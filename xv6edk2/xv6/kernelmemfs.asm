
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
80100073:	68 80 a9 10 80       	push   $0x8010a980
80100078:	68 60 e3 18 80       	push   $0x8018e360
8010007d:	e8 46 4c 00 00       	call   80104cc8 <initlock>
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
801000c1:	68 87 a9 10 80       	push   $0x8010a987
801000c6:	50                   	push   %eax
801000c7:	e8 8f 4a 00 00       	call   80104b5b <initsleeplock>
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
80100109:	e8 e0 4b 00 00       	call   80104cee <acquire>
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
80100148:	e8 13 4c 00 00       	call   80104d60 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 3c 4a 00 00       	call   80104b9b <acquiresleep>
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
801001c9:	e8 92 4b 00 00       	call   80104d60 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 bb 49 00 00       	call   80104b9b <acquiresleep>
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
801001fd:	68 8e a9 10 80       	push   $0x8010a98e
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
80100239:	e8 4a a6 00 00       	call   8010a888 <iderw>
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
8010025a:	e8 f6 49 00 00       	call   80104c55 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 9f a9 10 80       	push   $0x8010a99f
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
80100288:	e8 fb a5 00 00       	call   8010a888 <iderw>
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
801002a7:	e8 a9 49 00 00       	call   80104c55 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 a6 a9 10 80       	push   $0x8010a9a6
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 34 49 00 00       	call   80104c03 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 60 e3 18 80       	push   $0x8018e360
801002da:	e8 0f 4a 00 00       	call   80104cee <acquire>
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
8010034a:	e8 11 4a 00 00       	call   80104d60 <release>
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
8010042c:	e8 bd 48 00 00       	call   80104cee <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 ad a9 10 80       	push   $0x8010a9ad
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
8010052c:	c7 45 ec b6 a9 10 80 	movl   $0x8010a9b6,-0x14(%ebp)
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
801005ba:	e8 a1 47 00 00       	call   80104d60 <release>
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
801005e7:	68 bd a9 10 80       	push   $0x8010a9bd
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
80100606:	68 d1 a9 10 80       	push   $0x8010a9d1
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 93 47 00 00       	call   80104db6 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 d3 a9 10 80       	push   $0x8010a9d3
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
801006c4:	e8 53 80 00 00       	call   8010871c <graphic_scroll_up>
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
80100717:	e8 00 80 00 00       	call   8010871c <graphic_scroll_up>
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
8010077d:	e8 0e 80 00 00       	call   80108790 <font_render>
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
801007bd:	e8 72 62 00 00       	call   80106a34 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 65 62 00 00       	call   80106a34 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 58 62 00 00       	call   80106a34 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 48 62 00 00       	call   80106a34 <uartputc>
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
80100819:	e8 d0 44 00 00       	call   80104cee <acquire>
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
8010096f:	e8 c2 3e 00 00       	call   80104836 <wakeup>
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
80100992:	e8 c9 43 00 00       	call   80104d60 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 57 3f 00 00       	call   801048fc <procdump>
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
801009ce:	e8 1b 43 00 00       	call   80104cee <acquire>
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
801009ef:	e8 6c 43 00 00       	call   80104d60 <release>
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
80100a1c:	e8 23 3d 00 00       	call   80104744 <sleep>
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
80100a9a:	e8 c1 42 00 00       	call   80104d60 <release>
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
80100adc:	e8 0d 42 00 00       	call   80104cee <acquire>
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
80100b1e:	e8 3d 42 00 00       	call   80104d60 <release>
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
80100b50:	68 d7 a9 10 80       	push   $0x8010a9d7
80100b55:	68 20 d0 18 80       	push   $0x8018d020
80100b5a:	e8 69 41 00 00       	call   80104cc8 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 0c 37 19 80 bc 	movl   $0x80100abc,0x8019370c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 08 37 19 80 a8 	movl   $0x801009a8,0x80193708
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 df a9 10 80 	movl   $0x8010a9df,-0xc(%ebp)
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
80100bf7:	68 f5 a9 10 80       	push   $0x8010a9f5
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
80100c53:	e8 f0 6d 00 00       	call   80107a48 <setupkvm>
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
80100cf9:	e8 5c 71 00 00       	call   80107e5a <allocuvm>
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
80100d3f:	e8 45 70 00 00       	call   80107d89 <loaduvm>
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
    sp = TOP;
80100d9c:	c7 45 dc ff ff ff 7f 	movl   $0x7fffffff,-0x24(%ebp)
    if((allocuvm(pgdir, sp-PGSIZE, sp)) ==0)
80100da3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da6:	2d 00 10 00 00       	sub    $0x1000,%eax
80100dab:	83 ec 04             	sub    $0x4,%esp
80100dae:	ff 75 dc             	pushl  -0x24(%ebp)
80100db1:	50                   	push   %eax
80100db2:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db5:	e8 a0 70 00 00       	call   80107e5a <allocuvm>
80100dba:	83 c4 10             	add    $0x10,%esp
80100dbd:	85 c0                	test   %eax,%eax
80100dbf:	0f 84 f0 01 00 00    	je     80100fb5 <exec+0x3f7>
        goto bad;
    curproc->stack_alloc = 1;
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
80100dfd:	e8 e4 43 00 00       	call   801051e6 <strlen>
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
80100e2a:	e8 b7 43 00 00       	call   801051e6 <strlen>
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
80100e50:	e8 1a 75 00 00       	call   8010836f <copyout>
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
80100eec:	e8 7e 74 00 00       	call   8010836f <copyout>
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
80100f3a:	e8 59 42 00 00       	call   80105198 <safestrcpy>
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
80100f7d:	e8 f0 6b 00 00       	call   80107b72 <switchuvm>
80100f82:	83 c4 10             	add    $0x10,%esp
    freevm(oldpgdir);
80100f85:	83 ec 0c             	sub    $0xc,%esp
80100f88:	ff 75 cc             	pushl  -0x34(%ebp)
80100f8b:	e8 9b 70 00 00       	call   8010802b <freevm>
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
80100fcb:	e8 5b 70 00 00       	call   8010802b <freevm>
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
80101000:	68 01 aa 10 80       	push   $0x8010aa01
80101005:	68 60 2d 19 80       	push   $0x80192d60
8010100a:	e8 b9 3c 00 00       	call   80104cc8 <initlock>
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
80101027:	e8 c2 3c 00 00       	call   80104cee <acquire>
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
80101054:	e8 07 3d 00 00       	call   80104d60 <release>
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
80101077:	e8 e4 3c 00 00       	call   80104d60 <release>
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
80101098:	e8 51 3c 00 00       	call   80104cee <acquire>
8010109d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
801010a3:	8b 40 04             	mov    0x4(%eax),%eax
801010a6:	85 c0                	test   %eax,%eax
801010a8:	7f 0d                	jg     801010b7 <filedup+0x31>
    panic("filedup");
801010aa:	83 ec 0c             	sub    $0xc,%esp
801010ad:	68 08 aa 10 80       	push   $0x8010aa08
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
801010ce:	e8 8d 3c 00 00       	call   80104d60 <release>
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
801010ed:	e8 fc 3b 00 00       	call   80104cee <acquire>
801010f2:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	8b 40 04             	mov    0x4(%eax),%eax
801010fb:	85 c0                	test   %eax,%eax
801010fd:	7f 0d                	jg     8010110c <fileclose+0x31>
    panic("fileclose");
801010ff:	83 ec 0c             	sub    $0xc,%esp
80101102:	68 10 aa 10 80       	push   $0x8010aa10
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
8010112d:	e8 2e 3c 00 00       	call   80104d60 <release>
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
8010117b:	e8 e0 3b 00 00       	call   80104d60 <release>
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
801012d2:	68 1a aa 10 80       	push   $0x8010aa1a
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
801013d9:	68 23 aa 10 80       	push   $0x8010aa23
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
8010140f:	68 33 aa 10 80       	push   $0x8010aa33
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
8010144b:	e8 f4 3b 00 00       	call   80105044 <memmove>
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
80101495:	e8 e3 3a 00 00       	call   80104f7d <memset>
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
80101600:	68 40 aa 10 80       	push   $0x8010aa40
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
80101697:	68 56 aa 10 80       	push   $0x8010aa56
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
801016ff:	68 69 aa 10 80       	push   $0x8010aa69
80101704:	68 80 37 19 80       	push   $0x80193780
80101709:	e8 ba 35 00 00       	call   80104cc8 <initlock>
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
80101735:	68 70 aa 10 80       	push   $0x8010aa70
8010173a:	50                   	push   %eax
8010173b:	e8 1b 34 00 00       	call   80104b5b <initsleeplock>
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
80101794:	68 78 aa 10 80       	push   $0x8010aa78
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
80101811:	e8 67 37 00 00       	call   80104f7d <memset>
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
80101879:	68 cb aa 10 80       	push   $0x8010aacb
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
80101923:	e8 1c 37 00 00       	call   80105044 <memmove>
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
8010195c:	e8 8d 33 00 00       	call   80104cee <acquire>
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
801019aa:	e8 b1 33 00 00       	call   80104d60 <release>
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
801019e6:	68 dd aa 10 80       	push   $0x8010aadd
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
80101a23:	e8 38 33 00 00       	call   80104d60 <release>
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
80101a42:	e8 a7 32 00 00       	call   80104cee <acquire>
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
80101a61:	e8 fa 32 00 00       	call   80104d60 <release>
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
80101a8b:	68 ed aa 10 80       	push   $0x8010aaed
80101a90:	e8 30 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	83 c0 0c             	add    $0xc,%eax
80101a9b:	83 ec 0c             	sub    $0xc,%esp
80101a9e:	50                   	push   %eax
80101a9f:	e8 f7 30 00 00       	call   80104b9b <acquiresleep>
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
80101b49:	e8 f6 34 00 00       	call   80105044 <memmove>
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
80101b78:	68 f3 aa 10 80       	push   $0x8010aaf3
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
80101b9f:	e8 b1 30 00 00       	call   80104c55 <holdingsleep>
80101ba4:	83 c4 10             	add    $0x10,%esp
80101ba7:	85 c0                	test   %eax,%eax
80101ba9:	74 0a                	je     80101bb5 <iunlock+0x30>
80101bab:	8b 45 08             	mov    0x8(%ebp),%eax
80101bae:	8b 40 08             	mov    0x8(%eax),%eax
80101bb1:	85 c0                	test   %eax,%eax
80101bb3:	7f 0d                	jg     80101bc2 <iunlock+0x3d>
    panic("iunlock");
80101bb5:	83 ec 0c             	sub    $0xc,%esp
80101bb8:	68 02 ab 10 80       	push   $0x8010ab02
80101bbd:	e8 03 ea ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	83 c0 0c             	add    $0xc,%eax
80101bc8:	83 ec 0c             	sub    $0xc,%esp
80101bcb:	50                   	push   %eax
80101bcc:	e8 32 30 00 00       	call   80104c03 <releasesleep>
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
80101beb:	e8 ab 2f 00 00       	call   80104b9b <acquiresleep>
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
80101c11:	e8 d8 30 00 00       	call   80104cee <acquire>
80101c16:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c19:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1c:	8b 40 08             	mov    0x8(%eax),%eax
80101c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c22:	83 ec 0c             	sub    $0xc,%esp
80101c25:	68 80 37 19 80       	push   $0x80193780
80101c2a:	e8 31 31 00 00       	call   80104d60 <release>
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
80101c71:	e8 8d 2f 00 00       	call   80104c03 <releasesleep>
80101c76:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c79:	83 ec 0c             	sub    $0xc,%esp
80101c7c:	68 80 37 19 80       	push   $0x80193780
80101c81:	e8 68 30 00 00       	call   80104cee <acquire>
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
80101ca0:	e8 bb 30 00 00       	call   80104d60 <release>
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
80101dec:	68 0a ab 10 80       	push   $0x8010ab0a
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
80102096:	e8 a9 2f 00 00       	call   80105044 <memmove>
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
801021ea:	e8 55 2e 00 00       	call   80105044 <memmove>
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
8010226e:	e8 6f 2e 00 00       	call   801050e2 <strncmp>
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
80102292:	68 1d ab 10 80       	push   $0x8010ab1d
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
801022c1:	68 2f ab 10 80       	push   $0x8010ab2f
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
8010239a:	68 3e ab 10 80       	push   $0x8010ab3e
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
801023d5:	e8 62 2d 00 00       	call   8010513c <strncpy>
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
80102401:	68 4b ab 10 80       	push   $0x8010ab4b
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
80102477:	e8 c8 2b 00 00       	call   80105044 <memmove>
8010247c:	83 c4 10             	add    $0x10,%esp
8010247f:	eb 26                	jmp    801024a7 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102481:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102484:	83 ec 04             	sub    $0x4,%esp
80102487:	50                   	push   %eax
80102488:	ff 75 f4             	pushl  -0xc(%ebp)
8010248b:	ff 75 0c             	pushl  0xc(%ebp)
8010248e:	e8 b1 2b 00 00       	call   80105044 <memmove>
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
8010269d:	68 54 ab 10 80       	push   $0x8010ab54
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
8010274c:	68 86 ab 10 80       	push   $0x8010ab86
80102751:	68 e0 53 19 80       	push   $0x801953e0
80102756:	e8 6d 25 00 00       	call   80104cc8 <initlock>
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
80102817:	68 8b ab 10 80       	push   $0x8010ab8b
8010281c:	e8 a4 dd ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102821:	83 ec 04             	sub    $0x4,%esp
80102824:	68 00 10 00 00       	push   $0x1000
80102829:	6a 01                	push   $0x1
8010282b:	ff 75 08             	pushl  0x8(%ebp)
8010282e:	e8 4a 27 00 00       	call   80104f7d <memset>
80102833:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102836:	a1 14 54 19 80       	mov    0x80195414,%eax
8010283b:	85 c0                	test   %eax,%eax
8010283d:	74 10                	je     8010284f <kfree+0x69>
    acquire(&kmem.lock);
8010283f:	83 ec 0c             	sub    $0xc,%esp
80102842:	68 e0 53 19 80       	push   $0x801953e0
80102847:	e8 a2 24 00 00       	call   80104cee <acquire>
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
80102879:	e8 e2 24 00 00       	call   80104d60 <release>
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
8010289f:	e8 4a 24 00 00       	call   80104cee <acquire>
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
801028d0:	e8 8b 24 00 00       	call   80104d60 <release>
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
80102e25:	e8 be 21 00 00       	call   80104fe8 <memcmp>
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
80102f3d:	68 91 ab 10 80       	push   $0x8010ab91
80102f42:	68 20 54 19 80       	push   $0x80195420
80102f47:	e8 7c 1d 00 00       	call   80104cc8 <initlock>
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
80102ff6:	e8 49 20 00 00       	call   80105044 <memmove>
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
80103175:	e8 74 1b 00 00       	call   80104cee <acquire>
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
80103193:	e8 ac 15 00 00       	call   80104744 <sleep>
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
801031c8:	e8 77 15 00 00       	call   80104744 <sleep>
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
801031e7:	e8 74 1b 00 00       	call   80104d60 <release>
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
8010320c:	e8 dd 1a 00 00       	call   80104cee <acquire>
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
8010322d:	68 95 ab 10 80       	push   $0x8010ab95
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
8010325b:	e8 d6 15 00 00       	call   80104836 <wakeup>
80103260:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103263:	83 ec 0c             	sub    $0xc,%esp
80103266:	68 20 54 19 80       	push   $0x80195420
8010326b:	e8 f0 1a 00 00       	call   80104d60 <release>
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
80103286:	e8 63 1a 00 00       	call   80104cee <acquire>
8010328b:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010328e:	c7 05 60 54 19 80 00 	movl   $0x0,0x80195460
80103295:	00 00 00 
    wakeup(&log);
80103298:	83 ec 0c             	sub    $0xc,%esp
8010329b:	68 20 54 19 80       	push   $0x80195420
801032a0:	e8 91 15 00 00       	call   80104836 <wakeup>
801032a5:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801032a8:	83 ec 0c             	sub    $0xc,%esp
801032ab:	68 20 54 19 80       	push   $0x80195420
801032b0:	e8 ab 1a 00 00       	call   80104d60 <release>
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
80103330:	e8 0f 1d 00 00       	call   80105044 <memmove>
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
801033d5:	68 a4 ab 10 80       	push   $0x8010aba4
801033da:	e8 e6 d1 ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801033df:	a1 5c 54 19 80       	mov    0x8019545c,%eax
801033e4:	85 c0                	test   %eax,%eax
801033e6:	7f 0d                	jg     801033f5 <log_write+0x49>
    panic("log_write outside of trans");
801033e8:	83 ec 0c             	sub    $0xc,%esp
801033eb:	68 ba ab 10 80       	push   $0x8010abba
801033f0:	e8 d0 d1 ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
801033f5:	83 ec 0c             	sub    $0xc,%esp
801033f8:	68 20 54 19 80       	push   $0x80195420
801033fd:	e8 ec 18 00 00       	call   80104cee <acquire>
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
8010347b:	e8 e0 18 00 00       	call   80104d60 <release>
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
801034b5:	e8 9e 51 00 00       	call   80108658 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801034ba:	83 ec 08             	sub    $0x8,%esp
801034bd:	68 00 00 40 80       	push   $0x80400000
801034c2:	68 00 90 19 80       	push   $0x80199000
801034c7:	e8 73 f2 ff ff       	call   8010273f <kinit1>
801034cc:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801034cf:	e8 65 46 00 00       	call   80107b39 <kvmalloc>
  mpinit_uefi();
801034d4:	e8 38 4f 00 00       	call   80108411 <mpinit_uefi>
  lapicinit();     // interrupt controller
801034d9:	e8 f0 f5 ff ff       	call   80102ace <lapicinit>
  seginit();       // segment descriptors
801034de:	e8 dd 40 00 00       	call   801075c0 <seginit>
  picinit();    // disable pic
801034e3:	e8 a9 01 00 00       	call   80103691 <picinit>
  ioapicinit();    // another interrupt controller
801034e8:	e8 65 f1 ff ff       	call   80102652 <ioapicinit>
  consoleinit();   // console hardware
801034ed:	e8 47 d6 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
801034f2:	e8 52 34 00 00       	call   80106949 <uartinit>
  pinit();         // process table
801034f7:	e8 e2 05 00 00       	call   80103ade <pinit>
  tvinit();        // trap vectors
801034fc:	e8 ae 2f 00 00       	call   801064af <tvinit>
  binit();         // buffer cache
80103501:	e8 60 cb ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103506:	e8 e8 da ff ff       	call   80100ff3 <fileinit>
  ideinit();       // disk 
8010350b:	e8 4d 73 00 00       	call   8010a85d <ideinit>
  startothers();   // start other processors
80103510:	e8 92 00 00 00       	call   801035a7 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103515:	83 ec 08             	sub    $0x8,%esp
80103518:	68 00 00 00 a0       	push   $0xa0000000
8010351d:	68 00 00 40 80       	push   $0x80400000
80103522:	e8 55 f2 ff ff       	call   8010277c <kinit2>
80103527:	83 c4 10             	add    $0x10,%esp
  pci_init();
8010352a:	e8 9c 53 00 00       	call   801088cb <pci_init>
  arp_scan();
8010352f:	e8 15 61 00 00       	call   80109649 <arp_scan>
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
80103548:	e8 08 46 00 00       	call   80107b55 <switchkvm>
  seginit();
8010354d:	e8 6e 40 00 00       	call   801075c0 <seginit>
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
80103578:	68 d5 ab 10 80       	push   $0x8010abd5
8010357d:	e8 8a ce ff ff       	call   8010040c <cprintf>
80103582:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103585:	e8 9f 30 00 00       	call   80106629 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010358a:	e8 90 05 00 00       	call   80103b1f <mycpu>
8010358f:	05 a0 00 00 00       	add    $0xa0,%eax
80103594:	83 ec 08             	sub    $0x8,%esp
80103597:	6a 01                	push   $0x1
80103599:	50                   	push   %eax
8010359a:	e8 e7 fe ff ff       	call   80103486 <xchg>
8010359f:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801035a2:	e8 99 0f 00 00       	call   80104540 <scheduler>

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
801035c9:	e8 76 1a 00 00       	call   80105044 <memmove>
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
8010375a:	68 e9 ab 10 80       	push   $0x8010abe9
8010375f:	50                   	push   %eax
80103760:	e8 63 15 00 00       	call   80104cc8 <initlock>
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
80103823:	e8 c6 14 00 00       	call   80104cee <acquire>
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
8010384a:	e8 e7 0f 00 00       	call   80104836 <wakeup>
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
8010386d:	e8 c4 0f 00 00       	call   80104836 <wakeup>
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
80103896:	e8 c5 14 00 00       	call   80104d60 <release>
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
801038b5:	e8 a6 14 00 00       	call   80104d60 <release>
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
801038d3:	e8 16 14 00 00       	call   80104cee <acquire>
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
80103907:	e8 54 14 00 00       	call   80104d60 <release>
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
80103925:	e8 0c 0f 00 00       	call   80104836 <wakeup>
8010392a:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010392d:	8b 45 08             	mov    0x8(%ebp),%eax
80103930:	8b 55 08             	mov    0x8(%ebp),%edx
80103933:	81 c2 38 02 00 00    	add    $0x238,%edx
80103939:	83 ec 08             	sub    $0x8,%esp
8010393c:	50                   	push   %eax
8010393d:	52                   	push   %edx
8010393e:	e8 01 0e 00 00       	call   80104744 <sleep>
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
801039a8:	e8 89 0e 00 00       	call   80104836 <wakeup>
801039ad:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801039b0:	8b 45 08             	mov    0x8(%ebp),%eax
801039b3:	83 ec 0c             	sub    $0xc,%esp
801039b6:	50                   	push   %eax
801039b7:	e8 a4 13 00 00       	call   80104d60 <release>
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
801039d8:	e8 11 13 00 00       	call   80104cee <acquire>
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
801039f5:	e8 66 13 00 00       	call   80104d60 <release>
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
80103a18:	e8 27 0d 00 00       	call   80104744 <sleep>
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
80103aab:	e8 86 0d 00 00       	call   80104836 <wakeup>
80103ab0:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab6:	83 ec 0c             	sub    $0xc,%esp
80103ab9:	50                   	push   %eax
80103aba:	e8 a1 12 00 00       	call   80104d60 <release>
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
80103aeb:	68 f0 ab 10 80       	push   $0x8010abf0
80103af0:	68 00 55 19 80       	push   $0x80195500
80103af5:	e8 ce 11 00 00       	call   80104cc8 <initlock>
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
80103b3a:	68 f8 ab 10 80       	push   $0x8010abf8
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
80103b8f:	68 1e ac 10 80       	push   $0x8010ac1e
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
80103ba5:	e8 c0 12 00 00       	call   80104e6a <pushcli>
  c = mycpu();
80103baa:	e8 70 ff ff ff       	call   80103b1f <mycpu>
80103baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb5:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103bbe:	e8 f8 12 00 00       	call   80104ebb <popcli>
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
80103bda:	e8 0f 11 00 00       	call   80104cee <acquire>
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
80103c0d:	e8 4e 11 00 00       	call   80104d60 <release>
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
80103c57:	e8 04 11 00 00       	call   80104d60 <release>
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
80103ca4:	ba 69 64 10 80       	mov    $0x80106469,%edx
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
80103cc9:	e8 af 12 00 00       	call   80104f7d <memset>
80103cce:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd4:	8b 40 1c             	mov    0x1c(%eax),%eax
80103cd7:	ba fa 46 10 80       	mov    $0x801046fa,%edx
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
80103cfe:	e8 45 3d 00 00       	call   80107a48 <setupkvm>
80103d03:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d06:	89 42 04             	mov    %eax,0x4(%edx)
80103d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0c:	8b 40 04             	mov    0x4(%eax),%eax
80103d0f:	85 c0                	test   %eax,%eax
80103d11:	75 0d                	jne    80103d20 <userinit+0x3c>
    panic("userinit: out of memory?");
80103d13:	83 ec 0c             	sub    $0xc,%esp
80103d16:	68 2e ac 10 80       	push   $0x8010ac2e
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
80103d35:	e8 db 3f 00 00       	call   80107d15 <inituvm>
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
80103d54:	e8 24 12 00 00       	call   80104f7d <memset>
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
80103dce:	68 47 ac 10 80       	push   $0x8010ac47
80103dd3:	50                   	push   %eax
80103dd4:	e8 bf 13 00 00       	call   80105198 <safestrcpy>
80103dd9:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103ddc:	83 ec 0c             	sub    $0xc,%esp
80103ddf:	68 50 ac 10 80       	push   $0x8010ac50
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
80103dfa:	e8 ef 0e 00 00       	call   80104cee <acquire>
80103dff:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e05:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e0c:	83 ec 0c             	sub    $0xc,%esp
80103e0f:	68 00 55 19 80       	push   $0x80195500
80103e14:	e8 47 0f 00 00       	call   80104d60 <release>
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
80103e55:	e8 00 40 00 00       	call   80107e5a <allocuvm>
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
80103e89:	e8 d5 40 00 00       	call   80107f63 <deallocuvm>
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
80103eaf:	e8 be 3c 00 00       	call   80107b72 <switchuvm>
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
80103ee6:	e9 5a 01 00 00       	jmp    80104045 <fork+0x187>
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
80103efb:	e8 0d 42 00 00       	call   8010810d <copyuvm>
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
80103f3e:	e9 02 01 00 00       	jmp    80104045 <fork+0x187>
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
  np->stack_alloc = curproc->stack_alloc;
80103f73:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f76:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80103f7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f7f:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103f85:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103f88:	8b 40 18             	mov    0x18(%eax),%eax
80103f8b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103f92:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103f99:	eb 3b                	jmp    80103fd6 <fork+0x118>
    if(curproc->ofile[i])
80103f9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fa1:	83 c2 08             	add    $0x8,%edx
80103fa4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fa8:	85 c0                	test   %eax,%eax
80103faa:	74 26                	je     80103fd2 <fork+0x114>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103fac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103faf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103fb2:	83 c2 08             	add    $0x8,%edx
80103fb5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103fb9:	83 ec 0c             	sub    $0xc,%esp
80103fbc:	50                   	push   %eax
80103fbd:	e8 c4 d0 ff ff       	call   80101086 <filedup>
80103fc2:	83 c4 10             	add    $0x10,%esp
80103fc5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103fc8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103fcb:	83 c1 08             	add    $0x8,%ecx
80103fce:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103fd2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103fd6:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103fda:	7e bf                	jle    80103f9b <fork+0xdd>
  np->cwd = idup(curproc->cwd);
80103fdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fdf:	8b 40 68             	mov    0x68(%eax),%eax
80103fe2:	83 ec 0c             	sub    $0xc,%esp
80103fe5:	50                   	push   %eax
80103fe6:	e8 45 da ff ff       	call   80101a30 <idup>
80103feb:	83 c4 10             	add    $0x10,%esp
80103fee:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103ff1:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103ff4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ff7:	8d 50 6c             	lea    0x6c(%eax),%edx
80103ffa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ffd:	83 c0 6c             	add    $0x6c,%eax
80104000:	83 ec 04             	sub    $0x4,%esp
80104003:	6a 10                	push   $0x10
80104005:	52                   	push   %edx
80104006:	50                   	push   %eax
80104007:	e8 8c 11 00 00       	call   80105198 <safestrcpy>
8010400c:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010400f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104012:	8b 40 10             	mov    0x10(%eax),%eax
80104015:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104018:	83 ec 0c             	sub    $0xc,%esp
8010401b:	68 00 55 19 80       	push   $0x80195500
80104020:	e8 c9 0c 00 00       	call   80104cee <acquire>
80104025:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104028:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010402b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104032:	83 ec 0c             	sub    $0xc,%esp
80104035:	68 00 55 19 80       	push   $0x80195500
8010403a:	e8 21 0d 00 00       	call   80104d60 <release>
8010403f:	83 c4 10             	add    $0x10,%esp

  return pid;
80104042:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104045:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104048:	5b                   	pop    %ebx
80104049:	5e                   	pop    %esi
8010404a:	5f                   	pop    %edi
8010404b:	5d                   	pop    %ebp
8010404c:	c3                   	ret    

8010404d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010404d:	f3 0f 1e fb          	endbr32 
80104051:	55                   	push   %ebp
80104052:	89 e5                	mov    %esp,%ebp
80104054:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104057:	e8 3f fb ff ff       	call   80103b9b <myproc>
8010405c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010405f:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104064:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104067:	75 0d                	jne    80104076 <exit+0x29>
    panic("init exiting");
80104069:	83 ec 0c             	sub    $0xc,%esp
8010406c:	68 52 ac 10 80       	push   $0x8010ac52
80104071:	e8 4f c5 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104076:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010407d:	eb 3f                	jmp    801040be <exit+0x71>
    if(curproc->ofile[fd]){
8010407f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104082:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104085:	83 c2 08             	add    $0x8,%edx
80104088:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010408c:	85 c0                	test   %eax,%eax
8010408e:	74 2a                	je     801040ba <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104090:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104093:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104096:	83 c2 08             	add    $0x8,%edx
80104099:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010409d:	83 ec 0c             	sub    $0xc,%esp
801040a0:	50                   	push   %eax
801040a1:	e8 35 d0 ff ff       	call   801010db <fileclose>
801040a6:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801040a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040af:	83 c2 08             	add    $0x8,%edx
801040b2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801040b9:	00 
  for(fd = 0; fd < NOFILE; fd++){
801040ba:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801040be:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801040c2:	7e bb                	jle    8010407f <exit+0x32>
    }
  }

  begin_op();
801040c4:	e8 9a f0 ff ff       	call   80103163 <begin_op>
  iput(curproc->cwd);
801040c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040cc:	8b 40 68             	mov    0x68(%eax),%eax
801040cf:	83 ec 0c             	sub    $0xc,%esp
801040d2:	50                   	push   %eax
801040d3:	e8 ff da ff ff       	call   80101bd7 <iput>
801040d8:	83 c4 10             	add    $0x10,%esp
  end_op();
801040db:	e8 13 f1 ff ff       	call   801031f3 <end_op>
  curproc->cwd = 0;
801040e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040e3:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801040ea:	83 ec 0c             	sub    $0xc,%esp
801040ed:	68 00 55 19 80       	push   $0x80195500
801040f2:	e8 f7 0b 00 00       	call   80104cee <acquire>
801040f7:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801040fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040fd:	8b 40 14             	mov    0x14(%eax),%eax
80104100:	83 ec 0c             	sub    $0xc,%esp
80104103:	50                   	push   %eax
80104104:	e8 e6 06 00 00       	call   801047ef <wakeup1>
80104109:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010410c:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104113:	eb 3a                	jmp    8010414f <exit+0x102>
    if(p->parent == curproc){
80104115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104118:	8b 40 14             	mov    0x14(%eax),%eax
8010411b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010411e:	75 28                	jne    80104148 <exit+0xfb>
      p->parent = initproc;
80104120:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
80104126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104129:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010412c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412f:	8b 40 0c             	mov    0xc(%eax),%eax
80104132:	83 f8 05             	cmp    $0x5,%eax
80104135:	75 11                	jne    80104148 <exit+0xfb>
        wakeup1(initproc);
80104137:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
8010413c:	83 ec 0c             	sub    $0xc,%esp
8010413f:	50                   	push   %eax
80104140:	e8 aa 06 00 00       	call   801047ef <wakeup1>
80104145:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104148:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010414f:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
80104156:	72 bd                	jb     80104115 <exit+0xc8>
    }
  }

  curproc->scheduler = 0; //명시적으로 scheduler 필드를 초기화
80104158:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010415b:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104162:	00 00 00 

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104165:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104168:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010416f:	e8 8b 04 00 00       	call   801045ff <sched>
  panic("zombie exit");
80104174:	83 ec 0c             	sub    $0xc,%esp
80104177:	68 5f ac 10 80       	push   $0x8010ac5f
8010417c:	e8 44 c4 ff ff       	call   801005c5 <panic>

80104181 <exit2>:
}

void
exit2(int status)
{
80104181:	f3 0f 1e fb          	endbr32 
80104185:	55                   	push   %ebp
80104186:	89 e5                	mov    %esp,%ebp
80104188:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010418b:	e8 0b fa ff ff       	call   80103b9b <myproc>
80104190:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104193:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104198:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010419b:	75 0d                	jne    801041aa <exit2+0x29>
    panic("init exiting");
8010419d:	83 ec 0c             	sub    $0xc,%esp
801041a0:	68 52 ac 10 80       	push   $0x8010ac52
801041a5:	e8 1b c4 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801041aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801041b1:	eb 3f                	jmp    801041f2 <exit2+0x71>
    if(curproc->ofile[fd]){
801041b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041b9:	83 c2 08             	add    $0x8,%edx
801041bc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041c0:	85 c0                	test   %eax,%eax
801041c2:	74 2a                	je     801041ee <exit2+0x6d>
      fileclose(curproc->ofile[fd]);
801041c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041ca:	83 c2 08             	add    $0x8,%edx
801041cd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801041d1:	83 ec 0c             	sub    $0xc,%esp
801041d4:	50                   	push   %eax
801041d5:	e8 01 cf ff ff       	call   801010db <fileclose>
801041da:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801041dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041e3:	83 c2 08             	add    $0x8,%edx
801041e6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801041ed:	00 
  for(fd = 0; fd < NOFILE; fd++){
801041ee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801041f2:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801041f6:	7e bb                	jle    801041b3 <exit2+0x32>
    }
  }

  begin_op();
801041f8:	e8 66 ef ff ff       	call   80103163 <begin_op>
  iput(curproc->cwd);
801041fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104200:	8b 40 68             	mov    0x68(%eax),%eax
80104203:	83 ec 0c             	sub    $0xc,%esp
80104206:	50                   	push   %eax
80104207:	e8 cb d9 ff ff       	call   80101bd7 <iput>
8010420c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010420f:	e8 df ef ff ff       	call   801031f3 <end_op>
  curproc->cwd = 0;
80104214:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104217:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010421e:	83 ec 0c             	sub    $0xc,%esp
80104221:	68 00 55 19 80       	push   $0x80195500
80104226:	e8 c3 0a 00 00       	call   80104cee <acquire>
8010422b:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010422e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104231:	8b 40 14             	mov    0x14(%eax),%eax
80104234:	83 ec 0c             	sub    $0xc,%esp
80104237:	50                   	push   %eax
80104238:	e8 b2 05 00 00       	call   801047ef <wakeup1>
8010423d:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104240:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104247:	eb 3a                	jmp    80104283 <exit2+0x102>
    if(p->parent == curproc){
80104249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424c:	8b 40 14             	mov    0x14(%eax),%eax
8010424f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104252:	75 28                	jne    8010427c <exit2+0xfb>
      p->parent = initproc;
80104254:	8b 15 5c d0 18 80    	mov    0x8018d05c,%edx
8010425a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425d:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104263:	8b 40 0c             	mov    0xc(%eax),%eax
80104266:	83 f8 05             	cmp    $0x5,%eax
80104269:	75 11                	jne    8010427c <exit2+0xfb>
        wakeup1(initproc);
8010426b:	a1 5c d0 18 80       	mov    0x8018d05c,%eax
80104270:	83 ec 0c             	sub    $0xc,%esp
80104273:	50                   	push   %eax
80104274:	e8 76 05 00 00       	call   801047ef <wakeup1>
80104279:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010427c:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104283:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
8010428a:	72 bd                	jb     80104249 <exit2+0xc8>
    }
  }

  // Set exit status and become a zombie.
  curproc->xstate = status; // Save the exit status
8010428c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010428f:	8b 55 08             	mov    0x8(%ebp),%edx
80104292:	89 50 7c             	mov    %edx,0x7c(%eax)

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104295:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104298:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010429f:	e8 5b 03 00 00       	call   801045ff <sched>
  panic("zombie exit");
801042a4:	83 ec 0c             	sub    $0xc,%esp
801042a7:	68 5f ac 10 80       	push   $0x8010ac5f
801042ac:	e8 14 c3 ff ff       	call   801005c5 <panic>

801042b1 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801042b1:	f3 0f 1e fb          	endbr32 
801042b5:	55                   	push   %ebp
801042b6:	89 e5                	mov    %esp,%ebp
801042b8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801042bb:	e8 db f8 ff ff       	call   80103b9b <myproc>
801042c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801042c3:	83 ec 0c             	sub    $0xc,%esp
801042c6:	68 00 55 19 80       	push   $0x80195500
801042cb:	e8 1e 0a 00 00       	call   80104cee <acquire>
801042d0:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801042d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801042da:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
801042e1:	e9 a4 00 00 00       	jmp    8010438a <wait+0xd9>
      if(p->parent != curproc)
801042e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e9:	8b 40 14             	mov    0x14(%eax),%eax
801042ec:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801042ef:	0f 85 8d 00 00 00    	jne    80104382 <wait+0xd1>
        continue;
      havekids = 1;
801042f5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801042fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ff:	8b 40 0c             	mov    0xc(%eax),%eax
80104302:	83 f8 05             	cmp    $0x5,%eax
80104305:	75 7c                	jne    80104383 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430a:	8b 40 10             	mov    0x10(%eax),%eax
8010430d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104313:	8b 40 08             	mov    0x8(%eax),%eax
80104316:	83 ec 0c             	sub    $0xc,%esp
80104319:	50                   	push   %eax
8010431a:	e8 c7 e4 ff ff       	call   801027e6 <kfree>
8010431f:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104325:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010432c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432f:	8b 40 04             	mov    0x4(%eax),%eax
80104332:	83 ec 0c             	sub    $0xc,%esp
80104335:	50                   	push   %eax
80104336:	e8 f0 3c 00 00       	call   8010802b <freevm>
8010433b:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010433e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104341:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104348:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104355:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104366:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010436d:	83 ec 0c             	sub    $0xc,%esp
80104370:	68 00 55 19 80       	push   $0x80195500
80104375:	e8 e6 09 00 00       	call   80104d60 <release>
8010437a:	83 c4 10             	add    $0x10,%esp
        return pid;
8010437d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104380:	eb 54                	jmp    801043d6 <wait+0x125>
        continue;
80104382:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104383:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010438a:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
80104391:	0f 82 4f ff ff ff    	jb     801042e6 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104397:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010439b:	74 0a                	je     801043a7 <wait+0xf6>
8010439d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043a0:	8b 40 24             	mov    0x24(%eax),%eax
801043a3:	85 c0                	test   %eax,%eax
801043a5:	74 17                	je     801043be <wait+0x10d>
      release(&ptable.lock);
801043a7:	83 ec 0c             	sub    $0xc,%esp
801043aa:	68 00 55 19 80       	push   $0x80195500
801043af:	e8 ac 09 00 00       	call   80104d60 <release>
801043b4:	83 c4 10             	add    $0x10,%esp
      return -1;
801043b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043bc:	eb 18                	jmp    801043d6 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801043be:	83 ec 08             	sub    $0x8,%esp
801043c1:	68 00 55 19 80       	push   $0x80195500
801043c6:	ff 75 ec             	pushl  -0x14(%ebp)
801043c9:	e8 76 03 00 00       	call   80104744 <sleep>
801043ce:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801043d1:	e9 fd fe ff ff       	jmp    801042d3 <wait+0x22>
  }
}
801043d6:	c9                   	leave  
801043d7:	c3                   	ret    

801043d8 <wait2>:

int
wait2(int *status) {
801043d8:	f3 0f 1e fb          	endbr32 
801043dc:	55                   	push   %ebp
801043dd:	89 e5                	mov    %esp,%ebp
801043df:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801043e2:	e8 b4 f7 ff ff       	call   80103b9b <myproc>
801043e7:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
801043ea:	83 ec 0c             	sub    $0xc,%esp
801043ed:	68 00 55 19 80       	push   $0x80195500
801043f2:	e8 f7 08 00 00       	call   80104cee <acquire>
801043f7:	83 c4 10             	add    $0x10,%esp
  for(;;) {
    // Scan through table looking for zombie children.
    havekids = 0;
801043fa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104401:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104408:	e9 e5 00 00 00       	jmp    801044f2 <wait2+0x11a>
      if(p->parent != curproc)
8010440d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104410:	8b 40 14             	mov    0x14(%eax),%eax
80104413:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104416:	0f 85 ce 00 00 00    	jne    801044ea <wait2+0x112>
        continue;
      havekids = 1;
8010441c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE) {
80104423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104426:	8b 40 0c             	mov    0xc(%eax),%eax
80104429:	83 f8 05             	cmp    $0x5,%eax
8010442c:	0f 85 b9 00 00 00    	jne    801044eb <wait2+0x113>
        // Found one.
        pid = p->pid;
80104432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104435:	8b 40 10             	mov    0x10(%eax),%eax
80104438:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010443b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443e:	8b 40 08             	mov    0x8(%eax),%eax
80104441:	83 ec 0c             	sub    $0xc,%esp
80104444:	50                   	push   %eax
80104445:	e8 9c e3 ff ff       	call   801027e6 <kfree>
8010444a:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010444d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104450:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445a:	8b 40 04             	mov    0x4(%eax),%eax
8010445d:	83 ec 0c             	sub    $0xc,%esp
80104460:	50                   	push   %eax
80104461:	e8 c5 3b 00 00       	call   8010802b <freevm>
80104466:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104476:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010447d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104480:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104484:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104487:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        if(status != 0 && copyout(curproc->pgdir, (uint)status, &p->xstate, sizeof(p->xstate)) < 0) {
8010448e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104492:	74 37                	je     801044cb <wait2+0xf3>
80104494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104497:	8d 48 7c             	lea    0x7c(%eax),%ecx
8010449a:	8b 55 08             	mov    0x8(%ebp),%edx
8010449d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801044a0:	8b 40 04             	mov    0x4(%eax),%eax
801044a3:	6a 04                	push   $0x4
801044a5:	51                   	push   %ecx
801044a6:	52                   	push   %edx
801044a7:	50                   	push   %eax
801044a8:	e8 c2 3e 00 00       	call   8010836f <copyout>
801044ad:	83 c4 10             	add    $0x10,%esp
801044b0:	85 c0                	test   %eax,%eax
801044b2:	79 17                	jns    801044cb <wait2+0xf3>
          release(&ptable.lock);
801044b4:	83 ec 0c             	sub    $0xc,%esp
801044b7:	68 00 55 19 80       	push   $0x80195500
801044bc:	e8 9f 08 00 00       	call   80104d60 <release>
801044c1:	83 c4 10             	add    $0x10,%esp
          return -1;
801044c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044c9:	eb 73                	jmp    8010453e <wait2+0x166>
        }
        p->state = UNUSED;
801044cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ce:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801044d5:	83 ec 0c             	sub    $0xc,%esp
801044d8:	68 00 55 19 80       	push   $0x80195500
801044dd:	e8 7e 08 00 00       	call   80104d60 <release>
801044e2:	83 c4 10             	add    $0x10,%esp
        return pid;
801044e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801044e8:	eb 54                	jmp    8010453e <wait2+0x166>
        continue;
801044ea:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801044eb:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801044f2:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
801044f9:	0f 82 0e ff ff ff    	jb     8010440d <wait2+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed) {
801044ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104503:	74 0a                	je     8010450f <wait2+0x137>
80104505:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104508:	8b 40 24             	mov    0x24(%eax),%eax
8010450b:	85 c0                	test   %eax,%eax
8010450d:	74 17                	je     80104526 <wait2+0x14e>
      release(&ptable.lock);
8010450f:	83 ec 0c             	sub    $0xc,%esp
80104512:	68 00 55 19 80       	push   $0x80195500
80104517:	e8 44 08 00 00       	call   80104d60 <release>
8010451c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010451f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104524:	eb 18                	jmp    8010453e <wait2+0x166>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  // DOC: wait-sleep
80104526:	83 ec 08             	sub    $0x8,%esp
80104529:	68 00 55 19 80       	push   $0x80195500
8010452e:	ff 75 ec             	pushl  -0x14(%ebp)
80104531:	e8 0e 02 00 00       	call   80104744 <sleep>
80104536:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104539:	e9 bc fe ff ff       	jmp    801043fa <wait2+0x22>
  }
}
8010453e:	c9                   	leave  
8010453f:	c3                   	ret    

80104540 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104540:	f3 0f 1e fb          	endbr32 
80104544:	55                   	push   %ebp
80104545:	89 e5                	mov    %esp,%ebp
80104547:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010454a:	e8 d0 f5 ff ff       	call   80103b1f <mycpu>
8010454f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104555:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010455c:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010455f:	e8 73 f5 ff ff       	call   80103ad7 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104564:	83 ec 0c             	sub    $0xc,%esp
80104567:	68 00 55 19 80       	push   $0x80195500
8010456c:	e8 7d 07 00 00       	call   80104cee <acquire>
80104571:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104574:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
8010457b:	eb 64                	jmp    801045e1 <scheduler+0xa1>
      if(p->state != RUNNABLE)
8010457d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104580:	8b 40 0c             	mov    0xc(%eax),%eax
80104583:	83 f8 03             	cmp    $0x3,%eax
80104586:	75 51                	jne    801045d9 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104588:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010458b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010458e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104594:	83 ec 0c             	sub    $0xc,%esp
80104597:	ff 75 f4             	pushl  -0xc(%ebp)
8010459a:	e8 d3 35 00 00       	call   80107b72 <switchuvm>
8010459f:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
801045a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a5:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
801045ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045af:	8b 40 1c             	mov    0x1c(%eax),%eax
801045b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045b5:	83 c2 04             	add    $0x4,%edx
801045b8:	83 ec 08             	sub    $0x8,%esp
801045bb:	50                   	push   %eax
801045bc:	52                   	push   %edx
801045bd:	e8 4f 0c 00 00       	call   80105211 <swtch>
801045c2:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801045c5:	e8 8b 35 00 00       	call   80107b55 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801045ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045cd:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045d4:	00 00 00 
801045d7:	eb 01                	jmp    801045da <scheduler+0x9a>
        continue;
801045d9:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045da:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801045e1:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
801045e8:	72 93                	jb     8010457d <scheduler+0x3d>
    }
    release(&ptable.lock);
801045ea:	83 ec 0c             	sub    $0xc,%esp
801045ed:	68 00 55 19 80       	push   $0x80195500
801045f2:	e8 69 07 00 00       	call   80104d60 <release>
801045f7:	83 c4 10             	add    $0x10,%esp
    sti();
801045fa:	e9 60 ff ff ff       	jmp    8010455f <scheduler+0x1f>

801045ff <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801045ff:	f3 0f 1e fb          	endbr32 
80104603:	55                   	push   %ebp
80104604:	89 e5                	mov    %esp,%ebp
80104606:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104609:	e8 8d f5 ff ff       	call   80103b9b <myproc>
8010460e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104611:	83 ec 0c             	sub    $0xc,%esp
80104614:	68 00 55 19 80       	push   $0x80195500
80104619:	e8 17 08 00 00       	call   80104e35 <holding>
8010461e:	83 c4 10             	add    $0x10,%esp
80104621:	85 c0                	test   %eax,%eax
80104623:	75 0d                	jne    80104632 <sched+0x33>
    panic("sched ptable.lock");
80104625:	83 ec 0c             	sub    $0xc,%esp
80104628:	68 6b ac 10 80       	push   $0x8010ac6b
8010462d:	e8 93 bf ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104632:	e8 e8 f4 ff ff       	call   80103b1f <mycpu>
80104637:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010463d:	83 f8 01             	cmp    $0x1,%eax
80104640:	74 0d                	je     8010464f <sched+0x50>
    panic("sched locks");
80104642:	83 ec 0c             	sub    $0xc,%esp
80104645:	68 7d ac 10 80       	push   $0x8010ac7d
8010464a:	e8 76 bf ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
8010464f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104652:	8b 40 0c             	mov    0xc(%eax),%eax
80104655:	83 f8 04             	cmp    $0x4,%eax
80104658:	75 0d                	jne    80104667 <sched+0x68>
    panic("sched running");
8010465a:	83 ec 0c             	sub    $0xc,%esp
8010465d:	68 89 ac 10 80       	push   $0x8010ac89
80104662:	e8 5e bf ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
80104667:	e8 5b f4 ff ff       	call   80103ac7 <readeflags>
8010466c:	25 00 02 00 00       	and    $0x200,%eax
80104671:	85 c0                	test   %eax,%eax
80104673:	74 0d                	je     80104682 <sched+0x83>
    panic("sched interruptible");
80104675:	83 ec 0c             	sub    $0xc,%esp
80104678:	68 97 ac 10 80       	push   $0x8010ac97
8010467d:	e8 43 bf ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
80104682:	e8 98 f4 ff ff       	call   80103b1f <mycpu>
80104687:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010468d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104690:	e8 8a f4 ff ff       	call   80103b1f <mycpu>
80104695:	8b 40 04             	mov    0x4(%eax),%eax
80104698:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010469b:	83 c2 1c             	add    $0x1c,%edx
8010469e:	83 ec 08             	sub    $0x8,%esp
801046a1:	50                   	push   %eax
801046a2:	52                   	push   %edx
801046a3:	e8 69 0b 00 00       	call   80105211 <swtch>
801046a8:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801046ab:	e8 6f f4 ff ff       	call   80103b1f <mycpu>
801046b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046b3:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801046b9:	90                   	nop
801046ba:	c9                   	leave  
801046bb:	c3                   	ret    

801046bc <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801046bc:	f3 0f 1e fb          	endbr32 
801046c0:	55                   	push   %ebp
801046c1:	89 e5                	mov    %esp,%ebp
801046c3:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801046c6:	83 ec 0c             	sub    $0xc,%esp
801046c9:	68 00 55 19 80       	push   $0x80195500
801046ce:	e8 1b 06 00 00       	call   80104cee <acquire>
801046d3:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
801046d6:	e8 c0 f4 ff ff       	call   80103b9b <myproc>
801046db:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801046e2:	e8 18 ff ff ff       	call   801045ff <sched>
  release(&ptable.lock);
801046e7:	83 ec 0c             	sub    $0xc,%esp
801046ea:	68 00 55 19 80       	push   $0x80195500
801046ef:	e8 6c 06 00 00       	call   80104d60 <release>
801046f4:	83 c4 10             	add    $0x10,%esp
}
801046f7:	90                   	nop
801046f8:	c9                   	leave  
801046f9:	c3                   	ret    

801046fa <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801046fa:	f3 0f 1e fb          	endbr32 
801046fe:	55                   	push   %ebp
801046ff:	89 e5                	mov    %esp,%ebp
80104701:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104704:	83 ec 0c             	sub    $0xc,%esp
80104707:	68 00 55 19 80       	push   $0x80195500
8010470c:	e8 4f 06 00 00       	call   80104d60 <release>
80104711:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104714:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104719:	85 c0                	test   %eax,%eax
8010471b:	74 24                	je     80104741 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010471d:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104724:	00 00 00 
    iinit(ROOTDEV);
80104727:	83 ec 0c             	sub    $0xc,%esp
8010472a:	6a 01                	push   $0x1
8010472c:	e8 b7 cf ff ff       	call   801016e8 <iinit>
80104731:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104734:	83 ec 0c             	sub    $0xc,%esp
80104737:	6a 01                	push   $0x1
80104739:	e8 f2 e7 ff ff       	call   80102f30 <initlog>
8010473e:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104741:	90                   	nop
80104742:	c9                   	leave  
80104743:	c3                   	ret    

80104744 <sleep>:

// Atomically release lock and sleep on chan.ld: trap.o: in function `trap':
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104744:	f3 0f 1e fb          	endbr32 
80104748:	55                   	push   %ebp
80104749:	89 e5                	mov    %esp,%ebp
8010474b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
8010474e:	e8 48 f4 ff ff       	call   80103b9b <myproc>
80104753:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104756:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010475a:	75 0d                	jne    80104769 <sleep+0x25>
    panic("sleep");
8010475c:	83 ec 0c             	sub    $0xc,%esp
8010475f:	68 ab ac 10 80       	push   $0x8010acab
80104764:	e8 5c be ff ff       	call   801005c5 <panic>

  if(lk == 0)
80104769:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010476d:	75 0d                	jne    8010477c <sleep+0x38>
    panic("sleep without lk");
8010476f:	83 ec 0c             	sub    $0xc,%esp
80104772:	68 b1 ac 10 80       	push   $0x8010acb1
80104777:	e8 49 be ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010477c:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
80104783:	74 1e                	je     801047a3 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104785:	83 ec 0c             	sub    $0xc,%esp
80104788:	68 00 55 19 80       	push   $0x80195500
8010478d:	e8 5c 05 00 00       	call   80104cee <acquire>
80104792:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104795:	83 ec 0c             	sub    $0xc,%esp
80104798:	ff 75 0c             	pushl  0xc(%ebp)
8010479b:	e8 c0 05 00 00       	call   80104d60 <release>
801047a0:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
801047a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a6:	8b 55 08             	mov    0x8(%ebp),%edx
801047a9:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801047ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047af:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801047b6:	e8 44 fe ff ff       	call   801045ff <sched>

  // Tidy up.
  p->chan = 0;
801047bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047be:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801047c5:	81 7d 0c 00 55 19 80 	cmpl   $0x80195500,0xc(%ebp)
801047cc:	74 1e                	je     801047ec <sleep+0xa8>
    release(&ptable.lock);
801047ce:	83 ec 0c             	sub    $0xc,%esp
801047d1:	68 00 55 19 80       	push   $0x80195500
801047d6:	e8 85 05 00 00       	call   80104d60 <release>
801047db:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801047de:	83 ec 0c             	sub    $0xc,%esp
801047e1:	ff 75 0c             	pushl  0xc(%ebp)
801047e4:	e8 05 05 00 00       	call   80104cee <acquire>
801047e9:	83 c4 10             	add    $0x10,%esp
  }
}
801047ec:	90                   	nop
801047ed:	c9                   	leave  
801047ee:	c3                   	ret    

801047ef <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801047ef:	f3 0f 1e fb          	endbr32 
801047f3:	55                   	push   %ebp
801047f4:	89 e5                	mov    %esp,%ebp
801047f6:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801047f9:	c7 45 fc 34 55 19 80 	movl   $0x80195534,-0x4(%ebp)
80104800:	eb 27                	jmp    80104829 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104802:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104805:	8b 40 0c             	mov    0xc(%eax),%eax
80104808:	83 f8 02             	cmp    $0x2,%eax
8010480b:	75 15                	jne    80104822 <wakeup1+0x33>
8010480d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104810:	8b 40 20             	mov    0x20(%eax),%eax
80104813:	39 45 08             	cmp    %eax,0x8(%ebp)
80104816:	75 0a                	jne    80104822 <wakeup1+0x33>
      p->state = RUNNABLE;
80104818:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010481b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104822:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80104829:	81 7d fc 34 79 19 80 	cmpl   $0x80197934,-0x4(%ebp)
80104830:	72 d0                	jb     80104802 <wakeup1+0x13>
}
80104832:	90                   	nop
80104833:	90                   	nop
80104834:	c9                   	leave  
80104835:	c3                   	ret    

80104836 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104836:	f3 0f 1e fb          	endbr32 
8010483a:	55                   	push   %ebp
8010483b:	89 e5                	mov    %esp,%ebp
8010483d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104840:	83 ec 0c             	sub    $0xc,%esp
80104843:	68 00 55 19 80       	push   $0x80195500
80104848:	e8 a1 04 00 00       	call   80104cee <acquire>
8010484d:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104850:	83 ec 0c             	sub    $0xc,%esp
80104853:	ff 75 08             	pushl  0x8(%ebp)
80104856:	e8 94 ff ff ff       	call   801047ef <wakeup1>
8010485b:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010485e:	83 ec 0c             	sub    $0xc,%esp
80104861:	68 00 55 19 80       	push   $0x80195500
80104866:	e8 f5 04 00 00       	call   80104d60 <release>
8010486b:	83 c4 10             	add    $0x10,%esp
}
8010486e:	90                   	nop
8010486f:	c9                   	leave  
80104870:	c3                   	ret    

80104871 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104871:	f3 0f 1e fb          	endbr32 
80104875:	55                   	push   %ebp
80104876:	89 e5                	mov    %esp,%ebp
80104878:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010487b:	83 ec 0c             	sub    $0xc,%esp
8010487e:	68 00 55 19 80       	push   $0x80195500
80104883:	e8 66 04 00 00       	call   80104cee <acquire>
80104888:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010488b:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104892:	eb 48                	jmp    801048dc <kill+0x6b>
    if(p->pid == pid){
80104894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104897:	8b 40 10             	mov    0x10(%eax),%eax
8010489a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010489d:	75 36                	jne    801048d5 <kill+0x64>
      p->killed = 1;
8010489f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a2:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ac:	8b 40 0c             	mov    0xc(%eax),%eax
801048af:	83 f8 02             	cmp    $0x2,%eax
801048b2:	75 0a                	jne    801048be <kill+0x4d>
        p->state = RUNNABLE;
801048b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801048be:	83 ec 0c             	sub    $0xc,%esp
801048c1:	68 00 55 19 80       	push   $0x80195500
801048c6:	e8 95 04 00 00       	call   80104d60 <release>
801048cb:	83 c4 10             	add    $0x10,%esp
      return 0;
801048ce:	b8 00 00 00 00       	mov    $0x0,%eax
801048d3:	eb 25                	jmp    801048fa <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048d5:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801048dc:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
801048e3:	72 af                	jb     80104894 <kill+0x23>
    }
  }
  release(&ptable.lock);
801048e5:	83 ec 0c             	sub    $0xc,%esp
801048e8:	68 00 55 19 80       	push   $0x80195500
801048ed:	e8 6e 04 00 00       	call   80104d60 <release>
801048f2:	83 c4 10             	add    $0x10,%esp
  return -1;
801048f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801048fa:	c9                   	leave  
801048fb:	c3                   	ret    

801048fc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801048fc:	f3 0f 1e fb          	endbr32 
80104900:	55                   	push   %ebp
80104901:	89 e5                	mov    %esp,%ebp
80104903:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104906:	c7 45 f0 34 55 19 80 	movl   $0x80195534,-0x10(%ebp)
8010490d:	e9 da 00 00 00       	jmp    801049ec <procdump+0xf0>
    if(p->state == UNUSED)
80104912:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104915:	8b 40 0c             	mov    0xc(%eax),%eax
80104918:	85 c0                	test   %eax,%eax
8010491a:	0f 84 c4 00 00 00    	je     801049e4 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104920:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104923:	8b 40 0c             	mov    0xc(%eax),%eax
80104926:	83 f8 05             	cmp    $0x5,%eax
80104929:	77 23                	ja     8010494e <procdump+0x52>
8010492b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010492e:	8b 40 0c             	mov    0xc(%eax),%eax
80104931:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104938:	85 c0                	test   %eax,%eax
8010493a:	74 12                	je     8010494e <procdump+0x52>
      state = states[p->state];
8010493c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010493f:	8b 40 0c             	mov    0xc(%eax),%eax
80104942:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104949:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010494c:	eb 07                	jmp    80104955 <procdump+0x59>
    else
      state = "???";
8010494e:	c7 45 ec c2 ac 10 80 	movl   $0x8010acc2,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104955:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104958:	8d 50 6c             	lea    0x6c(%eax),%edx
8010495b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010495e:	8b 40 10             	mov    0x10(%eax),%eax
80104961:	52                   	push   %edx
80104962:	ff 75 ec             	pushl  -0x14(%ebp)
80104965:	50                   	push   %eax
80104966:	68 c6 ac 10 80       	push   $0x8010acc6
8010496b:	e8 9c ba ff ff       	call   8010040c <cprintf>
80104970:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104973:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104976:	8b 40 0c             	mov    0xc(%eax),%eax
80104979:	83 f8 02             	cmp    $0x2,%eax
8010497c:	75 54                	jne    801049d2 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010497e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104981:	8b 40 1c             	mov    0x1c(%eax),%eax
80104984:	8b 40 0c             	mov    0xc(%eax),%eax
80104987:	83 c0 08             	add    $0x8,%eax
8010498a:	89 c2                	mov    %eax,%edx
8010498c:	83 ec 08             	sub    $0x8,%esp
8010498f:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104992:	50                   	push   %eax
80104993:	52                   	push   %edx
80104994:	e8 1d 04 00 00       	call   80104db6 <getcallerpcs>
80104999:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010499c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801049a3:	eb 1c                	jmp    801049c1 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801049a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801049ac:	83 ec 08             	sub    $0x8,%esp
801049af:	50                   	push   %eax
801049b0:	68 cf ac 10 80       	push   $0x8010accf
801049b5:	e8 52 ba ff ff       	call   8010040c <cprintf>
801049ba:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801049bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801049c1:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801049c5:	7f 0b                	jg     801049d2 <procdump+0xd6>
801049c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ca:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801049ce:	85 c0                	test   %eax,%eax
801049d0:	75 d3                	jne    801049a5 <procdump+0xa9>
    }
    cprintf("\n");
801049d2:	83 ec 0c             	sub    $0xc,%esp
801049d5:	68 d3 ac 10 80       	push   $0x8010acd3
801049da:	e8 2d ba ff ff       	call   8010040c <cprintf>
801049df:	83 c4 10             	add    $0x10,%esp
801049e2:	eb 01                	jmp    801049e5 <procdump+0xe9>
      continue;
801049e4:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e5:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
801049ec:	81 7d f0 34 79 19 80 	cmpl   $0x80197934,-0x10(%ebp)
801049f3:	0f 82 19 ff ff ff    	jb     80104912 <procdump+0x16>
  }
}
801049f9:	90                   	nop
801049fa:	90                   	nop
801049fb:	c9                   	leave  
801049fc:	c3                   	ret    

801049fd <printpt>:


pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc);
int
printpt(int pid)
{
801049fd:	f3 0f 1e fb          	endbr32 
80104a01:	55                   	push   %ebp
80104a02:	89 e5                	mov    %esp,%ebp
80104a04:	83 ec 28             	sub    $0x28,%esp
    struct proc* p = 0;
80104a07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    pde_t* pgdir;
    pte_t* pte;
    uint va;
    int found = 0;
80104a0e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    // 프로세스 테이블에서 해당 pid의 프로세스를 찾기
    acquire(&ptable.lock);
80104a15:	83 ec 0c             	sub    $0xc,%esp
80104a18:	68 00 55 19 80       	push   $0x80195500
80104a1d:	e8 cc 02 00 00       	call   80104cee <acquire>
80104a22:	83 c4 10             	add    $0x10,%esp
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a25:	c7 45 f4 34 55 19 80 	movl   $0x80195534,-0xc(%ebp)
80104a2c:	eb 1b                	jmp    80104a49 <printpt+0x4c>
        if (p->pid == pid) {
80104a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a31:	8b 40 10             	mov    0x10(%eax),%eax
80104a34:	39 45 08             	cmp    %eax,0x8(%ebp)
80104a37:	75 09                	jne    80104a42 <printpt+0x45>
            found = 1;
80104a39:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
            break;
80104a40:	eb 10                	jmp    80104a52 <printpt+0x55>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104a42:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104a49:	81 7d f4 34 79 19 80 	cmpl   $0x80197934,-0xc(%ebp)
80104a50:	72 dc                	jb     80104a2e <printpt+0x31>
        }
    }
    release(&ptable.lock);
80104a52:	83 ec 0c             	sub    $0xc,%esp
80104a55:	68 00 55 19 80       	push   $0x80195500
80104a5a:	e8 01 03 00 00       	call   80104d60 <release>
80104a5f:	83 c4 10             	add    $0x10,%esp

    // 해당 프로세스가 존재하지 않거나, UNUSED 상태일 경우 -1 반환
    if (!found || p->state == UNUSED) {
80104a62:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104a66:	74 0a                	je     80104a72 <printpt+0x75>
80104a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a6b:	8b 40 0c             	mov    0xc(%eax),%eax
80104a6e:	85 c0                	test   %eax,%eax
80104a70:	75 1d                	jne    80104a8f <printpt+0x92>
        cprintf("Process with pid %d not found or is in UNUSED state\n", pid);
80104a72:	83 ec 08             	sub    $0x8,%esp
80104a75:	ff 75 08             	pushl  0x8(%ebp)
80104a78:	68 d8 ac 10 80       	push   $0x8010acd8
80104a7d:	e8 8a b9 ff ff       	call   8010040c <cprintf>
80104a82:	83 c4 10             	add    $0x10,%esp
        return -1;
80104a85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a8a:	e9 ca 00 00 00       	jmp    80104b59 <printpt+0x15c>
    }

    pgdir = p->pgdir;
80104a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a92:	8b 40 04             	mov    0x4(%eax),%eax
80104a95:	89 45 e8             	mov    %eax,-0x18(%ebp)

    cprintf("START PAGE TABLE (pid %d)\n", pid);
80104a98:	83 ec 08             	sub    $0x8,%esp
80104a9b:	ff 75 08             	pushl  0x8(%ebp)
80104a9e:	68 0d ad 10 80       	push   $0x8010ad0d
80104aa3:	e8 64 b9 ff ff       	call   8010040c <cprintf>
80104aa8:	83 c4 10             	add    $0x10,%esp
    for (va = 0; va < KERNBASE; va += PGSIZE) {
80104aab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ab2:	e9 82 00 00 00       	jmp    80104b39 <printpt+0x13c>
        pte = walkpgdir(pgdir, (void*)va, 0);
80104ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aba:	83 ec 04             	sub    $0x4,%esp
80104abd:	6a 00                	push   $0x0
80104abf:	50                   	push   %eax
80104ac0:	ff 75 e8             	pushl  -0x18(%ebp)
80104ac3:	e8 52 2e 00 00       	call   8010791a <walkpgdir>
80104ac8:	83 c4 10             	add    $0x10,%esp
80104acb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (pte && (*pte & PTE_P)) {
80104ace:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104ad2:	74 5e                	je     80104b32 <printpt+0x135>
80104ad4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ad7:	8b 00                	mov    (%eax),%eax
80104ad9:	83 e0 01             	and    $0x1,%eax
80104adc:	85 c0                	test   %eax,%eax
80104ade:	74 52                	je     80104b32 <printpt+0x135>
            cprintf("VA: 0x%x P %s %s PA: 0x%x\n",
                va,
                (*pte & PTE_U) ? "U" : "K",
                (*pte & PTE_W) ? "W" : " - ",
                PTE_ADDR(*pte));
80104ae0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ae3:	8b 00                	mov    (%eax),%eax
            cprintf("VA: 0x%x P %s %s PA: 0x%x\n",
80104ae5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104aea:	89 c2                	mov    %eax,%edx
                (*pte & PTE_W) ? "W" : " - ",
80104aec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104aef:	8b 00                	mov    (%eax),%eax
80104af1:	83 e0 02             	and    $0x2,%eax
            cprintf("VA: 0x%x P %s %s PA: 0x%x\n",
80104af4:	85 c0                	test   %eax,%eax
80104af6:	74 07                	je     80104aff <printpt+0x102>
80104af8:	b9 28 ad 10 80       	mov    $0x8010ad28,%ecx
80104afd:	eb 05                	jmp    80104b04 <printpt+0x107>
80104aff:	b9 2a ad 10 80       	mov    $0x8010ad2a,%ecx
                (*pte & PTE_U) ? "U" : "K",
80104b04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104b07:	8b 00                	mov    (%eax),%eax
80104b09:	83 e0 04             	and    $0x4,%eax
            cprintf("VA: 0x%x P %s %s PA: 0x%x\n",
80104b0c:	85 c0                	test   %eax,%eax
80104b0e:	74 07                	je     80104b17 <printpt+0x11a>
80104b10:	b8 2e ad 10 80       	mov    $0x8010ad2e,%eax
80104b15:	eb 05                	jmp    80104b1c <printpt+0x11f>
80104b17:	b8 30 ad 10 80       	mov    $0x8010ad30,%eax
80104b1c:	83 ec 0c             	sub    $0xc,%esp
80104b1f:	52                   	push   %edx
80104b20:	51                   	push   %ecx
80104b21:	50                   	push   %eax
80104b22:	ff 75 f0             	pushl  -0x10(%ebp)
80104b25:	68 32 ad 10 80       	push   $0x8010ad32
80104b2a:	e8 dd b8 ff ff       	call   8010040c <cprintf>
80104b2f:	83 c4 20             	add    $0x20,%esp
    for (va = 0; va < KERNBASE; va += PGSIZE) {
80104b32:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b3c:	85 c0                	test   %eax,%eax
80104b3e:	0f 89 73 ff ff ff    	jns    80104ab7 <printpt+0xba>
        }
    }
    cprintf("END PAGE TABLE\n");
80104b44:	83 ec 0c             	sub    $0xc,%esp
80104b47:	68 4d ad 10 80       	push   $0x8010ad4d
80104b4c:	e8 bb b8 ff ff       	call   8010040c <cprintf>
80104b51:	83 c4 10             	add    $0x10,%esp
    return 0;
80104b54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b59:	c9                   	leave  
80104b5a:	c3                   	ret    

80104b5b <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104b5b:	f3 0f 1e fb          	endbr32 
80104b5f:	55                   	push   %ebp
80104b60:	89 e5                	mov    %esp,%ebp
80104b62:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104b65:	8b 45 08             	mov    0x8(%ebp),%eax
80104b68:	83 c0 04             	add    $0x4,%eax
80104b6b:	83 ec 08             	sub    $0x8,%esp
80104b6e:	68 87 ad 10 80       	push   $0x8010ad87
80104b73:	50                   	push   %eax
80104b74:	e8 4f 01 00 00       	call   80104cc8 <initlock>
80104b79:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b82:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104b85:	8b 45 08             	mov    0x8(%ebp),%eax
80104b88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b91:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104b98:	90                   	nop
80104b99:	c9                   	leave  
80104b9a:	c3                   	ret    

80104b9b <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104b9b:	f3 0f 1e fb          	endbr32 
80104b9f:	55                   	push   %ebp
80104ba0:	89 e5                	mov    %esp,%ebp
80104ba2:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba8:	83 c0 04             	add    $0x4,%eax
80104bab:	83 ec 0c             	sub    $0xc,%esp
80104bae:	50                   	push   %eax
80104baf:	e8 3a 01 00 00       	call   80104cee <acquire>
80104bb4:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104bb7:	eb 15                	jmp    80104bce <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbc:	83 c0 04             	add    $0x4,%eax
80104bbf:	83 ec 08             	sub    $0x8,%esp
80104bc2:	50                   	push   %eax
80104bc3:	ff 75 08             	pushl  0x8(%ebp)
80104bc6:	e8 79 fb ff ff       	call   80104744 <sleep>
80104bcb:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104bce:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd1:	8b 00                	mov    (%eax),%eax
80104bd3:	85 c0                	test   %eax,%eax
80104bd5:	75 e2                	jne    80104bb9 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bda:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104be0:	e8 b6 ef ff ff       	call   80103b9b <myproc>
80104be5:	8b 50 10             	mov    0x10(%eax),%edx
80104be8:	8b 45 08             	mov    0x8(%ebp),%eax
80104beb:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104bee:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf1:	83 c0 04             	add    $0x4,%eax
80104bf4:	83 ec 0c             	sub    $0xc,%esp
80104bf7:	50                   	push   %eax
80104bf8:	e8 63 01 00 00       	call   80104d60 <release>
80104bfd:	83 c4 10             	add    $0x10,%esp
}
80104c00:	90                   	nop
80104c01:	c9                   	leave  
80104c02:	c3                   	ret    

80104c03 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104c03:	f3 0f 1e fb          	endbr32 
80104c07:	55                   	push   %ebp
80104c08:	89 e5                	mov    %esp,%ebp
80104c0a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c10:	83 c0 04             	add    $0x4,%eax
80104c13:	83 ec 0c             	sub    $0xc,%esp
80104c16:	50                   	push   %eax
80104c17:	e8 d2 00 00 00       	call   80104cee <acquire>
80104c1c:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c22:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104c28:	8b 45 08             	mov    0x8(%ebp),%eax
80104c2b:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104c32:	83 ec 0c             	sub    $0xc,%esp
80104c35:	ff 75 08             	pushl  0x8(%ebp)
80104c38:	e8 f9 fb ff ff       	call   80104836 <wakeup>
80104c3d:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104c40:	8b 45 08             	mov    0x8(%ebp),%eax
80104c43:	83 c0 04             	add    $0x4,%eax
80104c46:	83 ec 0c             	sub    $0xc,%esp
80104c49:	50                   	push   %eax
80104c4a:	e8 11 01 00 00       	call   80104d60 <release>
80104c4f:	83 c4 10             	add    $0x10,%esp
}
80104c52:	90                   	nop
80104c53:	c9                   	leave  
80104c54:	c3                   	ret    

80104c55 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104c55:	f3 0f 1e fb          	endbr32 
80104c59:	55                   	push   %ebp
80104c5a:	89 e5                	mov    %esp,%ebp
80104c5c:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c62:	83 c0 04             	add    $0x4,%eax
80104c65:	83 ec 0c             	sub    $0xc,%esp
80104c68:	50                   	push   %eax
80104c69:	e8 80 00 00 00       	call   80104cee <acquire>
80104c6e:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104c71:	8b 45 08             	mov    0x8(%ebp),%eax
80104c74:	8b 00                	mov    (%eax),%eax
80104c76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104c79:	8b 45 08             	mov    0x8(%ebp),%eax
80104c7c:	83 c0 04             	add    $0x4,%eax
80104c7f:	83 ec 0c             	sub    $0xc,%esp
80104c82:	50                   	push   %eax
80104c83:	e8 d8 00 00 00       	call   80104d60 <release>
80104c88:	83 c4 10             	add    $0x10,%esp
  return r;
80104c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104c8e:	c9                   	leave  
80104c8f:	c3                   	ret    

80104c90 <readeflags>:
{
80104c90:	55                   	push   %ebp
80104c91:	89 e5                	mov    %esp,%ebp
80104c93:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104c96:	9c                   	pushf  
80104c97:	58                   	pop    %eax
80104c98:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104c9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104c9e:	c9                   	leave  
80104c9f:	c3                   	ret    

80104ca0 <cli>:
{
80104ca0:	55                   	push   %ebp
80104ca1:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ca3:	fa                   	cli    
}
80104ca4:	90                   	nop
80104ca5:	5d                   	pop    %ebp
80104ca6:	c3                   	ret    

80104ca7 <sti>:
{
80104ca7:	55                   	push   %ebp
80104ca8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104caa:	fb                   	sti    
}
80104cab:	90                   	nop
80104cac:	5d                   	pop    %ebp
80104cad:	c3                   	ret    

80104cae <xchg>:
{
80104cae:	55                   	push   %ebp
80104caf:	89 e5                	mov    %esp,%ebp
80104cb1:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104cb4:	8b 55 08             	mov    0x8(%ebp),%edx
80104cb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104cba:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104cbd:	f0 87 02             	lock xchg %eax,(%edx)
80104cc0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104cc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cc6:	c9                   	leave  
80104cc7:	c3                   	ret    

80104cc8 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104cc8:	f3 0f 1e fb          	endbr32 
80104ccc:	55                   	push   %ebp
80104ccd:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd2:	8b 55 0c             	mov    0xc(%ebp),%edx
80104cd5:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104ceb:	90                   	nop
80104cec:	5d                   	pop    %ebp
80104ced:	c3                   	ret    

80104cee <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104cee:	f3 0f 1e fb          	endbr32 
80104cf2:	55                   	push   %ebp
80104cf3:	89 e5                	mov    %esp,%ebp
80104cf5:	53                   	push   %ebx
80104cf6:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104cf9:	e8 6c 01 00 00       	call   80104e6a <pushcli>
  if(holding(lk)){
80104cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80104d01:	83 ec 0c             	sub    $0xc,%esp
80104d04:	50                   	push   %eax
80104d05:	e8 2b 01 00 00       	call   80104e35 <holding>
80104d0a:	83 c4 10             	add    $0x10,%esp
80104d0d:	85 c0                	test   %eax,%eax
80104d0f:	74 0d                	je     80104d1e <acquire+0x30>
    panic("acquire");
80104d11:	83 ec 0c             	sub    $0xc,%esp
80104d14:	68 92 ad 10 80       	push   $0x8010ad92
80104d19:	e8 a7 b8 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104d1e:	90                   	nop
80104d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104d22:	83 ec 08             	sub    $0x8,%esp
80104d25:	6a 01                	push   $0x1
80104d27:	50                   	push   %eax
80104d28:	e8 81 ff ff ff       	call   80104cae <xchg>
80104d2d:	83 c4 10             	add    $0x10,%esp
80104d30:	85 c0                	test   %eax,%eax
80104d32:	75 eb                	jne    80104d1f <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104d34:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104d39:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104d3c:	e8 de ed ff ff       	call   80103b1f <mycpu>
80104d41:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104d44:	8b 45 08             	mov    0x8(%ebp),%eax
80104d47:	83 c0 0c             	add    $0xc,%eax
80104d4a:	83 ec 08             	sub    $0x8,%esp
80104d4d:	50                   	push   %eax
80104d4e:	8d 45 08             	lea    0x8(%ebp),%eax
80104d51:	50                   	push   %eax
80104d52:	e8 5f 00 00 00       	call   80104db6 <getcallerpcs>
80104d57:	83 c4 10             	add    $0x10,%esp
}
80104d5a:	90                   	nop
80104d5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d5e:	c9                   	leave  
80104d5f:	c3                   	ret    

80104d60 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104d60:	f3 0f 1e fb          	endbr32 
80104d64:	55                   	push   %ebp
80104d65:	89 e5                	mov    %esp,%ebp
80104d67:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104d6a:	83 ec 0c             	sub    $0xc,%esp
80104d6d:	ff 75 08             	pushl  0x8(%ebp)
80104d70:	e8 c0 00 00 00       	call   80104e35 <holding>
80104d75:	83 c4 10             	add    $0x10,%esp
80104d78:	85 c0                	test   %eax,%eax
80104d7a:	75 0d                	jne    80104d89 <release+0x29>
    panic("release");
80104d7c:	83 ec 0c             	sub    $0xc,%esp
80104d7f:	68 9a ad 10 80       	push   $0x8010ad9a
80104d84:	e8 3c b8 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80104d89:	8b 45 08             	mov    0x8(%ebp),%eax
80104d8c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104d93:	8b 45 08             	mov    0x8(%ebp),%eax
80104d96:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104d9d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104da2:	8b 45 08             	mov    0x8(%ebp),%eax
80104da5:	8b 55 08             	mov    0x8(%ebp),%edx
80104da8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104dae:	e8 08 01 00 00       	call   80104ebb <popcli>
}
80104db3:	90                   	nop
80104db4:	c9                   	leave  
80104db5:	c3                   	ret    

80104db6 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104db6:	f3 0f 1e fb          	endbr32 
80104dba:	55                   	push   %ebp
80104dbb:	89 e5                	mov    %esp,%ebp
80104dbd:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80104dc3:	83 e8 08             	sub    $0x8,%eax
80104dc6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104dc9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104dd0:	eb 38                	jmp    80104e0a <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104dd2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104dd6:	74 53                	je     80104e2b <getcallerpcs+0x75>
80104dd8:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104ddf:	76 4a                	jbe    80104e2b <getcallerpcs+0x75>
80104de1:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104de5:	74 44                	je     80104e2b <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104de7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104dea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104df1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104df4:	01 c2                	add    %eax,%edx
80104df6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104df9:	8b 40 04             	mov    0x4(%eax),%eax
80104dfc:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104dfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e01:	8b 00                	mov    (%eax),%eax
80104e03:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104e06:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e0a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e0e:	7e c2                	jle    80104dd2 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80104e10:	eb 19                	jmp    80104e2b <getcallerpcs+0x75>
    pcs[i] = 0;
80104e12:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e1f:	01 d0                	add    %edx,%eax
80104e21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104e27:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104e2b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104e2f:	7e e1                	jle    80104e12 <getcallerpcs+0x5c>
}
80104e31:	90                   	nop
80104e32:	90                   	nop
80104e33:	c9                   	leave  
80104e34:	c3                   	ret    

80104e35 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104e35:	f3 0f 1e fb          	endbr32 
80104e39:	55                   	push   %ebp
80104e3a:	89 e5                	mov    %esp,%ebp
80104e3c:	53                   	push   %ebx
80104e3d:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104e40:	8b 45 08             	mov    0x8(%ebp),%eax
80104e43:	8b 00                	mov    (%eax),%eax
80104e45:	85 c0                	test   %eax,%eax
80104e47:	74 16                	je     80104e5f <holding+0x2a>
80104e49:	8b 45 08             	mov    0x8(%ebp),%eax
80104e4c:	8b 58 08             	mov    0x8(%eax),%ebx
80104e4f:	e8 cb ec ff ff       	call   80103b1f <mycpu>
80104e54:	39 c3                	cmp    %eax,%ebx
80104e56:	75 07                	jne    80104e5f <holding+0x2a>
80104e58:	b8 01 00 00 00       	mov    $0x1,%eax
80104e5d:	eb 05                	jmp    80104e64 <holding+0x2f>
80104e5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e64:	83 c4 04             	add    $0x4,%esp
80104e67:	5b                   	pop    %ebx
80104e68:	5d                   	pop    %ebp
80104e69:	c3                   	ret    

80104e6a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104e6a:	f3 0f 1e fb          	endbr32 
80104e6e:	55                   	push   %ebp
80104e6f:	89 e5                	mov    %esp,%ebp
80104e71:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104e74:	e8 17 fe ff ff       	call   80104c90 <readeflags>
80104e79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104e7c:	e8 1f fe ff ff       	call   80104ca0 <cli>
  if(mycpu()->ncli == 0)
80104e81:	e8 99 ec ff ff       	call   80103b1f <mycpu>
80104e86:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104e8c:	85 c0                	test   %eax,%eax
80104e8e:	75 14                	jne    80104ea4 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80104e90:	e8 8a ec ff ff       	call   80103b1f <mycpu>
80104e95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e98:	81 e2 00 02 00 00    	and    $0x200,%edx
80104e9e:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104ea4:	e8 76 ec ff ff       	call   80103b1f <mycpu>
80104ea9:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104eaf:	83 c2 01             	add    $0x1,%edx
80104eb2:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104eb8:	90                   	nop
80104eb9:	c9                   	leave  
80104eba:	c3                   	ret    

80104ebb <popcli>:

void
popcli(void)
{
80104ebb:	f3 0f 1e fb          	endbr32 
80104ebf:	55                   	push   %ebp
80104ec0:	89 e5                	mov    %esp,%ebp
80104ec2:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104ec5:	e8 c6 fd ff ff       	call   80104c90 <readeflags>
80104eca:	25 00 02 00 00       	and    $0x200,%eax
80104ecf:	85 c0                	test   %eax,%eax
80104ed1:	74 0d                	je     80104ee0 <popcli+0x25>
    panic("popcli - interruptible");
80104ed3:	83 ec 0c             	sub    $0xc,%esp
80104ed6:	68 a2 ad 10 80       	push   $0x8010ada2
80104edb:	e8 e5 b6 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80104ee0:	e8 3a ec ff ff       	call   80103b1f <mycpu>
80104ee5:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104eeb:	83 ea 01             	sub    $0x1,%edx
80104eee:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104ef4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104efa:	85 c0                	test   %eax,%eax
80104efc:	79 0d                	jns    80104f0b <popcli+0x50>
    panic("popcli");
80104efe:	83 ec 0c             	sub    $0xc,%esp
80104f01:	68 b9 ad 10 80       	push   $0x8010adb9
80104f06:	e8 ba b6 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104f0b:	e8 0f ec ff ff       	call   80103b1f <mycpu>
80104f10:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f16:	85 c0                	test   %eax,%eax
80104f18:	75 14                	jne    80104f2e <popcli+0x73>
80104f1a:	e8 00 ec ff ff       	call   80103b1f <mycpu>
80104f1f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f25:	85 c0                	test   %eax,%eax
80104f27:	74 05                	je     80104f2e <popcli+0x73>
    sti();
80104f29:	e8 79 fd ff ff       	call   80104ca7 <sti>
}
80104f2e:	90                   	nop
80104f2f:	c9                   	leave  
80104f30:	c3                   	ret    

80104f31 <stosb>:
{
80104f31:	55                   	push   %ebp
80104f32:	89 e5                	mov    %esp,%ebp
80104f34:	57                   	push   %edi
80104f35:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f39:	8b 55 10             	mov    0x10(%ebp),%edx
80104f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f3f:	89 cb                	mov    %ecx,%ebx
80104f41:	89 df                	mov    %ebx,%edi
80104f43:	89 d1                	mov    %edx,%ecx
80104f45:	fc                   	cld    
80104f46:	f3 aa                	rep stos %al,%es:(%edi)
80104f48:	89 ca                	mov    %ecx,%edx
80104f4a:	89 fb                	mov    %edi,%ebx
80104f4c:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f4f:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104f52:	90                   	nop
80104f53:	5b                   	pop    %ebx
80104f54:	5f                   	pop    %edi
80104f55:	5d                   	pop    %ebp
80104f56:	c3                   	ret    

80104f57 <stosl>:
{
80104f57:	55                   	push   %ebp
80104f58:	89 e5                	mov    %esp,%ebp
80104f5a:	57                   	push   %edi
80104f5b:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104f5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104f5f:	8b 55 10             	mov    0x10(%ebp),%edx
80104f62:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f65:	89 cb                	mov    %ecx,%ebx
80104f67:	89 df                	mov    %ebx,%edi
80104f69:	89 d1                	mov    %edx,%ecx
80104f6b:	fc                   	cld    
80104f6c:	f3 ab                	rep stos %eax,%es:(%edi)
80104f6e:	89 ca                	mov    %ecx,%edx
80104f70:	89 fb                	mov    %edi,%ebx
80104f72:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104f75:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104f78:	90                   	nop
80104f79:	5b                   	pop    %ebx
80104f7a:	5f                   	pop    %edi
80104f7b:	5d                   	pop    %ebp
80104f7c:	c3                   	ret    

80104f7d <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104f7d:	f3 0f 1e fb          	endbr32 
80104f81:	55                   	push   %ebp
80104f82:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104f84:	8b 45 08             	mov    0x8(%ebp),%eax
80104f87:	83 e0 03             	and    $0x3,%eax
80104f8a:	85 c0                	test   %eax,%eax
80104f8c:	75 43                	jne    80104fd1 <memset+0x54>
80104f8e:	8b 45 10             	mov    0x10(%ebp),%eax
80104f91:	83 e0 03             	and    $0x3,%eax
80104f94:	85 c0                	test   %eax,%eax
80104f96:	75 39                	jne    80104fd1 <memset+0x54>
    c &= 0xFF;
80104f98:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104f9f:	8b 45 10             	mov    0x10(%ebp),%eax
80104fa2:	c1 e8 02             	shr    $0x2,%eax
80104fa5:	89 c1                	mov    %eax,%ecx
80104fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104faa:	c1 e0 18             	shl    $0x18,%eax
80104fad:	89 c2                	mov    %eax,%edx
80104faf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fb2:	c1 e0 10             	shl    $0x10,%eax
80104fb5:	09 c2                	or     %eax,%edx
80104fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fba:	c1 e0 08             	shl    $0x8,%eax
80104fbd:	09 d0                	or     %edx,%eax
80104fbf:	0b 45 0c             	or     0xc(%ebp),%eax
80104fc2:	51                   	push   %ecx
80104fc3:	50                   	push   %eax
80104fc4:	ff 75 08             	pushl  0x8(%ebp)
80104fc7:	e8 8b ff ff ff       	call   80104f57 <stosl>
80104fcc:	83 c4 0c             	add    $0xc,%esp
80104fcf:	eb 12                	jmp    80104fe3 <memset+0x66>
  } else
    stosb(dst, c, n);
80104fd1:	8b 45 10             	mov    0x10(%ebp),%eax
80104fd4:	50                   	push   %eax
80104fd5:	ff 75 0c             	pushl  0xc(%ebp)
80104fd8:	ff 75 08             	pushl  0x8(%ebp)
80104fdb:	e8 51 ff ff ff       	call   80104f31 <stosb>
80104fe0:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104fe3:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104fe6:	c9                   	leave  
80104fe7:	c3                   	ret    

80104fe8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104fe8:	f3 0f 1e fb          	endbr32 
80104fec:	55                   	push   %ebp
80104fed:	89 e5                	mov    %esp,%ebp
80104fef:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ffb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104ffe:	eb 30                	jmp    80105030 <memcmp+0x48>
    if(*s1 != *s2)
80105000:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105003:	0f b6 10             	movzbl (%eax),%edx
80105006:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105009:	0f b6 00             	movzbl (%eax),%eax
8010500c:	38 c2                	cmp    %al,%dl
8010500e:	74 18                	je     80105028 <memcmp+0x40>
      return *s1 - *s2;
80105010:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105013:	0f b6 00             	movzbl (%eax),%eax
80105016:	0f b6 d0             	movzbl %al,%edx
80105019:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010501c:	0f b6 00             	movzbl (%eax),%eax
8010501f:	0f b6 c0             	movzbl %al,%eax
80105022:	29 c2                	sub    %eax,%edx
80105024:	89 d0                	mov    %edx,%eax
80105026:	eb 1a                	jmp    80105042 <memcmp+0x5a>
    s1++, s2++;
80105028:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010502c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105030:	8b 45 10             	mov    0x10(%ebp),%eax
80105033:	8d 50 ff             	lea    -0x1(%eax),%edx
80105036:	89 55 10             	mov    %edx,0x10(%ebp)
80105039:	85 c0                	test   %eax,%eax
8010503b:	75 c3                	jne    80105000 <memcmp+0x18>
  }

  return 0;
8010503d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105042:	c9                   	leave  
80105043:	c3                   	ret    

80105044 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105044:	f3 0f 1e fb          	endbr32 
80105048:	55                   	push   %ebp
80105049:	89 e5                	mov    %esp,%ebp
8010504b:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010504e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105051:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105054:	8b 45 08             	mov    0x8(%ebp),%eax
80105057:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010505a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010505d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105060:	73 54                	jae    801050b6 <memmove+0x72>
80105062:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105065:	8b 45 10             	mov    0x10(%ebp),%eax
80105068:	01 d0                	add    %edx,%eax
8010506a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010506d:	73 47                	jae    801050b6 <memmove+0x72>
    s += n;
8010506f:	8b 45 10             	mov    0x10(%ebp),%eax
80105072:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105075:	8b 45 10             	mov    0x10(%ebp),%eax
80105078:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010507b:	eb 13                	jmp    80105090 <memmove+0x4c>
      *--d = *--s;
8010507d:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105081:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105085:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105088:	0f b6 10             	movzbl (%eax),%edx
8010508b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010508e:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105090:	8b 45 10             	mov    0x10(%ebp),%eax
80105093:	8d 50 ff             	lea    -0x1(%eax),%edx
80105096:	89 55 10             	mov    %edx,0x10(%ebp)
80105099:	85 c0                	test   %eax,%eax
8010509b:	75 e0                	jne    8010507d <memmove+0x39>
  if(s < d && s + n > d){
8010509d:	eb 24                	jmp    801050c3 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
8010509f:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050a2:	8d 42 01             	lea    0x1(%edx),%eax
801050a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801050a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050ab:	8d 48 01             	lea    0x1(%eax),%ecx
801050ae:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801050b1:	0f b6 12             	movzbl (%edx),%edx
801050b4:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801050b6:	8b 45 10             	mov    0x10(%ebp),%eax
801050b9:	8d 50 ff             	lea    -0x1(%eax),%edx
801050bc:	89 55 10             	mov    %edx,0x10(%ebp)
801050bf:	85 c0                	test   %eax,%eax
801050c1:	75 dc                	jne    8010509f <memmove+0x5b>

  return dst;
801050c3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801050c6:	c9                   	leave  
801050c7:	c3                   	ret    

801050c8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801050c8:	f3 0f 1e fb          	endbr32 
801050cc:	55                   	push   %ebp
801050cd:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801050cf:	ff 75 10             	pushl  0x10(%ebp)
801050d2:	ff 75 0c             	pushl  0xc(%ebp)
801050d5:	ff 75 08             	pushl  0x8(%ebp)
801050d8:	e8 67 ff ff ff       	call   80105044 <memmove>
801050dd:	83 c4 0c             	add    $0xc,%esp
}
801050e0:	c9                   	leave  
801050e1:	c3                   	ret    

801050e2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801050e2:	f3 0f 1e fb          	endbr32 
801050e6:	55                   	push   %ebp
801050e7:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801050e9:	eb 0c                	jmp    801050f7 <strncmp+0x15>
    n--, p++, q++;
801050eb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801050ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801050f3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801050f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050fb:	74 1a                	je     80105117 <strncmp+0x35>
801050fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105100:	0f b6 00             	movzbl (%eax),%eax
80105103:	84 c0                	test   %al,%al
80105105:	74 10                	je     80105117 <strncmp+0x35>
80105107:	8b 45 08             	mov    0x8(%ebp),%eax
8010510a:	0f b6 10             	movzbl (%eax),%edx
8010510d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105110:	0f b6 00             	movzbl (%eax),%eax
80105113:	38 c2                	cmp    %al,%dl
80105115:	74 d4                	je     801050eb <strncmp+0x9>
  if(n == 0)
80105117:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010511b:	75 07                	jne    80105124 <strncmp+0x42>
    return 0;
8010511d:	b8 00 00 00 00       	mov    $0x0,%eax
80105122:	eb 16                	jmp    8010513a <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80105124:	8b 45 08             	mov    0x8(%ebp),%eax
80105127:	0f b6 00             	movzbl (%eax),%eax
8010512a:	0f b6 d0             	movzbl %al,%edx
8010512d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105130:	0f b6 00             	movzbl (%eax),%eax
80105133:	0f b6 c0             	movzbl %al,%eax
80105136:	29 c2                	sub    %eax,%edx
80105138:	89 d0                	mov    %edx,%eax
}
8010513a:	5d                   	pop    %ebp
8010513b:	c3                   	ret    

8010513c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010513c:	f3 0f 1e fb          	endbr32 
80105140:	55                   	push   %ebp
80105141:	89 e5                	mov    %esp,%ebp
80105143:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105146:	8b 45 08             	mov    0x8(%ebp),%eax
80105149:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010514c:	90                   	nop
8010514d:	8b 45 10             	mov    0x10(%ebp),%eax
80105150:	8d 50 ff             	lea    -0x1(%eax),%edx
80105153:	89 55 10             	mov    %edx,0x10(%ebp)
80105156:	85 c0                	test   %eax,%eax
80105158:	7e 2c                	jle    80105186 <strncpy+0x4a>
8010515a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010515d:	8d 42 01             	lea    0x1(%edx),%eax
80105160:	89 45 0c             	mov    %eax,0xc(%ebp)
80105163:	8b 45 08             	mov    0x8(%ebp),%eax
80105166:	8d 48 01             	lea    0x1(%eax),%ecx
80105169:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010516c:	0f b6 12             	movzbl (%edx),%edx
8010516f:	88 10                	mov    %dl,(%eax)
80105171:	0f b6 00             	movzbl (%eax),%eax
80105174:	84 c0                	test   %al,%al
80105176:	75 d5                	jne    8010514d <strncpy+0x11>
    ;
  while(n-- > 0)
80105178:	eb 0c                	jmp    80105186 <strncpy+0x4a>
    *s++ = 0;
8010517a:	8b 45 08             	mov    0x8(%ebp),%eax
8010517d:	8d 50 01             	lea    0x1(%eax),%edx
80105180:	89 55 08             	mov    %edx,0x8(%ebp)
80105183:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105186:	8b 45 10             	mov    0x10(%ebp),%eax
80105189:	8d 50 ff             	lea    -0x1(%eax),%edx
8010518c:	89 55 10             	mov    %edx,0x10(%ebp)
8010518f:	85 c0                	test   %eax,%eax
80105191:	7f e7                	jg     8010517a <strncpy+0x3e>
  return os;
80105193:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105196:	c9                   	leave  
80105197:	c3                   	ret    

80105198 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105198:	f3 0f 1e fb          	endbr32 
8010519c:	55                   	push   %ebp
8010519d:	89 e5                	mov    %esp,%ebp
8010519f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801051a2:	8b 45 08             	mov    0x8(%ebp),%eax
801051a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801051a8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051ac:	7f 05                	jg     801051b3 <safestrcpy+0x1b>
    return os;
801051ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051b1:	eb 31                	jmp    801051e4 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801051b3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051bb:	7e 1e                	jle    801051db <safestrcpy+0x43>
801051bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801051c0:	8d 42 01             	lea    0x1(%edx),%eax
801051c3:	89 45 0c             	mov    %eax,0xc(%ebp)
801051c6:	8b 45 08             	mov    0x8(%ebp),%eax
801051c9:	8d 48 01             	lea    0x1(%eax),%ecx
801051cc:	89 4d 08             	mov    %ecx,0x8(%ebp)
801051cf:	0f b6 12             	movzbl (%edx),%edx
801051d2:	88 10                	mov    %dl,(%eax)
801051d4:	0f b6 00             	movzbl (%eax),%eax
801051d7:	84 c0                	test   %al,%al
801051d9:	75 d8                	jne    801051b3 <safestrcpy+0x1b>
    ;
  *s = 0;
801051db:	8b 45 08             	mov    0x8(%ebp),%eax
801051de:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801051e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051e4:	c9                   	leave  
801051e5:	c3                   	ret    

801051e6 <strlen>:

int
strlen(const char *s)
{
801051e6:	f3 0f 1e fb          	endbr32 
801051ea:	55                   	push   %ebp
801051eb:	89 e5                	mov    %esp,%ebp
801051ed:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801051f0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801051f7:	eb 04                	jmp    801051fd <strlen+0x17>
801051f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801051fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105200:	8b 45 08             	mov    0x8(%ebp),%eax
80105203:	01 d0                	add    %edx,%eax
80105205:	0f b6 00             	movzbl (%eax),%eax
80105208:	84 c0                	test   %al,%al
8010520a:	75 ed                	jne    801051f9 <strlen+0x13>
    ;
  return n;
8010520c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010520f:	c9                   	leave  
80105210:	c3                   	ret    

80105211 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105211:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105215:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105219:	55                   	push   %ebp
  pushl %ebx
8010521a:	53                   	push   %ebx
  pushl %esi
8010521b:	56                   	push   %esi
  pushl %edi
8010521c:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010521d:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010521f:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105221:	5f                   	pop    %edi
  popl %esi
80105222:	5e                   	pop    %esi
  popl %ebx
80105223:	5b                   	pop    %ebx
  popl %ebp
80105224:	5d                   	pop    %ebp
  ret
80105225:	c3                   	ret    

80105226 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int* ip)
{
80105226:	f3 0f 1e fb          	endbr32 
8010522a:	55                   	push   %ebp
8010522b:	89 e5                	mov    %esp,%ebp
    if(addr>=TOP || addr+4>TOP)
8010522d:	81 7d 08 fe ff ff 7f 	cmpl   $0x7ffffffe,0x8(%ebp)
80105234:	77 0a                	ja     80105240 <fetchint+0x1a>
80105236:	8b 45 08             	mov    0x8(%ebp),%eax
80105239:	83 c0 04             	add    $0x4,%eax
8010523c:	85 c0                	test   %eax,%eax
8010523e:	79 07                	jns    80105247 <fetchint+0x21>
        return -1;
80105240:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105245:	eb 0f                	jmp    80105256 <fetchint+0x30>
    *ip = *(int*)(addr);
80105247:	8b 45 08             	mov    0x8(%ebp),%eax
8010524a:	8b 10                	mov    (%eax),%edx
8010524c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010524f:	89 10                	mov    %edx,(%eax)
    return 0;
80105251:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105256:	5d                   	pop    %ebp
80105257:	c3                   	ret    

80105258 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char** pp)
{
80105258:	f3 0f 1e fb          	endbr32 
8010525c:	55                   	push   %ebp
8010525d:	89 e5                	mov    %esp,%ebp
8010525f:	83 ec 10             	sub    $0x10,%esp
    char* s, * ep;

    if (addr >= TOP)
80105262:	81 7d 08 fe ff ff 7f 	cmpl   $0x7ffffffe,0x8(%ebp)
80105269:	76 07                	jbe    80105272 <fetchstr+0x1a>
        return -1;
8010526b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105270:	eb 42                	jmp    801052b4 <fetchstr+0x5c>
    *pp = (char*)addr;
80105272:	8b 55 08             	mov    0x8(%ebp),%edx
80105275:	8b 45 0c             	mov    0xc(%ebp),%eax
80105278:	89 10                	mov    %edx,(%eax)
    ep = (char*)(TOP);
8010527a:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
    for (s = *pp; s < ep; s++) {
80105281:	8b 45 0c             	mov    0xc(%ebp),%eax
80105284:	8b 00                	mov    (%eax),%eax
80105286:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105289:	eb 1c                	jmp    801052a7 <fetchstr+0x4f>
        if (*s == 0)
8010528b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010528e:	0f b6 00             	movzbl (%eax),%eax
80105291:	84 c0                	test   %al,%al
80105293:	75 0e                	jne    801052a3 <fetchstr+0x4b>
            return s - *pp;
80105295:	8b 45 0c             	mov    0xc(%ebp),%eax
80105298:	8b 00                	mov    (%eax),%eax
8010529a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010529d:	29 c2                	sub    %eax,%edx
8010529f:	89 d0                	mov    %edx,%eax
801052a1:	eb 11                	jmp    801052b4 <fetchstr+0x5c>
    for (s = *pp; s < ep; s++) {
801052a3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052ad:	72 dc                	jb     8010528b <fetchstr+0x33>
    }
    return -1;
801052af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052b4:	c9                   	leave  
801052b5:	c3                   	ret    

801052b6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int* ip)
{
801052b6:	f3 0f 1e fb          	endbr32 
801052ba:	55                   	push   %ebp
801052bb:	89 e5                	mov    %esp,%ebp
801052bd:	83 ec 08             	sub    $0x8,%esp
    return fetchint((myproc()->tf->esp) + 4 + 4 * n, ip);
801052c0:	e8 d6 e8 ff ff       	call   80103b9b <myproc>
801052c5:	8b 40 18             	mov    0x18(%eax),%eax
801052c8:	8b 40 44             	mov    0x44(%eax),%eax
801052cb:	8b 55 08             	mov    0x8(%ebp),%edx
801052ce:	c1 e2 02             	shl    $0x2,%edx
801052d1:	01 d0                	add    %edx,%eax
801052d3:	83 c0 04             	add    $0x4,%eax
801052d6:	83 ec 08             	sub    $0x8,%esp
801052d9:	ff 75 0c             	pushl  0xc(%ebp)
801052dc:	50                   	push   %eax
801052dd:	e8 44 ff ff ff       	call   80105226 <fetchint>
801052e2:	83 c4 10             	add    $0x10,%esp
}
801052e5:	c9                   	leave  
801052e6:	c3                   	ret    

801052e7 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char** pp, int size)
{
801052e7:	f3 0f 1e fb          	endbr32 
801052eb:	55                   	push   %ebp
801052ec:	89 e5                	mov    %esp,%ebp
801052ee:	83 ec 18             	sub    $0x18,%esp
    int i;

    if (argint(n, &i) < 0)
801052f1:	83 ec 08             	sub    $0x8,%esp
801052f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052f7:	50                   	push   %eax
801052f8:	ff 75 08             	pushl  0x8(%ebp)
801052fb:	e8 b6 ff ff ff       	call   801052b6 <argint>
80105300:	83 c4 10             	add    $0x10,%esp
80105303:	85 c0                	test   %eax,%eax
80105305:	79 07                	jns    8010530e <argptr+0x27>
        return -1;
80105307:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010530c:	eb 34                	jmp    80105342 <argptr+0x5b>
    if (size < 0 || (uint)i >= (TOP) || (uint)i + size > (TOP))
8010530e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105312:	78 18                	js     8010532c <argptr+0x45>
80105314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105317:	3d fe ff ff 7f       	cmp    $0x7ffffffe,%eax
8010531c:	77 0e                	ja     8010532c <argptr+0x45>
8010531e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105321:	89 c2                	mov    %eax,%edx
80105323:	8b 45 10             	mov    0x10(%ebp),%eax
80105326:	01 d0                	add    %edx,%eax
80105328:	85 c0                	test   %eax,%eax
8010532a:	79 07                	jns    80105333 <argptr+0x4c>
        return -1;
8010532c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105331:	eb 0f                	jmp    80105342 <argptr+0x5b>
    *pp = (char*)i;
80105333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105336:	89 c2                	mov    %eax,%edx
80105338:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533b:	89 10                	mov    %edx,(%eax)
    return 0;
8010533d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105342:	c9                   	leave  
80105343:	c3                   	ret    

80105344 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char** pp)
{
80105344:	f3 0f 1e fb          	endbr32 
80105348:	55                   	push   %ebp
80105349:	89 e5                	mov    %esp,%ebp
8010534b:	83 ec 18             	sub    $0x18,%esp
    int addr;
    if (argint(n, &addr) < 0)
8010534e:	83 ec 08             	sub    $0x8,%esp
80105351:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105354:	50                   	push   %eax
80105355:	ff 75 08             	pushl  0x8(%ebp)
80105358:	e8 59 ff ff ff       	call   801052b6 <argint>
8010535d:	83 c4 10             	add    $0x10,%esp
80105360:	85 c0                	test   %eax,%eax
80105362:	79 07                	jns    8010536b <argstr+0x27>
        return -1;
80105364:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105369:	eb 12                	jmp    8010537d <argstr+0x39>
    return fetchstr(addr, pp);
8010536b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010536e:	83 ec 08             	sub    $0x8,%esp
80105371:	ff 75 0c             	pushl  0xc(%ebp)
80105374:	50                   	push   %eax
80105375:	e8 de fe ff ff       	call   80105258 <fetchstr>
8010537a:	83 c4 10             	add    $0x10,%esp
}
8010537d:	c9                   	leave  
8010537e:	c3                   	ret    

8010537f <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
8010537f:	f3 0f 1e fb          	endbr32 
80105383:	55                   	push   %ebp
80105384:	89 e5                	mov    %esp,%ebp
80105386:	83 ec 18             	sub    $0x18,%esp
    int num;
    struct proc* curproc = myproc();
80105389:	e8 0d e8 ff ff       	call   80103b9b <myproc>
8010538e:	89 45 f4             	mov    %eax,-0xc(%ebp)

    num = curproc->tf->eax;
80105391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105394:	8b 40 18             	mov    0x18(%eax),%eax
80105397:	8b 40 1c             	mov    0x1c(%eax),%eax
8010539a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010539d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801053a1:	7e 2f                	jle    801053d2 <syscall+0x53>
801053a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053a6:	83 f8 19             	cmp    $0x19,%eax
801053a9:	77 27                	ja     801053d2 <syscall+0x53>
801053ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ae:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801053b5:	85 c0                	test   %eax,%eax
801053b7:	74 19                	je     801053d2 <syscall+0x53>
        curproc->tf->eax = syscalls[num]();
801053b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053bc:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801053c3:	ff d0                	call   *%eax
801053c5:	89 c2                	mov    %eax,%edx
801053c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ca:	8b 40 18             	mov    0x18(%eax),%eax
801053cd:	89 50 1c             	mov    %edx,0x1c(%eax)
801053d0:	eb 2c                	jmp    801053fe <syscall+0x7f>
    }
    else {
        cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801053d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d5:	8d 50 6c             	lea    0x6c(%eax),%edx
        cprintf("%d %s: unknown sys call %d\n",
801053d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053db:	8b 40 10             	mov    0x10(%eax),%eax
801053de:	ff 75 f0             	pushl  -0x10(%ebp)
801053e1:	52                   	push   %edx
801053e2:	50                   	push   %eax
801053e3:	68 c0 ad 10 80       	push   $0x8010adc0
801053e8:	e8 1f b0 ff ff       	call   8010040c <cprintf>
801053ed:	83 c4 10             	add    $0x10,%esp
        curproc->tf->eax = -1;
801053f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f3:	8b 40 18             	mov    0x18(%eax),%eax
801053f6:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
    }
801053fd:	90                   	nop
801053fe:	90                   	nop
801053ff:	c9                   	leave  
80105400:	c3                   	ret    

80105401 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105401:	f3 0f 1e fb          	endbr32 
80105405:	55                   	push   %ebp
80105406:	89 e5                	mov    %esp,%ebp
80105408:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010540b:	83 ec 08             	sub    $0x8,%esp
8010540e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105411:	50                   	push   %eax
80105412:	ff 75 08             	pushl  0x8(%ebp)
80105415:	e8 9c fe ff ff       	call   801052b6 <argint>
8010541a:	83 c4 10             	add    $0x10,%esp
8010541d:	85 c0                	test   %eax,%eax
8010541f:	79 07                	jns    80105428 <argfd+0x27>
    return -1;
80105421:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105426:	eb 4f                	jmp    80105477 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542b:	85 c0                	test   %eax,%eax
8010542d:	78 20                	js     8010544f <argfd+0x4e>
8010542f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105432:	83 f8 0f             	cmp    $0xf,%eax
80105435:	7f 18                	jg     8010544f <argfd+0x4e>
80105437:	e8 5f e7 ff ff       	call   80103b9b <myproc>
8010543c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010543f:	83 c2 08             	add    $0x8,%edx
80105442:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105446:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105449:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010544d:	75 07                	jne    80105456 <argfd+0x55>
    return -1;
8010544f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105454:	eb 21                	jmp    80105477 <argfd+0x76>
  if(pfd)
80105456:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010545a:	74 08                	je     80105464 <argfd+0x63>
    *pfd = fd;
8010545c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010545f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105462:	89 10                	mov    %edx,(%eax)
  if(pf)
80105464:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105468:	74 08                	je     80105472 <argfd+0x71>
    *pf = f;
8010546a:	8b 45 10             	mov    0x10(%ebp),%eax
8010546d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105470:	89 10                	mov    %edx,(%eax)
  return 0;
80105472:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105477:	c9                   	leave  
80105478:	c3                   	ret    

80105479 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105479:	f3 0f 1e fb          	endbr32 
8010547d:	55                   	push   %ebp
8010547e:	89 e5                	mov    %esp,%ebp
80105480:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105483:	e8 13 e7 ff ff       	call   80103b9b <myproc>
80105488:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010548b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105492:	eb 2a                	jmp    801054be <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105494:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105497:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010549a:	83 c2 08             	add    $0x8,%edx
8010549d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801054a1:	85 c0                	test   %eax,%eax
801054a3:	75 15                	jne    801054ba <fdalloc+0x41>
      curproc->ofile[fd] = f;
801054a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054ab:	8d 4a 08             	lea    0x8(%edx),%ecx
801054ae:	8b 55 08             	mov    0x8(%ebp),%edx
801054b1:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801054b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b8:	eb 0f                	jmp    801054c9 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
801054ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801054be:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801054c2:	7e d0                	jle    80105494 <fdalloc+0x1b>
    }
  }
  return -1;
801054c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801054c9:	c9                   	leave  
801054ca:	c3                   	ret    

801054cb <sys_dup>:

int
sys_dup(void)
{
801054cb:	f3 0f 1e fb          	endbr32 
801054cf:	55                   	push   %ebp
801054d0:	89 e5                	mov    %esp,%ebp
801054d2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801054d5:	83 ec 04             	sub    $0x4,%esp
801054d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054db:	50                   	push   %eax
801054dc:	6a 00                	push   $0x0
801054de:	6a 00                	push   $0x0
801054e0:	e8 1c ff ff ff       	call   80105401 <argfd>
801054e5:	83 c4 10             	add    $0x10,%esp
801054e8:	85 c0                	test   %eax,%eax
801054ea:	79 07                	jns    801054f3 <sys_dup+0x28>
    return -1;
801054ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054f1:	eb 31                	jmp    80105524 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801054f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f6:	83 ec 0c             	sub    $0xc,%esp
801054f9:	50                   	push   %eax
801054fa:	e8 7a ff ff ff       	call   80105479 <fdalloc>
801054ff:	83 c4 10             	add    $0x10,%esp
80105502:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105505:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105509:	79 07                	jns    80105512 <sys_dup+0x47>
    return -1;
8010550b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105510:	eb 12                	jmp    80105524 <sys_dup+0x59>
  filedup(f);
80105512:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105515:	83 ec 0c             	sub    $0xc,%esp
80105518:	50                   	push   %eax
80105519:	e8 68 bb ff ff       	call   80101086 <filedup>
8010551e:	83 c4 10             	add    $0x10,%esp
  return fd;
80105521:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105524:	c9                   	leave  
80105525:	c3                   	ret    

80105526 <sys_read>:

int
sys_read(void)
{
80105526:	f3 0f 1e fb          	endbr32 
8010552a:	55                   	push   %ebp
8010552b:	89 e5                	mov    %esp,%ebp
8010552d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105530:	83 ec 04             	sub    $0x4,%esp
80105533:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105536:	50                   	push   %eax
80105537:	6a 00                	push   $0x0
80105539:	6a 00                	push   $0x0
8010553b:	e8 c1 fe ff ff       	call   80105401 <argfd>
80105540:	83 c4 10             	add    $0x10,%esp
80105543:	85 c0                	test   %eax,%eax
80105545:	78 2e                	js     80105575 <sys_read+0x4f>
80105547:	83 ec 08             	sub    $0x8,%esp
8010554a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010554d:	50                   	push   %eax
8010554e:	6a 02                	push   $0x2
80105550:	e8 61 fd ff ff       	call   801052b6 <argint>
80105555:	83 c4 10             	add    $0x10,%esp
80105558:	85 c0                	test   %eax,%eax
8010555a:	78 19                	js     80105575 <sys_read+0x4f>
8010555c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010555f:	83 ec 04             	sub    $0x4,%esp
80105562:	50                   	push   %eax
80105563:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105566:	50                   	push   %eax
80105567:	6a 01                	push   $0x1
80105569:	e8 79 fd ff ff       	call   801052e7 <argptr>
8010556e:	83 c4 10             	add    $0x10,%esp
80105571:	85 c0                	test   %eax,%eax
80105573:	79 07                	jns    8010557c <sys_read+0x56>
    return -1;
80105575:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010557a:	eb 17                	jmp    80105593 <sys_read+0x6d>
  return fileread(f, p, n);
8010557c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010557f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105585:	83 ec 04             	sub    $0x4,%esp
80105588:	51                   	push   %ecx
80105589:	52                   	push   %edx
8010558a:	50                   	push   %eax
8010558b:	e8 92 bc ff ff       	call   80101222 <fileread>
80105590:	83 c4 10             	add    $0x10,%esp
}
80105593:	c9                   	leave  
80105594:	c3                   	ret    

80105595 <sys_write>:

int
sys_write(void)
{
80105595:	f3 0f 1e fb          	endbr32 
80105599:	55                   	push   %ebp
8010559a:	89 e5                	mov    %esp,%ebp
8010559c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010559f:	83 ec 04             	sub    $0x4,%esp
801055a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055a5:	50                   	push   %eax
801055a6:	6a 00                	push   $0x0
801055a8:	6a 00                	push   $0x0
801055aa:	e8 52 fe ff ff       	call   80105401 <argfd>
801055af:	83 c4 10             	add    $0x10,%esp
801055b2:	85 c0                	test   %eax,%eax
801055b4:	78 2e                	js     801055e4 <sys_write+0x4f>
801055b6:	83 ec 08             	sub    $0x8,%esp
801055b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055bc:	50                   	push   %eax
801055bd:	6a 02                	push   $0x2
801055bf:	e8 f2 fc ff ff       	call   801052b6 <argint>
801055c4:	83 c4 10             	add    $0x10,%esp
801055c7:	85 c0                	test   %eax,%eax
801055c9:	78 19                	js     801055e4 <sys_write+0x4f>
801055cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055ce:	83 ec 04             	sub    $0x4,%esp
801055d1:	50                   	push   %eax
801055d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801055d5:	50                   	push   %eax
801055d6:	6a 01                	push   $0x1
801055d8:	e8 0a fd ff ff       	call   801052e7 <argptr>
801055dd:	83 c4 10             	add    $0x10,%esp
801055e0:	85 c0                	test   %eax,%eax
801055e2:	79 07                	jns    801055eb <sys_write+0x56>
    return -1;
801055e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055e9:	eb 17                	jmp    80105602 <sys_write+0x6d>
  return filewrite(f, p, n);
801055eb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801055ee:	8b 55 ec             	mov    -0x14(%ebp),%edx
801055f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f4:	83 ec 04             	sub    $0x4,%esp
801055f7:	51                   	push   %ecx
801055f8:	52                   	push   %edx
801055f9:	50                   	push   %eax
801055fa:	e8 df bc ff ff       	call   801012de <filewrite>
801055ff:	83 c4 10             	add    $0x10,%esp
}
80105602:	c9                   	leave  
80105603:	c3                   	ret    

80105604 <sys_close>:

int
sys_close(void)
{
80105604:	f3 0f 1e fb          	endbr32 
80105608:	55                   	push   %ebp
80105609:	89 e5                	mov    %esp,%ebp
8010560b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
8010560e:	83 ec 04             	sub    $0x4,%esp
80105611:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105614:	50                   	push   %eax
80105615:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105618:	50                   	push   %eax
80105619:	6a 00                	push   $0x0
8010561b:	e8 e1 fd ff ff       	call   80105401 <argfd>
80105620:	83 c4 10             	add    $0x10,%esp
80105623:	85 c0                	test   %eax,%eax
80105625:	79 07                	jns    8010562e <sys_close+0x2a>
    return -1;
80105627:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010562c:	eb 27                	jmp    80105655 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
8010562e:	e8 68 e5 ff ff       	call   80103b9b <myproc>
80105633:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105636:	83 c2 08             	add    $0x8,%edx
80105639:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105640:	00 
  fileclose(f);
80105641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105644:	83 ec 0c             	sub    $0xc,%esp
80105647:	50                   	push   %eax
80105648:	e8 8e ba ff ff       	call   801010db <fileclose>
8010564d:	83 c4 10             	add    $0x10,%esp
  return 0;
80105650:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105655:	c9                   	leave  
80105656:	c3                   	ret    

80105657 <sys_fstat>:

int
sys_fstat(void)
{
80105657:	f3 0f 1e fb          	endbr32 
8010565b:	55                   	push   %ebp
8010565c:	89 e5                	mov    %esp,%ebp
8010565e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105661:	83 ec 04             	sub    $0x4,%esp
80105664:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105667:	50                   	push   %eax
80105668:	6a 00                	push   $0x0
8010566a:	6a 00                	push   $0x0
8010566c:	e8 90 fd ff ff       	call   80105401 <argfd>
80105671:	83 c4 10             	add    $0x10,%esp
80105674:	85 c0                	test   %eax,%eax
80105676:	78 17                	js     8010568f <sys_fstat+0x38>
80105678:	83 ec 04             	sub    $0x4,%esp
8010567b:	6a 14                	push   $0x14
8010567d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105680:	50                   	push   %eax
80105681:	6a 01                	push   $0x1
80105683:	e8 5f fc ff ff       	call   801052e7 <argptr>
80105688:	83 c4 10             	add    $0x10,%esp
8010568b:	85 c0                	test   %eax,%eax
8010568d:	79 07                	jns    80105696 <sys_fstat+0x3f>
    return -1;
8010568f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105694:	eb 13                	jmp    801056a9 <sys_fstat+0x52>
  return filestat(f, st);
80105696:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010569c:	83 ec 08             	sub    $0x8,%esp
8010569f:	52                   	push   %edx
801056a0:	50                   	push   %eax
801056a1:	e8 21 bb ff ff       	call   801011c7 <filestat>
801056a6:	83 c4 10             	add    $0x10,%esp
}
801056a9:	c9                   	leave  
801056aa:	c3                   	ret    

801056ab <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801056ab:	f3 0f 1e fb          	endbr32 
801056af:	55                   	push   %ebp
801056b0:	89 e5                	mov    %esp,%ebp
801056b2:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801056b5:	83 ec 08             	sub    $0x8,%esp
801056b8:	8d 45 d8             	lea    -0x28(%ebp),%eax
801056bb:	50                   	push   %eax
801056bc:	6a 00                	push   $0x0
801056be:	e8 81 fc ff ff       	call   80105344 <argstr>
801056c3:	83 c4 10             	add    $0x10,%esp
801056c6:	85 c0                	test   %eax,%eax
801056c8:	78 15                	js     801056df <sys_link+0x34>
801056ca:	83 ec 08             	sub    $0x8,%esp
801056cd:	8d 45 dc             	lea    -0x24(%ebp),%eax
801056d0:	50                   	push   %eax
801056d1:	6a 01                	push   $0x1
801056d3:	e8 6c fc ff ff       	call   80105344 <argstr>
801056d8:	83 c4 10             	add    $0x10,%esp
801056db:	85 c0                	test   %eax,%eax
801056dd:	79 0a                	jns    801056e9 <sys_link+0x3e>
    return -1;
801056df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e4:	e9 68 01 00 00       	jmp    80105851 <sys_link+0x1a6>

  begin_op();
801056e9:	e8 75 da ff ff       	call   80103163 <begin_op>
  if((ip = namei(old)) == 0){
801056ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
801056f1:	83 ec 0c             	sub    $0xc,%esp
801056f4:	50                   	push   %eax
801056f5:	e8 df ce ff ff       	call   801025d9 <namei>
801056fa:	83 c4 10             	add    $0x10,%esp
801056fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105700:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105704:	75 0f                	jne    80105715 <sys_link+0x6a>
    end_op();
80105706:	e8 e8 da ff ff       	call   801031f3 <end_op>
    return -1;
8010570b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105710:	e9 3c 01 00 00       	jmp    80105851 <sys_link+0x1a6>
  }

  ilock(ip);
80105715:	83 ec 0c             	sub    $0xc,%esp
80105718:	ff 75 f4             	pushl  -0xc(%ebp)
8010571b:	e8 4e c3 ff ff       	call   80101a6e <ilock>
80105720:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105726:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010572a:	66 83 f8 01          	cmp    $0x1,%ax
8010572e:	75 1d                	jne    8010574d <sys_link+0xa2>
    iunlockput(ip);
80105730:	83 ec 0c             	sub    $0xc,%esp
80105733:	ff 75 f4             	pushl  -0xc(%ebp)
80105736:	e8 70 c5 ff ff       	call   80101cab <iunlockput>
8010573b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010573e:	e8 b0 da ff ff       	call   801031f3 <end_op>
    return -1;
80105743:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105748:	e9 04 01 00 00       	jmp    80105851 <sys_link+0x1a6>
  }

  ip->nlink++;
8010574d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105750:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105754:	83 c0 01             	add    $0x1,%eax
80105757:	89 c2                	mov    %eax,%edx
80105759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010575c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105760:	83 ec 0c             	sub    $0xc,%esp
80105763:	ff 75 f4             	pushl  -0xc(%ebp)
80105766:	e8 1a c1 ff ff       	call   80101885 <iupdate>
8010576b:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010576e:	83 ec 0c             	sub    $0xc,%esp
80105771:	ff 75 f4             	pushl  -0xc(%ebp)
80105774:	e8 0c c4 ff ff       	call   80101b85 <iunlock>
80105779:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010577c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010577f:	83 ec 08             	sub    $0x8,%esp
80105782:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105785:	52                   	push   %edx
80105786:	50                   	push   %eax
80105787:	e8 6d ce ff ff       	call   801025f9 <nameiparent>
8010578c:	83 c4 10             	add    $0x10,%esp
8010578f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105792:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105796:	74 71                	je     80105809 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105798:	83 ec 0c             	sub    $0xc,%esp
8010579b:	ff 75 f0             	pushl  -0x10(%ebp)
8010579e:	e8 cb c2 ff ff       	call   80101a6e <ilock>
801057a3:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801057a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a9:	8b 10                	mov    (%eax),%edx
801057ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ae:	8b 00                	mov    (%eax),%eax
801057b0:	39 c2                	cmp    %eax,%edx
801057b2:	75 1d                	jne    801057d1 <sys_link+0x126>
801057b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b7:	8b 40 04             	mov    0x4(%eax),%eax
801057ba:	83 ec 04             	sub    $0x4,%esp
801057bd:	50                   	push   %eax
801057be:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801057c1:	50                   	push   %eax
801057c2:	ff 75 f0             	pushl  -0x10(%ebp)
801057c5:	e8 6c cb ff ff       	call   80102336 <dirlink>
801057ca:	83 c4 10             	add    $0x10,%esp
801057cd:	85 c0                	test   %eax,%eax
801057cf:	79 10                	jns    801057e1 <sys_link+0x136>
    iunlockput(dp);
801057d1:	83 ec 0c             	sub    $0xc,%esp
801057d4:	ff 75 f0             	pushl  -0x10(%ebp)
801057d7:	e8 cf c4 ff ff       	call   80101cab <iunlockput>
801057dc:	83 c4 10             	add    $0x10,%esp
    goto bad;
801057df:	eb 29                	jmp    8010580a <sys_link+0x15f>
  }
  iunlockput(dp);
801057e1:	83 ec 0c             	sub    $0xc,%esp
801057e4:	ff 75 f0             	pushl  -0x10(%ebp)
801057e7:	e8 bf c4 ff ff       	call   80101cab <iunlockput>
801057ec:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801057ef:	83 ec 0c             	sub    $0xc,%esp
801057f2:	ff 75 f4             	pushl  -0xc(%ebp)
801057f5:	e8 dd c3 ff ff       	call   80101bd7 <iput>
801057fa:	83 c4 10             	add    $0x10,%esp

  end_op();
801057fd:	e8 f1 d9 ff ff       	call   801031f3 <end_op>

  return 0;
80105802:	b8 00 00 00 00       	mov    $0x0,%eax
80105807:	eb 48                	jmp    80105851 <sys_link+0x1a6>
    goto bad;
80105809:	90                   	nop

bad:
  ilock(ip);
8010580a:	83 ec 0c             	sub    $0xc,%esp
8010580d:	ff 75 f4             	pushl  -0xc(%ebp)
80105810:	e8 59 c2 ff ff       	call   80101a6e <ilock>
80105815:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010581b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010581f:	83 e8 01             	sub    $0x1,%eax
80105822:	89 c2                	mov    %eax,%edx
80105824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105827:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010582b:	83 ec 0c             	sub    $0xc,%esp
8010582e:	ff 75 f4             	pushl  -0xc(%ebp)
80105831:	e8 4f c0 ff ff       	call   80101885 <iupdate>
80105836:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105839:	83 ec 0c             	sub    $0xc,%esp
8010583c:	ff 75 f4             	pushl  -0xc(%ebp)
8010583f:	e8 67 c4 ff ff       	call   80101cab <iunlockput>
80105844:	83 c4 10             	add    $0x10,%esp
  end_op();
80105847:	e8 a7 d9 ff ff       	call   801031f3 <end_op>
  return -1;
8010584c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105851:	c9                   	leave  
80105852:	c3                   	ret    

80105853 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105853:	f3 0f 1e fb          	endbr32 
80105857:	55                   	push   %ebp
80105858:	89 e5                	mov    %esp,%ebp
8010585a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010585d:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105864:	eb 40                	jmp    801058a6 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105869:	6a 10                	push   $0x10
8010586b:	50                   	push   %eax
8010586c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010586f:	50                   	push   %eax
80105870:	ff 75 08             	pushl  0x8(%ebp)
80105873:	e8 fe c6 ff ff       	call   80101f76 <readi>
80105878:	83 c4 10             	add    $0x10,%esp
8010587b:	83 f8 10             	cmp    $0x10,%eax
8010587e:	74 0d                	je     8010588d <isdirempty+0x3a>
      panic("isdirempty: readi");
80105880:	83 ec 0c             	sub    $0xc,%esp
80105883:	68 dc ad 10 80       	push   $0x8010addc
80105888:	e8 38 ad ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
8010588d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105891:	66 85 c0             	test   %ax,%ax
80105894:	74 07                	je     8010589d <isdirempty+0x4a>
      return 0;
80105896:	b8 00 00 00 00       	mov    $0x0,%eax
8010589b:	eb 1b                	jmp    801058b8 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010589d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a0:	83 c0 10             	add    $0x10,%eax
801058a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058a6:	8b 45 08             	mov    0x8(%ebp),%eax
801058a9:	8b 50 58             	mov    0x58(%eax),%edx
801058ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058af:	39 c2                	cmp    %eax,%edx
801058b1:	77 b3                	ja     80105866 <isdirempty+0x13>
  }
  return 1;
801058b3:	b8 01 00 00 00       	mov    $0x1,%eax
}
801058b8:	c9                   	leave  
801058b9:	c3                   	ret    

801058ba <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801058ba:	f3 0f 1e fb          	endbr32 
801058be:	55                   	push   %ebp
801058bf:	89 e5                	mov    %esp,%ebp
801058c1:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801058c4:	83 ec 08             	sub    $0x8,%esp
801058c7:	8d 45 cc             	lea    -0x34(%ebp),%eax
801058ca:	50                   	push   %eax
801058cb:	6a 00                	push   $0x0
801058cd:	e8 72 fa ff ff       	call   80105344 <argstr>
801058d2:	83 c4 10             	add    $0x10,%esp
801058d5:	85 c0                	test   %eax,%eax
801058d7:	79 0a                	jns    801058e3 <sys_unlink+0x29>
    return -1;
801058d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058de:	e9 bf 01 00 00       	jmp    80105aa2 <sys_unlink+0x1e8>

  begin_op();
801058e3:	e8 7b d8 ff ff       	call   80103163 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801058e8:	8b 45 cc             	mov    -0x34(%ebp),%eax
801058eb:	83 ec 08             	sub    $0x8,%esp
801058ee:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801058f1:	52                   	push   %edx
801058f2:	50                   	push   %eax
801058f3:	e8 01 cd ff ff       	call   801025f9 <nameiparent>
801058f8:	83 c4 10             	add    $0x10,%esp
801058fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105902:	75 0f                	jne    80105913 <sys_unlink+0x59>
    end_op();
80105904:	e8 ea d8 ff ff       	call   801031f3 <end_op>
    return -1;
80105909:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010590e:	e9 8f 01 00 00       	jmp    80105aa2 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105913:	83 ec 0c             	sub    $0xc,%esp
80105916:	ff 75 f4             	pushl  -0xc(%ebp)
80105919:	e8 50 c1 ff ff       	call   80101a6e <ilock>
8010591e:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105921:	83 ec 08             	sub    $0x8,%esp
80105924:	68 ee ad 10 80       	push   $0x8010adee
80105929:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010592c:	50                   	push   %eax
8010592d:	e8 27 c9 ff ff       	call   80102259 <namecmp>
80105932:	83 c4 10             	add    $0x10,%esp
80105935:	85 c0                	test   %eax,%eax
80105937:	0f 84 49 01 00 00    	je     80105a86 <sys_unlink+0x1cc>
8010593d:	83 ec 08             	sub    $0x8,%esp
80105940:	68 f0 ad 10 80       	push   $0x8010adf0
80105945:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105948:	50                   	push   %eax
80105949:	e8 0b c9 ff ff       	call   80102259 <namecmp>
8010594e:	83 c4 10             	add    $0x10,%esp
80105951:	85 c0                	test   %eax,%eax
80105953:	0f 84 2d 01 00 00    	je     80105a86 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105959:	83 ec 04             	sub    $0x4,%esp
8010595c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010595f:	50                   	push   %eax
80105960:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105963:	50                   	push   %eax
80105964:	ff 75 f4             	pushl  -0xc(%ebp)
80105967:	e8 0c c9 ff ff       	call   80102278 <dirlookup>
8010596c:	83 c4 10             	add    $0x10,%esp
8010596f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105972:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105976:	0f 84 0d 01 00 00    	je     80105a89 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
8010597c:	83 ec 0c             	sub    $0xc,%esp
8010597f:	ff 75 f0             	pushl  -0x10(%ebp)
80105982:	e8 e7 c0 ff ff       	call   80101a6e <ilock>
80105987:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010598a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105991:	66 85 c0             	test   %ax,%ax
80105994:	7f 0d                	jg     801059a3 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105996:	83 ec 0c             	sub    $0xc,%esp
80105999:	68 f3 ad 10 80       	push   $0x8010adf3
8010599e:	e8 22 ac ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801059a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801059aa:	66 83 f8 01          	cmp    $0x1,%ax
801059ae:	75 25                	jne    801059d5 <sys_unlink+0x11b>
801059b0:	83 ec 0c             	sub    $0xc,%esp
801059b3:	ff 75 f0             	pushl  -0x10(%ebp)
801059b6:	e8 98 fe ff ff       	call   80105853 <isdirempty>
801059bb:	83 c4 10             	add    $0x10,%esp
801059be:	85 c0                	test   %eax,%eax
801059c0:	75 13                	jne    801059d5 <sys_unlink+0x11b>
    iunlockput(ip);
801059c2:	83 ec 0c             	sub    $0xc,%esp
801059c5:	ff 75 f0             	pushl  -0x10(%ebp)
801059c8:	e8 de c2 ff ff       	call   80101cab <iunlockput>
801059cd:	83 c4 10             	add    $0x10,%esp
    goto bad;
801059d0:	e9 b5 00 00 00       	jmp    80105a8a <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
801059d5:	83 ec 04             	sub    $0x4,%esp
801059d8:	6a 10                	push   $0x10
801059da:	6a 00                	push   $0x0
801059dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801059df:	50                   	push   %eax
801059e0:	e8 98 f5 ff ff       	call   80104f7d <memset>
801059e5:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801059e8:	8b 45 c8             	mov    -0x38(%ebp),%eax
801059eb:	6a 10                	push   $0x10
801059ed:	50                   	push   %eax
801059ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
801059f1:	50                   	push   %eax
801059f2:	ff 75 f4             	pushl  -0xc(%ebp)
801059f5:	e8 d5 c6 ff ff       	call   801020cf <writei>
801059fa:	83 c4 10             	add    $0x10,%esp
801059fd:	83 f8 10             	cmp    $0x10,%eax
80105a00:	74 0d                	je     80105a0f <sys_unlink+0x155>
    panic("unlink: writei");
80105a02:	83 ec 0c             	sub    $0xc,%esp
80105a05:	68 05 ae 10 80       	push   $0x8010ae05
80105a0a:	e8 b6 ab ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a12:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a16:	66 83 f8 01          	cmp    $0x1,%ax
80105a1a:	75 21                	jne    80105a3d <sys_unlink+0x183>
    dp->nlink--;
80105a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a23:	83 e8 01             	sub    $0x1,%eax
80105a26:	89 c2                	mov    %eax,%edx
80105a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a2b:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105a2f:	83 ec 0c             	sub    $0xc,%esp
80105a32:	ff 75 f4             	pushl  -0xc(%ebp)
80105a35:	e8 4b be ff ff       	call   80101885 <iupdate>
80105a3a:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105a3d:	83 ec 0c             	sub    $0xc,%esp
80105a40:	ff 75 f4             	pushl  -0xc(%ebp)
80105a43:	e8 63 c2 ff ff       	call   80101cab <iunlockput>
80105a48:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a52:	83 e8 01             	sub    $0x1,%eax
80105a55:	89 c2                	mov    %eax,%edx
80105a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105a5e:	83 ec 0c             	sub    $0xc,%esp
80105a61:	ff 75 f0             	pushl  -0x10(%ebp)
80105a64:	e8 1c be ff ff       	call   80101885 <iupdate>
80105a69:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105a6c:	83 ec 0c             	sub    $0xc,%esp
80105a6f:	ff 75 f0             	pushl  -0x10(%ebp)
80105a72:	e8 34 c2 ff ff       	call   80101cab <iunlockput>
80105a77:	83 c4 10             	add    $0x10,%esp

  end_op();
80105a7a:	e8 74 d7 ff ff       	call   801031f3 <end_op>

  return 0;
80105a7f:	b8 00 00 00 00       	mov    $0x0,%eax
80105a84:	eb 1c                	jmp    80105aa2 <sys_unlink+0x1e8>
    goto bad;
80105a86:	90                   	nop
80105a87:	eb 01                	jmp    80105a8a <sys_unlink+0x1d0>
    goto bad;
80105a89:	90                   	nop

bad:
  iunlockput(dp);
80105a8a:	83 ec 0c             	sub    $0xc,%esp
80105a8d:	ff 75 f4             	pushl  -0xc(%ebp)
80105a90:	e8 16 c2 ff ff       	call   80101cab <iunlockput>
80105a95:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a98:	e8 56 d7 ff ff       	call   801031f3 <end_op>
  return -1;
80105a9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105aa2:	c9                   	leave  
80105aa3:	c3                   	ret    

80105aa4 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105aa4:	f3 0f 1e fb          	endbr32 
80105aa8:	55                   	push   %ebp
80105aa9:	89 e5                	mov    %esp,%ebp
80105aab:	83 ec 38             	sub    $0x38,%esp
80105aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105ab1:	8b 55 10             	mov    0x10(%ebp),%edx
80105ab4:	8b 45 14             	mov    0x14(%ebp),%eax
80105ab7:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105abb:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105abf:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105ac3:	83 ec 08             	sub    $0x8,%esp
80105ac6:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ac9:	50                   	push   %eax
80105aca:	ff 75 08             	pushl  0x8(%ebp)
80105acd:	e8 27 cb ff ff       	call   801025f9 <nameiparent>
80105ad2:	83 c4 10             	add    $0x10,%esp
80105ad5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ad8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105adc:	75 0a                	jne    80105ae8 <create+0x44>
    return 0;
80105ade:	b8 00 00 00 00       	mov    $0x0,%eax
80105ae3:	e9 90 01 00 00       	jmp    80105c78 <create+0x1d4>
  ilock(dp);
80105ae8:	83 ec 0c             	sub    $0xc,%esp
80105aeb:	ff 75 f4             	pushl  -0xc(%ebp)
80105aee:	e8 7b bf ff ff       	call   80101a6e <ilock>
80105af3:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105af6:	83 ec 04             	sub    $0x4,%esp
80105af9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105afc:	50                   	push   %eax
80105afd:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b00:	50                   	push   %eax
80105b01:	ff 75 f4             	pushl  -0xc(%ebp)
80105b04:	e8 6f c7 ff ff       	call   80102278 <dirlookup>
80105b09:	83 c4 10             	add    $0x10,%esp
80105b0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b0f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b13:	74 50                	je     80105b65 <create+0xc1>
    iunlockput(dp);
80105b15:	83 ec 0c             	sub    $0xc,%esp
80105b18:	ff 75 f4             	pushl  -0xc(%ebp)
80105b1b:	e8 8b c1 ff ff       	call   80101cab <iunlockput>
80105b20:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105b23:	83 ec 0c             	sub    $0xc,%esp
80105b26:	ff 75 f0             	pushl  -0x10(%ebp)
80105b29:	e8 40 bf ff ff       	call   80101a6e <ilock>
80105b2e:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105b31:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105b36:	75 15                	jne    80105b4d <create+0xa9>
80105b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b3b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105b3f:	66 83 f8 02          	cmp    $0x2,%ax
80105b43:	75 08                	jne    80105b4d <create+0xa9>
      return ip;
80105b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b48:	e9 2b 01 00 00       	jmp    80105c78 <create+0x1d4>
    iunlockput(ip);
80105b4d:	83 ec 0c             	sub    $0xc,%esp
80105b50:	ff 75 f0             	pushl  -0x10(%ebp)
80105b53:	e8 53 c1 ff ff       	call   80101cab <iunlockput>
80105b58:	83 c4 10             	add    $0x10,%esp
    return 0;
80105b5b:	b8 00 00 00 00       	mov    $0x0,%eax
80105b60:	e9 13 01 00 00       	jmp    80105c78 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105b65:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6c:	8b 00                	mov    (%eax),%eax
80105b6e:	83 ec 08             	sub    $0x8,%esp
80105b71:	52                   	push   %edx
80105b72:	50                   	push   %eax
80105b73:	e8 32 bc ff ff       	call   801017aa <ialloc>
80105b78:	83 c4 10             	add    $0x10,%esp
80105b7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b82:	75 0d                	jne    80105b91 <create+0xed>
    panic("create: ialloc");
80105b84:	83 ec 0c             	sub    $0xc,%esp
80105b87:	68 14 ae 10 80       	push   $0x8010ae14
80105b8c:	e8 34 aa ff ff       	call   801005c5 <panic>

  ilock(ip);
80105b91:	83 ec 0c             	sub    $0xc,%esp
80105b94:	ff 75 f0             	pushl  -0x10(%ebp)
80105b97:	e8 d2 be ff ff       	call   80101a6e <ilock>
80105b9c:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba2:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105ba6:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bad:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105bb1:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105bb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb8:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105bbe:	83 ec 0c             	sub    $0xc,%esp
80105bc1:	ff 75 f0             	pushl  -0x10(%ebp)
80105bc4:	e8 bc bc ff ff       	call   80101885 <iupdate>
80105bc9:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105bcc:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105bd1:	75 6a                	jne    80105c3d <create+0x199>
    dp->nlink++;  // for ".."
80105bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd6:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105bda:	83 c0 01             	add    $0x1,%eax
80105bdd:	89 c2                	mov    %eax,%edx
80105bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be2:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105be6:	83 ec 0c             	sub    $0xc,%esp
80105be9:	ff 75 f4             	pushl  -0xc(%ebp)
80105bec:	e8 94 bc ff ff       	call   80101885 <iupdate>
80105bf1:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf7:	8b 40 04             	mov    0x4(%eax),%eax
80105bfa:	83 ec 04             	sub    $0x4,%esp
80105bfd:	50                   	push   %eax
80105bfe:	68 ee ad 10 80       	push   $0x8010adee
80105c03:	ff 75 f0             	pushl  -0x10(%ebp)
80105c06:	e8 2b c7 ff ff       	call   80102336 <dirlink>
80105c0b:	83 c4 10             	add    $0x10,%esp
80105c0e:	85 c0                	test   %eax,%eax
80105c10:	78 1e                	js     80105c30 <create+0x18c>
80105c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c15:	8b 40 04             	mov    0x4(%eax),%eax
80105c18:	83 ec 04             	sub    $0x4,%esp
80105c1b:	50                   	push   %eax
80105c1c:	68 f0 ad 10 80       	push   $0x8010adf0
80105c21:	ff 75 f0             	pushl  -0x10(%ebp)
80105c24:	e8 0d c7 ff ff       	call   80102336 <dirlink>
80105c29:	83 c4 10             	add    $0x10,%esp
80105c2c:	85 c0                	test   %eax,%eax
80105c2e:	79 0d                	jns    80105c3d <create+0x199>
      panic("create dots");
80105c30:	83 ec 0c             	sub    $0xc,%esp
80105c33:	68 23 ae 10 80       	push   $0x8010ae23
80105c38:	e8 88 a9 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c40:	8b 40 04             	mov    0x4(%eax),%eax
80105c43:	83 ec 04             	sub    $0x4,%esp
80105c46:	50                   	push   %eax
80105c47:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c4a:	50                   	push   %eax
80105c4b:	ff 75 f4             	pushl  -0xc(%ebp)
80105c4e:	e8 e3 c6 ff ff       	call   80102336 <dirlink>
80105c53:	83 c4 10             	add    $0x10,%esp
80105c56:	85 c0                	test   %eax,%eax
80105c58:	79 0d                	jns    80105c67 <create+0x1c3>
    panic("create: dirlink");
80105c5a:	83 ec 0c             	sub    $0xc,%esp
80105c5d:	68 2f ae 10 80       	push   $0x8010ae2f
80105c62:	e8 5e a9 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80105c67:	83 ec 0c             	sub    $0xc,%esp
80105c6a:	ff 75 f4             	pushl  -0xc(%ebp)
80105c6d:	e8 39 c0 ff ff       	call   80101cab <iunlockput>
80105c72:	83 c4 10             	add    $0x10,%esp

  return ip;
80105c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105c78:	c9                   	leave  
80105c79:	c3                   	ret    

80105c7a <sys_open>:

int
sys_open(void)
{
80105c7a:	f3 0f 1e fb          	endbr32 
80105c7e:	55                   	push   %ebp
80105c7f:	89 e5                	mov    %esp,%ebp
80105c81:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105c84:	83 ec 08             	sub    $0x8,%esp
80105c87:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105c8a:	50                   	push   %eax
80105c8b:	6a 00                	push   $0x0
80105c8d:	e8 b2 f6 ff ff       	call   80105344 <argstr>
80105c92:	83 c4 10             	add    $0x10,%esp
80105c95:	85 c0                	test   %eax,%eax
80105c97:	78 15                	js     80105cae <sys_open+0x34>
80105c99:	83 ec 08             	sub    $0x8,%esp
80105c9c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c9f:	50                   	push   %eax
80105ca0:	6a 01                	push   $0x1
80105ca2:	e8 0f f6 ff ff       	call   801052b6 <argint>
80105ca7:	83 c4 10             	add    $0x10,%esp
80105caa:	85 c0                	test   %eax,%eax
80105cac:	79 0a                	jns    80105cb8 <sys_open+0x3e>
    return -1;
80105cae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cb3:	e9 61 01 00 00       	jmp    80105e19 <sys_open+0x19f>

  begin_op();
80105cb8:	e8 a6 d4 ff ff       	call   80103163 <begin_op>

  if(omode & O_CREATE){
80105cbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cc0:	25 00 02 00 00       	and    $0x200,%eax
80105cc5:	85 c0                	test   %eax,%eax
80105cc7:	74 2a                	je     80105cf3 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80105cc9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ccc:	6a 00                	push   $0x0
80105cce:	6a 00                	push   $0x0
80105cd0:	6a 02                	push   $0x2
80105cd2:	50                   	push   %eax
80105cd3:	e8 cc fd ff ff       	call   80105aa4 <create>
80105cd8:	83 c4 10             	add    $0x10,%esp
80105cdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105cde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ce2:	75 75                	jne    80105d59 <sys_open+0xdf>
      end_op();
80105ce4:	e8 0a d5 ff ff       	call   801031f3 <end_op>
      return -1;
80105ce9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cee:	e9 26 01 00 00       	jmp    80105e19 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80105cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105cf6:	83 ec 0c             	sub    $0xc,%esp
80105cf9:	50                   	push   %eax
80105cfa:	e8 da c8 ff ff       	call   801025d9 <namei>
80105cff:	83 c4 10             	add    $0x10,%esp
80105d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d09:	75 0f                	jne    80105d1a <sys_open+0xa0>
      end_op();
80105d0b:	e8 e3 d4 ff ff       	call   801031f3 <end_op>
      return -1;
80105d10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d15:	e9 ff 00 00 00       	jmp    80105e19 <sys_open+0x19f>
    }
    ilock(ip);
80105d1a:	83 ec 0c             	sub    $0xc,%esp
80105d1d:	ff 75 f4             	pushl  -0xc(%ebp)
80105d20:	e8 49 bd ff ff       	call   80101a6e <ilock>
80105d25:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d2f:	66 83 f8 01          	cmp    $0x1,%ax
80105d33:	75 24                	jne    80105d59 <sys_open+0xdf>
80105d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d38:	85 c0                	test   %eax,%eax
80105d3a:	74 1d                	je     80105d59 <sys_open+0xdf>
      iunlockput(ip);
80105d3c:	83 ec 0c             	sub    $0xc,%esp
80105d3f:	ff 75 f4             	pushl  -0xc(%ebp)
80105d42:	e8 64 bf ff ff       	call   80101cab <iunlockput>
80105d47:	83 c4 10             	add    $0x10,%esp
      end_op();
80105d4a:	e8 a4 d4 ff ff       	call   801031f3 <end_op>
      return -1;
80105d4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d54:	e9 c0 00 00 00       	jmp    80105e19 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105d59:	e8 b7 b2 ff ff       	call   80101015 <filealloc>
80105d5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d65:	74 17                	je     80105d7e <sys_open+0x104>
80105d67:	83 ec 0c             	sub    $0xc,%esp
80105d6a:	ff 75 f0             	pushl  -0x10(%ebp)
80105d6d:	e8 07 f7 ff ff       	call   80105479 <fdalloc>
80105d72:	83 c4 10             	add    $0x10,%esp
80105d75:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105d78:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105d7c:	79 2e                	jns    80105dac <sys_open+0x132>
    if(f)
80105d7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d82:	74 0e                	je     80105d92 <sys_open+0x118>
      fileclose(f);
80105d84:	83 ec 0c             	sub    $0xc,%esp
80105d87:	ff 75 f0             	pushl  -0x10(%ebp)
80105d8a:	e8 4c b3 ff ff       	call   801010db <fileclose>
80105d8f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105d92:	83 ec 0c             	sub    $0xc,%esp
80105d95:	ff 75 f4             	pushl  -0xc(%ebp)
80105d98:	e8 0e bf ff ff       	call   80101cab <iunlockput>
80105d9d:	83 c4 10             	add    $0x10,%esp
    end_op();
80105da0:	e8 4e d4 ff ff       	call   801031f3 <end_op>
    return -1;
80105da5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105daa:	eb 6d                	jmp    80105e19 <sys_open+0x19f>
  }
  iunlock(ip);
80105dac:	83 ec 0c             	sub    $0xc,%esp
80105daf:	ff 75 f4             	pushl  -0xc(%ebp)
80105db2:	e8 ce bd ff ff       	call   80101b85 <iunlock>
80105db7:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dba:	e8 34 d4 ff ff       	call   801031f3 <end_op>

  f->type = FD_INODE;
80105dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc2:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dce:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105dd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105ddb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dde:	83 e0 01             	and    $0x1,%eax
80105de1:	85 c0                	test   %eax,%eax
80105de3:	0f 94 c0             	sete   %al
80105de6:	89 c2                	mov    %eax,%edx
80105de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105deb:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105df1:	83 e0 01             	and    $0x1,%eax
80105df4:	85 c0                	test   %eax,%eax
80105df6:	75 0a                	jne    80105e02 <sys_open+0x188>
80105df8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105dfb:	83 e0 02             	and    $0x2,%eax
80105dfe:	85 c0                	test   %eax,%eax
80105e00:	74 07                	je     80105e09 <sys_open+0x18f>
80105e02:	b8 01 00 00 00       	mov    $0x1,%eax
80105e07:	eb 05                	jmp    80105e0e <sys_open+0x194>
80105e09:	b8 00 00 00 00       	mov    $0x0,%eax
80105e0e:	89 c2                	mov    %eax,%edx
80105e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e13:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105e16:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105e19:	c9                   	leave  
80105e1a:	c3                   	ret    

80105e1b <sys_mkdir>:

int
sys_mkdir(void)
{
80105e1b:	f3 0f 1e fb          	endbr32 
80105e1f:	55                   	push   %ebp
80105e20:	89 e5                	mov    %esp,%ebp
80105e22:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105e25:	e8 39 d3 ff ff       	call   80103163 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105e2a:	83 ec 08             	sub    $0x8,%esp
80105e2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e30:	50                   	push   %eax
80105e31:	6a 00                	push   $0x0
80105e33:	e8 0c f5 ff ff       	call   80105344 <argstr>
80105e38:	83 c4 10             	add    $0x10,%esp
80105e3b:	85 c0                	test   %eax,%eax
80105e3d:	78 1b                	js     80105e5a <sys_mkdir+0x3f>
80105e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e42:	6a 00                	push   $0x0
80105e44:	6a 00                	push   $0x0
80105e46:	6a 01                	push   $0x1
80105e48:	50                   	push   %eax
80105e49:	e8 56 fc ff ff       	call   80105aa4 <create>
80105e4e:	83 c4 10             	add    $0x10,%esp
80105e51:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e58:	75 0c                	jne    80105e66 <sys_mkdir+0x4b>
    end_op();
80105e5a:	e8 94 d3 ff ff       	call   801031f3 <end_op>
    return -1;
80105e5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e64:	eb 18                	jmp    80105e7e <sys_mkdir+0x63>
  }
  iunlockput(ip);
80105e66:	83 ec 0c             	sub    $0xc,%esp
80105e69:	ff 75 f4             	pushl  -0xc(%ebp)
80105e6c:	e8 3a be ff ff       	call   80101cab <iunlockput>
80105e71:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e74:	e8 7a d3 ff ff       	call   801031f3 <end_op>
  return 0;
80105e79:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e7e:	c9                   	leave  
80105e7f:	c3                   	ret    

80105e80 <sys_mknod>:

int
sys_mknod(void)
{
80105e80:	f3 0f 1e fb          	endbr32 
80105e84:	55                   	push   %ebp
80105e85:	89 e5                	mov    %esp,%ebp
80105e87:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105e8a:	e8 d4 d2 ff ff       	call   80103163 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105e8f:	83 ec 08             	sub    $0x8,%esp
80105e92:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e95:	50                   	push   %eax
80105e96:	6a 00                	push   $0x0
80105e98:	e8 a7 f4 ff ff       	call   80105344 <argstr>
80105e9d:	83 c4 10             	add    $0x10,%esp
80105ea0:	85 c0                	test   %eax,%eax
80105ea2:	78 4f                	js     80105ef3 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80105ea4:	83 ec 08             	sub    $0x8,%esp
80105ea7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105eaa:	50                   	push   %eax
80105eab:	6a 01                	push   $0x1
80105ead:	e8 04 f4 ff ff       	call   801052b6 <argint>
80105eb2:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105eb5:	85 c0                	test   %eax,%eax
80105eb7:	78 3a                	js     80105ef3 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80105eb9:	83 ec 08             	sub    $0x8,%esp
80105ebc:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ebf:	50                   	push   %eax
80105ec0:	6a 02                	push   $0x2
80105ec2:	e8 ef f3 ff ff       	call   801052b6 <argint>
80105ec7:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105eca:	85 c0                	test   %eax,%eax
80105ecc:	78 25                	js     80105ef3 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105ece:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ed1:	0f bf c8             	movswl %ax,%ecx
80105ed4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ed7:	0f bf d0             	movswl %ax,%edx
80105eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105edd:	51                   	push   %ecx
80105ede:	52                   	push   %edx
80105edf:	6a 03                	push   $0x3
80105ee1:	50                   	push   %eax
80105ee2:	e8 bd fb ff ff       	call   80105aa4 <create>
80105ee7:	83 c4 10             	add    $0x10,%esp
80105eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105eed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ef1:	75 0c                	jne    80105eff <sys_mknod+0x7f>
    end_op();
80105ef3:	e8 fb d2 ff ff       	call   801031f3 <end_op>
    return -1;
80105ef8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105efd:	eb 18                	jmp    80105f17 <sys_mknod+0x97>
  }
  iunlockput(ip);
80105eff:	83 ec 0c             	sub    $0xc,%esp
80105f02:	ff 75 f4             	pushl  -0xc(%ebp)
80105f05:	e8 a1 bd ff ff       	call   80101cab <iunlockput>
80105f0a:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f0d:	e8 e1 d2 ff ff       	call   801031f3 <end_op>
  return 0;
80105f12:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f17:	c9                   	leave  
80105f18:	c3                   	ret    

80105f19 <sys_chdir>:

int
sys_chdir(void)
{
80105f19:	f3 0f 1e fb          	endbr32 
80105f1d:	55                   	push   %ebp
80105f1e:	89 e5                	mov    %esp,%ebp
80105f20:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105f23:	e8 73 dc ff ff       	call   80103b9b <myproc>
80105f28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105f2b:	e8 33 d2 ff ff       	call   80103163 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105f30:	83 ec 08             	sub    $0x8,%esp
80105f33:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f36:	50                   	push   %eax
80105f37:	6a 00                	push   $0x0
80105f39:	e8 06 f4 ff ff       	call   80105344 <argstr>
80105f3e:	83 c4 10             	add    $0x10,%esp
80105f41:	85 c0                	test   %eax,%eax
80105f43:	78 18                	js     80105f5d <sys_chdir+0x44>
80105f45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f48:	83 ec 0c             	sub    $0xc,%esp
80105f4b:	50                   	push   %eax
80105f4c:	e8 88 c6 ff ff       	call   801025d9 <namei>
80105f51:	83 c4 10             	add    $0x10,%esp
80105f54:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f5b:	75 0c                	jne    80105f69 <sys_chdir+0x50>
    end_op();
80105f5d:	e8 91 d2 ff ff       	call   801031f3 <end_op>
    return -1;
80105f62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f67:	eb 68                	jmp    80105fd1 <sys_chdir+0xb8>
  }
  ilock(ip);
80105f69:	83 ec 0c             	sub    $0xc,%esp
80105f6c:	ff 75 f0             	pushl  -0x10(%ebp)
80105f6f:	e8 fa ba ff ff       	call   80101a6e <ilock>
80105f74:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f7e:	66 83 f8 01          	cmp    $0x1,%ax
80105f82:	74 1a                	je     80105f9e <sys_chdir+0x85>
    iunlockput(ip);
80105f84:	83 ec 0c             	sub    $0xc,%esp
80105f87:	ff 75 f0             	pushl  -0x10(%ebp)
80105f8a:	e8 1c bd ff ff       	call   80101cab <iunlockput>
80105f8f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105f92:	e8 5c d2 ff ff       	call   801031f3 <end_op>
    return -1;
80105f97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f9c:	eb 33                	jmp    80105fd1 <sys_chdir+0xb8>
  }
  iunlock(ip);
80105f9e:	83 ec 0c             	sub    $0xc,%esp
80105fa1:	ff 75 f0             	pushl  -0x10(%ebp)
80105fa4:	e8 dc bb ff ff       	call   80101b85 <iunlock>
80105fa9:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105faf:	8b 40 68             	mov    0x68(%eax),%eax
80105fb2:	83 ec 0c             	sub    $0xc,%esp
80105fb5:	50                   	push   %eax
80105fb6:	e8 1c bc ff ff       	call   80101bd7 <iput>
80105fbb:	83 c4 10             	add    $0x10,%esp
  end_op();
80105fbe:	e8 30 d2 ff ff       	call   801031f3 <end_op>
  curproc->cwd = ip;
80105fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fc9:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105fcc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fd1:	c9                   	leave  
80105fd2:	c3                   	ret    

80105fd3 <sys_exec>:

int
sys_exec(void)
{
80105fd3:	f3 0f 1e fb          	endbr32 
80105fd7:	55                   	push   %ebp
80105fd8:	89 e5                	mov    %esp,%ebp
80105fda:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105fe0:	83 ec 08             	sub    $0x8,%esp
80105fe3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fe6:	50                   	push   %eax
80105fe7:	6a 00                	push   $0x0
80105fe9:	e8 56 f3 ff ff       	call   80105344 <argstr>
80105fee:	83 c4 10             	add    $0x10,%esp
80105ff1:	85 c0                	test   %eax,%eax
80105ff3:	78 18                	js     8010600d <sys_exec+0x3a>
80105ff5:	83 ec 08             	sub    $0x8,%esp
80105ff8:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105ffe:	50                   	push   %eax
80105fff:	6a 01                	push   $0x1
80106001:	e8 b0 f2 ff ff       	call   801052b6 <argint>
80106006:	83 c4 10             	add    $0x10,%esp
80106009:	85 c0                	test   %eax,%eax
8010600b:	79 0a                	jns    80106017 <sys_exec+0x44>
    return -1;
8010600d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106012:	e9 c6 00 00 00       	jmp    801060dd <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106017:	83 ec 04             	sub    $0x4,%esp
8010601a:	68 80 00 00 00       	push   $0x80
8010601f:	6a 00                	push   $0x0
80106021:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106027:	50                   	push   %eax
80106028:	e8 50 ef ff ff       	call   80104f7d <memset>
8010602d:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106030:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010603a:	83 f8 1f             	cmp    $0x1f,%eax
8010603d:	76 0a                	jbe    80106049 <sys_exec+0x76>
      return -1;
8010603f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106044:	e9 94 00 00 00       	jmp    801060dd <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604c:	c1 e0 02             	shl    $0x2,%eax
8010604f:	89 c2                	mov    %eax,%edx
80106051:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106057:	01 c2                	add    %eax,%edx
80106059:	83 ec 08             	sub    $0x8,%esp
8010605c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106062:	50                   	push   %eax
80106063:	52                   	push   %edx
80106064:	e8 bd f1 ff ff       	call   80105226 <fetchint>
80106069:	83 c4 10             	add    $0x10,%esp
8010606c:	85 c0                	test   %eax,%eax
8010606e:	79 07                	jns    80106077 <sys_exec+0xa4>
      return -1;
80106070:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106075:	eb 66                	jmp    801060dd <sys_exec+0x10a>
    if(uarg == 0){
80106077:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010607d:	85 c0                	test   %eax,%eax
8010607f:	75 27                	jne    801060a8 <sys_exec+0xd5>
      argv[i] = 0;
80106081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106084:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010608b:	00 00 00 00 
      break;
8010608f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106090:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106093:	83 ec 08             	sub    $0x8,%esp
80106096:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010609c:	52                   	push   %edx
8010609d:	50                   	push   %eax
8010609e:	e8 1b ab ff ff       	call   80100bbe <exec>
801060a3:	83 c4 10             	add    $0x10,%esp
801060a6:	eb 35                	jmp    801060dd <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801060a8:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801060ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060b1:	c1 e2 02             	shl    $0x2,%edx
801060b4:	01 c2                	add    %eax,%edx
801060b6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801060bc:	83 ec 08             	sub    $0x8,%esp
801060bf:	52                   	push   %edx
801060c0:	50                   	push   %eax
801060c1:	e8 92 f1 ff ff       	call   80105258 <fetchstr>
801060c6:	83 c4 10             	add    $0x10,%esp
801060c9:	85 c0                	test   %eax,%eax
801060cb:	79 07                	jns    801060d4 <sys_exec+0x101>
      return -1;
801060cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d2:	eb 09                	jmp    801060dd <sys_exec+0x10a>
  for(i=0;; i++){
801060d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801060d8:	e9 5a ff ff ff       	jmp    80106037 <sys_exec+0x64>
}
801060dd:	c9                   	leave  
801060de:	c3                   	ret    

801060df <sys_pipe>:

int
sys_pipe(void)
{
801060df:	f3 0f 1e fb          	endbr32 
801060e3:	55                   	push   %ebp
801060e4:	89 e5                	mov    %esp,%ebp
801060e6:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801060e9:	83 ec 04             	sub    $0x4,%esp
801060ec:	6a 08                	push   $0x8
801060ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060f1:	50                   	push   %eax
801060f2:	6a 00                	push   $0x0
801060f4:	e8 ee f1 ff ff       	call   801052e7 <argptr>
801060f9:	83 c4 10             	add    $0x10,%esp
801060fc:	85 c0                	test   %eax,%eax
801060fe:	79 0a                	jns    8010610a <sys_pipe+0x2b>
    return -1;
80106100:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106105:	e9 ae 00 00 00       	jmp    801061b8 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
8010610a:	83 ec 08             	sub    $0x8,%esp
8010610d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106110:	50                   	push   %eax
80106111:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106114:	50                   	push   %eax
80106115:	e8 a2 d5 ff ff       	call   801036bc <pipealloc>
8010611a:	83 c4 10             	add    $0x10,%esp
8010611d:	85 c0                	test   %eax,%eax
8010611f:	79 0a                	jns    8010612b <sys_pipe+0x4c>
    return -1;
80106121:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106126:	e9 8d 00 00 00       	jmp    801061b8 <sys_pipe+0xd9>
  fd0 = -1;
8010612b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106132:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106135:	83 ec 0c             	sub    $0xc,%esp
80106138:	50                   	push   %eax
80106139:	e8 3b f3 ff ff       	call   80105479 <fdalloc>
8010613e:	83 c4 10             	add    $0x10,%esp
80106141:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106144:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106148:	78 18                	js     80106162 <sys_pipe+0x83>
8010614a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010614d:	83 ec 0c             	sub    $0xc,%esp
80106150:	50                   	push   %eax
80106151:	e8 23 f3 ff ff       	call   80105479 <fdalloc>
80106156:	83 c4 10             	add    $0x10,%esp
80106159:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010615c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106160:	79 3e                	jns    801061a0 <sys_pipe+0xc1>
    if(fd0 >= 0)
80106162:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106166:	78 13                	js     8010617b <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106168:	e8 2e da ff ff       	call   80103b9b <myproc>
8010616d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106170:	83 c2 08             	add    $0x8,%edx
80106173:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010617a:	00 
    fileclose(rf);
8010617b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010617e:	83 ec 0c             	sub    $0xc,%esp
80106181:	50                   	push   %eax
80106182:	e8 54 af ff ff       	call   801010db <fileclose>
80106187:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010618a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010618d:	83 ec 0c             	sub    $0xc,%esp
80106190:	50                   	push   %eax
80106191:	e8 45 af ff ff       	call   801010db <fileclose>
80106196:	83 c4 10             	add    $0x10,%esp
    return -1;
80106199:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010619e:	eb 18                	jmp    801061b8 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801061a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061a6:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801061a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061ab:	8d 50 04             	lea    0x4(%eax),%edx
801061ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061b1:	89 02                	mov    %eax,(%edx)
  return 0;
801061b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061b8:	c9                   	leave  
801061b9:	c3                   	ret    

801061ba <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801061ba:	f3 0f 1e fb          	endbr32 
801061be:	55                   	push   %ebp
801061bf:	89 e5                	mov    %esp,%ebp
801061c1:	83 ec 08             	sub    $0x8,%esp
  return fork();
801061c4:	e8 f5 dc ff ff       	call   80103ebe <fork>
}
801061c9:	c9                   	leave  
801061ca:	c3                   	ret    

801061cb <sys_exit>:

int
sys_exit(void)
{
801061cb:	f3 0f 1e fb          	endbr32 
801061cf:	55                   	push   %ebp
801061d0:	89 e5                	mov    %esp,%ebp
801061d2:	83 ec 08             	sub    $0x8,%esp
  exit();
801061d5:	e8 73 de ff ff       	call   8010404d <exit>
  return 0;  // not reached
801061da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061df:	c9                   	leave  
801061e0:	c3                   	ret    

801061e1 <sys_wait>:

int
sys_wait(void)
{
801061e1:	f3 0f 1e fb          	endbr32 
801061e5:	55                   	push   %ebp
801061e6:	89 e5                	mov    %esp,%ebp
801061e8:	83 ec 08             	sub    $0x8,%esp
  return wait();
801061eb:	e8 c1 e0 ff ff       	call   801042b1 <wait>
}
801061f0:	c9                   	leave  
801061f1:	c3                   	ret    

801061f2 <sys_kill>:

int
sys_kill(void)
{
801061f2:	f3 0f 1e fb          	endbr32 
801061f6:	55                   	push   %ebp
801061f7:	89 e5                	mov    %esp,%ebp
801061f9:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801061fc:	83 ec 08             	sub    $0x8,%esp
801061ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106202:	50                   	push   %eax
80106203:	6a 00                	push   $0x0
80106205:	e8 ac f0 ff ff       	call   801052b6 <argint>
8010620a:	83 c4 10             	add    $0x10,%esp
8010620d:	85 c0                	test   %eax,%eax
8010620f:	79 07                	jns    80106218 <sys_kill+0x26>
    return -1;
80106211:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106216:	eb 0f                	jmp    80106227 <sys_kill+0x35>
  return kill(pid);
80106218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621b:	83 ec 0c             	sub    $0xc,%esp
8010621e:	50                   	push   %eax
8010621f:	e8 4d e6 ff ff       	call   80104871 <kill>
80106224:	83 c4 10             	add    $0x10,%esp
}
80106227:	c9                   	leave  
80106228:	c3                   	ret    

80106229 <sys_getpid>:

int
sys_getpid(void)
{
80106229:	f3 0f 1e fb          	endbr32 
8010622d:	55                   	push   %ebp
8010622e:	89 e5                	mov    %esp,%ebp
80106230:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106233:	e8 63 d9 ff ff       	call   80103b9b <myproc>
80106238:	8b 40 10             	mov    0x10(%eax),%eax
}
8010623b:	c9                   	leave  
8010623c:	c3                   	ret    

8010623d <sys_sbrk>:

int
sys_sbrk(void)
{
8010623d:	f3 0f 1e fb          	endbr32 
80106241:	55                   	push   %ebp
80106242:	89 e5                	mov    %esp,%ebp
80106244:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106247:	83 ec 08             	sub    $0x8,%esp
8010624a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010624d:	50                   	push   %eax
8010624e:	6a 00                	push   $0x0
80106250:	e8 61 f0 ff ff       	call   801052b6 <argint>
80106255:	83 c4 10             	add    $0x10,%esp
80106258:	85 c0                	test   %eax,%eax
8010625a:	79 07                	jns    80106263 <sys_sbrk+0x26>
    return -1;
8010625c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106261:	eb 27                	jmp    8010628a <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106263:	e8 33 d9 ff ff       	call   80103b9b <myproc>
80106268:	8b 00                	mov    (%eax),%eax
8010626a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010626d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106270:	83 ec 0c             	sub    $0xc,%esp
80106273:	50                   	push   %eax
80106274:	e8 a6 db ff ff       	call   80103e1f <growproc>
80106279:	83 c4 10             	add    $0x10,%esp
8010627c:	85 c0                	test   %eax,%eax
8010627e:	79 07                	jns    80106287 <sys_sbrk+0x4a>
    return -1;
80106280:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106285:	eb 03                	jmp    8010628a <sys_sbrk+0x4d>
  return addr;
80106287:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010628a:	c9                   	leave  
8010628b:	c3                   	ret    

8010628c <sys_sleep>:

int
sys_sleep(void)
{
8010628c:	f3 0f 1e fb          	endbr32 
80106290:	55                   	push   %ebp
80106291:	89 e5                	mov    %esp,%ebp
80106293:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106296:	83 ec 08             	sub    $0x8,%esp
80106299:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010629c:	50                   	push   %eax
8010629d:	6a 00                	push   $0x0
8010629f:	e8 12 f0 ff ff       	call   801052b6 <argint>
801062a4:	83 c4 10             	add    $0x10,%esp
801062a7:	85 c0                	test   %eax,%eax
801062a9:	79 07                	jns    801062b2 <sys_sleep+0x26>
    return -1;
801062ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b0:	eb 76                	jmp    80106328 <sys_sleep+0x9c>
  acquire(&tickslock);
801062b2:	83 ec 0c             	sub    $0xc,%esp
801062b5:	68 40 79 19 80       	push   $0x80197940
801062ba:	e8 2f ea ff ff       	call   80104cee <acquire>
801062bf:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801062c2:	a1 80 81 19 80       	mov    0x80198180,%eax
801062c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801062ca:	eb 38                	jmp    80106304 <sys_sleep+0x78>
    if(myproc()->killed){
801062cc:	e8 ca d8 ff ff       	call   80103b9b <myproc>
801062d1:	8b 40 24             	mov    0x24(%eax),%eax
801062d4:	85 c0                	test   %eax,%eax
801062d6:	74 17                	je     801062ef <sys_sleep+0x63>
      release(&tickslock);
801062d8:	83 ec 0c             	sub    $0xc,%esp
801062db:	68 40 79 19 80       	push   $0x80197940
801062e0:	e8 7b ea ff ff       	call   80104d60 <release>
801062e5:	83 c4 10             	add    $0x10,%esp
      return -1;
801062e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ed:	eb 39                	jmp    80106328 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801062ef:	83 ec 08             	sub    $0x8,%esp
801062f2:	68 40 79 19 80       	push   $0x80197940
801062f7:	68 80 81 19 80       	push   $0x80198180
801062fc:	e8 43 e4 ff ff       	call   80104744 <sleep>
80106301:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106304:	a1 80 81 19 80       	mov    0x80198180,%eax
80106309:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010630c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010630f:	39 d0                	cmp    %edx,%eax
80106311:	72 b9                	jb     801062cc <sys_sleep+0x40>
  }
  release(&tickslock);
80106313:	83 ec 0c             	sub    $0xc,%esp
80106316:	68 40 79 19 80       	push   $0x80197940
8010631b:	e8 40 ea ff ff       	call   80104d60 <release>
80106320:	83 c4 10             	add    $0x10,%esp
  return 0;
80106323:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106328:	c9                   	leave  
80106329:	c3                   	ret    

8010632a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010632a:	f3 0f 1e fb          	endbr32 
8010632e:	55                   	push   %ebp
8010632f:	89 e5                	mov    %esp,%ebp
80106331:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106334:	83 ec 0c             	sub    $0xc,%esp
80106337:	68 40 79 19 80       	push   $0x80197940
8010633c:	e8 ad e9 ff ff       	call   80104cee <acquire>
80106341:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106344:	a1 80 81 19 80       	mov    0x80198180,%eax
80106349:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010634c:	83 ec 0c             	sub    $0xc,%esp
8010634f:	68 40 79 19 80       	push   $0x80197940
80106354:	e8 07 ea ff ff       	call   80104d60 <release>
80106359:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010635c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010635f:	c9                   	leave  
80106360:	c3                   	ret    

80106361 <sys_exit2>:

int
sys_exit2(void)
{
80106361:	f3 0f 1e fb          	endbr32 
80106365:	55                   	push   %ebp
80106366:	89 e5                	mov    %esp,%ebp
80106368:	83 ec 18             	sub    $0x18,%esp
  int status;
  if(argint(0, &status) < 0)
8010636b:	83 ec 08             	sub    $0x8,%esp
8010636e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106371:	50                   	push   %eax
80106372:	6a 00                	push   $0x0
80106374:	e8 3d ef ff ff       	call   801052b6 <argint>
80106379:	83 c4 10             	add    $0x10,%esp
8010637c:	85 c0                	test   %eax,%eax
8010637e:	79 07                	jns    80106387 <sys_exit2+0x26>
    return -1; 
80106380:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106385:	eb 15                	jmp    8010639c <sys_exit2+0x3b>

  myproc()->xstate = status;
80106387:	e8 0f d8 ff ff       	call   80103b9b <myproc>
8010638c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010638f:	89 50 7c             	mov    %edx,0x7c(%eax)
  exit();
80106392:	e8 b6 dc ff ff       	call   8010404d <exit>
  return 0;
80106397:	b8 00 00 00 00       	mov    $0x0,%eax
}	
8010639c:	c9                   	leave  
8010639d:	c3                   	ret    

8010639e <sys_wait2>:

extern int wait2(int *status);

int sys_wait2(void) 
{
8010639e:	f3 0f 1e fb          	endbr32 
801063a2:	55                   	push   %ebp
801063a3:	89 e5                	mov    %esp,%ebp
801063a5:	83 ec 18             	sub    $0x18,%esp
  int *status;
  if(argptr(0, (void *)&status, sizeof(*status)) < 0)
801063a8:	83 ec 04             	sub    $0x4,%esp
801063ab:	6a 04                	push   $0x4
801063ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801063b0:	50                   	push   %eax
801063b1:	6a 00                	push   $0x0
801063b3:	e8 2f ef ff ff       	call   801052e7 <argptr>
801063b8:	83 c4 10             	add    $0x10,%esp
801063bb:	85 c0                	test   %eax,%eax
801063bd:	79 07                	jns    801063c6 <sys_wait2+0x28>
    return -1;
801063bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c4:	eb 0f                	jmp    801063d5 <sys_wait2+0x37>
  return wait2(status);
801063c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c9:	83 ec 0c             	sub    $0xc,%esp
801063cc:	50                   	push   %eax
801063cd:	e8 06 e0 ff ff       	call   801043d8 <wait2>
801063d2:	83 c4 10             	add    $0x10,%esp
}
801063d5:	c9                   	leave  
801063d6:	c3                   	ret    

801063d7 <sys_uthread_init>:

int
sys_uthread_init(void)
{
801063d7:	f3 0f 1e fb          	endbr32 
801063db:	55                   	push   %ebp
801063dc:	89 e5                	mov    %esp,%ebp
801063de:	83 ec 18             	sub    $0x18,%esp
    struct proc* p;
    int func;

    if (argint(0, &func) < 0)
801063e1:	83 ec 08             	sub    $0x8,%esp
801063e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063e7:	50                   	push   %eax
801063e8:	6a 00                	push   $0x0
801063ea:	e8 c7 ee ff ff       	call   801052b6 <argint>
801063ef:	83 c4 10             	add    $0x10,%esp
801063f2:	85 c0                	test   %eax,%eax
801063f4:	79 07                	jns    801063fd <sys_uthread_init+0x26>
        return -1;
801063f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063fb:	eb 1b                	jmp    80106418 <sys_uthread_init+0x41>

    p = myproc();
801063fd:	e8 99 d7 ff ff       	call   80103b9b <myproc>
80106402:	89 45 f4             	mov    %eax,-0xc(%ebp)

    p->scheduler = (uint)func;
80106405:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106408:	89 c2                	mov    %eax,%edx
8010640a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640d:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

    return 0;
80106413:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106418:	c9                   	leave  
80106419:	c3                   	ret    

8010641a <sys_printpt>:

int sys_printpt(void) {
8010641a:	f3 0f 1e fb          	endbr32 
8010641e:	55                   	push   %ebp
8010641f:	89 e5                	mov    %esp,%ebp
80106421:	83 ec 18             	sub    $0x18,%esp
    int pid;
    if(argint(0, &pid) < 0)
80106424:	83 ec 08             	sub    $0x8,%esp
80106427:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010642a:	50                   	push   %eax
8010642b:	6a 00                	push   $0x0
8010642d:	e8 84 ee ff ff       	call   801052b6 <argint>
80106432:	83 c4 10             	add    $0x10,%esp
80106435:	85 c0                	test   %eax,%eax
80106437:	79 07                	jns    80106440 <sys_printpt+0x26>
        return -1;
80106439:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643e:	eb 0f                	jmp    8010644f <sys_printpt+0x35>
    return printpt(pid);
80106440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106443:	83 ec 0c             	sub    $0xc,%esp
80106446:	50                   	push   %eax
80106447:	e8 b1 e5 ff ff       	call   801049fd <printpt>
8010644c:	83 c4 10             	add    $0x10,%esp
}
8010644f:	c9                   	leave  
80106450:	c3                   	ret    

80106451 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106451:	1e                   	push   %ds
  pushl %es
80106452:	06                   	push   %es
  pushl %fs
80106453:	0f a0                	push   %fs
  pushl %gs
80106455:	0f a8                	push   %gs
  pushal
80106457:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106458:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010645c:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010645e:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106460:	54                   	push   %esp
  call trap
80106461:	e8 df 01 00 00       	call   80106645 <trap>
  addl $4, %esp
80106466:	83 c4 04             	add    $0x4,%esp

80106469 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106469:	61                   	popa   
  popl %gs
8010646a:	0f a9                	pop    %gs
  popl %fs
8010646c:	0f a1                	pop    %fs
  popl %es
8010646e:	07                   	pop    %es
  popl %ds
8010646f:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106470:	83 c4 08             	add    $0x8,%esp
  iret
80106473:	cf                   	iret   

80106474 <lidt>:
{
80106474:	55                   	push   %ebp
80106475:	89 e5                	mov    %esp,%ebp
80106477:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010647a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010647d:	83 e8 01             	sub    $0x1,%eax
80106480:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106484:	8b 45 08             	mov    0x8(%ebp),%eax
80106487:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010648b:	8b 45 08             	mov    0x8(%ebp),%eax
8010648e:	c1 e8 10             	shr    $0x10,%eax
80106491:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106495:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106498:	0f 01 18             	lidtl  (%eax)
}
8010649b:	90                   	nop
8010649c:	c9                   	leave  
8010649d:	c3                   	ret    

8010649e <rcr2>:

static inline uint
rcr2(void)
{
8010649e:	55                   	push   %ebp
8010649f:	89 e5                	mov    %esp,%ebp
801064a1:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801064a4:	0f 20 d0             	mov    %cr2,%eax
801064a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801064aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801064ad:	c9                   	leave  
801064ae:	c3                   	ret    

801064af <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801064af:	f3 0f 1e fb          	endbr32 
801064b3:	55                   	push   %ebp
801064b4:	89 e5                	mov    %esp,%ebp
801064b6:	83 ec 18             	sub    $0x18,%esp
    int i;

    for (i = 0; i < 256; i++)
801064b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801064c0:	e9 c3 00 00 00       	jmp    80106588 <tvinit+0xd9>
        SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
801064c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c8:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
801064cf:	89 c2                	mov    %eax,%edx
801064d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d4:	66 89 14 c5 80 79 19 	mov    %dx,-0x7fe68680(,%eax,8)
801064db:	80 
801064dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064df:	66 c7 04 c5 82 79 19 	movw   $0x8,-0x7fe6867e(,%eax,8)
801064e6:	80 08 00 
801064e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ec:	0f b6 14 c5 84 79 19 	movzbl -0x7fe6867c(,%eax,8),%edx
801064f3:	80 
801064f4:	83 e2 e0             	and    $0xffffffe0,%edx
801064f7:	88 14 c5 84 79 19 80 	mov    %dl,-0x7fe6867c(,%eax,8)
801064fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106501:	0f b6 14 c5 84 79 19 	movzbl -0x7fe6867c(,%eax,8),%edx
80106508:	80 
80106509:	83 e2 1f             	and    $0x1f,%edx
8010650c:	88 14 c5 84 79 19 80 	mov    %dl,-0x7fe6867c(,%eax,8)
80106513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106516:	0f b6 14 c5 85 79 19 	movzbl -0x7fe6867b(,%eax,8),%edx
8010651d:	80 
8010651e:	83 e2 f0             	and    $0xfffffff0,%edx
80106521:	83 ca 0e             	or     $0xe,%edx
80106524:	88 14 c5 85 79 19 80 	mov    %dl,-0x7fe6867b(,%eax,8)
8010652b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652e:	0f b6 14 c5 85 79 19 	movzbl -0x7fe6867b(,%eax,8),%edx
80106535:	80 
80106536:	83 e2 ef             	and    $0xffffffef,%edx
80106539:	88 14 c5 85 79 19 80 	mov    %dl,-0x7fe6867b(,%eax,8)
80106540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106543:	0f b6 14 c5 85 79 19 	movzbl -0x7fe6867b(,%eax,8),%edx
8010654a:	80 
8010654b:	83 e2 9f             	and    $0xffffff9f,%edx
8010654e:	88 14 c5 85 79 19 80 	mov    %dl,-0x7fe6867b(,%eax,8)
80106555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106558:	0f b6 14 c5 85 79 19 	movzbl -0x7fe6867b(,%eax,8),%edx
8010655f:	80 
80106560:	83 ca 80             	or     $0xffffff80,%edx
80106563:	88 14 c5 85 79 19 80 	mov    %dl,-0x7fe6867b(,%eax,8)
8010656a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010656d:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106574:	c1 e8 10             	shr    $0x10,%eax
80106577:	89 c2                	mov    %eax,%edx
80106579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657c:	66 89 14 c5 86 79 19 	mov    %dx,-0x7fe6867a(,%eax,8)
80106583:	80 
    for (i = 0; i < 256; i++)
80106584:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106588:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010658f:	0f 8e 30 ff ff ff    	jle    801064c5 <tvinit+0x16>
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
80106595:	a1 88 f1 10 80       	mov    0x8010f188,%eax
8010659a:	66 a3 80 7b 19 80    	mov    %ax,0x80197b80
801065a0:	66 c7 05 82 7b 19 80 	movw   $0x8,0x80197b82
801065a7:	08 00 
801065a9:	0f b6 05 84 7b 19 80 	movzbl 0x80197b84,%eax
801065b0:	83 e0 e0             	and    $0xffffffe0,%eax
801065b3:	a2 84 7b 19 80       	mov    %al,0x80197b84
801065b8:	0f b6 05 84 7b 19 80 	movzbl 0x80197b84,%eax
801065bf:	83 e0 1f             	and    $0x1f,%eax
801065c2:	a2 84 7b 19 80       	mov    %al,0x80197b84
801065c7:	0f b6 05 85 7b 19 80 	movzbl 0x80197b85,%eax
801065ce:	83 c8 0f             	or     $0xf,%eax
801065d1:	a2 85 7b 19 80       	mov    %al,0x80197b85
801065d6:	0f b6 05 85 7b 19 80 	movzbl 0x80197b85,%eax
801065dd:	83 e0 ef             	and    $0xffffffef,%eax
801065e0:	a2 85 7b 19 80       	mov    %al,0x80197b85
801065e5:	0f b6 05 85 7b 19 80 	movzbl 0x80197b85,%eax
801065ec:	83 c8 60             	or     $0x60,%eax
801065ef:	a2 85 7b 19 80       	mov    %al,0x80197b85
801065f4:	0f b6 05 85 7b 19 80 	movzbl 0x80197b85,%eax
801065fb:	83 c8 80             	or     $0xffffff80,%eax
801065fe:	a2 85 7b 19 80       	mov    %al,0x80197b85
80106603:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106608:	c1 e8 10             	shr    $0x10,%eax
8010660b:	66 a3 86 7b 19 80    	mov    %ax,0x80197b86

    initlock(&tickslock, "time");
80106611:	83 ec 08             	sub    $0x8,%esp
80106614:	68 40 ae 10 80       	push   $0x8010ae40
80106619:	68 40 79 19 80       	push   $0x80197940
8010661e:	e8 a5 e6 ff ff       	call   80104cc8 <initlock>
80106623:	83 c4 10             	add    $0x10,%esp
}
80106626:	90                   	nop
80106627:	c9                   	leave  
80106628:	c3                   	ret    

80106629 <idtinit>:

void
idtinit(void)
{
80106629:	f3 0f 1e fb          	endbr32 
8010662d:	55                   	push   %ebp
8010662e:	89 e5                	mov    %esp,%ebp
    lidt(idt, sizeof(idt));
80106630:	68 00 08 00 00       	push   $0x800
80106635:	68 80 79 19 80       	push   $0x80197980
8010663a:	e8 35 fe ff ff       	call   80106474 <lidt>
8010663f:	83 c4 08             	add    $0x8,%esp
}
80106642:	90                   	nop
80106643:	c9                   	leave  
80106644:	c3                   	ret    

80106645 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe* tf)
{
80106645:	f3 0f 1e fb          	endbr32 
80106649:	55                   	push   %ebp
8010664a:	89 e5                	mov    %esp,%ebp
8010664c:	57                   	push   %edi
8010664d:	56                   	push   %esi
8010664e:	53                   	push   %ebx
8010664f:	83 ec 2c             	sub    $0x2c,%esp
    if (tf->trapno == T_SYSCALL) {
80106652:	8b 45 08             	mov    0x8(%ebp),%eax
80106655:	8b 40 30             	mov    0x30(%eax),%eax
80106658:	83 f8 40             	cmp    $0x40,%eax
8010665b:	75 3b                	jne    80106698 <trap+0x53>
        if (myproc()->killed)
8010665d:	e8 39 d5 ff ff       	call   80103b9b <myproc>
80106662:	8b 40 24             	mov    0x24(%eax),%eax
80106665:	85 c0                	test   %eax,%eax
80106667:	74 05                	je     8010666e <trap+0x29>
            exit();
80106669:	e8 df d9 ff ff       	call   8010404d <exit>
        myproc()->tf = tf;
8010666e:	e8 28 d5 ff ff       	call   80103b9b <myproc>
80106673:	8b 55 08             	mov    0x8(%ebp),%edx
80106676:	89 50 18             	mov    %edx,0x18(%eax)
        syscall();
80106679:	e8 01 ed ff ff       	call   8010537f <syscall>
        if (myproc()->killed)
8010667e:	e8 18 d5 ff ff       	call   80103b9b <myproc>
80106683:	8b 40 24             	mov    0x24(%eax),%eax
80106686:	85 c0                	test   %eax,%eax
80106688:	0f 84 74 02 00 00    	je     80106902 <trap+0x2bd>
            exit();
8010668e:	e8 ba d9 ff ff       	call   8010404d <exit>
        return;
80106693:	e9 6a 02 00 00       	jmp    80106902 <trap+0x2bd>
    }

    switch (tf->trapno) {
80106698:	8b 45 08             	mov    0x8(%ebp),%eax
8010669b:	8b 40 30             	mov    0x30(%eax),%eax
8010669e:	83 e8 0e             	sub    $0xe,%eax
801066a1:	83 f8 31             	cmp    $0x31,%eax
801066a4:	0f 87 23 01 00 00    	ja     801067cd <trap+0x188>
801066aa:	8b 04 85 e8 ae 10 80 	mov    -0x7fef5118(,%eax,4),%eax
801066b1:	3e ff e0             	notrack jmp *%eax
    case T_IRQ0 + IRQ_TIMER:
        if (cpuid() == 0) {
801066b4:	e8 47 d4 ff ff       	call   80103b00 <cpuid>
801066b9:	85 c0                	test   %eax,%eax
801066bb:	75 3d                	jne    801066fa <trap+0xb5>
            acquire(&tickslock);
801066bd:	83 ec 0c             	sub    $0xc,%esp
801066c0:	68 40 79 19 80       	push   $0x80197940
801066c5:	e8 24 e6 ff ff       	call   80104cee <acquire>
801066ca:	83 c4 10             	add    $0x10,%esp
            ticks++;
801066cd:	a1 80 81 19 80       	mov    0x80198180,%eax
801066d2:	83 c0 01             	add    $0x1,%eax
801066d5:	a3 80 81 19 80       	mov    %eax,0x80198180
            wakeup(&ticks);
801066da:	83 ec 0c             	sub    $0xc,%esp
801066dd:	68 80 81 19 80       	push   $0x80198180
801066e2:	e8 4f e1 ff ff       	call   80104836 <wakeup>
801066e7:	83 c4 10             	add    $0x10,%esp
            release(&tickslock);
801066ea:	83 ec 0c             	sub    $0xc,%esp
801066ed:	68 40 79 19 80       	push   $0x80197940
801066f2:	e8 69 e6 ff ff       	call   80104d60 <release>
801066f7:	83 c4 10             	add    $0x10,%esp
        }
        lapiceoi();
801066fa:	e8 18 c5 ff ff       	call   80102c17 <lapiceoi>
        break;
801066ff:	e9 7e 01 00 00       	jmp    80106882 <trap+0x23d>
    case T_IRQ0 + IRQ_IDE:
        ideintr();
80106704:	e8 75 41 00 00       	call   8010a87e <ideintr>
        lapiceoi();
80106709:	e8 09 c5 ff ff       	call   80102c17 <lapiceoi>
        break;
8010670e:	e9 6f 01 00 00       	jmp    80106882 <trap+0x23d>
    case T_IRQ0 + IRQ_IDE + 1:
        // Bochs generates spurious IDE1 interrupts.
        break;
    case T_IRQ0 + IRQ_KBD:
        kbdintr();
80106713:	e8 35 c3 ff ff       	call   80102a4d <kbdintr>
        lapiceoi();
80106718:	e8 fa c4 ff ff       	call   80102c17 <lapiceoi>
        break;
8010671d:	e9 60 01 00 00       	jmp    80106882 <trap+0x23d>
    case T_IRQ0 + IRQ_COM1:
        uartintr();
80106722:	e8 bd 03 00 00       	call   80106ae4 <uartintr>
        lapiceoi();
80106727:	e8 eb c4 ff ff       	call   80102c17 <lapiceoi>
        break;
8010672c:	e9 51 01 00 00       	jmp    80106882 <trap+0x23d>
    case T_IRQ0 + 0xB:
        i8254_intr();
80106731:	e8 87 2d 00 00       	call   801094bd <i8254_intr>
        lapiceoi();
80106736:	e8 dc c4 ff ff       	call   80102c17 <lapiceoi>
        break;
8010673b:	e9 42 01 00 00       	jmp    80106882 <trap+0x23d>
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106740:	8b 45 08             	mov    0x8(%ebp),%eax
80106743:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106746:	8b 45 08             	mov    0x8(%ebp),%eax
80106749:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010674d:	0f b7 d8             	movzwl %ax,%ebx
80106750:	e8 ab d3 ff ff       	call   80103b00 <cpuid>
80106755:	56                   	push   %esi
80106756:	53                   	push   %ebx
80106757:	50                   	push   %eax
80106758:	68 48 ae 10 80       	push   $0x8010ae48
8010675d:	e8 aa 9c ff ff       	call   8010040c <cprintf>
80106762:	83 c4 10             	add    $0x10,%esp
        lapiceoi();
80106765:	e8 ad c4 ff ff       	call   80102c17 <lapiceoi>
        break;
8010676a:	e9 13 01 00 00       	jmp    80106882 <trap+0x23d>
        
    case T_PGFLT: {
        uint d = rcr2();
8010676f:	e8 2a fd ff ff       	call   8010649e <rcr2>
80106774:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (d > TOP) {
80106777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010677a:	85 c0                	test   %eax,%eax
8010677c:	79 05                	jns    80106783 <trap+0x13e>
            exit();
8010677e:	e8 ca d8 ff ff       	call   8010404d <exit>
        }
        d = PGROUNDDOWN(d);
80106783:	81 65 e4 00 f0 ff ff 	andl   $0xfffff000,-0x1c(%ebp)
        if (allocuvm(myproc()->pgdir, d, d + PGSIZE) == 0) {
8010678a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010678d:	8d 98 00 10 00 00    	lea    0x1000(%eax),%ebx
80106793:	e8 03 d4 ff ff       	call   80103b9b <myproc>
80106798:	8b 40 04             	mov    0x4(%eax),%eax
8010679b:	83 ec 04             	sub    $0x4,%esp
8010679e:	53                   	push   %ebx
8010679f:	ff 75 e4             	pushl  -0x1c(%ebp)
801067a2:	50                   	push   %eax
801067a3:	e8 b2 16 00 00       	call   80107e5a <allocuvm>
801067a8:	83 c4 10             	add    $0x10,%esp
801067ab:	85 c0                	test   %eax,%eax
801067ad:	75 05                	jne    801067b4 <trap+0x16f>
            exit();
801067af:	e8 99 d8 ff ff       	call   8010404d <exit>
        }
        myproc()->stack_alloc++;
801067b4:	e8 e2 d3 ff ff       	call   80103b9b <myproc>
801067b9:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801067bf:	83 c2 01             	add    $0x1,%edx
801067c2:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
        break;
801067c8:	e9 b5 00 00 00       	jmp    80106882 <trap+0x23d>
    }


        //PAGEBREAK: 13
    default:
        if (myproc() == 0 || (tf->cs & 3) == 0) {
801067cd:	e8 c9 d3 ff ff       	call   80103b9b <myproc>
801067d2:	85 c0                	test   %eax,%eax
801067d4:	74 11                	je     801067e7 <trap+0x1a2>
801067d6:	8b 45 08             	mov    0x8(%ebp),%eax
801067d9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801067dd:	0f b7 c0             	movzwl %ax,%eax
801067e0:	83 e0 03             	and    $0x3,%eax
801067e3:	85 c0                	test   %eax,%eax
801067e5:	75 39                	jne    80106820 <trap+0x1db>
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801067e7:	e8 b2 fc ff ff       	call   8010649e <rcr2>
801067ec:	89 c3                	mov    %eax,%ebx
801067ee:	8b 45 08             	mov    0x8(%ebp),%eax
801067f1:	8b 70 38             	mov    0x38(%eax),%esi
801067f4:	e8 07 d3 ff ff       	call   80103b00 <cpuid>
801067f9:	8b 55 08             	mov    0x8(%ebp),%edx
801067fc:	8b 52 30             	mov    0x30(%edx),%edx
801067ff:	83 ec 0c             	sub    $0xc,%esp
80106802:	53                   	push   %ebx
80106803:	56                   	push   %esi
80106804:	50                   	push   %eax
80106805:	52                   	push   %edx
80106806:	68 6c ae 10 80       	push   $0x8010ae6c
8010680b:	e8 fc 9b ff ff       	call   8010040c <cprintf>
80106810:	83 c4 20             	add    $0x20,%esp
                tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
80106813:	83 ec 0c             	sub    $0xc,%esp
80106816:	68 9e ae 10 80       	push   $0x8010ae9e
8010681b:	e8 a5 9d ff ff       	call   801005c5 <panic>
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106820:	e8 79 fc ff ff       	call   8010649e <rcr2>
80106825:	89 c6                	mov    %eax,%esi
80106827:	8b 45 08             	mov    0x8(%ebp),%eax
8010682a:	8b 40 38             	mov    0x38(%eax),%eax
8010682d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106830:	e8 cb d2 ff ff       	call   80103b00 <cpuid>
80106835:	89 c3                	mov    %eax,%ebx
80106837:	8b 45 08             	mov    0x8(%ebp),%eax
8010683a:	8b 48 34             	mov    0x34(%eax),%ecx
8010683d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106840:	8b 45 08             	mov    0x8(%ebp),%eax
80106843:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106846:	e8 50 d3 ff ff       	call   80103b9b <myproc>
8010684b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010684e:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106851:	e8 45 d3 ff ff       	call   80103b9b <myproc>
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106856:	8b 40 10             	mov    0x10(%eax),%eax
80106859:	56                   	push   %esi
8010685a:	ff 75 d4             	pushl  -0x2c(%ebp)
8010685d:	53                   	push   %ebx
8010685e:	ff 75 d0             	pushl  -0x30(%ebp)
80106861:	57                   	push   %edi
80106862:	ff 75 cc             	pushl  -0x34(%ebp)
80106865:	50                   	push   %eax
80106866:	68 a4 ae 10 80       	push   $0x8010aea4
8010686b:	e8 9c 9b ff ff       	call   8010040c <cprintf>
80106870:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
80106873:	e8 23 d3 ff ff       	call   80103b9b <myproc>
80106878:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010687f:	eb 01                	jmp    80106882 <trap+0x23d>
        break;
80106881:	90                   	nop
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106882:	e8 14 d3 ff ff       	call   80103b9b <myproc>
80106887:	85 c0                	test   %eax,%eax
80106889:	74 23                	je     801068ae <trap+0x269>
8010688b:	e8 0b d3 ff ff       	call   80103b9b <myproc>
80106890:	8b 40 24             	mov    0x24(%eax),%eax
80106893:	85 c0                	test   %eax,%eax
80106895:	74 17                	je     801068ae <trap+0x269>
80106897:	8b 45 08             	mov    0x8(%ebp),%eax
8010689a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010689e:	0f b7 c0             	movzwl %ax,%eax
801068a1:	83 e0 03             	and    $0x3,%eax
801068a4:	83 f8 03             	cmp    $0x3,%eax
801068a7:	75 05                	jne    801068ae <trap+0x269>
        exit();
801068a9:	e8 9f d7 ff ff       	call   8010404d <exit>

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
801068ae:	e8 e8 d2 ff ff       	call   80103b9b <myproc>
801068b3:	85 c0                	test   %eax,%eax
801068b5:	74 1d                	je     801068d4 <trap+0x28f>
801068b7:	e8 df d2 ff ff       	call   80103b9b <myproc>
801068bc:	8b 40 0c             	mov    0xc(%eax),%eax
801068bf:	83 f8 04             	cmp    $0x4,%eax
801068c2:	75 10                	jne    801068d4 <trap+0x28f>
        tf->trapno == T_IRQ0 + IRQ_TIMER)
801068c4:	8b 45 08             	mov    0x8(%ebp),%eax
801068c7:	8b 40 30             	mov    0x30(%eax),%eax
    if (myproc() && myproc()->state == RUNNING &&
801068ca:	83 f8 20             	cmp    $0x20,%eax
801068cd:	75 05                	jne    801068d4 <trap+0x28f>
        yield();
801068cf:	e8 e8 dd ff ff       	call   801046bc <yield>

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
801068d4:	e8 c2 d2 ff ff       	call   80103b9b <myproc>
801068d9:	85 c0                	test   %eax,%eax
801068db:	74 26                	je     80106903 <trap+0x2be>
801068dd:	e8 b9 d2 ff ff       	call   80103b9b <myproc>
801068e2:	8b 40 24             	mov    0x24(%eax),%eax
801068e5:	85 c0                	test   %eax,%eax
801068e7:	74 1a                	je     80106903 <trap+0x2be>
801068e9:	8b 45 08             	mov    0x8(%ebp),%eax
801068ec:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801068f0:	0f b7 c0             	movzwl %ax,%eax
801068f3:	83 e0 03             	and    $0x3,%eax
801068f6:	83 f8 03             	cmp    $0x3,%eax
801068f9:	75 08                	jne    80106903 <trap+0x2be>
        exit();
801068fb:	e8 4d d7 ff ff       	call   8010404d <exit>
80106900:	eb 01                	jmp    80106903 <trap+0x2be>
        return;
80106902:	90                   	nop
80106903:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106906:	5b                   	pop    %ebx
80106907:	5e                   	pop    %esi
80106908:	5f                   	pop    %edi
80106909:	5d                   	pop    %ebp
8010690a:	c3                   	ret    

8010690b <inb>:
{
8010690b:	55                   	push   %ebp
8010690c:	89 e5                	mov    %esp,%ebp
8010690e:	83 ec 14             	sub    $0x14,%esp
80106911:	8b 45 08             	mov    0x8(%ebp),%eax
80106914:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106918:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010691c:	89 c2                	mov    %eax,%edx
8010691e:	ec                   	in     (%dx),%al
8010691f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106922:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106926:	c9                   	leave  
80106927:	c3                   	ret    

80106928 <outb>:
{
80106928:	55                   	push   %ebp
80106929:	89 e5                	mov    %esp,%ebp
8010692b:	83 ec 08             	sub    $0x8,%esp
8010692e:	8b 45 08             	mov    0x8(%ebp),%eax
80106931:	8b 55 0c             	mov    0xc(%ebp),%edx
80106934:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106938:	89 d0                	mov    %edx,%eax
8010693a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010693d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106941:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106945:	ee                   	out    %al,(%dx)
}
80106946:	90                   	nop
80106947:	c9                   	leave  
80106948:	c3                   	ret    

80106949 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106949:	f3 0f 1e fb          	endbr32 
8010694d:	55                   	push   %ebp
8010694e:	89 e5                	mov    %esp,%ebp
80106950:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106953:	6a 00                	push   $0x0
80106955:	68 fa 03 00 00       	push   $0x3fa
8010695a:	e8 c9 ff ff ff       	call   80106928 <outb>
8010695f:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106962:	68 80 00 00 00       	push   $0x80
80106967:	68 fb 03 00 00       	push   $0x3fb
8010696c:	e8 b7 ff ff ff       	call   80106928 <outb>
80106971:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106974:	6a 0c                	push   $0xc
80106976:	68 f8 03 00 00       	push   $0x3f8
8010697b:	e8 a8 ff ff ff       	call   80106928 <outb>
80106980:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106983:	6a 00                	push   $0x0
80106985:	68 f9 03 00 00       	push   $0x3f9
8010698a:	e8 99 ff ff ff       	call   80106928 <outb>
8010698f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106992:	6a 03                	push   $0x3
80106994:	68 fb 03 00 00       	push   $0x3fb
80106999:	e8 8a ff ff ff       	call   80106928 <outb>
8010699e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801069a1:	6a 00                	push   $0x0
801069a3:	68 fc 03 00 00       	push   $0x3fc
801069a8:	e8 7b ff ff ff       	call   80106928 <outb>
801069ad:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801069b0:	6a 01                	push   $0x1
801069b2:	68 f9 03 00 00       	push   $0x3f9
801069b7:	e8 6c ff ff ff       	call   80106928 <outb>
801069bc:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801069bf:	68 fd 03 00 00       	push   $0x3fd
801069c4:	e8 42 ff ff ff       	call   8010690b <inb>
801069c9:	83 c4 04             	add    $0x4,%esp
801069cc:	3c ff                	cmp    $0xff,%al
801069ce:	74 61                	je     80106a31 <uartinit+0xe8>
    return;
  uart = 1;
801069d0:	c7 05 60 d0 18 80 01 	movl   $0x1,0x8018d060
801069d7:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801069da:	68 fa 03 00 00       	push   $0x3fa
801069df:	e8 27 ff ff ff       	call   8010690b <inb>
801069e4:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801069e7:	68 f8 03 00 00       	push   $0x3f8
801069ec:	e8 1a ff ff ff       	call   8010690b <inb>
801069f1:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801069f4:	83 ec 08             	sub    $0x8,%esp
801069f7:	6a 00                	push   $0x0
801069f9:	6a 04                	push   $0x4
801069fb:	e8 fe bc ff ff       	call   801026fe <ioapicenable>
80106a00:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106a03:	c7 45 f4 b0 af 10 80 	movl   $0x8010afb0,-0xc(%ebp)
80106a0a:	eb 19                	jmp    80106a25 <uartinit+0xdc>
    uartputc(*p);
80106a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0f:	0f b6 00             	movzbl (%eax),%eax
80106a12:	0f be c0             	movsbl %al,%eax
80106a15:	83 ec 0c             	sub    $0xc,%esp
80106a18:	50                   	push   %eax
80106a19:	e8 16 00 00 00       	call   80106a34 <uartputc>
80106a1e:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106a21:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a28:	0f b6 00             	movzbl (%eax),%eax
80106a2b:	84 c0                	test   %al,%al
80106a2d:	75 dd                	jne    80106a0c <uartinit+0xc3>
80106a2f:	eb 01                	jmp    80106a32 <uartinit+0xe9>
    return;
80106a31:	90                   	nop
}
80106a32:	c9                   	leave  
80106a33:	c3                   	ret    

80106a34 <uartputc>:

void
uartputc(int c)
{
80106a34:	f3 0f 1e fb          	endbr32 
80106a38:	55                   	push   %ebp
80106a39:	89 e5                	mov    %esp,%ebp
80106a3b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106a3e:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106a43:	85 c0                	test   %eax,%eax
80106a45:	74 53                	je     80106a9a <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a4e:	eb 11                	jmp    80106a61 <uartputc+0x2d>
    microdelay(10);
80106a50:	83 ec 0c             	sub    $0xc,%esp
80106a53:	6a 0a                	push   $0xa
80106a55:	e8 dc c1 ff ff       	call   80102c36 <microdelay>
80106a5a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106a5d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a61:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106a65:	7f 1a                	jg     80106a81 <uartputc+0x4d>
80106a67:	83 ec 0c             	sub    $0xc,%esp
80106a6a:	68 fd 03 00 00       	push   $0x3fd
80106a6f:	e8 97 fe ff ff       	call   8010690b <inb>
80106a74:	83 c4 10             	add    $0x10,%esp
80106a77:	0f b6 c0             	movzbl %al,%eax
80106a7a:	83 e0 20             	and    $0x20,%eax
80106a7d:	85 c0                	test   %eax,%eax
80106a7f:	74 cf                	je     80106a50 <uartputc+0x1c>
  outb(COM1+0, c);
80106a81:	8b 45 08             	mov    0x8(%ebp),%eax
80106a84:	0f b6 c0             	movzbl %al,%eax
80106a87:	83 ec 08             	sub    $0x8,%esp
80106a8a:	50                   	push   %eax
80106a8b:	68 f8 03 00 00       	push   $0x3f8
80106a90:	e8 93 fe ff ff       	call   80106928 <outb>
80106a95:	83 c4 10             	add    $0x10,%esp
80106a98:	eb 01                	jmp    80106a9b <uartputc+0x67>
    return;
80106a9a:	90                   	nop
}
80106a9b:	c9                   	leave  
80106a9c:	c3                   	ret    

80106a9d <uartgetc>:

static int
uartgetc(void)
{
80106a9d:	f3 0f 1e fb          	endbr32 
80106aa1:	55                   	push   %ebp
80106aa2:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106aa4:	a1 60 d0 18 80       	mov    0x8018d060,%eax
80106aa9:	85 c0                	test   %eax,%eax
80106aab:	75 07                	jne    80106ab4 <uartgetc+0x17>
    return -1;
80106aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ab2:	eb 2e                	jmp    80106ae2 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106ab4:	68 fd 03 00 00       	push   $0x3fd
80106ab9:	e8 4d fe ff ff       	call   8010690b <inb>
80106abe:	83 c4 04             	add    $0x4,%esp
80106ac1:	0f b6 c0             	movzbl %al,%eax
80106ac4:	83 e0 01             	and    $0x1,%eax
80106ac7:	85 c0                	test   %eax,%eax
80106ac9:	75 07                	jne    80106ad2 <uartgetc+0x35>
    return -1;
80106acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad0:	eb 10                	jmp    80106ae2 <uartgetc+0x45>
  return inb(COM1+0);
80106ad2:	68 f8 03 00 00       	push   $0x3f8
80106ad7:	e8 2f fe ff ff       	call   8010690b <inb>
80106adc:	83 c4 04             	add    $0x4,%esp
80106adf:	0f b6 c0             	movzbl %al,%eax
}
80106ae2:	c9                   	leave  
80106ae3:	c3                   	ret    

80106ae4 <uartintr>:

void
uartintr(void)
{
80106ae4:	f3 0f 1e fb          	endbr32 
80106ae8:	55                   	push   %ebp
80106ae9:	89 e5                	mov    %esp,%ebp
80106aeb:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106aee:	83 ec 0c             	sub    $0xc,%esp
80106af1:	68 9d 6a 10 80       	push   $0x80106a9d
80106af6:	e8 05 9d ff ff       	call   80100800 <consoleintr>
80106afb:	83 c4 10             	add    $0x10,%esp
}
80106afe:	90                   	nop
80106aff:	c9                   	leave  
80106b00:	c3                   	ret    

80106b01 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106b01:	6a 00                	push   $0x0
  pushl $0
80106b03:	6a 00                	push   $0x0
  jmp alltraps
80106b05:	e9 47 f9 ff ff       	jmp    80106451 <alltraps>

80106b0a <vector1>:
.globl vector1
vector1:
  pushl $0
80106b0a:	6a 00                	push   $0x0
  pushl $1
80106b0c:	6a 01                	push   $0x1
  jmp alltraps
80106b0e:	e9 3e f9 ff ff       	jmp    80106451 <alltraps>

80106b13 <vector2>:
.globl vector2
vector2:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $2
80106b15:	6a 02                	push   $0x2
  jmp alltraps
80106b17:	e9 35 f9 ff ff       	jmp    80106451 <alltraps>

80106b1c <vector3>:
.globl vector3
vector3:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $3
80106b1e:	6a 03                	push   $0x3
  jmp alltraps
80106b20:	e9 2c f9 ff ff       	jmp    80106451 <alltraps>

80106b25 <vector4>:
.globl vector4
vector4:
  pushl $0
80106b25:	6a 00                	push   $0x0
  pushl $4
80106b27:	6a 04                	push   $0x4
  jmp alltraps
80106b29:	e9 23 f9 ff ff       	jmp    80106451 <alltraps>

80106b2e <vector5>:
.globl vector5
vector5:
  pushl $0
80106b2e:	6a 00                	push   $0x0
  pushl $5
80106b30:	6a 05                	push   $0x5
  jmp alltraps
80106b32:	e9 1a f9 ff ff       	jmp    80106451 <alltraps>

80106b37 <vector6>:
.globl vector6
vector6:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $6
80106b39:	6a 06                	push   $0x6
  jmp alltraps
80106b3b:	e9 11 f9 ff ff       	jmp    80106451 <alltraps>

80106b40 <vector7>:
.globl vector7
vector7:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $7
80106b42:	6a 07                	push   $0x7
  jmp alltraps
80106b44:	e9 08 f9 ff ff       	jmp    80106451 <alltraps>

80106b49 <vector8>:
.globl vector8
vector8:
  pushl $8
80106b49:	6a 08                	push   $0x8
  jmp alltraps
80106b4b:	e9 01 f9 ff ff       	jmp    80106451 <alltraps>

80106b50 <vector9>:
.globl vector9
vector9:
  pushl $0
80106b50:	6a 00                	push   $0x0
  pushl $9
80106b52:	6a 09                	push   $0x9
  jmp alltraps
80106b54:	e9 f8 f8 ff ff       	jmp    80106451 <alltraps>

80106b59 <vector10>:
.globl vector10
vector10:
  pushl $10
80106b59:	6a 0a                	push   $0xa
  jmp alltraps
80106b5b:	e9 f1 f8 ff ff       	jmp    80106451 <alltraps>

80106b60 <vector11>:
.globl vector11
vector11:
  pushl $11
80106b60:	6a 0b                	push   $0xb
  jmp alltraps
80106b62:	e9 ea f8 ff ff       	jmp    80106451 <alltraps>

80106b67 <vector12>:
.globl vector12
vector12:
  pushl $12
80106b67:	6a 0c                	push   $0xc
  jmp alltraps
80106b69:	e9 e3 f8 ff ff       	jmp    80106451 <alltraps>

80106b6e <vector13>:
.globl vector13
vector13:
  pushl $13
80106b6e:	6a 0d                	push   $0xd
  jmp alltraps
80106b70:	e9 dc f8 ff ff       	jmp    80106451 <alltraps>

80106b75 <vector14>:
.globl vector14
vector14:
  pushl $14
80106b75:	6a 0e                	push   $0xe
  jmp alltraps
80106b77:	e9 d5 f8 ff ff       	jmp    80106451 <alltraps>

80106b7c <vector15>:
.globl vector15
vector15:
  pushl $0
80106b7c:	6a 00                	push   $0x0
  pushl $15
80106b7e:	6a 0f                	push   $0xf
  jmp alltraps
80106b80:	e9 cc f8 ff ff       	jmp    80106451 <alltraps>

80106b85 <vector16>:
.globl vector16
vector16:
  pushl $0
80106b85:	6a 00                	push   $0x0
  pushl $16
80106b87:	6a 10                	push   $0x10
  jmp alltraps
80106b89:	e9 c3 f8 ff ff       	jmp    80106451 <alltraps>

80106b8e <vector17>:
.globl vector17
vector17:
  pushl $17
80106b8e:	6a 11                	push   $0x11
  jmp alltraps
80106b90:	e9 bc f8 ff ff       	jmp    80106451 <alltraps>

80106b95 <vector18>:
.globl vector18
vector18:
  pushl $0
80106b95:	6a 00                	push   $0x0
  pushl $18
80106b97:	6a 12                	push   $0x12
  jmp alltraps
80106b99:	e9 b3 f8 ff ff       	jmp    80106451 <alltraps>

80106b9e <vector19>:
.globl vector19
vector19:
  pushl $0
80106b9e:	6a 00                	push   $0x0
  pushl $19
80106ba0:	6a 13                	push   $0x13
  jmp alltraps
80106ba2:	e9 aa f8 ff ff       	jmp    80106451 <alltraps>

80106ba7 <vector20>:
.globl vector20
vector20:
  pushl $0
80106ba7:	6a 00                	push   $0x0
  pushl $20
80106ba9:	6a 14                	push   $0x14
  jmp alltraps
80106bab:	e9 a1 f8 ff ff       	jmp    80106451 <alltraps>

80106bb0 <vector21>:
.globl vector21
vector21:
  pushl $0
80106bb0:	6a 00                	push   $0x0
  pushl $21
80106bb2:	6a 15                	push   $0x15
  jmp alltraps
80106bb4:	e9 98 f8 ff ff       	jmp    80106451 <alltraps>

80106bb9 <vector22>:
.globl vector22
vector22:
  pushl $0
80106bb9:	6a 00                	push   $0x0
  pushl $22
80106bbb:	6a 16                	push   $0x16
  jmp alltraps
80106bbd:	e9 8f f8 ff ff       	jmp    80106451 <alltraps>

80106bc2 <vector23>:
.globl vector23
vector23:
  pushl $0
80106bc2:	6a 00                	push   $0x0
  pushl $23
80106bc4:	6a 17                	push   $0x17
  jmp alltraps
80106bc6:	e9 86 f8 ff ff       	jmp    80106451 <alltraps>

80106bcb <vector24>:
.globl vector24
vector24:
  pushl $0
80106bcb:	6a 00                	push   $0x0
  pushl $24
80106bcd:	6a 18                	push   $0x18
  jmp alltraps
80106bcf:	e9 7d f8 ff ff       	jmp    80106451 <alltraps>

80106bd4 <vector25>:
.globl vector25
vector25:
  pushl $0
80106bd4:	6a 00                	push   $0x0
  pushl $25
80106bd6:	6a 19                	push   $0x19
  jmp alltraps
80106bd8:	e9 74 f8 ff ff       	jmp    80106451 <alltraps>

80106bdd <vector26>:
.globl vector26
vector26:
  pushl $0
80106bdd:	6a 00                	push   $0x0
  pushl $26
80106bdf:	6a 1a                	push   $0x1a
  jmp alltraps
80106be1:	e9 6b f8 ff ff       	jmp    80106451 <alltraps>

80106be6 <vector27>:
.globl vector27
vector27:
  pushl $0
80106be6:	6a 00                	push   $0x0
  pushl $27
80106be8:	6a 1b                	push   $0x1b
  jmp alltraps
80106bea:	e9 62 f8 ff ff       	jmp    80106451 <alltraps>

80106bef <vector28>:
.globl vector28
vector28:
  pushl $0
80106bef:	6a 00                	push   $0x0
  pushl $28
80106bf1:	6a 1c                	push   $0x1c
  jmp alltraps
80106bf3:	e9 59 f8 ff ff       	jmp    80106451 <alltraps>

80106bf8 <vector29>:
.globl vector29
vector29:
  pushl $0
80106bf8:	6a 00                	push   $0x0
  pushl $29
80106bfa:	6a 1d                	push   $0x1d
  jmp alltraps
80106bfc:	e9 50 f8 ff ff       	jmp    80106451 <alltraps>

80106c01 <vector30>:
.globl vector30
vector30:
  pushl $0
80106c01:	6a 00                	push   $0x0
  pushl $30
80106c03:	6a 1e                	push   $0x1e
  jmp alltraps
80106c05:	e9 47 f8 ff ff       	jmp    80106451 <alltraps>

80106c0a <vector31>:
.globl vector31
vector31:
  pushl $0
80106c0a:	6a 00                	push   $0x0
  pushl $31
80106c0c:	6a 1f                	push   $0x1f
  jmp alltraps
80106c0e:	e9 3e f8 ff ff       	jmp    80106451 <alltraps>

80106c13 <vector32>:
.globl vector32
vector32:
  pushl $0
80106c13:	6a 00                	push   $0x0
  pushl $32
80106c15:	6a 20                	push   $0x20
  jmp alltraps
80106c17:	e9 35 f8 ff ff       	jmp    80106451 <alltraps>

80106c1c <vector33>:
.globl vector33
vector33:
  pushl $0
80106c1c:	6a 00                	push   $0x0
  pushl $33
80106c1e:	6a 21                	push   $0x21
  jmp alltraps
80106c20:	e9 2c f8 ff ff       	jmp    80106451 <alltraps>

80106c25 <vector34>:
.globl vector34
vector34:
  pushl $0
80106c25:	6a 00                	push   $0x0
  pushl $34
80106c27:	6a 22                	push   $0x22
  jmp alltraps
80106c29:	e9 23 f8 ff ff       	jmp    80106451 <alltraps>

80106c2e <vector35>:
.globl vector35
vector35:
  pushl $0
80106c2e:	6a 00                	push   $0x0
  pushl $35
80106c30:	6a 23                	push   $0x23
  jmp alltraps
80106c32:	e9 1a f8 ff ff       	jmp    80106451 <alltraps>

80106c37 <vector36>:
.globl vector36
vector36:
  pushl $0
80106c37:	6a 00                	push   $0x0
  pushl $36
80106c39:	6a 24                	push   $0x24
  jmp alltraps
80106c3b:	e9 11 f8 ff ff       	jmp    80106451 <alltraps>

80106c40 <vector37>:
.globl vector37
vector37:
  pushl $0
80106c40:	6a 00                	push   $0x0
  pushl $37
80106c42:	6a 25                	push   $0x25
  jmp alltraps
80106c44:	e9 08 f8 ff ff       	jmp    80106451 <alltraps>

80106c49 <vector38>:
.globl vector38
vector38:
  pushl $0
80106c49:	6a 00                	push   $0x0
  pushl $38
80106c4b:	6a 26                	push   $0x26
  jmp alltraps
80106c4d:	e9 ff f7 ff ff       	jmp    80106451 <alltraps>

80106c52 <vector39>:
.globl vector39
vector39:
  pushl $0
80106c52:	6a 00                	push   $0x0
  pushl $39
80106c54:	6a 27                	push   $0x27
  jmp alltraps
80106c56:	e9 f6 f7 ff ff       	jmp    80106451 <alltraps>

80106c5b <vector40>:
.globl vector40
vector40:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $40
80106c5d:	6a 28                	push   $0x28
  jmp alltraps
80106c5f:	e9 ed f7 ff ff       	jmp    80106451 <alltraps>

80106c64 <vector41>:
.globl vector41
vector41:
  pushl $0
80106c64:	6a 00                	push   $0x0
  pushl $41
80106c66:	6a 29                	push   $0x29
  jmp alltraps
80106c68:	e9 e4 f7 ff ff       	jmp    80106451 <alltraps>

80106c6d <vector42>:
.globl vector42
vector42:
  pushl $0
80106c6d:	6a 00                	push   $0x0
  pushl $42
80106c6f:	6a 2a                	push   $0x2a
  jmp alltraps
80106c71:	e9 db f7 ff ff       	jmp    80106451 <alltraps>

80106c76 <vector43>:
.globl vector43
vector43:
  pushl $0
80106c76:	6a 00                	push   $0x0
  pushl $43
80106c78:	6a 2b                	push   $0x2b
  jmp alltraps
80106c7a:	e9 d2 f7 ff ff       	jmp    80106451 <alltraps>

80106c7f <vector44>:
.globl vector44
vector44:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $44
80106c81:	6a 2c                	push   $0x2c
  jmp alltraps
80106c83:	e9 c9 f7 ff ff       	jmp    80106451 <alltraps>

80106c88 <vector45>:
.globl vector45
vector45:
  pushl $0
80106c88:	6a 00                	push   $0x0
  pushl $45
80106c8a:	6a 2d                	push   $0x2d
  jmp alltraps
80106c8c:	e9 c0 f7 ff ff       	jmp    80106451 <alltraps>

80106c91 <vector46>:
.globl vector46
vector46:
  pushl $0
80106c91:	6a 00                	push   $0x0
  pushl $46
80106c93:	6a 2e                	push   $0x2e
  jmp alltraps
80106c95:	e9 b7 f7 ff ff       	jmp    80106451 <alltraps>

80106c9a <vector47>:
.globl vector47
vector47:
  pushl $0
80106c9a:	6a 00                	push   $0x0
  pushl $47
80106c9c:	6a 2f                	push   $0x2f
  jmp alltraps
80106c9e:	e9 ae f7 ff ff       	jmp    80106451 <alltraps>

80106ca3 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $48
80106ca5:	6a 30                	push   $0x30
  jmp alltraps
80106ca7:	e9 a5 f7 ff ff       	jmp    80106451 <alltraps>

80106cac <vector49>:
.globl vector49
vector49:
  pushl $0
80106cac:	6a 00                	push   $0x0
  pushl $49
80106cae:	6a 31                	push   $0x31
  jmp alltraps
80106cb0:	e9 9c f7 ff ff       	jmp    80106451 <alltraps>

80106cb5 <vector50>:
.globl vector50
vector50:
  pushl $0
80106cb5:	6a 00                	push   $0x0
  pushl $50
80106cb7:	6a 32                	push   $0x32
  jmp alltraps
80106cb9:	e9 93 f7 ff ff       	jmp    80106451 <alltraps>

80106cbe <vector51>:
.globl vector51
vector51:
  pushl $0
80106cbe:	6a 00                	push   $0x0
  pushl $51
80106cc0:	6a 33                	push   $0x33
  jmp alltraps
80106cc2:	e9 8a f7 ff ff       	jmp    80106451 <alltraps>

80106cc7 <vector52>:
.globl vector52
vector52:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $52
80106cc9:	6a 34                	push   $0x34
  jmp alltraps
80106ccb:	e9 81 f7 ff ff       	jmp    80106451 <alltraps>

80106cd0 <vector53>:
.globl vector53
vector53:
  pushl $0
80106cd0:	6a 00                	push   $0x0
  pushl $53
80106cd2:	6a 35                	push   $0x35
  jmp alltraps
80106cd4:	e9 78 f7 ff ff       	jmp    80106451 <alltraps>

80106cd9 <vector54>:
.globl vector54
vector54:
  pushl $0
80106cd9:	6a 00                	push   $0x0
  pushl $54
80106cdb:	6a 36                	push   $0x36
  jmp alltraps
80106cdd:	e9 6f f7 ff ff       	jmp    80106451 <alltraps>

80106ce2 <vector55>:
.globl vector55
vector55:
  pushl $0
80106ce2:	6a 00                	push   $0x0
  pushl $55
80106ce4:	6a 37                	push   $0x37
  jmp alltraps
80106ce6:	e9 66 f7 ff ff       	jmp    80106451 <alltraps>

80106ceb <vector56>:
.globl vector56
vector56:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $56
80106ced:	6a 38                	push   $0x38
  jmp alltraps
80106cef:	e9 5d f7 ff ff       	jmp    80106451 <alltraps>

80106cf4 <vector57>:
.globl vector57
vector57:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $57
80106cf6:	6a 39                	push   $0x39
  jmp alltraps
80106cf8:	e9 54 f7 ff ff       	jmp    80106451 <alltraps>

80106cfd <vector58>:
.globl vector58
vector58:
  pushl $0
80106cfd:	6a 00                	push   $0x0
  pushl $58
80106cff:	6a 3a                	push   $0x3a
  jmp alltraps
80106d01:	e9 4b f7 ff ff       	jmp    80106451 <alltraps>

80106d06 <vector59>:
.globl vector59
vector59:
  pushl $0
80106d06:	6a 00                	push   $0x0
  pushl $59
80106d08:	6a 3b                	push   $0x3b
  jmp alltraps
80106d0a:	e9 42 f7 ff ff       	jmp    80106451 <alltraps>

80106d0f <vector60>:
.globl vector60
vector60:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $60
80106d11:	6a 3c                	push   $0x3c
  jmp alltraps
80106d13:	e9 39 f7 ff ff       	jmp    80106451 <alltraps>

80106d18 <vector61>:
.globl vector61
vector61:
  pushl $0
80106d18:	6a 00                	push   $0x0
  pushl $61
80106d1a:	6a 3d                	push   $0x3d
  jmp alltraps
80106d1c:	e9 30 f7 ff ff       	jmp    80106451 <alltraps>

80106d21 <vector62>:
.globl vector62
vector62:
  pushl $0
80106d21:	6a 00                	push   $0x0
  pushl $62
80106d23:	6a 3e                	push   $0x3e
  jmp alltraps
80106d25:	e9 27 f7 ff ff       	jmp    80106451 <alltraps>

80106d2a <vector63>:
.globl vector63
vector63:
  pushl $0
80106d2a:	6a 00                	push   $0x0
  pushl $63
80106d2c:	6a 3f                	push   $0x3f
  jmp alltraps
80106d2e:	e9 1e f7 ff ff       	jmp    80106451 <alltraps>

80106d33 <vector64>:
.globl vector64
vector64:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $64
80106d35:	6a 40                	push   $0x40
  jmp alltraps
80106d37:	e9 15 f7 ff ff       	jmp    80106451 <alltraps>

80106d3c <vector65>:
.globl vector65
vector65:
  pushl $0
80106d3c:	6a 00                	push   $0x0
  pushl $65
80106d3e:	6a 41                	push   $0x41
  jmp alltraps
80106d40:	e9 0c f7 ff ff       	jmp    80106451 <alltraps>

80106d45 <vector66>:
.globl vector66
vector66:
  pushl $0
80106d45:	6a 00                	push   $0x0
  pushl $66
80106d47:	6a 42                	push   $0x42
  jmp alltraps
80106d49:	e9 03 f7 ff ff       	jmp    80106451 <alltraps>

80106d4e <vector67>:
.globl vector67
vector67:
  pushl $0
80106d4e:	6a 00                	push   $0x0
  pushl $67
80106d50:	6a 43                	push   $0x43
  jmp alltraps
80106d52:	e9 fa f6 ff ff       	jmp    80106451 <alltraps>

80106d57 <vector68>:
.globl vector68
vector68:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $68
80106d59:	6a 44                	push   $0x44
  jmp alltraps
80106d5b:	e9 f1 f6 ff ff       	jmp    80106451 <alltraps>

80106d60 <vector69>:
.globl vector69
vector69:
  pushl $0
80106d60:	6a 00                	push   $0x0
  pushl $69
80106d62:	6a 45                	push   $0x45
  jmp alltraps
80106d64:	e9 e8 f6 ff ff       	jmp    80106451 <alltraps>

80106d69 <vector70>:
.globl vector70
vector70:
  pushl $0
80106d69:	6a 00                	push   $0x0
  pushl $70
80106d6b:	6a 46                	push   $0x46
  jmp alltraps
80106d6d:	e9 df f6 ff ff       	jmp    80106451 <alltraps>

80106d72 <vector71>:
.globl vector71
vector71:
  pushl $0
80106d72:	6a 00                	push   $0x0
  pushl $71
80106d74:	6a 47                	push   $0x47
  jmp alltraps
80106d76:	e9 d6 f6 ff ff       	jmp    80106451 <alltraps>

80106d7b <vector72>:
.globl vector72
vector72:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $72
80106d7d:	6a 48                	push   $0x48
  jmp alltraps
80106d7f:	e9 cd f6 ff ff       	jmp    80106451 <alltraps>

80106d84 <vector73>:
.globl vector73
vector73:
  pushl $0
80106d84:	6a 00                	push   $0x0
  pushl $73
80106d86:	6a 49                	push   $0x49
  jmp alltraps
80106d88:	e9 c4 f6 ff ff       	jmp    80106451 <alltraps>

80106d8d <vector74>:
.globl vector74
vector74:
  pushl $0
80106d8d:	6a 00                	push   $0x0
  pushl $74
80106d8f:	6a 4a                	push   $0x4a
  jmp alltraps
80106d91:	e9 bb f6 ff ff       	jmp    80106451 <alltraps>

80106d96 <vector75>:
.globl vector75
vector75:
  pushl $0
80106d96:	6a 00                	push   $0x0
  pushl $75
80106d98:	6a 4b                	push   $0x4b
  jmp alltraps
80106d9a:	e9 b2 f6 ff ff       	jmp    80106451 <alltraps>

80106d9f <vector76>:
.globl vector76
vector76:
  pushl $0
80106d9f:	6a 00                	push   $0x0
  pushl $76
80106da1:	6a 4c                	push   $0x4c
  jmp alltraps
80106da3:	e9 a9 f6 ff ff       	jmp    80106451 <alltraps>

80106da8 <vector77>:
.globl vector77
vector77:
  pushl $0
80106da8:	6a 00                	push   $0x0
  pushl $77
80106daa:	6a 4d                	push   $0x4d
  jmp alltraps
80106dac:	e9 a0 f6 ff ff       	jmp    80106451 <alltraps>

80106db1 <vector78>:
.globl vector78
vector78:
  pushl $0
80106db1:	6a 00                	push   $0x0
  pushl $78
80106db3:	6a 4e                	push   $0x4e
  jmp alltraps
80106db5:	e9 97 f6 ff ff       	jmp    80106451 <alltraps>

80106dba <vector79>:
.globl vector79
vector79:
  pushl $0
80106dba:	6a 00                	push   $0x0
  pushl $79
80106dbc:	6a 4f                	push   $0x4f
  jmp alltraps
80106dbe:	e9 8e f6 ff ff       	jmp    80106451 <alltraps>

80106dc3 <vector80>:
.globl vector80
vector80:
  pushl $0
80106dc3:	6a 00                	push   $0x0
  pushl $80
80106dc5:	6a 50                	push   $0x50
  jmp alltraps
80106dc7:	e9 85 f6 ff ff       	jmp    80106451 <alltraps>

80106dcc <vector81>:
.globl vector81
vector81:
  pushl $0
80106dcc:	6a 00                	push   $0x0
  pushl $81
80106dce:	6a 51                	push   $0x51
  jmp alltraps
80106dd0:	e9 7c f6 ff ff       	jmp    80106451 <alltraps>

80106dd5 <vector82>:
.globl vector82
vector82:
  pushl $0
80106dd5:	6a 00                	push   $0x0
  pushl $82
80106dd7:	6a 52                	push   $0x52
  jmp alltraps
80106dd9:	e9 73 f6 ff ff       	jmp    80106451 <alltraps>

80106dde <vector83>:
.globl vector83
vector83:
  pushl $0
80106dde:	6a 00                	push   $0x0
  pushl $83
80106de0:	6a 53                	push   $0x53
  jmp alltraps
80106de2:	e9 6a f6 ff ff       	jmp    80106451 <alltraps>

80106de7 <vector84>:
.globl vector84
vector84:
  pushl $0
80106de7:	6a 00                	push   $0x0
  pushl $84
80106de9:	6a 54                	push   $0x54
  jmp alltraps
80106deb:	e9 61 f6 ff ff       	jmp    80106451 <alltraps>

80106df0 <vector85>:
.globl vector85
vector85:
  pushl $0
80106df0:	6a 00                	push   $0x0
  pushl $85
80106df2:	6a 55                	push   $0x55
  jmp alltraps
80106df4:	e9 58 f6 ff ff       	jmp    80106451 <alltraps>

80106df9 <vector86>:
.globl vector86
vector86:
  pushl $0
80106df9:	6a 00                	push   $0x0
  pushl $86
80106dfb:	6a 56                	push   $0x56
  jmp alltraps
80106dfd:	e9 4f f6 ff ff       	jmp    80106451 <alltraps>

80106e02 <vector87>:
.globl vector87
vector87:
  pushl $0
80106e02:	6a 00                	push   $0x0
  pushl $87
80106e04:	6a 57                	push   $0x57
  jmp alltraps
80106e06:	e9 46 f6 ff ff       	jmp    80106451 <alltraps>

80106e0b <vector88>:
.globl vector88
vector88:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $88
80106e0d:	6a 58                	push   $0x58
  jmp alltraps
80106e0f:	e9 3d f6 ff ff       	jmp    80106451 <alltraps>

80106e14 <vector89>:
.globl vector89
vector89:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $89
80106e16:	6a 59                	push   $0x59
  jmp alltraps
80106e18:	e9 34 f6 ff ff       	jmp    80106451 <alltraps>

80106e1d <vector90>:
.globl vector90
vector90:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $90
80106e1f:	6a 5a                	push   $0x5a
  jmp alltraps
80106e21:	e9 2b f6 ff ff       	jmp    80106451 <alltraps>

80106e26 <vector91>:
.globl vector91
vector91:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $91
80106e28:	6a 5b                	push   $0x5b
  jmp alltraps
80106e2a:	e9 22 f6 ff ff       	jmp    80106451 <alltraps>

80106e2f <vector92>:
.globl vector92
vector92:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $92
80106e31:	6a 5c                	push   $0x5c
  jmp alltraps
80106e33:	e9 19 f6 ff ff       	jmp    80106451 <alltraps>

80106e38 <vector93>:
.globl vector93
vector93:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $93
80106e3a:	6a 5d                	push   $0x5d
  jmp alltraps
80106e3c:	e9 10 f6 ff ff       	jmp    80106451 <alltraps>

80106e41 <vector94>:
.globl vector94
vector94:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $94
80106e43:	6a 5e                	push   $0x5e
  jmp alltraps
80106e45:	e9 07 f6 ff ff       	jmp    80106451 <alltraps>

80106e4a <vector95>:
.globl vector95
vector95:
  pushl $0
80106e4a:	6a 00                	push   $0x0
  pushl $95
80106e4c:	6a 5f                	push   $0x5f
  jmp alltraps
80106e4e:	e9 fe f5 ff ff       	jmp    80106451 <alltraps>

80106e53 <vector96>:
.globl vector96
vector96:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $96
80106e55:	6a 60                	push   $0x60
  jmp alltraps
80106e57:	e9 f5 f5 ff ff       	jmp    80106451 <alltraps>

80106e5c <vector97>:
.globl vector97
vector97:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $97
80106e5e:	6a 61                	push   $0x61
  jmp alltraps
80106e60:	e9 ec f5 ff ff       	jmp    80106451 <alltraps>

80106e65 <vector98>:
.globl vector98
vector98:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $98
80106e67:	6a 62                	push   $0x62
  jmp alltraps
80106e69:	e9 e3 f5 ff ff       	jmp    80106451 <alltraps>

80106e6e <vector99>:
.globl vector99
vector99:
  pushl $0
80106e6e:	6a 00                	push   $0x0
  pushl $99
80106e70:	6a 63                	push   $0x63
  jmp alltraps
80106e72:	e9 da f5 ff ff       	jmp    80106451 <alltraps>

80106e77 <vector100>:
.globl vector100
vector100:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $100
80106e79:	6a 64                	push   $0x64
  jmp alltraps
80106e7b:	e9 d1 f5 ff ff       	jmp    80106451 <alltraps>

80106e80 <vector101>:
.globl vector101
vector101:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $101
80106e82:	6a 65                	push   $0x65
  jmp alltraps
80106e84:	e9 c8 f5 ff ff       	jmp    80106451 <alltraps>

80106e89 <vector102>:
.globl vector102
vector102:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $102
80106e8b:	6a 66                	push   $0x66
  jmp alltraps
80106e8d:	e9 bf f5 ff ff       	jmp    80106451 <alltraps>

80106e92 <vector103>:
.globl vector103
vector103:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $103
80106e94:	6a 67                	push   $0x67
  jmp alltraps
80106e96:	e9 b6 f5 ff ff       	jmp    80106451 <alltraps>

80106e9b <vector104>:
.globl vector104
vector104:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $104
80106e9d:	6a 68                	push   $0x68
  jmp alltraps
80106e9f:	e9 ad f5 ff ff       	jmp    80106451 <alltraps>

80106ea4 <vector105>:
.globl vector105
vector105:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $105
80106ea6:	6a 69                	push   $0x69
  jmp alltraps
80106ea8:	e9 a4 f5 ff ff       	jmp    80106451 <alltraps>

80106ead <vector106>:
.globl vector106
vector106:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $106
80106eaf:	6a 6a                	push   $0x6a
  jmp alltraps
80106eb1:	e9 9b f5 ff ff       	jmp    80106451 <alltraps>

80106eb6 <vector107>:
.globl vector107
vector107:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $107
80106eb8:	6a 6b                	push   $0x6b
  jmp alltraps
80106eba:	e9 92 f5 ff ff       	jmp    80106451 <alltraps>

80106ebf <vector108>:
.globl vector108
vector108:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $108
80106ec1:	6a 6c                	push   $0x6c
  jmp alltraps
80106ec3:	e9 89 f5 ff ff       	jmp    80106451 <alltraps>

80106ec8 <vector109>:
.globl vector109
vector109:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $109
80106eca:	6a 6d                	push   $0x6d
  jmp alltraps
80106ecc:	e9 80 f5 ff ff       	jmp    80106451 <alltraps>

80106ed1 <vector110>:
.globl vector110
vector110:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $110
80106ed3:	6a 6e                	push   $0x6e
  jmp alltraps
80106ed5:	e9 77 f5 ff ff       	jmp    80106451 <alltraps>

80106eda <vector111>:
.globl vector111
vector111:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $111
80106edc:	6a 6f                	push   $0x6f
  jmp alltraps
80106ede:	e9 6e f5 ff ff       	jmp    80106451 <alltraps>

80106ee3 <vector112>:
.globl vector112
vector112:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $112
80106ee5:	6a 70                	push   $0x70
  jmp alltraps
80106ee7:	e9 65 f5 ff ff       	jmp    80106451 <alltraps>

80106eec <vector113>:
.globl vector113
vector113:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $113
80106eee:	6a 71                	push   $0x71
  jmp alltraps
80106ef0:	e9 5c f5 ff ff       	jmp    80106451 <alltraps>

80106ef5 <vector114>:
.globl vector114
vector114:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $114
80106ef7:	6a 72                	push   $0x72
  jmp alltraps
80106ef9:	e9 53 f5 ff ff       	jmp    80106451 <alltraps>

80106efe <vector115>:
.globl vector115
vector115:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $115
80106f00:	6a 73                	push   $0x73
  jmp alltraps
80106f02:	e9 4a f5 ff ff       	jmp    80106451 <alltraps>

80106f07 <vector116>:
.globl vector116
vector116:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $116
80106f09:	6a 74                	push   $0x74
  jmp alltraps
80106f0b:	e9 41 f5 ff ff       	jmp    80106451 <alltraps>

80106f10 <vector117>:
.globl vector117
vector117:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $117
80106f12:	6a 75                	push   $0x75
  jmp alltraps
80106f14:	e9 38 f5 ff ff       	jmp    80106451 <alltraps>

80106f19 <vector118>:
.globl vector118
vector118:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $118
80106f1b:	6a 76                	push   $0x76
  jmp alltraps
80106f1d:	e9 2f f5 ff ff       	jmp    80106451 <alltraps>

80106f22 <vector119>:
.globl vector119
vector119:
  pushl $0
80106f22:	6a 00                	push   $0x0
  pushl $119
80106f24:	6a 77                	push   $0x77
  jmp alltraps
80106f26:	e9 26 f5 ff ff       	jmp    80106451 <alltraps>

80106f2b <vector120>:
.globl vector120
vector120:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $120
80106f2d:	6a 78                	push   $0x78
  jmp alltraps
80106f2f:	e9 1d f5 ff ff       	jmp    80106451 <alltraps>

80106f34 <vector121>:
.globl vector121
vector121:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $121
80106f36:	6a 79                	push   $0x79
  jmp alltraps
80106f38:	e9 14 f5 ff ff       	jmp    80106451 <alltraps>

80106f3d <vector122>:
.globl vector122
vector122:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $122
80106f3f:	6a 7a                	push   $0x7a
  jmp alltraps
80106f41:	e9 0b f5 ff ff       	jmp    80106451 <alltraps>

80106f46 <vector123>:
.globl vector123
vector123:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $123
80106f48:	6a 7b                	push   $0x7b
  jmp alltraps
80106f4a:	e9 02 f5 ff ff       	jmp    80106451 <alltraps>

80106f4f <vector124>:
.globl vector124
vector124:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $124
80106f51:	6a 7c                	push   $0x7c
  jmp alltraps
80106f53:	e9 f9 f4 ff ff       	jmp    80106451 <alltraps>

80106f58 <vector125>:
.globl vector125
vector125:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $125
80106f5a:	6a 7d                	push   $0x7d
  jmp alltraps
80106f5c:	e9 f0 f4 ff ff       	jmp    80106451 <alltraps>

80106f61 <vector126>:
.globl vector126
vector126:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $126
80106f63:	6a 7e                	push   $0x7e
  jmp alltraps
80106f65:	e9 e7 f4 ff ff       	jmp    80106451 <alltraps>

80106f6a <vector127>:
.globl vector127
vector127:
  pushl $0
80106f6a:	6a 00                	push   $0x0
  pushl $127
80106f6c:	6a 7f                	push   $0x7f
  jmp alltraps
80106f6e:	e9 de f4 ff ff       	jmp    80106451 <alltraps>

80106f73 <vector128>:
.globl vector128
vector128:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $128
80106f75:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106f7a:	e9 d2 f4 ff ff       	jmp    80106451 <alltraps>

80106f7f <vector129>:
.globl vector129
vector129:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $129
80106f81:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106f86:	e9 c6 f4 ff ff       	jmp    80106451 <alltraps>

80106f8b <vector130>:
.globl vector130
vector130:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $130
80106f8d:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106f92:	e9 ba f4 ff ff       	jmp    80106451 <alltraps>

80106f97 <vector131>:
.globl vector131
vector131:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $131
80106f99:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106f9e:	e9 ae f4 ff ff       	jmp    80106451 <alltraps>

80106fa3 <vector132>:
.globl vector132
vector132:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $132
80106fa5:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106faa:	e9 a2 f4 ff ff       	jmp    80106451 <alltraps>

80106faf <vector133>:
.globl vector133
vector133:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $133
80106fb1:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106fb6:	e9 96 f4 ff ff       	jmp    80106451 <alltraps>

80106fbb <vector134>:
.globl vector134
vector134:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $134
80106fbd:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106fc2:	e9 8a f4 ff ff       	jmp    80106451 <alltraps>

80106fc7 <vector135>:
.globl vector135
vector135:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $135
80106fc9:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106fce:	e9 7e f4 ff ff       	jmp    80106451 <alltraps>

80106fd3 <vector136>:
.globl vector136
vector136:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $136
80106fd5:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106fda:	e9 72 f4 ff ff       	jmp    80106451 <alltraps>

80106fdf <vector137>:
.globl vector137
vector137:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $137
80106fe1:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106fe6:	e9 66 f4 ff ff       	jmp    80106451 <alltraps>

80106feb <vector138>:
.globl vector138
vector138:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $138
80106fed:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106ff2:	e9 5a f4 ff ff       	jmp    80106451 <alltraps>

80106ff7 <vector139>:
.globl vector139
vector139:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $139
80106ff9:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106ffe:	e9 4e f4 ff ff       	jmp    80106451 <alltraps>

80107003 <vector140>:
.globl vector140
vector140:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $140
80107005:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010700a:	e9 42 f4 ff ff       	jmp    80106451 <alltraps>

8010700f <vector141>:
.globl vector141
vector141:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $141
80107011:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107016:	e9 36 f4 ff ff       	jmp    80106451 <alltraps>

8010701b <vector142>:
.globl vector142
vector142:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $142
8010701d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107022:	e9 2a f4 ff ff       	jmp    80106451 <alltraps>

80107027 <vector143>:
.globl vector143
vector143:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $143
80107029:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010702e:	e9 1e f4 ff ff       	jmp    80106451 <alltraps>

80107033 <vector144>:
.globl vector144
vector144:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $144
80107035:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010703a:	e9 12 f4 ff ff       	jmp    80106451 <alltraps>

8010703f <vector145>:
.globl vector145
vector145:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $145
80107041:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107046:	e9 06 f4 ff ff       	jmp    80106451 <alltraps>

8010704b <vector146>:
.globl vector146
vector146:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $146
8010704d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107052:	e9 fa f3 ff ff       	jmp    80106451 <alltraps>

80107057 <vector147>:
.globl vector147
vector147:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $147
80107059:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010705e:	e9 ee f3 ff ff       	jmp    80106451 <alltraps>

80107063 <vector148>:
.globl vector148
vector148:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $148
80107065:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010706a:	e9 e2 f3 ff ff       	jmp    80106451 <alltraps>

8010706f <vector149>:
.globl vector149
vector149:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $149
80107071:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107076:	e9 d6 f3 ff ff       	jmp    80106451 <alltraps>

8010707b <vector150>:
.globl vector150
vector150:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $150
8010707d:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107082:	e9 ca f3 ff ff       	jmp    80106451 <alltraps>

80107087 <vector151>:
.globl vector151
vector151:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $151
80107089:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010708e:	e9 be f3 ff ff       	jmp    80106451 <alltraps>

80107093 <vector152>:
.globl vector152
vector152:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $152
80107095:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010709a:	e9 b2 f3 ff ff       	jmp    80106451 <alltraps>

8010709f <vector153>:
.globl vector153
vector153:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $153
801070a1:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801070a6:	e9 a6 f3 ff ff       	jmp    80106451 <alltraps>

801070ab <vector154>:
.globl vector154
vector154:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $154
801070ad:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801070b2:	e9 9a f3 ff ff       	jmp    80106451 <alltraps>

801070b7 <vector155>:
.globl vector155
vector155:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $155
801070b9:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801070be:	e9 8e f3 ff ff       	jmp    80106451 <alltraps>

801070c3 <vector156>:
.globl vector156
vector156:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $156
801070c5:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801070ca:	e9 82 f3 ff ff       	jmp    80106451 <alltraps>

801070cf <vector157>:
.globl vector157
vector157:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $157
801070d1:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801070d6:	e9 76 f3 ff ff       	jmp    80106451 <alltraps>

801070db <vector158>:
.globl vector158
vector158:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $158
801070dd:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801070e2:	e9 6a f3 ff ff       	jmp    80106451 <alltraps>

801070e7 <vector159>:
.globl vector159
vector159:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $159
801070e9:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801070ee:	e9 5e f3 ff ff       	jmp    80106451 <alltraps>

801070f3 <vector160>:
.globl vector160
vector160:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $160
801070f5:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801070fa:	e9 52 f3 ff ff       	jmp    80106451 <alltraps>

801070ff <vector161>:
.globl vector161
vector161:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $161
80107101:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107106:	e9 46 f3 ff ff       	jmp    80106451 <alltraps>

8010710b <vector162>:
.globl vector162
vector162:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $162
8010710d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107112:	e9 3a f3 ff ff       	jmp    80106451 <alltraps>

80107117 <vector163>:
.globl vector163
vector163:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $163
80107119:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010711e:	e9 2e f3 ff ff       	jmp    80106451 <alltraps>

80107123 <vector164>:
.globl vector164
vector164:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $164
80107125:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010712a:	e9 22 f3 ff ff       	jmp    80106451 <alltraps>

8010712f <vector165>:
.globl vector165
vector165:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $165
80107131:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107136:	e9 16 f3 ff ff       	jmp    80106451 <alltraps>

8010713b <vector166>:
.globl vector166
vector166:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $166
8010713d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107142:	e9 0a f3 ff ff       	jmp    80106451 <alltraps>

80107147 <vector167>:
.globl vector167
vector167:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $167
80107149:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010714e:	e9 fe f2 ff ff       	jmp    80106451 <alltraps>

80107153 <vector168>:
.globl vector168
vector168:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $168
80107155:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010715a:	e9 f2 f2 ff ff       	jmp    80106451 <alltraps>

8010715f <vector169>:
.globl vector169
vector169:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $169
80107161:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107166:	e9 e6 f2 ff ff       	jmp    80106451 <alltraps>

8010716b <vector170>:
.globl vector170
vector170:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $170
8010716d:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107172:	e9 da f2 ff ff       	jmp    80106451 <alltraps>

80107177 <vector171>:
.globl vector171
vector171:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $171
80107179:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010717e:	e9 ce f2 ff ff       	jmp    80106451 <alltraps>

80107183 <vector172>:
.globl vector172
vector172:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $172
80107185:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010718a:	e9 c2 f2 ff ff       	jmp    80106451 <alltraps>

8010718f <vector173>:
.globl vector173
vector173:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $173
80107191:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107196:	e9 b6 f2 ff ff       	jmp    80106451 <alltraps>

8010719b <vector174>:
.globl vector174
vector174:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $174
8010719d:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801071a2:	e9 aa f2 ff ff       	jmp    80106451 <alltraps>

801071a7 <vector175>:
.globl vector175
vector175:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $175
801071a9:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801071ae:	e9 9e f2 ff ff       	jmp    80106451 <alltraps>

801071b3 <vector176>:
.globl vector176
vector176:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $176
801071b5:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801071ba:	e9 92 f2 ff ff       	jmp    80106451 <alltraps>

801071bf <vector177>:
.globl vector177
vector177:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $177
801071c1:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801071c6:	e9 86 f2 ff ff       	jmp    80106451 <alltraps>

801071cb <vector178>:
.globl vector178
vector178:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $178
801071cd:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801071d2:	e9 7a f2 ff ff       	jmp    80106451 <alltraps>

801071d7 <vector179>:
.globl vector179
vector179:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $179
801071d9:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801071de:	e9 6e f2 ff ff       	jmp    80106451 <alltraps>

801071e3 <vector180>:
.globl vector180
vector180:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $180
801071e5:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801071ea:	e9 62 f2 ff ff       	jmp    80106451 <alltraps>

801071ef <vector181>:
.globl vector181
vector181:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $181
801071f1:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801071f6:	e9 56 f2 ff ff       	jmp    80106451 <alltraps>

801071fb <vector182>:
.globl vector182
vector182:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $182
801071fd:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107202:	e9 4a f2 ff ff       	jmp    80106451 <alltraps>

80107207 <vector183>:
.globl vector183
vector183:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $183
80107209:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010720e:	e9 3e f2 ff ff       	jmp    80106451 <alltraps>

80107213 <vector184>:
.globl vector184
vector184:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $184
80107215:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010721a:	e9 32 f2 ff ff       	jmp    80106451 <alltraps>

8010721f <vector185>:
.globl vector185
vector185:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $185
80107221:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107226:	e9 26 f2 ff ff       	jmp    80106451 <alltraps>

8010722b <vector186>:
.globl vector186
vector186:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $186
8010722d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107232:	e9 1a f2 ff ff       	jmp    80106451 <alltraps>

80107237 <vector187>:
.globl vector187
vector187:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $187
80107239:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010723e:	e9 0e f2 ff ff       	jmp    80106451 <alltraps>

80107243 <vector188>:
.globl vector188
vector188:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $188
80107245:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010724a:	e9 02 f2 ff ff       	jmp    80106451 <alltraps>

8010724f <vector189>:
.globl vector189
vector189:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $189
80107251:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107256:	e9 f6 f1 ff ff       	jmp    80106451 <alltraps>

8010725b <vector190>:
.globl vector190
vector190:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $190
8010725d:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107262:	e9 ea f1 ff ff       	jmp    80106451 <alltraps>

80107267 <vector191>:
.globl vector191
vector191:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $191
80107269:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010726e:	e9 de f1 ff ff       	jmp    80106451 <alltraps>

80107273 <vector192>:
.globl vector192
vector192:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $192
80107275:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010727a:	e9 d2 f1 ff ff       	jmp    80106451 <alltraps>

8010727f <vector193>:
.globl vector193
vector193:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $193
80107281:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107286:	e9 c6 f1 ff ff       	jmp    80106451 <alltraps>

8010728b <vector194>:
.globl vector194
vector194:
  pushl $0
8010728b:	6a 00                	push   $0x0
  pushl $194
8010728d:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107292:	e9 ba f1 ff ff       	jmp    80106451 <alltraps>

80107297 <vector195>:
.globl vector195
vector195:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $195
80107299:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010729e:	e9 ae f1 ff ff       	jmp    80106451 <alltraps>

801072a3 <vector196>:
.globl vector196
vector196:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $196
801072a5:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801072aa:	e9 a2 f1 ff ff       	jmp    80106451 <alltraps>

801072af <vector197>:
.globl vector197
vector197:
  pushl $0
801072af:	6a 00                	push   $0x0
  pushl $197
801072b1:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801072b6:	e9 96 f1 ff ff       	jmp    80106451 <alltraps>

801072bb <vector198>:
.globl vector198
vector198:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $198
801072bd:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801072c2:	e9 8a f1 ff ff       	jmp    80106451 <alltraps>

801072c7 <vector199>:
.globl vector199
vector199:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $199
801072c9:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801072ce:	e9 7e f1 ff ff       	jmp    80106451 <alltraps>

801072d3 <vector200>:
.globl vector200
vector200:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $200
801072d5:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801072da:	e9 72 f1 ff ff       	jmp    80106451 <alltraps>

801072df <vector201>:
.globl vector201
vector201:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $201
801072e1:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801072e6:	e9 66 f1 ff ff       	jmp    80106451 <alltraps>

801072eb <vector202>:
.globl vector202
vector202:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $202
801072ed:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801072f2:	e9 5a f1 ff ff       	jmp    80106451 <alltraps>

801072f7 <vector203>:
.globl vector203
vector203:
  pushl $0
801072f7:	6a 00                	push   $0x0
  pushl $203
801072f9:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801072fe:	e9 4e f1 ff ff       	jmp    80106451 <alltraps>

80107303 <vector204>:
.globl vector204
vector204:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $204
80107305:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010730a:	e9 42 f1 ff ff       	jmp    80106451 <alltraps>

8010730f <vector205>:
.globl vector205
vector205:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $205
80107311:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107316:	e9 36 f1 ff ff       	jmp    80106451 <alltraps>

8010731b <vector206>:
.globl vector206
vector206:
  pushl $0
8010731b:	6a 00                	push   $0x0
  pushl $206
8010731d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107322:	e9 2a f1 ff ff       	jmp    80106451 <alltraps>

80107327 <vector207>:
.globl vector207
vector207:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $207
80107329:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010732e:	e9 1e f1 ff ff       	jmp    80106451 <alltraps>

80107333 <vector208>:
.globl vector208
vector208:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $208
80107335:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010733a:	e9 12 f1 ff ff       	jmp    80106451 <alltraps>

8010733f <vector209>:
.globl vector209
vector209:
  pushl $0
8010733f:	6a 00                	push   $0x0
  pushl $209
80107341:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107346:	e9 06 f1 ff ff       	jmp    80106451 <alltraps>

8010734b <vector210>:
.globl vector210
vector210:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $210
8010734d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107352:	e9 fa f0 ff ff       	jmp    80106451 <alltraps>

80107357 <vector211>:
.globl vector211
vector211:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $211
80107359:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010735e:	e9 ee f0 ff ff       	jmp    80106451 <alltraps>

80107363 <vector212>:
.globl vector212
vector212:
  pushl $0
80107363:	6a 00                	push   $0x0
  pushl $212
80107365:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010736a:	e9 e2 f0 ff ff       	jmp    80106451 <alltraps>

8010736f <vector213>:
.globl vector213
vector213:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $213
80107371:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107376:	e9 d6 f0 ff ff       	jmp    80106451 <alltraps>

8010737b <vector214>:
.globl vector214
vector214:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $214
8010737d:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107382:	e9 ca f0 ff ff       	jmp    80106451 <alltraps>

80107387 <vector215>:
.globl vector215
vector215:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $215
80107389:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010738e:	e9 be f0 ff ff       	jmp    80106451 <alltraps>

80107393 <vector216>:
.globl vector216
vector216:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $216
80107395:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010739a:	e9 b2 f0 ff ff       	jmp    80106451 <alltraps>

8010739f <vector217>:
.globl vector217
vector217:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $217
801073a1:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801073a6:	e9 a6 f0 ff ff       	jmp    80106451 <alltraps>

801073ab <vector218>:
.globl vector218
vector218:
  pushl $0
801073ab:	6a 00                	push   $0x0
  pushl $218
801073ad:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801073b2:	e9 9a f0 ff ff       	jmp    80106451 <alltraps>

801073b7 <vector219>:
.globl vector219
vector219:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $219
801073b9:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801073be:	e9 8e f0 ff ff       	jmp    80106451 <alltraps>

801073c3 <vector220>:
.globl vector220
vector220:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $220
801073c5:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801073ca:	e9 82 f0 ff ff       	jmp    80106451 <alltraps>

801073cf <vector221>:
.globl vector221
vector221:
  pushl $0
801073cf:	6a 00                	push   $0x0
  pushl $221
801073d1:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801073d6:	e9 76 f0 ff ff       	jmp    80106451 <alltraps>

801073db <vector222>:
.globl vector222
vector222:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $222
801073dd:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801073e2:	e9 6a f0 ff ff       	jmp    80106451 <alltraps>

801073e7 <vector223>:
.globl vector223
vector223:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $223
801073e9:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801073ee:	e9 5e f0 ff ff       	jmp    80106451 <alltraps>

801073f3 <vector224>:
.globl vector224
vector224:
  pushl $0
801073f3:	6a 00                	push   $0x0
  pushl $224
801073f5:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801073fa:	e9 52 f0 ff ff       	jmp    80106451 <alltraps>

801073ff <vector225>:
.globl vector225
vector225:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $225
80107401:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107406:	e9 46 f0 ff ff       	jmp    80106451 <alltraps>

8010740b <vector226>:
.globl vector226
vector226:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $226
8010740d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107412:	e9 3a f0 ff ff       	jmp    80106451 <alltraps>

80107417 <vector227>:
.globl vector227
vector227:
  pushl $0
80107417:	6a 00                	push   $0x0
  pushl $227
80107419:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010741e:	e9 2e f0 ff ff       	jmp    80106451 <alltraps>

80107423 <vector228>:
.globl vector228
vector228:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $228
80107425:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010742a:	e9 22 f0 ff ff       	jmp    80106451 <alltraps>

8010742f <vector229>:
.globl vector229
vector229:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $229
80107431:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107436:	e9 16 f0 ff ff       	jmp    80106451 <alltraps>

8010743b <vector230>:
.globl vector230
vector230:
  pushl $0
8010743b:	6a 00                	push   $0x0
  pushl $230
8010743d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107442:	e9 0a f0 ff ff       	jmp    80106451 <alltraps>

80107447 <vector231>:
.globl vector231
vector231:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $231
80107449:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010744e:	e9 fe ef ff ff       	jmp    80106451 <alltraps>

80107453 <vector232>:
.globl vector232
vector232:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $232
80107455:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010745a:	e9 f2 ef ff ff       	jmp    80106451 <alltraps>

8010745f <vector233>:
.globl vector233
vector233:
  pushl $0
8010745f:	6a 00                	push   $0x0
  pushl $233
80107461:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107466:	e9 e6 ef ff ff       	jmp    80106451 <alltraps>

8010746b <vector234>:
.globl vector234
vector234:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $234
8010746d:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107472:	e9 da ef ff ff       	jmp    80106451 <alltraps>

80107477 <vector235>:
.globl vector235
vector235:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $235
80107479:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010747e:	e9 ce ef ff ff       	jmp    80106451 <alltraps>

80107483 <vector236>:
.globl vector236
vector236:
  pushl $0
80107483:	6a 00                	push   $0x0
  pushl $236
80107485:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010748a:	e9 c2 ef ff ff       	jmp    80106451 <alltraps>

8010748f <vector237>:
.globl vector237
vector237:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $237
80107491:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107496:	e9 b6 ef ff ff       	jmp    80106451 <alltraps>

8010749b <vector238>:
.globl vector238
vector238:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $238
8010749d:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801074a2:	e9 aa ef ff ff       	jmp    80106451 <alltraps>

801074a7 <vector239>:
.globl vector239
vector239:
  pushl $0
801074a7:	6a 00                	push   $0x0
  pushl $239
801074a9:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801074ae:	e9 9e ef ff ff       	jmp    80106451 <alltraps>

801074b3 <vector240>:
.globl vector240
vector240:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $240
801074b5:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801074ba:	e9 92 ef ff ff       	jmp    80106451 <alltraps>

801074bf <vector241>:
.globl vector241
vector241:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $241
801074c1:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801074c6:	e9 86 ef ff ff       	jmp    80106451 <alltraps>

801074cb <vector242>:
.globl vector242
vector242:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $242
801074cd:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801074d2:	e9 7a ef ff ff       	jmp    80106451 <alltraps>

801074d7 <vector243>:
.globl vector243
vector243:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $243
801074d9:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801074de:	e9 6e ef ff ff       	jmp    80106451 <alltraps>

801074e3 <vector244>:
.globl vector244
vector244:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $244
801074e5:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801074ea:	e9 62 ef ff ff       	jmp    80106451 <alltraps>

801074ef <vector245>:
.globl vector245
vector245:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $245
801074f1:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801074f6:	e9 56 ef ff ff       	jmp    80106451 <alltraps>

801074fb <vector246>:
.globl vector246
vector246:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $246
801074fd:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107502:	e9 4a ef ff ff       	jmp    80106451 <alltraps>

80107507 <vector247>:
.globl vector247
vector247:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $247
80107509:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010750e:	e9 3e ef ff ff       	jmp    80106451 <alltraps>

80107513 <vector248>:
.globl vector248
vector248:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $248
80107515:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010751a:	e9 32 ef ff ff       	jmp    80106451 <alltraps>

8010751f <vector249>:
.globl vector249
vector249:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $249
80107521:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107526:	e9 26 ef ff ff       	jmp    80106451 <alltraps>

8010752b <vector250>:
.globl vector250
vector250:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $250
8010752d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107532:	e9 1a ef ff ff       	jmp    80106451 <alltraps>

80107537 <vector251>:
.globl vector251
vector251:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $251
80107539:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010753e:	e9 0e ef ff ff       	jmp    80106451 <alltraps>

80107543 <vector252>:
.globl vector252
vector252:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $252
80107545:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010754a:	e9 02 ef ff ff       	jmp    80106451 <alltraps>

8010754f <vector253>:
.globl vector253
vector253:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $253
80107551:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107556:	e9 f6 ee ff ff       	jmp    80106451 <alltraps>

8010755b <vector254>:
.globl vector254
vector254:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $254
8010755d:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107562:	e9 ea ee ff ff       	jmp    80106451 <alltraps>

80107567 <vector255>:
.globl vector255
vector255:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $255
80107569:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010756e:	e9 de ee ff ff       	jmp    80106451 <alltraps>

80107573 <lgdt>:
{
80107573:	55                   	push   %ebp
80107574:	89 e5                	mov    %esp,%ebp
80107576:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107579:	8b 45 0c             	mov    0xc(%ebp),%eax
8010757c:	83 e8 01             	sub    $0x1,%eax
8010757f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107583:	8b 45 08             	mov    0x8(%ebp),%eax
80107586:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010758a:	8b 45 08             	mov    0x8(%ebp),%eax
8010758d:	c1 e8 10             	shr    $0x10,%eax
80107590:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107594:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107597:	0f 01 10             	lgdtl  (%eax)
}
8010759a:	90                   	nop
8010759b:	c9                   	leave  
8010759c:	c3                   	ret    

8010759d <ltr>:
{
8010759d:	55                   	push   %ebp
8010759e:	89 e5                	mov    %esp,%ebp
801075a0:	83 ec 04             	sub    $0x4,%esp
801075a3:	8b 45 08             	mov    0x8(%ebp),%eax
801075a6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801075aa:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801075ae:	0f 00 d8             	ltr    %ax
}
801075b1:	90                   	nop
801075b2:	c9                   	leave  
801075b3:	c3                   	ret    

801075b4 <lcr3>:

static inline void
lcr3(uint val)
{
801075b4:	55                   	push   %ebp
801075b5:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801075b7:	8b 45 08             	mov    0x8(%ebp),%eax
801075ba:	0f 22 d8             	mov    %eax,%cr3
}
801075bd:	90                   	nop
801075be:	5d                   	pop    %ebp
801075bf:	c3                   	ret    

801075c0 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801075c0:	f3 0f 1e fb          	endbr32 
801075c4:	55                   	push   %ebp
801075c5:	89 e5                	mov    %esp,%ebp
801075c7:	83 ec 18             	sub    $0x18,%esp

    // Map "logical" addresses to virtual addresses using identity map.
    // Cannot share a CODE descriptor for both kernel and user
    // because it would have to have DPL_USR, but the CPU forbids
    // an interrupt from CPL=0 to DPL=3.
    c = &cpus[cpuid()];
801075ca:	e8 31 c5 ff ff       	call   80103b00 <cpuid>
801075cf:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801075d5:	05 c0 81 19 80       	add    $0x801981c0,%eax
801075da:	89 45 f4             	mov    %eax,-0xc(%ebp)

    c->gdt[SEG_KCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, 0);
801075dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e0:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801075e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e9:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801075ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f2:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801075f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801075fd:	83 e2 f0             	and    $0xfffffff0,%edx
80107600:	83 ca 0a             	or     $0xa,%edx
80107603:	88 50 7d             	mov    %dl,0x7d(%eax)
80107606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107609:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010760d:	83 ca 10             	or     $0x10,%edx
80107610:	88 50 7d             	mov    %dl,0x7d(%eax)
80107613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107616:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010761a:	83 e2 9f             	and    $0xffffff9f,%edx
8010761d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107623:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107627:	83 ca 80             	or     $0xffffff80,%edx
8010762a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010762d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107630:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107634:	83 ca 0f             	or     $0xf,%edx
80107637:	88 50 7e             	mov    %dl,0x7e(%eax)
8010763a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010763d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107641:	83 e2 ef             	and    $0xffffffef,%edx
80107644:	88 50 7e             	mov    %dl,0x7e(%eax)
80107647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010764a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010764e:	83 e2 df             	and    $0xffffffdf,%edx
80107651:	88 50 7e             	mov    %dl,0x7e(%eax)
80107654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107657:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010765b:	83 ca 40             	or     $0x40,%edx
8010765e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107664:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107668:	83 ca 80             	or     $0xffffff80,%edx
8010766b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010766e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107671:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
    c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107678:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010767f:	ff ff 
80107681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107684:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010768b:	00 00 
8010768d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107690:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010769a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076a1:	83 e2 f0             	and    $0xfffffff0,%edx
801076a4:	83 ca 02             	or     $0x2,%edx
801076a7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076b7:	83 ca 10             	or     $0x10,%edx
801076ba:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076ca:	83 e2 9f             	and    $0xffffff9f,%edx
801076cd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801076dd:	83 ca 80             	or     $0xffffff80,%edx
801076e0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801076e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801076f0:	83 ca 0f             	or     $0xf,%edx
801076f3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801076f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107703:	83 e2 ef             	and    $0xffffffef,%edx
80107706:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010770c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010770f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107716:	83 e2 df             	and    $0xffffffdf,%edx
80107719:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010771f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107722:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107729:	83 ca 40             	or     $0x40,%edx
8010772c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107735:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010773c:	83 ca 80             	or     $0xffffff80,%edx
8010773f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107748:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
    c->gdt[SEG_UCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, DPL_USER);
8010774f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107752:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107759:	ff ff 
8010775b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775e:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107765:	00 00 
80107767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776a:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107771:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107774:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010777b:	83 e2 f0             	and    $0xfffffff0,%edx
8010777e:	83 ca 0a             	or     $0xa,%edx
80107781:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010778a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107791:	83 ca 10             	or     $0x10,%edx
80107794:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010779a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010779d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077a4:	83 ca 60             	or     $0x60,%edx
801077a7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801077b7:	83 ca 80             	or     $0xffffff80,%edx
801077ba:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801077c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077ca:	83 ca 0f             	or     $0xf,%edx
801077cd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077dd:	83 e2 ef             	and    $0xffffffef,%edx
801077e0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801077f0:	83 e2 df             	and    $0xffffffdf,%edx
801077f3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801077f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077fc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107803:	83 ca 40             	or     $0x40,%edx
80107806:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010780c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107816:	83 ca 80             	or     $0xffffff80,%edx
80107819:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010781f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107822:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
    c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107833:	ff ff 
80107835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107838:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010783f:	00 00 
80107841:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107844:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010784b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107855:	83 e2 f0             	and    $0xfffffff0,%edx
80107858:	83 ca 02             	or     $0x2,%edx
8010785b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107864:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010786b:	83 ca 10             	or     $0x10,%edx
8010786e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107874:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107877:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010787e:	83 ca 60             	or     $0x60,%edx
80107881:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010788a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107891:	83 ca 80             	or     $0xffffff80,%edx
80107894:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010789a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010789d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078a4:	83 ca 0f             	or     $0xf,%edx
801078a7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078b7:	83 e2 ef             	and    $0xffffffef,%edx
801078ba:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078c3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078ca:	83 e2 df             	and    $0xffffffdf,%edx
801078cd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078dd:	83 ca 40             	or     $0x40,%edx
801078e0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078f0:	83 ca 80             	or     $0xffffff80,%edx
801078f3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fc:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
    lgdt(c->gdt, sizeof(c->gdt));
80107903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107906:	83 c0 70             	add    $0x70,%eax
80107909:	83 ec 08             	sub    $0x8,%esp
8010790c:	6a 30                	push   $0x30
8010790e:	50                   	push   %eax
8010790f:	e8 5f fc ff ff       	call   80107573 <lgdt>
80107914:	83 c4 10             	add    $0x10,%esp
}
80107917:	90                   	nop
80107918:	c9                   	leave  
80107919:	c3                   	ret    

8010791a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t*
walkpgdir(pde_t* pgdir, const void* va, int alloc)
{
8010791a:	f3 0f 1e fb          	endbr32 
8010791e:	55                   	push   %ebp
8010791f:	89 e5                	mov    %esp,%ebp
80107921:	83 ec 18             	sub    $0x18,%esp
    pde_t* pde;
    pte_t* pgtab;

    pde = &pgdir[PDX(va)];
80107924:	8b 45 0c             	mov    0xc(%ebp),%eax
80107927:	c1 e8 16             	shr    $0x16,%eax
8010792a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107931:	8b 45 08             	mov    0x8(%ebp),%eax
80107934:	01 d0                	add    %edx,%eax
80107936:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (*pde & PTE_P) {
80107939:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010793c:	8b 00                	mov    (%eax),%eax
8010793e:	83 e0 01             	and    $0x1,%eax
80107941:	85 c0                	test   %eax,%eax
80107943:	74 14                	je     80107959 <walkpgdir+0x3f>
        pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107945:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107948:	8b 00                	mov    (%eax),%eax
8010794a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010794f:	05 00 00 00 80       	add    $0x80000000,%eax
80107954:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107957:	eb 42                	jmp    8010799b <walkpgdir+0x81>
    }
    else {
        if (!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107959:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010795d:	74 0e                	je     8010796d <walkpgdir+0x53>
8010795f:	e8 20 af ff ff       	call   80102884 <kalloc>
80107964:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107967:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010796b:	75 07                	jne    80107974 <walkpgdir+0x5a>
            return 0;
8010796d:	b8 00 00 00 00       	mov    $0x0,%eax
80107972:	eb 3e                	jmp    801079b2 <walkpgdir+0x98>
        // Make sure all those PTE_P bits are zero.
        memset(pgtab, 0, PGSIZE);
80107974:	83 ec 04             	sub    $0x4,%esp
80107977:	68 00 10 00 00       	push   $0x1000
8010797c:	6a 00                	push   $0x0
8010797e:	ff 75 f4             	pushl  -0xc(%ebp)
80107981:	e8 f7 d5 ff ff       	call   80104f7d <memset>
80107986:	83 c4 10             	add    $0x10,%esp
        // The permissions here are overly generous, but they can
        // be further restricted by the permissions in the page table
        // entries, if necessary.
        *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798c:	05 00 00 00 80       	add    $0x80000000,%eax
80107991:	83 c8 07             	or     $0x7,%eax
80107994:	89 c2                	mov    %eax,%edx
80107996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107999:	89 10                	mov    %edx,(%eax)
    }
    return &pgtab[PTX(va)];
8010799b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010799e:	c1 e8 0c             	shr    $0xc,%eax
801079a1:	25 ff 03 00 00       	and    $0x3ff,%eax
801079a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801079ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b0:	01 d0                	add    %edx,%eax
}
801079b2:	c9                   	leave  
801079b3:	c3                   	ret    

801079b4 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t* pgdir, void* va, uint size, uint pa, int perm)
{
801079b4:	f3 0f 1e fb          	endbr32 
801079b8:	55                   	push   %ebp
801079b9:	89 e5                	mov    %esp,%ebp
801079bb:	83 ec 18             	sub    $0x18,%esp
    char* a, * last;
    pte_t* pte;

    a = (char*)PGROUNDDOWN((uint)va);
801079be:	8b 45 0c             	mov    0xc(%ebp),%eax
801079c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801079c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801079cc:	8b 45 10             	mov    0x10(%ebp),%eax
801079cf:	01 d0                	add    %edx,%eax
801079d1:	83 e8 01             	sub    $0x1,%eax
801079d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (;;) {
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
801079dc:	83 ec 04             	sub    $0x4,%esp
801079df:	6a 01                	push   $0x1
801079e1:	ff 75 f4             	pushl  -0xc(%ebp)
801079e4:	ff 75 08             	pushl  0x8(%ebp)
801079e7:	e8 2e ff ff ff       	call   8010791a <walkpgdir>
801079ec:	83 c4 10             	add    $0x10,%esp
801079ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079f2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079f6:	75 07                	jne    801079ff <mappages+0x4b>
            return -1;
801079f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079fd:	eb 47                	jmp    80107a46 <mappages+0x92>
        if (*pte & PTE_P)
801079ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a02:	8b 00                	mov    (%eax),%eax
80107a04:	83 e0 01             	and    $0x1,%eax
80107a07:	85 c0                	test   %eax,%eax
80107a09:	74 0d                	je     80107a18 <mappages+0x64>
            panic("remap");
80107a0b:	83 ec 0c             	sub    $0xc,%esp
80107a0e:	68 b8 af 10 80       	push   $0x8010afb8
80107a13:	e8 ad 8b ff ff       	call   801005c5 <panic>
        *pte = pa | perm | PTE_P;
80107a18:	8b 45 18             	mov    0x18(%ebp),%eax
80107a1b:	0b 45 14             	or     0x14(%ebp),%eax
80107a1e:	83 c8 01             	or     $0x1,%eax
80107a21:	89 c2                	mov    %eax,%edx
80107a23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a26:	89 10                	mov    %edx,(%eax)
        if (a == last)
80107a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107a2e:	74 10                	je     80107a40 <mappages+0x8c>
            break;
        a += PGSIZE;
80107a30:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
        pa += PGSIZE;
80107a37:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80107a3e:	eb 9c                	jmp    801079dc <mappages+0x28>
            break;
80107a40:	90                   	nop
    }
    return 0;
80107a41:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a46:	c9                   	leave  
80107a47:	c3                   	ret    

80107a48 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107a48:	f3 0f 1e fb          	endbr32 
80107a4c:	55                   	push   %ebp
80107a4d:	89 e5                	mov    %esp,%ebp
80107a4f:	53                   	push   %ebx
80107a50:	83 ec 24             	sub    $0x24,%esp
    pde_t* pgdir;
    struct kmap* k;
    k = kmap;
80107a53:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
    struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr + gpu.vram_size, PTE_W };
80107a5a:	a1 8c 84 19 80       	mov    0x8019848c,%eax
80107a5f:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107a64:	29 c2                	sub    %eax,%edx
80107a66:	89 d0                	mov    %edx,%eax
80107a68:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a6b:	a1 84 84 19 80       	mov    0x80198484,%eax
80107a70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107a73:	8b 15 84 84 19 80    	mov    0x80198484,%edx
80107a79:	a1 8c 84 19 80       	mov    0x8019848c,%eax
80107a7e:	01 d0                	add    %edx,%eax
80107a80:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107a83:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
    k[3] = vram;
80107a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8d:	83 c0 30             	add    $0x30,%eax
80107a90:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107a93:	89 10                	mov    %edx,(%eax)
80107a95:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a98:	89 50 04             	mov    %edx,0x4(%eax)
80107a9b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107a9e:	89 50 08             	mov    %edx,0x8(%eax)
80107aa1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107aa4:	89 50 0c             	mov    %edx,0xc(%eax)
    if ((pgdir = (pde_t*)kalloc()) == 0) {
80107aa7:	e8 d8 ad ff ff       	call   80102884 <kalloc>
80107aac:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107aaf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ab3:	75 07                	jne    80107abc <setupkvm+0x74>
        return 0;
80107ab5:	b8 00 00 00 00       	mov    $0x0,%eax
80107aba:	eb 78                	jmp    80107b34 <setupkvm+0xec>
    }
    memset(pgdir, 0, PGSIZE);
80107abc:	83 ec 04             	sub    $0x4,%esp
80107abf:	68 00 10 00 00       	push   $0x1000
80107ac4:	6a 00                	push   $0x0
80107ac6:	ff 75 f0             	pushl  -0x10(%ebp)
80107ac9:	e8 af d4 ff ff       	call   80104f7d <memset>
80107ace:	83 c4 10             	add    $0x10,%esp
    if (P2V(PHYSTOP) > (void*)DEVSPACE)
        panic("PHYSTOP too high");
    for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ad1:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107ad8:	eb 4e                	jmp    80107b28 <setupkvm+0xe0>
        if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107add:	8b 48 0c             	mov    0xc(%eax),%ecx
            (uint)k->phys_start, k->perm) < 0) {
80107ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae3:	8b 50 04             	mov    0x4(%eax),%edx
        if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae9:	8b 58 08             	mov    0x8(%eax),%ebx
80107aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aef:	8b 40 04             	mov    0x4(%eax),%eax
80107af2:	29 c3                	sub    %eax,%ebx
80107af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af7:	8b 00                	mov    (%eax),%eax
80107af9:	83 ec 0c             	sub    $0xc,%esp
80107afc:	51                   	push   %ecx
80107afd:	52                   	push   %edx
80107afe:	53                   	push   %ebx
80107aff:	50                   	push   %eax
80107b00:	ff 75 f0             	pushl  -0x10(%ebp)
80107b03:	e8 ac fe ff ff       	call   801079b4 <mappages>
80107b08:	83 c4 20             	add    $0x20,%esp
80107b0b:	85 c0                	test   %eax,%eax
80107b0d:	79 15                	jns    80107b24 <setupkvm+0xdc>
            freevm(pgdir);
80107b0f:	83 ec 0c             	sub    $0xc,%esp
80107b12:	ff 75 f0             	pushl  -0x10(%ebp)
80107b15:	e8 11 05 00 00       	call   8010802b <freevm>
80107b1a:	83 c4 10             	add    $0x10,%esp
            return 0;
80107b1d:	b8 00 00 00 00       	mov    $0x0,%eax
80107b22:	eb 10                	jmp    80107b34 <setupkvm+0xec>
    for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107b24:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107b28:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107b2f:	72 a9                	jb     80107ada <setupkvm+0x92>
        }
    return pgdir;
80107b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107b37:	c9                   	leave  
80107b38:	c3                   	ret    

80107b39 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107b39:	f3 0f 1e fb          	endbr32 
80107b3d:	55                   	push   %ebp
80107b3e:	89 e5                	mov    %esp,%ebp
80107b40:	83 ec 08             	sub    $0x8,%esp
    kpgdir = setupkvm();
80107b43:	e8 00 ff ff ff       	call   80107a48 <setupkvm>
80107b48:	a3 84 81 19 80       	mov    %eax,0x80198184
    switchkvm();
80107b4d:	e8 03 00 00 00       	call   80107b55 <switchkvm>
}
80107b52:	90                   	nop
80107b53:	c9                   	leave  
80107b54:	c3                   	ret    

80107b55 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107b55:	f3 0f 1e fb          	endbr32 
80107b59:	55                   	push   %ebp
80107b5a:	89 e5                	mov    %esp,%ebp
    lcr3(V2P(kpgdir));   // switch to the kernel page table
80107b5c:	a1 84 81 19 80       	mov    0x80198184,%eax
80107b61:	05 00 00 00 80       	add    $0x80000000,%eax
80107b66:	50                   	push   %eax
80107b67:	e8 48 fa ff ff       	call   801075b4 <lcr3>
80107b6c:	83 c4 04             	add    $0x4,%esp
}
80107b6f:	90                   	nop
80107b70:	c9                   	leave  
80107b71:	c3                   	ret    

80107b72 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc* p)
{
80107b72:	f3 0f 1e fb          	endbr32 
80107b76:	55                   	push   %ebp
80107b77:	89 e5                	mov    %esp,%ebp
80107b79:	56                   	push   %esi
80107b7a:	53                   	push   %ebx
80107b7b:	83 ec 10             	sub    $0x10,%esp
    if (p == 0)
80107b7e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107b82:	75 0d                	jne    80107b91 <switchuvm+0x1f>
        panic("switchuvm: no process");
80107b84:	83 ec 0c             	sub    $0xc,%esp
80107b87:	68 be af 10 80       	push   $0x8010afbe
80107b8c:	e8 34 8a ff ff       	call   801005c5 <panic>
    if (p->kstack == 0)
80107b91:	8b 45 08             	mov    0x8(%ebp),%eax
80107b94:	8b 40 08             	mov    0x8(%eax),%eax
80107b97:	85 c0                	test   %eax,%eax
80107b99:	75 0d                	jne    80107ba8 <switchuvm+0x36>
        panic("switchuvm: no kstack");
80107b9b:	83 ec 0c             	sub    $0xc,%esp
80107b9e:	68 d4 af 10 80       	push   $0x8010afd4
80107ba3:	e8 1d 8a ff ff       	call   801005c5 <panic>
    if (p->pgdir == 0)
80107ba8:	8b 45 08             	mov    0x8(%ebp),%eax
80107bab:	8b 40 04             	mov    0x4(%eax),%eax
80107bae:	85 c0                	test   %eax,%eax
80107bb0:	75 0d                	jne    80107bbf <switchuvm+0x4d>
        panic("switchuvm: no pgdir");
80107bb2:	83 ec 0c             	sub    $0xc,%esp
80107bb5:	68 e9 af 10 80       	push   $0x8010afe9
80107bba:	e8 06 8a ff ff       	call   801005c5 <panic>

    pushcli();
80107bbf:	e8 a6 d2 ff ff       	call   80104e6a <pushcli>
    mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107bc4:	e8 56 bf ff ff       	call   80103b1f <mycpu>
80107bc9:	89 c3                	mov    %eax,%ebx
80107bcb:	e8 4f bf ff ff       	call   80103b1f <mycpu>
80107bd0:	83 c0 08             	add    $0x8,%eax
80107bd3:	89 c6                	mov    %eax,%esi
80107bd5:	e8 45 bf ff ff       	call   80103b1f <mycpu>
80107bda:	83 c0 08             	add    $0x8,%eax
80107bdd:	c1 e8 10             	shr    $0x10,%eax
80107be0:	88 45 f7             	mov    %al,-0x9(%ebp)
80107be3:	e8 37 bf ff ff       	call   80103b1f <mycpu>
80107be8:	83 c0 08             	add    $0x8,%eax
80107beb:	c1 e8 18             	shr    $0x18,%eax
80107bee:	89 c2                	mov    %eax,%edx
80107bf0:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107bf7:	67 00 
80107bf9:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107c00:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107c04:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107c0a:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c11:	83 e0 f0             	and    $0xfffffff0,%eax
80107c14:	83 c8 09             	or     $0x9,%eax
80107c17:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c1d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c24:	83 c8 10             	or     $0x10,%eax
80107c27:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c2d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c34:	83 e0 9f             	and    $0xffffff9f,%eax
80107c37:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c3d:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107c44:	83 c8 80             	or     $0xffffff80,%eax
80107c47:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107c4d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c54:	83 e0 f0             	and    $0xfffffff0,%eax
80107c57:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c5d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c64:	83 e0 ef             	and    $0xffffffef,%eax
80107c67:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c6d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c74:	83 e0 df             	and    $0xffffffdf,%eax
80107c77:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c7d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c84:	83 c8 40             	or     $0x40,%eax
80107c87:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c8d:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107c94:	83 e0 7f             	and    $0x7f,%eax
80107c97:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107c9d:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
        sizeof(mycpu()->ts) - 1, 0);
    mycpu()->gdt[SEG_TSS].s = 0;
80107ca3:	e8 77 be ff ff       	call   80103b1f <mycpu>
80107ca8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107caf:	83 e2 ef             	and    $0xffffffef,%edx
80107cb2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
    mycpu()->ts.ss0 = SEG_KDATA << 3;
80107cb8:	e8 62 be ff ff       	call   80103b1f <mycpu>
80107cbd:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
    mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80107cc6:	8b 40 08             	mov    0x8(%eax),%eax
80107cc9:	89 c3                	mov    %eax,%ebx
80107ccb:	e8 4f be ff ff       	call   80103b1f <mycpu>
80107cd0:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107cd6:	89 50 0c             	mov    %edx,0xc(%eax)
    // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
    // forbids I/O instructions (e.g., inb and outb) from user space
    mycpu()->ts.iomb = (ushort)0xFFFF;
80107cd9:	e8 41 be ff ff       	call   80103b1f <mycpu>
80107cde:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
    ltr(SEG_TSS << 3);
80107ce4:	83 ec 0c             	sub    $0xc,%esp
80107ce7:	6a 28                	push   $0x28
80107ce9:	e8 af f8 ff ff       	call   8010759d <ltr>
80107cee:	83 c4 10             	add    $0x10,%esp
    lcr3(V2P(p->pgdir));  // switch to process's address space
80107cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80107cf4:	8b 40 04             	mov    0x4(%eax),%eax
80107cf7:	05 00 00 00 80       	add    $0x80000000,%eax
80107cfc:	83 ec 0c             	sub    $0xc,%esp
80107cff:	50                   	push   %eax
80107d00:	e8 af f8 ff ff       	call   801075b4 <lcr3>
80107d05:	83 c4 10             	add    $0x10,%esp
    popcli();
80107d08:	e8 ae d1 ff ff       	call   80104ebb <popcli>
}
80107d0d:	90                   	nop
80107d0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107d11:	5b                   	pop    %ebx
80107d12:	5e                   	pop    %esi
80107d13:	5d                   	pop    %ebp
80107d14:	c3                   	ret    

80107d15 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t* pgdir, char* init, uint sz)
{
80107d15:	f3 0f 1e fb          	endbr32 
80107d19:	55                   	push   %ebp
80107d1a:	89 e5                	mov    %esp,%ebp
80107d1c:	83 ec 18             	sub    $0x18,%esp
    char* mem;

    if (sz >= PGSIZE)
80107d1f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107d26:	76 0d                	jbe    80107d35 <inituvm+0x20>
        panic("inituvm: more than a page");
80107d28:	83 ec 0c             	sub    $0xc,%esp
80107d2b:	68 fd af 10 80       	push   $0x8010affd
80107d30:	e8 90 88 ff ff       	call   801005c5 <panic>
    mem = kalloc();
80107d35:	e8 4a ab ff ff       	call   80102884 <kalloc>
80107d3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memset(mem, 0, PGSIZE);
80107d3d:	83 ec 04             	sub    $0x4,%esp
80107d40:	68 00 10 00 00       	push   $0x1000
80107d45:	6a 00                	push   $0x0
80107d47:	ff 75 f4             	pushl  -0xc(%ebp)
80107d4a:	e8 2e d2 ff ff       	call   80104f7d <memset>
80107d4f:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W | PTE_U);
80107d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d55:	05 00 00 00 80       	add    $0x80000000,%eax
80107d5a:	83 ec 0c             	sub    $0xc,%esp
80107d5d:	6a 06                	push   $0x6
80107d5f:	50                   	push   %eax
80107d60:	68 00 10 00 00       	push   $0x1000
80107d65:	6a 00                	push   $0x0
80107d67:	ff 75 08             	pushl  0x8(%ebp)
80107d6a:	e8 45 fc ff ff       	call   801079b4 <mappages>
80107d6f:	83 c4 20             	add    $0x20,%esp
    memmove(mem, init, sz);
80107d72:	83 ec 04             	sub    $0x4,%esp
80107d75:	ff 75 10             	pushl  0x10(%ebp)
80107d78:	ff 75 0c             	pushl  0xc(%ebp)
80107d7b:	ff 75 f4             	pushl  -0xc(%ebp)
80107d7e:	e8 c1 d2 ff ff       	call   80105044 <memmove>
80107d83:	83 c4 10             	add    $0x10,%esp
}
80107d86:	90                   	nop
80107d87:	c9                   	leave  
80107d88:	c3                   	ret    

80107d89 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t* pgdir, char* addr, struct inode* ip, uint offset, uint sz)
{
80107d89:	f3 0f 1e fb          	endbr32 
80107d8d:	55                   	push   %ebp
80107d8e:	89 e5                	mov    %esp,%ebp
80107d90:	83 ec 18             	sub    $0x18,%esp
    uint i, pa, n;
    pte_t* pte;

    if ((uint)addr % PGSIZE != 0)
80107d93:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d96:	25 ff 0f 00 00       	and    $0xfff,%eax
80107d9b:	85 c0                	test   %eax,%eax
80107d9d:	74 0d                	je     80107dac <loaduvm+0x23>
        panic("loaduvm: addr must be page aligned");
80107d9f:	83 ec 0c             	sub    $0xc,%esp
80107da2:	68 18 b0 10 80       	push   $0x8010b018
80107da7:	e8 19 88 ff ff       	call   801005c5 <panic>
    for (i = 0; i < sz; i += PGSIZE) {
80107dac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107db3:	e9 8f 00 00 00       	jmp    80107e47 <loaduvm+0xbe>
        if ((pte = walkpgdir(pgdir, addr + i, 0)) == 0)
80107db8:	8b 55 0c             	mov    0xc(%ebp),%edx
80107dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbe:	01 d0                	add    %edx,%eax
80107dc0:	83 ec 04             	sub    $0x4,%esp
80107dc3:	6a 00                	push   $0x0
80107dc5:	50                   	push   %eax
80107dc6:	ff 75 08             	pushl  0x8(%ebp)
80107dc9:	e8 4c fb ff ff       	call   8010791a <walkpgdir>
80107dce:	83 c4 10             	add    $0x10,%esp
80107dd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107dd4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107dd8:	75 0d                	jne    80107de7 <loaduvm+0x5e>
            panic("loaduvm: address should exist");
80107dda:	83 ec 0c             	sub    $0xc,%esp
80107ddd:	68 3b b0 10 80       	push   $0x8010b03b
80107de2:	e8 de 87 ff ff       	call   801005c5 <panic>
        pa = PTE_ADDR(*pte);
80107de7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107dea:	8b 00                	mov    (%eax),%eax
80107dec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107df1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (sz - i < PGSIZE)
80107df4:	8b 45 18             	mov    0x18(%ebp),%eax
80107df7:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107dfa:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107dff:	77 0b                	ja     80107e0c <loaduvm+0x83>
            n = sz - i;
80107e01:	8b 45 18             	mov    0x18(%ebp),%eax
80107e04:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107e07:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e0a:	eb 07                	jmp    80107e13 <loaduvm+0x8a>
        else
            n = PGSIZE;
80107e0c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
        if (readi(ip, P2V(pa), offset + i, n) != n)
80107e13:	8b 55 14             	mov    0x14(%ebp),%edx
80107e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e19:	01 d0                	add    %edx,%eax
80107e1b:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107e1e:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107e24:	ff 75 f0             	pushl  -0x10(%ebp)
80107e27:	50                   	push   %eax
80107e28:	52                   	push   %edx
80107e29:	ff 75 10             	pushl  0x10(%ebp)
80107e2c:	e8 45 a1 ff ff       	call   80101f76 <readi>
80107e31:	83 c4 10             	add    $0x10,%esp
80107e34:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107e37:	74 07                	je     80107e40 <loaduvm+0xb7>
            return -1;
80107e39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e3e:	eb 18                	jmp    80107e58 <loaduvm+0xcf>
    for (i = 0; i < sz; i += PGSIZE) {
80107e40:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4a:	3b 45 18             	cmp    0x18(%ebp),%eax
80107e4d:	0f 82 65 ff ff ff    	jb     80107db8 <loaduvm+0x2f>
    }
    return 0;
80107e53:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e58:	c9                   	leave  
80107e59:	c3                   	ret    

80107e5a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t* pgdir, uint oldsz, uint newsz)
{
80107e5a:	f3 0f 1e fb          	endbr32 
80107e5e:	55                   	push   %ebp
80107e5f:	89 e5                	mov    %esp,%ebp
80107e61:	83 ec 18             	sub    $0x18,%esp
    char* mem;
    uint a;

    if (newsz >= KERNBASE)
80107e64:	8b 45 10             	mov    0x10(%ebp),%eax
80107e67:	85 c0                	test   %eax,%eax
80107e69:	79 0a                	jns    80107e75 <allocuvm+0x1b>
        return 0;
80107e6b:	b8 00 00 00 00       	mov    $0x0,%eax
80107e70:	e9 ec 00 00 00       	jmp    80107f61 <allocuvm+0x107>
    if (newsz < oldsz)
80107e75:	8b 45 10             	mov    0x10(%ebp),%eax
80107e78:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107e7b:	73 08                	jae    80107e85 <allocuvm+0x2b>
        return oldsz;
80107e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e80:	e9 dc 00 00 00       	jmp    80107f61 <allocuvm+0x107>

    a = PGROUNDUP(oldsz);
80107e85:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e88:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e92:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; a < newsz; a += PGSIZE) {
80107e95:	e9 b8 00 00 00       	jmp    80107f52 <allocuvm+0xf8>
        mem = kalloc();
80107e9a:	e8 e5 a9 ff ff       	call   80102884 <kalloc>
80107e9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (mem == 0) {
80107ea2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ea6:	75 2e                	jne    80107ed6 <allocuvm+0x7c>
            cprintf("allocuvm out of memory\n");
80107ea8:	83 ec 0c             	sub    $0xc,%esp
80107eab:	68 59 b0 10 80       	push   $0x8010b059
80107eb0:	e8 57 85 ff ff       	call   8010040c <cprintf>
80107eb5:	83 c4 10             	add    $0x10,%esp
            deallocuvm(pgdir, newsz, oldsz);
80107eb8:	83 ec 04             	sub    $0x4,%esp
80107ebb:	ff 75 0c             	pushl  0xc(%ebp)
80107ebe:	ff 75 10             	pushl  0x10(%ebp)
80107ec1:	ff 75 08             	pushl  0x8(%ebp)
80107ec4:	e8 9a 00 00 00       	call   80107f63 <deallocuvm>
80107ec9:	83 c4 10             	add    $0x10,%esp
            return 0;
80107ecc:	b8 00 00 00 00       	mov    $0x0,%eax
80107ed1:	e9 8b 00 00 00       	jmp    80107f61 <allocuvm+0x107>
        }
        memset(mem, 0, PGSIZE);
80107ed6:	83 ec 04             	sub    $0x4,%esp
80107ed9:	68 00 10 00 00       	push   $0x1000
80107ede:	6a 00                	push   $0x0
80107ee0:	ff 75 f0             	pushl  -0x10(%ebp)
80107ee3:	e8 95 d0 ff ff       	call   80104f7d <memset>
80107ee8:	83 c4 10             	add    $0x10,%esp
        if (mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
80107eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eee:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef7:	83 ec 0c             	sub    $0xc,%esp
80107efa:	6a 06                	push   $0x6
80107efc:	52                   	push   %edx
80107efd:	68 00 10 00 00       	push   $0x1000
80107f02:	50                   	push   %eax
80107f03:	ff 75 08             	pushl  0x8(%ebp)
80107f06:	e8 a9 fa ff ff       	call   801079b4 <mappages>
80107f0b:	83 c4 20             	add    $0x20,%esp
80107f0e:	85 c0                	test   %eax,%eax
80107f10:	79 39                	jns    80107f4b <allocuvm+0xf1>
            cprintf("allocuvm out of memory (2)\n");
80107f12:	83 ec 0c             	sub    $0xc,%esp
80107f15:	68 71 b0 10 80       	push   $0x8010b071
80107f1a:	e8 ed 84 ff ff       	call   8010040c <cprintf>
80107f1f:	83 c4 10             	add    $0x10,%esp
            deallocuvm(pgdir, newsz, oldsz);
80107f22:	83 ec 04             	sub    $0x4,%esp
80107f25:	ff 75 0c             	pushl  0xc(%ebp)
80107f28:	ff 75 10             	pushl  0x10(%ebp)
80107f2b:	ff 75 08             	pushl  0x8(%ebp)
80107f2e:	e8 30 00 00 00       	call   80107f63 <deallocuvm>
80107f33:	83 c4 10             	add    $0x10,%esp
            kfree(mem);
80107f36:	83 ec 0c             	sub    $0xc,%esp
80107f39:	ff 75 f0             	pushl  -0x10(%ebp)
80107f3c:	e8 a5 a8 ff ff       	call   801027e6 <kfree>
80107f41:	83 c4 10             	add    $0x10,%esp
            return 0;
80107f44:	b8 00 00 00 00       	mov    $0x0,%eax
80107f49:	eb 16                	jmp    80107f61 <allocuvm+0x107>
    for (; a < newsz; a += PGSIZE) {
80107f4b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f55:	3b 45 10             	cmp    0x10(%ebp),%eax
80107f58:	0f 82 3c ff ff ff    	jb     80107e9a <allocuvm+0x40>
        }
    }
    return newsz;
80107f5e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107f61:	c9                   	leave  
80107f62:	c3                   	ret    

80107f63 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t* pgdir, uint oldsz, uint newsz)
{
80107f63:	f3 0f 1e fb          	endbr32 
80107f67:	55                   	push   %ebp
80107f68:	89 e5                	mov    %esp,%ebp
80107f6a:	83 ec 18             	sub    $0x18,%esp
    pte_t* pte;
    uint a, pa;

    if (newsz >= oldsz)
80107f6d:	8b 45 10             	mov    0x10(%ebp),%eax
80107f70:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f73:	72 08                	jb     80107f7d <deallocuvm+0x1a>
        return oldsz;
80107f75:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f78:	e9 ac 00 00 00       	jmp    80108029 <deallocuvm+0xc6>

    a = PGROUNDUP(newsz);
80107f7d:	8b 45 10             	mov    0x10(%ebp),%eax
80107f80:	05 ff 0f 00 00       	add    $0xfff,%eax
80107f85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; a < oldsz; a += PGSIZE) {
80107f8d:	e9 88 00 00 00       	jmp    8010801a <deallocuvm+0xb7>
        pte = walkpgdir(pgdir, (char*)a, 0);
80107f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f95:	83 ec 04             	sub    $0x4,%esp
80107f98:	6a 00                	push   $0x0
80107f9a:	50                   	push   %eax
80107f9b:	ff 75 08             	pushl  0x8(%ebp)
80107f9e:	e8 77 f9 ff ff       	call   8010791a <walkpgdir>
80107fa3:	83 c4 10             	add    $0x10,%esp
80107fa6:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (!pte)
80107fa9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fad:	75 16                	jne    80107fc5 <deallocuvm+0x62>
            a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb2:	c1 e8 16             	shr    $0x16,%eax
80107fb5:	83 c0 01             	add    $0x1,%eax
80107fb8:	c1 e0 16             	shl    $0x16,%eax
80107fbb:	2d 00 10 00 00       	sub    $0x1000,%eax
80107fc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fc3:	eb 4e                	jmp    80108013 <deallocuvm+0xb0>
        else if ((*pte & PTE_P) != 0) {
80107fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fc8:	8b 00                	mov    (%eax),%eax
80107fca:	83 e0 01             	and    $0x1,%eax
80107fcd:	85 c0                	test   %eax,%eax
80107fcf:	74 42                	je     80108013 <deallocuvm+0xb0>
            pa = PTE_ADDR(*pte);
80107fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fd4:	8b 00                	mov    (%eax),%eax
80107fd6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fdb:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (pa == 0)
80107fde:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fe2:	75 0d                	jne    80107ff1 <deallocuvm+0x8e>
                panic("kfree");
80107fe4:	83 ec 0c             	sub    $0xc,%esp
80107fe7:	68 8d b0 10 80       	push   $0x8010b08d
80107fec:	e8 d4 85 ff ff       	call   801005c5 <panic>
            char* v = P2V(pa);
80107ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ff4:	05 00 00 00 80       	add    $0x80000000,%eax
80107ff9:	89 45 e8             	mov    %eax,-0x18(%ebp)
            kfree(v);
80107ffc:	83 ec 0c             	sub    $0xc,%esp
80107fff:	ff 75 e8             	pushl  -0x18(%ebp)
80108002:	e8 df a7 ff ff       	call   801027e6 <kfree>
80108007:	83 c4 10             	add    $0x10,%esp
            *pte = 0;
8010800a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010800d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (; a < oldsz; a += PGSIZE) {
80108013:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010801a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108020:	0f 82 6c ff ff ff    	jb     80107f92 <deallocuvm+0x2f>
        }
    }
    return newsz;
80108026:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108029:	c9                   	leave  
8010802a:	c3                   	ret    

8010802b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t* pgdir)
{
8010802b:	f3 0f 1e fb          	endbr32 
8010802f:	55                   	push   %ebp
80108030:	89 e5                	mov    %esp,%ebp
80108032:	83 ec 18             	sub    $0x18,%esp
    uint i;

    if (pgdir == 0)
80108035:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108039:	75 0d                	jne    80108048 <freevm+0x1d>
        panic("freevm: no pgdir");
8010803b:	83 ec 0c             	sub    $0xc,%esp
8010803e:	68 93 b0 10 80       	push   $0x8010b093
80108043:	e8 7d 85 ff ff       	call   801005c5 <panic>
    deallocuvm(pgdir, KERNBASE, 0);
80108048:	83 ec 04             	sub    $0x4,%esp
8010804b:	6a 00                	push   $0x0
8010804d:	68 00 00 00 80       	push   $0x80000000
80108052:	ff 75 08             	pushl  0x8(%ebp)
80108055:	e8 09 ff ff ff       	call   80107f63 <deallocuvm>
8010805a:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NPDENTRIES; i++) {
8010805d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108064:	eb 48                	jmp    801080ae <freevm+0x83>
        if (pgdir[i] & PTE_P) {
80108066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108069:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108070:	8b 45 08             	mov    0x8(%ebp),%eax
80108073:	01 d0                	add    %edx,%eax
80108075:	8b 00                	mov    (%eax),%eax
80108077:	83 e0 01             	and    $0x1,%eax
8010807a:	85 c0                	test   %eax,%eax
8010807c:	74 2c                	je     801080aa <freevm+0x7f>
            char* v = P2V(PTE_ADDR(pgdir[i]));
8010807e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108081:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108088:	8b 45 08             	mov    0x8(%ebp),%eax
8010808b:	01 d0                	add    %edx,%eax
8010808d:	8b 00                	mov    (%eax),%eax
8010808f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108094:	05 00 00 00 80       	add    $0x80000000,%eax
80108099:	89 45 f0             	mov    %eax,-0x10(%ebp)
            kfree(v);
8010809c:	83 ec 0c             	sub    $0xc,%esp
8010809f:	ff 75 f0             	pushl  -0x10(%ebp)
801080a2:	e8 3f a7 ff ff       	call   801027e6 <kfree>
801080a7:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NPDENTRIES; i++) {
801080aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080ae:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801080b5:	76 af                	jbe    80108066 <freevm+0x3b>
        }
    }
    kfree((char*)pgdir);
801080b7:	83 ec 0c             	sub    $0xc,%esp
801080ba:	ff 75 08             	pushl  0x8(%ebp)
801080bd:	e8 24 a7 ff ff       	call   801027e6 <kfree>
801080c2:	83 c4 10             	add    $0x10,%esp
}
801080c5:	90                   	nop
801080c6:	c9                   	leave  
801080c7:	c3                   	ret    

801080c8 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t* pgdir, char* uva)
{
801080c8:	f3 0f 1e fb          	endbr32 
801080cc:	55                   	push   %ebp
801080cd:	89 e5                	mov    %esp,%ebp
801080cf:	83 ec 18             	sub    $0x18,%esp
    pte_t* pte;

    pte = walkpgdir(pgdir, uva, 0);
801080d2:	83 ec 04             	sub    $0x4,%esp
801080d5:	6a 00                	push   $0x0
801080d7:	ff 75 0c             	pushl  0xc(%ebp)
801080da:	ff 75 08             	pushl  0x8(%ebp)
801080dd:	e8 38 f8 ff ff       	call   8010791a <walkpgdir>
801080e2:	83 c4 10             	add    $0x10,%esp
801080e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (pte == 0)
801080e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801080ec:	75 0d                	jne    801080fb <clearpteu+0x33>
        panic("clearpteu");
801080ee:	83 ec 0c             	sub    $0xc,%esp
801080f1:	68 a4 b0 10 80       	push   $0x8010b0a4
801080f6:	e8 ca 84 ff ff       	call   801005c5 <panic>
    *pte &= ~PTE_U;
801080fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fe:	8b 00                	mov    (%eax),%eax
80108100:	83 e0 fb             	and    $0xfffffffb,%eax
80108103:	89 c2                	mov    %eax,%edx
80108105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108108:	89 10                	mov    %edx,(%eax)
}
8010810a:	90                   	nop
8010810b:	c9                   	leave  
8010810c:	c3                   	ret    

8010810d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t* pgdir, uint sz)
{
8010810d:	f3 0f 1e fb          	endbr32 
80108111:	55                   	push   %ebp
80108112:	89 e5                	mov    %esp,%ebp
80108114:	83 ec 28             	sub    $0x28,%esp
    pde_t* d;
    pte_t* pte;
    uint pa, i, flags;
    char* mem;

    if ((d = setupkvm()) == 0)
80108117:	e8 2c f9 ff ff       	call   80107a48 <setupkvm>
8010811c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010811f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108123:	75 0a                	jne    8010812f <copyuvm+0x22>
        return 0;
80108125:	b8 00 00 00 00       	mov    $0x0,%eax
8010812a:	e9 e7 01 00 00       	jmp    80108316 <copyuvm+0x209>
    for (i = 0; i < sz; i += PGSIZE) {
8010812f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108136:	e9 bf 00 00 00       	jmp    801081fa <copyuvm+0xed>
        if ((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
8010813b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813e:	83 ec 04             	sub    $0x4,%esp
80108141:	6a 00                	push   $0x0
80108143:	50                   	push   %eax
80108144:	ff 75 08             	pushl  0x8(%ebp)
80108147:	e8 ce f7 ff ff       	call   8010791a <walkpgdir>
8010814c:	83 c4 10             	add    $0x10,%esp
8010814f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80108152:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108156:	75 0d                	jne    80108165 <copyuvm+0x58>
            panic("copyuvm: pte should exist");
80108158:	83 ec 0c             	sub    $0xc,%esp
8010815b:	68 ae b0 10 80       	push   $0x8010b0ae
80108160:	e8 60 84 ff ff       	call   801005c5 <panic>
        if (!(*pte & PTE_P))
80108165:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108168:	8b 00                	mov    (%eax),%eax
8010816a:	83 e0 01             	and    $0x1,%eax
8010816d:	85 c0                	test   %eax,%eax
8010816f:	75 0d                	jne    8010817e <copyuvm+0x71>
            panic("copyuvm: page not present");
80108171:	83 ec 0c             	sub    $0xc,%esp
80108174:	68 c8 b0 10 80       	push   $0x8010b0c8
80108179:	e8 47 84 ff ff       	call   801005c5 <panic>
        pa = PTE_ADDR(*pte);
8010817e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108181:	8b 00                	mov    (%eax),%eax
80108183:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108188:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        flags = PTE_FLAGS(*pte);
8010818b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010818e:	8b 00                	mov    (%eax),%eax
80108190:	25 ff 0f 00 00       	and    $0xfff,%eax
80108195:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if ((mem = kalloc()) == 0)
80108198:	e8 e7 a6 ff ff       	call   80102884 <kalloc>
8010819d:	89 45 dc             	mov    %eax,-0x24(%ebp)
801081a0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801081a4:	0f 84 52 01 00 00    	je     801082fc <copyuvm+0x1ef>
            goto bad;
        memmove(mem, (char*)P2V(pa), PGSIZE);
801081aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801081ad:	05 00 00 00 80       	add    $0x80000000,%eax
801081b2:	83 ec 04             	sub    $0x4,%esp
801081b5:	68 00 10 00 00       	push   $0x1000
801081ba:	50                   	push   %eax
801081bb:	ff 75 dc             	pushl  -0x24(%ebp)
801081be:	e8 81 ce ff ff       	call   80105044 <memmove>
801081c3:	83 c4 10             	add    $0x10,%esp
        if (mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801081c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801081c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801081cc:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801081d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d5:	83 ec 0c             	sub    $0xc,%esp
801081d8:	52                   	push   %edx
801081d9:	51                   	push   %ecx
801081da:	68 00 10 00 00       	push   $0x1000
801081df:	50                   	push   %eax
801081e0:	ff 75 f0             	pushl  -0x10(%ebp)
801081e3:	e8 cc f7 ff ff       	call   801079b4 <mappages>
801081e8:	83 c4 20             	add    $0x20,%esp
801081eb:	85 c0                	test   %eax,%eax
801081ed:	0f 88 0c 01 00 00    	js     801082ff <copyuvm+0x1f2>
    for (i = 0; i < sz; i += PGSIZE) {
801081f3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fd:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108200:	0f 82 35 ff ff ff    	jb     8010813b <copyuvm+0x2e>
            goto bad;
    }
    uint t = TOP;
80108206:	c7 45 ec ff ff ff 7f 	movl   $0x7fffffff,-0x14(%ebp)
    t = PGROUNDDOWN(t);
8010820d:	81 65 ec 00 f0 ff ff 	andl   $0xfffff000,-0x14(%ebp)

    for (i = t; i > t - 1 * PGSIZE; i -= PGSIZE) {
80108214:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108217:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010821a:	e9 c7 00 00 00       	jmp    801082e6 <copyuvm+0x1d9>
        if ((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
8010821f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108222:	83 ec 04             	sub    $0x4,%esp
80108225:	6a 00                	push   $0x0
80108227:	50                   	push   %eax
80108228:	ff 75 08             	pushl  0x8(%ebp)
8010822b:	e8 ea f6 ff ff       	call   8010791a <walkpgdir>
80108230:	83 c4 10             	add    $0x10,%esp
80108233:	89 45 e8             	mov    %eax,-0x18(%ebp)
80108236:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010823a:	75 0d                	jne    80108249 <copyuvm+0x13c>
            panic("copyuvm: pte should exist");
8010823c:	83 ec 0c             	sub    $0xc,%esp
8010823f:	68 ae b0 10 80       	push   $0x8010b0ae
80108244:	e8 7c 83 ff ff       	call   801005c5 <panic>
        if (!(*pte & PTE_P))
80108249:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010824c:	8b 00                	mov    (%eax),%eax
8010824e:	83 e0 01             	and    $0x1,%eax
80108251:	85 c0                	test   %eax,%eax
80108253:	75 0d                	jne    80108262 <copyuvm+0x155>
            panic("copyuvm: page not present");
80108255:	83 ec 0c             	sub    $0xc,%esp
80108258:	68 c8 b0 10 80       	push   $0x8010b0c8
8010825d:	e8 63 83 ff ff       	call   801005c5 <panic>
        pa = PTE_ADDR(*pte);
80108262:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108265:	8b 00                	mov    (%eax),%eax
80108267:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010826c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        flags = PTE_FLAGS(*pte);
8010826f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108272:	8b 00                	mov    (%eax),%eax
80108274:	25 ff 0f 00 00       	and    $0xfff,%eax
80108279:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if ((mem = kalloc()) == 0)
8010827c:	e8 03 a6 ff ff       	call   80102884 <kalloc>
80108281:	89 45 dc             	mov    %eax,-0x24(%ebp)
80108284:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80108288:	74 78                	je     80108302 <copyuvm+0x1f5>
            goto bad;
        memmove(mem, (char*)P2V(pa), PGSIZE);
8010828a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010828d:	05 00 00 00 80       	add    $0x80000000,%eax
80108292:	83 ec 04             	sub    $0x4,%esp
80108295:	68 00 10 00 00       	push   $0x1000
8010829a:	50                   	push   %eax
8010829b:	ff 75 dc             	pushl  -0x24(%ebp)
8010829e:	e8 a1 cd ff ff       	call   80105044 <memmove>
801082a3:	83 c4 10             	add    $0x10,%esp
        if (mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801082a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801082a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801082ac:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801082b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b5:	83 ec 0c             	sub    $0xc,%esp
801082b8:	52                   	push   %edx
801082b9:	51                   	push   %ecx
801082ba:	68 00 10 00 00       	push   $0x1000
801082bf:	50                   	push   %eax
801082c0:	ff 75 f0             	pushl  -0x10(%ebp)
801082c3:	e8 ec f6 ff ff       	call   801079b4 <mappages>
801082c8:	83 c4 20             	add    $0x20,%esp
801082cb:	85 c0                	test   %eax,%eax
801082cd:	79 10                	jns    801082df <copyuvm+0x1d2>
            kfree(mem);
801082cf:	83 ec 0c             	sub    $0xc,%esp
801082d2:	ff 75 dc             	pushl  -0x24(%ebp)
801082d5:	e8 0c a5 ff ff       	call   801027e6 <kfree>
801082da:	83 c4 10             	add    $0x10,%esp
            goto bad;
801082dd:	eb 24                	jmp    80108303 <copyuvm+0x1f6>
    for (i = t; i > t - 1 * PGSIZE; i -= PGSIZE) {
801082df:	81 6d f4 00 10 00 00 	subl   $0x1000,-0xc(%ebp)
801082e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e9:	2d 00 10 00 00       	sub    $0x1000,%eax
801082ee:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801082f1:	0f 87 28 ff ff ff    	ja     8010821f <copyuvm+0x112>
        }
    }
    return d;
801082f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082fa:	eb 1a                	jmp    80108316 <copyuvm+0x209>
            goto bad;
801082fc:	90                   	nop
801082fd:	eb 04                	jmp    80108303 <copyuvm+0x1f6>
            goto bad;
801082ff:	90                   	nop
80108300:	eb 01                	jmp    80108303 <copyuvm+0x1f6>
            goto bad;
80108302:	90                   	nop

bad:
    freevm(d);
80108303:	83 ec 0c             	sub    $0xc,%esp
80108306:	ff 75 f0             	pushl  -0x10(%ebp)
80108309:	e8 1d fd ff ff       	call   8010802b <freevm>
8010830e:	83 c4 10             	add    $0x10,%esp
    return 0;
80108311:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108316:	c9                   	leave  
80108317:	c3                   	ret    

80108318 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t* pgdir, char* uva)
{
80108318:	f3 0f 1e fb          	endbr32 
8010831c:	55                   	push   %ebp
8010831d:	89 e5                	mov    %esp,%ebp
8010831f:	83 ec 18             	sub    $0x18,%esp
    pte_t* pte;

    pte = walkpgdir(pgdir, uva, 0);
80108322:	83 ec 04             	sub    $0x4,%esp
80108325:	6a 00                	push   $0x0
80108327:	ff 75 0c             	pushl  0xc(%ebp)
8010832a:	ff 75 08             	pushl  0x8(%ebp)
8010832d:	e8 e8 f5 ff ff       	call   8010791a <walkpgdir>
80108332:	83 c4 10             	add    $0x10,%esp
80108335:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if ((*pte & PTE_P) == 0)
80108338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833b:	8b 00                	mov    (%eax),%eax
8010833d:	83 e0 01             	and    $0x1,%eax
80108340:	85 c0                	test   %eax,%eax
80108342:	75 07                	jne    8010834b <uva2ka+0x33>
        return 0;
80108344:	b8 00 00 00 00       	mov    $0x0,%eax
80108349:	eb 22                	jmp    8010836d <uva2ka+0x55>
    if ((*pte & PTE_U) == 0)
8010834b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834e:	8b 00                	mov    (%eax),%eax
80108350:	83 e0 04             	and    $0x4,%eax
80108353:	85 c0                	test   %eax,%eax
80108355:	75 07                	jne    8010835e <uva2ka+0x46>
        return 0;
80108357:	b8 00 00 00 00       	mov    $0x0,%eax
8010835c:	eb 0f                	jmp    8010836d <uva2ka+0x55>
    return (char*)P2V(PTE_ADDR(*pte));
8010835e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108361:	8b 00                	mov    (%eax),%eax
80108363:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108368:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010836d:	c9                   	leave  
8010836e:	c3                   	ret    

8010836f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t* pgdir, uint va, void* p, uint len)
{
8010836f:	f3 0f 1e fb          	endbr32 
80108373:	55                   	push   %ebp
80108374:	89 e5                	mov    %esp,%ebp
80108376:	83 ec 18             	sub    $0x18,%esp
    char* buf, * pa0;
    uint n, va0;

    buf = (char*)p;
80108379:	8b 45 10             	mov    0x10(%ebp),%eax
8010837c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (len > 0) {
8010837f:	eb 7f                	jmp    80108400 <copyout+0x91>
        va0 = (uint)PGROUNDDOWN(va);
80108381:	8b 45 0c             	mov    0xc(%ebp),%eax
80108384:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108389:	89 45 ec             	mov    %eax,-0x14(%ebp)
        pa0 = uva2ka(pgdir, (char*)va0);
8010838c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010838f:	83 ec 08             	sub    $0x8,%esp
80108392:	50                   	push   %eax
80108393:	ff 75 08             	pushl  0x8(%ebp)
80108396:	e8 7d ff ff ff       	call   80108318 <uva2ka>
8010839b:	83 c4 10             	add    $0x10,%esp
8010839e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (pa0 == 0)
801083a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801083a5:	75 07                	jne    801083ae <copyout+0x3f>
            return -1;
801083a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083ac:	eb 61                	jmp    8010840f <copyout+0xa0>
        n = PGSIZE - (va - va0);
801083ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083b1:	2b 45 0c             	sub    0xc(%ebp),%eax
801083b4:	05 00 10 00 00       	add    $0x1000,%eax
801083b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (n > len)
801083bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083bf:	3b 45 14             	cmp    0x14(%ebp),%eax
801083c2:	76 06                	jbe    801083ca <copyout+0x5b>
            n = len;
801083c4:	8b 45 14             	mov    0x14(%ebp),%eax
801083c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        memmove(pa0 + (va - va0), buf, n);
801083ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801083cd:	2b 45 ec             	sub    -0x14(%ebp),%eax
801083d0:	89 c2                	mov    %eax,%edx
801083d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083d5:	01 d0                	add    %edx,%eax
801083d7:	83 ec 04             	sub    $0x4,%esp
801083da:	ff 75 f0             	pushl  -0x10(%ebp)
801083dd:	ff 75 f4             	pushl  -0xc(%ebp)
801083e0:	50                   	push   %eax
801083e1:	e8 5e cc ff ff       	call   80105044 <memmove>
801083e6:	83 c4 10             	add    $0x10,%esp
        len -= n;
801083e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083ec:	29 45 14             	sub    %eax,0x14(%ebp)
        buf += n;
801083ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083f2:	01 45 f4             	add    %eax,-0xc(%ebp)
        va = va0 + PGSIZE;
801083f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f8:	05 00 10 00 00       	add    $0x1000,%eax
801083fd:	89 45 0c             	mov    %eax,0xc(%ebp)
    while (len > 0) {
80108400:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108404:	0f 85 77 ff ff ff    	jne    80108381 <copyout+0x12>
    }
    return 0;
8010840a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010840f:	c9                   	leave  
80108410:	c3                   	ret    

80108411 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108411:	f3 0f 1e fb          	endbr32 
80108415:	55                   	push   %ebp
80108416:	89 e5                	mov    %esp,%ebp
80108418:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
8010841b:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108422:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108425:	8b 40 08             	mov    0x8(%eax),%eax
80108428:	05 00 00 00 80       	add    $0x80000000,%eax
8010842d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108430:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80108437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843a:	8b 40 24             	mov    0x24(%eax),%eax
8010843d:	a3 1c 54 19 80       	mov    %eax,0x8019541c
  ncpu = 0;
80108442:	c7 05 80 84 19 80 00 	movl   $0x0,0x80198480
80108449:	00 00 00 

  while(i<madt->len){
8010844c:	90                   	nop
8010844d:	e9 be 00 00 00       	jmp    80108510 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80108452:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108455:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108458:	01 d0                	add    %edx,%eax
8010845a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
8010845d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108460:	0f b6 00             	movzbl (%eax),%eax
80108463:	0f b6 c0             	movzbl %al,%eax
80108466:	83 f8 05             	cmp    $0x5,%eax
80108469:	0f 87 a1 00 00 00    	ja     80108510 <mpinit_uefi+0xff>
8010846f:	8b 04 85 e4 b0 10 80 	mov    -0x7fef4f1c(,%eax,4),%eax
80108476:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010847c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
8010847f:	a1 80 84 19 80       	mov    0x80198480,%eax
80108484:	83 f8 03             	cmp    $0x3,%eax
80108487:	7f 28                	jg     801084b1 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108489:	8b 15 80 84 19 80    	mov    0x80198480,%edx
8010848f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108492:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80108496:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
8010849c:	81 c2 c0 81 19 80    	add    $0x801981c0,%edx
801084a2:	88 02                	mov    %al,(%edx)
          ncpu++;
801084a4:	a1 80 84 19 80       	mov    0x80198480,%eax
801084a9:	83 c0 01             	add    $0x1,%eax
801084ac:	a3 80 84 19 80       	mov    %eax,0x80198480
        }
        i += lapic_entry->record_len;
801084b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801084b4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084b8:	0f b6 c0             	movzbl %al,%eax
801084bb:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801084be:	eb 50                	jmp    80108510 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801084c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801084c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801084c9:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801084cd:	a2 a0 81 19 80       	mov    %al,0x801981a0
        i += ioapic->record_len;
801084d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801084d5:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084d9:	0f b6 c0             	movzbl %al,%eax
801084dc:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801084df:	eb 2f                	jmp    80108510 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801084e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801084e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084ea:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084ee:	0f b6 c0             	movzbl %al,%eax
801084f1:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801084f4:	eb 1a                	jmp    80108510 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801084f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801084fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ff:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108503:	0f b6 c0             	movzbl %al,%eax
80108506:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108509:	eb 05                	jmp    80108510 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
8010850b:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
8010850f:	90                   	nop
  while(i<madt->len){
80108510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108513:	8b 40 04             	mov    0x4(%eax),%eax
80108516:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108519:	0f 82 33 ff ff ff    	jb     80108452 <mpinit_uefi+0x41>
    }
  }

}
8010851f:	90                   	nop
80108520:	90                   	nop
80108521:	c9                   	leave  
80108522:	c3                   	ret    

80108523 <inb>:
{
80108523:	55                   	push   %ebp
80108524:	89 e5                	mov    %esp,%ebp
80108526:	83 ec 14             	sub    $0x14,%esp
80108529:	8b 45 08             	mov    0x8(%ebp),%eax
8010852c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108530:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108534:	89 c2                	mov    %eax,%edx
80108536:	ec                   	in     (%dx),%al
80108537:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010853a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010853e:	c9                   	leave  
8010853f:	c3                   	ret    

80108540 <outb>:
{
80108540:	55                   	push   %ebp
80108541:	89 e5                	mov    %esp,%ebp
80108543:	83 ec 08             	sub    $0x8,%esp
80108546:	8b 45 08             	mov    0x8(%ebp),%eax
80108549:	8b 55 0c             	mov    0xc(%ebp),%edx
8010854c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108550:	89 d0                	mov    %edx,%eax
80108552:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108555:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108559:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010855d:	ee                   	out    %al,(%dx)
}
8010855e:	90                   	nop
8010855f:	c9                   	leave  
80108560:	c3                   	ret    

80108561 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108561:	f3 0f 1e fb          	endbr32 
80108565:	55                   	push   %ebp
80108566:	89 e5                	mov    %esp,%ebp
80108568:	83 ec 28             	sub    $0x28,%esp
8010856b:	8b 45 08             	mov    0x8(%ebp),%eax
8010856e:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108571:	6a 00                	push   $0x0
80108573:	68 fa 03 00 00       	push   $0x3fa
80108578:	e8 c3 ff ff ff       	call   80108540 <outb>
8010857d:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108580:	68 80 00 00 00       	push   $0x80
80108585:	68 fb 03 00 00       	push   $0x3fb
8010858a:	e8 b1 ff ff ff       	call   80108540 <outb>
8010858f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108592:	6a 0c                	push   $0xc
80108594:	68 f8 03 00 00       	push   $0x3f8
80108599:	e8 a2 ff ff ff       	call   80108540 <outb>
8010859e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801085a1:	6a 00                	push   $0x0
801085a3:	68 f9 03 00 00       	push   $0x3f9
801085a8:	e8 93 ff ff ff       	call   80108540 <outb>
801085ad:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801085b0:	6a 03                	push   $0x3
801085b2:	68 fb 03 00 00       	push   $0x3fb
801085b7:	e8 84 ff ff ff       	call   80108540 <outb>
801085bc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801085bf:	6a 00                	push   $0x0
801085c1:	68 fc 03 00 00       	push   $0x3fc
801085c6:	e8 75 ff ff ff       	call   80108540 <outb>
801085cb:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
801085ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085d5:	eb 11                	jmp    801085e8 <uart_debug+0x87>
801085d7:	83 ec 0c             	sub    $0xc,%esp
801085da:	6a 0a                	push   $0xa
801085dc:	e8 55 a6 ff ff       	call   80102c36 <microdelay>
801085e1:	83 c4 10             	add    $0x10,%esp
801085e4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085e8:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801085ec:	7f 1a                	jg     80108608 <uart_debug+0xa7>
801085ee:	83 ec 0c             	sub    $0xc,%esp
801085f1:	68 fd 03 00 00       	push   $0x3fd
801085f6:	e8 28 ff ff ff       	call   80108523 <inb>
801085fb:	83 c4 10             	add    $0x10,%esp
801085fe:	0f b6 c0             	movzbl %al,%eax
80108601:	83 e0 20             	and    $0x20,%eax
80108604:	85 c0                	test   %eax,%eax
80108606:	74 cf                	je     801085d7 <uart_debug+0x76>
  outb(COM1+0, p);
80108608:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010860c:	0f b6 c0             	movzbl %al,%eax
8010860f:	83 ec 08             	sub    $0x8,%esp
80108612:	50                   	push   %eax
80108613:	68 f8 03 00 00       	push   $0x3f8
80108618:	e8 23 ff ff ff       	call   80108540 <outb>
8010861d:	83 c4 10             	add    $0x10,%esp
}
80108620:	90                   	nop
80108621:	c9                   	leave  
80108622:	c3                   	ret    

80108623 <uart_debugs>:

void uart_debugs(char *p){
80108623:	f3 0f 1e fb          	endbr32 
80108627:	55                   	push   %ebp
80108628:	89 e5                	mov    %esp,%ebp
8010862a:	83 ec 08             	sub    $0x8,%esp
  while(*p){
8010862d:	eb 1b                	jmp    8010864a <uart_debugs+0x27>
    uart_debug(*p++);
8010862f:	8b 45 08             	mov    0x8(%ebp),%eax
80108632:	8d 50 01             	lea    0x1(%eax),%edx
80108635:	89 55 08             	mov    %edx,0x8(%ebp)
80108638:	0f b6 00             	movzbl (%eax),%eax
8010863b:	0f be c0             	movsbl %al,%eax
8010863e:	83 ec 0c             	sub    $0xc,%esp
80108641:	50                   	push   %eax
80108642:	e8 1a ff ff ff       	call   80108561 <uart_debug>
80108647:	83 c4 10             	add    $0x10,%esp
  while(*p){
8010864a:	8b 45 08             	mov    0x8(%ebp),%eax
8010864d:	0f b6 00             	movzbl (%eax),%eax
80108650:	84 c0                	test   %al,%al
80108652:	75 db                	jne    8010862f <uart_debugs+0xc>
  }
}
80108654:	90                   	nop
80108655:	90                   	nop
80108656:	c9                   	leave  
80108657:	c3                   	ret    

80108658 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108658:	f3 0f 1e fb          	endbr32 
8010865c:	55                   	push   %ebp
8010865d:	89 e5                	mov    %esp,%ebp
8010865f:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108662:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108669:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010866c:	8b 50 14             	mov    0x14(%eax),%edx
8010866f:	8b 40 10             	mov    0x10(%eax),%eax
80108672:	a3 84 84 19 80       	mov    %eax,0x80198484
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108677:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010867a:	8b 50 1c             	mov    0x1c(%eax),%edx
8010867d:	8b 40 18             	mov    0x18(%eax),%eax
80108680:	a3 8c 84 19 80       	mov    %eax,0x8019848c
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108685:	a1 8c 84 19 80       	mov    0x8019848c,%eax
8010868a:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
8010868f:	29 c2                	sub    %eax,%edx
80108691:	89 d0                	mov    %edx,%eax
80108693:	a3 88 84 19 80       	mov    %eax,0x80198488
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108698:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010869b:	8b 50 24             	mov    0x24(%eax),%edx
8010869e:	8b 40 20             	mov    0x20(%eax),%eax
801086a1:	a3 90 84 19 80       	mov    %eax,0x80198490
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
801086a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086a9:	8b 50 2c             	mov    0x2c(%eax),%edx
801086ac:	8b 40 28             	mov    0x28(%eax),%eax
801086af:	a3 94 84 19 80       	mov    %eax,0x80198494
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
801086b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086b7:	8b 50 34             	mov    0x34(%eax),%edx
801086ba:	8b 40 30             	mov    0x30(%eax),%eax
801086bd:	a3 98 84 19 80       	mov    %eax,0x80198498
}
801086c2:	90                   	nop
801086c3:	c9                   	leave  
801086c4:	c3                   	ret    

801086c5 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
801086c5:	f3 0f 1e fb          	endbr32 
801086c9:	55                   	push   %ebp
801086ca:	89 e5                	mov    %esp,%ebp
801086cc:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
801086cf:	8b 15 98 84 19 80    	mov    0x80198498,%edx
801086d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801086d8:	0f af d0             	imul   %eax,%edx
801086db:	8b 45 08             	mov    0x8(%ebp),%eax
801086de:	01 d0                	add    %edx,%eax
801086e0:	c1 e0 02             	shl    $0x2,%eax
801086e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
801086e6:	8b 15 88 84 19 80    	mov    0x80198488,%edx
801086ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086ef:	01 d0                	add    %edx,%eax
801086f1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
801086f4:	8b 45 10             	mov    0x10(%ebp),%eax
801086f7:	0f b6 10             	movzbl (%eax),%edx
801086fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801086fd:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
801086ff:	8b 45 10             	mov    0x10(%ebp),%eax
80108702:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108706:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108709:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010870c:	8b 45 10             	mov    0x10(%ebp),%eax
8010870f:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108713:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108716:	88 50 02             	mov    %dl,0x2(%eax)
}
80108719:	90                   	nop
8010871a:	c9                   	leave  
8010871b:	c3                   	ret    

8010871c <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010871c:	f3 0f 1e fb          	endbr32 
80108720:	55                   	push   %ebp
80108721:	89 e5                	mov    %esp,%ebp
80108723:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108726:	8b 15 98 84 19 80    	mov    0x80198498,%edx
8010872c:	8b 45 08             	mov    0x8(%ebp),%eax
8010872f:	0f af c2             	imul   %edx,%eax
80108732:	c1 e0 02             	shl    $0x2,%eax
80108735:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108738:	8b 15 8c 84 19 80    	mov    0x8019848c,%edx
8010873e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108741:	29 c2                	sub    %eax,%edx
80108743:	89 d0                	mov    %edx,%eax
80108745:	8b 0d 88 84 19 80    	mov    0x80198488,%ecx
8010874b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010874e:	01 ca                	add    %ecx,%edx
80108750:	89 d1                	mov    %edx,%ecx
80108752:	8b 15 88 84 19 80    	mov    0x80198488,%edx
80108758:	83 ec 04             	sub    $0x4,%esp
8010875b:	50                   	push   %eax
8010875c:	51                   	push   %ecx
8010875d:	52                   	push   %edx
8010875e:	e8 e1 c8 ff ff       	call   80105044 <memmove>
80108763:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108769:	8b 0d 88 84 19 80    	mov    0x80198488,%ecx
8010876f:	8b 15 8c 84 19 80    	mov    0x8019848c,%edx
80108775:	01 d1                	add    %edx,%ecx
80108777:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010877a:	29 d1                	sub    %edx,%ecx
8010877c:	89 ca                	mov    %ecx,%edx
8010877e:	83 ec 04             	sub    $0x4,%esp
80108781:	50                   	push   %eax
80108782:	6a 00                	push   $0x0
80108784:	52                   	push   %edx
80108785:	e8 f3 c7 ff ff       	call   80104f7d <memset>
8010878a:	83 c4 10             	add    $0x10,%esp
}
8010878d:	90                   	nop
8010878e:	c9                   	leave  
8010878f:	c3                   	ret    

80108790 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108790:	f3 0f 1e fb          	endbr32 
80108794:	55                   	push   %ebp
80108795:	89 e5                	mov    %esp,%ebp
80108797:	53                   	push   %ebx
80108798:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
8010879b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087a2:	e9 b1 00 00 00       	jmp    80108858 <font_render+0xc8>
    for(int j=14;j>-1;j--){
801087a7:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
801087ae:	e9 97 00 00 00       	jmp    8010884a <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
801087b3:	8b 45 10             	mov    0x10(%ebp),%eax
801087b6:	83 e8 20             	sub    $0x20,%eax
801087b9:	6b d0 1e             	imul   $0x1e,%eax,%edx
801087bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bf:	01 d0                	add    %edx,%eax
801087c1:	0f b7 84 00 00 b1 10 	movzwl -0x7fef4f00(%eax,%eax,1),%eax
801087c8:	80 
801087c9:	0f b7 d0             	movzwl %ax,%edx
801087cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087cf:	bb 01 00 00 00       	mov    $0x1,%ebx
801087d4:	89 c1                	mov    %eax,%ecx
801087d6:	d3 e3                	shl    %cl,%ebx
801087d8:	89 d8                	mov    %ebx,%eax
801087da:	21 d0                	and    %edx,%eax
801087dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
801087df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087e2:	ba 01 00 00 00       	mov    $0x1,%edx
801087e7:	89 c1                	mov    %eax,%ecx
801087e9:	d3 e2                	shl    %cl,%edx
801087eb:	89 d0                	mov    %edx,%eax
801087ed:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801087f0:	75 2b                	jne    8010881d <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
801087f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801087f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f8:	01 c2                	add    %eax,%edx
801087fa:	b8 0e 00 00 00       	mov    $0xe,%eax
801087ff:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108802:	89 c1                	mov    %eax,%ecx
80108804:	8b 45 08             	mov    0x8(%ebp),%eax
80108807:	01 c8                	add    %ecx,%eax
80108809:	83 ec 04             	sub    $0x4,%esp
8010880c:	68 00 f5 10 80       	push   $0x8010f500
80108811:	52                   	push   %edx
80108812:	50                   	push   %eax
80108813:	e8 ad fe ff ff       	call   801086c5 <graphic_draw_pixel>
80108818:	83 c4 10             	add    $0x10,%esp
8010881b:	eb 29                	jmp    80108846 <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
8010881d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108823:	01 c2                	add    %eax,%edx
80108825:	b8 0e 00 00 00       	mov    $0xe,%eax
8010882a:	2b 45 f0             	sub    -0x10(%ebp),%eax
8010882d:	89 c1                	mov    %eax,%ecx
8010882f:	8b 45 08             	mov    0x8(%ebp),%eax
80108832:	01 c8                	add    %ecx,%eax
80108834:	83 ec 04             	sub    $0x4,%esp
80108837:	68 64 d0 18 80       	push   $0x8018d064
8010883c:	52                   	push   %edx
8010883d:	50                   	push   %eax
8010883e:	e8 82 fe ff ff       	call   801086c5 <graphic_draw_pixel>
80108843:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108846:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010884a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010884e:	0f 89 5f ff ff ff    	jns    801087b3 <font_render+0x23>
  for(int i=0;i<30;i++){
80108854:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108858:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
8010885c:	0f 8e 45 ff ff ff    	jle    801087a7 <font_render+0x17>
      }
    }
  }
}
80108862:	90                   	nop
80108863:	90                   	nop
80108864:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108867:	c9                   	leave  
80108868:	c3                   	ret    

80108869 <font_render_string>:

void font_render_string(char *string,int row){
80108869:	f3 0f 1e fb          	endbr32 
8010886d:	55                   	push   %ebp
8010886e:	89 e5                	mov    %esp,%ebp
80108870:	53                   	push   %ebx
80108871:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108874:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010887b:	eb 33                	jmp    801088b0 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
8010887d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108880:	8b 45 08             	mov    0x8(%ebp),%eax
80108883:	01 d0                	add    %edx,%eax
80108885:	0f b6 00             	movzbl (%eax),%eax
80108888:	0f be d8             	movsbl %al,%ebx
8010888b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010888e:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108891:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108894:	89 d0                	mov    %edx,%eax
80108896:	c1 e0 04             	shl    $0x4,%eax
80108899:	29 d0                	sub    %edx,%eax
8010889b:	83 c0 02             	add    $0x2,%eax
8010889e:	83 ec 04             	sub    $0x4,%esp
801088a1:	53                   	push   %ebx
801088a2:	51                   	push   %ecx
801088a3:	50                   	push   %eax
801088a4:	e8 e7 fe ff ff       	call   80108790 <font_render>
801088a9:	83 c4 10             	add    $0x10,%esp
    i++;
801088ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
801088b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088b3:	8b 45 08             	mov    0x8(%ebp),%eax
801088b6:	01 d0                	add    %edx,%eax
801088b8:	0f b6 00             	movzbl (%eax),%eax
801088bb:	84 c0                	test   %al,%al
801088bd:	74 06                	je     801088c5 <font_render_string+0x5c>
801088bf:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
801088c3:	7e b8                	jle    8010887d <font_render_string+0x14>
  }
}
801088c5:	90                   	nop
801088c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801088c9:	c9                   	leave  
801088ca:	c3                   	ret    

801088cb <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
801088cb:	f3 0f 1e fb          	endbr32 
801088cf:	55                   	push   %ebp
801088d0:	89 e5                	mov    %esp,%ebp
801088d2:	53                   	push   %ebx
801088d3:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
801088d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088dd:	eb 6b                	jmp    8010894a <pci_init+0x7f>
    for(int j=0;j<32;j++){
801088df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801088e6:	eb 58                	jmp    80108940 <pci_init+0x75>
      for(int k=0;k<8;k++){
801088e8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801088ef:	eb 45                	jmp    80108936 <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
801088f1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801088f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801088f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088fa:	83 ec 0c             	sub    $0xc,%esp
801088fd:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108900:	53                   	push   %ebx
80108901:	6a 00                	push   $0x0
80108903:	51                   	push   %ecx
80108904:	52                   	push   %edx
80108905:	50                   	push   %eax
80108906:	e8 c0 00 00 00       	call   801089cb <pci_access_config>
8010890b:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010890e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108911:	0f b7 c0             	movzwl %ax,%eax
80108914:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108919:	74 17                	je     80108932 <pci_init+0x67>
        pci_init_device(i,j,k);
8010891b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010891e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108924:	83 ec 04             	sub    $0x4,%esp
80108927:	51                   	push   %ecx
80108928:	52                   	push   %edx
80108929:	50                   	push   %eax
8010892a:	e8 4f 01 00 00       	call   80108a7e <pci_init_device>
8010892f:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108932:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108936:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010893a:	7e b5                	jle    801088f1 <pci_init+0x26>
    for(int j=0;j<32;j++){
8010893c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108940:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108944:	7e a2                	jle    801088e8 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108946:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010894a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108951:	7e 8c                	jle    801088df <pci_init+0x14>
      }
      }
    }
  }
}
80108953:	90                   	nop
80108954:	90                   	nop
80108955:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108958:	c9                   	leave  
80108959:	c3                   	ret    

8010895a <pci_write_config>:

void pci_write_config(uint config){
8010895a:	f3 0f 1e fb          	endbr32 
8010895e:	55                   	push   %ebp
8010895f:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108961:	8b 45 08             	mov    0x8(%ebp),%eax
80108964:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108969:	89 c0                	mov    %eax,%eax
8010896b:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
8010896c:	90                   	nop
8010896d:	5d                   	pop    %ebp
8010896e:	c3                   	ret    

8010896f <pci_write_data>:

void pci_write_data(uint config){
8010896f:	f3 0f 1e fb          	endbr32 
80108973:	55                   	push   %ebp
80108974:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108976:	8b 45 08             	mov    0x8(%ebp),%eax
80108979:	ba fc 0c 00 00       	mov    $0xcfc,%edx
8010897e:	89 c0                	mov    %eax,%eax
80108980:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108981:	90                   	nop
80108982:	5d                   	pop    %ebp
80108983:	c3                   	ret    

80108984 <pci_read_config>:
uint pci_read_config(){
80108984:	f3 0f 1e fb          	endbr32 
80108988:	55                   	push   %ebp
80108989:	89 e5                	mov    %esp,%ebp
8010898b:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010898e:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108993:	ed                   	in     (%dx),%eax
80108994:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108997:	83 ec 0c             	sub    $0xc,%esp
8010899a:	68 c8 00 00 00       	push   $0xc8
8010899f:	e8 92 a2 ff ff       	call   80102c36 <microdelay>
801089a4:	83 c4 10             	add    $0x10,%esp
  return data;
801089a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801089aa:	c9                   	leave  
801089ab:	c3                   	ret    

801089ac <pci_test>:


void pci_test(){
801089ac:	f3 0f 1e fb          	endbr32 
801089b0:	55                   	push   %ebp
801089b1:	89 e5                	mov    %esp,%ebp
801089b3:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801089b6:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801089bd:	ff 75 fc             	pushl  -0x4(%ebp)
801089c0:	e8 95 ff ff ff       	call   8010895a <pci_write_config>
801089c5:	83 c4 04             	add    $0x4,%esp
}
801089c8:	90                   	nop
801089c9:	c9                   	leave  
801089ca:	c3                   	ret    

801089cb <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
801089cb:	f3 0f 1e fb          	endbr32 
801089cf:	55                   	push   %ebp
801089d0:	89 e5                	mov    %esp,%ebp
801089d2:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801089d5:	8b 45 08             	mov    0x8(%ebp),%eax
801089d8:	c1 e0 10             	shl    $0x10,%eax
801089db:	25 00 00 ff 00       	and    $0xff0000,%eax
801089e0:	89 c2                	mov    %eax,%edx
801089e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e5:	c1 e0 0b             	shl    $0xb,%eax
801089e8:	0f b7 c0             	movzwl %ax,%eax
801089eb:	09 c2                	or     %eax,%edx
801089ed:	8b 45 10             	mov    0x10(%ebp),%eax
801089f0:	c1 e0 08             	shl    $0x8,%eax
801089f3:	25 00 07 00 00       	and    $0x700,%eax
801089f8:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801089fa:	8b 45 14             	mov    0x14(%ebp),%eax
801089fd:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a02:	09 d0                	or     %edx,%eax
80108a04:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108a0c:	ff 75 f4             	pushl  -0xc(%ebp)
80108a0f:	e8 46 ff ff ff       	call   8010895a <pci_write_config>
80108a14:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108a17:	e8 68 ff ff ff       	call   80108984 <pci_read_config>
80108a1c:	8b 55 18             	mov    0x18(%ebp),%edx
80108a1f:	89 02                	mov    %eax,(%edx)
}
80108a21:	90                   	nop
80108a22:	c9                   	leave  
80108a23:	c3                   	ret    

80108a24 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108a24:	f3 0f 1e fb          	endbr32 
80108a28:	55                   	push   %ebp
80108a29:	89 e5                	mov    %esp,%ebp
80108a2b:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a2e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a31:	c1 e0 10             	shl    $0x10,%eax
80108a34:	25 00 00 ff 00       	and    $0xff0000,%eax
80108a39:	89 c2                	mov    %eax,%edx
80108a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a3e:	c1 e0 0b             	shl    $0xb,%eax
80108a41:	0f b7 c0             	movzwl %ax,%eax
80108a44:	09 c2                	or     %eax,%edx
80108a46:	8b 45 10             	mov    0x10(%ebp),%eax
80108a49:	c1 e0 08             	shl    $0x8,%eax
80108a4c:	25 00 07 00 00       	and    $0x700,%eax
80108a51:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108a53:	8b 45 14             	mov    0x14(%ebp),%eax
80108a56:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108a5b:	09 d0                	or     %edx,%eax
80108a5d:	0d 00 00 00 80       	or     $0x80000000,%eax
80108a62:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108a65:	ff 75 fc             	pushl  -0x4(%ebp)
80108a68:	e8 ed fe ff ff       	call   8010895a <pci_write_config>
80108a6d:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108a70:	ff 75 18             	pushl  0x18(%ebp)
80108a73:	e8 f7 fe ff ff       	call   8010896f <pci_write_data>
80108a78:	83 c4 04             	add    $0x4,%esp
}
80108a7b:	90                   	nop
80108a7c:	c9                   	leave  
80108a7d:	c3                   	ret    

80108a7e <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108a7e:	f3 0f 1e fb          	endbr32 
80108a82:	55                   	push   %ebp
80108a83:	89 e5                	mov    %esp,%ebp
80108a85:	53                   	push   %ebx
80108a86:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108a89:	8b 45 08             	mov    0x8(%ebp),%eax
80108a8c:	a2 9c 84 19 80       	mov    %al,0x8019849c
  dev.device_num = device_num;
80108a91:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a94:	a2 9d 84 19 80       	mov    %al,0x8019849d
  dev.function_num = function_num;
80108a99:	8b 45 10             	mov    0x10(%ebp),%eax
80108a9c:	a2 9e 84 19 80       	mov    %al,0x8019849e
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108aa1:	ff 75 10             	pushl  0x10(%ebp)
80108aa4:	ff 75 0c             	pushl  0xc(%ebp)
80108aa7:	ff 75 08             	pushl  0x8(%ebp)
80108aaa:	68 44 c7 10 80       	push   $0x8010c744
80108aaf:	e8 58 79 ff ff       	call   8010040c <cprintf>
80108ab4:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108ab7:	83 ec 0c             	sub    $0xc,%esp
80108aba:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108abd:	50                   	push   %eax
80108abe:	6a 00                	push   $0x0
80108ac0:	ff 75 10             	pushl  0x10(%ebp)
80108ac3:	ff 75 0c             	pushl  0xc(%ebp)
80108ac6:	ff 75 08             	pushl  0x8(%ebp)
80108ac9:	e8 fd fe ff ff       	call   801089cb <pci_access_config>
80108ace:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108ad1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ad4:	c1 e8 10             	shr    $0x10,%eax
80108ad7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108add:	25 ff ff 00 00       	and    $0xffff,%eax
80108ae2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae8:	a3 a0 84 19 80       	mov    %eax,0x801984a0
  dev.vendor_id = vendor_id;
80108aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af0:	a3 a4 84 19 80       	mov    %eax,0x801984a4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108af5:	83 ec 04             	sub    $0x4,%esp
80108af8:	ff 75 f0             	pushl  -0x10(%ebp)
80108afb:	ff 75 f4             	pushl  -0xc(%ebp)
80108afe:	68 78 c7 10 80       	push   $0x8010c778
80108b03:	e8 04 79 ff ff       	call   8010040c <cprintf>
80108b08:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108b0b:	83 ec 0c             	sub    $0xc,%esp
80108b0e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b11:	50                   	push   %eax
80108b12:	6a 08                	push   $0x8
80108b14:	ff 75 10             	pushl  0x10(%ebp)
80108b17:	ff 75 0c             	pushl  0xc(%ebp)
80108b1a:	ff 75 08             	pushl  0x8(%ebp)
80108b1d:	e8 a9 fe ff ff       	call   801089cb <pci_access_config>
80108b22:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b28:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108b2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b2e:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b31:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108b34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b37:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108b3a:	0f b6 c0             	movzbl %al,%eax
80108b3d:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108b40:	c1 eb 18             	shr    $0x18,%ebx
80108b43:	83 ec 0c             	sub    $0xc,%esp
80108b46:	51                   	push   %ecx
80108b47:	52                   	push   %edx
80108b48:	50                   	push   %eax
80108b49:	53                   	push   %ebx
80108b4a:	68 9c c7 10 80       	push   $0x8010c79c
80108b4f:	e8 b8 78 ff ff       	call   8010040c <cprintf>
80108b54:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108b57:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b5a:	c1 e8 18             	shr    $0x18,%eax
80108b5d:	a2 a8 84 19 80       	mov    %al,0x801984a8
  dev.sub_class = (data>>16)&0xFF;
80108b62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b65:	c1 e8 10             	shr    $0x10,%eax
80108b68:	a2 a9 84 19 80       	mov    %al,0x801984a9
  dev.interface = (data>>8)&0xFF;
80108b6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b70:	c1 e8 08             	shr    $0x8,%eax
80108b73:	a2 aa 84 19 80       	mov    %al,0x801984aa
  dev.revision_id = data&0xFF;
80108b78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b7b:	a2 ab 84 19 80       	mov    %al,0x801984ab
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108b80:	83 ec 0c             	sub    $0xc,%esp
80108b83:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108b86:	50                   	push   %eax
80108b87:	6a 10                	push   $0x10
80108b89:	ff 75 10             	pushl  0x10(%ebp)
80108b8c:	ff 75 0c             	pushl  0xc(%ebp)
80108b8f:	ff 75 08             	pushl  0x8(%ebp)
80108b92:	e8 34 fe ff ff       	call   801089cb <pci_access_config>
80108b97:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108b9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b9d:	a3 ac 84 19 80       	mov    %eax,0x801984ac
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108ba2:	83 ec 0c             	sub    $0xc,%esp
80108ba5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108ba8:	50                   	push   %eax
80108ba9:	6a 14                	push   $0x14
80108bab:	ff 75 10             	pushl  0x10(%ebp)
80108bae:	ff 75 0c             	pushl  0xc(%ebp)
80108bb1:	ff 75 08             	pushl  0x8(%ebp)
80108bb4:	e8 12 fe ff ff       	call   801089cb <pci_access_config>
80108bb9:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bbf:	a3 b0 84 19 80       	mov    %eax,0x801984b0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108bc4:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108bcb:	75 5a                	jne    80108c27 <pci_init_device+0x1a9>
80108bcd:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108bd4:	75 51                	jne    80108c27 <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108bd6:	83 ec 0c             	sub    $0xc,%esp
80108bd9:	68 e1 c7 10 80       	push   $0x8010c7e1
80108bde:	e8 29 78 ff ff       	call   8010040c <cprintf>
80108be3:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108be6:	83 ec 0c             	sub    $0xc,%esp
80108be9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108bec:	50                   	push   %eax
80108bed:	68 f0 00 00 00       	push   $0xf0
80108bf2:	ff 75 10             	pushl  0x10(%ebp)
80108bf5:	ff 75 0c             	pushl  0xc(%ebp)
80108bf8:	ff 75 08             	pushl  0x8(%ebp)
80108bfb:	e8 cb fd ff ff       	call   801089cb <pci_access_config>
80108c00:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108c03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c06:	83 ec 08             	sub    $0x8,%esp
80108c09:	50                   	push   %eax
80108c0a:	68 fb c7 10 80       	push   $0x8010c7fb
80108c0f:	e8 f8 77 ff ff       	call   8010040c <cprintf>
80108c14:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108c17:	83 ec 0c             	sub    $0xc,%esp
80108c1a:	68 9c 84 19 80       	push   $0x8019849c
80108c1f:	e8 09 00 00 00       	call   80108c2d <i8254_init>
80108c24:	83 c4 10             	add    $0x10,%esp
  }
}
80108c27:	90                   	nop
80108c28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c2b:	c9                   	leave  
80108c2c:	c3                   	ret    

80108c2d <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108c2d:	f3 0f 1e fb          	endbr32 
80108c31:	55                   	push   %ebp
80108c32:	89 e5                	mov    %esp,%ebp
80108c34:	53                   	push   %ebx
80108c35:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108c38:	8b 45 08             	mov    0x8(%ebp),%eax
80108c3b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108c3f:	0f b6 c8             	movzbl %al,%ecx
80108c42:	8b 45 08             	mov    0x8(%ebp),%eax
80108c45:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108c49:	0f b6 d0             	movzbl %al,%edx
80108c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c4f:	0f b6 00             	movzbl (%eax),%eax
80108c52:	0f b6 c0             	movzbl %al,%eax
80108c55:	83 ec 0c             	sub    $0xc,%esp
80108c58:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108c5b:	53                   	push   %ebx
80108c5c:	6a 04                	push   $0x4
80108c5e:	51                   	push   %ecx
80108c5f:	52                   	push   %edx
80108c60:	50                   	push   %eax
80108c61:	e8 65 fd ff ff       	call   801089cb <pci_access_config>
80108c66:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c6c:	83 c8 04             	or     $0x4,%eax
80108c6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108c72:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108c75:	8b 45 08             	mov    0x8(%ebp),%eax
80108c78:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108c7c:	0f b6 c8             	movzbl %al,%ecx
80108c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80108c82:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108c86:	0f b6 d0             	movzbl %al,%edx
80108c89:	8b 45 08             	mov    0x8(%ebp),%eax
80108c8c:	0f b6 00             	movzbl (%eax),%eax
80108c8f:	0f b6 c0             	movzbl %al,%eax
80108c92:	83 ec 0c             	sub    $0xc,%esp
80108c95:	53                   	push   %ebx
80108c96:	6a 04                	push   $0x4
80108c98:	51                   	push   %ecx
80108c99:	52                   	push   %edx
80108c9a:	50                   	push   %eax
80108c9b:	e8 84 fd ff ff       	call   80108a24 <pci_write_config_register>
80108ca0:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca6:	8b 40 10             	mov    0x10(%eax),%eax
80108ca9:	05 00 00 00 40       	add    $0x40000000,%eax
80108cae:	a3 b4 84 19 80       	mov    %eax,0x801984b4
  uint *ctrl = (uint *)base_addr;
80108cb3:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108cbb:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108cc0:	05 d8 00 00 00       	add    $0xd8,%eax
80108cc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ccb:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd4:	8b 00                	mov    (%eax),%eax
80108cd6:	0d 00 00 00 04       	or     $0x4000000,%eax
80108cdb:	89 c2                	mov    %eax,%edx
80108cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce0:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ce5:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cee:	8b 00                	mov    (%eax),%eax
80108cf0:	83 c8 40             	or     $0x40,%eax
80108cf3:	89 c2                	mov    %eax,%edx
80108cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf8:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cfd:	8b 10                	mov    (%eax),%edx
80108cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d02:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108d04:	83 ec 0c             	sub    $0xc,%esp
80108d07:	68 10 c8 10 80       	push   $0x8010c810
80108d0c:	e8 fb 76 ff ff       	call   8010040c <cprintf>
80108d11:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108d14:	e8 6b 9b ff ff       	call   80102884 <kalloc>
80108d19:	a3 b8 84 19 80       	mov    %eax,0x801984b8
  *intr_addr = 0;
80108d1e:	a1 b8 84 19 80       	mov    0x801984b8,%eax
80108d23:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108d29:	a1 b8 84 19 80       	mov    0x801984b8,%eax
80108d2e:	83 ec 08             	sub    $0x8,%esp
80108d31:	50                   	push   %eax
80108d32:	68 32 c8 10 80       	push   $0x8010c832
80108d37:	e8 d0 76 ff ff       	call   8010040c <cprintf>
80108d3c:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108d3f:	e8 50 00 00 00       	call   80108d94 <i8254_init_recv>
  i8254_init_send();
80108d44:	e8 6d 03 00 00       	call   801090b6 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108d49:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d50:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108d53:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d5a:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108d5d:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d64:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108d67:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108d6e:	0f b6 c0             	movzbl %al,%eax
80108d71:	83 ec 0c             	sub    $0xc,%esp
80108d74:	53                   	push   %ebx
80108d75:	51                   	push   %ecx
80108d76:	52                   	push   %edx
80108d77:	50                   	push   %eax
80108d78:	68 40 c8 10 80       	push   $0x8010c840
80108d7d:	e8 8a 76 ff ff       	call   8010040c <cprintf>
80108d82:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80108d8e:	90                   	nop
80108d8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d92:	c9                   	leave  
80108d93:	c3                   	ret    

80108d94 <i8254_init_recv>:

void i8254_init_recv(){
80108d94:	f3 0f 1e fb          	endbr32 
80108d98:	55                   	push   %ebp
80108d99:	89 e5                	mov    %esp,%ebp
80108d9b:	57                   	push   %edi
80108d9c:	56                   	push   %esi
80108d9d:	53                   	push   %ebx
80108d9e:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108da1:	83 ec 0c             	sub    $0xc,%esp
80108da4:	6a 00                	push   $0x0
80108da6:	e8 ec 04 00 00       	call   80109297 <i8254_read_eeprom>
80108dab:	83 c4 10             	add    $0x10,%esp
80108dae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108db1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108db4:	a2 68 d0 18 80       	mov    %al,0x8018d068
  mac_addr[1] = data_l>>8;
80108db9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108dbc:	c1 e8 08             	shr    $0x8,%eax
80108dbf:	a2 69 d0 18 80       	mov    %al,0x8018d069
  uint data_m = i8254_read_eeprom(0x1);
80108dc4:	83 ec 0c             	sub    $0xc,%esp
80108dc7:	6a 01                	push   $0x1
80108dc9:	e8 c9 04 00 00       	call   80109297 <i8254_read_eeprom>
80108dce:	83 c4 10             	add    $0x10,%esp
80108dd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108dd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108dd7:	a2 6a d0 18 80       	mov    %al,0x8018d06a
  mac_addr[3] = data_m>>8;
80108ddc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ddf:	c1 e8 08             	shr    $0x8,%eax
80108de2:	a2 6b d0 18 80       	mov    %al,0x8018d06b
  uint data_h = i8254_read_eeprom(0x2);
80108de7:	83 ec 0c             	sub    $0xc,%esp
80108dea:	6a 02                	push   $0x2
80108dec:	e8 a6 04 00 00       	call   80109297 <i8254_read_eeprom>
80108df1:	83 c4 10             	add    $0x10,%esp
80108df4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108df7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dfa:	a2 6c d0 18 80       	mov    %al,0x8018d06c
  mac_addr[5] = data_h>>8;
80108dff:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e02:	c1 e8 08             	shr    $0x8,%eax
80108e05:	a2 6d d0 18 80       	mov    %al,0x8018d06d
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108e0a:	0f b6 05 6d d0 18 80 	movzbl 0x8018d06d,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e11:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108e14:	0f b6 05 6c d0 18 80 	movzbl 0x8018d06c,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e1b:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108e1e:	0f b6 05 6b d0 18 80 	movzbl 0x8018d06b,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e25:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108e28:	0f b6 05 6a d0 18 80 	movzbl 0x8018d06a,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e2f:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108e32:	0f b6 05 69 d0 18 80 	movzbl 0x8018d069,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e39:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108e3c:	0f b6 05 68 d0 18 80 	movzbl 0x8018d068,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108e43:	0f b6 c0             	movzbl %al,%eax
80108e46:	83 ec 04             	sub    $0x4,%esp
80108e49:	57                   	push   %edi
80108e4a:	56                   	push   %esi
80108e4b:	53                   	push   %ebx
80108e4c:	51                   	push   %ecx
80108e4d:	52                   	push   %edx
80108e4e:	50                   	push   %eax
80108e4f:	68 58 c8 10 80       	push   $0x8010c858
80108e54:	e8 b3 75 ff ff       	call   8010040c <cprintf>
80108e59:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108e5c:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108e61:	05 00 54 00 00       	add    $0x5400,%eax
80108e66:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108e69:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108e6e:	05 04 54 00 00       	add    $0x5404,%eax
80108e73:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108e76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108e79:	c1 e0 10             	shl    $0x10,%eax
80108e7c:	0b 45 d8             	or     -0x28(%ebp),%eax
80108e7f:	89 c2                	mov    %eax,%edx
80108e81:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108e84:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108e86:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e89:	0d 00 00 00 80       	or     $0x80000000,%eax
80108e8e:	89 c2                	mov    %eax,%edx
80108e90:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108e93:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108e95:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108e9a:	05 00 52 00 00       	add    $0x5200,%eax
80108e9f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108ea2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108ea9:	eb 19                	jmp    80108ec4 <i8254_init_recv+0x130>
    mta[i] = 0;
80108eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108eae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108eb5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108eb8:	01 d0                	add    %edx,%eax
80108eba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108ec0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108ec4:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108ec8:	7e e1                	jle    80108eab <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108eca:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108ecf:	05 d0 00 00 00       	add    $0xd0,%eax
80108ed4:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108ed7:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108eda:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108ee0:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108ee5:	05 c8 00 00 00       	add    $0xc8,%eax
80108eea:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108eed:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108ef0:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108ef6:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108efb:	05 28 28 00 00       	add    $0x2828,%eax
80108f00:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108f03:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108f06:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108f0c:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f11:	05 00 01 00 00       	add    $0x100,%eax
80108f16:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108f19:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108f1c:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108f22:	e8 5d 99 ff ff       	call   80102884 <kalloc>
80108f27:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f2a:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f2f:	05 00 28 00 00       	add    $0x2800,%eax
80108f34:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108f37:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f3c:	05 04 28 00 00       	add    $0x2804,%eax
80108f41:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108f44:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f49:	05 08 28 00 00       	add    $0x2808,%eax
80108f4e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f51:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f56:	05 10 28 00 00       	add    $0x2810,%eax
80108f5b:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f5e:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80108f63:	05 18 28 00 00       	add    $0x2818,%eax
80108f68:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108f6b:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108f6e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108f74:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108f77:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108f79:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108f7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108f82:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108f85:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108f8b:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108f8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108f94:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108f97:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108f9d:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108fa0:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108fa3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108faa:	eb 73                	jmp    8010901f <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80108fac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108faf:	c1 e0 04             	shl    $0x4,%eax
80108fb2:	89 c2                	mov    %eax,%edx
80108fb4:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fb7:	01 d0                	add    %edx,%eax
80108fb9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108fc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fc3:	c1 e0 04             	shl    $0x4,%eax
80108fc6:	89 c2                	mov    %eax,%edx
80108fc8:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fcb:	01 d0                	add    %edx,%eax
80108fcd:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108fd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fd6:	c1 e0 04             	shl    $0x4,%eax
80108fd9:	89 c2                	mov    %eax,%edx
80108fdb:	8b 45 98             	mov    -0x68(%ebp),%eax
80108fde:	01 d0                	add    %edx,%eax
80108fe0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108fe6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fe9:	c1 e0 04             	shl    $0x4,%eax
80108fec:	89 c2                	mov    %eax,%edx
80108fee:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ff1:	01 d0                	add    %edx,%eax
80108ff3:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108ff7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ffa:	c1 e0 04             	shl    $0x4,%eax
80108ffd:	89 c2                	mov    %eax,%edx
80108fff:	8b 45 98             	mov    -0x68(%ebp),%eax
80109002:	01 d0                	add    %edx,%eax
80109004:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109008:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010900b:	c1 e0 04             	shl    $0x4,%eax
8010900e:	89 c2                	mov    %eax,%edx
80109010:	8b 45 98             	mov    -0x68(%ebp),%eax
80109013:	01 d0                	add    %edx,%eax
80109015:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010901b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010901f:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80109026:	7e 84                	jle    80108fac <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109028:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010902f:	eb 57                	jmp    80109088 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80109031:	e8 4e 98 ff ff       	call   80102884 <kalloc>
80109036:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109039:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
8010903d:	75 12                	jne    80109051 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
8010903f:	83 ec 0c             	sub    $0xc,%esp
80109042:	68 78 c8 10 80       	push   $0x8010c878
80109047:	e8 c0 73 ff ff       	call   8010040c <cprintf>
8010904c:	83 c4 10             	add    $0x10,%esp
      break;
8010904f:	eb 3d                	jmp    8010908e <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109051:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109054:	c1 e0 04             	shl    $0x4,%eax
80109057:	89 c2                	mov    %eax,%edx
80109059:	8b 45 98             	mov    -0x68(%ebp),%eax
8010905c:	01 d0                	add    %edx,%eax
8010905e:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109061:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109067:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109069:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010906c:	83 c0 01             	add    $0x1,%eax
8010906f:	c1 e0 04             	shl    $0x4,%eax
80109072:	89 c2                	mov    %eax,%edx
80109074:	8b 45 98             	mov    -0x68(%ebp),%eax
80109077:	01 d0                	add    %edx,%eax
80109079:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010907c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109082:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109084:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80109088:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
8010908c:	7e a3                	jle    80109031 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
8010908e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109091:	8b 00                	mov    (%eax),%eax
80109093:	83 c8 02             	or     $0x2,%eax
80109096:	89 c2                	mov    %eax,%edx
80109098:	8b 45 b4             	mov    -0x4c(%ebp),%eax
8010909b:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
8010909d:	83 ec 0c             	sub    $0xc,%esp
801090a0:	68 98 c8 10 80       	push   $0x8010c898
801090a5:	e8 62 73 ff ff       	call   8010040c <cprintf>
801090aa:	83 c4 10             	add    $0x10,%esp
}
801090ad:	90                   	nop
801090ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
801090b1:	5b                   	pop    %ebx
801090b2:	5e                   	pop    %esi
801090b3:	5f                   	pop    %edi
801090b4:	5d                   	pop    %ebp
801090b5:	c3                   	ret    

801090b6 <i8254_init_send>:

void i8254_init_send(){
801090b6:	f3 0f 1e fb          	endbr32 
801090ba:	55                   	push   %ebp
801090bb:	89 e5                	mov    %esp,%ebp
801090bd:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801090c0:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801090c5:	05 28 38 00 00       	add    $0x3828,%eax
801090ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801090cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090d0:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801090d6:	e8 a9 97 ff ff       	call   80102884 <kalloc>
801090db:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801090de:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801090e3:	05 00 38 00 00       	add    $0x3800,%eax
801090e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801090eb:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801090f0:	05 04 38 00 00       	add    $0x3804,%eax
801090f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801090f8:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801090fd:	05 08 38 00 00       	add    $0x3808,%eax
80109102:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80109105:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109108:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010910e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109111:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109113:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109116:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
8010911c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010911f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80109125:	a1 b4 84 19 80       	mov    0x801984b4,%eax
8010912a:	05 10 38 00 00       	add    $0x3810,%eax
8010912f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109132:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80109137:	05 18 38 00 00       	add    $0x3818,%eax
8010913c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
8010913f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109142:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80109148:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010914b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109151:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109154:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109157:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010915e:	e9 82 00 00 00       	jmp    801091e5 <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
80109163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109166:	c1 e0 04             	shl    $0x4,%eax
80109169:	89 c2                	mov    %eax,%edx
8010916b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010916e:	01 d0                	add    %edx,%eax
80109170:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80109177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917a:	c1 e0 04             	shl    $0x4,%eax
8010917d:	89 c2                	mov    %eax,%edx
8010917f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109182:	01 d0                	add    %edx,%eax
80109184:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
8010918a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010918d:	c1 e0 04             	shl    $0x4,%eax
80109190:	89 c2                	mov    %eax,%edx
80109192:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109195:	01 d0                	add    %edx,%eax
80109197:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
8010919b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010919e:	c1 e0 04             	shl    $0x4,%eax
801091a1:	89 c2                	mov    %eax,%edx
801091a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091a6:	01 d0                	add    %edx,%eax
801091a8:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801091ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091af:	c1 e0 04             	shl    $0x4,%eax
801091b2:	89 c2                	mov    %eax,%edx
801091b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091b7:	01 d0                	add    %edx,%eax
801091b9:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801091bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c0:	c1 e0 04             	shl    $0x4,%eax
801091c3:	89 c2                	mov    %eax,%edx
801091c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091c8:	01 d0                	add    %edx,%eax
801091ca:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801091ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d1:	c1 e0 04             	shl    $0x4,%eax
801091d4:	89 c2                	mov    %eax,%edx
801091d6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801091d9:	01 d0                	add    %edx,%eax
801091db:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801091e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091e5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801091ec:	0f 8e 71 ff ff ff    	jle    80109163 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801091f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801091f9:	eb 57                	jmp    80109252 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
801091fb:	e8 84 96 ff ff       	call   80102884 <kalloc>
80109200:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109203:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80109207:	75 12                	jne    8010921b <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80109209:	83 ec 0c             	sub    $0xc,%esp
8010920c:	68 78 c8 10 80       	push   $0x8010c878
80109211:	e8 f6 71 ff ff       	call   8010040c <cprintf>
80109216:	83 c4 10             	add    $0x10,%esp
      break;
80109219:	eb 3d                	jmp    80109258 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010921b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010921e:	c1 e0 04             	shl    $0x4,%eax
80109221:	89 c2                	mov    %eax,%edx
80109223:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109226:	01 d0                	add    %edx,%eax
80109228:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010922b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109231:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109233:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109236:	83 c0 01             	add    $0x1,%eax
80109239:	c1 e0 04             	shl    $0x4,%eax
8010923c:	89 c2                	mov    %eax,%edx
8010923e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109241:	01 d0                	add    %edx,%eax
80109243:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109246:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010924c:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010924e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109252:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80109256:	7e a3                	jle    801091fb <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109258:	a1 b4 84 19 80       	mov    0x801984b4,%eax
8010925d:	05 00 04 00 00       	add    $0x400,%eax
80109262:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80109265:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109268:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
8010926e:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80109273:	05 10 04 00 00       	add    $0x410,%eax
80109278:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
8010927b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010927e:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80109284:	83 ec 0c             	sub    $0xc,%esp
80109287:	68 b8 c8 10 80       	push   $0x8010c8b8
8010928c:	e8 7b 71 ff ff       	call   8010040c <cprintf>
80109291:	83 c4 10             	add    $0x10,%esp

}
80109294:	90                   	nop
80109295:	c9                   	leave  
80109296:	c3                   	ret    

80109297 <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80109297:	f3 0f 1e fb          	endbr32 
8010929b:	55                   	push   %ebp
8010929c:	89 e5                	mov    %esp,%ebp
8010929e:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801092a1:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801092a6:	83 c0 14             	add    $0x14,%eax
801092a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801092ac:	8b 45 08             	mov    0x8(%ebp),%eax
801092af:	c1 e0 08             	shl    $0x8,%eax
801092b2:	0f b7 c0             	movzwl %ax,%eax
801092b5:	83 c8 01             	or     $0x1,%eax
801092b8:	89 c2                	mov    %eax,%edx
801092ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092bd:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801092bf:	83 ec 0c             	sub    $0xc,%esp
801092c2:	68 d8 c8 10 80       	push   $0x8010c8d8
801092c7:	e8 40 71 ff ff       	call   8010040c <cprintf>
801092cc:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801092cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d2:	8b 00                	mov    (%eax),%eax
801092d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801092d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092da:	83 e0 10             	and    $0x10,%eax
801092dd:	85 c0                	test   %eax,%eax
801092df:	75 02                	jne    801092e3 <i8254_read_eeprom+0x4c>
  while(1){
801092e1:	eb dc                	jmp    801092bf <i8254_read_eeprom+0x28>
      break;
801092e3:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801092e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092e7:	8b 00                	mov    (%eax),%eax
801092e9:	c1 e8 10             	shr    $0x10,%eax
}
801092ec:	c9                   	leave  
801092ed:	c3                   	ret    

801092ee <i8254_recv>:
void i8254_recv(){
801092ee:	f3 0f 1e fb          	endbr32 
801092f2:	55                   	push   %ebp
801092f3:	89 e5                	mov    %esp,%ebp
801092f5:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801092f8:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801092fd:	05 10 28 00 00       	add    $0x2810,%eax
80109302:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109305:	a1 b4 84 19 80       	mov    0x801984b4,%eax
8010930a:	05 18 28 00 00       	add    $0x2818,%eax
8010930f:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109312:	a1 b4 84 19 80       	mov    0x801984b4,%eax
80109317:	05 00 28 00 00       	add    $0x2800,%eax
8010931c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
8010931f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109322:	8b 00                	mov    (%eax),%eax
80109324:	05 00 00 00 80       	add    $0x80000000,%eax
80109329:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
8010932c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010932f:	8b 10                	mov    (%eax),%edx
80109331:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109334:	8b 00                	mov    (%eax),%eax
80109336:	29 c2                	sub    %eax,%edx
80109338:	89 d0                	mov    %edx,%eax
8010933a:	25 ff 00 00 00       	and    $0xff,%eax
8010933f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109342:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109346:	7e 37                	jle    8010937f <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109348:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010934b:	8b 00                	mov    (%eax),%eax
8010934d:	c1 e0 04             	shl    $0x4,%eax
80109350:	89 c2                	mov    %eax,%edx
80109352:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109355:	01 d0                	add    %edx,%eax
80109357:	8b 00                	mov    (%eax),%eax
80109359:	05 00 00 00 80       	add    $0x80000000,%eax
8010935e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109361:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109364:	8b 00                	mov    (%eax),%eax
80109366:	83 c0 01             	add    $0x1,%eax
80109369:	0f b6 d0             	movzbl %al,%edx
8010936c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010936f:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109371:	83 ec 0c             	sub    $0xc,%esp
80109374:	ff 75 e0             	pushl  -0x20(%ebp)
80109377:	e8 47 09 00 00       	call   80109cc3 <eth_proc>
8010937c:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
8010937f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109382:	8b 10                	mov    (%eax),%edx
80109384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109387:	8b 00                	mov    (%eax),%eax
80109389:	39 c2                	cmp    %eax,%edx
8010938b:	75 9f                	jne    8010932c <i8254_recv+0x3e>
      (*rdt)--;
8010938d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109390:	8b 00                	mov    (%eax),%eax
80109392:	8d 50 ff             	lea    -0x1(%eax),%edx
80109395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109398:	89 10                	mov    %edx,(%eax)
  while(1){
8010939a:	eb 90                	jmp    8010932c <i8254_recv+0x3e>

8010939c <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
8010939c:	f3 0f 1e fb          	endbr32 
801093a0:	55                   	push   %ebp
801093a1:	89 e5                	mov    %esp,%ebp
801093a3:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801093a6:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801093ab:	05 10 38 00 00       	add    $0x3810,%eax
801093b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801093b3:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801093b8:	05 18 38 00 00       	add    $0x3818,%eax
801093bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801093c0:	a1 b4 84 19 80       	mov    0x801984b4,%eax
801093c5:	05 00 38 00 00       	add    $0x3800,%eax
801093ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801093cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093d0:	8b 00                	mov    (%eax),%eax
801093d2:	05 00 00 00 80       	add    $0x80000000,%eax
801093d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801093da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093dd:	8b 10                	mov    (%eax),%edx
801093df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093e2:	8b 00                	mov    (%eax),%eax
801093e4:	29 c2                	sub    %eax,%edx
801093e6:	89 d0                	mov    %edx,%eax
801093e8:	0f b6 c0             	movzbl %al,%eax
801093eb:	ba 00 01 00 00       	mov    $0x100,%edx
801093f0:	29 c2                	sub    %eax,%edx
801093f2:	89 d0                	mov    %edx,%eax
801093f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801093f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093fa:	8b 00                	mov    (%eax),%eax
801093fc:	25 ff 00 00 00       	and    $0xff,%eax
80109401:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80109404:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109408:	0f 8e a8 00 00 00    	jle    801094b6 <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
8010940e:	8b 45 08             	mov    0x8(%ebp),%eax
80109411:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109414:	89 d1                	mov    %edx,%ecx
80109416:	c1 e1 04             	shl    $0x4,%ecx
80109419:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010941c:	01 ca                	add    %ecx,%edx
8010941e:	8b 12                	mov    (%edx),%edx
80109420:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109426:	83 ec 04             	sub    $0x4,%esp
80109429:	ff 75 0c             	pushl  0xc(%ebp)
8010942c:	50                   	push   %eax
8010942d:	52                   	push   %edx
8010942e:	e8 11 bc ff ff       	call   80105044 <memmove>
80109433:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80109436:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109439:	c1 e0 04             	shl    $0x4,%eax
8010943c:	89 c2                	mov    %eax,%edx
8010943e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109441:	01 d0                	add    %edx,%eax
80109443:	8b 55 0c             	mov    0xc(%ebp),%edx
80109446:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
8010944a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010944d:	c1 e0 04             	shl    $0x4,%eax
80109450:	89 c2                	mov    %eax,%edx
80109452:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109455:	01 d0                	add    %edx,%eax
80109457:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
8010945b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010945e:	c1 e0 04             	shl    $0x4,%eax
80109461:	89 c2                	mov    %eax,%edx
80109463:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109466:	01 d0                	add    %edx,%eax
80109468:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
8010946c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010946f:	c1 e0 04             	shl    $0x4,%eax
80109472:	89 c2                	mov    %eax,%edx
80109474:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109477:	01 d0                	add    %edx,%eax
80109479:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
8010947d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109480:	c1 e0 04             	shl    $0x4,%eax
80109483:	89 c2                	mov    %eax,%edx
80109485:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109488:	01 d0                	add    %edx,%eax
8010948a:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109490:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109493:	c1 e0 04             	shl    $0x4,%eax
80109496:	89 c2                	mov    %eax,%edx
80109498:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010949b:	01 d0                	add    %edx,%eax
8010949d:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801094a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094a4:	8b 00                	mov    (%eax),%eax
801094a6:	83 c0 01             	add    $0x1,%eax
801094a9:	0f b6 d0             	movzbl %al,%edx
801094ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094af:	89 10                	mov    %edx,(%eax)
    return len;
801094b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801094b4:	eb 05                	jmp    801094bb <i8254_send+0x11f>
  }else{
    return -1;
801094b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801094bb:	c9                   	leave  
801094bc:	c3                   	ret    

801094bd <i8254_intr>:

void i8254_intr(){
801094bd:	f3 0f 1e fb          	endbr32 
801094c1:	55                   	push   %ebp
801094c2:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801094c4:	a1 b8 84 19 80       	mov    0x801984b8,%eax
801094c9:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801094cf:	90                   	nop
801094d0:	5d                   	pop    %ebp
801094d1:	c3                   	ret    

801094d2 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801094d2:	f3 0f 1e fb          	endbr32 
801094d6:	55                   	push   %ebp
801094d7:	89 e5                	mov    %esp,%ebp
801094d9:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801094dc:	8b 45 08             	mov    0x8(%ebp),%eax
801094df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801094e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e5:	0f b7 00             	movzwl (%eax),%eax
801094e8:	66 3d 00 01          	cmp    $0x100,%ax
801094ec:	74 0a                	je     801094f8 <arp_proc+0x26>
801094ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801094f3:	e9 4f 01 00 00       	jmp    80109647 <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801094f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094fb:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801094ff:	66 83 f8 08          	cmp    $0x8,%ax
80109503:	74 0a                	je     8010950f <arp_proc+0x3d>
80109505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010950a:	e9 38 01 00 00       	jmp    80109647 <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
8010950f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109512:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109516:	3c 06                	cmp    $0x6,%al
80109518:	74 0a                	je     80109524 <arp_proc+0x52>
8010951a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010951f:	e9 23 01 00 00       	jmp    80109647 <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109527:	0f b6 40 05          	movzbl 0x5(%eax),%eax
8010952b:	3c 04                	cmp    $0x4,%al
8010952d:	74 0a                	je     80109539 <arp_proc+0x67>
8010952f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109534:	e9 0e 01 00 00       	jmp    80109647 <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010953c:	83 c0 18             	add    $0x18,%eax
8010953f:	83 ec 04             	sub    $0x4,%esp
80109542:	6a 04                	push   $0x4
80109544:	50                   	push   %eax
80109545:	68 04 f5 10 80       	push   $0x8010f504
8010954a:	e8 99 ba ff ff       	call   80104fe8 <memcmp>
8010954f:	83 c4 10             	add    $0x10,%esp
80109552:	85 c0                	test   %eax,%eax
80109554:	74 27                	je     8010957d <arp_proc+0xab>
80109556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109559:	83 c0 0e             	add    $0xe,%eax
8010955c:	83 ec 04             	sub    $0x4,%esp
8010955f:	6a 04                	push   $0x4
80109561:	50                   	push   %eax
80109562:	68 04 f5 10 80       	push   $0x8010f504
80109567:	e8 7c ba ff ff       	call   80104fe8 <memcmp>
8010956c:	83 c4 10             	add    $0x10,%esp
8010956f:	85 c0                	test   %eax,%eax
80109571:	74 0a                	je     8010957d <arp_proc+0xab>
80109573:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109578:	e9 ca 00 00 00       	jmp    80109647 <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
8010957d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109580:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109584:	66 3d 00 01          	cmp    $0x100,%ax
80109588:	75 69                	jne    801095f3 <arp_proc+0x121>
8010958a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010958d:	83 c0 18             	add    $0x18,%eax
80109590:	83 ec 04             	sub    $0x4,%esp
80109593:	6a 04                	push   $0x4
80109595:	50                   	push   %eax
80109596:	68 04 f5 10 80       	push   $0x8010f504
8010959b:	e8 48 ba ff ff       	call   80104fe8 <memcmp>
801095a0:	83 c4 10             	add    $0x10,%esp
801095a3:	85 c0                	test   %eax,%eax
801095a5:	75 4c                	jne    801095f3 <arp_proc+0x121>
    uint send = (uint)kalloc();
801095a7:	e8 d8 92 ff ff       	call   80102884 <kalloc>
801095ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801095af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801095b6:	83 ec 04             	sub    $0x4,%esp
801095b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801095bc:	50                   	push   %eax
801095bd:	ff 75 f0             	pushl  -0x10(%ebp)
801095c0:	ff 75 f4             	pushl  -0xc(%ebp)
801095c3:	e8 33 04 00 00       	call   801099fb <arp_reply_pkt_create>
801095c8:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801095cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095ce:	83 ec 08             	sub    $0x8,%esp
801095d1:	50                   	push   %eax
801095d2:	ff 75 f0             	pushl  -0x10(%ebp)
801095d5:	e8 c2 fd ff ff       	call   8010939c <i8254_send>
801095da:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
801095dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e0:	83 ec 0c             	sub    $0xc,%esp
801095e3:	50                   	push   %eax
801095e4:	e8 fd 91 ff ff       	call   801027e6 <kfree>
801095e9:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
801095ec:	b8 02 00 00 00       	mov    $0x2,%eax
801095f1:	eb 54                	jmp    80109647 <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801095f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095f6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801095fa:	66 3d 00 02          	cmp    $0x200,%ax
801095fe:	75 42                	jne    80109642 <arp_proc+0x170>
80109600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109603:	83 c0 18             	add    $0x18,%eax
80109606:	83 ec 04             	sub    $0x4,%esp
80109609:	6a 04                	push   $0x4
8010960b:	50                   	push   %eax
8010960c:	68 04 f5 10 80       	push   $0x8010f504
80109611:	e8 d2 b9 ff ff       	call   80104fe8 <memcmp>
80109616:	83 c4 10             	add    $0x10,%esp
80109619:	85 c0                	test   %eax,%eax
8010961b:	75 25                	jne    80109642 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
8010961d:	83 ec 0c             	sub    $0xc,%esp
80109620:	68 dc c8 10 80       	push   $0x8010c8dc
80109625:	e8 e2 6d ff ff       	call   8010040c <cprintf>
8010962a:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010962d:	83 ec 0c             	sub    $0xc,%esp
80109630:	ff 75 f4             	pushl  -0xc(%ebp)
80109633:	e8 b7 01 00 00       	call   801097ef <arp_table_update>
80109638:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
8010963b:	b8 01 00 00 00       	mov    $0x1,%eax
80109640:	eb 05                	jmp    80109647 <arp_proc+0x175>
  }else{
    return -1;
80109642:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109647:	c9                   	leave  
80109648:	c3                   	ret    

80109649 <arp_scan>:

void arp_scan(){
80109649:	f3 0f 1e fb          	endbr32 
8010964d:	55                   	push   %ebp
8010964e:	89 e5                	mov    %esp,%ebp
80109650:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109653:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010965a:	eb 6f                	jmp    801096cb <arp_scan+0x82>
    uint send = (uint)kalloc();
8010965c:	e8 23 92 ff ff       	call   80102884 <kalloc>
80109661:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109664:	83 ec 04             	sub    $0x4,%esp
80109667:	ff 75 f4             	pushl  -0xc(%ebp)
8010966a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010966d:	50                   	push   %eax
8010966e:	ff 75 ec             	pushl  -0x14(%ebp)
80109671:	e8 62 00 00 00       	call   801096d8 <arp_broadcast>
80109676:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109679:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010967c:	83 ec 08             	sub    $0x8,%esp
8010967f:	50                   	push   %eax
80109680:	ff 75 ec             	pushl  -0x14(%ebp)
80109683:	e8 14 fd ff ff       	call   8010939c <i8254_send>
80109688:	83 c4 10             	add    $0x10,%esp
8010968b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
8010968e:	eb 22                	jmp    801096b2 <arp_scan+0x69>
      microdelay(1);
80109690:	83 ec 0c             	sub    $0xc,%esp
80109693:	6a 01                	push   $0x1
80109695:	e8 9c 95 ff ff       	call   80102c36 <microdelay>
8010969a:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
8010969d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096a0:	83 ec 08             	sub    $0x8,%esp
801096a3:	50                   	push   %eax
801096a4:	ff 75 ec             	pushl  -0x14(%ebp)
801096a7:	e8 f0 fc ff ff       	call   8010939c <i8254_send>
801096ac:	83 c4 10             	add    $0x10,%esp
801096af:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801096b2:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801096b6:	74 d8                	je     80109690 <arp_scan+0x47>
    }
    kfree((char *)send);
801096b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801096bb:	83 ec 0c             	sub    $0xc,%esp
801096be:	50                   	push   %eax
801096bf:	e8 22 91 ff ff       	call   801027e6 <kfree>
801096c4:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801096c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801096cb:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801096d2:	7e 88                	jle    8010965c <arp_scan+0x13>
  }
}
801096d4:	90                   	nop
801096d5:	90                   	nop
801096d6:	c9                   	leave  
801096d7:	c3                   	ret    

801096d8 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
801096d8:	f3 0f 1e fb          	endbr32 
801096dc:	55                   	push   %ebp
801096dd:	89 e5                	mov    %esp,%ebp
801096df:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
801096e2:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
801096e6:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
801096ea:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
801096ee:	8b 45 10             	mov    0x10(%ebp),%eax
801096f1:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
801096f4:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
801096fb:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109701:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109708:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010970e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109711:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109717:	8b 45 08             	mov    0x8(%ebp),%eax
8010971a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010971d:	8b 45 08             	mov    0x8(%ebp),%eax
80109720:	83 c0 0e             	add    $0xe,%eax
80109723:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109729:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010972d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109730:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109737:	83 ec 04             	sub    $0x4,%esp
8010973a:	6a 06                	push   $0x6
8010973c:	8d 55 e6             	lea    -0x1a(%ebp),%edx
8010973f:	52                   	push   %edx
80109740:	50                   	push   %eax
80109741:	e8 fe b8 ff ff       	call   80105044 <memmove>
80109746:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010974c:	83 c0 06             	add    $0x6,%eax
8010974f:	83 ec 04             	sub    $0x4,%esp
80109752:	6a 06                	push   $0x6
80109754:	68 68 d0 18 80       	push   $0x8018d068
80109759:	50                   	push   %eax
8010975a:	e8 e5 b8 ff ff       	call   80105044 <memmove>
8010975f:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109762:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109765:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010976a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010976d:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109773:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109776:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010977a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010977d:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109781:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109784:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
8010978a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010978d:	8d 50 12             	lea    0x12(%eax),%edx
80109790:	83 ec 04             	sub    $0x4,%esp
80109793:	6a 06                	push   $0x6
80109795:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109798:	50                   	push   %eax
80109799:	52                   	push   %edx
8010979a:	e8 a5 b8 ff ff       	call   80105044 <memmove>
8010979f:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801097a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a5:	8d 50 18             	lea    0x18(%eax),%edx
801097a8:	83 ec 04             	sub    $0x4,%esp
801097ab:	6a 04                	push   $0x4
801097ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
801097b0:	50                   	push   %eax
801097b1:	52                   	push   %edx
801097b2:	e8 8d b8 ff ff       	call   80105044 <memmove>
801097b7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801097ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097bd:	83 c0 08             	add    $0x8,%eax
801097c0:	83 ec 04             	sub    $0x4,%esp
801097c3:	6a 06                	push   $0x6
801097c5:	68 68 d0 18 80       	push   $0x8018d068
801097ca:	50                   	push   %eax
801097cb:	e8 74 b8 ff ff       	call   80105044 <memmove>
801097d0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801097d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097d6:	83 c0 0e             	add    $0xe,%eax
801097d9:	83 ec 04             	sub    $0x4,%esp
801097dc:	6a 04                	push   $0x4
801097de:	68 04 f5 10 80       	push   $0x8010f504
801097e3:	50                   	push   %eax
801097e4:	e8 5b b8 ff ff       	call   80105044 <memmove>
801097e9:	83 c4 10             	add    $0x10,%esp
}
801097ec:	90                   	nop
801097ed:	c9                   	leave  
801097ee:	c3                   	ret    

801097ef <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
801097ef:	f3 0f 1e fb          	endbr32 
801097f3:	55                   	push   %ebp
801097f4:	89 e5                	mov    %esp,%ebp
801097f6:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
801097f9:	8b 45 08             	mov    0x8(%ebp),%eax
801097fc:	83 c0 0e             	add    $0xe,%eax
801097ff:	83 ec 0c             	sub    $0xc,%esp
80109802:	50                   	push   %eax
80109803:	e8 bc 00 00 00       	call   801098c4 <arp_table_search>
80109808:	83 c4 10             	add    $0x10,%esp
8010980b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010980e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109812:	78 2d                	js     80109841 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109814:	8b 45 08             	mov    0x8(%ebp),%eax
80109817:	8d 48 08             	lea    0x8(%eax),%ecx
8010981a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010981d:	89 d0                	mov    %edx,%eax
8010981f:	c1 e0 02             	shl    $0x2,%eax
80109822:	01 d0                	add    %edx,%eax
80109824:	01 c0                	add    %eax,%eax
80109826:	01 d0                	add    %edx,%eax
80109828:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010982d:	83 c0 04             	add    $0x4,%eax
80109830:	83 ec 04             	sub    $0x4,%esp
80109833:	6a 06                	push   $0x6
80109835:	51                   	push   %ecx
80109836:	50                   	push   %eax
80109837:	e8 08 b8 ff ff       	call   80105044 <memmove>
8010983c:	83 c4 10             	add    $0x10,%esp
8010983f:	eb 70                	jmp    801098b1 <arp_table_update+0xc2>
  }else{
    index += 1;
80109841:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109845:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109848:	8b 45 08             	mov    0x8(%ebp),%eax
8010984b:	8d 48 08             	lea    0x8(%eax),%ecx
8010984e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109851:	89 d0                	mov    %edx,%eax
80109853:	c1 e0 02             	shl    $0x2,%eax
80109856:	01 d0                	add    %edx,%eax
80109858:	01 c0                	add    %eax,%eax
8010985a:	01 d0                	add    %edx,%eax
8010985c:	05 80 d0 18 80       	add    $0x8018d080,%eax
80109861:	83 c0 04             	add    $0x4,%eax
80109864:	83 ec 04             	sub    $0x4,%esp
80109867:	6a 06                	push   $0x6
80109869:	51                   	push   %ecx
8010986a:	50                   	push   %eax
8010986b:	e8 d4 b7 ff ff       	call   80105044 <memmove>
80109870:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109873:	8b 45 08             	mov    0x8(%ebp),%eax
80109876:	8d 48 0e             	lea    0xe(%eax),%ecx
80109879:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010987c:	89 d0                	mov    %edx,%eax
8010987e:	c1 e0 02             	shl    $0x2,%eax
80109881:	01 d0                	add    %edx,%eax
80109883:	01 c0                	add    %eax,%eax
80109885:	01 d0                	add    %edx,%eax
80109887:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010988c:	83 ec 04             	sub    $0x4,%esp
8010988f:	6a 04                	push   $0x4
80109891:	51                   	push   %ecx
80109892:	50                   	push   %eax
80109893:	e8 ac b7 ff ff       	call   80105044 <memmove>
80109898:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010989b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010989e:	89 d0                	mov    %edx,%eax
801098a0:	c1 e0 02             	shl    $0x2,%eax
801098a3:	01 d0                	add    %edx,%eax
801098a5:	01 c0                	add    %eax,%eax
801098a7:	01 d0                	add    %edx,%eax
801098a9:	05 8a d0 18 80       	add    $0x8018d08a,%eax
801098ae:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801098b1:	83 ec 0c             	sub    $0xc,%esp
801098b4:	68 80 d0 18 80       	push   $0x8018d080
801098b9:	e8 87 00 00 00       	call   80109945 <print_arp_table>
801098be:	83 c4 10             	add    $0x10,%esp
}
801098c1:	90                   	nop
801098c2:	c9                   	leave  
801098c3:	c3                   	ret    

801098c4 <arp_table_search>:

int arp_table_search(uchar *ip){
801098c4:	f3 0f 1e fb          	endbr32 
801098c8:	55                   	push   %ebp
801098c9:	89 e5                	mov    %esp,%ebp
801098cb:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801098ce:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801098d5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801098dc:	eb 59                	jmp    80109937 <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801098de:	8b 55 f0             	mov    -0x10(%ebp),%edx
801098e1:	89 d0                	mov    %edx,%eax
801098e3:	c1 e0 02             	shl    $0x2,%eax
801098e6:	01 d0                	add    %edx,%eax
801098e8:	01 c0                	add    %eax,%eax
801098ea:	01 d0                	add    %edx,%eax
801098ec:	05 80 d0 18 80       	add    $0x8018d080,%eax
801098f1:	83 ec 04             	sub    $0x4,%esp
801098f4:	6a 04                	push   $0x4
801098f6:	ff 75 08             	pushl  0x8(%ebp)
801098f9:	50                   	push   %eax
801098fa:	e8 e9 b6 ff ff       	call   80104fe8 <memcmp>
801098ff:	83 c4 10             	add    $0x10,%esp
80109902:	85 c0                	test   %eax,%eax
80109904:	75 05                	jne    8010990b <arp_table_search+0x47>
      return i;
80109906:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109909:	eb 38                	jmp    80109943 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010990b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010990e:	89 d0                	mov    %edx,%eax
80109910:	c1 e0 02             	shl    $0x2,%eax
80109913:	01 d0                	add    %edx,%eax
80109915:	01 c0                	add    %eax,%eax
80109917:	01 d0                	add    %edx,%eax
80109919:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010991e:	0f b6 00             	movzbl (%eax),%eax
80109921:	84 c0                	test   %al,%al
80109923:	75 0e                	jne    80109933 <arp_table_search+0x6f>
80109925:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109929:	75 08                	jne    80109933 <arp_table_search+0x6f>
      empty = -i;
8010992b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010992e:	f7 d8                	neg    %eax
80109930:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109933:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109937:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010993b:	7e a1                	jle    801098de <arp_table_search+0x1a>
    }
  }
  return empty-1;
8010993d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109940:	83 e8 01             	sub    $0x1,%eax
}
80109943:	c9                   	leave  
80109944:	c3                   	ret    

80109945 <print_arp_table>:

void print_arp_table(){
80109945:	f3 0f 1e fb          	endbr32 
80109949:	55                   	push   %ebp
8010994a:	89 e5                	mov    %esp,%ebp
8010994c:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010994f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109956:	e9 92 00 00 00       	jmp    801099ed <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
8010995b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010995e:	89 d0                	mov    %edx,%eax
80109960:	c1 e0 02             	shl    $0x2,%eax
80109963:	01 d0                	add    %edx,%eax
80109965:	01 c0                	add    %eax,%eax
80109967:	01 d0                	add    %edx,%eax
80109969:	05 8a d0 18 80       	add    $0x8018d08a,%eax
8010996e:	0f b6 00             	movzbl (%eax),%eax
80109971:	84 c0                	test   %al,%al
80109973:	74 74                	je     801099e9 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109975:	83 ec 08             	sub    $0x8,%esp
80109978:	ff 75 f4             	pushl  -0xc(%ebp)
8010997b:	68 ef c8 10 80       	push   $0x8010c8ef
80109980:	e8 87 6a ff ff       	call   8010040c <cprintf>
80109985:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109988:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010998b:	89 d0                	mov    %edx,%eax
8010998d:	c1 e0 02             	shl    $0x2,%eax
80109990:	01 d0                	add    %edx,%eax
80109992:	01 c0                	add    %eax,%eax
80109994:	01 d0                	add    %edx,%eax
80109996:	05 80 d0 18 80       	add    $0x8018d080,%eax
8010999b:	83 ec 0c             	sub    $0xc,%esp
8010999e:	50                   	push   %eax
8010999f:	e8 5c 02 00 00       	call   80109c00 <print_ipv4>
801099a4:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801099a7:	83 ec 0c             	sub    $0xc,%esp
801099aa:	68 fe c8 10 80       	push   $0x8010c8fe
801099af:	e8 58 6a ff ff       	call   8010040c <cprintf>
801099b4:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801099b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099ba:	89 d0                	mov    %edx,%eax
801099bc:	c1 e0 02             	shl    $0x2,%eax
801099bf:	01 d0                	add    %edx,%eax
801099c1:	01 c0                	add    %eax,%eax
801099c3:	01 d0                	add    %edx,%eax
801099c5:	05 80 d0 18 80       	add    $0x8018d080,%eax
801099ca:	83 c0 04             	add    $0x4,%eax
801099cd:	83 ec 0c             	sub    $0xc,%esp
801099d0:	50                   	push   %eax
801099d1:	e8 7c 02 00 00       	call   80109c52 <print_mac>
801099d6:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801099d9:	83 ec 0c             	sub    $0xc,%esp
801099dc:	68 00 c9 10 80       	push   $0x8010c900
801099e1:	e8 26 6a ff ff       	call   8010040c <cprintf>
801099e6:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801099e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801099ed:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801099f1:	0f 8e 64 ff ff ff    	jle    8010995b <print_arp_table+0x16>
    }
  }
}
801099f7:	90                   	nop
801099f8:	90                   	nop
801099f9:	c9                   	leave  
801099fa:	c3                   	ret    

801099fb <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801099fb:	f3 0f 1e fb          	endbr32 
801099ff:	55                   	push   %ebp
80109a00:	89 e5                	mov    %esp,%ebp
80109a02:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109a05:	8b 45 10             	mov    0x10(%ebp),%eax
80109a08:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109a14:	8b 45 0c             	mov    0xc(%ebp),%eax
80109a17:	83 c0 0e             	add    $0xe,%eax
80109a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a20:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a27:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80109a2e:	8d 50 08             	lea    0x8(%eax),%edx
80109a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a34:	83 ec 04             	sub    $0x4,%esp
80109a37:	6a 06                	push   $0x6
80109a39:	52                   	push   %edx
80109a3a:	50                   	push   %eax
80109a3b:	e8 04 b6 ff ff       	call   80105044 <memmove>
80109a40:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a46:	83 c0 06             	add    $0x6,%eax
80109a49:	83 ec 04             	sub    $0x4,%esp
80109a4c:	6a 06                	push   $0x6
80109a4e:	68 68 d0 18 80       	push   $0x8018d068
80109a53:	50                   	push   %eax
80109a54:	e8 eb b5 ff ff       	call   80105044 <memmove>
80109a59:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a5f:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a67:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a70:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109a74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a77:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a7e:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109a84:	8b 45 08             	mov    0x8(%ebp),%eax
80109a87:	8d 50 08             	lea    0x8(%eax),%edx
80109a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a8d:	83 c0 12             	add    $0x12,%eax
80109a90:	83 ec 04             	sub    $0x4,%esp
80109a93:	6a 06                	push   $0x6
80109a95:	52                   	push   %edx
80109a96:	50                   	push   %eax
80109a97:	e8 a8 b5 ff ff       	call   80105044 <memmove>
80109a9c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80109aa2:	8d 50 0e             	lea    0xe(%eax),%edx
80109aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aa8:	83 c0 18             	add    $0x18,%eax
80109aab:	83 ec 04             	sub    $0x4,%esp
80109aae:	6a 04                	push   $0x4
80109ab0:	52                   	push   %edx
80109ab1:	50                   	push   %eax
80109ab2:	e8 8d b5 ff ff       	call   80105044 <memmove>
80109ab7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109abd:	83 c0 08             	add    $0x8,%eax
80109ac0:	83 ec 04             	sub    $0x4,%esp
80109ac3:	6a 06                	push   $0x6
80109ac5:	68 68 d0 18 80       	push   $0x8018d068
80109aca:	50                   	push   %eax
80109acb:	e8 74 b5 ff ff       	call   80105044 <memmove>
80109ad0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ad6:	83 c0 0e             	add    $0xe,%eax
80109ad9:	83 ec 04             	sub    $0x4,%esp
80109adc:	6a 04                	push   $0x4
80109ade:	68 04 f5 10 80       	push   $0x8010f504
80109ae3:	50                   	push   %eax
80109ae4:	e8 5b b5 ff ff       	call   80105044 <memmove>
80109ae9:	83 c4 10             	add    $0x10,%esp
}
80109aec:	90                   	nop
80109aed:	c9                   	leave  
80109aee:	c3                   	ret    

80109aef <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109aef:	f3 0f 1e fb          	endbr32 
80109af3:	55                   	push   %ebp
80109af4:	89 e5                	mov    %esp,%ebp
80109af6:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109af9:	83 ec 0c             	sub    $0xc,%esp
80109afc:	68 02 c9 10 80       	push   $0x8010c902
80109b01:	e8 06 69 ff ff       	call   8010040c <cprintf>
80109b06:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109b09:	8b 45 08             	mov    0x8(%ebp),%eax
80109b0c:	83 c0 0e             	add    $0xe,%eax
80109b0f:	83 ec 0c             	sub    $0xc,%esp
80109b12:	50                   	push   %eax
80109b13:	e8 e8 00 00 00       	call   80109c00 <print_ipv4>
80109b18:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b1b:	83 ec 0c             	sub    $0xc,%esp
80109b1e:	68 00 c9 10 80       	push   $0x8010c900
80109b23:	e8 e4 68 ff ff       	call   8010040c <cprintf>
80109b28:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b2e:	83 c0 08             	add    $0x8,%eax
80109b31:	83 ec 0c             	sub    $0xc,%esp
80109b34:	50                   	push   %eax
80109b35:	e8 18 01 00 00       	call   80109c52 <print_mac>
80109b3a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b3d:	83 ec 0c             	sub    $0xc,%esp
80109b40:	68 00 c9 10 80       	push   $0x8010c900
80109b45:	e8 c2 68 ff ff       	call   8010040c <cprintf>
80109b4a:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109b4d:	83 ec 0c             	sub    $0xc,%esp
80109b50:	68 19 c9 10 80       	push   $0x8010c919
80109b55:	e8 b2 68 ff ff       	call   8010040c <cprintf>
80109b5a:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80109b60:	83 c0 18             	add    $0x18,%eax
80109b63:	83 ec 0c             	sub    $0xc,%esp
80109b66:	50                   	push   %eax
80109b67:	e8 94 00 00 00       	call   80109c00 <print_ipv4>
80109b6c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b6f:	83 ec 0c             	sub    $0xc,%esp
80109b72:	68 00 c9 10 80       	push   $0x8010c900
80109b77:	e8 90 68 ff ff       	call   8010040c <cprintf>
80109b7c:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80109b82:	83 c0 12             	add    $0x12,%eax
80109b85:	83 ec 0c             	sub    $0xc,%esp
80109b88:	50                   	push   %eax
80109b89:	e8 c4 00 00 00       	call   80109c52 <print_mac>
80109b8e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109b91:	83 ec 0c             	sub    $0xc,%esp
80109b94:	68 00 c9 10 80       	push   $0x8010c900
80109b99:	e8 6e 68 ff ff       	call   8010040c <cprintf>
80109b9e:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109ba1:	83 ec 0c             	sub    $0xc,%esp
80109ba4:	68 30 c9 10 80       	push   $0x8010c930
80109ba9:	e8 5e 68 ff ff       	call   8010040c <cprintf>
80109bae:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80109bb4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109bb8:	66 3d 00 01          	cmp    $0x100,%ax
80109bbc:	75 12                	jne    80109bd0 <print_arp_info+0xe1>
80109bbe:	83 ec 0c             	sub    $0xc,%esp
80109bc1:	68 3c c9 10 80       	push   $0x8010c93c
80109bc6:	e8 41 68 ff ff       	call   8010040c <cprintf>
80109bcb:	83 c4 10             	add    $0x10,%esp
80109bce:	eb 1d                	jmp    80109bed <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd3:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109bd7:	66 3d 00 02          	cmp    $0x200,%ax
80109bdb:	75 10                	jne    80109bed <print_arp_info+0xfe>
    cprintf("Reply\n");
80109bdd:	83 ec 0c             	sub    $0xc,%esp
80109be0:	68 45 c9 10 80       	push   $0x8010c945
80109be5:	e8 22 68 ff ff       	call   8010040c <cprintf>
80109bea:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109bed:	83 ec 0c             	sub    $0xc,%esp
80109bf0:	68 00 c9 10 80       	push   $0x8010c900
80109bf5:	e8 12 68 ff ff       	call   8010040c <cprintf>
80109bfa:	83 c4 10             	add    $0x10,%esp
}
80109bfd:	90                   	nop
80109bfe:	c9                   	leave  
80109bff:	c3                   	ret    

80109c00 <print_ipv4>:

void print_ipv4(uchar *ip){
80109c00:	f3 0f 1e fb          	endbr32 
80109c04:	55                   	push   %ebp
80109c05:	89 e5                	mov    %esp,%ebp
80109c07:	53                   	push   %ebx
80109c08:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c0e:	83 c0 03             	add    $0x3,%eax
80109c11:	0f b6 00             	movzbl (%eax),%eax
80109c14:	0f b6 d8             	movzbl %al,%ebx
80109c17:	8b 45 08             	mov    0x8(%ebp),%eax
80109c1a:	83 c0 02             	add    $0x2,%eax
80109c1d:	0f b6 00             	movzbl (%eax),%eax
80109c20:	0f b6 c8             	movzbl %al,%ecx
80109c23:	8b 45 08             	mov    0x8(%ebp),%eax
80109c26:	83 c0 01             	add    $0x1,%eax
80109c29:	0f b6 00             	movzbl (%eax),%eax
80109c2c:	0f b6 d0             	movzbl %al,%edx
80109c2f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c32:	0f b6 00             	movzbl (%eax),%eax
80109c35:	0f b6 c0             	movzbl %al,%eax
80109c38:	83 ec 0c             	sub    $0xc,%esp
80109c3b:	53                   	push   %ebx
80109c3c:	51                   	push   %ecx
80109c3d:	52                   	push   %edx
80109c3e:	50                   	push   %eax
80109c3f:	68 4c c9 10 80       	push   $0x8010c94c
80109c44:	e8 c3 67 ff ff       	call   8010040c <cprintf>
80109c49:	83 c4 20             	add    $0x20,%esp
}
80109c4c:	90                   	nop
80109c4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109c50:	c9                   	leave  
80109c51:	c3                   	ret    

80109c52 <print_mac>:

void print_mac(uchar *mac){
80109c52:	f3 0f 1e fb          	endbr32 
80109c56:	55                   	push   %ebp
80109c57:	89 e5                	mov    %esp,%ebp
80109c59:	57                   	push   %edi
80109c5a:	56                   	push   %esi
80109c5b:	53                   	push   %ebx
80109c5c:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c62:	83 c0 05             	add    $0x5,%eax
80109c65:	0f b6 00             	movzbl (%eax),%eax
80109c68:	0f b6 f8             	movzbl %al,%edi
80109c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c6e:	83 c0 04             	add    $0x4,%eax
80109c71:	0f b6 00             	movzbl (%eax),%eax
80109c74:	0f b6 f0             	movzbl %al,%esi
80109c77:	8b 45 08             	mov    0x8(%ebp),%eax
80109c7a:	83 c0 03             	add    $0x3,%eax
80109c7d:	0f b6 00             	movzbl (%eax),%eax
80109c80:	0f b6 d8             	movzbl %al,%ebx
80109c83:	8b 45 08             	mov    0x8(%ebp),%eax
80109c86:	83 c0 02             	add    $0x2,%eax
80109c89:	0f b6 00             	movzbl (%eax),%eax
80109c8c:	0f b6 c8             	movzbl %al,%ecx
80109c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c92:	83 c0 01             	add    $0x1,%eax
80109c95:	0f b6 00             	movzbl (%eax),%eax
80109c98:	0f b6 d0             	movzbl %al,%edx
80109c9b:	8b 45 08             	mov    0x8(%ebp),%eax
80109c9e:	0f b6 00             	movzbl (%eax),%eax
80109ca1:	0f b6 c0             	movzbl %al,%eax
80109ca4:	83 ec 04             	sub    $0x4,%esp
80109ca7:	57                   	push   %edi
80109ca8:	56                   	push   %esi
80109ca9:	53                   	push   %ebx
80109caa:	51                   	push   %ecx
80109cab:	52                   	push   %edx
80109cac:	50                   	push   %eax
80109cad:	68 64 c9 10 80       	push   $0x8010c964
80109cb2:	e8 55 67 ff ff       	call   8010040c <cprintf>
80109cb7:	83 c4 20             	add    $0x20,%esp
}
80109cba:	90                   	nop
80109cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109cbe:	5b                   	pop    %ebx
80109cbf:	5e                   	pop    %esi
80109cc0:	5f                   	pop    %edi
80109cc1:	5d                   	pop    %ebp
80109cc2:	c3                   	ret    

80109cc3 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109cc3:	f3 0f 1e fb          	endbr32 
80109cc7:	55                   	push   %ebp
80109cc8:	89 e5                	mov    %esp,%ebp
80109cca:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80109cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80109cd6:	83 c0 0e             	add    $0xe,%eax
80109cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cdf:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109ce3:	3c 08                	cmp    $0x8,%al
80109ce5:	75 1b                	jne    80109d02 <eth_proc+0x3f>
80109ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cea:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109cee:	3c 06                	cmp    $0x6,%al
80109cf0:	75 10                	jne    80109d02 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109cf2:	83 ec 0c             	sub    $0xc,%esp
80109cf5:	ff 75 f0             	pushl  -0x10(%ebp)
80109cf8:	e8 d5 f7 ff ff       	call   801094d2 <arp_proc>
80109cfd:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109d00:	eb 24                	jmp    80109d26 <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d05:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109d09:	3c 08                	cmp    $0x8,%al
80109d0b:	75 19                	jne    80109d26 <eth_proc+0x63>
80109d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d10:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109d14:	84 c0                	test   %al,%al
80109d16:	75 0e                	jne    80109d26 <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109d18:	83 ec 0c             	sub    $0xc,%esp
80109d1b:	ff 75 08             	pushl  0x8(%ebp)
80109d1e:	e8 b3 00 00 00       	call   80109dd6 <ipv4_proc>
80109d23:	83 c4 10             	add    $0x10,%esp
}
80109d26:	90                   	nop
80109d27:	c9                   	leave  
80109d28:	c3                   	ret    

80109d29 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109d29:	f3 0f 1e fb          	endbr32 
80109d2d:	55                   	push   %ebp
80109d2e:	89 e5                	mov    %esp,%ebp
80109d30:	83 ec 04             	sub    $0x4,%esp
80109d33:	8b 45 08             	mov    0x8(%ebp),%eax
80109d36:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109d3a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d3e:	c1 e0 08             	shl    $0x8,%eax
80109d41:	89 c2                	mov    %eax,%edx
80109d43:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d47:	66 c1 e8 08          	shr    $0x8,%ax
80109d4b:	01 d0                	add    %edx,%eax
}
80109d4d:	c9                   	leave  
80109d4e:	c3                   	ret    

80109d4f <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109d4f:	f3 0f 1e fb          	endbr32 
80109d53:	55                   	push   %ebp
80109d54:	89 e5                	mov    %esp,%ebp
80109d56:	83 ec 04             	sub    $0x4,%esp
80109d59:	8b 45 08             	mov    0x8(%ebp),%eax
80109d5c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109d60:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d64:	c1 e0 08             	shl    $0x8,%eax
80109d67:	89 c2                	mov    %eax,%edx
80109d69:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109d6d:	66 c1 e8 08          	shr    $0x8,%ax
80109d71:	01 d0                	add    %edx,%eax
}
80109d73:	c9                   	leave  
80109d74:	c3                   	ret    

80109d75 <H2N_uint>:

uint H2N_uint(uint value){
80109d75:	f3 0f 1e fb          	endbr32 
80109d79:	55                   	push   %ebp
80109d7a:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80109d7f:	c1 e0 18             	shl    $0x18,%eax
80109d82:	25 00 00 00 0f       	and    $0xf000000,%eax
80109d87:	89 c2                	mov    %eax,%edx
80109d89:	8b 45 08             	mov    0x8(%ebp),%eax
80109d8c:	c1 e0 08             	shl    $0x8,%eax
80109d8f:	25 00 f0 00 00       	and    $0xf000,%eax
80109d94:	09 c2                	or     %eax,%edx
80109d96:	8b 45 08             	mov    0x8(%ebp),%eax
80109d99:	c1 e8 08             	shr    $0x8,%eax
80109d9c:	83 e0 0f             	and    $0xf,%eax
80109d9f:	01 d0                	add    %edx,%eax
}
80109da1:	5d                   	pop    %ebp
80109da2:	c3                   	ret    

80109da3 <N2H_uint>:

uint N2H_uint(uint value){
80109da3:	f3 0f 1e fb          	endbr32 
80109da7:	55                   	push   %ebp
80109da8:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109daa:	8b 45 08             	mov    0x8(%ebp),%eax
80109dad:	c1 e0 18             	shl    $0x18,%eax
80109db0:	89 c2                	mov    %eax,%edx
80109db2:	8b 45 08             	mov    0x8(%ebp),%eax
80109db5:	c1 e0 08             	shl    $0x8,%eax
80109db8:	25 00 00 ff 00       	and    $0xff0000,%eax
80109dbd:	01 c2                	add    %eax,%edx
80109dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80109dc2:	c1 e8 08             	shr    $0x8,%eax
80109dc5:	25 00 ff 00 00       	and    $0xff00,%eax
80109dca:	01 c2                	add    %eax,%edx
80109dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80109dcf:	c1 e8 18             	shr    $0x18,%eax
80109dd2:	01 d0                	add    %edx,%eax
}
80109dd4:	5d                   	pop    %ebp
80109dd5:	c3                   	ret    

80109dd6 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109dd6:	f3 0f 1e fb          	endbr32 
80109dda:	55                   	push   %ebp
80109ddb:	89 e5                	mov    %esp,%ebp
80109ddd:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
80109de0:	8b 45 08             	mov    0x8(%ebp),%eax
80109de3:	83 c0 0e             	add    $0xe,%eax
80109de6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
80109de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dec:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109df0:	0f b7 d0             	movzwl %ax,%edx
80109df3:	a1 08 f5 10 80       	mov    0x8010f508,%eax
80109df8:	39 c2                	cmp    %eax,%edx
80109dfa:	74 60                	je     80109e5c <ipv4_proc+0x86>
80109dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dff:	83 c0 0c             	add    $0xc,%eax
80109e02:	83 ec 04             	sub    $0x4,%esp
80109e05:	6a 04                	push   $0x4
80109e07:	50                   	push   %eax
80109e08:	68 04 f5 10 80       	push   $0x8010f504
80109e0d:	e8 d6 b1 ff ff       	call   80104fe8 <memcmp>
80109e12:	83 c4 10             	add    $0x10,%esp
80109e15:	85 c0                	test   %eax,%eax
80109e17:	74 43                	je     80109e5c <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
80109e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e1c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109e20:	0f b7 c0             	movzwl %ax,%eax
80109e23:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e2b:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109e2f:	3c 01                	cmp    $0x1,%al
80109e31:	75 10                	jne    80109e43 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
80109e33:	83 ec 0c             	sub    $0xc,%esp
80109e36:	ff 75 08             	pushl  0x8(%ebp)
80109e39:	e8 a7 00 00 00       	call   80109ee5 <icmp_proc>
80109e3e:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109e41:	eb 19                	jmp    80109e5c <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e46:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109e4a:	3c 06                	cmp    $0x6,%al
80109e4c:	75 0e                	jne    80109e5c <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
80109e4e:	83 ec 0c             	sub    $0xc,%esp
80109e51:	ff 75 08             	pushl  0x8(%ebp)
80109e54:	e8 c7 03 00 00       	call   8010a220 <tcp_proc>
80109e59:	83 c4 10             	add    $0x10,%esp
}
80109e5c:	90                   	nop
80109e5d:	c9                   	leave  
80109e5e:	c3                   	ret    

80109e5f <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109e5f:	f3 0f 1e fb          	endbr32 
80109e63:	55                   	push   %ebp
80109e64:	89 e5                	mov    %esp,%ebp
80109e66:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109e69:	8b 45 08             	mov    0x8(%ebp),%eax
80109e6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e72:	0f b6 00             	movzbl (%eax),%eax
80109e75:	83 e0 0f             	and    $0xf,%eax
80109e78:	01 c0                	add    %eax,%eax
80109e7a:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109e7d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109e84:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109e8b:	eb 48                	jmp    80109ed5 <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109e90:	01 c0                	add    %eax,%eax
80109e92:	89 c2                	mov    %eax,%edx
80109e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e97:	01 d0                	add    %edx,%eax
80109e99:	0f b6 00             	movzbl (%eax),%eax
80109e9c:	0f b6 c0             	movzbl %al,%eax
80109e9f:	c1 e0 08             	shl    $0x8,%eax
80109ea2:	89 c2                	mov    %eax,%edx
80109ea4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109ea7:	01 c0                	add    %eax,%eax
80109ea9:	8d 48 01             	lea    0x1(%eax),%ecx
80109eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eaf:	01 c8                	add    %ecx,%eax
80109eb1:	0f b6 00             	movzbl (%eax),%eax
80109eb4:	0f b6 c0             	movzbl %al,%eax
80109eb7:	01 d0                	add    %edx,%eax
80109eb9:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109ebc:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109ec3:	76 0c                	jbe    80109ed1 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
80109ec5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ec8:	0f b7 c0             	movzwl %ax,%eax
80109ecb:	83 c0 01             	add    $0x1,%eax
80109ece:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109ed1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109ed5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109ed9:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109edc:	7c af                	jl     80109e8d <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
80109ede:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ee1:	f7 d0                	not    %eax
}
80109ee3:	c9                   	leave  
80109ee4:	c3                   	ret    

80109ee5 <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109ee5:	f3 0f 1e fb          	endbr32 
80109ee9:	55                   	push   %ebp
80109eea:	89 e5                	mov    %esp,%ebp
80109eec:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109eef:	8b 45 08             	mov    0x8(%ebp),%eax
80109ef2:	83 c0 0e             	add    $0xe,%eax
80109ef5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109efb:	0f b6 00             	movzbl (%eax),%eax
80109efe:	0f b6 c0             	movzbl %al,%eax
80109f01:	83 e0 0f             	and    $0xf,%eax
80109f04:	c1 e0 02             	shl    $0x2,%eax
80109f07:	89 c2                	mov    %eax,%edx
80109f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f0c:	01 d0                	add    %edx,%eax
80109f0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f14:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109f18:	84 c0                	test   %al,%al
80109f1a:	75 4f                	jne    80109f6b <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f1f:	0f b6 00             	movzbl (%eax),%eax
80109f22:	3c 08                	cmp    $0x8,%al
80109f24:	75 45                	jne    80109f6b <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
80109f26:	e8 59 89 ff ff       	call   80102884 <kalloc>
80109f2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109f2e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109f35:	83 ec 04             	sub    $0x4,%esp
80109f38:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109f3b:	50                   	push   %eax
80109f3c:	ff 75 ec             	pushl  -0x14(%ebp)
80109f3f:	ff 75 08             	pushl  0x8(%ebp)
80109f42:	e8 7c 00 00 00       	call   80109fc3 <icmp_reply_pkt_create>
80109f47:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109f4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f4d:	83 ec 08             	sub    $0x8,%esp
80109f50:	50                   	push   %eax
80109f51:	ff 75 ec             	pushl  -0x14(%ebp)
80109f54:	e8 43 f4 ff ff       	call   8010939c <i8254_send>
80109f59:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f5f:	83 ec 0c             	sub    $0xc,%esp
80109f62:	50                   	push   %eax
80109f63:	e8 7e 88 ff ff       	call   801027e6 <kfree>
80109f68:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109f6b:	90                   	nop
80109f6c:	c9                   	leave  
80109f6d:	c3                   	ret    

80109f6e <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109f6e:	f3 0f 1e fb          	endbr32 
80109f72:	55                   	push   %ebp
80109f73:	89 e5                	mov    %esp,%ebp
80109f75:	53                   	push   %ebx
80109f76:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109f79:	8b 45 08             	mov    0x8(%ebp),%eax
80109f7c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109f80:	0f b7 c0             	movzwl %ax,%eax
80109f83:	83 ec 0c             	sub    $0xc,%esp
80109f86:	50                   	push   %eax
80109f87:	e8 9d fd ff ff       	call   80109d29 <N2H_ushort>
80109f8c:	83 c4 10             	add    $0x10,%esp
80109f8f:	0f b7 d8             	movzwl %ax,%ebx
80109f92:	8b 45 08             	mov    0x8(%ebp),%eax
80109f95:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109f99:	0f b7 c0             	movzwl %ax,%eax
80109f9c:	83 ec 0c             	sub    $0xc,%esp
80109f9f:	50                   	push   %eax
80109fa0:	e8 84 fd ff ff       	call   80109d29 <N2H_ushort>
80109fa5:	83 c4 10             	add    $0x10,%esp
80109fa8:	0f b7 c0             	movzwl %ax,%eax
80109fab:	83 ec 04             	sub    $0x4,%esp
80109fae:	53                   	push   %ebx
80109faf:	50                   	push   %eax
80109fb0:	68 83 c9 10 80       	push   $0x8010c983
80109fb5:	e8 52 64 ff ff       	call   8010040c <cprintf>
80109fba:	83 c4 10             	add    $0x10,%esp
}
80109fbd:	90                   	nop
80109fbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109fc1:	c9                   	leave  
80109fc2:	c3                   	ret    

80109fc3 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109fc3:	f3 0f 1e fb          	endbr32 
80109fc7:	55                   	push   %ebp
80109fc8:	89 e5                	mov    %esp,%ebp
80109fca:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd6:	83 c0 0e             	add    $0xe,%eax
80109fd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fdf:	0f b6 00             	movzbl (%eax),%eax
80109fe2:	0f b6 c0             	movzbl %al,%eax
80109fe5:	83 e0 0f             	and    $0xf,%eax
80109fe8:	c1 e0 02             	shl    $0x2,%eax
80109feb:	89 c2                	mov    %eax,%edx
80109fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ff0:	01 d0                	add    %edx,%eax
80109ff2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ff8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ffe:	83 c0 0e             	add    $0xe,%eax
8010a001:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a004:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a007:	83 c0 14             	add    $0x14,%eax
8010a00a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a00d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a010:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a016:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a019:	8d 50 06             	lea    0x6(%eax),%edx
8010a01c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a01f:	83 ec 04             	sub    $0x4,%esp
8010a022:	6a 06                	push   $0x6
8010a024:	52                   	push   %edx
8010a025:	50                   	push   %eax
8010a026:	e8 19 b0 ff ff       	call   80105044 <memmove>
8010a02b:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a02e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a031:	83 c0 06             	add    $0x6,%eax
8010a034:	83 ec 04             	sub    $0x4,%esp
8010a037:	6a 06                	push   $0x6
8010a039:	68 68 d0 18 80       	push   $0x8018d068
8010a03e:	50                   	push   %eax
8010a03f:	e8 00 b0 ff ff       	call   80105044 <memmove>
8010a044:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a047:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a04a:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a04e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a051:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a058:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a05b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a05e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a062:	83 ec 0c             	sub    $0xc,%esp
8010a065:	6a 54                	push   $0x54
8010a067:	e8 e3 fc ff ff       	call   80109d4f <H2N_ushort>
8010a06c:	83 c4 10             	add    $0x10,%esp
8010a06f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a072:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a076:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a07d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a080:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a084:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a08b:	83 c0 01             	add    $0x1,%eax
8010a08e:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a094:	83 ec 0c             	sub    $0xc,%esp
8010a097:	68 00 40 00 00       	push   $0x4000
8010a09c:	e8 ae fc ff ff       	call   80109d4f <H2N_ushort>
8010a0a1:	83 c4 10             	add    $0x10,%esp
8010a0a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0a7:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a0ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0ae:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a0b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0b5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a0b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0bc:	83 c0 0c             	add    $0xc,%eax
8010a0bf:	83 ec 04             	sub    $0x4,%esp
8010a0c2:	6a 04                	push   $0x4
8010a0c4:	68 04 f5 10 80       	push   $0x8010f504
8010a0c9:	50                   	push   %eax
8010a0ca:	e8 75 af ff ff       	call   80105044 <memmove>
8010a0cf:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a0d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a0d5:	8d 50 0c             	lea    0xc(%eax),%edx
8010a0d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0db:	83 c0 10             	add    $0x10,%eax
8010a0de:	83 ec 04             	sub    $0x4,%esp
8010a0e1:	6a 04                	push   $0x4
8010a0e3:	52                   	push   %edx
8010a0e4:	50                   	push   %eax
8010a0e5:	e8 5a af ff ff       	call   80105044 <memmove>
8010a0ea:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a0ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0f0:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a0f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0f9:	83 ec 0c             	sub    $0xc,%esp
8010a0fc:	50                   	push   %eax
8010a0fd:	e8 5d fd ff ff       	call   80109e5f <ipv4_chksum>
8010a102:	83 c4 10             	add    $0x10,%esp
8010a105:	0f b7 c0             	movzwl %ax,%eax
8010a108:	83 ec 0c             	sub    $0xc,%esp
8010a10b:	50                   	push   %eax
8010a10c:	e8 3e fc ff ff       	call   80109d4f <H2N_ushort>
8010a111:	83 c4 10             	add    $0x10,%esp
8010a114:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a117:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a11b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a11e:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a121:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a124:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a128:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a12b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a12f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a132:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a136:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a139:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a13d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a140:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a144:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a147:	8d 50 08             	lea    0x8(%eax),%edx
8010a14a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a14d:	83 c0 08             	add    $0x8,%eax
8010a150:	83 ec 04             	sub    $0x4,%esp
8010a153:	6a 08                	push   $0x8
8010a155:	52                   	push   %edx
8010a156:	50                   	push   %eax
8010a157:	e8 e8 ae ff ff       	call   80105044 <memmove>
8010a15c:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a15f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a162:	8d 50 10             	lea    0x10(%eax),%edx
8010a165:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a168:	83 c0 10             	add    $0x10,%eax
8010a16b:	83 ec 04             	sub    $0x4,%esp
8010a16e:	6a 30                	push   $0x30
8010a170:	52                   	push   %edx
8010a171:	50                   	push   %eax
8010a172:	e8 cd ae ff ff       	call   80105044 <memmove>
8010a177:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a17a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a17d:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a183:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a186:	83 ec 0c             	sub    $0xc,%esp
8010a189:	50                   	push   %eax
8010a18a:	e8 1c 00 00 00       	call   8010a1ab <icmp_chksum>
8010a18f:	83 c4 10             	add    $0x10,%esp
8010a192:	0f b7 c0             	movzwl %ax,%eax
8010a195:	83 ec 0c             	sub    $0xc,%esp
8010a198:	50                   	push   %eax
8010a199:	e8 b1 fb ff ff       	call   80109d4f <H2N_ushort>
8010a19e:	83 c4 10             	add    $0x10,%esp
8010a1a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1a4:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a1a8:	90                   	nop
8010a1a9:	c9                   	leave  
8010a1aa:	c3                   	ret    

8010a1ab <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a1ab:	f3 0f 1e fb          	endbr32 
8010a1af:	55                   	push   %ebp
8010a1b0:	89 e5                	mov    %esp,%ebp
8010a1b2:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a1b5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a1bb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a1c2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a1c9:	eb 48                	jmp    8010a213 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a1cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a1ce:	01 c0                	add    %eax,%eax
8010a1d0:	89 c2                	mov    %eax,%edx
8010a1d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1d5:	01 d0                	add    %edx,%eax
8010a1d7:	0f b6 00             	movzbl (%eax),%eax
8010a1da:	0f b6 c0             	movzbl %al,%eax
8010a1dd:	c1 e0 08             	shl    $0x8,%eax
8010a1e0:	89 c2                	mov    %eax,%edx
8010a1e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a1e5:	01 c0                	add    %eax,%eax
8010a1e7:	8d 48 01             	lea    0x1(%eax),%ecx
8010a1ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1ed:	01 c8                	add    %ecx,%eax
8010a1ef:	0f b6 00             	movzbl (%eax),%eax
8010a1f2:	0f b6 c0             	movzbl %al,%eax
8010a1f5:	01 d0                	add    %edx,%eax
8010a1f7:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a1fa:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a201:	76 0c                	jbe    8010a20f <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a203:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a206:	0f b7 c0             	movzwl %ax,%eax
8010a209:	83 c0 01             	add    $0x1,%eax
8010a20c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a20f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a213:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a217:	7e b2                	jle    8010a1cb <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a219:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a21c:	f7 d0                	not    %eax
}
8010a21e:	c9                   	leave  
8010a21f:	c3                   	ret    

8010a220 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a220:	f3 0f 1e fb          	endbr32 
8010a224:	55                   	push   %ebp
8010a225:	89 e5                	mov    %esp,%ebp
8010a227:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a22a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a22d:	83 c0 0e             	add    $0xe,%eax
8010a230:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a233:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a236:	0f b6 00             	movzbl (%eax),%eax
8010a239:	0f b6 c0             	movzbl %al,%eax
8010a23c:	83 e0 0f             	and    $0xf,%eax
8010a23f:	c1 e0 02             	shl    $0x2,%eax
8010a242:	89 c2                	mov    %eax,%edx
8010a244:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a247:	01 d0                	add    %edx,%eax
8010a249:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a24c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a24f:	83 c0 14             	add    $0x14,%eax
8010a252:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a255:	e8 2a 86 ff ff       	call   80102884 <kalloc>
8010a25a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a25d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a264:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a267:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a26b:	0f b6 c0             	movzbl %al,%eax
8010a26e:	83 e0 02             	and    $0x2,%eax
8010a271:	85 c0                	test   %eax,%eax
8010a273:	74 3d                	je     8010a2b2 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a275:	83 ec 0c             	sub    $0xc,%esp
8010a278:	6a 00                	push   $0x0
8010a27a:	6a 12                	push   $0x12
8010a27c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a27f:	50                   	push   %eax
8010a280:	ff 75 e8             	pushl  -0x18(%ebp)
8010a283:	ff 75 08             	pushl  0x8(%ebp)
8010a286:	e8 a2 01 00 00       	call   8010a42d <tcp_pkt_create>
8010a28b:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a28e:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a291:	83 ec 08             	sub    $0x8,%esp
8010a294:	50                   	push   %eax
8010a295:	ff 75 e8             	pushl  -0x18(%ebp)
8010a298:	e8 ff f0 ff ff       	call   8010939c <i8254_send>
8010a29d:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a2a0:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a2a5:	83 c0 01             	add    $0x1,%eax
8010a2a8:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a2ad:	e9 69 01 00 00       	jmp    8010a41b <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a2b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2b5:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a2b9:	3c 18                	cmp    $0x18,%al
8010a2bb:	0f 85 10 01 00 00    	jne    8010a3d1 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a2c1:	83 ec 04             	sub    $0x4,%esp
8010a2c4:	6a 03                	push   $0x3
8010a2c6:	68 9e c9 10 80       	push   $0x8010c99e
8010a2cb:	ff 75 ec             	pushl  -0x14(%ebp)
8010a2ce:	e8 15 ad ff ff       	call   80104fe8 <memcmp>
8010a2d3:	83 c4 10             	add    $0x10,%esp
8010a2d6:	85 c0                	test   %eax,%eax
8010a2d8:	74 74                	je     8010a34e <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a2da:	83 ec 0c             	sub    $0xc,%esp
8010a2dd:	68 a2 c9 10 80       	push   $0x8010c9a2
8010a2e2:	e8 25 61 ff ff       	call   8010040c <cprintf>
8010a2e7:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a2ea:	83 ec 0c             	sub    $0xc,%esp
8010a2ed:	6a 00                	push   $0x0
8010a2ef:	6a 10                	push   $0x10
8010a2f1:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a2f4:	50                   	push   %eax
8010a2f5:	ff 75 e8             	pushl  -0x18(%ebp)
8010a2f8:	ff 75 08             	pushl  0x8(%ebp)
8010a2fb:	e8 2d 01 00 00       	call   8010a42d <tcp_pkt_create>
8010a300:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a303:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a306:	83 ec 08             	sub    $0x8,%esp
8010a309:	50                   	push   %eax
8010a30a:	ff 75 e8             	pushl  -0x18(%ebp)
8010a30d:	e8 8a f0 ff ff       	call   8010939c <i8254_send>
8010a312:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a315:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a318:	83 c0 36             	add    $0x36,%eax
8010a31b:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a31e:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a321:	50                   	push   %eax
8010a322:	ff 75 e0             	pushl  -0x20(%ebp)
8010a325:	6a 00                	push   $0x0
8010a327:	6a 00                	push   $0x0
8010a329:	e8 66 04 00 00       	call   8010a794 <http_proc>
8010a32e:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a331:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a334:	83 ec 0c             	sub    $0xc,%esp
8010a337:	50                   	push   %eax
8010a338:	6a 18                	push   $0x18
8010a33a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a33d:	50                   	push   %eax
8010a33e:	ff 75 e8             	pushl  -0x18(%ebp)
8010a341:	ff 75 08             	pushl  0x8(%ebp)
8010a344:	e8 e4 00 00 00       	call   8010a42d <tcp_pkt_create>
8010a349:	83 c4 20             	add    $0x20,%esp
8010a34c:	eb 62                	jmp    8010a3b0 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a34e:	83 ec 0c             	sub    $0xc,%esp
8010a351:	6a 00                	push   $0x0
8010a353:	6a 10                	push   $0x10
8010a355:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a358:	50                   	push   %eax
8010a359:	ff 75 e8             	pushl  -0x18(%ebp)
8010a35c:	ff 75 08             	pushl  0x8(%ebp)
8010a35f:	e8 c9 00 00 00       	call   8010a42d <tcp_pkt_create>
8010a364:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a367:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a36a:	83 ec 08             	sub    $0x8,%esp
8010a36d:	50                   	push   %eax
8010a36e:	ff 75 e8             	pushl  -0x18(%ebp)
8010a371:	e8 26 f0 ff ff       	call   8010939c <i8254_send>
8010a376:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a379:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a37c:	83 c0 36             	add    $0x36,%eax
8010a37f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a382:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a385:	50                   	push   %eax
8010a386:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a389:	6a 00                	push   $0x0
8010a38b:	6a 00                	push   $0x0
8010a38d:	e8 02 04 00 00       	call   8010a794 <http_proc>
8010a392:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a395:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a398:	83 ec 0c             	sub    $0xc,%esp
8010a39b:	50                   	push   %eax
8010a39c:	6a 18                	push   $0x18
8010a39e:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3a1:	50                   	push   %eax
8010a3a2:	ff 75 e8             	pushl  -0x18(%ebp)
8010a3a5:	ff 75 08             	pushl  0x8(%ebp)
8010a3a8:	e8 80 00 00 00       	call   8010a42d <tcp_pkt_create>
8010a3ad:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a3b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a3b3:	83 ec 08             	sub    $0x8,%esp
8010a3b6:	50                   	push   %eax
8010a3b7:	ff 75 e8             	pushl  -0x18(%ebp)
8010a3ba:	e8 dd ef ff ff       	call   8010939c <i8254_send>
8010a3bf:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a3c2:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a3c7:	83 c0 01             	add    $0x1,%eax
8010a3ca:	a3 44 d3 18 80       	mov    %eax,0x8018d344
8010a3cf:	eb 4a                	jmp    8010a41b <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a3d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3d4:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a3d8:	3c 10                	cmp    $0x10,%al
8010a3da:	75 3f                	jne    8010a41b <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a3dc:	a1 48 d3 18 80       	mov    0x8018d348,%eax
8010a3e1:	83 f8 01             	cmp    $0x1,%eax
8010a3e4:	75 35                	jne    8010a41b <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a3e6:	83 ec 0c             	sub    $0xc,%esp
8010a3e9:	6a 00                	push   $0x0
8010a3eb:	6a 01                	push   $0x1
8010a3ed:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a3f0:	50                   	push   %eax
8010a3f1:	ff 75 e8             	pushl  -0x18(%ebp)
8010a3f4:	ff 75 08             	pushl  0x8(%ebp)
8010a3f7:	e8 31 00 00 00       	call   8010a42d <tcp_pkt_create>
8010a3fc:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a3ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a402:	83 ec 08             	sub    $0x8,%esp
8010a405:	50                   	push   %eax
8010a406:	ff 75 e8             	pushl  -0x18(%ebp)
8010a409:	e8 8e ef ff ff       	call   8010939c <i8254_send>
8010a40e:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a411:	c7 05 48 d3 18 80 00 	movl   $0x0,0x8018d348
8010a418:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a41b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a41e:	83 ec 0c             	sub    $0xc,%esp
8010a421:	50                   	push   %eax
8010a422:	e8 bf 83 ff ff       	call   801027e6 <kfree>
8010a427:	83 c4 10             	add    $0x10,%esp
}
8010a42a:	90                   	nop
8010a42b:	c9                   	leave  
8010a42c:	c3                   	ret    

8010a42d <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a42d:	f3 0f 1e fb          	endbr32 
8010a431:	55                   	push   %ebp
8010a432:	89 e5                	mov    %esp,%ebp
8010a434:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a437:	8b 45 08             	mov    0x8(%ebp),%eax
8010a43a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a43d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a440:	83 c0 0e             	add    $0xe,%eax
8010a443:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a446:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a449:	0f b6 00             	movzbl (%eax),%eax
8010a44c:	0f b6 c0             	movzbl %al,%eax
8010a44f:	83 e0 0f             	and    $0xf,%eax
8010a452:	c1 e0 02             	shl    $0x2,%eax
8010a455:	89 c2                	mov    %eax,%edx
8010a457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a45a:	01 d0                	add    %edx,%eax
8010a45c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a45f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a462:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a465:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a468:	83 c0 0e             	add    $0xe,%eax
8010a46b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a46e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a471:	83 c0 14             	add    $0x14,%eax
8010a474:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a477:	8b 45 18             	mov    0x18(%ebp),%eax
8010a47a:	8d 50 36             	lea    0x36(%eax),%edx
8010a47d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a480:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a482:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a485:	8d 50 06             	lea    0x6(%eax),%edx
8010a488:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a48b:	83 ec 04             	sub    $0x4,%esp
8010a48e:	6a 06                	push   $0x6
8010a490:	52                   	push   %edx
8010a491:	50                   	push   %eax
8010a492:	e8 ad ab ff ff       	call   80105044 <memmove>
8010a497:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a49a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a49d:	83 c0 06             	add    $0x6,%eax
8010a4a0:	83 ec 04             	sub    $0x4,%esp
8010a4a3:	6a 06                	push   $0x6
8010a4a5:	68 68 d0 18 80       	push   $0x8018d068
8010a4aa:	50                   	push   %eax
8010a4ab:	e8 94 ab ff ff       	call   80105044 <memmove>
8010a4b0:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a4b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4b6:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a4ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a4bd:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a4c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4c4:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a4c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4ca:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a4ce:	8b 45 18             	mov    0x18(%ebp),%eax
8010a4d1:	83 c0 28             	add    $0x28,%eax
8010a4d4:	0f b7 c0             	movzwl %ax,%eax
8010a4d7:	83 ec 0c             	sub    $0xc,%esp
8010a4da:	50                   	push   %eax
8010a4db:	e8 6f f8 ff ff       	call   80109d4f <H2N_ushort>
8010a4e0:	83 c4 10             	add    $0x10,%esp
8010a4e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4e6:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a4ea:	0f b7 15 40 d3 18 80 	movzwl 0x8018d340,%edx
8010a4f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4f4:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a4f8:	0f b7 05 40 d3 18 80 	movzwl 0x8018d340,%eax
8010a4ff:	83 c0 01             	add    $0x1,%eax
8010a502:	66 a3 40 d3 18 80    	mov    %ax,0x8018d340
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a508:	83 ec 0c             	sub    $0xc,%esp
8010a50b:	6a 00                	push   $0x0
8010a50d:	e8 3d f8 ff ff       	call   80109d4f <H2N_ushort>
8010a512:	83 c4 10             	add    $0x10,%esp
8010a515:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a518:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a51c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a51f:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a523:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a526:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a52a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a52d:	83 c0 0c             	add    $0xc,%eax
8010a530:	83 ec 04             	sub    $0x4,%esp
8010a533:	6a 04                	push   $0x4
8010a535:	68 04 f5 10 80       	push   $0x8010f504
8010a53a:	50                   	push   %eax
8010a53b:	e8 04 ab ff ff       	call   80105044 <memmove>
8010a540:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a543:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a546:	8d 50 0c             	lea    0xc(%eax),%edx
8010a549:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a54c:	83 c0 10             	add    $0x10,%eax
8010a54f:	83 ec 04             	sub    $0x4,%esp
8010a552:	6a 04                	push   $0x4
8010a554:	52                   	push   %edx
8010a555:	50                   	push   %eax
8010a556:	e8 e9 aa ff ff       	call   80105044 <memmove>
8010a55b:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a55e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a561:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a567:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a56a:	83 ec 0c             	sub    $0xc,%esp
8010a56d:	50                   	push   %eax
8010a56e:	e8 ec f8 ff ff       	call   80109e5f <ipv4_chksum>
8010a573:	83 c4 10             	add    $0x10,%esp
8010a576:	0f b7 c0             	movzwl %ax,%eax
8010a579:	83 ec 0c             	sub    $0xc,%esp
8010a57c:	50                   	push   %eax
8010a57d:	e8 cd f7 ff ff       	call   80109d4f <H2N_ushort>
8010a582:	83 c4 10             	add    $0x10,%esp
8010a585:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a588:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a58c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a58f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a593:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a596:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a599:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a59c:	0f b7 10             	movzwl (%eax),%edx
8010a59f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5a2:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a5a6:	a1 44 d3 18 80       	mov    0x8018d344,%eax
8010a5ab:	83 ec 0c             	sub    $0xc,%esp
8010a5ae:	50                   	push   %eax
8010a5af:	e8 c1 f7 ff ff       	call   80109d75 <H2N_uint>
8010a5b4:	83 c4 10             	add    $0x10,%esp
8010a5b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a5ba:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a5bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5c0:	8b 40 04             	mov    0x4(%eax),%eax
8010a5c3:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a5c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5cc:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a5cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5d2:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a5d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5d9:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a5dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5e0:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a5e4:	8b 45 14             	mov    0x14(%ebp),%eax
8010a5e7:	89 c2                	mov    %eax,%edx
8010a5e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5ec:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a5ef:	83 ec 0c             	sub    $0xc,%esp
8010a5f2:	68 90 38 00 00       	push   $0x3890
8010a5f7:	e8 53 f7 ff ff       	call   80109d4f <H2N_ushort>
8010a5fc:	83 c4 10             	add    $0x10,%esp
8010a5ff:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a602:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a606:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a609:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a60f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a612:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a618:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a61b:	83 ec 0c             	sub    $0xc,%esp
8010a61e:	50                   	push   %eax
8010a61f:	e8 1f 00 00 00       	call   8010a643 <tcp_chksum>
8010a624:	83 c4 10             	add    $0x10,%esp
8010a627:	83 c0 08             	add    $0x8,%eax
8010a62a:	0f b7 c0             	movzwl %ax,%eax
8010a62d:	83 ec 0c             	sub    $0xc,%esp
8010a630:	50                   	push   %eax
8010a631:	e8 19 f7 ff ff       	call   80109d4f <H2N_ushort>
8010a636:	83 c4 10             	add    $0x10,%esp
8010a639:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a63c:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a640:	90                   	nop
8010a641:	c9                   	leave  
8010a642:	c3                   	ret    

8010a643 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a643:	f3 0f 1e fb          	endbr32 
8010a647:	55                   	push   %ebp
8010a648:	89 e5                	mov    %esp,%ebp
8010a64a:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a64d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a650:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a653:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a656:	83 c0 14             	add    $0x14,%eax
8010a659:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a65c:	83 ec 04             	sub    $0x4,%esp
8010a65f:	6a 04                	push   $0x4
8010a661:	68 04 f5 10 80       	push   $0x8010f504
8010a666:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a669:	50                   	push   %eax
8010a66a:	e8 d5 a9 ff ff       	call   80105044 <memmove>
8010a66f:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a672:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a675:	83 c0 0c             	add    $0xc,%eax
8010a678:	83 ec 04             	sub    $0x4,%esp
8010a67b:	6a 04                	push   $0x4
8010a67d:	50                   	push   %eax
8010a67e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a681:	83 c0 04             	add    $0x4,%eax
8010a684:	50                   	push   %eax
8010a685:	e8 ba a9 ff ff       	call   80105044 <memmove>
8010a68a:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a68d:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a691:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a695:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a698:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a69c:	0f b7 c0             	movzwl %ax,%eax
8010a69f:	83 ec 0c             	sub    $0xc,%esp
8010a6a2:	50                   	push   %eax
8010a6a3:	e8 81 f6 ff ff       	call   80109d29 <N2H_ushort>
8010a6a8:	83 c4 10             	add    $0x10,%esp
8010a6ab:	83 e8 14             	sub    $0x14,%eax
8010a6ae:	0f b7 c0             	movzwl %ax,%eax
8010a6b1:	83 ec 0c             	sub    $0xc,%esp
8010a6b4:	50                   	push   %eax
8010a6b5:	e8 95 f6 ff ff       	call   80109d4f <H2N_ushort>
8010a6ba:	83 c4 10             	add    $0x10,%esp
8010a6bd:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a6c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a6c8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a6cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a6ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a6d5:	eb 33                	jmp    8010a70a <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a6d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6da:	01 c0                	add    %eax,%eax
8010a6dc:	89 c2                	mov    %eax,%edx
8010a6de:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6e1:	01 d0                	add    %edx,%eax
8010a6e3:	0f b6 00             	movzbl (%eax),%eax
8010a6e6:	0f b6 c0             	movzbl %al,%eax
8010a6e9:	c1 e0 08             	shl    $0x8,%eax
8010a6ec:	89 c2                	mov    %eax,%edx
8010a6ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6f1:	01 c0                	add    %eax,%eax
8010a6f3:	8d 48 01             	lea    0x1(%eax),%ecx
8010a6f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a6f9:	01 c8                	add    %ecx,%eax
8010a6fb:	0f b6 00             	movzbl (%eax),%eax
8010a6fe:	0f b6 c0             	movzbl %al,%eax
8010a701:	01 d0                	add    %edx,%eax
8010a703:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a706:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a70a:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a70e:	7e c7                	jle    8010a6d7 <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a710:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a713:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a716:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a71d:	eb 33                	jmp    8010a752 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a71f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a722:	01 c0                	add    %eax,%eax
8010a724:	89 c2                	mov    %eax,%edx
8010a726:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a729:	01 d0                	add    %edx,%eax
8010a72b:	0f b6 00             	movzbl (%eax),%eax
8010a72e:	0f b6 c0             	movzbl %al,%eax
8010a731:	c1 e0 08             	shl    $0x8,%eax
8010a734:	89 c2                	mov    %eax,%edx
8010a736:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a739:	01 c0                	add    %eax,%eax
8010a73b:	8d 48 01             	lea    0x1(%eax),%ecx
8010a73e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a741:	01 c8                	add    %ecx,%eax
8010a743:	0f b6 00             	movzbl (%eax),%eax
8010a746:	0f b6 c0             	movzbl %al,%eax
8010a749:	01 d0                	add    %edx,%eax
8010a74b:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a74e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a752:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a756:	0f b7 c0             	movzwl %ax,%eax
8010a759:	83 ec 0c             	sub    $0xc,%esp
8010a75c:	50                   	push   %eax
8010a75d:	e8 c7 f5 ff ff       	call   80109d29 <N2H_ushort>
8010a762:	83 c4 10             	add    $0x10,%esp
8010a765:	66 d1 e8             	shr    %ax
8010a768:	0f b7 c0             	movzwl %ax,%eax
8010a76b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a76e:	7c af                	jl     8010a71f <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a770:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a773:	c1 e8 10             	shr    $0x10,%eax
8010a776:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a77c:	f7 d0                	not    %eax
}
8010a77e:	c9                   	leave  
8010a77f:	c3                   	ret    

8010a780 <tcp_fin>:

void tcp_fin(){
8010a780:	f3 0f 1e fb          	endbr32 
8010a784:	55                   	push   %ebp
8010a785:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a787:	c7 05 48 d3 18 80 01 	movl   $0x1,0x8018d348
8010a78e:	00 00 00 
}
8010a791:	90                   	nop
8010a792:	5d                   	pop    %ebp
8010a793:	c3                   	ret    

8010a794 <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a794:	f3 0f 1e fb          	endbr32 
8010a798:	55                   	push   %ebp
8010a799:	89 e5                	mov    %esp,%ebp
8010a79b:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a79e:	8b 45 10             	mov    0x10(%ebp),%eax
8010a7a1:	83 ec 04             	sub    $0x4,%esp
8010a7a4:	6a 00                	push   $0x0
8010a7a6:	68 ab c9 10 80       	push   $0x8010c9ab
8010a7ab:	50                   	push   %eax
8010a7ac:	e8 65 00 00 00       	call   8010a816 <http_strcpy>
8010a7b1:	83 c4 10             	add    $0x10,%esp
8010a7b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a7b7:	8b 45 10             	mov    0x10(%ebp),%eax
8010a7ba:	83 ec 04             	sub    $0x4,%esp
8010a7bd:	ff 75 f4             	pushl  -0xc(%ebp)
8010a7c0:	68 be c9 10 80       	push   $0x8010c9be
8010a7c5:	50                   	push   %eax
8010a7c6:	e8 4b 00 00 00       	call   8010a816 <http_strcpy>
8010a7cb:	83 c4 10             	add    $0x10,%esp
8010a7ce:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a7d1:	8b 45 10             	mov    0x10(%ebp),%eax
8010a7d4:	83 ec 04             	sub    $0x4,%esp
8010a7d7:	ff 75 f4             	pushl  -0xc(%ebp)
8010a7da:	68 d9 c9 10 80       	push   $0x8010c9d9
8010a7df:	50                   	push   %eax
8010a7e0:	e8 31 00 00 00       	call   8010a816 <http_strcpy>
8010a7e5:	83 c4 10             	add    $0x10,%esp
8010a7e8:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a7eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a7ee:	83 e0 01             	and    $0x1,%eax
8010a7f1:	85 c0                	test   %eax,%eax
8010a7f3:	74 11                	je     8010a806 <http_proc+0x72>
    char *payload = (char *)send;
8010a7f5:	8b 45 10             	mov    0x10(%ebp),%eax
8010a7f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a7fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a7fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a801:	01 d0                	add    %edx,%eax
8010a803:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a806:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a809:	8b 45 14             	mov    0x14(%ebp),%eax
8010a80c:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a80e:	e8 6d ff ff ff       	call   8010a780 <tcp_fin>
}
8010a813:	90                   	nop
8010a814:	c9                   	leave  
8010a815:	c3                   	ret    

8010a816 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a816:	f3 0f 1e fb          	endbr32 
8010a81a:	55                   	push   %ebp
8010a81b:	89 e5                	mov    %esp,%ebp
8010a81d:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a820:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a827:	eb 20                	jmp    8010a849 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010a829:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a82c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a82f:	01 d0                	add    %edx,%eax
8010a831:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a834:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a837:	01 ca                	add    %ecx,%edx
8010a839:	89 d1                	mov    %edx,%ecx
8010a83b:	8b 55 08             	mov    0x8(%ebp),%edx
8010a83e:	01 ca                	add    %ecx,%edx
8010a840:	0f b6 00             	movzbl (%eax),%eax
8010a843:	88 02                	mov    %al,(%edx)
    i++;
8010a845:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a849:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a84c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a84f:	01 d0                	add    %edx,%eax
8010a851:	0f b6 00             	movzbl (%eax),%eax
8010a854:	84 c0                	test   %al,%al
8010a856:	75 d1                	jne    8010a829 <http_strcpy+0x13>
  }
  return i;
8010a858:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a85b:	c9                   	leave  
8010a85c:	c3                   	ret    

8010a85d <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
8010a85d:	f3 0f 1e fb          	endbr32 
8010a861:	55                   	push   %ebp
8010a862:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
8010a864:	c7 05 50 d3 18 80 c2 	movl   $0x8010f5c2,0x8018d350
8010a86b:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
8010a86e:	b8 00 d0 07 00       	mov    $0x7d000,%eax
8010a873:	c1 e8 09             	shr    $0x9,%eax
8010a876:	a3 4c d3 18 80       	mov    %eax,0x8018d34c
}
8010a87b:	90                   	nop
8010a87c:	5d                   	pop    %ebp
8010a87d:	c3                   	ret    

8010a87e <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a87e:	f3 0f 1e fb          	endbr32 
8010a882:	55                   	push   %ebp
8010a883:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a885:	90                   	nop
8010a886:	5d                   	pop    %ebp
8010a887:	c3                   	ret    

8010a888 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a888:	f3 0f 1e fb          	endbr32 
8010a88c:	55                   	push   %ebp
8010a88d:	89 e5                	mov    %esp,%ebp
8010a88f:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a892:	8b 45 08             	mov    0x8(%ebp),%eax
8010a895:	83 c0 0c             	add    $0xc,%eax
8010a898:	83 ec 0c             	sub    $0xc,%esp
8010a89b:	50                   	push   %eax
8010a89c:	e8 b4 a3 ff ff       	call   80104c55 <holdingsleep>
8010a8a1:	83 c4 10             	add    $0x10,%esp
8010a8a4:	85 c0                	test   %eax,%eax
8010a8a6:	75 0d                	jne    8010a8b5 <iderw+0x2d>
    panic("iderw: buf not locked");
8010a8a8:	83 ec 0c             	sub    $0xc,%esp
8010a8ab:	68 ea c9 10 80       	push   $0x8010c9ea
8010a8b0:	e8 10 5d ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a8b5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8b8:	8b 00                	mov    (%eax),%eax
8010a8ba:	83 e0 06             	and    $0x6,%eax
8010a8bd:	83 f8 02             	cmp    $0x2,%eax
8010a8c0:	75 0d                	jne    8010a8cf <iderw+0x47>
    panic("iderw: nothing to do");
8010a8c2:	83 ec 0c             	sub    $0xc,%esp
8010a8c5:	68 00 ca 10 80       	push   $0x8010ca00
8010a8ca:	e8 f6 5c ff ff       	call   801005c5 <panic>
  if(b->dev != 1)
8010a8cf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8d2:	8b 40 04             	mov    0x4(%eax),%eax
8010a8d5:	83 f8 01             	cmp    $0x1,%eax
8010a8d8:	74 0d                	je     8010a8e7 <iderw+0x5f>
    panic("iderw: request not for disk 1");
8010a8da:	83 ec 0c             	sub    $0xc,%esp
8010a8dd:	68 15 ca 10 80       	push   $0x8010ca15
8010a8e2:	e8 de 5c ff ff       	call   801005c5 <panic>
  if(b->blockno >= disksize)
8010a8e7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8ea:	8b 40 08             	mov    0x8(%eax),%eax
8010a8ed:	8b 15 4c d3 18 80    	mov    0x8018d34c,%edx
8010a8f3:	39 d0                	cmp    %edx,%eax
8010a8f5:	72 0d                	jb     8010a904 <iderw+0x7c>
    panic("iderw: block out of range");
8010a8f7:	83 ec 0c             	sub    $0xc,%esp
8010a8fa:	68 33 ca 10 80       	push   $0x8010ca33
8010a8ff:	e8 c1 5c ff ff       	call   801005c5 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a904:	8b 15 50 d3 18 80    	mov    0x8018d350,%edx
8010a90a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a90d:	8b 40 08             	mov    0x8(%eax),%eax
8010a910:	c1 e0 09             	shl    $0x9,%eax
8010a913:	01 d0                	add    %edx,%eax
8010a915:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a918:	8b 45 08             	mov    0x8(%ebp),%eax
8010a91b:	8b 00                	mov    (%eax),%eax
8010a91d:	83 e0 04             	and    $0x4,%eax
8010a920:	85 c0                	test   %eax,%eax
8010a922:	74 2b                	je     8010a94f <iderw+0xc7>
    b->flags &= ~B_DIRTY;
8010a924:	8b 45 08             	mov    0x8(%ebp),%eax
8010a927:	8b 00                	mov    (%eax),%eax
8010a929:	83 e0 fb             	and    $0xfffffffb,%eax
8010a92c:	89 c2                	mov    %eax,%edx
8010a92e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a931:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a933:	8b 45 08             	mov    0x8(%ebp),%eax
8010a936:	83 c0 5c             	add    $0x5c,%eax
8010a939:	83 ec 04             	sub    $0x4,%esp
8010a93c:	68 00 02 00 00       	push   $0x200
8010a941:	50                   	push   %eax
8010a942:	ff 75 f4             	pushl  -0xc(%ebp)
8010a945:	e8 fa a6 ff ff       	call   80105044 <memmove>
8010a94a:	83 c4 10             	add    $0x10,%esp
8010a94d:	eb 1a                	jmp    8010a969 <iderw+0xe1>
  } else
    memmove(b->data, p, BSIZE);
8010a94f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a952:	83 c0 5c             	add    $0x5c,%eax
8010a955:	83 ec 04             	sub    $0x4,%esp
8010a958:	68 00 02 00 00       	push   $0x200
8010a95d:	ff 75 f4             	pushl  -0xc(%ebp)
8010a960:	50                   	push   %eax
8010a961:	e8 de a6 ff ff       	call   80105044 <memmove>
8010a966:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a969:	8b 45 08             	mov    0x8(%ebp),%eax
8010a96c:	8b 00                	mov    (%eax),%eax
8010a96e:	83 c8 02             	or     $0x2,%eax
8010a971:	89 c2                	mov    %eax,%edx
8010a973:	8b 45 08             	mov    0x8(%ebp),%eax
8010a976:	89 10                	mov    %edx,(%eax)
}
8010a978:	90                   	nop
8010a979:	c9                   	leave  
8010a97a:	c3                   	ret    
