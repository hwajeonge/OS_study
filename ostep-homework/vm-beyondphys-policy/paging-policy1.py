#! /usr/bin/env python

from __future__ import print_function
import sys
from optparse import OptionParser
import random
import math

# to make Python2 and Python3 act the same -- how dumb
def random_seed(seed):
    try:
        random.seed(seed, version=1)
    except:
        random.seed(seed)
    return

def convert(size):
    length = len(size)
    lastchar = size[length-1]
    if (lastchar == 'k') or (lastchar == 'K'):
        m = 1024
        nsize = int(size[0:length-1]) * m
    elif (lastchar == 'm') or (lastchar == 'M'):
        m = 1024*1024
        nsize = int(size[0:length-1]) * m
    elif (lastchar == 'g') or (lastchar == 'G'):
        m = 1024*1024*1024
        nsize = int(size[0:length-1]) * m
    else:
        nsize = int(size)
    return nsize

def hfunc(index):
    if index == -1:
        return 'MISS'
    else:
        return 'HIT '

def vfunc(victim):
    if victim == -1:
        return '-'
    else:
        return str(victim)

#
# main program
#
parser = OptionParser()
parser.add_option('-a', '--addresses', default='-1',   help='a set of comma-separated pages to access; -1 means randomly generate',  action='store', type='string', dest='addresses')
parser.add_option('-f', '--addressfile', default='',   help='a file with a bunch of addresses in it',                                action='store', type='string', dest='addressfile')
parser.add_option('-n', '--numaddrs', default='10',    help='if -a (--addresses) is -1, this is the number of addrs to generate',    action='store', type='string', dest='numaddrs')
parser.add_option('-p', '--policy', default='FIFO',    help='replacement policy: FIFO, LRU, OPT, UNOPT, RAND, CLOCK',                action='store', type='string', dest='policy')
parser.add_option('-b', '--clockbits', default=2,      help='for CLOCK policy, how many clock bits to use',                          action='store', type='int', dest='clockbits')
parser.add_option('-C', '--cachesize', default='3',    help='size of the page cache, in pages',                                      action='store', type='string', dest='cachesize')
parser.add_option('-m', '--maxpage', default='10',     help='if randomly generating page accesses, this is the max page number',     action='store', type='string', dest='maxpage')
parser.add_option('-s', '--seed', default='0',         help='random number seed',                                                    action='store', type='string', dest='seed')
parser.add_option('-N', '--notrace', default=False,    help='do not print out a detailed trace',                                     action='store_true', dest='notrace')
parser.add_option('-c', '--compute', default=False,    help='compute answers for me',                                                action='store_true', dest='solve')

(options, args) = parser.parse_args()

print('ARG addresses', options.addresses)
print('ARG addressfile', options.addressfile)
print('ARG numaddrs', options.numaddrs)
print('ARG policy', options.policy)
print('ARG clockbits', options.clockbits)
print('ARG cachesize', options.cachesize)
print('ARG maxpage', options.maxpage)
print('ARG seed', options.seed)
print('ARG notrace', options.notrace)
print('')

addresses   = str(options.addresses)
addressFile = str(options.addressfile)
numaddrs    = int(options.numaddrs)
cachesize   = int(options.cachesize)
seed        = int(options.seed)
maxpage     = int(options.maxpage)
policy      = str(options.policy)
notrace     = options.notrace
clockbits   = int(options.clockbits)

random_seed(seed)

addrList = []
if addressFile != '':
    fd = open(addressFile)
    for line in fd:
        addrList.append(int(line))
    fd.close()
else:
    if addresses == '-1':
        # 주소 생성이 필요함
        for i in range(0, numaddrs):
            n = int(maxpage * random.random())
            addrList.append(n)
    else:
        addrList = addresses.split(',')

if options.solve == False:
    print('Assuming a replacement policy of %s, and a cache of size %d pages,' % (policy, cachesize))
    print('figure out whether each of the following page references hit or miss')
    print('in the page cache.\n')

    for n in addrList:
        print('Access: %d  Hit/Miss?  State of Memory?' % int(n))
    print('')

else:
    if notrace == False:
        print('Solving...\n')

    # 메모리 구조 초기화
    count = 0
    memory = []
    hits = 0
    miss = 0

    if policy == 'FIFO':
        leftStr = 'FirstIn'
        riteStr = 'Lastin '
    elif policy == 'LRU':
        leftStr = 'LRU'
        riteStr = 'MRU'
    elif policy == 'MRU':
        leftStr = 'LRU'
        riteStr = 'MRU'
    elif policy == 'OPT' or policy == 'RAND' or policy == 'UNOPT' or policy == 'CLOCK':
        leftStr = 'Left '
        riteStr = 'Right'
    else:
        print('Policy %s is not yet implemented' % policy)
        exit(1)

    # FIFO with Second Chance에서 사용되는 참조 비트
    access = [0] * cachesize

    # 클록 정책을 위한 참조 비트 추적
    ref = {}
    cdebug = False

    # 주소 목록 처리
    addrIndex = 0
    for nStr in addrList:
        n = int(nStr)
        try:
            idx = memory.index(n)
            hits = hits + 1
            # 페이지가 메모리에 있을 경우 참조 비트 설정
            if policy == 'FIFO':
                access[idx] = 1
            elif policy == 'LRU' or policy == 'MRU':
                memory.remove(n)
                memory.append(n)  # MRU 쪽으로 이동
        except:
            idx = -1
            miss += 1

        victim = -1
        if idx == -1:
            if count == cachesize:
                if policy == 'FIFO':
                    victim = -1
                    while victim == -1:
                        for i in range(len(memory)):
                            if access[i] == 0:  
                                victim = memory.pop(i) 
                                access.pop(i) 
                                break  
                            else: 
                                access[i] = 0
                        if victim == -1: 
                            i = 0
                elif policy == 'LRU':
                    victim = memory.pop(0)
                elif policy == 'MRU':
                    victim = memory.pop(count-1)
                elif policy == 'RAND':
                    victim = memory.pop(int(random.random() * count))
                elif policy == 'CLOCK':
                    while victim == -1:
                        page = memory[int(random.random() * count)]
                        if ref[page] >= 1:
                            ref[page] -= 1
                        else:
                            victim = page
                            memory.remove(page)
                            break
                    del ref[victim]
                elif policy == 'OPT':
                    maxReplace  = -1
                    replaceIdx  = -1
                    replacePage = -1
                    for pageIndex in range(0, count):
                        page = memory[pageIndex]
                        whenReferenced = len(addrList)
                        for futureIdx in range(addrIndex + 1, len(addrList)):
                            futurePage = int(addrList[futureIdx])
                            if page == futurePage:
                                whenReferenced = futureIdx
                                break
                        if whenReferenced >= maxReplace:
                            replaceIdx  = pageIndex
                            replacePage = page
                            maxReplace  = whenReferenced
                    victim = memory.pop(replaceIdx)
                elif policy == 'UNOPT':
                    minReplace  = len(addrList) + 1
                    replaceIdx  = -1
                    replacePage = -1
                    for pageIndex in range(0, count):
                        page = memory[pageIndex]
                        whenReferenced = len(addrList)
                        for futureIdx in range(addrIndex + 1, len(addrList)):
                            futurePage = int(addrList[futureIdx])
                            if page == futurePage:
                                whenReferenced = futureIdx
                                break
                        if whenReferenced < minReplace:
                            replaceIdx  = pageIndex
                            replacePage = page
                            minReplace  = whenReferenced
                    victim = memory.pop(replaceIdx)
            else:
                victim = -1
                count += 1

            memory.append(n)
            if len(access) < cachesize:
                access.append(0)
            if victim != -1:
                assert(victim not in memory)

        if n not in ref:
            ref[n] = 1
        else:
            ref[n] += 1
            if ref[n] > clockbits:
                ref[n] = clockbits

        if notrace == False:
            print('Access: %d  %s %s -> %12s <- %s Replaced:%s [Hits:%d Misses:%d]' % (n, hfunc(idx), leftStr, memory, riteStr, vfunc(victim), hits, miss))
        addrIndex = addrIndex + 1
        
    print('')
    print('FINALSTATS hits %d   misses %d   hitrate %.2f' % (hits, miss, (100.0*float(hits))/(float(hits)+float(miss))))
    print('')

