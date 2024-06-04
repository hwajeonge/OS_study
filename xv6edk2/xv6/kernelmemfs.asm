
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
8010005f:	ba a0 34 10 80       	mov    $0x801034a0,%edx
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
80100073:	68 c0 a9 10 80       	push   $0x8010a9c0
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 34 4c 00 00       	call   80104cb6 <initlock>
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
801000c1:	68 c7 a9 10 80       	push   $0x8010a9c7
801000c6:	50                   	push   %eax
801000c7:	e8 7d 4a 00 00       	call   80104b49 <initsleeplock>
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
80100109:	e8 ce 4b 00 00       	call   80104cdc <acquire>
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
80100148:	e8 01 4c 00 00       	call   80104d4e <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 2a 4a 00 00       	call   80104b89 <acquiresleep>
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
801001c9:	e8 80 4b 00 00       	call   80104d4e <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 a9 49 00 00       	call   80104b89 <acquiresleep>
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
801001fd:	68 ce a9 10 80       	push   $0x8010a9ce
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
80100239:	e8 88 a6 00 00       	call   8010a8c6 <iderw>
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
8010025a:	e8 e4 49 00 00       	call   80104c43 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 df a9 10 80       	push   $0x8010a9df
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
80100288:	e8 39 a6 00 00       	call   8010a8c6 <iderw>
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
801002a7:	e8 97 49 00 00       	call   80104c43 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 e6 a9 10 80       	push   $0x8010a9e6
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 22 49 00 00       	call   80104bf1 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 fd 49 00 00       	call   80104cdc <acquire>
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
8010034a:	e8 ff 49 00 00       	call   80104d4e <release>
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
8010042c:	e8 ab 48 00 00       	call   80104cdc <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 ed a9 10 80       	push   $0x8010a9ed
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
8010052c:	c7 45 ec f6 a9 10 80 	movl   $0x8010a9f6,-0x14(%ebp)
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
801005ba:	e8 8f 47 00 00       	call   80104d4e <release>
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
801005de:	e8 0e 26 00 00       	call   80102bf1 <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 fd a9 10 80       	push   $0x8010a9fd
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
80100606:	68 11 aa 10 80       	push   $0x8010aa11
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 81 47 00 00       	call   80104da4 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 13 aa 10 80       	push   $0x8010aa13
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
801006c4:	e8 91 80 00 00       	call   8010875a <graphic_scroll_up>
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
80100717:	e8 3e 80 00 00       	call   8010875a <graphic_scroll_up>
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
8010077d:	e8 4c 80 00 00       	call   801087ce <font_render>
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
801007bd:	e8 ca 62 00 00       	call   80106a8c <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 bd 62 00 00       	call   80106a8c <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 b0 62 00 00       	call   80106a8c <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 a0 62 00 00       	call   80106a8c <uartputc>
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
80100819:	e8 be 44 00 00       	call   80104cdc <acquire>
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
8010096f:	e8 b0 3e 00 00       	call   80104824 <wakeup>
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
80100992:	e8 b7 43 00 00       	call   80104d4e <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 45 3f 00 00       	call   801048ea <procdump>
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
801009b8:	e8 c8 11 00 00       	call   80101b85 <iunlock>
801009bd:	83 c4 10             	add    $0x10,%esp
  target = n;
801009c0:	8b 45 10             	mov    0x10(%ebp),%eax
801009c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	68 20 d0 18 80       	push   $0x8018d020
801009ce:	e8 09 43 00 00       	call   80104cdc <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 bb 31 00 00       	call   80103b9b <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 d0 18 80       	push   $0x8018d020
801009ef:	e8 5a 43 00 00       	call   80104d4e <release>
801009f4:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	pushl  0x8(%ebp)
801009fd:	e8 6c 10 00 00       	call   80101a6e <ilock>
80100a02:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a0a:	e9 ab 00 00 00       	jmp    80100aba <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a0f:	83 ec 08             	sub    $0x8,%esp
80100a12:	68 20 d0 18 80       	push   $0x8018d020
80100a17:	68 40 2d 19 80       	push   $0x80192d40
80100a1c:	e8 11 3d 00 00       	call   80104732 <sleep>
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
80100a9a:	e8 af 42 00 00       	call   80104d4e <release>
80100a9f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aa2:	83 ec 0c             	sub    $0xc,%esp
80100aa5:	ff 75 08             	pushl  0x8(%ebp)
80100aa8:	e8 c1 0f 00 00       	call   80101a6e <ilock>
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
80100acc:	e8 b4 10 00 00       	call   80101b85 <iunlock>
80100ad1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ad4:	83 ec 0c             	sub    $0xc,%esp
80100ad7:	68 20 d0 18 80       	push   $0x8018d020
80100adc:	e8 fb 41 00 00       	call   80104cdc <acquire>
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
80100b1e:	e8 2b 42 00 00       	call   80104d4e <release>
80100b23:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b26:	83 ec 0c             	sub    $0xc,%esp
80100b29:	ff 75 08             	pushl  0x8(%ebp)
80100b2c:	e8 3d 0f 00 00       	call   80101a6e <ilock>
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
80100b50:	68 17 aa 10 80       	push   $0x8010aa17
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 57 41 00 00       	call   80104cb6 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 1f aa 10 80 	movl   $0x8010aa1f,-0xc(%ebp)
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
80100bb3:	e8 46 1b 00 00       	call   801026fe <ioapicenable>
80100bb8:	83 c4 10             	add    $0x10,%esp
}
80100bbb:	90                   	nop
80100bbc:	c9                   	leave  
80100bbd:	c3                   	ret    

80100bbe <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char* path, char** argv)
{
80100bbe:	f3 0f 1e fb          	endbr32 
80100bc2:	55                   	push   %ebp
80100bc3:	89 e5                	mov    %esp,%ebp
80100bc5:	81 ec 18 01 00 00    	sub    $0x118,%esp
    uint argc, sz, sp, ustack[3 + MAXARG + 1];
    struct elfhdr elf;
    struct inode* ip;
    struct proghdr ph;
    pde_t* pgdir, * oldpgdir;
    struct proc* curproc = myproc();
80100bcb:	e8 cb 2f 00 00       	call   80103b9b <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

    begin_op();
80100bd3:	e8 8b 25 00 00       	call   80103163 <begin_op>

    if ((ip = namei(path)) == 0) {
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	pushl  0x8(%ebp)
80100bde:	e8 f6 19 00 00       	call   801025d9 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
        end_op();
80100bef:	e8 ff 25 00 00       	call   801031f3 <end_op>
        cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 35 aa 10 80       	push   $0x8010aa35
80100bfc:	e8 0b f8 ff ff       	call   8010040c <cprintf>
80100c01:	83 c4 10             	add    $0x10,%esp
        return -1;
80100c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c09:	e9 e3 03 00 00       	jmp    80100ff1 <exec+0x433>
    }
    ilock(ip);
80100c0e:	83 ec 0c             	sub    $0xc,%esp
80100c11:	ff 75 d8             	pushl  -0x28(%ebp)
80100c14:	e8 55 0e 00 00       	call   80101a6e <ilock>
80100c19:	83 c4 10             	add    $0x10,%esp
    pgdir = 0;
80100c1c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

    // Check ELF header
    if (readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c23:	6a 34                	push   $0x34
80100c25:	6a 00                	push   $0x0
80100c27:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c2d:	50                   	push   %eax
80100c2e:	ff 75 d8             	pushl  -0x28(%ebp)
80100c31:	e8 40 13 00 00       	call   80101f76 <readi>
80100c36:	83 c4 10             	add    $0x10,%esp
80100c39:	83 f8 34             	cmp    $0x34,%eax
80100c3c:	0f 85 58 03 00 00    	jne    80100f9a <exec+0x3dc>
        goto bad;
    if (elf.magic != ELF_MAGIC)
80100c42:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c48:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4d:	0f 85 4a 03 00 00    	jne    80100f9d <exec+0x3df>
        goto bad;

    if ((pgdir = setupkvm()) == 0)
80100c53:	e8 48 6e 00 00       	call   80107aa0 <setupkvm>
80100c58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c5f:	0f 84 3b 03 00 00    	je     80100fa0 <exec+0x3e2>
        goto bad;

    // Load program into memory.
    sz = 0;
80100c65:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
80100c6c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c73:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c79:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c7c:	e9 de 00 00 00       	jmp    80100d5f <exec+0x1a1>
        if (readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c84:	6a 20                	push   $0x20
80100c86:	50                   	push   %eax
80100c87:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c8d:	50                   	push   %eax
80100c8e:	ff 75 d8             	pushl  -0x28(%ebp)
80100c91:	e8 e0 12 00 00       	call   80101f76 <readi>
80100c96:	83 c4 10             	add    $0x10,%esp
80100c99:	83 f8 20             	cmp    $0x20,%eax
80100c9c:	0f 85 01 03 00 00    	jne    80100fa3 <exec+0x3e5>
            goto bad;
        if (ph.type != ELF_PROG_LOAD)
80100ca2:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ca8:	83 f8 01             	cmp    $0x1,%eax
80100cab:	0f 85 a0 00 00 00    	jne    80100d51 <exec+0x193>
            continue;
        if (ph.memsz < ph.filesz)
80100cb1:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb7:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cbd:	39 c2                	cmp    %eax,%edx
80100cbf:	0f 82 e1 02 00 00    	jb     80100fa6 <exec+0x3e8>
            goto bad;
        if (ph.vaddr + ph.memsz < ph.vaddr)
80100cc5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd1:	01 c2                	add    %eax,%edx
80100cd3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd9:	39 c2                	cmp    %eax,%edx
80100cdb:	0f 82 c8 02 00 00    	jb     80100fa9 <exec+0x3eb>
            goto bad;
        if ((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce1:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ced:	01 d0                	add    %edx,%eax
80100cef:	83 ec 04             	sub    $0x4,%esp
80100cf2:	50                   	push   %eax
80100cf3:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf9:	e8 b4 71 00 00       	call   80107eb2 <allocuvm>
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d08:	0f 84 9e 02 00 00    	je     80100fac <exec+0x3ee>
            goto bad;
        if (ph.vaddr % PGSIZE != 0)
80100d0e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d14:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d19:	85 c0                	test   %eax,%eax
80100d1b:	0f 85 8e 02 00 00    	jne    80100faf <exec+0x3f1>
            goto bad;
        if (loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d21:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d27:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d2d:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d33:	83 ec 0c             	sub    $0xc,%esp
80100d36:	52                   	push   %edx
80100d37:	50                   	push   %eax
80100d38:	ff 75 d8             	pushl  -0x28(%ebp)
80100d3b:	51                   	push   %ecx
80100d3c:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d3f:	e8 9d 70 00 00       	call   80107de1 <loaduvm>
80100d44:	83 c4 20             	add    $0x20,%esp
80100d47:	85 c0                	test   %eax,%eax
80100d49:	0f 88 63 02 00 00    	js     80100fb2 <exec+0x3f4>
80100d4f:	eb 01                	jmp    80100d52 <exec+0x194>
            continue;
80100d51:	90                   	nop
    for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
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
80100d78:	e8 2e 0f 00 00       	call   80101cab <iunlockput>
80100d7d:	83 c4 10             	add    $0x10,%esp
    end_op();
80100d80:	e8 6e 24 00 00       	call   801031f3 <end_op>
    ip = 0;
80100d85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

    // Allocate two pages at the next page boundary.
    // Make the first inaccessible.  Use the second as the user stack.
    sz = PGROUNDUP(sz);
80100d8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8f:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d99:	89 45 e0             	mov    %eax,-0x20(%ebp)
    // if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    //   goto bad;
    // clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
    // sp = sz;
    sp = TOPBASE;
80100d9c:	c7 45 dc ff ff ff 7f 	movl   $0x7fffffff,-0x24(%ebp)
    if ((allocuvm(pgdir, sp - PGSIZE, sp)) == 0)
80100da3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da6:	2d 00 10 00 00       	sub    $0x1000,%eax
80100dab:	83 ec 04             	sub    $0x4,%esp
80100dae:	ff 75 dc             	pushl  -0x24(%ebp)
80100db1:	50                   	push   %eax
80100db2:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db5:	e8 f8 70 00 00       	call   80107eb2 <allocuvm>
80100dba:	83 c4 10             	add    $0x10,%esp
80100dbd:	85 c0                	test   %eax,%eax
80100dbf:	0f 84 f0 01 00 00    	je     80100fb5 <exec+0x3f7>
        goto bad;
    curproc->stack_alloc = 1;             //PART2
80100dc5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dc8:	c7 80 80 00 00 00 01 	movl   $0x1,0x80(%eax)
80100dcf:	00 00 00 

    // Push argument strings, prepare rest of stack in ustack.
    for (argc = 0; argv[argc]; argc++) {
80100dd2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100dd9:	e9 96 00 00 00       	jmp    80100e74 <exec+0x2b6>
        if (argc >= MAXARG)
80100dde:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100de2:	0f 87 d0 01 00 00    	ja     80100fb8 <exec+0x3fa>
            goto bad;
        sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100de8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100deb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df5:	01 d0                	add    %edx,%eax
80100df7:	8b 00                	mov    (%eax),%eax
80100df9:	83 ec 0c             	sub    $0xc,%esp
80100dfc:	50                   	push   %eax
80100dfd:	e8 d2 43 00 00       	call   801051d4 <strlen>
80100e02:	83 c4 10             	add    $0x10,%esp
80100e05:	89 c2                	mov    %eax,%edx
80100e07:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e0a:	29 d0                	sub    %edx,%eax
80100e0c:	83 e8 01             	sub    $0x1,%eax
80100e0f:	83 e0 fc             	and    $0xfffffffc,%eax
80100e12:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e18:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e22:	01 d0                	add    %edx,%eax
80100e24:	8b 00                	mov    (%eax),%eax
80100e26:	83 ec 0c             	sub    $0xc,%esp
80100e29:	50                   	push   %eax
80100e2a:	e8 a5 43 00 00       	call   801051d4 <strlen>
80100e2f:	83 c4 10             	add    $0x10,%esp
80100e32:	83 c0 01             	add    $0x1,%eax
80100e35:	89 c1                	mov    %eax,%ecx
80100e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e41:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e44:	01 d0                	add    %edx,%eax
80100e46:	8b 00                	mov    (%eax),%eax
80100e48:	51                   	push   %ecx
80100e49:	50                   	push   %eax
80100e4a:	ff 75 dc             	pushl  -0x24(%ebp)
80100e4d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e50:	e8 58 75 00 00       	call   801083ad <copyout>
80100e55:	83 c4 10             	add    $0x10,%esp
80100e58:	85 c0                	test   %eax,%eax
80100e5a:	0f 88 5b 01 00 00    	js     80100fbb <exec+0x3fd>
            goto bad;
        ustack[3 + argc] = sp;
80100e60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e63:	8d 50 03             	lea    0x3(%eax),%edx
80100e66:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e69:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    for (argc = 0; argv[argc]; argc++) {
80100e70:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e81:	01 d0                	add    %edx,%eax
80100e83:	8b 00                	mov    (%eax),%eax
80100e85:	85 c0                	test   %eax,%eax
80100e87:	0f 85 51 ff ff ff    	jne    80100dde <exec+0x220>
    }
    ustack[3 + argc] = 0;
80100e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e90:	83 c0 03             	add    $0x3,%eax
80100e93:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e9a:	00 00 00 00 

    ustack[0] = 0xffffffff;  // fake return PC
80100e9e:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100ea5:	ff ff ff 
    ustack[1] = argc;
80100ea8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eab:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
    ustack[2] = sp - (argc + 1) * 4;  // argv pointer
80100eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb4:	83 c0 01             	add    $0x1,%eax
80100eb7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ebe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ec1:	29 d0                	sub    %edx,%eax
80100ec3:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

    sp -= (3 + argc + 1) * 4;
80100ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ecc:	83 c0 04             	add    $0x4,%eax
80100ecf:	c1 e0 02             	shl    $0x2,%eax
80100ed2:	29 45 dc             	sub    %eax,-0x24(%ebp)
    if (copyout(pgdir, sp, ustack, (3 + argc + 1) * 4) < 0)
80100ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed8:	83 c0 04             	add    $0x4,%eax
80100edb:	c1 e0 02             	shl    $0x2,%eax
80100ede:	50                   	push   %eax
80100edf:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ee5:	50                   	push   %eax
80100ee6:	ff 75 dc             	pushl  -0x24(%ebp)
80100ee9:	ff 75 d4             	pushl  -0x2c(%ebp)
80100eec:	e8 bc 74 00 00       	call   801083ad <copyout>
80100ef1:	83 c4 10             	add    $0x10,%esp
80100ef4:	85 c0                	test   %eax,%eax
80100ef6:	0f 88 c2 00 00 00    	js     80100fbe <exec+0x400>
        goto bad;

    // Save program name for debugging.
    for (last = s = path; *s; s++)
80100efc:	8b 45 08             	mov    0x8(%ebp),%eax
80100eff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f05:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f08:	eb 17                	jmp    80100f21 <exec+0x363>
        if (*s == '/')
80100f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f0d:	0f b6 00             	movzbl (%eax),%eax
80100f10:	3c 2f                	cmp    $0x2f,%al
80100f12:	75 09                	jne    80100f1d <exec+0x35f>
            last = s + 1;
80100f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f17:	83 c0 01             	add    $0x1,%eax
80100f1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (last = s = path; *s; s++)
80100f1d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f24:	0f b6 00             	movzbl (%eax),%eax
80100f27:	84 c0                	test   %al,%al
80100f29:	75 df                	jne    80100f0a <exec+0x34c>
    safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f2b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2e:	83 c0 6c             	add    $0x6c,%eax
80100f31:	83 ec 04             	sub    $0x4,%esp
80100f34:	6a 10                	push   $0x10
80100f36:	ff 75 f0             	pushl  -0x10(%ebp)
80100f39:	50                   	push   %eax
80100f3a:	e8 47 42 00 00       	call   80105186 <safestrcpy>
80100f3f:	83 c4 10             	add    $0x10,%esp

    // Commit to the user image.
    oldpgdir = curproc->pgdir;
80100f42:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f45:	8b 40 04             	mov    0x4(%eax),%eax
80100f48:	89 45 cc             	mov    %eax,-0x34(%ebp)
    curproc->pgdir = pgdir;
80100f4b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f4e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f51:	89 50 04             	mov    %edx,0x4(%eax)
    curproc->sz = sz;
80100f54:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f57:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f5a:	89 10                	mov    %edx,(%eax)
    curproc->tf->eip = elf.entry;  // main
80100f5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5f:	8b 40 18             	mov    0x18(%eax),%eax
80100f62:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f68:	89 50 38             	mov    %edx,0x38(%eax)
    curproc->tf->esp = sp;
80100f6b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6e:	8b 40 18             	mov    0x18(%eax),%eax
80100f71:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f74:	89 50 44             	mov    %edx,0x44(%eax)
    switchuvm(curproc);
80100f77:	83 ec 0c             	sub    $0xc,%esp
80100f7a:	ff 75 d0             	pushl  -0x30(%ebp)
80100f7d:	e8 48 6c 00 00       	call   80107bca <switchuvm>
80100f82:	83 c4 10             	add    $0x10,%esp
    freevm(oldpgdir);
80100f85:	83 ec 0c             	sub    $0xc,%esp
80100f88:	ff 75 cc             	pushl  -0x34(%ebp)
80100f8b:	e8 f3 70 00 00       	call   80108083 <freevm>
80100f90:	83 c4 10             	add    $0x10,%esp
    return 0;
80100f93:	b8 00 00 00 00       	mov    $0x0,%eax
80100f98:	eb 57                	jmp    80100ff1 <exec+0x433>
        goto bad;
80100f9a:	90                   	nop
80100f9b:	eb 22                	jmp    80100fbf <exec+0x401>
        goto bad;
80100f9d:	90                   	nop
80100f9e:	eb 1f                	jmp    80100fbf <exec+0x401>
        goto bad;
80100fa0:	90                   	nop
80100fa1:	eb 1c                	jmp    80100fbf <exec+0x401>
            goto bad;
80100fa3:	90                   	nop
80100fa4:	eb 19                	jmp    80100fbf <exec+0x401>
            goto bad;
80100fa6:	90                   	nop
80100fa7:	eb 16                	jmp    80100fbf <exec+0x401>
            goto bad;
80100fa9:	90                   	nop
80100faa:	eb 13                	jmp    80100fbf <exec+0x401>
            goto bad;
80100fac:	90                   	nop
80100fad:	eb 10                	jmp    80100fbf <exec+0x401>
            goto bad;
80100faf:	90                   	nop
80100fb0:	eb 0d                	jmp    80100fbf <exec+0x401>
            goto bad;
80100fb2:	90                   	nop
80100fb3:	eb 0a                	jmp    80100fbf <exec+0x401>
        goto bad;
80100fb5:	90                   	nop
80100fb6:	eb 07                	jmp    80100fbf <exec+0x401>
            goto bad;
80100fb8:	90                   	nop
80100fb9:	eb 04                	jmp    80100fbf <exec+0x401>
            goto bad;
80100fbb:	90                   	nop
80100fbc:	eb 01                	jmp    80100fbf <exec+0x401>
        goto bad;
80100fbe:	90                   	nop

bad:
    if (pgdir)
80100fbf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fc3:	74 0e                	je     80100fd3 <exec+0x415>
        freevm(pgdir);
80100fc5:	83 ec 0c             	sub    $0xc,%esp
80100fc8:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fcb:	e8 b3 70 00 00       	call   80108083 <freevm>
80100fd0:	83 c4 10             	add    $0x10,%esp
    if (ip) {
80100fd3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fd7:	74 13                	je     80100fec <exec+0x42e>
        iunlockput(ip);
80100fd9:	83 ec 0c             	sub    $0xc,%esp
80100fdc:	ff 75 d8             	pushl  -0x28(%ebp)
80100fdf:	e8 c7 0c 00 00       	call   80101cab <iunlockput>
80100fe4:	83 c4 10             	add    $0x10,%esp
        end_op();
80100fe7:	e8 07 22 00 00       	call   801031f3 <end_op>
    }
    return -1;
80100fec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ff1:	c9                   	leave  
80100ff2:	c3                   	ret    

80100ff3 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100ff3:	f3 0f 1e fb          	endbr32 
80100ff7:	55                   	push   %ebp
80100ff8:	89 e5                	mov    %esp,%ebp
80100ffa:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100ffd:	83 ec 08             	sub    $0x8,%esp
80101000:	68 41 aa 10 80       	push   $0x8010aa41
80101005:	68 60 2d 19 80       	push   $0x80192d60
8010100a:	e8 a7 3c 00 00       	call   80104cb6 <initlock>
8010100f:	83 c4 10             	add    $0x10,%esp
}
80101012:	90                   	nop
80101013:	c9                   	leave  
80101014:	c3                   	ret    

80101015 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101015:	f3 0f 1e fb          	endbr32 
80101019:	55                   	push   %ebp
8010101a:	89 e5                	mov    %esp,%ebp
8010101c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010101f:	83 ec 0c             	sub    $0xc,%esp
80101022:	68 60 2d 19 80       	push   $0x80192d60
80101027:	e8 b0 3c 00 00       	call   80104cdc <acquire>
8010102c:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102f:	c7 45 f4 94 2d 19 80 	movl   $0x80192d94,-0xc(%ebp)
80101036:	eb 2d                	jmp    80101065 <filealloc+0x50>
    if(f->ref == 0){
80101038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010103b:	8b 40 04             	mov    0x4(%eax),%eax
8010103e:	85 c0                	test   %eax,%eax
80101040:	75 1f                	jne    80101061 <filealloc+0x4c>
      f->ref = 1;
80101042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101045:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010104c:	83 ec 0c             	sub    $0xc,%esp
8010104f:	68 60 2d 19 80       	push   $0x80192d60
80101054:	e8 f5 3c 00 00       	call   80104d4e <release>
80101059:	83 c4 10             	add    $0x10,%esp
      return f;
8010105c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010105f:	eb 23                	jmp    80101084 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101061:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101065:	b8 f4 36 19 80       	mov    $0x801936f4,%eax
8010106a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010106d:	72 c9                	jb     80101038 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010106f:	83 ec 0c             	sub    $0xc,%esp
80101072:	68 60 2d 19 80       	push   $0x80192d60
80101077:	e8 d2 3c 00 00       	call   80104d4e <release>
8010107c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010107f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101084:	c9                   	leave  
80101085:	c3                   	ret    

80101086 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101086:	f3 0f 1e fb          	endbr32 
8010108a:	55                   	push   %ebp
8010108b:	89 e5                	mov    %esp,%ebp
8010108d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	68 60 2d 19 80       	push   $0x80192d60
80101098:	e8 3f 3c 00 00       	call   80104cdc <acquire>
8010109d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
801010a3:	8b 40 04             	mov    0x4(%eax),%eax
801010a6:	85 c0                	test   %eax,%eax
801010a8:	7f 0d                	jg     801010b7 <filedup+0x31>
    panic("filedup");
801010aa:	83 ec 0c             	sub    $0xc,%esp
801010ad:	68 48 aa 10 80       	push   $0x8010aa48
801010b2:	e8 0e f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010b7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ba:	8b 40 04             	mov    0x4(%eax),%eax
801010bd:	8d 50 01             	lea    0x1(%eax),%edx
801010c0:	8b 45 08             	mov    0x8(%ebp),%eax
801010c3:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010c6:	83 ec 0c             	sub    $0xc,%esp
801010c9:	68 60 2d 19 80       	push   $0x80192d60
801010ce:	e8 7b 3c 00 00       	call   80104d4e <release>
801010d3:	83 c4 10             	add    $0x10,%esp
  return f;
801010d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010d9:	c9                   	leave  
801010da:	c3                   	ret    

801010db <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010db:	f3 0f 1e fb          	endbr32 
801010df:	55                   	push   %ebp
801010e0:	89 e5                	mov    %esp,%ebp
801010e2:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010e5:	83 ec 0c             	sub    $0xc,%esp
801010e8:	68 60 2d 19 80       	push   $0x80192d60
801010ed:	e8 ea 3b 00 00       	call   80104cdc <acquire>
801010f2:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	8b 40 04             	mov    0x4(%eax),%eax
801010fb:	85 c0                	test   %eax,%eax
801010fd:	7f 0d                	jg     8010110c <fileclose+0x31>
    panic("fileclose");
801010ff:	83 ec 0c             	sub    $0xc,%esp
80101102:	68 50 aa 10 80       	push   $0x8010aa50
80101107:	e8 b9 f4 ff ff       	call   801005c5 <panic>
  if(--f->ref > 0){
8010110c:	8b 45 08             	mov    0x8(%ebp),%eax
8010110f:	8b 40 04             	mov    0x4(%eax),%eax
80101112:	8d 50 ff             	lea    -0x1(%eax),%edx
80101115:	8b 45 08             	mov    0x8(%ebp),%eax
80101118:	89 50 04             	mov    %edx,0x4(%eax)
8010111b:	8b 45 08             	mov    0x8(%ebp),%eax
8010111e:	8b 40 04             	mov    0x4(%eax),%eax
80101121:	85 c0                	test   %eax,%eax
80101123:	7e 15                	jle    8010113a <fileclose+0x5f>
    release(&ftable.lock);
80101125:	83 ec 0c             	sub    $0xc,%esp
80101128:	68 60 2d 19 80       	push   $0x80192d60
8010112d:	e8 1c 3c 00 00       	call   80104d4e <release>
80101132:	83 c4 10             	add    $0x10,%esp
80101135:	e9 8b 00 00 00       	jmp    801011c5 <fileclose+0xea>
    return;
  }
  ff = *f;
8010113a:	8b 45 08             	mov    0x8(%ebp),%eax
8010113d:	8b 10                	mov    (%eax),%edx
8010113f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101142:	8b 50 04             	mov    0x4(%eax),%edx
80101145:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101148:	8b 50 08             	mov    0x8(%eax),%edx
8010114b:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010114e:	8b 50 0c             	mov    0xc(%eax),%edx
80101151:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101154:	8b 50 10             	mov    0x10(%eax),%edx
80101157:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010115a:	8b 40 14             	mov    0x14(%eax),%eax
8010115d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101160:	8b 45 08             	mov    0x8(%ebp),%eax
80101163:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010116a:	8b 45 08             	mov    0x8(%ebp),%eax
8010116d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101173:	83 ec 0c             	sub    $0xc,%esp
80101176:	68 60 2d 19 80       	push   $0x80192d60
8010117b:	e8 ce 3b 00 00       	call   80104d4e <release>
80101180:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101183:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101186:	83 f8 01             	cmp    $0x1,%eax
80101189:	75 19                	jne    801011a4 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
8010118b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010118f:	0f be d0             	movsbl %al,%edx
80101192:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101195:	83 ec 08             	sub    $0x8,%esp
80101198:	52                   	push   %edx
80101199:	50                   	push   %eax
8010119a:	e8 73 26 00 00       	call   80103812 <pipeclose>
8010119f:	83 c4 10             	add    $0x10,%esp
801011a2:	eb 21                	jmp    801011c5 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011a7:	83 f8 02             	cmp    $0x2,%eax
801011aa:	75 19                	jne    801011c5 <fileclose+0xea>
    begin_op();
801011ac:	e8 b2 1f 00 00       	call   80103163 <begin_op>
    iput(ff.ip);
801011b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011b4:	83 ec 0c             	sub    $0xc,%esp
801011b7:	50                   	push   %eax
801011b8:	e8 1a 0a 00 00       	call   80101bd7 <iput>
801011bd:	83 c4 10             	add    $0x10,%esp
    end_op();
801011c0:	e8 2e 20 00 00       	call   801031f3 <end_op>
  }
}
801011c5:	c9                   	leave  
801011c6:	c3                   	ret    

801011c7 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011c7:	f3 0f 1e fb          	endbr32 
801011cb:	55                   	push   %ebp
801011cc:	89 e5                	mov    %esp,%ebp
801011ce:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011d1:	8b 45 08             	mov    0x8(%ebp),%eax
801011d4:	8b 00                	mov    (%eax),%eax
801011d6:	83 f8 02             	cmp    $0x2,%eax
801011d9:	75 40                	jne    8010121b <filestat+0x54>
    ilock(f->ip);
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	8b 40 10             	mov    0x10(%eax),%eax
801011e1:	83 ec 0c             	sub    $0xc,%esp
801011e4:	50                   	push   %eax
801011e5:	e8 84 08 00 00       	call   80101a6e <ilock>
801011ea:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011ed:	8b 45 08             	mov    0x8(%ebp),%eax
801011f0:	8b 40 10             	mov    0x10(%eax),%eax
801011f3:	83 ec 08             	sub    $0x8,%esp
801011f6:	ff 75 0c             	pushl  0xc(%ebp)
801011f9:	50                   	push   %eax
801011fa:	e8 2d 0d 00 00       	call   80101f2c <stati>
801011ff:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101202:	8b 45 08             	mov    0x8(%ebp),%eax
80101205:	8b 40 10             	mov    0x10(%eax),%eax
80101208:	83 ec 0c             	sub    $0xc,%esp
8010120b:	50                   	push   %eax
8010120c:	e8 74 09 00 00       	call   80101b85 <iunlock>
80101211:	83 c4 10             	add    $0x10,%esp
    return 0;
80101214:	b8 00 00 00 00       	mov    $0x0,%eax
80101219:	eb 05                	jmp    80101220 <filestat+0x59>
  }
  return -1;
8010121b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101220:	c9                   	leave  
80101221:	c3                   	ret    

80101222 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101222:	f3 0f 1e fb          	endbr32 
80101226:	55                   	push   %ebp
80101227:	89 e5                	mov    %esp,%ebp
80101229:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010122c:	8b 45 08             	mov    0x8(%ebp),%eax
8010122f:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101233:	84 c0                	test   %al,%al
80101235:	75 0a                	jne    80101241 <fileread+0x1f>
    return -1;
80101237:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010123c:	e9 9b 00 00 00       	jmp    801012dc <fileread+0xba>
  if(f->type == FD_PIPE)
80101241:	8b 45 08             	mov    0x8(%ebp),%eax
80101244:	8b 00                	mov    (%eax),%eax
80101246:	83 f8 01             	cmp    $0x1,%eax
80101249:	75 1a                	jne    80101265 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010124b:	8b 45 08             	mov    0x8(%ebp),%eax
8010124e:	8b 40 0c             	mov    0xc(%eax),%eax
80101251:	83 ec 04             	sub    $0x4,%esp
80101254:	ff 75 10             	pushl  0x10(%ebp)
80101257:	ff 75 0c             	pushl  0xc(%ebp)
8010125a:	50                   	push   %eax
8010125b:	e8 67 27 00 00       	call   801039c7 <piperead>
80101260:	83 c4 10             	add    $0x10,%esp
80101263:	eb 77                	jmp    801012dc <fileread+0xba>
  if(f->type == FD_INODE){
80101265:	8b 45 08             	mov    0x8(%ebp),%eax
80101268:	8b 00                	mov    (%eax),%eax
8010126a:	83 f8 02             	cmp    $0x2,%eax
8010126d:	75 60                	jne    801012cf <fileread+0xad>
    ilock(f->ip);
8010126f:	8b 45 08             	mov    0x8(%ebp),%eax
80101272:	8b 40 10             	mov    0x10(%eax),%eax
80101275:	83 ec 0c             	sub    $0xc,%esp
80101278:	50                   	push   %eax
80101279:	e8 f0 07 00 00       	call   80101a6e <ilock>
8010127e:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101281:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	8b 50 14             	mov    0x14(%eax),%edx
8010128a:	8b 45 08             	mov    0x8(%ebp),%eax
8010128d:	8b 40 10             	mov    0x10(%eax),%eax
80101290:	51                   	push   %ecx
80101291:	52                   	push   %edx
80101292:	ff 75 0c             	pushl  0xc(%ebp)
80101295:	50                   	push   %eax
80101296:	e8 db 0c 00 00       	call   80101f76 <readi>
8010129b:	83 c4 10             	add    $0x10,%esp
8010129e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012a5:	7e 11                	jle    801012b8 <fileread+0x96>
      f->off += r;
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	8b 50 14             	mov    0x14(%eax),%edx
801012ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b0:	01 c2                	add    %eax,%edx
801012b2:	8b 45 08             	mov    0x8(%ebp),%eax
801012b5:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 10             	mov    0x10(%eax),%eax
801012be:	83 ec 0c             	sub    $0xc,%esp
801012c1:	50                   	push   %eax
801012c2:	e8 be 08 00 00       	call   80101b85 <iunlock>
801012c7:	83 c4 10             	add    $0x10,%esp
    return r;
801012ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012cd:	eb 0d                	jmp    801012dc <fileread+0xba>
  }
  panic("fileread");
801012cf:	83 ec 0c             	sub    $0xc,%esp
801012d2:	68 5a aa 10 80       	push   $0x8010aa5a
801012d7:	e8 e9 f2 ff ff       	call   801005c5 <panic>
}
801012dc:	c9                   	leave  
801012dd:	c3                   	ret    

801012de <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012de:	f3 0f 1e fb          	endbr32 
801012e2:	55                   	push   %ebp
801012e3:	89 e5                	mov    %esp,%ebp
801012e5:	53                   	push   %ebx
801012e6:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012e9:	8b 45 08             	mov    0x8(%ebp),%eax
801012ec:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012f0:	84 c0                	test   %al,%al
801012f2:	75 0a                	jne    801012fe <filewrite+0x20>
    return -1;
801012f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f9:	e9 1b 01 00 00       	jmp    80101419 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801012fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101301:	8b 00                	mov    (%eax),%eax
80101303:	83 f8 01             	cmp    $0x1,%eax
80101306:	75 1d                	jne    80101325 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101308:	8b 45 08             	mov    0x8(%ebp),%eax
8010130b:	8b 40 0c             	mov    0xc(%eax),%eax
8010130e:	83 ec 04             	sub    $0x4,%esp
80101311:	ff 75 10             	pushl  0x10(%ebp)
80101314:	ff 75 0c             	pushl  0xc(%ebp)
80101317:	50                   	push   %eax
80101318:	e8 a4 25 00 00       	call   801038c1 <pipewrite>
8010131d:	83 c4 10             	add    $0x10,%esp
80101320:	e9 f4 00 00 00       	jmp    80101419 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101325:	8b 45 08             	mov    0x8(%ebp),%eax
80101328:	8b 00                	mov    (%eax),%eax
8010132a:	83 f8 02             	cmp    $0x2,%eax
8010132d:	0f 85 d9 00 00 00    	jne    8010140c <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101333:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
8010133a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101341:	e9 a3 00 00 00       	jmp    801013e9 <filewrite+0x10b>
      int n1 = n - i;
80101346:	8b 45 10             	mov    0x10(%ebp),%eax
80101349:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010134c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010134f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101352:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101355:	7e 06                	jle    8010135d <filewrite+0x7f>
        n1 = max;
80101357:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010135a:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010135d:	e8 01 1e 00 00       	call   80103163 <begin_op>
      ilock(f->ip);
80101362:	8b 45 08             	mov    0x8(%ebp),%eax
80101365:	8b 40 10             	mov    0x10(%eax),%eax
80101368:	83 ec 0c             	sub    $0xc,%esp
8010136b:	50                   	push   %eax
8010136c:	e8 fd 06 00 00       	call   80101a6e <ilock>
80101371:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101374:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101377:	8b 45 08             	mov    0x8(%ebp),%eax
8010137a:	8b 50 14             	mov    0x14(%eax),%edx
8010137d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101380:	8b 45 0c             	mov    0xc(%ebp),%eax
80101383:	01 c3                	add    %eax,%ebx
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	8b 40 10             	mov    0x10(%eax),%eax
8010138b:	51                   	push   %ecx
8010138c:	52                   	push   %edx
8010138d:	53                   	push   %ebx
8010138e:	50                   	push   %eax
8010138f:	e8 3b 0d 00 00       	call   801020cf <writei>
80101394:	83 c4 10             	add    $0x10,%esp
80101397:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010139a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010139e:	7e 11                	jle    801013b1 <filewrite+0xd3>
        f->off += r;
801013a0:	8b 45 08             	mov    0x8(%ebp),%eax
801013a3:	8b 50 14             	mov    0x14(%eax),%edx
801013a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a9:	01 c2                	add    %eax,%edx
801013ab:	8b 45 08             	mov    0x8(%ebp),%eax
801013ae:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013b1:	8b 45 08             	mov    0x8(%ebp),%eax
801013b4:	8b 40 10             	mov    0x10(%eax),%eax
801013b7:	83 ec 0c             	sub    $0xc,%esp
801013ba:	50                   	push   %eax
801013bb:	e8 c5 07 00 00       	call   80101b85 <iunlock>
801013c0:	83 c4 10             	add    $0x10,%esp
      end_op();
801013c3:	e8 2b 1e 00 00       	call   801031f3 <end_op>

      if(r < 0)
801013c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013cc:	78 29                	js     801013f7 <filewrite+0x119>
        break;
      if(r != n1)
801013ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013d1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013d4:	74 0d                	je     801013e3 <filewrite+0x105>
        panic("short filewrite");
801013d6:	83 ec 0c             	sub    $0xc,%esp
801013d9:	68 63 aa 10 80       	push   $0x8010aa63
801013de:	e8 e2 f1 ff ff       	call   801005c5 <panic>
      i += r;
801013e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013e6:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ec:	3b 45 10             	cmp    0x10(%ebp),%eax
801013ef:	0f 8c 51 ff ff ff    	jl     80101346 <filewrite+0x68>
801013f5:	eb 01                	jmp    801013f8 <filewrite+0x11a>
        break;
801013f7:	90                   	nop
    }
    return i == n ? n : -1;
801013f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013fb:	3b 45 10             	cmp    0x10(%ebp),%eax
801013fe:	75 05                	jne    80101405 <filewrite+0x127>
80101400:	8b 45 10             	mov    0x10(%ebp),%eax
80101403:	eb 14                	jmp    80101419 <filewrite+0x13b>
80101405:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010140a:	eb 0d                	jmp    80101419 <filewrite+0x13b>
  }
  panic("filewrite");
8010140c:	83 ec 0c             	sub    $0xc,%esp
8010140f:	68 73 aa 10 80       	push   $0x8010aa73
80101414:	e8 ac f1 ff ff       	call   801005c5 <panic>
}
80101419:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010141c:	c9                   	leave  
8010141d:	c3                   	ret    

8010141e <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010141e:	f3 0f 1e fb          	endbr32 
80101422:	55                   	push   %ebp
80101423:	89 e5                	mov    %esp,%ebp
80101425:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101428:	8b 45 08             	mov    0x8(%ebp),%eax
8010142b:	83 ec 08             	sub    $0x8,%esp
8010142e:	6a 01                	push   $0x1
80101430:	50                   	push   %eax
80101431:	e8 d3 ed ff ff       	call   80100209 <bread>
80101436:	83 c4 10             	add    $0x10,%esp
80101439:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010143c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010143f:	83 c0 5c             	add    $0x5c,%eax
80101442:	83 ec 04             	sub    $0x4,%esp
80101445:	6a 1c                	push   $0x1c
80101447:	50                   	push   %eax
80101448:	ff 75 0c             	pushl  0xc(%ebp)
8010144b:	e8 e2 3b 00 00       	call   80105032 <memmove>
80101450:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101453:	83 ec 0c             	sub    $0xc,%esp
80101456:	ff 75 f4             	pushl  -0xc(%ebp)
80101459:	e8 35 ee ff ff       	call   80100293 <brelse>
8010145e:	83 c4 10             	add    $0x10,%esp
}
80101461:	90                   	nop
80101462:	c9                   	leave  
80101463:	c3                   	ret    

80101464 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101464:	f3 0f 1e fb          	endbr32 
80101468:	55                   	push   %ebp
80101469:	89 e5                	mov    %esp,%ebp
8010146b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010146e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101471:	8b 45 08             	mov    0x8(%ebp),%eax
80101474:	83 ec 08             	sub    $0x8,%esp
80101477:	52                   	push   %edx
80101478:	50                   	push   %eax
80101479:	e8 8b ed ff ff       	call   80100209 <bread>
8010147e:	83 c4 10             	add    $0x10,%esp
80101481:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101487:	83 c0 5c             	add    $0x5c,%eax
8010148a:	83 ec 04             	sub    $0x4,%esp
8010148d:	68 00 02 00 00       	push   $0x200
80101492:	6a 00                	push   $0x0
80101494:	50                   	push   %eax
80101495:	e8 d1 3a 00 00       	call   80104f6b <memset>
8010149a:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010149d:	83 ec 0c             	sub    $0xc,%esp
801014a0:	ff 75 f4             	pushl  -0xc(%ebp)
801014a3:	e8 04 1f 00 00       	call   801033ac <log_write>
801014a8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014ab:	83 ec 0c             	sub    $0xc,%esp
801014ae:	ff 75 f4             	pushl  -0xc(%ebp)
801014b1:	e8 dd ed ff ff       	call   80100293 <brelse>
801014b6:	83 c4 10             	add    $0x10,%esp
}
801014b9:	90                   	nop
801014ba:	c9                   	leave  
801014bb:	c3                   	ret    

801014bc <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014bc:	f3 0f 1e fb          	endbr32 
801014c0:	55                   	push   %ebp
801014c1:	89 e5                	mov    %esp,%ebp
801014c3:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014c6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014d4:	e9 13 01 00 00       	jmp    801015ec <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801014d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014dc:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014e2:	85 c0                	test   %eax,%eax
801014e4:	0f 48 c2             	cmovs  %edx,%eax
801014e7:	c1 f8 0c             	sar    $0xc,%eax
801014ea:	89 c2                	mov    %eax,%edx
801014ec:	a1 78 37 19 80       	mov    0x80193778,%eax
801014f1:	01 d0                	add    %edx,%eax
801014f3:	83 ec 08             	sub    $0x8,%esp
801014f6:	50                   	push   %eax
801014f7:	ff 75 08             	pushl  0x8(%ebp)
801014fa:	e8 0a ed ff ff       	call   80100209 <bread>
801014ff:	83 c4 10             	add    $0x10,%esp
80101502:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101505:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010150c:	e9 a6 00 00 00       	jmp    801015b7 <balloc+0xfb>
      m = 1 << (bi % 8);
80101511:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101514:	99                   	cltd   
80101515:	c1 ea 1d             	shr    $0x1d,%edx
80101518:	01 d0                	add    %edx,%eax
8010151a:	83 e0 07             	and    $0x7,%eax
8010151d:	29 d0                	sub    %edx,%eax
8010151f:	ba 01 00 00 00       	mov    $0x1,%edx
80101524:	89 c1                	mov    %eax,%ecx
80101526:	d3 e2                	shl    %cl,%edx
80101528:	89 d0                	mov    %edx,%eax
8010152a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010152d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101530:	8d 50 07             	lea    0x7(%eax),%edx
80101533:	85 c0                	test   %eax,%eax
80101535:	0f 48 c2             	cmovs  %edx,%eax
80101538:	c1 f8 03             	sar    $0x3,%eax
8010153b:	89 c2                	mov    %eax,%edx
8010153d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101540:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101545:	0f b6 c0             	movzbl %al,%eax
80101548:	23 45 e8             	and    -0x18(%ebp),%eax
8010154b:	85 c0                	test   %eax,%eax
8010154d:	75 64                	jne    801015b3 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010154f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101552:	8d 50 07             	lea    0x7(%eax),%edx
80101555:	85 c0                	test   %eax,%eax
80101557:	0f 48 c2             	cmovs  %edx,%eax
8010155a:	c1 f8 03             	sar    $0x3,%eax
8010155d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101560:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101565:	89 d1                	mov    %edx,%ecx
80101567:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010156a:	09 ca                	or     %ecx,%edx
8010156c:	89 d1                	mov    %edx,%ecx
8010156e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101571:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101575:	83 ec 0c             	sub    $0xc,%esp
80101578:	ff 75 ec             	pushl  -0x14(%ebp)
8010157b:	e8 2c 1e 00 00       	call   801033ac <log_write>
80101580:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101583:	83 ec 0c             	sub    $0xc,%esp
80101586:	ff 75 ec             	pushl  -0x14(%ebp)
80101589:	e8 05 ed ff ff       	call   80100293 <brelse>
8010158e:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101591:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101594:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101597:	01 c2                	add    %eax,%edx
80101599:	8b 45 08             	mov    0x8(%ebp),%eax
8010159c:	83 ec 08             	sub    $0x8,%esp
8010159f:	52                   	push   %edx
801015a0:	50                   	push   %eax
801015a1:	e8 be fe ff ff       	call   80101464 <bzero>
801015a6:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015af:	01 d0                	add    %edx,%eax
801015b1:	eb 57                	jmp    8010160a <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015b3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015b7:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015be:	7f 17                	jg     801015d7 <balloc+0x11b>
801015c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c6:	01 d0                	add    %edx,%eax
801015c8:	89 c2                	mov    %eax,%edx
801015ca:	a1 60 37 19 80       	mov    0x80193760,%eax
801015cf:	39 c2                	cmp    %eax,%edx
801015d1:	0f 82 3a ff ff ff    	jb     80101511 <balloc+0x55>
      }
    }
    brelse(bp);
801015d7:	83 ec 0c             	sub    $0xc,%esp
801015da:	ff 75 ec             	pushl  -0x14(%ebp)
801015dd:	e8 b1 ec ff ff       	call   80100293 <brelse>
801015e2:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015e5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015ec:	8b 15 60 37 19 80    	mov    0x80193760,%edx
801015f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015f5:	39 c2                	cmp    %eax,%edx
801015f7:	0f 87 dc fe ff ff    	ja     801014d9 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801015fd:	83 ec 0c             	sub    $0xc,%esp
80101600:	68 80 aa 10 80       	push   $0x8010aa80
80101605:	e8 bb ef ff ff       	call   801005c5 <panic>
}
8010160a:	c9                   	leave  
8010160b:	c3                   	ret    

8010160c <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010160c:	f3 0f 1e fb          	endbr32 
80101610:	55                   	push   %ebp
80101611:	89 e5                	mov    %esp,%ebp
80101613:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101616:	83 ec 08             	sub    $0x8,%esp
80101619:	68 60 37 19 80       	push   $0x80193760
8010161e:	ff 75 08             	pushl  0x8(%ebp)
80101621:	e8 f8 fd ff ff       	call   8010141e <readsb>
80101626:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101629:	8b 45 0c             	mov    0xc(%ebp),%eax
8010162c:	c1 e8 0c             	shr    $0xc,%eax
8010162f:	89 c2                	mov    %eax,%edx
80101631:	a1 78 37 19 80       	mov    0x80193778,%eax
80101636:	01 c2                	add    %eax,%edx
80101638:	8b 45 08             	mov    0x8(%ebp),%eax
8010163b:	83 ec 08             	sub    $0x8,%esp
8010163e:	52                   	push   %edx
8010163f:	50                   	push   %eax
80101640:	e8 c4 eb ff ff       	call   80100209 <bread>
80101645:	83 c4 10             	add    $0x10,%esp
80101648:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010164b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010164e:	25 ff 0f 00 00       	and    $0xfff,%eax
80101653:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101656:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101659:	99                   	cltd   
8010165a:	c1 ea 1d             	shr    $0x1d,%edx
8010165d:	01 d0                	add    %edx,%eax
8010165f:	83 e0 07             	and    $0x7,%eax
80101662:	29 d0                	sub    %edx,%eax
80101664:	ba 01 00 00 00       	mov    $0x1,%edx
80101669:	89 c1                	mov    %eax,%ecx
8010166b:	d3 e2                	shl    %cl,%edx
8010166d:	89 d0                	mov    %edx,%eax
8010166f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101672:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101675:	8d 50 07             	lea    0x7(%eax),%edx
80101678:	85 c0                	test   %eax,%eax
8010167a:	0f 48 c2             	cmovs  %edx,%eax
8010167d:	c1 f8 03             	sar    $0x3,%eax
80101680:	89 c2                	mov    %eax,%edx
80101682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101685:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010168a:	0f b6 c0             	movzbl %al,%eax
8010168d:	23 45 ec             	and    -0x14(%ebp),%eax
80101690:	85 c0                	test   %eax,%eax
80101692:	75 0d                	jne    801016a1 <bfree+0x95>
    panic("freeing free block");
80101694:	83 ec 0c             	sub    $0xc,%esp
80101697:	68 96 aa 10 80       	push   $0x8010aa96
8010169c:	e8 24 ef ff ff       	call   801005c5 <panic>
  bp->data[bi/8] &= ~m;
801016a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a4:	8d 50 07             	lea    0x7(%eax),%edx
801016a7:	85 c0                	test   %eax,%eax
801016a9:	0f 48 c2             	cmovs  %edx,%eax
801016ac:	c1 f8 03             	sar    $0x3,%eax
801016af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016b2:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016b7:	89 d1                	mov    %edx,%ecx
801016b9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016bc:	f7 d2                	not    %edx
801016be:	21 ca                	and    %ecx,%edx
801016c0:	89 d1                	mov    %edx,%ecx
801016c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c5:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016c9:	83 ec 0c             	sub    $0xc,%esp
801016cc:	ff 75 f4             	pushl  -0xc(%ebp)
801016cf:	e8 d8 1c 00 00       	call   801033ac <log_write>
801016d4:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016d7:	83 ec 0c             	sub    $0xc,%esp
801016da:	ff 75 f4             	pushl  -0xc(%ebp)
801016dd:	e8 b1 eb ff ff       	call   80100293 <brelse>
801016e2:	83 c4 10             	add    $0x10,%esp
}
801016e5:	90                   	nop
801016e6:	c9                   	leave  
801016e7:	c3                   	ret    

801016e8 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016e8:	f3 0f 1e fb          	endbr32 
801016ec:	55                   	push   %ebp
801016ed:	89 e5                	mov    %esp,%ebp
801016ef:	57                   	push   %edi
801016f0:	56                   	push   %esi
801016f1:	53                   	push   %ebx
801016f2:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801016f5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801016fc:	83 ec 08             	sub    $0x8,%esp
801016ff:	68 a9 aa 10 80       	push   $0x8010aaa9
80101704:	68 80 37 19 80       	push   $0x80193780
80101709:	e8 a8 35 00 00       	call   80104cb6 <initlock>
8010170e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101711:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101718:	eb 2d                	jmp    80101747 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
8010171a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010171d:	89 d0                	mov    %edx,%eax
8010171f:	c1 e0 03             	shl    $0x3,%eax
80101722:	01 d0                	add    %edx,%eax
80101724:	c1 e0 04             	shl    $0x4,%eax
80101727:	83 c0 30             	add    $0x30,%eax
8010172a:	05 80 37 19 80       	add    $0x80193780,%eax
8010172f:	83 c0 10             	add    $0x10,%eax
80101732:	83 ec 08             	sub    $0x8,%esp
80101735:	68 b0 aa 10 80       	push   $0x8010aab0
8010173a:	50                   	push   %eax
8010173b:	e8 09 34 00 00       	call   80104b49 <initsleeplock>
80101740:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101743:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101747:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
8010174b:	7e cd                	jle    8010171a <iinit+0x32>
  }

  readsb(dev, &sb);
8010174d:	83 ec 08             	sub    $0x8,%esp
80101750:	68 60 37 19 80       	push   $0x80193760
80101755:	ff 75 08             	pushl  0x8(%ebp)
80101758:	e8 c1 fc ff ff       	call   8010141e <readsb>
8010175d:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101760:	a1 78 37 19 80       	mov    0x80193778,%eax
80101765:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101768:	8b 3d 74 37 19 80    	mov    0x80193774,%edi
8010176e:	8b 35 70 37 19 80    	mov    0x80193770,%esi
80101774:	8b 1d 6c 37 19 80    	mov    0x8019376c,%ebx
8010177a:	8b 0d 68 37 19 80    	mov    0x80193768,%ecx
80101780:	8b 15 64 37 19 80    	mov    0x80193764,%edx
80101786:	a1 60 37 19 80       	mov    0x80193760,%eax
8010178b:	ff 75 d4             	pushl  -0x2c(%ebp)
8010178e:	57                   	push   %edi
8010178f:	56                   	push   %esi
80101790:	53                   	push   %ebx
80101791:	51                   	push   %ecx
80101792:	52                   	push   %edx
80101793:	50                   	push   %eax
80101794:	68 b8 aa 10 80       	push   $0x8010aab8
80101799:	e8 6e ec ff ff       	call   8010040c <cprintf>
8010179e:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017a1:	90                   	nop
801017a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017a5:	5b                   	pop    %ebx
801017a6:	5e                   	pop    %esi
801017a7:	5f                   	pop    %edi
801017a8:	5d                   	pop    %ebp
801017a9:	c3                   	ret    

801017aa <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017aa:	f3 0f 1e fb          	endbr32 
801017ae:	55                   	push   %ebp
801017af:	89 e5                	mov    %esp,%ebp
801017b1:	83 ec 28             	sub    $0x28,%esp
801017b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801017b7:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017bb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017c2:	e9 9e 00 00 00       	jmp    80101865 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	c1 e8 03             	shr    $0x3,%eax
801017cd:	89 c2                	mov    %eax,%edx
801017cf:	a1 74 37 19 80       	mov    0x80193774,%eax
801017d4:	01 d0                	add    %edx,%eax
801017d6:	83 ec 08             	sub    $0x8,%esp
801017d9:	50                   	push   %eax
801017da:	ff 75 08             	pushl  0x8(%ebp)
801017dd:	e8 27 ea ff ff       	call   80100209 <bread>
801017e2:	83 c4 10             	add    $0x10,%esp
801017e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017eb:	8d 50 5c             	lea    0x5c(%eax),%edx
801017ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f1:	83 e0 07             	and    $0x7,%eax
801017f4:	c1 e0 06             	shl    $0x6,%eax
801017f7:	01 d0                	add    %edx,%eax
801017f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ff:	0f b7 00             	movzwl (%eax),%eax
80101802:	66 85 c0             	test   %ax,%ax
80101805:	75 4c                	jne    80101853 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101807:	83 ec 04             	sub    $0x4,%esp
8010180a:	6a 40                	push   $0x40
8010180c:	6a 00                	push   $0x0
8010180e:	ff 75 ec             	pushl  -0x14(%ebp)
80101811:	e8 55 37 00 00       	call   80104f6b <memset>
80101816:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101819:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010181c:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101820:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101823:	83 ec 0c             	sub    $0xc,%esp
80101826:	ff 75 f0             	pushl  -0x10(%ebp)
80101829:	e8 7e 1b 00 00       	call   801033ac <log_write>
8010182e:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101831:	83 ec 0c             	sub    $0xc,%esp
80101834:	ff 75 f0             	pushl  -0x10(%ebp)
80101837:	e8 57 ea ff ff       	call   80100293 <brelse>
8010183c:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101842:	83 ec 08             	sub    $0x8,%esp
80101845:	50                   	push   %eax
80101846:	ff 75 08             	pushl  0x8(%ebp)
80101849:	e8 fc 00 00 00       	call   8010194a <iget>
8010184e:	83 c4 10             	add    $0x10,%esp
80101851:	eb 30                	jmp    80101883 <ialloc+0xd9>
    }
    brelse(bp);
80101853:	83 ec 0c             	sub    $0xc,%esp
80101856:	ff 75 f0             	pushl  -0x10(%ebp)
80101859:	e8 35 ea ff ff       	call   80100293 <brelse>
8010185e:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101861:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101865:	8b 15 68 37 19 80    	mov    0x80193768,%edx
8010186b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186e:	39 c2                	cmp    %eax,%edx
80101870:	0f 87 51 ff ff ff    	ja     801017c7 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101876:	83 ec 0c             	sub    $0xc,%esp
80101879:	68 0b ab 10 80       	push   $0x8010ab0b
8010187e:	e8 42 ed ff ff       	call   801005c5 <panic>
}
80101883:	c9                   	leave  
80101884:	c3                   	ret    

80101885 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101885:	f3 0f 1e fb          	endbr32 
80101889:	55                   	push   %ebp
8010188a:	89 e5                	mov    %esp,%ebp
8010188c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010188f:	8b 45 08             	mov    0x8(%ebp),%eax
80101892:	8b 40 04             	mov    0x4(%eax),%eax
80101895:	c1 e8 03             	shr    $0x3,%eax
80101898:	89 c2                	mov    %eax,%edx
8010189a:	a1 74 37 19 80       	mov    0x80193774,%eax
8010189f:	01 c2                	add    %eax,%edx
801018a1:	8b 45 08             	mov    0x8(%ebp),%eax
801018a4:	8b 00                	mov    (%eax),%eax
801018a6:	83 ec 08             	sub    $0x8,%esp
801018a9:	52                   	push   %edx
801018aa:	50                   	push   %eax
801018ab:	e8 59 e9 ff ff       	call   80100209 <bread>
801018b0:	83 c4 10             	add    $0x10,%esp
801018b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b9:	8d 50 5c             	lea    0x5c(%eax),%edx
801018bc:	8b 45 08             	mov    0x8(%ebp),%eax
801018bf:	8b 40 04             	mov    0x4(%eax),%eax
801018c2:	83 e0 07             	and    $0x7,%eax
801018c5:	c1 e0 06             	shl    $0x6,%eax
801018c8:	01 d0                	add    %edx,%eax
801018ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018cd:	8b 45 08             	mov    0x8(%ebp),%eax
801018d0:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d7:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018da:	8b 45 08             	mov    0x8(%ebp),%eax
801018dd:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e4:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f2:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018f6:	8b 45 08             	mov    0x8(%ebp),%eax
801018f9:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801018fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101900:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101904:	8b 45 08             	mov    0x8(%ebp),%eax
80101907:	8b 50 58             	mov    0x58(%eax),%edx
8010190a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190d:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101910:	8b 45 08             	mov    0x8(%ebp),%eax
80101913:	8d 50 5c             	lea    0x5c(%eax),%edx
80101916:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101919:	83 c0 0c             	add    $0xc,%eax
8010191c:	83 ec 04             	sub    $0x4,%esp
8010191f:	6a 34                	push   $0x34
80101921:	52                   	push   %edx
80101922:	50                   	push   %eax
80101923:	e8 0a 37 00 00       	call   80105032 <memmove>
80101928:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010192b:	83 ec 0c             	sub    $0xc,%esp
8010192e:	ff 75 f4             	pushl  -0xc(%ebp)
80101931:	e8 76 1a 00 00       	call   801033ac <log_write>
80101936:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	ff 75 f4             	pushl  -0xc(%ebp)
8010193f:	e8 4f e9 ff ff       	call   80100293 <brelse>
80101944:	83 c4 10             	add    $0x10,%esp
}
80101947:	90                   	nop
80101948:	c9                   	leave  
80101949:	c3                   	ret    

8010194a <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010194a:	f3 0f 1e fb          	endbr32 
8010194e:	55                   	push   %ebp
8010194f:	89 e5                	mov    %esp,%ebp
80101951:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101954:	83 ec 0c             	sub    $0xc,%esp
80101957:	68 80 37 19 80       	push   $0x80193780
8010195c:	e8 7b 33 00 00       	call   80104cdc <acquire>
80101961:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101964:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010196b:	c7 45 f4 b4 37 19 80 	movl   $0x801937b4,-0xc(%ebp)
80101972:	eb 60                	jmp    801019d4 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101977:	8b 40 08             	mov    0x8(%eax),%eax
8010197a:	85 c0                	test   %eax,%eax
8010197c:	7e 39                	jle    801019b7 <iget+0x6d>
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 00                	mov    (%eax),%eax
80101983:	39 45 08             	cmp    %eax,0x8(%ebp)
80101986:	75 2f                	jne    801019b7 <iget+0x6d>
80101988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198b:	8b 40 04             	mov    0x4(%eax),%eax
8010198e:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101991:	75 24                	jne    801019b7 <iget+0x6d>
      ip->ref++;
80101993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101996:	8b 40 08             	mov    0x8(%eax),%eax
80101999:	8d 50 01             	lea    0x1(%eax),%edx
8010199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199f:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019a2:	83 ec 0c             	sub    $0xc,%esp
801019a5:	68 80 37 19 80       	push   $0x80193780
801019aa:	e8 9f 33 00 00       	call   80104d4e <release>
801019af:	83 c4 10             	add    $0x10,%esp
      return ip;
801019b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b5:	eb 77                	jmp    80101a2e <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019bb:	75 10                	jne    801019cd <iget+0x83>
801019bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c0:	8b 40 08             	mov    0x8(%eax),%eax
801019c3:	85 c0                	test   %eax,%eax
801019c5:	75 06                	jne    801019cd <iget+0x83>
      empty = ip;
801019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019cd:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019d4:	81 7d f4 d4 53 19 80 	cmpl   $0x801953d4,-0xc(%ebp)
801019db:	72 97                	jb     80101974 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019e1:	75 0d                	jne    801019f0 <iget+0xa6>
    panic("iget: no inodes");
801019e3:	83 ec 0c             	sub    $0xc,%esp
801019e6:	68 1d ab 10 80       	push   $0x8010ab1d
801019eb:	e8 d5 eb ff ff       	call   801005c5 <panic>

  ip = empty;
801019f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f9:	8b 55 08             	mov    0x8(%ebp),%edx
801019fc:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a01:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a04:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a14:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	68 80 37 19 80       	push   $0x80193780
80101a23:	e8 26 33 00 00       	call   80104d4e <release>
80101a28:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a2e:	c9                   	leave  
80101a2f:	c3                   	ret    

80101a30 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a30:	f3 0f 1e fb          	endbr32 
80101a34:	55                   	push   %ebp
80101a35:	89 e5                	mov    %esp,%ebp
80101a37:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a3a:	83 ec 0c             	sub    $0xc,%esp
80101a3d:	68 80 37 19 80       	push   $0x80193780
80101a42:	e8 95 32 00 00       	call   80104cdc <acquire>
80101a47:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4d:	8b 40 08             	mov    0x8(%eax),%eax
80101a50:	8d 50 01             	lea    0x1(%eax),%edx
80101a53:	8b 45 08             	mov    0x8(%ebp),%eax
80101a56:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a59:	83 ec 0c             	sub    $0xc,%esp
80101a5c:	68 80 37 19 80       	push   $0x80193780
80101a61:	e8 e8 32 00 00       	call   80104d4e <release>
80101a66:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a69:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a6c:	c9                   	leave  
80101a6d:	c3                   	ret    

80101a6e <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a6e:	f3 0f 1e fb          	endbr32 
80101a72:	55                   	push   %ebp
80101a73:	89 e5                	mov    %esp,%ebp
80101a75:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a78:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a7c:	74 0a                	je     80101a88 <ilock+0x1a>
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	8b 40 08             	mov    0x8(%eax),%eax
80101a84:	85 c0                	test   %eax,%eax
80101a86:	7f 0d                	jg     80101a95 <ilock+0x27>
    panic("ilock");
80101a88:	83 ec 0c             	sub    $0xc,%esp
80101a8b:	68 2d ab 10 80       	push   $0x8010ab2d
80101a90:	e8 30 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	83 c0 0c             	add    $0xc,%eax
80101a9b:	83 ec 0c             	sub    $0xc,%esp
80101a9e:	50                   	push   %eax
80101a9f:	e8 e5 30 00 00       	call   80104b89 <acquiresleep>
80101aa4:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaa:	8b 40 4c             	mov    0x4c(%eax),%eax
80101aad:	85 c0                	test   %eax,%eax
80101aaf:	0f 85 cd 00 00 00    	jne    80101b82 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	8b 40 04             	mov    0x4(%eax),%eax
80101abb:	c1 e8 03             	shr    $0x3,%eax
80101abe:	89 c2                	mov    %eax,%edx
80101ac0:	a1 74 37 19 80       	mov    0x80193774,%eax
80101ac5:	01 c2                	add    %eax,%edx
80101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aca:	8b 00                	mov    (%eax),%eax
80101acc:	83 ec 08             	sub    $0x8,%esp
80101acf:	52                   	push   %edx
80101ad0:	50                   	push   %eax
80101ad1:	e8 33 e7 ff ff       	call   80100209 <bread>
80101ad6:	83 c4 10             	add    $0x10,%esp
80101ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101adf:	8d 50 5c             	lea    0x5c(%eax),%edx
80101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae5:	8b 40 04             	mov    0x4(%eax),%eax
80101ae8:	83 e0 07             	and    $0x7,%eax
80101aeb:	c1 e0 06             	shl    $0x6,%eax
80101aee:	01 d0                	add    %edx,%eax
80101af0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af6:	0f b7 10             	movzwl (%eax),%edx
80101af9:	8b 45 08             	mov    0x8(%ebp),%eax
80101afc:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b03:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b11:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b15:	8b 45 08             	mov    0x8(%ebp),%eax
80101b18:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2d:	8b 50 08             	mov    0x8(%eax),%edx
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b39:	8d 50 0c             	lea    0xc(%eax),%edx
80101b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3f:	83 c0 5c             	add    $0x5c,%eax
80101b42:	83 ec 04             	sub    $0x4,%esp
80101b45:	6a 34                	push   $0x34
80101b47:	52                   	push   %edx
80101b48:	50                   	push   %eax
80101b49:	e8 e4 34 00 00       	call   80105032 <memmove>
80101b4e:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b51:	83 ec 0c             	sub    $0xc,%esp
80101b54:	ff 75 f4             	pushl  -0xc(%ebp)
80101b57:	e8 37 e7 ff ff       	call   80100293 <brelse>
80101b5c:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b62:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b69:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b70:	66 85 c0             	test   %ax,%ax
80101b73:	75 0d                	jne    80101b82 <ilock+0x114>
      panic("ilock: no type");
80101b75:	83 ec 0c             	sub    $0xc,%esp
80101b78:	68 33 ab 10 80       	push   $0x8010ab33
80101b7d:	e8 43 ea ff ff       	call   801005c5 <panic>
  }
}
80101b82:	90                   	nop
80101b83:	c9                   	leave  
80101b84:	c3                   	ret    

80101b85 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b85:	f3 0f 1e fb          	endbr32 
80101b89:	55                   	push   %ebp
80101b8a:	89 e5                	mov    %esp,%ebp
80101b8c:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b8f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b93:	74 20                	je     80101bb5 <iunlock+0x30>
80101b95:	8b 45 08             	mov    0x8(%ebp),%eax
80101b98:	83 c0 0c             	add    $0xc,%eax
80101b9b:	83 ec 0c             	sub    $0xc,%esp
80101b9e:	50                   	push   %eax
80101b9f:	e8 9f 30 00 00       	call   80104c43 <holdingsleep>
80101ba4:	83 c4 10             	add    $0x10,%esp
80101ba7:	85 c0                	test   %eax,%eax
80101ba9:	74 0a                	je     80101bb5 <iunlock+0x30>
80101bab:	8b 45 08             	mov    0x8(%ebp),%eax
80101bae:	8b 40 08             	mov    0x8(%eax),%eax
80101bb1:	85 c0                	test   %eax,%eax
80101bb3:	7f 0d                	jg     80101bc2 <iunlock+0x3d>
    panic("iunlock");
80101bb5:	83 ec 0c             	sub    $0xc,%esp
80101bb8:	68 42 ab 10 80       	push   $0x8010ab42
80101bbd:	e8 03 ea ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	83 c0 0c             	add    $0xc,%eax
80101bc8:	83 ec 0c             	sub    $0xc,%esp
80101bcb:	50                   	push   %eax
80101bcc:	e8 20 30 00 00       	call   80104bf1 <releasesleep>
80101bd1:	83 c4 10             	add    $0x10,%esp
}
80101bd4:	90                   	nop
80101bd5:	c9                   	leave  
80101bd6:	c3                   	ret    

80101bd7 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bd7:	f3 0f 1e fb          	endbr32 
80101bdb:	55                   	push   %ebp
80101bdc:	89 e5                	mov    %esp,%ebp
80101bde:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101be1:	8b 45 08             	mov    0x8(%ebp),%eax
80101be4:	83 c0 0c             	add    $0xc,%eax
80101be7:	83 ec 0c             	sub    $0xc,%esp
80101bea:	50                   	push   %eax
80101beb:	e8 99 2f 00 00       	call   80104b89 <acquiresleep>
80101bf0:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf6:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bf9:	85 c0                	test   %eax,%eax
80101bfb:	74 6a                	je     80101c67 <iput+0x90>
80101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80101c00:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c04:	66 85 c0             	test   %ax,%ax
80101c07:	75 5e                	jne    80101c67 <iput+0x90>
    acquire(&icache.lock);
80101c09:	83 ec 0c             	sub    $0xc,%esp
80101c0c:	68 80 37 19 80       	push   $0x80193780
80101c11:	e8 c6 30 00 00       	call   80104cdc <acquire>
80101c16:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c19:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1c:	8b 40 08             	mov    0x8(%eax),%eax
80101c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c22:	83 ec 0c             	sub    $0xc,%esp
80101c25:	68 80 37 19 80       	push   $0x80193780
80101c2a:	e8 1f 31 00 00       	call   80104d4e <release>
80101c2f:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c32:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c36:	75 2f                	jne    80101c67 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c38:	83 ec 0c             	sub    $0xc,%esp
80101c3b:	ff 75 08             	pushl  0x8(%ebp)
80101c3e:	e8 b5 01 00 00       	call   80101df8 <itrunc>
80101c43:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	ff 75 08             	pushl  0x8(%ebp)
80101c55:	e8 2b fc ff ff       	call   80101885 <iupdate>
80101c5a:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	83 c0 0c             	add    $0xc,%eax
80101c6d:	83 ec 0c             	sub    $0xc,%esp
80101c70:	50                   	push   %eax
80101c71:	e8 7b 2f 00 00       	call   80104bf1 <releasesleep>
80101c76:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c79:	83 ec 0c             	sub    $0xc,%esp
80101c7c:	68 80 37 19 80       	push   $0x80193780
80101c81:	e8 56 30 00 00       	call   80104cdc <acquire>
80101c86:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c89:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8c:	8b 40 08             	mov    0x8(%eax),%eax
80101c8f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c92:	8b 45 08             	mov    0x8(%ebp),%eax
80101c95:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c98:	83 ec 0c             	sub    $0xc,%esp
80101c9b:	68 80 37 19 80       	push   $0x80193780
80101ca0:	e8 a9 30 00 00       	call   80104d4e <release>
80101ca5:	83 c4 10             	add    $0x10,%esp
}
80101ca8:	90                   	nop
80101ca9:	c9                   	leave  
80101caa:	c3                   	ret    

80101cab <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cab:	f3 0f 1e fb          	endbr32 
80101caf:	55                   	push   %ebp
80101cb0:	89 e5                	mov    %esp,%ebp
80101cb2:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cb5:	83 ec 0c             	sub    $0xc,%esp
80101cb8:	ff 75 08             	pushl  0x8(%ebp)
80101cbb:	e8 c5 fe ff ff       	call   80101b85 <iunlock>
80101cc0:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cc3:	83 ec 0c             	sub    $0xc,%esp
80101cc6:	ff 75 08             	pushl  0x8(%ebp)
80101cc9:	e8 09 ff ff ff       	call   80101bd7 <iput>
80101cce:	83 c4 10             	add    $0x10,%esp
}
80101cd1:	90                   	nop
80101cd2:	c9                   	leave  
80101cd3:	c3                   	ret    

80101cd4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cd4:	f3 0f 1e fb          	endbr32 
80101cd8:	55                   	push   %ebp
80101cd9:	89 e5                	mov    %esp,%ebp
80101cdb:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cde:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101ce2:	77 42                	ja     80101d26 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cea:	83 c2 14             	add    $0x14,%edx
80101ced:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cf8:	75 24                	jne    80101d1e <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	83 ec 0c             	sub    $0xc,%esp
80101d02:	50                   	push   %eax
80101d03:	e8 b4 f7 ff ff       	call   801014bc <balloc>
80101d08:	83 c4 10             	add    $0x10,%esp
80101d0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d11:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d14:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d17:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d1a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d21:	e9 d0 00 00 00       	jmp    80101df6 <bmap+0x122>
  }
  bn -= NDIRECT;
80101d26:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d2a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d2e:	0f 87 b5 00 00 00    	ja     80101de9 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d34:	8b 45 08             	mov    0x8(%ebp),%eax
80101d37:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d44:	75 20                	jne    80101d66 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d46:	8b 45 08             	mov    0x8(%ebp),%eax
80101d49:	8b 00                	mov    (%eax),%eax
80101d4b:	83 ec 0c             	sub    $0xc,%esp
80101d4e:	50                   	push   %eax
80101d4f:	e8 68 f7 ff ff       	call   801014bc <balloc>
80101d54:	83 c4 10             	add    $0x10,%esp
80101d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d60:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d66:	8b 45 08             	mov    0x8(%ebp),%eax
80101d69:	8b 00                	mov    (%eax),%eax
80101d6b:	83 ec 08             	sub    $0x8,%esp
80101d6e:	ff 75 f4             	pushl  -0xc(%ebp)
80101d71:	50                   	push   %eax
80101d72:	e8 92 e4 ff ff       	call   80100209 <bread>
80101d77:	83 c4 10             	add    $0x10,%esp
80101d7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d80:	83 c0 5c             	add    $0x5c,%eax
80101d83:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d86:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d93:	01 d0                	add    %edx,%eax
80101d95:	8b 00                	mov    (%eax),%eax
80101d97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d9e:	75 36                	jne    80101dd6 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	8b 00                	mov    (%eax),%eax
80101da5:	83 ec 0c             	sub    $0xc,%esp
80101da8:	50                   	push   %eax
80101da9:	e8 0e f7 ff ff       	call   801014bc <balloc>
80101dae:	83 c4 10             	add    $0x10,%esp
80101db1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dc1:	01 c2                	add    %eax,%edx
80101dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc6:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101dc8:	83 ec 0c             	sub    $0xc,%esp
80101dcb:	ff 75 f0             	pushl  -0x10(%ebp)
80101dce:	e8 d9 15 00 00       	call   801033ac <log_write>
80101dd3:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101dd6:	83 ec 0c             	sub    $0xc,%esp
80101dd9:	ff 75 f0             	pushl  -0x10(%ebp)
80101ddc:	e8 b2 e4 ff ff       	call   80100293 <brelse>
80101de1:	83 c4 10             	add    $0x10,%esp
    return addr;
80101de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de7:	eb 0d                	jmp    80101df6 <bmap+0x122>
  }

  panic("bmap: out of range");
80101de9:	83 ec 0c             	sub    $0xc,%esp
80101dec:	68 4a ab 10 80       	push   $0x8010ab4a
80101df1:	e8 cf e7 ff ff       	call   801005c5 <panic>
}
80101df6:	c9                   	leave  
80101df7:	c3                   	ret    

80101df8 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101df8:	f3 0f 1e fb          	endbr32 
80101dfc:	55                   	push   %ebp
80101dfd:	89 e5                	mov    %esp,%ebp
80101dff:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e09:	eb 45                	jmp    80101e50 <itrunc+0x58>
    if(ip->addrs[i]){
80101e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e11:	83 c2 14             	add    $0x14,%edx
80101e14:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e18:	85 c0                	test   %eax,%eax
80101e1a:	74 30                	je     80101e4c <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e22:	83 c2 14             	add    $0x14,%edx
80101e25:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 d4 f7 ff ff       	call   8010160c <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e41:	83 c2 14             	add    $0x14,%edx
80101e44:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e4b:	00 
  for(i = 0; i < NDIRECT; i++){
80101e4c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e50:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e54:	7e b5                	jle    80101e0b <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e56:	8b 45 08             	mov    0x8(%ebp),%eax
80101e59:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e5f:	85 c0                	test   %eax,%eax
80101e61:	0f 84 aa 00 00 00    	je     80101f11 <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e67:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6a:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	8b 00                	mov    (%eax),%eax
80101e75:	83 ec 08             	sub    $0x8,%esp
80101e78:	52                   	push   %edx
80101e79:	50                   	push   %eax
80101e7a:	e8 8a e3 ff ff       	call   80100209 <bread>
80101e7f:	83 c4 10             	add    $0x10,%esp
80101e82:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e88:	83 c0 5c             	add    $0x5c,%eax
80101e8b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e8e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e95:	eb 3c                	jmp    80101ed3 <itrunc+0xdb>
      if(a[j])
80101e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e9a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ea1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ea4:	01 d0                	add    %edx,%eax
80101ea6:	8b 00                	mov    (%eax),%eax
80101ea8:	85 c0                	test   %eax,%eax
80101eaa:	74 23                	je     80101ecf <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eaf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eb9:	01 d0                	add    %edx,%eax
80101ebb:	8b 00                	mov    (%eax),%eax
80101ebd:	8b 55 08             	mov    0x8(%ebp),%edx
80101ec0:	8b 12                	mov    (%edx),%edx
80101ec2:	83 ec 08             	sub    $0x8,%esp
80101ec5:	50                   	push   %eax
80101ec6:	52                   	push   %edx
80101ec7:	e8 40 f7 ff ff       	call   8010160c <bfree>
80101ecc:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101ecf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ed6:	83 f8 7f             	cmp    $0x7f,%eax
80101ed9:	76 bc                	jbe    80101e97 <itrunc+0x9f>
    }
    brelse(bp);
80101edb:	83 ec 0c             	sub    $0xc,%esp
80101ede:	ff 75 ec             	pushl  -0x14(%ebp)
80101ee1:	e8 ad e3 ff ff       	call   80100293 <brelse>
80101ee6:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ef2:	8b 55 08             	mov    0x8(%ebp),%edx
80101ef5:	8b 12                	mov    (%edx),%edx
80101ef7:	83 ec 08             	sub    $0x8,%esp
80101efa:	50                   	push   %eax
80101efb:	52                   	push   %edx
80101efc:	e8 0b f7 ff ff       	call   8010160c <bfree>
80101f01:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f04:	8b 45 08             	mov    0x8(%ebp),%eax
80101f07:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f0e:	00 00 00 
  }

  ip->size = 0;
80101f11:	8b 45 08             	mov    0x8(%ebp),%eax
80101f14:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f1b:	83 ec 0c             	sub    $0xc,%esp
80101f1e:	ff 75 08             	pushl  0x8(%ebp)
80101f21:	e8 5f f9 ff ff       	call   80101885 <iupdate>
80101f26:	83 c4 10             	add    $0x10,%esp
}
80101f29:	90                   	nop
80101f2a:	c9                   	leave  
80101f2b:	c3                   	ret    

80101f2c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f2c:	f3 0f 1e fb          	endbr32 
80101f30:	55                   	push   %ebp
80101f31:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f33:	8b 45 08             	mov    0x8(%ebp),%eax
80101f36:	8b 00                	mov    (%eax),%eax
80101f38:	89 c2                	mov    %eax,%edx
80101f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f3d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f40:	8b 45 08             	mov    0x8(%ebp),%eax
80101f43:	8b 50 04             	mov    0x4(%eax),%edx
80101f46:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f49:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4f:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f53:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f56:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f59:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5c:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f60:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f63:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f67:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6a:	8b 50 58             	mov    0x58(%eax),%edx
80101f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f70:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f73:	90                   	nop
80101f74:	5d                   	pop    %ebp
80101f75:	c3                   	ret    

80101f76 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f76:	f3 0f 1e fb          	endbr32 
80101f7a:	55                   	push   %ebp
80101f7b:	89 e5                	mov    %esp,%ebp
80101f7d:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f80:	8b 45 08             	mov    0x8(%ebp),%eax
80101f83:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f87:	66 83 f8 03          	cmp    $0x3,%ax
80101f8b:	75 5c                	jne    80101fe9 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f90:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f94:	66 85 c0             	test   %ax,%ax
80101f97:	78 20                	js     80101fb9 <readi+0x43>
80101f99:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fa0:	66 83 f8 09          	cmp    $0x9,%ax
80101fa4:	7f 13                	jg     80101fb9 <readi+0x43>
80101fa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fad:	98                   	cwtl   
80101fae:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fb5:	85 c0                	test   %eax,%eax
80101fb7:	75 0a                	jne    80101fc3 <readi+0x4d>
      return -1;
80101fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fbe:	e9 0a 01 00 00       	jmp    801020cd <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fca:	98                   	cwtl   
80101fcb:	8b 04 c5 00 37 19 80 	mov    -0x7fe6c900(,%eax,8),%eax
80101fd2:	8b 55 14             	mov    0x14(%ebp),%edx
80101fd5:	83 ec 04             	sub    $0x4,%esp
80101fd8:	52                   	push   %edx
80101fd9:	ff 75 0c             	pushl  0xc(%ebp)
80101fdc:	ff 75 08             	pushl  0x8(%ebp)
80101fdf:	ff d0                	call   *%eax
80101fe1:	83 c4 10             	add    $0x10,%esp
80101fe4:	e9 e4 00 00 00       	jmp    801020cd <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	8b 40 58             	mov    0x58(%eax),%eax
80101fef:	39 45 10             	cmp    %eax,0x10(%ebp)
80101ff2:	77 0d                	ja     80102001 <readi+0x8b>
80101ff4:	8b 55 10             	mov    0x10(%ebp),%edx
80101ff7:	8b 45 14             	mov    0x14(%ebp),%eax
80101ffa:	01 d0                	add    %edx,%eax
80101ffc:	39 45 10             	cmp    %eax,0x10(%ebp)
80101fff:	76 0a                	jbe    8010200b <readi+0x95>
    return -1;
80102001:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102006:	e9 c2 00 00 00       	jmp    801020cd <readi+0x157>
  if(off + n > ip->size)
8010200b:	8b 55 10             	mov    0x10(%ebp),%edx
8010200e:	8b 45 14             	mov    0x14(%ebp),%eax
80102011:	01 c2                	add    %eax,%edx
80102013:	8b 45 08             	mov    0x8(%ebp),%eax
80102016:	8b 40 58             	mov    0x58(%eax),%eax
80102019:	39 c2                	cmp    %eax,%edx
8010201b:	76 0c                	jbe    80102029 <readi+0xb3>
    n = ip->size - off;
8010201d:	8b 45 08             	mov    0x8(%ebp),%eax
80102020:	8b 40 58             	mov    0x58(%eax),%eax
80102023:	2b 45 10             	sub    0x10(%ebp),%eax
80102026:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102029:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102030:	e9 89 00 00 00       	jmp    801020be <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102035:	8b 45 10             	mov    0x10(%ebp),%eax
80102038:	c1 e8 09             	shr    $0x9,%eax
8010203b:	83 ec 08             	sub    $0x8,%esp
8010203e:	50                   	push   %eax
8010203f:	ff 75 08             	pushl  0x8(%ebp)
80102042:	e8 8d fc ff ff       	call   80101cd4 <bmap>
80102047:	83 c4 10             	add    $0x10,%esp
8010204a:	8b 55 08             	mov    0x8(%ebp),%edx
8010204d:	8b 12                	mov    (%edx),%edx
8010204f:	83 ec 08             	sub    $0x8,%esp
80102052:	50                   	push   %eax
80102053:	52                   	push   %edx
80102054:	e8 b0 e1 ff ff       	call   80100209 <bread>
80102059:	83 c4 10             	add    $0x10,%esp
8010205c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010205f:	8b 45 10             	mov    0x10(%ebp),%eax
80102062:	25 ff 01 00 00       	and    $0x1ff,%eax
80102067:	ba 00 02 00 00       	mov    $0x200,%edx
8010206c:	29 c2                	sub    %eax,%edx
8010206e:	8b 45 14             	mov    0x14(%ebp),%eax
80102071:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102074:	39 c2                	cmp    %eax,%edx
80102076:	0f 46 c2             	cmovbe %edx,%eax
80102079:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010207c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010207f:	8d 50 5c             	lea    0x5c(%eax),%edx
80102082:	8b 45 10             	mov    0x10(%ebp),%eax
80102085:	25 ff 01 00 00       	and    $0x1ff,%eax
8010208a:	01 d0                	add    %edx,%eax
8010208c:	83 ec 04             	sub    $0x4,%esp
8010208f:	ff 75 ec             	pushl  -0x14(%ebp)
80102092:	50                   	push   %eax
80102093:	ff 75 0c             	pushl  0xc(%ebp)
80102096:	e8 97 2f 00 00       	call   80105032 <memmove>
8010209b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010209e:	83 ec 0c             	sub    $0xc,%esp
801020a1:	ff 75 f0             	pushl  -0x10(%ebp)
801020a4:	e8 ea e1 ff ff       	call   80100293 <brelse>
801020a9:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020af:	01 45 f4             	add    %eax,-0xc(%ebp)
801020b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020b5:	01 45 10             	add    %eax,0x10(%ebp)
801020b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020bb:	01 45 0c             	add    %eax,0xc(%ebp)
801020be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020c1:	3b 45 14             	cmp    0x14(%ebp),%eax
801020c4:	0f 82 6b ff ff ff    	jb     80102035 <readi+0xbf>
  }
  return n;
801020ca:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020cd:	c9                   	leave  
801020ce:	c3                   	ret    

801020cf <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020cf:	f3 0f 1e fb          	endbr32 
801020d3:	55                   	push   %ebp
801020d4:	89 e5                	mov    %esp,%ebp
801020d6:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020d9:	8b 45 08             	mov    0x8(%ebp),%eax
801020dc:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020e0:	66 83 f8 03          	cmp    $0x3,%ax
801020e4:	75 5c                	jne    80102142 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020e6:	8b 45 08             	mov    0x8(%ebp),%eax
801020e9:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020ed:	66 85 c0             	test   %ax,%ax
801020f0:	78 20                	js     80102112 <writei+0x43>
801020f2:	8b 45 08             	mov    0x8(%ebp),%eax
801020f5:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020f9:	66 83 f8 09          	cmp    $0x9,%ax
801020fd:	7f 13                	jg     80102112 <writei+0x43>
801020ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102102:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102106:	98                   	cwtl   
80102107:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010210e:	85 c0                	test   %eax,%eax
80102110:	75 0a                	jne    8010211c <writei+0x4d>
      return -1;
80102112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102117:	e9 3b 01 00 00       	jmp    80102257 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010211c:	8b 45 08             	mov    0x8(%ebp),%eax
8010211f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102123:	98                   	cwtl   
80102124:	8b 04 c5 04 37 19 80 	mov    -0x7fe6c8fc(,%eax,8),%eax
8010212b:	8b 55 14             	mov    0x14(%ebp),%edx
8010212e:	83 ec 04             	sub    $0x4,%esp
80102131:	52                   	push   %edx
80102132:	ff 75 0c             	pushl  0xc(%ebp)
80102135:	ff 75 08             	pushl  0x8(%ebp)
80102138:	ff d0                	call   *%eax
8010213a:	83 c4 10             	add    $0x10,%esp
8010213d:	e9 15 01 00 00       	jmp    80102257 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102142:	8b 45 08             	mov    0x8(%ebp),%eax
80102145:	8b 40 58             	mov    0x58(%eax),%eax
80102148:	39 45 10             	cmp    %eax,0x10(%ebp)
8010214b:	77 0d                	ja     8010215a <writei+0x8b>
8010214d:	8b 55 10             	mov    0x10(%ebp),%edx
80102150:	8b 45 14             	mov    0x14(%ebp),%eax
80102153:	01 d0                	add    %edx,%eax
80102155:	39 45 10             	cmp    %eax,0x10(%ebp)
80102158:	76 0a                	jbe    80102164 <writei+0x95>
    return -1;
8010215a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010215f:	e9 f3 00 00 00       	jmp    80102257 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102164:	8b 55 10             	mov    0x10(%ebp),%edx
80102167:	8b 45 14             	mov    0x14(%ebp),%eax
8010216a:	01 d0                	add    %edx,%eax
8010216c:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102171:	76 0a                	jbe    8010217d <writei+0xae>
    return -1;
80102173:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102178:	e9 da 00 00 00       	jmp    80102257 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010217d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102184:	e9 97 00 00 00       	jmp    80102220 <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102189:	8b 45 10             	mov    0x10(%ebp),%eax
8010218c:	c1 e8 09             	shr    $0x9,%eax
8010218f:	83 ec 08             	sub    $0x8,%esp
80102192:	50                   	push   %eax
80102193:	ff 75 08             	pushl  0x8(%ebp)
80102196:	e8 39 fb ff ff       	call   80101cd4 <bmap>
8010219b:	83 c4 10             	add    $0x10,%esp
8010219e:	8b 55 08             	mov    0x8(%ebp),%edx
801021a1:	8b 12                	mov    (%edx),%edx
801021a3:	83 ec 08             	sub    $0x8,%esp
801021a6:	50                   	push   %eax
801021a7:	52                   	push   %edx
801021a8:	e8 5c e0 ff ff       	call   80100209 <bread>
801021ad:	83 c4 10             	add    $0x10,%esp
801021b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021b3:	8b 45 10             	mov    0x10(%ebp),%eax
801021b6:	25 ff 01 00 00       	and    $0x1ff,%eax
801021bb:	ba 00 02 00 00       	mov    $0x200,%edx
801021c0:	29 c2                	sub    %eax,%edx
801021c2:	8b 45 14             	mov    0x14(%ebp),%eax
801021c5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021c8:	39 c2                	cmp    %eax,%edx
801021ca:	0f 46 c2             	cmovbe %edx,%eax
801021cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021d3:	8d 50 5c             	lea    0x5c(%eax),%edx
801021d6:	8b 45 10             	mov    0x10(%ebp),%eax
801021d9:	25 ff 01 00 00       	and    $0x1ff,%eax
801021de:	01 d0                	add    %edx,%eax
801021e0:	83 ec 04             	sub    $0x4,%esp
801021e3:	ff 75 ec             	pushl  -0x14(%ebp)
801021e6:	ff 75 0c             	pushl  0xc(%ebp)
801021e9:	50                   	push   %eax
801021ea:	e8 43 2e 00 00       	call   80105032 <memmove>
801021ef:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021f2:	83 ec 0c             	sub    $0xc,%esp
801021f5:	ff 75 f0             	pushl  -0x10(%ebp)
801021f8:	e8 af 11 00 00       	call   801033ac <log_write>
801021fd:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102200:	83 ec 0c             	sub    $0xc,%esp
80102203:	ff 75 f0             	pushl  -0x10(%ebp)
80102206:	e8 88 e0 ff ff       	call   80100293 <brelse>
8010220b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010220e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102211:	01 45 f4             	add    %eax,-0xc(%ebp)
80102214:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102217:	01 45 10             	add    %eax,0x10(%ebp)
8010221a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010221d:	01 45 0c             	add    %eax,0xc(%ebp)
80102220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102223:	3b 45 14             	cmp    0x14(%ebp),%eax
80102226:	0f 82 5d ff ff ff    	jb     80102189 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
8010222c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102230:	74 22                	je     80102254 <writei+0x185>
80102232:	8b 45 08             	mov    0x8(%ebp),%eax
80102235:	8b 40 58             	mov    0x58(%eax),%eax
80102238:	39 45 10             	cmp    %eax,0x10(%ebp)
8010223b:	76 17                	jbe    80102254 <writei+0x185>
    ip->size = off;
8010223d:	8b 45 08             	mov    0x8(%ebp),%eax
80102240:	8b 55 10             	mov    0x10(%ebp),%edx
80102243:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102246:	83 ec 0c             	sub    $0xc,%esp
80102249:	ff 75 08             	pushl  0x8(%ebp)
8010224c:	e8 34 f6 ff ff       	call   80101885 <iupdate>
80102251:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102254:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102257:	c9                   	leave  
80102258:	c3                   	ret    

80102259 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102259:	f3 0f 1e fb          	endbr32 
8010225d:	55                   	push   %ebp
8010225e:	89 e5                	mov    %esp,%ebp
80102260:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102263:	83 ec 04             	sub    $0x4,%esp
80102266:	6a 0e                	push   $0xe
80102268:	ff 75 0c             	pushl  0xc(%ebp)
8010226b:	ff 75 08             	pushl  0x8(%ebp)
8010226e:	e8 5d 2e 00 00       	call   801050d0 <strncmp>
80102273:	83 c4 10             	add    $0x10,%esp
}
80102276:	c9                   	leave  
80102277:	c3                   	ret    

80102278 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102278:	f3 0f 1e fb          	endbr32 
8010227c:	55                   	push   %ebp
8010227d:	89 e5                	mov    %esp,%ebp
8010227f:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102282:	8b 45 08             	mov    0x8(%ebp),%eax
80102285:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102289:	66 83 f8 01          	cmp    $0x1,%ax
8010228d:	74 0d                	je     8010229c <dirlookup+0x24>
    panic("dirlookup not DIR");
8010228f:	83 ec 0c             	sub    $0xc,%esp
80102292:	68 5d ab 10 80       	push   $0x8010ab5d
80102297:	e8 29 e3 ff ff       	call   801005c5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010229c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022a3:	eb 7b                	jmp    80102320 <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022a5:	6a 10                	push   $0x10
801022a7:	ff 75 f4             	pushl  -0xc(%ebp)
801022aa:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ad:	50                   	push   %eax
801022ae:	ff 75 08             	pushl  0x8(%ebp)
801022b1:	e8 c0 fc ff ff       	call   80101f76 <readi>
801022b6:	83 c4 10             	add    $0x10,%esp
801022b9:	83 f8 10             	cmp    $0x10,%eax
801022bc:	74 0d                	je     801022cb <dirlookup+0x53>
      panic("dirlookup read");
801022be:	83 ec 0c             	sub    $0xc,%esp
801022c1:	68 6f ab 10 80       	push   $0x8010ab6f
801022c6:	e8 fa e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801022cb:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022cf:	66 85 c0             	test   %ax,%ax
801022d2:	74 47                	je     8010231b <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801022d4:	83 ec 08             	sub    $0x8,%esp
801022d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022da:	83 c0 02             	add    $0x2,%eax
801022dd:	50                   	push   %eax
801022de:	ff 75 0c             	pushl  0xc(%ebp)
801022e1:	e8 73 ff ff ff       	call   80102259 <namecmp>
801022e6:	83 c4 10             	add    $0x10,%esp
801022e9:	85 c0                	test   %eax,%eax
801022eb:	75 2f                	jne    8010231c <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801022ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022f1:	74 08                	je     801022fb <dirlookup+0x83>
        *poff = off;
801022f3:	8b 45 10             	mov    0x10(%ebp),%eax
801022f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022f9:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022fb:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022ff:	0f b7 c0             	movzwl %ax,%eax
80102302:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102305:	8b 45 08             	mov    0x8(%ebp),%eax
80102308:	8b 00                	mov    (%eax),%eax
8010230a:	83 ec 08             	sub    $0x8,%esp
8010230d:	ff 75 f0             	pushl  -0x10(%ebp)
80102310:	50                   	push   %eax
80102311:	e8 34 f6 ff ff       	call   8010194a <iget>
80102316:	83 c4 10             	add    $0x10,%esp
80102319:	eb 19                	jmp    80102334 <dirlookup+0xbc>
      continue;
8010231b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010231c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102320:	8b 45 08             	mov    0x8(%ebp),%eax
80102323:	8b 40 58             	mov    0x58(%eax),%eax
80102326:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102329:	0f 82 76 ff ff ff    	jb     801022a5 <dirlookup+0x2d>
    }
  }

  return 0;
8010232f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102334:	c9                   	leave  
80102335:	c3                   	ret    

80102336 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102336:	f3 0f 1e fb          	endbr32 
8010233a:	55                   	push   %ebp
8010233b:	89 e5                	mov    %esp,%ebp
8010233d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102340:	83 ec 04             	sub    $0x4,%esp
80102343:	6a 00                	push   $0x0
80102345:	ff 75 0c             	pushl  0xc(%ebp)
80102348:	ff 75 08             	pushl  0x8(%ebp)
8010234b:	e8 28 ff ff ff       	call   80102278 <dirlookup>
80102350:	83 c4 10             	add    $0x10,%esp
80102353:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102356:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010235a:	74 18                	je     80102374 <dirlink+0x3e>
    iput(ip);
8010235c:	83 ec 0c             	sub    $0xc,%esp
8010235f:	ff 75 f0             	pushl  -0x10(%ebp)
80102362:	e8 70 f8 ff ff       	call   80101bd7 <iput>
80102367:	83 c4 10             	add    $0x10,%esp
    return -1;
8010236a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010236f:	e9 9c 00 00 00       	jmp    80102410 <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102374:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010237b:	eb 39                	jmp    801023b6 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010237d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102380:	6a 10                	push   $0x10
80102382:	50                   	push   %eax
80102383:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102386:	50                   	push   %eax
80102387:	ff 75 08             	pushl  0x8(%ebp)
8010238a:	e8 e7 fb ff ff       	call   80101f76 <readi>
8010238f:	83 c4 10             	add    $0x10,%esp
80102392:	83 f8 10             	cmp    $0x10,%eax
80102395:	74 0d                	je     801023a4 <dirlink+0x6e>
      panic("dirlink read");
80102397:	83 ec 0c             	sub    $0xc,%esp
8010239a:	68 7e ab 10 80       	push   $0x8010ab7e
8010239f:	e8 21 e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801023a4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023a8:	66 85 c0             	test   %ax,%ax
801023ab:	74 18                	je     801023c5 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b0:	83 c0 10             	add    $0x10,%eax
801023b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023b6:	8b 45 08             	mov    0x8(%ebp),%eax
801023b9:	8b 50 58             	mov    0x58(%eax),%edx
801023bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bf:	39 c2                	cmp    %eax,%edx
801023c1:	77 ba                	ja     8010237d <dirlink+0x47>
801023c3:	eb 01                	jmp    801023c6 <dirlink+0x90>
      break;
801023c5:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023c6:	83 ec 04             	sub    $0x4,%esp
801023c9:	6a 0e                	push   $0xe
801023cb:	ff 75 0c             	pushl  0xc(%ebp)
801023ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023d1:	83 c0 02             	add    $0x2,%eax
801023d4:	50                   	push   %eax
801023d5:	e8 50 2d 00 00       	call   8010512a <strncpy>
801023da:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023dd:	8b 45 10             	mov    0x10(%ebp),%eax
801023e0:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e7:	6a 10                	push   $0x10
801023e9:	50                   	push   %eax
801023ea:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023ed:	50                   	push   %eax
801023ee:	ff 75 08             	pushl  0x8(%ebp)
801023f1:	e8 d9 fc ff ff       	call   801020cf <writei>
801023f6:	83 c4 10             	add    $0x10,%esp
801023f9:	83 f8 10             	cmp    $0x10,%eax
801023fc:	74 0d                	je     8010240b <dirlink+0xd5>
    panic("dirlink");
801023fe:	83 ec 0c             	sub    $0xc,%esp
80102401:	68 8b ab 10 80       	push   $0x8010ab8b
80102406:	e8 ba e1 ff ff       	call   801005c5 <panic>

  return 0;
8010240b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102410:	c9                   	leave  
80102411:	c3                   	ret    

80102412 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102412:	f3 0f 1e fb          	endbr32 
80102416:	55                   	push   %ebp
80102417:	89 e5                	mov    %esp,%ebp
80102419:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010241c:	eb 04                	jmp    80102422 <skipelem+0x10>
    path++;
8010241e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102422:	8b 45 08             	mov    0x8(%ebp),%eax
80102425:	0f b6 00             	movzbl (%eax),%eax
80102428:	3c 2f                	cmp    $0x2f,%al
8010242a:	74 f2                	je     8010241e <skipelem+0xc>
  if(*path == 0)
8010242c:	8b 45 08             	mov    0x8(%ebp),%eax
8010242f:	0f b6 00             	movzbl (%eax),%eax
80102432:	84 c0                	test   %al,%al
80102434:	75 07                	jne    8010243d <skipelem+0x2b>
    return 0;
80102436:	b8 00 00 00 00       	mov    $0x0,%eax
8010243b:	eb 77                	jmp    801024b4 <skipelem+0xa2>
  s = path;
8010243d:	8b 45 08             	mov    0x8(%ebp),%eax
80102440:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102443:	eb 04                	jmp    80102449 <skipelem+0x37>
    path++;
80102445:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102449:	8b 45 08             	mov    0x8(%ebp),%eax
8010244c:	0f b6 00             	movzbl (%eax),%eax
8010244f:	3c 2f                	cmp    $0x2f,%al
80102451:	74 0a                	je     8010245d <skipelem+0x4b>
80102453:	8b 45 08             	mov    0x8(%ebp),%eax
80102456:	0f b6 00             	movzbl (%eax),%eax
80102459:	84 c0                	test   %al,%al
8010245b:	75 e8                	jne    80102445 <skipelem+0x33>
  len = path - s;
8010245d:	8b 45 08             	mov    0x8(%ebp),%eax
80102460:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102463:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102466:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010246a:	7e 15                	jle    80102481 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010246c:	83 ec 04             	sub    $0x4,%esp
8010246f:	6a 0e                	push   $0xe
80102471:	ff 75 f4             	pushl  -0xc(%ebp)
80102474:	ff 75 0c             	pushl  0xc(%ebp)
80102477:	e8 b6 2b 00 00       	call   80105032 <memmove>
8010247c:	83 c4 10             	add    $0x10,%esp
8010247f:	eb 26                	jmp    801024a7 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102481:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102484:	83 ec 04             	sub    $0x4,%esp
80102487:	50                   	push   %eax
80102488:	ff 75 f4             	pushl  -0xc(%ebp)
8010248b:	ff 75 0c             	pushl  0xc(%ebp)
8010248e:	e8 9f 2b 00 00       	call   80105032 <memmove>
80102493:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102496:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102499:	8b 45 0c             	mov    0xc(%ebp),%eax
8010249c:	01 d0                	add    %edx,%eax
8010249e:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024a1:	eb 04                	jmp    801024a7 <skipelem+0x95>
    path++;
801024a3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024a7:	8b 45 08             	mov    0x8(%ebp),%eax
801024aa:	0f b6 00             	movzbl (%eax),%eax
801024ad:	3c 2f                	cmp    $0x2f,%al
801024af:	74 f2                	je     801024a3 <skipelem+0x91>
  return path;
801024b1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024b4:	c9                   	leave  
801024b5:	c3                   	ret    

801024b6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024b6:	f3 0f 1e fb          	endbr32 
801024ba:	55                   	push   %ebp
801024bb:	89 e5                	mov    %esp,%ebp
801024bd:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024c0:	8b 45 08             	mov    0x8(%ebp),%eax
801024c3:	0f b6 00             	movzbl (%eax),%eax
801024c6:	3c 2f                	cmp    $0x2f,%al
801024c8:	75 17                	jne    801024e1 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024ca:	83 ec 08             	sub    $0x8,%esp
801024cd:	6a 01                	push   $0x1
801024cf:	6a 01                	push   $0x1
801024d1:	e8 74 f4 ff ff       	call   8010194a <iget>
801024d6:	83 c4 10             	add    $0x10,%esp
801024d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024dc:	e9 ba 00 00 00       	jmp    8010259b <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801024e1:	e8 b5 16 00 00       	call   80103b9b <myproc>
801024e6:	8b 40 68             	mov    0x68(%eax),%eax
801024e9:	83 ec 0c             	sub    $0xc,%esp
801024ec:	50                   	push   %eax
801024ed:	e8 3e f5 ff ff       	call   80101a30 <idup>
801024f2:	83 c4 10             	add    $0x10,%esp
801024f5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024f8:	e9 9e 00 00 00       	jmp    8010259b <namex+0xe5>
    ilock(ip);
801024fd:	83 ec 0c             	sub    $0xc,%esp
80102500:	ff 75 f4             	pushl  -0xc(%ebp)
80102503:	e8 66 f5 ff ff       	call   80101a6e <ilock>
80102508:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010250b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010250e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102512:	66 83 f8 01          	cmp    $0x1,%ax
80102516:	74 18                	je     80102530 <namex+0x7a>
      iunlockput(ip);
80102518:	83 ec 0c             	sub    $0xc,%esp
8010251b:	ff 75 f4             	pushl  -0xc(%ebp)
8010251e:	e8 88 f7 ff ff       	call   80101cab <iunlockput>
80102523:	83 c4 10             	add    $0x10,%esp
      return 0;
80102526:	b8 00 00 00 00       	mov    $0x0,%eax
8010252b:	e9 a7 00 00 00       	jmp    801025d7 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
80102530:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102534:	74 20                	je     80102556 <namex+0xa0>
80102536:	8b 45 08             	mov    0x8(%ebp),%eax
80102539:	0f b6 00             	movzbl (%eax),%eax
8010253c:	84 c0                	test   %al,%al
8010253e:	75 16                	jne    80102556 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
80102540:	83 ec 0c             	sub    $0xc,%esp
80102543:	ff 75 f4             	pushl  -0xc(%ebp)
80102546:	e8 3a f6 ff ff       	call   80101b85 <iunlock>
8010254b:	83 c4 10             	add    $0x10,%esp
      return ip;
8010254e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102551:	e9 81 00 00 00       	jmp    801025d7 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102556:	83 ec 04             	sub    $0x4,%esp
80102559:	6a 00                	push   $0x0
8010255b:	ff 75 10             	pushl  0x10(%ebp)
8010255e:	ff 75 f4             	pushl  -0xc(%ebp)
80102561:	e8 12 fd ff ff       	call   80102278 <dirlookup>
80102566:	83 c4 10             	add    $0x10,%esp
80102569:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010256c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102570:	75 15                	jne    80102587 <namex+0xd1>
      iunlockput(ip);
80102572:	83 ec 0c             	sub    $0xc,%esp
80102575:	ff 75 f4             	pushl  -0xc(%ebp)
80102578:	e8 2e f7 ff ff       	call   80101cab <iunlockput>
8010257d:	83 c4 10             	add    $0x10,%esp
      return 0;
80102580:	b8 00 00 00 00       	mov    $0x0,%eax
80102585:	eb 50                	jmp    801025d7 <namex+0x121>
    }
    iunlockput(ip);
80102587:	83 ec 0c             	sub    $0xc,%esp
8010258a:	ff 75 f4             	pushl  -0xc(%ebp)
8010258d:	e8 19 f7 ff ff       	call   80101cab <iunlockput>
80102592:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102598:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
8010259b:	83 ec 08             	sub    $0x8,%esp
8010259e:	ff 75 10             	pushl  0x10(%ebp)
801025a1:	ff 75 08             	pushl  0x8(%ebp)
801025a4:	e8 69 fe ff ff       	call   80102412 <skipelem>
801025a9:	83 c4 10             	add    $0x10,%esp
801025ac:	89 45 08             	mov    %eax,0x8(%ebp)
801025af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025b3:	0f 85 44 ff ff ff    	jne    801024fd <namex+0x47>
  }
  if(nameiparent){
801025b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025bd:	74 15                	je     801025d4 <namex+0x11e>
    iput(ip);
801025bf:	83 ec 0c             	sub    $0xc,%esp
801025c2:	ff 75 f4             	pushl  -0xc(%ebp)
801025c5:	e8 0d f6 ff ff       	call   80101bd7 <iput>
801025ca:	83 c4 10             	add    $0x10,%esp
    return 0;
801025cd:	b8 00 00 00 00       	mov    $0x0,%eax
801025d2:	eb 03                	jmp    801025d7 <namex+0x121>
  }
  return ip;
801025d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025d7:	c9                   	leave  
801025d8:	c3                   	ret    

801025d9 <namei>:

struct inode*
namei(char *path)
{
801025d9:	f3 0f 1e fb          	endbr32 
801025dd:	55                   	push   %ebp
801025de:	89 e5                	mov    %esp,%ebp
801025e0:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025e3:	83 ec 04             	sub    $0x4,%esp
801025e6:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025e9:	50                   	push   %eax
801025ea:	6a 00                	push   $0x0
801025ec:	ff 75 08             	pushl  0x8(%ebp)
801025ef:	e8 c2 fe ff ff       	call   801024b6 <namex>
801025f4:	83 c4 10             	add    $0x10,%esp
}
801025f7:	c9                   	leave  
801025f8:	c3                   	ret    

801025f9 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025f9:	f3 0f 1e fb          	endbr32 
801025fd:	55                   	push   %ebp
801025fe:	89 e5                	mov    %esp,%ebp
80102600:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102603:	83 ec 04             	sub    $0x4,%esp
80102606:	ff 75 0c             	pushl  0xc(%ebp)
80102609:	6a 01                	push   $0x1
8010260b:	ff 75 08             	pushl  0x8(%ebp)
8010260e:	e8 a3 fe ff ff       	call   801024b6 <namex>
80102613:	83 c4 10             	add    $0x10,%esp
}
80102616:	c9                   	leave  
80102617:	c3                   	ret    

80102618 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102618:	f3 0f 1e fb          	endbr32 
8010261c:	55                   	push   %ebp
8010261d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010261f:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102624:	8b 55 08             	mov    0x8(%ebp),%edx
80102627:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102629:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010262e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102631:	5d                   	pop    %ebp
80102632:	c3                   	ret    

80102633 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102633:	f3 0f 1e fb          	endbr32 
80102637:	55                   	push   %ebp
80102638:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010263a:	a1 d4 53 19 80       	mov    0x801953d4,%eax
8010263f:	8b 55 08             	mov    0x8(%ebp),%edx
80102642:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102644:	a1 d4 53 19 80       	mov    0x801953d4,%eax
80102649:	8b 55 0c             	mov    0xc(%ebp),%edx
8010264c:	89 50 10             	mov    %edx,0x10(%eax)
}
8010264f:	90                   	nop
80102650:	5d                   	pop    %ebp
80102651:	c3                   	ret    

80102652 <ioapicinit>:

void
ioapicinit(void)
{
80102652:	f3 0f 1e fb          	endbr32 
80102656:	55                   	push   %ebp
80102657:	89 e5                	mov    %esp,%ebp
80102659:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010265c:	c7 05 d4 53 19 80 00 	movl   $0xfec00000,0x801953d4
80102663:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102666:	6a 01                	push   $0x1
80102668:	e8 ab ff ff ff       	call   80102618 <ioapicread>
8010266d:	83 c4 04             	add    $0x4,%esp
80102670:	c1 e8 10             	shr    $0x10,%eax
80102673:	25 ff 00 00 00       	and    $0xff,%eax
80102678:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010267b:	6a 00                	push   $0x0
8010267d:	e8 96 ff ff ff       	call   80102618 <ioapicread>
80102682:	83 c4 04             	add    $0x4,%esp
80102685:	c1 e8 18             	shr    $0x18,%eax
80102688:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010268b:	0f b6 05 a0 81 19 80 	movzbl 0x801981a0,%eax
80102692:	0f b6 c0             	movzbl %al,%eax
80102695:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102698:	74 10                	je     801026aa <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010269a:	83 ec 0c             	sub    $0xc,%esp
8010269d:	68 94 ab 10 80       	push   $0x8010ab94
801026a2:	e8 65 dd ff ff       	call   8010040c <cprintf>
801026a7:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801026aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026b1:	eb 3f                	jmp    801026f2 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801026b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026b6:	83 c0 20             	add    $0x20,%eax
801026b9:	0d 00 00 01 00       	or     $0x10000,%eax
801026be:	89 c2                	mov    %eax,%edx
801026c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026c3:	83 c0 08             	add    $0x8,%eax
801026c6:	01 c0                	add    %eax,%eax
801026c8:	83 ec 08             	sub    $0x8,%esp
801026cb:	52                   	push   %edx
801026cc:	50                   	push   %eax
801026cd:	e8 61 ff ff ff       	call   80102633 <ioapicwrite>
801026d2:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801026d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d8:	83 c0 08             	add    $0x8,%eax
801026db:	01 c0                	add    %eax,%eax
801026dd:	83 c0 01             	add    $0x1,%eax
801026e0:	83 ec 08             	sub    $0x8,%esp
801026e3:	6a 00                	push   $0x0
801026e5:	50                   	push   %eax
801026e6:	e8 48 ff ff ff       	call   80102633 <ioapicwrite>
801026eb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
801026ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801026f8:	7e b9                	jle    801026b3 <ioapicinit+0x61>
  }
}
801026fa:	90                   	nop
801026fb:	90                   	nop
801026fc:	c9                   	leave  
801026fd:	c3                   	ret    

801026fe <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801026fe:	f3 0f 1e fb          	endbr32 
80102702:	55                   	push   %ebp
80102703:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102705:	8b 45 08             	mov    0x8(%ebp),%eax
80102708:	83 c0 20             	add    $0x20,%eax
8010270b:	89 c2                	mov    %eax,%edx
8010270d:	8b 45 08             	mov    0x8(%ebp),%eax
80102710:	83 c0 08             	add    $0x8,%eax
80102713:	01 c0                	add    %eax,%eax
80102715:	52                   	push   %edx
80102716:	50                   	push   %eax
80102717:	e8 17 ff ff ff       	call   80102633 <ioapicwrite>
8010271c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010271f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102722:	c1 e0 18             	shl    $0x18,%eax
80102725:	89 c2                	mov    %eax,%edx
80102727:	8b 45 08             	mov    0x8(%ebp),%eax
8010272a:	83 c0 08             	add    $0x8,%eax
8010272d:	01 c0                	add    %eax,%eax
8010272f:	83 c0 01             	add    $0x1,%eax
80102732:	52                   	push   %edx
80102733:	50                   	push   %eax
80102734:	e8 fa fe ff ff       	call   80102633 <ioapicwrite>
80102739:	83 c4 08             	add    $0x8,%esp
}
8010273c:	90                   	nop
8010273d:	c9                   	leave  
8010273e:	c3                   	ret    

8010273f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010273f:	f3 0f 1e fb          	endbr32 
80102743:	55                   	push   %ebp
80102744:	89 e5                	mov    %esp,%ebp
80102746:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102749:	83 ec 08             	sub    $0x8,%esp
8010274c:	68 c6 ab 10 80       	push   $0x8010abc6
80102751:	68 e0 53 19 80       	push   $0x801953e0
80102756:	e8 5b 25 00 00       	call   80104cb6 <initlock>
8010275b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010275e:	c7 05 14 54 19 80 00 	movl   $0x0,0x80195414
80102765:	00 00 00 
  freerange(vstart, vend);
80102768:	83 ec 08             	sub    $0x8,%esp
8010276b:	ff 75 0c             	pushl  0xc(%ebp)
8010276e:	ff 75 08             	pushl  0x8(%ebp)
80102771:	e8 2e 00 00 00       	call   801027a4 <freerange>
80102776:	83 c4 10             	add    $0x10,%esp
}
80102779:	90                   	nop
8010277a:	c9                   	leave  
8010277b:	c3                   	ret    

8010277c <kinit2>:

void
kinit2(void *vstart, void *vend)
{
8010277c:	f3 0f 1e fb          	endbr32 
80102780:	55                   	push   %ebp
80102781:	89 e5                	mov    %esp,%ebp
80102783:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102786:	83 ec 08             	sub    $0x8,%esp
80102789:	ff 75 0c             	pushl  0xc(%ebp)
8010278c:	ff 75 08             	pushl  0x8(%ebp)
8010278f:	e8 10 00 00 00       	call   801027a4 <freerange>
80102794:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102797:	c7 05 14 54 19 80 01 	movl   $0x1,0x80195414
8010279e:	00 00 00 
}
801027a1:	90                   	nop
801027a2:	c9                   	leave  
801027a3:	c3                   	ret    

801027a4 <freerange>:

void
freerange(void *vstart, void *vend)
{
801027a4:	f3 0f 1e fb          	endbr32 
801027a8:	55                   	push   %ebp
801027a9:	89 e5                	mov    %esp,%ebp
801027ab:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801027ae:	8b 45 08             	mov    0x8(%ebp),%eax
801027b1:	05 ff 0f 00 00       	add    $0xfff,%eax
801027b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801027bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027be:	eb 15                	jmp    801027d5 <freerange+0x31>
    kfree(p);
801027c0:	83 ec 0c             	sub    $0xc,%esp
801027c3:	ff 75 f4             	pushl  -0xc(%ebp)
801027c6:	e8 1b 00 00 00       	call   801027e6 <kfree>
801027cb:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801027ce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801027d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d8:	05 00 10 00 00       	add    $0x1000,%eax
801027dd:	39 45 0c             	cmp    %eax,0xc(%ebp)
801027e0:	73 de                	jae    801027c0 <freerange+0x1c>
}
801027e2:	90                   	nop
801027e3:	90                   	nop
801027e4:	c9                   	leave  
801027e5:	c3                   	ret    

801027e6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801027e6:	f3 0f 1e fb          	endbr32 
801027ea:	55                   	push   %ebp
801027eb:	89 e5                	mov    %esp,%ebp
801027ed:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801027f0:	8b 45 08             	mov    0x8(%ebp),%eax
801027f3:	25 ff 0f 00 00       	and    $0xfff,%eax
801027f8:	85 c0                	test   %eax,%eax
801027fa:	75 18                	jne    80102814 <kfree+0x2e>
801027fc:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102803:	72 0f                	jb     80102814 <kfree+0x2e>
80102805:	8b 45 08             	mov    0x8(%ebp),%eax
80102808:	05 00 00 00 80       	add    $0x80000000,%eax
8010280d:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102812:	76 0d                	jbe    80102821 <kfree+0x3b>
    panic("kfree");
80102814:	83 ec 0c             	sub    $0xc,%esp
80102817:	68 cb ab 10 80       	push   $0x8010abcb
8010281c:	e8 a4 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102821:	83 ec 04             	sub    $0x4,%esp
80102824:	68 00 10 00 00       	push   $0x1000
80102829:	6a 01                	push   $0x1
8010282b:	ff 75 08             	pushl  0x8(%ebp)
8010282e:	e8 38 27 00 00       	call   80104f6b <memset>
80102833:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102836:	a1 14 54 19 80       	mov    0x80195414,%eax
8010283b:	85 c0                	test   %eax,%eax
8010283d:	74 10                	je     8010284f <kfree+0x69>
    acquire(&kmem.lock);
8010283f:	83 ec 0c             	sub    $0xc,%esp
80102842:	68 e0 53 19 80       	push   $0x801953e0
80102847:	e8 90 24 00 00       	call   80104cdc <acquire>
8010284c:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
8010284f:	8b 45 08             	mov    0x8(%ebp),%eax
80102852:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102855:	8b 15 18 54 19 80    	mov    0x80195418,%edx
8010285b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010285e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102863:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
80102868:	a1 14 54 19 80       	mov    0x80195414,%eax
8010286d:	85 c0                	test   %eax,%eax
8010286f:	74 10                	je     80102881 <kfree+0x9b>
    release(&kmem.lock);
80102871:	83 ec 0c             	sub    $0xc,%esp
80102874:	68 e0 53 19 80       	push   $0x801953e0
80102879:	e8 d0 24 00 00       	call   80104d4e <release>
8010287e:	83 c4 10             	add    $0x10,%esp
}
80102881:	90                   	nop
80102882:	c9                   	leave  
80102883:	c3                   	ret    

80102884 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102884:	f3 0f 1e fb          	endbr32 
80102888:	55                   	push   %ebp
80102889:	89 e5                	mov    %esp,%ebp
8010288b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010288e:	a1 14 54 19 80       	mov    0x80195414,%eax
80102893:	85 c0                	test   %eax,%eax
80102895:	74 10                	je     801028a7 <kalloc+0x23>
    acquire(&kmem.lock);
80102897:	83 ec 0c             	sub    $0xc,%esp
8010289a:	68 e0 53 19 80       	push   $0x801953e0
8010289f:	e8 38 24 00 00       	call   80104cdc <acquire>
801028a4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801028a7:	a1 18 54 19 80       	mov    0x80195418,%eax
801028ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801028af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028b3:	74 0a                	je     801028bf <kalloc+0x3b>
    kmem.freelist = r->next;
801028b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b8:	8b 00                	mov    (%eax),%eax
801028ba:	a3 18 54 19 80       	mov    %eax,0x80195418
  if(kmem.use_lock)
801028bf:	a1 14 54 19 80       	mov    0x80195414,%eax
801028c4:	85 c0                	test   %eax,%eax
801028c6:	74 10                	je     801028d8 <kalloc+0x54>
    release(&kmem.lock);
801028c8:	83 ec 0c             	sub    $0xc,%esp
801028cb:	68 e0 53 19 80       	push   $0x801953e0
801028d0:	e8 79 24 00 00       	call   80104d4e <release>
801028d5:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801028d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801028db:	c9                   	leave  
801028dc:	c3                   	ret    

801028dd <inb>:
{
801028dd:	55                   	push   %ebp
801028de:	89 e5                	mov    %esp,%ebp
801028e0:	83 ec 14             	sub    $0x14,%esp
801028e3:	8b 45 08             	mov    0x8(%ebp),%eax
801028e6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028ea:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801028ee:	89 c2                	mov    %eax,%edx
801028f0:	ec                   	in     (%dx),%al
801028f1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801028f4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801028f8:	c9                   	leave  
801028f9:	c3                   	ret    

801028fa <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801028fa:	f3 0f 1e fb          	endbr32 
801028fe:	55                   	push   %ebp
801028ff:	89 e5                	mov    %esp,%ebp
80102901:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102904:	6a 64                	push   $0x64
80102906:	e8 d2 ff ff ff       	call   801028dd <inb>
8010290b:	83 c4 04             	add    $0x4,%esp
8010290e:	0f b6 c0             	movzbl %al,%eax
80102911:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102917:	83 e0 01             	and    $0x1,%eax
8010291a:	85 c0                	test   %eax,%eax
8010291c:	75 0a                	jne    80102928 <kbdgetc+0x2e>
    return -1;
8010291e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102923:	e9 23 01 00 00       	jmp    80102a4b <kbdgetc+0x151>
  data = inb(KBDATAP);
80102928:	6a 60                	push   $0x60
8010292a:	e8 ae ff ff ff       	call   801028dd <inb>
8010292f:	83 c4 04             	add    $0x4,%esp
80102932:	0f b6 c0             	movzbl %al,%eax
80102935:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102938:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010293f:	75 17                	jne    80102958 <kbdgetc+0x5e>
    shift |= E0ESC;
80102941:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102946:	83 c8 40             	or     $0x40,%eax
80102949:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
8010294e:	b8 00 00 00 00       	mov    $0x0,%eax
80102953:	e9 f3 00 00 00       	jmp    80102a4b <kbdgetc+0x151>
  } else if(data & 0x80){
80102958:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010295b:	25 80 00 00 00       	and    $0x80,%eax
80102960:	85 c0                	test   %eax,%eax
80102962:	74 45                	je     801029a9 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102964:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102969:	83 e0 40             	and    $0x40,%eax
8010296c:	85 c0                	test   %eax,%eax
8010296e:	75 08                	jne    80102978 <kbdgetc+0x7e>
80102970:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102973:	83 e0 7f             	and    $0x7f,%eax
80102976:	eb 03                	jmp    8010297b <kbdgetc+0x81>
80102978:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010297b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010297e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102981:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102986:	0f b6 00             	movzbl (%eax),%eax
80102989:	83 c8 40             	or     $0x40,%eax
8010298c:	0f b6 c0             	movzbl %al,%eax
8010298f:	f7 d0                	not    %eax
80102991:	89 c2                	mov    %eax,%edx
80102993:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102998:	21 d0                	and    %edx,%eax
8010299a:	a3 58 d0 18 80       	mov    %eax,0x8018d058
    return 0;
8010299f:	b8 00 00 00 00       	mov    $0x0,%eax
801029a4:	e9 a2 00 00 00       	jmp    80102a4b <kbdgetc+0x151>
  } else if(shift & E0ESC){
801029a9:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029ae:	83 e0 40             	and    $0x40,%eax
801029b1:	85 c0                	test   %eax,%eax
801029b3:	74 14                	je     801029c9 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801029b5:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801029bc:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029c1:	83 e0 bf             	and    $0xffffffbf,%eax
801029c4:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  }

  shift |= shiftcode[data];
801029c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029cc:	05 20 d0 10 80       	add    $0x8010d020,%eax
801029d1:	0f b6 00             	movzbl (%eax),%eax
801029d4:	0f b6 d0             	movzbl %al,%edx
801029d7:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029dc:	09 d0                	or     %edx,%eax
801029de:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  shift ^= togglecode[data];
801029e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029e6:	05 20 d1 10 80       	add    $0x8010d120,%eax
801029eb:	0f b6 00             	movzbl (%eax),%eax
801029ee:	0f b6 d0             	movzbl %al,%edx
801029f1:	a1 58 d0 18 80       	mov    0x8018d058,%eax
801029f6:	31 d0                	xor    %edx,%eax
801029f8:	a3 58 d0 18 80       	mov    %eax,0x8018d058
  c = charcode[shift & (CTL | SHIFT)][data];
801029fd:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a02:	83 e0 03             	and    $0x3,%eax
80102a05:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102a0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102a0f:	01 d0                	add    %edx,%eax
80102a11:	0f b6 00             	movzbl (%eax),%eax
80102a14:	0f b6 c0             	movzbl %al,%eax
80102a17:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102a1a:	a1 58 d0 18 80       	mov    0x8018d058,%eax
80102a1f:	83 e0 08             	and    $0x8,%eax
80102a22:	85 c0                	test   %eax,%eax
80102a24:	74 22                	je     80102a48 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102a26:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102a2a:	76 0c                	jbe    80102a38 <kbdgetc+0x13e>
80102a2c:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102a30:	77 06                	ja     80102a38 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102a32:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102a36:	eb 10                	jmp    80102a48 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102a38:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102a3c:	76 0a                	jbe    80102a48 <kbdgetc+0x14e>
80102a3e:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102a42:	77 04                	ja     80102a48 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102a44:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102a48:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102a4b:	c9                   	leave  
80102a4c:	c3                   	ret    

80102a4d <kbdintr>:

void
kbdintr(void)
{
80102a4d:	f3 0f 1e fb          	endbr32 
80102a51:	55                   	push   %ebp
80102a52:	89 e5                	mov    %esp,%ebp
80102a54:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102a57:	83 ec 0c             	sub    $0xc,%esp
80102a5a:	68 fa 28 10 80       	push   $0x801028fa
80102a5f:	e8 9c dd ff ff       	call   80100800 <consoleintr>
80102a64:	83 c4 10             	add    $0x10,%esp
}
80102a67:	90                   	nop
80102a68:	c9                   	leave  
80102a69:	c3                   	ret    

80102a6a <inb>:
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	83 ec 14             	sub    $0x14,%esp
80102a70:	8b 45 08             	mov    0x8(%ebp),%eax
80102a73:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a77:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102a7b:	89 c2                	mov    %eax,%edx
80102a7d:	ec                   	in     (%dx),%al
80102a7e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102a81:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102a85:	c9                   	leave  
80102a86:	c3                   	ret    

80102a87 <outb>:
{
80102a87:	55                   	push   %ebp
80102a88:	89 e5                	mov    %esp,%ebp
80102a8a:	83 ec 08             	sub    $0x8,%esp
80102a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a90:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a93:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102a97:	89 d0                	mov    %edx,%eax
80102a99:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a9c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102aa0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102aa4:	ee                   	out    %al,(%dx)
}
80102aa5:	90                   	nop
80102aa6:	c9                   	leave  
80102aa7:	c3                   	ret    

80102aa8 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102aa8:	f3 0f 1e fb          	endbr32 
80102aac:	55                   	push   %ebp
80102aad:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102aaf:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ab4:	8b 55 08             	mov    0x8(%ebp),%edx
80102ab7:	c1 e2 02             	shl    $0x2,%edx
80102aba:	01 c2                	add    %eax,%edx
80102abc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102abf:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ac1:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ac6:	83 c0 20             	add    $0x20,%eax
80102ac9:	8b 00                	mov    (%eax),%eax
}
80102acb:	90                   	nop
80102acc:	5d                   	pop    %ebp
80102acd:	c3                   	ret    

80102ace <lapicinit>:

void
lapicinit(void)
{
80102ace:	f3 0f 1e fb          	endbr32 
80102ad2:	55                   	push   %ebp
80102ad3:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ad5:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102ada:	85 c0                	test   %eax,%eax
80102adc:	0f 84 0c 01 00 00    	je     80102bee <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ae2:	68 3f 01 00 00       	push   $0x13f
80102ae7:	6a 3c                	push   $0x3c
80102ae9:	e8 ba ff ff ff       	call   80102aa8 <lapicw>
80102aee:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102af1:	6a 0b                	push   $0xb
80102af3:	68 f8 00 00 00       	push   $0xf8
80102af8:	e8 ab ff ff ff       	call   80102aa8 <lapicw>
80102afd:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102b00:	68 20 00 02 00       	push   $0x20020
80102b05:	68 c8 00 00 00       	push   $0xc8
80102b0a:	e8 99 ff ff ff       	call   80102aa8 <lapicw>
80102b0f:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102b12:	68 80 96 98 00       	push   $0x989680
80102b17:	68 e0 00 00 00       	push   $0xe0
80102b1c:	e8 87 ff ff ff       	call   80102aa8 <lapicw>
80102b21:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102b24:	68 00 00 01 00       	push   $0x10000
80102b29:	68 d4 00 00 00       	push   $0xd4
80102b2e:	e8 75 ff ff ff       	call   80102aa8 <lapicw>
80102b33:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102b36:	68 00 00 01 00       	push   $0x10000
80102b3b:	68 d8 00 00 00       	push   $0xd8
80102b40:	e8 63 ff ff ff       	call   80102aa8 <lapicw>
80102b45:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102b48:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102b4d:	83 c0 30             	add    $0x30,%eax
80102b50:	8b 00                	mov    (%eax),%eax
80102b52:	c1 e8 10             	shr    $0x10,%eax
80102b55:	25 fc 00 00 00       	and    $0xfc,%eax
80102b5a:	85 c0                	test   %eax,%eax
80102b5c:	74 12                	je     80102b70 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80102b5e:	68 00 00 01 00       	push   $0x10000
80102b63:	68 d0 00 00 00       	push   $0xd0
80102b68:	e8 3b ff ff ff       	call   80102aa8 <lapicw>
80102b6d:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102b70:	6a 33                	push   $0x33
80102b72:	68 dc 00 00 00       	push   $0xdc
80102b77:	e8 2c ff ff ff       	call   80102aa8 <lapicw>
80102b7c:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102b7f:	6a 00                	push   $0x0
80102b81:	68 a0 00 00 00       	push   $0xa0
80102b86:	e8 1d ff ff ff       	call   80102aa8 <lapicw>
80102b8b:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102b8e:	6a 00                	push   $0x0
80102b90:	68 a0 00 00 00       	push   $0xa0
80102b95:	e8 0e ff ff ff       	call   80102aa8 <lapicw>
80102b9a:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102b9d:	6a 00                	push   $0x0
80102b9f:	6a 2c                	push   $0x2c
80102ba1:	e8 02 ff ff ff       	call   80102aa8 <lapicw>
80102ba6:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ba9:	6a 00                	push   $0x0
80102bab:	68 c4 00 00 00       	push   $0xc4
80102bb0:	e8 f3 fe ff ff       	call   80102aa8 <lapicw>
80102bb5:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102bb8:	68 00 85 08 00       	push   $0x88500
80102bbd:	68 c0 00 00 00       	push   $0xc0
80102bc2:	e8 e1 fe ff ff       	call   80102aa8 <lapicw>
80102bc7:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102bca:	90                   	nop
80102bcb:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bd0:	05 00 03 00 00       	add    $0x300,%eax
80102bd5:	8b 00                	mov    (%eax),%eax
80102bd7:	25 00 10 00 00       	and    $0x1000,%eax
80102bdc:	85 c0                	test   %eax,%eax
80102bde:	75 eb                	jne    80102bcb <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102be0:	6a 00                	push   $0x0
80102be2:	6a 20                	push   $0x20
80102be4:	e8 bf fe ff ff       	call   80102aa8 <lapicw>
80102be9:	83 c4 08             	add    $0x8,%esp
80102bec:	eb 01                	jmp    80102bef <lapicinit+0x121>
    return;
80102bee:	90                   	nop
}
80102bef:	c9                   	leave  
80102bf0:	c3                   	ret    

80102bf1 <lapicid>:

int
lapicid(void)
{
80102bf1:	f3 0f 1e fb          	endbr32 
80102bf5:	55                   	push   %ebp
80102bf6:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102bf8:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102bfd:	85 c0                	test   %eax,%eax
80102bff:	75 07                	jne    80102c08 <lapicid+0x17>
    return 0;
80102c01:	b8 00 00 00 00       	mov    $0x0,%eax
80102c06:	eb 0d                	jmp    80102c15 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80102c08:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c0d:	83 c0 20             	add    $0x20,%eax
80102c10:	8b 00                	mov    (%eax),%eax
80102c12:	c1 e8 18             	shr    $0x18,%eax
}
80102c15:	5d                   	pop    %ebp
80102c16:	c3                   	ret    

80102c17 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102c17:	f3 0f 1e fb          	endbr32 
80102c1b:	55                   	push   %ebp
80102c1c:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c1e:	a1 1c 54 19 80       	mov    0x8019541c,%eax
80102c23:	85 c0                	test   %eax,%eax
80102c25:	74 0c                	je     80102c33 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80102c27:	6a 00                	push   $0x0
80102c29:	6a 2c                	push   $0x2c
80102c2b:	e8 78 fe ff ff       	call   80102aa8 <lapicw>
80102c30:	83 c4 08             	add    $0x8,%esp
}
80102c33:	90                   	nop
80102c34:	c9                   	leave  
80102c35:	c3                   	ret    

80102c36 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102c36:	f3 0f 1e fb          	endbr32 
80102c3a:	55                   	push   %ebp
80102c3b:	89 e5                	mov    %esp,%ebp
}
80102c3d:	90                   	nop
80102c3e:	5d                   	pop    %ebp
80102c3f:	c3                   	ret    

80102c40 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102c40:	f3 0f 1e fb          	endbr32 
80102c44:	55                   	push   %ebp
80102c45:	89 e5                	mov    %esp,%ebp
80102c47:	83 ec 14             	sub    $0x14,%esp
80102c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80102c4d:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102c50:	6a 0f                	push   $0xf
80102c52:	6a 70                	push   $0x70
80102c54:	e8 2e fe ff ff       	call   80102a87 <outb>
80102c59:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102c5c:	6a 0a                	push   $0xa
80102c5e:	6a 71                	push   $0x71
80102c60:	e8 22 fe ff ff       	call   80102a87 <outb>
80102c65:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102c68:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102c6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c72:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102c77:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c7a:	c1 e8 04             	shr    $0x4,%eax
80102c7d:	89 c2                	mov    %eax,%edx
80102c7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102c82:	83 c0 02             	add    $0x2,%eax
80102c85:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102c88:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102c8c:	c1 e0 18             	shl    $0x18,%eax
80102c8f:	50                   	push   %eax
80102c90:	68 c4 00 00 00       	push   $0xc4
80102c95:	e8 0e fe ff ff       	call   80102aa8 <lapicw>
80102c9a:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102c9d:	68 00 c5 00 00       	push   $0xc500
80102ca2:	68 c0 00 00 00       	push   $0xc0
80102ca7:	e8 fc fd ff ff       	call   80102aa8 <lapicw>
80102cac:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102caf:	68 c8 00 00 00       	push   $0xc8
80102cb4:	e8 7d ff ff ff       	call   80102c36 <microdelay>
80102cb9:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102cbc:	68 00 85 00 00       	push   $0x8500
80102cc1:	68 c0 00 00 00       	push   $0xc0
80102cc6:	e8 dd fd ff ff       	call   80102aa8 <lapicw>
80102ccb:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102cce:	6a 64                	push   $0x64
80102cd0:	e8 61 ff ff ff       	call   80102c36 <microdelay>
80102cd5:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102cd8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102cdf:	eb 3d                	jmp    80102d1e <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
80102ce1:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102ce5:	c1 e0 18             	shl    $0x18,%eax
80102ce8:	50                   	push   %eax
80102ce9:	68 c4 00 00 00       	push   $0xc4
80102cee:	e8 b5 fd ff ff       	call   80102aa8 <lapicw>
80102cf3:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cf9:	c1 e8 0c             	shr    $0xc,%eax
80102cfc:	80 cc 06             	or     $0x6,%ah
80102cff:	50                   	push   %eax
80102d00:	68 c0 00 00 00       	push   $0xc0
80102d05:	e8 9e fd ff ff       	call   80102aa8 <lapicw>
80102d0a:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102d0d:	68 c8 00 00 00       	push   $0xc8
80102d12:	e8 1f ff ff ff       	call   80102c36 <microdelay>
80102d17:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102d1a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102d1e:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102d22:	7e bd                	jle    80102ce1 <lapicstartap+0xa1>
  }
}
80102d24:	90                   	nop
80102d25:	90                   	nop
80102d26:	c9                   	leave  
80102d27:	c3                   	ret    

80102d28 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102d28:	f3 0f 1e fb          	endbr32 
80102d2c:	55                   	push   %ebp
80102d2d:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d32:	0f b6 c0             	movzbl %al,%eax
80102d35:	50                   	push   %eax
80102d36:	6a 70                	push   $0x70
80102d38:	e8 4a fd ff ff       	call   80102a87 <outb>
80102d3d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102d40:	68 c8 00 00 00       	push   $0xc8
80102d45:	e8 ec fe ff ff       	call   80102c36 <microdelay>
80102d4a:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102d4d:	6a 71                	push   $0x71
80102d4f:	e8 16 fd ff ff       	call   80102a6a <inb>
80102d54:	83 c4 04             	add    $0x4,%esp
80102d57:	0f b6 c0             	movzbl %al,%eax
}
80102d5a:	c9                   	leave  
80102d5b:	c3                   	ret    

80102d5c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102d5c:	f3 0f 1e fb          	endbr32 
80102d60:	55                   	push   %ebp
80102d61:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102d63:	6a 00                	push   $0x0
80102d65:	e8 be ff ff ff       	call   80102d28 <cmos_read>
80102d6a:	83 c4 04             	add    $0x4,%esp
80102d6d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d70:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102d72:	6a 02                	push   $0x2
80102d74:	e8 af ff ff ff       	call   80102d28 <cmos_read>
80102d79:	83 c4 04             	add    $0x4,%esp
80102d7c:	8b 55 08             	mov    0x8(%ebp),%edx
80102d7f:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102d82:	6a 04                	push   $0x4
80102d84:	e8 9f ff ff ff       	call   80102d28 <cmos_read>
80102d89:	83 c4 04             	add    $0x4,%esp
80102d8c:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8f:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102d92:	6a 07                	push   $0x7
80102d94:	e8 8f ff ff ff       	call   80102d28 <cmos_read>
80102d99:	83 c4 04             	add    $0x4,%esp
80102d9c:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9f:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102da2:	6a 08                	push   $0x8
80102da4:	e8 7f ff ff ff       	call   80102d28 <cmos_read>
80102da9:	83 c4 04             	add    $0x4,%esp
80102dac:	8b 55 08             	mov    0x8(%ebp),%edx
80102daf:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102db2:	6a 09                	push   $0x9
80102db4:	e8 6f ff ff ff       	call   80102d28 <cmos_read>
80102db9:	83 c4 04             	add    $0x4,%esp
80102dbc:	8b 55 08             	mov    0x8(%ebp),%edx
80102dbf:	89 42 14             	mov    %eax,0x14(%edx)
}
80102dc2:	90                   	nop
80102dc3:	c9                   	leave  
80102dc4:	c3                   	ret    

80102dc5 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102dc5:	f3 0f 1e fb          	endbr32 
80102dc9:	55                   	push   %ebp
80102dca:	89 e5                	mov    %esp,%ebp
80102dcc:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102dcf:	6a 0b                	push   $0xb
80102dd1:	e8 52 ff ff ff       	call   80102d28 <cmos_read>
80102dd6:	83 c4 04             	add    $0x4,%esp
80102dd9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ddf:	83 e0 04             	and    $0x4,%eax
80102de2:	85 c0                	test   %eax,%eax
80102de4:	0f 94 c0             	sete   %al
80102de7:	0f b6 c0             	movzbl %al,%eax
80102dea:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102ded:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102df0:	50                   	push   %eax
80102df1:	e8 66 ff ff ff       	call   80102d5c <fill_rtcdate>
80102df6:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102df9:	6a 0a                	push   $0xa
80102dfb:	e8 28 ff ff ff       	call   80102d28 <cmos_read>
80102e00:	83 c4 04             	add    $0x4,%esp
80102e03:	25 80 00 00 00       	and    $0x80,%eax
80102e08:	85 c0                	test   %eax,%eax
80102e0a:	75 27                	jne    80102e33 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80102e0c:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e0f:	50                   	push   %eax
80102e10:	e8 47 ff ff ff       	call   80102d5c <fill_rtcdate>
80102e15:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e18:	83 ec 04             	sub    $0x4,%esp
80102e1b:	6a 18                	push   $0x18
80102e1d:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102e20:	50                   	push   %eax
80102e21:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102e24:	50                   	push   %eax
80102e25:	e8 ac 21 00 00       	call   80104fd6 <memcmp>
80102e2a:	83 c4 10             	add    $0x10,%esp
80102e2d:	85 c0                	test   %eax,%eax
80102e2f:	74 05                	je     80102e36 <cmostime+0x71>
80102e31:	eb ba                	jmp    80102ded <cmostime+0x28>
        continue;
80102e33:	90                   	nop
    fill_rtcdate(&t1);
80102e34:	eb b7                	jmp    80102ded <cmostime+0x28>
      break;
80102e36:	90                   	nop
  }

  // convert
  if(bcd) {
80102e37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102e3b:	0f 84 b4 00 00 00    	je     80102ef5 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102e41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e44:	c1 e8 04             	shr    $0x4,%eax
80102e47:	89 c2                	mov    %eax,%edx
80102e49:	89 d0                	mov    %edx,%eax
80102e4b:	c1 e0 02             	shl    $0x2,%eax
80102e4e:	01 d0                	add    %edx,%eax
80102e50:	01 c0                	add    %eax,%eax
80102e52:	89 c2                	mov    %eax,%edx
80102e54:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102e57:	83 e0 0f             	and    $0xf,%eax
80102e5a:	01 d0                	add    %edx,%eax
80102e5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102e5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e62:	c1 e8 04             	shr    $0x4,%eax
80102e65:	89 c2                	mov    %eax,%edx
80102e67:	89 d0                	mov    %edx,%eax
80102e69:	c1 e0 02             	shl    $0x2,%eax
80102e6c:	01 d0                	add    %edx,%eax
80102e6e:	01 c0                	add    %eax,%eax
80102e70:	89 c2                	mov    %eax,%edx
80102e72:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102e75:	83 e0 0f             	and    $0xf,%eax
80102e78:	01 d0                	add    %edx,%eax
80102e7a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102e7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102e80:	c1 e8 04             	shr    $0x4,%eax
80102e83:	89 c2                	mov    %eax,%edx
80102e85:	89 d0                	mov    %edx,%eax
80102e87:	c1 e0 02             	shl    $0x2,%eax
80102e8a:	01 d0                	add    %edx,%eax
80102e8c:	01 c0                	add    %eax,%eax
80102e8e:	89 c2                	mov    %eax,%edx
80102e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102e93:	83 e0 0f             	and    $0xf,%eax
80102e96:	01 d0                	add    %edx,%eax
80102e98:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102e9e:	c1 e8 04             	shr    $0x4,%eax
80102ea1:	89 c2                	mov    %eax,%edx
80102ea3:	89 d0                	mov    %edx,%eax
80102ea5:	c1 e0 02             	shl    $0x2,%eax
80102ea8:	01 d0                	add    %edx,%eax
80102eaa:	01 c0                	add    %eax,%eax
80102eac:	89 c2                	mov    %eax,%edx
80102eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102eb1:	83 e0 0f             	and    $0xf,%eax
80102eb4:	01 d0                	add    %edx,%eax
80102eb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102eb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102ebc:	c1 e8 04             	shr    $0x4,%eax
80102ebf:	89 c2                	mov    %eax,%edx
80102ec1:	89 d0                	mov    %edx,%eax
80102ec3:	c1 e0 02             	shl    $0x2,%eax
80102ec6:	01 d0                	add    %edx,%eax
80102ec8:	01 c0                	add    %eax,%eax
80102eca:	89 c2                	mov    %eax,%edx
80102ecc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102ecf:	83 e0 0f             	and    $0xf,%eax
80102ed2:	01 d0                	add    %edx,%eax
80102ed4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102ed7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102eda:	c1 e8 04             	shr    $0x4,%eax
80102edd:	89 c2                	mov    %eax,%edx
80102edf:	89 d0                	mov    %edx,%eax
80102ee1:	c1 e0 02             	shl    $0x2,%eax
80102ee4:	01 d0                	add    %edx,%eax
80102ee6:	01 c0                	add    %eax,%eax
80102ee8:	89 c2                	mov    %eax,%edx
80102eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102eed:	83 e0 0f             	and    $0xf,%eax
80102ef0:	01 d0                	add    %edx,%eax
80102ef2:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ef8:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102efb:	89 10                	mov    %edx,(%eax)
80102efd:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102f00:	89 50 04             	mov    %edx,0x4(%eax)
80102f03:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102f06:	89 50 08             	mov    %edx,0x8(%eax)
80102f09:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f0c:	89 50 0c             	mov    %edx,0xc(%eax)
80102f0f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102f12:	89 50 10             	mov    %edx,0x10(%eax)
80102f15:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102f18:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80102f1e:	8b 40 14             	mov    0x14(%eax),%eax
80102f21:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102f27:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2a:	89 50 14             	mov    %edx,0x14(%eax)
}
80102f2d:	90                   	nop
80102f2e:	c9                   	leave  
80102f2f:	c3                   	ret    

80102f30 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102f30:	f3 0f 1e fb          	endbr32 
80102f34:	55                   	push   %ebp
80102f35:	89 e5                	mov    %esp,%ebp
80102f37:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102f3a:	83 ec 08             	sub    $0x8,%esp
80102f3d:	68 d1 ab 10 80       	push   $0x8010abd1
80102f42:	68 20 54 19 80       	push   $0x80195420
80102f47:	e8 6a 1d 00 00       	call   80104cb6 <initlock>
80102f4c:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102f4f:	83 ec 08             	sub    $0x8,%esp
80102f52:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102f55:	50                   	push   %eax
80102f56:	ff 75 08             	pushl  0x8(%ebp)
80102f59:	e8 c0 e4 ff ff       	call   8010141e <readsb>
80102f5e:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f64:	a3 54 54 19 80       	mov    %eax,0x80195454
  log.size = sb.nlog;
80102f69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102f6c:	a3 58 54 19 80       	mov    %eax,0x80195458
  log.dev = dev;
80102f71:	8b 45 08             	mov    0x8(%ebp),%eax
80102f74:	a3 64 54 19 80       	mov    %eax,0x80195464
  recover_from_log();
80102f79:	e8 bf 01 00 00       	call   8010313d <recover_from_log>
}
80102f7e:	90                   	nop
80102f7f:	c9                   	leave  
80102f80:	c3                   	ret    

80102f81 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102f81:	f3 0f 1e fb          	endbr32 
80102f85:	55                   	push   %ebp
80102f86:	89 e5                	mov    %esp,%ebp
80102f88:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102f8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f92:	e9 95 00 00 00       	jmp    8010302c <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102f97:	8b 15 54 54 19 80    	mov    0x80195454,%edx
80102f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fa0:	01 d0                	add    %edx,%eax
80102fa2:	83 c0 01             	add    $0x1,%eax
80102fa5:	89 c2                	mov    %eax,%edx
80102fa7:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fac:	83 ec 08             	sub    $0x8,%esp
80102faf:	52                   	push   %edx
80102fb0:	50                   	push   %eax
80102fb1:	e8 53 d2 ff ff       	call   80100209 <bread>
80102fb6:	83 c4 10             	add    $0x10,%esp
80102fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fbf:	83 c0 10             	add    $0x10,%eax
80102fc2:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80102fc9:	89 c2                	mov    %eax,%edx
80102fcb:	a1 64 54 19 80       	mov    0x80195464,%eax
80102fd0:	83 ec 08             	sub    $0x8,%esp
80102fd3:	52                   	push   %edx
80102fd4:	50                   	push   %eax
80102fd5:	e8 2f d2 ff ff       	call   80100209 <bread>
80102fda:	83 c4 10             	add    $0x10,%esp
80102fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fe3:	8d 50 5c             	lea    0x5c(%eax),%edx
80102fe6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe9:	83 c0 5c             	add    $0x5c,%eax
80102fec:	83 ec 04             	sub    $0x4,%esp
80102fef:	68 00 02 00 00       	push   $0x200
80102ff4:	52                   	push   %edx
80102ff5:	50                   	push   %eax
80102ff6:	e8 37 20 00 00       	call   80105032 <memmove>
80102ffb:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ffe:	83 ec 0c             	sub    $0xc,%esp
80103001:	ff 75 ec             	pushl  -0x14(%ebp)
80103004:	e8 3d d2 ff ff       	call   80100246 <bwrite>
80103009:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010300c:	83 ec 0c             	sub    $0xc,%esp
8010300f:	ff 75 f0             	pushl  -0x10(%ebp)
80103012:	e8 7c d2 ff ff       	call   80100293 <brelse>
80103017:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010301a:	83 ec 0c             	sub    $0xc,%esp
8010301d:	ff 75 ec             	pushl  -0x14(%ebp)
80103020:	e8 6e d2 ff ff       	call   80100293 <brelse>
80103025:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103028:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010302c:	a1 68 54 19 80       	mov    0x80195468,%eax
80103031:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103034:	0f 8c 5d ff ff ff    	jl     80102f97 <install_trans+0x16>
  }
}
8010303a:	90                   	nop
8010303b:	90                   	nop
8010303c:	c9                   	leave  
8010303d:	c3                   	ret    

8010303e <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010303e:	f3 0f 1e fb          	endbr32 
80103042:	55                   	push   %ebp
80103043:	89 e5                	mov    %esp,%ebp
80103045:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103048:	a1 54 54 19 80       	mov    0x80195454,%eax
8010304d:	89 c2                	mov    %eax,%edx
8010304f:	a1 64 54 19 80       	mov    0x80195464,%eax
80103054:	83 ec 08             	sub    $0x8,%esp
80103057:	52                   	push   %edx
80103058:	50                   	push   %eax
80103059:	e8 ab d1 ff ff       	call   80100209 <bread>
8010305e:	83 c4 10             	add    $0x10,%esp
80103061:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103064:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103067:	83 c0 5c             	add    $0x5c,%eax
8010306a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010306d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103070:	8b 00                	mov    (%eax),%eax
80103072:	a3 68 54 19 80       	mov    %eax,0x80195468
  for (i = 0; i < log.lh.n; i++) {
80103077:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010307e:	eb 1b                	jmp    8010309b <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
80103080:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103083:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103086:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010308a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010308d:	83 c2 10             	add    $0x10,%edx
80103090:	89 04 95 2c 54 19 80 	mov    %eax,-0x7fe6abd4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103097:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010309b:	a1 68 54 19 80       	mov    0x80195468,%eax
801030a0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801030a3:	7c db                	jl     80103080 <read_head+0x42>
  }
  brelse(buf);
801030a5:	83 ec 0c             	sub    $0xc,%esp
801030a8:	ff 75 f0             	pushl  -0x10(%ebp)
801030ab:	e8 e3 d1 ff ff       	call   80100293 <brelse>
801030b0:	83 c4 10             	add    $0x10,%esp
}
801030b3:	90                   	nop
801030b4:	c9                   	leave  
801030b5:	c3                   	ret    

801030b6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801030b6:	f3 0f 1e fb          	endbr32 
801030ba:	55                   	push   %ebp
801030bb:	89 e5                	mov    %esp,%ebp
801030bd:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801030c0:	a1 54 54 19 80       	mov    0x80195454,%eax
801030c5:	89 c2                	mov    %eax,%edx
801030c7:	a1 64 54 19 80       	mov    0x80195464,%eax
801030cc:	83 ec 08             	sub    $0x8,%esp
801030cf:	52                   	push   %edx
801030d0:	50                   	push   %eax
801030d1:	e8 33 d1 ff ff       	call   80100209 <bread>
801030d6:	83 c4 10             	add    $0x10,%esp
801030d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801030dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030df:	83 c0 5c             	add    $0x5c,%eax
801030e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801030e5:	8b 15 68 54 19 80    	mov    0x80195468,%edx
801030eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030ee:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801030f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030f7:	eb 1b                	jmp    80103114 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801030f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030fc:	83 c0 10             	add    $0x10,%eax
801030ff:	8b 0c 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%ecx
80103106:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103109:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010310c:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103110:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103114:	a1 68 54 19 80       	mov    0x80195468,%eax
80103119:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010311c:	7c db                	jl     801030f9 <write_head+0x43>
  }
  bwrite(buf);
8010311e:	83 ec 0c             	sub    $0xc,%esp
80103121:	ff 75 f0             	pushl  -0x10(%ebp)
80103124:	e8 1d d1 ff ff       	call   80100246 <bwrite>
80103129:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010312c:	83 ec 0c             	sub    $0xc,%esp
8010312f:	ff 75 f0             	pushl  -0x10(%ebp)
80103132:	e8 5c d1 ff ff       	call   80100293 <brelse>
80103137:	83 c4 10             	add    $0x10,%esp
}
8010313a:	90                   	nop
8010313b:	c9                   	leave  
8010313c:	c3                   	ret    

8010313d <recover_from_log>:

static void
recover_from_log(void)
{
8010313d:	f3 0f 1e fb          	endbr32 
80103141:	55                   	push   %ebp
80103142:	89 e5                	mov    %esp,%ebp
80103144:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103147:	e8 f2 fe ff ff       	call   8010303e <read_head>
  install_trans(); // if committed, copy from log to disk
8010314c:	e8 30 fe ff ff       	call   80102f81 <install_trans>
  log.lh.n = 0;
80103151:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
80103158:	00 00 00 
  write_head(); // clear the log
8010315b:	e8 56 ff ff ff       	call   801030b6 <write_head>
}
80103160:	90                   	nop
80103161:	c9                   	leave  
80103162:	c3                   	ret    

80103163 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103163:	f3 0f 1e fb          	endbr32 
80103167:	55                   	push   %ebp
80103168:	89 e5                	mov    %esp,%ebp
8010316a:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010316d:	83 ec 0c             	sub    $0xc,%esp
80103170:	68 20 54 19 80       	push   $0x80195420
80103175:	e8 62 1b 00 00       	call   80104cdc <acquire>
8010317a:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010317d:	a1 60 54 19 80       	mov    0x80195460,%eax
80103182:	85 c0                	test   %eax,%eax
80103184:	74 17                	je     8010319d <begin_op+0x3a>
      sleep(&log, &log.lock);
80103186:	83 ec 08             	sub    $0x8,%esp
80103189:	68 20 54 19 80       	push   $0x80195420
8010318e:	68 20 54 19 80       	push   $0x80195420
80103193:	e8 9a 15 00 00       	call   80104732 <sleep>
80103198:	83 c4 10             	add    $0x10,%esp
8010319b:	eb e0                	jmp    8010317d <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010319d:	8b 0d 68 54 19 80    	mov    0x80195468,%ecx
801031a3:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031a8:	8d 50 01             	lea    0x1(%eax),%edx
801031ab:	89 d0                	mov    %edx,%eax
801031ad:	c1 e0 02             	shl    $0x2,%eax
801031b0:	01 d0                	add    %edx,%eax
801031b2:	01 c0                	add    %eax,%eax
801031b4:	01 c8                	add    %ecx,%eax
801031b6:	83 f8 1e             	cmp    $0x1e,%eax
801031b9:	7e 17                	jle    801031d2 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801031bb:	83 ec 08             	sub    $0x8,%esp
801031be:	68 20 54 19 80       	push   $0x80195420
801031c3:	68 20 54 19 80       	push   $0x80195420
801031c8:	e8 65 15 00 00       	call   80104732 <sleep>
801031cd:	83 c4 10             	add    $0x10,%esp
801031d0:	eb ab                	jmp    8010317d <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801031d2:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801031d7:	83 c0 01             	add    $0x1,%eax
801031da:	a3 5c 54 19 80       	mov    %eax,0x8019545c
      release(&log.lock);
801031df:	83 ec 0c             	sub    $0xc,%esp
801031e2:	68 20 54 19 80       	push   $0x80195420
801031e7:	e8 62 1b 00 00       	call   80104d4e <release>
801031ec:	83 c4 10             	add    $0x10,%esp
      break;
801031ef:	90                   	nop
    }
  }
}
801031f0:	90                   	nop
801031f1:	c9                   	leave  
801031f2:	c3                   	ret    

801031f3 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801031f3:	f3 0f 1e fb          	endbr32 
801031f7:	55                   	push   %ebp
801031f8:	89 e5                	mov    %esp,%ebp
801031fa:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801031fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103204:	83 ec 0c             	sub    $0xc,%esp
80103207:	68 20 54 19 80       	push   $0x80195420
8010320c:	e8 cb 1a 00 00       	call   80104cdc <acquire>
80103211:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103214:	a1 5c 54 19 80       	mov    0x8019545c,%eax
80103219:	83 e8 01             	sub    $0x1,%eax
8010321c:	a3 5c 54 19 80       	mov    %eax,0x8019545c
  if(log.committing)
80103221:	a1 60 54 19 80       	mov    0x80195460,%eax
80103226:	85 c0                	test   %eax,%eax
80103228:	74 0d                	je     80103237 <end_op+0x44>
    panic("log.committing");
8010322a:	83 ec 0c             	sub    $0xc,%esp
8010322d:	68 d5 ab 10 80       	push   $0x8010abd5
80103232:	e8 8e d3 ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
80103237:	a1 5c 54 19 80       	mov    0x8019545c,%eax
8010323c:	85 c0                	test   %eax,%eax
8010323e:	75 13                	jne    80103253 <end_op+0x60>
    do_commit = 1;
80103240:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103247:	c7 05 60 54 19 80 01 	movl   $0x1,0x80195460
8010324e:	00 00 00 
80103251:	eb 10                	jmp    80103263 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103253:	83 ec 0c             	sub    $0xc,%esp
80103256:	68 20 54 19 80       	push   $0x80195420
8010325b:	e8 c4 15 00 00       	call   80104824 <wakeup>
80103260:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103263:	83 ec 0c             	sub    $0xc,%esp
80103266:	68 20 54 19 80       	push   $0x80195420
8010326b:	e8 de 1a 00 00       	call   80104d4e <release>
80103270:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103273:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103277:	74 3f                	je     801032b8 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103279:	e8 fa 00 00 00       	call   80103378 <commit>
    acquire(&log.lock);
8010327e:	83 ec 0c             	sub    $0xc,%esp
80103281:	68 20 54 19 80       	push   $0x80195420
80103286:	e8 51 1a 00 00       	call   80104cdc <acquire>
8010328b:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010328e:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
80103295:	00 00 00 
    wakeup(&log);
80103298:	83 ec 0c             	sub    $0xc,%esp
8010329b:	68 20 54 19 80       	push   $0x80195420
801032a0:	e8 7f 15 00 00       	call   80104824 <wakeup>
801032a5:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032a8:	83 ec 0c             	sub    $0xc,%esp
801032ab:	68 20 54 19 80       	push   $0x80195420
801032b0:	e8 99 1a 00 00       	call   80104d4e <release>
801032b5:	83 c4 10             	add    $0x10,%esp
  }
}
801032b8:	90                   	nop
801032b9:	c9                   	leave  
801032ba:	c3                   	ret    

801032bb <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801032bb:	f3 0f 1e fb          	endbr32 
801032bf:	55                   	push   %ebp
801032c0:	89 e5                	mov    %esp,%ebp
801032c2:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032cc:	e9 95 00 00 00       	jmp    80103366 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801032d1:	8b 15 54 54 19 80    	mov    0x80195454,%edx
801032d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032da:	01 d0                	add    %edx,%eax
801032dc:	83 c0 01             	add    $0x1,%eax
801032df:	89 c2                	mov    %eax,%edx
801032e1:	a1 64 54 19 80       	mov    0x80195464,%eax
801032e6:	83 ec 08             	sub    $0x8,%esp
801032e9:	52                   	push   %edx
801032ea:	50                   	push   %eax
801032eb:	e8 19 cf ff ff       	call   80100209 <bread>
801032f0:	83 c4 10             	add    $0x10,%esp
801032f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801032f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032f9:	83 c0 10             	add    $0x10,%eax
801032fc:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	a1 64 54 19 80       	mov    0x80195464,%eax
8010330a:	83 ec 08             	sub    $0x8,%esp
8010330d:	52                   	push   %edx
8010330e:	50                   	push   %eax
8010330f:	e8 f5 ce ff ff       	call   80100209 <bread>
80103314:	83 c4 10             	add    $0x10,%esp
80103317:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010331a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010331d:	8d 50 5c             	lea    0x5c(%eax),%edx
80103320:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103323:	83 c0 5c             	add    $0x5c,%eax
80103326:	83 ec 04             	sub    $0x4,%esp
80103329:	68 00 02 00 00       	push   $0x200
8010332e:	52                   	push   %edx
8010332f:	50                   	push   %eax
80103330:	e8 fd 1c 00 00       	call   80105032 <memmove>
80103335:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103338:	83 ec 0c             	sub    $0xc,%esp
8010333b:	ff 75 f0             	pushl  -0x10(%ebp)
8010333e:	e8 03 cf ff ff       	call   80100246 <bwrite>
80103343:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103346:	83 ec 0c             	sub    $0xc,%esp
80103349:	ff 75 ec             	pushl  -0x14(%ebp)
8010334c:	e8 42 cf ff ff       	call   80100293 <brelse>
80103351:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103354:	83 ec 0c             	sub    $0xc,%esp
80103357:	ff 75 f0             	pushl  -0x10(%ebp)
8010335a:	e8 34 cf ff ff       	call   80100293 <brelse>
8010335f:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103362:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103366:	a1 68 54 19 80       	mov    0x80195468,%eax
8010336b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010336e:	0f 8c 5d ff ff ff    	jl     801032d1 <write_log+0x16>
  }
}
80103374:	90                   	nop
80103375:	90                   	nop
80103376:	c9                   	leave  
80103377:	c3                   	ret    

80103378 <commit>:

static void
commit()
{
80103378:	f3 0f 1e fb          	endbr32 
8010337c:	55                   	push   %ebp
8010337d:	89 e5                	mov    %esp,%ebp
8010337f:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103382:	a1 68 54 19 80       	mov    0x80195468,%eax
80103387:	85 c0                	test   %eax,%eax
80103389:	7e 1e                	jle    801033a9 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
8010338b:	e8 2b ff ff ff       	call   801032bb <write_log>
    write_head();    // Write header to disk -- the real commit
80103390:	e8 21 fd ff ff       	call   801030b6 <write_head>
    install_trans(); // Now install writes to home locations
80103395:	e8 e7 fb ff ff       	call   80102f81 <install_trans>
    log.lh.n = 0;
8010339a:	c7 05 68 54 19 80 00 	movl   $0x0,0x80195468
801033a1:	00 00 00 
    write_head();    // Erase the transaction from the log
801033a4:	e8 0d fd ff ff       	call   801030b6 <write_head>
  }
}
801033a9:	90                   	nop
801033aa:	c9                   	leave  
801033ab:	c3                   	ret    

801033ac <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801033ac:	f3 0f 1e fb          	endbr32 
801033b0:	55                   	push   %ebp
801033b1:	89 e5                	mov    %esp,%ebp
801033b3:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801033b6:	a1 68 54 19 80       	mov    0x80195468,%eax
801033bb:	83 f8 1d             	cmp    $0x1d,%eax
801033be:	7f 12                	jg     801033d2 <log_write+0x26>
801033c0:	a1 68 54 19 80       	mov    0x80195468,%eax
801033c5:	8b 15 58 54 19 80    	mov    0x80195458,%edx
801033cb:	83 ea 01             	sub    $0x1,%edx
801033ce:	39 d0                	cmp    %edx,%eax
801033d0:	7c 0d                	jl     801033df <log_write+0x33>
    panic("too big a transaction");
801033d2:	83 ec 0c             	sub    $0xc,%esp
801033d5:	68 e4 ab 10 80       	push   $0x8010abe4
801033da:	e8 e6 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033df:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033e4:	85 c0                	test   %eax,%eax
801033e6:	7f 0d                	jg     801033f5 <log_write+0x49>
    panic("log_write outside of trans");
801033e8:	83 ec 0c             	sub    $0xc,%esp
801033eb:	68 fa ab 10 80       	push   $0x8010abfa
801033f0:	e8 d0 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
801033f5:	83 ec 0c             	sub    $0xc,%esp
801033f8:	68 20 54 19 80       	push   $0x80195420
801033fd:	e8 da 18 00 00       	call   80104cdc <acquire>
80103402:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103405:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010340c:	eb 1d                	jmp    8010342b <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010340e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103411:	83 c0 10             	add    $0x10,%eax
80103414:	8b 04 85 2c 54 19 80 	mov    -0x7fe6abd4(,%eax,4),%eax
8010341b:	89 c2                	mov    %eax,%edx
8010341d:	8b 45 08             	mov    0x8(%ebp),%eax
80103420:	8b 40 08             	mov    0x8(%eax),%eax
80103423:	39 c2                	cmp    %eax,%edx
80103425:	74 10                	je     80103437 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103427:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010342b:	a1 68 54 19 80       	mov    0x80195468,%eax
80103430:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103433:	7c d9                	jl     8010340e <log_write+0x62>
80103435:	eb 01                	jmp    80103438 <log_write+0x8c>
      break;
80103437:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103438:	8b 45 08             	mov    0x8(%ebp),%eax
8010343b:	8b 40 08             	mov    0x8(%eax),%eax
8010343e:	89 c2                	mov    %eax,%edx
80103440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103443:	83 c0 10             	add    $0x10,%eax
80103446:	89 14 85 2c 54 19 80 	mov    %edx,-0x7fe6abd4(,%eax,4)
  if (i == log.lh.n)
8010344d:	a1 68 54 19 80       	mov    0x80195468,%eax
80103452:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103455:	75 0d                	jne    80103464 <log_write+0xb8>
    log.lh.n++;
80103457:	a1 68 54 19 80       	mov    0x80195468,%eax
8010345c:	83 c0 01             	add    $0x1,%eax
8010345f:	a3 68 54 19 80       	mov    %eax,0x80195468
  b->flags |= B_DIRTY; // prevent eviction
80103464:	8b 45 08             	mov    0x8(%ebp),%eax
80103467:	8b 00                	mov    (%eax),%eax
80103469:	83 c8 04             	or     $0x4,%eax
8010346c:	89 c2                	mov    %eax,%edx
8010346e:	8b 45 08             	mov    0x8(%ebp),%eax
80103471:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103473:	83 ec 0c             	sub    $0xc,%esp
80103476:	68 20 54 19 80       	push   $0x80195420
8010347b:	e8 ce 18 00 00       	call   80104d4e <release>
80103480:	83 c4 10             	add    $0x10,%esp
}
80103483:	90                   	nop
80103484:	c9                   	leave  
80103485:	c3                   	ret    

80103486 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103486:	55                   	push   %ebp
80103487:	89 e5                	mov    %esp,%ebp
80103489:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010348c:	8b 55 08             	mov    0x8(%ebp),%edx
8010348f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103492:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103495:	f0 87 02             	lock xchg %eax,(%edx)
80103498:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010349b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010349e:	c9                   	leave  
8010349f:	c3                   	ret    

801034a0 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801034a0:	f3 0f 1e fb          	endbr32 
801034a4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801034a8:	83 e4 f0             	and    $0xfffffff0,%esp
801034ab:	ff 71 fc             	pushl  -0x4(%ecx)
801034ae:	55                   	push   %ebp
801034af:	89 e5                	mov    %esp,%ebp
801034b1:	51                   	push   %ecx
801034b2:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
801034b5:	e8 dc 51 00 00       	call   80108696 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034ba:	83 ec 08             	sub    $0x8,%esp
801034bd:	68 00 00 40 80       	push   $0x80400000
801034c2:	68 00 90 19 80       	push   $0x80199000
801034c7:	e8 73 f2 ff ff       	call   8010273f <kinit1>
801034cc:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034cf:	e8 bd 46 00 00       	call   80107b91 <kvmalloc>
  mpinit_uefi();
801034d4:	e8 76 4f 00 00       	call   8010844f <mpinit_uefi>
  lapicinit();     // interrupt controller
801034d9:	e8 f0 f5 ff ff       	call   80102ace <lapicinit>
  seginit();       // segment descriptors
801034de:	e8 35 41 00 00       	call   80107618 <seginit>
  picinit();    // disable pic
801034e3:	e8 a9 01 00 00       	call   80103691 <picinit>
  ioapicinit();    // another interrupt controller
801034e8:	e8 65 f1 ff ff       	call   80102652 <ioapicinit>
  consoleinit();   // console hardware
801034ed:	e8 47 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
801034f2:	e8 aa 34 00 00       	call   801069a1 <uartinit>
  pinit();         // process table
801034f7:	e8 e2 05 00 00       	call   80103ade <pinit>
  tvinit();        // trap vectors
801034fc:	e8 cb 2f 00 00       	call   801064cc <tvinit>
  binit();         // buffer cache
80103501:	e8 60 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103506:	e8 e8 da ff ff       	call   80100ff3 <fileinit>
  ideinit();       // disk 
8010350b:	e8 8b 73 00 00       	call   8010a89b <ideinit>
  startothers();   // start other processors
80103510:	e8 92 00 00 00       	call   801035a7 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103515:	83 ec 08             	sub    $0x8,%esp
80103518:	68 00 00 00 a0       	push   $0xa0000000
8010351d:	68 00 00 40 80       	push   $0x80400000
80103522:	e8 55 f2 ff ff       	call   8010277c <kinit2>
80103527:	83 c4 10             	add    $0x10,%esp
  pci_init();
8010352a:	e8 da 53 00 00       	call   80108909 <pci_init>
  arp_scan();
8010352f:	e8 53 61 00 00       	call   80109687 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103534:	e8 ab 07 00 00       	call   80103ce4 <userinit>

  mpmain();        // finish this processor's setup
80103539:	e8 1e 00 00 00       	call   8010355c <mpmain>

8010353e <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010353e:	f3 0f 1e fb          	endbr32 
80103542:	55                   	push   %ebp
80103543:	89 e5                	mov    %esp,%ebp
80103545:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103548:	e8 60 46 00 00       	call   80107bad <switchkvm>
  seginit();
8010354d:	e8 c6 40 00 00       	call   80107618 <seginit>
  lapicinit();
80103552:	e8 77 f5 ff ff       	call   80102ace <lapicinit>
  mpmain();
80103557:	e8 00 00 00 00       	call   8010355c <mpmain>

8010355c <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010355c:	f3 0f 1e fb          	endbr32 
80103560:	55                   	push   %ebp
80103561:	89 e5                	mov    %esp,%ebp
80103563:	53                   	push   %ebx
80103564:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103567:	e8 94 05 00 00       	call   80103b00 <cpuid>
8010356c:	89 c3                	mov    %eax,%ebx
8010356e:	e8 8d 05 00 00       	call   80103b00 <cpuid>
80103573:	83 ec 04             	sub    $0x4,%esp
80103576:	53                   	push   %ebx
80103577:	50                   	push   %eax
80103578:	68 15 ac 10 80       	push   $0x8010ac15
8010357d:	e8 8a ce ff ff       	call   8010040c <cprintf>
80103582:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103585:	e8 bc 30 00 00       	call   80106646 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010358a:	e8 90 05 00 00       	call   80103b1f <mycpu>
8010358f:	05 a0 00 00 00       	add    $0xa0,%eax
80103594:	83 ec 08             	sub    $0x8,%esp
80103597:	6a 01                	push   $0x1
80103599:	50                   	push   %eax
8010359a:	e8 e7 fe ff ff       	call   80103486 <xchg>
8010359f:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035a2:	e8 87 0f 00 00       	call   8010452e <scheduler>

801035a7 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801035a7:	f3 0f 1e fb          	endbr32 
801035ab:	55                   	push   %ebp
801035ac:	89 e5                	mov    %esp,%ebp
801035ae:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801035b1:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801035b8:	b8 8a 00 00 00       	mov    $0x8a,%eax
801035bd:	83 ec 04             	sub    $0x4,%esp
801035c0:	50                   	push   %eax
801035c1:	68 38 f5 10 80       	push   $0x8010f538
801035c6:	ff 75 f0             	pushl  -0x10(%ebp)
801035c9:	e8 64 1a 00 00       	call   80105032 <memmove>
801035ce:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801035d1:	c7 45 f4 c0 81 19 80 	movl   $0x801981c0,-0xc(%ebp)
801035d8:	eb 79                	jmp    80103653 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
801035da:	e8 40 05 00 00       	call   80103b1f <mycpu>
801035df:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035e2:	74 67                	je     8010364b <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801035e4:	e8 9b f2 ff ff       	call   80102884 <kalloc>
801035e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801035ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ef:	83 e8 04             	sub    $0x4,%eax
801035f2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801035f5:	81 c2 00 10 00 00    	add    $0x1000,%edx
801035fb:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801035fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103600:	83 e8 08             	sub    $0x8,%eax
80103603:	c7 00 3e 35 10 80    	movl   $0x8010353e,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103609:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
8010360e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103614:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103617:	83 e8 0c             	sub    $0xc,%eax
8010361a:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
8010361c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010361f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103628:	0f b6 00             	movzbl (%eax),%eax
8010362b:	0f b6 c0             	movzbl %al,%eax
8010362e:	83 ec 08             	sub    $0x8,%esp
80103631:	52                   	push   %edx
80103632:	50                   	push   %eax
80103633:	e8 08 f6 ff ff       	call   80102c40 <lapicstartap>
80103638:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010363b:	90                   	nop
8010363c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010363f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103645:	85 c0                	test   %eax,%eax
80103647:	74 f3                	je     8010363c <startothers+0x95>
80103649:	eb 01                	jmp    8010364c <startothers+0xa5>
      continue;
8010364b:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
8010364c:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103653:	a1 80 84 19 80       	mov    0x80198480,%eax
80103658:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010365e:	05 c0 81 19 80       	add    $0x801981c0,%eax
80103663:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103666:	0f 82 6e ff ff ff    	jb     801035da <startothers+0x33>
      ;
  }
}
8010366c:	90                   	nop
8010366d:	90                   	nop
8010366e:	c9                   	leave  
8010366f:	c3                   	ret    

80103670 <outb>:
{
80103670:	55                   	push   %ebp
80103671:	89 e5                	mov    %esp,%ebp
80103673:	83 ec 08             	sub    $0x8,%esp
80103676:	8b 45 08             	mov    0x8(%ebp),%eax
80103679:	8b 55 0c             	mov    0xc(%ebp),%edx
8010367c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103680:	89 d0                	mov    %edx,%eax
80103682:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103685:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103689:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010368d:	ee                   	out    %al,(%dx)
}
8010368e:	90                   	nop
8010368f:	c9                   	leave  
80103690:	c3                   	ret    

80103691 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103691:	f3 0f 1e fb          	endbr32 
80103695:	55                   	push   %ebp
80103696:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103698:	68 ff 00 00 00       	push   $0xff
8010369d:	6a 21                	push   $0x21
8010369f:	e8 cc ff ff ff       	call   80103670 <outb>
801036a4:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801036a7:	68 ff 00 00 00       	push   $0xff
801036ac:	68 a1 00 00 00       	push   $0xa1
801036b1:	e8 ba ff ff ff       	call   80103670 <outb>
801036b6:	83 c4 08             	add    $0x8,%esp
}
801036b9:	90                   	nop
801036ba:	c9                   	leave  
801036bb:	c3                   	ret    

801036bc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801036bc:	f3 0f 1e fb          	endbr32 
801036c0:	55                   	push   %ebp
801036c1:	89 e5                	mov    %esp,%ebp
801036c3:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801036c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801036cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801036d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801036d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801036d9:	8b 10                	mov    (%eax),%edx
801036db:	8b 45 08             	mov    0x8(%ebp),%eax
801036de:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801036e0:	e8 30 d9 ff ff       	call   80101015 <filealloc>
801036e5:	8b 55 08             	mov    0x8(%ebp),%edx
801036e8:	89 02                	mov    %eax,(%edx)
801036ea:	8b 45 08             	mov    0x8(%ebp),%eax
801036ed:	8b 00                	mov    (%eax),%eax
801036ef:	85 c0                	test   %eax,%eax
801036f1:	0f 84 c8 00 00 00    	je     801037bf <pipealloc+0x103>
801036f7:	e8 19 d9 ff ff       	call   80101015 <filealloc>
801036fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801036ff:	89 02                	mov    %eax,(%edx)
80103701:	8b 45 0c             	mov    0xc(%ebp),%eax
80103704:	8b 00                	mov    (%eax),%eax
80103706:	85 c0                	test   %eax,%eax
80103708:	0f 84 b1 00 00 00    	je     801037bf <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010370e:	e8 71 f1 ff ff       	call   80102884 <kalloc>
80103713:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103716:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010371a:	0f 84 a2 00 00 00    	je     801037c2 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80103720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103723:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010372a:	00 00 00 
  p->writeopen = 1;
8010372d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103730:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103737:	00 00 00 
  p->nwrite = 0;
8010373a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010373d:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103744:	00 00 00 
  p->nread = 0;
80103747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374a:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103751:	00 00 00 
  initlock(&p->lock, "pipe");
80103754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103757:	83 ec 08             	sub    $0x8,%esp
8010375a:	68 29 ac 10 80       	push   $0x8010ac29
8010375f:	50                   	push   %eax
80103760:	e8 51 15 00 00       	call   80104cb6 <initlock>
80103765:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103768:	8b 45 08             	mov    0x8(%ebp),%eax
8010376b:	8b 00                	mov    (%eax),%eax
8010376d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103773:	8b 45 08             	mov    0x8(%ebp),%eax
80103776:	8b 00                	mov    (%eax),%eax
80103778:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010377c:	8b 45 08             	mov    0x8(%ebp),%eax
8010377f:	8b 00                	mov    (%eax),%eax
80103781:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103785:	8b 45 08             	mov    0x8(%ebp),%eax
80103788:	8b 00                	mov    (%eax),%eax
8010378a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010378d:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103790:	8b 45 0c             	mov    0xc(%ebp),%eax
80103793:	8b 00                	mov    (%eax),%eax
80103795:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010379b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010379e:	8b 00                	mov    (%eax),%eax
801037a0:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801037a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801037a7:	8b 00                	mov    (%eax),%eax
801037a9:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801037ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801037b0:	8b 00                	mov    (%eax),%eax
801037b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037b5:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801037b8:	b8 00 00 00 00       	mov    $0x0,%eax
801037bd:	eb 51                	jmp    80103810 <pipealloc+0x154>
    goto bad;
801037bf:	90                   	nop
801037c0:	eb 01                	jmp    801037c3 <pipealloc+0x107>
    goto bad;
801037c2:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
801037c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037c7:	74 0e                	je     801037d7 <pipealloc+0x11b>
    kfree((char*)p);
801037c9:	83 ec 0c             	sub    $0xc,%esp
801037cc:	ff 75 f4             	pushl  -0xc(%ebp)
801037cf:	e8 12 f0 ff ff       	call   801027e6 <kfree>
801037d4:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801037d7:	8b 45 08             	mov    0x8(%ebp),%eax
801037da:	8b 00                	mov    (%eax),%eax
801037dc:	85 c0                	test   %eax,%eax
801037de:	74 11                	je     801037f1 <pipealloc+0x135>
    fileclose(*f0);
801037e0:	8b 45 08             	mov    0x8(%ebp),%eax
801037e3:	8b 00                	mov    (%eax),%eax
801037e5:	83 ec 0c             	sub    $0xc,%esp
801037e8:	50                   	push   %eax
801037e9:	e8 ed d8 ff ff       	call   801010db <fileclose>
801037ee:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801037f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801037f4:	8b 00                	mov    (%eax),%eax
801037f6:	85 c0                	test   %eax,%eax
801037f8:	74 11                	je     8010380b <pipealloc+0x14f>
    fileclose(*f1);
801037fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801037fd:	8b 00                	mov    (%eax),%eax
801037ff:	83 ec 0c             	sub    $0xc,%esp
80103802:	50                   	push   %eax
80103803:	e8 d3 d8 ff ff       	call   801010db <fileclose>
80103808:	83 c4 10             	add    $0x10,%esp
  return -1;
8010380b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103810:	c9                   	leave  
80103811:	c3                   	ret    

80103812 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103812:	f3 0f 1e fb          	endbr32 
80103816:	55                   	push   %ebp
80103817:	89 e5                	mov    %esp,%ebp
80103819:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010381c:	8b 45 08             	mov    0x8(%ebp),%eax
8010381f:	83 ec 0c             	sub    $0xc,%esp
80103822:	50                   	push   %eax
80103823:	e8 b4 14 00 00       	call   80104cdc <acquire>
80103828:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010382b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010382f:	74 23                	je     80103854 <pipeclose+0x42>
    p->writeopen = 0;
80103831:	8b 45 08             	mov    0x8(%ebp),%eax
80103834:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010383b:	00 00 00 
    wakeup(&p->nread);
8010383e:	8b 45 08             	mov    0x8(%ebp),%eax
80103841:	05 34 02 00 00       	add    $0x234,%eax
80103846:	83 ec 0c             	sub    $0xc,%esp
80103849:	50                   	push   %eax
8010384a:	e8 d5 0f 00 00       	call   80104824 <wakeup>
8010384f:	83 c4 10             	add    $0x10,%esp
80103852:	eb 21                	jmp    80103875 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103854:	8b 45 08             	mov    0x8(%ebp),%eax
80103857:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010385e:	00 00 00 
    wakeup(&p->nwrite);
80103861:	8b 45 08             	mov    0x8(%ebp),%eax
80103864:	05 38 02 00 00       	add    $0x238,%eax
80103869:	83 ec 0c             	sub    $0xc,%esp
8010386c:	50                   	push   %eax
8010386d:	e8 b2 0f 00 00       	call   80104824 <wakeup>
80103872:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103875:	8b 45 08             	mov    0x8(%ebp),%eax
80103878:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010387e:	85 c0                	test   %eax,%eax
80103880:	75 2c                	jne    801038ae <pipeclose+0x9c>
80103882:	8b 45 08             	mov    0x8(%ebp),%eax
80103885:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	75 1f                	jne    801038ae <pipeclose+0x9c>
    release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 b3 14 00 00       	call   80104d4e <release>
8010389b:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010389e:	83 ec 0c             	sub    $0xc,%esp
801038a1:	ff 75 08             	pushl  0x8(%ebp)
801038a4:	e8 3d ef ff ff       	call   801027e6 <kfree>
801038a9:	83 c4 10             	add    $0x10,%esp
801038ac:	eb 10                	jmp    801038be <pipeclose+0xac>
  } else
    release(&p->lock);
801038ae:	8b 45 08             	mov    0x8(%ebp),%eax
801038b1:	83 ec 0c             	sub    $0xc,%esp
801038b4:	50                   	push   %eax
801038b5:	e8 94 14 00 00       	call   80104d4e <release>
801038ba:	83 c4 10             	add    $0x10,%esp
}
801038bd:	90                   	nop
801038be:	90                   	nop
801038bf:	c9                   	leave  
801038c0:	c3                   	ret    

801038c1 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801038c1:	f3 0f 1e fb          	endbr32 
801038c5:	55                   	push   %ebp
801038c6:	89 e5                	mov    %esp,%ebp
801038c8:	53                   	push   %ebx
801038c9:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801038cc:	8b 45 08             	mov    0x8(%ebp),%eax
801038cf:	83 ec 0c             	sub    $0xc,%esp
801038d2:	50                   	push   %eax
801038d3:	e8 04 14 00 00       	call   80104cdc <acquire>
801038d8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801038db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038e2:	e9 ad 00 00 00       	jmp    80103994 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
801038e7:	8b 45 08             	mov    0x8(%ebp),%eax
801038ea:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801038f0:	85 c0                	test   %eax,%eax
801038f2:	74 0c                	je     80103900 <pipewrite+0x3f>
801038f4:	e8 a2 02 00 00       	call   80103b9b <myproc>
801038f9:	8b 40 24             	mov    0x24(%eax),%eax
801038fc:	85 c0                	test   %eax,%eax
801038fe:	74 19                	je     80103919 <pipewrite+0x58>
        release(&p->lock);
80103900:	8b 45 08             	mov    0x8(%ebp),%eax
80103903:	83 ec 0c             	sub    $0xc,%esp
80103906:	50                   	push   %eax
80103907:	e8 42 14 00 00       	call   80104d4e <release>
8010390c:	83 c4 10             	add    $0x10,%esp
        return -1;
8010390f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103914:	e9 a9 00 00 00       	jmp    801039c2 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103919:	8b 45 08             	mov    0x8(%ebp),%eax
8010391c:	05 34 02 00 00       	add    $0x234,%eax
80103921:	83 ec 0c             	sub    $0xc,%esp
80103924:	50                   	push   %eax
80103925:	e8 fa 0e 00 00       	call   80104824 <wakeup>
8010392a:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010392d:	8b 45 08             	mov    0x8(%ebp),%eax
80103930:	8b 55 08             	mov    0x8(%ebp),%edx
80103933:	81 c2 38 02 00 00    	add    $0x238,%edx
80103939:	83 ec 08             	sub    $0x8,%esp
8010393c:	50                   	push   %eax
8010393d:	52                   	push   %edx
8010393e:	e8 ef 0d 00 00       	call   80104732 <sleep>
80103943:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103946:	8b 45 08             	mov    0x8(%ebp),%eax
80103949:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010394f:	8b 45 08             	mov    0x8(%ebp),%eax
80103952:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103958:	05 00 02 00 00       	add    $0x200,%eax
8010395d:	39 c2                	cmp    %eax,%edx
8010395f:	74 86                	je     801038e7 <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103961:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103964:	8b 45 0c             	mov    0xc(%ebp),%eax
80103967:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010396a:	8b 45 08             	mov    0x8(%ebp),%eax
8010396d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103973:	8d 48 01             	lea    0x1(%eax),%ecx
80103976:	8b 55 08             	mov    0x8(%ebp),%edx
80103979:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010397f:	25 ff 01 00 00       	and    $0x1ff,%eax
80103984:	89 c1                	mov    %eax,%ecx
80103986:	0f b6 13             	movzbl (%ebx),%edx
80103989:	8b 45 08             	mov    0x8(%ebp),%eax
8010398c:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103990:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103997:	3b 45 10             	cmp    0x10(%ebp),%eax
8010399a:	7c aa                	jl     80103946 <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010399c:	8b 45 08             	mov    0x8(%ebp),%eax
8010399f:	05 34 02 00 00       	add    $0x234,%eax
801039a4:	83 ec 0c             	sub    $0xc,%esp
801039a7:	50                   	push   %eax
801039a8:	e8 77 0e 00 00       	call   80104824 <wakeup>
801039ad:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039b0:	8b 45 08             	mov    0x8(%ebp),%eax
801039b3:	83 ec 0c             	sub    $0xc,%esp
801039b6:	50                   	push   %eax
801039b7:	e8 92 13 00 00       	call   80104d4e <release>
801039bc:	83 c4 10             	add    $0x10,%esp
  return n;
801039bf:	8b 45 10             	mov    0x10(%ebp),%eax
}
801039c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039c5:	c9                   	leave  
801039c6:	c3                   	ret    

801039c7 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801039c7:	f3 0f 1e fb          	endbr32 
801039cb:	55                   	push   %ebp
801039cc:	89 e5                	mov    %esp,%ebp
801039ce:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801039d1:	8b 45 08             	mov    0x8(%ebp),%eax
801039d4:	83 ec 0c             	sub    $0xc,%esp
801039d7:	50                   	push   %eax
801039d8:	e8 ff 12 00 00       	call   80104cdc <acquire>
801039dd:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039e0:	eb 3e                	jmp    80103a20 <piperead+0x59>
    if(myproc()->killed){
801039e2:	e8 b4 01 00 00       	call   80103b9b <myproc>
801039e7:	8b 40 24             	mov    0x24(%eax),%eax
801039ea:	85 c0                	test   %eax,%eax
801039ec:	74 19                	je     80103a07 <piperead+0x40>
      release(&p->lock);
801039ee:	8b 45 08             	mov    0x8(%ebp),%eax
801039f1:	83 ec 0c             	sub    $0xc,%esp
801039f4:	50                   	push   %eax
801039f5:	e8 54 13 00 00       	call   80104d4e <release>
801039fa:	83 c4 10             	add    $0x10,%esp
      return -1;
801039fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a02:	e9 be 00 00 00       	jmp    80103ac5 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a07:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0a:	8b 55 08             	mov    0x8(%ebp),%edx
80103a0d:	81 c2 34 02 00 00    	add    $0x234,%edx
80103a13:	83 ec 08             	sub    $0x8,%esp
80103a16:	50                   	push   %eax
80103a17:	52                   	push   %edx
80103a18:	e8 15 0d 00 00       	call   80104732 <sleep>
80103a1d:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a20:	8b 45 08             	mov    0x8(%ebp),%eax
80103a23:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a29:	8b 45 08             	mov    0x8(%ebp),%eax
80103a2c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a32:	39 c2                	cmp    %eax,%edx
80103a34:	75 0d                	jne    80103a43 <piperead+0x7c>
80103a36:	8b 45 08             	mov    0x8(%ebp),%eax
80103a39:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103a3f:	85 c0                	test   %eax,%eax
80103a41:	75 9f                	jne    801039e2 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a4a:	eb 48                	jmp    80103a94 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4f:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103a55:	8b 45 08             	mov    0x8(%ebp),%eax
80103a58:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103a5e:	39 c2                	cmp    %eax,%edx
80103a60:	74 3c                	je     80103a9e <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103a62:	8b 45 08             	mov    0x8(%ebp),%eax
80103a65:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103a6b:	8d 48 01             	lea    0x1(%eax),%ecx
80103a6e:	8b 55 08             	mov    0x8(%ebp),%edx
80103a71:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103a77:	25 ff 01 00 00       	and    $0x1ff,%eax
80103a7c:	89 c1                	mov    %eax,%ecx
80103a7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a81:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a84:	01 c2                	add    %eax,%edx
80103a86:	8b 45 08             	mov    0x8(%ebp),%eax
80103a89:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103a8e:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a90:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a97:	3b 45 10             	cmp    0x10(%ebp),%eax
80103a9a:	7c b0                	jl     80103a4c <piperead+0x85>
80103a9c:	eb 01                	jmp    80103a9f <piperead+0xd8>
      break;
80103a9e:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa2:	05 38 02 00 00       	add    $0x238,%eax
80103aa7:	83 ec 0c             	sub    $0xc,%esp
80103aaa:	50                   	push   %eax
80103aab:	e8 74 0d 00 00       	call   80104824 <wakeup>
80103ab0:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab6:	83 ec 0c             	sub    $0xc,%esp
80103ab9:	50                   	push   %eax
80103aba:	e8 8f 12 00 00       	call   80104d4e <release>
80103abf:	83 c4 10             	add    $0x10,%esp
  return i;
80103ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ac5:	c9                   	leave  
80103ac6:	c3                   	ret    

80103ac7 <readeflags>:
{
80103ac7:	55                   	push   %ebp
80103ac8:	89 e5                	mov    %esp,%ebp
80103aca:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103acd:	9c                   	pushf  
80103ace:	58                   	pop    %eax
80103acf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103ad2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103ad5:	c9                   	leave  
80103ad6:	c3                   	ret    

80103ad7 <sti>:
{
80103ad7:	55                   	push   %ebp
80103ad8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103ada:	fb                   	sti    
}
80103adb:	90                   	nop
80103adc:	5d                   	pop    %ebp
80103add:	c3                   	ret    

80103ade <pinit>:
extern void trapret(void);
static void wakeup1(void *chan);

void
pinit(void)
{
80103ade:	f3 0f 1e fb          	endbr32 
80103ae2:	55                   	push   %ebp
80103ae3:	89 e5                	mov    %esp,%ebp
80103ae5:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103ae8:	83 ec 08             	sub    $0x8,%esp
80103aeb:	68 30 ac 10 80       	push   $0x8010ac30
80103af0:	68 00 55 19 80       	push   $0x80195500
80103af5:	e8 bc 11 00 00       	call   80104cb6 <initlock>
80103afa:	83 c4 10             	add    $0x10,%esp
}
80103afd:	90                   	nop
80103afe:	c9                   	leave  
80103aff:	c3                   	ret    

80103b00 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103b00:	f3 0f 1e fb          	endbr32 
80103b04:	55                   	push   %ebp
80103b05:	89 e5                	mov    %esp,%ebp
80103b07:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103b0a:	e8 10 00 00 00       	call   80103b1f <mycpu>
80103b0f:	2d c0 81 19 80       	sub    $0x801981c0,%eax
80103b14:	c1 f8 04             	sar    $0x4,%eax
80103b17:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103b1d:	c9                   	leave  
80103b1e:	c3                   	ret    

80103b1f <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103b1f:	f3 0f 1e fb          	endbr32 
80103b23:	55                   	push   %ebp
80103b24:	89 e5                	mov    %esp,%ebp
80103b26:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103b29:	e8 99 ff ff ff       	call   80103ac7 <readeflags>
80103b2e:	25 00 02 00 00       	and    $0x200,%eax
80103b33:	85 c0                	test   %eax,%eax
80103b35:	74 0d                	je     80103b44 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
80103b37:	83 ec 0c             	sub    $0xc,%esp
80103b3a:	68 38 ac 10 80       	push   $0x8010ac38
80103b3f:	e8 81 ca ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
80103b44:	e8 a8 f0 ff ff       	call   80102bf1 <lapicid>
80103b49:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103b4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b53:	eb 2d                	jmp    80103b82 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80103b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b58:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b5e:	05 c0 81 19 80       	add    $0x801981c0,%eax
80103b63:	0f b6 00             	movzbl (%eax),%eax
80103b66:	0f b6 c0             	movzbl %al,%eax
80103b69:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103b6c:	75 10                	jne    80103b7e <mycpu+0x5f>
      return &cpus[i];
80103b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b71:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b77:	05 c0 81 19 80       	add    $0x801981c0,%eax
80103b7c:	eb 1b                	jmp    80103b99 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80103b7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b82:	a1 80 84 19 80       	mov    0x80198480,%eax
80103b87:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b8a:	7c c9                	jl     80103b55 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80103b8c:	83 ec 0c             	sub    $0xc,%esp
80103b8f:	68 5e ac 10 80       	push   $0x8010ac5e
80103b94:	e8 2c ca ff ff       	call   801005c5 <panic>
}
80103b99:	c9                   	leave  
80103b9a:	c3                   	ret    

80103b9b <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103b9b:	f3 0f 1e fb          	endbr32 
80103b9f:	55                   	push   %ebp
80103ba0:	89 e5                	mov    %esp,%ebp
80103ba2:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103ba5:	e8 ae 12 00 00       	call   80104e58 <pushcli>
  c = mycpu();
80103baa:	e8 70 ff ff ff       	call   80103b1f <mycpu>
80103baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bbe:	e8 e6 12 00 00       	call   80104ea9 <popcli>
  return p;
80103bc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bc6:	c9                   	leave  
80103bc7:	c3                   	ret    

80103bc8 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103bc8:	f3 0f 1e fb          	endbr32 
80103bcc:	55                   	push   %ebp
80103bcd:	89 e5                	mov    %esp,%ebp
80103bcf:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103bd2:	83 ec 0c             	sub    $0xc,%esp
80103bd5:	68 00 55 19 80       	push   $0x80195500
80103bda:	e8 fd 10 00 00       	call   80104cdc <acquire>
80103bdf:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103be2:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80103be9:	eb 11                	jmp    80103bfc <allocproc+0x34>
    if(p->state == UNUSED){
80103beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bee:	8b 40 0c             	mov    0xc(%eax),%eax
80103bf1:	85 c0                	test   %eax,%eax
80103bf3:	74 2a                	je     80103c1f <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103bf5:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80103bfc:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
80103c03:	72 e6                	jb     80103beb <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
80103c05:	83 ec 0c             	sub    $0xc,%esp
80103c08:	68 00 55 19 80       	push   $0x80195500
80103c0d:	e8 3c 11 00 00       	call   80104d4e <release>
80103c12:	83 c4 10             	add    $0x10,%esp
  return 0;
80103c15:	b8 00 00 00 00       	mov    $0x0,%eax
80103c1a:	e9 c3 00 00 00       	jmp    80103ce2 <allocproc+0x11a>
      goto found;
80103c1f:	90                   	nop
80103c20:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80103c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c27:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103c2e:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103c33:	8d 50 01             	lea    0x1(%eax),%edx
80103c36:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103c3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c3f:	89 42 10             	mov    %eax,0x10(%edx)

  p->scheduler = 0; //사용자 수준 스케줄러 필드를 0으로 설정, 초기화
80103c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c45:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80103c4c:	00 00 00 

  release(&ptable.lock);
80103c4f:	83 ec 0c             	sub    $0xc,%esp
80103c52:	68 00 55 19 80       	push   $0x80195500
80103c57:	e8 f2 10 00 00       	call   80104d4e <release>
80103c5c:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103c5f:	e8 20 ec ff ff       	call   80102884 <kalloc>
80103c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c67:	89 42 08             	mov    %eax,0x8(%edx)
80103c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6d:	8b 40 08             	mov    0x8(%eax),%eax
80103c70:	85 c0                	test   %eax,%eax
80103c72:	75 11                	jne    80103c85 <allocproc+0xbd>
    p->state = UNUSED;
80103c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c77:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103c7e:	b8 00 00 00 00       	mov    $0x0,%eax
80103c83:	eb 5d                	jmp    80103ce2 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
80103c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c88:	8b 40 08             	mov    0x8(%eax),%eax
80103c8b:	05 00 10 00 00       	add    $0x1000,%eax
80103c90:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103c93:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103c9d:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103ca0:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103ca4:	ba 86 64 10 80       	mov    $0x80106486,%edx
80103ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cac:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103cae:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103cb8:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbe:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cc1:	83 ec 04             	sub    $0x4,%esp
80103cc4:	6a 14                	push   $0x14
80103cc6:	6a 00                	push   $0x0
80103cc8:	50                   	push   %eax
80103cc9:	e8 9d 12 00 00       	call   80104f6b <memset>
80103cce:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd4:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cd7:	ba e8 46 10 80       	mov    $0x801046e8,%edx
80103cdc:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103ce2:	c9                   	leave  
80103ce3:	c3                   	ret    

80103ce4 <userinit>:
int printpt(int pid);
//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103ce4:	f3 0f 1e fb          	endbr32 
80103ce8:	55                   	push   %ebp
80103ce9:	89 e5                	mov    %esp,%ebp
80103ceb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103cee:	e8 d5 fe ff ff       	call   80103bc8 <allocproc>
80103cf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf9:	a3 5c d0 18 80       	mov    %eax,0x8018d05c
  if((p->pgdir = setupkvm()) == 0){
80103cfe:	e8 9d 3d 00 00       	call   80107aa0 <setupkvm>
80103d03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d06:	89 42 04             	mov    %eax,0x4(%edx)
80103d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0c:	8b 40 04             	mov    0x4(%eax),%eax
80103d0f:	85 c0                	test   %eax,%eax
80103d11:	75 0d                	jne    80103d20 <userinit+0x3c>
    panic("userinit: out of memory?");
80103d13:	83 ec 0c             	sub    $0xc,%esp
80103d16:	68 6e ac 10 80       	push   $0x8010ac6e
80103d1b:	e8 a5 c8 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d20:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d28:	8b 40 04             	mov    0x4(%eax),%eax
80103d2b:	83 ec 04             	sub    $0x4,%esp
80103d2e:	52                   	push   %edx
80103d2f:	68 0c f5 10 80       	push   $0x8010f50c
80103d34:	50                   	push   %eax
80103d35:	e8 33 40 00 00       	call   80107d6d <inituvm>
80103d3a:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d40:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d49:	8b 40 18             	mov    0x18(%eax),%eax
80103d4c:	83 ec 04             	sub    $0x4,%esp
80103d4f:	6a 4c                	push   $0x4c
80103d51:	6a 00                	push   $0x0
80103d53:	50                   	push   %eax
80103d54:	e8 12 12 00 00       	call   80104f6b <memset>
80103d59:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5f:	8b 40 18             	mov    0x18(%eax),%eax
80103d62:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6b:	8b 40 18             	mov    0x18(%eax),%eax
80103d6e:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d77:	8b 50 18             	mov    0x18(%eax),%edx
80103d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7d:	8b 40 18             	mov    0x18(%eax),%eax
80103d80:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103d84:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8b:	8b 50 18             	mov    0x18(%eax),%edx
80103d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d91:	8b 40 18             	mov    0x18(%eax),%eax
80103d94:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103d98:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9f:	8b 40 18             	mov    0x18(%eax),%eax
80103da2:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dac:	8b 40 18             	mov    0x18(%eax),%eax
80103daf:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db9:	8b 40 18             	mov    0x18(%eax),%eax
80103dbc:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc6:	83 c0 6c             	add    $0x6c,%eax
80103dc9:	83 ec 04             	sub    $0x4,%esp
80103dcc:	6a 10                	push   $0x10
80103dce:	68 87 ac 10 80       	push   $0x8010ac87
80103dd3:	50                   	push   %eax
80103dd4:	e8 ad 13 00 00       	call   80105186 <safestrcpy>
80103dd9:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103ddc:	83 ec 0c             	sub    $0xc,%esp
80103ddf:	68 90 ac 10 80       	push   $0x8010ac90
80103de4:	e8 f0 e7 ff ff       	call   801025d9 <namei>
80103de9:	83 c4 10             	add    $0x10,%esp
80103dec:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103def:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103df2:	83 ec 0c             	sub    $0xc,%esp
80103df5:	68 00 55 19 80       	push   $0x80195500
80103dfa:	e8 dd 0e 00 00       	call   80104cdc <acquire>
80103dff:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e05:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e0c:	83 ec 0c             	sub    $0xc,%esp
80103e0f:	68 00 55 19 80       	push   $0x80195500
80103e14:	e8 35 0f 00 00       	call   80104d4e <release>
80103e19:	83 c4 10             	add    $0x10,%esp
}
80103e1c:	90                   	nop
80103e1d:	c9                   	leave  
80103e1e:	c3                   	ret    

80103e1f <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103e1f:	f3 0f 1e fb          	endbr32 
80103e23:	55                   	push   %ebp
80103e24:	89 e5                	mov    %esp,%ebp
80103e26:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103e29:	e8 6d fd ff ff       	call   80103b9b <myproc>
80103e2e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e34:	8b 00                	mov    (%eax),%eax
80103e36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103e39:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e3d:	7e 2e                	jle    80103e6d <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e3f:	8b 55 08             	mov    0x8(%ebp),%edx
80103e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e45:	01 c2                	add    %eax,%edx
80103e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e4a:	8b 40 04             	mov    0x4(%eax),%eax
80103e4d:	83 ec 04             	sub    $0x4,%esp
80103e50:	52                   	push   %edx
80103e51:	ff 75 f4             	pushl  -0xc(%ebp)
80103e54:	50                   	push   %eax
80103e55:	e8 58 40 00 00       	call   80107eb2 <allocuvm>
80103e5a:	83 c4 10             	add    $0x10,%esp
80103e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e64:	75 3b                	jne    80103ea1 <growproc+0x82>
      return -1;
80103e66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e6b:	eb 4f                	jmp    80103ebc <growproc+0x9d>
  } else if(n < 0){
80103e6d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103e71:	79 2e                	jns    80103ea1 <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103e73:	8b 55 08             	mov    0x8(%ebp),%edx
80103e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e79:	01 c2                	add    %eax,%edx
80103e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e7e:	8b 40 04             	mov    0x4(%eax),%eax
80103e81:	83 ec 04             	sub    $0x4,%esp
80103e84:	52                   	push   %edx
80103e85:	ff 75 f4             	pushl  -0xc(%ebp)
80103e88:	50                   	push   %eax
80103e89:	e8 2d 41 00 00       	call   80107fbb <deallocuvm>
80103e8e:	83 c4 10             	add    $0x10,%esp
80103e91:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e98:	75 07                	jne    80103ea1 <growproc+0x82>
      return -1;
80103e9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e9f:	eb 1b                	jmp    80103ebc <growproc+0x9d>
  }
  curproc->sz = sz;
80103ea1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ea4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ea7:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103ea9:	83 ec 0c             	sub    $0xc,%esp
80103eac:	ff 75 f0             	pushl  -0x10(%ebp)
80103eaf:	e8 16 3d 00 00       	call   80107bca <switchuvm>
80103eb4:	83 c4 10             	add    $0x10,%esp
  return 0;
80103eb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ebc:	c9                   	leave  
80103ebd:	c3                   	ret    

80103ebe <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103ebe:	f3 0f 1e fb          	endbr32 
80103ec2:	55                   	push   %ebp
80103ec3:	89 e5                	mov    %esp,%ebp
80103ec5:	57                   	push   %edi
80103ec6:	56                   	push   %esi
80103ec7:	53                   	push   %ebx
80103ec8:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103ecb:	e8 cb fc ff ff       	call   80103b9b <myproc>
80103ed0:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103ed3:	e8 f0 fc ff ff       	call   80103bc8 <allocproc>
80103ed8:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103edb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103edf:	75 0a                	jne    80103eeb <fork+0x2d>
    return -1;
80103ee1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ee6:	e9 48 01 00 00       	jmp    80104033 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103eeb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103eee:	8b 10                	mov    (%eax),%edx
80103ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ef3:	8b 40 04             	mov    0x4(%eax),%eax
80103ef6:	83 ec 08             	sub    $0x8,%esp
80103ef9:	52                   	push   %edx
80103efa:	50                   	push   %eax
80103efb:	e8 65 42 00 00       	call   80108165 <copyuvm>
80103f00:	83 c4 10             	add    $0x10,%esp
80103f03:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103f06:	89 42 04             	mov    %eax,0x4(%edx)
80103f09:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f0c:	8b 40 04             	mov    0x4(%eax),%eax
80103f0f:	85 c0                	test   %eax,%eax
80103f11:	75 30                	jne    80103f43 <fork+0x85>
    kfree(np->kstack);
80103f13:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f16:	8b 40 08             	mov    0x8(%eax),%eax
80103f19:	83 ec 0c             	sub    $0xc,%esp
80103f1c:	50                   	push   %eax
80103f1d:	e8 c4 e8 ff ff       	call   801027e6 <kfree>
80103f22:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103f25:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f28:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103f2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f32:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103f39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3e:	e9 f0 00 00 00       	jmp    80104033 <fork+0x175>
  }
  np->sz = curproc->sz;
80103f43:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f46:	8b 10                	mov    (%eax),%edx
80103f48:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f4b:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103f4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f50:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103f53:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103f56:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f59:	8b 48 18             	mov    0x18(%eax),%ecx
80103f5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f5f:	8b 40 18             	mov    0x18(%eax),%eax
80103f62:	89 c2                	mov    %eax,%edx
80103f64:	89 cb                	mov    %ecx,%ebx
80103f66:	b8 13 00 00 00       	mov    $0x13,%eax
80103f6b:	89 d7                	mov    %edx,%edi
80103f6d:	89 de                	mov    %ebx,%esi
80103f6f:	89 c1                	mov    %eax,%ecx
80103f71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103f73:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f76:	8b 40 18             	mov    0x18(%eax),%eax
80103f79:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103f80:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103f87:	eb 3b                	jmp    80103fc4 <fork+0x106>
    if(curproc->ofile[i])
80103f89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103f8f:	83 c2 08             	add    $0x8,%edx
80103f92:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103f96:	85 c0                	test   %eax,%eax
80103f98:	74 26                	je     80103fc0 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103f9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fa0:	83 c2 08             	add    $0x8,%edx
80103fa3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fa7:	83 ec 0c             	sub    $0xc,%esp
80103faa:	50                   	push   %eax
80103fab:	e8 d6 d0 ff ff       	call   80101086 <filedup>
80103fb0:	83 c4 10             	add    $0x10,%esp
80103fb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fb6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103fb9:	83 c1 08             	add    $0x8,%ecx
80103fbc:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103fc0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103fc4:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103fc8:	7e bf                	jle    80103f89 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80103fca:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fcd:	8b 40 68             	mov    0x68(%eax),%eax
80103fd0:	83 ec 0c             	sub    $0xc,%esp
80103fd3:	50                   	push   %eax
80103fd4:	e8 57 da ff ff       	call   80101a30 <idup>
80103fd9:	83 c4 10             	add    $0x10,%esp
80103fdc:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fdf:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103fe2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fe5:	8d 50 6c             	lea    0x6c(%eax),%edx
80103fe8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103feb:	83 c0 6c             	add    $0x6c,%eax
80103fee:	83 ec 04             	sub    $0x4,%esp
80103ff1:	6a 10                	push   $0x10
80103ff3:	52                   	push   %edx
80103ff4:	50                   	push   %eax
80103ff5:	e8 8c 11 00 00       	call   80105186 <safestrcpy>
80103ffa:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103ffd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104000:	8b 40 10             	mov    0x10(%eax),%eax
80104003:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104006:	83 ec 0c             	sub    $0xc,%esp
80104009:	68 00 55 19 80       	push   $0x80195500
8010400e:	e8 c9 0c 00 00       	call   80104cdc <acquire>
80104013:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104016:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104019:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104020:	83 ec 0c             	sub    $0xc,%esp
80104023:	68 00 55 19 80       	push   $0x80195500
80104028:	e8 21 0d 00 00       	call   80104d4e <release>
8010402d:	83 c4 10             	add    $0x10,%esp

  return pid;
80104030:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104033:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104036:	5b                   	pop    %ebx
80104037:	5e                   	pop    %esi
80104038:	5f                   	pop    %edi
80104039:	5d                   	pop    %ebp
8010403a:	c3                   	ret    

8010403b <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010403b:	f3 0f 1e fb          	endbr32 
8010403f:	55                   	push   %ebp
80104040:	89 e5                	mov    %esp,%ebp
80104042:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104045:	e8 51 fb ff ff       	call   80103b9b <myproc>
8010404a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010404d:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104052:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104055:	75 0d                	jne    80104064 <exit+0x29>
    panic("init exiting");
80104057:	83 ec 0c             	sub    $0xc,%esp
8010405a:	68 92 ac 10 80       	push   $0x8010ac92
8010405f:	e8 61 c5 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104064:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010406b:	eb 3f                	jmp    801040ac <exit+0x71>
    if(curproc->ofile[fd]){
8010406d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104070:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104073:	83 c2 08             	add    $0x8,%edx
80104076:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010407a:	85 c0                	test   %eax,%eax
8010407c:	74 2a                	je     801040a8 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
8010407e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104081:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104084:	83 c2 08             	add    $0x8,%edx
80104087:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010408b:	83 ec 0c             	sub    $0xc,%esp
8010408e:	50                   	push   %eax
8010408f:	e8 47 d0 ff ff       	call   801010db <fileclose>
80104094:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104097:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010409a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010409d:	83 c2 08             	add    $0x8,%edx
801040a0:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801040a7:	00 
  for(fd = 0; fd < NOFILE; fd++){
801040a8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801040ac:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801040b0:	7e bb                	jle    8010406d <exit+0x32>
    }
  }

  begin_op();
801040b2:	e8 ac f0 ff ff       	call   80103163 <begin_op>
  iput(curproc->cwd);
801040b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040ba:	8b 40 68             	mov    0x68(%eax),%eax
801040bd:	83 ec 0c             	sub    $0xc,%esp
801040c0:	50                   	push   %eax
801040c1:	e8 11 db ff ff       	call   80101bd7 <iput>
801040c6:	83 c4 10             	add    $0x10,%esp
  end_op();
801040c9:	e8 25 f1 ff ff       	call   801031f3 <end_op>
  curproc->cwd = 0;
801040ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040d1:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801040d8:	83 ec 0c             	sub    $0xc,%esp
801040db:	68 00 55 19 80       	push   $0x80195500
801040e0:	e8 f7 0b 00 00       	call   80104cdc <acquire>
801040e5:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801040e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040eb:	8b 40 14             	mov    0x14(%eax),%eax
801040ee:	83 ec 0c             	sub    $0xc,%esp
801040f1:	50                   	push   %eax
801040f2:	e8 e6 06 00 00       	call   801047dd <wakeup1>
801040f7:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040fa:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104101:	eb 3a                	jmp    8010413d <exit+0x102>
    if(p->parent == curproc){
80104103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104106:	8b 40 14             	mov    0x14(%eax),%eax
80104109:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010410c:	75 28                	jne    80104136 <exit+0xfb>
      p->parent = initproc;
8010410e:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104117:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010411a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411d:	8b 40 0c             	mov    0xc(%eax),%eax
80104120:	83 f8 05             	cmp    $0x5,%eax
80104123:	75 11                	jne    80104136 <exit+0xfb>
        wakeup1(initproc);
80104125:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
8010412a:	83 ec 0c             	sub    $0xc,%esp
8010412d:	50                   	push   %eax
8010412e:	e8 aa 06 00 00       	call   801047dd <wakeup1>
80104133:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104136:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010413d:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
80104144:	72 bd                	jb     80104103 <exit+0xc8>
    }
  }

  curproc->scheduler = 0; //명시적으로 scheduler 필드를 초기화
80104146:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104149:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104150:	00 00 00 

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104153:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104156:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010415d:	e8 8b 04 00 00       	call   801045ed <sched>
  panic("zombie exit");
80104162:	83 ec 0c             	sub    $0xc,%esp
80104165:	68 9f ac 10 80       	push   $0x8010ac9f
8010416a:	e8 56 c4 ff ff       	call   801005c5 <panic>

8010416f <exit2>:
}

void
exit2(int status)
{
8010416f:	f3 0f 1e fb          	endbr32 
80104173:	55                   	push   %ebp
80104174:	89 e5                	mov    %esp,%ebp
80104176:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104179:	e8 1d fa ff ff       	call   80103b9b <myproc>
8010417e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104181:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104186:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104189:	75 0d                	jne    80104198 <exit2+0x29>
    panic("init exiting");
8010418b:	83 ec 0c             	sub    $0xc,%esp
8010418e:	68 92 ac 10 80       	push   $0x8010ac92
80104193:	e8 2d c4 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104198:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010419f:	eb 3f                	jmp    801041e0 <exit2+0x71>
    if(curproc->ofile[fd]){
801041a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041a7:	83 c2 08             	add    $0x8,%edx
801041aa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041ae:	85 c0                	test   %eax,%eax
801041b0:	74 2a                	je     801041dc <exit2+0x6d>
      fileclose(curproc->ofile[fd]);
801041b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041b8:	83 c2 08             	add    $0x8,%edx
801041bb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041bf:	83 ec 0c             	sub    $0xc,%esp
801041c2:	50                   	push   %eax
801041c3:	e8 13 cf ff ff       	call   801010db <fileclose>
801041c8:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801041cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041d1:	83 c2 08             	add    $0x8,%edx
801041d4:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801041db:	00 
  for(fd = 0; fd < NOFILE; fd++){
801041dc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801041e0:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801041e4:	7e bb                	jle    801041a1 <exit2+0x32>
    }
  }

  begin_op();
801041e6:	e8 78 ef ff ff       	call   80103163 <begin_op>
  iput(curproc->cwd);
801041eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041ee:	8b 40 68             	mov    0x68(%eax),%eax
801041f1:	83 ec 0c             	sub    $0xc,%esp
801041f4:	50                   	push   %eax
801041f5:	e8 dd d9 ff ff       	call   80101bd7 <iput>
801041fa:	83 c4 10             	add    $0x10,%esp
  end_op();
801041fd:	e8 f1 ef ff ff       	call   801031f3 <end_op>
  curproc->cwd = 0;
80104202:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104205:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010420c:	83 ec 0c             	sub    $0xc,%esp
8010420f:	68 00 55 19 80       	push   $0x80195500
80104214:	e8 c3 0a 00 00       	call   80104cdc <acquire>
80104219:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010421c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010421f:	8b 40 14             	mov    0x14(%eax),%eax
80104222:	83 ec 0c             	sub    $0xc,%esp
80104225:	50                   	push   %eax
80104226:	e8 b2 05 00 00       	call   801047dd <wakeup1>
8010422b:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010422e:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104235:	eb 3a                	jmp    80104271 <exit2+0x102>
    if(p->parent == curproc){
80104237:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423a:	8b 40 14             	mov    0x14(%eax),%eax
8010423d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104240:	75 28                	jne    8010426a <exit2+0xfb>
      p->parent = initproc;
80104242:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424b:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010424e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104251:	8b 40 0c             	mov    0xc(%eax),%eax
80104254:	83 f8 05             	cmp    $0x5,%eax
80104257:	75 11                	jne    8010426a <exit2+0xfb>
        wakeup1(initproc);
80104259:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
8010425e:	83 ec 0c             	sub    $0xc,%esp
80104261:	50                   	push   %eax
80104262:	e8 76 05 00 00       	call   801047dd <wakeup1>
80104267:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010426a:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104271:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
80104278:	72 bd                	jb     80104237 <exit2+0xc8>
    }
  }

  // Set exit status and become a zombie.
  curproc->xstate = status; // Save the exit status
8010427a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010427d:	8b 55 08             	mov    0x8(%ebp),%edx
80104280:	89 50 7c             	mov    %edx,0x7c(%eax)

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104283:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104286:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010428d:	e8 5b 03 00 00       	call   801045ed <sched>
  panic("zombie exit");
80104292:	83 ec 0c             	sub    $0xc,%esp
80104295:	68 9f ac 10 80       	push   $0x8010ac9f
8010429a:	e8 26 c3 ff ff       	call   801005c5 <panic>

8010429f <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010429f:	f3 0f 1e fb          	endbr32 
801042a3:	55                   	push   %ebp
801042a4:	89 e5                	mov    %esp,%ebp
801042a6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801042a9:	e8 ed f8 ff ff       	call   80103b9b <myproc>
801042ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801042b1:	83 ec 0c             	sub    $0xc,%esp
801042b4:	68 00 55 19 80       	push   $0x80195500
801042b9:	e8 1e 0a 00 00       	call   80104cdc <acquire>
801042be:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801042c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042c8:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801042cf:	e9 a4 00 00 00       	jmp    80104378 <wait+0xd9>
      if(p->parent != curproc)
801042d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d7:	8b 40 14             	mov    0x14(%eax),%eax
801042da:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801042dd:	0f 85 8d 00 00 00    	jne    80104370 <wait+0xd1>
        continue;
      havekids = 1;
801042e3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801042ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ed:	8b 40 0c             	mov    0xc(%eax),%eax
801042f0:	83 f8 05             	cmp    $0x5,%eax
801042f3:	75 7c                	jne    80104371 <wait+0xd2>
        // Found one.
        pid = p->pid;
801042f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f8:	8b 40 10             	mov    0x10(%eax),%eax
801042fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801042fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104301:	8b 40 08             	mov    0x8(%eax),%eax
80104304:	83 ec 0c             	sub    $0xc,%esp
80104307:	50                   	push   %eax
80104308:	e8 d9 e4 ff ff       	call   801027e6 <kfree>
8010430d:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104313:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010431a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431d:	8b 40 04             	mov    0x4(%eax),%eax
80104320:	83 ec 0c             	sub    $0xc,%esp
80104323:	50                   	push   %eax
80104324:	e8 5a 3d 00 00       	call   80108083 <freevm>
80104329:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010432c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104339:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104343:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434a:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104354:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010435b:	83 ec 0c             	sub    $0xc,%esp
8010435e:	68 00 55 19 80       	push   $0x80195500
80104363:	e8 e6 09 00 00       	call   80104d4e <release>
80104368:	83 c4 10             	add    $0x10,%esp
        return pid;
8010436b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010436e:	eb 54                	jmp    801043c4 <wait+0x125>
        continue;
80104370:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104371:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104378:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
8010437f:	0f 82 4f ff ff ff    	jb     801042d4 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104385:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104389:	74 0a                	je     80104395 <wait+0xf6>
8010438b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010438e:	8b 40 24             	mov    0x24(%eax),%eax
80104391:	85 c0                	test   %eax,%eax
80104393:	74 17                	je     801043ac <wait+0x10d>
      release(&ptable.lock);
80104395:	83 ec 0c             	sub    $0xc,%esp
80104398:	68 00 55 19 80       	push   $0x80195500
8010439d:	e8 ac 09 00 00       	call   80104d4e <release>
801043a2:	83 c4 10             	add    $0x10,%esp
      return -1;
801043a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043aa:	eb 18                	jmp    801043c4 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801043ac:	83 ec 08             	sub    $0x8,%esp
801043af:	68 00 55 19 80       	push   $0x80195500
801043b4:	ff 75 ec             	pushl  -0x14(%ebp)
801043b7:	e8 76 03 00 00       	call   80104732 <sleep>
801043bc:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801043bf:	e9 fd fe ff ff       	jmp    801042c1 <wait+0x22>
  }
}
801043c4:	c9                   	leave  
801043c5:	c3                   	ret    

801043c6 <wait2>:

int
wait2(int *status) {
801043c6:	f3 0f 1e fb          	endbr32 
801043ca:	55                   	push   %ebp
801043cb:	89 e5                	mov    %esp,%ebp
801043cd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801043d0:	e8 c6 f7 ff ff       	call   80103b9b <myproc>
801043d5:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
801043d8:	83 ec 0c             	sub    $0xc,%esp
801043db:	68 00 55 19 80       	push   $0x80195500
801043e0:	e8 f7 08 00 00       	call   80104cdc <acquire>
801043e5:	83 c4 10             	add    $0x10,%esp
  for(;;) {
    // Scan through table looking for zombie children.
    havekids = 0;
801043e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801043ef:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801043f6:	e9 e5 00 00 00       	jmp    801044e0 <wait2+0x11a>
      if(p->parent != curproc)
801043fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fe:	8b 40 14             	mov    0x14(%eax),%eax
80104401:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104404:	0f 85 ce 00 00 00    	jne    801044d8 <wait2+0x112>
        continue;
      havekids = 1;
8010440a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE) {
80104411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104414:	8b 40 0c             	mov    0xc(%eax),%eax
80104417:	83 f8 05             	cmp    $0x5,%eax
8010441a:	0f 85 b9 00 00 00    	jne    801044d9 <wait2+0x113>
        // Found one.
        pid = p->pid;
80104420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104423:	8b 40 10             	mov    0x10(%eax),%eax
80104426:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442c:	8b 40 08             	mov    0x8(%eax),%eax
8010442f:	83 ec 0c             	sub    $0xc,%esp
80104432:	50                   	push   %eax
80104433:	e8 ae e3 ff ff       	call   801027e6 <kfree>
80104438:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010443b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104448:	8b 40 04             	mov    0x4(%eax),%eax
8010444b:	83 ec 0c             	sub    $0xc,%esp
8010444e:	50                   	push   %eax
8010444f:	e8 2f 3c 00 00       	call   80108083 <freevm>
80104454:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010446b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446e:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104475:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        if(status != 0 && copyout(curproc->pgdir, (uint)status, &p->xstate, sizeof(p->xstate)) < 0) {
8010447c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104480:	74 37                	je     801044b9 <wait2+0xf3>
80104482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104485:	8d 48 7c             	lea    0x7c(%eax),%ecx
80104488:	8b 55 08             	mov    0x8(%ebp),%edx
8010448b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010448e:	8b 40 04             	mov    0x4(%eax),%eax
80104491:	6a 04                	push   $0x4
80104493:	51                   	push   %ecx
80104494:	52                   	push   %edx
80104495:	50                   	push   %eax
80104496:	e8 12 3f 00 00       	call   801083ad <copyout>
8010449b:	83 c4 10             	add    $0x10,%esp
8010449e:	85 c0                	test   %eax,%eax
801044a0:	79 17                	jns    801044b9 <wait2+0xf3>
          release(&ptable.lock);
801044a2:	83 ec 0c             	sub    $0xc,%esp
801044a5:	68 00 55 19 80       	push   $0x80195500
801044aa:	e8 9f 08 00 00       	call   80104d4e <release>
801044af:	83 c4 10             	add    $0x10,%esp
          return -1;
801044b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044b7:	eb 73                	jmp    8010452c <wait2+0x166>
        }
        p->state = UNUSED;
801044b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801044c3:	83 ec 0c             	sub    $0xc,%esp
801044c6:	68 00 55 19 80       	push   $0x80195500
801044cb:	e8 7e 08 00 00       	call   80104d4e <release>
801044d0:	83 c4 10             	add    $0x10,%esp
        return pid;
801044d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044d6:	eb 54                	jmp    8010452c <wait2+0x166>
        continue;
801044d8:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801044d9:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801044e0:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
801044e7:	0f 82 0e ff ff ff    	jb     801043fb <wait2+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed) {
801044ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801044f1:	74 0a                	je     801044fd <wait2+0x137>
801044f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044f6:	8b 40 24             	mov    0x24(%eax),%eax
801044f9:	85 c0                	test   %eax,%eax
801044fb:	74 17                	je     80104514 <wait2+0x14e>
      release(&ptable.lock);
801044fd:	83 ec 0c             	sub    $0xc,%esp
80104500:	68 00 55 19 80       	push   $0x80195500
80104505:	e8 44 08 00 00       	call   80104d4e <release>
8010450a:	83 c4 10             	add    $0x10,%esp
      return -1;
8010450d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104512:	eb 18                	jmp    8010452c <wait2+0x166>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  // DOC: wait-sleep
80104514:	83 ec 08             	sub    $0x8,%esp
80104517:	68 00 55 19 80       	push   $0x80195500
8010451c:	ff 75 ec             	pushl  -0x14(%ebp)
8010451f:	e8 0e 02 00 00       	call   80104732 <sleep>
80104524:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104527:	e9 bc fe ff ff       	jmp    801043e8 <wait2+0x22>
  }
}
8010452c:	c9                   	leave  
8010452d:	c3                   	ret    

8010452e <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010452e:	f3 0f 1e fb          	endbr32 
80104532:	55                   	push   %ebp
80104533:	89 e5                	mov    %esp,%ebp
80104535:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104538:	e8 e2 f5 ff ff       	call   80103b1f <mycpu>
8010453d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104540:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104543:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010454a:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010454d:	e8 85 f5 ff ff       	call   80103ad7 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104552:	83 ec 0c             	sub    $0xc,%esp
80104555:	68 00 55 19 80       	push   $0x80195500
8010455a:	e8 7d 07 00 00       	call   80104cdc <acquire>
8010455f:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104562:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104569:	eb 64                	jmp    801045cf <scheduler+0xa1>
      if(p->state != RUNNABLE)
8010456b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456e:	8b 40 0c             	mov    0xc(%eax),%eax
80104571:	83 f8 03             	cmp    $0x3,%eax
80104574:	75 51                	jne    801045c7 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104576:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104579:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010457c:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104582:	83 ec 0c             	sub    $0xc,%esp
80104585:	ff 75 f4             	pushl  -0xc(%ebp)
80104588:	e8 3d 36 00 00       	call   80107bca <switchuvm>
8010458d:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104593:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
8010459a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459d:	8b 40 1c             	mov    0x1c(%eax),%eax
801045a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045a3:	83 c2 04             	add    $0x4,%edx
801045a6:	83 ec 08             	sub    $0x8,%esp
801045a9:	50                   	push   %eax
801045aa:	52                   	push   %edx
801045ab:	e8 4f 0c 00 00       	call   801051ff <swtch>
801045b0:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801045b3:	e8 f5 35 00 00       	call   80107bad <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801045b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045bb:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045c2:	00 00 00 
801045c5:	eb 01                	jmp    801045c8 <scheduler+0x9a>
        continue;
801045c7:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045c8:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801045cf:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
801045d6:	72 93                	jb     8010456b <scheduler+0x3d>
    }
    release(&ptable.lock);
801045d8:	83 ec 0c             	sub    $0xc,%esp
801045db:	68 00 55 19 80       	push   $0x80195500
801045e0:	e8 69 07 00 00       	call   80104d4e <release>
801045e5:	83 c4 10             	add    $0x10,%esp
    sti();
801045e8:	e9 60 ff ff ff       	jmp    8010454d <scheduler+0x1f>

801045ed <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801045ed:	f3 0f 1e fb          	endbr32 
801045f1:	55                   	push   %ebp
801045f2:	89 e5                	mov    %esp,%ebp
801045f4:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801045f7:	e8 9f f5 ff ff       	call   80103b9b <myproc>
801045fc:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801045ff:	83 ec 0c             	sub    $0xc,%esp
80104602:	68 00 55 19 80       	push   $0x80195500
80104607:	e8 17 08 00 00       	call   80104e23 <holding>
8010460c:	83 c4 10             	add    $0x10,%esp
8010460f:	85 c0                	test   %eax,%eax
80104611:	75 0d                	jne    80104620 <sched+0x33>
    panic("sched ptable.lock");
80104613:	83 ec 0c             	sub    $0xc,%esp
80104616:	68 ab ac 10 80       	push   $0x8010acab
8010461b:	e8 a5 bf ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104620:	e8 fa f4 ff ff       	call   80103b1f <mycpu>
80104625:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010462b:	83 f8 01             	cmp    $0x1,%eax
8010462e:	74 0d                	je     8010463d <sched+0x50>
    panic("sched locks");
80104630:	83 ec 0c             	sub    $0xc,%esp
80104633:	68 bd ac 10 80       	push   $0x8010acbd
80104638:	e8 88 bf ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
8010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104640:	8b 40 0c             	mov    0xc(%eax),%eax
80104643:	83 f8 04             	cmp    $0x4,%eax
80104646:	75 0d                	jne    80104655 <sched+0x68>
    panic("sched running");
80104648:	83 ec 0c             	sub    $0xc,%esp
8010464b:	68 c9 ac 10 80       	push   $0x8010acc9
80104650:	e8 70 bf ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
80104655:	e8 6d f4 ff ff       	call   80103ac7 <readeflags>
8010465a:	25 00 02 00 00       	and    $0x200,%eax
8010465f:	85 c0                	test   %eax,%eax
80104661:	74 0d                	je     80104670 <sched+0x83>
    panic("sched interruptible");
80104663:	83 ec 0c             	sub    $0xc,%esp
80104666:	68 d7 ac 10 80       	push   $0x8010acd7
8010466b:	e8 55 bf ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
80104670:	e8 aa f4 ff ff       	call   80103b1f <mycpu>
80104675:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010467b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010467e:	e8 9c f4 ff ff       	call   80103b1f <mycpu>
80104683:	8b 40 04             	mov    0x4(%eax),%eax
80104686:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104689:	83 c2 1c             	add    $0x1c,%edx
8010468c:	83 ec 08             	sub    $0x8,%esp
8010468f:	50                   	push   %eax
80104690:	52                   	push   %edx
80104691:	e8 69 0b 00 00       	call   801051ff <swtch>
80104696:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104699:	e8 81 f4 ff ff       	call   80103b1f <mycpu>
8010469e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046a1:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801046a7:	90                   	nop
801046a8:	c9                   	leave  
801046a9:	c3                   	ret    

801046aa <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801046aa:	f3 0f 1e fb          	endbr32 
801046ae:	55                   	push   %ebp
801046af:	89 e5                	mov    %esp,%ebp
801046b1:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801046b4:	83 ec 0c             	sub    $0xc,%esp
801046b7:	68 00 55 19 80       	push   $0x80195500
801046bc:	e8 1b 06 00 00       	call   80104cdc <acquire>
801046c1:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801046c4:	e8 d2 f4 ff ff       	call   80103b9b <myproc>
801046c9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801046d0:	e8 18 ff ff ff       	call   801045ed <sched>
  release(&ptable.lock);
801046d5:	83 ec 0c             	sub    $0xc,%esp
801046d8:	68 00 55 19 80       	push   $0x80195500
801046dd:	e8 6c 06 00 00       	call   80104d4e <release>
801046e2:	83 c4 10             	add    $0x10,%esp
}
801046e5:	90                   	nop
801046e6:	c9                   	leave  
801046e7:	c3                   	ret    

801046e8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801046e8:	f3 0f 1e fb          	endbr32 
801046ec:	55                   	push   %ebp
801046ed:	89 e5                	mov    %esp,%ebp
801046ef:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801046f2:	83 ec 0c             	sub    $0xc,%esp
801046f5:	68 00 55 19 80       	push   $0x80195500
801046fa:	e8 4f 06 00 00       	call   80104d4e <release>
801046ff:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104702:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104707:	85 c0                	test   %eax,%eax
80104709:	74 24                	je     8010472f <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010470b:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104712:	00 00 00 
    iinit(ROOTDEV);
80104715:	83 ec 0c             	sub    $0xc,%esp
80104718:	6a 01                	push   $0x1
8010471a:	e8 c9 cf ff ff       	call   801016e8 <iinit>
8010471f:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104722:	83 ec 0c             	sub    $0xc,%esp
80104725:	6a 01                	push   $0x1
80104727:	e8 04 e8 ff ff       	call   80102f30 <initlog>
8010472c:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010472f:	90                   	nop
80104730:	c9                   	leave  
80104731:	c3                   	ret    

80104732 <sleep>:

// Atomically release lock and sleep on chan.ld: trap.o: in function `trap':
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104732:	f3 0f 1e fb          	endbr32 
80104736:	55                   	push   %ebp
80104737:	89 e5                	mov    %esp,%ebp
80104739:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010473c:	e8 5a f4 ff ff       	call   80103b9b <myproc>
80104741:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104744:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104748:	75 0d                	jne    80104757 <sleep+0x25>
    panic("sleep");
8010474a:	83 ec 0c             	sub    $0xc,%esp
8010474d:	68 eb ac 10 80       	push   $0x8010aceb
80104752:	e8 6e be ff ff       	call   801005c5 <panic>

  if(lk == 0)
80104757:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010475b:	75 0d                	jne    8010476a <sleep+0x38>
    panic("sleep without lk");
8010475d:	83 ec 0c             	sub    $0xc,%esp
80104760:	68 f1 ac 10 80       	push   $0x8010acf1
80104765:	e8 5b be ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010476a:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104771:	74 1e                	je     80104791 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104773:	83 ec 0c             	sub    $0xc,%esp
80104776:	68 00 55 19 80       	push   $0x80195500
8010477b:	e8 5c 05 00 00       	call   80104cdc <acquire>
80104780:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104783:	83 ec 0c             	sub    $0xc,%esp
80104786:	ff 75 0c             	pushl  0xc(%ebp)
80104789:	e8 c0 05 00 00       	call   80104d4e <release>
8010478e:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104794:	8b 55 08             	mov    0x8(%ebp),%edx
80104797:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010479a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479d:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801047a4:	e8 44 fe ff ff       	call   801045ed <sched>

  // Tidy up.
  p->chan = 0;
801047a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ac:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801047b3:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801047ba:	74 1e                	je     801047da <sleep+0xa8>
    release(&ptable.lock);
801047bc:	83 ec 0c             	sub    $0xc,%esp
801047bf:	68 00 55 19 80       	push   $0x80195500
801047c4:	e8 85 05 00 00       	call   80104d4e <release>
801047c9:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801047cc:	83 ec 0c             	sub    $0xc,%esp
801047cf:	ff 75 0c             	pushl  0xc(%ebp)
801047d2:	e8 05 05 00 00       	call   80104cdc <acquire>
801047d7:	83 c4 10             	add    $0x10,%esp
  }
}
801047da:	90                   	nop
801047db:	c9                   	leave  
801047dc:	c3                   	ret    

801047dd <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801047dd:	f3 0f 1e fb          	endbr32 
801047e1:	55                   	push   %ebp
801047e2:	89 e5                	mov    %esp,%ebp
801047e4:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047e7:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
801047ee:	eb 27                	jmp    80104817 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
801047f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801047f3:	8b 40 0c             	mov    0xc(%eax),%eax
801047f6:	83 f8 02             	cmp    $0x2,%eax
801047f9:	75 15                	jne    80104810 <wakeup1+0x33>
801047fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801047fe:	8b 40 20             	mov    0x20(%eax),%eax
80104801:	39 45 08             	cmp    %eax,0x8(%ebp)
80104804:	75 0a                	jne    80104810 <wakeup1+0x33>
      p->state = RUNNABLE;
80104806:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104809:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104810:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80104817:	81 7d fc 34 79 19 80 	cmpl   $0x80197934,-0x4(%ebp)
8010481e:	72 d0                	jb     801047f0 <wakeup1+0x13>
}
80104820:	90                   	nop
80104821:	90                   	nop
80104822:	c9                   	leave  
80104823:	c3                   	ret    

80104824 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104824:	f3 0f 1e fb          	endbr32 
80104828:	55                   	push   %ebp
80104829:	89 e5                	mov    %esp,%ebp
8010482b:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010482e:	83 ec 0c             	sub    $0xc,%esp
80104831:	68 00 55 19 80       	push   $0x80195500
80104836:	e8 a1 04 00 00       	call   80104cdc <acquire>
8010483b:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010483e:	83 ec 0c             	sub    $0xc,%esp
80104841:	ff 75 08             	pushl  0x8(%ebp)
80104844:	e8 94 ff ff ff       	call   801047dd <wakeup1>
80104849:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010484c:	83 ec 0c             	sub    $0xc,%esp
8010484f:	68 00 55 19 80       	push   $0x80195500
80104854:	e8 f5 04 00 00       	call   80104d4e <release>
80104859:	83 c4 10             	add    $0x10,%esp
}
8010485c:	90                   	nop
8010485d:	c9                   	leave  
8010485e:	c3                   	ret    

8010485f <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010485f:	f3 0f 1e fb          	endbr32 
80104863:	55                   	push   %ebp
80104864:	89 e5                	mov    %esp,%ebp
80104866:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104869:	83 ec 0c             	sub    $0xc,%esp
8010486c:	68 00 55 19 80       	push   $0x80195500
80104871:	e8 66 04 00 00       	call   80104cdc <acquire>
80104876:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104879:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104880:	eb 48                	jmp    801048ca <kill+0x6b>
    if(p->pid == pid){
80104882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104885:	8b 40 10             	mov    0x10(%eax),%eax
80104888:	39 45 08             	cmp    %eax,0x8(%ebp)
8010488b:	75 36                	jne    801048c3 <kill+0x64>
      p->killed = 1;
8010488d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104890:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489a:	8b 40 0c             	mov    0xc(%eax),%eax
8010489d:	83 f8 02             	cmp    $0x2,%eax
801048a0:	75 0a                	jne    801048ac <kill+0x4d>
        p->state = RUNNABLE;
801048a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801048ac:	83 ec 0c             	sub    $0xc,%esp
801048af:	68 00 55 19 80       	push   $0x80195500
801048b4:	e8 95 04 00 00       	call   80104d4e <release>
801048b9:	83 c4 10             	add    $0x10,%esp
      return 0;
801048bc:	b8 00 00 00 00       	mov    $0x0,%eax
801048c1:	eb 25                	jmp    801048e8 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048c3:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801048ca:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
801048d1:	72 af                	jb     80104882 <kill+0x23>
    }
  }
  release(&ptable.lock);
801048d3:	83 ec 0c             	sub    $0xc,%esp
801048d6:	68 00 55 19 80       	push   $0x80195500
801048db:	e8 6e 04 00 00       	call   80104d4e <release>
801048e0:	83 c4 10             	add    $0x10,%esp
  return -1;
801048e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801048e8:	c9                   	leave  
801048e9:	c3                   	ret    

801048ea <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801048ea:	f3 0f 1e fb          	endbr32 
801048ee:	55                   	push   %ebp
801048ef:	89 e5                	mov    %esp,%ebp
801048f1:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048f4:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
801048fb:	e9 da 00 00 00       	jmp    801049da <procdump+0xf0>
    if(p->state == UNUSED)
80104900:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104903:	8b 40 0c             	mov    0xc(%eax),%eax
80104906:	85 c0                	test   %eax,%eax
80104908:	0f 84 c4 00 00 00    	je     801049d2 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010490e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104911:	8b 40 0c             	mov    0xc(%eax),%eax
80104914:	83 f8 05             	cmp    $0x5,%eax
80104917:	77 23                	ja     8010493c <procdump+0x52>
80104919:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010491c:	8b 40 0c             	mov    0xc(%eax),%eax
8010491f:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104926:	85 c0                	test   %eax,%eax
80104928:	74 12                	je     8010493c <procdump+0x52>
      state = states[p->state];
8010492a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010492d:	8b 40 0c             	mov    0xc(%eax),%eax
80104930:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104937:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010493a:	eb 07                	jmp    80104943 <procdump+0x59>
    else
      state = "???";
8010493c:	c7 45 ec 02 ad 10 80 	movl   $0x8010ad02,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104943:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104946:	8d 50 6c             	lea    0x6c(%eax),%edx
80104949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010494c:	8b 40 10             	mov    0x10(%eax),%eax
8010494f:	52                   	push   %edx
80104950:	ff 75 ec             	pushl  -0x14(%ebp)
80104953:	50                   	push   %eax
80104954:	68 06 ad 10 80       	push   $0x8010ad06
80104959:	e8 ae ba ff ff       	call   8010040c <cprintf>
8010495e:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104964:	8b 40 0c             	mov    0xc(%eax),%eax
80104967:	83 f8 02             	cmp    $0x2,%eax
8010496a:	75 54                	jne    801049c0 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010496c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010496f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104972:	8b 40 0c             	mov    0xc(%eax),%eax
80104975:	83 c0 08             	add    $0x8,%eax
80104978:	89 c2                	mov    %eax,%edx
8010497a:	83 ec 08             	sub    $0x8,%esp
8010497d:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104980:	50                   	push   %eax
80104981:	52                   	push   %edx
80104982:	e8 1d 04 00 00       	call   80104da4 <getcallerpcs>
80104987:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010498a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104991:	eb 1c                	jmp    801049af <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104996:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010499a:	83 ec 08             	sub    $0x8,%esp
8010499d:	50                   	push   %eax
8010499e:	68 0f ad 10 80       	push   $0x8010ad0f
801049a3:	e8 64 ba ff ff       	call   8010040c <cprintf>
801049a8:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801049ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801049af:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801049b3:	7f 0b                	jg     801049c0 <procdump+0xd6>
801049b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801049bc:	85 c0                	test   %eax,%eax
801049be:	75 d3                	jne    80104993 <procdump+0xa9>
    }
    cprintf("\n");
801049c0:	83 ec 0c             	sub    $0xc,%esp
801049c3:	68 13 ad 10 80       	push   $0x8010ad13
801049c8:	e8 3f ba ff ff       	call   8010040c <cprintf>
801049cd:	83 c4 10             	add    $0x10,%esp
801049d0:	eb 01                	jmp    801049d3 <procdump+0xe9>
      continue;
801049d2:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d3:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
801049da:	81 7d f0 34 79 19 80 	cmpl   $0x80197934,-0x10(%ebp)
801049e1:	0f 82 19 ff ff ff    	jb     80104900 <procdump+0x16>
  }
}
801049e7:	90                   	nop
801049e8:	90                   	nop
801049e9:	c9                   	leave  
801049ea:	c3                   	ret    

801049eb <printpt>:


pte_t* walkpgdir(pde_t* pgdir, const void* va, int alloc);
int
printpt(int pid)
{
801049eb:	f3 0f 1e fb          	endbr32 
801049ef:	55                   	push   %ebp
801049f0:	89 e5                	mov    %esp,%ebp
801049f2:	83 ec 28             	sub    $0x28,%esp
    struct proc* p = 0;
801049f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    pde_t* pgdir;
    pte_t* pte;
    uint va;
    int found = 0;
801049fc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    // 프로세스 테이블에서 해당 pid의 프로세스를 찾기
    acquire(&ptable.lock);
80104a03:	83 ec 0c             	sub    $0xc,%esp
80104a06:	68 00 55 19 80       	push   $0x80195500
80104a0b:	e8 cc 02 00 00       	call   80104cdc <acquire>
80104a10:	83 c4 10             	add    $0x10,%esp
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a13:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104a1a:	eb 1b                	jmp    80104a37 <printpt+0x4c>
        if (p->pid == pid) {
80104a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1f:	8b 40 10             	mov    0x10(%eax),%eax
80104a22:	39 45 08             	cmp    %eax,0x8(%ebp)
80104a25:	75 09                	jne    80104a30 <printpt+0x45>
            found = 1;
80104a27:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
            break;
80104a2e:	eb 10                	jmp    80104a40 <printpt+0x55>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a30:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104a37:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
80104a3e:	72 dc                	jb     80104a1c <printpt+0x31>
        }
    }
    release(&ptable.lock);
80104a40:	83 ec 0c             	sub    $0xc,%esp
80104a43:	68 00 55 19 80       	push   $0x80195500
80104a48:	e8 01 03 00 00       	call   80104d4e <release>
80104a4d:	83 c4 10             	add    $0x10,%esp

    // 해당 프로세스가 존재하지 않거나, UNUSED 상태일 경우 -1 반환
    if (!found || p->state == UNUSED) {
80104a50:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104a54:	74 0a                	je     80104a60 <printpt+0x75>
80104a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a59:	8b 40 0c             	mov    0xc(%eax),%eax
80104a5c:	85 c0                	test   %eax,%eax
80104a5e:	75 1d                	jne    80104a7d <printpt+0x92>
        cprintf("Process with pid %d not found or is in UNUSED state\n", pid);
80104a60:	83 ec 08             	sub    $0x8,%esp
80104a63:	ff 75 08             	pushl  0x8(%ebp)
80104a66:	68 18 ad 10 80       	push   $0x8010ad18
80104a6b:	e8 9c b9 ff ff       	call   8010040c <cprintf>
80104a70:	83 c4 10             	add    $0x10,%esp
        return -1;
80104a73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a78:	e9 ca 00 00 00       	jmp    80104b47 <printpt+0x15c>
    }

    pgdir = p->pgdir;
80104a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a80:	8b 40 04             	mov    0x4(%eax),%eax
80104a83:	89 45 e8             	mov    %eax,-0x18(%ebp)

    cprintf("START PAGE TABLE (pid %d)\n", pid);
80104a86:	83 ec 08             	sub    $0x8,%esp
80104a89:	ff 75 08             	pushl  0x8(%ebp)
80104a8c:	68 4d ad 10 80       	push   $0x8010ad4d
80104a91:	e8 76 b9 ff ff       	call   8010040c <cprintf>
80104a96:	83 c4 10             	add    $0x10,%esp
    for (va = 0; va < KERNBASE; va += PGSIZE) {
80104a99:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104aa0:	e9 82 00 00 00       	jmp    80104b27 <printpt+0x13c>
        pte = walkpgdir(pgdir, (void*)va, 0);
80104aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aa8:	83 ec 04             	sub    $0x4,%esp
80104aab:	6a 00                	push   $0x0
80104aad:	50                   	push   %eax
80104aae:	ff 75 e8             	pushl  -0x18(%ebp)
80104ab1:	e8 bc 2e 00 00       	call   80107972 <walkpgdir>
80104ab6:	83 c4 10             	add    $0x10,%esp
80104ab9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (pte && (*pte & PTE_P)) {
80104abc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104ac0:	74 5e                	je     80104b20 <printpt+0x135>
80104ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ac5:	8b 00                	mov    (%eax),%eax
80104ac7:	83 e0 01             	and    $0x1,%eax
80104aca:	85 c0                	test   %eax,%eax
80104acc:	74 52                	je     80104b20 <printpt+0x135>
            cprintf("VA: 0x%x P %c %c PA: 0x%x\n",
                va,
                (*pte & PTE_U) ? 'U' : 'K',
                (*pte & PTE_W) ? 'W' : '-',
                PTE_ADDR(*pte));
80104ace:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ad1:	8b 00                	mov    (%eax),%eax
            cprintf("VA: 0x%x P %c %c PA: 0x%x\n",
80104ad3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104ad8:	89 c2                	mov    %eax,%edx
                (*pte & PTE_W) ? 'W' : '-',
80104ada:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104add:	8b 00                	mov    (%eax),%eax
80104adf:	83 e0 02             	and    $0x2,%eax
            cprintf("VA: 0x%x P %c %c PA: 0x%x\n",
80104ae2:	85 c0                	test   %eax,%eax
80104ae4:	74 07                	je     80104aed <printpt+0x102>
80104ae6:	b9 57 00 00 00       	mov    $0x57,%ecx
80104aeb:	eb 05                	jmp    80104af2 <printpt+0x107>
80104aed:	b9 2d 00 00 00       	mov    $0x2d,%ecx
                (*pte & PTE_U) ? 'U' : 'K',
80104af2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104af5:	8b 00                	mov    (%eax),%eax
80104af7:	83 e0 04             	and    $0x4,%eax
            cprintf("VA: 0x%x P %c %c PA: 0x%x\n",
80104afa:	85 c0                	test   %eax,%eax
80104afc:	74 07                	je     80104b05 <printpt+0x11a>
80104afe:	b8 55 00 00 00       	mov    $0x55,%eax
80104b03:	eb 05                	jmp    80104b0a <printpt+0x11f>
80104b05:	b8 4b 00 00 00       	mov    $0x4b,%eax
80104b0a:	83 ec 0c             	sub    $0xc,%esp
80104b0d:	52                   	push   %edx
80104b0e:	51                   	push   %ecx
80104b0f:	50                   	push   %eax
80104b10:	ff 75 f0             	pushl  -0x10(%ebp)
80104b13:	68 68 ad 10 80       	push   $0x8010ad68
80104b18:	e8 ef b8 ff ff       	call   8010040c <cprintf>
80104b1d:	83 c4 20             	add    $0x20,%esp
    for (va = 0; va < KERNBASE; va += PGSIZE) {
80104b20:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b2a:	85 c0                	test   %eax,%eax
80104b2c:	0f 89 73 ff ff ff    	jns    80104aa5 <printpt+0xba>
        }
    }
    cprintf("END PAGE TABLE\n");
80104b32:	83 ec 0c             	sub    $0xc,%esp
80104b35:	68 83 ad 10 80       	push   $0x8010ad83
80104b3a:	e8 cd b8 ff ff       	call   8010040c <cprintf>
80104b3f:	83 c4 10             	add    $0x10,%esp
    return 0;
80104b42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b47:	c9                   	leave  
80104b48:	c3                   	ret    

80104b49 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104b49:	f3 0f 1e fb          	endbr32 
80104b4d:	55                   	push   %ebp
80104b4e:	89 e5                	mov    %esp,%ebp
80104b50:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104b53:	8b 45 08             	mov    0x8(%ebp),%eax
80104b56:	83 c0 04             	add    $0x4,%eax
80104b59:	83 ec 08             	sub    $0x8,%esp
80104b5c:	68 bd ad 10 80       	push   $0x8010adbd
80104b61:	50                   	push   %eax
80104b62:	e8 4f 01 00 00       	call   80104cb6 <initlock>
80104b67:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b70:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104b73:	8b 45 08             	mov    0x8(%ebp),%eax
80104b76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7f:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104b86:	90                   	nop
80104b87:	c9                   	leave  
80104b88:	c3                   	ret    

80104b89 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104b89:	f3 0f 1e fb          	endbr32 
80104b8d:	55                   	push   %ebp
80104b8e:	89 e5                	mov    %esp,%ebp
80104b90:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104b93:	8b 45 08             	mov    0x8(%ebp),%eax
80104b96:	83 c0 04             	add    $0x4,%eax
80104b99:	83 ec 0c             	sub    $0xc,%esp
80104b9c:	50                   	push   %eax
80104b9d:	e8 3a 01 00 00       	call   80104cdc <acquire>
80104ba2:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104ba5:	eb 15                	jmp    80104bbc <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80104baa:	83 c0 04             	add    $0x4,%eax
80104bad:	83 ec 08             	sub    $0x8,%esp
80104bb0:	50                   	push   %eax
80104bb1:	ff 75 08             	pushl  0x8(%ebp)
80104bb4:	e8 79 fb ff ff       	call   80104732 <sleep>
80104bb9:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbf:	8b 00                	mov    (%eax),%eax
80104bc1:	85 c0                	test   %eax,%eax
80104bc3:	75 e2                	jne    80104ba7 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104bce:	e8 c8 ef ff ff       	call   80103b9b <myproc>
80104bd3:	8b 50 10             	mov    0x10(%eax),%edx
80104bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd9:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80104bdf:	83 c0 04             	add    $0x4,%eax
80104be2:	83 ec 0c             	sub    $0xc,%esp
80104be5:	50                   	push   %eax
80104be6:	e8 63 01 00 00       	call   80104d4e <release>
80104beb:	83 c4 10             	add    $0x10,%esp
}
80104bee:	90                   	nop
80104bef:	c9                   	leave  
80104bf0:	c3                   	ret    

80104bf1 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104bf1:	f3 0f 1e fb          	endbr32 
80104bf5:	55                   	push   %ebp
80104bf6:	89 e5                	mov    %esp,%ebp
80104bf8:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bfe:	83 c0 04             	add    $0x4,%eax
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	50                   	push   %eax
80104c05:	e8 d2 00 00 00       	call   80104cdc <acquire>
80104c0a:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c16:	8b 45 08             	mov    0x8(%ebp),%eax
80104c19:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104c20:	83 ec 0c             	sub    $0xc,%esp
80104c23:	ff 75 08             	pushl  0x8(%ebp)
80104c26:	e8 f9 fb ff ff       	call   80104824 <wakeup>
80104c2b:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c31:	83 c0 04             	add    $0x4,%eax
80104c34:	83 ec 0c             	sub    $0xc,%esp
80104c37:	50                   	push   %eax
80104c38:	e8 11 01 00 00       	call   80104d4e <release>
80104c3d:	83 c4 10             	add    $0x10,%esp
}
80104c40:	90                   	nop
80104c41:	c9                   	leave  
80104c42:	c3                   	ret    

80104c43 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104c43:	f3 0f 1e fb          	endbr32 
80104c47:	55                   	push   %ebp
80104c48:	89 e5                	mov    %esp,%ebp
80104c4a:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c50:	83 c0 04             	add    $0x4,%eax
80104c53:	83 ec 0c             	sub    $0xc,%esp
80104c56:	50                   	push   %eax
80104c57:	e8 80 00 00 00       	call   80104cdc <acquire>
80104c5c:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c62:	8b 00                	mov    (%eax),%eax
80104c64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104c67:	8b 45 08             	mov    0x8(%ebp),%eax
80104c6a:	83 c0 04             	add    $0x4,%eax
80104c6d:	83 ec 0c             	sub    $0xc,%esp
80104c70:	50                   	push   %eax
80104c71:	e8 d8 00 00 00       	call   80104d4e <release>
80104c76:	83 c4 10             	add    $0x10,%esp
  return r;
80104c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104c7c:	c9                   	leave  
80104c7d:	c3                   	ret    

80104c7e <readeflags>:
{
80104c7e:	55                   	push   %ebp
80104c7f:	89 e5                	mov    %esp,%ebp
80104c81:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104c84:	9c                   	pushf  
80104c85:	58                   	pop    %eax
80104c86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104c89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104c8c:	c9                   	leave  
80104c8d:	c3                   	ret    

80104c8e <cli>:
{
80104c8e:	55                   	push   %ebp
80104c8f:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104c91:	fa                   	cli    
}
80104c92:	90                   	nop
80104c93:	5d                   	pop    %ebp
80104c94:	c3                   	ret    

80104c95 <sti>:
{
80104c95:	55                   	push   %ebp
80104c96:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104c98:	fb                   	sti    
}
80104c99:	90                   	nop
80104c9a:	5d                   	pop    %ebp
80104c9b:	c3                   	ret    

80104c9c <xchg>:
{
80104c9c:	55                   	push   %ebp
80104c9d:	89 e5                	mov    %esp,%ebp
80104c9f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104ca2:	8b 55 08             	mov    0x8(%ebp),%edx
80104ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cab:	f0 87 02             	lock xchg %eax,(%edx)
80104cae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104cb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cb4:	c9                   	leave  
80104cb5:	c3                   	ret    

80104cb6 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104cb6:	f3 0f 1e fb          	endbr32 
80104cba:	55                   	push   %ebp
80104cbb:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc0:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cc3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104cd9:	90                   	nop
80104cda:	5d                   	pop    %ebp
80104cdb:	c3                   	ret    

80104cdc <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104cdc:	f3 0f 1e fb          	endbr32 
80104ce0:	55                   	push   %ebp
80104ce1:	89 e5                	mov    %esp,%ebp
80104ce3:	53                   	push   %ebx
80104ce4:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ce7:	e8 6c 01 00 00       	call   80104e58 <pushcli>
  if(holding(lk)){
80104cec:	8b 45 08             	mov    0x8(%ebp),%eax
80104cef:	83 ec 0c             	sub    $0xc,%esp
80104cf2:	50                   	push   %eax
80104cf3:	e8 2b 01 00 00       	call   80104e23 <holding>
80104cf8:	83 c4 10             	add    $0x10,%esp
80104cfb:	85 c0                	test   %eax,%eax
80104cfd:	74 0d                	je     80104d0c <acquire+0x30>
    panic("acquire");
80104cff:	83 ec 0c             	sub    $0xc,%esp
80104d02:	68 c8 ad 10 80       	push   $0x8010adc8
80104d07:	e8 b9 b8 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104d0c:	90                   	nop
80104d0d:	8b 45 08             	mov    0x8(%ebp),%eax
80104d10:	83 ec 08             	sub    $0x8,%esp
80104d13:	6a 01                	push   $0x1
80104d15:	50                   	push   %eax
80104d16:	e8 81 ff ff ff       	call   80104c9c <xchg>
80104d1b:	83 c4 10             	add    $0x10,%esp
80104d1e:	85 c0                	test   %eax,%eax
80104d20:	75 eb                	jne    80104d0d <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104d22:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104d27:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104d2a:	e8 f0 ed ff ff       	call   80103b1f <mycpu>
80104d2f:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104d32:	8b 45 08             	mov    0x8(%ebp),%eax
80104d35:	83 c0 0c             	add    $0xc,%eax
80104d38:	83 ec 08             	sub    $0x8,%esp
80104d3b:	50                   	push   %eax
80104d3c:	8d 45 08             	lea    0x8(%ebp),%eax
80104d3f:	50                   	push   %eax
80104d40:	e8 5f 00 00 00       	call   80104da4 <getcallerpcs>
80104d45:	83 c4 10             	add    $0x10,%esp
}
80104d48:	90                   	nop
80104d49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d4c:	c9                   	leave  
80104d4d:	c3                   	ret    

80104d4e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104d4e:	f3 0f 1e fb          	endbr32 
80104d52:	55                   	push   %ebp
80104d53:	89 e5                	mov    %esp,%ebp
80104d55:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104d58:	83 ec 0c             	sub    $0xc,%esp
80104d5b:	ff 75 08             	pushl  0x8(%ebp)
80104d5e:	e8 c0 00 00 00       	call   80104e23 <holding>
80104d63:	83 c4 10             	add    $0x10,%esp
80104d66:	85 c0                	test   %eax,%eax
80104d68:	75 0d                	jne    80104d77 <release+0x29>
    panic("release");
80104d6a:	83 ec 0c             	sub    $0xc,%esp
80104d6d:	68 d0 ad 10 80       	push   $0x8010add0
80104d72:	e8 4e b8 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80104d77:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104d81:	8b 45 08             	mov    0x8(%ebp),%eax
80104d84:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104d8b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104d90:	8b 45 08             	mov    0x8(%ebp),%eax
80104d93:	8b 55 08             	mov    0x8(%ebp),%edx
80104d96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104d9c:	e8 08 01 00 00       	call   80104ea9 <popcli>
}
80104da1:	90                   	nop
80104da2:	c9                   	leave  
80104da3:	c3                   	ret    

80104da4 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104da4:	f3 0f 1e fb          	endbr32 
80104da8:	55                   	push   %ebp
80104da9:	89 e5                	mov    %esp,%ebp
80104dab:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104dae:	8b 45 08             	mov    0x8(%ebp),%eax
80104db1:	83 e8 08             	sub    $0x8,%eax
80104db4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104db7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104dbe:	eb 38                	jmp    80104df8 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104dc0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104dc4:	74 53                	je     80104e19 <getcallerpcs+0x75>
80104dc6:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104dcd:	76 4a                	jbe    80104e19 <getcallerpcs+0x75>
80104dcf:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104dd3:	74 44                	je     80104e19 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104dd5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dd8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de2:	01 c2                	add    %eax,%edx
80104de4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104de7:	8b 40 04             	mov    0x4(%eax),%eax
80104dea:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104def:	8b 00                	mov    (%eax),%eax
80104df1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104df4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104df8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104dfc:	7e c2                	jle    80104dc0 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104dfe:	eb 19                	jmp    80104e19 <getcallerpcs+0x75>
    pcs[i] = 0;
80104e00:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e03:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e0d:	01 d0                	add    %edx,%eax
80104e0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104e15:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e19:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e1d:	7e e1                	jle    80104e00 <getcallerpcs+0x5c>
}
80104e1f:	90                   	nop
80104e20:	90                   	nop
80104e21:	c9                   	leave  
80104e22:	c3                   	ret    

80104e23 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104e23:	f3 0f 1e fb          	endbr32 
80104e27:	55                   	push   %ebp
80104e28:	89 e5                	mov    %esp,%ebp
80104e2a:	53                   	push   %ebx
80104e2b:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e31:	8b 00                	mov    (%eax),%eax
80104e33:	85 c0                	test   %eax,%eax
80104e35:	74 16                	je     80104e4d <holding+0x2a>
80104e37:	8b 45 08             	mov    0x8(%ebp),%eax
80104e3a:	8b 58 08             	mov    0x8(%eax),%ebx
80104e3d:	e8 dd ec ff ff       	call   80103b1f <mycpu>
80104e42:	39 c3                	cmp    %eax,%ebx
80104e44:	75 07                	jne    80104e4d <holding+0x2a>
80104e46:	b8 01 00 00 00       	mov    $0x1,%eax
80104e4b:	eb 05                	jmp    80104e52 <holding+0x2f>
80104e4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e52:	83 c4 04             	add    $0x4,%esp
80104e55:	5b                   	pop    %ebx
80104e56:	5d                   	pop    %ebp
80104e57:	c3                   	ret    

80104e58 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104e58:	f3 0f 1e fb          	endbr32 
80104e5c:	55                   	push   %ebp
80104e5d:	89 e5                	mov    %esp,%ebp
80104e5f:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104e62:	e8 17 fe ff ff       	call   80104c7e <readeflags>
80104e67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104e6a:	e8 1f fe ff ff       	call   80104c8e <cli>
  if(mycpu()->ncli == 0)
80104e6f:	e8 ab ec ff ff       	call   80103b1f <mycpu>
80104e74:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104e7a:	85 c0                	test   %eax,%eax
80104e7c:	75 14                	jne    80104e92 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104e7e:	e8 9c ec ff ff       	call   80103b1f <mycpu>
80104e83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e86:	81 e2 00 02 00 00    	and    $0x200,%edx
80104e8c:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104e92:	e8 88 ec ff ff       	call   80103b1f <mycpu>
80104e97:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104e9d:	83 c2 01             	add    $0x1,%edx
80104ea0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104ea6:	90                   	nop
80104ea7:	c9                   	leave  
80104ea8:	c3                   	ret    

80104ea9 <popcli>:

void
popcli(void)
{
80104ea9:	f3 0f 1e fb          	endbr32 
80104ead:	55                   	push   %ebp
80104eae:	89 e5                	mov    %esp,%ebp
80104eb0:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104eb3:	e8 c6 fd ff ff       	call   80104c7e <readeflags>
80104eb8:	25 00 02 00 00       	and    $0x200,%eax
80104ebd:	85 c0                	test   %eax,%eax
80104ebf:	74 0d                	je     80104ece <popcli+0x25>
    panic("popcli - interruptible");
80104ec1:	83 ec 0c             	sub    $0xc,%esp
80104ec4:	68 d8 ad 10 80       	push   $0x8010add8
80104ec9:	e8 f7 b6 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104ece:	e8 4c ec ff ff       	call   80103b1f <mycpu>
80104ed3:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ed9:	83 ea 01             	sub    $0x1,%edx
80104edc:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104ee2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104ee8:	85 c0                	test   %eax,%eax
80104eea:	79 0d                	jns    80104ef9 <popcli+0x50>
    panic("popcli");
80104eec:	83 ec 0c             	sub    $0xc,%esp
80104eef:	68 ef ad 10 80       	push   $0x8010adef
80104ef4:	e8 cc b6 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104ef9:	e8 21 ec ff ff       	call   80103b1f <mycpu>
80104efe:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f04:	85 c0                	test   %eax,%eax
80104f06:	75 14                	jne    80104f1c <popcli+0x73>
80104f08:	e8 12 ec ff ff       	call   80103b1f <mycpu>
80104f0d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f13:	85 c0                	test   %eax,%eax
80104f15:	74 05                	je     80104f1c <popcli+0x73>
    sti();
80104f17:	e8 79 fd ff ff       	call   80104c95 <sti>
}
80104f1c:	90                   	nop
80104f1d:	c9                   	leave  
80104f1e:	c3                   	ret    

80104f1f <stosb>:
{
80104f1f:	55                   	push   %ebp
80104f20:	89 e5                	mov    %esp,%ebp
80104f22:	57                   	push   %edi
80104f23:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104f24:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f27:	8b 55 10             	mov    0x10(%ebp),%edx
80104f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f2d:	89 cb                	mov    %ecx,%ebx
80104f2f:	89 df                	mov    %ebx,%edi
80104f31:	89 d1                	mov    %edx,%ecx
80104f33:	fc                   	cld    
80104f34:	f3 aa                	rep stos %al,%es:(%edi)
80104f36:	89 ca                	mov    %ecx,%edx
80104f38:	89 fb                	mov    %edi,%ebx
80104f3a:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f3d:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104f40:	90                   	nop
80104f41:	5b                   	pop    %ebx
80104f42:	5f                   	pop    %edi
80104f43:	5d                   	pop    %ebp
80104f44:	c3                   	ret    

80104f45 <stosl>:
{
80104f45:	55                   	push   %ebp
80104f46:	89 e5                	mov    %esp,%ebp
80104f48:	57                   	push   %edi
80104f49:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104f4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f4d:	8b 55 10             	mov    0x10(%ebp),%edx
80104f50:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f53:	89 cb                	mov    %ecx,%ebx
80104f55:	89 df                	mov    %ebx,%edi
80104f57:	89 d1                	mov    %edx,%ecx
80104f59:	fc                   	cld    
80104f5a:	f3 ab                	rep stos %eax,%es:(%edi)
80104f5c:	89 ca                	mov    %ecx,%edx
80104f5e:	89 fb                	mov    %edi,%ebx
80104f60:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f63:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104f66:	90                   	nop
80104f67:	5b                   	pop    %ebx
80104f68:	5f                   	pop    %edi
80104f69:	5d                   	pop    %ebp
80104f6a:	c3                   	ret    

80104f6b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104f6b:	f3 0f 1e fb          	endbr32 
80104f6f:	55                   	push   %ebp
80104f70:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104f72:	8b 45 08             	mov    0x8(%ebp),%eax
80104f75:	83 e0 03             	and    $0x3,%eax
80104f78:	85 c0                	test   %eax,%eax
80104f7a:	75 43                	jne    80104fbf <memset+0x54>
80104f7c:	8b 45 10             	mov    0x10(%ebp),%eax
80104f7f:	83 e0 03             	and    $0x3,%eax
80104f82:	85 c0                	test   %eax,%eax
80104f84:	75 39                	jne    80104fbf <memset+0x54>
    c &= 0xFF;
80104f86:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104f8d:	8b 45 10             	mov    0x10(%ebp),%eax
80104f90:	c1 e8 02             	shr    $0x2,%eax
80104f93:	89 c1                	mov    %eax,%ecx
80104f95:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f98:	c1 e0 18             	shl    $0x18,%eax
80104f9b:	89 c2                	mov    %eax,%edx
80104f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fa0:	c1 e0 10             	shl    $0x10,%eax
80104fa3:	09 c2                	or     %eax,%edx
80104fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fa8:	c1 e0 08             	shl    $0x8,%eax
80104fab:	09 d0                	or     %edx,%eax
80104fad:	0b 45 0c             	or     0xc(%ebp),%eax
80104fb0:	51                   	push   %ecx
80104fb1:	50                   	push   %eax
80104fb2:	ff 75 08             	pushl  0x8(%ebp)
80104fb5:	e8 8b ff ff ff       	call   80104f45 <stosl>
80104fba:	83 c4 0c             	add    $0xc,%esp
80104fbd:	eb 12                	jmp    80104fd1 <memset+0x66>
  } else
    stosb(dst, c, n);
80104fbf:	8b 45 10             	mov    0x10(%ebp),%eax
80104fc2:	50                   	push   %eax
80104fc3:	ff 75 0c             	pushl  0xc(%ebp)
80104fc6:	ff 75 08             	pushl  0x8(%ebp)
80104fc9:	e8 51 ff ff ff       	call   80104f1f <stosb>
80104fce:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104fd1:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104fd4:	c9                   	leave  
80104fd5:	c3                   	ret    

80104fd6 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104fd6:	f3 0f 1e fb          	endbr32 
80104fda:	55                   	push   %ebp
80104fdb:	89 e5                	mov    %esp,%ebp
80104fdd:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fe3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fe9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104fec:	eb 30                	jmp    8010501e <memcmp+0x48>
    if(*s1 != *s2)
80104fee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ff1:	0f b6 10             	movzbl (%eax),%edx
80104ff4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ff7:	0f b6 00             	movzbl (%eax),%eax
80104ffa:	38 c2                	cmp    %al,%dl
80104ffc:	74 18                	je     80105016 <memcmp+0x40>
      return *s1 - *s2;
80104ffe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105001:	0f b6 00             	movzbl (%eax),%eax
80105004:	0f b6 d0             	movzbl %al,%edx
80105007:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010500a:	0f b6 00             	movzbl (%eax),%eax
8010500d:	0f b6 c0             	movzbl %al,%eax
80105010:	29 c2                	sub    %eax,%edx
80105012:	89 d0                	mov    %edx,%eax
80105014:	eb 1a                	jmp    80105030 <memcmp+0x5a>
    s1++, s2++;
80105016:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010501a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010501e:	8b 45 10             	mov    0x10(%ebp),%eax
80105021:	8d 50 ff             	lea    -0x1(%eax),%edx
80105024:	89 55 10             	mov    %edx,0x10(%ebp)
80105027:	85 c0                	test   %eax,%eax
80105029:	75 c3                	jne    80104fee <memcmp+0x18>
  }

  return 0;
8010502b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105030:	c9                   	leave  
80105031:	c3                   	ret    

80105032 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105032:	f3 0f 1e fb          	endbr32 
80105036:	55                   	push   %ebp
80105037:	89 e5                	mov    %esp,%ebp
80105039:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010503c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010503f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105042:	8b 45 08             	mov    0x8(%ebp),%eax
80105045:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105048:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010504b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010504e:	73 54                	jae    801050a4 <memmove+0x72>
80105050:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105053:	8b 45 10             	mov    0x10(%ebp),%eax
80105056:	01 d0                	add    %edx,%eax
80105058:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010505b:	73 47                	jae    801050a4 <memmove+0x72>
    s += n;
8010505d:	8b 45 10             	mov    0x10(%ebp),%eax
80105060:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105063:	8b 45 10             	mov    0x10(%ebp),%eax
80105066:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105069:	eb 13                	jmp    8010507e <memmove+0x4c>
      *--d = *--s;
8010506b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010506f:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105073:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105076:	0f b6 10             	movzbl (%eax),%edx
80105079:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010507c:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010507e:	8b 45 10             	mov    0x10(%ebp),%eax
80105081:	8d 50 ff             	lea    -0x1(%eax),%edx
80105084:	89 55 10             	mov    %edx,0x10(%ebp)
80105087:	85 c0                	test   %eax,%eax
80105089:	75 e0                	jne    8010506b <memmove+0x39>
  if(s < d && s + n > d){
8010508b:	eb 24                	jmp    801050b1 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
8010508d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105090:	8d 42 01             	lea    0x1(%edx),%eax
80105093:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105096:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105099:	8d 48 01             	lea    0x1(%eax),%ecx
8010509c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
8010509f:	0f b6 12             	movzbl (%edx),%edx
801050a2:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801050a4:	8b 45 10             	mov    0x10(%ebp),%eax
801050a7:	8d 50 ff             	lea    -0x1(%eax),%edx
801050aa:	89 55 10             	mov    %edx,0x10(%ebp)
801050ad:	85 c0                	test   %eax,%eax
801050af:	75 dc                	jne    8010508d <memmove+0x5b>

  return dst;
801050b1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801050b4:	c9                   	leave  
801050b5:	c3                   	ret    

801050b6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801050b6:	f3 0f 1e fb          	endbr32 
801050ba:	55                   	push   %ebp
801050bb:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801050bd:	ff 75 10             	pushl  0x10(%ebp)
801050c0:	ff 75 0c             	pushl  0xc(%ebp)
801050c3:	ff 75 08             	pushl  0x8(%ebp)
801050c6:	e8 67 ff ff ff       	call   80105032 <memmove>
801050cb:	83 c4 0c             	add    $0xc,%esp
}
801050ce:	c9                   	leave  
801050cf:	c3                   	ret    

801050d0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801050d0:	f3 0f 1e fb          	endbr32 
801050d4:	55                   	push   %ebp
801050d5:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801050d7:	eb 0c                	jmp    801050e5 <strncmp+0x15>
    n--, p++, q++;
801050d9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801050dd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801050e1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801050e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050e9:	74 1a                	je     80105105 <strncmp+0x35>
801050eb:	8b 45 08             	mov    0x8(%ebp),%eax
801050ee:	0f b6 00             	movzbl (%eax),%eax
801050f1:	84 c0                	test   %al,%al
801050f3:	74 10                	je     80105105 <strncmp+0x35>
801050f5:	8b 45 08             	mov    0x8(%ebp),%eax
801050f8:	0f b6 10             	movzbl (%eax),%edx
801050fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fe:	0f b6 00             	movzbl (%eax),%eax
80105101:	38 c2                	cmp    %al,%dl
80105103:	74 d4                	je     801050d9 <strncmp+0x9>
  if(n == 0)
80105105:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105109:	75 07                	jne    80105112 <strncmp+0x42>
    return 0;
8010510b:	b8 00 00 00 00       	mov    $0x0,%eax
80105110:	eb 16                	jmp    80105128 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80105112:	8b 45 08             	mov    0x8(%ebp),%eax
80105115:	0f b6 00             	movzbl (%eax),%eax
80105118:	0f b6 d0             	movzbl %al,%edx
8010511b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010511e:	0f b6 00             	movzbl (%eax),%eax
80105121:	0f b6 c0             	movzbl %al,%eax
80105124:	29 c2                	sub    %eax,%edx
80105126:	89 d0                	mov    %edx,%eax
}
80105128:	5d                   	pop    %ebp
80105129:	c3                   	ret    

8010512a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010512a:	f3 0f 1e fb          	endbr32 
8010512e:	55                   	push   %ebp
8010512f:	89 e5                	mov    %esp,%ebp
80105131:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105134:	8b 45 08             	mov    0x8(%ebp),%eax
80105137:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010513a:	90                   	nop
8010513b:	8b 45 10             	mov    0x10(%ebp),%eax
8010513e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105141:	89 55 10             	mov    %edx,0x10(%ebp)
80105144:	85 c0                	test   %eax,%eax
80105146:	7e 2c                	jle    80105174 <strncpy+0x4a>
80105148:	8b 55 0c             	mov    0xc(%ebp),%edx
8010514b:	8d 42 01             	lea    0x1(%edx),%eax
8010514e:	89 45 0c             	mov    %eax,0xc(%ebp)
80105151:	8b 45 08             	mov    0x8(%ebp),%eax
80105154:	8d 48 01             	lea    0x1(%eax),%ecx
80105157:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010515a:	0f b6 12             	movzbl (%edx),%edx
8010515d:	88 10                	mov    %dl,(%eax)
8010515f:	0f b6 00             	movzbl (%eax),%eax
80105162:	84 c0                	test   %al,%al
80105164:	75 d5                	jne    8010513b <strncpy+0x11>
    ;
  while(n-- > 0)
80105166:	eb 0c                	jmp    80105174 <strncpy+0x4a>
    *s++ = 0;
80105168:	8b 45 08             	mov    0x8(%ebp),%eax
8010516b:	8d 50 01             	lea    0x1(%eax),%edx
8010516e:	89 55 08             	mov    %edx,0x8(%ebp)
80105171:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105174:	8b 45 10             	mov    0x10(%ebp),%eax
80105177:	8d 50 ff             	lea    -0x1(%eax),%edx
8010517a:	89 55 10             	mov    %edx,0x10(%ebp)
8010517d:	85 c0                	test   %eax,%eax
8010517f:	7f e7                	jg     80105168 <strncpy+0x3e>
  return os;
80105181:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105184:	c9                   	leave  
80105185:	c3                   	ret    

80105186 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105186:	f3 0f 1e fb          	endbr32 
8010518a:	55                   	push   %ebp
8010518b:	89 e5                	mov    %esp,%ebp
8010518d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105190:	8b 45 08             	mov    0x8(%ebp),%eax
80105193:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105196:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010519a:	7f 05                	jg     801051a1 <safestrcpy+0x1b>
    return os;
8010519c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010519f:	eb 31                	jmp    801051d2 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801051a1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051a5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051a9:	7e 1e                	jle    801051c9 <safestrcpy+0x43>
801051ab:	8b 55 0c             	mov    0xc(%ebp),%edx
801051ae:	8d 42 01             	lea    0x1(%edx),%eax
801051b1:	89 45 0c             	mov    %eax,0xc(%ebp)
801051b4:	8b 45 08             	mov    0x8(%ebp),%eax
801051b7:	8d 48 01             	lea    0x1(%eax),%ecx
801051ba:	89 4d 08             	mov    %ecx,0x8(%ebp)
801051bd:	0f b6 12             	movzbl (%edx),%edx
801051c0:	88 10                	mov    %dl,(%eax)
801051c2:	0f b6 00             	movzbl (%eax),%eax
801051c5:	84 c0                	test   %al,%al
801051c7:	75 d8                	jne    801051a1 <safestrcpy+0x1b>
    ;
  *s = 0;
801051c9:	8b 45 08             	mov    0x8(%ebp),%eax
801051cc:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801051cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051d2:	c9                   	leave  
801051d3:	c3                   	ret    

801051d4 <strlen>:

int
strlen(const char *s)
{
801051d4:	f3 0f 1e fb          	endbr32 
801051d8:	55                   	push   %ebp
801051d9:	89 e5                	mov    %esp,%ebp
801051db:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801051de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801051e5:	eb 04                	jmp    801051eb <strlen+0x17>
801051e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801051eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051ee:	8b 45 08             	mov    0x8(%ebp),%eax
801051f1:	01 d0                	add    %edx,%eax
801051f3:	0f b6 00             	movzbl (%eax),%eax
801051f6:	84 c0                	test   %al,%al
801051f8:	75 ed                	jne    801051e7 <strlen+0x13>
    ;
  return n;
801051fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051fd:	c9                   	leave  
801051fe:	c3                   	ret    

801051ff <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801051ff:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105203:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105207:	55                   	push   %ebp
  pushl %ebx
80105208:	53                   	push   %ebx
  pushl %esi
80105209:	56                   	push   %esi
  pushl %edi
8010520a:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010520b:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010520d:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010520f:	5f                   	pop    %edi
  popl %esi
80105210:	5e                   	pop    %esi
  popl %ebx
80105211:	5b                   	pop    %ebx
  popl %ebp
80105212:	5d                   	pop    %ebp
  ret
80105213:	c3                   	ret    

80105214 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105214:	f3 0f 1e fb          	endbr32 
80105218:	55                   	push   %ebp
80105219:	89 e5                	mov    %esp,%ebp
8010521b:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010521e:	e8 78 e9 ff ff       	call   80103b9b <myproc>
80105223:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105229:	8b 00                	mov    (%eax),%eax
8010522b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010522e:	73 0f                	jae    8010523f <fetchint+0x2b>
80105230:	8b 45 08             	mov    0x8(%ebp),%eax
80105233:	8d 50 04             	lea    0x4(%eax),%edx
80105236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105239:	8b 00                	mov    (%eax),%eax
8010523b:	39 c2                	cmp    %eax,%edx
8010523d:	76 07                	jbe    80105246 <fetchint+0x32>
    return -1;
8010523f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105244:	eb 0f                	jmp    80105255 <fetchint+0x41>
  *ip = *(int*)(addr);
80105246:	8b 45 08             	mov    0x8(%ebp),%eax
80105249:	8b 10                	mov    (%eax),%edx
8010524b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010524e:	89 10                	mov    %edx,(%eax)
  return 0;
80105250:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105255:	c9                   	leave  
80105256:	c3                   	ret    

80105257 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105257:	f3 0f 1e fb          	endbr32 
8010525b:	55                   	push   %ebp
8010525c:	89 e5                	mov    %esp,%ebp
8010525e:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105261:	e8 35 e9 ff ff       	call   80103b9b <myproc>
80105266:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105269:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010526c:	8b 00                	mov    (%eax),%eax
8010526e:	39 45 08             	cmp    %eax,0x8(%ebp)
80105271:	72 07                	jb     8010527a <fetchstr+0x23>
    return -1;
80105273:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105278:	eb 43                	jmp    801052bd <fetchstr+0x66>
  *pp = (char*)addr;
8010527a:	8b 55 08             	mov    0x8(%ebp),%edx
8010527d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105280:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105282:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105285:	8b 00                	mov    (%eax),%eax
80105287:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010528a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010528d:	8b 00                	mov    (%eax),%eax
8010528f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105292:	eb 1c                	jmp    801052b0 <fetchstr+0x59>
    if(*s == 0)
80105294:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105297:	0f b6 00             	movzbl (%eax),%eax
8010529a:	84 c0                	test   %al,%al
8010529c:	75 0e                	jne    801052ac <fetchstr+0x55>
      return s - *pp;
8010529e:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a1:	8b 00                	mov    (%eax),%eax
801052a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052a6:	29 c2                	sub    %eax,%edx
801052a8:	89 d0                	mov    %edx,%eax
801052aa:	eb 11                	jmp    801052bd <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801052ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801052b6:	72 dc                	jb     80105294 <fetchstr+0x3d>
  }
  return -1;
801052b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052bd:	c9                   	leave  
801052be:	c3                   	ret    

801052bf <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801052bf:	f3 0f 1e fb          	endbr32 
801052c3:	55                   	push   %ebp
801052c4:	89 e5                	mov    %esp,%ebp
801052c6:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801052c9:	e8 cd e8 ff ff       	call   80103b9b <myproc>
801052ce:	8b 40 18             	mov    0x18(%eax),%eax
801052d1:	8b 40 44             	mov    0x44(%eax),%eax
801052d4:	8b 55 08             	mov    0x8(%ebp),%edx
801052d7:	c1 e2 02             	shl    $0x2,%edx
801052da:	01 d0                	add    %edx,%eax
801052dc:	83 c0 04             	add    $0x4,%eax
801052df:	83 ec 08             	sub    $0x8,%esp
801052e2:	ff 75 0c             	pushl  0xc(%ebp)
801052e5:	50                   	push   %eax
801052e6:	e8 29 ff ff ff       	call   80105214 <fetchint>
801052eb:	83 c4 10             	add    $0x10,%esp
}
801052ee:	c9                   	leave  
801052ef:	c3                   	ret    

801052f0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801052f0:	f3 0f 1e fb          	endbr32 
801052f4:	55                   	push   %ebp
801052f5:	89 e5                	mov    %esp,%ebp
801052f7:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801052fa:	e8 9c e8 ff ff       	call   80103b9b <myproc>
801052ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105302:	83 ec 08             	sub    $0x8,%esp
80105305:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105308:	50                   	push   %eax
80105309:	ff 75 08             	pushl  0x8(%ebp)
8010530c:	e8 ae ff ff ff       	call   801052bf <argint>
80105311:	83 c4 10             	add    $0x10,%esp
80105314:	85 c0                	test   %eax,%eax
80105316:	79 07                	jns    8010531f <argptr+0x2f>
    return -1;
80105318:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010531d:	eb 3b                	jmp    8010535a <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010531f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105323:	78 1f                	js     80105344 <argptr+0x54>
80105325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105328:	8b 00                	mov    (%eax),%eax
8010532a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010532d:	39 d0                	cmp    %edx,%eax
8010532f:	76 13                	jbe    80105344 <argptr+0x54>
80105331:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105334:	89 c2                	mov    %eax,%edx
80105336:	8b 45 10             	mov    0x10(%ebp),%eax
80105339:	01 c2                	add    %eax,%edx
8010533b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533e:	8b 00                	mov    (%eax),%eax
80105340:	39 c2                	cmp    %eax,%edx
80105342:	76 07                	jbe    8010534b <argptr+0x5b>
    return -1;
80105344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105349:	eb 0f                	jmp    8010535a <argptr+0x6a>
  *pp = (char*)i;
8010534b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010534e:	89 c2                	mov    %eax,%edx
80105350:	8b 45 0c             	mov    0xc(%ebp),%eax
80105353:	89 10                	mov    %edx,(%eax)
  return 0;
80105355:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010535a:	c9                   	leave  
8010535b:	c3                   	ret    

8010535c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010535c:	f3 0f 1e fb          	endbr32 
80105360:	55                   	push   %ebp
80105361:	89 e5                	mov    %esp,%ebp
80105363:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105366:	83 ec 08             	sub    $0x8,%esp
80105369:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010536c:	50                   	push   %eax
8010536d:	ff 75 08             	pushl  0x8(%ebp)
80105370:	e8 4a ff ff ff       	call   801052bf <argint>
80105375:	83 c4 10             	add    $0x10,%esp
80105378:	85 c0                	test   %eax,%eax
8010537a:	79 07                	jns    80105383 <argstr+0x27>
    return -1;
8010537c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105381:	eb 12                	jmp    80105395 <argstr+0x39>
  return fetchstr(addr, pp);
80105383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105386:	83 ec 08             	sub    $0x8,%esp
80105389:	ff 75 0c             	pushl  0xc(%ebp)
8010538c:	50                   	push   %eax
8010538d:	e8 c5 fe ff ff       	call   80105257 <fetchstr>
80105392:	83 c4 10             	add    $0x10,%esp
}
80105395:	c9                   	leave  
80105396:	c3                   	ret    

80105397 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80105397:	f3 0f 1e fb          	endbr32 
8010539b:	55                   	push   %ebp
8010539c:	89 e5                	mov    %esp,%ebp
8010539e:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801053a1:	e8 f5 e7 ff ff       	call   80103b9b <myproc>
801053a6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801053a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ac:	8b 40 18             	mov    0x18(%eax),%eax
801053af:	8b 40 1c             	mov    0x1c(%eax),%eax
801053b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801053b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053b9:	7e 2f                	jle    801053ea <syscall+0x53>
801053bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053be:	83 f8 19             	cmp    $0x19,%eax
801053c1:	77 27                	ja     801053ea <syscall+0x53>
801053c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c6:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801053cd:	85 c0                	test   %eax,%eax
801053cf:	74 19                	je     801053ea <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801053d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d4:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801053db:	ff d0                	call   *%eax
801053dd:	89 c2                	mov    %eax,%edx
801053df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e2:	8b 40 18             	mov    0x18(%eax),%eax
801053e5:	89 50 1c             	mov    %edx,0x1c(%eax)
801053e8:	eb 2c                	jmp    80105416 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801053ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ed:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801053f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f3:	8b 40 10             	mov    0x10(%eax),%eax
801053f6:	ff 75 f0             	pushl  -0x10(%ebp)
801053f9:	52                   	push   %edx
801053fa:	50                   	push   %eax
801053fb:	68 f6 ad 10 80       	push   $0x8010adf6
80105400:	e8 07 b0 ff ff       	call   8010040c <cprintf>
80105405:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010540b:	8b 40 18             	mov    0x18(%eax),%eax
8010540e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105415:	90                   	nop
80105416:	90                   	nop
80105417:	c9                   	leave  
80105418:	c3                   	ret    

80105419 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105419:	f3 0f 1e fb          	endbr32 
8010541d:	55                   	push   %ebp
8010541e:	89 e5                	mov    %esp,%ebp
80105420:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105423:	83 ec 08             	sub    $0x8,%esp
80105426:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105429:	50                   	push   %eax
8010542a:	ff 75 08             	pushl  0x8(%ebp)
8010542d:	e8 8d fe ff ff       	call   801052bf <argint>
80105432:	83 c4 10             	add    $0x10,%esp
80105435:	85 c0                	test   %eax,%eax
80105437:	79 07                	jns    80105440 <argfd+0x27>
    return -1;
80105439:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010543e:	eb 4f                	jmp    8010548f <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105440:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105443:	85 c0                	test   %eax,%eax
80105445:	78 20                	js     80105467 <argfd+0x4e>
80105447:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010544a:	83 f8 0f             	cmp    $0xf,%eax
8010544d:	7f 18                	jg     80105467 <argfd+0x4e>
8010544f:	e8 47 e7 ff ff       	call   80103b9b <myproc>
80105454:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105457:	83 c2 08             	add    $0x8,%edx
8010545a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010545e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105461:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105465:	75 07                	jne    8010546e <argfd+0x55>
    return -1;
80105467:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546c:	eb 21                	jmp    8010548f <argfd+0x76>
  if(pfd)
8010546e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105472:	74 08                	je     8010547c <argfd+0x63>
    *pfd = fd;
80105474:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105477:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547a:	89 10                	mov    %edx,(%eax)
  if(pf)
8010547c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105480:	74 08                	je     8010548a <argfd+0x71>
    *pf = f;
80105482:	8b 45 10             	mov    0x10(%ebp),%eax
80105485:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105488:	89 10                	mov    %edx,(%eax)
  return 0;
8010548a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010548f:	c9                   	leave  
80105490:	c3                   	ret    

80105491 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105491:	f3 0f 1e fb          	endbr32 
80105495:	55                   	push   %ebp
80105496:	89 e5                	mov    %esp,%ebp
80105498:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010549b:	e8 fb e6 ff ff       	call   80103b9b <myproc>
801054a0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801054a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801054aa:	eb 2a                	jmp    801054d6 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
801054ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054b2:	83 c2 08             	add    $0x8,%edx
801054b5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054b9:	85 c0                	test   %eax,%eax
801054bb:	75 15                	jne    801054d2 <fdalloc+0x41>
      curproc->ofile[fd] = f;
801054bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054c3:	8d 4a 08             	lea    0x8(%edx),%ecx
801054c6:	8b 55 08             	mov    0x8(%ebp),%edx
801054c9:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801054cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d0:	eb 0f                	jmp    801054e1 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
801054d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801054d6:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801054da:	7e d0                	jle    801054ac <fdalloc+0x1b>
    }
  }
  return -1;
801054dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054e1:	c9                   	leave  
801054e2:	c3                   	ret    

801054e3 <sys_dup>:

int
sys_dup(void)
{
801054e3:	f3 0f 1e fb          	endbr32 
801054e7:	55                   	push   %ebp
801054e8:	89 e5                	mov    %esp,%ebp
801054ea:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801054ed:	83 ec 04             	sub    $0x4,%esp
801054f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054f3:	50                   	push   %eax
801054f4:	6a 00                	push   $0x0
801054f6:	6a 00                	push   $0x0
801054f8:	e8 1c ff ff ff       	call   80105419 <argfd>
801054fd:	83 c4 10             	add    $0x10,%esp
80105500:	85 c0                	test   %eax,%eax
80105502:	79 07                	jns    8010550b <sys_dup+0x28>
    return -1;
80105504:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105509:	eb 31                	jmp    8010553c <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
8010550b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550e:	83 ec 0c             	sub    $0xc,%esp
80105511:	50                   	push   %eax
80105512:	e8 7a ff ff ff       	call   80105491 <fdalloc>
80105517:	83 c4 10             	add    $0x10,%esp
8010551a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010551d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105521:	79 07                	jns    8010552a <sys_dup+0x47>
    return -1;
80105523:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105528:	eb 12                	jmp    8010553c <sys_dup+0x59>
  filedup(f);
8010552a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010552d:	83 ec 0c             	sub    $0xc,%esp
80105530:	50                   	push   %eax
80105531:	e8 50 bb ff ff       	call   80101086 <filedup>
80105536:	83 c4 10             	add    $0x10,%esp
  return fd;
80105539:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010553c:	c9                   	leave  
8010553d:	c3                   	ret    

8010553e <sys_read>:

int
sys_read(void)
{
8010553e:	f3 0f 1e fb          	endbr32 
80105542:	55                   	push   %ebp
80105543:	89 e5                	mov    %esp,%ebp
80105545:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105548:	83 ec 04             	sub    $0x4,%esp
8010554b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010554e:	50                   	push   %eax
8010554f:	6a 00                	push   $0x0
80105551:	6a 00                	push   $0x0
80105553:	e8 c1 fe ff ff       	call   80105419 <argfd>
80105558:	83 c4 10             	add    $0x10,%esp
8010555b:	85 c0                	test   %eax,%eax
8010555d:	78 2e                	js     8010558d <sys_read+0x4f>
8010555f:	83 ec 08             	sub    $0x8,%esp
80105562:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105565:	50                   	push   %eax
80105566:	6a 02                	push   $0x2
80105568:	e8 52 fd ff ff       	call   801052bf <argint>
8010556d:	83 c4 10             	add    $0x10,%esp
80105570:	85 c0                	test   %eax,%eax
80105572:	78 19                	js     8010558d <sys_read+0x4f>
80105574:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105577:	83 ec 04             	sub    $0x4,%esp
8010557a:	50                   	push   %eax
8010557b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010557e:	50                   	push   %eax
8010557f:	6a 01                	push   $0x1
80105581:	e8 6a fd ff ff       	call   801052f0 <argptr>
80105586:	83 c4 10             	add    $0x10,%esp
80105589:	85 c0                	test   %eax,%eax
8010558b:	79 07                	jns    80105594 <sys_read+0x56>
    return -1;
8010558d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105592:	eb 17                	jmp    801055ab <sys_read+0x6d>
  return fileread(f, p, n);
80105594:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105597:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010559a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559d:	83 ec 04             	sub    $0x4,%esp
801055a0:	51                   	push   %ecx
801055a1:	52                   	push   %edx
801055a2:	50                   	push   %eax
801055a3:	e8 7a bc ff ff       	call   80101222 <fileread>
801055a8:	83 c4 10             	add    $0x10,%esp
}
801055ab:	c9                   	leave  
801055ac:	c3                   	ret    

801055ad <sys_write>:

int
sys_write(void)
{
801055ad:	f3 0f 1e fb          	endbr32 
801055b1:	55                   	push   %ebp
801055b2:	89 e5                	mov    %esp,%ebp
801055b4:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801055b7:	83 ec 04             	sub    $0x4,%esp
801055ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055bd:	50                   	push   %eax
801055be:	6a 00                	push   $0x0
801055c0:	6a 00                	push   $0x0
801055c2:	e8 52 fe ff ff       	call   80105419 <argfd>
801055c7:	83 c4 10             	add    $0x10,%esp
801055ca:	85 c0                	test   %eax,%eax
801055cc:	78 2e                	js     801055fc <sys_write+0x4f>
801055ce:	83 ec 08             	sub    $0x8,%esp
801055d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055d4:	50                   	push   %eax
801055d5:	6a 02                	push   $0x2
801055d7:	e8 e3 fc ff ff       	call   801052bf <argint>
801055dc:	83 c4 10             	add    $0x10,%esp
801055df:	85 c0                	test   %eax,%eax
801055e1:	78 19                	js     801055fc <sys_write+0x4f>
801055e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055e6:	83 ec 04             	sub    $0x4,%esp
801055e9:	50                   	push   %eax
801055ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055ed:	50                   	push   %eax
801055ee:	6a 01                	push   $0x1
801055f0:	e8 fb fc ff ff       	call   801052f0 <argptr>
801055f5:	83 c4 10             	add    $0x10,%esp
801055f8:	85 c0                	test   %eax,%eax
801055fa:	79 07                	jns    80105603 <sys_write+0x56>
    return -1;
801055fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105601:	eb 17                	jmp    8010561a <sys_write+0x6d>
  return filewrite(f, p, n);
80105603:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105606:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560c:	83 ec 04             	sub    $0x4,%esp
8010560f:	51                   	push   %ecx
80105610:	52                   	push   %edx
80105611:	50                   	push   %eax
80105612:	e8 c7 bc ff ff       	call   801012de <filewrite>
80105617:	83 c4 10             	add    $0x10,%esp
}
8010561a:	c9                   	leave  
8010561b:	c3                   	ret    

8010561c <sys_close>:

int
sys_close(void)
{
8010561c:	f3 0f 1e fb          	endbr32 
80105620:	55                   	push   %ebp
80105621:	89 e5                	mov    %esp,%ebp
80105623:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105626:	83 ec 04             	sub    $0x4,%esp
80105629:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010562c:	50                   	push   %eax
8010562d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105630:	50                   	push   %eax
80105631:	6a 00                	push   $0x0
80105633:	e8 e1 fd ff ff       	call   80105419 <argfd>
80105638:	83 c4 10             	add    $0x10,%esp
8010563b:	85 c0                	test   %eax,%eax
8010563d:	79 07                	jns    80105646 <sys_close+0x2a>
    return -1;
8010563f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105644:	eb 27                	jmp    8010566d <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105646:	e8 50 e5 ff ff       	call   80103b9b <myproc>
8010564b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010564e:	83 c2 08             	add    $0x8,%edx
80105651:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105658:	00 
  fileclose(f);
80105659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010565c:	83 ec 0c             	sub    $0xc,%esp
8010565f:	50                   	push   %eax
80105660:	e8 76 ba ff ff       	call   801010db <fileclose>
80105665:	83 c4 10             	add    $0x10,%esp
  return 0;
80105668:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010566d:	c9                   	leave  
8010566e:	c3                   	ret    

8010566f <sys_fstat>:

int
sys_fstat(void)
{
8010566f:	f3 0f 1e fb          	endbr32 
80105673:	55                   	push   %ebp
80105674:	89 e5                	mov    %esp,%ebp
80105676:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105679:	83 ec 04             	sub    $0x4,%esp
8010567c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010567f:	50                   	push   %eax
80105680:	6a 00                	push   $0x0
80105682:	6a 00                	push   $0x0
80105684:	e8 90 fd ff ff       	call   80105419 <argfd>
80105689:	83 c4 10             	add    $0x10,%esp
8010568c:	85 c0                	test   %eax,%eax
8010568e:	78 17                	js     801056a7 <sys_fstat+0x38>
80105690:	83 ec 04             	sub    $0x4,%esp
80105693:	6a 14                	push   $0x14
80105695:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105698:	50                   	push   %eax
80105699:	6a 01                	push   $0x1
8010569b:	e8 50 fc ff ff       	call   801052f0 <argptr>
801056a0:	83 c4 10             	add    $0x10,%esp
801056a3:	85 c0                	test   %eax,%eax
801056a5:	79 07                	jns    801056ae <sys_fstat+0x3f>
    return -1;
801056a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ac:	eb 13                	jmp    801056c1 <sys_fstat+0x52>
  return filestat(f, st);
801056ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b4:	83 ec 08             	sub    $0x8,%esp
801056b7:	52                   	push   %edx
801056b8:	50                   	push   %eax
801056b9:	e8 09 bb ff ff       	call   801011c7 <filestat>
801056be:	83 c4 10             	add    $0x10,%esp
}
801056c1:	c9                   	leave  
801056c2:	c3                   	ret    

801056c3 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801056c3:	f3 0f 1e fb          	endbr32 
801056c7:	55                   	push   %ebp
801056c8:	89 e5                	mov    %esp,%ebp
801056ca:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801056cd:	83 ec 08             	sub    $0x8,%esp
801056d0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801056d3:	50                   	push   %eax
801056d4:	6a 00                	push   $0x0
801056d6:	e8 81 fc ff ff       	call   8010535c <argstr>
801056db:	83 c4 10             	add    $0x10,%esp
801056de:	85 c0                	test   %eax,%eax
801056e0:	78 15                	js     801056f7 <sys_link+0x34>
801056e2:	83 ec 08             	sub    $0x8,%esp
801056e5:	8d 45 dc             	lea    -0x24(%ebp),%eax
801056e8:	50                   	push   %eax
801056e9:	6a 01                	push   $0x1
801056eb:	e8 6c fc ff ff       	call   8010535c <argstr>
801056f0:	83 c4 10             	add    $0x10,%esp
801056f3:	85 c0                	test   %eax,%eax
801056f5:	79 0a                	jns    80105701 <sys_link+0x3e>
    return -1;
801056f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056fc:	e9 68 01 00 00       	jmp    80105869 <sys_link+0x1a6>

  begin_op();
80105701:	e8 5d da ff ff       	call   80103163 <begin_op>
  if((ip = namei(old)) == 0){
80105706:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105709:	83 ec 0c             	sub    $0xc,%esp
8010570c:	50                   	push   %eax
8010570d:	e8 c7 ce ff ff       	call   801025d9 <namei>
80105712:	83 c4 10             	add    $0x10,%esp
80105715:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105718:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010571c:	75 0f                	jne    8010572d <sys_link+0x6a>
    end_op();
8010571e:	e8 d0 da ff ff       	call   801031f3 <end_op>
    return -1;
80105723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105728:	e9 3c 01 00 00       	jmp    80105869 <sys_link+0x1a6>
  }

  ilock(ip);
8010572d:	83 ec 0c             	sub    $0xc,%esp
80105730:	ff 75 f4             	pushl  -0xc(%ebp)
80105733:	e8 36 c3 ff ff       	call   80101a6e <ilock>
80105738:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010573b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010573e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105742:	66 83 f8 01          	cmp    $0x1,%ax
80105746:	75 1d                	jne    80105765 <sys_link+0xa2>
    iunlockput(ip);
80105748:	83 ec 0c             	sub    $0xc,%esp
8010574b:	ff 75 f4             	pushl  -0xc(%ebp)
8010574e:	e8 58 c5 ff ff       	call   80101cab <iunlockput>
80105753:	83 c4 10             	add    $0x10,%esp
    end_op();
80105756:	e8 98 da ff ff       	call   801031f3 <end_op>
    return -1;
8010575b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105760:	e9 04 01 00 00       	jmp    80105869 <sys_link+0x1a6>
  }

  ip->nlink++;
80105765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105768:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010576c:	83 c0 01             	add    $0x1,%eax
8010576f:	89 c2                	mov    %eax,%edx
80105771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105774:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105778:	83 ec 0c             	sub    $0xc,%esp
8010577b:	ff 75 f4             	pushl  -0xc(%ebp)
8010577e:	e8 02 c1 ff ff       	call   80101885 <iupdate>
80105783:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105786:	83 ec 0c             	sub    $0xc,%esp
80105789:	ff 75 f4             	pushl  -0xc(%ebp)
8010578c:	e8 f4 c3 ff ff       	call   80101b85 <iunlock>
80105791:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105794:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105797:	83 ec 08             	sub    $0x8,%esp
8010579a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010579d:	52                   	push   %edx
8010579e:	50                   	push   %eax
8010579f:	e8 55 ce ff ff       	call   801025f9 <nameiparent>
801057a4:	83 c4 10             	add    $0x10,%esp
801057a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057ae:	74 71                	je     80105821 <sys_link+0x15e>
    goto bad;
  ilock(dp);
801057b0:	83 ec 0c             	sub    $0xc,%esp
801057b3:	ff 75 f0             	pushl  -0x10(%ebp)
801057b6:	e8 b3 c2 ff ff       	call   80101a6e <ilock>
801057bb:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801057be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c1:	8b 10                	mov    (%eax),%edx
801057c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c6:	8b 00                	mov    (%eax),%eax
801057c8:	39 c2                	cmp    %eax,%edx
801057ca:	75 1d                	jne    801057e9 <sys_link+0x126>
801057cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057cf:	8b 40 04             	mov    0x4(%eax),%eax
801057d2:	83 ec 04             	sub    $0x4,%esp
801057d5:	50                   	push   %eax
801057d6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801057d9:	50                   	push   %eax
801057da:	ff 75 f0             	pushl  -0x10(%ebp)
801057dd:	e8 54 cb ff ff       	call   80102336 <dirlink>
801057e2:	83 c4 10             	add    $0x10,%esp
801057e5:	85 c0                	test   %eax,%eax
801057e7:	79 10                	jns    801057f9 <sys_link+0x136>
    iunlockput(dp);
801057e9:	83 ec 0c             	sub    $0xc,%esp
801057ec:	ff 75 f0             	pushl  -0x10(%ebp)
801057ef:	e8 b7 c4 ff ff       	call   80101cab <iunlockput>
801057f4:	83 c4 10             	add    $0x10,%esp
    goto bad;
801057f7:	eb 29                	jmp    80105822 <sys_link+0x15f>
  }
  iunlockput(dp);
801057f9:	83 ec 0c             	sub    $0xc,%esp
801057fc:	ff 75 f0             	pushl  -0x10(%ebp)
801057ff:	e8 a7 c4 ff ff       	call   80101cab <iunlockput>
80105804:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105807:	83 ec 0c             	sub    $0xc,%esp
8010580a:	ff 75 f4             	pushl  -0xc(%ebp)
8010580d:	e8 c5 c3 ff ff       	call   80101bd7 <iput>
80105812:	83 c4 10             	add    $0x10,%esp

  end_op();
80105815:	e8 d9 d9 ff ff       	call   801031f3 <end_op>

  return 0;
8010581a:	b8 00 00 00 00       	mov    $0x0,%eax
8010581f:	eb 48                	jmp    80105869 <sys_link+0x1a6>
    goto bad;
80105821:	90                   	nop

bad:
  ilock(ip);
80105822:	83 ec 0c             	sub    $0xc,%esp
80105825:	ff 75 f4             	pushl  -0xc(%ebp)
80105828:	e8 41 c2 ff ff       	call   80101a6e <ilock>
8010582d:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105833:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105837:	83 e8 01             	sub    $0x1,%eax
8010583a:	89 c2                	mov    %eax,%edx
8010583c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010583f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105843:	83 ec 0c             	sub    $0xc,%esp
80105846:	ff 75 f4             	pushl  -0xc(%ebp)
80105849:	e8 37 c0 ff ff       	call   80101885 <iupdate>
8010584e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105851:	83 ec 0c             	sub    $0xc,%esp
80105854:	ff 75 f4             	pushl  -0xc(%ebp)
80105857:	e8 4f c4 ff ff       	call   80101cab <iunlockput>
8010585c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010585f:	e8 8f d9 ff ff       	call   801031f3 <end_op>
  return -1;
80105864:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105869:	c9                   	leave  
8010586a:	c3                   	ret    

8010586b <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010586b:	f3 0f 1e fb          	endbr32 
8010586f:	55                   	push   %ebp
80105870:	89 e5                	mov    %esp,%ebp
80105872:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105875:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010587c:	eb 40                	jmp    801058be <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010587e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105881:	6a 10                	push   $0x10
80105883:	50                   	push   %eax
80105884:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105887:	50                   	push   %eax
80105888:	ff 75 08             	pushl  0x8(%ebp)
8010588b:	e8 e6 c6 ff ff       	call   80101f76 <readi>
80105890:	83 c4 10             	add    $0x10,%esp
80105893:	83 f8 10             	cmp    $0x10,%eax
80105896:	74 0d                	je     801058a5 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105898:	83 ec 0c             	sub    $0xc,%esp
8010589b:	68 12 ae 10 80       	push   $0x8010ae12
801058a0:	e8 20 ad ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
801058a5:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801058a9:	66 85 c0             	test   %ax,%ax
801058ac:	74 07                	je     801058b5 <isdirempty+0x4a>
      return 0;
801058ae:	b8 00 00 00 00       	mov    $0x0,%eax
801058b3:	eb 1b                	jmp    801058d0 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801058b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b8:	83 c0 10             	add    $0x10,%eax
801058bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058be:	8b 45 08             	mov    0x8(%ebp),%eax
801058c1:	8b 50 58             	mov    0x58(%eax),%edx
801058c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c7:	39 c2                	cmp    %eax,%edx
801058c9:	77 b3                	ja     8010587e <isdirempty+0x13>
  }
  return 1;
801058cb:	b8 01 00 00 00       	mov    $0x1,%eax
}
801058d0:	c9                   	leave  
801058d1:	c3                   	ret    

801058d2 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801058d2:	f3 0f 1e fb          	endbr32 
801058d6:	55                   	push   %ebp
801058d7:	89 e5                	mov    %esp,%ebp
801058d9:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801058dc:	83 ec 08             	sub    $0x8,%esp
801058df:	8d 45 cc             	lea    -0x34(%ebp),%eax
801058e2:	50                   	push   %eax
801058e3:	6a 00                	push   $0x0
801058e5:	e8 72 fa ff ff       	call   8010535c <argstr>
801058ea:	83 c4 10             	add    $0x10,%esp
801058ed:	85 c0                	test   %eax,%eax
801058ef:	79 0a                	jns    801058fb <sys_unlink+0x29>
    return -1;
801058f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f6:	e9 bf 01 00 00       	jmp    80105aba <sys_unlink+0x1e8>

  begin_op();
801058fb:	e8 63 d8 ff ff       	call   80103163 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105900:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105903:	83 ec 08             	sub    $0x8,%esp
80105906:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105909:	52                   	push   %edx
8010590a:	50                   	push   %eax
8010590b:	e8 e9 cc ff ff       	call   801025f9 <nameiparent>
80105910:	83 c4 10             	add    $0x10,%esp
80105913:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105916:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010591a:	75 0f                	jne    8010592b <sys_unlink+0x59>
    end_op();
8010591c:	e8 d2 d8 ff ff       	call   801031f3 <end_op>
    return -1;
80105921:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105926:	e9 8f 01 00 00       	jmp    80105aba <sys_unlink+0x1e8>
  }

  ilock(dp);
8010592b:	83 ec 0c             	sub    $0xc,%esp
8010592e:	ff 75 f4             	pushl  -0xc(%ebp)
80105931:	e8 38 c1 ff ff       	call   80101a6e <ilock>
80105936:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105939:	83 ec 08             	sub    $0x8,%esp
8010593c:	68 24 ae 10 80       	push   $0x8010ae24
80105941:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105944:	50                   	push   %eax
80105945:	e8 0f c9 ff ff       	call   80102259 <namecmp>
8010594a:	83 c4 10             	add    $0x10,%esp
8010594d:	85 c0                	test   %eax,%eax
8010594f:	0f 84 49 01 00 00    	je     80105a9e <sys_unlink+0x1cc>
80105955:	83 ec 08             	sub    $0x8,%esp
80105958:	68 26 ae 10 80       	push   $0x8010ae26
8010595d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105960:	50                   	push   %eax
80105961:	e8 f3 c8 ff ff       	call   80102259 <namecmp>
80105966:	83 c4 10             	add    $0x10,%esp
80105969:	85 c0                	test   %eax,%eax
8010596b:	0f 84 2d 01 00 00    	je     80105a9e <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105971:	83 ec 04             	sub    $0x4,%esp
80105974:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105977:	50                   	push   %eax
80105978:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010597b:	50                   	push   %eax
8010597c:	ff 75 f4             	pushl  -0xc(%ebp)
8010597f:	e8 f4 c8 ff ff       	call   80102278 <dirlookup>
80105984:	83 c4 10             	add    $0x10,%esp
80105987:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010598a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010598e:	0f 84 0d 01 00 00    	je     80105aa1 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105994:	83 ec 0c             	sub    $0xc,%esp
80105997:	ff 75 f0             	pushl  -0x10(%ebp)
8010599a:	e8 cf c0 ff ff       	call   80101a6e <ilock>
8010599f:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801059a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a5:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801059a9:	66 85 c0             	test   %ax,%ax
801059ac:	7f 0d                	jg     801059bb <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
801059ae:	83 ec 0c             	sub    $0xc,%esp
801059b1:	68 29 ae 10 80       	push   $0x8010ae29
801059b6:	e8 0a ac ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801059bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059be:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059c2:	66 83 f8 01          	cmp    $0x1,%ax
801059c6:	75 25                	jne    801059ed <sys_unlink+0x11b>
801059c8:	83 ec 0c             	sub    $0xc,%esp
801059cb:	ff 75 f0             	pushl  -0x10(%ebp)
801059ce:	e8 98 fe ff ff       	call   8010586b <isdirempty>
801059d3:	83 c4 10             	add    $0x10,%esp
801059d6:	85 c0                	test   %eax,%eax
801059d8:	75 13                	jne    801059ed <sys_unlink+0x11b>
    iunlockput(ip);
801059da:	83 ec 0c             	sub    $0xc,%esp
801059dd:	ff 75 f0             	pushl  -0x10(%ebp)
801059e0:	e8 c6 c2 ff ff       	call   80101cab <iunlockput>
801059e5:	83 c4 10             	add    $0x10,%esp
    goto bad;
801059e8:	e9 b5 00 00 00       	jmp    80105aa2 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
801059ed:	83 ec 04             	sub    $0x4,%esp
801059f0:	6a 10                	push   $0x10
801059f2:	6a 00                	push   $0x0
801059f4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801059f7:	50                   	push   %eax
801059f8:	e8 6e f5 ff ff       	call   80104f6b <memset>
801059fd:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105a00:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105a03:	6a 10                	push   $0x10
80105a05:	50                   	push   %eax
80105a06:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a09:	50                   	push   %eax
80105a0a:	ff 75 f4             	pushl  -0xc(%ebp)
80105a0d:	e8 bd c6 ff ff       	call   801020cf <writei>
80105a12:	83 c4 10             	add    $0x10,%esp
80105a15:	83 f8 10             	cmp    $0x10,%eax
80105a18:	74 0d                	je     80105a27 <sys_unlink+0x155>
    panic("unlink: writei");
80105a1a:	83 ec 0c             	sub    $0xc,%esp
80105a1d:	68 3b ae 10 80       	push   $0x8010ae3b
80105a22:	e8 9e ab ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a2e:	66 83 f8 01          	cmp    $0x1,%ax
80105a32:	75 21                	jne    80105a55 <sys_unlink+0x183>
    dp->nlink--;
80105a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a37:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a3b:	83 e8 01             	sub    $0x1,%eax
80105a3e:	89 c2                	mov    %eax,%edx
80105a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a43:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a47:	83 ec 0c             	sub    $0xc,%esp
80105a4a:	ff 75 f4             	pushl  -0xc(%ebp)
80105a4d:	e8 33 be ff ff       	call   80101885 <iupdate>
80105a52:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105a55:	83 ec 0c             	sub    $0xc,%esp
80105a58:	ff 75 f4             	pushl  -0xc(%ebp)
80105a5b:	e8 4b c2 ff ff       	call   80101cab <iunlockput>
80105a60:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a66:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a6a:	83 e8 01             	sub    $0x1,%eax
80105a6d:	89 c2                	mov    %eax,%edx
80105a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a72:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a76:	83 ec 0c             	sub    $0xc,%esp
80105a79:	ff 75 f0             	pushl  -0x10(%ebp)
80105a7c:	e8 04 be ff ff       	call   80101885 <iupdate>
80105a81:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105a84:	83 ec 0c             	sub    $0xc,%esp
80105a87:	ff 75 f0             	pushl  -0x10(%ebp)
80105a8a:	e8 1c c2 ff ff       	call   80101cab <iunlockput>
80105a8f:	83 c4 10             	add    $0x10,%esp

  end_op();
80105a92:	e8 5c d7 ff ff       	call   801031f3 <end_op>

  return 0;
80105a97:	b8 00 00 00 00       	mov    $0x0,%eax
80105a9c:	eb 1c                	jmp    80105aba <sys_unlink+0x1e8>
    goto bad;
80105a9e:	90                   	nop
80105a9f:	eb 01                	jmp    80105aa2 <sys_unlink+0x1d0>
    goto bad;
80105aa1:	90                   	nop

bad:
  iunlockput(dp);
80105aa2:	83 ec 0c             	sub    $0xc,%esp
80105aa5:	ff 75 f4             	pushl  -0xc(%ebp)
80105aa8:	e8 fe c1 ff ff       	call   80101cab <iunlockput>
80105aad:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ab0:	e8 3e d7 ff ff       	call   801031f3 <end_op>
  return -1;
80105ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105aba:	c9                   	leave  
80105abb:	c3                   	ret    

80105abc <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105abc:	f3 0f 1e fb          	endbr32 
80105ac0:	55                   	push   %ebp
80105ac1:	89 e5                	mov    %esp,%ebp
80105ac3:	83 ec 38             	sub    $0x38,%esp
80105ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105ac9:	8b 55 10             	mov    0x10(%ebp),%edx
80105acc:	8b 45 14             	mov    0x14(%ebp),%eax
80105acf:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105ad3:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105ad7:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105adb:	83 ec 08             	sub    $0x8,%esp
80105ade:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ae1:	50                   	push   %eax
80105ae2:	ff 75 08             	pushl  0x8(%ebp)
80105ae5:	e8 0f cb ff ff       	call   801025f9 <nameiparent>
80105aea:	83 c4 10             	add    $0x10,%esp
80105aed:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105af0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af4:	75 0a                	jne    80105b00 <create+0x44>
    return 0;
80105af6:	b8 00 00 00 00       	mov    $0x0,%eax
80105afb:	e9 90 01 00 00       	jmp    80105c90 <create+0x1d4>
  ilock(dp);
80105b00:	83 ec 0c             	sub    $0xc,%esp
80105b03:	ff 75 f4             	pushl  -0xc(%ebp)
80105b06:	e8 63 bf ff ff       	call   80101a6e <ilock>
80105b0b:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105b0e:	83 ec 04             	sub    $0x4,%esp
80105b11:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b14:	50                   	push   %eax
80105b15:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b18:	50                   	push   %eax
80105b19:	ff 75 f4             	pushl  -0xc(%ebp)
80105b1c:	e8 57 c7 ff ff       	call   80102278 <dirlookup>
80105b21:	83 c4 10             	add    $0x10,%esp
80105b24:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b2b:	74 50                	je     80105b7d <create+0xc1>
    iunlockput(dp);
80105b2d:	83 ec 0c             	sub    $0xc,%esp
80105b30:	ff 75 f4             	pushl  -0xc(%ebp)
80105b33:	e8 73 c1 ff ff       	call   80101cab <iunlockput>
80105b38:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105b3b:	83 ec 0c             	sub    $0xc,%esp
80105b3e:	ff 75 f0             	pushl  -0x10(%ebp)
80105b41:	e8 28 bf ff ff       	call   80101a6e <ilock>
80105b46:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105b49:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105b4e:	75 15                	jne    80105b65 <create+0xa9>
80105b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b53:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b57:	66 83 f8 02          	cmp    $0x2,%ax
80105b5b:	75 08                	jne    80105b65 <create+0xa9>
      return ip;
80105b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b60:	e9 2b 01 00 00       	jmp    80105c90 <create+0x1d4>
    iunlockput(ip);
80105b65:	83 ec 0c             	sub    $0xc,%esp
80105b68:	ff 75 f0             	pushl  -0x10(%ebp)
80105b6b:	e8 3b c1 ff ff       	call   80101cab <iunlockput>
80105b70:	83 c4 10             	add    $0x10,%esp
    return 0;
80105b73:	b8 00 00 00 00       	mov    $0x0,%eax
80105b78:	e9 13 01 00 00       	jmp    80105c90 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105b7d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b84:	8b 00                	mov    (%eax),%eax
80105b86:	83 ec 08             	sub    $0x8,%esp
80105b89:	52                   	push   %edx
80105b8a:	50                   	push   %eax
80105b8b:	e8 1a bc ff ff       	call   801017aa <ialloc>
80105b90:	83 c4 10             	add    $0x10,%esp
80105b93:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b9a:	75 0d                	jne    80105ba9 <create+0xed>
    panic("create: ialloc");
80105b9c:	83 ec 0c             	sub    $0xc,%esp
80105b9f:	68 4a ae 10 80       	push   $0x8010ae4a
80105ba4:	e8 1c aa ff ff       	call   801005c5 <panic>

  ilock(ip);
80105ba9:	83 ec 0c             	sub    $0xc,%esp
80105bac:	ff 75 f0             	pushl  -0x10(%ebp)
80105baf:	e8 ba be ff ff       	call   80101a6e <ilock>
80105bb4:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bba:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105bbe:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc5:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105bc9:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd0:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105bd6:	83 ec 0c             	sub    $0xc,%esp
80105bd9:	ff 75 f0             	pushl  -0x10(%ebp)
80105bdc:	e8 a4 bc ff ff       	call   80101885 <iupdate>
80105be1:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105be4:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105be9:	75 6a                	jne    80105c55 <create+0x199>
    dp->nlink++;  // for ".."
80105beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bee:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105bf2:	83 c0 01             	add    $0x1,%eax
80105bf5:	89 c2                	mov    %eax,%edx
80105bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfa:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105bfe:	83 ec 0c             	sub    $0xc,%esp
80105c01:	ff 75 f4             	pushl  -0xc(%ebp)
80105c04:	e8 7c bc ff ff       	call   80101885 <iupdate>
80105c09:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c0f:	8b 40 04             	mov    0x4(%eax),%eax
80105c12:	83 ec 04             	sub    $0x4,%esp
80105c15:	50                   	push   %eax
80105c16:	68 24 ae 10 80       	push   $0x8010ae24
80105c1b:	ff 75 f0             	pushl  -0x10(%ebp)
80105c1e:	e8 13 c7 ff ff       	call   80102336 <dirlink>
80105c23:	83 c4 10             	add    $0x10,%esp
80105c26:	85 c0                	test   %eax,%eax
80105c28:	78 1e                	js     80105c48 <create+0x18c>
80105c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2d:	8b 40 04             	mov    0x4(%eax),%eax
80105c30:	83 ec 04             	sub    $0x4,%esp
80105c33:	50                   	push   %eax
80105c34:	68 26 ae 10 80       	push   $0x8010ae26
80105c39:	ff 75 f0             	pushl  -0x10(%ebp)
80105c3c:	e8 f5 c6 ff ff       	call   80102336 <dirlink>
80105c41:	83 c4 10             	add    $0x10,%esp
80105c44:	85 c0                	test   %eax,%eax
80105c46:	79 0d                	jns    80105c55 <create+0x199>
      panic("create dots");
80105c48:	83 ec 0c             	sub    $0xc,%esp
80105c4b:	68 59 ae 10 80       	push   $0x8010ae59
80105c50:	e8 70 a9 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c58:	8b 40 04             	mov    0x4(%eax),%eax
80105c5b:	83 ec 04             	sub    $0x4,%esp
80105c5e:	50                   	push   %eax
80105c5f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c62:	50                   	push   %eax
80105c63:	ff 75 f4             	pushl  -0xc(%ebp)
80105c66:	e8 cb c6 ff ff       	call   80102336 <dirlink>
80105c6b:	83 c4 10             	add    $0x10,%esp
80105c6e:	85 c0                	test   %eax,%eax
80105c70:	79 0d                	jns    80105c7f <create+0x1c3>
    panic("create: dirlink");
80105c72:	83 ec 0c             	sub    $0xc,%esp
80105c75:	68 65 ae 10 80       	push   $0x8010ae65
80105c7a:	e8 46 a9 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80105c7f:	83 ec 0c             	sub    $0xc,%esp
80105c82:	ff 75 f4             	pushl  -0xc(%ebp)
80105c85:	e8 21 c0 ff ff       	call   80101cab <iunlockput>
80105c8a:	83 c4 10             	add    $0x10,%esp

  return ip;
80105c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105c90:	c9                   	leave  
80105c91:	c3                   	ret    

80105c92 <sys_open>:

int
sys_open(void)
{
80105c92:	f3 0f 1e fb          	endbr32 
80105c96:	55                   	push   %ebp
80105c97:	89 e5                	mov    %esp,%ebp
80105c99:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105c9c:	83 ec 08             	sub    $0x8,%esp
80105c9f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ca2:	50                   	push   %eax
80105ca3:	6a 00                	push   $0x0
80105ca5:	e8 b2 f6 ff ff       	call   8010535c <argstr>
80105caa:	83 c4 10             	add    $0x10,%esp
80105cad:	85 c0                	test   %eax,%eax
80105caf:	78 15                	js     80105cc6 <sys_open+0x34>
80105cb1:	83 ec 08             	sub    $0x8,%esp
80105cb4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cb7:	50                   	push   %eax
80105cb8:	6a 01                	push   $0x1
80105cba:	e8 00 f6 ff ff       	call   801052bf <argint>
80105cbf:	83 c4 10             	add    $0x10,%esp
80105cc2:	85 c0                	test   %eax,%eax
80105cc4:	79 0a                	jns    80105cd0 <sys_open+0x3e>
    return -1;
80105cc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccb:	e9 61 01 00 00       	jmp    80105e31 <sys_open+0x19f>

  begin_op();
80105cd0:	e8 8e d4 ff ff       	call   80103163 <begin_op>

  if(omode & O_CREATE){
80105cd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cd8:	25 00 02 00 00       	and    $0x200,%eax
80105cdd:	85 c0                	test   %eax,%eax
80105cdf:	74 2a                	je     80105d0b <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ce4:	6a 00                	push   $0x0
80105ce6:	6a 00                	push   $0x0
80105ce8:	6a 02                	push   $0x2
80105cea:	50                   	push   %eax
80105ceb:	e8 cc fd ff ff       	call   80105abc <create>
80105cf0:	83 c4 10             	add    $0x10,%esp
80105cf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105cf6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cfa:	75 75                	jne    80105d71 <sys_open+0xdf>
      end_op();
80105cfc:	e8 f2 d4 ff ff       	call   801031f3 <end_op>
      return -1;
80105d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d06:	e9 26 01 00 00       	jmp    80105e31 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105d0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d0e:	83 ec 0c             	sub    $0xc,%esp
80105d11:	50                   	push   %eax
80105d12:	e8 c2 c8 ff ff       	call   801025d9 <namei>
80105d17:	83 c4 10             	add    $0x10,%esp
80105d1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d21:	75 0f                	jne    80105d32 <sys_open+0xa0>
      end_op();
80105d23:	e8 cb d4 ff ff       	call   801031f3 <end_op>
      return -1;
80105d28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d2d:	e9 ff 00 00 00       	jmp    80105e31 <sys_open+0x19f>
    }
    ilock(ip);
80105d32:	83 ec 0c             	sub    $0xc,%esp
80105d35:	ff 75 f4             	pushl  -0xc(%ebp)
80105d38:	e8 31 bd ff ff       	call   80101a6e <ilock>
80105d3d:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d43:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d47:	66 83 f8 01          	cmp    $0x1,%ax
80105d4b:	75 24                	jne    80105d71 <sys_open+0xdf>
80105d4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d50:	85 c0                	test   %eax,%eax
80105d52:	74 1d                	je     80105d71 <sys_open+0xdf>
      iunlockput(ip);
80105d54:	83 ec 0c             	sub    $0xc,%esp
80105d57:	ff 75 f4             	pushl  -0xc(%ebp)
80105d5a:	e8 4c bf ff ff       	call   80101cab <iunlockput>
80105d5f:	83 c4 10             	add    $0x10,%esp
      end_op();
80105d62:	e8 8c d4 ff ff       	call   801031f3 <end_op>
      return -1;
80105d67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6c:	e9 c0 00 00 00       	jmp    80105e31 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105d71:	e8 9f b2 ff ff       	call   80101015 <filealloc>
80105d76:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d7d:	74 17                	je     80105d96 <sys_open+0x104>
80105d7f:	83 ec 0c             	sub    $0xc,%esp
80105d82:	ff 75 f0             	pushl  -0x10(%ebp)
80105d85:	e8 07 f7 ff ff       	call   80105491 <fdalloc>
80105d8a:	83 c4 10             	add    $0x10,%esp
80105d8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105d90:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105d94:	79 2e                	jns    80105dc4 <sys_open+0x132>
    if(f)
80105d96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d9a:	74 0e                	je     80105daa <sys_open+0x118>
      fileclose(f);
80105d9c:	83 ec 0c             	sub    $0xc,%esp
80105d9f:	ff 75 f0             	pushl  -0x10(%ebp)
80105da2:	e8 34 b3 ff ff       	call   801010db <fileclose>
80105da7:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105daa:	83 ec 0c             	sub    $0xc,%esp
80105dad:	ff 75 f4             	pushl  -0xc(%ebp)
80105db0:	e8 f6 be ff ff       	call   80101cab <iunlockput>
80105db5:	83 c4 10             	add    $0x10,%esp
    end_op();
80105db8:	e8 36 d4 ff ff       	call   801031f3 <end_op>
    return -1;
80105dbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc2:	eb 6d                	jmp    80105e31 <sys_open+0x19f>
  }
  iunlock(ip);
80105dc4:	83 ec 0c             	sub    $0xc,%esp
80105dc7:	ff 75 f4             	pushl  -0xc(%ebp)
80105dca:	e8 b6 bd ff ff       	call   80101b85 <iunlock>
80105dcf:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dd2:	e8 1c d4 ff ff       	call   801031f3 <end_op>

  f->type = FD_INODE;
80105dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dda:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105de6:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dec:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105df3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105df6:	83 e0 01             	and    $0x1,%eax
80105df9:	85 c0                	test   %eax,%eax
80105dfb:	0f 94 c0             	sete   %al
80105dfe:	89 c2                	mov    %eax,%edx
80105e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e03:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105e06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e09:	83 e0 01             	and    $0x1,%eax
80105e0c:	85 c0                	test   %eax,%eax
80105e0e:	75 0a                	jne    80105e1a <sys_open+0x188>
80105e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e13:	83 e0 02             	and    $0x2,%eax
80105e16:	85 c0                	test   %eax,%eax
80105e18:	74 07                	je     80105e21 <sys_open+0x18f>
80105e1a:	b8 01 00 00 00       	mov    $0x1,%eax
80105e1f:	eb 05                	jmp    80105e26 <sys_open+0x194>
80105e21:	b8 00 00 00 00       	mov    $0x0,%eax
80105e26:	89 c2                	mov    %eax,%edx
80105e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2b:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105e2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105e31:	c9                   	leave  
80105e32:	c3                   	ret    

80105e33 <sys_mkdir>:

int
sys_mkdir(void)
{
80105e33:	f3 0f 1e fb          	endbr32 
80105e37:	55                   	push   %ebp
80105e38:	89 e5                	mov    %esp,%ebp
80105e3a:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105e3d:	e8 21 d3 ff ff       	call   80103163 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105e42:	83 ec 08             	sub    $0x8,%esp
80105e45:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e48:	50                   	push   %eax
80105e49:	6a 00                	push   $0x0
80105e4b:	e8 0c f5 ff ff       	call   8010535c <argstr>
80105e50:	83 c4 10             	add    $0x10,%esp
80105e53:	85 c0                	test   %eax,%eax
80105e55:	78 1b                	js     80105e72 <sys_mkdir+0x3f>
80105e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5a:	6a 00                	push   $0x0
80105e5c:	6a 00                	push   $0x0
80105e5e:	6a 01                	push   $0x1
80105e60:	50                   	push   %eax
80105e61:	e8 56 fc ff ff       	call   80105abc <create>
80105e66:	83 c4 10             	add    $0x10,%esp
80105e69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e70:	75 0c                	jne    80105e7e <sys_mkdir+0x4b>
    end_op();
80105e72:	e8 7c d3 ff ff       	call   801031f3 <end_op>
    return -1;
80105e77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e7c:	eb 18                	jmp    80105e96 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105e7e:	83 ec 0c             	sub    $0xc,%esp
80105e81:	ff 75 f4             	pushl  -0xc(%ebp)
80105e84:	e8 22 be ff ff       	call   80101cab <iunlockput>
80105e89:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e8c:	e8 62 d3 ff ff       	call   801031f3 <end_op>
  return 0;
80105e91:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e96:	c9                   	leave  
80105e97:	c3                   	ret    

80105e98 <sys_mknod>:

int
sys_mknod(void)
{
80105e98:	f3 0f 1e fb          	endbr32 
80105e9c:	55                   	push   %ebp
80105e9d:	89 e5                	mov    %esp,%ebp
80105e9f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105ea2:	e8 bc d2 ff ff       	call   80103163 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105ea7:	83 ec 08             	sub    $0x8,%esp
80105eaa:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ead:	50                   	push   %eax
80105eae:	6a 00                	push   $0x0
80105eb0:	e8 a7 f4 ff ff       	call   8010535c <argstr>
80105eb5:	83 c4 10             	add    $0x10,%esp
80105eb8:	85 c0                	test   %eax,%eax
80105eba:	78 4f                	js     80105f0b <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105ebc:	83 ec 08             	sub    $0x8,%esp
80105ebf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ec2:	50                   	push   %eax
80105ec3:	6a 01                	push   $0x1
80105ec5:	e8 f5 f3 ff ff       	call   801052bf <argint>
80105eca:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105ecd:	85 c0                	test   %eax,%eax
80105ecf:	78 3a                	js     80105f0b <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105ed1:	83 ec 08             	sub    $0x8,%esp
80105ed4:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ed7:	50                   	push   %eax
80105ed8:	6a 02                	push   $0x2
80105eda:	e8 e0 f3 ff ff       	call   801052bf <argint>
80105edf:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105ee2:	85 c0                	test   %eax,%eax
80105ee4:	78 25                	js     80105f0b <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105ee6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ee9:	0f bf c8             	movswl %ax,%ecx
80105eec:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105eef:	0f bf d0             	movswl %ax,%edx
80105ef2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef5:	51                   	push   %ecx
80105ef6:	52                   	push   %edx
80105ef7:	6a 03                	push   $0x3
80105ef9:	50                   	push   %eax
80105efa:	e8 bd fb ff ff       	call   80105abc <create>
80105eff:	83 c4 10             	add    $0x10,%esp
80105f02:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105f05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f09:	75 0c                	jne    80105f17 <sys_mknod+0x7f>
    end_op();
80105f0b:	e8 e3 d2 ff ff       	call   801031f3 <end_op>
    return -1;
80105f10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f15:	eb 18                	jmp    80105f2f <sys_mknod+0x97>
  }
  iunlockput(ip);
80105f17:	83 ec 0c             	sub    $0xc,%esp
80105f1a:	ff 75 f4             	pushl  -0xc(%ebp)
80105f1d:	e8 89 bd ff ff       	call   80101cab <iunlockput>
80105f22:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f25:	e8 c9 d2 ff ff       	call   801031f3 <end_op>
  return 0;
80105f2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f2f:	c9                   	leave  
80105f30:	c3                   	ret    

80105f31 <sys_chdir>:

int
sys_chdir(void)
{
80105f31:	f3 0f 1e fb          	endbr32 
80105f35:	55                   	push   %ebp
80105f36:	89 e5                	mov    %esp,%ebp
80105f38:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105f3b:	e8 5b dc ff ff       	call   80103b9b <myproc>
80105f40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105f43:	e8 1b d2 ff ff       	call   80103163 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105f48:	83 ec 08             	sub    $0x8,%esp
80105f4b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f4e:	50                   	push   %eax
80105f4f:	6a 00                	push   $0x0
80105f51:	e8 06 f4 ff ff       	call   8010535c <argstr>
80105f56:	83 c4 10             	add    $0x10,%esp
80105f59:	85 c0                	test   %eax,%eax
80105f5b:	78 18                	js     80105f75 <sys_chdir+0x44>
80105f5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f60:	83 ec 0c             	sub    $0xc,%esp
80105f63:	50                   	push   %eax
80105f64:	e8 70 c6 ff ff       	call   801025d9 <namei>
80105f69:	83 c4 10             	add    $0x10,%esp
80105f6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f73:	75 0c                	jne    80105f81 <sys_chdir+0x50>
    end_op();
80105f75:	e8 79 d2 ff ff       	call   801031f3 <end_op>
    return -1;
80105f7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f7f:	eb 68                	jmp    80105fe9 <sys_chdir+0xb8>
  }
  ilock(ip);
80105f81:	83 ec 0c             	sub    $0xc,%esp
80105f84:	ff 75 f0             	pushl  -0x10(%ebp)
80105f87:	e8 e2 ba ff ff       	call   80101a6e <ilock>
80105f8c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105f8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f92:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f96:	66 83 f8 01          	cmp    $0x1,%ax
80105f9a:	74 1a                	je     80105fb6 <sys_chdir+0x85>
    iunlockput(ip);
80105f9c:	83 ec 0c             	sub    $0xc,%esp
80105f9f:	ff 75 f0             	pushl  -0x10(%ebp)
80105fa2:	e8 04 bd ff ff       	call   80101cab <iunlockput>
80105fa7:	83 c4 10             	add    $0x10,%esp
    end_op();
80105faa:	e8 44 d2 ff ff       	call   801031f3 <end_op>
    return -1;
80105faf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb4:	eb 33                	jmp    80105fe9 <sys_chdir+0xb8>
  }
  iunlock(ip);
80105fb6:	83 ec 0c             	sub    $0xc,%esp
80105fb9:	ff 75 f0             	pushl  -0x10(%ebp)
80105fbc:	e8 c4 bb ff ff       	call   80101b85 <iunlock>
80105fc1:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc7:	8b 40 68             	mov    0x68(%eax),%eax
80105fca:	83 ec 0c             	sub    $0xc,%esp
80105fcd:	50                   	push   %eax
80105fce:	e8 04 bc ff ff       	call   80101bd7 <iput>
80105fd3:	83 c4 10             	add    $0x10,%esp
  end_op();
80105fd6:	e8 18 d2 ff ff       	call   801031f3 <end_op>
  curproc->cwd = ip;
80105fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fde:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fe1:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105fe4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fe9:	c9                   	leave  
80105fea:	c3                   	ret    

80105feb <sys_exec>:

int
sys_exec(void)
{
80105feb:	f3 0f 1e fb          	endbr32 
80105fef:	55                   	push   %ebp
80105ff0:	89 e5                	mov    %esp,%ebp
80105ff2:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ff8:	83 ec 08             	sub    $0x8,%esp
80105ffb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ffe:	50                   	push   %eax
80105fff:	6a 00                	push   $0x0
80106001:	e8 56 f3 ff ff       	call   8010535c <argstr>
80106006:	83 c4 10             	add    $0x10,%esp
80106009:	85 c0                	test   %eax,%eax
8010600b:	78 18                	js     80106025 <sys_exec+0x3a>
8010600d:	83 ec 08             	sub    $0x8,%esp
80106010:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106016:	50                   	push   %eax
80106017:	6a 01                	push   $0x1
80106019:	e8 a1 f2 ff ff       	call   801052bf <argint>
8010601e:	83 c4 10             	add    $0x10,%esp
80106021:	85 c0                	test   %eax,%eax
80106023:	79 0a                	jns    8010602f <sys_exec+0x44>
    return -1;
80106025:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602a:	e9 c6 00 00 00       	jmp    801060f5 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
8010602f:	83 ec 04             	sub    $0x4,%esp
80106032:	68 80 00 00 00       	push   $0x80
80106037:	6a 00                	push   $0x0
80106039:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010603f:	50                   	push   %eax
80106040:	e8 26 ef ff ff       	call   80104f6b <memset>
80106045:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106048:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010604f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106052:	83 f8 1f             	cmp    $0x1f,%eax
80106055:	76 0a                	jbe    80106061 <sys_exec+0x76>
      return -1;
80106057:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010605c:	e9 94 00 00 00       	jmp    801060f5 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106064:	c1 e0 02             	shl    $0x2,%eax
80106067:	89 c2                	mov    %eax,%edx
80106069:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010606f:	01 c2                	add    %eax,%edx
80106071:	83 ec 08             	sub    $0x8,%esp
80106074:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010607a:	50                   	push   %eax
8010607b:	52                   	push   %edx
8010607c:	e8 93 f1 ff ff       	call   80105214 <fetchint>
80106081:	83 c4 10             	add    $0x10,%esp
80106084:	85 c0                	test   %eax,%eax
80106086:	79 07                	jns    8010608f <sys_exec+0xa4>
      return -1;
80106088:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010608d:	eb 66                	jmp    801060f5 <sys_exec+0x10a>
    if(uarg == 0){
8010608f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106095:	85 c0                	test   %eax,%eax
80106097:	75 27                	jne    801060c0 <sys_exec+0xd5>
      argv[i] = 0;
80106099:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801060a3:	00 00 00 00 
      break;
801060a7:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801060a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ab:	83 ec 08             	sub    $0x8,%esp
801060ae:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801060b4:	52                   	push   %edx
801060b5:	50                   	push   %eax
801060b6:	e8 03 ab ff ff       	call   80100bbe <exec>
801060bb:	83 c4 10             	add    $0x10,%esp
801060be:	eb 35                	jmp    801060f5 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801060c0:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801060c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060c9:	c1 e2 02             	shl    $0x2,%edx
801060cc:	01 c2                	add    %eax,%edx
801060ce:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801060d4:	83 ec 08             	sub    $0x8,%esp
801060d7:	52                   	push   %edx
801060d8:	50                   	push   %eax
801060d9:	e8 79 f1 ff ff       	call   80105257 <fetchstr>
801060de:	83 c4 10             	add    $0x10,%esp
801060e1:	85 c0                	test   %eax,%eax
801060e3:	79 07                	jns    801060ec <sys_exec+0x101>
      return -1;
801060e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ea:	eb 09                	jmp    801060f5 <sys_exec+0x10a>
  for(i=0;; i++){
801060ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801060f0:	e9 5a ff ff ff       	jmp    8010604f <sys_exec+0x64>
}
801060f5:	c9                   	leave  
801060f6:	c3                   	ret    

801060f7 <sys_pipe>:

int
sys_pipe(void)
{
801060f7:	f3 0f 1e fb          	endbr32 
801060fb:	55                   	push   %ebp
801060fc:	89 e5                	mov    %esp,%ebp
801060fe:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106101:	83 ec 04             	sub    $0x4,%esp
80106104:	6a 08                	push   $0x8
80106106:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106109:	50                   	push   %eax
8010610a:	6a 00                	push   $0x0
8010610c:	e8 df f1 ff ff       	call   801052f0 <argptr>
80106111:	83 c4 10             	add    $0x10,%esp
80106114:	85 c0                	test   %eax,%eax
80106116:	79 0a                	jns    80106122 <sys_pipe+0x2b>
    return -1;
80106118:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611d:	e9 ae 00 00 00       	jmp    801061d0 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106122:	83 ec 08             	sub    $0x8,%esp
80106125:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106128:	50                   	push   %eax
80106129:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010612c:	50                   	push   %eax
8010612d:	e8 8a d5 ff ff       	call   801036bc <pipealloc>
80106132:	83 c4 10             	add    $0x10,%esp
80106135:	85 c0                	test   %eax,%eax
80106137:	79 0a                	jns    80106143 <sys_pipe+0x4c>
    return -1;
80106139:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010613e:	e9 8d 00 00 00       	jmp    801061d0 <sys_pipe+0xd9>
  fd0 = -1;
80106143:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010614a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010614d:	83 ec 0c             	sub    $0xc,%esp
80106150:	50                   	push   %eax
80106151:	e8 3b f3 ff ff       	call   80105491 <fdalloc>
80106156:	83 c4 10             	add    $0x10,%esp
80106159:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010615c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106160:	78 18                	js     8010617a <sys_pipe+0x83>
80106162:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106165:	83 ec 0c             	sub    $0xc,%esp
80106168:	50                   	push   %eax
80106169:	e8 23 f3 ff ff       	call   80105491 <fdalloc>
8010616e:	83 c4 10             	add    $0x10,%esp
80106171:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106174:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106178:	79 3e                	jns    801061b8 <sys_pipe+0xc1>
    if(fd0 >= 0)
8010617a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010617e:	78 13                	js     80106193 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106180:	e8 16 da ff ff       	call   80103b9b <myproc>
80106185:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106188:	83 c2 08             	add    $0x8,%edx
8010618b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106192:	00 
    fileclose(rf);
80106193:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106196:	83 ec 0c             	sub    $0xc,%esp
80106199:	50                   	push   %eax
8010619a:	e8 3c af ff ff       	call   801010db <fileclose>
8010619f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801061a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061a5:	83 ec 0c             	sub    $0xc,%esp
801061a8:	50                   	push   %eax
801061a9:	e8 2d af ff ff       	call   801010db <fileclose>
801061ae:	83 c4 10             	add    $0x10,%esp
    return -1;
801061b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b6:	eb 18                	jmp    801061d0 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801061b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061be:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801061c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061c3:	8d 50 04             	lea    0x4(%eax),%edx
801061c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c9:	89 02                	mov    %eax,(%edx)
  return 0;
801061cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061d0:	c9                   	leave  
801061d1:	c3                   	ret    

801061d2 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801061d2:	f3 0f 1e fb          	endbr32 
801061d6:	55                   	push   %ebp
801061d7:	89 e5                	mov    %esp,%ebp
801061d9:	83 ec 08             	sub    $0x8,%esp
  return fork();
801061dc:	e8 dd dc ff ff       	call   80103ebe <fork>
}
801061e1:	c9                   	leave  
801061e2:	c3                   	ret    

801061e3 <sys_exit>:

int
sys_exit(void)
{
801061e3:	f3 0f 1e fb          	endbr32 
801061e7:	55                   	push   %ebp
801061e8:	89 e5                	mov    %esp,%ebp
801061ea:	83 ec 08             	sub    $0x8,%esp
  exit();
801061ed:	e8 49 de ff ff       	call   8010403b <exit>
  return 0;  // not reached
801061f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061f7:	c9                   	leave  
801061f8:	c3                   	ret    

801061f9 <sys_wait>:

int
sys_wait(void)
{
801061f9:	f3 0f 1e fb          	endbr32 
801061fd:	55                   	push   %ebp
801061fe:	89 e5                	mov    %esp,%ebp
80106200:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106203:	e8 97 e0 ff ff       	call   8010429f <wait>
}
80106208:	c9                   	leave  
80106209:	c3                   	ret    

8010620a <sys_kill>:

int
sys_kill(void)
{
8010620a:	f3 0f 1e fb          	endbr32 
8010620e:	55                   	push   %ebp
8010620f:	89 e5                	mov    %esp,%ebp
80106211:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106214:	83 ec 08             	sub    $0x8,%esp
80106217:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010621a:	50                   	push   %eax
8010621b:	6a 00                	push   $0x0
8010621d:	e8 9d f0 ff ff       	call   801052bf <argint>
80106222:	83 c4 10             	add    $0x10,%esp
80106225:	85 c0                	test   %eax,%eax
80106227:	79 07                	jns    80106230 <sys_kill+0x26>
    return -1;
80106229:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622e:	eb 0f                	jmp    8010623f <sys_kill+0x35>
  return kill(pid);
80106230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106233:	83 ec 0c             	sub    $0xc,%esp
80106236:	50                   	push   %eax
80106237:	e8 23 e6 ff ff       	call   8010485f <kill>
8010623c:	83 c4 10             	add    $0x10,%esp
}
8010623f:	c9                   	leave  
80106240:	c3                   	ret    

80106241 <sys_getpid>:

int
sys_getpid(void)
{
80106241:	f3 0f 1e fb          	endbr32 
80106245:	55                   	push   %ebp
80106246:	89 e5                	mov    %esp,%ebp
80106248:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010624b:	e8 4b d9 ff ff       	call   80103b9b <myproc>
80106250:	8b 40 10             	mov    0x10(%eax),%eax
}
80106253:	c9                   	leave  
80106254:	c3                   	ret    

80106255 <sys_sbrk>:

int
sys_sbrk(void)
{
80106255:	f3 0f 1e fb          	endbr32 
80106259:	55                   	push   %ebp
8010625a:	89 e5                	mov    %esp,%ebp
8010625c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010625f:	83 ec 08             	sub    $0x8,%esp
80106262:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106265:	50                   	push   %eax
80106266:	6a 00                	push   $0x0
80106268:	e8 52 f0 ff ff       	call   801052bf <argint>
8010626d:	83 c4 10             	add    $0x10,%esp
80106270:	85 c0                	test   %eax,%eax
80106272:	79 07                	jns    8010627b <sys_sbrk+0x26>
    return -1;
80106274:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106279:	eb 27                	jmp    801062a2 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010627b:	e8 1b d9 ff ff       	call   80103b9b <myproc>
80106280:	8b 00                	mov    (%eax),%eax
80106282:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106285:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106288:	83 ec 0c             	sub    $0xc,%esp
8010628b:	50                   	push   %eax
8010628c:	e8 8e db ff ff       	call   80103e1f <growproc>
80106291:	83 c4 10             	add    $0x10,%esp
80106294:	85 c0                	test   %eax,%eax
80106296:	79 07                	jns    8010629f <sys_sbrk+0x4a>
    return -1;
80106298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629d:	eb 03                	jmp    801062a2 <sys_sbrk+0x4d>
  return addr;
8010629f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801062a2:	c9                   	leave  
801062a3:	c3                   	ret    

801062a4 <sys_sleep>:

int
sys_sleep(void)
{
801062a4:	f3 0f 1e fb          	endbr32 
801062a8:	55                   	push   %ebp
801062a9:	89 e5                	mov    %esp,%ebp
801062ab:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801062ae:	83 ec 08             	sub    $0x8,%esp
801062b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062b4:	50                   	push   %eax
801062b5:	6a 00                	push   $0x0
801062b7:	e8 03 f0 ff ff       	call   801052bf <argint>
801062bc:	83 c4 10             	add    $0x10,%esp
801062bf:	85 c0                	test   %eax,%eax
801062c1:	79 07                	jns    801062ca <sys_sleep+0x26>
    return -1;
801062c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c8:	eb 76                	jmp    80106340 <sys_sleep+0x9c>
  acquire(&tickslock);
801062ca:	83 ec 0c             	sub    $0xc,%esp
801062cd:	68 40 79 19 80       	push   $0x80197940
801062d2:	e8 05 ea ff ff       	call   80104cdc <acquire>
801062d7:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801062da:	a1 80 81 19 80       	mov    0x80198180,%eax
801062df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801062e2:	eb 38                	jmp    8010631c <sys_sleep+0x78>
    if(myproc()->killed){
801062e4:	e8 b2 d8 ff ff       	call   80103b9b <myproc>
801062e9:	8b 40 24             	mov    0x24(%eax),%eax
801062ec:	85 c0                	test   %eax,%eax
801062ee:	74 17                	je     80106307 <sys_sleep+0x63>
      release(&tickslock);
801062f0:	83 ec 0c             	sub    $0xc,%esp
801062f3:	68 40 79 19 80       	push   $0x80197940
801062f8:	e8 51 ea ff ff       	call   80104d4e <release>
801062fd:	83 c4 10             	add    $0x10,%esp
      return -1;
80106300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106305:	eb 39                	jmp    80106340 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106307:	83 ec 08             	sub    $0x8,%esp
8010630a:	68 40 79 19 80       	push   $0x80197940
8010630f:	68 80 81 19 80       	push   $0x80198180
80106314:	e8 19 e4 ff ff       	call   80104732 <sleep>
80106319:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010631c:	a1 80 81 19 80       	mov    0x80198180,%eax
80106321:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106324:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106327:	39 d0                	cmp    %edx,%eax
80106329:	72 b9                	jb     801062e4 <sys_sleep+0x40>
  }
  release(&tickslock);
8010632b:	83 ec 0c             	sub    $0xc,%esp
8010632e:	68 40 79 19 80       	push   $0x80197940
80106333:	e8 16 ea ff ff       	call   80104d4e <release>
80106338:	83 c4 10             	add    $0x10,%esp
  return 0;
8010633b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106340:	c9                   	leave  
80106341:	c3                   	ret    

80106342 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106342:	f3 0f 1e fb          	endbr32 
80106346:	55                   	push   %ebp
80106347:	89 e5                	mov    %esp,%ebp
80106349:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010634c:	83 ec 0c             	sub    $0xc,%esp
8010634f:	68 40 79 19 80       	push   $0x80197940
80106354:	e8 83 e9 ff ff       	call   80104cdc <acquire>
80106359:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010635c:	a1 80 81 19 80       	mov    0x80198180,%eax
80106361:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106364:	83 ec 0c             	sub    $0xc,%esp
80106367:	68 40 79 19 80       	push   $0x80197940
8010636c:	e8 dd e9 ff ff       	call   80104d4e <release>
80106371:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106374:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106377:	c9                   	leave  
80106378:	c3                   	ret    

80106379 <sys_exit2>:

int
sys_exit2(void)
{
80106379:	f3 0f 1e fb          	endbr32 
8010637d:	55                   	push   %ebp
8010637e:	89 e5                	mov    %esp,%ebp
80106380:	83 ec 18             	sub    $0x18,%esp
  int status;
  if(argint(0, &status) < 0)
80106383:	83 ec 08             	sub    $0x8,%esp
80106386:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106389:	50                   	push   %eax
8010638a:	6a 00                	push   $0x0
8010638c:	e8 2e ef ff ff       	call   801052bf <argint>
80106391:	83 c4 10             	add    $0x10,%esp
80106394:	85 c0                	test   %eax,%eax
80106396:	79 07                	jns    8010639f <sys_exit2+0x26>
    return -1; 
80106398:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639d:	eb 15                	jmp    801063b4 <sys_exit2+0x3b>

  myproc()->xstate = status;
8010639f:	e8 f7 d7 ff ff       	call   80103b9b <myproc>
801063a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063a7:	89 50 7c             	mov    %edx,0x7c(%eax)
  exit();
801063aa:	e8 8c dc ff ff       	call   8010403b <exit>
  return 0;
801063af:	b8 00 00 00 00       	mov    $0x0,%eax
}	
801063b4:	c9                   	leave  
801063b5:	c3                   	ret    

801063b6 <sys_wait2>:

extern int wait2(int *status);

int sys_wait2(void) 
{
801063b6:	f3 0f 1e fb          	endbr32 
801063ba:	55                   	push   %ebp
801063bb:	89 e5                	mov    %esp,%ebp
801063bd:	83 ec 18             	sub    $0x18,%esp
  int *status;
  if(argptr(0, (void *)&status, sizeof(*status)) < 0)
801063c0:	83 ec 04             	sub    $0x4,%esp
801063c3:	6a 04                	push   $0x4
801063c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063c8:	50                   	push   %eax
801063c9:	6a 00                	push   $0x0
801063cb:	e8 20 ef ff ff       	call   801052f0 <argptr>
801063d0:	83 c4 10             	add    $0x10,%esp
801063d3:	85 c0                	test   %eax,%eax
801063d5:	79 07                	jns    801063de <sys_wait2+0x28>
    return -1;
801063d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063dc:	eb 0f                	jmp    801063ed <sys_wait2+0x37>
  return wait2(status);
801063de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e1:	83 ec 0c             	sub    $0xc,%esp
801063e4:	50                   	push   %eax
801063e5:	e8 dc df ff ff       	call   801043c6 <wait2>
801063ea:	83 c4 10             	add    $0x10,%esp
}
801063ed:	c9                   	leave  
801063ee:	c3                   	ret    

801063ef <sys_uthread_init>:

int
sys_uthread_init(void)
{
801063ef:	f3 0f 1e fb          	endbr32 
801063f3:	55                   	push   %ebp
801063f4:	89 e5                	mov    %esp,%ebp
801063f6:	83 ec 18             	sub    $0x18,%esp
    struct proc* p;
    int func;

    if (argint(0, &func) < 0)
801063f9:	83 ec 08             	sub    $0x8,%esp
801063fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ff:	50                   	push   %eax
80106400:	6a 00                	push   $0x0
80106402:	e8 b8 ee ff ff       	call   801052bf <argint>
80106407:	83 c4 10             	add    $0x10,%esp
8010640a:	85 c0                	test   %eax,%eax
8010640c:	79 07                	jns    80106415 <sys_uthread_init+0x26>
        return -1;
8010640e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106413:	eb 1b                	jmp    80106430 <sys_uthread_init+0x41>

    p = myproc();
80106415:	e8 81 d7 ff ff       	call   80103b9b <myproc>
8010641a:	89 45 f4             	mov    %eax,-0xc(%ebp)

    p->scheduler = (uint)func;
8010641d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106420:	89 c2                	mov    %eax,%edx
80106422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106425:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

    return 0;
8010642b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106430:	c9                   	leave  
80106431:	c3                   	ret    

80106432 <sys_printpt>:

int sys_printpt(void) {
80106432:	f3 0f 1e fb          	endbr32 
80106436:	55                   	push   %ebp
80106437:	89 e5                	mov    %esp,%ebp
80106439:	83 ec 18             	sub    $0x18,%esp
    int pid;
    if(argint(0, &pid) < 0)
8010643c:	83 ec 08             	sub    $0x8,%esp
8010643f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106442:	50                   	push   %eax
80106443:	6a 00                	push   $0x0
80106445:	e8 75 ee ff ff       	call   801052bf <argint>
8010644a:	83 c4 10             	add    $0x10,%esp
8010644d:	85 c0                	test   %eax,%eax
8010644f:	79 07                	jns    80106458 <sys_printpt+0x26>
        return -1;
80106451:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106456:	eb 14                	jmp    8010646c <sys_printpt+0x3a>
    printpt(pid);
80106458:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010645b:	83 ec 0c             	sub    $0xc,%esp
8010645e:	50                   	push   %eax
8010645f:	e8 87 e5 ff ff       	call   801049eb <printpt>
80106464:	83 c4 10             	add    $0x10,%esp
    return 0;
80106467:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010646c:	c9                   	leave  
8010646d:	c3                   	ret    

8010646e <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010646e:	1e                   	push   %ds
  pushl %es
8010646f:	06                   	push   %es
  pushl %fs
80106470:	0f a0                	push   %fs
  pushl %gs
80106472:	0f a8                	push   %gs
  pushal
80106474:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106475:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106479:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010647b:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010647d:	54                   	push   %esp
  call trap
8010647e:	e8 df 01 00 00       	call   80106662 <trap>
  addl $4, %esp
80106483:	83 c4 04             	add    $0x4,%esp

80106486 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106486:	61                   	popa   
  popl %gs
80106487:	0f a9                	pop    %gs
  popl %fs
80106489:	0f a1                	pop    %fs
  popl %es
8010648b:	07                   	pop    %es
  popl %ds
8010648c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010648d:	83 c4 08             	add    $0x8,%esp
  iret
80106490:	cf                   	iret   

80106491 <lidt>:
{
80106491:	55                   	push   %ebp
80106492:	89 e5                	mov    %esp,%ebp
80106494:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106497:	8b 45 0c             	mov    0xc(%ebp),%eax
8010649a:	83 e8 01             	sub    $0x1,%eax
8010649d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801064a1:	8b 45 08             	mov    0x8(%ebp),%eax
801064a4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801064a8:	8b 45 08             	mov    0x8(%ebp),%eax
801064ab:	c1 e8 10             	shr    $0x10,%eax
801064ae:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801064b2:	8d 45 fa             	lea    -0x6(%ebp),%eax
801064b5:	0f 01 18             	lidtl  (%eax)
}
801064b8:	90                   	nop
801064b9:	c9                   	leave  
801064ba:	c3                   	ret    

801064bb <rcr2>:

static inline uint
rcr2(void)
{
801064bb:	55                   	push   %ebp
801064bc:	89 e5                	mov    %esp,%ebp
801064be:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801064c1:	0f 20 d0             	mov    %cr2,%eax
801064c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801064c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801064ca:	c9                   	leave  
801064cb:	c3                   	ret    

801064cc <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801064cc:	f3 0f 1e fb          	endbr32 
801064d0:	55                   	push   %ebp
801064d1:	89 e5                	mov    %esp,%ebp
801064d3:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801064d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801064dd:	e9 c3 00 00 00       	jmp    801065a5 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801064e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e5:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
801064ec:	89 c2                	mov    %eax,%edx
801064ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f1:	66 89 14 c5 80 79 19 	mov    %dx,-0x7fe68680(,%eax,8)
801064f8:	80 
801064f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064fc:	66 c7 04 c5 82 79 19 	movw   $0x8,-0x7fe6867e(,%eax,8)
80106503:	80 08 00 
80106506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106509:	0f b6 14 c5 84 79 19 	movzbl -0x7fe6867c(,%eax,8),%edx
80106510:	80 
80106511:	83 e2 e0             	and    $0xffffffe0,%edx
80106514:	88 14 c5 84 79 19 80 	mov    %dl,-0x7fe6867c(,%eax,8)
8010651b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651e:	0f b6 14 c5 84 79 19 	movzbl -0x7fe6867c(,%eax,8),%edx
80106525:	80 
80106526:	83 e2 1f             	and    $0x1f,%edx
80106529:	88 14 c5 84 79 19 80 	mov    %dl,-0x7fe6867c(,%eax,8)
80106530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106533:	0f b6 14 c5 85 79 19 	movzbl -0x7fe6867b(,%eax,8),%edx
8010653a:	80 
8010653b:	83 e2 f0             	and    $0xfffffff0,%edx
8010653e:	83 ca 0e             	or     $0xe,%edx
80106541:	88 14 c5 85 79 19 80 	mov    %dl,-0x7fe6867b(,%eax,8)
80106548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654b:	0f b6 14 c5 85 79 19 	movzbl -0x7fe6867b(,%eax,8),%edx
80106552:	80 
80106553:	83 e2 ef             	and    $0xffffffef,%edx
80106556:	88 14 c5 85 79 19 80 	mov    %dl,-0x7fe6867b(,%eax,8)
8010655d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106560:	0f b6 14 c5 85 79 19 	movzbl -0x7fe6867b(,%eax,8),%edx
80106567:	80 
80106568:	83 e2 9f             	and    $0xffffff9f,%edx
8010656b:	88 14 c5 85 79 19 80 	mov    %dl,-0x7fe6867b(,%eax,8)
80106572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106575:	0f b6 14 c5 85 79 19 	movzbl -0x7fe6867b(,%eax,8),%edx
8010657c:	80 
8010657d:	83 ca 80             	or     $0xffffff80,%edx
80106580:	88 14 c5 85 79 19 80 	mov    %dl,-0x7fe6867b(,%eax,8)
80106587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658a:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106591:	c1 e8 10             	shr    $0x10,%eax
80106594:	89 c2                	mov    %eax,%edx
80106596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106599:	66 89 14 c5 86 79 19 	mov    %dx,-0x7fe6867a(,%eax,8)
801065a0:	80 
  for(i = 0; i < 256; i++)
801065a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801065a5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801065ac:	0f 8e 30 ff ff ff    	jle    801064e2 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801065b2:	a1 88 f1 10 80       	mov    0x8010f188,%eax
801065b7:	66 a3 80 7b 19 80    	mov    %ax,0x80197b80
801065bd:	66 c7 05 82 7b 19 80 	movw   $0x8,0x80197b82
801065c4:	08 00 
801065c6:	0f b6 05 84 7b 19 80 	movzbl 0x80197b84,%eax
801065cd:	83 e0 e0             	and    $0xffffffe0,%eax
801065d0:	a2 84 7b 19 80       	mov    %al,0x80197b84
801065d5:	0f b6 05 84 7b 19 80 	movzbl 0x80197b84,%eax
801065dc:	83 e0 1f             	and    $0x1f,%eax
801065df:	a2 84 7b 19 80       	mov    %al,0x80197b84
801065e4:	0f b6 05 85 7b 19 80 	movzbl 0x80197b85,%eax
801065eb:	83 c8 0f             	or     $0xf,%eax
801065ee:	a2 85 7b 19 80       	mov    %al,0x80197b85
801065f3:	0f b6 05 85 7b 19 80 	movzbl 0x80197b85,%eax
801065fa:	83 e0 ef             	and    $0xffffffef,%eax
801065fd:	a2 85 7b 19 80       	mov    %al,0x80197b85
80106602:	0f b6 05 85 7b 19 80 	movzbl 0x80197b85,%eax
80106609:	83 c8 60             	or     $0x60,%eax
8010660c:	a2 85 7b 19 80       	mov    %al,0x80197b85
80106611:	0f b6 05 85 7b 19 80 	movzbl 0x80197b85,%eax
80106618:	83 c8 80             	or     $0xffffff80,%eax
8010661b:	a2 85 7b 19 80       	mov    %al,0x80197b85
80106620:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106625:	c1 e8 10             	shr    $0x10,%eax
80106628:	66 a3 86 7b 19 80    	mov    %ax,0x80197b86

  initlock(&tickslock, "time");
8010662e:	83 ec 08             	sub    $0x8,%esp
80106631:	68 78 ae 10 80       	push   $0x8010ae78
80106636:	68 40 79 19 80       	push   $0x80197940
8010663b:	e8 76 e6 ff ff       	call   80104cb6 <initlock>
80106640:	83 c4 10             	add    $0x10,%esp
}
80106643:	90                   	nop
80106644:	c9                   	leave  
80106645:	c3                   	ret    

80106646 <idtinit>:

void
idtinit(void)
{
80106646:	f3 0f 1e fb          	endbr32 
8010664a:	55                   	push   %ebp
8010664b:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010664d:	68 00 08 00 00       	push   $0x800
80106652:	68 80 79 19 80       	push   $0x80197980
80106657:	e8 35 fe ff ff       	call   80106491 <lidt>
8010665c:	83 c4 08             	add    $0x8,%esp
}
8010665f:	90                   	nop
80106660:	c9                   	leave  
80106661:	c3                   	ret    

80106662 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106662:	f3 0f 1e fb          	endbr32 
80106666:	55                   	push   %ebp
80106667:	89 e5                	mov    %esp,%ebp
80106669:	57                   	push   %edi
8010666a:	56                   	push   %esi
8010666b:	53                   	push   %ebx
8010666c:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
8010666f:	8b 45 08             	mov    0x8(%ebp),%eax
80106672:	8b 40 30             	mov    0x30(%eax),%eax
80106675:	83 f8 40             	cmp    $0x40,%eax
80106678:	75 3b                	jne    801066b5 <trap+0x53>
    if(myproc()->killed)
8010667a:	e8 1c d5 ff ff       	call   80103b9b <myproc>
8010667f:	8b 40 24             	mov    0x24(%eax),%eax
80106682:	85 c0                	test   %eax,%eax
80106684:	74 05                	je     8010668b <trap+0x29>
      exit();
80106686:	e8 b0 d9 ff ff       	call   8010403b <exit>
    myproc()->tf = tf;
8010668b:	e8 0b d5 ff ff       	call   80103b9b <myproc>
80106690:	8b 55 08             	mov    0x8(%ebp),%edx
80106693:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106696:	e8 fc ec ff ff       	call   80105397 <syscall>
    if(myproc()->killed)
8010669b:	e8 fb d4 ff ff       	call   80103b9b <myproc>
801066a0:	8b 40 24             	mov    0x24(%eax),%eax
801066a3:	85 c0                	test   %eax,%eax
801066a5:	0f 84 af 02 00 00    	je     8010695a <trap+0x2f8>
      exit();
801066ab:	e8 8b d9 ff ff       	call   8010403b <exit>
    return;
801066b0:	e9 a5 02 00 00       	jmp    8010695a <trap+0x2f8>
  }

  switch(tf->trapno){
801066b5:	8b 45 08             	mov    0x8(%ebp),%eax
801066b8:	8b 40 30             	mov    0x30(%eax),%eax
801066bb:	83 e8 0e             	sub    $0xe,%eax
801066be:	83 f8 31             	cmp    $0x31,%eax
801066c1:	0f 87 5e 01 00 00    	ja     80106825 <trap+0x1c3>
801066c7:	8b 04 85 e0 af 10 80 	mov    -0x7fef5020(,%eax,4),%eax
801066ce:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801066d1:	e8 2a d4 ff ff       	call   80103b00 <cpuid>
801066d6:	85 c0                	test   %eax,%eax
801066d8:	75 3d                	jne    80106717 <trap+0xb5>
      acquire(&tickslock);
801066da:	83 ec 0c             	sub    $0xc,%esp
801066dd:	68 40 79 19 80       	push   $0x80197940
801066e2:	e8 f5 e5 ff ff       	call   80104cdc <acquire>
801066e7:	83 c4 10             	add    $0x10,%esp
      ticks++;
801066ea:	a1 80 81 19 80       	mov    0x80198180,%eax
801066ef:	83 c0 01             	add    $0x1,%eax
801066f2:	a3 80 81 19 80       	mov    %eax,0x80198180
      wakeup(&ticks);
801066f7:	83 ec 0c             	sub    $0xc,%esp
801066fa:	68 80 81 19 80       	push   $0x80198180
801066ff:	e8 20 e1 ff ff       	call   80104824 <wakeup>
80106704:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106707:	83 ec 0c             	sub    $0xc,%esp
8010670a:	68 40 79 19 80       	push   $0x80197940
8010670f:	e8 3a e6 ff ff       	call   80104d4e <release>
80106714:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106717:	e8 fb c4 ff ff       	call   80102c17 <lapiceoi>
    break;
8010671c:	e9 b9 01 00 00       	jmp    801068da <trap+0x278>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106721:	e8 96 41 00 00       	call   8010a8bc <ideintr>
    lapiceoi();
80106726:	e8 ec c4 ff ff       	call   80102c17 <lapiceoi>
    break;
8010672b:	e9 aa 01 00 00       	jmp    801068da <trap+0x278>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106730:	e8 18 c3 ff ff       	call   80102a4d <kbdintr>
    lapiceoi();
80106735:	e8 dd c4 ff ff       	call   80102c17 <lapiceoi>
    break;
8010673a:	e9 9b 01 00 00       	jmp    801068da <trap+0x278>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010673f:	e8 f8 03 00 00       	call   80106b3c <uartintr>
    lapiceoi();
80106744:	e8 ce c4 ff ff       	call   80102c17 <lapiceoi>
    break;
80106749:	e9 8c 01 00 00       	jmp    801068da <trap+0x278>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010674e:	8b 45 08             	mov    0x8(%ebp),%eax
80106751:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106754:	8b 45 08             	mov    0x8(%ebp),%eax
80106757:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010675b:	0f b7 d8             	movzwl %ax,%ebx
8010675e:	e8 9d d3 ff ff       	call   80103b00 <cpuid>
80106763:	56                   	push   %esi
80106764:	53                   	push   %ebx
80106765:	50                   	push   %eax
80106766:	68 80 ae 10 80       	push   $0x8010ae80
8010676b:	e8 9c 9c ff ff       	call   8010040c <cprintf>
80106770:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106773:	e8 9f c4 ff ff       	call   80102c17 <lapiceoi>
    break;
80106778:	e9 5d 01 00 00       	jmp    801068da <trap+0x278>

  case T_PGFLT: ;
    uint f = rcr2();
8010677d:	e8 39 fd ff ff       	call   801064bb <rcr2>
80106782:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (f > KERNBASE){
80106785:	81 7d e4 00 00 00 80 	cmpl   $0x80000000,-0x1c(%ebp)
8010678c:	76 15                	jbe    801067a3 <trap+0x141>
      cprintf("from trap access > KERNBASE");
8010678e:	83 ec 0c             	sub    $0xc,%esp
80106791:	68 a4 ae 10 80       	push   $0x8010aea4
80106796:	e8 71 9c ff ff       	call   8010040c <cprintf>
8010679b:	83 c4 10             	add    $0x10,%esp
      exit();
8010679e:	e8 98 d8 ff ff       	call   8010403b <exit>
    }
    f = PGROUNDDOWN(f);
801067a3:	81 65 e4 00 f0 ff ff 	andl   $0xfffff000,-0x1c(%ebp)
    if (allocuvm(myproc()->pgdir, f, f + PGSIZE) == 0) {
801067aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067ad:	8d 98 00 10 00 00    	lea    0x1000(%eax),%ebx
801067b3:	e8 e3 d3 ff ff       	call   80103b9b <myproc>
801067b8:	8b 40 04             	mov    0x4(%eax),%eax
801067bb:	83 ec 04             	sub    $0x4,%esp
801067be:	53                   	push   %ebx
801067bf:	ff 75 e4             	pushl  -0x1c(%ebp)
801067c2:	50                   	push   %eax
801067c3:	e8 ea 16 00 00       	call   80107eb2 <allocuvm>
801067c8:	83 c4 10             	add    $0x10,%esp
801067cb:	85 c0                	test   %eax,%eax
801067cd:	75 21                	jne    801067f0 <trap+0x18e>
      cprintf("case T_PGFLT from trap.c: allocuvm failed. Number of current allocated pages: %d\n", myproc()->stack_alloc);
801067cf:	e8 c7 d3 ff ff       	call   80103b9b <myproc>
801067d4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801067da:	83 ec 08             	sub    $0x8,%esp
801067dd:	50                   	push   %eax
801067de:	68 c0 ae 10 80       	push   $0x8010aec0
801067e3:	e8 24 9c ff ff       	call   8010040c <cprintf>
801067e8:	83 c4 10             	add    $0x10,%esp
      exit();
801067eb:	e8 4b d8 ff ff       	call   8010403b <exit>
    }
    myproc()->stack_alloc++;
801067f0:	e8 a6 d3 ff ff       	call   80103b9b <myproc>
801067f5:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801067fb:	83 c2 01             	add    $0x1,%edx
801067fe:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    cprintf("case T_PGFLT from trap.c: allocuvm succeeded. Number of pages allocated: %d\n", myproc()->stack_alloc);
80106804:	e8 92 d3 ff ff       	call   80103b9b <myproc>
80106809:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010680f:	83 ec 08             	sub    $0x8,%esp
80106812:	50                   	push   %eax
80106813:	68 14 af 10 80       	push   $0x8010af14
80106818:	e8 ef 9b ff ff       	call   8010040c <cprintf>
8010681d:	83 c4 10             	add    $0x10,%esp
    break;
80106820:	e9 b5 00 00 00       	jmp    801068da <trap+0x278>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106825:	e8 71 d3 ff ff       	call   80103b9b <myproc>
8010682a:	85 c0                	test   %eax,%eax
8010682c:	74 11                	je     8010683f <trap+0x1dd>
8010682e:	8b 45 08             	mov    0x8(%ebp),%eax
80106831:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106835:	0f b7 c0             	movzwl %ax,%eax
80106838:	83 e0 03             	and    $0x3,%eax
8010683b:	85 c0                	test   %eax,%eax
8010683d:	75 39                	jne    80106878 <trap+0x216>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010683f:	e8 77 fc ff ff       	call   801064bb <rcr2>
80106844:	89 c3                	mov    %eax,%ebx
80106846:	8b 45 08             	mov    0x8(%ebp),%eax
80106849:	8b 70 38             	mov    0x38(%eax),%esi
8010684c:	e8 af d2 ff ff       	call   80103b00 <cpuid>
80106851:	8b 55 08             	mov    0x8(%ebp),%edx
80106854:	8b 52 30             	mov    0x30(%edx),%edx
80106857:	83 ec 0c             	sub    $0xc,%esp
8010685a:	53                   	push   %ebx
8010685b:	56                   	push   %esi
8010685c:	50                   	push   %eax
8010685d:	52                   	push   %edx
8010685e:	68 64 af 10 80       	push   $0x8010af64
80106863:	e8 a4 9b ff ff       	call   8010040c <cprintf>
80106868:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010686b:	83 ec 0c             	sub    $0xc,%esp
8010686e:	68 96 af 10 80       	push   $0x8010af96
80106873:	e8 4d 9d ff ff       	call   801005c5 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106878:	e8 3e fc ff ff       	call   801064bb <rcr2>
8010687d:	89 c6                	mov    %eax,%esi
8010687f:	8b 45 08             	mov    0x8(%ebp),%eax
80106882:	8b 40 38             	mov    0x38(%eax),%eax
80106885:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106888:	e8 73 d2 ff ff       	call   80103b00 <cpuid>
8010688d:	89 c3                	mov    %eax,%ebx
8010688f:	8b 45 08             	mov    0x8(%ebp),%eax
80106892:	8b 48 34             	mov    0x34(%eax),%ecx
80106895:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106898:	8b 45 08             	mov    0x8(%ebp),%eax
8010689b:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010689e:	e8 f8 d2 ff ff       	call   80103b9b <myproc>
801068a3:	8d 50 6c             	lea    0x6c(%eax),%edx
801068a6:	89 55 cc             	mov    %edx,-0x34(%ebp)
801068a9:	e8 ed d2 ff ff       	call   80103b9b <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068ae:	8b 40 10             	mov    0x10(%eax),%eax
801068b1:	56                   	push   %esi
801068b2:	ff 75 d4             	pushl  -0x2c(%ebp)
801068b5:	53                   	push   %ebx
801068b6:	ff 75 d0             	pushl  -0x30(%ebp)
801068b9:	57                   	push   %edi
801068ba:	ff 75 cc             	pushl  -0x34(%ebp)
801068bd:	50                   	push   %eax
801068be:	68 9c af 10 80       	push   $0x8010af9c
801068c3:	e8 44 9b ff ff       	call   8010040c <cprintf>
801068c8:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801068cb:	e8 cb d2 ff ff       	call   80103b9b <myproc>
801068d0:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801068d7:	eb 01                	jmp    801068da <trap+0x278>
    break;
801068d9:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801068da:	e8 bc d2 ff ff       	call   80103b9b <myproc>
801068df:	85 c0                	test   %eax,%eax
801068e1:	74 23                	je     80106906 <trap+0x2a4>
801068e3:	e8 b3 d2 ff ff       	call   80103b9b <myproc>
801068e8:	8b 40 24             	mov    0x24(%eax),%eax
801068eb:	85 c0                	test   %eax,%eax
801068ed:	74 17                	je     80106906 <trap+0x2a4>
801068ef:	8b 45 08             	mov    0x8(%ebp),%eax
801068f2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068f6:	0f b7 c0             	movzwl %ax,%eax
801068f9:	83 e0 03             	and    $0x3,%eax
801068fc:	83 f8 03             	cmp    $0x3,%eax
801068ff:	75 05                	jne    80106906 <trap+0x2a4>
    exit();
80106901:	e8 35 d7 ff ff       	call   8010403b <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106906:	e8 90 d2 ff ff       	call   80103b9b <myproc>
8010690b:	85 c0                	test   %eax,%eax
8010690d:	74 1d                	je     8010692c <trap+0x2ca>
8010690f:	e8 87 d2 ff ff       	call   80103b9b <myproc>
80106914:	8b 40 0c             	mov    0xc(%eax),%eax
80106917:	83 f8 04             	cmp    $0x4,%eax
8010691a:	75 10                	jne    8010692c <trap+0x2ca>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010691c:	8b 45 08             	mov    0x8(%ebp),%eax
8010691f:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106922:	83 f8 20             	cmp    $0x20,%eax
80106925:	75 05                	jne    8010692c <trap+0x2ca>
    yield();
80106927:	e8 7e dd ff ff       	call   801046aa <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010692c:	e8 6a d2 ff ff       	call   80103b9b <myproc>
80106931:	85 c0                	test   %eax,%eax
80106933:	74 26                	je     8010695b <trap+0x2f9>
80106935:	e8 61 d2 ff ff       	call   80103b9b <myproc>
8010693a:	8b 40 24             	mov    0x24(%eax),%eax
8010693d:	85 c0                	test   %eax,%eax
8010693f:	74 1a                	je     8010695b <trap+0x2f9>
80106941:	8b 45 08             	mov    0x8(%ebp),%eax
80106944:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106948:	0f b7 c0             	movzwl %ax,%eax
8010694b:	83 e0 03             	and    $0x3,%eax
8010694e:	83 f8 03             	cmp    $0x3,%eax
80106951:	75 08                	jne    8010695b <trap+0x2f9>
    exit();
80106953:	e8 e3 d6 ff ff       	call   8010403b <exit>
80106958:	eb 01                	jmp    8010695b <trap+0x2f9>
    return;
8010695a:	90                   	nop
}
8010695b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010695e:	5b                   	pop    %ebx
8010695f:	5e                   	pop    %esi
80106960:	5f                   	pop    %edi
80106961:	5d                   	pop    %ebp
80106962:	c3                   	ret    

80106963 <inb>:
{
80106963:	55                   	push   %ebp
80106964:	89 e5                	mov    %esp,%ebp
80106966:	83 ec 14             	sub    $0x14,%esp
80106969:	8b 45 08             	mov    0x8(%ebp),%eax
8010696c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106970:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106974:	89 c2                	mov    %eax,%edx
80106976:	ec                   	in     (%dx),%al
80106977:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010697a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010697e:	c9                   	leave  
8010697f:	c3                   	ret    

80106980 <outb>:
{
80106980:	55                   	push   %ebp
80106981:	89 e5                	mov    %esp,%ebp
80106983:	83 ec 08             	sub    $0x8,%esp
80106986:	8b 45 08             	mov    0x8(%ebp),%eax
80106989:	8b 55 0c             	mov    0xc(%ebp),%edx
8010698c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106990:	89 d0                	mov    %edx,%eax
80106992:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106995:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106999:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010699d:	ee                   	out    %al,(%dx)
}
8010699e:	90                   	nop
8010699f:	c9                   	leave  
801069a0:	c3                   	ret    

801069a1 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801069a1:	f3 0f 1e fb          	endbr32 
801069a5:	55                   	push   %ebp
801069a6:	89 e5                	mov    %esp,%ebp
801069a8:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801069ab:	6a 00                	push   $0x0
801069ad:	68 fa 03 00 00       	push   $0x3fa
801069b2:	e8 c9 ff ff ff       	call   80106980 <outb>
801069b7:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801069ba:	68 80 00 00 00       	push   $0x80
801069bf:	68 fb 03 00 00       	push   $0x3fb
801069c4:	e8 b7 ff ff ff       	call   80106980 <outb>
801069c9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801069cc:	6a 0c                	push   $0xc
801069ce:	68 f8 03 00 00       	push   $0x3f8
801069d3:	e8 a8 ff ff ff       	call   80106980 <outb>
801069d8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801069db:	6a 00                	push   $0x0
801069dd:	68 f9 03 00 00       	push   $0x3f9
801069e2:	e8 99 ff ff ff       	call   80106980 <outb>
801069e7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801069ea:	6a 03                	push   $0x3
801069ec:	68 fb 03 00 00       	push   $0x3fb
801069f1:	e8 8a ff ff ff       	call   80106980 <outb>
801069f6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801069f9:	6a 00                	push   $0x0
801069fb:	68 fc 03 00 00       	push   $0x3fc
80106a00:	e8 7b ff ff ff       	call   80106980 <outb>
80106a05:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106a08:	6a 01                	push   $0x1
80106a0a:	68 f9 03 00 00       	push   $0x3f9
80106a0f:	e8 6c ff ff ff       	call   80106980 <outb>
80106a14:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106a17:	68 fd 03 00 00       	push   $0x3fd
80106a1c:	e8 42 ff ff ff       	call   80106963 <inb>
80106a21:	83 c4 04             	add    $0x4,%esp
80106a24:	3c ff                	cmp    $0xff,%al
80106a26:	74 61                	je     80106a89 <uartinit+0xe8>
    return;
  uart = 1;
80106a28:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
80106a2f:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106a32:	68 fa 03 00 00       	push   $0x3fa
80106a37:	e8 27 ff ff ff       	call   80106963 <inb>
80106a3c:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106a3f:	68 f8 03 00 00       	push   $0x3f8
80106a44:	e8 1a ff ff ff       	call   80106963 <inb>
80106a49:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106a4c:	83 ec 08             	sub    $0x8,%esp
80106a4f:	6a 00                	push   $0x0
80106a51:	6a 04                	push   $0x4
80106a53:	e8 a6 bc ff ff       	call   801026fe <ioapicenable>
80106a58:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a5b:	c7 45 f4 a8 b0 10 80 	movl   $0x8010b0a8,-0xc(%ebp)
80106a62:	eb 19                	jmp    80106a7d <uartinit+0xdc>
    uartputc(*p);
80106a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a67:	0f b6 00             	movzbl (%eax),%eax
80106a6a:	0f be c0             	movsbl %al,%eax
80106a6d:	83 ec 0c             	sub    $0xc,%esp
80106a70:	50                   	push   %eax
80106a71:	e8 16 00 00 00       	call   80106a8c <uartputc>
80106a76:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106a79:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a80:	0f b6 00             	movzbl (%eax),%eax
80106a83:	84 c0                	test   %al,%al
80106a85:	75 dd                	jne    80106a64 <uartinit+0xc3>
80106a87:	eb 01                	jmp    80106a8a <uartinit+0xe9>
    return;
80106a89:	90                   	nop
}
80106a8a:	c9                   	leave  
80106a8b:	c3                   	ret    

80106a8c <uartputc>:

void
uartputc(int c)
{
80106a8c:	f3 0f 1e fb          	endbr32 
80106a90:	55                   	push   %ebp
80106a91:	89 e5                	mov    %esp,%ebp
80106a93:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106a96:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106a9b:	85 c0                	test   %eax,%eax
80106a9d:	74 53                	je     80106af2 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106aa6:	eb 11                	jmp    80106ab9 <uartputc+0x2d>
    microdelay(10);
80106aa8:	83 ec 0c             	sub    $0xc,%esp
80106aab:	6a 0a                	push   $0xa
80106aad:	e8 84 c1 ff ff       	call   80102c36 <microdelay>
80106ab2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ab5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ab9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106abd:	7f 1a                	jg     80106ad9 <uartputc+0x4d>
80106abf:	83 ec 0c             	sub    $0xc,%esp
80106ac2:	68 fd 03 00 00       	push   $0x3fd
80106ac7:	e8 97 fe ff ff       	call   80106963 <inb>
80106acc:	83 c4 10             	add    $0x10,%esp
80106acf:	0f b6 c0             	movzbl %al,%eax
80106ad2:	83 e0 20             	and    $0x20,%eax
80106ad5:	85 c0                	test   %eax,%eax
80106ad7:	74 cf                	je     80106aa8 <uartputc+0x1c>
  outb(COM1+0, c);
80106ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80106adc:	0f b6 c0             	movzbl %al,%eax
80106adf:	83 ec 08             	sub    $0x8,%esp
80106ae2:	50                   	push   %eax
80106ae3:	68 f8 03 00 00       	push   $0x3f8
80106ae8:	e8 93 fe ff ff       	call   80106980 <outb>
80106aed:	83 c4 10             	add    $0x10,%esp
80106af0:	eb 01                	jmp    80106af3 <uartputc+0x67>
    return;
80106af2:	90                   	nop
}
80106af3:	c9                   	leave  
80106af4:	c3                   	ret    

80106af5 <uartgetc>:

static int
uartgetc(void)
{
80106af5:	f3 0f 1e fb          	endbr32 
80106af9:	55                   	push   %ebp
80106afa:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106afc:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106b01:	85 c0                	test   %eax,%eax
80106b03:	75 07                	jne    80106b0c <uartgetc+0x17>
    return -1;
80106b05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b0a:	eb 2e                	jmp    80106b3a <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106b0c:	68 fd 03 00 00       	push   $0x3fd
80106b11:	e8 4d fe ff ff       	call   80106963 <inb>
80106b16:	83 c4 04             	add    $0x4,%esp
80106b19:	0f b6 c0             	movzbl %al,%eax
80106b1c:	83 e0 01             	and    $0x1,%eax
80106b1f:	85 c0                	test   %eax,%eax
80106b21:	75 07                	jne    80106b2a <uartgetc+0x35>
    return -1;
80106b23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b28:	eb 10                	jmp    80106b3a <uartgetc+0x45>
  return inb(COM1+0);
80106b2a:	68 f8 03 00 00       	push   $0x3f8
80106b2f:	e8 2f fe ff ff       	call   80106963 <inb>
80106b34:	83 c4 04             	add    $0x4,%esp
80106b37:	0f b6 c0             	movzbl %al,%eax
}
80106b3a:	c9                   	leave  
80106b3b:	c3                   	ret    

80106b3c <uartintr>:

void
uartintr(void)
{
80106b3c:	f3 0f 1e fb          	endbr32 
80106b40:	55                   	push   %ebp
80106b41:	89 e5                	mov    %esp,%ebp
80106b43:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106b46:	83 ec 0c             	sub    $0xc,%esp
80106b49:	68 f5 6a 10 80       	push   $0x80106af5
80106b4e:	e8 ad 9c ff ff       	call   80100800 <consoleintr>
80106b53:	83 c4 10             	add    $0x10,%esp
}
80106b56:	90                   	nop
80106b57:	c9                   	leave  
80106b58:	c3                   	ret    

80106b59 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106b59:	6a 00                	push   $0x0
  pushl $0
80106b5b:	6a 00                	push   $0x0
  jmp alltraps
80106b5d:	e9 0c f9 ff ff       	jmp    8010646e <alltraps>

80106b62 <vector1>:
.globl vector1
vector1:
  pushl $0
80106b62:	6a 00                	push   $0x0
  pushl $1
80106b64:	6a 01                	push   $0x1
  jmp alltraps
80106b66:	e9 03 f9 ff ff       	jmp    8010646e <alltraps>

80106b6b <vector2>:
.globl vector2
vector2:
  pushl $0
80106b6b:	6a 00                	push   $0x0
  pushl $2
80106b6d:	6a 02                	push   $0x2
  jmp alltraps
80106b6f:	e9 fa f8 ff ff       	jmp    8010646e <alltraps>

80106b74 <vector3>:
.globl vector3
vector3:
  pushl $0
80106b74:	6a 00                	push   $0x0
  pushl $3
80106b76:	6a 03                	push   $0x3
  jmp alltraps
80106b78:	e9 f1 f8 ff ff       	jmp    8010646e <alltraps>

80106b7d <vector4>:
.globl vector4
vector4:
  pushl $0
80106b7d:	6a 00                	push   $0x0
  pushl $4
80106b7f:	6a 04                	push   $0x4
  jmp alltraps
80106b81:	e9 e8 f8 ff ff       	jmp    8010646e <alltraps>

80106b86 <vector5>:
.globl vector5
vector5:
  pushl $0
80106b86:	6a 00                	push   $0x0
  pushl $5
80106b88:	6a 05                	push   $0x5
  jmp alltraps
80106b8a:	e9 df f8 ff ff       	jmp    8010646e <alltraps>

80106b8f <vector6>:
.globl vector6
vector6:
  pushl $0
80106b8f:	6a 00                	push   $0x0
  pushl $6
80106b91:	6a 06                	push   $0x6
  jmp alltraps
80106b93:	e9 d6 f8 ff ff       	jmp    8010646e <alltraps>

80106b98 <vector7>:
.globl vector7
vector7:
  pushl $0
80106b98:	6a 00                	push   $0x0
  pushl $7
80106b9a:	6a 07                	push   $0x7
  jmp alltraps
80106b9c:	e9 cd f8 ff ff       	jmp    8010646e <alltraps>

80106ba1 <vector8>:
.globl vector8
vector8:
  pushl $8
80106ba1:	6a 08                	push   $0x8
  jmp alltraps
80106ba3:	e9 c6 f8 ff ff       	jmp    8010646e <alltraps>

80106ba8 <vector9>:
.globl vector9
vector9:
  pushl $0
80106ba8:	6a 00                	push   $0x0
  pushl $9
80106baa:	6a 09                	push   $0x9
  jmp alltraps
80106bac:	e9 bd f8 ff ff       	jmp    8010646e <alltraps>

80106bb1 <vector10>:
.globl vector10
vector10:
  pushl $10
80106bb1:	6a 0a                	push   $0xa
  jmp alltraps
80106bb3:	e9 b6 f8 ff ff       	jmp    8010646e <alltraps>

80106bb8 <vector11>:
.globl vector11
vector11:
  pushl $11
80106bb8:	6a 0b                	push   $0xb
  jmp alltraps
80106bba:	e9 af f8 ff ff       	jmp    8010646e <alltraps>

80106bbf <vector12>:
.globl vector12
vector12:
  pushl $12
80106bbf:	6a 0c                	push   $0xc
  jmp alltraps
80106bc1:	e9 a8 f8 ff ff       	jmp    8010646e <alltraps>

80106bc6 <vector13>:
.globl vector13
vector13:
  pushl $13
80106bc6:	6a 0d                	push   $0xd
  jmp alltraps
80106bc8:	e9 a1 f8 ff ff       	jmp    8010646e <alltraps>

80106bcd <vector14>:
.globl vector14
vector14:
  pushl $14
80106bcd:	6a 0e                	push   $0xe
  jmp alltraps
80106bcf:	e9 9a f8 ff ff       	jmp    8010646e <alltraps>

80106bd4 <vector15>:
.globl vector15
vector15:
  pushl $0
80106bd4:	6a 00                	push   $0x0
  pushl $15
80106bd6:	6a 0f                	push   $0xf
  jmp alltraps
80106bd8:	e9 91 f8 ff ff       	jmp    8010646e <alltraps>

80106bdd <vector16>:
.globl vector16
vector16:
  pushl $0
80106bdd:	6a 00                	push   $0x0
  pushl $16
80106bdf:	6a 10                	push   $0x10
  jmp alltraps
80106be1:	e9 88 f8 ff ff       	jmp    8010646e <alltraps>

80106be6 <vector17>:
.globl vector17
vector17:
  pushl $17
80106be6:	6a 11                	push   $0x11
  jmp alltraps
80106be8:	e9 81 f8 ff ff       	jmp    8010646e <alltraps>

80106bed <vector18>:
.globl vector18
vector18:
  pushl $0
80106bed:	6a 00                	push   $0x0
  pushl $18
80106bef:	6a 12                	push   $0x12
  jmp alltraps
80106bf1:	e9 78 f8 ff ff       	jmp    8010646e <alltraps>

80106bf6 <vector19>:
.globl vector19
vector19:
  pushl $0
80106bf6:	6a 00                	push   $0x0
  pushl $19
80106bf8:	6a 13                	push   $0x13
  jmp alltraps
80106bfa:	e9 6f f8 ff ff       	jmp    8010646e <alltraps>

80106bff <vector20>:
.globl vector20
vector20:
  pushl $0
80106bff:	6a 00                	push   $0x0
  pushl $20
80106c01:	6a 14                	push   $0x14
  jmp alltraps
80106c03:	e9 66 f8 ff ff       	jmp    8010646e <alltraps>

80106c08 <vector21>:
.globl vector21
vector21:
  pushl $0
80106c08:	6a 00                	push   $0x0
  pushl $21
80106c0a:	6a 15                	push   $0x15
  jmp alltraps
80106c0c:	e9 5d f8 ff ff       	jmp    8010646e <alltraps>

80106c11 <vector22>:
.globl vector22
vector22:
  pushl $0
80106c11:	6a 00                	push   $0x0
  pushl $22
80106c13:	6a 16                	push   $0x16
  jmp alltraps
80106c15:	e9 54 f8 ff ff       	jmp    8010646e <alltraps>

80106c1a <vector23>:
.globl vector23
vector23:
  pushl $0
80106c1a:	6a 00                	push   $0x0
  pushl $23
80106c1c:	6a 17                	push   $0x17
  jmp alltraps
80106c1e:	e9 4b f8 ff ff       	jmp    8010646e <alltraps>

80106c23 <vector24>:
.globl vector24
vector24:
  pushl $0
80106c23:	6a 00                	push   $0x0
  pushl $24
80106c25:	6a 18                	push   $0x18
  jmp alltraps
80106c27:	e9 42 f8 ff ff       	jmp    8010646e <alltraps>

80106c2c <vector25>:
.globl vector25
vector25:
  pushl $0
80106c2c:	6a 00                	push   $0x0
  pushl $25
80106c2e:	6a 19                	push   $0x19
  jmp alltraps
80106c30:	e9 39 f8 ff ff       	jmp    8010646e <alltraps>

80106c35 <vector26>:
.globl vector26
vector26:
  pushl $0
80106c35:	6a 00                	push   $0x0
  pushl $26
80106c37:	6a 1a                	push   $0x1a
  jmp alltraps
80106c39:	e9 30 f8 ff ff       	jmp    8010646e <alltraps>

80106c3e <vector27>:
.globl vector27
vector27:
  pushl $0
80106c3e:	6a 00                	push   $0x0
  pushl $27
80106c40:	6a 1b                	push   $0x1b
  jmp alltraps
80106c42:	e9 27 f8 ff ff       	jmp    8010646e <alltraps>

80106c47 <vector28>:
.globl vector28
vector28:
  pushl $0
80106c47:	6a 00                	push   $0x0
  pushl $28
80106c49:	6a 1c                	push   $0x1c
  jmp alltraps
80106c4b:	e9 1e f8 ff ff       	jmp    8010646e <alltraps>

80106c50 <vector29>:
.globl vector29
vector29:
  pushl $0
80106c50:	6a 00                	push   $0x0
  pushl $29
80106c52:	6a 1d                	push   $0x1d
  jmp alltraps
80106c54:	e9 15 f8 ff ff       	jmp    8010646e <alltraps>

80106c59 <vector30>:
.globl vector30
vector30:
  pushl $0
80106c59:	6a 00                	push   $0x0
  pushl $30
80106c5b:	6a 1e                	push   $0x1e
  jmp alltraps
80106c5d:	e9 0c f8 ff ff       	jmp    8010646e <alltraps>

80106c62 <vector31>:
.globl vector31
vector31:
  pushl $0
80106c62:	6a 00                	push   $0x0
  pushl $31
80106c64:	6a 1f                	push   $0x1f
  jmp alltraps
80106c66:	e9 03 f8 ff ff       	jmp    8010646e <alltraps>

80106c6b <vector32>:
.globl vector32
vector32:
  pushl $0
80106c6b:	6a 00                	push   $0x0
  pushl $32
80106c6d:	6a 20                	push   $0x20
  jmp alltraps
80106c6f:	e9 fa f7 ff ff       	jmp    8010646e <alltraps>

80106c74 <vector33>:
.globl vector33
vector33:
  pushl $0
80106c74:	6a 00                	push   $0x0
  pushl $33
80106c76:	6a 21                	push   $0x21
  jmp alltraps
80106c78:	e9 f1 f7 ff ff       	jmp    8010646e <alltraps>

80106c7d <vector34>:
.globl vector34
vector34:
  pushl $0
80106c7d:	6a 00                	push   $0x0
  pushl $34
80106c7f:	6a 22                	push   $0x22
  jmp alltraps
80106c81:	e9 e8 f7 ff ff       	jmp    8010646e <alltraps>

80106c86 <vector35>:
.globl vector35
vector35:
  pushl $0
80106c86:	6a 00                	push   $0x0
  pushl $35
80106c88:	6a 23                	push   $0x23
  jmp alltraps
80106c8a:	e9 df f7 ff ff       	jmp    8010646e <alltraps>

80106c8f <vector36>:
.globl vector36
vector36:
  pushl $0
80106c8f:	6a 00                	push   $0x0
  pushl $36
80106c91:	6a 24                	push   $0x24
  jmp alltraps
80106c93:	e9 d6 f7 ff ff       	jmp    8010646e <alltraps>

80106c98 <vector37>:
.globl vector37
vector37:
  pushl $0
80106c98:	6a 00                	push   $0x0
  pushl $37
80106c9a:	6a 25                	push   $0x25
  jmp alltraps
80106c9c:	e9 cd f7 ff ff       	jmp    8010646e <alltraps>

80106ca1 <vector38>:
.globl vector38
vector38:
  pushl $0
80106ca1:	6a 00                	push   $0x0
  pushl $38
80106ca3:	6a 26                	push   $0x26
  jmp alltraps
80106ca5:	e9 c4 f7 ff ff       	jmp    8010646e <alltraps>

80106caa <vector39>:
.globl vector39
vector39:
  pushl $0
80106caa:	6a 00                	push   $0x0
  pushl $39
80106cac:	6a 27                	push   $0x27
  jmp alltraps
80106cae:	e9 bb f7 ff ff       	jmp    8010646e <alltraps>

80106cb3 <vector40>:
.globl vector40
vector40:
  pushl $0
80106cb3:	6a 00                	push   $0x0
  pushl $40
80106cb5:	6a 28                	push   $0x28
  jmp alltraps
80106cb7:	e9 b2 f7 ff ff       	jmp    8010646e <alltraps>

80106cbc <vector41>:
.globl vector41
vector41:
  pushl $0
80106cbc:	6a 00                	push   $0x0
  pushl $41
80106cbe:	6a 29                	push   $0x29
  jmp alltraps
80106cc0:	e9 a9 f7 ff ff       	jmp    8010646e <alltraps>

80106cc5 <vector42>:
.globl vector42
vector42:
  pushl $0
80106cc5:	6a 00                	push   $0x0
  pushl $42
80106cc7:	6a 2a                	push   $0x2a
  jmp alltraps
80106cc9:	e9 a0 f7 ff ff       	jmp    8010646e <alltraps>

80106cce <vector43>:
.globl vector43
vector43:
  pushl $0
80106cce:	6a 00                	push   $0x0
  pushl $43
80106cd0:	6a 2b                	push   $0x2b
  jmp alltraps
80106cd2:	e9 97 f7 ff ff       	jmp    8010646e <alltraps>

80106cd7 <vector44>:
.globl vector44
vector44:
  pushl $0
80106cd7:	6a 00                	push   $0x0
  pushl $44
80106cd9:	6a 2c                	push   $0x2c
  jmp alltraps
80106cdb:	e9 8e f7 ff ff       	jmp    8010646e <alltraps>

80106ce0 <vector45>:
.globl vector45
vector45:
  pushl $0
80106ce0:	6a 00                	push   $0x0
  pushl $45
80106ce2:	6a 2d                	push   $0x2d
  jmp alltraps
80106ce4:	e9 85 f7 ff ff       	jmp    8010646e <alltraps>

80106ce9 <vector46>:
.globl vector46
vector46:
  pushl $0
80106ce9:	6a 00                	push   $0x0
  pushl $46
80106ceb:	6a 2e                	push   $0x2e
  jmp alltraps
80106ced:	e9 7c f7 ff ff       	jmp    8010646e <alltraps>

80106cf2 <vector47>:
.globl vector47
vector47:
  pushl $0
80106cf2:	6a 00                	push   $0x0
  pushl $47
80106cf4:	6a 2f                	push   $0x2f
  jmp alltraps
80106cf6:	e9 73 f7 ff ff       	jmp    8010646e <alltraps>

80106cfb <vector48>:
.globl vector48
vector48:
  pushl $0
80106cfb:	6a 00                	push   $0x0
  pushl $48
80106cfd:	6a 30                	push   $0x30
  jmp alltraps
80106cff:	e9 6a f7 ff ff       	jmp    8010646e <alltraps>

80106d04 <vector49>:
.globl vector49
vector49:
  pushl $0
80106d04:	6a 00                	push   $0x0
  pushl $49
80106d06:	6a 31                	push   $0x31
  jmp alltraps
80106d08:	e9 61 f7 ff ff       	jmp    8010646e <alltraps>

80106d0d <vector50>:
.globl vector50
vector50:
  pushl $0
80106d0d:	6a 00                	push   $0x0
  pushl $50
80106d0f:	6a 32                	push   $0x32
  jmp alltraps
80106d11:	e9 58 f7 ff ff       	jmp    8010646e <alltraps>

80106d16 <vector51>:
.globl vector51
vector51:
  pushl $0
80106d16:	6a 00                	push   $0x0
  pushl $51
80106d18:	6a 33                	push   $0x33
  jmp alltraps
80106d1a:	e9 4f f7 ff ff       	jmp    8010646e <alltraps>

80106d1f <vector52>:
.globl vector52
vector52:
  pushl $0
80106d1f:	6a 00                	push   $0x0
  pushl $52
80106d21:	6a 34                	push   $0x34
  jmp alltraps
80106d23:	e9 46 f7 ff ff       	jmp    8010646e <alltraps>

80106d28 <vector53>:
.globl vector53
vector53:
  pushl $0
80106d28:	6a 00                	push   $0x0
  pushl $53
80106d2a:	6a 35                	push   $0x35
  jmp alltraps
80106d2c:	e9 3d f7 ff ff       	jmp    8010646e <alltraps>

80106d31 <vector54>:
.globl vector54
vector54:
  pushl $0
80106d31:	6a 00                	push   $0x0
  pushl $54
80106d33:	6a 36                	push   $0x36
  jmp alltraps
80106d35:	e9 34 f7 ff ff       	jmp    8010646e <alltraps>

80106d3a <vector55>:
.globl vector55
vector55:
  pushl $0
80106d3a:	6a 00                	push   $0x0
  pushl $55
80106d3c:	6a 37                	push   $0x37
  jmp alltraps
80106d3e:	e9 2b f7 ff ff       	jmp    8010646e <alltraps>

80106d43 <vector56>:
.globl vector56
vector56:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $56
80106d45:	6a 38                	push   $0x38
  jmp alltraps
80106d47:	e9 22 f7 ff ff       	jmp    8010646e <alltraps>

80106d4c <vector57>:
.globl vector57
vector57:
  pushl $0
80106d4c:	6a 00                	push   $0x0
  pushl $57
80106d4e:	6a 39                	push   $0x39
  jmp alltraps
80106d50:	e9 19 f7 ff ff       	jmp    8010646e <alltraps>

80106d55 <vector58>:
.globl vector58
vector58:
  pushl $0
80106d55:	6a 00                	push   $0x0
  pushl $58
80106d57:	6a 3a                	push   $0x3a
  jmp alltraps
80106d59:	e9 10 f7 ff ff       	jmp    8010646e <alltraps>

80106d5e <vector59>:
.globl vector59
vector59:
  pushl $0
80106d5e:	6a 00                	push   $0x0
  pushl $59
80106d60:	6a 3b                	push   $0x3b
  jmp alltraps
80106d62:	e9 07 f7 ff ff       	jmp    8010646e <alltraps>

80106d67 <vector60>:
.globl vector60
vector60:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $60
80106d69:	6a 3c                	push   $0x3c
  jmp alltraps
80106d6b:	e9 fe f6 ff ff       	jmp    8010646e <alltraps>

80106d70 <vector61>:
.globl vector61
vector61:
  pushl $0
80106d70:	6a 00                	push   $0x0
  pushl $61
80106d72:	6a 3d                	push   $0x3d
  jmp alltraps
80106d74:	e9 f5 f6 ff ff       	jmp    8010646e <alltraps>

80106d79 <vector62>:
.globl vector62
vector62:
  pushl $0
80106d79:	6a 00                	push   $0x0
  pushl $62
80106d7b:	6a 3e                	push   $0x3e
  jmp alltraps
80106d7d:	e9 ec f6 ff ff       	jmp    8010646e <alltraps>

80106d82 <vector63>:
.globl vector63
vector63:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $63
80106d84:	6a 3f                	push   $0x3f
  jmp alltraps
80106d86:	e9 e3 f6 ff ff       	jmp    8010646e <alltraps>

80106d8b <vector64>:
.globl vector64
vector64:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $64
80106d8d:	6a 40                	push   $0x40
  jmp alltraps
80106d8f:	e9 da f6 ff ff       	jmp    8010646e <alltraps>

80106d94 <vector65>:
.globl vector65
vector65:
  pushl $0
80106d94:	6a 00                	push   $0x0
  pushl $65
80106d96:	6a 41                	push   $0x41
  jmp alltraps
80106d98:	e9 d1 f6 ff ff       	jmp    8010646e <alltraps>

80106d9d <vector66>:
.globl vector66
vector66:
  pushl $0
80106d9d:	6a 00                	push   $0x0
  pushl $66
80106d9f:	6a 42                	push   $0x42
  jmp alltraps
80106da1:	e9 c8 f6 ff ff       	jmp    8010646e <alltraps>

80106da6 <vector67>:
.globl vector67
vector67:
  pushl $0
80106da6:	6a 00                	push   $0x0
  pushl $67
80106da8:	6a 43                	push   $0x43
  jmp alltraps
80106daa:	e9 bf f6 ff ff       	jmp    8010646e <alltraps>

80106daf <vector68>:
.globl vector68
vector68:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $68
80106db1:	6a 44                	push   $0x44
  jmp alltraps
80106db3:	e9 b6 f6 ff ff       	jmp    8010646e <alltraps>

80106db8 <vector69>:
.globl vector69
vector69:
  pushl $0
80106db8:	6a 00                	push   $0x0
  pushl $69
80106dba:	6a 45                	push   $0x45
  jmp alltraps
80106dbc:	e9 ad f6 ff ff       	jmp    8010646e <alltraps>

80106dc1 <vector70>:
.globl vector70
vector70:
  pushl $0
80106dc1:	6a 00                	push   $0x0
  pushl $70
80106dc3:	6a 46                	push   $0x46
  jmp alltraps
80106dc5:	e9 a4 f6 ff ff       	jmp    8010646e <alltraps>

80106dca <vector71>:
.globl vector71
vector71:
  pushl $0
80106dca:	6a 00                	push   $0x0
  pushl $71
80106dcc:	6a 47                	push   $0x47
  jmp alltraps
80106dce:	e9 9b f6 ff ff       	jmp    8010646e <alltraps>

80106dd3 <vector72>:
.globl vector72
vector72:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $72
80106dd5:	6a 48                	push   $0x48
  jmp alltraps
80106dd7:	e9 92 f6 ff ff       	jmp    8010646e <alltraps>

80106ddc <vector73>:
.globl vector73
vector73:
  pushl $0
80106ddc:	6a 00                	push   $0x0
  pushl $73
80106dde:	6a 49                	push   $0x49
  jmp alltraps
80106de0:	e9 89 f6 ff ff       	jmp    8010646e <alltraps>

80106de5 <vector74>:
.globl vector74
vector74:
  pushl $0
80106de5:	6a 00                	push   $0x0
  pushl $74
80106de7:	6a 4a                	push   $0x4a
  jmp alltraps
80106de9:	e9 80 f6 ff ff       	jmp    8010646e <alltraps>

80106dee <vector75>:
.globl vector75
vector75:
  pushl $0
80106dee:	6a 00                	push   $0x0
  pushl $75
80106df0:	6a 4b                	push   $0x4b
  jmp alltraps
80106df2:	e9 77 f6 ff ff       	jmp    8010646e <alltraps>

80106df7 <vector76>:
.globl vector76
vector76:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $76
80106df9:	6a 4c                	push   $0x4c
  jmp alltraps
80106dfb:	e9 6e f6 ff ff       	jmp    8010646e <alltraps>

80106e00 <vector77>:
.globl vector77
vector77:
  pushl $0
80106e00:	6a 00                	push   $0x0
  pushl $77
80106e02:	6a 4d                	push   $0x4d
  jmp alltraps
80106e04:	e9 65 f6 ff ff       	jmp    8010646e <alltraps>

80106e09 <vector78>:
.globl vector78
vector78:
  pushl $0
80106e09:	6a 00                	push   $0x0
  pushl $78
80106e0b:	6a 4e                	push   $0x4e
  jmp alltraps
80106e0d:	e9 5c f6 ff ff       	jmp    8010646e <alltraps>

80106e12 <vector79>:
.globl vector79
vector79:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $79
80106e14:	6a 4f                	push   $0x4f
  jmp alltraps
80106e16:	e9 53 f6 ff ff       	jmp    8010646e <alltraps>

80106e1b <vector80>:
.globl vector80
vector80:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $80
80106e1d:	6a 50                	push   $0x50
  jmp alltraps
80106e1f:	e9 4a f6 ff ff       	jmp    8010646e <alltraps>

80106e24 <vector81>:
.globl vector81
vector81:
  pushl $0
80106e24:	6a 00                	push   $0x0
  pushl $81
80106e26:	6a 51                	push   $0x51
  jmp alltraps
80106e28:	e9 41 f6 ff ff       	jmp    8010646e <alltraps>

80106e2d <vector82>:
.globl vector82
vector82:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $82
80106e2f:	6a 52                	push   $0x52
  jmp alltraps
80106e31:	e9 38 f6 ff ff       	jmp    8010646e <alltraps>

80106e36 <vector83>:
.globl vector83
vector83:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $83
80106e38:	6a 53                	push   $0x53
  jmp alltraps
80106e3a:	e9 2f f6 ff ff       	jmp    8010646e <alltraps>

80106e3f <vector84>:
.globl vector84
vector84:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $84
80106e41:	6a 54                	push   $0x54
  jmp alltraps
80106e43:	e9 26 f6 ff ff       	jmp    8010646e <alltraps>

80106e48 <vector85>:
.globl vector85
vector85:
  pushl $0
80106e48:	6a 00                	push   $0x0
  pushl $85
80106e4a:	6a 55                	push   $0x55
  jmp alltraps
80106e4c:	e9 1d f6 ff ff       	jmp    8010646e <alltraps>

80106e51 <vector86>:
.globl vector86
vector86:
  pushl $0
80106e51:	6a 00                	push   $0x0
  pushl $86
80106e53:	6a 56                	push   $0x56
  jmp alltraps
80106e55:	e9 14 f6 ff ff       	jmp    8010646e <alltraps>

80106e5a <vector87>:
.globl vector87
vector87:
  pushl $0
80106e5a:	6a 00                	push   $0x0
  pushl $87
80106e5c:	6a 57                	push   $0x57
  jmp alltraps
80106e5e:	e9 0b f6 ff ff       	jmp    8010646e <alltraps>

80106e63 <vector88>:
.globl vector88
vector88:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $88
80106e65:	6a 58                	push   $0x58
  jmp alltraps
80106e67:	e9 02 f6 ff ff       	jmp    8010646e <alltraps>

80106e6c <vector89>:
.globl vector89
vector89:
  pushl $0
80106e6c:	6a 00                	push   $0x0
  pushl $89
80106e6e:	6a 59                	push   $0x59
  jmp alltraps
80106e70:	e9 f9 f5 ff ff       	jmp    8010646e <alltraps>

80106e75 <vector90>:
.globl vector90
vector90:
  pushl $0
80106e75:	6a 00                	push   $0x0
  pushl $90
80106e77:	6a 5a                	push   $0x5a
  jmp alltraps
80106e79:	e9 f0 f5 ff ff       	jmp    8010646e <alltraps>

80106e7e <vector91>:
.globl vector91
vector91:
  pushl $0
80106e7e:	6a 00                	push   $0x0
  pushl $91
80106e80:	6a 5b                	push   $0x5b
  jmp alltraps
80106e82:	e9 e7 f5 ff ff       	jmp    8010646e <alltraps>

80106e87 <vector92>:
.globl vector92
vector92:
  pushl $0
80106e87:	6a 00                	push   $0x0
  pushl $92
80106e89:	6a 5c                	push   $0x5c
  jmp alltraps
80106e8b:	e9 de f5 ff ff       	jmp    8010646e <alltraps>

80106e90 <vector93>:
.globl vector93
vector93:
  pushl $0
80106e90:	6a 00                	push   $0x0
  pushl $93
80106e92:	6a 5d                	push   $0x5d
  jmp alltraps
80106e94:	e9 d5 f5 ff ff       	jmp    8010646e <alltraps>

80106e99 <vector94>:
.globl vector94
vector94:
  pushl $0
80106e99:	6a 00                	push   $0x0
  pushl $94
80106e9b:	6a 5e                	push   $0x5e
  jmp alltraps
80106e9d:	e9 cc f5 ff ff       	jmp    8010646e <alltraps>

80106ea2 <vector95>:
.globl vector95
vector95:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $95
80106ea4:	6a 5f                	push   $0x5f
  jmp alltraps
80106ea6:	e9 c3 f5 ff ff       	jmp    8010646e <alltraps>

80106eab <vector96>:
.globl vector96
vector96:
  pushl $0
80106eab:	6a 00                	push   $0x0
  pushl $96
80106ead:	6a 60                	push   $0x60
  jmp alltraps
80106eaf:	e9 ba f5 ff ff       	jmp    8010646e <alltraps>

80106eb4 <vector97>:
.globl vector97
vector97:
  pushl $0
80106eb4:	6a 00                	push   $0x0
  pushl $97
80106eb6:	6a 61                	push   $0x61
  jmp alltraps
80106eb8:	e9 b1 f5 ff ff       	jmp    8010646e <alltraps>

80106ebd <vector98>:
.globl vector98
vector98:
  pushl $0
80106ebd:	6a 00                	push   $0x0
  pushl $98
80106ebf:	6a 62                	push   $0x62
  jmp alltraps
80106ec1:	e9 a8 f5 ff ff       	jmp    8010646e <alltraps>

80106ec6 <vector99>:
.globl vector99
vector99:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $99
80106ec8:	6a 63                	push   $0x63
  jmp alltraps
80106eca:	e9 9f f5 ff ff       	jmp    8010646e <alltraps>

80106ecf <vector100>:
.globl vector100
vector100:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $100
80106ed1:	6a 64                	push   $0x64
  jmp alltraps
80106ed3:	e9 96 f5 ff ff       	jmp    8010646e <alltraps>

80106ed8 <vector101>:
.globl vector101
vector101:
  pushl $0
80106ed8:	6a 00                	push   $0x0
  pushl $101
80106eda:	6a 65                	push   $0x65
  jmp alltraps
80106edc:	e9 8d f5 ff ff       	jmp    8010646e <alltraps>

80106ee1 <vector102>:
.globl vector102
vector102:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $102
80106ee3:	6a 66                	push   $0x66
  jmp alltraps
80106ee5:	e9 84 f5 ff ff       	jmp    8010646e <alltraps>

80106eea <vector103>:
.globl vector103
vector103:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $103
80106eec:	6a 67                	push   $0x67
  jmp alltraps
80106eee:	e9 7b f5 ff ff       	jmp    8010646e <alltraps>

80106ef3 <vector104>:
.globl vector104
vector104:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $104
80106ef5:	6a 68                	push   $0x68
  jmp alltraps
80106ef7:	e9 72 f5 ff ff       	jmp    8010646e <alltraps>

80106efc <vector105>:
.globl vector105
vector105:
  pushl $0
80106efc:	6a 00                	push   $0x0
  pushl $105
80106efe:	6a 69                	push   $0x69
  jmp alltraps
80106f00:	e9 69 f5 ff ff       	jmp    8010646e <alltraps>

80106f05 <vector106>:
.globl vector106
vector106:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $106
80106f07:	6a 6a                	push   $0x6a
  jmp alltraps
80106f09:	e9 60 f5 ff ff       	jmp    8010646e <alltraps>

80106f0e <vector107>:
.globl vector107
vector107:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $107
80106f10:	6a 6b                	push   $0x6b
  jmp alltraps
80106f12:	e9 57 f5 ff ff       	jmp    8010646e <alltraps>

80106f17 <vector108>:
.globl vector108
vector108:
  pushl $0
80106f17:	6a 00                	push   $0x0
  pushl $108
80106f19:	6a 6c                	push   $0x6c
  jmp alltraps
80106f1b:	e9 4e f5 ff ff       	jmp    8010646e <alltraps>

80106f20 <vector109>:
.globl vector109
vector109:
  pushl $0
80106f20:	6a 00                	push   $0x0
  pushl $109
80106f22:	6a 6d                	push   $0x6d
  jmp alltraps
80106f24:	e9 45 f5 ff ff       	jmp    8010646e <alltraps>

80106f29 <vector110>:
.globl vector110
vector110:
  pushl $0
80106f29:	6a 00                	push   $0x0
  pushl $110
80106f2b:	6a 6e                	push   $0x6e
  jmp alltraps
80106f2d:	e9 3c f5 ff ff       	jmp    8010646e <alltraps>

80106f32 <vector111>:
.globl vector111
vector111:
  pushl $0
80106f32:	6a 00                	push   $0x0
  pushl $111
80106f34:	6a 6f                	push   $0x6f
  jmp alltraps
80106f36:	e9 33 f5 ff ff       	jmp    8010646e <alltraps>

80106f3b <vector112>:
.globl vector112
vector112:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $112
80106f3d:	6a 70                	push   $0x70
  jmp alltraps
80106f3f:	e9 2a f5 ff ff       	jmp    8010646e <alltraps>

80106f44 <vector113>:
.globl vector113
vector113:
  pushl $0
80106f44:	6a 00                	push   $0x0
  pushl $113
80106f46:	6a 71                	push   $0x71
  jmp alltraps
80106f48:	e9 21 f5 ff ff       	jmp    8010646e <alltraps>

80106f4d <vector114>:
.globl vector114
vector114:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $114
80106f4f:	6a 72                	push   $0x72
  jmp alltraps
80106f51:	e9 18 f5 ff ff       	jmp    8010646e <alltraps>

80106f56 <vector115>:
.globl vector115
vector115:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $115
80106f58:	6a 73                	push   $0x73
  jmp alltraps
80106f5a:	e9 0f f5 ff ff       	jmp    8010646e <alltraps>

80106f5f <vector116>:
.globl vector116
vector116:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $116
80106f61:	6a 74                	push   $0x74
  jmp alltraps
80106f63:	e9 06 f5 ff ff       	jmp    8010646e <alltraps>

80106f68 <vector117>:
.globl vector117
vector117:
  pushl $0
80106f68:	6a 00                	push   $0x0
  pushl $117
80106f6a:	6a 75                	push   $0x75
  jmp alltraps
80106f6c:	e9 fd f4 ff ff       	jmp    8010646e <alltraps>

80106f71 <vector118>:
.globl vector118
vector118:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $118
80106f73:	6a 76                	push   $0x76
  jmp alltraps
80106f75:	e9 f4 f4 ff ff       	jmp    8010646e <alltraps>

80106f7a <vector119>:
.globl vector119
vector119:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $119
80106f7c:	6a 77                	push   $0x77
  jmp alltraps
80106f7e:	e9 eb f4 ff ff       	jmp    8010646e <alltraps>

80106f83 <vector120>:
.globl vector120
vector120:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $120
80106f85:	6a 78                	push   $0x78
  jmp alltraps
80106f87:	e9 e2 f4 ff ff       	jmp    8010646e <alltraps>

80106f8c <vector121>:
.globl vector121
vector121:
  pushl $0
80106f8c:	6a 00                	push   $0x0
  pushl $121
80106f8e:	6a 79                	push   $0x79
  jmp alltraps
80106f90:	e9 d9 f4 ff ff       	jmp    8010646e <alltraps>

80106f95 <vector122>:
.globl vector122
vector122:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $122
80106f97:	6a 7a                	push   $0x7a
  jmp alltraps
80106f99:	e9 d0 f4 ff ff       	jmp    8010646e <alltraps>

80106f9e <vector123>:
.globl vector123
vector123:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $123
80106fa0:	6a 7b                	push   $0x7b
  jmp alltraps
80106fa2:	e9 c7 f4 ff ff       	jmp    8010646e <alltraps>

80106fa7 <vector124>:
.globl vector124
vector124:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $124
80106fa9:	6a 7c                	push   $0x7c
  jmp alltraps
80106fab:	e9 be f4 ff ff       	jmp    8010646e <alltraps>

80106fb0 <vector125>:
.globl vector125
vector125:
  pushl $0
80106fb0:	6a 00                	push   $0x0
  pushl $125
80106fb2:	6a 7d                	push   $0x7d
  jmp alltraps
80106fb4:	e9 b5 f4 ff ff       	jmp    8010646e <alltraps>

80106fb9 <vector126>:
.globl vector126
vector126:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $126
80106fbb:	6a 7e                	push   $0x7e
  jmp alltraps
80106fbd:	e9 ac f4 ff ff       	jmp    8010646e <alltraps>

80106fc2 <vector127>:
.globl vector127
vector127:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $127
80106fc4:	6a 7f                	push   $0x7f
  jmp alltraps
80106fc6:	e9 a3 f4 ff ff       	jmp    8010646e <alltraps>

80106fcb <vector128>:
.globl vector128
vector128:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $128
80106fcd:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106fd2:	e9 97 f4 ff ff       	jmp    8010646e <alltraps>

80106fd7 <vector129>:
.globl vector129
vector129:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $129
80106fd9:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106fde:	e9 8b f4 ff ff       	jmp    8010646e <alltraps>

80106fe3 <vector130>:
.globl vector130
vector130:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $130
80106fe5:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106fea:	e9 7f f4 ff ff       	jmp    8010646e <alltraps>

80106fef <vector131>:
.globl vector131
vector131:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $131
80106ff1:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106ff6:	e9 73 f4 ff ff       	jmp    8010646e <alltraps>

80106ffb <vector132>:
.globl vector132
vector132:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $132
80106ffd:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107002:	e9 67 f4 ff ff       	jmp    8010646e <alltraps>

80107007 <vector133>:
.globl vector133
vector133:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $133
80107009:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010700e:	e9 5b f4 ff ff       	jmp    8010646e <alltraps>

80107013 <vector134>:
.globl vector134
vector134:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $134
80107015:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010701a:	e9 4f f4 ff ff       	jmp    8010646e <alltraps>

8010701f <vector135>:
.globl vector135
vector135:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $135
80107021:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107026:	e9 43 f4 ff ff       	jmp    8010646e <alltraps>

8010702b <vector136>:
.globl vector136
vector136:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $136
8010702d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107032:	e9 37 f4 ff ff       	jmp    8010646e <alltraps>

80107037 <vector137>:
.globl vector137
vector137:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $137
80107039:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010703e:	e9 2b f4 ff ff       	jmp    8010646e <alltraps>

80107043 <vector138>:
.globl vector138
vector138:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $138
80107045:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010704a:	e9 1f f4 ff ff       	jmp    8010646e <alltraps>

8010704f <vector139>:
.globl vector139
vector139:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $139
80107051:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107056:	e9 13 f4 ff ff       	jmp    8010646e <alltraps>

8010705b <vector140>:
.globl vector140
vector140:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $140
8010705d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107062:	e9 07 f4 ff ff       	jmp    8010646e <alltraps>

80107067 <vector141>:
.globl vector141
vector141:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $141
80107069:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010706e:	e9 fb f3 ff ff       	jmp    8010646e <alltraps>

80107073 <vector142>:
.globl vector142
vector142:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $142
80107075:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010707a:	e9 ef f3 ff ff       	jmp    8010646e <alltraps>

8010707f <vector143>:
.globl vector143
vector143:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $143
80107081:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107086:	e9 e3 f3 ff ff       	jmp    8010646e <alltraps>

8010708b <vector144>:
.globl vector144
vector144:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $144
8010708d:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107092:	e9 d7 f3 ff ff       	jmp    8010646e <alltraps>

80107097 <vector145>:
.globl vector145
vector145:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $145
80107099:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010709e:	e9 cb f3 ff ff       	jmp    8010646e <alltraps>

801070a3 <vector146>:
.globl vector146
vector146:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $146
801070a5:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801070aa:	e9 bf f3 ff ff       	jmp    8010646e <alltraps>

801070af <vector147>:
.globl vector147
vector147:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $147
801070b1:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801070b6:	e9 b3 f3 ff ff       	jmp    8010646e <alltraps>

801070bb <vector148>:
.globl vector148
vector148:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $148
801070bd:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801070c2:	e9 a7 f3 ff ff       	jmp    8010646e <alltraps>

801070c7 <vector149>:
.globl vector149
vector149:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $149
801070c9:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801070ce:	e9 9b f3 ff ff       	jmp    8010646e <alltraps>

801070d3 <vector150>:
.globl vector150
vector150:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $150
801070d5:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801070da:	e9 8f f3 ff ff       	jmp    8010646e <alltraps>

801070df <vector151>:
.globl vector151
vector151:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $151
801070e1:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801070e6:	e9 83 f3 ff ff       	jmp    8010646e <alltraps>

801070eb <vector152>:
.globl vector152
vector152:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $152
801070ed:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801070f2:	e9 77 f3 ff ff       	jmp    8010646e <alltraps>

801070f7 <vector153>:
.globl vector153
vector153:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $153
801070f9:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801070fe:	e9 6b f3 ff ff       	jmp    8010646e <alltraps>

80107103 <vector154>:
.globl vector154
vector154:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $154
80107105:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010710a:	e9 5f f3 ff ff       	jmp    8010646e <alltraps>

8010710f <vector155>:
.globl vector155
vector155:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $155
80107111:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107116:	e9 53 f3 ff ff       	jmp    8010646e <alltraps>

8010711b <vector156>:
.globl vector156
vector156:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $156
8010711d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107122:	e9 47 f3 ff ff       	jmp    8010646e <alltraps>

80107127 <vector157>:
.globl vector157
vector157:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $157
80107129:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010712e:	e9 3b f3 ff ff       	jmp    8010646e <alltraps>

80107133 <vector158>:
.globl vector158
vector158:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $158
80107135:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010713a:	e9 2f f3 ff ff       	jmp    8010646e <alltraps>

8010713f <vector159>:
.globl vector159
vector159:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $159
80107141:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107146:	e9 23 f3 ff ff       	jmp    8010646e <alltraps>

8010714b <vector160>:
.globl vector160
vector160:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $160
8010714d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107152:	e9 17 f3 ff ff       	jmp    8010646e <alltraps>

80107157 <vector161>:
.globl vector161
vector161:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $161
80107159:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010715e:	e9 0b f3 ff ff       	jmp    8010646e <alltraps>

80107163 <vector162>:
.globl vector162
vector162:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $162
80107165:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010716a:	e9 ff f2 ff ff       	jmp    8010646e <alltraps>

8010716f <vector163>:
.globl vector163
vector163:
  pushl $0
8010716f:	6a 00                	push   $0x0
  pushl $163
80107171:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107176:	e9 f3 f2 ff ff       	jmp    8010646e <alltraps>

8010717b <vector164>:
.globl vector164
vector164:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $164
8010717d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107182:	e9 e7 f2 ff ff       	jmp    8010646e <alltraps>

80107187 <vector165>:
.globl vector165
vector165:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $165
80107189:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010718e:	e9 db f2 ff ff       	jmp    8010646e <alltraps>

80107193 <vector166>:
.globl vector166
vector166:
  pushl $0
80107193:	6a 00                	push   $0x0
  pushl $166
80107195:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010719a:	e9 cf f2 ff ff       	jmp    8010646e <alltraps>

8010719f <vector167>:
.globl vector167
vector167:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $167
801071a1:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801071a6:	e9 c3 f2 ff ff       	jmp    8010646e <alltraps>

801071ab <vector168>:
.globl vector168
vector168:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $168
801071ad:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801071b2:	e9 b7 f2 ff ff       	jmp    8010646e <alltraps>

801071b7 <vector169>:
.globl vector169
vector169:
  pushl $0
801071b7:	6a 00                	push   $0x0
  pushl $169
801071b9:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801071be:	e9 ab f2 ff ff       	jmp    8010646e <alltraps>

801071c3 <vector170>:
.globl vector170
vector170:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $170
801071c5:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801071ca:	e9 9f f2 ff ff       	jmp    8010646e <alltraps>

801071cf <vector171>:
.globl vector171
vector171:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $171
801071d1:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801071d6:	e9 93 f2 ff ff       	jmp    8010646e <alltraps>

801071db <vector172>:
.globl vector172
vector172:
  pushl $0
801071db:	6a 00                	push   $0x0
  pushl $172
801071dd:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801071e2:	e9 87 f2 ff ff       	jmp    8010646e <alltraps>

801071e7 <vector173>:
.globl vector173
vector173:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $173
801071e9:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801071ee:	e9 7b f2 ff ff       	jmp    8010646e <alltraps>

801071f3 <vector174>:
.globl vector174
vector174:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $174
801071f5:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801071fa:	e9 6f f2 ff ff       	jmp    8010646e <alltraps>

801071ff <vector175>:
.globl vector175
vector175:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $175
80107201:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107206:	e9 63 f2 ff ff       	jmp    8010646e <alltraps>

8010720b <vector176>:
.globl vector176
vector176:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $176
8010720d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107212:	e9 57 f2 ff ff       	jmp    8010646e <alltraps>

80107217 <vector177>:
.globl vector177
vector177:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $177
80107219:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010721e:	e9 4b f2 ff ff       	jmp    8010646e <alltraps>

80107223 <vector178>:
.globl vector178
vector178:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $178
80107225:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010722a:	e9 3f f2 ff ff       	jmp    8010646e <alltraps>

8010722f <vector179>:
.globl vector179
vector179:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $179
80107231:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107236:	e9 33 f2 ff ff       	jmp    8010646e <alltraps>

8010723b <vector180>:
.globl vector180
vector180:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $180
8010723d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107242:	e9 27 f2 ff ff       	jmp    8010646e <alltraps>

80107247 <vector181>:
.globl vector181
vector181:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $181
80107249:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010724e:	e9 1b f2 ff ff       	jmp    8010646e <alltraps>

80107253 <vector182>:
.globl vector182
vector182:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $182
80107255:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010725a:	e9 0f f2 ff ff       	jmp    8010646e <alltraps>

8010725f <vector183>:
.globl vector183
vector183:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $183
80107261:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107266:	e9 03 f2 ff ff       	jmp    8010646e <alltraps>

8010726b <vector184>:
.globl vector184
vector184:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $184
8010726d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107272:	e9 f7 f1 ff ff       	jmp    8010646e <alltraps>

80107277 <vector185>:
.globl vector185
vector185:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $185
80107279:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010727e:	e9 eb f1 ff ff       	jmp    8010646e <alltraps>

80107283 <vector186>:
.globl vector186
vector186:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $186
80107285:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010728a:	e9 df f1 ff ff       	jmp    8010646e <alltraps>

8010728f <vector187>:
.globl vector187
vector187:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $187
80107291:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107296:	e9 d3 f1 ff ff       	jmp    8010646e <alltraps>

8010729b <vector188>:
.globl vector188
vector188:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $188
8010729d:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801072a2:	e9 c7 f1 ff ff       	jmp    8010646e <alltraps>

801072a7 <vector189>:
.globl vector189
vector189:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $189
801072a9:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801072ae:	e9 bb f1 ff ff       	jmp    8010646e <alltraps>

801072b3 <vector190>:
.globl vector190
vector190:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $190
801072b5:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801072ba:	e9 af f1 ff ff       	jmp    8010646e <alltraps>

801072bf <vector191>:
.globl vector191
vector191:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $191
801072c1:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801072c6:	e9 a3 f1 ff ff       	jmp    8010646e <alltraps>

801072cb <vector192>:
.globl vector192
vector192:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $192
801072cd:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801072d2:	e9 97 f1 ff ff       	jmp    8010646e <alltraps>

801072d7 <vector193>:
.globl vector193
vector193:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $193
801072d9:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801072de:	e9 8b f1 ff ff       	jmp    8010646e <alltraps>

801072e3 <vector194>:
.globl vector194
vector194:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $194
801072e5:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801072ea:	e9 7f f1 ff ff       	jmp    8010646e <alltraps>

801072ef <vector195>:
.globl vector195
vector195:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $195
801072f1:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801072f6:	e9 73 f1 ff ff       	jmp    8010646e <alltraps>

801072fb <vector196>:
.globl vector196
vector196:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $196
801072fd:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107302:	e9 67 f1 ff ff       	jmp    8010646e <alltraps>

80107307 <vector197>:
.globl vector197
vector197:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $197
80107309:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010730e:	e9 5b f1 ff ff       	jmp    8010646e <alltraps>

80107313 <vector198>:
.globl vector198
vector198:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $198
80107315:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010731a:	e9 4f f1 ff ff       	jmp    8010646e <alltraps>

8010731f <vector199>:
.globl vector199
vector199:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $199
80107321:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107326:	e9 43 f1 ff ff       	jmp    8010646e <alltraps>

8010732b <vector200>:
.globl vector200
vector200:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $200
8010732d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107332:	e9 37 f1 ff ff       	jmp    8010646e <alltraps>

80107337 <vector201>:
.globl vector201
vector201:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $201
80107339:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010733e:	e9 2b f1 ff ff       	jmp    8010646e <alltraps>

80107343 <vector202>:
.globl vector202
vector202:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $202
80107345:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010734a:	e9 1f f1 ff ff       	jmp    8010646e <alltraps>

8010734f <vector203>:
.globl vector203
vector203:
  pushl $0
8010734f:	6a 00                	push   $0x0
  pushl $203
80107351:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107356:	e9 13 f1 ff ff       	jmp    8010646e <alltraps>

8010735b <vector204>:
.globl vector204
vector204:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $204
8010735d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107362:	e9 07 f1 ff ff       	jmp    8010646e <alltraps>

80107367 <vector205>:
.globl vector205
vector205:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $205
80107369:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010736e:	e9 fb f0 ff ff       	jmp    8010646e <alltraps>

80107373 <vector206>:
.globl vector206
vector206:
  pushl $0
80107373:	6a 00                	push   $0x0
  pushl $206
80107375:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010737a:	e9 ef f0 ff ff       	jmp    8010646e <alltraps>

8010737f <vector207>:
.globl vector207
vector207:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $207
80107381:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107386:	e9 e3 f0 ff ff       	jmp    8010646e <alltraps>

8010738b <vector208>:
.globl vector208
vector208:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $208
8010738d:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107392:	e9 d7 f0 ff ff       	jmp    8010646e <alltraps>

80107397 <vector209>:
.globl vector209
vector209:
  pushl $0
80107397:	6a 00                	push   $0x0
  pushl $209
80107399:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010739e:	e9 cb f0 ff ff       	jmp    8010646e <alltraps>

801073a3 <vector210>:
.globl vector210
vector210:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $210
801073a5:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801073aa:	e9 bf f0 ff ff       	jmp    8010646e <alltraps>

801073af <vector211>:
.globl vector211
vector211:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $211
801073b1:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801073b6:	e9 b3 f0 ff ff       	jmp    8010646e <alltraps>

801073bb <vector212>:
.globl vector212
vector212:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $212
801073bd:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801073c2:	e9 a7 f0 ff ff       	jmp    8010646e <alltraps>

801073c7 <vector213>:
.globl vector213
vector213:
  pushl $0
801073c7:	6a 00                	push   $0x0
  pushl $213
801073c9:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801073ce:	e9 9b f0 ff ff       	jmp    8010646e <alltraps>

801073d3 <vector214>:
.globl vector214
vector214:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $214
801073d5:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801073da:	e9 8f f0 ff ff       	jmp    8010646e <alltraps>

801073df <vector215>:
.globl vector215
vector215:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $215
801073e1:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801073e6:	e9 83 f0 ff ff       	jmp    8010646e <alltraps>

801073eb <vector216>:
.globl vector216
vector216:
  pushl $0
801073eb:	6a 00                	push   $0x0
  pushl $216
801073ed:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801073f2:	e9 77 f0 ff ff       	jmp    8010646e <alltraps>

801073f7 <vector217>:
.globl vector217
vector217:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $217
801073f9:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801073fe:	e9 6b f0 ff ff       	jmp    8010646e <alltraps>

80107403 <vector218>:
.globl vector218
vector218:
  pushl $0
80107403:	6a 00                	push   $0x0
  pushl $218
80107405:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010740a:	e9 5f f0 ff ff       	jmp    8010646e <alltraps>

8010740f <vector219>:
.globl vector219
vector219:
  pushl $0
8010740f:	6a 00                	push   $0x0
  pushl $219
80107411:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107416:	e9 53 f0 ff ff       	jmp    8010646e <alltraps>

8010741b <vector220>:
.globl vector220
vector220:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $220
8010741d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107422:	e9 47 f0 ff ff       	jmp    8010646e <alltraps>

80107427 <vector221>:
.globl vector221
vector221:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $221
80107429:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010742e:	e9 3b f0 ff ff       	jmp    8010646e <alltraps>

80107433 <vector222>:
.globl vector222
vector222:
  pushl $0
80107433:	6a 00                	push   $0x0
  pushl $222
80107435:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010743a:	e9 2f f0 ff ff       	jmp    8010646e <alltraps>

8010743f <vector223>:
.globl vector223
vector223:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $223
80107441:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107446:	e9 23 f0 ff ff       	jmp    8010646e <alltraps>

8010744b <vector224>:
.globl vector224
vector224:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $224
8010744d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107452:	e9 17 f0 ff ff       	jmp    8010646e <alltraps>

80107457 <vector225>:
.globl vector225
vector225:
  pushl $0
80107457:	6a 00                	push   $0x0
  pushl $225
80107459:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010745e:	e9 0b f0 ff ff       	jmp    8010646e <alltraps>

80107463 <vector226>:
.globl vector226
vector226:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $226
80107465:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010746a:	e9 ff ef ff ff       	jmp    8010646e <alltraps>

8010746f <vector227>:
.globl vector227
vector227:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $227
80107471:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107476:	e9 f3 ef ff ff       	jmp    8010646e <alltraps>

8010747b <vector228>:
.globl vector228
vector228:
  pushl $0
8010747b:	6a 00                	push   $0x0
  pushl $228
8010747d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107482:	e9 e7 ef ff ff       	jmp    8010646e <alltraps>

80107487 <vector229>:
.globl vector229
vector229:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $229
80107489:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010748e:	e9 db ef ff ff       	jmp    8010646e <alltraps>

80107493 <vector230>:
.globl vector230
vector230:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $230
80107495:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010749a:	e9 cf ef ff ff       	jmp    8010646e <alltraps>

8010749f <vector231>:
.globl vector231
vector231:
  pushl $0
8010749f:	6a 00                	push   $0x0
  pushl $231
801074a1:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801074a6:	e9 c3 ef ff ff       	jmp    8010646e <alltraps>

801074ab <vector232>:
.globl vector232
vector232:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $232
801074ad:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801074b2:	e9 b7 ef ff ff       	jmp    8010646e <alltraps>

801074b7 <vector233>:
.globl vector233
vector233:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $233
801074b9:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801074be:	e9 ab ef ff ff       	jmp    8010646e <alltraps>

801074c3 <vector234>:
.globl vector234
vector234:
  pushl $0
801074c3:	6a 00                	push   $0x0
  pushl $234
801074c5:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801074ca:	e9 9f ef ff ff       	jmp    8010646e <alltraps>

801074cf <vector235>:
.globl vector235
vector235:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $235
801074d1:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801074d6:	e9 93 ef ff ff       	jmp    8010646e <alltraps>

801074db <vector236>:
.globl vector236
vector236:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $236
801074dd:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801074e2:	e9 87 ef ff ff       	jmp    8010646e <alltraps>

801074e7 <vector237>:
.globl vector237
vector237:
  pushl $0
801074e7:	6a 00                	push   $0x0
  pushl $237
801074e9:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801074ee:	e9 7b ef ff ff       	jmp    8010646e <alltraps>

801074f3 <vector238>:
.globl vector238
vector238:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $238
801074f5:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801074fa:	e9 6f ef ff ff       	jmp    8010646e <alltraps>

801074ff <vector239>:
.globl vector239
vector239:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $239
80107501:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107506:	e9 63 ef ff ff       	jmp    8010646e <alltraps>

8010750b <vector240>:
.globl vector240
vector240:
  pushl $0
8010750b:	6a 00                	push   $0x0
  pushl $240
8010750d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107512:	e9 57 ef ff ff       	jmp    8010646e <alltraps>

80107517 <vector241>:
.globl vector241
vector241:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $241
80107519:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010751e:	e9 4b ef ff ff       	jmp    8010646e <alltraps>

80107523 <vector242>:
.globl vector242
vector242:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $242
80107525:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010752a:	e9 3f ef ff ff       	jmp    8010646e <alltraps>

8010752f <vector243>:
.globl vector243
vector243:
  pushl $0
8010752f:	6a 00                	push   $0x0
  pushl $243
80107531:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107536:	e9 33 ef ff ff       	jmp    8010646e <alltraps>

8010753b <vector244>:
.globl vector244
vector244:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $244
8010753d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107542:	e9 27 ef ff ff       	jmp    8010646e <alltraps>

80107547 <vector245>:
.globl vector245
vector245:
  pushl $0
80107547:	6a 00                	push   $0x0
  pushl $245
80107549:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010754e:	e9 1b ef ff ff       	jmp    8010646e <alltraps>

80107553 <vector246>:
.globl vector246
vector246:
  pushl $0
80107553:	6a 00                	push   $0x0
  pushl $246
80107555:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010755a:	e9 0f ef ff ff       	jmp    8010646e <alltraps>

8010755f <vector247>:
.globl vector247
vector247:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $247
80107561:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107566:	e9 03 ef ff ff       	jmp    8010646e <alltraps>

8010756b <vector248>:
.globl vector248
vector248:
  pushl $0
8010756b:	6a 00                	push   $0x0
  pushl $248
8010756d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107572:	e9 f7 ee ff ff       	jmp    8010646e <alltraps>

80107577 <vector249>:
.globl vector249
vector249:
  pushl $0
80107577:	6a 00                	push   $0x0
  pushl $249
80107579:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010757e:	e9 eb ee ff ff       	jmp    8010646e <alltraps>

80107583 <vector250>:
.globl vector250
vector250:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $250
80107585:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010758a:	e9 df ee ff ff       	jmp    8010646e <alltraps>

8010758f <vector251>:
.globl vector251
vector251:
  pushl $0
8010758f:	6a 00                	push   $0x0
  pushl $251
80107591:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107596:	e9 d3 ee ff ff       	jmp    8010646e <alltraps>

8010759b <vector252>:
.globl vector252
vector252:
  pushl $0
8010759b:	6a 00                	push   $0x0
  pushl $252
8010759d:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801075a2:	e9 c7 ee ff ff       	jmp    8010646e <alltraps>

801075a7 <vector253>:
.globl vector253
vector253:
  pushl $0
801075a7:	6a 00                	push   $0x0
  pushl $253
801075a9:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801075ae:	e9 bb ee ff ff       	jmp    8010646e <alltraps>

801075b3 <vector254>:
.globl vector254
vector254:
  pushl $0
801075b3:	6a 00                	push   $0x0
  pushl $254
801075b5:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801075ba:	e9 af ee ff ff       	jmp    8010646e <alltraps>

801075bf <vector255>:
.globl vector255
vector255:
  pushl $0
801075bf:	6a 00                	push   $0x0
  pushl $255
801075c1:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801075c6:	e9 a3 ee ff ff       	jmp    8010646e <alltraps>

801075cb <lgdt>:
{
801075cb:	55                   	push   %ebp
801075cc:	89 e5                	mov    %esp,%ebp
801075ce:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801075d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801075d4:	83 e8 01             	sub    $0x1,%eax
801075d7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801075db:	8b 45 08             	mov    0x8(%ebp),%eax
801075de:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801075e2:	8b 45 08             	mov    0x8(%ebp),%eax
801075e5:	c1 e8 10             	shr    $0x10,%eax
801075e8:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
801075ec:	8d 45 fa             	lea    -0x6(%ebp),%eax
801075ef:	0f 01 10             	lgdtl  (%eax)
}
801075f2:	90                   	nop
801075f3:	c9                   	leave  
801075f4:	c3                   	ret    

801075f5 <ltr>:
{
801075f5:	55                   	push   %ebp
801075f6:	89 e5                	mov    %esp,%ebp
801075f8:	83 ec 04             	sub    $0x4,%esp
801075fb:	8b 45 08             	mov    0x8(%ebp),%eax
801075fe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107602:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107606:	0f 00 d8             	ltr    %ax
}
80107609:	90                   	nop
8010760a:	c9                   	leave  
8010760b:	c3                   	ret    

8010760c <lcr3>:

static inline void
lcr3(uint val)
{
8010760c:	55                   	push   %ebp
8010760d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010760f:	8b 45 08             	mov    0x8(%ebp),%eax
80107612:	0f 22 d8             	mov    %eax,%cr3
}
80107615:	90                   	nop
80107616:	5d                   	pop    %ebp
80107617:	c3                   	ret    

80107618 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107618:	f3 0f 1e fb          	endbr32 
8010761c:	55                   	push   %ebp
8010761d:	89 e5                	mov    %esp,%ebp
8010761f:	83 ec 18             	sub    $0x18,%esp

    // Map "logical" addresses to virtual addresses using identity map.
    // Cannot share a CODE descriptor for both kernel and user
    // because it would have to have DPL_USR, but the CPU forbids
    // an interrupt from CPL=0 to DPL=3.
    c = &cpus[cpuid()];
80107622:	e8 d9 c4 ff ff       	call   80103b00 <cpuid>
80107627:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010762d:	05 c0 81 19 80       	add    $0x801981c0,%eax
80107632:	89 45 f4             	mov    %eax,-0xc(%ebp)

    c->gdt[SEG_KCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, 0);
80107635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107638:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010763e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107641:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764a:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010764e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107651:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107655:	83 e2 f0             	and    $0xfffffff0,%edx
80107658:	83 ca 0a             	or     $0xa,%edx
8010765b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010765e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107661:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107665:	83 ca 10             	or     $0x10,%edx
80107668:	88 50 7d             	mov    %dl,0x7d(%eax)
8010766b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107672:	83 e2 9f             	and    $0xffffff9f,%edx
80107675:	88 50 7d             	mov    %dl,0x7d(%eax)
80107678:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010767f:	83 ca 80             	or     $0xffffff80,%edx
80107682:	88 50 7d             	mov    %dl,0x7d(%eax)
80107685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107688:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010768c:	83 ca 0f             	or     $0xf,%edx
8010768f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107695:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107699:	83 e2 ef             	and    $0xffffffef,%edx
8010769c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010769f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801076a6:	83 e2 df             	and    $0xffffffdf,%edx
801076a9:	88 50 7e             	mov    %dl,0x7e(%eax)
801076ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076af:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801076b3:	83 ca 40             	or     $0x40,%edx
801076b6:	88 50 7e             	mov    %dl,0x7e(%eax)
801076b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076bc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801076c0:	83 ca 80             	or     $0xffffff80,%edx
801076c3:	88 50 7e             	mov    %dl,0x7e(%eax)
801076c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
    c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801076cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801076d7:	ff ff 
801076d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076dc:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801076e3:	00 00 
801076e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e8:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801076ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076f9:	83 e2 f0             	and    $0xfffffff0,%edx
801076fc:	83 ca 02             	or     $0x2,%edx
801076ff:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107708:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010770f:	83 ca 10             	or     $0x10,%edx
80107712:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107722:	83 e2 9f             	and    $0xffffff9f,%edx
80107725:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010772b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107735:	83 ca 80             	or     $0xffffff80,%edx
80107738:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010773e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107741:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107748:	83 ca 0f             	or     $0xf,%edx
8010774b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107754:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010775b:	83 e2 ef             	and    $0xffffffef,%edx
8010775e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107767:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010776e:	83 e2 df             	and    $0xffffffdf,%edx
80107771:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107781:	83 ca 40             	or     $0x40,%edx
80107784:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010778a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107794:	83 ca 80             	or     $0xffffff80,%edx
80107797:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010779d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a0:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
    c->gdt[SEG_UCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, DPL_USER);
801077a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077aa:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801077b1:	ff ff 
801077b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b6:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801077bd:	00 00 
801077bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c2:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801077c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077cc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077d3:	83 e2 f0             	and    $0xfffffff0,%edx
801077d6:	83 ca 0a             	or     $0xa,%edx
801077d9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077e9:	83 ca 10             	or     $0x10,%edx
801077ec:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f5:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077fc:	83 ca 60             	or     $0x60,%edx
801077ff:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107808:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010780f:	83 ca 80             	or     $0xffffff80,%edx
80107812:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107822:	83 ca 0f             	or     $0xf,%edx
80107825:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010782b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107835:	83 e2 ef             	and    $0xffffffef,%edx
80107838:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010783e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107841:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107848:	83 e2 df             	and    $0xffffffdf,%edx
8010784b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107854:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010785b:	83 ca 40             	or     $0x40,%edx
8010785e:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107864:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107867:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010786e:	83 ca 80             	or     $0xffffff80,%edx
80107871:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787a:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
    c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107884:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010788b:	ff ff 
8010788d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107890:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107897:	00 00 
80107899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801078a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078ad:	83 e2 f0             	and    $0xfffffff0,%edx
801078b0:	83 ca 02             	or     $0x2,%edx
801078b3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078c3:	83 ca 10             	or     $0x10,%edx
801078c6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078d6:	83 ca 60             	or     $0x60,%edx
801078d9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801078e9:	83 ca 80             	or     $0xffffff80,%edx
801078ec:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078fc:	83 ca 0f             	or     $0xf,%edx
801078ff:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107908:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010790f:	83 e2 ef             	and    $0xffffffef,%edx
80107912:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107922:	83 e2 df             	and    $0xffffffdf,%edx
80107925:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010792b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107935:	83 ca 40             	or     $0x40,%edx
80107938:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010793e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107941:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107948:	83 ca 80             	or     $0xffffff80,%edx
8010794b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107954:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
    lgdt(c->gdt, sizeof(c->gdt));
8010795b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795e:	83 c0 70             	add    $0x70,%eax
80107961:	83 ec 08             	sub    $0x8,%esp
80107964:	6a 30                	push   $0x30
80107966:	50                   	push   %eax
80107967:	e8 5f fc ff ff       	call   801075cb <lgdt>
8010796c:	83 c4 10             	add    $0x10,%esp
}
8010796f:	90                   	nop
80107970:	c9                   	leave  
80107971:	c3                   	ret    

80107972 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t*
walkpgdir(pde_t* pgdir, const void* va, int alloc)
{
80107972:	f3 0f 1e fb          	endbr32 
80107976:	55                   	push   %ebp
80107977:	89 e5                	mov    %esp,%ebp
80107979:	83 ec 18             	sub    $0x18,%esp
    pde_t* pde;
    pte_t* pgtab;

    pde = &pgdir[PDX(va)];
8010797c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010797f:	c1 e8 16             	shr    $0x16,%eax
80107982:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107989:	8b 45 08             	mov    0x8(%ebp),%eax
8010798c:	01 d0                	add    %edx,%eax
8010798e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (*pde & PTE_P) {
80107991:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107994:	8b 00                	mov    (%eax),%eax
80107996:	83 e0 01             	and    $0x1,%eax
80107999:	85 c0                	test   %eax,%eax
8010799b:	74 14                	je     801079b1 <walkpgdir+0x3f>
        pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010799d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079a0:	8b 00                	mov    (%eax),%eax
801079a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079a7:	05 00 00 00 80       	add    $0x80000000,%eax
801079ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801079af:	eb 42                	jmp    801079f3 <walkpgdir+0x81>
    }
    else {
        if (!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801079b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801079b5:	74 0e                	je     801079c5 <walkpgdir+0x53>
801079b7:	e8 c8 ae ff ff       	call   80102884 <kalloc>
801079bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801079bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801079c3:	75 07                	jne    801079cc <walkpgdir+0x5a>
            return 0;
801079c5:	b8 00 00 00 00       	mov    $0x0,%eax
801079ca:	eb 3e                	jmp    80107a0a <walkpgdir+0x98>
        // Make sure all those PTE_P bits are zero.
        memset(pgtab, 0, PGSIZE);
801079cc:	83 ec 04             	sub    $0x4,%esp
801079cf:	68 00 10 00 00       	push   $0x1000
801079d4:	6a 00                	push   $0x0
801079d6:	ff 75 f4             	pushl  -0xc(%ebp)
801079d9:	e8 8d d5 ff ff       	call   80104f6b <memset>
801079de:	83 c4 10             	add    $0x10,%esp
        // The permissions here are overly generous, but they can
        // be further restricted by the permissions in the page table
        // entries, if necessary.
        *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801079e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e4:	05 00 00 00 80       	add    $0x80000000,%eax
801079e9:	83 c8 07             	or     $0x7,%eax
801079ec:	89 c2                	mov    %eax,%edx
801079ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079f1:	89 10                	mov    %edx,(%eax)
    }
    return &pgtab[PTX(va)];
801079f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801079f6:	c1 e8 0c             	shr    $0xc,%eax
801079f9:	25 ff 03 00 00       	and    $0x3ff,%eax
801079fe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a08:	01 d0                	add    %edx,%eax
}
80107a0a:	c9                   	leave  
80107a0b:	c3                   	ret    

80107a0c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t* pgdir, void* va, uint size, uint pa, int perm)
{
80107a0c:	f3 0f 1e fb          	endbr32 
80107a10:	55                   	push   %ebp
80107a11:	89 e5                	mov    %esp,%ebp
80107a13:	83 ec 18             	sub    $0x18,%esp
    char* a, * last;
    pte_t* pte;

    a = (char*)PGROUNDDOWN((uint)va);
80107a16:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107a21:	8b 55 0c             	mov    0xc(%ebp),%edx
80107a24:	8b 45 10             	mov    0x10(%ebp),%eax
80107a27:	01 d0                	add    %edx,%eax
80107a29:	83 e8 01             	sub    $0x1,%eax
80107a2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a31:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (;;) {
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80107a34:	83 ec 04             	sub    $0x4,%esp
80107a37:	6a 01                	push   $0x1
80107a39:	ff 75 f4             	pushl  -0xc(%ebp)
80107a3c:	ff 75 08             	pushl  0x8(%ebp)
80107a3f:	e8 2e ff ff ff       	call   80107972 <walkpgdir>
80107a44:	83 c4 10             	add    $0x10,%esp
80107a47:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a4a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a4e:	75 07                	jne    80107a57 <mappages+0x4b>
            return -1;
80107a50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a55:	eb 47                	jmp    80107a9e <mappages+0x92>
        if (*pte & PTE_P)
80107a57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a5a:	8b 00                	mov    (%eax),%eax
80107a5c:	83 e0 01             	and    $0x1,%eax
80107a5f:	85 c0                	test   %eax,%eax
80107a61:	74 0d                	je     80107a70 <mappages+0x64>
            panic("remap");
80107a63:	83 ec 0c             	sub    $0xc,%esp
80107a66:	68 b0 b0 10 80       	push   $0x8010b0b0
80107a6b:	e8 55 8b ff ff       	call   801005c5 <panic>
        *pte = pa | perm | PTE_P;
80107a70:	8b 45 18             	mov    0x18(%ebp),%eax
80107a73:	0b 45 14             	or     0x14(%ebp),%eax
80107a76:	83 c8 01             	or     $0x1,%eax
80107a79:	89 c2                	mov    %eax,%edx
80107a7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a7e:	89 10                	mov    %edx,(%eax)
        if (a == last)
80107a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a83:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107a86:	74 10                	je     80107a98 <mappages+0x8c>
            break;
        a += PGSIZE;
80107a88:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
        pa += PGSIZE;
80107a8f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80107a96:	eb 9c                	jmp    80107a34 <mappages+0x28>
            break;
80107a98:	90                   	nop
    }
    return 0;
80107a99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a9e:	c9                   	leave  
80107a9f:	c3                   	ret    

80107aa0 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107aa0:	f3 0f 1e fb          	endbr32 
80107aa4:	55                   	push   %ebp
80107aa5:	89 e5                	mov    %esp,%ebp
80107aa7:	53                   	push   %ebx
80107aa8:	83 ec 24             	sub    $0x24,%esp
    pde_t* pgdir;
    struct kmap* k;
    k = kmap;
80107aab:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
    struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr + gpu.vram_size, PTE_W };
80107ab2:	a1 8c 84 19 80       	mov    0x8019848c,%eax
80107ab7:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107abc:	29 c2                	sub    %eax,%edx
80107abe:	89 d0                	mov    %edx,%eax
80107ac0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ac3:	a1 84 84 19 80       	mov    0x80198484,%eax
80107ac8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107acb:	8b 15 84 84 19 80    	mov    0x80198484,%edx
80107ad1:	a1 8c 84 19 80       	mov    0x8019848c,%eax
80107ad6:	01 d0                	add    %edx,%eax
80107ad8:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107adb:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
    k[3] = vram;
80107ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae5:	83 c0 30             	add    $0x30,%eax
80107ae8:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107aeb:	89 10                	mov    %edx,(%eax)
80107aed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107af0:	89 50 04             	mov    %edx,0x4(%eax)
80107af3:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107af6:	89 50 08             	mov    %edx,0x8(%eax)
80107af9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107afc:	89 50 0c             	mov    %edx,0xc(%eax)
    if ((pgdir = (pde_t*)kalloc()) == 0) {
80107aff:	e8 80 ad ff ff       	call   80102884 <kalloc>
80107b04:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107b0b:	75 07                	jne    80107b14 <setupkvm+0x74>
        return 0;
80107b0d:	b8 00 00 00 00       	mov    $0x0,%eax
80107b12:	eb 78                	jmp    80107b8c <setupkvm+0xec>
    }
    memset(pgdir, 0, PGSIZE);
80107b14:	83 ec 04             	sub    $0x4,%esp
80107b17:	68 00 10 00 00       	push   $0x1000
80107b1c:	6a 00                	push   $0x0
80107b1e:	ff 75 f0             	pushl  -0x10(%ebp)
80107b21:	e8 45 d4 ff ff       	call   80104f6b <memset>
80107b26:	83 c4 10             	add    $0x10,%esp
    if (P2V(PHYSTOP) > (void*)DEVSPACE)
        panic("PHYSTOP too high");
    for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b29:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107b30:	eb 4e                	jmp    80107b80 <setupkvm+0xe0>
        if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b35:	8b 48 0c             	mov    0xc(%eax),%ecx
            (uint)k->phys_start, k->perm) < 0) {
80107b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3b:	8b 50 04             	mov    0x4(%eax),%edx
        if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b41:	8b 58 08             	mov    0x8(%eax),%ebx
80107b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b47:	8b 40 04             	mov    0x4(%eax),%eax
80107b4a:	29 c3                	sub    %eax,%ebx
80107b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4f:	8b 00                	mov    (%eax),%eax
80107b51:	83 ec 0c             	sub    $0xc,%esp
80107b54:	51                   	push   %ecx
80107b55:	52                   	push   %edx
80107b56:	53                   	push   %ebx
80107b57:	50                   	push   %eax
80107b58:	ff 75 f0             	pushl  -0x10(%ebp)
80107b5b:	e8 ac fe ff ff       	call   80107a0c <mappages>
80107b60:	83 c4 20             	add    $0x20,%esp
80107b63:	85 c0                	test   %eax,%eax
80107b65:	79 15                	jns    80107b7c <setupkvm+0xdc>
            freevm(pgdir);
80107b67:	83 ec 0c             	sub    $0xc,%esp
80107b6a:	ff 75 f0             	pushl  -0x10(%ebp)
80107b6d:	e8 11 05 00 00       	call   80108083 <freevm>
80107b72:	83 c4 10             	add    $0x10,%esp
            return 0;
80107b75:	b8 00 00 00 00       	mov    $0x0,%eax
80107b7a:	eb 10                	jmp    80107b8c <setupkvm+0xec>
    for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b7c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107b80:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107b87:	72 a9                	jb     80107b32 <setupkvm+0x92>
        }
    return pgdir;
80107b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107b8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107b8f:	c9                   	leave  
80107b90:	c3                   	ret    

80107b91 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107b91:	f3 0f 1e fb          	endbr32 
80107b95:	55                   	push   %ebp
80107b96:	89 e5                	mov    %esp,%ebp
80107b98:	83 ec 08             	sub    $0x8,%esp
    kpgdir = setupkvm();
80107b9b:	e8 00 ff ff ff       	call   80107aa0 <setupkvm>
80107ba0:	a3 84 81 19 80       	mov    %eax,0x80198184
    switchkvm();
80107ba5:	e8 03 00 00 00       	call   80107bad <switchkvm>
}
80107baa:	90                   	nop
80107bab:	c9                   	leave  
80107bac:	c3                   	ret    

80107bad <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107bad:	f3 0f 1e fb          	endbr32 
80107bb1:	55                   	push   %ebp
80107bb2:	89 e5                	mov    %esp,%ebp
    lcr3(V2P(kpgdir));   // switch to the kernel page table
80107bb4:	a1 84 81 19 80       	mov    0x80198184,%eax
80107bb9:	05 00 00 00 80       	add    $0x80000000,%eax
80107bbe:	50                   	push   %eax
80107bbf:	e8 48 fa ff ff       	call   8010760c <lcr3>
80107bc4:	83 c4 04             	add    $0x4,%esp
}
80107bc7:	90                   	nop
80107bc8:	c9                   	leave  
80107bc9:	c3                   	ret    

80107bca <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc* p)
{
80107bca:	f3 0f 1e fb          	endbr32 
80107bce:	55                   	push   %ebp
80107bcf:	89 e5                	mov    %esp,%ebp
80107bd1:	56                   	push   %esi
80107bd2:	53                   	push   %ebx
80107bd3:	83 ec 10             	sub    $0x10,%esp
    if (p == 0)
80107bd6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107bda:	75 0d                	jne    80107be9 <switchuvm+0x1f>
        panic("switchuvm: no process");
80107bdc:	83 ec 0c             	sub    $0xc,%esp
80107bdf:	68 b6 b0 10 80       	push   $0x8010b0b6
80107be4:	e8 dc 89 ff ff       	call   801005c5 <panic>
    if (p->kstack == 0)
80107be9:	8b 45 08             	mov    0x8(%ebp),%eax
80107bec:	8b 40 08             	mov    0x8(%eax),%eax
80107bef:	85 c0                	test   %eax,%eax
80107bf1:	75 0d                	jne    80107c00 <switchuvm+0x36>
        panic("switchuvm: no kstack");
80107bf3:	83 ec 0c             	sub    $0xc,%esp
80107bf6:	68 cc b0 10 80       	push   $0x8010b0cc
80107bfb:	e8 c5 89 ff ff       	call   801005c5 <panic>
    if (p->pgdir == 0)
80107c00:	8b 45 08             	mov    0x8(%ebp),%eax
80107c03:	8b 40 04             	mov    0x4(%eax),%eax
80107c06:	85 c0                	test   %eax,%eax
80107c08:	75 0d                	jne    80107c17 <switchuvm+0x4d>
        panic("switchuvm: no pgdir");
80107c0a:	83 ec 0c             	sub    $0xc,%esp
80107c0d:	68 e1 b0 10 80       	push   $0x8010b0e1
80107c12:	e8 ae 89 ff ff       	call   801005c5 <panic>

    pushcli();
80107c17:	e8 3c d2 ff ff       	call   80104e58 <pushcli>
    mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107c1c:	e8 fe be ff ff       	call   80103b1f <mycpu>
80107c21:	89 c3                	mov    %eax,%ebx
80107c23:	e8 f7 be ff ff       	call   80103b1f <mycpu>
80107c28:	83 c0 08             	add    $0x8,%eax
80107c2b:	89 c6                	mov    %eax,%esi
80107c2d:	e8 ed be ff ff       	call   80103b1f <mycpu>
80107c32:	83 c0 08             	add    $0x8,%eax
80107c35:	c1 e8 10             	shr    $0x10,%eax
80107c38:	88 45 f7             	mov    %al,-0x9(%ebp)
80107c3b:	e8 df be ff ff       	call   80103b1f <mycpu>
80107c40:	83 c0 08             	add    $0x8,%eax
80107c43:	c1 e8 18             	shr    $0x18,%eax
80107c46:	89 c2                	mov    %eax,%edx
80107c48:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107c4f:	67 00 
80107c51:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107c58:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107c5c:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107c62:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c69:	83 e0 f0             	and    $0xfffffff0,%eax
80107c6c:	83 c8 09             	or     $0x9,%eax
80107c6f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c75:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c7c:	83 c8 10             	or     $0x10,%eax
80107c7f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c85:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c8c:	83 e0 9f             	and    $0xffffff9f,%eax
80107c8f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c95:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c9c:	83 c8 80             	or     $0xffffff80,%eax
80107c9f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107ca5:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107cac:	83 e0 f0             	and    $0xfffffff0,%eax
80107caf:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107cb5:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107cbc:	83 e0 ef             	and    $0xffffffef,%eax
80107cbf:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107cc5:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ccc:	83 e0 df             	and    $0xffffffdf,%eax
80107ccf:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107cd5:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107cdc:	83 c8 40             	or     $0x40,%eax
80107cdf:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107ce5:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107cec:	83 e0 7f             	and    $0x7f,%eax
80107cef:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107cf5:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
        sizeof(mycpu()->ts) - 1, 0);
    mycpu()->gdt[SEG_TSS].s = 0;
80107cfb:	e8 1f be ff ff       	call   80103b1f <mycpu>
80107d00:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d07:	83 e2 ef             	and    $0xffffffef,%edx
80107d0a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
    mycpu()->ts.ss0 = SEG_KDATA << 3;
80107d10:	e8 0a be ff ff       	call   80103b1f <mycpu>
80107d15:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
    mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80107d1e:	8b 40 08             	mov    0x8(%eax),%eax
80107d21:	89 c3                	mov    %eax,%ebx
80107d23:	e8 f7 bd ff ff       	call   80103b1f <mycpu>
80107d28:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107d2e:	89 50 0c             	mov    %edx,0xc(%eax)
    // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
    // forbids I/O instructions (e.g., inb and outb) from user space
    mycpu()->ts.iomb = (ushort)0xFFFF;
80107d31:	e8 e9 bd ff ff       	call   80103b1f <mycpu>
80107d36:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
    ltr(SEG_TSS << 3);
80107d3c:	83 ec 0c             	sub    $0xc,%esp
80107d3f:	6a 28                	push   $0x28
80107d41:	e8 af f8 ff ff       	call   801075f5 <ltr>
80107d46:	83 c4 10             	add    $0x10,%esp
    lcr3(V2P(p->pgdir));  // switch to process's address space
80107d49:	8b 45 08             	mov    0x8(%ebp),%eax
80107d4c:	8b 40 04             	mov    0x4(%eax),%eax
80107d4f:	05 00 00 00 80       	add    $0x80000000,%eax
80107d54:	83 ec 0c             	sub    $0xc,%esp
80107d57:	50                   	push   %eax
80107d58:	e8 af f8 ff ff       	call   8010760c <lcr3>
80107d5d:	83 c4 10             	add    $0x10,%esp
    popcli();
80107d60:	e8 44 d1 ff ff       	call   80104ea9 <popcli>
}
80107d65:	90                   	nop
80107d66:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107d69:	5b                   	pop    %ebx
80107d6a:	5e                   	pop    %esi
80107d6b:	5d                   	pop    %ebp
80107d6c:	c3                   	ret    

80107d6d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t* pgdir, char* init, uint sz)
{
80107d6d:	f3 0f 1e fb          	endbr32 
80107d71:	55                   	push   %ebp
80107d72:	89 e5                	mov    %esp,%ebp
80107d74:	83 ec 18             	sub    $0x18,%esp
    char* mem;

    if (sz >= PGSIZE)
80107d77:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107d7e:	76 0d                	jbe    80107d8d <inituvm+0x20>
        panic("inituvm: more than a page");
80107d80:	83 ec 0c             	sub    $0xc,%esp
80107d83:	68 f5 b0 10 80       	push   $0x8010b0f5
80107d88:	e8 38 88 ff ff       	call   801005c5 <panic>
    mem = kalloc();
80107d8d:	e8 f2 aa ff ff       	call   80102884 <kalloc>
80107d92:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memset(mem, 0, PGSIZE);
80107d95:	83 ec 04             	sub    $0x4,%esp
80107d98:	68 00 10 00 00       	push   $0x1000
80107d9d:	6a 00                	push   $0x0
80107d9f:	ff 75 f4             	pushl  -0xc(%ebp)
80107da2:	e8 c4 d1 ff ff       	call   80104f6b <memset>
80107da7:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W | PTE_U);
80107daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dad:	05 00 00 00 80       	add    $0x80000000,%eax
80107db2:	83 ec 0c             	sub    $0xc,%esp
80107db5:	6a 06                	push   $0x6
80107db7:	50                   	push   %eax
80107db8:	68 00 10 00 00       	push   $0x1000
80107dbd:	6a 00                	push   $0x0
80107dbf:	ff 75 08             	pushl  0x8(%ebp)
80107dc2:	e8 45 fc ff ff       	call   80107a0c <mappages>
80107dc7:	83 c4 20             	add    $0x20,%esp
    memmove(mem, init, sz);
80107dca:	83 ec 04             	sub    $0x4,%esp
80107dcd:	ff 75 10             	pushl  0x10(%ebp)
80107dd0:	ff 75 0c             	pushl  0xc(%ebp)
80107dd3:	ff 75 f4             	pushl  -0xc(%ebp)
80107dd6:	e8 57 d2 ff ff       	call   80105032 <memmove>
80107ddb:	83 c4 10             	add    $0x10,%esp
}
80107dde:	90                   	nop
80107ddf:	c9                   	leave  
80107de0:	c3                   	ret    

80107de1 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t* pgdir, char* addr, struct inode* ip, uint offset, uint sz)
{
80107de1:	f3 0f 1e fb          	endbr32 
80107de5:	55                   	push   %ebp
80107de6:	89 e5                	mov    %esp,%ebp
80107de8:	83 ec 18             	sub    $0x18,%esp
    uint i, pa, n;
    pte_t* pte;

    if ((uint)addr % PGSIZE != 0)
80107deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dee:	25 ff 0f 00 00       	and    $0xfff,%eax
80107df3:	85 c0                	test   %eax,%eax
80107df5:	74 0d                	je     80107e04 <loaduvm+0x23>
        panic("loaduvm: addr must be page aligned");
80107df7:	83 ec 0c             	sub    $0xc,%esp
80107dfa:	68 10 b1 10 80       	push   $0x8010b110
80107dff:	e8 c1 87 ff ff       	call   801005c5 <panic>
    for (i = 0; i < sz; i += PGSIZE) {
80107e04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e0b:	e9 8f 00 00 00       	jmp    80107e9f <loaduvm+0xbe>
        if ((pte = walkpgdir(pgdir, addr + i, 0)) == 0)
80107e10:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e16:	01 d0                	add    %edx,%eax
80107e18:	83 ec 04             	sub    $0x4,%esp
80107e1b:	6a 00                	push   $0x0
80107e1d:	50                   	push   %eax
80107e1e:	ff 75 08             	pushl  0x8(%ebp)
80107e21:	e8 4c fb ff ff       	call   80107972 <walkpgdir>
80107e26:	83 c4 10             	add    $0x10,%esp
80107e29:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e2c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e30:	75 0d                	jne    80107e3f <loaduvm+0x5e>
            panic("loaduvm: address should exist");
80107e32:	83 ec 0c             	sub    $0xc,%esp
80107e35:	68 33 b1 10 80       	push   $0x8010b133
80107e3a:	e8 86 87 ff ff       	call   801005c5 <panic>
        pa = PTE_ADDR(*pte);
80107e3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e42:	8b 00                	mov    (%eax),%eax
80107e44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e49:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (sz - i < PGSIZE)
80107e4c:	8b 45 18             	mov    0x18(%ebp),%eax
80107e4f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107e52:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107e57:	77 0b                	ja     80107e64 <loaduvm+0x83>
            n = sz - i;
80107e59:	8b 45 18             	mov    0x18(%ebp),%eax
80107e5c:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107e5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e62:	eb 07                	jmp    80107e6b <loaduvm+0x8a>
        else
            n = PGSIZE;
80107e64:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
        if (readi(ip, P2V(pa), offset + i, n) != n)
80107e6b:	8b 55 14             	mov    0x14(%ebp),%edx
80107e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e71:	01 d0                	add    %edx,%eax
80107e73:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107e76:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107e7c:	ff 75 f0             	pushl  -0x10(%ebp)
80107e7f:	50                   	push   %eax
80107e80:	52                   	push   %edx
80107e81:	ff 75 10             	pushl  0x10(%ebp)
80107e84:	e8 ed a0 ff ff       	call   80101f76 <readi>
80107e89:	83 c4 10             	add    $0x10,%esp
80107e8c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107e8f:	74 07                	je     80107e98 <loaduvm+0xb7>
            return -1;
80107e91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e96:	eb 18                	jmp    80107eb0 <loaduvm+0xcf>
    for (i = 0; i < sz; i += PGSIZE) {
80107e98:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea2:	3b 45 18             	cmp    0x18(%ebp),%eax
80107ea5:	0f 82 65 ff ff ff    	jb     80107e10 <loaduvm+0x2f>
    }
    return 0;
80107eab:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107eb0:	c9                   	leave  
80107eb1:	c3                   	ret    

80107eb2 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t* pgdir, uint oldsz, uint newsz)
{
80107eb2:	f3 0f 1e fb          	endbr32 
80107eb6:	55                   	push   %ebp
80107eb7:	89 e5                	mov    %esp,%ebp
80107eb9:	83 ec 18             	sub    $0x18,%esp
    char* mem;
    uint a;

    if (newsz >= KERNBASE)
80107ebc:	8b 45 10             	mov    0x10(%ebp),%eax
80107ebf:	85 c0                	test   %eax,%eax
80107ec1:	79 0a                	jns    80107ecd <allocuvm+0x1b>
        return 0;
80107ec3:	b8 00 00 00 00       	mov    $0x0,%eax
80107ec8:	e9 ec 00 00 00       	jmp    80107fb9 <allocuvm+0x107>
    if (newsz < oldsz)
80107ecd:	8b 45 10             	mov    0x10(%ebp),%eax
80107ed0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ed3:	73 08                	jae    80107edd <allocuvm+0x2b>
        return oldsz;
80107ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ed8:	e9 dc 00 00 00       	jmp    80107fb9 <allocuvm+0x107>

    a = PGROUNDUP(oldsz);
80107edd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ee0:	05 ff 0f 00 00       	add    $0xfff,%eax
80107ee5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; a < newsz; a += PGSIZE) {
80107eed:	e9 b8 00 00 00       	jmp    80107faa <allocuvm+0xf8>
        mem = kalloc();
80107ef2:	e8 8d a9 ff ff       	call   80102884 <kalloc>
80107ef7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (mem == 0) {
80107efa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107efe:	75 2e                	jne    80107f2e <allocuvm+0x7c>
            cprintf("allocuvm out of memory\n");
80107f00:	83 ec 0c             	sub    $0xc,%esp
80107f03:	68 51 b1 10 80       	push   $0x8010b151
80107f08:	e8 ff 84 ff ff       	call   8010040c <cprintf>
80107f0d:	83 c4 10             	add    $0x10,%esp
            deallocuvm(pgdir, newsz, oldsz);
80107f10:	83 ec 04             	sub    $0x4,%esp
80107f13:	ff 75 0c             	pushl  0xc(%ebp)
80107f16:	ff 75 10             	pushl  0x10(%ebp)
80107f19:	ff 75 08             	pushl  0x8(%ebp)
80107f1c:	e8 9a 00 00 00       	call   80107fbb <deallocuvm>
80107f21:	83 c4 10             	add    $0x10,%esp
            return 0;
80107f24:	b8 00 00 00 00       	mov    $0x0,%eax
80107f29:	e9 8b 00 00 00       	jmp    80107fb9 <allocuvm+0x107>
        }
        memset(mem, 0, PGSIZE);
80107f2e:	83 ec 04             	sub    $0x4,%esp
80107f31:	68 00 10 00 00       	push   $0x1000
80107f36:	6a 00                	push   $0x0
80107f38:	ff 75 f0             	pushl  -0x10(%ebp)
80107f3b:	e8 2b d0 ff ff       	call   80104f6b <memset>
80107f40:	83 c4 10             	add    $0x10,%esp
        if (mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
80107f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f46:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4f:	83 ec 0c             	sub    $0xc,%esp
80107f52:	6a 06                	push   $0x6
80107f54:	52                   	push   %edx
80107f55:	68 00 10 00 00       	push   $0x1000
80107f5a:	50                   	push   %eax
80107f5b:	ff 75 08             	pushl  0x8(%ebp)
80107f5e:	e8 a9 fa ff ff       	call   80107a0c <mappages>
80107f63:	83 c4 20             	add    $0x20,%esp
80107f66:	85 c0                	test   %eax,%eax
80107f68:	79 39                	jns    80107fa3 <allocuvm+0xf1>
            cprintf("allocuvm out of memory (2)\n");
80107f6a:	83 ec 0c             	sub    $0xc,%esp
80107f6d:	68 69 b1 10 80       	push   $0x8010b169
80107f72:	e8 95 84 ff ff       	call   8010040c <cprintf>
80107f77:	83 c4 10             	add    $0x10,%esp
            deallocuvm(pgdir, newsz, oldsz);
80107f7a:	83 ec 04             	sub    $0x4,%esp
80107f7d:	ff 75 0c             	pushl  0xc(%ebp)
80107f80:	ff 75 10             	pushl  0x10(%ebp)
80107f83:	ff 75 08             	pushl  0x8(%ebp)
80107f86:	e8 30 00 00 00       	call   80107fbb <deallocuvm>
80107f8b:	83 c4 10             	add    $0x10,%esp
            kfree(mem);
80107f8e:	83 ec 0c             	sub    $0xc,%esp
80107f91:	ff 75 f0             	pushl  -0x10(%ebp)
80107f94:	e8 4d a8 ff ff       	call   801027e6 <kfree>
80107f99:	83 c4 10             	add    $0x10,%esp
            return 0;
80107f9c:	b8 00 00 00 00       	mov    $0x0,%eax
80107fa1:	eb 16                	jmp    80107fb9 <allocuvm+0x107>
    for (; a < newsz; a += PGSIZE) {
80107fa3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fad:	3b 45 10             	cmp    0x10(%ebp),%eax
80107fb0:	0f 82 3c ff ff ff    	jb     80107ef2 <allocuvm+0x40>
        }
    }
    return newsz;
80107fb6:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107fb9:	c9                   	leave  
80107fba:	c3                   	ret    

80107fbb <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t* pgdir, uint oldsz, uint newsz)
{
80107fbb:	f3 0f 1e fb          	endbr32 
80107fbf:	55                   	push   %ebp
80107fc0:	89 e5                	mov    %esp,%ebp
80107fc2:	83 ec 18             	sub    $0x18,%esp
    pte_t* pte;
    uint a, pa;

    if (newsz >= oldsz)
80107fc5:	8b 45 10             	mov    0x10(%ebp),%eax
80107fc8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107fcb:	72 08                	jb     80107fd5 <deallocuvm+0x1a>
        return oldsz;
80107fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fd0:	e9 ac 00 00 00       	jmp    80108081 <deallocuvm+0xc6>

    a = PGROUNDUP(newsz);
80107fd5:	8b 45 10             	mov    0x10(%ebp),%eax
80107fd8:	05 ff 0f 00 00       	add    $0xfff,%eax
80107fdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fe2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; a < oldsz; a += PGSIZE) {
80107fe5:	e9 88 00 00 00       	jmp    80108072 <deallocuvm+0xb7>
        pte = walkpgdir(pgdir, (char*)a, 0);
80107fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fed:	83 ec 04             	sub    $0x4,%esp
80107ff0:	6a 00                	push   $0x0
80107ff2:	50                   	push   %eax
80107ff3:	ff 75 08             	pushl  0x8(%ebp)
80107ff6:	e8 77 f9 ff ff       	call   80107972 <walkpgdir>
80107ffb:	83 c4 10             	add    $0x10,%esp
80107ffe:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (!pte)
80108001:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108005:	75 16                	jne    8010801d <deallocuvm+0x62>
            a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800a:	c1 e8 16             	shr    $0x16,%eax
8010800d:	83 c0 01             	add    $0x1,%eax
80108010:	c1 e0 16             	shl    $0x16,%eax
80108013:	2d 00 10 00 00       	sub    $0x1000,%eax
80108018:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010801b:	eb 4e                	jmp    8010806b <deallocuvm+0xb0>
        else if ((*pte & PTE_P) != 0) {
8010801d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108020:	8b 00                	mov    (%eax),%eax
80108022:	83 e0 01             	and    $0x1,%eax
80108025:	85 c0                	test   %eax,%eax
80108027:	74 42                	je     8010806b <deallocuvm+0xb0>
            pa = PTE_ADDR(*pte);
80108029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010802c:	8b 00                	mov    (%eax),%eax
8010802e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108033:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (pa == 0)
80108036:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010803a:	75 0d                	jne    80108049 <deallocuvm+0x8e>
                panic("kfree");
8010803c:	83 ec 0c             	sub    $0xc,%esp
8010803f:	68 85 b1 10 80       	push   $0x8010b185
80108044:	e8 7c 85 ff ff       	call   801005c5 <panic>
            char* v = P2V(pa);
80108049:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010804c:	05 00 00 00 80       	add    $0x80000000,%eax
80108051:	89 45 e8             	mov    %eax,-0x18(%ebp)
            kfree(v);
80108054:	83 ec 0c             	sub    $0xc,%esp
80108057:	ff 75 e8             	pushl  -0x18(%ebp)
8010805a:	e8 87 a7 ff ff       	call   801027e6 <kfree>
8010805f:	83 c4 10             	add    $0x10,%esp
            *pte = 0;
80108062:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108065:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (; a < oldsz; a += PGSIZE) {
8010806b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108075:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108078:	0f 82 6c ff ff ff    	jb     80107fea <deallocuvm+0x2f>
        }
    }
    return newsz;
8010807e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108081:	c9                   	leave  
80108082:	c3                   	ret    

80108083 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t* pgdir)
{
80108083:	f3 0f 1e fb          	endbr32 
80108087:	55                   	push   %ebp
80108088:	89 e5                	mov    %esp,%ebp
8010808a:	83 ec 18             	sub    $0x18,%esp
    uint i;

    if (pgdir == 0)
8010808d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108091:	75 0d                	jne    801080a0 <freevm+0x1d>
        panic("freevm: no pgdir");
80108093:	83 ec 0c             	sub    $0xc,%esp
80108096:	68 8b b1 10 80       	push   $0x8010b18b
8010809b:	e8 25 85 ff ff       	call   801005c5 <panic>
    deallocuvm(pgdir, KERNBASE, 0);
801080a0:	83 ec 04             	sub    $0x4,%esp
801080a3:	6a 00                	push   $0x0
801080a5:	68 00 00 00 80       	push   $0x80000000
801080aa:	ff 75 08             	pushl  0x8(%ebp)
801080ad:	e8 09 ff ff ff       	call   80107fbb <deallocuvm>
801080b2:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NPDENTRIES; i++) {
801080b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801080bc:	eb 48                	jmp    80108106 <freevm+0x83>
        if (pgdir[i] & PTE_P) {
801080be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080c8:	8b 45 08             	mov    0x8(%ebp),%eax
801080cb:	01 d0                	add    %edx,%eax
801080cd:	8b 00                	mov    (%eax),%eax
801080cf:	83 e0 01             	and    $0x1,%eax
801080d2:	85 c0                	test   %eax,%eax
801080d4:	74 2c                	je     80108102 <freevm+0x7f>
            char* v = P2V(PTE_ADDR(pgdir[i]));
801080d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080e0:	8b 45 08             	mov    0x8(%ebp),%eax
801080e3:	01 d0                	add    %edx,%eax
801080e5:	8b 00                	mov    (%eax),%eax
801080e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080ec:	05 00 00 00 80       	add    $0x80000000,%eax
801080f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
            kfree(v);
801080f4:	83 ec 0c             	sub    $0xc,%esp
801080f7:	ff 75 f0             	pushl  -0x10(%ebp)
801080fa:	e8 e7 a6 ff ff       	call   801027e6 <kfree>
801080ff:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NPDENTRIES; i++) {
80108102:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108106:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010810d:	76 af                	jbe    801080be <freevm+0x3b>
        }
    }
    kfree((char*)pgdir);
8010810f:	83 ec 0c             	sub    $0xc,%esp
80108112:	ff 75 08             	pushl  0x8(%ebp)
80108115:	e8 cc a6 ff ff       	call   801027e6 <kfree>
8010811a:	83 c4 10             	add    $0x10,%esp
}
8010811d:	90                   	nop
8010811e:	c9                   	leave  
8010811f:	c3                   	ret    

80108120 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t* pgdir, char* uva)
{
80108120:	f3 0f 1e fb          	endbr32 
80108124:	55                   	push   %ebp
80108125:	89 e5                	mov    %esp,%ebp
80108127:	83 ec 18             	sub    $0x18,%esp
    pte_t* pte;

    pte = walkpgdir(pgdir, uva, 0);
8010812a:	83 ec 04             	sub    $0x4,%esp
8010812d:	6a 00                	push   $0x0
8010812f:	ff 75 0c             	pushl  0xc(%ebp)
80108132:	ff 75 08             	pushl  0x8(%ebp)
80108135:	e8 38 f8 ff ff       	call   80107972 <walkpgdir>
8010813a:	83 c4 10             	add    $0x10,%esp
8010813d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (pte == 0)
80108140:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108144:	75 0d                	jne    80108153 <clearpteu+0x33>
        panic("clearpteu");
80108146:	83 ec 0c             	sub    $0xc,%esp
80108149:	68 9c b1 10 80       	push   $0x8010b19c
8010814e:	e8 72 84 ff ff       	call   801005c5 <panic>
    *pte &= ~PTE_U;
80108153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108156:	8b 00                	mov    (%eax),%eax
80108158:	83 e0 fb             	and    $0xfffffffb,%eax
8010815b:	89 c2                	mov    %eax,%edx
8010815d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108160:	89 10                	mov    %edx,(%eax)
}
80108162:	90                   	nop
80108163:	c9                   	leave  
80108164:	c3                   	ret    

80108165 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t* pgdir, uint sz)
{
80108165:	f3 0f 1e fb          	endbr32 
80108169:	55                   	push   %ebp
8010816a:	89 e5                	mov    %esp,%ebp
8010816c:	83 ec 28             	sub    $0x28,%esp
    pde_t* d;
    pte_t* pte;
    uint pa, i, flags;
    char* mem;

    if ((d = setupkvm()) == 0)
8010816f:	e8 2c f9 ff ff       	call   80107aa0 <setupkvm>
80108174:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108177:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010817b:	75 0a                	jne    80108187 <copyuvm+0x22>
        return 0;
8010817d:	b8 00 00 00 00       	mov    $0x0,%eax
80108182:	e9 cd 01 00 00       	jmp    80108354 <copyuvm+0x1ef>
    for (i = 0; i < sz; i += PGSIZE) {
80108187:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010818e:	e9 bf 00 00 00       	jmp    80108252 <copyuvm+0xed>
        if ((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
80108193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108196:	83 ec 04             	sub    $0x4,%esp
80108199:	6a 00                	push   $0x0
8010819b:	50                   	push   %eax
8010819c:	ff 75 08             	pushl  0x8(%ebp)
8010819f:	e8 ce f7 ff ff       	call   80107972 <walkpgdir>
801081a4:	83 c4 10             	add    $0x10,%esp
801081a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
801081aa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801081ae:	75 0d                	jne    801081bd <copyuvm+0x58>
            panic("copyuvm: pte should exist");
801081b0:	83 ec 0c             	sub    $0xc,%esp
801081b3:	68 a6 b1 10 80       	push   $0x8010b1a6
801081b8:	e8 08 84 ff ff       	call   801005c5 <panic>
        if (!(*pte & PTE_P))
801081bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081c0:	8b 00                	mov    (%eax),%eax
801081c2:	83 e0 01             	and    $0x1,%eax
801081c5:	85 c0                	test   %eax,%eax
801081c7:	75 0d                	jne    801081d6 <copyuvm+0x71>
            panic("copyuvm: page not present");
801081c9:	83 ec 0c             	sub    $0xc,%esp
801081cc:	68 c0 b1 10 80       	push   $0x8010b1c0
801081d1:	e8 ef 83 ff ff       	call   801005c5 <panic>
        pa = PTE_ADDR(*pte);
801081d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081d9:	8b 00                	mov    (%eax),%eax
801081db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        flags = PTE_FLAGS(*pte);
801081e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081e6:	8b 00                	mov    (%eax),%eax
801081e8:	25 ff 0f 00 00       	and    $0xfff,%eax
801081ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if ((mem = kalloc()) == 0)
801081f0:	e8 8f a6 ff ff       	call   80102884 <kalloc>
801081f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
801081f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801081fc:	0f 84 35 01 00 00    	je     80108337 <copyuvm+0x1d2>
            goto bad;
        memmove(mem, (char*)P2V(pa), PGSIZE);
80108202:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108205:	05 00 00 00 80       	add    $0x80000000,%eax
8010820a:	83 ec 04             	sub    $0x4,%esp
8010820d:	68 00 10 00 00       	push   $0x1000
80108212:	50                   	push   %eax
80108213:	ff 75 dc             	pushl  -0x24(%ebp)
80108216:	e8 17 ce ff ff       	call   80105032 <memmove>
8010821b:	83 c4 10             	add    $0x10,%esp
        if (mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010821e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108221:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108224:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010822a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822d:	83 ec 0c             	sub    $0xc,%esp
80108230:	52                   	push   %edx
80108231:	51                   	push   %ecx
80108232:	68 00 10 00 00       	push   $0x1000
80108237:	50                   	push   %eax
80108238:	ff 75 f0             	pushl  -0x10(%ebp)
8010823b:	e8 cc f7 ff ff       	call   80107a0c <mappages>
80108240:	83 c4 20             	add    $0x20,%esp
80108243:	85 c0                	test   %eax,%eax
80108245:	0f 88 ef 00 00 00    	js     8010833a <copyuvm+0x1d5>
    for (i = 0; i < sz; i += PGSIZE) {
8010824b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108255:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108258:	0f 82 35 ff ff ff    	jb     80108193 <copyuvm+0x2e>
            goto bad;
    }
    // Copy contents of stack to the new process
    uint stack_top = USERTOP - PGSIZE;
8010825e:	c7 45 ec 00 f0 ff 7f 	movl   $0x7ffff000,-0x14(%ebp)
    for (i = stack_top; i < USERTOP; i += PGSIZE) {
80108265:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108268:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010826b:	e9 b7 00 00 00       	jmp    80108327 <copyuvm+0x1c2>
        if ((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
80108270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108273:	83 ec 04             	sub    $0x4,%esp
80108276:	6a 00                	push   $0x0
80108278:	50                   	push   %eax
80108279:	ff 75 08             	pushl  0x8(%ebp)
8010827c:	e8 f1 f6 ff ff       	call   80107972 <walkpgdir>
80108281:	83 c4 10             	add    $0x10,%esp
80108284:	89 45 e8             	mov    %eax,-0x18(%ebp)
80108287:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010828b:	75 0d                	jne    8010829a <copyuvm+0x135>
            panic("copyuvm: pte should exist");
8010828d:	83 ec 0c             	sub    $0xc,%esp
80108290:	68 a6 b1 10 80       	push   $0x8010b1a6
80108295:	e8 2b 83 ff ff       	call   801005c5 <panic>
        if (!(*pte & PTE_P))
8010829a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010829d:	8b 00                	mov    (%eax),%eax
8010829f:	83 e0 01             	and    $0x1,%eax
801082a2:	85 c0                	test   %eax,%eax
801082a4:	75 0d                	jne    801082b3 <copyuvm+0x14e>
            panic("copyuvm: page not present");
801082a6:	83 ec 0c             	sub    $0xc,%esp
801082a9:	68 c0 b1 10 80       	push   $0x8010b1c0
801082ae:	e8 12 83 ff ff       	call   801005c5 <panic>
        pa = PTE_ADDR(*pte);
801082b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082b6:	8b 00                	mov    (%eax),%eax
801082b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        flags = PTE_FLAGS(*pte);
801082c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082c3:	8b 00                	mov    (%eax),%eax
801082c5:	25 ff 0f 00 00       	and    $0xfff,%eax
801082ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if ((mem = kalloc()) == 0)
801082cd:	e8 b2 a5 ff ff       	call   80102884 <kalloc>
801082d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
801082d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801082d9:	74 62                	je     8010833d <copyuvm+0x1d8>
            goto bad;
        memmove(mem, (char*)P2V(pa), PGSIZE);
801082db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801082de:	05 00 00 00 80       	add    $0x80000000,%eax
801082e3:	83 ec 04             	sub    $0x4,%esp
801082e6:	68 00 10 00 00       	push   $0x1000
801082eb:	50                   	push   %eax
801082ec:	ff 75 dc             	pushl  -0x24(%ebp)
801082ef:	e8 3e cd ff ff       	call   80105032 <memmove>
801082f4:	83 c4 10             	add    $0x10,%esp
        if (mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801082f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801082fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801082fd:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108306:	83 ec 0c             	sub    $0xc,%esp
80108309:	52                   	push   %edx
8010830a:	51                   	push   %ecx
8010830b:	68 00 10 00 00       	push   $0x1000
80108310:	50                   	push   %eax
80108311:	ff 75 f0             	pushl  -0x10(%ebp)
80108314:	e8 f3 f6 ff ff       	call   80107a0c <mappages>
80108319:	83 c4 20             	add    $0x20,%esp
8010831c:	85 c0                	test   %eax,%eax
8010831e:	78 20                	js     80108340 <copyuvm+0x1db>
    for (i = stack_top; i < USERTOP; i += PGSIZE) {
80108320:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832a:	85 c0                	test   %eax,%eax
8010832c:	0f 89 3e ff ff ff    	jns    80108270 <copyuvm+0x10b>
            goto bad;
    }
    return d;
80108332:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108335:	eb 1d                	jmp    80108354 <copyuvm+0x1ef>
            goto bad;
80108337:	90                   	nop
80108338:	eb 07                	jmp    80108341 <copyuvm+0x1dc>
            goto bad;
8010833a:	90                   	nop
8010833b:	eb 04                	jmp    80108341 <copyuvm+0x1dc>
            goto bad;
8010833d:	90                   	nop
8010833e:	eb 01                	jmp    80108341 <copyuvm+0x1dc>
            goto bad;
80108340:	90                   	nop

bad:
    freevm(d);
80108341:	83 ec 0c             	sub    $0xc,%esp
80108344:	ff 75 f0             	pushl  -0x10(%ebp)
80108347:	e8 37 fd ff ff       	call   80108083 <freevm>
8010834c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010834f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108354:	c9                   	leave  
80108355:	c3                   	ret    

80108356 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t* pgdir, char* uva)
{
80108356:	f3 0f 1e fb          	endbr32 
8010835a:	55                   	push   %ebp
8010835b:	89 e5                	mov    %esp,%ebp
8010835d:	83 ec 18             	sub    $0x18,%esp
    pte_t* pte;

    pte = walkpgdir(pgdir, uva, 0);
80108360:	83 ec 04             	sub    $0x4,%esp
80108363:	6a 00                	push   $0x0
80108365:	ff 75 0c             	pushl  0xc(%ebp)
80108368:	ff 75 08             	pushl  0x8(%ebp)
8010836b:	e8 02 f6 ff ff       	call   80107972 <walkpgdir>
80108370:	83 c4 10             	add    $0x10,%esp
80108373:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if ((*pte & PTE_P) == 0)
80108376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108379:	8b 00                	mov    (%eax),%eax
8010837b:	83 e0 01             	and    $0x1,%eax
8010837e:	85 c0                	test   %eax,%eax
80108380:	75 07                	jne    80108389 <uva2ka+0x33>
        return 0;
80108382:	b8 00 00 00 00       	mov    $0x0,%eax
80108387:	eb 22                	jmp    801083ab <uva2ka+0x55>
    if ((*pte & PTE_U) == 0)
80108389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838c:	8b 00                	mov    (%eax),%eax
8010838e:	83 e0 04             	and    $0x4,%eax
80108391:	85 c0                	test   %eax,%eax
80108393:	75 07                	jne    8010839c <uva2ka+0x46>
        return 0;
80108395:	b8 00 00 00 00       	mov    $0x0,%eax
8010839a:	eb 0f                	jmp    801083ab <uva2ka+0x55>
    return (char*)P2V(PTE_ADDR(*pte));
8010839c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839f:	8b 00                	mov    (%eax),%eax
801083a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083a6:	05 00 00 00 80       	add    $0x80000000,%eax
}
801083ab:	c9                   	leave  
801083ac:	c3                   	ret    

801083ad <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t* pgdir, uint va, void* p, uint len)
{
801083ad:	f3 0f 1e fb          	endbr32 
801083b1:	55                   	push   %ebp
801083b2:	89 e5                	mov    %esp,%ebp
801083b4:	83 ec 18             	sub    $0x18,%esp
    char* buf, * pa0;
    uint n, va0;

    buf = (char*)p;
801083b7:	8b 45 10             	mov    0x10(%ebp),%eax
801083ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (len > 0) {
801083bd:	eb 7f                	jmp    8010843e <copyout+0x91>
        va0 = (uint)PGROUNDDOWN(va);
801083bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
        pa0 = uva2ka(pgdir, (char*)va0);
801083ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083cd:	83 ec 08             	sub    $0x8,%esp
801083d0:	50                   	push   %eax
801083d1:	ff 75 08             	pushl  0x8(%ebp)
801083d4:	e8 7d ff ff ff       	call   80108356 <uva2ka>
801083d9:	83 c4 10             	add    $0x10,%esp
801083dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (pa0 == 0)
801083df:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801083e3:	75 07                	jne    801083ec <copyout+0x3f>
            return -1;
801083e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083ea:	eb 61                	jmp    8010844d <copyout+0xa0>
        n = PGSIZE - (va - va0);
801083ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ef:	2b 45 0c             	sub    0xc(%ebp),%eax
801083f2:	05 00 10 00 00       	add    $0x1000,%eax
801083f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (n > len)
801083fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083fd:	3b 45 14             	cmp    0x14(%ebp),%eax
80108400:	76 06                	jbe    80108408 <copyout+0x5b>
            n = len;
80108402:	8b 45 14             	mov    0x14(%ebp),%eax
80108405:	89 45 f0             	mov    %eax,-0x10(%ebp)
        memmove(pa0 + (va - va0), buf, n);
80108408:	8b 45 0c             	mov    0xc(%ebp),%eax
8010840b:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010840e:	89 c2                	mov    %eax,%edx
80108410:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108413:	01 d0                	add    %edx,%eax
80108415:	83 ec 04             	sub    $0x4,%esp
80108418:	ff 75 f0             	pushl  -0x10(%ebp)
8010841b:	ff 75 f4             	pushl  -0xc(%ebp)
8010841e:	50                   	push   %eax
8010841f:	e8 0e cc ff ff       	call   80105032 <memmove>
80108424:	83 c4 10             	add    $0x10,%esp
        len -= n;
80108427:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010842a:	29 45 14             	sub    %eax,0x14(%ebp)
        buf += n;
8010842d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108430:	01 45 f4             	add    %eax,-0xc(%ebp)
        va = va0 + PGSIZE;
80108433:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108436:	05 00 10 00 00       	add    $0x1000,%eax
8010843b:	89 45 0c             	mov    %eax,0xc(%ebp)
    while (len > 0) {
8010843e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108442:	0f 85 77 ff ff ff    	jne    801083bf <copyout+0x12>
    }
    return 0;
80108448:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010844d:	c9                   	leave  
8010844e:	c3                   	ret    

8010844f <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
8010844f:	f3 0f 1e fb          	endbr32 
80108453:	55                   	push   %ebp
80108454:	89 e5                	mov    %esp,%ebp
80108456:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108459:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108460:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108463:	8b 40 08             	mov    0x8(%eax),%eax
80108466:	05 00 00 00 80       	add    $0x80000000,%eax
8010846b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
8010846e:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108478:	8b 40 24             	mov    0x24(%eax),%eax
8010847b:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80108480:	c7 05 80 84 19 80 00 	movl   $0x0,0x80198480
80108487:	00 00 00 

  while(i<madt->len){
8010848a:	90                   	nop
8010848b:	e9 be 00 00 00       	jmp    8010854e <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80108490:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108493:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108496:	01 d0                	add    %edx,%eax
80108498:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010849b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010849e:	0f b6 00             	movzbl (%eax),%eax
801084a1:	0f b6 c0             	movzbl %al,%eax
801084a4:	83 f8 05             	cmp    $0x5,%eax
801084a7:	0f 87 a1 00 00 00    	ja     8010854e <mpinit_uefi+0xff>
801084ad:	8b 04 85 dc b1 10 80 	mov    -0x7fef4e24(,%eax,4),%eax
801084b4:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801084b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801084bd:	a1 80 84 19 80       	mov    0x80198480,%eax
801084c2:	83 f8 03             	cmp    $0x3,%eax
801084c5:	7f 28                	jg     801084ef <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801084c7:	8b 15 80 84 19 80    	mov    0x80198480,%edx
801084cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084d0:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801084d4:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
801084da:	81 c2 c0 81 19 80    	add    $0x801981c0,%edx
801084e0:	88 02                	mov    %al,(%edx)
          ncpu++;
801084e2:	a1 80 84 19 80       	mov    0x80198480,%eax
801084e7:	83 c0 01             	add    $0x1,%eax
801084ea:	a3 80 84 19 80       	mov    %eax,0x80198480
        }
        i += lapic_entry->record_len;
801084ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084f2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084f6:	0f b6 c0             	movzbl %al,%eax
801084f9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801084fc:	eb 50                	jmp    8010854e <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801084fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108501:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80108504:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108507:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010850b:	a2 a0 81 19 80       	mov    %al,0x801981a0
        i += ioapic->record_len;
80108510:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108513:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108517:	0f b6 c0             	movzbl %al,%eax
8010851a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010851d:	eb 2f                	jmp    8010854e <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
8010851f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108522:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80108525:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108528:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010852c:	0f b6 c0             	movzbl %al,%eax
8010852f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108532:	eb 1a                	jmp    8010854e <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80108534:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108537:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
8010853a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010853d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108541:	0f b6 c0             	movzbl %al,%eax
80108544:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108547:	eb 05                	jmp    8010854e <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
80108549:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010854d:	90                   	nop
  while(i<madt->len){
8010854e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108551:	8b 40 04             	mov    0x4(%eax),%eax
80108554:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108557:	0f 82 33 ff ff ff    	jb     80108490 <mpinit_uefi+0x41>
    }
  }

}
8010855d:	90                   	nop
8010855e:	90                   	nop
8010855f:	c9                   	leave  
80108560:	c3                   	ret    

80108561 <inb>:
{
80108561:	55                   	push   %ebp
80108562:	89 e5                	mov    %esp,%ebp
80108564:	83 ec 14             	sub    $0x14,%esp
80108567:	8b 45 08             	mov    0x8(%ebp),%eax
8010856a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010856e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108572:	89 c2                	mov    %eax,%edx
80108574:	ec                   	in     (%dx),%al
80108575:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108578:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010857c:	c9                   	leave  
8010857d:	c3                   	ret    

8010857e <outb>:
{
8010857e:	55                   	push   %ebp
8010857f:	89 e5                	mov    %esp,%ebp
80108581:	83 ec 08             	sub    $0x8,%esp
80108584:	8b 45 08             	mov    0x8(%ebp),%eax
80108587:	8b 55 0c             	mov    0xc(%ebp),%edx
8010858a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010858e:	89 d0                	mov    %edx,%eax
80108590:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108593:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108597:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010859b:	ee                   	out    %al,(%dx)
}
8010859c:	90                   	nop
8010859d:	c9                   	leave  
8010859e:	c3                   	ret    

8010859f <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
8010859f:	f3 0f 1e fb          	endbr32 
801085a3:	55                   	push   %ebp
801085a4:	89 e5                	mov    %esp,%ebp
801085a6:	83 ec 28             	sub    $0x28,%esp
801085a9:	8b 45 08             	mov    0x8(%ebp),%eax
801085ac:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801085af:	6a 00                	push   $0x0
801085b1:	68 fa 03 00 00       	push   $0x3fa
801085b6:	e8 c3 ff ff ff       	call   8010857e <outb>
801085bb:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801085be:	68 80 00 00 00       	push   $0x80
801085c3:	68 fb 03 00 00       	push   $0x3fb
801085c8:	e8 b1 ff ff ff       	call   8010857e <outb>
801085cd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801085d0:	6a 0c                	push   $0xc
801085d2:	68 f8 03 00 00       	push   $0x3f8
801085d7:	e8 a2 ff ff ff       	call   8010857e <outb>
801085dc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801085df:	6a 00                	push   $0x0
801085e1:	68 f9 03 00 00       	push   $0x3f9
801085e6:	e8 93 ff ff ff       	call   8010857e <outb>
801085eb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801085ee:	6a 03                	push   $0x3
801085f0:	68 fb 03 00 00       	push   $0x3fb
801085f5:	e8 84 ff ff ff       	call   8010857e <outb>
801085fa:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801085fd:	6a 00                	push   $0x0
801085ff:	68 fc 03 00 00       	push   $0x3fc
80108604:	e8 75 ff ff ff       	call   8010857e <outb>
80108609:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010860c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108613:	eb 11                	jmp    80108626 <uart_debug+0x87>
80108615:	83 ec 0c             	sub    $0xc,%esp
80108618:	6a 0a                	push   $0xa
8010861a:	e8 17 a6 ff ff       	call   80102c36 <microdelay>
8010861f:	83 c4 10             	add    $0x10,%esp
80108622:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108626:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010862a:	7f 1a                	jg     80108646 <uart_debug+0xa7>
8010862c:	83 ec 0c             	sub    $0xc,%esp
8010862f:	68 fd 03 00 00       	push   $0x3fd
80108634:	e8 28 ff ff ff       	call   80108561 <inb>
80108639:	83 c4 10             	add    $0x10,%esp
8010863c:	0f b6 c0             	movzbl %al,%eax
8010863f:	83 e0 20             	and    $0x20,%eax
80108642:	85 c0                	test   %eax,%eax
80108644:	74 cf                	je     80108615 <uart_debug+0x76>
  outb(COM1+0, p);
80108646:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010864a:	0f b6 c0             	movzbl %al,%eax
8010864d:	83 ec 08             	sub    $0x8,%esp
80108650:	50                   	push   %eax
80108651:	68 f8 03 00 00       	push   $0x3f8
80108656:	e8 23 ff ff ff       	call   8010857e <outb>
8010865b:	83 c4 10             	add    $0x10,%esp
}
8010865e:	90                   	nop
8010865f:	c9                   	leave  
80108660:	c3                   	ret    

80108661 <uart_debugs>:

void uart_debugs(char *p){
80108661:	f3 0f 1e fb          	endbr32 
80108665:	55                   	push   %ebp
80108666:	89 e5                	mov    %esp,%ebp
80108668:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010866b:	eb 1b                	jmp    80108688 <uart_debugs+0x27>
    uart_debug(*p++);
8010866d:	8b 45 08             	mov    0x8(%ebp),%eax
80108670:	8d 50 01             	lea    0x1(%eax),%edx
80108673:	89 55 08             	mov    %edx,0x8(%ebp)
80108676:	0f b6 00             	movzbl (%eax),%eax
80108679:	0f be c0             	movsbl %al,%eax
8010867c:	83 ec 0c             	sub    $0xc,%esp
8010867f:	50                   	push   %eax
80108680:	e8 1a ff ff ff       	call   8010859f <uart_debug>
80108685:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108688:	8b 45 08             	mov    0x8(%ebp),%eax
8010868b:	0f b6 00             	movzbl (%eax),%eax
8010868e:	84 c0                	test   %al,%al
80108690:	75 db                	jne    8010866d <uart_debugs+0xc>
  }
}
80108692:	90                   	nop
80108693:	90                   	nop
80108694:	c9                   	leave  
80108695:	c3                   	ret    

80108696 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108696:	f3 0f 1e fb          	endbr32 
8010869a:	55                   	push   %ebp
8010869b:	89 e5                	mov    %esp,%ebp
8010869d:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801086a0:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801086a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086aa:	8b 50 14             	mov    0x14(%eax),%edx
801086ad:	8b 40 10             	mov    0x10(%eax),%eax
801086b0:	a3 84 84 19 80       	mov    %eax,0x80198484
  gpu.vram_size = boot_param->graphic_config.frame_size;
801086b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086b8:	8b 50 1c             	mov    0x1c(%eax),%edx
801086bb:	8b 40 18             	mov    0x18(%eax),%eax
801086be:	a3 8c 84 19 80       	mov    %eax,0x8019848c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801086c3:	a1 8c 84 19 80       	mov    0x8019848c,%eax
801086c8:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
801086cd:	29 c2                	sub    %eax,%edx
801086cf:	89 d0                	mov    %edx,%eax
801086d1:	a3 88 84 19 80       	mov    %eax,0x80198488
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
801086d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086d9:	8b 50 24             	mov    0x24(%eax),%edx
801086dc:	8b 40 20             	mov    0x20(%eax),%eax
801086df:	a3 90 84 19 80       	mov    %eax,0x80198490
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801086e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086e7:	8b 50 2c             	mov    0x2c(%eax),%edx
801086ea:	8b 40 28             	mov    0x28(%eax),%eax
801086ed:	a3 94 84 19 80       	mov    %eax,0x80198494
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801086f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086f5:	8b 50 34             	mov    0x34(%eax),%edx
801086f8:	8b 40 30             	mov    0x30(%eax),%eax
801086fb:	a3 98 84 19 80       	mov    %eax,0x80198498
}
80108700:	90                   	nop
80108701:	c9                   	leave  
80108702:	c3                   	ret    

80108703 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108703:	f3 0f 1e fb          	endbr32 
80108707:	55                   	push   %ebp
80108708:	89 e5                	mov    %esp,%ebp
8010870a:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
8010870d:	8b 15 98 84 19 80    	mov    0x80198498,%edx
80108713:	8b 45 0c             	mov    0xc(%ebp),%eax
80108716:	0f af d0             	imul   %eax,%edx
80108719:	8b 45 08             	mov    0x8(%ebp),%eax
8010871c:	01 d0                	add    %edx,%eax
8010871e:	c1 e0 02             	shl    $0x2,%eax
80108721:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108724:	8b 15 88 84 19 80    	mov    0x80198488,%edx
8010872a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010872d:	01 d0                	add    %edx,%eax
8010872f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108732:	8b 45 10             	mov    0x10(%ebp),%eax
80108735:	0f b6 10             	movzbl (%eax),%edx
80108738:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010873b:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
8010873d:	8b 45 10             	mov    0x10(%ebp),%eax
80108740:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108744:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108747:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010874a:	8b 45 10             	mov    0x10(%ebp),%eax
8010874d:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108751:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108754:	88 50 02             	mov    %dl,0x2(%eax)
}
80108757:	90                   	nop
80108758:	c9                   	leave  
80108759:	c3                   	ret    

8010875a <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010875a:	f3 0f 1e fb          	endbr32 
8010875e:	55                   	push   %ebp
8010875f:	89 e5                	mov    %esp,%ebp
80108761:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108764:	8b 15 98 84 19 80    	mov    0x80198498,%edx
8010876a:	8b 45 08             	mov    0x8(%ebp),%eax
8010876d:	0f af c2             	imul   %edx,%eax
80108770:	c1 e0 02             	shl    $0x2,%eax
80108773:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108776:	8b 15 8c 84 19 80    	mov    0x8019848c,%edx
8010877c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877f:	29 c2                	sub    %eax,%edx
80108781:	89 d0                	mov    %edx,%eax
80108783:	8b 0d 88 84 19 80    	mov    0x80198488,%ecx
80108789:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010878c:	01 ca                	add    %ecx,%edx
8010878e:	89 d1                	mov    %edx,%ecx
80108790:	8b 15 88 84 19 80    	mov    0x80198488,%edx
80108796:	83 ec 04             	sub    $0x4,%esp
80108799:	50                   	push   %eax
8010879a:	51                   	push   %ecx
8010879b:	52                   	push   %edx
8010879c:	e8 91 c8 ff ff       	call   80105032 <memmove>
801087a1:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801087a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a7:	8b 0d 88 84 19 80    	mov    0x80198488,%ecx
801087ad:	8b 15 8c 84 19 80    	mov    0x8019848c,%edx
801087b3:	01 d1                	add    %edx,%ecx
801087b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801087b8:	29 d1                	sub    %edx,%ecx
801087ba:	89 ca                	mov    %ecx,%edx
801087bc:	83 ec 04             	sub    $0x4,%esp
801087bf:	50                   	push   %eax
801087c0:	6a 00                	push   $0x0
801087c2:	52                   	push   %edx
801087c3:	e8 a3 c7 ff ff       	call   80104f6b <memset>
801087c8:	83 c4 10             	add    $0x10,%esp
}
801087cb:	90                   	nop
801087cc:	c9                   	leave  
801087cd:	c3                   	ret    

801087ce <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
801087ce:	f3 0f 1e fb          	endbr32 
801087d2:	55                   	push   %ebp
801087d3:	89 e5                	mov    %esp,%ebp
801087d5:	53                   	push   %ebx
801087d6:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
801087d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087e0:	e9 b1 00 00 00       	jmp    80108896 <font_render+0xc8>
    for(int j=14;j>-1;j--){
801087e5:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801087ec:	e9 97 00 00 00       	jmp    80108888 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
801087f1:	8b 45 10             	mov    0x10(%ebp),%eax
801087f4:	83 e8 20             	sub    $0x20,%eax
801087f7:	6b d0 1e             	imul   $0x1e,%eax,%edx
801087fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fd:	01 d0                	add    %edx,%eax
801087ff:	0f b7 84 00 00 b2 10 	movzwl -0x7fef4e00(%eax,%eax,1),%eax
80108806:	80 
80108807:	0f b7 d0             	movzwl %ax,%edx
8010880a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010880d:	bb 01 00 00 00       	mov    $0x1,%ebx
80108812:	89 c1                	mov    %eax,%ecx
80108814:	d3 e3                	shl    %cl,%ebx
80108816:	89 d8                	mov    %ebx,%eax
80108818:	21 d0                	and    %edx,%eax
8010881a:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
8010881d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108820:	ba 01 00 00 00       	mov    $0x1,%edx
80108825:	89 c1                	mov    %eax,%ecx
80108827:	d3 e2                	shl    %cl,%edx
80108829:	89 d0                	mov    %edx,%eax
8010882b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010882e:	75 2b                	jne    8010885b <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108830:	8b 55 0c             	mov    0xc(%ebp),%edx
80108833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108836:	01 c2                	add    %eax,%edx
80108838:	b8 0e 00 00 00       	mov    $0xe,%eax
8010883d:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108840:	89 c1                	mov    %eax,%ecx
80108842:	8b 45 08             	mov    0x8(%ebp),%eax
80108845:	01 c8                	add    %ecx,%eax
80108847:	83 ec 04             	sub    $0x4,%esp
8010884a:	68 00 f5 10 80       	push   $0x8010f500
8010884f:	52                   	push   %edx
80108850:	50                   	push   %eax
80108851:	e8 ad fe ff ff       	call   80108703 <graphic_draw_pixel>
80108856:	83 c4 10             	add    $0x10,%esp
80108859:	eb 29                	jmp    80108884 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010885b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010885e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108861:	01 c2                	add    %eax,%edx
80108863:	b8 0e 00 00 00       	mov    $0xe,%eax
80108868:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010886b:	89 c1                	mov    %eax,%ecx
8010886d:	8b 45 08             	mov    0x8(%ebp),%eax
80108870:	01 c8                	add    %ecx,%eax
80108872:	83 ec 04             	sub    $0x4,%esp
80108875:	68 64 d0 18 80       	push   $0x8018d064
8010887a:	52                   	push   %edx
8010887b:	50                   	push   %eax
8010887c:	e8 82 fe ff ff       	call   80108703 <graphic_draw_pixel>
80108881:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108884:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108888:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010888c:	0f 89 5f ff ff ff    	jns    801087f1 <font_render+0x23>
  for(int i=0;i<30;i++){
80108892:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108896:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010889a:	0f 8e 45 ff ff ff    	jle    801087e5 <font_render+0x17>
      }
    }
  }
}
801088a0:	90                   	nop
801088a1:	90                   	nop
801088a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088a5:	c9                   	leave  
801088a6:	c3                   	ret    

801088a7 <font_render_string>:

void font_render_string(char *string,int row){
801088a7:	f3 0f 1e fb          	endbr32 
801088ab:	55                   	push   %ebp
801088ac:	89 e5                	mov    %esp,%ebp
801088ae:	53                   	push   %ebx
801088af:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801088b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801088b9:	eb 33                	jmp    801088ee <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
801088bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088be:	8b 45 08             	mov    0x8(%ebp),%eax
801088c1:	01 d0                	add    %edx,%eax
801088c3:	0f b6 00             	movzbl (%eax),%eax
801088c6:	0f be d8             	movsbl %al,%ebx
801088c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801088cc:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801088cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088d2:	89 d0                	mov    %edx,%eax
801088d4:	c1 e0 04             	shl    $0x4,%eax
801088d7:	29 d0                	sub    %edx,%eax
801088d9:	83 c0 02             	add    $0x2,%eax
801088dc:	83 ec 04             	sub    $0x4,%esp
801088df:	53                   	push   %ebx
801088e0:	51                   	push   %ecx
801088e1:	50                   	push   %eax
801088e2:	e8 e7 fe ff ff       	call   801087ce <font_render>
801088e7:	83 c4 10             	add    $0x10,%esp
    i++;
801088ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801088ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088f1:	8b 45 08             	mov    0x8(%ebp),%eax
801088f4:	01 d0                	add    %edx,%eax
801088f6:	0f b6 00             	movzbl (%eax),%eax
801088f9:	84 c0                	test   %al,%al
801088fb:	74 06                	je     80108903 <font_render_string+0x5c>
801088fd:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108901:	7e b8                	jle    801088bb <font_render_string+0x14>
  }
}
80108903:	90                   	nop
80108904:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108907:	c9                   	leave  
80108908:	c3                   	ret    

80108909 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108909:	f3 0f 1e fb          	endbr32 
8010890d:	55                   	push   %ebp
8010890e:	89 e5                	mov    %esp,%ebp
80108910:	53                   	push   %ebx
80108911:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108914:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010891b:	eb 6b                	jmp    80108988 <pci_init+0x7f>
    for(int j=0;j<32;j++){
8010891d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108924:	eb 58                	jmp    8010897e <pci_init+0x75>
      for(int k=0;k<8;k++){
80108926:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010892d:	eb 45                	jmp    80108974 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
8010892f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108932:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108938:	83 ec 0c             	sub    $0xc,%esp
8010893b:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010893e:	53                   	push   %ebx
8010893f:	6a 00                	push   $0x0
80108941:	51                   	push   %ecx
80108942:	52                   	push   %edx
80108943:	50                   	push   %eax
80108944:	e8 c0 00 00 00       	call   80108a09 <pci_access_config>
80108949:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010894c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010894f:	0f b7 c0             	movzwl %ax,%eax
80108952:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108957:	74 17                	je     80108970 <pci_init+0x67>
        pci_init_device(i,j,k);
80108959:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010895c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010895f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108962:	83 ec 04             	sub    $0x4,%esp
80108965:	51                   	push   %ecx
80108966:	52                   	push   %edx
80108967:	50                   	push   %eax
80108968:	e8 4f 01 00 00       	call   80108abc <pci_init_device>
8010896d:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108970:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108974:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108978:	7e b5                	jle    8010892f <pci_init+0x26>
    for(int j=0;j<32;j++){
8010897a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010897e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108982:	7e a2                	jle    80108926 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108984:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108988:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010898f:	7e 8c                	jle    8010891d <pci_init+0x14>
      }
      }
    }
  }
}
80108991:	90                   	nop
80108992:	90                   	nop
80108993:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108996:	c9                   	leave  
80108997:	c3                   	ret    

80108998 <pci_write_config>:

void pci_write_config(uint config){
80108998:	f3 0f 1e fb          	endbr32 
8010899c:	55                   	push   %ebp
8010899d:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
8010899f:	8b 45 08             	mov    0x8(%ebp),%eax
801089a2:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801089a7:	89 c0                	mov    %eax,%eax
801089a9:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801089aa:	90                   	nop
801089ab:	5d                   	pop    %ebp
801089ac:	c3                   	ret    

801089ad <pci_write_data>:

void pci_write_data(uint config){
801089ad:	f3 0f 1e fb          	endbr32 
801089b1:	55                   	push   %ebp
801089b2:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801089b4:	8b 45 08             	mov    0x8(%ebp),%eax
801089b7:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801089bc:	89 c0                	mov    %eax,%eax
801089be:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801089bf:	90                   	nop
801089c0:	5d                   	pop    %ebp
801089c1:	c3                   	ret    

801089c2 <pci_read_config>:
uint pci_read_config(){
801089c2:	f3 0f 1e fb          	endbr32 
801089c6:	55                   	push   %ebp
801089c7:	89 e5                	mov    %esp,%ebp
801089c9:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801089cc:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801089d1:	ed                   	in     (%dx),%eax
801089d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801089d5:	83 ec 0c             	sub    $0xc,%esp
801089d8:	68 c8 00 00 00       	push   $0xc8
801089dd:	e8 54 a2 ff ff       	call   80102c36 <microdelay>
801089e2:	83 c4 10             	add    $0x10,%esp
  return data;
801089e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801089e8:	c9                   	leave  
801089e9:	c3                   	ret    

801089ea <pci_test>:


void pci_test(){
801089ea:	f3 0f 1e fb          	endbr32 
801089ee:	55                   	push   %ebp
801089ef:	89 e5                	mov    %esp,%ebp
801089f1:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801089f4:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801089fb:	ff 75 fc             	pushl  -0x4(%ebp)
801089fe:	e8 95 ff ff ff       	call   80108998 <pci_write_config>
80108a03:	83 c4 04             	add    $0x4,%esp
}
80108a06:	90                   	nop
80108a07:	c9                   	leave  
80108a08:	c3                   	ret    

80108a09 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108a09:	f3 0f 1e fb          	endbr32 
80108a0d:	55                   	push   %ebp
80108a0e:	89 e5                	mov    %esp,%ebp
80108a10:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a13:	8b 45 08             	mov    0x8(%ebp),%eax
80108a16:	c1 e0 10             	shl    $0x10,%eax
80108a19:	25 00 00 ff 00       	and    $0xff0000,%eax
80108a1e:	89 c2                	mov    %eax,%edx
80108a20:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a23:	c1 e0 0b             	shl    $0xb,%eax
80108a26:	0f b7 c0             	movzwl %ax,%eax
80108a29:	09 c2                	or     %eax,%edx
80108a2b:	8b 45 10             	mov    0x10(%ebp),%eax
80108a2e:	c1 e0 08             	shl    $0x8,%eax
80108a31:	25 00 07 00 00       	and    $0x700,%eax
80108a36:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108a38:	8b 45 14             	mov    0x14(%ebp),%eax
80108a3b:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a40:	09 d0                	or     %edx,%eax
80108a42:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108a4a:	ff 75 f4             	pushl  -0xc(%ebp)
80108a4d:	e8 46 ff ff ff       	call   80108998 <pci_write_config>
80108a52:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108a55:	e8 68 ff ff ff       	call   801089c2 <pci_read_config>
80108a5a:	8b 55 18             	mov    0x18(%ebp),%edx
80108a5d:	89 02                	mov    %eax,(%edx)
}
80108a5f:	90                   	nop
80108a60:	c9                   	leave  
80108a61:	c3                   	ret    

80108a62 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108a62:	f3 0f 1e fb          	endbr32 
80108a66:	55                   	push   %ebp
80108a67:	89 e5                	mov    %esp,%ebp
80108a69:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80108a6f:	c1 e0 10             	shl    $0x10,%eax
80108a72:	25 00 00 ff 00       	and    $0xff0000,%eax
80108a77:	89 c2                	mov    %eax,%edx
80108a79:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a7c:	c1 e0 0b             	shl    $0xb,%eax
80108a7f:	0f b7 c0             	movzwl %ax,%eax
80108a82:	09 c2                	or     %eax,%edx
80108a84:	8b 45 10             	mov    0x10(%ebp),%eax
80108a87:	c1 e0 08             	shl    $0x8,%eax
80108a8a:	25 00 07 00 00       	and    $0x700,%eax
80108a8f:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108a91:	8b 45 14             	mov    0x14(%ebp),%eax
80108a94:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a99:	09 d0                	or     %edx,%eax
80108a9b:	0d 00 00 00 80       	or     $0x80000000,%eax
80108aa0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108aa3:	ff 75 fc             	pushl  -0x4(%ebp)
80108aa6:	e8 ed fe ff ff       	call   80108998 <pci_write_config>
80108aab:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108aae:	ff 75 18             	pushl  0x18(%ebp)
80108ab1:	e8 f7 fe ff ff       	call   801089ad <pci_write_data>
80108ab6:	83 c4 04             	add    $0x4,%esp
}
80108ab9:	90                   	nop
80108aba:	c9                   	leave  
80108abb:	c3                   	ret    

80108abc <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108abc:	f3 0f 1e fb          	endbr32 
80108ac0:	55                   	push   %ebp
80108ac1:	89 e5                	mov    %esp,%ebp
80108ac3:	53                   	push   %ebx
80108ac4:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80108aca:	a2 9c 84 19 80       	mov    %al,0x8019849c
  dev.device_num = device_num;
80108acf:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ad2:	a2 9d 84 19 80       	mov    %al,0x8019849d
  dev.function_num = function_num;
80108ad7:	8b 45 10             	mov    0x10(%ebp),%eax
80108ada:	a2 9e 84 19 80       	mov    %al,0x8019849e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108adf:	ff 75 10             	pushl  0x10(%ebp)
80108ae2:	ff 75 0c             	pushl  0xc(%ebp)
80108ae5:	ff 75 08             	pushl  0x8(%ebp)
80108ae8:	68 44 c8 10 80       	push   $0x8010c844
80108aed:	e8 1a 79 ff ff       	call   8010040c <cprintf>
80108af2:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108af5:	83 ec 0c             	sub    $0xc,%esp
80108af8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108afb:	50                   	push   %eax
80108afc:	6a 00                	push   $0x0
80108afe:	ff 75 10             	pushl  0x10(%ebp)
80108b01:	ff 75 0c             	pushl  0xc(%ebp)
80108b04:	ff 75 08             	pushl  0x8(%ebp)
80108b07:	e8 fd fe ff ff       	call   80108a09 <pci_access_config>
80108b0c:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108b0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b12:	c1 e8 10             	shr    $0x10,%eax
80108b15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b1b:	25 ff ff 00 00       	and    $0xffff,%eax
80108b20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b26:	a3 a0 84 19 80       	mov    %eax,0x801984a0
  dev.vendor_id = vendor_id;
80108b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b2e:	a3 a4 84 19 80       	mov    %eax,0x801984a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108b33:	83 ec 04             	sub    $0x4,%esp
80108b36:	ff 75 f0             	pushl  -0x10(%ebp)
80108b39:	ff 75 f4             	pushl  -0xc(%ebp)
80108b3c:	68 78 c8 10 80       	push   $0x8010c878
80108b41:	e8 c6 78 ff ff       	call   8010040c <cprintf>
80108b46:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108b49:	83 ec 0c             	sub    $0xc,%esp
80108b4c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b4f:	50                   	push   %eax
80108b50:	6a 08                	push   $0x8
80108b52:	ff 75 10             	pushl  0x10(%ebp)
80108b55:	ff 75 0c             	pushl  0xc(%ebp)
80108b58:	ff 75 08             	pushl  0x8(%ebp)
80108b5b:	e8 a9 fe ff ff       	call   80108a09 <pci_access_config>
80108b60:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b66:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108b69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b6c:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b6f:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108b72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b75:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b78:	0f b6 c0             	movzbl %al,%eax
80108b7b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108b7e:	c1 eb 18             	shr    $0x18,%ebx
80108b81:	83 ec 0c             	sub    $0xc,%esp
80108b84:	51                   	push   %ecx
80108b85:	52                   	push   %edx
80108b86:	50                   	push   %eax
80108b87:	53                   	push   %ebx
80108b88:	68 9c c8 10 80       	push   $0x8010c89c
80108b8d:	e8 7a 78 ff ff       	call   8010040c <cprintf>
80108b92:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b98:	c1 e8 18             	shr    $0x18,%eax
80108b9b:	a2 a8 84 19 80       	mov    %al,0x801984a8
  dev.sub_class = (data>>16)&0xFF;
80108ba0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ba3:	c1 e8 10             	shr    $0x10,%eax
80108ba6:	a2 a9 84 19 80       	mov    %al,0x801984a9
  dev.interface = (data>>8)&0xFF;
80108bab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bae:	c1 e8 08             	shr    $0x8,%eax
80108bb1:	a2 aa 84 19 80       	mov    %al,0x801984aa
  dev.revision_id = data&0xFF;
80108bb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bb9:	a2 ab 84 19 80       	mov    %al,0x801984ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108bbe:	83 ec 0c             	sub    $0xc,%esp
80108bc1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108bc4:	50                   	push   %eax
80108bc5:	6a 10                	push   $0x10
80108bc7:	ff 75 10             	pushl  0x10(%ebp)
80108bca:	ff 75 0c             	pushl  0xc(%ebp)
80108bcd:	ff 75 08             	pushl  0x8(%ebp)
80108bd0:	e8 34 fe ff ff       	call   80108a09 <pci_access_config>
80108bd5:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108bd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bdb:	a3 ac 84 19 80       	mov    %eax,0x801984ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108be0:	83 ec 0c             	sub    $0xc,%esp
80108be3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108be6:	50                   	push   %eax
80108be7:	6a 14                	push   $0x14
80108be9:	ff 75 10             	pushl  0x10(%ebp)
80108bec:	ff 75 0c             	pushl  0xc(%ebp)
80108bef:	ff 75 08             	pushl  0x8(%ebp)
80108bf2:	e8 12 fe ff ff       	call   80108a09 <pci_access_config>
80108bf7:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108bfa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bfd:	a3 b0 84 19 80       	mov    %eax,0x801984b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108c02:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108c09:	75 5a                	jne    80108c65 <pci_init_device+0x1a9>
80108c0b:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108c12:	75 51                	jne    80108c65 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108c14:	83 ec 0c             	sub    $0xc,%esp
80108c17:	68 e1 c8 10 80       	push   $0x8010c8e1
80108c1c:	e8 eb 77 ff ff       	call   8010040c <cprintf>
80108c21:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108c24:	83 ec 0c             	sub    $0xc,%esp
80108c27:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108c2a:	50                   	push   %eax
80108c2b:	68 f0 00 00 00       	push   $0xf0
80108c30:	ff 75 10             	pushl  0x10(%ebp)
80108c33:	ff 75 0c             	pushl  0xc(%ebp)
80108c36:	ff 75 08             	pushl  0x8(%ebp)
80108c39:	e8 cb fd ff ff       	call   80108a09 <pci_access_config>
80108c3e:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108c41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c44:	83 ec 08             	sub    $0x8,%esp
80108c47:	50                   	push   %eax
80108c48:	68 fb c8 10 80       	push   $0x8010c8fb
80108c4d:	e8 ba 77 ff ff       	call   8010040c <cprintf>
80108c52:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108c55:	83 ec 0c             	sub    $0xc,%esp
80108c58:	68 9c 84 19 80       	push   $0x8019849c
80108c5d:	e8 09 00 00 00       	call   80108c6b <i8254_init>
80108c62:	83 c4 10             	add    $0x10,%esp
  }
}
80108c65:	90                   	nop
80108c66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c69:	c9                   	leave  
80108c6a:	c3                   	ret    

80108c6b <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108c6b:	f3 0f 1e fb          	endbr32 
80108c6f:	55                   	push   %ebp
80108c70:	89 e5                	mov    %esp,%ebp
80108c72:	53                   	push   %ebx
80108c73:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108c76:	8b 45 08             	mov    0x8(%ebp),%eax
80108c79:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108c7d:	0f b6 c8             	movzbl %al,%ecx
80108c80:	8b 45 08             	mov    0x8(%ebp),%eax
80108c83:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108c87:	0f b6 d0             	movzbl %al,%edx
80108c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80108c8d:	0f b6 00             	movzbl (%eax),%eax
80108c90:	0f b6 c0             	movzbl %al,%eax
80108c93:	83 ec 0c             	sub    $0xc,%esp
80108c96:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108c99:	53                   	push   %ebx
80108c9a:	6a 04                	push   $0x4
80108c9c:	51                   	push   %ecx
80108c9d:	52                   	push   %edx
80108c9e:	50                   	push   %eax
80108c9f:	e8 65 fd ff ff       	call   80108a09 <pci_access_config>
80108ca4:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108ca7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108caa:	83 c8 04             	or     $0x4,%eax
80108cad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108cb0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80108cb6:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108cba:	0f b6 c8             	movzbl %al,%ecx
80108cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80108cc0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108cc4:	0f b6 d0             	movzbl %al,%edx
80108cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80108cca:	0f b6 00             	movzbl (%eax),%eax
80108ccd:	0f b6 c0             	movzbl %al,%eax
80108cd0:	83 ec 0c             	sub    $0xc,%esp
80108cd3:	53                   	push   %ebx
80108cd4:	6a 04                	push   $0x4
80108cd6:	51                   	push   %ecx
80108cd7:	52                   	push   %edx
80108cd8:	50                   	push   %eax
80108cd9:	e8 84 fd ff ff       	call   80108a62 <pci_write_config_register>
80108cde:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ce4:	8b 40 10             	mov    0x10(%eax),%eax
80108ce7:	05 00 00 00 40       	add    $0x40000000,%eax
80108cec:	a3 b4 84 19 80       	mov    %eax,0x801984b4
  uint *ctrl = (uint *)base_addr;
80108cf1:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108cf9:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108cfe:	05 d8 00 00 00       	add    $0xd8,%eax
80108d03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108d06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d09:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d12:	8b 00                	mov    (%eax),%eax
80108d14:	0d 00 00 00 04       	or     $0x4000000,%eax
80108d19:	89 c2                	mov    %eax,%edx
80108d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d1e:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d23:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d2c:	8b 00                	mov    (%eax),%eax
80108d2e:	83 c8 40             	or     $0x40,%eax
80108d31:	89 c2                	mov    %eax,%edx
80108d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d36:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d3b:	8b 10                	mov    (%eax),%edx
80108d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d40:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108d42:	83 ec 0c             	sub    $0xc,%esp
80108d45:	68 10 c9 10 80       	push   $0x8010c910
80108d4a:	e8 bd 76 ff ff       	call   8010040c <cprintf>
80108d4f:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108d52:	e8 2d 9b ff ff       	call   80102884 <kalloc>
80108d57:	a3 b8 84 19 80       	mov    %eax,0x801984b8
  *intr_addr = 0;
80108d5c:	a1 b8 84 19 80       	mov    0x801984b8,%eax
80108d61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108d67:	a1 b8 84 19 80       	mov    0x801984b8,%eax
80108d6c:	83 ec 08             	sub    $0x8,%esp
80108d6f:	50                   	push   %eax
80108d70:	68 32 c9 10 80       	push   $0x8010c932
80108d75:	e8 92 76 ff ff       	call   8010040c <cprintf>
80108d7a:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108d7d:	e8 50 00 00 00       	call   80108dd2 <i8254_init_recv>
  i8254_init_send();
80108d82:	e8 6d 03 00 00       	call   801090f4 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108d87:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d8e:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108d91:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d98:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108d9b:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108da2:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108da5:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108dac:	0f b6 c0             	movzbl %al,%eax
80108daf:	83 ec 0c             	sub    $0xc,%esp
80108db2:	53                   	push   %ebx
80108db3:	51                   	push   %ecx
80108db4:	52                   	push   %edx
80108db5:	50                   	push   %eax
80108db6:	68 40 c9 10 80       	push   $0x8010c940
80108dbb:	e8 4c 76 ff ff       	call   8010040c <cprintf>
80108dc0:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dc6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108dcc:	90                   	nop
80108dcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108dd0:	c9                   	leave  
80108dd1:	c3                   	ret    

80108dd2 <i8254_init_recv>:

void i8254_init_recv(){
80108dd2:	f3 0f 1e fb          	endbr32 
80108dd6:	55                   	push   %ebp
80108dd7:	89 e5                	mov    %esp,%ebp
80108dd9:	57                   	push   %edi
80108dda:	56                   	push   %esi
80108ddb:	53                   	push   %ebx
80108ddc:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108ddf:	83 ec 0c             	sub    $0xc,%esp
80108de2:	6a 00                	push   $0x0
80108de4:	e8 ec 04 00 00       	call   801092d5 <i8254_read_eeprom>
80108de9:	83 c4 10             	add    $0x10,%esp
80108dec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108def:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108df2:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108df7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108dfa:	c1 e8 08             	shr    $0x8,%eax
80108dfd:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108e02:	83 ec 0c             	sub    $0xc,%esp
80108e05:	6a 01                	push   $0x1
80108e07:	e8 c9 04 00 00       	call   801092d5 <i8254_read_eeprom>
80108e0c:	83 c4 10             	add    $0x10,%esp
80108e0f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108e12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e15:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108e1a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e1d:	c1 e8 08             	shr    $0x8,%eax
80108e20:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108e25:	83 ec 0c             	sub    $0xc,%esp
80108e28:	6a 02                	push   $0x2
80108e2a:	e8 a6 04 00 00       	call   801092d5 <i8254_read_eeprom>
80108e2f:	83 c4 10             	add    $0x10,%esp
80108e32:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108e35:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e38:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108e3d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e40:	c1 e8 08             	shr    $0x8,%eax
80108e43:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108e48:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e4f:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108e52:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e59:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108e5c:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e63:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108e66:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e6d:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108e70:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e77:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108e7a:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e81:	0f b6 c0             	movzbl %al,%eax
80108e84:	83 ec 04             	sub    $0x4,%esp
80108e87:	57                   	push   %edi
80108e88:	56                   	push   %esi
80108e89:	53                   	push   %ebx
80108e8a:	51                   	push   %ecx
80108e8b:	52                   	push   %edx
80108e8c:	50                   	push   %eax
80108e8d:	68 58 c9 10 80       	push   $0x8010c958
80108e92:	e8 75 75 ff ff       	call   8010040c <cprintf>
80108e97:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108e9a:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108e9f:	05 00 54 00 00       	add    $0x5400,%eax
80108ea4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108ea7:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108eac:	05 04 54 00 00       	add    $0x5404,%eax
80108eb1:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108eb4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108eb7:	c1 e0 10             	shl    $0x10,%eax
80108eba:	0b 45 d8             	or     -0x28(%ebp),%eax
80108ebd:	89 c2                	mov    %eax,%edx
80108ebf:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108ec2:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108ec4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ec7:	0d 00 00 00 80       	or     $0x80000000,%eax
80108ecc:	89 c2                	mov    %eax,%edx
80108ece:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108ed1:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108ed3:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108ed8:	05 00 52 00 00       	add    $0x5200,%eax
80108edd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108ee0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108ee7:	eb 19                	jmp    80108f02 <i8254_init_recv+0x130>
    mta[i] = 0;
80108ee9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108eec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ef3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ef6:	01 d0                	add    %edx,%eax
80108ef8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108efe:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108f02:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108f06:	7e e1                	jle    80108ee9 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108f08:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f0d:	05 d0 00 00 00       	add    $0xd0,%eax
80108f12:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108f15:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108f18:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108f1e:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f23:	05 c8 00 00 00       	add    $0xc8,%eax
80108f28:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108f2b:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108f2e:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108f34:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f39:	05 28 28 00 00       	add    $0x2828,%eax
80108f3e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108f41:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108f44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108f4a:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f4f:	05 00 01 00 00       	add    $0x100,%eax
80108f54:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108f57:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f5a:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108f60:	e8 1f 99 ff ff       	call   80102884 <kalloc>
80108f65:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f68:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f6d:	05 00 28 00 00       	add    $0x2800,%eax
80108f72:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108f75:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f7a:	05 04 28 00 00       	add    $0x2804,%eax
80108f7f:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108f82:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f87:	05 08 28 00 00       	add    $0x2808,%eax
80108f8c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f8f:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f94:	05 10 28 00 00       	add    $0x2810,%eax
80108f99:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f9c:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108fa1:	05 18 28 00 00       	add    $0x2818,%eax
80108fa6:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108fa9:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108fac:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108fb2:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108fb5:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108fb7:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108fba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108fc0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108fc3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108fc9:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108fcc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108fd2:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108fd5:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108fdb:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108fde:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108fe1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108fe8:	eb 73                	jmp    8010905d <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108fea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fed:	c1 e0 04             	shl    $0x4,%eax
80108ff0:	89 c2                	mov    %eax,%edx
80108ff2:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ff5:	01 d0                	add    %edx,%eax
80108ff7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108ffe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109001:	c1 e0 04             	shl    $0x4,%eax
80109004:	89 c2                	mov    %eax,%edx
80109006:	8b 45 98             	mov    -0x68(%ebp),%eax
80109009:	01 d0                	add    %edx,%eax
8010900b:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80109011:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109014:	c1 e0 04             	shl    $0x4,%eax
80109017:	89 c2                	mov    %eax,%edx
80109019:	8b 45 98             	mov    -0x68(%ebp),%eax
8010901c:	01 d0                	add    %edx,%eax
8010901e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80109024:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109027:	c1 e0 04             	shl    $0x4,%eax
8010902a:	89 c2                	mov    %eax,%edx
8010902c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010902f:	01 d0                	add    %edx,%eax
80109031:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80109035:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109038:	c1 e0 04             	shl    $0x4,%eax
8010903b:	89 c2                	mov    %eax,%edx
8010903d:	8b 45 98             	mov    -0x68(%ebp),%eax
80109040:	01 d0                	add    %edx,%eax
80109042:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109046:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109049:	c1 e0 04             	shl    $0x4,%eax
8010904c:	89 c2                	mov    %eax,%edx
8010904e:	8b 45 98             	mov    -0x68(%ebp),%eax
80109051:	01 d0                	add    %edx,%eax
80109053:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109059:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010905d:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109064:	7e 84                	jle    80108fea <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109066:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010906d:	eb 57                	jmp    801090c6 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
8010906f:	e8 10 98 ff ff       	call   80102884 <kalloc>
80109074:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109077:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
8010907b:	75 12                	jne    8010908f <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
8010907d:	83 ec 0c             	sub    $0xc,%esp
80109080:	68 78 c9 10 80       	push   $0x8010c978
80109085:	e8 82 73 ff ff       	call   8010040c <cprintf>
8010908a:	83 c4 10             	add    $0x10,%esp
      break;
8010908d:	eb 3d                	jmp    801090cc <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
8010908f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109092:	c1 e0 04             	shl    $0x4,%eax
80109095:	89 c2                	mov    %eax,%edx
80109097:	8b 45 98             	mov    -0x68(%ebp),%eax
8010909a:	01 d0                	add    %edx,%eax
8010909c:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010909f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801090a5:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801090a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801090aa:	83 c0 01             	add    $0x1,%eax
801090ad:	c1 e0 04             	shl    $0x4,%eax
801090b0:	89 c2                	mov    %eax,%edx
801090b2:	8b 45 98             	mov    -0x68(%ebp),%eax
801090b5:	01 d0                	add    %edx,%eax
801090b7:	8b 55 94             	mov    -0x6c(%ebp),%edx
801090ba:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801090c0:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801090c2:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801090c6:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801090ca:	7e a3                	jle    8010906f <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
801090cc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801090cf:	8b 00                	mov    (%eax),%eax
801090d1:	83 c8 02             	or     $0x2,%eax
801090d4:	89 c2                	mov    %eax,%edx
801090d6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801090d9:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801090db:	83 ec 0c             	sub    $0xc,%esp
801090de:	68 98 c9 10 80       	push   $0x8010c998
801090e3:	e8 24 73 ff ff       	call   8010040c <cprintf>
801090e8:	83 c4 10             	add    $0x10,%esp
}
801090eb:	90                   	nop
801090ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
801090ef:	5b                   	pop    %ebx
801090f0:	5e                   	pop    %esi
801090f1:	5f                   	pop    %edi
801090f2:	5d                   	pop    %ebp
801090f3:	c3                   	ret    

801090f4 <i8254_init_send>:

void i8254_init_send(){
801090f4:	f3 0f 1e fb          	endbr32 
801090f8:	55                   	push   %ebp
801090f9:	89 e5                	mov    %esp,%ebp
801090fb:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801090fe:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80109103:	05 28 38 00 00       	add    $0x3828,%eax
80109108:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
8010910b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010910e:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80109114:	e8 6b 97 ff ff       	call   80102884 <kalloc>
80109119:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
8010911c:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80109121:	05 00 38 00 00       	add    $0x3800,%eax
80109126:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80109129:	a1 b4 84 19 80       	mov    0x801984b4,%eax
8010912e:	05 04 38 00 00       	add    $0x3804,%eax
80109133:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80109136:	a1 b4 84 19 80       	mov    0x801984b4,%eax
8010913b:	05 08 38 00 00       	add    $0x3808,%eax
80109140:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80109143:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109146:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010914c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010914f:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109151:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109154:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
8010915a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010915d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80109163:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80109168:	05 10 38 00 00       	add    $0x3810,%eax
8010916d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109170:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80109175:	05 18 38 00 00       	add    $0x3818,%eax
8010917a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
8010917d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109180:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80109186:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109189:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
8010918f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109192:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109195:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010919c:	e9 82 00 00 00       	jmp    80109223 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
801091a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091a4:	c1 e0 04             	shl    $0x4,%eax
801091a7:	89 c2                	mov    %eax,%edx
801091a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091ac:	01 d0                	add    %edx,%eax
801091ae:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801091b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091b8:	c1 e0 04             	shl    $0x4,%eax
801091bb:	89 c2                	mov    %eax,%edx
801091bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091c0:	01 d0                	add    %edx,%eax
801091c2:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801091c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cb:	c1 e0 04             	shl    $0x4,%eax
801091ce:	89 c2                	mov    %eax,%edx
801091d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091d3:	01 d0                	add    %edx,%eax
801091d5:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801091d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091dc:	c1 e0 04             	shl    $0x4,%eax
801091df:	89 c2                	mov    %eax,%edx
801091e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091e4:	01 d0                	add    %edx,%eax
801091e6:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801091ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ed:	c1 e0 04             	shl    $0x4,%eax
801091f0:	89 c2                	mov    %eax,%edx
801091f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091f5:	01 d0                	add    %edx,%eax
801091f7:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801091fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091fe:	c1 e0 04             	shl    $0x4,%eax
80109201:	89 c2                	mov    %eax,%edx
80109203:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109206:	01 d0                	add    %edx,%eax
80109208:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
8010920c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010920f:	c1 e0 04             	shl    $0x4,%eax
80109212:	89 c2                	mov    %eax,%edx
80109214:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109217:	01 d0                	add    %edx,%eax
80109219:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010921f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109223:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010922a:	0f 8e 71 ff ff ff    	jle    801091a1 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109230:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109237:	eb 57                	jmp    80109290 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80109239:	e8 46 96 ff ff       	call   80102884 <kalloc>
8010923e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109241:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109245:	75 12                	jne    80109259 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80109247:	83 ec 0c             	sub    $0xc,%esp
8010924a:	68 78 c9 10 80       	push   $0x8010c978
8010924f:	e8 b8 71 ff ff       	call   8010040c <cprintf>
80109254:	83 c4 10             	add    $0x10,%esp
      break;
80109257:	eb 3d                	jmp    80109296 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109259:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010925c:	c1 e0 04             	shl    $0x4,%eax
8010925f:	89 c2                	mov    %eax,%edx
80109261:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109264:	01 d0                	add    %edx,%eax
80109266:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109269:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010926f:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109274:	83 c0 01             	add    $0x1,%eax
80109277:	c1 e0 04             	shl    $0x4,%eax
8010927a:	89 c2                	mov    %eax,%edx
8010927c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010927f:	01 d0                	add    %edx,%eax
80109281:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109284:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010928a:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010928c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109290:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109294:	7e a3                	jle    80109239 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109296:	a1 b4 84 19 80       	mov    0x801984b4,%eax
8010929b:	05 00 04 00 00       	add    $0x400,%eax
801092a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801092a3:	8b 45 c8             	mov    -0x38(%ebp),%eax
801092a6:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801092ac:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801092b1:	05 10 04 00 00       	add    $0x410,%eax
801092b6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801092b9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801092bc:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801092c2:	83 ec 0c             	sub    $0xc,%esp
801092c5:	68 b8 c9 10 80       	push   $0x8010c9b8
801092ca:	e8 3d 71 ff ff       	call   8010040c <cprintf>
801092cf:	83 c4 10             	add    $0x10,%esp

}
801092d2:	90                   	nop
801092d3:	c9                   	leave  
801092d4:	c3                   	ret    

801092d5 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801092d5:	f3 0f 1e fb          	endbr32 
801092d9:	55                   	push   %ebp
801092da:	89 e5                	mov    %esp,%ebp
801092dc:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801092df:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801092e4:	83 c0 14             	add    $0x14,%eax
801092e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801092ea:	8b 45 08             	mov    0x8(%ebp),%eax
801092ed:	c1 e0 08             	shl    $0x8,%eax
801092f0:	0f b7 c0             	movzwl %ax,%eax
801092f3:	83 c8 01             	or     $0x1,%eax
801092f6:	89 c2                	mov    %eax,%edx
801092f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092fb:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801092fd:	83 ec 0c             	sub    $0xc,%esp
80109300:	68 d8 c9 10 80       	push   $0x8010c9d8
80109305:	e8 02 71 ff ff       	call   8010040c <cprintf>
8010930a:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
8010930d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109310:	8b 00                	mov    (%eax),%eax
80109312:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80109315:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109318:	83 e0 10             	and    $0x10,%eax
8010931b:	85 c0                	test   %eax,%eax
8010931d:	75 02                	jne    80109321 <i8254_read_eeprom+0x4c>
  while(1){
8010931f:	eb dc                	jmp    801092fd <i8254_read_eeprom+0x28>
      break;
80109321:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80109322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109325:	8b 00                	mov    (%eax),%eax
80109327:	c1 e8 10             	shr    $0x10,%eax
}
8010932a:	c9                   	leave  
8010932b:	c3                   	ret    

8010932c <i8254_recv>:
void i8254_recv(){
8010932c:	f3 0f 1e fb          	endbr32 
80109330:	55                   	push   %ebp
80109331:	89 e5                	mov    %esp,%ebp
80109333:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80109336:	a1 b4 84 19 80       	mov    0x801984b4,%eax
8010933b:	05 10 28 00 00       	add    $0x2810,%eax
80109340:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109343:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80109348:	05 18 28 00 00       	add    $0x2818,%eax
8010934d:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109350:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80109355:	05 00 28 00 00       	add    $0x2800,%eax
8010935a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010935d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109360:	8b 00                	mov    (%eax),%eax
80109362:	05 00 00 00 80       	add    $0x80000000,%eax
80109367:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010936a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010936d:	8b 10                	mov    (%eax),%edx
8010936f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109372:	8b 00                	mov    (%eax),%eax
80109374:	29 c2                	sub    %eax,%edx
80109376:	89 d0                	mov    %edx,%eax
80109378:	25 ff 00 00 00       	and    $0xff,%eax
8010937d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109380:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109384:	7e 37                	jle    801093bd <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109386:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109389:	8b 00                	mov    (%eax),%eax
8010938b:	c1 e0 04             	shl    $0x4,%eax
8010938e:	89 c2                	mov    %eax,%edx
80109390:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109393:	01 d0                	add    %edx,%eax
80109395:	8b 00                	mov    (%eax),%eax
80109397:	05 00 00 00 80       	add    $0x80000000,%eax
8010939c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
8010939f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093a2:	8b 00                	mov    (%eax),%eax
801093a4:	83 c0 01             	add    $0x1,%eax
801093a7:	0f b6 d0             	movzbl %al,%edx
801093aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ad:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801093af:	83 ec 0c             	sub    $0xc,%esp
801093b2:	ff 75 e0             	pushl  -0x20(%ebp)
801093b5:	e8 47 09 00 00       	call   80109d01 <eth_proc>
801093ba:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801093bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c0:	8b 10                	mov    (%eax),%edx
801093c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c5:	8b 00                	mov    (%eax),%eax
801093c7:	39 c2                	cmp    %eax,%edx
801093c9:	75 9f                	jne    8010936a <i8254_recv+0x3e>
      (*rdt)--;
801093cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093ce:	8b 00                	mov    (%eax),%eax
801093d0:	8d 50 ff             	lea    -0x1(%eax),%edx
801093d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093d6:	89 10                	mov    %edx,(%eax)
  while(1){
801093d8:	eb 90                	jmp    8010936a <i8254_recv+0x3e>

801093da <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801093da:	f3 0f 1e fb          	endbr32 
801093de:	55                   	push   %ebp
801093df:	89 e5                	mov    %esp,%ebp
801093e1:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801093e4:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801093e9:	05 10 38 00 00       	add    $0x3810,%eax
801093ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801093f1:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801093f6:	05 18 38 00 00       	add    $0x3818,%eax
801093fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801093fe:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80109403:	05 00 38 00 00       	add    $0x3800,%eax
80109408:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
8010940b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010940e:	8b 00                	mov    (%eax),%eax
80109410:	05 00 00 00 80       	add    $0x80000000,%eax
80109415:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109418:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010941b:	8b 10                	mov    (%eax),%edx
8010941d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109420:	8b 00                	mov    (%eax),%eax
80109422:	29 c2                	sub    %eax,%edx
80109424:	89 d0                	mov    %edx,%eax
80109426:	0f b6 c0             	movzbl %al,%eax
80109429:	ba 00 01 00 00       	mov    $0x100,%edx
8010942e:	29 c2                	sub    %eax,%edx
80109430:	89 d0                	mov    %edx,%eax
80109432:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80109435:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109438:	8b 00                	mov    (%eax),%eax
8010943a:	25 ff 00 00 00       	and    $0xff,%eax
8010943f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109442:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109446:	0f 8e a8 00 00 00    	jle    801094f4 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
8010944c:	8b 45 08             	mov    0x8(%ebp),%eax
8010944f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109452:	89 d1                	mov    %edx,%ecx
80109454:	c1 e1 04             	shl    $0x4,%ecx
80109457:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010945a:	01 ca                	add    %ecx,%edx
8010945c:	8b 12                	mov    (%edx),%edx
8010945e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109464:	83 ec 04             	sub    $0x4,%esp
80109467:	ff 75 0c             	pushl  0xc(%ebp)
8010946a:	50                   	push   %eax
8010946b:	52                   	push   %edx
8010946c:	e8 c1 bb ff ff       	call   80105032 <memmove>
80109471:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109474:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109477:	c1 e0 04             	shl    $0x4,%eax
8010947a:	89 c2                	mov    %eax,%edx
8010947c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010947f:	01 d0                	add    %edx,%eax
80109481:	8b 55 0c             	mov    0xc(%ebp),%edx
80109484:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109488:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010948b:	c1 e0 04             	shl    $0x4,%eax
8010948e:	89 c2                	mov    %eax,%edx
80109490:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109493:	01 d0                	add    %edx,%eax
80109495:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109499:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010949c:	c1 e0 04             	shl    $0x4,%eax
8010949f:	89 c2                	mov    %eax,%edx
801094a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094a4:	01 d0                	add    %edx,%eax
801094a6:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801094aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094ad:	c1 e0 04             	shl    $0x4,%eax
801094b0:	89 c2                	mov    %eax,%edx
801094b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094b5:	01 d0                	add    %edx,%eax
801094b7:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801094bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094be:	c1 e0 04             	shl    $0x4,%eax
801094c1:	89 c2                	mov    %eax,%edx
801094c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094c6:	01 d0                	add    %edx,%eax
801094c8:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801094ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094d1:	c1 e0 04             	shl    $0x4,%eax
801094d4:	89 c2                	mov    %eax,%edx
801094d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094d9:	01 d0                	add    %edx,%eax
801094db:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801094df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094e2:	8b 00                	mov    (%eax),%eax
801094e4:	83 c0 01             	add    $0x1,%eax
801094e7:	0f b6 d0             	movzbl %al,%edx
801094ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094ed:	89 10                	mov    %edx,(%eax)
    return len;
801094ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801094f2:	eb 05                	jmp    801094f9 <i8254_send+0x11f>
  }else{
    return -1;
801094f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801094f9:	c9                   	leave  
801094fa:	c3                   	ret    

801094fb <i8254_intr>:

void i8254_intr(){
801094fb:	f3 0f 1e fb          	endbr32 
801094ff:	55                   	push   %ebp
80109500:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80109502:	a1 b8 84 19 80       	mov    0x801984b8,%eax
80109507:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
8010950d:	90                   	nop
8010950e:	5d                   	pop    %ebp
8010950f:	c3                   	ret    

80109510 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109510:	f3 0f 1e fb          	endbr32 
80109514:	55                   	push   %ebp
80109515:	89 e5                	mov    %esp,%ebp
80109517:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010951a:	8b 45 08             	mov    0x8(%ebp),%eax
8010951d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109523:	0f b7 00             	movzwl (%eax),%eax
80109526:	66 3d 00 01          	cmp    $0x100,%ax
8010952a:	74 0a                	je     80109536 <arp_proc+0x26>
8010952c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109531:	e9 4f 01 00 00       	jmp    80109685 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109539:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010953d:	66 83 f8 08          	cmp    $0x8,%ax
80109541:	74 0a                	je     8010954d <arp_proc+0x3d>
80109543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109548:	e9 38 01 00 00       	jmp    80109685 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
8010954d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109550:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109554:	3c 06                	cmp    $0x6,%al
80109556:	74 0a                	je     80109562 <arp_proc+0x52>
80109558:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010955d:	e9 23 01 00 00       	jmp    80109685 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109565:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109569:	3c 04                	cmp    $0x4,%al
8010956b:	74 0a                	je     80109577 <arp_proc+0x67>
8010956d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109572:	e9 0e 01 00 00       	jmp    80109685 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010957a:	83 c0 18             	add    $0x18,%eax
8010957d:	83 ec 04             	sub    $0x4,%esp
80109580:	6a 04                	push   $0x4
80109582:	50                   	push   %eax
80109583:	68 04 f5 10 80       	push   $0x8010f504
80109588:	e8 49 ba ff ff       	call   80104fd6 <memcmp>
8010958d:	83 c4 10             	add    $0x10,%esp
80109590:	85 c0                	test   %eax,%eax
80109592:	74 27                	je     801095bb <arp_proc+0xab>
80109594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109597:	83 c0 0e             	add    $0xe,%eax
8010959a:	83 ec 04             	sub    $0x4,%esp
8010959d:	6a 04                	push   $0x4
8010959f:	50                   	push   %eax
801095a0:	68 04 f5 10 80       	push   $0x8010f504
801095a5:	e8 2c ba ff ff       	call   80104fd6 <memcmp>
801095aa:	83 c4 10             	add    $0x10,%esp
801095ad:	85 c0                	test   %eax,%eax
801095af:	74 0a                	je     801095bb <arp_proc+0xab>
801095b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801095b6:	e9 ca 00 00 00       	jmp    80109685 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801095bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095be:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801095c2:	66 3d 00 01          	cmp    $0x100,%ax
801095c6:	75 69                	jne    80109631 <arp_proc+0x121>
801095c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095cb:	83 c0 18             	add    $0x18,%eax
801095ce:	83 ec 04             	sub    $0x4,%esp
801095d1:	6a 04                	push   $0x4
801095d3:	50                   	push   %eax
801095d4:	68 04 f5 10 80       	push   $0x8010f504
801095d9:	e8 f8 b9 ff ff       	call   80104fd6 <memcmp>
801095de:	83 c4 10             	add    $0x10,%esp
801095e1:	85 c0                	test   %eax,%eax
801095e3:	75 4c                	jne    80109631 <arp_proc+0x121>
    uint send = (uint)kalloc();
801095e5:	e8 9a 92 ff ff       	call   80102884 <kalloc>
801095ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801095ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801095f4:	83 ec 04             	sub    $0x4,%esp
801095f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801095fa:	50                   	push   %eax
801095fb:	ff 75 f0             	pushl  -0x10(%ebp)
801095fe:	ff 75 f4             	pushl  -0xc(%ebp)
80109601:	e8 33 04 00 00       	call   80109a39 <arp_reply_pkt_create>
80109606:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109609:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010960c:	83 ec 08             	sub    $0x8,%esp
8010960f:	50                   	push   %eax
80109610:	ff 75 f0             	pushl  -0x10(%ebp)
80109613:	e8 c2 fd ff ff       	call   801093da <i8254_send>
80109618:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010961b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010961e:	83 ec 0c             	sub    $0xc,%esp
80109621:	50                   	push   %eax
80109622:	e8 bf 91 ff ff       	call   801027e6 <kfree>
80109627:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010962a:	b8 02 00 00 00       	mov    $0x2,%eax
8010962f:	eb 54                	jmp    80109685 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109634:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109638:	66 3d 00 02          	cmp    $0x200,%ax
8010963c:	75 42                	jne    80109680 <arp_proc+0x170>
8010963e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109641:	83 c0 18             	add    $0x18,%eax
80109644:	83 ec 04             	sub    $0x4,%esp
80109647:	6a 04                	push   $0x4
80109649:	50                   	push   %eax
8010964a:	68 04 f5 10 80       	push   $0x8010f504
8010964f:	e8 82 b9 ff ff       	call   80104fd6 <memcmp>
80109654:	83 c4 10             	add    $0x10,%esp
80109657:	85 c0                	test   %eax,%eax
80109659:	75 25                	jne    80109680 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
8010965b:	83 ec 0c             	sub    $0xc,%esp
8010965e:	68 dc c9 10 80       	push   $0x8010c9dc
80109663:	e8 a4 6d ff ff       	call   8010040c <cprintf>
80109668:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010966b:	83 ec 0c             	sub    $0xc,%esp
8010966e:	ff 75 f4             	pushl  -0xc(%ebp)
80109671:	e8 b7 01 00 00       	call   8010982d <arp_table_update>
80109676:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109679:	b8 01 00 00 00       	mov    $0x1,%eax
8010967e:	eb 05                	jmp    80109685 <arp_proc+0x175>
  }else{
    return -1;
80109680:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109685:	c9                   	leave  
80109686:	c3                   	ret    

80109687 <arp_scan>:

void arp_scan(){
80109687:	f3 0f 1e fb          	endbr32 
8010968b:	55                   	push   %ebp
8010968c:	89 e5                	mov    %esp,%ebp
8010968e:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109698:	eb 6f                	jmp    80109709 <arp_scan+0x82>
    uint send = (uint)kalloc();
8010969a:	e8 e5 91 ff ff       	call   80102884 <kalloc>
8010969f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801096a2:	83 ec 04             	sub    $0x4,%esp
801096a5:	ff 75 f4             	pushl  -0xc(%ebp)
801096a8:	8d 45 e8             	lea    -0x18(%ebp),%eax
801096ab:	50                   	push   %eax
801096ac:	ff 75 ec             	pushl  -0x14(%ebp)
801096af:	e8 62 00 00 00       	call   80109716 <arp_broadcast>
801096b4:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801096b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096ba:	83 ec 08             	sub    $0x8,%esp
801096bd:	50                   	push   %eax
801096be:	ff 75 ec             	pushl  -0x14(%ebp)
801096c1:	e8 14 fd ff ff       	call   801093da <i8254_send>
801096c6:	83 c4 10             	add    $0x10,%esp
801096c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801096cc:	eb 22                	jmp    801096f0 <arp_scan+0x69>
      microdelay(1);
801096ce:	83 ec 0c             	sub    $0xc,%esp
801096d1:	6a 01                	push   $0x1
801096d3:	e8 5e 95 ff ff       	call   80102c36 <microdelay>
801096d8:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801096db:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096de:	83 ec 08             	sub    $0x8,%esp
801096e1:	50                   	push   %eax
801096e2:	ff 75 ec             	pushl  -0x14(%ebp)
801096e5:	e8 f0 fc ff ff       	call   801093da <i8254_send>
801096ea:	83 c4 10             	add    $0x10,%esp
801096ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801096f0:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801096f4:	74 d8                	je     801096ce <arp_scan+0x47>
    }
    kfree((char *)send);
801096f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096f9:	83 ec 0c             	sub    $0xc,%esp
801096fc:	50                   	push   %eax
801096fd:	e8 e4 90 ff ff       	call   801027e6 <kfree>
80109702:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109705:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109709:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109710:	7e 88                	jle    8010969a <arp_scan+0x13>
  }
}
80109712:	90                   	nop
80109713:	90                   	nop
80109714:	c9                   	leave  
80109715:	c3                   	ret    

80109716 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109716:	f3 0f 1e fb          	endbr32 
8010971a:	55                   	push   %ebp
8010971b:	89 e5                	mov    %esp,%ebp
8010971d:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109720:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109724:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109728:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
8010972c:	8b 45 10             	mov    0x10(%ebp),%eax
8010972f:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109732:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109739:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
8010973f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109746:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010974c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010974f:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109755:	8b 45 08             	mov    0x8(%ebp),%eax
80109758:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010975b:	8b 45 08             	mov    0x8(%ebp),%eax
8010975e:	83 c0 0e             	add    $0xe,%eax
80109761:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109767:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010976b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010976e:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109775:	83 ec 04             	sub    $0x4,%esp
80109778:	6a 06                	push   $0x6
8010977a:	8d 55 e6             	lea    -0x1a(%ebp),%edx
8010977d:	52                   	push   %edx
8010977e:	50                   	push   %eax
8010977f:	e8 ae b8 ff ff       	call   80105032 <memmove>
80109784:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010978a:	83 c0 06             	add    $0x6,%eax
8010978d:	83 ec 04             	sub    $0x4,%esp
80109790:	6a 06                	push   $0x6
80109792:	68 68 d0 18 80       	push   $0x8018d068
80109797:	50                   	push   %eax
80109798:	e8 95 b8 ff ff       	call   80105032 <memmove>
8010979d:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801097a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a3:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801097a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097ab:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801097b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097b4:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801097b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097bb:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801097bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097c2:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801097c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097cb:	8d 50 12             	lea    0x12(%eax),%edx
801097ce:	83 ec 04             	sub    $0x4,%esp
801097d1:	6a 06                	push   $0x6
801097d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801097d6:	50                   	push   %eax
801097d7:	52                   	push   %edx
801097d8:	e8 55 b8 ff ff       	call   80105032 <memmove>
801097dd:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801097e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097e3:	8d 50 18             	lea    0x18(%eax),%edx
801097e6:	83 ec 04             	sub    $0x4,%esp
801097e9:	6a 04                	push   $0x4
801097eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801097ee:	50                   	push   %eax
801097ef:	52                   	push   %edx
801097f0:	e8 3d b8 ff ff       	call   80105032 <memmove>
801097f5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801097f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097fb:	83 c0 08             	add    $0x8,%eax
801097fe:	83 ec 04             	sub    $0x4,%esp
80109801:	6a 06                	push   $0x6
80109803:	68 68 d0 18 80       	push   $0x8018d068
80109808:	50                   	push   %eax
80109809:	e8 24 b8 ff ff       	call   80105032 <memmove>
8010980e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109811:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109814:	83 c0 0e             	add    $0xe,%eax
80109817:	83 ec 04             	sub    $0x4,%esp
8010981a:	6a 04                	push   $0x4
8010981c:	68 04 f5 10 80       	push   $0x8010f504
80109821:	50                   	push   %eax
80109822:	e8 0b b8 ff ff       	call   80105032 <memmove>
80109827:	83 c4 10             	add    $0x10,%esp
}
8010982a:	90                   	nop
8010982b:	c9                   	leave  
8010982c:	c3                   	ret    

8010982d <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
8010982d:	f3 0f 1e fb          	endbr32 
80109831:	55                   	push   %ebp
80109832:	89 e5                	mov    %esp,%ebp
80109834:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109837:	8b 45 08             	mov    0x8(%ebp),%eax
8010983a:	83 c0 0e             	add    $0xe,%eax
8010983d:	83 ec 0c             	sub    $0xc,%esp
80109840:	50                   	push   %eax
80109841:	e8 bc 00 00 00       	call   80109902 <arp_table_search>
80109846:	83 c4 10             	add    $0x10,%esp
80109849:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010984c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109850:	78 2d                	js     8010987f <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109852:	8b 45 08             	mov    0x8(%ebp),%eax
80109855:	8d 48 08             	lea    0x8(%eax),%ecx
80109858:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010985b:	89 d0                	mov    %edx,%eax
8010985d:	c1 e0 02             	shl    $0x2,%eax
80109860:	01 d0                	add    %edx,%eax
80109862:	01 c0                	add    %eax,%eax
80109864:	01 d0                	add    %edx,%eax
80109866:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010986b:	83 c0 04             	add    $0x4,%eax
8010986e:	83 ec 04             	sub    $0x4,%esp
80109871:	6a 06                	push   $0x6
80109873:	51                   	push   %ecx
80109874:	50                   	push   %eax
80109875:	e8 b8 b7 ff ff       	call   80105032 <memmove>
8010987a:	83 c4 10             	add    $0x10,%esp
8010987d:	eb 70                	jmp    801098ef <arp_table_update+0xc2>
  }else{
    index += 1;
8010987f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109883:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109886:	8b 45 08             	mov    0x8(%ebp),%eax
80109889:	8d 48 08             	lea    0x8(%eax),%ecx
8010988c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010988f:	89 d0                	mov    %edx,%eax
80109891:	c1 e0 02             	shl    $0x2,%eax
80109894:	01 d0                	add    %edx,%eax
80109896:	01 c0                	add    %eax,%eax
80109898:	01 d0                	add    %edx,%eax
8010989a:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010989f:	83 c0 04             	add    $0x4,%eax
801098a2:	83 ec 04             	sub    $0x4,%esp
801098a5:	6a 06                	push   $0x6
801098a7:	51                   	push   %ecx
801098a8:	50                   	push   %eax
801098a9:	e8 84 b7 ff ff       	call   80105032 <memmove>
801098ae:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
801098b1:	8b 45 08             	mov    0x8(%ebp),%eax
801098b4:	8d 48 0e             	lea    0xe(%eax),%ecx
801098b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801098ba:	89 d0                	mov    %edx,%eax
801098bc:	c1 e0 02             	shl    $0x2,%eax
801098bf:	01 d0                	add    %edx,%eax
801098c1:	01 c0                	add    %eax,%eax
801098c3:	01 d0                	add    %edx,%eax
801098c5:	05 80 d0 18 80       	add    $0x8018d080,%eax
801098ca:	83 ec 04             	sub    $0x4,%esp
801098cd:	6a 04                	push   $0x4
801098cf:	51                   	push   %ecx
801098d0:	50                   	push   %eax
801098d1:	e8 5c b7 ff ff       	call   80105032 <memmove>
801098d6:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801098d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801098dc:	89 d0                	mov    %edx,%eax
801098de:	c1 e0 02             	shl    $0x2,%eax
801098e1:	01 d0                	add    %edx,%eax
801098e3:	01 c0                	add    %eax,%eax
801098e5:	01 d0                	add    %edx,%eax
801098e7:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801098ec:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801098ef:	83 ec 0c             	sub    $0xc,%esp
801098f2:	68 80 d0 18 80       	push   $0x8018d080
801098f7:	e8 87 00 00 00       	call   80109983 <print_arp_table>
801098fc:	83 c4 10             	add    $0x10,%esp
}
801098ff:	90                   	nop
80109900:	c9                   	leave  
80109901:	c3                   	ret    

80109902 <arp_table_search>:

int arp_table_search(uchar *ip){
80109902:	f3 0f 1e fb          	endbr32 
80109906:	55                   	push   %ebp
80109907:	89 e5                	mov    %esp,%ebp
80109909:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010990c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109913:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010991a:	eb 59                	jmp    80109975 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010991c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010991f:	89 d0                	mov    %edx,%eax
80109921:	c1 e0 02             	shl    $0x2,%eax
80109924:	01 d0                	add    %edx,%eax
80109926:	01 c0                	add    %eax,%eax
80109928:	01 d0                	add    %edx,%eax
8010992a:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010992f:	83 ec 04             	sub    $0x4,%esp
80109932:	6a 04                	push   $0x4
80109934:	ff 75 08             	pushl  0x8(%ebp)
80109937:	50                   	push   %eax
80109938:	e8 99 b6 ff ff       	call   80104fd6 <memcmp>
8010993d:	83 c4 10             	add    $0x10,%esp
80109940:	85 c0                	test   %eax,%eax
80109942:	75 05                	jne    80109949 <arp_table_search+0x47>
      return i;
80109944:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109947:	eb 38                	jmp    80109981 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109949:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010994c:	89 d0                	mov    %edx,%eax
8010994e:	c1 e0 02             	shl    $0x2,%eax
80109951:	01 d0                	add    %edx,%eax
80109953:	01 c0                	add    %eax,%eax
80109955:	01 d0                	add    %edx,%eax
80109957:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010995c:	0f b6 00             	movzbl (%eax),%eax
8010995f:	84 c0                	test   %al,%al
80109961:	75 0e                	jne    80109971 <arp_table_search+0x6f>
80109963:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109967:	75 08                	jne    80109971 <arp_table_search+0x6f>
      empty = -i;
80109969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010996c:	f7 d8                	neg    %eax
8010996e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109971:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109975:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109979:	7e a1                	jle    8010991c <arp_table_search+0x1a>
    }
  }
  return empty-1;
8010997b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010997e:	83 e8 01             	sub    $0x1,%eax
}
80109981:	c9                   	leave  
80109982:	c3                   	ret    

80109983 <print_arp_table>:

void print_arp_table(){
80109983:	f3 0f 1e fb          	endbr32 
80109987:	55                   	push   %ebp
80109988:	89 e5                	mov    %esp,%ebp
8010998a:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010998d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109994:	e9 92 00 00 00       	jmp    80109a2b <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109999:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010999c:	89 d0                	mov    %edx,%eax
8010999e:	c1 e0 02             	shl    $0x2,%eax
801099a1:	01 d0                	add    %edx,%eax
801099a3:	01 c0                	add    %eax,%eax
801099a5:	01 d0                	add    %edx,%eax
801099a7:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801099ac:	0f b6 00             	movzbl (%eax),%eax
801099af:	84 c0                	test   %al,%al
801099b1:	74 74                	je     80109a27 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
801099b3:	83 ec 08             	sub    $0x8,%esp
801099b6:	ff 75 f4             	pushl  -0xc(%ebp)
801099b9:	68 ef c9 10 80       	push   $0x8010c9ef
801099be:	e8 49 6a ff ff       	call   8010040c <cprintf>
801099c3:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801099c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099c9:	89 d0                	mov    %edx,%eax
801099cb:	c1 e0 02             	shl    $0x2,%eax
801099ce:	01 d0                	add    %edx,%eax
801099d0:	01 c0                	add    %eax,%eax
801099d2:	01 d0                	add    %edx,%eax
801099d4:	05 80 d0 18 80       	add    $0x8018d080,%eax
801099d9:	83 ec 0c             	sub    $0xc,%esp
801099dc:	50                   	push   %eax
801099dd:	e8 5c 02 00 00       	call   80109c3e <print_ipv4>
801099e2:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801099e5:	83 ec 0c             	sub    $0xc,%esp
801099e8:	68 fe c9 10 80       	push   $0x8010c9fe
801099ed:	e8 1a 6a ff ff       	call   8010040c <cprintf>
801099f2:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801099f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099f8:	89 d0                	mov    %edx,%eax
801099fa:	c1 e0 02             	shl    $0x2,%eax
801099fd:	01 d0                	add    %edx,%eax
801099ff:	01 c0                	add    %eax,%eax
80109a01:	01 d0                	add    %edx,%eax
80109a03:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109a08:	83 c0 04             	add    $0x4,%eax
80109a0b:	83 ec 0c             	sub    $0xc,%esp
80109a0e:	50                   	push   %eax
80109a0f:	e8 7c 02 00 00       	call   80109c90 <print_mac>
80109a14:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109a17:	83 ec 0c             	sub    $0xc,%esp
80109a1a:	68 00 ca 10 80       	push   $0x8010ca00
80109a1f:	e8 e8 69 ff ff       	call   8010040c <cprintf>
80109a24:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109a27:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109a2b:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109a2f:	0f 8e 64 ff ff ff    	jle    80109999 <print_arp_table+0x16>
    }
  }
}
80109a35:	90                   	nop
80109a36:	90                   	nop
80109a37:	c9                   	leave  
80109a38:	c3                   	ret    

80109a39 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109a39:	f3 0f 1e fb          	endbr32 
80109a3d:	55                   	push   %ebp
80109a3e:	89 e5                	mov    %esp,%ebp
80109a40:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109a43:	8b 45 10             	mov    0x10(%ebp),%eax
80109a46:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a55:	83 c0 0e             	add    $0xe,%eax
80109a58:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a5e:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a65:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109a69:	8b 45 08             	mov    0x8(%ebp),%eax
80109a6c:	8d 50 08             	lea    0x8(%eax),%edx
80109a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a72:	83 ec 04             	sub    $0x4,%esp
80109a75:	6a 06                	push   $0x6
80109a77:	52                   	push   %edx
80109a78:	50                   	push   %eax
80109a79:	e8 b4 b5 ff ff       	call   80105032 <memmove>
80109a7e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a84:	83 c0 06             	add    $0x6,%eax
80109a87:	83 ec 04             	sub    $0x4,%esp
80109a8a:	6a 06                	push   $0x6
80109a8c:	68 68 d0 18 80       	push   $0x8018d068
80109a91:	50                   	push   %eax
80109a92:	e8 9b b5 ff ff       	call   80105032 <memmove>
80109a97:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a9d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aa5:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aae:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ab5:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109abc:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac5:	8d 50 08             	lea    0x8(%eax),%edx
80109ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109acb:	83 c0 12             	add    $0x12,%eax
80109ace:	83 ec 04             	sub    $0x4,%esp
80109ad1:	6a 06                	push   $0x6
80109ad3:	52                   	push   %edx
80109ad4:	50                   	push   %eax
80109ad5:	e8 58 b5 ff ff       	call   80105032 <memmove>
80109ada:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109add:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae0:	8d 50 0e             	lea    0xe(%eax),%edx
80109ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ae6:	83 c0 18             	add    $0x18,%eax
80109ae9:	83 ec 04             	sub    $0x4,%esp
80109aec:	6a 04                	push   $0x4
80109aee:	52                   	push   %edx
80109aef:	50                   	push   %eax
80109af0:	e8 3d b5 ff ff       	call   80105032 <memmove>
80109af5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109af8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109afb:	83 c0 08             	add    $0x8,%eax
80109afe:	83 ec 04             	sub    $0x4,%esp
80109b01:	6a 06                	push   $0x6
80109b03:	68 68 d0 18 80       	push   $0x8018d068
80109b08:	50                   	push   %eax
80109b09:	e8 24 b5 ff ff       	call   80105032 <memmove>
80109b0e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b14:	83 c0 0e             	add    $0xe,%eax
80109b17:	83 ec 04             	sub    $0x4,%esp
80109b1a:	6a 04                	push   $0x4
80109b1c:	68 04 f5 10 80       	push   $0x8010f504
80109b21:	50                   	push   %eax
80109b22:	e8 0b b5 ff ff       	call   80105032 <memmove>
80109b27:	83 c4 10             	add    $0x10,%esp
}
80109b2a:	90                   	nop
80109b2b:	c9                   	leave  
80109b2c:	c3                   	ret    

80109b2d <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109b2d:	f3 0f 1e fb          	endbr32 
80109b31:	55                   	push   %ebp
80109b32:	89 e5                	mov    %esp,%ebp
80109b34:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109b37:	83 ec 0c             	sub    $0xc,%esp
80109b3a:	68 02 ca 10 80       	push   $0x8010ca02
80109b3f:	e8 c8 68 ff ff       	call   8010040c <cprintf>
80109b44:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109b47:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4a:	83 c0 0e             	add    $0xe,%eax
80109b4d:	83 ec 0c             	sub    $0xc,%esp
80109b50:	50                   	push   %eax
80109b51:	e8 e8 00 00 00       	call   80109c3e <print_ipv4>
80109b56:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b59:	83 ec 0c             	sub    $0xc,%esp
80109b5c:	68 00 ca 10 80       	push   $0x8010ca00
80109b61:	e8 a6 68 ff ff       	call   8010040c <cprintf>
80109b66:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109b69:	8b 45 08             	mov    0x8(%ebp),%eax
80109b6c:	83 c0 08             	add    $0x8,%eax
80109b6f:	83 ec 0c             	sub    $0xc,%esp
80109b72:	50                   	push   %eax
80109b73:	e8 18 01 00 00       	call   80109c90 <print_mac>
80109b78:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b7b:	83 ec 0c             	sub    $0xc,%esp
80109b7e:	68 00 ca 10 80       	push   $0x8010ca00
80109b83:	e8 84 68 ff ff       	call   8010040c <cprintf>
80109b88:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109b8b:	83 ec 0c             	sub    $0xc,%esp
80109b8e:	68 19 ca 10 80       	push   $0x8010ca19
80109b93:	e8 74 68 ff ff       	call   8010040c <cprintf>
80109b98:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b9e:	83 c0 18             	add    $0x18,%eax
80109ba1:	83 ec 0c             	sub    $0xc,%esp
80109ba4:	50                   	push   %eax
80109ba5:	e8 94 00 00 00       	call   80109c3e <print_ipv4>
80109baa:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109bad:	83 ec 0c             	sub    $0xc,%esp
80109bb0:	68 00 ca 10 80       	push   $0x8010ca00
80109bb5:	e8 52 68 ff ff       	call   8010040c <cprintf>
80109bba:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80109bc0:	83 c0 12             	add    $0x12,%eax
80109bc3:	83 ec 0c             	sub    $0xc,%esp
80109bc6:	50                   	push   %eax
80109bc7:	e8 c4 00 00 00       	call   80109c90 <print_mac>
80109bcc:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109bcf:	83 ec 0c             	sub    $0xc,%esp
80109bd2:	68 00 ca 10 80       	push   $0x8010ca00
80109bd7:	e8 30 68 ff ff       	call   8010040c <cprintf>
80109bdc:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109bdf:	83 ec 0c             	sub    $0xc,%esp
80109be2:	68 30 ca 10 80       	push   $0x8010ca30
80109be7:	e8 20 68 ff ff       	call   8010040c <cprintf>
80109bec:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109bef:	8b 45 08             	mov    0x8(%ebp),%eax
80109bf2:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109bf6:	66 3d 00 01          	cmp    $0x100,%ax
80109bfa:	75 12                	jne    80109c0e <print_arp_info+0xe1>
80109bfc:	83 ec 0c             	sub    $0xc,%esp
80109bff:	68 3c ca 10 80       	push   $0x8010ca3c
80109c04:	e8 03 68 ff ff       	call   8010040c <cprintf>
80109c09:	83 c4 10             	add    $0x10,%esp
80109c0c:	eb 1d                	jmp    80109c2b <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80109c11:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109c15:	66 3d 00 02          	cmp    $0x200,%ax
80109c19:	75 10                	jne    80109c2b <print_arp_info+0xfe>
    cprintf("Reply\n");
80109c1b:	83 ec 0c             	sub    $0xc,%esp
80109c1e:	68 45 ca 10 80       	push   $0x8010ca45
80109c23:	e8 e4 67 ff ff       	call   8010040c <cprintf>
80109c28:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109c2b:	83 ec 0c             	sub    $0xc,%esp
80109c2e:	68 00 ca 10 80       	push   $0x8010ca00
80109c33:	e8 d4 67 ff ff       	call   8010040c <cprintf>
80109c38:	83 c4 10             	add    $0x10,%esp
}
80109c3b:	90                   	nop
80109c3c:	c9                   	leave  
80109c3d:	c3                   	ret    

80109c3e <print_ipv4>:

void print_ipv4(uchar *ip){
80109c3e:	f3 0f 1e fb          	endbr32 
80109c42:	55                   	push   %ebp
80109c43:	89 e5                	mov    %esp,%ebp
80109c45:	53                   	push   %ebx
80109c46:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109c49:	8b 45 08             	mov    0x8(%ebp),%eax
80109c4c:	83 c0 03             	add    $0x3,%eax
80109c4f:	0f b6 00             	movzbl (%eax),%eax
80109c52:	0f b6 d8             	movzbl %al,%ebx
80109c55:	8b 45 08             	mov    0x8(%ebp),%eax
80109c58:	83 c0 02             	add    $0x2,%eax
80109c5b:	0f b6 00             	movzbl (%eax),%eax
80109c5e:	0f b6 c8             	movzbl %al,%ecx
80109c61:	8b 45 08             	mov    0x8(%ebp),%eax
80109c64:	83 c0 01             	add    $0x1,%eax
80109c67:	0f b6 00             	movzbl (%eax),%eax
80109c6a:	0f b6 d0             	movzbl %al,%edx
80109c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80109c70:	0f b6 00             	movzbl (%eax),%eax
80109c73:	0f b6 c0             	movzbl %al,%eax
80109c76:	83 ec 0c             	sub    $0xc,%esp
80109c79:	53                   	push   %ebx
80109c7a:	51                   	push   %ecx
80109c7b:	52                   	push   %edx
80109c7c:	50                   	push   %eax
80109c7d:	68 4c ca 10 80       	push   $0x8010ca4c
80109c82:	e8 85 67 ff ff       	call   8010040c <cprintf>
80109c87:	83 c4 20             	add    $0x20,%esp
}
80109c8a:	90                   	nop
80109c8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c8e:	c9                   	leave  
80109c8f:	c3                   	ret    

80109c90 <print_mac>:

void print_mac(uchar *mac){
80109c90:	f3 0f 1e fb          	endbr32 
80109c94:	55                   	push   %ebp
80109c95:	89 e5                	mov    %esp,%ebp
80109c97:	57                   	push   %edi
80109c98:	56                   	push   %esi
80109c99:	53                   	push   %ebx
80109c9a:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca0:	83 c0 05             	add    $0x5,%eax
80109ca3:	0f b6 00             	movzbl (%eax),%eax
80109ca6:	0f b6 f8             	movzbl %al,%edi
80109ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80109cac:	83 c0 04             	add    $0x4,%eax
80109caf:	0f b6 00             	movzbl (%eax),%eax
80109cb2:	0f b6 f0             	movzbl %al,%esi
80109cb5:	8b 45 08             	mov    0x8(%ebp),%eax
80109cb8:	83 c0 03             	add    $0x3,%eax
80109cbb:	0f b6 00             	movzbl (%eax),%eax
80109cbe:	0f b6 d8             	movzbl %al,%ebx
80109cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80109cc4:	83 c0 02             	add    $0x2,%eax
80109cc7:	0f b6 00             	movzbl (%eax),%eax
80109cca:	0f b6 c8             	movzbl %al,%ecx
80109ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80109cd0:	83 c0 01             	add    $0x1,%eax
80109cd3:	0f b6 00             	movzbl (%eax),%eax
80109cd6:	0f b6 d0             	movzbl %al,%edx
80109cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80109cdc:	0f b6 00             	movzbl (%eax),%eax
80109cdf:	0f b6 c0             	movzbl %al,%eax
80109ce2:	83 ec 04             	sub    $0x4,%esp
80109ce5:	57                   	push   %edi
80109ce6:	56                   	push   %esi
80109ce7:	53                   	push   %ebx
80109ce8:	51                   	push   %ecx
80109ce9:	52                   	push   %edx
80109cea:	50                   	push   %eax
80109ceb:	68 64 ca 10 80       	push   $0x8010ca64
80109cf0:	e8 17 67 ff ff       	call   8010040c <cprintf>
80109cf5:	83 c4 20             	add    $0x20,%esp
}
80109cf8:	90                   	nop
80109cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109cfc:	5b                   	pop    %ebx
80109cfd:	5e                   	pop    %esi
80109cfe:	5f                   	pop    %edi
80109cff:	5d                   	pop    %ebp
80109d00:	c3                   	ret    

80109d01 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109d01:	f3 0f 1e fb          	endbr32 
80109d05:	55                   	push   %ebp
80109d06:	89 e5                	mov    %esp,%ebp
80109d08:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80109d0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109d11:	8b 45 08             	mov    0x8(%ebp),%eax
80109d14:	83 c0 0e             	add    $0xe,%eax
80109d17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d1d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109d21:	3c 08                	cmp    $0x8,%al
80109d23:	75 1b                	jne    80109d40 <eth_proc+0x3f>
80109d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d28:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d2c:	3c 06                	cmp    $0x6,%al
80109d2e:	75 10                	jne    80109d40 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109d30:	83 ec 0c             	sub    $0xc,%esp
80109d33:	ff 75 f0             	pushl  -0x10(%ebp)
80109d36:	e8 d5 f7 ff ff       	call   80109510 <arp_proc>
80109d3b:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109d3e:	eb 24                	jmp    80109d64 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d43:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109d47:	3c 08                	cmp    $0x8,%al
80109d49:	75 19                	jne    80109d64 <eth_proc+0x63>
80109d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d4e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d52:	84 c0                	test   %al,%al
80109d54:	75 0e                	jne    80109d64 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109d56:	83 ec 0c             	sub    $0xc,%esp
80109d59:	ff 75 08             	pushl  0x8(%ebp)
80109d5c:	e8 b3 00 00 00       	call   80109e14 <ipv4_proc>
80109d61:	83 c4 10             	add    $0x10,%esp
}
80109d64:	90                   	nop
80109d65:	c9                   	leave  
80109d66:	c3                   	ret    

80109d67 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109d67:	f3 0f 1e fb          	endbr32 
80109d6b:	55                   	push   %ebp
80109d6c:	89 e5                	mov    %esp,%ebp
80109d6e:	83 ec 04             	sub    $0x4,%esp
80109d71:	8b 45 08             	mov    0x8(%ebp),%eax
80109d74:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109d78:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d7c:	c1 e0 08             	shl    $0x8,%eax
80109d7f:	89 c2                	mov    %eax,%edx
80109d81:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d85:	66 c1 e8 08          	shr    $0x8,%ax
80109d89:	01 d0                	add    %edx,%eax
}
80109d8b:	c9                   	leave  
80109d8c:	c3                   	ret    

80109d8d <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109d8d:	f3 0f 1e fb          	endbr32 
80109d91:	55                   	push   %ebp
80109d92:	89 e5                	mov    %esp,%ebp
80109d94:	83 ec 04             	sub    $0x4,%esp
80109d97:	8b 45 08             	mov    0x8(%ebp),%eax
80109d9a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109d9e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109da2:	c1 e0 08             	shl    $0x8,%eax
80109da5:	89 c2                	mov    %eax,%edx
80109da7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109dab:	66 c1 e8 08          	shr    $0x8,%ax
80109daf:	01 d0                	add    %edx,%eax
}
80109db1:	c9                   	leave  
80109db2:	c3                   	ret    

80109db3 <H2N_uint>:

uint H2N_uint(uint value){
80109db3:	f3 0f 1e fb          	endbr32 
80109db7:	55                   	push   %ebp
80109db8:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109dba:	8b 45 08             	mov    0x8(%ebp),%eax
80109dbd:	c1 e0 18             	shl    $0x18,%eax
80109dc0:	25 00 00 00 0f       	and    $0xf000000,%eax
80109dc5:	89 c2                	mov    %eax,%edx
80109dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80109dca:	c1 e0 08             	shl    $0x8,%eax
80109dcd:	25 00 f0 00 00       	and    $0xf000,%eax
80109dd2:	09 c2                	or     %eax,%edx
80109dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80109dd7:	c1 e8 08             	shr    $0x8,%eax
80109dda:	83 e0 0f             	and    $0xf,%eax
80109ddd:	01 d0                	add    %edx,%eax
}
80109ddf:	5d                   	pop    %ebp
80109de0:	c3                   	ret    

80109de1 <N2H_uint>:

uint N2H_uint(uint value){
80109de1:	f3 0f 1e fb          	endbr32 
80109de5:	55                   	push   %ebp
80109de6:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109de8:	8b 45 08             	mov    0x8(%ebp),%eax
80109deb:	c1 e0 18             	shl    $0x18,%eax
80109dee:	89 c2                	mov    %eax,%edx
80109df0:	8b 45 08             	mov    0x8(%ebp),%eax
80109df3:	c1 e0 08             	shl    $0x8,%eax
80109df6:	25 00 00 ff 00       	and    $0xff0000,%eax
80109dfb:	01 c2                	add    %eax,%edx
80109dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80109e00:	c1 e8 08             	shr    $0x8,%eax
80109e03:	25 00 ff 00 00       	and    $0xff00,%eax
80109e08:	01 c2                	add    %eax,%edx
80109e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80109e0d:	c1 e8 18             	shr    $0x18,%eax
80109e10:	01 d0                	add    %edx,%eax
}
80109e12:	5d                   	pop    %ebp
80109e13:	c3                   	ret    

80109e14 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109e14:	f3 0f 1e fb          	endbr32 
80109e18:	55                   	push   %ebp
80109e19:	89 e5                	mov    %esp,%ebp
80109e1b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109e1e:	8b 45 08             	mov    0x8(%ebp),%eax
80109e21:	83 c0 0e             	add    $0xe,%eax
80109e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e2a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109e2e:	0f b7 d0             	movzwl %ax,%edx
80109e31:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109e36:	39 c2                	cmp    %eax,%edx
80109e38:	74 60                	je     80109e9a <ipv4_proc+0x86>
80109e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e3d:	83 c0 0c             	add    $0xc,%eax
80109e40:	83 ec 04             	sub    $0x4,%esp
80109e43:	6a 04                	push   $0x4
80109e45:	50                   	push   %eax
80109e46:	68 04 f5 10 80       	push   $0x8010f504
80109e4b:	e8 86 b1 ff ff       	call   80104fd6 <memcmp>
80109e50:	83 c4 10             	add    $0x10,%esp
80109e53:	85 c0                	test   %eax,%eax
80109e55:	74 43                	je     80109e9a <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e5a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109e5e:	0f b7 c0             	movzwl %ax,%eax
80109e61:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e69:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109e6d:	3c 01                	cmp    $0x1,%al
80109e6f:	75 10                	jne    80109e81 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109e71:	83 ec 0c             	sub    $0xc,%esp
80109e74:	ff 75 08             	pushl  0x8(%ebp)
80109e77:	e8 a7 00 00 00       	call   80109f23 <icmp_proc>
80109e7c:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109e7f:	eb 19                	jmp    80109e9a <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e84:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109e88:	3c 06                	cmp    $0x6,%al
80109e8a:	75 0e                	jne    80109e9a <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109e8c:	83 ec 0c             	sub    $0xc,%esp
80109e8f:	ff 75 08             	pushl  0x8(%ebp)
80109e92:	e8 c7 03 00 00       	call   8010a25e <tcp_proc>
80109e97:	83 c4 10             	add    $0x10,%esp
}
80109e9a:	90                   	nop
80109e9b:	c9                   	leave  
80109e9c:	c3                   	ret    

80109e9d <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109e9d:	f3 0f 1e fb          	endbr32 
80109ea1:	55                   	push   %ebp
80109ea2:	89 e5                	mov    %esp,%ebp
80109ea4:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80109eaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eb0:	0f b6 00             	movzbl (%eax),%eax
80109eb3:	83 e0 0f             	and    $0xf,%eax
80109eb6:	01 c0                	add    %eax,%eax
80109eb8:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109ebb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109ec2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109ec9:	eb 48                	jmp    80109f13 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109ecb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ece:	01 c0                	add    %eax,%eax
80109ed0:	89 c2                	mov    %eax,%edx
80109ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ed5:	01 d0                	add    %edx,%eax
80109ed7:	0f b6 00             	movzbl (%eax),%eax
80109eda:	0f b6 c0             	movzbl %al,%eax
80109edd:	c1 e0 08             	shl    $0x8,%eax
80109ee0:	89 c2                	mov    %eax,%edx
80109ee2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ee5:	01 c0                	add    %eax,%eax
80109ee7:	8d 48 01             	lea    0x1(%eax),%ecx
80109eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eed:	01 c8                	add    %ecx,%eax
80109eef:	0f b6 00             	movzbl (%eax),%eax
80109ef2:	0f b6 c0             	movzbl %al,%eax
80109ef5:	01 d0                	add    %edx,%eax
80109ef7:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109efa:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109f01:	76 0c                	jbe    80109f0f <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109f03:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f06:	0f b7 c0             	movzwl %ax,%eax
80109f09:	83 c0 01             	add    $0x1,%eax
80109f0c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109f0f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109f13:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109f17:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109f1a:	7c af                	jl     80109ecb <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109f1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109f1f:	f7 d0                	not    %eax
}
80109f21:	c9                   	leave  
80109f22:	c3                   	ret    

80109f23 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109f23:	f3 0f 1e fb          	endbr32 
80109f27:	55                   	push   %ebp
80109f28:	89 e5                	mov    %esp,%ebp
80109f2a:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109f2d:	8b 45 08             	mov    0x8(%ebp),%eax
80109f30:	83 c0 0e             	add    $0xe,%eax
80109f33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f39:	0f b6 00             	movzbl (%eax),%eax
80109f3c:	0f b6 c0             	movzbl %al,%eax
80109f3f:	83 e0 0f             	and    $0xf,%eax
80109f42:	c1 e0 02             	shl    $0x2,%eax
80109f45:	89 c2                	mov    %eax,%edx
80109f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f4a:	01 d0                	add    %edx,%eax
80109f4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f52:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109f56:	84 c0                	test   %al,%al
80109f58:	75 4f                	jne    80109fa9 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f5d:	0f b6 00             	movzbl (%eax),%eax
80109f60:	3c 08                	cmp    $0x8,%al
80109f62:	75 45                	jne    80109fa9 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109f64:	e8 1b 89 ff ff       	call   80102884 <kalloc>
80109f69:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109f6c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109f73:	83 ec 04             	sub    $0x4,%esp
80109f76:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109f79:	50                   	push   %eax
80109f7a:	ff 75 ec             	pushl  -0x14(%ebp)
80109f7d:	ff 75 08             	pushl  0x8(%ebp)
80109f80:	e8 7c 00 00 00       	call   8010a001 <icmp_reply_pkt_create>
80109f85:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109f88:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f8b:	83 ec 08             	sub    $0x8,%esp
80109f8e:	50                   	push   %eax
80109f8f:	ff 75 ec             	pushl  -0x14(%ebp)
80109f92:	e8 43 f4 ff ff       	call   801093da <i8254_send>
80109f97:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109f9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f9d:	83 ec 0c             	sub    $0xc,%esp
80109fa0:	50                   	push   %eax
80109fa1:	e8 40 88 ff ff       	call   801027e6 <kfree>
80109fa6:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109fa9:	90                   	nop
80109faa:	c9                   	leave  
80109fab:	c3                   	ret    

80109fac <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109fac:	f3 0f 1e fb          	endbr32 
80109fb0:	55                   	push   %ebp
80109fb1:	89 e5                	mov    %esp,%ebp
80109fb3:	53                   	push   %ebx
80109fb4:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109fb7:	8b 45 08             	mov    0x8(%ebp),%eax
80109fba:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109fbe:	0f b7 c0             	movzwl %ax,%eax
80109fc1:	83 ec 0c             	sub    $0xc,%esp
80109fc4:	50                   	push   %eax
80109fc5:	e8 9d fd ff ff       	call   80109d67 <N2H_ushort>
80109fca:	83 c4 10             	add    $0x10,%esp
80109fcd:	0f b7 d8             	movzwl %ax,%ebx
80109fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109fd7:	0f b7 c0             	movzwl %ax,%eax
80109fda:	83 ec 0c             	sub    $0xc,%esp
80109fdd:	50                   	push   %eax
80109fde:	e8 84 fd ff ff       	call   80109d67 <N2H_ushort>
80109fe3:	83 c4 10             	add    $0x10,%esp
80109fe6:	0f b7 c0             	movzwl %ax,%eax
80109fe9:	83 ec 04             	sub    $0x4,%esp
80109fec:	53                   	push   %ebx
80109fed:	50                   	push   %eax
80109fee:	68 83 ca 10 80       	push   $0x8010ca83
80109ff3:	e8 14 64 ff ff       	call   8010040c <cprintf>
80109ff8:	83 c4 10             	add    $0x10,%esp
}
80109ffb:	90                   	nop
80109ffc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109fff:	c9                   	leave  
8010a000:	c3                   	ret    

8010a001 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a001:	f3 0f 1e fb          	endbr32 
8010a005:	55                   	push   %ebp
8010a006:	89 e5                	mov    %esp,%ebp
8010a008:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a00b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a00e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a011:	8b 45 08             	mov    0x8(%ebp),%eax
8010a014:	83 c0 0e             	add    $0xe,%eax
8010a017:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a01a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a01d:	0f b6 00             	movzbl (%eax),%eax
8010a020:	0f b6 c0             	movzbl %al,%eax
8010a023:	83 e0 0f             	and    $0xf,%eax
8010a026:	c1 e0 02             	shl    $0x2,%eax
8010a029:	89 c2                	mov    %eax,%edx
8010a02b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a02e:	01 d0                	add    %edx,%eax
8010a030:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a033:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a036:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a039:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a03c:	83 c0 0e             	add    $0xe,%eax
8010a03f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a042:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a045:	83 c0 14             	add    $0x14,%eax
8010a048:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a04b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a04e:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a054:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a057:	8d 50 06             	lea    0x6(%eax),%edx
8010a05a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a05d:	83 ec 04             	sub    $0x4,%esp
8010a060:	6a 06                	push   $0x6
8010a062:	52                   	push   %edx
8010a063:	50                   	push   %eax
8010a064:	e8 c9 af ff ff       	call   80105032 <memmove>
8010a069:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a06c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a06f:	83 c0 06             	add    $0x6,%eax
8010a072:	83 ec 04             	sub    $0x4,%esp
8010a075:	6a 06                	push   $0x6
8010a077:	68 68 d0 18 80       	push   $0x8018d068
8010a07c:	50                   	push   %eax
8010a07d:	e8 b0 af ff ff       	call   80105032 <memmove>
8010a082:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a085:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a088:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a08c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a08f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a093:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a096:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a099:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a09c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a0a0:	83 ec 0c             	sub    $0xc,%esp
8010a0a3:	6a 54                	push   $0x54
8010a0a5:	e8 e3 fc ff ff       	call   80109d8d <H2N_ushort>
8010a0aa:	83 c4 10             	add    $0x10,%esp
8010a0ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0b0:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a0b4:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a0bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0be:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a0c2:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a0c9:	83 c0 01             	add    $0x1,%eax
8010a0cc:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a0d2:	83 ec 0c             	sub    $0xc,%esp
8010a0d5:	68 00 40 00 00       	push   $0x4000
8010a0da:	e8 ae fc ff ff       	call   80109d8d <H2N_ushort>
8010a0df:	83 c4 10             	add    $0x10,%esp
8010a0e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0e5:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a0e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0ec:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a0f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0f3:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a0f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0fa:	83 c0 0c             	add    $0xc,%eax
8010a0fd:	83 ec 04             	sub    $0x4,%esp
8010a100:	6a 04                	push   $0x4
8010a102:	68 04 f5 10 80       	push   $0x8010f504
8010a107:	50                   	push   %eax
8010a108:	e8 25 af ff ff       	call   80105032 <memmove>
8010a10d:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a110:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a113:	8d 50 0c             	lea    0xc(%eax),%edx
8010a116:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a119:	83 c0 10             	add    $0x10,%eax
8010a11c:	83 ec 04             	sub    $0x4,%esp
8010a11f:	6a 04                	push   $0x4
8010a121:	52                   	push   %edx
8010a122:	50                   	push   %eax
8010a123:	e8 0a af ff ff       	call   80105032 <memmove>
8010a128:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a12b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a12e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a134:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a137:	83 ec 0c             	sub    $0xc,%esp
8010a13a:	50                   	push   %eax
8010a13b:	e8 5d fd ff ff       	call   80109e9d <ipv4_chksum>
8010a140:	83 c4 10             	add    $0x10,%esp
8010a143:	0f b7 c0             	movzwl %ax,%eax
8010a146:	83 ec 0c             	sub    $0xc,%esp
8010a149:	50                   	push   %eax
8010a14a:	e8 3e fc ff ff       	call   80109d8d <H2N_ushort>
8010a14f:	83 c4 10             	add    $0x10,%esp
8010a152:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a155:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a159:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a15c:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a15f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a162:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a166:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a169:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a16d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a170:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a174:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a177:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a17b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a17e:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a182:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a185:	8d 50 08             	lea    0x8(%eax),%edx
8010a188:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a18b:	83 c0 08             	add    $0x8,%eax
8010a18e:	83 ec 04             	sub    $0x4,%esp
8010a191:	6a 08                	push   $0x8
8010a193:	52                   	push   %edx
8010a194:	50                   	push   %eax
8010a195:	e8 98 ae ff ff       	call   80105032 <memmove>
8010a19a:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a19d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1a0:	8d 50 10             	lea    0x10(%eax),%edx
8010a1a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1a6:	83 c0 10             	add    $0x10,%eax
8010a1a9:	83 ec 04             	sub    $0x4,%esp
8010a1ac:	6a 30                	push   $0x30
8010a1ae:	52                   	push   %edx
8010a1af:	50                   	push   %eax
8010a1b0:	e8 7d ae ff ff       	call   80105032 <memmove>
8010a1b5:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a1b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1bb:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a1c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1c4:	83 ec 0c             	sub    $0xc,%esp
8010a1c7:	50                   	push   %eax
8010a1c8:	e8 1c 00 00 00       	call   8010a1e9 <icmp_chksum>
8010a1cd:	83 c4 10             	add    $0x10,%esp
8010a1d0:	0f b7 c0             	movzwl %ax,%eax
8010a1d3:	83 ec 0c             	sub    $0xc,%esp
8010a1d6:	50                   	push   %eax
8010a1d7:	e8 b1 fb ff ff       	call   80109d8d <H2N_ushort>
8010a1dc:	83 c4 10             	add    $0x10,%esp
8010a1df:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1e2:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a1e6:	90                   	nop
8010a1e7:	c9                   	leave  
8010a1e8:	c3                   	ret    

8010a1e9 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a1e9:	f3 0f 1e fb          	endbr32 
8010a1ed:	55                   	push   %ebp
8010a1ee:	89 e5                	mov    %esp,%ebp
8010a1f0:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a1f3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a1f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a200:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a207:	eb 48                	jmp    8010a251 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a209:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a20c:	01 c0                	add    %eax,%eax
8010a20e:	89 c2                	mov    %eax,%edx
8010a210:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a213:	01 d0                	add    %edx,%eax
8010a215:	0f b6 00             	movzbl (%eax),%eax
8010a218:	0f b6 c0             	movzbl %al,%eax
8010a21b:	c1 e0 08             	shl    $0x8,%eax
8010a21e:	89 c2                	mov    %eax,%edx
8010a220:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a223:	01 c0                	add    %eax,%eax
8010a225:	8d 48 01             	lea    0x1(%eax),%ecx
8010a228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a22b:	01 c8                	add    %ecx,%eax
8010a22d:	0f b6 00             	movzbl (%eax),%eax
8010a230:	0f b6 c0             	movzbl %al,%eax
8010a233:	01 d0                	add    %edx,%eax
8010a235:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a238:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a23f:	76 0c                	jbe    8010a24d <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a241:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a244:	0f b7 c0             	movzwl %ax,%eax
8010a247:	83 c0 01             	add    $0x1,%eax
8010a24a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a24d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a251:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a255:	7e b2                	jle    8010a209 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a257:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a25a:	f7 d0                	not    %eax
}
8010a25c:	c9                   	leave  
8010a25d:	c3                   	ret    

8010a25e <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a25e:	f3 0f 1e fb          	endbr32 
8010a262:	55                   	push   %ebp
8010a263:	89 e5                	mov    %esp,%ebp
8010a265:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a268:	8b 45 08             	mov    0x8(%ebp),%eax
8010a26b:	83 c0 0e             	add    $0xe,%eax
8010a26e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a271:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a274:	0f b6 00             	movzbl (%eax),%eax
8010a277:	0f b6 c0             	movzbl %al,%eax
8010a27a:	83 e0 0f             	and    $0xf,%eax
8010a27d:	c1 e0 02             	shl    $0x2,%eax
8010a280:	89 c2                	mov    %eax,%edx
8010a282:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a285:	01 d0                	add    %edx,%eax
8010a287:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a28a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a28d:	83 c0 14             	add    $0x14,%eax
8010a290:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a293:	e8 ec 85 ff ff       	call   80102884 <kalloc>
8010a298:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a29b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a2a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2a5:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a2a9:	0f b6 c0             	movzbl %al,%eax
8010a2ac:	83 e0 02             	and    $0x2,%eax
8010a2af:	85 c0                	test   %eax,%eax
8010a2b1:	74 3d                	je     8010a2f0 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a2b3:	83 ec 0c             	sub    $0xc,%esp
8010a2b6:	6a 00                	push   $0x0
8010a2b8:	6a 12                	push   $0x12
8010a2ba:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a2bd:	50                   	push   %eax
8010a2be:	ff 75 e8             	pushl  -0x18(%ebp)
8010a2c1:	ff 75 08             	pushl  0x8(%ebp)
8010a2c4:	e8 a2 01 00 00       	call   8010a46b <tcp_pkt_create>
8010a2c9:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a2cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a2cf:	83 ec 08             	sub    $0x8,%esp
8010a2d2:	50                   	push   %eax
8010a2d3:	ff 75 e8             	pushl  -0x18(%ebp)
8010a2d6:	e8 ff f0 ff ff       	call   801093da <i8254_send>
8010a2db:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a2de:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a2e3:	83 c0 01             	add    $0x1,%eax
8010a2e6:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a2eb:	e9 69 01 00 00       	jmp    8010a459 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a2f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2f3:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a2f7:	3c 18                	cmp    $0x18,%al
8010a2f9:	0f 85 10 01 00 00    	jne    8010a40f <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a2ff:	83 ec 04             	sub    $0x4,%esp
8010a302:	6a 03                	push   $0x3
8010a304:	68 9e ca 10 80       	push   $0x8010ca9e
8010a309:	ff 75 ec             	pushl  -0x14(%ebp)
8010a30c:	e8 c5 ac ff ff       	call   80104fd6 <memcmp>
8010a311:	83 c4 10             	add    $0x10,%esp
8010a314:	85 c0                	test   %eax,%eax
8010a316:	74 74                	je     8010a38c <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a318:	83 ec 0c             	sub    $0xc,%esp
8010a31b:	68 a2 ca 10 80       	push   $0x8010caa2
8010a320:	e8 e7 60 ff ff       	call   8010040c <cprintf>
8010a325:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a328:	83 ec 0c             	sub    $0xc,%esp
8010a32b:	6a 00                	push   $0x0
8010a32d:	6a 10                	push   $0x10
8010a32f:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a332:	50                   	push   %eax
8010a333:	ff 75 e8             	pushl  -0x18(%ebp)
8010a336:	ff 75 08             	pushl  0x8(%ebp)
8010a339:	e8 2d 01 00 00       	call   8010a46b <tcp_pkt_create>
8010a33e:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a341:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a344:	83 ec 08             	sub    $0x8,%esp
8010a347:	50                   	push   %eax
8010a348:	ff 75 e8             	pushl  -0x18(%ebp)
8010a34b:	e8 8a f0 ff ff       	call   801093da <i8254_send>
8010a350:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a353:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a356:	83 c0 36             	add    $0x36,%eax
8010a359:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a35c:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a35f:	50                   	push   %eax
8010a360:	ff 75 e0             	pushl  -0x20(%ebp)
8010a363:	6a 00                	push   $0x0
8010a365:	6a 00                	push   $0x0
8010a367:	e8 66 04 00 00       	call   8010a7d2 <http_proc>
8010a36c:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a36f:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a372:	83 ec 0c             	sub    $0xc,%esp
8010a375:	50                   	push   %eax
8010a376:	6a 18                	push   $0x18
8010a378:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a37b:	50                   	push   %eax
8010a37c:	ff 75 e8             	pushl  -0x18(%ebp)
8010a37f:	ff 75 08             	pushl  0x8(%ebp)
8010a382:	e8 e4 00 00 00       	call   8010a46b <tcp_pkt_create>
8010a387:	83 c4 20             	add    $0x20,%esp
8010a38a:	eb 62                	jmp    8010a3ee <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a38c:	83 ec 0c             	sub    $0xc,%esp
8010a38f:	6a 00                	push   $0x0
8010a391:	6a 10                	push   $0x10
8010a393:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a396:	50                   	push   %eax
8010a397:	ff 75 e8             	pushl  -0x18(%ebp)
8010a39a:	ff 75 08             	pushl  0x8(%ebp)
8010a39d:	e8 c9 00 00 00       	call   8010a46b <tcp_pkt_create>
8010a3a2:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a3a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a3a8:	83 ec 08             	sub    $0x8,%esp
8010a3ab:	50                   	push   %eax
8010a3ac:	ff 75 e8             	pushl  -0x18(%ebp)
8010a3af:	e8 26 f0 ff ff       	call   801093da <i8254_send>
8010a3b4:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a3b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a3ba:	83 c0 36             	add    $0x36,%eax
8010a3bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a3c0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a3c3:	50                   	push   %eax
8010a3c4:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a3c7:	6a 00                	push   $0x0
8010a3c9:	6a 00                	push   $0x0
8010a3cb:	e8 02 04 00 00       	call   8010a7d2 <http_proc>
8010a3d0:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a3d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a3d6:	83 ec 0c             	sub    $0xc,%esp
8010a3d9:	50                   	push   %eax
8010a3da:	6a 18                	push   $0x18
8010a3dc:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3df:	50                   	push   %eax
8010a3e0:	ff 75 e8             	pushl  -0x18(%ebp)
8010a3e3:	ff 75 08             	pushl  0x8(%ebp)
8010a3e6:	e8 80 00 00 00       	call   8010a46b <tcp_pkt_create>
8010a3eb:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a3ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a3f1:	83 ec 08             	sub    $0x8,%esp
8010a3f4:	50                   	push   %eax
8010a3f5:	ff 75 e8             	pushl  -0x18(%ebp)
8010a3f8:	e8 dd ef ff ff       	call   801093da <i8254_send>
8010a3fd:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a400:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a405:	83 c0 01             	add    $0x1,%eax
8010a408:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a40d:	eb 4a                	jmp    8010a459 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a40f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a412:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a416:	3c 10                	cmp    $0x10,%al
8010a418:	75 3f                	jne    8010a459 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a41a:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a41f:	83 f8 01             	cmp    $0x1,%eax
8010a422:	75 35                	jne    8010a459 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a424:	83 ec 0c             	sub    $0xc,%esp
8010a427:	6a 00                	push   $0x0
8010a429:	6a 01                	push   $0x1
8010a42b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a42e:	50                   	push   %eax
8010a42f:	ff 75 e8             	pushl  -0x18(%ebp)
8010a432:	ff 75 08             	pushl  0x8(%ebp)
8010a435:	e8 31 00 00 00       	call   8010a46b <tcp_pkt_create>
8010a43a:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a43d:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a440:	83 ec 08             	sub    $0x8,%esp
8010a443:	50                   	push   %eax
8010a444:	ff 75 e8             	pushl  -0x18(%ebp)
8010a447:	e8 8e ef ff ff       	call   801093da <i8254_send>
8010a44c:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a44f:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a456:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a459:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a45c:	83 ec 0c             	sub    $0xc,%esp
8010a45f:	50                   	push   %eax
8010a460:	e8 81 83 ff ff       	call   801027e6 <kfree>
8010a465:	83 c4 10             	add    $0x10,%esp
}
8010a468:	90                   	nop
8010a469:	c9                   	leave  
8010a46a:	c3                   	ret    

8010a46b <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a46b:	f3 0f 1e fb          	endbr32 
8010a46f:	55                   	push   %ebp
8010a470:	89 e5                	mov    %esp,%ebp
8010a472:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a475:	8b 45 08             	mov    0x8(%ebp),%eax
8010a478:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a47b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a47e:	83 c0 0e             	add    $0xe,%eax
8010a481:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a484:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a487:	0f b6 00             	movzbl (%eax),%eax
8010a48a:	0f b6 c0             	movzbl %al,%eax
8010a48d:	83 e0 0f             	and    $0xf,%eax
8010a490:	c1 e0 02             	shl    $0x2,%eax
8010a493:	89 c2                	mov    %eax,%edx
8010a495:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a498:	01 d0                	add    %edx,%eax
8010a49a:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a49d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a4a3:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4a6:	83 c0 0e             	add    $0xe,%eax
8010a4a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a4ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4af:	83 c0 14             	add    $0x14,%eax
8010a4b2:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a4b5:	8b 45 18             	mov    0x18(%ebp),%eax
8010a4b8:	8d 50 36             	lea    0x36(%eax),%edx
8010a4bb:	8b 45 10             	mov    0x10(%ebp),%eax
8010a4be:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a4c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4c3:	8d 50 06             	lea    0x6(%eax),%edx
8010a4c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4c9:	83 ec 04             	sub    $0x4,%esp
8010a4cc:	6a 06                	push   $0x6
8010a4ce:	52                   	push   %edx
8010a4cf:	50                   	push   %eax
8010a4d0:	e8 5d ab ff ff       	call   80105032 <memmove>
8010a4d5:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a4d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4db:	83 c0 06             	add    $0x6,%eax
8010a4de:	83 ec 04             	sub    $0x4,%esp
8010a4e1:	6a 06                	push   $0x6
8010a4e3:	68 68 d0 18 80       	push   $0x8018d068
8010a4e8:	50                   	push   %eax
8010a4e9:	e8 44 ab ff ff       	call   80105032 <memmove>
8010a4ee:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a4f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4f4:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a4f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4fb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a4ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a502:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a505:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a508:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a50c:	8b 45 18             	mov    0x18(%ebp),%eax
8010a50f:	83 c0 28             	add    $0x28,%eax
8010a512:	0f b7 c0             	movzwl %ax,%eax
8010a515:	83 ec 0c             	sub    $0xc,%esp
8010a518:	50                   	push   %eax
8010a519:	e8 6f f8 ff ff       	call   80109d8d <H2N_ushort>
8010a51e:	83 c4 10             	add    $0x10,%esp
8010a521:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a524:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a528:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a52f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a532:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a536:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a53d:	83 c0 01             	add    $0x1,%eax
8010a540:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a546:	83 ec 0c             	sub    $0xc,%esp
8010a549:	6a 00                	push   $0x0
8010a54b:	e8 3d f8 ff ff       	call   80109d8d <H2N_ushort>
8010a550:	83 c4 10             	add    $0x10,%esp
8010a553:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a556:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a55a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a55d:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a561:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a564:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a568:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a56b:	83 c0 0c             	add    $0xc,%eax
8010a56e:	83 ec 04             	sub    $0x4,%esp
8010a571:	6a 04                	push   $0x4
8010a573:	68 04 f5 10 80       	push   $0x8010f504
8010a578:	50                   	push   %eax
8010a579:	e8 b4 aa ff ff       	call   80105032 <memmove>
8010a57e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a581:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a584:	8d 50 0c             	lea    0xc(%eax),%edx
8010a587:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a58a:	83 c0 10             	add    $0x10,%eax
8010a58d:	83 ec 04             	sub    $0x4,%esp
8010a590:	6a 04                	push   $0x4
8010a592:	52                   	push   %edx
8010a593:	50                   	push   %eax
8010a594:	e8 99 aa ff ff       	call   80105032 <memmove>
8010a599:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a59c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a59f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a5a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5a8:	83 ec 0c             	sub    $0xc,%esp
8010a5ab:	50                   	push   %eax
8010a5ac:	e8 ec f8 ff ff       	call   80109e9d <ipv4_chksum>
8010a5b1:	83 c4 10             	add    $0x10,%esp
8010a5b4:	0f b7 c0             	movzwl %ax,%eax
8010a5b7:	83 ec 0c             	sub    $0xc,%esp
8010a5ba:	50                   	push   %eax
8010a5bb:	e8 cd f7 ff ff       	call   80109d8d <H2N_ushort>
8010a5c0:	83 c4 10             	add    $0x10,%esp
8010a5c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a5c6:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a5ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5cd:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a5d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5d4:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a5d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5da:	0f b7 10             	movzwl (%eax),%edx
8010a5dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5e0:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a5e4:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a5e9:	83 ec 0c             	sub    $0xc,%esp
8010a5ec:	50                   	push   %eax
8010a5ed:	e8 c1 f7 ff ff       	call   80109db3 <H2N_uint>
8010a5f2:	83 c4 10             	add    $0x10,%esp
8010a5f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a5f8:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a5fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5fe:	8b 40 04             	mov    0x4(%eax),%eax
8010a601:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a607:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a60a:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a60d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a610:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a614:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a617:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a61b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a61e:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a622:	8b 45 14             	mov    0x14(%ebp),%eax
8010a625:	89 c2                	mov    %eax,%edx
8010a627:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a62a:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a62d:	83 ec 0c             	sub    $0xc,%esp
8010a630:	68 90 38 00 00       	push   $0x3890
8010a635:	e8 53 f7 ff ff       	call   80109d8d <H2N_ushort>
8010a63a:	83 c4 10             	add    $0x10,%esp
8010a63d:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a640:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a644:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a647:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a64d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a650:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a656:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a659:	83 ec 0c             	sub    $0xc,%esp
8010a65c:	50                   	push   %eax
8010a65d:	e8 1f 00 00 00       	call   8010a681 <tcp_chksum>
8010a662:	83 c4 10             	add    $0x10,%esp
8010a665:	83 c0 08             	add    $0x8,%eax
8010a668:	0f b7 c0             	movzwl %ax,%eax
8010a66b:	83 ec 0c             	sub    $0xc,%esp
8010a66e:	50                   	push   %eax
8010a66f:	e8 19 f7 ff ff       	call   80109d8d <H2N_ushort>
8010a674:	83 c4 10             	add    $0x10,%esp
8010a677:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a67a:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a67e:	90                   	nop
8010a67f:	c9                   	leave  
8010a680:	c3                   	ret    

8010a681 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a681:	f3 0f 1e fb          	endbr32 
8010a685:	55                   	push   %ebp
8010a686:	89 e5                	mov    %esp,%ebp
8010a688:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a68b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a68e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a691:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a694:	83 c0 14             	add    $0x14,%eax
8010a697:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a69a:	83 ec 04             	sub    $0x4,%esp
8010a69d:	6a 04                	push   $0x4
8010a69f:	68 04 f5 10 80       	push   $0x8010f504
8010a6a4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a6a7:	50                   	push   %eax
8010a6a8:	e8 85 a9 ff ff       	call   80105032 <memmove>
8010a6ad:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a6b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6b3:	83 c0 0c             	add    $0xc,%eax
8010a6b6:	83 ec 04             	sub    $0x4,%esp
8010a6b9:	6a 04                	push   $0x4
8010a6bb:	50                   	push   %eax
8010a6bc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a6bf:	83 c0 04             	add    $0x4,%eax
8010a6c2:	50                   	push   %eax
8010a6c3:	e8 6a a9 ff ff       	call   80105032 <memmove>
8010a6c8:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a6cb:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a6cf:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a6d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a6d6:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a6da:	0f b7 c0             	movzwl %ax,%eax
8010a6dd:	83 ec 0c             	sub    $0xc,%esp
8010a6e0:	50                   	push   %eax
8010a6e1:	e8 81 f6 ff ff       	call   80109d67 <N2H_ushort>
8010a6e6:	83 c4 10             	add    $0x10,%esp
8010a6e9:	83 e8 14             	sub    $0x14,%eax
8010a6ec:	0f b7 c0             	movzwl %ax,%eax
8010a6ef:	83 ec 0c             	sub    $0xc,%esp
8010a6f2:	50                   	push   %eax
8010a6f3:	e8 95 f6 ff ff       	call   80109d8d <H2N_ushort>
8010a6f8:	83 c4 10             	add    $0x10,%esp
8010a6fb:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a6ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a706:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a709:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a70c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a713:	eb 33                	jmp    8010a748 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a715:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a718:	01 c0                	add    %eax,%eax
8010a71a:	89 c2                	mov    %eax,%edx
8010a71c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a71f:	01 d0                	add    %edx,%eax
8010a721:	0f b6 00             	movzbl (%eax),%eax
8010a724:	0f b6 c0             	movzbl %al,%eax
8010a727:	c1 e0 08             	shl    $0x8,%eax
8010a72a:	89 c2                	mov    %eax,%edx
8010a72c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a72f:	01 c0                	add    %eax,%eax
8010a731:	8d 48 01             	lea    0x1(%eax),%ecx
8010a734:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a737:	01 c8                	add    %ecx,%eax
8010a739:	0f b6 00             	movzbl (%eax),%eax
8010a73c:	0f b6 c0             	movzbl %al,%eax
8010a73f:	01 d0                	add    %edx,%eax
8010a741:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a744:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a748:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a74c:	7e c7                	jle    8010a715 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a74e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a751:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a754:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a75b:	eb 33                	jmp    8010a790 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a75d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a760:	01 c0                	add    %eax,%eax
8010a762:	89 c2                	mov    %eax,%edx
8010a764:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a767:	01 d0                	add    %edx,%eax
8010a769:	0f b6 00             	movzbl (%eax),%eax
8010a76c:	0f b6 c0             	movzbl %al,%eax
8010a76f:	c1 e0 08             	shl    $0x8,%eax
8010a772:	89 c2                	mov    %eax,%edx
8010a774:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a777:	01 c0                	add    %eax,%eax
8010a779:	8d 48 01             	lea    0x1(%eax),%ecx
8010a77c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a77f:	01 c8                	add    %ecx,%eax
8010a781:	0f b6 00             	movzbl (%eax),%eax
8010a784:	0f b6 c0             	movzbl %al,%eax
8010a787:	01 d0                	add    %edx,%eax
8010a789:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a78c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a790:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a794:	0f b7 c0             	movzwl %ax,%eax
8010a797:	83 ec 0c             	sub    $0xc,%esp
8010a79a:	50                   	push   %eax
8010a79b:	e8 c7 f5 ff ff       	call   80109d67 <N2H_ushort>
8010a7a0:	83 c4 10             	add    $0x10,%esp
8010a7a3:	66 d1 e8             	shr    %ax
8010a7a6:	0f b7 c0             	movzwl %ax,%eax
8010a7a9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a7ac:	7c af                	jl     8010a75d <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a7ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7b1:	c1 e8 10             	shr    $0x10,%eax
8010a7b4:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a7b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7ba:	f7 d0                	not    %eax
}
8010a7bc:	c9                   	leave  
8010a7bd:	c3                   	ret    

8010a7be <tcp_fin>:

void tcp_fin(){
8010a7be:	f3 0f 1e fb          	endbr32 
8010a7c2:	55                   	push   %ebp
8010a7c3:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a7c5:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a7cc:	00 00 00 
}
8010a7cf:	90                   	nop
8010a7d0:	5d                   	pop    %ebp
8010a7d1:	c3                   	ret    

8010a7d2 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a7d2:	f3 0f 1e fb          	endbr32 
8010a7d6:	55                   	push   %ebp
8010a7d7:	89 e5                	mov    %esp,%ebp
8010a7d9:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a7dc:	8b 45 10             	mov    0x10(%ebp),%eax
8010a7df:	83 ec 04             	sub    $0x4,%esp
8010a7e2:	6a 00                	push   $0x0
8010a7e4:	68 ab ca 10 80       	push   $0x8010caab
8010a7e9:	50                   	push   %eax
8010a7ea:	e8 65 00 00 00       	call   8010a854 <http_strcpy>
8010a7ef:	83 c4 10             	add    $0x10,%esp
8010a7f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a7f5:	8b 45 10             	mov    0x10(%ebp),%eax
8010a7f8:	83 ec 04             	sub    $0x4,%esp
8010a7fb:	ff 75 f4             	pushl  -0xc(%ebp)
8010a7fe:	68 be ca 10 80       	push   $0x8010cabe
8010a803:	50                   	push   %eax
8010a804:	e8 4b 00 00 00       	call   8010a854 <http_strcpy>
8010a809:	83 c4 10             	add    $0x10,%esp
8010a80c:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a80f:	8b 45 10             	mov    0x10(%ebp),%eax
8010a812:	83 ec 04             	sub    $0x4,%esp
8010a815:	ff 75 f4             	pushl  -0xc(%ebp)
8010a818:	68 d9 ca 10 80       	push   $0x8010cad9
8010a81d:	50                   	push   %eax
8010a81e:	e8 31 00 00 00       	call   8010a854 <http_strcpy>
8010a823:	83 c4 10             	add    $0x10,%esp
8010a826:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a82c:	83 e0 01             	and    $0x1,%eax
8010a82f:	85 c0                	test   %eax,%eax
8010a831:	74 11                	je     8010a844 <http_proc+0x72>
    char *payload = (char *)send;
8010a833:	8b 45 10             	mov    0x10(%ebp),%eax
8010a836:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a839:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a83c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a83f:	01 d0                	add    %edx,%eax
8010a841:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a844:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a847:	8b 45 14             	mov    0x14(%ebp),%eax
8010a84a:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a84c:	e8 6d ff ff ff       	call   8010a7be <tcp_fin>
}
8010a851:	90                   	nop
8010a852:	c9                   	leave  
8010a853:	c3                   	ret    

8010a854 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a854:	f3 0f 1e fb          	endbr32 
8010a858:	55                   	push   %ebp
8010a859:	89 e5                	mov    %esp,%ebp
8010a85b:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a85e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a865:	eb 20                	jmp    8010a887 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a867:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a86a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a86d:	01 d0                	add    %edx,%eax
8010a86f:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a872:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a875:	01 ca                	add    %ecx,%edx
8010a877:	89 d1                	mov    %edx,%ecx
8010a879:	8b 55 08             	mov    0x8(%ebp),%edx
8010a87c:	01 ca                	add    %ecx,%edx
8010a87e:	0f b6 00             	movzbl (%eax),%eax
8010a881:	88 02                	mov    %al,(%edx)
    i++;
8010a883:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a887:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a88a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a88d:	01 d0                	add    %edx,%eax
8010a88f:	0f b6 00             	movzbl (%eax),%eax
8010a892:	84 c0                	test   %al,%al
8010a894:	75 d1                	jne    8010a867 <http_strcpy+0x13>
  }
  return i;
8010a896:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a899:	c9                   	leave  
8010a89a:	c3                   	ret    

8010a89b <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a89b:	f3 0f 1e fb          	endbr32 
8010a89f:	55                   	push   %ebp
8010a8a0:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a8a2:	c7 05 50 d3 18 80 c2 	movl   $0x8010f5c2,0x8018d350
8010a8a9:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a8ac:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a8b1:	c1 e8 09             	shr    $0x9,%eax
8010a8b4:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a8b9:	90                   	nop
8010a8ba:	5d                   	pop    %ebp
8010a8bb:	c3                   	ret    

8010a8bc <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a8bc:	f3 0f 1e fb          	endbr32 
8010a8c0:	55                   	push   %ebp
8010a8c1:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a8c3:	90                   	nop
8010a8c4:	5d                   	pop    %ebp
8010a8c5:	c3                   	ret    

8010a8c6 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a8c6:	f3 0f 1e fb          	endbr32 
8010a8ca:	55                   	push   %ebp
8010a8cb:	89 e5                	mov    %esp,%ebp
8010a8cd:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a8d0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8d3:	83 c0 0c             	add    $0xc,%eax
8010a8d6:	83 ec 0c             	sub    $0xc,%esp
8010a8d9:	50                   	push   %eax
8010a8da:	e8 64 a3 ff ff       	call   80104c43 <holdingsleep>
8010a8df:	83 c4 10             	add    $0x10,%esp
8010a8e2:	85 c0                	test   %eax,%eax
8010a8e4:	75 0d                	jne    8010a8f3 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a8e6:	83 ec 0c             	sub    $0xc,%esp
8010a8e9:	68 ea ca 10 80       	push   $0x8010caea
8010a8ee:	e8 d2 5c ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a8f3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8f6:	8b 00                	mov    (%eax),%eax
8010a8f8:	83 e0 06             	and    $0x6,%eax
8010a8fb:	83 f8 02             	cmp    $0x2,%eax
8010a8fe:	75 0d                	jne    8010a90d <iderw+0x47>
    panic("iderw: nothing to do");
8010a900:	83 ec 0c             	sub    $0xc,%esp
8010a903:	68 00 cb 10 80       	push   $0x8010cb00
8010a908:	e8 b8 5c ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a90d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a910:	8b 40 04             	mov    0x4(%eax),%eax
8010a913:	83 f8 01             	cmp    $0x1,%eax
8010a916:	74 0d                	je     8010a925 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a918:	83 ec 0c             	sub    $0xc,%esp
8010a91b:	68 15 cb 10 80       	push   $0x8010cb15
8010a920:	e8 a0 5c ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a925:	8b 45 08             	mov    0x8(%ebp),%eax
8010a928:	8b 40 08             	mov    0x8(%eax),%eax
8010a92b:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a931:	39 d0                	cmp    %edx,%eax
8010a933:	72 0d                	jb     8010a942 <iderw+0x7c>
    panic("iderw: block out of range");
8010a935:	83 ec 0c             	sub    $0xc,%esp
8010a938:	68 33 cb 10 80       	push   $0x8010cb33
8010a93d:	e8 83 5c ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a942:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a948:	8b 45 08             	mov    0x8(%ebp),%eax
8010a94b:	8b 40 08             	mov    0x8(%eax),%eax
8010a94e:	c1 e0 09             	shl    $0x9,%eax
8010a951:	01 d0                	add    %edx,%eax
8010a953:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a956:	8b 45 08             	mov    0x8(%ebp),%eax
8010a959:	8b 00                	mov    (%eax),%eax
8010a95b:	83 e0 04             	and    $0x4,%eax
8010a95e:	85 c0                	test   %eax,%eax
8010a960:	74 2b                	je     8010a98d <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a962:	8b 45 08             	mov    0x8(%ebp),%eax
8010a965:	8b 00                	mov    (%eax),%eax
8010a967:	83 e0 fb             	and    $0xfffffffb,%eax
8010a96a:	89 c2                	mov    %eax,%edx
8010a96c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a96f:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a971:	8b 45 08             	mov    0x8(%ebp),%eax
8010a974:	83 c0 5c             	add    $0x5c,%eax
8010a977:	83 ec 04             	sub    $0x4,%esp
8010a97a:	68 00 02 00 00       	push   $0x200
8010a97f:	50                   	push   %eax
8010a980:	ff 75 f4             	pushl  -0xc(%ebp)
8010a983:	e8 aa a6 ff ff       	call   80105032 <memmove>
8010a988:	83 c4 10             	add    $0x10,%esp
8010a98b:	eb 1a                	jmp    8010a9a7 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a98d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a990:	83 c0 5c             	add    $0x5c,%eax
8010a993:	83 ec 04             	sub    $0x4,%esp
8010a996:	68 00 02 00 00       	push   $0x200
8010a99b:	ff 75 f4             	pushl  -0xc(%ebp)
8010a99e:	50                   	push   %eax
8010a99f:	e8 8e a6 ff ff       	call   80105032 <memmove>
8010a9a4:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a9a7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9aa:	8b 00                	mov    (%eax),%eax
8010a9ac:	83 c8 02             	or     $0x2,%eax
8010a9af:	89 c2                	mov    %eax,%edx
8010a9b1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a9b4:	89 10                	mov    %edx,(%eax)
}
8010a9b6:	90                   	nop
8010a9b7:	c9                   	leave  
8010a9b8:	c3                   	ret    
