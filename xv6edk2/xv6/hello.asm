
_hello:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h" 
#include "user.h" 

int main(int argc, char *argv[]) {
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	83 ec 04             	sub    $0x4,%esp
 printf(1,"Hello world!\n");
  15:	83 ec 08             	sub    $0x8,%esp
  18:	68 02 08 00 00       	push   $0x802
  1d:	6a 01                	push   $0x1
  1f:	e8 17 04 00 00       	call   43b <printf>
  24:	83 c4 10             	add    $0x10,%esp
 exit();
  27:	e8 7b 02 00 00       	call   2a7 <exit>

0000002c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  2c:	55                   	push   %ebp
  2d:	89 e5                	mov    %esp,%ebp
  2f:	57                   	push   %edi
  30:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  34:	8b 55 10             	mov    0x10(%ebp),%edx
  37:	8b 45 0c             	mov    0xc(%ebp),%eax
  3a:	89 cb                	mov    %ecx,%ebx
  3c:	89 df                	mov    %ebx,%edi
  3e:	89 d1                	mov    %edx,%ecx
  40:	fc                   	cld    
  41:	f3 aa                	rep stos %al,%es:(%edi)
  43:	89 ca                	mov    %ecx,%edx
  45:	89 fb                	mov    %edi,%ebx
  47:	89 5d 08             	mov    %ebx,0x8(%ebp)
  4a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  4d:	90                   	nop
  4e:	5b                   	pop    %ebx
  4f:	5f                   	pop    %edi
  50:	5d                   	pop    %ebp
  51:	c3                   	ret    

00000052 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  52:	f3 0f 1e fb          	endbr32 
  56:	55                   	push   %ebp
  57:	89 e5                	mov    %esp,%ebp
  59:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  5c:	8b 45 08             	mov    0x8(%ebp),%eax
  5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  62:	90                   	nop
  63:	8b 55 0c             	mov    0xc(%ebp),%edx
  66:	8d 42 01             	lea    0x1(%edx),%eax
  69:	89 45 0c             	mov    %eax,0xc(%ebp)
  6c:	8b 45 08             	mov    0x8(%ebp),%eax
  6f:	8d 48 01             	lea    0x1(%eax),%ecx
  72:	89 4d 08             	mov    %ecx,0x8(%ebp)
  75:	0f b6 12             	movzbl (%edx),%edx
  78:	88 10                	mov    %dl,(%eax)
  7a:	0f b6 00             	movzbl (%eax),%eax
  7d:	84 c0                	test   %al,%al
  7f:	75 e2                	jne    63 <strcpy+0x11>
    ;
  return os;
  81:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  84:	c9                   	leave  
  85:	c3                   	ret    

00000086 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  86:	f3 0f 1e fb          	endbr32 
  8a:	55                   	push   %ebp
  8b:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  8d:	eb 08                	jmp    97 <strcmp+0x11>
    p++, q++;
  8f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  93:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  97:	8b 45 08             	mov    0x8(%ebp),%eax
  9a:	0f b6 00             	movzbl (%eax),%eax
  9d:	84 c0                	test   %al,%al
  9f:	74 10                	je     b1 <strcmp+0x2b>
  a1:	8b 45 08             	mov    0x8(%ebp),%eax
  a4:	0f b6 10             	movzbl (%eax),%edx
  a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  aa:	0f b6 00             	movzbl (%eax),%eax
  ad:	38 c2                	cmp    %al,%dl
  af:	74 de                	je     8f <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
  b1:	8b 45 08             	mov    0x8(%ebp),%eax
  b4:	0f b6 00             	movzbl (%eax),%eax
  b7:	0f b6 d0             	movzbl %al,%edx
  ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  bd:	0f b6 00             	movzbl (%eax),%eax
  c0:	0f b6 c0             	movzbl %al,%eax
  c3:	29 c2                	sub    %eax,%edx
  c5:	89 d0                	mov    %edx,%eax
}
  c7:	5d                   	pop    %ebp
  c8:	c3                   	ret    

000000c9 <strlen>:

uint
strlen(char *s)
{
  c9:	f3 0f 1e fb          	endbr32 
  cd:	55                   	push   %ebp
  ce:	89 e5                	mov    %esp,%ebp
  d0:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  d3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  da:	eb 04                	jmp    e0 <strlen+0x17>
  dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  e0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  e3:	8b 45 08             	mov    0x8(%ebp),%eax
  e6:	01 d0                	add    %edx,%eax
  e8:	0f b6 00             	movzbl (%eax),%eax
  eb:	84 c0                	test   %al,%al
  ed:	75 ed                	jne    dc <strlen+0x13>
    ;
  return n;
  ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f2:	c9                   	leave  
  f3:	c3                   	ret    

000000f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f4:	f3 0f 1e fb          	endbr32 
  f8:	55                   	push   %ebp
  f9:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
  fb:	8b 45 10             	mov    0x10(%ebp),%eax
  fe:	50                   	push   %eax
  ff:	ff 75 0c             	pushl  0xc(%ebp)
 102:	ff 75 08             	pushl  0x8(%ebp)
 105:	e8 22 ff ff ff       	call   2c <stosb>
 10a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 10d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 110:	c9                   	leave  
 111:	c3                   	ret    

00000112 <strchr>:

char*
strchr(const char *s, char c)
{
 112:	f3 0f 1e fb          	endbr32 
 116:	55                   	push   %ebp
 117:	89 e5                	mov    %esp,%ebp
 119:	83 ec 04             	sub    $0x4,%esp
 11c:	8b 45 0c             	mov    0xc(%ebp),%eax
 11f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 122:	eb 14                	jmp    138 <strchr+0x26>
    if(*s == c)
 124:	8b 45 08             	mov    0x8(%ebp),%eax
 127:	0f b6 00             	movzbl (%eax),%eax
 12a:	38 45 fc             	cmp    %al,-0x4(%ebp)
 12d:	75 05                	jne    134 <strchr+0x22>
      return (char*)s;
 12f:	8b 45 08             	mov    0x8(%ebp),%eax
 132:	eb 13                	jmp    147 <strchr+0x35>
  for(; *s; s++)
 134:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 138:	8b 45 08             	mov    0x8(%ebp),%eax
 13b:	0f b6 00             	movzbl (%eax),%eax
 13e:	84 c0                	test   %al,%al
 140:	75 e2                	jne    124 <strchr+0x12>
  return 0;
 142:	b8 00 00 00 00       	mov    $0x0,%eax
}
 147:	c9                   	leave  
 148:	c3                   	ret    

00000149 <gets>:

char*
gets(char *buf, int max)
{
 149:	f3 0f 1e fb          	endbr32 
 14d:	55                   	push   %ebp
 14e:	89 e5                	mov    %esp,%ebp
 150:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 153:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 15a:	eb 42                	jmp    19e <gets+0x55>
    cc = read(0, &c, 1);
 15c:	83 ec 04             	sub    $0x4,%esp
 15f:	6a 01                	push   $0x1
 161:	8d 45 ef             	lea    -0x11(%ebp),%eax
 164:	50                   	push   %eax
 165:	6a 00                	push   $0x0
 167:	e8 53 01 00 00       	call   2bf <read>
 16c:	83 c4 10             	add    $0x10,%esp
 16f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 172:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 176:	7e 33                	jle    1ab <gets+0x62>
      break;
    buf[i++] = c;
 178:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17b:	8d 50 01             	lea    0x1(%eax),%edx
 17e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 181:	89 c2                	mov    %eax,%edx
 183:	8b 45 08             	mov    0x8(%ebp),%eax
 186:	01 c2                	add    %eax,%edx
 188:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 18c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 18e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 192:	3c 0a                	cmp    $0xa,%al
 194:	74 16                	je     1ac <gets+0x63>
 196:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 19a:	3c 0d                	cmp    $0xd,%al
 19c:	74 0e                	je     1ac <gets+0x63>
  for(i=0; i+1 < max; ){
 19e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a1:	83 c0 01             	add    $0x1,%eax
 1a4:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1a7:	7f b3                	jg     15c <gets+0x13>
 1a9:	eb 01                	jmp    1ac <gets+0x63>
      break;
 1ab:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1af:	8b 45 08             	mov    0x8(%ebp),%eax
 1b2:	01 d0                	add    %edx,%eax
 1b4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ba:	c9                   	leave  
 1bb:	c3                   	ret    

000001bc <stat>:

int
stat(char *n, struct stat *st)
{
 1bc:	f3 0f 1e fb          	endbr32 
 1c0:	55                   	push   %ebp
 1c1:	89 e5                	mov    %esp,%ebp
 1c3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c6:	83 ec 08             	sub    $0x8,%esp
 1c9:	6a 00                	push   $0x0
 1cb:	ff 75 08             	pushl  0x8(%ebp)
 1ce:	e8 14 01 00 00       	call   2e7 <open>
 1d3:	83 c4 10             	add    $0x10,%esp
 1d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1dd:	79 07                	jns    1e6 <stat+0x2a>
    return -1;
 1df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1e4:	eb 25                	jmp    20b <stat+0x4f>
  r = fstat(fd, st);
 1e6:	83 ec 08             	sub    $0x8,%esp
 1e9:	ff 75 0c             	pushl  0xc(%ebp)
 1ec:	ff 75 f4             	pushl  -0xc(%ebp)
 1ef:	e8 0b 01 00 00       	call   2ff <fstat>
 1f4:	83 c4 10             	add    $0x10,%esp
 1f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1fa:	83 ec 0c             	sub    $0xc,%esp
 1fd:	ff 75 f4             	pushl  -0xc(%ebp)
 200:	e8 ca 00 00 00       	call   2cf <close>
 205:	83 c4 10             	add    $0x10,%esp
  return r;
 208:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 20b:	c9                   	leave  
 20c:	c3                   	ret    

0000020d <atoi>:

int
atoi(const char *s)
{
 20d:	f3 0f 1e fb          	endbr32 
 211:	55                   	push   %ebp
 212:	89 e5                	mov    %esp,%ebp
 214:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 217:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 21e:	eb 25                	jmp    245 <atoi+0x38>
    n = n*10 + *s++ - '0';
 220:	8b 55 fc             	mov    -0x4(%ebp),%edx
 223:	89 d0                	mov    %edx,%eax
 225:	c1 e0 02             	shl    $0x2,%eax
 228:	01 d0                	add    %edx,%eax
 22a:	01 c0                	add    %eax,%eax
 22c:	89 c1                	mov    %eax,%ecx
 22e:	8b 45 08             	mov    0x8(%ebp),%eax
 231:	8d 50 01             	lea    0x1(%eax),%edx
 234:	89 55 08             	mov    %edx,0x8(%ebp)
 237:	0f b6 00             	movzbl (%eax),%eax
 23a:	0f be c0             	movsbl %al,%eax
 23d:	01 c8                	add    %ecx,%eax
 23f:	83 e8 30             	sub    $0x30,%eax
 242:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 245:	8b 45 08             	mov    0x8(%ebp),%eax
 248:	0f b6 00             	movzbl (%eax),%eax
 24b:	3c 2f                	cmp    $0x2f,%al
 24d:	7e 0a                	jle    259 <atoi+0x4c>
 24f:	8b 45 08             	mov    0x8(%ebp),%eax
 252:	0f b6 00             	movzbl (%eax),%eax
 255:	3c 39                	cmp    $0x39,%al
 257:	7e c7                	jle    220 <atoi+0x13>
  return n;
 259:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 25c:	c9                   	leave  
 25d:	c3                   	ret    

0000025e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 25e:	f3 0f 1e fb          	endbr32 
 262:	55                   	push   %ebp
 263:	89 e5                	mov    %esp,%ebp
 265:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 268:	8b 45 08             	mov    0x8(%ebp),%eax
 26b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 26e:	8b 45 0c             	mov    0xc(%ebp),%eax
 271:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 274:	eb 17                	jmp    28d <memmove+0x2f>
    *dst++ = *src++;
 276:	8b 55 f8             	mov    -0x8(%ebp),%edx
 279:	8d 42 01             	lea    0x1(%edx),%eax
 27c:	89 45 f8             	mov    %eax,-0x8(%ebp)
 27f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 282:	8d 48 01             	lea    0x1(%eax),%ecx
 285:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 288:	0f b6 12             	movzbl (%edx),%edx
 28b:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 28d:	8b 45 10             	mov    0x10(%ebp),%eax
 290:	8d 50 ff             	lea    -0x1(%eax),%edx
 293:	89 55 10             	mov    %edx,0x10(%ebp)
 296:	85 c0                	test   %eax,%eax
 298:	7f dc                	jg     276 <memmove+0x18>
  return vdst;
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 29d:	c9                   	leave  
 29e:	c3                   	ret    

0000029f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 29f:	b8 01 00 00 00       	mov    $0x1,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret    

000002a7 <exit>:
SYSCALL(exit)
 2a7:	b8 02 00 00 00       	mov    $0x2,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret    

000002af <wait>:
SYSCALL(wait)
 2af:	b8 03 00 00 00       	mov    $0x3,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret    

000002b7 <pipe>:
SYSCALL(pipe)
 2b7:	b8 04 00 00 00       	mov    $0x4,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret    

000002bf <read>:
SYSCALL(read)
 2bf:	b8 05 00 00 00       	mov    $0x5,%eax
 2c4:	cd 40                	int    $0x40
 2c6:	c3                   	ret    

000002c7 <write>:
SYSCALL(write)
 2c7:	b8 10 00 00 00       	mov    $0x10,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <close>:
SYSCALL(close)
 2cf:	b8 15 00 00 00       	mov    $0x15,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <kill>:
SYSCALL(kill)
 2d7:	b8 06 00 00 00       	mov    $0x6,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <exec>:
SYSCALL(exec)
 2df:	b8 07 00 00 00       	mov    $0x7,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <open>:
SYSCALL(open)
 2e7:	b8 0f 00 00 00       	mov    $0xf,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <mknod>:
SYSCALL(mknod)
 2ef:	b8 11 00 00 00       	mov    $0x11,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <unlink>:
SYSCALL(unlink)
 2f7:	b8 12 00 00 00       	mov    $0x12,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <fstat>:
SYSCALL(fstat)
 2ff:	b8 08 00 00 00       	mov    $0x8,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <link>:
SYSCALL(link)
 307:	b8 13 00 00 00       	mov    $0x13,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <mkdir>:
SYSCALL(mkdir)
 30f:	b8 14 00 00 00       	mov    $0x14,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <chdir>:
SYSCALL(chdir)
 317:	b8 09 00 00 00       	mov    $0x9,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <dup>:
SYSCALL(dup)
 31f:	b8 0a 00 00 00       	mov    $0xa,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <getpid>:
SYSCALL(getpid)
 327:	b8 0b 00 00 00       	mov    $0xb,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <sbrk>:
SYSCALL(sbrk)
 32f:	b8 0c 00 00 00       	mov    $0xc,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	ret    

00000337 <sleep>:
SYSCALL(sleep)
 337:	b8 0d 00 00 00       	mov    $0xd,%eax
 33c:	cd 40                	int    $0x40
 33e:	c3                   	ret    

0000033f <uptime>:
SYSCALL(uptime)
 33f:	b8 0e 00 00 00       	mov    $0xe,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	ret    

00000347 <exit2>:
SYSCALL(exit2)
 347:	b8 16 00 00 00       	mov    $0x16,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <wait2>:
SYSCALL(wait2)
 34f:	b8 17 00 00 00       	mov    $0x17,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	ret    

00000357 <uthread_init>:
SYSCALL(uthread_init)
 357:	b8 18 00 00 00       	mov    $0x18,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	ret    

0000035f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 35f:	f3 0f 1e fb          	endbr32 
 363:	55                   	push   %ebp
 364:	89 e5                	mov    %esp,%ebp
 366:	83 ec 18             	sub    $0x18,%esp
 369:	8b 45 0c             	mov    0xc(%ebp),%eax
 36c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 36f:	83 ec 04             	sub    $0x4,%esp
 372:	6a 01                	push   $0x1
 374:	8d 45 f4             	lea    -0xc(%ebp),%eax
 377:	50                   	push   %eax
 378:	ff 75 08             	pushl  0x8(%ebp)
 37b:	e8 47 ff ff ff       	call   2c7 <write>
 380:	83 c4 10             	add    $0x10,%esp
}
 383:	90                   	nop
 384:	c9                   	leave  
 385:	c3                   	ret    

00000386 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 386:	f3 0f 1e fb          	endbr32 
 38a:	55                   	push   %ebp
 38b:	89 e5                	mov    %esp,%ebp
 38d:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 390:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 397:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 39b:	74 17                	je     3b4 <printint+0x2e>
 39d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3a1:	79 11                	jns    3b4 <printint+0x2e>
    neg = 1;
 3a3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ad:	f7 d8                	neg    %eax
 3af:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3b2:	eb 06                	jmp    3ba <printint+0x34>
  } else {
    x = xx;
 3b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3c7:	ba 00 00 00 00       	mov    $0x0,%edx
 3cc:	f7 f1                	div    %ecx
 3ce:	89 d1                	mov    %edx,%ecx
 3d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d3:	8d 50 01             	lea    0x1(%eax),%edx
 3d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3d9:	0f b6 91 5c 0a 00 00 	movzbl 0xa5c(%ecx),%edx
 3e0:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ea:	ba 00 00 00 00       	mov    $0x0,%edx
 3ef:	f7 f1                	div    %ecx
 3f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3f8:	75 c7                	jne    3c1 <printint+0x3b>
  if(neg)
 3fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3fe:	74 2d                	je     42d <printint+0xa7>
    buf[i++] = '-';
 400:	8b 45 f4             	mov    -0xc(%ebp),%eax
 403:	8d 50 01             	lea    0x1(%eax),%edx
 406:	89 55 f4             	mov    %edx,-0xc(%ebp)
 409:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 40e:	eb 1d                	jmp    42d <printint+0xa7>
    putc(fd, buf[i]);
 410:	8d 55 dc             	lea    -0x24(%ebp),%edx
 413:	8b 45 f4             	mov    -0xc(%ebp),%eax
 416:	01 d0                	add    %edx,%eax
 418:	0f b6 00             	movzbl (%eax),%eax
 41b:	0f be c0             	movsbl %al,%eax
 41e:	83 ec 08             	sub    $0x8,%esp
 421:	50                   	push   %eax
 422:	ff 75 08             	pushl  0x8(%ebp)
 425:	e8 35 ff ff ff       	call   35f <putc>
 42a:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 42d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 431:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 435:	79 d9                	jns    410 <printint+0x8a>
}
 437:	90                   	nop
 438:	90                   	nop
 439:	c9                   	leave  
 43a:	c3                   	ret    

0000043b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 43b:	f3 0f 1e fb          	endbr32 
 43f:	55                   	push   %ebp
 440:	89 e5                	mov    %esp,%ebp
 442:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 445:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 44c:	8d 45 0c             	lea    0xc(%ebp),%eax
 44f:	83 c0 04             	add    $0x4,%eax
 452:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 455:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 45c:	e9 59 01 00 00       	jmp    5ba <printf+0x17f>
    c = fmt[i] & 0xff;
 461:	8b 55 0c             	mov    0xc(%ebp),%edx
 464:	8b 45 f0             	mov    -0x10(%ebp),%eax
 467:	01 d0                	add    %edx,%eax
 469:	0f b6 00             	movzbl (%eax),%eax
 46c:	0f be c0             	movsbl %al,%eax
 46f:	25 ff 00 00 00       	and    $0xff,%eax
 474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 477:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 47b:	75 2c                	jne    4a9 <printf+0x6e>
      if(c == '%'){
 47d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 481:	75 0c                	jne    48f <printf+0x54>
        state = '%';
 483:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 48a:	e9 27 01 00 00       	jmp    5b6 <printf+0x17b>
      } else {
        putc(fd, c);
 48f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 492:	0f be c0             	movsbl %al,%eax
 495:	83 ec 08             	sub    $0x8,%esp
 498:	50                   	push   %eax
 499:	ff 75 08             	pushl  0x8(%ebp)
 49c:	e8 be fe ff ff       	call   35f <putc>
 4a1:	83 c4 10             	add    $0x10,%esp
 4a4:	e9 0d 01 00 00       	jmp    5b6 <printf+0x17b>
      }
    } else if(state == '%'){
 4a9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ad:	0f 85 03 01 00 00    	jne    5b6 <printf+0x17b>
      if(c == 'd'){
 4b3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4b7:	75 1e                	jne    4d7 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4bc:	8b 00                	mov    (%eax),%eax
 4be:	6a 01                	push   $0x1
 4c0:	6a 0a                	push   $0xa
 4c2:	50                   	push   %eax
 4c3:	ff 75 08             	pushl  0x8(%ebp)
 4c6:	e8 bb fe ff ff       	call   386 <printint>
 4cb:	83 c4 10             	add    $0x10,%esp
        ap++;
 4ce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4d2:	e9 d8 00 00 00       	jmp    5af <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 4d7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4db:	74 06                	je     4e3 <printf+0xa8>
 4dd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4e1:	75 1e                	jne    501 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 4e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e6:	8b 00                	mov    (%eax),%eax
 4e8:	6a 00                	push   $0x0
 4ea:	6a 10                	push   $0x10
 4ec:	50                   	push   %eax
 4ed:	ff 75 08             	pushl  0x8(%ebp)
 4f0:	e8 91 fe ff ff       	call   386 <printint>
 4f5:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4fc:	e9 ae 00 00 00       	jmp    5af <printf+0x174>
      } else if(c == 's'){
 501:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 505:	75 43                	jne    54a <printf+0x10f>
        s = (char*)*ap;
 507:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50a:	8b 00                	mov    (%eax),%eax
 50c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 50f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 513:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 517:	75 25                	jne    53e <printf+0x103>
          s = "(null)";
 519:	c7 45 f4 10 08 00 00 	movl   $0x810,-0xc(%ebp)
        while(*s != 0){
 520:	eb 1c                	jmp    53e <printf+0x103>
          putc(fd, *s);
 522:	8b 45 f4             	mov    -0xc(%ebp),%eax
 525:	0f b6 00             	movzbl (%eax),%eax
 528:	0f be c0             	movsbl %al,%eax
 52b:	83 ec 08             	sub    $0x8,%esp
 52e:	50                   	push   %eax
 52f:	ff 75 08             	pushl  0x8(%ebp)
 532:	e8 28 fe ff ff       	call   35f <putc>
 537:	83 c4 10             	add    $0x10,%esp
          s++;
 53a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 53e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 541:	0f b6 00             	movzbl (%eax),%eax
 544:	84 c0                	test   %al,%al
 546:	75 da                	jne    522 <printf+0xe7>
 548:	eb 65                	jmp    5af <printf+0x174>
        }
      } else if(c == 'c'){
 54a:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 54e:	75 1d                	jne    56d <printf+0x132>
        putc(fd, *ap);
 550:	8b 45 e8             	mov    -0x18(%ebp),%eax
 553:	8b 00                	mov    (%eax),%eax
 555:	0f be c0             	movsbl %al,%eax
 558:	83 ec 08             	sub    $0x8,%esp
 55b:	50                   	push   %eax
 55c:	ff 75 08             	pushl  0x8(%ebp)
 55f:	e8 fb fd ff ff       	call   35f <putc>
 564:	83 c4 10             	add    $0x10,%esp
        ap++;
 567:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 56b:	eb 42                	jmp    5af <printf+0x174>
      } else if(c == '%'){
 56d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 571:	75 17                	jne    58a <printf+0x14f>
        putc(fd, c);
 573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 576:	0f be c0             	movsbl %al,%eax
 579:	83 ec 08             	sub    $0x8,%esp
 57c:	50                   	push   %eax
 57d:	ff 75 08             	pushl  0x8(%ebp)
 580:	e8 da fd ff ff       	call   35f <putc>
 585:	83 c4 10             	add    $0x10,%esp
 588:	eb 25                	jmp    5af <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 58a:	83 ec 08             	sub    $0x8,%esp
 58d:	6a 25                	push   $0x25
 58f:	ff 75 08             	pushl  0x8(%ebp)
 592:	e8 c8 fd ff ff       	call   35f <putc>
 597:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 59a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59d:	0f be c0             	movsbl %al,%eax
 5a0:	83 ec 08             	sub    $0x8,%esp
 5a3:	50                   	push   %eax
 5a4:	ff 75 08             	pushl  0x8(%ebp)
 5a7:	e8 b3 fd ff ff       	call   35f <putc>
 5ac:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5b6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ba:	8b 55 0c             	mov    0xc(%ebp),%edx
 5bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5c0:	01 d0                	add    %edx,%eax
 5c2:	0f b6 00             	movzbl (%eax),%eax
 5c5:	84 c0                	test   %al,%al
 5c7:	0f 85 94 fe ff ff    	jne    461 <printf+0x26>
    }
  }
}
 5cd:	90                   	nop
 5ce:	90                   	nop
 5cf:	c9                   	leave  
 5d0:	c3                   	ret    

000005d1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5d1:	f3 0f 1e fb          	endbr32 
 5d5:	55                   	push   %ebp
 5d6:	89 e5                	mov    %esp,%ebp
 5d8:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5db:	8b 45 08             	mov    0x8(%ebp),%eax
 5de:	83 e8 08             	sub    $0x8,%eax
 5e1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e4:	a1 78 0a 00 00       	mov    0xa78,%eax
 5e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5ec:	eb 24                	jmp    612 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f1:	8b 00                	mov    (%eax),%eax
 5f3:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5f6:	72 12                	jb     60a <free+0x39>
 5f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5fb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5fe:	77 24                	ja     624 <free+0x53>
 600:	8b 45 fc             	mov    -0x4(%ebp),%eax
 603:	8b 00                	mov    (%eax),%eax
 605:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 608:	72 1a                	jb     624 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 60a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60d:	8b 00                	mov    (%eax),%eax
 60f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 612:	8b 45 f8             	mov    -0x8(%ebp),%eax
 615:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 618:	76 d4                	jbe    5ee <free+0x1d>
 61a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61d:	8b 00                	mov    (%eax),%eax
 61f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 622:	73 ca                	jae    5ee <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 624:	8b 45 f8             	mov    -0x8(%ebp),%eax
 627:	8b 40 04             	mov    0x4(%eax),%eax
 62a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 631:	8b 45 f8             	mov    -0x8(%ebp),%eax
 634:	01 c2                	add    %eax,%edx
 636:	8b 45 fc             	mov    -0x4(%ebp),%eax
 639:	8b 00                	mov    (%eax),%eax
 63b:	39 c2                	cmp    %eax,%edx
 63d:	75 24                	jne    663 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 63f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 642:	8b 50 04             	mov    0x4(%eax),%edx
 645:	8b 45 fc             	mov    -0x4(%ebp),%eax
 648:	8b 00                	mov    (%eax),%eax
 64a:	8b 40 04             	mov    0x4(%eax),%eax
 64d:	01 c2                	add    %eax,%edx
 64f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 652:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	8b 00                	mov    (%eax),%eax
 65a:	8b 10                	mov    (%eax),%edx
 65c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65f:	89 10                	mov    %edx,(%eax)
 661:	eb 0a                	jmp    66d <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 663:	8b 45 fc             	mov    -0x4(%ebp),%eax
 666:	8b 10                	mov    (%eax),%edx
 668:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66b:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 66d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 670:	8b 40 04             	mov    0x4(%eax),%eax
 673:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 67a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67d:	01 d0                	add    %edx,%eax
 67f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 682:	75 20                	jne    6a4 <free+0xd3>
    p->s.size += bp->s.size;
 684:	8b 45 fc             	mov    -0x4(%ebp),%eax
 687:	8b 50 04             	mov    0x4(%eax),%edx
 68a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68d:	8b 40 04             	mov    0x4(%eax),%eax
 690:	01 c2                	add    %eax,%edx
 692:	8b 45 fc             	mov    -0x4(%ebp),%eax
 695:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 698:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69b:	8b 10                	mov    (%eax),%edx
 69d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a0:	89 10                	mov    %edx,(%eax)
 6a2:	eb 08                	jmp    6ac <free+0xdb>
  } else
    p->s.ptr = bp;
 6a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6aa:	89 10                	mov    %edx,(%eax)
  freep = p;
 6ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6af:	a3 78 0a 00 00       	mov    %eax,0xa78
}
 6b4:	90                   	nop
 6b5:	c9                   	leave  
 6b6:	c3                   	ret    

000006b7 <morecore>:

static Header*
morecore(uint nu)
{
 6b7:	f3 0f 1e fb          	endbr32 
 6bb:	55                   	push   %ebp
 6bc:	89 e5                	mov    %esp,%ebp
 6be:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6c1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6c8:	77 07                	ja     6d1 <morecore+0x1a>
    nu = 4096;
 6ca:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6d1:	8b 45 08             	mov    0x8(%ebp),%eax
 6d4:	c1 e0 03             	shl    $0x3,%eax
 6d7:	83 ec 0c             	sub    $0xc,%esp
 6da:	50                   	push   %eax
 6db:	e8 4f fc ff ff       	call   32f <sbrk>
 6e0:	83 c4 10             	add    $0x10,%esp
 6e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6e6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6ea:	75 07                	jne    6f3 <morecore+0x3c>
    return 0;
 6ec:	b8 00 00 00 00       	mov    $0x0,%eax
 6f1:	eb 26                	jmp    719 <morecore+0x62>
  hp = (Header*)p;
 6f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6fc:	8b 55 08             	mov    0x8(%ebp),%edx
 6ff:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 702:	8b 45 f0             	mov    -0x10(%ebp),%eax
 705:	83 c0 08             	add    $0x8,%eax
 708:	83 ec 0c             	sub    $0xc,%esp
 70b:	50                   	push   %eax
 70c:	e8 c0 fe ff ff       	call   5d1 <free>
 711:	83 c4 10             	add    $0x10,%esp
  return freep;
 714:	a1 78 0a 00 00       	mov    0xa78,%eax
}
 719:	c9                   	leave  
 71a:	c3                   	ret    

0000071b <malloc>:

void*
malloc(uint nbytes)
{
 71b:	f3 0f 1e fb          	endbr32 
 71f:	55                   	push   %ebp
 720:	89 e5                	mov    %esp,%ebp
 722:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 725:	8b 45 08             	mov    0x8(%ebp),%eax
 728:	83 c0 07             	add    $0x7,%eax
 72b:	c1 e8 03             	shr    $0x3,%eax
 72e:	83 c0 01             	add    $0x1,%eax
 731:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 734:	a1 78 0a 00 00       	mov    0xa78,%eax
 739:	89 45 f0             	mov    %eax,-0x10(%ebp)
 73c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 740:	75 23                	jne    765 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 742:	c7 45 f0 70 0a 00 00 	movl   $0xa70,-0x10(%ebp)
 749:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74c:	a3 78 0a 00 00       	mov    %eax,0xa78
 751:	a1 78 0a 00 00       	mov    0xa78,%eax
 756:	a3 70 0a 00 00       	mov    %eax,0xa70
    base.s.size = 0;
 75b:	c7 05 74 0a 00 00 00 	movl   $0x0,0xa74
 762:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 765:	8b 45 f0             	mov    -0x10(%ebp),%eax
 768:	8b 00                	mov    (%eax),%eax
 76a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 76d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 770:	8b 40 04             	mov    0x4(%eax),%eax
 773:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 776:	77 4d                	ja     7c5 <malloc+0xaa>
      if(p->s.size == nunits)
 778:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77b:	8b 40 04             	mov    0x4(%eax),%eax
 77e:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 781:	75 0c                	jne    78f <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 783:	8b 45 f4             	mov    -0xc(%ebp),%eax
 786:	8b 10                	mov    (%eax),%edx
 788:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78b:	89 10                	mov    %edx,(%eax)
 78d:	eb 26                	jmp    7b5 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 78f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 792:	8b 40 04             	mov    0x4(%eax),%eax
 795:	2b 45 ec             	sub    -0x14(%ebp),%eax
 798:	89 c2                	mov    %eax,%edx
 79a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a3:	8b 40 04             	mov    0x4(%eax),%eax
 7a6:	c1 e0 03             	shl    $0x3,%eax
 7a9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7af:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7b2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b8:	a3 78 0a 00 00       	mov    %eax,0xa78
      return (void*)(p + 1);
 7bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c0:	83 c0 08             	add    $0x8,%eax
 7c3:	eb 3b                	jmp    800 <malloc+0xe5>
    }
    if(p == freep)
 7c5:	a1 78 0a 00 00       	mov    0xa78,%eax
 7ca:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7cd:	75 1e                	jne    7ed <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 7cf:	83 ec 0c             	sub    $0xc,%esp
 7d2:	ff 75 ec             	pushl  -0x14(%ebp)
 7d5:	e8 dd fe ff ff       	call   6b7 <morecore>
 7da:	83 c4 10             	add    $0x10,%esp
 7dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e4:	75 07                	jne    7ed <malloc+0xd2>
        return 0;
 7e6:	b8 00 00 00 00       	mov    $0x0,%eax
 7eb:	eb 13                	jmp    800 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f6:	8b 00                	mov    (%eax),%eax
 7f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7fb:	e9 6d ff ff ff       	jmp    76d <malloc+0x52>
  }
}
 800:	c9                   	leave  
 801:	c3                   	ret    
