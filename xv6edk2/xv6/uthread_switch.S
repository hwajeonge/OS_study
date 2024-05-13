	.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
   /* 현재 스레드의 레지스터 상태를 현재 스레드의 스택에 저장 */
   pushal

   /* 현재 스레드의 스택 포인터를 저장 */
   movl current_thread, %eax
   movl %esp, (%eax)

   /* 다음 스레드의 스택으로 전환 */
   movl next_thread, %eax
   movl (%eax), %esp

   /* 현재 스레드를 다음 스레드로 설정 */
   movl %eax, current_thread

   /* 다음 스레드의 레지스터 상태 복원 */
   popal

   /* 다음 스레드를 0으로 설정  */
   movl $0, next_thread

   ret    /* return to ra */

