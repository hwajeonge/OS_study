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
    parser.add_option("-p", "--policy", default="FIFO", help="sched policy to use: SJF, FIFO, RR", action="store", type="string", dest="policy")
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

def execute_fifo(joblist):
    print('** Executing FIFO scheduling **\n')
    thetime = 0
    completion_times = {}
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
    if n > 0:
        print(f'\n  Average -- Response: {total_response/n:.2f} Turnaround: {total_turnaround/n:.2f} Wait: {total_wait/n:.2f}\n')


def execute_sjf(joblist):
    print('** Executing SJF scheduling **\n')
    joblist.sort(key=lambda job: (job[2], job[1]))  # Sort by arrival time then by job length
    current_time = 0
    completion_times = {}
    total_wait = total_turnaround = total_response = 0.0

    while joblist or any([job[1] > 0 for job in joblist]):
        next_job = min((job for job in joblist if job[1] > 0), default=None, key=lambda job: job[1])

        if next_job and current_time >= next_job[2]:
            print(f'  [ time {current_time:3d} ] Run job {next_job[0]} for {next_job[1]:.2f} secs')
            current_time += next_job[1]
            completion_times[next_job[0]] = current_time
            next_job[1] = 0  # Job is completed

            response_time = current_time - next_job[2] - next_job[1]
            turnaround_time = current_time - next_job[2]
            wait_time = turnaround_time - next_job[1]

            print(f'  [ time {current_time:3d} ] Finish job {next_job[0]} at {current_time:.2f}')
            print(f'  Job {next_job[0]} -- Response: {response_time:.2f} Turnaround: {turnaround_time:.2f} Wait: {wait_time:.2f}')

            total_response += response_time
            total_turnaround += turnaround_time
            total_wait += wait_time
        else:
            print(f'  [ time {current_time:3d} ] No jobs to run')
            current_time += 1  # Increment time if no jobs are available to run

    n = len(completion_times)
    if n > 0:
        print(f'\n  Average -- Response: {total_response/n:.2f} Turnaround: {total_turnaround/n:.2f} Wait: {total_wait/n:.2f}\n')


def execute_stcf(joblist):
    print('** Executing STCF scheduling **\n')
    joblist.sort(key=lambda job: job[2])  # Sort by arrival time
    current_time = 0
    ready_queue = []
    remaining_times = {job[0]: job[1] for job in joblist}
    completion_times = {}
    total_wait = total_turnaround = total_response = 0.0

    while joblist or ready_queue or any(job[1] for job in ready_queue):
        # Load jobs into the ready queue as they arrive
        while joblist and joblist[0][2] <= current_time:
            heapq.heappush(ready_queue, (joblist[0][1], joblist.pop(0)))

        # Select job with the shortest remaining time
        if ready_queue:
            running_job = heapq.heappop(ready_queue)[1]
            # Run the job for one time unit
            print(f'  [ time {current_time:3d} ] Run job {running_job[0]} for 1 unit')
            remaining_times[running_job[0]] -= 1
            if remaining_times[running_job[0]] == 0:
                # Job finishes
                completion_times[running_job[0]] = current_time + 1
                print(f'  [ time {current_time + 1:3d} ] Finish job {running_job[0]} at {current_time + 1:.2f}')
                
                response_time = (current_time + 1) - running_job[2]
                turnaround_time = (current_time + 1) - running_job[2]
                wait_time = turnaround_time - running_job[1]

                print(f'  Job {running_job[0]} -- Response: {response_time:.2f} Turnaround: {turnaround_time:.2f} Wait: {wait_time:.2f}')

                total_response += response_time
                total_turnaround += turnaround_time
                total_wait += wait_time
            else:
                # Reinsert the job back into the ready queue with updated remaining time
                heapq.heappush(ready_queue, (remaining_times[running_job[0]], running_job))

        else:
            print(f'  [ time {current_time:3d} ] No jobs to run')

        current_time += 1  # Increment time

    n = len(completion_times)
    if n > 0:
        print(f'\n  Average -- Response: {total_response/n:.2f} Turnaround: {total_turnaround/n:.2f} Wait: {total_wait/n:.2f}\n')



def execute_rr(joblist, quantum):
    print('** Executing RR scheduling **\n')
    joblist.sort(key=lambda x: x[2])  # Sort by arrival time
    ready_queue = []
    current_time = 0
    total_wait = total_turnaround = total_response = 0.0
    completed_jobs = 0
    running_job = None

    while joblist or ready_queue or running_job:
        # Add new jobs to the ready queue if it is their arrival time
        while joblist and joblist[0][2] <= current_time:
            new_job = joblist.pop(0)
            if running_job and not (running_job[1] <= 0):
                # Preempt the running job if a new job arrives
                ready_queue.insert(0, running_job)
                running_job = new_job
            else:
                ready_queue.append(new_job)

        if not running_job and ready_queue:
            # Pop the first job from the ready queue to run it
            running_job = ready_queue.pop(0)

        if running_job:
            # Calculate process time
            process_time = min(running_job[1], quantum)
            print(f'  [ time {current_time:3d} ] Run job {running_job[0]} for {process_time:.2f} secs')
            running_job[1] -= process_time
            start_time = current_time  # Record the start time of this slice
            current_time += process_time

            # Check if the job is completed
            if running_job[1] <= 0:
                print(f'  [ time {current_time:3d} ] Job {running_job[0]} completed')
                completion_time = current_time
                response_time = completion_time - running_job[2] - running_job[1]
                turnaround_time = completion_time - running_job[2]
                wait_time = turnaround_time - (running_job[1] + process_time)

                print(f'  Job {running_job[0]} -- Response: {response_time:.2f} Turnaround: {turnaround_time:.2f} Wait: {wait_time:.2f}')

                total_response += response_time
                total_turnaround += turnaround_time
                total_wait += wait_time
                completed_jobs += 1

                running_job = None  # Reset running_job
            else:
                # If the job is not finished, put it back into the queue
                ready_queue.append(running_job)
                running_job = None

    if completed_jobs > 0:
        print(f'\n  Average -- Response: {total_response / completed_jobs:.2f} Turnaround: {total_turnaround / completed_jobs:.2f} Wait: {total_wait / completed_jobs:.2f}\n')



if __name__ == '__main__':
    main() 
