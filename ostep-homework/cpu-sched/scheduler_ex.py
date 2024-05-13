#! /usr/bin/env python3

from __future__ import print_function
import sys
import heapq
from optparse import OptionParser
import random
from collections import deque

# to make Python2 and Python3 act the same -- how dumb
def random_seed(seed):
    try:
        random.seed(seed, version=1)
    except:
        random.seed(seed)
    return

parser = OptionParser()
parser.add_option("-s", "--seed", default=0, help="the random seed", action="store", type="int", dest="seed")
parser.add_option("-j", "--jobs", default=3, help="number of jobs in the system", action="store", type="int", dest="jobs")
parser.add_option("-l", "--jlist", default="", help="instead of random jobs, provide a comma-separated list of run times", action="store", type="string", dest="jlist")
parser.add_option("-m", "--maxlen", default=10, help="max length of job", action="store", type="int", dest="maxlen")
parser.add_option("-p", "--policy", default="FIFO", help="sched policy to use: SJF, FIFO, RR", action="store", type="string", dest="policy")
parser.add_option("-q", "--quantum", help="length of time slice for RR policy", default=1, action="store", type="int", dest="quantum")
parser.add_option("-a", "--arrivals", default="", help="comma-separated list of arrival times for each job", action="store", type="string", dest="arrivals")
parser.add_option("-c", help="compute answers for me", action="store_true", default=False, dest="solve")

(options, args) = parser.parse_args()

random_seed(options.seed)

print('ARG policy', options.policy)
if options.jlist == '':
    print('ARG jobs', options.jobs)
    print('ARG maxlen', options.maxlen)
    print('ARG seed', options.seed)
else:
    print('ARG jlist', options.jlist)
print('')

print('Here is the job list, with the run time of each job: ')

import operator

class Job:
    def __init__(self, number, burst, arrival):
        self.number = number
        self.burst = burst
        self.arrival = arrival
        self.remaining_time = burst  # 남은 실행 시간 초기화
        self.start_time = None
        self.completion_time = None
        self.total_burst_time = 0
        self.wait_time = None
        self.turnaround_time = None
        
    def __lt__(self, other):
        return self.remaining_time < other.remaining_time

joblist = []
if options.jlist == '':
    arrival_times = list(map(int, options.arrivals.split(','))) if options.arrivals else [0] * options.jobs
    joblist = [Job(jobnum, int(options.maxlen * random.random()) + 1, arrival_times[jobnum] if len(arrival_times) > jobnum else 0)
               for jobnum in range(options.jobs)]
    for job in joblist:
        print(f'  Job {job.number} ( length = {job.burst}, arrival = {job.arrival} )')
else:
    runtimes = list(map(int, options.jlist.split(',')))
    arrival_times = list(map(int, options.arrivals.split(','))) if options.arrivals else [0] * len(runtimes)
    joblist = [Job(jobnum, runtime, arrival_time) for jobnum, (runtime, arrival_time) in enumerate(zip(runtimes, arrival_times))]
    for job in joblist:
        print(f'  Job {job.number} ( length = {job.burst}, arrival = {job.arrival} )')
print('\n')


if options.solve == True:
    print('** Solutions **\n')
    if options.policy == 'SJF':
        print("Execution trace:")
        if all(job.arrival == joblist[0].arrival for job in joblist):
            # 비선점 SJF 로직 실행
            joblist.sort(key=lambda x: x.burst)
            current_time = 0
            for job in joblist:
                job.start_time = current_time
                job.completion_time = job.start_time + job.burst
                print(f'  [ time {job.start_time:3d} ] Run job {job.number} for {job.burst:.2f} secs (DONE at {job.completion_time:.2f})')
                current_time += job.burst
        else:
            # STCF 로직 실행
            current_time = 0
            ready_queue = []
            process_queue = deque(sorted(joblist, key=lambda x: x.arrival))
            active_process = None

            while process_queue or ready_queue:
                while process_queue and process_queue[0].arrival <= current_time:
                    heapq.heappush(ready_queue, process_queue.popleft())

                if not ready_queue:
                    if process_queue:
                        current_time = process_queue[0].arrival
                        continue
                    else:
                        break

                if not active_process or (ready_queue and ready_queue[0].remaining_time < active_process.remaining_time):
                    if active_process:
                        heapq.heappush(ready_queue, active_process)
                    active_process = heapq.heappop(ready_queue)
                    if active_process.start_time is None:
                        active_process.start_time = current_time

                next_event_time = process_queue[0].arrival if process_queue else float('inf')
                time_slice = min(active_process.remaining_time, next_event_time - current_time)
                active_process.remaining_time -= time_slice
                current_time += time_slice

                print(f'  [ time {current_time - time_slice:3d} ] Run job {active_process.number} for {time_slice:.2f} secs (DONE at {current_time:.2f})')

                if active_process.remaining_time == 0:
                    active_process.completion_time = current_time
                    active_process = None

        # Final statistics
        print('\nFinal statistics:')
        total_wait = 0
        total_turnaround = 0
        for job in joblist:
            response_time = job.start_time - job.arrival
            wait_time = job.completion_time - job.arrival - job.burst
            turnaround_time = job.completion_time - job.arrival
            total_wait += wait_time
            total_turnaround += turnaround_time
            print(f'  Job {job.number} -- Response: {response_time:.2f} Turnaround {turnaround_time:.2f} Wait {wait_time:.2f}')

        average_wait = total_wait / len(joblist)
        average_turnaround = total_turnaround / len(joblist)
        print(f'\n  Average -- Response: {average_wait:.2f} Turnaround {average_turnaround:.2f} Wait {average_wait:.2f}\n')

    if options.policy == 'FIFO':
        print('Execution trace:')
        thetime = 0
        total_wait = 0
        total_turnaround = 0

        joblist.sort(key=lambda job: job.arrival)

        for job in joblist:
            # job.start_time을 조정하여 이전 job.completion_time 또는 job.arrival 중 더 큰 시간으로 설정
            job.start_time = max(thetime, job.arrival)
            thetime = job.start_time + job.burst
            job.completion_time = thetime
            job.wait_time = job.start_time - job.arrival
            job.turnaround_time = job.completion_time - job.arrival

            total_wait += job.wait_time
            total_turnaround += job.turnaround_time

            print(f'  [ time {job.start_time} ] Run job {job.number} for {job.burst:.2f} secs (DONE at {job.completion_time})')

        average_wait = total_wait / len(joblist)
        average_turnaround = total_turnaround / len(joblist)

        print('\nFinal statistics:')
        for job in joblist:
            print(f'  Job {job.number} -- Response: {job.wait_time:.2f} Turnaround {job.turnaround_time:.2f} Wait {job.wait_time:.2f}')
        
        print(f'\n  Average -- Response: {average_wait:.2f} Turnaround {average_turnaround:.2f} Wait {average_wait:.2f}\n')


    if options.policy == 'RR':
        print('Execution trace:')
        ready_queue = deque()
        current_time = 0
        job_stats = []

        joblist.sort(key=lambda job: job.arrival)

        while joblist or ready_queue:
            if not ready_queue and joblist and joblist[0].arrival > current_time:
                current_time = joblist[0].arrival

            while joblist and joblist[0].arrival <= current_time:
                ready_queue.append(joblist.pop(0))

            if ready_queue:
                job = ready_queue.popleft()
                if job.start_time is None:
                    job.start_time = current_time

                process_time = min(job.burst, options.quantum)
                job.burst -= process_time
                job.total_burst_time += process_time

                print(f'  [ time {current_time:3d} ] Run job {job.number} for {process_time:.2f} secs')
                current_time += process_time

                if job.burst > 0:
                    ready_queue.append(job)
                else:
                    job.completion_time = current_time
                    print(f'  [ time {current_time:3d} ] Job {job.number} done at {current_time:.2f}')
                    response = job.start_time - job.arrival
                    turnaround = job.completion_time - job.arrival
                    wait = turnaround - job.total_burst_time
                    job_stats.append((job.number, response, turnaround, wait))

        print('\nFinal statistics:')
        for stat in job_stats:
            job_number, response, turnaround, wait = stat
            print(f'  Job {job_number:3d} -- Response: {response:.2f} Turnaround {turnaround:.2f} Wait {wait:.2f}')

        if job_stats:
            total_response = sum(stat[1] for stat in job_stats)
            total_turnaround = sum(stat[2] for stat in job_stats)
            total_wait = sum(stat[3] for stat in job_stats)
            num_jobs = len(job_stats)
            print(f'\n  Average -- Response: {total_response / num_jobs:.2f} Turnaround {total_turnaround / num_jobs:.2f} Wait {total_wait / num_jobs:.2f}\n')

    if options.policy != 'FIFO' and options.policy != 'SJF' and options.policy != 'RR':
        print('Error: Policy', options.policy, 'is not available.')
        sys.exit(0)
else:
    print('Compute the turnaround time, response time, and wait time for each job.')
    print('When you are done, run this program again, with the same arguments,')
    print('but with -c, which will thus provide you with the answers. You can use')
    print('-s <somenumber> or your own job list (-l 10,15,20 for example)')
    print('to generate different problems for yourself.')
    print('')
