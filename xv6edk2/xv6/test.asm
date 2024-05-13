
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"   
#include "fcntl.h"   


int main(int argc, char *argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	83 ec 24             	sub    $0x24,%esp
   int pid, child_pid;
   char *message;
   int n, status, exit_code;

   pid = fork();
  15:	e8 5c 03 00 00       	call   376 <fork>
  1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
   switch(pid) {
  1d:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
  21:	74 08                	je     2b <main+0x2b>
  23:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  27:	74 21                	je     4a <main+0x4a>
  29:	eb 36                	jmp    61 <main+0x61>
    case -1:
      printf(2, "fork failed");
  2b:	83 ec 08             	sub    $0x8,%esp
  2e:	68 d9 08 00 00       	push   $0x8d9
  33:	6a 02                	push   $0x2
  35:	e8 d8 04 00 00       	call   512 <printf>
  3a:	83 c4 10             	add    $0x10,%esp
      exit2(0);
  3d:	83 ec 0c             	sub    $0xc,%esp
  40:	6a 00                	push   $0x0
  42:	e8 d7 03 00 00       	call   41e <exit2>
  47:	83 c4 10             	add    $0x10,%esp
    case 0:
      message = "This is the child";
  4a:	c7 45 f4 e5 08 00 00 	movl   $0x8e5,-0xc(%ebp)
      n = 5;
  51:	c7 45 f0 05 00 00 00 	movl   $0x5,-0x10(%ebp)
      exit_code = 37;
  58:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
      break;
  5f:	eb 16                	jmp    77 <main+0x77>
    default:
      message = "This is the parent";
  61:	c7 45 f4 f7 08 00 00 	movl   $0x8f7,-0xc(%ebp)
      n = 3;
  68:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
      exit_code = 0;
  6f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      break;
  76:	90                   	nop
   }
  for(; n > 0; n--) {
  77:	eb 26                	jmp    9f <main+0x9f>
   printf(1, "%s\n", message);
  79:	83 ec 04             	sub    $0x4,%esp
  7c:	ff 75 f4             	pushl  -0xc(%ebp)
  7f:	68 0a 09 00 00       	push   $0x90a
  84:	6a 01                	push   $0x1
  86:	e8 87 04 00 00       	call   512 <printf>
  8b:	83 c4 10             	add    $0x10,%esp
   sleep(1);
  8e:	83 ec 0c             	sub    $0xc,%esp
  91:	6a 01                	push   $0x1
  93:	e8 76 03 00 00       	call   40e <sleep>
  98:	83 c4 10             	add    $0x10,%esp
  for(; n > 0; n--) {
  9b:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
  9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  a3:	7f d4                	jg     79 <main+0x79>
  }
  if (pid != 0) {
  a5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  a9:	74 3d                	je     e8 <main+0xe8>
   child_pid = wait2(&status);
  ab:	83 ec 0c             	sub    $0xc,%esp
  ae:	8d 45 e0             	lea    -0x20(%ebp),%eax
  b1:	50                   	push   %eax
  b2:	e8 6f 03 00 00       	call   426 <wait2>
  b7:	83 c4 10             	add    $0x10,%esp
  ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
   printf(1, "Child has finished: PID = %d\n", 
  bd:	83 ec 04             	sub    $0x4,%esp
  c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  c3:	68 0e 09 00 00       	push   $0x90e
  c8:	6a 01                	push   $0x1
  ca:	e8 43 04 00 00       	call   512 <printf>
  cf:	83 c4 10             	add    $0x10,%esp
             child_pid);
   printf(1, "Child exited with code %d\n", 
  d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  d5:	83 ec 04             	sub    $0x4,%esp
  d8:	50                   	push   %eax
  d9:	68 2c 09 00 00       	push   $0x92c
  de:	6a 01                	push   $0x1
  e0:	e8 2d 04 00 00       	call   512 <printf>
  e5:	83 c4 10             	add    $0x10,%esp
              status);
  }
  exit2(exit_code);
  e8:	83 ec 0c             	sub    $0xc,%esp
  eb:	ff 75 ec             	pushl  -0x14(%ebp)
  ee:	e8 2b 03 00 00       	call   41e <exit2>
  f3:	83 c4 10             	add    $0x10,%esp
  f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  fb:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  fe:	c9                   	leave  
  ff:	8d 61 fc             	lea    -0x4(%ecx),%esp
 102:	c3                   	ret    

00000103 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	57                   	push   %edi
 107:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 108:	8b 4d 08             	mov    0x8(%ebp),%ecx
 10b:	8b 55 10             	mov    0x10(%ebp),%edx
 10e:	8b 45 0c             	mov    0xc(%ebp),%eax
 111:	89 cb                	mov    %ecx,%ebx
 113:	89 df                	mov    %ebx,%edi
 115:	89 d1                	mov    %edx,%ecx
 117:	fc                   	cld    
 118:	f3 aa                	rep stos %al,%es:(%edi)
 11a:	89 ca                	mov    %ecx,%edx
 11c:	89 fb                	mov    %edi,%ebx
 11e:	89 5d 08             	mov    %ebx,0x8(%ebp)
 121:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 124:	90                   	nop
 125:	5b                   	pop    %ebx
 126:	5f                   	pop    %edi
 127:	5d                   	pop    %ebp
 128:	c3                   	ret    

00000129 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 129:	f3 0f 1e fb          	endbr32 
 12d:	55                   	push   %ebp
 12e:	89 e5                	mov    %esp,%ebp
 130:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 133:	8b 45 08             	mov    0x8(%ebp),%eax
 136:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 139:	90                   	nop
 13a:	8b 55 0c             	mov    0xc(%ebp),%edx
 13d:	8d 42 01             	lea    0x1(%edx),%eax
 140:	89 45 0c             	mov    %eax,0xc(%ebp)
 143:	8b 45 08             	mov    0x8(%ebp),%eax
 146:	8d 48 01             	lea    0x1(%eax),%ecx
 149:	89 4d 08             	mov    %ecx,0x8(%ebp)
 14c:	0f b6 12             	movzbl (%edx),%edx
 14f:	88 10                	mov    %dl,(%eax)
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	84 c0                	test   %al,%al
 156:	75 e2                	jne    13a <strcpy+0x11>
    ;
  return os;
 158:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 15b:	c9                   	leave  
 15c:	c3                   	ret    

0000015d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 15d:	f3 0f 1e fb          	endbr32 
 161:	55                   	push   %ebp
 162:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 164:	eb 08                	jmp    16e <strcmp+0x11>
    p++, q++;
 166:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	0f b6 00             	movzbl (%eax),%eax
 174:	84 c0                	test   %al,%al
 176:	74 10                	je     188 <strcmp+0x2b>
 178:	8b 45 08             	mov    0x8(%ebp),%eax
 17b:	0f b6 10             	movzbl (%eax),%edx
 17e:	8b 45 0c             	mov    0xc(%ebp),%eax
 181:	0f b6 00             	movzbl (%eax),%eax
 184:	38 c2                	cmp    %al,%dl
 186:	74 de                	je     166 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 188:	8b 45 08             	mov    0x8(%ebp),%eax
 18b:	0f b6 00             	movzbl (%eax),%eax
 18e:	0f b6 d0             	movzbl %al,%edx
 191:	8b 45 0c             	mov    0xc(%ebp),%eax
 194:	0f b6 00             	movzbl (%eax),%eax
 197:	0f b6 c0             	movzbl %al,%eax
 19a:	29 c2                	sub    %eax,%edx
 19c:	89 d0                	mov    %edx,%eax
}
 19e:	5d                   	pop    %ebp
 19f:	c3                   	ret    

000001a0 <strlen>:

uint
strlen(char *s)
{
 1a0:	f3 0f 1e fb          	endbr32 
 1a4:	55                   	push   %ebp
 1a5:	89 e5                	mov    %esp,%ebp
 1a7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b1:	eb 04                	jmp    1b7 <strlen+0x17>
 1b3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ba:	8b 45 08             	mov    0x8(%ebp),%eax
 1bd:	01 d0                	add    %edx,%eax
 1bf:	0f b6 00             	movzbl (%eax),%eax
 1c2:	84 c0                	test   %al,%al
 1c4:	75 ed                	jne    1b3 <strlen+0x13>
    ;
  return n;
 1c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c9:	c9                   	leave  
 1ca:	c3                   	ret    

000001cb <memset>:

void*
memset(void *dst, int c, uint n)
{
 1cb:	f3 0f 1e fb          	endbr32 
 1cf:	55                   	push   %ebp
 1d0:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1d2:	8b 45 10             	mov    0x10(%ebp),%eax
 1d5:	50                   	push   %eax
 1d6:	ff 75 0c             	pushl  0xc(%ebp)
 1d9:	ff 75 08             	pushl  0x8(%ebp)
 1dc:	e8 22 ff ff ff       	call   103 <stosb>
 1e1:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e7:	c9                   	leave  
 1e8:	c3                   	ret    

000001e9 <strchr>:

char*
strchr(const char *s, char c)
{
 1e9:	f3 0f 1e fb          	endbr32 
 1ed:	55                   	push   %ebp
 1ee:	89 e5                	mov    %esp,%ebp
 1f0:	83 ec 04             	sub    $0x4,%esp
 1f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f6:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f9:	eb 14                	jmp    20f <strchr+0x26>
    if(*s == c)
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	0f b6 00             	movzbl (%eax),%eax
 201:	38 45 fc             	cmp    %al,-0x4(%ebp)
 204:	75 05                	jne    20b <strchr+0x22>
      return (char*)s;
 206:	8b 45 08             	mov    0x8(%ebp),%eax
 209:	eb 13                	jmp    21e <strchr+0x35>
  for(; *s; s++)
 20b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	0f b6 00             	movzbl (%eax),%eax
 215:	84 c0                	test   %al,%al
 217:	75 e2                	jne    1fb <strchr+0x12>
  return 0;
 219:	b8 00 00 00 00       	mov    $0x0,%eax
}
 21e:	c9                   	leave  
 21f:	c3                   	ret    

00000220 <gets>:

char*
gets(char *buf, int max)
{
 220:	f3 0f 1e fb          	endbr32 
 224:	55                   	push   %ebp
 225:	89 e5                	mov    %esp,%ebp
 227:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 231:	eb 42                	jmp    275 <gets+0x55>
    cc = read(0, &c, 1);
 233:	83 ec 04             	sub    $0x4,%esp
 236:	6a 01                	push   $0x1
 238:	8d 45 ef             	lea    -0x11(%ebp),%eax
 23b:	50                   	push   %eax
 23c:	6a 00                	push   $0x0
 23e:	e8 53 01 00 00       	call   396 <read>
 243:	83 c4 10             	add    $0x10,%esp
 246:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 249:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 24d:	7e 33                	jle    282 <gets+0x62>
      break;
    buf[i++] = c;
 24f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 252:	8d 50 01             	lea    0x1(%eax),%edx
 255:	89 55 f4             	mov    %edx,-0xc(%ebp)
 258:	89 c2                	mov    %eax,%edx
 25a:	8b 45 08             	mov    0x8(%ebp),%eax
 25d:	01 c2                	add    %eax,%edx
 25f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 263:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 265:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 269:	3c 0a                	cmp    $0xa,%al
 26b:	74 16                	je     283 <gets+0x63>
 26d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 271:	3c 0d                	cmp    $0xd,%al
 273:	74 0e                	je     283 <gets+0x63>
  for(i=0; i+1 < max; ){
 275:	8b 45 f4             	mov    -0xc(%ebp),%eax
 278:	83 c0 01             	add    $0x1,%eax
 27b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 27e:	7f b3                	jg     233 <gets+0x13>
 280:	eb 01                	jmp    283 <gets+0x63>
      break;
 282:	90                   	nop
      break;
  }
  buf[i] = '\0';
 283:	8b 55 f4             	mov    -0xc(%ebp),%edx
 286:	8b 45 08             	mov    0x8(%ebp),%eax
 289:	01 d0                	add    %edx,%eax
 28b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 291:	c9                   	leave  
 292:	c3                   	ret    

00000293 <stat>:

int
stat(char *n, struct stat *st)
{
 293:	f3 0f 1e fb          	endbr32 
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29d:	83 ec 08             	sub    $0x8,%esp
 2a0:	6a 00                	push   $0x0
 2a2:	ff 75 08             	pushl  0x8(%ebp)
 2a5:	e8 14 01 00 00       	call   3be <open>
 2aa:	83 c4 10             	add    $0x10,%esp
 2ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2b4:	79 07                	jns    2bd <stat+0x2a>
    return -1;
 2b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2bb:	eb 25                	jmp    2e2 <stat+0x4f>
  r = fstat(fd, st);
 2bd:	83 ec 08             	sub    $0x8,%esp
 2c0:	ff 75 0c             	pushl  0xc(%ebp)
 2c3:	ff 75 f4             	pushl  -0xc(%ebp)
 2c6:	e8 0b 01 00 00       	call   3d6 <fstat>
 2cb:	83 c4 10             	add    $0x10,%esp
 2ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2d1:	83 ec 0c             	sub    $0xc,%esp
 2d4:	ff 75 f4             	pushl  -0xc(%ebp)
 2d7:	e8 ca 00 00 00       	call   3a6 <close>
 2dc:	83 c4 10             	add    $0x10,%esp
  return r;
 2df:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2e2:	c9                   	leave  
 2e3:	c3                   	ret    

000002e4 <atoi>:

int
atoi(const char *s)
{
 2e4:	f3 0f 1e fb          	endbr32 
 2e8:	55                   	push   %ebp
 2e9:	89 e5                	mov    %esp,%ebp
 2eb:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2f5:	eb 25                	jmp    31c <atoi+0x38>
    n = n*10 + *s++ - '0';
 2f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2fa:	89 d0                	mov    %edx,%eax
 2fc:	c1 e0 02             	shl    $0x2,%eax
 2ff:	01 d0                	add    %edx,%eax
 301:	01 c0                	add    %eax,%eax
 303:	89 c1                	mov    %eax,%ecx
 305:	8b 45 08             	mov    0x8(%ebp),%eax
 308:	8d 50 01             	lea    0x1(%eax),%edx
 30b:	89 55 08             	mov    %edx,0x8(%ebp)
 30e:	0f b6 00             	movzbl (%eax),%eax
 311:	0f be c0             	movsbl %al,%eax
 314:	01 c8                	add    %ecx,%eax
 316:	83 e8 30             	sub    $0x30,%eax
 319:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 31c:	8b 45 08             	mov    0x8(%ebp),%eax
 31f:	0f b6 00             	movzbl (%eax),%eax
 322:	3c 2f                	cmp    $0x2f,%al
 324:	7e 0a                	jle    330 <atoi+0x4c>
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	0f b6 00             	movzbl (%eax),%eax
 32c:	3c 39                	cmp    $0x39,%al
 32e:	7e c7                	jle    2f7 <atoi+0x13>
  return n;
 330:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 333:	c9                   	leave  
 334:	c3                   	ret    

00000335 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 335:	f3 0f 1e fb          	endbr32 
 339:	55                   	push   %ebp
 33a:	89 e5                	mov    %esp,%ebp
 33c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 33f:	8b 45 08             	mov    0x8(%ebp),%eax
 342:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 345:	8b 45 0c             	mov    0xc(%ebp),%eax
 348:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 34b:	eb 17                	jmp    364 <memmove+0x2f>
    *dst++ = *src++;
 34d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 350:	8d 42 01             	lea    0x1(%edx),%eax
 353:	89 45 f8             	mov    %eax,-0x8(%ebp)
 356:	8b 45 fc             	mov    -0x4(%ebp),%eax
 359:	8d 48 01             	lea    0x1(%eax),%ecx
 35c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 35f:	0f b6 12             	movzbl (%edx),%edx
 362:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 364:	8b 45 10             	mov    0x10(%ebp),%eax
 367:	8d 50 ff             	lea    -0x1(%eax),%edx
 36a:	89 55 10             	mov    %edx,0x10(%ebp)
 36d:	85 c0                	test   %eax,%eax
 36f:	7f dc                	jg     34d <memmove+0x18>
  return vdst;
 371:	8b 45 08             	mov    0x8(%ebp),%eax
}
 374:	c9                   	leave  
 375:	c3                   	ret    

00000376 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 376:	b8 01 00 00 00       	mov    $0x1,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <exit>:
SYSCALL(exit)
 37e:	b8 02 00 00 00       	mov    $0x2,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret    

00000386 <wait>:
SYSCALL(wait)
 386:	b8 03 00 00 00       	mov    $0x3,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <pipe>:
SYSCALL(pipe)
 38e:	b8 04 00 00 00       	mov    $0x4,%eax
 393:	cd 40                	int    $0x40
 395:	c3                   	ret    

00000396 <read>:
SYSCALL(read)
 396:	b8 05 00 00 00       	mov    $0x5,%eax
 39b:	cd 40                	int    $0x40
 39d:	c3                   	ret    

0000039e <write>:
SYSCALL(write)
 39e:	b8 10 00 00 00       	mov    $0x10,%eax
 3a3:	cd 40                	int    $0x40
 3a5:	c3                   	ret    

000003a6 <close>:
SYSCALL(close)
 3a6:	b8 15 00 00 00       	mov    $0x15,%eax
 3ab:	cd 40                	int    $0x40
 3ad:	c3                   	ret    

000003ae <kill>:
SYSCALL(kill)
 3ae:	b8 06 00 00 00       	mov    $0x6,%eax
 3b3:	cd 40                	int    $0x40
 3b5:	c3                   	ret    

000003b6 <exec>:
SYSCALL(exec)
 3b6:	b8 07 00 00 00       	mov    $0x7,%eax
 3bb:	cd 40                	int    $0x40
 3bd:	c3                   	ret    

000003be <open>:
SYSCALL(open)
 3be:	b8 0f 00 00 00       	mov    $0xf,%eax
 3c3:	cd 40                	int    $0x40
 3c5:	c3                   	ret    

000003c6 <mknod>:
SYSCALL(mknod)
 3c6:	b8 11 00 00 00       	mov    $0x11,%eax
 3cb:	cd 40                	int    $0x40
 3cd:	c3                   	ret    

000003ce <unlink>:
SYSCALL(unlink)
 3ce:	b8 12 00 00 00       	mov    $0x12,%eax
 3d3:	cd 40                	int    $0x40
 3d5:	c3                   	ret    

000003d6 <fstat>:
SYSCALL(fstat)
 3d6:	b8 08 00 00 00       	mov    $0x8,%eax
 3db:	cd 40                	int    $0x40
 3dd:	c3                   	ret    

000003de <link>:
SYSCALL(link)
 3de:	b8 13 00 00 00       	mov    $0x13,%eax
 3e3:	cd 40                	int    $0x40
 3e5:	c3                   	ret    

000003e6 <mkdir>:
SYSCALL(mkdir)
 3e6:	b8 14 00 00 00       	mov    $0x14,%eax
 3eb:	cd 40                	int    $0x40
 3ed:	c3                   	ret    

000003ee <chdir>:
SYSCALL(chdir)
 3ee:	b8 09 00 00 00       	mov    $0x9,%eax
 3f3:	cd 40                	int    $0x40
 3f5:	c3                   	ret    

000003f6 <dup>:
SYSCALL(dup)
 3f6:	b8 0a 00 00 00       	mov    $0xa,%eax
 3fb:	cd 40                	int    $0x40
 3fd:	c3                   	ret    

000003fe <getpid>:
SYSCALL(getpid)
 3fe:	b8 0b 00 00 00       	mov    $0xb,%eax
 403:	cd 40                	int    $0x40
 405:	c3                   	ret    

00000406 <sbrk>:
SYSCALL(sbrk)
 406:	b8 0c 00 00 00       	mov    $0xc,%eax
 40b:	cd 40                	int    $0x40
 40d:	c3                   	ret    

0000040e <sleep>:
SYSCALL(sleep)
 40e:	b8 0d 00 00 00       	mov    $0xd,%eax
 413:	cd 40                	int    $0x40
 415:	c3                   	ret    

00000416 <uptime>:
SYSCALL(uptime)
 416:	b8 0e 00 00 00       	mov    $0xe,%eax
 41b:	cd 40                	int    $0x40
 41d:	c3                   	ret    

0000041e <exit2>:
SYSCALL(exit2)
 41e:	b8 16 00 00 00       	mov    $0x16,%eax
 423:	cd 40                	int    $0x40
 425:	c3                   	ret    

00000426 <wait2>:
SYSCALL(wait2)
 426:	b8 17 00 00 00       	mov    $0x17,%eax
 42b:	cd 40                	int    $0x40
 42d:	c3                   	ret    

0000042e <uthread_init>:
SYSCALL(uthread_init)
 42e:	b8 18 00 00 00       	mov    $0x18,%eax
 433:	cd 40                	int    $0x40
 435:	c3                   	ret    

00000436 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 436:	f3 0f 1e fb          	endbr32 
 43a:	55                   	push   %ebp
 43b:	89 e5                	mov    %esp,%ebp
 43d:	83 ec 18             	sub    $0x18,%esp
 440:	8b 45 0c             	mov    0xc(%ebp),%eax
 443:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 446:	83 ec 04             	sub    $0x4,%esp
 449:	6a 01                	push   $0x1
 44b:	8d 45 f4             	lea    -0xc(%ebp),%eax
 44e:	50                   	push   %eax
 44f:	ff 75 08             	pushl  0x8(%ebp)
 452:	e8 47 ff ff ff       	call   39e <write>
 457:	83 c4 10             	add    $0x10,%esp
}
 45a:	90                   	nop
 45b:	c9                   	leave  
 45c:	c3                   	ret    

0000045d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45d:	f3 0f 1e fb          	endbr32 
 461:	55                   	push   %ebp
 462:	89 e5                	mov    %esp,%ebp
 464:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 467:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 46e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 472:	74 17                	je     48b <printint+0x2e>
 474:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 478:	79 11                	jns    48b <printint+0x2e>
    neg = 1;
 47a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 481:	8b 45 0c             	mov    0xc(%ebp),%eax
 484:	f7 d8                	neg    %eax
 486:	89 45 ec             	mov    %eax,-0x14(%ebp)
 489:	eb 06                	jmp    491 <printint+0x34>
  } else {
    x = xx;
 48b:	8b 45 0c             	mov    0xc(%ebp),%eax
 48e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 491:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 498:	8b 4d 10             	mov    0x10(%ebp),%ecx
 49b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 49e:	ba 00 00 00 00       	mov    $0x0,%edx
 4a3:	f7 f1                	div    %ecx
 4a5:	89 d1                	mov    %edx,%ecx
 4a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4aa:	8d 50 01             	lea    0x1(%eax),%edx
 4ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4b0:	0f b6 91 9c 0b 00 00 	movzbl 0xb9c(%ecx),%edx
 4b7:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4be:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c1:	ba 00 00 00 00       	mov    $0x0,%edx
 4c6:	f7 f1                	div    %ecx
 4c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4cf:	75 c7                	jne    498 <printint+0x3b>
  if(neg)
 4d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4d5:	74 2d                	je     504 <printint+0xa7>
    buf[i++] = '-';
 4d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4da:	8d 50 01             	lea    0x1(%eax),%edx
 4dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4e0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4e5:	eb 1d                	jmp    504 <printint+0xa7>
    putc(fd, buf[i]);
 4e7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ed:	01 d0                	add    %edx,%eax
 4ef:	0f b6 00             	movzbl (%eax),%eax
 4f2:	0f be c0             	movsbl %al,%eax
 4f5:	83 ec 08             	sub    $0x8,%esp
 4f8:	50                   	push   %eax
 4f9:	ff 75 08             	pushl  0x8(%ebp)
 4fc:	e8 35 ff ff ff       	call   436 <putc>
 501:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 504:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 508:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 50c:	79 d9                	jns    4e7 <printint+0x8a>
}
 50e:	90                   	nop
 50f:	90                   	nop
 510:	c9                   	leave  
 511:	c3                   	ret    

00000512 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 512:	f3 0f 1e fb          	endbr32 
 516:	55                   	push   %ebp
 517:	89 e5                	mov    %esp,%ebp
 519:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 51c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 523:	8d 45 0c             	lea    0xc(%ebp),%eax
 526:	83 c0 04             	add    $0x4,%eax
 529:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 52c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 533:	e9 59 01 00 00       	jmp    691 <printf+0x17f>
    c = fmt[i] & 0xff;
 538:	8b 55 0c             	mov    0xc(%ebp),%edx
 53b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 53e:	01 d0                	add    %edx,%eax
 540:	0f b6 00             	movzbl (%eax),%eax
 543:	0f be c0             	movsbl %al,%eax
 546:	25 ff 00 00 00       	and    $0xff,%eax
 54b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 54e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 552:	75 2c                	jne    580 <printf+0x6e>
      if(c == '%'){
 554:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 558:	75 0c                	jne    566 <printf+0x54>
        state = '%';
 55a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 561:	e9 27 01 00 00       	jmp    68d <printf+0x17b>
      } else {
        putc(fd, c);
 566:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 569:	0f be c0             	movsbl %al,%eax
 56c:	83 ec 08             	sub    $0x8,%esp
 56f:	50                   	push   %eax
 570:	ff 75 08             	pushl  0x8(%ebp)
 573:	e8 be fe ff ff       	call   436 <putc>
 578:	83 c4 10             	add    $0x10,%esp
 57b:	e9 0d 01 00 00       	jmp    68d <printf+0x17b>
      }
    } else if(state == '%'){
 580:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 584:	0f 85 03 01 00 00    	jne    68d <printf+0x17b>
      if(c == 'd'){
 58a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 58e:	75 1e                	jne    5ae <printf+0x9c>
        printint(fd, *ap, 10, 1);
 590:	8b 45 e8             	mov    -0x18(%ebp),%eax
 593:	8b 00                	mov    (%eax),%eax
 595:	6a 01                	push   $0x1
 597:	6a 0a                	push   $0xa
 599:	50                   	push   %eax
 59a:	ff 75 08             	pushl  0x8(%ebp)
 59d:	e8 bb fe ff ff       	call   45d <printint>
 5a2:	83 c4 10             	add    $0x10,%esp
        ap++;
 5a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a9:	e9 d8 00 00 00       	jmp    686 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 5ae:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5b2:	74 06                	je     5ba <printf+0xa8>
 5b4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b8:	75 1e                	jne    5d8 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 5ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5bd:	8b 00                	mov    (%eax),%eax
 5bf:	6a 00                	push   $0x0
 5c1:	6a 10                	push   $0x10
 5c3:	50                   	push   %eax
 5c4:	ff 75 08             	pushl  0x8(%ebp)
 5c7:	e8 91 fe ff ff       	call   45d <printint>
 5cc:	83 c4 10             	add    $0x10,%esp
        ap++;
 5cf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d3:	e9 ae 00 00 00       	jmp    686 <printf+0x174>
      } else if(c == 's'){
 5d8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5dc:	75 43                	jne    621 <printf+0x10f>
        s = (char*)*ap;
 5de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e1:	8b 00                	mov    (%eax),%eax
 5e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5e6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ee:	75 25                	jne    615 <printf+0x103>
          s = "(null)";
 5f0:	c7 45 f4 47 09 00 00 	movl   $0x947,-0xc(%ebp)
        while(*s != 0){
 5f7:	eb 1c                	jmp    615 <printf+0x103>
          putc(fd, *s);
 5f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fc:	0f b6 00             	movzbl (%eax),%eax
 5ff:	0f be c0             	movsbl %al,%eax
 602:	83 ec 08             	sub    $0x8,%esp
 605:	50                   	push   %eax
 606:	ff 75 08             	pushl  0x8(%ebp)
 609:	e8 28 fe ff ff       	call   436 <putc>
 60e:	83 c4 10             	add    $0x10,%esp
          s++;
 611:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 615:	8b 45 f4             	mov    -0xc(%ebp),%eax
 618:	0f b6 00             	movzbl (%eax),%eax
 61b:	84 c0                	test   %al,%al
 61d:	75 da                	jne    5f9 <printf+0xe7>
 61f:	eb 65                	jmp    686 <printf+0x174>
        }
      } else if(c == 'c'){
 621:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 625:	75 1d                	jne    644 <printf+0x132>
        putc(fd, *ap);
 627:	8b 45 e8             	mov    -0x18(%ebp),%eax
 62a:	8b 00                	mov    (%eax),%eax
 62c:	0f be c0             	movsbl %al,%eax
 62f:	83 ec 08             	sub    $0x8,%esp
 632:	50                   	push   %eax
 633:	ff 75 08             	pushl  0x8(%ebp)
 636:	e8 fb fd ff ff       	call   436 <putc>
 63b:	83 c4 10             	add    $0x10,%esp
        ap++;
 63e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 642:	eb 42                	jmp    686 <printf+0x174>
      } else if(c == '%'){
 644:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 648:	75 17                	jne    661 <printf+0x14f>
        putc(fd, c);
 64a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 64d:	0f be c0             	movsbl %al,%eax
 650:	83 ec 08             	sub    $0x8,%esp
 653:	50                   	push   %eax
 654:	ff 75 08             	pushl  0x8(%ebp)
 657:	e8 da fd ff ff       	call   436 <putc>
 65c:	83 c4 10             	add    $0x10,%esp
 65f:	eb 25                	jmp    686 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 661:	83 ec 08             	sub    $0x8,%esp
 664:	6a 25                	push   $0x25
 666:	ff 75 08             	pushl  0x8(%ebp)
 669:	e8 c8 fd ff ff       	call   436 <putc>
 66e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 671:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 674:	0f be c0             	movsbl %al,%eax
 677:	83 ec 08             	sub    $0x8,%esp
 67a:	50                   	push   %eax
 67b:	ff 75 08             	pushl  0x8(%ebp)
 67e:	e8 b3 fd ff ff       	call   436 <putc>
 683:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 686:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 68d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 691:	8b 55 0c             	mov    0xc(%ebp),%edx
 694:	8b 45 f0             	mov    -0x10(%ebp),%eax
 697:	01 d0                	add    %edx,%eax
 699:	0f b6 00             	movzbl (%eax),%eax
 69c:	84 c0                	test   %al,%al
 69e:	0f 85 94 fe ff ff    	jne    538 <printf+0x26>
    }
  }
}
 6a4:	90                   	nop
 6a5:	90                   	nop
 6a6:	c9                   	leave  
 6a7:	c3                   	ret    

000006a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a8:	f3 0f 1e fb          	endbr32 
 6ac:	55                   	push   %ebp
 6ad:	89 e5                	mov    %esp,%ebp
 6af:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b2:	8b 45 08             	mov    0x8(%ebp),%eax
 6b5:	83 e8 08             	sub    $0x8,%eax
 6b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6bb:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 6c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6c3:	eb 24                	jmp    6e9 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c8:	8b 00                	mov    (%eax),%eax
 6ca:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6cd:	72 12                	jb     6e1 <free+0x39>
 6cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d5:	77 24                	ja     6fb <free+0x53>
 6d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6da:	8b 00                	mov    (%eax),%eax
 6dc:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6df:	72 1a                	jb     6fb <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	8b 00                	mov    (%eax),%eax
 6e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ec:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ef:	76 d4                	jbe    6c5 <free+0x1d>
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6f9:	73 ca                	jae    6c5 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fe:	8b 40 04             	mov    0x4(%eax),%eax
 701:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 708:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70b:	01 c2                	add    %eax,%edx
 70d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 710:	8b 00                	mov    (%eax),%eax
 712:	39 c2                	cmp    %eax,%edx
 714:	75 24                	jne    73a <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 716:	8b 45 f8             	mov    -0x8(%ebp),%eax
 719:	8b 50 04             	mov    0x4(%eax),%edx
 71c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71f:	8b 00                	mov    (%eax),%eax
 721:	8b 40 04             	mov    0x4(%eax),%eax
 724:	01 c2                	add    %eax,%edx
 726:	8b 45 f8             	mov    -0x8(%ebp),%eax
 729:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 72c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72f:	8b 00                	mov    (%eax),%eax
 731:	8b 10                	mov    (%eax),%edx
 733:	8b 45 f8             	mov    -0x8(%ebp),%eax
 736:	89 10                	mov    %edx,(%eax)
 738:	eb 0a                	jmp    744 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 73a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73d:	8b 10                	mov    (%eax),%edx
 73f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 742:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 744:	8b 45 fc             	mov    -0x4(%ebp),%eax
 747:	8b 40 04             	mov    0x4(%eax),%eax
 74a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 751:	8b 45 fc             	mov    -0x4(%ebp),%eax
 754:	01 d0                	add    %edx,%eax
 756:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 759:	75 20                	jne    77b <free+0xd3>
    p->s.size += bp->s.size;
 75b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75e:	8b 50 04             	mov    0x4(%eax),%edx
 761:	8b 45 f8             	mov    -0x8(%ebp),%eax
 764:	8b 40 04             	mov    0x4(%eax),%eax
 767:	01 c2                	add    %eax,%edx
 769:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 76f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 772:	8b 10                	mov    (%eax),%edx
 774:	8b 45 fc             	mov    -0x4(%ebp),%eax
 777:	89 10                	mov    %edx,(%eax)
 779:	eb 08                	jmp    783 <free+0xdb>
  } else
    p->s.ptr = bp;
 77b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 781:	89 10                	mov    %edx,(%eax)
  freep = p;
 783:	8b 45 fc             	mov    -0x4(%ebp),%eax
 786:	a3 b8 0b 00 00       	mov    %eax,0xbb8
}
 78b:	90                   	nop
 78c:	c9                   	leave  
 78d:	c3                   	ret    

0000078e <morecore>:

static Header*
morecore(uint nu)
{
 78e:	f3 0f 1e fb          	endbr32 
 792:	55                   	push   %ebp
 793:	89 e5                	mov    %esp,%ebp
 795:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 798:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 79f:	77 07                	ja     7a8 <morecore+0x1a>
    nu = 4096;
 7a1:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7a8:	8b 45 08             	mov    0x8(%ebp),%eax
 7ab:	c1 e0 03             	shl    $0x3,%eax
 7ae:	83 ec 0c             	sub    $0xc,%esp
 7b1:	50                   	push   %eax
 7b2:	e8 4f fc ff ff       	call   406 <sbrk>
 7b7:	83 c4 10             	add    $0x10,%esp
 7ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7bd:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c1:	75 07                	jne    7ca <morecore+0x3c>
    return 0;
 7c3:	b8 00 00 00 00       	mov    $0x0,%eax
 7c8:	eb 26                	jmp    7f0 <morecore+0x62>
  hp = (Header*)p;
 7ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d3:	8b 55 08             	mov    0x8(%ebp),%edx
 7d6:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dc:	83 c0 08             	add    $0x8,%eax
 7df:	83 ec 0c             	sub    $0xc,%esp
 7e2:	50                   	push   %eax
 7e3:	e8 c0 fe ff ff       	call   6a8 <free>
 7e8:	83 c4 10             	add    $0x10,%esp
  return freep;
 7eb:	a1 b8 0b 00 00       	mov    0xbb8,%eax
}
 7f0:	c9                   	leave  
 7f1:	c3                   	ret    

000007f2 <malloc>:

void*
malloc(uint nbytes)
{
 7f2:	f3 0f 1e fb          	endbr32 
 7f6:	55                   	push   %ebp
 7f7:	89 e5                	mov    %esp,%ebp
 7f9:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fc:	8b 45 08             	mov    0x8(%ebp),%eax
 7ff:	83 c0 07             	add    $0x7,%eax
 802:	c1 e8 03             	shr    $0x3,%eax
 805:	83 c0 01             	add    $0x1,%eax
 808:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 80b:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 810:	89 45 f0             	mov    %eax,-0x10(%ebp)
 813:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 817:	75 23                	jne    83c <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 819:	c7 45 f0 b0 0b 00 00 	movl   $0xbb0,-0x10(%ebp)
 820:	8b 45 f0             	mov    -0x10(%ebp),%eax
 823:	a3 b8 0b 00 00       	mov    %eax,0xbb8
 828:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 82d:	a3 b0 0b 00 00       	mov    %eax,0xbb0
    base.s.size = 0;
 832:	c7 05 b4 0b 00 00 00 	movl   $0x0,0xbb4
 839:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83f:	8b 00                	mov    (%eax),%eax
 841:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 844:	8b 45 f4             	mov    -0xc(%ebp),%eax
 847:	8b 40 04             	mov    0x4(%eax),%eax
 84a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 84d:	77 4d                	ja     89c <malloc+0xaa>
      if(p->s.size == nunits)
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	8b 40 04             	mov    0x4(%eax),%eax
 855:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 858:	75 0c                	jne    866 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85d:	8b 10                	mov    (%eax),%edx
 85f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 862:	89 10                	mov    %edx,(%eax)
 864:	eb 26                	jmp    88c <malloc+0x9a>
      else {
        p->s.size -= nunits;
 866:	8b 45 f4             	mov    -0xc(%ebp),%eax
 869:	8b 40 04             	mov    0x4(%eax),%eax
 86c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 86f:	89 c2                	mov    %eax,%edx
 871:	8b 45 f4             	mov    -0xc(%ebp),%eax
 874:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 877:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87a:	8b 40 04             	mov    0x4(%eax),%eax
 87d:	c1 e0 03             	shl    $0x3,%eax
 880:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 883:	8b 45 f4             	mov    -0xc(%ebp),%eax
 886:	8b 55 ec             	mov    -0x14(%ebp),%edx
 889:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 88c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88f:	a3 b8 0b 00 00       	mov    %eax,0xbb8
      return (void*)(p + 1);
 894:	8b 45 f4             	mov    -0xc(%ebp),%eax
 897:	83 c0 08             	add    $0x8,%eax
 89a:	eb 3b                	jmp    8d7 <malloc+0xe5>
    }
    if(p == freep)
 89c:	a1 b8 0b 00 00       	mov    0xbb8,%eax
 8a1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8a4:	75 1e                	jne    8c4 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 8a6:	83 ec 0c             	sub    $0xc,%esp
 8a9:	ff 75 ec             	pushl  -0x14(%ebp)
 8ac:	e8 dd fe ff ff       	call   78e <morecore>
 8b1:	83 c4 10             	add    $0x10,%esp
 8b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8bb:	75 07                	jne    8c4 <malloc+0xd2>
        return 0;
 8bd:	b8 00 00 00 00       	mov    $0x0,%eax
 8c2:	eb 13                	jmp    8d7 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cd:	8b 00                	mov    (%eax),%eax
 8cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8d2:	e9 6d ff ff ff       	jmp    844 <malloc+0x52>
  }
}
 8d7:	c9                   	leave  
 8d8:	c3                   	ret    
