./run.sh
ls
cd xv6edk
cd xv6edk2
cd xv6
ls
mv _hello.c hello.c
cd xv6edk2
cd xv6
ls
cd xv6edk/xv6
cd xv6edk2/xv6
cat README
grep run README
;s
ls
cd xv6edk2/
ls
./dbgrun.sh 
gdb kernelmemfs
cd xv6edk2/xv6
make kernelmemfs
cd ..
cp MyLoaderPkg/loader.efi image/efi/boot/bootx64.efi
cp MyLoaderPkg/X64/DEBUG_GCC5/X64/loader.efi image/efi/boot/bootx64.efi
cp image/efi/boot/bootx64.efi
ls
cd xv6edk2/
ls
cd xv6/
make clean
make kernelmemfs 
cd ..
./run.sh 
cd xv6edk2/
./dbgrun.sh 
cd xv6edk2/
cd xv6/
gdb kernelmemfs
cd xv6edk2
cd xv6
make kernelmemfs
mkdir -p image/efi/boot
cp image/efi/boot/bootx64.efi 
cp xv6/kernelmemfs image/kernel
cp kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd ..
./run.sh
cd xv6edk2
xv6
cd xv6
make kernelmemfs
vi test.c
make kernelmemfs
vi defs.h
cd xv6edk2
cd xv6
ls
makekernelmemfs
make kernelmemfs
ls
make kernelmemfs
vi kernelmemfs
make kernelmemfs
vi user.h
make kernelmemfs
ls
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
./run.sh
cd xv6edk2
cd xv6
vi user.h
vi usys.S
vi syscall.h
vi syscall.c
vi sysproc.c
vi proc.c
vi user.h
vi usys.S
vi syscall.h
vi syscall.c
vi sysproc.c
vi proc.c
vi syscall.c
vi sysproc.c
vi proc.h
make clean
make
vi test
vi Makefile
make kernelmemfs
ls
rm test
vi test.c
vi Makefile
make kernelmemfs
rm test.c
vi Makefile
make clean
make kernelmemfs
vi main.c
vi test.c
gcc -o test test.c
./test
rm test.c
vi usys.S
vi test.c
vi Makefile
gcc -o test test.c
make kernelmemfs
vi Makefile
vi test.c
sudo apt update
sudo apt install build-essential
make kernelmemfs
sudo apt install libc6-dev
echo | gcc -v -E -x c -
make kernelmemfs
rm test.c
make kernelmemfs
vi Makefile
make kernelmemfs
vi defs.h
vi test.c
rm test.c
vi test.c
vi Makefile
vi test.c
make kernelmemfs
vi user.h
vi test.c
git clone https://github.com/remzi-arpacidusseau/ostep-homework.git
python -V
cd ostep-homework
python -V
python3
cd ostep-homework
vi scheduler.py
ls
cd cpu-sched
vi scheduler.py
python3 --version
python3 scheduler.py
python3 shceduler.py -c
python3 scheduler.py
-c
-q
cd ostep-homework
cd cpu-sched
vi scheduler
vi schduler.py
rm scheduler
rm schduler.py
vi scheduler.py
cd ostep-homework
cd cpu-sched
vi scheduler.py
vi scheduler2.py
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
python3 scheduler2.py -p FIFO -a "0, 2, 4" -j 3 -m 10
rm scheduler2.py
vi scheduler2.py
rm scheduler2.py
vi scheduler2.py
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
rm scheduler2.py
vi scheduler2.py
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 19
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
vi scheduler2.py
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
python3 scheduler2.py -p FIFO -j 3 -m 10
python3 scheduler.py -p FIFO -j -m 10
rm scheduler.py
vi scheduler.py
rm scheduler2.py
vi scheduler2.py
python3 scheduler.py -p SJF -a "0, 2, 4" -j 3 -m 10
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
vi scheduler2.py
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
rm scheduler2.py
vi scheduler2.py
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
vi scheduler2.py
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
:wq
vi scheduler2.py
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
vi scheduler2.py
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
vi scheduler2.py
rm scheduler2.py
python3 scheduler.py
vi scheduler2.py
python3 scheduler2.py
python3 scheduler2.py -p SJF -a "0, 2, 4" -j 3 -m 10
rm scheduler2.py
vi scheduler2.py
python3 scheduler2.py
python3 scheduler2.py -a "0, 2, 4"
rm scheduler2.py
vi scheduler2.py
python3 scheduler2.py
python3 scheduler2.py -a "0, 2, 4"
vi scheduler2.py
python3 scheduler2.py
rm scheduler2.py
vi scheduler2.py
python3 scheduler2.py
python3 scheduler2.py -p FIFO -a "0, 2, 4" -j 3 -m 10
vi scheduler.py
cd ostep-homework
cd cpu-sche
cd cpu-sched
vi scheduler2.py
python3 scheduler2.py -c -p SJF -a "0, 2, 4" -j 3 -m 10
python3 scheduler2.py -c -p FIFO -a "0, 2, 4" -j 3 -m 10
python3 scheduler2.py -c -p RR -a "0, 2, 4" -j 3 -m 10
python3 scheduler2.py -c -p RR -j 3 -m 10
python3 scheduler2.py -c -p FIFO -j 3 -m 10
python3 scheduler2.py -c -p FIFO -a "0, 2, 4" -j 3 -m 10
python3 scheduler2.py -c -p FIFO -a "2, 0, 4" -j 3 -m 10
vi scheduler3.py
python3 scheduler3.py -c -p RR -a "0, 2, 4" -j 3 -m 10
vi scheduler3.py
rm scheduler3.py
vi scheduler3.py
python3 scheduler3.py
python3 scheduler3.py -p RR -a "0, 2, 4" -j 3 -m 10
python3 scheduler3.py -c -p RR -a "0, 2, 4" -j 3 -m 10
python3 scheduler3.py
python3 scheduler3.py -c -p SJF -j 3 -m 10
python3 scheduler2.py -c -p SJF -j 3 -m 10
vi scheduler3.py
rm scheduler3.py
vi scheduler3.py
python3 scheduler3.py -c -p RR -a "0, 2, 4" -j 3 -m 10
rm scheduler2.py -c -pRR -a "0, 2, 4"
scheduler2.py -c -p
rm scheduler3.py
python3 scheduler2.py -c -p RR -a "0, 2, 4"
cd ostep-homework
cd cpu-sched
python3 scheduler2.py -c -p FIFO -a "0, 2, 4"
python3 scheduler2.py -c -p RR -a "0, 1, 7"
cd ostep-homework
cd cpu-sched
python3 scheduler2.py -c -p SFJ
cd ostep-homework
cd cpu-sched
vi scheduler5.py
python3 script.py -p RR -a "0, 2, 4" -c
python3 scheduler5.py -p RR -a 
python3 sscheduler5.py -p RR -a "0, 2, 4" -c
python3 scheduler5.py -p RR -a "0, 2, 4" -c
rm scheduler5.py
vi scheduler5.py
python3 scheduler5.py -p RR -a "0, 2, 4" -c
rm scheduler5.py
vi scheduler5.py
python3 scheduler5.py -p RR -a "0, 2, 4" -c
python3 scheduler5.py -p RR -c
python3 scheduler5.py -p FIFO -c
python3 scheduler5.py -p FIFO -a "2, 0, 4" -c
python3 scheduler5.py -p SJF -c
rm scheduler5.py
vi scheduler5.py
python3 scheduler5.py -p SJF -c
python3 scheduler5.py -p SJF -a -c
python3 scheduler5.py -p SJF -a "0, 2, 4" -c
python3 scheduler5.py -p SJF -a "2, 0, 1" -c
python3 scheduler5.py -p RR -a "2, 0, 1" -c
python3 scheduler5.py -p RR -a "0, 2, 4" -c
python3 scheduler5.py -p SJF -a "2, 0, 1" -c
rm scheduler5.py
vi scheduler5.py
python3 scheduler5.py -p RR -a "0, 2, 4 -c

python3 scheduler5.py -p RR -a "0, 2, 4" -c
rm scheduler5.py
vi scheduler5.py
python3 scheduler5.py -p RR -a "0, 2, 4" -c
rm scheduler5.py
vi scheduler5.py
python3 scheduler5.py -p RR -a "0, 2, 4" -c
rm scheduler5.py
vi scheduler5.py
python3 scheduler5.py -p RR -a "0, 2, 4" -c
rm scheduler5.py
vi scheduler5.py
python3 scheduler5.py -p RR -a "0, 2, 4" -c
rm scheduler5.py
vi scheduler5.py
python3 scheduler5.py -p RR -a "0, 2, 4" -c
python3 scheduler5.py -p SFJ -c
python3 scheduler5.py -p SFJ -a "0, 2, 4" -c
rm scheduler5.py
vi scheduler5.py
python3 scheduler5.py -p SFJ -a "0, 2, 4" -c
python3 scheduler5.py -p FIFO -a "0, 2, 4" -c
vi scheduler_ex.py
python3 scheduler5.py -p RR -a "0, 2, 4" -c
python3 scheduler_ex.py -p RR -a "0, 2, 4" -c
vi scheduler_ex.py
python3 scheduler_ex.py -p RR -a "0, 2, 4" -c
python3 scheduler_ex.py -p RR -j 3 -s 100 -q 1 -c -a "0,2,4"
python3 scheduler5.py -p RR -j 3 -s 100 -q 1 -c -a "0,2,4"
python3 scheduler5.py -p RR -j 3 -s 100 -q 1 -c
python3 scheduler5.py -p SJF -j 3 -s 100 -q 1 -c -a "0, 2, 4
python3 scheduler5.py -p SJF -j 3 -s 100 -a "0,2,4" -l "3,5,2" -c

python3 scheduler5.py -p SJF -j 3 -s 100 -a "0,2,4" -l "3,5,2" -c
python3 scheduler_a.py -p SJF -j 3 -s 100 -a "0,2,4" -l "3,5,2" -c
python3 scheduler5.py -p SJF -j 3 -s 100 -c
python3 scheduler_a.py -p SJF -j 3 -s 100 -c
python3 scheduler_a.py -p RR\ -j 3 -s 100 -c
python3 scheduler_a.py -p RR -j 3 -s 100 -c
python3 scheduler_a.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_a.py -p FIFO -j 3 -s 100 -c 
python3 scheduler_a.py -p FIFO -j 3 -s 100 -c -a "0, 2, 4"
vi scheduler_b.py
python3 scheduler_b.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
vi scheduler_b.py
python3 scheduler_b.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
vi scheduler_b.py
python3 scheduler_b.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_b.py -p SJF -j 3 -s 100 -a "0,2,4" -l "3,5,2" -c
python3 scheduler_a.py -p FIFO -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_a.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler.py -p RR -j 3 -s 100 -c
python3 scheduler.py -p FIFO -j 3 -s 100 -c
rm scheduler_b
rm scheduler_b.py
vi scheduler_b.py
python3 scheduler_b.py -p FIFO -j 3 -s 100 -c
python3 scheduler_b.py -p FIFO -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_b.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_b.py -p RR -j 3 -s 100 -c
python3 scheduler_b.py -p SJF -j 3 -s 100 -c
python3 scheduler\.py -p SJF -j 3 -s 100 -c
python3 scheduler.py -p SJF -j 3 -s 100 -c
python3 scheduler_b.py -p SJF -j 3 -s 100 -c -a "0, 2, 4" -l "3, 5, 2"
vi scheduler_c.py
python3 scheduler_c.py -p SJF -j 3 -s 100 -c -a "0, 2, 4" -l "3, 5, 2"
python3 scheduler_b.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
rm scheduler_c.py
vi scheduler_c.py
python3 scheduler_c.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_c.py -p RR -j 3 -s 100 -c 
python3 scheduler_c.py -p FIFO -j 3 -s 100 -c 
python3 scheduler_c.py -p FIFO -j 3 -s 100 -c -a "0, 2, 4
python3 scheduler_c.py -p FIFO -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_c.py -p SJF -j 3 -s 100 -c 
python3 scheduler_c.py -p SJF -j 3 -s 100 -c -a "0, 2, 4" -l "3, 5, 2"
vi scheduler_d.py
python3 scheduler_d.py -p SJF -j 3 -s 100 -c -a "0, 2, 4" -l "3, 5, 2"
python3 scheduler_d.py -p SJF -j 3 -s 100 -c
python3 scheduler_d.py -p FIFO -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_d.py -p FIFO -j 3 -s 100 -c 
python3 scheduler_d.py -p RR -j 3 -s 100 -c -a "0, 2, 4" 
python3 scheduler_d.py -p RR -j 3 -s 100 -c 
vi scheduler_e.py
python3 scheduler_d.py -p RR -j 3 -s 100 -c 
rm scheduler_e.py
vi scheduler_e.py
python3 scheduler_d.py -p RR -j 3 -s 100 -c 
rm scheduler_e.py
vi scheduler_e.py
python3 scheduler_e.py -p RR -j 3 -s 100 -c 
rm scheduler_e.py
vi scheduler_e.py
python3 scheduler_e.py -p RR -j 3 -s 100 -c 
rm scheduler_e.py
vi scheduler_e.py
python3 scheduler_e.py -p RR -j 3 -s 100 -c 
rm scheduler_e.py
vi scheduler_e.py
python3 scheduler_e.py -p RR -j 3 -s 100 -c 
python3 scheduler_e.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_e.py -p FIFO -j 3 -s 100 -c
python3 scheduler_e.py -p FIFO -j 3 -s 100 -c -a "0, 2, 4
python3 scheduler_e.py -p FIFO -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_e.py -p SJF -j 3 -s 100 -c
python3 scheduler_e.py -p SJF -j 3 -s 100 -c -a "0, 2, 4" -l "3, 5, 2"
python3 scheduler_e.py -p SJF -j 3 -s 100 -c -a "0, 2, 4"
vi scheduler_g.py
python3 scheduler_g.py -p SJF -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_g.py -p SJ -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_g.py -p J -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler.py -p J -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler.py -p J -j 3 -s 100 -c 
python3 scheduler_g.py
rm scheduler_g.py
vi scheduler_g.py
python3 scheduler.py -p J -j 3 -s 100 -c 
python3 scheduler.py -p J -j 3 -s 100
rm scheduler_g.py
vi scheduler_g.py
python3 scheduler_g.py -p SJF -j 3 -s 100 -c -a "0, 2, 4"
python3 scheduler_g.py -p RR -j 3 -s 100 -c -a "0, 2, 4"
cd ostep-homework
cd cpu-sched
rm scheduler_g.py
vi scheduler_g.py
python3 scheduler_g.py -c -j 3 -s 100 -p SJF -a "0, 2, 4"
cd ostep-homework
cd cpu-sched
python3 scheduler_g.py -c -p FIFO -a "0, 2, 4" -s 100 -j 3
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cd xv6/kernelmemfs image/kernel
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kerenelmemfs
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
vi uthread.c
vi uthread
rm uthread
vi uthread_switch.S
vi Makefile
make clean
make
vi Makefile
make clean
vi Makefile
make clean
vi Makefile
make clean
make
mkdir -p image/efi/boot
xv6/kernelmemfs image/kernel
kernelmemfs image/kernel
cp kernelmemfs image/kernel
cd ..
cp xv6/kernelmemfs image/kernel
cd xv6
./run.sh
make kerenelmemfs
rm uthread.c
vi uthread.c
vi uthread_switch.S
rm uthread_switch.S
vi uthread_switch.S
rm uthread_switch.S
vi uthread_switch.S
cd xv6ekd2/xv6
cd xv6edk2
cd xv6
make kernelmemfs
cd xv6edk2
cd xv6
make kernelmemfs
make clean
make kernelmemfs
make clean
make kernelmemfs
make clean
make kernelmemfs
make clean
make kernelmemfs
cd xv6edk2
cd xv6
vi syscall.h
vi user.h
vi sysproc.c
vi syscall.c
vi usys.S
vi proc.c
vi proc.h
make
make clean
vi trap.c
rm trap.c
vi trap.c
rm uthread.c
vi uthread.c
rm trap.c
vi trap.c
vi uthread.h
vi trap.c
vi uthread.h
vi trap.c
vi uthread.c
vi trap.c
rm uthread.h
vi uthread.h
vi uthread.c
rm uthread.h
vi trap.c
rm uthread.h
vi uthread.c
rm uthread.c
vi uthread.c
make clean
vi uthread.c
vi trap.c
vi uthread.c
vi trap.c
cd xv6edk2
cd xv6
vi proc.c
vi proc.h
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
vi syscall.h
vi user.h
vi sysproc.c
vi syscall.c
vi usys.S
vi proc.h
make
rm uthread.c
vi uthread.c
vi uthread_switching
rm uthread_switching
vi uthread_switch
vi uthread_switch.S
vi proc.c
vi proc.h
vi proc.c
vi proc.h
vi trap.c
rm trap.c
vi trap.c
vi proc.h
vi trap.c
rm trap.c
vi trap.c
rm uthread.c
vi uthread.c
vi trap.c
vi proc.c
vi proc.h
cd xv6edk2
cd xv6
make kernelmemfs
cp xv6/kernelmemfs image/kernel
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kenelmemfs image/kernel
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6
cd xv6edk2\xv6
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs.
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6
xd xv6edk2
cd xv6edk2
cd xv6\
make kernelmemfs
cd ..
cp xv6 kernelmemfs image/kernel
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cp xv6/kernelmemfs image/kernel
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cd xv6/kernelmemfs image/kernel
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
cd ..
kernelmemfs
make kernelmemfs
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
cp xv6 kernelmemfs image/kernel
cp xv6/kernelmemfs image/kernel
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
vi Makefile
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
xv6edk2
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
vi user.h
vi syscall.h
vi user.h
vi syscall.c
vi usys.S
vi userlib
vi ulib.c
vi user.h
vi ulib.c
vi proc.h
vi uthread.c
vi ulib.c
vi uthread.c
make
vi uthread.c
make
vi uthread.c
make
vi sysproc.c
vi usys.S
vi uthread.c
make
vi sysproc.c
vi proc.c
make
vi proc.c
make
make clean
make
vi uthread.c
make clean
make
vi proc.c
make clean
make
vi uthread.c
make clean
make
vi proc.c
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
vi proc.c
proc.h
vi proc.h
vi user.h
vi syscall.h
vi usys.S
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm trap.c
vi trap.c
rm uthread.c
vi uthread.c
make  clean
make
vi trap.c
make
rm trap.c
vi trap.c
make clean
maek
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm trap.c
vi trap.c
make clean
make
rm uthread.c
vi uthread.c
rm trap.c
vi trap.c
make clean
make
rm trap.c
vi trap.c
make clean
make
rm trap.c
vi trap.c
make
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make
make clean
make
rm uthread.c
vi uthread.x
vi uthread.c
make clean
make
rm trap.c
vi trap.c
rm trap.c
vi trap.c
make clean
make
vi trap.c
make clean
make
rm trap.c
vi trap.c
make clean
make
vi trap.c
make clean
make
vi trap.c
make clean
make
vi trap.c
make clean
make
trap.c
vi trap.
vi trap.c
make
vi trap.c
make
:wq
vi trap.c
make
vi trap.c
make
vi trap.c
make
vi trap.c
make
vi trap.c
make
vi trap.c
make
:wq
vi trap.c
mamke
make
vi trap.c
make
vi trap.c
make
vi trap.c
make
rm trap.c
vi trap.c
make
vi trap.c
make
vi trap.c
make
vi trap.c
make
vi Makefile
make
vi Makefile
make
rm trap.c
vi trap.c
vi uthread.c
make
vi trap.c
make
vi Makefile
make
vi Makefile
vi proc.h
vi uthread.c
vi trap.c
make
vi uthread.c
make
vi uthread.c
vi proc.h
vi pro.c
vi proc.c
rm trap.c
vi trap.c
rm uthread.c
vi uthread.c
make
vi trap.c
make
trap.c
vi trap.c
make
vi uthread.c
make
vi uthread.c
make
vi uthread.c
vi uthread.h
vi uthread.c
vi trap.c
make
vi trap.c
make
rm uthread.h
vi uthread.c
rm trap.c
vi trap.c
rm uthread.c
vi uthread.c
make
make clean
make
vi Makefile
make clean
make
vi proc.c
vi trap.c
make clean
make
vi uthread.c
vi trap.c
make
vi trap.c
make clean
make
vi trap.c
make clean
make
vi Makefile
make clean
make
vi Makefile
make clean
make
vi Makefile
make clean
make
vi Makefile
make clean
make
vi Makefile
make clean
make
vi Makefile
make
make clean
make
vi proc.h
vi user.h
vi SYS_uthread_init
vi syscall.h
vi sysproc.c
vi syscall.c
vi usys.S
vi proc.c
vi proc.h
vi proc.c
vi defs.h
vi syscall.c
vi defs.h
vi proc.c
make clean
make
vi user.h
make clean
make
vi user.h
make clean
make
vi Makekernel
vi Makefile
make clean
make
rm trap.c
vi trap.c
make clean
make
vi Makefile
vi syscall.c
make clean
make
vi syscall.h
vi syscall.c
make clean
make
vi syscall.c
vi syscall.h
vi Makefile
vi sysproc.c
make clean
make
vi usys.S
vi user.h
vi syscall.c
vi usys.S
make clean
make
rm trap.c
vi trap.c
make clean
make
rm uthread.c
vi uthread.c
vi trap.c
make clean
make
vi trap.c
rm trap.c
vi trap.c
make clean
make
rm trap.c
vi trap.c
make clean
make
rm trap.c
vi trap.c
rm uthread.c
vi uthread.c
make clean
make
usys.S
vi usys.S
rm trap.c
vi trap.c
rm uthread.c
vi uthread.c
make clean
make
vi uthread_switch.S
vi trap.c
vi uthread.c
make clean
make
vi uthread.c
vi trap.c
make clean
make
vi trap.c
make
vi uthread.h
vi trap.c
make clean
make
vi Makefile
rm trap.c
vi trap.c
rm uthread.c
vi uthread.c
make clean
make
rm trap.c
vi trap.c
make
make clean
make
vi uthread.h
vi uthread.c
rm uthread.h
vi uthread.h
vi uthread.c
vi trap.c
make clean
make
vi uthread.c
vi trap.c
vi uthread.h
make clean
make
vi uthread.h
rm uthread.h
vi uthread.h
make clean
make
vi trap.c
proc.c
vi proc.c
make clean
make
vi proc.c
make clean
make
vi syscall.c
rm uthread.c
vi uthread.c
rm trap.c
vi trap.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
vi trap.c
make clean
make
rm trap.c
vi trap.c
make clean
make
rm uthread.c
vi uthread.c
rm trap.c
vi trap.c
vi uthread.c
rm trap.c
vi trap.c
rm uthread.c
vi uthread.c
make clean
make
rm uthread.c
vi uthread.c
make clean
make
sudo apt-get install git-core
sudo apt-get install update
git --version
sudo git config --global user.name hwajeonge
sudo git config --global user.email wlrmadldi0516@naver.com
sudo git init
git status
sudo git remote add origin https://github.com/hwajeonge/jeong.git
sudo git fetch origin
sudo git add -A
sudo git commit
sudo git push origin +master
sudo git push
git remote add origin https://github.com/hwajeonge/jeong.git
git branch -M main
git push -u origin main
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6c
cd xv6
vi thread_switch.S
vi switch.S
uthread_switch.S
vi uthread_switch.S
make clean
make
vi uthread.c
make clean
make
vi uthread.c
make
make clean
make
vi trap.c
vi uthread.c
make clean
make
vi trap.c
vi uthread.c
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
vi sysproc.c
make clean
make
vi uthread.c
vi trap.c
make clean
make
vi Makefile
vi sysproc.h
vi Makefile
vi syspro.c
vi sysproc.c
vi proc.c
make clean
make
vi proc.c
vi sysproc.c
make clean
make
rm sysproc.c
vi sysproc.c
make clean
make
cd xv6
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kerne
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
vi defs.h
vi proc.c
vi proc.h
vi syscall.c
vi syscall.h
vi sysproc.c
vi user.h
vi usys.S
vi sysproc.c
vi uthread.c
make clean
make
vi uthread.c
rm uthread.c
vi uthread.c
make clean
make
vi uthread.h
sudo apt-get
sudo apt-get update
sudo apt-get upgrade
git --version
git config --global user.name hwajeonge
git config --global user.email wlrmadldi0516@naver.com
git init
git remote add origin https://github.com/hwajeonge/OS_study.git
git add .
git init
sudo git commit -m "히스토리 작성"
git push origin master
git config --list
git status
git pull origin master
cd /home/jeong
cd /home
cd jeong
cd/home
cd /home
cd /jeong
cd jeong
cd /home
cd /jeong
cd ..
cd .git
cd /git
cd /.git
git
mkdir github
cd github
mkdir git
cd git
git clone https://github.com/hwajeonge/OS_study.git
git init
cd ..
git config --list
git init
cd /home/jeong/.git/
cd ..
git config --global user.name hwajeonge
git config --global user.email wlrmadldi0516@naver.com
git init
git remote add origin https://github.com/hwajeonge/OS_study.git
cd /home/jeong/.git/
git clone https://github.com/moonjupark/xv6edk2.git
git add .
git status
git config
git config -l
git push origin master
cd ..
cd /jeong
cd jeong
git push origin master
git add .
git push origin master
git add .
git commit -m
git commit
cd /home/jeong/.git/
git add .
git commit -m 처음
git log
git push
git push origin master
git remote remove origin
git remote add origin https://github.com/hwajeonge/OS_study.git
git remote -v
git push origin master
git push origin main
cd ..
git remote remove origin
git remote add origin https://github.com/hwajeonge/OS_study.git
git fetch origin
ls -l
cd .git
ls
cd ..
add .
git status
sudo git fetch origin
sudo git add -A
sudo git commit
sudo git push origin
sudo git push origin +master
sudo git pull
git push -u origin master
git push -u origin main
git fetch origin
ls -al
git config --list
git branch -m main
git init
git branch -m main
git status
git config
git config --global user.name hwajeonge
git config --global user.email wlrmadldi0516@naver.com
git init
-git branch -m
git branch -m
git branch -m main
git branch
git remote add origin https://github.com/hwajeonge/OS_study.git
git branch
git branch -m main
git remote add origin https://github.com/hwajeonge/OS_study.git
git add .
git remote
git remote remove origin https://github.com/hwajeonge/OS_study.git
git remote remove https://github.com/hwajeonge/OS_study.git
git remote add origin https://github.com/hwajeonge/OS_study.git
git remote add main https://github.com/hwajeonge/OS_study.git
git remote
git remote remove origin
git remote add origin https://github.com/hwajeonge/OS_study.git
git remote -v
cd .git
git clone https://github.com/moonjupark/xv6edk2.git
cd ..
gitgit branch -m main
git branch -m main
git add .
whoami
ls -la .git
sudo chown -R $(whoami) .git
sudo chmod -R u+rwX .git
git add .
m -rf ostep-homework/.git
git add .
git commit
git push
git push -u origin main
git branch
git remote add origin https://github.com/hwajeonge/OS_study.git
git branch
cd .git
git branch
cd ..
git checkout -b main
git push -u origin main
git push origin main
git push origin master
git remote
git remote main
git remote remove main
git remote remove origin
git remote add origin https://github.com/hwajeonge/OS_study.git
git remote
git add .
sudo git commit
git push origin main
git remote -v
git remote add main https://github.com/hwajeonge/OS_study.git
git remote -v
git push origin main
git config --list
git status
git checkout -b main
git push main
git push origin main
rm -rf .git
git --version
git config --list
git init
git config --list
git remote add origin https://github.com/hwajeonge/OS_study.git
git branch -m
git branch -m main
git branch
git init
git branch -m main
git add .
git commit
git push -u origin main
git push -u origin
git push -u origin master
git commit
git add .
rm -rf xv6edk2/.git
git add .
rm -rf xv6edk2/xv6/\.git
rm -rf xv6edk2/xv6/.git
git add .
rm -rf xv6edk2/.got
rm -rf xv6edk2/.git
rm -rf xv6edk2/xv6/.git
ls -l xv6edk2/xv6/.git
cd xv6edk2
cd xv6
whoami
ls -la .git
sudo chown -R $(whoami) .git
sudo chmod -R u+rwX .git
rm -rf xv6edk2/xv6/.git
git add .
git commit -m "initial commit

\
c


git add .
sudo git commit -m "처음"
git push origin master
mkdir -p .git/logs/refs/remotes/origin/master
ls -ld .git .git/logs .git/logs/refs .git/logs/refs/remotes .git/logs/refs/remotes/origin
sudo chown -R $(whoami):$(whoami) .git
sudo chmod -R u+rwX .git
git push origin master
git config credential.helper store
git push origin master
git config --global credential.helper store
got config --global --list
git config --global --list
git push origin master
git branch
git checkout -b main
git branch
git add .
git commit
git add .
git commit
git push origin main
git add .
git commit
git push origin main
git checkout main
git pull origin main
git add .
git commit
git push origin main
git checkout master
git checkout -b main
git push -u origin main
git checkout master
git branch
git config --global --list
git push origin master
python3 scheduler.py
cd ostep-homework
python3 scheduler.py -j 7 -p FIFO -l 6,2,13,22,12,5,2 -c
python3 --version
cd cpu-sched
python3 scheduler.py -j 7 -p FIFO -l 6,2,13,22,12,5,2 -c\
python3 scheduler.py -j 7 -p FIFO -l 6,2,13,22,12,5,2 -c
python3 scheduler.py -j 7 -p FIFO -l 6,2,13,22,12,5,2 -a 0,3,3,4,17,32,46 -c
python3 scheduler.py -j 7 -p FIFO -l 6,2,13,22,12,5,2 -a 0,3,3,4,17,32,46 -c -s 100
python3 scheduler.py -j 7 -p RR -q 2 -l 6,2,13,22,12,5,2 -c
python3 scheduler.py -j 7 -p SJF -l 6,2,13,22,12,5,2 -c
python3 scheduler.py -j 7 -p SJF -l 6,2,13,22,12,5,2 -a 0,3,3,4,17,32,46 -c
cd ostep-homework
cd vm-beyondphys-policy
vi paging-policy3
python3 paging_policy.py --policy=FIFO --addresses=0,4,1,4,2,4,3 --cachesize=3 --compute
python3 paging_policy3.py --policy=FIFO --addresses=0,4,1,4,2,4,3 --cachesize=3 --compute
python3 paging-policy3.py --policy=FIFO --addresses=0,4,1,4,2,4,3 --cachesize=3 --compute
rm paging-policy3
vi paging-policy3.py
python3 paging-policy3.py --policy=FIFO --addresses=0,4,1,4,2,4,3 --cachesize=3 --compute
python3 paging-policy.py --policy=FIFO --addresses=0,4,1,4,2,4,3 --cachesize=3 --compute
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel

cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image kernel
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
sudo git add -A
sudo git commit -m "printpt systemcall"
sudo git push origin +master
git rebase -i HEAD~1
git push origin +master
git rebase --continue
git rm --cached .git-credentials
echo ".git-credentials" >> .gitignore
git add .gitignore
git commit -m "Add .git-credentials to .gitignore"
git push origin master
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch .git-credentials' --prune-empty --tag-name-filter cat -- --all
git add -A
git commint 
sudo git commit
git add -A
git commit
sudo git push origin +master
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
vi proc.c
vi sysproc.c
vi defs.h
vi proc.c
vi sysproc.c
vi defs.h
vi proc.h
vi syscall.h
vi usys.S
vi user.h
vi usys.S
vi syscall.c
vi recurse.c
vi Makefile
make clean
make
vi proc.c
vi defs.h
make clean
make
vi proc.h
vi proc.c
vi proc.h
make clean
make
vi sysproc.c
vi proc.c
make clean
make
vi sysproc.c
vi proc.c
make clean
make
vi recurse.c
make clean
make
cd xv6edk2
cd xv6
rm exec.c
vi exec.c
make clear
make
make clear
make
git add -A
sudo git add exec.c
sudo git status
sudo git commit "스택 재정렬"
sudo git commit -m "스택 재정렬"
sudo git push origin master
cd xv6edk2
cd xv6
rm exec.c
vi exec.c
rm trap.c
vi trap.c
rm vm.c
vi vm.c
rm vm.c
vi vm.c
rm trap.c
vi trap.c
rm exec.c
vi exec.c
make clear
make clean
make
vi sysproc.c
vi proc.c
vi recurse.c
vi vm.c
vi proc.c
vi sysproc.c
vi proc.c
cd xv6edk2
cd xv6
traps.h
vi traps.h
make clean
make
vi proc.c
vi syscall.c
vi user.h
make clean
make
vi proc.h
make clean
make
vi defs.h
make
vi Makefile
make
vi Makefile
make clean
make
ls -l vm.o
nm vm.o | grep walkpgdir
nm proc.o | grep walkpgdir
vi Makefile
nm kernel | grep walkpgdir
make clean
make
nm vm.o | grep walkpgdir
make clean
make
cd xv6edk2
cd xv6
make clean
make
make clean
make
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kenrelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make
make clear
make
cd xv6edk2
cd xv6
make kernelmemfs
make
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
qemu-system-x86_64 -serial mon:stdio -kernel kernel-qemu
make clean
make
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
cd xv6edk2
cd xv6
make kernelmemfs
make clean
make
make clean
make
make kernelmemfs
cd ..
cp xv6/kernelmemfs image/kernel
./run.sh
