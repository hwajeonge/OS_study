
_recurse:     file format elf32-i386


Disassembly of section .text:

00000000 <recurse>:

// Prevent this function from being optimized which might give it closed form
#pragma GCC push_options
#pragma GCC optimize ("O0")

static int recurse(int n) {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 08             	sub    $0x8,%esp
    if(n == 0)
   a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   e:	75 07                	jne    17 <recurse+0x17>
        return 0;
  10:	b8 00 00 00 00       	mov    $0x0,%eax
  15:	eb 17                	jmp    2e <recurse+0x2e>
    return n + recurse(n - 1);
  17:	8b 45 08             	mov    0x8(%ebp),%eax
  1a:	83 e8 01             	sub    $0x1,%eax
  1d:	83 ec 0c             	sub    $0xc,%esp
  20:	50                   	push   %eax
  21:	e8 da ff ff ff       	call   0 <recurse>
  26:	83 c4 10             	add    $0x10,%esp
  29:	8b 55 08             	mov    0x8(%ebp),%edx
  2c:	01 d0                	add    %edx,%eax
}
  2e:	c9                   	leave  
  2f:	c3                   	ret    

00000030 <main>:

#pragma GCC pop_options

int main(int argc, char *argv[]) {
  30:	f3 0f 1e fb          	endbr32 
  34:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  38:	83 e4 f0             	and    $0xfffffff0,%esp
  3b:	ff 71 fc             	pushl  -0x4(%ecx)
  3e:	55                   	push   %ebp
  3f:	89 e5                	mov    %esp,%ebp
  41:	51                   	push   %ecx
  42:	83 ec 14             	sub    $0x14,%esp
  45:	89 c8                	mov    %ecx,%eax
    int n, m;

    if(argc != 2){
  47:	83 38 02             	cmpl   $0x2,(%eax)
  4a:	74 1d                	je     69 <main+0x39>
        printf(1, "Usage: %s levels\n", argv[0]);
  4c:	8b 40 04             	mov    0x4(%eax),%eax
  4f:	8b 00                	mov    (%eax),%eax
  51:	83 ec 04             	sub    $0x4,%esp
  54:	50                   	push   %eax
  55:	68 9e 08 00 00       	push   $0x89e
  5a:	6a 01                	push   $0x1
  5c:	e8 76 04 00 00       	call   4d7 <printf>
  61:	83 c4 10             	add    $0x10,%esp
        exit();
  64:	e8 d2 02 00 00       	call   33b <exit>
    }

    //printpt(getpid()); // Uncomment for the test.
    n = atoi(argv[1]);
  69:	8b 40 04             	mov    0x4(%eax),%eax
  6c:	83 c0 04             	add    $0x4,%eax
  6f:	8b 00                	mov    (%eax),%eax
  71:	83 ec 0c             	sub    $0xc,%esp
  74:	50                   	push   %eax
  75:	e8 27 02 00 00       	call   2a1 <atoi>
  7a:	83 c4 10             	add    $0x10,%esp
  7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    printf(1, "Recursing %d levels\n", n);
  80:	83 ec 04             	sub    $0x4,%esp
  83:	ff 75 f4             	pushl  -0xc(%ebp)
  86:	68 b0 08 00 00       	push   $0x8b0
  8b:	6a 01                	push   $0x1
  8d:	e8 45 04 00 00       	call   4d7 <printf>
  92:	83 c4 10             	add    $0x10,%esp
    m = recurse(n);
  95:	83 ec 0c             	sub    $0xc,%esp
  98:	ff 75 f4             	pushl  -0xc(%ebp)
  9b:	e8 60 ff ff ff       	call   0 <recurse>
  a0:	83 c4 10             	add    $0x10,%esp
  a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    printf(1, "Yielded a value of %d\n", m);
  a6:	83 ec 04             	sub    $0x4,%esp
  a9:	ff 75 f0             	pushl  -0x10(%ebp)
  ac:	68 c5 08 00 00       	push   $0x8c5
  b1:	6a 01                	push   $0x1
  b3:	e8 1f 04 00 00       	call   4d7 <printf>
  b8:	83 c4 10             	add    $0x10,%esp

    //printpt(getpid()); // Uncomment for the test.
    exit();
  bb:	e8 7b 02 00 00       	call   33b <exit>

000000c0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  c0:	55                   	push   %ebp
  c1:	89 e5                	mov    %esp,%ebp
  c3:	57                   	push   %edi
  c4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  c8:	8b 55 10             	mov    0x10(%ebp),%edx
  cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  ce:	89 cb                	mov    %ecx,%ebx
  d0:	89 df                	mov    %ebx,%edi
  d2:	89 d1                	mov    %edx,%ecx
  d4:	fc                   	cld    
  d5:	f3 aa                	rep stos %al,%es:(%edi)
  d7:	89 ca                	mov    %ecx,%edx
  d9:	89 fb                	mov    %edi,%ebx
  db:	89 5d 08             	mov    %ebx,0x8(%ebp)
  de:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  e1:	90                   	nop
  e2:	5b                   	pop    %ebx
  e3:	5f                   	pop    %edi
  e4:	5d                   	pop    %ebp
  e5:	c3                   	ret    

000000e6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  e6:	f3 0f 1e fb          	endbr32 
  ea:	55                   	push   %ebp
  eb:	89 e5                	mov    %esp,%ebp
  ed:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  f0:	8b 45 08             	mov    0x8(%ebp),%eax
  f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  f6:	90                   	nop
  f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  fa:	8d 42 01             	lea    0x1(%edx),%eax
  fd:	89 45 0c             	mov    %eax,0xc(%ebp)
 100:	8b 45 08             	mov    0x8(%ebp),%eax
 103:	8d 48 01             	lea    0x1(%eax),%ecx
 106:	89 4d 08             	mov    %ecx,0x8(%ebp)
 109:	0f b6 12             	movzbl (%edx),%edx
 10c:	88 10                	mov    %dl,(%eax)
 10e:	0f b6 00             	movzbl (%eax),%eax
 111:	84 c0                	test   %al,%al
 113:	75 e2                	jne    f7 <strcpy+0x11>
    ;
  return os;
 115:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 118:	c9                   	leave  
 119:	c3                   	ret    

0000011a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11a:	f3 0f 1e fb          	endbr32 
 11e:	55                   	push   %ebp
 11f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 121:	eb 08                	jmp    12b <strcmp+0x11>
    p++, q++;
 123:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 127:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 12b:	8b 45 08             	mov    0x8(%ebp),%eax
 12e:	0f b6 00             	movzbl (%eax),%eax
 131:	84 c0                	test   %al,%al
 133:	74 10                	je     145 <strcmp+0x2b>
 135:	8b 45 08             	mov    0x8(%ebp),%eax
 138:	0f b6 10             	movzbl (%eax),%edx
 13b:	8b 45 0c             	mov    0xc(%ebp),%eax
 13e:	0f b6 00             	movzbl (%eax),%eax
 141:	38 c2                	cmp    %al,%dl
 143:	74 de                	je     123 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 145:	8b 45 08             	mov    0x8(%ebp),%eax
 148:	0f b6 00             	movzbl (%eax),%eax
 14b:	0f b6 d0             	movzbl %al,%edx
 14e:	8b 45 0c             	mov    0xc(%ebp),%eax
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	0f b6 c0             	movzbl %al,%eax
 157:	29 c2                	sub    %eax,%edx
 159:	89 d0                	mov    %edx,%eax
}
 15b:	5d                   	pop    %ebp
 15c:	c3                   	ret    

0000015d <strlen>:

uint
strlen(char *s)
{
 15d:	f3 0f 1e fb          	endbr32 
 161:	55                   	push   %ebp
 162:	89 e5                	mov    %esp,%ebp
 164:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 167:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 16e:	eb 04                	jmp    174 <strlen+0x17>
 170:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 174:	8b 55 fc             	mov    -0x4(%ebp),%edx
 177:	8b 45 08             	mov    0x8(%ebp),%eax
 17a:	01 d0                	add    %edx,%eax
 17c:	0f b6 00             	movzbl (%eax),%eax
 17f:	84 c0                	test   %al,%al
 181:	75 ed                	jne    170 <strlen+0x13>
    ;
  return n;
 183:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 186:	c9                   	leave  
 187:	c3                   	ret    

00000188 <memset>:

void*
memset(void *dst, int c, uint n)
{
 188:	f3 0f 1e fb          	endbr32 
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 18f:	8b 45 10             	mov    0x10(%ebp),%eax
 192:	50                   	push   %eax
 193:	ff 75 0c             	pushl  0xc(%ebp)
 196:	ff 75 08             	pushl  0x8(%ebp)
 199:	e8 22 ff ff ff       	call   c0 <stosb>
 19e:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1a1:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1a4:	c9                   	leave  
 1a5:	c3                   	ret    

000001a6 <strchr>:

char*
strchr(const char *s, char c)
{
 1a6:	f3 0f 1e fb          	endbr32 
 1aa:	55                   	push   %ebp
 1ab:	89 e5                	mov    %esp,%ebp
 1ad:	83 ec 04             	sub    $0x4,%esp
 1b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b3:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1b6:	eb 14                	jmp    1cc <strchr+0x26>
    if(*s == c)
 1b8:	8b 45 08             	mov    0x8(%ebp),%eax
 1bb:	0f b6 00             	movzbl (%eax),%eax
 1be:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1c1:	75 05                	jne    1c8 <strchr+0x22>
      return (char*)s;
 1c3:	8b 45 08             	mov    0x8(%ebp),%eax
 1c6:	eb 13                	jmp    1db <strchr+0x35>
  for(; *s; s++)
 1c8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1cc:	8b 45 08             	mov    0x8(%ebp),%eax
 1cf:	0f b6 00             	movzbl (%eax),%eax
 1d2:	84 c0                	test   %al,%al
 1d4:	75 e2                	jne    1b8 <strchr+0x12>
  return 0;
 1d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1db:	c9                   	leave  
 1dc:	c3                   	ret    

000001dd <gets>:

char*
gets(char *buf, int max)
{
 1dd:	f3 0f 1e fb          	endbr32 
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1ee:	eb 42                	jmp    232 <gets+0x55>
    cc = read(0, &c, 1);
 1f0:	83 ec 04             	sub    $0x4,%esp
 1f3:	6a 01                	push   $0x1
 1f5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1f8:	50                   	push   %eax
 1f9:	6a 00                	push   $0x0
 1fb:	e8 53 01 00 00       	call   353 <read>
 200:	83 c4 10             	add    $0x10,%esp
 203:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 206:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 20a:	7e 33                	jle    23f <gets+0x62>
      break;
    buf[i++] = c;
 20c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 20f:	8d 50 01             	lea    0x1(%eax),%edx
 212:	89 55 f4             	mov    %edx,-0xc(%ebp)
 215:	89 c2                	mov    %eax,%edx
 217:	8b 45 08             	mov    0x8(%ebp),%eax
 21a:	01 c2                	add    %eax,%edx
 21c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 220:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 222:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 226:	3c 0a                	cmp    $0xa,%al
 228:	74 16                	je     240 <gets+0x63>
 22a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 22e:	3c 0d                	cmp    $0xd,%al
 230:	74 0e                	je     240 <gets+0x63>
  for(i=0; i+1 < max; ){
 232:	8b 45 f4             	mov    -0xc(%ebp),%eax
 235:	83 c0 01             	add    $0x1,%eax
 238:	39 45 0c             	cmp    %eax,0xc(%ebp)
 23b:	7f b3                	jg     1f0 <gets+0x13>
 23d:	eb 01                	jmp    240 <gets+0x63>
      break;
 23f:	90                   	nop
      break;
  }
  buf[i] = '\0';
 240:	8b 55 f4             	mov    -0xc(%ebp),%edx
 243:	8b 45 08             	mov    0x8(%ebp),%eax
 246:	01 d0                	add    %edx,%eax
 248:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 24b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 24e:	c9                   	leave  
 24f:	c3                   	ret    

00000250 <stat>:

int
stat(char *n, struct stat *st)
{
 250:	f3 0f 1e fb          	endbr32 
 254:	55                   	push   %ebp
 255:	89 e5                	mov    %esp,%ebp
 257:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25a:	83 ec 08             	sub    $0x8,%esp
 25d:	6a 00                	push   $0x0
 25f:	ff 75 08             	pushl  0x8(%ebp)
 262:	e8 14 01 00 00       	call   37b <open>
 267:	83 c4 10             	add    $0x10,%esp
 26a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 26d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 271:	79 07                	jns    27a <stat+0x2a>
    return -1;
 273:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 278:	eb 25                	jmp    29f <stat+0x4f>
  r = fstat(fd, st);
 27a:	83 ec 08             	sub    $0x8,%esp
 27d:	ff 75 0c             	pushl  0xc(%ebp)
 280:	ff 75 f4             	pushl  -0xc(%ebp)
 283:	e8 0b 01 00 00       	call   393 <fstat>
 288:	83 c4 10             	add    $0x10,%esp
 28b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 28e:	83 ec 0c             	sub    $0xc,%esp
 291:	ff 75 f4             	pushl  -0xc(%ebp)
 294:	e8 ca 00 00 00       	call   363 <close>
 299:	83 c4 10             	add    $0x10,%esp
  return r;
 29c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 29f:	c9                   	leave  
 2a0:	c3                   	ret    

000002a1 <atoi>:

int
atoi(const char *s)
{
 2a1:	f3 0f 1e fb          	endbr32 
 2a5:	55                   	push   %ebp
 2a6:	89 e5                	mov    %esp,%ebp
 2a8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2b2:	eb 25                	jmp    2d9 <atoi+0x38>
    n = n*10 + *s++ - '0';
 2b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2b7:	89 d0                	mov    %edx,%eax
 2b9:	c1 e0 02             	shl    $0x2,%eax
 2bc:	01 d0                	add    %edx,%eax
 2be:	01 c0                	add    %eax,%eax
 2c0:	89 c1                	mov    %eax,%ecx
 2c2:	8b 45 08             	mov    0x8(%ebp),%eax
 2c5:	8d 50 01             	lea    0x1(%eax),%edx
 2c8:	89 55 08             	mov    %edx,0x8(%ebp)
 2cb:	0f b6 00             	movzbl (%eax),%eax
 2ce:	0f be c0             	movsbl %al,%eax
 2d1:	01 c8                	add    %ecx,%eax
 2d3:	83 e8 30             	sub    $0x30,%eax
 2d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d9:	8b 45 08             	mov    0x8(%ebp),%eax
 2dc:	0f b6 00             	movzbl (%eax),%eax
 2df:	3c 2f                	cmp    $0x2f,%al
 2e1:	7e 0a                	jle    2ed <atoi+0x4c>
 2e3:	8b 45 08             	mov    0x8(%ebp),%eax
 2e6:	0f b6 00             	movzbl (%eax),%eax
 2e9:	3c 39                	cmp    $0x39,%al
 2eb:	7e c7                	jle    2b4 <atoi+0x13>
  return n;
 2ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2f0:	c9                   	leave  
 2f1:	c3                   	ret    

000002f2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2f2:	f3 0f 1e fb          	endbr32 
 2f6:	55                   	push   %ebp
 2f7:	89 e5                	mov    %esp,%ebp
 2f9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2fc:	8b 45 08             	mov    0x8(%ebp),%eax
 2ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 302:	8b 45 0c             	mov    0xc(%ebp),%eax
 305:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 308:	eb 17                	jmp    321 <memmove+0x2f>
    *dst++ = *src++;
 30a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 30d:	8d 42 01             	lea    0x1(%edx),%eax
 310:	89 45 f8             	mov    %eax,-0x8(%ebp)
 313:	8b 45 fc             	mov    -0x4(%ebp),%eax
 316:	8d 48 01             	lea    0x1(%eax),%ecx
 319:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 31c:	0f b6 12             	movzbl (%edx),%edx
 31f:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 321:	8b 45 10             	mov    0x10(%ebp),%eax
 324:	8d 50 ff             	lea    -0x1(%eax),%edx
 327:	89 55 10             	mov    %edx,0x10(%ebp)
 32a:	85 c0                	test   %eax,%eax
 32c:	7f dc                	jg     30a <memmove+0x18>
  return vdst;
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 331:	c9                   	leave  
 332:	c3                   	ret    

00000333 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 333:	b8 01 00 00 00       	mov    $0x1,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <exit>:
SYSCALL(exit)
 33b:	b8 02 00 00 00       	mov    $0x2,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <wait>:
SYSCALL(wait)
 343:	b8 03 00 00 00       	mov    $0x3,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <pipe>:
SYSCALL(pipe)
 34b:	b8 04 00 00 00       	mov    $0x4,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <read>:
SYSCALL(read)
 353:	b8 05 00 00 00       	mov    $0x5,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <write>:
SYSCALL(write)
 35b:	b8 10 00 00 00       	mov    $0x10,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <close>:
SYSCALL(close)
 363:	b8 15 00 00 00       	mov    $0x15,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <kill>:
SYSCALL(kill)
 36b:	b8 06 00 00 00       	mov    $0x6,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <exec>:
SYSCALL(exec)
 373:	b8 07 00 00 00       	mov    $0x7,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <open>:
SYSCALL(open)
 37b:	b8 0f 00 00 00       	mov    $0xf,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <mknod>:
SYSCALL(mknod)
 383:	b8 11 00 00 00       	mov    $0x11,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <unlink>:
SYSCALL(unlink)
 38b:	b8 12 00 00 00       	mov    $0x12,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    

00000393 <fstat>:
SYSCALL(fstat)
 393:	b8 08 00 00 00       	mov    $0x8,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret    

0000039b <link>:
SYSCALL(link)
 39b:	b8 13 00 00 00       	mov    $0x13,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret    

000003a3 <mkdir>:
SYSCALL(mkdir)
 3a3:	b8 14 00 00 00       	mov    $0x14,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	ret    

000003ab <chdir>:
SYSCALL(chdir)
 3ab:	b8 09 00 00 00       	mov    $0x9,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	ret    

000003b3 <dup>:
SYSCALL(dup)
 3b3:	b8 0a 00 00 00       	mov    $0xa,%eax
 3b8:	cd 40                	int    $0x40
 3ba:	c3                   	ret    

000003bb <getpid>:
SYSCALL(getpid)
 3bb:	b8 0b 00 00 00       	mov    $0xb,%eax
 3c0:	cd 40                	int    $0x40
 3c2:	c3                   	ret    

000003c3 <sbrk>:
SYSCALL(sbrk)
 3c3:	b8 0c 00 00 00       	mov    $0xc,%eax
 3c8:	cd 40                	int    $0x40
 3ca:	c3                   	ret    

000003cb <sleep>:
SYSCALL(sleep)
 3cb:	b8 0d 00 00 00       	mov    $0xd,%eax
 3d0:	cd 40                	int    $0x40
 3d2:	c3                   	ret    

000003d3 <uptime>:
SYSCALL(uptime)
 3d3:	b8 0e 00 00 00       	mov    $0xe,%eax
 3d8:	cd 40                	int    $0x40
 3da:	c3                   	ret    

000003db <exit2>:
SYSCALL(exit2)
 3db:	b8 16 00 00 00       	mov    $0x16,%eax
 3e0:	cd 40                	int    $0x40
 3e2:	c3                   	ret    

000003e3 <wait2>:
SYSCALL(wait2)
 3e3:	b8 17 00 00 00       	mov    $0x17,%eax
 3e8:	cd 40                	int    $0x40
 3ea:	c3                   	ret    

000003eb <uthread_init>:
SYSCALL(uthread_init)
 3eb:	b8 18 00 00 00       	mov    $0x18,%eax
 3f0:	cd 40                	int    $0x40
 3f2:	c3                   	ret    

000003f3 <printpt>:
SYSCALL(printpt)
 3f3:	b8 19 00 00 00       	mov    $0x19,%eax
 3f8:	cd 40                	int    $0x40
 3fa:	c3                   	ret    

000003fb <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3fb:	f3 0f 1e fb          	endbr32 
 3ff:	55                   	push   %ebp
 400:	89 e5                	mov    %esp,%ebp
 402:	83 ec 18             	sub    $0x18,%esp
 405:	8b 45 0c             	mov    0xc(%ebp),%eax
 408:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 40b:	83 ec 04             	sub    $0x4,%esp
 40e:	6a 01                	push   $0x1
 410:	8d 45 f4             	lea    -0xc(%ebp),%eax
 413:	50                   	push   %eax
 414:	ff 75 08             	pushl  0x8(%ebp)
 417:	e8 3f ff ff ff       	call   35b <write>
 41c:	83 c4 10             	add    $0x10,%esp
}
 41f:	90                   	nop
 420:	c9                   	leave  
 421:	c3                   	ret    

00000422 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 422:	f3 0f 1e fb          	endbr32 
 426:	55                   	push   %ebp
 427:	89 e5                	mov    %esp,%ebp
 429:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 42c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 433:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 437:	74 17                	je     450 <printint+0x2e>
 439:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 43d:	79 11                	jns    450 <printint+0x2e>
    neg = 1;
 43f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 446:	8b 45 0c             	mov    0xc(%ebp),%eax
 449:	f7 d8                	neg    %eax
 44b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 44e:	eb 06                	jmp    456 <printint+0x34>
  } else {
    x = xx;
 450:	8b 45 0c             	mov    0xc(%ebp),%eax
 453:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 456:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 45d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 460:	8b 45 ec             	mov    -0x14(%ebp),%eax
 463:	ba 00 00 00 00       	mov    $0x0,%edx
 468:	f7 f1                	div    %ecx
 46a:	89 d1                	mov    %edx,%ecx
 46c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 46f:	8d 50 01             	lea    0x1(%eax),%edx
 472:	89 55 f4             	mov    %edx,-0xc(%ebp)
 475:	0f b6 91 48 0b 00 00 	movzbl 0xb48(%ecx),%edx
 47c:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 480:	8b 4d 10             	mov    0x10(%ebp),%ecx
 483:	8b 45 ec             	mov    -0x14(%ebp),%eax
 486:	ba 00 00 00 00       	mov    $0x0,%edx
 48b:	f7 f1                	div    %ecx
 48d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 490:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 494:	75 c7                	jne    45d <printint+0x3b>
  if(neg)
 496:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 49a:	74 2d                	je     4c9 <printint+0xa7>
    buf[i++] = '-';
 49c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49f:	8d 50 01             	lea    0x1(%eax),%edx
 4a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4a5:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4aa:	eb 1d                	jmp    4c9 <printint+0xa7>
    putc(fd, buf[i]);
 4ac:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b2:	01 d0                	add    %edx,%eax
 4b4:	0f b6 00             	movzbl (%eax),%eax
 4b7:	0f be c0             	movsbl %al,%eax
 4ba:	83 ec 08             	sub    $0x8,%esp
 4bd:	50                   	push   %eax
 4be:	ff 75 08             	pushl  0x8(%ebp)
 4c1:	e8 35 ff ff ff       	call   3fb <putc>
 4c6:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4c9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d1:	79 d9                	jns    4ac <printint+0x8a>
}
 4d3:	90                   	nop
 4d4:	90                   	nop
 4d5:	c9                   	leave  
 4d6:	c3                   	ret    

000004d7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4d7:	f3 0f 1e fb          	endbr32 
 4db:	55                   	push   %ebp
 4dc:	89 e5                	mov    %esp,%ebp
 4de:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4e8:	8d 45 0c             	lea    0xc(%ebp),%eax
 4eb:	83 c0 04             	add    $0x4,%eax
 4ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4f8:	e9 59 01 00 00       	jmp    656 <printf+0x17f>
    c = fmt[i] & 0xff;
 4fd:	8b 55 0c             	mov    0xc(%ebp),%edx
 500:	8b 45 f0             	mov    -0x10(%ebp),%eax
 503:	01 d0                	add    %edx,%eax
 505:	0f b6 00             	movzbl (%eax),%eax
 508:	0f be c0             	movsbl %al,%eax
 50b:	25 ff 00 00 00       	and    $0xff,%eax
 510:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 513:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 517:	75 2c                	jne    545 <printf+0x6e>
      if(c == '%'){
 519:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 51d:	75 0c                	jne    52b <printf+0x54>
        state = '%';
 51f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 526:	e9 27 01 00 00       	jmp    652 <printf+0x17b>
      } else {
        putc(fd, c);
 52b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 52e:	0f be c0             	movsbl %al,%eax
 531:	83 ec 08             	sub    $0x8,%esp
 534:	50                   	push   %eax
 535:	ff 75 08             	pushl  0x8(%ebp)
 538:	e8 be fe ff ff       	call   3fb <putc>
 53d:	83 c4 10             	add    $0x10,%esp
 540:	e9 0d 01 00 00       	jmp    652 <printf+0x17b>
      }
    } else if(state == '%'){
 545:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 549:	0f 85 03 01 00 00    	jne    652 <printf+0x17b>
      if(c == 'd'){
 54f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 553:	75 1e                	jne    573 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 555:	8b 45 e8             	mov    -0x18(%ebp),%eax
 558:	8b 00                	mov    (%eax),%eax
 55a:	6a 01                	push   $0x1
 55c:	6a 0a                	push   $0xa
 55e:	50                   	push   %eax
 55f:	ff 75 08             	pushl  0x8(%ebp)
 562:	e8 bb fe ff ff       	call   422 <printint>
 567:	83 c4 10             	add    $0x10,%esp
        ap++;
 56a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 56e:	e9 d8 00 00 00       	jmp    64b <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 573:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 577:	74 06                	je     57f <printf+0xa8>
 579:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 57d:	75 1e                	jne    59d <printf+0xc6>
        printint(fd, *ap, 16, 0);
 57f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 582:	8b 00                	mov    (%eax),%eax
 584:	6a 00                	push   $0x0
 586:	6a 10                	push   $0x10
 588:	50                   	push   %eax
 589:	ff 75 08             	pushl  0x8(%ebp)
 58c:	e8 91 fe ff ff       	call   422 <printint>
 591:	83 c4 10             	add    $0x10,%esp
        ap++;
 594:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 598:	e9 ae 00 00 00       	jmp    64b <printf+0x174>
      } else if(c == 's'){
 59d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5a1:	75 43                	jne    5e6 <printf+0x10f>
        s = (char*)*ap;
 5a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a6:	8b 00                	mov    (%eax),%eax
 5a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5ab:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5b3:	75 25                	jne    5da <printf+0x103>
          s = "(null)";
 5b5:	c7 45 f4 dc 08 00 00 	movl   $0x8dc,-0xc(%ebp)
        while(*s != 0){
 5bc:	eb 1c                	jmp    5da <printf+0x103>
          putc(fd, *s);
 5be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c1:	0f b6 00             	movzbl (%eax),%eax
 5c4:	0f be c0             	movsbl %al,%eax
 5c7:	83 ec 08             	sub    $0x8,%esp
 5ca:	50                   	push   %eax
 5cb:	ff 75 08             	pushl  0x8(%ebp)
 5ce:	e8 28 fe ff ff       	call   3fb <putc>
 5d3:	83 c4 10             	add    $0x10,%esp
          s++;
 5d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5dd:	0f b6 00             	movzbl (%eax),%eax
 5e0:	84 c0                	test   %al,%al
 5e2:	75 da                	jne    5be <printf+0xe7>
 5e4:	eb 65                	jmp    64b <printf+0x174>
        }
      } else if(c == 'c'){
 5e6:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5ea:	75 1d                	jne    609 <printf+0x132>
        putc(fd, *ap);
 5ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ef:	8b 00                	mov    (%eax),%eax
 5f1:	0f be c0             	movsbl %al,%eax
 5f4:	83 ec 08             	sub    $0x8,%esp
 5f7:	50                   	push   %eax
 5f8:	ff 75 08             	pushl  0x8(%ebp)
 5fb:	e8 fb fd ff ff       	call   3fb <putc>
 600:	83 c4 10             	add    $0x10,%esp
        ap++;
 603:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 607:	eb 42                	jmp    64b <printf+0x174>
      } else if(c == '%'){
 609:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 60d:	75 17                	jne    626 <printf+0x14f>
        putc(fd, c);
 60f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 612:	0f be c0             	movsbl %al,%eax
 615:	83 ec 08             	sub    $0x8,%esp
 618:	50                   	push   %eax
 619:	ff 75 08             	pushl  0x8(%ebp)
 61c:	e8 da fd ff ff       	call   3fb <putc>
 621:	83 c4 10             	add    $0x10,%esp
 624:	eb 25                	jmp    64b <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 626:	83 ec 08             	sub    $0x8,%esp
 629:	6a 25                	push   $0x25
 62b:	ff 75 08             	pushl  0x8(%ebp)
 62e:	e8 c8 fd ff ff       	call   3fb <putc>
 633:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 636:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 639:	0f be c0             	movsbl %al,%eax
 63c:	83 ec 08             	sub    $0x8,%esp
 63f:	50                   	push   %eax
 640:	ff 75 08             	pushl  0x8(%ebp)
 643:	e8 b3 fd ff ff       	call   3fb <putc>
 648:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 64b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 652:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 656:	8b 55 0c             	mov    0xc(%ebp),%edx
 659:	8b 45 f0             	mov    -0x10(%ebp),%eax
 65c:	01 d0                	add    %edx,%eax
 65e:	0f b6 00             	movzbl (%eax),%eax
 661:	84 c0                	test   %al,%al
 663:	0f 85 94 fe ff ff    	jne    4fd <printf+0x26>
    }
  }
}
 669:	90                   	nop
 66a:	90                   	nop
 66b:	c9                   	leave  
 66c:	c3                   	ret    

0000066d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 66d:	f3 0f 1e fb          	endbr32 
 671:	55                   	push   %ebp
 672:	89 e5                	mov    %esp,%ebp
 674:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 677:	8b 45 08             	mov    0x8(%ebp),%eax
 67a:	83 e8 08             	sub    $0x8,%eax
 67d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 680:	a1 64 0b 00 00       	mov    0xb64,%eax
 685:	89 45 fc             	mov    %eax,-0x4(%ebp)
 688:	eb 24                	jmp    6ae <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	8b 00                	mov    (%eax),%eax
 68f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 692:	72 12                	jb     6a6 <free+0x39>
 694:	8b 45 f8             	mov    -0x8(%ebp),%eax
 697:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 69a:	77 24                	ja     6c0 <free+0x53>
 69c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69f:	8b 00                	mov    (%eax),%eax
 6a1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6a4:	72 1a                	jb     6c0 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a9:	8b 00                	mov    (%eax),%eax
 6ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b4:	76 d4                	jbe    68a <free+0x1d>
 6b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b9:	8b 00                	mov    (%eax),%eax
 6bb:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6be:	73 ca                	jae    68a <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c3:	8b 40 04             	mov    0x4(%eax),%eax
 6c6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d0:	01 c2                	add    %eax,%edx
 6d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d5:	8b 00                	mov    (%eax),%eax
 6d7:	39 c2                	cmp    %eax,%edx
 6d9:	75 24                	jne    6ff <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 6db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6de:	8b 50 04             	mov    0x4(%eax),%edx
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	8b 00                	mov    (%eax),%eax
 6e6:	8b 40 04             	mov    0x4(%eax),%eax
 6e9:	01 c2                	add    %eax,%edx
 6eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ee:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	8b 10                	mov    (%eax),%edx
 6f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6fb:	89 10                	mov    %edx,(%eax)
 6fd:	eb 0a                	jmp    709 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 6ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 702:	8b 10                	mov    (%eax),%edx
 704:	8b 45 f8             	mov    -0x8(%ebp),%eax
 707:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 709:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70c:	8b 40 04             	mov    0x4(%eax),%eax
 70f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 716:	8b 45 fc             	mov    -0x4(%ebp),%eax
 719:	01 d0                	add    %edx,%eax
 71b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 71e:	75 20                	jne    740 <free+0xd3>
    p->s.size += bp->s.size;
 720:	8b 45 fc             	mov    -0x4(%ebp),%eax
 723:	8b 50 04             	mov    0x4(%eax),%edx
 726:	8b 45 f8             	mov    -0x8(%ebp),%eax
 729:	8b 40 04             	mov    0x4(%eax),%eax
 72c:	01 c2                	add    %eax,%edx
 72e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 731:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 734:	8b 45 f8             	mov    -0x8(%ebp),%eax
 737:	8b 10                	mov    (%eax),%edx
 739:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73c:	89 10                	mov    %edx,(%eax)
 73e:	eb 08                	jmp    748 <free+0xdb>
  } else
    p->s.ptr = bp;
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	8b 55 f8             	mov    -0x8(%ebp),%edx
 746:	89 10                	mov    %edx,(%eax)
  freep = p;
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	a3 64 0b 00 00       	mov    %eax,0xb64
}
 750:	90                   	nop
 751:	c9                   	leave  
 752:	c3                   	ret    

00000753 <morecore>:

static Header*
morecore(uint nu)
{
 753:	f3 0f 1e fb          	endbr32 
 757:	55                   	push   %ebp
 758:	89 e5                	mov    %esp,%ebp
 75a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 75d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 764:	77 07                	ja     76d <morecore+0x1a>
    nu = 4096;
 766:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 76d:	8b 45 08             	mov    0x8(%ebp),%eax
 770:	c1 e0 03             	shl    $0x3,%eax
 773:	83 ec 0c             	sub    $0xc,%esp
 776:	50                   	push   %eax
 777:	e8 47 fc ff ff       	call   3c3 <sbrk>
 77c:	83 c4 10             	add    $0x10,%esp
 77f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 782:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 786:	75 07                	jne    78f <morecore+0x3c>
    return 0;
 788:	b8 00 00 00 00       	mov    $0x0,%eax
 78d:	eb 26                	jmp    7b5 <morecore+0x62>
  hp = (Header*)p;
 78f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 792:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 795:	8b 45 f0             	mov    -0x10(%ebp),%eax
 798:	8b 55 08             	mov    0x8(%ebp),%edx
 79b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 79e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a1:	83 c0 08             	add    $0x8,%eax
 7a4:	83 ec 0c             	sub    $0xc,%esp
 7a7:	50                   	push   %eax
 7a8:	e8 c0 fe ff ff       	call   66d <free>
 7ad:	83 c4 10             	add    $0x10,%esp
  return freep;
 7b0:	a1 64 0b 00 00       	mov    0xb64,%eax
}
 7b5:	c9                   	leave  
 7b6:	c3                   	ret    

000007b7 <malloc>:

void*
malloc(uint nbytes)
{
 7b7:	f3 0f 1e fb          	endbr32 
 7bb:	55                   	push   %ebp
 7bc:	89 e5                	mov    %esp,%ebp
 7be:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c1:	8b 45 08             	mov    0x8(%ebp),%eax
 7c4:	83 c0 07             	add    $0x7,%eax
 7c7:	c1 e8 03             	shr    $0x3,%eax
 7ca:	83 c0 01             	add    $0x1,%eax
 7cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7d0:	a1 64 0b 00 00       	mov    0xb64,%eax
 7d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7dc:	75 23                	jne    801 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 7de:	c7 45 f0 5c 0b 00 00 	movl   $0xb5c,-0x10(%ebp)
 7e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e8:	a3 64 0b 00 00       	mov    %eax,0xb64
 7ed:	a1 64 0b 00 00       	mov    0xb64,%eax
 7f2:	a3 5c 0b 00 00       	mov    %eax,0xb5c
    base.s.size = 0;
 7f7:	c7 05 60 0b 00 00 00 	movl   $0x0,0xb60
 7fe:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 801:	8b 45 f0             	mov    -0x10(%ebp),%eax
 804:	8b 00                	mov    (%eax),%eax
 806:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 809:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80c:	8b 40 04             	mov    0x4(%eax),%eax
 80f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 812:	77 4d                	ja     861 <malloc+0xaa>
      if(p->s.size == nunits)
 814:	8b 45 f4             	mov    -0xc(%ebp),%eax
 817:	8b 40 04             	mov    0x4(%eax),%eax
 81a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 81d:	75 0c                	jne    82b <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 81f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 822:	8b 10                	mov    (%eax),%edx
 824:	8b 45 f0             	mov    -0x10(%ebp),%eax
 827:	89 10                	mov    %edx,(%eax)
 829:	eb 26                	jmp    851 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 82b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82e:	8b 40 04             	mov    0x4(%eax),%eax
 831:	2b 45 ec             	sub    -0x14(%ebp),%eax
 834:	89 c2                	mov    %eax,%edx
 836:	8b 45 f4             	mov    -0xc(%ebp),%eax
 839:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	8b 40 04             	mov    0x4(%eax),%eax
 842:	c1 e0 03             	shl    $0x3,%eax
 845:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 848:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 84e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 851:	8b 45 f0             	mov    -0x10(%ebp),%eax
 854:	a3 64 0b 00 00       	mov    %eax,0xb64
      return (void*)(p + 1);
 859:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85c:	83 c0 08             	add    $0x8,%eax
 85f:	eb 3b                	jmp    89c <malloc+0xe5>
    }
    if(p == freep)
 861:	a1 64 0b 00 00       	mov    0xb64,%eax
 866:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 869:	75 1e                	jne    889 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 86b:	83 ec 0c             	sub    $0xc,%esp
 86e:	ff 75 ec             	pushl  -0x14(%ebp)
 871:	e8 dd fe ff ff       	call   753 <morecore>
 876:	83 c4 10             	add    $0x10,%esp
 879:	89 45 f4             	mov    %eax,-0xc(%ebp)
 87c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 880:	75 07                	jne    889 <malloc+0xd2>
        return 0;
 882:	b8 00 00 00 00       	mov    $0x0,%eax
 887:	eb 13                	jmp    89c <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 889:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 88f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 892:	8b 00                	mov    (%eax),%eax
 894:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 897:	e9 6d ff ff ff       	jmp    809 <malloc+0x52>
  }
}
 89c:	c9                   	leave  
 89d:	c3                   	ret    
