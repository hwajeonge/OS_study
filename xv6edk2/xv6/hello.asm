
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
  18:	68 0a 08 00 00       	push   $0x80a
  1d:	6a 01                	push   $0x1
  1f:	e8 1f 04 00 00       	call   443 <printf>
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

0000035f <printpt>:
SYSCALL(printpt)
 35f:	b8 19 00 00 00       	mov    $0x19,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 367:	f3 0f 1e fb          	endbr32 
 36b:	55                   	push   %ebp
 36c:	89 e5                	mov    %esp,%ebp
 36e:	83 ec 18             	sub    $0x18,%esp
 371:	8b 45 0c             	mov    0xc(%ebp),%eax
 374:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 377:	83 ec 04             	sub    $0x4,%esp
 37a:	6a 01                	push   $0x1
 37c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 37f:	50                   	push   %eax
 380:	ff 75 08             	pushl  0x8(%ebp)
 383:	e8 3f ff ff ff       	call   2c7 <write>
 388:	83 c4 10             	add    $0x10,%esp
}
 38b:	90                   	nop
 38c:	c9                   	leave  
 38d:	c3                   	ret    

0000038e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 38e:	f3 0f 1e fb          	endbr32 
 392:	55                   	push   %ebp
 393:	89 e5                	mov    %esp,%ebp
 395:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 398:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 39f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3a3:	74 17                	je     3bc <printint+0x2e>
 3a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3a9:	79 11                	jns    3bc <printint+0x2e>
    neg = 1;
 3ab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b5:	f7 d8                	neg    %eax
 3b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ba:	eb 06                	jmp    3c2 <printint+0x34>
  } else {
    x = xx;
 3bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3cf:	ba 00 00 00 00       	mov    $0x0,%edx
 3d4:	f7 f1                	div    %ecx
 3d6:	89 d1                	mov    %edx,%ecx
 3d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3db:	8d 50 01             	lea    0x1(%eax),%edx
 3de:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3e1:	0f b6 91 64 0a 00 00 	movzbl 0xa64(%ecx),%edx
 3e8:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 3ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f2:	ba 00 00 00 00       	mov    $0x0,%edx
 3f7:	f7 f1                	div    %ecx
 3f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 400:	75 c7                	jne    3c9 <printint+0x3b>
  if(neg)
 402:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 406:	74 2d                	je     435 <printint+0xa7>
    buf[i++] = '-';
 408:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40b:	8d 50 01             	lea    0x1(%eax),%edx
 40e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 411:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 416:	eb 1d                	jmp    435 <printint+0xa7>
    putc(fd, buf[i]);
 418:	8d 55 dc             	lea    -0x24(%ebp),%edx
 41b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41e:	01 d0                	add    %edx,%eax
 420:	0f b6 00             	movzbl (%eax),%eax
 423:	0f be c0             	movsbl %al,%eax
 426:	83 ec 08             	sub    $0x8,%esp
 429:	50                   	push   %eax
 42a:	ff 75 08             	pushl  0x8(%ebp)
 42d:	e8 35 ff ff ff       	call   367 <putc>
 432:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 435:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 439:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 43d:	79 d9                	jns    418 <printint+0x8a>
}
 43f:	90                   	nop
 440:	90                   	nop
 441:	c9                   	leave  
 442:	c3                   	ret    

00000443 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 443:	f3 0f 1e fb          	endbr32 
 447:	55                   	push   %ebp
 448:	89 e5                	mov    %esp,%ebp
 44a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 44d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 454:	8d 45 0c             	lea    0xc(%ebp),%eax
 457:	83 c0 04             	add    $0x4,%eax
 45a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 45d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 464:	e9 59 01 00 00       	jmp    5c2 <printf+0x17f>
    c = fmt[i] & 0xff;
 469:	8b 55 0c             	mov    0xc(%ebp),%edx
 46c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 46f:	01 d0                	add    %edx,%eax
 471:	0f b6 00             	movzbl (%eax),%eax
 474:	0f be c0             	movsbl %al,%eax
 477:	25 ff 00 00 00       	and    $0xff,%eax
 47c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 47f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 483:	75 2c                	jne    4b1 <printf+0x6e>
      if(c == '%'){
 485:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 489:	75 0c                	jne    497 <printf+0x54>
        state = '%';
 48b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 492:	e9 27 01 00 00       	jmp    5be <printf+0x17b>
      } else {
        putc(fd, c);
 497:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 49a:	0f be c0             	movsbl %al,%eax
 49d:	83 ec 08             	sub    $0x8,%esp
 4a0:	50                   	push   %eax
 4a1:	ff 75 08             	pushl  0x8(%ebp)
 4a4:	e8 be fe ff ff       	call   367 <putc>
 4a9:	83 c4 10             	add    $0x10,%esp
 4ac:	e9 0d 01 00 00       	jmp    5be <printf+0x17b>
      }
    } else if(state == '%'){
 4b1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4b5:	0f 85 03 01 00 00    	jne    5be <printf+0x17b>
      if(c == 'd'){
 4bb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4bf:	75 1e                	jne    4df <printf+0x9c>
        printint(fd, *ap, 10, 1);
 4c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4c4:	8b 00                	mov    (%eax),%eax
 4c6:	6a 01                	push   $0x1
 4c8:	6a 0a                	push   $0xa
 4ca:	50                   	push   %eax
 4cb:	ff 75 08             	pushl  0x8(%ebp)
 4ce:	e8 bb fe ff ff       	call   38e <printint>
 4d3:	83 c4 10             	add    $0x10,%esp
        ap++;
 4d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4da:	e9 d8 00 00 00       	jmp    5b7 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 4df:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4e3:	74 06                	je     4eb <printf+0xa8>
 4e5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4e9:	75 1e                	jne    509 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 4eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ee:	8b 00                	mov    (%eax),%eax
 4f0:	6a 00                	push   $0x0
 4f2:	6a 10                	push   $0x10
 4f4:	50                   	push   %eax
 4f5:	ff 75 08             	pushl  0x8(%ebp)
 4f8:	e8 91 fe ff ff       	call   38e <printint>
 4fd:	83 c4 10             	add    $0x10,%esp
        ap++;
 500:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 504:	e9 ae 00 00 00       	jmp    5b7 <printf+0x174>
      } else if(c == 's'){
 509:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 50d:	75 43                	jne    552 <printf+0x10f>
        s = (char*)*ap;
 50f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 512:	8b 00                	mov    (%eax),%eax
 514:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 517:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 51b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 51f:	75 25                	jne    546 <printf+0x103>
          s = "(null)";
 521:	c7 45 f4 18 08 00 00 	movl   $0x818,-0xc(%ebp)
        while(*s != 0){
 528:	eb 1c                	jmp    546 <printf+0x103>
          putc(fd, *s);
 52a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 52d:	0f b6 00             	movzbl (%eax),%eax
 530:	0f be c0             	movsbl %al,%eax
 533:	83 ec 08             	sub    $0x8,%esp
 536:	50                   	push   %eax
 537:	ff 75 08             	pushl  0x8(%ebp)
 53a:	e8 28 fe ff ff       	call   367 <putc>
 53f:	83 c4 10             	add    $0x10,%esp
          s++;
 542:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 546:	8b 45 f4             	mov    -0xc(%ebp),%eax
 549:	0f b6 00             	movzbl (%eax),%eax
 54c:	84 c0                	test   %al,%al
 54e:	75 da                	jne    52a <printf+0xe7>
 550:	eb 65                	jmp    5b7 <printf+0x174>
        }
      } else if(c == 'c'){
 552:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 556:	75 1d                	jne    575 <printf+0x132>
        putc(fd, *ap);
 558:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55b:	8b 00                	mov    (%eax),%eax
 55d:	0f be c0             	movsbl %al,%eax
 560:	83 ec 08             	sub    $0x8,%esp
 563:	50                   	push   %eax
 564:	ff 75 08             	pushl  0x8(%ebp)
 567:	e8 fb fd ff ff       	call   367 <putc>
 56c:	83 c4 10             	add    $0x10,%esp
        ap++;
 56f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 573:	eb 42                	jmp    5b7 <printf+0x174>
      } else if(c == '%'){
 575:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 579:	75 17                	jne    592 <printf+0x14f>
        putc(fd, c);
 57b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57e:	0f be c0             	movsbl %al,%eax
 581:	83 ec 08             	sub    $0x8,%esp
 584:	50                   	push   %eax
 585:	ff 75 08             	pushl  0x8(%ebp)
 588:	e8 da fd ff ff       	call   367 <putc>
 58d:	83 c4 10             	add    $0x10,%esp
 590:	eb 25                	jmp    5b7 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 592:	83 ec 08             	sub    $0x8,%esp
 595:	6a 25                	push   $0x25
 597:	ff 75 08             	pushl  0x8(%ebp)
 59a:	e8 c8 fd ff ff       	call   367 <putc>
 59f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a5:	0f be c0             	movsbl %al,%eax
 5a8:	83 ec 08             	sub    $0x8,%esp
 5ab:	50                   	push   %eax
 5ac:	ff 75 08             	pushl  0x8(%ebp)
 5af:	e8 b3 fd ff ff       	call   367 <putc>
 5b4:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5b7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 5be:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5c2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5c8:	01 d0                	add    %edx,%eax
 5ca:	0f b6 00             	movzbl (%eax),%eax
 5cd:	84 c0                	test   %al,%al
 5cf:	0f 85 94 fe ff ff    	jne    469 <printf+0x26>
    }
  }
}
 5d5:	90                   	nop
 5d6:	90                   	nop
 5d7:	c9                   	leave  
 5d8:	c3                   	ret    

000005d9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5d9:	f3 0f 1e fb          	endbr32 
 5dd:	55                   	push   %ebp
 5de:	89 e5                	mov    %esp,%ebp
 5e0:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5e3:	8b 45 08             	mov    0x8(%ebp),%eax
 5e6:	83 e8 08             	sub    $0x8,%eax
 5e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5ec:	a1 80 0a 00 00       	mov    0xa80,%eax
 5f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f4:	eb 24                	jmp    61a <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f9:	8b 00                	mov    (%eax),%eax
 5fb:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 5fe:	72 12                	jb     612 <free+0x39>
 600:	8b 45 f8             	mov    -0x8(%ebp),%eax
 603:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 606:	77 24                	ja     62c <free+0x53>
 608:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60b:	8b 00                	mov    (%eax),%eax
 60d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 610:	72 1a                	jb     62c <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 612:	8b 45 fc             	mov    -0x4(%ebp),%eax
 615:	8b 00                	mov    (%eax),%eax
 617:	89 45 fc             	mov    %eax,-0x4(%ebp)
 61a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 620:	76 d4                	jbe    5f6 <free+0x1d>
 622:	8b 45 fc             	mov    -0x4(%ebp),%eax
 625:	8b 00                	mov    (%eax),%eax
 627:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 62a:	73 ca                	jae    5f6 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 62c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62f:	8b 40 04             	mov    0x4(%eax),%eax
 632:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 639:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63c:	01 c2                	add    %eax,%edx
 63e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 641:	8b 00                	mov    (%eax),%eax
 643:	39 c2                	cmp    %eax,%edx
 645:	75 24                	jne    66b <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 647:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64a:	8b 50 04             	mov    0x4(%eax),%edx
 64d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 650:	8b 00                	mov    (%eax),%eax
 652:	8b 40 04             	mov    0x4(%eax),%eax
 655:	01 c2                	add    %eax,%edx
 657:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65a:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 65d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 660:	8b 00                	mov    (%eax),%eax
 662:	8b 10                	mov    (%eax),%edx
 664:	8b 45 f8             	mov    -0x8(%ebp),%eax
 667:	89 10                	mov    %edx,(%eax)
 669:	eb 0a                	jmp    675 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 66b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66e:	8b 10                	mov    (%eax),%edx
 670:	8b 45 f8             	mov    -0x8(%ebp),%eax
 673:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	8b 40 04             	mov    0x4(%eax),%eax
 67b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 682:	8b 45 fc             	mov    -0x4(%ebp),%eax
 685:	01 d0                	add    %edx,%eax
 687:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 68a:	75 20                	jne    6ac <free+0xd3>
    p->s.size += bp->s.size;
 68c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68f:	8b 50 04             	mov    0x4(%eax),%edx
 692:	8b 45 f8             	mov    -0x8(%ebp),%eax
 695:	8b 40 04             	mov    0x4(%eax),%eax
 698:	01 c2                	add    %eax,%edx
 69a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a3:	8b 10                	mov    (%eax),%edx
 6a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a8:	89 10                	mov    %edx,(%eax)
 6aa:	eb 08                	jmp    6b4 <free+0xdb>
  } else
    p->s.ptr = bp;
 6ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6af:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6b2:	89 10                	mov    %edx,(%eax)
  freep = p;
 6b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b7:	a3 80 0a 00 00       	mov    %eax,0xa80
}
 6bc:	90                   	nop
 6bd:	c9                   	leave  
 6be:	c3                   	ret    

000006bf <morecore>:

static Header*
morecore(uint nu)
{
 6bf:	f3 0f 1e fb          	endbr32 
 6c3:	55                   	push   %ebp
 6c4:	89 e5                	mov    %esp,%ebp
 6c6:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6c9:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6d0:	77 07                	ja     6d9 <morecore+0x1a>
    nu = 4096;
 6d2:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6d9:	8b 45 08             	mov    0x8(%ebp),%eax
 6dc:	c1 e0 03             	shl    $0x3,%eax
 6df:	83 ec 0c             	sub    $0xc,%esp
 6e2:	50                   	push   %eax
 6e3:	e8 47 fc ff ff       	call   32f <sbrk>
 6e8:	83 c4 10             	add    $0x10,%esp
 6eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6ee:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6f2:	75 07                	jne    6fb <morecore+0x3c>
    return 0;
 6f4:	b8 00 00 00 00       	mov    $0x0,%eax
 6f9:	eb 26                	jmp    721 <morecore+0x62>
  hp = (Header*)p;
 6fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 701:	8b 45 f0             	mov    -0x10(%ebp),%eax
 704:	8b 55 08             	mov    0x8(%ebp),%edx
 707:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 70a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 70d:	83 c0 08             	add    $0x8,%eax
 710:	83 ec 0c             	sub    $0xc,%esp
 713:	50                   	push   %eax
 714:	e8 c0 fe ff ff       	call   5d9 <free>
 719:	83 c4 10             	add    $0x10,%esp
  return freep;
 71c:	a1 80 0a 00 00       	mov    0xa80,%eax
}
 721:	c9                   	leave  
 722:	c3                   	ret    

00000723 <malloc>:

void*
malloc(uint nbytes)
{
 723:	f3 0f 1e fb          	endbr32 
 727:	55                   	push   %ebp
 728:	89 e5                	mov    %esp,%ebp
 72a:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 72d:	8b 45 08             	mov    0x8(%ebp),%eax
 730:	83 c0 07             	add    $0x7,%eax
 733:	c1 e8 03             	shr    $0x3,%eax
 736:	83 c0 01             	add    $0x1,%eax
 739:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 73c:	a1 80 0a 00 00       	mov    0xa80,%eax
 741:	89 45 f0             	mov    %eax,-0x10(%ebp)
 744:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 748:	75 23                	jne    76d <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 74a:	c7 45 f0 78 0a 00 00 	movl   $0xa78,-0x10(%ebp)
 751:	8b 45 f0             	mov    -0x10(%ebp),%eax
 754:	a3 80 0a 00 00       	mov    %eax,0xa80
 759:	a1 80 0a 00 00       	mov    0xa80,%eax
 75e:	a3 78 0a 00 00       	mov    %eax,0xa78
    base.s.size = 0;
 763:	c7 05 7c 0a 00 00 00 	movl   $0x0,0xa7c
 76a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 76d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 770:	8b 00                	mov    (%eax),%eax
 772:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 775:	8b 45 f4             	mov    -0xc(%ebp),%eax
 778:	8b 40 04             	mov    0x4(%eax),%eax
 77b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 77e:	77 4d                	ja     7cd <malloc+0xaa>
      if(p->s.size == nunits)
 780:	8b 45 f4             	mov    -0xc(%ebp),%eax
 783:	8b 40 04             	mov    0x4(%eax),%eax
 786:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 789:	75 0c                	jne    797 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78e:	8b 10                	mov    (%eax),%edx
 790:	8b 45 f0             	mov    -0x10(%ebp),%eax
 793:	89 10                	mov    %edx,(%eax)
 795:	eb 26                	jmp    7bd <malloc+0x9a>
      else {
        p->s.size -= nunits;
 797:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79a:	8b 40 04             	mov    0x4(%eax),%eax
 79d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7a0:	89 c2                	mov    %eax,%edx
 7a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ab:	8b 40 04             	mov    0x4(%eax),%eax
 7ae:	c1 e0 03             	shl    $0x3,%eax
 7b1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7ba:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c0:	a3 80 0a 00 00       	mov    %eax,0xa80
      return (void*)(p + 1);
 7c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c8:	83 c0 08             	add    $0x8,%eax
 7cb:	eb 3b                	jmp    808 <malloc+0xe5>
    }
    if(p == freep)
 7cd:	a1 80 0a 00 00       	mov    0xa80,%eax
 7d2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7d5:	75 1e                	jne    7f5 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 7d7:	83 ec 0c             	sub    $0xc,%esp
 7da:	ff 75 ec             	pushl  -0x14(%ebp)
 7dd:	e8 dd fe ff ff       	call   6bf <morecore>
 7e2:	83 c4 10             	add    $0x10,%esp
 7e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ec:	75 07                	jne    7f5 <malloc+0xd2>
        return 0;
 7ee:	b8 00 00 00 00       	mov    $0x0,%eax
 7f3:	eb 13                	jmp    808 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fe:	8b 00                	mov    (%eax),%eax
 800:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 803:	e9 6d ff ff ff       	jmp    775 <malloc+0x52>
  }
}
 808:	c9                   	leave  
 809:	c3                   	ret    
