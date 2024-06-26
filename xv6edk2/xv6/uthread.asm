
_uthread:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_init>:

static void thread_schedule(void);

void
thread_init(void)
{
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 08             	sub    $0x8,%esp
    // main() is thread 0, which will make the first invocation to
    // thread_schedule().  it needs a stack so that the first thread_switch() can
    // save thread 0's state.  thread_schedule() won't run the main thread ever
    // again, because its state is set to RUNNING, and thread_schedule() selects
    // a RUNNABLE thread.
    current_thread = &all_thread[0];
   a:	c7 05 ec 8d 00 00 c0 	movl   $0xdc0,0x8dec
  11:	0d 00 00 
    current_thread->state = RUNNING;
  14:	a1 ec 8d 00 00       	mov    0x8dec,%eax
  19:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  20:	00 00 00 

    // 사용자 수준 스케줄러 초기화
    uthread_init(thread_schedule);
  23:	83 ec 0c             	sub    $0xc,%esp
  26:	68 36 00 00 00       	push   $0x36
  2b:	e8 70 05 00 00       	call   5a0 <uthread_init>
  30:	83 c4 10             	add    $0x10,%esp
}
  33:	90                   	nop
  34:	c9                   	leave  
  35:	c3                   	ret    

00000036 <thread_schedule>:

static void
thread_schedule(void)
{
  36:	f3 0f 1e fb          	endbr32 
  3a:	55                   	push   %ebp
  3b:	89 e5                	mov    %esp,%ebp
  3d:	83 ec 18             	sub    $0x18,%esp
    thread_p t;

    /* Find another runnable thread. */
    next_thread = 0;
  40:	c7 05 f0 8d 00 00 00 	movl   $0x0,0x8df0
  47:	00 00 00 
    for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  4a:	c7 45 f4 c0 0d 00 00 	movl   $0xdc0,-0xc(%ebp)
  51:	eb 29                	jmp    7c <thread_schedule+0x46>
        if (t->state == RUNNABLE && t != current_thread) {
  53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  56:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  5c:	83 f8 02             	cmp    $0x2,%eax
  5f:	75 14                	jne    75 <thread_schedule+0x3f>
  61:	a1 ec 8d 00 00       	mov    0x8dec,%eax
  66:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  69:	74 0a                	je     75 <thread_schedule+0x3f>
            next_thread = t;
  6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6e:	a3 f0 8d 00 00       	mov    %eax,0x8df0
            break;
  73:	eb 11                	jmp    86 <thread_schedule+0x50>
    for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  75:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  7c:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
  81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  84:	72 cd                	jb     53 <thread_schedule+0x1d>
        }
    }

    if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  86:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
  8b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  8e:	72 1a                	jb     aa <thread_schedule+0x74>
  90:	a1 ec 8d 00 00       	mov    0x8dec,%eax
  95:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  9b:	83 f8 02             	cmp    $0x2,%eax
  9e:	75 0a                	jne    aa <thread_schedule+0x74>
        /* The current thread is the only runnable thread; run it. */
        next_thread = current_thread;
  a0:	a1 ec 8d 00 00       	mov    0x8dec,%eax
  a5:	a3 f0 8d 00 00       	mov    %eax,0x8df0
    }

    if (next_thread == 0) {
  aa:	a1 f0 8d 00 00       	mov    0x8df0,%eax
  af:	85 c0                	test   %eax,%eax
  b1:	75 17                	jne    ca <thread_schedule+0x94>
        printf(2, "thread_schedule: no runnable threads\n");
  b3:	83 ec 08             	sub    $0x8,%esp
  b6:	68 54 0a 00 00       	push   $0xa54
  bb:	6a 02                	push   $0x2
  bd:	e8 ca 05 00 00       	call   68c <printf>
  c2:	83 c4 10             	add    $0x10,%esp
        exit();
  c5:	e8 26 04 00 00       	call   4f0 <exit>
    }

    if (current_thread != next_thread) {         /* switch threads?  */
  ca:	8b 15 ec 8d 00 00    	mov    0x8dec,%edx
  d0:	a1 f0 8d 00 00       	mov    0x8df0,%eax
  d5:	39 c2                	cmp    %eax,%edx
  d7:	74 16                	je     ef <thread_schedule+0xb9>
        next_thread->state = RUNNING;
  d9:	a1 f0 8d 00 00       	mov    0x8df0,%eax
  de:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  e5:	00 00 00 
        thread_switch();
  e8:	e8 68 01 00 00       	call   255 <thread_switch>
    }
    else
        next_thread = 0;
}
  ed:	eb 0a                	jmp    f9 <thread_schedule+0xc3>
        next_thread = 0;
  ef:	c7 05 f0 8d 00 00 00 	movl   $0x0,0x8df0
  f6:	00 00 00 
}
  f9:	90                   	nop
  fa:	c9                   	leave  
  fb:	c3                   	ret    

000000fc <thread_create>:

void
thread_create(void (*func)())
{
  fc:	f3 0f 1e fb          	endbr32 
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	83 ec 10             	sub    $0x10,%esp
    thread_p t;

    for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 106:	c7 45 fc c0 0d 00 00 	movl   $0xdc0,-0x4(%ebp)
 10d:	eb 14                	jmp    123 <thread_create+0x27>
        if (t->state == FREE) break;
 10f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 112:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 118:	85 c0                	test   %eax,%eax
 11a:	74 13                	je     12f <thread_create+0x33>
    for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 11c:	81 45 fc 08 20 00 00 	addl   $0x2008,-0x4(%ebp)
 123:	b8 e0 8d 00 00       	mov    $0x8de0,%eax
 128:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 12b:	72 e2                	jb     10f <thread_create+0x13>
 12d:	eb 01                	jmp    130 <thread_create+0x34>
        if (t->state == FREE) break;
 12f:	90                   	nop
    }
    t->sp = (int)(t->stack + STACK_SIZE);   // set sp to the top of the stack
 130:	8b 45 fc             	mov    -0x4(%ebp),%eax
 133:	83 c0 04             	add    $0x4,%eax
 136:	05 00 20 00 00       	add    $0x2000,%eax
 13b:	89 c2                	mov    %eax,%edx
 13d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 140:	89 10                	mov    %edx,(%eax)
    t->sp -= 4;                              // space for return address
 142:	8b 45 fc             	mov    -0x4(%ebp),%eax
 145:	8b 00                	mov    (%eax),%eax
 147:	8d 50 fc             	lea    -0x4(%eax),%edx
 14a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 14d:	89 10                	mov    %edx,(%eax)
    *(int*)(t->sp) = (int)func;           // push return address on stack
 14f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 152:	8b 00                	mov    (%eax),%eax
 154:	89 c2                	mov    %eax,%edx
 156:	8b 45 08             	mov    0x8(%ebp),%eax
 159:	89 02                	mov    %eax,(%edx)
    t->sp -= 32;                             // space for registers that thread_switch expects
 15b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 15e:	8b 00                	mov    (%eax),%eax
 160:	8d 50 e0             	lea    -0x20(%eax),%edx
 163:	8b 45 fc             	mov    -0x4(%ebp),%eax
 166:	89 10                	mov    %edx,(%eax)
    t->state = RUNNABLE;
 168:	8b 45 fc             	mov    -0x4(%ebp),%eax
 16b:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 172:	00 00 00 
}
 175:	90                   	nop
 176:	c9                   	leave  
 177:	c3                   	ret    

00000178 <thread_yield>:

void
thread_yield(void)
{
 178:	f3 0f 1e fb          	endbr32 
 17c:	55                   	push   %ebp
 17d:	89 e5                	mov    %esp,%ebp
 17f:	83 ec 08             	sub    $0x8,%esp
    current_thread->state = RUNNABLE;
 182:	a1 ec 8d 00 00       	mov    0x8dec,%eax
 187:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 18e:	00 00 00 
    thread_schedule();
 191:	e8 a0 fe ff ff       	call   36 <thread_schedule>
}
 196:	90                   	nop
 197:	c9                   	leave  
 198:	c3                   	ret    

00000199 <mythread>:

static void
mythread(void)
{
 199:	f3 0f 1e fb          	endbr32 
 19d:	55                   	push   %ebp
 19e:	89 e5                	mov    %esp,%ebp
 1a0:	83 ec 18             	sub    $0x18,%esp
    int i;
    printf(1, "my thread running\n");
 1a3:	83 ec 08             	sub    $0x8,%esp
 1a6:	68 7a 0a 00 00       	push   $0xa7a
 1ab:	6a 01                	push   $0x1
 1ad:	e8 da 04 00 00       	call   68c <printf>
 1b2:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < 100; i++) {
 1b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1bc:	eb 1c                	jmp    1da <mythread+0x41>
        printf(1, "my thread 0x%x\n", (int)current_thread);
 1be:	a1 ec 8d 00 00       	mov    0x8dec,%eax
 1c3:	83 ec 04             	sub    $0x4,%esp
 1c6:	50                   	push   %eax
 1c7:	68 8d 0a 00 00       	push   $0xa8d
 1cc:	6a 01                	push   $0x1
 1ce:	e8 b9 04 00 00       	call   68c <printf>
 1d3:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < 100; i++) {
 1d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1da:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 1de:	7e de                	jle    1be <mythread+0x25>
        // thread_yield(); // 자동 양보 방지
    }
    printf(1, "my thread: exit\n");
 1e0:	83 ec 08             	sub    $0x8,%esp
 1e3:	68 9d 0a 00 00       	push   $0xa9d
 1e8:	6a 01                	push   $0x1
 1ea:	e8 9d 04 00 00       	call   68c <printf>
 1ef:	83 c4 10             	add    $0x10,%esp
    current_thread->state = FREE;
 1f2:	a1 ec 8d 00 00       	mov    0x8dec,%eax
 1f7:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 1fe:	00 00 00 
    thread_schedule();
 201:	e8 30 fe ff ff       	call   36 <thread_schedule>
}
 206:	90                   	nop
 207:	c9                   	leave  
 208:	c3                   	ret    

00000209 <main>:


int
main(int argc, char* argv[])
{
 209:	f3 0f 1e fb          	endbr32 
 20d:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 211:	83 e4 f0             	and    $0xfffffff0,%esp
 214:	ff 71 fc             	pushl  -0x4(%ecx)
 217:	55                   	push   %ebp
 218:	89 e5                	mov    %esp,%ebp
 21a:	51                   	push   %ecx
 21b:	83 ec 04             	sub    $0x4,%esp
    thread_init();
 21e:	e8 dd fd ff ff       	call   0 <thread_init>
    thread_create(mythread);
 223:	83 ec 0c             	sub    $0xc,%esp
 226:	68 99 01 00 00       	push   $0x199
 22b:	e8 cc fe ff ff       	call   fc <thread_create>
 230:	83 c4 10             	add    $0x10,%esp
    thread_create(mythread);
 233:	83 ec 0c             	sub    $0xc,%esp
 236:	68 99 01 00 00       	push   $0x199
 23b:	e8 bc fe ff ff       	call   fc <thread_create>
 240:	83 c4 10             	add    $0x10,%esp
    thread_schedule();
 243:	e8 ee fd ff ff       	call   36 <thread_schedule>
    return 0;
 248:	b8 00 00 00 00       	mov    $0x0,%eax
}
 24d:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 250:	c9                   	leave  
 251:	8d 61 fc             	lea    -0x4(%ecx),%esp
 254:	c3                   	ret    

00000255 <thread_switch>:

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
   /* 현재 스레드의 레지스터 상태를 현재 스레드의 스택에 저장 */
   pushal
 255:	60                   	pusha  

   /* 현재 스레드의 스택 포인터를 저장 */
   movl current_thread, %eax
 256:	a1 ec 8d 00 00       	mov    0x8dec,%eax
   movl %esp, (%eax)
 25b:	89 20                	mov    %esp,(%eax)

   /* 다음 스레드의 스택으로 전환 */
   movl next_thread, %eax
 25d:	a1 f0 8d 00 00       	mov    0x8df0,%eax
   movl (%eax), %esp
 262:	8b 20                	mov    (%eax),%esp

   /* 현재 스레드를 다음 스레드로 설정 */
   movl %eax, current_thread
 264:	a3 ec 8d 00 00       	mov    %eax,0x8dec

   /* 다음 스레드의 레지스터 상태 복원 */
   popal
 269:	61                   	popa   

   /* 다음 스레드를 0으로 설정  */
   movl $0, next_thread
 26a:	c7 05 f0 8d 00 00 00 	movl   $0x0,0x8df0
 271:	00 00 00 

   ret    /* return to ra */
 274:	c3                   	ret    

00000275 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
 278:	57                   	push   %edi
 279:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 27a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 27d:	8b 55 10             	mov    0x10(%ebp),%edx
 280:	8b 45 0c             	mov    0xc(%ebp),%eax
 283:	89 cb                	mov    %ecx,%ebx
 285:	89 df                	mov    %ebx,%edi
 287:	89 d1                	mov    %edx,%ecx
 289:	fc                   	cld    
 28a:	f3 aa                	rep stos %al,%es:(%edi)
 28c:	89 ca                	mov    %ecx,%edx
 28e:	89 fb                	mov    %edi,%ebx
 290:	89 5d 08             	mov    %ebx,0x8(%ebp)
 293:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 296:	90                   	nop
 297:	5b                   	pop    %ebx
 298:	5f                   	pop    %edi
 299:	5d                   	pop    %ebp
 29a:	c3                   	ret    

0000029b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 29b:	f3 0f 1e fb          	endbr32 
 29f:	55                   	push   %ebp
 2a0:	89 e5                	mov    %esp,%ebp
 2a2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2a5:	8b 45 08             	mov    0x8(%ebp),%eax
 2a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2ab:	90                   	nop
 2ac:	8b 55 0c             	mov    0xc(%ebp),%edx
 2af:	8d 42 01             	lea    0x1(%edx),%eax
 2b2:	89 45 0c             	mov    %eax,0xc(%ebp)
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	8d 48 01             	lea    0x1(%eax),%ecx
 2bb:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2be:	0f b6 12             	movzbl (%edx),%edx
 2c1:	88 10                	mov    %dl,(%eax)
 2c3:	0f b6 00             	movzbl (%eax),%eax
 2c6:	84 c0                	test   %al,%al
 2c8:	75 e2                	jne    2ac <strcpy+0x11>
    ;
  return os;
 2ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2cd:	c9                   	leave  
 2ce:	c3                   	ret    

000002cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2cf:	f3 0f 1e fb          	endbr32 
 2d3:	55                   	push   %ebp
 2d4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2d6:	eb 08                	jmp    2e0 <strcmp+0x11>
    p++, q++;
 2d8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2dc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
 2e3:	0f b6 00             	movzbl (%eax),%eax
 2e6:	84 c0                	test   %al,%al
 2e8:	74 10                	je     2fa <strcmp+0x2b>
 2ea:	8b 45 08             	mov    0x8(%ebp),%eax
 2ed:	0f b6 10             	movzbl (%eax),%edx
 2f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f3:	0f b6 00             	movzbl (%eax),%eax
 2f6:	38 c2                	cmp    %al,%dl
 2f8:	74 de                	je     2d8 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 2fa:	8b 45 08             	mov    0x8(%ebp),%eax
 2fd:	0f b6 00             	movzbl (%eax),%eax
 300:	0f b6 d0             	movzbl %al,%edx
 303:	8b 45 0c             	mov    0xc(%ebp),%eax
 306:	0f b6 00             	movzbl (%eax),%eax
 309:	0f b6 c0             	movzbl %al,%eax
 30c:	29 c2                	sub    %eax,%edx
 30e:	89 d0                	mov    %edx,%eax
}
 310:	5d                   	pop    %ebp
 311:	c3                   	ret    

00000312 <strlen>:

uint
strlen(char *s)
{
 312:	f3 0f 1e fb          	endbr32 
 316:	55                   	push   %ebp
 317:	89 e5                	mov    %esp,%ebp
 319:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 31c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 323:	eb 04                	jmp    329 <strlen+0x17>
 325:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 329:	8b 55 fc             	mov    -0x4(%ebp),%edx
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
 32f:	01 d0                	add    %edx,%eax
 331:	0f b6 00             	movzbl (%eax),%eax
 334:	84 c0                	test   %al,%al
 336:	75 ed                	jne    325 <strlen+0x13>
    ;
  return n;
 338:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33b:	c9                   	leave  
 33c:	c3                   	ret    

0000033d <memset>:

void*
memset(void *dst, int c, uint n)
{
 33d:	f3 0f 1e fb          	endbr32 
 341:	55                   	push   %ebp
 342:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 344:	8b 45 10             	mov    0x10(%ebp),%eax
 347:	50                   	push   %eax
 348:	ff 75 0c             	pushl  0xc(%ebp)
 34b:	ff 75 08             	pushl  0x8(%ebp)
 34e:	e8 22 ff ff ff       	call   275 <stosb>
 353:	83 c4 0c             	add    $0xc,%esp
  return dst;
 356:	8b 45 08             	mov    0x8(%ebp),%eax
}
 359:	c9                   	leave  
 35a:	c3                   	ret    

0000035b <strchr>:

char*
strchr(const char *s, char c)
{
 35b:	f3 0f 1e fb          	endbr32 
 35f:	55                   	push   %ebp
 360:	89 e5                	mov    %esp,%ebp
 362:	83 ec 04             	sub    $0x4,%esp
 365:	8b 45 0c             	mov    0xc(%ebp),%eax
 368:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 36b:	eb 14                	jmp    381 <strchr+0x26>
    if(*s == c)
 36d:	8b 45 08             	mov    0x8(%ebp),%eax
 370:	0f b6 00             	movzbl (%eax),%eax
 373:	38 45 fc             	cmp    %al,-0x4(%ebp)
 376:	75 05                	jne    37d <strchr+0x22>
      return (char*)s;
 378:	8b 45 08             	mov    0x8(%ebp),%eax
 37b:	eb 13                	jmp    390 <strchr+0x35>
  for(; *s; s++)
 37d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 381:	8b 45 08             	mov    0x8(%ebp),%eax
 384:	0f b6 00             	movzbl (%eax),%eax
 387:	84 c0                	test   %al,%al
 389:	75 e2                	jne    36d <strchr+0x12>
  return 0;
 38b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 390:	c9                   	leave  
 391:	c3                   	ret    

00000392 <gets>:

char*
gets(char *buf, int max)
{
 392:	f3 0f 1e fb          	endbr32 
 396:	55                   	push   %ebp
 397:	89 e5                	mov    %esp,%ebp
 399:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 39c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3a3:	eb 42                	jmp    3e7 <gets+0x55>
    cc = read(0, &c, 1);
 3a5:	83 ec 04             	sub    $0x4,%esp
 3a8:	6a 01                	push   $0x1
 3aa:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3ad:	50                   	push   %eax
 3ae:	6a 00                	push   $0x0
 3b0:	e8 53 01 00 00       	call   508 <read>
 3b5:	83 c4 10             	add    $0x10,%esp
 3b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3bf:	7e 33                	jle    3f4 <gets+0x62>
      break;
    buf[i++] = c;
 3c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c4:	8d 50 01             	lea    0x1(%eax),%edx
 3c7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3ca:	89 c2                	mov    %eax,%edx
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
 3cf:	01 c2                	add    %eax,%edx
 3d1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3d5:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3d7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3db:	3c 0a                	cmp    $0xa,%al
 3dd:	74 16                	je     3f5 <gets+0x63>
 3df:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3e3:	3c 0d                	cmp    $0xd,%al
 3e5:	74 0e                	je     3f5 <gets+0x63>
  for(i=0; i+1 < max; ){
 3e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ea:	83 c0 01             	add    $0x1,%eax
 3ed:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3f0:	7f b3                	jg     3a5 <gets+0x13>
 3f2:	eb 01                	jmp    3f5 <gets+0x63>
      break;
 3f4:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3f8:	8b 45 08             	mov    0x8(%ebp),%eax
 3fb:	01 d0                	add    %edx,%eax
 3fd:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 400:	8b 45 08             	mov    0x8(%ebp),%eax
}
 403:	c9                   	leave  
 404:	c3                   	ret    

00000405 <stat>:

int
stat(char *n, struct stat *st)
{
 405:	f3 0f 1e fb          	endbr32 
 409:	55                   	push   %ebp
 40a:	89 e5                	mov    %esp,%ebp
 40c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 40f:	83 ec 08             	sub    $0x8,%esp
 412:	6a 00                	push   $0x0
 414:	ff 75 08             	pushl  0x8(%ebp)
 417:	e8 14 01 00 00       	call   530 <open>
 41c:	83 c4 10             	add    $0x10,%esp
 41f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 422:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 426:	79 07                	jns    42f <stat+0x2a>
    return -1;
 428:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 42d:	eb 25                	jmp    454 <stat+0x4f>
  r = fstat(fd, st);
 42f:	83 ec 08             	sub    $0x8,%esp
 432:	ff 75 0c             	pushl  0xc(%ebp)
 435:	ff 75 f4             	pushl  -0xc(%ebp)
 438:	e8 0b 01 00 00       	call   548 <fstat>
 43d:	83 c4 10             	add    $0x10,%esp
 440:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 443:	83 ec 0c             	sub    $0xc,%esp
 446:	ff 75 f4             	pushl  -0xc(%ebp)
 449:	e8 ca 00 00 00       	call   518 <close>
 44e:	83 c4 10             	add    $0x10,%esp
  return r;
 451:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 454:	c9                   	leave  
 455:	c3                   	ret    

00000456 <atoi>:

int
atoi(const char *s)
{
 456:	f3 0f 1e fb          	endbr32 
 45a:	55                   	push   %ebp
 45b:	89 e5                	mov    %esp,%ebp
 45d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 460:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 467:	eb 25                	jmp    48e <atoi+0x38>
    n = n*10 + *s++ - '0';
 469:	8b 55 fc             	mov    -0x4(%ebp),%edx
 46c:	89 d0                	mov    %edx,%eax
 46e:	c1 e0 02             	shl    $0x2,%eax
 471:	01 d0                	add    %edx,%eax
 473:	01 c0                	add    %eax,%eax
 475:	89 c1                	mov    %eax,%ecx
 477:	8b 45 08             	mov    0x8(%ebp),%eax
 47a:	8d 50 01             	lea    0x1(%eax),%edx
 47d:	89 55 08             	mov    %edx,0x8(%ebp)
 480:	0f b6 00             	movzbl (%eax),%eax
 483:	0f be c0             	movsbl %al,%eax
 486:	01 c8                	add    %ecx,%eax
 488:	83 e8 30             	sub    $0x30,%eax
 48b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 48e:	8b 45 08             	mov    0x8(%ebp),%eax
 491:	0f b6 00             	movzbl (%eax),%eax
 494:	3c 2f                	cmp    $0x2f,%al
 496:	7e 0a                	jle    4a2 <atoi+0x4c>
 498:	8b 45 08             	mov    0x8(%ebp),%eax
 49b:	0f b6 00             	movzbl (%eax),%eax
 49e:	3c 39                	cmp    $0x39,%al
 4a0:	7e c7                	jle    469 <atoi+0x13>
  return n;
 4a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4a5:	c9                   	leave  
 4a6:	c3                   	ret    

000004a7 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4a7:	f3 0f 1e fb          	endbr32 
 4ab:	55                   	push   %ebp
 4ac:	89 e5                	mov    %esp,%ebp
 4ae:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 4b1:	8b 45 08             	mov    0x8(%ebp),%eax
 4b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4bd:	eb 17                	jmp    4d6 <memmove+0x2f>
    *dst++ = *src++;
 4bf:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4c2:	8d 42 01             	lea    0x1(%edx),%eax
 4c5:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4cb:	8d 48 01             	lea    0x1(%eax),%ecx
 4ce:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4d1:	0f b6 12             	movzbl (%edx),%edx
 4d4:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4d6:	8b 45 10             	mov    0x10(%ebp),%eax
 4d9:	8d 50 ff             	lea    -0x1(%eax),%edx
 4dc:	89 55 10             	mov    %edx,0x10(%ebp)
 4df:	85 c0                	test   %eax,%eax
 4e1:	7f dc                	jg     4bf <memmove+0x18>
  return vdst;
 4e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4e6:	c9                   	leave  
 4e7:	c3                   	ret    

000004e8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4e8:	b8 01 00 00 00       	mov    $0x1,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <exit>:
SYSCALL(exit)
 4f0:	b8 02 00 00 00       	mov    $0x2,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <wait>:
SYSCALL(wait)
 4f8:	b8 03 00 00 00       	mov    $0x3,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <pipe>:
SYSCALL(pipe)
 500:	b8 04 00 00 00       	mov    $0x4,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <read>:
SYSCALL(read)
 508:	b8 05 00 00 00       	mov    $0x5,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <write>:
SYSCALL(write)
 510:	b8 10 00 00 00       	mov    $0x10,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <close>:
SYSCALL(close)
 518:	b8 15 00 00 00       	mov    $0x15,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <kill>:
SYSCALL(kill)
 520:	b8 06 00 00 00       	mov    $0x6,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <exec>:
SYSCALL(exec)
 528:	b8 07 00 00 00       	mov    $0x7,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <open>:
SYSCALL(open)
 530:	b8 0f 00 00 00       	mov    $0xf,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <mknod>:
SYSCALL(mknod)
 538:	b8 11 00 00 00       	mov    $0x11,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <unlink>:
SYSCALL(unlink)
 540:	b8 12 00 00 00       	mov    $0x12,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <fstat>:
SYSCALL(fstat)
 548:	b8 08 00 00 00       	mov    $0x8,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <link>:
SYSCALL(link)
 550:	b8 13 00 00 00       	mov    $0x13,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <mkdir>:
SYSCALL(mkdir)
 558:	b8 14 00 00 00       	mov    $0x14,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <chdir>:
SYSCALL(chdir)
 560:	b8 09 00 00 00       	mov    $0x9,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <dup>:
SYSCALL(dup)
 568:	b8 0a 00 00 00       	mov    $0xa,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <getpid>:
SYSCALL(getpid)
 570:	b8 0b 00 00 00       	mov    $0xb,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <sbrk>:
SYSCALL(sbrk)
 578:	b8 0c 00 00 00       	mov    $0xc,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <sleep>:
SYSCALL(sleep)
 580:	b8 0d 00 00 00       	mov    $0xd,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <uptime>:
SYSCALL(uptime)
 588:	b8 0e 00 00 00       	mov    $0xe,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <exit2>:
SYSCALL(exit2)
 590:	b8 16 00 00 00       	mov    $0x16,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <wait2>:
SYSCALL(wait2)
 598:	b8 17 00 00 00       	mov    $0x17,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <uthread_init>:
SYSCALL(uthread_init)
 5a0:	b8 18 00 00 00       	mov    $0x18,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <printpt>:
SYSCALL(printpt)
 5a8:	b8 19 00 00 00       	mov    $0x19,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5b0:	f3 0f 1e fb          	endbr32 
 5b4:	55                   	push   %ebp
 5b5:	89 e5                	mov    %esp,%ebp
 5b7:	83 ec 18             	sub    $0x18,%esp
 5ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 5bd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5c0:	83 ec 04             	sub    $0x4,%esp
 5c3:	6a 01                	push   $0x1
 5c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5c8:	50                   	push   %eax
 5c9:	ff 75 08             	pushl  0x8(%ebp)
 5cc:	e8 3f ff ff ff       	call   510 <write>
 5d1:	83 c4 10             	add    $0x10,%esp
}
 5d4:	90                   	nop
 5d5:	c9                   	leave  
 5d6:	c3                   	ret    

000005d7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5d7:	f3 0f 1e fb          	endbr32 
 5db:	55                   	push   %ebp
 5dc:	89 e5                	mov    %esp,%ebp
 5de:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5e8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 5ec:	74 17                	je     605 <printint+0x2e>
 5ee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5f2:	79 11                	jns    605 <printint+0x2e>
    neg = 1;
 5f4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 5fe:	f7 d8                	neg    %eax
 600:	89 45 ec             	mov    %eax,-0x14(%ebp)
 603:	eb 06                	jmp    60b <printint+0x34>
  } else {
    x = xx;
 605:	8b 45 0c             	mov    0xc(%ebp),%eax
 608:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 60b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 612:	8b 4d 10             	mov    0x10(%ebp),%ecx
 615:	8b 45 ec             	mov    -0x14(%ebp),%eax
 618:	ba 00 00 00 00       	mov    $0x0,%edx
 61d:	f7 f1                	div    %ecx
 61f:	89 d1                	mov    %edx,%ecx
 621:	8b 45 f4             	mov    -0xc(%ebp),%eax
 624:	8d 50 01             	lea    0x1(%eax),%edx
 627:	89 55 f4             	mov    %edx,-0xc(%ebp)
 62a:	0f b6 91 a4 0d 00 00 	movzbl 0xda4(%ecx),%edx
 631:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 635:	8b 4d 10             	mov    0x10(%ebp),%ecx
 638:	8b 45 ec             	mov    -0x14(%ebp),%eax
 63b:	ba 00 00 00 00       	mov    $0x0,%edx
 640:	f7 f1                	div    %ecx
 642:	89 45 ec             	mov    %eax,-0x14(%ebp)
 645:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 649:	75 c7                	jne    612 <printint+0x3b>
  if(neg)
 64b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 64f:	74 2d                	je     67e <printint+0xa7>
    buf[i++] = '-';
 651:	8b 45 f4             	mov    -0xc(%ebp),%eax
 654:	8d 50 01             	lea    0x1(%eax),%edx
 657:	89 55 f4             	mov    %edx,-0xc(%ebp)
 65a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 65f:	eb 1d                	jmp    67e <printint+0xa7>
    putc(fd, buf[i]);
 661:	8d 55 dc             	lea    -0x24(%ebp),%edx
 664:	8b 45 f4             	mov    -0xc(%ebp),%eax
 667:	01 d0                	add    %edx,%eax
 669:	0f b6 00             	movzbl (%eax),%eax
 66c:	0f be c0             	movsbl %al,%eax
 66f:	83 ec 08             	sub    $0x8,%esp
 672:	50                   	push   %eax
 673:	ff 75 08             	pushl  0x8(%ebp)
 676:	e8 35 ff ff ff       	call   5b0 <putc>
 67b:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 67e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 682:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 686:	79 d9                	jns    661 <printint+0x8a>
}
 688:	90                   	nop
 689:	90                   	nop
 68a:	c9                   	leave  
 68b:	c3                   	ret    

0000068c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 68c:	f3 0f 1e fb          	endbr32 
 690:	55                   	push   %ebp
 691:	89 e5                	mov    %esp,%ebp
 693:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 696:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 69d:	8d 45 0c             	lea    0xc(%ebp),%eax
 6a0:	83 c0 04             	add    $0x4,%eax
 6a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6ad:	e9 59 01 00 00       	jmp    80b <printf+0x17f>
    c = fmt[i] & 0xff;
 6b2:	8b 55 0c             	mov    0xc(%ebp),%edx
 6b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b8:	01 d0                	add    %edx,%eax
 6ba:	0f b6 00             	movzbl (%eax),%eax
 6bd:	0f be c0             	movsbl %al,%eax
 6c0:	25 ff 00 00 00       	and    $0xff,%eax
 6c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6cc:	75 2c                	jne    6fa <printf+0x6e>
      if(c == '%'){
 6ce:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6d2:	75 0c                	jne    6e0 <printf+0x54>
        state = '%';
 6d4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6db:	e9 27 01 00 00       	jmp    807 <printf+0x17b>
      } else {
        putc(fd, c);
 6e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e3:	0f be c0             	movsbl %al,%eax
 6e6:	83 ec 08             	sub    $0x8,%esp
 6e9:	50                   	push   %eax
 6ea:	ff 75 08             	pushl  0x8(%ebp)
 6ed:	e8 be fe ff ff       	call   5b0 <putc>
 6f2:	83 c4 10             	add    $0x10,%esp
 6f5:	e9 0d 01 00 00       	jmp    807 <printf+0x17b>
      }
    } else if(state == '%'){
 6fa:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6fe:	0f 85 03 01 00 00    	jne    807 <printf+0x17b>
      if(c == 'd'){
 704:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 708:	75 1e                	jne    728 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 70a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 70d:	8b 00                	mov    (%eax),%eax
 70f:	6a 01                	push   $0x1
 711:	6a 0a                	push   $0xa
 713:	50                   	push   %eax
 714:	ff 75 08             	pushl  0x8(%ebp)
 717:	e8 bb fe ff ff       	call   5d7 <printint>
 71c:	83 c4 10             	add    $0x10,%esp
        ap++;
 71f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 723:	e9 d8 00 00 00       	jmp    800 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 728:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 72c:	74 06                	je     734 <printf+0xa8>
 72e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 732:	75 1e                	jne    752 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 734:	8b 45 e8             	mov    -0x18(%ebp),%eax
 737:	8b 00                	mov    (%eax),%eax
 739:	6a 00                	push   $0x0
 73b:	6a 10                	push   $0x10
 73d:	50                   	push   %eax
 73e:	ff 75 08             	pushl  0x8(%ebp)
 741:	e8 91 fe ff ff       	call   5d7 <printint>
 746:	83 c4 10             	add    $0x10,%esp
        ap++;
 749:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74d:	e9 ae 00 00 00       	jmp    800 <printf+0x174>
      } else if(c == 's'){
 752:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 756:	75 43                	jne    79b <printf+0x10f>
        s = (char*)*ap;
 758:	8b 45 e8             	mov    -0x18(%ebp),%eax
 75b:	8b 00                	mov    (%eax),%eax
 75d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 760:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 764:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 768:	75 25                	jne    78f <printf+0x103>
          s = "(null)";
 76a:	c7 45 f4 ae 0a 00 00 	movl   $0xaae,-0xc(%ebp)
        while(*s != 0){
 771:	eb 1c                	jmp    78f <printf+0x103>
          putc(fd, *s);
 773:	8b 45 f4             	mov    -0xc(%ebp),%eax
 776:	0f b6 00             	movzbl (%eax),%eax
 779:	0f be c0             	movsbl %al,%eax
 77c:	83 ec 08             	sub    $0x8,%esp
 77f:	50                   	push   %eax
 780:	ff 75 08             	pushl  0x8(%ebp)
 783:	e8 28 fe ff ff       	call   5b0 <putc>
 788:	83 c4 10             	add    $0x10,%esp
          s++;
 78b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 78f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 792:	0f b6 00             	movzbl (%eax),%eax
 795:	84 c0                	test   %al,%al
 797:	75 da                	jne    773 <printf+0xe7>
 799:	eb 65                	jmp    800 <printf+0x174>
        }
      } else if(c == 'c'){
 79b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 79f:	75 1d                	jne    7be <printf+0x132>
        putc(fd, *ap);
 7a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7a4:	8b 00                	mov    (%eax),%eax
 7a6:	0f be c0             	movsbl %al,%eax
 7a9:	83 ec 08             	sub    $0x8,%esp
 7ac:	50                   	push   %eax
 7ad:	ff 75 08             	pushl  0x8(%ebp)
 7b0:	e8 fb fd ff ff       	call   5b0 <putc>
 7b5:	83 c4 10             	add    $0x10,%esp
        ap++;
 7b8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7bc:	eb 42                	jmp    800 <printf+0x174>
      } else if(c == '%'){
 7be:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7c2:	75 17                	jne    7db <printf+0x14f>
        putc(fd, c);
 7c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7c7:	0f be c0             	movsbl %al,%eax
 7ca:	83 ec 08             	sub    $0x8,%esp
 7cd:	50                   	push   %eax
 7ce:	ff 75 08             	pushl  0x8(%ebp)
 7d1:	e8 da fd ff ff       	call   5b0 <putc>
 7d6:	83 c4 10             	add    $0x10,%esp
 7d9:	eb 25                	jmp    800 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7db:	83 ec 08             	sub    $0x8,%esp
 7de:	6a 25                	push   $0x25
 7e0:	ff 75 08             	pushl  0x8(%ebp)
 7e3:	e8 c8 fd ff ff       	call   5b0 <putc>
 7e8:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 7eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7ee:	0f be c0             	movsbl %al,%eax
 7f1:	83 ec 08             	sub    $0x8,%esp
 7f4:	50                   	push   %eax
 7f5:	ff 75 08             	pushl  0x8(%ebp)
 7f8:	e8 b3 fd ff ff       	call   5b0 <putc>
 7fd:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 800:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 807:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 80b:	8b 55 0c             	mov    0xc(%ebp),%edx
 80e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 811:	01 d0                	add    %edx,%eax
 813:	0f b6 00             	movzbl (%eax),%eax
 816:	84 c0                	test   %al,%al
 818:	0f 85 94 fe ff ff    	jne    6b2 <printf+0x26>
    }
  }
}
 81e:	90                   	nop
 81f:	90                   	nop
 820:	c9                   	leave  
 821:	c3                   	ret    

00000822 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 822:	f3 0f 1e fb          	endbr32 
 826:	55                   	push   %ebp
 827:	89 e5                	mov    %esp,%ebp
 829:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 82c:	8b 45 08             	mov    0x8(%ebp),%eax
 82f:	83 e8 08             	sub    $0x8,%eax
 832:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 835:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 83a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 83d:	eb 24                	jmp    863 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 842:	8b 00                	mov    (%eax),%eax
 844:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 847:	72 12                	jb     85b <free+0x39>
 849:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 84f:	77 24                	ja     875 <free+0x53>
 851:	8b 45 fc             	mov    -0x4(%ebp),%eax
 854:	8b 00                	mov    (%eax),%eax
 856:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 859:	72 1a                	jb     875 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85e:	8b 00                	mov    (%eax),%eax
 860:	89 45 fc             	mov    %eax,-0x4(%ebp)
 863:	8b 45 f8             	mov    -0x8(%ebp),%eax
 866:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 869:	76 d4                	jbe    83f <free+0x1d>
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	8b 00                	mov    (%eax),%eax
 870:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 873:	73 ca                	jae    83f <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 875:	8b 45 f8             	mov    -0x8(%ebp),%eax
 878:	8b 40 04             	mov    0x4(%eax),%eax
 87b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 882:	8b 45 f8             	mov    -0x8(%ebp),%eax
 885:	01 c2                	add    %eax,%edx
 887:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88a:	8b 00                	mov    (%eax),%eax
 88c:	39 c2                	cmp    %eax,%edx
 88e:	75 24                	jne    8b4 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 890:	8b 45 f8             	mov    -0x8(%ebp),%eax
 893:	8b 50 04             	mov    0x4(%eax),%edx
 896:	8b 45 fc             	mov    -0x4(%ebp),%eax
 899:	8b 00                	mov    (%eax),%eax
 89b:	8b 40 04             	mov    0x4(%eax),%eax
 89e:	01 c2                	add    %eax,%edx
 8a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a9:	8b 00                	mov    (%eax),%eax
 8ab:	8b 10                	mov    (%eax),%edx
 8ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b0:	89 10                	mov    %edx,(%eax)
 8b2:	eb 0a                	jmp    8be <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 8b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b7:	8b 10                	mov    (%eax),%edx
 8b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bc:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c1:	8b 40 04             	mov    0x4(%eax),%eax
 8c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ce:	01 d0                	add    %edx,%eax
 8d0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8d3:	75 20                	jne    8f5 <free+0xd3>
    p->s.size += bp->s.size;
 8d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d8:	8b 50 04             	mov    0x4(%eax),%edx
 8db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8de:	8b 40 04             	mov    0x4(%eax),%eax
 8e1:	01 c2                	add    %eax,%edx
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ec:	8b 10                	mov    (%eax),%edx
 8ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f1:	89 10                	mov    %edx,(%eax)
 8f3:	eb 08                	jmp    8fd <free+0xdb>
  } else
    p->s.ptr = bp;
 8f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8fb:	89 10                	mov    %edx,(%eax)
  freep = p;
 8fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 900:	a3 e8 8d 00 00       	mov    %eax,0x8de8
}
 905:	90                   	nop
 906:	c9                   	leave  
 907:	c3                   	ret    

00000908 <morecore>:

static Header*
morecore(uint nu)
{
 908:	f3 0f 1e fb          	endbr32 
 90c:	55                   	push   %ebp
 90d:	89 e5                	mov    %esp,%ebp
 90f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 912:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 919:	77 07                	ja     922 <morecore+0x1a>
    nu = 4096;
 91b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 922:	8b 45 08             	mov    0x8(%ebp),%eax
 925:	c1 e0 03             	shl    $0x3,%eax
 928:	83 ec 0c             	sub    $0xc,%esp
 92b:	50                   	push   %eax
 92c:	e8 47 fc ff ff       	call   578 <sbrk>
 931:	83 c4 10             	add    $0x10,%esp
 934:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 937:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 93b:	75 07                	jne    944 <morecore+0x3c>
    return 0;
 93d:	b8 00 00 00 00       	mov    $0x0,%eax
 942:	eb 26                	jmp    96a <morecore+0x62>
  hp = (Header*)p;
 944:	8b 45 f4             	mov    -0xc(%ebp),%eax
 947:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 94a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94d:	8b 55 08             	mov    0x8(%ebp),%edx
 950:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 953:	8b 45 f0             	mov    -0x10(%ebp),%eax
 956:	83 c0 08             	add    $0x8,%eax
 959:	83 ec 0c             	sub    $0xc,%esp
 95c:	50                   	push   %eax
 95d:	e8 c0 fe ff ff       	call   822 <free>
 962:	83 c4 10             	add    $0x10,%esp
  return freep;
 965:	a1 e8 8d 00 00       	mov    0x8de8,%eax
}
 96a:	c9                   	leave  
 96b:	c3                   	ret    

0000096c <malloc>:

void*
malloc(uint nbytes)
{
 96c:	f3 0f 1e fb          	endbr32 
 970:	55                   	push   %ebp
 971:	89 e5                	mov    %esp,%ebp
 973:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 976:	8b 45 08             	mov    0x8(%ebp),%eax
 979:	83 c0 07             	add    $0x7,%eax
 97c:	c1 e8 03             	shr    $0x3,%eax
 97f:	83 c0 01             	add    $0x1,%eax
 982:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 985:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 98a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 98d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 991:	75 23                	jne    9b6 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 993:	c7 45 f0 e0 8d 00 00 	movl   $0x8de0,-0x10(%ebp)
 99a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 99d:	a3 e8 8d 00 00       	mov    %eax,0x8de8
 9a2:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 9a7:	a3 e0 8d 00 00       	mov    %eax,0x8de0
    base.s.size = 0;
 9ac:	c7 05 e4 8d 00 00 00 	movl   $0x0,0x8de4
 9b3:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b9:	8b 00                	mov    (%eax),%eax
 9bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c1:	8b 40 04             	mov    0x4(%eax),%eax
 9c4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9c7:	77 4d                	ja     a16 <malloc+0xaa>
      if(p->s.size == nunits)
 9c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cc:	8b 40 04             	mov    0x4(%eax),%eax
 9cf:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9d2:	75 0c                	jne    9e0 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 9d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d7:	8b 10                	mov    (%eax),%edx
 9d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9dc:	89 10                	mov    %edx,(%eax)
 9de:	eb 26                	jmp    a06 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e3:	8b 40 04             	mov    0x4(%eax),%eax
 9e6:	2b 45 ec             	sub    -0x14(%ebp),%eax
 9e9:	89 c2                	mov    %eax,%edx
 9eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ee:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f4:	8b 40 04             	mov    0x4(%eax),%eax
 9f7:	c1 e0 03             	shl    $0x3,%eax
 9fa:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a00:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a03:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a09:	a3 e8 8d 00 00       	mov    %eax,0x8de8
      return (void*)(p + 1);
 a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a11:	83 c0 08             	add    $0x8,%eax
 a14:	eb 3b                	jmp    a51 <malloc+0xe5>
    }
    if(p == freep)
 a16:	a1 e8 8d 00 00       	mov    0x8de8,%eax
 a1b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a1e:	75 1e                	jne    a3e <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 a20:	83 ec 0c             	sub    $0xc,%esp
 a23:	ff 75 ec             	pushl  -0x14(%ebp)
 a26:	e8 dd fe ff ff       	call   908 <morecore>
 a2b:	83 c4 10             	add    $0x10,%esp
 a2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a35:	75 07                	jne    a3e <malloc+0xd2>
        return 0;
 a37:	b8 00 00 00 00       	mov    $0x0,%eax
 a3c:	eb 13                	jmp    a51 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a47:	8b 00                	mov    (%eax),%eax
 a49:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a4c:	e9 6d ff ff ff       	jmp    9be <malloc+0x52>
  }
}
 a51:	c9                   	leave  
 a52:	c3                   	ret    
