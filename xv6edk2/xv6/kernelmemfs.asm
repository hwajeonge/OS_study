
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
80100073:	68 e0 a8 10 80       	push   $0x8010a8e0
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 78 4c 00 00       	call   80104cfa <initlock>
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
801000c1:	68 e7 a8 10 80       	push   $0x8010a8e7
801000c6:	50                   	push   %eax
801000c7:	e8 c1 4a 00 00       	call   80104b8d <initsleeplock>
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
80100109:	e8 12 4c 00 00       	call   80104d20 <acquire>
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
80100148:	e8 45 4c 00 00       	call   80104d92 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 6e 4a 00 00       	call   80104bcd <acquiresleep>
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
801001c9:	e8 c4 4b 00 00       	call   80104d92 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 ed 49 00 00       	call   80104bcd <acquiresleep>
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
801001fd:	68 ee a8 10 80       	push   $0x8010a8ee
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
80100239:	e8 98 a5 00 00       	call   8010a7d6 <iderw>
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
8010025a:	e8 28 4a 00 00       	call   80104c87 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 ff a8 10 80       	push   $0x8010a8ff
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
80100288:	e8 49 a5 00 00       	call   8010a7d6 <iderw>
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
801002a7:	e8 db 49 00 00       	call   80104c87 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 06 a9 10 80       	push   $0x8010a906
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 66 49 00 00       	call   80104c35 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 41 4a 00 00       	call   80104d20 <acquire>
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
8010034a:	e8 43 4a 00 00       	call   80104d92 <release>
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
8010042c:	e8 ef 48 00 00       	call   80104d20 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 0d a9 10 80       	push   $0x8010a90d
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
8010052c:	c7 45 ec 16 a9 10 80 	movl   $0x8010a916,-0x14(%ebp)
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
801005ba:	e8 d3 47 00 00       	call   80104d92 <release>
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
801005e7:	68 1d a9 10 80       	push   $0x8010a91d
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
80100606:	68 31 a9 10 80       	push   $0x8010a931
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 c5 47 00 00       	call   80104de8 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 33 a9 10 80       	push   $0x8010a933
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
801006c4:	e8 a1 7f 00 00       	call   8010866a <graphic_scroll_up>
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
80100717:	e8 4e 7f 00 00       	call   8010866a <graphic_scroll_up>
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
8010077d:	e8 5c 7f 00 00       	call   801086de <font_render>
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
801007bd:	e8 bc 62 00 00       	call   80106a7e <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 af 62 00 00       	call   80106a7e <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 a2 62 00 00       	call   80106a7e <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 92 62 00 00       	call   80106a7e <uartputc>
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
80100819:	e8 02 45 00 00       	call   80104d20 <acquire>
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
80100992:	e8 fb 43 00 00       	call   80104d92 <release>
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
801009ce:	e8 4d 43 00 00       	call   80104d20 <acquire>
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
801009ef:	e8 9e 43 00 00       	call   80104d92 <release>
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
80100a9a:	e8 f3 42 00 00       	call   80104d92 <release>
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
80100adc:	e8 3f 42 00 00       	call   80104d20 <acquire>
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
80100b1e:	e8 6f 42 00 00       	call   80104d92 <release>
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
80100b50:	68 37 a9 10 80       	push   $0x8010a937
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 9b 41 00 00       	call   80104cfa <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 3f a9 10 80 	movl   $0x8010a93f,-0xc(%ebp)
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
80100bf7:	68 55 a9 10 80       	push   $0x8010a955
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
80100c53:	e8 3a 6e 00 00       	call   80107a92 <setupkvm>
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
80100cf9:	e8 a6 71 00 00       	call   80107ea4 <allocuvm>
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
80100d3f:	e8 8f 70 00 00       	call   80107dd3 <loaduvm>
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
80100dae:	e8 f1 70 00 00       	call   80107ea4 <allocuvm>
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
80100dd2:	e8 3b 73 00 00       	call   80108112 <clearpteu>
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
80100e0b:	e8 08 44 00 00       	call   80105218 <strlen>
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
80100e38:	e8 db 43 00 00       	call   80105218 <strlen>
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
80100e5e:	e8 5a 74 00 00       	call   801082bd <copyout>
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
80100efa:	e8 be 73 00 00       	call   801082bd <copyout>
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
80100f48:	e8 7d 42 00 00       	call   801051ca <safestrcpy>
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
80100f8b:	e8 2c 6c 00 00       	call   80107bbc <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	pushl  -0x34(%ebp)
80100f99:	e8 d7 70 00 00       	call   80108075 <freevm>
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
80100fd9:	e8 97 70 00 00       	call   80108075 <freevm>
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
8010100e:	68 61 a9 10 80       	push   $0x8010a961
80101013:	68 60 2d 19 80       	push   $0x80192d60
80101018:	e8 dd 3c 00 00       	call   80104cfa <initlock>
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
80101035:	e8 e6 3c 00 00       	call   80104d20 <acquire>
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
80101062:	e8 2b 3d 00 00       	call   80104d92 <release>
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
80101085:	e8 08 3d 00 00       	call   80104d92 <release>
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
801010a6:	e8 75 3c 00 00       	call   80104d20 <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 68 a9 10 80       	push   $0x8010a968
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
801010dc:	e8 b1 3c 00 00       	call   80104d92 <release>
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
801010fb:	e8 20 3c 00 00       	call   80104d20 <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 70 a9 10 80       	push   $0x8010a970
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
8010113b:	e8 52 3c 00 00       	call   80104d92 <release>
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
80101189:	e8 04 3c 00 00       	call   80104d92 <release>
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
801012e0:	68 7a a9 10 80       	push   $0x8010a97a
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
801013e7:	68 83 a9 10 80       	push   $0x8010a983
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
8010141d:	68 93 a9 10 80       	push   $0x8010a993
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
80101459:	e8 18 3c 00 00       	call   80105076 <memmove>
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
801014a3:	e8 07 3b 00 00       	call   80104faf <memset>
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
8010160e:	68 a0 a9 10 80       	push   $0x8010a9a0
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
801016a5:	68 b6 a9 10 80       	push   $0x8010a9b6
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
8010170d:	68 c9 a9 10 80       	push   $0x8010a9c9
80101712:	68 80 37 19 80       	push   $0x80193780
80101717:	e8 de 35 00 00       	call   80104cfa <initlock>
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
80101743:	68 d0 a9 10 80       	push   $0x8010a9d0
80101748:	50                   	push   %eax
80101749:	e8 3f 34 00 00       	call   80104b8d <initsleeplock>
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
801017a2:	68 d8 a9 10 80       	push   $0x8010a9d8
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
8010181f:	e8 8b 37 00 00       	call   80104faf <memset>
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
80101887:	68 2b aa 10 80       	push   $0x8010aa2b
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
80101931:	e8 40 37 00 00       	call   80105076 <memmove>
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
8010196a:	e8 b1 33 00 00       	call   80104d20 <acquire>
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
801019b8:	e8 d5 33 00 00       	call   80104d92 <release>
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
801019f4:	68 3d aa 10 80       	push   $0x8010aa3d
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
80101a31:	e8 5c 33 00 00       	call   80104d92 <release>
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
80101a50:	e8 cb 32 00 00       	call   80104d20 <acquire>
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
80101a6f:	e8 1e 33 00 00       	call   80104d92 <release>
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
80101a99:	68 4d aa 10 80       	push   $0x8010aa4d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 1b 31 00 00       	call   80104bcd <acquiresleep>
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
80101b57:	e8 1a 35 00 00       	call   80105076 <memmove>
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
80101b86:	68 53 aa 10 80       	push   $0x8010aa53
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
80101bad:	e8 d5 30 00 00       	call   80104c87 <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 62 aa 10 80       	push   $0x8010aa62
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 56 30 00 00       	call   80104c35 <releasesleep>
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
80101bf9:	e8 cf 2f 00 00       	call   80104bcd <acquiresleep>
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
80101c1f:	e8 fc 30 00 00       	call   80104d20 <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 80 37 19 80       	push   $0x80193780
80101c38:	e8 55 31 00 00       	call   80104d92 <release>
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
80101c7f:	e8 b1 2f 00 00       	call   80104c35 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 80 37 19 80       	push   $0x80193780
80101c8f:	e8 8c 30 00 00       	call   80104d20 <acquire>
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
80101cae:	e8 df 30 00 00       	call   80104d92 <release>
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
80101dfa:	68 6a aa 10 80       	push   $0x8010aa6a
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
801020a4:	e8 cd 2f 00 00       	call   80105076 <memmove>
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
801021f8:	e8 79 2e 00 00       	call   80105076 <memmove>
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
8010227c:	e8 93 2e 00 00       	call   80105114 <strncmp>
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
801022a0:	68 7d aa 10 80       	push   $0x8010aa7d
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
801022cf:	68 8f aa 10 80       	push   $0x8010aa8f
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
801023a8:	68 9e aa 10 80       	push   $0x8010aa9e
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
801023e3:	e8 86 2d 00 00       	call   8010516e <strncpy>
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
8010240f:	68 ab aa 10 80       	push   $0x8010aaab
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
80102485:	e8 ec 2b 00 00       	call   80105076 <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	ff 75 0c             	pushl  0xc(%ebp)
8010249c:	e8 d5 2b 00 00       	call   80105076 <memmove>
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
801026ab:	68 b4 aa 10 80       	push   $0x8010aab4
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
8010275a:	68 e6 aa 10 80       	push   $0x8010aae6
8010275f:	68 e0 53 19 80       	push   $0x801953e0
80102764:	e8 91 25 00 00       	call   80104cfa <initlock>
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
80102825:	68 eb aa 10 80       	push   $0x8010aaeb
8010282a:	e8 96 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010282f:	83 ec 04             	sub    $0x4,%esp
80102832:	68 00 10 00 00       	push   $0x1000
80102837:	6a 01                	push   $0x1
80102839:	ff 75 08             	pushl  0x8(%ebp)
8010283c:	e8 6e 27 00 00       	call   80104faf <memset>
80102841:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102844:	a1 14 54 19 80       	mov    0x80195414,%eax
80102849:	85 c0                	test   %eax,%eax
8010284b:	74 10                	je     8010285d <kfree+0x69>
    acquire(&kmem.lock);
8010284d:	83 ec 0c             	sub    $0xc,%esp
80102850:	68 e0 53 19 80       	push   $0x801953e0
80102855:	e8 c6 24 00 00       	call   80104d20 <acquire>
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
80102887:	e8 06 25 00 00       	call   80104d92 <release>
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
801028ad:	e8 6e 24 00 00       	call   80104d20 <acquire>
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
801028de:	e8 af 24 00 00       	call   80104d92 <release>
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
80102e33:	e8 e2 21 00 00       	call   8010501a <memcmp>
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
80102f4b:	68 f1 aa 10 80       	push   $0x8010aaf1
80102f50:	68 20 54 19 80       	push   $0x80195420
80102f55:	e8 a0 1d 00 00       	call   80104cfa <initlock>
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
80103004:	e8 6d 20 00 00       	call   80105076 <memmove>
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
80103183:	e8 98 1b 00 00       	call   80104d20 <acquire>
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
801031f5:	e8 98 1b 00 00       	call   80104d92 <release>
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
8010321a:	e8 01 1b 00 00       	call   80104d20 <acquire>
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
8010323b:	68 f5 aa 10 80       	push   $0x8010aaf5
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
80103279:	e8 14 1b 00 00       	call   80104d92 <release>
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
80103294:	e8 87 1a 00 00       	call   80104d20 <acquire>
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
801032be:	e8 cf 1a 00 00       	call   80104d92 <release>
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
8010333e:	e8 33 1d 00 00       	call   80105076 <memmove>
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
801033e3:	68 04 ab 10 80       	push   $0x8010ab04
801033e8:	e8 d8 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033ed:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033f2:	85 c0                	test   %eax,%eax
801033f4:	7f 0d                	jg     80103403 <log_write+0x49>
    panic("log_write outside of trans");
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	68 1a ab 10 80       	push   $0x8010ab1a
801033fe:	e8 c2 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	68 20 54 19 80       	push   $0x80195420
8010340b:	e8 10 19 00 00       	call   80104d20 <acquire>
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
80103489:	e8 04 19 00 00       	call   80104d92 <release>
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
801034c3:	e8 de 50 00 00       	call   801085a6 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	68 00 00 40 80       	push   $0x80400000
801034d0:	68 00 90 19 80       	push   $0x80199000
801034d5:	e8 73 f2 ff ff       	call   8010274d <kinit1>
801034da:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034dd:	e8 a1 46 00 00       	call   80107b83 <kvmalloc>
  mpinit_uefi();
801034e2:	e8 78 4e 00 00       	call   8010835f <mpinit_uefi>
  lapicinit();     // interrupt controller
801034e7:	e8 f0 f5 ff ff       	call   80102adc <lapicinit>
  seginit();       // segment descriptors
801034ec:	e8 19 41 00 00       	call   8010760a <seginit>
  picinit();    // disable pic
801034f1:	e8 a9 01 00 00       	call   8010369f <picinit>
  ioapicinit();    // another interrupt controller
801034f6:	e8 65 f1 ff ff       	call   80102660 <ioapicinit>
  consoleinit();   // console hardware
801034fb:	e8 39 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
80103500:	e8 8e 34 00 00       	call   80106993 <uartinit>
  pinit();         // process table
80103505:	e8 e2 05 00 00       	call   80103aec <pinit>
  tvinit();        // trap vectors
8010350a:	e8 01 30 00 00       	call   80106510 <tvinit>
  binit();         // buffer cache
8010350f:	e8 52 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103514:	e8 e8 da ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103519:	e8 8d 72 00 00       	call   8010a7ab <ideinit>
  startothers();   // start other processors
8010351e:	e8 92 00 00 00       	call   801035b5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103523:	83 ec 08             	sub    $0x8,%esp
80103526:	68 00 00 00 a0       	push   $0xa0000000
8010352b:	68 00 00 40 80       	push   $0x80400000
80103530:	e8 55 f2 ff ff       	call   8010278a <kinit2>
80103535:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103538:	e8 dc 52 00 00       	call   80108819 <pci_init>
  arp_scan();
8010353d:	e8 55 60 00 00       	call   80109597 <arp_scan>
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
80103556:	e8 44 46 00 00       	call   80107b9f <switchkvm>
  seginit();
8010355b:	e8 aa 40 00 00       	call   8010760a <seginit>
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
80103586:	68 35 ab 10 80       	push   $0x8010ab35
8010358b:	e8 7c ce ff ff       	call   8010040c <cprintf>
80103590:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103593:	e8 f2 30 00 00       	call   8010668a <idtinit>
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
801035d7:	e8 9a 1a 00 00       	call   80105076 <memmove>
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
80103768:	68 49 ab 10 80       	push   $0x8010ab49
8010376d:	50                   	push   %eax
8010376e:	e8 87 15 00 00       	call   80104cfa <initlock>
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
80103831:	e8 ea 14 00 00       	call   80104d20 <acquire>
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
801038a4:	e8 e9 14 00 00       	call   80104d92 <release>
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
801038c3:	e8 ca 14 00 00       	call   80104d92 <release>
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
801038e1:	e8 3a 14 00 00       	call   80104d20 <acquire>
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
80103915:	e8 78 14 00 00       	call   80104d92 <release>
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
801039c5:	e8 c8 13 00 00       	call   80104d92 <release>
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
801039e6:	e8 35 13 00 00       	call   80104d20 <acquire>
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
80103a03:	e8 8a 13 00 00       	call   80104d92 <release>
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
80103ac8:	e8 c5 12 00 00       	call   80104d92 <release>
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
80103af9:	68 50 ab 10 80       	push   $0x8010ab50
80103afe:	68 00 55 19 80       	push   $0x80195500
80103b03:	e8 f2 11 00 00       	call   80104cfa <initlock>
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
80103b48:	68 58 ab 10 80       	push   $0x8010ab58
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
80103b9d:	68 7e ab 10 80       	push   $0x8010ab7e
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
80103bb3:	e8 e4 12 00 00       	call   80104e9c <pushcli>
  c = mycpu();
80103bb8:	e8 70 ff ff ff       	call   80103b2d <mycpu>
80103bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bcc:	e8 1c 13 00 00       	call   80104eed <popcli>
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
80103be8:	e8 33 11 00 00       	call   80104d20 <acquire>
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
80103c1b:	e8 72 11 00 00       	call   80104d92 <release>
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
80103c65:	e8 28 11 00 00       	call   80104d92 <release>
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
80103cb2:	ba ca 64 10 80       	mov    $0x801064ca,%edx
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
80103cd7:	e8 d3 12 00 00       	call   80104faf <memset>
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
void printpt(int pid);
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
80103d0c:	e8 81 3d 00 00       	call   80107a92 <setupkvm>
80103d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d14:	89 42 04             	mov    %eax,0x4(%edx)
80103d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1a:	8b 40 04             	mov    0x4(%eax),%eax
80103d1d:	85 c0                	test   %eax,%eax
80103d1f:	75 0d                	jne    80103d2e <userinit+0x3c>
    panic("userinit: out of memory?");
80103d21:	83 ec 0c             	sub    $0xc,%esp
80103d24:	68 8e ab 10 80       	push   $0x8010ab8e
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
80103d43:	e8 17 40 00 00       	call   80107d5f <inituvm>
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
80103d62:	e8 48 12 00 00       	call   80104faf <memset>
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
80103ddc:	68 a7 ab 10 80       	push   $0x8010aba7
80103de1:	50                   	push   %eax
80103de2:	e8 e3 13 00 00       	call   801051ca <safestrcpy>
80103de7:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103dea:	83 ec 0c             	sub    $0xc,%esp
80103ded:	68 b0 ab 10 80       	push   $0x8010abb0
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
80103e08:	e8 13 0f 00 00       	call   80104d20 <acquire>
80103e0d:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e13:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e1a:	83 ec 0c             	sub    $0xc,%esp
80103e1d:	68 00 55 19 80       	push   $0x80195500
80103e22:	e8 6b 0f 00 00       	call   80104d92 <release>
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
80103e63:	e8 3c 40 00 00       	call   80107ea4 <allocuvm>
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
80103e97:	e8 11 41 00 00       	call   80107fad <deallocuvm>
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
80103ebd:	e8 fa 3c 00 00       	call   80107bbc <switchuvm>
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
80103f09:	e8 49 42 00 00       	call   80108157 <copyuvm>
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
80104003:	e8 c2 11 00 00       	call   801051ca <safestrcpy>
80104008:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010400b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010400e:	8b 40 10             	mov    0x10(%eax),%eax
80104011:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104014:	83 ec 0c             	sub    $0xc,%esp
80104017:	68 00 55 19 80       	push   $0x80195500
8010401c:	e8 ff 0c 00 00       	call   80104d20 <acquire>
80104021:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104024:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104027:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010402e:	83 ec 0c             	sub    $0xc,%esp
80104031:	68 00 55 19 80       	push   $0x80195500
80104036:	e8 57 0d 00 00       	call   80104d92 <release>
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
80104068:	68 b2 ab 10 80       	push   $0x8010abb2
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
801040ee:	e8 2d 0c 00 00       	call   80104d20 <acquire>
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
80104173:	68 bf ab 10 80       	push   $0x8010abbf
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
8010419c:	68 b2 ab 10 80       	push   $0x8010abb2
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
80104222:	e8 f9 0a 00 00       	call   80104d20 <acquire>
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
801042a3:	68 bf ab 10 80       	push   $0x8010abbf
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
801042c7:	e8 54 0a 00 00       	call   80104d20 <acquire>
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
80104332:	e8 3e 3d 00 00       	call   80108075 <freevm>
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
80104371:	e8 1c 0a 00 00       	call   80104d92 <release>
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
801043ab:	e8 e2 09 00 00       	call   80104d92 <release>
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
801043ee:	e8 2d 09 00 00       	call   80104d20 <acquire>
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
8010445d:	e8 13 3c 00 00       	call   80108075 <freevm>
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
801044a4:	e8 14 3e 00 00       	call   801082bd <copyout>
801044a9:	83 c4 10             	add    $0x10,%esp
801044ac:	85 c0                	test   %eax,%eax
801044ae:	79 17                	jns    801044c7 <wait2+0xf3>
          release(&ptable.lock);
801044b0:	83 ec 0c             	sub    $0xc,%esp
801044b3:	68 00 55 19 80       	push   $0x80195500
801044b8:	e8 d5 08 00 00       	call   80104d92 <release>
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
801044d9:	e8 b4 08 00 00       	call   80104d92 <release>
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
80104513:	e8 7a 08 00 00       	call   80104d92 <release>
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
80104568:	e8 b3 07 00 00       	call   80104d20 <acquire>
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
80104596:	e8 21 36 00 00       	call   80107bbc <switchuvm>
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
801045b9:	e8 85 0c 00 00       	call   80105243 <swtch>
801045be:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801045c1:	e8 d9 35 00 00       	call   80107b9f <switchkvm>

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
801045ee:	e8 9f 07 00 00       	call   80104d92 <release>
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
80104615:	e8 4d 08 00 00       	call   80104e67 <holding>
8010461a:	83 c4 10             	add    $0x10,%esp
8010461d:	85 c0                	test   %eax,%eax
8010461f:	75 0d                	jne    8010462e <sched+0x33>
    panic("sched ptable.lock");
80104621:	83 ec 0c             	sub    $0xc,%esp
80104624:	68 cb ab 10 80       	push   $0x8010abcb
80104629:	e8 97 bf ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
8010462e:	e8 fa f4 ff ff       	call   80103b2d <mycpu>
80104633:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104639:	83 f8 01             	cmp    $0x1,%eax
8010463c:	74 0d                	je     8010464b <sched+0x50>
    panic("sched locks");
8010463e:	83 ec 0c             	sub    $0xc,%esp
80104641:	68 dd ab 10 80       	push   $0x8010abdd
80104646:	e8 7a bf ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
8010464b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464e:	8b 40 0c             	mov    0xc(%eax),%eax
80104651:	83 f8 04             	cmp    $0x4,%eax
80104654:	75 0d                	jne    80104663 <sched+0x68>
    panic("sched running");
80104656:	83 ec 0c             	sub    $0xc,%esp
80104659:	68 e9 ab 10 80       	push   $0x8010abe9
8010465e:	e8 62 bf ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
80104663:	e8 6d f4 ff ff       	call   80103ad5 <readeflags>
80104668:	25 00 02 00 00       	and    $0x200,%eax
8010466d:	85 c0                	test   %eax,%eax
8010466f:	74 0d                	je     8010467e <sched+0x83>
    panic("sched interruptible");
80104671:	83 ec 0c             	sub    $0xc,%esp
80104674:	68 f7 ab 10 80       	push   $0x8010abf7
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
8010469f:	e8 9f 0b 00 00       	call   80105243 <swtch>
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
801046ca:	e8 51 06 00 00       	call   80104d20 <acquire>
801046cf:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801046d2:	e8 d2 f4 ff ff       	call   80103ba9 <myproc>
801046d7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801046de:	e8 18 ff ff ff       	call   801045fb <sched>
  release(&ptable.lock);
801046e3:	83 ec 0c             	sub    $0xc,%esp
801046e6:	68 00 55 19 80       	push   $0x80195500
801046eb:	e8 a2 06 00 00       	call   80104d92 <release>
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
80104708:	e8 85 06 00 00       	call   80104d92 <release>
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
8010475b:	68 0b ac 10 80       	push   $0x8010ac0b
80104760:	e8 60 be ff ff       	call   801005c5 <panic>

  if(lk == 0)
80104765:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104769:	75 0d                	jne    80104778 <sleep+0x38>
    panic("sleep without lk");
8010476b:	83 ec 0c             	sub    $0xc,%esp
8010476e:	68 11 ac 10 80       	push   $0x8010ac11
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
80104789:	e8 92 05 00 00       	call   80104d20 <acquire>
8010478e:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104791:	83 ec 0c             	sub    $0xc,%esp
80104794:	ff 75 0c             	pushl  0xc(%ebp)
80104797:	e8 f6 05 00 00       	call   80104d92 <release>
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
801047d2:	e8 bb 05 00 00       	call   80104d92 <release>
801047d7:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801047da:	83 ec 0c             	sub    $0xc,%esp
801047dd:	ff 75 0c             	pushl  0xc(%ebp)
801047e0:	e8 3b 05 00 00       	call   80104d20 <acquire>
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
80104844:	e8 d7 04 00 00       	call   80104d20 <acquire>
80104849:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010484c:	83 ec 0c             	sub    $0xc,%esp
8010484f:	ff 75 08             	pushl  0x8(%ebp)
80104852:	e8 94 ff ff ff       	call   801047eb <wakeup1>
80104857:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010485a:	83 ec 0c             	sub    $0xc,%esp
8010485d:	68 00 55 19 80       	push   $0x80195500
80104862:	e8 2b 05 00 00       	call   80104d92 <release>
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
8010487f:	e8 9c 04 00 00       	call   80104d20 <acquire>
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
801048c2:	e8 cb 04 00 00       	call   80104d92 <release>
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
801048e9:	e8 a4 04 00 00       	call   80104d92 <release>
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
8010494a:	c7 45 ec 22 ac 10 80 	movl   $0x8010ac22,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104951:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104954:	8d 50 6c             	lea    0x6c(%eax),%edx
80104957:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010495a:	8b 40 10             	mov    0x10(%eax),%eax
8010495d:	52                   	push   %edx
8010495e:	ff 75 ec             	pushl  -0x14(%ebp)
80104961:	50                   	push   %eax
80104962:	68 26 ac 10 80       	push   $0x8010ac26
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
80104990:	e8 53 04 00 00       	call   80104de8 <getcallerpcs>
80104995:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104998:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010499f:	eb 1c                	jmp    801049bd <procdump+0xc5>
        cprintf(" %p", pc[i]);
801049a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a4:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801049a8:	83 ec 08             	sub    $0x8,%esp
801049ab:	50                   	push   %eax
801049ac:	68 2f ac 10 80       	push   $0x8010ac2f
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
801049d1:	68 33 ac 10 80       	push   $0x8010ac33
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

801049f9 <printpt>:

// printpt 함수 구현
void printpt(int pid) {
801049f9:	f3 0f 1e fb          	endbr32 
801049fd:	55                   	push   %ebp
801049fe:	89 e5                	mov    %esp,%ebp
80104a00:	56                   	push   %esi
80104a01:	53                   	push   %ebx
80104a02:	83 ec 20             	sub    $0x20,%esp
    struct proc *p = myproc();  // 현재 실행 중인 프로세스를 가져옴
80104a05:	e8 9f f1 ff ff       	call   80103ba9 <myproc>
80104a0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(p->pid != pid) {
80104a0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a10:	8b 40 10             	mov    0x10(%eax),%eax
80104a13:	39 45 08             	cmp    %eax,0x8(%ebp)
80104a16:	74 15                	je     80104a2d <printpt+0x34>
        cprintf("Error: PID does not match current process.\n");
80104a18:	83 ec 0c             	sub    $0xc,%esp
80104a1b:	68 38 ac 10 80       	push   $0x8010ac38
80104a20:	e8 e7 b9 ff ff       	call   8010040c <cprintf>
80104a25:	83 c4 10             	add    $0x10,%esp
        return;
80104a28:	e9 59 01 00 00       	jmp    80104b86 <printpt+0x18d>
    }

    pde_t *pgdir = p->pgdir;
80104a2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a30:	8b 40 04             	mov    0x4(%eax),%eax
80104a33:	89 45 e8             	mov    %eax,-0x18(%ebp)
    cprintf("START PAGE TABLE (pid %d)\n", pid);
80104a36:	83 ec 08             	sub    $0x8,%esp
80104a39:	ff 75 08             	pushl  0x8(%ebp)
80104a3c:	68 64 ac 10 80       	push   $0x8010ac64
80104a41:	e8 c6 b9 ff ff       	call   8010040c <cprintf>
80104a46:	83 c4 10             	add    $0x10,%esp
    for(int i = 0; i < NPDENTRIES; i++) {
80104a49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a50:	e9 14 01 00 00       	jmp    80104b69 <printpt+0x170>
        if((pgdir[i] & PTE_P) && (pgdir[i] & PTE_U)) { // 사용자 메모리 부분만 탐색
80104a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a58:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104a62:	01 d0                	add    %edx,%eax
80104a64:	8b 00                	mov    (%eax),%eax
80104a66:	83 e0 01             	and    $0x1,%eax
80104a69:	85 c0                	test   %eax,%eax
80104a6b:	0f 84 f4 00 00 00    	je     80104b65 <printpt+0x16c>
80104a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a74:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104a7e:	01 d0                	add    %edx,%eax
80104a80:	8b 00                	mov    (%eax),%eax
80104a82:	83 e0 04             	and    $0x4,%eax
80104a85:	85 c0                	test   %eax,%eax
80104a87:	0f 84 d8 00 00 00    	je     80104b65 <printpt+0x16c>
            pte_t *pt = (pte_t*)P2V(PTE_ADDR(pgdir[i]));
80104a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104a97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104a9a:	01 d0                	add    %edx,%eax
80104a9c:	8b 00                	mov    (%eax),%eax
80104a9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104aa3:	05 00 00 00 80       	add    $0x80000000,%eax
80104aa8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            for(int j = 0; j < NPTENTRIES; j++) {
80104aab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ab2:	e9 a1 00 00 00       	jmp    80104b58 <printpt+0x15f>
                if(pt[j] & PTE_P) { // 유효한 페이지 테이블 엔트리만 출력
80104ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ac1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ac4:	01 d0                	add    %edx,%eax
80104ac6:	8b 00                	mov    (%eax),%eax
80104ac8:	83 e0 01             	and    $0x1,%eax
80104acb:	85 c0                	test   %eax,%eax
80104acd:	0f 84 81 00 00 00    	je     80104b54 <printpt+0x15b>
                    cprintf("%x P %c %c %x\n", 
                            (i << 10) + j, // 가상 페이지 번호
                            (pt[j] & PTE_U) ? 'U' : 'K', // 사용자 모드 접근 가능 여부
                            (pt[j] & PTE_W) ? 'W' : '-', // 쓰기 가능 여부
                            PTE_ADDR(pt[j])); // 물리 페이지 번호
80104ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ad6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104add:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ae0:	01 d0                	add    %edx,%eax
80104ae2:	8b 00                	mov    (%eax),%eax
                    cprintf("%x P %c %c %x\n", 
80104ae4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104ae9:	89 c2                	mov    %eax,%edx
                            (pt[j] & PTE_W) ? 'W' : '-', // 쓰기 가능 여부
80104aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aee:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104af5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104af8:	01 c8                	add    %ecx,%eax
80104afa:	8b 00                	mov    (%eax),%eax
80104afc:	83 e0 02             	and    $0x2,%eax
                    cprintf("%x P %c %c %x\n", 
80104aff:	85 c0                	test   %eax,%eax
80104b01:	74 07                	je     80104b0a <printpt+0x111>
80104b03:	be 57 00 00 00       	mov    $0x57,%esi
80104b08:	eb 05                	jmp    80104b0f <printpt+0x116>
80104b0a:	be 2d 00 00 00       	mov    $0x2d,%esi
                            (pt[j] & PTE_U) ? 'U' : 'K', // 사용자 모드 접근 가능 여부
80104b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b12:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104b19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104b1c:	01 c8                	add    %ecx,%eax
80104b1e:	8b 00                	mov    (%eax),%eax
80104b20:	83 e0 04             	and    $0x4,%eax
                    cprintf("%x P %c %c %x\n", 
80104b23:	85 c0                	test   %eax,%eax
80104b25:	74 07                	je     80104b2e <printpt+0x135>
80104b27:	bb 55 00 00 00       	mov    $0x55,%ebx
80104b2c:	eb 05                	jmp    80104b33 <printpt+0x13a>
80104b2e:	bb 4b 00 00 00       	mov    $0x4b,%ebx
                            (i << 10) + j, // 가상 페이지 번호
80104b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b36:	c1 e0 0a             	shl    $0xa,%eax
80104b39:	89 c1                	mov    %eax,%ecx
                    cprintf("%x P %c %c %x\n", 
80104b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b3e:	01 c8                	add    %ecx,%eax
80104b40:	83 ec 0c             	sub    $0xc,%esp
80104b43:	52                   	push   %edx
80104b44:	56                   	push   %esi
80104b45:	53                   	push   %ebx
80104b46:	50                   	push   %eax
80104b47:	68 7f ac 10 80       	push   $0x8010ac7f
80104b4c:	e8 bb b8 ff ff       	call   8010040c <cprintf>
80104b51:	83 c4 20             	add    $0x20,%esp
            for(int j = 0; j < NPTENTRIES; j++) {
80104b54:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104b58:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
80104b5f:	0f 8e 52 ff ff ff    	jle    80104ab7 <printpt+0xbe>
    for(int i = 0; i < NPDENTRIES; i++) {
80104b65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104b69:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80104b70:	0f 8e df fe ff ff    	jle    80104a55 <printpt+0x5c>
                }
            }
        }
    }
    cprintf("END PAGE TABLE\n");
80104b76:	83 ec 0c             	sub    $0xc,%esp
80104b79:	68 8e ac 10 80       	push   $0x8010ac8e
80104b7e:	e8 89 b8 ff ff       	call   8010040c <cprintf>
80104b83:	83 c4 10             	add    $0x10,%esp
}
80104b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b89:	5b                   	pop    %ebx
80104b8a:	5e                   	pop    %esi
80104b8b:	5d                   	pop    %ebp
80104b8c:	c3                   	ret    

80104b8d <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104b8d:	f3 0f 1e fb          	endbr32 
80104b91:	55                   	push   %ebp
80104b92:	89 e5                	mov    %esp,%ebp
80104b94:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104b97:	8b 45 08             	mov    0x8(%ebp),%eax
80104b9a:	83 c0 04             	add    $0x4,%eax
80104b9d:	83 ec 08             	sub    $0x8,%esp
80104ba0:	68 c8 ac 10 80       	push   $0x8010acc8
80104ba5:	50                   	push   %eax
80104ba6:	e8 4f 01 00 00       	call   80104cfa <initlock>
80104bab:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104bae:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb1:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bb4:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc3:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104bca:	90                   	nop
80104bcb:	c9                   	leave  
80104bcc:	c3                   	ret    

80104bcd <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104bcd:	f3 0f 1e fb          	endbr32 
80104bd1:	55                   	push   %ebp
80104bd2:	89 e5                	mov    %esp,%ebp
80104bd4:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bda:	83 c0 04             	add    $0x4,%eax
80104bdd:	83 ec 0c             	sub    $0xc,%esp
80104be0:	50                   	push   %eax
80104be1:	e8 3a 01 00 00       	call   80104d20 <acquire>
80104be6:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104be9:	eb 15                	jmp    80104c00 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104beb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bee:	83 c0 04             	add    $0x4,%eax
80104bf1:	83 ec 08             	sub    $0x8,%esp
80104bf4:	50                   	push   %eax
80104bf5:	ff 75 08             	pushl  0x8(%ebp)
80104bf8:	e8 43 fb ff ff       	call   80104740 <sleep>
80104bfd:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104c00:	8b 45 08             	mov    0x8(%ebp),%eax
80104c03:	8b 00                	mov    (%eax),%eax
80104c05:	85 c0                	test   %eax,%eax
80104c07:	75 e2                	jne    80104beb <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104c09:	8b 45 08             	mov    0x8(%ebp),%eax
80104c0c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104c12:	e8 92 ef ff ff       	call   80103ba9 <myproc>
80104c17:	8b 50 10             	mov    0x10(%eax),%edx
80104c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1d:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104c20:	8b 45 08             	mov    0x8(%ebp),%eax
80104c23:	83 c0 04             	add    $0x4,%eax
80104c26:	83 ec 0c             	sub    $0xc,%esp
80104c29:	50                   	push   %eax
80104c2a:	e8 63 01 00 00       	call   80104d92 <release>
80104c2f:	83 c4 10             	add    $0x10,%esp
}
80104c32:	90                   	nop
80104c33:	c9                   	leave  
80104c34:	c3                   	ret    

80104c35 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104c35:	f3 0f 1e fb          	endbr32 
80104c39:	55                   	push   %ebp
80104c3a:	89 e5                	mov    %esp,%ebp
80104c3c:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c42:	83 c0 04             	add    $0x4,%eax
80104c45:	83 ec 0c             	sub    $0xc,%esp
80104c48:	50                   	push   %eax
80104c49:	e8 d2 00 00 00       	call   80104d20 <acquire>
80104c4e:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104c51:	8b 45 08             	mov    0x8(%ebp),%eax
80104c54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104c64:	83 ec 0c             	sub    $0xc,%esp
80104c67:	ff 75 08             	pushl  0x8(%ebp)
80104c6a:	e8 c3 fb ff ff       	call   80104832 <wakeup>
80104c6f:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104c72:	8b 45 08             	mov    0x8(%ebp),%eax
80104c75:	83 c0 04             	add    $0x4,%eax
80104c78:	83 ec 0c             	sub    $0xc,%esp
80104c7b:	50                   	push   %eax
80104c7c:	e8 11 01 00 00       	call   80104d92 <release>
80104c81:	83 c4 10             	add    $0x10,%esp
}
80104c84:	90                   	nop
80104c85:	c9                   	leave  
80104c86:	c3                   	ret    

80104c87 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104c87:	f3 0f 1e fb          	endbr32 
80104c8b:	55                   	push   %ebp
80104c8c:	89 e5                	mov    %esp,%ebp
80104c8e:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104c91:	8b 45 08             	mov    0x8(%ebp),%eax
80104c94:	83 c0 04             	add    $0x4,%eax
80104c97:	83 ec 0c             	sub    $0xc,%esp
80104c9a:	50                   	push   %eax
80104c9b:	e8 80 00 00 00       	call   80104d20 <acquire>
80104ca0:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca6:	8b 00                	mov    (%eax),%eax
80104ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104cab:	8b 45 08             	mov    0x8(%ebp),%eax
80104cae:	83 c0 04             	add    $0x4,%eax
80104cb1:	83 ec 0c             	sub    $0xc,%esp
80104cb4:	50                   	push   %eax
80104cb5:	e8 d8 00 00 00       	call   80104d92 <release>
80104cba:	83 c4 10             	add    $0x10,%esp
  return r;
80104cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104cc0:	c9                   	leave  
80104cc1:	c3                   	ret    

80104cc2 <readeflags>:
{
80104cc2:	55                   	push   %ebp
80104cc3:	89 e5                	mov    %esp,%ebp
80104cc5:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104cc8:	9c                   	pushf  
80104cc9:	58                   	pop    %eax
80104cca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ccd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cd0:	c9                   	leave  
80104cd1:	c3                   	ret    

80104cd2 <cli>:
{
80104cd2:	55                   	push   %ebp
80104cd3:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104cd5:	fa                   	cli    
}
80104cd6:	90                   	nop
80104cd7:	5d                   	pop    %ebp
80104cd8:	c3                   	ret    

80104cd9 <sti>:
{
80104cd9:	55                   	push   %ebp
80104cda:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104cdc:	fb                   	sti    
}
80104cdd:	90                   	nop
80104cde:	5d                   	pop    %ebp
80104cdf:	c3                   	ret    

80104ce0 <xchg>:
{
80104ce0:	55                   	push   %ebp
80104ce1:	89 e5                	mov    %esp,%ebp
80104ce3:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104ce6:	8b 55 08             	mov    0x8(%ebp),%edx
80104ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cec:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cef:	f0 87 02             	lock xchg %eax,(%edx)
80104cf2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cf8:	c9                   	leave  
80104cf9:	c3                   	ret    

80104cfa <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104cfa:	f3 0f 1e fb          	endbr32 
80104cfe:	55                   	push   %ebp
80104cff:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104d01:	8b 45 08             	mov    0x8(%ebp),%eax
80104d04:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d07:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104d13:	8b 45 08             	mov    0x8(%ebp),%eax
80104d16:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104d1d:	90                   	nop
80104d1e:	5d                   	pop    %ebp
80104d1f:	c3                   	ret    

80104d20 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104d20:	f3 0f 1e fb          	endbr32 
80104d24:	55                   	push   %ebp
80104d25:	89 e5                	mov    %esp,%ebp
80104d27:	53                   	push   %ebx
80104d28:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104d2b:	e8 6c 01 00 00       	call   80104e9c <pushcli>
  if(holding(lk)){
80104d30:	8b 45 08             	mov    0x8(%ebp),%eax
80104d33:	83 ec 0c             	sub    $0xc,%esp
80104d36:	50                   	push   %eax
80104d37:	e8 2b 01 00 00       	call   80104e67 <holding>
80104d3c:	83 c4 10             	add    $0x10,%esp
80104d3f:	85 c0                	test   %eax,%eax
80104d41:	74 0d                	je     80104d50 <acquire+0x30>
    panic("acquire");
80104d43:	83 ec 0c             	sub    $0xc,%esp
80104d46:	68 d3 ac 10 80       	push   $0x8010acd3
80104d4b:	e8 75 b8 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104d50:	90                   	nop
80104d51:	8b 45 08             	mov    0x8(%ebp),%eax
80104d54:	83 ec 08             	sub    $0x8,%esp
80104d57:	6a 01                	push   $0x1
80104d59:	50                   	push   %eax
80104d5a:	e8 81 ff ff ff       	call   80104ce0 <xchg>
80104d5f:	83 c4 10             	add    $0x10,%esp
80104d62:	85 c0                	test   %eax,%eax
80104d64:	75 eb                	jne    80104d51 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104d66:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104d6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104d6e:	e8 ba ed ff ff       	call   80103b2d <mycpu>
80104d73:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104d76:	8b 45 08             	mov    0x8(%ebp),%eax
80104d79:	83 c0 0c             	add    $0xc,%eax
80104d7c:	83 ec 08             	sub    $0x8,%esp
80104d7f:	50                   	push   %eax
80104d80:	8d 45 08             	lea    0x8(%ebp),%eax
80104d83:	50                   	push   %eax
80104d84:	e8 5f 00 00 00       	call   80104de8 <getcallerpcs>
80104d89:	83 c4 10             	add    $0x10,%esp
}
80104d8c:	90                   	nop
80104d8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d90:	c9                   	leave  
80104d91:	c3                   	ret    

80104d92 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104d92:	f3 0f 1e fb          	endbr32 
80104d96:	55                   	push   %ebp
80104d97:	89 e5                	mov    %esp,%ebp
80104d99:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104d9c:	83 ec 0c             	sub    $0xc,%esp
80104d9f:	ff 75 08             	pushl  0x8(%ebp)
80104da2:	e8 c0 00 00 00       	call   80104e67 <holding>
80104da7:	83 c4 10             	add    $0x10,%esp
80104daa:	85 c0                	test   %eax,%eax
80104dac:	75 0d                	jne    80104dbb <release+0x29>
    panic("release");
80104dae:	83 ec 0c             	sub    $0xc,%esp
80104db1:	68 db ac 10 80       	push   $0x8010acdb
80104db6:	e8 0a b8 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80104dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80104dbe:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104dcf:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd7:	8b 55 08             	mov    0x8(%ebp),%edx
80104dda:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104de0:	e8 08 01 00 00       	call   80104eed <popcli>
}
80104de5:	90                   	nop
80104de6:	c9                   	leave  
80104de7:	c3                   	ret    

80104de8 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104de8:	f3 0f 1e fb          	endbr32 
80104dec:	55                   	push   %ebp
80104ded:	89 e5                	mov    %esp,%ebp
80104def:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104df2:	8b 45 08             	mov    0x8(%ebp),%eax
80104df5:	83 e8 08             	sub    $0x8,%eax
80104df8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104dfb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104e02:	eb 38                	jmp    80104e3c <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104e04:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104e08:	74 53                	je     80104e5d <getcallerpcs+0x75>
80104e0a:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104e11:	76 4a                	jbe    80104e5d <getcallerpcs+0x75>
80104e13:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104e17:	74 44                	je     80104e5d <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104e19:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e23:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e26:	01 c2                	add    %eax,%edx
80104e28:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e2b:	8b 40 04             	mov    0x4(%eax),%eax
80104e2e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104e30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e33:	8b 00                	mov    (%eax),%eax
80104e35:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e38:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e3c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e40:	7e c2                	jle    80104e04 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104e42:	eb 19                	jmp    80104e5d <getcallerpcs+0x75>
    pcs[i] = 0;
80104e44:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e51:	01 d0                	add    %edx,%eax
80104e53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104e59:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e5d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e61:	7e e1                	jle    80104e44 <getcallerpcs+0x5c>
}
80104e63:	90                   	nop
80104e64:	90                   	nop
80104e65:	c9                   	leave  
80104e66:	c3                   	ret    

80104e67 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104e67:	f3 0f 1e fb          	endbr32 
80104e6b:	55                   	push   %ebp
80104e6c:	89 e5                	mov    %esp,%ebp
80104e6e:	53                   	push   %ebx
80104e6f:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104e72:	8b 45 08             	mov    0x8(%ebp),%eax
80104e75:	8b 00                	mov    (%eax),%eax
80104e77:	85 c0                	test   %eax,%eax
80104e79:	74 16                	je     80104e91 <holding+0x2a>
80104e7b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7e:	8b 58 08             	mov    0x8(%eax),%ebx
80104e81:	e8 a7 ec ff ff       	call   80103b2d <mycpu>
80104e86:	39 c3                	cmp    %eax,%ebx
80104e88:	75 07                	jne    80104e91 <holding+0x2a>
80104e8a:	b8 01 00 00 00       	mov    $0x1,%eax
80104e8f:	eb 05                	jmp    80104e96 <holding+0x2f>
80104e91:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e96:	83 c4 04             	add    $0x4,%esp
80104e99:	5b                   	pop    %ebx
80104e9a:	5d                   	pop    %ebp
80104e9b:	c3                   	ret    

80104e9c <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104e9c:	f3 0f 1e fb          	endbr32 
80104ea0:	55                   	push   %ebp
80104ea1:	89 e5                	mov    %esp,%ebp
80104ea3:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104ea6:	e8 17 fe ff ff       	call   80104cc2 <readeflags>
80104eab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104eae:	e8 1f fe ff ff       	call   80104cd2 <cli>
  if(mycpu()->ncli == 0)
80104eb3:	e8 75 ec ff ff       	call   80103b2d <mycpu>
80104eb8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ebe:	85 c0                	test   %eax,%eax
80104ec0:	75 14                	jne    80104ed6 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104ec2:	e8 66 ec ff ff       	call   80103b2d <mycpu>
80104ec7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104eca:	81 e2 00 02 00 00    	and    $0x200,%edx
80104ed0:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104ed6:	e8 52 ec ff ff       	call   80103b2d <mycpu>
80104edb:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ee1:	83 c2 01             	add    $0x1,%edx
80104ee4:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104eea:	90                   	nop
80104eeb:	c9                   	leave  
80104eec:	c3                   	ret    

80104eed <popcli>:

void
popcli(void)
{
80104eed:	f3 0f 1e fb          	endbr32 
80104ef1:	55                   	push   %ebp
80104ef2:	89 e5                	mov    %esp,%ebp
80104ef4:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104ef7:	e8 c6 fd ff ff       	call   80104cc2 <readeflags>
80104efc:	25 00 02 00 00       	and    $0x200,%eax
80104f01:	85 c0                	test   %eax,%eax
80104f03:	74 0d                	je     80104f12 <popcli+0x25>
    panic("popcli - interruptible");
80104f05:	83 ec 0c             	sub    $0xc,%esp
80104f08:	68 e3 ac 10 80       	push   $0x8010ace3
80104f0d:	e8 b3 b6 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104f12:	e8 16 ec ff ff       	call   80103b2d <mycpu>
80104f17:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104f1d:	83 ea 01             	sub    $0x1,%edx
80104f20:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104f26:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f2c:	85 c0                	test   %eax,%eax
80104f2e:	79 0d                	jns    80104f3d <popcli+0x50>
    panic("popcli");
80104f30:	83 ec 0c             	sub    $0xc,%esp
80104f33:	68 fa ac 10 80       	push   $0x8010acfa
80104f38:	e8 88 b6 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104f3d:	e8 eb eb ff ff       	call   80103b2d <mycpu>
80104f42:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f48:	85 c0                	test   %eax,%eax
80104f4a:	75 14                	jne    80104f60 <popcli+0x73>
80104f4c:	e8 dc eb ff ff       	call   80103b2d <mycpu>
80104f51:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f57:	85 c0                	test   %eax,%eax
80104f59:	74 05                	je     80104f60 <popcli+0x73>
    sti();
80104f5b:	e8 79 fd ff ff       	call   80104cd9 <sti>
}
80104f60:	90                   	nop
80104f61:	c9                   	leave  
80104f62:	c3                   	ret    

80104f63 <stosb>:
{
80104f63:	55                   	push   %ebp
80104f64:	89 e5                	mov    %esp,%ebp
80104f66:	57                   	push   %edi
80104f67:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104f68:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f6b:	8b 55 10             	mov    0x10(%ebp),%edx
80104f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f71:	89 cb                	mov    %ecx,%ebx
80104f73:	89 df                	mov    %ebx,%edi
80104f75:	89 d1                	mov    %edx,%ecx
80104f77:	fc                   	cld    
80104f78:	f3 aa                	rep stos %al,%es:(%edi)
80104f7a:	89 ca                	mov    %ecx,%edx
80104f7c:	89 fb                	mov    %edi,%ebx
80104f7e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f81:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104f84:	90                   	nop
80104f85:	5b                   	pop    %ebx
80104f86:	5f                   	pop    %edi
80104f87:	5d                   	pop    %ebp
80104f88:	c3                   	ret    

80104f89 <stosl>:
{
80104f89:	55                   	push   %ebp
80104f8a:	89 e5                	mov    %esp,%ebp
80104f8c:	57                   	push   %edi
80104f8d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104f8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f91:	8b 55 10             	mov    0x10(%ebp),%edx
80104f94:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f97:	89 cb                	mov    %ecx,%ebx
80104f99:	89 df                	mov    %ebx,%edi
80104f9b:	89 d1                	mov    %edx,%ecx
80104f9d:	fc                   	cld    
80104f9e:	f3 ab                	rep stos %eax,%es:(%edi)
80104fa0:	89 ca                	mov    %ecx,%edx
80104fa2:	89 fb                	mov    %edi,%ebx
80104fa4:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104fa7:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104faa:	90                   	nop
80104fab:	5b                   	pop    %ebx
80104fac:	5f                   	pop    %edi
80104fad:	5d                   	pop    %ebp
80104fae:	c3                   	ret    

80104faf <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104faf:	f3 0f 1e fb          	endbr32 
80104fb3:	55                   	push   %ebp
80104fb4:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb9:	83 e0 03             	and    $0x3,%eax
80104fbc:	85 c0                	test   %eax,%eax
80104fbe:	75 43                	jne    80105003 <memset+0x54>
80104fc0:	8b 45 10             	mov    0x10(%ebp),%eax
80104fc3:	83 e0 03             	and    $0x3,%eax
80104fc6:	85 c0                	test   %eax,%eax
80104fc8:	75 39                	jne    80105003 <memset+0x54>
    c &= 0xFF;
80104fca:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104fd1:	8b 45 10             	mov    0x10(%ebp),%eax
80104fd4:	c1 e8 02             	shr    $0x2,%eax
80104fd7:	89 c1                	mov    %eax,%ecx
80104fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fdc:	c1 e0 18             	shl    $0x18,%eax
80104fdf:	89 c2                	mov    %eax,%edx
80104fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe4:	c1 e0 10             	shl    $0x10,%eax
80104fe7:	09 c2                	or     %eax,%edx
80104fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fec:	c1 e0 08             	shl    $0x8,%eax
80104fef:	09 d0                	or     %edx,%eax
80104ff1:	0b 45 0c             	or     0xc(%ebp),%eax
80104ff4:	51                   	push   %ecx
80104ff5:	50                   	push   %eax
80104ff6:	ff 75 08             	pushl  0x8(%ebp)
80104ff9:	e8 8b ff ff ff       	call   80104f89 <stosl>
80104ffe:	83 c4 0c             	add    $0xc,%esp
80105001:	eb 12                	jmp    80105015 <memset+0x66>
  } else
    stosb(dst, c, n);
80105003:	8b 45 10             	mov    0x10(%ebp),%eax
80105006:	50                   	push   %eax
80105007:	ff 75 0c             	pushl  0xc(%ebp)
8010500a:	ff 75 08             	pushl  0x8(%ebp)
8010500d:	e8 51 ff ff ff       	call   80104f63 <stosb>
80105012:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105015:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105018:	c9                   	leave  
80105019:	c3                   	ret    

8010501a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010501a:	f3 0f 1e fb          	endbr32 
8010501e:	55                   	push   %ebp
8010501f:	89 e5                	mov    %esp,%ebp
80105021:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105024:	8b 45 08             	mov    0x8(%ebp),%eax
80105027:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010502a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010502d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105030:	eb 30                	jmp    80105062 <memcmp+0x48>
    if(*s1 != *s2)
80105032:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105035:	0f b6 10             	movzbl (%eax),%edx
80105038:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010503b:	0f b6 00             	movzbl (%eax),%eax
8010503e:	38 c2                	cmp    %al,%dl
80105040:	74 18                	je     8010505a <memcmp+0x40>
      return *s1 - *s2;
80105042:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105045:	0f b6 00             	movzbl (%eax),%eax
80105048:	0f b6 d0             	movzbl %al,%edx
8010504b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010504e:	0f b6 00             	movzbl (%eax),%eax
80105051:	0f b6 c0             	movzbl %al,%eax
80105054:	29 c2                	sub    %eax,%edx
80105056:	89 d0                	mov    %edx,%eax
80105058:	eb 1a                	jmp    80105074 <memcmp+0x5a>
    s1++, s2++;
8010505a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010505e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105062:	8b 45 10             	mov    0x10(%ebp),%eax
80105065:	8d 50 ff             	lea    -0x1(%eax),%edx
80105068:	89 55 10             	mov    %edx,0x10(%ebp)
8010506b:	85 c0                	test   %eax,%eax
8010506d:	75 c3                	jne    80105032 <memcmp+0x18>
  }

  return 0;
8010506f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105074:	c9                   	leave  
80105075:	c3                   	ret    

80105076 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105076:	f3 0f 1e fb          	endbr32 
8010507a:	55                   	push   %ebp
8010507b:	89 e5                	mov    %esp,%ebp
8010507d:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105080:	8b 45 0c             	mov    0xc(%ebp),%eax
80105083:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105086:	8b 45 08             	mov    0x8(%ebp),%eax
80105089:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010508c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010508f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105092:	73 54                	jae    801050e8 <memmove+0x72>
80105094:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105097:	8b 45 10             	mov    0x10(%ebp),%eax
8010509a:	01 d0                	add    %edx,%eax
8010509c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010509f:	73 47                	jae    801050e8 <memmove+0x72>
    s += n;
801050a1:	8b 45 10             	mov    0x10(%ebp),%eax
801050a4:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801050a7:	8b 45 10             	mov    0x10(%ebp),%eax
801050aa:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801050ad:	eb 13                	jmp    801050c2 <memmove+0x4c>
      *--d = *--s;
801050af:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801050b3:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801050b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050ba:	0f b6 10             	movzbl (%eax),%edx
801050bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050c0:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801050c2:	8b 45 10             	mov    0x10(%ebp),%eax
801050c5:	8d 50 ff             	lea    -0x1(%eax),%edx
801050c8:	89 55 10             	mov    %edx,0x10(%ebp)
801050cb:	85 c0                	test   %eax,%eax
801050cd:	75 e0                	jne    801050af <memmove+0x39>
  if(s < d && s + n > d){
801050cf:	eb 24                	jmp    801050f5 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
801050d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050d4:	8d 42 01             	lea    0x1(%edx),%eax
801050d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
801050da:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050dd:	8d 48 01             	lea    0x1(%eax),%ecx
801050e0:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801050e3:	0f b6 12             	movzbl (%edx),%edx
801050e6:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801050e8:	8b 45 10             	mov    0x10(%ebp),%eax
801050eb:	8d 50 ff             	lea    -0x1(%eax),%edx
801050ee:	89 55 10             	mov    %edx,0x10(%ebp)
801050f1:	85 c0                	test   %eax,%eax
801050f3:	75 dc                	jne    801050d1 <memmove+0x5b>

  return dst;
801050f5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801050f8:	c9                   	leave  
801050f9:	c3                   	ret    

801050fa <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801050fa:	f3 0f 1e fb          	endbr32 
801050fe:	55                   	push   %ebp
801050ff:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105101:	ff 75 10             	pushl  0x10(%ebp)
80105104:	ff 75 0c             	pushl  0xc(%ebp)
80105107:	ff 75 08             	pushl  0x8(%ebp)
8010510a:	e8 67 ff ff ff       	call   80105076 <memmove>
8010510f:	83 c4 0c             	add    $0xc,%esp
}
80105112:	c9                   	leave  
80105113:	c3                   	ret    

80105114 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105114:	f3 0f 1e fb          	endbr32 
80105118:	55                   	push   %ebp
80105119:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010511b:	eb 0c                	jmp    80105129 <strncmp+0x15>
    n--, p++, q++;
8010511d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105121:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105125:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105129:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010512d:	74 1a                	je     80105149 <strncmp+0x35>
8010512f:	8b 45 08             	mov    0x8(%ebp),%eax
80105132:	0f b6 00             	movzbl (%eax),%eax
80105135:	84 c0                	test   %al,%al
80105137:	74 10                	je     80105149 <strncmp+0x35>
80105139:	8b 45 08             	mov    0x8(%ebp),%eax
8010513c:	0f b6 10             	movzbl (%eax),%edx
8010513f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105142:	0f b6 00             	movzbl (%eax),%eax
80105145:	38 c2                	cmp    %al,%dl
80105147:	74 d4                	je     8010511d <strncmp+0x9>
  if(n == 0)
80105149:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010514d:	75 07                	jne    80105156 <strncmp+0x42>
    return 0;
8010514f:	b8 00 00 00 00       	mov    $0x0,%eax
80105154:	eb 16                	jmp    8010516c <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80105156:	8b 45 08             	mov    0x8(%ebp),%eax
80105159:	0f b6 00             	movzbl (%eax),%eax
8010515c:	0f b6 d0             	movzbl %al,%edx
8010515f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105162:	0f b6 00             	movzbl (%eax),%eax
80105165:	0f b6 c0             	movzbl %al,%eax
80105168:	29 c2                	sub    %eax,%edx
8010516a:	89 d0                	mov    %edx,%eax
}
8010516c:	5d                   	pop    %ebp
8010516d:	c3                   	ret    

8010516e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010516e:	f3 0f 1e fb          	endbr32 
80105172:	55                   	push   %ebp
80105173:	89 e5                	mov    %esp,%ebp
80105175:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105178:	8b 45 08             	mov    0x8(%ebp),%eax
8010517b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010517e:	90                   	nop
8010517f:	8b 45 10             	mov    0x10(%ebp),%eax
80105182:	8d 50 ff             	lea    -0x1(%eax),%edx
80105185:	89 55 10             	mov    %edx,0x10(%ebp)
80105188:	85 c0                	test   %eax,%eax
8010518a:	7e 2c                	jle    801051b8 <strncpy+0x4a>
8010518c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010518f:	8d 42 01             	lea    0x1(%edx),%eax
80105192:	89 45 0c             	mov    %eax,0xc(%ebp)
80105195:	8b 45 08             	mov    0x8(%ebp),%eax
80105198:	8d 48 01             	lea    0x1(%eax),%ecx
8010519b:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010519e:	0f b6 12             	movzbl (%edx),%edx
801051a1:	88 10                	mov    %dl,(%eax)
801051a3:	0f b6 00             	movzbl (%eax),%eax
801051a6:	84 c0                	test   %al,%al
801051a8:	75 d5                	jne    8010517f <strncpy+0x11>
    ;
  while(n-- > 0)
801051aa:	eb 0c                	jmp    801051b8 <strncpy+0x4a>
    *s++ = 0;
801051ac:	8b 45 08             	mov    0x8(%ebp),%eax
801051af:	8d 50 01             	lea    0x1(%eax),%edx
801051b2:	89 55 08             	mov    %edx,0x8(%ebp)
801051b5:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801051b8:	8b 45 10             	mov    0x10(%ebp),%eax
801051bb:	8d 50 ff             	lea    -0x1(%eax),%edx
801051be:	89 55 10             	mov    %edx,0x10(%ebp)
801051c1:	85 c0                	test   %eax,%eax
801051c3:	7f e7                	jg     801051ac <strncpy+0x3e>
  return os;
801051c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051c8:	c9                   	leave  
801051c9:	c3                   	ret    

801051ca <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801051ca:	f3 0f 1e fb          	endbr32 
801051ce:	55                   	push   %ebp
801051cf:	89 e5                	mov    %esp,%ebp
801051d1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801051d4:	8b 45 08             	mov    0x8(%ebp),%eax
801051d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801051da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051de:	7f 05                	jg     801051e5 <safestrcpy+0x1b>
    return os;
801051e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051e3:	eb 31                	jmp    80105216 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801051e5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051ed:	7e 1e                	jle    8010520d <safestrcpy+0x43>
801051ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801051f2:	8d 42 01             	lea    0x1(%edx),%eax
801051f5:	89 45 0c             	mov    %eax,0xc(%ebp)
801051f8:	8b 45 08             	mov    0x8(%ebp),%eax
801051fb:	8d 48 01             	lea    0x1(%eax),%ecx
801051fe:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105201:	0f b6 12             	movzbl (%edx),%edx
80105204:	88 10                	mov    %dl,(%eax)
80105206:	0f b6 00             	movzbl (%eax),%eax
80105209:	84 c0                	test   %al,%al
8010520b:	75 d8                	jne    801051e5 <safestrcpy+0x1b>
    ;
  *s = 0;
8010520d:	8b 45 08             	mov    0x8(%ebp),%eax
80105210:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105213:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105216:	c9                   	leave  
80105217:	c3                   	ret    

80105218 <strlen>:

int
strlen(const char *s)
{
80105218:	f3 0f 1e fb          	endbr32 
8010521c:	55                   	push   %ebp
8010521d:	89 e5                	mov    %esp,%ebp
8010521f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105222:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105229:	eb 04                	jmp    8010522f <strlen+0x17>
8010522b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010522f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105232:	8b 45 08             	mov    0x8(%ebp),%eax
80105235:	01 d0                	add    %edx,%eax
80105237:	0f b6 00             	movzbl (%eax),%eax
8010523a:	84 c0                	test   %al,%al
8010523c:	75 ed                	jne    8010522b <strlen+0x13>
    ;
  return n;
8010523e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105241:	c9                   	leave  
80105242:	c3                   	ret    

80105243 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105243:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105247:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010524b:	55                   	push   %ebp
  pushl %ebx
8010524c:	53                   	push   %ebx
  pushl %esi
8010524d:	56                   	push   %esi
  pushl %edi
8010524e:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010524f:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105251:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105253:	5f                   	pop    %edi
  popl %esi
80105254:	5e                   	pop    %esi
  popl %ebx
80105255:	5b                   	pop    %ebx
  popl %ebp
80105256:	5d                   	pop    %ebp
  ret
80105257:	c3                   	ret    

80105258 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105258:	f3 0f 1e fb          	endbr32 
8010525c:	55                   	push   %ebp
8010525d:	89 e5                	mov    %esp,%ebp
8010525f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105262:	e8 42 e9 ff ff       	call   80103ba9 <myproc>
80105267:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010526a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526d:	8b 00                	mov    (%eax),%eax
8010526f:	39 45 08             	cmp    %eax,0x8(%ebp)
80105272:	73 0f                	jae    80105283 <fetchint+0x2b>
80105274:	8b 45 08             	mov    0x8(%ebp),%eax
80105277:	8d 50 04             	lea    0x4(%eax),%edx
8010527a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527d:	8b 00                	mov    (%eax),%eax
8010527f:	39 c2                	cmp    %eax,%edx
80105281:	76 07                	jbe    8010528a <fetchint+0x32>
    return -1;
80105283:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105288:	eb 0f                	jmp    80105299 <fetchint+0x41>
  *ip = *(int*)(addr);
8010528a:	8b 45 08             	mov    0x8(%ebp),%eax
8010528d:	8b 10                	mov    (%eax),%edx
8010528f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105292:	89 10                	mov    %edx,(%eax)
  return 0;
80105294:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105299:	c9                   	leave  
8010529a:	c3                   	ret    

8010529b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010529b:	f3 0f 1e fb          	endbr32 
8010529f:	55                   	push   %ebp
801052a0:	89 e5                	mov    %esp,%ebp
801052a2:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801052a5:	e8 ff e8 ff ff       	call   80103ba9 <myproc>
801052aa:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801052ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052b0:	8b 00                	mov    (%eax),%eax
801052b2:	39 45 08             	cmp    %eax,0x8(%ebp)
801052b5:	72 07                	jb     801052be <fetchstr+0x23>
    return -1;
801052b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052bc:	eb 43                	jmp    80105301 <fetchstr+0x66>
  *pp = (char*)addr;
801052be:	8b 55 08             	mov    0x8(%ebp),%edx
801052c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c4:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801052c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052c9:	8b 00                	mov    (%eax),%eax
801052cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801052ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d1:	8b 00                	mov    (%eax),%eax
801052d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052d6:	eb 1c                	jmp    801052f4 <fetchstr+0x59>
    if(*s == 0)
801052d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052db:	0f b6 00             	movzbl (%eax),%eax
801052de:	84 c0                	test   %al,%al
801052e0:	75 0e                	jne    801052f0 <fetchstr+0x55>
      return s - *pp;
801052e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e5:	8b 00                	mov    (%eax),%eax
801052e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052ea:	29 c2                	sub    %eax,%edx
801052ec:	89 d0                	mov    %edx,%eax
801052ee:	eb 11                	jmp    80105301 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801052f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801052fa:	72 dc                	jb     801052d8 <fetchstr+0x3d>
  }
  return -1;
801052fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105301:	c9                   	leave  
80105302:	c3                   	ret    

80105303 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105303:	f3 0f 1e fb          	endbr32 
80105307:	55                   	push   %ebp
80105308:	89 e5                	mov    %esp,%ebp
8010530a:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010530d:	e8 97 e8 ff ff       	call   80103ba9 <myproc>
80105312:	8b 40 18             	mov    0x18(%eax),%eax
80105315:	8b 40 44             	mov    0x44(%eax),%eax
80105318:	8b 55 08             	mov    0x8(%ebp),%edx
8010531b:	c1 e2 02             	shl    $0x2,%edx
8010531e:	01 d0                	add    %edx,%eax
80105320:	83 c0 04             	add    $0x4,%eax
80105323:	83 ec 08             	sub    $0x8,%esp
80105326:	ff 75 0c             	pushl  0xc(%ebp)
80105329:	50                   	push   %eax
8010532a:	e8 29 ff ff ff       	call   80105258 <fetchint>
8010532f:	83 c4 10             	add    $0x10,%esp
}
80105332:	c9                   	leave  
80105333:	c3                   	ret    

80105334 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105334:	f3 0f 1e fb          	endbr32 
80105338:	55                   	push   %ebp
80105339:	89 e5                	mov    %esp,%ebp
8010533b:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
8010533e:	e8 66 e8 ff ff       	call   80103ba9 <myproc>
80105343:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105346:	83 ec 08             	sub    $0x8,%esp
80105349:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010534c:	50                   	push   %eax
8010534d:	ff 75 08             	pushl  0x8(%ebp)
80105350:	e8 ae ff ff ff       	call   80105303 <argint>
80105355:	83 c4 10             	add    $0x10,%esp
80105358:	85 c0                	test   %eax,%eax
8010535a:	79 07                	jns    80105363 <argptr+0x2f>
    return -1;
8010535c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105361:	eb 3b                	jmp    8010539e <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105363:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105367:	78 1f                	js     80105388 <argptr+0x54>
80105369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010536c:	8b 00                	mov    (%eax),%eax
8010536e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105371:	39 d0                	cmp    %edx,%eax
80105373:	76 13                	jbe    80105388 <argptr+0x54>
80105375:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105378:	89 c2                	mov    %eax,%edx
8010537a:	8b 45 10             	mov    0x10(%ebp),%eax
8010537d:	01 c2                	add    %eax,%edx
8010537f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105382:	8b 00                	mov    (%eax),%eax
80105384:	39 c2                	cmp    %eax,%edx
80105386:	76 07                	jbe    8010538f <argptr+0x5b>
    return -1;
80105388:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010538d:	eb 0f                	jmp    8010539e <argptr+0x6a>
  *pp = (char*)i;
8010538f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105392:	89 c2                	mov    %eax,%edx
80105394:	8b 45 0c             	mov    0xc(%ebp),%eax
80105397:	89 10                	mov    %edx,(%eax)
  return 0;
80105399:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010539e:	c9                   	leave  
8010539f:	c3                   	ret    

801053a0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801053a0:	f3 0f 1e fb          	endbr32 
801053a4:	55                   	push   %ebp
801053a5:	89 e5                	mov    %esp,%ebp
801053a7:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801053aa:	83 ec 08             	sub    $0x8,%esp
801053ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053b0:	50                   	push   %eax
801053b1:	ff 75 08             	pushl  0x8(%ebp)
801053b4:	e8 4a ff ff ff       	call   80105303 <argint>
801053b9:	83 c4 10             	add    $0x10,%esp
801053bc:	85 c0                	test   %eax,%eax
801053be:	79 07                	jns    801053c7 <argstr+0x27>
    return -1;
801053c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053c5:	eb 12                	jmp    801053d9 <argstr+0x39>
  return fetchstr(addr, pp);
801053c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ca:	83 ec 08             	sub    $0x8,%esp
801053cd:	ff 75 0c             	pushl  0xc(%ebp)
801053d0:	50                   	push   %eax
801053d1:	e8 c5 fe ff ff       	call   8010529b <fetchstr>
801053d6:	83 c4 10             	add    $0x10,%esp
}
801053d9:	c9                   	leave  
801053da:	c3                   	ret    

801053db <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
801053db:	f3 0f 1e fb          	endbr32 
801053df:	55                   	push   %ebp
801053e0:	89 e5                	mov    %esp,%ebp
801053e2:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801053e5:	e8 bf e7 ff ff       	call   80103ba9 <myproc>
801053ea:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801053ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f0:	8b 40 18             	mov    0x18(%eax),%eax
801053f3:	8b 40 1c             	mov    0x1c(%eax),%eax
801053f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801053f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053fd:	7e 2f                	jle    8010542e <syscall+0x53>
801053ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105402:	83 f8 19             	cmp    $0x19,%eax
80105405:	77 27                	ja     8010542e <syscall+0x53>
80105407:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010540a:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105411:	85 c0                	test   %eax,%eax
80105413:	74 19                	je     8010542e <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105418:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
8010541f:	ff d0                	call   *%eax
80105421:	89 c2                	mov    %eax,%edx
80105423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105426:	8b 40 18             	mov    0x18(%eax),%eax
80105429:	89 50 1c             	mov    %edx,0x1c(%eax)
8010542c:	eb 2c                	jmp    8010545a <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010542e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105431:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105434:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105437:	8b 40 10             	mov    0x10(%eax),%eax
8010543a:	ff 75 f0             	pushl  -0x10(%ebp)
8010543d:	52                   	push   %edx
8010543e:	50                   	push   %eax
8010543f:	68 01 ad 10 80       	push   $0x8010ad01
80105444:	e8 c3 af ff ff       	call   8010040c <cprintf>
80105449:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
8010544c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544f:	8b 40 18             	mov    0x18(%eax),%eax
80105452:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105459:	90                   	nop
8010545a:	90                   	nop
8010545b:	c9                   	leave  
8010545c:	c3                   	ret    

8010545d <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010545d:	f3 0f 1e fb          	endbr32 
80105461:	55                   	push   %ebp
80105462:	89 e5                	mov    %esp,%ebp
80105464:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105467:	83 ec 08             	sub    $0x8,%esp
8010546a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010546d:	50                   	push   %eax
8010546e:	ff 75 08             	pushl  0x8(%ebp)
80105471:	e8 8d fe ff ff       	call   80105303 <argint>
80105476:	83 c4 10             	add    $0x10,%esp
80105479:	85 c0                	test   %eax,%eax
8010547b:	79 07                	jns    80105484 <argfd+0x27>
    return -1;
8010547d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105482:	eb 4f                	jmp    801054d3 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105484:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105487:	85 c0                	test   %eax,%eax
80105489:	78 20                	js     801054ab <argfd+0x4e>
8010548b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010548e:	83 f8 0f             	cmp    $0xf,%eax
80105491:	7f 18                	jg     801054ab <argfd+0x4e>
80105493:	e8 11 e7 ff ff       	call   80103ba9 <myproc>
80105498:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010549b:	83 c2 08             	add    $0x8,%edx
8010549e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054a9:	75 07                	jne    801054b2 <argfd+0x55>
    return -1;
801054ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b0:	eb 21                	jmp    801054d3 <argfd+0x76>
  if(pfd)
801054b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801054b6:	74 08                	je     801054c0 <argfd+0x63>
    *pfd = fd;
801054b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801054be:	89 10                	mov    %edx,(%eax)
  if(pf)
801054c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054c4:	74 08                	je     801054ce <argfd+0x71>
    *pf = f;
801054c6:	8b 45 10             	mov    0x10(%ebp),%eax
801054c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054cc:	89 10                	mov    %edx,(%eax)
  return 0;
801054ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054d3:	c9                   	leave  
801054d4:	c3                   	ret    

801054d5 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801054d5:	f3 0f 1e fb          	endbr32 
801054d9:	55                   	push   %ebp
801054da:	89 e5                	mov    %esp,%ebp
801054dc:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801054df:	e8 c5 e6 ff ff       	call   80103ba9 <myproc>
801054e4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801054e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801054ee:	eb 2a                	jmp    8010551a <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
801054f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054f6:	83 c2 08             	add    $0x8,%edx
801054f9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054fd:	85 c0                	test   %eax,%eax
801054ff:	75 15                	jne    80105516 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105501:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105504:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105507:	8d 4a 08             	lea    0x8(%edx),%ecx
8010550a:	8b 55 08             	mov    0x8(%ebp),%edx
8010550d:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105514:	eb 0f                	jmp    80105525 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105516:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010551a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010551e:	7e d0                	jle    801054f0 <fdalloc+0x1b>
    }
  }
  return -1;
80105520:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105525:	c9                   	leave  
80105526:	c3                   	ret    

80105527 <sys_dup>:

int
sys_dup(void)
{
80105527:	f3 0f 1e fb          	endbr32 
8010552b:	55                   	push   %ebp
8010552c:	89 e5                	mov    %esp,%ebp
8010552e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105531:	83 ec 04             	sub    $0x4,%esp
80105534:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105537:	50                   	push   %eax
80105538:	6a 00                	push   $0x0
8010553a:	6a 00                	push   $0x0
8010553c:	e8 1c ff ff ff       	call   8010545d <argfd>
80105541:	83 c4 10             	add    $0x10,%esp
80105544:	85 c0                	test   %eax,%eax
80105546:	79 07                	jns    8010554f <sys_dup+0x28>
    return -1;
80105548:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010554d:	eb 31                	jmp    80105580 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
8010554f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105552:	83 ec 0c             	sub    $0xc,%esp
80105555:	50                   	push   %eax
80105556:	e8 7a ff ff ff       	call   801054d5 <fdalloc>
8010555b:	83 c4 10             	add    $0x10,%esp
8010555e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105561:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105565:	79 07                	jns    8010556e <sys_dup+0x47>
    return -1;
80105567:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010556c:	eb 12                	jmp    80105580 <sys_dup+0x59>
  filedup(f);
8010556e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105571:	83 ec 0c             	sub    $0xc,%esp
80105574:	50                   	push   %eax
80105575:	e8 1a bb ff ff       	call   80101094 <filedup>
8010557a:	83 c4 10             	add    $0x10,%esp
  return fd;
8010557d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105580:	c9                   	leave  
80105581:	c3                   	ret    

80105582 <sys_read>:

int
sys_read(void)
{
80105582:	f3 0f 1e fb          	endbr32 
80105586:	55                   	push   %ebp
80105587:	89 e5                	mov    %esp,%ebp
80105589:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010558c:	83 ec 04             	sub    $0x4,%esp
8010558f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105592:	50                   	push   %eax
80105593:	6a 00                	push   $0x0
80105595:	6a 00                	push   $0x0
80105597:	e8 c1 fe ff ff       	call   8010545d <argfd>
8010559c:	83 c4 10             	add    $0x10,%esp
8010559f:	85 c0                	test   %eax,%eax
801055a1:	78 2e                	js     801055d1 <sys_read+0x4f>
801055a3:	83 ec 08             	sub    $0x8,%esp
801055a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055a9:	50                   	push   %eax
801055aa:	6a 02                	push   $0x2
801055ac:	e8 52 fd ff ff       	call   80105303 <argint>
801055b1:	83 c4 10             	add    $0x10,%esp
801055b4:	85 c0                	test   %eax,%eax
801055b6:	78 19                	js     801055d1 <sys_read+0x4f>
801055b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055bb:	83 ec 04             	sub    $0x4,%esp
801055be:	50                   	push   %eax
801055bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055c2:	50                   	push   %eax
801055c3:	6a 01                	push   $0x1
801055c5:	e8 6a fd ff ff       	call   80105334 <argptr>
801055ca:	83 c4 10             	add    $0x10,%esp
801055cd:	85 c0                	test   %eax,%eax
801055cf:	79 07                	jns    801055d8 <sys_read+0x56>
    return -1;
801055d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055d6:	eb 17                	jmp    801055ef <sys_read+0x6d>
  return fileread(f, p, n);
801055d8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801055db:	8b 55 ec             	mov    -0x14(%ebp),%edx
801055de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e1:	83 ec 04             	sub    $0x4,%esp
801055e4:	51                   	push   %ecx
801055e5:	52                   	push   %edx
801055e6:	50                   	push   %eax
801055e7:	e8 44 bc ff ff       	call   80101230 <fileread>
801055ec:	83 c4 10             	add    $0x10,%esp
}
801055ef:	c9                   	leave  
801055f0:	c3                   	ret    

801055f1 <sys_write>:

int
sys_write(void)
{
801055f1:	f3 0f 1e fb          	endbr32 
801055f5:	55                   	push   %ebp
801055f6:	89 e5                	mov    %esp,%ebp
801055f8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801055fb:	83 ec 04             	sub    $0x4,%esp
801055fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105601:	50                   	push   %eax
80105602:	6a 00                	push   $0x0
80105604:	6a 00                	push   $0x0
80105606:	e8 52 fe ff ff       	call   8010545d <argfd>
8010560b:	83 c4 10             	add    $0x10,%esp
8010560e:	85 c0                	test   %eax,%eax
80105610:	78 2e                	js     80105640 <sys_write+0x4f>
80105612:	83 ec 08             	sub    $0x8,%esp
80105615:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105618:	50                   	push   %eax
80105619:	6a 02                	push   $0x2
8010561b:	e8 e3 fc ff ff       	call   80105303 <argint>
80105620:	83 c4 10             	add    $0x10,%esp
80105623:	85 c0                	test   %eax,%eax
80105625:	78 19                	js     80105640 <sys_write+0x4f>
80105627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010562a:	83 ec 04             	sub    $0x4,%esp
8010562d:	50                   	push   %eax
8010562e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105631:	50                   	push   %eax
80105632:	6a 01                	push   $0x1
80105634:	e8 fb fc ff ff       	call   80105334 <argptr>
80105639:	83 c4 10             	add    $0x10,%esp
8010563c:	85 c0                	test   %eax,%eax
8010563e:	79 07                	jns    80105647 <sys_write+0x56>
    return -1;
80105640:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105645:	eb 17                	jmp    8010565e <sys_write+0x6d>
  return filewrite(f, p, n);
80105647:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010564a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010564d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105650:	83 ec 04             	sub    $0x4,%esp
80105653:	51                   	push   %ecx
80105654:	52                   	push   %edx
80105655:	50                   	push   %eax
80105656:	e8 91 bc ff ff       	call   801012ec <filewrite>
8010565b:	83 c4 10             	add    $0x10,%esp
}
8010565e:	c9                   	leave  
8010565f:	c3                   	ret    

80105660 <sys_close>:

int
sys_close(void)
{
80105660:	f3 0f 1e fb          	endbr32 
80105664:	55                   	push   %ebp
80105665:	89 e5                	mov    %esp,%ebp
80105667:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010566a:	83 ec 04             	sub    $0x4,%esp
8010566d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105670:	50                   	push   %eax
80105671:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105674:	50                   	push   %eax
80105675:	6a 00                	push   $0x0
80105677:	e8 e1 fd ff ff       	call   8010545d <argfd>
8010567c:	83 c4 10             	add    $0x10,%esp
8010567f:	85 c0                	test   %eax,%eax
80105681:	79 07                	jns    8010568a <sys_close+0x2a>
    return -1;
80105683:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105688:	eb 27                	jmp    801056b1 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
8010568a:	e8 1a e5 ff ff       	call   80103ba9 <myproc>
8010568f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105692:	83 c2 08             	add    $0x8,%edx
80105695:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010569c:	00 
  fileclose(f);
8010569d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056a0:	83 ec 0c             	sub    $0xc,%esp
801056a3:	50                   	push   %eax
801056a4:	e8 40 ba ff ff       	call   801010e9 <fileclose>
801056a9:	83 c4 10             	add    $0x10,%esp
  return 0;
801056ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056b1:	c9                   	leave  
801056b2:	c3                   	ret    

801056b3 <sys_fstat>:

int
sys_fstat(void)
{
801056b3:	f3 0f 1e fb          	endbr32 
801056b7:	55                   	push   %ebp
801056b8:	89 e5                	mov    %esp,%ebp
801056ba:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801056bd:	83 ec 04             	sub    $0x4,%esp
801056c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056c3:	50                   	push   %eax
801056c4:	6a 00                	push   $0x0
801056c6:	6a 00                	push   $0x0
801056c8:	e8 90 fd ff ff       	call   8010545d <argfd>
801056cd:	83 c4 10             	add    $0x10,%esp
801056d0:	85 c0                	test   %eax,%eax
801056d2:	78 17                	js     801056eb <sys_fstat+0x38>
801056d4:	83 ec 04             	sub    $0x4,%esp
801056d7:	6a 14                	push   $0x14
801056d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056dc:	50                   	push   %eax
801056dd:	6a 01                	push   $0x1
801056df:	e8 50 fc ff ff       	call   80105334 <argptr>
801056e4:	83 c4 10             	add    $0x10,%esp
801056e7:	85 c0                	test   %eax,%eax
801056e9:	79 07                	jns    801056f2 <sys_fstat+0x3f>
    return -1;
801056eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f0:	eb 13                	jmp    80105705 <sys_fstat+0x52>
  return filestat(f, st);
801056f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f8:	83 ec 08             	sub    $0x8,%esp
801056fb:	52                   	push   %edx
801056fc:	50                   	push   %eax
801056fd:	e8 d3 ba ff ff       	call   801011d5 <filestat>
80105702:	83 c4 10             	add    $0x10,%esp
}
80105705:	c9                   	leave  
80105706:	c3                   	ret    

80105707 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105707:	f3 0f 1e fb          	endbr32 
8010570b:	55                   	push   %ebp
8010570c:	89 e5                	mov    %esp,%ebp
8010570e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105711:	83 ec 08             	sub    $0x8,%esp
80105714:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105717:	50                   	push   %eax
80105718:	6a 00                	push   $0x0
8010571a:	e8 81 fc ff ff       	call   801053a0 <argstr>
8010571f:	83 c4 10             	add    $0x10,%esp
80105722:	85 c0                	test   %eax,%eax
80105724:	78 15                	js     8010573b <sys_link+0x34>
80105726:	83 ec 08             	sub    $0x8,%esp
80105729:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010572c:	50                   	push   %eax
8010572d:	6a 01                	push   $0x1
8010572f:	e8 6c fc ff ff       	call   801053a0 <argstr>
80105734:	83 c4 10             	add    $0x10,%esp
80105737:	85 c0                	test   %eax,%eax
80105739:	79 0a                	jns    80105745 <sys_link+0x3e>
    return -1;
8010573b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105740:	e9 68 01 00 00       	jmp    801058ad <sys_link+0x1a6>

  begin_op();
80105745:	e8 27 da ff ff       	call   80103171 <begin_op>
  if((ip = namei(old)) == 0){
8010574a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010574d:	83 ec 0c             	sub    $0xc,%esp
80105750:	50                   	push   %eax
80105751:	e8 91 ce ff ff       	call   801025e7 <namei>
80105756:	83 c4 10             	add    $0x10,%esp
80105759:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010575c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105760:	75 0f                	jne    80105771 <sys_link+0x6a>
    end_op();
80105762:	e8 9a da ff ff       	call   80103201 <end_op>
    return -1;
80105767:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010576c:	e9 3c 01 00 00       	jmp    801058ad <sys_link+0x1a6>
  }

  ilock(ip);
80105771:	83 ec 0c             	sub    $0xc,%esp
80105774:	ff 75 f4             	pushl  -0xc(%ebp)
80105777:	e8 00 c3 ff ff       	call   80101a7c <ilock>
8010577c:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010577f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105782:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105786:	66 83 f8 01          	cmp    $0x1,%ax
8010578a:	75 1d                	jne    801057a9 <sys_link+0xa2>
    iunlockput(ip);
8010578c:	83 ec 0c             	sub    $0xc,%esp
8010578f:	ff 75 f4             	pushl  -0xc(%ebp)
80105792:	e8 22 c5 ff ff       	call   80101cb9 <iunlockput>
80105797:	83 c4 10             	add    $0x10,%esp
    end_op();
8010579a:	e8 62 da ff ff       	call   80103201 <end_op>
    return -1;
8010579f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a4:	e9 04 01 00 00       	jmp    801058ad <sys_link+0x1a6>
  }

  ip->nlink++;
801057a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ac:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801057b0:	83 c0 01             	add    $0x1,%eax
801057b3:	89 c2                	mov    %eax,%edx
801057b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b8:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801057bc:	83 ec 0c             	sub    $0xc,%esp
801057bf:	ff 75 f4             	pushl  -0xc(%ebp)
801057c2:	e8 cc c0 ff ff       	call   80101893 <iupdate>
801057c7:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801057ca:	83 ec 0c             	sub    $0xc,%esp
801057cd:	ff 75 f4             	pushl  -0xc(%ebp)
801057d0:	e8 be c3 ff ff       	call   80101b93 <iunlock>
801057d5:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801057d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801057db:	83 ec 08             	sub    $0x8,%esp
801057de:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801057e1:	52                   	push   %edx
801057e2:	50                   	push   %eax
801057e3:	e8 1f ce ff ff       	call   80102607 <nameiparent>
801057e8:	83 c4 10             	add    $0x10,%esp
801057eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057f2:	74 71                	je     80105865 <sys_link+0x15e>
    goto bad;
  ilock(dp);
801057f4:	83 ec 0c             	sub    $0xc,%esp
801057f7:	ff 75 f0             	pushl  -0x10(%ebp)
801057fa:	e8 7d c2 ff ff       	call   80101a7c <ilock>
801057ff:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105802:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105805:	8b 10                	mov    (%eax),%edx
80105807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010580a:	8b 00                	mov    (%eax),%eax
8010580c:	39 c2                	cmp    %eax,%edx
8010580e:	75 1d                	jne    8010582d <sys_link+0x126>
80105810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105813:	8b 40 04             	mov    0x4(%eax),%eax
80105816:	83 ec 04             	sub    $0x4,%esp
80105819:	50                   	push   %eax
8010581a:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010581d:	50                   	push   %eax
8010581e:	ff 75 f0             	pushl  -0x10(%ebp)
80105821:	e8 1e cb ff ff       	call   80102344 <dirlink>
80105826:	83 c4 10             	add    $0x10,%esp
80105829:	85 c0                	test   %eax,%eax
8010582b:	79 10                	jns    8010583d <sys_link+0x136>
    iunlockput(dp);
8010582d:	83 ec 0c             	sub    $0xc,%esp
80105830:	ff 75 f0             	pushl  -0x10(%ebp)
80105833:	e8 81 c4 ff ff       	call   80101cb9 <iunlockput>
80105838:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010583b:	eb 29                	jmp    80105866 <sys_link+0x15f>
  }
  iunlockput(dp);
8010583d:	83 ec 0c             	sub    $0xc,%esp
80105840:	ff 75 f0             	pushl  -0x10(%ebp)
80105843:	e8 71 c4 ff ff       	call   80101cb9 <iunlockput>
80105848:	83 c4 10             	add    $0x10,%esp
  iput(ip);
8010584b:	83 ec 0c             	sub    $0xc,%esp
8010584e:	ff 75 f4             	pushl  -0xc(%ebp)
80105851:	e8 8f c3 ff ff       	call   80101be5 <iput>
80105856:	83 c4 10             	add    $0x10,%esp

  end_op();
80105859:	e8 a3 d9 ff ff       	call   80103201 <end_op>

  return 0;
8010585e:	b8 00 00 00 00       	mov    $0x0,%eax
80105863:	eb 48                	jmp    801058ad <sys_link+0x1a6>
    goto bad;
80105865:	90                   	nop

bad:
  ilock(ip);
80105866:	83 ec 0c             	sub    $0xc,%esp
80105869:	ff 75 f4             	pushl  -0xc(%ebp)
8010586c:	e8 0b c2 ff ff       	call   80101a7c <ilock>
80105871:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105877:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010587b:	83 e8 01             	sub    $0x1,%eax
8010587e:	89 c2                	mov    %eax,%edx
80105880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105883:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105887:	83 ec 0c             	sub    $0xc,%esp
8010588a:	ff 75 f4             	pushl  -0xc(%ebp)
8010588d:	e8 01 c0 ff ff       	call   80101893 <iupdate>
80105892:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105895:	83 ec 0c             	sub    $0xc,%esp
80105898:	ff 75 f4             	pushl  -0xc(%ebp)
8010589b:	e8 19 c4 ff ff       	call   80101cb9 <iunlockput>
801058a0:	83 c4 10             	add    $0x10,%esp
  end_op();
801058a3:	e8 59 d9 ff ff       	call   80103201 <end_op>
  return -1;
801058a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058ad:	c9                   	leave  
801058ae:	c3                   	ret    

801058af <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801058af:	f3 0f 1e fb          	endbr32 
801058b3:	55                   	push   %ebp
801058b4:	89 e5                	mov    %esp,%ebp
801058b6:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058b9:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801058c0:	eb 40                	jmp    80105902 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801058c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c5:	6a 10                	push   $0x10
801058c7:	50                   	push   %eax
801058c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801058cb:	50                   	push   %eax
801058cc:	ff 75 08             	pushl  0x8(%ebp)
801058cf:	e8 b0 c6 ff ff       	call   80101f84 <readi>
801058d4:	83 c4 10             	add    $0x10,%esp
801058d7:	83 f8 10             	cmp    $0x10,%eax
801058da:	74 0d                	je     801058e9 <isdirempty+0x3a>
      panic("isdirempty: readi");
801058dc:	83 ec 0c             	sub    $0xc,%esp
801058df:	68 1d ad 10 80       	push   $0x8010ad1d
801058e4:	e8 dc ac ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
801058e9:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801058ed:	66 85 c0             	test   %ax,%ax
801058f0:	74 07                	je     801058f9 <isdirempty+0x4a>
      return 0;
801058f2:	b8 00 00 00 00       	mov    $0x0,%eax
801058f7:	eb 1b                	jmp    80105914 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fc:	83 c0 10             	add    $0x10,%eax
801058ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105902:	8b 45 08             	mov    0x8(%ebp),%eax
80105905:	8b 50 58             	mov    0x58(%eax),%edx
80105908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010590b:	39 c2                	cmp    %eax,%edx
8010590d:	77 b3                	ja     801058c2 <isdirempty+0x13>
  }
  return 1;
8010590f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105914:	c9                   	leave  
80105915:	c3                   	ret    

80105916 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105916:	f3 0f 1e fb          	endbr32 
8010591a:	55                   	push   %ebp
8010591b:	89 e5                	mov    %esp,%ebp
8010591d:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105920:	83 ec 08             	sub    $0x8,%esp
80105923:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105926:	50                   	push   %eax
80105927:	6a 00                	push   $0x0
80105929:	e8 72 fa ff ff       	call   801053a0 <argstr>
8010592e:	83 c4 10             	add    $0x10,%esp
80105931:	85 c0                	test   %eax,%eax
80105933:	79 0a                	jns    8010593f <sys_unlink+0x29>
    return -1;
80105935:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010593a:	e9 bf 01 00 00       	jmp    80105afe <sys_unlink+0x1e8>

  begin_op();
8010593f:	e8 2d d8 ff ff       	call   80103171 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105944:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105947:	83 ec 08             	sub    $0x8,%esp
8010594a:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010594d:	52                   	push   %edx
8010594e:	50                   	push   %eax
8010594f:	e8 b3 cc ff ff       	call   80102607 <nameiparent>
80105954:	83 c4 10             	add    $0x10,%esp
80105957:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010595a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010595e:	75 0f                	jne    8010596f <sys_unlink+0x59>
    end_op();
80105960:	e8 9c d8 ff ff       	call   80103201 <end_op>
    return -1;
80105965:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596a:	e9 8f 01 00 00       	jmp    80105afe <sys_unlink+0x1e8>
  }

  ilock(dp);
8010596f:	83 ec 0c             	sub    $0xc,%esp
80105972:	ff 75 f4             	pushl  -0xc(%ebp)
80105975:	e8 02 c1 ff ff       	call   80101a7c <ilock>
8010597a:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010597d:	83 ec 08             	sub    $0x8,%esp
80105980:	68 2f ad 10 80       	push   $0x8010ad2f
80105985:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105988:	50                   	push   %eax
80105989:	e8 d9 c8 ff ff       	call   80102267 <namecmp>
8010598e:	83 c4 10             	add    $0x10,%esp
80105991:	85 c0                	test   %eax,%eax
80105993:	0f 84 49 01 00 00    	je     80105ae2 <sys_unlink+0x1cc>
80105999:	83 ec 08             	sub    $0x8,%esp
8010599c:	68 31 ad 10 80       	push   $0x8010ad31
801059a1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059a4:	50                   	push   %eax
801059a5:	e8 bd c8 ff ff       	call   80102267 <namecmp>
801059aa:	83 c4 10             	add    $0x10,%esp
801059ad:	85 c0                	test   %eax,%eax
801059af:	0f 84 2d 01 00 00    	je     80105ae2 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801059b5:	83 ec 04             	sub    $0x4,%esp
801059b8:	8d 45 c8             	lea    -0x38(%ebp),%eax
801059bb:	50                   	push   %eax
801059bc:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801059bf:	50                   	push   %eax
801059c0:	ff 75 f4             	pushl  -0xc(%ebp)
801059c3:	e8 be c8 ff ff       	call   80102286 <dirlookup>
801059c8:	83 c4 10             	add    $0x10,%esp
801059cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059d2:	0f 84 0d 01 00 00    	je     80105ae5 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
801059d8:	83 ec 0c             	sub    $0xc,%esp
801059db:	ff 75 f0             	pushl  -0x10(%ebp)
801059de:	e8 99 c0 ff ff       	call   80101a7c <ilock>
801059e3:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801059e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059ed:	66 85 c0             	test   %ax,%ax
801059f0:	7f 0d                	jg     801059ff <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
801059f2:	83 ec 0c             	sub    $0xc,%esp
801059f5:	68 34 ad 10 80       	push   $0x8010ad34
801059fa:	e8 c6 ab ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801059ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a02:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a06:	66 83 f8 01          	cmp    $0x1,%ax
80105a0a:	75 25                	jne    80105a31 <sys_unlink+0x11b>
80105a0c:	83 ec 0c             	sub    $0xc,%esp
80105a0f:	ff 75 f0             	pushl  -0x10(%ebp)
80105a12:	e8 98 fe ff ff       	call   801058af <isdirempty>
80105a17:	83 c4 10             	add    $0x10,%esp
80105a1a:	85 c0                	test   %eax,%eax
80105a1c:	75 13                	jne    80105a31 <sys_unlink+0x11b>
    iunlockput(ip);
80105a1e:	83 ec 0c             	sub    $0xc,%esp
80105a21:	ff 75 f0             	pushl  -0x10(%ebp)
80105a24:	e8 90 c2 ff ff       	call   80101cb9 <iunlockput>
80105a29:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105a2c:	e9 b5 00 00 00       	jmp    80105ae6 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105a31:	83 ec 04             	sub    $0x4,%esp
80105a34:	6a 10                	push   $0x10
80105a36:	6a 00                	push   $0x0
80105a38:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a3b:	50                   	push   %eax
80105a3c:	e8 6e f5 ff ff       	call   80104faf <memset>
80105a41:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a44:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105a47:	6a 10                	push   $0x10
80105a49:	50                   	push   %eax
80105a4a:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a4d:	50                   	push   %eax
80105a4e:	ff 75 f4             	pushl  -0xc(%ebp)
80105a51:	e8 87 c6 ff ff       	call   801020dd <writei>
80105a56:	83 c4 10             	add    $0x10,%esp
80105a59:	83 f8 10             	cmp    $0x10,%eax
80105a5c:	74 0d                	je     80105a6b <sys_unlink+0x155>
    panic("unlink: writei");
80105a5e:	83 ec 0c             	sub    $0xc,%esp
80105a61:	68 46 ad 10 80       	push   $0x8010ad46
80105a66:	e8 5a ab ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a72:	66 83 f8 01          	cmp    $0x1,%ax
80105a76:	75 21                	jne    80105a99 <sys_unlink+0x183>
    dp->nlink--;
80105a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a7f:	83 e8 01             	sub    $0x1,%eax
80105a82:	89 c2                	mov    %eax,%edx
80105a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a87:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a8b:	83 ec 0c             	sub    $0xc,%esp
80105a8e:	ff 75 f4             	pushl  -0xc(%ebp)
80105a91:	e8 fd bd ff ff       	call   80101893 <iupdate>
80105a96:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105a99:	83 ec 0c             	sub    $0xc,%esp
80105a9c:	ff 75 f4             	pushl  -0xc(%ebp)
80105a9f:	e8 15 c2 ff ff       	call   80101cb9 <iunlockput>
80105aa4:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aaa:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105aae:	83 e8 01             	sub    $0x1,%eax
80105ab1:	89 c2                	mov    %eax,%edx
80105ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab6:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105aba:	83 ec 0c             	sub    $0xc,%esp
80105abd:	ff 75 f0             	pushl  -0x10(%ebp)
80105ac0:	e8 ce bd ff ff       	call   80101893 <iupdate>
80105ac5:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105ac8:	83 ec 0c             	sub    $0xc,%esp
80105acb:	ff 75 f0             	pushl  -0x10(%ebp)
80105ace:	e8 e6 c1 ff ff       	call   80101cb9 <iunlockput>
80105ad3:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ad6:	e8 26 d7 ff ff       	call   80103201 <end_op>

  return 0;
80105adb:	b8 00 00 00 00       	mov    $0x0,%eax
80105ae0:	eb 1c                	jmp    80105afe <sys_unlink+0x1e8>
    goto bad;
80105ae2:	90                   	nop
80105ae3:	eb 01                	jmp    80105ae6 <sys_unlink+0x1d0>
    goto bad;
80105ae5:	90                   	nop

bad:
  iunlockput(dp);
80105ae6:	83 ec 0c             	sub    $0xc,%esp
80105ae9:	ff 75 f4             	pushl  -0xc(%ebp)
80105aec:	e8 c8 c1 ff ff       	call   80101cb9 <iunlockput>
80105af1:	83 c4 10             	add    $0x10,%esp
  end_op();
80105af4:	e8 08 d7 ff ff       	call   80103201 <end_op>
  return -1;
80105af9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105afe:	c9                   	leave  
80105aff:	c3                   	ret    

80105b00 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105b00:	f3 0f 1e fb          	endbr32 
80105b04:	55                   	push   %ebp
80105b05:	89 e5                	mov    %esp,%ebp
80105b07:	83 ec 38             	sub    $0x38,%esp
80105b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105b0d:	8b 55 10             	mov    0x10(%ebp),%edx
80105b10:	8b 45 14             	mov    0x14(%ebp),%eax
80105b13:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105b17:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105b1b:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105b1f:	83 ec 08             	sub    $0x8,%esp
80105b22:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b25:	50                   	push   %eax
80105b26:	ff 75 08             	pushl  0x8(%ebp)
80105b29:	e8 d9 ca ff ff       	call   80102607 <nameiparent>
80105b2e:	83 c4 10             	add    $0x10,%esp
80105b31:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b38:	75 0a                	jne    80105b44 <create+0x44>
    return 0;
80105b3a:	b8 00 00 00 00       	mov    $0x0,%eax
80105b3f:	e9 90 01 00 00       	jmp    80105cd4 <create+0x1d4>
  ilock(dp);
80105b44:	83 ec 0c             	sub    $0xc,%esp
80105b47:	ff 75 f4             	pushl  -0xc(%ebp)
80105b4a:	e8 2d bf ff ff       	call   80101a7c <ilock>
80105b4f:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105b52:	83 ec 04             	sub    $0x4,%esp
80105b55:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b58:	50                   	push   %eax
80105b59:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b5c:	50                   	push   %eax
80105b5d:	ff 75 f4             	pushl  -0xc(%ebp)
80105b60:	e8 21 c7 ff ff       	call   80102286 <dirlookup>
80105b65:	83 c4 10             	add    $0x10,%esp
80105b68:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b6f:	74 50                	je     80105bc1 <create+0xc1>
    iunlockput(dp);
80105b71:	83 ec 0c             	sub    $0xc,%esp
80105b74:	ff 75 f4             	pushl  -0xc(%ebp)
80105b77:	e8 3d c1 ff ff       	call   80101cb9 <iunlockput>
80105b7c:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105b7f:	83 ec 0c             	sub    $0xc,%esp
80105b82:	ff 75 f0             	pushl  -0x10(%ebp)
80105b85:	e8 f2 be ff ff       	call   80101a7c <ilock>
80105b8a:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105b8d:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105b92:	75 15                	jne    80105ba9 <create+0xa9>
80105b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b97:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b9b:	66 83 f8 02          	cmp    $0x2,%ax
80105b9f:	75 08                	jne    80105ba9 <create+0xa9>
      return ip;
80105ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba4:	e9 2b 01 00 00       	jmp    80105cd4 <create+0x1d4>
    iunlockput(ip);
80105ba9:	83 ec 0c             	sub    $0xc,%esp
80105bac:	ff 75 f0             	pushl  -0x10(%ebp)
80105baf:	e8 05 c1 ff ff       	call   80101cb9 <iunlockput>
80105bb4:	83 c4 10             	add    $0x10,%esp
    return 0;
80105bb7:	b8 00 00 00 00       	mov    $0x0,%eax
80105bbc:	e9 13 01 00 00       	jmp    80105cd4 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105bc1:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc8:	8b 00                	mov    (%eax),%eax
80105bca:	83 ec 08             	sub    $0x8,%esp
80105bcd:	52                   	push   %edx
80105bce:	50                   	push   %eax
80105bcf:	e8 e4 bb ff ff       	call   801017b8 <ialloc>
80105bd4:	83 c4 10             	add    $0x10,%esp
80105bd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bde:	75 0d                	jne    80105bed <create+0xed>
    panic("create: ialloc");
80105be0:	83 ec 0c             	sub    $0xc,%esp
80105be3:	68 55 ad 10 80       	push   $0x8010ad55
80105be8:	e8 d8 a9 ff ff       	call   801005c5 <panic>

  ilock(ip);
80105bed:	83 ec 0c             	sub    $0xc,%esp
80105bf0:	ff 75 f0             	pushl  -0x10(%ebp)
80105bf3:	e8 84 be ff ff       	call   80101a7c <ilock>
80105bf8:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfe:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105c02:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c09:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105c0d:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c14:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105c1a:	83 ec 0c             	sub    $0xc,%esp
80105c1d:	ff 75 f0             	pushl  -0x10(%ebp)
80105c20:	e8 6e bc ff ff       	call   80101893 <iupdate>
80105c25:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105c28:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105c2d:	75 6a                	jne    80105c99 <create+0x199>
    dp->nlink++;  // for ".."
80105c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c32:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c36:	83 c0 01             	add    $0x1,%eax
80105c39:	89 c2                	mov    %eax,%edx
80105c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3e:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105c42:	83 ec 0c             	sub    $0xc,%esp
80105c45:	ff 75 f4             	pushl  -0xc(%ebp)
80105c48:	e8 46 bc ff ff       	call   80101893 <iupdate>
80105c4d:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105c50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c53:	8b 40 04             	mov    0x4(%eax),%eax
80105c56:	83 ec 04             	sub    $0x4,%esp
80105c59:	50                   	push   %eax
80105c5a:	68 2f ad 10 80       	push   $0x8010ad2f
80105c5f:	ff 75 f0             	pushl  -0x10(%ebp)
80105c62:	e8 dd c6 ff ff       	call   80102344 <dirlink>
80105c67:	83 c4 10             	add    $0x10,%esp
80105c6a:	85 c0                	test   %eax,%eax
80105c6c:	78 1e                	js     80105c8c <create+0x18c>
80105c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c71:	8b 40 04             	mov    0x4(%eax),%eax
80105c74:	83 ec 04             	sub    $0x4,%esp
80105c77:	50                   	push   %eax
80105c78:	68 31 ad 10 80       	push   $0x8010ad31
80105c7d:	ff 75 f0             	pushl  -0x10(%ebp)
80105c80:	e8 bf c6 ff ff       	call   80102344 <dirlink>
80105c85:	83 c4 10             	add    $0x10,%esp
80105c88:	85 c0                	test   %eax,%eax
80105c8a:	79 0d                	jns    80105c99 <create+0x199>
      panic("create dots");
80105c8c:	83 ec 0c             	sub    $0xc,%esp
80105c8f:	68 64 ad 10 80       	push   $0x8010ad64
80105c94:	e8 2c a9 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9c:	8b 40 04             	mov    0x4(%eax),%eax
80105c9f:	83 ec 04             	sub    $0x4,%esp
80105ca2:	50                   	push   %eax
80105ca3:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ca6:	50                   	push   %eax
80105ca7:	ff 75 f4             	pushl  -0xc(%ebp)
80105caa:	e8 95 c6 ff ff       	call   80102344 <dirlink>
80105caf:	83 c4 10             	add    $0x10,%esp
80105cb2:	85 c0                	test   %eax,%eax
80105cb4:	79 0d                	jns    80105cc3 <create+0x1c3>
    panic("create: dirlink");
80105cb6:	83 ec 0c             	sub    $0xc,%esp
80105cb9:	68 70 ad 10 80       	push   $0x8010ad70
80105cbe:	e8 02 a9 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80105cc3:	83 ec 0c             	sub    $0xc,%esp
80105cc6:	ff 75 f4             	pushl  -0xc(%ebp)
80105cc9:	e8 eb bf ff ff       	call   80101cb9 <iunlockput>
80105cce:	83 c4 10             	add    $0x10,%esp

  return ip;
80105cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105cd4:	c9                   	leave  
80105cd5:	c3                   	ret    

80105cd6 <sys_open>:

int
sys_open(void)
{
80105cd6:	f3 0f 1e fb          	endbr32 
80105cda:	55                   	push   %ebp
80105cdb:	89 e5                	mov    %esp,%ebp
80105cdd:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ce0:	83 ec 08             	sub    $0x8,%esp
80105ce3:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ce6:	50                   	push   %eax
80105ce7:	6a 00                	push   $0x0
80105ce9:	e8 b2 f6 ff ff       	call   801053a0 <argstr>
80105cee:	83 c4 10             	add    $0x10,%esp
80105cf1:	85 c0                	test   %eax,%eax
80105cf3:	78 15                	js     80105d0a <sys_open+0x34>
80105cf5:	83 ec 08             	sub    $0x8,%esp
80105cf8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cfb:	50                   	push   %eax
80105cfc:	6a 01                	push   $0x1
80105cfe:	e8 00 f6 ff ff       	call   80105303 <argint>
80105d03:	83 c4 10             	add    $0x10,%esp
80105d06:	85 c0                	test   %eax,%eax
80105d08:	79 0a                	jns    80105d14 <sys_open+0x3e>
    return -1;
80105d0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0f:	e9 61 01 00 00       	jmp    80105e75 <sys_open+0x19f>

  begin_op();
80105d14:	e8 58 d4 ff ff       	call   80103171 <begin_op>

  if(omode & O_CREATE){
80105d19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d1c:	25 00 02 00 00       	and    $0x200,%eax
80105d21:	85 c0                	test   %eax,%eax
80105d23:	74 2a                	je     80105d4f <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105d25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d28:	6a 00                	push   $0x0
80105d2a:	6a 00                	push   $0x0
80105d2c:	6a 02                	push   $0x2
80105d2e:	50                   	push   %eax
80105d2f:	e8 cc fd ff ff       	call   80105b00 <create>
80105d34:	83 c4 10             	add    $0x10,%esp
80105d37:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105d3a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d3e:	75 75                	jne    80105db5 <sys_open+0xdf>
      end_op();
80105d40:	e8 bc d4 ff ff       	call   80103201 <end_op>
      return -1;
80105d45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4a:	e9 26 01 00 00       	jmp    80105e75 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105d4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d52:	83 ec 0c             	sub    $0xc,%esp
80105d55:	50                   	push   %eax
80105d56:	e8 8c c8 ff ff       	call   801025e7 <namei>
80105d5b:	83 c4 10             	add    $0x10,%esp
80105d5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d65:	75 0f                	jne    80105d76 <sys_open+0xa0>
      end_op();
80105d67:	e8 95 d4 ff ff       	call   80103201 <end_op>
      return -1;
80105d6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d71:	e9 ff 00 00 00       	jmp    80105e75 <sys_open+0x19f>
    }
    ilock(ip);
80105d76:	83 ec 0c             	sub    $0xc,%esp
80105d79:	ff 75 f4             	pushl  -0xc(%ebp)
80105d7c:	e8 fb bc ff ff       	call   80101a7c <ilock>
80105d81:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d87:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d8b:	66 83 f8 01          	cmp    $0x1,%ax
80105d8f:	75 24                	jne    80105db5 <sys_open+0xdf>
80105d91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d94:	85 c0                	test   %eax,%eax
80105d96:	74 1d                	je     80105db5 <sys_open+0xdf>
      iunlockput(ip);
80105d98:	83 ec 0c             	sub    $0xc,%esp
80105d9b:	ff 75 f4             	pushl  -0xc(%ebp)
80105d9e:	e8 16 bf ff ff       	call   80101cb9 <iunlockput>
80105da3:	83 c4 10             	add    $0x10,%esp
      end_op();
80105da6:	e8 56 d4 ff ff       	call   80103201 <end_op>
      return -1;
80105dab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db0:	e9 c0 00 00 00       	jmp    80105e75 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105db5:	e8 69 b2 ff ff       	call   80101023 <filealloc>
80105dba:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dbd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dc1:	74 17                	je     80105dda <sys_open+0x104>
80105dc3:	83 ec 0c             	sub    $0xc,%esp
80105dc6:	ff 75 f0             	pushl  -0x10(%ebp)
80105dc9:	e8 07 f7 ff ff       	call   801054d5 <fdalloc>
80105dce:	83 c4 10             	add    $0x10,%esp
80105dd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105dd4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105dd8:	79 2e                	jns    80105e08 <sys_open+0x132>
    if(f)
80105dda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dde:	74 0e                	je     80105dee <sys_open+0x118>
      fileclose(f);
80105de0:	83 ec 0c             	sub    $0xc,%esp
80105de3:	ff 75 f0             	pushl  -0x10(%ebp)
80105de6:	e8 fe b2 ff ff       	call   801010e9 <fileclose>
80105deb:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105dee:	83 ec 0c             	sub    $0xc,%esp
80105df1:	ff 75 f4             	pushl  -0xc(%ebp)
80105df4:	e8 c0 be ff ff       	call   80101cb9 <iunlockput>
80105df9:	83 c4 10             	add    $0x10,%esp
    end_op();
80105dfc:	e8 00 d4 ff ff       	call   80103201 <end_op>
    return -1;
80105e01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e06:	eb 6d                	jmp    80105e75 <sys_open+0x19f>
  }
  iunlock(ip);
80105e08:	83 ec 0c             	sub    $0xc,%esp
80105e0b:	ff 75 f4             	pushl  -0xc(%ebp)
80105e0e:	e8 80 bd ff ff       	call   80101b93 <iunlock>
80105e13:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e16:	e8 e6 d3 ff ff       	call   80103201 <end_op>

  f->type = FD_INODE;
80105e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e2a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e30:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e3a:	83 e0 01             	and    $0x1,%eax
80105e3d:	85 c0                	test   %eax,%eax
80105e3f:	0f 94 c0             	sete   %al
80105e42:	89 c2                	mov    %eax,%edx
80105e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e47:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105e4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e4d:	83 e0 01             	and    $0x1,%eax
80105e50:	85 c0                	test   %eax,%eax
80105e52:	75 0a                	jne    80105e5e <sys_open+0x188>
80105e54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e57:	83 e0 02             	and    $0x2,%eax
80105e5a:	85 c0                	test   %eax,%eax
80105e5c:	74 07                	je     80105e65 <sys_open+0x18f>
80105e5e:	b8 01 00 00 00       	mov    $0x1,%eax
80105e63:	eb 05                	jmp    80105e6a <sys_open+0x194>
80105e65:	b8 00 00 00 00       	mov    $0x0,%eax
80105e6a:	89 c2                	mov    %eax,%edx
80105e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6f:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105e75:	c9                   	leave  
80105e76:	c3                   	ret    

80105e77 <sys_mkdir>:

int
sys_mkdir(void)
{
80105e77:	f3 0f 1e fb          	endbr32 
80105e7b:	55                   	push   %ebp
80105e7c:	89 e5                	mov    %esp,%ebp
80105e7e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105e81:	e8 eb d2 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105e86:	83 ec 08             	sub    $0x8,%esp
80105e89:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e8c:	50                   	push   %eax
80105e8d:	6a 00                	push   $0x0
80105e8f:	e8 0c f5 ff ff       	call   801053a0 <argstr>
80105e94:	83 c4 10             	add    $0x10,%esp
80105e97:	85 c0                	test   %eax,%eax
80105e99:	78 1b                	js     80105eb6 <sys_mkdir+0x3f>
80105e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9e:	6a 00                	push   $0x0
80105ea0:	6a 00                	push   $0x0
80105ea2:	6a 01                	push   $0x1
80105ea4:	50                   	push   %eax
80105ea5:	e8 56 fc ff ff       	call   80105b00 <create>
80105eaa:	83 c4 10             	add    $0x10,%esp
80105ead:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eb4:	75 0c                	jne    80105ec2 <sys_mkdir+0x4b>
    end_op();
80105eb6:	e8 46 d3 ff ff       	call   80103201 <end_op>
    return -1;
80105ebb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec0:	eb 18                	jmp    80105eda <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105ec2:	83 ec 0c             	sub    $0xc,%esp
80105ec5:	ff 75 f4             	pushl  -0xc(%ebp)
80105ec8:	e8 ec bd ff ff       	call   80101cb9 <iunlockput>
80105ecd:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ed0:	e8 2c d3 ff ff       	call   80103201 <end_op>
  return 0;
80105ed5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105eda:	c9                   	leave  
80105edb:	c3                   	ret    

80105edc <sys_mknod>:

int
sys_mknod(void)
{
80105edc:	f3 0f 1e fb          	endbr32 
80105ee0:	55                   	push   %ebp
80105ee1:	89 e5                	mov    %esp,%ebp
80105ee3:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105ee6:	e8 86 d2 ff ff       	call   80103171 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105eeb:	83 ec 08             	sub    $0x8,%esp
80105eee:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ef1:	50                   	push   %eax
80105ef2:	6a 00                	push   $0x0
80105ef4:	e8 a7 f4 ff ff       	call   801053a0 <argstr>
80105ef9:	83 c4 10             	add    $0x10,%esp
80105efc:	85 c0                	test   %eax,%eax
80105efe:	78 4f                	js     80105f4f <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105f00:	83 ec 08             	sub    $0x8,%esp
80105f03:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f06:	50                   	push   %eax
80105f07:	6a 01                	push   $0x1
80105f09:	e8 f5 f3 ff ff       	call   80105303 <argint>
80105f0e:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105f11:	85 c0                	test   %eax,%eax
80105f13:	78 3a                	js     80105f4f <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105f15:	83 ec 08             	sub    $0x8,%esp
80105f18:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f1b:	50                   	push   %eax
80105f1c:	6a 02                	push   $0x2
80105f1e:	e8 e0 f3 ff ff       	call   80105303 <argint>
80105f23:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105f26:	85 c0                	test   %eax,%eax
80105f28:	78 25                	js     80105f4f <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105f2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f2d:	0f bf c8             	movswl %ax,%ecx
80105f30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f33:	0f bf d0             	movswl %ax,%edx
80105f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f39:	51                   	push   %ecx
80105f3a:	52                   	push   %edx
80105f3b:	6a 03                	push   $0x3
80105f3d:	50                   	push   %eax
80105f3e:	e8 bd fb ff ff       	call   80105b00 <create>
80105f43:	83 c4 10             	add    $0x10,%esp
80105f46:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105f49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f4d:	75 0c                	jne    80105f5b <sys_mknod+0x7f>
    end_op();
80105f4f:	e8 ad d2 ff ff       	call   80103201 <end_op>
    return -1;
80105f54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f59:	eb 18                	jmp    80105f73 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105f5b:	83 ec 0c             	sub    $0xc,%esp
80105f5e:	ff 75 f4             	pushl  -0xc(%ebp)
80105f61:	e8 53 bd ff ff       	call   80101cb9 <iunlockput>
80105f66:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f69:	e8 93 d2 ff ff       	call   80103201 <end_op>
  return 0;
80105f6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f73:	c9                   	leave  
80105f74:	c3                   	ret    

80105f75 <sys_chdir>:

int
sys_chdir(void)
{
80105f75:	f3 0f 1e fb          	endbr32 
80105f79:	55                   	push   %ebp
80105f7a:	89 e5                	mov    %esp,%ebp
80105f7c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105f7f:	e8 25 dc ff ff       	call   80103ba9 <myproc>
80105f84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105f87:	e8 e5 d1 ff ff       	call   80103171 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105f8c:	83 ec 08             	sub    $0x8,%esp
80105f8f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f92:	50                   	push   %eax
80105f93:	6a 00                	push   $0x0
80105f95:	e8 06 f4 ff ff       	call   801053a0 <argstr>
80105f9a:	83 c4 10             	add    $0x10,%esp
80105f9d:	85 c0                	test   %eax,%eax
80105f9f:	78 18                	js     80105fb9 <sys_chdir+0x44>
80105fa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105fa4:	83 ec 0c             	sub    $0xc,%esp
80105fa7:	50                   	push   %eax
80105fa8:	e8 3a c6 ff ff       	call   801025e7 <namei>
80105fad:	83 c4 10             	add    $0x10,%esp
80105fb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fb3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fb7:	75 0c                	jne    80105fc5 <sys_chdir+0x50>
    end_op();
80105fb9:	e8 43 d2 ff ff       	call   80103201 <end_op>
    return -1;
80105fbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc3:	eb 68                	jmp    8010602d <sys_chdir+0xb8>
  }
  ilock(ip);
80105fc5:	83 ec 0c             	sub    $0xc,%esp
80105fc8:	ff 75 f0             	pushl  -0x10(%ebp)
80105fcb:	e8 ac ba ff ff       	call   80101a7c <ilock>
80105fd0:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105fda:	66 83 f8 01          	cmp    $0x1,%ax
80105fde:	74 1a                	je     80105ffa <sys_chdir+0x85>
    iunlockput(ip);
80105fe0:	83 ec 0c             	sub    $0xc,%esp
80105fe3:	ff 75 f0             	pushl  -0x10(%ebp)
80105fe6:	e8 ce bc ff ff       	call   80101cb9 <iunlockput>
80105feb:	83 c4 10             	add    $0x10,%esp
    end_op();
80105fee:	e8 0e d2 ff ff       	call   80103201 <end_op>
    return -1;
80105ff3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff8:	eb 33                	jmp    8010602d <sys_chdir+0xb8>
  }
  iunlock(ip);
80105ffa:	83 ec 0c             	sub    $0xc,%esp
80105ffd:	ff 75 f0             	pushl  -0x10(%ebp)
80106000:	e8 8e bb ff ff       	call   80101b93 <iunlock>
80106005:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600b:	8b 40 68             	mov    0x68(%eax),%eax
8010600e:	83 ec 0c             	sub    $0xc,%esp
80106011:	50                   	push   %eax
80106012:	e8 ce bb ff ff       	call   80101be5 <iput>
80106017:	83 c4 10             	add    $0x10,%esp
  end_op();
8010601a:	e8 e2 d1 ff ff       	call   80103201 <end_op>
  curproc->cwd = ip;
8010601f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106022:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106025:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106028:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010602d:	c9                   	leave  
8010602e:	c3                   	ret    

8010602f <sys_exec>:

int
sys_exec(void)
{
8010602f:	f3 0f 1e fb          	endbr32 
80106033:	55                   	push   %ebp
80106034:	89 e5                	mov    %esp,%ebp
80106036:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010603c:	83 ec 08             	sub    $0x8,%esp
8010603f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106042:	50                   	push   %eax
80106043:	6a 00                	push   $0x0
80106045:	e8 56 f3 ff ff       	call   801053a0 <argstr>
8010604a:	83 c4 10             	add    $0x10,%esp
8010604d:	85 c0                	test   %eax,%eax
8010604f:	78 18                	js     80106069 <sys_exec+0x3a>
80106051:	83 ec 08             	sub    $0x8,%esp
80106054:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010605a:	50                   	push   %eax
8010605b:	6a 01                	push   $0x1
8010605d:	e8 a1 f2 ff ff       	call   80105303 <argint>
80106062:	83 c4 10             	add    $0x10,%esp
80106065:	85 c0                	test   %eax,%eax
80106067:	79 0a                	jns    80106073 <sys_exec+0x44>
    return -1;
80106069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606e:	e9 c6 00 00 00       	jmp    80106139 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106073:	83 ec 04             	sub    $0x4,%esp
80106076:	68 80 00 00 00       	push   $0x80
8010607b:	6a 00                	push   $0x0
8010607d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106083:	50                   	push   %eax
80106084:	e8 26 ef ff ff       	call   80104faf <memset>
80106089:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010608c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106093:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106096:	83 f8 1f             	cmp    $0x1f,%eax
80106099:	76 0a                	jbe    801060a5 <sys_exec+0x76>
      return -1;
8010609b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a0:	e9 94 00 00 00       	jmp    80106139 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801060a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a8:	c1 e0 02             	shl    $0x2,%eax
801060ab:	89 c2                	mov    %eax,%edx
801060ad:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801060b3:	01 c2                	add    %eax,%edx
801060b5:	83 ec 08             	sub    $0x8,%esp
801060b8:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801060be:	50                   	push   %eax
801060bf:	52                   	push   %edx
801060c0:	e8 93 f1 ff ff       	call   80105258 <fetchint>
801060c5:	83 c4 10             	add    $0x10,%esp
801060c8:	85 c0                	test   %eax,%eax
801060ca:	79 07                	jns    801060d3 <sys_exec+0xa4>
      return -1;
801060cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d1:	eb 66                	jmp    80106139 <sys_exec+0x10a>
    if(uarg == 0){
801060d3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801060d9:	85 c0                	test   %eax,%eax
801060db:	75 27                	jne    80106104 <sys_exec+0xd5>
      argv[i] = 0;
801060dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e0:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801060e7:	00 00 00 00 
      break;
801060eb:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801060ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ef:	83 ec 08             	sub    $0x8,%esp
801060f2:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801060f8:	52                   	push   %edx
801060f9:	50                   	push   %eax
801060fa:	e8 bf aa ff ff       	call   80100bbe <exec>
801060ff:	83 c4 10             	add    $0x10,%esp
80106102:	eb 35                	jmp    80106139 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106104:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010610a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010610d:	c1 e2 02             	shl    $0x2,%edx
80106110:	01 c2                	add    %eax,%edx
80106112:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106118:	83 ec 08             	sub    $0x8,%esp
8010611b:	52                   	push   %edx
8010611c:	50                   	push   %eax
8010611d:	e8 79 f1 ff ff       	call   8010529b <fetchstr>
80106122:	83 c4 10             	add    $0x10,%esp
80106125:	85 c0                	test   %eax,%eax
80106127:	79 07                	jns    80106130 <sys_exec+0x101>
      return -1;
80106129:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010612e:	eb 09                	jmp    80106139 <sys_exec+0x10a>
  for(i=0;; i++){
80106130:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106134:	e9 5a ff ff ff       	jmp    80106093 <sys_exec+0x64>
}
80106139:	c9                   	leave  
8010613a:	c3                   	ret    

8010613b <sys_pipe>:

int
sys_pipe(void)
{
8010613b:	f3 0f 1e fb          	endbr32 
8010613f:	55                   	push   %ebp
80106140:	89 e5                	mov    %esp,%ebp
80106142:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106145:	83 ec 04             	sub    $0x4,%esp
80106148:	6a 08                	push   $0x8
8010614a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010614d:	50                   	push   %eax
8010614e:	6a 00                	push   $0x0
80106150:	e8 df f1 ff ff       	call   80105334 <argptr>
80106155:	83 c4 10             	add    $0x10,%esp
80106158:	85 c0                	test   %eax,%eax
8010615a:	79 0a                	jns    80106166 <sys_pipe+0x2b>
    return -1;
8010615c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106161:	e9 ae 00 00 00       	jmp    80106214 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106166:	83 ec 08             	sub    $0x8,%esp
80106169:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010616c:	50                   	push   %eax
8010616d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106170:	50                   	push   %eax
80106171:	e8 54 d5 ff ff       	call   801036ca <pipealloc>
80106176:	83 c4 10             	add    $0x10,%esp
80106179:	85 c0                	test   %eax,%eax
8010617b:	79 0a                	jns    80106187 <sys_pipe+0x4c>
    return -1;
8010617d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106182:	e9 8d 00 00 00       	jmp    80106214 <sys_pipe+0xd9>
  fd0 = -1;
80106187:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010618e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106191:	83 ec 0c             	sub    $0xc,%esp
80106194:	50                   	push   %eax
80106195:	e8 3b f3 ff ff       	call   801054d5 <fdalloc>
8010619a:	83 c4 10             	add    $0x10,%esp
8010619d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061a4:	78 18                	js     801061be <sys_pipe+0x83>
801061a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061a9:	83 ec 0c             	sub    $0xc,%esp
801061ac:	50                   	push   %eax
801061ad:	e8 23 f3 ff ff       	call   801054d5 <fdalloc>
801061b2:	83 c4 10             	add    $0x10,%esp
801061b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061bc:	79 3e                	jns    801061fc <sys_pipe+0xc1>
    if(fd0 >= 0)
801061be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061c2:	78 13                	js     801061d7 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
801061c4:	e8 e0 d9 ff ff       	call   80103ba9 <myproc>
801061c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061cc:	83 c2 08             	add    $0x8,%edx
801061cf:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801061d6:	00 
    fileclose(rf);
801061d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061da:	83 ec 0c             	sub    $0xc,%esp
801061dd:	50                   	push   %eax
801061de:	e8 06 af ff ff       	call   801010e9 <fileclose>
801061e3:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801061e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e9:	83 ec 0c             	sub    $0xc,%esp
801061ec:	50                   	push   %eax
801061ed:	e8 f7 ae ff ff       	call   801010e9 <fileclose>
801061f2:	83 c4 10             	add    $0x10,%esp
    return -1;
801061f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061fa:	eb 18                	jmp    80106214 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801061fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106202:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106204:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106207:	8d 50 04             	lea    0x4(%eax),%edx
8010620a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620d:	89 02                	mov    %eax,(%edx)
  return 0;
8010620f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106214:	c9                   	leave  
80106215:	c3                   	ret    

80106216 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106216:	f3 0f 1e fb          	endbr32 
8010621a:	55                   	push   %ebp
8010621b:	89 e5                	mov    %esp,%ebp
8010621d:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106220:	e8 a7 dc ff ff       	call   80103ecc <fork>
}
80106225:	c9                   	leave  
80106226:	c3                   	ret    

80106227 <sys_exit>:

int
sys_exit(void)
{
80106227:	f3 0f 1e fb          	endbr32 
8010622b:	55                   	push   %ebp
8010622c:	89 e5                	mov    %esp,%ebp
8010622e:	83 ec 08             	sub    $0x8,%esp
  exit();
80106231:	e8 13 de ff ff       	call   80104049 <exit>
  return 0;  // not reached
80106236:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010623b:	c9                   	leave  
8010623c:	c3                   	ret    

8010623d <sys_wait>:

int
sys_wait(void)
{
8010623d:	f3 0f 1e fb          	endbr32 
80106241:	55                   	push   %ebp
80106242:	89 e5                	mov    %esp,%ebp
80106244:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106247:	e8 61 e0 ff ff       	call   801042ad <wait>
}
8010624c:	c9                   	leave  
8010624d:	c3                   	ret    

8010624e <sys_kill>:

int
sys_kill(void)
{
8010624e:	f3 0f 1e fb          	endbr32 
80106252:	55                   	push   %ebp
80106253:	89 e5                	mov    %esp,%ebp
80106255:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106258:	83 ec 08             	sub    $0x8,%esp
8010625b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010625e:	50                   	push   %eax
8010625f:	6a 00                	push   $0x0
80106261:	e8 9d f0 ff ff       	call   80105303 <argint>
80106266:	83 c4 10             	add    $0x10,%esp
80106269:	85 c0                	test   %eax,%eax
8010626b:	79 07                	jns    80106274 <sys_kill+0x26>
    return -1;
8010626d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106272:	eb 0f                	jmp    80106283 <sys_kill+0x35>
  return kill(pid);
80106274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106277:	83 ec 0c             	sub    $0xc,%esp
8010627a:	50                   	push   %eax
8010627b:	e8 ed e5 ff ff       	call   8010486d <kill>
80106280:	83 c4 10             	add    $0x10,%esp
}
80106283:	c9                   	leave  
80106284:	c3                   	ret    

80106285 <sys_getpid>:

int
sys_getpid(void)
{
80106285:	f3 0f 1e fb          	endbr32 
80106289:	55                   	push   %ebp
8010628a:	89 e5                	mov    %esp,%ebp
8010628c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010628f:	e8 15 d9 ff ff       	call   80103ba9 <myproc>
80106294:	8b 40 10             	mov    0x10(%eax),%eax
}
80106297:	c9                   	leave  
80106298:	c3                   	ret    

80106299 <sys_sbrk>:

int
sys_sbrk(void)
{
80106299:	f3 0f 1e fb          	endbr32 
8010629d:	55                   	push   %ebp
8010629e:	89 e5                	mov    %esp,%ebp
801062a0:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801062a3:	83 ec 08             	sub    $0x8,%esp
801062a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062a9:	50                   	push   %eax
801062aa:	6a 00                	push   $0x0
801062ac:	e8 52 f0 ff ff       	call   80105303 <argint>
801062b1:	83 c4 10             	add    $0x10,%esp
801062b4:	85 c0                	test   %eax,%eax
801062b6:	79 07                	jns    801062bf <sys_sbrk+0x26>
    return -1;
801062b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062bd:	eb 27                	jmp    801062e6 <sys_sbrk+0x4d>
  addr = myproc()->sz;
801062bf:	e8 e5 d8 ff ff       	call   80103ba9 <myproc>
801062c4:	8b 00                	mov    (%eax),%eax
801062c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801062c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062cc:	83 ec 0c             	sub    $0xc,%esp
801062cf:	50                   	push   %eax
801062d0:	e8 58 db ff ff       	call   80103e2d <growproc>
801062d5:	83 c4 10             	add    $0x10,%esp
801062d8:	85 c0                	test   %eax,%eax
801062da:	79 07                	jns    801062e3 <sys_sbrk+0x4a>
    return -1;
801062dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e1:	eb 03                	jmp    801062e6 <sys_sbrk+0x4d>
  return addr;
801062e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062e6:	c9                   	leave  
801062e7:	c3                   	ret    

801062e8 <sys_sleep>:

int
sys_sleep(void)
{
801062e8:	f3 0f 1e fb          	endbr32 
801062ec:	55                   	push   %ebp
801062ed:	89 e5                	mov    %esp,%ebp
801062ef:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801062f2:	83 ec 08             	sub    $0x8,%esp
801062f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062f8:	50                   	push   %eax
801062f9:	6a 00                	push   $0x0
801062fb:	e8 03 f0 ff ff       	call   80105303 <argint>
80106300:	83 c4 10             	add    $0x10,%esp
80106303:	85 c0                	test   %eax,%eax
80106305:	79 07                	jns    8010630e <sys_sleep+0x26>
    return -1;
80106307:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630c:	eb 76                	jmp    80106384 <sys_sleep+0x9c>
  acquire(&tickslock);
8010630e:	83 ec 0c             	sub    $0xc,%esp
80106311:	68 40 76 19 80       	push   $0x80197640
80106316:	e8 05 ea ff ff       	call   80104d20 <acquire>
8010631b:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010631e:	a1 80 7e 19 80       	mov    0x80197e80,%eax
80106323:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106326:	eb 38                	jmp    80106360 <sys_sleep+0x78>
    if(myproc()->killed){
80106328:	e8 7c d8 ff ff       	call   80103ba9 <myproc>
8010632d:	8b 40 24             	mov    0x24(%eax),%eax
80106330:	85 c0                	test   %eax,%eax
80106332:	74 17                	je     8010634b <sys_sleep+0x63>
      release(&tickslock);
80106334:	83 ec 0c             	sub    $0xc,%esp
80106337:	68 40 76 19 80       	push   $0x80197640
8010633c:	e8 51 ea ff ff       	call   80104d92 <release>
80106341:	83 c4 10             	add    $0x10,%esp
      return -1;
80106344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106349:	eb 39                	jmp    80106384 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
8010634b:	83 ec 08             	sub    $0x8,%esp
8010634e:	68 40 76 19 80       	push   $0x80197640
80106353:	68 80 7e 19 80       	push   $0x80197e80
80106358:	e8 e3 e3 ff ff       	call   80104740 <sleep>
8010635d:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106360:	a1 80 7e 19 80       	mov    0x80197e80,%eax
80106365:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106368:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010636b:	39 d0                	cmp    %edx,%eax
8010636d:	72 b9                	jb     80106328 <sys_sleep+0x40>
  }
  release(&tickslock);
8010636f:	83 ec 0c             	sub    $0xc,%esp
80106372:	68 40 76 19 80       	push   $0x80197640
80106377:	e8 16 ea ff ff       	call   80104d92 <release>
8010637c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010637f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106384:	c9                   	leave  
80106385:	c3                   	ret    

80106386 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106386:	f3 0f 1e fb          	endbr32 
8010638a:	55                   	push   %ebp
8010638b:	89 e5                	mov    %esp,%ebp
8010638d:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106390:	83 ec 0c             	sub    $0xc,%esp
80106393:	68 40 76 19 80       	push   $0x80197640
80106398:	e8 83 e9 ff ff       	call   80104d20 <acquire>
8010639d:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801063a0:	a1 80 7e 19 80       	mov    0x80197e80,%eax
801063a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801063a8:	83 ec 0c             	sub    $0xc,%esp
801063ab:	68 40 76 19 80       	push   $0x80197640
801063b0:	e8 dd e9 ff ff       	call   80104d92 <release>
801063b5:	83 c4 10             	add    $0x10,%esp
  return xticks;
801063b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063bb:	c9                   	leave  
801063bc:	c3                   	ret    

801063bd <sys_exit2>:

int
sys_exit2(void)
{
801063bd:	f3 0f 1e fb          	endbr32 
801063c1:	55                   	push   %ebp
801063c2:	89 e5                	mov    %esp,%ebp
801063c4:	83 ec 18             	sub    $0x18,%esp
  int status;
  if(argint(0, &status) < 0)
801063c7:	83 ec 08             	sub    $0x8,%esp
801063ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063cd:	50                   	push   %eax
801063ce:	6a 00                	push   $0x0
801063d0:	e8 2e ef ff ff       	call   80105303 <argint>
801063d5:	83 c4 10             	add    $0x10,%esp
801063d8:	85 c0                	test   %eax,%eax
801063da:	79 07                	jns    801063e3 <sys_exit2+0x26>
    return -1; 
801063dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e1:	eb 15                	jmp    801063f8 <sys_exit2+0x3b>

  myproc()->xstate = status;
801063e3:	e8 c1 d7 ff ff       	call   80103ba9 <myproc>
801063e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063eb:	89 50 7c             	mov    %edx,0x7c(%eax)
  exit();
801063ee:	e8 56 dc ff ff       	call   80104049 <exit>
  return 0;
801063f3:	b8 00 00 00 00       	mov    $0x0,%eax
}	
801063f8:	c9                   	leave  
801063f9:	c3                   	ret    

801063fa <sys_wait2>:

extern int wait2(int *status);

int sys_wait2(void) 
{
801063fa:	f3 0f 1e fb          	endbr32 
801063fe:	55                   	push   %ebp
801063ff:	89 e5                	mov    %esp,%ebp
80106401:	83 ec 18             	sub    $0x18,%esp
  int *status;
  if(argptr(0, (void *)&status, sizeof(*status)) < 0)
80106404:	83 ec 04             	sub    $0x4,%esp
80106407:	6a 04                	push   $0x4
80106409:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010640c:	50                   	push   %eax
8010640d:	6a 00                	push   $0x0
8010640f:	e8 20 ef ff ff       	call   80105334 <argptr>
80106414:	83 c4 10             	add    $0x10,%esp
80106417:	85 c0                	test   %eax,%eax
80106419:	79 07                	jns    80106422 <sys_wait2+0x28>
    return -1;
8010641b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106420:	eb 0f                	jmp    80106431 <sys_wait2+0x37>
  return wait2(status);
80106422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106425:	83 ec 0c             	sub    $0xc,%esp
80106428:	50                   	push   %eax
80106429:	e8 a6 df ff ff       	call   801043d4 <wait2>
8010642e:	83 c4 10             	add    $0x10,%esp
}
80106431:	c9                   	leave  
80106432:	c3                   	ret    

80106433 <sys_uthread_init>:

int
sys_uthread_init(void)
{
80106433:	f3 0f 1e fb          	endbr32 
80106437:	55                   	push   %ebp
80106438:	89 e5                	mov    %esp,%ebp
8010643a:	83 ec 18             	sub    $0x18,%esp
    struct proc* p;
    int func;

    if (argint(0, &func) < 0)
8010643d:	83 ec 08             	sub    $0x8,%esp
80106440:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106443:	50                   	push   %eax
80106444:	6a 00                	push   $0x0
80106446:	e8 b8 ee ff ff       	call   80105303 <argint>
8010644b:	83 c4 10             	add    $0x10,%esp
8010644e:	85 c0                	test   %eax,%eax
80106450:	79 07                	jns    80106459 <sys_uthread_init+0x26>
        return -1;
80106452:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106457:	eb 1b                	jmp    80106474 <sys_uthread_init+0x41>

    p = myproc();
80106459:	e8 4b d7 ff ff       	call   80103ba9 <myproc>
8010645e:	89 45 f4             	mov    %eax,-0xc(%ebp)

    p->scheduler = (uint)func;
80106461:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106464:	89 c2                	mov    %eax,%edx
80106466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106469:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

    return 0;
8010646f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106474:	c9                   	leave  
80106475:	c3                   	ret    

80106476 <sys_printpt>:

int sys_printpt(void) {
80106476:	f3 0f 1e fb          	endbr32 
8010647a:	55                   	push   %ebp
8010647b:	89 e5                	mov    %esp,%ebp
8010647d:	83 ec 18             	sub    $0x18,%esp
    int pid;
    if(argint(0, &pid) < 0)
80106480:	83 ec 08             	sub    $0x8,%esp
80106483:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106486:	50                   	push   %eax
80106487:	6a 00                	push   $0x0
80106489:	e8 75 ee ff ff       	call   80105303 <argint>
8010648e:	83 c4 10             	add    $0x10,%esp
80106491:	85 c0                	test   %eax,%eax
80106493:	79 07                	jns    8010649c <sys_printpt+0x26>
        return -1;
80106495:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649a:	eb 14                	jmp    801064b0 <sys_printpt+0x3a>
    printpt(pid);
8010649c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649f:	83 ec 0c             	sub    $0xc,%esp
801064a2:	50                   	push   %eax
801064a3:	e8 51 e5 ff ff       	call   801049f9 <printpt>
801064a8:	83 c4 10             	add    $0x10,%esp
    return 0;
801064ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064b0:	c9                   	leave  
801064b1:	c3                   	ret    

801064b2 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801064b2:	1e                   	push   %ds
  pushl %es
801064b3:	06                   	push   %es
  pushl %fs
801064b4:	0f a0                	push   %fs
  pushl %gs
801064b6:	0f a8                	push   %gs
  pushal
801064b8:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801064b9:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801064bd:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801064bf:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801064c1:	54                   	push   %esp
  call trap
801064c2:	e8 df 01 00 00       	call   801066a6 <trap>
  addl $4, %esp
801064c7:	83 c4 04             	add    $0x4,%esp

801064ca <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801064ca:	61                   	popa   
  popl %gs
801064cb:	0f a9                	pop    %gs
  popl %fs
801064cd:	0f a1                	pop    %fs
  popl %es
801064cf:	07                   	pop    %es
  popl %ds
801064d0:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801064d1:	83 c4 08             	add    $0x8,%esp
  iret
801064d4:	cf                   	iret   

801064d5 <lidt>:
{
801064d5:	55                   	push   %ebp
801064d6:	89 e5                	mov    %esp,%ebp
801064d8:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801064db:	8b 45 0c             	mov    0xc(%ebp),%eax
801064de:	83 e8 01             	sub    $0x1,%eax
801064e1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801064e5:	8b 45 08             	mov    0x8(%ebp),%eax
801064e8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801064ec:	8b 45 08             	mov    0x8(%ebp),%eax
801064ef:	c1 e8 10             	shr    $0x10,%eax
801064f2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801064f6:	8d 45 fa             	lea    -0x6(%ebp),%eax
801064f9:	0f 01 18             	lidtl  (%eax)
}
801064fc:	90                   	nop
801064fd:	c9                   	leave  
801064fe:	c3                   	ret    

801064ff <rcr2>:

static inline uint
rcr2(void)
{
801064ff:	55                   	push   %ebp
80106500:	89 e5                	mov    %esp,%ebp
80106502:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106505:	0f 20 d0             	mov    %cr2,%eax
80106508:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010650b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010650e:	c9                   	leave  
8010650f:	c3                   	ret    

80106510 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106510:	f3 0f 1e fb          	endbr32 
80106514:	55                   	push   %ebp
80106515:	89 e5                	mov    %esp,%ebp
80106517:	83 ec 18             	sub    $0x18,%esp
    int i;

    for (i = 0; i < 256; i++)
8010651a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106521:	e9 c3 00 00 00       	jmp    801065e9 <tvinit+0xd9>
        SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
80106526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106529:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106530:	89 c2                	mov    %eax,%edx
80106532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106535:	66 89 14 c5 80 76 19 	mov    %dx,-0x7fe68980(,%eax,8)
8010653c:	80 
8010653d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106540:	66 c7 04 c5 82 76 19 	movw   $0x8,-0x7fe6897e(,%eax,8)
80106547:	80 08 00 
8010654a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654d:	0f b6 14 c5 84 76 19 	movzbl -0x7fe6897c(,%eax,8),%edx
80106554:	80 
80106555:	83 e2 e0             	and    $0xffffffe0,%edx
80106558:	88 14 c5 84 76 19 80 	mov    %dl,-0x7fe6897c(,%eax,8)
8010655f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106562:	0f b6 14 c5 84 76 19 	movzbl -0x7fe6897c(,%eax,8),%edx
80106569:	80 
8010656a:	83 e2 1f             	and    $0x1f,%edx
8010656d:	88 14 c5 84 76 19 80 	mov    %dl,-0x7fe6897c(,%eax,8)
80106574:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106577:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
8010657e:	80 
8010657f:	83 e2 f0             	and    $0xfffffff0,%edx
80106582:	83 ca 0e             	or     $0xe,%edx
80106585:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
8010658c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658f:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
80106596:	80 
80106597:	83 e2 ef             	and    $0xffffffef,%edx
8010659a:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
801065a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a4:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
801065ab:	80 
801065ac:	83 e2 9f             	and    $0xffffff9f,%edx
801065af:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
801065b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b9:	0f b6 14 c5 85 76 19 	movzbl -0x7fe6897b(,%eax,8),%edx
801065c0:	80 
801065c1:	83 ca 80             	or     $0xffffff80,%edx
801065c4:	88 14 c5 85 76 19 80 	mov    %dl,-0x7fe6897b(,%eax,8)
801065cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ce:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
801065d5:	c1 e8 10             	shr    $0x10,%eax
801065d8:	89 c2                	mov    %eax,%edx
801065da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065dd:	66 89 14 c5 86 76 19 	mov    %dx,-0x7fe6897a(,%eax,8)
801065e4:	80 
    for (i = 0; i < 256; i++)
801065e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065e9:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801065f0:	0f 8e 30 ff ff ff    	jle    80106526 <tvinit+0x16>
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
801065f6:	a1 88 f1 10 80       	mov    0x8010f188,%eax
801065fb:	66 a3 80 78 19 80    	mov    %ax,0x80197880
80106601:	66 c7 05 82 78 19 80 	movw   $0x8,0x80197882
80106608:	08 00 
8010660a:	0f b6 05 84 78 19 80 	movzbl 0x80197884,%eax
80106611:	83 e0 e0             	and    $0xffffffe0,%eax
80106614:	a2 84 78 19 80       	mov    %al,0x80197884
80106619:	0f b6 05 84 78 19 80 	movzbl 0x80197884,%eax
80106620:	83 e0 1f             	and    $0x1f,%eax
80106623:	a2 84 78 19 80       	mov    %al,0x80197884
80106628:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
8010662f:	83 c8 0f             	or     $0xf,%eax
80106632:	a2 85 78 19 80       	mov    %al,0x80197885
80106637:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
8010663e:	83 e0 ef             	and    $0xffffffef,%eax
80106641:	a2 85 78 19 80       	mov    %al,0x80197885
80106646:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
8010664d:	83 c8 60             	or     $0x60,%eax
80106650:	a2 85 78 19 80       	mov    %al,0x80197885
80106655:	0f b6 05 85 78 19 80 	movzbl 0x80197885,%eax
8010665c:	83 c8 80             	or     $0xffffff80,%eax
8010665f:	a2 85 78 19 80       	mov    %al,0x80197885
80106664:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106669:	c1 e8 10             	shr    $0x10,%eax
8010666c:	66 a3 86 78 19 80    	mov    %ax,0x80197886

    initlock(&tickslock, "time");
80106672:	83 ec 08             	sub    $0x8,%esp
80106675:	68 80 ad 10 80       	push   $0x8010ad80
8010667a:	68 40 76 19 80       	push   $0x80197640
8010667f:	e8 76 e6 ff ff       	call   80104cfa <initlock>
80106684:	83 c4 10             	add    $0x10,%esp
}
80106687:	90                   	nop
80106688:	c9                   	leave  
80106689:	c3                   	ret    

8010668a <idtinit>:

void
idtinit(void)
{
8010668a:	f3 0f 1e fb          	endbr32 
8010668e:	55                   	push   %ebp
8010668f:	89 e5                	mov    %esp,%ebp
    lidt(idt, sizeof(idt));
80106691:	68 00 08 00 00       	push   $0x800
80106696:	68 80 76 19 80       	push   $0x80197680
8010669b:	e8 35 fe ff ff       	call   801064d5 <lidt>
801066a0:	83 c4 08             	add    $0x8,%esp
}
801066a3:	90                   	nop
801066a4:	c9                   	leave  
801066a5:	c3                   	ret    

801066a6 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe* tf)
{
801066a6:	f3 0f 1e fb          	endbr32 
801066aa:	55                   	push   %ebp
801066ab:	89 e5                	mov    %esp,%ebp
801066ad:	57                   	push   %edi
801066ae:	56                   	push   %esi
801066af:	53                   	push   %ebx
801066b0:	83 ec 2c             	sub    $0x2c,%esp
    if (tf->trapno == T_SYSCALL) {
801066b3:	8b 45 08             	mov    0x8(%ebp),%eax
801066b6:	8b 40 30             	mov    0x30(%eax),%eax
801066b9:	83 f8 40             	cmp    $0x40,%eax
801066bc:	75 3b                	jne    801066f9 <trap+0x53>
        if (myproc()->killed)
801066be:	e8 e6 d4 ff ff       	call   80103ba9 <myproc>
801066c3:	8b 40 24             	mov    0x24(%eax),%eax
801066c6:	85 c0                	test   %eax,%eax
801066c8:	74 05                	je     801066cf <trap+0x29>
            exit();
801066ca:	e8 7a d9 ff ff       	call   80104049 <exit>
        myproc()->tf = tf;
801066cf:	e8 d5 d4 ff ff       	call   80103ba9 <myproc>
801066d4:	8b 55 08             	mov    0x8(%ebp),%edx
801066d7:	89 50 18             	mov    %edx,0x18(%eax)
        syscall();
801066da:	e8 fc ec ff ff       	call   801053db <syscall>
        if (myproc()->killed)
801066df:	e8 c5 d4 ff ff       	call   80103ba9 <myproc>
801066e4:	8b 40 24             	mov    0x24(%eax),%eax
801066e7:	85 c0                	test   %eax,%eax
801066e9:	0f 84 5d 02 00 00    	je     8010694c <trap+0x2a6>
            exit();
801066ef:	e8 55 d9 ff ff       	call   80104049 <exit>
        return;
801066f4:	e9 53 02 00 00       	jmp    8010694c <trap+0x2a6>
    }

    switch (tf->trapno) {
801066f9:	8b 45 08             	mov    0x8(%ebp),%eax
801066fc:	8b 40 30             	mov    0x30(%eax),%eax
801066ff:	83 e8 20             	sub    $0x20,%eax
80106702:	83 f8 1f             	cmp    $0x1f,%eax
80106705:	0f 87 09 01 00 00    	ja     80106814 <trap+0x16e>
8010670b:	8b 04 85 28 ae 10 80 	mov    -0x7fef51d8(,%eax,4),%eax
80106712:	3e ff e0             	notrack jmp *%eax
    case T_IRQ0 + IRQ_TIMER:
        if (cpuid() == 0) {
80106715:	e8 f4 d3 ff ff       	call   80103b0e <cpuid>
8010671a:	85 c0                	test   %eax,%eax
8010671c:	75 3d                	jne    8010675b <trap+0xb5>
            acquire(&tickslock);
8010671e:	83 ec 0c             	sub    $0xc,%esp
80106721:	68 40 76 19 80       	push   $0x80197640
80106726:	e8 f5 e5 ff ff       	call   80104d20 <acquire>
8010672b:	83 c4 10             	add    $0x10,%esp
            ticks++;
8010672e:	a1 80 7e 19 80       	mov    0x80197e80,%eax
80106733:	83 c0 01             	add    $0x1,%eax
80106736:	a3 80 7e 19 80       	mov    %eax,0x80197e80
            wakeup(&ticks);
8010673b:	83 ec 0c             	sub    $0xc,%esp
8010673e:	68 80 7e 19 80       	push   $0x80197e80
80106743:	e8 ea e0 ff ff       	call   80104832 <wakeup>
80106748:	83 c4 10             	add    $0x10,%esp
            release(&tickslock);
8010674b:	83 ec 0c             	sub    $0xc,%esp
8010674e:	68 40 76 19 80       	push   $0x80197640
80106753:	e8 3a e6 ff ff       	call   80104d92 <release>
80106758:	83 c4 10             	add    $0x10,%esp
        }
        lapiceoi();  // Acknowledge the interrupt
8010675b:	e8 c5 c4 ff ff       	call   80102c25 <lapiceoi>

        // After acknowledging the timer interrupt, check if we need to switch threads.
        struct proc* curproc = myproc();
80106760:	e8 44 d4 ff ff       	call   80103ba9 <myproc>
80106765:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (curproc && curproc->scheduler && (tf->cs & 3) == DPL_USER) {
80106768:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010676c:	0f 84 59 01 00 00    	je     801068cb <trap+0x225>
80106772:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106775:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010677b:	85 c0                	test   %eax,%eax
8010677d:	0f 84 48 01 00 00    	je     801068cb <trap+0x225>
80106783:	8b 45 08             	mov    0x8(%ebp),%eax
80106786:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010678a:	0f b7 c0             	movzwl %ax,%eax
8010678d:	83 e0 03             	and    $0x3,%eax
80106790:	83 f8 03             	cmp    $0x3,%eax
80106793:	0f 85 32 01 00 00    	jne    801068cb <trap+0x225>
            // Only switch threads if the current process has a user-level scheduler
            // and the trap occurred in user mode.
            ((void(*)(void))curproc->scheduler)();  // Call the user-level scheduler
80106799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010679c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801067a2:	ff d0                	call   *%eax
	    return;
801067a4:	e9 a4 01 00 00       	jmp    8010694d <trap+0x2a7>
        }
        break;
    case T_IRQ0 + IRQ_IDE:
        ideintr();
801067a9:	e8 1e 40 00 00       	call   8010a7cc <ideintr>
        lapiceoi();
801067ae:	e8 72 c4 ff ff       	call   80102c25 <lapiceoi>
        break;
801067b3:	e9 14 01 00 00       	jmp    801068cc <trap+0x226>
    case T_IRQ0 + IRQ_IDE + 1:
        // Bochs generates spurious IDE1 interrupts.
        break;
    case T_IRQ0 + IRQ_KBD:
        kbdintr();
801067b8:	e8 9e c2 ff ff       	call   80102a5b <kbdintr>
        lapiceoi();
801067bd:	e8 63 c4 ff ff       	call   80102c25 <lapiceoi>
        break;
801067c2:	e9 05 01 00 00       	jmp    801068cc <trap+0x226>
    case T_IRQ0 + IRQ_COM1:
        uartintr();
801067c7:	e8 62 03 00 00       	call   80106b2e <uartintr>
        lapiceoi();
801067cc:	e8 54 c4 ff ff       	call   80102c25 <lapiceoi>
        break;
801067d1:	e9 f6 00 00 00       	jmp    801068cc <trap+0x226>
    case T_IRQ0 + 0xB:
        i8254_intr();
801067d6:	e8 30 2c 00 00       	call   8010940b <i8254_intr>
        lapiceoi();
801067db:	e8 45 c4 ff ff       	call   80102c25 <lapiceoi>
        break;
801067e0:	e9 e7 00 00 00       	jmp    801068cc <trap+0x226>
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067e5:	8b 45 08             	mov    0x8(%ebp),%eax
801067e8:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801067eb:	8b 45 08             	mov    0x8(%ebp),%eax
801067ee:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067f2:	0f b7 d8             	movzwl %ax,%ebx
801067f5:	e8 14 d3 ff ff       	call   80103b0e <cpuid>
801067fa:	56                   	push   %esi
801067fb:	53                   	push   %ebx
801067fc:	50                   	push   %eax
801067fd:	68 88 ad 10 80       	push   $0x8010ad88
80106802:	e8 05 9c ff ff       	call   8010040c <cprintf>
80106807:	83 c4 10             	add    $0x10,%esp
        lapiceoi();
8010680a:	e8 16 c4 ff ff       	call   80102c25 <lapiceoi>
        break;
8010680f:	e9 b8 00 00 00       	jmp    801068cc <trap+0x226>

        //PAGEBREAK: 13
    default:
        if (myproc() == 0 || (tf->cs & 3) == 0) {
80106814:	e8 90 d3 ff ff       	call   80103ba9 <myproc>
80106819:	85 c0                	test   %eax,%eax
8010681b:	74 11                	je     8010682e <trap+0x188>
8010681d:	8b 45 08             	mov    0x8(%ebp),%eax
80106820:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106824:	0f b7 c0             	movzwl %ax,%eax
80106827:	83 e0 03             	and    $0x3,%eax
8010682a:	85 c0                	test   %eax,%eax
8010682c:	75 39                	jne    80106867 <trap+0x1c1>
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010682e:	e8 cc fc ff ff       	call   801064ff <rcr2>
80106833:	89 c3                	mov    %eax,%ebx
80106835:	8b 45 08             	mov    0x8(%ebp),%eax
80106838:	8b 70 38             	mov    0x38(%eax),%esi
8010683b:	e8 ce d2 ff ff       	call   80103b0e <cpuid>
80106840:	8b 55 08             	mov    0x8(%ebp),%edx
80106843:	8b 52 30             	mov    0x30(%edx),%edx
80106846:	83 ec 0c             	sub    $0xc,%esp
80106849:	53                   	push   %ebx
8010684a:	56                   	push   %esi
8010684b:	50                   	push   %eax
8010684c:	52                   	push   %edx
8010684d:	68 ac ad 10 80       	push   $0x8010adac
80106852:	e8 b5 9b ff ff       	call   8010040c <cprintf>
80106857:	83 c4 20             	add    $0x20,%esp
                tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
8010685a:	83 ec 0c             	sub    $0xc,%esp
8010685d:	68 de ad 10 80       	push   $0x8010adde
80106862:	e8 5e 9d ff ff       	call   801005c5 <panic>
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106867:	e8 93 fc ff ff       	call   801064ff <rcr2>
8010686c:	89 c6                	mov    %eax,%esi
8010686e:	8b 45 08             	mov    0x8(%ebp),%eax
80106871:	8b 40 38             	mov    0x38(%eax),%eax
80106874:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106877:	e8 92 d2 ff ff       	call   80103b0e <cpuid>
8010687c:	89 c3                	mov    %eax,%ebx
8010687e:	8b 45 08             	mov    0x8(%ebp),%eax
80106881:	8b 48 34             	mov    0x34(%eax),%ecx
80106884:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106887:	8b 45 08             	mov    0x8(%ebp),%eax
8010688a:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010688d:	e8 17 d3 ff ff       	call   80103ba9 <myproc>
80106892:	8d 50 6c             	lea    0x6c(%eax),%edx
80106895:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106898:	e8 0c d3 ff ff       	call   80103ba9 <myproc>
        cprintf("pid %d %s: trap %d err %d on cpu %d "
8010689d:	8b 40 10             	mov    0x10(%eax),%eax
801068a0:	56                   	push   %esi
801068a1:	ff 75 d4             	pushl  -0x2c(%ebp)
801068a4:	53                   	push   %ebx
801068a5:	ff 75 d0             	pushl  -0x30(%ebp)
801068a8:	57                   	push   %edi
801068a9:	ff 75 cc             	pushl  -0x34(%ebp)
801068ac:	50                   	push   %eax
801068ad:	68 e4 ad 10 80       	push   $0x8010ade4
801068b2:	e8 55 9b ff ff       	call   8010040c <cprintf>
801068b7:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
801068ba:	e8 ea d2 ff ff       	call   80103ba9 <myproc>
801068bf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801068c6:	eb 04                	jmp    801068cc <trap+0x226>
        break;
801068c8:	90                   	nop
801068c9:	eb 01                	jmp    801068cc <trap+0x226>
        break;
801068cb:	90                   	nop
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
801068cc:	e8 d8 d2 ff ff       	call   80103ba9 <myproc>
801068d1:	85 c0                	test   %eax,%eax
801068d3:	74 23                	je     801068f8 <trap+0x252>
801068d5:	e8 cf d2 ff ff       	call   80103ba9 <myproc>
801068da:	8b 40 24             	mov    0x24(%eax),%eax
801068dd:	85 c0                	test   %eax,%eax
801068df:	74 17                	je     801068f8 <trap+0x252>
801068e1:	8b 45 08             	mov    0x8(%ebp),%eax
801068e4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068e8:	0f b7 c0             	movzwl %ax,%eax
801068eb:	83 e0 03             	and    $0x3,%eax
801068ee:	83 f8 03             	cmp    $0x3,%eax
801068f1:	75 05                	jne    801068f8 <trap+0x252>
        exit();
801068f3:	e8 51 d7 ff ff       	call   80104049 <exit>

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
801068f8:	e8 ac d2 ff ff       	call   80103ba9 <myproc>
801068fd:	85 c0                	test   %eax,%eax
801068ff:	74 1d                	je     8010691e <trap+0x278>
80106901:	e8 a3 d2 ff ff       	call   80103ba9 <myproc>
80106906:	8b 40 0c             	mov    0xc(%eax),%eax
80106909:	83 f8 04             	cmp    $0x4,%eax
8010690c:	75 10                	jne    8010691e <trap+0x278>
        tf->trapno == T_IRQ0 + IRQ_TIMER)
8010690e:	8b 45 08             	mov    0x8(%ebp),%eax
80106911:	8b 40 30             	mov    0x30(%eax),%eax
    if (myproc() && myproc()->state == RUNNING &&
80106914:	83 f8 20             	cmp    $0x20,%eax
80106917:	75 05                	jne    8010691e <trap+0x278>
        yield();
80106919:	e8 9a dd ff ff       	call   801046b8 <yield>

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
8010691e:	e8 86 d2 ff ff       	call   80103ba9 <myproc>
80106923:	85 c0                	test   %eax,%eax
80106925:	74 26                	je     8010694d <trap+0x2a7>
80106927:	e8 7d d2 ff ff       	call   80103ba9 <myproc>
8010692c:	8b 40 24             	mov    0x24(%eax),%eax
8010692f:	85 c0                	test   %eax,%eax
80106931:	74 1a                	je     8010694d <trap+0x2a7>
80106933:	8b 45 08             	mov    0x8(%ebp),%eax
80106936:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010693a:	0f b7 c0             	movzwl %ax,%eax
8010693d:	83 e0 03             	and    $0x3,%eax
80106940:	83 f8 03             	cmp    $0x3,%eax
80106943:	75 08                	jne    8010694d <trap+0x2a7>
        exit();
80106945:	e8 ff d6 ff ff       	call   80104049 <exit>
8010694a:	eb 01                	jmp    8010694d <trap+0x2a7>
        return;
8010694c:	90                   	nop
}
8010694d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106950:	5b                   	pop    %ebx
80106951:	5e                   	pop    %esi
80106952:	5f                   	pop    %edi
80106953:	5d                   	pop    %ebp
80106954:	c3                   	ret    

80106955 <inb>:
{
80106955:	55                   	push   %ebp
80106956:	89 e5                	mov    %esp,%ebp
80106958:	83 ec 14             	sub    $0x14,%esp
8010695b:	8b 45 08             	mov    0x8(%ebp),%eax
8010695e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106962:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106966:	89 c2                	mov    %eax,%edx
80106968:	ec                   	in     (%dx),%al
80106969:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010696c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106970:	c9                   	leave  
80106971:	c3                   	ret    

80106972 <outb>:
{
80106972:	55                   	push   %ebp
80106973:	89 e5                	mov    %esp,%ebp
80106975:	83 ec 08             	sub    $0x8,%esp
80106978:	8b 45 08             	mov    0x8(%ebp),%eax
8010697b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010697e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106982:	89 d0                	mov    %edx,%eax
80106984:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106987:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010698b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010698f:	ee                   	out    %al,(%dx)
}
80106990:	90                   	nop
80106991:	c9                   	leave  
80106992:	c3                   	ret    

80106993 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106993:	f3 0f 1e fb          	endbr32 
80106997:	55                   	push   %ebp
80106998:	89 e5                	mov    %esp,%ebp
8010699a:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010699d:	6a 00                	push   $0x0
8010699f:	68 fa 03 00 00       	push   $0x3fa
801069a4:	e8 c9 ff ff ff       	call   80106972 <outb>
801069a9:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801069ac:	68 80 00 00 00       	push   $0x80
801069b1:	68 fb 03 00 00       	push   $0x3fb
801069b6:	e8 b7 ff ff ff       	call   80106972 <outb>
801069bb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801069be:	6a 0c                	push   $0xc
801069c0:	68 f8 03 00 00       	push   $0x3f8
801069c5:	e8 a8 ff ff ff       	call   80106972 <outb>
801069ca:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801069cd:	6a 00                	push   $0x0
801069cf:	68 f9 03 00 00       	push   $0x3f9
801069d4:	e8 99 ff ff ff       	call   80106972 <outb>
801069d9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801069dc:	6a 03                	push   $0x3
801069de:	68 fb 03 00 00       	push   $0x3fb
801069e3:	e8 8a ff ff ff       	call   80106972 <outb>
801069e8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801069eb:	6a 00                	push   $0x0
801069ed:	68 fc 03 00 00       	push   $0x3fc
801069f2:	e8 7b ff ff ff       	call   80106972 <outb>
801069f7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801069fa:	6a 01                	push   $0x1
801069fc:	68 f9 03 00 00       	push   $0x3f9
80106a01:	e8 6c ff ff ff       	call   80106972 <outb>
80106a06:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106a09:	68 fd 03 00 00       	push   $0x3fd
80106a0e:	e8 42 ff ff ff       	call   80106955 <inb>
80106a13:	83 c4 04             	add    $0x4,%esp
80106a16:	3c ff                	cmp    $0xff,%al
80106a18:	74 61                	je     80106a7b <uartinit+0xe8>
    return;
  uart = 1;
80106a1a:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
80106a21:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106a24:	68 fa 03 00 00       	push   $0x3fa
80106a29:	e8 27 ff ff ff       	call   80106955 <inb>
80106a2e:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106a31:	68 f8 03 00 00       	push   $0x3f8
80106a36:	e8 1a ff ff ff       	call   80106955 <inb>
80106a3b:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106a3e:	83 ec 08             	sub    $0x8,%esp
80106a41:	6a 00                	push   $0x0
80106a43:	6a 04                	push   $0x4
80106a45:	e8 c2 bc ff ff       	call   8010270c <ioapicenable>
80106a4a:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a4d:	c7 45 f4 a8 ae 10 80 	movl   $0x8010aea8,-0xc(%ebp)
80106a54:	eb 19                	jmp    80106a6f <uartinit+0xdc>
    uartputc(*p);
80106a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a59:	0f b6 00             	movzbl (%eax),%eax
80106a5c:	0f be c0             	movsbl %al,%eax
80106a5f:	83 ec 0c             	sub    $0xc,%esp
80106a62:	50                   	push   %eax
80106a63:	e8 16 00 00 00       	call   80106a7e <uartputc>
80106a68:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106a6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a72:	0f b6 00             	movzbl (%eax),%eax
80106a75:	84 c0                	test   %al,%al
80106a77:	75 dd                	jne    80106a56 <uartinit+0xc3>
80106a79:	eb 01                	jmp    80106a7c <uartinit+0xe9>
    return;
80106a7b:	90                   	nop
}
80106a7c:	c9                   	leave  
80106a7d:	c3                   	ret    

80106a7e <uartputc>:

void
uartputc(int c)
{
80106a7e:	f3 0f 1e fb          	endbr32 
80106a82:	55                   	push   %ebp
80106a83:	89 e5                	mov    %esp,%ebp
80106a85:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106a88:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106a8d:	85 c0                	test   %eax,%eax
80106a8f:	74 53                	je     80106ae4 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a98:	eb 11                	jmp    80106aab <uartputc+0x2d>
    microdelay(10);
80106a9a:	83 ec 0c             	sub    $0xc,%esp
80106a9d:	6a 0a                	push   $0xa
80106a9f:	e8 a0 c1 ff ff       	call   80102c44 <microdelay>
80106aa4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106aa7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106aab:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106aaf:	7f 1a                	jg     80106acb <uartputc+0x4d>
80106ab1:	83 ec 0c             	sub    $0xc,%esp
80106ab4:	68 fd 03 00 00       	push   $0x3fd
80106ab9:	e8 97 fe ff ff       	call   80106955 <inb>
80106abe:	83 c4 10             	add    $0x10,%esp
80106ac1:	0f b6 c0             	movzbl %al,%eax
80106ac4:	83 e0 20             	and    $0x20,%eax
80106ac7:	85 c0                	test   %eax,%eax
80106ac9:	74 cf                	je     80106a9a <uartputc+0x1c>
  outb(COM1+0, c);
80106acb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ace:	0f b6 c0             	movzbl %al,%eax
80106ad1:	83 ec 08             	sub    $0x8,%esp
80106ad4:	50                   	push   %eax
80106ad5:	68 f8 03 00 00       	push   $0x3f8
80106ada:	e8 93 fe ff ff       	call   80106972 <outb>
80106adf:	83 c4 10             	add    $0x10,%esp
80106ae2:	eb 01                	jmp    80106ae5 <uartputc+0x67>
    return;
80106ae4:	90                   	nop
}
80106ae5:	c9                   	leave  
80106ae6:	c3                   	ret    

80106ae7 <uartgetc>:

static int
uartgetc(void)
{
80106ae7:	f3 0f 1e fb          	endbr32 
80106aeb:	55                   	push   %ebp
80106aec:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106aee:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106af3:	85 c0                	test   %eax,%eax
80106af5:	75 07                	jne    80106afe <uartgetc+0x17>
    return -1;
80106af7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106afc:	eb 2e                	jmp    80106b2c <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106afe:	68 fd 03 00 00       	push   $0x3fd
80106b03:	e8 4d fe ff ff       	call   80106955 <inb>
80106b08:	83 c4 04             	add    $0x4,%esp
80106b0b:	0f b6 c0             	movzbl %al,%eax
80106b0e:	83 e0 01             	and    $0x1,%eax
80106b11:	85 c0                	test   %eax,%eax
80106b13:	75 07                	jne    80106b1c <uartgetc+0x35>
    return -1;
80106b15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b1a:	eb 10                	jmp    80106b2c <uartgetc+0x45>
  return inb(COM1+0);
80106b1c:	68 f8 03 00 00       	push   $0x3f8
80106b21:	e8 2f fe ff ff       	call   80106955 <inb>
80106b26:	83 c4 04             	add    $0x4,%esp
80106b29:	0f b6 c0             	movzbl %al,%eax
}
80106b2c:	c9                   	leave  
80106b2d:	c3                   	ret    

80106b2e <uartintr>:

void
uartintr(void)
{
80106b2e:	f3 0f 1e fb          	endbr32 
80106b32:	55                   	push   %ebp
80106b33:	89 e5                	mov    %esp,%ebp
80106b35:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106b38:	83 ec 0c             	sub    $0xc,%esp
80106b3b:	68 e7 6a 10 80       	push   $0x80106ae7
80106b40:	e8 bb 9c ff ff       	call   80100800 <consoleintr>
80106b45:	83 c4 10             	add    $0x10,%esp
}
80106b48:	90                   	nop
80106b49:	c9                   	leave  
80106b4a:	c3                   	ret    

80106b4b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106b4b:	6a 00                	push   $0x0
  pushl $0
80106b4d:	6a 00                	push   $0x0
  jmp alltraps
80106b4f:	e9 5e f9 ff ff       	jmp    801064b2 <alltraps>

80106b54 <vector1>:
.globl vector1
vector1:
  pushl $0
80106b54:	6a 00                	push   $0x0
  pushl $1
80106b56:	6a 01                	push   $0x1
  jmp alltraps
80106b58:	e9 55 f9 ff ff       	jmp    801064b2 <alltraps>

80106b5d <vector2>:
.globl vector2
vector2:
  pushl $0
80106b5d:	6a 00                	push   $0x0
  pushl $2
80106b5f:	6a 02                	push   $0x2
  jmp alltraps
80106b61:	e9 4c f9 ff ff       	jmp    801064b2 <alltraps>

80106b66 <vector3>:
.globl vector3
vector3:
  pushl $0
80106b66:	6a 00                	push   $0x0
  pushl $3
80106b68:	6a 03                	push   $0x3
  jmp alltraps
80106b6a:	e9 43 f9 ff ff       	jmp    801064b2 <alltraps>

80106b6f <vector4>:
.globl vector4
vector4:
  pushl $0
80106b6f:	6a 00                	push   $0x0
  pushl $4
80106b71:	6a 04                	push   $0x4
  jmp alltraps
80106b73:	e9 3a f9 ff ff       	jmp    801064b2 <alltraps>

80106b78 <vector5>:
.globl vector5
vector5:
  pushl $0
80106b78:	6a 00                	push   $0x0
  pushl $5
80106b7a:	6a 05                	push   $0x5
  jmp alltraps
80106b7c:	e9 31 f9 ff ff       	jmp    801064b2 <alltraps>

80106b81 <vector6>:
.globl vector6
vector6:
  pushl $0
80106b81:	6a 00                	push   $0x0
  pushl $6
80106b83:	6a 06                	push   $0x6
  jmp alltraps
80106b85:	e9 28 f9 ff ff       	jmp    801064b2 <alltraps>

80106b8a <vector7>:
.globl vector7
vector7:
  pushl $0
80106b8a:	6a 00                	push   $0x0
  pushl $7
80106b8c:	6a 07                	push   $0x7
  jmp alltraps
80106b8e:	e9 1f f9 ff ff       	jmp    801064b2 <alltraps>

80106b93 <vector8>:
.globl vector8
vector8:
  pushl $8
80106b93:	6a 08                	push   $0x8
  jmp alltraps
80106b95:	e9 18 f9 ff ff       	jmp    801064b2 <alltraps>

80106b9a <vector9>:
.globl vector9
vector9:
  pushl $0
80106b9a:	6a 00                	push   $0x0
  pushl $9
80106b9c:	6a 09                	push   $0x9
  jmp alltraps
80106b9e:	e9 0f f9 ff ff       	jmp    801064b2 <alltraps>

80106ba3 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ba3:	6a 0a                	push   $0xa
  jmp alltraps
80106ba5:	e9 08 f9 ff ff       	jmp    801064b2 <alltraps>

80106baa <vector11>:
.globl vector11
vector11:
  pushl $11
80106baa:	6a 0b                	push   $0xb
  jmp alltraps
80106bac:	e9 01 f9 ff ff       	jmp    801064b2 <alltraps>

80106bb1 <vector12>:
.globl vector12
vector12:
  pushl $12
80106bb1:	6a 0c                	push   $0xc
  jmp alltraps
80106bb3:	e9 fa f8 ff ff       	jmp    801064b2 <alltraps>

80106bb8 <vector13>:
.globl vector13
vector13:
  pushl $13
80106bb8:	6a 0d                	push   $0xd
  jmp alltraps
80106bba:	e9 f3 f8 ff ff       	jmp    801064b2 <alltraps>

80106bbf <vector14>:
.globl vector14
vector14:
  pushl $14
80106bbf:	6a 0e                	push   $0xe
  jmp alltraps
80106bc1:	e9 ec f8 ff ff       	jmp    801064b2 <alltraps>

80106bc6 <vector15>:
.globl vector15
vector15:
  pushl $0
80106bc6:	6a 00                	push   $0x0
  pushl $15
80106bc8:	6a 0f                	push   $0xf
  jmp alltraps
80106bca:	e9 e3 f8 ff ff       	jmp    801064b2 <alltraps>

80106bcf <vector16>:
.globl vector16
vector16:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $16
80106bd1:	6a 10                	push   $0x10
  jmp alltraps
80106bd3:	e9 da f8 ff ff       	jmp    801064b2 <alltraps>

80106bd8 <vector17>:
.globl vector17
vector17:
  pushl $17
80106bd8:	6a 11                	push   $0x11
  jmp alltraps
80106bda:	e9 d3 f8 ff ff       	jmp    801064b2 <alltraps>

80106bdf <vector18>:
.globl vector18
vector18:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $18
80106be1:	6a 12                	push   $0x12
  jmp alltraps
80106be3:	e9 ca f8 ff ff       	jmp    801064b2 <alltraps>

80106be8 <vector19>:
.globl vector19
vector19:
  pushl $0
80106be8:	6a 00                	push   $0x0
  pushl $19
80106bea:	6a 13                	push   $0x13
  jmp alltraps
80106bec:	e9 c1 f8 ff ff       	jmp    801064b2 <alltraps>

80106bf1 <vector20>:
.globl vector20
vector20:
  pushl $0
80106bf1:	6a 00                	push   $0x0
  pushl $20
80106bf3:	6a 14                	push   $0x14
  jmp alltraps
80106bf5:	e9 b8 f8 ff ff       	jmp    801064b2 <alltraps>

80106bfa <vector21>:
.globl vector21
vector21:
  pushl $0
80106bfa:	6a 00                	push   $0x0
  pushl $21
80106bfc:	6a 15                	push   $0x15
  jmp alltraps
80106bfe:	e9 af f8 ff ff       	jmp    801064b2 <alltraps>

80106c03 <vector22>:
.globl vector22
vector22:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $22
80106c05:	6a 16                	push   $0x16
  jmp alltraps
80106c07:	e9 a6 f8 ff ff       	jmp    801064b2 <alltraps>

80106c0c <vector23>:
.globl vector23
vector23:
  pushl $0
80106c0c:	6a 00                	push   $0x0
  pushl $23
80106c0e:	6a 17                	push   $0x17
  jmp alltraps
80106c10:	e9 9d f8 ff ff       	jmp    801064b2 <alltraps>

80106c15 <vector24>:
.globl vector24
vector24:
  pushl $0
80106c15:	6a 00                	push   $0x0
  pushl $24
80106c17:	6a 18                	push   $0x18
  jmp alltraps
80106c19:	e9 94 f8 ff ff       	jmp    801064b2 <alltraps>

80106c1e <vector25>:
.globl vector25
vector25:
  pushl $0
80106c1e:	6a 00                	push   $0x0
  pushl $25
80106c20:	6a 19                	push   $0x19
  jmp alltraps
80106c22:	e9 8b f8 ff ff       	jmp    801064b2 <alltraps>

80106c27 <vector26>:
.globl vector26
vector26:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $26
80106c29:	6a 1a                	push   $0x1a
  jmp alltraps
80106c2b:	e9 82 f8 ff ff       	jmp    801064b2 <alltraps>

80106c30 <vector27>:
.globl vector27
vector27:
  pushl $0
80106c30:	6a 00                	push   $0x0
  pushl $27
80106c32:	6a 1b                	push   $0x1b
  jmp alltraps
80106c34:	e9 79 f8 ff ff       	jmp    801064b2 <alltraps>

80106c39 <vector28>:
.globl vector28
vector28:
  pushl $0
80106c39:	6a 00                	push   $0x0
  pushl $28
80106c3b:	6a 1c                	push   $0x1c
  jmp alltraps
80106c3d:	e9 70 f8 ff ff       	jmp    801064b2 <alltraps>

80106c42 <vector29>:
.globl vector29
vector29:
  pushl $0
80106c42:	6a 00                	push   $0x0
  pushl $29
80106c44:	6a 1d                	push   $0x1d
  jmp alltraps
80106c46:	e9 67 f8 ff ff       	jmp    801064b2 <alltraps>

80106c4b <vector30>:
.globl vector30
vector30:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $30
80106c4d:	6a 1e                	push   $0x1e
  jmp alltraps
80106c4f:	e9 5e f8 ff ff       	jmp    801064b2 <alltraps>

80106c54 <vector31>:
.globl vector31
vector31:
  pushl $0
80106c54:	6a 00                	push   $0x0
  pushl $31
80106c56:	6a 1f                	push   $0x1f
  jmp alltraps
80106c58:	e9 55 f8 ff ff       	jmp    801064b2 <alltraps>

80106c5d <vector32>:
.globl vector32
vector32:
  pushl $0
80106c5d:	6a 00                	push   $0x0
  pushl $32
80106c5f:	6a 20                	push   $0x20
  jmp alltraps
80106c61:	e9 4c f8 ff ff       	jmp    801064b2 <alltraps>

80106c66 <vector33>:
.globl vector33
vector33:
  pushl $0
80106c66:	6a 00                	push   $0x0
  pushl $33
80106c68:	6a 21                	push   $0x21
  jmp alltraps
80106c6a:	e9 43 f8 ff ff       	jmp    801064b2 <alltraps>

80106c6f <vector34>:
.globl vector34
vector34:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $34
80106c71:	6a 22                	push   $0x22
  jmp alltraps
80106c73:	e9 3a f8 ff ff       	jmp    801064b2 <alltraps>

80106c78 <vector35>:
.globl vector35
vector35:
  pushl $0
80106c78:	6a 00                	push   $0x0
  pushl $35
80106c7a:	6a 23                	push   $0x23
  jmp alltraps
80106c7c:	e9 31 f8 ff ff       	jmp    801064b2 <alltraps>

80106c81 <vector36>:
.globl vector36
vector36:
  pushl $0
80106c81:	6a 00                	push   $0x0
  pushl $36
80106c83:	6a 24                	push   $0x24
  jmp alltraps
80106c85:	e9 28 f8 ff ff       	jmp    801064b2 <alltraps>

80106c8a <vector37>:
.globl vector37
vector37:
  pushl $0
80106c8a:	6a 00                	push   $0x0
  pushl $37
80106c8c:	6a 25                	push   $0x25
  jmp alltraps
80106c8e:	e9 1f f8 ff ff       	jmp    801064b2 <alltraps>

80106c93 <vector38>:
.globl vector38
vector38:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $38
80106c95:	6a 26                	push   $0x26
  jmp alltraps
80106c97:	e9 16 f8 ff ff       	jmp    801064b2 <alltraps>

80106c9c <vector39>:
.globl vector39
vector39:
  pushl $0
80106c9c:	6a 00                	push   $0x0
  pushl $39
80106c9e:	6a 27                	push   $0x27
  jmp alltraps
80106ca0:	e9 0d f8 ff ff       	jmp    801064b2 <alltraps>

80106ca5 <vector40>:
.globl vector40
vector40:
  pushl $0
80106ca5:	6a 00                	push   $0x0
  pushl $40
80106ca7:	6a 28                	push   $0x28
  jmp alltraps
80106ca9:	e9 04 f8 ff ff       	jmp    801064b2 <alltraps>

80106cae <vector41>:
.globl vector41
vector41:
  pushl $0
80106cae:	6a 00                	push   $0x0
  pushl $41
80106cb0:	6a 29                	push   $0x29
  jmp alltraps
80106cb2:	e9 fb f7 ff ff       	jmp    801064b2 <alltraps>

80106cb7 <vector42>:
.globl vector42
vector42:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $42
80106cb9:	6a 2a                	push   $0x2a
  jmp alltraps
80106cbb:	e9 f2 f7 ff ff       	jmp    801064b2 <alltraps>

80106cc0 <vector43>:
.globl vector43
vector43:
  pushl $0
80106cc0:	6a 00                	push   $0x0
  pushl $43
80106cc2:	6a 2b                	push   $0x2b
  jmp alltraps
80106cc4:	e9 e9 f7 ff ff       	jmp    801064b2 <alltraps>

80106cc9 <vector44>:
.globl vector44
vector44:
  pushl $0
80106cc9:	6a 00                	push   $0x0
  pushl $44
80106ccb:	6a 2c                	push   $0x2c
  jmp alltraps
80106ccd:	e9 e0 f7 ff ff       	jmp    801064b2 <alltraps>

80106cd2 <vector45>:
.globl vector45
vector45:
  pushl $0
80106cd2:	6a 00                	push   $0x0
  pushl $45
80106cd4:	6a 2d                	push   $0x2d
  jmp alltraps
80106cd6:	e9 d7 f7 ff ff       	jmp    801064b2 <alltraps>

80106cdb <vector46>:
.globl vector46
vector46:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $46
80106cdd:	6a 2e                	push   $0x2e
  jmp alltraps
80106cdf:	e9 ce f7 ff ff       	jmp    801064b2 <alltraps>

80106ce4 <vector47>:
.globl vector47
vector47:
  pushl $0
80106ce4:	6a 00                	push   $0x0
  pushl $47
80106ce6:	6a 2f                	push   $0x2f
  jmp alltraps
80106ce8:	e9 c5 f7 ff ff       	jmp    801064b2 <alltraps>

80106ced <vector48>:
.globl vector48
vector48:
  pushl $0
80106ced:	6a 00                	push   $0x0
  pushl $48
80106cef:	6a 30                	push   $0x30
  jmp alltraps
80106cf1:	e9 bc f7 ff ff       	jmp    801064b2 <alltraps>

80106cf6 <vector49>:
.globl vector49
vector49:
  pushl $0
80106cf6:	6a 00                	push   $0x0
  pushl $49
80106cf8:	6a 31                	push   $0x31
  jmp alltraps
80106cfa:	e9 b3 f7 ff ff       	jmp    801064b2 <alltraps>

80106cff <vector50>:
.globl vector50
vector50:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $50
80106d01:	6a 32                	push   $0x32
  jmp alltraps
80106d03:	e9 aa f7 ff ff       	jmp    801064b2 <alltraps>

80106d08 <vector51>:
.globl vector51
vector51:
  pushl $0
80106d08:	6a 00                	push   $0x0
  pushl $51
80106d0a:	6a 33                	push   $0x33
  jmp alltraps
80106d0c:	e9 a1 f7 ff ff       	jmp    801064b2 <alltraps>

80106d11 <vector52>:
.globl vector52
vector52:
  pushl $0
80106d11:	6a 00                	push   $0x0
  pushl $52
80106d13:	6a 34                	push   $0x34
  jmp alltraps
80106d15:	e9 98 f7 ff ff       	jmp    801064b2 <alltraps>

80106d1a <vector53>:
.globl vector53
vector53:
  pushl $0
80106d1a:	6a 00                	push   $0x0
  pushl $53
80106d1c:	6a 35                	push   $0x35
  jmp alltraps
80106d1e:	e9 8f f7 ff ff       	jmp    801064b2 <alltraps>

80106d23 <vector54>:
.globl vector54
vector54:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $54
80106d25:	6a 36                	push   $0x36
  jmp alltraps
80106d27:	e9 86 f7 ff ff       	jmp    801064b2 <alltraps>

80106d2c <vector55>:
.globl vector55
vector55:
  pushl $0
80106d2c:	6a 00                	push   $0x0
  pushl $55
80106d2e:	6a 37                	push   $0x37
  jmp alltraps
80106d30:	e9 7d f7 ff ff       	jmp    801064b2 <alltraps>

80106d35 <vector56>:
.globl vector56
vector56:
  pushl $0
80106d35:	6a 00                	push   $0x0
  pushl $56
80106d37:	6a 38                	push   $0x38
  jmp alltraps
80106d39:	e9 74 f7 ff ff       	jmp    801064b2 <alltraps>

80106d3e <vector57>:
.globl vector57
vector57:
  pushl $0
80106d3e:	6a 00                	push   $0x0
  pushl $57
80106d40:	6a 39                	push   $0x39
  jmp alltraps
80106d42:	e9 6b f7 ff ff       	jmp    801064b2 <alltraps>

80106d47 <vector58>:
.globl vector58
vector58:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $58
80106d49:	6a 3a                	push   $0x3a
  jmp alltraps
80106d4b:	e9 62 f7 ff ff       	jmp    801064b2 <alltraps>

80106d50 <vector59>:
.globl vector59
vector59:
  pushl $0
80106d50:	6a 00                	push   $0x0
  pushl $59
80106d52:	6a 3b                	push   $0x3b
  jmp alltraps
80106d54:	e9 59 f7 ff ff       	jmp    801064b2 <alltraps>

80106d59 <vector60>:
.globl vector60
vector60:
  pushl $0
80106d59:	6a 00                	push   $0x0
  pushl $60
80106d5b:	6a 3c                	push   $0x3c
  jmp alltraps
80106d5d:	e9 50 f7 ff ff       	jmp    801064b2 <alltraps>

80106d62 <vector61>:
.globl vector61
vector61:
  pushl $0
80106d62:	6a 00                	push   $0x0
  pushl $61
80106d64:	6a 3d                	push   $0x3d
  jmp alltraps
80106d66:	e9 47 f7 ff ff       	jmp    801064b2 <alltraps>

80106d6b <vector62>:
.globl vector62
vector62:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $62
80106d6d:	6a 3e                	push   $0x3e
  jmp alltraps
80106d6f:	e9 3e f7 ff ff       	jmp    801064b2 <alltraps>

80106d74 <vector63>:
.globl vector63
vector63:
  pushl $0
80106d74:	6a 00                	push   $0x0
  pushl $63
80106d76:	6a 3f                	push   $0x3f
  jmp alltraps
80106d78:	e9 35 f7 ff ff       	jmp    801064b2 <alltraps>

80106d7d <vector64>:
.globl vector64
vector64:
  pushl $0
80106d7d:	6a 00                	push   $0x0
  pushl $64
80106d7f:	6a 40                	push   $0x40
  jmp alltraps
80106d81:	e9 2c f7 ff ff       	jmp    801064b2 <alltraps>

80106d86 <vector65>:
.globl vector65
vector65:
  pushl $0
80106d86:	6a 00                	push   $0x0
  pushl $65
80106d88:	6a 41                	push   $0x41
  jmp alltraps
80106d8a:	e9 23 f7 ff ff       	jmp    801064b2 <alltraps>

80106d8f <vector66>:
.globl vector66
vector66:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $66
80106d91:	6a 42                	push   $0x42
  jmp alltraps
80106d93:	e9 1a f7 ff ff       	jmp    801064b2 <alltraps>

80106d98 <vector67>:
.globl vector67
vector67:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $67
80106d9a:	6a 43                	push   $0x43
  jmp alltraps
80106d9c:	e9 11 f7 ff ff       	jmp    801064b2 <alltraps>

80106da1 <vector68>:
.globl vector68
vector68:
  pushl $0
80106da1:	6a 00                	push   $0x0
  pushl $68
80106da3:	6a 44                	push   $0x44
  jmp alltraps
80106da5:	e9 08 f7 ff ff       	jmp    801064b2 <alltraps>

80106daa <vector69>:
.globl vector69
vector69:
  pushl $0
80106daa:	6a 00                	push   $0x0
  pushl $69
80106dac:	6a 45                	push   $0x45
  jmp alltraps
80106dae:	e9 ff f6 ff ff       	jmp    801064b2 <alltraps>

80106db3 <vector70>:
.globl vector70
vector70:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $70
80106db5:	6a 46                	push   $0x46
  jmp alltraps
80106db7:	e9 f6 f6 ff ff       	jmp    801064b2 <alltraps>

80106dbc <vector71>:
.globl vector71
vector71:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $71
80106dbe:	6a 47                	push   $0x47
  jmp alltraps
80106dc0:	e9 ed f6 ff ff       	jmp    801064b2 <alltraps>

80106dc5 <vector72>:
.globl vector72
vector72:
  pushl $0
80106dc5:	6a 00                	push   $0x0
  pushl $72
80106dc7:	6a 48                	push   $0x48
  jmp alltraps
80106dc9:	e9 e4 f6 ff ff       	jmp    801064b2 <alltraps>

80106dce <vector73>:
.globl vector73
vector73:
  pushl $0
80106dce:	6a 00                	push   $0x0
  pushl $73
80106dd0:	6a 49                	push   $0x49
  jmp alltraps
80106dd2:	e9 db f6 ff ff       	jmp    801064b2 <alltraps>

80106dd7 <vector74>:
.globl vector74
vector74:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $74
80106dd9:	6a 4a                	push   $0x4a
  jmp alltraps
80106ddb:	e9 d2 f6 ff ff       	jmp    801064b2 <alltraps>

80106de0 <vector75>:
.globl vector75
vector75:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $75
80106de2:	6a 4b                	push   $0x4b
  jmp alltraps
80106de4:	e9 c9 f6 ff ff       	jmp    801064b2 <alltraps>

80106de9 <vector76>:
.globl vector76
vector76:
  pushl $0
80106de9:	6a 00                	push   $0x0
  pushl $76
80106deb:	6a 4c                	push   $0x4c
  jmp alltraps
80106ded:	e9 c0 f6 ff ff       	jmp    801064b2 <alltraps>

80106df2 <vector77>:
.globl vector77
vector77:
  pushl $0
80106df2:	6a 00                	push   $0x0
  pushl $77
80106df4:	6a 4d                	push   $0x4d
  jmp alltraps
80106df6:	e9 b7 f6 ff ff       	jmp    801064b2 <alltraps>

80106dfb <vector78>:
.globl vector78
vector78:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $78
80106dfd:	6a 4e                	push   $0x4e
  jmp alltraps
80106dff:	e9 ae f6 ff ff       	jmp    801064b2 <alltraps>

80106e04 <vector79>:
.globl vector79
vector79:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $79
80106e06:	6a 4f                	push   $0x4f
  jmp alltraps
80106e08:	e9 a5 f6 ff ff       	jmp    801064b2 <alltraps>

80106e0d <vector80>:
.globl vector80
vector80:
  pushl $0
80106e0d:	6a 00                	push   $0x0
  pushl $80
80106e0f:	6a 50                	push   $0x50
  jmp alltraps
80106e11:	e9 9c f6 ff ff       	jmp    801064b2 <alltraps>

80106e16 <vector81>:
.globl vector81
vector81:
  pushl $0
80106e16:	6a 00                	push   $0x0
  pushl $81
80106e18:	6a 51                	push   $0x51
  jmp alltraps
80106e1a:	e9 93 f6 ff ff       	jmp    801064b2 <alltraps>

80106e1f <vector82>:
.globl vector82
vector82:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $82
80106e21:	6a 52                	push   $0x52
  jmp alltraps
80106e23:	e9 8a f6 ff ff       	jmp    801064b2 <alltraps>

80106e28 <vector83>:
.globl vector83
vector83:
  pushl $0
80106e28:	6a 00                	push   $0x0
  pushl $83
80106e2a:	6a 53                	push   $0x53
  jmp alltraps
80106e2c:	e9 81 f6 ff ff       	jmp    801064b2 <alltraps>

80106e31 <vector84>:
.globl vector84
vector84:
  pushl $0
80106e31:	6a 00                	push   $0x0
  pushl $84
80106e33:	6a 54                	push   $0x54
  jmp alltraps
80106e35:	e9 78 f6 ff ff       	jmp    801064b2 <alltraps>

80106e3a <vector85>:
.globl vector85
vector85:
  pushl $0
80106e3a:	6a 00                	push   $0x0
  pushl $85
80106e3c:	6a 55                	push   $0x55
  jmp alltraps
80106e3e:	e9 6f f6 ff ff       	jmp    801064b2 <alltraps>

80106e43 <vector86>:
.globl vector86
vector86:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $86
80106e45:	6a 56                	push   $0x56
  jmp alltraps
80106e47:	e9 66 f6 ff ff       	jmp    801064b2 <alltraps>

80106e4c <vector87>:
.globl vector87
vector87:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $87
80106e4e:	6a 57                	push   $0x57
  jmp alltraps
80106e50:	e9 5d f6 ff ff       	jmp    801064b2 <alltraps>

80106e55 <vector88>:
.globl vector88
vector88:
  pushl $0
80106e55:	6a 00                	push   $0x0
  pushl $88
80106e57:	6a 58                	push   $0x58
  jmp alltraps
80106e59:	e9 54 f6 ff ff       	jmp    801064b2 <alltraps>

80106e5e <vector89>:
.globl vector89
vector89:
  pushl $0
80106e5e:	6a 00                	push   $0x0
  pushl $89
80106e60:	6a 59                	push   $0x59
  jmp alltraps
80106e62:	e9 4b f6 ff ff       	jmp    801064b2 <alltraps>

80106e67 <vector90>:
.globl vector90
vector90:
  pushl $0
80106e67:	6a 00                	push   $0x0
  pushl $90
80106e69:	6a 5a                	push   $0x5a
  jmp alltraps
80106e6b:	e9 42 f6 ff ff       	jmp    801064b2 <alltraps>

80106e70 <vector91>:
.globl vector91
vector91:
  pushl $0
80106e70:	6a 00                	push   $0x0
  pushl $91
80106e72:	6a 5b                	push   $0x5b
  jmp alltraps
80106e74:	e9 39 f6 ff ff       	jmp    801064b2 <alltraps>

80106e79 <vector92>:
.globl vector92
vector92:
  pushl $0
80106e79:	6a 00                	push   $0x0
  pushl $92
80106e7b:	6a 5c                	push   $0x5c
  jmp alltraps
80106e7d:	e9 30 f6 ff ff       	jmp    801064b2 <alltraps>

80106e82 <vector93>:
.globl vector93
vector93:
  pushl $0
80106e82:	6a 00                	push   $0x0
  pushl $93
80106e84:	6a 5d                	push   $0x5d
  jmp alltraps
80106e86:	e9 27 f6 ff ff       	jmp    801064b2 <alltraps>

80106e8b <vector94>:
.globl vector94
vector94:
  pushl $0
80106e8b:	6a 00                	push   $0x0
  pushl $94
80106e8d:	6a 5e                	push   $0x5e
  jmp alltraps
80106e8f:	e9 1e f6 ff ff       	jmp    801064b2 <alltraps>

80106e94 <vector95>:
.globl vector95
vector95:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $95
80106e96:	6a 5f                	push   $0x5f
  jmp alltraps
80106e98:	e9 15 f6 ff ff       	jmp    801064b2 <alltraps>

80106e9d <vector96>:
.globl vector96
vector96:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $96
80106e9f:	6a 60                	push   $0x60
  jmp alltraps
80106ea1:	e9 0c f6 ff ff       	jmp    801064b2 <alltraps>

80106ea6 <vector97>:
.globl vector97
vector97:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $97
80106ea8:	6a 61                	push   $0x61
  jmp alltraps
80106eaa:	e9 03 f6 ff ff       	jmp    801064b2 <alltraps>

80106eaf <vector98>:
.globl vector98
vector98:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $98
80106eb1:	6a 62                	push   $0x62
  jmp alltraps
80106eb3:	e9 fa f5 ff ff       	jmp    801064b2 <alltraps>

80106eb8 <vector99>:
.globl vector99
vector99:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $99
80106eba:	6a 63                	push   $0x63
  jmp alltraps
80106ebc:	e9 f1 f5 ff ff       	jmp    801064b2 <alltraps>

80106ec1 <vector100>:
.globl vector100
vector100:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $100
80106ec3:	6a 64                	push   $0x64
  jmp alltraps
80106ec5:	e9 e8 f5 ff ff       	jmp    801064b2 <alltraps>

80106eca <vector101>:
.globl vector101
vector101:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $101
80106ecc:	6a 65                	push   $0x65
  jmp alltraps
80106ece:	e9 df f5 ff ff       	jmp    801064b2 <alltraps>

80106ed3 <vector102>:
.globl vector102
vector102:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $102
80106ed5:	6a 66                	push   $0x66
  jmp alltraps
80106ed7:	e9 d6 f5 ff ff       	jmp    801064b2 <alltraps>

80106edc <vector103>:
.globl vector103
vector103:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $103
80106ede:	6a 67                	push   $0x67
  jmp alltraps
80106ee0:	e9 cd f5 ff ff       	jmp    801064b2 <alltraps>

80106ee5 <vector104>:
.globl vector104
vector104:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $104
80106ee7:	6a 68                	push   $0x68
  jmp alltraps
80106ee9:	e9 c4 f5 ff ff       	jmp    801064b2 <alltraps>

80106eee <vector105>:
.globl vector105
vector105:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $105
80106ef0:	6a 69                	push   $0x69
  jmp alltraps
80106ef2:	e9 bb f5 ff ff       	jmp    801064b2 <alltraps>

80106ef7 <vector106>:
.globl vector106
vector106:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $106
80106ef9:	6a 6a                	push   $0x6a
  jmp alltraps
80106efb:	e9 b2 f5 ff ff       	jmp    801064b2 <alltraps>

80106f00 <vector107>:
.globl vector107
vector107:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $107
80106f02:	6a 6b                	push   $0x6b
  jmp alltraps
80106f04:	e9 a9 f5 ff ff       	jmp    801064b2 <alltraps>

80106f09 <vector108>:
.globl vector108
vector108:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $108
80106f0b:	6a 6c                	push   $0x6c
  jmp alltraps
80106f0d:	e9 a0 f5 ff ff       	jmp    801064b2 <alltraps>

80106f12 <vector109>:
.globl vector109
vector109:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $109
80106f14:	6a 6d                	push   $0x6d
  jmp alltraps
80106f16:	e9 97 f5 ff ff       	jmp    801064b2 <alltraps>

80106f1b <vector110>:
.globl vector110
vector110:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $110
80106f1d:	6a 6e                	push   $0x6e
  jmp alltraps
80106f1f:	e9 8e f5 ff ff       	jmp    801064b2 <alltraps>

80106f24 <vector111>:
.globl vector111
vector111:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $111
80106f26:	6a 6f                	push   $0x6f
  jmp alltraps
80106f28:	e9 85 f5 ff ff       	jmp    801064b2 <alltraps>

80106f2d <vector112>:
.globl vector112
vector112:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $112
80106f2f:	6a 70                	push   $0x70
  jmp alltraps
80106f31:	e9 7c f5 ff ff       	jmp    801064b2 <alltraps>

80106f36 <vector113>:
.globl vector113
vector113:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $113
80106f38:	6a 71                	push   $0x71
  jmp alltraps
80106f3a:	e9 73 f5 ff ff       	jmp    801064b2 <alltraps>

80106f3f <vector114>:
.globl vector114
vector114:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $114
80106f41:	6a 72                	push   $0x72
  jmp alltraps
80106f43:	e9 6a f5 ff ff       	jmp    801064b2 <alltraps>

80106f48 <vector115>:
.globl vector115
vector115:
  pushl $0
80106f48:	6a 00                	push   $0x0
  pushl $115
80106f4a:	6a 73                	push   $0x73
  jmp alltraps
80106f4c:	e9 61 f5 ff ff       	jmp    801064b2 <alltraps>

80106f51 <vector116>:
.globl vector116
vector116:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $116
80106f53:	6a 74                	push   $0x74
  jmp alltraps
80106f55:	e9 58 f5 ff ff       	jmp    801064b2 <alltraps>

80106f5a <vector117>:
.globl vector117
vector117:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $117
80106f5c:	6a 75                	push   $0x75
  jmp alltraps
80106f5e:	e9 4f f5 ff ff       	jmp    801064b2 <alltraps>

80106f63 <vector118>:
.globl vector118
vector118:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $118
80106f65:	6a 76                	push   $0x76
  jmp alltraps
80106f67:	e9 46 f5 ff ff       	jmp    801064b2 <alltraps>

80106f6c <vector119>:
.globl vector119
vector119:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $119
80106f6e:	6a 77                	push   $0x77
  jmp alltraps
80106f70:	e9 3d f5 ff ff       	jmp    801064b2 <alltraps>

80106f75 <vector120>:
.globl vector120
vector120:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $120
80106f77:	6a 78                	push   $0x78
  jmp alltraps
80106f79:	e9 34 f5 ff ff       	jmp    801064b2 <alltraps>

80106f7e <vector121>:
.globl vector121
vector121:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $121
80106f80:	6a 79                	push   $0x79
  jmp alltraps
80106f82:	e9 2b f5 ff ff       	jmp    801064b2 <alltraps>

80106f87 <vector122>:
.globl vector122
vector122:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $122
80106f89:	6a 7a                	push   $0x7a
  jmp alltraps
80106f8b:	e9 22 f5 ff ff       	jmp    801064b2 <alltraps>

80106f90 <vector123>:
.globl vector123
vector123:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $123
80106f92:	6a 7b                	push   $0x7b
  jmp alltraps
80106f94:	e9 19 f5 ff ff       	jmp    801064b2 <alltraps>

80106f99 <vector124>:
.globl vector124
vector124:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $124
80106f9b:	6a 7c                	push   $0x7c
  jmp alltraps
80106f9d:	e9 10 f5 ff ff       	jmp    801064b2 <alltraps>

80106fa2 <vector125>:
.globl vector125
vector125:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $125
80106fa4:	6a 7d                	push   $0x7d
  jmp alltraps
80106fa6:	e9 07 f5 ff ff       	jmp    801064b2 <alltraps>

80106fab <vector126>:
.globl vector126
vector126:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $126
80106fad:	6a 7e                	push   $0x7e
  jmp alltraps
80106faf:	e9 fe f4 ff ff       	jmp    801064b2 <alltraps>

80106fb4 <vector127>:
.globl vector127
vector127:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $127
80106fb6:	6a 7f                	push   $0x7f
  jmp alltraps
80106fb8:	e9 f5 f4 ff ff       	jmp    801064b2 <alltraps>

80106fbd <vector128>:
.globl vector128
vector128:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $128
80106fbf:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106fc4:	e9 e9 f4 ff ff       	jmp    801064b2 <alltraps>

80106fc9 <vector129>:
.globl vector129
vector129:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $129
80106fcb:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106fd0:	e9 dd f4 ff ff       	jmp    801064b2 <alltraps>

80106fd5 <vector130>:
.globl vector130
vector130:
  pushl $0
80106fd5:	6a 00                	push   $0x0
  pushl $130
80106fd7:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106fdc:	e9 d1 f4 ff ff       	jmp    801064b2 <alltraps>

80106fe1 <vector131>:
.globl vector131
vector131:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $131
80106fe3:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106fe8:	e9 c5 f4 ff ff       	jmp    801064b2 <alltraps>

80106fed <vector132>:
.globl vector132
vector132:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $132
80106fef:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106ff4:	e9 b9 f4 ff ff       	jmp    801064b2 <alltraps>

80106ff9 <vector133>:
.globl vector133
vector133:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $133
80106ffb:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107000:	e9 ad f4 ff ff       	jmp    801064b2 <alltraps>

80107005 <vector134>:
.globl vector134
vector134:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $134
80107007:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010700c:	e9 a1 f4 ff ff       	jmp    801064b2 <alltraps>

80107011 <vector135>:
.globl vector135
vector135:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $135
80107013:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107018:	e9 95 f4 ff ff       	jmp    801064b2 <alltraps>

8010701d <vector136>:
.globl vector136
vector136:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $136
8010701f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107024:	e9 89 f4 ff ff       	jmp    801064b2 <alltraps>

80107029 <vector137>:
.globl vector137
vector137:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $137
8010702b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107030:	e9 7d f4 ff ff       	jmp    801064b2 <alltraps>

80107035 <vector138>:
.globl vector138
vector138:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $138
80107037:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010703c:	e9 71 f4 ff ff       	jmp    801064b2 <alltraps>

80107041 <vector139>:
.globl vector139
vector139:
  pushl $0
80107041:	6a 00                	push   $0x0
  pushl $139
80107043:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107048:	e9 65 f4 ff ff       	jmp    801064b2 <alltraps>

8010704d <vector140>:
.globl vector140
vector140:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $140
8010704f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107054:	e9 59 f4 ff ff       	jmp    801064b2 <alltraps>

80107059 <vector141>:
.globl vector141
vector141:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $141
8010705b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107060:	e9 4d f4 ff ff       	jmp    801064b2 <alltraps>

80107065 <vector142>:
.globl vector142
vector142:
  pushl $0
80107065:	6a 00                	push   $0x0
  pushl $142
80107067:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010706c:	e9 41 f4 ff ff       	jmp    801064b2 <alltraps>

80107071 <vector143>:
.globl vector143
vector143:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $143
80107073:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107078:	e9 35 f4 ff ff       	jmp    801064b2 <alltraps>

8010707d <vector144>:
.globl vector144
vector144:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $144
8010707f:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107084:	e9 29 f4 ff ff       	jmp    801064b2 <alltraps>

80107089 <vector145>:
.globl vector145
vector145:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $145
8010708b:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107090:	e9 1d f4 ff ff       	jmp    801064b2 <alltraps>

80107095 <vector146>:
.globl vector146
vector146:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $146
80107097:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010709c:	e9 11 f4 ff ff       	jmp    801064b2 <alltraps>

801070a1 <vector147>:
.globl vector147
vector147:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $147
801070a3:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801070a8:	e9 05 f4 ff ff       	jmp    801064b2 <alltraps>

801070ad <vector148>:
.globl vector148
vector148:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $148
801070af:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801070b4:	e9 f9 f3 ff ff       	jmp    801064b2 <alltraps>

801070b9 <vector149>:
.globl vector149
vector149:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $149
801070bb:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801070c0:	e9 ed f3 ff ff       	jmp    801064b2 <alltraps>

801070c5 <vector150>:
.globl vector150
vector150:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $150
801070c7:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801070cc:	e9 e1 f3 ff ff       	jmp    801064b2 <alltraps>

801070d1 <vector151>:
.globl vector151
vector151:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $151
801070d3:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801070d8:	e9 d5 f3 ff ff       	jmp    801064b2 <alltraps>

801070dd <vector152>:
.globl vector152
vector152:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $152
801070df:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801070e4:	e9 c9 f3 ff ff       	jmp    801064b2 <alltraps>

801070e9 <vector153>:
.globl vector153
vector153:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $153
801070eb:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801070f0:	e9 bd f3 ff ff       	jmp    801064b2 <alltraps>

801070f5 <vector154>:
.globl vector154
vector154:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $154
801070f7:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801070fc:	e9 b1 f3 ff ff       	jmp    801064b2 <alltraps>

80107101 <vector155>:
.globl vector155
vector155:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $155
80107103:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107108:	e9 a5 f3 ff ff       	jmp    801064b2 <alltraps>

8010710d <vector156>:
.globl vector156
vector156:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $156
8010710f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107114:	e9 99 f3 ff ff       	jmp    801064b2 <alltraps>

80107119 <vector157>:
.globl vector157
vector157:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $157
8010711b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107120:	e9 8d f3 ff ff       	jmp    801064b2 <alltraps>

80107125 <vector158>:
.globl vector158
vector158:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $158
80107127:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010712c:	e9 81 f3 ff ff       	jmp    801064b2 <alltraps>

80107131 <vector159>:
.globl vector159
vector159:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $159
80107133:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107138:	e9 75 f3 ff ff       	jmp    801064b2 <alltraps>

8010713d <vector160>:
.globl vector160
vector160:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $160
8010713f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107144:	e9 69 f3 ff ff       	jmp    801064b2 <alltraps>

80107149 <vector161>:
.globl vector161
vector161:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $161
8010714b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107150:	e9 5d f3 ff ff       	jmp    801064b2 <alltraps>

80107155 <vector162>:
.globl vector162
vector162:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $162
80107157:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010715c:	e9 51 f3 ff ff       	jmp    801064b2 <alltraps>

80107161 <vector163>:
.globl vector163
vector163:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $163
80107163:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107168:	e9 45 f3 ff ff       	jmp    801064b2 <alltraps>

8010716d <vector164>:
.globl vector164
vector164:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $164
8010716f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107174:	e9 39 f3 ff ff       	jmp    801064b2 <alltraps>

80107179 <vector165>:
.globl vector165
vector165:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $165
8010717b:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107180:	e9 2d f3 ff ff       	jmp    801064b2 <alltraps>

80107185 <vector166>:
.globl vector166
vector166:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $166
80107187:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010718c:	e9 21 f3 ff ff       	jmp    801064b2 <alltraps>

80107191 <vector167>:
.globl vector167
vector167:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $167
80107193:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107198:	e9 15 f3 ff ff       	jmp    801064b2 <alltraps>

8010719d <vector168>:
.globl vector168
vector168:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $168
8010719f:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801071a4:	e9 09 f3 ff ff       	jmp    801064b2 <alltraps>

801071a9 <vector169>:
.globl vector169
vector169:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $169
801071ab:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801071b0:	e9 fd f2 ff ff       	jmp    801064b2 <alltraps>

801071b5 <vector170>:
.globl vector170
vector170:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $170
801071b7:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801071bc:	e9 f1 f2 ff ff       	jmp    801064b2 <alltraps>

801071c1 <vector171>:
.globl vector171
vector171:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $171
801071c3:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801071c8:	e9 e5 f2 ff ff       	jmp    801064b2 <alltraps>

801071cd <vector172>:
.globl vector172
vector172:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $172
801071cf:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801071d4:	e9 d9 f2 ff ff       	jmp    801064b2 <alltraps>

801071d9 <vector173>:
.globl vector173
vector173:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $173
801071db:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801071e0:	e9 cd f2 ff ff       	jmp    801064b2 <alltraps>

801071e5 <vector174>:
.globl vector174
vector174:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $174
801071e7:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801071ec:	e9 c1 f2 ff ff       	jmp    801064b2 <alltraps>

801071f1 <vector175>:
.globl vector175
vector175:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $175
801071f3:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801071f8:	e9 b5 f2 ff ff       	jmp    801064b2 <alltraps>

801071fd <vector176>:
.globl vector176
vector176:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $176
801071ff:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107204:	e9 a9 f2 ff ff       	jmp    801064b2 <alltraps>

80107209 <vector177>:
.globl vector177
vector177:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $177
8010720b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107210:	e9 9d f2 ff ff       	jmp    801064b2 <alltraps>

80107215 <vector178>:
.globl vector178
vector178:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $178
80107217:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010721c:	e9 91 f2 ff ff       	jmp    801064b2 <alltraps>

80107221 <vector179>:
.globl vector179
vector179:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $179
80107223:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107228:	e9 85 f2 ff ff       	jmp    801064b2 <alltraps>

8010722d <vector180>:
.globl vector180
vector180:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $180
8010722f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107234:	e9 79 f2 ff ff       	jmp    801064b2 <alltraps>

80107239 <vector181>:
.globl vector181
vector181:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $181
8010723b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107240:	e9 6d f2 ff ff       	jmp    801064b2 <alltraps>

80107245 <vector182>:
.globl vector182
vector182:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $182
80107247:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010724c:	e9 61 f2 ff ff       	jmp    801064b2 <alltraps>

80107251 <vector183>:
.globl vector183
vector183:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $183
80107253:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107258:	e9 55 f2 ff ff       	jmp    801064b2 <alltraps>

8010725d <vector184>:
.globl vector184
vector184:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $184
8010725f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107264:	e9 49 f2 ff ff       	jmp    801064b2 <alltraps>

80107269 <vector185>:
.globl vector185
vector185:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $185
8010726b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107270:	e9 3d f2 ff ff       	jmp    801064b2 <alltraps>

80107275 <vector186>:
.globl vector186
vector186:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $186
80107277:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010727c:	e9 31 f2 ff ff       	jmp    801064b2 <alltraps>

80107281 <vector187>:
.globl vector187
vector187:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $187
80107283:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107288:	e9 25 f2 ff ff       	jmp    801064b2 <alltraps>

8010728d <vector188>:
.globl vector188
vector188:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $188
8010728f:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107294:	e9 19 f2 ff ff       	jmp    801064b2 <alltraps>

80107299 <vector189>:
.globl vector189
vector189:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $189
8010729b:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801072a0:	e9 0d f2 ff ff       	jmp    801064b2 <alltraps>

801072a5 <vector190>:
.globl vector190
vector190:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $190
801072a7:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801072ac:	e9 01 f2 ff ff       	jmp    801064b2 <alltraps>

801072b1 <vector191>:
.globl vector191
vector191:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $191
801072b3:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801072b8:	e9 f5 f1 ff ff       	jmp    801064b2 <alltraps>

801072bd <vector192>:
.globl vector192
vector192:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $192
801072bf:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801072c4:	e9 e9 f1 ff ff       	jmp    801064b2 <alltraps>

801072c9 <vector193>:
.globl vector193
vector193:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $193
801072cb:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801072d0:	e9 dd f1 ff ff       	jmp    801064b2 <alltraps>

801072d5 <vector194>:
.globl vector194
vector194:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $194
801072d7:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801072dc:	e9 d1 f1 ff ff       	jmp    801064b2 <alltraps>

801072e1 <vector195>:
.globl vector195
vector195:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $195
801072e3:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801072e8:	e9 c5 f1 ff ff       	jmp    801064b2 <alltraps>

801072ed <vector196>:
.globl vector196
vector196:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $196
801072ef:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801072f4:	e9 b9 f1 ff ff       	jmp    801064b2 <alltraps>

801072f9 <vector197>:
.globl vector197
vector197:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $197
801072fb:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107300:	e9 ad f1 ff ff       	jmp    801064b2 <alltraps>

80107305 <vector198>:
.globl vector198
vector198:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $198
80107307:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010730c:	e9 a1 f1 ff ff       	jmp    801064b2 <alltraps>

80107311 <vector199>:
.globl vector199
vector199:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $199
80107313:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107318:	e9 95 f1 ff ff       	jmp    801064b2 <alltraps>

8010731d <vector200>:
.globl vector200
vector200:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $200
8010731f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107324:	e9 89 f1 ff ff       	jmp    801064b2 <alltraps>

80107329 <vector201>:
.globl vector201
vector201:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $201
8010732b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107330:	e9 7d f1 ff ff       	jmp    801064b2 <alltraps>

80107335 <vector202>:
.globl vector202
vector202:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $202
80107337:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010733c:	e9 71 f1 ff ff       	jmp    801064b2 <alltraps>

80107341 <vector203>:
.globl vector203
vector203:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $203
80107343:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107348:	e9 65 f1 ff ff       	jmp    801064b2 <alltraps>

8010734d <vector204>:
.globl vector204
vector204:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $204
8010734f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107354:	e9 59 f1 ff ff       	jmp    801064b2 <alltraps>

80107359 <vector205>:
.globl vector205
vector205:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $205
8010735b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107360:	e9 4d f1 ff ff       	jmp    801064b2 <alltraps>

80107365 <vector206>:
.globl vector206
vector206:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $206
80107367:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010736c:	e9 41 f1 ff ff       	jmp    801064b2 <alltraps>

80107371 <vector207>:
.globl vector207
vector207:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $207
80107373:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107378:	e9 35 f1 ff ff       	jmp    801064b2 <alltraps>

8010737d <vector208>:
.globl vector208
vector208:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $208
8010737f:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107384:	e9 29 f1 ff ff       	jmp    801064b2 <alltraps>

80107389 <vector209>:
.globl vector209
vector209:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $209
8010738b:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107390:	e9 1d f1 ff ff       	jmp    801064b2 <alltraps>

80107395 <vector210>:
.globl vector210
vector210:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $210
80107397:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010739c:	e9 11 f1 ff ff       	jmp    801064b2 <alltraps>

801073a1 <vector211>:
.globl vector211
vector211:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $211
801073a3:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801073a8:	e9 05 f1 ff ff       	jmp    801064b2 <alltraps>

801073ad <vector212>:
.globl vector212
vector212:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $212
801073af:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801073b4:	e9 f9 f0 ff ff       	jmp    801064b2 <alltraps>

801073b9 <vector213>:
.globl vector213
vector213:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $213
801073bb:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801073c0:	e9 ed f0 ff ff       	jmp    801064b2 <alltraps>

801073c5 <vector214>:
.globl vector214
vector214:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $214
801073c7:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801073cc:	e9 e1 f0 ff ff       	jmp    801064b2 <alltraps>

801073d1 <vector215>:
.globl vector215
vector215:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $215
801073d3:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801073d8:	e9 d5 f0 ff ff       	jmp    801064b2 <alltraps>

801073dd <vector216>:
.globl vector216
vector216:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $216
801073df:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801073e4:	e9 c9 f0 ff ff       	jmp    801064b2 <alltraps>

801073e9 <vector217>:
.globl vector217
vector217:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $217
801073eb:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801073f0:	e9 bd f0 ff ff       	jmp    801064b2 <alltraps>

801073f5 <vector218>:
.globl vector218
vector218:
  pushl $0
801073f5:	6a 00                	push   $0x0
  pushl $218
801073f7:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801073fc:	e9 b1 f0 ff ff       	jmp    801064b2 <alltraps>

80107401 <vector219>:
.globl vector219
vector219:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $219
80107403:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107408:	e9 a5 f0 ff ff       	jmp    801064b2 <alltraps>

8010740d <vector220>:
.globl vector220
vector220:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $220
8010740f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107414:	e9 99 f0 ff ff       	jmp    801064b2 <alltraps>

80107419 <vector221>:
.globl vector221
vector221:
  pushl $0
80107419:	6a 00                	push   $0x0
  pushl $221
8010741b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107420:	e9 8d f0 ff ff       	jmp    801064b2 <alltraps>

80107425 <vector222>:
.globl vector222
vector222:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $222
80107427:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010742c:	e9 81 f0 ff ff       	jmp    801064b2 <alltraps>

80107431 <vector223>:
.globl vector223
vector223:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $223
80107433:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107438:	e9 75 f0 ff ff       	jmp    801064b2 <alltraps>

8010743d <vector224>:
.globl vector224
vector224:
  pushl $0
8010743d:	6a 00                	push   $0x0
  pushl $224
8010743f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107444:	e9 69 f0 ff ff       	jmp    801064b2 <alltraps>

80107449 <vector225>:
.globl vector225
vector225:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $225
8010744b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107450:	e9 5d f0 ff ff       	jmp    801064b2 <alltraps>

80107455 <vector226>:
.globl vector226
vector226:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $226
80107457:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010745c:	e9 51 f0 ff ff       	jmp    801064b2 <alltraps>

80107461 <vector227>:
.globl vector227
vector227:
  pushl $0
80107461:	6a 00                	push   $0x0
  pushl $227
80107463:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107468:	e9 45 f0 ff ff       	jmp    801064b2 <alltraps>

8010746d <vector228>:
.globl vector228
vector228:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $228
8010746f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107474:	e9 39 f0 ff ff       	jmp    801064b2 <alltraps>

80107479 <vector229>:
.globl vector229
vector229:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $229
8010747b:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107480:	e9 2d f0 ff ff       	jmp    801064b2 <alltraps>

80107485 <vector230>:
.globl vector230
vector230:
  pushl $0
80107485:	6a 00                	push   $0x0
  pushl $230
80107487:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010748c:	e9 21 f0 ff ff       	jmp    801064b2 <alltraps>

80107491 <vector231>:
.globl vector231
vector231:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $231
80107493:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107498:	e9 15 f0 ff ff       	jmp    801064b2 <alltraps>

8010749d <vector232>:
.globl vector232
vector232:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $232
8010749f:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801074a4:	e9 09 f0 ff ff       	jmp    801064b2 <alltraps>

801074a9 <vector233>:
.globl vector233
vector233:
  pushl $0
801074a9:	6a 00                	push   $0x0
  pushl $233
801074ab:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801074b0:	e9 fd ef ff ff       	jmp    801064b2 <alltraps>

801074b5 <vector234>:
.globl vector234
vector234:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $234
801074b7:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801074bc:	e9 f1 ef ff ff       	jmp    801064b2 <alltraps>

801074c1 <vector235>:
.globl vector235
vector235:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $235
801074c3:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801074c8:	e9 e5 ef ff ff       	jmp    801064b2 <alltraps>

801074cd <vector236>:
.globl vector236
vector236:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $236
801074cf:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801074d4:	e9 d9 ef ff ff       	jmp    801064b2 <alltraps>

801074d9 <vector237>:
.globl vector237
vector237:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $237
801074db:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801074e0:	e9 cd ef ff ff       	jmp    801064b2 <alltraps>

801074e5 <vector238>:
.globl vector238
vector238:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $238
801074e7:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801074ec:	e9 c1 ef ff ff       	jmp    801064b2 <alltraps>

801074f1 <vector239>:
.globl vector239
vector239:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $239
801074f3:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801074f8:	e9 b5 ef ff ff       	jmp    801064b2 <alltraps>

801074fd <vector240>:
.globl vector240
vector240:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $240
801074ff:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107504:	e9 a9 ef ff ff       	jmp    801064b2 <alltraps>

80107509 <vector241>:
.globl vector241
vector241:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $241
8010750b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107510:	e9 9d ef ff ff       	jmp    801064b2 <alltraps>

80107515 <vector242>:
.globl vector242
vector242:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $242
80107517:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010751c:	e9 91 ef ff ff       	jmp    801064b2 <alltraps>

80107521 <vector243>:
.globl vector243
vector243:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $243
80107523:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107528:	e9 85 ef ff ff       	jmp    801064b2 <alltraps>

8010752d <vector244>:
.globl vector244
vector244:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $244
8010752f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107534:	e9 79 ef ff ff       	jmp    801064b2 <alltraps>

80107539 <vector245>:
.globl vector245
vector245:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $245
8010753b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107540:	e9 6d ef ff ff       	jmp    801064b2 <alltraps>

80107545 <vector246>:
.globl vector246
vector246:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $246
80107547:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010754c:	e9 61 ef ff ff       	jmp    801064b2 <alltraps>

80107551 <vector247>:
.globl vector247
vector247:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $247
80107553:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107558:	e9 55 ef ff ff       	jmp    801064b2 <alltraps>

8010755d <vector248>:
.globl vector248
vector248:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $248
8010755f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107564:	e9 49 ef ff ff       	jmp    801064b2 <alltraps>

80107569 <vector249>:
.globl vector249
vector249:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $249
8010756b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107570:	e9 3d ef ff ff       	jmp    801064b2 <alltraps>

80107575 <vector250>:
.globl vector250
vector250:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $250
80107577:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010757c:	e9 31 ef ff ff       	jmp    801064b2 <alltraps>

80107581 <vector251>:
.globl vector251
vector251:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $251
80107583:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107588:	e9 25 ef ff ff       	jmp    801064b2 <alltraps>

8010758d <vector252>:
.globl vector252
vector252:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $252
8010758f:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107594:	e9 19 ef ff ff       	jmp    801064b2 <alltraps>

80107599 <vector253>:
.globl vector253
vector253:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $253
8010759b:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801075a0:	e9 0d ef ff ff       	jmp    801064b2 <alltraps>

801075a5 <vector254>:
.globl vector254
vector254:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $254
801075a7:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801075ac:	e9 01 ef ff ff       	jmp    801064b2 <alltraps>

801075b1 <vector255>:
.globl vector255
vector255:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $255
801075b3:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801075b8:	e9 f5 ee ff ff       	jmp    801064b2 <alltraps>

801075bd <lgdt>:
{
801075bd:	55                   	push   %ebp
801075be:	89 e5                	mov    %esp,%ebp
801075c0:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801075c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801075c6:	83 e8 01             	sub    $0x1,%eax
801075c9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801075cd:	8b 45 08             	mov    0x8(%ebp),%eax
801075d0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801075d4:	8b 45 08             	mov    0x8(%ebp),%eax
801075d7:	c1 e8 10             	shr    $0x10,%eax
801075da:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801075de:	8d 45 fa             	lea    -0x6(%ebp),%eax
801075e1:	0f 01 10             	lgdtl  (%eax)
}
801075e4:	90                   	nop
801075e5:	c9                   	leave  
801075e6:	c3                   	ret    

801075e7 <ltr>:
{
801075e7:	55                   	push   %ebp
801075e8:	89 e5                	mov    %esp,%ebp
801075ea:	83 ec 04             	sub    $0x4,%esp
801075ed:	8b 45 08             	mov    0x8(%ebp),%eax
801075f0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801075f4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801075f8:	0f 00 d8             	ltr    %ax
}
801075fb:	90                   	nop
801075fc:	c9                   	leave  
801075fd:	c3                   	ret    

801075fe <lcr3>:

static inline void
lcr3(uint val)
{
801075fe:	55                   	push   %ebp
801075ff:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107601:	8b 45 08             	mov    0x8(%ebp),%eax
80107604:	0f 22 d8             	mov    %eax,%cr3
}
80107607:	90                   	nop
80107608:	5d                   	pop    %ebp
80107609:	c3                   	ret    

8010760a <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010760a:	f3 0f 1e fb          	endbr32 
8010760e:	55                   	push   %ebp
8010760f:	89 e5                	mov    %esp,%ebp
80107611:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107614:	e8 f5 c4 ff ff       	call   80103b0e <cpuid>
80107619:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010761f:	05 c0 7e 19 80       	add    $0x80197ec0,%eax
80107624:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107633:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107643:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107647:	83 e2 f0             	and    $0xfffffff0,%edx
8010764a:	83 ca 0a             	or     $0xa,%edx
8010764d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107653:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107657:	83 ca 10             	or     $0x10,%edx
8010765a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010765d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107660:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107664:	83 e2 9f             	and    $0xffffff9f,%edx
80107667:	88 50 7d             	mov    %dl,0x7d(%eax)
8010766a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107671:	83 ca 80             	or     $0xffffff80,%edx
80107674:	88 50 7d             	mov    %dl,0x7d(%eax)
80107677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010767e:	83 ca 0f             	or     $0xf,%edx
80107681:	88 50 7e             	mov    %dl,0x7e(%eax)
80107684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107687:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010768b:	83 e2 ef             	and    $0xffffffef,%edx
8010768e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107694:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107698:	83 e2 df             	and    $0xffffffdf,%edx
8010769b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010769e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801076a5:	83 ca 40             	or     $0x40,%edx
801076a8:	88 50 7e             	mov    %dl,0x7e(%eax)
801076ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ae:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801076b2:	83 ca 80             	or     $0xffffff80,%edx
801076b5:	88 50 7e             	mov    %dl,0x7e(%eax)
801076b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076bb:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801076bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c2:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801076c9:	ff ff 
801076cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ce:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801076d5:	00 00 
801076d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076da:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801076e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076eb:	83 e2 f0             	and    $0xfffffff0,%edx
801076ee:	83 ca 02             	or     $0x2,%edx
801076f1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fa:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107701:	83 ca 10             	or     $0x10,%edx
80107704:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010770a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107714:	83 e2 9f             	and    $0xffffff9f,%edx
80107717:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010771d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107720:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107727:	83 ca 80             	or     $0xffffff80,%edx
8010772a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107733:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010773a:	83 ca 0f             	or     $0xf,%edx
8010773d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107746:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010774d:	83 e2 ef             	and    $0xffffffef,%edx
80107750:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107756:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107759:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107760:	83 e2 df             	and    $0xffffffdf,%edx
80107763:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107773:	83 ca 40             	or     $0x40,%edx
80107776:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010777c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107786:	83 ca 80             	or     $0xffffff80,%edx
80107789:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010778f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107792:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779c:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801077a3:	ff ff 
801077a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a8:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801077af:	00 00 
801077b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b4:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801077bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077be:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077c5:	83 e2 f0             	and    $0xfffffff0,%edx
801077c8:	83 ca 0a             	or     $0xa,%edx
801077cb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d4:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077db:	83 ca 10             	or     $0x10,%edx
801077de:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e7:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077ee:	83 ca 60             	or     $0x60,%edx
801077f1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fa:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107801:	83 ca 80             	or     $0xffffff80,%edx
80107804:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010780a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107814:	83 ca 0f             	or     $0xf,%edx
80107817:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010781d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107820:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107827:	83 e2 ef             	and    $0xffffffef,%edx
8010782a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107833:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010783a:	83 e2 df             	and    $0xffffffdf,%edx
8010783d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107846:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010784d:	83 ca 40             	or     $0x40,%edx
80107850:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107859:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107860:	83 ca 80             	or     $0xffffff80,%edx
80107863:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786c:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107876:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010787d:	ff ff 
8010787f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107882:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107889:	00 00 
8010788b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788e:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107898:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010789f:	83 e2 f0             	and    $0xfffffff0,%edx
801078a2:	83 ca 02             	or     $0x2,%edx
801078a5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ae:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078b5:	83 ca 10             	or     $0x10,%edx
801078b8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078c8:	83 ca 60             	or     $0x60,%edx
801078cb:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078db:	83 ca 80             	or     $0xffffff80,%edx
801078de:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078ee:	83 ca 0f             	or     $0xf,%edx
801078f1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fa:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107901:	83 e2 ef             	and    $0xffffffef,%edx
80107904:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010790a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107914:	83 e2 df             	and    $0xffffffdf,%edx
80107917:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010791d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107920:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107927:	83 ca 40             	or     $0x40,%edx
8010792a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107933:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010793a:	83 ca 80             	or     $0xffffff80,%edx
8010793d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107946:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010794d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107950:	83 c0 70             	add    $0x70,%eax
80107953:	83 ec 08             	sub    $0x8,%esp
80107956:	6a 30                	push   $0x30
80107958:	50                   	push   %eax
80107959:	e8 5f fc ff ff       	call   801075bd <lgdt>
8010795e:	83 c4 10             	add    $0x10,%esp
}
80107961:	90                   	nop
80107962:	c9                   	leave  
80107963:	c3                   	ret    

80107964 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107964:	f3 0f 1e fb          	endbr32 
80107968:	55                   	push   %ebp
80107969:	89 e5                	mov    %esp,%ebp
8010796b:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010796e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107971:	c1 e8 16             	shr    $0x16,%eax
80107974:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010797b:	8b 45 08             	mov    0x8(%ebp),%eax
8010797e:	01 d0                	add    %edx,%eax
80107980:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107983:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107986:	8b 00                	mov    (%eax),%eax
80107988:	83 e0 01             	and    $0x1,%eax
8010798b:	85 c0                	test   %eax,%eax
8010798d:	74 14                	je     801079a3 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010798f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107992:	8b 00                	mov    (%eax),%eax
80107994:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107999:	05 00 00 00 80       	add    $0x80000000,%eax
8010799e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801079a1:	eb 42                	jmp    801079e5 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801079a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801079a7:	74 0e                	je     801079b7 <walkpgdir+0x53>
801079a9:	e8 e4 ae ff ff       	call   80102892 <kalloc>
801079ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801079b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801079b5:	75 07                	jne    801079be <walkpgdir+0x5a>
      return 0;
801079b7:	b8 00 00 00 00       	mov    $0x0,%eax
801079bc:	eb 3e                	jmp    801079fc <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801079be:	83 ec 04             	sub    $0x4,%esp
801079c1:	68 00 10 00 00       	push   $0x1000
801079c6:	6a 00                	push   $0x0
801079c8:	ff 75 f4             	pushl  -0xc(%ebp)
801079cb:	e8 df d5 ff ff       	call   80104faf <memset>
801079d0:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801079d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d6:	05 00 00 00 80       	add    $0x80000000,%eax
801079db:	83 c8 07             	or     $0x7,%eax
801079de:	89 c2                	mov    %eax,%edx
801079e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079e3:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801079e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801079e8:	c1 e8 0c             	shr    $0xc,%eax
801079eb:	25 ff 03 00 00       	and    $0x3ff,%eax
801079f0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fa:	01 d0                	add    %edx,%eax
}
801079fc:	c9                   	leave  
801079fd:	c3                   	ret    

801079fe <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801079fe:	f3 0f 1e fb          	endbr32 
80107a02:	55                   	push   %ebp
80107a03:	89 e5                	mov    %esp,%ebp
80107a05:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107a08:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107a13:	8b 55 0c             	mov    0xc(%ebp),%edx
80107a16:	8b 45 10             	mov    0x10(%ebp),%eax
80107a19:	01 d0                	add    %edx,%eax
80107a1b:	83 e8 01             	sub    $0x1,%eax
80107a1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107a26:	83 ec 04             	sub    $0x4,%esp
80107a29:	6a 01                	push   $0x1
80107a2b:	ff 75 f4             	pushl  -0xc(%ebp)
80107a2e:	ff 75 08             	pushl  0x8(%ebp)
80107a31:	e8 2e ff ff ff       	call   80107964 <walkpgdir>
80107a36:	83 c4 10             	add    $0x10,%esp
80107a39:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a3c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a40:	75 07                	jne    80107a49 <mappages+0x4b>
      return -1;
80107a42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a47:	eb 47                	jmp    80107a90 <mappages+0x92>
    if(*pte & PTE_P)
80107a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a4c:	8b 00                	mov    (%eax),%eax
80107a4e:	83 e0 01             	and    $0x1,%eax
80107a51:	85 c0                	test   %eax,%eax
80107a53:	74 0d                	je     80107a62 <mappages+0x64>
      panic("remap");
80107a55:	83 ec 0c             	sub    $0xc,%esp
80107a58:	68 b0 ae 10 80       	push   $0x8010aeb0
80107a5d:	e8 63 8b ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
80107a62:	8b 45 18             	mov    0x18(%ebp),%eax
80107a65:	0b 45 14             	or     0x14(%ebp),%eax
80107a68:	83 c8 01             	or     $0x1,%eax
80107a6b:	89 c2                	mov    %eax,%edx
80107a6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a70:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a75:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107a78:	74 10                	je     80107a8a <mappages+0x8c>
      break;
    a += PGSIZE;
80107a7a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107a81:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107a88:	eb 9c                	jmp    80107a26 <mappages+0x28>
      break;
80107a8a:	90                   	nop
  }
  return 0;
80107a8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a90:	c9                   	leave  
80107a91:	c3                   	ret    

80107a92 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107a92:	f3 0f 1e fb          	endbr32 
80107a96:	55                   	push   %ebp
80107a97:	89 e5                	mov    %esp,%ebp
80107a99:	53                   	push   %ebx
80107a9a:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107a9d:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107aa4:	a1 8c 81 19 80       	mov    0x8019818c,%eax
80107aa9:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107aae:	29 c2                	sub    %eax,%edx
80107ab0:	89 d0                	mov    %edx,%eax
80107ab2:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ab5:	a1 84 81 19 80       	mov    0x80198184,%eax
80107aba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107abd:	8b 15 84 81 19 80    	mov    0x80198184,%edx
80107ac3:	a1 8c 81 19 80       	mov    0x8019818c,%eax
80107ac8:	01 d0                	add    %edx,%eax
80107aca:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107acd:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad7:	83 c0 30             	add    $0x30,%eax
80107ada:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107add:	89 10                	mov    %edx,(%eax)
80107adf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107ae2:	89 50 04             	mov    %edx,0x4(%eax)
80107ae5:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107ae8:	89 50 08             	mov    %edx,0x8(%eax)
80107aeb:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107aee:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107af1:	e8 9c ad ff ff       	call   80102892 <kalloc>
80107af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107af9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107afd:	75 07                	jne    80107b06 <setupkvm+0x74>
    return 0;
80107aff:	b8 00 00 00 00       	mov    $0x0,%eax
80107b04:	eb 78                	jmp    80107b7e <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
80107b06:	83 ec 04             	sub    $0x4,%esp
80107b09:	68 00 10 00 00       	push   $0x1000
80107b0e:	6a 00                	push   $0x0
80107b10:	ff 75 f0             	pushl  -0x10(%ebp)
80107b13:	e8 97 d4 ff ff       	call   80104faf <memset>
80107b18:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b1b:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107b22:	eb 4e                	jmp    80107b72 <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b27:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2d:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b33:	8b 58 08             	mov    0x8(%eax),%ebx
80107b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b39:	8b 40 04             	mov    0x4(%eax),%eax
80107b3c:	29 c3                	sub    %eax,%ebx
80107b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b41:	8b 00                	mov    (%eax),%eax
80107b43:	83 ec 0c             	sub    $0xc,%esp
80107b46:	51                   	push   %ecx
80107b47:	52                   	push   %edx
80107b48:	53                   	push   %ebx
80107b49:	50                   	push   %eax
80107b4a:	ff 75 f0             	pushl  -0x10(%ebp)
80107b4d:	e8 ac fe ff ff       	call   801079fe <mappages>
80107b52:	83 c4 20             	add    $0x20,%esp
80107b55:	85 c0                	test   %eax,%eax
80107b57:	79 15                	jns    80107b6e <setupkvm+0xdc>
      freevm(pgdir);
80107b59:	83 ec 0c             	sub    $0xc,%esp
80107b5c:	ff 75 f0             	pushl  -0x10(%ebp)
80107b5f:	e8 11 05 00 00       	call   80108075 <freevm>
80107b64:	83 c4 10             	add    $0x10,%esp
      return 0;
80107b67:	b8 00 00 00 00       	mov    $0x0,%eax
80107b6c:	eb 10                	jmp    80107b7e <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b6e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107b72:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107b79:	72 a9                	jb     80107b24 <setupkvm+0x92>
    }
  return pgdir;
80107b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107b81:	c9                   	leave  
80107b82:	c3                   	ret    

80107b83 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107b83:	f3 0f 1e fb          	endbr32 
80107b87:	55                   	push   %ebp
80107b88:	89 e5                	mov    %esp,%ebp
80107b8a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107b8d:	e8 00 ff ff ff       	call   80107a92 <setupkvm>
80107b92:	a3 84 7e 19 80       	mov    %eax,0x80197e84
  switchkvm();
80107b97:	e8 03 00 00 00       	call   80107b9f <switchkvm>
}
80107b9c:	90                   	nop
80107b9d:	c9                   	leave  
80107b9e:	c3                   	ret    

80107b9f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107b9f:	f3 0f 1e fb          	endbr32 
80107ba3:	55                   	push   %ebp
80107ba4:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107ba6:	a1 84 7e 19 80       	mov    0x80197e84,%eax
80107bab:	05 00 00 00 80       	add    $0x80000000,%eax
80107bb0:	50                   	push   %eax
80107bb1:	e8 48 fa ff ff       	call   801075fe <lcr3>
80107bb6:	83 c4 04             	add    $0x4,%esp
}
80107bb9:	90                   	nop
80107bba:	c9                   	leave  
80107bbb:	c3                   	ret    

80107bbc <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107bbc:	f3 0f 1e fb          	endbr32 
80107bc0:	55                   	push   %ebp
80107bc1:	89 e5                	mov    %esp,%ebp
80107bc3:	56                   	push   %esi
80107bc4:	53                   	push   %ebx
80107bc5:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107bc8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107bcc:	75 0d                	jne    80107bdb <switchuvm+0x1f>
    panic("switchuvm: no process");
80107bce:	83 ec 0c             	sub    $0xc,%esp
80107bd1:	68 b6 ae 10 80       	push   $0x8010aeb6
80107bd6:	e8 ea 89 ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
80107bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80107bde:	8b 40 08             	mov    0x8(%eax),%eax
80107be1:	85 c0                	test   %eax,%eax
80107be3:	75 0d                	jne    80107bf2 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107be5:	83 ec 0c             	sub    $0xc,%esp
80107be8:	68 cc ae 10 80       	push   $0x8010aecc
80107bed:	e8 d3 89 ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
80107bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf5:	8b 40 04             	mov    0x4(%eax),%eax
80107bf8:	85 c0                	test   %eax,%eax
80107bfa:	75 0d                	jne    80107c09 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107bfc:	83 ec 0c             	sub    $0xc,%esp
80107bff:	68 e1 ae 10 80       	push   $0x8010aee1
80107c04:	e8 bc 89 ff ff       	call   801005c5 <panic>

  pushcli();
80107c09:	e8 8e d2 ff ff       	call   80104e9c <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107c0e:	e8 1a bf ff ff       	call   80103b2d <mycpu>
80107c13:	89 c3                	mov    %eax,%ebx
80107c15:	e8 13 bf ff ff       	call   80103b2d <mycpu>
80107c1a:	83 c0 08             	add    $0x8,%eax
80107c1d:	89 c6                	mov    %eax,%esi
80107c1f:	e8 09 bf ff ff       	call   80103b2d <mycpu>
80107c24:	83 c0 08             	add    $0x8,%eax
80107c27:	c1 e8 10             	shr    $0x10,%eax
80107c2a:	88 45 f7             	mov    %al,-0x9(%ebp)
80107c2d:	e8 fb be ff ff       	call   80103b2d <mycpu>
80107c32:	83 c0 08             	add    $0x8,%eax
80107c35:	c1 e8 18             	shr    $0x18,%eax
80107c38:	89 c2                	mov    %eax,%edx
80107c3a:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107c41:	67 00 
80107c43:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107c4a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107c4e:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107c54:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c5b:	83 e0 f0             	and    $0xfffffff0,%eax
80107c5e:	83 c8 09             	or     $0x9,%eax
80107c61:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c67:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c6e:	83 c8 10             	or     $0x10,%eax
80107c71:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c77:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c7e:	83 e0 9f             	and    $0xffffff9f,%eax
80107c81:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c87:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c8e:	83 c8 80             	or     $0xffffff80,%eax
80107c91:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c97:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c9e:	83 e0 f0             	and    $0xfffffff0,%eax
80107ca1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ca7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107cae:	83 e0 ef             	and    $0xffffffef,%eax
80107cb1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107cb7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107cbe:	83 e0 df             	and    $0xffffffdf,%eax
80107cc1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107cc7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107cce:	83 c8 40             	or     $0x40,%eax
80107cd1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107cd7:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107cde:	83 e0 7f             	and    $0x7f,%eax
80107ce1:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ce7:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107ced:	e8 3b be ff ff       	call   80103b2d <mycpu>
80107cf2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cf9:	83 e2 ef             	and    $0xffffffef,%edx
80107cfc:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107d02:	e8 26 be ff ff       	call   80103b2d <mycpu>
80107d07:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107d0d:	8b 45 08             	mov    0x8(%ebp),%eax
80107d10:	8b 40 08             	mov    0x8(%eax),%eax
80107d13:	89 c3                	mov    %eax,%ebx
80107d15:	e8 13 be ff ff       	call   80103b2d <mycpu>
80107d1a:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107d20:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107d23:	e8 05 be ff ff       	call   80103b2d <mycpu>
80107d28:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107d2e:	83 ec 0c             	sub    $0xc,%esp
80107d31:	6a 28                	push   $0x28
80107d33:	e8 af f8 ff ff       	call   801075e7 <ltr>
80107d38:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80107d3e:	8b 40 04             	mov    0x4(%eax),%eax
80107d41:	05 00 00 00 80       	add    $0x80000000,%eax
80107d46:	83 ec 0c             	sub    $0xc,%esp
80107d49:	50                   	push   %eax
80107d4a:	e8 af f8 ff ff       	call   801075fe <lcr3>
80107d4f:	83 c4 10             	add    $0x10,%esp
  popcli();
80107d52:	e8 96 d1 ff ff       	call   80104eed <popcli>
}
80107d57:	90                   	nop
80107d58:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107d5b:	5b                   	pop    %ebx
80107d5c:	5e                   	pop    %esi
80107d5d:	5d                   	pop    %ebp
80107d5e:	c3                   	ret    

80107d5f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107d5f:	f3 0f 1e fb          	endbr32 
80107d63:	55                   	push   %ebp
80107d64:	89 e5                	mov    %esp,%ebp
80107d66:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107d69:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107d70:	76 0d                	jbe    80107d7f <inituvm+0x20>
    panic("inituvm: more than a page");
80107d72:	83 ec 0c             	sub    $0xc,%esp
80107d75:	68 f5 ae 10 80       	push   $0x8010aef5
80107d7a:	e8 46 88 ff ff       	call   801005c5 <panic>
  mem = kalloc();
80107d7f:	e8 0e ab ff ff       	call   80102892 <kalloc>
80107d84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107d87:	83 ec 04             	sub    $0x4,%esp
80107d8a:	68 00 10 00 00       	push   $0x1000
80107d8f:	6a 00                	push   $0x0
80107d91:	ff 75 f4             	pushl  -0xc(%ebp)
80107d94:	e8 16 d2 ff ff       	call   80104faf <memset>
80107d99:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9f:	05 00 00 00 80       	add    $0x80000000,%eax
80107da4:	83 ec 0c             	sub    $0xc,%esp
80107da7:	6a 06                	push   $0x6
80107da9:	50                   	push   %eax
80107daa:	68 00 10 00 00       	push   $0x1000
80107daf:	6a 00                	push   $0x0
80107db1:	ff 75 08             	pushl  0x8(%ebp)
80107db4:	e8 45 fc ff ff       	call   801079fe <mappages>
80107db9:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107dbc:	83 ec 04             	sub    $0x4,%esp
80107dbf:	ff 75 10             	pushl  0x10(%ebp)
80107dc2:	ff 75 0c             	pushl  0xc(%ebp)
80107dc5:	ff 75 f4             	pushl  -0xc(%ebp)
80107dc8:	e8 a9 d2 ff ff       	call   80105076 <memmove>
80107dcd:	83 c4 10             	add    $0x10,%esp
}
80107dd0:	90                   	nop
80107dd1:	c9                   	leave  
80107dd2:	c3                   	ret    

80107dd3 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107dd3:	f3 0f 1e fb          	endbr32 
80107dd7:	55                   	push   %ebp
80107dd8:	89 e5                	mov    %esp,%ebp
80107dda:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107de0:	25 ff 0f 00 00       	and    $0xfff,%eax
80107de5:	85 c0                	test   %eax,%eax
80107de7:	74 0d                	je     80107df6 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80107de9:	83 ec 0c             	sub    $0xc,%esp
80107dec:	68 10 af 10 80       	push   $0x8010af10
80107df1:	e8 cf 87 ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107df6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107dfd:	e9 8f 00 00 00       	jmp    80107e91 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107e02:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e08:	01 d0                	add    %edx,%eax
80107e0a:	83 ec 04             	sub    $0x4,%esp
80107e0d:	6a 00                	push   $0x0
80107e0f:	50                   	push   %eax
80107e10:	ff 75 08             	pushl  0x8(%ebp)
80107e13:	e8 4c fb ff ff       	call   80107964 <walkpgdir>
80107e18:	83 c4 10             	add    $0x10,%esp
80107e1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e1e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e22:	75 0d                	jne    80107e31 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80107e24:	83 ec 0c             	sub    $0xc,%esp
80107e27:	68 33 af 10 80       	push   $0x8010af33
80107e2c:	e8 94 87 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80107e31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e34:	8b 00                	mov    (%eax),%eax
80107e36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107e3e:	8b 45 18             	mov    0x18(%ebp),%eax
80107e41:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107e44:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107e49:	77 0b                	ja     80107e56 <loaduvm+0x83>
      n = sz - i;
80107e4b:	8b 45 18             	mov    0x18(%ebp),%eax
80107e4e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107e51:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e54:	eb 07                	jmp    80107e5d <loaduvm+0x8a>
    else
      n = PGSIZE;
80107e56:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107e5d:	8b 55 14             	mov    0x14(%ebp),%edx
80107e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e63:	01 d0                	add    %edx,%eax
80107e65:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107e68:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107e6e:	ff 75 f0             	pushl  -0x10(%ebp)
80107e71:	50                   	push   %eax
80107e72:	52                   	push   %edx
80107e73:	ff 75 10             	pushl  0x10(%ebp)
80107e76:	e8 09 a1 ff ff       	call   80101f84 <readi>
80107e7b:	83 c4 10             	add    $0x10,%esp
80107e7e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107e81:	74 07                	je     80107e8a <loaduvm+0xb7>
      return -1;
80107e83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e88:	eb 18                	jmp    80107ea2 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80107e8a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e94:	3b 45 18             	cmp    0x18(%ebp),%eax
80107e97:	0f 82 65 ff ff ff    	jb     80107e02 <loaduvm+0x2f>
  }
  return 0;
80107e9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ea2:	c9                   	leave  
80107ea3:	c3                   	ret    

80107ea4 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107ea4:	f3 0f 1e fb          	endbr32 
80107ea8:	55                   	push   %ebp
80107ea9:	89 e5                	mov    %esp,%ebp
80107eab:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107eae:	8b 45 10             	mov    0x10(%ebp),%eax
80107eb1:	85 c0                	test   %eax,%eax
80107eb3:	79 0a                	jns    80107ebf <allocuvm+0x1b>
    return 0;
80107eb5:	b8 00 00 00 00       	mov    $0x0,%eax
80107eba:	e9 ec 00 00 00       	jmp    80107fab <allocuvm+0x107>
  if(newsz < oldsz)
80107ebf:	8b 45 10             	mov    0x10(%ebp),%eax
80107ec2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ec5:	73 08                	jae    80107ecf <allocuvm+0x2b>
    return oldsz;
80107ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eca:	e9 dc 00 00 00       	jmp    80107fab <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
80107ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ed2:	05 ff 0f 00 00       	add    $0xfff,%eax
80107ed7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107edc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107edf:	e9 b8 00 00 00       	jmp    80107f9c <allocuvm+0xf8>
    mem = kalloc();
80107ee4:	e8 a9 a9 ff ff       	call   80102892 <kalloc>
80107ee9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107eec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ef0:	75 2e                	jne    80107f20 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80107ef2:	83 ec 0c             	sub    $0xc,%esp
80107ef5:	68 51 af 10 80       	push   $0x8010af51
80107efa:	e8 0d 85 ff ff       	call   8010040c <cprintf>
80107eff:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107f02:	83 ec 04             	sub    $0x4,%esp
80107f05:	ff 75 0c             	pushl  0xc(%ebp)
80107f08:	ff 75 10             	pushl  0x10(%ebp)
80107f0b:	ff 75 08             	pushl  0x8(%ebp)
80107f0e:	e8 9a 00 00 00       	call   80107fad <deallocuvm>
80107f13:	83 c4 10             	add    $0x10,%esp
      return 0;
80107f16:	b8 00 00 00 00       	mov    $0x0,%eax
80107f1b:	e9 8b 00 00 00       	jmp    80107fab <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80107f20:	83 ec 04             	sub    $0x4,%esp
80107f23:	68 00 10 00 00       	push   $0x1000
80107f28:	6a 00                	push   $0x0
80107f2a:	ff 75 f0             	pushl  -0x10(%ebp)
80107f2d:	e8 7d d0 ff ff       	call   80104faf <memset>
80107f32:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f38:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f41:	83 ec 0c             	sub    $0xc,%esp
80107f44:	6a 06                	push   $0x6
80107f46:	52                   	push   %edx
80107f47:	68 00 10 00 00       	push   $0x1000
80107f4c:	50                   	push   %eax
80107f4d:	ff 75 08             	pushl  0x8(%ebp)
80107f50:	e8 a9 fa ff ff       	call   801079fe <mappages>
80107f55:	83 c4 20             	add    $0x20,%esp
80107f58:	85 c0                	test   %eax,%eax
80107f5a:	79 39                	jns    80107f95 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80107f5c:	83 ec 0c             	sub    $0xc,%esp
80107f5f:	68 69 af 10 80       	push   $0x8010af69
80107f64:	e8 a3 84 ff ff       	call   8010040c <cprintf>
80107f69:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107f6c:	83 ec 04             	sub    $0x4,%esp
80107f6f:	ff 75 0c             	pushl  0xc(%ebp)
80107f72:	ff 75 10             	pushl  0x10(%ebp)
80107f75:	ff 75 08             	pushl  0x8(%ebp)
80107f78:	e8 30 00 00 00       	call   80107fad <deallocuvm>
80107f7d:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107f80:	83 ec 0c             	sub    $0xc,%esp
80107f83:	ff 75 f0             	pushl  -0x10(%ebp)
80107f86:	e8 69 a8 ff ff       	call   801027f4 <kfree>
80107f8b:	83 c4 10             	add    $0x10,%esp
      return 0;
80107f8e:	b8 00 00 00 00       	mov    $0x0,%eax
80107f93:	eb 16                	jmp    80107fab <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80107f95:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9f:	3b 45 10             	cmp    0x10(%ebp),%eax
80107fa2:	0f 82 3c ff ff ff    	jb     80107ee4 <allocuvm+0x40>
    }
  }
  return newsz;
80107fa8:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107fab:	c9                   	leave  
80107fac:	c3                   	ret    

80107fad <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107fad:	f3 0f 1e fb          	endbr32 
80107fb1:	55                   	push   %ebp
80107fb2:	89 e5                	mov    %esp,%ebp
80107fb4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107fb7:	8b 45 10             	mov    0x10(%ebp),%eax
80107fba:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fbd:	72 08                	jb     80107fc7 <deallocuvm+0x1a>
    return oldsz;
80107fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fc2:	e9 ac 00 00 00       	jmp    80108073 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80107fc7:	8b 45 10             	mov    0x10(%ebp),%eax
80107fca:	05 ff 0f 00 00       	add    $0xfff,%eax
80107fcf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107fd7:	e9 88 00 00 00       	jmp    80108064 <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fdf:	83 ec 04             	sub    $0x4,%esp
80107fe2:	6a 00                	push   $0x0
80107fe4:	50                   	push   %eax
80107fe5:	ff 75 08             	pushl  0x8(%ebp)
80107fe8:	e8 77 f9 ff ff       	call   80107964 <walkpgdir>
80107fed:	83 c4 10             	add    $0x10,%esp
80107ff0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107ff3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ff7:	75 16                	jne    8010800f <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffc:	c1 e8 16             	shr    $0x16,%eax
80107fff:	83 c0 01             	add    $0x1,%eax
80108002:	c1 e0 16             	shl    $0x16,%eax
80108005:	2d 00 10 00 00       	sub    $0x1000,%eax
8010800a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010800d:	eb 4e                	jmp    8010805d <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
8010800f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108012:	8b 00                	mov    (%eax),%eax
80108014:	83 e0 01             	and    $0x1,%eax
80108017:	85 c0                	test   %eax,%eax
80108019:	74 42                	je     8010805d <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
8010801b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010801e:	8b 00                	mov    (%eax),%eax
80108020:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108025:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108028:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010802c:	75 0d                	jne    8010803b <deallocuvm+0x8e>
        panic("kfree");
8010802e:	83 ec 0c             	sub    $0xc,%esp
80108031:	68 85 af 10 80       	push   $0x8010af85
80108036:	e8 8a 85 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
8010803b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010803e:	05 00 00 00 80       	add    $0x80000000,%eax
80108043:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108046:	83 ec 0c             	sub    $0xc,%esp
80108049:	ff 75 e8             	pushl  -0x18(%ebp)
8010804c:	e8 a3 a7 ff ff       	call   801027f4 <kfree>
80108051:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108054:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108057:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010805d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108067:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010806a:	0f 82 6c ff ff ff    	jb     80107fdc <deallocuvm+0x2f>
    }
  }
  return newsz;
80108070:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108073:	c9                   	leave  
80108074:	c3                   	ret    

80108075 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108075:	f3 0f 1e fb          	endbr32 
80108079:	55                   	push   %ebp
8010807a:	89 e5                	mov    %esp,%ebp
8010807c:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010807f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108083:	75 0d                	jne    80108092 <freevm+0x1d>
    panic("freevm: no pgdir");
80108085:	83 ec 0c             	sub    $0xc,%esp
80108088:	68 8b af 10 80       	push   $0x8010af8b
8010808d:	e8 33 85 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108092:	83 ec 04             	sub    $0x4,%esp
80108095:	6a 00                	push   $0x0
80108097:	68 00 00 00 80       	push   $0x80000000
8010809c:	ff 75 08             	pushl  0x8(%ebp)
8010809f:	e8 09 ff ff ff       	call   80107fad <deallocuvm>
801080a4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801080a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080ae:	eb 48                	jmp    801080f8 <freevm+0x83>
    if(pgdir[i] & PTE_P){
801080b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080ba:	8b 45 08             	mov    0x8(%ebp),%eax
801080bd:	01 d0                	add    %edx,%eax
801080bf:	8b 00                	mov    (%eax),%eax
801080c1:	83 e0 01             	and    $0x1,%eax
801080c4:	85 c0                	test   %eax,%eax
801080c6:	74 2c                	je     801080f4 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801080c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080d2:	8b 45 08             	mov    0x8(%ebp),%eax
801080d5:	01 d0                	add    %edx,%eax
801080d7:	8b 00                	mov    (%eax),%eax
801080d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080de:	05 00 00 00 80       	add    $0x80000000,%eax
801080e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801080e6:	83 ec 0c             	sub    $0xc,%esp
801080e9:	ff 75 f0             	pushl  -0x10(%ebp)
801080ec:	e8 03 a7 ff ff       	call   801027f4 <kfree>
801080f1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801080f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080f8:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801080ff:	76 af                	jbe    801080b0 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80108101:	83 ec 0c             	sub    $0xc,%esp
80108104:	ff 75 08             	pushl  0x8(%ebp)
80108107:	e8 e8 a6 ff ff       	call   801027f4 <kfree>
8010810c:	83 c4 10             	add    $0x10,%esp
}
8010810f:	90                   	nop
80108110:	c9                   	leave  
80108111:	c3                   	ret    

80108112 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108112:	f3 0f 1e fb          	endbr32 
80108116:	55                   	push   %ebp
80108117:	89 e5                	mov    %esp,%ebp
80108119:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010811c:	83 ec 04             	sub    $0x4,%esp
8010811f:	6a 00                	push   $0x0
80108121:	ff 75 0c             	pushl  0xc(%ebp)
80108124:	ff 75 08             	pushl  0x8(%ebp)
80108127:	e8 38 f8 ff ff       	call   80107964 <walkpgdir>
8010812c:	83 c4 10             	add    $0x10,%esp
8010812f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108132:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108136:	75 0d                	jne    80108145 <clearpteu+0x33>
    panic("clearpteu");
80108138:	83 ec 0c             	sub    $0xc,%esp
8010813b:	68 9c af 10 80       	push   $0x8010af9c
80108140:	e8 80 84 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
80108145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108148:	8b 00                	mov    (%eax),%eax
8010814a:	83 e0 fb             	and    $0xfffffffb,%eax
8010814d:	89 c2                	mov    %eax,%edx
8010814f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108152:	89 10                	mov    %edx,(%eax)
}
80108154:	90                   	nop
80108155:	c9                   	leave  
80108156:	c3                   	ret    

80108157 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108157:	f3 0f 1e fb          	endbr32 
8010815b:	55                   	push   %ebp
8010815c:	89 e5                	mov    %esp,%ebp
8010815e:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108161:	e8 2c f9 ff ff       	call   80107a92 <setupkvm>
80108166:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108169:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010816d:	75 0a                	jne    80108179 <copyuvm+0x22>
    return 0;
8010816f:	b8 00 00 00 00       	mov    $0x0,%eax
80108174:	e9 eb 00 00 00       	jmp    80108264 <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80108179:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108180:	e9 b7 00 00 00       	jmp    8010823c <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108188:	83 ec 04             	sub    $0x4,%esp
8010818b:	6a 00                	push   $0x0
8010818d:	50                   	push   %eax
8010818e:	ff 75 08             	pushl  0x8(%ebp)
80108191:	e8 ce f7 ff ff       	call   80107964 <walkpgdir>
80108196:	83 c4 10             	add    $0x10,%esp
80108199:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010819c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081a0:	75 0d                	jne    801081af <copyuvm+0x58>
      panic("copyuvm: pte should exist");
801081a2:	83 ec 0c             	sub    $0xc,%esp
801081a5:	68 a6 af 10 80       	push   $0x8010afa6
801081aa:	e8 16 84 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
801081af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081b2:	8b 00                	mov    (%eax),%eax
801081b4:	83 e0 01             	and    $0x1,%eax
801081b7:	85 c0                	test   %eax,%eax
801081b9:	75 0d                	jne    801081c8 <copyuvm+0x71>
      panic("copyuvm: page not present");
801081bb:	83 ec 0c             	sub    $0xc,%esp
801081be:	68 c0 af 10 80       	push   $0x8010afc0
801081c3:	e8 fd 83 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
801081c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081cb:	8b 00                	mov    (%eax),%eax
801081cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801081d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081d8:	8b 00                	mov    (%eax),%eax
801081da:	25 ff 0f 00 00       	and    $0xfff,%eax
801081df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801081e2:	e8 ab a6 ff ff       	call   80102892 <kalloc>
801081e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
801081ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801081ee:	74 5d                	je     8010824d <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801081f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081f3:	05 00 00 00 80       	add    $0x80000000,%eax
801081f8:	83 ec 04             	sub    $0x4,%esp
801081fb:	68 00 10 00 00       	push   $0x1000
80108200:	50                   	push   %eax
80108201:	ff 75 e0             	pushl  -0x20(%ebp)
80108204:	e8 6d ce ff ff       	call   80105076 <memmove>
80108209:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010820c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010820f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108212:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821b:	83 ec 0c             	sub    $0xc,%esp
8010821e:	52                   	push   %edx
8010821f:	51                   	push   %ecx
80108220:	68 00 10 00 00       	push   $0x1000
80108225:	50                   	push   %eax
80108226:	ff 75 f0             	pushl  -0x10(%ebp)
80108229:	e8 d0 f7 ff ff       	call   801079fe <mappages>
8010822e:	83 c4 20             	add    $0x20,%esp
80108231:	85 c0                	test   %eax,%eax
80108233:	78 1b                	js     80108250 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
80108235:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010823c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010823f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108242:	0f 82 3d ff ff ff    	jb     80108185 <copyuvm+0x2e>
      goto bad;
  }
  return d;
80108248:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010824b:	eb 17                	jmp    80108264 <copyuvm+0x10d>
      goto bad;
8010824d:	90                   	nop
8010824e:	eb 01                	jmp    80108251 <copyuvm+0xfa>
      goto bad;
80108250:	90                   	nop

bad:
  freevm(d);
80108251:	83 ec 0c             	sub    $0xc,%esp
80108254:	ff 75 f0             	pushl  -0x10(%ebp)
80108257:	e8 19 fe ff ff       	call   80108075 <freevm>
8010825c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010825f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108264:	c9                   	leave  
80108265:	c3                   	ret    

80108266 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108266:	f3 0f 1e fb          	endbr32 
8010826a:	55                   	push   %ebp
8010826b:	89 e5                	mov    %esp,%ebp
8010826d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108270:	83 ec 04             	sub    $0x4,%esp
80108273:	6a 00                	push   $0x0
80108275:	ff 75 0c             	pushl  0xc(%ebp)
80108278:	ff 75 08             	pushl  0x8(%ebp)
8010827b:	e8 e4 f6 ff ff       	call   80107964 <walkpgdir>
80108280:	83 c4 10             	add    $0x10,%esp
80108283:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108289:	8b 00                	mov    (%eax),%eax
8010828b:	83 e0 01             	and    $0x1,%eax
8010828e:	85 c0                	test   %eax,%eax
80108290:	75 07                	jne    80108299 <uva2ka+0x33>
    return 0;
80108292:	b8 00 00 00 00       	mov    $0x0,%eax
80108297:	eb 22                	jmp    801082bb <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80108299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829c:	8b 00                	mov    (%eax),%eax
8010829e:	83 e0 04             	and    $0x4,%eax
801082a1:	85 c0                	test   %eax,%eax
801082a3:	75 07                	jne    801082ac <uva2ka+0x46>
    return 0;
801082a5:	b8 00 00 00 00       	mov    $0x0,%eax
801082aa:	eb 0f                	jmp    801082bb <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
801082ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082af:	8b 00                	mov    (%eax),%eax
801082b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082b6:	05 00 00 00 80       	add    $0x80000000,%eax
}
801082bb:	c9                   	leave  
801082bc:	c3                   	ret    

801082bd <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801082bd:	f3 0f 1e fb          	endbr32 
801082c1:	55                   	push   %ebp
801082c2:	89 e5                	mov    %esp,%ebp
801082c4:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801082c7:	8b 45 10             	mov    0x10(%ebp),%eax
801082ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801082cd:	eb 7f                	jmp    8010834e <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801082cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801082d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801082da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082dd:	83 ec 08             	sub    $0x8,%esp
801082e0:	50                   	push   %eax
801082e1:	ff 75 08             	pushl  0x8(%ebp)
801082e4:	e8 7d ff ff ff       	call   80108266 <uva2ka>
801082e9:	83 c4 10             	add    $0x10,%esp
801082ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801082ef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801082f3:	75 07                	jne    801082fc <copyout+0x3f>
      return -1;
801082f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082fa:	eb 61                	jmp    8010835d <copyout+0xa0>
    n = PGSIZE - (va - va0);
801082fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082ff:	2b 45 0c             	sub    0xc(%ebp),%eax
80108302:	05 00 10 00 00       	add    $0x1000,%eax
80108307:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010830a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010830d:	3b 45 14             	cmp    0x14(%ebp),%eax
80108310:	76 06                	jbe    80108318 <copyout+0x5b>
      n = len;
80108312:	8b 45 14             	mov    0x14(%ebp),%eax
80108315:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108318:	8b 45 0c             	mov    0xc(%ebp),%eax
8010831b:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010831e:	89 c2                	mov    %eax,%edx
80108320:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108323:	01 d0                	add    %edx,%eax
80108325:	83 ec 04             	sub    $0x4,%esp
80108328:	ff 75 f0             	pushl  -0x10(%ebp)
8010832b:	ff 75 f4             	pushl  -0xc(%ebp)
8010832e:	50                   	push   %eax
8010832f:	e8 42 cd ff ff       	call   80105076 <memmove>
80108334:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010833a:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010833d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108340:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108343:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108346:	05 00 10 00 00       	add    $0x1000,%eax
8010834b:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010834e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108352:	0f 85 77 ff ff ff    	jne    801082cf <copyout+0x12>
  }
  return 0;
80108358:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010835d:	c9                   	leave  
8010835e:	c3                   	ret    

8010835f <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010835f:	f3 0f 1e fb          	endbr32 
80108363:	55                   	push   %ebp
80108364:	89 e5                	mov    %esp,%ebp
80108366:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108369:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108370:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108373:	8b 40 08             	mov    0x8(%eax),%eax
80108376:	05 00 00 00 80       	add    $0x80000000,%eax
8010837b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010837e:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108388:	8b 40 24             	mov    0x24(%eax),%eax
8010838b:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80108390:	c7 05 80 81 19 80 00 	movl   $0x0,0x80198180
80108397:	00 00 00 

  while(i<madt->len){
8010839a:	90                   	nop
8010839b:	e9 be 00 00 00       	jmp    8010845e <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
801083a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083a6:	01 d0                	add    %edx,%eax
801083a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801083ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083ae:	0f b6 00             	movzbl (%eax),%eax
801083b1:	0f b6 c0             	movzbl %al,%eax
801083b4:	83 f8 05             	cmp    $0x5,%eax
801083b7:	0f 87 a1 00 00 00    	ja     8010845e <mpinit_uefi+0xff>
801083bd:	8b 04 85 dc af 10 80 	mov    -0x7fef5024(,%eax,4),%eax
801083c4:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801083c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801083cd:	a1 80 81 19 80       	mov    0x80198180,%eax
801083d2:	83 f8 03             	cmp    $0x3,%eax
801083d5:	7f 28                	jg     801083ff <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801083d7:	8b 15 80 81 19 80    	mov    0x80198180,%edx
801083dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801083e0:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801083e4:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
801083ea:	81 c2 c0 7e 19 80    	add    $0x80197ec0,%edx
801083f0:	88 02                	mov    %al,(%edx)
          ncpu++;
801083f2:	a1 80 81 19 80       	mov    0x80198180,%eax
801083f7:	83 c0 01             	add    $0x1,%eax
801083fa:	a3 80 81 19 80       	mov    %eax,0x80198180
        }
        i += lapic_entry->record_len;
801083ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108402:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108406:	0f b6 c0             	movzbl %al,%eax
80108409:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010840c:	eb 50                	jmp    8010845e <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
8010840e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108411:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108417:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010841b:	a2 a0 7e 19 80       	mov    %al,0x80197ea0
        i += ioapic->record_len;
80108420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108423:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108427:	0f b6 c0             	movzbl %al,%eax
8010842a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010842d:	eb 2f                	jmp    8010845e <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
8010842f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108432:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108435:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108438:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010843c:	0f b6 c0             	movzbl %al,%eax
8010843f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108442:	eb 1a                	jmp    8010845e <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108444:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108447:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010844a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010844d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108451:	0f b6 c0             	movzbl %al,%eax
80108454:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108457:	eb 05                	jmp    8010845e <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
80108459:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010845d:	90                   	nop
  while(i<madt->len){
8010845e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108461:	8b 40 04             	mov    0x4(%eax),%eax
80108464:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108467:	0f 82 33 ff ff ff    	jb     801083a0 <mpinit_uefi+0x41>
    }
  }

}
8010846d:	90                   	nop
8010846e:	90                   	nop
8010846f:	c9                   	leave  
80108470:	c3                   	ret    

80108471 <inb>:
{
80108471:	55                   	push   %ebp
80108472:	89 e5                	mov    %esp,%ebp
80108474:	83 ec 14             	sub    $0x14,%esp
80108477:	8b 45 08             	mov    0x8(%ebp),%eax
8010847a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010847e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108482:	89 c2                	mov    %eax,%edx
80108484:	ec                   	in     (%dx),%al
80108485:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108488:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010848c:	c9                   	leave  
8010848d:	c3                   	ret    

8010848e <outb>:
{
8010848e:	55                   	push   %ebp
8010848f:	89 e5                	mov    %esp,%ebp
80108491:	83 ec 08             	sub    $0x8,%esp
80108494:	8b 45 08             	mov    0x8(%ebp),%eax
80108497:	8b 55 0c             	mov    0xc(%ebp),%edx
8010849a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010849e:	89 d0                	mov    %edx,%eax
801084a0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801084a3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801084a7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801084ab:	ee                   	out    %al,(%dx)
}
801084ac:	90                   	nop
801084ad:	c9                   	leave  
801084ae:	c3                   	ret    

801084af <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801084af:	f3 0f 1e fb          	endbr32 
801084b3:	55                   	push   %ebp
801084b4:	89 e5                	mov    %esp,%ebp
801084b6:	83 ec 28             	sub    $0x28,%esp
801084b9:	8b 45 08             	mov    0x8(%ebp),%eax
801084bc:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801084bf:	6a 00                	push   $0x0
801084c1:	68 fa 03 00 00       	push   $0x3fa
801084c6:	e8 c3 ff ff ff       	call   8010848e <outb>
801084cb:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801084ce:	68 80 00 00 00       	push   $0x80
801084d3:	68 fb 03 00 00       	push   $0x3fb
801084d8:	e8 b1 ff ff ff       	call   8010848e <outb>
801084dd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801084e0:	6a 0c                	push   $0xc
801084e2:	68 f8 03 00 00       	push   $0x3f8
801084e7:	e8 a2 ff ff ff       	call   8010848e <outb>
801084ec:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801084ef:	6a 00                	push   $0x0
801084f1:	68 f9 03 00 00       	push   $0x3f9
801084f6:	e8 93 ff ff ff       	call   8010848e <outb>
801084fb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801084fe:	6a 03                	push   $0x3
80108500:	68 fb 03 00 00       	push   $0x3fb
80108505:	e8 84 ff ff ff       	call   8010848e <outb>
8010850a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010850d:	6a 00                	push   $0x0
8010850f:	68 fc 03 00 00       	push   $0x3fc
80108514:	e8 75 ff ff ff       	call   8010848e <outb>
80108519:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010851c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108523:	eb 11                	jmp    80108536 <uart_debug+0x87>
80108525:	83 ec 0c             	sub    $0xc,%esp
80108528:	6a 0a                	push   $0xa
8010852a:	e8 15 a7 ff ff       	call   80102c44 <microdelay>
8010852f:	83 c4 10             	add    $0x10,%esp
80108532:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108536:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010853a:	7f 1a                	jg     80108556 <uart_debug+0xa7>
8010853c:	83 ec 0c             	sub    $0xc,%esp
8010853f:	68 fd 03 00 00       	push   $0x3fd
80108544:	e8 28 ff ff ff       	call   80108471 <inb>
80108549:	83 c4 10             	add    $0x10,%esp
8010854c:	0f b6 c0             	movzbl %al,%eax
8010854f:	83 e0 20             	and    $0x20,%eax
80108552:	85 c0                	test   %eax,%eax
80108554:	74 cf                	je     80108525 <uart_debug+0x76>
  outb(COM1+0, p);
80108556:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010855a:	0f b6 c0             	movzbl %al,%eax
8010855d:	83 ec 08             	sub    $0x8,%esp
80108560:	50                   	push   %eax
80108561:	68 f8 03 00 00       	push   $0x3f8
80108566:	e8 23 ff ff ff       	call   8010848e <outb>
8010856b:	83 c4 10             	add    $0x10,%esp
}
8010856e:	90                   	nop
8010856f:	c9                   	leave  
80108570:	c3                   	ret    

80108571 <uart_debugs>:

void uart_debugs(char *p){
80108571:	f3 0f 1e fb          	endbr32 
80108575:	55                   	push   %ebp
80108576:	89 e5                	mov    %esp,%ebp
80108578:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010857b:	eb 1b                	jmp    80108598 <uart_debugs+0x27>
    uart_debug(*p++);
8010857d:	8b 45 08             	mov    0x8(%ebp),%eax
80108580:	8d 50 01             	lea    0x1(%eax),%edx
80108583:	89 55 08             	mov    %edx,0x8(%ebp)
80108586:	0f b6 00             	movzbl (%eax),%eax
80108589:	0f be c0             	movsbl %al,%eax
8010858c:	83 ec 0c             	sub    $0xc,%esp
8010858f:	50                   	push   %eax
80108590:	e8 1a ff ff ff       	call   801084af <uart_debug>
80108595:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108598:	8b 45 08             	mov    0x8(%ebp),%eax
8010859b:	0f b6 00             	movzbl (%eax),%eax
8010859e:	84 c0                	test   %al,%al
801085a0:	75 db                	jne    8010857d <uart_debugs+0xc>
  }
}
801085a2:	90                   	nop
801085a3:	90                   	nop
801085a4:	c9                   	leave  
801085a5:	c3                   	ret    

801085a6 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801085a6:	f3 0f 1e fb          	endbr32 
801085aa:	55                   	push   %ebp
801085ab:	89 e5                	mov    %esp,%ebp
801085ad:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801085b0:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801085b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801085ba:	8b 50 14             	mov    0x14(%eax),%edx
801085bd:	8b 40 10             	mov    0x10(%eax),%eax
801085c0:	a3 84 81 19 80       	mov    %eax,0x80198184
  gpu.vram_size = boot_param->graphic_config.frame_size;
801085c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801085c8:	8b 50 1c             	mov    0x1c(%eax),%edx
801085cb:	8b 40 18             	mov    0x18(%eax),%eax
801085ce:	a3 8c 81 19 80       	mov    %eax,0x8019818c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801085d3:	a1 8c 81 19 80       	mov    0x8019818c,%eax
801085d8:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801085dd:	29 c2                	sub    %eax,%edx
801085df:	89 d0                	mov    %edx,%eax
801085e1:	a3 88 81 19 80       	mov    %eax,0x80198188
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801085e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801085e9:	8b 50 24             	mov    0x24(%eax),%edx
801085ec:	8b 40 20             	mov    0x20(%eax),%eax
801085ef:	a3 90 81 19 80       	mov    %eax,0x80198190
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801085f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801085f7:	8b 50 2c             	mov    0x2c(%eax),%edx
801085fa:	8b 40 28             	mov    0x28(%eax),%eax
801085fd:	a3 94 81 19 80       	mov    %eax,0x80198194
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108602:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108605:	8b 50 34             	mov    0x34(%eax),%edx
80108608:	8b 40 30             	mov    0x30(%eax),%eax
8010860b:	a3 98 81 19 80       	mov    %eax,0x80198198
}
80108610:	90                   	nop
80108611:	c9                   	leave  
80108612:	c3                   	ret    

80108613 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108613:	f3 0f 1e fb          	endbr32 
80108617:	55                   	push   %ebp
80108618:	89 e5                	mov    %esp,%ebp
8010861a:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
8010861d:	8b 15 98 81 19 80    	mov    0x80198198,%edx
80108623:	8b 45 0c             	mov    0xc(%ebp),%eax
80108626:	0f af d0             	imul   %eax,%edx
80108629:	8b 45 08             	mov    0x8(%ebp),%eax
8010862c:	01 d0                	add    %edx,%eax
8010862e:	c1 e0 02             	shl    $0x2,%eax
80108631:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108634:	8b 15 88 81 19 80    	mov    0x80198188,%edx
8010863a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010863d:	01 d0                	add    %edx,%eax
8010863f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108642:	8b 45 10             	mov    0x10(%ebp),%eax
80108645:	0f b6 10             	movzbl (%eax),%edx
80108648:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010864b:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010864d:	8b 45 10             	mov    0x10(%ebp),%eax
80108650:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108654:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108657:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010865a:	8b 45 10             	mov    0x10(%ebp),%eax
8010865d:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108661:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108664:	88 50 02             	mov    %dl,0x2(%eax)
}
80108667:	90                   	nop
80108668:	c9                   	leave  
80108669:	c3                   	ret    

8010866a <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010866a:	f3 0f 1e fb          	endbr32 
8010866e:	55                   	push   %ebp
8010866f:	89 e5                	mov    %esp,%ebp
80108671:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108674:	8b 15 98 81 19 80    	mov    0x80198198,%edx
8010867a:	8b 45 08             	mov    0x8(%ebp),%eax
8010867d:	0f af c2             	imul   %edx,%eax
80108680:	c1 e0 02             	shl    $0x2,%eax
80108683:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108686:	8b 15 8c 81 19 80    	mov    0x8019818c,%edx
8010868c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868f:	29 c2                	sub    %eax,%edx
80108691:	89 d0                	mov    %edx,%eax
80108693:	8b 0d 88 81 19 80    	mov    0x80198188,%ecx
80108699:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010869c:	01 ca                	add    %ecx,%edx
8010869e:	89 d1                	mov    %edx,%ecx
801086a0:	8b 15 88 81 19 80    	mov    0x80198188,%edx
801086a6:	83 ec 04             	sub    $0x4,%esp
801086a9:	50                   	push   %eax
801086aa:	51                   	push   %ecx
801086ab:	52                   	push   %edx
801086ac:	e8 c5 c9 ff ff       	call   80105076 <memmove>
801086b1:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801086b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b7:	8b 0d 88 81 19 80    	mov    0x80198188,%ecx
801086bd:	8b 15 8c 81 19 80    	mov    0x8019818c,%edx
801086c3:	01 d1                	add    %edx,%ecx
801086c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086c8:	29 d1                	sub    %edx,%ecx
801086ca:	89 ca                	mov    %ecx,%edx
801086cc:	83 ec 04             	sub    $0x4,%esp
801086cf:	50                   	push   %eax
801086d0:	6a 00                	push   $0x0
801086d2:	52                   	push   %edx
801086d3:	e8 d7 c8 ff ff       	call   80104faf <memset>
801086d8:	83 c4 10             	add    $0x10,%esp
}
801086db:	90                   	nop
801086dc:	c9                   	leave  
801086dd:	c3                   	ret    

801086de <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801086de:	f3 0f 1e fb          	endbr32 
801086e2:	55                   	push   %ebp
801086e3:	89 e5                	mov    %esp,%ebp
801086e5:	53                   	push   %ebx
801086e6:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801086e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086f0:	e9 b1 00 00 00       	jmp    801087a6 <font_render+0xc8>
    for(int j=14;j>-1;j--){
801086f5:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801086fc:	e9 97 00 00 00       	jmp    80108798 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108701:	8b 45 10             	mov    0x10(%ebp),%eax
80108704:	83 e8 20             	sub    $0x20,%eax
80108707:	6b d0 1e             	imul   $0x1e,%eax,%edx
8010870a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870d:	01 d0                	add    %edx,%eax
8010870f:	0f b7 84 00 00 b0 10 	movzwl -0x7fef5000(%eax,%eax,1),%eax
80108716:	80 
80108717:	0f b7 d0             	movzwl %ax,%edx
8010871a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010871d:	bb 01 00 00 00       	mov    $0x1,%ebx
80108722:	89 c1                	mov    %eax,%ecx
80108724:	d3 e3                	shl    %cl,%ebx
80108726:	89 d8                	mov    %ebx,%eax
80108728:	21 d0                	and    %edx,%eax
8010872a:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010872d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108730:	ba 01 00 00 00       	mov    $0x1,%edx
80108735:	89 c1                	mov    %eax,%ecx
80108737:	d3 e2                	shl    %cl,%edx
80108739:	89 d0                	mov    %edx,%eax
8010873b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010873e:	75 2b                	jne    8010876b <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108740:	8b 55 0c             	mov    0xc(%ebp),%edx
80108743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108746:	01 c2                	add    %eax,%edx
80108748:	b8 0e 00 00 00       	mov    $0xe,%eax
8010874d:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108750:	89 c1                	mov    %eax,%ecx
80108752:	8b 45 08             	mov    0x8(%ebp),%eax
80108755:	01 c8                	add    %ecx,%eax
80108757:	83 ec 04             	sub    $0x4,%esp
8010875a:	68 00 f5 10 80       	push   $0x8010f500
8010875f:	52                   	push   %edx
80108760:	50                   	push   %eax
80108761:	e8 ad fe ff ff       	call   80108613 <graphic_draw_pixel>
80108766:	83 c4 10             	add    $0x10,%esp
80108769:	eb 29                	jmp    80108794 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010876b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010876e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108771:	01 c2                	add    %eax,%edx
80108773:	b8 0e 00 00 00       	mov    $0xe,%eax
80108778:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010877b:	89 c1                	mov    %eax,%ecx
8010877d:	8b 45 08             	mov    0x8(%ebp),%eax
80108780:	01 c8                	add    %ecx,%eax
80108782:	83 ec 04             	sub    $0x4,%esp
80108785:	68 64 d0 18 80       	push   $0x8018d064
8010878a:	52                   	push   %edx
8010878b:	50                   	push   %eax
8010878c:	e8 82 fe ff ff       	call   80108613 <graphic_draw_pixel>
80108791:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108794:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108798:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010879c:	0f 89 5f ff ff ff    	jns    80108701 <font_render+0x23>
  for(int i=0;i<30;i++){
801087a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087a6:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801087aa:	0f 8e 45 ff ff ff    	jle    801086f5 <font_render+0x17>
      }
    }
  }
}
801087b0:	90                   	nop
801087b1:	90                   	nop
801087b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801087b5:	c9                   	leave  
801087b6:	c3                   	ret    

801087b7 <font_render_string>:

void font_render_string(char *string,int row){
801087b7:	f3 0f 1e fb          	endbr32 
801087bb:	55                   	push   %ebp
801087bc:	89 e5                	mov    %esp,%ebp
801087be:	53                   	push   %ebx
801087bf:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801087c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801087c9:	eb 33                	jmp    801087fe <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
801087cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801087ce:	8b 45 08             	mov    0x8(%ebp),%eax
801087d1:	01 d0                	add    %edx,%eax
801087d3:	0f b6 00             	movzbl (%eax),%eax
801087d6:	0f be d8             	movsbl %al,%ebx
801087d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801087dc:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801087df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801087e2:	89 d0                	mov    %edx,%eax
801087e4:	c1 e0 04             	shl    $0x4,%eax
801087e7:	29 d0                	sub    %edx,%eax
801087e9:	83 c0 02             	add    $0x2,%eax
801087ec:	83 ec 04             	sub    $0x4,%esp
801087ef:	53                   	push   %ebx
801087f0:	51                   	push   %ecx
801087f1:	50                   	push   %eax
801087f2:	e8 e7 fe ff ff       	call   801086de <font_render>
801087f7:	83 c4 10             	add    $0x10,%esp
    i++;
801087fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801087fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108801:	8b 45 08             	mov    0x8(%ebp),%eax
80108804:	01 d0                	add    %edx,%eax
80108806:	0f b6 00             	movzbl (%eax),%eax
80108809:	84 c0                	test   %al,%al
8010880b:	74 06                	je     80108813 <font_render_string+0x5c>
8010880d:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108811:	7e b8                	jle    801087cb <font_render_string+0x14>
  }
}
80108813:	90                   	nop
80108814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108817:	c9                   	leave  
80108818:	c3                   	ret    

80108819 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108819:	f3 0f 1e fb          	endbr32 
8010881d:	55                   	push   %ebp
8010881e:	89 e5                	mov    %esp,%ebp
80108820:	53                   	push   %ebx
80108821:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108824:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010882b:	eb 6b                	jmp    80108898 <pci_init+0x7f>
    for(int j=0;j<32;j++){
8010882d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108834:	eb 58                	jmp    8010888e <pci_init+0x75>
      for(int k=0;k<8;k++){
80108836:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010883d:	eb 45                	jmp    80108884 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
8010883f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108842:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108848:	83 ec 0c             	sub    $0xc,%esp
8010884b:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010884e:	53                   	push   %ebx
8010884f:	6a 00                	push   $0x0
80108851:	51                   	push   %ecx
80108852:	52                   	push   %edx
80108853:	50                   	push   %eax
80108854:	e8 c0 00 00 00       	call   80108919 <pci_access_config>
80108859:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010885c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010885f:	0f b7 c0             	movzwl %ax,%eax
80108862:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108867:	74 17                	je     80108880 <pci_init+0x67>
        pci_init_device(i,j,k);
80108869:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010886c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010886f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108872:	83 ec 04             	sub    $0x4,%esp
80108875:	51                   	push   %ecx
80108876:	52                   	push   %edx
80108877:	50                   	push   %eax
80108878:	e8 4f 01 00 00       	call   801089cc <pci_init_device>
8010887d:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108880:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108884:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108888:	7e b5                	jle    8010883f <pci_init+0x26>
    for(int j=0;j<32;j++){
8010888a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010888e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108892:	7e a2                	jle    80108836 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108894:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108898:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010889f:	7e 8c                	jle    8010882d <pci_init+0x14>
      }
      }
    }
  }
}
801088a1:	90                   	nop
801088a2:	90                   	nop
801088a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088a6:	c9                   	leave  
801088a7:	c3                   	ret    

801088a8 <pci_write_config>:

void pci_write_config(uint config){
801088a8:	f3 0f 1e fb          	endbr32 
801088ac:	55                   	push   %ebp
801088ad:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801088af:	8b 45 08             	mov    0x8(%ebp),%eax
801088b2:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801088b7:	89 c0                	mov    %eax,%eax
801088b9:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801088ba:	90                   	nop
801088bb:	5d                   	pop    %ebp
801088bc:	c3                   	ret    

801088bd <pci_write_data>:

void pci_write_data(uint config){
801088bd:	f3 0f 1e fb          	endbr32 
801088c1:	55                   	push   %ebp
801088c2:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801088c4:	8b 45 08             	mov    0x8(%ebp),%eax
801088c7:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801088cc:	89 c0                	mov    %eax,%eax
801088ce:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801088cf:	90                   	nop
801088d0:	5d                   	pop    %ebp
801088d1:	c3                   	ret    

801088d2 <pci_read_config>:
uint pci_read_config(){
801088d2:	f3 0f 1e fb          	endbr32 
801088d6:	55                   	push   %ebp
801088d7:	89 e5                	mov    %esp,%ebp
801088d9:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801088dc:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801088e1:	ed                   	in     (%dx),%eax
801088e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801088e5:	83 ec 0c             	sub    $0xc,%esp
801088e8:	68 c8 00 00 00       	push   $0xc8
801088ed:	e8 52 a3 ff ff       	call   80102c44 <microdelay>
801088f2:	83 c4 10             	add    $0x10,%esp
  return data;
801088f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801088f8:	c9                   	leave  
801088f9:	c3                   	ret    

801088fa <pci_test>:


void pci_test(){
801088fa:	f3 0f 1e fb          	endbr32 
801088fe:	55                   	push   %ebp
801088ff:	89 e5                	mov    %esp,%ebp
80108901:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108904:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010890b:	ff 75 fc             	pushl  -0x4(%ebp)
8010890e:	e8 95 ff ff ff       	call   801088a8 <pci_write_config>
80108913:	83 c4 04             	add    $0x4,%esp
}
80108916:	90                   	nop
80108917:	c9                   	leave  
80108918:	c3                   	ret    

80108919 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108919:	f3 0f 1e fb          	endbr32 
8010891d:	55                   	push   %ebp
8010891e:	89 e5                	mov    %esp,%ebp
80108920:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108923:	8b 45 08             	mov    0x8(%ebp),%eax
80108926:	c1 e0 10             	shl    $0x10,%eax
80108929:	25 00 00 ff 00       	and    $0xff0000,%eax
8010892e:	89 c2                	mov    %eax,%edx
80108930:	8b 45 0c             	mov    0xc(%ebp),%eax
80108933:	c1 e0 0b             	shl    $0xb,%eax
80108936:	0f b7 c0             	movzwl %ax,%eax
80108939:	09 c2                	or     %eax,%edx
8010893b:	8b 45 10             	mov    0x10(%ebp),%eax
8010893e:	c1 e0 08             	shl    $0x8,%eax
80108941:	25 00 07 00 00       	and    $0x700,%eax
80108946:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108948:	8b 45 14             	mov    0x14(%ebp),%eax
8010894b:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108950:	09 d0                	or     %edx,%eax
80108952:	0d 00 00 00 80       	or     $0x80000000,%eax
80108957:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
8010895a:	ff 75 f4             	pushl  -0xc(%ebp)
8010895d:	e8 46 ff ff ff       	call   801088a8 <pci_write_config>
80108962:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108965:	e8 68 ff ff ff       	call   801088d2 <pci_read_config>
8010896a:	8b 55 18             	mov    0x18(%ebp),%edx
8010896d:	89 02                	mov    %eax,(%edx)
}
8010896f:	90                   	nop
80108970:	c9                   	leave  
80108971:	c3                   	ret    

80108972 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108972:	f3 0f 1e fb          	endbr32 
80108976:	55                   	push   %ebp
80108977:	89 e5                	mov    %esp,%ebp
80108979:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010897c:	8b 45 08             	mov    0x8(%ebp),%eax
8010897f:	c1 e0 10             	shl    $0x10,%eax
80108982:	25 00 00 ff 00       	and    $0xff0000,%eax
80108987:	89 c2                	mov    %eax,%edx
80108989:	8b 45 0c             	mov    0xc(%ebp),%eax
8010898c:	c1 e0 0b             	shl    $0xb,%eax
8010898f:	0f b7 c0             	movzwl %ax,%eax
80108992:	09 c2                	or     %eax,%edx
80108994:	8b 45 10             	mov    0x10(%ebp),%eax
80108997:	c1 e0 08             	shl    $0x8,%eax
8010899a:	25 00 07 00 00       	and    $0x700,%eax
8010899f:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801089a1:	8b 45 14             	mov    0x14(%ebp),%eax
801089a4:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801089a9:	09 d0                	or     %edx,%eax
801089ab:	0d 00 00 00 80       	or     $0x80000000,%eax
801089b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801089b3:	ff 75 fc             	pushl  -0x4(%ebp)
801089b6:	e8 ed fe ff ff       	call   801088a8 <pci_write_config>
801089bb:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801089be:	ff 75 18             	pushl  0x18(%ebp)
801089c1:	e8 f7 fe ff ff       	call   801088bd <pci_write_data>
801089c6:	83 c4 04             	add    $0x4,%esp
}
801089c9:	90                   	nop
801089ca:	c9                   	leave  
801089cb:	c3                   	ret    

801089cc <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801089cc:	f3 0f 1e fb          	endbr32 
801089d0:	55                   	push   %ebp
801089d1:	89 e5                	mov    %esp,%ebp
801089d3:	53                   	push   %ebx
801089d4:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801089d7:	8b 45 08             	mov    0x8(%ebp),%eax
801089da:	a2 9c 81 19 80       	mov    %al,0x8019819c
  dev.device_num = device_num;
801089df:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e2:	a2 9d 81 19 80       	mov    %al,0x8019819d
  dev.function_num = function_num;
801089e7:	8b 45 10             	mov    0x10(%ebp),%eax
801089ea:	a2 9e 81 19 80       	mov    %al,0x8019819e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801089ef:	ff 75 10             	pushl  0x10(%ebp)
801089f2:	ff 75 0c             	pushl  0xc(%ebp)
801089f5:	ff 75 08             	pushl  0x8(%ebp)
801089f8:	68 44 c6 10 80       	push   $0x8010c644
801089fd:	e8 0a 7a ff ff       	call   8010040c <cprintf>
80108a02:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108a05:	83 ec 0c             	sub    $0xc,%esp
80108a08:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a0b:	50                   	push   %eax
80108a0c:	6a 00                	push   $0x0
80108a0e:	ff 75 10             	pushl  0x10(%ebp)
80108a11:	ff 75 0c             	pushl  0xc(%ebp)
80108a14:	ff 75 08             	pushl  0x8(%ebp)
80108a17:	e8 fd fe ff ff       	call   80108919 <pci_access_config>
80108a1c:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108a1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a22:	c1 e8 10             	shr    $0x10,%eax
80108a25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108a28:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a2b:	25 ff ff 00 00       	and    $0xffff,%eax
80108a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a36:	a3 a0 81 19 80       	mov    %eax,0x801981a0
  dev.vendor_id = vendor_id;
80108a3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a3e:	a3 a4 81 19 80       	mov    %eax,0x801981a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108a43:	83 ec 04             	sub    $0x4,%esp
80108a46:	ff 75 f0             	pushl  -0x10(%ebp)
80108a49:	ff 75 f4             	pushl  -0xc(%ebp)
80108a4c:	68 78 c6 10 80       	push   $0x8010c678
80108a51:	e8 b6 79 ff ff       	call   8010040c <cprintf>
80108a56:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108a59:	83 ec 0c             	sub    $0xc,%esp
80108a5c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108a5f:	50                   	push   %eax
80108a60:	6a 08                	push   $0x8
80108a62:	ff 75 10             	pushl  0x10(%ebp)
80108a65:	ff 75 0c             	pushl  0xc(%ebp)
80108a68:	ff 75 08             	pushl  0x8(%ebp)
80108a6b:	e8 a9 fe ff ff       	call   80108919 <pci_access_config>
80108a70:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108a73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a76:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108a79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a7c:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108a7f:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108a82:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a85:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108a88:	0f b6 c0             	movzbl %al,%eax
80108a8b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108a8e:	c1 eb 18             	shr    $0x18,%ebx
80108a91:	83 ec 0c             	sub    $0xc,%esp
80108a94:	51                   	push   %ecx
80108a95:	52                   	push   %edx
80108a96:	50                   	push   %eax
80108a97:	53                   	push   %ebx
80108a98:	68 9c c6 10 80       	push   $0x8010c69c
80108a9d:	e8 6a 79 ff ff       	call   8010040c <cprintf>
80108aa2:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108aa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aa8:	c1 e8 18             	shr    $0x18,%eax
80108aab:	a2 a8 81 19 80       	mov    %al,0x801981a8
  dev.sub_class = (data>>16)&0xFF;
80108ab0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ab3:	c1 e8 10             	shr    $0x10,%eax
80108ab6:	a2 a9 81 19 80       	mov    %al,0x801981a9
  dev.interface = (data>>8)&0xFF;
80108abb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108abe:	c1 e8 08             	shr    $0x8,%eax
80108ac1:	a2 aa 81 19 80       	mov    %al,0x801981aa
  dev.revision_id = data&0xFF;
80108ac6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ac9:	a2 ab 81 19 80       	mov    %al,0x801981ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108ace:	83 ec 0c             	sub    $0xc,%esp
80108ad1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108ad4:	50                   	push   %eax
80108ad5:	6a 10                	push   $0x10
80108ad7:	ff 75 10             	pushl  0x10(%ebp)
80108ada:	ff 75 0c             	pushl  0xc(%ebp)
80108add:	ff 75 08             	pushl  0x8(%ebp)
80108ae0:	e8 34 fe ff ff       	call   80108919 <pci_access_config>
80108ae5:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108ae8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aeb:	a3 ac 81 19 80       	mov    %eax,0x801981ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108af0:	83 ec 0c             	sub    $0xc,%esp
80108af3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108af6:	50                   	push   %eax
80108af7:	6a 14                	push   $0x14
80108af9:	ff 75 10             	pushl  0x10(%ebp)
80108afc:	ff 75 0c             	pushl  0xc(%ebp)
80108aff:	ff 75 08             	pushl  0x8(%ebp)
80108b02:	e8 12 fe ff ff       	call   80108919 <pci_access_config>
80108b07:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108b0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b0d:	a3 b0 81 19 80       	mov    %eax,0x801981b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108b12:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108b19:	75 5a                	jne    80108b75 <pci_init_device+0x1a9>
80108b1b:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108b22:	75 51                	jne    80108b75 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108b24:	83 ec 0c             	sub    $0xc,%esp
80108b27:	68 e1 c6 10 80       	push   $0x8010c6e1
80108b2c:	e8 db 78 ff ff       	call   8010040c <cprintf>
80108b31:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108b34:	83 ec 0c             	sub    $0xc,%esp
80108b37:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b3a:	50                   	push   %eax
80108b3b:	68 f0 00 00 00       	push   $0xf0
80108b40:	ff 75 10             	pushl  0x10(%ebp)
80108b43:	ff 75 0c             	pushl  0xc(%ebp)
80108b46:	ff 75 08             	pushl  0x8(%ebp)
80108b49:	e8 cb fd ff ff       	call   80108919 <pci_access_config>
80108b4e:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108b51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b54:	83 ec 08             	sub    $0x8,%esp
80108b57:	50                   	push   %eax
80108b58:	68 fb c6 10 80       	push   $0x8010c6fb
80108b5d:	e8 aa 78 ff ff       	call   8010040c <cprintf>
80108b62:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108b65:	83 ec 0c             	sub    $0xc,%esp
80108b68:	68 9c 81 19 80       	push   $0x8019819c
80108b6d:	e8 09 00 00 00       	call   80108b7b <i8254_init>
80108b72:	83 c4 10             	add    $0x10,%esp
  }
}
80108b75:	90                   	nop
80108b76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b79:	c9                   	leave  
80108b7a:	c3                   	ret    

80108b7b <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108b7b:	f3 0f 1e fb          	endbr32 
80108b7f:	55                   	push   %ebp
80108b80:	89 e5                	mov    %esp,%ebp
80108b82:	53                   	push   %ebx
80108b83:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108b86:	8b 45 08             	mov    0x8(%ebp),%eax
80108b89:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108b8d:	0f b6 c8             	movzbl %al,%ecx
80108b90:	8b 45 08             	mov    0x8(%ebp),%eax
80108b93:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108b97:	0f b6 d0             	movzbl %al,%edx
80108b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80108b9d:	0f b6 00             	movzbl (%eax),%eax
80108ba0:	0f b6 c0             	movzbl %al,%eax
80108ba3:	83 ec 0c             	sub    $0xc,%esp
80108ba6:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108ba9:	53                   	push   %ebx
80108baa:	6a 04                	push   $0x4
80108bac:	51                   	push   %ecx
80108bad:	52                   	push   %edx
80108bae:	50                   	push   %eax
80108baf:	e8 65 fd ff ff       	call   80108919 <pci_access_config>
80108bb4:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108bb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bba:	83 c8 04             	or     $0x4,%eax
80108bbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108bc0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80108bc6:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108bca:	0f b6 c8             	movzbl %al,%ecx
80108bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80108bd0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108bd4:	0f b6 d0             	movzbl %al,%edx
80108bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80108bda:	0f b6 00             	movzbl (%eax),%eax
80108bdd:	0f b6 c0             	movzbl %al,%eax
80108be0:	83 ec 0c             	sub    $0xc,%esp
80108be3:	53                   	push   %ebx
80108be4:	6a 04                	push   $0x4
80108be6:	51                   	push   %ecx
80108be7:	52                   	push   %edx
80108be8:	50                   	push   %eax
80108be9:	e8 84 fd ff ff       	call   80108972 <pci_write_config_register>
80108bee:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108bf1:	8b 45 08             	mov    0x8(%ebp),%eax
80108bf4:	8b 40 10             	mov    0x10(%eax),%eax
80108bf7:	05 00 00 00 40       	add    $0x40000000,%eax
80108bfc:	a3 b4 81 19 80       	mov    %eax,0x801981b4
  uint *ctrl = (uint *)base_addr;
80108c01:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108c09:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108c0e:	05 d8 00 00 00       	add    $0xd8,%eax
80108c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c19:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c22:	8b 00                	mov    (%eax),%eax
80108c24:	0d 00 00 00 04       	or     $0x4000000,%eax
80108c29:	89 c2                	mov    %eax,%edx
80108c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c2e:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c33:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3c:	8b 00                	mov    (%eax),%eax
80108c3e:	83 c8 40             	or     $0x40,%eax
80108c41:	89 c2                	mov    %eax,%edx
80108c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c46:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c4b:	8b 10                	mov    (%eax),%edx
80108c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c50:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108c52:	83 ec 0c             	sub    $0xc,%esp
80108c55:	68 10 c7 10 80       	push   $0x8010c710
80108c5a:	e8 ad 77 ff ff       	call   8010040c <cprintf>
80108c5f:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108c62:	e8 2b 9c ff ff       	call   80102892 <kalloc>
80108c67:	a3 b8 81 19 80       	mov    %eax,0x801981b8
  *intr_addr = 0;
80108c6c:	a1 b8 81 19 80       	mov    0x801981b8,%eax
80108c71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108c77:	a1 b8 81 19 80       	mov    0x801981b8,%eax
80108c7c:	83 ec 08             	sub    $0x8,%esp
80108c7f:	50                   	push   %eax
80108c80:	68 32 c7 10 80       	push   $0x8010c732
80108c85:	e8 82 77 ff ff       	call   8010040c <cprintf>
80108c8a:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108c8d:	e8 50 00 00 00       	call   80108ce2 <i8254_init_recv>
  i8254_init_send();
80108c92:	e8 6d 03 00 00       	call   80109004 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108c97:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108c9e:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108ca1:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108ca8:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108cab:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108cb2:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108cb5:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108cbc:	0f b6 c0             	movzbl %al,%eax
80108cbf:	83 ec 0c             	sub    $0xc,%esp
80108cc2:	53                   	push   %ebx
80108cc3:	51                   	push   %ecx
80108cc4:	52                   	push   %edx
80108cc5:	50                   	push   %eax
80108cc6:	68 40 c7 10 80       	push   $0x8010c740
80108ccb:	e8 3c 77 ff ff       	call   8010040c <cprintf>
80108cd0:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cd6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108cdc:	90                   	nop
80108cdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ce0:	c9                   	leave  
80108ce1:	c3                   	ret    

80108ce2 <i8254_init_recv>:

void i8254_init_recv(){
80108ce2:	f3 0f 1e fb          	endbr32 
80108ce6:	55                   	push   %ebp
80108ce7:	89 e5                	mov    %esp,%ebp
80108ce9:	57                   	push   %edi
80108cea:	56                   	push   %esi
80108ceb:	53                   	push   %ebx
80108cec:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108cef:	83 ec 0c             	sub    $0xc,%esp
80108cf2:	6a 00                	push   $0x0
80108cf4:	e8 ec 04 00 00       	call   801091e5 <i8254_read_eeprom>
80108cf9:	83 c4 10             	add    $0x10,%esp
80108cfc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108cff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d02:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108d07:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d0a:	c1 e8 08             	shr    $0x8,%eax
80108d0d:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108d12:	83 ec 0c             	sub    $0xc,%esp
80108d15:	6a 01                	push   $0x1
80108d17:	e8 c9 04 00 00       	call   801091e5 <i8254_read_eeprom>
80108d1c:	83 c4 10             	add    $0x10,%esp
80108d1f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108d22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d25:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108d2a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d2d:	c1 e8 08             	shr    $0x8,%eax
80108d30:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108d35:	83 ec 0c             	sub    $0xc,%esp
80108d38:	6a 02                	push   $0x2
80108d3a:	e8 a6 04 00 00       	call   801091e5 <i8254_read_eeprom>
80108d3f:	83 c4 10             	add    $0x10,%esp
80108d42:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108d45:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d48:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108d4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108d50:	c1 e8 08             	shr    $0x8,%eax
80108d53:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108d58:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108d5f:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108d62:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108d69:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108d6c:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108d73:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108d76:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108d7d:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108d80:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108d87:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108d8a:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108d91:	0f b6 c0             	movzbl %al,%eax
80108d94:	83 ec 04             	sub    $0x4,%esp
80108d97:	57                   	push   %edi
80108d98:	56                   	push   %esi
80108d99:	53                   	push   %ebx
80108d9a:	51                   	push   %ecx
80108d9b:	52                   	push   %edx
80108d9c:	50                   	push   %eax
80108d9d:	68 58 c7 10 80       	push   $0x8010c758
80108da2:	e8 65 76 ff ff       	call   8010040c <cprintf>
80108da7:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108daa:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108daf:	05 00 54 00 00       	add    $0x5400,%eax
80108db4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108db7:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108dbc:	05 04 54 00 00       	add    $0x5404,%eax
80108dc1:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108dc4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108dc7:	c1 e0 10             	shl    $0x10,%eax
80108dca:	0b 45 d8             	or     -0x28(%ebp),%eax
80108dcd:	89 c2                	mov    %eax,%edx
80108dcf:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108dd2:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108dd4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dd7:	0d 00 00 00 80       	or     $0x80000000,%eax
80108ddc:	89 c2                	mov    %eax,%edx
80108dde:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108de1:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108de3:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108de8:	05 00 52 00 00       	add    $0x5200,%eax
80108ded:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108df0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108df7:	eb 19                	jmp    80108e12 <i8254_init_recv+0x130>
    mta[i] = 0;
80108df9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108dfc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e03:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108e06:	01 d0                	add    %edx,%eax
80108e08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108e0e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108e12:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108e16:	7e e1                	jle    80108df9 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108e18:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e1d:	05 d0 00 00 00       	add    $0xd0,%eax
80108e22:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108e25:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108e28:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108e2e:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e33:	05 c8 00 00 00       	add    $0xc8,%eax
80108e38:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108e3b:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108e3e:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108e44:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e49:	05 28 28 00 00       	add    $0x2828,%eax
80108e4e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108e51:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108e54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108e5a:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e5f:	05 00 01 00 00       	add    $0x100,%eax
80108e64:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108e67:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108e6a:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108e70:	e8 1d 9a ff ff       	call   80102892 <kalloc>
80108e75:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108e78:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e7d:	05 00 28 00 00       	add    $0x2800,%eax
80108e82:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108e85:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e8a:	05 04 28 00 00       	add    $0x2804,%eax
80108e8f:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108e92:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108e97:	05 08 28 00 00       	add    $0x2808,%eax
80108e9c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108e9f:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108ea4:	05 10 28 00 00       	add    $0x2810,%eax
80108ea9:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108eac:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80108eb1:	05 18 28 00 00       	add    $0x2818,%eax
80108eb6:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108eb9:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108ebc:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108ec2:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108ec5:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108ec7:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108eca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108ed0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108ed3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108ed9:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108edc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108ee2:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108ee5:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108eeb:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108eee:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108ef1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108ef8:	eb 73                	jmp    80108f6d <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108efa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108efd:	c1 e0 04             	shl    $0x4,%eax
80108f00:	89 c2                	mov    %eax,%edx
80108f02:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f05:	01 d0                	add    %edx,%eax
80108f07:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108f0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f11:	c1 e0 04             	shl    $0x4,%eax
80108f14:	89 c2                	mov    %eax,%edx
80108f16:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f19:	01 d0                	add    %edx,%eax
80108f1b:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108f21:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f24:	c1 e0 04             	shl    $0x4,%eax
80108f27:	89 c2                	mov    %eax,%edx
80108f29:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f2c:	01 d0                	add    %edx,%eax
80108f2e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108f34:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f37:	c1 e0 04             	shl    $0x4,%eax
80108f3a:	89 c2                	mov    %eax,%edx
80108f3c:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f3f:	01 d0                	add    %edx,%eax
80108f41:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108f45:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f48:	c1 e0 04             	shl    $0x4,%eax
80108f4b:	89 c2                	mov    %eax,%edx
80108f4d:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f50:	01 d0                	add    %edx,%eax
80108f52:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108f56:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f59:	c1 e0 04             	shl    $0x4,%eax
80108f5c:	89 c2                	mov    %eax,%edx
80108f5e:	8b 45 98             	mov    -0x68(%ebp),%eax
80108f61:	01 d0                	add    %edx,%eax
80108f63:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108f69:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108f6d:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108f74:	7e 84                	jle    80108efa <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108f76:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108f7d:	eb 57                	jmp    80108fd6 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80108f7f:	e8 0e 99 ff ff       	call   80102892 <kalloc>
80108f84:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108f87:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108f8b:	75 12                	jne    80108f9f <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80108f8d:	83 ec 0c             	sub    $0xc,%esp
80108f90:	68 78 c7 10 80       	push   $0x8010c778
80108f95:	e8 72 74 ff ff       	call   8010040c <cprintf>
80108f9a:	83 c4 10             	add    $0x10,%esp
      break;
80108f9d:	eb 3d                	jmp    80108fdc <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108f9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108fa2:	c1 e0 04             	shl    $0x4,%eax
80108fa5:	89 c2                	mov    %eax,%edx
80108fa7:	8b 45 98             	mov    -0x68(%ebp),%eax
80108faa:	01 d0                	add    %edx,%eax
80108fac:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108faf:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108fb5:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108fb7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108fba:	83 c0 01             	add    $0x1,%eax
80108fbd:	c1 e0 04             	shl    $0x4,%eax
80108fc0:	89 c2                	mov    %eax,%edx
80108fc2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fc5:	01 d0                	add    %edx,%eax
80108fc7:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108fca:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108fd0:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108fd2:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108fd6:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108fda:	7e a3                	jle    80108f7f <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80108fdc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108fdf:	8b 00                	mov    (%eax),%eax
80108fe1:	83 c8 02             	or     $0x2,%eax
80108fe4:	89 c2                	mov    %eax,%edx
80108fe6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108fe9:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108feb:	83 ec 0c             	sub    $0xc,%esp
80108fee:	68 98 c7 10 80       	push   $0x8010c798
80108ff3:	e8 14 74 ff ff       	call   8010040c <cprintf>
80108ff8:	83 c4 10             	add    $0x10,%esp
}
80108ffb:	90                   	nop
80108ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108fff:	5b                   	pop    %ebx
80109000:	5e                   	pop    %esi
80109001:	5f                   	pop    %edi
80109002:	5d                   	pop    %ebp
80109003:	c3                   	ret    

80109004 <i8254_init_send>:

void i8254_init_send(){
80109004:	f3 0f 1e fb          	endbr32 
80109008:	55                   	push   %ebp
80109009:	89 e5                	mov    %esp,%ebp
8010900b:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
8010900e:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109013:	05 28 38 00 00       	add    $0x3828,%eax
80109018:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
8010901b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010901e:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80109024:	e8 69 98 ff ff       	call   80102892 <kalloc>
80109029:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010902c:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109031:	05 00 38 00 00       	add    $0x3800,%eax
80109036:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80109039:	a1 b4 81 19 80       	mov    0x801981b4,%eax
8010903e:	05 04 38 00 00       	add    $0x3804,%eax
80109043:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80109046:	a1 b4 81 19 80       	mov    0x801981b4,%eax
8010904b:	05 08 38 00 00       	add    $0x3808,%eax
80109050:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80109053:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109056:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010905c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010905f:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109061:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109064:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
8010906a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010906d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80109073:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109078:	05 10 38 00 00       	add    $0x3810,%eax
8010907d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109080:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109085:	05 18 38 00 00       	add    $0x3818,%eax
8010908a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
8010908d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109090:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80109096:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109099:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
8010909f:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801090a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801090ac:	e9 82 00 00 00       	jmp    80109133 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
801090b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b4:	c1 e0 04             	shl    $0x4,%eax
801090b7:	89 c2                	mov    %eax,%edx
801090b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090bc:	01 d0                	add    %edx,%eax
801090be:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801090c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c8:	c1 e0 04             	shl    $0x4,%eax
801090cb:	89 c2                	mov    %eax,%edx
801090cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090d0:	01 d0                	add    %edx,%eax
801090d2:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801090d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090db:	c1 e0 04             	shl    $0x4,%eax
801090de:	89 c2                	mov    %eax,%edx
801090e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090e3:	01 d0                	add    %edx,%eax
801090e5:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801090e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ec:	c1 e0 04             	shl    $0x4,%eax
801090ef:	89 c2                	mov    %eax,%edx
801090f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090f4:	01 d0                	add    %edx,%eax
801090f6:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801090fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090fd:	c1 e0 04             	shl    $0x4,%eax
80109100:	89 c2                	mov    %eax,%edx
80109102:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109105:	01 d0                	add    %edx,%eax
80109107:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
8010910b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010910e:	c1 e0 04             	shl    $0x4,%eax
80109111:	89 c2                	mov    %eax,%edx
80109113:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109116:	01 d0                	add    %edx,%eax
80109118:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
8010911c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010911f:	c1 e0 04             	shl    $0x4,%eax
80109122:	89 c2                	mov    %eax,%edx
80109124:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109127:	01 d0                	add    %edx,%eax
80109129:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010912f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109133:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010913a:	0f 8e 71 ff ff ff    	jle    801090b1 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109140:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109147:	eb 57                	jmp    801091a0 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80109149:	e8 44 97 ff ff       	call   80102892 <kalloc>
8010914e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109151:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109155:	75 12                	jne    80109169 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80109157:	83 ec 0c             	sub    $0xc,%esp
8010915a:	68 78 c7 10 80       	push   $0x8010c778
8010915f:	e8 a8 72 ff ff       	call   8010040c <cprintf>
80109164:	83 c4 10             	add    $0x10,%esp
      break;
80109167:	eb 3d                	jmp    801091a6 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010916c:	c1 e0 04             	shl    $0x4,%eax
8010916f:	89 c2                	mov    %eax,%edx
80109171:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109174:	01 d0                	add    %edx,%eax
80109176:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109179:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010917f:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109181:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109184:	83 c0 01             	add    $0x1,%eax
80109187:	c1 e0 04             	shl    $0x4,%eax
8010918a:	89 c2                	mov    %eax,%edx
8010918c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010918f:	01 d0                	add    %edx,%eax
80109191:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109194:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010919a:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010919c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801091a0:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801091a4:	7e a3                	jle    80109149 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
801091a6:	a1 b4 81 19 80       	mov    0x801981b4,%eax
801091ab:	05 00 04 00 00       	add    $0x400,%eax
801091b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801091b3:	8b 45 c8             	mov    -0x38(%ebp),%eax
801091b6:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801091bc:	a1 b4 81 19 80       	mov    0x801981b4,%eax
801091c1:	05 10 04 00 00       	add    $0x410,%eax
801091c6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801091c9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801091cc:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801091d2:	83 ec 0c             	sub    $0xc,%esp
801091d5:	68 b8 c7 10 80       	push   $0x8010c7b8
801091da:	e8 2d 72 ff ff       	call   8010040c <cprintf>
801091df:	83 c4 10             	add    $0x10,%esp

}
801091e2:	90                   	nop
801091e3:	c9                   	leave  
801091e4:	c3                   	ret    

801091e5 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801091e5:	f3 0f 1e fb          	endbr32 
801091e9:	55                   	push   %ebp
801091ea:	89 e5                	mov    %esp,%ebp
801091ec:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801091ef:	a1 b4 81 19 80       	mov    0x801981b4,%eax
801091f4:	83 c0 14             	add    $0x14,%eax
801091f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801091fa:	8b 45 08             	mov    0x8(%ebp),%eax
801091fd:	c1 e0 08             	shl    $0x8,%eax
80109200:	0f b7 c0             	movzwl %ax,%eax
80109203:	83 c8 01             	or     $0x1,%eax
80109206:	89 c2                	mov    %eax,%edx
80109208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010920b:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
8010920d:	83 ec 0c             	sub    $0xc,%esp
80109210:	68 d8 c7 10 80       	push   $0x8010c7d8
80109215:	e8 f2 71 ff ff       	call   8010040c <cprintf>
8010921a:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010921d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109220:	8b 00                	mov    (%eax),%eax
80109222:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109225:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109228:	83 e0 10             	and    $0x10,%eax
8010922b:	85 c0                	test   %eax,%eax
8010922d:	75 02                	jne    80109231 <i8254_read_eeprom+0x4c>
  while(1){
8010922f:	eb dc                	jmp    8010920d <i8254_read_eeprom+0x28>
      break;
80109231:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109235:	8b 00                	mov    (%eax),%eax
80109237:	c1 e8 10             	shr    $0x10,%eax
}
8010923a:	c9                   	leave  
8010923b:	c3                   	ret    

8010923c <i8254_recv>:
void i8254_recv(){
8010923c:	f3 0f 1e fb          	endbr32 
80109240:	55                   	push   %ebp
80109241:	89 e5                	mov    %esp,%ebp
80109243:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109246:	a1 b4 81 19 80       	mov    0x801981b4,%eax
8010924b:	05 10 28 00 00       	add    $0x2810,%eax
80109250:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109253:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109258:	05 18 28 00 00       	add    $0x2818,%eax
8010925d:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109260:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109265:	05 00 28 00 00       	add    $0x2800,%eax
8010926a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010926d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109270:	8b 00                	mov    (%eax),%eax
80109272:	05 00 00 00 80       	add    $0x80000000,%eax
80109277:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010927a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010927d:	8b 10                	mov    (%eax),%edx
8010927f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109282:	8b 00                	mov    (%eax),%eax
80109284:	29 c2                	sub    %eax,%edx
80109286:	89 d0                	mov    %edx,%eax
80109288:	25 ff 00 00 00       	and    $0xff,%eax
8010928d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109290:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109294:	7e 37                	jle    801092cd <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109296:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109299:	8b 00                	mov    (%eax),%eax
8010929b:	c1 e0 04             	shl    $0x4,%eax
8010929e:	89 c2                	mov    %eax,%edx
801092a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092a3:	01 d0                	add    %edx,%eax
801092a5:	8b 00                	mov    (%eax),%eax
801092a7:	05 00 00 00 80       	add    $0x80000000,%eax
801092ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801092af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092b2:	8b 00                	mov    (%eax),%eax
801092b4:	83 c0 01             	add    $0x1,%eax
801092b7:	0f b6 d0             	movzbl %al,%edx
801092ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092bd:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801092bf:	83 ec 0c             	sub    $0xc,%esp
801092c2:	ff 75 e0             	pushl  -0x20(%ebp)
801092c5:	e8 47 09 00 00       	call   80109c11 <eth_proc>
801092ca:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801092cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092d0:	8b 10                	mov    (%eax),%edx
801092d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d5:	8b 00                	mov    (%eax),%eax
801092d7:	39 c2                	cmp    %eax,%edx
801092d9:	75 9f                	jne    8010927a <i8254_recv+0x3e>
      (*rdt)--;
801092db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092de:	8b 00                	mov    (%eax),%eax
801092e0:	8d 50 ff             	lea    -0x1(%eax),%edx
801092e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092e6:	89 10                	mov    %edx,(%eax)
  while(1){
801092e8:	eb 90                	jmp    8010927a <i8254_recv+0x3e>

801092ea <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801092ea:	f3 0f 1e fb          	endbr32 
801092ee:	55                   	push   %ebp
801092ef:	89 e5                	mov    %esp,%ebp
801092f1:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801092f4:	a1 b4 81 19 80       	mov    0x801981b4,%eax
801092f9:	05 10 38 00 00       	add    $0x3810,%eax
801092fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109301:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109306:	05 18 38 00 00       	add    $0x3818,%eax
8010930b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010930e:	a1 b4 81 19 80       	mov    0x801981b4,%eax
80109313:	05 00 38 00 00       	add    $0x3800,%eax
80109318:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
8010931b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010931e:	8b 00                	mov    (%eax),%eax
80109320:	05 00 00 00 80       	add    $0x80000000,%eax
80109325:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109328:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010932b:	8b 10                	mov    (%eax),%edx
8010932d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109330:	8b 00                	mov    (%eax),%eax
80109332:	29 c2                	sub    %eax,%edx
80109334:	89 d0                	mov    %edx,%eax
80109336:	0f b6 c0             	movzbl %al,%eax
80109339:	ba 00 01 00 00       	mov    $0x100,%edx
8010933e:	29 c2                	sub    %eax,%edx
80109340:	89 d0                	mov    %edx,%eax
80109342:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109345:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109348:	8b 00                	mov    (%eax),%eax
8010934a:	25 ff 00 00 00       	and    $0xff,%eax
8010934f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109352:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109356:	0f 8e a8 00 00 00    	jle    80109404 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
8010935c:	8b 45 08             	mov    0x8(%ebp),%eax
8010935f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109362:	89 d1                	mov    %edx,%ecx
80109364:	c1 e1 04             	shl    $0x4,%ecx
80109367:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010936a:	01 ca                	add    %ecx,%edx
8010936c:	8b 12                	mov    (%edx),%edx
8010936e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109374:	83 ec 04             	sub    $0x4,%esp
80109377:	ff 75 0c             	pushl  0xc(%ebp)
8010937a:	50                   	push   %eax
8010937b:	52                   	push   %edx
8010937c:	e8 f5 bc ff ff       	call   80105076 <memmove>
80109381:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109384:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109387:	c1 e0 04             	shl    $0x4,%eax
8010938a:	89 c2                	mov    %eax,%edx
8010938c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010938f:	01 d0                	add    %edx,%eax
80109391:	8b 55 0c             	mov    0xc(%ebp),%edx
80109394:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109398:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010939b:	c1 e0 04             	shl    $0x4,%eax
8010939e:	89 c2                	mov    %eax,%edx
801093a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093a3:	01 d0                	add    %edx,%eax
801093a5:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801093a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801093ac:	c1 e0 04             	shl    $0x4,%eax
801093af:	89 c2                	mov    %eax,%edx
801093b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093b4:	01 d0                	add    %edx,%eax
801093b6:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801093ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
801093bd:	c1 e0 04             	shl    $0x4,%eax
801093c0:	89 c2                	mov    %eax,%edx
801093c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093c5:	01 d0                	add    %edx,%eax
801093c7:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801093cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801093ce:	c1 e0 04             	shl    $0x4,%eax
801093d1:	89 c2                	mov    %eax,%edx
801093d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093d6:	01 d0                	add    %edx,%eax
801093d8:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801093de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801093e1:	c1 e0 04             	shl    $0x4,%eax
801093e4:	89 c2                	mov    %eax,%edx
801093e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093e9:	01 d0                	add    %edx,%eax
801093eb:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801093ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093f2:	8b 00                	mov    (%eax),%eax
801093f4:	83 c0 01             	add    $0x1,%eax
801093f7:	0f b6 d0             	movzbl %al,%edx
801093fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093fd:	89 10                	mov    %edx,(%eax)
    return len;
801093ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80109402:	eb 05                	jmp    80109409 <i8254_send+0x11f>
  }else{
    return -1;
80109404:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109409:	c9                   	leave  
8010940a:	c3                   	ret    

8010940b <i8254_intr>:

void i8254_intr(){
8010940b:	f3 0f 1e fb          	endbr32 
8010940f:	55                   	push   %ebp
80109410:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109412:	a1 b8 81 19 80       	mov    0x801981b8,%eax
80109417:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010941d:	90                   	nop
8010941e:	5d                   	pop    %ebp
8010941f:	c3                   	ret    

80109420 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109420:	f3 0f 1e fb          	endbr32 
80109424:	55                   	push   %ebp
80109425:	89 e5                	mov    %esp,%ebp
80109427:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010942a:	8b 45 08             	mov    0x8(%ebp),%eax
8010942d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109433:	0f b7 00             	movzwl (%eax),%eax
80109436:	66 3d 00 01          	cmp    $0x100,%ax
8010943a:	74 0a                	je     80109446 <arp_proc+0x26>
8010943c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109441:	e9 4f 01 00 00       	jmp    80109595 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109449:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010944d:	66 83 f8 08          	cmp    $0x8,%ax
80109451:	74 0a                	je     8010945d <arp_proc+0x3d>
80109453:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109458:	e9 38 01 00 00       	jmp    80109595 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
8010945d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109460:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109464:	3c 06                	cmp    $0x6,%al
80109466:	74 0a                	je     80109472 <arp_proc+0x52>
80109468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010946d:	e9 23 01 00 00       	jmp    80109595 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109475:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109479:	3c 04                	cmp    $0x4,%al
8010947b:	74 0a                	je     80109487 <arp_proc+0x67>
8010947d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109482:	e9 0e 01 00 00       	jmp    80109595 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010948a:	83 c0 18             	add    $0x18,%eax
8010948d:	83 ec 04             	sub    $0x4,%esp
80109490:	6a 04                	push   $0x4
80109492:	50                   	push   %eax
80109493:	68 04 f5 10 80       	push   $0x8010f504
80109498:	e8 7d bb ff ff       	call   8010501a <memcmp>
8010949d:	83 c4 10             	add    $0x10,%esp
801094a0:	85 c0                	test   %eax,%eax
801094a2:	74 27                	je     801094cb <arp_proc+0xab>
801094a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a7:	83 c0 0e             	add    $0xe,%eax
801094aa:	83 ec 04             	sub    $0x4,%esp
801094ad:	6a 04                	push   $0x4
801094af:	50                   	push   %eax
801094b0:	68 04 f5 10 80       	push   $0x8010f504
801094b5:	e8 60 bb ff ff       	call   8010501a <memcmp>
801094ba:	83 c4 10             	add    $0x10,%esp
801094bd:	85 c0                	test   %eax,%eax
801094bf:	74 0a                	je     801094cb <arp_proc+0xab>
801094c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801094c6:	e9 ca 00 00 00       	jmp    80109595 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801094cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ce:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801094d2:	66 3d 00 01          	cmp    $0x100,%ax
801094d6:	75 69                	jne    80109541 <arp_proc+0x121>
801094d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094db:	83 c0 18             	add    $0x18,%eax
801094de:	83 ec 04             	sub    $0x4,%esp
801094e1:	6a 04                	push   $0x4
801094e3:	50                   	push   %eax
801094e4:	68 04 f5 10 80       	push   $0x8010f504
801094e9:	e8 2c bb ff ff       	call   8010501a <memcmp>
801094ee:	83 c4 10             	add    $0x10,%esp
801094f1:	85 c0                	test   %eax,%eax
801094f3:	75 4c                	jne    80109541 <arp_proc+0x121>
    uint send = (uint)kalloc();
801094f5:	e8 98 93 ff ff       	call   80102892 <kalloc>
801094fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801094fd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109504:	83 ec 04             	sub    $0x4,%esp
80109507:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010950a:	50                   	push   %eax
8010950b:	ff 75 f0             	pushl  -0x10(%ebp)
8010950e:	ff 75 f4             	pushl  -0xc(%ebp)
80109511:	e8 33 04 00 00       	call   80109949 <arp_reply_pkt_create>
80109516:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010951c:	83 ec 08             	sub    $0x8,%esp
8010951f:	50                   	push   %eax
80109520:	ff 75 f0             	pushl  -0x10(%ebp)
80109523:	e8 c2 fd ff ff       	call   801092ea <i8254_send>
80109528:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010952b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010952e:	83 ec 0c             	sub    $0xc,%esp
80109531:	50                   	push   %eax
80109532:	e8 bd 92 ff ff       	call   801027f4 <kfree>
80109537:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010953a:	b8 02 00 00 00       	mov    $0x2,%eax
8010953f:	eb 54                	jmp    80109595 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109544:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109548:	66 3d 00 02          	cmp    $0x200,%ax
8010954c:	75 42                	jne    80109590 <arp_proc+0x170>
8010954e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109551:	83 c0 18             	add    $0x18,%eax
80109554:	83 ec 04             	sub    $0x4,%esp
80109557:	6a 04                	push   $0x4
80109559:	50                   	push   %eax
8010955a:	68 04 f5 10 80       	push   $0x8010f504
8010955f:	e8 b6 ba ff ff       	call   8010501a <memcmp>
80109564:	83 c4 10             	add    $0x10,%esp
80109567:	85 c0                	test   %eax,%eax
80109569:	75 25                	jne    80109590 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
8010956b:	83 ec 0c             	sub    $0xc,%esp
8010956e:	68 dc c7 10 80       	push   $0x8010c7dc
80109573:	e8 94 6e ff ff       	call   8010040c <cprintf>
80109578:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010957b:	83 ec 0c             	sub    $0xc,%esp
8010957e:	ff 75 f4             	pushl  -0xc(%ebp)
80109581:	e8 b7 01 00 00       	call   8010973d <arp_table_update>
80109586:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109589:	b8 01 00 00 00       	mov    $0x1,%eax
8010958e:	eb 05                	jmp    80109595 <arp_proc+0x175>
  }else{
    return -1;
80109590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109595:	c9                   	leave  
80109596:	c3                   	ret    

80109597 <arp_scan>:

void arp_scan(){
80109597:	f3 0f 1e fb          	endbr32 
8010959b:	55                   	push   %ebp
8010959c:	89 e5                	mov    %esp,%ebp
8010959e:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801095a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801095a8:	eb 6f                	jmp    80109619 <arp_scan+0x82>
    uint send = (uint)kalloc();
801095aa:	e8 e3 92 ff ff       	call   80102892 <kalloc>
801095af:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801095b2:	83 ec 04             	sub    $0x4,%esp
801095b5:	ff 75 f4             	pushl  -0xc(%ebp)
801095b8:	8d 45 e8             	lea    -0x18(%ebp),%eax
801095bb:	50                   	push   %eax
801095bc:	ff 75 ec             	pushl  -0x14(%ebp)
801095bf:	e8 62 00 00 00       	call   80109626 <arp_broadcast>
801095c4:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801095c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095ca:	83 ec 08             	sub    $0x8,%esp
801095cd:	50                   	push   %eax
801095ce:	ff 75 ec             	pushl  -0x14(%ebp)
801095d1:	e8 14 fd ff ff       	call   801092ea <i8254_send>
801095d6:	83 c4 10             	add    $0x10,%esp
801095d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801095dc:	eb 22                	jmp    80109600 <arp_scan+0x69>
      microdelay(1);
801095de:	83 ec 0c             	sub    $0xc,%esp
801095e1:	6a 01                	push   $0x1
801095e3:	e8 5c 96 ff ff       	call   80102c44 <microdelay>
801095e8:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801095eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095ee:	83 ec 08             	sub    $0x8,%esp
801095f1:	50                   	push   %eax
801095f2:	ff 75 ec             	pushl  -0x14(%ebp)
801095f5:	e8 f0 fc ff ff       	call   801092ea <i8254_send>
801095fa:	83 c4 10             	add    $0x10,%esp
801095fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109600:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109604:	74 d8                	je     801095de <arp_scan+0x47>
    }
    kfree((char *)send);
80109606:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109609:	83 ec 0c             	sub    $0xc,%esp
8010960c:	50                   	push   %eax
8010960d:	e8 e2 91 ff ff       	call   801027f4 <kfree>
80109612:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109615:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109619:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109620:	7e 88                	jle    801095aa <arp_scan+0x13>
  }
}
80109622:	90                   	nop
80109623:	90                   	nop
80109624:	c9                   	leave  
80109625:	c3                   	ret    

80109626 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109626:	f3 0f 1e fb          	endbr32 
8010962a:	55                   	push   %ebp
8010962b:	89 e5                	mov    %esp,%ebp
8010962d:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109630:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109634:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109638:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010963c:	8b 45 10             	mov    0x10(%ebp),%eax
8010963f:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109642:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109649:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
8010964f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109656:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010965c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010965f:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109665:	8b 45 08             	mov    0x8(%ebp),%eax
80109668:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010966b:	8b 45 08             	mov    0x8(%ebp),%eax
8010966e:	83 c0 0e             	add    $0xe,%eax
80109671:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109674:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109677:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010967b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010967e:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109685:	83 ec 04             	sub    $0x4,%esp
80109688:	6a 06                	push   $0x6
8010968a:	8d 55 e6             	lea    -0x1a(%ebp),%edx
8010968d:	52                   	push   %edx
8010968e:	50                   	push   %eax
8010968f:	e8 e2 b9 ff ff       	call   80105076 <memmove>
80109694:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010969a:	83 c0 06             	add    $0x6,%eax
8010969d:	83 ec 04             	sub    $0x4,%esp
801096a0:	6a 06                	push   $0x6
801096a2:	68 68 d0 18 80       	push   $0x8018d068
801096a7:	50                   	push   %eax
801096a8:	e8 c9 b9 ff ff       	call   80105076 <memmove>
801096ad:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801096b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096b3:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801096b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096bb:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801096c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096c4:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801096c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096cb:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801096cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096d2:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801096d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096db:	8d 50 12             	lea    0x12(%eax),%edx
801096de:	83 ec 04             	sub    $0x4,%esp
801096e1:	6a 06                	push   $0x6
801096e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801096e6:	50                   	push   %eax
801096e7:	52                   	push   %edx
801096e8:	e8 89 b9 ff ff       	call   80105076 <memmove>
801096ed:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801096f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096f3:	8d 50 18             	lea    0x18(%eax),%edx
801096f6:	83 ec 04             	sub    $0x4,%esp
801096f9:	6a 04                	push   $0x4
801096fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801096fe:	50                   	push   %eax
801096ff:	52                   	push   %edx
80109700:	e8 71 b9 ff ff       	call   80105076 <memmove>
80109705:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109708:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010970b:	83 c0 08             	add    $0x8,%eax
8010970e:	83 ec 04             	sub    $0x4,%esp
80109711:	6a 06                	push   $0x6
80109713:	68 68 d0 18 80       	push   $0x8018d068
80109718:	50                   	push   %eax
80109719:	e8 58 b9 ff ff       	call   80105076 <memmove>
8010971e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109721:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109724:	83 c0 0e             	add    $0xe,%eax
80109727:	83 ec 04             	sub    $0x4,%esp
8010972a:	6a 04                	push   $0x4
8010972c:	68 04 f5 10 80       	push   $0x8010f504
80109731:	50                   	push   %eax
80109732:	e8 3f b9 ff ff       	call   80105076 <memmove>
80109737:	83 c4 10             	add    $0x10,%esp
}
8010973a:	90                   	nop
8010973b:	c9                   	leave  
8010973c:	c3                   	ret    

8010973d <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010973d:	f3 0f 1e fb          	endbr32 
80109741:	55                   	push   %ebp
80109742:	89 e5                	mov    %esp,%ebp
80109744:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109747:	8b 45 08             	mov    0x8(%ebp),%eax
8010974a:	83 c0 0e             	add    $0xe,%eax
8010974d:	83 ec 0c             	sub    $0xc,%esp
80109750:	50                   	push   %eax
80109751:	e8 bc 00 00 00       	call   80109812 <arp_table_search>
80109756:	83 c4 10             	add    $0x10,%esp
80109759:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010975c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109760:	78 2d                	js     8010978f <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109762:	8b 45 08             	mov    0x8(%ebp),%eax
80109765:	8d 48 08             	lea    0x8(%eax),%ecx
80109768:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010976b:	89 d0                	mov    %edx,%eax
8010976d:	c1 e0 02             	shl    $0x2,%eax
80109770:	01 d0                	add    %edx,%eax
80109772:	01 c0                	add    %eax,%eax
80109774:	01 d0                	add    %edx,%eax
80109776:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010977b:	83 c0 04             	add    $0x4,%eax
8010977e:	83 ec 04             	sub    $0x4,%esp
80109781:	6a 06                	push   $0x6
80109783:	51                   	push   %ecx
80109784:	50                   	push   %eax
80109785:	e8 ec b8 ff ff       	call   80105076 <memmove>
8010978a:	83 c4 10             	add    $0x10,%esp
8010978d:	eb 70                	jmp    801097ff <arp_table_update+0xc2>
  }else{
    index += 1;
8010978f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109793:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109796:	8b 45 08             	mov    0x8(%ebp),%eax
80109799:	8d 48 08             	lea    0x8(%eax),%ecx
8010979c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010979f:	89 d0                	mov    %edx,%eax
801097a1:	c1 e0 02             	shl    $0x2,%eax
801097a4:	01 d0                	add    %edx,%eax
801097a6:	01 c0                	add    %eax,%eax
801097a8:	01 d0                	add    %edx,%eax
801097aa:	05 80 d0 18 80       	add    $0x8018d080,%eax
801097af:	83 c0 04             	add    $0x4,%eax
801097b2:	83 ec 04             	sub    $0x4,%esp
801097b5:	6a 06                	push   $0x6
801097b7:	51                   	push   %ecx
801097b8:	50                   	push   %eax
801097b9:	e8 b8 b8 ff ff       	call   80105076 <memmove>
801097be:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801097c1:	8b 45 08             	mov    0x8(%ebp),%eax
801097c4:	8d 48 0e             	lea    0xe(%eax),%ecx
801097c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097ca:	89 d0                	mov    %edx,%eax
801097cc:	c1 e0 02             	shl    $0x2,%eax
801097cf:	01 d0                	add    %edx,%eax
801097d1:	01 c0                	add    %eax,%eax
801097d3:	01 d0                	add    %edx,%eax
801097d5:	05 80 d0 18 80       	add    $0x8018d080,%eax
801097da:	83 ec 04             	sub    $0x4,%esp
801097dd:	6a 04                	push   $0x4
801097df:	51                   	push   %ecx
801097e0:	50                   	push   %eax
801097e1:	e8 90 b8 ff ff       	call   80105076 <memmove>
801097e6:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801097e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097ec:	89 d0                	mov    %edx,%eax
801097ee:	c1 e0 02             	shl    $0x2,%eax
801097f1:	01 d0                	add    %edx,%eax
801097f3:	01 c0                	add    %eax,%eax
801097f5:	01 d0                	add    %edx,%eax
801097f7:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801097fc:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801097ff:	83 ec 0c             	sub    $0xc,%esp
80109802:	68 80 d0 18 80       	push   $0x8018d080
80109807:	e8 87 00 00 00       	call   80109893 <print_arp_table>
8010980c:	83 c4 10             	add    $0x10,%esp
}
8010980f:	90                   	nop
80109810:	c9                   	leave  
80109811:	c3                   	ret    

80109812 <arp_table_search>:

int arp_table_search(uchar *ip){
80109812:	f3 0f 1e fb          	endbr32 
80109816:	55                   	push   %ebp
80109817:	89 e5                	mov    %esp,%ebp
80109819:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010981c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109823:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010982a:	eb 59                	jmp    80109885 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010982c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010982f:	89 d0                	mov    %edx,%eax
80109831:	c1 e0 02             	shl    $0x2,%eax
80109834:	01 d0                	add    %edx,%eax
80109836:	01 c0                	add    %eax,%eax
80109838:	01 d0                	add    %edx,%eax
8010983a:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010983f:	83 ec 04             	sub    $0x4,%esp
80109842:	6a 04                	push   $0x4
80109844:	ff 75 08             	pushl  0x8(%ebp)
80109847:	50                   	push   %eax
80109848:	e8 cd b7 ff ff       	call   8010501a <memcmp>
8010984d:	83 c4 10             	add    $0x10,%esp
80109850:	85 c0                	test   %eax,%eax
80109852:	75 05                	jne    80109859 <arp_table_search+0x47>
      return i;
80109854:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109857:	eb 38                	jmp    80109891 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109859:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010985c:	89 d0                	mov    %edx,%eax
8010985e:	c1 e0 02             	shl    $0x2,%eax
80109861:	01 d0                	add    %edx,%eax
80109863:	01 c0                	add    %eax,%eax
80109865:	01 d0                	add    %edx,%eax
80109867:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010986c:	0f b6 00             	movzbl (%eax),%eax
8010986f:	84 c0                	test   %al,%al
80109871:	75 0e                	jne    80109881 <arp_table_search+0x6f>
80109873:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109877:	75 08                	jne    80109881 <arp_table_search+0x6f>
      empty = -i;
80109879:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010987c:	f7 d8                	neg    %eax
8010987e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109881:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109885:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109889:	7e a1                	jle    8010982c <arp_table_search+0x1a>
    }
  }
  return empty-1;
8010988b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010988e:	83 e8 01             	sub    $0x1,%eax
}
80109891:	c9                   	leave  
80109892:	c3                   	ret    

80109893 <print_arp_table>:

void print_arp_table(){
80109893:	f3 0f 1e fb          	endbr32 
80109897:	55                   	push   %ebp
80109898:	89 e5                	mov    %esp,%ebp
8010989a:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010989d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801098a4:	e9 92 00 00 00       	jmp    8010993b <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
801098a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801098ac:	89 d0                	mov    %edx,%eax
801098ae:	c1 e0 02             	shl    $0x2,%eax
801098b1:	01 d0                	add    %edx,%eax
801098b3:	01 c0                	add    %eax,%eax
801098b5:	01 d0                	add    %edx,%eax
801098b7:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801098bc:	0f b6 00             	movzbl (%eax),%eax
801098bf:	84 c0                	test   %al,%al
801098c1:	74 74                	je     80109937 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
801098c3:	83 ec 08             	sub    $0x8,%esp
801098c6:	ff 75 f4             	pushl  -0xc(%ebp)
801098c9:	68 ef c7 10 80       	push   $0x8010c7ef
801098ce:	e8 39 6b ff ff       	call   8010040c <cprintf>
801098d3:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801098d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801098d9:	89 d0                	mov    %edx,%eax
801098db:	c1 e0 02             	shl    $0x2,%eax
801098de:	01 d0                	add    %edx,%eax
801098e0:	01 c0                	add    %eax,%eax
801098e2:	01 d0                	add    %edx,%eax
801098e4:	05 80 d0 18 80       	add    $0x8018d080,%eax
801098e9:	83 ec 0c             	sub    $0xc,%esp
801098ec:	50                   	push   %eax
801098ed:	e8 5c 02 00 00       	call   80109b4e <print_ipv4>
801098f2:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801098f5:	83 ec 0c             	sub    $0xc,%esp
801098f8:	68 fe c7 10 80       	push   $0x8010c7fe
801098fd:	e8 0a 6b ff ff       	call   8010040c <cprintf>
80109902:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109905:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109908:	89 d0                	mov    %edx,%eax
8010990a:	c1 e0 02             	shl    $0x2,%eax
8010990d:	01 d0                	add    %edx,%eax
8010990f:	01 c0                	add    %eax,%eax
80109911:	01 d0                	add    %edx,%eax
80109913:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109918:	83 c0 04             	add    $0x4,%eax
8010991b:	83 ec 0c             	sub    $0xc,%esp
8010991e:	50                   	push   %eax
8010991f:	e8 7c 02 00 00       	call   80109ba0 <print_mac>
80109924:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109927:	83 ec 0c             	sub    $0xc,%esp
8010992a:	68 00 c8 10 80       	push   $0x8010c800
8010992f:	e8 d8 6a ff ff       	call   8010040c <cprintf>
80109934:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109937:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010993b:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010993f:	0f 8e 64 ff ff ff    	jle    801098a9 <print_arp_table+0x16>
    }
  }
}
80109945:	90                   	nop
80109946:	90                   	nop
80109947:	c9                   	leave  
80109948:	c3                   	ret    

80109949 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109949:	f3 0f 1e fb          	endbr32 
8010994d:	55                   	push   %ebp
8010994e:	89 e5                	mov    %esp,%ebp
80109950:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109953:	8b 45 10             	mov    0x10(%ebp),%eax
80109956:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010995c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010995f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109962:	8b 45 0c             	mov    0xc(%ebp),%eax
80109965:	83 c0 0e             	add    $0xe,%eax
80109968:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
8010996b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010996e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109975:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109979:	8b 45 08             	mov    0x8(%ebp),%eax
8010997c:	8d 50 08             	lea    0x8(%eax),%edx
8010997f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109982:	83 ec 04             	sub    $0x4,%esp
80109985:	6a 06                	push   $0x6
80109987:	52                   	push   %edx
80109988:	50                   	push   %eax
80109989:	e8 e8 b6 ff ff       	call   80105076 <memmove>
8010998e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109994:	83 c0 06             	add    $0x6,%eax
80109997:	83 ec 04             	sub    $0x4,%esp
8010999a:	6a 06                	push   $0x6
8010999c:	68 68 d0 18 80       	push   $0x8018d068
801099a1:	50                   	push   %eax
801099a2:	e8 cf b6 ff ff       	call   80105076 <memmove>
801099a7:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801099aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099ad:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801099b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099b5:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801099bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099be:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801099c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099c5:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801099c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099cc:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801099d2:	8b 45 08             	mov    0x8(%ebp),%eax
801099d5:	8d 50 08             	lea    0x8(%eax),%edx
801099d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099db:	83 c0 12             	add    $0x12,%eax
801099de:	83 ec 04             	sub    $0x4,%esp
801099e1:	6a 06                	push   $0x6
801099e3:	52                   	push   %edx
801099e4:	50                   	push   %eax
801099e5:	e8 8c b6 ff ff       	call   80105076 <memmove>
801099ea:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801099ed:	8b 45 08             	mov    0x8(%ebp),%eax
801099f0:	8d 50 0e             	lea    0xe(%eax),%edx
801099f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099f6:	83 c0 18             	add    $0x18,%eax
801099f9:	83 ec 04             	sub    $0x4,%esp
801099fc:	6a 04                	push   $0x4
801099fe:	52                   	push   %edx
801099ff:	50                   	push   %eax
80109a00:	e8 71 b6 ff ff       	call   80105076 <memmove>
80109a05:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a0b:	83 c0 08             	add    $0x8,%eax
80109a0e:	83 ec 04             	sub    $0x4,%esp
80109a11:	6a 06                	push   $0x6
80109a13:	68 68 d0 18 80       	push   $0x8018d068
80109a18:	50                   	push   %eax
80109a19:	e8 58 b6 ff ff       	call   80105076 <memmove>
80109a1e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a24:	83 c0 0e             	add    $0xe,%eax
80109a27:	83 ec 04             	sub    $0x4,%esp
80109a2a:	6a 04                	push   $0x4
80109a2c:	68 04 f5 10 80       	push   $0x8010f504
80109a31:	50                   	push   %eax
80109a32:	e8 3f b6 ff ff       	call   80105076 <memmove>
80109a37:	83 c4 10             	add    $0x10,%esp
}
80109a3a:	90                   	nop
80109a3b:	c9                   	leave  
80109a3c:	c3                   	ret    

80109a3d <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109a3d:	f3 0f 1e fb          	endbr32 
80109a41:	55                   	push   %ebp
80109a42:	89 e5                	mov    %esp,%ebp
80109a44:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109a47:	83 ec 0c             	sub    $0xc,%esp
80109a4a:	68 02 c8 10 80       	push   $0x8010c802
80109a4f:	e8 b8 69 ff ff       	call   8010040c <cprintf>
80109a54:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109a57:	8b 45 08             	mov    0x8(%ebp),%eax
80109a5a:	83 c0 0e             	add    $0xe,%eax
80109a5d:	83 ec 0c             	sub    $0xc,%esp
80109a60:	50                   	push   %eax
80109a61:	e8 e8 00 00 00       	call   80109b4e <print_ipv4>
80109a66:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109a69:	83 ec 0c             	sub    $0xc,%esp
80109a6c:	68 00 c8 10 80       	push   $0x8010c800
80109a71:	e8 96 69 ff ff       	call   8010040c <cprintf>
80109a76:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109a79:	8b 45 08             	mov    0x8(%ebp),%eax
80109a7c:	83 c0 08             	add    $0x8,%eax
80109a7f:	83 ec 0c             	sub    $0xc,%esp
80109a82:	50                   	push   %eax
80109a83:	e8 18 01 00 00       	call   80109ba0 <print_mac>
80109a88:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109a8b:	83 ec 0c             	sub    $0xc,%esp
80109a8e:	68 00 c8 10 80       	push   $0x8010c800
80109a93:	e8 74 69 ff ff       	call   8010040c <cprintf>
80109a98:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109a9b:	83 ec 0c             	sub    $0xc,%esp
80109a9e:	68 19 c8 10 80       	push   $0x8010c819
80109aa3:	e8 64 69 ff ff       	call   8010040c <cprintf>
80109aa8:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109aab:	8b 45 08             	mov    0x8(%ebp),%eax
80109aae:	83 c0 18             	add    $0x18,%eax
80109ab1:	83 ec 0c             	sub    $0xc,%esp
80109ab4:	50                   	push   %eax
80109ab5:	e8 94 00 00 00       	call   80109b4e <print_ipv4>
80109aba:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109abd:	83 ec 0c             	sub    $0xc,%esp
80109ac0:	68 00 c8 10 80       	push   $0x8010c800
80109ac5:	e8 42 69 ff ff       	call   8010040c <cprintf>
80109aca:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109acd:	8b 45 08             	mov    0x8(%ebp),%eax
80109ad0:	83 c0 12             	add    $0x12,%eax
80109ad3:	83 ec 0c             	sub    $0xc,%esp
80109ad6:	50                   	push   %eax
80109ad7:	e8 c4 00 00 00       	call   80109ba0 <print_mac>
80109adc:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109adf:	83 ec 0c             	sub    $0xc,%esp
80109ae2:	68 00 c8 10 80       	push   $0x8010c800
80109ae7:	e8 20 69 ff ff       	call   8010040c <cprintf>
80109aec:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109aef:	83 ec 0c             	sub    $0xc,%esp
80109af2:	68 30 c8 10 80       	push   $0x8010c830
80109af7:	e8 10 69 ff ff       	call   8010040c <cprintf>
80109afc:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109aff:	8b 45 08             	mov    0x8(%ebp),%eax
80109b02:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b06:	66 3d 00 01          	cmp    $0x100,%ax
80109b0a:	75 12                	jne    80109b1e <print_arp_info+0xe1>
80109b0c:	83 ec 0c             	sub    $0xc,%esp
80109b0f:	68 3c c8 10 80       	push   $0x8010c83c
80109b14:	e8 f3 68 ff ff       	call   8010040c <cprintf>
80109b19:	83 c4 10             	add    $0x10,%esp
80109b1c:	eb 1d                	jmp    80109b3b <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80109b21:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b25:	66 3d 00 02          	cmp    $0x200,%ax
80109b29:	75 10                	jne    80109b3b <print_arp_info+0xfe>
    cprintf("Reply\n");
80109b2b:	83 ec 0c             	sub    $0xc,%esp
80109b2e:	68 45 c8 10 80       	push   $0x8010c845
80109b33:	e8 d4 68 ff ff       	call   8010040c <cprintf>
80109b38:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109b3b:	83 ec 0c             	sub    $0xc,%esp
80109b3e:	68 00 c8 10 80       	push   $0x8010c800
80109b43:	e8 c4 68 ff ff       	call   8010040c <cprintf>
80109b48:	83 c4 10             	add    $0x10,%esp
}
80109b4b:	90                   	nop
80109b4c:	c9                   	leave  
80109b4d:	c3                   	ret    

80109b4e <print_ipv4>:

void print_ipv4(uchar *ip){
80109b4e:	f3 0f 1e fb          	endbr32 
80109b52:	55                   	push   %ebp
80109b53:	89 e5                	mov    %esp,%ebp
80109b55:	53                   	push   %ebx
80109b56:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109b59:	8b 45 08             	mov    0x8(%ebp),%eax
80109b5c:	83 c0 03             	add    $0x3,%eax
80109b5f:	0f b6 00             	movzbl (%eax),%eax
80109b62:	0f b6 d8             	movzbl %al,%ebx
80109b65:	8b 45 08             	mov    0x8(%ebp),%eax
80109b68:	83 c0 02             	add    $0x2,%eax
80109b6b:	0f b6 00             	movzbl (%eax),%eax
80109b6e:	0f b6 c8             	movzbl %al,%ecx
80109b71:	8b 45 08             	mov    0x8(%ebp),%eax
80109b74:	83 c0 01             	add    $0x1,%eax
80109b77:	0f b6 00             	movzbl (%eax),%eax
80109b7a:	0f b6 d0             	movzbl %al,%edx
80109b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80109b80:	0f b6 00             	movzbl (%eax),%eax
80109b83:	0f b6 c0             	movzbl %al,%eax
80109b86:	83 ec 0c             	sub    $0xc,%esp
80109b89:	53                   	push   %ebx
80109b8a:	51                   	push   %ecx
80109b8b:	52                   	push   %edx
80109b8c:	50                   	push   %eax
80109b8d:	68 4c c8 10 80       	push   $0x8010c84c
80109b92:	e8 75 68 ff ff       	call   8010040c <cprintf>
80109b97:	83 c4 20             	add    $0x20,%esp
}
80109b9a:	90                   	nop
80109b9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b9e:	c9                   	leave  
80109b9f:	c3                   	ret    

80109ba0 <print_mac>:

void print_mac(uchar *mac){
80109ba0:	f3 0f 1e fb          	endbr32 
80109ba4:	55                   	push   %ebp
80109ba5:	89 e5                	mov    %esp,%ebp
80109ba7:	57                   	push   %edi
80109ba8:	56                   	push   %esi
80109ba9:	53                   	push   %ebx
80109baa:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109bad:	8b 45 08             	mov    0x8(%ebp),%eax
80109bb0:	83 c0 05             	add    $0x5,%eax
80109bb3:	0f b6 00             	movzbl (%eax),%eax
80109bb6:	0f b6 f8             	movzbl %al,%edi
80109bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80109bbc:	83 c0 04             	add    $0x4,%eax
80109bbf:	0f b6 00             	movzbl (%eax),%eax
80109bc2:	0f b6 f0             	movzbl %al,%esi
80109bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc8:	83 c0 03             	add    $0x3,%eax
80109bcb:	0f b6 00             	movzbl (%eax),%eax
80109bce:	0f b6 d8             	movzbl %al,%ebx
80109bd1:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd4:	83 c0 02             	add    $0x2,%eax
80109bd7:	0f b6 00             	movzbl (%eax),%eax
80109bda:	0f b6 c8             	movzbl %al,%ecx
80109bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80109be0:	83 c0 01             	add    $0x1,%eax
80109be3:	0f b6 00             	movzbl (%eax),%eax
80109be6:	0f b6 d0             	movzbl %al,%edx
80109be9:	8b 45 08             	mov    0x8(%ebp),%eax
80109bec:	0f b6 00             	movzbl (%eax),%eax
80109bef:	0f b6 c0             	movzbl %al,%eax
80109bf2:	83 ec 04             	sub    $0x4,%esp
80109bf5:	57                   	push   %edi
80109bf6:	56                   	push   %esi
80109bf7:	53                   	push   %ebx
80109bf8:	51                   	push   %ecx
80109bf9:	52                   	push   %edx
80109bfa:	50                   	push   %eax
80109bfb:	68 64 c8 10 80       	push   $0x8010c864
80109c00:	e8 07 68 ff ff       	call   8010040c <cprintf>
80109c05:	83 c4 20             	add    $0x20,%esp
}
80109c08:	90                   	nop
80109c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109c0c:	5b                   	pop    %ebx
80109c0d:	5e                   	pop    %esi
80109c0e:	5f                   	pop    %edi
80109c0f:	5d                   	pop    %ebp
80109c10:	c3                   	ret    

80109c11 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109c11:	f3 0f 1e fb          	endbr32 
80109c15:	55                   	push   %ebp
80109c16:	89 e5                	mov    %esp,%ebp
80109c18:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109c21:	8b 45 08             	mov    0x8(%ebp),%eax
80109c24:	83 c0 0e             	add    $0xe,%eax
80109c27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c2d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109c31:	3c 08                	cmp    $0x8,%al
80109c33:	75 1b                	jne    80109c50 <eth_proc+0x3f>
80109c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c38:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109c3c:	3c 06                	cmp    $0x6,%al
80109c3e:	75 10                	jne    80109c50 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109c40:	83 ec 0c             	sub    $0xc,%esp
80109c43:	ff 75 f0             	pushl  -0x10(%ebp)
80109c46:	e8 d5 f7 ff ff       	call   80109420 <arp_proc>
80109c4b:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109c4e:	eb 24                	jmp    80109c74 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c53:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109c57:	3c 08                	cmp    $0x8,%al
80109c59:	75 19                	jne    80109c74 <eth_proc+0x63>
80109c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c5e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109c62:	84 c0                	test   %al,%al
80109c64:	75 0e                	jne    80109c74 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109c66:	83 ec 0c             	sub    $0xc,%esp
80109c69:	ff 75 08             	pushl  0x8(%ebp)
80109c6c:	e8 b3 00 00 00       	call   80109d24 <ipv4_proc>
80109c71:	83 c4 10             	add    $0x10,%esp
}
80109c74:	90                   	nop
80109c75:	c9                   	leave  
80109c76:	c3                   	ret    

80109c77 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109c77:	f3 0f 1e fb          	endbr32 
80109c7b:	55                   	push   %ebp
80109c7c:	89 e5                	mov    %esp,%ebp
80109c7e:	83 ec 04             	sub    $0x4,%esp
80109c81:	8b 45 08             	mov    0x8(%ebp),%eax
80109c84:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109c88:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109c8c:	c1 e0 08             	shl    $0x8,%eax
80109c8f:	89 c2                	mov    %eax,%edx
80109c91:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109c95:	66 c1 e8 08          	shr    $0x8,%ax
80109c99:	01 d0                	add    %edx,%eax
}
80109c9b:	c9                   	leave  
80109c9c:	c3                   	ret    

80109c9d <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109c9d:	f3 0f 1e fb          	endbr32 
80109ca1:	55                   	push   %ebp
80109ca2:	89 e5                	mov    %esp,%ebp
80109ca4:	83 ec 04             	sub    $0x4,%esp
80109ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80109caa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109cae:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109cb2:	c1 e0 08             	shl    $0x8,%eax
80109cb5:	89 c2                	mov    %eax,%edx
80109cb7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109cbb:	66 c1 e8 08          	shr    $0x8,%ax
80109cbf:	01 d0                	add    %edx,%eax
}
80109cc1:	c9                   	leave  
80109cc2:	c3                   	ret    

80109cc3 <H2N_uint>:

uint H2N_uint(uint value){
80109cc3:	f3 0f 1e fb          	endbr32 
80109cc7:	55                   	push   %ebp
80109cc8:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109cca:	8b 45 08             	mov    0x8(%ebp),%eax
80109ccd:	c1 e0 18             	shl    $0x18,%eax
80109cd0:	25 00 00 00 0f       	and    $0xf000000,%eax
80109cd5:	89 c2                	mov    %eax,%edx
80109cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80109cda:	c1 e0 08             	shl    $0x8,%eax
80109cdd:	25 00 f0 00 00       	and    $0xf000,%eax
80109ce2:	09 c2                	or     %eax,%edx
80109ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80109ce7:	c1 e8 08             	shr    $0x8,%eax
80109cea:	83 e0 0f             	and    $0xf,%eax
80109ced:	01 d0                	add    %edx,%eax
}
80109cef:	5d                   	pop    %ebp
80109cf0:	c3                   	ret    

80109cf1 <N2H_uint>:

uint N2H_uint(uint value){
80109cf1:	f3 0f 1e fb          	endbr32 
80109cf5:	55                   	push   %ebp
80109cf6:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80109cfb:	c1 e0 18             	shl    $0x18,%eax
80109cfe:	89 c2                	mov    %eax,%edx
80109d00:	8b 45 08             	mov    0x8(%ebp),%eax
80109d03:	c1 e0 08             	shl    $0x8,%eax
80109d06:	25 00 00 ff 00       	and    $0xff0000,%eax
80109d0b:	01 c2                	add    %eax,%edx
80109d0d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d10:	c1 e8 08             	shr    $0x8,%eax
80109d13:	25 00 ff 00 00       	and    $0xff00,%eax
80109d18:	01 c2                	add    %eax,%edx
80109d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80109d1d:	c1 e8 18             	shr    $0x18,%eax
80109d20:	01 d0                	add    %edx,%eax
}
80109d22:	5d                   	pop    %ebp
80109d23:	c3                   	ret    

80109d24 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109d24:	f3 0f 1e fb          	endbr32 
80109d28:	55                   	push   %ebp
80109d29:	89 e5                	mov    %esp,%ebp
80109d2b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80109d31:	83 c0 0e             	add    $0xe,%eax
80109d34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d3a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109d3e:	0f b7 d0             	movzwl %ax,%edx
80109d41:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109d46:	39 c2                	cmp    %eax,%edx
80109d48:	74 60                	je     80109daa <ipv4_proc+0x86>
80109d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d4d:	83 c0 0c             	add    $0xc,%eax
80109d50:	83 ec 04             	sub    $0x4,%esp
80109d53:	6a 04                	push   $0x4
80109d55:	50                   	push   %eax
80109d56:	68 04 f5 10 80       	push   $0x8010f504
80109d5b:	e8 ba b2 ff ff       	call   8010501a <memcmp>
80109d60:	83 c4 10             	add    $0x10,%esp
80109d63:	85 c0                	test   %eax,%eax
80109d65:	74 43                	je     80109daa <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d6a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109d6e:	0f b7 c0             	movzwl %ax,%eax
80109d71:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d79:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109d7d:	3c 01                	cmp    $0x1,%al
80109d7f:	75 10                	jne    80109d91 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109d81:	83 ec 0c             	sub    $0xc,%esp
80109d84:	ff 75 08             	pushl  0x8(%ebp)
80109d87:	e8 a7 00 00 00       	call   80109e33 <icmp_proc>
80109d8c:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109d8f:	eb 19                	jmp    80109daa <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d94:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109d98:	3c 06                	cmp    $0x6,%al
80109d9a:	75 0e                	jne    80109daa <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109d9c:	83 ec 0c             	sub    $0xc,%esp
80109d9f:	ff 75 08             	pushl  0x8(%ebp)
80109da2:	e8 c7 03 00 00       	call   8010a16e <tcp_proc>
80109da7:	83 c4 10             	add    $0x10,%esp
}
80109daa:	90                   	nop
80109dab:	c9                   	leave  
80109dac:	c3                   	ret    

80109dad <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109dad:	f3 0f 1e fb          	endbr32 
80109db1:	55                   	push   %ebp
80109db2:	89 e5                	mov    %esp,%ebp
80109db4:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109db7:	8b 45 08             	mov    0x8(%ebp),%eax
80109dba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dc0:	0f b6 00             	movzbl (%eax),%eax
80109dc3:	83 e0 0f             	and    $0xf,%eax
80109dc6:	01 c0                	add    %eax,%eax
80109dc8:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109dcb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109dd2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109dd9:	eb 48                	jmp    80109e23 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109ddb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109dde:	01 c0                	add    %eax,%eax
80109de0:	89 c2                	mov    %eax,%edx
80109de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109de5:	01 d0                	add    %edx,%eax
80109de7:	0f b6 00             	movzbl (%eax),%eax
80109dea:	0f b6 c0             	movzbl %al,%eax
80109ded:	c1 e0 08             	shl    $0x8,%eax
80109df0:	89 c2                	mov    %eax,%edx
80109df2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109df5:	01 c0                	add    %eax,%eax
80109df7:	8d 48 01             	lea    0x1(%eax),%ecx
80109dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dfd:	01 c8                	add    %ecx,%eax
80109dff:	0f b6 00             	movzbl (%eax),%eax
80109e02:	0f b6 c0             	movzbl %al,%eax
80109e05:	01 d0                	add    %edx,%eax
80109e07:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109e0a:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109e11:	76 0c                	jbe    80109e1f <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109e13:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e16:	0f b7 c0             	movzwl %ax,%eax
80109e19:	83 c0 01             	add    $0x1,%eax
80109e1c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109e1f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109e23:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109e27:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109e2a:	7c af                	jl     80109ddb <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109e2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109e2f:	f7 d0                	not    %eax
}
80109e31:	c9                   	leave  
80109e32:	c3                   	ret    

80109e33 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109e33:	f3 0f 1e fb          	endbr32 
80109e37:	55                   	push   %ebp
80109e38:	89 e5                	mov    %esp,%ebp
80109e3a:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80109e40:	83 c0 0e             	add    $0xe,%eax
80109e43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e49:	0f b6 00             	movzbl (%eax),%eax
80109e4c:	0f b6 c0             	movzbl %al,%eax
80109e4f:	83 e0 0f             	and    $0xf,%eax
80109e52:	c1 e0 02             	shl    $0x2,%eax
80109e55:	89 c2                	mov    %eax,%edx
80109e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e5a:	01 d0                	add    %edx,%eax
80109e5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e62:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109e66:	84 c0                	test   %al,%al
80109e68:	75 4f                	jne    80109eb9 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e6d:	0f b6 00             	movzbl (%eax),%eax
80109e70:	3c 08                	cmp    $0x8,%al
80109e72:	75 45                	jne    80109eb9 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109e74:	e8 19 8a ff ff       	call   80102892 <kalloc>
80109e79:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109e7c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109e83:	83 ec 04             	sub    $0x4,%esp
80109e86:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109e89:	50                   	push   %eax
80109e8a:	ff 75 ec             	pushl  -0x14(%ebp)
80109e8d:	ff 75 08             	pushl  0x8(%ebp)
80109e90:	e8 7c 00 00 00       	call   80109f11 <icmp_reply_pkt_create>
80109e95:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109e98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e9b:	83 ec 08             	sub    $0x8,%esp
80109e9e:	50                   	push   %eax
80109e9f:	ff 75 ec             	pushl  -0x14(%ebp)
80109ea2:	e8 43 f4 ff ff       	call   801092ea <i8254_send>
80109ea7:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ead:	83 ec 0c             	sub    $0xc,%esp
80109eb0:	50                   	push   %eax
80109eb1:	e8 3e 89 ff ff       	call   801027f4 <kfree>
80109eb6:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109eb9:	90                   	nop
80109eba:	c9                   	leave  
80109ebb:	c3                   	ret    

80109ebc <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109ebc:	f3 0f 1e fb          	endbr32 
80109ec0:	55                   	push   %ebp
80109ec1:	89 e5                	mov    %esp,%ebp
80109ec3:	53                   	push   %ebx
80109ec4:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80109eca:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109ece:	0f b7 c0             	movzwl %ax,%eax
80109ed1:	83 ec 0c             	sub    $0xc,%esp
80109ed4:	50                   	push   %eax
80109ed5:	e8 9d fd ff ff       	call   80109c77 <N2H_ushort>
80109eda:	83 c4 10             	add    $0x10,%esp
80109edd:	0f b7 d8             	movzwl %ax,%ebx
80109ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ee3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109ee7:	0f b7 c0             	movzwl %ax,%eax
80109eea:	83 ec 0c             	sub    $0xc,%esp
80109eed:	50                   	push   %eax
80109eee:	e8 84 fd ff ff       	call   80109c77 <N2H_ushort>
80109ef3:	83 c4 10             	add    $0x10,%esp
80109ef6:	0f b7 c0             	movzwl %ax,%eax
80109ef9:	83 ec 04             	sub    $0x4,%esp
80109efc:	53                   	push   %ebx
80109efd:	50                   	push   %eax
80109efe:	68 83 c8 10 80       	push   $0x8010c883
80109f03:	e8 04 65 ff ff       	call   8010040c <cprintf>
80109f08:	83 c4 10             	add    $0x10,%esp
}
80109f0b:	90                   	nop
80109f0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109f0f:	c9                   	leave  
80109f10:	c3                   	ret    

80109f11 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109f11:	f3 0f 1e fb          	endbr32 
80109f15:	55                   	push   %ebp
80109f16:	89 e5                	mov    %esp,%ebp
80109f18:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109f21:	8b 45 08             	mov    0x8(%ebp),%eax
80109f24:	83 c0 0e             	add    $0xe,%eax
80109f27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109f2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f2d:	0f b6 00             	movzbl (%eax),%eax
80109f30:	0f b6 c0             	movzbl %al,%eax
80109f33:	83 e0 0f             	and    $0xf,%eax
80109f36:	c1 e0 02             	shl    $0x2,%eax
80109f39:	89 c2                	mov    %eax,%edx
80109f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f3e:	01 d0                	add    %edx,%eax
80109f40:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109f43:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f46:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109f49:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f4c:	83 c0 0e             	add    $0xe,%eax
80109f4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109f52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109f55:	83 c0 14             	add    $0x14,%eax
80109f58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109f5b:	8b 45 10             	mov    0x10(%ebp),%eax
80109f5e:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f67:	8d 50 06             	lea    0x6(%eax),%edx
80109f6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f6d:	83 ec 04             	sub    $0x4,%esp
80109f70:	6a 06                	push   $0x6
80109f72:	52                   	push   %edx
80109f73:	50                   	push   %eax
80109f74:	e8 fd b0 ff ff       	call   80105076 <memmove>
80109f79:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109f7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f7f:	83 c0 06             	add    $0x6,%eax
80109f82:	83 ec 04             	sub    $0x4,%esp
80109f85:	6a 06                	push   $0x6
80109f87:	68 68 d0 18 80       	push   $0x8018d068
80109f8c:	50                   	push   %eax
80109f8d:	e8 e4 b0 ff ff       	call   80105076 <memmove>
80109f92:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109f95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f98:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109f9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f9f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109fa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fa6:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109fa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fac:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109fb0:	83 ec 0c             	sub    $0xc,%esp
80109fb3:	6a 54                	push   $0x54
80109fb5:	e8 e3 fc ff ff       	call   80109c9d <H2N_ushort>
80109fba:	83 c4 10             	add    $0x10,%esp
80109fbd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109fc0:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109fc4:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
80109fcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109fce:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109fd2:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
80109fd9:	83 c0 01             	add    $0x1,%eax
80109fdc:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
80109fe2:	83 ec 0c             	sub    $0xc,%esp
80109fe5:	68 00 40 00 00       	push   $0x4000
80109fea:	e8 ae fc ff ff       	call   80109c9d <H2N_ushort>
80109fef:	83 c4 10             	add    $0x10,%esp
80109ff2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ff5:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109ff9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ffc:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a000:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a003:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a007:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a00a:	83 c0 0c             	add    $0xc,%eax
8010a00d:	83 ec 04             	sub    $0x4,%esp
8010a010:	6a 04                	push   $0x4
8010a012:	68 04 f5 10 80       	push   $0x8010f504
8010a017:	50                   	push   %eax
8010a018:	e8 59 b0 ff ff       	call   80105076 <memmove>
8010a01d:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a020:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a023:	8d 50 0c             	lea    0xc(%eax),%edx
8010a026:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a029:	83 c0 10             	add    $0x10,%eax
8010a02c:	83 ec 04             	sub    $0x4,%esp
8010a02f:	6a 04                	push   $0x4
8010a031:	52                   	push   %edx
8010a032:	50                   	push   %eax
8010a033:	e8 3e b0 ff ff       	call   80105076 <memmove>
8010a038:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a03b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a03e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a044:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a047:	83 ec 0c             	sub    $0xc,%esp
8010a04a:	50                   	push   %eax
8010a04b:	e8 5d fd ff ff       	call   80109dad <ipv4_chksum>
8010a050:	83 c4 10             	add    $0x10,%esp
8010a053:	0f b7 c0             	movzwl %ax,%eax
8010a056:	83 ec 0c             	sub    $0xc,%esp
8010a059:	50                   	push   %eax
8010a05a:	e8 3e fc ff ff       	call   80109c9d <H2N_ushort>
8010a05f:	83 c4 10             	add    $0x10,%esp
8010a062:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a065:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a069:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a06c:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a06f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a072:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a076:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a079:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a07d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a080:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a084:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a087:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a08b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a08e:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a092:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a095:	8d 50 08             	lea    0x8(%eax),%edx
8010a098:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a09b:	83 c0 08             	add    $0x8,%eax
8010a09e:	83 ec 04             	sub    $0x4,%esp
8010a0a1:	6a 08                	push   $0x8
8010a0a3:	52                   	push   %edx
8010a0a4:	50                   	push   %eax
8010a0a5:	e8 cc af ff ff       	call   80105076 <memmove>
8010a0aa:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a0ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0b0:	8d 50 10             	lea    0x10(%eax),%edx
8010a0b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0b6:	83 c0 10             	add    $0x10,%eax
8010a0b9:	83 ec 04             	sub    $0x4,%esp
8010a0bc:	6a 30                	push   $0x30
8010a0be:	52                   	push   %edx
8010a0bf:	50                   	push   %eax
8010a0c0:	e8 b1 af ff ff       	call   80105076 <memmove>
8010a0c5:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a0c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0cb:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a0d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a0d4:	83 ec 0c             	sub    $0xc,%esp
8010a0d7:	50                   	push   %eax
8010a0d8:	e8 1c 00 00 00       	call   8010a0f9 <icmp_chksum>
8010a0dd:	83 c4 10             	add    $0x10,%esp
8010a0e0:	0f b7 c0             	movzwl %ax,%eax
8010a0e3:	83 ec 0c             	sub    $0xc,%esp
8010a0e6:	50                   	push   %eax
8010a0e7:	e8 b1 fb ff ff       	call   80109c9d <H2N_ushort>
8010a0ec:	83 c4 10             	add    $0x10,%esp
8010a0ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a0f2:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a0f6:	90                   	nop
8010a0f7:	c9                   	leave  
8010a0f8:	c3                   	ret    

8010a0f9 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a0f9:	f3 0f 1e fb          	endbr32 
8010a0fd:	55                   	push   %ebp
8010a0fe:	89 e5                	mov    %esp,%ebp
8010a100:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a103:	8b 45 08             	mov    0x8(%ebp),%eax
8010a106:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a109:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a110:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a117:	eb 48                	jmp    8010a161 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a119:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a11c:	01 c0                	add    %eax,%eax
8010a11e:	89 c2                	mov    %eax,%edx
8010a120:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a123:	01 d0                	add    %edx,%eax
8010a125:	0f b6 00             	movzbl (%eax),%eax
8010a128:	0f b6 c0             	movzbl %al,%eax
8010a12b:	c1 e0 08             	shl    $0x8,%eax
8010a12e:	89 c2                	mov    %eax,%edx
8010a130:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a133:	01 c0                	add    %eax,%eax
8010a135:	8d 48 01             	lea    0x1(%eax),%ecx
8010a138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a13b:	01 c8                	add    %ecx,%eax
8010a13d:	0f b6 00             	movzbl (%eax),%eax
8010a140:	0f b6 c0             	movzbl %al,%eax
8010a143:	01 d0                	add    %edx,%eax
8010a145:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a148:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a14f:	76 0c                	jbe    8010a15d <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a151:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a154:	0f b7 c0             	movzwl %ax,%eax
8010a157:	83 c0 01             	add    $0x1,%eax
8010a15a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a15d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a161:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a165:	7e b2                	jle    8010a119 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a167:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a16a:	f7 d0                	not    %eax
}
8010a16c:	c9                   	leave  
8010a16d:	c3                   	ret    

8010a16e <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a16e:	f3 0f 1e fb          	endbr32 
8010a172:	55                   	push   %ebp
8010a173:	89 e5                	mov    %esp,%ebp
8010a175:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a178:	8b 45 08             	mov    0x8(%ebp),%eax
8010a17b:	83 c0 0e             	add    $0xe,%eax
8010a17e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a181:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a184:	0f b6 00             	movzbl (%eax),%eax
8010a187:	0f b6 c0             	movzbl %al,%eax
8010a18a:	83 e0 0f             	and    $0xf,%eax
8010a18d:	c1 e0 02             	shl    $0x2,%eax
8010a190:	89 c2                	mov    %eax,%edx
8010a192:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a195:	01 d0                	add    %edx,%eax
8010a197:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a19a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a19d:	83 c0 14             	add    $0x14,%eax
8010a1a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a1a3:	e8 ea 86 ff ff       	call   80102892 <kalloc>
8010a1a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a1ab:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a1b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1b5:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a1b9:	0f b6 c0             	movzbl %al,%eax
8010a1bc:	83 e0 02             	and    $0x2,%eax
8010a1bf:	85 c0                	test   %eax,%eax
8010a1c1:	74 3d                	je     8010a200 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a1c3:	83 ec 0c             	sub    $0xc,%esp
8010a1c6:	6a 00                	push   $0x0
8010a1c8:	6a 12                	push   $0x12
8010a1ca:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a1cd:	50                   	push   %eax
8010a1ce:	ff 75 e8             	pushl  -0x18(%ebp)
8010a1d1:	ff 75 08             	pushl  0x8(%ebp)
8010a1d4:	e8 a2 01 00 00       	call   8010a37b <tcp_pkt_create>
8010a1d9:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a1dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a1df:	83 ec 08             	sub    $0x8,%esp
8010a1e2:	50                   	push   %eax
8010a1e3:	ff 75 e8             	pushl  -0x18(%ebp)
8010a1e6:	e8 ff f0 ff ff       	call   801092ea <i8254_send>
8010a1eb:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a1ee:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a1f3:	83 c0 01             	add    $0x1,%eax
8010a1f6:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a1fb:	e9 69 01 00 00       	jmp    8010a369 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a200:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a203:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a207:	3c 18                	cmp    $0x18,%al
8010a209:	0f 85 10 01 00 00    	jne    8010a31f <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a20f:	83 ec 04             	sub    $0x4,%esp
8010a212:	6a 03                	push   $0x3
8010a214:	68 9e c8 10 80       	push   $0x8010c89e
8010a219:	ff 75 ec             	pushl  -0x14(%ebp)
8010a21c:	e8 f9 ad ff ff       	call   8010501a <memcmp>
8010a221:	83 c4 10             	add    $0x10,%esp
8010a224:	85 c0                	test   %eax,%eax
8010a226:	74 74                	je     8010a29c <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a228:	83 ec 0c             	sub    $0xc,%esp
8010a22b:	68 a2 c8 10 80       	push   $0x8010c8a2
8010a230:	e8 d7 61 ff ff       	call   8010040c <cprintf>
8010a235:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a238:	83 ec 0c             	sub    $0xc,%esp
8010a23b:	6a 00                	push   $0x0
8010a23d:	6a 10                	push   $0x10
8010a23f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a242:	50                   	push   %eax
8010a243:	ff 75 e8             	pushl  -0x18(%ebp)
8010a246:	ff 75 08             	pushl  0x8(%ebp)
8010a249:	e8 2d 01 00 00       	call   8010a37b <tcp_pkt_create>
8010a24e:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a251:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a254:	83 ec 08             	sub    $0x8,%esp
8010a257:	50                   	push   %eax
8010a258:	ff 75 e8             	pushl  -0x18(%ebp)
8010a25b:	e8 8a f0 ff ff       	call   801092ea <i8254_send>
8010a260:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a263:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a266:	83 c0 36             	add    $0x36,%eax
8010a269:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a26c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a26f:	50                   	push   %eax
8010a270:	ff 75 e0             	pushl  -0x20(%ebp)
8010a273:	6a 00                	push   $0x0
8010a275:	6a 00                	push   $0x0
8010a277:	e8 66 04 00 00       	call   8010a6e2 <http_proc>
8010a27c:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a27f:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a282:	83 ec 0c             	sub    $0xc,%esp
8010a285:	50                   	push   %eax
8010a286:	6a 18                	push   $0x18
8010a288:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a28b:	50                   	push   %eax
8010a28c:	ff 75 e8             	pushl  -0x18(%ebp)
8010a28f:	ff 75 08             	pushl  0x8(%ebp)
8010a292:	e8 e4 00 00 00       	call   8010a37b <tcp_pkt_create>
8010a297:	83 c4 20             	add    $0x20,%esp
8010a29a:	eb 62                	jmp    8010a2fe <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a29c:	83 ec 0c             	sub    $0xc,%esp
8010a29f:	6a 00                	push   $0x0
8010a2a1:	6a 10                	push   $0x10
8010a2a3:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a2a6:	50                   	push   %eax
8010a2a7:	ff 75 e8             	pushl  -0x18(%ebp)
8010a2aa:	ff 75 08             	pushl  0x8(%ebp)
8010a2ad:	e8 c9 00 00 00       	call   8010a37b <tcp_pkt_create>
8010a2b2:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a2b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a2b8:	83 ec 08             	sub    $0x8,%esp
8010a2bb:	50                   	push   %eax
8010a2bc:	ff 75 e8             	pushl  -0x18(%ebp)
8010a2bf:	e8 26 f0 ff ff       	call   801092ea <i8254_send>
8010a2c4:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a2c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2ca:	83 c0 36             	add    $0x36,%eax
8010a2cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a2d0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a2d3:	50                   	push   %eax
8010a2d4:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a2d7:	6a 00                	push   $0x0
8010a2d9:	6a 00                	push   $0x0
8010a2db:	e8 02 04 00 00       	call   8010a6e2 <http_proc>
8010a2e0:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a2e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a2e6:	83 ec 0c             	sub    $0xc,%esp
8010a2e9:	50                   	push   %eax
8010a2ea:	6a 18                	push   $0x18
8010a2ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a2ef:	50                   	push   %eax
8010a2f0:	ff 75 e8             	pushl  -0x18(%ebp)
8010a2f3:	ff 75 08             	pushl  0x8(%ebp)
8010a2f6:	e8 80 00 00 00       	call   8010a37b <tcp_pkt_create>
8010a2fb:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a2fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a301:	83 ec 08             	sub    $0x8,%esp
8010a304:	50                   	push   %eax
8010a305:	ff 75 e8             	pushl  -0x18(%ebp)
8010a308:	e8 dd ef ff ff       	call   801092ea <i8254_send>
8010a30d:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a310:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a315:	83 c0 01             	add    $0x1,%eax
8010a318:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a31d:	eb 4a                	jmp    8010a369 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a31f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a322:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a326:	3c 10                	cmp    $0x10,%al
8010a328:	75 3f                	jne    8010a369 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a32a:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a32f:	83 f8 01             	cmp    $0x1,%eax
8010a332:	75 35                	jne    8010a369 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a334:	83 ec 0c             	sub    $0xc,%esp
8010a337:	6a 00                	push   $0x0
8010a339:	6a 01                	push   $0x1
8010a33b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a33e:	50                   	push   %eax
8010a33f:	ff 75 e8             	pushl  -0x18(%ebp)
8010a342:	ff 75 08             	pushl  0x8(%ebp)
8010a345:	e8 31 00 00 00       	call   8010a37b <tcp_pkt_create>
8010a34a:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a34d:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a350:	83 ec 08             	sub    $0x8,%esp
8010a353:	50                   	push   %eax
8010a354:	ff 75 e8             	pushl  -0x18(%ebp)
8010a357:	e8 8e ef ff ff       	call   801092ea <i8254_send>
8010a35c:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a35f:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a366:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a369:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a36c:	83 ec 0c             	sub    $0xc,%esp
8010a36f:	50                   	push   %eax
8010a370:	e8 7f 84 ff ff       	call   801027f4 <kfree>
8010a375:	83 c4 10             	add    $0x10,%esp
}
8010a378:	90                   	nop
8010a379:	c9                   	leave  
8010a37a:	c3                   	ret    

8010a37b <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a37b:	f3 0f 1e fb          	endbr32 
8010a37f:	55                   	push   %ebp
8010a380:	89 e5                	mov    %esp,%ebp
8010a382:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a385:	8b 45 08             	mov    0x8(%ebp),%eax
8010a388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a38b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a38e:	83 c0 0e             	add    $0xe,%eax
8010a391:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a394:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a397:	0f b6 00             	movzbl (%eax),%eax
8010a39a:	0f b6 c0             	movzbl %al,%eax
8010a39d:	83 e0 0f             	and    $0xf,%eax
8010a3a0:	c1 e0 02             	shl    $0x2,%eax
8010a3a3:	89 c2                	mov    %eax,%edx
8010a3a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3a8:	01 d0                	add    %edx,%eax
8010a3aa:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a3ad:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a3b3:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3b6:	83 c0 0e             	add    $0xe,%eax
8010a3b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a3bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a3bf:	83 c0 14             	add    $0x14,%eax
8010a3c2:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a3c5:	8b 45 18             	mov    0x18(%ebp),%eax
8010a3c8:	8d 50 36             	lea    0x36(%eax),%edx
8010a3cb:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3ce:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a3d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3d3:	8d 50 06             	lea    0x6(%eax),%edx
8010a3d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3d9:	83 ec 04             	sub    $0x4,%esp
8010a3dc:	6a 06                	push   $0x6
8010a3de:	52                   	push   %edx
8010a3df:	50                   	push   %eax
8010a3e0:	e8 91 ac ff ff       	call   80105076 <memmove>
8010a3e5:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a3e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3eb:	83 c0 06             	add    $0x6,%eax
8010a3ee:	83 ec 04             	sub    $0x4,%esp
8010a3f1:	6a 06                	push   $0x6
8010a3f3:	68 68 d0 18 80       	push   $0x8018d068
8010a3f8:	50                   	push   %eax
8010a3f9:	e8 78 ac ff ff       	call   80105076 <memmove>
8010a3fe:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a401:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a404:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a408:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a40b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a40f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a412:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a415:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a418:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a41c:	8b 45 18             	mov    0x18(%ebp),%eax
8010a41f:	83 c0 28             	add    $0x28,%eax
8010a422:	0f b7 c0             	movzwl %ax,%eax
8010a425:	83 ec 0c             	sub    $0xc,%esp
8010a428:	50                   	push   %eax
8010a429:	e8 6f f8 ff ff       	call   80109c9d <H2N_ushort>
8010a42e:	83 c4 10             	add    $0x10,%esp
8010a431:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a434:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a438:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a43f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a442:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a446:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a44d:	83 c0 01             	add    $0x1,%eax
8010a450:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a456:	83 ec 0c             	sub    $0xc,%esp
8010a459:	6a 00                	push   $0x0
8010a45b:	e8 3d f8 ff ff       	call   80109c9d <H2N_ushort>
8010a460:	83 c4 10             	add    $0x10,%esp
8010a463:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a466:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a46a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a46d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a471:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a474:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a478:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a47b:	83 c0 0c             	add    $0xc,%eax
8010a47e:	83 ec 04             	sub    $0x4,%esp
8010a481:	6a 04                	push   $0x4
8010a483:	68 04 f5 10 80       	push   $0x8010f504
8010a488:	50                   	push   %eax
8010a489:	e8 e8 ab ff ff       	call   80105076 <memmove>
8010a48e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a491:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a494:	8d 50 0c             	lea    0xc(%eax),%edx
8010a497:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a49a:	83 c0 10             	add    $0x10,%eax
8010a49d:	83 ec 04             	sub    $0x4,%esp
8010a4a0:	6a 04                	push   $0x4
8010a4a2:	52                   	push   %edx
8010a4a3:	50                   	push   %eax
8010a4a4:	e8 cd ab ff ff       	call   80105076 <memmove>
8010a4a9:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a4ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4af:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a4b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4b8:	83 ec 0c             	sub    $0xc,%esp
8010a4bb:	50                   	push   %eax
8010a4bc:	e8 ec f8 ff ff       	call   80109dad <ipv4_chksum>
8010a4c1:	83 c4 10             	add    $0x10,%esp
8010a4c4:	0f b7 c0             	movzwl %ax,%eax
8010a4c7:	83 ec 0c             	sub    $0xc,%esp
8010a4ca:	50                   	push   %eax
8010a4cb:	e8 cd f7 ff ff       	call   80109c9d <H2N_ushort>
8010a4d0:	83 c4 10             	add    $0x10,%esp
8010a4d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4d6:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a4da:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4dd:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a4e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4e4:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a4e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a4ea:	0f b7 10             	movzwl (%eax),%edx
8010a4ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a4f0:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a4f4:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a4f9:	83 ec 0c             	sub    $0xc,%esp
8010a4fc:	50                   	push   %eax
8010a4fd:	e8 c1 f7 ff ff       	call   80109cc3 <H2N_uint>
8010a502:	83 c4 10             	add    $0x10,%esp
8010a505:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a508:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a50b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a50e:	8b 40 04             	mov    0x4(%eax),%eax
8010a511:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a517:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a51a:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a51d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a520:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a524:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a527:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a52b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a52e:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a532:	8b 45 14             	mov    0x14(%ebp),%eax
8010a535:	89 c2                	mov    %eax,%edx
8010a537:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a53a:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a53d:	83 ec 0c             	sub    $0xc,%esp
8010a540:	68 90 38 00 00       	push   $0x3890
8010a545:	e8 53 f7 ff ff       	call   80109c9d <H2N_ushort>
8010a54a:	83 c4 10             	add    $0x10,%esp
8010a54d:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a550:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a554:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a557:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a55d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a560:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a566:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a569:	83 ec 0c             	sub    $0xc,%esp
8010a56c:	50                   	push   %eax
8010a56d:	e8 1f 00 00 00       	call   8010a591 <tcp_chksum>
8010a572:	83 c4 10             	add    $0x10,%esp
8010a575:	83 c0 08             	add    $0x8,%eax
8010a578:	0f b7 c0             	movzwl %ax,%eax
8010a57b:	83 ec 0c             	sub    $0xc,%esp
8010a57e:	50                   	push   %eax
8010a57f:	e8 19 f7 ff ff       	call   80109c9d <H2N_ushort>
8010a584:	83 c4 10             	add    $0x10,%esp
8010a587:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a58a:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a58e:	90                   	nop
8010a58f:	c9                   	leave  
8010a590:	c3                   	ret    

8010a591 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a591:	f3 0f 1e fb          	endbr32 
8010a595:	55                   	push   %ebp
8010a596:	89 e5                	mov    %esp,%ebp
8010a598:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a59b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a59e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a5a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5a4:	83 c0 14             	add    $0x14,%eax
8010a5a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a5aa:	83 ec 04             	sub    $0x4,%esp
8010a5ad:	6a 04                	push   $0x4
8010a5af:	68 04 f5 10 80       	push   $0x8010f504
8010a5b4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a5b7:	50                   	push   %eax
8010a5b8:	e8 b9 aa ff ff       	call   80105076 <memmove>
8010a5bd:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a5c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5c3:	83 c0 0c             	add    $0xc,%eax
8010a5c6:	83 ec 04             	sub    $0x4,%esp
8010a5c9:	6a 04                	push   $0x4
8010a5cb:	50                   	push   %eax
8010a5cc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a5cf:	83 c0 04             	add    $0x4,%eax
8010a5d2:	50                   	push   %eax
8010a5d3:	e8 9e aa ff ff       	call   80105076 <memmove>
8010a5d8:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a5db:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a5df:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a5e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5e6:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a5ea:	0f b7 c0             	movzwl %ax,%eax
8010a5ed:	83 ec 0c             	sub    $0xc,%esp
8010a5f0:	50                   	push   %eax
8010a5f1:	e8 81 f6 ff ff       	call   80109c77 <N2H_ushort>
8010a5f6:	83 c4 10             	add    $0x10,%esp
8010a5f9:	83 e8 14             	sub    $0x14,%eax
8010a5fc:	0f b7 c0             	movzwl %ax,%eax
8010a5ff:	83 ec 0c             	sub    $0xc,%esp
8010a602:	50                   	push   %eax
8010a603:	e8 95 f6 ff ff       	call   80109c9d <H2N_ushort>
8010a608:	83 c4 10             	add    $0x10,%esp
8010a60b:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a60f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a616:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a619:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a61c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a623:	eb 33                	jmp    8010a658 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a625:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a628:	01 c0                	add    %eax,%eax
8010a62a:	89 c2                	mov    %eax,%edx
8010a62c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a62f:	01 d0                	add    %edx,%eax
8010a631:	0f b6 00             	movzbl (%eax),%eax
8010a634:	0f b6 c0             	movzbl %al,%eax
8010a637:	c1 e0 08             	shl    $0x8,%eax
8010a63a:	89 c2                	mov    %eax,%edx
8010a63c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a63f:	01 c0                	add    %eax,%eax
8010a641:	8d 48 01             	lea    0x1(%eax),%ecx
8010a644:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a647:	01 c8                	add    %ecx,%eax
8010a649:	0f b6 00             	movzbl (%eax),%eax
8010a64c:	0f b6 c0             	movzbl %al,%eax
8010a64f:	01 d0                	add    %edx,%eax
8010a651:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a654:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a658:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a65c:	7e c7                	jle    8010a625 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a65e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a661:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a664:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a66b:	eb 33                	jmp    8010a6a0 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a66d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a670:	01 c0                	add    %eax,%eax
8010a672:	89 c2                	mov    %eax,%edx
8010a674:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a677:	01 d0                	add    %edx,%eax
8010a679:	0f b6 00             	movzbl (%eax),%eax
8010a67c:	0f b6 c0             	movzbl %al,%eax
8010a67f:	c1 e0 08             	shl    $0x8,%eax
8010a682:	89 c2                	mov    %eax,%edx
8010a684:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a687:	01 c0                	add    %eax,%eax
8010a689:	8d 48 01             	lea    0x1(%eax),%ecx
8010a68c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a68f:	01 c8                	add    %ecx,%eax
8010a691:	0f b6 00             	movzbl (%eax),%eax
8010a694:	0f b6 c0             	movzbl %al,%eax
8010a697:	01 d0                	add    %edx,%eax
8010a699:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a69c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a6a0:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a6a4:	0f b7 c0             	movzwl %ax,%eax
8010a6a7:	83 ec 0c             	sub    $0xc,%esp
8010a6aa:	50                   	push   %eax
8010a6ab:	e8 c7 f5 ff ff       	call   80109c77 <N2H_ushort>
8010a6b0:	83 c4 10             	add    $0x10,%esp
8010a6b3:	66 d1 e8             	shr    %ax
8010a6b6:	0f b7 c0             	movzwl %ax,%eax
8010a6b9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a6bc:	7c af                	jl     8010a66d <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a6be:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a6c1:	c1 e8 10             	shr    $0x10,%eax
8010a6c4:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a6c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a6ca:	f7 d0                	not    %eax
}
8010a6cc:	c9                   	leave  
8010a6cd:	c3                   	ret    

8010a6ce <tcp_fin>:

void tcp_fin(){
8010a6ce:	f3 0f 1e fb          	endbr32 
8010a6d2:	55                   	push   %ebp
8010a6d3:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a6d5:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a6dc:	00 00 00 
}
8010a6df:	90                   	nop
8010a6e0:	5d                   	pop    %ebp
8010a6e1:	c3                   	ret    

8010a6e2 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a6e2:	f3 0f 1e fb          	endbr32 
8010a6e6:	55                   	push   %ebp
8010a6e7:	89 e5                	mov    %esp,%ebp
8010a6e9:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a6ec:	8b 45 10             	mov    0x10(%ebp),%eax
8010a6ef:	83 ec 04             	sub    $0x4,%esp
8010a6f2:	6a 00                	push   $0x0
8010a6f4:	68 ab c8 10 80       	push   $0x8010c8ab
8010a6f9:	50                   	push   %eax
8010a6fa:	e8 65 00 00 00       	call   8010a764 <http_strcpy>
8010a6ff:	83 c4 10             	add    $0x10,%esp
8010a702:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a705:	8b 45 10             	mov    0x10(%ebp),%eax
8010a708:	83 ec 04             	sub    $0x4,%esp
8010a70b:	ff 75 f4             	pushl  -0xc(%ebp)
8010a70e:	68 be c8 10 80       	push   $0x8010c8be
8010a713:	50                   	push   %eax
8010a714:	e8 4b 00 00 00       	call   8010a764 <http_strcpy>
8010a719:	83 c4 10             	add    $0x10,%esp
8010a71c:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a71f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a722:	83 ec 04             	sub    $0x4,%esp
8010a725:	ff 75 f4             	pushl  -0xc(%ebp)
8010a728:	68 d9 c8 10 80       	push   $0x8010c8d9
8010a72d:	50                   	push   %eax
8010a72e:	e8 31 00 00 00       	call   8010a764 <http_strcpy>
8010a733:	83 c4 10             	add    $0x10,%esp
8010a736:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a73c:	83 e0 01             	and    $0x1,%eax
8010a73f:	85 c0                	test   %eax,%eax
8010a741:	74 11                	je     8010a754 <http_proc+0x72>
    char *payload = (char *)send;
8010a743:	8b 45 10             	mov    0x10(%ebp),%eax
8010a746:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a749:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a74c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a74f:	01 d0                	add    %edx,%eax
8010a751:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a754:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a757:	8b 45 14             	mov    0x14(%ebp),%eax
8010a75a:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a75c:	e8 6d ff ff ff       	call   8010a6ce <tcp_fin>
}
8010a761:	90                   	nop
8010a762:	c9                   	leave  
8010a763:	c3                   	ret    

8010a764 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a764:	f3 0f 1e fb          	endbr32 
8010a768:	55                   	push   %ebp
8010a769:	89 e5                	mov    %esp,%ebp
8010a76b:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a76e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a775:	eb 20                	jmp    8010a797 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a777:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a77a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a77d:	01 d0                	add    %edx,%eax
8010a77f:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a782:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a785:	01 ca                	add    %ecx,%edx
8010a787:	89 d1                	mov    %edx,%ecx
8010a789:	8b 55 08             	mov    0x8(%ebp),%edx
8010a78c:	01 ca                	add    %ecx,%edx
8010a78e:	0f b6 00             	movzbl (%eax),%eax
8010a791:	88 02                	mov    %al,(%edx)
    i++;
8010a793:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a797:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a79a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a79d:	01 d0                	add    %edx,%eax
8010a79f:	0f b6 00             	movzbl (%eax),%eax
8010a7a2:	84 c0                	test   %al,%al
8010a7a4:	75 d1                	jne    8010a777 <http_strcpy+0x13>
  }
  return i;
8010a7a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a7a9:	c9                   	leave  
8010a7aa:	c3                   	ret    

8010a7ab <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a7ab:	f3 0f 1e fb          	endbr32 
8010a7af:	55                   	push   %ebp
8010a7b0:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a7b2:	c7 05 50 d3 18 80 c2 	movl   $0x8010f5c2,0x8018d350
8010a7b9:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a7bc:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a7c1:	c1 e8 09             	shr    $0x9,%eax
8010a7c4:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a7c9:	90                   	nop
8010a7ca:	5d                   	pop    %ebp
8010a7cb:	c3                   	ret    

8010a7cc <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a7cc:	f3 0f 1e fb          	endbr32 
8010a7d0:	55                   	push   %ebp
8010a7d1:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a7d3:	90                   	nop
8010a7d4:	5d                   	pop    %ebp
8010a7d5:	c3                   	ret    

8010a7d6 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a7d6:	f3 0f 1e fb          	endbr32 
8010a7da:	55                   	push   %ebp
8010a7db:	89 e5                	mov    %esp,%ebp
8010a7dd:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a7e0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a7e3:	83 c0 0c             	add    $0xc,%eax
8010a7e6:	83 ec 0c             	sub    $0xc,%esp
8010a7e9:	50                   	push   %eax
8010a7ea:	e8 98 a4 ff ff       	call   80104c87 <holdingsleep>
8010a7ef:	83 c4 10             	add    $0x10,%esp
8010a7f2:	85 c0                	test   %eax,%eax
8010a7f4:	75 0d                	jne    8010a803 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a7f6:	83 ec 0c             	sub    $0xc,%esp
8010a7f9:	68 ea c8 10 80       	push   $0x8010c8ea
8010a7fe:	e8 c2 5d ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a803:	8b 45 08             	mov    0x8(%ebp),%eax
8010a806:	8b 00                	mov    (%eax),%eax
8010a808:	83 e0 06             	and    $0x6,%eax
8010a80b:	83 f8 02             	cmp    $0x2,%eax
8010a80e:	75 0d                	jne    8010a81d <iderw+0x47>
    panic("iderw: nothing to do");
8010a810:	83 ec 0c             	sub    $0xc,%esp
8010a813:	68 00 c9 10 80       	push   $0x8010c900
8010a818:	e8 a8 5d ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a81d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a820:	8b 40 04             	mov    0x4(%eax),%eax
8010a823:	83 f8 01             	cmp    $0x1,%eax
8010a826:	74 0d                	je     8010a835 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a828:	83 ec 0c             	sub    $0xc,%esp
8010a82b:	68 15 c9 10 80       	push   $0x8010c915
8010a830:	e8 90 5d ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a835:	8b 45 08             	mov    0x8(%ebp),%eax
8010a838:	8b 40 08             	mov    0x8(%eax),%eax
8010a83b:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a841:	39 d0                	cmp    %edx,%eax
8010a843:	72 0d                	jb     8010a852 <iderw+0x7c>
    panic("iderw: block out of range");
8010a845:	83 ec 0c             	sub    $0xc,%esp
8010a848:	68 33 c9 10 80       	push   $0x8010c933
8010a84d:	e8 73 5d ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a852:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a858:	8b 45 08             	mov    0x8(%ebp),%eax
8010a85b:	8b 40 08             	mov    0x8(%eax),%eax
8010a85e:	c1 e0 09             	shl    $0x9,%eax
8010a861:	01 d0                	add    %edx,%eax
8010a863:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a866:	8b 45 08             	mov    0x8(%ebp),%eax
8010a869:	8b 00                	mov    (%eax),%eax
8010a86b:	83 e0 04             	and    $0x4,%eax
8010a86e:	85 c0                	test   %eax,%eax
8010a870:	74 2b                	je     8010a89d <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a872:	8b 45 08             	mov    0x8(%ebp),%eax
8010a875:	8b 00                	mov    (%eax),%eax
8010a877:	83 e0 fb             	and    $0xfffffffb,%eax
8010a87a:	89 c2                	mov    %eax,%edx
8010a87c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a87f:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a881:	8b 45 08             	mov    0x8(%ebp),%eax
8010a884:	83 c0 5c             	add    $0x5c,%eax
8010a887:	83 ec 04             	sub    $0x4,%esp
8010a88a:	68 00 02 00 00       	push   $0x200
8010a88f:	50                   	push   %eax
8010a890:	ff 75 f4             	pushl  -0xc(%ebp)
8010a893:	e8 de a7 ff ff       	call   80105076 <memmove>
8010a898:	83 c4 10             	add    $0x10,%esp
8010a89b:	eb 1a                	jmp    8010a8b7 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a89d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8a0:	83 c0 5c             	add    $0x5c,%eax
8010a8a3:	83 ec 04             	sub    $0x4,%esp
8010a8a6:	68 00 02 00 00       	push   $0x200
8010a8ab:	ff 75 f4             	pushl  -0xc(%ebp)
8010a8ae:	50                   	push   %eax
8010a8af:	e8 c2 a7 ff ff       	call   80105076 <memmove>
8010a8b4:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a8b7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8ba:	8b 00                	mov    (%eax),%eax
8010a8bc:	83 c8 02             	or     $0x2,%eax
8010a8bf:	89 c2                	mov    %eax,%edx
8010a8c1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8c4:	89 10                	mov    %edx,(%eax)
}
8010a8c6:	90                   	nop
8010a8c7:	c9                   	leave  
8010a8c8:	c3                   	ret    
