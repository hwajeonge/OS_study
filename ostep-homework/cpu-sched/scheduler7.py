#! /usr/bin/env python3

from __future__ import print_function
import sys
from optparse import OptionParser
import random

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
if options.arrivals:
    print('ARG arrivals', options.arrivals)
print('')

print('Here is the job list, with the run time of each job: ')

joblist = []
completion_times = {}
if options.jlist == '':
    for jobnum in range(0, options.jobs):
        runtime = int(options.maxlen * random.random()) + 1
        arrival = 0  # Default arrival time
        if options.arrivals:
            arrivals = [int(x) for x in options.arrivals.split(',')]
            if jobnum < len(arrivals):
                arrival = arrivals[jobnum]
        joblist.append([jobnum, runtime, arrival])
        print('  Job', jobnum, '( length = ' + str(runtime) + ', arrival = ' + str(arrival) + ' )')
else:
    jobnum = 0
    runtimes = options.jlist.split(',')
    arrivals = options.arrivals.split(',') if options.arrivals else ['0'] * len(runtimes)
    for runtime, arrival in zip(runtimes, arrivals):
        joblist.append([jobnum, float(runtime), float(arrival)])
        jobnum += 1
    for job in joblist:
        print('  Job', job[0], '( length = ' + str(job[1]) + ', arrival = ' + str(job[2]) + ' )')
print('\n')

if options.solve:
    print('** Solutions **\n')
    thetime = 0
    running_job = None
    remaining_times = {job[0]: job[1] for job in joblist}  # 각 작업의 남은 실행 시간

    if options.policy == 'SJF' and options.arrivals:
        # Implementing STCF scheduling
        print('Executing STCF scheduling')
        joblist.sort(key=lambda x: (x[2], x[1]))  # Sort by arrival time, then by job length

        while joblist or running_job:
            # 현재 시간에 도착한 작업 찾기
            arrived_jobs = [job for job in joblist if job[2] <= thetime]
            for job in arrived_jobs:
                joblist.remove(job)

            if running_job is None or (arrived_jobs and min(arrived_jobs, key=lambda x: remaining_times[x[0]])[1] < remaining_times[running_job[0]]):
                # 새로운 작업을 시작하거나, 실행 중인 작업보다 더 짧은 작업으로 교체
                if running_job:
                    print(f'  [ time {thetime:3d} ] Interrupt job {running_job[0]} (remaining time {remaining_times[running_job[0]]:.2f})')
                running_job = min(arrived_jobs, key=lambda x: remaining_times[x[0]], default=running_job)

            # 실행 중인 작업 업데이트
            if running_job:
                print(f'  [ time {thetime:3d} ] Run job {running_job[0]} for 1 unit')
                remaining_times[running_job[0]] -= 1
                if remaining_times[running_job[0]] <= 0:
                    print(f'  [ time {thetime:3d} ] Finish job {running_job[0]}')
                    running_job = None
            
            thetime += 1
        else:
            # SJF scheduling
            print('Executing SJF scheduling')
            joblist.sort(key=lambda x: x[1])  # Sort by job length

            for job in joblist:
                if thetime < job[2]:  # If the next job arrives later than the current time
                    thetime = job[2]
                print(f'  [ time {thetime:3d} ] Run job {job[0]} for {job[1]} secs ( DONE at {thetime + job[1]:.2f} )')
                thetime += job[1]
                completion_times[job[0]] = thetime

        total_wait = total_turnaround = total_response = 0.0
        for job in joblist:
            jobnum, runtime, arrival = job
            completion = completion_times[jobnum]
            response_time = completion - runtime - arrival
            wait_time = response_time
            turnaround_time = completion - arrival
            print(f'  Job {jobnum} -- Response: {response_time:.2f} Turnaround: {turnaround_time:.2f} Wait: {wait_time:.2f}')

            total_wait += wait_time
            total_turnaround += turnaround_time
            total_response += response_time

        n = len(joblist)
        print(f'\n  Average -- Response: {total_response/n:.2f} Turnaround: {total_turnaround/n:.2f} Wait: {total_wait/n:.2f}\n')

    elif options.policy == 'FIFO':
        # FIFO scheduling
        print('Executing FIFO scheduling')
        joblist.sort(key=lambda x: x[2])  # Sort by arrival time

        for job in joblist:
            if thetime < job[2]:  # If the next job arrives later than the current time
                thetime = job[2]
            print(f'  [ time {thetime:3d} ] Run job {job[0]} for {job[1]} secs ( DONE at {thetime + job[1]:.2f} )')
            thetime += job[1]
            completion_times[job[0]] = thetime

        total_wait = total_turnaround = total_response = 0.0
        for job in joblist:
            jobnum, runtime, arrival = job
            completion = completion_times[jobnum]
            response_time = completion - arrival
            wait_time = response_time - runtime
            turnaround_time = completion - arrival

            print(f'  Job {jobnum} -- Response: {response_time:.2f} Turnaround: {turnaround_time:.2f} Wait: {wait_time:.2f}')

            total_wait += wait_time
            total_turnaround += turnaround_time
            total_response += response_time

        n = len(joblist)
        print(f'\n  Average -- Response: {total_response/n:.2f} Turnaround: {total_turnaround/n:.2f} Wait: {total_wait/n:.2f}\n')

    elif options.policy == 'RR':
    # RR scheduling
        print('Executing RR scheduling')
        joblist.sort(key=lambda x: x[2])  # Sort by arrival time

        runlist = joblist.copy()
        remaining_times = {job[0]: job[1] for job in joblist}  # Initialize remaining times for all jobs
        thetime = 0

        while runlist:
        # Get jobs that have arrived
            current_jobs = [job for job in runlist if job[2] <= thetime]
            if not current_jobs:
                # Skip time to next job arrival
                thetime = min(job[2] for job in runlist if job[2] > thetime)
                continue

            job = current_jobs[0]
            executed_time = min(options.quantum, remaining_times[job[0]])
            print(f'  [ time {thetime:3d} ] Run job {job[0]} for min({options.quantum}, {executed_time}) secs')
            remaining_times[job[0]] -= executed_time
            thetime += executed_time

            if remaining_times[job[0]] <= 0:
                print(f'  [ time {thetime:3d} ] Finish job {job[0]}')
                completion_times[job[0]] = thetime
                runlist.remove(job)
            else:
            # If the job is not completed, move the job to the end of the list
                runlist.append(runlist.pop(0))

            if thetime < job[2] + executed_time:
            # There's still time left in the quantum; attempt to start the next job
                thetime = job[2] + executed_time

        total_wait = total_turnaround = total_response = 0.0
        for job in joblist:
            jobnum, runtime, arrival = job
            completion = completion_times.get(jobnum, thetime)  # Use the last known time if the job is not completed
            response_time = completion - arrival - (runtime - remaining_times[jobnum])
            wait_time = response_time
            turnaround_time = completion - arrival

            print(f'  Job {jobnum} -- Response: {response_time:.2f} Turnaround: {turnaround_time:.2f} Wait: {wait_time:.2f}')

            total_wait += wait_time
            total_turnaround += turnaround_time
            total_response += response_time

        n = len(joblist)
        print(f'\n  Average -- Response: {total_response/n:.2f} Turnaround: {total_turnaround/n:.2f} Wait: {total_wait/n:.2f}\n')

