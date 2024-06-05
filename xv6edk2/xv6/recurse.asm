
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
  41:	53                   	push   %ebx
  42:	51                   	push   %ecx
  43:	83 ec 10             	sub    $0x10,%esp
  46:	89 cb                	mov    %ecx,%ebx
    int n, m;

    if(argc != 2){
  48:	83 3b 02             	cmpl   $0x2,(%ebx)
  4b:	74 1d                	je     6a <main+0x3a>
        printf(1, "Usage: %s levels\n", argv[0]);
  4d:	8b 43 04             	mov    0x4(%ebx),%eax
  50:	8b 00                	mov    (%eax),%eax
  52:	83 ec 04             	sub    $0x4,%esp
  55:	50                   	push   %eax
  56:	68 c1 08 00 00       	push   $0x8c1
  5b:	6a 01                	push   $0x1
  5d:	e8 98 04 00 00       	call   4fa <printf>
  62:	83 c4 10             	add    $0x10,%esp
        exit();
  65:	e8 f4 02 00 00       	call   35e <exit>
    }

    printpt(getpid()); // Uncomment for the test.
  6a:	e8 6f 03 00 00       	call   3de <getpid>
  6f:	83 ec 0c             	sub    $0xc,%esp
  72:	50                   	push   %eax
  73:	e8 9e 03 00 00       	call   416 <printpt>
  78:	83 c4 10             	add    $0x10,%esp
    n = atoi(argv[1]);
  7b:	8b 43 04             	mov    0x4(%ebx),%eax
  7e:	83 c0 04             	add    $0x4,%eax
  81:	8b 00                	mov    (%eax),%eax
  83:	83 ec 0c             	sub    $0xc,%esp
  86:	50                   	push   %eax
  87:	e8 38 02 00 00       	call   2c4 <atoi>
  8c:	83 c4 10             	add    $0x10,%esp
  8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    printf(1, "Recursing %d levels\n", n);
  92:	83 ec 04             	sub    $0x4,%esp
  95:	ff 75 f4             	pushl  -0xc(%ebp)
  98:	68 d3 08 00 00       	push   $0x8d3
  9d:	6a 01                	push   $0x1
  9f:	e8 56 04 00 00       	call   4fa <printf>
  a4:	83 c4 10             	add    $0x10,%esp
    m = recurse(n);
  a7:	83 ec 0c             	sub    $0xc,%esp
  aa:	ff 75 f4             	pushl  -0xc(%ebp)
  ad:	e8 4e ff ff ff       	call   0 <recurse>
  b2:	83 c4 10             	add    $0x10,%esp
  b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    printf(1, "Yielded a value of %d\n", m);
  b8:	83 ec 04             	sub    $0x4,%esp
  bb:	ff 75 f0             	pushl  -0x10(%ebp)
  be:	68 e8 08 00 00       	push   $0x8e8
  c3:	6a 01                	push   $0x1
  c5:	e8 30 04 00 00       	call   4fa <printf>
  ca:	83 c4 10             	add    $0x10,%esp

    printpt(getpid()); // Uncomment for the test.
  cd:	e8 0c 03 00 00       	call   3de <getpid>
  d2:	83 ec 0c             	sub    $0xc,%esp
  d5:	50                   	push   %eax
  d6:	e8 3b 03 00 00       	call   416 <printpt>
  db:	83 c4 10             	add    $0x10,%esp
    exit();
  de:	e8 7b 02 00 00       	call   35e <exit>

000000e3 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  e6:	57                   	push   %edi
  e7:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  eb:	8b 55 10             	mov    0x10(%ebp),%edx
  ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  f1:	89 cb                	mov    %ecx,%ebx
  f3:	89 df                	mov    %ebx,%edi
  f5:	89 d1                	mov    %edx,%ecx
  f7:	fc                   	cld    
  f8:	f3 aa                	rep stos %al,%es:(%edi)
  fa:	89 ca                	mov    %ecx,%edx
  fc:	89 fb                	mov    %edi,%ebx
  fe:	89 5d 08             	mov    %ebx,0x8(%ebp)
 101:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 104:	90                   	nop
 105:	5b                   	pop    %ebx
 106:	5f                   	pop    %edi
 107:	5d                   	pop    %ebp
 108:	c3                   	ret    

00000109 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 109:	f3 0f 1e fb          	endbr32 
 10d:	55                   	push   %ebp
 10e:	89 e5                	mov    %esp,%ebp
 110:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 113:	8b 45 08             	mov    0x8(%ebp),%eax
 116:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 119:	90                   	nop
 11a:	8b 55 0c             	mov    0xc(%ebp),%edx
 11d:	8d 42 01             	lea    0x1(%edx),%eax
 120:	89 45 0c             	mov    %eax,0xc(%ebp)
 123:	8b 45 08             	mov    0x8(%ebp),%eax
 126:	8d 48 01             	lea    0x1(%eax),%ecx
 129:	89 4d 08             	mov    %ecx,0x8(%ebp)
 12c:	0f b6 12             	movzbl (%edx),%edx
 12f:	88 10                	mov    %dl,(%eax)
 131:	0f b6 00             	movzbl (%eax),%eax
 134:	84 c0                	test   %al,%al
 136:	75 e2                	jne    11a <strcpy+0x11>
    ;
  return os;
 138:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 13b:	c9                   	leave  
 13c:	c3                   	ret    

0000013d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13d:	f3 0f 1e fb          	endbr32 
 141:	55                   	push   %ebp
 142:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 144:	eb 08                	jmp    14e <strcmp+0x11>
    p++, q++;
 146:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 14a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	0f b6 00             	movzbl (%eax),%eax
 154:	84 c0                	test   %al,%al
 156:	74 10                	je     168 <strcmp+0x2b>
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	0f b6 10             	movzbl (%eax),%edx
 15e:	8b 45 0c             	mov    0xc(%ebp),%eax
 161:	0f b6 00             	movzbl (%eax),%eax
 164:	38 c2                	cmp    %al,%dl
 166:	74 de                	je     146 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	0f b6 00             	movzbl (%eax),%eax
 16e:	0f b6 d0             	movzbl %al,%edx
 171:	8b 45 0c             	mov    0xc(%ebp),%eax
 174:	0f b6 00             	movzbl (%eax),%eax
 177:	0f b6 c0             	movzbl %al,%eax
 17a:	29 c2                	sub    %eax,%edx
 17c:	89 d0                	mov    %edx,%eax
}
 17e:	5d                   	pop    %ebp
 17f:	c3                   	ret    

00000180 <strlen>:

uint
strlen(char *s)
{
 180:	f3 0f 1e fb          	endbr32 
 184:	55                   	push   %ebp
 185:	89 e5                	mov    %esp,%ebp
 187:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 18a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 191:	eb 04                	jmp    197 <strlen+0x17>
 193:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 197:	8b 55 fc             	mov    -0x4(%ebp),%edx
 19a:	8b 45 08             	mov    0x8(%ebp),%eax
 19d:	01 d0                	add    %edx,%eax
 19f:	0f b6 00             	movzbl (%eax),%eax
 1a2:	84 c0                	test   %al,%al
 1a4:	75 ed                	jne    193 <strlen+0x13>
    ;
  return n;
 1a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1a9:	c9                   	leave  
 1aa:	c3                   	ret    

000001ab <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ab:	f3 0f 1e fb          	endbr32 
 1af:	55                   	push   %ebp
 1b0:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1b2:	8b 45 10             	mov    0x10(%ebp),%eax
 1b5:	50                   	push   %eax
 1b6:	ff 75 0c             	pushl  0xc(%ebp)
 1b9:	ff 75 08             	pushl  0x8(%ebp)
 1bc:	e8 22 ff ff ff       	call   e3 <stosb>
 1c1:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1c7:	c9                   	leave  
 1c8:	c3                   	ret    

000001c9 <strchr>:

char*
strchr(const char *s, char c)
{
 1c9:	f3 0f 1e fb          	endbr32 
 1cd:	55                   	push   %ebp
 1ce:	89 e5                	mov    %esp,%ebp
 1d0:	83 ec 04             	sub    $0x4,%esp
 1d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d6:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1d9:	eb 14                	jmp    1ef <strchr+0x26>
    if(*s == c)
 1db:	8b 45 08             	mov    0x8(%ebp),%eax
 1de:	0f b6 00             	movzbl (%eax),%eax
 1e1:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1e4:	75 05                	jne    1eb <strchr+0x22>
      return (char*)s;
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	eb 13                	jmp    1fe <strchr+0x35>
  for(; *s; s++)
 1eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	0f b6 00             	movzbl (%eax),%eax
 1f5:	84 c0                	test   %al,%al
 1f7:	75 e2                	jne    1db <strchr+0x12>
  return 0;
 1f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1fe:	c9                   	leave  
 1ff:	c3                   	ret    

00000200 <gets>:

char*
gets(char *buf, int max)
{
 200:	f3 0f 1e fb          	endbr32 
 204:	55                   	push   %ebp
 205:	89 e5                	mov    %esp,%ebp
 207:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 211:	eb 42                	jmp    255 <gets+0x55>
    cc = read(0, &c, 1);
 213:	83 ec 04             	sub    $0x4,%esp
 216:	6a 01                	push   $0x1
 218:	8d 45 ef             	lea    -0x11(%ebp),%eax
 21b:	50                   	push   %eax
 21c:	6a 00                	push   $0x0
 21e:	e8 53 01 00 00       	call   376 <read>
 223:	83 c4 10             	add    $0x10,%esp
 226:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 229:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 22d:	7e 33                	jle    262 <gets+0x62>
      break;
    buf[i++] = c;
 22f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 232:	8d 50 01             	lea    0x1(%eax),%edx
 235:	89 55 f4             	mov    %edx,-0xc(%ebp)
 238:	89 c2                	mov    %eax,%edx
 23a:	8b 45 08             	mov    0x8(%ebp),%eax
 23d:	01 c2                	add    %eax,%edx
 23f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 243:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 245:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 249:	3c 0a                	cmp    $0xa,%al
 24b:	74 16                	je     263 <gets+0x63>
 24d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 251:	3c 0d                	cmp    $0xd,%al
 253:	74 0e                	je     263 <gets+0x63>
  for(i=0; i+1 < max; ){
 255:	8b 45 f4             	mov    -0xc(%ebp),%eax
 258:	83 c0 01             	add    $0x1,%eax
 25b:	39 45 0c             	cmp    %eax,0xc(%ebp)
 25e:	7f b3                	jg     213 <gets+0x13>
 260:	eb 01                	jmp    263 <gets+0x63>
      break;
 262:	90                   	nop
      break;
  }
  buf[i] = '\0';
 263:	8b 55 f4             	mov    -0xc(%ebp),%edx
 266:	8b 45 08             	mov    0x8(%ebp),%eax
 269:	01 d0                	add    %edx,%eax
 26b:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 26e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 271:	c9                   	leave  
 272:	c3                   	ret    

00000273 <stat>:

int
stat(char *n, struct stat *st)
{
 273:	f3 0f 1e fb          	endbr32 
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27d:	83 ec 08             	sub    $0x8,%esp
 280:	6a 00                	push   $0x0
 282:	ff 75 08             	pushl  0x8(%ebp)
 285:	e8 14 01 00 00       	call   39e <open>
 28a:	83 c4 10             	add    $0x10,%esp
 28d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 290:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 294:	79 07                	jns    29d <stat+0x2a>
    return -1;
 296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 29b:	eb 25                	jmp    2c2 <stat+0x4f>
  r = fstat(fd, st);
 29d:	83 ec 08             	sub    $0x8,%esp
 2a0:	ff 75 0c             	pushl  0xc(%ebp)
 2a3:	ff 75 f4             	pushl  -0xc(%ebp)
 2a6:	e8 0b 01 00 00       	call   3b6 <fstat>
 2ab:	83 c4 10             	add    $0x10,%esp
 2ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b1:	83 ec 0c             	sub    $0xc,%esp
 2b4:	ff 75 f4             	pushl  -0xc(%ebp)
 2b7:	e8 ca 00 00 00       	call   386 <close>
 2bc:	83 c4 10             	add    $0x10,%esp
  return r;
 2bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c2:	c9                   	leave  
 2c3:	c3                   	ret    

000002c4 <atoi>:

int
atoi(const char *s)
{
 2c4:	f3 0f 1e fb          	endbr32 
 2c8:	55                   	push   %ebp
 2c9:	89 e5                	mov    %esp,%ebp
 2cb:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2ce:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d5:	eb 25                	jmp    2fc <atoi+0x38>
    n = n*10 + *s++ - '0';
 2d7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2da:	89 d0                	mov    %edx,%eax
 2dc:	c1 e0 02             	shl    $0x2,%eax
 2df:	01 d0                	add    %edx,%eax
 2e1:	01 c0                	add    %eax,%eax
 2e3:	89 c1                	mov    %eax,%ecx
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	8d 50 01             	lea    0x1(%eax),%edx
 2eb:	89 55 08             	mov    %edx,0x8(%ebp)
 2ee:	0f b6 00             	movzbl (%eax),%eax
 2f1:	0f be c0             	movsbl %al,%eax
 2f4:	01 c8                	add    %ecx,%eax
 2f6:	83 e8 30             	sub    $0x30,%eax
 2f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2fc:	8b 45 08             	mov    0x8(%ebp),%eax
 2ff:	0f b6 00             	movzbl (%eax),%eax
 302:	3c 2f                	cmp    $0x2f,%al
 304:	7e 0a                	jle    310 <atoi+0x4c>
 306:	8b 45 08             	mov    0x8(%ebp),%eax
 309:	0f b6 00             	movzbl (%eax),%eax
 30c:	3c 39                	cmp    $0x39,%al
 30e:	7e c7                	jle    2d7 <atoi+0x13>
  return n;
 310:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 313:	c9                   	leave  
 314:	c3                   	ret    

00000315 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 315:	f3 0f 1e fb          	endbr32 
 319:	55                   	push   %ebp
 31a:	89 e5                	mov    %esp,%ebp
 31c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 325:	8b 45 0c             	mov    0xc(%ebp),%eax
 328:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 32b:	eb 17                	jmp    344 <memmove+0x2f>
    *dst++ = *src++;
 32d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 330:	8d 42 01             	lea    0x1(%edx),%eax
 333:	89 45 f8             	mov    %eax,-0x8(%ebp)
 336:	8b 45 fc             	mov    -0x4(%ebp),%eax
 339:	8d 48 01             	lea    0x1(%eax),%ecx
 33c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 33f:	0f b6 12             	movzbl (%edx),%edx
 342:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 344:	8b 45 10             	mov    0x10(%ebp),%eax
 347:	8d 50 ff             	lea    -0x1(%eax),%edx
 34a:	89 55 10             	mov    %edx,0x10(%ebp)
 34d:	85 c0                	test   %eax,%eax
 34f:	7f dc                	jg     32d <memmove+0x18>
  return vdst;
 351:	8b 45 08             	mov    0x8(%ebp),%eax
}
 354:	c9                   	leave  
 355:	c3                   	ret    

00000356 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 356:	b8 01 00 00 00       	mov    $0x1,%eax
 35b:	cd 40                	int    $0x40
 35d:	c3                   	ret    

0000035e <exit>:
SYSCALL(exit)
 35e:	b8 02 00 00 00       	mov    $0x2,%eax
 363:	cd 40                	int    $0x40
 365:	c3                   	ret    

00000366 <wait>:
SYSCALL(wait)
 366:	b8 03 00 00 00       	mov    $0x3,%eax
 36b:	cd 40                	int    $0x40
 36d:	c3                   	ret    

0000036e <pipe>:
SYSCALL(pipe)
 36e:	b8 04 00 00 00       	mov    $0x4,%eax
 373:	cd 40                	int    $0x40
 375:	c3                   	ret    

00000376 <read>:
SYSCALL(read)
 376:	b8 05 00 00 00       	mov    $0x5,%eax
 37b:	cd 40                	int    $0x40
 37d:	c3                   	ret    

0000037e <write>:
SYSCALL(write)
 37e:	b8 10 00 00 00       	mov    $0x10,%eax
 383:	cd 40                	int    $0x40
 385:	c3                   	ret    

00000386 <close>:
SYSCALL(close)
 386:	b8 15 00 00 00       	mov    $0x15,%eax
 38b:	cd 40                	int    $0x40
 38d:	c3                   	ret    

0000038e <kill>:
SYSCALL(kill)
 38e:	b8 06 00 00 00       	mov    $0x6,%eax
 393:	cd 40                	int    $0x40
 395:	c3                   	ret    

00000396 <exec>:
SYSCALL(exec)
 396:	b8 07 00 00 00       	mov    $0x7,%eax
 39b:	cd 40                	int    $0x40
 39d:	c3                   	ret    

0000039e <open>:
SYSCALL(open)
 39e:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a3:	cd 40                	int    $0x40
 3a5:	c3                   	ret    

000003a6 <mknod>:
SYSCALL(mknod)
 3a6:	b8 11 00 00 00       	mov    $0x11,%eax
 3ab:	cd 40                	int    $0x40
 3ad:	c3                   	ret    

000003ae <unlink>:
SYSCALL(unlink)
 3ae:	b8 12 00 00 00       	mov    $0x12,%eax
 3b3:	cd 40                	int    $0x40
 3b5:	c3                   	ret    

000003b6 <fstat>:
SYSCALL(fstat)
 3b6:	b8 08 00 00 00       	mov    $0x8,%eax
 3bb:	cd 40                	int    $0x40
 3bd:	c3                   	ret    

000003be <link>:
SYSCALL(link)
 3be:	b8 13 00 00 00       	mov    $0x13,%eax
 3c3:	cd 40                	int    $0x40
 3c5:	c3                   	ret    

000003c6 <mkdir>:
SYSCALL(mkdir)
 3c6:	b8 14 00 00 00       	mov    $0x14,%eax
 3cb:	cd 40                	int    $0x40
 3cd:	c3                   	ret    

000003ce <chdir>:
SYSCALL(chdir)
 3ce:	b8 09 00 00 00       	mov    $0x9,%eax
 3d3:	cd 40                	int    $0x40
 3d5:	c3                   	ret    

000003d6 <dup>:
SYSCALL(dup)
 3d6:	b8 0a 00 00 00       	mov    $0xa,%eax
 3db:	cd 40                	int    $0x40
 3dd:	c3                   	ret    

000003de <getpid>:
SYSCALL(getpid)
 3de:	b8 0b 00 00 00       	mov    $0xb,%eax
 3e3:	cd 40                	int    $0x40
 3e5:	c3                   	ret    

000003e6 <sbrk>:
SYSCALL(sbrk)
 3e6:	b8 0c 00 00 00       	mov    $0xc,%eax
 3eb:	cd 40                	int    $0x40
 3ed:	c3                   	ret    

000003ee <sleep>:
SYSCALL(sleep)
 3ee:	b8 0d 00 00 00       	mov    $0xd,%eax
 3f3:	cd 40                	int    $0x40
 3f5:	c3                   	ret    

000003f6 <uptime>:
SYSCALL(uptime)
 3f6:	b8 0e 00 00 00       	mov    $0xe,%eax
 3fb:	cd 40                	int    $0x40
 3fd:	c3                   	ret    

000003fe <exit2>:
SYSCALL(exit2)
 3fe:	b8 16 00 00 00       	mov    $0x16,%eax
 403:	cd 40                	int    $0x40
 405:	c3                   	ret    

00000406 <wait2>:
SYSCALL(wait2)
 406:	b8 17 00 00 00       	mov    $0x17,%eax
 40b:	cd 40                	int    $0x40
 40d:	c3                   	ret    

0000040e <uthread_init>:
SYSCALL(uthread_init)
 40e:	b8 18 00 00 00       	mov    $0x18,%eax
 413:	cd 40                	int    $0x40
 415:	c3                   	ret    

00000416 <printpt>:
SYSCALL(printpt)
 416:	b8 19 00 00 00       	mov    $0x19,%eax
 41b:	cd 40                	int    $0x40
 41d:	c3                   	ret    

0000041e <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 41e:	f3 0f 1e fb          	endbr32 
 422:	55                   	push   %ebp
 423:	89 e5                	mov    %esp,%ebp
 425:	83 ec 18             	sub    $0x18,%esp
 428:	8b 45 0c             	mov    0xc(%ebp),%eax
 42b:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 42e:	83 ec 04             	sub    $0x4,%esp
 431:	6a 01                	push   $0x1
 433:	8d 45 f4             	lea    -0xc(%ebp),%eax
 436:	50                   	push   %eax
 437:	ff 75 08             	pushl  0x8(%ebp)
 43a:	e8 3f ff ff ff       	call   37e <write>
 43f:	83 c4 10             	add    $0x10,%esp
}
 442:	90                   	nop
 443:	c9                   	leave  
 444:	c3                   	ret    

00000445 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 445:	f3 0f 1e fb          	endbr32 
 449:	55                   	push   %ebp
 44a:	89 e5                	mov    %esp,%ebp
 44c:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 44f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 456:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 45a:	74 17                	je     473 <printint+0x2e>
 45c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 460:	79 11                	jns    473 <printint+0x2e>
    neg = 1;
 462:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 469:	8b 45 0c             	mov    0xc(%ebp),%eax
 46c:	f7 d8                	neg    %eax
 46e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 471:	eb 06                	jmp    479 <printint+0x34>
  } else {
    x = xx;
 473:	8b 45 0c             	mov    0xc(%ebp),%eax
 476:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 479:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 480:	8b 4d 10             	mov    0x10(%ebp),%ecx
 483:	8b 45 ec             	mov    -0x14(%ebp),%eax
 486:	ba 00 00 00 00       	mov    $0x0,%edx
 48b:	f7 f1                	div    %ecx
 48d:	89 d1                	mov    %edx,%ecx
 48f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 492:	8d 50 01             	lea    0x1(%eax),%edx
 495:	89 55 f4             	mov    %edx,-0xc(%ebp)
 498:	0f b6 91 70 0b 00 00 	movzbl 0xb70(%ecx),%edx
 49f:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a9:	ba 00 00 00 00       	mov    $0x0,%edx
 4ae:	f7 f1                	div    %ecx
 4b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4b3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4b7:	75 c7                	jne    480 <printint+0x3b>
  if(neg)
 4b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4bd:	74 2d                	je     4ec <printint+0xa7>
    buf[i++] = '-';
 4bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c2:	8d 50 01             	lea    0x1(%eax),%edx
 4c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4c8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4cd:	eb 1d                	jmp    4ec <printint+0xa7>
    putc(fd, buf[i]);
 4cf:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d5:	01 d0                	add    %edx,%eax
 4d7:	0f b6 00             	movzbl (%eax),%eax
 4da:	0f be c0             	movsbl %al,%eax
 4dd:	83 ec 08             	sub    $0x8,%esp
 4e0:	50                   	push   %eax
 4e1:	ff 75 08             	pushl  0x8(%ebp)
 4e4:	e8 35 ff ff ff       	call   41e <putc>
 4e9:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4ec:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f4:	79 d9                	jns    4cf <printint+0x8a>
}
 4f6:	90                   	nop
 4f7:	90                   	nop
 4f8:	c9                   	leave  
 4f9:	c3                   	ret    

000004fa <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4fa:	f3 0f 1e fb          	endbr32 
 4fe:	55                   	push   %ebp
 4ff:	89 e5                	mov    %esp,%ebp
 501:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 504:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 50b:	8d 45 0c             	lea    0xc(%ebp),%eax
 50e:	83 c0 04             	add    $0x4,%eax
 511:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 514:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 51b:	e9 59 01 00 00       	jmp    679 <printf+0x17f>
    c = fmt[i] & 0xff;
 520:	8b 55 0c             	mov    0xc(%ebp),%edx
 523:	8b 45 f0             	mov    -0x10(%ebp),%eax
 526:	01 d0                	add    %edx,%eax
 528:	0f b6 00             	movzbl (%eax),%eax
 52b:	0f be c0             	movsbl %al,%eax
 52e:	25 ff 00 00 00       	and    $0xff,%eax
 533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 536:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 53a:	75 2c                	jne    568 <printf+0x6e>
      if(c == '%'){
 53c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 540:	75 0c                	jne    54e <printf+0x54>
        state = '%';
 542:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 549:	e9 27 01 00 00       	jmp    675 <printf+0x17b>
      } else {
        putc(fd, c);
 54e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 551:	0f be c0             	movsbl %al,%eax
 554:	83 ec 08             	sub    $0x8,%esp
 557:	50                   	push   %eax
 558:	ff 75 08             	pushl  0x8(%ebp)
 55b:	e8 be fe ff ff       	call   41e <putc>
 560:	83 c4 10             	add    $0x10,%esp
 563:	e9 0d 01 00 00       	jmp    675 <printf+0x17b>
      }
    } else if(state == '%'){
 568:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 56c:	0f 85 03 01 00 00    	jne    675 <printf+0x17b>
      if(c == 'd'){
 572:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 576:	75 1e                	jne    596 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 578:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57b:	8b 00                	mov    (%eax),%eax
 57d:	6a 01                	push   $0x1
 57f:	6a 0a                	push   $0xa
 581:	50                   	push   %eax
 582:	ff 75 08             	pushl  0x8(%ebp)
 585:	e8 bb fe ff ff       	call   445 <printint>
 58a:	83 c4 10             	add    $0x10,%esp
        ap++;
 58d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 591:	e9 d8 00 00 00       	jmp    66e <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 596:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 59a:	74 06                	je     5a2 <printf+0xa8>
 59c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5a0:	75 1e                	jne    5c0 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 5a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a5:	8b 00                	mov    (%eax),%eax
 5a7:	6a 00                	push   $0x0
 5a9:	6a 10                	push   $0x10
 5ab:	50                   	push   %eax
 5ac:	ff 75 08             	pushl  0x8(%ebp)
 5af:	e8 91 fe ff ff       	call   445 <printint>
 5b4:	83 c4 10             	add    $0x10,%esp
        ap++;
 5b7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5bb:	e9 ae 00 00 00       	jmp    66e <printf+0x174>
      } else if(c == 's'){
 5c0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5c4:	75 43                	jne    609 <printf+0x10f>
        s = (char*)*ap;
 5c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c9:	8b 00                	mov    (%eax),%eax
 5cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5ce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d6:	75 25                	jne    5fd <printf+0x103>
          s = "(null)";
 5d8:	c7 45 f4 ff 08 00 00 	movl   $0x8ff,-0xc(%ebp)
        while(*s != 0){
 5df:	eb 1c                	jmp    5fd <printf+0x103>
          putc(fd, *s);
 5e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e4:	0f b6 00             	movzbl (%eax),%eax
 5e7:	0f be c0             	movsbl %al,%eax
 5ea:	83 ec 08             	sub    $0x8,%esp
 5ed:	50                   	push   %eax
 5ee:	ff 75 08             	pushl  0x8(%ebp)
 5f1:	e8 28 fe ff ff       	call   41e <putc>
 5f6:	83 c4 10             	add    $0x10,%esp
          s++;
 5f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 600:	0f b6 00             	movzbl (%eax),%eax
 603:	84 c0                	test   %al,%al
 605:	75 da                	jne    5e1 <printf+0xe7>
 607:	eb 65                	jmp    66e <printf+0x174>
        }
      } else if(c == 'c'){
 609:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 60d:	75 1d                	jne    62c <printf+0x132>
        putc(fd, *ap);
 60f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 612:	8b 00                	mov    (%eax),%eax
 614:	0f be c0             	movsbl %al,%eax
 617:	83 ec 08             	sub    $0x8,%esp
 61a:	50                   	push   %eax
 61b:	ff 75 08             	pushl  0x8(%ebp)
 61e:	e8 fb fd ff ff       	call   41e <putc>
 623:	83 c4 10             	add    $0x10,%esp
        ap++;
 626:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 62a:	eb 42                	jmp    66e <printf+0x174>
      } else if(c == '%'){
 62c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 630:	75 17                	jne    649 <printf+0x14f>
        putc(fd, c);
 632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 635:	0f be c0             	movsbl %al,%eax
 638:	83 ec 08             	sub    $0x8,%esp
 63b:	50                   	push   %eax
 63c:	ff 75 08             	pushl  0x8(%ebp)
 63f:	e8 da fd ff ff       	call   41e <putc>
 644:	83 c4 10             	add    $0x10,%esp
 647:	eb 25                	jmp    66e <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 649:	83 ec 08             	sub    $0x8,%esp
 64c:	6a 25                	push   $0x25
 64e:	ff 75 08             	pushl  0x8(%ebp)
 651:	e8 c8 fd ff ff       	call   41e <putc>
 656:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 659:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65c:	0f be c0             	movsbl %al,%eax
 65f:	83 ec 08             	sub    $0x8,%esp
 662:	50                   	push   %eax
 663:	ff 75 08             	pushl  0x8(%ebp)
 666:	e8 b3 fd ff ff       	call   41e <putc>
 66b:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 66e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 675:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 679:	8b 55 0c             	mov    0xc(%ebp),%edx
 67c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 67f:	01 d0                	add    %edx,%eax
 681:	0f b6 00             	movzbl (%eax),%eax
 684:	84 c0                	test   %al,%al
 686:	0f 85 94 fe ff ff    	jne    520 <printf+0x26>
    }
  }
}
 68c:	90                   	nop
 68d:	90                   	nop
 68e:	c9                   	leave  
 68f:	c3                   	ret    

00000690 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 690:	f3 0f 1e fb          	endbr32 
 694:	55                   	push   %ebp
 695:	89 e5                	mov    %esp,%ebp
 697:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 69a:	8b 45 08             	mov    0x8(%ebp),%eax
 69d:	83 e8 08             	sub    $0x8,%eax
 6a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a3:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 6a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6ab:	eb 24                	jmp    6d1 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b0:	8b 00                	mov    (%eax),%eax
 6b2:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6b5:	72 12                	jb     6c9 <free+0x39>
 6b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6bd:	77 24                	ja     6e3 <free+0x53>
 6bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c2:	8b 00                	mov    (%eax),%eax
 6c4:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6c7:	72 1a                	jb     6e3 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cc:	8b 00                	mov    (%eax),%eax
 6ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d7:	76 d4                	jbe    6ad <free+0x1d>
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	8b 00                	mov    (%eax),%eax
 6de:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6e1:	73 ca                	jae    6ad <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e6:	8b 40 04             	mov    0x4(%eax),%eax
 6e9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f3:	01 c2                	add    %eax,%edx
 6f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f8:	8b 00                	mov    (%eax),%eax
 6fa:	39 c2                	cmp    %eax,%edx
 6fc:	75 24                	jne    722 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 6fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 701:	8b 50 04             	mov    0x4(%eax),%edx
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	8b 00                	mov    (%eax),%eax
 709:	8b 40 04             	mov    0x4(%eax),%eax
 70c:	01 c2                	add    %eax,%edx
 70e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 711:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 714:	8b 45 fc             	mov    -0x4(%ebp),%eax
 717:	8b 00                	mov    (%eax),%eax
 719:	8b 10                	mov    (%eax),%edx
 71b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71e:	89 10                	mov    %edx,(%eax)
 720:	eb 0a                	jmp    72c <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 722:	8b 45 fc             	mov    -0x4(%ebp),%eax
 725:	8b 10                	mov    (%eax),%edx
 727:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 72c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72f:	8b 40 04             	mov    0x4(%eax),%eax
 732:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 739:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73c:	01 d0                	add    %edx,%eax
 73e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 741:	75 20                	jne    763 <free+0xd3>
    p->s.size += bp->s.size;
 743:	8b 45 fc             	mov    -0x4(%ebp),%eax
 746:	8b 50 04             	mov    0x4(%eax),%edx
 749:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74c:	8b 40 04             	mov    0x4(%eax),%eax
 74f:	01 c2                	add    %eax,%edx
 751:	8b 45 fc             	mov    -0x4(%ebp),%eax
 754:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 757:	8b 45 f8             	mov    -0x8(%ebp),%eax
 75a:	8b 10                	mov    (%eax),%edx
 75c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75f:	89 10                	mov    %edx,(%eax)
 761:	eb 08                	jmp    76b <free+0xdb>
  } else
    p->s.ptr = bp;
 763:	8b 45 fc             	mov    -0x4(%ebp),%eax
 766:	8b 55 f8             	mov    -0x8(%ebp),%edx
 769:	89 10                	mov    %edx,(%eax)
  freep = p;
 76b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76e:	a3 8c 0b 00 00       	mov    %eax,0xb8c
}
 773:	90                   	nop
 774:	c9                   	leave  
 775:	c3                   	ret    

00000776 <morecore>:

static Header*
morecore(uint nu)
{
 776:	f3 0f 1e fb          	endbr32 
 77a:	55                   	push   %ebp
 77b:	89 e5                	mov    %esp,%ebp
 77d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 780:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 787:	77 07                	ja     790 <morecore+0x1a>
    nu = 4096;
 789:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 790:	8b 45 08             	mov    0x8(%ebp),%eax
 793:	c1 e0 03             	shl    $0x3,%eax
 796:	83 ec 0c             	sub    $0xc,%esp
 799:	50                   	push   %eax
 79a:	e8 47 fc ff ff       	call   3e6 <sbrk>
 79f:	83 c4 10             	add    $0x10,%esp
 7a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7a5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7a9:	75 07                	jne    7b2 <morecore+0x3c>
    return 0;
 7ab:	b8 00 00 00 00       	mov    $0x0,%eax
 7b0:	eb 26                	jmp    7d8 <morecore+0x62>
  hp = (Header*)p;
 7b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7bb:	8b 55 08             	mov    0x8(%ebp),%edx
 7be:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c4:	83 c0 08             	add    $0x8,%eax
 7c7:	83 ec 0c             	sub    $0xc,%esp
 7ca:	50                   	push   %eax
 7cb:	e8 c0 fe ff ff       	call   690 <free>
 7d0:	83 c4 10             	add    $0x10,%esp
  return freep;
 7d3:	a1 8c 0b 00 00       	mov    0xb8c,%eax
}
 7d8:	c9                   	leave  
 7d9:	c3                   	ret    

000007da <malloc>:

void*
malloc(uint nbytes)
{
 7da:	f3 0f 1e fb          	endbr32 
 7de:	55                   	push   %ebp
 7df:	89 e5                	mov    %esp,%ebp
 7e1:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e4:	8b 45 08             	mov    0x8(%ebp),%eax
 7e7:	83 c0 07             	add    $0x7,%eax
 7ea:	c1 e8 03             	shr    $0x3,%eax
 7ed:	83 c0 01             	add    $0x1,%eax
 7f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7f3:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 7f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7ff:	75 23                	jne    824 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 801:	c7 45 f0 84 0b 00 00 	movl   $0xb84,-0x10(%ebp)
 808:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80b:	a3 8c 0b 00 00       	mov    %eax,0xb8c
 810:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 815:	a3 84 0b 00 00       	mov    %eax,0xb84
    base.s.size = 0;
 81a:	c7 05 88 0b 00 00 00 	movl   $0x0,0xb88
 821:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 824:	8b 45 f0             	mov    -0x10(%ebp),%eax
 827:	8b 00                	mov    (%eax),%eax
 829:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 82c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82f:	8b 40 04             	mov    0x4(%eax),%eax
 832:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 835:	77 4d                	ja     884 <malloc+0xaa>
      if(p->s.size == nunits)
 837:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83a:	8b 40 04             	mov    0x4(%eax),%eax
 83d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 840:	75 0c                	jne    84e <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 842:	8b 45 f4             	mov    -0xc(%ebp),%eax
 845:	8b 10                	mov    (%eax),%edx
 847:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84a:	89 10                	mov    %edx,(%eax)
 84c:	eb 26                	jmp    874 <malloc+0x9a>
      else {
        p->s.size -= nunits;
 84e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 851:	8b 40 04             	mov    0x4(%eax),%eax
 854:	2b 45 ec             	sub    -0x14(%ebp),%eax
 857:	89 c2                	mov    %eax,%edx
 859:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 85f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 862:	8b 40 04             	mov    0x4(%eax),%eax
 865:	c1 e0 03             	shl    $0x3,%eax
 868:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86e:	8b 55 ec             	mov    -0x14(%ebp),%edx
 871:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 874:	8b 45 f0             	mov    -0x10(%ebp),%eax
 877:	a3 8c 0b 00 00       	mov    %eax,0xb8c
      return (void*)(p + 1);
 87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87f:	83 c0 08             	add    $0x8,%eax
 882:	eb 3b                	jmp    8bf <malloc+0xe5>
    }
    if(p == freep)
 884:	a1 8c 0b 00 00       	mov    0xb8c,%eax
 889:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 88c:	75 1e                	jne    8ac <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 88e:	83 ec 0c             	sub    $0xc,%esp
 891:	ff 75 ec             	pushl  -0x14(%ebp)
 894:	e8 dd fe ff ff       	call   776 <morecore>
 899:	83 c4 10             	add    $0x10,%esp
 89c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 89f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8a3:	75 07                	jne    8ac <malloc+0xd2>
        return 0;
 8a5:	b8 00 00 00 00       	mov    $0x0,%eax
 8aa:	eb 13                	jmp    8bf <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8af:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b5:	8b 00                	mov    (%eax),%eax
 8b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8ba:	e9 6d ff ff ff       	jmp    82c <malloc+0x52>
  }
}
 8bf:	c9                   	leave  
 8c0:	c3                   	ret    
