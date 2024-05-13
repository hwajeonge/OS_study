#ifndef UTHREAD_H  // Include guard 시작
#define UTHREAD_H

#include "types.h"  // 타입 정의를 포함하는 경우

#define STACK_SIZE  8192
#define MAX_THREAD  4

// Possible states of a thread
#define FREE        0x0
#define RUNNING     0x1
#define RUNNABLE    0x2

// 스레드 구조체 정의
typedef struct thread {
    int sp;                // 스택 포인터
    char stack[STACK_SIZE]; // 스레드의 스택
    int state;             // 스레드의 상태 (FREE, RUNNING, RUNNABLE)
} thread_t, *thread_p;

// 공개 함수 및 변수 정의
extern thread_t all_thread[MAX_THREAD];
extern thread_p current_thread;
extern thread_p next_thread;

extern void thread_schedule(void);  // 외부에서 호출 가능하도록 extern 선언
extern void thread_switch(void);

void thread_init(void);
void thread_create(void (*func)(void));
void thread_yield(void);

#endif // UTHREAD_H  // Include guard 종료

