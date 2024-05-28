
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	53                   	push   %ebx
   8:	83 ec 14             	sub    $0x14,%esp
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   b:	83 ec 0c             	sub    $0xc,%esp
   e:	ff 75 08             	pushl  0x8(%ebp)
  11:	e8 d5 03 00 00       	call   3eb <strlen>
  16:	83 c4 10             	add    $0x10,%esp
  19:	8b 55 08             	mov    0x8(%ebp),%edx
  1c:	01 d0                	add    %edx,%eax
  1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  21:	eb 04                	jmp    27 <fmtname+0x27>
  23:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2a:	3b 45 08             	cmp    0x8(%ebp),%eax
  2d:	72 0a                	jb     39 <fmtname+0x39>
  2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  32:	0f b6 00             	movzbl (%eax),%eax
  35:	3c 2f                	cmp    $0x2f,%al
  37:	75 ea                	jne    23 <fmtname+0x23>
    ;
  p++;
  39:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3d:	83 ec 0c             	sub    $0xc,%esp
  40:	ff 75 f4             	pushl  -0xc(%ebp)
  43:	e8 a3 03 00 00       	call   3eb <strlen>
  48:	83 c4 10             	add    $0x10,%esp
  4b:	83 f8 0d             	cmp    $0xd,%eax
  4e:	76 05                	jbe    55 <fmtname+0x55>
    return p;
  50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  53:	eb 60                	jmp    b5 <fmtname+0xb5>
  memmove(buf, p, strlen(p));
  55:	83 ec 0c             	sub    $0xc,%esp
  58:	ff 75 f4             	pushl  -0xc(%ebp)
  5b:	e8 8b 03 00 00       	call   3eb <strlen>
  60:	83 c4 10             	add    $0x10,%esp
  63:	83 ec 04             	sub    $0x4,%esp
  66:	50                   	push   %eax
  67:	ff 75 f4             	pushl  -0xc(%ebp)
  6a:	68 30 0e 00 00       	push   $0xe30
  6f:	e8 0c 05 00 00       	call   580 <memmove>
  74:	83 c4 10             	add    $0x10,%esp
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  77:	83 ec 0c             	sub    $0xc,%esp
  7a:	ff 75 f4             	pushl  -0xc(%ebp)
  7d:	e8 69 03 00 00       	call   3eb <strlen>
  82:	83 c4 10             	add    $0x10,%esp
  85:	ba 0e 00 00 00       	mov    $0xe,%edx
  8a:	89 d3                	mov    %edx,%ebx
  8c:	29 c3                	sub    %eax,%ebx
  8e:	83 ec 0c             	sub    $0xc,%esp
  91:	ff 75 f4             	pushl  -0xc(%ebp)
  94:	e8 52 03 00 00       	call   3eb <strlen>
  99:	83 c4 10             	add    $0x10,%esp
  9c:	05 30 0e 00 00       	add    $0xe30,%eax
  a1:	83 ec 04             	sub    $0x4,%esp
  a4:	53                   	push   %ebx
  a5:	6a 20                	push   $0x20
  a7:	50                   	push   %eax
  a8:	e8 69 03 00 00       	call   416 <memset>
  ad:	83 c4 10             	add    $0x10,%esp
  return buf;
  b0:	b8 30 0e 00 00       	mov    $0xe30,%eax
}
  b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  b8:	c9                   	leave  
  b9:	c3                   	ret    

000000ba <ls>:

void
ls(char *path)
{
  ba:	f3 0f 1e fb          	endbr32 
  be:	55                   	push   %ebp
  bf:	89 e5                	mov    %esp,%ebp
  c1:	57                   	push   %edi
  c2:	56                   	push   %esi
  c3:	53                   	push   %ebx
  c4:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  ca:	83 ec 08             	sub    $0x8,%esp
  cd:	6a 00                	push   $0x0
  cf:	ff 75 08             	pushl  0x8(%ebp)
  d2:	e8 32 05 00 00       	call   609 <open>
  d7:	83 c4 10             	add    $0x10,%esp
  da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  e1:	79 1a                	jns    fd <ls+0x43>
    printf(2, "ls: cannot open %s\n", path);
  e3:	83 ec 04             	sub    $0x4,%esp
  e6:	ff 75 08             	pushl  0x8(%ebp)
  e9:	68 2c 0b 00 00       	push   $0xb2c
  ee:	6a 02                	push   $0x2
  f0:	e8 70 06 00 00       	call   765 <printf>
  f5:	83 c4 10             	add    $0x10,%esp
    return;
  f8:	e9 e1 01 00 00       	jmp    2de <ls+0x224>
  }

  if(fstat(fd, &st) < 0){
  fd:	83 ec 08             	sub    $0x8,%esp
 100:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 106:	50                   	push   %eax
 107:	ff 75 e4             	pushl  -0x1c(%ebp)
 10a:	e8 12 05 00 00       	call   621 <fstat>
 10f:	83 c4 10             	add    $0x10,%esp
 112:	85 c0                	test   %eax,%eax
 114:	79 28                	jns    13e <ls+0x84>
    printf(2, "ls: cannot stat %s\n", path);
 116:	83 ec 04             	sub    $0x4,%esp
 119:	ff 75 08             	pushl  0x8(%ebp)
 11c:	68 40 0b 00 00       	push   $0xb40
 121:	6a 02                	push   $0x2
 123:	e8 3d 06 00 00       	call   765 <printf>
 128:	83 c4 10             	add    $0x10,%esp
    close(fd);
 12b:	83 ec 0c             	sub    $0xc,%esp
 12e:	ff 75 e4             	pushl  -0x1c(%ebp)
 131:	e8 bb 04 00 00       	call   5f1 <close>
 136:	83 c4 10             	add    $0x10,%esp
    return;
 139:	e9 a0 01 00 00       	jmp    2de <ls+0x224>
  }

  switch(st.type){
 13e:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 145:	98                   	cwtl   
 146:	83 f8 01             	cmp    $0x1,%eax
 149:	74 48                	je     193 <ls+0xd9>
 14b:	83 f8 02             	cmp    $0x2,%eax
 14e:	0f 85 7c 01 00 00    	jne    2d0 <ls+0x216>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 154:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 15a:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 160:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 167:	0f bf d8             	movswl %ax,%ebx
 16a:	83 ec 0c             	sub    $0xc,%esp
 16d:	ff 75 08             	pushl  0x8(%ebp)
 170:	e8 8b fe ff ff       	call   0 <fmtname>
 175:	83 c4 10             	add    $0x10,%esp
 178:	83 ec 08             	sub    $0x8,%esp
 17b:	57                   	push   %edi
 17c:	56                   	push   %esi
 17d:	53                   	push   %ebx
 17e:	50                   	push   %eax
 17f:	68 54 0b 00 00       	push   $0xb54
 184:	6a 01                	push   $0x1
 186:	e8 da 05 00 00       	call   765 <printf>
 18b:	83 c4 20             	add    $0x20,%esp
    break;
 18e:	e9 3d 01 00 00       	jmp    2d0 <ls+0x216>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 193:	83 ec 0c             	sub    $0xc,%esp
 196:	ff 75 08             	pushl  0x8(%ebp)
 199:	e8 4d 02 00 00       	call   3eb <strlen>
 19e:	83 c4 10             	add    $0x10,%esp
 1a1:	83 c0 10             	add    $0x10,%eax
 1a4:	3d 00 02 00 00       	cmp    $0x200,%eax
 1a9:	76 17                	jbe    1c2 <ls+0x108>
      printf(1, "ls: path too long\n");
 1ab:	83 ec 08             	sub    $0x8,%esp
 1ae:	68 61 0b 00 00       	push   $0xb61
 1b3:	6a 01                	push   $0x1
 1b5:	e8 ab 05 00 00       	call   765 <printf>
 1ba:	83 c4 10             	add    $0x10,%esp
      break;
 1bd:	e9 0e 01 00 00       	jmp    2d0 <ls+0x216>
    }
    strcpy(buf, path);
 1c2:	83 ec 08             	sub    $0x8,%esp
 1c5:	ff 75 08             	pushl  0x8(%ebp)
 1c8:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1ce:	50                   	push   %eax
 1cf:	e8 a0 01 00 00       	call   374 <strcpy>
 1d4:	83 c4 10             	add    $0x10,%esp
    p = buf+strlen(buf);
 1d7:	83 ec 0c             	sub    $0xc,%esp
 1da:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1e0:	50                   	push   %eax
 1e1:	e8 05 02 00 00       	call   3eb <strlen>
 1e6:	83 c4 10             	add    $0x10,%esp
 1e9:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1ef:	01 d0                	add    %edx,%eax
 1f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1f7:	8d 50 01             	lea    0x1(%eax),%edx
 1fa:	89 55 e0             	mov    %edx,-0x20(%ebp)
 1fd:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 200:	e9 aa 00 00 00       	jmp    2af <ls+0x1f5>
      if(de.inum == 0)
 205:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 20c:	66 85 c0             	test   %ax,%ax
 20f:	75 05                	jne    216 <ls+0x15c>
        continue;
 211:	e9 99 00 00 00       	jmp    2af <ls+0x1f5>
      memmove(p, de.name, DIRSIZ);
 216:	83 ec 04             	sub    $0x4,%esp
 219:	6a 0e                	push   $0xe
 21b:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 221:	83 c0 02             	add    $0x2,%eax
 224:	50                   	push   %eax
 225:	ff 75 e0             	pushl  -0x20(%ebp)
 228:	e8 53 03 00 00       	call   580 <memmove>
 22d:	83 c4 10             	add    $0x10,%esp
      p[DIRSIZ] = 0;
 230:	8b 45 e0             	mov    -0x20(%ebp),%eax
 233:	83 c0 0e             	add    $0xe,%eax
 236:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 239:	83 ec 08             	sub    $0x8,%esp
 23c:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 242:	50                   	push   %eax
 243:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 249:	50                   	push   %eax
 24a:	e8 8f 02 00 00       	call   4de <stat>
 24f:	83 c4 10             	add    $0x10,%esp
 252:	85 c0                	test   %eax,%eax
 254:	79 1b                	jns    271 <ls+0x1b7>
        printf(1, "ls: cannot stat %s\n", buf);
 256:	83 ec 04             	sub    $0x4,%esp
 259:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 25f:	50                   	push   %eax
 260:	68 40 0b 00 00       	push   $0xb40
 265:	6a 01                	push   $0x1
 267:	e8 f9 04 00 00       	call   765 <printf>
 26c:	83 c4 10             	add    $0x10,%esp
        continue;
 26f:	eb 3e                	jmp    2af <ls+0x1f5>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 271:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 277:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 27d:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 284:	0f bf d8             	movswl %ax,%ebx
 287:	83 ec 0c             	sub    $0xc,%esp
 28a:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 290:	50                   	push   %eax
 291:	e8 6a fd ff ff       	call   0 <fmtname>
 296:	83 c4 10             	add    $0x10,%esp
 299:	83 ec 08             	sub    $0x8,%esp
 29c:	57                   	push   %edi
 29d:	56                   	push   %esi
 29e:	53                   	push   %ebx
 29f:	50                   	push   %eax
 2a0:	68 54 0b 00 00       	push   $0xb54
 2a5:	6a 01                	push   $0x1
 2a7:	e8 b9 04 00 00       	call   765 <printf>
 2ac:	83 c4 20             	add    $0x20,%esp
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2af:	83 ec 04             	sub    $0x4,%esp
 2b2:	6a 10                	push   $0x10
 2b4:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2ba:	50                   	push   %eax
 2bb:	ff 75 e4             	pushl  -0x1c(%ebp)
 2be:	e8 1e 03 00 00       	call   5e1 <read>
 2c3:	83 c4 10             	add    $0x10,%esp
 2c6:	83 f8 10             	cmp    $0x10,%eax
 2c9:	0f 84 36 ff ff ff    	je     205 <ls+0x14b>
    }
    break;
 2cf:	90                   	nop
  }
  close(fd);
 2d0:	83 ec 0c             	sub    $0xc,%esp
 2d3:	ff 75 e4             	pushl  -0x1c(%ebp)
 2d6:	e8 16 03 00 00       	call   5f1 <close>
 2db:	83 c4 10             	add    $0x10,%esp
}
 2de:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2e1:	5b                   	pop    %ebx
 2e2:	5e                   	pop    %esi
 2e3:	5f                   	pop    %edi
 2e4:	5d                   	pop    %ebp
 2e5:	c3                   	ret    

000002e6 <main>:

int
main(int argc, char *argv[])
{
 2e6:	f3 0f 1e fb          	endbr32 
 2ea:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 2ee:	83 e4 f0             	and    $0xfffffff0,%esp
 2f1:	ff 71 fc             	pushl  -0x4(%ecx)
 2f4:	55                   	push   %ebp
 2f5:	89 e5                	mov    %esp,%ebp
 2f7:	53                   	push   %ebx
 2f8:	51                   	push   %ecx
 2f9:	83 ec 10             	sub    $0x10,%esp
 2fc:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
 2fe:	83 3b 01             	cmpl   $0x1,(%ebx)
 301:	7f 15                	jg     318 <main+0x32>
    ls(".");
 303:	83 ec 0c             	sub    $0xc,%esp
 306:	68 74 0b 00 00       	push   $0xb74
 30b:	e8 aa fd ff ff       	call   ba <ls>
 310:	83 c4 10             	add    $0x10,%esp
    exit();
 313:	e8 b1 02 00 00       	call   5c9 <exit>
  }
  for(i=1; i<argc; i++)
 318:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
 31f:	eb 21                	jmp    342 <main+0x5c>
    ls(argv[i]);
 321:	8b 45 f4             	mov    -0xc(%ebp),%eax
 324:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 32b:	8b 43 04             	mov    0x4(%ebx),%eax
 32e:	01 d0                	add    %edx,%eax
 330:	8b 00                	mov    (%eax),%eax
 332:	83 ec 0c             	sub    $0xc,%esp
 335:	50                   	push   %eax
 336:	e8 7f fd ff ff       	call   ba <ls>
 33b:	83 c4 10             	add    $0x10,%esp
  for(i=1; i<argc; i++)
 33e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 342:	8b 45 f4             	mov    -0xc(%ebp),%eax
 345:	3b 03                	cmp    (%ebx),%eax
 347:	7c d8                	jl     321 <main+0x3b>
  exit();
 349:	e8 7b 02 00 00       	call   5c9 <exit>

0000034e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 34e:	55                   	push   %ebp
 34f:	89 e5                	mov    %esp,%ebp
 351:	57                   	push   %edi
 352:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 353:	8b 4d 08             	mov    0x8(%ebp),%ecx
 356:	8b 55 10             	mov    0x10(%ebp),%edx
 359:	8b 45 0c             	mov    0xc(%ebp),%eax
 35c:	89 cb                	mov    %ecx,%ebx
 35e:	89 df                	mov    %ebx,%edi
 360:	89 d1                	mov    %edx,%ecx
 362:	fc                   	cld    
 363:	f3 aa                	rep stos %al,%es:(%edi)
 365:	89 ca                	mov    %ecx,%edx
 367:	89 fb                	mov    %edi,%ebx
 369:	89 5d 08             	mov    %ebx,0x8(%ebp)
 36c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 36f:	90                   	nop
 370:	5b                   	pop    %ebx
 371:	5f                   	pop    %edi
 372:	5d                   	pop    %ebp
 373:	c3                   	ret    

00000374 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 374:	f3 0f 1e fb          	endbr32 
 378:	55                   	push   %ebp
 379:	89 e5                	mov    %esp,%ebp
 37b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 37e:	8b 45 08             	mov    0x8(%ebp),%eax
 381:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 384:	90                   	nop
 385:	8b 55 0c             	mov    0xc(%ebp),%edx
 388:	8d 42 01             	lea    0x1(%edx),%eax
 38b:	89 45 0c             	mov    %eax,0xc(%ebp)
 38e:	8b 45 08             	mov    0x8(%ebp),%eax
 391:	8d 48 01             	lea    0x1(%eax),%ecx
 394:	89 4d 08             	mov    %ecx,0x8(%ebp)
 397:	0f b6 12             	movzbl (%edx),%edx
 39a:	88 10                	mov    %dl,(%eax)
 39c:	0f b6 00             	movzbl (%eax),%eax
 39f:	84 c0                	test   %al,%al
 3a1:	75 e2                	jne    385 <strcpy+0x11>
    ;
  return os;
 3a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a6:	c9                   	leave  
 3a7:	c3                   	ret    

000003a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3a8:	f3 0f 1e fb          	endbr32 
 3ac:	55                   	push   %ebp
 3ad:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3af:	eb 08                	jmp    3b9 <strcmp+0x11>
    p++, q++;
 3b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 3b9:	8b 45 08             	mov    0x8(%ebp),%eax
 3bc:	0f b6 00             	movzbl (%eax),%eax
 3bf:	84 c0                	test   %al,%al
 3c1:	74 10                	je     3d3 <strcmp+0x2b>
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	0f b6 10             	movzbl (%eax),%edx
 3c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cc:	0f b6 00             	movzbl (%eax),%eax
 3cf:	38 c2                	cmp    %al,%dl
 3d1:	74 de                	je     3b1 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	0f b6 00             	movzbl (%eax),%eax
 3d9:	0f b6 d0             	movzbl %al,%edx
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	0f b6 00             	movzbl (%eax),%eax
 3e2:	0f b6 c0             	movzbl %al,%eax
 3e5:	29 c2                	sub    %eax,%edx
 3e7:	89 d0                	mov    %edx,%eax
}
 3e9:	5d                   	pop    %ebp
 3ea:	c3                   	ret    

000003eb <strlen>:

uint
strlen(char *s)
{
 3eb:	f3 0f 1e fb          	endbr32 
 3ef:	55                   	push   %ebp
 3f0:	89 e5                	mov    %esp,%ebp
 3f2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3f5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3fc:	eb 04                	jmp    402 <strlen+0x17>
 3fe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 402:	8b 55 fc             	mov    -0x4(%ebp),%edx
 405:	8b 45 08             	mov    0x8(%ebp),%eax
 408:	01 d0                	add    %edx,%eax
 40a:	0f b6 00             	movzbl (%eax),%eax
 40d:	84 c0                	test   %al,%al
 40f:	75 ed                	jne    3fe <strlen+0x13>
    ;
  return n;
 411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 414:	c9                   	leave  
 415:	c3                   	ret    

00000416 <memset>:

void*
memset(void *dst, int c, uint n)
{
 416:	f3 0f 1e fb          	endbr32 
 41a:	55                   	push   %ebp
 41b:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 41d:	8b 45 10             	mov    0x10(%ebp),%eax
 420:	50                   	push   %eax
 421:	ff 75 0c             	pushl  0xc(%ebp)
 424:	ff 75 08             	pushl  0x8(%ebp)
 427:	e8 22 ff ff ff       	call   34e <stosb>
 42c:	83 c4 0c             	add    $0xc,%esp
  return dst;
 42f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 432:	c9                   	leave  
 433:	c3                   	ret    

00000434 <strchr>:

char*
strchr(const char *s, char c)
{
 434:	f3 0f 1e fb          	endbr32 
 438:	55                   	push   %ebp
 439:	89 e5                	mov    %esp,%ebp
 43b:	83 ec 04             	sub    $0x4,%esp
 43e:	8b 45 0c             	mov    0xc(%ebp),%eax
 441:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 444:	eb 14                	jmp    45a <strchr+0x26>
    if(*s == c)
 446:	8b 45 08             	mov    0x8(%ebp),%eax
 449:	0f b6 00             	movzbl (%eax),%eax
 44c:	38 45 fc             	cmp    %al,-0x4(%ebp)
 44f:	75 05                	jne    456 <strchr+0x22>
      return (char*)s;
 451:	8b 45 08             	mov    0x8(%ebp),%eax
 454:	eb 13                	jmp    469 <strchr+0x35>
  for(; *s; s++)
 456:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 45a:	8b 45 08             	mov    0x8(%ebp),%eax
 45d:	0f b6 00             	movzbl (%eax),%eax
 460:	84 c0                	test   %al,%al
 462:	75 e2                	jne    446 <strchr+0x12>
  return 0;
 464:	b8 00 00 00 00       	mov    $0x0,%eax
}
 469:	c9                   	leave  
 46a:	c3                   	ret    

0000046b <gets>:

char*
gets(char *buf, int max)
{
 46b:	f3 0f 1e fb          	endbr32 
 46f:	55                   	push   %ebp
 470:	89 e5                	mov    %esp,%ebp
 472:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 475:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 47c:	eb 42                	jmp    4c0 <gets+0x55>
    cc = read(0, &c, 1);
 47e:	83 ec 04             	sub    $0x4,%esp
 481:	6a 01                	push   $0x1
 483:	8d 45 ef             	lea    -0x11(%ebp),%eax
 486:	50                   	push   %eax
 487:	6a 00                	push   $0x0
 489:	e8 53 01 00 00       	call   5e1 <read>
 48e:	83 c4 10             	add    $0x10,%esp
 491:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 494:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 498:	7e 33                	jle    4cd <gets+0x62>
      break;
    buf[i++] = c;
 49a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49d:	8d 50 01             	lea    0x1(%eax),%edx
 4a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4a3:	89 c2                	mov    %eax,%edx
 4a5:	8b 45 08             	mov    0x8(%ebp),%eax
 4a8:	01 c2                	add    %eax,%edx
 4aa:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ae:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4b0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b4:	3c 0a                	cmp    $0xa,%al
 4b6:	74 16                	je     4ce <gets+0x63>
 4b8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4bc:	3c 0d                	cmp    $0xd,%al
 4be:	74 0e                	je     4ce <gets+0x63>
  for(i=0; i+1 < max; ){
 4c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c3:	83 c0 01             	add    $0x1,%eax
 4c6:	39 45 0c             	cmp    %eax,0xc(%ebp)
 4c9:	7f b3                	jg     47e <gets+0x13>
 4cb:	eb 01                	jmp    4ce <gets+0x63>
      break;
 4cd:	90                   	nop
      break;
  }
  buf[i] = '\0';
 4ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4d1:	8b 45 08             	mov    0x8(%ebp),%eax
 4d4:	01 d0                	add    %edx,%eax
 4d6:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4d9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4dc:	c9                   	leave  
 4dd:	c3                   	ret    

000004de <stat>:

int
stat(char *n, struct stat *st)
{
 4de:	f3 0f 1e fb          	endbr32 
 4e2:	55                   	push   %ebp
 4e3:	89 e5                	mov    %esp,%ebp
 4e5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4e8:	83 ec 08             	sub    $0x8,%esp
 4eb:	6a 00                	push   $0x0
 4ed:	ff 75 08             	pushl  0x8(%ebp)
 4f0:	e8 14 01 00 00       	call   609 <open>
 4f5:	83 c4 10             	add    $0x10,%esp
 4f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ff:	79 07                	jns    508 <stat+0x2a>
    return -1;
 501:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 506:	eb 25                	jmp    52d <stat+0x4f>
  r = fstat(fd, st);
 508:	83 ec 08             	sub    $0x8,%esp
 50b:	ff 75 0c             	pushl  0xc(%ebp)
 50e:	ff 75 f4             	pushl  -0xc(%ebp)
 511:	e8 0b 01 00 00       	call   621 <fstat>
 516:	83 c4 10             	add    $0x10,%esp
 519:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 51c:	83 ec 0c             	sub    $0xc,%esp
 51f:	ff 75 f4             	pushl  -0xc(%ebp)
 522:	e8 ca 00 00 00       	call   5f1 <close>
 527:	83 c4 10             	add    $0x10,%esp
  return r;
 52a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 52d:	c9                   	leave  
 52e:	c3                   	ret    

0000052f <atoi>:

int
atoi(const char *s)
{
 52f:	f3 0f 1e fb          	endbr32 
 533:	55                   	push   %ebp
 534:	89 e5                	mov    %esp,%ebp
 536:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 539:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 540:	eb 25                	jmp    567 <atoi+0x38>
    n = n*10 + *s++ - '0';
 542:	8b 55 fc             	mov    -0x4(%ebp),%edx
 545:	89 d0                	mov    %edx,%eax
 547:	c1 e0 02             	shl    $0x2,%eax
 54a:	01 d0                	add    %edx,%eax
 54c:	01 c0                	add    %eax,%eax
 54e:	89 c1                	mov    %eax,%ecx
 550:	8b 45 08             	mov    0x8(%ebp),%eax
 553:	8d 50 01             	lea    0x1(%eax),%edx
 556:	89 55 08             	mov    %edx,0x8(%ebp)
 559:	0f b6 00             	movzbl (%eax),%eax
 55c:	0f be c0             	movsbl %al,%eax
 55f:	01 c8                	add    %ecx,%eax
 561:	83 e8 30             	sub    $0x30,%eax
 564:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	0f b6 00             	movzbl (%eax),%eax
 56d:	3c 2f                	cmp    $0x2f,%al
 56f:	7e 0a                	jle    57b <atoi+0x4c>
 571:	8b 45 08             	mov    0x8(%ebp),%eax
 574:	0f b6 00             	movzbl (%eax),%eax
 577:	3c 39                	cmp    $0x39,%al
 579:	7e c7                	jle    542 <atoi+0x13>
  return n;
 57b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 57e:	c9                   	leave  
 57f:	c3                   	ret    

00000580 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 580:	f3 0f 1e fb          	endbr32 
 584:	55                   	push   %ebp
 585:	89 e5                	mov    %esp,%ebp
 587:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 58a:	8b 45 08             	mov    0x8(%ebp),%eax
 58d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 590:	8b 45 0c             	mov    0xc(%ebp),%eax
 593:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 596:	eb 17                	jmp    5af <memmove+0x2f>
    *dst++ = *src++;
 598:	8b 55 f8             	mov    -0x8(%ebp),%edx
 59b:	8d 42 01             	lea    0x1(%edx),%eax
 59e:	89 45 f8             	mov    %eax,-0x8(%ebp)
 5a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5a4:	8d 48 01             	lea    0x1(%eax),%ecx
 5a7:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 5aa:	0f b6 12             	movzbl (%edx),%edx
 5ad:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 5af:	8b 45 10             	mov    0x10(%ebp),%eax
 5b2:	8d 50 ff             	lea    -0x1(%eax),%edx
 5b5:	89 55 10             	mov    %edx,0x10(%ebp)
 5b8:	85 c0                	test   %eax,%eax
 5ba:	7f dc                	jg     598 <memmove+0x18>
  return vdst;
 5bc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5bf:	c9                   	leave  
 5c0:	c3                   	ret    

000005c1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5c1:	b8 01 00 00 00       	mov    $0x1,%eax
 5c6:	cd 40                	int    $0x40
 5c8:	c3                   	ret    

000005c9 <exit>:
SYSCALL(exit)
 5c9:	b8 02 00 00 00       	mov    $0x2,%eax
 5ce:	cd 40                	int    $0x40
 5d0:	c3                   	ret    

000005d1 <wait>:
SYSCALL(wait)
 5d1:	b8 03 00 00 00       	mov    $0x3,%eax
 5d6:	cd 40                	int    $0x40
 5d8:	c3                   	ret    

000005d9 <pipe>:
SYSCALL(pipe)
 5d9:	b8 04 00 00 00       	mov    $0x4,%eax
 5de:	cd 40                	int    $0x40
 5e0:	c3                   	ret    

000005e1 <read>:
SYSCALL(read)
 5e1:	b8 05 00 00 00       	mov    $0x5,%eax
 5e6:	cd 40                	int    $0x40
 5e8:	c3                   	ret    

000005e9 <write>:
SYSCALL(write)
 5e9:	b8 10 00 00 00       	mov    $0x10,%eax
 5ee:	cd 40                	int    $0x40
 5f0:	c3                   	ret    

000005f1 <close>:
SYSCALL(close)
 5f1:	b8 15 00 00 00       	mov    $0x15,%eax
 5f6:	cd 40                	int    $0x40
 5f8:	c3                   	ret    

000005f9 <kill>:
SYSCALL(kill)
 5f9:	b8 06 00 00 00       	mov    $0x6,%eax
 5fe:	cd 40                	int    $0x40
 600:	c3                   	ret    

00000601 <exec>:
SYSCALL(exec)
 601:	b8 07 00 00 00       	mov    $0x7,%eax
 606:	cd 40                	int    $0x40
 608:	c3                   	ret    

00000609 <open>:
SYSCALL(open)
 609:	b8 0f 00 00 00       	mov    $0xf,%eax
 60e:	cd 40                	int    $0x40
 610:	c3                   	ret    

00000611 <mknod>:
SYSCALL(mknod)
 611:	b8 11 00 00 00       	mov    $0x11,%eax
 616:	cd 40                	int    $0x40
 618:	c3                   	ret    

00000619 <unlink>:
SYSCALL(unlink)
 619:	b8 12 00 00 00       	mov    $0x12,%eax
 61e:	cd 40                	int    $0x40
 620:	c3                   	ret    

00000621 <fstat>:
SYSCALL(fstat)
 621:	b8 08 00 00 00       	mov    $0x8,%eax
 626:	cd 40                	int    $0x40
 628:	c3                   	ret    

00000629 <link>:
SYSCALL(link)
 629:	b8 13 00 00 00       	mov    $0x13,%eax
 62e:	cd 40                	int    $0x40
 630:	c3                   	ret    

00000631 <mkdir>:
SYSCALL(mkdir)
 631:	b8 14 00 00 00       	mov    $0x14,%eax
 636:	cd 40                	int    $0x40
 638:	c3                   	ret    

00000639 <chdir>:
SYSCALL(chdir)
 639:	b8 09 00 00 00       	mov    $0x9,%eax
 63e:	cd 40                	int    $0x40
 640:	c3                   	ret    

00000641 <dup>:
SYSCALL(dup)
 641:	b8 0a 00 00 00       	mov    $0xa,%eax
 646:	cd 40                	int    $0x40
 648:	c3                   	ret    

00000649 <getpid>:
SYSCALL(getpid)
 649:	b8 0b 00 00 00       	mov    $0xb,%eax
 64e:	cd 40                	int    $0x40
 650:	c3                   	ret    

00000651 <sbrk>:
SYSCALL(sbrk)
 651:	b8 0c 00 00 00       	mov    $0xc,%eax
 656:	cd 40                	int    $0x40
 658:	c3                   	ret    

00000659 <sleep>:
SYSCALL(sleep)
 659:	b8 0d 00 00 00       	mov    $0xd,%eax
 65e:	cd 40                	int    $0x40
 660:	c3                   	ret    

00000661 <uptime>:
SYSCALL(uptime)
 661:	b8 0e 00 00 00       	mov    $0xe,%eax
 666:	cd 40                	int    $0x40
 668:	c3                   	ret    

00000669 <exit2>:
SYSCALL(exit2)
 669:	b8 16 00 00 00       	mov    $0x16,%eax
 66e:	cd 40                	int    $0x40
 670:	c3                   	ret    

00000671 <wait2>:
SYSCALL(wait2)
 671:	b8 17 00 00 00       	mov    $0x17,%eax
 676:	cd 40                	int    $0x40
 678:	c3                   	ret    

00000679 <uthread_init>:
SYSCALL(uthread_init)
 679:	b8 18 00 00 00       	mov    $0x18,%eax
 67e:	cd 40                	int    $0x40
 680:	c3                   	ret    

00000681 <printpt>:
SYSCALL(printpt)
 681:	b8 19 00 00 00       	mov    $0x19,%eax
 686:	cd 40                	int    $0x40
 688:	c3                   	ret    

00000689 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 689:	f3 0f 1e fb          	endbr32 
 68d:	55                   	push   %ebp
 68e:	89 e5                	mov    %esp,%ebp
 690:	83 ec 18             	sub    $0x18,%esp
 693:	8b 45 0c             	mov    0xc(%ebp),%eax
 696:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 699:	83 ec 04             	sub    $0x4,%esp
 69c:	6a 01                	push   $0x1
 69e:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6a1:	50                   	push   %eax
 6a2:	ff 75 08             	pushl  0x8(%ebp)
 6a5:	e8 3f ff ff ff       	call   5e9 <write>
 6aa:	83 c4 10             	add    $0x10,%esp
}
 6ad:	90                   	nop
 6ae:	c9                   	leave  
 6af:	c3                   	ret    

000006b0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6b0:	f3 0f 1e fb          	endbr32 
 6b4:	55                   	push   %ebp
 6b5:	89 e5                	mov    %esp,%ebp
 6b7:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6c1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6c5:	74 17                	je     6de <printint+0x2e>
 6c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6cb:	79 11                	jns    6de <printint+0x2e>
    neg = 1;
 6cd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d7:	f7 d8                	neg    %eax
 6d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6dc:	eb 06                	jmp    6e4 <printint+0x34>
  } else {
    x = xx;
 6de:	8b 45 0c             	mov    0xc(%ebp),%eax
 6e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 6ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f1:	ba 00 00 00 00       	mov    $0x0,%edx
 6f6:	f7 f1                	div    %ecx
 6f8:	89 d1                	mov    %edx,%ecx
 6fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6fd:	8d 50 01             	lea    0x1(%eax),%edx
 700:	89 55 f4             	mov    %edx,-0xc(%ebp)
 703:	0f b6 91 1c 0e 00 00 	movzbl 0xe1c(%ecx),%edx
 70a:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 70e:	8b 4d 10             	mov    0x10(%ebp),%ecx
 711:	8b 45 ec             	mov    -0x14(%ebp),%eax
 714:	ba 00 00 00 00       	mov    $0x0,%edx
 719:	f7 f1                	div    %ecx
 71b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 71e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 722:	75 c7                	jne    6eb <printint+0x3b>
  if(neg)
 724:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 728:	74 2d                	je     757 <printint+0xa7>
    buf[i++] = '-';
 72a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72d:	8d 50 01             	lea    0x1(%eax),%edx
 730:	89 55 f4             	mov    %edx,-0xc(%ebp)
 733:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 738:	eb 1d                	jmp    757 <printint+0xa7>
    putc(fd, buf[i]);
 73a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 740:	01 d0                	add    %edx,%eax
 742:	0f b6 00             	movzbl (%eax),%eax
 745:	0f be c0             	movsbl %al,%eax
 748:	83 ec 08             	sub    $0x8,%esp
 74b:	50                   	push   %eax
 74c:	ff 75 08             	pushl  0x8(%ebp)
 74f:	e8 35 ff ff ff       	call   689 <putc>
 754:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 757:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 75b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 75f:	79 d9                	jns    73a <printint+0x8a>
}
 761:	90                   	nop
 762:	90                   	nop
 763:	c9                   	leave  
 764:	c3                   	ret    

00000765 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 765:	f3 0f 1e fb          	endbr32 
 769:	55                   	push   %ebp
 76a:	89 e5                	mov    %esp,%ebp
 76c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 76f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 776:	8d 45 0c             	lea    0xc(%ebp),%eax
 779:	83 c0 04             	add    $0x4,%eax
 77c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 77f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 786:	e9 59 01 00 00       	jmp    8e4 <printf+0x17f>
    c = fmt[i] & 0xff;
 78b:	8b 55 0c             	mov    0xc(%ebp),%edx
 78e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 791:	01 d0                	add    %edx,%eax
 793:	0f b6 00             	movzbl (%eax),%eax
 796:	0f be c0             	movsbl %al,%eax
 799:	25 ff 00 00 00       	and    $0xff,%eax
 79e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7a1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7a5:	75 2c                	jne    7d3 <printf+0x6e>
      if(c == '%'){
 7a7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7ab:	75 0c                	jne    7b9 <printf+0x54>
        state = '%';
 7ad:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 7b4:	e9 27 01 00 00       	jmp    8e0 <printf+0x17b>
      } else {
        putc(fd, c);
 7b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7bc:	0f be c0             	movsbl %al,%eax
 7bf:	83 ec 08             	sub    $0x8,%esp
 7c2:	50                   	push   %eax
 7c3:	ff 75 08             	pushl  0x8(%ebp)
 7c6:	e8 be fe ff ff       	call   689 <putc>
 7cb:	83 c4 10             	add    $0x10,%esp
 7ce:	e9 0d 01 00 00       	jmp    8e0 <printf+0x17b>
      }
    } else if(state == '%'){
 7d3:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7d7:	0f 85 03 01 00 00    	jne    8e0 <printf+0x17b>
      if(c == 'd'){
 7dd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7e1:	75 1e                	jne    801 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 7e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e6:	8b 00                	mov    (%eax),%eax
 7e8:	6a 01                	push   $0x1
 7ea:	6a 0a                	push   $0xa
 7ec:	50                   	push   %eax
 7ed:	ff 75 08             	pushl  0x8(%ebp)
 7f0:	e8 bb fe ff ff       	call   6b0 <printint>
 7f5:	83 c4 10             	add    $0x10,%esp
        ap++;
 7f8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7fc:	e9 d8 00 00 00       	jmp    8d9 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 801:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 805:	74 06                	je     80d <printf+0xa8>
 807:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 80b:	75 1e                	jne    82b <printf+0xc6>
        printint(fd, *ap, 16, 0);
 80d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	6a 00                	push   $0x0
 814:	6a 10                	push   $0x10
 816:	50                   	push   %eax
 817:	ff 75 08             	pushl  0x8(%ebp)
 81a:	e8 91 fe ff ff       	call   6b0 <printint>
 81f:	83 c4 10             	add    $0x10,%esp
        ap++;
 822:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 826:	e9 ae 00 00 00       	jmp    8d9 <printf+0x174>
      } else if(c == 's'){
 82b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 82f:	75 43                	jne    874 <printf+0x10f>
        s = (char*)*ap;
 831:	8b 45 e8             	mov    -0x18(%ebp),%eax
 834:	8b 00                	mov    (%eax),%eax
 836:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 839:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 83d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 841:	75 25                	jne    868 <printf+0x103>
          s = "(null)";
 843:	c7 45 f4 76 0b 00 00 	movl   $0xb76,-0xc(%ebp)
        while(*s != 0){
 84a:	eb 1c                	jmp    868 <printf+0x103>
          putc(fd, *s);
 84c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84f:	0f b6 00             	movzbl (%eax),%eax
 852:	0f be c0             	movsbl %al,%eax
 855:	83 ec 08             	sub    $0x8,%esp
 858:	50                   	push   %eax
 859:	ff 75 08             	pushl  0x8(%ebp)
 85c:	e8 28 fe ff ff       	call   689 <putc>
 861:	83 c4 10             	add    $0x10,%esp
          s++;
 864:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 868:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86b:	0f b6 00             	movzbl (%eax),%eax
 86e:	84 c0                	test   %al,%al
 870:	75 da                	jne    84c <printf+0xe7>
 872:	eb 65                	jmp    8d9 <printf+0x174>
        }
      } else if(c == 'c'){
 874:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 878:	75 1d                	jne    897 <printf+0x132>
        putc(fd, *ap);
 87a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 87d:	8b 00                	mov    (%eax),%eax
 87f:	0f be c0             	movsbl %al,%eax
 882:	83 ec 08             	sub    $0x8,%esp
 885:	50                   	push   %eax
 886:	ff 75 08             	pushl  0x8(%ebp)
 889:	e8 fb fd ff ff       	call   689 <putc>
 88e:	83 c4 10             	add    $0x10,%esp
        ap++;
 891:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 895:	eb 42                	jmp    8d9 <printf+0x174>
      } else if(c == '%'){
 897:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 89b:	75 17                	jne    8b4 <printf+0x14f>
        putc(fd, c);
 89d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a0:	0f be c0             	movsbl %al,%eax
 8a3:	83 ec 08             	sub    $0x8,%esp
 8a6:	50                   	push   %eax
 8a7:	ff 75 08             	pushl  0x8(%ebp)
 8aa:	e8 da fd ff ff       	call   689 <putc>
 8af:	83 c4 10             	add    $0x10,%esp
 8b2:	eb 25                	jmp    8d9 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8b4:	83 ec 08             	sub    $0x8,%esp
 8b7:	6a 25                	push   $0x25
 8b9:	ff 75 08             	pushl  0x8(%ebp)
 8bc:	e8 c8 fd ff ff       	call   689 <putc>
 8c1:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8c7:	0f be c0             	movsbl %al,%eax
 8ca:	83 ec 08             	sub    $0x8,%esp
 8cd:	50                   	push   %eax
 8ce:	ff 75 08             	pushl  0x8(%ebp)
 8d1:	e8 b3 fd ff ff       	call   689 <putc>
 8d6:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8d9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 8e0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8e4:	8b 55 0c             	mov    0xc(%ebp),%edx
 8e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ea:	01 d0                	add    %edx,%eax
 8ec:	0f b6 00             	movzbl (%eax),%eax
 8ef:	84 c0                	test   %al,%al
 8f1:	0f 85 94 fe ff ff    	jne    78b <printf+0x26>
    }
  }
}
 8f7:	90                   	nop
 8f8:	90                   	nop
 8f9:	c9                   	leave  
 8fa:	c3                   	ret    

000008fb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8fb:	f3 0f 1e fb          	endbr32 
 8ff:	55                   	push   %ebp
 900:	89 e5                	mov    %esp,%ebp
 902:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 905:	8b 45 08             	mov    0x8(%ebp),%eax
 908:	83 e8 08             	sub    $0x8,%eax
 90b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90e:	a1 48 0e 00 00       	mov    0xe48,%eax
 913:	89 45 fc             	mov    %eax,-0x4(%ebp)
 916:	eb 24                	jmp    93c <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 918:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91b:	8b 00                	mov    (%eax),%eax
 91d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 920:	72 12                	jb     934 <free+0x39>
 922:	8b 45 f8             	mov    -0x8(%ebp),%eax
 925:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 928:	77 24                	ja     94e <free+0x53>
 92a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92d:	8b 00                	mov    (%eax),%eax
 92f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 932:	72 1a                	jb     94e <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 934:	8b 45 fc             	mov    -0x4(%ebp),%eax
 937:	8b 00                	mov    (%eax),%eax
 939:	89 45 fc             	mov    %eax,-0x4(%ebp)
 93c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 93f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 942:	76 d4                	jbe    918 <free+0x1d>
 944:	8b 45 fc             	mov    -0x4(%ebp),%eax
 947:	8b 00                	mov    (%eax),%eax
 949:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 94c:	73 ca                	jae    918 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 94e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 951:	8b 40 04             	mov    0x4(%eax),%eax
 954:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 95b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95e:	01 c2                	add    %eax,%edx
 960:	8b 45 fc             	mov    -0x4(%ebp),%eax
 963:	8b 00                	mov    (%eax),%eax
 965:	39 c2                	cmp    %eax,%edx
 967:	75 24                	jne    98d <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 969:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96c:	8b 50 04             	mov    0x4(%eax),%edx
 96f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 972:	8b 00                	mov    (%eax),%eax
 974:	8b 40 04             	mov    0x4(%eax),%eax
 977:	01 c2                	add    %eax,%edx
 979:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97c:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 97f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 982:	8b 00                	mov    (%eax),%eax
 984:	8b 10                	mov    (%eax),%edx
 986:	8b 45 f8             	mov    -0x8(%ebp),%eax
 989:	89 10                	mov    %edx,(%eax)
 98b:	eb 0a                	jmp    997 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 98d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 990:	8b 10                	mov    (%eax),%edx
 992:	8b 45 f8             	mov    -0x8(%ebp),%eax
 995:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 997:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99a:	8b 40 04             	mov    0x4(%eax),%eax
 99d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a7:	01 d0                	add    %edx,%eax
 9a9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9ac:	75 20                	jne    9ce <free+0xd3>
    p->s.size += bp->s.size;
 9ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b1:	8b 50 04             	mov    0x4(%eax),%edx
 9b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b7:	8b 40 04             	mov    0x4(%eax),%eax
 9ba:	01 c2                	add    %eax,%edx
 9bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bf:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c5:	8b 10                	mov    (%eax),%edx
 9c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ca:	89 10                	mov    %edx,(%eax)
 9cc:	eb 08                	jmp    9d6 <free+0xdb>
  } else
    p->s.ptr = bp;
 9ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d1:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9d4:	89 10                	mov    %edx,(%eax)
  freep = p;
 9d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d9:	a3 48 0e 00 00       	mov    %eax,0xe48
}
 9de:	90                   	nop
 9df:	c9                   	leave  
 9e0:	c3                   	ret    

000009e1 <morecore>:

static Header*
morecore(uint nu)
{
 9e1:	f3 0f 1e fb          	endbr32 
 9e5:	55                   	push   %ebp
 9e6:	89 e5                	mov    %esp,%ebp
 9e8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9eb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9f2:	77 07                	ja     9fb <morecore+0x1a>
    nu = 4096;
 9f4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9fb:	8b 45 08             	mov    0x8(%ebp),%eax
 9fe:	c1 e0 03             	shl    $0x3,%eax
 a01:	83 ec 0c             	sub    $0xc,%esp
 a04:	50                   	push   %eax
 a05:	e8 47 fc ff ff       	call   651 <sbrk>
 a0a:	83 c4 10             	add    $0x10,%esp
 a0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a10:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a14:	75 07                	jne    a1d <morecore+0x3c>
    return 0;
 a16:	b8 00 00 00 00       	mov    $0x0,%eax
 a1b:	eb 26                	jmp    a43 <morecore+0x62>
  hp = (Header*)p;
 a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a26:	8b 55 08             	mov    0x8(%ebp),%edx
 a29:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2f:	83 c0 08             	add    $0x8,%eax
 a32:	83 ec 0c             	sub    $0xc,%esp
 a35:	50                   	push   %eax
 a36:	e8 c0 fe ff ff       	call   8fb <free>
 a3b:	83 c4 10             	add    $0x10,%esp
  return freep;
 a3e:	a1 48 0e 00 00       	mov    0xe48,%eax
}
 a43:	c9                   	leave  
 a44:	c3                   	ret    

00000a45 <malloc>:

void*
malloc(uint nbytes)
{
 a45:	f3 0f 1e fb          	endbr32 
 a49:	55                   	push   %ebp
 a4a:	89 e5                	mov    %esp,%ebp
 a4c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a4f:	8b 45 08             	mov    0x8(%ebp),%eax
 a52:	83 c0 07             	add    $0x7,%eax
 a55:	c1 e8 03             	shr    $0x3,%eax
 a58:	83 c0 01             	add    $0x1,%eax
 a5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a5e:	a1 48 0e 00 00       	mov    0xe48,%eax
 a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a6a:	75 23                	jne    a8f <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 a6c:	c7 45 f0 40 0e 00 00 	movl   $0xe40,-0x10(%ebp)
 a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a76:	a3 48 0e 00 00       	mov    %eax,0xe48
 a7b:	a1 48 0e 00 00       	mov    0xe48,%eax
 a80:	a3 40 0e 00 00       	mov    %eax,0xe40
    base.s.size = 0;
 a85:	c7 05 44 0e 00 00 00 	movl   $0x0,0xe44
 a8c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a92:	8b 00                	mov    (%eax),%eax
 a94:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9a:	8b 40 04             	mov    0x4(%eax),%eax
 a9d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 aa0:	77 4d                	ja     aef <malloc+0xaa>
      if(p->s.size == nunits)
 aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa5:	8b 40 04             	mov    0x4(%eax),%eax
 aa8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 aab:	75 0c                	jne    ab9 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab0:	8b 10                	mov    (%eax),%edx
 ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab5:	89 10                	mov    %edx,(%eax)
 ab7:	eb 26                	jmp    adf <malloc+0x9a>
      else {
        p->s.size -= nunits;
 ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abc:	8b 40 04             	mov    0x4(%eax),%eax
 abf:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ac2:	89 c2                	mov    %eax,%edx
 ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acd:	8b 40 04             	mov    0x4(%eax),%eax
 ad0:	c1 e0 03             	shl    $0x3,%eax
 ad3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 adc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae2:	a3 48 0e 00 00       	mov    %eax,0xe48
      return (void*)(p + 1);
 ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aea:	83 c0 08             	add    $0x8,%eax
 aed:	eb 3b                	jmp    b2a <malloc+0xe5>
    }
    if(p == freep)
 aef:	a1 48 0e 00 00       	mov    0xe48,%eax
 af4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 af7:	75 1e                	jne    b17 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 af9:	83 ec 0c             	sub    $0xc,%esp
 afc:	ff 75 ec             	pushl  -0x14(%ebp)
 aff:	e8 dd fe ff ff       	call   9e1 <morecore>
 b04:	83 c4 10             	add    $0x10,%esp
 b07:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b0e:	75 07                	jne    b17 <malloc+0xd2>
        return 0;
 b10:	b8 00 00 00 00       	mov    $0x0,%eax
 b15:	eb 13                	jmp    b2a <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b20:	8b 00                	mov    (%eax),%eax
 b22:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b25:	e9 6d ff ff ff       	jmp    a97 <malloc+0x52>
  }
}
 b2a:	c9                   	leave  
 b2b:	c3                   	ret    
