
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr  
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr  

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 60 e3 18 80       	mov    $0x8018e360,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba ae 34 10 80       	mov    $0x801034ae,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	f3 0f 1e fb          	endbr32 
8010006a:	55                   	push   %ebp
8010006b:	89 e5                	mov    %esp,%ebp
8010006d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
80100070:	83 ec 08             	sub    $0x8,%esp
80100073:	68 00 a7 10 80       	push   $0x8010a700
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 e4 4a 00 00       	call   80104b66 <initlock>
80100082:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100085:	c7 05 ac 2a 19 80 5c 	movl   $0x80192a5c,0x80192aac
8010008c:	2a 19 80 
  bcache.head.next = &bcache.head;
8010008f:	c7 05 b0 2a 19 80 5c 	movl   $0x80192a5c,0x80192ab0
80100096:	2a 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100099:	c7 45 f4 94 e3 18 80 	movl   $0x8018e394,-0xc(%ebp)
801000a0:	eb 47                	jmp    801000e9 <binit+0x83>
    b->next = bcache.head.next;
801000a2:	8b 15 b0 2a 19 80    	mov    0x80192ab0,%edx
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b1:	c7 40 50 5c 2a 19 80 	movl   $0x80192a5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000bb:	83 c0 0c             	add    $0xc,%eax
801000be:	83 ec 08             	sub    $0x8,%esp
801000c1:	68 07 a7 10 80       	push   $0x8010a707
801000c6:	50                   	push   %eax
801000c7:	e8 2d 49 00 00       	call   801049f9 <initsleeplock>
801000cc:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cf:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
801000d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d7:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000dd:	a3 b0 2a 19 80       	mov    %eax,0x80192ab0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000e2:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e9:	b8 5c 2a 19 80       	mov    $0x80192a5c,%eax
801000ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000f1:	72 af                	jb     801000a2 <binit+0x3c>
  }
}
801000f3:	90                   	nop
801000f4:	90                   	nop
801000f5:	c9                   	leave  
801000f6:	c3                   	ret    

801000f7 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f7:	f3 0f 1e fb          	endbr32 
801000fb:	55                   	push   %ebp
801000fc:	89 e5                	mov    %esp,%ebp
801000fe:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
80100101:	83 ec 0c             	sub    $0xc,%esp
80100104:	68 60 e3 18 80       	push   $0x8018e360
80100109:	e8 7e 4a 00 00       	call   80104b8c <acquire>
8010010e:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100111:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
80100116:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100119:	eb 58                	jmp    80100173 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
8010011b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011e:	8b 40 04             	mov    0x4(%eax),%eax
80100121:	39 45 08             	cmp    %eax,0x8(%ebp)
80100124:	75 44                	jne    8010016a <bget+0x73>
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 08             	mov    0x8(%eax),%eax
8010012c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010012f:	75 39                	jne    8010016a <bget+0x73>
      b->refcnt++;
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 4c             	mov    0x4c(%eax),%eax
80100137:	8d 50 01             	lea    0x1(%eax),%edx
8010013a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013d:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100140:	83 ec 0c             	sub    $0xc,%esp
80100143:	68 60 e3 18 80       	push   $0x8018e360
80100148:	e8 b1 4a 00 00       	call   80104bfe <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 da 48 00 00       	call   80104a39 <acquiresleep>
8010015f:	83 c4 10             	add    $0x10,%esp
      return b;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	e9 9d 00 00 00       	jmp    80100207 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 40 54             	mov    0x54(%eax),%eax
80100170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100173:	81 7d f4 5c 2a 19 80 	cmpl   $0x80192a5c,-0xc(%ebp)
8010017a:	75 9f                	jne    8010011b <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010017c:	a1 ac 2a 19 80       	mov    0x80192aac,%eax
80100181:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100184:	eb 6b                	jmp    801001f1 <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 4c             	mov    0x4c(%eax),%eax
8010018c:	85 c0                	test   %eax,%eax
8010018e:	75 58                	jne    801001e8 <bget+0xf1>
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	8b 00                	mov    (%eax),%eax
80100195:	83 e0 04             	and    $0x4,%eax
80100198:	85 c0                	test   %eax,%eax
8010019a:	75 4c                	jne    801001e8 <bget+0xf1>
      b->dev = dev;
8010019c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019f:	8b 55 08             	mov    0x8(%ebp),%edx
801001a2:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
801001a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801001ab:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001ba:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001c1:	83 ec 0c             	sub    $0xc,%esp
801001c4:	68 60 e3 18 80       	push   $0x8018e360
801001c9:	e8 30 4a 00 00       	call   80104bfe <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 59 48 00 00       	call   80104a39 <acquiresleep>
801001e0:	83 c4 10             	add    $0x10,%esp
      return b;
801001e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e6:	eb 1f                	jmp    80100207 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 40 50             	mov    0x50(%eax),%eax
801001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001f1:	81 7d f4 5c 2a 19 80 	cmpl   $0x80192a5c,-0xc(%ebp)
801001f8:	75 8c                	jne    80100186 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001fa:	83 ec 0c             	sub    $0xc,%esp
801001fd:	68 0e a7 10 80       	push   $0x8010a70e
80100202:	e8 be 03 00 00       	call   801005c5 <panic>
}
80100207:	c9                   	leave  
80100208:	c3                   	ret    

80100209 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100209:	f3 0f 1e fb          	endbr32 
8010020d:	55                   	push   %ebp
8010020e:	89 e5                	mov    %esp,%ebp
80100210:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100213:	83 ec 08             	sub    $0x8,%esp
80100216:	ff 75 0c             	pushl  0xc(%ebp)
80100219:	ff 75 08             	pushl  0x8(%ebp)
8010021c:	e8 d6 fe ff ff       	call   801000f7 <bget>
80100221:	83 c4 10             	add    $0x10,%esp
80100224:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
80100227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010022a:	8b 00                	mov    (%eax),%eax
8010022c:	83 e0 02             	and    $0x2,%eax
8010022f:	85 c0                	test   %eax,%eax
80100231:	75 0e                	jne    80100241 <bread+0x38>
    iderw(b);
80100233:	83 ec 0c             	sub    $0xc,%esp
80100236:	ff 75 f4             	pushl  -0xc(%ebp)
80100239:	e8 c8 a3 00 00       	call   8010a606 <iderw>
8010023e:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100241:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100244:	c9                   	leave  
80100245:	c3                   	ret    

80100246 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100246:	f3 0f 1e fb          	endbr32 
8010024a:	55                   	push   %ebp
8010024b:	89 e5                	mov    %esp,%ebp
8010024d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	50                   	push   %eax
8010025a:	e8 94 48 00 00       	call   80104af3 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 1f a7 10 80       	push   $0x8010a71f
8010026e:	e8 52 03 00 00       	call   801005c5 <panic>
  b->flags |= B_DIRTY;
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	8b 00                	mov    (%eax),%eax
80100278:	83 c8 04             	or     $0x4,%eax
8010027b:	89 c2                	mov    %eax,%edx
8010027d:	8b 45 08             	mov    0x8(%ebp),%eax
80100280:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100282:	83 ec 0c             	sub    $0xc,%esp
80100285:	ff 75 08             	pushl  0x8(%ebp)
80100288:	e8 79 a3 00 00       	call   8010a606 <iderw>
8010028d:	83 c4 10             	add    $0x10,%esp
}
80100290:	90                   	nop
80100291:	c9                   	leave  
80100292:	c3                   	ret    

80100293 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100293:	f3 0f 1e fb          	endbr32 
80100297:	55                   	push   %ebp
80100298:	89 e5                	mov    %esp,%ebp
8010029a:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010029d:	8b 45 08             	mov    0x8(%ebp),%eax
801002a0:	83 c0 0c             	add    $0xc,%eax
801002a3:	83 ec 0c             	sub    $0xc,%esp
801002a6:	50                   	push   %eax
801002a7:	e8 47 48 00 00       	call   80104af3 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 26 a7 10 80       	push   $0x8010a726
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 d2 47 00 00       	call   80104aa1 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 ad 48 00 00       	call   80104b8c <acquire>
801002df:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002e2:	8b 45 08             	mov    0x8(%ebp),%eax
801002e5:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e8:	8d 50 ff             	lea    -0x1(%eax),%edx
801002eb:	8b 45 08             	mov    0x8(%ebp),%eax
801002ee:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002f1:	8b 45 08             	mov    0x8(%ebp),%eax
801002f4:	8b 40 4c             	mov    0x4c(%eax),%eax
801002f7:	85 c0                	test   %eax,%eax
801002f9:	75 47                	jne    80100342 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002fb:	8b 45 08             	mov    0x8(%ebp),%eax
801002fe:	8b 40 54             	mov    0x54(%eax),%eax
80100301:	8b 55 08             	mov    0x8(%ebp),%edx
80100304:	8b 52 50             	mov    0x50(%edx),%edx
80100307:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	8b 40 50             	mov    0x50(%eax),%eax
80100310:	8b 55 08             	mov    0x8(%ebp),%edx
80100313:	8b 52 54             	mov    0x54(%edx),%edx
80100316:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100319:	8b 15 b0 2a 19 80    	mov    0x80192ab0,%edx
8010031f:	8b 45 08             	mov    0x8(%ebp),%eax
80100322:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100325:	8b 45 08             	mov    0x8(%ebp),%eax
80100328:	c7 40 50 5c 2a 19 80 	movl   $0x80192a5c,0x50(%eax)
    bcache.head.next->prev = b;
8010032f:	a1 b0 2a 19 80       	mov    0x80192ab0,%eax
80100334:	8b 55 08             	mov    0x8(%ebp),%edx
80100337:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	a3 b0 2a 19 80       	mov    %eax,0x80192ab0
  }
  
  release(&bcache.lock);
80100342:	83 ec 0c             	sub    $0xc,%esp
80100345:	68 60 e3 18 80       	push   $0x8018e360
8010034a:	e8 af 48 00 00       	call   80104bfe <release>
8010034f:	83 c4 10             	add    $0x10,%esp
}
80100352:	90                   	nop
80100353:	c9                   	leave  
80100354:	c3                   	ret    

80100355 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100355:	55                   	push   %ebp
80100356:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100358:	fa                   	cli    
}
80100359:	90                   	nop
8010035a:	5d                   	pop    %ebp
8010035b:	c3                   	ret    

8010035c <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
8010035c:	f3 0f 1e fb          	endbr32 
80100360:	55                   	push   %ebp
80100361:	89 e5                	mov    %esp,%ebp
80100363:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100366:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010036a:	74 1c                	je     80100388 <printint+0x2c>
8010036c:	8b 45 08             	mov    0x8(%ebp),%eax
8010036f:	c1 e8 1f             	shr    $0x1f,%eax
80100372:	0f b6 c0             	movzbl %al,%eax
80100375:	89 45 10             	mov    %eax,0x10(%ebp)
80100378:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010037c:	74 0a                	je     80100388 <printint+0x2c>
    x = -xx;
8010037e:	8b 45 08             	mov    0x8(%ebp),%eax
80100381:	f7 d8                	neg    %eax
80100383:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100386:	eb 06                	jmp    8010038e <printint+0x32>
  else
    x = xx;
80100388:	8b 45 08             	mov    0x8(%ebp),%eax
8010038b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010038e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100395:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010039b:	ba 00 00 00 00       	mov    $0x0,%edx
801003a0:	f7 f1                	div    %ecx
801003a2:	89 d1                	mov    %edx,%ecx
801003a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a7:	8d 50 01             	lea    0x1(%eax),%edx
801003aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003ad:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
801003b4:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003be:	ba 00 00 00 00       	mov    $0x0,%edx
801003c3:	f7 f1                	div    %ecx
801003c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003cc:	75 c7                	jne    80100395 <printint+0x39>

  if(sign)
801003ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003d2:	74 2a                	je     801003fe <printint+0xa2>
    buf[i++] = '-';
801003d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d7:	8d 50 01             	lea    0x1(%eax),%edx
801003da:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003dd:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003e2:	eb 1a                	jmp    801003fe <printint+0xa2>
    consputc(buf[i]);
801003e4:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003ea:	01 d0                	add    %edx,%eax
801003ec:	0f b6 00             	movzbl (%eax),%eax
801003ef:	0f be c0             	movsbl %al,%eax
801003f2:	83 ec 0c             	sub    $0xc,%esp
801003f5:	50                   	push   %eax
801003f6:	e8 9a 03 00 00       	call   80100795 <consputc>
801003fb:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003fe:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100402:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100406:	79 dc                	jns    801003e4 <printint+0x88>
}
80100408:	90                   	nop
80100409:	90                   	nop
8010040a:	c9                   	leave  
8010040b:	c3                   	ret    

8010040c <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
8010040c:	f3 0f 1e fb          	endbr32 
80100410:	55                   	push   %ebp
80100411:	89 e5                	mov    %esp,%ebp
80100413:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100416:	a1 54 d0 18 80       	mov    0x8018d054,%eax
8010041b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010041e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100422:	74 10                	je     80100434 <cprintf+0x28>
    acquire(&cons.lock);
80100424:	83 ec 0c             	sub    $0xc,%esp
80100427:	68 20 d0 18 80       	push   $0x8018d020
8010042c:	e8 5b 47 00 00       	call   80104b8c <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 2d a7 10 80       	push   $0x8010a72d
80100443:	e8 7d 01 00 00       	call   801005c5 <panic>


  argp = (uint*)(void*)(&fmt + 1);
80100448:	8d 45 0c             	lea    0xc(%ebp),%eax
8010044b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010044e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100455:	e9 2f 01 00 00       	jmp    80100589 <cprintf+0x17d>
    if(c != '%'){
8010045a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010045e:	74 13                	je     80100473 <cprintf+0x67>
      consputc(c);
80100460:	83 ec 0c             	sub    $0xc,%esp
80100463:	ff 75 e4             	pushl  -0x1c(%ebp)
80100466:	e8 2a 03 00 00       	call   80100795 <consputc>
8010046b:	83 c4 10             	add    $0x10,%esp
      continue;
8010046e:	e9 12 01 00 00       	jmp    80100585 <cprintf+0x179>
    }
    c = fmt[++i] & 0xff;
80100473:	8b 55 08             	mov    0x8(%ebp),%edx
80100476:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010047a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010047d:	01 d0                	add    %edx,%eax
8010047f:	0f b6 00             	movzbl (%eax),%eax
80100482:	0f be c0             	movsbl %al,%eax
80100485:	25 ff 00 00 00       	and    $0xff,%eax
8010048a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010048d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100491:	0f 84 14 01 00 00    	je     801005ab <cprintf+0x19f>
      break;
    switch(c){
80100497:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010049b:	74 5e                	je     801004fb <cprintf+0xef>
8010049d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004a1:	0f 8f c2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004a7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004ab:	74 6b                	je     80100518 <cprintf+0x10c>
801004ad:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004b1:	0f 8f b2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004b7:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004bb:	74 3e                	je     801004fb <cprintf+0xef>
801004bd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004c1:	0f 8f a2 00 00 00    	jg     80100569 <cprintf+0x15d>
801004c7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004cb:	0f 84 89 00 00 00    	je     8010055a <cprintf+0x14e>
801004d1:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004d5:	0f 85 8e 00 00 00    	jne    80100569 <cprintf+0x15d>
    case 'd':
      printint(*argp++, 10, 1);
801004db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004de:	8d 50 04             	lea    0x4(%eax),%edx
801004e1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e4:	8b 00                	mov    (%eax),%eax
801004e6:	83 ec 04             	sub    $0x4,%esp
801004e9:	6a 01                	push   $0x1
801004eb:	6a 0a                	push   $0xa
801004ed:	50                   	push   %eax
801004ee:	e8 69 fe ff ff       	call   8010035c <printint>
801004f3:	83 c4 10             	add    $0x10,%esp
      break;
801004f6:	e9 8a 00 00 00       	jmp    80100585 <cprintf+0x179>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fe:	8d 50 04             	lea    0x4(%eax),%edx
80100501:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100504:	8b 00                	mov    (%eax),%eax
80100506:	83 ec 04             	sub    $0x4,%esp
80100509:	6a 00                	push   $0x0
8010050b:	6a 10                	push   $0x10
8010050d:	50                   	push   %eax
8010050e:	e8 49 fe ff ff       	call   8010035c <printint>
80100513:	83 c4 10             	add    $0x10,%esp
      break;
80100516:	eb 6d                	jmp    80100585 <cprintf+0x179>
    case 's':
      if((s = (char*)*argp++) == 0)
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100526:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010052a:	75 22                	jne    8010054e <cprintf+0x142>
        s = "(null)";
8010052c:	c7 45 ec 36 a7 10 80 	movl   $0x8010a736,-0x14(%ebp)
      for(; *s; s++)
80100533:	eb 19                	jmp    8010054e <cprintf+0x142>
        consputc(*s);
80100535:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100538:	0f b6 00             	movzbl (%eax),%eax
8010053b:	0f be c0             	movsbl %al,%eax
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	50                   	push   %eax
80100542:	e8 4e 02 00 00       	call   80100795 <consputc>
80100547:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010054a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010054e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100551:	0f b6 00             	movzbl (%eax),%eax
80100554:	84 c0                	test   %al,%al
80100556:	75 dd                	jne    80100535 <cprintf+0x129>
      break;
80100558:	eb 2b                	jmp    80100585 <cprintf+0x179>
    case '%':
      consputc('%');
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	6a 25                	push   $0x25
8010055f:	e8 31 02 00 00       	call   80100795 <consputc>
80100564:	83 c4 10             	add    $0x10,%esp
      break;
80100567:	eb 1c                	jmp    80100585 <cprintf+0x179>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100569:	83 ec 0c             	sub    $0xc,%esp
8010056c:	6a 25                	push   $0x25
8010056e:	e8 22 02 00 00       	call   80100795 <consputc>
80100573:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100576:	83 ec 0c             	sub    $0xc,%esp
80100579:	ff 75 e4             	pushl  -0x1c(%ebp)
8010057c:	e8 14 02 00 00       	call   80100795 <consputc>
80100581:	83 c4 10             	add    $0x10,%esp
      break;
80100584:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100585:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100589:	8b 55 08             	mov    0x8(%ebp),%edx
8010058c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010058f:	01 d0                	add    %edx,%eax
80100591:	0f b6 00             	movzbl (%eax),%eax
80100594:	0f be c0             	movsbl %al,%eax
80100597:	25 ff 00 00 00       	and    $0xff,%eax
8010059c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010059f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005a3:	0f 85 b1 fe ff ff    	jne    8010045a <cprintf+0x4e>
801005a9:	eb 01                	jmp    801005ac <cprintf+0x1a0>
      break;
801005ab:	90                   	nop
    }
  }

  if(locking)
801005ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005b0:	74 10                	je     801005c2 <cprintf+0x1b6>
    release(&cons.lock);
801005b2:	83 ec 0c             	sub    $0xc,%esp
801005b5:	68 20 d0 18 80       	push   $0x8018d020
801005ba:	e8 3f 46 00 00       	call   80104bfe <release>
801005bf:	83 c4 10             	add    $0x10,%esp
}
801005c2:	90                   	nop
801005c3:	c9                   	leave  
801005c4:	c3                   	ret    

801005c5 <panic>:

void
panic(char *s)
{
801005c5:	f3 0f 1e fb          	endbr32 
801005c9:	55                   	push   %ebp
801005ca:	89 e5                	mov    %esp,%ebp
801005cc:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005cf:	e8 81 fd ff ff       	call   80100355 <cli>
  cons.locking = 0;
801005d4:	c7 05 54 d0 18 80 00 	movl   $0x0,0x8018d054
801005db:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005de:	e8 1c 26 00 00       	call   80102bff <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 3d a7 10 80       	push   $0x8010a73d
801005ec:	e8 1b fe ff ff       	call   8010040c <cprintf>
801005f1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005f4:	8b 45 08             	mov    0x8(%ebp),%eax
801005f7:	83 ec 0c             	sub    $0xc,%esp
801005fa:	50                   	push   %eax
801005fb:	e8 0c fe ff ff       	call   8010040c <cprintf>
80100600:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100603:	83 ec 0c             	sub    $0xc,%esp
80100606:	68 51 a7 10 80       	push   $0x8010a751
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 31 46 00 00       	call   80104c54 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 53 a7 10 80       	push   $0x8010a753
8010063f:	e8 c8 fd ff ff       	call   8010040c <cprintf>
80100644:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100647:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010064b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010064f:	7e de                	jle    8010062f <panic+0x6a>
  panicked = 1; // freeze other CPU
80100651:	c7 05 00 d0 18 80 01 	movl   $0x1,0x8018d000
80100658:	00 00 00 
  for(;;)
8010065b:	eb fe                	jmp    8010065b <panic+0x96>

8010065d <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010065d:	f3 0f 1e fb          	endbr32 
80100661:	55                   	push   %ebp
80100662:	89 e5                	mov    %esp,%ebp
80100664:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100667:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010066b:	75 64                	jne    801006d1 <graphic_putc+0x74>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8010066d:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100673:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100678:	89 c8                	mov    %ecx,%eax
8010067a:	f7 ea                	imul   %edx
8010067c:	c1 fa 04             	sar    $0x4,%edx
8010067f:	89 c8                	mov    %ecx,%eax
80100681:	c1 f8 1f             	sar    $0x1f,%eax
80100684:	29 c2                	sub    %eax,%edx
80100686:	89 d0                	mov    %edx,%eax
80100688:	6b c0 35             	imul   $0x35,%eax,%eax
8010068b:	29 c1                	sub    %eax,%ecx
8010068d:	89 c8                	mov    %ecx,%eax
8010068f:	ba 35 00 00 00       	mov    $0x35,%edx
80100694:	29 c2                	sub    %eax,%edx
80100696:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010069b:	01 d0                	add    %edx,%eax
8010069d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006a2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006a7:	3d 23 04 00 00       	cmp    $0x423,%eax
801006ac:	0f 8e e0 00 00 00    	jle    80100792 <graphic_putc+0x135>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006b2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006b7:	83 e8 35             	sub    $0x35,%eax
801006ba:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006bf:	83 ec 0c             	sub    $0xc,%esp
801006c2:	6a 1e                	push   $0x1e
801006c4:	e8 d1 7d 00 00       	call   8010849a <graphic_scroll_up>
801006c9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006cc:	e9 c1 00 00 00       	jmp    80100792 <graphic_putc+0x135>
  }else if(c == BACKSPACE){
801006d1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006d8:	75 1f                	jne    801006f9 <graphic_putc+0x9c>
    if(console_pos>0) --console_pos;
801006da:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006df:	85 c0                	test   %eax,%eax
801006e1:	0f 8e ab 00 00 00    	jle    80100792 <graphic_putc+0x135>
801006e7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006ec:	83 e8 01             	sub    $0x1,%eax
801006ef:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006f4:	e9 99 00 00 00       	jmp    80100792 <graphic_putc+0x135>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006f9:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006fe:	3d 23 04 00 00       	cmp    $0x423,%eax
80100703:	7e 1a                	jle    8010071f <graphic_putc+0xc2>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
80100705:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010070a:	83 e8 35             	sub    $0x35,%eax
8010070d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
80100712:	83 ec 0c             	sub    $0xc,%esp
80100715:	6a 1e                	push   $0x1e
80100717:	e8 7e 7d 00 00       	call   8010849a <graphic_scroll_up>
8010071c:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
8010071f:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100725:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010072a:	89 c8                	mov    %ecx,%eax
8010072c:	f7 ea                	imul   %edx
8010072e:	c1 fa 04             	sar    $0x4,%edx
80100731:	89 c8                	mov    %ecx,%eax
80100733:	c1 f8 1f             	sar    $0x1f,%eax
80100736:	29 c2                	sub    %eax,%edx
80100738:	89 d0                	mov    %edx,%eax
8010073a:	6b c0 35             	imul   $0x35,%eax,%eax
8010073d:	29 c1                	sub    %eax,%ecx
8010073f:	89 c8                	mov    %ecx,%eax
80100741:	89 c2                	mov    %eax,%edx
80100743:	c1 e2 04             	shl    $0x4,%edx
80100746:	29 c2                	sub    %eax,%edx
80100748:	89 d0                	mov    %edx,%eax
8010074a:	83 c0 02             	add    $0x2,%eax
8010074d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
80100750:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100756:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010075b:	89 c8                	mov    %ecx,%eax
8010075d:	f7 ea                	imul   %edx
8010075f:	c1 fa 04             	sar    $0x4,%edx
80100762:	89 c8                	mov    %ecx,%eax
80100764:	c1 f8 1f             	sar    $0x1f,%eax
80100767:	29 c2                	sub    %eax,%edx
80100769:	89 d0                	mov    %edx,%eax
8010076b:	6b c0 1e             	imul   $0x1e,%eax,%eax
8010076e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
80100771:	83 ec 04             	sub    $0x4,%esp
80100774:	ff 75 08             	pushl  0x8(%ebp)
80100777:	ff 75 f0             	pushl  -0x10(%ebp)
8010077a:	ff 75 f4             	pushl  -0xc(%ebp)
8010077d:	e8 8c 7d 00 00       	call   8010850e <font_render>
80100782:	83 c4 10             	add    $0x10,%esp
    console_pos++;
80100785:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010078a:	83 c0 01             	add    $0x1,%eax
8010078d:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
80100792:	90                   	nop
80100793:	c9                   	leave  
80100794:	c3                   	ret    

80100795 <consputc>:


void
consputc(int c)
{
80100795:	f3 0f 1e fb          	endbr32 
80100799:	55                   	push   %ebp
8010079a:	89 e5                	mov    %esp,%ebp
8010079c:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010079f:	a1 00 d0 18 80       	mov    0x8018d000,%eax
801007a4:	85 c0                	test   %eax,%eax
801007a6:	74 07                	je     801007af <consputc+0x1a>
    cli();
801007a8:	e8 a8 fb ff ff       	call   80100355 <cli>
    for(;;)
801007ad:	eb fe                	jmp    801007ad <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
801007af:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007b6:	75 29                	jne    801007e1 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b8:	83 ec 0c             	sub    $0xc,%esp
801007bb:	6a 08                	push   $0x8
801007bd:	e8 ec 60 00 00       	call   801068ae <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 df 60 00 00       	call   801068ae <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 d2 60 00 00       	call   801068ae <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 c2 60 00 00       	call   801068ae <uartputc>
801007ec:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007ef:	83 ec 0c             	sub    $0xc,%esp
801007f2:	ff 75 08             	pushl  0x8(%ebp)
801007f5:	e8 63 fe ff ff       	call   8010065d <graphic_putc>
801007fa:	83 c4 10             	add    $0x10,%esp
}
801007fd:	90                   	nop
801007fe:	c9                   	leave  
801007ff:	c3                   	ret    

80100800 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100800:	f3 0f 1e fb          	endbr32 
80100804:	55                   	push   %ebp
80100805:	89 e5                	mov    %esp,%ebp
80100807:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
8010080a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100811:	83 ec 0c             	sub    $0xc,%esp
80100814:	68 20 d0 18 80       	push   $0x8018d020
80100819:	e8 6e 43 00 00       	call   80104b8c <acquire>
8010081e:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100821:	e9 52 01 00 00       	jmp    80100978 <consoleintr+0x178>
    switch(c){
80100826:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010082a:	0f 84 81 00 00 00    	je     801008b1 <consoleintr+0xb1>
80100830:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100834:	0f 8f ac 00 00 00    	jg     801008e6 <consoleintr+0xe6>
8010083a:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010083e:	74 43                	je     80100883 <consoleintr+0x83>
80100840:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100844:	0f 8f 9c 00 00 00    	jg     801008e6 <consoleintr+0xe6>
8010084a:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
8010084e:	74 61                	je     801008b1 <consoleintr+0xb1>
80100850:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100854:	0f 85 8c 00 00 00    	jne    801008e6 <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010085a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100861:	e9 12 01 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100866:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010086b:	83 e8 01             	sub    $0x1,%eax
8010086e:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
80100873:	83 ec 0c             	sub    $0xc,%esp
80100876:	68 00 01 00 00       	push   $0x100
8010087b:	e8 15 ff ff ff       	call   80100795 <consputc>
80100880:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100883:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
80100889:	a1 44 2d 19 80       	mov    0x80192d44,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 e2 00 00 00    	je     80100978 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100896:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
      while(input.e != input.w &&
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 ba                	jne    80100866 <consoleintr+0x66>
      }
      break;
801008ac:	e9 c7 00 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008b7:	a1 44 2d 19 80       	mov    0x80192d44,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 b4 00 00 00    	je     80100978 <consoleintr+0x178>
        input.e--;
801008c4:	a1 48 2d 19 80       	mov    0x80192d48,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 48 2d 19 80       	mov    %eax,0x80192d48
        consputc(BACKSPACE);
801008d1:	83 ec 0c             	sub    $0xc,%esp
801008d4:	68 00 01 00 00       	push   $0x100
801008d9:	e8 b7 fe ff ff       	call   80100795 <consputc>
801008de:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008e1:	e9 92 00 00 00       	jmp    80100978 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008ea:	0f 84 87 00 00 00    	je     80100977 <consoleintr+0x177>
801008f0:	8b 15 48 2d 19 80    	mov    0x80192d48,%edx
801008f6:	a1 40 2d 19 80       	mov    0x80192d40,%eax
801008fb:	29 c2                	sub    %eax,%edx
801008fd:	89 d0                	mov    %edx,%eax
801008ff:	83 f8 7f             	cmp    $0x7f,%eax
80100902:	77 73                	ja     80100977 <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
80100904:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100908:	74 05                	je     8010090f <consoleintr+0x10f>
8010090a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010090d:	eb 05                	jmp    80100914 <consoleintr+0x114>
8010090f:	b8 0a 00 00 00       	mov    $0xa,%eax
80100914:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100917:	a1 48 2d 19 80       	mov    0x80192d48,%eax
8010091c:	8d 50 01             	lea    0x1(%eax),%edx
8010091f:	89 15 48 2d 19 80    	mov    %edx,0x80192d48
80100925:	83 e0 7f             	and    $0x7f,%eax
80100928:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010092b:	88 90 c0 2c 19 80    	mov    %dl,-0x7fe6d340(%eax)
        consputc(c);
80100931:	83 ec 0c             	sub    $0xc,%esp
80100934:	ff 75 f0             	pushl  -0x10(%ebp)
80100937:	e8 59 fe ff ff       	call   80100795 <consputc>
8010093c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010093f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100943:	74 18                	je     8010095d <consoleintr+0x15d>
80100945:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100949:	74 12                	je     8010095d <consoleintr+0x15d>
8010094b:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100950:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100956:	83 ea 80             	sub    $0xffffff80,%edx
80100959:	39 d0                	cmp    %edx,%eax
8010095b:	75 1a                	jne    80100977 <consoleintr+0x177>
          input.w = input.e;
8010095d:	a1 48 2d 19 80       	mov    0x80192d48,%eax
80100962:	a3 44 2d 19 80       	mov    %eax,0x80192d44
          wakeup(&input.r);
80100967:	83 ec 0c             	sub    $0xc,%esp
8010096a:	68 40 2d 19 80       	push   $0x80192d40
8010096f:	e8 be 3e 00 00       	call   80104832 <wakeup>
80100974:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100977:	90                   	nop
  while((c = getc()) >= 0){
80100978:	8b 45 08             	mov    0x8(%ebp),%eax
8010097b:	ff d0                	call   *%eax
8010097d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100984:	0f 89 9c fe ff ff    	jns    80100826 <consoleintr+0x26>
    }
  }
  release(&cons.lock);
8010098a:	83 ec 0c             	sub    $0xc,%esp
8010098d:	68 20 d0 18 80       	push   $0x8018d020
80100992:	e8 67 42 00 00       	call   80104bfe <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 53 3f 00 00       	call   801048f8 <procdump>
  }
}
801009a5:	90                   	nop
801009a6:	c9                   	leave  
801009a7:	c3                   	ret    

801009a8 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009a8:	f3 0f 1e fb          	endbr32 
801009ac:	55                   	push   %ebp
801009ad:	89 e5                	mov    %esp,%ebp
801009af:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009b2:	83 ec 0c             	sub    $0xc,%esp
801009b5:	ff 75 08             	pushl  0x8(%ebp)
801009b8:	e8 d6 11 00 00       	call   80101b93 <iunlock>
801009bd:	83 c4 10             	add    $0x10,%esp
  target = n;
801009c0:	8b 45 10             	mov    0x10(%ebp),%eax
801009c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	68 20 d0 18 80       	push   $0x8018d020
801009ce:	e8 b9 41 00 00       	call   80104b8c <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 c9 31 00 00       	call   80103ba9 <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 d0 18 80       	push   $0x8018d020
801009ef:	e8 0a 42 00 00       	call   80104bfe <release>
801009f4:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	pushl  0x8(%ebp)
801009fd:	e8 7a 10 00 00       	call   80101a7c <ilock>
80100a02:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a0a:	e9 ab 00 00 00       	jmp    80100aba <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a0f:	83 ec 08             	sub    $0x8,%esp
80100a12:	68 20 d0 18 80       	push   $0x8018d020
80100a17:	68 40 2d 19 80       	push   $0x80192d40
80100a1c:	e8 1f 3d 00 00       	call   80104740 <sleep>
80100a21:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a24:	8b 15 40 2d 19 80    	mov    0x80192d40,%edx
80100a2a:	a1 44 2d 19 80       	mov    0x80192d44,%eax
80100a2f:	39 c2                	cmp    %eax,%edx
80100a31:	74 a8                	je     801009db <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a33:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a38:	8d 50 01             	lea    0x1(%eax),%edx
80100a3b:	89 15 40 2d 19 80    	mov    %edx,0x80192d40
80100a41:	83 e0 7f             	and    $0x7f,%eax
80100a44:	0f b6 80 c0 2c 19 80 	movzbl -0x7fe6d340(%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a51:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a55:	75 17                	jne    80100a6e <consoleread+0xc6>
      if(n < target){
80100a57:	8b 45 10             	mov    0x10(%ebp),%eax
80100a5a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a5d:	76 2f                	jbe    80100a8e <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a5f:	a1 40 2d 19 80       	mov    0x80192d40,%eax
80100a64:	83 e8 01             	sub    $0x1,%eax
80100a67:	a3 40 2d 19 80       	mov    %eax,0x80192d40
      }
      break;
80100a6c:	eb 20                	jmp    80100a8e <consoleread+0xe6>
    }
    *dst++ = c;
80100a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a71:	8d 50 01             	lea    0x1(%eax),%edx
80100a74:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a77:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a7a:	88 10                	mov    %dl,(%eax)
    --n;
80100a7c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a80:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a84:	74 0b                	je     80100a91 <consoleread+0xe9>
  while(n > 0){
80100a86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a8a:	7f 98                	jg     80100a24 <consoleread+0x7c>
80100a8c:	eb 04                	jmp    80100a92 <consoleread+0xea>
      break;
80100a8e:	90                   	nop
80100a8f:	eb 01                	jmp    80100a92 <consoleread+0xea>
      break;
80100a91:	90                   	nop
  }
  release(&cons.lock);
80100a92:	83 ec 0c             	sub    $0xc,%esp
80100a95:	68 20 d0 18 80       	push   $0x8018d020
80100a9a:	e8 5f 41 00 00       	call   80104bfe <release>
80100a9f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aa2:	83 ec 0c             	sub    $0xc,%esp
80100aa5:	ff 75 08             	pushl  0x8(%ebp)
80100aa8:	e8 cf 0f 00 00       	call   80101a7c <ilock>
80100aad:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ab0:	8b 45 10             	mov    0x10(%ebp),%eax
80100ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ab6:	29 c2                	sub    %eax,%edx
80100ab8:	89 d0                	mov    %edx,%eax
}
80100aba:	c9                   	leave  
80100abb:	c3                   	ret    

80100abc <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100abc:	f3 0f 1e fb          	endbr32 
80100ac0:	55                   	push   %ebp
80100ac1:	89 e5                	mov    %esp,%ebp
80100ac3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	ff 75 08             	pushl  0x8(%ebp)
80100acc:	e8 c2 10 00 00       	call   80101b93 <iunlock>
80100ad1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ad4:	83 ec 0c             	sub    $0xc,%esp
80100ad7:	68 20 d0 18 80       	push   $0x8018d020
80100adc:	e8 ab 40 00 00       	call   80104b8c <acquire>
80100ae1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ae4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100aeb:	eb 21                	jmp    80100b0e <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100aed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100af0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100af3:	01 d0                	add    %edx,%eax
80100af5:	0f b6 00             	movzbl (%eax),%eax
80100af8:	0f be c0             	movsbl %al,%eax
80100afb:	0f b6 c0             	movzbl %al,%eax
80100afe:	83 ec 0c             	sub    $0xc,%esp
80100b01:	50                   	push   %eax
80100b02:	e8 8e fc ff ff       	call   80100795 <consputc>
80100b07:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b0a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b11:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b14:	7c d7                	jl     80100aed <consolewrite+0x31>
  release(&cons.lock);
80100b16:	83 ec 0c             	sub    $0xc,%esp
80100b19:	68 20 d0 18 80       	push   $0x8018d020
80100b1e:	e8 db 40 00 00       	call   80104bfe <release>
80100b23:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b26:	83 ec 0c             	sub    $0xc,%esp
80100b29:	ff 75 08             	pushl  0x8(%ebp)
80100b2c:	e8 4b 0f 00 00       	call   80101a7c <ilock>
80100b31:	83 c4 10             	add    $0x10,%esp

  return n;
80100b34:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b37:	c9                   	leave  
80100b38:	c3                   	ret    

80100b39 <consoleinit>:

void
consoleinit(void)
{
80100b39:	f3 0f 1e fb          	endbr32 
80100b3d:	55                   	push   %ebp
80100b3e:	89 e5                	mov    %esp,%ebp
80100b40:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b43:	c7 05 00 d0 18 80 00 	movl   $0x0,0x8018d000
80100b4a:	00 00 00 
  initlock(&cons.lock, "console");
80100b4d:	83 ec 08             	sub    $0x8,%esp
80100b50:	68 57 a7 10 80       	push   $0x8010a757
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 07 40 00 00       	call   80104b66 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 5f a7 10 80 	movl   $0x8010a75f,-0xc(%ebp)
80100b7d:	eb 19                	jmp    80100b98 <consoleinit+0x5f>
    graphic_putc(*p);
80100b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b82:	0f b6 00             	movzbl (%eax),%eax
80100b85:	0f be c0             	movsbl %al,%eax
80100b88:	83 ec 0c             	sub    $0xc,%esp
80100b8b:	50                   	push   %eax
80100b8c:	e8 cc fa ff ff       	call   8010065d <graphic_putc>
80100b91:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b9b:	0f b6 00             	movzbl (%eax),%eax
80100b9e:	84 c0                	test   %al,%al
80100ba0:	75 dd                	jne    80100b7f <consoleinit+0x46>
  
  cons.locking = 1;
80100ba2:	c7 05 54 d0 18 80 01 	movl   $0x1,0x8018d054
80100ba9:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bac:	83 ec 08             	sub    $0x8,%esp
80100baf:	6a 00                	push   $0x0
80100bb1:	6a 01                	push   $0x1
80100bb3:	e8 54 1b 00 00       	call   8010270c <ioapicenable>
80100bb8:	83 c4 10             	add    $0x10,%esp
}
80100bbb:	90                   	nop
80100bbc:	c9                   	leave  
80100bbd:	c3                   	ret    

80100bbe <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bbe:	f3 0f 1e fb          	endbr32 
80100bc2:	55                   	push   %ebp
80100bc3:	89 e5                	mov    %esp,%ebp
80100bc5:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bcb:	e8 d9 2f 00 00       	call   80103ba9 <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd3:	e8 99 25 00 00       	call   80103171 <begin_op>

  if((ip = namei(path)) == 0){
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	pushl  0x8(%ebp)
80100bde:	e8 04 1a 00 00       	call   801025e7 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
    end_op();
80100bef:	e8 0d 26 00 00       	call   80103201 <end_op>
    cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 75 a7 10 80       	push   $0x8010a775
80100bfc:	e8 0b f8 ff ff       	call   8010040c <cprintf>
80100c01:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c09:	e9 f1 03 00 00       	jmp    80100fff <exec+0x441>
  }
  ilock(ip);
80100c0e:	83 ec 0c             	sub    $0xc,%esp
80100c11:	ff 75 d8             	pushl  -0x28(%ebp)
80100c14:	e8 63 0e 00 00       	call   80101a7c <ilock>
80100c19:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c1c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c23:	6a 34                	push   $0x34
80100c25:	6a 00                	push   $0x0
80100c27:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c2d:	50                   	push   %eax
80100c2e:	ff 75 d8             	pushl  -0x28(%ebp)
80100c31:	e8 4e 13 00 00       	call   80101f84 <readi>
80100c36:	83 c4 10             	add    $0x10,%esp
80100c39:	83 f8 34             	cmp    $0x34,%eax
80100c3c:	0f 85 66 03 00 00    	jne    80100fa8 <exec+0x3ea>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c42:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c48:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4d:	0f 85 58 03 00 00    	jne    80100fab <exec+0x3ed>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c53:	e8 6a 6c 00 00       	call   801078c2 <setupkvm>
80100c58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c5f:	0f 84 49 03 00 00    	je     80100fae <exec+0x3f0>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c65:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c6c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c73:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c79:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c7c:	e9 de 00 00 00       	jmp    80100d5f <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c84:	6a 20                	push   $0x20
80100c86:	50                   	push   %eax
80100c87:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c8d:	50                   	push   %eax
80100c8e:	ff 75 d8             	pushl  -0x28(%ebp)
80100c91:	e8 ee 12 00 00       	call   80101f84 <readi>
80100c96:	83 c4 10             	add    $0x10,%esp
80100c99:	83 f8 20             	cmp    $0x20,%eax
80100c9c:	0f 85 0f 03 00 00    	jne    80100fb1 <exec+0x3f3>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ca2:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ca8:	83 f8 01             	cmp    $0x1,%eax
80100cab:	0f 85 a0 00 00 00    	jne    80100d51 <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100cb1:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb7:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cbd:	39 c2                	cmp    %eax,%edx
80100cbf:	0f 82 ef 02 00 00    	jb     80100fb4 <exec+0x3f6>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100cc5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd1:	01 c2                	add    %eax,%edx
80100cd3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd9:	39 c2                	cmp    %eax,%edx
80100cdb:	0f 82 d6 02 00 00    	jb     80100fb7 <exec+0x3f9>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce1:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ced:	01 d0                	add    %edx,%eax
80100cef:	83 ec 04             	sub    $0x4,%esp
80100cf2:	50                   	push   %eax
80100cf3:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf9:	e8 d6 6f 00 00       	call   80107cd4 <allocuvm>
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d08:	0f 84 ac 02 00 00    	je     80100fba <exec+0x3fc>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d0e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d14:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d19:	85 c0                	test   %eax,%eax
80100d1b:	0f 85 9c 02 00 00    	jne    80100fbd <exec+0x3ff>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d21:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d27:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2d:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d33:	83 ec 0c             	sub    $0xc,%esp
80100d36:	52                   	push   %edx
80100d37:	50                   	push   %eax
80100d38:	ff 75 d8             	pushl  -0x28(%ebp)
80100d3b:	51                   	push   %ecx
80100d3c:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d3f:	e8 bf 6e 00 00       	call   80107c03 <loaduvm>
80100d44:	83 c4 20             	add    $0x20,%esp
80100d47:	85 c0                	test   %eax,%eax
80100d49:	0f 88 71 02 00 00    	js     80100fc0 <exec+0x402>
80100d4f:	eb 01                	jmp    80100d52 <exec+0x194>
      continue;
80100d51:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d52:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d59:	83 c0 20             	add    $0x20,%eax
80100d5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d5f:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d66:	0f b7 c0             	movzwl %ax,%eax
80100d69:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d6c:	0f 8c 0f ff ff ff    	jl     80100c81 <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100d72:	83 ec 0c             	sub    $0xc,%esp
80100d75:	ff 75 d8             	pushl  -0x28(%ebp)
80100d78:	e8 3c 0f 00 00       	call   80101cb9 <iunlockput>
80100d7d:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d80:	e8 7c 24 00 00       	call   80103201 <end_op>
  ip = 0;
80100d85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8f:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9f:	05 00 20 00 00       	add    $0x2000,%eax
80100da4:	83 ec 04             	sub    $0x4,%esp
80100da7:	50                   	push   %eax
80100da8:	ff 75 e0             	pushl  -0x20(%ebp)
80100dab:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dae:	e8 21 6f 00 00       	call   80107cd4 <allocuvm>
80100db3:	83 c4 10             	add    $0x10,%esp
80100db6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100db9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dbd:	0f 84 00 02 00 00    	je     80100fc3 <exec+0x405>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dc6:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dcb:	83 ec 08             	sub    $0x8,%esp
80100dce:	50                   	push   %eax
80100dcf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dd2:	e8 6b 71 00 00       	call   80107f42 <clearpteu>
80100dd7:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dda:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ddd:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100de7:	e9 96 00 00 00       	jmp    80100e82 <exec+0x2c4>
    if(argc >= MAXARG)
80100dec:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100df0:	0f 87 d0 01 00 00    	ja     80100fc6 <exec+0x408>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e03:	01 d0                	add    %edx,%eax
80100e05:	8b 00                	mov    (%eax),%eax
80100e07:	83 ec 0c             	sub    $0xc,%esp
80100e0a:	50                   	push   %eax
80100e0b:	e8 74 42 00 00       	call   80105084 <strlen>
80100e10:	83 c4 10             	add    $0x10,%esp
80100e13:	89 c2                	mov    %eax,%edx
80100e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e18:	29 d0                	sub    %edx,%eax
80100e1a:	83 e8 01             	sub    $0x1,%eax
80100e1d:	83 e0 fc             	and    $0xfffffffc,%eax
80100e20:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e30:	01 d0                	add    %edx,%eax
80100e32:	8b 00                	mov    (%eax),%eax
80100e34:	83 ec 0c             	sub    $0xc,%esp
80100e37:	50                   	push   %eax
80100e38:	e8 47 42 00 00       	call   80105084 <strlen>
80100e3d:	83 c4 10             	add    $0x10,%esp
80100e40:	83 c0 01             	add    $0x1,%eax
80100e43:	89 c1                	mov    %eax,%ecx
80100e45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e52:	01 d0                	add    %edx,%eax
80100e54:	8b 00                	mov    (%eax),%eax
80100e56:	51                   	push   %ecx
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 8a 72 00 00       	call   801080ed <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 5b 01 00 00    	js     80100fc9 <exec+0x40b>
      goto bad;
    ustack[3+argc] = sp;
80100e6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e71:	8d 50 03             	lea    0x3(%eax),%edx
80100e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e77:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e7e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e85:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e8f:	01 d0                	add    %edx,%eax
80100e91:	8b 00                	mov    (%eax),%eax
80100e93:	85 c0                	test   %eax,%eax
80100e95:	0f 85 51 ff ff ff    	jne    80100dec <exec+0x22e>
  }
  ustack[3+argc] = 0;
80100e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9e:	83 c0 03             	add    $0x3,%eax
80100ea1:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ea8:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100eac:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eb3:	ff ff ff 
  ustack[1] = argc;
80100eb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb9:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ebf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec2:	83 c0 01             	add    $0x1,%eax
80100ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ecf:	29 d0                	sub    %edx,%eax
80100ed1:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eda:	83 c0 04             	add    $0x4,%eax
80100edd:	c1 e0 02             	shl    $0x2,%eax
80100ee0:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ee3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee6:	83 c0 04             	add    $0x4,%eax
80100ee9:	c1 e0 02             	shl    $0x2,%eax
80100eec:	50                   	push   %eax
80100eed:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ef3:	50                   	push   %eax
80100ef4:	ff 75 dc             	pushl  -0x24(%ebp)
80100ef7:	ff 75 d4             	pushl  -0x2c(%ebp)
80100efa:	e8 ee 71 00 00       	call   801080ed <copyout>
80100eff:	83 c4 10             	add    $0x10,%esp
80100f02:	85 c0                	test   %eax,%eax
80100f04:	0f 88 c2 00 00 00    	js     80100fcc <exec+0x40e>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f16:	eb 17                	jmp    80100f2f <exec+0x371>
    if(*s == '/')
80100f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1b:	0f b6 00             	movzbl (%eax),%eax
80100f1e:	3c 2f                	cmp    $0x2f,%al
80100f20:	75 09                	jne    80100f2b <exec+0x36d>
      last = s+1;
80100f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f25:	83 c0 01             	add    $0x1,%eax
80100f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f2b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f32:	0f b6 00             	movzbl (%eax),%eax
80100f35:	84 c0                	test   %al,%al
80100f37:	75 df                	jne    80100f18 <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f39:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f3c:	83 c0 6c             	add    $0x6c,%eax
80100f3f:	83 ec 04             	sub    $0x4,%esp
80100f42:	6a 10                	push   $0x10
80100f44:	ff 75 f0             	pushl  -0x10(%ebp)
80100f47:	50                   	push   %eax
80100f48:	e8 e9 40 00 00       	call   80105036 <safestrcpy>
80100f4d:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f50:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f53:	8b 40 04             	mov    0x4(%eax),%eax
80100f56:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f59:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f5f:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f62:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f65:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f68:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6d:	8b 40 18             	mov    0x18(%eax),%eax
80100f70:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f76:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f79:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f7c:	8b 40 18             	mov    0x18(%eax),%eax
80100f7f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f82:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f85:	83 ec 0c             	sub    $0xc,%esp
80100f88:	ff 75 d0             	pushl  -0x30(%ebp)
80100f8b:	e8 5c 6a 00 00       	call   801079ec <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	pushl  -0x34(%ebp)
80100f99:	e8 07 6f 00 00       	call   80107ea5 <freevm>
80100f9e:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fa1:	b8 00 00 00 00       	mov    $0x0,%eax
80100fa6:	eb 57                	jmp    80100fff <exec+0x441>
    goto bad;
80100fa8:	90                   	nop
80100fa9:	eb 22                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fab:	90                   	nop
80100fac:	eb 1f                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fae:	90                   	nop
80100faf:	eb 1c                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb1:	90                   	nop
80100fb2:	eb 19                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb4:	90                   	nop
80100fb5:	eb 16                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fb7:	90                   	nop
80100fb8:	eb 13                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fba:	90                   	nop
80100fbb:	eb 10                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fbd:	90                   	nop
80100fbe:	eb 0d                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc0:	90                   	nop
80100fc1:	eb 0a                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fc3:	90                   	nop
80100fc4:	eb 07                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc6:	90                   	nop
80100fc7:	eb 04                	jmp    80100fcd <exec+0x40f>
      goto bad;
80100fc9:	90                   	nop
80100fca:	eb 01                	jmp    80100fcd <exec+0x40f>
    goto bad;
80100fcc:	90                   	nop

 bad:
  if(pgdir)
80100fcd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fd1:	74 0e                	je     80100fe1 <exec+0x423>
    freevm(pgdir);
80100fd3:	83 ec 0c             	sub    $0xc,%esp
80100fd6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fd9:	e8 c7 6e 00 00       	call   80107ea5 <freevm>
80100fde:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fe1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fe5:	74 13                	je     80100ffa <exec+0x43c>
    iunlockput(ip);
80100fe7:	83 ec 0c             	sub    $0xc,%esp
80100fea:	ff 75 d8             	pushl  -0x28(%ebp)
80100fed:	e8 c7 0c 00 00       	call   80101cb9 <iunlockput>
80100ff2:	83 c4 10             	add    $0x10,%esp
    end_op();
80100ff5:	e8 07 22 00 00       	call   80103201 <end_op>
  }
  return -1;
80100ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fff:	c9                   	leave  
80101000:	c3                   	ret    

80101001 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101001:	f3 0f 1e fb          	endbr32 
80101005:	55                   	push   %ebp
80101006:	89 e5                	mov    %esp,%ebp
80101008:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010100b:	83 ec 08             	sub    $0x8,%esp
8010100e:	68 81 a7 10 80       	push   $0x8010a781
80101013:	68 60 2d 19 80       	push   $0x80192d60
80101018:	e8 49 3b 00 00       	call   80104b66 <initlock>
8010101d:	83 c4 10             	add    $0x10,%esp
}
80101020:	90                   	nop
80101021:	c9                   	leave  
80101022:	c3                   	ret    

80101023 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101023:	f3 0f 1e fb          	endbr32 
80101027:	55                   	push   %ebp
80101028:	89 e5                	mov    %esp,%ebp
8010102a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010102d:	83 ec 0c             	sub    $0xc,%esp
80101030:	68 60 2d 19 80       	push   $0x80192d60
80101035:	e8 52 3b 00 00       	call   80104b8c <acquire>
8010103a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103d:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
80101044:	eb 2d                	jmp    80101073 <filealloc+0x50>
    if(f->ref == 0){
80101046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101049:	8b 40 04             	mov    0x4(%eax),%eax
8010104c:	85 c0                	test   %eax,%eax
8010104e:	75 1f                	jne    8010106f <filealloc+0x4c>
      f->ref = 1;
80101050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101053:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 60 2d 19 80       	push   $0x80192d60
80101062:	e8 97 3b 00 00       	call   80104bfe <release>
80101067:	83 c4 10             	add    $0x10,%esp
      return f;
8010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106d:	eb 23                	jmp    80101092 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101073:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
80101078:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107b:	72 c9                	jb     80101046 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 60 2d 19 80       	push   $0x80192d60
80101085:	e8 74 3b 00 00       	call   80104bfe <release>
8010108a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010108d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101092:	c9                   	leave  
80101093:	c3                   	ret    

80101094 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101094:	f3 0f 1e fb          	endbr32 
80101098:	55                   	push   %ebp
80101099:	89 e5                	mov    %esp,%ebp
8010109b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010109e:	83 ec 0c             	sub    $0xc,%esp
801010a1:	68 60 2d 19 80       	push   $0x80192d60
801010a6:	e8 e1 3a 00 00       	call   80104b8c <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 88 a7 10 80       	push   $0x8010a788
801010c0:	e8 00 f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 40 04             	mov    0x4(%eax),%eax
801010cb:	8d 50 01             	lea    0x1(%eax),%edx
801010ce:	8b 45 08             	mov    0x8(%ebp),%eax
801010d1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 60 2d 19 80       	push   $0x80192d60
801010dc:	e8 1d 3b 00 00       	call   80104bfe <release>
801010e1:	83 c4 10             	add    $0x10,%esp
  return f;
801010e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010e7:	c9                   	leave  
801010e8:	c3                   	ret    

801010e9 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010e9:	f3 0f 1e fb          	endbr32 
801010ed:	55                   	push   %ebp
801010ee:	89 e5                	mov    %esp,%ebp
801010f0:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010f3:	83 ec 0c             	sub    $0xc,%esp
801010f6:	68 60 2d 19 80       	push   $0x80192d60
801010fb:	e8 8c 3a 00 00       	call   80104b8c <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 90 a7 10 80       	push   $0x8010a790
80101115:	e8 ab f4 ff ff       	call   801005c5 <panic>
  if(--f->ref > 0){
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 04             	mov    0x4(%eax),%eax
80101120:	8d 50 ff             	lea    -0x1(%eax),%edx
80101123:	8b 45 08             	mov    0x8(%ebp),%eax
80101126:	89 50 04             	mov    %edx,0x4(%eax)
80101129:	8b 45 08             	mov    0x8(%ebp),%eax
8010112c:	8b 40 04             	mov    0x4(%eax),%eax
8010112f:	85 c0                	test   %eax,%eax
80101131:	7e 15                	jle    80101148 <fileclose+0x5f>
    release(&ftable.lock);
80101133:	83 ec 0c             	sub    $0xc,%esp
80101136:	68 60 2d 19 80       	push   $0x80192d60
8010113b:	e8 be 3a 00 00       	call   80104bfe <release>
80101140:	83 c4 10             	add    $0x10,%esp
80101143:	e9 8b 00 00 00       	jmp    801011d3 <fileclose+0xea>
    return;
  }
  ff = *f;
80101148:	8b 45 08             	mov    0x8(%ebp),%eax
8010114b:	8b 10                	mov    (%eax),%edx
8010114d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101150:	8b 50 04             	mov    0x4(%eax),%edx
80101153:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101156:	8b 50 08             	mov    0x8(%eax),%edx
80101159:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010115c:	8b 50 0c             	mov    0xc(%eax),%edx
8010115f:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101162:	8b 50 10             	mov    0x10(%eax),%edx
80101165:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101168:	8b 40 14             	mov    0x14(%eax),%eax
8010116b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010116e:	8b 45 08             	mov    0x8(%ebp),%eax
80101171:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101178:	8b 45 08             	mov    0x8(%ebp),%eax
8010117b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101181:	83 ec 0c             	sub    $0xc,%esp
80101184:	68 60 2d 19 80       	push   $0x80192d60
80101189:	e8 70 3a 00 00       	call   80104bfe <release>
8010118e:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101191:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101194:	83 f8 01             	cmp    $0x1,%eax
80101197:	75 19                	jne    801011b2 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101199:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010119d:	0f be d0             	movsbl %al,%edx
801011a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011a3:	83 ec 08             	sub    $0x8,%esp
801011a6:	52                   	push   %edx
801011a7:	50                   	push   %eax
801011a8:	e8 73 26 00 00       	call   80103820 <pipeclose>
801011ad:	83 c4 10             	add    $0x10,%esp
801011b0:	eb 21                	jmp    801011d3 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011b5:	83 f8 02             	cmp    $0x2,%eax
801011b8:	75 19                	jne    801011d3 <fileclose+0xea>
    begin_op();
801011ba:	e8 b2 1f 00 00       	call   80103171 <begin_op>
    iput(ff.ip);
801011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011c2:	83 ec 0c             	sub    $0xc,%esp
801011c5:	50                   	push   %eax
801011c6:	e8 1a 0a 00 00       	call   80101be5 <iput>
801011cb:	83 c4 10             	add    $0x10,%esp
    end_op();
801011ce:	e8 2e 20 00 00       	call   80103201 <end_op>
  }
}
801011d3:	c9                   	leave  
801011d4:	c3                   	ret    

801011d5 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011d5:	f3 0f 1e fb          	endbr32 
801011d9:	55                   	push   %ebp
801011da:	89 e5                	mov    %esp,%ebp
801011dc:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011df:	8b 45 08             	mov    0x8(%ebp),%eax
801011e2:	8b 00                	mov    (%eax),%eax
801011e4:	83 f8 02             	cmp    $0x2,%eax
801011e7:	75 40                	jne    80101229 <filestat+0x54>
    ilock(f->ip);
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 40 10             	mov    0x10(%eax),%eax
801011ef:	83 ec 0c             	sub    $0xc,%esp
801011f2:	50                   	push   %eax
801011f3:	e8 84 08 00 00       	call   80101a7c <ilock>
801011f8:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011fb:	8b 45 08             	mov    0x8(%ebp),%eax
801011fe:	8b 40 10             	mov    0x10(%eax),%eax
80101201:	83 ec 08             	sub    $0x8,%esp
80101204:	ff 75 0c             	pushl  0xc(%ebp)
80101207:	50                   	push   %eax
80101208:	e8 2d 0d 00 00       	call   80101f3a <stati>
8010120d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101210:	8b 45 08             	mov    0x8(%ebp),%eax
80101213:	8b 40 10             	mov    0x10(%eax),%eax
80101216:	83 ec 0c             	sub    $0xc,%esp
80101219:	50                   	push   %eax
8010121a:	e8 74 09 00 00       	call   80101b93 <iunlock>
8010121f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101222:	b8 00 00 00 00       	mov    $0x0,%eax
80101227:	eb 05                	jmp    8010122e <filestat+0x59>
  }
  return -1;
80101229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010122e:	c9                   	leave  
8010122f:	c3                   	ret    

80101230 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101230:	f3 0f 1e fb          	endbr32 
80101234:	55                   	push   %ebp
80101235:	89 e5                	mov    %esp,%ebp
80101237:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010123a:	8b 45 08             	mov    0x8(%ebp),%eax
8010123d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101241:	84 c0                	test   %al,%al
80101243:	75 0a                	jne    8010124f <fileread+0x1f>
    return -1;
80101245:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010124a:	e9 9b 00 00 00       	jmp    801012ea <fileread+0xba>
  if(f->type == FD_PIPE)
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	8b 00                	mov    (%eax),%eax
80101254:	83 f8 01             	cmp    $0x1,%eax
80101257:	75 1a                	jne    80101273 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101259:	8b 45 08             	mov    0x8(%ebp),%eax
8010125c:	8b 40 0c             	mov    0xc(%eax),%eax
8010125f:	83 ec 04             	sub    $0x4,%esp
80101262:	ff 75 10             	pushl  0x10(%ebp)
80101265:	ff 75 0c             	pushl  0xc(%ebp)
80101268:	50                   	push   %eax
80101269:	e8 67 27 00 00       	call   801039d5 <piperead>
8010126e:	83 c4 10             	add    $0x10,%esp
80101271:	eb 77                	jmp    801012ea <fileread+0xba>
  if(f->type == FD_INODE){
80101273:	8b 45 08             	mov    0x8(%ebp),%eax
80101276:	8b 00                	mov    (%eax),%eax
80101278:	83 f8 02             	cmp    $0x2,%eax
8010127b:	75 60                	jne    801012dd <fileread+0xad>
    ilock(f->ip);
8010127d:	8b 45 08             	mov    0x8(%ebp),%eax
80101280:	8b 40 10             	mov    0x10(%eax),%eax
80101283:	83 ec 0c             	sub    $0xc,%esp
80101286:	50                   	push   %eax
80101287:	e8 f0 07 00 00       	call   80101a7c <ilock>
8010128c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010128f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 50 14             	mov    0x14(%eax),%edx
80101298:	8b 45 08             	mov    0x8(%ebp),%eax
8010129b:	8b 40 10             	mov    0x10(%eax),%eax
8010129e:	51                   	push   %ecx
8010129f:	52                   	push   %edx
801012a0:	ff 75 0c             	pushl  0xc(%ebp)
801012a3:	50                   	push   %eax
801012a4:	e8 db 0c 00 00       	call   80101f84 <readi>
801012a9:	83 c4 10             	add    $0x10,%esp
801012ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012b3:	7e 11                	jle    801012c6 <fileread+0x96>
      f->off += r;
801012b5:	8b 45 08             	mov    0x8(%ebp),%eax
801012b8:	8b 50 14             	mov    0x14(%eax),%edx
801012bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012be:	01 c2                	add    %eax,%edx
801012c0:	8b 45 08             	mov    0x8(%ebp),%eax
801012c3:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012c6:	8b 45 08             	mov    0x8(%ebp),%eax
801012c9:	8b 40 10             	mov    0x10(%eax),%eax
801012cc:	83 ec 0c             	sub    $0xc,%esp
801012cf:	50                   	push   %eax
801012d0:	e8 be 08 00 00       	call   80101b93 <iunlock>
801012d5:	83 c4 10             	add    $0x10,%esp
    return r;
801012d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012db:	eb 0d                	jmp    801012ea <fileread+0xba>
  }
  panic("fileread");
801012dd:	83 ec 0c             	sub    $0xc,%esp
801012e0:	68 9a a7 10 80       	push   $0x8010a79a
801012e5:	e8 db f2 ff ff       	call   801005c5 <panic>
}
801012ea:	c9                   	leave  
801012eb:	c3                   	ret    

801012ec <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012ec:	f3 0f 1e fb          	endbr32 
801012f0:	55                   	push   %ebp
801012f1:	89 e5                	mov    %esp,%ebp
801012f3:	53                   	push   %ebx
801012f4:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012f7:	8b 45 08             	mov    0x8(%ebp),%eax
801012fa:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012fe:	84 c0                	test   %al,%al
80101300:	75 0a                	jne    8010130c <filewrite+0x20>
    return -1;
80101302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101307:	e9 1b 01 00 00       	jmp    80101427 <filewrite+0x13b>
  if(f->type == FD_PIPE)
8010130c:	8b 45 08             	mov    0x8(%ebp),%eax
8010130f:	8b 00                	mov    (%eax),%eax
80101311:	83 f8 01             	cmp    $0x1,%eax
80101314:	75 1d                	jne    80101333 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	8b 40 0c             	mov    0xc(%eax),%eax
8010131c:	83 ec 04             	sub    $0x4,%esp
8010131f:	ff 75 10             	pushl  0x10(%ebp)
80101322:	ff 75 0c             	pushl  0xc(%ebp)
80101325:	50                   	push   %eax
80101326:	e8 a4 25 00 00       	call   801038cf <pipewrite>
8010132b:	83 c4 10             	add    $0x10,%esp
8010132e:	e9 f4 00 00 00       	jmp    80101427 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101333:	8b 45 08             	mov    0x8(%ebp),%eax
80101336:	8b 00                	mov    (%eax),%eax
80101338:	83 f8 02             	cmp    $0x2,%eax
8010133b:	0f 85 d9 00 00 00    	jne    8010141a <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101341:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010134f:	e9 a3 00 00 00       	jmp    801013f7 <filewrite+0x10b>
      int n1 = n - i;
80101354:	8b 45 10             	mov    0x10(%ebp),%eax
80101357:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010135a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101360:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101363:	7e 06                	jle    8010136b <filewrite+0x7f>
        n1 = max;
80101365:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101368:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010136b:	e8 01 1e 00 00       	call   80103171 <begin_op>
      ilock(f->ip);
80101370:	8b 45 08             	mov    0x8(%ebp),%eax
80101373:	8b 40 10             	mov    0x10(%eax),%eax
80101376:	83 ec 0c             	sub    $0xc,%esp
80101379:	50                   	push   %eax
8010137a:	e8 fd 06 00 00       	call   80101a7c <ilock>
8010137f:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101382:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	8b 50 14             	mov    0x14(%eax),%edx
8010138b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010138e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101391:	01 c3                	add    %eax,%ebx
80101393:	8b 45 08             	mov    0x8(%ebp),%eax
80101396:	8b 40 10             	mov    0x10(%eax),%eax
80101399:	51                   	push   %ecx
8010139a:	52                   	push   %edx
8010139b:	53                   	push   %ebx
8010139c:	50                   	push   %eax
8010139d:	e8 3b 0d 00 00       	call   801020dd <writei>
801013a2:	83 c4 10             	add    $0x10,%esp
801013a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013a8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013ac:	7e 11                	jle    801013bf <filewrite+0xd3>
        f->off += r;
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	8b 50 14             	mov    0x14(%eax),%edx
801013b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013b7:	01 c2                	add    %eax,%edx
801013b9:	8b 45 08             	mov    0x8(%ebp),%eax
801013bc:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	8b 40 10             	mov    0x10(%eax),%eax
801013c5:	83 ec 0c             	sub    $0xc,%esp
801013c8:	50                   	push   %eax
801013c9:	e8 c5 07 00 00       	call   80101b93 <iunlock>
801013ce:	83 c4 10             	add    $0x10,%esp
      end_op();
801013d1:	e8 2b 1e 00 00       	call   80103201 <end_op>

      if(r < 0)
801013d6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013da:	78 29                	js     80101405 <filewrite+0x119>
        break;
      if(r != n1)
801013dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013df:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013e2:	74 0d                	je     801013f1 <filewrite+0x105>
        panic("short filewrite");
801013e4:	83 ec 0c             	sub    $0xc,%esp
801013e7:	68 a3 a7 10 80       	push   $0x8010a7a3
801013ec:	e8 d4 f1 ff ff       	call   801005c5 <panic>
      i += r;
801013f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013f4:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013fa:	3b 45 10             	cmp    0x10(%ebp),%eax
801013fd:	0f 8c 51 ff ff ff    	jl     80101354 <filewrite+0x68>
80101403:	eb 01                	jmp    80101406 <filewrite+0x11a>
        break;
80101405:	90                   	nop
    }
    return i == n ? n : -1;
80101406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101409:	3b 45 10             	cmp    0x10(%ebp),%eax
8010140c:	75 05                	jne    80101413 <filewrite+0x127>
8010140e:	8b 45 10             	mov    0x10(%ebp),%eax
80101411:	eb 14                	jmp    80101427 <filewrite+0x13b>
80101413:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101418:	eb 0d                	jmp    80101427 <filewrite+0x13b>
  }
  panic("filewrite");
8010141a:	83 ec 0c             	sub    $0xc,%esp
8010141d:	68 b3 a7 10 80       	push   $0x8010a7b3
80101422:	e8 9e f1 ff ff       	call   801005c5 <panic>
}
80101427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010142a:	c9                   	leave  
8010142b:	c3                   	ret    

8010142c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010142c:	f3 0f 1e fb          	endbr32 
80101430:	55                   	push   %ebp
80101431:	89 e5                	mov    %esp,%ebp
80101433:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101436:	8b 45 08             	mov    0x8(%ebp),%eax
80101439:	83 ec 08             	sub    $0x8,%esp
8010143c:	6a 01                	push   $0x1
8010143e:	50                   	push   %eax
8010143f:	e8 c5 ed ff ff       	call   80100209 <bread>
80101444:	83 c4 10             	add    $0x10,%esp
80101447:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010144a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010144d:	83 c0 5c             	add    $0x5c,%eax
80101450:	83 ec 04             	sub    $0x4,%esp
80101453:	6a 1c                	push   $0x1c
80101455:	50                   	push   %eax
80101456:	ff 75 0c             	pushl  0xc(%ebp)
80101459:	e8 84 3a 00 00       	call   80104ee2 <memmove>
8010145e:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101461:	83 ec 0c             	sub    $0xc,%esp
80101464:	ff 75 f4             	pushl  -0xc(%ebp)
80101467:	e8 27 ee ff ff       	call   80100293 <brelse>
8010146c:	83 c4 10             	add    $0x10,%esp
}
8010146f:	90                   	nop
80101470:	c9                   	leave  
80101471:	c3                   	ret    

80101472 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101472:	f3 0f 1e fb          	endbr32 
80101476:	55                   	push   %ebp
80101477:	89 e5                	mov    %esp,%ebp
80101479:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010147c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010147f:	8b 45 08             	mov    0x8(%ebp),%eax
80101482:	83 ec 08             	sub    $0x8,%esp
80101485:	52                   	push   %edx
80101486:	50                   	push   %eax
80101487:	e8 7d ed ff ff       	call   80100209 <bread>
8010148c:	83 c4 10             	add    $0x10,%esp
8010148f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101495:	83 c0 5c             	add    $0x5c,%eax
80101498:	83 ec 04             	sub    $0x4,%esp
8010149b:	68 00 02 00 00       	push   $0x200
801014a0:	6a 00                	push   $0x0
801014a2:	50                   	push   %eax
801014a3:	e8 73 39 00 00       	call   80104e1b <memset>
801014a8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014ab:	83 ec 0c             	sub    $0xc,%esp
801014ae:	ff 75 f4             	pushl  -0xc(%ebp)
801014b1:	e8 04 1f 00 00       	call   801033ba <log_write>
801014b6:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014b9:	83 ec 0c             	sub    $0xc,%esp
801014bc:	ff 75 f4             	pushl  -0xc(%ebp)
801014bf:	e8 cf ed ff ff       	call   80100293 <brelse>
801014c4:	83 c4 10             	add    $0x10,%esp
}
801014c7:	90                   	nop
801014c8:	c9                   	leave  
801014c9:	c3                   	ret    

801014ca <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014ca:	f3 0f 1e fb          	endbr32 
801014ce:	55                   	push   %ebp
801014cf:	89 e5                	mov    %esp,%ebp
801014d1:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014d4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014e2:	e9 13 01 00 00       	jmp    801015fa <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801014e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ea:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014f0:	85 c0                	test   %eax,%eax
801014f2:	0f 48 c2             	cmovs  %edx,%eax
801014f5:	c1 f8 0c             	sar    $0xc,%eax
801014f8:	89 c2                	mov    %eax,%edx
801014fa:	a1 78 37 19 80       	mov    0x80193778,%eax
801014ff:	01 d0                	add    %edx,%eax
80101501:	83 ec 08             	sub    $0x8,%esp
80101504:	50                   	push   %eax
80101505:	ff 75 08             	pushl  0x8(%ebp)
80101508:	e8 fc ec ff ff       	call   80100209 <bread>
8010150d:	83 c4 10             	add    $0x10,%esp
80101510:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101513:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010151a:	e9 a6 00 00 00       	jmp    801015c5 <balloc+0xfb>
      m = 1 << (bi % 8);
8010151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101522:	99                   	cltd   
80101523:	c1 ea 1d             	shr    $0x1d,%edx
80101526:	01 d0                	add    %edx,%eax
80101528:	83 e0 07             	and    $0x7,%eax
8010152b:	29 d0                	sub    %edx,%eax
8010152d:	ba 01 00 00 00       	mov    $0x1,%edx
80101532:	89 c1                	mov    %eax,%ecx
80101534:	d3 e2                	shl    %cl,%edx
80101536:	89 d0                	mov    %edx,%eax
80101538:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153e:	8d 50 07             	lea    0x7(%eax),%edx
80101541:	85 c0                	test   %eax,%eax
80101543:	0f 48 c2             	cmovs  %edx,%eax
80101546:	c1 f8 03             	sar    $0x3,%eax
80101549:	89 c2                	mov    %eax,%edx
8010154b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010154e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101553:	0f b6 c0             	movzbl %al,%eax
80101556:	23 45 e8             	and    -0x18(%ebp),%eax
80101559:	85 c0                	test   %eax,%eax
8010155b:	75 64                	jne    801015c1 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010155d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101560:	8d 50 07             	lea    0x7(%eax),%edx
80101563:	85 c0                	test   %eax,%eax
80101565:	0f 48 c2             	cmovs  %edx,%eax
80101568:	c1 f8 03             	sar    $0x3,%eax
8010156b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010156e:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101573:	89 d1                	mov    %edx,%ecx
80101575:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101578:	09 ca                	or     %ecx,%edx
8010157a:	89 d1                	mov    %edx,%ecx
8010157c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010157f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101583:	83 ec 0c             	sub    $0xc,%esp
80101586:	ff 75 ec             	pushl  -0x14(%ebp)
80101589:	e8 2c 1e 00 00       	call   801033ba <log_write>
8010158e:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101591:	83 ec 0c             	sub    $0xc,%esp
80101594:	ff 75 ec             	pushl  -0x14(%ebp)
80101597:	e8 f7 ec ff ff       	call   80100293 <brelse>
8010159c:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010159f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a5:	01 c2                	add    %eax,%edx
801015a7:	8b 45 08             	mov    0x8(%ebp),%eax
801015aa:	83 ec 08             	sub    $0x8,%esp
801015ad:	52                   	push   %edx
801015ae:	50                   	push   %eax
801015af:	e8 be fe ff ff       	call   80101472 <bzero>
801015b4:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015bd:	01 d0                	add    %edx,%eax
801015bf:	eb 57                	jmp    80101618 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015c5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015cc:	7f 17                	jg     801015e5 <balloc+0x11b>
801015ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d4:	01 d0                	add    %edx,%eax
801015d6:	89 c2                	mov    %eax,%edx
801015d8:	a1 60 37 19 80       	mov    0x80193760,%eax
801015dd:	39 c2                	cmp    %eax,%edx
801015df:	0f 82 3a ff ff ff    	jb     8010151f <balloc+0x55>
      }
    }
    brelse(bp);
801015e5:	83 ec 0c             	sub    $0xc,%esp
801015e8:	ff 75 ec             	pushl  -0x14(%ebp)
801015eb:	e8 a3 ec ff ff       	call   80100293 <brelse>
801015f0:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015f3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015fa:	8b 15 60 37 19 80    	mov    0x80193760,%edx
80101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101603:	39 c2                	cmp    %eax,%edx
80101605:	0f 87 dc fe ff ff    	ja     801014e7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010160b:	83 ec 0c             	sub    $0xc,%esp
8010160e:	68 c0 a7 10 80       	push   $0x8010a7c0
80101613:	e8 ad ef ff ff       	call   801005c5 <panic>
}
80101618:	c9                   	leave  
80101619:	c3                   	ret    

8010161a <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010161a:	f3 0f 1e fb          	endbr32 
8010161e:	55                   	push   %ebp
8010161f:	89 e5                	mov    %esp,%ebp
80101621:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101624:	83 ec 08             	sub    $0x8,%esp
80101627:	68 60 37 19 80       	push   $0x80193760
8010162c:	ff 75 08             	pushl  0x8(%ebp)
8010162f:	e8 f8 fd ff ff       	call   8010142c <readsb>
80101634:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163a:	c1 e8 0c             	shr    $0xc,%eax
8010163d:	89 c2                	mov    %eax,%edx
8010163f:	a1 78 37 19 80       	mov    0x80193778,%eax
80101644:	01 c2                	add    %eax,%edx
80101646:	8b 45 08             	mov    0x8(%ebp),%eax
80101649:	83 ec 08             	sub    $0x8,%esp
8010164c:	52                   	push   %edx
8010164d:	50                   	push   %eax
8010164e:	e8 b6 eb ff ff       	call   80100209 <bread>
80101653:	83 c4 10             	add    $0x10,%esp
80101656:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101659:	8b 45 0c             	mov    0xc(%ebp),%eax
8010165c:	25 ff 0f 00 00       	and    $0xfff,%eax
80101661:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101667:	99                   	cltd   
80101668:	c1 ea 1d             	shr    $0x1d,%edx
8010166b:	01 d0                	add    %edx,%eax
8010166d:	83 e0 07             	and    $0x7,%eax
80101670:	29 d0                	sub    %edx,%eax
80101672:	ba 01 00 00 00       	mov    $0x1,%edx
80101677:	89 c1                	mov    %eax,%ecx
80101679:	d3 e2                	shl    %cl,%edx
8010167b:	89 d0                	mov    %edx,%eax
8010167d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101683:	8d 50 07             	lea    0x7(%eax),%edx
80101686:	85 c0                	test   %eax,%eax
80101688:	0f 48 c2             	cmovs  %edx,%eax
8010168b:	c1 f8 03             	sar    $0x3,%eax
8010168e:	89 c2                	mov    %eax,%edx
80101690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101693:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101698:	0f b6 c0             	movzbl %al,%eax
8010169b:	23 45 ec             	and    -0x14(%ebp),%eax
8010169e:	85 c0                	test   %eax,%eax
801016a0:	75 0d                	jne    801016af <bfree+0x95>
    panic("freeing free block");
801016a2:	83 ec 0c             	sub    $0xc,%esp
801016a5:	68 d6 a7 10 80       	push   $0x8010a7d6
801016aa:	e8 16 ef ff ff       	call   801005c5 <panic>
  bp->data[bi/8] &= ~m;
801016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b2:	8d 50 07             	lea    0x7(%eax),%edx
801016b5:	85 c0                	test   %eax,%eax
801016b7:	0f 48 c2             	cmovs  %edx,%eax
801016ba:	c1 f8 03             	sar    $0x3,%eax
801016bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c0:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016c5:	89 d1                	mov    %edx,%ecx
801016c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016ca:	f7 d2                	not    %edx
801016cc:	21 ca                	and    %ecx,%edx
801016ce:	89 d1                	mov    %edx,%ecx
801016d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016d3:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016d7:	83 ec 0c             	sub    $0xc,%esp
801016da:	ff 75 f4             	pushl  -0xc(%ebp)
801016dd:	e8 d8 1c 00 00       	call   801033ba <log_write>
801016e2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016e5:	83 ec 0c             	sub    $0xc,%esp
801016e8:	ff 75 f4             	pushl  -0xc(%ebp)
801016eb:	e8 a3 eb ff ff       	call   80100293 <brelse>
801016f0:	83 c4 10             	add    $0x10,%esp
}
801016f3:	90                   	nop
801016f4:	c9                   	leave  
801016f5:	c3                   	ret    

801016f6 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016f6:	f3 0f 1e fb          	endbr32 
801016fa:	55                   	push   %ebp
801016fb:	89 e5                	mov    %esp,%ebp
801016fd:	57                   	push   %edi
801016fe:	56                   	push   %esi
801016ff:	53                   	push   %ebx
80101700:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101703:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010170a:	83 ec 08             	sub    $0x8,%esp
8010170d:	68 e9 a7 10 80       	push   $0x8010a7e9
80101712:	68 80 37 19 80       	push   $0x80193780
80101717:	e8 4a 34 00 00       	call   80104b66 <initlock>
8010171c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010171f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101726:	eb 2d                	jmp    80101755 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101728:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010172b:	89 d0                	mov    %edx,%eax
8010172d:	c1 e0 03             	shl    $0x3,%eax
80101730:	01 d0                	add    %edx,%eax
80101732:	c1 e0 04             	shl    $0x4,%eax
80101735:	83 c0 30             	add    $0x30,%eax
80101738:	05 80 37 19 80       	add    $0x80193780,%eax
8010173d:	83 c0 10             	add    $0x10,%eax
80101740:	83 ec 08             	sub    $0x8,%esp
80101743:	68 f0 a7 10 80       	push   $0x8010a7f0
80101748:	50                   	push   %eax
80101749:	e8 ab 32 00 00       	call   801049f9 <initsleeplock>
8010174e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101751:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101755:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101759:	7e cd                	jle    80101728 <iinit+0x32>
  }

  readsb(dev, &sb);
8010175b:	83 ec 08             	sub    $0x8,%esp
8010175e:	68 60 37 19 80       	push   $0x80193760
80101763:	ff 75 08             	pushl  0x8(%ebp)
80101766:	e8 c1 fc ff ff       	call   8010142c <readsb>
8010176b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010176e:	a1 78 37 19 80       	mov    0x80193778,%eax
80101773:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101776:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
8010177c:	8b 35 70 37 19 80    	mov    0x80193770,%esi
80101782:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
80101788:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
8010178e:	8b 15 64 37 19 80    	mov    0x80193764,%edx
80101794:	a1 60 37 19 80       	mov    0x80193760,%eax
80101799:	ff 75 d4             	pushl  -0x2c(%ebp)
8010179c:	57                   	push   %edi
8010179d:	56                   	push   %esi
8010179e:	53                   	push   %ebx
8010179f:	51                   	push   %ecx
801017a0:	52                   	push   %edx
801017a1:	50                   	push   %eax
801017a2:	68 f8 a7 10 80       	push   $0x8010a7f8
801017a7:	e8 60 ec ff ff       	call   8010040c <cprintf>
801017ac:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017af:	90                   	nop
801017b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017b3:	5b                   	pop    %ebx
801017b4:	5e                   	pop    %esi
801017b5:	5f                   	pop    %edi
801017b6:	5d                   	pop    %ebp
801017b7:	c3                   	ret    

801017b8 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017b8:	f3 0f 1e fb          	endbr32 
801017bc:	55                   	push   %ebp
801017bd:	89 e5                	mov    %esp,%ebp
801017bf:	83 ec 28             	sub    $0x28,%esp
801017c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801017c5:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017c9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017d0:	e9 9e 00 00 00       	jmp    80101873 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d8:	c1 e8 03             	shr    $0x3,%eax
801017db:	89 c2                	mov    %eax,%edx
801017dd:	a1 74 37 19 80       	mov    0x80193774,%eax
801017e2:	01 d0                	add    %edx,%eax
801017e4:	83 ec 08             	sub    $0x8,%esp
801017e7:	50                   	push   %eax
801017e8:	ff 75 08             	pushl  0x8(%ebp)
801017eb:	e8 19 ea ff ff       	call   80100209 <bread>
801017f0:	83 c4 10             	add    $0x10,%esp
801017f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	8d 50 5c             	lea    0x5c(%eax),%edx
801017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ff:	83 e0 07             	and    $0x7,%eax
80101802:	c1 e0 06             	shl    $0x6,%eax
80101805:	01 d0                	add    %edx,%eax
80101807:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010180a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010180d:	0f b7 00             	movzwl (%eax),%eax
80101810:	66 85 c0             	test   %ax,%ax
80101813:	75 4c                	jne    80101861 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101815:	83 ec 04             	sub    $0x4,%esp
80101818:	6a 40                	push   $0x40
8010181a:	6a 00                	push   $0x0
8010181c:	ff 75 ec             	pushl  -0x14(%ebp)
8010181f:	e8 f7 35 00 00       	call   80104e1b <memset>
80101824:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101827:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010182a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010182e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101831:	83 ec 0c             	sub    $0xc,%esp
80101834:	ff 75 f0             	pushl  -0x10(%ebp)
80101837:	e8 7e 1b 00 00       	call   801033ba <log_write>
8010183c:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010183f:	83 ec 0c             	sub    $0xc,%esp
80101842:	ff 75 f0             	pushl  -0x10(%ebp)
80101845:	e8 49 ea ff ff       	call   80100293 <brelse>
8010184a:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101850:	83 ec 08             	sub    $0x8,%esp
80101853:	50                   	push   %eax
80101854:	ff 75 08             	pushl  0x8(%ebp)
80101857:	e8 fc 00 00 00       	call   80101958 <iget>
8010185c:	83 c4 10             	add    $0x10,%esp
8010185f:	eb 30                	jmp    80101891 <ialloc+0xd9>
    }
    brelse(bp);
80101861:	83 ec 0c             	sub    $0xc,%esp
80101864:	ff 75 f0             	pushl  -0x10(%ebp)
80101867:	e8 27 ea ff ff       	call   80100293 <brelse>
8010186c:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010186f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101873:	8b 15 68 37 19 80    	mov    0x80193768,%edx
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	39 c2                	cmp    %eax,%edx
8010187e:	0f 87 51 ff ff ff    	ja     801017d5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 4b a8 10 80       	push   $0x8010a84b
8010188c:	e8 34 ed ff ff       	call   801005c5 <panic>
}
80101891:	c9                   	leave  
80101892:	c3                   	ret    

80101893 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101893:	f3 0f 1e fb          	endbr32 
80101897:	55                   	push   %ebp
80101898:	89 e5                	mov    %esp,%ebp
8010189a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010189d:	8b 45 08             	mov    0x8(%ebp),%eax
801018a0:	8b 40 04             	mov    0x4(%eax),%eax
801018a3:	c1 e8 03             	shr    $0x3,%eax
801018a6:	89 c2                	mov    %eax,%edx
801018a8:	a1 74 37 19 80       	mov    0x80193774,%eax
801018ad:	01 c2                	add    %eax,%edx
801018af:	8b 45 08             	mov    0x8(%ebp),%eax
801018b2:	8b 00                	mov    (%eax),%eax
801018b4:	83 ec 08             	sub    $0x8,%esp
801018b7:	52                   	push   %edx
801018b8:	50                   	push   %eax
801018b9:	e8 4b e9 ff ff       	call   80100209 <bread>
801018be:	83 c4 10             	add    $0x10,%esp
801018c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ca:	8b 45 08             	mov    0x8(%ebp),%eax
801018cd:	8b 40 04             	mov    0x4(%eax),%eax
801018d0:	83 e0 07             	and    $0x7,%eax
801018d3:	c1 e0 06             	shl    $0x6,%eax
801018d6:	01 d0                	add    %edx,%eax
801018d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018db:	8b 45 08             	mov    0x8(%ebp),%eax
801018de:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f2:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018f6:	8b 45 08             	mov    0x8(%ebp),%eax
801018f9:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101900:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101904:	8b 45 08             	mov    0x8(%ebp),%eax
80101907:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101912:	8b 45 08             	mov    0x8(%ebp),%eax
80101915:	8b 50 58             	mov    0x58(%eax),%edx
80101918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191b:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	8d 50 5c             	lea    0x5c(%eax),%edx
80101924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101927:	83 c0 0c             	add    $0xc,%eax
8010192a:	83 ec 04             	sub    $0x4,%esp
8010192d:	6a 34                	push   $0x34
8010192f:	52                   	push   %edx
80101930:	50                   	push   %eax
80101931:	e8 ac 35 00 00       	call   80104ee2 <memmove>
80101936:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	ff 75 f4             	pushl  -0xc(%ebp)
8010193f:	e8 76 1a 00 00       	call   801033ba <log_write>
80101944:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101947:	83 ec 0c             	sub    $0xc,%esp
8010194a:	ff 75 f4             	pushl  -0xc(%ebp)
8010194d:	e8 41 e9 ff ff       	call   80100293 <brelse>
80101952:	83 c4 10             	add    $0x10,%esp
}
80101955:	90                   	nop
80101956:	c9                   	leave  
80101957:	c3                   	ret    

80101958 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101958:	f3 0f 1e fb          	endbr32 
8010195c:	55                   	push   %ebp
8010195d:	89 e5                	mov    %esp,%ebp
8010195f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101962:	83 ec 0c             	sub    $0xc,%esp
80101965:	68 80 37 19 80       	push   $0x80193780
8010196a:	e8 1d 32 00 00       	call   80104b8c <acquire>
8010196f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101972:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101979:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
80101980:	eb 60                	jmp    801019e2 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101985:	8b 40 08             	mov    0x8(%eax),%eax
80101988:	85 c0                	test   %eax,%eax
8010198a:	7e 39                	jle    801019c5 <iget+0x6d>
8010198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198f:	8b 00                	mov    (%eax),%eax
80101991:	39 45 08             	cmp    %eax,0x8(%ebp)
80101994:	75 2f                	jne    801019c5 <iget+0x6d>
80101996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101999:	8b 40 04             	mov    0x4(%eax),%eax
8010199c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010199f:	75 24                	jne    801019c5 <iget+0x6d>
      ip->ref++;
801019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a4:	8b 40 08             	mov    0x8(%eax),%eax
801019a7:	8d 50 01             	lea    0x1(%eax),%edx
801019aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ad:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019b0:	83 ec 0c             	sub    $0xc,%esp
801019b3:	68 80 37 19 80       	push   $0x80193780
801019b8:	e8 41 32 00 00       	call   80104bfe <release>
801019bd:	83 c4 10             	add    $0x10,%esp
      return ip;
801019c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c3:	eb 77                	jmp    80101a3c <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019c9:	75 10                	jne    801019db <iget+0x83>
801019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ce:	8b 40 08             	mov    0x8(%eax),%eax
801019d1:	85 c0                	test   %eax,%eax
801019d3:	75 06                	jne    801019db <iget+0x83>
      empty = ip;
801019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019db:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019e2:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
801019e9:	72 97                	jb     80101982 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ef:	75 0d                	jne    801019fe <iget+0xa6>
    panic("iget: no inodes");
801019f1:	83 ec 0c             	sub    $0xc,%esp
801019f4:	68 5d a8 10 80       	push   $0x8010a85d
801019f9:	e8 c7 eb ff ff       	call   801005c5 <panic>

  ip = empty;
801019fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a07:	8b 55 08             	mov    0x8(%ebp),%edx
80101a0a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a12:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a22:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a29:	83 ec 0c             	sub    $0xc,%esp
80101a2c:	68 80 37 19 80       	push   $0x80193780
80101a31:	e8 c8 31 00 00       	call   80104bfe <release>
80101a36:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a3c:	c9                   	leave  
80101a3d:	c3                   	ret    

80101a3e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a3e:	f3 0f 1e fb          	endbr32 
80101a42:	55                   	push   %ebp
80101a43:	89 e5                	mov    %esp,%ebp
80101a45:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a48:	83 ec 0c             	sub    $0xc,%esp
80101a4b:	68 80 37 19 80       	push   $0x80193780
80101a50:	e8 37 31 00 00       	call   80104b8c <acquire>
80101a55:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 08             	mov    0x8(%eax),%eax
80101a5e:	8d 50 01             	lea    0x1(%eax),%edx
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 80 37 19 80       	push   $0x80193780
80101a6f:	e8 8a 31 00 00       	call   80104bfe <release>
80101a74:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a77:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a7a:	c9                   	leave  
80101a7b:	c3                   	ret    

80101a7c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a7c:	f3 0f 1e fb          	endbr32 
80101a80:	55                   	push   %ebp
80101a81:	89 e5                	mov    %esp,%ebp
80101a83:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a8a:	74 0a                	je     80101a96 <ilock+0x1a>
80101a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8f:	8b 40 08             	mov    0x8(%eax),%eax
80101a92:	85 c0                	test   %eax,%eax
80101a94:	7f 0d                	jg     80101aa3 <ilock+0x27>
    panic("ilock");
80101a96:	83 ec 0c             	sub    $0xc,%esp
80101a99:	68 6d a8 10 80       	push   $0x8010a86d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 87 2f 00 00       	call   80104a39 <acquiresleep>
80101ab2:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101abb:	85 c0                	test   %eax,%eax
80101abd:	0f 85 cd 00 00 00    	jne    80101b90 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	8b 40 04             	mov    0x4(%eax),%eax
80101ac9:	c1 e8 03             	shr    $0x3,%eax
80101acc:	89 c2                	mov    %eax,%edx
80101ace:	a1 74 37 19 80       	mov    0x80193774,%eax
80101ad3:	01 c2                	add    %eax,%edx
80101ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad8:	8b 00                	mov    (%eax),%eax
80101ada:	83 ec 08             	sub    $0x8,%esp
80101add:	52                   	push   %edx
80101ade:	50                   	push   %eax
80101adf:	e8 25 e7 ff ff       	call   80100209 <bread>
80101ae4:	83 c4 10             	add    $0x10,%esp
80101ae7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aed:	8d 50 5c             	lea    0x5c(%eax),%edx
80101af0:	8b 45 08             	mov    0x8(%ebp),%eax
80101af3:	8b 40 04             	mov    0x4(%eax),%eax
80101af6:	83 e0 07             	and    $0x7,%eax
80101af9:	c1 e0 06             	shl    $0x6,%eax
80101afc:	01 d0                	add    %edx,%eax
80101afe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b04:	0f b7 10             	movzwl (%eax),%edx
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b11:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b31:	8b 45 08             	mov    0x8(%ebp),%eax
80101b34:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b3b:	8b 50 08             	mov    0x8(%eax),%edx
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b47:	8d 50 0c             	lea    0xc(%eax),%edx
80101b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4d:	83 c0 5c             	add    $0x5c,%eax
80101b50:	83 ec 04             	sub    $0x4,%esp
80101b53:	6a 34                	push   $0x34
80101b55:	52                   	push   %edx
80101b56:	50                   	push   %eax
80101b57:	e8 86 33 00 00       	call   80104ee2 <memmove>
80101b5c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	ff 75 f4             	pushl  -0xc(%ebp)
80101b65:	e8 29 e7 ff ff       	call   80100293 <brelse>
80101b6a:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b7e:	66 85 c0             	test   %ax,%ax
80101b81:	75 0d                	jne    80101b90 <ilock+0x114>
      panic("ilock: no type");
80101b83:	83 ec 0c             	sub    $0xc,%esp
80101b86:	68 73 a8 10 80       	push   $0x8010a873
80101b8b:	e8 35 ea ff ff       	call   801005c5 <panic>
  }
}
80101b90:	90                   	nop
80101b91:	c9                   	leave  
80101b92:	c3                   	ret    

80101b93 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b93:	f3 0f 1e fb          	endbr32 
80101b97:	55                   	push   %ebp
80101b98:	89 e5                	mov    %esp,%ebp
80101b9a:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ba1:	74 20                	je     80101bc3 <iunlock+0x30>
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	83 c0 0c             	add    $0xc,%eax
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	50                   	push   %eax
80101bad:	e8 41 2f 00 00       	call   80104af3 <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 82 a8 10 80       	push   $0x8010a882
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 c2 2e 00 00       	call   80104aa1 <releasesleep>
80101bdf:	83 c4 10             	add    $0x10,%esp
}
80101be2:	90                   	nop
80101be3:	c9                   	leave  
80101be4:	c3                   	ret    

80101be5 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101be5:	f3 0f 1e fb          	endbr32 
80101be9:	55                   	push   %ebp
80101bea:	89 e5                	mov    %esp,%ebp
80101bec:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	83 c0 0c             	add    $0xc,%eax
80101bf5:	83 ec 0c             	sub    $0xc,%esp
80101bf8:	50                   	push   %eax
80101bf9:	e8 3b 2e 00 00       	call   80104a39 <acquiresleep>
80101bfe:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c07:	85 c0                	test   %eax,%eax
80101c09:	74 6a                	je     80101c75 <iput+0x90>
80101c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c12:	66 85 c0             	test   %ax,%ax
80101c15:	75 5e                	jne    80101c75 <iput+0x90>
    acquire(&icache.lock);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	68 80 37 19 80       	push   $0x80193780
80101c1f:	e8 68 2f 00 00       	call   80104b8c <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 80 37 19 80       	push   $0x80193780
80101c38:	e8 c1 2f 00 00       	call   80104bfe <release>
80101c3d:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c40:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c44:	75 2f                	jne    80101c75 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c46:	83 ec 0c             	sub    $0xc,%esp
80101c49:	ff 75 08             	pushl  0x8(%ebp)
80101c4c:	e8 b5 01 00 00       	call   80101e06 <itrunc>
80101c51:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 08             	pushl  0x8(%ebp)
80101c63:	e8 2b fc ff ff       	call   80101893 <iupdate>
80101c68:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c75:	8b 45 08             	mov    0x8(%ebp),%eax
80101c78:	83 c0 0c             	add    $0xc,%eax
80101c7b:	83 ec 0c             	sub    $0xc,%esp
80101c7e:	50                   	push   %eax
80101c7f:	e8 1d 2e 00 00       	call   80104aa1 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 80 37 19 80       	push   $0x80193780
80101c8f:	e8 f8 2e 00 00       	call   80104b8c <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 08             	mov    0x8(%eax),%eax
80101c9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ca6:	83 ec 0c             	sub    $0xc,%esp
80101ca9:	68 80 37 19 80       	push   $0x80193780
80101cae:	e8 4b 2f 00 00       	call   80104bfe <release>
80101cb3:	83 c4 10             	add    $0x10,%esp
}
80101cb6:	90                   	nop
80101cb7:	c9                   	leave  
80101cb8:	c3                   	ret    

80101cb9 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cb9:	f3 0f 1e fb          	endbr32 
80101cbd:	55                   	push   %ebp
80101cbe:	89 e5                	mov    %esp,%ebp
80101cc0:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cc3:	83 ec 0c             	sub    $0xc,%esp
80101cc6:	ff 75 08             	pushl  0x8(%ebp)
80101cc9:	e8 c5 fe ff ff       	call   80101b93 <iunlock>
80101cce:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cd1:	83 ec 0c             	sub    $0xc,%esp
80101cd4:	ff 75 08             	pushl  0x8(%ebp)
80101cd7:	e8 09 ff ff ff       	call   80101be5 <iput>
80101cdc:	83 c4 10             	add    $0x10,%esp
}
80101cdf:	90                   	nop
80101ce0:	c9                   	leave  
80101ce1:	c3                   	ret    

80101ce2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ce2:	f3 0f 1e fb          	endbr32 
80101ce6:	55                   	push   %ebp
80101ce7:	89 e5                	mov    %esp,%ebp
80101ce9:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cec:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cf0:	77 42                	ja     80101d34 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cf8:	83 c2 14             	add    $0x14,%edx
80101cfb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d06:	75 24                	jne    80101d2c <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d08:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	83 ec 0c             	sub    $0xc,%esp
80101d10:	50                   	push   %eax
80101d11:	e8 b4 f7 ff ff       	call   801014ca <balloc>
80101d16:	83 c4 10             	add    $0x10,%esp
80101d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d22:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d28:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2f:	e9 d0 00 00 00       	jmp    80101e04 <bmap+0x122>
  }
  bn -= NDIRECT;
80101d34:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d38:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d3c:	0f 87 b5 00 00 00    	ja     80101df7 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d52:	75 20                	jne    80101d74 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d54:	8b 45 08             	mov    0x8(%ebp),%eax
80101d57:	8b 00                	mov    (%eax),%eax
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	50                   	push   %eax
80101d5d:	e8 68 f7 ff ff       	call   801014ca <balloc>
80101d62:	83 c4 10             	add    $0x10,%esp
80101d65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d68:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	8b 00                	mov    (%eax),%eax
80101d79:	83 ec 08             	sub    $0x8,%esp
80101d7c:	ff 75 f4             	pushl  -0xc(%ebp)
80101d7f:	50                   	push   %eax
80101d80:	e8 84 e4 ff ff       	call   80100209 <bread>
80101d85:	83 c4 10             	add    $0x10,%esp
80101d88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d8e:	83 c0 5c             	add    $0x5c,%eax
80101d91:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d94:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d97:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101da1:	01 d0                	add    %edx,%eax
80101da3:	8b 00                	mov    (%eax),%eax
80101da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dac:	75 36                	jne    80101de4 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101dae:	8b 45 08             	mov    0x8(%ebp),%eax
80101db1:	8b 00                	mov    (%eax),%eax
80101db3:	83 ec 0c             	sub    $0xc,%esp
80101db6:	50                   	push   %eax
80101db7:	e8 0e f7 ff ff       	call   801014ca <balloc>
80101dbc:	83 c4 10             	add    $0x10,%esp
80101dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dcf:	01 c2                	add    %eax,%edx
80101dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dd4:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	ff 75 f0             	pushl  -0x10(%ebp)
80101ddc:	e8 d9 15 00 00       	call   801033ba <log_write>
80101de1:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101de4:	83 ec 0c             	sub    $0xc,%esp
80101de7:	ff 75 f0             	pushl  -0x10(%ebp)
80101dea:	e8 a4 e4 ff ff       	call   80100293 <brelse>
80101def:	83 c4 10             	add    $0x10,%esp
    return addr;
80101df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df5:	eb 0d                	jmp    80101e04 <bmap+0x122>
  }

  panic("bmap: out of range");
80101df7:	83 ec 0c             	sub    $0xc,%esp
80101dfa:	68 8a a8 10 80       	push   $0x8010a88a
80101dff:	e8 c1 e7 ff ff       	call   801005c5 <panic>
}
80101e04:	c9                   	leave  
80101e05:	c3                   	ret    

80101e06 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e06:	f3 0f 1e fb          	endbr32 
80101e0a:	55                   	push   %ebp
80101e0b:	89 e5                	mov    %esp,%ebp
80101e0d:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e17:	eb 45                	jmp    80101e5e <itrunc+0x58>
    if(ip->addrs[i]){
80101e19:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e1f:	83 c2 14             	add    $0x14,%edx
80101e22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e26:	85 c0                	test   %eax,%eax
80101e28:	74 30                	je     80101e5a <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e30:	83 c2 14             	add    $0x14,%edx
80101e33:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e37:	8b 55 08             	mov    0x8(%ebp),%edx
80101e3a:	8b 12                	mov    (%edx),%edx
80101e3c:	83 ec 08             	sub    $0x8,%esp
80101e3f:	50                   	push   %eax
80101e40:	52                   	push   %edx
80101e41:	e8 d4 f7 ff ff       	call   8010161a <bfree>
80101e46:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e49:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e4f:	83 c2 14             	add    $0x14,%edx
80101e52:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e59:	00 
  for(i = 0; i < NDIRECT; i++){
80101e5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e5e:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e62:	7e b5                	jle    80101e19 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e6d:	85 c0                	test   %eax,%eax
80101e6f:	0f 84 aa 00 00 00    	je     80101f1f <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e75:	8b 45 08             	mov    0x8(%ebp),%eax
80101e78:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e81:	8b 00                	mov    (%eax),%eax
80101e83:	83 ec 08             	sub    $0x8,%esp
80101e86:	52                   	push   %edx
80101e87:	50                   	push   %eax
80101e88:	e8 7c e3 ff ff       	call   80100209 <bread>
80101e8d:	83 c4 10             	add    $0x10,%esp
80101e90:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e96:	83 c0 5c             	add    $0x5c,%eax
80101e99:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ea3:	eb 3c                	jmp    80101ee1 <itrunc+0xdb>
      if(a[j])
80101ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eb2:	01 d0                	add    %edx,%eax
80101eb4:	8b 00                	mov    (%eax),%eax
80101eb6:	85 c0                	test   %eax,%eax
80101eb8:	74 23                	je     80101edd <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ec7:	01 d0                	add    %edx,%eax
80101ec9:	8b 00                	mov    (%eax),%eax
80101ecb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ece:	8b 12                	mov    (%edx),%edx
80101ed0:	83 ec 08             	sub    $0x8,%esp
80101ed3:	50                   	push   %eax
80101ed4:	52                   	push   %edx
80101ed5:	e8 40 f7 ff ff       	call   8010161a <bfree>
80101eda:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101edd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee4:	83 f8 7f             	cmp    $0x7f,%eax
80101ee7:	76 bc                	jbe    80101ea5 <itrunc+0x9f>
    }
    brelse(bp);
80101ee9:	83 ec 0c             	sub    $0xc,%esp
80101eec:	ff 75 ec             	pushl  -0x14(%ebp)
80101eef:	e8 9f e3 ff ff       	call   80100293 <brelse>
80101ef4:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f00:	8b 55 08             	mov    0x8(%ebp),%edx
80101f03:	8b 12                	mov    (%edx),%edx
80101f05:	83 ec 08             	sub    $0x8,%esp
80101f08:	50                   	push   %eax
80101f09:	52                   	push   %edx
80101f0a:	e8 0b f7 ff ff       	call   8010161a <bfree>
80101f0f:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f12:	8b 45 08             	mov    0x8(%ebp),%eax
80101f15:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f1c:	00 00 00 
  }

  ip->size = 0;
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f29:	83 ec 0c             	sub    $0xc,%esp
80101f2c:	ff 75 08             	pushl  0x8(%ebp)
80101f2f:	e8 5f f9 ff ff       	call   80101893 <iupdate>
80101f34:	83 c4 10             	add    $0x10,%esp
}
80101f37:	90                   	nop
80101f38:	c9                   	leave  
80101f39:	c3                   	ret    

80101f3a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f3a:	f3 0f 1e fb          	endbr32 
80101f3e:	55                   	push   %ebp
80101f3f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f41:	8b 45 08             	mov    0x8(%ebp),%eax
80101f44:	8b 00                	mov    (%eax),%eax
80101f46:	89 c2                	mov    %eax,%edx
80101f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f4b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f51:	8b 50 04             	mov    0x4(%eax),%edx
80101f54:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f57:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f61:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f64:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f67:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f71:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 50 58             	mov    0x58(%eax),%edx
80101f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f7e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f81:	90                   	nop
80101f82:	5d                   	pop    %ebp
80101f83:	c3                   	ret    

80101f84 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f84:	f3 0f 1e fb          	endbr32 
80101f88:	55                   	push   %ebp
80101f89:	89 e5                	mov    %esp,%ebp
80101f8b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f91:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f95:	66 83 f8 03          	cmp    $0x3,%ax
80101f99:	75 5c                	jne    80101ff7 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fa2:	66 85 c0             	test   %ax,%ax
80101fa5:	78 20                	js     80101fc7 <readi+0x43>
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fae:	66 83 f8 09          	cmp    $0x9,%ax
80101fb2:	7f 13                	jg     80101fc7 <readi+0x43>
80101fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fbb:	98                   	cwtl   
80101fbc:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	75 0a                	jne    80101fd1 <readi+0x4d>
      return -1;
80101fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fcc:	e9 0a 01 00 00       	jmp    801020db <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fd8:	98                   	cwtl   
80101fd9:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fe0:	8b 55 14             	mov    0x14(%ebp),%edx
80101fe3:	83 ec 04             	sub    $0x4,%esp
80101fe6:	52                   	push   %edx
80101fe7:	ff 75 0c             	pushl  0xc(%ebp)
80101fea:	ff 75 08             	pushl  0x8(%ebp)
80101fed:	ff d0                	call   *%eax
80101fef:	83 c4 10             	add    $0x10,%esp
80101ff2:	e9 e4 00 00 00       	jmp    801020db <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80101ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffa:	8b 40 58             	mov    0x58(%eax),%eax
80101ffd:	39 45 10             	cmp    %eax,0x10(%ebp)
80102000:	77 0d                	ja     8010200f <readi+0x8b>
80102002:	8b 55 10             	mov    0x10(%ebp),%edx
80102005:	8b 45 14             	mov    0x14(%ebp),%eax
80102008:	01 d0                	add    %edx,%eax
8010200a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010200d:	76 0a                	jbe    80102019 <readi+0x95>
    return -1;
8010200f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102014:	e9 c2 00 00 00       	jmp    801020db <readi+0x157>
  if(off + n > ip->size)
80102019:	8b 55 10             	mov    0x10(%ebp),%edx
8010201c:	8b 45 14             	mov    0x14(%ebp),%eax
8010201f:	01 c2                	add    %eax,%edx
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	8b 40 58             	mov    0x58(%eax),%eax
80102027:	39 c2                	cmp    %eax,%edx
80102029:	76 0c                	jbe    80102037 <readi+0xb3>
    n = ip->size - off;
8010202b:	8b 45 08             	mov    0x8(%ebp),%eax
8010202e:	8b 40 58             	mov    0x58(%eax),%eax
80102031:	2b 45 10             	sub    0x10(%ebp),%eax
80102034:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102037:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010203e:	e9 89 00 00 00       	jmp    801020cc <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102043:	8b 45 10             	mov    0x10(%ebp),%eax
80102046:	c1 e8 09             	shr    $0x9,%eax
80102049:	83 ec 08             	sub    $0x8,%esp
8010204c:	50                   	push   %eax
8010204d:	ff 75 08             	pushl  0x8(%ebp)
80102050:	e8 8d fc ff ff       	call   80101ce2 <bmap>
80102055:	83 c4 10             	add    $0x10,%esp
80102058:	8b 55 08             	mov    0x8(%ebp),%edx
8010205b:	8b 12                	mov    (%edx),%edx
8010205d:	83 ec 08             	sub    $0x8,%esp
80102060:	50                   	push   %eax
80102061:	52                   	push   %edx
80102062:	e8 a2 e1 ff ff       	call   80100209 <bread>
80102067:	83 c4 10             	add    $0x10,%esp
8010206a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010206d:	8b 45 10             	mov    0x10(%ebp),%eax
80102070:	25 ff 01 00 00       	and    $0x1ff,%eax
80102075:	ba 00 02 00 00       	mov    $0x200,%edx
8010207a:	29 c2                	sub    %eax,%edx
8010207c:	8b 45 14             	mov    0x14(%ebp),%eax
8010207f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102082:	39 c2                	cmp    %eax,%edx
80102084:	0f 46 c2             	cmovbe %edx,%eax
80102087:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010208a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010208d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102090:	8b 45 10             	mov    0x10(%ebp),%eax
80102093:	25 ff 01 00 00       	and    $0x1ff,%eax
80102098:	01 d0                	add    %edx,%eax
8010209a:	83 ec 04             	sub    $0x4,%esp
8010209d:	ff 75 ec             	pushl  -0x14(%ebp)
801020a0:	50                   	push   %eax
801020a1:	ff 75 0c             	pushl  0xc(%ebp)
801020a4:	e8 39 2e 00 00       	call   80104ee2 <memmove>
801020a9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020ac:	83 ec 0c             	sub    $0xc,%esp
801020af:	ff 75 f0             	pushl  -0x10(%ebp)
801020b2:	e8 dc e1 ff ff       	call   80100293 <brelse>
801020b7:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020bd:	01 45 f4             	add    %eax,-0xc(%ebp)
801020c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c3:	01 45 10             	add    %eax,0x10(%ebp)
801020c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c9:	01 45 0c             	add    %eax,0xc(%ebp)
801020cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020cf:	3b 45 14             	cmp    0x14(%ebp),%eax
801020d2:	0f 82 6b ff ff ff    	jb     80102043 <readi+0xbf>
  }
  return n;
801020d8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020db:	c9                   	leave  
801020dc:	c3                   	ret    

801020dd <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020dd:	f3 0f 1e fb          	endbr32 
801020e1:	55                   	push   %ebp
801020e2:	89 e5                	mov    %esp,%ebp
801020e4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020e7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ea:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020ee:	66 83 f8 03          	cmp    $0x3,%ax
801020f2:	75 5c                	jne    80102150 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020f4:	8b 45 08             	mov    0x8(%ebp),%eax
801020f7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020fb:	66 85 c0             	test   %ax,%ax
801020fe:	78 20                	js     80102120 <writei+0x43>
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
80102103:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102107:	66 83 f8 09          	cmp    $0x9,%ax
8010210b:	7f 13                	jg     80102120 <writei+0x43>
8010210d:	8b 45 08             	mov    0x8(%ebp),%eax
80102110:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102114:	98                   	cwtl   
80102115:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	75 0a                	jne    8010212a <writei+0x4d>
      return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 3b 01 00 00       	jmp    80102265 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102131:	98                   	cwtl   
80102132:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
80102139:	8b 55 14             	mov    0x14(%ebp),%edx
8010213c:	83 ec 04             	sub    $0x4,%esp
8010213f:	52                   	push   %edx
80102140:	ff 75 0c             	pushl  0xc(%ebp)
80102143:	ff 75 08             	pushl  0x8(%ebp)
80102146:	ff d0                	call   *%eax
80102148:	83 c4 10             	add    $0x10,%esp
8010214b:	e9 15 01 00 00       	jmp    80102265 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 40 58             	mov    0x58(%eax),%eax
80102156:	39 45 10             	cmp    %eax,0x10(%ebp)
80102159:	77 0d                	ja     80102168 <writei+0x8b>
8010215b:	8b 55 10             	mov    0x10(%ebp),%edx
8010215e:	8b 45 14             	mov    0x14(%ebp),%eax
80102161:	01 d0                	add    %edx,%eax
80102163:	39 45 10             	cmp    %eax,0x10(%ebp)
80102166:	76 0a                	jbe    80102172 <writei+0x95>
    return -1;
80102168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010216d:	e9 f3 00 00 00       	jmp    80102265 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102172:	8b 55 10             	mov    0x10(%ebp),%edx
80102175:	8b 45 14             	mov    0x14(%ebp),%eax
80102178:	01 d0                	add    %edx,%eax
8010217a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010217f:	76 0a                	jbe    8010218b <writei+0xae>
    return -1;
80102181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102186:	e9 da 00 00 00       	jmp    80102265 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010218b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102192:	e9 97 00 00 00       	jmp    8010222e <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102197:	8b 45 10             	mov    0x10(%ebp),%eax
8010219a:	c1 e8 09             	shr    $0x9,%eax
8010219d:	83 ec 08             	sub    $0x8,%esp
801021a0:	50                   	push   %eax
801021a1:	ff 75 08             	pushl  0x8(%ebp)
801021a4:	e8 39 fb ff ff       	call   80101ce2 <bmap>
801021a9:	83 c4 10             	add    $0x10,%esp
801021ac:	8b 55 08             	mov    0x8(%ebp),%edx
801021af:	8b 12                	mov    (%edx),%edx
801021b1:	83 ec 08             	sub    $0x8,%esp
801021b4:	50                   	push   %eax
801021b5:	52                   	push   %edx
801021b6:	e8 4e e0 ff ff       	call   80100209 <bread>
801021bb:	83 c4 10             	add    $0x10,%esp
801021be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021c1:	8b 45 10             	mov    0x10(%ebp),%eax
801021c4:	25 ff 01 00 00       	and    $0x1ff,%eax
801021c9:	ba 00 02 00 00       	mov    $0x200,%edx
801021ce:	29 c2                	sub    %eax,%edx
801021d0:	8b 45 14             	mov    0x14(%ebp),%eax
801021d3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021d6:	39 c2                	cmp    %eax,%edx
801021d8:	0f 46 c2             	cmovbe %edx,%eax
801021db:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e1:	8d 50 5c             	lea    0x5c(%eax),%edx
801021e4:	8b 45 10             	mov    0x10(%ebp),%eax
801021e7:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ec:	01 d0                	add    %edx,%eax
801021ee:	83 ec 04             	sub    $0x4,%esp
801021f1:	ff 75 ec             	pushl  -0x14(%ebp)
801021f4:	ff 75 0c             	pushl  0xc(%ebp)
801021f7:	50                   	push   %eax
801021f8:	e8 e5 2c 00 00       	call   80104ee2 <memmove>
801021fd:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102200:	83 ec 0c             	sub    $0xc,%esp
80102203:	ff 75 f0             	pushl  -0x10(%ebp)
80102206:	e8 af 11 00 00       	call   801033ba <log_write>
8010220b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010220e:	83 ec 0c             	sub    $0xc,%esp
80102211:	ff 75 f0             	pushl  -0x10(%ebp)
80102214:	e8 7a e0 ff ff       	call   80100293 <brelse>
80102219:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010221c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010221f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102222:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102225:	01 45 10             	add    %eax,0x10(%ebp)
80102228:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010222b:	01 45 0c             	add    %eax,0xc(%ebp)
8010222e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102231:	3b 45 14             	cmp    0x14(%ebp),%eax
80102234:	0f 82 5d ff ff ff    	jb     80102197 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
8010223a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010223e:	74 22                	je     80102262 <writei+0x185>
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	8b 40 58             	mov    0x58(%eax),%eax
80102246:	39 45 10             	cmp    %eax,0x10(%ebp)
80102249:	76 17                	jbe    80102262 <writei+0x185>
    ip->size = off;
8010224b:	8b 45 08             	mov    0x8(%ebp),%eax
8010224e:	8b 55 10             	mov    0x10(%ebp),%edx
80102251:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102254:	83 ec 0c             	sub    $0xc,%esp
80102257:	ff 75 08             	pushl  0x8(%ebp)
8010225a:	e8 34 f6 ff ff       	call   80101893 <iupdate>
8010225f:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102262:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102265:	c9                   	leave  
80102266:	c3                   	ret    

80102267 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102267:	f3 0f 1e fb          	endbr32 
8010226b:	55                   	push   %ebp
8010226c:	89 e5                	mov    %esp,%ebp
8010226e:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102271:	83 ec 04             	sub    $0x4,%esp
80102274:	6a 0e                	push   $0xe
80102276:	ff 75 0c             	pushl  0xc(%ebp)
80102279:	ff 75 08             	pushl  0x8(%ebp)
8010227c:	e8 ff 2c 00 00       	call   80104f80 <strncmp>
80102281:	83 c4 10             	add    $0x10,%esp
}
80102284:	c9                   	leave  
80102285:	c3                   	ret    

80102286 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102286:	f3 0f 1e fb          	endbr32 
8010228a:	55                   	push   %ebp
8010228b:	89 e5                	mov    %esp,%ebp
8010228d:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102290:	8b 45 08             	mov    0x8(%ebp),%eax
80102293:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102297:	66 83 f8 01          	cmp    $0x1,%ax
8010229b:	74 0d                	je     801022aa <dirlookup+0x24>
    panic("dirlookup not DIR");
8010229d:	83 ec 0c             	sub    $0xc,%esp
801022a0:	68 9d a8 10 80       	push   $0x8010a89d
801022a5:	e8 1b e3 ff ff       	call   801005c5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b1:	eb 7b                	jmp    8010232e <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b3:	6a 10                	push   $0x10
801022b5:	ff 75 f4             	pushl  -0xc(%ebp)
801022b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bb:	50                   	push   %eax
801022bc:	ff 75 08             	pushl  0x8(%ebp)
801022bf:	e8 c0 fc ff ff       	call   80101f84 <readi>
801022c4:	83 c4 10             	add    $0x10,%esp
801022c7:	83 f8 10             	cmp    $0x10,%eax
801022ca:	74 0d                	je     801022d9 <dirlookup+0x53>
      panic("dirlookup read");
801022cc:	83 ec 0c             	sub    $0xc,%esp
801022cf:	68 af a8 10 80       	push   $0x8010a8af
801022d4:	e8 ec e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801022d9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022dd:	66 85 c0             	test   %ax,%ax
801022e0:	74 47                	je     80102329 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801022e2:	83 ec 08             	sub    $0x8,%esp
801022e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e8:	83 c0 02             	add    $0x2,%eax
801022eb:	50                   	push   %eax
801022ec:	ff 75 0c             	pushl  0xc(%ebp)
801022ef:	e8 73 ff ff ff       	call   80102267 <namecmp>
801022f4:	83 c4 10             	add    $0x10,%esp
801022f7:	85 c0                	test   %eax,%eax
801022f9:	75 2f                	jne    8010232a <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801022fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022ff:	74 08                	je     80102309 <dirlookup+0x83>
        *poff = off;
80102301:	8b 45 10             	mov    0x10(%ebp),%eax
80102304:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102307:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102309:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010230d:	0f b7 c0             	movzwl %ax,%eax
80102310:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102313:	8b 45 08             	mov    0x8(%ebp),%eax
80102316:	8b 00                	mov    (%eax),%eax
80102318:	83 ec 08             	sub    $0x8,%esp
8010231b:	ff 75 f0             	pushl  -0x10(%ebp)
8010231e:	50                   	push   %eax
8010231f:	e8 34 f6 ff ff       	call   80101958 <iget>
80102324:	83 c4 10             	add    $0x10,%esp
80102327:	eb 19                	jmp    80102342 <dirlookup+0xbc>
      continue;
80102329:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010232a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010232e:	8b 45 08             	mov    0x8(%ebp),%eax
80102331:	8b 40 58             	mov    0x58(%eax),%eax
80102334:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102337:	0f 82 76 ff ff ff    	jb     801022b3 <dirlookup+0x2d>
    }
  }

  return 0;
8010233d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102342:	c9                   	leave  
80102343:	c3                   	ret    

80102344 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102344:	f3 0f 1e fb          	endbr32 
80102348:	55                   	push   %ebp
80102349:	89 e5                	mov    %esp,%ebp
8010234b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010234e:	83 ec 04             	sub    $0x4,%esp
80102351:	6a 00                	push   $0x0
80102353:	ff 75 0c             	pushl  0xc(%ebp)
80102356:	ff 75 08             	pushl  0x8(%ebp)
80102359:	e8 28 ff ff ff       	call   80102286 <dirlookup>
8010235e:	83 c4 10             	add    $0x10,%esp
80102361:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102364:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102368:	74 18                	je     80102382 <dirlink+0x3e>
    iput(ip);
8010236a:	83 ec 0c             	sub    $0xc,%esp
8010236d:	ff 75 f0             	pushl  -0x10(%ebp)
80102370:	e8 70 f8 ff ff       	call   80101be5 <iput>
80102375:	83 c4 10             	add    $0x10,%esp
    return -1;
80102378:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010237d:	e9 9c 00 00 00       	jmp    8010241e <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102389:	eb 39                	jmp    801023c4 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010238b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238e:	6a 10                	push   $0x10
80102390:	50                   	push   %eax
80102391:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102394:	50                   	push   %eax
80102395:	ff 75 08             	pushl  0x8(%ebp)
80102398:	e8 e7 fb ff ff       	call   80101f84 <readi>
8010239d:	83 c4 10             	add    $0x10,%esp
801023a0:	83 f8 10             	cmp    $0x10,%eax
801023a3:	74 0d                	je     801023b2 <dirlink+0x6e>
      panic("dirlink read");
801023a5:	83 ec 0c             	sub    $0xc,%esp
801023a8:	68 be a8 10 80       	push   $0x8010a8be
801023ad:	e8 13 e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801023b2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023b6:	66 85 c0             	test   %ax,%ax
801023b9:	74 18                	je     801023d3 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023be:	83 c0 10             	add    $0x10,%eax
801023c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023c4:	8b 45 08             	mov    0x8(%ebp),%eax
801023c7:	8b 50 58             	mov    0x58(%eax),%edx
801023ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cd:	39 c2                	cmp    %eax,%edx
801023cf:	77 ba                	ja     8010238b <dirlink+0x47>
801023d1:	eb 01                	jmp    801023d4 <dirlink+0x90>
      break;
801023d3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	6a 0e                	push   $0xe
801023d9:	ff 75 0c             	pushl  0xc(%ebp)
801023dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023df:	83 c0 02             	add    $0x2,%eax
801023e2:	50                   	push   %eax
801023e3:	e8 f2 2b 00 00       	call   80104fda <strncpy>
801023e8:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023eb:	8b 45 10             	mov    0x10(%ebp),%eax
801023ee:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f5:	6a 10                	push   $0x10
801023f7:	50                   	push   %eax
801023f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023fb:	50                   	push   %eax
801023fc:	ff 75 08             	pushl  0x8(%ebp)
801023ff:	e8 d9 fc ff ff       	call   801020dd <writei>
80102404:	83 c4 10             	add    $0x10,%esp
80102407:	83 f8 10             	cmp    $0x10,%eax
8010240a:	74 0d                	je     80102419 <dirlink+0xd5>
    panic("dirlink");
8010240c:	83 ec 0c             	sub    $0xc,%esp
8010240f:	68 cb a8 10 80       	push   $0x8010a8cb
80102414:	e8 ac e1 ff ff       	call   801005c5 <panic>

  return 0;
80102419:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010241e:	c9                   	leave  
8010241f:	c3                   	ret    

80102420 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102420:	f3 0f 1e fb          	endbr32 
80102424:	55                   	push   %ebp
80102425:	89 e5                	mov    %esp,%ebp
80102427:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010242a:	eb 04                	jmp    80102430 <skipelem+0x10>
    path++;
8010242c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102430:	8b 45 08             	mov    0x8(%ebp),%eax
80102433:	0f b6 00             	movzbl (%eax),%eax
80102436:	3c 2f                	cmp    $0x2f,%al
80102438:	74 f2                	je     8010242c <skipelem+0xc>
  if(*path == 0)
8010243a:	8b 45 08             	mov    0x8(%ebp),%eax
8010243d:	0f b6 00             	movzbl (%eax),%eax
80102440:	84 c0                	test   %al,%al
80102442:	75 07                	jne    8010244b <skipelem+0x2b>
    return 0;
80102444:	b8 00 00 00 00       	mov    $0x0,%eax
80102449:	eb 77                	jmp    801024c2 <skipelem+0xa2>
  s = path;
8010244b:	8b 45 08             	mov    0x8(%ebp),%eax
8010244e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102451:	eb 04                	jmp    80102457 <skipelem+0x37>
    path++;
80102453:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102457:	8b 45 08             	mov    0x8(%ebp),%eax
8010245a:	0f b6 00             	movzbl (%eax),%eax
8010245d:	3c 2f                	cmp    $0x2f,%al
8010245f:	74 0a                	je     8010246b <skipelem+0x4b>
80102461:	8b 45 08             	mov    0x8(%ebp),%eax
80102464:	0f b6 00             	movzbl (%eax),%eax
80102467:	84 c0                	test   %al,%al
80102469:	75 e8                	jne    80102453 <skipelem+0x33>
  len = path - s;
8010246b:	8b 45 08             	mov    0x8(%ebp),%eax
8010246e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102471:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102474:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102478:	7e 15                	jle    8010248f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010247a:	83 ec 04             	sub    $0x4,%esp
8010247d:	6a 0e                	push   $0xe
8010247f:	ff 75 f4             	pushl  -0xc(%ebp)
80102482:	ff 75 0c             	pushl  0xc(%ebp)
80102485:	e8 58 2a 00 00       	call   80104ee2 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	ff 75 0c             	pushl  0xc(%ebp)
8010249c:	e8 41 2a 00 00       	call   80104ee2 <memmove>
801024a1:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801024aa:	01 d0                	add    %edx,%eax
801024ac:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024af:	eb 04                	jmp    801024b5 <skipelem+0x95>
    path++;
801024b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024b5:	8b 45 08             	mov    0x8(%ebp),%eax
801024b8:	0f b6 00             	movzbl (%eax),%eax
801024bb:	3c 2f                	cmp    $0x2f,%al
801024bd:	74 f2                	je     801024b1 <skipelem+0x91>
  return path;
801024bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024c2:	c9                   	leave  
801024c3:	c3                   	ret    

801024c4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024c4:	f3 0f 1e fb          	endbr32 
801024c8:	55                   	push   %ebp
801024c9:	89 e5                	mov    %esp,%ebp
801024cb:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024ce:	8b 45 08             	mov    0x8(%ebp),%eax
801024d1:	0f b6 00             	movzbl (%eax),%eax
801024d4:	3c 2f                	cmp    $0x2f,%al
801024d6:	75 17                	jne    801024ef <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024d8:	83 ec 08             	sub    $0x8,%esp
801024db:	6a 01                	push   $0x1
801024dd:	6a 01                	push   $0x1
801024df:	e8 74 f4 ff ff       	call   80101958 <iget>
801024e4:	83 c4 10             	add    $0x10,%esp
801024e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024ea:	e9 ba 00 00 00       	jmp    801025a9 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801024ef:	e8 b5 16 00 00       	call   80103ba9 <myproc>
801024f4:	8b 40 68             	mov    0x68(%eax),%eax
801024f7:	83 ec 0c             	sub    $0xc,%esp
801024fa:	50                   	push   %eax
801024fb:	e8 3e f5 ff ff       	call   80101a3e <idup>
80102500:	83 c4 10             	add    $0x10,%esp
80102503:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102506:	e9 9e 00 00 00       	jmp    801025a9 <namex+0xe5>
    ilock(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	pushl  -0xc(%ebp)
80102511:	e8 66 f5 ff ff       	call   80101a7c <ilock>
80102516:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010251c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102520:	66 83 f8 01          	cmp    $0x1,%ax
80102524:	74 18                	je     8010253e <namex+0x7a>
      iunlockput(ip);
80102526:	83 ec 0c             	sub    $0xc,%esp
80102529:	ff 75 f4             	pushl  -0xc(%ebp)
8010252c:	e8 88 f7 ff ff       	call   80101cb9 <iunlockput>
80102531:	83 c4 10             	add    $0x10,%esp
      return 0;
80102534:	b8 00 00 00 00       	mov    $0x0,%eax
80102539:	e9 a7 00 00 00       	jmp    801025e5 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010253e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102542:	74 20                	je     80102564 <namex+0xa0>
80102544:	8b 45 08             	mov    0x8(%ebp),%eax
80102547:	0f b6 00             	movzbl (%eax),%eax
8010254a:	84 c0                	test   %al,%al
8010254c:	75 16                	jne    80102564 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010254e:	83 ec 0c             	sub    $0xc,%esp
80102551:	ff 75 f4             	pushl  -0xc(%ebp)
80102554:	e8 3a f6 ff ff       	call   80101b93 <iunlock>
80102559:	83 c4 10             	add    $0x10,%esp
      return ip;
8010255c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010255f:	e9 81 00 00 00       	jmp    801025e5 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102564:	83 ec 04             	sub    $0x4,%esp
80102567:	6a 00                	push   $0x0
80102569:	ff 75 10             	pushl  0x10(%ebp)
8010256c:	ff 75 f4             	pushl  -0xc(%ebp)
8010256f:	e8 12 fd ff ff       	call   80102286 <dirlookup>
80102574:	83 c4 10             	add    $0x10,%esp
80102577:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010257a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010257e:	75 15                	jne    80102595 <namex+0xd1>
      iunlockput(ip);
80102580:	83 ec 0c             	sub    $0xc,%esp
80102583:	ff 75 f4             	pushl  -0xc(%ebp)
80102586:	e8 2e f7 ff ff       	call   80101cb9 <iunlockput>
8010258b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010258e:	b8 00 00 00 00       	mov    $0x0,%eax
80102593:	eb 50                	jmp    801025e5 <namex+0x121>
    }
    iunlockput(ip);
80102595:	83 ec 0c             	sub    $0xc,%esp
80102598:	ff 75 f4             	pushl  -0xc(%ebp)
8010259b:	e8 19 f7 ff ff       	call   80101cb9 <iunlockput>
801025a0:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025a9:	83 ec 08             	sub    $0x8,%esp
801025ac:	ff 75 10             	pushl  0x10(%ebp)
801025af:	ff 75 08             	pushl  0x8(%ebp)
801025b2:	e8 69 fe ff ff       	call   80102420 <skipelem>
801025b7:	83 c4 10             	add    $0x10,%esp
801025ba:	89 45 08             	mov    %eax,0x8(%ebp)
801025bd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025c1:	0f 85 44 ff ff ff    	jne    8010250b <namex+0x47>
  }
  if(nameiparent){
801025c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025cb:	74 15                	je     801025e2 <namex+0x11e>
    iput(ip);
801025cd:	83 ec 0c             	sub    $0xc,%esp
801025d0:	ff 75 f4             	pushl  -0xc(%ebp)
801025d3:	e8 0d f6 ff ff       	call   80101be5 <iput>
801025d8:	83 c4 10             	add    $0x10,%esp
    return 0;
801025db:	b8 00 00 00 00       	mov    $0x0,%eax
801025e0:	eb 03                	jmp    801025e5 <namex+0x121>
  }
  return ip;
801025e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025e5:	c9                   	leave  
801025e6:	c3                   	ret    

801025e7 <namei>:

struct inode*
namei(char *path)
{
801025e7:	f3 0f 1e fb          	endbr32 
801025eb:	55                   	push   %ebp
801025ec:	89 e5                	mov    %esp,%ebp
801025ee:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025f1:	83 ec 04             	sub    $0x4,%esp
801025f4:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025f7:	50                   	push   %eax
801025f8:	6a 00                	push   $0x0
801025fa:	ff 75 08             	pushl  0x8(%ebp)
801025fd:	e8 c2 fe ff ff       	call   801024c4 <namex>
80102602:	83 c4 10             	add    $0x10,%esp
}
80102605:	c9                   	leave  
80102606:	c3                   	ret    

80102607 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102607:	f3 0f 1e fb          	endbr32 
8010260b:	55                   	push   %ebp
8010260c:	89 e5                	mov    %esp,%ebp
8010260e:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102611:	83 ec 04             	sub    $0x4,%esp
80102614:	ff 75 0c             	pushl  0xc(%ebp)
80102617:	6a 01                	push   $0x1
80102619:	ff 75 08             	pushl  0x8(%ebp)
8010261c:	e8 a3 fe ff ff       	call   801024c4 <namex>
80102621:	83 c4 10             	add    $0x10,%esp
}
80102624:	c9                   	leave  
80102625:	c3                   	ret    

80102626 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102626:	f3 0f 1e fb          	endbr32 
8010262a:	55                   	push   %ebp
8010262b:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010262d:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102632:	8b 55 08             	mov    0x8(%ebp),%edx
80102635:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102637:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010263c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010263f:	5d                   	pop    %ebp
80102640:	c3                   	ret    

80102641 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102641:	f3 0f 1e fb          	endbr32 
80102645:	55                   	push   %ebp
80102646:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102648:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010264d:	8b 55 08             	mov    0x8(%ebp),%edx
80102650:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102652:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102657:	8b 55 0c             	mov    0xc(%ebp),%edx
8010265a:	89 50 10             	mov    %edx,0x10(%eax)
}
8010265d:	90                   	nop
8010265e:	5d                   	pop    %ebp
8010265f:	c3                   	ret    

80102660 <ioapicinit>:

void
ioapicinit(void)
{
80102660:	f3 0f 1e fb          	endbr32 
80102664:	55                   	push   %ebp
80102665:	89 e5                	mov    %esp,%ebp
80102667:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010266a:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
80102671:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102674:	6a 01                	push   $0x1
80102676:	e8 ab ff ff ff       	call   80102626 <ioapicread>
8010267b:	83 c4 04             	add    $0x4,%esp
8010267e:	c1 e8 10             	shr    $0x10,%eax
80102681:	25 ff 00 00 00       	and    $0xff,%eax
80102686:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102689:	6a 00                	push   $0x0
8010268b:	e8 96 ff ff ff       	call   80102626 <ioapicread>
80102690:	83 c4 04             	add    $0x4,%esp
80102693:	c1 e8 18             	shr    $0x18,%eax
80102696:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102699:	0f b6 05 a0 7e 19 80 	movzbl 0x80197ea0,%eax
801026a0:	0f b6 c0             	movzbl %al,%eax
801026a3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801026a6:	74 10                	je     801026b8 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801026a8:	83 ec 0c             	sub    $0xc,%esp
801026ab:	68 d4 a8 10 80       	push   $0x8010a8d4
801026b0:	e8 57 dd ff ff       	call   8010040c <cprintf>
801026b5:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801026b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026bf:	eb 3f                	jmp    80102700 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801026c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c4:	83 c0 20             	add    $0x20,%eax
801026c7:	0d 00 00 01 00       	or     $0x10000,%eax
801026cc:	89 c2                	mov    %eax,%edx
801026ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d1:	83 c0 08             	add    $0x8,%eax
801026d4:	01 c0                	add    %eax,%eax
801026d6:	83 ec 08             	sub    $0x8,%esp
801026d9:	52                   	push   %edx
801026da:	50                   	push   %eax
801026db:	e8 61 ff ff ff       	call   80102641 <ioapicwrite>
801026e0:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801026e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e6:	83 c0 08             	add    $0x8,%eax
801026e9:	01 c0                	add    %eax,%eax
801026eb:	83 c0 01             	add    $0x1,%eax
801026ee:	83 ec 08             	sub    $0x8,%esp
801026f1:	6a 00                	push   $0x0
801026f3:	50                   	push   %eax
801026f4:	e8 48 ff ff ff       	call   80102641 <ioapicwrite>
801026f9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
801026fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102703:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102706:	7e b9                	jle    801026c1 <ioapicinit+0x61>
  }
}
80102708:	90                   	nop
80102709:	90                   	nop
8010270a:	c9                   	leave  
8010270b:	c3                   	ret    

8010270c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010270c:	f3 0f 1e fb          	endbr32 
80102710:	55                   	push   %ebp
80102711:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102713:	8b 45 08             	mov    0x8(%ebp),%eax
80102716:	83 c0 20             	add    $0x20,%eax
80102719:	89 c2                	mov    %eax,%edx
8010271b:	8b 45 08             	mov    0x8(%ebp),%eax
8010271e:	83 c0 08             	add    $0x8,%eax
80102721:	01 c0                	add    %eax,%eax
80102723:	52                   	push   %edx
80102724:	50                   	push   %eax
80102725:	e8 17 ff ff ff       	call   80102641 <ioapicwrite>
8010272a:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010272d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102730:	c1 e0 18             	shl    $0x18,%eax
80102733:	89 c2                	mov    %eax,%edx
80102735:	8b 45 08             	mov    0x8(%ebp),%eax
80102738:	83 c0 08             	add    $0x8,%eax
8010273b:	01 c0                	add    %eax,%eax
8010273d:	83 c0 01             	add    $0x1,%eax
80102740:	52                   	push   %edx
80102741:	50                   	push   %eax
80102742:	e8 fa fe ff ff       	call   80102641 <ioapicwrite>
80102747:	83 c4 08             	add    $0x8,%esp
}
8010274a:	90                   	nop
8010274b:	c9                   	leave  
8010274c:	c3                   	ret    

8010274d <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010274d:	f3 0f 1e fb          	endbr32 
80102751:	55                   	push   %ebp
80102752:	89 e5                	mov    %esp,%ebp
80102754:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	68 06 a9 10 80       	push   $0x8010a906
8010275f:	68 e0 53 19 80       	push   $0x801953e0
80102764:	e8 fd 23 00 00       	call   80104b66 <initlock>
80102769:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010276c:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
80102773:	00 00 00 
  freerange(vstart, vend);
80102776:	83 ec 08             	sub    $0x8,%esp
80102779:	ff 75 0c             	pushl  0xc(%ebp)
8010277c:	ff 75 08             	pushl  0x8(%ebp)
8010277f:	e8 2e 00 00 00       	call   801027b2 <freerange>
80102784:	83 c4 10             	add    $0x10,%esp
}
80102787:	90                   	nop
80102788:	c9                   	leave  
80102789:	c3                   	ret    

8010278a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010278a:	f3 0f 1e fb          	endbr32 
8010278e:	55                   	push   %ebp
8010278f:	89 e5                	mov    %esp,%ebp
80102791:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102794:	83 ec 08             	sub    $0x8,%esp
80102797:	ff 75 0c             	pushl  0xc(%ebp)
8010279a:	ff 75 08             	pushl  0x8(%ebp)
8010279d:	e8 10 00 00 00       	call   801027b2 <freerange>
801027a2:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801027a5:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
801027ac:	00 00 00 
}
801027af:	90                   	nop
801027b0:	c9                   	leave  
801027b1:	c3                   	ret    

801027b2 <freerange>:

void
freerange(void *vstart, void *vend)
{
801027b2:	f3 0f 1e fb          	endbr32 
801027b6:	55                   	push   %ebp
801027b7:	89 e5                	mov    %esp,%ebp
801027b9:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801027bc:	8b 45 08             	mov    0x8(%ebp),%eax
801027bf:	05 ff 0f 00 00       	add    $0xfff,%eax
801027c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801027c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027cc:	eb 15                	jmp    801027e3 <freerange+0x31>
    kfree(p);
801027ce:	83 ec 0c             	sub    $0xc,%esp
801027d1:	ff 75 f4             	pushl  -0xc(%ebp)
801027d4:	e8 1b 00 00 00       	call   801027f4 <kfree>
801027d9:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801027e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e6:	05 00 10 00 00       	add    $0x1000,%eax
801027eb:	39 45 0c             	cmp    %eax,0xc(%ebp)
801027ee:	73 de                	jae    801027ce <freerange+0x1c>
}
801027f0:	90                   	nop
801027f1:	90                   	nop
801027f2:	c9                   	leave  
801027f3:	c3                   	ret    

801027f4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801027f4:	f3 0f 1e fb          	endbr32 
801027f8:	55                   	push   %ebp
801027f9:	89 e5                	mov    %esp,%ebp
801027fb:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801027fe:	8b 45 08             	mov    0x8(%ebp),%eax
80102801:	25 ff 0f 00 00       	and    $0xfff,%eax
80102806:	85 c0                	test   %eax,%eax
80102808:	75 18                	jne    80102822 <kfree+0x2e>
8010280a:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102811:	72 0f                	jb     80102822 <kfree+0x2e>
80102813:	8b 45 08             	mov    0x8(%ebp),%eax
80102816:	05 00 00 00 80       	add    $0x80000000,%eax
8010281b:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102820:	76 0d                	jbe    8010282f <kfree+0x3b>
    panic("kfree");
80102822:	83 ec 0c             	sub    $0xc,%esp
80102825:	68 0b a9 10 80       	push   $0x8010a90b
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	pushl  0x8(%ebp)
8010283c:	e8 da 25 00 00       	call   80104e1b <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 14 54 19 80       	mov    0x80195414,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 e0 53 19 80       	push   $0x801953e0
80102855:	e8 32 23 00 00       	call   80104b8c <acquire>
8010285a:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010285d:	8b 45 08             	mov    0x8(%ebp),%eax
80102860:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102863:	8b 15 18 54 19 80    	mov    0x80195418,%edx
80102869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010286c:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
8010286e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102871:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
80102876:	a1 14 54 19 80       	mov    0x80195414,%eax
8010287b:	85 c0                	test   %eax,%eax
8010287d:	74 10                	je     8010288f <kfree+0x9b>
    release(&kmem.lock);
8010287f:	83 ec 0c             	sub    $0xc,%esp
80102882:	68 e0 53 19 80       	push   $0x801953e0
80102887:	e8 72 23 00 00       	call   80104bfe <release>
8010288c:	83 c4 10             	add    $0x10,%esp
}
8010288f:	90                   	nop
80102890:	c9                   	leave  
80102891:	c3                   	ret    

80102892 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102892:	f3 0f 1e fb          	endbr32 
80102896:	55                   	push   %ebp
80102897:	89 e5                	mov    %esp,%ebp
80102899:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010289c:	a1 14 54 19 80       	mov    0x80195414,%eax
801028a1:	85 c0                	test   %eax,%eax
801028a3:	74 10                	je     801028b5 <kalloc+0x23>
    acquire(&kmem.lock);
801028a5:	83 ec 0c             	sub    $0xc,%esp
801028a8:	68 e0 53 19 80       	push   $0x801953e0
801028ad:	e8 da 22 00 00       	call   80104b8c <acquire>
801028b2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801028b5:	a1 18 54 19 80       	mov    0x80195418,%eax
801028ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801028bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028c1:	74 0a                	je     801028cd <kalloc+0x3b>
    kmem.freelist = r->next;
801028c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c6:	8b 00                	mov    (%eax),%eax
801028c8:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028cd:	a1 14 54 19 80       	mov    0x80195414,%eax
801028d2:	85 c0                	test   %eax,%eax
801028d4:	74 10                	je     801028e6 <kalloc+0x54>
    release(&kmem.lock);
801028d6:	83 ec 0c             	sub    $0xc,%esp
801028d9:	68 e0 53 19 80       	push   $0x801953e0
801028de:	e8 1b 23 00 00       	call   80104bfe <release>
801028e3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801028e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801028e9:	c9                   	leave  
801028ea:	c3                   	ret    

801028eb <inb>:
{
801028eb:	55                   	push   %ebp
801028ec:	89 e5                	mov    %esp,%ebp
801028ee:	83 ec 14             	sub    $0x14,%esp
801028f1:	8b 45 08             	mov    0x8(%ebp),%eax
801028f4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028f8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801028fc:	89 c2                	mov    %eax,%edx
801028fe:	ec                   	in     (%dx),%al
801028ff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102902:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102906:	c9                   	leave  
80102907:	c3                   	ret    

80102908 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102908:	f3 0f 1e fb          	endbr32 
8010290c:	55                   	push   %ebp
8010290d:	89 e5                	mov    %esp,%ebp
8010290f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102912:	6a 64                	push   $0x64
80102914:	e8 d2 ff ff ff       	call   801028eb <inb>
80102919:	83 c4 04             	add    $0x4,%esp
8010291c:	0f b6 c0             	movzbl %al,%eax
8010291f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102925:	83 e0 01             	and    $0x1,%eax
80102928:	85 c0                	test   %eax,%eax
8010292a:	75 0a                	jne    80102936 <kbdgetc+0x2e>
    return -1;
8010292c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102931:	e9 23 01 00 00       	jmp    80102a59 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102936:	6a 60                	push   $0x60
80102938:	e8 ae ff ff ff       	call   801028eb <inb>
8010293d:	83 c4 04             	add    $0x4,%esp
80102940:	0f b6 c0             	movzbl %al,%eax
80102943:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102946:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010294d:	75 17                	jne    80102966 <kbdgetc+0x5e>
    shift |= E0ESC;
8010294f:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102954:	83 c8 40             	or     $0x40,%eax
80102957:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
8010295c:	b8 00 00 00 00       	mov    $0x0,%eax
80102961:	e9 f3 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(data & 0x80){
80102966:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102969:	25 80 00 00 00       	and    $0x80,%eax
8010296e:	85 c0                	test   %eax,%eax
80102970:	74 45                	je     801029b7 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102972:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102977:	83 e0 40             	and    $0x40,%eax
8010297a:	85 c0                	test   %eax,%eax
8010297c:	75 08                	jne    80102986 <kbdgetc+0x7e>
8010297e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102981:	83 e0 7f             	and    $0x7f,%eax
80102984:	eb 03                	jmp    80102989 <kbdgetc+0x81>
80102986:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102989:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010298c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010298f:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102994:	0f b6 00             	movzbl (%eax),%eax
80102997:	83 c8 40             	or     $0x40,%eax
8010299a:	0f b6 c0             	movzbl %al,%eax
8010299d:	f7 d0                	not    %eax
8010299f:	89 c2                	mov    %eax,%edx
801029a1:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029a6:	21 d0                	and    %edx,%eax
801029a8:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
801029ad:	b8 00 00 00 00       	mov    $0x0,%eax
801029b2:	e9 a2 00 00 00       	jmp    80102a59 <kbdgetc+0x151>
  } else if(shift & E0ESC){
801029b7:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029bc:	83 e0 40             	and    $0x40,%eax
801029bf:	85 c0                	test   %eax,%eax
801029c1:	74 14                	je     801029d7 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801029c3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801029ca:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029cf:	83 e0 bf             	and    $0xffffffbf,%eax
801029d2:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
801029d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029da:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029df:	0f b6 00             	movzbl (%eax),%eax
801029e2:	0f b6 d0             	movzbl %al,%edx
801029e5:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029ea:	09 d0                	or     %edx,%eax
801029ec:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
801029f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029f4:	05 20 d1 10 80       	add    $0x8010d120,%eax
801029f9:	0f b6 00             	movzbl (%eax),%eax
801029fc:	0f b6 d0             	movzbl %al,%edx
801029ff:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a04:	31 d0                	xor    %edx,%eax
80102a06:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
80102a0b:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a10:	83 e0 03             	and    $0x3,%eax
80102a13:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a1d:	01 d0                	add    %edx,%eax
80102a1f:	0f b6 00             	movzbl (%eax),%eax
80102a22:	0f b6 c0             	movzbl %al,%eax
80102a25:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a28:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a2d:	83 e0 08             	and    $0x8,%eax
80102a30:	85 c0                	test   %eax,%eax
80102a32:	74 22                	je     80102a56 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102a34:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102a38:	76 0c                	jbe    80102a46 <kbdgetc+0x13e>
80102a3a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102a3e:	77 06                	ja     80102a46 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102a40:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102a44:	eb 10                	jmp    80102a56 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102a46:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102a4a:	76 0a                	jbe    80102a56 <kbdgetc+0x14e>
80102a4c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102a50:	77 04                	ja     80102a56 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102a52:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102a56:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102a59:	c9                   	leave  
80102a5a:	c3                   	ret    

80102a5b <kbdintr>:

void
kbdintr(void)
{
80102a5b:	f3 0f 1e fb          	endbr32 
80102a5f:	55                   	push   %ebp
80102a60:	89 e5                	mov    %esp,%ebp
80102a62:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	68 08 29 10 80       	push   $0x80102908
80102a6d:	e8 8e dd ff ff       	call   80100800 <consoleintr>
80102a72:	83 c4 10             	add    $0x10,%esp
}
80102a75:	90                   	nop
80102a76:	c9                   	leave  
80102a77:	c3                   	ret    

80102a78 <inb>:
{
80102a78:	55                   	push   %ebp
80102a79:	89 e5                	mov    %esp,%ebp
80102a7b:	83 ec 14             	sub    $0x14,%esp
80102a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a81:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a85:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102a89:	89 c2                	mov    %eax,%edx
80102a8b:	ec                   	in     (%dx),%al
80102a8c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102a8f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102a93:	c9                   	leave  
80102a94:	c3                   	ret    

80102a95 <outb>:
{
80102a95:	55                   	push   %ebp
80102a96:	89 e5                	mov    %esp,%ebp
80102a98:	83 ec 08             	sub    $0x8,%esp
80102a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102aa1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102aa5:	89 d0                	mov    %edx,%eax
80102aa7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aaa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102aae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ab2:	ee                   	out    %al,(%dx)
}
80102ab3:	90                   	nop
80102ab4:	c9                   	leave  
80102ab5:	c3                   	ret    

80102ab6 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ab6:	f3 0f 1e fb          	endbr32 
80102aba:	55                   	push   %ebp
80102abb:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102abd:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ac2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac5:	c1 e2 02             	shl    $0x2,%edx
80102ac8:	01 c2                	add    %eax,%edx
80102aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80102acd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102acf:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ad4:	83 c0 20             	add    $0x20,%eax
80102ad7:	8b 00                	mov    (%eax),%eax
}
80102ad9:	90                   	nop
80102ada:	5d                   	pop    %ebp
80102adb:	c3                   	ret    

80102adc <lapicinit>:

void
lapicinit(void)
{
80102adc:	f3 0f 1e fb          	endbr32 
80102ae0:	55                   	push   %ebp
80102ae1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ae3:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ae8:	85 c0                	test   %eax,%eax
80102aea:	0f 84 0c 01 00 00    	je     80102bfc <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102af0:	68 3f 01 00 00       	push   $0x13f
80102af5:	6a 3c                	push   $0x3c
80102af7:	e8 ba ff ff ff       	call   80102ab6 <lapicw>
80102afc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102aff:	6a 0b                	push   $0xb
80102b01:	68 f8 00 00 00       	push   $0xf8
80102b06:	e8 ab ff ff ff       	call   80102ab6 <lapicw>
80102b0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b0e:	68 20 00 02 00       	push   $0x20020
80102b13:	68 c8 00 00 00       	push   $0xc8
80102b18:	e8 99 ff ff ff       	call   80102ab6 <lapicw>
80102b1d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b20:	68 80 96 98 00       	push   $0x989680
80102b25:	68 e0 00 00 00       	push   $0xe0
80102b2a:	e8 87 ff ff ff       	call   80102ab6 <lapicw>
80102b2f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b32:	68 00 00 01 00       	push   $0x10000
80102b37:	68 d4 00 00 00       	push   $0xd4
80102b3c:	e8 75 ff ff ff       	call   80102ab6 <lapicw>
80102b41:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102b44:	68 00 00 01 00       	push   $0x10000
80102b49:	68 d8 00 00 00       	push   $0xd8
80102b4e:	e8 63 ff ff ff       	call   80102ab6 <lapicw>
80102b53:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102b56:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b5b:	83 c0 30             	add    $0x30,%eax
80102b5e:	8b 00                	mov    (%eax),%eax
80102b60:	c1 e8 10             	shr    $0x10,%eax
80102b63:	25 fc 00 00 00       	and    $0xfc,%eax
80102b68:	85 c0                	test   %eax,%eax
80102b6a:	74 12                	je     80102b7e <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102b6c:	68 00 00 01 00       	push   $0x10000
80102b71:	68 d0 00 00 00       	push   $0xd0
80102b76:	e8 3b ff ff ff       	call   80102ab6 <lapicw>
80102b7b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102b7e:	6a 33                	push   $0x33
80102b80:	68 dc 00 00 00       	push   $0xdc
80102b85:	e8 2c ff ff ff       	call   80102ab6 <lapicw>
80102b8a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102b8d:	6a 00                	push   $0x0
80102b8f:	68 a0 00 00 00       	push   $0xa0
80102b94:	e8 1d ff ff ff       	call   80102ab6 <lapicw>
80102b99:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102b9c:	6a 00                	push   $0x0
80102b9e:	68 a0 00 00 00       	push   $0xa0
80102ba3:	e8 0e ff ff ff       	call   80102ab6 <lapicw>
80102ba8:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102bab:	6a 00                	push   $0x0
80102bad:	6a 2c                	push   $0x2c
80102baf:	e8 02 ff ff ff       	call   80102ab6 <lapicw>
80102bb4:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102bb7:	6a 00                	push   $0x0
80102bb9:	68 c4 00 00 00       	push   $0xc4
80102bbe:	e8 f3 fe ff ff       	call   80102ab6 <lapicw>
80102bc3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102bc6:	68 00 85 08 00       	push   $0x88500
80102bcb:	68 c0 00 00 00       	push   $0xc0
80102bd0:	e8 e1 fe ff ff       	call   80102ab6 <lapicw>
80102bd5:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102bd8:	90                   	nop
80102bd9:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bde:	05 00 03 00 00       	add    $0x300,%eax
80102be3:	8b 00                	mov    (%eax),%eax
80102be5:	25 00 10 00 00       	and    $0x1000,%eax
80102bea:	85 c0                	test   %eax,%eax
80102bec:	75 eb                	jne    80102bd9 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102bee:	6a 00                	push   $0x0
80102bf0:	6a 20                	push   $0x20
80102bf2:	e8 bf fe ff ff       	call   80102ab6 <lapicw>
80102bf7:	83 c4 08             	add    $0x8,%esp
80102bfa:	eb 01                	jmp    80102bfd <lapicinit+0x121>
    return;
80102bfc:	90                   	nop
}
80102bfd:	c9                   	leave  
80102bfe:	c3                   	ret    

80102bff <lapicid>:

int
lapicid(void)
{
80102bff:	f3 0f 1e fb          	endbr32 
80102c03:	55                   	push   %ebp
80102c04:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102c06:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c0b:	85 c0                	test   %eax,%eax
80102c0d:	75 07                	jne    80102c16 <lapicid+0x17>
    return 0;
80102c0f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c14:	eb 0d                	jmp    80102c23 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c16:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c1b:	83 c0 20             	add    $0x20,%eax
80102c1e:	8b 00                	mov    (%eax),%eax
80102c20:	c1 e8 18             	shr    $0x18,%eax
}
80102c23:	5d                   	pop    %ebp
80102c24:	c3                   	ret    

80102c25 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c25:	f3 0f 1e fb          	endbr32 
80102c29:	55                   	push   %ebp
80102c2a:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c2c:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c31:	85 c0                	test   %eax,%eax
80102c33:	74 0c                	je     80102c41 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102c35:	6a 00                	push   $0x0
80102c37:	6a 2c                	push   $0x2c
80102c39:	e8 78 fe ff ff       	call   80102ab6 <lapicw>
80102c3e:	83 c4 08             	add    $0x8,%esp
}
80102c41:	90                   	nop
80102c42:	c9                   	leave  
80102c43:	c3                   	ret    

80102c44 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102c44:	f3 0f 1e fb          	endbr32 
80102c48:	55                   	push   %ebp
80102c49:	89 e5                	mov    %esp,%ebp
}
80102c4b:	90                   	nop
80102c4c:	5d                   	pop    %ebp
80102c4d:	c3                   	ret    

80102c4e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102c4e:	f3 0f 1e fb          	endbr32 
80102c52:	55                   	push   %ebp
80102c53:	89 e5                	mov    %esp,%ebp
80102c55:	83 ec 14             	sub    $0x14,%esp
80102c58:	8b 45 08             	mov    0x8(%ebp),%eax
80102c5b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102c5e:	6a 0f                	push   $0xf
80102c60:	6a 70                	push   $0x70
80102c62:	e8 2e fe ff ff       	call   80102a95 <outb>
80102c67:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102c6a:	6a 0a                	push   $0xa
80102c6c:	6a 71                	push   $0x71
80102c6e:	e8 22 fe ff ff       	call   80102a95 <outb>
80102c73:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102c76:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102c7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c80:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102c85:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c88:	c1 e8 04             	shr    $0x4,%eax
80102c8b:	89 c2                	mov    %eax,%edx
80102c8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c90:	83 c0 02             	add    $0x2,%eax
80102c93:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102c96:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102c9a:	c1 e0 18             	shl    $0x18,%eax
80102c9d:	50                   	push   %eax
80102c9e:	68 c4 00 00 00       	push   $0xc4
80102ca3:	e8 0e fe ff ff       	call   80102ab6 <lapicw>
80102ca8:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102cab:	68 00 c5 00 00       	push   $0xc500
80102cb0:	68 c0 00 00 00       	push   $0xc0
80102cb5:	e8 fc fd ff ff       	call   80102ab6 <lapicw>
80102cba:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102cbd:	68 c8 00 00 00       	push   $0xc8
80102cc2:	e8 7d ff ff ff       	call   80102c44 <microdelay>
80102cc7:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102cca:	68 00 85 00 00       	push   $0x8500
80102ccf:	68 c0 00 00 00       	push   $0xc0
80102cd4:	e8 dd fd ff ff       	call   80102ab6 <lapicw>
80102cd9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102cdc:	6a 64                	push   $0x64
80102cde:	e8 61 ff ff ff       	call   80102c44 <microdelay>
80102ce3:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ce6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102ced:	eb 3d                	jmp    80102d2c <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102cef:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102cf3:	c1 e0 18             	shl    $0x18,%eax
80102cf6:	50                   	push   %eax
80102cf7:	68 c4 00 00 00       	push   $0xc4
80102cfc:	e8 b5 fd ff ff       	call   80102ab6 <lapicw>
80102d01:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d07:	c1 e8 0c             	shr    $0xc,%eax
80102d0a:	80 cc 06             	or     $0x6,%ah
80102d0d:	50                   	push   %eax
80102d0e:	68 c0 00 00 00       	push   $0xc0
80102d13:	e8 9e fd ff ff       	call   80102ab6 <lapicw>
80102d18:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d1b:	68 c8 00 00 00       	push   $0xc8
80102d20:	e8 1f ff ff ff       	call   80102c44 <microdelay>
80102d25:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d28:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d2c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d30:	7e bd                	jle    80102cef <lapicstartap+0xa1>
  }
}
80102d32:	90                   	nop
80102d33:	90                   	nop
80102d34:	c9                   	leave  
80102d35:	c3                   	ret    

80102d36 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102d36:	f3 0f 1e fb          	endbr32 
80102d3a:	55                   	push   %ebp
80102d3b:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d40:	0f b6 c0             	movzbl %al,%eax
80102d43:	50                   	push   %eax
80102d44:	6a 70                	push   $0x70
80102d46:	e8 4a fd ff ff       	call   80102a95 <outb>
80102d4b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d4e:	68 c8 00 00 00       	push   $0xc8
80102d53:	e8 ec fe ff ff       	call   80102c44 <microdelay>
80102d58:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102d5b:	6a 71                	push   $0x71
80102d5d:	e8 16 fd ff ff       	call   80102a78 <inb>
80102d62:	83 c4 04             	add    $0x4,%esp
80102d65:	0f b6 c0             	movzbl %al,%eax
}
80102d68:	c9                   	leave  
80102d69:	c3                   	ret    

80102d6a <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102d6a:	f3 0f 1e fb          	endbr32 
80102d6e:	55                   	push   %ebp
80102d6f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102d71:	6a 00                	push   $0x0
80102d73:	e8 be ff ff ff       	call   80102d36 <cmos_read>
80102d78:	83 c4 04             	add    $0x4,%esp
80102d7b:	8b 55 08             	mov    0x8(%ebp),%edx
80102d7e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102d80:	6a 02                	push   $0x2
80102d82:	e8 af ff ff ff       	call   80102d36 <cmos_read>
80102d87:	83 c4 04             	add    $0x4,%esp
80102d8a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102d90:	6a 04                	push   $0x4
80102d92:	e8 9f ff ff ff       	call   80102d36 <cmos_read>
80102d97:	83 c4 04             	add    $0x4,%esp
80102d9a:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102da0:	6a 07                	push   $0x7
80102da2:	e8 8f ff ff ff       	call   80102d36 <cmos_read>
80102da7:	83 c4 04             	add    $0x4,%esp
80102daa:	8b 55 08             	mov    0x8(%ebp),%edx
80102dad:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102db0:	6a 08                	push   $0x8
80102db2:	e8 7f ff ff ff       	call   80102d36 <cmos_read>
80102db7:	83 c4 04             	add    $0x4,%esp
80102dba:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbd:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102dc0:	6a 09                	push   $0x9
80102dc2:	e8 6f ff ff ff       	call   80102d36 <cmos_read>
80102dc7:	83 c4 04             	add    $0x4,%esp
80102dca:	8b 55 08             	mov    0x8(%ebp),%edx
80102dcd:	89 42 14             	mov    %eax,0x14(%edx)
}
80102dd0:	90                   	nop
80102dd1:	c9                   	leave  
80102dd2:	c3                   	ret    

80102dd3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102dd3:	f3 0f 1e fb          	endbr32 
80102dd7:	55                   	push   %ebp
80102dd8:	89 e5                	mov    %esp,%ebp
80102dda:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102ddd:	6a 0b                	push   $0xb
80102ddf:	e8 52 ff ff ff       	call   80102d36 <cmos_read>
80102de4:	83 c4 04             	add    $0x4,%esp
80102de7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ded:	83 e0 04             	and    $0x4,%eax
80102df0:	85 c0                	test   %eax,%eax
80102df2:	0f 94 c0             	sete   %al
80102df5:	0f b6 c0             	movzbl %al,%eax
80102df8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102dfb:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102dfe:	50                   	push   %eax
80102dff:	e8 66 ff ff ff       	call   80102d6a <fill_rtcdate>
80102e04:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102e07:	6a 0a                	push   $0xa
80102e09:	e8 28 ff ff ff       	call   80102d36 <cmos_read>
80102e0e:	83 c4 04             	add    $0x4,%esp
80102e11:	25 80 00 00 00       	and    $0x80,%eax
80102e16:	85 c0                	test   %eax,%eax
80102e18:	75 27                	jne    80102e41 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e1a:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e1d:	50                   	push   %eax
80102e1e:	e8 47 ff ff ff       	call   80102d6a <fill_rtcdate>
80102e23:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e26:	83 ec 04             	sub    $0x4,%esp
80102e29:	6a 18                	push   $0x18
80102e2b:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e2e:	50                   	push   %eax
80102e2f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e32:	50                   	push   %eax
80102e33:	e8 4e 20 00 00       	call   80104e86 <memcmp>
80102e38:	83 c4 10             	add    $0x10,%esp
80102e3b:	85 c0                	test   %eax,%eax
80102e3d:	74 05                	je     80102e44 <cmostime+0x71>
80102e3f:	eb ba                	jmp    80102dfb <cmostime+0x28>
        continue;
80102e41:	90                   	nop
    fill_rtcdate(&t1);
80102e42:	eb b7                	jmp    80102dfb <cmostime+0x28>
      break;
80102e44:	90                   	nop
  }

  // convert
  if(bcd) {
80102e45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102e49:	0f 84 b4 00 00 00    	je     80102f03 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102e4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e52:	c1 e8 04             	shr    $0x4,%eax
80102e55:	89 c2                	mov    %eax,%edx
80102e57:	89 d0                	mov    %edx,%eax
80102e59:	c1 e0 02             	shl    $0x2,%eax
80102e5c:	01 d0                	add    %edx,%eax
80102e5e:	01 c0                	add    %eax,%eax
80102e60:	89 c2                	mov    %eax,%edx
80102e62:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e65:	83 e0 0f             	and    $0xf,%eax
80102e68:	01 d0                	add    %edx,%eax
80102e6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102e6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e70:	c1 e8 04             	shr    $0x4,%eax
80102e73:	89 c2                	mov    %eax,%edx
80102e75:	89 d0                	mov    %edx,%eax
80102e77:	c1 e0 02             	shl    $0x2,%eax
80102e7a:	01 d0                	add    %edx,%eax
80102e7c:	01 c0                	add    %eax,%eax
80102e7e:	89 c2                	mov    %eax,%edx
80102e80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e83:	83 e0 0f             	and    $0xf,%eax
80102e86:	01 d0                	add    %edx,%eax
80102e88:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102e8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102e8e:	c1 e8 04             	shr    $0x4,%eax
80102e91:	89 c2                	mov    %eax,%edx
80102e93:	89 d0                	mov    %edx,%eax
80102e95:	c1 e0 02             	shl    $0x2,%eax
80102e98:	01 d0                	add    %edx,%eax
80102e9a:	01 c0                	add    %eax,%eax
80102e9c:	89 c2                	mov    %eax,%edx
80102e9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102ea1:	83 e0 0f             	and    $0xf,%eax
80102ea4:	01 d0                	add    %edx,%eax
80102ea6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102eac:	c1 e8 04             	shr    $0x4,%eax
80102eaf:	89 c2                	mov    %eax,%edx
80102eb1:	89 d0                	mov    %edx,%eax
80102eb3:	c1 e0 02             	shl    $0x2,%eax
80102eb6:	01 d0                	add    %edx,%eax
80102eb8:	01 c0                	add    %eax,%eax
80102eba:	89 c2                	mov    %eax,%edx
80102ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102ebf:	83 e0 0f             	and    $0xf,%eax
80102ec2:	01 d0                	add    %edx,%eax
80102ec4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102eca:	c1 e8 04             	shr    $0x4,%eax
80102ecd:	89 c2                	mov    %eax,%edx
80102ecf:	89 d0                	mov    %edx,%eax
80102ed1:	c1 e0 02             	shl    $0x2,%eax
80102ed4:	01 d0                	add    %edx,%eax
80102ed6:	01 c0                	add    %eax,%eax
80102ed8:	89 c2                	mov    %eax,%edx
80102eda:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102edd:	83 e0 0f             	and    $0xf,%eax
80102ee0:	01 d0                	add    %edx,%eax
80102ee2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ee8:	c1 e8 04             	shr    $0x4,%eax
80102eeb:	89 c2                	mov    %eax,%edx
80102eed:	89 d0                	mov    %edx,%eax
80102eef:	c1 e0 02             	shl    $0x2,%eax
80102ef2:	01 d0                	add    %edx,%eax
80102ef4:	01 c0                	add    %eax,%eax
80102ef6:	89 c2                	mov    %eax,%edx
80102ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102efb:	83 e0 0f             	and    $0xf,%eax
80102efe:	01 d0                	add    %edx,%eax
80102f00:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102f03:	8b 45 08             	mov    0x8(%ebp),%eax
80102f06:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102f09:	89 10                	mov    %edx,(%eax)
80102f0b:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f0e:	89 50 04             	mov    %edx,0x4(%eax)
80102f11:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f14:	89 50 08             	mov    %edx,0x8(%eax)
80102f17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f1a:	89 50 0c             	mov    %edx,0xc(%eax)
80102f1d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f20:	89 50 10             	mov    %edx,0x10(%eax)
80102f23:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f26:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f29:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2c:	8b 40 14             	mov    0x14(%eax),%eax
80102f2f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102f35:	8b 45 08             	mov    0x8(%ebp),%eax
80102f38:	89 50 14             	mov    %edx,0x14(%eax)
}
80102f3b:	90                   	nop
80102f3c:	c9                   	leave  
80102f3d:	c3                   	ret    

80102f3e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102f3e:	f3 0f 1e fb          	endbr32 
80102f42:	55                   	push   %ebp
80102f43:	89 e5                	mov    %esp,%ebp
80102f45:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102f48:	83 ec 08             	sub    $0x8,%esp
80102f4b:	68 11 a9 10 80       	push   $0x8010a911
80102f50:	68 20 54 19 80       	push   $0x80195420
80102f55:	e8 0c 1c 00 00       	call   80104b66 <initlock>
80102f5a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102f5d:	83 ec 08             	sub    $0x8,%esp
80102f60:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102f63:	50                   	push   %eax
80102f64:	ff 75 08             	pushl  0x8(%ebp)
80102f67:	e8 c0 e4 ff ff       	call   8010142c <readsb>
80102f6c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f72:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102f77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f7a:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f82:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102f87:	e8 bf 01 00 00       	call   8010314b <recover_from_log>
}
80102f8c:	90                   	nop
80102f8d:	c9                   	leave  
80102f8e:	c3                   	ret    

80102f8f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102f8f:	f3 0f 1e fb          	endbr32 
80102f93:	55                   	push   %ebp
80102f94:	89 e5                	mov    %esp,%ebp
80102f96:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102f99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fa0:	e9 95 00 00 00       	jmp    8010303a <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102fa5:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80102fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fae:	01 d0                	add    %edx,%eax
80102fb0:	83 c0 01             	add    $0x1,%eax
80102fb3:	89 c2                	mov    %eax,%edx
80102fb5:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fba:	83 ec 08             	sub    $0x8,%esp
80102fbd:	52                   	push   %edx
80102fbe:	50                   	push   %eax
80102fbf:	e8 45 d2 ff ff       	call   80100209 <bread>
80102fc4:	83 c4 10             	add    $0x10,%esp
80102fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fcd:	83 c0 10             	add    $0x10,%eax
80102fd0:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80102fd7:	89 c2                	mov    %eax,%edx
80102fd9:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fde:	83 ec 08             	sub    $0x8,%esp
80102fe1:	52                   	push   %edx
80102fe2:	50                   	push   %eax
80102fe3:	e8 21 d2 ff ff       	call   80100209 <bread>
80102fe8:	83 c4 10             	add    $0x10,%esp
80102feb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102ff1:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ff7:	83 c0 5c             	add    $0x5c,%eax
80102ffa:	83 ec 04             	sub    $0x4,%esp
80102ffd:	68 00 02 00 00       	push   $0x200
80103002:	52                   	push   %edx
80103003:	50                   	push   %eax
80103004:	e8 d9 1e 00 00       	call   80104ee2 <memmove>
80103009:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010300c:	83 ec 0c             	sub    $0xc,%esp
8010300f:	ff 75 ec             	pushl  -0x14(%ebp)
80103012:	e8 2f d2 ff ff       	call   80100246 <bwrite>
80103017:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010301a:	83 ec 0c             	sub    $0xc,%esp
8010301d:	ff 75 f0             	pushl  -0x10(%ebp)
80103020:	e8 6e d2 ff ff       	call   80100293 <brelse>
80103025:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103028:	83 ec 0c             	sub    $0xc,%esp
8010302b:	ff 75 ec             	pushl  -0x14(%ebp)
8010302e:	e8 60 d2 ff ff       	call   80100293 <brelse>
80103033:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103036:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010303a:	a1 68 54 19 80       	mov    0x80195468,%eax
8010303f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103042:	0f 8c 5d ff ff ff    	jl     80102fa5 <install_trans+0x16>
  }
}
80103048:	90                   	nop
80103049:	90                   	nop
8010304a:	c9                   	leave  
8010304b:	c3                   	ret    

8010304c <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010304c:	f3 0f 1e fb          	endbr32 
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103056:	a1 54 54 19 80       	mov    0x80195454,%eax
8010305b:	89 c2                	mov    %eax,%edx
8010305d:	a1 64 54 19 80       	mov    0x80195464,%eax
80103062:	83 ec 08             	sub    $0x8,%esp
80103065:	52                   	push   %edx
80103066:	50                   	push   %eax
80103067:	e8 9d d1 ff ff       	call   80100209 <bread>
8010306c:	83 c4 10             	add    $0x10,%esp
8010306f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103075:	83 c0 5c             	add    $0x5c,%eax
80103078:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010307b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010307e:	8b 00                	mov    (%eax),%eax
80103080:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
80103085:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010308c:	eb 1b                	jmp    801030a9 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010308e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103094:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010309b:	83 c2 10             	add    $0x10,%edx
8010309e:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801030a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801030a9:	a1 68 54 19 80       	mov    0x80195468,%eax
801030ae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030b1:	7c db                	jl     8010308e <read_head+0x42>
  }
  brelse(buf);
801030b3:	83 ec 0c             	sub    $0xc,%esp
801030b6:	ff 75 f0             	pushl  -0x10(%ebp)
801030b9:	e8 d5 d1 ff ff       	call   80100293 <brelse>
801030be:	83 c4 10             	add    $0x10,%esp
}
801030c1:	90                   	nop
801030c2:	c9                   	leave  
801030c3:	c3                   	ret    

801030c4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801030c4:	f3 0f 1e fb          	endbr32 
801030c8:	55                   	push   %ebp
801030c9:	89 e5                	mov    %esp,%ebp
801030cb:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030ce:	a1 54 54 19 80       	mov    0x80195454,%eax
801030d3:	89 c2                	mov    %eax,%edx
801030d5:	a1 64 54 19 80       	mov    0x80195464,%eax
801030da:	83 ec 08             	sub    $0x8,%esp
801030dd:	52                   	push   %edx
801030de:	50                   	push   %eax
801030df:	e8 25 d1 ff ff       	call   80100209 <bread>
801030e4:	83 c4 10             	add    $0x10,%esp
801030e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801030ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030ed:	83 c0 5c             	add    $0x5c,%eax
801030f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801030f3:	8b 15 68 54 19 80    	mov    0x80195468,%edx
801030f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030fc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801030fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103105:	eb 1b                	jmp    80103122 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103107:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310a:	83 c0 10             	add    $0x10,%eax
8010310d:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103114:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103117:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010311a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010311e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103122:	a1 68 54 19 80       	mov    0x80195468,%eax
80103127:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010312a:	7c db                	jl     80103107 <write_head+0x43>
  }
  bwrite(buf);
8010312c:	83 ec 0c             	sub    $0xc,%esp
8010312f:	ff 75 f0             	pushl  -0x10(%ebp)
80103132:	e8 0f d1 ff ff       	call   80100246 <bwrite>
80103137:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010313a:	83 ec 0c             	sub    $0xc,%esp
8010313d:	ff 75 f0             	pushl  -0x10(%ebp)
80103140:	e8 4e d1 ff ff       	call   80100293 <brelse>
80103145:	83 c4 10             	add    $0x10,%esp
}
80103148:	90                   	nop
80103149:	c9                   	leave  
8010314a:	c3                   	ret    

8010314b <recover_from_log>:

static void
recover_from_log(void)
{
8010314b:	f3 0f 1e fb          	endbr32 
8010314f:	55                   	push   %ebp
80103150:	89 e5                	mov    %esp,%ebp
80103152:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103155:	e8 f2 fe ff ff       	call   8010304c <read_head>
  install_trans(); // if committed, copy from log to disk
8010315a:	e8 30 fe ff ff       	call   80102f8f <install_trans>
  log.lh.n = 0;
8010315f:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
80103166:	00 00 00 
  write_head(); // clear the log
80103169:	e8 56 ff ff ff       	call   801030c4 <write_head>
}
8010316e:	90                   	nop
8010316f:	c9                   	leave  
80103170:	c3                   	ret    

80103171 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103171:	f3 0f 1e fb          	endbr32 
80103175:	55                   	push   %ebp
80103176:	89 e5                	mov    %esp,%ebp
80103178:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 54 19 80       	push   $0x80195420
80103183:	e8 04 1a 00 00       	call   80104b8c <acquire>
80103188:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010318b:	a1 60 54 19 80       	mov    0x80195460,%eax
80103190:	85 c0                	test   %eax,%eax
80103192:	74 17                	je     801031ab <begin_op+0x3a>
      sleep(&log, &log.lock);
80103194:	83 ec 08             	sub    $0x8,%esp
80103197:	68 20 54 19 80       	push   $0x80195420
8010319c:	68 20 54 19 80       	push   $0x80195420
801031a1:	e8 9a 15 00 00       	call   80104740 <sleep>
801031a6:	83 c4 10             	add    $0x10,%esp
801031a9:	eb e0                	jmp    8010318b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801031ab:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
801031b1:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031b6:	8d 50 01             	lea    0x1(%eax),%edx
801031b9:	89 d0                	mov    %edx,%eax
801031bb:	c1 e0 02             	shl    $0x2,%eax
801031be:	01 d0                	add    %edx,%eax
801031c0:	01 c0                	add    %eax,%eax
801031c2:	01 c8                	add    %ecx,%eax
801031c4:	83 f8 1e             	cmp    $0x1e,%eax
801031c7:	7e 17                	jle    801031e0 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801031c9:	83 ec 08             	sub    $0x8,%esp
801031cc:	68 20 54 19 80       	push   $0x80195420
801031d1:	68 20 54 19 80       	push   $0x80195420
801031d6:	e8 65 15 00 00       	call   80104740 <sleep>
801031db:	83 c4 10             	add    $0x10,%esp
801031de:	eb ab                	jmp    8010318b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801031e0:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031e5:	83 c0 01             	add    $0x1,%eax
801031e8:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
801031ed:	83 ec 0c             	sub    $0xc,%esp
801031f0:	68 20 54 19 80       	push   $0x80195420
801031f5:	e8 04 1a 00 00       	call   80104bfe <release>
801031fa:	83 c4 10             	add    $0x10,%esp
      break;
801031fd:	90                   	nop
    }
  }
}
801031fe:	90                   	nop
801031ff:	c9                   	leave  
80103200:	c3                   	ret    

80103201 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103201:	f3 0f 1e fb          	endbr32 
80103205:	55                   	push   %ebp
80103206:	89 e5                	mov    %esp,%ebp
80103208:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010320b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103212:	83 ec 0c             	sub    $0xc,%esp
80103215:	68 20 54 19 80       	push   $0x80195420
8010321a:	e8 6d 19 00 00       	call   80104b8c <acquire>
8010321f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103222:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103227:	83 e8 01             	sub    $0x1,%eax
8010322a:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
8010322f:	a1 60 54 19 80       	mov    0x80195460,%eax
80103234:	85 c0                	test   %eax,%eax
80103236:	74 0d                	je     80103245 <end_op+0x44>
    panic("log.committing");
80103238:	83 ec 0c             	sub    $0xc,%esp
8010323b:	68 15 a9 10 80       	push   $0x8010a915
80103240:	e8 80 d3 ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
80103245:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010324a:	85 c0                	test   %eax,%eax
8010324c:	75 13                	jne    80103261 <end_op+0x60>
    do_commit = 1;
8010324e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103255:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
8010325c:	00 00 00 
8010325f:	eb 10                	jmp    80103271 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103261:	83 ec 0c             	sub    $0xc,%esp
80103264:	68 20 54 19 80       	push   $0x80195420
80103269:	e8 c4 15 00 00       	call   80104832 <wakeup>
8010326e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103271:	83 ec 0c             	sub    $0xc,%esp
80103274:	68 20 54 19 80       	push   $0x80195420
80103279:	e8 80 19 00 00       	call   80104bfe <release>
8010327e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103281:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103285:	74 3f                	je     801032c6 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103287:	e8 fa 00 00 00       	call   80103386 <commit>
    acquire(&log.lock);
8010328c:	83 ec 0c             	sub    $0xc,%esp
8010328f:	68 20 54 19 80       	push   $0x80195420
80103294:	e8 f3 18 00 00       	call   80104b8c <acquire>
80103299:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010329c:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
801032a3:	00 00 00 
    wakeup(&log);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	68 20 54 19 80       	push   $0x80195420
801032ae:	e8 7f 15 00 00       	call   80104832 <wakeup>
801032b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032b6:	83 ec 0c             	sub    $0xc,%esp
801032b9:	68 20 54 19 80       	push   $0x80195420
801032be:	e8 3b 19 00 00       	call   80104bfe <release>
801032c3:	83 c4 10             	add    $0x10,%esp
  }
}
801032c6:	90                   	nop
801032c7:	c9                   	leave  
801032c8:	c3                   	ret    

801032c9 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801032c9:	f3 0f 1e fb          	endbr32 
801032cd:	55                   	push   %ebp
801032ce:	89 e5                	mov    %esp,%ebp
801032d0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032da:	e9 95 00 00 00       	jmp    80103374 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801032df:	8b 15 54 54 19 80    	mov    0x80195454,%edx
801032e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e8:	01 d0                	add    %edx,%eax
801032ea:	83 c0 01             	add    $0x1,%eax
801032ed:	89 c2                	mov    %eax,%edx
801032ef:	a1 64 54 19 80       	mov    0x80195464,%eax
801032f4:	83 ec 08             	sub    $0x8,%esp
801032f7:	52                   	push   %edx
801032f8:	50                   	push   %eax
801032f9:	e8 0b cf ff ff       	call   80100209 <bread>
801032fe:	83 c4 10             	add    $0x10,%esp
80103301:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103307:	83 c0 10             	add    $0x10,%eax
8010330a:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103311:	89 c2                	mov    %eax,%edx
80103313:	a1 64 54 19 80       	mov    0x80195464,%eax
80103318:	83 ec 08             	sub    $0x8,%esp
8010331b:	52                   	push   %edx
8010331c:	50                   	push   %eax
8010331d:	e8 e7 ce ff ff       	call   80100209 <bread>
80103322:	83 c4 10             	add    $0x10,%esp
80103325:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103328:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010332b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010332e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103331:	83 c0 5c             	add    $0x5c,%eax
80103334:	83 ec 04             	sub    $0x4,%esp
80103337:	68 00 02 00 00       	push   $0x200
8010333c:	52                   	push   %edx
8010333d:	50                   	push   %eax
8010333e:	e8 9f 1b 00 00       	call   80104ee2 <memmove>
80103343:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103346:	83 ec 0c             	sub    $0xc,%esp
80103349:	ff 75 f0             	pushl  -0x10(%ebp)
8010334c:	e8 f5 ce ff ff       	call   80100246 <bwrite>
80103351:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103354:	83 ec 0c             	sub    $0xc,%esp
80103357:	ff 75 ec             	pushl  -0x14(%ebp)
8010335a:	e8 34 cf ff ff       	call   80100293 <brelse>
8010335f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103362:	83 ec 0c             	sub    $0xc,%esp
80103365:	ff 75 f0             	pushl  -0x10(%ebp)
80103368:	e8 26 cf ff ff       	call   80100293 <brelse>
8010336d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103370:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103374:	a1 68 54 19 80       	mov    0x80195468,%eax
80103379:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010337c:	0f 8c 5d ff ff ff    	jl     801032df <write_log+0x16>
  }
}
80103382:	90                   	nop
80103383:	90                   	nop
80103384:	c9                   	leave  
80103385:	c3                   	ret    

80103386 <commit>:

static void
commit()
{
80103386:	f3 0f 1e fb          	endbr32 
8010338a:	55                   	push   %ebp
8010338b:	89 e5                	mov    %esp,%ebp
8010338d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103390:	a1 68 54 19 80       	mov    0x80195468,%eax
80103395:	85 c0                	test   %eax,%eax
80103397:	7e 1e                	jle    801033b7 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103399:	e8 2b ff ff ff       	call   801032c9 <write_log>
    write_head();    // Write header to disk -- the real commit
8010339e:	e8 21 fd ff ff       	call   801030c4 <write_head>
    install_trans(); // Now install writes to home locations
801033a3:	e8 e7 fb ff ff       	call   80102f8f <install_trans>
    log.lh.n = 0;
801033a8:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801033af:	00 00 00 
    write_head();    // Erase the transaction from the log
801033b2:	e8 0d fd ff ff       	call   801030c4 <write_head>
  }
}
801033b7:	90                   	nop
801033b8:	c9                   	leave  
801033b9:	c3                   	ret    

801033ba <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801033ba:	f3 0f 1e fb          	endbr32 
801033be:	55                   	push   %ebp
801033bf:	89 e5                	mov    %esp,%ebp
801033c1:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801033c4:	a1 68 54 19 80       	mov    0x80195468,%eax
801033c9:	83 f8 1d             	cmp    $0x1d,%eax
801033cc:	7f 12                	jg     801033e0 <log_write+0x26>
801033ce:	a1 68 54 19 80       	mov    0x80195468,%eax
801033d3:	8b 15 58 54 19 80    	mov    0x80195458,%edx
801033d9:	83 ea 01             	sub    $0x1,%edx
801033dc:	39 d0                	cmp    %edx,%eax
801033de:	7c 0d                	jl     801033ed <log_write+0x33>
    panic("too big a transaction");
801033e0:	83 ec 0c             	sub    $0xc,%esp
801033e3:	68 24 a9 10 80       	push   $0x8010a924
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 3a a9 10 80       	push   $0x8010a93a
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 20 54 19 80       	push   $0x80195420
8010340b:	e8 7c 17 00 00       	call   80104b8c <acquire>
80103410:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103413:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010341a:	eb 1d                	jmp    80103439 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010341c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010341f:	83 c0 10             	add    $0x10,%eax
80103422:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103429:	89 c2                	mov    %eax,%edx
8010342b:	8b 45 08             	mov    0x8(%ebp),%eax
8010342e:	8b 40 08             	mov    0x8(%eax),%eax
80103431:	39 c2                	cmp    %eax,%edx
80103433:	74 10                	je     80103445 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103435:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103439:	a1 68 54 19 80       	mov    0x80195468,%eax
8010343e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103441:	7c d9                	jl     8010341c <log_write+0x62>
80103443:	eb 01                	jmp    80103446 <log_write+0x8c>
      break;
80103445:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103446:	8b 45 08             	mov    0x8(%ebp),%eax
80103449:	8b 40 08             	mov    0x8(%eax),%eax
8010344c:	89 c2                	mov    %eax,%edx
8010344e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103451:	83 c0 10             	add    $0x10,%eax
80103454:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
8010345b:	a1 68 54 19 80       	mov    0x80195468,%eax
80103460:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103463:	75 0d                	jne    80103472 <log_write+0xb8>
    log.lh.n++;
80103465:	a1 68 54 19 80       	mov    0x80195468,%eax
8010346a:	83 c0 01             	add    $0x1,%eax
8010346d:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
80103472:	8b 45 08             	mov    0x8(%ebp),%eax
80103475:	8b 00                	mov    (%eax),%eax
80103477:	83 c8 04             	or     $0x4,%eax
8010347a:	89 c2                	mov    %eax,%edx
8010347c:	8b 45 08             	mov    0x8(%ebp),%eax
8010347f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103481:	83 ec 0c             	sub    $0xc,%esp
80103484:	68 20 54 19 80       	push   $0x80195420
80103489:	e8 70 17 00 00       	call   80104bfe <release>
8010348e:	83 c4 10             	add    $0x10,%esp
}
80103491:	90                   	nop
80103492:	c9                   	leave  
80103493:	c3                   	ret    

80103494 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103494:	55                   	push   %ebp
80103495:	89 e5                	mov    %esp,%ebp
80103497:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010349a:	8b 55 08             	mov    0x8(%ebp),%edx
8010349d:	8b 45 0c             	mov    0xc(%ebp),%eax
801034a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801034a3:	f0 87 02             	lock xchg %eax,(%edx)
801034a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801034a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801034ac:	c9                   	leave  
801034ad:	c3                   	ret    

801034ae <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801034ae:	f3 0f 1e fb          	endbr32 
801034b2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801034b6:	83 e4 f0             	and    $0xfffffff0,%esp
801034b9:	ff 71 fc             	pushl  -0x4(%ecx)
801034bc:	55                   	push   %ebp
801034bd:	89 e5                	mov    %esp,%ebp
801034bf:	51                   	push   %ecx
801034c0:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
801034c3:	e8 0e 4f 00 00       	call   801083d6 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 90 19 80       	push   $0x80199000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 d1 44 00 00       	call   801079b3 <kvmalloc>
  mpinit_uefi();
801034e2:	e8 a8 4c 00 00       	call   8010818f <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 49 3f 00 00       	call   8010743a <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 be 32 00 00       	call   801067c3 <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 31 2e 00 00       	call   80106340 <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 bd 70 00 00       	call   8010a5db <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 0c 51 00 00       	call   80108649 <pci_init>
  arp_scan();
8010353d:	e8 85 5e 00 00       	call   801093c7 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103542:	e8 ab 07 00 00       	call   80103cf2 <userinit>

  mpmain();        // finish this processor's setup
80103547:	e8 1e 00 00 00       	call   8010356a <mpmain>

8010354c <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010354c:	f3 0f 1e fb          	endbr32 
80103550:	55                   	push   %ebp
80103551:	89 e5                	mov    %esp,%ebp
80103553:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103556:	e8 74 44 00 00       	call   801079cf <switchkvm>
  seginit();
8010355b:	e8 da 3e 00 00       	call   8010743a <seginit>
  lapicinit();
80103560:	e8 77 f5 ff ff       	call   80102adc <lapicinit>
  mpmain();
80103565:	e8 00 00 00 00       	call   8010356a <mpmain>

8010356a <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010356a:	f3 0f 1e fb          	endbr32 
8010356e:	55                   	push   %ebp
8010356f:	89 e5                	mov    %esp,%ebp
80103571:	53                   	push   %ebx
80103572:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103575:	e8 94 05 00 00       	call   80103b0e <cpuid>
8010357a:	89 c3                	mov    %eax,%ebx
8010357c:	e8 8d 05 00 00       	call   80103b0e <cpuid>
80103581:	83 ec 04             	sub    $0x4,%esp
80103584:	53                   	push   %ebx
80103585:	50                   	push   %eax
80103586:	68 55 a9 10 80       	push   $0x8010a955
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 22 2f 00 00       	call   801064ba <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103598:	e8 90 05 00 00       	call   80103b2d <mycpu>
8010359d:	05 a0 00 00 00       	add    $0xa0,%eax
801035a2:	83 ec 08             	sub    $0x8,%esp
801035a5:	6a 01                	push   $0x1
801035a7:	50                   	push   %eax
801035a8:	e8 e7 fe ff ff       	call   80103494 <xchg>
801035ad:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035b0:	e8 87 0f 00 00       	call   8010453c <scheduler>

801035b5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801035b5:	f3 0f 1e fb          	endbr32 
801035b9:	55                   	push   %ebp
801035ba:	89 e5                	mov    %esp,%ebp
801035bc:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801035bf:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801035c6:	b8 8a 00 00 00       	mov    $0x8a,%eax
801035cb:	83 ec 04             	sub    $0x4,%esp
801035ce:	50                   	push   %eax
801035cf:	68 38 f5 10 80       	push   $0x8010f538
801035d4:	ff 75 f0             	pushl  -0x10(%ebp)
801035d7:	e8 06 19 00 00       	call   80104ee2 <memmove>
801035dc:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035df:	c7 45 f4 c0 7e 19 80 	movl   $0x80197ec0,-0xc(%ebp)
801035e6:	eb 79                	jmp    80103661 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
801035e8:	e8 40 05 00 00       	call   80103b2d <mycpu>
801035ed:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035f0:	74 67                	je     80103659 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801035f2:	e8 9b f2 ff ff       	call   80102892 <kalloc>
801035f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801035fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035fd:	83 e8 04             	sub    $0x4,%eax
80103600:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103603:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103609:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010360b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010360e:	83 e8 08             	sub    $0x8,%eax
80103611:	c7 00 4c 35 10 80    	movl   $0x8010354c,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103617:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
8010361c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103625:	83 e8 0c             	sub    $0xc,%eax
80103628:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
8010362a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010362d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103636:	0f b6 00             	movzbl (%eax),%eax
80103639:	0f b6 c0             	movzbl %al,%eax
8010363c:	83 ec 08             	sub    $0x8,%esp
8010363f:	52                   	push   %edx
80103640:	50                   	push   %eax
80103641:	e8 08 f6 ff ff       	call   80102c4e <lapicstartap>
80103646:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103649:	90                   	nop
8010364a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010364d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103653:	85 c0                	test   %eax,%eax
80103655:	74 f3                	je     8010364a <startothers+0x95>
80103657:	eb 01                	jmp    8010365a <startothers+0xa5>
      continue;
80103659:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
8010365a:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103661:	a1 80 81 19 80       	mov    0x80198180,%eax
80103666:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010366c:	05 c0 7e 19 80       	add    $0x80197ec0,%eax
80103671:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103674:	0f 82 6e ff ff ff    	jb     801035e8 <startothers+0x33>
      ;
  }
}
8010367a:	90                   	nop
8010367b:	90                   	nop
8010367c:	c9                   	leave  
8010367d:	c3                   	ret    

8010367e <outb>:
{
8010367e:	55                   	push   %ebp
8010367f:	89 e5                	mov    %esp,%ebp
80103681:	83 ec 08             	sub    $0x8,%esp
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 55 0c             	mov    0xc(%ebp),%edx
8010368a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010368e:	89 d0                	mov    %edx,%eax
80103690:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103693:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103697:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010369b:	ee                   	out    %al,(%dx)
}
8010369c:	90                   	nop
8010369d:	c9                   	leave  
8010369e:	c3                   	ret    

8010369f <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
8010369f:	f3 0f 1e fb          	endbr32 
801036a3:	55                   	push   %ebp
801036a4:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801036a6:	68 ff 00 00 00       	push   $0xff
801036ab:	6a 21                	push   $0x21
801036ad:	e8 cc ff ff ff       	call   8010367e <outb>
801036b2:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801036b5:	68 ff 00 00 00       	push   $0xff
801036ba:	68 a1 00 00 00       	push   $0xa1
801036bf:	e8 ba ff ff ff       	call   8010367e <outb>
801036c4:	83 c4 08             	add    $0x8,%esp
}
801036c7:	90                   	nop
801036c8:	c9                   	leave  
801036c9:	c3                   	ret    

801036ca <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801036ca:	f3 0f 1e fb          	endbr32 
801036ce:	55                   	push   %ebp
801036cf:	89 e5                	mov    %esp,%ebp
801036d1:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801036d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801036db:	8b 45 0c             	mov    0xc(%ebp),%eax
801036de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801036e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801036e7:	8b 10                	mov    (%eax),%edx
801036e9:	8b 45 08             	mov    0x8(%ebp),%eax
801036ec:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801036ee:	e8 30 d9 ff ff       	call   80101023 <filealloc>
801036f3:	8b 55 08             	mov    0x8(%ebp),%edx
801036f6:	89 02                	mov    %eax,(%edx)
801036f8:	8b 45 08             	mov    0x8(%ebp),%eax
801036fb:	8b 00                	mov    (%eax),%eax
801036fd:	85 c0                	test   %eax,%eax
801036ff:	0f 84 c8 00 00 00    	je     801037cd <pipealloc+0x103>
80103705:	e8 19 d9 ff ff       	call   80101023 <filealloc>
8010370a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010370d:	89 02                	mov    %eax,(%edx)
8010370f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103712:	8b 00                	mov    (%eax),%eax
80103714:	85 c0                	test   %eax,%eax
80103716:	0f 84 b1 00 00 00    	je     801037cd <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010371c:	e8 71 f1 ff ff       	call   80102892 <kalloc>
80103721:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103724:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103728:	0f 84 a2 00 00 00    	je     801037d0 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
8010372e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103731:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103738:	00 00 00 
  p->writeopen = 1;
8010373b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010373e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103745:	00 00 00 
  p->nwrite = 0;
80103748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374b:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103752:	00 00 00 
  p->nread = 0;
80103755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103758:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010375f:	00 00 00 
  initlock(&p->lock, "pipe");
80103762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103765:	83 ec 08             	sub    $0x8,%esp
80103768:	68 69 a9 10 80       	push   $0x8010a969
8010376d:	50                   	push   %eax
8010376e:	e8 f3 13 00 00       	call   80104b66 <initlock>
80103773:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103776:	8b 45 08             	mov    0x8(%ebp),%eax
80103779:	8b 00                	mov    (%eax),%eax
8010377b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103781:	8b 45 08             	mov    0x8(%ebp),%eax
80103784:	8b 00                	mov    (%eax),%eax
80103786:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010378a:	8b 45 08             	mov    0x8(%ebp),%eax
8010378d:	8b 00                	mov    (%eax),%eax
8010378f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103793:	8b 45 08             	mov    0x8(%ebp),%eax
80103796:	8b 00                	mov    (%eax),%eax
80103798:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010379b:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010379e:	8b 45 0c             	mov    0xc(%ebp),%eax
801037a1:	8b 00                	mov    (%eax),%eax
801037a3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801037a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801037ac:	8b 00                	mov    (%eax),%eax
801037ae:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801037b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b5:	8b 00                	mov    (%eax),%eax
801037b7:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801037bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801037be:	8b 00                	mov    (%eax),%eax
801037c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037c3:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801037c6:	b8 00 00 00 00       	mov    $0x0,%eax
801037cb:	eb 51                	jmp    8010381e <pipealloc+0x154>
    goto bad;
801037cd:	90                   	nop
801037ce:	eb 01                	jmp    801037d1 <pipealloc+0x107>
    goto bad;
801037d0:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801037d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037d5:	74 0e                	je     801037e5 <pipealloc+0x11b>
    kfree((char*)p);
801037d7:	83 ec 0c             	sub    $0xc,%esp
801037da:	ff 75 f4             	pushl  -0xc(%ebp)
801037dd:	e8 12 f0 ff ff       	call   801027f4 <kfree>
801037e2:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801037e5:	8b 45 08             	mov    0x8(%ebp),%eax
801037e8:	8b 00                	mov    (%eax),%eax
801037ea:	85 c0                	test   %eax,%eax
801037ec:	74 11                	je     801037ff <pipealloc+0x135>
    fileclose(*f0);
801037ee:	8b 45 08             	mov    0x8(%ebp),%eax
801037f1:	8b 00                	mov    (%eax),%eax
801037f3:	83 ec 0c             	sub    $0xc,%esp
801037f6:	50                   	push   %eax
801037f7:	e8 ed d8 ff ff       	call   801010e9 <fileclose>
801037fc:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801037ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103802:	8b 00                	mov    (%eax),%eax
80103804:	85 c0                	test   %eax,%eax
80103806:	74 11                	je     80103819 <pipealloc+0x14f>
    fileclose(*f1);
80103808:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380b:	8b 00                	mov    (%eax),%eax
8010380d:	83 ec 0c             	sub    $0xc,%esp
80103810:	50                   	push   %eax
80103811:	e8 d3 d8 ff ff       	call   801010e9 <fileclose>
80103816:	83 c4 10             	add    $0x10,%esp
  return -1;
80103819:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010381e:	c9                   	leave  
8010381f:	c3                   	ret    

80103820 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103820:	f3 0f 1e fb          	endbr32 
80103824:	55                   	push   %ebp
80103825:	89 e5                	mov    %esp,%ebp
80103827:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010382a:	8b 45 08             	mov    0x8(%ebp),%eax
8010382d:	83 ec 0c             	sub    $0xc,%esp
80103830:	50                   	push   %eax
80103831:	e8 56 13 00 00       	call   80104b8c <acquire>
80103836:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103839:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010383d:	74 23                	je     80103862 <pipeclose+0x42>
    p->writeopen = 0;
8010383f:	8b 45 08             	mov    0x8(%ebp),%eax
80103842:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103849:	00 00 00 
    wakeup(&p->nread);
8010384c:	8b 45 08             	mov    0x8(%ebp),%eax
8010384f:	05 34 02 00 00       	add    $0x234,%eax
80103854:	83 ec 0c             	sub    $0xc,%esp
80103857:	50                   	push   %eax
80103858:	e8 d5 0f 00 00       	call   80104832 <wakeup>
8010385d:	83 c4 10             	add    $0x10,%esp
80103860:	eb 21                	jmp    80103883 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103862:	8b 45 08             	mov    0x8(%ebp),%eax
80103865:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010386c:	00 00 00 
    wakeup(&p->nwrite);
8010386f:	8b 45 08             	mov    0x8(%ebp),%eax
80103872:	05 38 02 00 00       	add    $0x238,%eax
80103877:	83 ec 0c             	sub    $0xc,%esp
8010387a:	50                   	push   %eax
8010387b:	e8 b2 0f 00 00       	call   80104832 <wakeup>
80103880:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103883:	8b 45 08             	mov    0x8(%ebp),%eax
80103886:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010388c:	85 c0                	test   %eax,%eax
8010388e:	75 2c                	jne    801038bc <pipeclose+0x9c>
80103890:	8b 45 08             	mov    0x8(%ebp),%eax
80103893:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103899:	85 c0                	test   %eax,%eax
8010389b:	75 1f                	jne    801038bc <pipeclose+0x9c>
    release(&p->lock);
8010389d:	8b 45 08             	mov    0x8(%ebp),%eax
801038a0:	83 ec 0c             	sub    $0xc,%esp
801038a3:	50                   	push   %eax
801038a4:	e8 55 13 00 00       	call   80104bfe <release>
801038a9:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801038ac:	83 ec 0c             	sub    $0xc,%esp
801038af:	ff 75 08             	pushl  0x8(%ebp)
801038b2:	e8 3d ef ff ff       	call   801027f4 <kfree>
801038b7:	83 c4 10             	add    $0x10,%esp
801038ba:	eb 10                	jmp    801038cc <pipeclose+0xac>
  } else
    release(&p->lock);
801038bc:	8b 45 08             	mov    0x8(%ebp),%eax
801038bf:	83 ec 0c             	sub    $0xc,%esp
801038c2:	50                   	push   %eax
801038c3:	e8 36 13 00 00       	call   80104bfe <release>
801038c8:	83 c4 10             	add    $0x10,%esp
}
801038cb:	90                   	nop
801038cc:	90                   	nop
801038cd:	c9                   	leave  
801038ce:	c3                   	ret    

801038cf <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801038cf:	f3 0f 1e fb          	endbr32 
801038d3:	55                   	push   %ebp
801038d4:	89 e5                	mov    %esp,%ebp
801038d6:	53                   	push   %ebx
801038d7:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801038da:	8b 45 08             	mov    0x8(%ebp),%eax
801038dd:	83 ec 0c             	sub    $0xc,%esp
801038e0:	50                   	push   %eax
801038e1:	e8 a6 12 00 00       	call   80104b8c <acquire>
801038e6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801038e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038f0:	e9 ad 00 00 00       	jmp    801039a2 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801038f5:	8b 45 08             	mov    0x8(%ebp),%eax
801038f8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038fe:	85 c0                	test   %eax,%eax
80103900:	74 0c                	je     8010390e <pipewrite+0x3f>
80103902:	e8 a2 02 00 00       	call   80103ba9 <myproc>
80103907:	8b 40 24             	mov    0x24(%eax),%eax
8010390a:	85 c0                	test   %eax,%eax
8010390c:	74 19                	je     80103927 <pipewrite+0x58>
        release(&p->lock);
8010390e:	8b 45 08             	mov    0x8(%ebp),%eax
80103911:	83 ec 0c             	sub    $0xc,%esp
80103914:	50                   	push   %eax
80103915:	e8 e4 12 00 00       	call   80104bfe <release>
8010391a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010391d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103922:	e9 a9 00 00 00       	jmp    801039d0 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	05 34 02 00 00       	add    $0x234,%eax
8010392f:	83 ec 0c             	sub    $0xc,%esp
80103932:	50                   	push   %eax
80103933:	e8 fa 0e 00 00       	call   80104832 <wakeup>
80103938:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010393b:	8b 45 08             	mov    0x8(%ebp),%eax
8010393e:	8b 55 08             	mov    0x8(%ebp),%edx
80103941:	81 c2 38 02 00 00    	add    $0x238,%edx
80103947:	83 ec 08             	sub    $0x8,%esp
8010394a:	50                   	push   %eax
8010394b:	52                   	push   %edx
8010394c:	e8 ef 0d 00 00       	call   80104740 <sleep>
80103951:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010395d:	8b 45 08             	mov    0x8(%ebp),%eax
80103960:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103966:	05 00 02 00 00       	add    $0x200,%eax
8010396b:	39 c2                	cmp    %eax,%edx
8010396d:	74 86                	je     801038f5 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010396f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103972:	8b 45 0c             	mov    0xc(%ebp),%eax
80103975:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103978:	8b 45 08             	mov    0x8(%ebp),%eax
8010397b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103981:	8d 48 01             	lea    0x1(%eax),%ecx
80103984:	8b 55 08             	mov    0x8(%ebp),%edx
80103987:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010398d:	25 ff 01 00 00       	and    $0x1ff,%eax
80103992:	89 c1                	mov    %eax,%ecx
80103994:	0f b6 13             	movzbl (%ebx),%edx
80103997:	8b 45 08             	mov    0x8(%ebp),%eax
8010399a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010399e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801039a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801039a8:	7c aa                	jl     80103954 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801039aa:	8b 45 08             	mov    0x8(%ebp),%eax
801039ad:	05 34 02 00 00       	add    $0x234,%eax
801039b2:	83 ec 0c             	sub    $0xc,%esp
801039b5:	50                   	push   %eax
801039b6:	e8 77 0e 00 00       	call   80104832 <wakeup>
801039bb:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039be:	8b 45 08             	mov    0x8(%ebp),%eax
801039c1:	83 ec 0c             	sub    $0xc,%esp
801039c4:	50                   	push   %eax
801039c5:	e8 34 12 00 00       	call   80104bfe <release>
801039ca:	83 c4 10             	add    $0x10,%esp
  return n;
801039cd:	8b 45 10             	mov    0x10(%ebp),%eax
}
801039d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039d3:	c9                   	leave  
801039d4:	c3                   	ret    

801039d5 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801039d5:	f3 0f 1e fb          	endbr32 
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
801039dc:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801039df:	8b 45 08             	mov    0x8(%ebp),%eax
801039e2:	83 ec 0c             	sub    $0xc,%esp
801039e5:	50                   	push   %eax
801039e6:	e8 a1 11 00 00       	call   80104b8c <acquire>
801039eb:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039ee:	eb 3e                	jmp    80103a2e <piperead+0x59>
    if(myproc()->killed){
801039f0:	e8 b4 01 00 00       	call   80103ba9 <myproc>
801039f5:	8b 40 24             	mov    0x24(%eax),%eax
801039f8:	85 c0                	test   %eax,%eax
801039fa:	74 19                	je     80103a15 <piperead+0x40>
      release(&p->lock);
801039fc:	8b 45 08             	mov    0x8(%ebp),%eax
801039ff:	83 ec 0c             	sub    $0xc,%esp
80103a02:	50                   	push   %eax
80103a03:	e8 f6 11 00 00       	call   80104bfe <release>
80103a08:	83 c4 10             	add    $0x10,%esp
      return -1;
80103a0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a10:	e9 be 00 00 00       	jmp    80103ad3 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a15:	8b 45 08             	mov    0x8(%ebp),%eax
80103a18:	8b 55 08             	mov    0x8(%ebp),%edx
80103a1b:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a21:	83 ec 08             	sub    $0x8,%esp
80103a24:	50                   	push   %eax
80103a25:	52                   	push   %edx
80103a26:	e8 15 0d 00 00       	call   80104740 <sleep>
80103a2b:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103a31:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a37:	8b 45 08             	mov    0x8(%ebp),%eax
80103a3a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a40:	39 c2                	cmp    %eax,%edx
80103a42:	75 0d                	jne    80103a51 <piperead+0x7c>
80103a44:	8b 45 08             	mov    0x8(%ebp),%eax
80103a47:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103a4d:	85 c0                	test   %eax,%eax
80103a4f:	75 9f                	jne    801039f0 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a58:	eb 48                	jmp    80103aa2 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a5d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a63:	8b 45 08             	mov    0x8(%ebp),%eax
80103a66:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a6c:	39 c2                	cmp    %eax,%edx
80103a6e:	74 3c                	je     80103aac <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103a70:	8b 45 08             	mov    0x8(%ebp),%eax
80103a73:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103a79:	8d 48 01             	lea    0x1(%eax),%ecx
80103a7c:	8b 55 08             	mov    0x8(%ebp),%edx
80103a7f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103a85:	25 ff 01 00 00       	and    $0x1ff,%eax
80103a8a:	89 c1                	mov    %eax,%ecx
80103a8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a92:	01 c2                	add    %eax,%edx
80103a94:	8b 45 08             	mov    0x8(%ebp),%eax
80103a97:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103a9c:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa5:	3b 45 10             	cmp    0x10(%ebp),%eax
80103aa8:	7c b0                	jl     80103a5a <piperead+0x85>
80103aaa:	eb 01                	jmp    80103aad <piperead+0xd8>
      break;
80103aac:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103aad:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab0:	05 38 02 00 00       	add    $0x238,%eax
80103ab5:	83 ec 0c             	sub    $0xc,%esp
80103ab8:	50                   	push   %eax
80103ab9:	e8 74 0d 00 00       	call   80104832 <wakeup>
80103abe:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac4:	83 ec 0c             	sub    $0xc,%esp
80103ac7:	50                   	push   %eax
80103ac8:	e8 31 11 00 00       	call   80104bfe <release>
80103acd:	83 c4 10             	add    $0x10,%esp
  return i;
80103ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ad3:	c9                   	leave  
80103ad4:	c3                   	ret    

80103ad5 <readeflags>:
{
80103ad5:	55                   	push   %ebp
80103ad6:	89 e5                	mov    %esp,%ebp
80103ad8:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103adb:	9c                   	pushf  
80103adc:	58                   	pop    %eax
80103add:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103ae0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103ae3:	c9                   	leave  
80103ae4:	c3                   	ret    

80103ae5 <sti>:
{
80103ae5:	55                   	push   %ebp
80103ae6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103ae8:	fb                   	sti    
}
80103ae9:	90                   	nop
80103aea:	5d                   	pop    %ebp
80103aeb:	c3                   	ret    

80103aec <pinit>:
extern void trapret(void);
static void wakeup1(void *chan);

void
pinit(void)
{
80103aec:	f3 0f 1e fb          	endbr32 
80103af0:	55                   	push   %ebp
80103af1:	89 e5                	mov    %esp,%ebp
80103af3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103af6:	83 ec 08             	sub    $0x8,%esp
80103af9:	68 70 a9 10 80       	push   $0x8010a970
80103afe:	68 00 55 19 80       	push   $0x80195500
80103b03:	e8 5e 10 00 00       	call   80104b66 <initlock>
80103b08:	83 c4 10             	add    $0x10,%esp
}
80103b0b:	90                   	nop
80103b0c:	c9                   	leave  
80103b0d:	c3                   	ret    

80103b0e <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b0e:	f3 0f 1e fb          	endbr32 
80103b12:	55                   	push   %ebp
80103b13:	89 e5                	mov    %esp,%ebp
80103b15:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b18:	e8 10 00 00 00       	call   80103b2d <mycpu>
80103b1d:	2d c0 7e 19 80       	sub    $0x80197ec0,%eax
80103b22:	c1 f8 04             	sar    $0x4,%eax
80103b25:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b2b:	c9                   	leave  
80103b2c:	c3                   	ret    

80103b2d <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b2d:	f3 0f 1e fb          	endbr32 
80103b31:	55                   	push   %ebp
80103b32:	89 e5                	mov    %esp,%ebp
80103b34:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103b37:	e8 99 ff ff ff       	call   80103ad5 <readeflags>
80103b3c:	25 00 02 00 00       	and    $0x200,%eax
80103b41:	85 c0                	test   %eax,%eax
80103b43:	74 0d                	je     80103b52 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103b45:	83 ec 0c             	sub    $0xc,%esp
80103b48:	68 78 a9 10 80       	push   $0x8010a978
80103b4d:	e8 73 ca ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
80103b52:	e8 a8 f0 ff ff       	call   80102bff <lapicid>
80103b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103b5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b61:	eb 2d                	jmp    80103b90 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b66:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b6c:	05 c0 7e 19 80       	add    $0x80197ec0,%eax
80103b71:	0f b6 00             	movzbl (%eax),%eax
80103b74:	0f b6 c0             	movzbl %al,%eax
80103b77:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b7a:	75 10                	jne    80103b8c <mycpu+0x5f>
      return &cpus[i];
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b85:	05 c0 7e 19 80       	add    $0x80197ec0,%eax
80103b8a:	eb 1b                	jmp    80103ba7 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b90:	a1 80 81 19 80       	mov    0x80198180,%eax
80103b95:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b98:	7c c9                	jl     80103b63 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103b9a:	83 ec 0c             	sub    $0xc,%esp
80103b9d:	68 9e a9 10 80       	push   $0x8010a99e
80103ba2:	e8 1e ca ff ff       	call   801005c5 <panic>
}
80103ba7:	c9                   	leave  
80103ba8:	c3                   	ret    

80103ba9 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103ba9:	f3 0f 1e fb          	endbr32 
80103bad:	55                   	push   %ebp
80103bae:	89 e5                	mov    %esp,%ebp
80103bb0:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103bb3:	e8 50 11 00 00       	call   80104d08 <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 88 11 00 00       	call   80104d59 <popcli>
  return p;
80103bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bd4:	c9                   	leave  
80103bd5:	c3                   	ret    

80103bd6 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103bd6:	f3 0f 1e fb          	endbr32 
80103bda:	55                   	push   %ebp
80103bdb:	89 e5                	mov    %esp,%ebp
80103bdd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103be0:	83 ec 0c             	sub    $0xc,%esp
80103be3:	68 00 55 19 80       	push   $0x80195500
80103be8:	e8 9f 0f 00 00       	call   80104b8c <acquire>
80103bed:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103bf0:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103bf7:	eb 11                	jmp    80103c0a <allocproc+0x34>
    if(p->state == UNUSED){
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 0c             	mov    0xc(%eax),%eax
80103bff:	85 c0                	test   %eax,%eax
80103c01:	74 2a                	je     80103c2d <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103c03:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80103c0a:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
80103c11:	72 e6                	jb     80103bf9 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c13:	83 ec 0c             	sub    $0xc,%esp
80103c16:	68 00 55 19 80       	push   $0x80195500
80103c1b:	e8 de 0f 00 00       	call   80104bfe <release>
80103c20:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c23:	b8 00 00 00 00       	mov    $0x0,%eax
80103c28:	e9 c3 00 00 00       	jmp    80103cf0 <allocproc+0x11a>
      goto found;
80103c2d:	90                   	nop
80103c2e:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80103c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c35:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c3c:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c41:	8d 50 01             	lea    0x1(%eax),%edx
80103c44:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103c4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c4d:	89 42 10             	mov    %eax,0x10(%edx)

  p->scheduler = 0; //사용자 수준 스케줄러 필드를 0으로 설정, 초기화
80103c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c53:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80103c5a:	00 00 00 

  release(&ptable.lock);
80103c5d:	83 ec 0c             	sub    $0xc,%esp
80103c60:	68 00 55 19 80       	push   $0x80195500
80103c65:	e8 94 0f 00 00       	call   80104bfe <release>
80103c6a:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103c6d:	e8 20 ec ff ff       	call   80102892 <kalloc>
80103c72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c75:	89 42 08             	mov    %eax,0x8(%edx)
80103c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7b:	8b 40 08             	mov    0x8(%eax),%eax
80103c7e:	85 c0                	test   %eax,%eax
80103c80:	75 11                	jne    80103c93 <allocproc+0xbd>
    p->state = UNUSED;
80103c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c85:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103c8c:	b8 00 00 00 00       	mov    $0x0,%eax
80103c91:	eb 5d                	jmp    80103cf0 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
80103c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c96:	8b 40 08             	mov    0x8(%eax),%eax
80103c99:	05 00 10 00 00       	add    $0x1000,%eax
80103c9e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103ca1:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cab:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103cae:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103cb2:	ba fa 62 10 80       	mov    $0x801062fa,%edx
80103cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cba:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103cbc:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cc6:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ccc:	8b 40 1c             	mov    0x1c(%eax),%eax
80103ccf:	83 ec 04             	sub    $0x4,%esp
80103cd2:	6a 14                	push   $0x14
80103cd4:	6a 00                	push   $0x0
80103cd6:	50                   	push   %eax
80103cd7:	e8 3f 11 00 00       	call   80104e1b <memset>
80103cdc:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce2:	8b 40 1c             	mov    0x1c(%eax),%eax
80103ce5:	ba f6 46 10 80       	mov    $0x801046f6,%edx
80103cea:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103cf0:	c9                   	leave  
80103cf1:	c3                   	ret    

80103cf2 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103cf2:	f3 0f 1e fb          	endbr32 
80103cf6:	55                   	push   %ebp
80103cf7:	89 e5                	mov    %esp,%ebp
80103cf9:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103cfc:	e8 d5 fe ff ff       	call   80103bd6 <allocproc>
80103d01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d07:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103d0c:	e8 b1 3b 00 00       	call   801078c2 <setupkvm>
80103d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d14:	89 42 04             	mov    %eax,0x4(%edx)
80103d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1a:	8b 40 04             	mov    0x4(%eax),%eax
80103d1d:	85 c0                	test   %eax,%eax
80103d1f:	75 0d                	jne    80103d2e <userinit+0x3c>
    panic("userinit: out of memory?");
80103d21:	83 ec 0c             	sub    $0xc,%esp
80103d24:	68 ae a9 10 80       	push   $0x8010a9ae
80103d29:	e8 97 c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d2e:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d36:	8b 40 04             	mov    0x4(%eax),%eax
80103d39:	83 ec 04             	sub    $0x4,%esp
80103d3c:	52                   	push   %edx
80103d3d:	68 0c f5 10 80       	push   $0x8010f50c
80103d42:	50                   	push   %eax
80103d43:	e8 47 3e 00 00       	call   80107b8f <inituvm>
80103d48:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d57:	8b 40 18             	mov    0x18(%eax),%eax
80103d5a:	83 ec 04             	sub    $0x4,%esp
80103d5d:	6a 4c                	push   $0x4c
80103d5f:	6a 00                	push   $0x0
80103d61:	50                   	push   %eax
80103d62:	e8 b4 10 00 00       	call   80104e1b <memset>
80103d67:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6d:	8b 40 18             	mov    0x18(%eax),%eax
80103d70:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d79:	8b 40 18             	mov    0x18(%eax),%eax
80103d7c:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d85:	8b 50 18             	mov    0x18(%eax),%edx
80103d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8b:	8b 40 18             	mov    0x18(%eax),%eax
80103d8e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103d92:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d99:	8b 50 18             	mov    0x18(%eax),%edx
80103d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9f:	8b 40 18             	mov    0x18(%eax),%eax
80103da2:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103da6:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dad:	8b 40 18             	mov    0x18(%eax),%eax
80103db0:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dba:	8b 40 18             	mov    0x18(%eax),%eax
80103dbd:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc7:	8b 40 18             	mov    0x18(%eax),%eax
80103dca:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd4:	83 c0 6c             	add    $0x6c,%eax
80103dd7:	83 ec 04             	sub    $0x4,%esp
80103dda:	6a 10                	push   $0x10
80103ddc:	68 c7 a9 10 80       	push   $0x8010a9c7
80103de1:	50                   	push   %eax
80103de2:	e8 4f 12 00 00       	call   80105036 <safestrcpy>
80103de7:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103dea:	83 ec 0c             	sub    $0xc,%esp
80103ded:	68 d0 a9 10 80       	push   $0x8010a9d0
80103df2:	e8 f0 e7 ff ff       	call   801025e7 <namei>
80103df7:	83 c4 10             	add    $0x10,%esp
80103dfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dfd:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103e00:	83 ec 0c             	sub    $0xc,%esp
80103e03:	68 00 55 19 80       	push   $0x80195500
80103e08:	e8 7f 0d 00 00       	call   80104b8c <acquire>
80103e0d:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e13:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e1a:	83 ec 0c             	sub    $0xc,%esp
80103e1d:	68 00 55 19 80       	push   $0x80195500
80103e22:	e8 d7 0d 00 00       	call   80104bfe <release>
80103e27:	83 c4 10             	add    $0x10,%esp
}
80103e2a:	90                   	nop
80103e2b:	c9                   	leave  
80103e2c:	c3                   	ret    

80103e2d <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e2d:	f3 0f 1e fb          	endbr32 
80103e31:	55                   	push   %ebp
80103e32:	89 e5                	mov    %esp,%ebp
80103e34:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103e37:	e8 6d fd ff ff       	call   80103ba9 <myproc>
80103e3c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e42:	8b 00                	mov    (%eax),%eax
80103e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103e47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e4b:	7e 2e                	jle    80103e7b <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e4d:	8b 55 08             	mov    0x8(%ebp),%edx
80103e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e53:	01 c2                	add    %eax,%edx
80103e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e58:	8b 40 04             	mov    0x4(%eax),%eax
80103e5b:	83 ec 04             	sub    $0x4,%esp
80103e5e:	52                   	push   %edx
80103e5f:	ff 75 f4             	pushl  -0xc(%ebp)
80103e62:	50                   	push   %eax
80103e63:	e8 6c 3e 00 00       	call   80107cd4 <allocuvm>
80103e68:	83 c4 10             	add    $0x10,%esp
80103e6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e72:	75 3b                	jne    80103eaf <growproc+0x82>
      return -1;
80103e74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e79:	eb 4f                	jmp    80103eca <growproc+0x9d>
  } else if(n < 0){
80103e7b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e7f:	79 2e                	jns    80103eaf <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e81:	8b 55 08             	mov    0x8(%ebp),%edx
80103e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e87:	01 c2                	add    %eax,%edx
80103e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e8c:	8b 40 04             	mov    0x4(%eax),%eax
80103e8f:	83 ec 04             	sub    $0x4,%esp
80103e92:	52                   	push   %edx
80103e93:	ff 75 f4             	pushl  -0xc(%ebp)
80103e96:	50                   	push   %eax
80103e97:	e8 41 3f 00 00       	call   80107ddd <deallocuvm>
80103e9c:	83 c4 10             	add    $0x10,%esp
80103e9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ea2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ea6:	75 07                	jne    80103eaf <growproc+0x82>
      return -1;
80103ea8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ead:	eb 1b                	jmp    80103eca <growproc+0x9d>
  }
  curproc->sz = sz;
80103eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103eb5:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103eb7:	83 ec 0c             	sub    $0xc,%esp
80103eba:	ff 75 f0             	pushl  -0x10(%ebp)
80103ebd:	e8 2a 3b 00 00       	call   801079ec <switchuvm>
80103ec2:	83 c4 10             	add    $0x10,%esp
  return 0;
80103ec5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103eca:	c9                   	leave  
80103ecb:	c3                   	ret    

80103ecc <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103ecc:	f3 0f 1e fb          	endbr32 
80103ed0:	55                   	push   %ebp
80103ed1:	89 e5                	mov    %esp,%ebp
80103ed3:	57                   	push   %edi
80103ed4:	56                   	push   %esi
80103ed5:	53                   	push   %ebx
80103ed6:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103ed9:	e8 cb fc ff ff       	call   80103ba9 <myproc>
80103ede:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103ee1:	e8 f0 fc ff ff       	call   80103bd6 <allocproc>
80103ee6:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103ee9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103eed:	75 0a                	jne    80103ef9 <fork+0x2d>
    return -1;
80103eef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ef4:	e9 48 01 00 00       	jmp    80104041 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103ef9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103efc:	8b 10                	mov    (%eax),%edx
80103efe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f01:	8b 40 04             	mov    0x4(%eax),%eax
80103f04:	83 ec 08             	sub    $0x8,%esp
80103f07:	52                   	push   %edx
80103f08:	50                   	push   %eax
80103f09:	e8 79 40 00 00       	call   80107f87 <copyuvm>
80103f0e:	83 c4 10             	add    $0x10,%esp
80103f11:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f14:	89 42 04             	mov    %eax,0x4(%edx)
80103f17:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f1a:	8b 40 04             	mov    0x4(%eax),%eax
80103f1d:	85 c0                	test   %eax,%eax
80103f1f:	75 30                	jne    80103f51 <fork+0x85>
    kfree(np->kstack);
80103f21:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f24:	8b 40 08             	mov    0x8(%eax),%eax
80103f27:	83 ec 0c             	sub    $0xc,%esp
80103f2a:	50                   	push   %eax
80103f2b:	e8 c4 e8 ff ff       	call   801027f4 <kfree>
80103f30:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103f33:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f36:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103f3d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f40:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103f47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f4c:	e9 f0 00 00 00       	jmp    80104041 <fork+0x175>
  }
  np->sz = curproc->sz;
80103f51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f54:	8b 10                	mov    (%eax),%edx
80103f56:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f59:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103f5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103f61:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103f64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f67:	8b 48 18             	mov    0x18(%eax),%ecx
80103f6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f6d:	8b 40 18             	mov    0x18(%eax),%eax
80103f70:	89 c2                	mov    %eax,%edx
80103f72:	89 cb                	mov    %ecx,%ebx
80103f74:	b8 13 00 00 00       	mov    $0x13,%eax
80103f79:	89 d7                	mov    %edx,%edi
80103f7b:	89 de                	mov    %ebx,%esi
80103f7d:	89 c1                	mov    %eax,%ecx
80103f7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103f81:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f84:	8b 40 18             	mov    0x18(%eax),%eax
80103f87:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103f8e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103f95:	eb 3b                	jmp    80103fd2 <fork+0x106>
    if(curproc->ofile[i])
80103f97:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f9a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f9d:	83 c2 08             	add    $0x8,%edx
80103fa0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fa4:	85 c0                	test   %eax,%eax
80103fa6:	74 26                	je     80103fce <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103fa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fae:	83 c2 08             	add    $0x8,%edx
80103fb1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fb5:	83 ec 0c             	sub    $0xc,%esp
80103fb8:	50                   	push   %eax
80103fb9:	e8 d6 d0 ff ff       	call   80101094 <filedup>
80103fbe:	83 c4 10             	add    $0x10,%esp
80103fc1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fc4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103fc7:	83 c1 08             	add    $0x8,%ecx
80103fca:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103fce:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103fd2:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103fd6:	7e bf                	jle    80103f97 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80103fd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fdb:	8b 40 68             	mov    0x68(%eax),%eax
80103fde:	83 ec 0c             	sub    $0xc,%esp
80103fe1:	50                   	push   %eax
80103fe2:	e8 57 da ff ff       	call   80101a3e <idup>
80103fe7:	83 c4 10             	add    $0x10,%esp
80103fea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fed:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103ff0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ff3:	8d 50 6c             	lea    0x6c(%eax),%edx
80103ff6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ff9:	83 c0 6c             	add    $0x6c,%eax
80103ffc:	83 ec 04             	sub    $0x4,%esp
80103fff:	6a 10                	push   $0x10
80104001:	52                   	push   %edx
80104002:	50                   	push   %eax
80104003:	e8 2e 10 00 00       	call   80105036 <safestrcpy>
80104008:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010400b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010400e:	8b 40 10             	mov    0x10(%eax),%eax
80104011:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104014:	83 ec 0c             	sub    $0xc,%esp
80104017:	68 00 55 19 80       	push   $0x80195500
8010401c:	e8 6b 0b 00 00       	call   80104b8c <acquire>
80104021:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104024:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104027:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010402e:	83 ec 0c             	sub    $0xc,%esp
80104031:	68 00 55 19 80       	push   $0x80195500
80104036:	e8 c3 0b 00 00       	call   80104bfe <release>
8010403b:	83 c4 10             	add    $0x10,%esp

  return pid;
8010403e:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104041:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104044:	5b                   	pop    %ebx
80104045:	5e                   	pop    %esi
80104046:	5f                   	pop    %edi
80104047:	5d                   	pop    %ebp
80104048:	c3                   	ret    

80104049 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104049:	f3 0f 1e fb          	endbr32 
8010404d:	55                   	push   %ebp
8010404e:	89 e5                	mov    %esp,%ebp
80104050:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104053:	e8 51 fb ff ff       	call   80103ba9 <myproc>
80104058:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010405b:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104060:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104063:	75 0d                	jne    80104072 <exit+0x29>
    panic("init exiting");
80104065:	83 ec 0c             	sub    $0xc,%esp
80104068:	68 d2 a9 10 80       	push   $0x8010a9d2
8010406d:	e8 53 c5 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104072:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104079:	eb 3f                	jmp    801040ba <exit+0x71>
    if(curproc->ofile[fd]){
8010407b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010407e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104081:	83 c2 08             	add    $0x8,%edx
80104084:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104088:	85 c0                	test   %eax,%eax
8010408a:	74 2a                	je     801040b6 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
8010408c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010408f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104092:	83 c2 08             	add    $0x8,%edx
80104095:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104099:	83 ec 0c             	sub    $0xc,%esp
8010409c:	50                   	push   %eax
8010409d:	e8 47 d0 ff ff       	call   801010e9 <fileclose>
801040a2:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801040a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040ab:	83 c2 08             	add    $0x8,%edx
801040ae:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801040b5:	00 
  for(fd = 0; fd < NOFILE; fd++){
801040b6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801040ba:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801040be:	7e bb                	jle    8010407b <exit+0x32>
    }
  }

  begin_op();
801040c0:	e8 ac f0 ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
801040c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040c8:	8b 40 68             	mov    0x68(%eax),%eax
801040cb:	83 ec 0c             	sub    $0xc,%esp
801040ce:	50                   	push   %eax
801040cf:	e8 11 db ff ff       	call   80101be5 <iput>
801040d4:	83 c4 10             	add    $0x10,%esp
  end_op();
801040d7:	e8 25 f1 ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
801040dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040df:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801040e6:	83 ec 0c             	sub    $0xc,%esp
801040e9:	68 00 55 19 80       	push   $0x80195500
801040ee:	e8 99 0a 00 00       	call   80104b8c <acquire>
801040f3:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801040f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040f9:	8b 40 14             	mov    0x14(%eax),%eax
801040fc:	83 ec 0c             	sub    $0xc,%esp
801040ff:	50                   	push   %eax
80104100:	e8 e6 06 00 00       	call   801047eb <wakeup1>
80104105:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104108:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010410f:	eb 3a                	jmp    8010414b <exit+0x102>
    if(p->parent == curproc){
80104111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104114:	8b 40 14             	mov    0x14(%eax),%eax
80104117:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010411a:	75 28                	jne    80104144 <exit+0xfb>
      p->parent = initproc;
8010411c:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104125:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412b:	8b 40 0c             	mov    0xc(%eax),%eax
8010412e:	83 f8 05             	cmp    $0x5,%eax
80104131:	75 11                	jne    80104144 <exit+0xfb>
        wakeup1(initproc);
80104133:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104138:	83 ec 0c             	sub    $0xc,%esp
8010413b:	50                   	push   %eax
8010413c:	e8 aa 06 00 00       	call   801047eb <wakeup1>
80104141:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104144:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010414b:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
80104152:	72 bd                	jb     80104111 <exit+0xc8>
    }
  }

  curproc->scheduler = 0; //명시적으로 scheduler 필드를 초기화
80104154:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104157:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
8010415e:	00 00 00 

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104161:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104164:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010416b:	e8 8b 04 00 00       	call   801045fb <sched>
  panic("zombie exit");
80104170:	83 ec 0c             	sub    $0xc,%esp
80104173:	68 df a9 10 80       	push   $0x8010a9df
80104178:	e8 48 c4 ff ff       	call   801005c5 <panic>

8010417d <exit2>:
}

void
exit2(int status)
{
8010417d:	f3 0f 1e fb          	endbr32 
80104181:	55                   	push   %ebp
80104182:	89 e5                	mov    %esp,%ebp
80104184:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104187:	e8 1d fa ff ff       	call   80103ba9 <myproc>
8010418c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010418f:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104194:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104197:	75 0d                	jne    801041a6 <exit2+0x29>
    panic("init exiting");
80104199:	83 ec 0c             	sub    $0xc,%esp
8010419c:	68 d2 a9 10 80       	push   $0x8010a9d2
801041a1:	e8 1f c4 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801041a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801041ad:	eb 3f                	jmp    801041ee <exit2+0x71>
    if(curproc->ofile[fd]){
801041af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041b5:	83 c2 08             	add    $0x8,%edx
801041b8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041bc:	85 c0                	test   %eax,%eax
801041be:	74 2a                	je     801041ea <exit2+0x6d>
      fileclose(curproc->ofile[fd]);
801041c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041c6:	83 c2 08             	add    $0x8,%edx
801041c9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041cd:	83 ec 0c             	sub    $0xc,%esp
801041d0:	50                   	push   %eax
801041d1:	e8 13 cf ff ff       	call   801010e9 <fileclose>
801041d6:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801041d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041df:	83 c2 08             	add    $0x8,%edx
801041e2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801041e9:	00 
  for(fd = 0; fd < NOFILE; fd++){
801041ea:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801041ee:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801041f2:	7e bb                	jle    801041af <exit2+0x32>
    }
  }

  begin_op();
801041f4:	e8 78 ef ff ff       	call   80103171 <begin_op>
  iput(curproc->cwd);
801041f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041fc:	8b 40 68             	mov    0x68(%eax),%eax
801041ff:	83 ec 0c             	sub    $0xc,%esp
80104202:	50                   	push   %eax
80104203:	e8 dd d9 ff ff       	call   80101be5 <iput>
80104208:	83 c4 10             	add    $0x10,%esp
  end_op();
8010420b:	e8 f1 ef ff ff       	call   80103201 <end_op>
  curproc->cwd = 0;
80104210:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104213:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010421a:	83 ec 0c             	sub    $0xc,%esp
8010421d:	68 00 55 19 80       	push   $0x80195500
80104222:	e8 65 09 00 00       	call   80104b8c <acquire>
80104227:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010422a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010422d:	8b 40 14             	mov    0x14(%eax),%eax
80104230:	83 ec 0c             	sub    $0xc,%esp
80104233:	50                   	push   %eax
80104234:	e8 b2 05 00 00       	call   801047eb <wakeup1>
80104239:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010423c:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104243:	eb 3a                	jmp    8010427f <exit2+0x102>
    if(p->parent == curproc){
80104245:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104248:	8b 40 14             	mov    0x14(%eax),%eax
8010424b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010424e:	75 28                	jne    80104278 <exit2+0xfb>
      p->parent = initproc;
80104250:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104259:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010425c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425f:	8b 40 0c             	mov    0xc(%eax),%eax
80104262:	83 f8 05             	cmp    $0x5,%eax
80104265:	75 11                	jne    80104278 <exit2+0xfb>
        wakeup1(initproc);
80104267:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
8010426c:	83 ec 0c             	sub    $0xc,%esp
8010426f:	50                   	push   %eax
80104270:	e8 76 05 00 00       	call   801047eb <wakeup1>
80104275:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104278:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010427f:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
80104286:	72 bd                	jb     80104245 <exit2+0xc8>
    }
  }

  // Set exit status and become a zombie.
  curproc->xstate = status; // Save the exit status
80104288:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010428b:	8b 55 08             	mov    0x8(%ebp),%edx
8010428e:	89 50 7c             	mov    %edx,0x7c(%eax)

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104291:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104294:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010429b:	e8 5b 03 00 00       	call   801045fb <sched>
  panic("zombie exit");
801042a0:	83 ec 0c             	sub    $0xc,%esp
801042a3:	68 df a9 10 80       	push   $0x8010a9df
801042a8:	e8 18 c3 ff ff       	call   801005c5 <panic>

801042ad <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801042ad:	f3 0f 1e fb          	endbr32 
801042b1:	55                   	push   %ebp
801042b2:	89 e5                	mov    %esp,%ebp
801042b4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801042b7:	e8 ed f8 ff ff       	call   80103ba9 <myproc>
801042bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801042bf:	83 ec 0c             	sub    $0xc,%esp
801042c2:	68 00 55 19 80       	push   $0x80195500
801042c7:	e8 c0 08 00 00       	call   80104b8c <acquire>
801042cc:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801042cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042d6:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801042dd:	e9 a4 00 00 00       	jmp    80104386 <wait+0xd9>
      if(p->parent != curproc)
801042e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e5:	8b 40 14             	mov    0x14(%eax),%eax
801042e8:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801042eb:	0f 85 8d 00 00 00    	jne    8010437e <wait+0xd1>
        continue;
      havekids = 1;
801042f1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801042f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fb:	8b 40 0c             	mov    0xc(%eax),%eax
801042fe:	83 f8 05             	cmp    $0x5,%eax
80104301:	75 7c                	jne    8010437f <wait+0xd2>
        // Found one.
        pid = p->pid;
80104303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104306:	8b 40 10             	mov    0x10(%eax),%eax
80104309:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430f:	8b 40 08             	mov    0x8(%eax),%eax
80104312:	83 ec 0c             	sub    $0xc,%esp
80104315:	50                   	push   %eax
80104316:	e8 d9 e4 ff ff       	call   801027f4 <kfree>
8010431b:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010431e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104321:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432b:	8b 40 04             	mov    0x4(%eax),%eax
8010432e:	83 ec 0c             	sub    $0xc,%esp
80104331:	50                   	push   %eax
80104332:	e8 6e 3b 00 00       	call   80107ea5 <freevm>
80104337:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010433a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104347:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010434e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104351:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104358:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010435f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104362:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104369:	83 ec 0c             	sub    $0xc,%esp
8010436c:	68 00 55 19 80       	push   $0x80195500
80104371:	e8 88 08 00 00       	call   80104bfe <release>
80104376:	83 c4 10             	add    $0x10,%esp
        return pid;
80104379:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010437c:	eb 54                	jmp    801043d2 <wait+0x125>
        continue;
8010437e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010437f:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104386:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
8010438d:	0f 82 4f ff ff ff    	jb     801042e2 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104393:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104397:	74 0a                	je     801043a3 <wait+0xf6>
80104399:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010439c:	8b 40 24             	mov    0x24(%eax),%eax
8010439f:	85 c0                	test   %eax,%eax
801043a1:	74 17                	je     801043ba <wait+0x10d>
      release(&ptable.lock);
801043a3:	83 ec 0c             	sub    $0xc,%esp
801043a6:	68 00 55 19 80       	push   $0x80195500
801043ab:	e8 4e 08 00 00       	call   80104bfe <release>
801043b0:	83 c4 10             	add    $0x10,%esp
      return -1;
801043b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b8:	eb 18                	jmp    801043d2 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801043ba:	83 ec 08             	sub    $0x8,%esp
801043bd:	68 00 55 19 80       	push   $0x80195500
801043c2:	ff 75 ec             	pushl  -0x14(%ebp)
801043c5:	e8 76 03 00 00       	call   80104740 <sleep>
801043ca:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801043cd:	e9 fd fe ff ff       	jmp    801042cf <wait+0x22>
  }
}
801043d2:	c9                   	leave  
801043d3:	c3                   	ret    

801043d4 <wait2>:

int
wait2(int *status) {
801043d4:	f3 0f 1e fb          	endbr32 
801043d8:	55                   	push   %ebp
801043d9:	89 e5                	mov    %esp,%ebp
801043db:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801043de:	e8 c6 f7 ff ff       	call   80103ba9 <myproc>
801043e3:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
801043e6:	83 ec 0c             	sub    $0xc,%esp
801043e9:	68 00 55 19 80       	push   $0x80195500
801043ee:	e8 99 07 00 00       	call   80104b8c <acquire>
801043f3:	83 c4 10             	add    $0x10,%esp
  for(;;) {
    // Scan through table looking for zombie children.
    havekids = 0;
801043f6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801043fd:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104404:	e9 e5 00 00 00       	jmp    801044ee <wait2+0x11a>
      if(p->parent != curproc)
80104409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440c:	8b 40 14             	mov    0x14(%eax),%eax
8010440f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104412:	0f 85 ce 00 00 00    	jne    801044e6 <wait2+0x112>
        continue;
      havekids = 1;
80104418:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE) {
8010441f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104422:	8b 40 0c             	mov    0xc(%eax),%eax
80104425:	83 f8 05             	cmp    $0x5,%eax
80104428:	0f 85 b9 00 00 00    	jne    801044e7 <wait2+0x113>
        // Found one.
        pid = p->pid;
8010442e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104431:	8b 40 10             	mov    0x10(%eax),%eax
80104434:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443a:	8b 40 08             	mov    0x8(%eax),%eax
8010443d:	83 ec 0c             	sub    $0xc,%esp
80104440:	50                   	push   %eax
80104441:	e8 ae e3 ff ff       	call   801027f4 <kfree>
80104446:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104456:	8b 40 04             	mov    0x4(%eax),%eax
80104459:	83 ec 0c             	sub    $0xc,%esp
8010445c:	50                   	push   %eax
8010445d:	e8 43 3a 00 00       	call   80107ea5 <freevm>
80104462:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104468:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010446f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104472:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447c:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104483:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        if(status != 0 && copyout(curproc->pgdir, (uint)status, &p->xstate, sizeof(p->xstate)) < 0) {
8010448a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010448e:	74 37                	je     801044c7 <wait2+0xf3>
80104490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104493:	8d 48 7c             	lea    0x7c(%eax),%ecx
80104496:	8b 55 08             	mov    0x8(%ebp),%edx
80104499:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010449c:	8b 40 04             	mov    0x4(%eax),%eax
8010449f:	6a 04                	push   $0x4
801044a1:	51                   	push   %ecx
801044a2:	52                   	push   %edx
801044a3:	50                   	push   %eax
801044a4:	e8 44 3c 00 00       	call   801080ed <copyout>
801044a9:	83 c4 10             	add    $0x10,%esp
801044ac:	85 c0                	test   %eax,%eax
801044ae:	79 17                	jns    801044c7 <wait2+0xf3>
          release(&ptable.lock);
801044b0:	83 ec 0c             	sub    $0xc,%esp
801044b3:	68 00 55 19 80       	push   $0x80195500
801044b8:	e8 41 07 00 00       	call   80104bfe <release>
801044bd:	83 c4 10             	add    $0x10,%esp
          return -1;
801044c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044c5:	eb 73                	jmp    8010453a <wait2+0x166>
        }
        p->state = UNUSED;
801044c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ca:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801044d1:	83 ec 0c             	sub    $0xc,%esp
801044d4:	68 00 55 19 80       	push   $0x80195500
801044d9:	e8 20 07 00 00       	call   80104bfe <release>
801044de:	83 c4 10             	add    $0x10,%esp
        return pid;
801044e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044e4:	eb 54                	jmp    8010453a <wait2+0x166>
        continue;
801044e6:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801044e7:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801044ee:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
801044f5:	0f 82 0e ff ff ff    	jb     80104409 <wait2+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed) {
801044fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801044ff:	74 0a                	je     8010450b <wait2+0x137>
80104501:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104504:	8b 40 24             	mov    0x24(%eax),%eax
80104507:	85 c0                	test   %eax,%eax
80104509:	74 17                	je     80104522 <wait2+0x14e>
      release(&ptable.lock);
8010450b:	83 ec 0c             	sub    $0xc,%esp
8010450e:	68 00 55 19 80       	push   $0x80195500
80104513:	e8 e6 06 00 00       	call   80104bfe <release>
80104518:	83 c4 10             	add    $0x10,%esp
      return -1;
8010451b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104520:	eb 18                	jmp    8010453a <wait2+0x166>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  // DOC: wait-sleep
80104522:	83 ec 08             	sub    $0x8,%esp
80104525:	68 00 55 19 80       	push   $0x80195500
8010452a:	ff 75 ec             	pushl  -0x14(%ebp)
8010452d:	e8 0e 02 00 00       	call   80104740 <sleep>
80104532:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104535:	e9 bc fe ff ff       	jmp    801043f6 <wait2+0x22>
  }
}
8010453a:	c9                   	leave  
8010453b:	c3                   	ret    

8010453c <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010453c:	f3 0f 1e fb          	endbr32 
80104540:	55                   	push   %ebp
80104541:	89 e5                	mov    %esp,%ebp
80104543:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104546:	e8 e2 f5 ff ff       	call   80103b2d <mycpu>
8010454b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
8010454e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104551:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104558:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010455b:	e8 85 f5 ff ff       	call   80103ae5 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104560:	83 ec 0c             	sub    $0xc,%esp
80104563:	68 00 55 19 80       	push   $0x80195500
80104568:	e8 1f 06 00 00       	call   80104b8c <acquire>
8010456d:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104570:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104577:	eb 64                	jmp    801045dd <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457c:	8b 40 0c             	mov    0xc(%eax),%eax
8010457f:	83 f8 03             	cmp    $0x3,%eax
80104582:	75 51                	jne    801045d5 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104587:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010458a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104590:	83 ec 0c             	sub    $0xc,%esp
80104593:	ff 75 f4             	pushl  -0xc(%ebp)
80104596:	e8 51 34 00 00       	call   801079ec <switchuvm>
8010459b:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010459e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a1:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801045a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ab:	8b 40 1c             	mov    0x1c(%eax),%eax
801045ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045b1:	83 c2 04             	add    $0x4,%edx
801045b4:	83 ec 08             	sub    $0x8,%esp
801045b7:	50                   	push   %eax
801045b8:	52                   	push   %edx
801045b9:	e8 f1 0a 00 00       	call   801050af <swtch>
801045be:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801045c1:	e8 09 34 00 00       	call   801079cf <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801045c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045c9:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045d0:	00 00 00 
801045d3:	eb 01                	jmp    801045d6 <scheduler+0x9a>
        continue;
801045d5:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045d6:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801045dd:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
801045e4:	72 93                	jb     80104579 <scheduler+0x3d>
    }
    release(&ptable.lock);
801045e6:	83 ec 0c             	sub    $0xc,%esp
801045e9:	68 00 55 19 80       	push   $0x80195500
801045ee:	e8 0b 06 00 00       	call   80104bfe <release>
801045f3:	83 c4 10             	add    $0x10,%esp
    sti();
801045f6:	e9 60 ff ff ff       	jmp    8010455b <scheduler+0x1f>

801045fb <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801045fb:	f3 0f 1e fb          	endbr32 
801045ff:	55                   	push   %ebp
80104600:	89 e5                	mov    %esp,%ebp
80104602:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104605:	e8 9f f5 ff ff       	call   80103ba9 <myproc>
8010460a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
8010460d:	83 ec 0c             	sub    $0xc,%esp
80104610:	68 00 55 19 80       	push   $0x80195500
80104615:	e8 b9 06 00 00       	call   80104cd3 <holding>
8010461a:	83 c4 10             	add    $0x10,%esp
8010461d:	85 c0                	test   %eax,%eax
8010461f:	75 0d                	jne    8010462e <sched+0x33>
    panic("sched ptable.lock");
80104621:	83 ec 0c             	sub    $0xc,%esp
80104624:	68 eb a9 10 80       	push   $0x8010a9eb
80104629:	e8 97 bf ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
8010462e:	e8 fa f4 ff ff       	call   80103b2d <mycpu>
80104633:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104639:	83 f8 01             	cmp    $0x1,%eax
8010463c:	74 0d                	je     8010464b <sched+0x50>
    panic("sched locks");
8010463e:	83 ec 0c             	sub    $0xc,%esp
80104641:	68 fd a9 10 80       	push   $0x8010a9fd
80104646:	e8 7a bf ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
8010464b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464e:	8b 40 0c             	mov    0xc(%eax),%eax
80104651:	83 f8 04             	cmp    $0x4,%eax
80104654:	75 0d                	jne    80104663 <sched+0x68>
    panic("sched running");
80104656:	83 ec 0c             	sub    $0xc,%esp
80104659:	68 09 aa 10 80       	push   $0x8010aa09
8010465e:	e8 62 bf ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
80104663:	e8 6d f4 ff ff       	call   80103ad5 <readeflags>
80104668:	25 00 02 00 00       	and    $0x200,%eax
8010466d:	85 c0                	test   %eax,%eax
8010466f:	74 0d                	je     8010467e <sched+0x83>
    panic("sched interruptible");
80104671:	83 ec 0c             	sub    $0xc,%esp
80104674:	68 17 aa 10 80       	push   $0x8010aa17
80104679:	e8 47 bf ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
8010467e:	e8 aa f4 ff ff       	call   80103b2d <mycpu>
80104683:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104689:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010468c:	e8 9c f4 ff ff       	call   80103b2d <mycpu>
80104691:	8b 40 04             	mov    0x4(%eax),%eax
80104694:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104697:	83 c2 1c             	add    $0x1c,%edx
8010469a:	83 ec 08             	sub    $0x8,%esp
8010469d:	50                   	push   %eax
8010469e:	52                   	push   %edx
8010469f:	e8 0b 0a 00 00       	call   801050af <swtch>
801046a4:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801046a7:	e8 81 f4 ff ff       	call   80103b2d <mycpu>
801046ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046af:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801046b5:	90                   	nop
801046b6:	c9                   	leave  
801046b7:	c3                   	ret    

801046b8 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801046b8:	f3 0f 1e fb          	endbr32 
801046bc:	55                   	push   %ebp
801046bd:	89 e5                	mov    %esp,%ebp
801046bf:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801046c2:	83 ec 0c             	sub    $0xc,%esp
801046c5:	68 00 55 19 80       	push   $0x80195500
801046ca:	e8 bd 04 00 00       	call   80104b8c <acquire>
801046cf:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801046d2:	e8 d2 f4 ff ff       	call   80103ba9 <myproc>
801046d7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801046de:	e8 18 ff ff ff       	call   801045fb <sched>
  release(&ptable.lock);
801046e3:	83 ec 0c             	sub    $0xc,%esp
801046e6:	68 00 55 19 80       	push   $0x80195500
801046eb:	e8 0e 05 00 00       	call   80104bfe <release>
801046f0:	83 c4 10             	add    $0x10,%esp
}
801046f3:	90                   	nop
801046f4:	c9                   	leave  
801046f5:	c3                   	ret    

801046f6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801046f6:	f3 0f 1e fb          	endbr32 
801046fa:	55                   	push   %ebp
801046fb:	89 e5                	mov    %esp,%ebp
801046fd:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104700:	83 ec 0c             	sub    $0xc,%esp
80104703:	68 00 55 19 80       	push   $0x80195500
80104708:	e8 f1 04 00 00       	call   80104bfe <release>
8010470d:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104710:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104715:	85 c0                	test   %eax,%eax
80104717:	74 24                	je     8010473d <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104719:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104720:	00 00 00 
    iinit(ROOTDEV);
80104723:	83 ec 0c             	sub    $0xc,%esp
80104726:	6a 01                	push   $0x1
80104728:	e8 c9 cf ff ff       	call   801016f6 <iinit>
8010472d:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104730:	83 ec 0c             	sub    $0xc,%esp
80104733:	6a 01                	push   $0x1
80104735:	e8 04 e8 ff ff       	call   80102f3e <initlog>
8010473a:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010473d:	90                   	nop
8010473e:	c9                   	leave  
8010473f:	c3                   	ret    

80104740 <sleep>:

// Atomically release lock and sleep on chan.ld: trap.o: in function `trap':
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104740:	f3 0f 1e fb          	endbr32 
80104744:	55                   	push   %ebp
80104745:	89 e5                	mov    %esp,%ebp
80104747:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010474a:	e8 5a f4 ff ff       	call   80103ba9 <myproc>
8010474f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104752:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104756:	75 0d                	jne    80104765 <sleep+0x25>
    panic("sleep");
80104758:	83 ec 0c             	sub    $0xc,%esp
8010475b:	68 2b aa 10 80       	push   $0x8010aa2b
80104760:	e8 60 be ff ff       	call   801005c5 <panic>

  if(lk == 0)
80104765:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104769:	75 0d                	jne    80104778 <sleep+0x38>
    panic("sleep without lk");
8010476b:	83 ec 0c             	sub    $0xc,%esp
8010476e:	68 31 aa 10 80       	push   $0x8010aa31
80104773:	e8 4d be ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104778:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
8010477f:	74 1e                	je     8010479f <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104781:	83 ec 0c             	sub    $0xc,%esp
80104784:	68 00 55 19 80       	push   $0x80195500
80104789:	e8 fe 03 00 00       	call   80104b8c <acquire>
8010478e:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104791:	83 ec 0c             	sub    $0xc,%esp
80104794:	ff 75 0c             	pushl  0xc(%ebp)
80104797:	e8 62 04 00 00       	call   80104bfe <release>
8010479c:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010479f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a2:	8b 55 08             	mov    0x8(%ebp),%edx
801047a5:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801047a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ab:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801047b2:	e8 44 fe ff ff       	call   801045fb <sched>

  // Tidy up.
  p->chan = 0;
801047b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ba:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801047c1:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801047c8:	74 1e                	je     801047e8 <sleep+0xa8>
    release(&ptable.lock);
801047ca:	83 ec 0c             	sub    $0xc,%esp
801047cd:	68 00 55 19 80       	push   $0x80195500
801047d2:	e8 27 04 00 00       	call   80104bfe <release>
801047d7:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801047da:	83 ec 0c             	sub    $0xc,%esp
801047dd:	ff 75 0c             	pushl  0xc(%ebp)
801047e0:	e8 a7 03 00 00       	call   80104b8c <acquire>
801047e5:	83 c4 10             	add    $0x10,%esp
  }
}
801047e8:	90                   	nop
801047e9:	c9                   	leave  
801047ea:	c3                   	ret    

801047eb <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801047eb:	f3 0f 1e fb          	endbr32 
801047ef:	55                   	push   %ebp
801047f0:	89 e5                	mov    %esp,%ebp
801047f2:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047f5:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
801047fc:	eb 27                	jmp    80104825 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
801047fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104801:	8b 40 0c             	mov    0xc(%eax),%eax
80104804:	83 f8 02             	cmp    $0x2,%eax
80104807:	75 15                	jne    8010481e <wakeup1+0x33>
80104809:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010480c:	8b 40 20             	mov    0x20(%eax),%eax
8010480f:	39 45 08             	cmp    %eax,0x8(%ebp)
80104812:	75 0a                	jne    8010481e <wakeup1+0x33>
      p->state = RUNNABLE;
80104814:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104817:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010481e:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104825:	81 7d fc 34 76 19 80 	cmpl   $0x80197634,-0x4(%ebp)
8010482c:	72 d0                	jb     801047fe <wakeup1+0x13>
}
8010482e:	90                   	nop
8010482f:	90                   	nop
80104830:	c9                   	leave  
80104831:	c3                   	ret    

80104832 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104832:	f3 0f 1e fb          	endbr32 
80104836:	55                   	push   %ebp
80104837:	89 e5                	mov    %esp,%ebp
80104839:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010483c:	83 ec 0c             	sub    $0xc,%esp
8010483f:	68 00 55 19 80       	push   $0x80195500
80104844:	e8 43 03 00 00       	call   80104b8c <acquire>
80104849:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010484c:	83 ec 0c             	sub    $0xc,%esp
8010484f:	ff 75 08             	pushl  0x8(%ebp)
80104852:	e8 94 ff ff ff       	call   801047eb <wakeup1>
80104857:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010485a:	83 ec 0c             	sub    $0xc,%esp
8010485d:	68 00 55 19 80       	push   $0x80195500
80104862:	e8 97 03 00 00       	call   80104bfe <release>
80104867:	83 c4 10             	add    $0x10,%esp
}
8010486a:	90                   	nop
8010486b:	c9                   	leave  
8010486c:	c3                   	ret    

8010486d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010486d:	f3 0f 1e fb          	endbr32 
80104871:	55                   	push   %ebp
80104872:	89 e5                	mov    %esp,%ebp
80104874:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104877:	83 ec 0c             	sub    $0xc,%esp
8010487a:	68 00 55 19 80       	push   $0x80195500
8010487f:	e8 08 03 00 00       	call   80104b8c <acquire>
80104884:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104887:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010488e:	eb 48                	jmp    801048d8 <kill+0x6b>
    if(p->pid == pid){
80104890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104893:	8b 40 10             	mov    0x10(%eax),%eax
80104896:	39 45 08             	cmp    %eax,0x8(%ebp)
80104899:	75 36                	jne    801048d1 <kill+0x64>
      p->killed = 1;
8010489b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801048a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a8:	8b 40 0c             	mov    0xc(%eax),%eax
801048ab:	83 f8 02             	cmp    $0x2,%eax
801048ae:	75 0a                	jne    801048ba <kill+0x4d>
        p->state = RUNNABLE;
801048b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801048ba:	83 ec 0c             	sub    $0xc,%esp
801048bd:	68 00 55 19 80       	push   $0x80195500
801048c2:	e8 37 03 00 00       	call   80104bfe <release>
801048c7:	83 c4 10             	add    $0x10,%esp
      return 0;
801048ca:	b8 00 00 00 00       	mov    $0x0,%eax
801048cf:	eb 25                	jmp    801048f6 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048d1:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801048d8:	81 7d f4 34 76 19 80 	cmpl   $0x80197634,-0xc(%ebp)
801048df:	72 af                	jb     80104890 <kill+0x23>
    }
  }
  release(&ptable.lock);
801048e1:	83 ec 0c             	sub    $0xc,%esp
801048e4:	68 00 55 19 80       	push   $0x80195500
801048e9:	e8 10 03 00 00       	call   80104bfe <release>
801048ee:	83 c4 10             	add    $0x10,%esp
  return -1;
801048f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801048f6:	c9                   	leave  
801048f7:	c3                   	ret    

801048f8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801048f8:	f3 0f 1e fb          	endbr32 
801048fc:	55                   	push   %ebp
801048fd:	89 e5                	mov    %esp,%ebp
801048ff:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104902:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
80104909:	e9 da 00 00 00       	jmp    801049e8 <procdump+0xf0>
    if(p->state == UNUSED)
8010490e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104911:	8b 40 0c             	mov    0xc(%eax),%eax
80104914:	85 c0                	test   %eax,%eax
80104916:	0f 84 c4 00 00 00    	je     801049e0 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010491c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010491f:	8b 40 0c             	mov    0xc(%eax),%eax
80104922:	83 f8 05             	cmp    $0x5,%eax
80104925:	77 23                	ja     8010494a <procdump+0x52>
80104927:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010492a:	8b 40 0c             	mov    0xc(%eax),%eax
8010492d:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104934:	85 c0                	test   %eax,%eax
80104936:	74 12                	je     8010494a <procdump+0x52>
      state = states[p->state];
80104938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010493b:	8b 40 0c             	mov    0xc(%eax),%eax
8010493e:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104945:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104948:	eb 07                	jmp    80104951 <procdump+0x59>
    else
      state = "???";
8010494a:	c7 45 ec 42 aa 10 80 	movl   $0x8010aa42,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104951:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104954:	8d 50 6c             	lea    0x6c(%eax),%edx
80104957:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010495a:	8b 40 10             	mov    0x10(%eax),%eax
8010495d:	52                   	push   %edx
8010495e:	ff 75 ec             	pushl  -0x14(%ebp)
80104961:	50                   	push   %eax
80104962:	68 46 aa 10 80       	push   $0x8010aa46
80104967:	e8 a0 ba ff ff       	call   8010040c <cprintf>
8010496c:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010496f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104972:	8b 40 0c             	mov    0xc(%eax),%eax
80104975:	83 f8 02             	cmp    $0x2,%eax
80104978:	75 54                	jne    801049ce <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010497a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010497d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104980:	8b 40 0c             	mov    0xc(%eax),%eax
80104983:	83 c0 08             	add    $0x8,%eax
80104986:	89 c2                	mov    %eax,%edx
80104988:	83 ec 08             	sub    $0x8,%esp
8010498b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010498e:	50                   	push   %eax
8010498f:	52                   	push   %edx
80104990:	e8 bf 02 00 00       	call   80104c54 <getcallerpcs>
80104995:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104998:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010499f:	eb 1c                	jmp    801049bd <procdump+0xc5>
        cprintf(" %p", pc[i]);
801049a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a4:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801049a8:	83 ec 08             	sub    $0x8,%esp
801049ab:	50                   	push   %eax
801049ac:	68 4f aa 10 80       	push   $0x8010aa4f
801049b1:	e8 56 ba ff ff       	call   8010040c <cprintf>
801049b6:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801049b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801049bd:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801049c1:	7f 0b                	jg     801049ce <procdump+0xd6>
801049c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801049ca:	85 c0                	test   %eax,%eax
801049cc:	75 d3                	jne    801049a1 <procdump+0xa9>
    }
    cprintf("\n");
801049ce:	83 ec 0c             	sub    $0xc,%esp
801049d1:	68 53 aa 10 80       	push   $0x8010aa53
801049d6:	e8 31 ba ff ff       	call   8010040c <cprintf>
801049db:	83 c4 10             	add    $0x10,%esp
801049de:	eb 01                	jmp    801049e1 <procdump+0xe9>
      continue;
801049e0:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e1:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
801049e8:	81 7d f0 34 76 19 80 	cmpl   $0x80197634,-0x10(%ebp)
801049ef:	0f 82 19 ff ff ff    	jb     8010490e <procdump+0x16>
  }
}
801049f5:	90                   	nop
801049f6:	90                   	nop
801049f7:	c9                   	leave  
801049f8:	c3                   	ret    

801049f9 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801049f9:	f3 0f 1e fb          	endbr32 
801049fd:	55                   	push   %ebp
801049fe:	89 e5                	mov    %esp,%ebp
80104a00:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a03:	8b 45 08             	mov    0x8(%ebp),%eax
80104a06:	83 c0 04             	add    $0x4,%eax
80104a09:	83 ec 08             	sub    $0x8,%esp
80104a0c:	68 7f aa 10 80       	push   $0x8010aa7f
80104a11:	50                   	push   %eax
80104a12:	e8 4f 01 00 00       	call   80104b66 <initlock>
80104a17:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104a20:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104a23:	8b 45 08             	mov    0x8(%ebp),%eax
80104a26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a2f:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104a36:	90                   	nop
80104a37:	c9                   	leave  
80104a38:	c3                   	ret    

80104a39 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104a39:	f3 0f 1e fb          	endbr32 
80104a3d:	55                   	push   %ebp
80104a3e:	89 e5                	mov    %esp,%ebp
80104a40:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104a43:	8b 45 08             	mov    0x8(%ebp),%eax
80104a46:	83 c0 04             	add    $0x4,%eax
80104a49:	83 ec 0c             	sub    $0xc,%esp
80104a4c:	50                   	push   %eax
80104a4d:	e8 3a 01 00 00       	call   80104b8c <acquire>
80104a52:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a55:	eb 15                	jmp    80104a6c <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104a57:	8b 45 08             	mov    0x8(%ebp),%eax
80104a5a:	83 c0 04             	add    $0x4,%eax
80104a5d:	83 ec 08             	sub    $0x8,%esp
80104a60:	50                   	push   %eax
80104a61:	ff 75 08             	pushl  0x8(%ebp)
80104a64:	e8 d7 fc ff ff       	call   80104740 <sleep>
80104a69:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a6f:	8b 00                	mov    (%eax),%eax
80104a71:	85 c0                	test   %eax,%eax
80104a73:	75 e2                	jne    80104a57 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104a75:	8b 45 08             	mov    0x8(%ebp),%eax
80104a78:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104a7e:	e8 26 f1 ff ff       	call   80103ba9 <myproc>
80104a83:	8b 50 10             	mov    0x10(%eax),%edx
80104a86:	8b 45 08             	mov    0x8(%ebp),%eax
80104a89:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104a8c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8f:	83 c0 04             	add    $0x4,%eax
80104a92:	83 ec 0c             	sub    $0xc,%esp
80104a95:	50                   	push   %eax
80104a96:	e8 63 01 00 00       	call   80104bfe <release>
80104a9b:	83 c4 10             	add    $0x10,%esp
}
80104a9e:	90                   	nop
80104a9f:	c9                   	leave  
80104aa0:	c3                   	ret    

80104aa1 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104aa1:	f3 0f 1e fb          	endbr32 
80104aa5:	55                   	push   %ebp
80104aa6:	89 e5                	mov    %esp,%ebp
80104aa8:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104aab:	8b 45 08             	mov    0x8(%ebp),%eax
80104aae:	83 c0 04             	add    $0x4,%eax
80104ab1:	83 ec 0c             	sub    $0xc,%esp
80104ab4:	50                   	push   %eax
80104ab5:	e8 d2 00 00 00       	call   80104b8c <acquire>
80104aba:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104abd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104ad0:	83 ec 0c             	sub    $0xc,%esp
80104ad3:	ff 75 08             	pushl  0x8(%ebp)
80104ad6:	e8 57 fd ff ff       	call   80104832 <wakeup>
80104adb:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104ade:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae1:	83 c0 04             	add    $0x4,%eax
80104ae4:	83 ec 0c             	sub    $0xc,%esp
80104ae7:	50                   	push   %eax
80104ae8:	e8 11 01 00 00       	call   80104bfe <release>
80104aed:	83 c4 10             	add    $0x10,%esp
}
80104af0:	90                   	nop
80104af1:	c9                   	leave  
80104af2:	c3                   	ret    

80104af3 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104af3:	f3 0f 1e fb          	endbr32 
80104af7:	55                   	push   %ebp
80104af8:	89 e5                	mov    %esp,%ebp
80104afa:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104afd:	8b 45 08             	mov    0x8(%ebp),%eax
80104b00:	83 c0 04             	add    $0x4,%eax
80104b03:	83 ec 0c             	sub    $0xc,%esp
80104b06:	50                   	push   %eax
80104b07:	e8 80 00 00 00       	call   80104b8c <acquire>
80104b0c:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b12:	8b 00                	mov    (%eax),%eax
80104b14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b17:	8b 45 08             	mov    0x8(%ebp),%eax
80104b1a:	83 c0 04             	add    $0x4,%eax
80104b1d:	83 ec 0c             	sub    $0xc,%esp
80104b20:	50                   	push   %eax
80104b21:	e8 d8 00 00 00       	call   80104bfe <release>
80104b26:	83 c4 10             	add    $0x10,%esp
  return r;
80104b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104b2c:	c9                   	leave  
80104b2d:	c3                   	ret    

80104b2e <readeflags>:
{
80104b2e:	55                   	push   %ebp
80104b2f:	89 e5                	mov    %esp,%ebp
80104b31:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b34:	9c                   	pushf  
80104b35:	58                   	pop    %eax
80104b36:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b39:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b3c:	c9                   	leave  
80104b3d:	c3                   	ret    

80104b3e <cli>:
{
80104b3e:	55                   	push   %ebp
80104b3f:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104b41:	fa                   	cli    
}
80104b42:	90                   	nop
80104b43:	5d                   	pop    %ebp
80104b44:	c3                   	ret    

80104b45 <sti>:
{
80104b45:	55                   	push   %ebp
80104b46:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b48:	fb                   	sti    
}
80104b49:	90                   	nop
80104b4a:	5d                   	pop    %ebp
80104b4b:	c3                   	ret    

80104b4c <xchg>:
{
80104b4c:	55                   	push   %ebp
80104b4d:	89 e5                	mov    %esp,%ebp
80104b4f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104b52:	8b 55 08             	mov    0x8(%ebp),%edx
80104b55:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104b5b:	f0 87 02             	lock xchg %eax,(%edx)
80104b5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104b61:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b64:	c9                   	leave  
80104b65:	c3                   	ret    

80104b66 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b66:	f3 0f 1e fb          	endbr32 
80104b6a:	55                   	push   %ebp
80104b6b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b70:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b73:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b76:	8b 45 08             	mov    0x8(%ebp),%eax
80104b79:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b82:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b89:	90                   	nop
80104b8a:	5d                   	pop    %ebp
80104b8b:	c3                   	ret    

80104b8c <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b8c:	f3 0f 1e fb          	endbr32 
80104b90:	55                   	push   %ebp
80104b91:	89 e5                	mov    %esp,%ebp
80104b93:	53                   	push   %ebx
80104b94:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b97:	e8 6c 01 00 00       	call   80104d08 <pushcli>
  if(holding(lk)){
80104b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b9f:	83 ec 0c             	sub    $0xc,%esp
80104ba2:	50                   	push   %eax
80104ba3:	e8 2b 01 00 00       	call   80104cd3 <holding>
80104ba8:	83 c4 10             	add    $0x10,%esp
80104bab:	85 c0                	test   %eax,%eax
80104bad:	74 0d                	je     80104bbc <acquire+0x30>
    panic("acquire");
80104baf:	83 ec 0c             	sub    $0xc,%esp
80104bb2:	68 8a aa 10 80       	push   $0x8010aa8a
80104bb7:	e8 09 ba ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104bbc:	90                   	nop
80104bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc0:	83 ec 08             	sub    $0x8,%esp
80104bc3:	6a 01                	push   $0x1
80104bc5:	50                   	push   %eax
80104bc6:	e8 81 ff ff ff       	call   80104b4c <xchg>
80104bcb:	83 c4 10             	add    $0x10,%esp
80104bce:	85 c0                	test   %eax,%eax
80104bd0:	75 eb                	jne    80104bbd <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104bd2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104bd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104bda:	e8 4e ef ff ff       	call   80103b2d <mycpu>
80104bdf:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104be2:	8b 45 08             	mov    0x8(%ebp),%eax
80104be5:	83 c0 0c             	add    $0xc,%eax
80104be8:	83 ec 08             	sub    $0x8,%esp
80104beb:	50                   	push   %eax
80104bec:	8d 45 08             	lea    0x8(%ebp),%eax
80104bef:	50                   	push   %eax
80104bf0:	e8 5f 00 00 00       	call   80104c54 <getcallerpcs>
80104bf5:	83 c4 10             	add    $0x10,%esp
}
80104bf8:	90                   	nop
80104bf9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bfc:	c9                   	leave  
80104bfd:	c3                   	ret    

80104bfe <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104bfe:	f3 0f 1e fb          	endbr32 
80104c02:	55                   	push   %ebp
80104c03:	89 e5                	mov    %esp,%ebp
80104c05:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104c08:	83 ec 0c             	sub    $0xc,%esp
80104c0b:	ff 75 08             	pushl  0x8(%ebp)
80104c0e:	e8 c0 00 00 00       	call   80104cd3 <holding>
80104c13:	83 c4 10             	add    $0x10,%esp
80104c16:	85 c0                	test   %eax,%eax
80104c18:	75 0d                	jne    80104c27 <release+0x29>
    panic("release");
80104c1a:	83 ec 0c             	sub    $0xc,%esp
80104c1d:	68 92 aa 10 80       	push   $0x8010aa92
80104c22:	e8 9e b9 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80104c27:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104c31:	8b 45 08             	mov    0x8(%ebp),%eax
80104c34:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104c3b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104c40:	8b 45 08             	mov    0x8(%ebp),%eax
80104c43:	8b 55 08             	mov    0x8(%ebp),%edx
80104c46:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104c4c:	e8 08 01 00 00       	call   80104d59 <popcli>
}
80104c51:	90                   	nop
80104c52:	c9                   	leave  
80104c53:	c3                   	ret    

80104c54 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104c54:	f3 0f 1e fb          	endbr32 
80104c58:	55                   	push   %ebp
80104c59:	89 e5                	mov    %esp,%ebp
80104c5b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c61:	83 e8 08             	sub    $0x8,%eax
80104c64:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104c67:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104c6e:	eb 38                	jmp    80104ca8 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104c70:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104c74:	74 53                	je     80104cc9 <getcallerpcs+0x75>
80104c76:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c7d:	76 4a                	jbe    80104cc9 <getcallerpcs+0x75>
80104c7f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c83:	74 44                	je     80104cc9 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c85:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c88:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c92:	01 c2                	add    %eax,%edx
80104c94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c97:	8b 40 04             	mov    0x4(%eax),%eax
80104c9a:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c9f:	8b 00                	mov    (%eax),%eax
80104ca1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104ca4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104ca8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104cac:	7e c2                	jle    80104c70 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104cae:	eb 19                	jmp    80104cc9 <getcallerpcs+0x75>
    pcs[i] = 0;
80104cb0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cb3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cba:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cbd:	01 d0                	add    %edx,%eax
80104cbf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104cc5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104cc9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104ccd:	7e e1                	jle    80104cb0 <getcallerpcs+0x5c>
}
80104ccf:	90                   	nop
80104cd0:	90                   	nop
80104cd1:	c9                   	leave  
80104cd2:	c3                   	ret    

80104cd3 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104cd3:	f3 0f 1e fb          	endbr32 
80104cd7:	55                   	push   %ebp
80104cd8:	89 e5                	mov    %esp,%ebp
80104cda:	53                   	push   %ebx
80104cdb:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104cde:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce1:	8b 00                	mov    (%eax),%eax
80104ce3:	85 c0                	test   %eax,%eax
80104ce5:	74 16                	je     80104cfd <holding+0x2a>
80104ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80104cea:	8b 58 08             	mov    0x8(%eax),%ebx
80104ced:	e8 3b ee ff ff       	call   80103b2d <mycpu>
80104cf2:	39 c3                	cmp    %eax,%ebx
80104cf4:	75 07                	jne    80104cfd <holding+0x2a>
80104cf6:	b8 01 00 00 00       	mov    $0x1,%eax
80104cfb:	eb 05                	jmp    80104d02 <holding+0x2f>
80104cfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d02:	83 c4 04             	add    $0x4,%esp
80104d05:	5b                   	pop    %ebx
80104d06:	5d                   	pop    %ebp
80104d07:	c3                   	ret    

80104d08 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104d08:	f3 0f 1e fb          	endbr32 
80104d0c:	55                   	push   %ebp
80104d0d:	89 e5                	mov    %esp,%ebp
80104d0f:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104d12:	e8 17 fe ff ff       	call   80104b2e <readeflags>
80104d17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d1a:	e8 1f fe ff ff       	call   80104b3e <cli>
  if(mycpu()->ncli == 0)
80104d1f:	e8 09 ee ff ff       	call   80103b2d <mycpu>
80104d24:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d2a:	85 c0                	test   %eax,%eax
80104d2c:	75 14                	jne    80104d42 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104d2e:	e8 fa ed ff ff       	call   80103b2d <mycpu>
80104d33:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d36:	81 e2 00 02 00 00    	and    $0x200,%edx
80104d3c:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104d42:	e8 e6 ed ff ff       	call   80103b2d <mycpu>
80104d47:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d4d:	83 c2 01             	add    $0x1,%edx
80104d50:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104d56:	90                   	nop
80104d57:	c9                   	leave  
80104d58:	c3                   	ret    

80104d59 <popcli>:

void
popcli(void)
{
80104d59:	f3 0f 1e fb          	endbr32 
80104d5d:	55                   	push   %ebp
80104d5e:	89 e5                	mov    %esp,%ebp
80104d60:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104d63:	e8 c6 fd ff ff       	call   80104b2e <readeflags>
80104d68:	25 00 02 00 00       	and    $0x200,%eax
80104d6d:	85 c0                	test   %eax,%eax
80104d6f:	74 0d                	je     80104d7e <popcli+0x25>
    panic("popcli - interruptible");
80104d71:	83 ec 0c             	sub    $0xc,%esp
80104d74:	68 9a aa 10 80       	push   $0x8010aa9a
80104d79:	e8 47 b8 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104d7e:	e8 aa ed ff ff       	call   80103b2d <mycpu>
80104d83:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104d89:	83 ea 01             	sub    $0x1,%edx
80104d8c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104d92:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d98:	85 c0                	test   %eax,%eax
80104d9a:	79 0d                	jns    80104da9 <popcli+0x50>
    panic("popcli");
80104d9c:	83 ec 0c             	sub    $0xc,%esp
80104d9f:	68 b1 aa 10 80       	push   $0x8010aab1
80104da4:	e8 1c b8 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104da9:	e8 7f ed ff ff       	call   80103b2d <mycpu>
80104dae:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104db4:	85 c0                	test   %eax,%eax
80104db6:	75 14                	jne    80104dcc <popcli+0x73>
80104db8:	e8 70 ed ff ff       	call   80103b2d <mycpu>
80104dbd:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104dc3:	85 c0                	test   %eax,%eax
80104dc5:	74 05                	je     80104dcc <popcli+0x73>
    sti();
80104dc7:	e8 79 fd ff ff       	call   80104b45 <sti>
}
80104dcc:	90                   	nop
80104dcd:	c9                   	leave  
80104dce:	c3                   	ret    

80104dcf <stosb>:
{
80104dcf:	55                   	push   %ebp
80104dd0:	89 e5                	mov    %esp,%ebp
80104dd2:	57                   	push   %edi
80104dd3:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104dd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104dd7:	8b 55 10             	mov    0x10(%ebp),%edx
80104dda:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ddd:	89 cb                	mov    %ecx,%ebx
80104ddf:	89 df                	mov    %ebx,%edi
80104de1:	89 d1                	mov    %edx,%ecx
80104de3:	fc                   	cld    
80104de4:	f3 aa                	rep stos %al,%es:(%edi)
80104de6:	89 ca                	mov    %ecx,%edx
80104de8:	89 fb                	mov    %edi,%ebx
80104dea:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104ded:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104df0:	90                   	nop
80104df1:	5b                   	pop    %ebx
80104df2:	5f                   	pop    %edi
80104df3:	5d                   	pop    %ebp
80104df4:	c3                   	ret    

80104df5 <stosl>:
{
80104df5:	55                   	push   %ebp
80104df6:	89 e5                	mov    %esp,%ebp
80104df8:	57                   	push   %edi
80104df9:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104dfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104dfd:	8b 55 10             	mov    0x10(%ebp),%edx
80104e00:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e03:	89 cb                	mov    %ecx,%ebx
80104e05:	89 df                	mov    %ebx,%edi
80104e07:	89 d1                	mov    %edx,%ecx
80104e09:	fc                   	cld    
80104e0a:	f3 ab                	rep stos %eax,%es:(%edi)
80104e0c:	89 ca                	mov    %ecx,%edx
80104e0e:	89 fb                	mov    %edi,%ebx
80104e10:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e13:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e16:	90                   	nop
80104e17:	5b                   	pop    %ebx
80104e18:	5f                   	pop    %edi
80104e19:	5d                   	pop    %ebp
80104e1a:	c3                   	ret    

80104e1b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e1b:	f3 0f 1e fb          	endbr32 
80104e1f:	55                   	push   %ebp
80104e20:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e22:	8b 45 08             	mov    0x8(%ebp),%eax
80104e25:	83 e0 03             	and    $0x3,%eax
80104e28:	85 c0                	test   %eax,%eax
80104e2a:	75 43                	jne    80104e6f <memset+0x54>
80104e2c:	8b 45 10             	mov    0x10(%ebp),%eax
80104e2f:	83 e0 03             	and    $0x3,%eax
80104e32:	85 c0                	test   %eax,%eax
80104e34:	75 39                	jne    80104e6f <memset+0x54>
    c &= 0xFF;
80104e36:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e3d:	8b 45 10             	mov    0x10(%ebp),%eax
80104e40:	c1 e8 02             	shr    $0x2,%eax
80104e43:	89 c1                	mov    %eax,%ecx
80104e45:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e48:	c1 e0 18             	shl    $0x18,%eax
80104e4b:	89 c2                	mov    %eax,%edx
80104e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e50:	c1 e0 10             	shl    $0x10,%eax
80104e53:	09 c2                	or     %eax,%edx
80104e55:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e58:	c1 e0 08             	shl    $0x8,%eax
80104e5b:	09 d0                	or     %edx,%eax
80104e5d:	0b 45 0c             	or     0xc(%ebp),%eax
80104e60:	51                   	push   %ecx
80104e61:	50                   	push   %eax
80104e62:	ff 75 08             	pushl  0x8(%ebp)
80104e65:	e8 8b ff ff ff       	call   80104df5 <stosl>
80104e6a:	83 c4 0c             	add    $0xc,%esp
80104e6d:	eb 12                	jmp    80104e81 <memset+0x66>
  } else
    stosb(dst, c, n);
80104e6f:	8b 45 10             	mov    0x10(%ebp),%eax
80104e72:	50                   	push   %eax
80104e73:	ff 75 0c             	pushl  0xc(%ebp)
80104e76:	ff 75 08             	pushl  0x8(%ebp)
80104e79:	e8 51 ff ff ff       	call   80104dcf <stosb>
80104e7e:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104e81:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104e84:	c9                   	leave  
80104e85:	c3                   	ret    

80104e86 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104e86:	f3 0f 1e fb          	endbr32 
80104e8a:	55                   	push   %ebp
80104e8b:	89 e5                	mov    %esp,%ebp
80104e8d:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104e90:	8b 45 08             	mov    0x8(%ebp),%eax
80104e93:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e96:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e99:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e9c:	eb 30                	jmp    80104ece <memcmp+0x48>
    if(*s1 != *s2)
80104e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ea1:	0f b6 10             	movzbl (%eax),%edx
80104ea4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ea7:	0f b6 00             	movzbl (%eax),%eax
80104eaa:	38 c2                	cmp    %al,%dl
80104eac:	74 18                	je     80104ec6 <memcmp+0x40>
      return *s1 - *s2;
80104eae:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb1:	0f b6 00             	movzbl (%eax),%eax
80104eb4:	0f b6 d0             	movzbl %al,%edx
80104eb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104eba:	0f b6 00             	movzbl (%eax),%eax
80104ebd:	0f b6 c0             	movzbl %al,%eax
80104ec0:	29 c2                	sub    %eax,%edx
80104ec2:	89 d0                	mov    %edx,%eax
80104ec4:	eb 1a                	jmp    80104ee0 <memcmp+0x5a>
    s1++, s2++;
80104ec6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104eca:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104ece:	8b 45 10             	mov    0x10(%ebp),%eax
80104ed1:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ed4:	89 55 10             	mov    %edx,0x10(%ebp)
80104ed7:	85 c0                	test   %eax,%eax
80104ed9:	75 c3                	jne    80104e9e <memcmp+0x18>
  }

  return 0;
80104edb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ee0:	c9                   	leave  
80104ee1:	c3                   	ret    

80104ee2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ee2:	f3 0f 1e fb          	endbr32 
80104ee6:	55                   	push   %ebp
80104ee7:	89 e5                	mov    %esp,%ebp
80104ee9:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104eec:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ef5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104ef8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104efb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104efe:	73 54                	jae    80104f54 <memmove+0x72>
80104f00:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f03:	8b 45 10             	mov    0x10(%ebp),%eax
80104f06:	01 d0                	add    %edx,%eax
80104f08:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104f0b:	73 47                	jae    80104f54 <memmove+0x72>
    s += n;
80104f0d:	8b 45 10             	mov    0x10(%ebp),%eax
80104f10:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104f13:	8b 45 10             	mov    0x10(%ebp),%eax
80104f16:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f19:	eb 13                	jmp    80104f2e <memmove+0x4c>
      *--d = *--s;
80104f1b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f1f:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f26:	0f b6 10             	movzbl (%eax),%edx
80104f29:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f2c:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f2e:	8b 45 10             	mov    0x10(%ebp),%eax
80104f31:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f34:	89 55 10             	mov    %edx,0x10(%ebp)
80104f37:	85 c0                	test   %eax,%eax
80104f39:	75 e0                	jne    80104f1b <memmove+0x39>
  if(s < d && s + n > d){
80104f3b:	eb 24                	jmp    80104f61 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f3d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f40:	8d 42 01             	lea    0x1(%edx),%eax
80104f43:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f46:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f49:	8d 48 01             	lea    0x1(%eax),%ecx
80104f4c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104f4f:	0f b6 12             	movzbl (%edx),%edx
80104f52:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f54:	8b 45 10             	mov    0x10(%ebp),%eax
80104f57:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f5a:	89 55 10             	mov    %edx,0x10(%ebp)
80104f5d:	85 c0                	test   %eax,%eax
80104f5f:	75 dc                	jne    80104f3d <memmove+0x5b>

  return dst;
80104f61:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104f64:	c9                   	leave  
80104f65:	c3                   	ret    

80104f66 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104f66:	f3 0f 1e fb          	endbr32 
80104f6a:	55                   	push   %ebp
80104f6b:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104f6d:	ff 75 10             	pushl  0x10(%ebp)
80104f70:	ff 75 0c             	pushl  0xc(%ebp)
80104f73:	ff 75 08             	pushl  0x8(%ebp)
80104f76:	e8 67 ff ff ff       	call   80104ee2 <memmove>
80104f7b:	83 c4 0c             	add    $0xc,%esp
}
80104f7e:	c9                   	leave  
80104f7f:	c3                   	ret    

80104f80 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104f80:	f3 0f 1e fb          	endbr32 
80104f84:	55                   	push   %ebp
80104f85:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104f87:	eb 0c                	jmp    80104f95 <strncmp+0x15>
    n--, p++, q++;
80104f89:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104f8d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104f91:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104f95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f99:	74 1a                	je     80104fb5 <strncmp+0x35>
80104f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9e:	0f b6 00             	movzbl (%eax),%eax
80104fa1:	84 c0                	test   %al,%al
80104fa3:	74 10                	je     80104fb5 <strncmp+0x35>
80104fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa8:	0f b6 10             	movzbl (%eax),%edx
80104fab:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fae:	0f b6 00             	movzbl (%eax),%eax
80104fb1:	38 c2                	cmp    %al,%dl
80104fb3:	74 d4                	je     80104f89 <strncmp+0x9>
  if(n == 0)
80104fb5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fb9:	75 07                	jne    80104fc2 <strncmp+0x42>
    return 0;
80104fbb:	b8 00 00 00 00       	mov    $0x0,%eax
80104fc0:	eb 16                	jmp    80104fd8 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80104fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc5:	0f b6 00             	movzbl (%eax),%eax
80104fc8:	0f b6 d0             	movzbl %al,%edx
80104fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fce:	0f b6 00             	movzbl (%eax),%eax
80104fd1:	0f b6 c0             	movzbl %al,%eax
80104fd4:	29 c2                	sub    %eax,%edx
80104fd6:	89 d0                	mov    %edx,%eax
}
80104fd8:	5d                   	pop    %ebp
80104fd9:	c3                   	ret    

80104fda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104fda:	f3 0f 1e fb          	endbr32 
80104fde:	55                   	push   %ebp
80104fdf:	89 e5                	mov    %esp,%ebp
80104fe1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104fea:	90                   	nop
80104feb:	8b 45 10             	mov    0x10(%ebp),%eax
80104fee:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ff1:	89 55 10             	mov    %edx,0x10(%ebp)
80104ff4:	85 c0                	test   %eax,%eax
80104ff6:	7e 2c                	jle    80105024 <strncpy+0x4a>
80104ff8:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ffb:	8d 42 01             	lea    0x1(%edx),%eax
80104ffe:	89 45 0c             	mov    %eax,0xc(%ebp)
80105001:	8b 45 08             	mov    0x8(%ebp),%eax
80105004:	8d 48 01             	lea    0x1(%eax),%ecx
80105007:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010500a:	0f b6 12             	movzbl (%edx),%edx
8010500d:	88 10                	mov    %dl,(%eax)
8010500f:	0f b6 00             	movzbl (%eax),%eax
80105012:	84 c0                	test   %al,%al
80105014:	75 d5                	jne    80104feb <strncpy+0x11>
    ;
  while(n-- > 0)
80105016:	eb 0c                	jmp    80105024 <strncpy+0x4a>
    *s++ = 0;
80105018:	8b 45 08             	mov    0x8(%ebp),%eax
8010501b:	8d 50 01             	lea    0x1(%eax),%edx
8010501e:	89 55 08             	mov    %edx,0x8(%ebp)
80105021:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105024:	8b 45 10             	mov    0x10(%ebp),%eax
80105027:	8d 50 ff             	lea    -0x1(%eax),%edx
8010502a:	89 55 10             	mov    %edx,0x10(%ebp)
8010502d:	85 c0                	test   %eax,%eax
8010502f:	7f e7                	jg     80105018 <strncpy+0x3e>
  return os;
80105031:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105034:	c9                   	leave  
80105035:	c3                   	ret    

80105036 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105036:	f3 0f 1e fb          	endbr32 
8010503a:	55                   	push   %ebp
8010503b:	89 e5                	mov    %esp,%ebp
8010503d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105040:	8b 45 08             	mov    0x8(%ebp),%eax
80105043:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105046:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010504a:	7f 05                	jg     80105051 <safestrcpy+0x1b>
    return os;
8010504c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010504f:	eb 31                	jmp    80105082 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105051:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105055:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105059:	7e 1e                	jle    80105079 <safestrcpy+0x43>
8010505b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010505e:	8d 42 01             	lea    0x1(%edx),%eax
80105061:	89 45 0c             	mov    %eax,0xc(%ebp)
80105064:	8b 45 08             	mov    0x8(%ebp),%eax
80105067:	8d 48 01             	lea    0x1(%eax),%ecx
8010506a:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010506d:	0f b6 12             	movzbl (%edx),%edx
80105070:	88 10                	mov    %dl,(%eax)
80105072:	0f b6 00             	movzbl (%eax),%eax
80105075:	84 c0                	test   %al,%al
80105077:	75 d8                	jne    80105051 <safestrcpy+0x1b>
    ;
  *s = 0;
80105079:	8b 45 08             	mov    0x8(%ebp),%eax
8010507c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010507f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105082:	c9                   	leave  
80105083:	c3                   	ret    

80105084 <strlen>:

int
strlen(const char *s)
{
80105084:	f3 0f 1e fb          	endbr32 
80105088:	55                   	push   %ebp
80105089:	89 e5                	mov    %esp,%ebp
8010508b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010508e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105095:	eb 04                	jmp    8010509b <strlen+0x17>
80105097:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010509b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010509e:	8b 45 08             	mov    0x8(%ebp),%eax
801050a1:	01 d0                	add    %edx,%eax
801050a3:	0f b6 00             	movzbl (%eax),%eax
801050a6:	84 c0                	test   %al,%al
801050a8:	75 ed                	jne    80105097 <strlen+0x13>
    ;
  return n;
801050aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050ad:	c9                   	leave  
801050ae:	c3                   	ret    

801050af <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801050af:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801050b3:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801050b7:	55                   	push   %ebp
  pushl %ebx
801050b8:	53                   	push   %ebx
  pushl %esi
801050b9:	56                   	push   %esi
  pushl %edi
801050ba:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801050bb:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801050bd:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801050bf:	5f                   	pop    %edi
  popl %esi
801050c0:	5e                   	pop    %esi
  popl %ebx
801050c1:	5b                   	pop    %ebx
  popl %ebp
801050c2:	5d                   	pop    %ebp
  ret
801050c3:	c3                   	ret    

801050c4 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801050c4:	f3 0f 1e fb          	endbr32 
801050c8:	55                   	push   %ebp
801050c9:	89 e5                	mov    %esp,%ebp
801050cb:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801050ce:	e8 d6 ea ff ff       	call   80103ba9 <myproc>
801050d3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801050d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d9:	8b 00                	mov    (%eax),%eax
801050db:	39 45 08             	cmp    %eax,0x8(%ebp)
801050de:	73 0f                	jae    801050ef <fetchint+0x2b>
801050e0:	8b 45 08             	mov    0x8(%ebp),%eax
801050e3:	8d 50 04             	lea    0x4(%eax),%edx
801050e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e9:	8b 00                	mov    (%eax),%eax
801050eb:	39 c2                	cmp    %eax,%edx
801050ed:	76 07                	jbe    801050f6 <fetchint+0x32>
    return -1;
801050ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050f4:	eb 0f                	jmp    80105105 <fetchint+0x41>
  *ip = *(int*)(addr);
801050f6:	8b 45 08             	mov    0x8(%ebp),%eax
801050f9:	8b 10                	mov    (%eax),%edx
801050fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fe:	89 10                	mov    %edx,(%eax)
  return 0;
80105100:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105105:	c9                   	leave  
80105106:	c3                   	ret    

80105107 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105107:	f3 0f 1e fb          	endbr32 
8010510b:	55                   	push   %ebp
8010510c:	89 e5                	mov    %esp,%ebp
8010510e:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105111:	e8 93 ea ff ff       	call   80103ba9 <myproc>
80105116:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010511c:	8b 00                	mov    (%eax),%eax
8010511e:	39 45 08             	cmp    %eax,0x8(%ebp)
80105121:	72 07                	jb     8010512a <fetchstr+0x23>
    return -1;
80105123:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105128:	eb 43                	jmp    8010516d <fetchstr+0x66>
  *pp = (char*)addr;
8010512a:	8b 55 08             	mov    0x8(%ebp),%edx
8010512d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105130:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105132:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105135:	8b 00                	mov    (%eax),%eax
80105137:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010513a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010513d:	8b 00                	mov    (%eax),%eax
8010513f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105142:	eb 1c                	jmp    80105160 <fetchstr+0x59>
    if(*s == 0)
80105144:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105147:	0f b6 00             	movzbl (%eax),%eax
8010514a:	84 c0                	test   %al,%al
8010514c:	75 0e                	jne    8010515c <fetchstr+0x55>
      return s - *pp;
8010514e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105151:	8b 00                	mov    (%eax),%eax
80105153:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105156:	29 c2                	sub    %eax,%edx
80105158:	89 d0                	mov    %edx,%eax
8010515a:	eb 11                	jmp    8010516d <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
8010515c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105163:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105166:	72 dc                	jb     80105144 <fetchstr+0x3d>
  }
  return -1;
80105168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010516d:	c9                   	leave  
8010516e:	c3                   	ret    

8010516f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010516f:	f3 0f 1e fb          	endbr32 
80105173:	55                   	push   %ebp
80105174:	89 e5                	mov    %esp,%ebp
80105176:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105179:	e8 2b ea ff ff       	call   80103ba9 <myproc>
8010517e:	8b 40 18             	mov    0x18(%eax),%eax
80105181:	8b 40 44             	mov    0x44(%eax),%eax
80105184:	8b 55 08             	mov    0x8(%ebp),%edx
80105187:	c1 e2 02             	shl    $0x2,%edx
8010518a:	01 d0                	add    %edx,%eax
8010518c:	83 c0 04             	add    $0x4,%eax
8010518f:	83 ec 08             	sub    $0x8,%esp
80105192:	ff 75 0c             	pushl  0xc(%ebp)
80105195:	50                   	push   %eax
80105196:	e8 29 ff ff ff       	call   801050c4 <fetchint>
8010519b:	83 c4 10             	add    $0x10,%esp
}
8010519e:	c9                   	leave  
8010519f:	c3                   	ret    

801051a0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801051a0:	f3 0f 1e fb          	endbr32 
801051a4:	55                   	push   %ebp
801051a5:	89 e5                	mov    %esp,%ebp
801051a7:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801051aa:	e8 fa e9 ff ff       	call   80103ba9 <myproc>
801051af:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801051b2:	83 ec 08             	sub    $0x8,%esp
801051b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051b8:	50                   	push   %eax
801051b9:	ff 75 08             	pushl  0x8(%ebp)
801051bc:	e8 ae ff ff ff       	call   8010516f <argint>
801051c1:	83 c4 10             	add    $0x10,%esp
801051c4:	85 c0                	test   %eax,%eax
801051c6:	79 07                	jns    801051cf <argptr+0x2f>
    return -1;
801051c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051cd:	eb 3b                	jmp    8010520a <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801051cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051d3:	78 1f                	js     801051f4 <argptr+0x54>
801051d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d8:	8b 00                	mov    (%eax),%eax
801051da:	8b 55 f0             	mov    -0x10(%ebp),%edx
801051dd:	39 d0                	cmp    %edx,%eax
801051df:	76 13                	jbe    801051f4 <argptr+0x54>
801051e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e4:	89 c2                	mov    %eax,%edx
801051e6:	8b 45 10             	mov    0x10(%ebp),%eax
801051e9:	01 c2                	add    %eax,%edx
801051eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ee:	8b 00                	mov    (%eax),%eax
801051f0:	39 c2                	cmp    %eax,%edx
801051f2:	76 07                	jbe    801051fb <argptr+0x5b>
    return -1;
801051f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f9:	eb 0f                	jmp    8010520a <argptr+0x6a>
  *pp = (char*)i;
801051fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051fe:	89 c2                	mov    %eax,%edx
80105200:	8b 45 0c             	mov    0xc(%ebp),%eax
80105203:	89 10                	mov    %edx,(%eax)
  return 0;
80105205:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010520a:	c9                   	leave  
8010520b:	c3                   	ret    

8010520c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010520c:	f3 0f 1e fb          	endbr32 
80105210:	55                   	push   %ebp
80105211:	89 e5                	mov    %esp,%ebp
80105213:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105216:	83 ec 08             	sub    $0x8,%esp
80105219:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010521c:	50                   	push   %eax
8010521d:	ff 75 08             	pushl  0x8(%ebp)
80105220:	e8 4a ff ff ff       	call   8010516f <argint>
80105225:	83 c4 10             	add    $0x10,%esp
80105228:	85 c0                	test   %eax,%eax
8010522a:	79 07                	jns    80105233 <argstr+0x27>
    return -1;
8010522c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105231:	eb 12                	jmp    80105245 <argstr+0x39>
  return fetchstr(addr, pp);
80105233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105236:	83 ec 08             	sub    $0x8,%esp
80105239:	ff 75 0c             	pushl  0xc(%ebp)
8010523c:	50                   	push   %eax
8010523d:	e8 c5 fe ff ff       	call   80105107 <fetchstr>
80105242:	83 c4 10             	add    $0x10,%esp
}
80105245:	c9                   	leave  
80105246:	c3                   	ret    

80105247 <syscall>:
[SYS_uthread_init]   sys_uthread_init,
};

void
syscall(void)
{
80105247:	f3 0f 1e fb          	endbr32 
8010524b:	55                   	push   %ebp
8010524c:	89 e5                	mov    %esp,%ebp
8010524e:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105251:	e8 53 e9 ff ff       	call   80103ba9 <myproc>
80105256:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010525c:	8b 40 18             	mov    0x18(%eax),%eax
8010525f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105262:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105265:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105269:	7e 2f                	jle    8010529a <syscall+0x53>
8010526b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010526e:	83 f8 18             	cmp    $0x18,%eax
80105271:	77 27                	ja     8010529a <syscall+0x53>
80105273:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105276:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010527d:	85 c0                	test   %eax,%eax
8010527f:	74 19                	je     8010529a <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105281:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105284:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010528b:	ff d0                	call   *%eax
8010528d:	89 c2                	mov    %eax,%edx
8010528f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105292:	8b 40 18             	mov    0x18(%eax),%eax
80105295:	89 50 1c             	mov    %edx,0x1c(%eax)
80105298:	eb 2c                	jmp    801052c6 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010529a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010529d:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801052a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a3:	8b 40 10             	mov    0x10(%eax),%eax
801052a6:	ff 75 f0             	pushl  -0x10(%ebp)
801052a9:	52                   	push   %edx
801052aa:	50                   	push   %eax
801052ab:	68 b8 aa 10 80       	push   $0x8010aab8
801052b0:	e8 57 b1 ff ff       	call   8010040c <cprintf>
801052b5:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801052b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052bb:	8b 40 18             	mov    0x18(%eax),%eax
801052be:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801052c5:	90                   	nop
801052c6:	90                   	nop
801052c7:	c9                   	leave  
801052c8:	c3                   	ret    

801052c9 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801052c9:	f3 0f 1e fb          	endbr32 
801052cd:	55                   	push   %ebp
801052ce:	89 e5                	mov    %esp,%ebp
801052d0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801052d3:	83 ec 08             	sub    $0x8,%esp
801052d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052d9:	50                   	push   %eax
801052da:	ff 75 08             	pushl  0x8(%ebp)
801052dd:	e8 8d fe ff ff       	call   8010516f <argint>
801052e2:	83 c4 10             	add    $0x10,%esp
801052e5:	85 c0                	test   %eax,%eax
801052e7:	79 07                	jns    801052f0 <argfd+0x27>
    return -1;
801052e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052ee:	eb 4f                	jmp    8010533f <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801052f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052f3:	85 c0                	test   %eax,%eax
801052f5:	78 20                	js     80105317 <argfd+0x4e>
801052f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052fa:	83 f8 0f             	cmp    $0xf,%eax
801052fd:	7f 18                	jg     80105317 <argfd+0x4e>
801052ff:	e8 a5 e8 ff ff       	call   80103ba9 <myproc>
80105304:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105307:	83 c2 08             	add    $0x8,%edx
8010530a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010530e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105311:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105315:	75 07                	jne    8010531e <argfd+0x55>
    return -1;
80105317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010531c:	eb 21                	jmp    8010533f <argfd+0x76>
  if(pfd)
8010531e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105322:	74 08                	je     8010532c <argfd+0x63>
    *pfd = fd;
80105324:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105327:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532a:	89 10                	mov    %edx,(%eax)
  if(pf)
8010532c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105330:	74 08                	je     8010533a <argfd+0x71>
    *pf = f;
80105332:	8b 45 10             	mov    0x10(%ebp),%eax
80105335:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105338:	89 10                	mov    %edx,(%eax)
  return 0;
8010533a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010533f:	c9                   	leave  
80105340:	c3                   	ret    

80105341 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105341:	f3 0f 1e fb          	endbr32 
80105345:	55                   	push   %ebp
80105346:	89 e5                	mov    %esp,%ebp
80105348:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010534b:	e8 59 e8 ff ff       	call   80103ba9 <myproc>
80105350:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010535a:	eb 2a                	jmp    80105386 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
8010535c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105362:	83 c2 08             	add    $0x8,%edx
80105365:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105369:	85 c0                	test   %eax,%eax
8010536b:	75 15                	jne    80105382 <fdalloc+0x41>
      curproc->ofile[fd] = f;
8010536d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105370:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105373:	8d 4a 08             	lea    0x8(%edx),%ecx
80105376:	8b 55 08             	mov    0x8(%ebp),%edx
80105379:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010537d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105380:	eb 0f                	jmp    80105391 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105382:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105386:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010538a:	7e d0                	jle    8010535c <fdalloc+0x1b>
    }
  }
  return -1;
8010538c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105391:	c9                   	leave  
80105392:	c3                   	ret    

80105393 <sys_dup>:

int
sys_dup(void)
{
80105393:	f3 0f 1e fb          	endbr32 
80105397:	55                   	push   %ebp
80105398:	89 e5                	mov    %esp,%ebp
8010539a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010539d:	83 ec 04             	sub    $0x4,%esp
801053a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053a3:	50                   	push   %eax
801053a4:	6a 00                	push   $0x0
801053a6:	6a 00                	push   $0x0
801053a8:	e8 1c ff ff ff       	call   801052c9 <argfd>
801053ad:	83 c4 10             	add    $0x10,%esp
801053b0:	85 c0                	test   %eax,%eax
801053b2:	79 07                	jns    801053bb <sys_dup+0x28>
    return -1;
801053b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053b9:	eb 31                	jmp    801053ec <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801053bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053be:	83 ec 0c             	sub    $0xc,%esp
801053c1:	50                   	push   %eax
801053c2:	e8 7a ff ff ff       	call   80105341 <fdalloc>
801053c7:	83 c4 10             	add    $0x10,%esp
801053ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053d1:	79 07                	jns    801053da <sys_dup+0x47>
    return -1;
801053d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d8:	eb 12                	jmp    801053ec <sys_dup+0x59>
  filedup(f);
801053da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053dd:	83 ec 0c             	sub    $0xc,%esp
801053e0:	50                   	push   %eax
801053e1:	e8 ae bc ff ff       	call   80101094 <filedup>
801053e6:	83 c4 10             	add    $0x10,%esp
  return fd;
801053e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801053ec:	c9                   	leave  
801053ed:	c3                   	ret    

801053ee <sys_read>:

int
sys_read(void)
{
801053ee:	f3 0f 1e fb          	endbr32 
801053f2:	55                   	push   %ebp
801053f3:	89 e5                	mov    %esp,%ebp
801053f5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053f8:	83 ec 04             	sub    $0x4,%esp
801053fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053fe:	50                   	push   %eax
801053ff:	6a 00                	push   $0x0
80105401:	6a 00                	push   $0x0
80105403:	e8 c1 fe ff ff       	call   801052c9 <argfd>
80105408:	83 c4 10             	add    $0x10,%esp
8010540b:	85 c0                	test   %eax,%eax
8010540d:	78 2e                	js     8010543d <sys_read+0x4f>
8010540f:	83 ec 08             	sub    $0x8,%esp
80105412:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105415:	50                   	push   %eax
80105416:	6a 02                	push   $0x2
80105418:	e8 52 fd ff ff       	call   8010516f <argint>
8010541d:	83 c4 10             	add    $0x10,%esp
80105420:	85 c0                	test   %eax,%eax
80105422:	78 19                	js     8010543d <sys_read+0x4f>
80105424:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105427:	83 ec 04             	sub    $0x4,%esp
8010542a:	50                   	push   %eax
8010542b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010542e:	50                   	push   %eax
8010542f:	6a 01                	push   $0x1
80105431:	e8 6a fd ff ff       	call   801051a0 <argptr>
80105436:	83 c4 10             	add    $0x10,%esp
80105439:	85 c0                	test   %eax,%eax
8010543b:	79 07                	jns    80105444 <sys_read+0x56>
    return -1;
8010543d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105442:	eb 17                	jmp    8010545b <sys_read+0x6d>
  return fileread(f, p, n);
80105444:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105447:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010544a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544d:	83 ec 04             	sub    $0x4,%esp
80105450:	51                   	push   %ecx
80105451:	52                   	push   %edx
80105452:	50                   	push   %eax
80105453:	e8 d8 bd ff ff       	call   80101230 <fileread>
80105458:	83 c4 10             	add    $0x10,%esp
}
8010545b:	c9                   	leave  
8010545c:	c3                   	ret    

8010545d <sys_write>:

int
sys_write(void)
{
8010545d:	f3 0f 1e fb          	endbr32 
80105461:	55                   	push   %ebp
80105462:	89 e5                	mov    %esp,%ebp
80105464:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105467:	83 ec 04             	sub    $0x4,%esp
8010546a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010546d:	50                   	push   %eax
8010546e:	6a 00                	push   $0x0
80105470:	6a 00                	push   $0x0
80105472:	e8 52 fe ff ff       	call   801052c9 <argfd>
80105477:	83 c4 10             	add    $0x10,%esp
8010547a:	85 c0                	test   %eax,%eax
8010547c:	78 2e                	js     801054ac <sys_write+0x4f>
8010547e:	83 ec 08             	sub    $0x8,%esp
80105481:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105484:	50                   	push   %eax
80105485:	6a 02                	push   $0x2
80105487:	e8 e3 fc ff ff       	call   8010516f <argint>
8010548c:	83 c4 10             	add    $0x10,%esp
8010548f:	85 c0                	test   %eax,%eax
80105491:	78 19                	js     801054ac <sys_write+0x4f>
80105493:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105496:	83 ec 04             	sub    $0x4,%esp
80105499:	50                   	push   %eax
8010549a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010549d:	50                   	push   %eax
8010549e:	6a 01                	push   $0x1
801054a0:	e8 fb fc ff ff       	call   801051a0 <argptr>
801054a5:	83 c4 10             	add    $0x10,%esp
801054a8:	85 c0                	test   %eax,%eax
801054aa:	79 07                	jns    801054b3 <sys_write+0x56>
    return -1;
801054ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b1:	eb 17                	jmp    801054ca <sys_write+0x6d>
  return filewrite(f, p, n);
801054b3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801054b6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801054b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054bc:	83 ec 04             	sub    $0x4,%esp
801054bf:	51                   	push   %ecx
801054c0:	52                   	push   %edx
801054c1:	50                   	push   %eax
801054c2:	e8 25 be ff ff       	call   801012ec <filewrite>
801054c7:	83 c4 10             	add    $0x10,%esp
}
801054ca:	c9                   	leave  
801054cb:	c3                   	ret    

801054cc <sys_close>:

int
sys_close(void)
{
801054cc:	f3 0f 1e fb          	endbr32 
801054d0:	55                   	push   %ebp
801054d1:	89 e5                	mov    %esp,%ebp
801054d3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801054d6:	83 ec 04             	sub    $0x4,%esp
801054d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054dc:	50                   	push   %eax
801054dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054e0:	50                   	push   %eax
801054e1:	6a 00                	push   $0x0
801054e3:	e8 e1 fd ff ff       	call   801052c9 <argfd>
801054e8:	83 c4 10             	add    $0x10,%esp
801054eb:	85 c0                	test   %eax,%eax
801054ed:	79 07                	jns    801054f6 <sys_close+0x2a>
    return -1;
801054ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054f4:	eb 27                	jmp    8010551d <sys_close+0x51>
  myproc()->ofile[fd] = 0;
801054f6:	e8 ae e6 ff ff       	call   80103ba9 <myproc>
801054fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054fe:	83 c2 08             	add    $0x8,%edx
80105501:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105508:	00 
  fileclose(f);
80105509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550c:	83 ec 0c             	sub    $0xc,%esp
8010550f:	50                   	push   %eax
80105510:	e8 d4 bb ff ff       	call   801010e9 <fileclose>
80105515:	83 c4 10             	add    $0x10,%esp
  return 0;
80105518:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010551d:	c9                   	leave  
8010551e:	c3                   	ret    

8010551f <sys_fstat>:

int
sys_fstat(void)
{
8010551f:	f3 0f 1e fb          	endbr32 
80105523:	55                   	push   %ebp
80105524:	89 e5                	mov    %esp,%ebp
80105526:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105529:	83 ec 04             	sub    $0x4,%esp
8010552c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010552f:	50                   	push   %eax
80105530:	6a 00                	push   $0x0
80105532:	6a 00                	push   $0x0
80105534:	e8 90 fd ff ff       	call   801052c9 <argfd>
80105539:	83 c4 10             	add    $0x10,%esp
8010553c:	85 c0                	test   %eax,%eax
8010553e:	78 17                	js     80105557 <sys_fstat+0x38>
80105540:	83 ec 04             	sub    $0x4,%esp
80105543:	6a 14                	push   $0x14
80105545:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105548:	50                   	push   %eax
80105549:	6a 01                	push   $0x1
8010554b:	e8 50 fc ff ff       	call   801051a0 <argptr>
80105550:	83 c4 10             	add    $0x10,%esp
80105553:	85 c0                	test   %eax,%eax
80105555:	79 07                	jns    8010555e <sys_fstat+0x3f>
    return -1;
80105557:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010555c:	eb 13                	jmp    80105571 <sys_fstat+0x52>
  return filestat(f, st);
8010555e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105564:	83 ec 08             	sub    $0x8,%esp
80105567:	52                   	push   %edx
80105568:	50                   	push   %eax
80105569:	e8 67 bc ff ff       	call   801011d5 <filestat>
8010556e:	83 c4 10             	add    $0x10,%esp
}
80105571:	c9                   	leave  
80105572:	c3                   	ret    

80105573 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105573:	f3 0f 1e fb          	endbr32 
80105577:	55                   	push   %ebp
80105578:	89 e5                	mov    %esp,%ebp
8010557a:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010557d:	83 ec 08             	sub    $0x8,%esp
80105580:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105583:	50                   	push   %eax
80105584:	6a 00                	push   $0x0
80105586:	e8 81 fc ff ff       	call   8010520c <argstr>
8010558b:	83 c4 10             	add    $0x10,%esp
8010558e:	85 c0                	test   %eax,%eax
80105590:	78 15                	js     801055a7 <sys_link+0x34>
80105592:	83 ec 08             	sub    $0x8,%esp
80105595:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105598:	50                   	push   %eax
80105599:	6a 01                	push   $0x1
8010559b:	e8 6c fc ff ff       	call   8010520c <argstr>
801055a0:	83 c4 10             	add    $0x10,%esp
801055a3:	85 c0                	test   %eax,%eax
801055a5:	79 0a                	jns    801055b1 <sys_link+0x3e>
    return -1;
801055a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ac:	e9 68 01 00 00       	jmp    80105719 <sys_link+0x1a6>

  begin_op();
801055b1:	e8 bb db ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
801055b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801055b9:	83 ec 0c             	sub    $0xc,%esp
801055bc:	50                   	push   %eax
801055bd:	e8 25 d0 ff ff       	call   801025e7 <namei>
801055c2:	83 c4 10             	add    $0x10,%esp
801055c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055cc:	75 0f                	jne    801055dd <sys_link+0x6a>
    end_op();
801055ce:	e8 2e dc ff ff       	call   80103201 <end_op>
    return -1;
801055d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055d8:	e9 3c 01 00 00       	jmp    80105719 <sys_link+0x1a6>
  }

  ilock(ip);
801055dd:	83 ec 0c             	sub    $0xc,%esp
801055e0:	ff 75 f4             	pushl  -0xc(%ebp)
801055e3:	e8 94 c4 ff ff       	call   80101a7c <ilock>
801055e8:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801055eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ee:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055f2:	66 83 f8 01          	cmp    $0x1,%ax
801055f6:	75 1d                	jne    80105615 <sys_link+0xa2>
    iunlockput(ip);
801055f8:	83 ec 0c             	sub    $0xc,%esp
801055fb:	ff 75 f4             	pushl  -0xc(%ebp)
801055fe:	e8 b6 c6 ff ff       	call   80101cb9 <iunlockput>
80105603:	83 c4 10             	add    $0x10,%esp
    end_op();
80105606:	e8 f6 db ff ff       	call   80103201 <end_op>
    return -1;
8010560b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105610:	e9 04 01 00 00       	jmp    80105719 <sys_link+0x1a6>
  }

  ip->nlink++;
80105615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105618:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010561c:	83 c0 01             	add    $0x1,%eax
8010561f:	89 c2                	mov    %eax,%edx
80105621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105624:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105628:	83 ec 0c             	sub    $0xc,%esp
8010562b:	ff 75 f4             	pushl  -0xc(%ebp)
8010562e:	e8 60 c2 ff ff       	call   80101893 <iupdate>
80105633:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105636:	83 ec 0c             	sub    $0xc,%esp
80105639:	ff 75 f4             	pushl  -0xc(%ebp)
8010563c:	e8 52 c5 ff ff       	call   80101b93 <iunlock>
80105641:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105644:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105647:	83 ec 08             	sub    $0x8,%esp
8010564a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010564d:	52                   	push   %edx
8010564e:	50                   	push   %eax
8010564f:	e8 b3 cf ff ff       	call   80102607 <nameiparent>
80105654:	83 c4 10             	add    $0x10,%esp
80105657:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010565a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010565e:	74 71                	je     801056d1 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105660:	83 ec 0c             	sub    $0xc,%esp
80105663:	ff 75 f0             	pushl  -0x10(%ebp)
80105666:	e8 11 c4 ff ff       	call   80101a7c <ilock>
8010566b:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010566e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105671:	8b 10                	mov    (%eax),%edx
80105673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105676:	8b 00                	mov    (%eax),%eax
80105678:	39 c2                	cmp    %eax,%edx
8010567a:	75 1d                	jne    80105699 <sys_link+0x126>
8010567c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567f:	8b 40 04             	mov    0x4(%eax),%eax
80105682:	83 ec 04             	sub    $0x4,%esp
80105685:	50                   	push   %eax
80105686:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105689:	50                   	push   %eax
8010568a:	ff 75 f0             	pushl  -0x10(%ebp)
8010568d:	e8 b2 cc ff ff       	call   80102344 <dirlink>
80105692:	83 c4 10             	add    $0x10,%esp
80105695:	85 c0                	test   %eax,%eax
80105697:	79 10                	jns    801056a9 <sys_link+0x136>
    iunlockput(dp);
80105699:	83 ec 0c             	sub    $0xc,%esp
8010569c:	ff 75 f0             	pushl  -0x10(%ebp)
8010569f:	e8 15 c6 ff ff       	call   80101cb9 <iunlockput>
801056a4:	83 c4 10             	add    $0x10,%esp
    goto bad;
801056a7:	eb 29                	jmp    801056d2 <sys_link+0x15f>
  }
  iunlockput(dp);
801056a9:	83 ec 0c             	sub    $0xc,%esp
801056ac:	ff 75 f0             	pushl  -0x10(%ebp)
801056af:	e8 05 c6 ff ff       	call   80101cb9 <iunlockput>
801056b4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801056b7:	83 ec 0c             	sub    $0xc,%esp
801056ba:	ff 75 f4             	pushl  -0xc(%ebp)
801056bd:	e8 23 c5 ff ff       	call   80101be5 <iput>
801056c2:	83 c4 10             	add    $0x10,%esp

  end_op();
801056c5:	e8 37 db ff ff       	call   80103201 <end_op>

  return 0;
801056ca:	b8 00 00 00 00       	mov    $0x0,%eax
801056cf:	eb 48                	jmp    80105719 <sys_link+0x1a6>
    goto bad;
801056d1:	90                   	nop

bad:
  ilock(ip);
801056d2:	83 ec 0c             	sub    $0xc,%esp
801056d5:	ff 75 f4             	pushl  -0xc(%ebp)
801056d8:	e8 9f c3 ff ff       	call   80101a7c <ilock>
801056dd:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801056e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e3:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056e7:	83 e8 01             	sub    $0x1,%eax
801056ea:	89 c2                	mov    %eax,%edx
801056ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ef:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801056f3:	83 ec 0c             	sub    $0xc,%esp
801056f6:	ff 75 f4             	pushl  -0xc(%ebp)
801056f9:	e8 95 c1 ff ff       	call   80101893 <iupdate>
801056fe:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105701:	83 ec 0c             	sub    $0xc,%esp
80105704:	ff 75 f4             	pushl  -0xc(%ebp)
80105707:	e8 ad c5 ff ff       	call   80101cb9 <iunlockput>
8010570c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010570f:	e8 ed da ff ff       	call   80103201 <end_op>
  return -1;
80105714:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105719:	c9                   	leave  
8010571a:	c3                   	ret    

8010571b <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010571b:	f3 0f 1e fb          	endbr32 
8010571f:	55                   	push   %ebp
80105720:	89 e5                	mov    %esp,%ebp
80105722:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105725:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010572c:	eb 40                	jmp    8010576e <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010572e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105731:	6a 10                	push   $0x10
80105733:	50                   	push   %eax
80105734:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105737:	50                   	push   %eax
80105738:	ff 75 08             	pushl  0x8(%ebp)
8010573b:	e8 44 c8 ff ff       	call   80101f84 <readi>
80105740:	83 c4 10             	add    $0x10,%esp
80105743:	83 f8 10             	cmp    $0x10,%eax
80105746:	74 0d                	je     80105755 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105748:	83 ec 0c             	sub    $0xc,%esp
8010574b:	68 d4 aa 10 80       	push   $0x8010aad4
80105750:	e8 70 ae ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105755:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105759:	66 85 c0             	test   %ax,%ax
8010575c:	74 07                	je     80105765 <isdirempty+0x4a>
      return 0;
8010575e:	b8 00 00 00 00       	mov    $0x0,%eax
80105763:	eb 1b                	jmp    80105780 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105768:	83 c0 10             	add    $0x10,%eax
8010576b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010576e:	8b 45 08             	mov    0x8(%ebp),%eax
80105771:	8b 50 58             	mov    0x58(%eax),%edx
80105774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105777:	39 c2                	cmp    %eax,%edx
80105779:	77 b3                	ja     8010572e <isdirempty+0x13>
  }
  return 1;
8010577b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105780:	c9                   	leave  
80105781:	c3                   	ret    

80105782 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105782:	f3 0f 1e fb          	endbr32 
80105786:	55                   	push   %ebp
80105787:	89 e5                	mov    %esp,%ebp
80105789:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010578c:	83 ec 08             	sub    $0x8,%esp
8010578f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105792:	50                   	push   %eax
80105793:	6a 00                	push   $0x0
80105795:	e8 72 fa ff ff       	call   8010520c <argstr>
8010579a:	83 c4 10             	add    $0x10,%esp
8010579d:	85 c0                	test   %eax,%eax
8010579f:	79 0a                	jns    801057ab <sys_unlink+0x29>
    return -1;
801057a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a6:	e9 bf 01 00 00       	jmp    8010596a <sys_unlink+0x1e8>

  begin_op();
801057ab:	e8 c1 d9 ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801057b0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801057b3:	83 ec 08             	sub    $0x8,%esp
801057b6:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801057b9:	52                   	push   %edx
801057ba:	50                   	push   %eax
801057bb:	e8 47 ce ff ff       	call   80102607 <nameiparent>
801057c0:	83 c4 10             	add    $0x10,%esp
801057c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057ca:	75 0f                	jne    801057db <sys_unlink+0x59>
    end_op();
801057cc:	e8 30 da ff ff       	call   80103201 <end_op>
    return -1;
801057d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d6:	e9 8f 01 00 00       	jmp    8010596a <sys_unlink+0x1e8>
  }

  ilock(dp);
801057db:	83 ec 0c             	sub    $0xc,%esp
801057de:	ff 75 f4             	pushl  -0xc(%ebp)
801057e1:	e8 96 c2 ff ff       	call   80101a7c <ilock>
801057e6:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801057e9:	83 ec 08             	sub    $0x8,%esp
801057ec:	68 e6 aa 10 80       	push   $0x8010aae6
801057f1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057f4:	50                   	push   %eax
801057f5:	e8 6d ca ff ff       	call   80102267 <namecmp>
801057fa:	83 c4 10             	add    $0x10,%esp
801057fd:	85 c0                	test   %eax,%eax
801057ff:	0f 84 49 01 00 00    	je     8010594e <sys_unlink+0x1cc>
80105805:	83 ec 08             	sub    $0x8,%esp
80105808:	68 e8 aa 10 80       	push   $0x8010aae8
8010580d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105810:	50                   	push   %eax
80105811:	e8 51 ca ff ff       	call   80102267 <namecmp>
80105816:	83 c4 10             	add    $0x10,%esp
80105819:	85 c0                	test   %eax,%eax
8010581b:	0f 84 2d 01 00 00    	je     8010594e <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105821:	83 ec 04             	sub    $0x4,%esp
80105824:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105827:	50                   	push   %eax
80105828:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010582b:	50                   	push   %eax
8010582c:	ff 75 f4             	pushl  -0xc(%ebp)
8010582f:	e8 52 ca ff ff       	call   80102286 <dirlookup>
80105834:	83 c4 10             	add    $0x10,%esp
80105837:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010583a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010583e:	0f 84 0d 01 00 00    	je     80105951 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105844:	83 ec 0c             	sub    $0xc,%esp
80105847:	ff 75 f0             	pushl  -0x10(%ebp)
8010584a:	e8 2d c2 ff ff       	call   80101a7c <ilock>
8010584f:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105852:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105855:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105859:	66 85 c0             	test   %ax,%ax
8010585c:	7f 0d                	jg     8010586b <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
8010585e:	83 ec 0c             	sub    $0xc,%esp
80105861:	68 eb aa 10 80       	push   $0x8010aaeb
80105866:	e8 5a ad ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010586b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105872:	66 83 f8 01          	cmp    $0x1,%ax
80105876:	75 25                	jne    8010589d <sys_unlink+0x11b>
80105878:	83 ec 0c             	sub    $0xc,%esp
8010587b:	ff 75 f0             	pushl  -0x10(%ebp)
8010587e:	e8 98 fe ff ff       	call   8010571b <isdirempty>
80105883:	83 c4 10             	add    $0x10,%esp
80105886:	85 c0                	test   %eax,%eax
80105888:	75 13                	jne    8010589d <sys_unlink+0x11b>
    iunlockput(ip);
8010588a:	83 ec 0c             	sub    $0xc,%esp
8010588d:	ff 75 f0             	pushl  -0x10(%ebp)
80105890:	e8 24 c4 ff ff       	call   80101cb9 <iunlockput>
80105895:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105898:	e9 b5 00 00 00       	jmp    80105952 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
8010589d:	83 ec 04             	sub    $0x4,%esp
801058a0:	6a 10                	push   $0x10
801058a2:	6a 00                	push   $0x0
801058a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801058a7:	50                   	push   %eax
801058a8:	e8 6e f5 ff ff       	call   80104e1b <memset>
801058ad:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801058b0:	8b 45 c8             	mov    -0x38(%ebp),%eax
801058b3:	6a 10                	push   $0x10
801058b5:	50                   	push   %eax
801058b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801058b9:	50                   	push   %eax
801058ba:	ff 75 f4             	pushl  -0xc(%ebp)
801058bd:	e8 1b c8 ff ff       	call   801020dd <writei>
801058c2:	83 c4 10             	add    $0x10,%esp
801058c5:	83 f8 10             	cmp    $0x10,%eax
801058c8:	74 0d                	je     801058d7 <sys_unlink+0x155>
    panic("unlink: writei");
801058ca:	83 ec 0c             	sub    $0xc,%esp
801058cd:	68 fd aa 10 80       	push   $0x8010aafd
801058d2:	e8 ee ac ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
801058d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058da:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058de:	66 83 f8 01          	cmp    $0x1,%ax
801058e2:	75 21                	jne    80105905 <sys_unlink+0x183>
    dp->nlink--;
801058e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058eb:	83 e8 01             	sub    $0x1,%eax
801058ee:	89 c2                	mov    %eax,%edx
801058f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f3:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801058f7:	83 ec 0c             	sub    $0xc,%esp
801058fa:	ff 75 f4             	pushl  -0xc(%ebp)
801058fd:	e8 91 bf ff ff       	call   80101893 <iupdate>
80105902:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105905:	83 ec 0c             	sub    $0xc,%esp
80105908:	ff 75 f4             	pushl  -0xc(%ebp)
8010590b:	e8 a9 c3 ff ff       	call   80101cb9 <iunlockput>
80105910:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105913:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105916:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010591a:	83 e8 01             	sub    $0x1,%eax
8010591d:	89 c2                	mov    %eax,%edx
8010591f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105922:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105926:	83 ec 0c             	sub    $0xc,%esp
80105929:	ff 75 f0             	pushl  -0x10(%ebp)
8010592c:	e8 62 bf ff ff       	call   80101893 <iupdate>
80105931:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105934:	83 ec 0c             	sub    $0xc,%esp
80105937:	ff 75 f0             	pushl  -0x10(%ebp)
8010593a:	e8 7a c3 ff ff       	call   80101cb9 <iunlockput>
8010593f:	83 c4 10             	add    $0x10,%esp

  end_op();
80105942:	e8 ba d8 ff ff       	call   80103201 <end_op>

  return 0;
80105947:	b8 00 00 00 00       	mov    $0x0,%eax
8010594c:	eb 1c                	jmp    8010596a <sys_unlink+0x1e8>
    goto bad;
8010594e:	90                   	nop
8010594f:	eb 01                	jmp    80105952 <sys_unlink+0x1d0>
    goto bad;
80105951:	90                   	nop

bad:
  iunlockput(dp);
80105952:	83 ec 0c             	sub    $0xc,%esp
80105955:	ff 75 f4             	pushl  -0xc(%ebp)
80105958:	e8 5c c3 ff ff       	call   80101cb9 <iunlockput>
8010595d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105960:	e8 9c d8 ff ff       	call   80103201 <end_op>
  return -1;
80105965:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010596a:	c9                   	leave  
8010596b:	c3                   	ret    

8010596c <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010596c:	f3 0f 1e fb          	endbr32 
80105970:	55                   	push   %ebp
80105971:	89 e5                	mov    %esp,%ebp
80105973:	83 ec 38             	sub    $0x38,%esp
80105976:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105979:	8b 55 10             	mov    0x10(%ebp),%edx
8010597c:	8b 45 14             	mov    0x14(%ebp),%eax
8010597f:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105983:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105987:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010598b:	83 ec 08             	sub    $0x8,%esp
8010598e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105991:	50                   	push   %eax
80105992:	ff 75 08             	pushl  0x8(%ebp)
80105995:	e8 6d cc ff ff       	call   80102607 <nameiparent>
8010599a:	83 c4 10             	add    $0x10,%esp
8010599d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059a4:	75 0a                	jne    801059b0 <create+0x44>
    return 0;
801059a6:	b8 00 00 00 00       	mov    $0x0,%eax
801059ab:	e9 90 01 00 00       	jmp    80105b40 <create+0x1d4>
  ilock(dp);
801059b0:	83 ec 0c             	sub    $0xc,%esp
801059b3:	ff 75 f4             	pushl  -0xc(%ebp)
801059b6:	e8 c1 c0 ff ff       	call   80101a7c <ilock>
801059bb:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801059be:	83 ec 04             	sub    $0x4,%esp
801059c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059c4:	50                   	push   %eax
801059c5:	8d 45 de             	lea    -0x22(%ebp),%eax
801059c8:	50                   	push   %eax
801059c9:	ff 75 f4             	pushl  -0xc(%ebp)
801059cc:	e8 b5 c8 ff ff       	call   80102286 <dirlookup>
801059d1:	83 c4 10             	add    $0x10,%esp
801059d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059db:	74 50                	je     80105a2d <create+0xc1>
    iunlockput(dp);
801059dd:	83 ec 0c             	sub    $0xc,%esp
801059e0:	ff 75 f4             	pushl  -0xc(%ebp)
801059e3:	e8 d1 c2 ff ff       	call   80101cb9 <iunlockput>
801059e8:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801059eb:	83 ec 0c             	sub    $0xc,%esp
801059ee:	ff 75 f0             	pushl  -0x10(%ebp)
801059f1:	e8 86 c0 ff ff       	call   80101a7c <ilock>
801059f6:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801059f9:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801059fe:	75 15                	jne    80105a15 <create+0xa9>
80105a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a03:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a07:	66 83 f8 02          	cmp    $0x2,%ax
80105a0b:	75 08                	jne    80105a15 <create+0xa9>
      return ip;
80105a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a10:	e9 2b 01 00 00       	jmp    80105b40 <create+0x1d4>
    iunlockput(ip);
80105a15:	83 ec 0c             	sub    $0xc,%esp
80105a18:	ff 75 f0             	pushl  -0x10(%ebp)
80105a1b:	e8 99 c2 ff ff       	call   80101cb9 <iunlockput>
80105a20:	83 c4 10             	add    $0x10,%esp
    return 0;
80105a23:	b8 00 00 00 00       	mov    $0x0,%eax
80105a28:	e9 13 01 00 00       	jmp    80105b40 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105a2d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a34:	8b 00                	mov    (%eax),%eax
80105a36:	83 ec 08             	sub    $0x8,%esp
80105a39:	52                   	push   %edx
80105a3a:	50                   	push   %eax
80105a3b:	e8 78 bd ff ff       	call   801017b8 <ialloc>
80105a40:	83 c4 10             	add    $0x10,%esp
80105a43:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a4a:	75 0d                	jne    80105a59 <create+0xed>
    panic("create: ialloc");
80105a4c:	83 ec 0c             	sub    $0xc,%esp
80105a4f:	68 0c ab 10 80       	push   $0x8010ab0c
80105a54:	e8 6c ab ff ff       	call   801005c5 <panic>

  ilock(ip);
80105a59:	83 ec 0c             	sub    $0xc,%esp
80105a5c:	ff 75 f0             	pushl  -0x10(%ebp)
80105a5f:	e8 18 c0 ff ff       	call   80101a7c <ilock>
80105a64:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a6e:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a75:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a79:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a80:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a86:	83 ec 0c             	sub    $0xc,%esp
80105a89:	ff 75 f0             	pushl  -0x10(%ebp)
80105a8c:	e8 02 be ff ff       	call   80101893 <iupdate>
80105a91:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a94:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a99:	75 6a                	jne    80105b05 <create+0x199>
    dp->nlink++;  // for ".."
80105a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105aa2:	83 c0 01             	add    $0x1,%eax
80105aa5:	89 c2                	mov    %eax,%edx
80105aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aaa:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105aae:	83 ec 0c             	sub    $0xc,%esp
80105ab1:	ff 75 f4             	pushl  -0xc(%ebp)
80105ab4:	e8 da bd ff ff       	call   80101893 <iupdate>
80105ab9:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abf:	8b 40 04             	mov    0x4(%eax),%eax
80105ac2:	83 ec 04             	sub    $0x4,%esp
80105ac5:	50                   	push   %eax
80105ac6:	68 e6 aa 10 80       	push   $0x8010aae6
80105acb:	ff 75 f0             	pushl  -0x10(%ebp)
80105ace:	e8 71 c8 ff ff       	call   80102344 <dirlink>
80105ad3:	83 c4 10             	add    $0x10,%esp
80105ad6:	85 c0                	test   %eax,%eax
80105ad8:	78 1e                	js     80105af8 <create+0x18c>
80105ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105add:	8b 40 04             	mov    0x4(%eax),%eax
80105ae0:	83 ec 04             	sub    $0x4,%esp
80105ae3:	50                   	push   %eax
80105ae4:	68 e8 aa 10 80       	push   $0x8010aae8
80105ae9:	ff 75 f0             	pushl  -0x10(%ebp)
80105aec:	e8 53 c8 ff ff       	call   80102344 <dirlink>
80105af1:	83 c4 10             	add    $0x10,%esp
80105af4:	85 c0                	test   %eax,%eax
80105af6:	79 0d                	jns    80105b05 <create+0x199>
      panic("create dots");
80105af8:	83 ec 0c             	sub    $0xc,%esp
80105afb:	68 1b ab 10 80       	push   $0x8010ab1b
80105b00:	e8 c0 aa ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b08:	8b 40 04             	mov    0x4(%eax),%eax
80105b0b:	83 ec 04             	sub    $0x4,%esp
80105b0e:	50                   	push   %eax
80105b0f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b12:	50                   	push   %eax
80105b13:	ff 75 f4             	pushl  -0xc(%ebp)
80105b16:	e8 29 c8 ff ff       	call   80102344 <dirlink>
80105b1b:	83 c4 10             	add    $0x10,%esp
80105b1e:	85 c0                	test   %eax,%eax
80105b20:	79 0d                	jns    80105b2f <create+0x1c3>
    panic("create: dirlink");
80105b22:	83 ec 0c             	sub    $0xc,%esp
80105b25:	68 27 ab 10 80       	push   $0x8010ab27
80105b2a:	e8 96 aa ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80105b2f:	83 ec 0c             	sub    $0xc,%esp
80105b32:	ff 75 f4             	pushl  -0xc(%ebp)
80105b35:	e8 7f c1 ff ff       	call   80101cb9 <iunlockput>
80105b3a:	83 c4 10             	add    $0x10,%esp

  return ip;
80105b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105b40:	c9                   	leave  
80105b41:	c3                   	ret    

80105b42 <sys_open>:

int
sys_open(void)
{
80105b42:	f3 0f 1e fb          	endbr32 
80105b46:	55                   	push   %ebp
80105b47:	89 e5                	mov    %esp,%ebp
80105b49:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105b4c:	83 ec 08             	sub    $0x8,%esp
80105b4f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b52:	50                   	push   %eax
80105b53:	6a 00                	push   $0x0
80105b55:	e8 b2 f6 ff ff       	call   8010520c <argstr>
80105b5a:	83 c4 10             	add    $0x10,%esp
80105b5d:	85 c0                	test   %eax,%eax
80105b5f:	78 15                	js     80105b76 <sys_open+0x34>
80105b61:	83 ec 08             	sub    $0x8,%esp
80105b64:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b67:	50                   	push   %eax
80105b68:	6a 01                	push   $0x1
80105b6a:	e8 00 f6 ff ff       	call   8010516f <argint>
80105b6f:	83 c4 10             	add    $0x10,%esp
80105b72:	85 c0                	test   %eax,%eax
80105b74:	79 0a                	jns    80105b80 <sys_open+0x3e>
    return -1;
80105b76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7b:	e9 61 01 00 00       	jmp    80105ce1 <sys_open+0x19f>

  begin_op();
80105b80:	e8 ec d5 ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
80105b85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b88:	25 00 02 00 00       	and    $0x200,%eax
80105b8d:	85 c0                	test   %eax,%eax
80105b8f:	74 2a                	je     80105bbb <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105b91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b94:	6a 00                	push   $0x0
80105b96:	6a 00                	push   $0x0
80105b98:	6a 02                	push   $0x2
80105b9a:	50                   	push   %eax
80105b9b:	e8 cc fd ff ff       	call   8010596c <create>
80105ba0:	83 c4 10             	add    $0x10,%esp
80105ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ba6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105baa:	75 75                	jne    80105c21 <sys_open+0xdf>
      end_op();
80105bac:	e8 50 d6 ff ff       	call   80103201 <end_op>
      return -1;
80105bb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb6:	e9 26 01 00 00       	jmp    80105ce1 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105bbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bbe:	83 ec 0c             	sub    $0xc,%esp
80105bc1:	50                   	push   %eax
80105bc2:	e8 20 ca ff ff       	call   801025e7 <namei>
80105bc7:	83 c4 10             	add    $0x10,%esp
80105bca:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bcd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bd1:	75 0f                	jne    80105be2 <sys_open+0xa0>
      end_op();
80105bd3:	e8 29 d6 ff ff       	call   80103201 <end_op>
      return -1;
80105bd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bdd:	e9 ff 00 00 00       	jmp    80105ce1 <sys_open+0x19f>
    }
    ilock(ip);
80105be2:	83 ec 0c             	sub    $0xc,%esp
80105be5:	ff 75 f4             	pushl  -0xc(%ebp)
80105be8:	e8 8f be ff ff       	call   80101a7c <ilock>
80105bed:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf3:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bf7:	66 83 f8 01          	cmp    $0x1,%ax
80105bfb:	75 24                	jne    80105c21 <sys_open+0xdf>
80105bfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c00:	85 c0                	test   %eax,%eax
80105c02:	74 1d                	je     80105c21 <sys_open+0xdf>
      iunlockput(ip);
80105c04:	83 ec 0c             	sub    $0xc,%esp
80105c07:	ff 75 f4             	pushl  -0xc(%ebp)
80105c0a:	e8 aa c0 ff ff       	call   80101cb9 <iunlockput>
80105c0f:	83 c4 10             	add    $0x10,%esp
      end_op();
80105c12:	e8 ea d5 ff ff       	call   80103201 <end_op>
      return -1;
80105c17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1c:	e9 c0 00 00 00       	jmp    80105ce1 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105c21:	e8 fd b3 ff ff       	call   80101023 <filealloc>
80105c26:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c2d:	74 17                	je     80105c46 <sys_open+0x104>
80105c2f:	83 ec 0c             	sub    $0xc,%esp
80105c32:	ff 75 f0             	pushl  -0x10(%ebp)
80105c35:	e8 07 f7 ff ff       	call   80105341 <fdalloc>
80105c3a:	83 c4 10             	add    $0x10,%esp
80105c3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105c40:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c44:	79 2e                	jns    80105c74 <sys_open+0x132>
    if(f)
80105c46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c4a:	74 0e                	je     80105c5a <sys_open+0x118>
      fileclose(f);
80105c4c:	83 ec 0c             	sub    $0xc,%esp
80105c4f:	ff 75 f0             	pushl  -0x10(%ebp)
80105c52:	e8 92 b4 ff ff       	call   801010e9 <fileclose>
80105c57:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105c5a:	83 ec 0c             	sub    $0xc,%esp
80105c5d:	ff 75 f4             	pushl  -0xc(%ebp)
80105c60:	e8 54 c0 ff ff       	call   80101cb9 <iunlockput>
80105c65:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c68:	e8 94 d5 ff ff       	call   80103201 <end_op>
    return -1;
80105c6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c72:	eb 6d                	jmp    80105ce1 <sys_open+0x19f>
  }
  iunlock(ip);
80105c74:	83 ec 0c             	sub    $0xc,%esp
80105c77:	ff 75 f4             	pushl  -0xc(%ebp)
80105c7a:	e8 14 bf ff ff       	call   80101b93 <iunlock>
80105c7f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c82:	e8 7a d5 ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
80105c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c96:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105ca3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ca6:	83 e0 01             	and    $0x1,%eax
80105ca9:	85 c0                	test   %eax,%eax
80105cab:	0f 94 c0             	sete   %al
80105cae:	89 c2                	mov    %eax,%edx
80105cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb3:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105cb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cb9:	83 e0 01             	and    $0x1,%eax
80105cbc:	85 c0                	test   %eax,%eax
80105cbe:	75 0a                	jne    80105cca <sys_open+0x188>
80105cc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cc3:	83 e0 02             	and    $0x2,%eax
80105cc6:	85 c0                	test   %eax,%eax
80105cc8:	74 07                	je     80105cd1 <sys_open+0x18f>
80105cca:	b8 01 00 00 00       	mov    $0x1,%eax
80105ccf:	eb 05                	jmp    80105cd6 <sys_open+0x194>
80105cd1:	b8 00 00 00 00       	mov    $0x0,%eax
80105cd6:	89 c2                	mov    %eax,%edx
80105cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cdb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105cde:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105ce1:	c9                   	leave  
80105ce2:	c3                   	ret    

80105ce3 <sys_mkdir>:

int
sys_mkdir(void)
{
80105ce3:	f3 0f 1e fb          	endbr32 
80105ce7:	55                   	push   %ebp
80105ce8:	89 e5                	mov    %esp,%ebp
80105cea:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105ced:	e8 7f d4 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105cf2:	83 ec 08             	sub    $0x8,%esp
80105cf5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cf8:	50                   	push   %eax
80105cf9:	6a 00                	push   $0x0
80105cfb:	e8 0c f5 ff ff       	call   8010520c <argstr>
80105d00:	83 c4 10             	add    $0x10,%esp
80105d03:	85 c0                	test   %eax,%eax
80105d05:	78 1b                	js     80105d22 <sys_mkdir+0x3f>
80105d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0a:	6a 00                	push   $0x0
80105d0c:	6a 00                	push   $0x0
80105d0e:	6a 01                	push   $0x1
80105d10:	50                   	push   %eax
80105d11:	e8 56 fc ff ff       	call   8010596c <create>
80105d16:	83 c4 10             	add    $0x10,%esp
80105d19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d20:	75 0c                	jne    80105d2e <sys_mkdir+0x4b>
    end_op();
80105d22:	e8 da d4 ff ff       	call   80103201 <end_op>
    return -1;
80105d27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d2c:	eb 18                	jmp    80105d46 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105d2e:	83 ec 0c             	sub    $0xc,%esp
80105d31:	ff 75 f4             	pushl  -0xc(%ebp)
80105d34:	e8 80 bf ff ff       	call   80101cb9 <iunlockput>
80105d39:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d3c:	e8 c0 d4 ff ff       	call   80103201 <end_op>
  return 0;
80105d41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d46:	c9                   	leave  
80105d47:	c3                   	ret    

80105d48 <sys_mknod>:

int
sys_mknod(void)
{
80105d48:	f3 0f 1e fb          	endbr32 
80105d4c:	55                   	push   %ebp
80105d4d:	89 e5                	mov    %esp,%ebp
80105d4f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105d52:	e8 1a d4 ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105d57:	83 ec 08             	sub    $0x8,%esp
80105d5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d5d:	50                   	push   %eax
80105d5e:	6a 00                	push   $0x0
80105d60:	e8 a7 f4 ff ff       	call   8010520c <argstr>
80105d65:	83 c4 10             	add    $0x10,%esp
80105d68:	85 c0                	test   %eax,%eax
80105d6a:	78 4f                	js     80105dbb <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105d6c:	83 ec 08             	sub    $0x8,%esp
80105d6f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d72:	50                   	push   %eax
80105d73:	6a 01                	push   $0x1
80105d75:	e8 f5 f3 ff ff       	call   8010516f <argint>
80105d7a:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d7d:	85 c0                	test   %eax,%eax
80105d7f:	78 3a                	js     80105dbb <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105d81:	83 ec 08             	sub    $0x8,%esp
80105d84:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d87:	50                   	push   %eax
80105d88:	6a 02                	push   $0x2
80105d8a:	e8 e0 f3 ff ff       	call   8010516f <argint>
80105d8f:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d92:	85 c0                	test   %eax,%eax
80105d94:	78 25                	js     80105dbb <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d96:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d99:	0f bf c8             	movswl %ax,%ecx
80105d9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d9f:	0f bf d0             	movswl %ax,%edx
80105da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da5:	51                   	push   %ecx
80105da6:	52                   	push   %edx
80105da7:	6a 03                	push   $0x3
80105da9:	50                   	push   %eax
80105daa:	e8 bd fb ff ff       	call   8010596c <create>
80105daf:	83 c4 10             	add    $0x10,%esp
80105db2:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105db5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105db9:	75 0c                	jne    80105dc7 <sys_mknod+0x7f>
    end_op();
80105dbb:	e8 41 d4 ff ff       	call   80103201 <end_op>
    return -1;
80105dc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc5:	eb 18                	jmp    80105ddf <sys_mknod+0x97>
  }
  iunlockput(ip);
80105dc7:	83 ec 0c             	sub    $0xc,%esp
80105dca:	ff 75 f4             	pushl  -0xc(%ebp)
80105dcd:	e8 e7 be ff ff       	call   80101cb9 <iunlockput>
80105dd2:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dd5:	e8 27 d4 ff ff       	call   80103201 <end_op>
  return 0;
80105dda:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ddf:	c9                   	leave  
80105de0:	c3                   	ret    

80105de1 <sys_chdir>:

int
sys_chdir(void)
{
80105de1:	f3 0f 1e fb          	endbr32 
80105de5:	55                   	push   %ebp
80105de6:	89 e5                	mov    %esp,%ebp
80105de8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105deb:	e8 b9 dd ff ff       	call   80103ba9 <myproc>
80105df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105df3:	e8 79 d3 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105df8:	83 ec 08             	sub    $0x8,%esp
80105dfb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dfe:	50                   	push   %eax
80105dff:	6a 00                	push   $0x0
80105e01:	e8 06 f4 ff ff       	call   8010520c <argstr>
80105e06:	83 c4 10             	add    $0x10,%esp
80105e09:	85 c0                	test   %eax,%eax
80105e0b:	78 18                	js     80105e25 <sys_chdir+0x44>
80105e0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105e10:	83 ec 0c             	sub    $0xc,%esp
80105e13:	50                   	push   %eax
80105e14:	e8 ce c7 ff ff       	call   801025e7 <namei>
80105e19:	83 c4 10             	add    $0x10,%esp
80105e1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e23:	75 0c                	jne    80105e31 <sys_chdir+0x50>
    end_op();
80105e25:	e8 d7 d3 ff ff       	call   80103201 <end_op>
    return -1;
80105e2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e2f:	eb 68                	jmp    80105e99 <sys_chdir+0xb8>
  }
  ilock(ip);
80105e31:	83 ec 0c             	sub    $0xc,%esp
80105e34:	ff 75 f0             	pushl  -0x10(%ebp)
80105e37:	e8 40 bc ff ff       	call   80101a7c <ilock>
80105e3c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e42:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e46:	66 83 f8 01          	cmp    $0x1,%ax
80105e4a:	74 1a                	je     80105e66 <sys_chdir+0x85>
    iunlockput(ip);
80105e4c:	83 ec 0c             	sub    $0xc,%esp
80105e4f:	ff 75 f0             	pushl  -0x10(%ebp)
80105e52:	e8 62 be ff ff       	call   80101cb9 <iunlockput>
80105e57:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e5a:	e8 a2 d3 ff ff       	call   80103201 <end_op>
    return -1;
80105e5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e64:	eb 33                	jmp    80105e99 <sys_chdir+0xb8>
  }
  iunlock(ip);
80105e66:	83 ec 0c             	sub    $0xc,%esp
80105e69:	ff 75 f0             	pushl  -0x10(%ebp)
80105e6c:	e8 22 bd ff ff       	call   80101b93 <iunlock>
80105e71:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e77:	8b 40 68             	mov    0x68(%eax),%eax
80105e7a:	83 ec 0c             	sub    $0xc,%esp
80105e7d:	50                   	push   %eax
80105e7e:	e8 62 bd ff ff       	call   80101be5 <iput>
80105e83:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e86:	e8 76 d3 ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
80105e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e91:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e94:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e99:	c9                   	leave  
80105e9a:	c3                   	ret    

80105e9b <sys_exec>:

int
sys_exec(void)
{
80105e9b:	f3 0f 1e fb          	endbr32 
80105e9f:	55                   	push   %ebp
80105ea0:	89 e5                	mov    %esp,%ebp
80105ea2:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ea8:	83 ec 08             	sub    $0x8,%esp
80105eab:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105eae:	50                   	push   %eax
80105eaf:	6a 00                	push   $0x0
80105eb1:	e8 56 f3 ff ff       	call   8010520c <argstr>
80105eb6:	83 c4 10             	add    $0x10,%esp
80105eb9:	85 c0                	test   %eax,%eax
80105ebb:	78 18                	js     80105ed5 <sys_exec+0x3a>
80105ebd:	83 ec 08             	sub    $0x8,%esp
80105ec0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105ec6:	50                   	push   %eax
80105ec7:	6a 01                	push   $0x1
80105ec9:	e8 a1 f2 ff ff       	call   8010516f <argint>
80105ece:	83 c4 10             	add    $0x10,%esp
80105ed1:	85 c0                	test   %eax,%eax
80105ed3:	79 0a                	jns    80105edf <sys_exec+0x44>
    return -1;
80105ed5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eda:	e9 c6 00 00 00       	jmp    80105fa5 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80105edf:	83 ec 04             	sub    $0x4,%esp
80105ee2:	68 80 00 00 00       	push   $0x80
80105ee7:	6a 00                	push   $0x0
80105ee9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105eef:	50                   	push   %eax
80105ef0:	e8 26 ef ff ff       	call   80104e1b <memset>
80105ef5:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105ef8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f02:	83 f8 1f             	cmp    $0x1f,%eax
80105f05:	76 0a                	jbe    80105f11 <sys_exec+0x76>
      return -1;
80105f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f0c:	e9 94 00 00 00       	jmp    80105fa5 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f14:	c1 e0 02             	shl    $0x2,%eax
80105f17:	89 c2                	mov    %eax,%edx
80105f19:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105f1f:	01 c2                	add    %eax,%edx
80105f21:	83 ec 08             	sub    $0x8,%esp
80105f24:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105f2a:	50                   	push   %eax
80105f2b:	52                   	push   %edx
80105f2c:	e8 93 f1 ff ff       	call   801050c4 <fetchint>
80105f31:	83 c4 10             	add    $0x10,%esp
80105f34:	85 c0                	test   %eax,%eax
80105f36:	79 07                	jns    80105f3f <sys_exec+0xa4>
      return -1;
80105f38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f3d:	eb 66                	jmp    80105fa5 <sys_exec+0x10a>
    if(uarg == 0){
80105f3f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f45:	85 c0                	test   %eax,%eax
80105f47:	75 27                	jne    80105f70 <sys_exec+0xd5>
      argv[i] = 0;
80105f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105f53:	00 00 00 00 
      break;
80105f57:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105f58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5b:	83 ec 08             	sub    $0x8,%esp
80105f5e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f64:	52                   	push   %edx
80105f65:	50                   	push   %eax
80105f66:	e8 53 ac ff ff       	call   80100bbe <exec>
80105f6b:	83 c4 10             	add    $0x10,%esp
80105f6e:	eb 35                	jmp    80105fa5 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80105f70:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105f76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f79:	c1 e2 02             	shl    $0x2,%edx
80105f7c:	01 c2                	add    %eax,%edx
80105f7e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f84:	83 ec 08             	sub    $0x8,%esp
80105f87:	52                   	push   %edx
80105f88:	50                   	push   %eax
80105f89:	e8 79 f1 ff ff       	call   80105107 <fetchstr>
80105f8e:	83 c4 10             	add    $0x10,%esp
80105f91:	85 c0                	test   %eax,%eax
80105f93:	79 07                	jns    80105f9c <sys_exec+0x101>
      return -1;
80105f95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f9a:	eb 09                	jmp    80105fa5 <sys_exec+0x10a>
  for(i=0;; i++){
80105f9c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105fa0:	e9 5a ff ff ff       	jmp    80105eff <sys_exec+0x64>
}
80105fa5:	c9                   	leave  
80105fa6:	c3                   	ret    

80105fa7 <sys_pipe>:

int
sys_pipe(void)
{
80105fa7:	f3 0f 1e fb          	endbr32 
80105fab:	55                   	push   %ebp
80105fac:	89 e5                	mov    %esp,%ebp
80105fae:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105fb1:	83 ec 04             	sub    $0x4,%esp
80105fb4:	6a 08                	push   $0x8
80105fb6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fb9:	50                   	push   %eax
80105fba:	6a 00                	push   $0x0
80105fbc:	e8 df f1 ff ff       	call   801051a0 <argptr>
80105fc1:	83 c4 10             	add    $0x10,%esp
80105fc4:	85 c0                	test   %eax,%eax
80105fc6:	79 0a                	jns    80105fd2 <sys_pipe+0x2b>
    return -1;
80105fc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fcd:	e9 ae 00 00 00       	jmp    80106080 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80105fd2:	83 ec 08             	sub    $0x8,%esp
80105fd5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fd8:	50                   	push   %eax
80105fd9:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fdc:	50                   	push   %eax
80105fdd:	e8 e8 d6 ff ff       	call   801036ca <pipealloc>
80105fe2:	83 c4 10             	add    $0x10,%esp
80105fe5:	85 c0                	test   %eax,%eax
80105fe7:	79 0a                	jns    80105ff3 <sys_pipe+0x4c>
    return -1;
80105fe9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fee:	e9 8d 00 00 00       	jmp    80106080 <sys_pipe+0xd9>
  fd0 = -1;
80105ff3:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105ffa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ffd:	83 ec 0c             	sub    $0xc,%esp
80106000:	50                   	push   %eax
80106001:	e8 3b f3 ff ff       	call   80105341 <fdalloc>
80106006:	83 c4 10             	add    $0x10,%esp
80106009:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010600c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106010:	78 18                	js     8010602a <sys_pipe+0x83>
80106012:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106015:	83 ec 0c             	sub    $0xc,%esp
80106018:	50                   	push   %eax
80106019:	e8 23 f3 ff ff       	call   80105341 <fdalloc>
8010601e:	83 c4 10             	add    $0x10,%esp
80106021:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106024:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106028:	79 3e                	jns    80106068 <sys_pipe+0xc1>
    if(fd0 >= 0)
8010602a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010602e:	78 13                	js     80106043 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106030:	e8 74 db ff ff       	call   80103ba9 <myproc>
80106035:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106038:	83 c2 08             	add    $0x8,%edx
8010603b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106042:	00 
    fileclose(rf);
80106043:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106046:	83 ec 0c             	sub    $0xc,%esp
80106049:	50                   	push   %eax
8010604a:	e8 9a b0 ff ff       	call   801010e9 <fileclose>
8010604f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106052:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106055:	83 ec 0c             	sub    $0xc,%esp
80106058:	50                   	push   %eax
80106059:	e8 8b b0 ff ff       	call   801010e9 <fileclose>
8010605e:	83 c4 10             	add    $0x10,%esp
    return -1;
80106061:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106066:	eb 18                	jmp    80106080 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106068:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010606b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010606e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106070:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106073:	8d 50 04             	lea    0x4(%eax),%edx
80106076:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106079:	89 02                	mov    %eax,(%edx)
  return 0;
8010607b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106080:	c9                   	leave  
80106081:	c3                   	ret    

80106082 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106082:	f3 0f 1e fb          	endbr32 
80106086:	55                   	push   %ebp
80106087:	89 e5                	mov    %esp,%ebp
80106089:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010608c:	e8 3b de ff ff       	call   80103ecc <fork>
}
80106091:	c9                   	leave  
80106092:	c3                   	ret    

80106093 <sys_exit>:

int
sys_exit(void)
{
80106093:	f3 0f 1e fb          	endbr32 
80106097:	55                   	push   %ebp
80106098:	89 e5                	mov    %esp,%ebp
8010609a:	83 ec 08             	sub    $0x8,%esp
  exit();
8010609d:	e8 a7 df ff ff       	call   80104049 <exit>
  return 0;  // not reached
801060a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060a7:	c9                   	leave  
801060a8:	c3                   	ret    

801060a9 <sys_wait>:

int
sys_wait(void)
{
801060a9:	f3 0f 1e fb          	endbr32 
801060ad:	55                   	push   %ebp
801060ae:	89 e5                	mov    %esp,%ebp
801060b0:	83 ec 08             	sub    $0x8,%esp
  return wait();
801060b3:	e8 f5 e1 ff ff       	call   801042ad <wait>
}
801060b8:	c9                   	leave  
801060b9:	c3                   	ret    

801060ba <sys_kill>:

int
sys_kill(void)
{
801060ba:	f3 0f 1e fb          	endbr32 
801060be:	55                   	push   %ebp
801060bf:	89 e5                	mov    %esp,%ebp
801060c1:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801060c4:	83 ec 08             	sub    $0x8,%esp
801060c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060ca:	50                   	push   %eax
801060cb:	6a 00                	push   $0x0
801060cd:	e8 9d f0 ff ff       	call   8010516f <argint>
801060d2:	83 c4 10             	add    $0x10,%esp
801060d5:	85 c0                	test   %eax,%eax
801060d7:	79 07                	jns    801060e0 <sys_kill+0x26>
    return -1;
801060d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060de:	eb 0f                	jmp    801060ef <sys_kill+0x35>
  return kill(pid);
801060e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e3:	83 ec 0c             	sub    $0xc,%esp
801060e6:	50                   	push   %eax
801060e7:	e8 81 e7 ff ff       	call   8010486d <kill>
801060ec:	83 c4 10             	add    $0x10,%esp
}
801060ef:	c9                   	leave  
801060f0:	c3                   	ret    

801060f1 <sys_getpid>:

int
sys_getpid(void)
{
801060f1:	f3 0f 1e fb          	endbr32 
801060f5:	55                   	push   %ebp
801060f6:	89 e5                	mov    %esp,%ebp
801060f8:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801060fb:	e8 a9 da ff ff       	call   80103ba9 <myproc>
80106100:	8b 40 10             	mov    0x10(%eax),%eax
}
80106103:	c9                   	leave  
80106104:	c3                   	ret    

80106105 <sys_sbrk>:

int
sys_sbrk(void)
{
80106105:	f3 0f 1e fb          	endbr32 
80106109:	55                   	push   %ebp
8010610a:	89 e5                	mov    %esp,%ebp
8010610c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010610f:	83 ec 08             	sub    $0x8,%esp
80106112:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106115:	50                   	push   %eax
80106116:	6a 00                	push   $0x0
80106118:	e8 52 f0 ff ff       	call   8010516f <argint>
8010611d:	83 c4 10             	add    $0x10,%esp
80106120:	85 c0                	test   %eax,%eax
80106122:	79 07                	jns    8010612b <sys_sbrk+0x26>
    return -1;
80106124:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106129:	eb 27                	jmp    80106152 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010612b:	e8 79 da ff ff       	call   80103ba9 <myproc>
80106130:	8b 00                	mov    (%eax),%eax
80106132:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106138:	83 ec 0c             	sub    $0xc,%esp
8010613b:	50                   	push   %eax
8010613c:	e8 ec dc ff ff       	call   80103e2d <growproc>
80106141:	83 c4 10             	add    $0x10,%esp
80106144:	85 c0                	test   %eax,%eax
80106146:	79 07                	jns    8010614f <sys_sbrk+0x4a>
    return -1;
80106148:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614d:	eb 03                	jmp    80106152 <sys_sbrk+0x4d>
  return addr;
8010614f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106152:	c9                   	leave  
80106153:	c3                   	ret    

80106154 <sys_sleep>:

int
sys_sleep(void)
{
80106154:	f3 0f 1e fb          	endbr32 
80106158:	55                   	push   %ebp
80106159:	89 e5                	mov    %esp,%ebp
8010615b:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010615e:	83 ec 08             	sub    $0x8,%esp
80106161:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106164:	50                   	push   %eax
80106165:	6a 00                	push   $0x0
80106167:	e8 03 f0 ff ff       	call   8010516f <argint>
8010616c:	83 c4 10             	add    $0x10,%esp
8010616f:	85 c0                	test   %eax,%eax
80106171:	79 07                	jns    8010617a <sys_sleep+0x26>
    return -1;
80106173:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106178:	eb 76                	jmp    801061f0 <sys_sleep+0x9c>
  acquire(&tickslock);
8010617a:	83 ec 0c             	sub    $0xc,%esp
8010617d:	68 40 76 19 80       	push   $0x80197640
80106182:	e8 05 ea ff ff       	call   80104b8c <acquire>
80106187:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010618a:	a1 80 7e 19 80       	mov    0x80197e80,%eax
8010618f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106192:	eb 38                	jmp    801061cc <sys_sleep+0x78>
    if(myproc()->killed){
80106194:	e8 10 da ff ff       	call   80103ba9 <myproc>
80106199:	8b 40 24             	mov    0x24(%eax),%eax
8010619c:	85 c0                	test   %eax,%eax
8010619e:	74 17                	je     801061b7 <sys_sleep+0x63>
      release(&tickslock);
801061a0:	83 ec 0c             	sub    $0xc,%esp
801061a3:	68 40 76 19 80       	push   $0x80197640
801061a8:	e8 51 ea ff ff       	call   80104bfe <release>
801061ad:	83 c4 10             	add    $0x10,%esp
      return -1;
801061b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b5:	eb 39                	jmp    801061f0 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801061b7:	83 ec 08             	sub    $0x8,%esp
801061ba:	68 40 76 19 80       	push   $0x80197640
801061bf:	68 80 7e 19 80       	push   $0x80197e80
801061c4:	e8 77 e5 ff ff       	call   80104740 <sleep>
801061c9:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801061cc:	a1 80 7e 19 80       	mov    0x80197e80,%eax
801061d1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801061d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061d7:	39 d0                	cmp    %edx,%eax
801061d9:	72 b9                	jb     80106194 <sys_sleep+0x40>
  }
  release(&tickslock);
801061db:	83 ec 0c             	sub    $0xc,%esp
801061de:	68 40 76 19 80       	push   $0x80197640
801061e3:	e8 16 ea ff ff       	call   80104bfe <release>
801061e8:	83 c4 10             	add    $0x10,%esp
  return 0;
801061eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061f0:	c9                   	leave  
801061f1:	c3                   	ret    

801061f2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801061f2:	f3 0f 1e fb          	endbr32 
801061f6:	55                   	push   %ebp
801061f7:	89 e5                	mov    %esp,%ebp
801061f9:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801061fc:	83 ec 0c             	sub    $0xc,%esp
801061ff:	68 40 76 19 80       	push   $0x80197640
80106204:	e8 83 e9 ff ff       	call   80104b8c <acquire>
80106209:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010620c:	a1 80 7e 19 80       	mov    0x80197e80,%eax
80106211:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106214:	83 ec 0c             	sub    $0xc,%esp
80106217:	68 40 76 19 80       	push   $0x80197640
8010621c:	e8 dd e9 ff ff       	call   80104bfe <release>
80106221:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106224:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106227:	c9                   	leave  
80106228:	c3                   	ret    

80106229 <sys_exit2>:

int
sys_exit2(void)
{
80106229:	f3 0f 1e fb          	endbr32 
8010622d:	55                   	push   %ebp
8010622e:	89 e5                	mov    %esp,%ebp
80106230:	83 ec 18             	sub    $0x18,%esp
  int status;
  if(argint(0, &status) < 0)
80106233:	83 ec 08             	sub    $0x8,%esp
80106236:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106239:	50                   	push   %eax
8010623a:	6a 00                	push   $0x0
8010623c:	e8 2e ef ff ff       	call   8010516f <argint>
80106241:	83 c4 10             	add    $0x10,%esp
80106244:	85 c0                	test   %eax,%eax
80106246:	79 07                	jns    8010624f <sys_exit2+0x26>
    return -1; 
80106248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624d:	eb 15                	jmp    80106264 <sys_exit2+0x3b>

  myproc()->xstate = status;
8010624f:	e8 55 d9 ff ff       	call   80103ba9 <myproc>
80106254:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106257:	89 50 7c             	mov    %edx,0x7c(%eax)
  exit();
8010625a:	e8 ea dd ff ff       	call   80104049 <exit>
  return 0;
8010625f:	b8 00 00 00 00       	mov    $0x0,%eax
}	
80106264:	c9                   	leave  
80106265:	c3                   	ret    

80106266 <sys_wait2>:

extern int wait2(int *status);

int sys_wait2(void) 
{
80106266:	f3 0f 1e fb          	endbr32 
8010626a:	55                   	push   %ebp
8010626b:	89 e5                	mov    %esp,%ebp
8010626d:	83 ec 18             	sub    $0x18,%esp
  int *status;
  if(argptr(0, (void *)&status, sizeof(*status)) < 0)
80106270:	83 ec 04             	sub    $0x4,%esp
80106273:	6a 04                	push   $0x4
80106275:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106278:	50                   	push   %eax
80106279:	6a 00                	push   $0x0
8010627b:	e8 20 ef ff ff       	call   801051a0 <argptr>
80106280:	83 c4 10             	add    $0x10,%esp
80106283:	85 c0                	test   %eax,%eax
80106285:	79 07                	jns    8010628e <sys_wait2+0x28>
    return -1;
80106287:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010628c:	eb 0f                	jmp    8010629d <sys_wait2+0x37>
  return wait2(status);
8010628e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106291:	83 ec 0c             	sub    $0xc,%esp
80106294:	50                   	push   %eax
80106295:	e8 3a e1 ff ff       	call   801043d4 <wait2>
8010629a:	83 c4 10             	add    $0x10,%esp
}
8010629d:	c9                   	leave  
8010629e:	c3                   	ret    

8010629f <sys_uthread_init>:

int
sys_uthread_init(void)
{
8010629f:	f3 0f 1e fb          	endbr32 
801062a3:	55                   	push   %ebp
801062a4:	89 e5                	mov    %esp,%ebp
801062a6:	83 ec 18             	sub    $0x18,%esp
    struct proc* p;
    int func;

    if (argint(0, &func) < 0)
801062a9:	83 ec 08             	sub    $0x8,%esp
801062ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062af:	50                   	push   %eax
801062b0:	6a 00                	push   $0x0
801062b2:	e8 b8 ee ff ff       	call   8010516f <argint>
801062b7:	83 c4 10             	add    $0x10,%esp
801062ba:	85 c0                	test   %eax,%eax
801062bc:	79 07                	jns    801062c5 <sys_uthread_init+0x26>
        return -1;
801062be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c3:	eb 1b                	jmp    801062e0 <sys_uthread_init+0x41>

    p = myproc();
801062c5:	e8 df d8 ff ff       	call   80103ba9 <myproc>
801062ca:	89 45 f4             	mov    %eax,-0xc(%ebp)

    p->scheduler = (uint)func;
801062cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d0:	89 c2                	mov    %eax,%edx
801062d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d5:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

    return 0;
801062db:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062e0:	c9                   	leave  
801062e1:	c3                   	ret    

801062e2 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801062e2:	1e                   	push   %ds
  pushl %es
801062e3:	06                   	push   %es
  pushl %fs
801062e4:	0f a0                	push   %fs
  pushl %gs
801062e6:	0f a8                	push   %gs
  pushal
801062e8:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801062e9:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801062ed:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801062ef:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801062f1:	54                   	push   %esp
  call trap
801062f2:	e8 df 01 00 00       	call   801064d6 <trap>
  addl $4, %esp
801062f7:	83 c4 04             	add    $0x4,%esp

801062fa <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801062fa:	61                   	popa   
  popl %gs
801062fb:	0f a9                	pop    %gs
  popl %fs
801062fd:	0f a1                	pop    %fs
  popl %es
801062ff:	07                   	pop    %es
  popl %ds
80106300:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106301:	83 c4 08             	add    $0x8,%esp
  iret
80106304:	cf                   	iret   

80106305 <lidt>:
{
80106305:	55                   	push   %ebp
80106306:	89 e5                	mov    %esp,%ebp
80106308:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010630b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010630e:	83 e8 01             	sub    $0x1,%eax
80106311:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106315:	8b 45 08             	mov    0x8(%ebp),%eax
80106318:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010631c:	8b 45 08             	mov    0x8(%ebp),%eax
8010631f:	c1 e8 10             	shr    $0x10,%eax
80106322:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106326:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106329:	0f 01 18             	lidtl  (%eax)
}
8010632c:	90                   	nop
8010632d:	c9                   	leave  
8010632e:	c3                   	ret    

8010632f <rcr2>:

static inline uint
rcr2(void)
{
8010632f:	55                   	push   %ebp
80106330:	89 e5                	mov    %esp,%ebp
80106332:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106335:	0f 20 d0             	mov    %cr2,%eax
80106338:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010633b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010633e:	c9                   	leave  
8010633f:	c3                   	ret    

80106340 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106340:	f3 0f 1e fb          	endbr32 
80106344:	55                   	push   %ebp
80106345:	89 e5                	mov    %esp,%ebp
80106347:	83 ec 18             	sub    $0x18,%esp
    int i;

    for (i = 0; i < 256; i++)
8010634a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106351:	e9 c3 00 00 00       	jmp    80106419 <tvinit+0xd9>
        SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
80106356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106359:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80106360:	89 c2                	mov    %eax,%edx
80106362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106365:	66 89 14 c5 80 76 19 	mov    %dx,-0x7fe68980(,%eax,8)
8010636c:	80 
8010636d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106370:	66 c7 04 c5 82 76 19 	movw   $0x8,-0x7fe6897e(,%eax,8)
80106377:	80 08 00 
8010637a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637d:	0f b6 14 c5 84 76 19 	movzbl -0x7fe6897c(,%eax,8),%edx
80106384:	80 
80106385:	83 e2 e0             	and    $0xffffffe0,%edx
80106388:	88 14 c5 84 76 19 80 	mov    %dl,-0x7fe6897c(,%eax,8)
8010638f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106392:	0f b6 14 c5 84 76 19 	movzbl -0x7fe6897c(,%eax,8),%edx
80106399:	80 
8010639a:	83 e2 1f             	and    $0x1f,%edx
8010639d:	88 14 c5 84 76 19 80 	mov    %dl,-0x7fe6897c(,%eax,8)
801063a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a7:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
801063ae:	80 
801063af:	83 e2 f0             	and    $0xfffffff0,%edx
801063b2:	83 ca 0e             	or     $0xe,%edx
801063b5:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
801063bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063bf:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
801063c6:	80 
801063c7:	83 e2 ef             	and    $0xffffffef,%edx
801063ca:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
801063d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d4:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
801063db:	80 
801063dc:	83 e2 9f             	and    $0xffffff9f,%edx
801063df:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
801063e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e9:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
801063f0:	80 
801063f1:	83 ca 80             	or     $0xffffff80,%edx
801063f4:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
801063fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fe:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80106405:	c1 e8 10             	shr    $0x10,%eax
80106408:	89 c2                	mov    %eax,%edx
8010640a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640d:	66 89 14 c5 86 76 19 	mov    %dx,-0x7fe6897a(,%eax,8)
80106414:	80 
    for (i = 0; i < 256; i++)
80106415:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106419:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106420:	0f 8e 30 ff ff ff    	jle    80106356 <tvinit+0x16>
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
80106426:	a1 84 f1 10 80       	mov    0x8010f184,%eax
8010642b:	66 a3 80 78 19 80    	mov    %ax,0x80197880
80106431:	66 c7 05 82 78 19 80 	movw   $0x8,0x80197882
80106438:	08 00 
8010643a:	0f b6 05 84 78 19 80 	movzbl 0x80197884,%eax
80106441:	83 e0 e0             	and    $0xffffffe0,%eax
80106444:	a2 84 78 19 80       	mov    %al,0x80197884
80106449:	0f b6 05 84 78 19 80 	movzbl 0x80197884,%eax
80106450:	83 e0 1f             	and    $0x1f,%eax
80106453:	a2 84 78 19 80       	mov    %al,0x80197884
80106458:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
8010645f:	83 c8 0f             	or     $0xf,%eax
80106462:	a2 85 78 19 80       	mov    %al,0x80197885
80106467:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
8010646e:	83 e0 ef             	and    $0xffffffef,%eax
80106471:	a2 85 78 19 80       	mov    %al,0x80197885
80106476:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
8010647d:	83 c8 60             	or     $0x60,%eax
80106480:	a2 85 78 19 80       	mov    %al,0x80197885
80106485:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
8010648c:	83 c8 80             	or     $0xffffff80,%eax
8010648f:	a2 85 78 19 80       	mov    %al,0x80197885
80106494:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80106499:	c1 e8 10             	shr    $0x10,%eax
8010649c:	66 a3 86 78 19 80    	mov    %ax,0x80197886

    initlock(&tickslock, "time");
801064a2:	83 ec 08             	sub    $0x8,%esp
801064a5:	68 38 ab 10 80       	push   $0x8010ab38
801064aa:	68 40 76 19 80       	push   $0x80197640
801064af:	e8 b2 e6 ff ff       	call   80104b66 <initlock>
801064b4:	83 c4 10             	add    $0x10,%esp
}
801064b7:	90                   	nop
801064b8:	c9                   	leave  
801064b9:	c3                   	ret    

801064ba <idtinit>:

void
idtinit(void)
{
801064ba:	f3 0f 1e fb          	endbr32 
801064be:	55                   	push   %ebp
801064bf:	89 e5                	mov    %esp,%ebp
    lidt(idt, sizeof(idt));
801064c1:	68 00 08 00 00       	push   $0x800
801064c6:	68 80 76 19 80       	push   $0x80197680
801064cb:	e8 35 fe ff ff       	call   80106305 <lidt>
801064d0:	83 c4 08             	add    $0x8,%esp
}
801064d3:	90                   	nop
801064d4:	c9                   	leave  
801064d5:	c3                   	ret    

801064d6 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe* tf)
{
801064d6:	f3 0f 1e fb          	endbr32 
801064da:	55                   	push   %ebp
801064db:	89 e5                	mov    %esp,%ebp
801064dd:	57                   	push   %edi
801064de:	56                   	push   %esi
801064df:	53                   	push   %ebx
801064e0:	83 ec 2c             	sub    $0x2c,%esp
    if (tf->trapno == T_SYSCALL) {
801064e3:	8b 45 08             	mov    0x8(%ebp),%eax
801064e6:	8b 40 30             	mov    0x30(%eax),%eax
801064e9:	83 f8 40             	cmp    $0x40,%eax
801064ec:	75 3b                	jne    80106529 <trap+0x53>
        if (myproc()->killed)
801064ee:	e8 b6 d6 ff ff       	call   80103ba9 <myproc>
801064f3:	8b 40 24             	mov    0x24(%eax),%eax
801064f6:	85 c0                	test   %eax,%eax
801064f8:	74 05                	je     801064ff <trap+0x29>
            exit();
801064fa:	e8 4a db ff ff       	call   80104049 <exit>
        myproc()->tf = tf;
801064ff:	e8 a5 d6 ff ff       	call   80103ba9 <myproc>
80106504:	8b 55 08             	mov    0x8(%ebp),%edx
80106507:	89 50 18             	mov    %edx,0x18(%eax)
        syscall();
8010650a:	e8 38 ed ff ff       	call   80105247 <syscall>
        if (myproc()->killed)
8010650f:	e8 95 d6 ff ff       	call   80103ba9 <myproc>
80106514:	8b 40 24             	mov    0x24(%eax),%eax
80106517:	85 c0                	test   %eax,%eax
80106519:	0f 84 5d 02 00 00    	je     8010677c <trap+0x2a6>
            exit();
8010651f:	e8 25 db ff ff       	call   80104049 <exit>
        return;
80106524:	e9 53 02 00 00       	jmp    8010677c <trap+0x2a6>
    }

    switch (tf->trapno) {
80106529:	8b 45 08             	mov    0x8(%ebp),%eax
8010652c:	8b 40 30             	mov    0x30(%eax),%eax
8010652f:	83 e8 20             	sub    $0x20,%eax
80106532:	83 f8 1f             	cmp    $0x1f,%eax
80106535:	0f 87 09 01 00 00    	ja     80106644 <trap+0x16e>
8010653b:	8b 04 85 e0 ab 10 80 	mov    -0x7fef5420(,%eax,4),%eax
80106542:	3e ff e0             	notrack jmp *%eax
    case T_IRQ0 + IRQ_TIMER:
        if (cpuid() == 0) {
80106545:	e8 c4 d5 ff ff       	call   80103b0e <cpuid>
8010654a:	85 c0                	test   %eax,%eax
8010654c:	75 3d                	jne    8010658b <trap+0xb5>
            acquire(&tickslock);
8010654e:	83 ec 0c             	sub    $0xc,%esp
80106551:	68 40 76 19 80       	push   $0x80197640
80106556:	e8 31 e6 ff ff       	call   80104b8c <acquire>
8010655b:	83 c4 10             	add    $0x10,%esp
            ticks++;
8010655e:	a1 80 7e 19 80       	mov    0x80197e80,%eax
80106563:	83 c0 01             	add    $0x1,%eax
80106566:	a3 80 7e 19 80       	mov    %eax,0x80197e80
            wakeup(&ticks);
8010656b:	83 ec 0c             	sub    $0xc,%esp
8010656e:	68 80 7e 19 80       	push   $0x80197e80
80106573:	e8 ba e2 ff ff       	call   80104832 <wakeup>
80106578:	83 c4 10             	add    $0x10,%esp
            release(&tickslock);
8010657b:	83 ec 0c             	sub    $0xc,%esp
8010657e:	68 40 76 19 80       	push   $0x80197640
80106583:	e8 76 e6 ff ff       	call   80104bfe <release>
80106588:	83 c4 10             	add    $0x10,%esp
        }
        lapiceoi();  // Acknowledge the interrupt
8010658b:	e8 95 c6 ff ff       	call   80102c25 <lapiceoi>

        // After acknowledging the timer interrupt, check if we need to switch threads.
        struct proc* curproc = myproc();
80106590:	e8 14 d6 ff ff       	call   80103ba9 <myproc>
80106595:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (curproc && curproc->scheduler && (tf->cs & 3) == DPL_USER) {
80106598:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010659c:	0f 84 59 01 00 00    	je     801066fb <trap+0x225>
801065a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065a5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801065ab:	85 c0                	test   %eax,%eax
801065ad:	0f 84 48 01 00 00    	je     801066fb <trap+0x225>
801065b3:	8b 45 08             	mov    0x8(%ebp),%eax
801065b6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801065ba:	0f b7 c0             	movzwl %ax,%eax
801065bd:	83 e0 03             	and    $0x3,%eax
801065c0:	83 f8 03             	cmp    $0x3,%eax
801065c3:	0f 85 32 01 00 00    	jne    801066fb <trap+0x225>
            // Only switch threads if the current process has a user-level scheduler
            // and the trap occurred in user mode.
            ((void(*)(void))curproc->scheduler)();  // Call the user-level scheduler
801065c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065cc:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801065d2:	ff d0                	call   *%eax
	    return;
801065d4:	e9 a4 01 00 00       	jmp    8010677d <trap+0x2a7>
        }
        break;
    case T_IRQ0 + IRQ_IDE:
        ideintr();
801065d9:	e8 1e 40 00 00       	call   8010a5fc <ideintr>
        lapiceoi();
801065de:	e8 42 c6 ff ff       	call   80102c25 <lapiceoi>
        break;
801065e3:	e9 14 01 00 00       	jmp    801066fc <trap+0x226>
    case T_IRQ0 + IRQ_IDE + 1:
        // Bochs generates spurious IDE1 interrupts.
        break;
    case T_IRQ0 + IRQ_KBD:
        kbdintr();
801065e8:	e8 6e c4 ff ff       	call   80102a5b <kbdintr>
        lapiceoi();
801065ed:	e8 33 c6 ff ff       	call   80102c25 <lapiceoi>
        break;
801065f2:	e9 05 01 00 00       	jmp    801066fc <trap+0x226>
    case T_IRQ0 + IRQ_COM1:
        uartintr();
801065f7:	e8 62 03 00 00       	call   8010695e <uartintr>
        lapiceoi();
801065fc:	e8 24 c6 ff ff       	call   80102c25 <lapiceoi>
        break;
80106601:	e9 f6 00 00 00       	jmp    801066fc <trap+0x226>
    case T_IRQ0 + 0xB:
        i8254_intr();
80106606:	e8 30 2c 00 00       	call   8010923b <i8254_intr>
        lapiceoi();
8010660b:	e8 15 c6 ff ff       	call   80102c25 <lapiceoi>
        break;
80106610:	e9 e7 00 00 00       	jmp    801066fc <trap+0x226>
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106615:	8b 45 08             	mov    0x8(%ebp),%eax
80106618:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010661b:	8b 45 08             	mov    0x8(%ebp),%eax
8010661e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106622:	0f b7 d8             	movzwl %ax,%ebx
80106625:	e8 e4 d4 ff ff       	call   80103b0e <cpuid>
8010662a:	56                   	push   %esi
8010662b:	53                   	push   %ebx
8010662c:	50                   	push   %eax
8010662d:	68 40 ab 10 80       	push   $0x8010ab40
80106632:	e8 d5 9d ff ff       	call   8010040c <cprintf>
80106637:	83 c4 10             	add    $0x10,%esp
        lapiceoi();
8010663a:	e8 e6 c5 ff ff       	call   80102c25 <lapiceoi>
        break;
8010663f:	e9 b8 00 00 00       	jmp    801066fc <trap+0x226>

        //PAGEBREAK: 13
    default:
        if (myproc() == 0 || (tf->cs & 3) == 0) {
80106644:	e8 60 d5 ff ff       	call   80103ba9 <myproc>
80106649:	85 c0                	test   %eax,%eax
8010664b:	74 11                	je     8010665e <trap+0x188>
8010664d:	8b 45 08             	mov    0x8(%ebp),%eax
80106650:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106654:	0f b7 c0             	movzwl %ax,%eax
80106657:	83 e0 03             	and    $0x3,%eax
8010665a:	85 c0                	test   %eax,%eax
8010665c:	75 39                	jne    80106697 <trap+0x1c1>
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010665e:	e8 cc fc ff ff       	call   8010632f <rcr2>
80106663:	89 c3                	mov    %eax,%ebx
80106665:	8b 45 08             	mov    0x8(%ebp),%eax
80106668:	8b 70 38             	mov    0x38(%eax),%esi
8010666b:	e8 9e d4 ff ff       	call   80103b0e <cpuid>
80106670:	8b 55 08             	mov    0x8(%ebp),%edx
80106673:	8b 52 30             	mov    0x30(%edx),%edx
80106676:	83 ec 0c             	sub    $0xc,%esp
80106679:	53                   	push   %ebx
8010667a:	56                   	push   %esi
8010667b:	50                   	push   %eax
8010667c:	52                   	push   %edx
8010667d:	68 64 ab 10 80       	push   $0x8010ab64
80106682:	e8 85 9d ff ff       	call   8010040c <cprintf>
80106687:	83 c4 20             	add    $0x20,%esp
                tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
8010668a:	83 ec 0c             	sub    $0xc,%esp
8010668d:	68 96 ab 10 80       	push   $0x8010ab96
80106692:	e8 2e 9f ff ff       	call   801005c5 <panic>
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106697:	e8 93 fc ff ff       	call   8010632f <rcr2>
8010669c:	89 c6                	mov    %eax,%esi
8010669e:	8b 45 08             	mov    0x8(%ebp),%eax
801066a1:	8b 40 38             	mov    0x38(%eax),%eax
801066a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801066a7:	e8 62 d4 ff ff       	call   80103b0e <cpuid>
801066ac:	89 c3                	mov    %eax,%ebx
801066ae:	8b 45 08             	mov    0x8(%ebp),%eax
801066b1:	8b 48 34             	mov    0x34(%eax),%ecx
801066b4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801066b7:	8b 45 08             	mov    0x8(%ebp),%eax
801066ba:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801066bd:	e8 e7 d4 ff ff       	call   80103ba9 <myproc>
801066c2:	8d 50 6c             	lea    0x6c(%eax),%edx
801066c5:	89 55 cc             	mov    %edx,-0x34(%ebp)
801066c8:	e8 dc d4 ff ff       	call   80103ba9 <myproc>
        cprintf("pid %d %s: trap %d err %d on cpu %d "
801066cd:	8b 40 10             	mov    0x10(%eax),%eax
801066d0:	56                   	push   %esi
801066d1:	ff 75 d4             	pushl  -0x2c(%ebp)
801066d4:	53                   	push   %ebx
801066d5:	ff 75 d0             	pushl  -0x30(%ebp)
801066d8:	57                   	push   %edi
801066d9:	ff 75 cc             	pushl  -0x34(%ebp)
801066dc:	50                   	push   %eax
801066dd:	68 9c ab 10 80       	push   $0x8010ab9c
801066e2:	e8 25 9d ff ff       	call   8010040c <cprintf>
801066e7:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
801066ea:	e8 ba d4 ff ff       	call   80103ba9 <myproc>
801066ef:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801066f6:	eb 04                	jmp    801066fc <trap+0x226>
        break;
801066f8:	90                   	nop
801066f9:	eb 01                	jmp    801066fc <trap+0x226>
        break;
801066fb:	90                   	nop
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
801066fc:	e8 a8 d4 ff ff       	call   80103ba9 <myproc>
80106701:	85 c0                	test   %eax,%eax
80106703:	74 23                	je     80106728 <trap+0x252>
80106705:	e8 9f d4 ff ff       	call   80103ba9 <myproc>
8010670a:	8b 40 24             	mov    0x24(%eax),%eax
8010670d:	85 c0                	test   %eax,%eax
8010670f:	74 17                	je     80106728 <trap+0x252>
80106711:	8b 45 08             	mov    0x8(%ebp),%eax
80106714:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106718:	0f b7 c0             	movzwl %ax,%eax
8010671b:	83 e0 03             	and    $0x3,%eax
8010671e:	83 f8 03             	cmp    $0x3,%eax
80106721:	75 05                	jne    80106728 <trap+0x252>
        exit();
80106723:	e8 21 d9 ff ff       	call   80104049 <exit>

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
80106728:	e8 7c d4 ff ff       	call   80103ba9 <myproc>
8010672d:	85 c0                	test   %eax,%eax
8010672f:	74 1d                	je     8010674e <trap+0x278>
80106731:	e8 73 d4 ff ff       	call   80103ba9 <myproc>
80106736:	8b 40 0c             	mov    0xc(%eax),%eax
80106739:	83 f8 04             	cmp    $0x4,%eax
8010673c:	75 10                	jne    8010674e <trap+0x278>
        tf->trapno == T_IRQ0 + IRQ_TIMER)
8010673e:	8b 45 08             	mov    0x8(%ebp),%eax
80106741:	8b 40 30             	mov    0x30(%eax),%eax
    if (myproc() && myproc()->state == RUNNING &&
80106744:	83 f8 20             	cmp    $0x20,%eax
80106747:	75 05                	jne    8010674e <trap+0x278>
        yield();
80106749:	e8 6a df ff ff       	call   801046b8 <yield>

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
8010674e:	e8 56 d4 ff ff       	call   80103ba9 <myproc>
80106753:	85 c0                	test   %eax,%eax
80106755:	74 26                	je     8010677d <trap+0x2a7>
80106757:	e8 4d d4 ff ff       	call   80103ba9 <myproc>
8010675c:	8b 40 24             	mov    0x24(%eax),%eax
8010675f:	85 c0                	test   %eax,%eax
80106761:	74 1a                	je     8010677d <trap+0x2a7>
80106763:	8b 45 08             	mov    0x8(%ebp),%eax
80106766:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010676a:	0f b7 c0             	movzwl %ax,%eax
8010676d:	83 e0 03             	and    $0x3,%eax
80106770:	83 f8 03             	cmp    $0x3,%eax
80106773:	75 08                	jne    8010677d <trap+0x2a7>
        exit();
80106775:	e8 cf d8 ff ff       	call   80104049 <exit>
8010677a:	eb 01                	jmp    8010677d <trap+0x2a7>
        return;
8010677c:	90                   	nop
}
8010677d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106780:	5b                   	pop    %ebx
80106781:	5e                   	pop    %esi
80106782:	5f                   	pop    %edi
80106783:	5d                   	pop    %ebp
80106784:	c3                   	ret    

80106785 <inb>:
{
80106785:	55                   	push   %ebp
80106786:	89 e5                	mov    %esp,%ebp
80106788:	83 ec 14             	sub    $0x14,%esp
8010678b:	8b 45 08             	mov    0x8(%ebp),%eax
8010678e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106792:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106796:	89 c2                	mov    %eax,%edx
80106798:	ec                   	in     (%dx),%al
80106799:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010679c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801067a0:	c9                   	leave  
801067a1:	c3                   	ret    

801067a2 <outb>:
{
801067a2:	55                   	push   %ebp
801067a3:	89 e5                	mov    %esp,%ebp
801067a5:	83 ec 08             	sub    $0x8,%esp
801067a8:	8b 45 08             	mov    0x8(%ebp),%eax
801067ab:	8b 55 0c             	mov    0xc(%ebp),%edx
801067ae:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801067b2:	89 d0                	mov    %edx,%eax
801067b4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801067b7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801067bb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801067bf:	ee                   	out    %al,(%dx)
}
801067c0:	90                   	nop
801067c1:	c9                   	leave  
801067c2:	c3                   	ret    

801067c3 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801067c3:	f3 0f 1e fb          	endbr32 
801067c7:	55                   	push   %ebp
801067c8:	89 e5                	mov    %esp,%ebp
801067ca:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801067cd:	6a 00                	push   $0x0
801067cf:	68 fa 03 00 00       	push   $0x3fa
801067d4:	e8 c9 ff ff ff       	call   801067a2 <outb>
801067d9:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801067dc:	68 80 00 00 00       	push   $0x80
801067e1:	68 fb 03 00 00       	push   $0x3fb
801067e6:	e8 b7 ff ff ff       	call   801067a2 <outb>
801067eb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801067ee:	6a 0c                	push   $0xc
801067f0:	68 f8 03 00 00       	push   $0x3f8
801067f5:	e8 a8 ff ff ff       	call   801067a2 <outb>
801067fa:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801067fd:	6a 00                	push   $0x0
801067ff:	68 f9 03 00 00       	push   $0x3f9
80106804:	e8 99 ff ff ff       	call   801067a2 <outb>
80106809:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010680c:	6a 03                	push   $0x3
8010680e:	68 fb 03 00 00       	push   $0x3fb
80106813:	e8 8a ff ff ff       	call   801067a2 <outb>
80106818:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010681b:	6a 00                	push   $0x0
8010681d:	68 fc 03 00 00       	push   $0x3fc
80106822:	e8 7b ff ff ff       	call   801067a2 <outb>
80106827:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010682a:	6a 01                	push   $0x1
8010682c:	68 f9 03 00 00       	push   $0x3f9
80106831:	e8 6c ff ff ff       	call   801067a2 <outb>
80106836:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106839:	68 fd 03 00 00       	push   $0x3fd
8010683e:	e8 42 ff ff ff       	call   80106785 <inb>
80106843:	83 c4 04             	add    $0x4,%esp
80106846:	3c ff                	cmp    $0xff,%al
80106848:	74 61                	je     801068ab <uartinit+0xe8>
    return;
  uart = 1;
8010684a:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
80106851:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106854:	68 fa 03 00 00       	push   $0x3fa
80106859:	e8 27 ff ff ff       	call   80106785 <inb>
8010685e:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106861:	68 f8 03 00 00       	push   $0x3f8
80106866:	e8 1a ff ff ff       	call   80106785 <inb>
8010686b:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010686e:	83 ec 08             	sub    $0x8,%esp
80106871:	6a 00                	push   $0x0
80106873:	6a 04                	push   $0x4
80106875:	e8 92 be ff ff       	call   8010270c <ioapicenable>
8010687a:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010687d:	c7 45 f4 60 ac 10 80 	movl   $0x8010ac60,-0xc(%ebp)
80106884:	eb 19                	jmp    8010689f <uartinit+0xdc>
    uartputc(*p);
80106886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106889:	0f b6 00             	movzbl (%eax),%eax
8010688c:	0f be c0             	movsbl %al,%eax
8010688f:	83 ec 0c             	sub    $0xc,%esp
80106892:	50                   	push   %eax
80106893:	e8 16 00 00 00       	call   801068ae <uartputc>
80106898:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010689b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010689f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a2:	0f b6 00             	movzbl (%eax),%eax
801068a5:	84 c0                	test   %al,%al
801068a7:	75 dd                	jne    80106886 <uartinit+0xc3>
801068a9:	eb 01                	jmp    801068ac <uartinit+0xe9>
    return;
801068ab:	90                   	nop
}
801068ac:	c9                   	leave  
801068ad:	c3                   	ret    

801068ae <uartputc>:

void
uartputc(int c)
{
801068ae:	f3 0f 1e fb          	endbr32 
801068b2:	55                   	push   %ebp
801068b3:	89 e5                	mov    %esp,%ebp
801068b5:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801068b8:	a1 60 d0 18 80       	mov    0x8018d060,%eax
801068bd:	85 c0                	test   %eax,%eax
801068bf:	74 53                	je     80106914 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801068c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801068c8:	eb 11                	jmp    801068db <uartputc+0x2d>
    microdelay(10);
801068ca:	83 ec 0c             	sub    $0xc,%esp
801068cd:	6a 0a                	push   $0xa
801068cf:	e8 70 c3 ff ff       	call   80102c44 <microdelay>
801068d4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801068d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801068db:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801068df:	7f 1a                	jg     801068fb <uartputc+0x4d>
801068e1:	83 ec 0c             	sub    $0xc,%esp
801068e4:	68 fd 03 00 00       	push   $0x3fd
801068e9:	e8 97 fe ff ff       	call   80106785 <inb>
801068ee:	83 c4 10             	add    $0x10,%esp
801068f1:	0f b6 c0             	movzbl %al,%eax
801068f4:	83 e0 20             	and    $0x20,%eax
801068f7:	85 c0                	test   %eax,%eax
801068f9:	74 cf                	je     801068ca <uartputc+0x1c>
  outb(COM1+0, c);
801068fb:	8b 45 08             	mov    0x8(%ebp),%eax
801068fe:	0f b6 c0             	movzbl %al,%eax
80106901:	83 ec 08             	sub    $0x8,%esp
80106904:	50                   	push   %eax
80106905:	68 f8 03 00 00       	push   $0x3f8
8010690a:	e8 93 fe ff ff       	call   801067a2 <outb>
8010690f:	83 c4 10             	add    $0x10,%esp
80106912:	eb 01                	jmp    80106915 <uartputc+0x67>
    return;
80106914:	90                   	nop
}
80106915:	c9                   	leave  
80106916:	c3                   	ret    

80106917 <uartgetc>:

static int
uartgetc(void)
{
80106917:	f3 0f 1e fb          	endbr32 
8010691b:	55                   	push   %ebp
8010691c:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010691e:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106923:	85 c0                	test   %eax,%eax
80106925:	75 07                	jne    8010692e <uartgetc+0x17>
    return -1;
80106927:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010692c:	eb 2e                	jmp    8010695c <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
8010692e:	68 fd 03 00 00       	push   $0x3fd
80106933:	e8 4d fe ff ff       	call   80106785 <inb>
80106938:	83 c4 04             	add    $0x4,%esp
8010693b:	0f b6 c0             	movzbl %al,%eax
8010693e:	83 e0 01             	and    $0x1,%eax
80106941:	85 c0                	test   %eax,%eax
80106943:	75 07                	jne    8010694c <uartgetc+0x35>
    return -1;
80106945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010694a:	eb 10                	jmp    8010695c <uartgetc+0x45>
  return inb(COM1+0);
8010694c:	68 f8 03 00 00       	push   $0x3f8
80106951:	e8 2f fe ff ff       	call   80106785 <inb>
80106956:	83 c4 04             	add    $0x4,%esp
80106959:	0f b6 c0             	movzbl %al,%eax
}
8010695c:	c9                   	leave  
8010695d:	c3                   	ret    

8010695e <uartintr>:

void
uartintr(void)
{
8010695e:	f3 0f 1e fb          	endbr32 
80106962:	55                   	push   %ebp
80106963:	89 e5                	mov    %esp,%ebp
80106965:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106968:	83 ec 0c             	sub    $0xc,%esp
8010696b:	68 17 69 10 80       	push   $0x80106917
80106970:	e8 8b 9e ff ff       	call   80100800 <consoleintr>
80106975:	83 c4 10             	add    $0x10,%esp
}
80106978:	90                   	nop
80106979:	c9                   	leave  
8010697a:	c3                   	ret    

8010697b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $0
8010697d:	6a 00                	push   $0x0
  jmp alltraps
8010697f:	e9 5e f9 ff ff       	jmp    801062e2 <alltraps>

80106984 <vector1>:
.globl vector1
vector1:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $1
80106986:	6a 01                	push   $0x1
  jmp alltraps
80106988:	e9 55 f9 ff ff       	jmp    801062e2 <alltraps>

8010698d <vector2>:
.globl vector2
vector2:
  pushl $0
8010698d:	6a 00                	push   $0x0
  pushl $2
8010698f:	6a 02                	push   $0x2
  jmp alltraps
80106991:	e9 4c f9 ff ff       	jmp    801062e2 <alltraps>

80106996 <vector3>:
.globl vector3
vector3:
  pushl $0
80106996:	6a 00                	push   $0x0
  pushl $3
80106998:	6a 03                	push   $0x3
  jmp alltraps
8010699a:	e9 43 f9 ff ff       	jmp    801062e2 <alltraps>

8010699f <vector4>:
.globl vector4
vector4:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $4
801069a1:	6a 04                	push   $0x4
  jmp alltraps
801069a3:	e9 3a f9 ff ff       	jmp    801062e2 <alltraps>

801069a8 <vector5>:
.globl vector5
vector5:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $5
801069aa:	6a 05                	push   $0x5
  jmp alltraps
801069ac:	e9 31 f9 ff ff       	jmp    801062e2 <alltraps>

801069b1 <vector6>:
.globl vector6
vector6:
  pushl $0
801069b1:	6a 00                	push   $0x0
  pushl $6
801069b3:	6a 06                	push   $0x6
  jmp alltraps
801069b5:	e9 28 f9 ff ff       	jmp    801062e2 <alltraps>

801069ba <vector7>:
.globl vector7
vector7:
  pushl $0
801069ba:	6a 00                	push   $0x0
  pushl $7
801069bc:	6a 07                	push   $0x7
  jmp alltraps
801069be:	e9 1f f9 ff ff       	jmp    801062e2 <alltraps>

801069c3 <vector8>:
.globl vector8
vector8:
  pushl $8
801069c3:	6a 08                	push   $0x8
  jmp alltraps
801069c5:	e9 18 f9 ff ff       	jmp    801062e2 <alltraps>

801069ca <vector9>:
.globl vector9
vector9:
  pushl $0
801069ca:	6a 00                	push   $0x0
  pushl $9
801069cc:	6a 09                	push   $0x9
  jmp alltraps
801069ce:	e9 0f f9 ff ff       	jmp    801062e2 <alltraps>

801069d3 <vector10>:
.globl vector10
vector10:
  pushl $10
801069d3:	6a 0a                	push   $0xa
  jmp alltraps
801069d5:	e9 08 f9 ff ff       	jmp    801062e2 <alltraps>

801069da <vector11>:
.globl vector11
vector11:
  pushl $11
801069da:	6a 0b                	push   $0xb
  jmp alltraps
801069dc:	e9 01 f9 ff ff       	jmp    801062e2 <alltraps>

801069e1 <vector12>:
.globl vector12
vector12:
  pushl $12
801069e1:	6a 0c                	push   $0xc
  jmp alltraps
801069e3:	e9 fa f8 ff ff       	jmp    801062e2 <alltraps>

801069e8 <vector13>:
.globl vector13
vector13:
  pushl $13
801069e8:	6a 0d                	push   $0xd
  jmp alltraps
801069ea:	e9 f3 f8 ff ff       	jmp    801062e2 <alltraps>

801069ef <vector14>:
.globl vector14
vector14:
  pushl $14
801069ef:	6a 0e                	push   $0xe
  jmp alltraps
801069f1:	e9 ec f8 ff ff       	jmp    801062e2 <alltraps>

801069f6 <vector15>:
.globl vector15
vector15:
  pushl $0
801069f6:	6a 00                	push   $0x0
  pushl $15
801069f8:	6a 0f                	push   $0xf
  jmp alltraps
801069fa:	e9 e3 f8 ff ff       	jmp    801062e2 <alltraps>

801069ff <vector16>:
.globl vector16
vector16:
  pushl $0
801069ff:	6a 00                	push   $0x0
  pushl $16
80106a01:	6a 10                	push   $0x10
  jmp alltraps
80106a03:	e9 da f8 ff ff       	jmp    801062e2 <alltraps>

80106a08 <vector17>:
.globl vector17
vector17:
  pushl $17
80106a08:	6a 11                	push   $0x11
  jmp alltraps
80106a0a:	e9 d3 f8 ff ff       	jmp    801062e2 <alltraps>

80106a0f <vector18>:
.globl vector18
vector18:
  pushl $0
80106a0f:	6a 00                	push   $0x0
  pushl $18
80106a11:	6a 12                	push   $0x12
  jmp alltraps
80106a13:	e9 ca f8 ff ff       	jmp    801062e2 <alltraps>

80106a18 <vector19>:
.globl vector19
vector19:
  pushl $0
80106a18:	6a 00                	push   $0x0
  pushl $19
80106a1a:	6a 13                	push   $0x13
  jmp alltraps
80106a1c:	e9 c1 f8 ff ff       	jmp    801062e2 <alltraps>

80106a21 <vector20>:
.globl vector20
vector20:
  pushl $0
80106a21:	6a 00                	push   $0x0
  pushl $20
80106a23:	6a 14                	push   $0x14
  jmp alltraps
80106a25:	e9 b8 f8 ff ff       	jmp    801062e2 <alltraps>

80106a2a <vector21>:
.globl vector21
vector21:
  pushl $0
80106a2a:	6a 00                	push   $0x0
  pushl $21
80106a2c:	6a 15                	push   $0x15
  jmp alltraps
80106a2e:	e9 af f8 ff ff       	jmp    801062e2 <alltraps>

80106a33 <vector22>:
.globl vector22
vector22:
  pushl $0
80106a33:	6a 00                	push   $0x0
  pushl $22
80106a35:	6a 16                	push   $0x16
  jmp alltraps
80106a37:	e9 a6 f8 ff ff       	jmp    801062e2 <alltraps>

80106a3c <vector23>:
.globl vector23
vector23:
  pushl $0
80106a3c:	6a 00                	push   $0x0
  pushl $23
80106a3e:	6a 17                	push   $0x17
  jmp alltraps
80106a40:	e9 9d f8 ff ff       	jmp    801062e2 <alltraps>

80106a45 <vector24>:
.globl vector24
vector24:
  pushl $0
80106a45:	6a 00                	push   $0x0
  pushl $24
80106a47:	6a 18                	push   $0x18
  jmp alltraps
80106a49:	e9 94 f8 ff ff       	jmp    801062e2 <alltraps>

80106a4e <vector25>:
.globl vector25
vector25:
  pushl $0
80106a4e:	6a 00                	push   $0x0
  pushl $25
80106a50:	6a 19                	push   $0x19
  jmp alltraps
80106a52:	e9 8b f8 ff ff       	jmp    801062e2 <alltraps>

80106a57 <vector26>:
.globl vector26
vector26:
  pushl $0
80106a57:	6a 00                	push   $0x0
  pushl $26
80106a59:	6a 1a                	push   $0x1a
  jmp alltraps
80106a5b:	e9 82 f8 ff ff       	jmp    801062e2 <alltraps>

80106a60 <vector27>:
.globl vector27
vector27:
  pushl $0
80106a60:	6a 00                	push   $0x0
  pushl $27
80106a62:	6a 1b                	push   $0x1b
  jmp alltraps
80106a64:	e9 79 f8 ff ff       	jmp    801062e2 <alltraps>

80106a69 <vector28>:
.globl vector28
vector28:
  pushl $0
80106a69:	6a 00                	push   $0x0
  pushl $28
80106a6b:	6a 1c                	push   $0x1c
  jmp alltraps
80106a6d:	e9 70 f8 ff ff       	jmp    801062e2 <alltraps>

80106a72 <vector29>:
.globl vector29
vector29:
  pushl $0
80106a72:	6a 00                	push   $0x0
  pushl $29
80106a74:	6a 1d                	push   $0x1d
  jmp alltraps
80106a76:	e9 67 f8 ff ff       	jmp    801062e2 <alltraps>

80106a7b <vector30>:
.globl vector30
vector30:
  pushl $0
80106a7b:	6a 00                	push   $0x0
  pushl $30
80106a7d:	6a 1e                	push   $0x1e
  jmp alltraps
80106a7f:	e9 5e f8 ff ff       	jmp    801062e2 <alltraps>

80106a84 <vector31>:
.globl vector31
vector31:
  pushl $0
80106a84:	6a 00                	push   $0x0
  pushl $31
80106a86:	6a 1f                	push   $0x1f
  jmp alltraps
80106a88:	e9 55 f8 ff ff       	jmp    801062e2 <alltraps>

80106a8d <vector32>:
.globl vector32
vector32:
  pushl $0
80106a8d:	6a 00                	push   $0x0
  pushl $32
80106a8f:	6a 20                	push   $0x20
  jmp alltraps
80106a91:	e9 4c f8 ff ff       	jmp    801062e2 <alltraps>

80106a96 <vector33>:
.globl vector33
vector33:
  pushl $0
80106a96:	6a 00                	push   $0x0
  pushl $33
80106a98:	6a 21                	push   $0x21
  jmp alltraps
80106a9a:	e9 43 f8 ff ff       	jmp    801062e2 <alltraps>

80106a9f <vector34>:
.globl vector34
vector34:
  pushl $0
80106a9f:	6a 00                	push   $0x0
  pushl $34
80106aa1:	6a 22                	push   $0x22
  jmp alltraps
80106aa3:	e9 3a f8 ff ff       	jmp    801062e2 <alltraps>

80106aa8 <vector35>:
.globl vector35
vector35:
  pushl $0
80106aa8:	6a 00                	push   $0x0
  pushl $35
80106aaa:	6a 23                	push   $0x23
  jmp alltraps
80106aac:	e9 31 f8 ff ff       	jmp    801062e2 <alltraps>

80106ab1 <vector36>:
.globl vector36
vector36:
  pushl $0
80106ab1:	6a 00                	push   $0x0
  pushl $36
80106ab3:	6a 24                	push   $0x24
  jmp alltraps
80106ab5:	e9 28 f8 ff ff       	jmp    801062e2 <alltraps>

80106aba <vector37>:
.globl vector37
vector37:
  pushl $0
80106aba:	6a 00                	push   $0x0
  pushl $37
80106abc:	6a 25                	push   $0x25
  jmp alltraps
80106abe:	e9 1f f8 ff ff       	jmp    801062e2 <alltraps>

80106ac3 <vector38>:
.globl vector38
vector38:
  pushl $0
80106ac3:	6a 00                	push   $0x0
  pushl $38
80106ac5:	6a 26                	push   $0x26
  jmp alltraps
80106ac7:	e9 16 f8 ff ff       	jmp    801062e2 <alltraps>

80106acc <vector39>:
.globl vector39
vector39:
  pushl $0
80106acc:	6a 00                	push   $0x0
  pushl $39
80106ace:	6a 27                	push   $0x27
  jmp alltraps
80106ad0:	e9 0d f8 ff ff       	jmp    801062e2 <alltraps>

80106ad5 <vector40>:
.globl vector40
vector40:
  pushl $0
80106ad5:	6a 00                	push   $0x0
  pushl $40
80106ad7:	6a 28                	push   $0x28
  jmp alltraps
80106ad9:	e9 04 f8 ff ff       	jmp    801062e2 <alltraps>

80106ade <vector41>:
.globl vector41
vector41:
  pushl $0
80106ade:	6a 00                	push   $0x0
  pushl $41
80106ae0:	6a 29                	push   $0x29
  jmp alltraps
80106ae2:	e9 fb f7 ff ff       	jmp    801062e2 <alltraps>

80106ae7 <vector42>:
.globl vector42
vector42:
  pushl $0
80106ae7:	6a 00                	push   $0x0
  pushl $42
80106ae9:	6a 2a                	push   $0x2a
  jmp alltraps
80106aeb:	e9 f2 f7 ff ff       	jmp    801062e2 <alltraps>

80106af0 <vector43>:
.globl vector43
vector43:
  pushl $0
80106af0:	6a 00                	push   $0x0
  pushl $43
80106af2:	6a 2b                	push   $0x2b
  jmp alltraps
80106af4:	e9 e9 f7 ff ff       	jmp    801062e2 <alltraps>

80106af9 <vector44>:
.globl vector44
vector44:
  pushl $0
80106af9:	6a 00                	push   $0x0
  pushl $44
80106afb:	6a 2c                	push   $0x2c
  jmp alltraps
80106afd:	e9 e0 f7 ff ff       	jmp    801062e2 <alltraps>

80106b02 <vector45>:
.globl vector45
vector45:
  pushl $0
80106b02:	6a 00                	push   $0x0
  pushl $45
80106b04:	6a 2d                	push   $0x2d
  jmp alltraps
80106b06:	e9 d7 f7 ff ff       	jmp    801062e2 <alltraps>

80106b0b <vector46>:
.globl vector46
vector46:
  pushl $0
80106b0b:	6a 00                	push   $0x0
  pushl $46
80106b0d:	6a 2e                	push   $0x2e
  jmp alltraps
80106b0f:	e9 ce f7 ff ff       	jmp    801062e2 <alltraps>

80106b14 <vector47>:
.globl vector47
vector47:
  pushl $0
80106b14:	6a 00                	push   $0x0
  pushl $47
80106b16:	6a 2f                	push   $0x2f
  jmp alltraps
80106b18:	e9 c5 f7 ff ff       	jmp    801062e2 <alltraps>

80106b1d <vector48>:
.globl vector48
vector48:
  pushl $0
80106b1d:	6a 00                	push   $0x0
  pushl $48
80106b1f:	6a 30                	push   $0x30
  jmp alltraps
80106b21:	e9 bc f7 ff ff       	jmp    801062e2 <alltraps>

80106b26 <vector49>:
.globl vector49
vector49:
  pushl $0
80106b26:	6a 00                	push   $0x0
  pushl $49
80106b28:	6a 31                	push   $0x31
  jmp alltraps
80106b2a:	e9 b3 f7 ff ff       	jmp    801062e2 <alltraps>

80106b2f <vector50>:
.globl vector50
vector50:
  pushl $0
80106b2f:	6a 00                	push   $0x0
  pushl $50
80106b31:	6a 32                	push   $0x32
  jmp alltraps
80106b33:	e9 aa f7 ff ff       	jmp    801062e2 <alltraps>

80106b38 <vector51>:
.globl vector51
vector51:
  pushl $0
80106b38:	6a 00                	push   $0x0
  pushl $51
80106b3a:	6a 33                	push   $0x33
  jmp alltraps
80106b3c:	e9 a1 f7 ff ff       	jmp    801062e2 <alltraps>

80106b41 <vector52>:
.globl vector52
vector52:
  pushl $0
80106b41:	6a 00                	push   $0x0
  pushl $52
80106b43:	6a 34                	push   $0x34
  jmp alltraps
80106b45:	e9 98 f7 ff ff       	jmp    801062e2 <alltraps>

80106b4a <vector53>:
.globl vector53
vector53:
  pushl $0
80106b4a:	6a 00                	push   $0x0
  pushl $53
80106b4c:	6a 35                	push   $0x35
  jmp alltraps
80106b4e:	e9 8f f7 ff ff       	jmp    801062e2 <alltraps>

80106b53 <vector54>:
.globl vector54
vector54:
  pushl $0
80106b53:	6a 00                	push   $0x0
  pushl $54
80106b55:	6a 36                	push   $0x36
  jmp alltraps
80106b57:	e9 86 f7 ff ff       	jmp    801062e2 <alltraps>

80106b5c <vector55>:
.globl vector55
vector55:
  pushl $0
80106b5c:	6a 00                	push   $0x0
  pushl $55
80106b5e:	6a 37                	push   $0x37
  jmp alltraps
80106b60:	e9 7d f7 ff ff       	jmp    801062e2 <alltraps>

80106b65 <vector56>:
.globl vector56
vector56:
  pushl $0
80106b65:	6a 00                	push   $0x0
  pushl $56
80106b67:	6a 38                	push   $0x38
  jmp alltraps
80106b69:	e9 74 f7 ff ff       	jmp    801062e2 <alltraps>

80106b6e <vector57>:
.globl vector57
vector57:
  pushl $0
80106b6e:	6a 00                	push   $0x0
  pushl $57
80106b70:	6a 39                	push   $0x39
  jmp alltraps
80106b72:	e9 6b f7 ff ff       	jmp    801062e2 <alltraps>

80106b77 <vector58>:
.globl vector58
vector58:
  pushl $0
80106b77:	6a 00                	push   $0x0
  pushl $58
80106b79:	6a 3a                	push   $0x3a
  jmp alltraps
80106b7b:	e9 62 f7 ff ff       	jmp    801062e2 <alltraps>

80106b80 <vector59>:
.globl vector59
vector59:
  pushl $0
80106b80:	6a 00                	push   $0x0
  pushl $59
80106b82:	6a 3b                	push   $0x3b
  jmp alltraps
80106b84:	e9 59 f7 ff ff       	jmp    801062e2 <alltraps>

80106b89 <vector60>:
.globl vector60
vector60:
  pushl $0
80106b89:	6a 00                	push   $0x0
  pushl $60
80106b8b:	6a 3c                	push   $0x3c
  jmp alltraps
80106b8d:	e9 50 f7 ff ff       	jmp    801062e2 <alltraps>

80106b92 <vector61>:
.globl vector61
vector61:
  pushl $0
80106b92:	6a 00                	push   $0x0
  pushl $61
80106b94:	6a 3d                	push   $0x3d
  jmp alltraps
80106b96:	e9 47 f7 ff ff       	jmp    801062e2 <alltraps>

80106b9b <vector62>:
.globl vector62
vector62:
  pushl $0
80106b9b:	6a 00                	push   $0x0
  pushl $62
80106b9d:	6a 3e                	push   $0x3e
  jmp alltraps
80106b9f:	e9 3e f7 ff ff       	jmp    801062e2 <alltraps>

80106ba4 <vector63>:
.globl vector63
vector63:
  pushl $0
80106ba4:	6a 00                	push   $0x0
  pushl $63
80106ba6:	6a 3f                	push   $0x3f
  jmp alltraps
80106ba8:	e9 35 f7 ff ff       	jmp    801062e2 <alltraps>

80106bad <vector64>:
.globl vector64
vector64:
  pushl $0
80106bad:	6a 00                	push   $0x0
  pushl $64
80106baf:	6a 40                	push   $0x40
  jmp alltraps
80106bb1:	e9 2c f7 ff ff       	jmp    801062e2 <alltraps>

80106bb6 <vector65>:
.globl vector65
vector65:
  pushl $0
80106bb6:	6a 00                	push   $0x0
  pushl $65
80106bb8:	6a 41                	push   $0x41
  jmp alltraps
80106bba:	e9 23 f7 ff ff       	jmp    801062e2 <alltraps>

80106bbf <vector66>:
.globl vector66
vector66:
  pushl $0
80106bbf:	6a 00                	push   $0x0
  pushl $66
80106bc1:	6a 42                	push   $0x42
  jmp alltraps
80106bc3:	e9 1a f7 ff ff       	jmp    801062e2 <alltraps>

80106bc8 <vector67>:
.globl vector67
vector67:
  pushl $0
80106bc8:	6a 00                	push   $0x0
  pushl $67
80106bca:	6a 43                	push   $0x43
  jmp alltraps
80106bcc:	e9 11 f7 ff ff       	jmp    801062e2 <alltraps>

80106bd1 <vector68>:
.globl vector68
vector68:
  pushl $0
80106bd1:	6a 00                	push   $0x0
  pushl $68
80106bd3:	6a 44                	push   $0x44
  jmp alltraps
80106bd5:	e9 08 f7 ff ff       	jmp    801062e2 <alltraps>

80106bda <vector69>:
.globl vector69
vector69:
  pushl $0
80106bda:	6a 00                	push   $0x0
  pushl $69
80106bdc:	6a 45                	push   $0x45
  jmp alltraps
80106bde:	e9 ff f6 ff ff       	jmp    801062e2 <alltraps>

80106be3 <vector70>:
.globl vector70
vector70:
  pushl $0
80106be3:	6a 00                	push   $0x0
  pushl $70
80106be5:	6a 46                	push   $0x46
  jmp alltraps
80106be7:	e9 f6 f6 ff ff       	jmp    801062e2 <alltraps>

80106bec <vector71>:
.globl vector71
vector71:
  pushl $0
80106bec:	6a 00                	push   $0x0
  pushl $71
80106bee:	6a 47                	push   $0x47
  jmp alltraps
80106bf0:	e9 ed f6 ff ff       	jmp    801062e2 <alltraps>

80106bf5 <vector72>:
.globl vector72
vector72:
  pushl $0
80106bf5:	6a 00                	push   $0x0
  pushl $72
80106bf7:	6a 48                	push   $0x48
  jmp alltraps
80106bf9:	e9 e4 f6 ff ff       	jmp    801062e2 <alltraps>

80106bfe <vector73>:
.globl vector73
vector73:
  pushl $0
80106bfe:	6a 00                	push   $0x0
  pushl $73
80106c00:	6a 49                	push   $0x49
  jmp alltraps
80106c02:	e9 db f6 ff ff       	jmp    801062e2 <alltraps>

80106c07 <vector74>:
.globl vector74
vector74:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $74
80106c09:	6a 4a                	push   $0x4a
  jmp alltraps
80106c0b:	e9 d2 f6 ff ff       	jmp    801062e2 <alltraps>

80106c10 <vector75>:
.globl vector75
vector75:
  pushl $0
80106c10:	6a 00                	push   $0x0
  pushl $75
80106c12:	6a 4b                	push   $0x4b
  jmp alltraps
80106c14:	e9 c9 f6 ff ff       	jmp    801062e2 <alltraps>

80106c19 <vector76>:
.globl vector76
vector76:
  pushl $0
80106c19:	6a 00                	push   $0x0
  pushl $76
80106c1b:	6a 4c                	push   $0x4c
  jmp alltraps
80106c1d:	e9 c0 f6 ff ff       	jmp    801062e2 <alltraps>

80106c22 <vector77>:
.globl vector77
vector77:
  pushl $0
80106c22:	6a 00                	push   $0x0
  pushl $77
80106c24:	6a 4d                	push   $0x4d
  jmp alltraps
80106c26:	e9 b7 f6 ff ff       	jmp    801062e2 <alltraps>

80106c2b <vector78>:
.globl vector78
vector78:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $78
80106c2d:	6a 4e                	push   $0x4e
  jmp alltraps
80106c2f:	e9 ae f6 ff ff       	jmp    801062e2 <alltraps>

80106c34 <vector79>:
.globl vector79
vector79:
  pushl $0
80106c34:	6a 00                	push   $0x0
  pushl $79
80106c36:	6a 4f                	push   $0x4f
  jmp alltraps
80106c38:	e9 a5 f6 ff ff       	jmp    801062e2 <alltraps>

80106c3d <vector80>:
.globl vector80
vector80:
  pushl $0
80106c3d:	6a 00                	push   $0x0
  pushl $80
80106c3f:	6a 50                	push   $0x50
  jmp alltraps
80106c41:	e9 9c f6 ff ff       	jmp    801062e2 <alltraps>

80106c46 <vector81>:
.globl vector81
vector81:
  pushl $0
80106c46:	6a 00                	push   $0x0
  pushl $81
80106c48:	6a 51                	push   $0x51
  jmp alltraps
80106c4a:	e9 93 f6 ff ff       	jmp    801062e2 <alltraps>

80106c4f <vector82>:
.globl vector82
vector82:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $82
80106c51:	6a 52                	push   $0x52
  jmp alltraps
80106c53:	e9 8a f6 ff ff       	jmp    801062e2 <alltraps>

80106c58 <vector83>:
.globl vector83
vector83:
  pushl $0
80106c58:	6a 00                	push   $0x0
  pushl $83
80106c5a:	6a 53                	push   $0x53
  jmp alltraps
80106c5c:	e9 81 f6 ff ff       	jmp    801062e2 <alltraps>

80106c61 <vector84>:
.globl vector84
vector84:
  pushl $0
80106c61:	6a 00                	push   $0x0
  pushl $84
80106c63:	6a 54                	push   $0x54
  jmp alltraps
80106c65:	e9 78 f6 ff ff       	jmp    801062e2 <alltraps>

80106c6a <vector85>:
.globl vector85
vector85:
  pushl $0
80106c6a:	6a 00                	push   $0x0
  pushl $85
80106c6c:	6a 55                	push   $0x55
  jmp alltraps
80106c6e:	e9 6f f6 ff ff       	jmp    801062e2 <alltraps>

80106c73 <vector86>:
.globl vector86
vector86:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $86
80106c75:	6a 56                	push   $0x56
  jmp alltraps
80106c77:	e9 66 f6 ff ff       	jmp    801062e2 <alltraps>

80106c7c <vector87>:
.globl vector87
vector87:
  pushl $0
80106c7c:	6a 00                	push   $0x0
  pushl $87
80106c7e:	6a 57                	push   $0x57
  jmp alltraps
80106c80:	e9 5d f6 ff ff       	jmp    801062e2 <alltraps>

80106c85 <vector88>:
.globl vector88
vector88:
  pushl $0
80106c85:	6a 00                	push   $0x0
  pushl $88
80106c87:	6a 58                	push   $0x58
  jmp alltraps
80106c89:	e9 54 f6 ff ff       	jmp    801062e2 <alltraps>

80106c8e <vector89>:
.globl vector89
vector89:
  pushl $0
80106c8e:	6a 00                	push   $0x0
  pushl $89
80106c90:	6a 59                	push   $0x59
  jmp alltraps
80106c92:	e9 4b f6 ff ff       	jmp    801062e2 <alltraps>

80106c97 <vector90>:
.globl vector90
vector90:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $90
80106c99:	6a 5a                	push   $0x5a
  jmp alltraps
80106c9b:	e9 42 f6 ff ff       	jmp    801062e2 <alltraps>

80106ca0 <vector91>:
.globl vector91
vector91:
  pushl $0
80106ca0:	6a 00                	push   $0x0
  pushl $91
80106ca2:	6a 5b                	push   $0x5b
  jmp alltraps
80106ca4:	e9 39 f6 ff ff       	jmp    801062e2 <alltraps>

80106ca9 <vector92>:
.globl vector92
vector92:
  pushl $0
80106ca9:	6a 00                	push   $0x0
  pushl $92
80106cab:	6a 5c                	push   $0x5c
  jmp alltraps
80106cad:	e9 30 f6 ff ff       	jmp    801062e2 <alltraps>

80106cb2 <vector93>:
.globl vector93
vector93:
  pushl $0
80106cb2:	6a 00                	push   $0x0
  pushl $93
80106cb4:	6a 5d                	push   $0x5d
  jmp alltraps
80106cb6:	e9 27 f6 ff ff       	jmp    801062e2 <alltraps>

80106cbb <vector94>:
.globl vector94
vector94:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $94
80106cbd:	6a 5e                	push   $0x5e
  jmp alltraps
80106cbf:	e9 1e f6 ff ff       	jmp    801062e2 <alltraps>

80106cc4 <vector95>:
.globl vector95
vector95:
  pushl $0
80106cc4:	6a 00                	push   $0x0
  pushl $95
80106cc6:	6a 5f                	push   $0x5f
  jmp alltraps
80106cc8:	e9 15 f6 ff ff       	jmp    801062e2 <alltraps>

80106ccd <vector96>:
.globl vector96
vector96:
  pushl $0
80106ccd:	6a 00                	push   $0x0
  pushl $96
80106ccf:	6a 60                	push   $0x60
  jmp alltraps
80106cd1:	e9 0c f6 ff ff       	jmp    801062e2 <alltraps>

80106cd6 <vector97>:
.globl vector97
vector97:
  pushl $0
80106cd6:	6a 00                	push   $0x0
  pushl $97
80106cd8:	6a 61                	push   $0x61
  jmp alltraps
80106cda:	e9 03 f6 ff ff       	jmp    801062e2 <alltraps>

80106cdf <vector98>:
.globl vector98
vector98:
  pushl $0
80106cdf:	6a 00                	push   $0x0
  pushl $98
80106ce1:	6a 62                	push   $0x62
  jmp alltraps
80106ce3:	e9 fa f5 ff ff       	jmp    801062e2 <alltraps>

80106ce8 <vector99>:
.globl vector99
vector99:
  pushl $0
80106ce8:	6a 00                	push   $0x0
  pushl $99
80106cea:	6a 63                	push   $0x63
  jmp alltraps
80106cec:	e9 f1 f5 ff ff       	jmp    801062e2 <alltraps>

80106cf1 <vector100>:
.globl vector100
vector100:
  pushl $0
80106cf1:	6a 00                	push   $0x0
  pushl $100
80106cf3:	6a 64                	push   $0x64
  jmp alltraps
80106cf5:	e9 e8 f5 ff ff       	jmp    801062e2 <alltraps>

80106cfa <vector101>:
.globl vector101
vector101:
  pushl $0
80106cfa:	6a 00                	push   $0x0
  pushl $101
80106cfc:	6a 65                	push   $0x65
  jmp alltraps
80106cfe:	e9 df f5 ff ff       	jmp    801062e2 <alltraps>

80106d03 <vector102>:
.globl vector102
vector102:
  pushl $0
80106d03:	6a 00                	push   $0x0
  pushl $102
80106d05:	6a 66                	push   $0x66
  jmp alltraps
80106d07:	e9 d6 f5 ff ff       	jmp    801062e2 <alltraps>

80106d0c <vector103>:
.globl vector103
vector103:
  pushl $0
80106d0c:	6a 00                	push   $0x0
  pushl $103
80106d0e:	6a 67                	push   $0x67
  jmp alltraps
80106d10:	e9 cd f5 ff ff       	jmp    801062e2 <alltraps>

80106d15 <vector104>:
.globl vector104
vector104:
  pushl $0
80106d15:	6a 00                	push   $0x0
  pushl $104
80106d17:	6a 68                	push   $0x68
  jmp alltraps
80106d19:	e9 c4 f5 ff ff       	jmp    801062e2 <alltraps>

80106d1e <vector105>:
.globl vector105
vector105:
  pushl $0
80106d1e:	6a 00                	push   $0x0
  pushl $105
80106d20:	6a 69                	push   $0x69
  jmp alltraps
80106d22:	e9 bb f5 ff ff       	jmp    801062e2 <alltraps>

80106d27 <vector106>:
.globl vector106
vector106:
  pushl $0
80106d27:	6a 00                	push   $0x0
  pushl $106
80106d29:	6a 6a                	push   $0x6a
  jmp alltraps
80106d2b:	e9 b2 f5 ff ff       	jmp    801062e2 <alltraps>

80106d30 <vector107>:
.globl vector107
vector107:
  pushl $0
80106d30:	6a 00                	push   $0x0
  pushl $107
80106d32:	6a 6b                	push   $0x6b
  jmp alltraps
80106d34:	e9 a9 f5 ff ff       	jmp    801062e2 <alltraps>

80106d39 <vector108>:
.globl vector108
vector108:
  pushl $0
80106d39:	6a 00                	push   $0x0
  pushl $108
80106d3b:	6a 6c                	push   $0x6c
  jmp alltraps
80106d3d:	e9 a0 f5 ff ff       	jmp    801062e2 <alltraps>

80106d42 <vector109>:
.globl vector109
vector109:
  pushl $0
80106d42:	6a 00                	push   $0x0
  pushl $109
80106d44:	6a 6d                	push   $0x6d
  jmp alltraps
80106d46:	e9 97 f5 ff ff       	jmp    801062e2 <alltraps>

80106d4b <vector110>:
.globl vector110
vector110:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $110
80106d4d:	6a 6e                	push   $0x6e
  jmp alltraps
80106d4f:	e9 8e f5 ff ff       	jmp    801062e2 <alltraps>

80106d54 <vector111>:
.globl vector111
vector111:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $111
80106d56:	6a 6f                	push   $0x6f
  jmp alltraps
80106d58:	e9 85 f5 ff ff       	jmp    801062e2 <alltraps>

80106d5d <vector112>:
.globl vector112
vector112:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $112
80106d5f:	6a 70                	push   $0x70
  jmp alltraps
80106d61:	e9 7c f5 ff ff       	jmp    801062e2 <alltraps>

80106d66 <vector113>:
.globl vector113
vector113:
  pushl $0
80106d66:	6a 00                	push   $0x0
  pushl $113
80106d68:	6a 71                	push   $0x71
  jmp alltraps
80106d6a:	e9 73 f5 ff ff       	jmp    801062e2 <alltraps>

80106d6f <vector114>:
.globl vector114
vector114:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $114
80106d71:	6a 72                	push   $0x72
  jmp alltraps
80106d73:	e9 6a f5 ff ff       	jmp    801062e2 <alltraps>

80106d78 <vector115>:
.globl vector115
vector115:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $115
80106d7a:	6a 73                	push   $0x73
  jmp alltraps
80106d7c:	e9 61 f5 ff ff       	jmp    801062e2 <alltraps>

80106d81 <vector116>:
.globl vector116
vector116:
  pushl $0
80106d81:	6a 00                	push   $0x0
  pushl $116
80106d83:	6a 74                	push   $0x74
  jmp alltraps
80106d85:	e9 58 f5 ff ff       	jmp    801062e2 <alltraps>

80106d8a <vector117>:
.globl vector117
vector117:
  pushl $0
80106d8a:	6a 00                	push   $0x0
  pushl $117
80106d8c:	6a 75                	push   $0x75
  jmp alltraps
80106d8e:	e9 4f f5 ff ff       	jmp    801062e2 <alltraps>

80106d93 <vector118>:
.globl vector118
vector118:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $118
80106d95:	6a 76                	push   $0x76
  jmp alltraps
80106d97:	e9 46 f5 ff ff       	jmp    801062e2 <alltraps>

80106d9c <vector119>:
.globl vector119
vector119:
  pushl $0
80106d9c:	6a 00                	push   $0x0
  pushl $119
80106d9e:	6a 77                	push   $0x77
  jmp alltraps
80106da0:	e9 3d f5 ff ff       	jmp    801062e2 <alltraps>

80106da5 <vector120>:
.globl vector120
vector120:
  pushl $0
80106da5:	6a 00                	push   $0x0
  pushl $120
80106da7:	6a 78                	push   $0x78
  jmp alltraps
80106da9:	e9 34 f5 ff ff       	jmp    801062e2 <alltraps>

80106dae <vector121>:
.globl vector121
vector121:
  pushl $0
80106dae:	6a 00                	push   $0x0
  pushl $121
80106db0:	6a 79                	push   $0x79
  jmp alltraps
80106db2:	e9 2b f5 ff ff       	jmp    801062e2 <alltraps>

80106db7 <vector122>:
.globl vector122
vector122:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $122
80106db9:	6a 7a                	push   $0x7a
  jmp alltraps
80106dbb:	e9 22 f5 ff ff       	jmp    801062e2 <alltraps>

80106dc0 <vector123>:
.globl vector123
vector123:
  pushl $0
80106dc0:	6a 00                	push   $0x0
  pushl $123
80106dc2:	6a 7b                	push   $0x7b
  jmp alltraps
80106dc4:	e9 19 f5 ff ff       	jmp    801062e2 <alltraps>

80106dc9 <vector124>:
.globl vector124
vector124:
  pushl $0
80106dc9:	6a 00                	push   $0x0
  pushl $124
80106dcb:	6a 7c                	push   $0x7c
  jmp alltraps
80106dcd:	e9 10 f5 ff ff       	jmp    801062e2 <alltraps>

80106dd2 <vector125>:
.globl vector125
vector125:
  pushl $0
80106dd2:	6a 00                	push   $0x0
  pushl $125
80106dd4:	6a 7d                	push   $0x7d
  jmp alltraps
80106dd6:	e9 07 f5 ff ff       	jmp    801062e2 <alltraps>

80106ddb <vector126>:
.globl vector126
vector126:
  pushl $0
80106ddb:	6a 00                	push   $0x0
  pushl $126
80106ddd:	6a 7e                	push   $0x7e
  jmp alltraps
80106ddf:	e9 fe f4 ff ff       	jmp    801062e2 <alltraps>

80106de4 <vector127>:
.globl vector127
vector127:
  pushl $0
80106de4:	6a 00                	push   $0x0
  pushl $127
80106de6:	6a 7f                	push   $0x7f
  jmp alltraps
80106de8:	e9 f5 f4 ff ff       	jmp    801062e2 <alltraps>

80106ded <vector128>:
.globl vector128
vector128:
  pushl $0
80106ded:	6a 00                	push   $0x0
  pushl $128
80106def:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106df4:	e9 e9 f4 ff ff       	jmp    801062e2 <alltraps>

80106df9 <vector129>:
.globl vector129
vector129:
  pushl $0
80106df9:	6a 00                	push   $0x0
  pushl $129
80106dfb:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106e00:	e9 dd f4 ff ff       	jmp    801062e2 <alltraps>

80106e05 <vector130>:
.globl vector130
vector130:
  pushl $0
80106e05:	6a 00                	push   $0x0
  pushl $130
80106e07:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106e0c:	e9 d1 f4 ff ff       	jmp    801062e2 <alltraps>

80106e11 <vector131>:
.globl vector131
vector131:
  pushl $0
80106e11:	6a 00                	push   $0x0
  pushl $131
80106e13:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106e18:	e9 c5 f4 ff ff       	jmp    801062e2 <alltraps>

80106e1d <vector132>:
.globl vector132
vector132:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $132
80106e1f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106e24:	e9 b9 f4 ff ff       	jmp    801062e2 <alltraps>

80106e29 <vector133>:
.globl vector133
vector133:
  pushl $0
80106e29:	6a 00                	push   $0x0
  pushl $133
80106e2b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106e30:	e9 ad f4 ff ff       	jmp    801062e2 <alltraps>

80106e35 <vector134>:
.globl vector134
vector134:
  pushl $0
80106e35:	6a 00                	push   $0x0
  pushl $134
80106e37:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106e3c:	e9 a1 f4 ff ff       	jmp    801062e2 <alltraps>

80106e41 <vector135>:
.globl vector135
vector135:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $135
80106e43:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106e48:	e9 95 f4 ff ff       	jmp    801062e2 <alltraps>

80106e4d <vector136>:
.globl vector136
vector136:
  pushl $0
80106e4d:	6a 00                	push   $0x0
  pushl $136
80106e4f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106e54:	e9 89 f4 ff ff       	jmp    801062e2 <alltraps>

80106e59 <vector137>:
.globl vector137
vector137:
  pushl $0
80106e59:	6a 00                	push   $0x0
  pushl $137
80106e5b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106e60:	e9 7d f4 ff ff       	jmp    801062e2 <alltraps>

80106e65 <vector138>:
.globl vector138
vector138:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $138
80106e67:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106e6c:	e9 71 f4 ff ff       	jmp    801062e2 <alltraps>

80106e71 <vector139>:
.globl vector139
vector139:
  pushl $0
80106e71:	6a 00                	push   $0x0
  pushl $139
80106e73:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106e78:	e9 65 f4 ff ff       	jmp    801062e2 <alltraps>

80106e7d <vector140>:
.globl vector140
vector140:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $140
80106e7f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106e84:	e9 59 f4 ff ff       	jmp    801062e2 <alltraps>

80106e89 <vector141>:
.globl vector141
vector141:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $141
80106e8b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106e90:	e9 4d f4 ff ff       	jmp    801062e2 <alltraps>

80106e95 <vector142>:
.globl vector142
vector142:
  pushl $0
80106e95:	6a 00                	push   $0x0
  pushl $142
80106e97:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106e9c:	e9 41 f4 ff ff       	jmp    801062e2 <alltraps>

80106ea1 <vector143>:
.globl vector143
vector143:
  pushl $0
80106ea1:	6a 00                	push   $0x0
  pushl $143
80106ea3:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106ea8:	e9 35 f4 ff ff       	jmp    801062e2 <alltraps>

80106ead <vector144>:
.globl vector144
vector144:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $144
80106eaf:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106eb4:	e9 29 f4 ff ff       	jmp    801062e2 <alltraps>

80106eb9 <vector145>:
.globl vector145
vector145:
  pushl $0
80106eb9:	6a 00                	push   $0x0
  pushl $145
80106ebb:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106ec0:	e9 1d f4 ff ff       	jmp    801062e2 <alltraps>

80106ec5 <vector146>:
.globl vector146
vector146:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $146
80106ec7:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106ecc:	e9 11 f4 ff ff       	jmp    801062e2 <alltraps>

80106ed1 <vector147>:
.globl vector147
vector147:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $147
80106ed3:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106ed8:	e9 05 f4 ff ff       	jmp    801062e2 <alltraps>

80106edd <vector148>:
.globl vector148
vector148:
  pushl $0
80106edd:	6a 00                	push   $0x0
  pushl $148
80106edf:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106ee4:	e9 f9 f3 ff ff       	jmp    801062e2 <alltraps>

80106ee9 <vector149>:
.globl vector149
vector149:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $149
80106eeb:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106ef0:	e9 ed f3 ff ff       	jmp    801062e2 <alltraps>

80106ef5 <vector150>:
.globl vector150
vector150:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $150
80106ef7:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106efc:	e9 e1 f3 ff ff       	jmp    801062e2 <alltraps>

80106f01 <vector151>:
.globl vector151
vector151:
  pushl $0
80106f01:	6a 00                	push   $0x0
  pushl $151
80106f03:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106f08:	e9 d5 f3 ff ff       	jmp    801062e2 <alltraps>

80106f0d <vector152>:
.globl vector152
vector152:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $152
80106f0f:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106f14:	e9 c9 f3 ff ff       	jmp    801062e2 <alltraps>

80106f19 <vector153>:
.globl vector153
vector153:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $153
80106f1b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106f20:	e9 bd f3 ff ff       	jmp    801062e2 <alltraps>

80106f25 <vector154>:
.globl vector154
vector154:
  pushl $0
80106f25:	6a 00                	push   $0x0
  pushl $154
80106f27:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106f2c:	e9 b1 f3 ff ff       	jmp    801062e2 <alltraps>

80106f31 <vector155>:
.globl vector155
vector155:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $155
80106f33:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106f38:	e9 a5 f3 ff ff       	jmp    801062e2 <alltraps>

80106f3d <vector156>:
.globl vector156
vector156:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $156
80106f3f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106f44:	e9 99 f3 ff ff       	jmp    801062e2 <alltraps>

80106f49 <vector157>:
.globl vector157
vector157:
  pushl $0
80106f49:	6a 00                	push   $0x0
  pushl $157
80106f4b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106f50:	e9 8d f3 ff ff       	jmp    801062e2 <alltraps>

80106f55 <vector158>:
.globl vector158
vector158:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $158
80106f57:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106f5c:	e9 81 f3 ff ff       	jmp    801062e2 <alltraps>

80106f61 <vector159>:
.globl vector159
vector159:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $159
80106f63:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106f68:	e9 75 f3 ff ff       	jmp    801062e2 <alltraps>

80106f6d <vector160>:
.globl vector160
vector160:
  pushl $0
80106f6d:	6a 00                	push   $0x0
  pushl $160
80106f6f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106f74:	e9 69 f3 ff ff       	jmp    801062e2 <alltraps>

80106f79 <vector161>:
.globl vector161
vector161:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $161
80106f7b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106f80:	e9 5d f3 ff ff       	jmp    801062e2 <alltraps>

80106f85 <vector162>:
.globl vector162
vector162:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $162
80106f87:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106f8c:	e9 51 f3 ff ff       	jmp    801062e2 <alltraps>

80106f91 <vector163>:
.globl vector163
vector163:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $163
80106f93:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106f98:	e9 45 f3 ff ff       	jmp    801062e2 <alltraps>

80106f9d <vector164>:
.globl vector164
vector164:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $164
80106f9f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106fa4:	e9 39 f3 ff ff       	jmp    801062e2 <alltraps>

80106fa9 <vector165>:
.globl vector165
vector165:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $165
80106fab:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106fb0:	e9 2d f3 ff ff       	jmp    801062e2 <alltraps>

80106fb5 <vector166>:
.globl vector166
vector166:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $166
80106fb7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106fbc:	e9 21 f3 ff ff       	jmp    801062e2 <alltraps>

80106fc1 <vector167>:
.globl vector167
vector167:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $167
80106fc3:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106fc8:	e9 15 f3 ff ff       	jmp    801062e2 <alltraps>

80106fcd <vector168>:
.globl vector168
vector168:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $168
80106fcf:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106fd4:	e9 09 f3 ff ff       	jmp    801062e2 <alltraps>

80106fd9 <vector169>:
.globl vector169
vector169:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $169
80106fdb:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106fe0:	e9 fd f2 ff ff       	jmp    801062e2 <alltraps>

80106fe5 <vector170>:
.globl vector170
vector170:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $170
80106fe7:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106fec:	e9 f1 f2 ff ff       	jmp    801062e2 <alltraps>

80106ff1 <vector171>:
.globl vector171
vector171:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $171
80106ff3:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106ff8:	e9 e5 f2 ff ff       	jmp    801062e2 <alltraps>

80106ffd <vector172>:
.globl vector172
vector172:
  pushl $0
80106ffd:	6a 00                	push   $0x0
  pushl $172
80106fff:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107004:	e9 d9 f2 ff ff       	jmp    801062e2 <alltraps>

80107009 <vector173>:
.globl vector173
vector173:
  pushl $0
80107009:	6a 00                	push   $0x0
  pushl $173
8010700b:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107010:	e9 cd f2 ff ff       	jmp    801062e2 <alltraps>

80107015 <vector174>:
.globl vector174
vector174:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $174
80107017:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010701c:	e9 c1 f2 ff ff       	jmp    801062e2 <alltraps>

80107021 <vector175>:
.globl vector175
vector175:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $175
80107023:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107028:	e9 b5 f2 ff ff       	jmp    801062e2 <alltraps>

8010702d <vector176>:
.globl vector176
vector176:
  pushl $0
8010702d:	6a 00                	push   $0x0
  pushl $176
8010702f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107034:	e9 a9 f2 ff ff       	jmp    801062e2 <alltraps>

80107039 <vector177>:
.globl vector177
vector177:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $177
8010703b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107040:	e9 9d f2 ff ff       	jmp    801062e2 <alltraps>

80107045 <vector178>:
.globl vector178
vector178:
  pushl $0
80107045:	6a 00                	push   $0x0
  pushl $178
80107047:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010704c:	e9 91 f2 ff ff       	jmp    801062e2 <alltraps>

80107051 <vector179>:
.globl vector179
vector179:
  pushl $0
80107051:	6a 00                	push   $0x0
  pushl $179
80107053:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107058:	e9 85 f2 ff ff       	jmp    801062e2 <alltraps>

8010705d <vector180>:
.globl vector180
vector180:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $180
8010705f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107064:	e9 79 f2 ff ff       	jmp    801062e2 <alltraps>

80107069 <vector181>:
.globl vector181
vector181:
  pushl $0
80107069:	6a 00                	push   $0x0
  pushl $181
8010706b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107070:	e9 6d f2 ff ff       	jmp    801062e2 <alltraps>

80107075 <vector182>:
.globl vector182
vector182:
  pushl $0
80107075:	6a 00                	push   $0x0
  pushl $182
80107077:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010707c:	e9 61 f2 ff ff       	jmp    801062e2 <alltraps>

80107081 <vector183>:
.globl vector183
vector183:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $183
80107083:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107088:	e9 55 f2 ff ff       	jmp    801062e2 <alltraps>

8010708d <vector184>:
.globl vector184
vector184:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $184
8010708f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107094:	e9 49 f2 ff ff       	jmp    801062e2 <alltraps>

80107099 <vector185>:
.globl vector185
vector185:
  pushl $0
80107099:	6a 00                	push   $0x0
  pushl $185
8010709b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801070a0:	e9 3d f2 ff ff       	jmp    801062e2 <alltraps>

801070a5 <vector186>:
.globl vector186
vector186:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $186
801070a7:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801070ac:	e9 31 f2 ff ff       	jmp    801062e2 <alltraps>

801070b1 <vector187>:
.globl vector187
vector187:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $187
801070b3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801070b8:	e9 25 f2 ff ff       	jmp    801062e2 <alltraps>

801070bd <vector188>:
.globl vector188
vector188:
  pushl $0
801070bd:	6a 00                	push   $0x0
  pushl $188
801070bf:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801070c4:	e9 19 f2 ff ff       	jmp    801062e2 <alltraps>

801070c9 <vector189>:
.globl vector189
vector189:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $189
801070cb:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801070d0:	e9 0d f2 ff ff       	jmp    801062e2 <alltraps>

801070d5 <vector190>:
.globl vector190
vector190:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $190
801070d7:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801070dc:	e9 01 f2 ff ff       	jmp    801062e2 <alltraps>

801070e1 <vector191>:
.globl vector191
vector191:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $191
801070e3:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801070e8:	e9 f5 f1 ff ff       	jmp    801062e2 <alltraps>

801070ed <vector192>:
.globl vector192
vector192:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $192
801070ef:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801070f4:	e9 e9 f1 ff ff       	jmp    801062e2 <alltraps>

801070f9 <vector193>:
.globl vector193
vector193:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $193
801070fb:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107100:	e9 dd f1 ff ff       	jmp    801062e2 <alltraps>

80107105 <vector194>:
.globl vector194
vector194:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $194
80107107:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010710c:	e9 d1 f1 ff ff       	jmp    801062e2 <alltraps>

80107111 <vector195>:
.globl vector195
vector195:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $195
80107113:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107118:	e9 c5 f1 ff ff       	jmp    801062e2 <alltraps>

8010711d <vector196>:
.globl vector196
vector196:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $196
8010711f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107124:	e9 b9 f1 ff ff       	jmp    801062e2 <alltraps>

80107129 <vector197>:
.globl vector197
vector197:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $197
8010712b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107130:	e9 ad f1 ff ff       	jmp    801062e2 <alltraps>

80107135 <vector198>:
.globl vector198
vector198:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $198
80107137:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010713c:	e9 a1 f1 ff ff       	jmp    801062e2 <alltraps>

80107141 <vector199>:
.globl vector199
vector199:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $199
80107143:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107148:	e9 95 f1 ff ff       	jmp    801062e2 <alltraps>

8010714d <vector200>:
.globl vector200
vector200:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $200
8010714f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107154:	e9 89 f1 ff ff       	jmp    801062e2 <alltraps>

80107159 <vector201>:
.globl vector201
vector201:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $201
8010715b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107160:	e9 7d f1 ff ff       	jmp    801062e2 <alltraps>

80107165 <vector202>:
.globl vector202
vector202:
  pushl $0
80107165:	6a 00                	push   $0x0
  pushl $202
80107167:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010716c:	e9 71 f1 ff ff       	jmp    801062e2 <alltraps>

80107171 <vector203>:
.globl vector203
vector203:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $203
80107173:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107178:	e9 65 f1 ff ff       	jmp    801062e2 <alltraps>

8010717d <vector204>:
.globl vector204
vector204:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $204
8010717f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107184:	e9 59 f1 ff ff       	jmp    801062e2 <alltraps>

80107189 <vector205>:
.globl vector205
vector205:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $205
8010718b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107190:	e9 4d f1 ff ff       	jmp    801062e2 <alltraps>

80107195 <vector206>:
.globl vector206
vector206:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $206
80107197:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010719c:	e9 41 f1 ff ff       	jmp    801062e2 <alltraps>

801071a1 <vector207>:
.globl vector207
vector207:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $207
801071a3:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801071a8:	e9 35 f1 ff ff       	jmp    801062e2 <alltraps>

801071ad <vector208>:
.globl vector208
vector208:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $208
801071af:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801071b4:	e9 29 f1 ff ff       	jmp    801062e2 <alltraps>

801071b9 <vector209>:
.globl vector209
vector209:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $209
801071bb:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801071c0:	e9 1d f1 ff ff       	jmp    801062e2 <alltraps>

801071c5 <vector210>:
.globl vector210
vector210:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $210
801071c7:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801071cc:	e9 11 f1 ff ff       	jmp    801062e2 <alltraps>

801071d1 <vector211>:
.globl vector211
vector211:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $211
801071d3:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801071d8:	e9 05 f1 ff ff       	jmp    801062e2 <alltraps>

801071dd <vector212>:
.globl vector212
vector212:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $212
801071df:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801071e4:	e9 f9 f0 ff ff       	jmp    801062e2 <alltraps>

801071e9 <vector213>:
.globl vector213
vector213:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $213
801071eb:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801071f0:	e9 ed f0 ff ff       	jmp    801062e2 <alltraps>

801071f5 <vector214>:
.globl vector214
vector214:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $214
801071f7:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801071fc:	e9 e1 f0 ff ff       	jmp    801062e2 <alltraps>

80107201 <vector215>:
.globl vector215
vector215:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $215
80107203:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107208:	e9 d5 f0 ff ff       	jmp    801062e2 <alltraps>

8010720d <vector216>:
.globl vector216
vector216:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $216
8010720f:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107214:	e9 c9 f0 ff ff       	jmp    801062e2 <alltraps>

80107219 <vector217>:
.globl vector217
vector217:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $217
8010721b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107220:	e9 bd f0 ff ff       	jmp    801062e2 <alltraps>

80107225 <vector218>:
.globl vector218
vector218:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $218
80107227:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010722c:	e9 b1 f0 ff ff       	jmp    801062e2 <alltraps>

80107231 <vector219>:
.globl vector219
vector219:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $219
80107233:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107238:	e9 a5 f0 ff ff       	jmp    801062e2 <alltraps>

8010723d <vector220>:
.globl vector220
vector220:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $220
8010723f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107244:	e9 99 f0 ff ff       	jmp    801062e2 <alltraps>

80107249 <vector221>:
.globl vector221
vector221:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $221
8010724b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107250:	e9 8d f0 ff ff       	jmp    801062e2 <alltraps>

80107255 <vector222>:
.globl vector222
vector222:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $222
80107257:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010725c:	e9 81 f0 ff ff       	jmp    801062e2 <alltraps>

80107261 <vector223>:
.globl vector223
vector223:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $223
80107263:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107268:	e9 75 f0 ff ff       	jmp    801062e2 <alltraps>

8010726d <vector224>:
.globl vector224
vector224:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $224
8010726f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107274:	e9 69 f0 ff ff       	jmp    801062e2 <alltraps>

80107279 <vector225>:
.globl vector225
vector225:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $225
8010727b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107280:	e9 5d f0 ff ff       	jmp    801062e2 <alltraps>

80107285 <vector226>:
.globl vector226
vector226:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $226
80107287:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010728c:	e9 51 f0 ff ff       	jmp    801062e2 <alltraps>

80107291 <vector227>:
.globl vector227
vector227:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $227
80107293:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107298:	e9 45 f0 ff ff       	jmp    801062e2 <alltraps>

8010729d <vector228>:
.globl vector228
vector228:
  pushl $0
8010729d:	6a 00                	push   $0x0
  pushl $228
8010729f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801072a4:	e9 39 f0 ff ff       	jmp    801062e2 <alltraps>

801072a9 <vector229>:
.globl vector229
vector229:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $229
801072ab:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801072b0:	e9 2d f0 ff ff       	jmp    801062e2 <alltraps>

801072b5 <vector230>:
.globl vector230
vector230:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $230
801072b7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801072bc:	e9 21 f0 ff ff       	jmp    801062e2 <alltraps>

801072c1 <vector231>:
.globl vector231
vector231:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $231
801072c3:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801072c8:	e9 15 f0 ff ff       	jmp    801062e2 <alltraps>

801072cd <vector232>:
.globl vector232
vector232:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $232
801072cf:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801072d4:	e9 09 f0 ff ff       	jmp    801062e2 <alltraps>

801072d9 <vector233>:
.globl vector233
vector233:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $233
801072db:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801072e0:	e9 fd ef ff ff       	jmp    801062e2 <alltraps>

801072e5 <vector234>:
.globl vector234
vector234:
  pushl $0
801072e5:	6a 00                	push   $0x0
  pushl $234
801072e7:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801072ec:	e9 f1 ef ff ff       	jmp    801062e2 <alltraps>

801072f1 <vector235>:
.globl vector235
vector235:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $235
801072f3:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801072f8:	e9 e5 ef ff ff       	jmp    801062e2 <alltraps>

801072fd <vector236>:
.globl vector236
vector236:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $236
801072ff:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107304:	e9 d9 ef ff ff       	jmp    801062e2 <alltraps>

80107309 <vector237>:
.globl vector237
vector237:
  pushl $0
80107309:	6a 00                	push   $0x0
  pushl $237
8010730b:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107310:	e9 cd ef ff ff       	jmp    801062e2 <alltraps>

80107315 <vector238>:
.globl vector238
vector238:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $238
80107317:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010731c:	e9 c1 ef ff ff       	jmp    801062e2 <alltraps>

80107321 <vector239>:
.globl vector239
vector239:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $239
80107323:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107328:	e9 b5 ef ff ff       	jmp    801062e2 <alltraps>

8010732d <vector240>:
.globl vector240
vector240:
  pushl $0
8010732d:	6a 00                	push   $0x0
  pushl $240
8010732f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107334:	e9 a9 ef ff ff       	jmp    801062e2 <alltraps>

80107339 <vector241>:
.globl vector241
vector241:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $241
8010733b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107340:	e9 9d ef ff ff       	jmp    801062e2 <alltraps>

80107345 <vector242>:
.globl vector242
vector242:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $242
80107347:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010734c:	e9 91 ef ff ff       	jmp    801062e2 <alltraps>

80107351 <vector243>:
.globl vector243
vector243:
  pushl $0
80107351:	6a 00                	push   $0x0
  pushl $243
80107353:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107358:	e9 85 ef ff ff       	jmp    801062e2 <alltraps>

8010735d <vector244>:
.globl vector244
vector244:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $244
8010735f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107364:	e9 79 ef ff ff       	jmp    801062e2 <alltraps>

80107369 <vector245>:
.globl vector245
vector245:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $245
8010736b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107370:	e9 6d ef ff ff       	jmp    801062e2 <alltraps>

80107375 <vector246>:
.globl vector246
vector246:
  pushl $0
80107375:	6a 00                	push   $0x0
  pushl $246
80107377:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010737c:	e9 61 ef ff ff       	jmp    801062e2 <alltraps>

80107381 <vector247>:
.globl vector247
vector247:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $247
80107383:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107388:	e9 55 ef ff ff       	jmp    801062e2 <alltraps>

8010738d <vector248>:
.globl vector248
vector248:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $248
8010738f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107394:	e9 49 ef ff ff       	jmp    801062e2 <alltraps>

80107399 <vector249>:
.globl vector249
vector249:
  pushl $0
80107399:	6a 00                	push   $0x0
  pushl $249
8010739b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801073a0:	e9 3d ef ff ff       	jmp    801062e2 <alltraps>

801073a5 <vector250>:
.globl vector250
vector250:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $250
801073a7:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801073ac:	e9 31 ef ff ff       	jmp    801062e2 <alltraps>

801073b1 <vector251>:
.globl vector251
vector251:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $251
801073b3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801073b8:	e9 25 ef ff ff       	jmp    801062e2 <alltraps>

801073bd <vector252>:
.globl vector252
vector252:
  pushl $0
801073bd:	6a 00                	push   $0x0
  pushl $252
801073bf:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801073c4:	e9 19 ef ff ff       	jmp    801062e2 <alltraps>

801073c9 <vector253>:
.globl vector253
vector253:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $253
801073cb:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801073d0:	e9 0d ef ff ff       	jmp    801062e2 <alltraps>

801073d5 <vector254>:
.globl vector254
vector254:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $254
801073d7:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801073dc:	e9 01 ef ff ff       	jmp    801062e2 <alltraps>

801073e1 <vector255>:
.globl vector255
vector255:
  pushl $0
801073e1:	6a 00                	push   $0x0
  pushl $255
801073e3:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801073e8:	e9 f5 ee ff ff       	jmp    801062e2 <alltraps>

801073ed <lgdt>:
{
801073ed:	55                   	push   %ebp
801073ee:	89 e5                	mov    %esp,%ebp
801073f0:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801073f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801073f6:	83 e8 01             	sub    $0x1,%eax
801073f9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801073fd:	8b 45 08             	mov    0x8(%ebp),%eax
80107400:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107404:	8b 45 08             	mov    0x8(%ebp),%eax
80107407:	c1 e8 10             	shr    $0x10,%eax
8010740a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010740e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107411:	0f 01 10             	lgdtl  (%eax)
}
80107414:	90                   	nop
80107415:	c9                   	leave  
80107416:	c3                   	ret    

80107417 <ltr>:
{
80107417:	55                   	push   %ebp
80107418:	89 e5                	mov    %esp,%ebp
8010741a:	83 ec 04             	sub    $0x4,%esp
8010741d:	8b 45 08             	mov    0x8(%ebp),%eax
80107420:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107424:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107428:	0f 00 d8             	ltr    %ax
}
8010742b:	90                   	nop
8010742c:	c9                   	leave  
8010742d:	c3                   	ret    

8010742e <lcr3>:

static inline void
lcr3(uint val)
{
8010742e:	55                   	push   %ebp
8010742f:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107431:	8b 45 08             	mov    0x8(%ebp),%eax
80107434:	0f 22 d8             	mov    %eax,%cr3
}
80107437:	90                   	nop
80107438:	5d                   	pop    %ebp
80107439:	c3                   	ret    

8010743a <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010743a:	f3 0f 1e fb          	endbr32 
8010743e:	55                   	push   %ebp
8010743f:	89 e5                	mov    %esp,%ebp
80107441:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107444:	e8 c5 c6 ff ff       	call   80103b0e <cpuid>
80107449:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010744f:	05 c0 7e 19 80       	add    $0x80197ec0,%eax
80107454:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010745a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107463:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010746c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107473:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107477:	83 e2 f0             	and    $0xfffffff0,%edx
8010747a:	83 ca 0a             	or     $0xa,%edx
8010747d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107483:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107487:	83 ca 10             	or     $0x10,%edx
8010748a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010748d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107490:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107494:	83 e2 9f             	and    $0xffffff9f,%edx
80107497:	88 50 7d             	mov    %dl,0x7d(%eax)
8010749a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801074a1:	83 ca 80             	or     $0xffffff80,%edx
801074a4:	88 50 7d             	mov    %dl,0x7d(%eax)
801074a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074aa:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074ae:	83 ca 0f             	or     $0xf,%edx
801074b1:	88 50 7e             	mov    %dl,0x7e(%eax)
801074b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074bb:	83 e2 ef             	and    $0xffffffef,%edx
801074be:	88 50 7e             	mov    %dl,0x7e(%eax)
801074c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074c8:	83 e2 df             	and    $0xffffffdf,%edx
801074cb:	88 50 7e             	mov    %dl,0x7e(%eax)
801074ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074d5:	83 ca 40             	or     $0x40,%edx
801074d8:	88 50 7e             	mov    %dl,0x7e(%eax)
801074db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074de:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801074e2:	83 ca 80             	or     $0xffffff80,%edx
801074e5:	88 50 7e             	mov    %dl,0x7e(%eax)
801074e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074eb:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801074ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f2:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801074f9:	ff ff 
801074fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fe:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107505:	00 00 
80107507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750a:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107514:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010751b:	83 e2 f0             	and    $0xfffffff0,%edx
8010751e:	83 ca 02             	or     $0x2,%edx
80107521:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010752a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107531:	83 ca 10             	or     $0x10,%edx
80107534:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010753a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107544:	83 e2 9f             	and    $0xffffff9f,%edx
80107547:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010754d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107550:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107557:	83 ca 80             	or     $0xffffff80,%edx
8010755a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107563:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010756a:	83 ca 0f             	or     $0xf,%edx
8010756d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107576:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010757d:	83 e2 ef             	and    $0xffffffef,%edx
80107580:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107589:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107590:	83 e2 df             	and    $0xffffffdf,%edx
80107593:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075a3:	83 ca 40             	or     $0x40,%edx
801075a6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075af:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801075b6:	83 ca 80             	or     $0xffffff80,%edx
801075b9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801075bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075c2:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801075c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cc:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801075d3:	ff ff 
801075d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075d8:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801075df:	00 00 
801075e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e4:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801075eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ee:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801075f5:	83 e2 f0             	and    $0xfffffff0,%edx
801075f8:	83 ca 0a             	or     $0xa,%edx
801075fb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107604:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010760b:	83 ca 10             	or     $0x10,%edx
8010760e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107617:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010761e:	83 ca 60             	or     $0x60,%edx
80107621:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107631:	83 ca 80             	or     $0xffffff80,%edx
80107634:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010763a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107644:	83 ca 0f             	or     $0xf,%edx
80107647:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010764d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107650:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107657:	83 e2 ef             	and    $0xffffffef,%edx
8010765a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107663:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010766a:	83 e2 df             	and    $0xffffffdf,%edx
8010766d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107676:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010767d:	83 ca 40             	or     $0x40,%edx
80107680:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107689:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107690:	83 ca 80             	or     $0xffffff80,%edx
80107693:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769c:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801076a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a6:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801076ad:	ff ff 
801076af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b2:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801076b9:	00 00 
801076bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076be:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801076c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801076cf:	83 e2 f0             	and    $0xfffffff0,%edx
801076d2:	83 ca 02             	or     $0x2,%edx
801076d5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801076db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076de:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801076e5:	83 ca 10             	or     $0x10,%edx
801076e8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801076ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801076f8:	83 ca 60             	or     $0x60,%edx
801076fb:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107704:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010770b:	83 ca 80             	or     $0xffffff80,%edx
8010770e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107717:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010771e:	83 ca 0f             	or     $0xf,%edx
80107721:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107731:	83 e2 ef             	and    $0xffffffef,%edx
80107734:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010773a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107744:	83 e2 df             	and    $0xffffffdf,%edx
80107747:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010774d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107750:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107757:	83 ca 40             	or     $0x40,%edx
8010775a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107763:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010776a:	83 ca 80             	or     $0xffffff80,%edx
8010776d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107776:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010777d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107780:	83 c0 70             	add    $0x70,%eax
80107783:	83 ec 08             	sub    $0x8,%esp
80107786:	6a 30                	push   $0x30
80107788:	50                   	push   %eax
80107789:	e8 5f fc ff ff       	call   801073ed <lgdt>
8010778e:	83 c4 10             	add    $0x10,%esp
}
80107791:	90                   	nop
80107792:	c9                   	leave  
80107793:	c3                   	ret    

80107794 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107794:	f3 0f 1e fb          	endbr32 
80107798:	55                   	push   %ebp
80107799:	89 e5                	mov    %esp,%ebp
8010779b:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010779e:	8b 45 0c             	mov    0xc(%ebp),%eax
801077a1:	c1 e8 16             	shr    $0x16,%eax
801077a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801077ab:	8b 45 08             	mov    0x8(%ebp),%eax
801077ae:	01 d0                	add    %edx,%eax
801077b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801077b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077b6:	8b 00                	mov    (%eax),%eax
801077b8:	83 e0 01             	and    $0x1,%eax
801077bb:	85 c0                	test   %eax,%eax
801077bd:	74 14                	je     801077d3 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801077bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077c2:	8b 00                	mov    (%eax),%eax
801077c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077c9:	05 00 00 00 80       	add    $0x80000000,%eax
801077ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077d1:	eb 42                	jmp    80107815 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801077d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801077d7:	74 0e                	je     801077e7 <walkpgdir+0x53>
801077d9:	e8 b4 b0 ff ff       	call   80102892 <kalloc>
801077de:	89 45 f4             	mov    %eax,-0xc(%ebp)
801077e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801077e5:	75 07                	jne    801077ee <walkpgdir+0x5a>
      return 0;
801077e7:	b8 00 00 00 00       	mov    $0x0,%eax
801077ec:	eb 3e                	jmp    8010782c <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801077ee:	83 ec 04             	sub    $0x4,%esp
801077f1:	68 00 10 00 00       	push   $0x1000
801077f6:	6a 00                	push   $0x0
801077f8:	ff 75 f4             	pushl  -0xc(%ebp)
801077fb:	e8 1b d6 ff ff       	call   80104e1b <memset>
80107800:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107806:	05 00 00 00 80       	add    $0x80000000,%eax
8010780b:	83 c8 07             	or     $0x7,%eax
8010780e:	89 c2                	mov    %eax,%edx
80107810:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107813:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107815:	8b 45 0c             	mov    0xc(%ebp),%eax
80107818:	c1 e8 0c             	shr    $0xc,%eax
8010781b:	25 ff 03 00 00       	and    $0x3ff,%eax
80107820:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782a:	01 d0                	add    %edx,%eax
}
8010782c:	c9                   	leave  
8010782d:	c3                   	ret    

8010782e <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010782e:	f3 0f 1e fb          	endbr32 
80107832:	55                   	push   %ebp
80107833:	89 e5                	mov    %esp,%ebp
80107835:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107838:	8b 45 0c             	mov    0xc(%ebp),%eax
8010783b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107840:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107843:	8b 55 0c             	mov    0xc(%ebp),%edx
80107846:	8b 45 10             	mov    0x10(%ebp),%eax
80107849:	01 d0                	add    %edx,%eax
8010784b:	83 e8 01             	sub    $0x1,%eax
8010784e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107853:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107856:	83 ec 04             	sub    $0x4,%esp
80107859:	6a 01                	push   $0x1
8010785b:	ff 75 f4             	pushl  -0xc(%ebp)
8010785e:	ff 75 08             	pushl  0x8(%ebp)
80107861:	e8 2e ff ff ff       	call   80107794 <walkpgdir>
80107866:	83 c4 10             	add    $0x10,%esp
80107869:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010786c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107870:	75 07                	jne    80107879 <mappages+0x4b>
      return -1;
80107872:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107877:	eb 47                	jmp    801078c0 <mappages+0x92>
    if(*pte & PTE_P)
80107879:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010787c:	8b 00                	mov    (%eax),%eax
8010787e:	83 e0 01             	and    $0x1,%eax
80107881:	85 c0                	test   %eax,%eax
80107883:	74 0d                	je     80107892 <mappages+0x64>
      panic("remap");
80107885:	83 ec 0c             	sub    $0xc,%esp
80107888:	68 68 ac 10 80       	push   $0x8010ac68
8010788d:	e8 33 8d ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
80107892:	8b 45 18             	mov    0x18(%ebp),%eax
80107895:	0b 45 14             	or     0x14(%ebp),%eax
80107898:	83 c8 01             	or     $0x1,%eax
8010789b:	89 c2                	mov    %eax,%edx
8010789d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078a0:	89 10                	mov    %edx,(%eax)
    if(a == last)
801078a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801078a8:	74 10                	je     801078ba <mappages+0x8c>
      break;
    a += PGSIZE;
801078aa:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801078b1:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801078b8:	eb 9c                	jmp    80107856 <mappages+0x28>
      break;
801078ba:	90                   	nop
  }
  return 0;
801078bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801078c0:	c9                   	leave  
801078c1:	c3                   	ret    

801078c2 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801078c2:	f3 0f 1e fb          	endbr32 
801078c6:	55                   	push   %ebp
801078c7:	89 e5                	mov    %esp,%ebp
801078c9:	53                   	push   %ebx
801078ca:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801078cd:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
801078d4:	a1 8c 81 19 80       	mov    0x8019818c,%eax
801078d9:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801078de:	29 c2                	sub    %eax,%edx
801078e0:	89 d0                	mov    %edx,%eax
801078e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
801078e5:	a1 84 81 19 80       	mov    0x80198184,%eax
801078ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801078ed:	8b 15 84 81 19 80    	mov    0x80198184,%edx
801078f3:	a1 8c 81 19 80       	mov    0x8019818c,%eax
801078f8:	01 d0                	add    %edx,%eax
801078fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
801078fd:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107907:	83 c0 30             	add    $0x30,%eax
8010790a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010790d:	89 10                	mov    %edx,(%eax)
8010790f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107912:	89 50 04             	mov    %edx,0x4(%eax)
80107915:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107918:	89 50 08             	mov    %edx,0x8(%eax)
8010791b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010791e:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107921:	e8 6c af ff ff       	call   80102892 <kalloc>
80107926:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107929:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010792d:	75 07                	jne    80107936 <setupkvm+0x74>
    return 0;
8010792f:	b8 00 00 00 00       	mov    $0x0,%eax
80107934:	eb 78                	jmp    801079ae <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
80107936:	83 ec 04             	sub    $0x4,%esp
80107939:	68 00 10 00 00       	push   $0x1000
8010793e:	6a 00                	push   $0x0
80107940:	ff 75 f0             	pushl  -0x10(%ebp)
80107943:	e8 d3 d4 ff ff       	call   80104e1b <memset>
80107948:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010794b:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107952:	eb 4e                	jmp    801079a2 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107957:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
8010795a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795d:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107963:	8b 58 08             	mov    0x8(%eax),%ebx
80107966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107969:	8b 40 04             	mov    0x4(%eax),%eax
8010796c:	29 c3                	sub    %eax,%ebx
8010796e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107971:	8b 00                	mov    (%eax),%eax
80107973:	83 ec 0c             	sub    $0xc,%esp
80107976:	51                   	push   %ecx
80107977:	52                   	push   %edx
80107978:	53                   	push   %ebx
80107979:	50                   	push   %eax
8010797a:	ff 75 f0             	pushl  -0x10(%ebp)
8010797d:	e8 ac fe ff ff       	call   8010782e <mappages>
80107982:	83 c4 20             	add    $0x20,%esp
80107985:	85 c0                	test   %eax,%eax
80107987:	79 15                	jns    8010799e <setupkvm+0xdc>
      freevm(pgdir);
80107989:	83 ec 0c             	sub    $0xc,%esp
8010798c:	ff 75 f0             	pushl  -0x10(%ebp)
8010798f:	e8 11 05 00 00       	call   80107ea5 <freevm>
80107994:	83 c4 10             	add    $0x10,%esp
      return 0;
80107997:	b8 00 00 00 00       	mov    $0x0,%eax
8010799c:	eb 10                	jmp    801079ae <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010799e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801079a2:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
801079a9:	72 a9                	jb     80107954 <setupkvm+0x92>
    }
  return pgdir;
801079ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801079ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801079b1:	c9                   	leave  
801079b2:	c3                   	ret    

801079b3 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801079b3:	f3 0f 1e fb          	endbr32 
801079b7:	55                   	push   %ebp
801079b8:	89 e5                	mov    %esp,%ebp
801079ba:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801079bd:	e8 00 ff ff ff       	call   801078c2 <setupkvm>
801079c2:	a3 84 7e 19 80       	mov    %eax,0x80197e84
  switchkvm();
801079c7:	e8 03 00 00 00       	call   801079cf <switchkvm>
}
801079cc:	90                   	nop
801079cd:	c9                   	leave  
801079ce:	c3                   	ret    

801079cf <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801079cf:	f3 0f 1e fb          	endbr32 
801079d3:	55                   	push   %ebp
801079d4:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801079d6:	a1 84 7e 19 80       	mov    0x80197e84,%eax
801079db:	05 00 00 00 80       	add    $0x80000000,%eax
801079e0:	50                   	push   %eax
801079e1:	e8 48 fa ff ff       	call   8010742e <lcr3>
801079e6:	83 c4 04             	add    $0x4,%esp
}
801079e9:	90                   	nop
801079ea:	c9                   	leave  
801079eb:	c3                   	ret    

801079ec <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801079ec:	f3 0f 1e fb          	endbr32 
801079f0:	55                   	push   %ebp
801079f1:	89 e5                	mov    %esp,%ebp
801079f3:	56                   	push   %esi
801079f4:	53                   	push   %ebx
801079f5:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801079f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801079fc:	75 0d                	jne    80107a0b <switchuvm+0x1f>
    panic("switchuvm: no process");
801079fe:	83 ec 0c             	sub    $0xc,%esp
80107a01:	68 6e ac 10 80       	push   $0x8010ac6e
80107a06:	e8 ba 8b ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
80107a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0e:	8b 40 08             	mov    0x8(%eax),%eax
80107a11:	85 c0                	test   %eax,%eax
80107a13:	75 0d                	jne    80107a22 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107a15:	83 ec 0c             	sub    $0xc,%esp
80107a18:	68 84 ac 10 80       	push   $0x8010ac84
80107a1d:	e8 a3 8b ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
80107a22:	8b 45 08             	mov    0x8(%ebp),%eax
80107a25:	8b 40 04             	mov    0x4(%eax),%eax
80107a28:	85 c0                	test   %eax,%eax
80107a2a:	75 0d                	jne    80107a39 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107a2c:	83 ec 0c             	sub    $0xc,%esp
80107a2f:	68 99 ac 10 80       	push   $0x8010ac99
80107a34:	e8 8c 8b ff ff       	call   801005c5 <panic>

  pushcli();
80107a39:	e8 ca d2 ff ff       	call   80104d08 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107a3e:	e8 ea c0 ff ff       	call   80103b2d <mycpu>
80107a43:	89 c3                	mov    %eax,%ebx
80107a45:	e8 e3 c0 ff ff       	call   80103b2d <mycpu>
80107a4a:	83 c0 08             	add    $0x8,%eax
80107a4d:	89 c6                	mov    %eax,%esi
80107a4f:	e8 d9 c0 ff ff       	call   80103b2d <mycpu>
80107a54:	83 c0 08             	add    $0x8,%eax
80107a57:	c1 e8 10             	shr    $0x10,%eax
80107a5a:	88 45 f7             	mov    %al,-0x9(%ebp)
80107a5d:	e8 cb c0 ff ff       	call   80103b2d <mycpu>
80107a62:	83 c0 08             	add    $0x8,%eax
80107a65:	c1 e8 18             	shr    $0x18,%eax
80107a68:	89 c2                	mov    %eax,%edx
80107a6a:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107a71:	67 00 
80107a73:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107a7a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107a7e:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107a84:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a8b:	83 e0 f0             	and    $0xfffffff0,%eax
80107a8e:	83 c8 09             	or     $0x9,%eax
80107a91:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a97:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107a9e:	83 c8 10             	or     $0x10,%eax
80107aa1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107aa7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107aae:	83 e0 9f             	and    $0xffffff9f,%eax
80107ab1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ab7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107abe:	83 c8 80             	or     $0xffffff80,%eax
80107ac1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ac7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ace:	83 e0 f0             	and    $0xfffffff0,%eax
80107ad1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ad7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ade:	83 e0 ef             	and    $0xffffffef,%eax
80107ae1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ae7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107aee:	83 e0 df             	and    $0xffffffdf,%eax
80107af1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107af7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107afe:	83 c8 40             	or     $0x40,%eax
80107b01:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b07:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107b0e:	83 e0 7f             	and    $0x7f,%eax
80107b11:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107b17:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107b1d:	e8 0b c0 ff ff       	call   80103b2d <mycpu>
80107b22:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b29:	83 e2 ef             	and    $0xffffffef,%edx
80107b2c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107b32:	e8 f6 bf ff ff       	call   80103b2d <mycpu>
80107b37:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80107b40:	8b 40 08             	mov    0x8(%eax),%eax
80107b43:	89 c3                	mov    %eax,%ebx
80107b45:	e8 e3 bf ff ff       	call   80103b2d <mycpu>
80107b4a:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107b50:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107b53:	e8 d5 bf ff ff       	call   80103b2d <mycpu>
80107b58:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107b5e:	83 ec 0c             	sub    $0xc,%esp
80107b61:	6a 28                	push   $0x28
80107b63:	e8 af f8 ff ff       	call   80107417 <ltr>
80107b68:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80107b6e:	8b 40 04             	mov    0x4(%eax),%eax
80107b71:	05 00 00 00 80       	add    $0x80000000,%eax
80107b76:	83 ec 0c             	sub    $0xc,%esp
80107b79:	50                   	push   %eax
80107b7a:	e8 af f8 ff ff       	call   8010742e <lcr3>
80107b7f:	83 c4 10             	add    $0x10,%esp
  popcli();
80107b82:	e8 d2 d1 ff ff       	call   80104d59 <popcli>
}
80107b87:	90                   	nop
80107b88:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107b8b:	5b                   	pop    %ebx
80107b8c:	5e                   	pop    %esi
80107b8d:	5d                   	pop    %ebp
80107b8e:	c3                   	ret    

80107b8f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107b8f:	f3 0f 1e fb          	endbr32 
80107b93:	55                   	push   %ebp
80107b94:	89 e5                	mov    %esp,%ebp
80107b96:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107b99:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107ba0:	76 0d                	jbe    80107baf <inituvm+0x20>
    panic("inituvm: more than a page");
80107ba2:	83 ec 0c             	sub    $0xc,%esp
80107ba5:	68 ad ac 10 80       	push   $0x8010acad
80107baa:	e8 16 8a ff ff       	call   801005c5 <panic>
  mem = kalloc();
80107baf:	e8 de ac ff ff       	call   80102892 <kalloc>
80107bb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107bb7:	83 ec 04             	sub    $0x4,%esp
80107bba:	68 00 10 00 00       	push   $0x1000
80107bbf:	6a 00                	push   $0x0
80107bc1:	ff 75 f4             	pushl  -0xc(%ebp)
80107bc4:	e8 52 d2 ff ff       	call   80104e1b <memset>
80107bc9:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcf:	05 00 00 00 80       	add    $0x80000000,%eax
80107bd4:	83 ec 0c             	sub    $0xc,%esp
80107bd7:	6a 06                	push   $0x6
80107bd9:	50                   	push   %eax
80107bda:	68 00 10 00 00       	push   $0x1000
80107bdf:	6a 00                	push   $0x0
80107be1:	ff 75 08             	pushl  0x8(%ebp)
80107be4:	e8 45 fc ff ff       	call   8010782e <mappages>
80107be9:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107bec:	83 ec 04             	sub    $0x4,%esp
80107bef:	ff 75 10             	pushl  0x10(%ebp)
80107bf2:	ff 75 0c             	pushl  0xc(%ebp)
80107bf5:	ff 75 f4             	pushl  -0xc(%ebp)
80107bf8:	e8 e5 d2 ff ff       	call   80104ee2 <memmove>
80107bfd:	83 c4 10             	add    $0x10,%esp
}
80107c00:	90                   	nop
80107c01:	c9                   	leave  
80107c02:	c3                   	ret    

80107c03 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107c03:	f3 0f 1e fb          	endbr32 
80107c07:	55                   	push   %ebp
80107c08:	89 e5                	mov    %esp,%ebp
80107c0a:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c10:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c15:	85 c0                	test   %eax,%eax
80107c17:	74 0d                	je     80107c26 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107c19:	83 ec 0c             	sub    $0xc,%esp
80107c1c:	68 c8 ac 10 80       	push   $0x8010acc8
80107c21:	e8 9f 89 ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107c26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c2d:	e9 8f 00 00 00       	jmp    80107cc1 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107c32:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c38:	01 d0                	add    %edx,%eax
80107c3a:	83 ec 04             	sub    $0x4,%esp
80107c3d:	6a 00                	push   $0x0
80107c3f:	50                   	push   %eax
80107c40:	ff 75 08             	pushl  0x8(%ebp)
80107c43:	e8 4c fb ff ff       	call   80107794 <walkpgdir>
80107c48:	83 c4 10             	add    $0x10,%esp
80107c4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c4e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c52:	75 0d                	jne    80107c61 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107c54:	83 ec 0c             	sub    $0xc,%esp
80107c57:	68 eb ac 10 80       	push   $0x8010aceb
80107c5c:	e8 64 89 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107c61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c64:	8b 00                	mov    (%eax),%eax
80107c66:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c6b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107c6e:	8b 45 18             	mov    0x18(%ebp),%eax
80107c71:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107c74:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107c79:	77 0b                	ja     80107c86 <loaduvm+0x83>
      n = sz - i;
80107c7b:	8b 45 18             	mov    0x18(%ebp),%eax
80107c7e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107c81:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c84:	eb 07                	jmp    80107c8d <loaduvm+0x8a>
    else
      n = PGSIZE;
80107c86:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107c8d:	8b 55 14             	mov    0x14(%ebp),%edx
80107c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c93:	01 d0                	add    %edx,%eax
80107c95:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107c98:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107c9e:	ff 75 f0             	pushl  -0x10(%ebp)
80107ca1:	50                   	push   %eax
80107ca2:	52                   	push   %edx
80107ca3:	ff 75 10             	pushl  0x10(%ebp)
80107ca6:	e8 d9 a2 ff ff       	call   80101f84 <readi>
80107cab:	83 c4 10             	add    $0x10,%esp
80107cae:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107cb1:	74 07                	je     80107cba <loaduvm+0xb7>
      return -1;
80107cb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cb8:	eb 18                	jmp    80107cd2 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107cba:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc4:	3b 45 18             	cmp    0x18(%ebp),%eax
80107cc7:	0f 82 65 ff ff ff    	jb     80107c32 <loaduvm+0x2f>
  }
  return 0;
80107ccd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107cd2:	c9                   	leave  
80107cd3:	c3                   	ret    

80107cd4 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107cd4:	f3 0f 1e fb          	endbr32 
80107cd8:	55                   	push   %ebp
80107cd9:	89 e5                	mov    %esp,%ebp
80107cdb:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107cde:	8b 45 10             	mov    0x10(%ebp),%eax
80107ce1:	85 c0                	test   %eax,%eax
80107ce3:	79 0a                	jns    80107cef <allocuvm+0x1b>
    return 0;
80107ce5:	b8 00 00 00 00       	mov    $0x0,%eax
80107cea:	e9 ec 00 00 00       	jmp    80107ddb <allocuvm+0x107>
  if(newsz < oldsz)
80107cef:	8b 45 10             	mov    0x10(%ebp),%eax
80107cf2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107cf5:	73 08                	jae    80107cff <allocuvm+0x2b>
    return oldsz;
80107cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cfa:	e9 dc 00 00 00       	jmp    80107ddb <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107cff:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d02:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107d0f:	e9 b8 00 00 00       	jmp    80107dcc <allocuvm+0xf8>
    mem = kalloc();
80107d14:	e8 79 ab ff ff       	call   80102892 <kalloc>
80107d19:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107d1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d20:	75 2e                	jne    80107d50 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107d22:	83 ec 0c             	sub    $0xc,%esp
80107d25:	68 09 ad 10 80       	push   $0x8010ad09
80107d2a:	e8 dd 86 ff ff       	call   8010040c <cprintf>
80107d2f:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107d32:	83 ec 04             	sub    $0x4,%esp
80107d35:	ff 75 0c             	pushl  0xc(%ebp)
80107d38:	ff 75 10             	pushl  0x10(%ebp)
80107d3b:	ff 75 08             	pushl  0x8(%ebp)
80107d3e:	e8 9a 00 00 00       	call   80107ddd <deallocuvm>
80107d43:	83 c4 10             	add    $0x10,%esp
      return 0;
80107d46:	b8 00 00 00 00       	mov    $0x0,%eax
80107d4b:	e9 8b 00 00 00       	jmp    80107ddb <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107d50:	83 ec 04             	sub    $0x4,%esp
80107d53:	68 00 10 00 00       	push   $0x1000
80107d58:	6a 00                	push   $0x0
80107d5a:	ff 75 f0             	pushl  -0x10(%ebp)
80107d5d:	e8 b9 d0 ff ff       	call   80104e1b <memset>
80107d62:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d68:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d71:	83 ec 0c             	sub    $0xc,%esp
80107d74:	6a 06                	push   $0x6
80107d76:	52                   	push   %edx
80107d77:	68 00 10 00 00       	push   $0x1000
80107d7c:	50                   	push   %eax
80107d7d:	ff 75 08             	pushl  0x8(%ebp)
80107d80:	e8 a9 fa ff ff       	call   8010782e <mappages>
80107d85:	83 c4 20             	add    $0x20,%esp
80107d88:	85 c0                	test   %eax,%eax
80107d8a:	79 39                	jns    80107dc5 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107d8c:	83 ec 0c             	sub    $0xc,%esp
80107d8f:	68 21 ad 10 80       	push   $0x8010ad21
80107d94:	e8 73 86 ff ff       	call   8010040c <cprintf>
80107d99:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107d9c:	83 ec 04             	sub    $0x4,%esp
80107d9f:	ff 75 0c             	pushl  0xc(%ebp)
80107da2:	ff 75 10             	pushl  0x10(%ebp)
80107da5:	ff 75 08             	pushl  0x8(%ebp)
80107da8:	e8 30 00 00 00       	call   80107ddd <deallocuvm>
80107dad:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107db0:	83 ec 0c             	sub    $0xc,%esp
80107db3:	ff 75 f0             	pushl  -0x10(%ebp)
80107db6:	e8 39 aa ff ff       	call   801027f4 <kfree>
80107dbb:	83 c4 10             	add    $0x10,%esp
      return 0;
80107dbe:	b8 00 00 00 00       	mov    $0x0,%eax
80107dc3:	eb 16                	jmp    80107ddb <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107dc5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcf:	3b 45 10             	cmp    0x10(%ebp),%eax
80107dd2:	0f 82 3c ff ff ff    	jb     80107d14 <allocuvm+0x40>
    }
  }
  return newsz;
80107dd8:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ddb:	c9                   	leave  
80107ddc:	c3                   	ret    

80107ddd <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ddd:	f3 0f 1e fb          	endbr32 
80107de1:	55                   	push   %ebp
80107de2:	89 e5                	mov    %esp,%ebp
80107de4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107de7:	8b 45 10             	mov    0x10(%ebp),%eax
80107dea:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ded:	72 08                	jb     80107df7 <deallocuvm+0x1a>
    return oldsz;
80107def:	8b 45 0c             	mov    0xc(%ebp),%eax
80107df2:	e9 ac 00 00 00       	jmp    80107ea3 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107df7:	8b 45 10             	mov    0x10(%ebp),%eax
80107dfa:	05 ff 0f 00 00       	add    $0xfff,%eax
80107dff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e04:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107e07:	e9 88 00 00 00       	jmp    80107e94 <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0f:	83 ec 04             	sub    $0x4,%esp
80107e12:	6a 00                	push   $0x0
80107e14:	50                   	push   %eax
80107e15:	ff 75 08             	pushl  0x8(%ebp)
80107e18:	e8 77 f9 ff ff       	call   80107794 <walkpgdir>
80107e1d:	83 c4 10             	add    $0x10,%esp
80107e20:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107e23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e27:	75 16                	jne    80107e3f <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2c:	c1 e8 16             	shr    $0x16,%eax
80107e2f:	83 c0 01             	add    $0x1,%eax
80107e32:	c1 e0 16             	shl    $0x16,%eax
80107e35:	2d 00 10 00 00       	sub    $0x1000,%eax
80107e3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e3d:	eb 4e                	jmp    80107e8d <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80107e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e42:	8b 00                	mov    (%eax),%eax
80107e44:	83 e0 01             	and    $0x1,%eax
80107e47:	85 c0                	test   %eax,%eax
80107e49:	74 42                	je     80107e8d <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80107e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e4e:	8b 00                	mov    (%eax),%eax
80107e50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e55:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107e58:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e5c:	75 0d                	jne    80107e6b <deallocuvm+0x8e>
        panic("kfree");
80107e5e:	83 ec 0c             	sub    $0xc,%esp
80107e61:	68 3d ad 10 80       	push   $0x8010ad3d
80107e66:	e8 5a 87 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80107e6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e6e:	05 00 00 00 80       	add    $0x80000000,%eax
80107e73:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107e76:	83 ec 0c             	sub    $0xc,%esp
80107e79:	ff 75 e8             	pushl  -0x18(%ebp)
80107e7c:	e8 73 a9 ff ff       	call   801027f4 <kfree>
80107e81:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107e8d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e97:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e9a:	0f 82 6c ff ff ff    	jb     80107e0c <deallocuvm+0x2f>
    }
  }
  return newsz;
80107ea0:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107ea3:	c9                   	leave  
80107ea4:	c3                   	ret    

80107ea5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107ea5:	f3 0f 1e fb          	endbr32 
80107ea9:	55                   	push   %ebp
80107eaa:	89 e5                	mov    %esp,%ebp
80107eac:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107eaf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107eb3:	75 0d                	jne    80107ec2 <freevm+0x1d>
    panic("freevm: no pgdir");
80107eb5:	83 ec 0c             	sub    $0xc,%esp
80107eb8:	68 43 ad 10 80       	push   $0x8010ad43
80107ebd:	e8 03 87 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107ec2:	83 ec 04             	sub    $0x4,%esp
80107ec5:	6a 00                	push   $0x0
80107ec7:	68 00 00 00 80       	push   $0x80000000
80107ecc:	ff 75 08             	pushl  0x8(%ebp)
80107ecf:	e8 09 ff ff ff       	call   80107ddd <deallocuvm>
80107ed4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107ed7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ede:	eb 48                	jmp    80107f28 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107eea:	8b 45 08             	mov    0x8(%ebp),%eax
80107eed:	01 d0                	add    %edx,%eax
80107eef:	8b 00                	mov    (%eax),%eax
80107ef1:	83 e0 01             	and    $0x1,%eax
80107ef4:	85 c0                	test   %eax,%eax
80107ef6:	74 2c                	je     80107f24 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f02:	8b 45 08             	mov    0x8(%ebp),%eax
80107f05:	01 d0                	add    %edx,%eax
80107f07:	8b 00                	mov    (%eax),%eax
80107f09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f0e:	05 00 00 00 80       	add    $0x80000000,%eax
80107f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107f16:	83 ec 0c             	sub    $0xc,%esp
80107f19:	ff 75 f0             	pushl  -0x10(%ebp)
80107f1c:	e8 d3 a8 ff ff       	call   801027f4 <kfree>
80107f21:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107f24:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107f28:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107f2f:	76 af                	jbe    80107ee0 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80107f31:	83 ec 0c             	sub    $0xc,%esp
80107f34:	ff 75 08             	pushl  0x8(%ebp)
80107f37:	e8 b8 a8 ff ff       	call   801027f4 <kfree>
80107f3c:	83 c4 10             	add    $0x10,%esp
}
80107f3f:	90                   	nop
80107f40:	c9                   	leave  
80107f41:	c3                   	ret    

80107f42 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107f42:	f3 0f 1e fb          	endbr32 
80107f46:	55                   	push   %ebp
80107f47:	89 e5                	mov    %esp,%ebp
80107f49:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f4c:	83 ec 04             	sub    $0x4,%esp
80107f4f:	6a 00                	push   $0x0
80107f51:	ff 75 0c             	pushl  0xc(%ebp)
80107f54:	ff 75 08             	pushl  0x8(%ebp)
80107f57:	e8 38 f8 ff ff       	call   80107794 <walkpgdir>
80107f5c:	83 c4 10             	add    $0x10,%esp
80107f5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107f62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f66:	75 0d                	jne    80107f75 <clearpteu+0x33>
    panic("clearpteu");
80107f68:	83 ec 0c             	sub    $0xc,%esp
80107f6b:	68 54 ad 10 80       	push   $0x8010ad54
80107f70:	e8 50 86 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80107f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f78:	8b 00                	mov    (%eax),%eax
80107f7a:	83 e0 fb             	and    $0xfffffffb,%eax
80107f7d:	89 c2                	mov    %eax,%edx
80107f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f82:	89 10                	mov    %edx,(%eax)
}
80107f84:	90                   	nop
80107f85:	c9                   	leave  
80107f86:	c3                   	ret    

80107f87 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107f87:	f3 0f 1e fb          	endbr32 
80107f8b:	55                   	push   %ebp
80107f8c:	89 e5                	mov    %esp,%ebp
80107f8e:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107f91:	e8 2c f9 ff ff       	call   801078c2 <setupkvm>
80107f96:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f9d:	75 0a                	jne    80107fa9 <copyuvm+0x22>
    return 0;
80107f9f:	b8 00 00 00 00       	mov    $0x0,%eax
80107fa4:	e9 eb 00 00 00       	jmp    80108094 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80107fa9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fb0:	e9 b7 00 00 00       	jmp    8010806c <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb8:	83 ec 04             	sub    $0x4,%esp
80107fbb:	6a 00                	push   $0x0
80107fbd:	50                   	push   %eax
80107fbe:	ff 75 08             	pushl  0x8(%ebp)
80107fc1:	e8 ce f7 ff ff       	call   80107794 <walkpgdir>
80107fc6:	83 c4 10             	add    $0x10,%esp
80107fc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fcc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fd0:	75 0d                	jne    80107fdf <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80107fd2:	83 ec 0c             	sub    $0xc,%esp
80107fd5:	68 5e ad 10 80       	push   $0x8010ad5e
80107fda:	e8 e6 85 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
80107fdf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fe2:	8b 00                	mov    (%eax),%eax
80107fe4:	83 e0 01             	and    $0x1,%eax
80107fe7:	85 c0                	test   %eax,%eax
80107fe9:	75 0d                	jne    80107ff8 <copyuvm+0x71>
      panic("copyuvm: page not present");
80107feb:	83 ec 0c             	sub    $0xc,%esp
80107fee:	68 78 ad 10 80       	push   $0x8010ad78
80107ff3:	e8 cd 85 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107ff8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ffb:	8b 00                	mov    (%eax),%eax
80107ffd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108002:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108005:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108008:	8b 00                	mov    (%eax),%eax
8010800a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010800f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108012:	e8 7b a8 ff ff       	call   80102892 <kalloc>
80108017:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010801a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010801e:	74 5d                	je     8010807d <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108020:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108023:	05 00 00 00 80       	add    $0x80000000,%eax
80108028:	83 ec 04             	sub    $0x4,%esp
8010802b:	68 00 10 00 00       	push   $0x1000
80108030:	50                   	push   %eax
80108031:	ff 75 e0             	pushl  -0x20(%ebp)
80108034:	e8 a9 ce ff ff       	call   80104ee2 <memmove>
80108039:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010803c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010803f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108042:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804b:	83 ec 0c             	sub    $0xc,%esp
8010804e:	52                   	push   %edx
8010804f:	51                   	push   %ecx
80108050:	68 00 10 00 00       	push   $0x1000
80108055:	50                   	push   %eax
80108056:	ff 75 f0             	pushl  -0x10(%ebp)
80108059:	e8 d0 f7 ff ff       	call   8010782e <mappages>
8010805e:	83 c4 20             	add    $0x20,%esp
80108061:	85 c0                	test   %eax,%eax
80108063:	78 1b                	js     80108080 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80108065:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010806c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108072:	0f 82 3d ff ff ff    	jb     80107fb5 <copyuvm+0x2e>
      goto bad;
  }
  return d;
80108078:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010807b:	eb 17                	jmp    80108094 <copyuvm+0x10d>
      goto bad;
8010807d:	90                   	nop
8010807e:	eb 01                	jmp    80108081 <copyuvm+0xfa>
      goto bad;
80108080:	90                   	nop

bad:
  freevm(d);
80108081:	83 ec 0c             	sub    $0xc,%esp
80108084:	ff 75 f0             	pushl  -0x10(%ebp)
80108087:	e8 19 fe ff ff       	call   80107ea5 <freevm>
8010808c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010808f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108094:	c9                   	leave  
80108095:	c3                   	ret    

80108096 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108096:	f3 0f 1e fb          	endbr32 
8010809a:	55                   	push   %ebp
8010809b:	89 e5                	mov    %esp,%ebp
8010809d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801080a0:	83 ec 04             	sub    $0x4,%esp
801080a3:	6a 00                	push   $0x0
801080a5:	ff 75 0c             	pushl  0xc(%ebp)
801080a8:	ff 75 08             	pushl  0x8(%ebp)
801080ab:	e8 e4 f6 ff ff       	call   80107794 <walkpgdir>
801080b0:	83 c4 10             	add    $0x10,%esp
801080b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801080b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b9:	8b 00                	mov    (%eax),%eax
801080bb:	83 e0 01             	and    $0x1,%eax
801080be:	85 c0                	test   %eax,%eax
801080c0:	75 07                	jne    801080c9 <uva2ka+0x33>
    return 0;
801080c2:	b8 00 00 00 00       	mov    $0x0,%eax
801080c7:	eb 22                	jmp    801080eb <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
801080c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cc:	8b 00                	mov    (%eax),%eax
801080ce:	83 e0 04             	and    $0x4,%eax
801080d1:	85 c0                	test   %eax,%eax
801080d3:	75 07                	jne    801080dc <uva2ka+0x46>
    return 0;
801080d5:	b8 00 00 00 00       	mov    $0x0,%eax
801080da:	eb 0f                	jmp    801080eb <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
801080dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080df:	8b 00                	mov    (%eax),%eax
801080e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080e6:	05 00 00 00 80       	add    $0x80000000,%eax
}
801080eb:	c9                   	leave  
801080ec:	c3                   	ret    

801080ed <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801080ed:	f3 0f 1e fb          	endbr32 
801080f1:	55                   	push   %ebp
801080f2:	89 e5                	mov    %esp,%ebp
801080f4:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801080f7:	8b 45 10             	mov    0x10(%ebp),%eax
801080fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801080fd:	eb 7f                	jmp    8010817e <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801080ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80108102:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108107:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010810a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010810d:	83 ec 08             	sub    $0x8,%esp
80108110:	50                   	push   %eax
80108111:	ff 75 08             	pushl  0x8(%ebp)
80108114:	e8 7d ff ff ff       	call   80108096 <uva2ka>
80108119:	83 c4 10             	add    $0x10,%esp
8010811c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010811f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108123:	75 07                	jne    8010812c <copyout+0x3f>
      return -1;
80108125:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010812a:	eb 61                	jmp    8010818d <copyout+0xa0>
    n = PGSIZE - (va - va0);
8010812c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010812f:	2b 45 0c             	sub    0xc(%ebp),%eax
80108132:	05 00 10 00 00       	add    $0x1000,%eax
80108137:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010813a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010813d:	3b 45 14             	cmp    0x14(%ebp),%eax
80108140:	76 06                	jbe    80108148 <copyout+0x5b>
      n = len;
80108142:	8b 45 14             	mov    0x14(%ebp),%eax
80108145:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108148:	8b 45 0c             	mov    0xc(%ebp),%eax
8010814b:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010814e:	89 c2                	mov    %eax,%edx
80108150:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108153:	01 d0                	add    %edx,%eax
80108155:	83 ec 04             	sub    $0x4,%esp
80108158:	ff 75 f0             	pushl  -0x10(%ebp)
8010815b:	ff 75 f4             	pushl  -0xc(%ebp)
8010815e:	50                   	push   %eax
8010815f:	e8 7e cd ff ff       	call   80104ee2 <memmove>
80108164:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108167:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010816a:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010816d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108170:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108173:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108176:	05 00 10 00 00       	add    $0x1000,%eax
8010817b:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010817e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108182:	0f 85 77 ff ff ff    	jne    801080ff <copyout+0x12>
  }
  return 0;
80108188:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010818d:	c9                   	leave  
8010818e:	c3                   	ret    

8010818f <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010818f:	f3 0f 1e fb          	endbr32 
80108193:	55                   	push   %ebp
80108194:	89 e5                	mov    %esp,%ebp
80108196:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108199:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801081a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801081a3:	8b 40 08             	mov    0x8(%eax),%eax
801081a6:	05 00 00 00 80       	add    $0x80000000,%eax
801081ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801081ae:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801081b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b8:	8b 40 24             	mov    0x24(%eax),%eax
801081bb:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
801081c0:	c7 05 80 81 19 80 00 	movl   $0x0,0x80198180
801081c7:	00 00 00 

  while(i<madt->len){
801081ca:	90                   	nop
801081cb:	e9 be 00 00 00       	jmp    8010828e <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
801081d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801081d6:	01 d0                	add    %edx,%eax
801081d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801081db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081de:	0f b6 00             	movzbl (%eax),%eax
801081e1:	0f b6 c0             	movzbl %al,%eax
801081e4:	83 f8 05             	cmp    $0x5,%eax
801081e7:	0f 87 a1 00 00 00    	ja     8010828e <mpinit_uefi+0xff>
801081ed:	8b 04 85 94 ad 10 80 	mov    -0x7fef526c(,%eax,4),%eax
801081f4:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801081f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801081fd:	a1 80 81 19 80       	mov    0x80198180,%eax
80108202:	83 f8 03             	cmp    $0x3,%eax
80108205:	7f 28                	jg     8010822f <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108207:	8b 15 80 81 19 80    	mov    0x80198180,%edx
8010820d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108210:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108214:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010821a:	81 c2 c0 7e 19 80    	add    $0x80197ec0,%edx
80108220:	88 02                	mov    %al,(%edx)
          ncpu++;
80108222:	a1 80 81 19 80       	mov    0x80198180,%eax
80108227:	83 c0 01             	add    $0x1,%eax
8010822a:	a3 80 81 19 80       	mov    %eax,0x80198180
        }
        i += lapic_entry->record_len;
8010822f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108232:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108236:	0f b6 c0             	movzbl %al,%eax
80108239:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010823c:	eb 50                	jmp    8010828e <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
8010823e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108241:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108244:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108247:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010824b:	a2 a0 7e 19 80       	mov    %al,0x80197ea0
        i += ioapic->record_len;
80108250:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108253:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108257:	0f b6 c0             	movzbl %al,%eax
8010825a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010825d:	eb 2f                	jmp    8010828e <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
8010825f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108262:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108265:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108268:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010826c:	0f b6 c0             	movzbl %al,%eax
8010826f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108272:	eb 1a                	jmp    8010828e <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108274:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108277:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010827a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010827d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108281:	0f b6 c0             	movzbl %al,%eax
80108284:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108287:	eb 05                	jmp    8010828e <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
80108289:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010828d:	90                   	nop
  while(i<madt->len){
8010828e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108291:	8b 40 04             	mov    0x4(%eax),%eax
80108294:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108297:	0f 82 33 ff ff ff    	jb     801081d0 <mpinit_uefi+0x41>
    }
  }

}
8010829d:	90                   	nop
8010829e:	90                   	nop
8010829f:	c9                   	leave  
801082a0:	c3                   	ret    

801082a1 <inb>:
{
801082a1:	55                   	push   %ebp
801082a2:	89 e5                	mov    %esp,%ebp
801082a4:	83 ec 14             	sub    $0x14,%esp
801082a7:	8b 45 08             	mov    0x8(%ebp),%eax
801082aa:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801082ae:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801082b2:	89 c2                	mov    %eax,%edx
801082b4:	ec                   	in     (%dx),%al
801082b5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801082b8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801082bc:	c9                   	leave  
801082bd:	c3                   	ret    

801082be <outb>:
{
801082be:	55                   	push   %ebp
801082bf:	89 e5                	mov    %esp,%ebp
801082c1:	83 ec 08             	sub    $0x8,%esp
801082c4:	8b 45 08             	mov    0x8(%ebp),%eax
801082c7:	8b 55 0c             	mov    0xc(%ebp),%edx
801082ca:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801082ce:	89 d0                	mov    %edx,%eax
801082d0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801082d3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801082d7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801082db:	ee                   	out    %al,(%dx)
}
801082dc:	90                   	nop
801082dd:	c9                   	leave  
801082de:	c3                   	ret    

801082df <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801082df:	f3 0f 1e fb          	endbr32 
801082e3:	55                   	push   %ebp
801082e4:	89 e5                	mov    %esp,%ebp
801082e6:	83 ec 28             	sub    $0x28,%esp
801082e9:	8b 45 08             	mov    0x8(%ebp),%eax
801082ec:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801082ef:	6a 00                	push   $0x0
801082f1:	68 fa 03 00 00       	push   $0x3fa
801082f6:	e8 c3 ff ff ff       	call   801082be <outb>
801082fb:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801082fe:	68 80 00 00 00       	push   $0x80
80108303:	68 fb 03 00 00       	push   $0x3fb
80108308:	e8 b1 ff ff ff       	call   801082be <outb>
8010830d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108310:	6a 0c                	push   $0xc
80108312:	68 f8 03 00 00       	push   $0x3f8
80108317:	e8 a2 ff ff ff       	call   801082be <outb>
8010831c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010831f:	6a 00                	push   $0x0
80108321:	68 f9 03 00 00       	push   $0x3f9
80108326:	e8 93 ff ff ff       	call   801082be <outb>
8010832b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010832e:	6a 03                	push   $0x3
80108330:	68 fb 03 00 00       	push   $0x3fb
80108335:	e8 84 ff ff ff       	call   801082be <outb>
8010833a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010833d:	6a 00                	push   $0x0
8010833f:	68 fc 03 00 00       	push   $0x3fc
80108344:	e8 75 ff ff ff       	call   801082be <outb>
80108349:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010834c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108353:	eb 11                	jmp    80108366 <uart_debug+0x87>
80108355:	83 ec 0c             	sub    $0xc,%esp
80108358:	6a 0a                	push   $0xa
8010835a:	e8 e5 a8 ff ff       	call   80102c44 <microdelay>
8010835f:	83 c4 10             	add    $0x10,%esp
80108362:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108366:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010836a:	7f 1a                	jg     80108386 <uart_debug+0xa7>
8010836c:	83 ec 0c             	sub    $0xc,%esp
8010836f:	68 fd 03 00 00       	push   $0x3fd
80108374:	e8 28 ff ff ff       	call   801082a1 <inb>
80108379:	83 c4 10             	add    $0x10,%esp
8010837c:	0f b6 c0             	movzbl %al,%eax
8010837f:	83 e0 20             	and    $0x20,%eax
80108382:	85 c0                	test   %eax,%eax
80108384:	74 cf                	je     80108355 <uart_debug+0x76>
  outb(COM1+0, p);
80108386:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010838a:	0f b6 c0             	movzbl %al,%eax
8010838d:	83 ec 08             	sub    $0x8,%esp
80108390:	50                   	push   %eax
80108391:	68 f8 03 00 00       	push   $0x3f8
80108396:	e8 23 ff ff ff       	call   801082be <outb>
8010839b:	83 c4 10             	add    $0x10,%esp
}
8010839e:	90                   	nop
8010839f:	c9                   	leave  
801083a0:	c3                   	ret    

801083a1 <uart_debugs>:

void uart_debugs(char *p){
801083a1:	f3 0f 1e fb          	endbr32 
801083a5:	55                   	push   %ebp
801083a6:	89 e5                	mov    %esp,%ebp
801083a8:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801083ab:	eb 1b                	jmp    801083c8 <uart_debugs+0x27>
    uart_debug(*p++);
801083ad:	8b 45 08             	mov    0x8(%ebp),%eax
801083b0:	8d 50 01             	lea    0x1(%eax),%edx
801083b3:	89 55 08             	mov    %edx,0x8(%ebp)
801083b6:	0f b6 00             	movzbl (%eax),%eax
801083b9:	0f be c0             	movsbl %al,%eax
801083bc:	83 ec 0c             	sub    $0xc,%esp
801083bf:	50                   	push   %eax
801083c0:	e8 1a ff ff ff       	call   801082df <uart_debug>
801083c5:	83 c4 10             	add    $0x10,%esp
  while(*p){
801083c8:	8b 45 08             	mov    0x8(%ebp),%eax
801083cb:	0f b6 00             	movzbl (%eax),%eax
801083ce:	84 c0                	test   %al,%al
801083d0:	75 db                	jne    801083ad <uart_debugs+0xc>
  }
}
801083d2:	90                   	nop
801083d3:	90                   	nop
801083d4:	c9                   	leave  
801083d5:	c3                   	ret    

801083d6 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801083d6:	f3 0f 1e fb          	endbr32 
801083da:	55                   	push   %ebp
801083db:	89 e5                	mov    %esp,%ebp
801083dd:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801083e0:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801083e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083ea:	8b 50 14             	mov    0x14(%eax),%edx
801083ed:	8b 40 10             	mov    0x10(%eax),%eax
801083f0:	a3 84 81 19 80       	mov    %eax,0x80198184
  gpu.vram_size = boot_param->graphic_config.frame_size;
801083f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083f8:	8b 50 1c             	mov    0x1c(%eax),%edx
801083fb:	8b 40 18             	mov    0x18(%eax),%eax
801083fe:	a3 8c 81 19 80       	mov    %eax,0x8019818c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108403:	a1 8c 81 19 80       	mov    0x8019818c,%eax
80108408:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
8010840d:	29 c2                	sub    %eax,%edx
8010840f:	89 d0                	mov    %edx,%eax
80108411:	a3 88 81 19 80       	mov    %eax,0x80198188
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108416:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108419:	8b 50 24             	mov    0x24(%eax),%edx
8010841c:	8b 40 20             	mov    0x20(%eax),%eax
8010841f:	a3 90 81 19 80       	mov    %eax,0x80198190
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108424:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108427:	8b 50 2c             	mov    0x2c(%eax),%edx
8010842a:	8b 40 28             	mov    0x28(%eax),%eax
8010842d:	a3 94 81 19 80       	mov    %eax,0x80198194
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108432:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108435:	8b 50 34             	mov    0x34(%eax),%edx
80108438:	8b 40 30             	mov    0x30(%eax),%eax
8010843b:	a3 98 81 19 80       	mov    %eax,0x80198198
}
80108440:	90                   	nop
80108441:	c9                   	leave  
80108442:	c3                   	ret    

80108443 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108443:	f3 0f 1e fb          	endbr32 
80108447:	55                   	push   %ebp
80108448:	89 e5                	mov    %esp,%ebp
8010844a:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
8010844d:	8b 15 98 81 19 80    	mov    0x80198198,%edx
80108453:	8b 45 0c             	mov    0xc(%ebp),%eax
80108456:	0f af d0             	imul   %eax,%edx
80108459:	8b 45 08             	mov    0x8(%ebp),%eax
8010845c:	01 d0                	add    %edx,%eax
8010845e:	c1 e0 02             	shl    $0x2,%eax
80108461:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108464:	8b 15 88 81 19 80    	mov    0x80198188,%edx
8010846a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010846d:	01 d0                	add    %edx,%eax
8010846f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108472:	8b 45 10             	mov    0x10(%ebp),%eax
80108475:	0f b6 10             	movzbl (%eax),%edx
80108478:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010847b:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010847d:	8b 45 10             	mov    0x10(%ebp),%eax
80108480:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108484:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108487:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010848a:	8b 45 10             	mov    0x10(%ebp),%eax
8010848d:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108491:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108494:	88 50 02             	mov    %dl,0x2(%eax)
}
80108497:	90                   	nop
80108498:	c9                   	leave  
80108499:	c3                   	ret    

8010849a <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010849a:	f3 0f 1e fb          	endbr32 
8010849e:	55                   	push   %ebp
8010849f:	89 e5                	mov    %esp,%ebp
801084a1:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801084a4:	8b 15 98 81 19 80    	mov    0x80198198,%edx
801084aa:	8b 45 08             	mov    0x8(%ebp),%eax
801084ad:	0f af c2             	imul   %edx,%eax
801084b0:	c1 e0 02             	shl    $0x2,%eax
801084b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801084b6:	8b 15 8c 81 19 80    	mov    0x8019818c,%edx
801084bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bf:	29 c2                	sub    %eax,%edx
801084c1:	89 d0                	mov    %edx,%eax
801084c3:	8b 0d 88 81 19 80    	mov    0x80198188,%ecx
801084c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084cc:	01 ca                	add    %ecx,%edx
801084ce:	89 d1                	mov    %edx,%ecx
801084d0:	8b 15 88 81 19 80    	mov    0x80198188,%edx
801084d6:	83 ec 04             	sub    $0x4,%esp
801084d9:	50                   	push   %eax
801084da:	51                   	push   %ecx
801084db:	52                   	push   %edx
801084dc:	e8 01 ca ff ff       	call   80104ee2 <memmove>
801084e1:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801084e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e7:	8b 0d 88 81 19 80    	mov    0x80198188,%ecx
801084ed:	8b 15 8c 81 19 80    	mov    0x8019818c,%edx
801084f3:	01 d1                	add    %edx,%ecx
801084f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084f8:	29 d1                	sub    %edx,%ecx
801084fa:	89 ca                	mov    %ecx,%edx
801084fc:	83 ec 04             	sub    $0x4,%esp
801084ff:	50                   	push   %eax
80108500:	6a 00                	push   $0x0
80108502:	52                   	push   %edx
80108503:	e8 13 c9 ff ff       	call   80104e1b <memset>
80108508:	83 c4 10             	add    $0x10,%esp
}
8010850b:	90                   	nop
8010850c:	c9                   	leave  
8010850d:	c3                   	ret    

8010850e <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010850e:	f3 0f 1e fb          	endbr32 
80108512:	55                   	push   %ebp
80108513:	89 e5                	mov    %esp,%ebp
80108515:	53                   	push   %ebx
80108516:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108519:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108520:	e9 b1 00 00 00       	jmp    801085d6 <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108525:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
8010852c:	e9 97 00 00 00       	jmp    801085c8 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108531:	8b 45 10             	mov    0x10(%ebp),%eax
80108534:	83 e8 20             	sub    $0x20,%eax
80108537:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010853a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853d:	01 d0                	add    %edx,%eax
8010853f:	0f b7 84 00 c0 ad 10 	movzwl -0x7fef5240(%eax,%eax,1),%eax
80108546:	80 
80108547:	0f b7 d0             	movzwl %ax,%edx
8010854a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010854d:	bb 01 00 00 00       	mov    $0x1,%ebx
80108552:	89 c1                	mov    %eax,%ecx
80108554:	d3 e3                	shl    %cl,%ebx
80108556:	89 d8                	mov    %ebx,%eax
80108558:	21 d0                	and    %edx,%eax
8010855a:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010855d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108560:	ba 01 00 00 00       	mov    $0x1,%edx
80108565:	89 c1                	mov    %eax,%ecx
80108567:	d3 e2                	shl    %cl,%edx
80108569:	89 d0                	mov    %edx,%eax
8010856b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010856e:	75 2b                	jne    8010859b <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108570:	8b 55 0c             	mov    0xc(%ebp),%edx
80108573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108576:	01 c2                	add    %eax,%edx
80108578:	b8 0e 00 00 00       	mov    $0xe,%eax
8010857d:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108580:	89 c1                	mov    %eax,%ecx
80108582:	8b 45 08             	mov    0x8(%ebp),%eax
80108585:	01 c8                	add    %ecx,%eax
80108587:	83 ec 04             	sub    $0x4,%esp
8010858a:	68 00 f5 10 80       	push   $0x8010f500
8010858f:	52                   	push   %edx
80108590:	50                   	push   %eax
80108591:	e8 ad fe ff ff       	call   80108443 <graphic_draw_pixel>
80108596:	83 c4 10             	add    $0x10,%esp
80108599:	eb 29                	jmp    801085c4 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010859b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010859e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a1:	01 c2                	add    %eax,%edx
801085a3:	b8 0e 00 00 00       	mov    $0xe,%eax
801085a8:	2b 45 f0             	sub    -0x10(%ebp),%eax
801085ab:	89 c1                	mov    %eax,%ecx
801085ad:	8b 45 08             	mov    0x8(%ebp),%eax
801085b0:	01 c8                	add    %ecx,%eax
801085b2:	83 ec 04             	sub    $0x4,%esp
801085b5:	68 64 d0 18 80       	push   $0x8018d064
801085ba:	52                   	push   %edx
801085bb:	50                   	push   %eax
801085bc:	e8 82 fe ff ff       	call   80108443 <graphic_draw_pixel>
801085c1:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801085c4:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801085c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085cc:	0f 89 5f ff ff ff    	jns    80108531 <font_render+0x23>
  for(int i=0;i<30;i++){
801085d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085d6:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801085da:	0f 8e 45 ff ff ff    	jle    80108525 <font_render+0x17>
      }
    }
  }
}
801085e0:	90                   	nop
801085e1:	90                   	nop
801085e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085e5:	c9                   	leave  
801085e6:	c3                   	ret    

801085e7 <font_render_string>:

void font_render_string(char *string,int row){
801085e7:	f3 0f 1e fb          	endbr32 
801085eb:	55                   	push   %ebp
801085ec:	89 e5                	mov    %esp,%ebp
801085ee:	53                   	push   %ebx
801085ef:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801085f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801085f9:	eb 33                	jmp    8010862e <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
801085fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108601:	01 d0                	add    %edx,%eax
80108603:	0f b6 00             	movzbl (%eax),%eax
80108606:	0f be d8             	movsbl %al,%ebx
80108609:	8b 45 0c             	mov    0xc(%ebp),%eax
8010860c:	6b c8 1e             	imul   $0x1e,%eax,%ecx
8010860f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108612:	89 d0                	mov    %edx,%eax
80108614:	c1 e0 04             	shl    $0x4,%eax
80108617:	29 d0                	sub    %edx,%eax
80108619:	83 c0 02             	add    $0x2,%eax
8010861c:	83 ec 04             	sub    $0x4,%esp
8010861f:	53                   	push   %ebx
80108620:	51                   	push   %ecx
80108621:	50                   	push   %eax
80108622:	e8 e7 fe ff ff       	call   8010850e <font_render>
80108627:	83 c4 10             	add    $0x10,%esp
    i++;
8010862a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
8010862e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108631:	8b 45 08             	mov    0x8(%ebp),%eax
80108634:	01 d0                	add    %edx,%eax
80108636:	0f b6 00             	movzbl (%eax),%eax
80108639:	84 c0                	test   %al,%al
8010863b:	74 06                	je     80108643 <font_render_string+0x5c>
8010863d:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108641:	7e b8                	jle    801085fb <font_render_string+0x14>
  }
}
80108643:	90                   	nop
80108644:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108647:	c9                   	leave  
80108648:	c3                   	ret    

80108649 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108649:	f3 0f 1e fb          	endbr32 
8010864d:	55                   	push   %ebp
8010864e:	89 e5                	mov    %esp,%ebp
80108650:	53                   	push   %ebx
80108651:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108654:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010865b:	eb 6b                	jmp    801086c8 <pci_init+0x7f>
    for(int j=0;j<32;j++){
8010865d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108664:	eb 58                	jmp    801086be <pci_init+0x75>
      for(int k=0;k<8;k++){
80108666:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010866d:	eb 45                	jmp    801086b4 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
8010866f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108672:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108678:	83 ec 0c             	sub    $0xc,%esp
8010867b:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010867e:	53                   	push   %ebx
8010867f:	6a 00                	push   $0x0
80108681:	51                   	push   %ecx
80108682:	52                   	push   %edx
80108683:	50                   	push   %eax
80108684:	e8 c0 00 00 00       	call   80108749 <pci_access_config>
80108689:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010868c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010868f:	0f b7 c0             	movzwl %ax,%eax
80108692:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108697:	74 17                	je     801086b0 <pci_init+0x67>
        pci_init_device(i,j,k);
80108699:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010869c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010869f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a2:	83 ec 04             	sub    $0x4,%esp
801086a5:	51                   	push   %ecx
801086a6:	52                   	push   %edx
801086a7:	50                   	push   %eax
801086a8:	e8 4f 01 00 00       	call   801087fc <pci_init_device>
801086ad:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801086b0:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801086b4:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801086b8:	7e b5                	jle    8010866f <pci_init+0x26>
    for(int j=0;j<32;j++){
801086ba:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801086be:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801086c2:	7e a2                	jle    80108666 <pci_init+0x1d>
  for(int i=0;i<256;i++){
801086c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801086c8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801086cf:	7e 8c                	jle    8010865d <pci_init+0x14>
      }
      }
    }
  }
}
801086d1:	90                   	nop
801086d2:	90                   	nop
801086d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086d6:	c9                   	leave  
801086d7:	c3                   	ret    

801086d8 <pci_write_config>:

void pci_write_config(uint config){
801086d8:	f3 0f 1e fb          	endbr32 
801086dc:	55                   	push   %ebp
801086dd:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801086df:	8b 45 08             	mov    0x8(%ebp),%eax
801086e2:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801086e7:	89 c0                	mov    %eax,%eax
801086e9:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801086ea:	90                   	nop
801086eb:	5d                   	pop    %ebp
801086ec:	c3                   	ret    

801086ed <pci_write_data>:

void pci_write_data(uint config){
801086ed:	f3 0f 1e fb          	endbr32 
801086f1:	55                   	push   %ebp
801086f2:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801086f4:	8b 45 08             	mov    0x8(%ebp),%eax
801086f7:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801086fc:	89 c0                	mov    %eax,%eax
801086fe:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801086ff:	90                   	nop
80108700:	5d                   	pop    %ebp
80108701:	c3                   	ret    

80108702 <pci_read_config>:
uint pci_read_config(){
80108702:	f3 0f 1e fb          	endbr32 
80108706:	55                   	push   %ebp
80108707:	89 e5                	mov    %esp,%ebp
80108709:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010870c:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108711:	ed                   	in     (%dx),%eax
80108712:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108715:	83 ec 0c             	sub    $0xc,%esp
80108718:	68 c8 00 00 00       	push   $0xc8
8010871d:	e8 22 a5 ff ff       	call   80102c44 <microdelay>
80108722:	83 c4 10             	add    $0x10,%esp
  return data;
80108725:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108728:	c9                   	leave  
80108729:	c3                   	ret    

8010872a <pci_test>:


void pci_test(){
8010872a:	f3 0f 1e fb          	endbr32 
8010872e:	55                   	push   %ebp
8010872f:	89 e5                	mov    %esp,%ebp
80108731:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108734:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010873b:	ff 75 fc             	pushl  -0x4(%ebp)
8010873e:	e8 95 ff ff ff       	call   801086d8 <pci_write_config>
80108743:	83 c4 04             	add    $0x4,%esp
}
80108746:	90                   	nop
80108747:	c9                   	leave  
80108748:	c3                   	ret    

80108749 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108749:	f3 0f 1e fb          	endbr32 
8010874d:	55                   	push   %ebp
8010874e:	89 e5                	mov    %esp,%ebp
80108750:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108753:	8b 45 08             	mov    0x8(%ebp),%eax
80108756:	c1 e0 10             	shl    $0x10,%eax
80108759:	25 00 00 ff 00       	and    $0xff0000,%eax
8010875e:	89 c2                	mov    %eax,%edx
80108760:	8b 45 0c             	mov    0xc(%ebp),%eax
80108763:	c1 e0 0b             	shl    $0xb,%eax
80108766:	0f b7 c0             	movzwl %ax,%eax
80108769:	09 c2                	or     %eax,%edx
8010876b:	8b 45 10             	mov    0x10(%ebp),%eax
8010876e:	c1 e0 08             	shl    $0x8,%eax
80108771:	25 00 07 00 00       	and    $0x700,%eax
80108776:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108778:	8b 45 14             	mov    0x14(%ebp),%eax
8010877b:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108780:	09 d0                	or     %edx,%eax
80108782:	0d 00 00 00 80       	or     $0x80000000,%eax
80108787:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010878a:	ff 75 f4             	pushl  -0xc(%ebp)
8010878d:	e8 46 ff ff ff       	call   801086d8 <pci_write_config>
80108792:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108795:	e8 68 ff ff ff       	call   80108702 <pci_read_config>
8010879a:	8b 55 18             	mov    0x18(%ebp),%edx
8010879d:	89 02                	mov    %eax,(%edx)
}
8010879f:	90                   	nop
801087a0:	c9                   	leave  
801087a1:	c3                   	ret    

801087a2 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
801087a2:	f3 0f 1e fb          	endbr32 
801087a6:	55                   	push   %ebp
801087a7:	89 e5                	mov    %esp,%ebp
801087a9:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087ac:	8b 45 08             	mov    0x8(%ebp),%eax
801087af:	c1 e0 10             	shl    $0x10,%eax
801087b2:	25 00 00 ff 00       	and    $0xff0000,%eax
801087b7:	89 c2                	mov    %eax,%edx
801087b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801087bc:	c1 e0 0b             	shl    $0xb,%eax
801087bf:	0f b7 c0             	movzwl %ax,%eax
801087c2:	09 c2                	or     %eax,%edx
801087c4:	8b 45 10             	mov    0x10(%ebp),%eax
801087c7:	c1 e0 08             	shl    $0x8,%eax
801087ca:	25 00 07 00 00       	and    $0x700,%eax
801087cf:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801087d1:	8b 45 14             	mov    0x14(%ebp),%eax
801087d4:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801087d9:	09 d0                	or     %edx,%eax
801087db:	0d 00 00 00 80       	or     $0x80000000,%eax
801087e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801087e3:	ff 75 fc             	pushl  -0x4(%ebp)
801087e6:	e8 ed fe ff ff       	call   801086d8 <pci_write_config>
801087eb:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801087ee:	ff 75 18             	pushl  0x18(%ebp)
801087f1:	e8 f7 fe ff ff       	call   801086ed <pci_write_data>
801087f6:	83 c4 04             	add    $0x4,%esp
}
801087f9:	90                   	nop
801087fa:	c9                   	leave  
801087fb:	c3                   	ret    

801087fc <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801087fc:	f3 0f 1e fb          	endbr32 
80108800:	55                   	push   %ebp
80108801:	89 e5                	mov    %esp,%ebp
80108803:	53                   	push   %ebx
80108804:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108807:	8b 45 08             	mov    0x8(%ebp),%eax
8010880a:	a2 9c 81 19 80       	mov    %al,0x8019819c
  dev.device_num = device_num;
8010880f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108812:	a2 9d 81 19 80       	mov    %al,0x8019819d
  dev.function_num = function_num;
80108817:	8b 45 10             	mov    0x10(%ebp),%eax
8010881a:	a2 9e 81 19 80       	mov    %al,0x8019819e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
8010881f:	ff 75 10             	pushl  0x10(%ebp)
80108822:	ff 75 0c             	pushl  0xc(%ebp)
80108825:	ff 75 08             	pushl  0x8(%ebp)
80108828:	68 04 c4 10 80       	push   $0x8010c404
8010882d:	e8 da 7b ff ff       	call   8010040c <cprintf>
80108832:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108835:	83 ec 0c             	sub    $0xc,%esp
80108838:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010883b:	50                   	push   %eax
8010883c:	6a 00                	push   $0x0
8010883e:	ff 75 10             	pushl  0x10(%ebp)
80108841:	ff 75 0c             	pushl  0xc(%ebp)
80108844:	ff 75 08             	pushl  0x8(%ebp)
80108847:	e8 fd fe ff ff       	call   80108749 <pci_access_config>
8010884c:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
8010884f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108852:	c1 e8 10             	shr    $0x10,%eax
80108855:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108858:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010885b:	25 ff ff 00 00       	and    $0xffff,%eax
80108860:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108866:	a3 a0 81 19 80       	mov    %eax,0x801981a0
  dev.vendor_id = vendor_id;
8010886b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010886e:	a3 a4 81 19 80       	mov    %eax,0x801981a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108873:	83 ec 04             	sub    $0x4,%esp
80108876:	ff 75 f0             	pushl  -0x10(%ebp)
80108879:	ff 75 f4             	pushl  -0xc(%ebp)
8010887c:	68 38 c4 10 80       	push   $0x8010c438
80108881:	e8 86 7b ff ff       	call   8010040c <cprintf>
80108886:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108889:	83 ec 0c             	sub    $0xc,%esp
8010888c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010888f:	50                   	push   %eax
80108890:	6a 08                	push   $0x8
80108892:	ff 75 10             	pushl  0x10(%ebp)
80108895:	ff 75 0c             	pushl  0xc(%ebp)
80108898:	ff 75 08             	pushl  0x8(%ebp)
8010889b:	e8 a9 fe ff ff       	call   80108749 <pci_access_config>
801088a0:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801088a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088a6:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801088a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ac:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801088af:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801088b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088b5:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801088b8:	0f b6 c0             	movzbl %al,%eax
801088bb:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801088be:	c1 eb 18             	shr    $0x18,%ebx
801088c1:	83 ec 0c             	sub    $0xc,%esp
801088c4:	51                   	push   %ecx
801088c5:	52                   	push   %edx
801088c6:	50                   	push   %eax
801088c7:	53                   	push   %ebx
801088c8:	68 5c c4 10 80       	push   $0x8010c45c
801088cd:	e8 3a 7b ff ff       	call   8010040c <cprintf>
801088d2:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801088d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088d8:	c1 e8 18             	shr    $0x18,%eax
801088db:	a2 a8 81 19 80       	mov    %al,0x801981a8
  dev.sub_class = (data>>16)&0xFF;
801088e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088e3:	c1 e8 10             	shr    $0x10,%eax
801088e6:	a2 a9 81 19 80       	mov    %al,0x801981a9
  dev.interface = (data>>8)&0xFF;
801088eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ee:	c1 e8 08             	shr    $0x8,%eax
801088f1:	a2 aa 81 19 80       	mov    %al,0x801981aa
  dev.revision_id = data&0xFF;
801088f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088f9:	a2 ab 81 19 80       	mov    %al,0x801981ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801088fe:	83 ec 0c             	sub    $0xc,%esp
80108901:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108904:	50                   	push   %eax
80108905:	6a 10                	push   $0x10
80108907:	ff 75 10             	pushl  0x10(%ebp)
8010890a:	ff 75 0c             	pushl  0xc(%ebp)
8010890d:	ff 75 08             	pushl  0x8(%ebp)
80108910:	e8 34 fe ff ff       	call   80108749 <pci_access_config>
80108915:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108918:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010891b:	a3 ac 81 19 80       	mov    %eax,0x801981ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108920:	83 ec 0c             	sub    $0xc,%esp
80108923:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108926:	50                   	push   %eax
80108927:	6a 14                	push   $0x14
80108929:	ff 75 10             	pushl  0x10(%ebp)
8010892c:	ff 75 0c             	pushl  0xc(%ebp)
8010892f:	ff 75 08             	pushl  0x8(%ebp)
80108932:	e8 12 fe ff ff       	call   80108749 <pci_access_config>
80108937:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010893a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010893d:	a3 b0 81 19 80       	mov    %eax,0x801981b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108942:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108949:	75 5a                	jne    801089a5 <pci_init_device+0x1a9>
8010894b:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108952:	75 51                	jne    801089a5 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108954:	83 ec 0c             	sub    $0xc,%esp
80108957:	68 a1 c4 10 80       	push   $0x8010c4a1
8010895c:	e8 ab 7a ff ff       	call   8010040c <cprintf>
80108961:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108964:	83 ec 0c             	sub    $0xc,%esp
80108967:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010896a:	50                   	push   %eax
8010896b:	68 f0 00 00 00       	push   $0xf0
80108970:	ff 75 10             	pushl  0x10(%ebp)
80108973:	ff 75 0c             	pushl  0xc(%ebp)
80108976:	ff 75 08             	pushl  0x8(%ebp)
80108979:	e8 cb fd ff ff       	call   80108749 <pci_access_config>
8010897e:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108981:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108984:	83 ec 08             	sub    $0x8,%esp
80108987:	50                   	push   %eax
80108988:	68 bb c4 10 80       	push   $0x8010c4bb
8010898d:	e8 7a 7a ff ff       	call   8010040c <cprintf>
80108992:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108995:	83 ec 0c             	sub    $0xc,%esp
80108998:	68 9c 81 19 80       	push   $0x8019819c
8010899d:	e8 09 00 00 00       	call   801089ab <i8254_init>
801089a2:	83 c4 10             	add    $0x10,%esp
  }
}
801089a5:	90                   	nop
801089a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089a9:	c9                   	leave  
801089aa:	c3                   	ret    

801089ab <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
801089ab:	f3 0f 1e fb          	endbr32 
801089af:	55                   	push   %ebp
801089b0:	89 e5                	mov    %esp,%ebp
801089b2:	53                   	push   %ebx
801089b3:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801089b6:	8b 45 08             	mov    0x8(%ebp),%eax
801089b9:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801089bd:	0f b6 c8             	movzbl %al,%ecx
801089c0:	8b 45 08             	mov    0x8(%ebp),%eax
801089c3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801089c7:	0f b6 d0             	movzbl %al,%edx
801089ca:	8b 45 08             	mov    0x8(%ebp),%eax
801089cd:	0f b6 00             	movzbl (%eax),%eax
801089d0:	0f b6 c0             	movzbl %al,%eax
801089d3:	83 ec 0c             	sub    $0xc,%esp
801089d6:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801089d9:	53                   	push   %ebx
801089da:	6a 04                	push   $0x4
801089dc:	51                   	push   %ecx
801089dd:	52                   	push   %edx
801089de:	50                   	push   %eax
801089df:	e8 65 fd ff ff       	call   80108749 <pci_access_config>
801089e4:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801089e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089ea:	83 c8 04             	or     $0x4,%eax
801089ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801089f0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801089f3:	8b 45 08             	mov    0x8(%ebp),%eax
801089f6:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801089fa:	0f b6 c8             	movzbl %al,%ecx
801089fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108a00:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108a04:	0f b6 d0             	movzbl %al,%edx
80108a07:	8b 45 08             	mov    0x8(%ebp),%eax
80108a0a:	0f b6 00             	movzbl (%eax),%eax
80108a0d:	0f b6 c0             	movzbl %al,%eax
80108a10:	83 ec 0c             	sub    $0xc,%esp
80108a13:	53                   	push   %ebx
80108a14:	6a 04                	push   $0x4
80108a16:	51                   	push   %ecx
80108a17:	52                   	push   %edx
80108a18:	50                   	push   %eax
80108a19:	e8 84 fd ff ff       	call   801087a2 <pci_write_config_register>
80108a1e:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108a21:	8b 45 08             	mov    0x8(%ebp),%eax
80108a24:	8b 40 10             	mov    0x10(%eax),%eax
80108a27:	05 00 00 00 40       	add    $0x40000000,%eax
80108a2c:	a3 b4 81 19 80       	mov    %eax,0x801981b4
  uint *ctrl = (uint *)base_addr;
80108a31:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108a36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108a39:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108a3e:	05 d8 00 00 00       	add    $0xd8,%eax
80108a43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a49:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a52:	8b 00                	mov    (%eax),%eax
80108a54:	0d 00 00 00 04       	or     $0x4000000,%eax
80108a59:	89 c2                	mov    %eax,%edx
80108a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5e:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a63:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6c:	8b 00                	mov    (%eax),%eax
80108a6e:	83 c8 40             	or     $0x40,%eax
80108a71:	89 c2                	mov    %eax,%edx
80108a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a76:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7b:	8b 10                	mov    (%eax),%edx
80108a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a80:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108a82:	83 ec 0c             	sub    $0xc,%esp
80108a85:	68 d0 c4 10 80       	push   $0x8010c4d0
80108a8a:	e8 7d 79 ff ff       	call   8010040c <cprintf>
80108a8f:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108a92:	e8 fb 9d ff ff       	call   80102892 <kalloc>
80108a97:	a3 b8 81 19 80       	mov    %eax,0x801981b8
  *intr_addr = 0;
80108a9c:	a1 b8 81 19 80       	mov    0x801981b8,%eax
80108aa1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108aa7:	a1 b8 81 19 80       	mov    0x801981b8,%eax
80108aac:	83 ec 08             	sub    $0x8,%esp
80108aaf:	50                   	push   %eax
80108ab0:	68 f2 c4 10 80       	push   $0x8010c4f2
80108ab5:	e8 52 79 ff ff       	call   8010040c <cprintf>
80108aba:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108abd:	e8 50 00 00 00       	call   80108b12 <i8254_init_recv>
  i8254_init_send();
80108ac2:	e8 6d 03 00 00       	call   80108e34 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108ac7:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ace:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108ad1:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ad8:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108adb:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ae2:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108ae5:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108aec:	0f b6 c0             	movzbl %al,%eax
80108aef:	83 ec 0c             	sub    $0xc,%esp
80108af2:	53                   	push   %ebx
80108af3:	51                   	push   %ecx
80108af4:	52                   	push   %edx
80108af5:	50                   	push   %eax
80108af6:	68 00 c5 10 80       	push   $0x8010c500
80108afb:	e8 0c 79 ff ff       	call   8010040c <cprintf>
80108b00:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b06:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108b0c:	90                   	nop
80108b0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b10:	c9                   	leave  
80108b11:	c3                   	ret    

80108b12 <i8254_init_recv>:

void i8254_init_recv(){
80108b12:	f3 0f 1e fb          	endbr32 
80108b16:	55                   	push   %ebp
80108b17:	89 e5                	mov    %esp,%ebp
80108b19:	57                   	push   %edi
80108b1a:	56                   	push   %esi
80108b1b:	53                   	push   %ebx
80108b1c:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108b1f:	83 ec 0c             	sub    $0xc,%esp
80108b22:	6a 00                	push   $0x0
80108b24:	e8 ec 04 00 00       	call   80109015 <i8254_read_eeprom>
80108b29:	83 c4 10             	add    $0x10,%esp
80108b2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108b2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108b32:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108b37:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108b3a:	c1 e8 08             	shr    $0x8,%eax
80108b3d:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108b42:	83 ec 0c             	sub    $0xc,%esp
80108b45:	6a 01                	push   $0x1
80108b47:	e8 c9 04 00 00       	call   80109015 <i8254_read_eeprom>
80108b4c:	83 c4 10             	add    $0x10,%esp
80108b4f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108b52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b55:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108b5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108b5d:	c1 e8 08             	shr    $0x8,%eax
80108b60:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108b65:	83 ec 0c             	sub    $0xc,%esp
80108b68:	6a 02                	push   $0x2
80108b6a:	e8 a6 04 00 00       	call   80109015 <i8254_read_eeprom>
80108b6f:	83 c4 10             	add    $0x10,%esp
80108b72:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108b75:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b78:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108b7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108b80:	c1 e8 08             	shr    $0x8,%eax
80108b83:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108b88:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b8f:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108b92:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108b99:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108b9c:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108ba3:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108ba6:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bad:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108bb0:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bb7:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108bba:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108bc1:	0f b6 c0             	movzbl %al,%eax
80108bc4:	83 ec 04             	sub    $0x4,%esp
80108bc7:	57                   	push   %edi
80108bc8:	56                   	push   %esi
80108bc9:	53                   	push   %ebx
80108bca:	51                   	push   %ecx
80108bcb:	52                   	push   %edx
80108bcc:	50                   	push   %eax
80108bcd:	68 18 c5 10 80       	push   $0x8010c518
80108bd2:	e8 35 78 ff ff       	call   8010040c <cprintf>
80108bd7:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108bda:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108bdf:	05 00 54 00 00       	add    $0x5400,%eax
80108be4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108be7:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108bec:	05 04 54 00 00       	add    $0x5404,%eax
80108bf1:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108bf4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108bf7:	c1 e0 10             	shl    $0x10,%eax
80108bfa:	0b 45 d8             	or     -0x28(%ebp),%eax
80108bfd:	89 c2                	mov    %eax,%edx
80108bff:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108c02:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108c04:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108c07:	0d 00 00 00 80       	or     $0x80000000,%eax
80108c0c:	89 c2                	mov    %eax,%edx
80108c0e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108c11:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108c13:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c18:	05 00 52 00 00       	add    $0x5200,%eax
80108c1d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108c20:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108c27:	eb 19                	jmp    80108c42 <i8254_init_recv+0x130>
    mta[i] = 0;
80108c29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c2c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c33:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108c36:	01 d0                	add    %edx,%eax
80108c38:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108c3e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108c42:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108c46:	7e e1                	jle    80108c29 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108c48:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c4d:	05 d0 00 00 00       	add    $0xd0,%eax
80108c52:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108c55:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108c58:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108c5e:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c63:	05 c8 00 00 00       	add    $0xc8,%eax
80108c68:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108c6b:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108c6e:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108c74:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c79:	05 28 28 00 00       	add    $0x2828,%eax
80108c7e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108c81:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108c84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108c8a:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c8f:	05 00 01 00 00       	add    $0x100,%eax
80108c94:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108c97:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108c9a:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108ca0:	e8 ed 9b ff ff       	call   80102892 <kalloc>
80108ca5:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108ca8:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108cad:	05 00 28 00 00       	add    $0x2800,%eax
80108cb2:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108cb5:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108cba:	05 04 28 00 00       	add    $0x2804,%eax
80108cbf:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108cc2:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108cc7:	05 08 28 00 00       	add    $0x2808,%eax
80108ccc:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108ccf:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108cd4:	05 10 28 00 00       	add    $0x2810,%eax
80108cd9:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108cdc:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108ce1:	05 18 28 00 00       	add    $0x2818,%eax
80108ce6:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108ce9:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108cec:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108cf2:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108cf5:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108cf7:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108cfa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108d00:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108d03:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108d09:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108d0c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108d12:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108d15:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108d1b:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108d1e:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108d21:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108d28:	eb 73                	jmp    80108d9d <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108d2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d2d:	c1 e0 04             	shl    $0x4,%eax
80108d30:	89 c2                	mov    %eax,%edx
80108d32:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d35:	01 d0                	add    %edx,%eax
80108d37:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d41:	c1 e0 04             	shl    $0x4,%eax
80108d44:	89 c2                	mov    %eax,%edx
80108d46:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d49:	01 d0                	add    %edx,%eax
80108d4b:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108d51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d54:	c1 e0 04             	shl    $0x4,%eax
80108d57:	89 c2                	mov    %eax,%edx
80108d59:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d5c:	01 d0                	add    %edx,%eax
80108d5e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108d64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d67:	c1 e0 04             	shl    $0x4,%eax
80108d6a:	89 c2                	mov    %eax,%edx
80108d6c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d6f:	01 d0                	add    %edx,%eax
80108d71:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108d75:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d78:	c1 e0 04             	shl    $0x4,%eax
80108d7b:	89 c2                	mov    %eax,%edx
80108d7d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d80:	01 d0                	add    %edx,%eax
80108d82:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108d86:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d89:	c1 e0 04             	shl    $0x4,%eax
80108d8c:	89 c2                	mov    %eax,%edx
80108d8e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108d91:	01 d0                	add    %edx,%eax
80108d93:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108d99:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108d9d:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108da4:	7e 84                	jle    80108d2a <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108da6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108dad:	eb 57                	jmp    80108e06 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108daf:	e8 de 9a ff ff       	call   80102892 <kalloc>
80108db4:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108db7:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108dbb:	75 12                	jne    80108dcf <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108dbd:	83 ec 0c             	sub    $0xc,%esp
80108dc0:	68 38 c5 10 80       	push   $0x8010c538
80108dc5:	e8 42 76 ff ff       	call   8010040c <cprintf>
80108dca:	83 c4 10             	add    $0x10,%esp
      break;
80108dcd:	eb 3d                	jmp    80108e0c <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108dcf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108dd2:	c1 e0 04             	shl    $0x4,%eax
80108dd5:	89 c2                	mov    %eax,%edx
80108dd7:	8b 45 98             	mov    -0x68(%ebp),%eax
80108dda:	01 d0                	add    %edx,%eax
80108ddc:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108ddf:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108de5:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108de7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108dea:	83 c0 01             	add    $0x1,%eax
80108ded:	c1 e0 04             	shl    $0x4,%eax
80108df0:	89 c2                	mov    %eax,%edx
80108df2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108df5:	01 d0                	add    %edx,%eax
80108df7:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108dfa:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e00:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108e02:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108e06:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108e0a:	7e a3                	jle    80108daf <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108e0c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e0f:	8b 00                	mov    (%eax),%eax
80108e11:	83 c8 02             	or     $0x2,%eax
80108e14:	89 c2                	mov    %eax,%edx
80108e16:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e19:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108e1b:	83 ec 0c             	sub    $0xc,%esp
80108e1e:	68 58 c5 10 80       	push   $0x8010c558
80108e23:	e8 e4 75 ff ff       	call   8010040c <cprintf>
80108e28:	83 c4 10             	add    $0x10,%esp
}
80108e2b:	90                   	nop
80108e2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108e2f:	5b                   	pop    %ebx
80108e30:	5e                   	pop    %esi
80108e31:	5f                   	pop    %edi
80108e32:	5d                   	pop    %ebp
80108e33:	c3                   	ret    

80108e34 <i8254_init_send>:

void i8254_init_send(){
80108e34:	f3 0f 1e fb          	endbr32 
80108e38:	55                   	push   %ebp
80108e39:	89 e5                	mov    %esp,%ebp
80108e3b:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108e3e:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e43:	05 28 38 00 00       	add    $0x3828,%eax
80108e48:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e4e:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108e54:	e8 39 9a ff ff       	call   80102892 <kalloc>
80108e59:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108e5c:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e61:	05 00 38 00 00       	add    $0x3800,%eax
80108e66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108e69:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e6e:	05 04 38 00 00       	add    $0x3804,%eax
80108e73:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108e76:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e7b:	05 08 38 00 00       	add    $0x3808,%eax
80108e80:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108e83:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e86:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108e8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e8f:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108e91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108e94:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108e9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108e9d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108ea3:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108ea8:	05 10 38 00 00       	add    $0x3810,%eax
80108ead:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108eb0:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108eb5:	05 18 38 00 00       	add    $0x3818,%eax
80108eba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108ebd:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108ec0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108ec6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ec9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108ecf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ed2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108ed5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108edc:	e9 82 00 00 00       	jmp    80108f63 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80108ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee4:	c1 e0 04             	shl    $0x4,%eax
80108ee7:	89 c2                	mov    %eax,%edx
80108ee9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108eec:	01 d0                	add    %edx,%eax
80108eee:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef8:	c1 e0 04             	shl    $0x4,%eax
80108efb:	89 c2                	mov    %eax,%edx
80108efd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f00:	01 d0                	add    %edx,%eax
80108f02:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f0b:	c1 e0 04             	shl    $0x4,%eax
80108f0e:	89 c2                	mov    %eax,%edx
80108f10:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f13:	01 d0                	add    %edx,%eax
80108f15:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1c:	c1 e0 04             	shl    $0x4,%eax
80108f1f:	89 c2                	mov    %eax,%edx
80108f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f24:	01 d0                	add    %edx,%eax
80108f26:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f2d:	c1 e0 04             	shl    $0x4,%eax
80108f30:	89 c2                	mov    %eax,%edx
80108f32:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f35:	01 d0                	add    %edx,%eax
80108f37:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f3e:	c1 e0 04             	shl    $0x4,%eax
80108f41:	89 c2                	mov    %eax,%edx
80108f43:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f46:	01 d0                	add    %edx,%eax
80108f48:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f4f:	c1 e0 04             	shl    $0x4,%eax
80108f52:	89 c2                	mov    %eax,%edx
80108f54:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f57:	01 d0                	add    %edx,%eax
80108f59:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108f5f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108f63:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108f6a:	0f 8e 71 ff ff ff    	jle    80108ee1 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108f70:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108f77:	eb 57                	jmp    80108fd0 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80108f79:	e8 14 99 ff ff       	call   80102892 <kalloc>
80108f7e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108f81:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108f85:	75 12                	jne    80108f99 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80108f87:	83 ec 0c             	sub    $0xc,%esp
80108f8a:	68 38 c5 10 80       	push   $0x8010c538
80108f8f:	e8 78 74 ff ff       	call   8010040c <cprintf>
80108f94:	83 c4 10             	add    $0x10,%esp
      break;
80108f97:	eb 3d                	jmp    80108fd6 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f9c:	c1 e0 04             	shl    $0x4,%eax
80108f9f:	89 c2                	mov    %eax,%edx
80108fa1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fa4:	01 d0                	add    %edx,%eax
80108fa6:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108fa9:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108faf:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108fb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fb4:	83 c0 01             	add    $0x1,%eax
80108fb7:	c1 e0 04             	shl    $0x4,%eax
80108fba:	89 c2                	mov    %eax,%edx
80108fbc:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108fbf:	01 d0                	add    %edx,%eax
80108fc1:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108fc4:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108fca:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108fcc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108fd0:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108fd4:	7e a3                	jle    80108f79 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108fd6:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108fdb:	05 00 04 00 00       	add    $0x400,%eax
80108fe0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108fe3:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108fe6:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108fec:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108ff1:	05 10 04 00 00       	add    $0x410,%eax
80108ff6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108ff9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ffc:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109002:	83 ec 0c             	sub    $0xc,%esp
80109005:	68 78 c5 10 80       	push   $0x8010c578
8010900a:	e8 fd 73 ff ff       	call   8010040c <cprintf>
8010900f:	83 c4 10             	add    $0x10,%esp

}
80109012:	90                   	nop
80109013:	c9                   	leave  
80109014:	c3                   	ret    

80109015 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109015:	f3 0f 1e fb          	endbr32 
80109019:	55                   	push   %ebp
8010901a:	89 e5                	mov    %esp,%ebp
8010901c:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
8010901f:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109024:	83 c0 14             	add    $0x14,%eax
80109027:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
8010902a:	8b 45 08             	mov    0x8(%ebp),%eax
8010902d:	c1 e0 08             	shl    $0x8,%eax
80109030:	0f b7 c0             	movzwl %ax,%eax
80109033:	83 c8 01             	or     $0x1,%eax
80109036:	89 c2                	mov    %eax,%edx
80109038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010903b:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
8010903d:	83 ec 0c             	sub    $0xc,%esp
80109040:	68 98 c5 10 80       	push   $0x8010c598
80109045:	e8 c2 73 ff ff       	call   8010040c <cprintf>
8010904a:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010904d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109050:	8b 00                	mov    (%eax),%eax
80109052:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109055:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109058:	83 e0 10             	and    $0x10,%eax
8010905b:	85 c0                	test   %eax,%eax
8010905d:	75 02                	jne    80109061 <i8254_read_eeprom+0x4c>
  while(1){
8010905f:	eb dc                	jmp    8010903d <i8254_read_eeprom+0x28>
      break;
80109061:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109065:	8b 00                	mov    (%eax),%eax
80109067:	c1 e8 10             	shr    $0x10,%eax
}
8010906a:	c9                   	leave  
8010906b:	c3                   	ret    

8010906c <i8254_recv>:
void i8254_recv(){
8010906c:	f3 0f 1e fb          	endbr32 
80109070:	55                   	push   %ebp
80109071:	89 e5                	mov    %esp,%ebp
80109073:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109076:	a1 b4 81 19 80       	mov    0x801981b4,%eax
8010907b:	05 10 28 00 00       	add    $0x2810,%eax
80109080:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109083:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109088:	05 18 28 00 00       	add    $0x2818,%eax
8010908d:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109090:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109095:	05 00 28 00 00       	add    $0x2800,%eax
8010909a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010909d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090a0:	8b 00                	mov    (%eax),%eax
801090a2:	05 00 00 00 80       	add    $0x80000000,%eax
801090a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801090aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ad:	8b 10                	mov    (%eax),%edx
801090af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090b2:	8b 00                	mov    (%eax),%eax
801090b4:	29 c2                	sub    %eax,%edx
801090b6:	89 d0                	mov    %edx,%eax
801090b8:	25 ff 00 00 00       	and    $0xff,%eax
801090bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801090c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801090c4:	7e 37                	jle    801090fd <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
801090c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090c9:	8b 00                	mov    (%eax),%eax
801090cb:	c1 e0 04             	shl    $0x4,%eax
801090ce:	89 c2                	mov    %eax,%edx
801090d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090d3:	01 d0                	add    %edx,%eax
801090d5:	8b 00                	mov    (%eax),%eax
801090d7:	05 00 00 00 80       	add    $0x80000000,%eax
801090dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801090df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e2:	8b 00                	mov    (%eax),%eax
801090e4:	83 c0 01             	add    $0x1,%eax
801090e7:	0f b6 d0             	movzbl %al,%edx
801090ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090ed:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801090ef:	83 ec 0c             	sub    $0xc,%esp
801090f2:	ff 75 e0             	pushl  -0x20(%ebp)
801090f5:	e8 47 09 00 00       	call   80109a41 <eth_proc>
801090fa:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801090fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109100:	8b 10                	mov    (%eax),%edx
80109102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109105:	8b 00                	mov    (%eax),%eax
80109107:	39 c2                	cmp    %eax,%edx
80109109:	75 9f                	jne    801090aa <i8254_recv+0x3e>
      (*rdt)--;
8010910b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010910e:	8b 00                	mov    (%eax),%eax
80109110:	8d 50 ff             	lea    -0x1(%eax),%edx
80109113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109116:	89 10                	mov    %edx,(%eax)
  while(1){
80109118:	eb 90                	jmp    801090aa <i8254_recv+0x3e>

8010911a <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010911a:	f3 0f 1e fb          	endbr32 
8010911e:	55                   	push   %ebp
8010911f:	89 e5                	mov    %esp,%ebp
80109121:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80109124:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109129:	05 10 38 00 00       	add    $0x3810,%eax
8010912e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109131:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109136:	05 18 38 00 00       	add    $0x3818,%eax
8010913b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010913e:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109143:	05 00 38 00 00       	add    $0x3800,%eax
80109148:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
8010914b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010914e:	8b 00                	mov    (%eax),%eax
80109150:	05 00 00 00 80       	add    $0x80000000,%eax
80109155:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109158:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010915b:	8b 10                	mov    (%eax),%edx
8010915d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109160:	8b 00                	mov    (%eax),%eax
80109162:	29 c2                	sub    %eax,%edx
80109164:	89 d0                	mov    %edx,%eax
80109166:	0f b6 c0             	movzbl %al,%eax
80109169:	ba 00 01 00 00       	mov    $0x100,%edx
8010916e:	29 c2                	sub    %eax,%edx
80109170:	89 d0                	mov    %edx,%eax
80109172:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109175:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109178:	8b 00                	mov    (%eax),%eax
8010917a:	25 ff 00 00 00       	and    $0xff,%eax
8010917f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109182:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109186:	0f 8e a8 00 00 00    	jle    80109234 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
8010918c:	8b 45 08             	mov    0x8(%ebp),%eax
8010918f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109192:	89 d1                	mov    %edx,%ecx
80109194:	c1 e1 04             	shl    $0x4,%ecx
80109197:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010919a:	01 ca                	add    %ecx,%edx
8010919c:	8b 12                	mov    (%edx),%edx
8010919e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801091a4:	83 ec 04             	sub    $0x4,%esp
801091a7:	ff 75 0c             	pushl  0xc(%ebp)
801091aa:	50                   	push   %eax
801091ab:	52                   	push   %edx
801091ac:	e8 31 bd ff ff       	call   80104ee2 <memmove>
801091b1:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801091b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091b7:	c1 e0 04             	shl    $0x4,%eax
801091ba:	89 c2                	mov    %eax,%edx
801091bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091bf:	01 d0                	add    %edx,%eax
801091c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801091c4:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801091c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091cb:	c1 e0 04             	shl    $0x4,%eax
801091ce:	89 c2                	mov    %eax,%edx
801091d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091d3:	01 d0                	add    %edx,%eax
801091d5:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801091d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091dc:	c1 e0 04             	shl    $0x4,%eax
801091df:	89 c2                	mov    %eax,%edx
801091e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091e4:	01 d0                	add    %edx,%eax
801091e6:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801091ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091ed:	c1 e0 04             	shl    $0x4,%eax
801091f0:	89 c2                	mov    %eax,%edx
801091f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091f5:	01 d0                	add    %edx,%eax
801091f7:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801091fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801091fe:	c1 e0 04             	shl    $0x4,%eax
80109201:	89 c2                	mov    %eax,%edx
80109203:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109206:	01 d0                	add    %edx,%eax
80109208:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
8010920e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109211:	c1 e0 04             	shl    $0x4,%eax
80109214:	89 c2                	mov    %eax,%edx
80109216:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109219:	01 d0                	add    %edx,%eax
8010921b:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
8010921f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109222:	8b 00                	mov    (%eax),%eax
80109224:	83 c0 01             	add    $0x1,%eax
80109227:	0f b6 d0             	movzbl %al,%edx
8010922a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010922d:	89 10                	mov    %edx,(%eax)
    return len;
8010922f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109232:	eb 05                	jmp    80109239 <i8254_send+0x11f>
  }else{
    return -1;
80109234:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109239:	c9                   	leave  
8010923a:	c3                   	ret    

8010923b <i8254_intr>:

void i8254_intr(){
8010923b:	f3 0f 1e fb          	endbr32 
8010923f:	55                   	push   %ebp
80109240:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109242:	a1 b8 81 19 80       	mov    0x801981b8,%eax
80109247:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010924d:	90                   	nop
8010924e:	5d                   	pop    %ebp
8010924f:	c3                   	ret    

80109250 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109250:	f3 0f 1e fb          	endbr32 
80109254:	55                   	push   %ebp
80109255:	89 e5                	mov    %esp,%ebp
80109257:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010925a:	8b 45 08             	mov    0x8(%ebp),%eax
8010925d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109263:	0f b7 00             	movzwl (%eax),%eax
80109266:	66 3d 00 01          	cmp    $0x100,%ax
8010926a:	74 0a                	je     80109276 <arp_proc+0x26>
8010926c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109271:	e9 4f 01 00 00       	jmp    801093c5 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109276:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109279:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010927d:	66 83 f8 08          	cmp    $0x8,%ax
80109281:	74 0a                	je     8010928d <arp_proc+0x3d>
80109283:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109288:	e9 38 01 00 00       	jmp    801093c5 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
8010928d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109290:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109294:	3c 06                	cmp    $0x6,%al
80109296:	74 0a                	je     801092a2 <arp_proc+0x52>
80109298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010929d:	e9 23 01 00 00       	jmp    801093c5 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
801092a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092a5:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801092a9:	3c 04                	cmp    $0x4,%al
801092ab:	74 0a                	je     801092b7 <arp_proc+0x67>
801092ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092b2:	e9 0e 01 00 00       	jmp    801093c5 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801092b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ba:	83 c0 18             	add    $0x18,%eax
801092bd:	83 ec 04             	sub    $0x4,%esp
801092c0:	6a 04                	push   $0x4
801092c2:	50                   	push   %eax
801092c3:	68 04 f5 10 80       	push   $0x8010f504
801092c8:	e8 b9 bb ff ff       	call   80104e86 <memcmp>
801092cd:	83 c4 10             	add    $0x10,%esp
801092d0:	85 c0                	test   %eax,%eax
801092d2:	74 27                	je     801092fb <arp_proc+0xab>
801092d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d7:	83 c0 0e             	add    $0xe,%eax
801092da:	83 ec 04             	sub    $0x4,%esp
801092dd:	6a 04                	push   $0x4
801092df:	50                   	push   %eax
801092e0:	68 04 f5 10 80       	push   $0x8010f504
801092e5:	e8 9c bb ff ff       	call   80104e86 <memcmp>
801092ea:	83 c4 10             	add    $0x10,%esp
801092ed:	85 c0                	test   %eax,%eax
801092ef:	74 0a                	je     801092fb <arp_proc+0xab>
801092f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092f6:	e9 ca 00 00 00       	jmp    801093c5 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801092fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092fe:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109302:	66 3d 00 01          	cmp    $0x100,%ax
80109306:	75 69                	jne    80109371 <arp_proc+0x121>
80109308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010930b:	83 c0 18             	add    $0x18,%eax
8010930e:	83 ec 04             	sub    $0x4,%esp
80109311:	6a 04                	push   $0x4
80109313:	50                   	push   %eax
80109314:	68 04 f5 10 80       	push   $0x8010f504
80109319:	e8 68 bb ff ff       	call   80104e86 <memcmp>
8010931e:	83 c4 10             	add    $0x10,%esp
80109321:	85 c0                	test   %eax,%eax
80109323:	75 4c                	jne    80109371 <arp_proc+0x121>
    uint send = (uint)kalloc();
80109325:	e8 68 95 ff ff       	call   80102892 <kalloc>
8010932a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
8010932d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109334:	83 ec 04             	sub    $0x4,%esp
80109337:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010933a:	50                   	push   %eax
8010933b:	ff 75 f0             	pushl  -0x10(%ebp)
8010933e:	ff 75 f4             	pushl  -0xc(%ebp)
80109341:	e8 33 04 00 00       	call   80109779 <arp_reply_pkt_create>
80109346:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109349:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010934c:	83 ec 08             	sub    $0x8,%esp
8010934f:	50                   	push   %eax
80109350:	ff 75 f0             	pushl  -0x10(%ebp)
80109353:	e8 c2 fd ff ff       	call   8010911a <i8254_send>
80109358:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010935b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010935e:	83 ec 0c             	sub    $0xc,%esp
80109361:	50                   	push   %eax
80109362:	e8 8d 94 ff ff       	call   801027f4 <kfree>
80109367:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010936a:	b8 02 00 00 00       	mov    $0x2,%eax
8010936f:	eb 54                	jmp    801093c5 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109374:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109378:	66 3d 00 02          	cmp    $0x200,%ax
8010937c:	75 42                	jne    801093c0 <arp_proc+0x170>
8010937e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109381:	83 c0 18             	add    $0x18,%eax
80109384:	83 ec 04             	sub    $0x4,%esp
80109387:	6a 04                	push   $0x4
80109389:	50                   	push   %eax
8010938a:	68 04 f5 10 80       	push   $0x8010f504
8010938f:	e8 f2 ba ff ff       	call   80104e86 <memcmp>
80109394:	83 c4 10             	add    $0x10,%esp
80109397:	85 c0                	test   %eax,%eax
80109399:	75 25                	jne    801093c0 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
8010939b:	83 ec 0c             	sub    $0xc,%esp
8010939e:	68 9c c5 10 80       	push   $0x8010c59c
801093a3:	e8 64 70 ff ff       	call   8010040c <cprintf>
801093a8:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801093ab:	83 ec 0c             	sub    $0xc,%esp
801093ae:	ff 75 f4             	pushl  -0xc(%ebp)
801093b1:	e8 b7 01 00 00       	call   8010956d <arp_table_update>
801093b6:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801093b9:	b8 01 00 00 00       	mov    $0x1,%eax
801093be:	eb 05                	jmp    801093c5 <arp_proc+0x175>
  }else{
    return -1;
801093c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801093c5:	c9                   	leave  
801093c6:	c3                   	ret    

801093c7 <arp_scan>:

void arp_scan(){
801093c7:	f3 0f 1e fb          	endbr32 
801093cb:	55                   	push   %ebp
801093cc:	89 e5                	mov    %esp,%ebp
801093ce:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801093d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801093d8:	eb 6f                	jmp    80109449 <arp_scan+0x82>
    uint send = (uint)kalloc();
801093da:	e8 b3 94 ff ff       	call   80102892 <kalloc>
801093df:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801093e2:	83 ec 04             	sub    $0x4,%esp
801093e5:	ff 75 f4             	pushl  -0xc(%ebp)
801093e8:	8d 45 e8             	lea    -0x18(%ebp),%eax
801093eb:	50                   	push   %eax
801093ec:	ff 75 ec             	pushl  -0x14(%ebp)
801093ef:	e8 62 00 00 00       	call   80109456 <arp_broadcast>
801093f4:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801093f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093fa:	83 ec 08             	sub    $0x8,%esp
801093fd:	50                   	push   %eax
801093fe:	ff 75 ec             	pushl  -0x14(%ebp)
80109401:	e8 14 fd ff ff       	call   8010911a <i8254_send>
80109406:	83 c4 10             	add    $0x10,%esp
80109409:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010940c:	eb 22                	jmp    80109430 <arp_scan+0x69>
      microdelay(1);
8010940e:	83 ec 0c             	sub    $0xc,%esp
80109411:	6a 01                	push   $0x1
80109413:	e8 2c 98 ff ff       	call   80102c44 <microdelay>
80109418:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010941b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010941e:	83 ec 08             	sub    $0x8,%esp
80109421:	50                   	push   %eax
80109422:	ff 75 ec             	pushl  -0x14(%ebp)
80109425:	e8 f0 fc ff ff       	call   8010911a <i8254_send>
8010942a:	83 c4 10             	add    $0x10,%esp
8010942d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109430:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109434:	74 d8                	je     8010940e <arp_scan+0x47>
    }
    kfree((char *)send);
80109436:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109439:	83 ec 0c             	sub    $0xc,%esp
8010943c:	50                   	push   %eax
8010943d:	e8 b2 93 ff ff       	call   801027f4 <kfree>
80109442:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109445:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109449:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109450:	7e 88                	jle    801093da <arp_scan+0x13>
  }
}
80109452:	90                   	nop
80109453:	90                   	nop
80109454:	c9                   	leave  
80109455:	c3                   	ret    

80109456 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109456:	f3 0f 1e fb          	endbr32 
8010945a:	55                   	push   %ebp
8010945b:	89 e5                	mov    %esp,%ebp
8010945d:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109460:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109464:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109468:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010946c:	8b 45 10             	mov    0x10(%ebp),%eax
8010946f:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109472:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109479:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
8010947f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109486:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010948c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010948f:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109495:	8b 45 08             	mov    0x8(%ebp),%eax
80109498:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010949b:	8b 45 08             	mov    0x8(%ebp),%eax
8010949e:	83 c0 0e             	add    $0xe,%eax
801094a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
801094a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a7:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801094ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ae:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801094b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b5:	83 ec 04             	sub    $0x4,%esp
801094b8:	6a 06                	push   $0x6
801094ba:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801094bd:	52                   	push   %edx
801094be:	50                   	push   %eax
801094bf:	e8 1e ba ff ff       	call   80104ee2 <memmove>
801094c4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801094c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ca:	83 c0 06             	add    $0x6,%eax
801094cd:	83 ec 04             	sub    $0x4,%esp
801094d0:	6a 06                	push   $0x6
801094d2:	68 68 d0 18 80       	push   $0x8018d068
801094d7:	50                   	push   %eax
801094d8:	e8 05 ba ff ff       	call   80104ee2 <memmove>
801094dd:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801094e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094e3:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801094e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094eb:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801094f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094f4:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801094f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094fb:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801094ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109502:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010950b:	8d 50 12             	lea    0x12(%eax),%edx
8010950e:	83 ec 04             	sub    $0x4,%esp
80109511:	6a 06                	push   $0x6
80109513:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109516:	50                   	push   %eax
80109517:	52                   	push   %edx
80109518:	e8 c5 b9 ff ff       	call   80104ee2 <memmove>
8010951d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109520:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109523:	8d 50 18             	lea    0x18(%eax),%edx
80109526:	83 ec 04             	sub    $0x4,%esp
80109529:	6a 04                	push   $0x4
8010952b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010952e:	50                   	push   %eax
8010952f:	52                   	push   %edx
80109530:	e8 ad b9 ff ff       	call   80104ee2 <memmove>
80109535:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010953b:	83 c0 08             	add    $0x8,%eax
8010953e:	83 ec 04             	sub    $0x4,%esp
80109541:	6a 06                	push   $0x6
80109543:	68 68 d0 18 80       	push   $0x8018d068
80109548:	50                   	push   %eax
80109549:	e8 94 b9 ff ff       	call   80104ee2 <memmove>
8010954e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109551:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109554:	83 c0 0e             	add    $0xe,%eax
80109557:	83 ec 04             	sub    $0x4,%esp
8010955a:	6a 04                	push   $0x4
8010955c:	68 04 f5 10 80       	push   $0x8010f504
80109561:	50                   	push   %eax
80109562:	e8 7b b9 ff ff       	call   80104ee2 <memmove>
80109567:	83 c4 10             	add    $0x10,%esp
}
8010956a:	90                   	nop
8010956b:	c9                   	leave  
8010956c:	c3                   	ret    

8010956d <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010956d:	f3 0f 1e fb          	endbr32 
80109571:	55                   	push   %ebp
80109572:	89 e5                	mov    %esp,%ebp
80109574:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109577:	8b 45 08             	mov    0x8(%ebp),%eax
8010957a:	83 c0 0e             	add    $0xe,%eax
8010957d:	83 ec 0c             	sub    $0xc,%esp
80109580:	50                   	push   %eax
80109581:	e8 bc 00 00 00       	call   80109642 <arp_table_search>
80109586:	83 c4 10             	add    $0x10,%esp
80109589:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010958c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109590:	78 2d                	js     801095bf <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109592:	8b 45 08             	mov    0x8(%ebp),%eax
80109595:	8d 48 08             	lea    0x8(%eax),%ecx
80109598:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010959b:	89 d0                	mov    %edx,%eax
8010959d:	c1 e0 02             	shl    $0x2,%eax
801095a0:	01 d0                	add    %edx,%eax
801095a2:	01 c0                	add    %eax,%eax
801095a4:	01 d0                	add    %edx,%eax
801095a6:	05 80 d0 18 80       	add    $0x8018d080,%eax
801095ab:	83 c0 04             	add    $0x4,%eax
801095ae:	83 ec 04             	sub    $0x4,%esp
801095b1:	6a 06                	push   $0x6
801095b3:	51                   	push   %ecx
801095b4:	50                   	push   %eax
801095b5:	e8 28 b9 ff ff       	call   80104ee2 <memmove>
801095ba:	83 c4 10             	add    $0x10,%esp
801095bd:	eb 70                	jmp    8010962f <arp_table_update+0xc2>
  }else{
    index += 1;
801095bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
801095c3:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
801095c6:	8b 45 08             	mov    0x8(%ebp),%eax
801095c9:	8d 48 08             	lea    0x8(%eax),%ecx
801095cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095cf:	89 d0                	mov    %edx,%eax
801095d1:	c1 e0 02             	shl    $0x2,%eax
801095d4:	01 d0                	add    %edx,%eax
801095d6:	01 c0                	add    %eax,%eax
801095d8:	01 d0                	add    %edx,%eax
801095da:	05 80 d0 18 80       	add    $0x8018d080,%eax
801095df:	83 c0 04             	add    $0x4,%eax
801095e2:	83 ec 04             	sub    $0x4,%esp
801095e5:	6a 06                	push   $0x6
801095e7:	51                   	push   %ecx
801095e8:	50                   	push   %eax
801095e9:	e8 f4 b8 ff ff       	call   80104ee2 <memmove>
801095ee:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801095f1:	8b 45 08             	mov    0x8(%ebp),%eax
801095f4:	8d 48 0e             	lea    0xe(%eax),%ecx
801095f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095fa:	89 d0                	mov    %edx,%eax
801095fc:	c1 e0 02             	shl    $0x2,%eax
801095ff:	01 d0                	add    %edx,%eax
80109601:	01 c0                	add    %eax,%eax
80109603:	01 d0                	add    %edx,%eax
80109605:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010960a:	83 ec 04             	sub    $0x4,%esp
8010960d:	6a 04                	push   $0x4
8010960f:	51                   	push   %ecx
80109610:	50                   	push   %eax
80109611:	e8 cc b8 ff ff       	call   80104ee2 <memmove>
80109616:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109619:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010961c:	89 d0                	mov    %edx,%eax
8010961e:	c1 e0 02             	shl    $0x2,%eax
80109621:	01 d0                	add    %edx,%eax
80109623:	01 c0                	add    %eax,%eax
80109625:	01 d0                	add    %edx,%eax
80109627:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010962c:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
8010962f:	83 ec 0c             	sub    $0xc,%esp
80109632:	68 80 d0 18 80       	push   $0x8018d080
80109637:	e8 87 00 00 00       	call   801096c3 <print_arp_table>
8010963c:	83 c4 10             	add    $0x10,%esp
}
8010963f:	90                   	nop
80109640:	c9                   	leave  
80109641:	c3                   	ret    

80109642 <arp_table_search>:

int arp_table_search(uchar *ip){
80109642:	f3 0f 1e fb          	endbr32 
80109646:	55                   	push   %ebp
80109647:	89 e5                	mov    %esp,%ebp
80109649:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010964c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109653:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010965a:	eb 59                	jmp    801096b5 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010965c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010965f:	89 d0                	mov    %edx,%eax
80109661:	c1 e0 02             	shl    $0x2,%eax
80109664:	01 d0                	add    %edx,%eax
80109666:	01 c0                	add    %eax,%eax
80109668:	01 d0                	add    %edx,%eax
8010966a:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010966f:	83 ec 04             	sub    $0x4,%esp
80109672:	6a 04                	push   $0x4
80109674:	ff 75 08             	pushl  0x8(%ebp)
80109677:	50                   	push   %eax
80109678:	e8 09 b8 ff ff       	call   80104e86 <memcmp>
8010967d:	83 c4 10             	add    $0x10,%esp
80109680:	85 c0                	test   %eax,%eax
80109682:	75 05                	jne    80109689 <arp_table_search+0x47>
      return i;
80109684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109687:	eb 38                	jmp    801096c1 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109689:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010968c:	89 d0                	mov    %edx,%eax
8010968e:	c1 e0 02             	shl    $0x2,%eax
80109691:	01 d0                	add    %edx,%eax
80109693:	01 c0                	add    %eax,%eax
80109695:	01 d0                	add    %edx,%eax
80109697:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010969c:	0f b6 00             	movzbl (%eax),%eax
8010969f:	84 c0                	test   %al,%al
801096a1:	75 0e                	jne    801096b1 <arp_table_search+0x6f>
801096a3:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801096a7:	75 08                	jne    801096b1 <arp_table_search+0x6f>
      empty = -i;
801096a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096ac:	f7 d8                	neg    %eax
801096ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801096b1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801096b5:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
801096b9:	7e a1                	jle    8010965c <arp_table_search+0x1a>
    }
  }
  return empty-1;
801096bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096be:	83 e8 01             	sub    $0x1,%eax
}
801096c1:	c9                   	leave  
801096c2:	c3                   	ret    

801096c3 <print_arp_table>:

void print_arp_table(){
801096c3:	f3 0f 1e fb          	endbr32 
801096c7:	55                   	push   %ebp
801096c8:	89 e5                	mov    %esp,%ebp
801096ca:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801096cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801096d4:	e9 92 00 00 00       	jmp    8010976b <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
801096d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801096dc:	89 d0                	mov    %edx,%eax
801096de:	c1 e0 02             	shl    $0x2,%eax
801096e1:	01 d0                	add    %edx,%eax
801096e3:	01 c0                	add    %eax,%eax
801096e5:	01 d0                	add    %edx,%eax
801096e7:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801096ec:	0f b6 00             	movzbl (%eax),%eax
801096ef:	84 c0                	test   %al,%al
801096f1:	74 74                	je     80109767 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
801096f3:	83 ec 08             	sub    $0x8,%esp
801096f6:	ff 75 f4             	pushl  -0xc(%ebp)
801096f9:	68 af c5 10 80       	push   $0x8010c5af
801096fe:	e8 09 6d ff ff       	call   8010040c <cprintf>
80109703:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109706:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109709:	89 d0                	mov    %edx,%eax
8010970b:	c1 e0 02             	shl    $0x2,%eax
8010970e:	01 d0                	add    %edx,%eax
80109710:	01 c0                	add    %eax,%eax
80109712:	01 d0                	add    %edx,%eax
80109714:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109719:	83 ec 0c             	sub    $0xc,%esp
8010971c:	50                   	push   %eax
8010971d:	e8 5c 02 00 00       	call   8010997e <print_ipv4>
80109722:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109725:	83 ec 0c             	sub    $0xc,%esp
80109728:	68 be c5 10 80       	push   $0x8010c5be
8010972d:	e8 da 6c ff ff       	call   8010040c <cprintf>
80109732:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109735:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109738:	89 d0                	mov    %edx,%eax
8010973a:	c1 e0 02             	shl    $0x2,%eax
8010973d:	01 d0                	add    %edx,%eax
8010973f:	01 c0                	add    %eax,%eax
80109741:	01 d0                	add    %edx,%eax
80109743:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109748:	83 c0 04             	add    $0x4,%eax
8010974b:	83 ec 0c             	sub    $0xc,%esp
8010974e:	50                   	push   %eax
8010974f:	e8 7c 02 00 00       	call   801099d0 <print_mac>
80109754:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109757:	83 ec 0c             	sub    $0xc,%esp
8010975a:	68 c0 c5 10 80       	push   $0x8010c5c0
8010975f:	e8 a8 6c ff ff       	call   8010040c <cprintf>
80109764:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109767:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010976b:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010976f:	0f 8e 64 ff ff ff    	jle    801096d9 <print_arp_table+0x16>
    }
  }
}
80109775:	90                   	nop
80109776:	90                   	nop
80109777:	c9                   	leave  
80109778:	c3                   	ret    

80109779 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109779:	f3 0f 1e fb          	endbr32 
8010977d:	55                   	push   %ebp
8010977e:	89 e5                	mov    %esp,%ebp
80109780:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109783:	8b 45 10             	mov    0x10(%ebp),%eax
80109786:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010978c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010978f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109792:	8b 45 0c             	mov    0xc(%ebp),%eax
80109795:	83 c0 0e             	add    $0xe,%eax
80109798:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010979b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010979e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801097a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097a5:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
801097a9:	8b 45 08             	mov    0x8(%ebp),%eax
801097ac:	8d 50 08             	lea    0x8(%eax),%edx
801097af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b2:	83 ec 04             	sub    $0x4,%esp
801097b5:	6a 06                	push   $0x6
801097b7:	52                   	push   %edx
801097b8:	50                   	push   %eax
801097b9:	e8 24 b7 ff ff       	call   80104ee2 <memmove>
801097be:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801097c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097c4:	83 c0 06             	add    $0x6,%eax
801097c7:	83 ec 04             	sub    $0x4,%esp
801097ca:	6a 06                	push   $0x6
801097cc:	68 68 d0 18 80       	push   $0x8018d068
801097d1:	50                   	push   %eax
801097d2:	e8 0b b7 ff ff       	call   80104ee2 <memmove>
801097d7:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801097da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097dd:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801097e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097e5:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801097eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097ee:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801097f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097f5:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801097f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097fc:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109802:	8b 45 08             	mov    0x8(%ebp),%eax
80109805:	8d 50 08             	lea    0x8(%eax),%edx
80109808:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010980b:	83 c0 12             	add    $0x12,%eax
8010980e:	83 ec 04             	sub    $0x4,%esp
80109811:	6a 06                	push   $0x6
80109813:	52                   	push   %edx
80109814:	50                   	push   %eax
80109815:	e8 c8 b6 ff ff       	call   80104ee2 <memmove>
8010981a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
8010981d:	8b 45 08             	mov    0x8(%ebp),%eax
80109820:	8d 50 0e             	lea    0xe(%eax),%edx
80109823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109826:	83 c0 18             	add    $0x18,%eax
80109829:	83 ec 04             	sub    $0x4,%esp
8010982c:	6a 04                	push   $0x4
8010982e:	52                   	push   %edx
8010982f:	50                   	push   %eax
80109830:	e8 ad b6 ff ff       	call   80104ee2 <memmove>
80109835:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109838:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010983b:	83 c0 08             	add    $0x8,%eax
8010983e:	83 ec 04             	sub    $0x4,%esp
80109841:	6a 06                	push   $0x6
80109843:	68 68 d0 18 80       	push   $0x8018d068
80109848:	50                   	push   %eax
80109849:	e8 94 b6 ff ff       	call   80104ee2 <memmove>
8010984e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109854:	83 c0 0e             	add    $0xe,%eax
80109857:	83 ec 04             	sub    $0x4,%esp
8010985a:	6a 04                	push   $0x4
8010985c:	68 04 f5 10 80       	push   $0x8010f504
80109861:	50                   	push   %eax
80109862:	e8 7b b6 ff ff       	call   80104ee2 <memmove>
80109867:	83 c4 10             	add    $0x10,%esp
}
8010986a:	90                   	nop
8010986b:	c9                   	leave  
8010986c:	c3                   	ret    

8010986d <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
8010986d:	f3 0f 1e fb          	endbr32 
80109871:	55                   	push   %ebp
80109872:	89 e5                	mov    %esp,%ebp
80109874:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109877:	83 ec 0c             	sub    $0xc,%esp
8010987a:	68 c2 c5 10 80       	push   $0x8010c5c2
8010987f:	e8 88 6b ff ff       	call   8010040c <cprintf>
80109884:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109887:	8b 45 08             	mov    0x8(%ebp),%eax
8010988a:	83 c0 0e             	add    $0xe,%eax
8010988d:	83 ec 0c             	sub    $0xc,%esp
80109890:	50                   	push   %eax
80109891:	e8 e8 00 00 00       	call   8010997e <print_ipv4>
80109896:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109899:	83 ec 0c             	sub    $0xc,%esp
8010989c:	68 c0 c5 10 80       	push   $0x8010c5c0
801098a1:	e8 66 6b ff ff       	call   8010040c <cprintf>
801098a6:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
801098a9:	8b 45 08             	mov    0x8(%ebp),%eax
801098ac:	83 c0 08             	add    $0x8,%eax
801098af:	83 ec 0c             	sub    $0xc,%esp
801098b2:	50                   	push   %eax
801098b3:	e8 18 01 00 00       	call   801099d0 <print_mac>
801098b8:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801098bb:	83 ec 0c             	sub    $0xc,%esp
801098be:	68 c0 c5 10 80       	push   $0x8010c5c0
801098c3:	e8 44 6b ff ff       	call   8010040c <cprintf>
801098c8:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
801098cb:	83 ec 0c             	sub    $0xc,%esp
801098ce:	68 d9 c5 10 80       	push   $0x8010c5d9
801098d3:	e8 34 6b ff ff       	call   8010040c <cprintf>
801098d8:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
801098db:	8b 45 08             	mov    0x8(%ebp),%eax
801098de:	83 c0 18             	add    $0x18,%eax
801098e1:	83 ec 0c             	sub    $0xc,%esp
801098e4:	50                   	push   %eax
801098e5:	e8 94 00 00 00       	call   8010997e <print_ipv4>
801098ea:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801098ed:	83 ec 0c             	sub    $0xc,%esp
801098f0:	68 c0 c5 10 80       	push   $0x8010c5c0
801098f5:	e8 12 6b ff ff       	call   8010040c <cprintf>
801098fa:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801098fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109900:	83 c0 12             	add    $0x12,%eax
80109903:	83 ec 0c             	sub    $0xc,%esp
80109906:	50                   	push   %eax
80109907:	e8 c4 00 00 00       	call   801099d0 <print_mac>
8010990c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010990f:	83 ec 0c             	sub    $0xc,%esp
80109912:	68 c0 c5 10 80       	push   $0x8010c5c0
80109917:	e8 f0 6a ff ff       	call   8010040c <cprintf>
8010991c:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010991f:	83 ec 0c             	sub    $0xc,%esp
80109922:	68 f0 c5 10 80       	push   $0x8010c5f0
80109927:	e8 e0 6a ff ff       	call   8010040c <cprintf>
8010992c:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010992f:	8b 45 08             	mov    0x8(%ebp),%eax
80109932:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109936:	66 3d 00 01          	cmp    $0x100,%ax
8010993a:	75 12                	jne    8010994e <print_arp_info+0xe1>
8010993c:	83 ec 0c             	sub    $0xc,%esp
8010993f:	68 fc c5 10 80       	push   $0x8010c5fc
80109944:	e8 c3 6a ff ff       	call   8010040c <cprintf>
80109949:	83 c4 10             	add    $0x10,%esp
8010994c:	eb 1d                	jmp    8010996b <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010994e:	8b 45 08             	mov    0x8(%ebp),%eax
80109951:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109955:	66 3d 00 02          	cmp    $0x200,%ax
80109959:	75 10                	jne    8010996b <print_arp_info+0xfe>
    cprintf("Reply\n");
8010995b:	83 ec 0c             	sub    $0xc,%esp
8010995e:	68 05 c6 10 80       	push   $0x8010c605
80109963:	e8 a4 6a ff ff       	call   8010040c <cprintf>
80109968:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010996b:	83 ec 0c             	sub    $0xc,%esp
8010996e:	68 c0 c5 10 80       	push   $0x8010c5c0
80109973:	e8 94 6a ff ff       	call   8010040c <cprintf>
80109978:	83 c4 10             	add    $0x10,%esp
}
8010997b:	90                   	nop
8010997c:	c9                   	leave  
8010997d:	c3                   	ret    

8010997e <print_ipv4>:

void print_ipv4(uchar *ip){
8010997e:	f3 0f 1e fb          	endbr32 
80109982:	55                   	push   %ebp
80109983:	89 e5                	mov    %esp,%ebp
80109985:	53                   	push   %ebx
80109986:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109989:	8b 45 08             	mov    0x8(%ebp),%eax
8010998c:	83 c0 03             	add    $0x3,%eax
8010998f:	0f b6 00             	movzbl (%eax),%eax
80109992:	0f b6 d8             	movzbl %al,%ebx
80109995:	8b 45 08             	mov    0x8(%ebp),%eax
80109998:	83 c0 02             	add    $0x2,%eax
8010999b:	0f b6 00             	movzbl (%eax),%eax
8010999e:	0f b6 c8             	movzbl %al,%ecx
801099a1:	8b 45 08             	mov    0x8(%ebp),%eax
801099a4:	83 c0 01             	add    $0x1,%eax
801099a7:	0f b6 00             	movzbl (%eax),%eax
801099aa:	0f b6 d0             	movzbl %al,%edx
801099ad:	8b 45 08             	mov    0x8(%ebp),%eax
801099b0:	0f b6 00             	movzbl (%eax),%eax
801099b3:	0f b6 c0             	movzbl %al,%eax
801099b6:	83 ec 0c             	sub    $0xc,%esp
801099b9:	53                   	push   %ebx
801099ba:	51                   	push   %ecx
801099bb:	52                   	push   %edx
801099bc:	50                   	push   %eax
801099bd:	68 0c c6 10 80       	push   $0x8010c60c
801099c2:	e8 45 6a ff ff       	call   8010040c <cprintf>
801099c7:	83 c4 20             	add    $0x20,%esp
}
801099ca:	90                   	nop
801099cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801099ce:	c9                   	leave  
801099cf:	c3                   	ret    

801099d0 <print_mac>:

void print_mac(uchar *mac){
801099d0:	f3 0f 1e fb          	endbr32 
801099d4:	55                   	push   %ebp
801099d5:	89 e5                	mov    %esp,%ebp
801099d7:	57                   	push   %edi
801099d8:	56                   	push   %esi
801099d9:	53                   	push   %ebx
801099da:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
801099dd:	8b 45 08             	mov    0x8(%ebp),%eax
801099e0:	83 c0 05             	add    $0x5,%eax
801099e3:	0f b6 00             	movzbl (%eax),%eax
801099e6:	0f b6 f8             	movzbl %al,%edi
801099e9:	8b 45 08             	mov    0x8(%ebp),%eax
801099ec:	83 c0 04             	add    $0x4,%eax
801099ef:	0f b6 00             	movzbl (%eax),%eax
801099f2:	0f b6 f0             	movzbl %al,%esi
801099f5:	8b 45 08             	mov    0x8(%ebp),%eax
801099f8:	83 c0 03             	add    $0x3,%eax
801099fb:	0f b6 00             	movzbl (%eax),%eax
801099fe:	0f b6 d8             	movzbl %al,%ebx
80109a01:	8b 45 08             	mov    0x8(%ebp),%eax
80109a04:	83 c0 02             	add    $0x2,%eax
80109a07:	0f b6 00             	movzbl (%eax),%eax
80109a0a:	0f b6 c8             	movzbl %al,%ecx
80109a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80109a10:	83 c0 01             	add    $0x1,%eax
80109a13:	0f b6 00             	movzbl (%eax),%eax
80109a16:	0f b6 d0             	movzbl %al,%edx
80109a19:	8b 45 08             	mov    0x8(%ebp),%eax
80109a1c:	0f b6 00             	movzbl (%eax),%eax
80109a1f:	0f b6 c0             	movzbl %al,%eax
80109a22:	83 ec 04             	sub    $0x4,%esp
80109a25:	57                   	push   %edi
80109a26:	56                   	push   %esi
80109a27:	53                   	push   %ebx
80109a28:	51                   	push   %ecx
80109a29:	52                   	push   %edx
80109a2a:	50                   	push   %eax
80109a2b:	68 24 c6 10 80       	push   $0x8010c624
80109a30:	e8 d7 69 ff ff       	call   8010040c <cprintf>
80109a35:	83 c4 20             	add    $0x20,%esp
}
80109a38:	90                   	nop
80109a39:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109a3c:	5b                   	pop    %ebx
80109a3d:	5e                   	pop    %esi
80109a3e:	5f                   	pop    %edi
80109a3f:	5d                   	pop    %ebp
80109a40:	c3                   	ret    

80109a41 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109a41:	f3 0f 1e fb          	endbr32 
80109a45:	55                   	push   %ebp
80109a46:	89 e5                	mov    %esp,%ebp
80109a48:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109a4b:	8b 45 08             	mov    0x8(%ebp),%eax
80109a4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109a51:	8b 45 08             	mov    0x8(%ebp),%eax
80109a54:	83 c0 0e             	add    $0xe,%eax
80109a57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a5d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109a61:	3c 08                	cmp    $0x8,%al
80109a63:	75 1b                	jne    80109a80 <eth_proc+0x3f>
80109a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a68:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a6c:	3c 06                	cmp    $0x6,%al
80109a6e:	75 10                	jne    80109a80 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109a70:	83 ec 0c             	sub    $0xc,%esp
80109a73:	ff 75 f0             	pushl  -0x10(%ebp)
80109a76:	e8 d5 f7 ff ff       	call   80109250 <arp_proc>
80109a7b:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109a7e:	eb 24                	jmp    80109aa4 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a83:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109a87:	3c 08                	cmp    $0x8,%al
80109a89:	75 19                	jne    80109aa4 <eth_proc+0x63>
80109a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a8e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a92:	84 c0                	test   %al,%al
80109a94:	75 0e                	jne    80109aa4 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109a96:	83 ec 0c             	sub    $0xc,%esp
80109a99:	ff 75 08             	pushl  0x8(%ebp)
80109a9c:	e8 b3 00 00 00       	call   80109b54 <ipv4_proc>
80109aa1:	83 c4 10             	add    $0x10,%esp
}
80109aa4:	90                   	nop
80109aa5:	c9                   	leave  
80109aa6:	c3                   	ret    

80109aa7 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109aa7:	f3 0f 1e fb          	endbr32 
80109aab:	55                   	push   %ebp
80109aac:	89 e5                	mov    %esp,%ebp
80109aae:	83 ec 04             	sub    $0x4,%esp
80109ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ab4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109ab8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109abc:	c1 e0 08             	shl    $0x8,%eax
80109abf:	89 c2                	mov    %eax,%edx
80109ac1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ac5:	66 c1 e8 08          	shr    $0x8,%ax
80109ac9:	01 d0                	add    %edx,%eax
}
80109acb:	c9                   	leave  
80109acc:	c3                   	ret    

80109acd <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109acd:	f3 0f 1e fb          	endbr32 
80109ad1:	55                   	push   %ebp
80109ad2:	89 e5                	mov    %esp,%ebp
80109ad4:	83 ec 04             	sub    $0x4,%esp
80109ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80109ada:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109ade:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109ae2:	c1 e0 08             	shl    $0x8,%eax
80109ae5:	89 c2                	mov    %eax,%edx
80109ae7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109aeb:	66 c1 e8 08          	shr    $0x8,%ax
80109aef:	01 d0                	add    %edx,%eax
}
80109af1:	c9                   	leave  
80109af2:	c3                   	ret    

80109af3 <H2N_uint>:

uint H2N_uint(uint value){
80109af3:	f3 0f 1e fb          	endbr32 
80109af7:	55                   	push   %ebp
80109af8:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109afa:	8b 45 08             	mov    0x8(%ebp),%eax
80109afd:	c1 e0 18             	shl    $0x18,%eax
80109b00:	25 00 00 00 0f       	and    $0xf000000,%eax
80109b05:	89 c2                	mov    %eax,%edx
80109b07:	8b 45 08             	mov    0x8(%ebp),%eax
80109b0a:	c1 e0 08             	shl    $0x8,%eax
80109b0d:	25 00 f0 00 00       	and    $0xf000,%eax
80109b12:	09 c2                	or     %eax,%edx
80109b14:	8b 45 08             	mov    0x8(%ebp),%eax
80109b17:	c1 e8 08             	shr    $0x8,%eax
80109b1a:	83 e0 0f             	and    $0xf,%eax
80109b1d:	01 d0                	add    %edx,%eax
}
80109b1f:	5d                   	pop    %ebp
80109b20:	c3                   	ret    

80109b21 <N2H_uint>:

uint N2H_uint(uint value){
80109b21:	f3 0f 1e fb          	endbr32 
80109b25:	55                   	push   %ebp
80109b26:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109b28:	8b 45 08             	mov    0x8(%ebp),%eax
80109b2b:	c1 e0 18             	shl    $0x18,%eax
80109b2e:	89 c2                	mov    %eax,%edx
80109b30:	8b 45 08             	mov    0x8(%ebp),%eax
80109b33:	c1 e0 08             	shl    $0x8,%eax
80109b36:	25 00 00 ff 00       	and    $0xff0000,%eax
80109b3b:	01 c2                	add    %eax,%edx
80109b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80109b40:	c1 e8 08             	shr    $0x8,%eax
80109b43:	25 00 ff 00 00       	and    $0xff00,%eax
80109b48:	01 c2                	add    %eax,%edx
80109b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4d:	c1 e8 18             	shr    $0x18,%eax
80109b50:	01 d0                	add    %edx,%eax
}
80109b52:	5d                   	pop    %ebp
80109b53:	c3                   	ret    

80109b54 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109b54:	f3 0f 1e fb          	endbr32 
80109b58:	55                   	push   %ebp
80109b59:	89 e5                	mov    %esp,%ebp
80109b5b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b61:	83 c0 0e             	add    $0xe,%eax
80109b64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b6a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b6e:	0f b7 d0             	movzwl %ax,%edx
80109b71:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109b76:	39 c2                	cmp    %eax,%edx
80109b78:	74 60                	je     80109bda <ipv4_proc+0x86>
80109b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b7d:	83 c0 0c             	add    $0xc,%eax
80109b80:	83 ec 04             	sub    $0x4,%esp
80109b83:	6a 04                	push   $0x4
80109b85:	50                   	push   %eax
80109b86:	68 04 f5 10 80       	push   $0x8010f504
80109b8b:	e8 f6 b2 ff ff       	call   80104e86 <memcmp>
80109b90:	83 c4 10             	add    $0x10,%esp
80109b93:	85 c0                	test   %eax,%eax
80109b95:	74 43                	je     80109bda <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b9a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b9e:	0f b7 c0             	movzwl %ax,%eax
80109ba1:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ba9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109bad:	3c 01                	cmp    $0x1,%al
80109baf:	75 10                	jne    80109bc1 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109bb1:	83 ec 0c             	sub    $0xc,%esp
80109bb4:	ff 75 08             	pushl  0x8(%ebp)
80109bb7:	e8 a7 00 00 00       	call   80109c63 <icmp_proc>
80109bbc:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109bbf:	eb 19                	jmp    80109bda <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bc4:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109bc8:	3c 06                	cmp    $0x6,%al
80109bca:	75 0e                	jne    80109bda <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109bcc:	83 ec 0c             	sub    $0xc,%esp
80109bcf:	ff 75 08             	pushl  0x8(%ebp)
80109bd2:	e8 c7 03 00 00       	call   80109f9e <tcp_proc>
80109bd7:	83 c4 10             	add    $0x10,%esp
}
80109bda:	90                   	nop
80109bdb:	c9                   	leave  
80109bdc:	c3                   	ret    

80109bdd <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109bdd:	f3 0f 1e fb          	endbr32 
80109be1:	55                   	push   %ebp
80109be2:	89 e5                	mov    %esp,%ebp
80109be4:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109be7:	8b 45 08             	mov    0x8(%ebp),%eax
80109bea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bf0:	0f b6 00             	movzbl (%eax),%eax
80109bf3:	83 e0 0f             	and    $0xf,%eax
80109bf6:	01 c0                	add    %eax,%eax
80109bf8:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109bfb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c02:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109c09:	eb 48                	jmp    80109c53 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109c0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c0e:	01 c0                	add    %eax,%eax
80109c10:	89 c2                	mov    %eax,%edx
80109c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c15:	01 d0                	add    %edx,%eax
80109c17:	0f b6 00             	movzbl (%eax),%eax
80109c1a:	0f b6 c0             	movzbl %al,%eax
80109c1d:	c1 e0 08             	shl    $0x8,%eax
80109c20:	89 c2                	mov    %eax,%edx
80109c22:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109c25:	01 c0                	add    %eax,%eax
80109c27:	8d 48 01             	lea    0x1(%eax),%ecx
80109c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c2d:	01 c8                	add    %ecx,%eax
80109c2f:	0f b6 00             	movzbl (%eax),%eax
80109c32:	0f b6 c0             	movzbl %al,%eax
80109c35:	01 d0                	add    %edx,%eax
80109c37:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109c3a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109c41:	76 0c                	jbe    80109c4f <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109c43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c46:	0f b7 c0             	movzwl %ax,%eax
80109c49:	83 c0 01             	add    $0x1,%eax
80109c4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109c4f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109c53:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109c57:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109c5a:	7c af                	jl     80109c0b <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109c5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109c5f:	f7 d0                	not    %eax
}
80109c61:	c9                   	leave  
80109c62:	c3                   	ret    

80109c63 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109c63:	f3 0f 1e fb          	endbr32 
80109c67:	55                   	push   %ebp
80109c68:	89 e5                	mov    %esp,%ebp
80109c6a:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80109c70:	83 c0 0e             	add    $0xe,%eax
80109c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c79:	0f b6 00             	movzbl (%eax),%eax
80109c7c:	0f b6 c0             	movzbl %al,%eax
80109c7f:	83 e0 0f             	and    $0xf,%eax
80109c82:	c1 e0 02             	shl    $0x2,%eax
80109c85:	89 c2                	mov    %eax,%edx
80109c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c8a:	01 d0                	add    %edx,%eax
80109c8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c92:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109c96:	84 c0                	test   %al,%al
80109c98:	75 4f                	jne    80109ce9 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c9d:	0f b6 00             	movzbl (%eax),%eax
80109ca0:	3c 08                	cmp    $0x8,%al
80109ca2:	75 45                	jne    80109ce9 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109ca4:	e8 e9 8b ff ff       	call   80102892 <kalloc>
80109ca9:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109cac:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109cb3:	83 ec 04             	sub    $0x4,%esp
80109cb6:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109cb9:	50                   	push   %eax
80109cba:	ff 75 ec             	pushl  -0x14(%ebp)
80109cbd:	ff 75 08             	pushl  0x8(%ebp)
80109cc0:	e8 7c 00 00 00       	call   80109d41 <icmp_reply_pkt_create>
80109cc5:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109cc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ccb:	83 ec 08             	sub    $0x8,%esp
80109cce:	50                   	push   %eax
80109ccf:	ff 75 ec             	pushl  -0x14(%ebp)
80109cd2:	e8 43 f4 ff ff       	call   8010911a <i8254_send>
80109cd7:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109cda:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cdd:	83 ec 0c             	sub    $0xc,%esp
80109ce0:	50                   	push   %eax
80109ce1:	e8 0e 8b ff ff       	call   801027f4 <kfree>
80109ce6:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109ce9:	90                   	nop
80109cea:	c9                   	leave  
80109ceb:	c3                   	ret    

80109cec <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109cec:	f3 0f 1e fb          	endbr32 
80109cf0:	55                   	push   %ebp
80109cf1:	89 e5                	mov    %esp,%ebp
80109cf3:	53                   	push   %ebx
80109cf4:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80109cfa:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109cfe:	0f b7 c0             	movzwl %ax,%eax
80109d01:	83 ec 0c             	sub    $0xc,%esp
80109d04:	50                   	push   %eax
80109d05:	e8 9d fd ff ff       	call   80109aa7 <N2H_ushort>
80109d0a:	83 c4 10             	add    $0x10,%esp
80109d0d:	0f b7 d8             	movzwl %ax,%ebx
80109d10:	8b 45 08             	mov    0x8(%ebp),%eax
80109d13:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109d17:	0f b7 c0             	movzwl %ax,%eax
80109d1a:	83 ec 0c             	sub    $0xc,%esp
80109d1d:	50                   	push   %eax
80109d1e:	e8 84 fd ff ff       	call   80109aa7 <N2H_ushort>
80109d23:	83 c4 10             	add    $0x10,%esp
80109d26:	0f b7 c0             	movzwl %ax,%eax
80109d29:	83 ec 04             	sub    $0x4,%esp
80109d2c:	53                   	push   %ebx
80109d2d:	50                   	push   %eax
80109d2e:	68 43 c6 10 80       	push   $0x8010c643
80109d33:	e8 d4 66 ff ff       	call   8010040c <cprintf>
80109d38:	83 c4 10             	add    $0x10,%esp
}
80109d3b:	90                   	nop
80109d3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109d3f:	c9                   	leave  
80109d40:	c3                   	ret    

80109d41 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109d41:	f3 0f 1e fb          	endbr32 
80109d45:	55                   	push   %ebp
80109d46:	89 e5                	mov    %esp,%ebp
80109d48:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80109d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109d51:	8b 45 08             	mov    0x8(%ebp),%eax
80109d54:	83 c0 0e             	add    $0xe,%eax
80109d57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d5d:	0f b6 00             	movzbl (%eax),%eax
80109d60:	0f b6 c0             	movzbl %al,%eax
80109d63:	83 e0 0f             	and    $0xf,%eax
80109d66:	c1 e0 02             	shl    $0x2,%eax
80109d69:	89 c2                	mov    %eax,%edx
80109d6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d6e:	01 d0                	add    %edx,%eax
80109d70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109d73:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d76:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109d79:	8b 45 0c             	mov    0xc(%ebp),%eax
80109d7c:	83 c0 0e             	add    $0xe,%eax
80109d7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d85:	83 c0 14             	add    $0x14,%eax
80109d88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109d8b:	8b 45 10             	mov    0x10(%ebp),%eax
80109d8e:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d97:	8d 50 06             	lea    0x6(%eax),%edx
80109d9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d9d:	83 ec 04             	sub    $0x4,%esp
80109da0:	6a 06                	push   $0x6
80109da2:	52                   	push   %edx
80109da3:	50                   	push   %eax
80109da4:	e8 39 b1 ff ff       	call   80104ee2 <memmove>
80109da9:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109dac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109daf:	83 c0 06             	add    $0x6,%eax
80109db2:	83 ec 04             	sub    $0x4,%esp
80109db5:	6a 06                	push   $0x6
80109db7:	68 68 d0 18 80       	push   $0x8018d068
80109dbc:	50                   	push   %eax
80109dbd:	e8 20 b1 ff ff       	call   80104ee2 <memmove>
80109dc2:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dc8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109dcc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109dcf:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dd6:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109dd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ddc:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109de0:	83 ec 0c             	sub    $0xc,%esp
80109de3:	6a 54                	push   $0x54
80109de5:	e8 e3 fc ff ff       	call   80109acd <H2N_ushort>
80109dea:	83 c4 10             	add    $0x10,%esp
80109ded:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109df0:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109df4:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109dfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109dfe:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109e02:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109e09:	83 c0 01             	add    $0x1,%eax
80109e0c:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109e12:	83 ec 0c             	sub    $0xc,%esp
80109e15:	68 00 40 00 00       	push   $0x4000
80109e1a:	e8 ae fc ff ff       	call   80109acd <H2N_ushort>
80109e1f:	83 c4 10             	add    $0x10,%esp
80109e22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e25:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109e29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e2c:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e33:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e3a:	83 c0 0c             	add    $0xc,%eax
80109e3d:	83 ec 04             	sub    $0x4,%esp
80109e40:	6a 04                	push   $0x4
80109e42:	68 04 f5 10 80       	push   $0x8010f504
80109e47:	50                   	push   %eax
80109e48:	e8 95 b0 ff ff       	call   80104ee2 <memmove>
80109e4d:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e53:	8d 50 0c             	lea    0xc(%eax),%edx
80109e56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e59:	83 c0 10             	add    $0x10,%eax
80109e5c:	83 ec 04             	sub    $0x4,%esp
80109e5f:	6a 04                	push   $0x4
80109e61:	52                   	push   %edx
80109e62:	50                   	push   %eax
80109e63:	e8 7a b0 ff ff       	call   80104ee2 <memmove>
80109e68:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109e6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e6e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109e77:	83 ec 0c             	sub    $0xc,%esp
80109e7a:	50                   	push   %eax
80109e7b:	e8 5d fd ff ff       	call   80109bdd <ipv4_chksum>
80109e80:	83 c4 10             	add    $0x10,%esp
80109e83:	0f b7 c0             	movzwl %ax,%eax
80109e86:	83 ec 0c             	sub    $0xc,%esp
80109e89:	50                   	push   %eax
80109e8a:	e8 3e fc ff ff       	call   80109acd <H2N_ushort>
80109e8f:	83 c4 10             	add    $0x10,%esp
80109e92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109e95:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109e99:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e9c:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109e9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ea2:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109ea6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ea9:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109ead:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109eb0:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109eb7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109ebb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ebe:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109ec2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ec5:	8d 50 08             	lea    0x8(%eax),%edx
80109ec8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ecb:	83 c0 08             	add    $0x8,%eax
80109ece:	83 ec 04             	sub    $0x4,%esp
80109ed1:	6a 08                	push   $0x8
80109ed3:	52                   	push   %edx
80109ed4:	50                   	push   %eax
80109ed5:	e8 08 b0 ff ff       	call   80104ee2 <memmove>
80109eda:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ee0:	8d 50 10             	lea    0x10(%eax),%edx
80109ee3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ee6:	83 c0 10             	add    $0x10,%eax
80109ee9:	83 ec 04             	sub    $0x4,%esp
80109eec:	6a 30                	push   $0x30
80109eee:	52                   	push   %edx
80109eef:	50                   	push   %eax
80109ef0:	e8 ed af ff ff       	call   80104ee2 <memmove>
80109ef5:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109ef8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109efb:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109f01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109f04:	83 ec 0c             	sub    $0xc,%esp
80109f07:	50                   	push   %eax
80109f08:	e8 1c 00 00 00       	call   80109f29 <icmp_chksum>
80109f0d:	83 c4 10             	add    $0x10,%esp
80109f10:	0f b7 c0             	movzwl %ax,%eax
80109f13:	83 ec 0c             	sub    $0xc,%esp
80109f16:	50                   	push   %eax
80109f17:	e8 b1 fb ff ff       	call   80109acd <H2N_ushort>
80109f1c:	83 c4 10             	add    $0x10,%esp
80109f1f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109f22:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109f26:	90                   	nop
80109f27:	c9                   	leave  
80109f28:	c3                   	ret    

80109f29 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109f29:	f3 0f 1e fb          	endbr32 
80109f2d:	55                   	push   %ebp
80109f2e:	89 e5                	mov    %esp,%ebp
80109f30:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109f33:	8b 45 08             	mov    0x8(%ebp),%eax
80109f36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109f39:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109f40:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109f47:	eb 48                	jmp    80109f91 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109f49:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f4c:	01 c0                	add    %eax,%eax
80109f4e:	89 c2                	mov    %eax,%edx
80109f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f53:	01 d0                	add    %edx,%eax
80109f55:	0f b6 00             	movzbl (%eax),%eax
80109f58:	0f b6 c0             	movzbl %al,%eax
80109f5b:	c1 e0 08             	shl    $0x8,%eax
80109f5e:	89 c2                	mov    %eax,%edx
80109f60:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109f63:	01 c0                	add    %eax,%eax
80109f65:	8d 48 01             	lea    0x1(%eax),%ecx
80109f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f6b:	01 c8                	add    %ecx,%eax
80109f6d:	0f b6 00             	movzbl (%eax),%eax
80109f70:	0f b6 c0             	movzbl %al,%eax
80109f73:	01 d0                	add    %edx,%eax
80109f75:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109f78:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109f7f:	76 0c                	jbe    80109f8d <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
80109f81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f84:	0f b7 c0             	movzwl %ax,%eax
80109f87:	83 c0 01             	add    $0x1,%eax
80109f8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109f8d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109f91:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109f95:	7e b2                	jle    80109f49 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
80109f97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f9a:	f7 d0                	not    %eax
}
80109f9c:	c9                   	leave  
80109f9d:	c3                   	ret    

80109f9e <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109f9e:	f3 0f 1e fb          	endbr32 
80109fa2:	55                   	push   %ebp
80109fa3:	89 e5                	mov    %esp,%ebp
80109fa5:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109fa8:	8b 45 08             	mov    0x8(%ebp),%eax
80109fab:	83 c0 0e             	add    $0xe,%eax
80109fae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fb4:	0f b6 00             	movzbl (%eax),%eax
80109fb7:	0f b6 c0             	movzbl %al,%eax
80109fba:	83 e0 0f             	and    $0xf,%eax
80109fbd:	c1 e0 02             	shl    $0x2,%eax
80109fc0:	89 c2                	mov    %eax,%edx
80109fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109fc5:	01 d0                	add    %edx,%eax
80109fc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fcd:	83 c0 14             	add    $0x14,%eax
80109fd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109fd3:	e8 ba 88 ff ff       	call   80102892 <kalloc>
80109fd8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109fdb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fe5:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109fe9:	0f b6 c0             	movzbl %al,%eax
80109fec:	83 e0 02             	and    $0x2,%eax
80109fef:	85 c0                	test   %eax,%eax
80109ff1:	74 3d                	je     8010a030 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109ff3:	83 ec 0c             	sub    $0xc,%esp
80109ff6:	6a 00                	push   $0x0
80109ff8:	6a 12                	push   $0x12
80109ffa:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ffd:	50                   	push   %eax
80109ffe:	ff 75 e8             	pushl  -0x18(%ebp)
8010a001:	ff 75 08             	pushl  0x8(%ebp)
8010a004:	e8 a2 01 00 00       	call   8010a1ab <tcp_pkt_create>
8010a009:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a00c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a00f:	83 ec 08             	sub    $0x8,%esp
8010a012:	50                   	push   %eax
8010a013:	ff 75 e8             	pushl  -0x18(%ebp)
8010a016:	e8 ff f0 ff ff       	call   8010911a <i8254_send>
8010a01b:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a01e:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a023:	83 c0 01             	add    $0x1,%eax
8010a026:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a02b:	e9 69 01 00 00       	jmp    8010a199 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a030:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a033:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a037:	3c 18                	cmp    $0x18,%al
8010a039:	0f 85 10 01 00 00    	jne    8010a14f <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a03f:	83 ec 04             	sub    $0x4,%esp
8010a042:	6a 03                	push   $0x3
8010a044:	68 5e c6 10 80       	push   $0x8010c65e
8010a049:	ff 75 ec             	pushl  -0x14(%ebp)
8010a04c:	e8 35 ae ff ff       	call   80104e86 <memcmp>
8010a051:	83 c4 10             	add    $0x10,%esp
8010a054:	85 c0                	test   %eax,%eax
8010a056:	74 74                	je     8010a0cc <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a058:	83 ec 0c             	sub    $0xc,%esp
8010a05b:	68 62 c6 10 80       	push   $0x8010c662
8010a060:	e8 a7 63 ff ff       	call   8010040c <cprintf>
8010a065:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a068:	83 ec 0c             	sub    $0xc,%esp
8010a06b:	6a 00                	push   $0x0
8010a06d:	6a 10                	push   $0x10
8010a06f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a072:	50                   	push   %eax
8010a073:	ff 75 e8             	pushl  -0x18(%ebp)
8010a076:	ff 75 08             	pushl  0x8(%ebp)
8010a079:	e8 2d 01 00 00       	call   8010a1ab <tcp_pkt_create>
8010a07e:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a081:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a084:	83 ec 08             	sub    $0x8,%esp
8010a087:	50                   	push   %eax
8010a088:	ff 75 e8             	pushl  -0x18(%ebp)
8010a08b:	e8 8a f0 ff ff       	call   8010911a <i8254_send>
8010a090:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a093:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a096:	83 c0 36             	add    $0x36,%eax
8010a099:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a09c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a09f:	50                   	push   %eax
8010a0a0:	ff 75 e0             	pushl  -0x20(%ebp)
8010a0a3:	6a 00                	push   $0x0
8010a0a5:	6a 00                	push   $0x0
8010a0a7:	e8 66 04 00 00       	call   8010a512 <http_proc>
8010a0ac:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a0af:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a0b2:	83 ec 0c             	sub    $0xc,%esp
8010a0b5:	50                   	push   %eax
8010a0b6:	6a 18                	push   $0x18
8010a0b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0bb:	50                   	push   %eax
8010a0bc:	ff 75 e8             	pushl  -0x18(%ebp)
8010a0bf:	ff 75 08             	pushl  0x8(%ebp)
8010a0c2:	e8 e4 00 00 00       	call   8010a1ab <tcp_pkt_create>
8010a0c7:	83 c4 20             	add    $0x20,%esp
8010a0ca:	eb 62                	jmp    8010a12e <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a0cc:	83 ec 0c             	sub    $0xc,%esp
8010a0cf:	6a 00                	push   $0x0
8010a0d1:	6a 10                	push   $0x10
8010a0d3:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a0d6:	50                   	push   %eax
8010a0d7:	ff 75 e8             	pushl  -0x18(%ebp)
8010a0da:	ff 75 08             	pushl  0x8(%ebp)
8010a0dd:	e8 c9 00 00 00       	call   8010a1ab <tcp_pkt_create>
8010a0e2:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a0e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a0e8:	83 ec 08             	sub    $0x8,%esp
8010a0eb:	50                   	push   %eax
8010a0ec:	ff 75 e8             	pushl  -0x18(%ebp)
8010a0ef:	e8 26 f0 ff ff       	call   8010911a <i8254_send>
8010a0f4:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a0f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a0fa:	83 c0 36             	add    $0x36,%eax
8010a0fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a100:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a103:	50                   	push   %eax
8010a104:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a107:	6a 00                	push   $0x0
8010a109:	6a 00                	push   $0x0
8010a10b:	e8 02 04 00 00       	call   8010a512 <http_proc>
8010a110:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a113:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a116:	83 ec 0c             	sub    $0xc,%esp
8010a119:	50                   	push   %eax
8010a11a:	6a 18                	push   $0x18
8010a11c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a11f:	50                   	push   %eax
8010a120:	ff 75 e8             	pushl  -0x18(%ebp)
8010a123:	ff 75 08             	pushl  0x8(%ebp)
8010a126:	e8 80 00 00 00       	call   8010a1ab <tcp_pkt_create>
8010a12b:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a12e:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a131:	83 ec 08             	sub    $0x8,%esp
8010a134:	50                   	push   %eax
8010a135:	ff 75 e8             	pushl  -0x18(%ebp)
8010a138:	e8 dd ef ff ff       	call   8010911a <i8254_send>
8010a13d:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a140:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a145:	83 c0 01             	add    $0x1,%eax
8010a148:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a14d:	eb 4a                	jmp    8010a199 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a14f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a152:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a156:	3c 10                	cmp    $0x10,%al
8010a158:	75 3f                	jne    8010a199 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a15a:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a15f:	83 f8 01             	cmp    $0x1,%eax
8010a162:	75 35                	jne    8010a199 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a164:	83 ec 0c             	sub    $0xc,%esp
8010a167:	6a 00                	push   $0x0
8010a169:	6a 01                	push   $0x1
8010a16b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a16e:	50                   	push   %eax
8010a16f:	ff 75 e8             	pushl  -0x18(%ebp)
8010a172:	ff 75 08             	pushl  0x8(%ebp)
8010a175:	e8 31 00 00 00       	call   8010a1ab <tcp_pkt_create>
8010a17a:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a17d:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a180:	83 ec 08             	sub    $0x8,%esp
8010a183:	50                   	push   %eax
8010a184:	ff 75 e8             	pushl  -0x18(%ebp)
8010a187:	e8 8e ef ff ff       	call   8010911a <i8254_send>
8010a18c:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a18f:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a196:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a199:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a19c:	83 ec 0c             	sub    $0xc,%esp
8010a19f:	50                   	push   %eax
8010a1a0:	e8 4f 86 ff ff       	call   801027f4 <kfree>
8010a1a5:	83 c4 10             	add    $0x10,%esp
}
8010a1a8:	90                   	nop
8010a1a9:	c9                   	leave  
8010a1aa:	c3                   	ret    

8010a1ab <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a1ab:	f3 0f 1e fb          	endbr32 
8010a1af:	55                   	push   %ebp
8010a1b0:	89 e5                	mov    %esp,%ebp
8010a1b2:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a1b5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a1bb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1be:	83 c0 0e             	add    $0xe,%eax
8010a1c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a1c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1c7:	0f b6 00             	movzbl (%eax),%eax
8010a1ca:	0f b6 c0             	movzbl %al,%eax
8010a1cd:	83 e0 0f             	and    $0xf,%eax
8010a1d0:	c1 e0 02             	shl    $0x2,%eax
8010a1d3:	89 c2                	mov    %eax,%edx
8010a1d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1d8:	01 d0                	add    %edx,%eax
8010a1da:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a1dd:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a1e3:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1e6:	83 c0 0e             	add    $0xe,%eax
8010a1e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a1ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1ef:	83 c0 14             	add    $0x14,%eax
8010a1f2:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a1f5:	8b 45 18             	mov    0x18(%ebp),%eax
8010a1f8:	8d 50 36             	lea    0x36(%eax),%edx
8010a1fb:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1fe:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a200:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a203:	8d 50 06             	lea    0x6(%eax),%edx
8010a206:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a209:	83 ec 04             	sub    $0x4,%esp
8010a20c:	6a 06                	push   $0x6
8010a20e:	52                   	push   %edx
8010a20f:	50                   	push   %eax
8010a210:	e8 cd ac ff ff       	call   80104ee2 <memmove>
8010a215:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a218:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a21b:	83 c0 06             	add    $0x6,%eax
8010a21e:	83 ec 04             	sub    $0x4,%esp
8010a221:	6a 06                	push   $0x6
8010a223:	68 68 d0 18 80       	push   $0x8018d068
8010a228:	50                   	push   %eax
8010a229:	e8 b4 ac ff ff       	call   80104ee2 <memmove>
8010a22e:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a231:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a234:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a238:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a23b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a23f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a242:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a245:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a248:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a24c:	8b 45 18             	mov    0x18(%ebp),%eax
8010a24f:	83 c0 28             	add    $0x28,%eax
8010a252:	0f b7 c0             	movzwl %ax,%eax
8010a255:	83 ec 0c             	sub    $0xc,%esp
8010a258:	50                   	push   %eax
8010a259:	e8 6f f8 ff ff       	call   80109acd <H2N_ushort>
8010a25e:	83 c4 10             	add    $0x10,%esp
8010a261:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a264:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a268:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a26f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a272:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a276:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a27d:	83 c0 01             	add    $0x1,%eax
8010a280:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a286:	83 ec 0c             	sub    $0xc,%esp
8010a289:	6a 00                	push   $0x0
8010a28b:	e8 3d f8 ff ff       	call   80109acd <H2N_ushort>
8010a290:	83 c4 10             	add    $0x10,%esp
8010a293:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a296:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a29a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a29d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a2a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2a4:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a2a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2ab:	83 c0 0c             	add    $0xc,%eax
8010a2ae:	83 ec 04             	sub    $0x4,%esp
8010a2b1:	6a 04                	push   $0x4
8010a2b3:	68 04 f5 10 80       	push   $0x8010f504
8010a2b8:	50                   	push   %eax
8010a2b9:	e8 24 ac ff ff       	call   80104ee2 <memmove>
8010a2be:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a2c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2c4:	8d 50 0c             	lea    0xc(%eax),%edx
8010a2c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2ca:	83 c0 10             	add    $0x10,%eax
8010a2cd:	83 ec 04             	sub    $0x4,%esp
8010a2d0:	6a 04                	push   $0x4
8010a2d2:	52                   	push   %edx
8010a2d3:	50                   	push   %eax
8010a2d4:	e8 09 ac ff ff       	call   80104ee2 <memmove>
8010a2d9:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a2dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2df:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a2e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2e8:	83 ec 0c             	sub    $0xc,%esp
8010a2eb:	50                   	push   %eax
8010a2ec:	e8 ec f8 ff ff       	call   80109bdd <ipv4_chksum>
8010a2f1:	83 c4 10             	add    $0x10,%esp
8010a2f4:	0f b7 c0             	movzwl %ax,%eax
8010a2f7:	83 ec 0c             	sub    $0xc,%esp
8010a2fa:	50                   	push   %eax
8010a2fb:	e8 cd f7 ff ff       	call   80109acd <H2N_ushort>
8010a300:	83 c4 10             	add    $0x10,%esp
8010a303:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a306:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a30a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a30d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a311:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a314:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a317:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a31a:	0f b7 10             	movzwl (%eax),%edx
8010a31d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a320:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a324:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a329:	83 ec 0c             	sub    $0xc,%esp
8010a32c:	50                   	push   %eax
8010a32d:	e8 c1 f7 ff ff       	call   80109af3 <H2N_uint>
8010a332:	83 c4 10             	add    $0x10,%esp
8010a335:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a338:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a33b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a33e:	8b 40 04             	mov    0x4(%eax),%eax
8010a341:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a347:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a34a:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a34d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a350:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a354:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a357:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a35b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a35e:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a362:	8b 45 14             	mov    0x14(%ebp),%eax
8010a365:	89 c2                	mov    %eax,%edx
8010a367:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a36a:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a36d:	83 ec 0c             	sub    $0xc,%esp
8010a370:	68 90 38 00 00       	push   $0x3890
8010a375:	e8 53 f7 ff ff       	call   80109acd <H2N_ushort>
8010a37a:	83 c4 10             	add    $0x10,%esp
8010a37d:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a380:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a384:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a387:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a38d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a390:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a396:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a399:	83 ec 0c             	sub    $0xc,%esp
8010a39c:	50                   	push   %eax
8010a39d:	e8 1f 00 00 00       	call   8010a3c1 <tcp_chksum>
8010a3a2:	83 c4 10             	add    $0x10,%esp
8010a3a5:	83 c0 08             	add    $0x8,%eax
8010a3a8:	0f b7 c0             	movzwl %ax,%eax
8010a3ab:	83 ec 0c             	sub    $0xc,%esp
8010a3ae:	50                   	push   %eax
8010a3af:	e8 19 f7 ff ff       	call   80109acd <H2N_ushort>
8010a3b4:	83 c4 10             	add    $0x10,%esp
8010a3b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a3ba:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a3be:	90                   	nop
8010a3bf:	c9                   	leave  
8010a3c0:	c3                   	ret    

8010a3c1 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a3c1:	f3 0f 1e fb          	endbr32 
8010a3c5:	55                   	push   %ebp
8010a3c6:	89 e5                	mov    %esp,%ebp
8010a3c8:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a3cb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a3d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3d4:	83 c0 14             	add    $0x14,%eax
8010a3d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a3da:	83 ec 04             	sub    $0x4,%esp
8010a3dd:	6a 04                	push   $0x4
8010a3df:	68 04 f5 10 80       	push   $0x8010f504
8010a3e4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a3e7:	50                   	push   %eax
8010a3e8:	e8 f5 aa ff ff       	call   80104ee2 <memmove>
8010a3ed:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a3f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3f3:	83 c0 0c             	add    $0xc,%eax
8010a3f6:	83 ec 04             	sub    $0x4,%esp
8010a3f9:	6a 04                	push   $0x4
8010a3fb:	50                   	push   %eax
8010a3fc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a3ff:	83 c0 04             	add    $0x4,%eax
8010a402:	50                   	push   %eax
8010a403:	e8 da aa ff ff       	call   80104ee2 <memmove>
8010a408:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a40b:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a40f:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a413:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a416:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a41a:	0f b7 c0             	movzwl %ax,%eax
8010a41d:	83 ec 0c             	sub    $0xc,%esp
8010a420:	50                   	push   %eax
8010a421:	e8 81 f6 ff ff       	call   80109aa7 <N2H_ushort>
8010a426:	83 c4 10             	add    $0x10,%esp
8010a429:	83 e8 14             	sub    $0x14,%eax
8010a42c:	0f b7 c0             	movzwl %ax,%eax
8010a42f:	83 ec 0c             	sub    $0xc,%esp
8010a432:	50                   	push   %eax
8010a433:	e8 95 f6 ff ff       	call   80109acd <H2N_ushort>
8010a438:	83 c4 10             	add    $0x10,%esp
8010a43b:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a43f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a446:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a44c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a453:	eb 33                	jmp    8010a488 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a455:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a458:	01 c0                	add    %eax,%eax
8010a45a:	89 c2                	mov    %eax,%edx
8010a45c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a45f:	01 d0                	add    %edx,%eax
8010a461:	0f b6 00             	movzbl (%eax),%eax
8010a464:	0f b6 c0             	movzbl %al,%eax
8010a467:	c1 e0 08             	shl    $0x8,%eax
8010a46a:	89 c2                	mov    %eax,%edx
8010a46c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a46f:	01 c0                	add    %eax,%eax
8010a471:	8d 48 01             	lea    0x1(%eax),%ecx
8010a474:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a477:	01 c8                	add    %ecx,%eax
8010a479:	0f b6 00             	movzbl (%eax),%eax
8010a47c:	0f b6 c0             	movzbl %al,%eax
8010a47f:	01 d0                	add    %edx,%eax
8010a481:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a484:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a488:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a48c:	7e c7                	jle    8010a455 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a48e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a491:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a494:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a49b:	eb 33                	jmp    8010a4d0 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a49d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4a0:	01 c0                	add    %eax,%eax
8010a4a2:	89 c2                	mov    %eax,%edx
8010a4a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4a7:	01 d0                	add    %edx,%eax
8010a4a9:	0f b6 00             	movzbl (%eax),%eax
8010a4ac:	0f b6 c0             	movzbl %al,%eax
8010a4af:	c1 e0 08             	shl    $0x8,%eax
8010a4b2:	89 c2                	mov    %eax,%edx
8010a4b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4b7:	01 c0                	add    %eax,%eax
8010a4b9:	8d 48 01             	lea    0x1(%eax),%ecx
8010a4bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4bf:	01 c8                	add    %ecx,%eax
8010a4c1:	0f b6 00             	movzbl (%eax),%eax
8010a4c4:	0f b6 c0             	movzbl %al,%eax
8010a4c7:	01 d0                	add    %edx,%eax
8010a4c9:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a4cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a4d0:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a4d4:	0f b7 c0             	movzwl %ax,%eax
8010a4d7:	83 ec 0c             	sub    $0xc,%esp
8010a4da:	50                   	push   %eax
8010a4db:	e8 c7 f5 ff ff       	call   80109aa7 <N2H_ushort>
8010a4e0:	83 c4 10             	add    $0x10,%esp
8010a4e3:	66 d1 e8             	shr    %ax
8010a4e6:	0f b7 c0             	movzwl %ax,%eax
8010a4e9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a4ec:	7c af                	jl     8010a49d <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a4ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4f1:	c1 e8 10             	shr    $0x10,%eax
8010a4f4:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a4f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4fa:	f7 d0                	not    %eax
}
8010a4fc:	c9                   	leave  
8010a4fd:	c3                   	ret    

8010a4fe <tcp_fin>:

void tcp_fin(){
8010a4fe:	f3 0f 1e fb          	endbr32 
8010a502:	55                   	push   %ebp
8010a503:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a505:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a50c:	00 00 00 
}
8010a50f:	90                   	nop
8010a510:	5d                   	pop    %ebp
8010a511:	c3                   	ret    

8010a512 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a512:	f3 0f 1e fb          	endbr32 
8010a516:	55                   	push   %ebp
8010a517:	89 e5                	mov    %esp,%ebp
8010a519:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a51c:	8b 45 10             	mov    0x10(%ebp),%eax
8010a51f:	83 ec 04             	sub    $0x4,%esp
8010a522:	6a 00                	push   $0x0
8010a524:	68 6b c6 10 80       	push   $0x8010c66b
8010a529:	50                   	push   %eax
8010a52a:	e8 65 00 00 00       	call   8010a594 <http_strcpy>
8010a52f:	83 c4 10             	add    $0x10,%esp
8010a532:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a535:	8b 45 10             	mov    0x10(%ebp),%eax
8010a538:	83 ec 04             	sub    $0x4,%esp
8010a53b:	ff 75 f4             	pushl  -0xc(%ebp)
8010a53e:	68 7e c6 10 80       	push   $0x8010c67e
8010a543:	50                   	push   %eax
8010a544:	e8 4b 00 00 00       	call   8010a594 <http_strcpy>
8010a549:	83 c4 10             	add    $0x10,%esp
8010a54c:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a54f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a552:	83 ec 04             	sub    $0x4,%esp
8010a555:	ff 75 f4             	pushl  -0xc(%ebp)
8010a558:	68 99 c6 10 80       	push   $0x8010c699
8010a55d:	50                   	push   %eax
8010a55e:	e8 31 00 00 00       	call   8010a594 <http_strcpy>
8010a563:	83 c4 10             	add    $0x10,%esp
8010a566:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a569:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a56c:	83 e0 01             	and    $0x1,%eax
8010a56f:	85 c0                	test   %eax,%eax
8010a571:	74 11                	je     8010a584 <http_proc+0x72>
    char *payload = (char *)send;
8010a573:	8b 45 10             	mov    0x10(%ebp),%eax
8010a576:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a579:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a57c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a57f:	01 d0                	add    %edx,%eax
8010a581:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a584:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a587:	8b 45 14             	mov    0x14(%ebp),%eax
8010a58a:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a58c:	e8 6d ff ff ff       	call   8010a4fe <tcp_fin>
}
8010a591:	90                   	nop
8010a592:	c9                   	leave  
8010a593:	c3                   	ret    

8010a594 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a594:	f3 0f 1e fb          	endbr32 
8010a598:	55                   	push   %ebp
8010a599:	89 e5                	mov    %esp,%ebp
8010a59b:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a59e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a5a5:	eb 20                	jmp    8010a5c7 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a5a7:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a5aa:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5ad:	01 d0                	add    %edx,%eax
8010a5af:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a5b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a5b5:	01 ca                	add    %ecx,%edx
8010a5b7:	89 d1                	mov    %edx,%ecx
8010a5b9:	8b 55 08             	mov    0x8(%ebp),%edx
8010a5bc:	01 ca                	add    %ecx,%edx
8010a5be:	0f b6 00             	movzbl (%eax),%eax
8010a5c1:	88 02                	mov    %al,(%edx)
    i++;
8010a5c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a5c7:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a5ca:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a5cd:	01 d0                	add    %edx,%eax
8010a5cf:	0f b6 00             	movzbl (%eax),%eax
8010a5d2:	84 c0                	test   %al,%al
8010a5d4:	75 d1                	jne    8010a5a7 <http_strcpy+0x13>
  }
  return i;
8010a5d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a5d9:	c9                   	leave  
8010a5da:	c3                   	ret    

8010a5db <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a5db:	f3 0f 1e fb          	endbr32 
8010a5df:	55                   	push   %ebp
8010a5e0:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a5e2:	c7 05 50 d3 18 80 c2 	movl   $0x8010f5c2,0x8018d350
8010a5e9:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a5ec:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a5f1:	c1 e8 09             	shr    $0x9,%eax
8010a5f4:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a5f9:	90                   	nop
8010a5fa:	5d                   	pop    %ebp
8010a5fb:	c3                   	ret    

8010a5fc <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a5fc:	f3 0f 1e fb          	endbr32 
8010a600:	55                   	push   %ebp
8010a601:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a603:	90                   	nop
8010a604:	5d                   	pop    %ebp
8010a605:	c3                   	ret    

8010a606 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a606:	f3 0f 1e fb          	endbr32 
8010a60a:	55                   	push   %ebp
8010a60b:	89 e5                	mov    %esp,%ebp
8010a60d:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a610:	8b 45 08             	mov    0x8(%ebp),%eax
8010a613:	83 c0 0c             	add    $0xc,%eax
8010a616:	83 ec 0c             	sub    $0xc,%esp
8010a619:	50                   	push   %eax
8010a61a:	e8 d4 a4 ff ff       	call   80104af3 <holdingsleep>
8010a61f:	83 c4 10             	add    $0x10,%esp
8010a622:	85 c0                	test   %eax,%eax
8010a624:	75 0d                	jne    8010a633 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a626:	83 ec 0c             	sub    $0xc,%esp
8010a629:	68 aa c6 10 80       	push   $0x8010c6aa
8010a62e:	e8 92 5f ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a633:	8b 45 08             	mov    0x8(%ebp),%eax
8010a636:	8b 00                	mov    (%eax),%eax
8010a638:	83 e0 06             	and    $0x6,%eax
8010a63b:	83 f8 02             	cmp    $0x2,%eax
8010a63e:	75 0d                	jne    8010a64d <iderw+0x47>
    panic("iderw: nothing to do");
8010a640:	83 ec 0c             	sub    $0xc,%esp
8010a643:	68 c0 c6 10 80       	push   $0x8010c6c0
8010a648:	e8 78 5f ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a64d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a650:	8b 40 04             	mov    0x4(%eax),%eax
8010a653:	83 f8 01             	cmp    $0x1,%eax
8010a656:	74 0d                	je     8010a665 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a658:	83 ec 0c             	sub    $0xc,%esp
8010a65b:	68 d5 c6 10 80       	push   $0x8010c6d5
8010a660:	e8 60 5f ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a665:	8b 45 08             	mov    0x8(%ebp),%eax
8010a668:	8b 40 08             	mov    0x8(%eax),%eax
8010a66b:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a671:	39 d0                	cmp    %edx,%eax
8010a673:	72 0d                	jb     8010a682 <iderw+0x7c>
    panic("iderw: block out of range");
8010a675:	83 ec 0c             	sub    $0xc,%esp
8010a678:	68 f3 c6 10 80       	push   $0x8010c6f3
8010a67d:	e8 43 5f ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a682:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a688:	8b 45 08             	mov    0x8(%ebp),%eax
8010a68b:	8b 40 08             	mov    0x8(%eax),%eax
8010a68e:	c1 e0 09             	shl    $0x9,%eax
8010a691:	01 d0                	add    %edx,%eax
8010a693:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a696:	8b 45 08             	mov    0x8(%ebp),%eax
8010a699:	8b 00                	mov    (%eax),%eax
8010a69b:	83 e0 04             	and    $0x4,%eax
8010a69e:	85 c0                	test   %eax,%eax
8010a6a0:	74 2b                	je     8010a6cd <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a6a2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6a5:	8b 00                	mov    (%eax),%eax
8010a6a7:	83 e0 fb             	and    $0xfffffffb,%eax
8010a6aa:	89 c2                	mov    %eax,%edx
8010a6ac:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6af:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a6b1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6b4:	83 c0 5c             	add    $0x5c,%eax
8010a6b7:	83 ec 04             	sub    $0x4,%esp
8010a6ba:	68 00 02 00 00       	push   $0x200
8010a6bf:	50                   	push   %eax
8010a6c0:	ff 75 f4             	pushl  -0xc(%ebp)
8010a6c3:	e8 1a a8 ff ff       	call   80104ee2 <memmove>
8010a6c8:	83 c4 10             	add    $0x10,%esp
8010a6cb:	eb 1a                	jmp    8010a6e7 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a6cd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6d0:	83 c0 5c             	add    $0x5c,%eax
8010a6d3:	83 ec 04             	sub    $0x4,%esp
8010a6d6:	68 00 02 00 00       	push   $0x200
8010a6db:	ff 75 f4             	pushl  -0xc(%ebp)
8010a6de:	50                   	push   %eax
8010a6df:	e8 fe a7 ff ff       	call   80104ee2 <memmove>
8010a6e4:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a6e7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6ea:	8b 00                	mov    (%eax),%eax
8010a6ec:	83 c8 02             	or     $0x2,%eax
8010a6ef:	89 c2                	mov    %eax,%edx
8010a6f1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6f4:	89 10                	mov    %edx,(%eax)
}
8010a6f6:	90                   	nop
8010a6f7:	c9                   	leave  
8010a6f8:	c3                   	ret    
