#! /usr/bin/env python3

from __future__ import print_function
import sys
import random
import heapq
from optparse import OptionParser

def random_seed(seed):
    try:
        random.seed(seed, version=1)
    except:
        random.seed(seed)
    return

def print_job_list(joblist):
    for job in joblist:
        print('  Job', job[0], '( length = ' + str(job[1]) + ', arrival = ' + str(job[2]) + ' )')

def parse_options():
    parser = OptionParser()
    parser.add_option("-s", "--seed", default=0, help="the random seed", action="store", type="int", dest="seed")
    parser.add_option("-j", "--jobs", default=3, help="number of jobs in the system", action="store", type="int", dest="jobs")
    parser.add_option("-l", "--jlist", default="", help="instead of random jobs, provide a comma-separated list of run times", action="store", type="string", dest="jlist")
    parser.add_option("-m", "--maxlen", default=10, help="max length of job", action="store", type="int", dest="maxlen")
    parser.add_option("-p", "--policy", default="FIFO", help="sched policy to use: SJF, FIFO, RR, STCF", action="store", type="string", dest="policy")
    parser.add_option("-q", "--quantum", help="length of time slice for RR policy", default=1, action="store", type="int", dest="quantum")
    parser.add_option("-a", "--arrival_time", default="", help="comma-separated list of arrival times for each job", action="store", type="string", dest="arrival_time")
    parser.add_option("-c", help="compute answers for me", action="store_true", default=False, dest="solve")
    return parser.parse_args()

def main():
    options, args = parse_options()
    random_seed(options.seed)

    print('ARG policy', options.policy)
    if options.jlist == '':
        print('ARG jobs', options.jobs)
        print('ARG maxlen', options.maxlen)
        print('ARG seed', options.seed)
    else:
        print('ARG jlist', options.jlist)
    if options.arrival_time:
        print('ARG arrival_time', options.arrival_time)
    print('')

    print('Here is the job list, with the run time of each job: ')
    joblist = []
    if options.jlist == '':
        for jobnum in range(options.jobs):
            runtime = int(options.maxlen * random.random()) + 1
            arrival = 0
            if options.arrival_time:
                arrivals = [int(x) for x in options.arrival_time.split(',')]
                if jobnum < len(arrivals):
                    arrival = arrivals[jobnum]
            joblist.append([jobnum, runtime, arrival])
    else:
        jobnum = 0
        runtimes = options.jlist.split(',')
        arrivals = options.arrival_time.split(',') if options.arrival_time else ['0'] * len(runtimes)
        for runtime, arrival in zip(runtimes, arrivals):
            joblist.append([jobnum, float(runtime), float(arrival)])
            jobnum += 1
    print_job_list(joblist)
    print('\n')

    if options.solve:
        if options.policy == 'SJF':
            if options.arrival_time:
                execute_stcf(joblist)
            else:
                execute_sjf(joblist)
        elif options.policy == 'FIFO':
            execute_fifo(joblist)
        elif options.policy == 'RR':
            execute_rr(joblist, options.quantum)
        elif options.policy == 'STCF':
            execute_stcf(joblist)

def execute_fifo(joblist):
    print('** Executing FIFO scheduling **\n')
    thetime = 0
    job_responses = {}
    start_times = {}
    completion_times = {}
    joblist.sort(key=lambda x: x[2])  # Sort by arrival time

    for job in joblist:
        if thetime < job[2]:  # If the next job arrives later than the current time
            thetime = job[2]
        if job[0] not in job_responses:
            job_responses[job[0]] = thetime - job[2]  # Response time is first execution start minus arrival
        start_times[job[0]] = thetime
        print(f'  [ time {thetime:3d} ] Run job {job[0]} for {job[1]} secs ( DONE at {thetime + job[1]:.2f} )')
        thetime += job[1]
        completion_times[job[0]] = thetime

    total_wait = total_turnaround = total_response = 0.0
    for job in joblist:
        jobnum, runtime, arrival = job
        completion = completion_times[jobnum]
        response_time = job_responses[jobnum]
        wait_time = start_times[jobnum] - arrival
        turnaround_time = completion - arrival

        print(f'  Job {jobnum} -- Response: {response_time:.2f} Turnaround: {turnaround_time:.2f} Wait: {wait_time:.2f}')

        total_wait += wait_time
        total_turnaround += turnaround_time
        total_response += response_time

    n = len(joblist)
    if n > 0:
        print(f'\n  Average -- Response: {total_response/n:.2f} Turnaround: {total_turnaround/n:.2f} Wait: {total_wait/n:.2f}\n')


def execute_sjf(joblist):
    print('** Executing SJF scheduling **\n')
    joblist.sort(key=lambda job: (job[2], job[1]))  # 도착 시간과 작업 길이로 정렬
    current_time = 0
    first_run = {}
    start_times = {}
    completion_times = {}

    for job in joblist:
        if current_time < job[2]:
            current_time = job[2]
        if job[0] not in first_run:
            first_run[job[0]] = current_time
        start_times[job[0]] = current_time
        print(f'  [ time {current_time:3d} ] Run job {job[0]} for {job[1]:.2f} secs')
        current_time += job[1]
        completion_times[job[0]] = current_time

    total_wait = total_turnaround = total_response = 0.0
    for job in joblist:
        jobnum = job[0]
        response_time = first_run[jobnum] - job[2]
        completion = completion_times[jobnum]
        wait_time = start_times[jobnum] - job[2]
        turnaround_time = completion - job[2]

        print(f'  Job {jobnum} -- Response: {response_time:.2f} Turnaround: {turnaround_time:.2f} Wait: {wait_time:.2f}')

        total_wait += wait_time
        total_turnaround += turnaround_time
        total_response += response_time

    n = len(joblist)
    if n > 0:
        print(f'\n  Average -- Response: {total_response/n:.2f} Turnaround: {total_turnaround/n:.2f} Wait: {total_wait/n:.2f}\n')


def execute_stcf(joblist):
    print('** Executing STCF scheduling **\n')
    current_time = 0
    ready_queue = []
    running_job = None
    remaining_times = {job[0]: job[1] for job in joblist}
    first_run = {}
    start_times = {}
    completion_times = {}
    arrival_times = {job[0]: job[2] for job in joblist}  # 도착 시간 저장
    wait_times = {job[0]: 0 for job in joblist}  # 대기 시간 초기화
    queue_entry_times = {job[0]: job[2] for job in joblist}  # 큐 진입 초기 시간 설정

    while joblist or ready_queue or running_job:
        while joblist and joblist[0][2] <= current_time:
            new_job = joblist.pop(0)
            heapq.heappush(ready_queue, (new_job[1], new_job))
            queue_entry_times[new_job[0]] = current_time  # 큐 진입 시간 갱신

        if not running_job or (ready_queue and ready_queue[0][0] < remaining_times[running_job[0]]):
            if running_job:
                print(f'  [ time {current_time:3d} ] Interrupt job {running_job[0]} (remaining time {remaining_times[running_job[0]]:.2f})')
                heapq.heappush(ready_queue, (remaining_times[running_job[0]], running_job))
                queue_entry_times[running_job[0]] = current_time  # 재진입 시간 갱신
            if ready_queue:
                running_job = heapq.heappop(ready_queue)[1]
                if running_job[0] not in first_run:
                    first_run[running_job[0]] = current_time - arrival_times[running_job[0]]
                wait_times[running_job[0]] += current_time - queue_entry_times[running_job[0]]

        if running_job:
            print(f'  [ time {current_time:3d} ] Run job {running_job[0]} for 1 unit')
            remaining_times[running_job[0]] -= 1
            if remaining_times[running_job[0]] <= 0:
                print(f'  [ time {current_time:3d} ] Finish job {running_job[0]}')
                completion_times[running_job[0]] = current_time
                running_job = None

        current_time += 1

    total_wait = total_turnaround = total_response = 0.0
    for jobnum in first_run:
        response_time = first_run[jobnum]
        completion = completion_times[jobnum] + 1
        turnaround_time = completion - arrival_times[jobnum]
        print(f'  Job {jobnum} -- Response: {response_time:.2f} Turnaround: {turnaround_time:.2f} Wait: {wait_times[jobnum]:.2f}')

        total_wait += wait_times[jobnum]
        total_turnaround += turnaround_time
        total_response += response_time

    n = len(first_run)
    if n > 0:
        print(f'\n  Average -- Response: {total_response/n:.2f} Turnaround: {total_turnaround/n:.2f} Wait: {total_wait/n:.2f}\n')

def execute_rr(joblist, quantum):
    print('** Executing RR scheduling **\n')
    joblist.sort(key=lambda x: x[2])  # 도착 시간에 따라 정렬
    ready_queue = []
    current_time = 0
    job_responses = {}
    start_times = {}
    completion_times = {}
    arrival_times = {}
    wait_times = {}  # 각 작업의 대기 시간을 저장할 사전
    last_time = {}   # 각 작업이 마지막으로 준비 큐에 들어간 시간

    # 모든 작업의 도착 시간을 사전에 저장
    for job in joblist:
        arrival_times[job[0]] = job[2]
        wait_times[job[0]] = 0
        last_time[job[0]] = job[2]  # 초기 도착 시간을 마지막으로 준비 큐에 들어간 시간으로 설정

    running_job = None

    while joblist or ready_queue or running_job:
        # 도착한 작업을 준비 큐에 추가
        while joblist and joblist[0][2] <= current_time:
            new_job = joblist.pop(0)
            ready_queue.append(new_job)
            if running_job and running_job[1] > 0:
                ready_queue.append(running_job)
                running_job = None

        # 다음 작업 실행
        if not running_job and ready_queue:
            running_job = ready_queue.pop(0)
            if running_job[0] not in job_responses:
                job_responses[running_job[0]] = current_time - arrival_times[running_job[0]]
            start_times[running_job[0]] = current_time
            # 대기 시간 계산: 준비 큐에 마지막으로 들어간 시간부터 실행 시작 시간까지
            wait_times[running_job[0]] += current_time - last_time[running_job[0]]

        # 작업 실행
        if running_job:
            process_time = min(running_job[1], quantum)
            print(f'  [ time {current_time:3d} ] Run job {running_job[0]} for {process_time:.2f} secs')
            running_job[1] -= process_time
            current_time += process_time

            if running_job[1] <= 0:
                print(f'  [ time {current_time:3d} ] Job {running_job[0]} completed')
                completion_times[running_job[0]] = current_time
                running_job = None
            else:
                ready_queue.append(running_job)
                last_time[running_job[0]] = current_time
                running_job = None

    # 최종 통계 계산 및 출력
    total_wait = total_turnaround = total_response = 0.0
    for jobnum in job_responses:
        response_time = job_responses[jobnum]
        completion = completion_times[jobnum]
        turnaround_time = completion - arrival_times[jobnum]
        wait_time = wait_times[jobnum]

        print(f'  Job {jobnum} -- Response: {response_time:.2f} Turnaround: {turnaround_time:.2f} Wait: {wait_time:.2f}')

        total_wait += wait_time
        total_turnaround += turnaround_time
        total_response += response_time

    n = len(job_responses)
    if n > 0:
        print(f'\n  Average -- Response: {total_response/n:.2f} Turnaround {total_turnaround/n:.2f} Wait {total_wait/n:.2f}\n')



if __name__ == '__main__':
    main()


