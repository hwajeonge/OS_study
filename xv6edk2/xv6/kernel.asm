
kernel:     file format elf32-i386


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
8010005a:	bc 90 13 11 80       	mov    $0x80111390,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 94 39 10 80       	mov    $0x80103994,%edx
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
80100073:	68 60 ad 10 80       	push   $0x8010ad60
80100078:	68 a0 13 11 80       	push   $0x801113a0
8010007d:	e8 28 51 00 00       	call   801051aa <initlock>
80100082:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100085:	c7 05 ec 5a 11 80 9c 	movl   $0x80115a9c,0x80115aec
8010008c:	5a 11 80 
  bcache.head.next = &bcache.head;
8010008f:	c7 05 f0 5a 11 80 9c 	movl   $0x80115a9c,0x80115af0
80100096:	5a 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100099:	c7 45 f4 d4 13 11 80 	movl   $0x801113d4,-0xc(%ebp)
801000a0:	eb 47                	jmp    801000e9 <binit+0x83>
    b->next = bcache.head.next;
801000a2:	8b 15 f0 5a 11 80    	mov    0x80115af0,%edx
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b1:	c7 40 50 9c 5a 11 80 	movl   $0x80115a9c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000bb:	83 c0 0c             	add    $0xc,%eax
801000be:	83 ec 08             	sub    $0x8,%esp
801000c1:	68 67 ad 10 80       	push   $0x8010ad67
801000c6:	50                   	push   %eax
801000c7:	e8 71 4f 00 00       	call   8010503d <initsleeplock>
801000cc:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cf:	a1 f0 5a 11 80       	mov    0x80115af0,%eax
801000d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d7:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000dd:	a3 f0 5a 11 80       	mov    %eax,0x80115af0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000e2:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e9:	b8 9c 5a 11 80       	mov    $0x80115a9c,%eax
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
80100104:	68 a0 13 11 80       	push   $0x801113a0
80100109:	e8 c2 50 00 00       	call   801051d0 <acquire>
8010010e:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100111:	a1 f0 5a 11 80       	mov    0x80115af0,%eax
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
80100143:	68 a0 13 11 80       	push   $0x801113a0
80100148:	e8 f5 50 00 00       	call   80105242 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 1e 4f 00 00       	call   8010507d <acquiresleep>
8010015f:	83 c4 10             	add    $0x10,%esp
      return b;
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	e9 9d 00 00 00       	jmp    80100207 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 40 54             	mov    0x54(%eax),%eax
80100170:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100173:	81 7d f4 9c 5a 11 80 	cmpl   $0x80115a9c,-0xc(%ebp)
8010017a:	75 9f                	jne    8010011b <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010017c:	a1 ec 5a 11 80       	mov    0x80115aec,%eax
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
801001c4:	68 a0 13 11 80       	push   $0x801113a0
801001c9:	e8 74 50 00 00       	call   80105242 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 9d 4e 00 00       	call   8010507d <acquiresleep>
801001e0:	83 c4 10             	add    $0x10,%esp
      return b;
801001e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e6:	eb 1f                	jmp    80100207 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001eb:	8b 40 50             	mov    0x50(%eax),%eax
801001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001f1:	81 7d f4 9c 5a 11 80 	cmpl   $0x80115a9c,-0xc(%ebp)
801001f8:	75 8c                	jne    80100186 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001fa:	83 ec 0c             	sub    $0xc,%esp
801001fd:	68 6e ad 10 80       	push   $0x8010ad6e
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
80100239:	e8 bd 27 00 00       	call   801029fb <iderw>
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
8010025a:	e8 d8 4e 00 00       	call   80105137 <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 7f ad 10 80       	push   $0x8010ad7f
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
80100288:	e8 6e 27 00 00       	call   801029fb <iderw>
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
801002a7:	e8 8b 4e 00 00       	call   80105137 <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 86 ad 10 80       	push   $0x8010ad86
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 16 4e 00 00       	call   801050e5 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 a0 13 11 80       	push   $0x801113a0
801002da:	e8 f1 4e 00 00       	call   801051d0 <acquire>
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
80100319:	8b 15 f0 5a 11 80    	mov    0x80115af0,%edx
8010031f:	8b 45 08             	mov    0x8(%ebp),%eax
80100322:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100325:	8b 45 08             	mov    0x8(%ebp),%eax
80100328:	c7 40 50 9c 5a 11 80 	movl   $0x80115a9c,0x50(%eax)
    bcache.head.next->prev = b;
8010032f:	a1 f0 5a 11 80       	mov    0x80115af0,%eax
80100334:	8b 55 08             	mov    0x8(%ebp),%edx
80100337:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
8010033a:	8b 45 08             	mov    0x8(%ebp),%eax
8010033d:	a3 f0 5a 11 80       	mov    %eax,0x80115af0
  }
  
  release(&bcache.lock);
80100342:	83 ec 0c             	sub    $0xc,%esp
80100345:	68 a0 13 11 80       	push   $0x801113a0
8010034a:	e8 f3 4e 00 00       	call   80105242 <release>
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
80100416:	a1 54 00 11 80       	mov    0x80110054,%eax
8010041b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010041e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100422:	74 10                	je     80100434 <cprintf+0x28>
    acquire(&cons.lock);
80100424:	83 ec 0c             	sub    $0xc,%esp
80100427:	68 20 00 11 80       	push   $0x80110020
8010042c:	e8 9f 4d 00 00       	call   801051d0 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 8d ad 10 80       	push   $0x8010ad8d
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
8010052c:	c7 45 ec 96 ad 10 80 	movl   $0x8010ad96,-0x14(%ebp)
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
801005b5:	68 20 00 11 80       	push   $0x80110020
801005ba:	e8 83 4c 00 00       	call   80105242 <release>
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
801005d4:	c7 05 54 00 11 80 00 	movl   $0x0,0x80110054
801005db:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005de:	e8 02 2b 00 00       	call   801030e5 <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 9d ad 10 80       	push   $0x8010ad9d
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
80100606:	68 b1 ad 10 80       	push   $0x8010adb1
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 75 4c 00 00       	call   80105298 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 b3 ad 10 80       	push   $0x8010adb3
8010063f:	e8 c8 fd ff ff       	call   8010040c <cprintf>
80100644:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100647:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010064b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010064f:	7e de                	jle    8010062f <panic+0x6a>
  panicked = 1; // freeze other CPU
80100651:	c7 05 00 00 11 80 01 	movl   $0x1,0x80110000
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
801006c4:	e8 4b 85 00 00       	call   80108c14 <graphic_scroll_up>
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
80100717:	e8 f8 84 00 00       	call   80108c14 <graphic_scroll_up>
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
8010077d:	e8 06 85 00 00       	call   80108c88 <font_render>
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
8010079f:	a1 00 00 11 80       	mov    0x80110000,%eax
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
801007bd:	e8 be 67 00 00       	call   80106f80 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 b1 67 00 00       	call   80106f80 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 a4 67 00 00       	call   80106f80 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 94 67 00 00       	call   80106f80 <uartputc>
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
80100814:	68 20 00 11 80       	push   $0x80110020
80100819:	e8 b2 49 00 00       	call   801051d0 <acquire>
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
80100866:	a1 88 5d 11 80       	mov    0x80115d88,%eax
8010086b:	83 e8 01             	sub    $0x1,%eax
8010086e:	a3 88 5d 11 80       	mov    %eax,0x80115d88
        consputc(BACKSPACE);
80100873:	83 ec 0c             	sub    $0xc,%esp
80100876:	68 00 01 00 00       	push   $0x100
8010087b:	e8 15 ff ff ff       	call   80100795 <consputc>
80100880:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100883:	8b 15 88 5d 11 80    	mov    0x80115d88,%edx
80100889:	a1 84 5d 11 80       	mov    0x80115d84,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 e2 00 00 00    	je     80100978 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100896:	a1 88 5d 11 80       	mov    0x80115d88,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	83 e0 7f             	and    $0x7f,%eax
801008a1:	0f b6 80 00 5d 11 80 	movzbl -0x7feea300(%eax),%eax
      while(input.e != input.w &&
801008a8:	3c 0a                	cmp    $0xa,%al
801008aa:	75 ba                	jne    80100866 <consoleintr+0x66>
      }
      break;
801008ac:	e9 c7 00 00 00       	jmp    80100978 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008b1:	8b 15 88 5d 11 80    	mov    0x80115d88,%edx
801008b7:	a1 84 5d 11 80       	mov    0x80115d84,%eax
801008bc:	39 c2                	cmp    %eax,%edx
801008be:	0f 84 b4 00 00 00    	je     80100978 <consoleintr+0x178>
        input.e--;
801008c4:	a1 88 5d 11 80       	mov    0x80115d88,%eax
801008c9:	83 e8 01             	sub    $0x1,%eax
801008cc:	a3 88 5d 11 80       	mov    %eax,0x80115d88
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
801008f0:	8b 15 88 5d 11 80    	mov    0x80115d88,%edx
801008f6:	a1 80 5d 11 80       	mov    0x80115d80,%eax
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
80100917:	a1 88 5d 11 80       	mov    0x80115d88,%eax
8010091c:	8d 50 01             	lea    0x1(%eax),%edx
8010091f:	89 15 88 5d 11 80    	mov    %edx,0x80115d88
80100925:	83 e0 7f             	and    $0x7f,%eax
80100928:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010092b:	88 90 00 5d 11 80    	mov    %dl,-0x7feea300(%eax)
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
8010094b:	a1 88 5d 11 80       	mov    0x80115d88,%eax
80100950:	8b 15 80 5d 11 80    	mov    0x80115d80,%edx
80100956:	83 ea 80             	sub    $0xffffff80,%edx
80100959:	39 d0                	cmp    %edx,%eax
8010095b:	75 1a                	jne    80100977 <consoleintr+0x177>
          input.w = input.e;
8010095d:	a1 88 5d 11 80       	mov    0x80115d88,%eax
80100962:	a3 84 5d 11 80       	mov    %eax,0x80115d84
          wakeup(&input.r);
80100967:	83 ec 0c             	sub    $0xc,%esp
8010096a:	68 80 5d 11 80       	push   $0x80115d80
8010096f:	e8 a4 43 00 00       	call   80104d18 <wakeup>
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
8010098d:	68 20 00 11 80       	push   $0x80110020
80100992:	e8 ab 48 00 00       	call   80105242 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 39 44 00 00       	call   80104dde <procdump>
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
801009b8:	e8 c4 11 00 00       	call   80101b81 <iunlock>
801009bd:	83 c4 10             	add    $0x10,%esp
  target = n;
801009c0:	8b 45 10             	mov    0x10(%ebp),%eax
801009c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	68 20 00 11 80       	push   $0x80110020
801009ce:	e8 fd 47 00 00       	call   801051d0 <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 af 36 00 00       	call   8010408f <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 00 11 80       	push   $0x80110020
801009ef:	e8 4e 48 00 00       	call   80105242 <release>
801009f4:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009f7:	83 ec 0c             	sub    $0xc,%esp
801009fa:	ff 75 08             	pushl  0x8(%ebp)
801009fd:	e8 68 10 00 00       	call   80101a6a <ilock>
80100a02:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a0a:	e9 ab 00 00 00       	jmp    80100aba <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a0f:	83 ec 08             	sub    $0x8,%esp
80100a12:	68 20 00 11 80       	push   $0x80110020
80100a17:	68 80 5d 11 80       	push   $0x80115d80
80100a1c:	e8 05 42 00 00       	call   80104c26 <sleep>
80100a21:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a24:	8b 15 80 5d 11 80    	mov    0x80115d80,%edx
80100a2a:	a1 84 5d 11 80       	mov    0x80115d84,%eax
80100a2f:	39 c2                	cmp    %eax,%edx
80100a31:	74 a8                	je     801009db <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a33:	a1 80 5d 11 80       	mov    0x80115d80,%eax
80100a38:	8d 50 01             	lea    0x1(%eax),%edx
80100a3b:	89 15 80 5d 11 80    	mov    %edx,0x80115d80
80100a41:	83 e0 7f             	and    $0x7f,%eax
80100a44:	0f b6 80 00 5d 11 80 	movzbl -0x7feea300(%eax),%eax
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
80100a5f:	a1 80 5d 11 80       	mov    0x80115d80,%eax
80100a64:	83 e8 01             	sub    $0x1,%eax
80100a67:	a3 80 5d 11 80       	mov    %eax,0x80115d80
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
80100a95:	68 20 00 11 80       	push   $0x80110020
80100a9a:	e8 a3 47 00 00       	call   80105242 <release>
80100a9f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100aa2:	83 ec 0c             	sub    $0xc,%esp
80100aa5:	ff 75 08             	pushl  0x8(%ebp)
80100aa8:	e8 bd 0f 00 00       	call   80101a6a <ilock>
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
80100acc:	e8 b0 10 00 00       	call   80101b81 <iunlock>
80100ad1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ad4:	83 ec 0c             	sub    $0xc,%esp
80100ad7:	68 20 00 11 80       	push   $0x80110020
80100adc:	e8 ef 46 00 00       	call   801051d0 <acquire>
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
80100b19:	68 20 00 11 80       	push   $0x80110020
80100b1e:	e8 1f 47 00 00       	call   80105242 <release>
80100b23:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b26:	83 ec 0c             	sub    $0xc,%esp
80100b29:	ff 75 08             	pushl  0x8(%ebp)
80100b2c:	e8 39 0f 00 00       	call   80101a6a <ilock>
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
80100b43:	c7 05 00 00 11 80 00 	movl   $0x0,0x80110000
80100b4a:	00 00 00 
  initlock(&cons.lock, "console");
80100b4d:	83 ec 08             	sub    $0x8,%esp
80100b50:	68 b7 ad 10 80       	push   $0x8010adb7
80100b55:	68 20 00 11 80       	push   $0x80110020
80100b5a:	e8 4b 46 00 00       	call   801051aa <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 4c 67 11 80 bc 	movl   $0x80100abc,0x8011674c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 48 67 11 80 a8 	movl   $0x801009a8,0x80116748
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 bf ad 10 80 	movl   $0x8010adbf,-0xc(%ebp)
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
80100ba2:	c7 05 54 00 11 80 01 	movl   $0x1,0x80110054
80100ba9:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bac:	83 ec 08             	sub    $0x8,%esp
80100baf:	6a 00                	push   $0x0
80100bb1:	6a 01                	push   $0x1
80100bb3:	e8 3a 20 00 00       	call   80102bf2 <ioapicenable>
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
80100bcb:	e8 bf 34 00 00       	call   8010408f <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

    begin_op();
80100bd3:	e8 7f 2a 00 00       	call   80103657 <begin_op>

    if ((ip = namei(path)) == 0) {
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	pushl  0x8(%ebp)
80100bde:	e8 f2 19 00 00       	call   801025d5 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
        end_op();
80100bef:	e8 f3 2a 00 00       	call   801036e7 <end_op>
        cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 d5 ad 10 80       	push   $0x8010add5
80100bfc:	e8 0b f8 ff ff       	call   8010040c <cprintf>
80100c01:	83 c4 10             	add    $0x10,%esp
        return -1;
80100c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c09:	e9 df 03 00 00       	jmp    80100fed <exec+0x42f>
    }
    ilock(ip);
80100c0e:	83 ec 0c             	sub    $0xc,%esp
80100c11:	ff 75 d8             	pushl  -0x28(%ebp)
80100c14:	e8 51 0e 00 00       	call   80101a6a <ilock>
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
80100c31:	e8 3c 13 00 00       	call   80101f72 <readi>
80100c36:	83 c4 10             	add    $0x10,%esp
80100c39:	83 f8 34             	cmp    $0x34,%eax
80100c3c:	0f 85 54 03 00 00    	jne    80100f96 <exec+0x3d8>
        goto bad;
    if (elf.magic != ELF_MAGIC)
80100c42:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c48:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4d:	0f 85 46 03 00 00    	jne    80100f99 <exec+0x3db>
        goto bad;

    if ((pgdir = setupkvm()) == 0)
80100c53:	e8 3c 73 00 00       	call   80107f94 <setupkvm>
80100c58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c5b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c5f:	0f 84 37 03 00 00    	je     80100f9c <exec+0x3de>
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
80100c91:	e8 dc 12 00 00       	call   80101f72 <readi>
80100c96:	83 c4 10             	add    $0x10,%esp
80100c99:	83 f8 20             	cmp    $0x20,%eax
80100c9c:	0f 85 fd 02 00 00    	jne    80100f9f <exec+0x3e1>
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
80100cbf:	0f 82 dd 02 00 00    	jb     80100fa2 <exec+0x3e4>
            goto bad;
        if (ph.vaddr + ph.memsz < ph.vaddr)
80100cc5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ccb:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cd1:	01 c2                	add    %eax,%edx
80100cd3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cd9:	39 c2                	cmp    %eax,%edx
80100cdb:	0f 82 c4 02 00 00    	jb     80100fa5 <exec+0x3e7>
            goto bad;
        if ((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ce1:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100ce7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ced:	01 d0                	add    %edx,%eax
80100cef:	83 ec 04             	sub    $0x4,%esp
80100cf2:	50                   	push   %eax
80100cf3:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf9:	e8 54 76 00 00       	call   80108352 <allocuvm>
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d08:	0f 84 9a 02 00 00    	je     80100fa8 <exec+0x3ea>
            goto bad;
        if (ph.vaddr % PGSIZE != 0)
80100d0e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d14:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d19:	85 c0                	test   %eax,%eax
80100d1b:	0f 85 8a 02 00 00    	jne    80100fab <exec+0x3ed>
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
80100d3f:	e8 3d 75 00 00       	call   80108281 <loaduvm>
80100d44:	83 c4 20             	add    $0x20,%esp
80100d47:	85 c0                	test   %eax,%eax
80100d49:	0f 88 5f 02 00 00    	js     80100fae <exec+0x3f0>
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
80100d78:	e8 2a 0f 00 00       	call   80101ca7 <iunlockput>
80100d7d:	83 c4 10             	add    $0x10,%esp
    end_op();
80100d80:	e8 62 29 00 00       	call   801036e7 <end_op>
    ip = 0;
80100d85:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

    // Allocate stack at the top address (below KERNBASE)
    sp = TOPBASE;
80100d8c:	c7 45 dc 00 f0 ff 7f 	movl   $0x7ffff000,-0x24(%ebp)
    if ((allocuvm(pgdir, sp - PGSIZE, sp)) == 0)
80100d93:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d96:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d9b:	83 ec 04             	sub    $0x4,%esp
80100d9e:	ff 75 dc             	pushl  -0x24(%ebp)
80100da1:	50                   	push   %eax
80100da2:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da5:	e8 a8 75 00 00       	call   80108352 <allocuvm>
80100daa:	83 c4 10             	add    $0x10,%esp
80100dad:	85 c0                	test   %eax,%eax
80100daf:	0f 84 fc 01 00 00    	je     80100fb1 <exec+0x3f3>
        goto bad;
    curproc->stack_alloc = 1;  // Initialize the stack allocation count
80100db5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100db8:	c7 80 80 00 00 00 01 	movl   $0x1,0x80(%eax)
80100dbf:	00 00 00 
    curproc->stack_top = sp;   // Set the stack top address
80100dc2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dc5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100dc8:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)

    // Push argument strings, prepare rest of stack in ustack.
    for (argc = 0; argv[argc]; argc++) {
80100dce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100dd5:	e9 96 00 00 00       	jmp    80100e70 <exec+0x2b2>
        if (argc >= MAXARG)
80100dda:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dde:	0f 87 d0 01 00 00    	ja     80100fb4 <exec+0x3f6>
            goto bad;
        sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dee:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df1:	01 d0                	add    %edx,%eax
80100df3:	8b 00                	mov    (%eax),%eax
80100df5:	83 ec 0c             	sub    $0xc,%esp
80100df8:	50                   	push   %eax
80100df9:	e8 ca 48 00 00       	call   801056c8 <strlen>
80100dfe:	83 c4 10             	add    $0x10,%esp
80100e01:	89 c2                	mov    %eax,%edx
80100e03:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e06:	29 d0                	sub    %edx,%eax
80100e08:	83 e8 01             	sub    $0x1,%eax
80100e0b:	83 e0 fc             	and    $0xfffffffc,%eax
80100e0e:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e1e:	01 d0                	add    %edx,%eax
80100e20:	8b 00                	mov    (%eax),%eax
80100e22:	83 ec 0c             	sub    $0xc,%esp
80100e25:	50                   	push   %eax
80100e26:	e8 9d 48 00 00       	call   801056c8 <strlen>
80100e2b:	83 c4 10             	add    $0x10,%esp
80100e2e:	83 c0 01             	add    $0x1,%eax
80100e31:	89 c1                	mov    %eax,%ecx
80100e33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e40:	01 d0                	add    %edx,%eax
80100e42:	8b 00                	mov    (%eax),%eax
80100e44:	51                   	push   %ecx
80100e45:	50                   	push   %eax
80100e46:	ff 75 dc             	pushl  -0x24(%ebp)
80100e49:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e4c:	e8 16 7a 00 00       	call   80108867 <copyout>
80100e51:	83 c4 10             	add    $0x10,%esp
80100e54:	85 c0                	test   %eax,%eax
80100e56:	0f 88 5b 01 00 00    	js     80100fb7 <exec+0x3f9>
            goto bad;
        ustack[3 + argc] = sp;
80100e5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5f:	8d 50 03             	lea    0x3(%eax),%edx
80100e62:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e65:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    for (argc = 0; argv[argc]; argc++) {
80100e6c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e73:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e7d:	01 d0                	add    %edx,%eax
80100e7f:	8b 00                	mov    (%eax),%eax
80100e81:	85 c0                	test   %eax,%eax
80100e83:	0f 85 51 ff ff ff    	jne    80100dda <exec+0x21c>
    }
    ustack[3 + argc] = 0;
80100e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8c:	83 c0 03             	add    $0x3,%eax
80100e8f:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e96:	00 00 00 00 

    ustack[0] = 0xffffffff;  // fake return PC
80100e9a:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100ea1:	ff ff ff 
    ustack[1] = argc;
80100ea4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea7:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
    ustack[2] = sp - (argc + 1) * 4;  // argv pointer
80100ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb0:	83 c0 01             	add    $0x1,%eax
80100eb3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100eba:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ebd:	29 d0                	sub    %edx,%eax
80100ebf:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

    sp -= (3 + argc + 1) * 4;
80100ec5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec8:	83 c0 04             	add    $0x4,%eax
80100ecb:	c1 e0 02             	shl    $0x2,%eax
80100ece:	29 45 dc             	sub    %eax,-0x24(%ebp)
    if (copyout(pgdir, sp, ustack, (3 + argc + 1) * 4) < 0)
80100ed1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed4:	83 c0 04             	add    $0x4,%eax
80100ed7:	c1 e0 02             	shl    $0x2,%eax
80100eda:	50                   	push   %eax
80100edb:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ee1:	50                   	push   %eax
80100ee2:	ff 75 dc             	pushl  -0x24(%ebp)
80100ee5:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ee8:	e8 7a 79 00 00       	call   80108867 <copyout>
80100eed:	83 c4 10             	add    $0x10,%esp
80100ef0:	85 c0                	test   %eax,%eax
80100ef2:	0f 88 c2 00 00 00    	js     80100fba <exec+0x3fc>
        goto bad;

    // Save program name for debugging.
    for (last = s = path; *s; s++)
80100ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80100efb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f01:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f04:	eb 17                	jmp    80100f1d <exec+0x35f>
        if (*s == '/')
80100f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f09:	0f b6 00             	movzbl (%eax),%eax
80100f0c:	3c 2f                	cmp    $0x2f,%al
80100f0e:	75 09                	jne    80100f19 <exec+0x35b>
            last = s + 1;
80100f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f13:	83 c0 01             	add    $0x1,%eax
80100f16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (last = s = path; *s; s++)
80100f19:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f20:	0f b6 00             	movzbl (%eax),%eax
80100f23:	84 c0                	test   %al,%al
80100f25:	75 df                	jne    80100f06 <exec+0x348>
    safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f27:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2a:	83 c0 6c             	add    $0x6c,%eax
80100f2d:	83 ec 04             	sub    $0x4,%esp
80100f30:	6a 10                	push   $0x10
80100f32:	ff 75 f0             	pushl  -0x10(%ebp)
80100f35:	50                   	push   %eax
80100f36:	e8 3f 47 00 00       	call   8010567a <safestrcpy>
80100f3b:	83 c4 10             	add    $0x10,%esp

    // Commit to the user image.
    oldpgdir = curproc->pgdir;
80100f3e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f41:	8b 40 04             	mov    0x4(%eax),%eax
80100f44:	89 45 cc             	mov    %eax,-0x34(%ebp)
    curproc->pgdir = pgdir;
80100f47:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f4a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f4d:	89 50 04             	mov    %edx,0x4(%eax)
    curproc->sz = sz;
80100f50:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f53:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f56:	89 10                	mov    %edx,(%eax)
    curproc->tf->eip = elf.entry;  // main
80100f58:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f5b:	8b 40 18             	mov    0x18(%eax),%eax
80100f5e:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f64:	89 50 38             	mov    %edx,0x38(%eax)
    curproc->tf->esp = sp;
80100f67:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f6a:	8b 40 18             	mov    0x18(%eax),%eax
80100f6d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f70:	89 50 44             	mov    %edx,0x44(%eax)
    switchuvm(curproc);
80100f73:	83 ec 0c             	sub    $0xc,%esp
80100f76:	ff 75 d0             	pushl  -0x30(%ebp)
80100f79:	e8 ec 70 00 00       	call   8010806a <switchuvm>
80100f7e:	83 c4 10             	add    $0x10,%esp
    freevm(oldpgdir);
80100f81:	83 ec 0c             	sub    $0xc,%esp
80100f84:	ff 75 cc             	pushl  -0x34(%ebp)
80100f87:	e8 97 75 00 00       	call   80108523 <freevm>
80100f8c:	83 c4 10             	add    $0x10,%esp
    return 0;
80100f8f:	b8 00 00 00 00       	mov    $0x0,%eax
80100f94:	eb 57                	jmp    80100fed <exec+0x42f>
        goto bad;
80100f96:	90                   	nop
80100f97:	eb 22                	jmp    80100fbb <exec+0x3fd>
        goto bad;
80100f99:	90                   	nop
80100f9a:	eb 1f                	jmp    80100fbb <exec+0x3fd>
        goto bad;
80100f9c:	90                   	nop
80100f9d:	eb 1c                	jmp    80100fbb <exec+0x3fd>
            goto bad;
80100f9f:	90                   	nop
80100fa0:	eb 19                	jmp    80100fbb <exec+0x3fd>
            goto bad;
80100fa2:	90                   	nop
80100fa3:	eb 16                	jmp    80100fbb <exec+0x3fd>
            goto bad;
80100fa5:	90                   	nop
80100fa6:	eb 13                	jmp    80100fbb <exec+0x3fd>
            goto bad;
80100fa8:	90                   	nop
80100fa9:	eb 10                	jmp    80100fbb <exec+0x3fd>
            goto bad;
80100fab:	90                   	nop
80100fac:	eb 0d                	jmp    80100fbb <exec+0x3fd>
            goto bad;
80100fae:	90                   	nop
80100faf:	eb 0a                	jmp    80100fbb <exec+0x3fd>
        goto bad;
80100fb1:	90                   	nop
80100fb2:	eb 07                	jmp    80100fbb <exec+0x3fd>
            goto bad;
80100fb4:	90                   	nop
80100fb5:	eb 04                	jmp    80100fbb <exec+0x3fd>
            goto bad;
80100fb7:	90                   	nop
80100fb8:	eb 01                	jmp    80100fbb <exec+0x3fd>
        goto bad;
80100fba:	90                   	nop

bad:
    if (pgdir)
80100fbb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fbf:	74 0e                	je     80100fcf <exec+0x411>
        freevm(pgdir);
80100fc1:	83 ec 0c             	sub    $0xc,%esp
80100fc4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fc7:	e8 57 75 00 00       	call   80108523 <freevm>
80100fcc:	83 c4 10             	add    $0x10,%esp
    if (ip) {
80100fcf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fd3:	74 13                	je     80100fe8 <exec+0x42a>
        iunlockput(ip);
80100fd5:	83 ec 0c             	sub    $0xc,%esp
80100fd8:	ff 75 d8             	pushl  -0x28(%ebp)
80100fdb:	e8 c7 0c 00 00       	call   80101ca7 <iunlockput>
80100fe0:	83 c4 10             	add    $0x10,%esp
        end_op();
80100fe3:	e8 ff 26 00 00       	call   801036e7 <end_op>
    }
    return -1;
80100fe8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fed:	c9                   	leave  
80100fee:	c3                   	ret    

80100fef <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fef:	f3 0f 1e fb          	endbr32 
80100ff3:	55                   	push   %ebp
80100ff4:	89 e5                	mov    %esp,%ebp
80100ff6:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100ff9:	83 ec 08             	sub    $0x8,%esp
80100ffc:	68 e1 ad 10 80       	push   $0x8010ade1
80101001:	68 a0 5d 11 80       	push   $0x80115da0
80101006:	e8 9f 41 00 00       	call   801051aa <initlock>
8010100b:	83 c4 10             	add    $0x10,%esp
}
8010100e:	90                   	nop
8010100f:	c9                   	leave  
80101010:	c3                   	ret    

80101011 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101011:	f3 0f 1e fb          	endbr32 
80101015:	55                   	push   %ebp
80101016:	89 e5                	mov    %esp,%ebp
80101018:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010101b:	83 ec 0c             	sub    $0xc,%esp
8010101e:	68 a0 5d 11 80       	push   $0x80115da0
80101023:	e8 a8 41 00 00       	call   801051d0 <acquire>
80101028:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102b:	c7 45 f4 d4 5d 11 80 	movl   $0x80115dd4,-0xc(%ebp)
80101032:	eb 2d                	jmp    80101061 <filealloc+0x50>
    if(f->ref == 0){
80101034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101037:	8b 40 04             	mov    0x4(%eax),%eax
8010103a:	85 c0                	test   %eax,%eax
8010103c:	75 1f                	jne    8010105d <filealloc+0x4c>
      f->ref = 1;
8010103e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101041:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101048:	83 ec 0c             	sub    $0xc,%esp
8010104b:	68 a0 5d 11 80       	push   $0x80115da0
80101050:	e8 ed 41 00 00       	call   80105242 <release>
80101055:	83 c4 10             	add    $0x10,%esp
      return f;
80101058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010105b:	eb 23                	jmp    80101080 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010105d:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101061:	b8 34 67 11 80       	mov    $0x80116734,%eax
80101066:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101069:	72 c9                	jb     80101034 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010106b:	83 ec 0c             	sub    $0xc,%esp
8010106e:	68 a0 5d 11 80       	push   $0x80115da0
80101073:	e8 ca 41 00 00       	call   80105242 <release>
80101078:	83 c4 10             	add    $0x10,%esp
  return 0;
8010107b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101080:	c9                   	leave  
80101081:	c3                   	ret    

80101082 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101082:	f3 0f 1e fb          	endbr32 
80101086:	55                   	push   %ebp
80101087:	89 e5                	mov    %esp,%ebp
80101089:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010108c:	83 ec 0c             	sub    $0xc,%esp
8010108f:	68 a0 5d 11 80       	push   $0x80115da0
80101094:	e8 37 41 00 00       	call   801051d0 <acquire>
80101099:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010109c:	8b 45 08             	mov    0x8(%ebp),%eax
8010109f:	8b 40 04             	mov    0x4(%eax),%eax
801010a2:	85 c0                	test   %eax,%eax
801010a4:	7f 0d                	jg     801010b3 <filedup+0x31>
    panic("filedup");
801010a6:	83 ec 0c             	sub    $0xc,%esp
801010a9:	68 e8 ad 10 80       	push   $0x8010ade8
801010ae:	e8 12 f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010b3:	8b 45 08             	mov    0x8(%ebp),%eax
801010b6:	8b 40 04             	mov    0x4(%eax),%eax
801010b9:	8d 50 01             	lea    0x1(%eax),%edx
801010bc:	8b 45 08             	mov    0x8(%ebp),%eax
801010bf:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010c2:	83 ec 0c             	sub    $0xc,%esp
801010c5:	68 a0 5d 11 80       	push   $0x80115da0
801010ca:	e8 73 41 00 00       	call   80105242 <release>
801010cf:	83 c4 10             	add    $0x10,%esp
  return f;
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010d5:	c9                   	leave  
801010d6:	c3                   	ret    

801010d7 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010d7:	f3 0f 1e fb          	endbr32 
801010db:	55                   	push   %ebp
801010dc:	89 e5                	mov    %esp,%ebp
801010de:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010e1:	83 ec 0c             	sub    $0xc,%esp
801010e4:	68 a0 5d 11 80       	push   $0x80115da0
801010e9:	e8 e2 40 00 00       	call   801051d0 <acquire>
801010ee:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010f1:	8b 45 08             	mov    0x8(%ebp),%eax
801010f4:	8b 40 04             	mov    0x4(%eax),%eax
801010f7:	85 c0                	test   %eax,%eax
801010f9:	7f 0d                	jg     80101108 <fileclose+0x31>
    panic("fileclose");
801010fb:	83 ec 0c             	sub    $0xc,%esp
801010fe:	68 f0 ad 10 80       	push   $0x8010adf0
80101103:	e8 bd f4 ff ff       	call   801005c5 <panic>
  if(--f->ref > 0){
80101108:	8b 45 08             	mov    0x8(%ebp),%eax
8010110b:	8b 40 04             	mov    0x4(%eax),%eax
8010110e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101111:	8b 45 08             	mov    0x8(%ebp),%eax
80101114:	89 50 04             	mov    %edx,0x4(%eax)
80101117:	8b 45 08             	mov    0x8(%ebp),%eax
8010111a:	8b 40 04             	mov    0x4(%eax),%eax
8010111d:	85 c0                	test   %eax,%eax
8010111f:	7e 15                	jle    80101136 <fileclose+0x5f>
    release(&ftable.lock);
80101121:	83 ec 0c             	sub    $0xc,%esp
80101124:	68 a0 5d 11 80       	push   $0x80115da0
80101129:	e8 14 41 00 00       	call   80105242 <release>
8010112e:	83 c4 10             	add    $0x10,%esp
80101131:	e9 8b 00 00 00       	jmp    801011c1 <fileclose+0xea>
    return;
  }
  ff = *f;
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	8b 10                	mov    (%eax),%edx
8010113b:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010113e:	8b 50 04             	mov    0x4(%eax),%edx
80101141:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101144:	8b 50 08             	mov    0x8(%eax),%edx
80101147:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010114a:	8b 50 0c             	mov    0xc(%eax),%edx
8010114d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101150:	8b 50 10             	mov    0x10(%eax),%edx
80101153:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101156:	8b 40 14             	mov    0x14(%eax),%eax
80101159:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010115c:	8b 45 08             	mov    0x8(%ebp),%eax
8010115f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101166:	8b 45 08             	mov    0x8(%ebp),%eax
80101169:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010116f:	83 ec 0c             	sub    $0xc,%esp
80101172:	68 a0 5d 11 80       	push   $0x80115da0
80101177:	e8 c6 40 00 00       	call   80105242 <release>
8010117c:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
8010117f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101182:	83 f8 01             	cmp    $0x1,%eax
80101185:	75 19                	jne    801011a0 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101187:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010118b:	0f be d0             	movsbl %al,%edx
8010118e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101191:	83 ec 08             	sub    $0x8,%esp
80101194:	52                   	push   %edx
80101195:	50                   	push   %eax
80101196:	e8 6b 2b 00 00       	call   80103d06 <pipeclose>
8010119b:	83 c4 10             	add    $0x10,%esp
8010119e:	eb 21                	jmp    801011c1 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011a3:	83 f8 02             	cmp    $0x2,%eax
801011a6:	75 19                	jne    801011c1 <fileclose+0xea>
    begin_op();
801011a8:	e8 aa 24 00 00       	call   80103657 <begin_op>
    iput(ff.ip);
801011ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011b0:	83 ec 0c             	sub    $0xc,%esp
801011b3:	50                   	push   %eax
801011b4:	e8 1a 0a 00 00       	call   80101bd3 <iput>
801011b9:	83 c4 10             	add    $0x10,%esp
    end_op();
801011bc:	e8 26 25 00 00       	call   801036e7 <end_op>
  }
}
801011c1:	c9                   	leave  
801011c2:	c3                   	ret    

801011c3 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011c3:	f3 0f 1e fb          	endbr32 
801011c7:	55                   	push   %ebp
801011c8:	89 e5                	mov    %esp,%ebp
801011ca:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011cd:	8b 45 08             	mov    0x8(%ebp),%eax
801011d0:	8b 00                	mov    (%eax),%eax
801011d2:	83 f8 02             	cmp    $0x2,%eax
801011d5:	75 40                	jne    80101217 <filestat+0x54>
    ilock(f->ip);
801011d7:	8b 45 08             	mov    0x8(%ebp),%eax
801011da:	8b 40 10             	mov    0x10(%eax),%eax
801011dd:	83 ec 0c             	sub    $0xc,%esp
801011e0:	50                   	push   %eax
801011e1:	e8 84 08 00 00       	call   80101a6a <ilock>
801011e6:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 40 10             	mov    0x10(%eax),%eax
801011ef:	83 ec 08             	sub    $0x8,%esp
801011f2:	ff 75 0c             	pushl  0xc(%ebp)
801011f5:	50                   	push   %eax
801011f6:	e8 2d 0d 00 00       	call   80101f28 <stati>
801011fb:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101201:	8b 40 10             	mov    0x10(%eax),%eax
80101204:	83 ec 0c             	sub    $0xc,%esp
80101207:	50                   	push   %eax
80101208:	e8 74 09 00 00       	call   80101b81 <iunlock>
8010120d:	83 c4 10             	add    $0x10,%esp
    return 0;
80101210:	b8 00 00 00 00       	mov    $0x0,%eax
80101215:	eb 05                	jmp    8010121c <filestat+0x59>
  }
  return -1;
80101217:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010121c:	c9                   	leave  
8010121d:	c3                   	ret    

8010121e <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010121e:	f3 0f 1e fb          	endbr32 
80101222:	55                   	push   %ebp
80101223:	89 e5                	mov    %esp,%ebp
80101225:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101228:	8b 45 08             	mov    0x8(%ebp),%eax
8010122b:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010122f:	84 c0                	test   %al,%al
80101231:	75 0a                	jne    8010123d <fileread+0x1f>
    return -1;
80101233:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101238:	e9 9b 00 00 00       	jmp    801012d8 <fileread+0xba>
  if(f->type == FD_PIPE)
8010123d:	8b 45 08             	mov    0x8(%ebp),%eax
80101240:	8b 00                	mov    (%eax),%eax
80101242:	83 f8 01             	cmp    $0x1,%eax
80101245:	75 1a                	jne    80101261 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101247:	8b 45 08             	mov    0x8(%ebp),%eax
8010124a:	8b 40 0c             	mov    0xc(%eax),%eax
8010124d:	83 ec 04             	sub    $0x4,%esp
80101250:	ff 75 10             	pushl  0x10(%ebp)
80101253:	ff 75 0c             	pushl  0xc(%ebp)
80101256:	50                   	push   %eax
80101257:	e8 5f 2c 00 00       	call   80103ebb <piperead>
8010125c:	83 c4 10             	add    $0x10,%esp
8010125f:	eb 77                	jmp    801012d8 <fileread+0xba>
  if(f->type == FD_INODE){
80101261:	8b 45 08             	mov    0x8(%ebp),%eax
80101264:	8b 00                	mov    (%eax),%eax
80101266:	83 f8 02             	cmp    $0x2,%eax
80101269:	75 60                	jne    801012cb <fileread+0xad>
    ilock(f->ip);
8010126b:	8b 45 08             	mov    0x8(%ebp),%eax
8010126e:	8b 40 10             	mov    0x10(%eax),%eax
80101271:	83 ec 0c             	sub    $0xc,%esp
80101274:	50                   	push   %eax
80101275:	e8 f0 07 00 00       	call   80101a6a <ilock>
8010127a:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010127d:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101280:	8b 45 08             	mov    0x8(%ebp),%eax
80101283:	8b 50 14             	mov    0x14(%eax),%edx
80101286:	8b 45 08             	mov    0x8(%ebp),%eax
80101289:	8b 40 10             	mov    0x10(%eax),%eax
8010128c:	51                   	push   %ecx
8010128d:	52                   	push   %edx
8010128e:	ff 75 0c             	pushl  0xc(%ebp)
80101291:	50                   	push   %eax
80101292:	e8 db 0c 00 00       	call   80101f72 <readi>
80101297:	83 c4 10             	add    $0x10,%esp
8010129a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010129d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012a1:	7e 11                	jle    801012b4 <fileread+0x96>
      f->off += r;
801012a3:	8b 45 08             	mov    0x8(%ebp),%eax
801012a6:	8b 50 14             	mov    0x14(%eax),%edx
801012a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ac:	01 c2                	add    %eax,%edx
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012b4:	8b 45 08             	mov    0x8(%ebp),%eax
801012b7:	8b 40 10             	mov    0x10(%eax),%eax
801012ba:	83 ec 0c             	sub    $0xc,%esp
801012bd:	50                   	push   %eax
801012be:	e8 be 08 00 00       	call   80101b81 <iunlock>
801012c3:	83 c4 10             	add    $0x10,%esp
    return r;
801012c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c9:	eb 0d                	jmp    801012d8 <fileread+0xba>
  }
  panic("fileread");
801012cb:	83 ec 0c             	sub    $0xc,%esp
801012ce:	68 fa ad 10 80       	push   $0x8010adfa
801012d3:	e8 ed f2 ff ff       	call   801005c5 <panic>
}
801012d8:	c9                   	leave  
801012d9:	c3                   	ret    

801012da <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012da:	f3 0f 1e fb          	endbr32 
801012de:	55                   	push   %ebp
801012df:	89 e5                	mov    %esp,%ebp
801012e1:	53                   	push   %ebx
801012e2:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012e5:	8b 45 08             	mov    0x8(%ebp),%eax
801012e8:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012ec:	84 c0                	test   %al,%al
801012ee:	75 0a                	jne    801012fa <filewrite+0x20>
    return -1;
801012f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f5:	e9 1b 01 00 00       	jmp    80101415 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801012fa:	8b 45 08             	mov    0x8(%ebp),%eax
801012fd:	8b 00                	mov    (%eax),%eax
801012ff:	83 f8 01             	cmp    $0x1,%eax
80101302:	75 1d                	jne    80101321 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101304:	8b 45 08             	mov    0x8(%ebp),%eax
80101307:	8b 40 0c             	mov    0xc(%eax),%eax
8010130a:	83 ec 04             	sub    $0x4,%esp
8010130d:	ff 75 10             	pushl  0x10(%ebp)
80101310:	ff 75 0c             	pushl  0xc(%ebp)
80101313:	50                   	push   %eax
80101314:	e8 9c 2a 00 00       	call   80103db5 <pipewrite>
80101319:	83 c4 10             	add    $0x10,%esp
8010131c:	e9 f4 00 00 00       	jmp    80101415 <filewrite+0x13b>
  if(f->type == FD_INODE){
80101321:	8b 45 08             	mov    0x8(%ebp),%eax
80101324:	8b 00                	mov    (%eax),%eax
80101326:	83 f8 02             	cmp    $0x2,%eax
80101329:	0f 85 d9 00 00 00    	jne    80101408 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
8010132f:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101336:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010133d:	e9 a3 00 00 00       	jmp    801013e5 <filewrite+0x10b>
      int n1 = n - i;
80101342:	8b 45 10             	mov    0x10(%ebp),%eax
80101345:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101348:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010134b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010134e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101351:	7e 06                	jle    80101359 <filewrite+0x7f>
        n1 = max;
80101353:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101356:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101359:	e8 f9 22 00 00       	call   80103657 <begin_op>
      ilock(f->ip);
8010135e:	8b 45 08             	mov    0x8(%ebp),%eax
80101361:	8b 40 10             	mov    0x10(%eax),%eax
80101364:	83 ec 0c             	sub    $0xc,%esp
80101367:	50                   	push   %eax
80101368:	e8 fd 06 00 00       	call   80101a6a <ilock>
8010136d:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101370:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101373:	8b 45 08             	mov    0x8(%ebp),%eax
80101376:	8b 50 14             	mov    0x14(%eax),%edx
80101379:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010137c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010137f:	01 c3                	add    %eax,%ebx
80101381:	8b 45 08             	mov    0x8(%ebp),%eax
80101384:	8b 40 10             	mov    0x10(%eax),%eax
80101387:	51                   	push   %ecx
80101388:	52                   	push   %edx
80101389:	53                   	push   %ebx
8010138a:	50                   	push   %eax
8010138b:	e8 3b 0d 00 00       	call   801020cb <writei>
80101390:	83 c4 10             	add    $0x10,%esp
80101393:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101396:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010139a:	7e 11                	jle    801013ad <filewrite+0xd3>
        f->off += r;
8010139c:	8b 45 08             	mov    0x8(%ebp),%eax
8010139f:	8b 50 14             	mov    0x14(%eax),%edx
801013a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a5:	01 c2                	add    %eax,%edx
801013a7:	8b 45 08             	mov    0x8(%ebp),%eax
801013aa:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013ad:	8b 45 08             	mov    0x8(%ebp),%eax
801013b0:	8b 40 10             	mov    0x10(%eax),%eax
801013b3:	83 ec 0c             	sub    $0xc,%esp
801013b6:	50                   	push   %eax
801013b7:	e8 c5 07 00 00       	call   80101b81 <iunlock>
801013bc:	83 c4 10             	add    $0x10,%esp
      end_op();
801013bf:	e8 23 23 00 00       	call   801036e7 <end_op>

      if(r < 0)
801013c4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013c8:	78 29                	js     801013f3 <filewrite+0x119>
        break;
      if(r != n1)
801013ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013cd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013d0:	74 0d                	je     801013df <filewrite+0x105>
        panic("short filewrite");
801013d2:	83 ec 0c             	sub    $0xc,%esp
801013d5:	68 03 ae 10 80       	push   $0x8010ae03
801013da:	e8 e6 f1 ff ff       	call   801005c5 <panic>
      i += r;
801013df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013e2:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e8:	3b 45 10             	cmp    0x10(%ebp),%eax
801013eb:	0f 8c 51 ff ff ff    	jl     80101342 <filewrite+0x68>
801013f1:	eb 01                	jmp    801013f4 <filewrite+0x11a>
        break;
801013f3:	90                   	nop
    }
    return i == n ? n : -1;
801013f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f7:	3b 45 10             	cmp    0x10(%ebp),%eax
801013fa:	75 05                	jne    80101401 <filewrite+0x127>
801013fc:	8b 45 10             	mov    0x10(%ebp),%eax
801013ff:	eb 14                	jmp    80101415 <filewrite+0x13b>
80101401:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101406:	eb 0d                	jmp    80101415 <filewrite+0x13b>
  }
  panic("filewrite");
80101408:	83 ec 0c             	sub    $0xc,%esp
8010140b:	68 13 ae 10 80       	push   $0x8010ae13
80101410:	e8 b0 f1 ff ff       	call   801005c5 <panic>
}
80101415:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101418:	c9                   	leave  
80101419:	c3                   	ret    

8010141a <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010141a:	f3 0f 1e fb          	endbr32 
8010141e:	55                   	push   %ebp
8010141f:	89 e5                	mov    %esp,%ebp
80101421:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101424:	8b 45 08             	mov    0x8(%ebp),%eax
80101427:	83 ec 08             	sub    $0x8,%esp
8010142a:	6a 01                	push   $0x1
8010142c:	50                   	push   %eax
8010142d:	e8 d7 ed ff ff       	call   80100209 <bread>
80101432:	83 c4 10             	add    $0x10,%esp
80101435:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010143b:	83 c0 5c             	add    $0x5c,%eax
8010143e:	83 ec 04             	sub    $0x4,%esp
80101441:	6a 1c                	push   $0x1c
80101443:	50                   	push   %eax
80101444:	ff 75 0c             	pushl  0xc(%ebp)
80101447:	e8 da 40 00 00       	call   80105526 <memmove>
8010144c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010144f:	83 ec 0c             	sub    $0xc,%esp
80101452:	ff 75 f4             	pushl  -0xc(%ebp)
80101455:	e8 39 ee ff ff       	call   80100293 <brelse>
8010145a:	83 c4 10             	add    $0x10,%esp
}
8010145d:	90                   	nop
8010145e:	c9                   	leave  
8010145f:	c3                   	ret    

80101460 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101460:	f3 0f 1e fb          	endbr32 
80101464:	55                   	push   %ebp
80101465:	89 e5                	mov    %esp,%ebp
80101467:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010146a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010146d:	8b 45 08             	mov    0x8(%ebp),%eax
80101470:	83 ec 08             	sub    $0x8,%esp
80101473:	52                   	push   %edx
80101474:	50                   	push   %eax
80101475:	e8 8f ed ff ff       	call   80100209 <bread>
8010147a:	83 c4 10             	add    $0x10,%esp
8010147d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101483:	83 c0 5c             	add    $0x5c,%eax
80101486:	83 ec 04             	sub    $0x4,%esp
80101489:	68 00 02 00 00       	push   $0x200
8010148e:	6a 00                	push   $0x0
80101490:	50                   	push   %eax
80101491:	e8 c9 3f 00 00       	call   8010545f <memset>
80101496:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101499:	83 ec 0c             	sub    $0xc,%esp
8010149c:	ff 75 f4             	pushl  -0xc(%ebp)
8010149f:	e8 fc 23 00 00       	call   801038a0 <log_write>
801014a4:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014a7:	83 ec 0c             	sub    $0xc,%esp
801014aa:	ff 75 f4             	pushl  -0xc(%ebp)
801014ad:	e8 e1 ed ff ff       	call   80100293 <brelse>
801014b2:	83 c4 10             	add    $0x10,%esp
}
801014b5:	90                   	nop
801014b6:	c9                   	leave  
801014b7:	c3                   	ret    

801014b8 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014b8:	f3 0f 1e fb          	endbr32 
801014bc:	55                   	push   %ebp
801014bd:	89 e5                	mov    %esp,%ebp
801014bf:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014c2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014d0:	e9 13 01 00 00       	jmp    801015e8 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801014d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d8:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014de:	85 c0                	test   %eax,%eax
801014e0:	0f 48 c2             	cmovs  %edx,%eax
801014e3:	c1 f8 0c             	sar    $0xc,%eax
801014e6:	89 c2                	mov    %eax,%edx
801014e8:	a1 b8 67 11 80       	mov    0x801167b8,%eax
801014ed:	01 d0                	add    %edx,%eax
801014ef:	83 ec 08             	sub    $0x8,%esp
801014f2:	50                   	push   %eax
801014f3:	ff 75 08             	pushl  0x8(%ebp)
801014f6:	e8 0e ed ff ff       	call   80100209 <bread>
801014fb:	83 c4 10             	add    $0x10,%esp
801014fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101501:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101508:	e9 a6 00 00 00       	jmp    801015b3 <balloc+0xfb>
      m = 1 << (bi % 8);
8010150d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101510:	99                   	cltd   
80101511:	c1 ea 1d             	shr    $0x1d,%edx
80101514:	01 d0                	add    %edx,%eax
80101516:	83 e0 07             	and    $0x7,%eax
80101519:	29 d0                	sub    %edx,%eax
8010151b:	ba 01 00 00 00       	mov    $0x1,%edx
80101520:	89 c1                	mov    %eax,%ecx
80101522:	d3 e2                	shl    %cl,%edx
80101524:	89 d0                	mov    %edx,%eax
80101526:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101529:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152c:	8d 50 07             	lea    0x7(%eax),%edx
8010152f:	85 c0                	test   %eax,%eax
80101531:	0f 48 c2             	cmovs  %edx,%eax
80101534:	c1 f8 03             	sar    $0x3,%eax
80101537:	89 c2                	mov    %eax,%edx
80101539:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010153c:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101541:	0f b6 c0             	movzbl %al,%eax
80101544:	23 45 e8             	and    -0x18(%ebp),%eax
80101547:	85 c0                	test   %eax,%eax
80101549:	75 64                	jne    801015af <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
8010154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154e:	8d 50 07             	lea    0x7(%eax),%edx
80101551:	85 c0                	test   %eax,%eax
80101553:	0f 48 c2             	cmovs  %edx,%eax
80101556:	c1 f8 03             	sar    $0x3,%eax
80101559:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010155c:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101561:	89 d1                	mov    %edx,%ecx
80101563:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101566:	09 ca                	or     %ecx,%edx
80101568:	89 d1                	mov    %edx,%ecx
8010156a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010156d:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101571:	83 ec 0c             	sub    $0xc,%esp
80101574:	ff 75 ec             	pushl  -0x14(%ebp)
80101577:	e8 24 23 00 00       	call   801038a0 <log_write>
8010157c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010157f:	83 ec 0c             	sub    $0xc,%esp
80101582:	ff 75 ec             	pushl  -0x14(%ebp)
80101585:	e8 09 ed ff ff       	call   80100293 <brelse>
8010158a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010158d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101590:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101593:	01 c2                	add    %eax,%edx
80101595:	8b 45 08             	mov    0x8(%ebp),%eax
80101598:	83 ec 08             	sub    $0x8,%esp
8010159b:	52                   	push   %edx
8010159c:	50                   	push   %eax
8010159d:	e8 be fe ff ff       	call   80101460 <bzero>
801015a2:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015ab:	01 d0                	add    %edx,%eax
801015ad:	eb 57                	jmp    80101606 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015af:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015b3:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015ba:	7f 17                	jg     801015d3 <balloc+0x11b>
801015bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c2:	01 d0                	add    %edx,%eax
801015c4:	89 c2                	mov    %eax,%edx
801015c6:	a1 a0 67 11 80       	mov    0x801167a0,%eax
801015cb:	39 c2                	cmp    %eax,%edx
801015cd:	0f 82 3a ff ff ff    	jb     8010150d <balloc+0x55>
      }
    }
    brelse(bp);
801015d3:	83 ec 0c             	sub    $0xc,%esp
801015d6:	ff 75 ec             	pushl  -0x14(%ebp)
801015d9:	e8 b5 ec ff ff       	call   80100293 <brelse>
801015de:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015e1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015e8:	8b 15 a0 67 11 80    	mov    0x801167a0,%edx
801015ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015f1:	39 c2                	cmp    %eax,%edx
801015f3:	0f 87 dc fe ff ff    	ja     801014d5 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801015f9:	83 ec 0c             	sub    $0xc,%esp
801015fc:	68 20 ae 10 80       	push   $0x8010ae20
80101601:	e8 bf ef ff ff       	call   801005c5 <panic>
}
80101606:	c9                   	leave  
80101607:	c3                   	ret    

80101608 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101608:	f3 0f 1e fb          	endbr32 
8010160c:	55                   	push   %ebp
8010160d:	89 e5                	mov    %esp,%ebp
8010160f:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101612:	83 ec 08             	sub    $0x8,%esp
80101615:	68 a0 67 11 80       	push   $0x801167a0
8010161a:	ff 75 08             	pushl  0x8(%ebp)
8010161d:	e8 f8 fd ff ff       	call   8010141a <readsb>
80101622:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101625:	8b 45 0c             	mov    0xc(%ebp),%eax
80101628:	c1 e8 0c             	shr    $0xc,%eax
8010162b:	89 c2                	mov    %eax,%edx
8010162d:	a1 b8 67 11 80       	mov    0x801167b8,%eax
80101632:	01 c2                	add    %eax,%edx
80101634:	8b 45 08             	mov    0x8(%ebp),%eax
80101637:	83 ec 08             	sub    $0x8,%esp
8010163a:	52                   	push   %edx
8010163b:	50                   	push   %eax
8010163c:	e8 c8 eb ff ff       	call   80100209 <bread>
80101641:	83 c4 10             	add    $0x10,%esp
80101644:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101647:	8b 45 0c             	mov    0xc(%ebp),%eax
8010164a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010164f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101652:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101655:	99                   	cltd   
80101656:	c1 ea 1d             	shr    $0x1d,%edx
80101659:	01 d0                	add    %edx,%eax
8010165b:	83 e0 07             	and    $0x7,%eax
8010165e:	29 d0                	sub    %edx,%eax
80101660:	ba 01 00 00 00       	mov    $0x1,%edx
80101665:	89 c1                	mov    %eax,%ecx
80101667:	d3 e2                	shl    %cl,%edx
80101669:	89 d0                	mov    %edx,%eax
8010166b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010166e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101671:	8d 50 07             	lea    0x7(%eax),%edx
80101674:	85 c0                	test   %eax,%eax
80101676:	0f 48 c2             	cmovs  %edx,%eax
80101679:	c1 f8 03             	sar    $0x3,%eax
8010167c:	89 c2                	mov    %eax,%edx
8010167e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101681:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101686:	0f b6 c0             	movzbl %al,%eax
80101689:	23 45 ec             	and    -0x14(%ebp),%eax
8010168c:	85 c0                	test   %eax,%eax
8010168e:	75 0d                	jne    8010169d <bfree+0x95>
    panic("freeing free block");
80101690:	83 ec 0c             	sub    $0xc,%esp
80101693:	68 36 ae 10 80       	push   $0x8010ae36
80101698:	e8 28 ef ff ff       	call   801005c5 <panic>
  bp->data[bi/8] &= ~m;
8010169d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a0:	8d 50 07             	lea    0x7(%eax),%edx
801016a3:	85 c0                	test   %eax,%eax
801016a5:	0f 48 c2             	cmovs  %edx,%eax
801016a8:	c1 f8 03             	sar    $0x3,%eax
801016ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ae:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016b3:	89 d1                	mov    %edx,%ecx
801016b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016b8:	f7 d2                	not    %edx
801016ba:	21 ca                	and    %ecx,%edx
801016bc:	89 d1                	mov    %edx,%ecx
801016be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016c1:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016c5:	83 ec 0c             	sub    $0xc,%esp
801016c8:	ff 75 f4             	pushl  -0xc(%ebp)
801016cb:	e8 d0 21 00 00       	call   801038a0 <log_write>
801016d0:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016d3:	83 ec 0c             	sub    $0xc,%esp
801016d6:	ff 75 f4             	pushl  -0xc(%ebp)
801016d9:	e8 b5 eb ff ff       	call   80100293 <brelse>
801016de:	83 c4 10             	add    $0x10,%esp
}
801016e1:	90                   	nop
801016e2:	c9                   	leave  
801016e3:	c3                   	ret    

801016e4 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016e4:	f3 0f 1e fb          	endbr32 
801016e8:	55                   	push   %ebp
801016e9:	89 e5                	mov    %esp,%ebp
801016eb:	57                   	push   %edi
801016ec:	56                   	push   %esi
801016ed:	53                   	push   %ebx
801016ee:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
801016f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801016f8:	83 ec 08             	sub    $0x8,%esp
801016fb:	68 49 ae 10 80       	push   $0x8010ae49
80101700:	68 c0 67 11 80       	push   $0x801167c0
80101705:	e8 a0 3a 00 00       	call   801051aa <initlock>
8010170a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010170d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101714:	eb 2d                	jmp    80101743 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101716:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101719:	89 d0                	mov    %edx,%eax
8010171b:	c1 e0 03             	shl    $0x3,%eax
8010171e:	01 d0                	add    %edx,%eax
80101720:	c1 e0 04             	shl    $0x4,%eax
80101723:	83 c0 30             	add    $0x30,%eax
80101726:	05 c0 67 11 80       	add    $0x801167c0,%eax
8010172b:	83 c0 10             	add    $0x10,%eax
8010172e:	83 ec 08             	sub    $0x8,%esp
80101731:	68 50 ae 10 80       	push   $0x8010ae50
80101736:	50                   	push   %eax
80101737:	e8 01 39 00 00       	call   8010503d <initsleeplock>
8010173c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010173f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101743:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101747:	7e cd                	jle    80101716 <iinit+0x32>
  }

  readsb(dev, &sb);
80101749:	83 ec 08             	sub    $0x8,%esp
8010174c:	68 a0 67 11 80       	push   $0x801167a0
80101751:	ff 75 08             	pushl  0x8(%ebp)
80101754:	e8 c1 fc ff ff       	call   8010141a <readsb>
80101759:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010175c:	a1 b8 67 11 80       	mov    0x801167b8,%eax
80101761:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101764:	8b 3d b4 67 11 80    	mov    0x801167b4,%edi
8010176a:	8b 35 b0 67 11 80    	mov    0x801167b0,%esi
80101770:	8b 1d ac 67 11 80    	mov    0x801167ac,%ebx
80101776:	8b 0d a8 67 11 80    	mov    0x801167a8,%ecx
8010177c:	8b 15 a4 67 11 80    	mov    0x801167a4,%edx
80101782:	a1 a0 67 11 80       	mov    0x801167a0,%eax
80101787:	ff 75 d4             	pushl  -0x2c(%ebp)
8010178a:	57                   	push   %edi
8010178b:	56                   	push   %esi
8010178c:	53                   	push   %ebx
8010178d:	51                   	push   %ecx
8010178e:	52                   	push   %edx
8010178f:	50                   	push   %eax
80101790:	68 58 ae 10 80       	push   $0x8010ae58
80101795:	e8 72 ec ff ff       	call   8010040c <cprintf>
8010179a:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
8010179d:	90                   	nop
8010179e:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017a1:	5b                   	pop    %ebx
801017a2:	5e                   	pop    %esi
801017a3:	5f                   	pop    %edi
801017a4:	5d                   	pop    %ebp
801017a5:	c3                   	ret    

801017a6 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017a6:	f3 0f 1e fb          	endbr32 
801017aa:	55                   	push   %ebp
801017ab:	89 e5                	mov    %esp,%ebp
801017ad:	83 ec 28             	sub    $0x28,%esp
801017b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801017b3:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017b7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017be:	e9 9e 00 00 00       	jmp    80101861 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c6:	c1 e8 03             	shr    $0x3,%eax
801017c9:	89 c2                	mov    %eax,%edx
801017cb:	a1 b4 67 11 80       	mov    0x801167b4,%eax
801017d0:	01 d0                	add    %edx,%eax
801017d2:	83 ec 08             	sub    $0x8,%esp
801017d5:	50                   	push   %eax
801017d6:	ff 75 08             	pushl  0x8(%ebp)
801017d9:	e8 2b ea ff ff       	call   80100209 <bread>
801017de:	83 c4 10             	add    $0x10,%esp
801017e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e7:	8d 50 5c             	lea    0x5c(%eax),%edx
801017ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ed:	83 e0 07             	and    $0x7,%eax
801017f0:	c1 e0 06             	shl    $0x6,%eax
801017f3:	01 d0                	add    %edx,%eax
801017f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017fb:	0f b7 00             	movzwl (%eax),%eax
801017fe:	66 85 c0             	test   %ax,%ax
80101801:	75 4c                	jne    8010184f <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101803:	83 ec 04             	sub    $0x4,%esp
80101806:	6a 40                	push   $0x40
80101808:	6a 00                	push   $0x0
8010180a:	ff 75 ec             	pushl  -0x14(%ebp)
8010180d:	e8 4d 3c 00 00       	call   8010545f <memset>
80101812:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101815:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101818:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010181c:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010181f:	83 ec 0c             	sub    $0xc,%esp
80101822:	ff 75 f0             	pushl  -0x10(%ebp)
80101825:	e8 76 20 00 00       	call   801038a0 <log_write>
8010182a:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010182d:	83 ec 0c             	sub    $0xc,%esp
80101830:	ff 75 f0             	pushl  -0x10(%ebp)
80101833:	e8 5b ea ff ff       	call   80100293 <brelse>
80101838:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010183b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183e:	83 ec 08             	sub    $0x8,%esp
80101841:	50                   	push   %eax
80101842:	ff 75 08             	pushl  0x8(%ebp)
80101845:	e8 fc 00 00 00       	call   80101946 <iget>
8010184a:	83 c4 10             	add    $0x10,%esp
8010184d:	eb 30                	jmp    8010187f <ialloc+0xd9>
    }
    brelse(bp);
8010184f:	83 ec 0c             	sub    $0xc,%esp
80101852:	ff 75 f0             	pushl  -0x10(%ebp)
80101855:	e8 39 ea ff ff       	call   80100293 <brelse>
8010185a:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010185d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101861:	8b 15 a8 67 11 80    	mov    0x801167a8,%edx
80101867:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186a:	39 c2                	cmp    %eax,%edx
8010186c:	0f 87 51 ff ff ff    	ja     801017c3 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101872:	83 ec 0c             	sub    $0xc,%esp
80101875:	68 ab ae 10 80       	push   $0x8010aeab
8010187a:	e8 46 ed ff ff       	call   801005c5 <panic>
}
8010187f:	c9                   	leave  
80101880:	c3                   	ret    

80101881 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101881:	f3 0f 1e fb          	endbr32 
80101885:	55                   	push   %ebp
80101886:	89 e5                	mov    %esp,%ebp
80101888:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010188b:	8b 45 08             	mov    0x8(%ebp),%eax
8010188e:	8b 40 04             	mov    0x4(%eax),%eax
80101891:	c1 e8 03             	shr    $0x3,%eax
80101894:	89 c2                	mov    %eax,%edx
80101896:	a1 b4 67 11 80       	mov    0x801167b4,%eax
8010189b:	01 c2                	add    %eax,%edx
8010189d:	8b 45 08             	mov    0x8(%ebp),%eax
801018a0:	8b 00                	mov    (%eax),%eax
801018a2:	83 ec 08             	sub    $0x8,%esp
801018a5:	52                   	push   %edx
801018a6:	50                   	push   %eax
801018a7:	e8 5d e9 ff ff       	call   80100209 <bread>
801018ac:	83 c4 10             	add    $0x10,%esp
801018af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b5:	8d 50 5c             	lea    0x5c(%eax),%edx
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8b 40 04             	mov    0x4(%eax),%eax
801018be:	83 e0 07             	and    $0x7,%eax
801018c1:	c1 e0 06             	shl    $0x6,%eax
801018c4:	01 d0                	add    %edx,%eax
801018c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018c9:	8b 45 08             	mov    0x8(%ebp),%eax
801018cc:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801018d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d3:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801018d6:	8b 45 08             	mov    0x8(%ebp),%eax
801018d9:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801018dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e0:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018e4:	8b 45 08             	mov    0x8(%ebp),%eax
801018e7:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801018eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ee:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018f2:	8b 45 08             	mov    0x8(%ebp),%eax
801018f5:	0f b7 50 56          	movzwl 0x56(%eax),%edx
801018f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018fc:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101900:	8b 45 08             	mov    0x8(%ebp),%eax
80101903:	8b 50 58             	mov    0x58(%eax),%edx
80101906:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101909:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010190c:	8b 45 08             	mov    0x8(%ebp),%eax
8010190f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101912:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101915:	83 c0 0c             	add    $0xc,%eax
80101918:	83 ec 04             	sub    $0x4,%esp
8010191b:	6a 34                	push   $0x34
8010191d:	52                   	push   %edx
8010191e:	50                   	push   %eax
8010191f:	e8 02 3c 00 00       	call   80105526 <memmove>
80101924:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101927:	83 ec 0c             	sub    $0xc,%esp
8010192a:	ff 75 f4             	pushl  -0xc(%ebp)
8010192d:	e8 6e 1f 00 00       	call   801038a0 <log_write>
80101932:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101935:	83 ec 0c             	sub    $0xc,%esp
80101938:	ff 75 f4             	pushl  -0xc(%ebp)
8010193b:	e8 53 e9 ff ff       	call   80100293 <brelse>
80101940:	83 c4 10             	add    $0x10,%esp
}
80101943:	90                   	nop
80101944:	c9                   	leave  
80101945:	c3                   	ret    

80101946 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101946:	f3 0f 1e fb          	endbr32 
8010194a:	55                   	push   %ebp
8010194b:	89 e5                	mov    %esp,%ebp
8010194d:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101950:	83 ec 0c             	sub    $0xc,%esp
80101953:	68 c0 67 11 80       	push   $0x801167c0
80101958:	e8 73 38 00 00       	call   801051d0 <acquire>
8010195d:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101960:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101967:	c7 45 f4 f4 67 11 80 	movl   $0x801167f4,-0xc(%ebp)
8010196e:	eb 60                	jmp    801019d0 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101973:	8b 40 08             	mov    0x8(%eax),%eax
80101976:	85 c0                	test   %eax,%eax
80101978:	7e 39                	jle    801019b3 <iget+0x6d>
8010197a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197d:	8b 00                	mov    (%eax),%eax
8010197f:	39 45 08             	cmp    %eax,0x8(%ebp)
80101982:	75 2f                	jne    801019b3 <iget+0x6d>
80101984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101987:	8b 40 04             	mov    0x4(%eax),%eax
8010198a:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010198d:	75 24                	jne    801019b3 <iget+0x6d>
      ip->ref++;
8010198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101992:	8b 40 08             	mov    0x8(%eax),%eax
80101995:	8d 50 01             	lea    0x1(%eax),%edx
80101998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199b:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010199e:	83 ec 0c             	sub    $0xc,%esp
801019a1:	68 c0 67 11 80       	push   $0x801167c0
801019a6:	e8 97 38 00 00       	call   80105242 <release>
801019ab:	83 c4 10             	add    $0x10,%esp
      return ip;
801019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b1:	eb 77                	jmp    80101a2a <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019b7:	75 10                	jne    801019c9 <iget+0x83>
801019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019bc:	8b 40 08             	mov    0x8(%eax),%eax
801019bf:	85 c0                	test   %eax,%eax
801019c1:	75 06                	jne    801019c9 <iget+0x83>
      empty = ip;
801019c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019c9:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801019d0:	81 7d f4 14 84 11 80 	cmpl   $0x80118414,-0xc(%ebp)
801019d7:	72 97                	jb     80101970 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019dd:	75 0d                	jne    801019ec <iget+0xa6>
    panic("iget: no inodes");
801019df:	83 ec 0c             	sub    $0xc,%esp
801019e2:	68 bd ae 10 80       	push   $0x8010aebd
801019e7:	e8 d9 eb ff ff       	call   801005c5 <panic>

  ip = empty;
801019ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f5:	8b 55 08             	mov    0x8(%ebp),%edx
801019f8:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a00:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a06:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a10:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a17:	83 ec 0c             	sub    $0xc,%esp
80101a1a:	68 c0 67 11 80       	push   $0x801167c0
80101a1f:	e8 1e 38 00 00       	call   80105242 <release>
80101a24:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a2a:	c9                   	leave  
80101a2b:	c3                   	ret    

80101a2c <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a2c:	f3 0f 1e fb          	endbr32 
80101a30:	55                   	push   %ebp
80101a31:	89 e5                	mov    %esp,%ebp
80101a33:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a36:	83 ec 0c             	sub    $0xc,%esp
80101a39:	68 c0 67 11 80       	push   $0x801167c0
80101a3e:	e8 8d 37 00 00       	call   801051d0 <acquire>
80101a43:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a46:	8b 45 08             	mov    0x8(%ebp),%eax
80101a49:	8b 40 08             	mov    0x8(%eax),%eax
80101a4c:	8d 50 01             	lea    0x1(%eax),%edx
80101a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a52:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a55:	83 ec 0c             	sub    $0xc,%esp
80101a58:	68 c0 67 11 80       	push   $0x801167c0
80101a5d:	e8 e0 37 00 00       	call   80105242 <release>
80101a62:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a65:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a68:	c9                   	leave  
80101a69:	c3                   	ret    

80101a6a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a6a:	f3 0f 1e fb          	endbr32 
80101a6e:	55                   	push   %ebp
80101a6f:	89 e5                	mov    %esp,%ebp
80101a71:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a74:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a78:	74 0a                	je     80101a84 <ilock+0x1a>
80101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7d:	8b 40 08             	mov    0x8(%eax),%eax
80101a80:	85 c0                	test   %eax,%eax
80101a82:	7f 0d                	jg     80101a91 <ilock+0x27>
    panic("ilock");
80101a84:	83 ec 0c             	sub    $0xc,%esp
80101a87:	68 cd ae 10 80       	push   $0x8010aecd
80101a8c:	e8 34 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101a91:	8b 45 08             	mov    0x8(%ebp),%eax
80101a94:	83 c0 0c             	add    $0xc,%eax
80101a97:	83 ec 0c             	sub    $0xc,%esp
80101a9a:	50                   	push   %eax
80101a9b:	e8 dd 35 00 00       	call   8010507d <acquiresleep>
80101aa0:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	8b 40 4c             	mov    0x4c(%eax),%eax
80101aa9:	85 c0                	test   %eax,%eax
80101aab:	0f 85 cd 00 00 00    	jne    80101b7e <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab4:	8b 40 04             	mov    0x4(%eax),%eax
80101ab7:	c1 e8 03             	shr    $0x3,%eax
80101aba:	89 c2                	mov    %eax,%edx
80101abc:	a1 b4 67 11 80       	mov    0x801167b4,%eax
80101ac1:	01 c2                	add    %eax,%edx
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	8b 00                	mov    (%eax),%eax
80101ac8:	83 ec 08             	sub    $0x8,%esp
80101acb:	52                   	push   %edx
80101acc:	50                   	push   %eax
80101acd:	e8 37 e7 ff ff       	call   80100209 <bread>
80101ad2:	83 c4 10             	add    $0x10,%esp
80101ad5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101adb:	8d 50 5c             	lea    0x5c(%eax),%edx
80101ade:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae1:	8b 40 04             	mov    0x4(%eax),%eax
80101ae4:	83 e0 07             	and    $0x7,%eax
80101ae7:	c1 e0 06             	shl    $0x6,%eax
80101aea:	01 d0                	add    %edx,%eax
80101aec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af2:	0f b7 10             	movzwl (%eax),%edx
80101af5:	8b 45 08             	mov    0x8(%ebp),%eax
80101af8:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aff:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b03:	8b 45 08             	mov    0x8(%ebp),%eax
80101b06:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b0d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b22:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b29:	8b 50 08             	mov    0x8(%eax),%edx
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b35:	8d 50 0c             	lea    0xc(%eax),%edx
80101b38:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3b:	83 c0 5c             	add    $0x5c,%eax
80101b3e:	83 ec 04             	sub    $0x4,%esp
80101b41:	6a 34                	push   $0x34
80101b43:	52                   	push   %edx
80101b44:	50                   	push   %eax
80101b45:	e8 dc 39 00 00       	call   80105526 <memmove>
80101b4a:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b4d:	83 ec 0c             	sub    $0xc,%esp
80101b50:	ff 75 f4             	pushl  -0xc(%ebp)
80101b53:	e8 3b e7 ff ff       	call   80100293 <brelse>
80101b58:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5e:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101b6c:	66 85 c0             	test   %ax,%ax
80101b6f:	75 0d                	jne    80101b7e <ilock+0x114>
      panic("ilock: no type");
80101b71:	83 ec 0c             	sub    $0xc,%esp
80101b74:	68 d3 ae 10 80       	push   $0x8010aed3
80101b79:	e8 47 ea ff ff       	call   801005c5 <panic>
  }
}
80101b7e:	90                   	nop
80101b7f:	c9                   	leave  
80101b80:	c3                   	ret    

80101b81 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b81:	f3 0f 1e fb          	endbr32 
80101b85:	55                   	push   %ebp
80101b86:	89 e5                	mov    %esp,%ebp
80101b88:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b8b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b8f:	74 20                	je     80101bb1 <iunlock+0x30>
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	83 c0 0c             	add    $0xc,%eax
80101b97:	83 ec 0c             	sub    $0xc,%esp
80101b9a:	50                   	push   %eax
80101b9b:	e8 97 35 00 00       	call   80105137 <holdingsleep>
80101ba0:	83 c4 10             	add    $0x10,%esp
80101ba3:	85 c0                	test   %eax,%eax
80101ba5:	74 0a                	je     80101bb1 <iunlock+0x30>
80101ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80101baa:	8b 40 08             	mov    0x8(%eax),%eax
80101bad:	85 c0                	test   %eax,%eax
80101baf:	7f 0d                	jg     80101bbe <iunlock+0x3d>
    panic("iunlock");
80101bb1:	83 ec 0c             	sub    $0xc,%esp
80101bb4:	68 e2 ae 10 80       	push   $0x8010aee2
80101bb9:	e8 07 ea ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	83 c0 0c             	add    $0xc,%eax
80101bc4:	83 ec 0c             	sub    $0xc,%esp
80101bc7:	50                   	push   %eax
80101bc8:	e8 18 35 00 00       	call   801050e5 <releasesleep>
80101bcd:	83 c4 10             	add    $0x10,%esp
}
80101bd0:	90                   	nop
80101bd1:	c9                   	leave  
80101bd2:	c3                   	ret    

80101bd3 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bd3:	f3 0f 1e fb          	endbr32 
80101bd7:	55                   	push   %ebp
80101bd8:	89 e5                	mov    %esp,%ebp
80101bda:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101be0:	83 c0 0c             	add    $0xc,%eax
80101be3:	83 ec 0c             	sub    $0xc,%esp
80101be6:	50                   	push   %eax
80101be7:	e8 91 34 00 00       	call   8010507d <acquiresleep>
80101bec:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bf5:	85 c0                	test   %eax,%eax
80101bf7:	74 6a                	je     80101c63 <iput+0x90>
80101bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfc:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c00:	66 85 c0             	test   %ax,%ax
80101c03:	75 5e                	jne    80101c63 <iput+0x90>
    acquire(&icache.lock);
80101c05:	83 ec 0c             	sub    $0xc,%esp
80101c08:	68 c0 67 11 80       	push   $0x801167c0
80101c0d:	e8 be 35 00 00       	call   801051d0 <acquire>
80101c12:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c15:	8b 45 08             	mov    0x8(%ebp),%eax
80101c18:	8b 40 08             	mov    0x8(%eax),%eax
80101c1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c1e:	83 ec 0c             	sub    $0xc,%esp
80101c21:	68 c0 67 11 80       	push   $0x801167c0
80101c26:	e8 17 36 00 00       	call   80105242 <release>
80101c2b:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c2e:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c32:	75 2f                	jne    80101c63 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c34:	83 ec 0c             	sub    $0xc,%esp
80101c37:	ff 75 08             	pushl  0x8(%ebp)
80101c3a:	e8 b5 01 00 00       	call   80101df4 <itrunc>
80101c3f:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c42:	8b 45 08             	mov    0x8(%ebp),%eax
80101c45:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c4b:	83 ec 0c             	sub    $0xc,%esp
80101c4e:	ff 75 08             	pushl  0x8(%ebp)
80101c51:	e8 2b fc ff ff       	call   80101881 <iupdate>
80101c56:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c59:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5c:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	83 c0 0c             	add    $0xc,%eax
80101c69:	83 ec 0c             	sub    $0xc,%esp
80101c6c:	50                   	push   %eax
80101c6d:	e8 73 34 00 00       	call   801050e5 <releasesleep>
80101c72:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c75:	83 ec 0c             	sub    $0xc,%esp
80101c78:	68 c0 67 11 80       	push   $0x801167c0
80101c7d:	e8 4e 35 00 00       	call   801051d0 <acquire>
80101c82:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c85:	8b 45 08             	mov    0x8(%ebp),%eax
80101c88:	8b 40 08             	mov    0x8(%eax),%eax
80101c8b:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c91:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c94:	83 ec 0c             	sub    $0xc,%esp
80101c97:	68 c0 67 11 80       	push   $0x801167c0
80101c9c:	e8 a1 35 00 00       	call   80105242 <release>
80101ca1:	83 c4 10             	add    $0x10,%esp
}
80101ca4:	90                   	nop
80101ca5:	c9                   	leave  
80101ca6:	c3                   	ret    

80101ca7 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101ca7:	f3 0f 1e fb          	endbr32 
80101cab:	55                   	push   %ebp
80101cac:	89 e5                	mov    %esp,%ebp
80101cae:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cb1:	83 ec 0c             	sub    $0xc,%esp
80101cb4:	ff 75 08             	pushl  0x8(%ebp)
80101cb7:	e8 c5 fe ff ff       	call   80101b81 <iunlock>
80101cbc:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cbf:	83 ec 0c             	sub    $0xc,%esp
80101cc2:	ff 75 08             	pushl  0x8(%ebp)
80101cc5:	e8 09 ff ff ff       	call   80101bd3 <iput>
80101cca:	83 c4 10             	add    $0x10,%esp
}
80101ccd:	90                   	nop
80101cce:	c9                   	leave  
80101ccf:	c3                   	ret    

80101cd0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cd0:	f3 0f 1e fb          	endbr32 
80101cd4:	55                   	push   %ebp
80101cd5:	89 e5                	mov    %esp,%ebp
80101cd7:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cda:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cde:	77 42                	ja     80101d22 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ce6:	83 c2 14             	add    $0x14,%edx
80101ce9:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ced:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cf4:	75 24                	jne    80101d1a <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 00                	mov    (%eax),%eax
80101cfb:	83 ec 0c             	sub    $0xc,%esp
80101cfe:	50                   	push   %eax
80101cff:	e8 b4 f7 ff ff       	call   801014b8 <balloc>
80101d04:	83 c4 10             	add    $0x10,%esp
80101d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d10:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d13:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d16:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d1d:	e9 d0 00 00 00       	jmp    80101df2 <bmap+0x122>
  }
  bn -= NDIRECT;
80101d22:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d26:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d2a:	0f 87 b5 00 00 00    	ja     80101de5 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d39:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d40:	75 20                	jne    80101d62 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 00                	mov    (%eax),%eax
80101d47:	83 ec 0c             	sub    $0xc,%esp
80101d4a:	50                   	push   %eax
80101d4b:	e8 68 f7 ff ff       	call   801014b8 <balloc>
80101d50:	83 c4 10             	add    $0x10,%esp
80101d53:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d56:	8b 45 08             	mov    0x8(%ebp),%eax
80101d59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d5c:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d62:	8b 45 08             	mov    0x8(%ebp),%eax
80101d65:	8b 00                	mov    (%eax),%eax
80101d67:	83 ec 08             	sub    $0x8,%esp
80101d6a:	ff 75 f4             	pushl  -0xc(%ebp)
80101d6d:	50                   	push   %eax
80101d6e:	e8 96 e4 ff ff       	call   80100209 <bread>
80101d73:	83 c4 10             	add    $0x10,%esp
80101d76:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d7c:	83 c0 5c             	add    $0x5c,%eax
80101d7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d82:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d85:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d8f:	01 d0                	add    %edx,%eax
80101d91:	8b 00                	mov    (%eax),%eax
80101d93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d9a:	75 36                	jne    80101dd2 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9f:	8b 00                	mov    (%eax),%eax
80101da1:	83 ec 0c             	sub    $0xc,%esp
80101da4:	50                   	push   %eax
80101da5:	e8 0e f7 ff ff       	call   801014b8 <balloc>
80101daa:	83 c4 10             	add    $0x10,%esp
80101dad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101db0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101db3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dbd:	01 c2                	add    %eax,%edx
80101dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc2:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101dc4:	83 ec 0c             	sub    $0xc,%esp
80101dc7:	ff 75 f0             	pushl  -0x10(%ebp)
80101dca:	e8 d1 1a 00 00       	call   801038a0 <log_write>
80101dcf:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101dd2:	83 ec 0c             	sub    $0xc,%esp
80101dd5:	ff 75 f0             	pushl  -0x10(%ebp)
80101dd8:	e8 b6 e4 ff ff       	call   80100293 <brelse>
80101ddd:	83 c4 10             	add    $0x10,%esp
    return addr;
80101de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101de3:	eb 0d                	jmp    80101df2 <bmap+0x122>
  }

  panic("bmap: out of range");
80101de5:	83 ec 0c             	sub    $0xc,%esp
80101de8:	68 ea ae 10 80       	push   $0x8010aeea
80101ded:	e8 d3 e7 ff ff       	call   801005c5 <panic>
}
80101df2:	c9                   	leave  
80101df3:	c3                   	ret    

80101df4 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101df4:	f3 0f 1e fb          	endbr32 
80101df8:	55                   	push   %ebp
80101df9:	89 e5                	mov    %esp,%ebp
80101dfb:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dfe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e05:	eb 45                	jmp    80101e4c <itrunc+0x58>
    if(ip->addrs[i]){
80101e07:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e0d:	83 c2 14             	add    $0x14,%edx
80101e10:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 30                	je     80101e48 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e18:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e1e:	83 c2 14             	add    $0x14,%edx
80101e21:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e25:	8b 55 08             	mov    0x8(%ebp),%edx
80101e28:	8b 12                	mov    (%edx),%edx
80101e2a:	83 ec 08             	sub    $0x8,%esp
80101e2d:	50                   	push   %eax
80101e2e:	52                   	push   %edx
80101e2f:	e8 d4 f7 ff ff       	call   80101608 <bfree>
80101e34:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e37:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e3d:	83 c2 14             	add    $0x14,%edx
80101e40:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e47:	00 
  for(i = 0; i < NDIRECT; i++){
80101e48:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e4c:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e50:	7e b5                	jle    80101e07 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e52:	8b 45 08             	mov    0x8(%ebp),%eax
80101e55:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e5b:	85 c0                	test   %eax,%eax
80101e5d:	0f 84 aa 00 00 00    	je     80101f0d <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e63:	8b 45 08             	mov    0x8(%ebp),%eax
80101e66:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6f:	8b 00                	mov    (%eax),%eax
80101e71:	83 ec 08             	sub    $0x8,%esp
80101e74:	52                   	push   %edx
80101e75:	50                   	push   %eax
80101e76:	e8 8e e3 ff ff       	call   80100209 <bread>
80101e7b:	83 c4 10             	add    $0x10,%esp
80101e7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e84:	83 c0 5c             	add    $0x5c,%eax
80101e87:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e91:	eb 3c                	jmp    80101ecf <itrunc+0xdb>
      if(a[j])
80101e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ea0:	01 d0                	add    %edx,%eax
80101ea2:	8b 00                	mov    (%eax),%eax
80101ea4:	85 c0                	test   %eax,%eax
80101ea6:	74 23                	je     80101ecb <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eb5:	01 d0                	add    %edx,%eax
80101eb7:	8b 00                	mov    (%eax),%eax
80101eb9:	8b 55 08             	mov    0x8(%ebp),%edx
80101ebc:	8b 12                	mov    (%edx),%edx
80101ebe:	83 ec 08             	sub    $0x8,%esp
80101ec1:	50                   	push   %eax
80101ec2:	52                   	push   %edx
80101ec3:	e8 40 f7 ff ff       	call   80101608 <bfree>
80101ec8:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101ecb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ed2:	83 f8 7f             	cmp    $0x7f,%eax
80101ed5:	76 bc                	jbe    80101e93 <itrunc+0x9f>
    }
    brelse(bp);
80101ed7:	83 ec 0c             	sub    $0xc,%esp
80101eda:	ff 75 ec             	pushl  -0x14(%ebp)
80101edd:	e8 b1 e3 ff ff       	call   80100293 <brelse>
80101ee2:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee8:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101eee:	8b 55 08             	mov    0x8(%ebp),%edx
80101ef1:	8b 12                	mov    (%edx),%edx
80101ef3:	83 ec 08             	sub    $0x8,%esp
80101ef6:	50                   	push   %eax
80101ef7:	52                   	push   %edx
80101ef8:	e8 0b f7 ff ff       	call   80101608 <bfree>
80101efd:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f00:	8b 45 08             	mov    0x8(%ebp),%eax
80101f03:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f0a:	00 00 00 
  }

  ip->size = 0;
80101f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f10:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f17:	83 ec 0c             	sub    $0xc,%esp
80101f1a:	ff 75 08             	pushl  0x8(%ebp)
80101f1d:	e8 5f f9 ff ff       	call   80101881 <iupdate>
80101f22:	83 c4 10             	add    $0x10,%esp
}
80101f25:	90                   	nop
80101f26:	c9                   	leave  
80101f27:	c3                   	ret    

80101f28 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f28:	f3 0f 1e fb          	endbr32 
80101f2c:	55                   	push   %ebp
80101f2d:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f32:	8b 00                	mov    (%eax),%eax
80101f34:	89 c2                	mov    %eax,%edx
80101f36:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f39:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3f:	8b 50 04             	mov    0x4(%eax),%edx
80101f42:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f45:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f48:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4b:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f52:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f55:	8b 45 08             	mov    0x8(%ebp),%eax
80101f58:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f5f:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f63:	8b 45 08             	mov    0x8(%ebp),%eax
80101f66:	8b 50 58             	mov    0x58(%eax),%edx
80101f69:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f6c:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f6f:	90                   	nop
80101f70:	5d                   	pop    %ebp
80101f71:	c3                   	ret    

80101f72 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f72:	f3 0f 1e fb          	endbr32 
80101f76:	55                   	push   %ebp
80101f77:	89 e5                	mov    %esp,%ebp
80101f79:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101f83:	66 83 f8 03          	cmp    $0x3,%ax
80101f87:	75 5c                	jne    80101fe5 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f89:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8c:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f90:	66 85 c0             	test   %ax,%ax
80101f93:	78 20                	js     80101fb5 <readi+0x43>
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f9c:	66 83 f8 09          	cmp    $0x9,%ax
80101fa0:	7f 13                	jg     80101fb5 <readi+0x43>
80101fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa5:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fa9:	98                   	cwtl   
80101faa:	8b 04 c5 40 67 11 80 	mov    -0x7fee98c0(,%eax,8),%eax
80101fb1:	85 c0                	test   %eax,%eax
80101fb3:	75 0a                	jne    80101fbf <readi+0x4d>
      return -1;
80101fb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fba:	e9 0a 01 00 00       	jmp    801020c9 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fc6:	98                   	cwtl   
80101fc7:	8b 04 c5 40 67 11 80 	mov    -0x7fee98c0(,%eax,8),%eax
80101fce:	8b 55 14             	mov    0x14(%ebp),%edx
80101fd1:	83 ec 04             	sub    $0x4,%esp
80101fd4:	52                   	push   %edx
80101fd5:	ff 75 0c             	pushl  0xc(%ebp)
80101fd8:	ff 75 08             	pushl  0x8(%ebp)
80101fdb:	ff d0                	call   *%eax
80101fdd:	83 c4 10             	add    $0x10,%esp
80101fe0:	e9 e4 00 00 00       	jmp    801020c9 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80101fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe8:	8b 40 58             	mov    0x58(%eax),%eax
80101feb:	39 45 10             	cmp    %eax,0x10(%ebp)
80101fee:	77 0d                	ja     80101ffd <readi+0x8b>
80101ff0:	8b 55 10             	mov    0x10(%ebp),%edx
80101ff3:	8b 45 14             	mov    0x14(%ebp),%eax
80101ff6:	01 d0                	add    %edx,%eax
80101ff8:	39 45 10             	cmp    %eax,0x10(%ebp)
80101ffb:	76 0a                	jbe    80102007 <readi+0x95>
    return -1;
80101ffd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102002:	e9 c2 00 00 00       	jmp    801020c9 <readi+0x157>
  if(off + n > ip->size)
80102007:	8b 55 10             	mov    0x10(%ebp),%edx
8010200a:	8b 45 14             	mov    0x14(%ebp),%eax
8010200d:	01 c2                	add    %eax,%edx
8010200f:	8b 45 08             	mov    0x8(%ebp),%eax
80102012:	8b 40 58             	mov    0x58(%eax),%eax
80102015:	39 c2                	cmp    %eax,%edx
80102017:	76 0c                	jbe    80102025 <readi+0xb3>
    n = ip->size - off;
80102019:	8b 45 08             	mov    0x8(%ebp),%eax
8010201c:	8b 40 58             	mov    0x58(%eax),%eax
8010201f:	2b 45 10             	sub    0x10(%ebp),%eax
80102022:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102025:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010202c:	e9 89 00 00 00       	jmp    801020ba <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102031:	8b 45 10             	mov    0x10(%ebp),%eax
80102034:	c1 e8 09             	shr    $0x9,%eax
80102037:	83 ec 08             	sub    $0x8,%esp
8010203a:	50                   	push   %eax
8010203b:	ff 75 08             	pushl  0x8(%ebp)
8010203e:	e8 8d fc ff ff       	call   80101cd0 <bmap>
80102043:	83 c4 10             	add    $0x10,%esp
80102046:	8b 55 08             	mov    0x8(%ebp),%edx
80102049:	8b 12                	mov    (%edx),%edx
8010204b:	83 ec 08             	sub    $0x8,%esp
8010204e:	50                   	push   %eax
8010204f:	52                   	push   %edx
80102050:	e8 b4 e1 ff ff       	call   80100209 <bread>
80102055:	83 c4 10             	add    $0x10,%esp
80102058:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010205b:	8b 45 10             	mov    0x10(%ebp),%eax
8010205e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102063:	ba 00 02 00 00       	mov    $0x200,%edx
80102068:	29 c2                	sub    %eax,%edx
8010206a:	8b 45 14             	mov    0x14(%ebp),%eax
8010206d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102070:	39 c2                	cmp    %eax,%edx
80102072:	0f 46 c2             	cmovbe %edx,%eax
80102075:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102078:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010207b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010207e:	8b 45 10             	mov    0x10(%ebp),%eax
80102081:	25 ff 01 00 00       	and    $0x1ff,%eax
80102086:	01 d0                	add    %edx,%eax
80102088:	83 ec 04             	sub    $0x4,%esp
8010208b:	ff 75 ec             	pushl  -0x14(%ebp)
8010208e:	50                   	push   %eax
8010208f:	ff 75 0c             	pushl  0xc(%ebp)
80102092:	e8 8f 34 00 00       	call   80105526 <memmove>
80102097:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010209a:	83 ec 0c             	sub    $0xc,%esp
8010209d:	ff 75 f0             	pushl  -0x10(%ebp)
801020a0:	e8 ee e1 ff ff       	call   80100293 <brelse>
801020a5:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020ab:	01 45 f4             	add    %eax,-0xc(%ebp)
801020ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020b1:	01 45 10             	add    %eax,0x10(%ebp)
801020b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020b7:	01 45 0c             	add    %eax,0xc(%ebp)
801020ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020bd:	3b 45 14             	cmp    0x14(%ebp),%eax
801020c0:	0f 82 6b ff ff ff    	jb     80102031 <readi+0xbf>
  }
  return n;
801020c6:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020c9:	c9                   	leave  
801020ca:	c3                   	ret    

801020cb <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020cb:	f3 0f 1e fb          	endbr32 
801020cf:	55                   	push   %ebp
801020d0:	89 e5                	mov    %esp,%ebp
801020d2:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020d5:	8b 45 08             	mov    0x8(%ebp),%eax
801020d8:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801020dc:	66 83 f8 03          	cmp    $0x3,%ax
801020e0:	75 5c                	jne    8010213e <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020e2:	8b 45 08             	mov    0x8(%ebp),%eax
801020e5:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020e9:	66 85 c0             	test   %ax,%ax
801020ec:	78 20                	js     8010210e <writei+0x43>
801020ee:	8b 45 08             	mov    0x8(%ebp),%eax
801020f1:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020f5:	66 83 f8 09          	cmp    $0x9,%ax
801020f9:	7f 13                	jg     8010210e <writei+0x43>
801020fb:	8b 45 08             	mov    0x8(%ebp),%eax
801020fe:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102102:	98                   	cwtl   
80102103:	8b 04 c5 44 67 11 80 	mov    -0x7fee98bc(,%eax,8),%eax
8010210a:	85 c0                	test   %eax,%eax
8010210c:	75 0a                	jne    80102118 <writei+0x4d>
      return -1;
8010210e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102113:	e9 3b 01 00 00       	jmp    80102253 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
80102118:	8b 45 08             	mov    0x8(%ebp),%eax
8010211b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010211f:	98                   	cwtl   
80102120:	8b 04 c5 44 67 11 80 	mov    -0x7fee98bc(,%eax,8),%eax
80102127:	8b 55 14             	mov    0x14(%ebp),%edx
8010212a:	83 ec 04             	sub    $0x4,%esp
8010212d:	52                   	push   %edx
8010212e:	ff 75 0c             	pushl  0xc(%ebp)
80102131:	ff 75 08             	pushl  0x8(%ebp)
80102134:	ff d0                	call   *%eax
80102136:	83 c4 10             	add    $0x10,%esp
80102139:	e9 15 01 00 00       	jmp    80102253 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
8010213e:	8b 45 08             	mov    0x8(%ebp),%eax
80102141:	8b 40 58             	mov    0x58(%eax),%eax
80102144:	39 45 10             	cmp    %eax,0x10(%ebp)
80102147:	77 0d                	ja     80102156 <writei+0x8b>
80102149:	8b 55 10             	mov    0x10(%ebp),%edx
8010214c:	8b 45 14             	mov    0x14(%ebp),%eax
8010214f:	01 d0                	add    %edx,%eax
80102151:	39 45 10             	cmp    %eax,0x10(%ebp)
80102154:	76 0a                	jbe    80102160 <writei+0x95>
    return -1;
80102156:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010215b:	e9 f3 00 00 00       	jmp    80102253 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102160:	8b 55 10             	mov    0x10(%ebp),%edx
80102163:	8b 45 14             	mov    0x14(%ebp),%eax
80102166:	01 d0                	add    %edx,%eax
80102168:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010216d:	76 0a                	jbe    80102179 <writei+0xae>
    return -1;
8010216f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102174:	e9 da 00 00 00       	jmp    80102253 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102179:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102180:	e9 97 00 00 00       	jmp    8010221c <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102185:	8b 45 10             	mov    0x10(%ebp),%eax
80102188:	c1 e8 09             	shr    $0x9,%eax
8010218b:	83 ec 08             	sub    $0x8,%esp
8010218e:	50                   	push   %eax
8010218f:	ff 75 08             	pushl  0x8(%ebp)
80102192:	e8 39 fb ff ff       	call   80101cd0 <bmap>
80102197:	83 c4 10             	add    $0x10,%esp
8010219a:	8b 55 08             	mov    0x8(%ebp),%edx
8010219d:	8b 12                	mov    (%edx),%edx
8010219f:	83 ec 08             	sub    $0x8,%esp
801021a2:	50                   	push   %eax
801021a3:	52                   	push   %edx
801021a4:	e8 60 e0 ff ff       	call   80100209 <bread>
801021a9:	83 c4 10             	add    $0x10,%esp
801021ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021af:	8b 45 10             	mov    0x10(%ebp),%eax
801021b2:	25 ff 01 00 00       	and    $0x1ff,%eax
801021b7:	ba 00 02 00 00       	mov    $0x200,%edx
801021bc:	29 c2                	sub    %eax,%edx
801021be:	8b 45 14             	mov    0x14(%ebp),%eax
801021c1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021c4:	39 c2                	cmp    %eax,%edx
801021c6:	0f 46 c2             	cmovbe %edx,%eax
801021c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021cf:	8d 50 5c             	lea    0x5c(%eax),%edx
801021d2:	8b 45 10             	mov    0x10(%ebp),%eax
801021d5:	25 ff 01 00 00       	and    $0x1ff,%eax
801021da:	01 d0                	add    %edx,%eax
801021dc:	83 ec 04             	sub    $0x4,%esp
801021df:	ff 75 ec             	pushl  -0x14(%ebp)
801021e2:	ff 75 0c             	pushl  0xc(%ebp)
801021e5:	50                   	push   %eax
801021e6:	e8 3b 33 00 00       	call   80105526 <memmove>
801021eb:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021ee:	83 ec 0c             	sub    $0xc,%esp
801021f1:	ff 75 f0             	pushl  -0x10(%ebp)
801021f4:	e8 a7 16 00 00       	call   801038a0 <log_write>
801021f9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021fc:	83 ec 0c             	sub    $0xc,%esp
801021ff:	ff 75 f0             	pushl  -0x10(%ebp)
80102202:	e8 8c e0 ff ff       	call   80100293 <brelse>
80102207:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010220a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010220d:	01 45 f4             	add    %eax,-0xc(%ebp)
80102210:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102213:	01 45 10             	add    %eax,0x10(%ebp)
80102216:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102219:	01 45 0c             	add    %eax,0xc(%ebp)
8010221c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010221f:	3b 45 14             	cmp    0x14(%ebp),%eax
80102222:	0f 82 5d ff ff ff    	jb     80102185 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
80102228:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010222c:	74 22                	je     80102250 <writei+0x185>
8010222e:	8b 45 08             	mov    0x8(%ebp),%eax
80102231:	8b 40 58             	mov    0x58(%eax),%eax
80102234:	39 45 10             	cmp    %eax,0x10(%ebp)
80102237:	76 17                	jbe    80102250 <writei+0x185>
    ip->size = off;
80102239:	8b 45 08             	mov    0x8(%ebp),%eax
8010223c:	8b 55 10             	mov    0x10(%ebp),%edx
8010223f:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102242:	83 ec 0c             	sub    $0xc,%esp
80102245:	ff 75 08             	pushl  0x8(%ebp)
80102248:	e8 34 f6 ff ff       	call   80101881 <iupdate>
8010224d:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102250:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102253:	c9                   	leave  
80102254:	c3                   	ret    

80102255 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102255:	f3 0f 1e fb          	endbr32 
80102259:	55                   	push   %ebp
8010225a:	89 e5                	mov    %esp,%ebp
8010225c:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010225f:	83 ec 04             	sub    $0x4,%esp
80102262:	6a 0e                	push   $0xe
80102264:	ff 75 0c             	pushl  0xc(%ebp)
80102267:	ff 75 08             	pushl  0x8(%ebp)
8010226a:	e8 55 33 00 00       	call   801055c4 <strncmp>
8010226f:	83 c4 10             	add    $0x10,%esp
}
80102272:	c9                   	leave  
80102273:	c3                   	ret    

80102274 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102274:	f3 0f 1e fb          	endbr32 
80102278:	55                   	push   %ebp
80102279:	89 e5                	mov    %esp,%ebp
8010227b:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010227e:	8b 45 08             	mov    0x8(%ebp),%eax
80102281:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102285:	66 83 f8 01          	cmp    $0x1,%ax
80102289:	74 0d                	je     80102298 <dirlookup+0x24>
    panic("dirlookup not DIR");
8010228b:	83 ec 0c             	sub    $0xc,%esp
8010228e:	68 fd ae 10 80       	push   $0x8010aefd
80102293:	e8 2d e3 ff ff       	call   801005c5 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102298:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010229f:	eb 7b                	jmp    8010231c <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022a1:	6a 10                	push   $0x10
801022a3:	ff 75 f4             	pushl  -0xc(%ebp)
801022a6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022a9:	50                   	push   %eax
801022aa:	ff 75 08             	pushl  0x8(%ebp)
801022ad:	e8 c0 fc ff ff       	call   80101f72 <readi>
801022b2:	83 c4 10             	add    $0x10,%esp
801022b5:	83 f8 10             	cmp    $0x10,%eax
801022b8:	74 0d                	je     801022c7 <dirlookup+0x53>
      panic("dirlookup read");
801022ba:	83 ec 0c             	sub    $0xc,%esp
801022bd:	68 0f af 10 80       	push   $0x8010af0f
801022c2:	e8 fe e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801022c7:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022cb:	66 85 c0             	test   %ax,%ax
801022ce:	74 47                	je     80102317 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801022d0:	83 ec 08             	sub    $0x8,%esp
801022d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d6:	83 c0 02             	add    $0x2,%eax
801022d9:	50                   	push   %eax
801022da:	ff 75 0c             	pushl  0xc(%ebp)
801022dd:	e8 73 ff ff ff       	call   80102255 <namecmp>
801022e2:	83 c4 10             	add    $0x10,%esp
801022e5:	85 c0                	test   %eax,%eax
801022e7:	75 2f                	jne    80102318 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801022e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022ed:	74 08                	je     801022f7 <dirlookup+0x83>
        *poff = off;
801022ef:	8b 45 10             	mov    0x10(%ebp),%eax
801022f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022f5:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022f7:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fb:	0f b7 c0             	movzwl %ax,%eax
801022fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102301:	8b 45 08             	mov    0x8(%ebp),%eax
80102304:	8b 00                	mov    (%eax),%eax
80102306:	83 ec 08             	sub    $0x8,%esp
80102309:	ff 75 f0             	pushl  -0x10(%ebp)
8010230c:	50                   	push   %eax
8010230d:	e8 34 f6 ff ff       	call   80101946 <iget>
80102312:	83 c4 10             	add    $0x10,%esp
80102315:	eb 19                	jmp    80102330 <dirlookup+0xbc>
      continue;
80102317:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102318:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010231c:	8b 45 08             	mov    0x8(%ebp),%eax
8010231f:	8b 40 58             	mov    0x58(%eax),%eax
80102322:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102325:	0f 82 76 ff ff ff    	jb     801022a1 <dirlookup+0x2d>
    }
  }

  return 0;
8010232b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102330:	c9                   	leave  
80102331:	c3                   	ret    

80102332 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102332:	f3 0f 1e fb          	endbr32 
80102336:	55                   	push   %ebp
80102337:	89 e5                	mov    %esp,%ebp
80102339:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010233c:	83 ec 04             	sub    $0x4,%esp
8010233f:	6a 00                	push   $0x0
80102341:	ff 75 0c             	pushl  0xc(%ebp)
80102344:	ff 75 08             	pushl  0x8(%ebp)
80102347:	e8 28 ff ff ff       	call   80102274 <dirlookup>
8010234c:	83 c4 10             	add    $0x10,%esp
8010234f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102352:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102356:	74 18                	je     80102370 <dirlink+0x3e>
    iput(ip);
80102358:	83 ec 0c             	sub    $0xc,%esp
8010235b:	ff 75 f0             	pushl  -0x10(%ebp)
8010235e:	e8 70 f8 ff ff       	call   80101bd3 <iput>
80102363:	83 c4 10             	add    $0x10,%esp
    return -1;
80102366:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010236b:	e9 9c 00 00 00       	jmp    8010240c <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102370:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102377:	eb 39                	jmp    801023b2 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237c:	6a 10                	push   $0x10
8010237e:	50                   	push   %eax
8010237f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102382:	50                   	push   %eax
80102383:	ff 75 08             	pushl  0x8(%ebp)
80102386:	e8 e7 fb ff ff       	call   80101f72 <readi>
8010238b:	83 c4 10             	add    $0x10,%esp
8010238e:	83 f8 10             	cmp    $0x10,%eax
80102391:	74 0d                	je     801023a0 <dirlink+0x6e>
      panic("dirlink read");
80102393:	83 ec 0c             	sub    $0xc,%esp
80102396:	68 1e af 10 80       	push   $0x8010af1e
8010239b:	e8 25 e2 ff ff       	call   801005c5 <panic>
    if(de.inum == 0)
801023a0:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023a4:	66 85 c0             	test   %ax,%ax
801023a7:	74 18                	je     801023c1 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ac:	83 c0 10             	add    $0x10,%eax
801023af:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023b2:	8b 45 08             	mov    0x8(%ebp),%eax
801023b5:	8b 50 58             	mov    0x58(%eax),%edx
801023b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bb:	39 c2                	cmp    %eax,%edx
801023bd:	77 ba                	ja     80102379 <dirlink+0x47>
801023bf:	eb 01                	jmp    801023c2 <dirlink+0x90>
      break;
801023c1:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023c2:	83 ec 04             	sub    $0x4,%esp
801023c5:	6a 0e                	push   $0xe
801023c7:	ff 75 0c             	pushl  0xc(%ebp)
801023ca:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023cd:	83 c0 02             	add    $0x2,%eax
801023d0:	50                   	push   %eax
801023d1:	e8 48 32 00 00       	call   8010561e <strncpy>
801023d6:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023d9:	8b 45 10             	mov    0x10(%ebp),%eax
801023dc:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e3:	6a 10                	push   $0x10
801023e5:	50                   	push   %eax
801023e6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023e9:	50                   	push   %eax
801023ea:	ff 75 08             	pushl  0x8(%ebp)
801023ed:	e8 d9 fc ff ff       	call   801020cb <writei>
801023f2:	83 c4 10             	add    $0x10,%esp
801023f5:	83 f8 10             	cmp    $0x10,%eax
801023f8:	74 0d                	je     80102407 <dirlink+0xd5>
    panic("dirlink");
801023fa:	83 ec 0c             	sub    $0xc,%esp
801023fd:	68 2b af 10 80       	push   $0x8010af2b
80102402:	e8 be e1 ff ff       	call   801005c5 <panic>

  return 0;
80102407:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010240c:	c9                   	leave  
8010240d:	c3                   	ret    

8010240e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010240e:	f3 0f 1e fb          	endbr32 
80102412:	55                   	push   %ebp
80102413:	89 e5                	mov    %esp,%ebp
80102415:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102418:	eb 04                	jmp    8010241e <skipelem+0x10>
    path++;
8010241a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010241e:	8b 45 08             	mov    0x8(%ebp),%eax
80102421:	0f b6 00             	movzbl (%eax),%eax
80102424:	3c 2f                	cmp    $0x2f,%al
80102426:	74 f2                	je     8010241a <skipelem+0xc>
  if(*path == 0)
80102428:	8b 45 08             	mov    0x8(%ebp),%eax
8010242b:	0f b6 00             	movzbl (%eax),%eax
8010242e:	84 c0                	test   %al,%al
80102430:	75 07                	jne    80102439 <skipelem+0x2b>
    return 0;
80102432:	b8 00 00 00 00       	mov    $0x0,%eax
80102437:	eb 77                	jmp    801024b0 <skipelem+0xa2>
  s = path;
80102439:	8b 45 08             	mov    0x8(%ebp),%eax
8010243c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010243f:	eb 04                	jmp    80102445 <skipelem+0x37>
    path++;
80102441:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102445:	8b 45 08             	mov    0x8(%ebp),%eax
80102448:	0f b6 00             	movzbl (%eax),%eax
8010244b:	3c 2f                	cmp    $0x2f,%al
8010244d:	74 0a                	je     80102459 <skipelem+0x4b>
8010244f:	8b 45 08             	mov    0x8(%ebp),%eax
80102452:	0f b6 00             	movzbl (%eax),%eax
80102455:	84 c0                	test   %al,%al
80102457:	75 e8                	jne    80102441 <skipelem+0x33>
  len = path - s;
80102459:	8b 45 08             	mov    0x8(%ebp),%eax
8010245c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010245f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102462:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102466:	7e 15                	jle    8010247d <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102468:	83 ec 04             	sub    $0x4,%esp
8010246b:	6a 0e                	push   $0xe
8010246d:	ff 75 f4             	pushl  -0xc(%ebp)
80102470:	ff 75 0c             	pushl  0xc(%ebp)
80102473:	e8 ae 30 00 00       	call   80105526 <memmove>
80102478:	83 c4 10             	add    $0x10,%esp
8010247b:	eb 26                	jmp    801024a3 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010247d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102480:	83 ec 04             	sub    $0x4,%esp
80102483:	50                   	push   %eax
80102484:	ff 75 f4             	pushl  -0xc(%ebp)
80102487:	ff 75 0c             	pushl  0xc(%ebp)
8010248a:	e8 97 30 00 00       	call   80105526 <memmove>
8010248f:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102492:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102495:	8b 45 0c             	mov    0xc(%ebp),%eax
80102498:	01 d0                	add    %edx,%eax
8010249a:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010249d:	eb 04                	jmp    801024a3 <skipelem+0x95>
    path++;
8010249f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024a3:	8b 45 08             	mov    0x8(%ebp),%eax
801024a6:	0f b6 00             	movzbl (%eax),%eax
801024a9:	3c 2f                	cmp    $0x2f,%al
801024ab:	74 f2                	je     8010249f <skipelem+0x91>
  return path;
801024ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024b0:	c9                   	leave  
801024b1:	c3                   	ret    

801024b2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024b2:	f3 0f 1e fb          	endbr32 
801024b6:	55                   	push   %ebp
801024b7:	89 e5                	mov    %esp,%ebp
801024b9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024bc:	8b 45 08             	mov    0x8(%ebp),%eax
801024bf:	0f b6 00             	movzbl (%eax),%eax
801024c2:	3c 2f                	cmp    $0x2f,%al
801024c4:	75 17                	jne    801024dd <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024c6:	83 ec 08             	sub    $0x8,%esp
801024c9:	6a 01                	push   $0x1
801024cb:	6a 01                	push   $0x1
801024cd:	e8 74 f4 ff ff       	call   80101946 <iget>
801024d2:	83 c4 10             	add    $0x10,%esp
801024d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024d8:	e9 ba 00 00 00       	jmp    80102597 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801024dd:	e8 ad 1b 00 00       	call   8010408f <myproc>
801024e2:	8b 40 68             	mov    0x68(%eax),%eax
801024e5:	83 ec 0c             	sub    $0xc,%esp
801024e8:	50                   	push   %eax
801024e9:	e8 3e f5 ff ff       	call   80101a2c <idup>
801024ee:	83 c4 10             	add    $0x10,%esp
801024f1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024f4:	e9 9e 00 00 00       	jmp    80102597 <namex+0xe5>
    ilock(ip);
801024f9:	83 ec 0c             	sub    $0xc,%esp
801024fc:	ff 75 f4             	pushl  -0xc(%ebp)
801024ff:	e8 66 f5 ff ff       	call   80101a6a <ilock>
80102504:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010250a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010250e:	66 83 f8 01          	cmp    $0x1,%ax
80102512:	74 18                	je     8010252c <namex+0x7a>
      iunlockput(ip);
80102514:	83 ec 0c             	sub    $0xc,%esp
80102517:	ff 75 f4             	pushl  -0xc(%ebp)
8010251a:	e8 88 f7 ff ff       	call   80101ca7 <iunlockput>
8010251f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102522:	b8 00 00 00 00       	mov    $0x0,%eax
80102527:	e9 a7 00 00 00       	jmp    801025d3 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010252c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102530:	74 20                	je     80102552 <namex+0xa0>
80102532:	8b 45 08             	mov    0x8(%ebp),%eax
80102535:	0f b6 00             	movzbl (%eax),%eax
80102538:	84 c0                	test   %al,%al
8010253a:	75 16                	jne    80102552 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010253c:	83 ec 0c             	sub    $0xc,%esp
8010253f:	ff 75 f4             	pushl  -0xc(%ebp)
80102542:	e8 3a f6 ff ff       	call   80101b81 <iunlock>
80102547:	83 c4 10             	add    $0x10,%esp
      return ip;
8010254a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010254d:	e9 81 00 00 00       	jmp    801025d3 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102552:	83 ec 04             	sub    $0x4,%esp
80102555:	6a 00                	push   $0x0
80102557:	ff 75 10             	pushl  0x10(%ebp)
8010255a:	ff 75 f4             	pushl  -0xc(%ebp)
8010255d:	e8 12 fd ff ff       	call   80102274 <dirlookup>
80102562:	83 c4 10             	add    $0x10,%esp
80102565:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102568:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010256c:	75 15                	jne    80102583 <namex+0xd1>
      iunlockput(ip);
8010256e:	83 ec 0c             	sub    $0xc,%esp
80102571:	ff 75 f4             	pushl  -0xc(%ebp)
80102574:	e8 2e f7 ff ff       	call   80101ca7 <iunlockput>
80102579:	83 c4 10             	add    $0x10,%esp
      return 0;
8010257c:	b8 00 00 00 00       	mov    $0x0,%eax
80102581:	eb 50                	jmp    801025d3 <namex+0x121>
    }
    iunlockput(ip);
80102583:	83 ec 0c             	sub    $0xc,%esp
80102586:	ff 75 f4             	pushl  -0xc(%ebp)
80102589:	e8 19 f7 ff ff       	call   80101ca7 <iunlockput>
8010258e:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102591:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102594:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
80102597:	83 ec 08             	sub    $0x8,%esp
8010259a:	ff 75 10             	pushl  0x10(%ebp)
8010259d:	ff 75 08             	pushl  0x8(%ebp)
801025a0:	e8 69 fe ff ff       	call   8010240e <skipelem>
801025a5:	83 c4 10             	add    $0x10,%esp
801025a8:	89 45 08             	mov    %eax,0x8(%ebp)
801025ab:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025af:	0f 85 44 ff ff ff    	jne    801024f9 <namex+0x47>
  }
  if(nameiparent){
801025b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025b9:	74 15                	je     801025d0 <namex+0x11e>
    iput(ip);
801025bb:	83 ec 0c             	sub    $0xc,%esp
801025be:	ff 75 f4             	pushl  -0xc(%ebp)
801025c1:	e8 0d f6 ff ff       	call   80101bd3 <iput>
801025c6:	83 c4 10             	add    $0x10,%esp
    return 0;
801025c9:	b8 00 00 00 00       	mov    $0x0,%eax
801025ce:	eb 03                	jmp    801025d3 <namex+0x121>
  }
  return ip;
801025d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025d3:	c9                   	leave  
801025d4:	c3                   	ret    

801025d5 <namei>:

struct inode*
namei(char *path)
{
801025d5:	f3 0f 1e fb          	endbr32 
801025d9:	55                   	push   %ebp
801025da:	89 e5                	mov    %esp,%ebp
801025dc:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025df:	83 ec 04             	sub    $0x4,%esp
801025e2:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025e5:	50                   	push   %eax
801025e6:	6a 00                	push   $0x0
801025e8:	ff 75 08             	pushl  0x8(%ebp)
801025eb:	e8 c2 fe ff ff       	call   801024b2 <namex>
801025f0:	83 c4 10             	add    $0x10,%esp
}
801025f3:	c9                   	leave  
801025f4:	c3                   	ret    

801025f5 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025f5:	f3 0f 1e fb          	endbr32 
801025f9:	55                   	push   %ebp
801025fa:	89 e5                	mov    %esp,%ebp
801025fc:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025ff:	83 ec 04             	sub    $0x4,%esp
80102602:	ff 75 0c             	pushl  0xc(%ebp)
80102605:	6a 01                	push   $0x1
80102607:	ff 75 08             	pushl  0x8(%ebp)
8010260a:	e8 a3 fe ff ff       	call   801024b2 <namex>
8010260f:	83 c4 10             	add    $0x10,%esp
}
80102612:	c9                   	leave  
80102613:	c3                   	ret    

80102614 <inb>:
{
80102614:	55                   	push   %ebp
80102615:	89 e5                	mov    %esp,%ebp
80102617:	83 ec 14             	sub    $0x14,%esp
8010261a:	8b 45 08             	mov    0x8(%ebp),%eax
8010261d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102621:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102625:	89 c2                	mov    %eax,%edx
80102627:	ec                   	in     (%dx),%al
80102628:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010262b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010262f:	c9                   	leave  
80102630:	c3                   	ret    

80102631 <insl>:
{
80102631:	55                   	push   %ebp
80102632:	89 e5                	mov    %esp,%ebp
80102634:	57                   	push   %edi
80102635:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102636:	8b 55 08             	mov    0x8(%ebp),%edx
80102639:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010263c:	8b 45 10             	mov    0x10(%ebp),%eax
8010263f:	89 cb                	mov    %ecx,%ebx
80102641:	89 df                	mov    %ebx,%edi
80102643:	89 c1                	mov    %eax,%ecx
80102645:	fc                   	cld    
80102646:	f3 6d                	rep insl (%dx),%es:(%edi)
80102648:	89 c8                	mov    %ecx,%eax
8010264a:	89 fb                	mov    %edi,%ebx
8010264c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010264f:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102652:	90                   	nop
80102653:	5b                   	pop    %ebx
80102654:	5f                   	pop    %edi
80102655:	5d                   	pop    %ebp
80102656:	c3                   	ret    

80102657 <outb>:
{
80102657:	55                   	push   %ebp
80102658:	89 e5                	mov    %esp,%ebp
8010265a:	83 ec 08             	sub    $0x8,%esp
8010265d:	8b 45 08             	mov    0x8(%ebp),%eax
80102660:	8b 55 0c             	mov    0xc(%ebp),%edx
80102663:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102667:	89 d0                	mov    %edx,%eax
80102669:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010266c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102670:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102674:	ee                   	out    %al,(%dx)
}
80102675:	90                   	nop
80102676:	c9                   	leave  
80102677:	c3                   	ret    

80102678 <outsl>:
{
80102678:	55                   	push   %ebp
80102679:	89 e5                	mov    %esp,%ebp
8010267b:	56                   	push   %esi
8010267c:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010267d:	8b 55 08             	mov    0x8(%ebp),%edx
80102680:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102683:	8b 45 10             	mov    0x10(%ebp),%eax
80102686:	89 cb                	mov    %ecx,%ebx
80102688:	89 de                	mov    %ebx,%esi
8010268a:	89 c1                	mov    %eax,%ecx
8010268c:	fc                   	cld    
8010268d:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010268f:	89 c8                	mov    %ecx,%eax
80102691:	89 f3                	mov    %esi,%ebx
80102693:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102696:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102699:	90                   	nop
8010269a:	5b                   	pop    %ebx
8010269b:	5e                   	pop    %esi
8010269c:	5d                   	pop    %ebp
8010269d:	c3                   	ret    

8010269e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010269e:	f3 0f 1e fb          	endbr32 
801026a2:	55                   	push   %ebp
801026a3:	89 e5                	mov    %esp,%ebp
801026a5:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801026a8:	90                   	nop
801026a9:	68 f7 01 00 00       	push   $0x1f7
801026ae:	e8 61 ff ff ff       	call   80102614 <inb>
801026b3:	83 c4 04             	add    $0x4,%esp
801026b6:	0f b6 c0             	movzbl %al,%eax
801026b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026bf:	25 c0 00 00 00       	and    $0xc0,%eax
801026c4:	83 f8 40             	cmp    $0x40,%eax
801026c7:	75 e0                	jne    801026a9 <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026cd:	74 11                	je     801026e0 <idewait+0x42>
801026cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026d2:	83 e0 21             	and    $0x21,%eax
801026d5:	85 c0                	test   %eax,%eax
801026d7:	74 07                	je     801026e0 <idewait+0x42>
    return -1;
801026d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026de:	eb 05                	jmp    801026e5 <idewait+0x47>
  return 0;
801026e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026e5:	c9                   	leave  
801026e6:	c3                   	ret    

801026e7 <ideinit>:

void
ideinit(void)
{
801026e7:	f3 0f 1e fb          	endbr32 
801026eb:	55                   	push   %ebp
801026ec:	89 e5                	mov    %esp,%ebp
801026ee:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801026f1:	83 ec 08             	sub    $0x8,%esp
801026f4:	68 33 af 10 80       	push   $0x8010af33
801026f9:	68 60 00 11 80       	push   $0x80110060
801026fe:	e8 a7 2a 00 00       	call   801051aa <initlock>
80102703:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102706:	a1 c0 b4 11 80       	mov    0x8011b4c0,%eax
8010270b:	83 e8 01             	sub    $0x1,%eax
8010270e:	83 ec 08             	sub    $0x8,%esp
80102711:	50                   	push   %eax
80102712:	6a 0e                	push   $0xe
80102714:	e8 d9 04 00 00       	call   80102bf2 <ioapicenable>
80102719:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010271c:	83 ec 0c             	sub    $0xc,%esp
8010271f:	6a 00                	push   $0x0
80102721:	e8 78 ff ff ff       	call   8010269e <idewait>
80102726:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102729:	83 ec 08             	sub    $0x8,%esp
8010272c:	68 f0 00 00 00       	push   $0xf0
80102731:	68 f6 01 00 00       	push   $0x1f6
80102736:	e8 1c ff ff ff       	call   80102657 <outb>
8010273b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010273e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102745:	eb 24                	jmp    8010276b <ideinit+0x84>
    if(inb(0x1f7) != 0){
80102747:	83 ec 0c             	sub    $0xc,%esp
8010274a:	68 f7 01 00 00       	push   $0x1f7
8010274f:	e8 c0 fe ff ff       	call   80102614 <inb>
80102754:	83 c4 10             	add    $0x10,%esp
80102757:	84 c0                	test   %al,%al
80102759:	74 0c                	je     80102767 <ideinit+0x80>
      havedisk1 = 1;
8010275b:	c7 05 98 00 11 80 01 	movl   $0x1,0x80110098
80102762:	00 00 00 
      break;
80102765:	eb 0d                	jmp    80102774 <ideinit+0x8d>
  for(i=0; i<1000; i++){
80102767:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010276b:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102772:	7e d3                	jle    80102747 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102774:	83 ec 08             	sub    $0x8,%esp
80102777:	68 e0 00 00 00       	push   $0xe0
8010277c:	68 f6 01 00 00       	push   $0x1f6
80102781:	e8 d1 fe ff ff       	call   80102657 <outb>
80102786:	83 c4 10             	add    $0x10,%esp
}
80102789:	90                   	nop
8010278a:	c9                   	leave  
8010278b:	c3                   	ret    

8010278c <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010278c:	f3 0f 1e fb          	endbr32 
80102790:	55                   	push   %ebp
80102791:	89 e5                	mov    %esp,%ebp
80102793:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102796:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010279a:	75 0d                	jne    801027a9 <idestart+0x1d>
    panic("idestart");
8010279c:	83 ec 0c             	sub    $0xc,%esp
8010279f:	68 37 af 10 80       	push   $0x8010af37
801027a4:	e8 1c de ff ff       	call   801005c5 <panic>
  if(b->blockno >= FSSIZE)
801027a9:	8b 45 08             	mov    0x8(%ebp),%eax
801027ac:	8b 40 08             	mov    0x8(%eax),%eax
801027af:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801027b4:	76 0d                	jbe    801027c3 <idestart+0x37>
    panic("incorrect blockno");
801027b6:	83 ec 0c             	sub    $0xc,%esp
801027b9:	68 40 af 10 80       	push   $0x8010af40
801027be:	e8 02 de ff ff       	call   801005c5 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027c3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027ca:	8b 45 08             	mov    0x8(%ebp),%eax
801027cd:	8b 50 08             	mov    0x8(%eax),%edx
801027d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d3:	0f af c2             	imul   %edx,%eax
801027d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027d9:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027dd:	75 07                	jne    801027e6 <idestart+0x5a>
801027df:	b8 20 00 00 00       	mov    $0x20,%eax
801027e4:	eb 05                	jmp    801027eb <idestart+0x5f>
801027e6:	b8 c4 00 00 00       	mov    $0xc4,%eax
801027eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801027ee:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027f2:	75 07                	jne    801027fb <idestart+0x6f>
801027f4:	b8 30 00 00 00       	mov    $0x30,%eax
801027f9:	eb 05                	jmp    80102800 <idestart+0x74>
801027fb:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102800:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102803:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102807:	7e 0d                	jle    80102816 <idestart+0x8a>
80102809:	83 ec 0c             	sub    $0xc,%esp
8010280c:	68 37 af 10 80       	push   $0x8010af37
80102811:	e8 af dd ff ff       	call   801005c5 <panic>

  idewait(0);
80102816:	83 ec 0c             	sub    $0xc,%esp
80102819:	6a 00                	push   $0x0
8010281b:	e8 7e fe ff ff       	call   8010269e <idewait>
80102820:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102823:	83 ec 08             	sub    $0x8,%esp
80102826:	6a 00                	push   $0x0
80102828:	68 f6 03 00 00       	push   $0x3f6
8010282d:	e8 25 fe ff ff       	call   80102657 <outb>
80102832:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102838:	0f b6 c0             	movzbl %al,%eax
8010283b:	83 ec 08             	sub    $0x8,%esp
8010283e:	50                   	push   %eax
8010283f:	68 f2 01 00 00       	push   $0x1f2
80102844:	e8 0e fe ff ff       	call   80102657 <outb>
80102849:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010284c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010284f:	0f b6 c0             	movzbl %al,%eax
80102852:	83 ec 08             	sub    $0x8,%esp
80102855:	50                   	push   %eax
80102856:	68 f3 01 00 00       	push   $0x1f3
8010285b:	e8 f7 fd ff ff       	call   80102657 <outb>
80102860:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102863:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102866:	c1 f8 08             	sar    $0x8,%eax
80102869:	0f b6 c0             	movzbl %al,%eax
8010286c:	83 ec 08             	sub    $0x8,%esp
8010286f:	50                   	push   %eax
80102870:	68 f4 01 00 00       	push   $0x1f4
80102875:	e8 dd fd ff ff       	call   80102657 <outb>
8010287a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010287d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102880:	c1 f8 10             	sar    $0x10,%eax
80102883:	0f b6 c0             	movzbl %al,%eax
80102886:	83 ec 08             	sub    $0x8,%esp
80102889:	50                   	push   %eax
8010288a:	68 f5 01 00 00       	push   $0x1f5
8010288f:	e8 c3 fd ff ff       	call   80102657 <outb>
80102894:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102897:	8b 45 08             	mov    0x8(%ebp),%eax
8010289a:	8b 40 04             	mov    0x4(%eax),%eax
8010289d:	c1 e0 04             	shl    $0x4,%eax
801028a0:	83 e0 10             	and    $0x10,%eax
801028a3:	89 c2                	mov    %eax,%edx
801028a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028a8:	c1 f8 18             	sar    $0x18,%eax
801028ab:	83 e0 0f             	and    $0xf,%eax
801028ae:	09 d0                	or     %edx,%eax
801028b0:	83 c8 e0             	or     $0xffffffe0,%eax
801028b3:	0f b6 c0             	movzbl %al,%eax
801028b6:	83 ec 08             	sub    $0x8,%esp
801028b9:	50                   	push   %eax
801028ba:	68 f6 01 00 00       	push   $0x1f6
801028bf:	e8 93 fd ff ff       	call   80102657 <outb>
801028c4:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801028c7:	8b 45 08             	mov    0x8(%ebp),%eax
801028ca:	8b 00                	mov    (%eax),%eax
801028cc:	83 e0 04             	and    $0x4,%eax
801028cf:	85 c0                	test   %eax,%eax
801028d1:	74 35                	je     80102908 <idestart+0x17c>
    outb(0x1f7, write_cmd);
801028d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028d6:	0f b6 c0             	movzbl %al,%eax
801028d9:	83 ec 08             	sub    $0x8,%esp
801028dc:	50                   	push   %eax
801028dd:	68 f7 01 00 00       	push   $0x1f7
801028e2:	e8 70 fd ff ff       	call   80102657 <outb>
801028e7:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028ea:	8b 45 08             	mov    0x8(%ebp),%eax
801028ed:	83 c0 5c             	add    $0x5c,%eax
801028f0:	83 ec 04             	sub    $0x4,%esp
801028f3:	68 80 00 00 00       	push   $0x80
801028f8:	50                   	push   %eax
801028f9:	68 f0 01 00 00       	push   $0x1f0
801028fe:	e8 75 fd ff ff       	call   80102678 <outsl>
80102903:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102906:	eb 17                	jmp    8010291f <idestart+0x193>
    outb(0x1f7, read_cmd);
80102908:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010290b:	0f b6 c0             	movzbl %al,%eax
8010290e:	83 ec 08             	sub    $0x8,%esp
80102911:	50                   	push   %eax
80102912:	68 f7 01 00 00       	push   $0x1f7
80102917:	e8 3b fd ff ff       	call   80102657 <outb>
8010291c:	83 c4 10             	add    $0x10,%esp
}
8010291f:	90                   	nop
80102920:	c9                   	leave  
80102921:	c3                   	ret    

80102922 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102922:	f3 0f 1e fb          	endbr32 
80102926:	55                   	push   %ebp
80102927:	89 e5                	mov    %esp,%ebp
80102929:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010292c:	83 ec 0c             	sub    $0xc,%esp
8010292f:	68 60 00 11 80       	push   $0x80110060
80102934:	e8 97 28 00 00       	call   801051d0 <acquire>
80102939:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010293c:	a1 94 00 11 80       	mov    0x80110094,%eax
80102941:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102944:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102948:	75 15                	jne    8010295f <ideintr+0x3d>
    release(&idelock);
8010294a:	83 ec 0c             	sub    $0xc,%esp
8010294d:	68 60 00 11 80       	push   $0x80110060
80102952:	e8 eb 28 00 00       	call   80105242 <release>
80102957:	83 c4 10             	add    $0x10,%esp
    return;
8010295a:	e9 9a 00 00 00       	jmp    801029f9 <ideintr+0xd7>
  }
  idequeue = b->qnext;
8010295f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102962:	8b 40 58             	mov    0x58(%eax),%eax
80102965:	a3 94 00 11 80       	mov    %eax,0x80110094

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010296a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010296d:	8b 00                	mov    (%eax),%eax
8010296f:	83 e0 04             	and    $0x4,%eax
80102972:	85 c0                	test   %eax,%eax
80102974:	75 2d                	jne    801029a3 <ideintr+0x81>
80102976:	83 ec 0c             	sub    $0xc,%esp
80102979:	6a 01                	push   $0x1
8010297b:	e8 1e fd ff ff       	call   8010269e <idewait>
80102980:	83 c4 10             	add    $0x10,%esp
80102983:	85 c0                	test   %eax,%eax
80102985:	78 1c                	js     801029a3 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298a:	83 c0 5c             	add    $0x5c,%eax
8010298d:	83 ec 04             	sub    $0x4,%esp
80102990:	68 80 00 00 00       	push   $0x80
80102995:	50                   	push   %eax
80102996:	68 f0 01 00 00       	push   $0x1f0
8010299b:	e8 91 fc ff ff       	call   80102631 <insl>
801029a0:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801029a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a6:	8b 00                	mov    (%eax),%eax
801029a8:	83 c8 02             	or     $0x2,%eax
801029ab:	89 c2                	mov    %eax,%edx
801029ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b0:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b5:	8b 00                	mov    (%eax),%eax
801029b7:	83 e0 fb             	and    $0xfffffffb,%eax
801029ba:	89 c2                	mov    %eax,%edx
801029bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029bf:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029c1:	83 ec 0c             	sub    $0xc,%esp
801029c4:	ff 75 f4             	pushl  -0xc(%ebp)
801029c7:	e8 4c 23 00 00       	call   80104d18 <wakeup>
801029cc:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801029cf:	a1 94 00 11 80       	mov    0x80110094,%eax
801029d4:	85 c0                	test   %eax,%eax
801029d6:	74 11                	je     801029e9 <ideintr+0xc7>
    idestart(idequeue);
801029d8:	a1 94 00 11 80       	mov    0x80110094,%eax
801029dd:	83 ec 0c             	sub    $0xc,%esp
801029e0:	50                   	push   %eax
801029e1:	e8 a6 fd ff ff       	call   8010278c <idestart>
801029e6:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801029e9:	83 ec 0c             	sub    $0xc,%esp
801029ec:	68 60 00 11 80       	push   $0x80110060
801029f1:	e8 4c 28 00 00       	call   80105242 <release>
801029f6:	83 c4 10             	add    $0x10,%esp
}
801029f9:	c9                   	leave  
801029fa:	c3                   	ret    

801029fb <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029fb:	f3 0f 1e fb          	endbr32 
801029ff:	55                   	push   %ebp
80102a00:	89 e5                	mov    %esp,%ebp
80102a02:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102a05:	8b 15 98 00 11 80    	mov    0x80110098,%edx
80102a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0e:	8b 40 04             	mov    0x4(%eax),%eax
80102a11:	83 ec 04             	sub    $0x4,%esp
80102a14:	52                   	push   %edx
80102a15:	50                   	push   %eax
80102a16:	68 52 af 10 80       	push   $0x8010af52
80102a1b:	e8 ec d9 ff ff       	call   8010040c <cprintf>
80102a20:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
80102a23:	8b 45 08             	mov    0x8(%ebp),%eax
80102a26:	83 c0 0c             	add    $0xc,%eax
80102a29:	83 ec 0c             	sub    $0xc,%esp
80102a2c:	50                   	push   %eax
80102a2d:	e8 05 27 00 00       	call   80105137 <holdingsleep>
80102a32:	83 c4 10             	add    $0x10,%esp
80102a35:	85 c0                	test   %eax,%eax
80102a37:	75 0d                	jne    80102a46 <iderw+0x4b>
    panic("iderw: buf not locked");
80102a39:	83 ec 0c             	sub    $0xc,%esp
80102a3c:	68 6c af 10 80       	push   $0x8010af6c
80102a41:	e8 7f db ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a46:	8b 45 08             	mov    0x8(%ebp),%eax
80102a49:	8b 00                	mov    (%eax),%eax
80102a4b:	83 e0 06             	and    $0x6,%eax
80102a4e:	83 f8 02             	cmp    $0x2,%eax
80102a51:	75 0d                	jne    80102a60 <iderw+0x65>
    panic("iderw: nothing to do");
80102a53:	83 ec 0c             	sub    $0xc,%esp
80102a56:	68 82 af 10 80       	push   $0x8010af82
80102a5b:	e8 65 db ff ff       	call   801005c5 <panic>
  if(b->dev != 0 && !havedisk1)
80102a60:	8b 45 08             	mov    0x8(%ebp),%eax
80102a63:	8b 40 04             	mov    0x4(%eax),%eax
80102a66:	85 c0                	test   %eax,%eax
80102a68:	74 16                	je     80102a80 <iderw+0x85>
80102a6a:	a1 98 00 11 80       	mov    0x80110098,%eax
80102a6f:	85 c0                	test   %eax,%eax
80102a71:	75 0d                	jne    80102a80 <iderw+0x85>
    panic("iderw: ide disk 1 not present");
80102a73:	83 ec 0c             	sub    $0xc,%esp
80102a76:	68 97 af 10 80       	push   $0x8010af97
80102a7b:	e8 45 db ff ff       	call   801005c5 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a80:	83 ec 0c             	sub    $0xc,%esp
80102a83:	68 60 00 11 80       	push   $0x80110060
80102a88:	e8 43 27 00 00       	call   801051d0 <acquire>
80102a8d:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a90:	8b 45 08             	mov    0x8(%ebp),%eax
80102a93:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a9a:	c7 45 f4 94 00 11 80 	movl   $0x80110094,-0xc(%ebp)
80102aa1:	eb 0b                	jmp    80102aae <iderw+0xb3>
80102aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa6:	8b 00                	mov    (%eax),%eax
80102aa8:	83 c0 58             	add    $0x58,%eax
80102aab:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab1:	8b 00                	mov    (%eax),%eax
80102ab3:	85 c0                	test   %eax,%eax
80102ab5:	75 ec                	jne    80102aa3 <iderw+0xa8>
    ;
  *pp = b;
80102ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aba:	8b 55 08             	mov    0x8(%ebp),%edx
80102abd:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102abf:	a1 94 00 11 80       	mov    0x80110094,%eax
80102ac4:	39 45 08             	cmp    %eax,0x8(%ebp)
80102ac7:	75 23                	jne    80102aec <iderw+0xf1>
    idestart(b);
80102ac9:	83 ec 0c             	sub    $0xc,%esp
80102acc:	ff 75 08             	pushl  0x8(%ebp)
80102acf:	e8 b8 fc ff ff       	call   8010278c <idestart>
80102ad4:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ad7:	eb 13                	jmp    80102aec <iderw+0xf1>
    sleep(b, &idelock);
80102ad9:	83 ec 08             	sub    $0x8,%esp
80102adc:	68 60 00 11 80       	push   $0x80110060
80102ae1:	ff 75 08             	pushl  0x8(%ebp)
80102ae4:	e8 3d 21 00 00       	call   80104c26 <sleep>
80102ae9:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102aec:	8b 45 08             	mov    0x8(%ebp),%eax
80102aef:	8b 00                	mov    (%eax),%eax
80102af1:	83 e0 06             	and    $0x6,%eax
80102af4:	83 f8 02             	cmp    $0x2,%eax
80102af7:	75 e0                	jne    80102ad9 <iderw+0xde>
  }


  release(&idelock);
80102af9:	83 ec 0c             	sub    $0xc,%esp
80102afc:	68 60 00 11 80       	push   $0x80110060
80102b01:	e8 3c 27 00 00       	call   80105242 <release>
80102b06:	83 c4 10             	add    $0x10,%esp
}
80102b09:	90                   	nop
80102b0a:	c9                   	leave  
80102b0b:	c3                   	ret    

80102b0c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b0c:	f3 0f 1e fb          	endbr32 
80102b10:	55                   	push   %ebp
80102b11:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b13:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b18:	8b 55 08             	mov    0x8(%ebp),%edx
80102b1b:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b1d:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b22:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b25:	5d                   	pop    %ebp
80102b26:	c3                   	ret    

80102b27 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b27:	f3 0f 1e fb          	endbr32 
80102b2b:	55                   	push   %ebp
80102b2c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b2e:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b33:	8b 55 08             	mov    0x8(%ebp),%edx
80102b36:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b38:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b3d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b40:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b43:	90                   	nop
80102b44:	5d                   	pop    %ebp
80102b45:	c3                   	ret    

80102b46 <ioapicinit>:

void
ioapicinit(void)
{
80102b46:	f3 0f 1e fb          	endbr32 
80102b4a:	55                   	push   %ebp
80102b4b:	89 e5                	mov    %esp,%ebp
80102b4d:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b50:	c7 05 14 84 11 80 00 	movl   $0xfec00000,0x80118414
80102b57:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b5a:	6a 01                	push   $0x1
80102b5c:	e8 ab ff ff ff       	call   80102b0c <ioapicread>
80102b61:	83 c4 04             	add    $0x4,%esp
80102b64:	c1 e8 10             	shr    $0x10,%eax
80102b67:	25 ff 00 00 00       	and    $0xff,%eax
80102b6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b6f:	6a 00                	push   $0x0
80102b71:	e8 96 ff ff ff       	call   80102b0c <ioapicread>
80102b76:	83 c4 04             	add    $0x4,%esp
80102b79:	c1 e8 18             	shr    $0x18,%eax
80102b7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b7f:	0f b6 05 e0 b1 11 80 	movzbl 0x8011b1e0,%eax
80102b86:	0f b6 c0             	movzbl %al,%eax
80102b89:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102b8c:	74 10                	je     80102b9e <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b8e:	83 ec 0c             	sub    $0xc,%esp
80102b91:	68 b8 af 10 80       	push   $0x8010afb8
80102b96:	e8 71 d8 ff ff       	call   8010040c <cprintf>
80102b9b:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ba5:	eb 3f                	jmp    80102be6 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102baa:	83 c0 20             	add    $0x20,%eax
80102bad:	0d 00 00 01 00       	or     $0x10000,%eax
80102bb2:	89 c2                	mov    %eax,%edx
80102bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb7:	83 c0 08             	add    $0x8,%eax
80102bba:	01 c0                	add    %eax,%eax
80102bbc:	83 ec 08             	sub    $0x8,%esp
80102bbf:	52                   	push   %edx
80102bc0:	50                   	push   %eax
80102bc1:	e8 61 ff ff ff       	call   80102b27 <ioapicwrite>
80102bc6:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bcc:	83 c0 08             	add    $0x8,%eax
80102bcf:	01 c0                	add    %eax,%eax
80102bd1:	83 c0 01             	add    $0x1,%eax
80102bd4:	83 ec 08             	sub    $0x8,%esp
80102bd7:	6a 00                	push   $0x0
80102bd9:	50                   	push   %eax
80102bda:	e8 48 ff ff ff       	call   80102b27 <ioapicwrite>
80102bdf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102be2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102bec:	7e b9                	jle    80102ba7 <ioapicinit+0x61>
  }
}
80102bee:	90                   	nop
80102bef:	90                   	nop
80102bf0:	c9                   	leave  
80102bf1:	c3                   	ret    

80102bf2 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102bf2:	f3 0f 1e fb          	endbr32 
80102bf6:	55                   	push   %ebp
80102bf7:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102bf9:	8b 45 08             	mov    0x8(%ebp),%eax
80102bfc:	83 c0 20             	add    $0x20,%eax
80102bff:	89 c2                	mov    %eax,%edx
80102c01:	8b 45 08             	mov    0x8(%ebp),%eax
80102c04:	83 c0 08             	add    $0x8,%eax
80102c07:	01 c0                	add    %eax,%eax
80102c09:	52                   	push   %edx
80102c0a:	50                   	push   %eax
80102c0b:	e8 17 ff ff ff       	call   80102b27 <ioapicwrite>
80102c10:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c13:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c16:	c1 e0 18             	shl    $0x18,%eax
80102c19:	89 c2                	mov    %eax,%edx
80102c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c1e:	83 c0 08             	add    $0x8,%eax
80102c21:	01 c0                	add    %eax,%eax
80102c23:	83 c0 01             	add    $0x1,%eax
80102c26:	52                   	push   %edx
80102c27:	50                   	push   %eax
80102c28:	e8 fa fe ff ff       	call   80102b27 <ioapicwrite>
80102c2d:	83 c4 08             	add    $0x8,%esp
}
80102c30:	90                   	nop
80102c31:	c9                   	leave  
80102c32:	c3                   	ret    

80102c33 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c33:	f3 0f 1e fb          	endbr32 
80102c37:	55                   	push   %ebp
80102c38:	89 e5                	mov    %esp,%ebp
80102c3a:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102c3d:	83 ec 08             	sub    $0x8,%esp
80102c40:	68 ea af 10 80       	push   $0x8010afea
80102c45:	68 20 84 11 80       	push   $0x80118420
80102c4a:	e8 5b 25 00 00       	call   801051aa <initlock>
80102c4f:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102c52:	c7 05 54 84 11 80 00 	movl   $0x0,0x80118454
80102c59:	00 00 00 
  freerange(vstart, vend);
80102c5c:	83 ec 08             	sub    $0x8,%esp
80102c5f:	ff 75 0c             	pushl  0xc(%ebp)
80102c62:	ff 75 08             	pushl  0x8(%ebp)
80102c65:	e8 2e 00 00 00       	call   80102c98 <freerange>
80102c6a:	83 c4 10             	add    $0x10,%esp
}
80102c6d:	90                   	nop
80102c6e:	c9                   	leave  
80102c6f:	c3                   	ret    

80102c70 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c70:	f3 0f 1e fb          	endbr32 
80102c74:	55                   	push   %ebp
80102c75:	89 e5                	mov    %esp,%ebp
80102c77:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c7a:	83 ec 08             	sub    $0x8,%esp
80102c7d:	ff 75 0c             	pushl  0xc(%ebp)
80102c80:	ff 75 08             	pushl  0x8(%ebp)
80102c83:	e8 10 00 00 00       	call   80102c98 <freerange>
80102c88:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c8b:	c7 05 54 84 11 80 01 	movl   $0x1,0x80118454
80102c92:	00 00 00 
}
80102c95:	90                   	nop
80102c96:	c9                   	leave  
80102c97:	c3                   	ret    

80102c98 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c98:	f3 0f 1e fb          	endbr32 
80102c9c:	55                   	push   %ebp
80102c9d:	89 e5                	mov    %esp,%ebp
80102c9f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca5:	05 ff 0f 00 00       	add    $0xfff,%eax
80102caa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102caf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cb2:	eb 15                	jmp    80102cc9 <freerange+0x31>
    kfree(p);
80102cb4:	83 ec 0c             	sub    $0xc,%esp
80102cb7:	ff 75 f4             	pushl  -0xc(%ebp)
80102cba:	e8 1b 00 00 00       	call   80102cda <kfree>
80102cbf:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cc2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ccc:	05 00 10 00 00       	add    $0x1000,%eax
80102cd1:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102cd4:	73 de                	jae    80102cb4 <freerange+0x1c>
}
80102cd6:	90                   	nop
80102cd7:	90                   	nop
80102cd8:	c9                   	leave  
80102cd9:	c3                   	ret    

80102cda <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102cda:	f3 0f 1e fb          	endbr32 
80102cde:	55                   	push   %ebp
80102cdf:	89 e5                	mov    %esp,%ebp
80102ce1:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102ce4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce7:	25 ff 0f 00 00       	and    $0xfff,%eax
80102cec:	85 c0                	test   %eax,%eax
80102cee:	75 18                	jne    80102d08 <kfree+0x2e>
80102cf0:	81 7d 08 00 c0 11 80 	cmpl   $0x8011c000,0x8(%ebp)
80102cf7:	72 0f                	jb     80102d08 <kfree+0x2e>
80102cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80102cfc:	05 00 00 00 80       	add    $0x80000000,%eax
80102d01:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102d06:	76 0d                	jbe    80102d15 <kfree+0x3b>
    panic("kfree");
80102d08:	83 ec 0c             	sub    $0xc,%esp
80102d0b:	68 ef af 10 80       	push   $0x8010afef
80102d10:	e8 b0 d8 ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d15:	83 ec 04             	sub    $0x4,%esp
80102d18:	68 00 10 00 00       	push   $0x1000
80102d1d:	6a 01                	push   $0x1
80102d1f:	ff 75 08             	pushl  0x8(%ebp)
80102d22:	e8 38 27 00 00       	call   8010545f <memset>
80102d27:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102d2a:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d2f:	85 c0                	test   %eax,%eax
80102d31:	74 10                	je     80102d43 <kfree+0x69>
    acquire(&kmem.lock);
80102d33:	83 ec 0c             	sub    $0xc,%esp
80102d36:	68 20 84 11 80       	push   $0x80118420
80102d3b:	e8 90 24 00 00       	call   801051d0 <acquire>
80102d40:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102d43:	8b 45 08             	mov    0x8(%ebp),%eax
80102d46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102d49:	8b 15 58 84 11 80    	mov    0x80118458,%edx
80102d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d52:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d57:	a3 58 84 11 80       	mov    %eax,0x80118458
  if(kmem.use_lock)
80102d5c:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d61:	85 c0                	test   %eax,%eax
80102d63:	74 10                	je     80102d75 <kfree+0x9b>
    release(&kmem.lock);
80102d65:	83 ec 0c             	sub    $0xc,%esp
80102d68:	68 20 84 11 80       	push   $0x80118420
80102d6d:	e8 d0 24 00 00       	call   80105242 <release>
80102d72:	83 c4 10             	add    $0x10,%esp
}
80102d75:	90                   	nop
80102d76:	c9                   	leave  
80102d77:	c3                   	ret    

80102d78 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d78:	f3 0f 1e fb          	endbr32 
80102d7c:	55                   	push   %ebp
80102d7d:	89 e5                	mov    %esp,%ebp
80102d7f:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d82:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d87:	85 c0                	test   %eax,%eax
80102d89:	74 10                	je     80102d9b <kalloc+0x23>
    acquire(&kmem.lock);
80102d8b:	83 ec 0c             	sub    $0xc,%esp
80102d8e:	68 20 84 11 80       	push   $0x80118420
80102d93:	e8 38 24 00 00       	call   801051d0 <acquire>
80102d98:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d9b:	a1 58 84 11 80       	mov    0x80118458,%eax
80102da0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102da3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102da7:	74 0a                	je     80102db3 <kalloc+0x3b>
    kmem.freelist = r->next;
80102da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dac:	8b 00                	mov    (%eax),%eax
80102dae:	a3 58 84 11 80       	mov    %eax,0x80118458
  if(kmem.use_lock)
80102db3:	a1 54 84 11 80       	mov    0x80118454,%eax
80102db8:	85 c0                	test   %eax,%eax
80102dba:	74 10                	je     80102dcc <kalloc+0x54>
    release(&kmem.lock);
80102dbc:	83 ec 0c             	sub    $0xc,%esp
80102dbf:	68 20 84 11 80       	push   $0x80118420
80102dc4:	e8 79 24 00 00       	call   80105242 <release>
80102dc9:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102dcf:	c9                   	leave  
80102dd0:	c3                   	ret    

80102dd1 <inb>:
{
80102dd1:	55                   	push   %ebp
80102dd2:	89 e5                	mov    %esp,%ebp
80102dd4:	83 ec 14             	sub    $0x14,%esp
80102dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80102dda:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dde:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102de2:	89 c2                	mov    %eax,%edx
80102de4:	ec                   	in     (%dx),%al
80102de5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102de8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102dec:	c9                   	leave  
80102ded:	c3                   	ret    

80102dee <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102dee:	f3 0f 1e fb          	endbr32 
80102df2:	55                   	push   %ebp
80102df3:	89 e5                	mov    %esp,%ebp
80102df5:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102df8:	6a 64                	push   $0x64
80102dfa:	e8 d2 ff ff ff       	call   80102dd1 <inb>
80102dff:	83 c4 04             	add    $0x4,%esp
80102e02:	0f b6 c0             	movzbl %al,%eax
80102e05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e0b:	83 e0 01             	and    $0x1,%eax
80102e0e:	85 c0                	test   %eax,%eax
80102e10:	75 0a                	jne    80102e1c <kbdgetc+0x2e>
    return -1;
80102e12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e17:	e9 23 01 00 00       	jmp    80102f3f <kbdgetc+0x151>
  data = inb(KBDATAP);
80102e1c:	6a 60                	push   $0x60
80102e1e:	e8 ae ff ff ff       	call   80102dd1 <inb>
80102e23:	83 c4 04             	add    $0x4,%esp
80102e26:	0f b6 c0             	movzbl %al,%eax
80102e29:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e2c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e33:	75 17                	jne    80102e4c <kbdgetc+0x5e>
    shift |= E0ESC;
80102e35:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e3a:	83 c8 40             	or     $0x40,%eax
80102e3d:	a3 9c 00 11 80       	mov    %eax,0x8011009c
    return 0;
80102e42:	b8 00 00 00 00       	mov    $0x0,%eax
80102e47:	e9 f3 00 00 00       	jmp    80102f3f <kbdgetc+0x151>
  } else if(data & 0x80){
80102e4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e4f:	25 80 00 00 00       	and    $0x80,%eax
80102e54:	85 c0                	test   %eax,%eax
80102e56:	74 45                	je     80102e9d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e58:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e5d:	83 e0 40             	and    $0x40,%eax
80102e60:	85 c0                	test   %eax,%eax
80102e62:	75 08                	jne    80102e6c <kbdgetc+0x7e>
80102e64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e67:	83 e0 7f             	and    $0x7f,%eax
80102e6a:	eb 03                	jmp    80102e6f <kbdgetc+0x81>
80102e6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e72:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e75:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102e7a:	0f b6 00             	movzbl (%eax),%eax
80102e7d:	83 c8 40             	or     $0x40,%eax
80102e80:	0f b6 c0             	movzbl %al,%eax
80102e83:	f7 d0                	not    %eax
80102e85:	89 c2                	mov    %eax,%edx
80102e87:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e8c:	21 d0                	and    %edx,%eax
80102e8e:	a3 9c 00 11 80       	mov    %eax,0x8011009c
    return 0;
80102e93:	b8 00 00 00 00       	mov    $0x0,%eax
80102e98:	e9 a2 00 00 00       	jmp    80102f3f <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102e9d:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102ea2:	83 e0 40             	and    $0x40,%eax
80102ea5:	85 c0                	test   %eax,%eax
80102ea7:	74 14                	je     80102ebd <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102ea9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102eb0:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102eb5:	83 e0 bf             	and    $0xffffffbf,%eax
80102eb8:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  }

  shift |= shiftcode[data];
80102ebd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ec0:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102ec5:	0f b6 00             	movzbl (%eax),%eax
80102ec8:	0f b6 d0             	movzbl %al,%edx
80102ecb:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102ed0:	09 d0                	or     %edx,%eax
80102ed2:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  shift ^= togglecode[data];
80102ed7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eda:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102edf:	0f b6 00             	movzbl (%eax),%eax
80102ee2:	0f b6 d0             	movzbl %al,%edx
80102ee5:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102eea:	31 d0                	xor    %edx,%eax
80102eec:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  c = charcode[shift & (CTL | SHIFT)][data];
80102ef1:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102ef6:	83 e0 03             	and    $0x3,%eax
80102ef9:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102f00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f03:	01 d0                	add    %edx,%eax
80102f05:	0f b6 00             	movzbl (%eax),%eax
80102f08:	0f b6 c0             	movzbl %al,%eax
80102f0b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f0e:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102f13:	83 e0 08             	and    $0x8,%eax
80102f16:	85 c0                	test   %eax,%eax
80102f18:	74 22                	je     80102f3c <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102f1a:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f1e:	76 0c                	jbe    80102f2c <kbdgetc+0x13e>
80102f20:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f24:	77 06                	ja     80102f2c <kbdgetc+0x13e>
      c += 'A' - 'a';
80102f26:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f2a:	eb 10                	jmp    80102f3c <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102f2c:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f30:	76 0a                	jbe    80102f3c <kbdgetc+0x14e>
80102f32:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f36:	77 04                	ja     80102f3c <kbdgetc+0x14e>
      c += 'a' - 'A';
80102f38:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f3f:	c9                   	leave  
80102f40:	c3                   	ret    

80102f41 <kbdintr>:

void
kbdintr(void)
{
80102f41:	f3 0f 1e fb          	endbr32 
80102f45:	55                   	push   %ebp
80102f46:	89 e5                	mov    %esp,%ebp
80102f48:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102f4b:	83 ec 0c             	sub    $0xc,%esp
80102f4e:	68 ee 2d 10 80       	push   $0x80102dee
80102f53:	e8 a8 d8 ff ff       	call   80100800 <consoleintr>
80102f58:	83 c4 10             	add    $0x10,%esp
}
80102f5b:	90                   	nop
80102f5c:	c9                   	leave  
80102f5d:	c3                   	ret    

80102f5e <inb>:
{
80102f5e:	55                   	push   %ebp
80102f5f:	89 e5                	mov    %esp,%ebp
80102f61:	83 ec 14             	sub    $0x14,%esp
80102f64:	8b 45 08             	mov    0x8(%ebp),%eax
80102f67:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f6b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f6f:	89 c2                	mov    %eax,%edx
80102f71:	ec                   	in     (%dx),%al
80102f72:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f75:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f79:	c9                   	leave  
80102f7a:	c3                   	ret    

80102f7b <outb>:
{
80102f7b:	55                   	push   %ebp
80102f7c:	89 e5                	mov    %esp,%ebp
80102f7e:	83 ec 08             	sub    $0x8,%esp
80102f81:	8b 45 08             	mov    0x8(%ebp),%eax
80102f84:	8b 55 0c             	mov    0xc(%ebp),%edx
80102f87:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102f8b:	89 d0                	mov    %edx,%eax
80102f8d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f90:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f94:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f98:	ee                   	out    %al,(%dx)
}
80102f99:	90                   	nop
80102f9a:	c9                   	leave  
80102f9b:	c3                   	ret    

80102f9c <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102f9c:	f3 0f 1e fb          	endbr32 
80102fa0:	55                   	push   %ebp
80102fa1:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fa3:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fa8:	8b 55 08             	mov    0x8(%ebp),%edx
80102fab:	c1 e2 02             	shl    $0x2,%edx
80102fae:	01 c2                	add    %eax,%edx
80102fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fb3:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102fb5:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fba:	83 c0 20             	add    $0x20,%eax
80102fbd:	8b 00                	mov    (%eax),%eax
}
80102fbf:	90                   	nop
80102fc0:	5d                   	pop    %ebp
80102fc1:	c3                   	ret    

80102fc2 <lapicinit>:

void
lapicinit(void)
{
80102fc2:	f3 0f 1e fb          	endbr32 
80102fc6:	55                   	push   %ebp
80102fc7:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102fc9:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fce:	85 c0                	test   %eax,%eax
80102fd0:	0f 84 0c 01 00 00    	je     801030e2 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102fd6:	68 3f 01 00 00       	push   $0x13f
80102fdb:	6a 3c                	push   $0x3c
80102fdd:	e8 ba ff ff ff       	call   80102f9c <lapicw>
80102fe2:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102fe5:	6a 0b                	push   $0xb
80102fe7:	68 f8 00 00 00       	push   $0xf8
80102fec:	e8 ab ff ff ff       	call   80102f9c <lapicw>
80102ff1:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ff4:	68 20 00 02 00       	push   $0x20020
80102ff9:	68 c8 00 00 00       	push   $0xc8
80102ffe:	e8 99 ff ff ff       	call   80102f9c <lapicw>
80103003:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80103006:	68 80 96 98 00       	push   $0x989680
8010300b:	68 e0 00 00 00       	push   $0xe0
80103010:	e8 87 ff ff ff       	call   80102f9c <lapicw>
80103015:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103018:	68 00 00 01 00       	push   $0x10000
8010301d:	68 d4 00 00 00       	push   $0xd4
80103022:	e8 75 ff ff ff       	call   80102f9c <lapicw>
80103027:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
8010302a:	68 00 00 01 00       	push   $0x10000
8010302f:	68 d8 00 00 00       	push   $0xd8
80103034:	e8 63 ff ff ff       	call   80102f9c <lapicw>
80103039:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010303c:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103041:	83 c0 30             	add    $0x30,%eax
80103044:	8b 00                	mov    (%eax),%eax
80103046:	c1 e8 10             	shr    $0x10,%eax
80103049:	25 fc 00 00 00       	and    $0xfc,%eax
8010304e:	85 c0                	test   %eax,%eax
80103050:	74 12                	je     80103064 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80103052:	68 00 00 01 00       	push   $0x10000
80103057:	68 d0 00 00 00       	push   $0xd0
8010305c:	e8 3b ff ff ff       	call   80102f9c <lapicw>
80103061:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103064:	6a 33                	push   $0x33
80103066:	68 dc 00 00 00       	push   $0xdc
8010306b:	e8 2c ff ff ff       	call   80102f9c <lapicw>
80103070:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103073:	6a 00                	push   $0x0
80103075:	68 a0 00 00 00       	push   $0xa0
8010307a:	e8 1d ff ff ff       	call   80102f9c <lapicw>
8010307f:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103082:	6a 00                	push   $0x0
80103084:	68 a0 00 00 00       	push   $0xa0
80103089:	e8 0e ff ff ff       	call   80102f9c <lapicw>
8010308e:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103091:	6a 00                	push   $0x0
80103093:	6a 2c                	push   $0x2c
80103095:	e8 02 ff ff ff       	call   80102f9c <lapicw>
8010309a:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010309d:	6a 00                	push   $0x0
8010309f:	68 c4 00 00 00       	push   $0xc4
801030a4:	e8 f3 fe ff ff       	call   80102f9c <lapicw>
801030a9:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801030ac:	68 00 85 08 00       	push   $0x88500
801030b1:	68 c0 00 00 00       	push   $0xc0
801030b6:	e8 e1 fe ff ff       	call   80102f9c <lapicw>
801030bb:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801030be:	90                   	nop
801030bf:	a1 5c 84 11 80       	mov    0x8011845c,%eax
801030c4:	05 00 03 00 00       	add    $0x300,%eax
801030c9:	8b 00                	mov    (%eax),%eax
801030cb:	25 00 10 00 00       	and    $0x1000,%eax
801030d0:	85 c0                	test   %eax,%eax
801030d2:	75 eb                	jne    801030bf <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801030d4:	6a 00                	push   $0x0
801030d6:	6a 20                	push   $0x20
801030d8:	e8 bf fe ff ff       	call   80102f9c <lapicw>
801030dd:	83 c4 08             	add    $0x8,%esp
801030e0:	eb 01                	jmp    801030e3 <lapicinit+0x121>
    return;
801030e2:	90                   	nop
}
801030e3:	c9                   	leave  
801030e4:	c3                   	ret    

801030e5 <lapicid>:

int
lapicid(void)
{
801030e5:	f3 0f 1e fb          	endbr32 
801030e9:	55                   	push   %ebp
801030ea:	89 e5                	mov    %esp,%ebp

  if (!lapic){
801030ec:	a1 5c 84 11 80       	mov    0x8011845c,%eax
801030f1:	85 c0                	test   %eax,%eax
801030f3:	75 07                	jne    801030fc <lapicid+0x17>
    return 0;
801030f5:	b8 00 00 00 00       	mov    $0x0,%eax
801030fa:	eb 0d                	jmp    80103109 <lapicid+0x24>
  }
  return lapic[ID] >> 24;
801030fc:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103101:	83 c0 20             	add    $0x20,%eax
80103104:	8b 00                	mov    (%eax),%eax
80103106:	c1 e8 18             	shr    $0x18,%eax
}
80103109:	5d                   	pop    %ebp
8010310a:	c3                   	ret    

8010310b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010310b:	f3 0f 1e fb          	endbr32 
8010310f:	55                   	push   %ebp
80103110:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103112:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103117:	85 c0                	test   %eax,%eax
80103119:	74 0c                	je     80103127 <lapiceoi+0x1c>
    lapicw(EOI, 0);
8010311b:	6a 00                	push   $0x0
8010311d:	6a 2c                	push   $0x2c
8010311f:	e8 78 fe ff ff       	call   80102f9c <lapicw>
80103124:	83 c4 08             	add    $0x8,%esp
}
80103127:	90                   	nop
80103128:	c9                   	leave  
80103129:	c3                   	ret    

8010312a <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010312a:	f3 0f 1e fb          	endbr32 
8010312e:	55                   	push   %ebp
8010312f:	89 e5                	mov    %esp,%ebp
}
80103131:	90                   	nop
80103132:	5d                   	pop    %ebp
80103133:	c3                   	ret    

80103134 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103134:	f3 0f 1e fb          	endbr32 
80103138:	55                   	push   %ebp
80103139:	89 e5                	mov    %esp,%ebp
8010313b:	83 ec 14             	sub    $0x14,%esp
8010313e:	8b 45 08             	mov    0x8(%ebp),%eax
80103141:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103144:	6a 0f                	push   $0xf
80103146:	6a 70                	push   $0x70
80103148:	e8 2e fe ff ff       	call   80102f7b <outb>
8010314d:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103150:	6a 0a                	push   $0xa
80103152:	6a 71                	push   $0x71
80103154:	e8 22 fe ff ff       	call   80102f7b <outb>
80103159:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010315c:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103163:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103166:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010316b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010316e:	c1 e8 04             	shr    $0x4,%eax
80103171:	89 c2                	mov    %eax,%edx
80103173:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103176:	83 c0 02             	add    $0x2,%eax
80103179:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010317c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103180:	c1 e0 18             	shl    $0x18,%eax
80103183:	50                   	push   %eax
80103184:	68 c4 00 00 00       	push   $0xc4
80103189:	e8 0e fe ff ff       	call   80102f9c <lapicw>
8010318e:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103191:	68 00 c5 00 00       	push   $0xc500
80103196:	68 c0 00 00 00       	push   $0xc0
8010319b:	e8 fc fd ff ff       	call   80102f9c <lapicw>
801031a0:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031a3:	68 c8 00 00 00       	push   $0xc8
801031a8:	e8 7d ff ff ff       	call   8010312a <microdelay>
801031ad:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801031b0:	68 00 85 00 00       	push   $0x8500
801031b5:	68 c0 00 00 00       	push   $0xc0
801031ba:	e8 dd fd ff ff       	call   80102f9c <lapicw>
801031bf:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031c2:	6a 64                	push   $0x64
801031c4:	e8 61 ff ff ff       	call   8010312a <microdelay>
801031c9:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801031d3:	eb 3d                	jmp    80103212 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801031d5:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031d9:	c1 e0 18             	shl    $0x18,%eax
801031dc:	50                   	push   %eax
801031dd:	68 c4 00 00 00       	push   $0xc4
801031e2:	e8 b5 fd ff ff       	call   80102f9c <lapicw>
801031e7:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801031ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801031ed:	c1 e8 0c             	shr    $0xc,%eax
801031f0:	80 cc 06             	or     $0x6,%ah
801031f3:	50                   	push   %eax
801031f4:	68 c0 00 00 00       	push   $0xc0
801031f9:	e8 9e fd ff ff       	call   80102f9c <lapicw>
801031fe:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103201:	68 c8 00 00 00       	push   $0xc8
80103206:	e8 1f ff ff ff       	call   8010312a <microdelay>
8010320b:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
8010320e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103212:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103216:	7e bd                	jle    801031d5 <lapicstartap+0xa1>
  }
}
80103218:	90                   	nop
80103219:	90                   	nop
8010321a:	c9                   	leave  
8010321b:	c3                   	ret    

8010321c <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010321c:	f3 0f 1e fb          	endbr32 
80103220:	55                   	push   %ebp
80103221:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103223:	8b 45 08             	mov    0x8(%ebp),%eax
80103226:	0f b6 c0             	movzbl %al,%eax
80103229:	50                   	push   %eax
8010322a:	6a 70                	push   $0x70
8010322c:	e8 4a fd ff ff       	call   80102f7b <outb>
80103231:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103234:	68 c8 00 00 00       	push   $0xc8
80103239:	e8 ec fe ff ff       	call   8010312a <microdelay>
8010323e:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103241:	6a 71                	push   $0x71
80103243:	e8 16 fd ff ff       	call   80102f5e <inb>
80103248:	83 c4 04             	add    $0x4,%esp
8010324b:	0f b6 c0             	movzbl %al,%eax
}
8010324e:	c9                   	leave  
8010324f:	c3                   	ret    

80103250 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103250:	f3 0f 1e fb          	endbr32 
80103254:	55                   	push   %ebp
80103255:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103257:	6a 00                	push   $0x0
80103259:	e8 be ff ff ff       	call   8010321c <cmos_read>
8010325e:	83 c4 04             	add    $0x4,%esp
80103261:	8b 55 08             	mov    0x8(%ebp),%edx
80103264:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103266:	6a 02                	push   $0x2
80103268:	e8 af ff ff ff       	call   8010321c <cmos_read>
8010326d:	83 c4 04             	add    $0x4,%esp
80103270:	8b 55 08             	mov    0x8(%ebp),%edx
80103273:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103276:	6a 04                	push   $0x4
80103278:	e8 9f ff ff ff       	call   8010321c <cmos_read>
8010327d:	83 c4 04             	add    $0x4,%esp
80103280:	8b 55 08             	mov    0x8(%ebp),%edx
80103283:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103286:	6a 07                	push   $0x7
80103288:	e8 8f ff ff ff       	call   8010321c <cmos_read>
8010328d:	83 c4 04             	add    $0x4,%esp
80103290:	8b 55 08             	mov    0x8(%ebp),%edx
80103293:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103296:	6a 08                	push   $0x8
80103298:	e8 7f ff ff ff       	call   8010321c <cmos_read>
8010329d:	83 c4 04             	add    $0x4,%esp
801032a0:	8b 55 08             	mov    0x8(%ebp),%edx
801032a3:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801032a6:	6a 09                	push   $0x9
801032a8:	e8 6f ff ff ff       	call   8010321c <cmos_read>
801032ad:	83 c4 04             	add    $0x4,%esp
801032b0:	8b 55 08             	mov    0x8(%ebp),%edx
801032b3:	89 42 14             	mov    %eax,0x14(%edx)
}
801032b6:	90                   	nop
801032b7:	c9                   	leave  
801032b8:	c3                   	ret    

801032b9 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801032b9:	f3 0f 1e fb          	endbr32 
801032bd:	55                   	push   %ebp
801032be:	89 e5                	mov    %esp,%ebp
801032c0:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801032c3:	6a 0b                	push   $0xb
801032c5:	e8 52 ff ff ff       	call   8010321c <cmos_read>
801032ca:	83 c4 04             	add    $0x4,%esp
801032cd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801032d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d3:	83 e0 04             	and    $0x4,%eax
801032d6:	85 c0                	test   %eax,%eax
801032d8:	0f 94 c0             	sete   %al
801032db:	0f b6 c0             	movzbl %al,%eax
801032de:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801032e1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032e4:	50                   	push   %eax
801032e5:	e8 66 ff ff ff       	call   80103250 <fill_rtcdate>
801032ea:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801032ed:	6a 0a                	push   $0xa
801032ef:	e8 28 ff ff ff       	call   8010321c <cmos_read>
801032f4:	83 c4 04             	add    $0x4,%esp
801032f7:	25 80 00 00 00       	and    $0x80,%eax
801032fc:	85 c0                	test   %eax,%eax
801032fe:	75 27                	jne    80103327 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80103300:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103303:	50                   	push   %eax
80103304:	e8 47 ff ff ff       	call   80103250 <fill_rtcdate>
80103309:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010330c:	83 ec 04             	sub    $0x4,%esp
8010330f:	6a 18                	push   $0x18
80103311:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103314:	50                   	push   %eax
80103315:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103318:	50                   	push   %eax
80103319:	e8 ac 21 00 00       	call   801054ca <memcmp>
8010331e:	83 c4 10             	add    $0x10,%esp
80103321:	85 c0                	test   %eax,%eax
80103323:	74 05                	je     8010332a <cmostime+0x71>
80103325:	eb ba                	jmp    801032e1 <cmostime+0x28>
        continue;
80103327:	90                   	nop
    fill_rtcdate(&t1);
80103328:	eb b7                	jmp    801032e1 <cmostime+0x28>
      break;
8010332a:	90                   	nop
  }

  // convert
  if(bcd) {
8010332b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010332f:	0f 84 b4 00 00 00    	je     801033e9 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103335:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103338:	c1 e8 04             	shr    $0x4,%eax
8010333b:	89 c2                	mov    %eax,%edx
8010333d:	89 d0                	mov    %edx,%eax
8010333f:	c1 e0 02             	shl    $0x2,%eax
80103342:	01 d0                	add    %edx,%eax
80103344:	01 c0                	add    %eax,%eax
80103346:	89 c2                	mov    %eax,%edx
80103348:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010334b:	83 e0 0f             	and    $0xf,%eax
8010334e:	01 d0                	add    %edx,%eax
80103350:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103353:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103356:	c1 e8 04             	shr    $0x4,%eax
80103359:	89 c2                	mov    %eax,%edx
8010335b:	89 d0                	mov    %edx,%eax
8010335d:	c1 e0 02             	shl    $0x2,%eax
80103360:	01 d0                	add    %edx,%eax
80103362:	01 c0                	add    %eax,%eax
80103364:	89 c2                	mov    %eax,%edx
80103366:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103369:	83 e0 0f             	and    $0xf,%eax
8010336c:	01 d0                	add    %edx,%eax
8010336e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103371:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103374:	c1 e8 04             	shr    $0x4,%eax
80103377:	89 c2                	mov    %eax,%edx
80103379:	89 d0                	mov    %edx,%eax
8010337b:	c1 e0 02             	shl    $0x2,%eax
8010337e:	01 d0                	add    %edx,%eax
80103380:	01 c0                	add    %eax,%eax
80103382:	89 c2                	mov    %eax,%edx
80103384:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103387:	83 e0 0f             	and    $0xf,%eax
8010338a:	01 d0                	add    %edx,%eax
8010338c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010338f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103392:	c1 e8 04             	shr    $0x4,%eax
80103395:	89 c2                	mov    %eax,%edx
80103397:	89 d0                	mov    %edx,%eax
80103399:	c1 e0 02             	shl    $0x2,%eax
8010339c:	01 d0                	add    %edx,%eax
8010339e:	01 c0                	add    %eax,%eax
801033a0:	89 c2                	mov    %eax,%edx
801033a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033a5:	83 e0 0f             	and    $0xf,%eax
801033a8:	01 d0                	add    %edx,%eax
801033aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801033ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033b0:	c1 e8 04             	shr    $0x4,%eax
801033b3:	89 c2                	mov    %eax,%edx
801033b5:	89 d0                	mov    %edx,%eax
801033b7:	c1 e0 02             	shl    $0x2,%eax
801033ba:	01 d0                	add    %edx,%eax
801033bc:	01 c0                	add    %eax,%eax
801033be:	89 c2                	mov    %eax,%edx
801033c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033c3:	83 e0 0f             	and    $0xf,%eax
801033c6:	01 d0                	add    %edx,%eax
801033c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801033cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033ce:	c1 e8 04             	shr    $0x4,%eax
801033d1:	89 c2                	mov    %eax,%edx
801033d3:	89 d0                	mov    %edx,%eax
801033d5:	c1 e0 02             	shl    $0x2,%eax
801033d8:	01 d0                	add    %edx,%eax
801033da:	01 c0                	add    %eax,%eax
801033dc:	89 c2                	mov    %eax,%edx
801033de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e1:	83 e0 0f             	and    $0xf,%eax
801033e4:	01 d0                	add    %edx,%eax
801033e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801033e9:	8b 45 08             	mov    0x8(%ebp),%eax
801033ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
801033ef:	89 10                	mov    %edx,(%eax)
801033f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
801033f4:	89 50 04             	mov    %edx,0x4(%eax)
801033f7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801033fa:	89 50 08             	mov    %edx,0x8(%eax)
801033fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103400:	89 50 0c             	mov    %edx,0xc(%eax)
80103403:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103406:	89 50 10             	mov    %edx,0x10(%eax)
80103409:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010340c:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010340f:	8b 45 08             	mov    0x8(%ebp),%eax
80103412:	8b 40 14             	mov    0x14(%eax),%eax
80103415:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010341b:	8b 45 08             	mov    0x8(%ebp),%eax
8010341e:	89 50 14             	mov    %edx,0x14(%eax)
}
80103421:	90                   	nop
80103422:	c9                   	leave  
80103423:	c3                   	ret    

80103424 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103424:	f3 0f 1e fb          	endbr32 
80103428:	55                   	push   %ebp
80103429:	89 e5                	mov    %esp,%ebp
8010342b:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010342e:	83 ec 08             	sub    $0x8,%esp
80103431:	68 f5 af 10 80       	push   $0x8010aff5
80103436:	68 60 84 11 80       	push   $0x80118460
8010343b:	e8 6a 1d 00 00       	call   801051aa <initlock>
80103440:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103443:	83 ec 08             	sub    $0x8,%esp
80103446:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103449:	50                   	push   %eax
8010344a:	ff 75 08             	pushl  0x8(%ebp)
8010344d:	e8 c8 df ff ff       	call   8010141a <readsb>
80103452:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103455:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103458:	a3 94 84 11 80       	mov    %eax,0x80118494
  log.size = sb.nlog;
8010345d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103460:	a3 98 84 11 80       	mov    %eax,0x80118498
  log.dev = dev;
80103465:	8b 45 08             	mov    0x8(%ebp),%eax
80103468:	a3 a4 84 11 80       	mov    %eax,0x801184a4
  recover_from_log();
8010346d:	e8 bf 01 00 00       	call   80103631 <recover_from_log>
}
80103472:	90                   	nop
80103473:	c9                   	leave  
80103474:	c3                   	ret    

80103475 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103475:	f3 0f 1e fb          	endbr32 
80103479:	55                   	push   %ebp
8010347a:	89 e5                	mov    %esp,%ebp
8010347c:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010347f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103486:	e9 95 00 00 00       	jmp    80103520 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010348b:	8b 15 94 84 11 80    	mov    0x80118494,%edx
80103491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103494:	01 d0                	add    %edx,%eax
80103496:	83 c0 01             	add    $0x1,%eax
80103499:	89 c2                	mov    %eax,%edx
8010349b:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801034a0:	83 ec 08             	sub    $0x8,%esp
801034a3:	52                   	push   %edx
801034a4:	50                   	push   %eax
801034a5:	e8 5f cd ff ff       	call   80100209 <bread>
801034aa:	83 c4 10             	add    $0x10,%esp
801034ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801034b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034b3:	83 c0 10             	add    $0x10,%eax
801034b6:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
801034bd:	89 c2                	mov    %eax,%edx
801034bf:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801034c4:	83 ec 08             	sub    $0x8,%esp
801034c7:	52                   	push   %edx
801034c8:	50                   	push   %eax
801034c9:	e8 3b cd ff ff       	call   80100209 <bread>
801034ce:	83 c4 10             	add    $0x10,%esp
801034d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801034d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d7:	8d 50 5c             	lea    0x5c(%eax),%edx
801034da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dd:	83 c0 5c             	add    $0x5c,%eax
801034e0:	83 ec 04             	sub    $0x4,%esp
801034e3:	68 00 02 00 00       	push   $0x200
801034e8:	52                   	push   %edx
801034e9:	50                   	push   %eax
801034ea:	e8 37 20 00 00       	call   80105526 <memmove>
801034ef:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801034f2:	83 ec 0c             	sub    $0xc,%esp
801034f5:	ff 75 ec             	pushl  -0x14(%ebp)
801034f8:	e8 49 cd ff ff       	call   80100246 <bwrite>
801034fd:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103500:	83 ec 0c             	sub    $0xc,%esp
80103503:	ff 75 f0             	pushl  -0x10(%ebp)
80103506:	e8 88 cd ff ff       	call   80100293 <brelse>
8010350b:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010350e:	83 ec 0c             	sub    $0xc,%esp
80103511:	ff 75 ec             	pushl  -0x14(%ebp)
80103514:	e8 7a cd ff ff       	call   80100293 <brelse>
80103519:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010351c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103520:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103525:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103528:	0f 8c 5d ff ff ff    	jl     8010348b <install_trans+0x16>
  }
}
8010352e:	90                   	nop
8010352f:	90                   	nop
80103530:	c9                   	leave  
80103531:	c3                   	ret    

80103532 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103532:	f3 0f 1e fb          	endbr32 
80103536:	55                   	push   %ebp
80103537:	89 e5                	mov    %esp,%ebp
80103539:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010353c:	a1 94 84 11 80       	mov    0x80118494,%eax
80103541:	89 c2                	mov    %eax,%edx
80103543:	a1 a4 84 11 80       	mov    0x801184a4,%eax
80103548:	83 ec 08             	sub    $0x8,%esp
8010354b:	52                   	push   %edx
8010354c:	50                   	push   %eax
8010354d:	e8 b7 cc ff ff       	call   80100209 <bread>
80103552:	83 c4 10             	add    $0x10,%esp
80103555:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103558:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010355b:	83 c0 5c             	add    $0x5c,%eax
8010355e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103561:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103564:	8b 00                	mov    (%eax),%eax
80103566:	a3 a8 84 11 80       	mov    %eax,0x801184a8
  for (i = 0; i < log.lh.n; i++) {
8010356b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103572:	eb 1b                	jmp    8010358f <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
80103574:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103577:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010357a:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010357e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103581:	83 c2 10             	add    $0x10,%edx
80103584:	89 04 95 6c 84 11 80 	mov    %eax,-0x7fee7b94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010358b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010358f:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103594:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103597:	7c db                	jl     80103574 <read_head+0x42>
  }
  brelse(buf);
80103599:	83 ec 0c             	sub    $0xc,%esp
8010359c:	ff 75 f0             	pushl  -0x10(%ebp)
8010359f:	e8 ef cc ff ff       	call   80100293 <brelse>
801035a4:	83 c4 10             	add    $0x10,%esp
}
801035a7:	90                   	nop
801035a8:	c9                   	leave  
801035a9:	c3                   	ret    

801035aa <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801035aa:	f3 0f 1e fb          	endbr32 
801035ae:	55                   	push   %ebp
801035af:	89 e5                	mov    %esp,%ebp
801035b1:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035b4:	a1 94 84 11 80       	mov    0x80118494,%eax
801035b9:	89 c2                	mov    %eax,%edx
801035bb:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801035c0:	83 ec 08             	sub    $0x8,%esp
801035c3:	52                   	push   %edx
801035c4:	50                   	push   %eax
801035c5:	e8 3f cc ff ff       	call   80100209 <bread>
801035ca:	83 c4 10             	add    $0x10,%esp
801035cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801035d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d3:	83 c0 5c             	add    $0x5c,%eax
801035d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801035d9:	8b 15 a8 84 11 80    	mov    0x801184a8,%edx
801035df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035e2:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801035e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035eb:	eb 1b                	jmp    80103608 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801035ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f0:	83 c0 10             	add    $0x10,%eax
801035f3:	8b 0c 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%ecx
801035fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103600:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103604:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103608:	a1 a8 84 11 80       	mov    0x801184a8,%eax
8010360d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103610:	7c db                	jl     801035ed <write_head+0x43>
  }
  bwrite(buf);
80103612:	83 ec 0c             	sub    $0xc,%esp
80103615:	ff 75 f0             	pushl  -0x10(%ebp)
80103618:	e8 29 cc ff ff       	call   80100246 <bwrite>
8010361d:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103620:	83 ec 0c             	sub    $0xc,%esp
80103623:	ff 75 f0             	pushl  -0x10(%ebp)
80103626:	e8 68 cc ff ff       	call   80100293 <brelse>
8010362b:	83 c4 10             	add    $0x10,%esp
}
8010362e:	90                   	nop
8010362f:	c9                   	leave  
80103630:	c3                   	ret    

80103631 <recover_from_log>:

static void
recover_from_log(void)
{
80103631:	f3 0f 1e fb          	endbr32 
80103635:	55                   	push   %ebp
80103636:	89 e5                	mov    %esp,%ebp
80103638:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010363b:	e8 f2 fe ff ff       	call   80103532 <read_head>
  install_trans(); // if committed, copy from log to disk
80103640:	e8 30 fe ff ff       	call   80103475 <install_trans>
  log.lh.n = 0;
80103645:	c7 05 a8 84 11 80 00 	movl   $0x0,0x801184a8
8010364c:	00 00 00 
  write_head(); // clear the log
8010364f:	e8 56 ff ff ff       	call   801035aa <write_head>
}
80103654:	90                   	nop
80103655:	c9                   	leave  
80103656:	c3                   	ret    

80103657 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103657:	f3 0f 1e fb          	endbr32 
8010365b:	55                   	push   %ebp
8010365c:	89 e5                	mov    %esp,%ebp
8010365e:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103661:	83 ec 0c             	sub    $0xc,%esp
80103664:	68 60 84 11 80       	push   $0x80118460
80103669:	e8 62 1b 00 00       	call   801051d0 <acquire>
8010366e:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103671:	a1 a0 84 11 80       	mov    0x801184a0,%eax
80103676:	85 c0                	test   %eax,%eax
80103678:	74 17                	je     80103691 <begin_op+0x3a>
      sleep(&log, &log.lock);
8010367a:	83 ec 08             	sub    $0x8,%esp
8010367d:	68 60 84 11 80       	push   $0x80118460
80103682:	68 60 84 11 80       	push   $0x80118460
80103687:	e8 9a 15 00 00       	call   80104c26 <sleep>
8010368c:	83 c4 10             	add    $0x10,%esp
8010368f:	eb e0                	jmp    80103671 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103691:	8b 0d a8 84 11 80    	mov    0x801184a8,%ecx
80103697:	a1 9c 84 11 80       	mov    0x8011849c,%eax
8010369c:	8d 50 01             	lea    0x1(%eax),%edx
8010369f:	89 d0                	mov    %edx,%eax
801036a1:	c1 e0 02             	shl    $0x2,%eax
801036a4:	01 d0                	add    %edx,%eax
801036a6:	01 c0                	add    %eax,%eax
801036a8:	01 c8                	add    %ecx,%eax
801036aa:	83 f8 1e             	cmp    $0x1e,%eax
801036ad:	7e 17                	jle    801036c6 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801036af:	83 ec 08             	sub    $0x8,%esp
801036b2:	68 60 84 11 80       	push   $0x80118460
801036b7:	68 60 84 11 80       	push   $0x80118460
801036bc:	e8 65 15 00 00       	call   80104c26 <sleep>
801036c1:	83 c4 10             	add    $0x10,%esp
801036c4:	eb ab                	jmp    80103671 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801036c6:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801036cb:	83 c0 01             	add    $0x1,%eax
801036ce:	a3 9c 84 11 80       	mov    %eax,0x8011849c
      release(&log.lock);
801036d3:	83 ec 0c             	sub    $0xc,%esp
801036d6:	68 60 84 11 80       	push   $0x80118460
801036db:	e8 62 1b 00 00       	call   80105242 <release>
801036e0:	83 c4 10             	add    $0x10,%esp
      break;
801036e3:	90                   	nop
    }
  }
}
801036e4:	90                   	nop
801036e5:	c9                   	leave  
801036e6:	c3                   	ret    

801036e7 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801036e7:	f3 0f 1e fb          	endbr32 
801036eb:	55                   	push   %ebp
801036ec:	89 e5                	mov    %esp,%ebp
801036ee:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801036f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801036f8:	83 ec 0c             	sub    $0xc,%esp
801036fb:	68 60 84 11 80       	push   $0x80118460
80103700:	e8 cb 1a 00 00       	call   801051d0 <acquire>
80103705:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103708:	a1 9c 84 11 80       	mov    0x8011849c,%eax
8010370d:	83 e8 01             	sub    $0x1,%eax
80103710:	a3 9c 84 11 80       	mov    %eax,0x8011849c
  if(log.committing)
80103715:	a1 a0 84 11 80       	mov    0x801184a0,%eax
8010371a:	85 c0                	test   %eax,%eax
8010371c:	74 0d                	je     8010372b <end_op+0x44>
    panic("log.committing");
8010371e:	83 ec 0c             	sub    $0xc,%esp
80103721:	68 f9 af 10 80       	push   $0x8010aff9
80103726:	e8 9a ce ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
8010372b:	a1 9c 84 11 80       	mov    0x8011849c,%eax
80103730:	85 c0                	test   %eax,%eax
80103732:	75 13                	jne    80103747 <end_op+0x60>
    do_commit = 1;
80103734:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010373b:	c7 05 a0 84 11 80 01 	movl   $0x1,0x801184a0
80103742:	00 00 00 
80103745:	eb 10                	jmp    80103757 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	68 60 84 11 80       	push   $0x80118460
8010374f:	e8 c4 15 00 00       	call   80104d18 <wakeup>
80103754:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103757:	83 ec 0c             	sub    $0xc,%esp
8010375a:	68 60 84 11 80       	push   $0x80118460
8010375f:	e8 de 1a 00 00       	call   80105242 <release>
80103764:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103767:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010376b:	74 3f                	je     801037ac <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010376d:	e8 fa 00 00 00       	call   8010386c <commit>
    acquire(&log.lock);
80103772:	83 ec 0c             	sub    $0xc,%esp
80103775:	68 60 84 11 80       	push   $0x80118460
8010377a:	e8 51 1a 00 00       	call   801051d0 <acquire>
8010377f:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103782:	c7 05 a0 84 11 80 00 	movl   $0x0,0x801184a0
80103789:	00 00 00 
    wakeup(&log);
8010378c:	83 ec 0c             	sub    $0xc,%esp
8010378f:	68 60 84 11 80       	push   $0x80118460
80103794:	e8 7f 15 00 00       	call   80104d18 <wakeup>
80103799:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010379c:	83 ec 0c             	sub    $0xc,%esp
8010379f:	68 60 84 11 80       	push   $0x80118460
801037a4:	e8 99 1a 00 00       	call   80105242 <release>
801037a9:	83 c4 10             	add    $0x10,%esp
  }
}
801037ac:	90                   	nop
801037ad:	c9                   	leave  
801037ae:	c3                   	ret    

801037af <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801037af:	f3 0f 1e fb          	endbr32 
801037b3:	55                   	push   %ebp
801037b4:	89 e5                	mov    %esp,%ebp
801037b6:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037c0:	e9 95 00 00 00       	jmp    8010385a <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801037c5:	8b 15 94 84 11 80    	mov    0x80118494,%edx
801037cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ce:	01 d0                	add    %edx,%eax
801037d0:	83 c0 01             	add    $0x1,%eax
801037d3:	89 c2                	mov    %eax,%edx
801037d5:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801037da:	83 ec 08             	sub    $0x8,%esp
801037dd:	52                   	push   %edx
801037de:	50                   	push   %eax
801037df:	e8 25 ca ff ff       	call   80100209 <bread>
801037e4:	83 c4 10             	add    $0x10,%esp
801037e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801037ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ed:	83 c0 10             	add    $0x10,%eax
801037f0:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
801037f7:	89 c2                	mov    %eax,%edx
801037f9:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801037fe:	83 ec 08             	sub    $0x8,%esp
80103801:	52                   	push   %edx
80103802:	50                   	push   %eax
80103803:	e8 01 ca ff ff       	call   80100209 <bread>
80103808:	83 c4 10             	add    $0x10,%esp
8010380b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010380e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103811:	8d 50 5c             	lea    0x5c(%eax),%edx
80103814:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103817:	83 c0 5c             	add    $0x5c,%eax
8010381a:	83 ec 04             	sub    $0x4,%esp
8010381d:	68 00 02 00 00       	push   $0x200
80103822:	52                   	push   %edx
80103823:	50                   	push   %eax
80103824:	e8 fd 1c 00 00       	call   80105526 <memmove>
80103829:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010382c:	83 ec 0c             	sub    $0xc,%esp
8010382f:	ff 75 f0             	pushl  -0x10(%ebp)
80103832:	e8 0f ca ff ff       	call   80100246 <bwrite>
80103837:	83 c4 10             	add    $0x10,%esp
    brelse(from);
8010383a:	83 ec 0c             	sub    $0xc,%esp
8010383d:	ff 75 ec             	pushl  -0x14(%ebp)
80103840:	e8 4e ca ff ff       	call   80100293 <brelse>
80103845:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103848:	83 ec 0c             	sub    $0xc,%esp
8010384b:	ff 75 f0             	pushl  -0x10(%ebp)
8010384e:	e8 40 ca ff ff       	call   80100293 <brelse>
80103853:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103856:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010385a:	a1 a8 84 11 80       	mov    0x801184a8,%eax
8010385f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103862:	0f 8c 5d ff ff ff    	jl     801037c5 <write_log+0x16>
  }
}
80103868:	90                   	nop
80103869:	90                   	nop
8010386a:	c9                   	leave  
8010386b:	c3                   	ret    

8010386c <commit>:

static void
commit()
{
8010386c:	f3 0f 1e fb          	endbr32 
80103870:	55                   	push   %ebp
80103871:	89 e5                	mov    %esp,%ebp
80103873:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103876:	a1 a8 84 11 80       	mov    0x801184a8,%eax
8010387b:	85 c0                	test   %eax,%eax
8010387d:	7e 1e                	jle    8010389d <commit+0x31>
    write_log();     // Write modified blocks from cache to log
8010387f:	e8 2b ff ff ff       	call   801037af <write_log>
    write_head();    // Write header to disk -- the real commit
80103884:	e8 21 fd ff ff       	call   801035aa <write_head>
    install_trans(); // Now install writes to home locations
80103889:	e8 e7 fb ff ff       	call   80103475 <install_trans>
    log.lh.n = 0;
8010388e:	c7 05 a8 84 11 80 00 	movl   $0x0,0x801184a8
80103895:	00 00 00 
    write_head();    // Erase the transaction from the log
80103898:	e8 0d fd ff ff       	call   801035aa <write_head>
  }
}
8010389d:	90                   	nop
8010389e:	c9                   	leave  
8010389f:	c3                   	ret    

801038a0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801038a0:	f3 0f 1e fb          	endbr32 
801038a4:	55                   	push   %ebp
801038a5:	89 e5                	mov    %esp,%ebp
801038a7:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801038aa:	a1 a8 84 11 80       	mov    0x801184a8,%eax
801038af:	83 f8 1d             	cmp    $0x1d,%eax
801038b2:	7f 12                	jg     801038c6 <log_write+0x26>
801038b4:	a1 a8 84 11 80       	mov    0x801184a8,%eax
801038b9:	8b 15 98 84 11 80    	mov    0x80118498,%edx
801038bf:	83 ea 01             	sub    $0x1,%edx
801038c2:	39 d0                	cmp    %edx,%eax
801038c4:	7c 0d                	jl     801038d3 <log_write+0x33>
    panic("too big a transaction");
801038c6:	83 ec 0c             	sub    $0xc,%esp
801038c9:	68 08 b0 10 80       	push   $0x8010b008
801038ce:	e8 f2 cc ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801038d3:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801038d8:	85 c0                	test   %eax,%eax
801038da:	7f 0d                	jg     801038e9 <log_write+0x49>
    panic("log_write outside of trans");
801038dc:	83 ec 0c             	sub    $0xc,%esp
801038df:	68 1e b0 10 80       	push   $0x8010b01e
801038e4:	e8 dc cc ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
801038e9:	83 ec 0c             	sub    $0xc,%esp
801038ec:	68 60 84 11 80       	push   $0x80118460
801038f1:	e8 da 18 00 00       	call   801051d0 <acquire>
801038f6:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801038f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103900:	eb 1d                	jmp    8010391f <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103905:	83 c0 10             	add    $0x10,%eax
80103908:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
8010390f:	89 c2                	mov    %eax,%edx
80103911:	8b 45 08             	mov    0x8(%ebp),%eax
80103914:	8b 40 08             	mov    0x8(%eax),%eax
80103917:	39 c2                	cmp    %eax,%edx
80103919:	74 10                	je     8010392b <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
8010391b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010391f:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103924:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103927:	7c d9                	jl     80103902 <log_write+0x62>
80103929:	eb 01                	jmp    8010392c <log_write+0x8c>
      break;
8010392b:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010392c:	8b 45 08             	mov    0x8(%ebp),%eax
8010392f:	8b 40 08             	mov    0x8(%eax),%eax
80103932:	89 c2                	mov    %eax,%edx
80103934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103937:	83 c0 10             	add    $0x10,%eax
8010393a:	89 14 85 6c 84 11 80 	mov    %edx,-0x7fee7b94(,%eax,4)
  if (i == log.lh.n)
80103941:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103946:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103949:	75 0d                	jne    80103958 <log_write+0xb8>
    log.lh.n++;
8010394b:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103950:	83 c0 01             	add    $0x1,%eax
80103953:	a3 a8 84 11 80       	mov    %eax,0x801184a8
  b->flags |= B_DIRTY; // prevent eviction
80103958:	8b 45 08             	mov    0x8(%ebp),%eax
8010395b:	8b 00                	mov    (%eax),%eax
8010395d:	83 c8 04             	or     $0x4,%eax
80103960:	89 c2                	mov    %eax,%edx
80103962:	8b 45 08             	mov    0x8(%ebp),%eax
80103965:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103967:	83 ec 0c             	sub    $0xc,%esp
8010396a:	68 60 84 11 80       	push   $0x80118460
8010396f:	e8 ce 18 00 00       	call   80105242 <release>
80103974:	83 c4 10             	add    $0x10,%esp
}
80103977:	90                   	nop
80103978:	c9                   	leave  
80103979:	c3                   	ret    

8010397a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010397a:	55                   	push   %ebp
8010397b:	89 e5                	mov    %esp,%ebp
8010397d:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103980:	8b 55 08             	mov    0x8(%ebp),%edx
80103983:	8b 45 0c             	mov    0xc(%ebp),%eax
80103986:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103989:	f0 87 02             	lock xchg %eax,(%edx)
8010398c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010398f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103992:	c9                   	leave  
80103993:	c3                   	ret    

80103994 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103994:	f3 0f 1e fb          	endbr32 
80103998:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010399c:	83 e4 f0             	and    $0xfffffff0,%esp
8010399f:	ff 71 fc             	pushl  -0x4(%ecx)
801039a2:	55                   	push   %ebp
801039a3:	89 e5                	mov    %esp,%ebp
801039a5:	51                   	push   %ecx
801039a6:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
801039a9:	e8 a2 51 00 00       	call   80108b50 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801039ae:	83 ec 08             	sub    $0x8,%esp
801039b1:	68 00 00 40 80       	push   $0x80400000
801039b6:	68 00 c0 11 80       	push   $0x8011c000
801039bb:	e8 73 f2 ff ff       	call   80102c33 <kinit1>
801039c0:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801039c3:	e8 69 46 00 00       	call   80108031 <kvmalloc>
  mpinit_uefi();
801039c8:	e8 3c 4f 00 00       	call   80108909 <mpinit_uefi>
  lapicinit();     // interrupt controller
801039cd:	e8 f0 f5 ff ff       	call   80102fc2 <lapicinit>
  seginit();       // segment descriptors
801039d2:	e8 35 41 00 00       	call   80107b0c <seginit>
  picinit();    // disable pic
801039d7:	e8 a9 01 00 00       	call   80103b85 <picinit>
  ioapicinit();    // another interrupt controller
801039dc:	e8 65 f1 ff ff       	call   80102b46 <ioapicinit>
  consoleinit();   // console hardware
801039e1:	e8 53 d1 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
801039e6:	e8 aa 34 00 00       	call   80106e95 <uartinit>
  pinit();         // process table
801039eb:	e8 e2 05 00 00       	call   80103fd2 <pinit>
  tvinit();        // trap vectors
801039f0:	e8 cb 2f 00 00       	call   801069c0 <tvinit>
  binit();         // buffer cache
801039f5:	e8 6c c6 ff ff       	call   80100066 <binit>
  fileinit();      // file table
801039fa:	e8 f0 d5 ff ff       	call   80100fef <fileinit>
  ideinit();       // disk 
801039ff:	e8 e3 ec ff ff       	call   801026e7 <ideinit>
  startothers();   // start other processors
80103a04:	e8 92 00 00 00       	call   80103a9b <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a09:	83 ec 08             	sub    $0x8,%esp
80103a0c:	68 00 00 00 a0       	push   $0xa0000000
80103a11:	68 00 00 40 80       	push   $0x80400000
80103a16:	e8 55 f2 ff ff       	call   80102c70 <kinit2>
80103a1b:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103a1e:	e8 a0 53 00 00       	call   80108dc3 <pci_init>
  arp_scan();
80103a23:	e8 19 61 00 00       	call   80109b41 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103a28:	e8 ab 07 00 00       	call   801041d8 <userinit>

  mpmain();        // finish this processor's setup
80103a2d:	e8 1e 00 00 00       	call   80103a50 <mpmain>

80103a32 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103a32:	f3 0f 1e fb          	endbr32 
80103a36:	55                   	push   %ebp
80103a37:	89 e5                	mov    %esp,%ebp
80103a39:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103a3c:	e8 0c 46 00 00       	call   8010804d <switchkvm>
  seginit();
80103a41:	e8 c6 40 00 00       	call   80107b0c <seginit>
  lapicinit();
80103a46:	e8 77 f5 ff ff       	call   80102fc2 <lapicinit>
  mpmain();
80103a4b:	e8 00 00 00 00       	call   80103a50 <mpmain>

80103a50 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a50:	f3 0f 1e fb          	endbr32 
80103a54:	55                   	push   %ebp
80103a55:	89 e5                	mov    %esp,%ebp
80103a57:	53                   	push   %ebx
80103a58:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103a5b:	e8 94 05 00 00       	call   80103ff4 <cpuid>
80103a60:	89 c3                	mov    %eax,%ebx
80103a62:	e8 8d 05 00 00       	call   80103ff4 <cpuid>
80103a67:	83 ec 04             	sub    $0x4,%esp
80103a6a:	53                   	push   %ebx
80103a6b:	50                   	push   %eax
80103a6c:	68 39 b0 10 80       	push   $0x8010b039
80103a71:	e8 96 c9 ff ff       	call   8010040c <cprintf>
80103a76:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a79:	e8 bc 30 00 00       	call   80106b3a <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103a7e:	e8 90 05 00 00       	call   80104013 <mycpu>
80103a83:	05 a0 00 00 00       	add    $0xa0,%eax
80103a88:	83 ec 08             	sub    $0x8,%esp
80103a8b:	6a 01                	push   $0x1
80103a8d:	50                   	push   %eax
80103a8e:	e8 e7 fe ff ff       	call   8010397a <xchg>
80103a93:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a96:	e8 87 0f 00 00       	call   80104a22 <scheduler>

80103a9b <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a9b:	f3 0f 1e fb          	endbr32 
80103a9f:	55                   	push   %ebp
80103aa0:	89 e5                	mov    %esp,%ebp
80103aa2:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103aa5:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103aac:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103ab1:	83 ec 04             	sub    $0x4,%esp
80103ab4:	50                   	push   %eax
80103ab5:	68 18 f5 10 80       	push   $0x8010f518
80103aba:	ff 75 f0             	pushl  -0x10(%ebp)
80103abd:	e8 64 1a 00 00       	call   80105526 <memmove>
80103ac2:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103ac5:	c7 45 f4 00 b2 11 80 	movl   $0x8011b200,-0xc(%ebp)
80103acc:	eb 79                	jmp    80103b47 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
80103ace:	e8 40 05 00 00       	call   80104013 <mycpu>
80103ad3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103ad6:	74 67                	je     80103b3f <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103ad8:	e8 9b f2 ff ff       	call   80102d78 <kalloc>
80103add:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ae3:	83 e8 04             	sub    $0x4,%eax
80103ae6:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103ae9:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103aef:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af4:	83 e8 08             	sub    $0x8,%eax
80103af7:	c7 00 32 3a 10 80    	movl   $0x80103a32,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103afd:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
80103b02:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b0b:	83 e8 0c             	sub    $0xc,%eax
80103b0e:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b13:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1c:	0f b6 00             	movzbl (%eax),%eax
80103b1f:	0f b6 c0             	movzbl %al,%eax
80103b22:	83 ec 08             	sub    $0x8,%esp
80103b25:	52                   	push   %edx
80103b26:	50                   	push   %eax
80103b27:	e8 08 f6 ff ff       	call   80103134 <lapicstartap>
80103b2c:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103b2f:	90                   	nop
80103b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b33:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103b39:	85 c0                	test   %eax,%eax
80103b3b:	74 f3                	je     80103b30 <startothers+0x95>
80103b3d:	eb 01                	jmp    80103b40 <startothers+0xa5>
      continue;
80103b3f:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103b40:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103b47:	a1 c0 b4 11 80       	mov    0x8011b4c0,%eax
80103b4c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b52:	05 00 b2 11 80       	add    $0x8011b200,%eax
80103b57:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b5a:	0f 82 6e ff ff ff    	jb     80103ace <startothers+0x33>
      ;
  }
}
80103b60:	90                   	nop
80103b61:	90                   	nop
80103b62:	c9                   	leave  
80103b63:	c3                   	ret    

80103b64 <outb>:
{
80103b64:	55                   	push   %ebp
80103b65:	89 e5                	mov    %esp,%ebp
80103b67:	83 ec 08             	sub    $0x8,%esp
80103b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b70:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103b74:	89 d0                	mov    %edx,%eax
80103b76:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b79:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b7d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b81:	ee                   	out    %al,(%dx)
}
80103b82:	90                   	nop
80103b83:	c9                   	leave  
80103b84:	c3                   	ret    

80103b85 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103b85:	f3 0f 1e fb          	endbr32 
80103b89:	55                   	push   %ebp
80103b8a:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103b8c:	68 ff 00 00 00       	push   $0xff
80103b91:	6a 21                	push   $0x21
80103b93:	e8 cc ff ff ff       	call   80103b64 <outb>
80103b98:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103b9b:	68 ff 00 00 00       	push   $0xff
80103ba0:	68 a1 00 00 00       	push   $0xa1
80103ba5:	e8 ba ff ff ff       	call   80103b64 <outb>
80103baa:	83 c4 08             	add    $0x8,%esp
}
80103bad:	90                   	nop
80103bae:	c9                   	leave  
80103baf:	c3                   	ret    

80103bb0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103bb0:	f3 0f 1e fb          	endbr32 
80103bb4:	55                   	push   %ebp
80103bb5:	89 e5                	mov    %esp,%ebp
80103bb7:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103bba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bc4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103bca:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bcd:	8b 10                	mov    (%eax),%edx
80103bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80103bd2:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103bd4:	e8 38 d4 ff ff       	call   80101011 <filealloc>
80103bd9:	8b 55 08             	mov    0x8(%ebp),%edx
80103bdc:	89 02                	mov    %eax,(%edx)
80103bde:	8b 45 08             	mov    0x8(%ebp),%eax
80103be1:	8b 00                	mov    (%eax),%eax
80103be3:	85 c0                	test   %eax,%eax
80103be5:	0f 84 c8 00 00 00    	je     80103cb3 <pipealloc+0x103>
80103beb:	e8 21 d4 ff ff       	call   80101011 <filealloc>
80103bf0:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bf3:	89 02                	mov    %eax,(%edx)
80103bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bf8:	8b 00                	mov    (%eax),%eax
80103bfa:	85 c0                	test   %eax,%eax
80103bfc:	0f 84 b1 00 00 00    	je     80103cb3 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c02:	e8 71 f1 ff ff       	call   80102d78 <kalloc>
80103c07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c0e:	0f 84 a2 00 00 00    	je     80103cb6 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80103c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c17:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103c1e:	00 00 00 
  p->writeopen = 1;
80103c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c24:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103c2b:	00 00 00 
  p->nwrite = 0;
80103c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c31:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103c38:	00 00 00 
  p->nread = 0;
80103c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3e:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103c45:	00 00 00 
  initlock(&p->lock, "pipe");
80103c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4b:	83 ec 08             	sub    $0x8,%esp
80103c4e:	68 4d b0 10 80       	push   $0x8010b04d
80103c53:	50                   	push   %eax
80103c54:	e8 51 15 00 00       	call   801051aa <initlock>
80103c59:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80103c5f:	8b 00                	mov    (%eax),%eax
80103c61:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103c67:	8b 45 08             	mov    0x8(%ebp),%eax
80103c6a:	8b 00                	mov    (%eax),%eax
80103c6c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103c70:	8b 45 08             	mov    0x8(%ebp),%eax
80103c73:	8b 00                	mov    (%eax),%eax
80103c75:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103c79:	8b 45 08             	mov    0x8(%ebp),%eax
80103c7c:	8b 00                	mov    (%eax),%eax
80103c7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c81:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103c84:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c87:	8b 00                	mov    (%eax),%eax
80103c89:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103c8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c92:	8b 00                	mov    (%eax),%eax
80103c94:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103c98:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c9b:	8b 00                	mov    (%eax),%eax
80103c9d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ca4:	8b 00                	mov    (%eax),%eax
80103ca6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ca9:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103cac:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb1:	eb 51                	jmp    80103d04 <pipealloc+0x154>
    goto bad;
80103cb3:	90                   	nop
80103cb4:	eb 01                	jmp    80103cb7 <pipealloc+0x107>
    goto bad;
80103cb6:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103cb7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cbb:	74 0e                	je     80103ccb <pipealloc+0x11b>
    kfree((char*)p);
80103cbd:	83 ec 0c             	sub    $0xc,%esp
80103cc0:	ff 75 f4             	pushl  -0xc(%ebp)
80103cc3:	e8 12 f0 ff ff       	call   80102cda <kfree>
80103cc8:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80103cce:	8b 00                	mov    (%eax),%eax
80103cd0:	85 c0                	test   %eax,%eax
80103cd2:	74 11                	je     80103ce5 <pipealloc+0x135>
    fileclose(*f0);
80103cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd7:	8b 00                	mov    (%eax),%eax
80103cd9:	83 ec 0c             	sub    $0xc,%esp
80103cdc:	50                   	push   %eax
80103cdd:	e8 f5 d3 ff ff       	call   801010d7 <fileclose>
80103ce2:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce8:	8b 00                	mov    (%eax),%eax
80103cea:	85 c0                	test   %eax,%eax
80103cec:	74 11                	je     80103cff <pipealloc+0x14f>
    fileclose(*f1);
80103cee:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf1:	8b 00                	mov    (%eax),%eax
80103cf3:	83 ec 0c             	sub    $0xc,%esp
80103cf6:	50                   	push   %eax
80103cf7:	e8 db d3 ff ff       	call   801010d7 <fileclose>
80103cfc:	83 c4 10             	add    $0x10,%esp
  return -1;
80103cff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d04:	c9                   	leave  
80103d05:	c3                   	ret    

80103d06 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d06:	f3 0f 1e fb          	endbr32 
80103d0a:	55                   	push   %ebp
80103d0b:	89 e5                	mov    %esp,%ebp
80103d0d:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103d10:	8b 45 08             	mov    0x8(%ebp),%eax
80103d13:	83 ec 0c             	sub    $0xc,%esp
80103d16:	50                   	push   %eax
80103d17:	e8 b4 14 00 00       	call   801051d0 <acquire>
80103d1c:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103d1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d23:	74 23                	je     80103d48 <pipeclose+0x42>
    p->writeopen = 0;
80103d25:	8b 45 08             	mov    0x8(%ebp),%eax
80103d28:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d2f:	00 00 00 
    wakeup(&p->nread);
80103d32:	8b 45 08             	mov    0x8(%ebp),%eax
80103d35:	05 34 02 00 00       	add    $0x234,%eax
80103d3a:	83 ec 0c             	sub    $0xc,%esp
80103d3d:	50                   	push   %eax
80103d3e:	e8 d5 0f 00 00       	call   80104d18 <wakeup>
80103d43:	83 c4 10             	add    $0x10,%esp
80103d46:	eb 21                	jmp    80103d69 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103d48:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4b:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103d52:	00 00 00 
    wakeup(&p->nwrite);
80103d55:	8b 45 08             	mov    0x8(%ebp),%eax
80103d58:	05 38 02 00 00       	add    $0x238,%eax
80103d5d:	83 ec 0c             	sub    $0xc,%esp
80103d60:	50                   	push   %eax
80103d61:	e8 b2 0f 00 00       	call   80104d18 <wakeup>
80103d66:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103d69:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6c:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103d72:	85 c0                	test   %eax,%eax
80103d74:	75 2c                	jne    80103da2 <pipeclose+0x9c>
80103d76:	8b 45 08             	mov    0x8(%ebp),%eax
80103d79:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103d7f:	85 c0                	test   %eax,%eax
80103d81:	75 1f                	jne    80103da2 <pipeclose+0x9c>
    release(&p->lock);
80103d83:	8b 45 08             	mov    0x8(%ebp),%eax
80103d86:	83 ec 0c             	sub    $0xc,%esp
80103d89:	50                   	push   %eax
80103d8a:	e8 b3 14 00 00       	call   80105242 <release>
80103d8f:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103d92:	83 ec 0c             	sub    $0xc,%esp
80103d95:	ff 75 08             	pushl  0x8(%ebp)
80103d98:	e8 3d ef ff ff       	call   80102cda <kfree>
80103d9d:	83 c4 10             	add    $0x10,%esp
80103da0:	eb 10                	jmp    80103db2 <pipeclose+0xac>
  } else
    release(&p->lock);
80103da2:	8b 45 08             	mov    0x8(%ebp),%eax
80103da5:	83 ec 0c             	sub    $0xc,%esp
80103da8:	50                   	push   %eax
80103da9:	e8 94 14 00 00       	call   80105242 <release>
80103dae:	83 c4 10             	add    $0x10,%esp
}
80103db1:	90                   	nop
80103db2:	90                   	nop
80103db3:	c9                   	leave  
80103db4:	c3                   	ret    

80103db5 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103db5:	f3 0f 1e fb          	endbr32 
80103db9:	55                   	push   %ebp
80103dba:	89 e5                	mov    %esp,%ebp
80103dbc:	53                   	push   %ebx
80103dbd:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc3:	83 ec 0c             	sub    $0xc,%esp
80103dc6:	50                   	push   %eax
80103dc7:	e8 04 14 00 00       	call   801051d0 <acquire>
80103dcc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103dcf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dd6:	e9 ad 00 00 00       	jmp    80103e88 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dde:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103de4:	85 c0                	test   %eax,%eax
80103de6:	74 0c                	je     80103df4 <pipewrite+0x3f>
80103de8:	e8 a2 02 00 00       	call   8010408f <myproc>
80103ded:	8b 40 24             	mov    0x24(%eax),%eax
80103df0:	85 c0                	test   %eax,%eax
80103df2:	74 19                	je     80103e0d <pipewrite+0x58>
        release(&p->lock);
80103df4:	8b 45 08             	mov    0x8(%ebp),%eax
80103df7:	83 ec 0c             	sub    $0xc,%esp
80103dfa:	50                   	push   %eax
80103dfb:	e8 42 14 00 00       	call   80105242 <release>
80103e00:	83 c4 10             	add    $0x10,%esp
        return -1;
80103e03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e08:	e9 a9 00 00 00       	jmp    80103eb6 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e10:	05 34 02 00 00       	add    $0x234,%eax
80103e15:	83 ec 0c             	sub    $0xc,%esp
80103e18:	50                   	push   %eax
80103e19:	e8 fa 0e 00 00       	call   80104d18 <wakeup>
80103e1e:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e21:	8b 45 08             	mov    0x8(%ebp),%eax
80103e24:	8b 55 08             	mov    0x8(%ebp),%edx
80103e27:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e2d:	83 ec 08             	sub    $0x8,%esp
80103e30:	50                   	push   %eax
80103e31:	52                   	push   %edx
80103e32:	e8 ef 0d 00 00       	call   80104c26 <sleep>
80103e37:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3d:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e43:	8b 45 08             	mov    0x8(%ebp),%eax
80103e46:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e4c:	05 00 02 00 00       	add    $0x200,%eax
80103e51:	39 c2                	cmp    %eax,%edx
80103e53:	74 86                	je     80103ddb <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103e55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e58:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e5b:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e61:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103e67:	8d 48 01             	lea    0x1(%eax),%ecx
80103e6a:	8b 55 08             	mov    0x8(%ebp),%edx
80103e6d:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103e73:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e78:	89 c1                	mov    %eax,%ecx
80103e7a:	0f b6 13             	movzbl (%ebx),%edx
80103e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e80:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103e84:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e8b:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e8e:	7c aa                	jl     80103e3a <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103e90:	8b 45 08             	mov    0x8(%ebp),%eax
80103e93:	05 34 02 00 00       	add    $0x234,%eax
80103e98:	83 ec 0c             	sub    $0xc,%esp
80103e9b:	50                   	push   %eax
80103e9c:	e8 77 0e 00 00       	call   80104d18 <wakeup>
80103ea1:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ea4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea7:	83 ec 0c             	sub    $0xc,%esp
80103eaa:	50                   	push   %eax
80103eab:	e8 92 13 00 00       	call   80105242 <release>
80103eb0:	83 c4 10             	add    $0x10,%esp
  return n;
80103eb3:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103eb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103eb9:	c9                   	leave  
80103eba:	c3                   	ret    

80103ebb <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103ebb:	f3 0f 1e fb          	endbr32 
80103ebf:	55                   	push   %ebp
80103ec0:	89 e5                	mov    %esp,%ebp
80103ec2:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec8:	83 ec 0c             	sub    $0xc,%esp
80103ecb:	50                   	push   %eax
80103ecc:	e8 ff 12 00 00       	call   801051d0 <acquire>
80103ed1:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103ed4:	eb 3e                	jmp    80103f14 <piperead+0x59>
    if(myproc()->killed){
80103ed6:	e8 b4 01 00 00       	call   8010408f <myproc>
80103edb:	8b 40 24             	mov    0x24(%eax),%eax
80103ede:	85 c0                	test   %eax,%eax
80103ee0:	74 19                	je     80103efb <piperead+0x40>
      release(&p->lock);
80103ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee5:	83 ec 0c             	sub    $0xc,%esp
80103ee8:	50                   	push   %eax
80103ee9:	e8 54 13 00 00       	call   80105242 <release>
80103eee:	83 c4 10             	add    $0x10,%esp
      return -1;
80103ef1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ef6:	e9 be 00 00 00       	jmp    80103fb9 <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103efb:	8b 45 08             	mov    0x8(%ebp),%eax
80103efe:	8b 55 08             	mov    0x8(%ebp),%edx
80103f01:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f07:	83 ec 08             	sub    $0x8,%esp
80103f0a:	50                   	push   %eax
80103f0b:	52                   	push   %edx
80103f0c:	e8 15 0d 00 00       	call   80104c26 <sleep>
80103f11:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f14:	8b 45 08             	mov    0x8(%ebp),%eax
80103f17:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f20:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f26:	39 c2                	cmp    %eax,%edx
80103f28:	75 0d                	jne    80103f37 <piperead+0x7c>
80103f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2d:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f33:	85 c0                	test   %eax,%eax
80103f35:	75 9f                	jne    80103ed6 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f3e:	eb 48                	jmp    80103f88 <piperead+0xcd>
    if(p->nread == p->nwrite)
80103f40:	8b 45 08             	mov    0x8(%ebp),%eax
80103f43:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f49:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f52:	39 c2                	cmp    %eax,%edx
80103f54:	74 3c                	je     80103f92 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f56:	8b 45 08             	mov    0x8(%ebp),%eax
80103f59:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f5f:	8d 48 01             	lea    0x1(%eax),%ecx
80103f62:	8b 55 08             	mov    0x8(%ebp),%edx
80103f65:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103f6b:	25 ff 01 00 00       	and    $0x1ff,%eax
80103f70:	89 c1                	mov    %eax,%ecx
80103f72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f75:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f78:	01 c2                	add    %eax,%edx
80103f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7d:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103f82:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f84:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f8b:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f8e:	7c b0                	jl     80103f40 <piperead+0x85>
80103f90:	eb 01                	jmp    80103f93 <piperead+0xd8>
      break;
80103f92:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103f93:	8b 45 08             	mov    0x8(%ebp),%eax
80103f96:	05 38 02 00 00       	add    $0x238,%eax
80103f9b:	83 ec 0c             	sub    $0xc,%esp
80103f9e:	50                   	push   %eax
80103f9f:	e8 74 0d 00 00       	call   80104d18 <wakeup>
80103fa4:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80103faa:	83 ec 0c             	sub    $0xc,%esp
80103fad:	50                   	push   %eax
80103fae:	e8 8f 12 00 00       	call   80105242 <release>
80103fb3:	83 c4 10             	add    $0x10,%esp
  return i;
80103fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103fb9:	c9                   	leave  
80103fba:	c3                   	ret    

80103fbb <readeflags>:
{
80103fbb:	55                   	push   %ebp
80103fbc:	89 e5                	mov    %esp,%ebp
80103fbe:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103fc1:	9c                   	pushf  
80103fc2:	58                   	pop    %eax
80103fc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103fc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103fc9:	c9                   	leave  
80103fca:	c3                   	ret    

80103fcb <sti>:
{
80103fcb:	55                   	push   %ebp
80103fcc:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103fce:	fb                   	sti    
}
80103fcf:	90                   	nop
80103fd0:	5d                   	pop    %ebp
80103fd1:	c3                   	ret    

80103fd2 <pinit>:
extern void trapret(void);
static void wakeup1(void *chan);

void
pinit(void)
{
80103fd2:	f3 0f 1e fb          	endbr32 
80103fd6:	55                   	push   %ebp
80103fd7:	89 e5                	mov    %esp,%ebp
80103fd9:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103fdc:	83 ec 08             	sub    $0x8,%esp
80103fdf:	68 54 b0 10 80       	push   $0x8010b054
80103fe4:	68 40 85 11 80       	push   $0x80118540
80103fe9:	e8 bc 11 00 00       	call   801051aa <initlock>
80103fee:	83 c4 10             	add    $0x10,%esp
}
80103ff1:	90                   	nop
80103ff2:	c9                   	leave  
80103ff3:	c3                   	ret    

80103ff4 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103ff4:	f3 0f 1e fb          	endbr32 
80103ff8:	55                   	push   %ebp
80103ff9:	89 e5                	mov    %esp,%ebp
80103ffb:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103ffe:	e8 10 00 00 00       	call   80104013 <mycpu>
80104003:	2d 00 b2 11 80       	sub    $0x8011b200,%eax
80104008:	c1 f8 04             	sar    $0x4,%eax
8010400b:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104011:	c9                   	leave  
80104012:	c3                   	ret    

80104013 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104013:	f3 0f 1e fb          	endbr32 
80104017:	55                   	push   %ebp
80104018:	89 e5                	mov    %esp,%ebp
8010401a:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
8010401d:	e8 99 ff ff ff       	call   80103fbb <readeflags>
80104022:	25 00 02 00 00       	and    $0x200,%eax
80104027:	85 c0                	test   %eax,%eax
80104029:	74 0d                	je     80104038 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
8010402b:	83 ec 0c             	sub    $0xc,%esp
8010402e:	68 5c b0 10 80       	push   $0x8010b05c
80104033:	e8 8d c5 ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
80104038:	e8 a8 f0 ff ff       	call   801030e5 <lapicid>
8010403d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104040:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104047:	eb 2d                	jmp    80104076 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
80104049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104052:	05 00 b2 11 80       	add    $0x8011b200,%eax
80104057:	0f b6 00             	movzbl (%eax),%eax
8010405a:	0f b6 c0             	movzbl %al,%eax
8010405d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104060:	75 10                	jne    80104072 <mycpu+0x5f>
      return &cpus[i];
80104062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104065:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010406b:	05 00 b2 11 80       	add    $0x8011b200,%eax
80104070:	eb 1b                	jmp    8010408d <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80104072:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104076:	a1 c0 b4 11 80       	mov    0x8011b4c0,%eax
8010407b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010407e:	7c c9                	jl     80104049 <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80104080:	83 ec 0c             	sub    $0xc,%esp
80104083:	68 82 b0 10 80       	push   $0x8010b082
80104088:	e8 38 c5 ff ff       	call   801005c5 <panic>
}
8010408d:	c9                   	leave  
8010408e:	c3                   	ret    

8010408f <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010408f:	f3 0f 1e fb          	endbr32 
80104093:	55                   	push   %ebp
80104094:	89 e5                	mov    %esp,%ebp
80104096:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104099:	e8 ae 12 00 00       	call   8010534c <pushcli>
  c = mycpu();
8010409e:	e8 70 ff ff ff       	call   80104013 <mycpu>
801040a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801040a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a9:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801040af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801040b2:	e8 e6 12 00 00       	call   8010539d <popcli>
  return p;
801040b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801040ba:	c9                   	leave  
801040bb:	c3                   	ret    

801040bc <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801040bc:	f3 0f 1e fb          	endbr32 
801040c0:	55                   	push   %ebp
801040c1:	89 e5                	mov    %esp,%ebp
801040c3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801040c6:	83 ec 0c             	sub    $0xc,%esp
801040c9:	68 40 85 11 80       	push   $0x80118540
801040ce:	e8 fd 10 00 00       	call   801051d0 <acquire>
801040d3:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040d6:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801040dd:	eb 11                	jmp    801040f0 <allocproc+0x34>
    if(p->state == UNUSED){
801040df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e2:	8b 40 0c             	mov    0xc(%eax),%eax
801040e5:	85 c0                	test   %eax,%eax
801040e7:	74 2a                	je     80104113 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040e9:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801040f0:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
801040f7:	72 e6                	jb     801040df <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
801040f9:	83 ec 0c             	sub    $0xc,%esp
801040fc:	68 40 85 11 80       	push   $0x80118540
80104101:	e8 3c 11 00 00       	call   80105242 <release>
80104106:	83 c4 10             	add    $0x10,%esp
  return 0;
80104109:	b8 00 00 00 00       	mov    $0x0,%eax
8010410e:	e9 c3 00 00 00       	jmp    801041d6 <allocproc+0x11a>
      goto found;
80104113:	90                   	nop
80104114:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411b:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104122:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80104127:	8d 50 01             	lea    0x1(%eax),%edx
8010412a:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80104130:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104133:	89 42 10             	mov    %eax,0x10(%edx)

  p->scheduler = 0; //사용자 수준 스케줄러 필드를 0으로 설정, 초기화
80104136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104139:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104140:	00 00 00 

  release(&ptable.lock);
80104143:	83 ec 0c             	sub    $0xc,%esp
80104146:	68 40 85 11 80       	push   $0x80118540
8010414b:	e8 f2 10 00 00       	call   80105242 <release>
80104150:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104153:	e8 20 ec ff ff       	call   80102d78 <kalloc>
80104158:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010415b:	89 42 08             	mov    %eax,0x8(%edx)
8010415e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104161:	8b 40 08             	mov    0x8(%eax),%eax
80104164:	85 c0                	test   %eax,%eax
80104166:	75 11                	jne    80104179 <allocproc+0xbd>
    p->state = UNUSED;
80104168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104172:	b8 00 00 00 00       	mov    $0x0,%eax
80104177:	eb 5d                	jmp    801041d6 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
80104179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417c:	8b 40 08             	mov    0x8(%eax),%eax
8010417f:	05 00 10 00 00       	add    $0x1000,%eax
80104184:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104187:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010418b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104191:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104194:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104198:	ba 7a 69 10 80       	mov    $0x8010697a,%edx
8010419d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041a0:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801041a2:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801041a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041ac:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801041af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b2:	8b 40 1c             	mov    0x1c(%eax),%eax
801041b5:	83 ec 04             	sub    $0x4,%esp
801041b8:	6a 14                	push   $0x14
801041ba:	6a 00                	push   $0x0
801041bc:	50                   	push   %eax
801041bd:	e8 9d 12 00 00       	call   8010545f <memset>
801041c2:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801041c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c8:	8b 40 1c             	mov    0x1c(%eax),%eax
801041cb:	ba dc 4b 10 80       	mov    $0x80104bdc,%edx
801041d0:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801041d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801041d6:	c9                   	leave  
801041d7:	c3                   	ret    

801041d8 <userinit>:
int printpt(int pid);
//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801041d8:	f3 0f 1e fb          	endbr32 
801041dc:	55                   	push   %ebp
801041dd:	89 e5                	mov    %esp,%ebp
801041df:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801041e2:	e8 d5 fe ff ff       	call   801040bc <allocproc>
801041e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801041ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ed:	a3 a0 00 11 80       	mov    %eax,0x801100a0
  if((p->pgdir = setupkvm()) == 0){
801041f2:	e8 9d 3d 00 00       	call   80107f94 <setupkvm>
801041f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fa:	89 42 04             	mov    %eax,0x4(%edx)
801041fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104200:	8b 40 04             	mov    0x4(%eax),%eax
80104203:	85 c0                	test   %eax,%eax
80104205:	75 0d                	jne    80104214 <userinit+0x3c>
    panic("userinit: out of memory?");
80104207:	83 ec 0c             	sub    $0xc,%esp
8010420a:	68 92 b0 10 80       	push   $0x8010b092
8010420f:	e8 b1 c3 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104214:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421c:	8b 40 04             	mov    0x4(%eax),%eax
8010421f:	83 ec 04             	sub    $0x4,%esp
80104222:	52                   	push   %edx
80104223:	68 ec f4 10 80       	push   $0x8010f4ec
80104228:	50                   	push   %eax
80104229:	e8 df 3f 00 00       	call   8010820d <inituvm>
8010422e:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104234:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010423a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423d:	8b 40 18             	mov    0x18(%eax),%eax
80104240:	83 ec 04             	sub    $0x4,%esp
80104243:	6a 4c                	push   $0x4c
80104245:	6a 00                	push   $0x0
80104247:	50                   	push   %eax
80104248:	e8 12 12 00 00       	call   8010545f <memset>
8010424d:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104253:	8b 40 18             	mov    0x18(%eax),%eax
80104256:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010425c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425f:	8b 40 18             	mov    0x18(%eax),%eax
80104262:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426b:	8b 50 18             	mov    0x18(%eax),%edx
8010426e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104271:	8b 40 18             	mov    0x18(%eax),%eax
80104274:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104278:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010427c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427f:	8b 50 18             	mov    0x18(%eax),%edx
80104282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104285:	8b 40 18             	mov    0x18(%eax),%eax
80104288:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010428c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104290:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104293:	8b 40 18             	mov    0x18(%eax),%eax
80104296:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010429d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a0:	8b 40 18             	mov    0x18(%eax),%eax
801042a3:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801042aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ad:	8b 40 18             	mov    0x18(%eax),%eax
801042b0:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801042b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ba:	83 c0 6c             	add    $0x6c,%eax
801042bd:	83 ec 04             	sub    $0x4,%esp
801042c0:	6a 10                	push   $0x10
801042c2:	68 ab b0 10 80       	push   $0x8010b0ab
801042c7:	50                   	push   %eax
801042c8:	e8 ad 13 00 00       	call   8010567a <safestrcpy>
801042cd:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801042d0:	83 ec 0c             	sub    $0xc,%esp
801042d3:	68 b4 b0 10 80       	push   $0x8010b0b4
801042d8:	e8 f8 e2 ff ff       	call   801025d5 <namei>
801042dd:	83 c4 10             	add    $0x10,%esp
801042e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042e3:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801042e6:	83 ec 0c             	sub    $0xc,%esp
801042e9:	68 40 85 11 80       	push   $0x80118540
801042ee:	e8 dd 0e 00 00       	call   801051d0 <acquire>
801042f3:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801042f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104300:	83 ec 0c             	sub    $0xc,%esp
80104303:	68 40 85 11 80       	push   $0x80118540
80104308:	e8 35 0f 00 00       	call   80105242 <release>
8010430d:	83 c4 10             	add    $0x10,%esp
}
80104310:	90                   	nop
80104311:	c9                   	leave  
80104312:	c3                   	ret    

80104313 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104313:	f3 0f 1e fb          	endbr32 
80104317:	55                   	push   %ebp
80104318:	89 e5                	mov    %esp,%ebp
8010431a:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010431d:	e8 6d fd ff ff       	call   8010408f <myproc>
80104322:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104325:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104328:	8b 00                	mov    (%eax),%eax
8010432a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010432d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104331:	7e 2e                	jle    80104361 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104333:	8b 55 08             	mov    0x8(%ebp),%edx
80104336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104339:	01 c2                	add    %eax,%edx
8010433b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010433e:	8b 40 04             	mov    0x4(%eax),%eax
80104341:	83 ec 04             	sub    $0x4,%esp
80104344:	52                   	push   %edx
80104345:	ff 75 f4             	pushl  -0xc(%ebp)
80104348:	50                   	push   %eax
80104349:	e8 04 40 00 00       	call   80108352 <allocuvm>
8010434e:	83 c4 10             	add    $0x10,%esp
80104351:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104354:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104358:	75 3b                	jne    80104395 <growproc+0x82>
      return -1;
8010435a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010435f:	eb 4f                	jmp    801043b0 <growproc+0x9d>
  } else if(n < 0){
80104361:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104365:	79 2e                	jns    80104395 <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104367:	8b 55 08             	mov    0x8(%ebp),%edx
8010436a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436d:	01 c2                	add    %eax,%edx
8010436f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104372:	8b 40 04             	mov    0x4(%eax),%eax
80104375:	83 ec 04             	sub    $0x4,%esp
80104378:	52                   	push   %edx
80104379:	ff 75 f4             	pushl  -0xc(%ebp)
8010437c:	50                   	push   %eax
8010437d:	e8 d9 40 00 00       	call   8010845b <deallocuvm>
80104382:	83 c4 10             	add    $0x10,%esp
80104385:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104388:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010438c:	75 07                	jne    80104395 <growproc+0x82>
      return -1;
8010438e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104393:	eb 1b                	jmp    801043b0 <growproc+0x9d>
  }
  curproc->sz = sz;
80104395:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104398:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010439b:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010439d:	83 ec 0c             	sub    $0xc,%esp
801043a0:	ff 75 f0             	pushl  -0x10(%ebp)
801043a3:	e8 c2 3c 00 00       	call   8010806a <switchuvm>
801043a8:	83 c4 10             	add    $0x10,%esp
  return 0;
801043ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043b0:	c9                   	leave  
801043b1:	c3                   	ret    

801043b2 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801043b2:	f3 0f 1e fb          	endbr32 
801043b6:	55                   	push   %ebp
801043b7:	89 e5                	mov    %esp,%ebp
801043b9:	57                   	push   %edi
801043ba:	56                   	push   %esi
801043bb:	53                   	push   %ebx
801043bc:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801043bf:	e8 cb fc ff ff       	call   8010408f <myproc>
801043c4:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801043c7:	e8 f0 fc ff ff       	call   801040bc <allocproc>
801043cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
801043cf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801043d3:	75 0a                	jne    801043df <fork+0x2d>
    return -1;
801043d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043da:	e9 48 01 00 00       	jmp    80104527 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801043df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043e2:	8b 10                	mov    (%eax),%edx
801043e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043e7:	8b 40 04             	mov    0x4(%eax),%eax
801043ea:	83 ec 08             	sub    $0x8,%esp
801043ed:	52                   	push   %edx
801043ee:	50                   	push   %eax
801043ef:	e8 11 42 00 00       	call   80108605 <copyuvm>
801043f4:	83 c4 10             	add    $0x10,%esp
801043f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
801043fa:	89 42 04             	mov    %eax,0x4(%edx)
801043fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104400:	8b 40 04             	mov    0x4(%eax),%eax
80104403:	85 c0                	test   %eax,%eax
80104405:	75 30                	jne    80104437 <fork+0x85>
    kfree(np->kstack);
80104407:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010440a:	8b 40 08             	mov    0x8(%eax),%eax
8010440d:	83 ec 0c             	sub    $0xc,%esp
80104410:	50                   	push   %eax
80104411:	e8 c4 e8 ff ff       	call   80102cda <kfree>
80104416:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104419:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010441c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104423:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104426:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010442d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104432:	e9 f0 00 00 00       	jmp    80104527 <fork+0x175>
  }
  np->sz = curproc->sz;
80104437:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010443a:	8b 10                	mov    (%eax),%edx
8010443c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010443f:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104441:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104444:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104447:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010444a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010444d:	8b 48 18             	mov    0x18(%eax),%ecx
80104450:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104453:	8b 40 18             	mov    0x18(%eax),%eax
80104456:	89 c2                	mov    %eax,%edx
80104458:	89 cb                	mov    %ecx,%ebx
8010445a:	b8 13 00 00 00       	mov    $0x13,%eax
8010445f:	89 d7                	mov    %edx,%edi
80104461:	89 de                	mov    %ebx,%esi
80104463:	89 c1                	mov    %eax,%ecx
80104465:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104467:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010446a:	8b 40 18             	mov    0x18(%eax),%eax
8010446d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104474:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010447b:	eb 3b                	jmp    801044b8 <fork+0x106>
    if(curproc->ofile[i])
8010447d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104480:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104483:	83 c2 08             	add    $0x8,%edx
80104486:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010448a:	85 c0                	test   %eax,%eax
8010448c:	74 26                	je     801044b4 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010448e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104491:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104494:	83 c2 08             	add    $0x8,%edx
80104497:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010449b:	83 ec 0c             	sub    $0xc,%esp
8010449e:	50                   	push   %eax
8010449f:	e8 de cb ff ff       	call   80101082 <filedup>
801044a4:	83 c4 10             	add    $0x10,%esp
801044a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044aa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801044ad:	83 c1 08             	add    $0x8,%ecx
801044b0:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801044b4:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801044b8:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801044bc:	7e bf                	jle    8010447d <fork+0xcb>
  np->cwd = idup(curproc->cwd);
801044be:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044c1:	8b 40 68             	mov    0x68(%eax),%eax
801044c4:	83 ec 0c             	sub    $0xc,%esp
801044c7:	50                   	push   %eax
801044c8:	e8 5f d5 ff ff       	call   80101a2c <idup>
801044cd:	83 c4 10             	add    $0x10,%esp
801044d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044d3:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801044d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044d9:	8d 50 6c             	lea    0x6c(%eax),%edx
801044dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044df:	83 c0 6c             	add    $0x6c,%eax
801044e2:	83 ec 04             	sub    $0x4,%esp
801044e5:	6a 10                	push   $0x10
801044e7:	52                   	push   %edx
801044e8:	50                   	push   %eax
801044e9:	e8 8c 11 00 00       	call   8010567a <safestrcpy>
801044ee:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801044f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044f4:	8b 40 10             	mov    0x10(%eax),%eax
801044f7:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801044fa:	83 ec 0c             	sub    $0xc,%esp
801044fd:	68 40 85 11 80       	push   $0x80118540
80104502:	e8 c9 0c 00 00       	call   801051d0 <acquire>
80104507:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010450a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010450d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104514:	83 ec 0c             	sub    $0xc,%esp
80104517:	68 40 85 11 80       	push   $0x80118540
8010451c:	e8 21 0d 00 00       	call   80105242 <release>
80104521:	83 c4 10             	add    $0x10,%esp

  return pid;
80104524:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104527:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010452a:	5b                   	pop    %ebx
8010452b:	5e                   	pop    %esi
8010452c:	5f                   	pop    %edi
8010452d:	5d                   	pop    %ebp
8010452e:	c3                   	ret    

8010452f <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010452f:	f3 0f 1e fb          	endbr32 
80104533:	55                   	push   %ebp
80104534:	89 e5                	mov    %esp,%ebp
80104536:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104539:	e8 51 fb ff ff       	call   8010408f <myproc>
8010453e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104541:	a1 a0 00 11 80       	mov    0x801100a0,%eax
80104546:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104549:	75 0d                	jne    80104558 <exit+0x29>
    panic("init exiting");
8010454b:	83 ec 0c             	sub    $0xc,%esp
8010454e:	68 b6 b0 10 80       	push   $0x8010b0b6
80104553:	e8 6d c0 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104558:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010455f:	eb 3f                	jmp    801045a0 <exit+0x71>
    if(curproc->ofile[fd]){
80104561:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104564:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104567:	83 c2 08             	add    $0x8,%edx
8010456a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010456e:	85 c0                	test   %eax,%eax
80104570:	74 2a                	je     8010459c <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104572:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104575:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104578:	83 c2 08             	add    $0x8,%edx
8010457b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010457f:	83 ec 0c             	sub    $0xc,%esp
80104582:	50                   	push   %eax
80104583:	e8 4f cb ff ff       	call   801010d7 <fileclose>
80104588:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
8010458b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010458e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104591:	83 c2 08             	add    $0x8,%edx
80104594:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010459b:	00 
  for(fd = 0; fd < NOFILE; fd++){
8010459c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801045a0:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801045a4:	7e bb                	jle    80104561 <exit+0x32>
    }
  }

  begin_op();
801045a6:	e8 ac f0 ff ff       	call   80103657 <begin_op>
  iput(curproc->cwd);
801045ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045ae:	8b 40 68             	mov    0x68(%eax),%eax
801045b1:	83 ec 0c             	sub    $0xc,%esp
801045b4:	50                   	push   %eax
801045b5:	e8 19 d6 ff ff       	call   80101bd3 <iput>
801045ba:	83 c4 10             	add    $0x10,%esp
  end_op();
801045bd:	e8 25 f1 ff ff       	call   801036e7 <end_op>
  curproc->cwd = 0;
801045c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045c5:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801045cc:	83 ec 0c             	sub    $0xc,%esp
801045cf:	68 40 85 11 80       	push   $0x80118540
801045d4:	e8 f7 0b 00 00       	call   801051d0 <acquire>
801045d9:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801045dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045df:	8b 40 14             	mov    0x14(%eax),%eax
801045e2:	83 ec 0c             	sub    $0xc,%esp
801045e5:	50                   	push   %eax
801045e6:	e8 e6 06 00 00       	call   80104cd1 <wakeup1>
801045eb:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045ee:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801045f5:	eb 3a                	jmp    80104631 <exit+0x102>
    if(p->parent == curproc){
801045f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fa:	8b 40 14             	mov    0x14(%eax),%eax
801045fd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104600:	75 28                	jne    8010462a <exit+0xfb>
      p->parent = initproc;
80104602:	8b 15 a0 00 11 80    	mov    0x801100a0,%edx
80104608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460b:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010460e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104611:	8b 40 0c             	mov    0xc(%eax),%eax
80104614:	83 f8 05             	cmp    $0x5,%eax
80104617:	75 11                	jne    8010462a <exit+0xfb>
        wakeup1(initproc);
80104619:	a1 a0 00 11 80       	mov    0x801100a0,%eax
8010461e:	83 ec 0c             	sub    $0xc,%esp
80104621:	50                   	push   %eax
80104622:	e8 aa 06 00 00       	call   80104cd1 <wakeup1>
80104627:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010462a:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104631:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
80104638:	72 bd                	jb     801045f7 <exit+0xc8>
    }
  }

  curproc->scheduler = 0; //명시적으로 scheduler 필드를 초기화
8010463a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010463d:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104644:	00 00 00 

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104647:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010464a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104651:	e8 8b 04 00 00       	call   80104ae1 <sched>
  panic("zombie exit");
80104656:	83 ec 0c             	sub    $0xc,%esp
80104659:	68 c3 b0 10 80       	push   $0x8010b0c3
8010465e:	e8 62 bf ff ff       	call   801005c5 <panic>

80104663 <exit2>:
}

void
exit2(int status)
{
80104663:	f3 0f 1e fb          	endbr32 
80104667:	55                   	push   %ebp
80104668:	89 e5                	mov    %esp,%ebp
8010466a:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010466d:	e8 1d fa ff ff       	call   8010408f <myproc>
80104672:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104675:	a1 a0 00 11 80       	mov    0x801100a0,%eax
8010467a:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010467d:	75 0d                	jne    8010468c <exit2+0x29>
    panic("init exiting");
8010467f:	83 ec 0c             	sub    $0xc,%esp
80104682:	68 b6 b0 10 80       	push   $0x8010b0b6
80104687:	e8 39 bf ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010468c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104693:	eb 3f                	jmp    801046d4 <exit2+0x71>
    if(curproc->ofile[fd]){
80104695:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104698:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010469b:	83 c2 08             	add    $0x8,%edx
8010469e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046a2:	85 c0                	test   %eax,%eax
801046a4:	74 2a                	je     801046d0 <exit2+0x6d>
      fileclose(curproc->ofile[fd]);
801046a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046ac:	83 c2 08             	add    $0x8,%edx
801046af:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046b3:	83 ec 0c             	sub    $0xc,%esp
801046b6:	50                   	push   %eax
801046b7:	e8 1b ca ff ff       	call   801010d7 <fileclose>
801046bc:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801046bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046c5:	83 c2 08             	add    $0x8,%edx
801046c8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801046cf:	00 
  for(fd = 0; fd < NOFILE; fd++){
801046d0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801046d4:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801046d8:	7e bb                	jle    80104695 <exit2+0x32>
    }
  }

  begin_op();
801046da:	e8 78 ef ff ff       	call   80103657 <begin_op>
  iput(curproc->cwd);
801046df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046e2:	8b 40 68             	mov    0x68(%eax),%eax
801046e5:	83 ec 0c             	sub    $0xc,%esp
801046e8:	50                   	push   %eax
801046e9:	e8 e5 d4 ff ff       	call   80101bd3 <iput>
801046ee:	83 c4 10             	add    $0x10,%esp
  end_op();
801046f1:	e8 f1 ef ff ff       	call   801036e7 <end_op>
  curproc->cwd = 0;
801046f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046f9:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104700:	83 ec 0c             	sub    $0xc,%esp
80104703:	68 40 85 11 80       	push   $0x80118540
80104708:	e8 c3 0a 00 00       	call   801051d0 <acquire>
8010470d:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104710:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104713:	8b 40 14             	mov    0x14(%eax),%eax
80104716:	83 ec 0c             	sub    $0xc,%esp
80104719:	50                   	push   %eax
8010471a:	e8 b2 05 00 00       	call   80104cd1 <wakeup1>
8010471f:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104722:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104729:	eb 3a                	jmp    80104765 <exit2+0x102>
    if(p->parent == curproc){
8010472b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472e:	8b 40 14             	mov    0x14(%eax),%eax
80104731:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104734:	75 28                	jne    8010475e <exit2+0xfb>
      p->parent = initproc;
80104736:	8b 15 a0 00 11 80    	mov    0x801100a0,%edx
8010473c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473f:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104745:	8b 40 0c             	mov    0xc(%eax),%eax
80104748:	83 f8 05             	cmp    $0x5,%eax
8010474b:	75 11                	jne    8010475e <exit2+0xfb>
        wakeup1(initproc);
8010474d:	a1 a0 00 11 80       	mov    0x801100a0,%eax
80104752:	83 ec 0c             	sub    $0xc,%esp
80104755:	50                   	push   %eax
80104756:	e8 76 05 00 00       	call   80104cd1 <wakeup1>
8010475b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010475e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104765:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
8010476c:	72 bd                	jb     8010472b <exit2+0xc8>
    }
  }

  // Set exit status and become a zombie.
  curproc->xstate = status; // Save the exit status
8010476e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104771:	8b 55 08             	mov    0x8(%ebp),%edx
80104774:	89 50 7c             	mov    %edx,0x7c(%eax)

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104777:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010477a:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104781:	e8 5b 03 00 00       	call   80104ae1 <sched>
  panic("zombie exit");
80104786:	83 ec 0c             	sub    $0xc,%esp
80104789:	68 c3 b0 10 80       	push   $0x8010b0c3
8010478e:	e8 32 be ff ff       	call   801005c5 <panic>

80104793 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104793:	f3 0f 1e fb          	endbr32 
80104797:	55                   	push   %ebp
80104798:	89 e5                	mov    %esp,%ebp
8010479a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
8010479d:	e8 ed f8 ff ff       	call   8010408f <myproc>
801047a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801047a5:	83 ec 0c             	sub    $0xc,%esp
801047a8:	68 40 85 11 80       	push   $0x80118540
801047ad:	e8 1e 0a 00 00       	call   801051d0 <acquire>
801047b2:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801047b5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047bc:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801047c3:	e9 a4 00 00 00       	jmp    8010486c <wait+0xd9>
      if(p->parent != curproc)
801047c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cb:	8b 40 14             	mov    0x14(%eax),%eax
801047ce:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801047d1:	0f 85 8d 00 00 00    	jne    80104864 <wait+0xd1>
        continue;
      havekids = 1;
801047d7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801047de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e1:	8b 40 0c             	mov    0xc(%eax),%eax
801047e4:	83 f8 05             	cmp    $0x5,%eax
801047e7:	75 7c                	jne    80104865 <wait+0xd2>
        // Found one.
        pid = p->pid;
801047e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ec:	8b 40 10             	mov    0x10(%eax),%eax
801047ef:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801047f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f5:	8b 40 08             	mov    0x8(%eax),%eax
801047f8:	83 ec 0c             	sub    $0xc,%esp
801047fb:	50                   	push   %eax
801047fc:	e8 d9 e4 ff ff       	call   80102cda <kfree>
80104801:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104807:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010480e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104811:	8b 40 04             	mov    0x4(%eax),%eax
80104814:	83 ec 0c             	sub    $0xc,%esp
80104817:	50                   	push   %eax
80104818:	e8 06 3d 00 00       	call   80108523 <freevm>
8010481d:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104823:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010482a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010482d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104837:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010483b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104848:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010484f:	83 ec 0c             	sub    $0xc,%esp
80104852:	68 40 85 11 80       	push   $0x80118540
80104857:	e8 e6 09 00 00       	call   80105242 <release>
8010485c:	83 c4 10             	add    $0x10,%esp
        return pid;
8010485f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104862:	eb 54                	jmp    801048b8 <wait+0x125>
        continue;
80104864:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104865:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010486c:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
80104873:	0f 82 4f ff ff ff    	jb     801047c8 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104879:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010487d:	74 0a                	je     80104889 <wait+0xf6>
8010487f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104882:	8b 40 24             	mov    0x24(%eax),%eax
80104885:	85 c0                	test   %eax,%eax
80104887:	74 17                	je     801048a0 <wait+0x10d>
      release(&ptable.lock);
80104889:	83 ec 0c             	sub    $0xc,%esp
8010488c:	68 40 85 11 80       	push   $0x80118540
80104891:	e8 ac 09 00 00       	call   80105242 <release>
80104896:	83 c4 10             	add    $0x10,%esp
      return -1;
80104899:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010489e:	eb 18                	jmp    801048b8 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801048a0:	83 ec 08             	sub    $0x8,%esp
801048a3:	68 40 85 11 80       	push   $0x80118540
801048a8:	ff 75 ec             	pushl  -0x14(%ebp)
801048ab:	e8 76 03 00 00       	call   80104c26 <sleep>
801048b0:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801048b3:	e9 fd fe ff ff       	jmp    801047b5 <wait+0x22>
  }
}
801048b8:	c9                   	leave  
801048b9:	c3                   	ret    

801048ba <wait2>:

int
wait2(int *status) {
801048ba:	f3 0f 1e fb          	endbr32 
801048be:	55                   	push   %ebp
801048bf:	89 e5                	mov    %esp,%ebp
801048c1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801048c4:	e8 c6 f7 ff ff       	call   8010408f <myproc>
801048c9:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
801048cc:	83 ec 0c             	sub    $0xc,%esp
801048cf:	68 40 85 11 80       	push   $0x80118540
801048d4:	e8 f7 08 00 00       	call   801051d0 <acquire>
801048d9:	83 c4 10             	add    $0x10,%esp
  for(;;) {
    // Scan through table looking for zombie children.
    havekids = 0;
801048dc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801048e3:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801048ea:	e9 e5 00 00 00       	jmp    801049d4 <wait2+0x11a>
      if(p->parent != curproc)
801048ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f2:	8b 40 14             	mov    0x14(%eax),%eax
801048f5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801048f8:	0f 85 ce 00 00 00    	jne    801049cc <wait2+0x112>
        continue;
      havekids = 1;
801048fe:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE) {
80104905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104908:	8b 40 0c             	mov    0xc(%eax),%eax
8010490b:	83 f8 05             	cmp    $0x5,%eax
8010490e:	0f 85 b9 00 00 00    	jne    801049cd <wait2+0x113>
        // Found one.
        pid = p->pid;
80104914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104917:	8b 40 10             	mov    0x10(%eax),%eax
8010491a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010491d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104920:	8b 40 08             	mov    0x8(%eax),%eax
80104923:	83 ec 0c             	sub    $0xc,%esp
80104926:	50                   	push   %eax
80104927:	e8 ae e3 ff ff       	call   80102cda <kfree>
8010492c:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010492f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104932:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493c:	8b 40 04             	mov    0x4(%eax),%eax
8010493f:	83 ec 0c             	sub    $0xc,%esp
80104942:	50                   	push   %eax
80104943:	e8 db 3b 00 00       	call   80108523 <freevm>
80104948:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010494b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104958:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010495f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104962:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104969:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        if(status != 0 && copyout(curproc->pgdir, (uint)status, &p->xstate, sizeof(p->xstate)) < 0) {
80104970:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104974:	74 37                	je     801049ad <wait2+0xf3>
80104976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104979:	8d 48 7c             	lea    0x7c(%eax),%ecx
8010497c:	8b 55 08             	mov    0x8(%ebp),%edx
8010497f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104982:	8b 40 04             	mov    0x4(%eax),%eax
80104985:	6a 04                	push   $0x4
80104987:	51                   	push   %ecx
80104988:	52                   	push   %edx
80104989:	50                   	push   %eax
8010498a:	e8 d8 3e 00 00       	call   80108867 <copyout>
8010498f:	83 c4 10             	add    $0x10,%esp
80104992:	85 c0                	test   %eax,%eax
80104994:	79 17                	jns    801049ad <wait2+0xf3>
          release(&ptable.lock);
80104996:	83 ec 0c             	sub    $0xc,%esp
80104999:	68 40 85 11 80       	push   $0x80118540
8010499e:	e8 9f 08 00 00       	call   80105242 <release>
801049a3:	83 c4 10             	add    $0x10,%esp
          return -1;
801049a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049ab:	eb 73                	jmp    80104a20 <wait2+0x166>
        }
        p->state = UNUSED;
801049ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801049b7:	83 ec 0c             	sub    $0xc,%esp
801049ba:	68 40 85 11 80       	push   $0x80118540
801049bf:	e8 7e 08 00 00       	call   80105242 <release>
801049c4:	83 c4 10             	add    $0x10,%esp
        return pid;
801049c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801049ca:	eb 54                	jmp    80104a20 <wait2+0x166>
        continue;
801049cc:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801049cd:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801049d4:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
801049db:	0f 82 0e ff ff ff    	jb     801048ef <wait2+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed) {
801049e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049e5:	74 0a                	je     801049f1 <wait2+0x137>
801049e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049ea:	8b 40 24             	mov    0x24(%eax),%eax
801049ed:	85 c0                	test   %eax,%eax
801049ef:	74 17                	je     80104a08 <wait2+0x14e>
      release(&ptable.lock);
801049f1:	83 ec 0c             	sub    $0xc,%esp
801049f4:	68 40 85 11 80       	push   $0x80118540
801049f9:	e8 44 08 00 00       	call   80105242 <release>
801049fe:	83 c4 10             	add    $0x10,%esp
      return -1;
80104a01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a06:	eb 18                	jmp    80104a20 <wait2+0x166>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  // DOC: wait-sleep
80104a08:	83 ec 08             	sub    $0x8,%esp
80104a0b:	68 40 85 11 80       	push   $0x80118540
80104a10:	ff 75 ec             	pushl  -0x14(%ebp)
80104a13:	e8 0e 02 00 00       	call   80104c26 <sleep>
80104a18:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104a1b:	e9 bc fe ff ff       	jmp    801048dc <wait2+0x22>
  }
}
80104a20:	c9                   	leave  
80104a21:	c3                   	ret    

80104a22 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a22:	f3 0f 1e fb          	endbr32 
80104a26:	55                   	push   %ebp
80104a27:	89 e5                	mov    %esp,%ebp
80104a29:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104a2c:	e8 e2 f5 ff ff       	call   80104013 <mycpu>
80104a31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a37:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a3e:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a41:	e8 85 f5 ff ff       	call   80103fcb <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a46:	83 ec 0c             	sub    $0xc,%esp
80104a49:	68 40 85 11 80       	push   $0x80118540
80104a4e:	e8 7d 07 00 00       	call   801051d0 <acquire>
80104a53:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a56:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104a5d:	eb 64                	jmp    80104ac3 <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a62:	8b 40 0c             	mov    0xc(%eax),%eax
80104a65:	83 f8 03             	cmp    $0x3,%eax
80104a68:	75 51                	jne    80104abb <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a70:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a76:	83 ec 0c             	sub    $0xc,%esp
80104a79:	ff 75 f4             	pushl  -0xc(%ebp)
80104a7c:	e8 e9 35 00 00       	call   8010806a <switchuvm>
80104a81:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a87:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a91:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a94:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a97:	83 c2 04             	add    $0x4,%edx
80104a9a:	83 ec 08             	sub    $0x8,%esp
80104a9d:	50                   	push   %eax
80104a9e:	52                   	push   %edx
80104a9f:	e8 4f 0c 00 00       	call   801056f3 <swtch>
80104aa4:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104aa7:	e8 a1 35 00 00       	call   8010804d <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aaf:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104ab6:	00 00 00 
80104ab9:	eb 01                	jmp    80104abc <scheduler+0x9a>
        continue;
80104abb:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104abc:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104ac3:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
80104aca:	72 93                	jb     80104a5f <scheduler+0x3d>
    }
    release(&ptable.lock);
80104acc:	83 ec 0c             	sub    $0xc,%esp
80104acf:	68 40 85 11 80       	push   $0x80118540
80104ad4:	e8 69 07 00 00       	call   80105242 <release>
80104ad9:	83 c4 10             	add    $0x10,%esp
    sti();
80104adc:	e9 60 ff ff ff       	jmp    80104a41 <scheduler+0x1f>

80104ae1 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104ae1:	f3 0f 1e fb          	endbr32 
80104ae5:	55                   	push   %ebp
80104ae6:	89 e5                	mov    %esp,%ebp
80104ae8:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104aeb:	e8 9f f5 ff ff       	call   8010408f <myproc>
80104af0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104af3:	83 ec 0c             	sub    $0xc,%esp
80104af6:	68 40 85 11 80       	push   $0x80118540
80104afb:	e8 17 08 00 00       	call   80105317 <holding>
80104b00:	83 c4 10             	add    $0x10,%esp
80104b03:	85 c0                	test   %eax,%eax
80104b05:	75 0d                	jne    80104b14 <sched+0x33>
    panic("sched ptable.lock");
80104b07:	83 ec 0c             	sub    $0xc,%esp
80104b0a:	68 cf b0 10 80       	push   $0x8010b0cf
80104b0f:	e8 b1 ba ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104b14:	e8 fa f4 ff ff       	call   80104013 <mycpu>
80104b19:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b1f:	83 f8 01             	cmp    $0x1,%eax
80104b22:	74 0d                	je     80104b31 <sched+0x50>
    panic("sched locks");
80104b24:	83 ec 0c             	sub    $0xc,%esp
80104b27:	68 e1 b0 10 80       	push   $0x8010b0e1
80104b2c:	e8 94 ba ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b34:	8b 40 0c             	mov    0xc(%eax),%eax
80104b37:	83 f8 04             	cmp    $0x4,%eax
80104b3a:	75 0d                	jne    80104b49 <sched+0x68>
    panic("sched running");
80104b3c:	83 ec 0c             	sub    $0xc,%esp
80104b3f:	68 ed b0 10 80       	push   $0x8010b0ed
80104b44:	e8 7c ba ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
80104b49:	e8 6d f4 ff ff       	call   80103fbb <readeflags>
80104b4e:	25 00 02 00 00       	and    $0x200,%eax
80104b53:	85 c0                	test   %eax,%eax
80104b55:	74 0d                	je     80104b64 <sched+0x83>
    panic("sched interruptible");
80104b57:	83 ec 0c             	sub    $0xc,%esp
80104b5a:	68 fb b0 10 80       	push   $0x8010b0fb
80104b5f:	e8 61 ba ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
80104b64:	e8 aa f4 ff ff       	call   80104013 <mycpu>
80104b69:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b72:	e8 9c f4 ff ff       	call   80104013 <mycpu>
80104b77:	8b 40 04             	mov    0x4(%eax),%eax
80104b7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b7d:	83 c2 1c             	add    $0x1c,%edx
80104b80:	83 ec 08             	sub    $0x8,%esp
80104b83:	50                   	push   %eax
80104b84:	52                   	push   %edx
80104b85:	e8 69 0b 00 00       	call   801056f3 <swtch>
80104b8a:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104b8d:	e8 81 f4 ff ff       	call   80104013 <mycpu>
80104b92:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104b95:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104b9b:	90                   	nop
80104b9c:	c9                   	leave  
80104b9d:	c3                   	ret    

80104b9e <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b9e:	f3 0f 1e fb          	endbr32 
80104ba2:	55                   	push   %ebp
80104ba3:	89 e5                	mov    %esp,%ebp
80104ba5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104ba8:	83 ec 0c             	sub    $0xc,%esp
80104bab:	68 40 85 11 80       	push   $0x80118540
80104bb0:	e8 1b 06 00 00       	call   801051d0 <acquire>
80104bb5:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104bb8:	e8 d2 f4 ff ff       	call   8010408f <myproc>
80104bbd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104bc4:	e8 18 ff ff ff       	call   80104ae1 <sched>
  release(&ptable.lock);
80104bc9:	83 ec 0c             	sub    $0xc,%esp
80104bcc:	68 40 85 11 80       	push   $0x80118540
80104bd1:	e8 6c 06 00 00       	call   80105242 <release>
80104bd6:	83 c4 10             	add    $0x10,%esp
}
80104bd9:	90                   	nop
80104bda:	c9                   	leave  
80104bdb:	c3                   	ret    

80104bdc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bdc:	f3 0f 1e fb          	endbr32 
80104be0:	55                   	push   %ebp
80104be1:	89 e5                	mov    %esp,%ebp
80104be3:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104be6:	83 ec 0c             	sub    $0xc,%esp
80104be9:	68 40 85 11 80       	push   $0x80118540
80104bee:	e8 4f 06 00 00       	call   80105242 <release>
80104bf3:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104bf6:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104bfb:	85 c0                	test   %eax,%eax
80104bfd:	74 24                	je     80104c23 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104bff:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104c06:	00 00 00 
    iinit(ROOTDEV);
80104c09:	83 ec 0c             	sub    $0xc,%esp
80104c0c:	6a 01                	push   $0x1
80104c0e:	e8 d1 ca ff ff       	call   801016e4 <iinit>
80104c13:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104c16:	83 ec 0c             	sub    $0xc,%esp
80104c19:	6a 01                	push   $0x1
80104c1b:	e8 04 e8 ff ff       	call   80103424 <initlog>
80104c20:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104c23:	90                   	nop
80104c24:	c9                   	leave  
80104c25:	c3                   	ret    

80104c26 <sleep>:

// Atomically release lock and sleep on chan.ld: trap.o: in function `trap':
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c26:	f3 0f 1e fb          	endbr32 
80104c2a:	55                   	push   %ebp
80104c2b:	89 e5                	mov    %esp,%ebp
80104c2d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104c30:	e8 5a f4 ff ff       	call   8010408f <myproc>
80104c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104c38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c3c:	75 0d                	jne    80104c4b <sleep+0x25>
    panic("sleep");
80104c3e:	83 ec 0c             	sub    $0xc,%esp
80104c41:	68 0f b1 10 80       	push   $0x8010b10f
80104c46:	e8 7a b9 ff ff       	call   801005c5 <panic>

  if(lk == 0)
80104c4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c4f:	75 0d                	jne    80104c5e <sleep+0x38>
    panic("sleep without lk");
80104c51:	83 ec 0c             	sub    $0xc,%esp
80104c54:	68 15 b1 10 80       	push   $0x8010b115
80104c59:	e8 67 b9 ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c5e:	81 7d 0c 40 85 11 80 	cmpl   $0x80118540,0xc(%ebp)
80104c65:	74 1e                	je     80104c85 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c67:	83 ec 0c             	sub    $0xc,%esp
80104c6a:	68 40 85 11 80       	push   $0x80118540
80104c6f:	e8 5c 05 00 00       	call   801051d0 <acquire>
80104c74:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104c77:	83 ec 0c             	sub    $0xc,%esp
80104c7a:	ff 75 0c             	pushl  0xc(%ebp)
80104c7d:	e8 c0 05 00 00       	call   80105242 <release>
80104c82:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c88:	8b 55 08             	mov    0x8(%ebp),%edx
80104c8b:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c91:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c98:	e8 44 fe ff ff       	call   80104ae1 <sched>

  // Tidy up.
  p->chan = 0;
80104c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca0:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ca7:	81 7d 0c 40 85 11 80 	cmpl   $0x80118540,0xc(%ebp)
80104cae:	74 1e                	je     80104cce <sleep+0xa8>
    release(&ptable.lock);
80104cb0:	83 ec 0c             	sub    $0xc,%esp
80104cb3:	68 40 85 11 80       	push   $0x80118540
80104cb8:	e8 85 05 00 00       	call   80105242 <release>
80104cbd:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104cc0:	83 ec 0c             	sub    $0xc,%esp
80104cc3:	ff 75 0c             	pushl  0xc(%ebp)
80104cc6:	e8 05 05 00 00       	call   801051d0 <acquire>
80104ccb:	83 c4 10             	add    $0x10,%esp
  }
}
80104cce:	90                   	nop
80104ccf:	c9                   	leave  
80104cd0:	c3                   	ret    

80104cd1 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104cd1:	f3 0f 1e fb          	endbr32 
80104cd5:	55                   	push   %ebp
80104cd6:	89 e5                	mov    %esp,%ebp
80104cd8:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cdb:	c7 45 fc 74 85 11 80 	movl   $0x80118574,-0x4(%ebp)
80104ce2:	eb 27                	jmp    80104d0b <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104ce4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ce7:	8b 40 0c             	mov    0xc(%eax),%eax
80104cea:	83 f8 02             	cmp    $0x2,%eax
80104ced:	75 15                	jne    80104d04 <wakeup1+0x33>
80104cef:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cf2:	8b 40 20             	mov    0x20(%eax),%eax
80104cf5:	39 45 08             	cmp    %eax,0x8(%ebp)
80104cf8:	75 0a                	jne    80104d04 <wakeup1+0x33>
      p->state = RUNNABLE;
80104cfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cfd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d04:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80104d0b:	81 7d fc 74 a9 11 80 	cmpl   $0x8011a974,-0x4(%ebp)
80104d12:	72 d0                	jb     80104ce4 <wakeup1+0x13>
}
80104d14:	90                   	nop
80104d15:	90                   	nop
80104d16:	c9                   	leave  
80104d17:	c3                   	ret    

80104d18 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104d18:	f3 0f 1e fb          	endbr32 
80104d1c:	55                   	push   %ebp
80104d1d:	89 e5                	mov    %esp,%ebp
80104d1f:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104d22:	83 ec 0c             	sub    $0xc,%esp
80104d25:	68 40 85 11 80       	push   $0x80118540
80104d2a:	e8 a1 04 00 00       	call   801051d0 <acquire>
80104d2f:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104d32:	83 ec 0c             	sub    $0xc,%esp
80104d35:	ff 75 08             	pushl  0x8(%ebp)
80104d38:	e8 94 ff ff ff       	call   80104cd1 <wakeup1>
80104d3d:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104d40:	83 ec 0c             	sub    $0xc,%esp
80104d43:	68 40 85 11 80       	push   $0x80118540
80104d48:	e8 f5 04 00 00       	call   80105242 <release>
80104d4d:	83 c4 10             	add    $0x10,%esp
}
80104d50:	90                   	nop
80104d51:	c9                   	leave  
80104d52:	c3                   	ret    

80104d53 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d53:	f3 0f 1e fb          	endbr32 
80104d57:	55                   	push   %ebp
80104d58:	89 e5                	mov    %esp,%ebp
80104d5a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d5d:	83 ec 0c             	sub    $0xc,%esp
80104d60:	68 40 85 11 80       	push   $0x80118540
80104d65:	e8 66 04 00 00       	call   801051d0 <acquire>
80104d6a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d6d:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104d74:	eb 48                	jmp    80104dbe <kill+0x6b>
    if(p->pid == pid){
80104d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d79:	8b 40 10             	mov    0x10(%eax),%eax
80104d7c:	39 45 08             	cmp    %eax,0x8(%ebp)
80104d7f:	75 36                	jne    80104db7 <kill+0x64>
      p->killed = 1;
80104d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d84:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d91:	83 f8 02             	cmp    $0x2,%eax
80104d94:	75 0a                	jne    80104da0 <kill+0x4d>
        p->state = RUNNABLE;
80104d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d99:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104da0:	83 ec 0c             	sub    $0xc,%esp
80104da3:	68 40 85 11 80       	push   $0x80118540
80104da8:	e8 95 04 00 00       	call   80105242 <release>
80104dad:	83 c4 10             	add    $0x10,%esp
      return 0;
80104db0:	b8 00 00 00 00       	mov    $0x0,%eax
80104db5:	eb 25                	jmp    80104ddc <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104db7:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104dbe:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
80104dc5:	72 af                	jb     80104d76 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104dc7:	83 ec 0c             	sub    $0xc,%esp
80104dca:	68 40 85 11 80       	push   $0x80118540
80104dcf:	e8 6e 04 00 00       	call   80105242 <release>
80104dd4:	83 c4 10             	add    $0x10,%esp
  return -1;
80104dd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ddc:	c9                   	leave  
80104ddd:	c3                   	ret    

80104dde <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104dde:	f3 0f 1e fb          	endbr32 
80104de2:	55                   	push   %ebp
80104de3:	89 e5                	mov    %esp,%ebp
80104de5:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104de8:	c7 45 f0 74 85 11 80 	movl   $0x80118574,-0x10(%ebp)
80104def:	e9 da 00 00 00       	jmp    80104ece <procdump+0xf0>
    if(p->state == UNUSED)
80104df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104df7:	8b 40 0c             	mov    0xc(%eax),%eax
80104dfa:	85 c0                	test   %eax,%eax
80104dfc:	0f 84 c4 00 00 00    	je     80104ec6 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e05:	8b 40 0c             	mov    0xc(%eax),%eax
80104e08:	83 f8 05             	cmp    $0x5,%eax
80104e0b:	77 23                	ja     80104e30 <procdump+0x52>
80104e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e10:	8b 40 0c             	mov    0xc(%eax),%eax
80104e13:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104e1a:	85 c0                	test   %eax,%eax
80104e1c:	74 12                	je     80104e30 <procdump+0x52>
      state = states[p->state];
80104e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e21:	8b 40 0c             	mov    0xc(%eax),%eax
80104e24:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104e2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e2e:	eb 07                	jmp    80104e37 <procdump+0x59>
    else
      state = "???";
80104e30:	c7 45 ec 26 b1 10 80 	movl   $0x8010b126,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e3a:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e40:	8b 40 10             	mov    0x10(%eax),%eax
80104e43:	52                   	push   %edx
80104e44:	ff 75 ec             	pushl  -0x14(%ebp)
80104e47:	50                   	push   %eax
80104e48:	68 2a b1 10 80       	push   $0x8010b12a
80104e4d:	e8 ba b5 ff ff       	call   8010040c <cprintf>
80104e52:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e58:	8b 40 0c             	mov    0xc(%eax),%eax
80104e5b:	83 f8 02             	cmp    $0x2,%eax
80104e5e:	75 54                	jne    80104eb4 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e63:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e66:	8b 40 0c             	mov    0xc(%eax),%eax
80104e69:	83 c0 08             	add    $0x8,%eax
80104e6c:	89 c2                	mov    %eax,%edx
80104e6e:	83 ec 08             	sub    $0x8,%esp
80104e71:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104e74:	50                   	push   %eax
80104e75:	52                   	push   %edx
80104e76:	e8 1d 04 00 00       	call   80105298 <getcallerpcs>
80104e7b:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e85:	eb 1c                	jmp    80104ea3 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e8e:	83 ec 08             	sub    $0x8,%esp
80104e91:	50                   	push   %eax
80104e92:	68 33 b1 10 80       	push   $0x8010b133
80104e97:	e8 70 b5 ff ff       	call   8010040c <cprintf>
80104e9c:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e9f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ea3:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104ea7:	7f 0b                	jg     80104eb4 <procdump+0xd6>
80104ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eac:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104eb0:	85 c0                	test   %eax,%eax
80104eb2:	75 d3                	jne    80104e87 <procdump+0xa9>
    }
    cprintf("\n");
80104eb4:	83 ec 0c             	sub    $0xc,%esp
80104eb7:	68 37 b1 10 80       	push   $0x8010b137
80104ebc:	e8 4b b5 ff ff       	call   8010040c <cprintf>
80104ec1:	83 c4 10             	add    $0x10,%esp
80104ec4:	eb 01                	jmp    80104ec7 <procdump+0xe9>
      continue;
80104ec6:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ec7:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
80104ece:	81 7d f0 74 a9 11 80 	cmpl   $0x8011a974,-0x10(%ebp)
80104ed5:	0f 82 19 ff ff ff    	jb     80104df4 <procdump+0x16>
  }
}
80104edb:	90                   	nop
80104edc:	90                   	nop
80104edd:	c9                   	leave  
80104ede:	c3                   	ret    

80104edf <printpt>:


pte_t* walkpgdir(pde_t* pgdir, const void* va, int alloc);
int
printpt(int pid)
{
80104edf:	f3 0f 1e fb          	endbr32 
80104ee3:	55                   	push   %ebp
80104ee4:	89 e5                	mov    %esp,%ebp
80104ee6:	83 ec 28             	sub    $0x28,%esp
    struct proc* p = 0;
80104ee9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    pde_t* pgdir;
    pte_t* pte;
    uint va;
    int found = 0;
80104ef0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    // 프로세스 테이블에서 해당 pid의 프로세스를 찾기
    acquire(&ptable.lock);
80104ef7:	83 ec 0c             	sub    $0xc,%esp
80104efa:	68 40 85 11 80       	push   $0x80118540
80104eff:	e8 cc 02 00 00       	call   801051d0 <acquire>
80104f04:	83 c4 10             	add    $0x10,%esp
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104f07:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104f0e:	eb 1b                	jmp    80104f2b <printpt+0x4c>
        if (p->pid == pid) {
80104f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f13:	8b 40 10             	mov    0x10(%eax),%eax
80104f16:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f19:	75 09                	jne    80104f24 <printpt+0x45>
            found = 1;
80104f1b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
            break;
80104f22:	eb 10                	jmp    80104f34 <printpt+0x55>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104f24:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104f2b:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
80104f32:	72 dc                	jb     80104f10 <printpt+0x31>
        }
    }
    release(&ptable.lock);
80104f34:	83 ec 0c             	sub    $0xc,%esp
80104f37:	68 40 85 11 80       	push   $0x80118540
80104f3c:	e8 01 03 00 00       	call   80105242 <release>
80104f41:	83 c4 10             	add    $0x10,%esp

    // 해당 프로세스가 존재하지 않거나, UNUSED 상태일 경우 -1 반환
    if (!found || p->state == UNUSED) {
80104f44:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104f48:	74 0a                	je     80104f54 <printpt+0x75>
80104f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4d:	8b 40 0c             	mov    0xc(%eax),%eax
80104f50:	85 c0                	test   %eax,%eax
80104f52:	75 1d                	jne    80104f71 <printpt+0x92>
        cprintf("Process with pid %d not found or is in UNUSED state\n", pid);
80104f54:	83 ec 08             	sub    $0x8,%esp
80104f57:	ff 75 08             	pushl  0x8(%ebp)
80104f5a:	68 3c b1 10 80       	push   $0x8010b13c
80104f5f:	e8 a8 b4 ff ff       	call   8010040c <cprintf>
80104f64:	83 c4 10             	add    $0x10,%esp
        return -1;
80104f67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f6c:	e9 ca 00 00 00       	jmp    8010503b <printpt+0x15c>
    }

    pgdir = p->pgdir;
80104f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f74:	8b 40 04             	mov    0x4(%eax),%eax
80104f77:	89 45 e8             	mov    %eax,-0x18(%ebp)

    cprintf("START PAGE TABLE (pid %d)\n", pid);
80104f7a:	83 ec 08             	sub    $0x8,%esp
80104f7d:	ff 75 08             	pushl  0x8(%ebp)
80104f80:	68 71 b1 10 80       	push   $0x8010b171
80104f85:	e8 82 b4 ff ff       	call   8010040c <cprintf>
80104f8a:	83 c4 10             	add    $0x10,%esp
    for (va = 0; va < KERNBASE; va += PGSIZE) {
80104f8d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104f94:	e9 82 00 00 00       	jmp    8010501b <printpt+0x13c>
        pte = walkpgdir(pgdir, (void*)va, 0);
80104f99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f9c:	83 ec 04             	sub    $0x4,%esp
80104f9f:	6a 00                	push   $0x0
80104fa1:	50                   	push   %eax
80104fa2:	ff 75 e8             	pushl  -0x18(%ebp)
80104fa5:	e8 bc 2e 00 00       	call   80107e66 <walkpgdir>
80104faa:	83 c4 10             	add    $0x10,%esp
80104fad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (pte && (*pte & PTE_P)) {
80104fb0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104fb4:	74 5e                	je     80105014 <printpt+0x135>
80104fb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104fb9:	8b 00                	mov    (%eax),%eax
80104fbb:	83 e0 01             	and    $0x1,%eax
80104fbe:	85 c0                	test   %eax,%eax
80104fc0:	74 52                	je     80105014 <printpt+0x135>
            cprintf("VA: 0x%x P %c %c PA: 0x%x\n",
                va,
                (*pte & PTE_U) ? 'U' : 'K',
                (*pte & PTE_W) ? 'W' : '-',
                PTE_ADDR(*pte));
80104fc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104fc5:	8b 00                	mov    (%eax),%eax
            cprintf("VA: 0x%x P %c %c PA: 0x%x\n",
80104fc7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104fcc:	89 c2                	mov    %eax,%edx
                (*pte & PTE_W) ? 'W' : '-',
80104fce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104fd1:	8b 00                	mov    (%eax),%eax
80104fd3:	83 e0 02             	and    $0x2,%eax
            cprintf("VA: 0x%x P %c %c PA: 0x%x\n",
80104fd6:	85 c0                	test   %eax,%eax
80104fd8:	74 07                	je     80104fe1 <printpt+0x102>
80104fda:	b9 57 00 00 00       	mov    $0x57,%ecx
80104fdf:	eb 05                	jmp    80104fe6 <printpt+0x107>
80104fe1:	b9 2d 00 00 00       	mov    $0x2d,%ecx
                (*pte & PTE_U) ? 'U' : 'K',
80104fe6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104fe9:	8b 00                	mov    (%eax),%eax
80104feb:	83 e0 04             	and    $0x4,%eax
            cprintf("VA: 0x%x P %c %c PA: 0x%x\n",
80104fee:	85 c0                	test   %eax,%eax
80104ff0:	74 07                	je     80104ff9 <printpt+0x11a>
80104ff2:	b8 55 00 00 00       	mov    $0x55,%eax
80104ff7:	eb 05                	jmp    80104ffe <printpt+0x11f>
80104ff9:	b8 4b 00 00 00       	mov    $0x4b,%eax
80104ffe:	83 ec 0c             	sub    $0xc,%esp
80105001:	52                   	push   %edx
80105002:	51                   	push   %ecx
80105003:	50                   	push   %eax
80105004:	ff 75 f0             	pushl  -0x10(%ebp)
80105007:	68 8c b1 10 80       	push   $0x8010b18c
8010500c:	e8 fb b3 ff ff       	call   8010040c <cprintf>
80105011:	83 c4 20             	add    $0x20,%esp
    for (va = 0; va < KERNBASE; va += PGSIZE) {
80105014:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
8010501b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501e:	85 c0                	test   %eax,%eax
80105020:	0f 89 73 ff ff ff    	jns    80104f99 <printpt+0xba>
        }
    }
    cprintf("END PAGE TABLE\n");
80105026:	83 ec 0c             	sub    $0xc,%esp
80105029:	68 a7 b1 10 80       	push   $0x8010b1a7
8010502e:	e8 d9 b3 ff ff       	call   8010040c <cprintf>
80105033:	83 c4 10             	add    $0x10,%esp
    return 0;
80105036:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010503b:	c9                   	leave  
8010503c:	c3                   	ret    

8010503d <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010503d:	f3 0f 1e fb          	endbr32 
80105041:	55                   	push   %ebp
80105042:	89 e5                	mov    %esp,%ebp
80105044:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105047:	8b 45 08             	mov    0x8(%ebp),%eax
8010504a:	83 c0 04             	add    $0x4,%eax
8010504d:	83 ec 08             	sub    $0x8,%esp
80105050:	68 e1 b1 10 80       	push   $0x8010b1e1
80105055:	50                   	push   %eax
80105056:	e8 4f 01 00 00       	call   801051aa <initlock>
8010505b:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010505e:	8b 45 08             	mov    0x8(%ebp),%eax
80105061:	8b 55 0c             	mov    0xc(%ebp),%edx
80105064:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105067:	8b 45 08             	mov    0x8(%ebp),%eax
8010506a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105070:	8b 45 08             	mov    0x8(%ebp),%eax
80105073:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010507a:	90                   	nop
8010507b:	c9                   	leave  
8010507c:	c3                   	ret    

8010507d <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010507d:	f3 0f 1e fb          	endbr32 
80105081:	55                   	push   %ebp
80105082:	89 e5                	mov    %esp,%ebp
80105084:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105087:	8b 45 08             	mov    0x8(%ebp),%eax
8010508a:	83 c0 04             	add    $0x4,%eax
8010508d:	83 ec 0c             	sub    $0xc,%esp
80105090:	50                   	push   %eax
80105091:	e8 3a 01 00 00       	call   801051d0 <acquire>
80105096:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105099:	eb 15                	jmp    801050b0 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
8010509b:	8b 45 08             	mov    0x8(%ebp),%eax
8010509e:	83 c0 04             	add    $0x4,%eax
801050a1:	83 ec 08             	sub    $0x8,%esp
801050a4:	50                   	push   %eax
801050a5:	ff 75 08             	pushl  0x8(%ebp)
801050a8:	e8 79 fb ff ff       	call   80104c26 <sleep>
801050ad:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801050b0:	8b 45 08             	mov    0x8(%ebp),%eax
801050b3:	8b 00                	mov    (%eax),%eax
801050b5:	85 c0                	test   %eax,%eax
801050b7:	75 e2                	jne    8010509b <acquiresleep+0x1e>
  }
  lk->locked = 1;
801050b9:	8b 45 08             	mov    0x8(%ebp),%eax
801050bc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801050c2:	e8 c8 ef ff ff       	call   8010408f <myproc>
801050c7:	8b 50 10             	mov    0x10(%eax),%edx
801050ca:	8b 45 08             	mov    0x8(%ebp),%eax
801050cd:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801050d0:	8b 45 08             	mov    0x8(%ebp),%eax
801050d3:	83 c0 04             	add    $0x4,%eax
801050d6:	83 ec 0c             	sub    $0xc,%esp
801050d9:	50                   	push   %eax
801050da:	e8 63 01 00 00       	call   80105242 <release>
801050df:	83 c4 10             	add    $0x10,%esp
}
801050e2:	90                   	nop
801050e3:	c9                   	leave  
801050e4:	c3                   	ret    

801050e5 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801050e5:	f3 0f 1e fb          	endbr32 
801050e9:	55                   	push   %ebp
801050ea:	89 e5                	mov    %esp,%ebp
801050ec:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801050ef:	8b 45 08             	mov    0x8(%ebp),%eax
801050f2:	83 c0 04             	add    $0x4,%eax
801050f5:	83 ec 0c             	sub    $0xc,%esp
801050f8:	50                   	push   %eax
801050f9:	e8 d2 00 00 00       	call   801051d0 <acquire>
801050fe:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105101:	8b 45 08             	mov    0x8(%ebp),%eax
80105104:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010510a:	8b 45 08             	mov    0x8(%ebp),%eax
8010510d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105114:	83 ec 0c             	sub    $0xc,%esp
80105117:	ff 75 08             	pushl  0x8(%ebp)
8010511a:	e8 f9 fb ff ff       	call   80104d18 <wakeup>
8010511f:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105122:	8b 45 08             	mov    0x8(%ebp),%eax
80105125:	83 c0 04             	add    $0x4,%eax
80105128:	83 ec 0c             	sub    $0xc,%esp
8010512b:	50                   	push   %eax
8010512c:	e8 11 01 00 00       	call   80105242 <release>
80105131:	83 c4 10             	add    $0x10,%esp
}
80105134:	90                   	nop
80105135:	c9                   	leave  
80105136:	c3                   	ret    

80105137 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105137:	f3 0f 1e fb          	endbr32 
8010513b:	55                   	push   %ebp
8010513c:	89 e5                	mov    %esp,%ebp
8010513e:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80105141:	8b 45 08             	mov    0x8(%ebp),%eax
80105144:	83 c0 04             	add    $0x4,%eax
80105147:	83 ec 0c             	sub    $0xc,%esp
8010514a:	50                   	push   %eax
8010514b:	e8 80 00 00 00       	call   801051d0 <acquire>
80105150:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80105153:	8b 45 08             	mov    0x8(%ebp),%eax
80105156:	8b 00                	mov    (%eax),%eax
80105158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010515b:	8b 45 08             	mov    0x8(%ebp),%eax
8010515e:	83 c0 04             	add    $0x4,%eax
80105161:	83 ec 0c             	sub    $0xc,%esp
80105164:	50                   	push   %eax
80105165:	e8 d8 00 00 00       	call   80105242 <release>
8010516a:	83 c4 10             	add    $0x10,%esp
  return r;
8010516d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105170:	c9                   	leave  
80105171:	c3                   	ret    

80105172 <readeflags>:
{
80105172:	55                   	push   %ebp
80105173:	89 e5                	mov    %esp,%ebp
80105175:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105178:	9c                   	pushf  
80105179:	58                   	pop    %eax
8010517a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010517d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105180:	c9                   	leave  
80105181:	c3                   	ret    

80105182 <cli>:
{
80105182:	55                   	push   %ebp
80105183:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105185:	fa                   	cli    
}
80105186:	90                   	nop
80105187:	5d                   	pop    %ebp
80105188:	c3                   	ret    

80105189 <sti>:
{
80105189:	55                   	push   %ebp
8010518a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010518c:	fb                   	sti    
}
8010518d:	90                   	nop
8010518e:	5d                   	pop    %ebp
8010518f:	c3                   	ret    

80105190 <xchg>:
{
80105190:	55                   	push   %ebp
80105191:	89 e5                	mov    %esp,%ebp
80105193:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105196:	8b 55 08             	mov    0x8(%ebp),%edx
80105199:	8b 45 0c             	mov    0xc(%ebp),%eax
8010519c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010519f:	f0 87 02             	lock xchg %eax,(%edx)
801051a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801051a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051a8:	c9                   	leave  
801051a9:	c3                   	ret    

801051aa <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801051aa:	f3 0f 1e fb          	endbr32 
801051ae:	55                   	push   %ebp
801051af:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801051b1:	8b 45 08             	mov    0x8(%ebp),%eax
801051b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801051b7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801051ba:	8b 45 08             	mov    0x8(%ebp),%eax
801051bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801051c3:	8b 45 08             	mov    0x8(%ebp),%eax
801051c6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051cd:	90                   	nop
801051ce:	5d                   	pop    %ebp
801051cf:	c3                   	ret    

801051d0 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051d0:	f3 0f 1e fb          	endbr32 
801051d4:	55                   	push   %ebp
801051d5:	89 e5                	mov    %esp,%ebp
801051d7:	53                   	push   %ebx
801051d8:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051db:	e8 6c 01 00 00       	call   8010534c <pushcli>
  if(holding(lk)){
801051e0:	8b 45 08             	mov    0x8(%ebp),%eax
801051e3:	83 ec 0c             	sub    $0xc,%esp
801051e6:	50                   	push   %eax
801051e7:	e8 2b 01 00 00       	call   80105317 <holding>
801051ec:	83 c4 10             	add    $0x10,%esp
801051ef:	85 c0                	test   %eax,%eax
801051f1:	74 0d                	je     80105200 <acquire+0x30>
    panic("acquire");
801051f3:	83 ec 0c             	sub    $0xc,%esp
801051f6:	68 ec b1 10 80       	push   $0x8010b1ec
801051fb:	e8 c5 b3 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105200:	90                   	nop
80105201:	8b 45 08             	mov    0x8(%ebp),%eax
80105204:	83 ec 08             	sub    $0x8,%esp
80105207:	6a 01                	push   $0x1
80105209:	50                   	push   %eax
8010520a:	e8 81 ff ff ff       	call   80105190 <xchg>
8010520f:	83 c4 10             	add    $0x10,%esp
80105212:	85 c0                	test   %eax,%eax
80105214:	75 eb                	jne    80105201 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105216:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010521b:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010521e:	e8 f0 ed ff ff       	call   80104013 <mycpu>
80105223:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105226:	8b 45 08             	mov    0x8(%ebp),%eax
80105229:	83 c0 0c             	add    $0xc,%eax
8010522c:	83 ec 08             	sub    $0x8,%esp
8010522f:	50                   	push   %eax
80105230:	8d 45 08             	lea    0x8(%ebp),%eax
80105233:	50                   	push   %eax
80105234:	e8 5f 00 00 00       	call   80105298 <getcallerpcs>
80105239:	83 c4 10             	add    $0x10,%esp
}
8010523c:	90                   	nop
8010523d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105240:	c9                   	leave  
80105241:	c3                   	ret    

80105242 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105242:	f3 0f 1e fb          	endbr32 
80105246:	55                   	push   %ebp
80105247:	89 e5                	mov    %esp,%ebp
80105249:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010524c:	83 ec 0c             	sub    $0xc,%esp
8010524f:	ff 75 08             	pushl  0x8(%ebp)
80105252:	e8 c0 00 00 00       	call   80105317 <holding>
80105257:	83 c4 10             	add    $0x10,%esp
8010525a:	85 c0                	test   %eax,%eax
8010525c:	75 0d                	jne    8010526b <release+0x29>
    panic("release");
8010525e:	83 ec 0c             	sub    $0xc,%esp
80105261:	68 f4 b1 10 80       	push   $0x8010b1f4
80105266:	e8 5a b3 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
8010526b:	8b 45 08             	mov    0x8(%ebp),%eax
8010526e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105275:	8b 45 08             	mov    0x8(%ebp),%eax
80105278:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010527f:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105284:	8b 45 08             	mov    0x8(%ebp),%eax
80105287:	8b 55 08             	mov    0x8(%ebp),%edx
8010528a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105290:	e8 08 01 00 00       	call   8010539d <popcli>
}
80105295:	90                   	nop
80105296:	c9                   	leave  
80105297:	c3                   	ret    

80105298 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105298:	f3 0f 1e fb          	endbr32 
8010529c:	55                   	push   %ebp
8010529d:	89 e5                	mov    %esp,%ebp
8010529f:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801052a2:	8b 45 08             	mov    0x8(%ebp),%eax
801052a5:	83 e8 08             	sub    $0x8,%eax
801052a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801052ab:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801052b2:	eb 38                	jmp    801052ec <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801052b4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801052b8:	74 53                	je     8010530d <getcallerpcs+0x75>
801052ba:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801052c1:	76 4a                	jbe    8010530d <getcallerpcs+0x75>
801052c3:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801052c7:	74 44                	je     8010530d <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801052c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d6:	01 c2                	add    %eax,%edx
801052d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052db:	8b 40 04             	mov    0x4(%eax),%eax
801052de:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801052e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052e3:	8b 00                	mov    (%eax),%eax
801052e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801052e8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052ec:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052f0:	7e c2                	jle    801052b4 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801052f2:	eb 19                	jmp    8010530d <getcallerpcs+0x75>
    pcs[i] = 0;
801052f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052f7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105301:	01 d0                	add    %edx,%eax
80105303:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105309:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010530d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105311:	7e e1                	jle    801052f4 <getcallerpcs+0x5c>
}
80105313:	90                   	nop
80105314:	90                   	nop
80105315:	c9                   	leave  
80105316:	c3                   	ret    

80105317 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105317:	f3 0f 1e fb          	endbr32 
8010531b:	55                   	push   %ebp
8010531c:	89 e5                	mov    %esp,%ebp
8010531e:	53                   	push   %ebx
8010531f:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105322:	8b 45 08             	mov    0x8(%ebp),%eax
80105325:	8b 00                	mov    (%eax),%eax
80105327:	85 c0                	test   %eax,%eax
80105329:	74 16                	je     80105341 <holding+0x2a>
8010532b:	8b 45 08             	mov    0x8(%ebp),%eax
8010532e:	8b 58 08             	mov    0x8(%eax),%ebx
80105331:	e8 dd ec ff ff       	call   80104013 <mycpu>
80105336:	39 c3                	cmp    %eax,%ebx
80105338:	75 07                	jne    80105341 <holding+0x2a>
8010533a:	b8 01 00 00 00       	mov    $0x1,%eax
8010533f:	eb 05                	jmp    80105346 <holding+0x2f>
80105341:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105346:	83 c4 04             	add    $0x4,%esp
80105349:	5b                   	pop    %ebx
8010534a:	5d                   	pop    %ebp
8010534b:	c3                   	ret    

8010534c <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010534c:	f3 0f 1e fb          	endbr32 
80105350:	55                   	push   %ebp
80105351:	89 e5                	mov    %esp,%ebp
80105353:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105356:	e8 17 fe ff ff       	call   80105172 <readeflags>
8010535b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010535e:	e8 1f fe ff ff       	call   80105182 <cli>
  if(mycpu()->ncli == 0)
80105363:	e8 ab ec ff ff       	call   80104013 <mycpu>
80105368:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010536e:	85 c0                	test   %eax,%eax
80105370:	75 14                	jne    80105386 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105372:	e8 9c ec ff ff       	call   80104013 <mycpu>
80105377:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010537a:	81 e2 00 02 00 00    	and    $0x200,%edx
80105380:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105386:	e8 88 ec ff ff       	call   80104013 <mycpu>
8010538b:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105391:	83 c2 01             	add    $0x1,%edx
80105394:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010539a:	90                   	nop
8010539b:	c9                   	leave  
8010539c:	c3                   	ret    

8010539d <popcli>:

void
popcli(void)
{
8010539d:	f3 0f 1e fb          	endbr32 
801053a1:	55                   	push   %ebp
801053a2:	89 e5                	mov    %esp,%ebp
801053a4:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801053a7:	e8 c6 fd ff ff       	call   80105172 <readeflags>
801053ac:	25 00 02 00 00       	and    $0x200,%eax
801053b1:	85 c0                	test   %eax,%eax
801053b3:	74 0d                	je     801053c2 <popcli+0x25>
    panic("popcli - interruptible");
801053b5:	83 ec 0c             	sub    $0xc,%esp
801053b8:	68 fc b1 10 80       	push   $0x8010b1fc
801053bd:	e8 03 b2 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
801053c2:	e8 4c ec ff ff       	call   80104013 <mycpu>
801053c7:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801053cd:	83 ea 01             	sub    $0x1,%edx
801053d0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801053d6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801053dc:	85 c0                	test   %eax,%eax
801053de:	79 0d                	jns    801053ed <popcli+0x50>
    panic("popcli");
801053e0:	83 ec 0c             	sub    $0xc,%esp
801053e3:	68 13 b2 10 80       	push   $0x8010b213
801053e8:	e8 d8 b1 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801053ed:	e8 21 ec ff ff       	call   80104013 <mycpu>
801053f2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801053f8:	85 c0                	test   %eax,%eax
801053fa:	75 14                	jne    80105410 <popcli+0x73>
801053fc:	e8 12 ec ff ff       	call   80104013 <mycpu>
80105401:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105407:	85 c0                	test   %eax,%eax
80105409:	74 05                	je     80105410 <popcli+0x73>
    sti();
8010540b:	e8 79 fd ff ff       	call   80105189 <sti>
}
80105410:	90                   	nop
80105411:	c9                   	leave  
80105412:	c3                   	ret    

80105413 <stosb>:
{
80105413:	55                   	push   %ebp
80105414:	89 e5                	mov    %esp,%ebp
80105416:	57                   	push   %edi
80105417:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105418:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010541b:	8b 55 10             	mov    0x10(%ebp),%edx
8010541e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105421:	89 cb                	mov    %ecx,%ebx
80105423:	89 df                	mov    %ebx,%edi
80105425:	89 d1                	mov    %edx,%ecx
80105427:	fc                   	cld    
80105428:	f3 aa                	rep stos %al,%es:(%edi)
8010542a:	89 ca                	mov    %ecx,%edx
8010542c:	89 fb                	mov    %edi,%ebx
8010542e:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105431:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105434:	90                   	nop
80105435:	5b                   	pop    %ebx
80105436:	5f                   	pop    %edi
80105437:	5d                   	pop    %ebp
80105438:	c3                   	ret    

80105439 <stosl>:
{
80105439:	55                   	push   %ebp
8010543a:	89 e5                	mov    %esp,%ebp
8010543c:	57                   	push   %edi
8010543d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010543e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105441:	8b 55 10             	mov    0x10(%ebp),%edx
80105444:	8b 45 0c             	mov    0xc(%ebp),%eax
80105447:	89 cb                	mov    %ecx,%ebx
80105449:	89 df                	mov    %ebx,%edi
8010544b:	89 d1                	mov    %edx,%ecx
8010544d:	fc                   	cld    
8010544e:	f3 ab                	rep stos %eax,%es:(%edi)
80105450:	89 ca                	mov    %ecx,%edx
80105452:	89 fb                	mov    %edi,%ebx
80105454:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105457:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010545a:	90                   	nop
8010545b:	5b                   	pop    %ebx
8010545c:	5f                   	pop    %edi
8010545d:	5d                   	pop    %ebp
8010545e:	c3                   	ret    

8010545f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010545f:	f3 0f 1e fb          	endbr32 
80105463:	55                   	push   %ebp
80105464:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105466:	8b 45 08             	mov    0x8(%ebp),%eax
80105469:	83 e0 03             	and    $0x3,%eax
8010546c:	85 c0                	test   %eax,%eax
8010546e:	75 43                	jne    801054b3 <memset+0x54>
80105470:	8b 45 10             	mov    0x10(%ebp),%eax
80105473:	83 e0 03             	and    $0x3,%eax
80105476:	85 c0                	test   %eax,%eax
80105478:	75 39                	jne    801054b3 <memset+0x54>
    c &= 0xFF;
8010547a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105481:	8b 45 10             	mov    0x10(%ebp),%eax
80105484:	c1 e8 02             	shr    $0x2,%eax
80105487:	89 c1                	mov    %eax,%ecx
80105489:	8b 45 0c             	mov    0xc(%ebp),%eax
8010548c:	c1 e0 18             	shl    $0x18,%eax
8010548f:	89 c2                	mov    %eax,%edx
80105491:	8b 45 0c             	mov    0xc(%ebp),%eax
80105494:	c1 e0 10             	shl    $0x10,%eax
80105497:	09 c2                	or     %eax,%edx
80105499:	8b 45 0c             	mov    0xc(%ebp),%eax
8010549c:	c1 e0 08             	shl    $0x8,%eax
8010549f:	09 d0                	or     %edx,%eax
801054a1:	0b 45 0c             	or     0xc(%ebp),%eax
801054a4:	51                   	push   %ecx
801054a5:	50                   	push   %eax
801054a6:	ff 75 08             	pushl  0x8(%ebp)
801054a9:	e8 8b ff ff ff       	call   80105439 <stosl>
801054ae:	83 c4 0c             	add    $0xc,%esp
801054b1:	eb 12                	jmp    801054c5 <memset+0x66>
  } else
    stosb(dst, c, n);
801054b3:	8b 45 10             	mov    0x10(%ebp),%eax
801054b6:	50                   	push   %eax
801054b7:	ff 75 0c             	pushl  0xc(%ebp)
801054ba:	ff 75 08             	pushl  0x8(%ebp)
801054bd:	e8 51 ff ff ff       	call   80105413 <stosb>
801054c2:	83 c4 0c             	add    $0xc,%esp
  return dst;
801054c5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054c8:	c9                   	leave  
801054c9:	c3                   	ret    

801054ca <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801054ca:	f3 0f 1e fb          	endbr32 
801054ce:	55                   	push   %ebp
801054cf:	89 e5                	mov    %esp,%ebp
801054d1:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801054d4:	8b 45 08             	mov    0x8(%ebp),%eax
801054d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801054da:	8b 45 0c             	mov    0xc(%ebp),%eax
801054dd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801054e0:	eb 30                	jmp    80105512 <memcmp+0x48>
    if(*s1 != *s2)
801054e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054e5:	0f b6 10             	movzbl (%eax),%edx
801054e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054eb:	0f b6 00             	movzbl (%eax),%eax
801054ee:	38 c2                	cmp    %al,%dl
801054f0:	74 18                	je     8010550a <memcmp+0x40>
      return *s1 - *s2;
801054f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054f5:	0f b6 00             	movzbl (%eax),%eax
801054f8:	0f b6 d0             	movzbl %al,%edx
801054fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054fe:	0f b6 00             	movzbl (%eax),%eax
80105501:	0f b6 c0             	movzbl %al,%eax
80105504:	29 c2                	sub    %eax,%edx
80105506:	89 d0                	mov    %edx,%eax
80105508:	eb 1a                	jmp    80105524 <memcmp+0x5a>
    s1++, s2++;
8010550a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010550e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105512:	8b 45 10             	mov    0x10(%ebp),%eax
80105515:	8d 50 ff             	lea    -0x1(%eax),%edx
80105518:	89 55 10             	mov    %edx,0x10(%ebp)
8010551b:	85 c0                	test   %eax,%eax
8010551d:	75 c3                	jne    801054e2 <memcmp+0x18>
  }

  return 0;
8010551f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105524:	c9                   	leave  
80105525:	c3                   	ret    

80105526 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105526:	f3 0f 1e fb          	endbr32 
8010552a:	55                   	push   %ebp
8010552b:	89 e5                	mov    %esp,%ebp
8010552d:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105530:	8b 45 0c             	mov    0xc(%ebp),%eax
80105533:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105536:	8b 45 08             	mov    0x8(%ebp),%eax
80105539:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010553c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010553f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105542:	73 54                	jae    80105598 <memmove+0x72>
80105544:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105547:	8b 45 10             	mov    0x10(%ebp),%eax
8010554a:	01 d0                	add    %edx,%eax
8010554c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010554f:	73 47                	jae    80105598 <memmove+0x72>
    s += n;
80105551:	8b 45 10             	mov    0x10(%ebp),%eax
80105554:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105557:	8b 45 10             	mov    0x10(%ebp),%eax
8010555a:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010555d:	eb 13                	jmp    80105572 <memmove+0x4c>
      *--d = *--s;
8010555f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105563:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105567:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010556a:	0f b6 10             	movzbl (%eax),%edx
8010556d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105570:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105572:	8b 45 10             	mov    0x10(%ebp),%eax
80105575:	8d 50 ff             	lea    -0x1(%eax),%edx
80105578:	89 55 10             	mov    %edx,0x10(%ebp)
8010557b:	85 c0                	test   %eax,%eax
8010557d:	75 e0                	jne    8010555f <memmove+0x39>
  if(s < d && s + n > d){
8010557f:	eb 24                	jmp    801055a5 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105581:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105584:	8d 42 01             	lea    0x1(%edx),%eax
80105587:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010558a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010558d:	8d 48 01             	lea    0x1(%eax),%ecx
80105590:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105593:	0f b6 12             	movzbl (%edx),%edx
80105596:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105598:	8b 45 10             	mov    0x10(%ebp),%eax
8010559b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010559e:	89 55 10             	mov    %edx,0x10(%ebp)
801055a1:	85 c0                	test   %eax,%eax
801055a3:	75 dc                	jne    80105581 <memmove+0x5b>

  return dst;
801055a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055a8:	c9                   	leave  
801055a9:	c3                   	ret    

801055aa <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801055aa:	f3 0f 1e fb          	endbr32 
801055ae:	55                   	push   %ebp
801055af:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801055b1:	ff 75 10             	pushl  0x10(%ebp)
801055b4:	ff 75 0c             	pushl  0xc(%ebp)
801055b7:	ff 75 08             	pushl  0x8(%ebp)
801055ba:	e8 67 ff ff ff       	call   80105526 <memmove>
801055bf:	83 c4 0c             	add    $0xc,%esp
}
801055c2:	c9                   	leave  
801055c3:	c3                   	ret    

801055c4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801055c4:	f3 0f 1e fb          	endbr32 
801055c8:	55                   	push   %ebp
801055c9:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801055cb:	eb 0c                	jmp    801055d9 <strncmp+0x15>
    n--, p++, q++;
801055cd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055d1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801055d5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801055d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055dd:	74 1a                	je     801055f9 <strncmp+0x35>
801055df:	8b 45 08             	mov    0x8(%ebp),%eax
801055e2:	0f b6 00             	movzbl (%eax),%eax
801055e5:	84 c0                	test   %al,%al
801055e7:	74 10                	je     801055f9 <strncmp+0x35>
801055e9:	8b 45 08             	mov    0x8(%ebp),%eax
801055ec:	0f b6 10             	movzbl (%eax),%edx
801055ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f2:	0f b6 00             	movzbl (%eax),%eax
801055f5:	38 c2                	cmp    %al,%dl
801055f7:	74 d4                	je     801055cd <strncmp+0x9>
  if(n == 0)
801055f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055fd:	75 07                	jne    80105606 <strncmp+0x42>
    return 0;
801055ff:	b8 00 00 00 00       	mov    $0x0,%eax
80105604:	eb 16                	jmp    8010561c <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80105606:	8b 45 08             	mov    0x8(%ebp),%eax
80105609:	0f b6 00             	movzbl (%eax),%eax
8010560c:	0f b6 d0             	movzbl %al,%edx
8010560f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105612:	0f b6 00             	movzbl (%eax),%eax
80105615:	0f b6 c0             	movzbl %al,%eax
80105618:	29 c2                	sub    %eax,%edx
8010561a:	89 d0                	mov    %edx,%eax
}
8010561c:	5d                   	pop    %ebp
8010561d:	c3                   	ret    

8010561e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010561e:	f3 0f 1e fb          	endbr32 
80105622:	55                   	push   %ebp
80105623:	89 e5                	mov    %esp,%ebp
80105625:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105628:	8b 45 08             	mov    0x8(%ebp),%eax
8010562b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010562e:	90                   	nop
8010562f:	8b 45 10             	mov    0x10(%ebp),%eax
80105632:	8d 50 ff             	lea    -0x1(%eax),%edx
80105635:	89 55 10             	mov    %edx,0x10(%ebp)
80105638:	85 c0                	test   %eax,%eax
8010563a:	7e 2c                	jle    80105668 <strncpy+0x4a>
8010563c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010563f:	8d 42 01             	lea    0x1(%edx),%eax
80105642:	89 45 0c             	mov    %eax,0xc(%ebp)
80105645:	8b 45 08             	mov    0x8(%ebp),%eax
80105648:	8d 48 01             	lea    0x1(%eax),%ecx
8010564b:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010564e:	0f b6 12             	movzbl (%edx),%edx
80105651:	88 10                	mov    %dl,(%eax)
80105653:	0f b6 00             	movzbl (%eax),%eax
80105656:	84 c0                	test   %al,%al
80105658:	75 d5                	jne    8010562f <strncpy+0x11>
    ;
  while(n-- > 0)
8010565a:	eb 0c                	jmp    80105668 <strncpy+0x4a>
    *s++ = 0;
8010565c:	8b 45 08             	mov    0x8(%ebp),%eax
8010565f:	8d 50 01             	lea    0x1(%eax),%edx
80105662:	89 55 08             	mov    %edx,0x8(%ebp)
80105665:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105668:	8b 45 10             	mov    0x10(%ebp),%eax
8010566b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010566e:	89 55 10             	mov    %edx,0x10(%ebp)
80105671:	85 c0                	test   %eax,%eax
80105673:	7f e7                	jg     8010565c <strncpy+0x3e>
  return os;
80105675:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105678:	c9                   	leave  
80105679:	c3                   	ret    

8010567a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010567a:	f3 0f 1e fb          	endbr32 
8010567e:	55                   	push   %ebp
8010567f:	89 e5                	mov    %esp,%ebp
80105681:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105684:	8b 45 08             	mov    0x8(%ebp),%eax
80105687:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010568a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010568e:	7f 05                	jg     80105695 <safestrcpy+0x1b>
    return os;
80105690:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105693:	eb 31                	jmp    801056c6 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105695:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105699:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010569d:	7e 1e                	jle    801056bd <safestrcpy+0x43>
8010569f:	8b 55 0c             	mov    0xc(%ebp),%edx
801056a2:	8d 42 01             	lea    0x1(%edx),%eax
801056a5:	89 45 0c             	mov    %eax,0xc(%ebp)
801056a8:	8b 45 08             	mov    0x8(%ebp),%eax
801056ab:	8d 48 01             	lea    0x1(%eax),%ecx
801056ae:	89 4d 08             	mov    %ecx,0x8(%ebp)
801056b1:	0f b6 12             	movzbl (%edx),%edx
801056b4:	88 10                	mov    %dl,(%eax)
801056b6:	0f b6 00             	movzbl (%eax),%eax
801056b9:	84 c0                	test   %al,%al
801056bb:	75 d8                	jne    80105695 <safestrcpy+0x1b>
    ;
  *s = 0;
801056bd:	8b 45 08             	mov    0x8(%ebp),%eax
801056c0:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801056c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056c6:	c9                   	leave  
801056c7:	c3                   	ret    

801056c8 <strlen>:

int
strlen(const char *s)
{
801056c8:	f3 0f 1e fb          	endbr32 
801056cc:	55                   	push   %ebp
801056cd:	89 e5                	mov    %esp,%ebp
801056cf:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801056d2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801056d9:	eb 04                	jmp    801056df <strlen+0x17>
801056db:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056df:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056e2:	8b 45 08             	mov    0x8(%ebp),%eax
801056e5:	01 d0                	add    %edx,%eax
801056e7:	0f b6 00             	movzbl (%eax),%eax
801056ea:	84 c0                	test   %al,%al
801056ec:	75 ed                	jne    801056db <strlen+0x13>
    ;
  return n;
801056ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056f1:	c9                   	leave  
801056f2:	c3                   	ret    

801056f3 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801056f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801056f7:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801056fb:	55                   	push   %ebp
  pushl %ebx
801056fc:	53                   	push   %ebx
  pushl %esi
801056fd:	56                   	push   %esi
  pushl %edi
801056fe:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801056ff:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105701:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105703:	5f                   	pop    %edi
  popl %esi
80105704:	5e                   	pop    %esi
  popl %ebx
80105705:	5b                   	pop    %ebx
  popl %ebp
80105706:	5d                   	pop    %ebp
  ret
80105707:	c3                   	ret    

80105708 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105708:	f3 0f 1e fb          	endbr32 
8010570c:	55                   	push   %ebp
8010570d:	89 e5                	mov    %esp,%ebp
8010570f:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105712:	e8 78 e9 ff ff       	call   8010408f <myproc>
80105717:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010571a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010571d:	8b 00                	mov    (%eax),%eax
8010571f:	39 45 08             	cmp    %eax,0x8(%ebp)
80105722:	73 0f                	jae    80105733 <fetchint+0x2b>
80105724:	8b 45 08             	mov    0x8(%ebp),%eax
80105727:	8d 50 04             	lea    0x4(%eax),%edx
8010572a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010572d:	8b 00                	mov    (%eax),%eax
8010572f:	39 c2                	cmp    %eax,%edx
80105731:	76 07                	jbe    8010573a <fetchint+0x32>
    return -1;
80105733:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105738:	eb 0f                	jmp    80105749 <fetchint+0x41>
  *ip = *(int*)(addr);
8010573a:	8b 45 08             	mov    0x8(%ebp),%eax
8010573d:	8b 10                	mov    (%eax),%edx
8010573f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105742:	89 10                	mov    %edx,(%eax)
  return 0;
80105744:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105749:	c9                   	leave  
8010574a:	c3                   	ret    

8010574b <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010574b:	f3 0f 1e fb          	endbr32 
8010574f:	55                   	push   %ebp
80105750:	89 e5                	mov    %esp,%ebp
80105752:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105755:	e8 35 e9 ff ff       	call   8010408f <myproc>
8010575a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
8010575d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105760:	8b 00                	mov    (%eax),%eax
80105762:	39 45 08             	cmp    %eax,0x8(%ebp)
80105765:	72 07                	jb     8010576e <fetchstr+0x23>
    return -1;
80105767:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010576c:	eb 43                	jmp    801057b1 <fetchstr+0x66>
  *pp = (char*)addr;
8010576e:	8b 55 08             	mov    0x8(%ebp),%edx
80105771:	8b 45 0c             	mov    0xc(%ebp),%eax
80105774:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105776:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105779:	8b 00                	mov    (%eax),%eax
8010577b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
8010577e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105781:	8b 00                	mov    (%eax),%eax
80105783:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105786:	eb 1c                	jmp    801057a4 <fetchstr+0x59>
    if(*s == 0)
80105788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578b:	0f b6 00             	movzbl (%eax),%eax
8010578e:	84 c0                	test   %al,%al
80105790:	75 0e                	jne    801057a0 <fetchstr+0x55>
      return s - *pp;
80105792:	8b 45 0c             	mov    0xc(%ebp),%eax
80105795:	8b 00                	mov    (%eax),%eax
80105797:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010579a:	29 c2                	sub    %eax,%edx
8010579c:	89 d0                	mov    %edx,%eax
8010579e:	eb 11                	jmp    801057b1 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801057a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801057a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057a7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801057aa:	72 dc                	jb     80105788 <fetchstr+0x3d>
  }
  return -1;
801057ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057b1:	c9                   	leave  
801057b2:	c3                   	ret    

801057b3 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801057b3:	f3 0f 1e fb          	endbr32 
801057b7:	55                   	push   %ebp
801057b8:	89 e5                	mov    %esp,%ebp
801057ba:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801057bd:	e8 cd e8 ff ff       	call   8010408f <myproc>
801057c2:	8b 40 18             	mov    0x18(%eax),%eax
801057c5:	8b 40 44             	mov    0x44(%eax),%eax
801057c8:	8b 55 08             	mov    0x8(%ebp),%edx
801057cb:	c1 e2 02             	shl    $0x2,%edx
801057ce:	01 d0                	add    %edx,%eax
801057d0:	83 c0 04             	add    $0x4,%eax
801057d3:	83 ec 08             	sub    $0x8,%esp
801057d6:	ff 75 0c             	pushl  0xc(%ebp)
801057d9:	50                   	push   %eax
801057da:	e8 29 ff ff ff       	call   80105708 <fetchint>
801057df:	83 c4 10             	add    $0x10,%esp
}
801057e2:	c9                   	leave  
801057e3:	c3                   	ret    

801057e4 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801057e4:	f3 0f 1e fb          	endbr32 
801057e8:	55                   	push   %ebp
801057e9:	89 e5                	mov    %esp,%ebp
801057eb:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801057ee:	e8 9c e8 ff ff       	call   8010408f <myproc>
801057f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801057f6:	83 ec 08             	sub    $0x8,%esp
801057f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057fc:	50                   	push   %eax
801057fd:	ff 75 08             	pushl  0x8(%ebp)
80105800:	e8 ae ff ff ff       	call   801057b3 <argint>
80105805:	83 c4 10             	add    $0x10,%esp
80105808:	85 c0                	test   %eax,%eax
8010580a:	79 07                	jns    80105813 <argptr+0x2f>
    return -1;
8010580c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105811:	eb 3b                	jmp    8010584e <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105813:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105817:	78 1f                	js     80105838 <argptr+0x54>
80105819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010581c:	8b 00                	mov    (%eax),%eax
8010581e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105821:	39 d0                	cmp    %edx,%eax
80105823:	76 13                	jbe    80105838 <argptr+0x54>
80105825:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105828:	89 c2                	mov    %eax,%edx
8010582a:	8b 45 10             	mov    0x10(%ebp),%eax
8010582d:	01 c2                	add    %eax,%edx
8010582f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105832:	8b 00                	mov    (%eax),%eax
80105834:	39 c2                	cmp    %eax,%edx
80105836:	76 07                	jbe    8010583f <argptr+0x5b>
    return -1;
80105838:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583d:	eb 0f                	jmp    8010584e <argptr+0x6a>
  *pp = (char*)i;
8010583f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105842:	89 c2                	mov    %eax,%edx
80105844:	8b 45 0c             	mov    0xc(%ebp),%eax
80105847:	89 10                	mov    %edx,(%eax)
  return 0;
80105849:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010584e:	c9                   	leave  
8010584f:	c3                   	ret    

80105850 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105850:	f3 0f 1e fb          	endbr32 
80105854:	55                   	push   %ebp
80105855:	89 e5                	mov    %esp,%ebp
80105857:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010585a:	83 ec 08             	sub    $0x8,%esp
8010585d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105860:	50                   	push   %eax
80105861:	ff 75 08             	pushl  0x8(%ebp)
80105864:	e8 4a ff ff ff       	call   801057b3 <argint>
80105869:	83 c4 10             	add    $0x10,%esp
8010586c:	85 c0                	test   %eax,%eax
8010586e:	79 07                	jns    80105877 <argstr+0x27>
    return -1;
80105870:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105875:	eb 12                	jmp    80105889 <argstr+0x39>
  return fetchstr(addr, pp);
80105877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587a:	83 ec 08             	sub    $0x8,%esp
8010587d:	ff 75 0c             	pushl  0xc(%ebp)
80105880:	50                   	push   %eax
80105881:	e8 c5 fe ff ff       	call   8010574b <fetchstr>
80105886:	83 c4 10             	add    $0x10,%esp
}
80105889:	c9                   	leave  
8010588a:	c3                   	ret    

8010588b <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
8010588b:	f3 0f 1e fb          	endbr32 
8010588f:	55                   	push   %ebp
80105890:	89 e5                	mov    %esp,%ebp
80105892:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105895:	e8 f5 e7 ff ff       	call   8010408f <myproc>
8010589a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
8010589d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a0:	8b 40 18             	mov    0x18(%eax),%eax
801058a3:	8b 40 1c             	mov    0x1c(%eax),%eax
801058a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801058a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058ad:	7e 2f                	jle    801058de <syscall+0x53>
801058af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b2:	83 f8 19             	cmp    $0x19,%eax
801058b5:	77 27                	ja     801058de <syscall+0x53>
801058b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ba:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801058c1:	85 c0                	test   %eax,%eax
801058c3:	74 19                	je     801058de <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
801058c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c8:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801058cf:	ff d0                	call   *%eax
801058d1:	89 c2                	mov    %eax,%edx
801058d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d6:	8b 40 18             	mov    0x18(%eax),%eax
801058d9:	89 50 1c             	mov    %edx,0x1c(%eax)
801058dc:	eb 2c                	jmp    8010590a <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801058de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e1:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801058e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e7:	8b 40 10             	mov    0x10(%eax),%eax
801058ea:	ff 75 f0             	pushl  -0x10(%ebp)
801058ed:	52                   	push   %edx
801058ee:	50                   	push   %eax
801058ef:	68 1a b2 10 80       	push   $0x8010b21a
801058f4:	e8 13 ab ff ff       	call   8010040c <cprintf>
801058f9:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801058fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ff:	8b 40 18             	mov    0x18(%eax),%eax
80105902:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105909:	90                   	nop
8010590a:	90                   	nop
8010590b:	c9                   	leave  
8010590c:	c3                   	ret    

8010590d <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010590d:	f3 0f 1e fb          	endbr32 
80105911:	55                   	push   %ebp
80105912:	89 e5                	mov    %esp,%ebp
80105914:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105917:	83 ec 08             	sub    $0x8,%esp
8010591a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010591d:	50                   	push   %eax
8010591e:	ff 75 08             	pushl  0x8(%ebp)
80105921:	e8 8d fe ff ff       	call   801057b3 <argint>
80105926:	83 c4 10             	add    $0x10,%esp
80105929:	85 c0                	test   %eax,%eax
8010592b:	79 07                	jns    80105934 <argfd+0x27>
    return -1;
8010592d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105932:	eb 4f                	jmp    80105983 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105934:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105937:	85 c0                	test   %eax,%eax
80105939:	78 20                	js     8010595b <argfd+0x4e>
8010593b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593e:	83 f8 0f             	cmp    $0xf,%eax
80105941:	7f 18                	jg     8010595b <argfd+0x4e>
80105943:	e8 47 e7 ff ff       	call   8010408f <myproc>
80105948:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010594b:	83 c2 08             	add    $0x8,%edx
8010594e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105952:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105955:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105959:	75 07                	jne    80105962 <argfd+0x55>
    return -1;
8010595b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105960:	eb 21                	jmp    80105983 <argfd+0x76>
  if(pfd)
80105962:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105966:	74 08                	je     80105970 <argfd+0x63>
    *pfd = fd;
80105968:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010596b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010596e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105970:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105974:	74 08                	je     8010597e <argfd+0x71>
    *pf = f;
80105976:	8b 45 10             	mov    0x10(%ebp),%eax
80105979:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010597c:	89 10                	mov    %edx,(%eax)
  return 0;
8010597e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105983:	c9                   	leave  
80105984:	c3                   	ret    

80105985 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105985:	f3 0f 1e fb          	endbr32 
80105989:	55                   	push   %ebp
8010598a:	89 e5                	mov    %esp,%ebp
8010598c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010598f:	e8 fb e6 ff ff       	call   8010408f <myproc>
80105994:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105997:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010599e:	eb 2a                	jmp    801059ca <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
801059a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059a6:	83 c2 08             	add    $0x8,%edx
801059a9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059ad:	85 c0                	test   %eax,%eax
801059af:	75 15                	jne    801059c6 <fdalloc+0x41>
      curproc->ofile[fd] = f;
801059b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059b7:	8d 4a 08             	lea    0x8(%edx),%ecx
801059ba:	8b 55 08             	mov    0x8(%ebp),%edx
801059bd:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801059c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c4:	eb 0f                	jmp    801059d5 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
801059c6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801059ca:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801059ce:	7e d0                	jle    801059a0 <fdalloc+0x1b>
    }
  }
  return -1;
801059d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059d5:	c9                   	leave  
801059d6:	c3                   	ret    

801059d7 <sys_dup>:

int
sys_dup(void)
{
801059d7:	f3 0f 1e fb          	endbr32 
801059db:	55                   	push   %ebp
801059dc:	89 e5                	mov    %esp,%ebp
801059de:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801059e1:	83 ec 04             	sub    $0x4,%esp
801059e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059e7:	50                   	push   %eax
801059e8:	6a 00                	push   $0x0
801059ea:	6a 00                	push   $0x0
801059ec:	e8 1c ff ff ff       	call   8010590d <argfd>
801059f1:	83 c4 10             	add    $0x10,%esp
801059f4:	85 c0                	test   %eax,%eax
801059f6:	79 07                	jns    801059ff <sys_dup+0x28>
    return -1;
801059f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059fd:	eb 31                	jmp    80105a30 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801059ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a02:	83 ec 0c             	sub    $0xc,%esp
80105a05:	50                   	push   %eax
80105a06:	e8 7a ff ff ff       	call   80105985 <fdalloc>
80105a0b:	83 c4 10             	add    $0x10,%esp
80105a0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a15:	79 07                	jns    80105a1e <sys_dup+0x47>
    return -1;
80105a17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1c:	eb 12                	jmp    80105a30 <sys_dup+0x59>
  filedup(f);
80105a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a21:	83 ec 0c             	sub    $0xc,%esp
80105a24:	50                   	push   %eax
80105a25:	e8 58 b6 ff ff       	call   80101082 <filedup>
80105a2a:	83 c4 10             	add    $0x10,%esp
  return fd;
80105a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105a30:	c9                   	leave  
80105a31:	c3                   	ret    

80105a32 <sys_read>:

int
sys_read(void)
{
80105a32:	f3 0f 1e fb          	endbr32 
80105a36:	55                   	push   %ebp
80105a37:	89 e5                	mov    %esp,%ebp
80105a39:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a3c:	83 ec 04             	sub    $0x4,%esp
80105a3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a42:	50                   	push   %eax
80105a43:	6a 00                	push   $0x0
80105a45:	6a 00                	push   $0x0
80105a47:	e8 c1 fe ff ff       	call   8010590d <argfd>
80105a4c:	83 c4 10             	add    $0x10,%esp
80105a4f:	85 c0                	test   %eax,%eax
80105a51:	78 2e                	js     80105a81 <sys_read+0x4f>
80105a53:	83 ec 08             	sub    $0x8,%esp
80105a56:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a59:	50                   	push   %eax
80105a5a:	6a 02                	push   $0x2
80105a5c:	e8 52 fd ff ff       	call   801057b3 <argint>
80105a61:	83 c4 10             	add    $0x10,%esp
80105a64:	85 c0                	test   %eax,%eax
80105a66:	78 19                	js     80105a81 <sys_read+0x4f>
80105a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a6b:	83 ec 04             	sub    $0x4,%esp
80105a6e:	50                   	push   %eax
80105a6f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a72:	50                   	push   %eax
80105a73:	6a 01                	push   $0x1
80105a75:	e8 6a fd ff ff       	call   801057e4 <argptr>
80105a7a:	83 c4 10             	add    $0x10,%esp
80105a7d:	85 c0                	test   %eax,%eax
80105a7f:	79 07                	jns    80105a88 <sys_read+0x56>
    return -1;
80105a81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a86:	eb 17                	jmp    80105a9f <sys_read+0x6d>
  return fileread(f, p, n);
80105a88:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a8b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a91:	83 ec 04             	sub    $0x4,%esp
80105a94:	51                   	push   %ecx
80105a95:	52                   	push   %edx
80105a96:	50                   	push   %eax
80105a97:	e8 82 b7 ff ff       	call   8010121e <fileread>
80105a9c:	83 c4 10             	add    $0x10,%esp
}
80105a9f:	c9                   	leave  
80105aa0:	c3                   	ret    

80105aa1 <sys_write>:

int
sys_write(void)
{
80105aa1:	f3 0f 1e fb          	endbr32 
80105aa5:	55                   	push   %ebp
80105aa6:	89 e5                	mov    %esp,%ebp
80105aa8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105aab:	83 ec 04             	sub    $0x4,%esp
80105aae:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ab1:	50                   	push   %eax
80105ab2:	6a 00                	push   $0x0
80105ab4:	6a 00                	push   $0x0
80105ab6:	e8 52 fe ff ff       	call   8010590d <argfd>
80105abb:	83 c4 10             	add    $0x10,%esp
80105abe:	85 c0                	test   %eax,%eax
80105ac0:	78 2e                	js     80105af0 <sys_write+0x4f>
80105ac2:	83 ec 08             	sub    $0x8,%esp
80105ac5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ac8:	50                   	push   %eax
80105ac9:	6a 02                	push   $0x2
80105acb:	e8 e3 fc ff ff       	call   801057b3 <argint>
80105ad0:	83 c4 10             	add    $0x10,%esp
80105ad3:	85 c0                	test   %eax,%eax
80105ad5:	78 19                	js     80105af0 <sys_write+0x4f>
80105ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ada:	83 ec 04             	sub    $0x4,%esp
80105add:	50                   	push   %eax
80105ade:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ae1:	50                   	push   %eax
80105ae2:	6a 01                	push   $0x1
80105ae4:	e8 fb fc ff ff       	call   801057e4 <argptr>
80105ae9:	83 c4 10             	add    $0x10,%esp
80105aec:	85 c0                	test   %eax,%eax
80105aee:	79 07                	jns    80105af7 <sys_write+0x56>
    return -1;
80105af0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af5:	eb 17                	jmp    80105b0e <sys_write+0x6d>
  return filewrite(f, p, n);
80105af7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105afa:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b00:	83 ec 04             	sub    $0x4,%esp
80105b03:	51                   	push   %ecx
80105b04:	52                   	push   %edx
80105b05:	50                   	push   %eax
80105b06:	e8 cf b7 ff ff       	call   801012da <filewrite>
80105b0b:	83 c4 10             	add    $0x10,%esp
}
80105b0e:	c9                   	leave  
80105b0f:	c3                   	ret    

80105b10 <sys_close>:

int
sys_close(void)
{
80105b10:	f3 0f 1e fb          	endbr32 
80105b14:	55                   	push   %ebp
80105b15:	89 e5                	mov    %esp,%ebp
80105b17:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105b1a:	83 ec 04             	sub    $0x4,%esp
80105b1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b20:	50                   	push   %eax
80105b21:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b24:	50                   	push   %eax
80105b25:	6a 00                	push   $0x0
80105b27:	e8 e1 fd ff ff       	call   8010590d <argfd>
80105b2c:	83 c4 10             	add    $0x10,%esp
80105b2f:	85 c0                	test   %eax,%eax
80105b31:	79 07                	jns    80105b3a <sys_close+0x2a>
    return -1;
80105b33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b38:	eb 27                	jmp    80105b61 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105b3a:	e8 50 e5 ff ff       	call   8010408f <myproc>
80105b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b42:	83 c2 08             	add    $0x8,%edx
80105b45:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b4c:	00 
  fileclose(f);
80105b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b50:	83 ec 0c             	sub    $0xc,%esp
80105b53:	50                   	push   %eax
80105b54:	e8 7e b5 ff ff       	call   801010d7 <fileclose>
80105b59:	83 c4 10             	add    $0x10,%esp
  return 0;
80105b5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b61:	c9                   	leave  
80105b62:	c3                   	ret    

80105b63 <sys_fstat>:

int
sys_fstat(void)
{
80105b63:	f3 0f 1e fb          	endbr32 
80105b67:	55                   	push   %ebp
80105b68:	89 e5                	mov    %esp,%ebp
80105b6a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b6d:	83 ec 04             	sub    $0x4,%esp
80105b70:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b73:	50                   	push   %eax
80105b74:	6a 00                	push   $0x0
80105b76:	6a 00                	push   $0x0
80105b78:	e8 90 fd ff ff       	call   8010590d <argfd>
80105b7d:	83 c4 10             	add    $0x10,%esp
80105b80:	85 c0                	test   %eax,%eax
80105b82:	78 17                	js     80105b9b <sys_fstat+0x38>
80105b84:	83 ec 04             	sub    $0x4,%esp
80105b87:	6a 14                	push   $0x14
80105b89:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b8c:	50                   	push   %eax
80105b8d:	6a 01                	push   $0x1
80105b8f:	e8 50 fc ff ff       	call   801057e4 <argptr>
80105b94:	83 c4 10             	add    $0x10,%esp
80105b97:	85 c0                	test   %eax,%eax
80105b99:	79 07                	jns    80105ba2 <sys_fstat+0x3f>
    return -1;
80105b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba0:	eb 13                	jmp    80105bb5 <sys_fstat+0x52>
  return filestat(f, st);
80105ba2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba8:	83 ec 08             	sub    $0x8,%esp
80105bab:	52                   	push   %edx
80105bac:	50                   	push   %eax
80105bad:	e8 11 b6 ff ff       	call   801011c3 <filestat>
80105bb2:	83 c4 10             	add    $0x10,%esp
}
80105bb5:	c9                   	leave  
80105bb6:	c3                   	ret    

80105bb7 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105bb7:	f3 0f 1e fb          	endbr32 
80105bbb:	55                   	push   %ebp
80105bbc:	89 e5                	mov    %esp,%ebp
80105bbe:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105bc1:	83 ec 08             	sub    $0x8,%esp
80105bc4:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105bc7:	50                   	push   %eax
80105bc8:	6a 00                	push   $0x0
80105bca:	e8 81 fc ff ff       	call   80105850 <argstr>
80105bcf:	83 c4 10             	add    $0x10,%esp
80105bd2:	85 c0                	test   %eax,%eax
80105bd4:	78 15                	js     80105beb <sys_link+0x34>
80105bd6:	83 ec 08             	sub    $0x8,%esp
80105bd9:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105bdc:	50                   	push   %eax
80105bdd:	6a 01                	push   $0x1
80105bdf:	e8 6c fc ff ff       	call   80105850 <argstr>
80105be4:	83 c4 10             	add    $0x10,%esp
80105be7:	85 c0                	test   %eax,%eax
80105be9:	79 0a                	jns    80105bf5 <sys_link+0x3e>
    return -1;
80105beb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf0:	e9 68 01 00 00       	jmp    80105d5d <sys_link+0x1a6>

  begin_op();
80105bf5:	e8 5d da ff ff       	call   80103657 <begin_op>
  if((ip = namei(old)) == 0){
80105bfa:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105bfd:	83 ec 0c             	sub    $0xc,%esp
80105c00:	50                   	push   %eax
80105c01:	e8 cf c9 ff ff       	call   801025d5 <namei>
80105c06:	83 c4 10             	add    $0x10,%esp
80105c09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c10:	75 0f                	jne    80105c21 <sys_link+0x6a>
    end_op();
80105c12:	e8 d0 da ff ff       	call   801036e7 <end_op>
    return -1;
80105c17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1c:	e9 3c 01 00 00       	jmp    80105d5d <sys_link+0x1a6>
  }

  ilock(ip);
80105c21:	83 ec 0c             	sub    $0xc,%esp
80105c24:	ff 75 f4             	pushl  -0xc(%ebp)
80105c27:	e8 3e be ff ff       	call   80101a6a <ilock>
80105c2c:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c32:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c36:	66 83 f8 01          	cmp    $0x1,%ax
80105c3a:	75 1d                	jne    80105c59 <sys_link+0xa2>
    iunlockput(ip);
80105c3c:	83 ec 0c             	sub    $0xc,%esp
80105c3f:	ff 75 f4             	pushl  -0xc(%ebp)
80105c42:	e8 60 c0 ff ff       	call   80101ca7 <iunlockput>
80105c47:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c4a:	e8 98 da ff ff       	call   801036e7 <end_op>
    return -1;
80105c4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c54:	e9 04 01 00 00       	jmp    80105d5d <sys_link+0x1a6>
  }

  ip->nlink++;
80105c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5c:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c60:	83 c0 01             	add    $0x1,%eax
80105c63:	89 c2                	mov    %eax,%edx
80105c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c68:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105c6c:	83 ec 0c             	sub    $0xc,%esp
80105c6f:	ff 75 f4             	pushl  -0xc(%ebp)
80105c72:	e8 0a bc ff ff       	call   80101881 <iupdate>
80105c77:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105c7a:	83 ec 0c             	sub    $0xc,%esp
80105c7d:	ff 75 f4             	pushl  -0xc(%ebp)
80105c80:	e8 fc be ff ff       	call   80101b81 <iunlock>
80105c85:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105c88:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c8b:	83 ec 08             	sub    $0x8,%esp
80105c8e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c91:	52                   	push   %edx
80105c92:	50                   	push   %eax
80105c93:	e8 5d c9 ff ff       	call   801025f5 <nameiparent>
80105c98:	83 c4 10             	add    $0x10,%esp
80105c9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c9e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ca2:	74 71                	je     80105d15 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105ca4:	83 ec 0c             	sub    $0xc,%esp
80105ca7:	ff 75 f0             	pushl  -0x10(%ebp)
80105caa:	e8 bb bd ff ff       	call   80101a6a <ilock>
80105caf:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb5:	8b 10                	mov    (%eax),%edx
80105cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cba:	8b 00                	mov    (%eax),%eax
80105cbc:	39 c2                	cmp    %eax,%edx
80105cbe:	75 1d                	jne    80105cdd <sys_link+0x126>
80105cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc3:	8b 40 04             	mov    0x4(%eax),%eax
80105cc6:	83 ec 04             	sub    $0x4,%esp
80105cc9:	50                   	push   %eax
80105cca:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ccd:	50                   	push   %eax
80105cce:	ff 75 f0             	pushl  -0x10(%ebp)
80105cd1:	e8 5c c6 ff ff       	call   80102332 <dirlink>
80105cd6:	83 c4 10             	add    $0x10,%esp
80105cd9:	85 c0                	test   %eax,%eax
80105cdb:	79 10                	jns    80105ced <sys_link+0x136>
    iunlockput(dp);
80105cdd:	83 ec 0c             	sub    $0xc,%esp
80105ce0:	ff 75 f0             	pushl  -0x10(%ebp)
80105ce3:	e8 bf bf ff ff       	call   80101ca7 <iunlockput>
80105ce8:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ceb:	eb 29                	jmp    80105d16 <sys_link+0x15f>
  }
  iunlockput(dp);
80105ced:	83 ec 0c             	sub    $0xc,%esp
80105cf0:	ff 75 f0             	pushl  -0x10(%ebp)
80105cf3:	e8 af bf ff ff       	call   80101ca7 <iunlockput>
80105cf8:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105cfb:	83 ec 0c             	sub    $0xc,%esp
80105cfe:	ff 75 f4             	pushl  -0xc(%ebp)
80105d01:	e8 cd be ff ff       	call   80101bd3 <iput>
80105d06:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d09:	e8 d9 d9 ff ff       	call   801036e7 <end_op>

  return 0;
80105d0e:	b8 00 00 00 00       	mov    $0x0,%eax
80105d13:	eb 48                	jmp    80105d5d <sys_link+0x1a6>
    goto bad;
80105d15:	90                   	nop

bad:
  ilock(ip);
80105d16:	83 ec 0c             	sub    $0xc,%esp
80105d19:	ff 75 f4             	pushl  -0xc(%ebp)
80105d1c:	e8 49 bd ff ff       	call   80101a6a <ilock>
80105d21:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d27:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d2b:	83 e8 01             	sub    $0x1,%eax
80105d2e:	89 c2                	mov    %eax,%edx
80105d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d33:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d37:	83 ec 0c             	sub    $0xc,%esp
80105d3a:	ff 75 f4             	pushl  -0xc(%ebp)
80105d3d:	e8 3f bb ff ff       	call   80101881 <iupdate>
80105d42:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d45:	83 ec 0c             	sub    $0xc,%esp
80105d48:	ff 75 f4             	pushl  -0xc(%ebp)
80105d4b:	e8 57 bf ff ff       	call   80101ca7 <iunlockput>
80105d50:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d53:	e8 8f d9 ff ff       	call   801036e7 <end_op>
  return -1;
80105d58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d5d:	c9                   	leave  
80105d5e:	c3                   	ret    

80105d5f <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105d5f:	f3 0f 1e fb          	endbr32 
80105d63:	55                   	push   %ebp
80105d64:	89 e5                	mov    %esp,%ebp
80105d66:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d69:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d70:	eb 40                	jmp    80105db2 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d75:	6a 10                	push   $0x10
80105d77:	50                   	push   %eax
80105d78:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d7b:	50                   	push   %eax
80105d7c:	ff 75 08             	pushl  0x8(%ebp)
80105d7f:	e8 ee c1 ff ff       	call   80101f72 <readi>
80105d84:	83 c4 10             	add    $0x10,%esp
80105d87:	83 f8 10             	cmp    $0x10,%eax
80105d8a:	74 0d                	je     80105d99 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105d8c:	83 ec 0c             	sub    $0xc,%esp
80105d8f:	68 36 b2 10 80       	push   $0x8010b236
80105d94:	e8 2c a8 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105d99:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105d9d:	66 85 c0             	test   %ax,%ax
80105da0:	74 07                	je     80105da9 <isdirempty+0x4a>
      return 0;
80105da2:	b8 00 00 00 00       	mov    $0x0,%eax
80105da7:	eb 1b                	jmp    80105dc4 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dac:	83 c0 10             	add    $0x10,%eax
80105daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105db2:	8b 45 08             	mov    0x8(%ebp),%eax
80105db5:	8b 50 58             	mov    0x58(%eax),%edx
80105db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbb:	39 c2                	cmp    %eax,%edx
80105dbd:	77 b3                	ja     80105d72 <isdirempty+0x13>
  }
  return 1;
80105dbf:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105dc4:	c9                   	leave  
80105dc5:	c3                   	ret    

80105dc6 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105dc6:	f3 0f 1e fb          	endbr32 
80105dca:	55                   	push   %ebp
80105dcb:	89 e5                	mov    %esp,%ebp
80105dcd:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105dd0:	83 ec 08             	sub    $0x8,%esp
80105dd3:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105dd6:	50                   	push   %eax
80105dd7:	6a 00                	push   $0x0
80105dd9:	e8 72 fa ff ff       	call   80105850 <argstr>
80105dde:	83 c4 10             	add    $0x10,%esp
80105de1:	85 c0                	test   %eax,%eax
80105de3:	79 0a                	jns    80105def <sys_unlink+0x29>
    return -1;
80105de5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dea:	e9 bf 01 00 00       	jmp    80105fae <sys_unlink+0x1e8>

  begin_op();
80105def:	e8 63 d8 ff ff       	call   80103657 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105df4:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105df7:	83 ec 08             	sub    $0x8,%esp
80105dfa:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105dfd:	52                   	push   %edx
80105dfe:	50                   	push   %eax
80105dff:	e8 f1 c7 ff ff       	call   801025f5 <nameiparent>
80105e04:	83 c4 10             	add    $0x10,%esp
80105e07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e0e:	75 0f                	jne    80105e1f <sys_unlink+0x59>
    end_op();
80105e10:	e8 d2 d8 ff ff       	call   801036e7 <end_op>
    return -1;
80105e15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1a:	e9 8f 01 00 00       	jmp    80105fae <sys_unlink+0x1e8>
  }

  ilock(dp);
80105e1f:	83 ec 0c             	sub    $0xc,%esp
80105e22:	ff 75 f4             	pushl  -0xc(%ebp)
80105e25:	e8 40 bc ff ff       	call   80101a6a <ilock>
80105e2a:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e2d:	83 ec 08             	sub    $0x8,%esp
80105e30:	68 48 b2 10 80       	push   $0x8010b248
80105e35:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e38:	50                   	push   %eax
80105e39:	e8 17 c4 ff ff       	call   80102255 <namecmp>
80105e3e:	83 c4 10             	add    $0x10,%esp
80105e41:	85 c0                	test   %eax,%eax
80105e43:	0f 84 49 01 00 00    	je     80105f92 <sys_unlink+0x1cc>
80105e49:	83 ec 08             	sub    $0x8,%esp
80105e4c:	68 4a b2 10 80       	push   $0x8010b24a
80105e51:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e54:	50                   	push   %eax
80105e55:	e8 fb c3 ff ff       	call   80102255 <namecmp>
80105e5a:	83 c4 10             	add    $0x10,%esp
80105e5d:	85 c0                	test   %eax,%eax
80105e5f:	0f 84 2d 01 00 00    	je     80105f92 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105e65:	83 ec 04             	sub    $0x4,%esp
80105e68:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105e6b:	50                   	push   %eax
80105e6c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e6f:	50                   	push   %eax
80105e70:	ff 75 f4             	pushl  -0xc(%ebp)
80105e73:	e8 fc c3 ff ff       	call   80102274 <dirlookup>
80105e78:	83 c4 10             	add    $0x10,%esp
80105e7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e82:	0f 84 0d 01 00 00    	je     80105f95 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105e88:	83 ec 0c             	sub    $0xc,%esp
80105e8b:	ff 75 f0             	pushl  -0x10(%ebp)
80105e8e:	e8 d7 bb ff ff       	call   80101a6a <ilock>
80105e93:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105e96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e99:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e9d:	66 85 c0             	test   %ax,%ax
80105ea0:	7f 0d                	jg     80105eaf <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105ea2:	83 ec 0c             	sub    $0xc,%esp
80105ea5:	68 4d b2 10 80       	push   $0x8010b24d
80105eaa:	e8 16 a7 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105eb6:	66 83 f8 01          	cmp    $0x1,%ax
80105eba:	75 25                	jne    80105ee1 <sys_unlink+0x11b>
80105ebc:	83 ec 0c             	sub    $0xc,%esp
80105ebf:	ff 75 f0             	pushl  -0x10(%ebp)
80105ec2:	e8 98 fe ff ff       	call   80105d5f <isdirempty>
80105ec7:	83 c4 10             	add    $0x10,%esp
80105eca:	85 c0                	test   %eax,%eax
80105ecc:	75 13                	jne    80105ee1 <sys_unlink+0x11b>
    iunlockput(ip);
80105ece:	83 ec 0c             	sub    $0xc,%esp
80105ed1:	ff 75 f0             	pushl  -0x10(%ebp)
80105ed4:	e8 ce bd ff ff       	call   80101ca7 <iunlockput>
80105ed9:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105edc:	e9 b5 00 00 00       	jmp    80105f96 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105ee1:	83 ec 04             	sub    $0x4,%esp
80105ee4:	6a 10                	push   $0x10
80105ee6:	6a 00                	push   $0x0
80105ee8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105eeb:	50                   	push   %eax
80105eec:	e8 6e f5 ff ff       	call   8010545f <memset>
80105ef1:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ef4:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ef7:	6a 10                	push   $0x10
80105ef9:	50                   	push   %eax
80105efa:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105efd:	50                   	push   %eax
80105efe:	ff 75 f4             	pushl  -0xc(%ebp)
80105f01:	e8 c5 c1 ff ff       	call   801020cb <writei>
80105f06:	83 c4 10             	add    $0x10,%esp
80105f09:	83 f8 10             	cmp    $0x10,%eax
80105f0c:	74 0d                	je     80105f1b <sys_unlink+0x155>
    panic("unlink: writei");
80105f0e:	83 ec 0c             	sub    $0xc,%esp
80105f11:	68 5f b2 10 80       	push   $0x8010b25f
80105f16:	e8 aa a6 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f22:	66 83 f8 01          	cmp    $0x1,%ax
80105f26:	75 21                	jne    80105f49 <sys_unlink+0x183>
    dp->nlink--;
80105f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f2f:	83 e8 01             	sub    $0x1,%eax
80105f32:	89 c2                	mov    %eax,%edx
80105f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f37:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105f3b:	83 ec 0c             	sub    $0xc,%esp
80105f3e:	ff 75 f4             	pushl  -0xc(%ebp)
80105f41:	e8 3b b9 ff ff       	call   80101881 <iupdate>
80105f46:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105f49:	83 ec 0c             	sub    $0xc,%esp
80105f4c:	ff 75 f4             	pushl  -0xc(%ebp)
80105f4f:	e8 53 bd ff ff       	call   80101ca7 <iunlockput>
80105f54:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105f57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f5e:	83 e8 01             	sub    $0x1,%eax
80105f61:	89 c2                	mov    %eax,%edx
80105f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f66:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105f6a:	83 ec 0c             	sub    $0xc,%esp
80105f6d:	ff 75 f0             	pushl  -0x10(%ebp)
80105f70:	e8 0c b9 ff ff       	call   80101881 <iupdate>
80105f75:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105f78:	83 ec 0c             	sub    $0xc,%esp
80105f7b:	ff 75 f0             	pushl  -0x10(%ebp)
80105f7e:	e8 24 bd ff ff       	call   80101ca7 <iunlockput>
80105f83:	83 c4 10             	add    $0x10,%esp

  end_op();
80105f86:	e8 5c d7 ff ff       	call   801036e7 <end_op>

  return 0;
80105f8b:	b8 00 00 00 00       	mov    $0x0,%eax
80105f90:	eb 1c                	jmp    80105fae <sys_unlink+0x1e8>
    goto bad;
80105f92:	90                   	nop
80105f93:	eb 01                	jmp    80105f96 <sys_unlink+0x1d0>
    goto bad;
80105f95:	90                   	nop

bad:
  iunlockput(dp);
80105f96:	83 ec 0c             	sub    $0xc,%esp
80105f99:	ff 75 f4             	pushl  -0xc(%ebp)
80105f9c:	e8 06 bd ff ff       	call   80101ca7 <iunlockput>
80105fa1:	83 c4 10             	add    $0x10,%esp
  end_op();
80105fa4:	e8 3e d7 ff ff       	call   801036e7 <end_op>
  return -1;
80105fa9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105fae:	c9                   	leave  
80105faf:	c3                   	ret    

80105fb0 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105fb0:	f3 0f 1e fb          	endbr32 
80105fb4:	55                   	push   %ebp
80105fb5:	89 e5                	mov    %esp,%ebp
80105fb7:	83 ec 38             	sub    $0x38,%esp
80105fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105fbd:	8b 55 10             	mov    0x10(%ebp),%edx
80105fc0:	8b 45 14             	mov    0x14(%ebp),%eax
80105fc3:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105fc7:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105fcb:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105fcf:	83 ec 08             	sub    $0x8,%esp
80105fd2:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fd5:	50                   	push   %eax
80105fd6:	ff 75 08             	pushl  0x8(%ebp)
80105fd9:	e8 17 c6 ff ff       	call   801025f5 <nameiparent>
80105fde:	83 c4 10             	add    $0x10,%esp
80105fe1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fe4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fe8:	75 0a                	jne    80105ff4 <create+0x44>
    return 0;
80105fea:	b8 00 00 00 00       	mov    $0x0,%eax
80105fef:	e9 90 01 00 00       	jmp    80106184 <create+0x1d4>
  ilock(dp);
80105ff4:	83 ec 0c             	sub    $0xc,%esp
80105ff7:	ff 75 f4             	pushl  -0xc(%ebp)
80105ffa:	e8 6b ba ff ff       	call   80101a6a <ilock>
80105fff:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106002:	83 ec 04             	sub    $0x4,%esp
80106005:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106008:	50                   	push   %eax
80106009:	8d 45 de             	lea    -0x22(%ebp),%eax
8010600c:	50                   	push   %eax
8010600d:	ff 75 f4             	pushl  -0xc(%ebp)
80106010:	e8 5f c2 ff ff       	call   80102274 <dirlookup>
80106015:	83 c4 10             	add    $0x10,%esp
80106018:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010601b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010601f:	74 50                	je     80106071 <create+0xc1>
    iunlockput(dp);
80106021:	83 ec 0c             	sub    $0xc,%esp
80106024:	ff 75 f4             	pushl  -0xc(%ebp)
80106027:	e8 7b bc ff ff       	call   80101ca7 <iunlockput>
8010602c:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010602f:	83 ec 0c             	sub    $0xc,%esp
80106032:	ff 75 f0             	pushl  -0x10(%ebp)
80106035:	e8 30 ba ff ff       	call   80101a6a <ilock>
8010603a:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010603d:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106042:	75 15                	jne    80106059 <create+0xa9>
80106044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106047:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010604b:	66 83 f8 02          	cmp    $0x2,%ax
8010604f:	75 08                	jne    80106059 <create+0xa9>
      return ip;
80106051:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106054:	e9 2b 01 00 00       	jmp    80106184 <create+0x1d4>
    iunlockput(ip);
80106059:	83 ec 0c             	sub    $0xc,%esp
8010605c:	ff 75 f0             	pushl  -0x10(%ebp)
8010605f:	e8 43 bc ff ff       	call   80101ca7 <iunlockput>
80106064:	83 c4 10             	add    $0x10,%esp
    return 0;
80106067:	b8 00 00 00 00       	mov    $0x0,%eax
8010606c:	e9 13 01 00 00       	jmp    80106184 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106071:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106075:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106078:	8b 00                	mov    (%eax),%eax
8010607a:	83 ec 08             	sub    $0x8,%esp
8010607d:	52                   	push   %edx
8010607e:	50                   	push   %eax
8010607f:	e8 22 b7 ff ff       	call   801017a6 <ialloc>
80106084:	83 c4 10             	add    $0x10,%esp
80106087:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010608a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010608e:	75 0d                	jne    8010609d <create+0xed>
    panic("create: ialloc");
80106090:	83 ec 0c             	sub    $0xc,%esp
80106093:	68 6e b2 10 80       	push   $0x8010b26e
80106098:	e8 28 a5 ff ff       	call   801005c5 <panic>

  ilock(ip);
8010609d:	83 ec 0c             	sub    $0xc,%esp
801060a0:	ff 75 f0             	pushl  -0x10(%ebp)
801060a3:	e8 c2 b9 ff ff       	call   80101a6a <ilock>
801060a8:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801060ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ae:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801060b2:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801060b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b9:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801060bd:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801060c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c4:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801060ca:	83 ec 0c             	sub    $0xc,%esp
801060cd:	ff 75 f0             	pushl  -0x10(%ebp)
801060d0:	e8 ac b7 ff ff       	call   80101881 <iupdate>
801060d5:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801060d8:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801060dd:	75 6a                	jne    80106149 <create+0x199>
    dp->nlink++;  // for ".."
801060df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801060e6:	83 c0 01             	add    $0x1,%eax
801060e9:	89 c2                	mov    %eax,%edx
801060eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ee:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801060f2:	83 ec 0c             	sub    $0xc,%esp
801060f5:	ff 75 f4             	pushl  -0xc(%ebp)
801060f8:	e8 84 b7 ff ff       	call   80101881 <iupdate>
801060fd:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106100:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106103:	8b 40 04             	mov    0x4(%eax),%eax
80106106:	83 ec 04             	sub    $0x4,%esp
80106109:	50                   	push   %eax
8010610a:	68 48 b2 10 80       	push   $0x8010b248
8010610f:	ff 75 f0             	pushl  -0x10(%ebp)
80106112:	e8 1b c2 ff ff       	call   80102332 <dirlink>
80106117:	83 c4 10             	add    $0x10,%esp
8010611a:	85 c0                	test   %eax,%eax
8010611c:	78 1e                	js     8010613c <create+0x18c>
8010611e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106121:	8b 40 04             	mov    0x4(%eax),%eax
80106124:	83 ec 04             	sub    $0x4,%esp
80106127:	50                   	push   %eax
80106128:	68 4a b2 10 80       	push   $0x8010b24a
8010612d:	ff 75 f0             	pushl  -0x10(%ebp)
80106130:	e8 fd c1 ff ff       	call   80102332 <dirlink>
80106135:	83 c4 10             	add    $0x10,%esp
80106138:	85 c0                	test   %eax,%eax
8010613a:	79 0d                	jns    80106149 <create+0x199>
      panic("create dots");
8010613c:	83 ec 0c             	sub    $0xc,%esp
8010613f:	68 7d b2 10 80       	push   $0x8010b27d
80106144:	e8 7c a4 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106149:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010614c:	8b 40 04             	mov    0x4(%eax),%eax
8010614f:	83 ec 04             	sub    $0x4,%esp
80106152:	50                   	push   %eax
80106153:	8d 45 de             	lea    -0x22(%ebp),%eax
80106156:	50                   	push   %eax
80106157:	ff 75 f4             	pushl  -0xc(%ebp)
8010615a:	e8 d3 c1 ff ff       	call   80102332 <dirlink>
8010615f:	83 c4 10             	add    $0x10,%esp
80106162:	85 c0                	test   %eax,%eax
80106164:	79 0d                	jns    80106173 <create+0x1c3>
    panic("create: dirlink");
80106166:	83 ec 0c             	sub    $0xc,%esp
80106169:	68 89 b2 10 80       	push   $0x8010b289
8010616e:	e8 52 a4 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80106173:	83 ec 0c             	sub    $0xc,%esp
80106176:	ff 75 f4             	pushl  -0xc(%ebp)
80106179:	e8 29 bb ff ff       	call   80101ca7 <iunlockput>
8010617e:	83 c4 10             	add    $0x10,%esp

  return ip;
80106181:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106184:	c9                   	leave  
80106185:	c3                   	ret    

80106186 <sys_open>:

int
sys_open(void)
{
80106186:	f3 0f 1e fb          	endbr32 
8010618a:	55                   	push   %ebp
8010618b:	89 e5                	mov    %esp,%ebp
8010618d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106190:	83 ec 08             	sub    $0x8,%esp
80106193:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106196:	50                   	push   %eax
80106197:	6a 00                	push   $0x0
80106199:	e8 b2 f6 ff ff       	call   80105850 <argstr>
8010619e:	83 c4 10             	add    $0x10,%esp
801061a1:	85 c0                	test   %eax,%eax
801061a3:	78 15                	js     801061ba <sys_open+0x34>
801061a5:	83 ec 08             	sub    $0x8,%esp
801061a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061ab:	50                   	push   %eax
801061ac:	6a 01                	push   $0x1
801061ae:	e8 00 f6 ff ff       	call   801057b3 <argint>
801061b3:	83 c4 10             	add    $0x10,%esp
801061b6:	85 c0                	test   %eax,%eax
801061b8:	79 0a                	jns    801061c4 <sys_open+0x3e>
    return -1;
801061ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061bf:	e9 61 01 00 00       	jmp    80106325 <sys_open+0x19f>

  begin_op();
801061c4:	e8 8e d4 ff ff       	call   80103657 <begin_op>

  if(omode & O_CREATE){
801061c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061cc:	25 00 02 00 00       	and    $0x200,%eax
801061d1:	85 c0                	test   %eax,%eax
801061d3:	74 2a                	je     801061ff <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801061d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061d8:	6a 00                	push   $0x0
801061da:	6a 00                	push   $0x0
801061dc:	6a 02                	push   $0x2
801061de:	50                   	push   %eax
801061df:	e8 cc fd ff ff       	call   80105fb0 <create>
801061e4:	83 c4 10             	add    $0x10,%esp
801061e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801061ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061ee:	75 75                	jne    80106265 <sys_open+0xdf>
      end_op();
801061f0:	e8 f2 d4 ff ff       	call   801036e7 <end_op>
      return -1;
801061f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061fa:	e9 26 01 00 00       	jmp    80106325 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801061ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106202:	83 ec 0c             	sub    $0xc,%esp
80106205:	50                   	push   %eax
80106206:	e8 ca c3 ff ff       	call   801025d5 <namei>
8010620b:	83 c4 10             	add    $0x10,%esp
8010620e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106211:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106215:	75 0f                	jne    80106226 <sys_open+0xa0>
      end_op();
80106217:	e8 cb d4 ff ff       	call   801036e7 <end_op>
      return -1;
8010621c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106221:	e9 ff 00 00 00       	jmp    80106325 <sys_open+0x19f>
    }
    ilock(ip);
80106226:	83 ec 0c             	sub    $0xc,%esp
80106229:	ff 75 f4             	pushl  -0xc(%ebp)
8010622c:	e8 39 b8 ff ff       	call   80101a6a <ilock>
80106231:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106237:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010623b:	66 83 f8 01          	cmp    $0x1,%ax
8010623f:	75 24                	jne    80106265 <sys_open+0xdf>
80106241:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106244:	85 c0                	test   %eax,%eax
80106246:	74 1d                	je     80106265 <sys_open+0xdf>
      iunlockput(ip);
80106248:	83 ec 0c             	sub    $0xc,%esp
8010624b:	ff 75 f4             	pushl  -0xc(%ebp)
8010624e:	e8 54 ba ff ff       	call   80101ca7 <iunlockput>
80106253:	83 c4 10             	add    $0x10,%esp
      end_op();
80106256:	e8 8c d4 ff ff       	call   801036e7 <end_op>
      return -1;
8010625b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106260:	e9 c0 00 00 00       	jmp    80106325 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106265:	e8 a7 ad ff ff       	call   80101011 <filealloc>
8010626a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010626d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106271:	74 17                	je     8010628a <sys_open+0x104>
80106273:	83 ec 0c             	sub    $0xc,%esp
80106276:	ff 75 f0             	pushl  -0x10(%ebp)
80106279:	e8 07 f7 ff ff       	call   80105985 <fdalloc>
8010627e:	83 c4 10             	add    $0x10,%esp
80106281:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106284:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106288:	79 2e                	jns    801062b8 <sys_open+0x132>
    if(f)
8010628a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010628e:	74 0e                	je     8010629e <sys_open+0x118>
      fileclose(f);
80106290:	83 ec 0c             	sub    $0xc,%esp
80106293:	ff 75 f0             	pushl  -0x10(%ebp)
80106296:	e8 3c ae ff ff       	call   801010d7 <fileclose>
8010629b:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010629e:	83 ec 0c             	sub    $0xc,%esp
801062a1:	ff 75 f4             	pushl  -0xc(%ebp)
801062a4:	e8 fe b9 ff ff       	call   80101ca7 <iunlockput>
801062a9:	83 c4 10             	add    $0x10,%esp
    end_op();
801062ac:	e8 36 d4 ff ff       	call   801036e7 <end_op>
    return -1;
801062b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b6:	eb 6d                	jmp    80106325 <sys_open+0x19f>
  }
  iunlock(ip);
801062b8:	83 ec 0c             	sub    $0xc,%esp
801062bb:	ff 75 f4             	pushl  -0xc(%ebp)
801062be:	e8 be b8 ff ff       	call   80101b81 <iunlock>
801062c3:	83 c4 10             	add    $0x10,%esp
  end_op();
801062c6:	e8 1c d4 ff ff       	call   801036e7 <end_op>

  f->type = FD_INODE;
801062cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ce:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801062d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062da:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801062dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801062e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062ea:	83 e0 01             	and    $0x1,%eax
801062ed:	85 c0                	test   %eax,%eax
801062ef:	0f 94 c0             	sete   %al
801062f2:	89 c2                	mov    %eax,%edx
801062f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f7:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801062fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062fd:	83 e0 01             	and    $0x1,%eax
80106300:	85 c0                	test   %eax,%eax
80106302:	75 0a                	jne    8010630e <sys_open+0x188>
80106304:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106307:	83 e0 02             	and    $0x2,%eax
8010630a:	85 c0                	test   %eax,%eax
8010630c:	74 07                	je     80106315 <sys_open+0x18f>
8010630e:	b8 01 00 00 00       	mov    $0x1,%eax
80106313:	eb 05                	jmp    8010631a <sys_open+0x194>
80106315:	b8 00 00 00 00       	mov    $0x0,%eax
8010631a:	89 c2                	mov    %eax,%edx
8010631c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010631f:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106322:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106325:	c9                   	leave  
80106326:	c3                   	ret    

80106327 <sys_mkdir>:

int
sys_mkdir(void)
{
80106327:	f3 0f 1e fb          	endbr32 
8010632b:	55                   	push   %ebp
8010632c:	89 e5                	mov    %esp,%ebp
8010632e:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106331:	e8 21 d3 ff ff       	call   80103657 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106336:	83 ec 08             	sub    $0x8,%esp
80106339:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010633c:	50                   	push   %eax
8010633d:	6a 00                	push   $0x0
8010633f:	e8 0c f5 ff ff       	call   80105850 <argstr>
80106344:	83 c4 10             	add    $0x10,%esp
80106347:	85 c0                	test   %eax,%eax
80106349:	78 1b                	js     80106366 <sys_mkdir+0x3f>
8010634b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634e:	6a 00                	push   $0x0
80106350:	6a 00                	push   $0x0
80106352:	6a 01                	push   $0x1
80106354:	50                   	push   %eax
80106355:	e8 56 fc ff ff       	call   80105fb0 <create>
8010635a:	83 c4 10             	add    $0x10,%esp
8010635d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106360:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106364:	75 0c                	jne    80106372 <sys_mkdir+0x4b>
    end_op();
80106366:	e8 7c d3 ff ff       	call   801036e7 <end_op>
    return -1;
8010636b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106370:	eb 18                	jmp    8010638a <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106372:	83 ec 0c             	sub    $0xc,%esp
80106375:	ff 75 f4             	pushl  -0xc(%ebp)
80106378:	e8 2a b9 ff ff       	call   80101ca7 <iunlockput>
8010637d:	83 c4 10             	add    $0x10,%esp
  end_op();
80106380:	e8 62 d3 ff ff       	call   801036e7 <end_op>
  return 0;
80106385:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010638a:	c9                   	leave  
8010638b:	c3                   	ret    

8010638c <sys_mknod>:

int
sys_mknod(void)
{
8010638c:	f3 0f 1e fb          	endbr32 
80106390:	55                   	push   %ebp
80106391:	89 e5                	mov    %esp,%ebp
80106393:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106396:	e8 bc d2 ff ff       	call   80103657 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010639b:	83 ec 08             	sub    $0x8,%esp
8010639e:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063a1:	50                   	push   %eax
801063a2:	6a 00                	push   $0x0
801063a4:	e8 a7 f4 ff ff       	call   80105850 <argstr>
801063a9:	83 c4 10             	add    $0x10,%esp
801063ac:	85 c0                	test   %eax,%eax
801063ae:	78 4f                	js     801063ff <sys_mknod+0x73>
     argint(1, &major) < 0 ||
801063b0:	83 ec 08             	sub    $0x8,%esp
801063b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063b6:	50                   	push   %eax
801063b7:	6a 01                	push   $0x1
801063b9:	e8 f5 f3 ff ff       	call   801057b3 <argint>
801063be:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801063c1:	85 c0                	test   %eax,%eax
801063c3:	78 3a                	js     801063ff <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801063c5:	83 ec 08             	sub    $0x8,%esp
801063c8:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063cb:	50                   	push   %eax
801063cc:	6a 02                	push   $0x2
801063ce:	e8 e0 f3 ff ff       	call   801057b3 <argint>
801063d3:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801063d6:	85 c0                	test   %eax,%eax
801063d8:	78 25                	js     801063ff <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801063da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063dd:	0f bf c8             	movswl %ax,%ecx
801063e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063e3:	0f bf d0             	movswl %ax,%edx
801063e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e9:	51                   	push   %ecx
801063ea:	52                   	push   %edx
801063eb:	6a 03                	push   $0x3
801063ed:	50                   	push   %eax
801063ee:	e8 bd fb ff ff       	call   80105fb0 <create>
801063f3:	83 c4 10             	add    $0x10,%esp
801063f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801063f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063fd:	75 0c                	jne    8010640b <sys_mknod+0x7f>
    end_op();
801063ff:	e8 e3 d2 ff ff       	call   801036e7 <end_op>
    return -1;
80106404:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106409:	eb 18                	jmp    80106423 <sys_mknod+0x97>
  }
  iunlockput(ip);
8010640b:	83 ec 0c             	sub    $0xc,%esp
8010640e:	ff 75 f4             	pushl  -0xc(%ebp)
80106411:	e8 91 b8 ff ff       	call   80101ca7 <iunlockput>
80106416:	83 c4 10             	add    $0x10,%esp
  end_op();
80106419:	e8 c9 d2 ff ff       	call   801036e7 <end_op>
  return 0;
8010641e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106423:	c9                   	leave  
80106424:	c3                   	ret    

80106425 <sys_chdir>:

int
sys_chdir(void)
{
80106425:	f3 0f 1e fb          	endbr32 
80106429:	55                   	push   %ebp
8010642a:	89 e5                	mov    %esp,%ebp
8010642c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010642f:	e8 5b dc ff ff       	call   8010408f <myproc>
80106434:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106437:	e8 1b d2 ff ff       	call   80103657 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010643c:	83 ec 08             	sub    $0x8,%esp
8010643f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106442:	50                   	push   %eax
80106443:	6a 00                	push   $0x0
80106445:	e8 06 f4 ff ff       	call   80105850 <argstr>
8010644a:	83 c4 10             	add    $0x10,%esp
8010644d:	85 c0                	test   %eax,%eax
8010644f:	78 18                	js     80106469 <sys_chdir+0x44>
80106451:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106454:	83 ec 0c             	sub    $0xc,%esp
80106457:	50                   	push   %eax
80106458:	e8 78 c1 ff ff       	call   801025d5 <namei>
8010645d:	83 c4 10             	add    $0x10,%esp
80106460:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106463:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106467:	75 0c                	jne    80106475 <sys_chdir+0x50>
    end_op();
80106469:	e8 79 d2 ff ff       	call   801036e7 <end_op>
    return -1;
8010646e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106473:	eb 68                	jmp    801064dd <sys_chdir+0xb8>
  }
  ilock(ip);
80106475:	83 ec 0c             	sub    $0xc,%esp
80106478:	ff 75 f0             	pushl  -0x10(%ebp)
8010647b:	e8 ea b5 ff ff       	call   80101a6a <ilock>
80106480:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106486:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010648a:	66 83 f8 01          	cmp    $0x1,%ax
8010648e:	74 1a                	je     801064aa <sys_chdir+0x85>
    iunlockput(ip);
80106490:	83 ec 0c             	sub    $0xc,%esp
80106493:	ff 75 f0             	pushl  -0x10(%ebp)
80106496:	e8 0c b8 ff ff       	call   80101ca7 <iunlockput>
8010649b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010649e:	e8 44 d2 ff ff       	call   801036e7 <end_op>
    return -1;
801064a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a8:	eb 33                	jmp    801064dd <sys_chdir+0xb8>
  }
  iunlock(ip);
801064aa:	83 ec 0c             	sub    $0xc,%esp
801064ad:	ff 75 f0             	pushl  -0x10(%ebp)
801064b0:	e8 cc b6 ff ff       	call   80101b81 <iunlock>
801064b5:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801064b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064bb:	8b 40 68             	mov    0x68(%eax),%eax
801064be:	83 ec 0c             	sub    $0xc,%esp
801064c1:	50                   	push   %eax
801064c2:	e8 0c b7 ff ff       	call   80101bd3 <iput>
801064c7:	83 c4 10             	add    $0x10,%esp
  end_op();
801064ca:	e8 18 d2 ff ff       	call   801036e7 <end_op>
  curproc->cwd = ip;
801064cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064d5:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801064d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064dd:	c9                   	leave  
801064de:	c3                   	ret    

801064df <sys_exec>:

int
sys_exec(void)
{
801064df:	f3 0f 1e fb          	endbr32 
801064e3:	55                   	push   %ebp
801064e4:	89 e5                	mov    %esp,%ebp
801064e6:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801064ec:	83 ec 08             	sub    $0x8,%esp
801064ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064f2:	50                   	push   %eax
801064f3:	6a 00                	push   $0x0
801064f5:	e8 56 f3 ff ff       	call   80105850 <argstr>
801064fa:	83 c4 10             	add    $0x10,%esp
801064fd:	85 c0                	test   %eax,%eax
801064ff:	78 18                	js     80106519 <sys_exec+0x3a>
80106501:	83 ec 08             	sub    $0x8,%esp
80106504:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010650a:	50                   	push   %eax
8010650b:	6a 01                	push   $0x1
8010650d:	e8 a1 f2 ff ff       	call   801057b3 <argint>
80106512:	83 c4 10             	add    $0x10,%esp
80106515:	85 c0                	test   %eax,%eax
80106517:	79 0a                	jns    80106523 <sys_exec+0x44>
    return -1;
80106519:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651e:	e9 c6 00 00 00       	jmp    801065e9 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106523:	83 ec 04             	sub    $0x4,%esp
80106526:	68 80 00 00 00       	push   $0x80
8010652b:	6a 00                	push   $0x0
8010652d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106533:	50                   	push   %eax
80106534:	e8 26 ef ff ff       	call   8010545f <memset>
80106539:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010653c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106546:	83 f8 1f             	cmp    $0x1f,%eax
80106549:	76 0a                	jbe    80106555 <sys_exec+0x76>
      return -1;
8010654b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106550:	e9 94 00 00 00       	jmp    801065e9 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106558:	c1 e0 02             	shl    $0x2,%eax
8010655b:	89 c2                	mov    %eax,%edx
8010655d:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106563:	01 c2                	add    %eax,%edx
80106565:	83 ec 08             	sub    $0x8,%esp
80106568:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010656e:	50                   	push   %eax
8010656f:	52                   	push   %edx
80106570:	e8 93 f1 ff ff       	call   80105708 <fetchint>
80106575:	83 c4 10             	add    $0x10,%esp
80106578:	85 c0                	test   %eax,%eax
8010657a:	79 07                	jns    80106583 <sys_exec+0xa4>
      return -1;
8010657c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106581:	eb 66                	jmp    801065e9 <sys_exec+0x10a>
    if(uarg == 0){
80106583:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106589:	85 c0                	test   %eax,%eax
8010658b:	75 27                	jne    801065b4 <sys_exec+0xd5>
      argv[i] = 0;
8010658d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106590:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106597:	00 00 00 00 
      break;
8010659b:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010659c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010659f:	83 ec 08             	sub    $0x8,%esp
801065a2:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801065a8:	52                   	push   %edx
801065a9:	50                   	push   %eax
801065aa:	e8 0f a6 ff ff       	call   80100bbe <exec>
801065af:	83 c4 10             	add    $0x10,%esp
801065b2:	eb 35                	jmp    801065e9 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801065b4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801065ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065bd:	c1 e2 02             	shl    $0x2,%edx
801065c0:	01 c2                	add    %eax,%edx
801065c2:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801065c8:	83 ec 08             	sub    $0x8,%esp
801065cb:	52                   	push   %edx
801065cc:	50                   	push   %eax
801065cd:	e8 79 f1 ff ff       	call   8010574b <fetchstr>
801065d2:	83 c4 10             	add    $0x10,%esp
801065d5:	85 c0                	test   %eax,%eax
801065d7:	79 07                	jns    801065e0 <sys_exec+0x101>
      return -1;
801065d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065de:	eb 09                	jmp    801065e9 <sys_exec+0x10a>
  for(i=0;; i++){
801065e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801065e4:	e9 5a ff ff ff       	jmp    80106543 <sys_exec+0x64>
}
801065e9:	c9                   	leave  
801065ea:	c3                   	ret    

801065eb <sys_pipe>:

int
sys_pipe(void)
{
801065eb:	f3 0f 1e fb          	endbr32 
801065ef:	55                   	push   %ebp
801065f0:	89 e5                	mov    %esp,%ebp
801065f2:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801065f5:	83 ec 04             	sub    $0x4,%esp
801065f8:	6a 08                	push   $0x8
801065fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065fd:	50                   	push   %eax
801065fe:	6a 00                	push   $0x0
80106600:	e8 df f1 ff ff       	call   801057e4 <argptr>
80106605:	83 c4 10             	add    $0x10,%esp
80106608:	85 c0                	test   %eax,%eax
8010660a:	79 0a                	jns    80106616 <sys_pipe+0x2b>
    return -1;
8010660c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106611:	e9 ae 00 00 00       	jmp    801066c4 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106616:	83 ec 08             	sub    $0x8,%esp
80106619:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010661c:	50                   	push   %eax
8010661d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106620:	50                   	push   %eax
80106621:	e8 8a d5 ff ff       	call   80103bb0 <pipealloc>
80106626:	83 c4 10             	add    $0x10,%esp
80106629:	85 c0                	test   %eax,%eax
8010662b:	79 0a                	jns    80106637 <sys_pipe+0x4c>
    return -1;
8010662d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106632:	e9 8d 00 00 00       	jmp    801066c4 <sys_pipe+0xd9>
  fd0 = -1;
80106637:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010663e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106641:	83 ec 0c             	sub    $0xc,%esp
80106644:	50                   	push   %eax
80106645:	e8 3b f3 ff ff       	call   80105985 <fdalloc>
8010664a:	83 c4 10             	add    $0x10,%esp
8010664d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106650:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106654:	78 18                	js     8010666e <sys_pipe+0x83>
80106656:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106659:	83 ec 0c             	sub    $0xc,%esp
8010665c:	50                   	push   %eax
8010665d:	e8 23 f3 ff ff       	call   80105985 <fdalloc>
80106662:	83 c4 10             	add    $0x10,%esp
80106665:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106668:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010666c:	79 3e                	jns    801066ac <sys_pipe+0xc1>
    if(fd0 >= 0)
8010666e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106672:	78 13                	js     80106687 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106674:	e8 16 da ff ff       	call   8010408f <myproc>
80106679:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010667c:	83 c2 08             	add    $0x8,%edx
8010667f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106686:	00 
    fileclose(rf);
80106687:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010668a:	83 ec 0c             	sub    $0xc,%esp
8010668d:	50                   	push   %eax
8010668e:	e8 44 aa ff ff       	call   801010d7 <fileclose>
80106693:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106696:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106699:	83 ec 0c             	sub    $0xc,%esp
8010669c:	50                   	push   %eax
8010669d:	e8 35 aa ff ff       	call   801010d7 <fileclose>
801066a2:	83 c4 10             	add    $0x10,%esp
    return -1;
801066a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066aa:	eb 18                	jmp    801066c4 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801066ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066b2:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801066b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066b7:	8d 50 04             	lea    0x4(%eax),%edx
801066ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066bd:	89 02                	mov    %eax,(%edx)
  return 0;
801066bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066c4:	c9                   	leave  
801066c5:	c3                   	ret    

801066c6 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801066c6:	f3 0f 1e fb          	endbr32 
801066ca:	55                   	push   %ebp
801066cb:	89 e5                	mov    %esp,%ebp
801066cd:	83 ec 08             	sub    $0x8,%esp
  return fork();
801066d0:	e8 dd dc ff ff       	call   801043b2 <fork>
}
801066d5:	c9                   	leave  
801066d6:	c3                   	ret    

801066d7 <sys_exit>:

int
sys_exit(void)
{
801066d7:	f3 0f 1e fb          	endbr32 
801066db:	55                   	push   %ebp
801066dc:	89 e5                	mov    %esp,%ebp
801066de:	83 ec 08             	sub    $0x8,%esp
  exit();
801066e1:	e8 49 de ff ff       	call   8010452f <exit>
  return 0;  // not reached
801066e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066eb:	c9                   	leave  
801066ec:	c3                   	ret    

801066ed <sys_wait>:

int
sys_wait(void)
{
801066ed:	f3 0f 1e fb          	endbr32 
801066f1:	55                   	push   %ebp
801066f2:	89 e5                	mov    %esp,%ebp
801066f4:	83 ec 08             	sub    $0x8,%esp
  return wait();
801066f7:	e8 97 e0 ff ff       	call   80104793 <wait>
}
801066fc:	c9                   	leave  
801066fd:	c3                   	ret    

801066fe <sys_kill>:

int
sys_kill(void)
{
801066fe:	f3 0f 1e fb          	endbr32 
80106702:	55                   	push   %ebp
80106703:	89 e5                	mov    %esp,%ebp
80106705:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106708:	83 ec 08             	sub    $0x8,%esp
8010670b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010670e:	50                   	push   %eax
8010670f:	6a 00                	push   $0x0
80106711:	e8 9d f0 ff ff       	call   801057b3 <argint>
80106716:	83 c4 10             	add    $0x10,%esp
80106719:	85 c0                	test   %eax,%eax
8010671b:	79 07                	jns    80106724 <sys_kill+0x26>
    return -1;
8010671d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106722:	eb 0f                	jmp    80106733 <sys_kill+0x35>
  return kill(pid);
80106724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106727:	83 ec 0c             	sub    $0xc,%esp
8010672a:	50                   	push   %eax
8010672b:	e8 23 e6 ff ff       	call   80104d53 <kill>
80106730:	83 c4 10             	add    $0x10,%esp
}
80106733:	c9                   	leave  
80106734:	c3                   	ret    

80106735 <sys_getpid>:

int
sys_getpid(void)
{
80106735:	f3 0f 1e fb          	endbr32 
80106739:	55                   	push   %ebp
8010673a:	89 e5                	mov    %esp,%ebp
8010673c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010673f:	e8 4b d9 ff ff       	call   8010408f <myproc>
80106744:	8b 40 10             	mov    0x10(%eax),%eax
}
80106747:	c9                   	leave  
80106748:	c3                   	ret    

80106749 <sys_sbrk>:

int
sys_sbrk(void)
{
80106749:	f3 0f 1e fb          	endbr32 
8010674d:	55                   	push   %ebp
8010674e:	89 e5                	mov    %esp,%ebp
80106750:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106753:	83 ec 08             	sub    $0x8,%esp
80106756:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106759:	50                   	push   %eax
8010675a:	6a 00                	push   $0x0
8010675c:	e8 52 f0 ff ff       	call   801057b3 <argint>
80106761:	83 c4 10             	add    $0x10,%esp
80106764:	85 c0                	test   %eax,%eax
80106766:	79 07                	jns    8010676f <sys_sbrk+0x26>
    return -1;
80106768:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676d:	eb 27                	jmp    80106796 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010676f:	e8 1b d9 ff ff       	call   8010408f <myproc>
80106774:	8b 00                	mov    (%eax),%eax
80106776:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010677c:	83 ec 0c             	sub    $0xc,%esp
8010677f:	50                   	push   %eax
80106780:	e8 8e db ff ff       	call   80104313 <growproc>
80106785:	83 c4 10             	add    $0x10,%esp
80106788:	85 c0                	test   %eax,%eax
8010678a:	79 07                	jns    80106793 <sys_sbrk+0x4a>
    return -1;
8010678c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106791:	eb 03                	jmp    80106796 <sys_sbrk+0x4d>
  return addr;
80106793:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106796:	c9                   	leave  
80106797:	c3                   	ret    

80106798 <sys_sleep>:

int
sys_sleep(void)
{
80106798:	f3 0f 1e fb          	endbr32 
8010679c:	55                   	push   %ebp
8010679d:	89 e5                	mov    %esp,%ebp
8010679f:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801067a2:	83 ec 08             	sub    $0x8,%esp
801067a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067a8:	50                   	push   %eax
801067a9:	6a 00                	push   $0x0
801067ab:	e8 03 f0 ff ff       	call   801057b3 <argint>
801067b0:	83 c4 10             	add    $0x10,%esp
801067b3:	85 c0                	test   %eax,%eax
801067b5:	79 07                	jns    801067be <sys_sleep+0x26>
    return -1;
801067b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bc:	eb 76                	jmp    80106834 <sys_sleep+0x9c>
  acquire(&tickslock);
801067be:	83 ec 0c             	sub    $0xc,%esp
801067c1:	68 80 a9 11 80       	push   $0x8011a980
801067c6:	e8 05 ea ff ff       	call   801051d0 <acquire>
801067cb:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801067ce:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
801067d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801067d6:	eb 38                	jmp    80106810 <sys_sleep+0x78>
    if(myproc()->killed){
801067d8:	e8 b2 d8 ff ff       	call   8010408f <myproc>
801067dd:	8b 40 24             	mov    0x24(%eax),%eax
801067e0:	85 c0                	test   %eax,%eax
801067e2:	74 17                	je     801067fb <sys_sleep+0x63>
      release(&tickslock);
801067e4:	83 ec 0c             	sub    $0xc,%esp
801067e7:	68 80 a9 11 80       	push   $0x8011a980
801067ec:	e8 51 ea ff ff       	call   80105242 <release>
801067f1:	83 c4 10             	add    $0x10,%esp
      return -1;
801067f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f9:	eb 39                	jmp    80106834 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801067fb:	83 ec 08             	sub    $0x8,%esp
801067fe:	68 80 a9 11 80       	push   $0x8011a980
80106803:	68 c0 b1 11 80       	push   $0x8011b1c0
80106808:	e8 19 e4 ff ff       	call   80104c26 <sleep>
8010680d:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106810:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
80106815:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106818:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010681b:	39 d0                	cmp    %edx,%eax
8010681d:	72 b9                	jb     801067d8 <sys_sleep+0x40>
  }
  release(&tickslock);
8010681f:	83 ec 0c             	sub    $0xc,%esp
80106822:	68 80 a9 11 80       	push   $0x8011a980
80106827:	e8 16 ea ff ff       	call   80105242 <release>
8010682c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010682f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106834:	c9                   	leave  
80106835:	c3                   	ret    

80106836 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106836:	f3 0f 1e fb          	endbr32 
8010683a:	55                   	push   %ebp
8010683b:	89 e5                	mov    %esp,%ebp
8010683d:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106840:	83 ec 0c             	sub    $0xc,%esp
80106843:	68 80 a9 11 80       	push   $0x8011a980
80106848:	e8 83 e9 ff ff       	call   801051d0 <acquire>
8010684d:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106850:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
80106855:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106858:	83 ec 0c             	sub    $0xc,%esp
8010685b:	68 80 a9 11 80       	push   $0x8011a980
80106860:	e8 dd e9 ff ff       	call   80105242 <release>
80106865:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106868:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010686b:	c9                   	leave  
8010686c:	c3                   	ret    

8010686d <sys_exit2>:

int
sys_exit2(void)
{
8010686d:	f3 0f 1e fb          	endbr32 
80106871:	55                   	push   %ebp
80106872:	89 e5                	mov    %esp,%ebp
80106874:	83 ec 18             	sub    $0x18,%esp
  int status;
  if(argint(0, &status) < 0)
80106877:	83 ec 08             	sub    $0x8,%esp
8010687a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010687d:	50                   	push   %eax
8010687e:	6a 00                	push   $0x0
80106880:	e8 2e ef ff ff       	call   801057b3 <argint>
80106885:	83 c4 10             	add    $0x10,%esp
80106888:	85 c0                	test   %eax,%eax
8010688a:	79 07                	jns    80106893 <sys_exit2+0x26>
    return -1; 
8010688c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106891:	eb 15                	jmp    801068a8 <sys_exit2+0x3b>

  myproc()->xstate = status;
80106893:	e8 f7 d7 ff ff       	call   8010408f <myproc>
80106898:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010689b:	89 50 7c             	mov    %edx,0x7c(%eax)
  exit();
8010689e:	e8 8c dc ff ff       	call   8010452f <exit>
  return 0;
801068a3:	b8 00 00 00 00       	mov    $0x0,%eax
}	
801068a8:	c9                   	leave  
801068a9:	c3                   	ret    

801068aa <sys_wait2>:

extern int wait2(int *status);

int sys_wait2(void) 
{
801068aa:	f3 0f 1e fb          	endbr32 
801068ae:	55                   	push   %ebp
801068af:	89 e5                	mov    %esp,%ebp
801068b1:	83 ec 18             	sub    $0x18,%esp
  int *status;
  if(argptr(0, (void *)&status, sizeof(*status)) < 0)
801068b4:	83 ec 04             	sub    $0x4,%esp
801068b7:	6a 04                	push   $0x4
801068b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068bc:	50                   	push   %eax
801068bd:	6a 00                	push   $0x0
801068bf:	e8 20 ef ff ff       	call   801057e4 <argptr>
801068c4:	83 c4 10             	add    $0x10,%esp
801068c7:	85 c0                	test   %eax,%eax
801068c9:	79 07                	jns    801068d2 <sys_wait2+0x28>
    return -1;
801068cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d0:	eb 0f                	jmp    801068e1 <sys_wait2+0x37>
  return wait2(status);
801068d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d5:	83 ec 0c             	sub    $0xc,%esp
801068d8:	50                   	push   %eax
801068d9:	e8 dc df ff ff       	call   801048ba <wait2>
801068de:	83 c4 10             	add    $0x10,%esp
}
801068e1:	c9                   	leave  
801068e2:	c3                   	ret    

801068e3 <sys_uthread_init>:

int
sys_uthread_init(void)
{
801068e3:	f3 0f 1e fb          	endbr32 
801068e7:	55                   	push   %ebp
801068e8:	89 e5                	mov    %esp,%ebp
801068ea:	83 ec 18             	sub    $0x18,%esp
    struct proc* p;
    int func;

    if (argint(0, &func) < 0)
801068ed:	83 ec 08             	sub    $0x8,%esp
801068f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068f3:	50                   	push   %eax
801068f4:	6a 00                	push   $0x0
801068f6:	e8 b8 ee ff ff       	call   801057b3 <argint>
801068fb:	83 c4 10             	add    $0x10,%esp
801068fe:	85 c0                	test   %eax,%eax
80106900:	79 07                	jns    80106909 <sys_uthread_init+0x26>
        return -1;
80106902:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106907:	eb 1b                	jmp    80106924 <sys_uthread_init+0x41>

    p = myproc();
80106909:	e8 81 d7 ff ff       	call   8010408f <myproc>
8010690e:	89 45 f4             	mov    %eax,-0xc(%ebp)

    p->scheduler = (uint)func;
80106911:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106914:	89 c2                	mov    %eax,%edx
80106916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106919:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

    return 0;
8010691f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106924:	c9                   	leave  
80106925:	c3                   	ret    

80106926 <sys_printpt>:

int sys_printpt(void) {
80106926:	f3 0f 1e fb          	endbr32 
8010692a:	55                   	push   %ebp
8010692b:	89 e5                	mov    %esp,%ebp
8010692d:	83 ec 18             	sub    $0x18,%esp
    int pid;
    if(argint(0, &pid) < 0)
80106930:	83 ec 08             	sub    $0x8,%esp
80106933:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106936:	50                   	push   %eax
80106937:	6a 00                	push   $0x0
80106939:	e8 75 ee ff ff       	call   801057b3 <argint>
8010693e:	83 c4 10             	add    $0x10,%esp
80106941:	85 c0                	test   %eax,%eax
80106943:	79 07                	jns    8010694c <sys_printpt+0x26>
        return -1;
80106945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010694a:	eb 14                	jmp    80106960 <sys_printpt+0x3a>
    printpt(pid);
8010694c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010694f:	83 ec 0c             	sub    $0xc,%esp
80106952:	50                   	push   %eax
80106953:	e8 87 e5 ff ff       	call   80104edf <printpt>
80106958:	83 c4 10             	add    $0x10,%esp
    return 0;
8010695b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106960:	c9                   	leave  
80106961:	c3                   	ret    

80106962 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106962:	1e                   	push   %ds
  pushl %es
80106963:	06                   	push   %es
  pushl %fs
80106964:	0f a0                	push   %fs
  pushl %gs
80106966:	0f a8                	push   %gs
  pushal
80106968:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106969:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010696d:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010696f:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106971:	54                   	push   %esp
  call trap
80106972:	e8 df 01 00 00       	call   80106b56 <trap>
  addl $4, %esp
80106977:	83 c4 04             	add    $0x4,%esp

8010697a <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010697a:	61                   	popa   
  popl %gs
8010697b:	0f a9                	pop    %gs
  popl %fs
8010697d:	0f a1                	pop    %fs
  popl %es
8010697f:	07                   	pop    %es
  popl %ds
80106980:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106981:	83 c4 08             	add    $0x8,%esp
  iret
80106984:	cf                   	iret   

80106985 <lidt>:
{
80106985:	55                   	push   %ebp
80106986:	89 e5                	mov    %esp,%ebp
80106988:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010698b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010698e:	83 e8 01             	sub    $0x1,%eax
80106991:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106995:	8b 45 08             	mov    0x8(%ebp),%eax
80106998:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010699c:	8b 45 08             	mov    0x8(%ebp),%eax
8010699f:	c1 e8 10             	shr    $0x10,%eax
801069a2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801069a6:	8d 45 fa             	lea    -0x6(%ebp),%eax
801069a9:	0f 01 18             	lidtl  (%eax)
}
801069ac:	90                   	nop
801069ad:	c9                   	leave  
801069ae:	c3                   	ret    

801069af <rcr2>:

static inline uint
rcr2(void)
{
801069af:	55                   	push   %ebp
801069b0:	89 e5                	mov    %esp,%ebp
801069b2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801069b5:	0f 20 d0             	mov    %cr2,%eax
801069b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801069bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801069be:	c9                   	leave  
801069bf:	c3                   	ret    

801069c0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801069c0:	f3 0f 1e fb          	endbr32 
801069c4:	55                   	push   %ebp
801069c5:	89 e5                	mov    %esp,%ebp
801069c7:	83 ec 18             	sub    $0x18,%esp
    int i;

    for (i = 0; i < 256; i++)
801069ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801069d1:	e9 c3 00 00 00       	jmp    80106a99 <tvinit+0xd9>
        SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
801069d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d9:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
801069e0:	89 c2                	mov    %eax,%edx
801069e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e5:	66 89 14 c5 c0 a9 11 	mov    %dx,-0x7fee5640(,%eax,8)
801069ec:	80 
801069ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f0:	66 c7 04 c5 c2 a9 11 	movw   $0x8,-0x7fee563e(,%eax,8)
801069f7:	80 08 00 
801069fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069fd:	0f b6 14 c5 c4 a9 11 	movzbl -0x7fee563c(,%eax,8),%edx
80106a04:	80 
80106a05:	83 e2 e0             	and    $0xffffffe0,%edx
80106a08:	88 14 c5 c4 a9 11 80 	mov    %dl,-0x7fee563c(,%eax,8)
80106a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a12:	0f b6 14 c5 c4 a9 11 	movzbl -0x7fee563c(,%eax,8),%edx
80106a19:	80 
80106a1a:	83 e2 1f             	and    $0x1f,%edx
80106a1d:	88 14 c5 c4 a9 11 80 	mov    %dl,-0x7fee563c(,%eax,8)
80106a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a27:	0f b6 14 c5 c5 a9 11 	movzbl -0x7fee563b(,%eax,8),%edx
80106a2e:	80 
80106a2f:	83 e2 f0             	and    $0xfffffff0,%edx
80106a32:	83 ca 0e             	or     $0xe,%edx
80106a35:	88 14 c5 c5 a9 11 80 	mov    %dl,-0x7fee563b(,%eax,8)
80106a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a3f:	0f b6 14 c5 c5 a9 11 	movzbl -0x7fee563b(,%eax,8),%edx
80106a46:	80 
80106a47:	83 e2 ef             	and    $0xffffffef,%edx
80106a4a:	88 14 c5 c5 a9 11 80 	mov    %dl,-0x7fee563b(,%eax,8)
80106a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a54:	0f b6 14 c5 c5 a9 11 	movzbl -0x7fee563b(,%eax,8),%edx
80106a5b:	80 
80106a5c:	83 e2 9f             	and    $0xffffff9f,%edx
80106a5f:	88 14 c5 c5 a9 11 80 	mov    %dl,-0x7fee563b(,%eax,8)
80106a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a69:	0f b6 14 c5 c5 a9 11 	movzbl -0x7fee563b(,%eax,8),%edx
80106a70:	80 
80106a71:	83 ca 80             	or     $0xffffff80,%edx
80106a74:	88 14 c5 c5 a9 11 80 	mov    %dl,-0x7fee563b(,%eax,8)
80106a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a7e:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106a85:	c1 e8 10             	shr    $0x10,%eax
80106a88:	89 c2                	mov    %eax,%edx
80106a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a8d:	66 89 14 c5 c6 a9 11 	mov    %dx,-0x7fee563a(,%eax,8)
80106a94:	80 
    for (i = 0; i < 256; i++)
80106a95:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a99:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106aa0:	0f 8e 30 ff ff ff    	jle    801069d6 <tvinit+0x16>
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
80106aa6:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106aab:	66 a3 c0 ab 11 80    	mov    %ax,0x8011abc0
80106ab1:	66 c7 05 c2 ab 11 80 	movw   $0x8,0x8011abc2
80106ab8:	08 00 
80106aba:	0f b6 05 c4 ab 11 80 	movzbl 0x8011abc4,%eax
80106ac1:	83 e0 e0             	and    $0xffffffe0,%eax
80106ac4:	a2 c4 ab 11 80       	mov    %al,0x8011abc4
80106ac9:	0f b6 05 c4 ab 11 80 	movzbl 0x8011abc4,%eax
80106ad0:	83 e0 1f             	and    $0x1f,%eax
80106ad3:	a2 c4 ab 11 80       	mov    %al,0x8011abc4
80106ad8:	0f b6 05 c5 ab 11 80 	movzbl 0x8011abc5,%eax
80106adf:	83 c8 0f             	or     $0xf,%eax
80106ae2:	a2 c5 ab 11 80       	mov    %al,0x8011abc5
80106ae7:	0f b6 05 c5 ab 11 80 	movzbl 0x8011abc5,%eax
80106aee:	83 e0 ef             	and    $0xffffffef,%eax
80106af1:	a2 c5 ab 11 80       	mov    %al,0x8011abc5
80106af6:	0f b6 05 c5 ab 11 80 	movzbl 0x8011abc5,%eax
80106afd:	83 c8 60             	or     $0x60,%eax
80106b00:	a2 c5 ab 11 80       	mov    %al,0x8011abc5
80106b05:	0f b6 05 c5 ab 11 80 	movzbl 0x8011abc5,%eax
80106b0c:	83 c8 80             	or     $0xffffff80,%eax
80106b0f:	a2 c5 ab 11 80       	mov    %al,0x8011abc5
80106b14:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106b19:	c1 e8 10             	shr    $0x10,%eax
80106b1c:	66 a3 c6 ab 11 80    	mov    %ax,0x8011abc6

    initlock(&tickslock, "time");
80106b22:	83 ec 08             	sub    $0x8,%esp
80106b25:	68 9c b2 10 80       	push   $0x8010b29c
80106b2a:	68 80 a9 11 80       	push   $0x8011a980
80106b2f:	e8 76 e6 ff ff       	call   801051aa <initlock>
80106b34:	83 c4 10             	add    $0x10,%esp
}
80106b37:	90                   	nop
80106b38:	c9                   	leave  
80106b39:	c3                   	ret    

80106b3a <idtinit>:

void
idtinit(void)
{
80106b3a:	f3 0f 1e fb          	endbr32 
80106b3e:	55                   	push   %ebp
80106b3f:	89 e5                	mov    %esp,%ebp
    lidt(idt, sizeof(idt));
80106b41:	68 00 08 00 00       	push   $0x800
80106b46:	68 c0 a9 11 80       	push   $0x8011a9c0
80106b4b:	e8 35 fe ff ff       	call   80106985 <lidt>
80106b50:	83 c4 08             	add    $0x8,%esp
}
80106b53:	90                   	nop
80106b54:	c9                   	leave  
80106b55:	c3                   	ret    

80106b56 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe* tf)
{
80106b56:	f3 0f 1e fb          	endbr32 
80106b5a:	55                   	push   %ebp
80106b5b:	89 e5                	mov    %esp,%ebp
80106b5d:	57                   	push   %edi
80106b5e:	56                   	push   %esi
80106b5f:	53                   	push   %ebx
80106b60:	83 ec 2c             	sub    $0x2c,%esp
    if (tf->trapno == T_SYSCALL) {
80106b63:	8b 45 08             	mov    0x8(%ebp),%eax
80106b66:	8b 40 30             	mov    0x30(%eax),%eax
80106b69:	83 f8 40             	cmp    $0x40,%eax
80106b6c:	75 3b                	jne    80106ba9 <trap+0x53>
        if (myproc()->killed)
80106b6e:	e8 1c d5 ff ff       	call   8010408f <myproc>
80106b73:	8b 40 24             	mov    0x24(%eax),%eax
80106b76:	85 c0                	test   %eax,%eax
80106b78:	74 05                	je     80106b7f <trap+0x29>
            exit();
80106b7a:	e8 b0 d9 ff ff       	call   8010452f <exit>
        myproc()->tf = tf;
80106b7f:	e8 0b d5 ff ff       	call   8010408f <myproc>
80106b84:	8b 55 08             	mov    0x8(%ebp),%edx
80106b87:	89 50 18             	mov    %edx,0x18(%eax)
        syscall();
80106b8a:	e8 fc ec ff ff       	call   8010588b <syscall>
        if (myproc()->killed)
80106b8f:	e8 fb d4 ff ff       	call   8010408f <myproc>
80106b94:	8b 40 24             	mov    0x24(%eax),%eax
80106b97:	85 c0                	test   %eax,%eax
80106b99:	0f 84 af 02 00 00    	je     80106e4e <trap+0x2f8>
            exit();
80106b9f:	e8 8b d9 ff ff       	call   8010452f <exit>
        return;
80106ba4:	e9 a5 02 00 00       	jmp    80106e4e <trap+0x2f8>
    }

    switch (tf->trapno) {
80106ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80106bac:	8b 40 30             	mov    0x30(%eax),%eax
80106baf:	83 e8 0e             	sub    $0xe,%eax
80106bb2:	83 f8 31             	cmp    $0x31,%eax
80106bb5:	0f 87 5e 01 00 00    	ja     80106d19 <trap+0x1c3>
80106bbb:	8b 04 85 04 b4 10 80 	mov    -0x7fef4bfc(,%eax,4),%eax
80106bc2:	3e ff e0             	notrack jmp *%eax
    case T_IRQ0 + IRQ_TIMER:
        if (cpuid() == 0) {
80106bc5:	e8 2a d4 ff ff       	call   80103ff4 <cpuid>
80106bca:	85 c0                	test   %eax,%eax
80106bcc:	75 3d                	jne    80106c0b <trap+0xb5>
            acquire(&tickslock);
80106bce:	83 ec 0c             	sub    $0xc,%esp
80106bd1:	68 80 a9 11 80       	push   $0x8011a980
80106bd6:	e8 f5 e5 ff ff       	call   801051d0 <acquire>
80106bdb:	83 c4 10             	add    $0x10,%esp
            ticks++;
80106bde:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
80106be3:	83 c0 01             	add    $0x1,%eax
80106be6:	a3 c0 b1 11 80       	mov    %eax,0x8011b1c0
            wakeup(&ticks);
80106beb:	83 ec 0c             	sub    $0xc,%esp
80106bee:	68 c0 b1 11 80       	push   $0x8011b1c0
80106bf3:	e8 20 e1 ff ff       	call   80104d18 <wakeup>
80106bf8:	83 c4 10             	add    $0x10,%esp
            release(&tickslock);
80106bfb:	83 ec 0c             	sub    $0xc,%esp
80106bfe:	68 80 a9 11 80       	push   $0x8011a980
80106c03:	e8 3a e6 ff ff       	call   80105242 <release>
80106c08:	83 c4 10             	add    $0x10,%esp
        }
        lapiceoi();
80106c0b:	e8 fb c4 ff ff       	call   8010310b <lapiceoi>
        break;
80106c10:	e9 b9 01 00 00       	jmp    80106dce <trap+0x278>
    case T_IRQ0 + IRQ_IDE:
        ideintr();
80106c15:	e8 08 bd ff ff       	call   80102922 <ideintr>
        lapiceoi();
80106c1a:	e8 ec c4 ff ff       	call   8010310b <lapiceoi>
        break;
80106c1f:	e9 aa 01 00 00       	jmp    80106dce <trap+0x278>
    case T_IRQ0 + IRQ_IDE + 1:
        // Bochs generates spurious IDE1 interrupts.
        break;
    case T_IRQ0 + IRQ_KBD:
        kbdintr();
80106c24:	e8 18 c3 ff ff       	call   80102f41 <kbdintr>
        lapiceoi();
80106c29:	e8 dd c4 ff ff       	call   8010310b <lapiceoi>
        break;
80106c2e:	e9 9b 01 00 00       	jmp    80106dce <trap+0x278>
    case T_IRQ0 + IRQ_COM1:
        uartintr();
80106c33:	e8 f8 03 00 00       	call   80107030 <uartintr>
        lapiceoi();
80106c38:	e8 ce c4 ff ff       	call   8010310b <lapiceoi>
        break;
80106c3d:	e9 8c 01 00 00       	jmp    80106dce <trap+0x278>
    case T_IRQ0 + 7:
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c42:	8b 45 08             	mov    0x8(%ebp),%eax
80106c45:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106c48:	8b 45 08             	mov    0x8(%ebp),%eax
80106c4b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c4f:	0f b7 d8             	movzwl %ax,%ebx
80106c52:	e8 9d d3 ff ff       	call   80103ff4 <cpuid>
80106c57:	56                   	push   %esi
80106c58:	53                   	push   %ebx
80106c59:	50                   	push   %eax
80106c5a:	68 a4 b2 10 80       	push   $0x8010b2a4
80106c5f:	e8 a8 97 ff ff       	call   8010040c <cprintf>
80106c64:	83 c4 10             	add    $0x10,%esp
        lapiceoi();
80106c67:	e8 9f c4 ff ff       	call   8010310b <lapiceoi>
        break;
80106c6c:	e9 5d 01 00 00       	jmp    80106dce <trap+0x278>

    case T_PGFLT:;
        uint f = rcr2();
80106c71:	e8 39 fd ff ff       	call   801069af <rcr2>
80106c76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (f > KERNBASE) {
80106c79:	81 7d e4 00 00 00 80 	cmpl   $0x80000000,-0x1c(%ebp)
80106c80:	76 15                	jbe    80106c97 <trap+0x141>
            cprintf("from trap access > KERNBASE");
80106c82:	83 ec 0c             	sub    $0xc,%esp
80106c85:	68 c8 b2 10 80       	push   $0x8010b2c8
80106c8a:	e8 7d 97 ff ff       	call   8010040c <cprintf>
80106c8f:	83 c4 10             	add    $0x10,%esp
            exit();
80106c92:	e8 98 d8 ff ff       	call   8010452f <exit>
        }
        f = PGROUNDDOWN(f);
80106c97:	81 65 e4 00 f0 ff ff 	andl   $0xfffff000,-0x1c(%ebp)
        if (allocuvm(myproc()->pgdir, f, f + PGSIZE) == 0) {
80106c9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ca1:	8d 98 00 10 00 00    	lea    0x1000(%eax),%ebx
80106ca7:	e8 e3 d3 ff ff       	call   8010408f <myproc>
80106cac:	8b 40 04             	mov    0x4(%eax),%eax
80106caf:	83 ec 04             	sub    $0x4,%esp
80106cb2:	53                   	push   %ebx
80106cb3:	ff 75 e4             	pushl  -0x1c(%ebp)
80106cb6:	50                   	push   %eax
80106cb7:	e8 96 16 00 00       	call   80108352 <allocuvm>
80106cbc:	83 c4 10             	add    $0x10,%esp
80106cbf:	85 c0                	test   %eax,%eax
80106cc1:	75 21                	jne    80106ce4 <trap+0x18e>
            cprintf("case T_PGFLT from trap.c: allocuvm failed. Number of current allocated pages: %d\n", myproc()->stack_alloc);
80106cc3:	e8 c7 d3 ff ff       	call   8010408f <myproc>
80106cc8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106cce:	83 ec 08             	sub    $0x8,%esp
80106cd1:	50                   	push   %eax
80106cd2:	68 e4 b2 10 80       	push   $0x8010b2e4
80106cd7:	e8 30 97 ff ff       	call   8010040c <cprintf>
80106cdc:	83 c4 10             	add    $0x10,%esp
            exit();
80106cdf:	e8 4b d8 ff ff       	call   8010452f <exit>
        }
        myproc()->stack_alloc++;
80106ce4:	e8 a6 d3 ff ff       	call   8010408f <myproc>
80106ce9:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80106cef:	83 c2 01             	add    $0x1,%edx
80106cf2:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
        cprintf("case T_PGFLT from trap.c: allocuvm succeeded. Number of pages allocated: %d\n", myproc()->stack_alloc);
80106cf8:	e8 92 d3 ff ff       	call   8010408f <myproc>
80106cfd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106d03:	83 ec 08             	sub    $0x8,%esp
80106d06:	50                   	push   %eax
80106d07:	68 38 b3 10 80       	push   $0x8010b338
80106d0c:	e8 fb 96 ff ff       	call   8010040c <cprintf>
80106d11:	83 c4 10             	add    $0x10,%esp
        break;
80106d14:	e9 b5 00 00 00       	jmp    80106dce <trap+0x278>

        //PAGEBREAK: 13
    default:
        if (myproc() == 0 || (tf->cs & 3) == 0) {
80106d19:	e8 71 d3 ff ff       	call   8010408f <myproc>
80106d1e:	85 c0                	test   %eax,%eax
80106d20:	74 11                	je     80106d33 <trap+0x1dd>
80106d22:	8b 45 08             	mov    0x8(%ebp),%eax
80106d25:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d29:	0f b7 c0             	movzwl %ax,%eax
80106d2c:	83 e0 03             	and    $0x3,%eax
80106d2f:	85 c0                	test   %eax,%eax
80106d31:	75 39                	jne    80106d6c <trap+0x216>
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106d33:	e8 77 fc ff ff       	call   801069af <rcr2>
80106d38:	89 c3                	mov    %eax,%ebx
80106d3a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d3d:	8b 70 38             	mov    0x38(%eax),%esi
80106d40:	e8 af d2 ff ff       	call   80103ff4 <cpuid>
80106d45:	8b 55 08             	mov    0x8(%ebp),%edx
80106d48:	8b 52 30             	mov    0x30(%edx),%edx
80106d4b:	83 ec 0c             	sub    $0xc,%esp
80106d4e:	53                   	push   %ebx
80106d4f:	56                   	push   %esi
80106d50:	50                   	push   %eax
80106d51:	52                   	push   %edx
80106d52:	68 88 b3 10 80       	push   $0x8010b388
80106d57:	e8 b0 96 ff ff       	call   8010040c <cprintf>
80106d5c:	83 c4 20             	add    $0x20,%esp
                tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
80106d5f:	83 ec 0c             	sub    $0xc,%esp
80106d62:	68 ba b3 10 80       	push   $0x8010b3ba
80106d67:	e8 59 98 ff ff       	call   801005c5 <panic>
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d6c:	e8 3e fc ff ff       	call   801069af <rcr2>
80106d71:	89 c6                	mov    %eax,%esi
80106d73:	8b 45 08             	mov    0x8(%ebp),%eax
80106d76:	8b 40 38             	mov    0x38(%eax),%eax
80106d79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106d7c:	e8 73 d2 ff ff       	call   80103ff4 <cpuid>
80106d81:	89 c3                	mov    %eax,%ebx
80106d83:	8b 45 08             	mov    0x8(%ebp),%eax
80106d86:	8b 48 34             	mov    0x34(%eax),%ecx
80106d89:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80106d8f:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106d92:	e8 f8 d2 ff ff       	call   8010408f <myproc>
80106d97:	8d 50 6c             	lea    0x6c(%eax),%edx
80106d9a:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106d9d:	e8 ed d2 ff ff       	call   8010408f <myproc>
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106da2:	8b 40 10             	mov    0x10(%eax),%eax
80106da5:	56                   	push   %esi
80106da6:	ff 75 d4             	pushl  -0x2c(%ebp)
80106da9:	53                   	push   %ebx
80106daa:	ff 75 d0             	pushl  -0x30(%ebp)
80106dad:	57                   	push   %edi
80106dae:	ff 75 cc             	pushl  -0x34(%ebp)
80106db1:	50                   	push   %eax
80106db2:	68 c0 b3 10 80       	push   $0x8010b3c0
80106db7:	e8 50 96 ff ff       	call   8010040c <cprintf>
80106dbc:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
80106dbf:	e8 cb d2 ff ff       	call   8010408f <myproc>
80106dc4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106dcb:	eb 01                	jmp    80106dce <trap+0x278>
        break;
80106dcd:	90                   	nop
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106dce:	e8 bc d2 ff ff       	call   8010408f <myproc>
80106dd3:	85 c0                	test   %eax,%eax
80106dd5:	74 23                	je     80106dfa <trap+0x2a4>
80106dd7:	e8 b3 d2 ff ff       	call   8010408f <myproc>
80106ddc:	8b 40 24             	mov    0x24(%eax),%eax
80106ddf:	85 c0                	test   %eax,%eax
80106de1:	74 17                	je     80106dfa <trap+0x2a4>
80106de3:	8b 45 08             	mov    0x8(%ebp),%eax
80106de6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106dea:	0f b7 c0             	movzwl %ax,%eax
80106ded:	83 e0 03             	and    $0x3,%eax
80106df0:	83 f8 03             	cmp    $0x3,%eax
80106df3:	75 05                	jne    80106dfa <trap+0x2a4>
        exit();
80106df5:	e8 35 d7 ff ff       	call   8010452f <exit>

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
80106dfa:	e8 90 d2 ff ff       	call   8010408f <myproc>
80106dff:	85 c0                	test   %eax,%eax
80106e01:	74 1d                	je     80106e20 <trap+0x2ca>
80106e03:	e8 87 d2 ff ff       	call   8010408f <myproc>
80106e08:	8b 40 0c             	mov    0xc(%eax),%eax
80106e0b:	83 f8 04             	cmp    $0x4,%eax
80106e0e:	75 10                	jne    80106e20 <trap+0x2ca>
        tf->trapno == T_IRQ0 + IRQ_TIMER)
80106e10:	8b 45 08             	mov    0x8(%ebp),%eax
80106e13:	8b 40 30             	mov    0x30(%eax),%eax
    if (myproc() && myproc()->state == RUNNING &&
80106e16:	83 f8 20             	cmp    $0x20,%eax
80106e19:	75 05                	jne    80106e20 <trap+0x2ca>
        yield();
80106e1b:	e8 7e dd ff ff       	call   80104b9e <yield>

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106e20:	e8 6a d2 ff ff       	call   8010408f <myproc>
80106e25:	85 c0                	test   %eax,%eax
80106e27:	74 26                	je     80106e4f <trap+0x2f9>
80106e29:	e8 61 d2 ff ff       	call   8010408f <myproc>
80106e2e:	8b 40 24             	mov    0x24(%eax),%eax
80106e31:	85 c0                	test   %eax,%eax
80106e33:	74 1a                	je     80106e4f <trap+0x2f9>
80106e35:	8b 45 08             	mov    0x8(%ebp),%eax
80106e38:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e3c:	0f b7 c0             	movzwl %ax,%eax
80106e3f:	83 e0 03             	and    $0x3,%eax
80106e42:	83 f8 03             	cmp    $0x3,%eax
80106e45:	75 08                	jne    80106e4f <trap+0x2f9>
        exit();
80106e47:	e8 e3 d6 ff ff       	call   8010452f <exit>
80106e4c:	eb 01                	jmp    80106e4f <trap+0x2f9>
        return;
80106e4e:	90                   	nop
}
80106e4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e52:	5b                   	pop    %ebx
80106e53:	5e                   	pop    %esi
80106e54:	5f                   	pop    %edi
80106e55:	5d                   	pop    %ebp
80106e56:	c3                   	ret    

80106e57 <inb>:
{
80106e57:	55                   	push   %ebp
80106e58:	89 e5                	mov    %esp,%ebp
80106e5a:	83 ec 14             	sub    $0x14,%esp
80106e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80106e60:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106e64:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106e68:	89 c2                	mov    %eax,%edx
80106e6a:	ec                   	in     (%dx),%al
80106e6b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106e6e:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106e72:	c9                   	leave  
80106e73:	c3                   	ret    

80106e74 <outb>:
{
80106e74:	55                   	push   %ebp
80106e75:	89 e5                	mov    %esp,%ebp
80106e77:	83 ec 08             	sub    $0x8,%esp
80106e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80106e7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e80:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106e84:	89 d0                	mov    %edx,%eax
80106e86:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106e89:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106e8d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106e91:	ee                   	out    %al,(%dx)
}
80106e92:	90                   	nop
80106e93:	c9                   	leave  
80106e94:	c3                   	ret    

80106e95 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106e95:	f3 0f 1e fb          	endbr32 
80106e99:	55                   	push   %ebp
80106e9a:	89 e5                	mov    %esp,%ebp
80106e9c:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106e9f:	6a 00                	push   $0x0
80106ea1:	68 fa 03 00 00       	push   $0x3fa
80106ea6:	e8 c9 ff ff ff       	call   80106e74 <outb>
80106eab:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106eae:	68 80 00 00 00       	push   $0x80
80106eb3:	68 fb 03 00 00       	push   $0x3fb
80106eb8:	e8 b7 ff ff ff       	call   80106e74 <outb>
80106ebd:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106ec0:	6a 0c                	push   $0xc
80106ec2:	68 f8 03 00 00       	push   $0x3f8
80106ec7:	e8 a8 ff ff ff       	call   80106e74 <outb>
80106ecc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106ecf:	6a 00                	push   $0x0
80106ed1:	68 f9 03 00 00       	push   $0x3f9
80106ed6:	e8 99 ff ff ff       	call   80106e74 <outb>
80106edb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ede:	6a 03                	push   $0x3
80106ee0:	68 fb 03 00 00       	push   $0x3fb
80106ee5:	e8 8a ff ff ff       	call   80106e74 <outb>
80106eea:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106eed:	6a 00                	push   $0x0
80106eef:	68 fc 03 00 00       	push   $0x3fc
80106ef4:	e8 7b ff ff ff       	call   80106e74 <outb>
80106ef9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106efc:	6a 01                	push   $0x1
80106efe:	68 f9 03 00 00       	push   $0x3f9
80106f03:	e8 6c ff ff ff       	call   80106e74 <outb>
80106f08:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106f0b:	68 fd 03 00 00       	push   $0x3fd
80106f10:	e8 42 ff ff ff       	call   80106e57 <inb>
80106f15:	83 c4 04             	add    $0x4,%esp
80106f18:	3c ff                	cmp    $0xff,%al
80106f1a:	74 61                	je     80106f7d <uartinit+0xe8>
    return;
  uart = 1;
80106f1c:	c7 05 a4 00 11 80 01 	movl   $0x1,0x801100a4
80106f23:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106f26:	68 fa 03 00 00       	push   $0x3fa
80106f2b:	e8 27 ff ff ff       	call   80106e57 <inb>
80106f30:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106f33:	68 f8 03 00 00       	push   $0x3f8
80106f38:	e8 1a ff ff ff       	call   80106e57 <inb>
80106f3d:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106f40:	83 ec 08             	sub    $0x8,%esp
80106f43:	6a 00                	push   $0x0
80106f45:	6a 04                	push   $0x4
80106f47:	e8 a6 bc ff ff       	call   80102bf2 <ioapicenable>
80106f4c:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f4f:	c7 45 f4 cc b4 10 80 	movl   $0x8010b4cc,-0xc(%ebp)
80106f56:	eb 19                	jmp    80106f71 <uartinit+0xdc>
    uartputc(*p);
80106f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f5b:	0f b6 00             	movzbl (%eax),%eax
80106f5e:	0f be c0             	movsbl %al,%eax
80106f61:	83 ec 0c             	sub    $0xc,%esp
80106f64:	50                   	push   %eax
80106f65:	e8 16 00 00 00       	call   80106f80 <uartputc>
80106f6a:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106f6d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f74:	0f b6 00             	movzbl (%eax),%eax
80106f77:	84 c0                	test   %al,%al
80106f79:	75 dd                	jne    80106f58 <uartinit+0xc3>
80106f7b:	eb 01                	jmp    80106f7e <uartinit+0xe9>
    return;
80106f7d:	90                   	nop
}
80106f7e:	c9                   	leave  
80106f7f:	c3                   	ret    

80106f80 <uartputc>:

void
uartputc(int c)
{
80106f80:	f3 0f 1e fb          	endbr32 
80106f84:	55                   	push   %ebp
80106f85:	89 e5                	mov    %esp,%ebp
80106f87:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106f8a:	a1 a4 00 11 80       	mov    0x801100a4,%eax
80106f8f:	85 c0                	test   %eax,%eax
80106f91:	74 53                	je     80106fe6 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f9a:	eb 11                	jmp    80106fad <uartputc+0x2d>
    microdelay(10);
80106f9c:	83 ec 0c             	sub    $0xc,%esp
80106f9f:	6a 0a                	push   $0xa
80106fa1:	e8 84 c1 ff ff       	call   8010312a <microdelay>
80106fa6:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106fa9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106fad:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106fb1:	7f 1a                	jg     80106fcd <uartputc+0x4d>
80106fb3:	83 ec 0c             	sub    $0xc,%esp
80106fb6:	68 fd 03 00 00       	push   $0x3fd
80106fbb:	e8 97 fe ff ff       	call   80106e57 <inb>
80106fc0:	83 c4 10             	add    $0x10,%esp
80106fc3:	0f b6 c0             	movzbl %al,%eax
80106fc6:	83 e0 20             	and    $0x20,%eax
80106fc9:	85 c0                	test   %eax,%eax
80106fcb:	74 cf                	je     80106f9c <uartputc+0x1c>
  outb(COM1+0, c);
80106fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80106fd0:	0f b6 c0             	movzbl %al,%eax
80106fd3:	83 ec 08             	sub    $0x8,%esp
80106fd6:	50                   	push   %eax
80106fd7:	68 f8 03 00 00       	push   $0x3f8
80106fdc:	e8 93 fe ff ff       	call   80106e74 <outb>
80106fe1:	83 c4 10             	add    $0x10,%esp
80106fe4:	eb 01                	jmp    80106fe7 <uartputc+0x67>
    return;
80106fe6:	90                   	nop
}
80106fe7:	c9                   	leave  
80106fe8:	c3                   	ret    

80106fe9 <uartgetc>:

static int
uartgetc(void)
{
80106fe9:	f3 0f 1e fb          	endbr32 
80106fed:	55                   	push   %ebp
80106fee:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106ff0:	a1 a4 00 11 80       	mov    0x801100a4,%eax
80106ff5:	85 c0                	test   %eax,%eax
80106ff7:	75 07                	jne    80107000 <uartgetc+0x17>
    return -1;
80106ff9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ffe:	eb 2e                	jmp    8010702e <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80107000:	68 fd 03 00 00       	push   $0x3fd
80107005:	e8 4d fe ff ff       	call   80106e57 <inb>
8010700a:	83 c4 04             	add    $0x4,%esp
8010700d:	0f b6 c0             	movzbl %al,%eax
80107010:	83 e0 01             	and    $0x1,%eax
80107013:	85 c0                	test   %eax,%eax
80107015:	75 07                	jne    8010701e <uartgetc+0x35>
    return -1;
80107017:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010701c:	eb 10                	jmp    8010702e <uartgetc+0x45>
  return inb(COM1+0);
8010701e:	68 f8 03 00 00       	push   $0x3f8
80107023:	e8 2f fe ff ff       	call   80106e57 <inb>
80107028:	83 c4 04             	add    $0x4,%esp
8010702b:	0f b6 c0             	movzbl %al,%eax
}
8010702e:	c9                   	leave  
8010702f:	c3                   	ret    

80107030 <uartintr>:

void
uartintr(void)
{
80107030:	f3 0f 1e fb          	endbr32 
80107034:	55                   	push   %ebp
80107035:	89 e5                	mov    %esp,%ebp
80107037:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010703a:	83 ec 0c             	sub    $0xc,%esp
8010703d:	68 e9 6f 10 80       	push   $0x80106fe9
80107042:	e8 b9 97 ff ff       	call   80100800 <consoleintr>
80107047:	83 c4 10             	add    $0x10,%esp
}
8010704a:	90                   	nop
8010704b:	c9                   	leave  
8010704c:	c3                   	ret    

8010704d <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $0
8010704f:	6a 00                	push   $0x0
  jmp alltraps
80107051:	e9 0c f9 ff ff       	jmp    80106962 <alltraps>

80107056 <vector1>:
.globl vector1
vector1:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $1
80107058:	6a 01                	push   $0x1
  jmp alltraps
8010705a:	e9 03 f9 ff ff       	jmp    80106962 <alltraps>

8010705f <vector2>:
.globl vector2
vector2:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $2
80107061:	6a 02                	push   $0x2
  jmp alltraps
80107063:	e9 fa f8 ff ff       	jmp    80106962 <alltraps>

80107068 <vector3>:
.globl vector3
vector3:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $3
8010706a:	6a 03                	push   $0x3
  jmp alltraps
8010706c:	e9 f1 f8 ff ff       	jmp    80106962 <alltraps>

80107071 <vector4>:
.globl vector4
vector4:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $4
80107073:	6a 04                	push   $0x4
  jmp alltraps
80107075:	e9 e8 f8 ff ff       	jmp    80106962 <alltraps>

8010707a <vector5>:
.globl vector5
vector5:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $5
8010707c:	6a 05                	push   $0x5
  jmp alltraps
8010707e:	e9 df f8 ff ff       	jmp    80106962 <alltraps>

80107083 <vector6>:
.globl vector6
vector6:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $6
80107085:	6a 06                	push   $0x6
  jmp alltraps
80107087:	e9 d6 f8 ff ff       	jmp    80106962 <alltraps>

8010708c <vector7>:
.globl vector7
vector7:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $7
8010708e:	6a 07                	push   $0x7
  jmp alltraps
80107090:	e9 cd f8 ff ff       	jmp    80106962 <alltraps>

80107095 <vector8>:
.globl vector8
vector8:
  pushl $8
80107095:	6a 08                	push   $0x8
  jmp alltraps
80107097:	e9 c6 f8 ff ff       	jmp    80106962 <alltraps>

8010709c <vector9>:
.globl vector9
vector9:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $9
8010709e:	6a 09                	push   $0x9
  jmp alltraps
801070a0:	e9 bd f8 ff ff       	jmp    80106962 <alltraps>

801070a5 <vector10>:
.globl vector10
vector10:
  pushl $10
801070a5:	6a 0a                	push   $0xa
  jmp alltraps
801070a7:	e9 b6 f8 ff ff       	jmp    80106962 <alltraps>

801070ac <vector11>:
.globl vector11
vector11:
  pushl $11
801070ac:	6a 0b                	push   $0xb
  jmp alltraps
801070ae:	e9 af f8 ff ff       	jmp    80106962 <alltraps>

801070b3 <vector12>:
.globl vector12
vector12:
  pushl $12
801070b3:	6a 0c                	push   $0xc
  jmp alltraps
801070b5:	e9 a8 f8 ff ff       	jmp    80106962 <alltraps>

801070ba <vector13>:
.globl vector13
vector13:
  pushl $13
801070ba:	6a 0d                	push   $0xd
  jmp alltraps
801070bc:	e9 a1 f8 ff ff       	jmp    80106962 <alltraps>

801070c1 <vector14>:
.globl vector14
vector14:
  pushl $14
801070c1:	6a 0e                	push   $0xe
  jmp alltraps
801070c3:	e9 9a f8 ff ff       	jmp    80106962 <alltraps>

801070c8 <vector15>:
.globl vector15
vector15:
  pushl $0
801070c8:	6a 00                	push   $0x0
  pushl $15
801070ca:	6a 0f                	push   $0xf
  jmp alltraps
801070cc:	e9 91 f8 ff ff       	jmp    80106962 <alltraps>

801070d1 <vector16>:
.globl vector16
vector16:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $16
801070d3:	6a 10                	push   $0x10
  jmp alltraps
801070d5:	e9 88 f8 ff ff       	jmp    80106962 <alltraps>

801070da <vector17>:
.globl vector17
vector17:
  pushl $17
801070da:	6a 11                	push   $0x11
  jmp alltraps
801070dc:	e9 81 f8 ff ff       	jmp    80106962 <alltraps>

801070e1 <vector18>:
.globl vector18
vector18:
  pushl $0
801070e1:	6a 00                	push   $0x0
  pushl $18
801070e3:	6a 12                	push   $0x12
  jmp alltraps
801070e5:	e9 78 f8 ff ff       	jmp    80106962 <alltraps>

801070ea <vector19>:
.globl vector19
vector19:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $19
801070ec:	6a 13                	push   $0x13
  jmp alltraps
801070ee:	e9 6f f8 ff ff       	jmp    80106962 <alltraps>

801070f3 <vector20>:
.globl vector20
vector20:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $20
801070f5:	6a 14                	push   $0x14
  jmp alltraps
801070f7:	e9 66 f8 ff ff       	jmp    80106962 <alltraps>

801070fc <vector21>:
.globl vector21
vector21:
  pushl $0
801070fc:	6a 00                	push   $0x0
  pushl $21
801070fe:	6a 15                	push   $0x15
  jmp alltraps
80107100:	e9 5d f8 ff ff       	jmp    80106962 <alltraps>

80107105 <vector22>:
.globl vector22
vector22:
  pushl $0
80107105:	6a 00                	push   $0x0
  pushl $22
80107107:	6a 16                	push   $0x16
  jmp alltraps
80107109:	e9 54 f8 ff ff       	jmp    80106962 <alltraps>

8010710e <vector23>:
.globl vector23
vector23:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $23
80107110:	6a 17                	push   $0x17
  jmp alltraps
80107112:	e9 4b f8 ff ff       	jmp    80106962 <alltraps>

80107117 <vector24>:
.globl vector24
vector24:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $24
80107119:	6a 18                	push   $0x18
  jmp alltraps
8010711b:	e9 42 f8 ff ff       	jmp    80106962 <alltraps>

80107120 <vector25>:
.globl vector25
vector25:
  pushl $0
80107120:	6a 00                	push   $0x0
  pushl $25
80107122:	6a 19                	push   $0x19
  jmp alltraps
80107124:	e9 39 f8 ff ff       	jmp    80106962 <alltraps>

80107129 <vector26>:
.globl vector26
vector26:
  pushl $0
80107129:	6a 00                	push   $0x0
  pushl $26
8010712b:	6a 1a                	push   $0x1a
  jmp alltraps
8010712d:	e9 30 f8 ff ff       	jmp    80106962 <alltraps>

80107132 <vector27>:
.globl vector27
vector27:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $27
80107134:	6a 1b                	push   $0x1b
  jmp alltraps
80107136:	e9 27 f8 ff ff       	jmp    80106962 <alltraps>

8010713b <vector28>:
.globl vector28
vector28:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $28
8010713d:	6a 1c                	push   $0x1c
  jmp alltraps
8010713f:	e9 1e f8 ff ff       	jmp    80106962 <alltraps>

80107144 <vector29>:
.globl vector29
vector29:
  pushl $0
80107144:	6a 00                	push   $0x0
  pushl $29
80107146:	6a 1d                	push   $0x1d
  jmp alltraps
80107148:	e9 15 f8 ff ff       	jmp    80106962 <alltraps>

8010714d <vector30>:
.globl vector30
vector30:
  pushl $0
8010714d:	6a 00                	push   $0x0
  pushl $30
8010714f:	6a 1e                	push   $0x1e
  jmp alltraps
80107151:	e9 0c f8 ff ff       	jmp    80106962 <alltraps>

80107156 <vector31>:
.globl vector31
vector31:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $31
80107158:	6a 1f                	push   $0x1f
  jmp alltraps
8010715a:	e9 03 f8 ff ff       	jmp    80106962 <alltraps>

8010715f <vector32>:
.globl vector32
vector32:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $32
80107161:	6a 20                	push   $0x20
  jmp alltraps
80107163:	e9 fa f7 ff ff       	jmp    80106962 <alltraps>

80107168 <vector33>:
.globl vector33
vector33:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $33
8010716a:	6a 21                	push   $0x21
  jmp alltraps
8010716c:	e9 f1 f7 ff ff       	jmp    80106962 <alltraps>

80107171 <vector34>:
.globl vector34
vector34:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $34
80107173:	6a 22                	push   $0x22
  jmp alltraps
80107175:	e9 e8 f7 ff ff       	jmp    80106962 <alltraps>

8010717a <vector35>:
.globl vector35
vector35:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $35
8010717c:	6a 23                	push   $0x23
  jmp alltraps
8010717e:	e9 df f7 ff ff       	jmp    80106962 <alltraps>

80107183 <vector36>:
.globl vector36
vector36:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $36
80107185:	6a 24                	push   $0x24
  jmp alltraps
80107187:	e9 d6 f7 ff ff       	jmp    80106962 <alltraps>

8010718c <vector37>:
.globl vector37
vector37:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $37
8010718e:	6a 25                	push   $0x25
  jmp alltraps
80107190:	e9 cd f7 ff ff       	jmp    80106962 <alltraps>

80107195 <vector38>:
.globl vector38
vector38:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $38
80107197:	6a 26                	push   $0x26
  jmp alltraps
80107199:	e9 c4 f7 ff ff       	jmp    80106962 <alltraps>

8010719e <vector39>:
.globl vector39
vector39:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $39
801071a0:	6a 27                	push   $0x27
  jmp alltraps
801071a2:	e9 bb f7 ff ff       	jmp    80106962 <alltraps>

801071a7 <vector40>:
.globl vector40
vector40:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $40
801071a9:	6a 28                	push   $0x28
  jmp alltraps
801071ab:	e9 b2 f7 ff ff       	jmp    80106962 <alltraps>

801071b0 <vector41>:
.globl vector41
vector41:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $41
801071b2:	6a 29                	push   $0x29
  jmp alltraps
801071b4:	e9 a9 f7 ff ff       	jmp    80106962 <alltraps>

801071b9 <vector42>:
.globl vector42
vector42:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $42
801071bb:	6a 2a                	push   $0x2a
  jmp alltraps
801071bd:	e9 a0 f7 ff ff       	jmp    80106962 <alltraps>

801071c2 <vector43>:
.globl vector43
vector43:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $43
801071c4:	6a 2b                	push   $0x2b
  jmp alltraps
801071c6:	e9 97 f7 ff ff       	jmp    80106962 <alltraps>

801071cb <vector44>:
.globl vector44
vector44:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $44
801071cd:	6a 2c                	push   $0x2c
  jmp alltraps
801071cf:	e9 8e f7 ff ff       	jmp    80106962 <alltraps>

801071d4 <vector45>:
.globl vector45
vector45:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $45
801071d6:	6a 2d                	push   $0x2d
  jmp alltraps
801071d8:	e9 85 f7 ff ff       	jmp    80106962 <alltraps>

801071dd <vector46>:
.globl vector46
vector46:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $46
801071df:	6a 2e                	push   $0x2e
  jmp alltraps
801071e1:	e9 7c f7 ff ff       	jmp    80106962 <alltraps>

801071e6 <vector47>:
.globl vector47
vector47:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $47
801071e8:	6a 2f                	push   $0x2f
  jmp alltraps
801071ea:	e9 73 f7 ff ff       	jmp    80106962 <alltraps>

801071ef <vector48>:
.globl vector48
vector48:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $48
801071f1:	6a 30                	push   $0x30
  jmp alltraps
801071f3:	e9 6a f7 ff ff       	jmp    80106962 <alltraps>

801071f8 <vector49>:
.globl vector49
vector49:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $49
801071fa:	6a 31                	push   $0x31
  jmp alltraps
801071fc:	e9 61 f7 ff ff       	jmp    80106962 <alltraps>

80107201 <vector50>:
.globl vector50
vector50:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $50
80107203:	6a 32                	push   $0x32
  jmp alltraps
80107205:	e9 58 f7 ff ff       	jmp    80106962 <alltraps>

8010720a <vector51>:
.globl vector51
vector51:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $51
8010720c:	6a 33                	push   $0x33
  jmp alltraps
8010720e:	e9 4f f7 ff ff       	jmp    80106962 <alltraps>

80107213 <vector52>:
.globl vector52
vector52:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $52
80107215:	6a 34                	push   $0x34
  jmp alltraps
80107217:	e9 46 f7 ff ff       	jmp    80106962 <alltraps>

8010721c <vector53>:
.globl vector53
vector53:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $53
8010721e:	6a 35                	push   $0x35
  jmp alltraps
80107220:	e9 3d f7 ff ff       	jmp    80106962 <alltraps>

80107225 <vector54>:
.globl vector54
vector54:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $54
80107227:	6a 36                	push   $0x36
  jmp alltraps
80107229:	e9 34 f7 ff ff       	jmp    80106962 <alltraps>

8010722e <vector55>:
.globl vector55
vector55:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $55
80107230:	6a 37                	push   $0x37
  jmp alltraps
80107232:	e9 2b f7 ff ff       	jmp    80106962 <alltraps>

80107237 <vector56>:
.globl vector56
vector56:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $56
80107239:	6a 38                	push   $0x38
  jmp alltraps
8010723b:	e9 22 f7 ff ff       	jmp    80106962 <alltraps>

80107240 <vector57>:
.globl vector57
vector57:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $57
80107242:	6a 39                	push   $0x39
  jmp alltraps
80107244:	e9 19 f7 ff ff       	jmp    80106962 <alltraps>

80107249 <vector58>:
.globl vector58
vector58:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $58
8010724b:	6a 3a                	push   $0x3a
  jmp alltraps
8010724d:	e9 10 f7 ff ff       	jmp    80106962 <alltraps>

80107252 <vector59>:
.globl vector59
vector59:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $59
80107254:	6a 3b                	push   $0x3b
  jmp alltraps
80107256:	e9 07 f7 ff ff       	jmp    80106962 <alltraps>

8010725b <vector60>:
.globl vector60
vector60:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $60
8010725d:	6a 3c                	push   $0x3c
  jmp alltraps
8010725f:	e9 fe f6 ff ff       	jmp    80106962 <alltraps>

80107264 <vector61>:
.globl vector61
vector61:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $61
80107266:	6a 3d                	push   $0x3d
  jmp alltraps
80107268:	e9 f5 f6 ff ff       	jmp    80106962 <alltraps>

8010726d <vector62>:
.globl vector62
vector62:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $62
8010726f:	6a 3e                	push   $0x3e
  jmp alltraps
80107271:	e9 ec f6 ff ff       	jmp    80106962 <alltraps>

80107276 <vector63>:
.globl vector63
vector63:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $63
80107278:	6a 3f                	push   $0x3f
  jmp alltraps
8010727a:	e9 e3 f6 ff ff       	jmp    80106962 <alltraps>

8010727f <vector64>:
.globl vector64
vector64:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $64
80107281:	6a 40                	push   $0x40
  jmp alltraps
80107283:	e9 da f6 ff ff       	jmp    80106962 <alltraps>

80107288 <vector65>:
.globl vector65
vector65:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $65
8010728a:	6a 41                	push   $0x41
  jmp alltraps
8010728c:	e9 d1 f6 ff ff       	jmp    80106962 <alltraps>

80107291 <vector66>:
.globl vector66
vector66:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $66
80107293:	6a 42                	push   $0x42
  jmp alltraps
80107295:	e9 c8 f6 ff ff       	jmp    80106962 <alltraps>

8010729a <vector67>:
.globl vector67
vector67:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $67
8010729c:	6a 43                	push   $0x43
  jmp alltraps
8010729e:	e9 bf f6 ff ff       	jmp    80106962 <alltraps>

801072a3 <vector68>:
.globl vector68
vector68:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $68
801072a5:	6a 44                	push   $0x44
  jmp alltraps
801072a7:	e9 b6 f6 ff ff       	jmp    80106962 <alltraps>

801072ac <vector69>:
.globl vector69
vector69:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $69
801072ae:	6a 45                	push   $0x45
  jmp alltraps
801072b0:	e9 ad f6 ff ff       	jmp    80106962 <alltraps>

801072b5 <vector70>:
.globl vector70
vector70:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $70
801072b7:	6a 46                	push   $0x46
  jmp alltraps
801072b9:	e9 a4 f6 ff ff       	jmp    80106962 <alltraps>

801072be <vector71>:
.globl vector71
vector71:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $71
801072c0:	6a 47                	push   $0x47
  jmp alltraps
801072c2:	e9 9b f6 ff ff       	jmp    80106962 <alltraps>

801072c7 <vector72>:
.globl vector72
vector72:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $72
801072c9:	6a 48                	push   $0x48
  jmp alltraps
801072cb:	e9 92 f6 ff ff       	jmp    80106962 <alltraps>

801072d0 <vector73>:
.globl vector73
vector73:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $73
801072d2:	6a 49                	push   $0x49
  jmp alltraps
801072d4:	e9 89 f6 ff ff       	jmp    80106962 <alltraps>

801072d9 <vector74>:
.globl vector74
vector74:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $74
801072db:	6a 4a                	push   $0x4a
  jmp alltraps
801072dd:	e9 80 f6 ff ff       	jmp    80106962 <alltraps>

801072e2 <vector75>:
.globl vector75
vector75:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $75
801072e4:	6a 4b                	push   $0x4b
  jmp alltraps
801072e6:	e9 77 f6 ff ff       	jmp    80106962 <alltraps>

801072eb <vector76>:
.globl vector76
vector76:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $76
801072ed:	6a 4c                	push   $0x4c
  jmp alltraps
801072ef:	e9 6e f6 ff ff       	jmp    80106962 <alltraps>

801072f4 <vector77>:
.globl vector77
vector77:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $77
801072f6:	6a 4d                	push   $0x4d
  jmp alltraps
801072f8:	e9 65 f6 ff ff       	jmp    80106962 <alltraps>

801072fd <vector78>:
.globl vector78
vector78:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $78
801072ff:	6a 4e                	push   $0x4e
  jmp alltraps
80107301:	e9 5c f6 ff ff       	jmp    80106962 <alltraps>

80107306 <vector79>:
.globl vector79
vector79:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $79
80107308:	6a 4f                	push   $0x4f
  jmp alltraps
8010730a:	e9 53 f6 ff ff       	jmp    80106962 <alltraps>

8010730f <vector80>:
.globl vector80
vector80:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $80
80107311:	6a 50                	push   $0x50
  jmp alltraps
80107313:	e9 4a f6 ff ff       	jmp    80106962 <alltraps>

80107318 <vector81>:
.globl vector81
vector81:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $81
8010731a:	6a 51                	push   $0x51
  jmp alltraps
8010731c:	e9 41 f6 ff ff       	jmp    80106962 <alltraps>

80107321 <vector82>:
.globl vector82
vector82:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $82
80107323:	6a 52                	push   $0x52
  jmp alltraps
80107325:	e9 38 f6 ff ff       	jmp    80106962 <alltraps>

8010732a <vector83>:
.globl vector83
vector83:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $83
8010732c:	6a 53                	push   $0x53
  jmp alltraps
8010732e:	e9 2f f6 ff ff       	jmp    80106962 <alltraps>

80107333 <vector84>:
.globl vector84
vector84:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $84
80107335:	6a 54                	push   $0x54
  jmp alltraps
80107337:	e9 26 f6 ff ff       	jmp    80106962 <alltraps>

8010733c <vector85>:
.globl vector85
vector85:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $85
8010733e:	6a 55                	push   $0x55
  jmp alltraps
80107340:	e9 1d f6 ff ff       	jmp    80106962 <alltraps>

80107345 <vector86>:
.globl vector86
vector86:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $86
80107347:	6a 56                	push   $0x56
  jmp alltraps
80107349:	e9 14 f6 ff ff       	jmp    80106962 <alltraps>

8010734e <vector87>:
.globl vector87
vector87:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $87
80107350:	6a 57                	push   $0x57
  jmp alltraps
80107352:	e9 0b f6 ff ff       	jmp    80106962 <alltraps>

80107357 <vector88>:
.globl vector88
vector88:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $88
80107359:	6a 58                	push   $0x58
  jmp alltraps
8010735b:	e9 02 f6 ff ff       	jmp    80106962 <alltraps>

80107360 <vector89>:
.globl vector89
vector89:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $89
80107362:	6a 59                	push   $0x59
  jmp alltraps
80107364:	e9 f9 f5 ff ff       	jmp    80106962 <alltraps>

80107369 <vector90>:
.globl vector90
vector90:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $90
8010736b:	6a 5a                	push   $0x5a
  jmp alltraps
8010736d:	e9 f0 f5 ff ff       	jmp    80106962 <alltraps>

80107372 <vector91>:
.globl vector91
vector91:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $91
80107374:	6a 5b                	push   $0x5b
  jmp alltraps
80107376:	e9 e7 f5 ff ff       	jmp    80106962 <alltraps>

8010737b <vector92>:
.globl vector92
vector92:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $92
8010737d:	6a 5c                	push   $0x5c
  jmp alltraps
8010737f:	e9 de f5 ff ff       	jmp    80106962 <alltraps>

80107384 <vector93>:
.globl vector93
vector93:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $93
80107386:	6a 5d                	push   $0x5d
  jmp alltraps
80107388:	e9 d5 f5 ff ff       	jmp    80106962 <alltraps>

8010738d <vector94>:
.globl vector94
vector94:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $94
8010738f:	6a 5e                	push   $0x5e
  jmp alltraps
80107391:	e9 cc f5 ff ff       	jmp    80106962 <alltraps>

80107396 <vector95>:
.globl vector95
vector95:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $95
80107398:	6a 5f                	push   $0x5f
  jmp alltraps
8010739a:	e9 c3 f5 ff ff       	jmp    80106962 <alltraps>

8010739f <vector96>:
.globl vector96
vector96:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $96
801073a1:	6a 60                	push   $0x60
  jmp alltraps
801073a3:	e9 ba f5 ff ff       	jmp    80106962 <alltraps>

801073a8 <vector97>:
.globl vector97
vector97:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $97
801073aa:	6a 61                	push   $0x61
  jmp alltraps
801073ac:	e9 b1 f5 ff ff       	jmp    80106962 <alltraps>

801073b1 <vector98>:
.globl vector98
vector98:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $98
801073b3:	6a 62                	push   $0x62
  jmp alltraps
801073b5:	e9 a8 f5 ff ff       	jmp    80106962 <alltraps>

801073ba <vector99>:
.globl vector99
vector99:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $99
801073bc:	6a 63                	push   $0x63
  jmp alltraps
801073be:	e9 9f f5 ff ff       	jmp    80106962 <alltraps>

801073c3 <vector100>:
.globl vector100
vector100:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $100
801073c5:	6a 64                	push   $0x64
  jmp alltraps
801073c7:	e9 96 f5 ff ff       	jmp    80106962 <alltraps>

801073cc <vector101>:
.globl vector101
vector101:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $101
801073ce:	6a 65                	push   $0x65
  jmp alltraps
801073d0:	e9 8d f5 ff ff       	jmp    80106962 <alltraps>

801073d5 <vector102>:
.globl vector102
vector102:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $102
801073d7:	6a 66                	push   $0x66
  jmp alltraps
801073d9:	e9 84 f5 ff ff       	jmp    80106962 <alltraps>

801073de <vector103>:
.globl vector103
vector103:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $103
801073e0:	6a 67                	push   $0x67
  jmp alltraps
801073e2:	e9 7b f5 ff ff       	jmp    80106962 <alltraps>

801073e7 <vector104>:
.globl vector104
vector104:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $104
801073e9:	6a 68                	push   $0x68
  jmp alltraps
801073eb:	e9 72 f5 ff ff       	jmp    80106962 <alltraps>

801073f0 <vector105>:
.globl vector105
vector105:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $105
801073f2:	6a 69                	push   $0x69
  jmp alltraps
801073f4:	e9 69 f5 ff ff       	jmp    80106962 <alltraps>

801073f9 <vector106>:
.globl vector106
vector106:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $106
801073fb:	6a 6a                	push   $0x6a
  jmp alltraps
801073fd:	e9 60 f5 ff ff       	jmp    80106962 <alltraps>

80107402 <vector107>:
.globl vector107
vector107:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $107
80107404:	6a 6b                	push   $0x6b
  jmp alltraps
80107406:	e9 57 f5 ff ff       	jmp    80106962 <alltraps>

8010740b <vector108>:
.globl vector108
vector108:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $108
8010740d:	6a 6c                	push   $0x6c
  jmp alltraps
8010740f:	e9 4e f5 ff ff       	jmp    80106962 <alltraps>

80107414 <vector109>:
.globl vector109
vector109:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $109
80107416:	6a 6d                	push   $0x6d
  jmp alltraps
80107418:	e9 45 f5 ff ff       	jmp    80106962 <alltraps>

8010741d <vector110>:
.globl vector110
vector110:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $110
8010741f:	6a 6e                	push   $0x6e
  jmp alltraps
80107421:	e9 3c f5 ff ff       	jmp    80106962 <alltraps>

80107426 <vector111>:
.globl vector111
vector111:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $111
80107428:	6a 6f                	push   $0x6f
  jmp alltraps
8010742a:	e9 33 f5 ff ff       	jmp    80106962 <alltraps>

8010742f <vector112>:
.globl vector112
vector112:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $112
80107431:	6a 70                	push   $0x70
  jmp alltraps
80107433:	e9 2a f5 ff ff       	jmp    80106962 <alltraps>

80107438 <vector113>:
.globl vector113
vector113:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $113
8010743a:	6a 71                	push   $0x71
  jmp alltraps
8010743c:	e9 21 f5 ff ff       	jmp    80106962 <alltraps>

80107441 <vector114>:
.globl vector114
vector114:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $114
80107443:	6a 72                	push   $0x72
  jmp alltraps
80107445:	e9 18 f5 ff ff       	jmp    80106962 <alltraps>

8010744a <vector115>:
.globl vector115
vector115:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $115
8010744c:	6a 73                	push   $0x73
  jmp alltraps
8010744e:	e9 0f f5 ff ff       	jmp    80106962 <alltraps>

80107453 <vector116>:
.globl vector116
vector116:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $116
80107455:	6a 74                	push   $0x74
  jmp alltraps
80107457:	e9 06 f5 ff ff       	jmp    80106962 <alltraps>

8010745c <vector117>:
.globl vector117
vector117:
  pushl $0
8010745c:	6a 00                	push   $0x0
  pushl $117
8010745e:	6a 75                	push   $0x75
  jmp alltraps
80107460:	e9 fd f4 ff ff       	jmp    80106962 <alltraps>

80107465 <vector118>:
.globl vector118
vector118:
  pushl $0
80107465:	6a 00                	push   $0x0
  pushl $118
80107467:	6a 76                	push   $0x76
  jmp alltraps
80107469:	e9 f4 f4 ff ff       	jmp    80106962 <alltraps>

8010746e <vector119>:
.globl vector119
vector119:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $119
80107470:	6a 77                	push   $0x77
  jmp alltraps
80107472:	e9 eb f4 ff ff       	jmp    80106962 <alltraps>

80107477 <vector120>:
.globl vector120
vector120:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $120
80107479:	6a 78                	push   $0x78
  jmp alltraps
8010747b:	e9 e2 f4 ff ff       	jmp    80106962 <alltraps>

80107480 <vector121>:
.globl vector121
vector121:
  pushl $0
80107480:	6a 00                	push   $0x0
  pushl $121
80107482:	6a 79                	push   $0x79
  jmp alltraps
80107484:	e9 d9 f4 ff ff       	jmp    80106962 <alltraps>

80107489 <vector122>:
.globl vector122
vector122:
  pushl $0
80107489:	6a 00                	push   $0x0
  pushl $122
8010748b:	6a 7a                	push   $0x7a
  jmp alltraps
8010748d:	e9 d0 f4 ff ff       	jmp    80106962 <alltraps>

80107492 <vector123>:
.globl vector123
vector123:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $123
80107494:	6a 7b                	push   $0x7b
  jmp alltraps
80107496:	e9 c7 f4 ff ff       	jmp    80106962 <alltraps>

8010749b <vector124>:
.globl vector124
vector124:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $124
8010749d:	6a 7c                	push   $0x7c
  jmp alltraps
8010749f:	e9 be f4 ff ff       	jmp    80106962 <alltraps>

801074a4 <vector125>:
.globl vector125
vector125:
  pushl $0
801074a4:	6a 00                	push   $0x0
  pushl $125
801074a6:	6a 7d                	push   $0x7d
  jmp alltraps
801074a8:	e9 b5 f4 ff ff       	jmp    80106962 <alltraps>

801074ad <vector126>:
.globl vector126
vector126:
  pushl $0
801074ad:	6a 00                	push   $0x0
  pushl $126
801074af:	6a 7e                	push   $0x7e
  jmp alltraps
801074b1:	e9 ac f4 ff ff       	jmp    80106962 <alltraps>

801074b6 <vector127>:
.globl vector127
vector127:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $127
801074b8:	6a 7f                	push   $0x7f
  jmp alltraps
801074ba:	e9 a3 f4 ff ff       	jmp    80106962 <alltraps>

801074bf <vector128>:
.globl vector128
vector128:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $128
801074c1:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801074c6:	e9 97 f4 ff ff       	jmp    80106962 <alltraps>

801074cb <vector129>:
.globl vector129
vector129:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $129
801074cd:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801074d2:	e9 8b f4 ff ff       	jmp    80106962 <alltraps>

801074d7 <vector130>:
.globl vector130
vector130:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $130
801074d9:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801074de:	e9 7f f4 ff ff       	jmp    80106962 <alltraps>

801074e3 <vector131>:
.globl vector131
vector131:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $131
801074e5:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801074ea:	e9 73 f4 ff ff       	jmp    80106962 <alltraps>

801074ef <vector132>:
.globl vector132
vector132:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $132
801074f1:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801074f6:	e9 67 f4 ff ff       	jmp    80106962 <alltraps>

801074fb <vector133>:
.globl vector133
vector133:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $133
801074fd:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107502:	e9 5b f4 ff ff       	jmp    80106962 <alltraps>

80107507 <vector134>:
.globl vector134
vector134:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $134
80107509:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010750e:	e9 4f f4 ff ff       	jmp    80106962 <alltraps>

80107513 <vector135>:
.globl vector135
vector135:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $135
80107515:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010751a:	e9 43 f4 ff ff       	jmp    80106962 <alltraps>

8010751f <vector136>:
.globl vector136
vector136:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $136
80107521:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107526:	e9 37 f4 ff ff       	jmp    80106962 <alltraps>

8010752b <vector137>:
.globl vector137
vector137:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $137
8010752d:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107532:	e9 2b f4 ff ff       	jmp    80106962 <alltraps>

80107537 <vector138>:
.globl vector138
vector138:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $138
80107539:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010753e:	e9 1f f4 ff ff       	jmp    80106962 <alltraps>

80107543 <vector139>:
.globl vector139
vector139:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $139
80107545:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010754a:	e9 13 f4 ff ff       	jmp    80106962 <alltraps>

8010754f <vector140>:
.globl vector140
vector140:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $140
80107551:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107556:	e9 07 f4 ff ff       	jmp    80106962 <alltraps>

8010755b <vector141>:
.globl vector141
vector141:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $141
8010755d:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107562:	e9 fb f3 ff ff       	jmp    80106962 <alltraps>

80107567 <vector142>:
.globl vector142
vector142:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $142
80107569:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010756e:	e9 ef f3 ff ff       	jmp    80106962 <alltraps>

80107573 <vector143>:
.globl vector143
vector143:
  pushl $0
80107573:	6a 00                	push   $0x0
  pushl $143
80107575:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010757a:	e9 e3 f3 ff ff       	jmp    80106962 <alltraps>

8010757f <vector144>:
.globl vector144
vector144:
  pushl $0
8010757f:	6a 00                	push   $0x0
  pushl $144
80107581:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107586:	e9 d7 f3 ff ff       	jmp    80106962 <alltraps>

8010758b <vector145>:
.globl vector145
vector145:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $145
8010758d:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107592:	e9 cb f3 ff ff       	jmp    80106962 <alltraps>

80107597 <vector146>:
.globl vector146
vector146:
  pushl $0
80107597:	6a 00                	push   $0x0
  pushl $146
80107599:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010759e:	e9 bf f3 ff ff       	jmp    80106962 <alltraps>

801075a3 <vector147>:
.globl vector147
vector147:
  pushl $0
801075a3:	6a 00                	push   $0x0
  pushl $147
801075a5:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801075aa:	e9 b3 f3 ff ff       	jmp    80106962 <alltraps>

801075af <vector148>:
.globl vector148
vector148:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $148
801075b1:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801075b6:	e9 a7 f3 ff ff       	jmp    80106962 <alltraps>

801075bb <vector149>:
.globl vector149
vector149:
  pushl $0
801075bb:	6a 00                	push   $0x0
  pushl $149
801075bd:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801075c2:	e9 9b f3 ff ff       	jmp    80106962 <alltraps>

801075c7 <vector150>:
.globl vector150
vector150:
  pushl $0
801075c7:	6a 00                	push   $0x0
  pushl $150
801075c9:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801075ce:	e9 8f f3 ff ff       	jmp    80106962 <alltraps>

801075d3 <vector151>:
.globl vector151
vector151:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $151
801075d5:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801075da:	e9 83 f3 ff ff       	jmp    80106962 <alltraps>

801075df <vector152>:
.globl vector152
vector152:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $152
801075e1:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801075e6:	e9 77 f3 ff ff       	jmp    80106962 <alltraps>

801075eb <vector153>:
.globl vector153
vector153:
  pushl $0
801075eb:	6a 00                	push   $0x0
  pushl $153
801075ed:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801075f2:	e9 6b f3 ff ff       	jmp    80106962 <alltraps>

801075f7 <vector154>:
.globl vector154
vector154:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $154
801075f9:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801075fe:	e9 5f f3 ff ff       	jmp    80106962 <alltraps>

80107603 <vector155>:
.globl vector155
vector155:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $155
80107605:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010760a:	e9 53 f3 ff ff       	jmp    80106962 <alltraps>

8010760f <vector156>:
.globl vector156
vector156:
  pushl $0
8010760f:	6a 00                	push   $0x0
  pushl $156
80107611:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107616:	e9 47 f3 ff ff       	jmp    80106962 <alltraps>

8010761b <vector157>:
.globl vector157
vector157:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $157
8010761d:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107622:	e9 3b f3 ff ff       	jmp    80106962 <alltraps>

80107627 <vector158>:
.globl vector158
vector158:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $158
80107629:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010762e:	e9 2f f3 ff ff       	jmp    80106962 <alltraps>

80107633 <vector159>:
.globl vector159
vector159:
  pushl $0
80107633:	6a 00                	push   $0x0
  pushl $159
80107635:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010763a:	e9 23 f3 ff ff       	jmp    80106962 <alltraps>

8010763f <vector160>:
.globl vector160
vector160:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $160
80107641:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107646:	e9 17 f3 ff ff       	jmp    80106962 <alltraps>

8010764b <vector161>:
.globl vector161
vector161:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $161
8010764d:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107652:	e9 0b f3 ff ff       	jmp    80106962 <alltraps>

80107657 <vector162>:
.globl vector162
vector162:
  pushl $0
80107657:	6a 00                	push   $0x0
  pushl $162
80107659:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010765e:	e9 ff f2 ff ff       	jmp    80106962 <alltraps>

80107663 <vector163>:
.globl vector163
vector163:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $163
80107665:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010766a:	e9 f3 f2 ff ff       	jmp    80106962 <alltraps>

8010766f <vector164>:
.globl vector164
vector164:
  pushl $0
8010766f:	6a 00                	push   $0x0
  pushl $164
80107671:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107676:	e9 e7 f2 ff ff       	jmp    80106962 <alltraps>

8010767b <vector165>:
.globl vector165
vector165:
  pushl $0
8010767b:	6a 00                	push   $0x0
  pushl $165
8010767d:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107682:	e9 db f2 ff ff       	jmp    80106962 <alltraps>

80107687 <vector166>:
.globl vector166
vector166:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $166
80107689:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010768e:	e9 cf f2 ff ff       	jmp    80106962 <alltraps>

80107693 <vector167>:
.globl vector167
vector167:
  pushl $0
80107693:	6a 00                	push   $0x0
  pushl $167
80107695:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010769a:	e9 c3 f2 ff ff       	jmp    80106962 <alltraps>

8010769f <vector168>:
.globl vector168
vector168:
  pushl $0
8010769f:	6a 00                	push   $0x0
  pushl $168
801076a1:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801076a6:	e9 b7 f2 ff ff       	jmp    80106962 <alltraps>

801076ab <vector169>:
.globl vector169
vector169:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $169
801076ad:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801076b2:	e9 ab f2 ff ff       	jmp    80106962 <alltraps>

801076b7 <vector170>:
.globl vector170
vector170:
  pushl $0
801076b7:	6a 00                	push   $0x0
  pushl $170
801076b9:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801076be:	e9 9f f2 ff ff       	jmp    80106962 <alltraps>

801076c3 <vector171>:
.globl vector171
vector171:
  pushl $0
801076c3:	6a 00                	push   $0x0
  pushl $171
801076c5:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801076ca:	e9 93 f2 ff ff       	jmp    80106962 <alltraps>

801076cf <vector172>:
.globl vector172
vector172:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $172
801076d1:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801076d6:	e9 87 f2 ff ff       	jmp    80106962 <alltraps>

801076db <vector173>:
.globl vector173
vector173:
  pushl $0
801076db:	6a 00                	push   $0x0
  pushl $173
801076dd:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801076e2:	e9 7b f2 ff ff       	jmp    80106962 <alltraps>

801076e7 <vector174>:
.globl vector174
vector174:
  pushl $0
801076e7:	6a 00                	push   $0x0
  pushl $174
801076e9:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801076ee:	e9 6f f2 ff ff       	jmp    80106962 <alltraps>

801076f3 <vector175>:
.globl vector175
vector175:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $175
801076f5:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801076fa:	e9 63 f2 ff ff       	jmp    80106962 <alltraps>

801076ff <vector176>:
.globl vector176
vector176:
  pushl $0
801076ff:	6a 00                	push   $0x0
  pushl $176
80107701:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107706:	e9 57 f2 ff ff       	jmp    80106962 <alltraps>

8010770b <vector177>:
.globl vector177
vector177:
  pushl $0
8010770b:	6a 00                	push   $0x0
  pushl $177
8010770d:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107712:	e9 4b f2 ff ff       	jmp    80106962 <alltraps>

80107717 <vector178>:
.globl vector178
vector178:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $178
80107719:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010771e:	e9 3f f2 ff ff       	jmp    80106962 <alltraps>

80107723 <vector179>:
.globl vector179
vector179:
  pushl $0
80107723:	6a 00                	push   $0x0
  pushl $179
80107725:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010772a:	e9 33 f2 ff ff       	jmp    80106962 <alltraps>

8010772f <vector180>:
.globl vector180
vector180:
  pushl $0
8010772f:	6a 00                	push   $0x0
  pushl $180
80107731:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107736:	e9 27 f2 ff ff       	jmp    80106962 <alltraps>

8010773b <vector181>:
.globl vector181
vector181:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $181
8010773d:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107742:	e9 1b f2 ff ff       	jmp    80106962 <alltraps>

80107747 <vector182>:
.globl vector182
vector182:
  pushl $0
80107747:	6a 00                	push   $0x0
  pushl $182
80107749:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010774e:	e9 0f f2 ff ff       	jmp    80106962 <alltraps>

80107753 <vector183>:
.globl vector183
vector183:
  pushl $0
80107753:	6a 00                	push   $0x0
  pushl $183
80107755:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010775a:	e9 03 f2 ff ff       	jmp    80106962 <alltraps>

8010775f <vector184>:
.globl vector184
vector184:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $184
80107761:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107766:	e9 f7 f1 ff ff       	jmp    80106962 <alltraps>

8010776b <vector185>:
.globl vector185
vector185:
  pushl $0
8010776b:	6a 00                	push   $0x0
  pushl $185
8010776d:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107772:	e9 eb f1 ff ff       	jmp    80106962 <alltraps>

80107777 <vector186>:
.globl vector186
vector186:
  pushl $0
80107777:	6a 00                	push   $0x0
  pushl $186
80107779:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010777e:	e9 df f1 ff ff       	jmp    80106962 <alltraps>

80107783 <vector187>:
.globl vector187
vector187:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $187
80107785:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010778a:	e9 d3 f1 ff ff       	jmp    80106962 <alltraps>

8010778f <vector188>:
.globl vector188
vector188:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $188
80107791:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107796:	e9 c7 f1 ff ff       	jmp    80106962 <alltraps>

8010779b <vector189>:
.globl vector189
vector189:
  pushl $0
8010779b:	6a 00                	push   $0x0
  pushl $189
8010779d:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801077a2:	e9 bb f1 ff ff       	jmp    80106962 <alltraps>

801077a7 <vector190>:
.globl vector190
vector190:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $190
801077a9:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801077ae:	e9 af f1 ff ff       	jmp    80106962 <alltraps>

801077b3 <vector191>:
.globl vector191
vector191:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $191
801077b5:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801077ba:	e9 a3 f1 ff ff       	jmp    80106962 <alltraps>

801077bf <vector192>:
.globl vector192
vector192:
  pushl $0
801077bf:	6a 00                	push   $0x0
  pushl $192
801077c1:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801077c6:	e9 97 f1 ff ff       	jmp    80106962 <alltraps>

801077cb <vector193>:
.globl vector193
vector193:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $193
801077cd:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801077d2:	e9 8b f1 ff ff       	jmp    80106962 <alltraps>

801077d7 <vector194>:
.globl vector194
vector194:
  pushl $0
801077d7:	6a 00                	push   $0x0
  pushl $194
801077d9:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801077de:	e9 7f f1 ff ff       	jmp    80106962 <alltraps>

801077e3 <vector195>:
.globl vector195
vector195:
  pushl $0
801077e3:	6a 00                	push   $0x0
  pushl $195
801077e5:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801077ea:	e9 73 f1 ff ff       	jmp    80106962 <alltraps>

801077ef <vector196>:
.globl vector196
vector196:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $196
801077f1:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801077f6:	e9 67 f1 ff ff       	jmp    80106962 <alltraps>

801077fb <vector197>:
.globl vector197
vector197:
  pushl $0
801077fb:	6a 00                	push   $0x0
  pushl $197
801077fd:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107802:	e9 5b f1 ff ff       	jmp    80106962 <alltraps>

80107807 <vector198>:
.globl vector198
vector198:
  pushl $0
80107807:	6a 00                	push   $0x0
  pushl $198
80107809:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010780e:	e9 4f f1 ff ff       	jmp    80106962 <alltraps>

80107813 <vector199>:
.globl vector199
vector199:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $199
80107815:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010781a:	e9 43 f1 ff ff       	jmp    80106962 <alltraps>

8010781f <vector200>:
.globl vector200
vector200:
  pushl $0
8010781f:	6a 00                	push   $0x0
  pushl $200
80107821:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107826:	e9 37 f1 ff ff       	jmp    80106962 <alltraps>

8010782b <vector201>:
.globl vector201
vector201:
  pushl $0
8010782b:	6a 00                	push   $0x0
  pushl $201
8010782d:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107832:	e9 2b f1 ff ff       	jmp    80106962 <alltraps>

80107837 <vector202>:
.globl vector202
vector202:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $202
80107839:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010783e:	e9 1f f1 ff ff       	jmp    80106962 <alltraps>

80107843 <vector203>:
.globl vector203
vector203:
  pushl $0
80107843:	6a 00                	push   $0x0
  pushl $203
80107845:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010784a:	e9 13 f1 ff ff       	jmp    80106962 <alltraps>

8010784f <vector204>:
.globl vector204
vector204:
  pushl $0
8010784f:	6a 00                	push   $0x0
  pushl $204
80107851:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107856:	e9 07 f1 ff ff       	jmp    80106962 <alltraps>

8010785b <vector205>:
.globl vector205
vector205:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $205
8010785d:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107862:	e9 fb f0 ff ff       	jmp    80106962 <alltraps>

80107867 <vector206>:
.globl vector206
vector206:
  pushl $0
80107867:	6a 00                	push   $0x0
  pushl $206
80107869:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010786e:	e9 ef f0 ff ff       	jmp    80106962 <alltraps>

80107873 <vector207>:
.globl vector207
vector207:
  pushl $0
80107873:	6a 00                	push   $0x0
  pushl $207
80107875:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010787a:	e9 e3 f0 ff ff       	jmp    80106962 <alltraps>

8010787f <vector208>:
.globl vector208
vector208:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $208
80107881:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107886:	e9 d7 f0 ff ff       	jmp    80106962 <alltraps>

8010788b <vector209>:
.globl vector209
vector209:
  pushl $0
8010788b:	6a 00                	push   $0x0
  pushl $209
8010788d:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107892:	e9 cb f0 ff ff       	jmp    80106962 <alltraps>

80107897 <vector210>:
.globl vector210
vector210:
  pushl $0
80107897:	6a 00                	push   $0x0
  pushl $210
80107899:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010789e:	e9 bf f0 ff ff       	jmp    80106962 <alltraps>

801078a3 <vector211>:
.globl vector211
vector211:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $211
801078a5:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801078aa:	e9 b3 f0 ff ff       	jmp    80106962 <alltraps>

801078af <vector212>:
.globl vector212
vector212:
  pushl $0
801078af:	6a 00                	push   $0x0
  pushl $212
801078b1:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801078b6:	e9 a7 f0 ff ff       	jmp    80106962 <alltraps>

801078bb <vector213>:
.globl vector213
vector213:
  pushl $0
801078bb:	6a 00                	push   $0x0
  pushl $213
801078bd:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801078c2:	e9 9b f0 ff ff       	jmp    80106962 <alltraps>

801078c7 <vector214>:
.globl vector214
vector214:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $214
801078c9:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801078ce:	e9 8f f0 ff ff       	jmp    80106962 <alltraps>

801078d3 <vector215>:
.globl vector215
vector215:
  pushl $0
801078d3:	6a 00                	push   $0x0
  pushl $215
801078d5:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801078da:	e9 83 f0 ff ff       	jmp    80106962 <alltraps>

801078df <vector216>:
.globl vector216
vector216:
  pushl $0
801078df:	6a 00                	push   $0x0
  pushl $216
801078e1:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801078e6:	e9 77 f0 ff ff       	jmp    80106962 <alltraps>

801078eb <vector217>:
.globl vector217
vector217:
  pushl $0
801078eb:	6a 00                	push   $0x0
  pushl $217
801078ed:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801078f2:	e9 6b f0 ff ff       	jmp    80106962 <alltraps>

801078f7 <vector218>:
.globl vector218
vector218:
  pushl $0
801078f7:	6a 00                	push   $0x0
  pushl $218
801078f9:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801078fe:	e9 5f f0 ff ff       	jmp    80106962 <alltraps>

80107903 <vector219>:
.globl vector219
vector219:
  pushl $0
80107903:	6a 00                	push   $0x0
  pushl $219
80107905:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010790a:	e9 53 f0 ff ff       	jmp    80106962 <alltraps>

8010790f <vector220>:
.globl vector220
vector220:
  pushl $0
8010790f:	6a 00                	push   $0x0
  pushl $220
80107911:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107916:	e9 47 f0 ff ff       	jmp    80106962 <alltraps>

8010791b <vector221>:
.globl vector221
vector221:
  pushl $0
8010791b:	6a 00                	push   $0x0
  pushl $221
8010791d:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107922:	e9 3b f0 ff ff       	jmp    80106962 <alltraps>

80107927 <vector222>:
.globl vector222
vector222:
  pushl $0
80107927:	6a 00                	push   $0x0
  pushl $222
80107929:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010792e:	e9 2f f0 ff ff       	jmp    80106962 <alltraps>

80107933 <vector223>:
.globl vector223
vector223:
  pushl $0
80107933:	6a 00                	push   $0x0
  pushl $223
80107935:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010793a:	e9 23 f0 ff ff       	jmp    80106962 <alltraps>

8010793f <vector224>:
.globl vector224
vector224:
  pushl $0
8010793f:	6a 00                	push   $0x0
  pushl $224
80107941:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107946:	e9 17 f0 ff ff       	jmp    80106962 <alltraps>

8010794b <vector225>:
.globl vector225
vector225:
  pushl $0
8010794b:	6a 00                	push   $0x0
  pushl $225
8010794d:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107952:	e9 0b f0 ff ff       	jmp    80106962 <alltraps>

80107957 <vector226>:
.globl vector226
vector226:
  pushl $0
80107957:	6a 00                	push   $0x0
  pushl $226
80107959:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010795e:	e9 ff ef ff ff       	jmp    80106962 <alltraps>

80107963 <vector227>:
.globl vector227
vector227:
  pushl $0
80107963:	6a 00                	push   $0x0
  pushl $227
80107965:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010796a:	e9 f3 ef ff ff       	jmp    80106962 <alltraps>

8010796f <vector228>:
.globl vector228
vector228:
  pushl $0
8010796f:	6a 00                	push   $0x0
  pushl $228
80107971:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107976:	e9 e7 ef ff ff       	jmp    80106962 <alltraps>

8010797b <vector229>:
.globl vector229
vector229:
  pushl $0
8010797b:	6a 00                	push   $0x0
  pushl $229
8010797d:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107982:	e9 db ef ff ff       	jmp    80106962 <alltraps>

80107987 <vector230>:
.globl vector230
vector230:
  pushl $0
80107987:	6a 00                	push   $0x0
  pushl $230
80107989:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010798e:	e9 cf ef ff ff       	jmp    80106962 <alltraps>

80107993 <vector231>:
.globl vector231
vector231:
  pushl $0
80107993:	6a 00                	push   $0x0
  pushl $231
80107995:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010799a:	e9 c3 ef ff ff       	jmp    80106962 <alltraps>

8010799f <vector232>:
.globl vector232
vector232:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $232
801079a1:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801079a6:	e9 b7 ef ff ff       	jmp    80106962 <alltraps>

801079ab <vector233>:
.globl vector233
vector233:
  pushl $0
801079ab:	6a 00                	push   $0x0
  pushl $233
801079ad:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801079b2:	e9 ab ef ff ff       	jmp    80106962 <alltraps>

801079b7 <vector234>:
.globl vector234
vector234:
  pushl $0
801079b7:	6a 00                	push   $0x0
  pushl $234
801079b9:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801079be:	e9 9f ef ff ff       	jmp    80106962 <alltraps>

801079c3 <vector235>:
.globl vector235
vector235:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $235
801079c5:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801079ca:	e9 93 ef ff ff       	jmp    80106962 <alltraps>

801079cf <vector236>:
.globl vector236
vector236:
  pushl $0
801079cf:	6a 00                	push   $0x0
  pushl $236
801079d1:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801079d6:	e9 87 ef ff ff       	jmp    80106962 <alltraps>

801079db <vector237>:
.globl vector237
vector237:
  pushl $0
801079db:	6a 00                	push   $0x0
  pushl $237
801079dd:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801079e2:	e9 7b ef ff ff       	jmp    80106962 <alltraps>

801079e7 <vector238>:
.globl vector238
vector238:
  pushl $0
801079e7:	6a 00                	push   $0x0
  pushl $238
801079e9:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801079ee:	e9 6f ef ff ff       	jmp    80106962 <alltraps>

801079f3 <vector239>:
.globl vector239
vector239:
  pushl $0
801079f3:	6a 00                	push   $0x0
  pushl $239
801079f5:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801079fa:	e9 63 ef ff ff       	jmp    80106962 <alltraps>

801079ff <vector240>:
.globl vector240
vector240:
  pushl $0
801079ff:	6a 00                	push   $0x0
  pushl $240
80107a01:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107a06:	e9 57 ef ff ff       	jmp    80106962 <alltraps>

80107a0b <vector241>:
.globl vector241
vector241:
  pushl $0
80107a0b:	6a 00                	push   $0x0
  pushl $241
80107a0d:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107a12:	e9 4b ef ff ff       	jmp    80106962 <alltraps>

80107a17 <vector242>:
.globl vector242
vector242:
  pushl $0
80107a17:	6a 00                	push   $0x0
  pushl $242
80107a19:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107a1e:	e9 3f ef ff ff       	jmp    80106962 <alltraps>

80107a23 <vector243>:
.globl vector243
vector243:
  pushl $0
80107a23:	6a 00                	push   $0x0
  pushl $243
80107a25:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107a2a:	e9 33 ef ff ff       	jmp    80106962 <alltraps>

80107a2f <vector244>:
.globl vector244
vector244:
  pushl $0
80107a2f:	6a 00                	push   $0x0
  pushl $244
80107a31:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107a36:	e9 27 ef ff ff       	jmp    80106962 <alltraps>

80107a3b <vector245>:
.globl vector245
vector245:
  pushl $0
80107a3b:	6a 00                	push   $0x0
  pushl $245
80107a3d:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107a42:	e9 1b ef ff ff       	jmp    80106962 <alltraps>

80107a47 <vector246>:
.globl vector246
vector246:
  pushl $0
80107a47:	6a 00                	push   $0x0
  pushl $246
80107a49:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107a4e:	e9 0f ef ff ff       	jmp    80106962 <alltraps>

80107a53 <vector247>:
.globl vector247
vector247:
  pushl $0
80107a53:	6a 00                	push   $0x0
  pushl $247
80107a55:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107a5a:	e9 03 ef ff ff       	jmp    80106962 <alltraps>

80107a5f <vector248>:
.globl vector248
vector248:
  pushl $0
80107a5f:	6a 00                	push   $0x0
  pushl $248
80107a61:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107a66:	e9 f7 ee ff ff       	jmp    80106962 <alltraps>

80107a6b <vector249>:
.globl vector249
vector249:
  pushl $0
80107a6b:	6a 00                	push   $0x0
  pushl $249
80107a6d:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107a72:	e9 eb ee ff ff       	jmp    80106962 <alltraps>

80107a77 <vector250>:
.globl vector250
vector250:
  pushl $0
80107a77:	6a 00                	push   $0x0
  pushl $250
80107a79:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107a7e:	e9 df ee ff ff       	jmp    80106962 <alltraps>

80107a83 <vector251>:
.globl vector251
vector251:
  pushl $0
80107a83:	6a 00                	push   $0x0
  pushl $251
80107a85:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107a8a:	e9 d3 ee ff ff       	jmp    80106962 <alltraps>

80107a8f <vector252>:
.globl vector252
vector252:
  pushl $0
80107a8f:	6a 00                	push   $0x0
  pushl $252
80107a91:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107a96:	e9 c7 ee ff ff       	jmp    80106962 <alltraps>

80107a9b <vector253>:
.globl vector253
vector253:
  pushl $0
80107a9b:	6a 00                	push   $0x0
  pushl $253
80107a9d:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107aa2:	e9 bb ee ff ff       	jmp    80106962 <alltraps>

80107aa7 <vector254>:
.globl vector254
vector254:
  pushl $0
80107aa7:	6a 00                	push   $0x0
  pushl $254
80107aa9:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107aae:	e9 af ee ff ff       	jmp    80106962 <alltraps>

80107ab3 <vector255>:
.globl vector255
vector255:
  pushl $0
80107ab3:	6a 00                	push   $0x0
  pushl $255
80107ab5:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107aba:	e9 a3 ee ff ff       	jmp    80106962 <alltraps>

80107abf <lgdt>:
{
80107abf:	55                   	push   %ebp
80107ac0:	89 e5                	mov    %esp,%ebp
80107ac2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ac8:	83 e8 01             	sub    $0x1,%eax
80107acb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107acf:	8b 45 08             	mov    0x8(%ebp),%eax
80107ad2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107ad6:	8b 45 08             	mov    0x8(%ebp),%eax
80107ad9:	c1 e8 10             	shr    $0x10,%eax
80107adc:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107ae0:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107ae3:	0f 01 10             	lgdtl  (%eax)
}
80107ae6:	90                   	nop
80107ae7:	c9                   	leave  
80107ae8:	c3                   	ret    

80107ae9 <ltr>:
{
80107ae9:	55                   	push   %ebp
80107aea:	89 e5                	mov    %esp,%ebp
80107aec:	83 ec 04             	sub    $0x4,%esp
80107aef:	8b 45 08             	mov    0x8(%ebp),%eax
80107af2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107af6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107afa:	0f 00 d8             	ltr    %ax
}
80107afd:	90                   	nop
80107afe:	c9                   	leave  
80107aff:	c3                   	ret    

80107b00 <lcr3>:

static inline void
lcr3(uint val)
{
80107b00:	55                   	push   %ebp
80107b01:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107b03:	8b 45 08             	mov    0x8(%ebp),%eax
80107b06:	0f 22 d8             	mov    %eax,%cr3
}
80107b09:	90                   	nop
80107b0a:	5d                   	pop    %ebp
80107b0b:	c3                   	ret    

80107b0c <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107b0c:	f3 0f 1e fb          	endbr32 
80107b10:	55                   	push   %ebp
80107b11:	89 e5                	mov    %esp,%ebp
80107b13:	83 ec 18             	sub    $0x18,%esp

    // Map "logical" addresses to virtual addresses using identity map.
    // Cannot share a CODE descriptor for both kernel and user
    // because it would have to have DPL_USR, but the CPU forbids
    // an interrupt from CPL=0 to DPL=3.
    c = &cpus[cpuid()];
80107b16:	e8 d9 c4 ff ff       	call   80103ff4 <cpuid>
80107b1b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107b21:	05 00 b2 11 80       	add    $0x8011b200,%eax
80107b26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    c->gdt[SEG_KCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, 0);
80107b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2c:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b35:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3e:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b45:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b49:	83 e2 f0             	and    $0xfffffff0,%edx
80107b4c:	83 ca 0a             	or     $0xa,%edx
80107b4f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b55:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b59:	83 ca 10             	or     $0x10,%edx
80107b5c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b66:	83 e2 9f             	and    $0xffffff9f,%edx
80107b69:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b73:	83 ca 80             	or     $0xffffff80,%edx
80107b76:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b80:	83 ca 0f             	or     $0xf,%edx
80107b83:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b89:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b8d:	83 e2 ef             	and    $0xffffffef,%edx
80107b90:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b96:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b9a:	83 e2 df             	and    $0xffffffdf,%edx
80107b9d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ba7:	83 ca 40             	or     $0x40,%edx
80107baa:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107bb4:	83 ca 80             	or     $0xffffff80,%edx
80107bb7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbd:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
    c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc4:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107bcb:	ff ff 
80107bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd0:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107bd7:	00 00 
80107bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdc:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bed:	83 e2 f0             	and    $0xfffffff0,%edx
80107bf0:	83 ca 02             	or     $0x2,%edx
80107bf3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c03:	83 ca 10             	or     $0x10,%edx
80107c06:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c16:	83 e2 9f             	and    $0xffffff9f,%edx
80107c19:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c22:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c29:	83 ca 80             	or     $0xffffff80,%edx
80107c2c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c35:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c3c:	83 ca 0f             	or     $0xf,%edx
80107c3f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c4f:	83 e2 ef             	and    $0xffffffef,%edx
80107c52:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c62:	83 e2 df             	and    $0xffffffdf,%edx
80107c65:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c75:	83 ca 40             	or     $0x40,%edx
80107c78:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c81:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c88:	83 ca 80             	or     $0xffffff80,%edx
80107c8b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c94:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
    c->gdt[SEG_UCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, DPL_USER);
80107c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9e:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107ca5:	ff ff 
80107ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caa:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107cb1:	00 00 
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107cc7:	83 e2 f0             	and    $0xfffffff0,%edx
80107cca:	83 ca 0a             	or     $0xa,%edx
80107ccd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107cdd:	83 ca 10             	or     $0x10,%edx
80107ce0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107cf0:	83 ca 60             	or     $0x60,%edx
80107cf3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d03:	83 ca 80             	or     $0xffffff80,%edx
80107d06:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d16:	83 ca 0f             	or     $0xf,%edx
80107d19:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d22:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d29:	83 e2 ef             	and    $0xffffffef,%edx
80107d2c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d35:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d3c:	83 e2 df             	and    $0xffffffdf,%edx
80107d3f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d48:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d4f:	83 ca 40             	or     $0x40,%edx
80107d52:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d62:	83 ca 80             	or     $0xffffff80,%edx
80107d65:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6e:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
    c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d78:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107d7f:	ff ff 
80107d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d84:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107d8b:	00 00 
80107d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d90:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107da1:	83 e2 f0             	and    $0xfffffff0,%edx
80107da4:	83 ca 02             	or     $0x2,%edx
80107da7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107db7:	83 ca 10             	or     $0x10,%edx
80107dba:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107dca:	83 ca 60             	or     $0x60,%edx
80107dcd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ddd:	83 ca 80             	or     $0xffffff80,%edx
80107de0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107df0:	83 ca 0f             	or     $0xf,%edx
80107df3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e03:	83 e2 ef             	and    $0xffffffef,%edx
80107e06:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e16:	83 e2 df             	and    $0xffffffdf,%edx
80107e19:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e22:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e29:	83 ca 40             	or     $0x40,%edx
80107e2c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e35:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e3c:	83 ca 80             	or     $0xffffff80,%edx
80107e3f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e48:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
    lgdt(c->gdt, sizeof(c->gdt));
80107e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e52:	83 c0 70             	add    $0x70,%eax
80107e55:	83 ec 08             	sub    $0x8,%esp
80107e58:	6a 30                	push   $0x30
80107e5a:	50                   	push   %eax
80107e5b:	e8 5f fc ff ff       	call   80107abf <lgdt>
80107e60:	83 c4 10             	add    $0x10,%esp
}
80107e63:	90                   	nop
80107e64:	c9                   	leave  
80107e65:	c3                   	ret    

80107e66 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t*
walkpgdir(pde_t* pgdir, const void* va, int alloc)
{
80107e66:	f3 0f 1e fb          	endbr32 
80107e6a:	55                   	push   %ebp
80107e6b:	89 e5                	mov    %esp,%ebp
80107e6d:	83 ec 18             	sub    $0x18,%esp
    pde_t* pde;
    pte_t* pgtab;

    pde = &pgdir[PDX(va)];
80107e70:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e73:	c1 e8 16             	shr    $0x16,%eax
80107e76:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80107e80:	01 d0                	add    %edx,%eax
80107e82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (*pde & PTE_P) {
80107e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e88:	8b 00                	mov    (%eax),%eax
80107e8a:	83 e0 01             	and    $0x1,%eax
80107e8d:	85 c0                	test   %eax,%eax
80107e8f:	74 14                	je     80107ea5 <walkpgdir+0x3f>
        pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e94:	8b 00                	mov    (%eax),%eax
80107e96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e9b:	05 00 00 00 80       	add    $0x80000000,%eax
80107ea0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ea3:	eb 42                	jmp    80107ee7 <walkpgdir+0x81>
    }
    else {
        if (!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ea5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ea9:	74 0e                	je     80107eb9 <walkpgdir+0x53>
80107eab:	e8 c8 ae ff ff       	call   80102d78 <kalloc>
80107eb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107eb3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107eb7:	75 07                	jne    80107ec0 <walkpgdir+0x5a>
            return 0;
80107eb9:	b8 00 00 00 00       	mov    $0x0,%eax
80107ebe:	eb 3e                	jmp    80107efe <walkpgdir+0x98>
        // Make sure all those PTE_P bits are zero.
        memset(pgtab, 0, PGSIZE);
80107ec0:	83 ec 04             	sub    $0x4,%esp
80107ec3:	68 00 10 00 00       	push   $0x1000
80107ec8:	6a 00                	push   $0x0
80107eca:	ff 75 f4             	pushl  -0xc(%ebp)
80107ecd:	e8 8d d5 ff ff       	call   8010545f <memset>
80107ed2:	83 c4 10             	add    $0x10,%esp
        // The permissions here are overly generous, but they can
        // be further restricted by the permissions in the page table
        // entries, if necessary.
        *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed8:	05 00 00 00 80       	add    $0x80000000,%eax
80107edd:	83 c8 07             	or     $0x7,%eax
80107ee0:	89 c2                	mov    %eax,%edx
80107ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ee5:	89 10                	mov    %edx,(%eax)
    }
    return &pgtab[PTX(va)];
80107ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eea:	c1 e8 0c             	shr    $0xc,%eax
80107eed:	25 ff 03 00 00       	and    $0x3ff,%eax
80107ef2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efc:	01 d0                	add    %edx,%eax
}
80107efe:	c9                   	leave  
80107eff:	c3                   	ret    

80107f00 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t* pgdir, void* va, uint size, uint pa, int perm)
{
80107f00:	f3 0f 1e fb          	endbr32 
80107f04:	55                   	push   %ebp
80107f05:	89 e5                	mov    %esp,%ebp
80107f07:	83 ec 18             	sub    $0x18,%esp
    char* a, * last;
    pte_t* pte;

    a = (char*)PGROUNDDOWN((uint)va);
80107f0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f15:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f18:	8b 45 10             	mov    0x10(%ebp),%eax
80107f1b:	01 d0                	add    %edx,%eax
80107f1d:	83 e8 01             	sub    $0x1,%eax
80107f20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f25:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (;;) {
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f28:	83 ec 04             	sub    $0x4,%esp
80107f2b:	6a 01                	push   $0x1
80107f2d:	ff 75 f4             	pushl  -0xc(%ebp)
80107f30:	ff 75 08             	pushl  0x8(%ebp)
80107f33:	e8 2e ff ff ff       	call   80107e66 <walkpgdir>
80107f38:	83 c4 10             	add    $0x10,%esp
80107f3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f3e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f42:	75 07                	jne    80107f4b <mappages+0x4b>
            return -1;
80107f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f49:	eb 47                	jmp    80107f92 <mappages+0x92>
        if (*pte & PTE_P)
80107f4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f4e:	8b 00                	mov    (%eax),%eax
80107f50:	83 e0 01             	and    $0x1,%eax
80107f53:	85 c0                	test   %eax,%eax
80107f55:	74 0d                	je     80107f64 <mappages+0x64>
            panic("remap");
80107f57:	83 ec 0c             	sub    $0xc,%esp
80107f5a:	68 d4 b4 10 80       	push   $0x8010b4d4
80107f5f:	e8 61 86 ff ff       	call   801005c5 <panic>
        *pte = pa | perm | PTE_P;
80107f64:	8b 45 18             	mov    0x18(%ebp),%eax
80107f67:	0b 45 14             	or     0x14(%ebp),%eax
80107f6a:	83 c8 01             	or     $0x1,%eax
80107f6d:	89 c2                	mov    %eax,%edx
80107f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f72:	89 10                	mov    %edx,(%eax)
        if (a == last)
80107f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f77:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f7a:	74 10                	je     80107f8c <mappages+0x8c>
            break;
        a += PGSIZE;
80107f7c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
        pa += PGSIZE;
80107f83:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f8a:	eb 9c                	jmp    80107f28 <mappages+0x28>
            break;
80107f8c:	90                   	nop
    }
    return 0;
80107f8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f92:	c9                   	leave  
80107f93:	c3                   	ret    

80107f94 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107f94:	f3 0f 1e fb          	endbr32 
80107f98:	55                   	push   %ebp
80107f99:	89 e5                	mov    %esp,%ebp
80107f9b:	53                   	push   %ebx
80107f9c:	83 ec 14             	sub    $0x14,%esp
    pde_t* pgdir;
    struct kmap* k;

    if ((pgdir = (pde_t*)kalloc()) == 0)
80107f9f:	e8 d4 ad ff ff       	call   80102d78 <kalloc>
80107fa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fa7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fab:	75 07                	jne    80107fb4 <setupkvm+0x20>
        return 0;
80107fad:	b8 00 00 00 00       	mov    $0x0,%eax
80107fb2:	eb 78                	jmp    8010802c <setupkvm+0x98>
    memset(pgdir, 0, PGSIZE);
80107fb4:	83 ec 04             	sub    $0x4,%esp
80107fb7:	68 00 10 00 00       	push   $0x1000
80107fbc:	6a 00                	push   $0x0
80107fbe:	ff 75 f0             	pushl  -0x10(%ebp)
80107fc1:	e8 99 d4 ff ff       	call   8010545f <memset>
80107fc6:	83 c4 10             	add    $0x10,%esp
    if (P2V(PHYSTOP) > (void*)DEVSPACE)
        panic("PHYSTOP too high");
    for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107fc9:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107fd0:	eb 4e                	jmp    80108020 <setupkvm+0x8c>
        if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd5:	8b 48 0c             	mov    0xc(%eax),%ecx
            (uint)k->phys_start, k->perm) < 0) {
80107fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fdb:	8b 50 04             	mov    0x4(%eax),%edx
        if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe1:	8b 58 08             	mov    0x8(%eax),%ebx
80107fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe7:	8b 40 04             	mov    0x4(%eax),%eax
80107fea:	29 c3                	sub    %eax,%ebx
80107fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fef:	8b 00                	mov    (%eax),%eax
80107ff1:	83 ec 0c             	sub    $0xc,%esp
80107ff4:	51                   	push   %ecx
80107ff5:	52                   	push   %edx
80107ff6:	53                   	push   %ebx
80107ff7:	50                   	push   %eax
80107ff8:	ff 75 f0             	pushl  -0x10(%ebp)
80107ffb:	e8 00 ff ff ff       	call   80107f00 <mappages>
80108000:	83 c4 20             	add    $0x20,%esp
80108003:	85 c0                	test   %eax,%eax
80108005:	79 15                	jns    8010801c <setupkvm+0x88>
            freevm(pgdir);
80108007:	83 ec 0c             	sub    $0xc,%esp
8010800a:	ff 75 f0             	pushl  -0x10(%ebp)
8010800d:	e8 11 05 00 00       	call   80108523 <freevm>
80108012:	83 c4 10             	add    $0x10,%esp
            return 0;
80108015:	b8 00 00 00 00       	mov    $0x0,%eax
8010801a:	eb 10                	jmp    8010802c <setupkvm+0x98>
    for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010801c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108020:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80108027:	72 a9                	jb     80107fd2 <setupkvm+0x3e>
        }
    return pgdir;
80108029:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010802c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010802f:	c9                   	leave  
80108030:	c3                   	ret    

80108031 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108031:	f3 0f 1e fb          	endbr32 
80108035:	55                   	push   %ebp
80108036:	89 e5                	mov    %esp,%ebp
80108038:	83 ec 08             	sub    $0x8,%esp
    kpgdir = setupkvm();
8010803b:	e8 54 ff ff ff       	call   80107f94 <setupkvm>
80108040:	a3 c4 b1 11 80       	mov    %eax,0x8011b1c4
    switchkvm();
80108045:	e8 03 00 00 00       	call   8010804d <switchkvm>
}
8010804a:	90                   	nop
8010804b:	c9                   	leave  
8010804c:	c3                   	ret    

8010804d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010804d:	f3 0f 1e fb          	endbr32 
80108051:	55                   	push   %ebp
80108052:	89 e5                	mov    %esp,%ebp
    lcr3(V2P(kpgdir));   // switch to the kernel page table
80108054:	a1 c4 b1 11 80       	mov    0x8011b1c4,%eax
80108059:	05 00 00 00 80       	add    $0x80000000,%eax
8010805e:	50                   	push   %eax
8010805f:	e8 9c fa ff ff       	call   80107b00 <lcr3>
80108064:	83 c4 04             	add    $0x4,%esp
}
80108067:	90                   	nop
80108068:	c9                   	leave  
80108069:	c3                   	ret    

8010806a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc* p)
{
8010806a:	f3 0f 1e fb          	endbr32 
8010806e:	55                   	push   %ebp
8010806f:	89 e5                	mov    %esp,%ebp
80108071:	56                   	push   %esi
80108072:	53                   	push   %ebx
80108073:	83 ec 10             	sub    $0x10,%esp
    if (p == 0)
80108076:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010807a:	75 0d                	jne    80108089 <switchuvm+0x1f>
        panic("switchuvm: no process");
8010807c:	83 ec 0c             	sub    $0xc,%esp
8010807f:	68 da b4 10 80       	push   $0x8010b4da
80108084:	e8 3c 85 ff ff       	call   801005c5 <panic>
    if (p->kstack == 0)
80108089:	8b 45 08             	mov    0x8(%ebp),%eax
8010808c:	8b 40 08             	mov    0x8(%eax),%eax
8010808f:	85 c0                	test   %eax,%eax
80108091:	75 0d                	jne    801080a0 <switchuvm+0x36>
        panic("switchuvm: no kstack");
80108093:	83 ec 0c             	sub    $0xc,%esp
80108096:	68 f0 b4 10 80       	push   $0x8010b4f0
8010809b:	e8 25 85 ff ff       	call   801005c5 <panic>
    if (p->pgdir == 0)
801080a0:	8b 45 08             	mov    0x8(%ebp),%eax
801080a3:	8b 40 04             	mov    0x4(%eax),%eax
801080a6:	85 c0                	test   %eax,%eax
801080a8:	75 0d                	jne    801080b7 <switchuvm+0x4d>
        panic("switchuvm: no pgdir");
801080aa:	83 ec 0c             	sub    $0xc,%esp
801080ad:	68 05 b5 10 80       	push   $0x8010b505
801080b2:	e8 0e 85 ff ff       	call   801005c5 <panic>

    pushcli();
801080b7:	e8 90 d2 ff ff       	call   8010534c <pushcli>
    mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801080bc:	e8 52 bf ff ff       	call   80104013 <mycpu>
801080c1:	89 c3                	mov    %eax,%ebx
801080c3:	e8 4b bf ff ff       	call   80104013 <mycpu>
801080c8:	83 c0 08             	add    $0x8,%eax
801080cb:	89 c6                	mov    %eax,%esi
801080cd:	e8 41 bf ff ff       	call   80104013 <mycpu>
801080d2:	83 c0 08             	add    $0x8,%eax
801080d5:	c1 e8 10             	shr    $0x10,%eax
801080d8:	88 45 f7             	mov    %al,-0x9(%ebp)
801080db:	e8 33 bf ff ff       	call   80104013 <mycpu>
801080e0:	83 c0 08             	add    $0x8,%eax
801080e3:	c1 e8 18             	shr    $0x18,%eax
801080e6:	89 c2                	mov    %eax,%edx
801080e8:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801080ef:	67 00 
801080f1:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801080f8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801080fc:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108102:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108109:	83 e0 f0             	and    $0xfffffff0,%eax
8010810c:	83 c8 09             	or     $0x9,%eax
8010810f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108115:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010811c:	83 c8 10             	or     $0x10,%eax
8010811f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108125:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010812c:	83 e0 9f             	and    $0xffffff9f,%eax
8010812f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108135:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010813c:	83 c8 80             	or     $0xffffff80,%eax
8010813f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108145:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010814c:	83 e0 f0             	and    $0xfffffff0,%eax
8010814f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108155:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010815c:	83 e0 ef             	and    $0xffffffef,%eax
8010815f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108165:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010816c:	83 e0 df             	and    $0xffffffdf,%eax
8010816f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108175:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010817c:	83 c8 40             	or     $0x40,%eax
8010817f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108185:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010818c:	83 e0 7f             	and    $0x7f,%eax
8010818f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108195:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
        sizeof(mycpu()->ts) - 1, 0);
    mycpu()->gdt[SEG_TSS].s = 0;
8010819b:	e8 73 be ff ff       	call   80104013 <mycpu>
801081a0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801081a7:	83 e2 ef             	and    $0xffffffef,%edx
801081aa:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
    mycpu()->ts.ss0 = SEG_KDATA << 3;
801081b0:	e8 5e be ff ff       	call   80104013 <mycpu>
801081b5:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
    mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801081bb:	8b 45 08             	mov    0x8(%ebp),%eax
801081be:	8b 40 08             	mov    0x8(%eax),%eax
801081c1:	89 c3                	mov    %eax,%ebx
801081c3:	e8 4b be ff ff       	call   80104013 <mycpu>
801081c8:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801081ce:	89 50 0c             	mov    %edx,0xc(%eax)
    // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
    // forbids I/O instructions (e.g., inb and outb) from user space
    mycpu()->ts.iomb = (ushort)0xFFFF;
801081d1:	e8 3d be ff ff       	call   80104013 <mycpu>
801081d6:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
    ltr(SEG_TSS << 3);
801081dc:	83 ec 0c             	sub    $0xc,%esp
801081df:	6a 28                	push   $0x28
801081e1:	e8 03 f9 ff ff       	call   80107ae9 <ltr>
801081e6:	83 c4 10             	add    $0x10,%esp
    lcr3(V2P(p->pgdir));  // switch to process's address space
801081e9:	8b 45 08             	mov    0x8(%ebp),%eax
801081ec:	8b 40 04             	mov    0x4(%eax),%eax
801081ef:	05 00 00 00 80       	add    $0x80000000,%eax
801081f4:	83 ec 0c             	sub    $0xc,%esp
801081f7:	50                   	push   %eax
801081f8:	e8 03 f9 ff ff       	call   80107b00 <lcr3>
801081fd:	83 c4 10             	add    $0x10,%esp
    popcli();
80108200:	e8 98 d1 ff ff       	call   8010539d <popcli>
}
80108205:	90                   	nop
80108206:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108209:	5b                   	pop    %ebx
8010820a:	5e                   	pop    %esi
8010820b:	5d                   	pop    %ebp
8010820c:	c3                   	ret    

8010820d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t* pgdir, char* init, uint sz)
{
8010820d:	f3 0f 1e fb          	endbr32 
80108211:	55                   	push   %ebp
80108212:	89 e5                	mov    %esp,%ebp
80108214:	83 ec 18             	sub    $0x18,%esp
    char* mem;

    if (sz >= PGSIZE)
80108217:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010821e:	76 0d                	jbe    8010822d <inituvm+0x20>
        panic("inituvm: more than a page");
80108220:	83 ec 0c             	sub    $0xc,%esp
80108223:	68 19 b5 10 80       	push   $0x8010b519
80108228:	e8 98 83 ff ff       	call   801005c5 <panic>
    mem = kalloc();
8010822d:	e8 46 ab ff ff       	call   80102d78 <kalloc>
80108232:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memset(mem, 0, PGSIZE);
80108235:	83 ec 04             	sub    $0x4,%esp
80108238:	68 00 10 00 00       	push   $0x1000
8010823d:	6a 00                	push   $0x0
8010823f:	ff 75 f4             	pushl  -0xc(%ebp)
80108242:	e8 18 d2 ff ff       	call   8010545f <memset>
80108247:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W | PTE_U);
8010824a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824d:	05 00 00 00 80       	add    $0x80000000,%eax
80108252:	83 ec 0c             	sub    $0xc,%esp
80108255:	6a 06                	push   $0x6
80108257:	50                   	push   %eax
80108258:	68 00 10 00 00       	push   $0x1000
8010825d:	6a 00                	push   $0x0
8010825f:	ff 75 08             	pushl  0x8(%ebp)
80108262:	e8 99 fc ff ff       	call   80107f00 <mappages>
80108267:	83 c4 20             	add    $0x20,%esp
    memmove(mem, init, sz);
8010826a:	83 ec 04             	sub    $0x4,%esp
8010826d:	ff 75 10             	pushl  0x10(%ebp)
80108270:	ff 75 0c             	pushl  0xc(%ebp)
80108273:	ff 75 f4             	pushl  -0xc(%ebp)
80108276:	e8 ab d2 ff ff       	call   80105526 <memmove>
8010827b:	83 c4 10             	add    $0x10,%esp
}
8010827e:	90                   	nop
8010827f:	c9                   	leave  
80108280:	c3                   	ret    

80108281 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t* pgdir, char* addr, struct inode* ip, uint offset, uint sz)
{
80108281:	f3 0f 1e fb          	endbr32 
80108285:	55                   	push   %ebp
80108286:	89 e5                	mov    %esp,%ebp
80108288:	83 ec 18             	sub    $0x18,%esp
    uint i, pa, n;
    pte_t* pte;

    if ((uint)addr % PGSIZE != 0)
8010828b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010828e:	25 ff 0f 00 00       	and    $0xfff,%eax
80108293:	85 c0                	test   %eax,%eax
80108295:	74 0d                	je     801082a4 <loaduvm+0x23>
        panic("loaduvm: addr must be page aligned");
80108297:	83 ec 0c             	sub    $0xc,%esp
8010829a:	68 34 b5 10 80       	push   $0x8010b534
8010829f:	e8 21 83 ff ff       	call   801005c5 <panic>
    for (i = 0; i < sz; i += PGSIZE) {
801082a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082ab:	e9 8f 00 00 00       	jmp    8010833f <loaduvm+0xbe>
        if ((pte = walkpgdir(pgdir, addr + i, 0)) == 0)
801082b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801082b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b6:	01 d0                	add    %edx,%eax
801082b8:	83 ec 04             	sub    $0x4,%esp
801082bb:	6a 00                	push   $0x0
801082bd:	50                   	push   %eax
801082be:	ff 75 08             	pushl  0x8(%ebp)
801082c1:	e8 a0 fb ff ff       	call   80107e66 <walkpgdir>
801082c6:	83 c4 10             	add    $0x10,%esp
801082c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082d0:	75 0d                	jne    801082df <loaduvm+0x5e>
            panic("loaduvm: address should exist");
801082d2:	83 ec 0c             	sub    $0xc,%esp
801082d5:	68 57 b5 10 80       	push   $0x8010b557
801082da:	e8 e6 82 ff ff       	call   801005c5 <panic>
        pa = PTE_ADDR(*pte);
801082df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e2:	8b 00                	mov    (%eax),%eax
801082e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (sz - i < PGSIZE)
801082ec:	8b 45 18             	mov    0x18(%ebp),%eax
801082ef:	2b 45 f4             	sub    -0xc(%ebp),%eax
801082f2:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801082f7:	77 0b                	ja     80108304 <loaduvm+0x83>
            n = sz - i;
801082f9:	8b 45 18             	mov    0x18(%ebp),%eax
801082fc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801082ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108302:	eb 07                	jmp    8010830b <loaduvm+0x8a>
        else
            n = PGSIZE;
80108304:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
        if (readi(ip, P2V(pa), offset + i, n) != n)
8010830b:	8b 55 14             	mov    0x14(%ebp),%edx
8010830e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108311:	01 d0                	add    %edx,%eax
80108313:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108316:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010831c:	ff 75 f0             	pushl  -0x10(%ebp)
8010831f:	50                   	push   %eax
80108320:	52                   	push   %edx
80108321:	ff 75 10             	pushl  0x10(%ebp)
80108324:	e8 49 9c ff ff       	call   80101f72 <readi>
80108329:	83 c4 10             	add    $0x10,%esp
8010832c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010832f:	74 07                	je     80108338 <loaduvm+0xb7>
            return -1;
80108331:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108336:	eb 18                	jmp    80108350 <loaduvm+0xcf>
    for (i = 0; i < sz; i += PGSIZE) {
80108338:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010833f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108342:	3b 45 18             	cmp    0x18(%ebp),%eax
80108345:	0f 82 65 ff ff ff    	jb     801082b0 <loaduvm+0x2f>
    }
    return 0;
8010834b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108350:	c9                   	leave  
80108351:	c3                   	ret    

80108352 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t* pgdir, uint oldsz, uint newsz)
{
80108352:	f3 0f 1e fb          	endbr32 
80108356:	55                   	push   %ebp
80108357:	89 e5                	mov    %esp,%ebp
80108359:	83 ec 18             	sub    $0x18,%esp
    char* mem;
    uint a;

    if (newsz >= KERNBASE)
8010835c:	8b 45 10             	mov    0x10(%ebp),%eax
8010835f:	85 c0                	test   %eax,%eax
80108361:	79 0a                	jns    8010836d <allocuvm+0x1b>
        return 0;
80108363:	b8 00 00 00 00       	mov    $0x0,%eax
80108368:	e9 ec 00 00 00       	jmp    80108459 <allocuvm+0x107>
    if (newsz < oldsz)
8010836d:	8b 45 10             	mov    0x10(%ebp),%eax
80108370:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108373:	73 08                	jae    8010837d <allocuvm+0x2b>
        return oldsz;
80108375:	8b 45 0c             	mov    0xc(%ebp),%eax
80108378:	e9 dc 00 00 00       	jmp    80108459 <allocuvm+0x107>

    a = PGROUNDUP(oldsz);
8010837d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108380:	05 ff 0f 00 00       	add    $0xfff,%eax
80108385:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010838a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; a < newsz; a += PGSIZE) {
8010838d:	e9 b8 00 00 00       	jmp    8010844a <allocuvm+0xf8>
        mem = kalloc();
80108392:	e8 e1 a9 ff ff       	call   80102d78 <kalloc>
80108397:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (mem == 0) {
8010839a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010839e:	75 2e                	jne    801083ce <allocuvm+0x7c>
            cprintf("allocuvm out of memory\n");
801083a0:	83 ec 0c             	sub    $0xc,%esp
801083a3:	68 75 b5 10 80       	push   $0x8010b575
801083a8:	e8 5f 80 ff ff       	call   8010040c <cprintf>
801083ad:	83 c4 10             	add    $0x10,%esp
            deallocuvm(pgdir, newsz, oldsz);
801083b0:	83 ec 04             	sub    $0x4,%esp
801083b3:	ff 75 0c             	pushl  0xc(%ebp)
801083b6:	ff 75 10             	pushl  0x10(%ebp)
801083b9:	ff 75 08             	pushl  0x8(%ebp)
801083bc:	e8 9a 00 00 00       	call   8010845b <deallocuvm>
801083c1:	83 c4 10             	add    $0x10,%esp
            return 0;
801083c4:	b8 00 00 00 00       	mov    $0x0,%eax
801083c9:	e9 8b 00 00 00       	jmp    80108459 <allocuvm+0x107>
        }
        memset(mem, 0, PGSIZE);
801083ce:	83 ec 04             	sub    $0x4,%esp
801083d1:	68 00 10 00 00       	push   $0x1000
801083d6:	6a 00                	push   $0x0
801083d8:	ff 75 f0             	pushl  -0x10(%ebp)
801083db:	e8 7f d0 ff ff       	call   8010545f <memset>
801083e0:	83 c4 10             	add    $0x10,%esp
        if (mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
801083e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083e6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801083ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ef:	83 ec 0c             	sub    $0xc,%esp
801083f2:	6a 06                	push   $0x6
801083f4:	52                   	push   %edx
801083f5:	68 00 10 00 00       	push   $0x1000
801083fa:	50                   	push   %eax
801083fb:	ff 75 08             	pushl  0x8(%ebp)
801083fe:	e8 fd fa ff ff       	call   80107f00 <mappages>
80108403:	83 c4 20             	add    $0x20,%esp
80108406:	85 c0                	test   %eax,%eax
80108408:	79 39                	jns    80108443 <allocuvm+0xf1>
            cprintf("allocuvm out of memory (2)\n");
8010840a:	83 ec 0c             	sub    $0xc,%esp
8010840d:	68 8d b5 10 80       	push   $0x8010b58d
80108412:	e8 f5 7f ff ff       	call   8010040c <cprintf>
80108417:	83 c4 10             	add    $0x10,%esp
            deallocuvm(pgdir, newsz, oldsz);
8010841a:	83 ec 04             	sub    $0x4,%esp
8010841d:	ff 75 0c             	pushl  0xc(%ebp)
80108420:	ff 75 10             	pushl  0x10(%ebp)
80108423:	ff 75 08             	pushl  0x8(%ebp)
80108426:	e8 30 00 00 00       	call   8010845b <deallocuvm>
8010842b:	83 c4 10             	add    $0x10,%esp
            kfree(mem);
8010842e:	83 ec 0c             	sub    $0xc,%esp
80108431:	ff 75 f0             	pushl  -0x10(%ebp)
80108434:	e8 a1 a8 ff ff       	call   80102cda <kfree>
80108439:	83 c4 10             	add    $0x10,%esp
            return 0;
8010843c:	b8 00 00 00 00       	mov    $0x0,%eax
80108441:	eb 16                	jmp    80108459 <allocuvm+0x107>
    for (; a < newsz; a += PGSIZE) {
80108443:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010844a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844d:	3b 45 10             	cmp    0x10(%ebp),%eax
80108450:	0f 82 3c ff ff ff    	jb     80108392 <allocuvm+0x40>
        }
    }
    return newsz;
80108456:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108459:	c9                   	leave  
8010845a:	c3                   	ret    

8010845b <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t* pgdir, uint oldsz, uint newsz)
{
8010845b:	f3 0f 1e fb          	endbr32 
8010845f:	55                   	push   %ebp
80108460:	89 e5                	mov    %esp,%ebp
80108462:	83 ec 18             	sub    $0x18,%esp
    pte_t* pte;
    uint a, pa;

    if (newsz >= oldsz)
80108465:	8b 45 10             	mov    0x10(%ebp),%eax
80108468:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010846b:	72 08                	jb     80108475 <deallocuvm+0x1a>
        return oldsz;
8010846d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108470:	e9 ac 00 00 00       	jmp    80108521 <deallocuvm+0xc6>

    a = PGROUNDUP(newsz);
80108475:	8b 45 10             	mov    0x10(%ebp),%eax
80108478:	05 ff 0f 00 00       	add    $0xfff,%eax
8010847d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108482:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; a < oldsz; a += PGSIZE) {
80108485:	e9 88 00 00 00       	jmp    80108512 <deallocuvm+0xb7>
        pte = walkpgdir(pgdir, (char*)a, 0);
8010848a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848d:	83 ec 04             	sub    $0x4,%esp
80108490:	6a 00                	push   $0x0
80108492:	50                   	push   %eax
80108493:	ff 75 08             	pushl  0x8(%ebp)
80108496:	e8 cb f9 ff ff       	call   80107e66 <walkpgdir>
8010849b:	83 c4 10             	add    $0x10,%esp
8010849e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (!pte)
801084a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084a5:	75 16                	jne    801084bd <deallocuvm+0x62>
            a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801084a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084aa:	c1 e8 16             	shr    $0x16,%eax
801084ad:	83 c0 01             	add    $0x1,%eax
801084b0:	c1 e0 16             	shl    $0x16,%eax
801084b3:	2d 00 10 00 00       	sub    $0x1000,%eax
801084b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801084bb:	eb 4e                	jmp    8010850b <deallocuvm+0xb0>
        else if ((*pte & PTE_P) != 0) {
801084bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084c0:	8b 00                	mov    (%eax),%eax
801084c2:	83 e0 01             	and    $0x1,%eax
801084c5:	85 c0                	test   %eax,%eax
801084c7:	74 42                	je     8010850b <deallocuvm+0xb0>
            pa = PTE_ADDR(*pte);
801084c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084cc:	8b 00                	mov    (%eax),%eax
801084ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (pa == 0)
801084d6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084da:	75 0d                	jne    801084e9 <deallocuvm+0x8e>
                panic("kfree");
801084dc:	83 ec 0c             	sub    $0xc,%esp
801084df:	68 a9 b5 10 80       	push   $0x8010b5a9
801084e4:	e8 dc 80 ff ff       	call   801005c5 <panic>
            char* v = P2V(pa);
801084e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ec:	05 00 00 00 80       	add    $0x80000000,%eax
801084f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
            kfree(v);
801084f4:	83 ec 0c             	sub    $0xc,%esp
801084f7:	ff 75 e8             	pushl  -0x18(%ebp)
801084fa:	e8 db a7 ff ff       	call   80102cda <kfree>
801084ff:	83 c4 10             	add    $0x10,%esp
            *pte = 0;
80108502:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108505:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    for (; a < oldsz; a += PGSIZE) {
8010850b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108515:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108518:	0f 82 6c ff ff ff    	jb     8010848a <deallocuvm+0x2f>
        }
    }
    return newsz;
8010851e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108521:	c9                   	leave  
80108522:	c3                   	ret    

80108523 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t* pgdir)
{
80108523:	f3 0f 1e fb          	endbr32 
80108527:	55                   	push   %ebp
80108528:	89 e5                	mov    %esp,%ebp
8010852a:	83 ec 18             	sub    $0x18,%esp
    uint i;

    if (pgdir == 0)
8010852d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108531:	75 0d                	jne    80108540 <freevm+0x1d>
        panic("freevm: no pgdir");
80108533:	83 ec 0c             	sub    $0xc,%esp
80108536:	68 af b5 10 80       	push   $0x8010b5af
8010853b:	e8 85 80 ff ff       	call   801005c5 <panic>
    deallocuvm(pgdir, KERNBASE, 0);
80108540:	83 ec 04             	sub    $0x4,%esp
80108543:	6a 00                	push   $0x0
80108545:	68 00 00 00 80       	push   $0x80000000
8010854a:	ff 75 08             	pushl  0x8(%ebp)
8010854d:	e8 09 ff ff ff       	call   8010845b <deallocuvm>
80108552:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NPDENTRIES; i++) {
80108555:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010855c:	eb 48                	jmp    801085a6 <freevm+0x83>
        if (pgdir[i] & PTE_P) {
8010855e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108561:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108568:	8b 45 08             	mov    0x8(%ebp),%eax
8010856b:	01 d0                	add    %edx,%eax
8010856d:	8b 00                	mov    (%eax),%eax
8010856f:	83 e0 01             	and    $0x1,%eax
80108572:	85 c0                	test   %eax,%eax
80108574:	74 2c                	je     801085a2 <freevm+0x7f>
            char* v = P2V(PTE_ADDR(pgdir[i]));
80108576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108579:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108580:	8b 45 08             	mov    0x8(%ebp),%eax
80108583:	01 d0                	add    %edx,%eax
80108585:	8b 00                	mov    (%eax),%eax
80108587:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010858c:	05 00 00 00 80       	add    $0x80000000,%eax
80108591:	89 45 f0             	mov    %eax,-0x10(%ebp)
            kfree(v);
80108594:	83 ec 0c             	sub    $0xc,%esp
80108597:	ff 75 f0             	pushl  -0x10(%ebp)
8010859a:	e8 3b a7 ff ff       	call   80102cda <kfree>
8010859f:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NPDENTRIES; i++) {
801085a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085a6:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801085ad:	76 af                	jbe    8010855e <freevm+0x3b>
        }
    }
    kfree((char*)pgdir);
801085af:	83 ec 0c             	sub    $0xc,%esp
801085b2:	ff 75 08             	pushl  0x8(%ebp)
801085b5:	e8 20 a7 ff ff       	call   80102cda <kfree>
801085ba:	83 c4 10             	add    $0x10,%esp
}
801085bd:	90                   	nop
801085be:	c9                   	leave  
801085bf:	c3                   	ret    

801085c0 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t* pgdir, char* uva)
{
801085c0:	f3 0f 1e fb          	endbr32 
801085c4:	55                   	push   %ebp
801085c5:	89 e5                	mov    %esp,%ebp
801085c7:	83 ec 18             	sub    $0x18,%esp
    pte_t* pte;

    pte = walkpgdir(pgdir, uva, 0);
801085ca:	83 ec 04             	sub    $0x4,%esp
801085cd:	6a 00                	push   $0x0
801085cf:	ff 75 0c             	pushl  0xc(%ebp)
801085d2:	ff 75 08             	pushl  0x8(%ebp)
801085d5:	e8 8c f8 ff ff       	call   80107e66 <walkpgdir>
801085da:	83 c4 10             	add    $0x10,%esp
801085dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (pte == 0)
801085e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801085e4:	75 0d                	jne    801085f3 <clearpteu+0x33>
        panic("clearpteu");
801085e6:	83 ec 0c             	sub    $0xc,%esp
801085e9:	68 c0 b5 10 80       	push   $0x8010b5c0
801085ee:	e8 d2 7f ff ff       	call   801005c5 <panic>
    *pte &= ~PTE_U;
801085f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f6:	8b 00                	mov    (%eax),%eax
801085f8:	83 e0 fb             	and    $0xfffffffb,%eax
801085fb:	89 c2                	mov    %eax,%edx
801085fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108600:	89 10                	mov    %edx,(%eax)
}
80108602:	90                   	nop
80108603:	c9                   	leave  
80108604:	c3                   	ret    

80108605 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t* pgdir, uint sz)
{
80108605:	f3 0f 1e fb          	endbr32 
80108609:	55                   	push   %ebp
8010860a:	89 e5                	mov    %esp,%ebp
8010860c:	83 ec 28             	sub    $0x28,%esp
    pde_t* d;
    pte_t* pte;
    uint pa, i, flags;
    char* mem;

    if ((d = setupkvm()) == 0)
8010860f:	e8 80 f9 ff ff       	call   80107f94 <setupkvm>
80108614:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108617:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010861b:	75 0a                	jne    80108627 <copyuvm+0x22>
        return 0;
8010861d:	b8 00 00 00 00       	mov    $0x0,%eax
80108622:	e9 e7 01 00 00       	jmp    8010880e <copyuvm+0x209>
    for (i = 0; i < sz; i += PGSIZE) {
80108627:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010862e:	e9 bf 00 00 00       	jmp    801086f2 <copyuvm+0xed>
        if ((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
80108633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108636:	83 ec 04             	sub    $0x4,%esp
80108639:	6a 00                	push   $0x0
8010863b:	50                   	push   %eax
8010863c:	ff 75 08             	pushl  0x8(%ebp)
8010863f:	e8 22 f8 ff ff       	call   80107e66 <walkpgdir>
80108644:	83 c4 10             	add    $0x10,%esp
80108647:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010864a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010864e:	75 0d                	jne    8010865d <copyuvm+0x58>
            panic("copyuvm: pte should exist");
80108650:	83 ec 0c             	sub    $0xc,%esp
80108653:	68 ca b5 10 80       	push   $0x8010b5ca
80108658:	e8 68 7f ff ff       	call   801005c5 <panic>
        if (!(*pte & PTE_P))
8010865d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108660:	8b 00                	mov    (%eax),%eax
80108662:	83 e0 01             	and    $0x1,%eax
80108665:	85 c0                	test   %eax,%eax
80108667:	75 0d                	jne    80108676 <copyuvm+0x71>
            panic("copyuvm: page not present");
80108669:	83 ec 0c             	sub    $0xc,%esp
8010866c:	68 e4 b5 10 80       	push   $0x8010b5e4
80108671:	e8 4f 7f ff ff       	call   801005c5 <panic>
        pa = PTE_ADDR(*pte);
80108676:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108679:	8b 00                	mov    (%eax),%eax
8010867b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108680:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        flags = PTE_FLAGS(*pte);
80108683:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108686:	8b 00                	mov    (%eax),%eax
80108688:	25 ff 0f 00 00       	and    $0xfff,%eax
8010868d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if ((mem = kalloc()) == 0)
80108690:	e8 e3 a6 ff ff       	call   80102d78 <kalloc>
80108695:	89 45 dc             	mov    %eax,-0x24(%ebp)
80108698:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010869c:	0f 84 52 01 00 00    	je     801087f4 <copyuvm+0x1ef>
            goto bad;
        memmove(mem, (char*)P2V(pa), PGSIZE);
801086a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086a5:	05 00 00 00 80       	add    $0x80000000,%eax
801086aa:	83 ec 04             	sub    $0x4,%esp
801086ad:	68 00 10 00 00       	push   $0x1000
801086b2:	50                   	push   %eax
801086b3:	ff 75 dc             	pushl  -0x24(%ebp)
801086b6:	e8 6b ce ff ff       	call   80105526 <memmove>
801086bb:	83 c4 10             	add    $0x10,%esp
        if (mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801086be:	8b 55 e0             	mov    -0x20(%ebp),%edx
801086c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801086c4:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801086ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cd:	83 ec 0c             	sub    $0xc,%esp
801086d0:	52                   	push   %edx
801086d1:	51                   	push   %ecx
801086d2:	68 00 10 00 00       	push   $0x1000
801086d7:	50                   	push   %eax
801086d8:	ff 75 f0             	pushl  -0x10(%ebp)
801086db:	e8 20 f8 ff ff       	call   80107f00 <mappages>
801086e0:	83 c4 20             	add    $0x20,%esp
801086e3:	85 c0                	test   %eax,%eax
801086e5:	0f 88 0c 01 00 00    	js     801087f7 <copyuvm+0x1f2>
    for (i = 0; i < sz; i += PGSIZE) {
801086eb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086f8:	0f 82 35 ff ff ff    	jb     80108633 <copyuvm+0x2e>
            goto bad;
    }

    uint t = TOPBASE;
801086fe:	c7 45 ec 00 f0 ff 7f 	movl   $0x7ffff000,-0x14(%ebp)
    t = PGROUNDDOWN(t);
80108705:	81 65 ec 00 f0 ff ff 	andl   $0xfffff000,-0x14(%ebp)

    for (i = t; i > t - 1 * PGSIZE; i -= PGSIZE) {
8010870c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010870f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108712:	e9 c7 00 00 00       	jmp    801087de <copyuvm+0x1d9>
        if ((pte = walkpgdir(pgdir, (void*)i, 0)) == 0)
80108717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871a:	83 ec 04             	sub    $0x4,%esp
8010871d:	6a 00                	push   $0x0
8010871f:	50                   	push   %eax
80108720:	ff 75 08             	pushl  0x8(%ebp)
80108723:	e8 3e f7 ff ff       	call   80107e66 <walkpgdir>
80108728:	83 c4 10             	add    $0x10,%esp
8010872b:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010872e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108732:	75 0d                	jne    80108741 <copyuvm+0x13c>
            panic("copyuvm: pte should exist");
80108734:	83 ec 0c             	sub    $0xc,%esp
80108737:	68 ca b5 10 80       	push   $0x8010b5ca
8010873c:	e8 84 7e ff ff       	call   801005c5 <panic>
        if (!(*pte & PTE_P))
80108741:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108744:	8b 00                	mov    (%eax),%eax
80108746:	83 e0 01             	and    $0x1,%eax
80108749:	85 c0                	test   %eax,%eax
8010874b:	75 0d                	jne    8010875a <copyuvm+0x155>
            panic("copyuvm: page not present");
8010874d:	83 ec 0c             	sub    $0xc,%esp
80108750:	68 e4 b5 10 80       	push   $0x8010b5e4
80108755:	e8 6b 7e ff ff       	call   801005c5 <panic>
        pa = PTE_ADDR(*pte);
8010875a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010875d:	8b 00                	mov    (%eax),%eax
8010875f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108764:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        flags = PTE_FLAGS(*pte);
80108767:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010876a:	8b 00                	mov    (%eax),%eax
8010876c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108771:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if ((mem = kalloc()) == 0)
80108774:	e8 ff a5 ff ff       	call   80102d78 <kalloc>
80108779:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010877c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80108780:	74 78                	je     801087fa <copyuvm+0x1f5>
            goto bad;
        memmove(mem, (char*)P2V(pa), PGSIZE);
80108782:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108785:	05 00 00 00 80       	add    $0x80000000,%eax
8010878a:	83 ec 04             	sub    $0x4,%esp
8010878d:	68 00 10 00 00       	push   $0x1000
80108792:	50                   	push   %eax
80108793:	ff 75 dc             	pushl  -0x24(%ebp)
80108796:	e8 8b cd ff ff       	call   80105526 <memmove>
8010879b:	83 c4 10             	add    $0x10,%esp
        if (mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010879e:	8b 55 e0             	mov    -0x20(%ebp),%edx
801087a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801087a4:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801087aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ad:	83 ec 0c             	sub    $0xc,%esp
801087b0:	52                   	push   %edx
801087b1:	51                   	push   %ecx
801087b2:	68 00 10 00 00       	push   $0x1000
801087b7:	50                   	push   %eax
801087b8:	ff 75 f0             	pushl  -0x10(%ebp)
801087bb:	e8 40 f7 ff ff       	call   80107f00 <mappages>
801087c0:	83 c4 20             	add    $0x20,%esp
801087c3:	85 c0                	test   %eax,%eax
801087c5:	79 10                	jns    801087d7 <copyuvm+0x1d2>
            kfree(mem);
801087c7:	83 ec 0c             	sub    $0xc,%esp
801087ca:	ff 75 dc             	pushl  -0x24(%ebp)
801087cd:	e8 08 a5 ff ff       	call   80102cda <kfree>
801087d2:	83 c4 10             	add    $0x10,%esp
            goto bad;
801087d5:	eb 24                	jmp    801087fb <copyuvm+0x1f6>
    for (i = t; i > t - 1 * PGSIZE; i -= PGSIZE) {
801087d7:	81 6d f4 00 10 00 00 	subl   $0x1000,-0xc(%ebp)
801087de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087e1:	2d 00 10 00 00       	sub    $0x1000,%eax
801087e6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801087e9:	0f 87 28 ff ff ff    	ja     80108717 <copyuvm+0x112>
        }
    }

    return d;
801087ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f2:	eb 1a                	jmp    8010880e <copyuvm+0x209>
            goto bad;
801087f4:	90                   	nop
801087f5:	eb 04                	jmp    801087fb <copyuvm+0x1f6>
            goto bad;
801087f7:	90                   	nop
801087f8:	eb 01                	jmp    801087fb <copyuvm+0x1f6>
            goto bad;
801087fa:	90                   	nop

bad:
    freevm(d);
801087fb:	83 ec 0c             	sub    $0xc,%esp
801087fe:	ff 75 f0             	pushl  -0x10(%ebp)
80108801:	e8 1d fd ff ff       	call   80108523 <freevm>
80108806:	83 c4 10             	add    $0x10,%esp
    return 0;
80108809:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010880e:	c9                   	leave  
8010880f:	c3                   	ret    

80108810 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t* pgdir, char* uva)
{
80108810:	f3 0f 1e fb          	endbr32 
80108814:	55                   	push   %ebp
80108815:	89 e5                	mov    %esp,%ebp
80108817:	83 ec 18             	sub    $0x18,%esp
    pte_t* pte;

    pte = walkpgdir(pgdir, uva, 0);
8010881a:	83 ec 04             	sub    $0x4,%esp
8010881d:	6a 00                	push   $0x0
8010881f:	ff 75 0c             	pushl  0xc(%ebp)
80108822:	ff 75 08             	pushl  0x8(%ebp)
80108825:	e8 3c f6 ff ff       	call   80107e66 <walkpgdir>
8010882a:	83 c4 10             	add    $0x10,%esp
8010882d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if ((*pte & PTE_P) == 0)
80108830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108833:	8b 00                	mov    (%eax),%eax
80108835:	83 e0 01             	and    $0x1,%eax
80108838:	85 c0                	test   %eax,%eax
8010883a:	75 07                	jne    80108843 <uva2ka+0x33>
        return 0;
8010883c:	b8 00 00 00 00       	mov    $0x0,%eax
80108841:	eb 22                	jmp    80108865 <uva2ka+0x55>
    if ((*pte & PTE_U) == 0)
80108843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108846:	8b 00                	mov    (%eax),%eax
80108848:	83 e0 04             	and    $0x4,%eax
8010884b:	85 c0                	test   %eax,%eax
8010884d:	75 07                	jne    80108856 <uva2ka+0x46>
        return 0;
8010884f:	b8 00 00 00 00       	mov    $0x0,%eax
80108854:	eb 0f                	jmp    80108865 <uva2ka+0x55>
    return (char*)P2V(PTE_ADDR(*pte));
80108856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108859:	8b 00                	mov    (%eax),%eax
8010885b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108860:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108865:	c9                   	leave  
80108866:	c3                   	ret    

80108867 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t* pgdir, uint va, void* p, uint len)
{
80108867:	f3 0f 1e fb          	endbr32 
8010886b:	55                   	push   %ebp
8010886c:	89 e5                	mov    %esp,%ebp
8010886e:	83 ec 18             	sub    $0x18,%esp
    char* buf, * pa0;
    uint n, va0;

    buf = (char*)p;
80108871:	8b 45 10             	mov    0x10(%ebp),%eax
80108874:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (len > 0) {
80108877:	eb 7f                	jmp    801088f8 <copyout+0x91>
        va0 = (uint)PGROUNDDOWN(va);
80108879:	8b 45 0c             	mov    0xc(%ebp),%eax
8010887c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108881:	89 45 ec             	mov    %eax,-0x14(%ebp)
        pa0 = uva2ka(pgdir, (char*)va0);
80108884:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108887:	83 ec 08             	sub    $0x8,%esp
8010888a:	50                   	push   %eax
8010888b:	ff 75 08             	pushl  0x8(%ebp)
8010888e:	e8 7d ff ff ff       	call   80108810 <uva2ka>
80108893:	83 c4 10             	add    $0x10,%esp
80108896:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (pa0 == 0)
80108899:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010889d:	75 07                	jne    801088a6 <copyout+0x3f>
            return -1;
8010889f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088a4:	eb 61                	jmp    80108907 <copyout+0xa0>
        n = PGSIZE - (va - va0);
801088a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088a9:	2b 45 0c             	sub    0xc(%ebp),%eax
801088ac:	05 00 10 00 00       	add    $0x1000,%eax
801088b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (n > len)
801088b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088b7:	3b 45 14             	cmp    0x14(%ebp),%eax
801088ba:	76 06                	jbe    801088c2 <copyout+0x5b>
            n = len;
801088bc:	8b 45 14             	mov    0x14(%ebp),%eax
801088bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
        memmove(pa0 + (va - va0), buf, n);
801088c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801088c5:	2b 45 ec             	sub    -0x14(%ebp),%eax
801088c8:	89 c2                	mov    %eax,%edx
801088ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088cd:	01 d0                	add    %edx,%eax
801088cf:	83 ec 04             	sub    $0x4,%esp
801088d2:	ff 75 f0             	pushl  -0x10(%ebp)
801088d5:	ff 75 f4             	pushl  -0xc(%ebp)
801088d8:	50                   	push   %eax
801088d9:	e8 48 cc ff ff       	call   80105526 <memmove>
801088de:	83 c4 10             	add    $0x10,%esp
        len -= n;
801088e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e4:	29 45 14             	sub    %eax,0x14(%ebp)
        buf += n;
801088e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ea:	01 45 f4             	add    %eax,-0xc(%ebp)
        va = va0 + PGSIZE;
801088ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088f0:	05 00 10 00 00       	add    $0x1000,%eax
801088f5:	89 45 0c             	mov    %eax,0xc(%ebp)
    while (len > 0) {
801088f8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801088fc:	0f 85 77 ff ff ff    	jne    80108879 <copyout+0x12>
    }
    return 0;
80108902:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108907:	c9                   	leave  
80108908:	c3                   	ret    

80108909 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108909:	f3 0f 1e fb          	endbr32 
8010890d:	55                   	push   %ebp
8010890e:	89 e5                	mov    %esp,%ebp
80108910:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108913:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
8010891a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010891d:	8b 40 08             	mov    0x8(%eax),%eax
80108920:	05 00 00 00 80       	add    $0x80000000,%eax
80108925:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108928:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010892f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108932:	8b 40 24             	mov    0x24(%eax),%eax
80108935:	a3 5c 84 11 80       	mov    %eax,0x8011845c
  ncpu = 0;
8010893a:	c7 05 c0 b4 11 80 00 	movl   $0x0,0x8011b4c0
80108941:	00 00 00 

  while(i<madt->len){
80108944:	90                   	nop
80108945:	e9 be 00 00 00       	jmp    80108a08 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
8010894a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010894d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108950:	01 d0                	add    %edx,%eax
80108952:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80108955:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108958:	0f b6 00             	movzbl (%eax),%eax
8010895b:	0f b6 c0             	movzbl %al,%eax
8010895e:	83 f8 05             	cmp    $0x5,%eax
80108961:	0f 87 a1 00 00 00    	ja     80108a08 <mpinit_uefi+0xff>
80108967:	8b 04 85 00 b6 10 80 	mov    -0x7fef4a00(,%eax,4),%eax
8010896e:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80108971:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108974:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108977:	a1 c0 b4 11 80       	mov    0x8011b4c0,%eax
8010897c:	83 f8 03             	cmp    $0x3,%eax
8010897f:	7f 28                	jg     801089a9 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80108981:	8b 15 c0 b4 11 80    	mov    0x8011b4c0,%edx
80108987:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010898a:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010898e:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80108994:	81 c2 00 b2 11 80    	add    $0x8011b200,%edx
8010899a:	88 02                	mov    %al,(%edx)
          ncpu++;
8010899c:	a1 c0 b4 11 80       	mov    0x8011b4c0,%eax
801089a1:	83 c0 01             	add    $0x1,%eax
801089a4:	a3 c0 b4 11 80       	mov    %eax,0x8011b4c0
        }
        i += lapic_entry->record_len;
801089a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089ac:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801089b0:	0f b6 c0             	movzbl %al,%eax
801089b3:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801089b6:	eb 50                	jmp    80108a08 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
801089b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
801089be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801089c1:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801089c5:	a2 e0 b1 11 80       	mov    %al,0x8011b1e0
        i += ioapic->record_len;
801089ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801089cd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801089d1:	0f b6 c0             	movzbl %al,%eax
801089d4:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801089d7:	eb 2f                	jmp    80108a08 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
801089d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
801089df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089e2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801089e6:	0f b6 c0             	movzbl %al,%eax
801089e9:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
801089ec:	eb 1a                	jmp    80108a08 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
801089ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
801089f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089f7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801089fb:	0f b6 c0             	movzbl %al,%eax
801089fe:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108a01:	eb 05                	jmp    80108a08 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
80108a03:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108a07:	90                   	nop
  while(i<madt->len){
80108a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0b:	8b 40 04             	mov    0x4(%eax),%eax
80108a0e:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80108a11:	0f 82 33 ff ff ff    	jb     8010894a <mpinit_uefi+0x41>
    }
  }

}
80108a17:	90                   	nop
80108a18:	90                   	nop
80108a19:	c9                   	leave  
80108a1a:	c3                   	ret    

80108a1b <inb>:
{
80108a1b:	55                   	push   %ebp
80108a1c:	89 e5                	mov    %esp,%ebp
80108a1e:	83 ec 14             	sub    $0x14,%esp
80108a21:	8b 45 08             	mov    0x8(%ebp),%eax
80108a24:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108a28:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80108a2c:	89 c2                	mov    %eax,%edx
80108a2e:	ec                   	in     (%dx),%al
80108a2f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108a32:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108a36:	c9                   	leave  
80108a37:	c3                   	ret    

80108a38 <outb>:
{
80108a38:	55                   	push   %ebp
80108a39:	89 e5                	mov    %esp,%ebp
80108a3b:	83 ec 08             	sub    $0x8,%esp
80108a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a41:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a44:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108a48:	89 d0                	mov    %edx,%eax
80108a4a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80108a4d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80108a51:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80108a55:	ee                   	out    %al,(%dx)
}
80108a56:	90                   	nop
80108a57:	c9                   	leave  
80108a58:	c3                   	ret    

80108a59 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80108a59:	f3 0f 1e fb          	endbr32 
80108a5d:	55                   	push   %ebp
80108a5e:	89 e5                	mov    %esp,%ebp
80108a60:	83 ec 28             	sub    $0x28,%esp
80108a63:	8b 45 08             	mov    0x8(%ebp),%eax
80108a66:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80108a69:	6a 00                	push   $0x0
80108a6b:	68 fa 03 00 00       	push   $0x3fa
80108a70:	e8 c3 ff ff ff       	call   80108a38 <outb>
80108a75:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80108a78:	68 80 00 00 00       	push   $0x80
80108a7d:	68 fb 03 00 00       	push   $0x3fb
80108a82:	e8 b1 ff ff ff       	call   80108a38 <outb>
80108a87:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108a8a:	6a 0c                	push   $0xc
80108a8c:	68 f8 03 00 00       	push   $0x3f8
80108a91:	e8 a2 ff ff ff       	call   80108a38 <outb>
80108a96:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108a99:	6a 00                	push   $0x0
80108a9b:	68 f9 03 00 00       	push   $0x3f9
80108aa0:	e8 93 ff ff ff       	call   80108a38 <outb>
80108aa5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108aa8:	6a 03                	push   $0x3
80108aaa:	68 fb 03 00 00       	push   $0x3fb
80108aaf:	e8 84 ff ff ff       	call   80108a38 <outb>
80108ab4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108ab7:	6a 00                	push   $0x0
80108ab9:	68 fc 03 00 00       	push   $0x3fc
80108abe:	e8 75 ff ff ff       	call   80108a38 <outb>
80108ac3:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108ac6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108acd:	eb 11                	jmp    80108ae0 <uart_debug+0x87>
80108acf:	83 ec 0c             	sub    $0xc,%esp
80108ad2:	6a 0a                	push   $0xa
80108ad4:	e8 51 a6 ff ff       	call   8010312a <microdelay>
80108ad9:	83 c4 10             	add    $0x10,%esp
80108adc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ae0:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108ae4:	7f 1a                	jg     80108b00 <uart_debug+0xa7>
80108ae6:	83 ec 0c             	sub    $0xc,%esp
80108ae9:	68 fd 03 00 00       	push   $0x3fd
80108aee:	e8 28 ff ff ff       	call   80108a1b <inb>
80108af3:	83 c4 10             	add    $0x10,%esp
80108af6:	0f b6 c0             	movzbl %al,%eax
80108af9:	83 e0 20             	and    $0x20,%eax
80108afc:	85 c0                	test   %eax,%eax
80108afe:	74 cf                	je     80108acf <uart_debug+0x76>
  outb(COM1+0, p);
80108b00:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108b04:	0f b6 c0             	movzbl %al,%eax
80108b07:	83 ec 08             	sub    $0x8,%esp
80108b0a:	50                   	push   %eax
80108b0b:	68 f8 03 00 00       	push   $0x3f8
80108b10:	e8 23 ff ff ff       	call   80108a38 <outb>
80108b15:	83 c4 10             	add    $0x10,%esp
}
80108b18:	90                   	nop
80108b19:	c9                   	leave  
80108b1a:	c3                   	ret    

80108b1b <uart_debugs>:

void uart_debugs(char *p){
80108b1b:	f3 0f 1e fb          	endbr32 
80108b1f:	55                   	push   %ebp
80108b20:	89 e5                	mov    %esp,%ebp
80108b22:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108b25:	eb 1b                	jmp    80108b42 <uart_debugs+0x27>
    uart_debug(*p++);
80108b27:	8b 45 08             	mov    0x8(%ebp),%eax
80108b2a:	8d 50 01             	lea    0x1(%eax),%edx
80108b2d:	89 55 08             	mov    %edx,0x8(%ebp)
80108b30:	0f b6 00             	movzbl (%eax),%eax
80108b33:	0f be c0             	movsbl %al,%eax
80108b36:	83 ec 0c             	sub    $0xc,%esp
80108b39:	50                   	push   %eax
80108b3a:	e8 1a ff ff ff       	call   80108a59 <uart_debug>
80108b3f:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108b42:	8b 45 08             	mov    0x8(%ebp),%eax
80108b45:	0f b6 00             	movzbl (%eax),%eax
80108b48:	84 c0                	test   %al,%al
80108b4a:	75 db                	jne    80108b27 <uart_debugs+0xc>
  }
}
80108b4c:	90                   	nop
80108b4d:	90                   	nop
80108b4e:	c9                   	leave  
80108b4f:	c3                   	ret    

80108b50 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108b50:	f3 0f 1e fb          	endbr32 
80108b54:	55                   	push   %ebp
80108b55:	89 e5                	mov    %esp,%ebp
80108b57:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108b5a:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108b61:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108b64:	8b 50 14             	mov    0x14(%eax),%edx
80108b67:	8b 40 10             	mov    0x10(%eax),%eax
80108b6a:	a3 c4 b4 11 80       	mov    %eax,0x8011b4c4
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108b6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108b72:	8b 50 1c             	mov    0x1c(%eax),%edx
80108b75:	8b 40 18             	mov    0x18(%eax),%eax
80108b78:	a3 cc b4 11 80       	mov    %eax,0x8011b4cc
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108b7d:	a1 cc b4 11 80       	mov    0x8011b4cc,%eax
80108b82:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108b87:	29 c2                	sub    %eax,%edx
80108b89:	89 d0                	mov    %edx,%eax
80108b8b:	a3 c8 b4 11 80       	mov    %eax,0x8011b4c8
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108b90:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108b93:	8b 50 24             	mov    0x24(%eax),%edx
80108b96:	8b 40 20             	mov    0x20(%eax),%eax
80108b99:	a3 d0 b4 11 80       	mov    %eax,0x8011b4d0
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108b9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108ba1:	8b 50 2c             	mov    0x2c(%eax),%edx
80108ba4:	8b 40 28             	mov    0x28(%eax),%eax
80108ba7:	a3 d4 b4 11 80       	mov    %eax,0x8011b4d4
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108bac:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108baf:	8b 50 34             	mov    0x34(%eax),%edx
80108bb2:	8b 40 30             	mov    0x30(%eax),%eax
80108bb5:	a3 d8 b4 11 80       	mov    %eax,0x8011b4d8
}
80108bba:	90                   	nop
80108bbb:	c9                   	leave  
80108bbc:	c3                   	ret    

80108bbd <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108bbd:	f3 0f 1e fb          	endbr32 
80108bc1:	55                   	push   %ebp
80108bc2:	89 e5                	mov    %esp,%ebp
80108bc4:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108bc7:	8b 15 d8 b4 11 80    	mov    0x8011b4d8,%edx
80108bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bd0:	0f af d0             	imul   %eax,%edx
80108bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80108bd6:	01 d0                	add    %edx,%eax
80108bd8:	c1 e0 02             	shl    $0x2,%eax
80108bdb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108bde:	8b 15 c8 b4 11 80    	mov    0x8011b4c8,%edx
80108be4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108be7:	01 d0                	add    %edx,%eax
80108be9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108bec:	8b 45 10             	mov    0x10(%ebp),%eax
80108bef:	0f b6 10             	movzbl (%eax),%edx
80108bf2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108bf5:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108bf7:	8b 45 10             	mov    0x10(%ebp),%eax
80108bfa:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108bfe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108c01:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108c04:	8b 45 10             	mov    0x10(%ebp),%eax
80108c07:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108c0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108c0e:	88 50 02             	mov    %dl,0x2(%eax)
}
80108c11:	90                   	nop
80108c12:	c9                   	leave  
80108c13:	c3                   	ret    

80108c14 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108c14:	f3 0f 1e fb          	endbr32 
80108c18:	55                   	push   %ebp
80108c19:	89 e5                	mov    %esp,%ebp
80108c1b:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108c1e:	8b 15 d8 b4 11 80    	mov    0x8011b4d8,%edx
80108c24:	8b 45 08             	mov    0x8(%ebp),%eax
80108c27:	0f af c2             	imul   %edx,%eax
80108c2a:	c1 e0 02             	shl    $0x2,%eax
80108c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108c30:	8b 15 cc b4 11 80    	mov    0x8011b4cc,%edx
80108c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c39:	29 c2                	sub    %eax,%edx
80108c3b:	89 d0                	mov    %edx,%eax
80108c3d:	8b 0d c8 b4 11 80    	mov    0x8011b4c8,%ecx
80108c43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108c46:	01 ca                	add    %ecx,%edx
80108c48:	89 d1                	mov    %edx,%ecx
80108c4a:	8b 15 c8 b4 11 80    	mov    0x8011b4c8,%edx
80108c50:	83 ec 04             	sub    $0x4,%esp
80108c53:	50                   	push   %eax
80108c54:	51                   	push   %ecx
80108c55:	52                   	push   %edx
80108c56:	e8 cb c8 ff ff       	call   80105526 <memmove>
80108c5b:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c61:	8b 0d c8 b4 11 80    	mov    0x8011b4c8,%ecx
80108c67:	8b 15 cc b4 11 80    	mov    0x8011b4cc,%edx
80108c6d:	01 d1                	add    %edx,%ecx
80108c6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108c72:	29 d1                	sub    %edx,%ecx
80108c74:	89 ca                	mov    %ecx,%edx
80108c76:	83 ec 04             	sub    $0x4,%esp
80108c79:	50                   	push   %eax
80108c7a:	6a 00                	push   $0x0
80108c7c:	52                   	push   %edx
80108c7d:	e8 dd c7 ff ff       	call   8010545f <memset>
80108c82:	83 c4 10             	add    $0x10,%esp
}
80108c85:	90                   	nop
80108c86:	c9                   	leave  
80108c87:	c3                   	ret    

80108c88 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108c88:	f3 0f 1e fb          	endbr32 
80108c8c:	55                   	push   %ebp
80108c8d:	89 e5                	mov    %esp,%ebp
80108c8f:	53                   	push   %ebx
80108c90:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108c93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c9a:	e9 b1 00 00 00       	jmp    80108d50 <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108c9f:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108ca6:	e9 97 00 00 00       	jmp    80108d42 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108cab:	8b 45 10             	mov    0x10(%ebp),%eax
80108cae:	83 e8 20             	sub    $0x20,%eax
80108cb1:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb7:	01 d0                	add    %edx,%eax
80108cb9:	0f b7 84 00 20 b6 10 	movzwl -0x7fef49e0(%eax,%eax,1),%eax
80108cc0:	80 
80108cc1:	0f b7 d0             	movzwl %ax,%edx
80108cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cc7:	bb 01 00 00 00       	mov    $0x1,%ebx
80108ccc:	89 c1                	mov    %eax,%ecx
80108cce:	d3 e3                	shl    %cl,%ebx
80108cd0:	89 d8                	mov    %ebx,%eax
80108cd2:	21 d0                	and    %edx,%eax
80108cd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cda:	ba 01 00 00 00       	mov    $0x1,%edx
80108cdf:	89 c1                	mov    %eax,%ecx
80108ce1:	d3 e2                	shl    %cl,%edx
80108ce3:	89 d0                	mov    %edx,%eax
80108ce5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108ce8:	75 2b                	jne    80108d15 <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108cea:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf0:	01 c2                	add    %eax,%edx
80108cf2:	b8 0e 00 00 00       	mov    $0xe,%eax
80108cf7:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108cfa:	89 c1                	mov    %eax,%ecx
80108cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80108cff:	01 c8                	add    %ecx,%eax
80108d01:	83 ec 04             	sub    $0x4,%esp
80108d04:	68 e0 f4 10 80       	push   $0x8010f4e0
80108d09:	52                   	push   %edx
80108d0a:	50                   	push   %eax
80108d0b:	e8 ad fe ff ff       	call   80108bbd <graphic_draw_pixel>
80108d10:	83 c4 10             	add    $0x10,%esp
80108d13:	eb 29                	jmp    80108d3e <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108d15:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d1b:	01 c2                	add    %eax,%edx
80108d1d:	b8 0e 00 00 00       	mov    $0xe,%eax
80108d22:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108d25:	89 c1                	mov    %eax,%ecx
80108d27:	8b 45 08             	mov    0x8(%ebp),%eax
80108d2a:	01 c8                	add    %ecx,%eax
80108d2c:	83 ec 04             	sub    $0x4,%esp
80108d2f:	68 a8 00 11 80       	push   $0x801100a8
80108d34:	52                   	push   %edx
80108d35:	50                   	push   %eax
80108d36:	e8 82 fe ff ff       	call   80108bbd <graphic_draw_pixel>
80108d3b:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108d3e:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108d42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d46:	0f 89 5f ff ff ff    	jns    80108cab <font_render+0x23>
  for(int i=0;i<30;i++){
80108d4c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108d50:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108d54:	0f 8e 45 ff ff ff    	jle    80108c9f <font_render+0x17>
      }
    }
  }
}
80108d5a:	90                   	nop
80108d5b:	90                   	nop
80108d5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d5f:	c9                   	leave  
80108d60:	c3                   	ret    

80108d61 <font_render_string>:

void font_render_string(char *string,int row){
80108d61:	f3 0f 1e fb          	endbr32 
80108d65:	55                   	push   %ebp
80108d66:	89 e5                	mov    %esp,%ebp
80108d68:	53                   	push   %ebx
80108d69:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108d6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108d73:	eb 33                	jmp    80108da8 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108d75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d78:	8b 45 08             	mov    0x8(%ebp),%eax
80108d7b:	01 d0                	add    %edx,%eax
80108d7d:	0f b6 00             	movzbl (%eax),%eax
80108d80:	0f be d8             	movsbl %al,%ebx
80108d83:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d86:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108d89:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108d8c:	89 d0                	mov    %edx,%eax
80108d8e:	c1 e0 04             	shl    $0x4,%eax
80108d91:	29 d0                	sub    %edx,%eax
80108d93:	83 c0 02             	add    $0x2,%eax
80108d96:	83 ec 04             	sub    $0x4,%esp
80108d99:	53                   	push   %ebx
80108d9a:	51                   	push   %ecx
80108d9b:	50                   	push   %eax
80108d9c:	e8 e7 fe ff ff       	call   80108c88 <font_render>
80108da1:	83 c4 10             	add    $0x10,%esp
    i++;
80108da4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108da8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108dab:	8b 45 08             	mov    0x8(%ebp),%eax
80108dae:	01 d0                	add    %edx,%eax
80108db0:	0f b6 00             	movzbl (%eax),%eax
80108db3:	84 c0                	test   %al,%al
80108db5:	74 06                	je     80108dbd <font_render_string+0x5c>
80108db7:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108dbb:	7e b8                	jle    80108d75 <font_render_string+0x14>
  }
}
80108dbd:	90                   	nop
80108dbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108dc1:	c9                   	leave  
80108dc2:	c3                   	ret    

80108dc3 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108dc3:	f3 0f 1e fb          	endbr32 
80108dc7:	55                   	push   %ebp
80108dc8:	89 e5                	mov    %esp,%ebp
80108dca:	53                   	push   %ebx
80108dcb:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108dce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108dd5:	eb 6b                	jmp    80108e42 <pci_init+0x7f>
    for(int j=0;j<32;j++){
80108dd7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108dde:	eb 58                	jmp    80108e38 <pci_init+0x75>
      for(int k=0;k<8;k++){
80108de0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108de7:	eb 45                	jmp    80108e2e <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108de9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108dec:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df2:	83 ec 0c             	sub    $0xc,%esp
80108df5:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108df8:	53                   	push   %ebx
80108df9:	6a 00                	push   $0x0
80108dfb:	51                   	push   %ecx
80108dfc:	52                   	push   %edx
80108dfd:	50                   	push   %eax
80108dfe:	e8 c0 00 00 00       	call   80108ec3 <pci_access_config>
80108e03:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108e06:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e09:	0f b7 c0             	movzwl %ax,%eax
80108e0c:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108e11:	74 17                	je     80108e2a <pci_init+0x67>
        pci_init_device(i,j,k);
80108e13:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108e16:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1c:	83 ec 04             	sub    $0x4,%esp
80108e1f:	51                   	push   %ecx
80108e20:	52                   	push   %edx
80108e21:	50                   	push   %eax
80108e22:	e8 4f 01 00 00       	call   80108f76 <pci_init_device>
80108e27:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108e2a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108e2e:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108e32:	7e b5                	jle    80108de9 <pci_init+0x26>
    for(int j=0;j<32;j++){
80108e34:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e38:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108e3c:	7e a2                	jle    80108de0 <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108e3e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e42:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e49:	7e 8c                	jle    80108dd7 <pci_init+0x14>
      }
      }
    }
  }
}
80108e4b:	90                   	nop
80108e4c:	90                   	nop
80108e4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e50:	c9                   	leave  
80108e51:	c3                   	ret    

80108e52 <pci_write_config>:

void pci_write_config(uint config){
80108e52:	f3 0f 1e fb          	endbr32 
80108e56:	55                   	push   %ebp
80108e57:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108e59:	8b 45 08             	mov    0x8(%ebp),%eax
80108e5c:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108e61:	89 c0                	mov    %eax,%eax
80108e63:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108e64:	90                   	nop
80108e65:	5d                   	pop    %ebp
80108e66:	c3                   	ret    

80108e67 <pci_write_data>:

void pci_write_data(uint config){
80108e67:	f3 0f 1e fb          	endbr32 
80108e6b:	55                   	push   %ebp
80108e6c:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80108e71:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108e76:	89 c0                	mov    %eax,%eax
80108e78:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108e79:	90                   	nop
80108e7a:	5d                   	pop    %ebp
80108e7b:	c3                   	ret    

80108e7c <pci_read_config>:
uint pci_read_config(){
80108e7c:	f3 0f 1e fb          	endbr32 
80108e80:	55                   	push   %ebp
80108e81:	89 e5                	mov    %esp,%ebp
80108e83:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108e86:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108e8b:	ed                   	in     (%dx),%eax
80108e8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108e8f:	83 ec 0c             	sub    $0xc,%esp
80108e92:	68 c8 00 00 00       	push   $0xc8
80108e97:	e8 8e a2 ff ff       	call   8010312a <microdelay>
80108e9c:	83 c4 10             	add    $0x10,%esp
  return data;
80108e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108ea2:	c9                   	leave  
80108ea3:	c3                   	ret    

80108ea4 <pci_test>:


void pci_test(){
80108ea4:	f3 0f 1e fb          	endbr32 
80108ea8:	55                   	push   %ebp
80108ea9:	89 e5                	mov    %esp,%ebp
80108eab:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108eae:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108eb5:	ff 75 fc             	pushl  -0x4(%ebp)
80108eb8:	e8 95 ff ff ff       	call   80108e52 <pci_write_config>
80108ebd:	83 c4 04             	add    $0x4,%esp
}
80108ec0:	90                   	nop
80108ec1:	c9                   	leave  
80108ec2:	c3                   	ret    

80108ec3 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108ec3:	f3 0f 1e fb          	endbr32 
80108ec7:	55                   	push   %ebp
80108ec8:	89 e5                	mov    %esp,%ebp
80108eca:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80108ed0:	c1 e0 10             	shl    $0x10,%eax
80108ed3:	25 00 00 ff 00       	and    $0xff0000,%eax
80108ed8:	89 c2                	mov    %eax,%edx
80108eda:	8b 45 0c             	mov    0xc(%ebp),%eax
80108edd:	c1 e0 0b             	shl    $0xb,%eax
80108ee0:	0f b7 c0             	movzwl %ax,%eax
80108ee3:	09 c2                	or     %eax,%edx
80108ee5:	8b 45 10             	mov    0x10(%ebp),%eax
80108ee8:	c1 e0 08             	shl    $0x8,%eax
80108eeb:	25 00 07 00 00       	and    $0x700,%eax
80108ef0:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108ef2:	8b 45 14             	mov    0x14(%ebp),%eax
80108ef5:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108efa:	09 d0                	or     %edx,%eax
80108efc:	0d 00 00 00 80       	or     $0x80000000,%eax
80108f01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108f04:	ff 75 f4             	pushl  -0xc(%ebp)
80108f07:	e8 46 ff ff ff       	call   80108e52 <pci_write_config>
80108f0c:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108f0f:	e8 68 ff ff ff       	call   80108e7c <pci_read_config>
80108f14:	8b 55 18             	mov    0x18(%ebp),%edx
80108f17:	89 02                	mov    %eax,(%edx)
}
80108f19:	90                   	nop
80108f1a:	c9                   	leave  
80108f1b:	c3                   	ret    

80108f1c <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108f1c:	f3 0f 1e fb          	endbr32 
80108f20:	55                   	push   %ebp
80108f21:	89 e5                	mov    %esp,%ebp
80108f23:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108f26:	8b 45 08             	mov    0x8(%ebp),%eax
80108f29:	c1 e0 10             	shl    $0x10,%eax
80108f2c:	25 00 00 ff 00       	and    $0xff0000,%eax
80108f31:	89 c2                	mov    %eax,%edx
80108f33:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f36:	c1 e0 0b             	shl    $0xb,%eax
80108f39:	0f b7 c0             	movzwl %ax,%eax
80108f3c:	09 c2                	or     %eax,%edx
80108f3e:	8b 45 10             	mov    0x10(%ebp),%eax
80108f41:	c1 e0 08             	shl    $0x8,%eax
80108f44:	25 00 07 00 00       	and    $0x700,%eax
80108f49:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108f4b:	8b 45 14             	mov    0x14(%ebp),%eax
80108f4e:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108f53:	09 d0                	or     %edx,%eax
80108f55:	0d 00 00 00 80       	or     $0x80000000,%eax
80108f5a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108f5d:	ff 75 fc             	pushl  -0x4(%ebp)
80108f60:	e8 ed fe ff ff       	call   80108e52 <pci_write_config>
80108f65:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108f68:	ff 75 18             	pushl  0x18(%ebp)
80108f6b:	e8 f7 fe ff ff       	call   80108e67 <pci_write_data>
80108f70:	83 c4 04             	add    $0x4,%esp
}
80108f73:	90                   	nop
80108f74:	c9                   	leave  
80108f75:	c3                   	ret    

80108f76 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108f76:	f3 0f 1e fb          	endbr32 
80108f7a:	55                   	push   %ebp
80108f7b:	89 e5                	mov    %esp,%ebp
80108f7d:	53                   	push   %ebx
80108f7e:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108f81:	8b 45 08             	mov    0x8(%ebp),%eax
80108f84:	a2 dc b4 11 80       	mov    %al,0x8011b4dc
  dev.device_num = device_num;
80108f89:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f8c:	a2 dd b4 11 80       	mov    %al,0x8011b4dd
  dev.function_num = function_num;
80108f91:	8b 45 10             	mov    0x10(%ebp),%eax
80108f94:	a2 de b4 11 80       	mov    %al,0x8011b4de
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108f99:	ff 75 10             	pushl  0x10(%ebp)
80108f9c:	ff 75 0c             	pushl  0xc(%ebp)
80108f9f:	ff 75 08             	pushl  0x8(%ebp)
80108fa2:	68 64 cc 10 80       	push   $0x8010cc64
80108fa7:	e8 60 74 ff ff       	call   8010040c <cprintf>
80108fac:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108faf:	83 ec 0c             	sub    $0xc,%esp
80108fb2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108fb5:	50                   	push   %eax
80108fb6:	6a 00                	push   $0x0
80108fb8:	ff 75 10             	pushl  0x10(%ebp)
80108fbb:	ff 75 0c             	pushl  0xc(%ebp)
80108fbe:	ff 75 08             	pushl  0x8(%ebp)
80108fc1:	e8 fd fe ff ff       	call   80108ec3 <pci_access_config>
80108fc6:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108fc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fcc:	c1 e8 10             	shr    $0x10,%eax
80108fcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108fd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fd5:	25 ff ff 00 00       	and    $0xffff,%eax
80108fda:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fe0:	a3 e0 b4 11 80       	mov    %eax,0x8011b4e0
  dev.vendor_id = vendor_id;
80108fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe8:	a3 e4 b4 11 80       	mov    %eax,0x8011b4e4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108fed:	83 ec 04             	sub    $0x4,%esp
80108ff0:	ff 75 f0             	pushl  -0x10(%ebp)
80108ff3:	ff 75 f4             	pushl  -0xc(%ebp)
80108ff6:	68 98 cc 10 80       	push   $0x8010cc98
80108ffb:	e8 0c 74 ff ff       	call   8010040c <cprintf>
80109000:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80109003:	83 ec 0c             	sub    $0xc,%esp
80109006:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109009:	50                   	push   %eax
8010900a:	6a 08                	push   $0x8
8010900c:	ff 75 10             	pushl  0x10(%ebp)
8010900f:	ff 75 0c             	pushl  0xc(%ebp)
80109012:	ff 75 08             	pushl  0x8(%ebp)
80109015:	e8 a9 fe ff ff       	call   80108ec3 <pci_access_config>
8010901a:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010901d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109020:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80109023:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109026:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80109029:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010902c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010902f:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80109032:	0f b6 c0             	movzbl %al,%eax
80109035:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80109038:	c1 eb 18             	shr    $0x18,%ebx
8010903b:	83 ec 0c             	sub    $0xc,%esp
8010903e:	51                   	push   %ecx
8010903f:	52                   	push   %edx
80109040:	50                   	push   %eax
80109041:	53                   	push   %ebx
80109042:	68 bc cc 10 80       	push   $0x8010ccbc
80109047:	e8 c0 73 ff ff       	call   8010040c <cprintf>
8010904c:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010904f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109052:	c1 e8 18             	shr    $0x18,%eax
80109055:	a2 e8 b4 11 80       	mov    %al,0x8011b4e8
  dev.sub_class = (data>>16)&0xFF;
8010905a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010905d:	c1 e8 10             	shr    $0x10,%eax
80109060:	a2 e9 b4 11 80       	mov    %al,0x8011b4e9
  dev.interface = (data>>8)&0xFF;
80109065:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109068:	c1 e8 08             	shr    $0x8,%eax
8010906b:	a2 ea b4 11 80       	mov    %al,0x8011b4ea
  dev.revision_id = data&0xFF;
80109070:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109073:	a2 eb b4 11 80       	mov    %al,0x8011b4eb
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80109078:	83 ec 0c             	sub    $0xc,%esp
8010907b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010907e:	50                   	push   %eax
8010907f:	6a 10                	push   $0x10
80109081:	ff 75 10             	pushl  0x10(%ebp)
80109084:	ff 75 0c             	pushl  0xc(%ebp)
80109087:	ff 75 08             	pushl  0x8(%ebp)
8010908a:	e8 34 fe ff ff       	call   80108ec3 <pci_access_config>
8010908f:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80109092:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109095:	a3 ec b4 11 80       	mov    %eax,0x8011b4ec
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
8010909a:	83 ec 0c             	sub    $0xc,%esp
8010909d:	8d 45 ec             	lea    -0x14(%ebp),%eax
801090a0:	50                   	push   %eax
801090a1:	6a 14                	push   $0x14
801090a3:	ff 75 10             	pushl  0x10(%ebp)
801090a6:	ff 75 0c             	pushl  0xc(%ebp)
801090a9:	ff 75 08             	pushl  0x8(%ebp)
801090ac:	e8 12 fe ff ff       	call   80108ec3 <pci_access_config>
801090b1:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801090b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090b7:	a3 f0 b4 11 80       	mov    %eax,0x8011b4f0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801090bc:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801090c3:	75 5a                	jne    8010911f <pci_init_device+0x1a9>
801090c5:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
801090cc:	75 51                	jne    8010911f <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
801090ce:	83 ec 0c             	sub    $0xc,%esp
801090d1:	68 01 cd 10 80       	push   $0x8010cd01
801090d6:	e8 31 73 ff ff       	call   8010040c <cprintf>
801090db:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
801090de:	83 ec 0c             	sub    $0xc,%esp
801090e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801090e4:	50                   	push   %eax
801090e5:	68 f0 00 00 00       	push   $0xf0
801090ea:	ff 75 10             	pushl  0x10(%ebp)
801090ed:	ff 75 0c             	pushl  0xc(%ebp)
801090f0:	ff 75 08             	pushl  0x8(%ebp)
801090f3:	e8 cb fd ff ff       	call   80108ec3 <pci_access_config>
801090f8:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
801090fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090fe:	83 ec 08             	sub    $0x8,%esp
80109101:	50                   	push   %eax
80109102:	68 1b cd 10 80       	push   $0x8010cd1b
80109107:	e8 00 73 ff ff       	call   8010040c <cprintf>
8010910c:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010910f:	83 ec 0c             	sub    $0xc,%esp
80109112:	68 dc b4 11 80       	push   $0x8011b4dc
80109117:	e8 09 00 00 00       	call   80109125 <i8254_init>
8010911c:	83 c4 10             	add    $0x10,%esp
  }
}
8010911f:	90                   	nop
80109120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109123:	c9                   	leave  
80109124:	c3                   	ret    

80109125 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80109125:	f3 0f 1e fb          	endbr32 
80109129:	55                   	push   %ebp
8010912a:	89 e5                	mov    %esp,%ebp
8010912c:	53                   	push   %ebx
8010912d:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80109130:	8b 45 08             	mov    0x8(%ebp),%eax
80109133:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80109137:	0f b6 c8             	movzbl %al,%ecx
8010913a:	8b 45 08             	mov    0x8(%ebp),%eax
8010913d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109141:	0f b6 d0             	movzbl %al,%edx
80109144:	8b 45 08             	mov    0x8(%ebp),%eax
80109147:	0f b6 00             	movzbl (%eax),%eax
8010914a:	0f b6 c0             	movzbl %al,%eax
8010914d:	83 ec 0c             	sub    $0xc,%esp
80109150:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80109153:	53                   	push   %ebx
80109154:	6a 04                	push   $0x4
80109156:	51                   	push   %ecx
80109157:	52                   	push   %edx
80109158:	50                   	push   %eax
80109159:	e8 65 fd ff ff       	call   80108ec3 <pci_access_config>
8010915e:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80109161:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109164:	83 c8 04             	or     $0x4,%eax
80109167:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
8010916a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
8010916d:	8b 45 08             	mov    0x8(%ebp),%eax
80109170:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80109174:	0f b6 c8             	movzbl %al,%ecx
80109177:	8b 45 08             	mov    0x8(%ebp),%eax
8010917a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010917e:	0f b6 d0             	movzbl %al,%edx
80109181:	8b 45 08             	mov    0x8(%ebp),%eax
80109184:	0f b6 00             	movzbl (%eax),%eax
80109187:	0f b6 c0             	movzbl %al,%eax
8010918a:	83 ec 0c             	sub    $0xc,%esp
8010918d:	53                   	push   %ebx
8010918e:	6a 04                	push   $0x4
80109190:	51                   	push   %ecx
80109191:	52                   	push   %edx
80109192:	50                   	push   %eax
80109193:	e8 84 fd ff ff       	call   80108f1c <pci_write_config_register>
80109198:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
8010919b:	8b 45 08             	mov    0x8(%ebp),%eax
8010919e:	8b 40 10             	mov    0x10(%eax),%eax
801091a1:	05 00 00 00 40       	add    $0x40000000,%eax
801091a6:	a3 f4 b4 11 80       	mov    %eax,0x8011b4f4
  uint *ctrl = (uint *)base_addr;
801091ab:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801091b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801091b3:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801091b8:	05 d8 00 00 00       	add    $0xd8,%eax
801091bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801091c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091c3:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801091c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cc:	8b 00                	mov    (%eax),%eax
801091ce:	0d 00 00 00 04       	or     $0x4000000,%eax
801091d3:	89 c2                	mov    %eax,%edx
801091d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d8:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
801091da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091dd:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
801091e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091e6:	8b 00                	mov    (%eax),%eax
801091e8:	83 c8 40             	or     $0x40,%eax
801091eb:	89 c2                	mov    %eax,%edx
801091ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f0:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
801091f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f5:	8b 10                	mov    (%eax),%edx
801091f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091fa:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
801091fc:	83 ec 0c             	sub    $0xc,%esp
801091ff:	68 30 cd 10 80       	push   $0x8010cd30
80109204:	e8 03 72 ff ff       	call   8010040c <cprintf>
80109209:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
8010920c:	e8 67 9b ff ff       	call   80102d78 <kalloc>
80109211:	a3 f8 b4 11 80       	mov    %eax,0x8011b4f8
  *intr_addr = 0;
80109216:	a1 f8 b4 11 80       	mov    0x8011b4f8,%eax
8010921b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80109221:	a1 f8 b4 11 80       	mov    0x8011b4f8,%eax
80109226:	83 ec 08             	sub    $0x8,%esp
80109229:	50                   	push   %eax
8010922a:	68 52 cd 10 80       	push   $0x8010cd52
8010922f:	e8 d8 71 ff ff       	call   8010040c <cprintf>
80109234:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80109237:	e8 50 00 00 00       	call   8010928c <i8254_init_recv>
  i8254_init_send();
8010923c:	e8 6d 03 00 00       	call   801095ae <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80109241:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109248:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010924b:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109252:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80109255:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010925c:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010925f:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109266:	0f b6 c0             	movzbl %al,%eax
80109269:	83 ec 0c             	sub    $0xc,%esp
8010926c:	53                   	push   %ebx
8010926d:	51                   	push   %ecx
8010926e:	52                   	push   %edx
8010926f:	50                   	push   %eax
80109270:	68 60 cd 10 80       	push   $0x8010cd60
80109275:	e8 92 71 ff ff       	call   8010040c <cprintf>
8010927a:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
8010927d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109280:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80109286:	90                   	nop
80109287:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010928a:	c9                   	leave  
8010928b:	c3                   	ret    

8010928c <i8254_init_recv>:

void i8254_init_recv(){
8010928c:	f3 0f 1e fb          	endbr32 
80109290:	55                   	push   %ebp
80109291:	89 e5                	mov    %esp,%ebp
80109293:	57                   	push   %edi
80109294:	56                   	push   %esi
80109295:	53                   	push   %ebx
80109296:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80109299:	83 ec 0c             	sub    $0xc,%esp
8010929c:	6a 00                	push   $0x0
8010929e:	e8 ec 04 00 00       	call   8010978f <i8254_read_eeprom>
801092a3:	83 c4 10             	add    $0x10,%esp
801092a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801092a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801092ac:	a2 ac 00 11 80       	mov    %al,0x801100ac
  mac_addr[1] = data_l>>8;
801092b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801092b4:	c1 e8 08             	shr    $0x8,%eax
801092b7:	a2 ad 00 11 80       	mov    %al,0x801100ad
  uint data_m = i8254_read_eeprom(0x1);
801092bc:	83 ec 0c             	sub    $0xc,%esp
801092bf:	6a 01                	push   $0x1
801092c1:	e8 c9 04 00 00       	call   8010978f <i8254_read_eeprom>
801092c6:	83 c4 10             	add    $0x10,%esp
801092c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801092cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801092cf:	a2 ae 00 11 80       	mov    %al,0x801100ae
  mac_addr[3] = data_m>>8;
801092d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801092d7:	c1 e8 08             	shr    $0x8,%eax
801092da:	a2 af 00 11 80       	mov    %al,0x801100af
  uint data_h = i8254_read_eeprom(0x2);
801092df:	83 ec 0c             	sub    $0xc,%esp
801092e2:	6a 02                	push   $0x2
801092e4:	e8 a6 04 00 00       	call   8010978f <i8254_read_eeprom>
801092e9:	83 c4 10             	add    $0x10,%esp
801092ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
801092ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092f2:	a2 b0 00 11 80       	mov    %al,0x801100b0
  mac_addr[5] = data_h>>8;
801092f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092fa:	c1 e8 08             	shr    $0x8,%eax
801092fd:	a2 b1 00 11 80       	mov    %al,0x801100b1
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80109302:	0f b6 05 b1 00 11 80 	movzbl 0x801100b1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109309:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
8010930c:	0f b6 05 b0 00 11 80 	movzbl 0x801100b0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109313:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80109316:	0f b6 05 af 00 11 80 	movzbl 0x801100af,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010931d:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80109320:	0f b6 05 ae 00 11 80 	movzbl 0x801100ae,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109327:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010932a:	0f b6 05 ad 00 11 80 	movzbl 0x801100ad,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109331:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80109334:	0f b6 05 ac 00 11 80 	movzbl 0x801100ac,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010933b:	0f b6 c0             	movzbl %al,%eax
8010933e:	83 ec 04             	sub    $0x4,%esp
80109341:	57                   	push   %edi
80109342:	56                   	push   %esi
80109343:	53                   	push   %ebx
80109344:	51                   	push   %ecx
80109345:	52                   	push   %edx
80109346:	50                   	push   %eax
80109347:	68 78 cd 10 80       	push   $0x8010cd78
8010934c:	e8 bb 70 ff ff       	call   8010040c <cprintf>
80109351:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80109354:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
80109359:	05 00 54 00 00       	add    $0x5400,%eax
8010935e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80109361:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
80109366:	05 04 54 00 00       	add    $0x5404,%eax
8010936b:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
8010936e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109371:	c1 e0 10             	shl    $0x10,%eax
80109374:	0b 45 d8             	or     -0x28(%ebp),%eax
80109377:	89 c2                	mov    %eax,%edx
80109379:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010937c:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
8010937e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109381:	0d 00 00 00 80       	or     $0x80000000,%eax
80109386:	89 c2                	mov    %eax,%edx
80109388:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010938b:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
8010938d:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
80109392:	05 00 52 00 00       	add    $0x5200,%eax
80109397:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
8010939a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801093a1:	eb 19                	jmp    801093bc <i8254_init_recv+0x130>
    mta[i] = 0;
801093a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801093a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093ad:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801093b0:	01 d0                	add    %edx,%eax
801093b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801093b8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801093bc:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801093c0:	7e e1                	jle    801093a3 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801093c2:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801093c7:	05 d0 00 00 00       	add    $0xd0,%eax
801093cc:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801093cf:	8b 45 c0             	mov    -0x40(%ebp),%eax
801093d2:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
801093d8:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801093dd:	05 c8 00 00 00       	add    $0xc8,%eax
801093e2:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801093e5:	8b 45 bc             	mov    -0x44(%ebp),%eax
801093e8:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
801093ee:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801093f3:	05 28 28 00 00       	add    $0x2828,%eax
801093f8:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
801093fb:	8b 45 b8             	mov    -0x48(%ebp),%eax
801093fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80109404:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
80109409:	05 00 01 00 00       	add    $0x100,%eax
8010940e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80109411:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109414:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
8010941a:	e8 59 99 ff ff       	call   80102d78 <kalloc>
8010941f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109422:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
80109427:	05 00 28 00 00       	add    $0x2800,%eax
8010942c:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010942f:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
80109434:	05 04 28 00 00       	add    $0x2804,%eax
80109439:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010943c:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
80109441:	05 08 28 00 00       	add    $0x2808,%eax
80109446:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80109449:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
8010944e:	05 10 28 00 00       	add    $0x2810,%eax
80109453:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80109456:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
8010945b:	05 18 28 00 00       	add    $0x2818,%eax
80109460:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80109463:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109466:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010946c:	8b 45 ac             	mov    -0x54(%ebp),%eax
8010946f:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80109471:	8b 45 a8             	mov    -0x58(%ebp),%eax
80109474:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
8010947a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
8010947d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80109483:	8b 45 a0             	mov    -0x60(%ebp),%eax
80109486:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
8010948c:	8b 45 9c             	mov    -0x64(%ebp),%eax
8010948f:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80109495:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109498:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010949b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801094a2:	eb 73                	jmp    80109517 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
801094a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094a7:	c1 e0 04             	shl    $0x4,%eax
801094aa:	89 c2                	mov    %eax,%edx
801094ac:	8b 45 98             	mov    -0x68(%ebp),%eax
801094af:	01 d0                	add    %edx,%eax
801094b1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801094b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094bb:	c1 e0 04             	shl    $0x4,%eax
801094be:	89 c2                	mov    %eax,%edx
801094c0:	8b 45 98             	mov    -0x68(%ebp),%eax
801094c3:	01 d0                	add    %edx,%eax
801094c5:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801094cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094ce:	c1 e0 04             	shl    $0x4,%eax
801094d1:	89 c2                	mov    %eax,%edx
801094d3:	8b 45 98             	mov    -0x68(%ebp),%eax
801094d6:	01 d0                	add    %edx,%eax
801094d8:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
801094de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094e1:	c1 e0 04             	shl    $0x4,%eax
801094e4:	89 c2                	mov    %eax,%edx
801094e6:	8b 45 98             	mov    -0x68(%ebp),%eax
801094e9:	01 d0                	add    %edx,%eax
801094eb:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
801094ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801094f2:	c1 e0 04             	shl    $0x4,%eax
801094f5:	89 c2                	mov    %eax,%edx
801094f7:	8b 45 98             	mov    -0x68(%ebp),%eax
801094fa:	01 d0                	add    %edx,%eax
801094fc:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80109500:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109503:	c1 e0 04             	shl    $0x4,%eax
80109506:	89 c2                	mov    %eax,%edx
80109508:	8b 45 98             	mov    -0x68(%ebp),%eax
8010950b:	01 d0                	add    %edx,%eax
8010950d:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109513:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109517:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010951e:	7e 84                	jle    801094a4 <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80109520:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80109527:	eb 57                	jmp    80109580 <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80109529:	e8 4a 98 ff ff       	call   80102d78 <kalloc>
8010952e:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109531:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109535:	75 12                	jne    80109549 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80109537:	83 ec 0c             	sub    $0xc,%esp
8010953a:	68 98 cd 10 80       	push   $0x8010cd98
8010953f:	e8 c8 6e ff ff       	call   8010040c <cprintf>
80109544:	83 c4 10             	add    $0x10,%esp
      break;
80109547:	eb 3d                	jmp    80109586 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109549:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010954c:	c1 e0 04             	shl    $0x4,%eax
8010954f:	89 c2                	mov    %eax,%edx
80109551:	8b 45 98             	mov    -0x68(%ebp),%eax
80109554:	01 d0                	add    %edx,%eax
80109556:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109559:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010955f:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109561:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109564:	83 c0 01             	add    $0x1,%eax
80109567:	c1 e0 04             	shl    $0x4,%eax
8010956a:	89 c2                	mov    %eax,%edx
8010956c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010956f:	01 d0                	add    %edx,%eax
80109571:	8b 55 94             	mov    -0x6c(%ebp),%edx
80109574:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
8010957a:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010957c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80109580:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80109584:	7e a3                	jle    80109529 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80109586:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109589:	8b 00                	mov    (%eax),%eax
8010958b:	83 c8 02             	or     $0x2,%eax
8010958e:	89 c2                	mov    %eax,%edx
80109590:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109593:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80109595:	83 ec 0c             	sub    $0xc,%esp
80109598:	68 b8 cd 10 80       	push   $0x8010cdb8
8010959d:	e8 6a 6e ff ff       	call   8010040c <cprintf>
801095a2:	83 c4 10             	add    $0x10,%esp
}
801095a5:	90                   	nop
801095a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801095a9:	5b                   	pop    %ebx
801095aa:	5e                   	pop    %esi
801095ab:	5f                   	pop    %edi
801095ac:	5d                   	pop    %ebp
801095ad:	c3                   	ret    

801095ae <i8254_init_send>:

void i8254_init_send(){
801095ae:	f3 0f 1e fb          	endbr32 
801095b2:	55                   	push   %ebp
801095b3:	89 e5                	mov    %esp,%ebp
801095b5:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801095b8:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801095bd:	05 28 38 00 00       	add    $0x3828,%eax
801095c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801095c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801095c8:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801095ce:	e8 a5 97 ff ff       	call   80102d78 <kalloc>
801095d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801095d6:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801095db:	05 00 38 00 00       	add    $0x3800,%eax
801095e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
801095e3:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801095e8:	05 04 38 00 00       	add    $0x3804,%eax
801095ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
801095f0:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801095f5:	05 08 38 00 00       	add    $0x3808,%eax
801095fa:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
801095fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109600:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109606:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109609:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
8010960b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010960e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109614:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109617:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010961d:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
80109622:	05 10 38 00 00       	add    $0x3810,%eax
80109627:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010962a:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
8010962f:	05 18 38 00 00       	add    $0x3818,%eax
80109634:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109637:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010963a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80109640:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109643:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109649:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010964c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010964f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109656:	e9 82 00 00 00       	jmp    801096dd <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
8010965b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010965e:	c1 e0 04             	shl    $0x4,%eax
80109661:	89 c2                	mov    %eax,%edx
80109663:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109666:	01 d0                	add    %edx,%eax
80109668:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010966f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109672:	c1 e0 04             	shl    $0x4,%eax
80109675:	89 c2                	mov    %eax,%edx
80109677:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010967a:	01 d0                	add    %edx,%eax
8010967c:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109685:	c1 e0 04             	shl    $0x4,%eax
80109688:	89 c2                	mov    %eax,%edx
8010968a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010968d:	01 d0                	add    %edx,%eax
8010968f:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80109693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109696:	c1 e0 04             	shl    $0x4,%eax
80109699:	89 c2                	mov    %eax,%edx
8010969b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010969e:	01 d0                	add    %edx,%eax
801096a0:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801096a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096a7:	c1 e0 04             	shl    $0x4,%eax
801096aa:	89 c2                	mov    %eax,%edx
801096ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
801096af:	01 d0                	add    %edx,%eax
801096b1:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801096b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096b8:	c1 e0 04             	shl    $0x4,%eax
801096bb:	89 c2                	mov    %eax,%edx
801096bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
801096c0:	01 d0                	add    %edx,%eax
801096c2:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801096c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096c9:	c1 e0 04             	shl    $0x4,%eax
801096cc:	89 c2                	mov    %eax,%edx
801096ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
801096d1:	01 d0                	add    %edx,%eax
801096d3:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801096d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801096dd:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801096e4:	0f 8e 71 ff ff ff    	jle    8010965b <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801096ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801096f1:	eb 57                	jmp    8010974a <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
801096f3:	e8 80 96 ff ff       	call   80102d78 <kalloc>
801096f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801096fb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801096ff:	75 12                	jne    80109713 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80109701:	83 ec 0c             	sub    $0xc,%esp
80109704:	68 98 cd 10 80       	push   $0x8010cd98
80109709:	e8 fe 6c ff ff       	call   8010040c <cprintf>
8010970e:	83 c4 10             	add    $0x10,%esp
      break;
80109711:	eb 3d                	jmp    80109750 <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109716:	c1 e0 04             	shl    $0x4,%eax
80109719:	89 c2                	mov    %eax,%edx
8010971b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010971e:	01 d0                	add    %edx,%eax
80109720:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109723:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109729:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010972b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010972e:	83 c0 01             	add    $0x1,%eax
80109731:	c1 e0 04             	shl    $0x4,%eax
80109734:	89 c2                	mov    %eax,%edx
80109736:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109739:	01 d0                	add    %edx,%eax
8010973b:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010973e:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109744:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109746:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010974a:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010974e:	7e a3                	jle    801096f3 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80109750:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
80109755:	05 00 04 00 00       	add    $0x400,%eax
8010975a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010975d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109760:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80109766:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
8010976b:	05 10 04 00 00       	add    $0x410,%eax
80109770:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80109773:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80109776:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
8010977c:	83 ec 0c             	sub    $0xc,%esp
8010977f:	68 d8 cd 10 80       	push   $0x8010cdd8
80109784:	e8 83 6c ff ff       	call   8010040c <cprintf>
80109789:	83 c4 10             	add    $0x10,%esp

}
8010978c:	90                   	nop
8010978d:	c9                   	leave  
8010978e:	c3                   	ret    

8010978f <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
8010978f:	f3 0f 1e fb          	endbr32 
80109793:	55                   	push   %ebp
80109794:	89 e5                	mov    %esp,%ebp
80109796:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109799:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
8010979e:	83 c0 14             	add    $0x14,%eax
801097a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801097a4:	8b 45 08             	mov    0x8(%ebp),%eax
801097a7:	c1 e0 08             	shl    $0x8,%eax
801097aa:	0f b7 c0             	movzwl %ax,%eax
801097ad:	83 c8 01             	or     $0x1,%eax
801097b0:	89 c2                	mov    %eax,%edx
801097b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b5:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801097b7:	83 ec 0c             	sub    $0xc,%esp
801097ba:	68 f8 cd 10 80       	push   $0x8010cdf8
801097bf:	e8 48 6c ff ff       	call   8010040c <cprintf>
801097c4:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801097c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ca:	8b 00                	mov    (%eax),%eax
801097cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801097cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097d2:	83 e0 10             	and    $0x10,%eax
801097d5:	85 c0                	test   %eax,%eax
801097d7:	75 02                	jne    801097db <i8254_read_eeprom+0x4c>
  while(1){
801097d9:	eb dc                	jmp    801097b7 <i8254_read_eeprom+0x28>
      break;
801097db:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
801097dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097df:	8b 00                	mov    (%eax),%eax
801097e1:	c1 e8 10             	shr    $0x10,%eax
}
801097e4:	c9                   	leave  
801097e5:	c3                   	ret    

801097e6 <i8254_recv>:
void i8254_recv(){
801097e6:	f3 0f 1e fb          	endbr32 
801097ea:	55                   	push   %ebp
801097eb:	89 e5                	mov    %esp,%ebp
801097ed:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
801097f0:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801097f5:	05 10 28 00 00       	add    $0x2810,%eax
801097fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801097fd:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
80109802:	05 18 28 00 00       	add    $0x2818,%eax
80109807:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
8010980a:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
8010980f:	05 00 28 00 00       	add    $0x2800,%eax
80109814:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109817:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010981a:	8b 00                	mov    (%eax),%eax
8010981c:	05 00 00 00 80       	add    $0x80000000,%eax
80109821:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109827:	8b 10                	mov    (%eax),%edx
80109829:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010982c:	8b 00                	mov    (%eax),%eax
8010982e:	29 c2                	sub    %eax,%edx
80109830:	89 d0                	mov    %edx,%eax
80109832:	25 ff 00 00 00       	and    $0xff,%eax
80109837:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
8010983a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010983e:	7e 37                	jle    80109877 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80109840:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109843:	8b 00                	mov    (%eax),%eax
80109845:	c1 e0 04             	shl    $0x4,%eax
80109848:	89 c2                	mov    %eax,%edx
8010984a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010984d:	01 d0                	add    %edx,%eax
8010984f:	8b 00                	mov    (%eax),%eax
80109851:	05 00 00 00 80       	add    $0x80000000,%eax
80109856:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80109859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010985c:	8b 00                	mov    (%eax),%eax
8010985e:	83 c0 01             	add    $0x1,%eax
80109861:	0f b6 d0             	movzbl %al,%edx
80109864:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109867:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80109869:	83 ec 0c             	sub    $0xc,%esp
8010986c:	ff 75 e0             	pushl  -0x20(%ebp)
8010986f:	e8 47 09 00 00       	call   8010a1bb <eth_proc>
80109874:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80109877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010987a:	8b 10                	mov    (%eax),%edx
8010987c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010987f:	8b 00                	mov    (%eax),%eax
80109881:	39 c2                	cmp    %eax,%edx
80109883:	75 9f                	jne    80109824 <i8254_recv+0x3e>
      (*rdt)--;
80109885:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109888:	8b 00                	mov    (%eax),%eax
8010988a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010988d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109890:	89 10                	mov    %edx,(%eax)
  while(1){
80109892:	eb 90                	jmp    80109824 <i8254_recv+0x3e>

80109894 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109894:	f3 0f 1e fb          	endbr32 
80109898:	55                   	push   %ebp
80109899:	89 e5                	mov    %esp,%ebp
8010989b:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
8010989e:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801098a3:	05 10 38 00 00       	add    $0x3810,%eax
801098a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801098ab:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801098b0:	05 18 38 00 00       	add    $0x3818,%eax
801098b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
801098b8:	a1 f4 b4 11 80       	mov    0x8011b4f4,%eax
801098bd:	05 00 38 00 00       	add    $0x3800,%eax
801098c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
801098c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098c8:	8b 00                	mov    (%eax),%eax
801098ca:	05 00 00 00 80       	add    $0x80000000,%eax
801098cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
801098d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098d5:	8b 10                	mov    (%eax),%edx
801098d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098da:	8b 00                	mov    (%eax),%eax
801098dc:	29 c2                	sub    %eax,%edx
801098de:	89 d0                	mov    %edx,%eax
801098e0:	0f b6 c0             	movzbl %al,%eax
801098e3:	ba 00 01 00 00       	mov    $0x100,%edx
801098e8:	29 c2                	sub    %eax,%edx
801098ea:	89 d0                	mov    %edx,%eax
801098ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
801098ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098f2:	8b 00                	mov    (%eax),%eax
801098f4:	25 ff 00 00 00       	and    $0xff,%eax
801098f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
801098fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80109900:	0f 8e a8 00 00 00    	jle    801099ae <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109906:	8b 45 08             	mov    0x8(%ebp),%eax
80109909:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010990c:	89 d1                	mov    %edx,%ecx
8010990e:	c1 e1 04             	shl    $0x4,%ecx
80109911:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109914:	01 ca                	add    %ecx,%edx
80109916:	8b 12                	mov    (%edx),%edx
80109918:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010991e:	83 ec 04             	sub    $0x4,%esp
80109921:	ff 75 0c             	pushl  0xc(%ebp)
80109924:	50                   	push   %eax
80109925:	52                   	push   %edx
80109926:	e8 fb bb ff ff       	call   80105526 <memmove>
8010992b:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010992e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109931:	c1 e0 04             	shl    $0x4,%eax
80109934:	89 c2                	mov    %eax,%edx
80109936:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109939:	01 d0                	add    %edx,%eax
8010993b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010993e:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109942:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109945:	c1 e0 04             	shl    $0x4,%eax
80109948:	89 c2                	mov    %eax,%edx
8010994a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010994d:	01 d0                	add    %edx,%eax
8010994f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109953:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109956:	c1 e0 04             	shl    $0x4,%eax
80109959:	89 c2                	mov    %eax,%edx
8010995b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010995e:	01 d0                	add    %edx,%eax
80109960:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80109964:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109967:	c1 e0 04             	shl    $0x4,%eax
8010996a:	89 c2                	mov    %eax,%edx
8010996c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010996f:	01 d0                	add    %edx,%eax
80109971:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80109975:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109978:	c1 e0 04             	shl    $0x4,%eax
8010997b:	89 c2                	mov    %eax,%edx
8010997d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109980:	01 d0                	add    %edx,%eax
80109982:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109988:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010998b:	c1 e0 04             	shl    $0x4,%eax
8010998e:	89 c2                	mov    %eax,%edx
80109990:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109993:	01 d0                	add    %edx,%eax
80109995:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010999c:	8b 00                	mov    (%eax),%eax
8010999e:	83 c0 01             	add    $0x1,%eax
801099a1:	0f b6 d0             	movzbl %al,%edx
801099a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099a7:	89 10                	mov    %edx,(%eax)
    return len;
801099a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801099ac:	eb 05                	jmp    801099b3 <i8254_send+0x11f>
  }else{
    return -1;
801099ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801099b3:	c9                   	leave  
801099b4:	c3                   	ret    

801099b5 <i8254_intr>:

void i8254_intr(){
801099b5:	f3 0f 1e fb          	endbr32 
801099b9:	55                   	push   %ebp
801099ba:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801099bc:	a1 f8 b4 11 80       	mov    0x8011b4f8,%eax
801099c1:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
801099c7:	90                   	nop
801099c8:	5d                   	pop    %ebp
801099c9:	c3                   	ret    

801099ca <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
801099ca:	f3 0f 1e fb          	endbr32 
801099ce:	55                   	push   %ebp
801099cf:	89 e5                	mov    %esp,%ebp
801099d1:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
801099d4:	8b 45 08             	mov    0x8(%ebp),%eax
801099d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
801099da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099dd:	0f b7 00             	movzwl (%eax),%eax
801099e0:	66 3d 00 01          	cmp    $0x100,%ax
801099e4:	74 0a                	je     801099f0 <arp_proc+0x26>
801099e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801099eb:	e9 4f 01 00 00       	jmp    80109b3f <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
801099f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099f3:	0f b7 40 02          	movzwl 0x2(%eax),%eax
801099f7:	66 83 f8 08          	cmp    $0x8,%ax
801099fb:	74 0a                	je     80109a07 <arp_proc+0x3d>
801099fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a02:	e9 38 01 00 00       	jmp    80109b3f <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80109a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a0a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109a0e:	3c 06                	cmp    $0x6,%al
80109a10:	74 0a                	je     80109a1c <arp_proc+0x52>
80109a12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a17:	e9 23 01 00 00       	jmp    80109b3f <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
80109a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a1f:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109a23:	3c 04                	cmp    $0x4,%al
80109a25:	74 0a                	je     80109a31 <arp_proc+0x67>
80109a27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a2c:	e9 0e 01 00 00       	jmp    80109b3f <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a34:	83 c0 18             	add    $0x18,%eax
80109a37:	83 ec 04             	sub    $0x4,%esp
80109a3a:	6a 04                	push   $0x4
80109a3c:	50                   	push   %eax
80109a3d:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a42:	e8 83 ba ff ff       	call   801054ca <memcmp>
80109a47:	83 c4 10             	add    $0x10,%esp
80109a4a:	85 c0                	test   %eax,%eax
80109a4c:	74 27                	je     80109a75 <arp_proc+0xab>
80109a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a51:	83 c0 0e             	add    $0xe,%eax
80109a54:	83 ec 04             	sub    $0x4,%esp
80109a57:	6a 04                	push   $0x4
80109a59:	50                   	push   %eax
80109a5a:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a5f:	e8 66 ba ff ff       	call   801054ca <memcmp>
80109a64:	83 c4 10             	add    $0x10,%esp
80109a67:	85 c0                	test   %eax,%eax
80109a69:	74 0a                	je     80109a75 <arp_proc+0xab>
80109a6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109a70:	e9 ca 00 00 00       	jmp    80109b3f <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a78:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a7c:	66 3d 00 01          	cmp    $0x100,%ax
80109a80:	75 69                	jne    80109aeb <arp_proc+0x121>
80109a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a85:	83 c0 18             	add    $0x18,%eax
80109a88:	83 ec 04             	sub    $0x4,%esp
80109a8b:	6a 04                	push   $0x4
80109a8d:	50                   	push   %eax
80109a8e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109a93:	e8 32 ba ff ff       	call   801054ca <memcmp>
80109a98:	83 c4 10             	add    $0x10,%esp
80109a9b:	85 c0                	test   %eax,%eax
80109a9d:	75 4c                	jne    80109aeb <arp_proc+0x121>
    uint send = (uint)kalloc();
80109a9f:	e8 d4 92 ff ff       	call   80102d78 <kalloc>
80109aa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109aa7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80109aae:	83 ec 04             	sub    $0x4,%esp
80109ab1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109ab4:	50                   	push   %eax
80109ab5:	ff 75 f0             	pushl  -0x10(%ebp)
80109ab8:	ff 75 f4             	pushl  -0xc(%ebp)
80109abb:	e8 33 04 00 00       	call   80109ef3 <arp_reply_pkt_create>
80109ac0:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109ac3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ac6:	83 ec 08             	sub    $0x8,%esp
80109ac9:	50                   	push   %eax
80109aca:	ff 75 f0             	pushl  -0x10(%ebp)
80109acd:	e8 c2 fd ff ff       	call   80109894 <i8254_send>
80109ad2:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ad8:	83 ec 0c             	sub    $0xc,%esp
80109adb:	50                   	push   %eax
80109adc:	e8 f9 91 ff ff       	call   80102cda <kfree>
80109ae1:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109ae4:	b8 02 00 00 00       	mov    $0x2,%eax
80109ae9:	eb 54                	jmp    80109b3f <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109aee:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109af2:	66 3d 00 02          	cmp    $0x200,%ax
80109af6:	75 42                	jne    80109b3a <arp_proc+0x170>
80109af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109afb:	83 c0 18             	add    $0x18,%eax
80109afe:	83 ec 04             	sub    $0x4,%esp
80109b01:	6a 04                	push   $0x4
80109b03:	50                   	push   %eax
80109b04:	68 e4 f4 10 80       	push   $0x8010f4e4
80109b09:	e8 bc b9 ff ff       	call   801054ca <memcmp>
80109b0e:	83 c4 10             	add    $0x10,%esp
80109b11:	85 c0                	test   %eax,%eax
80109b13:	75 25                	jne    80109b3a <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
80109b15:	83 ec 0c             	sub    $0xc,%esp
80109b18:	68 fc cd 10 80       	push   $0x8010cdfc
80109b1d:	e8 ea 68 ff ff       	call   8010040c <cprintf>
80109b22:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109b25:	83 ec 0c             	sub    $0xc,%esp
80109b28:	ff 75 f4             	pushl  -0xc(%ebp)
80109b2b:	e8 b7 01 00 00       	call   80109ce7 <arp_table_update>
80109b30:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109b33:	b8 01 00 00 00       	mov    $0x1,%eax
80109b38:	eb 05                	jmp    80109b3f <arp_proc+0x175>
  }else{
    return -1;
80109b3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109b3f:	c9                   	leave  
80109b40:	c3                   	ret    

80109b41 <arp_scan>:

void arp_scan(){
80109b41:	f3 0f 1e fb          	endbr32 
80109b45:	55                   	push   %ebp
80109b46:	89 e5                	mov    %esp,%ebp
80109b48:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109b4b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109b52:	eb 6f                	jmp    80109bc3 <arp_scan+0x82>
    uint send = (uint)kalloc();
80109b54:	e8 1f 92 ff ff       	call   80102d78 <kalloc>
80109b59:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109b5c:	83 ec 04             	sub    $0x4,%esp
80109b5f:	ff 75 f4             	pushl  -0xc(%ebp)
80109b62:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109b65:	50                   	push   %eax
80109b66:	ff 75 ec             	pushl  -0x14(%ebp)
80109b69:	e8 62 00 00 00       	call   80109bd0 <arp_broadcast>
80109b6e:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109b71:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b74:	83 ec 08             	sub    $0x8,%esp
80109b77:	50                   	push   %eax
80109b78:	ff 75 ec             	pushl  -0x14(%ebp)
80109b7b:	e8 14 fd ff ff       	call   80109894 <i8254_send>
80109b80:	83 c4 10             	add    $0x10,%esp
80109b83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109b86:	eb 22                	jmp    80109baa <arp_scan+0x69>
      microdelay(1);
80109b88:	83 ec 0c             	sub    $0xc,%esp
80109b8b:	6a 01                	push   $0x1
80109b8d:	e8 98 95 ff ff       	call   8010312a <microdelay>
80109b92:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109b95:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b98:	83 ec 08             	sub    $0x8,%esp
80109b9b:	50                   	push   %eax
80109b9c:	ff 75 ec             	pushl  -0x14(%ebp)
80109b9f:	e8 f0 fc ff ff       	call   80109894 <i8254_send>
80109ba4:	83 c4 10             	add    $0x10,%esp
80109ba7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109baa:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109bae:	74 d8                	je     80109b88 <arp_scan+0x47>
    }
    kfree((char *)send);
80109bb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109bb3:	83 ec 0c             	sub    $0xc,%esp
80109bb6:	50                   	push   %eax
80109bb7:	e8 1e 91 ff ff       	call   80102cda <kfree>
80109bbc:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109bbf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109bc3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109bca:	7e 88                	jle    80109b54 <arp_scan+0x13>
  }
}
80109bcc:	90                   	nop
80109bcd:	90                   	nop
80109bce:	c9                   	leave  
80109bcf:	c3                   	ret    

80109bd0 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109bd0:	f3 0f 1e fb          	endbr32 
80109bd4:	55                   	push   %ebp
80109bd5:	89 e5                	mov    %esp,%ebp
80109bd7:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109bda:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109bde:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109be2:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109be6:	8b 45 10             	mov    0x10(%ebp),%eax
80109be9:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109bec:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109bf3:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109bf9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109c00:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109c06:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c09:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109c15:	8b 45 08             	mov    0x8(%ebp),%eax
80109c18:	83 c0 0e             	add    $0xe,%eax
80109c1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c21:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c28:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c2f:	83 ec 04             	sub    $0x4,%esp
80109c32:	6a 06                	push   $0x6
80109c34:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109c37:	52                   	push   %edx
80109c38:	50                   	push   %eax
80109c39:	e8 e8 b8 ff ff       	call   80105526 <memmove>
80109c3e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c44:	83 c0 06             	add    $0x6,%eax
80109c47:	83 ec 04             	sub    $0x4,%esp
80109c4a:	6a 06                	push   $0x6
80109c4c:	68 ac 00 11 80       	push   $0x801100ac
80109c51:	50                   	push   %eax
80109c52:	e8 cf b8 ff ff       	call   80105526 <memmove>
80109c57:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c5d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c65:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109c6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c6e:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c75:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c7c:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c85:	8d 50 12             	lea    0x12(%eax),%edx
80109c88:	83 ec 04             	sub    $0x4,%esp
80109c8b:	6a 06                	push   $0x6
80109c8d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109c90:	50                   	push   %eax
80109c91:	52                   	push   %edx
80109c92:	e8 8f b8 ff ff       	call   80105526 <memmove>
80109c97:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c9d:	8d 50 18             	lea    0x18(%eax),%edx
80109ca0:	83 ec 04             	sub    $0x4,%esp
80109ca3:	6a 04                	push   $0x4
80109ca5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109ca8:	50                   	push   %eax
80109ca9:	52                   	push   %edx
80109caa:	e8 77 b8 ff ff       	call   80105526 <memmove>
80109caf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cb5:	83 c0 08             	add    $0x8,%eax
80109cb8:	83 ec 04             	sub    $0x4,%esp
80109cbb:	6a 06                	push   $0x6
80109cbd:	68 ac 00 11 80       	push   $0x801100ac
80109cc2:	50                   	push   %eax
80109cc3:	e8 5e b8 ff ff       	call   80105526 <memmove>
80109cc8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cce:	83 c0 0e             	add    $0xe,%eax
80109cd1:	83 ec 04             	sub    $0x4,%esp
80109cd4:	6a 04                	push   $0x4
80109cd6:	68 e4 f4 10 80       	push   $0x8010f4e4
80109cdb:	50                   	push   %eax
80109cdc:	e8 45 b8 ff ff       	call   80105526 <memmove>
80109ce1:	83 c4 10             	add    $0x10,%esp
}
80109ce4:	90                   	nop
80109ce5:	c9                   	leave  
80109ce6:	c3                   	ret    

80109ce7 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109ce7:	f3 0f 1e fb          	endbr32 
80109ceb:	55                   	push   %ebp
80109cec:	89 e5                	mov    %esp,%ebp
80109cee:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80109cf4:	83 c0 0e             	add    $0xe,%eax
80109cf7:	83 ec 0c             	sub    $0xc,%esp
80109cfa:	50                   	push   %eax
80109cfb:	e8 bc 00 00 00       	call   80109dbc <arp_table_search>
80109d00:	83 c4 10             	add    $0x10,%esp
80109d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109d06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109d0a:	78 2d                	js     80109d39 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80109d0f:	8d 48 08             	lea    0x8(%eax),%ecx
80109d12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109d15:	89 d0                	mov    %edx,%eax
80109d17:	c1 e0 02             	shl    $0x2,%eax
80109d1a:	01 d0                	add    %edx,%eax
80109d1c:	01 c0                	add    %eax,%eax
80109d1e:	01 d0                	add    %edx,%eax
80109d20:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109d25:	83 c0 04             	add    $0x4,%eax
80109d28:	83 ec 04             	sub    $0x4,%esp
80109d2b:	6a 06                	push   $0x6
80109d2d:	51                   	push   %ecx
80109d2e:	50                   	push   %eax
80109d2f:	e8 f2 b7 ff ff       	call   80105526 <memmove>
80109d34:	83 c4 10             	add    $0x10,%esp
80109d37:	eb 70                	jmp    80109da9 <arp_table_update+0xc2>
  }else{
    index += 1;
80109d39:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109d3d:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109d40:	8b 45 08             	mov    0x8(%ebp),%eax
80109d43:	8d 48 08             	lea    0x8(%eax),%ecx
80109d46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109d49:	89 d0                	mov    %edx,%eax
80109d4b:	c1 e0 02             	shl    $0x2,%eax
80109d4e:	01 d0                	add    %edx,%eax
80109d50:	01 c0                	add    %eax,%eax
80109d52:	01 d0                	add    %edx,%eax
80109d54:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109d59:	83 c0 04             	add    $0x4,%eax
80109d5c:	83 ec 04             	sub    $0x4,%esp
80109d5f:	6a 06                	push   $0x6
80109d61:	51                   	push   %ecx
80109d62:	50                   	push   %eax
80109d63:	e8 be b7 ff ff       	call   80105526 <memmove>
80109d68:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80109d6e:	8d 48 0e             	lea    0xe(%eax),%ecx
80109d71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109d74:	89 d0                	mov    %edx,%eax
80109d76:	c1 e0 02             	shl    $0x2,%eax
80109d79:	01 d0                	add    %edx,%eax
80109d7b:	01 c0                	add    %eax,%eax
80109d7d:	01 d0                	add    %edx,%eax
80109d7f:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109d84:	83 ec 04             	sub    $0x4,%esp
80109d87:	6a 04                	push   $0x4
80109d89:	51                   	push   %ecx
80109d8a:	50                   	push   %eax
80109d8b:	e8 96 b7 ff ff       	call   80105526 <memmove>
80109d90:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109d93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109d96:	89 d0                	mov    %edx,%eax
80109d98:	c1 e0 02             	shl    $0x2,%eax
80109d9b:	01 d0                	add    %edx,%eax
80109d9d:	01 c0                	add    %eax,%eax
80109d9f:	01 d0                	add    %edx,%eax
80109da1:	05 ca 00 11 80       	add    $0x801100ca,%eax
80109da6:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109da9:	83 ec 0c             	sub    $0xc,%esp
80109dac:	68 c0 00 11 80       	push   $0x801100c0
80109db1:	e8 87 00 00 00       	call   80109e3d <print_arp_table>
80109db6:	83 c4 10             	add    $0x10,%esp
}
80109db9:	90                   	nop
80109dba:	c9                   	leave  
80109dbb:	c3                   	ret    

80109dbc <arp_table_search>:

int arp_table_search(uchar *ip){
80109dbc:	f3 0f 1e fb          	endbr32 
80109dc0:	55                   	push   %ebp
80109dc1:	89 e5                	mov    %esp,%ebp
80109dc3:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109dc6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109dcd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109dd4:	eb 59                	jmp    80109e2f <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109dd6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109dd9:	89 d0                	mov    %edx,%eax
80109ddb:	c1 e0 02             	shl    $0x2,%eax
80109dde:	01 d0                	add    %edx,%eax
80109de0:	01 c0                	add    %eax,%eax
80109de2:	01 d0                	add    %edx,%eax
80109de4:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109de9:	83 ec 04             	sub    $0x4,%esp
80109dec:	6a 04                	push   $0x4
80109dee:	ff 75 08             	pushl  0x8(%ebp)
80109df1:	50                   	push   %eax
80109df2:	e8 d3 b6 ff ff       	call   801054ca <memcmp>
80109df7:	83 c4 10             	add    $0x10,%esp
80109dfa:	85 c0                	test   %eax,%eax
80109dfc:	75 05                	jne    80109e03 <arp_table_search+0x47>
      return i;
80109dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e01:	eb 38                	jmp    80109e3b <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109e03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109e06:	89 d0                	mov    %edx,%eax
80109e08:	c1 e0 02             	shl    $0x2,%eax
80109e0b:	01 d0                	add    %edx,%eax
80109e0d:	01 c0                	add    %eax,%eax
80109e0f:	01 d0                	add    %edx,%eax
80109e11:	05 ca 00 11 80       	add    $0x801100ca,%eax
80109e16:	0f b6 00             	movzbl (%eax),%eax
80109e19:	84 c0                	test   %al,%al
80109e1b:	75 0e                	jne    80109e2b <arp_table_search+0x6f>
80109e1d:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109e21:	75 08                	jne    80109e2b <arp_table_search+0x6f>
      empty = -i;
80109e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e26:	f7 d8                	neg    %eax
80109e28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109e2b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109e2f:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109e33:	7e a1                	jle    80109dd6 <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e38:	83 e8 01             	sub    $0x1,%eax
}
80109e3b:	c9                   	leave  
80109e3c:	c3                   	ret    

80109e3d <print_arp_table>:

void print_arp_table(){
80109e3d:	f3 0f 1e fb          	endbr32 
80109e41:	55                   	push   %ebp
80109e42:	89 e5                	mov    %esp,%ebp
80109e44:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109e47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109e4e:	e9 92 00 00 00       	jmp    80109ee5 <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109e53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e56:	89 d0                	mov    %edx,%eax
80109e58:	c1 e0 02             	shl    $0x2,%eax
80109e5b:	01 d0                	add    %edx,%eax
80109e5d:	01 c0                	add    %eax,%eax
80109e5f:	01 d0                	add    %edx,%eax
80109e61:	05 ca 00 11 80       	add    $0x801100ca,%eax
80109e66:	0f b6 00             	movzbl (%eax),%eax
80109e69:	84 c0                	test   %al,%al
80109e6b:	74 74                	je     80109ee1 <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109e6d:	83 ec 08             	sub    $0x8,%esp
80109e70:	ff 75 f4             	pushl  -0xc(%ebp)
80109e73:	68 0f ce 10 80       	push   $0x8010ce0f
80109e78:	e8 8f 65 ff ff       	call   8010040c <cprintf>
80109e7d:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109e80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e83:	89 d0                	mov    %edx,%eax
80109e85:	c1 e0 02             	shl    $0x2,%eax
80109e88:	01 d0                	add    %edx,%eax
80109e8a:	01 c0                	add    %eax,%eax
80109e8c:	01 d0                	add    %edx,%eax
80109e8e:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109e93:	83 ec 0c             	sub    $0xc,%esp
80109e96:	50                   	push   %eax
80109e97:	e8 5c 02 00 00       	call   8010a0f8 <print_ipv4>
80109e9c:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109e9f:	83 ec 0c             	sub    $0xc,%esp
80109ea2:	68 1e ce 10 80       	push   $0x8010ce1e
80109ea7:	e8 60 65 ff ff       	call   8010040c <cprintf>
80109eac:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109eaf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109eb2:	89 d0                	mov    %edx,%eax
80109eb4:	c1 e0 02             	shl    $0x2,%eax
80109eb7:	01 d0                	add    %edx,%eax
80109eb9:	01 c0                	add    %eax,%eax
80109ebb:	01 d0                	add    %edx,%eax
80109ebd:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109ec2:	83 c0 04             	add    $0x4,%eax
80109ec5:	83 ec 0c             	sub    $0xc,%esp
80109ec8:	50                   	push   %eax
80109ec9:	e8 7c 02 00 00       	call   8010a14a <print_mac>
80109ece:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109ed1:	83 ec 0c             	sub    $0xc,%esp
80109ed4:	68 20 ce 10 80       	push   $0x8010ce20
80109ed9:	e8 2e 65 ff ff       	call   8010040c <cprintf>
80109ede:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109ee1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109ee5:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109ee9:	0f 8e 64 ff ff ff    	jle    80109e53 <print_arp_table+0x16>
    }
  }
}
80109eef:	90                   	nop
80109ef0:	90                   	nop
80109ef1:	c9                   	leave  
80109ef2:	c3                   	ret    

80109ef3 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109ef3:	f3 0f 1e fb          	endbr32 
80109ef7:	55                   	push   %ebp
80109ef8:	89 e5                	mov    %esp,%ebp
80109efa:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109efd:	8b 45 10             	mov    0x10(%ebp),%eax
80109f00:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109f06:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109f0c:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f0f:	83 c0 0e             	add    $0xe,%eax
80109f12:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f18:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f1f:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109f23:	8b 45 08             	mov    0x8(%ebp),%eax
80109f26:	8d 50 08             	lea    0x8(%eax),%edx
80109f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f2c:	83 ec 04             	sub    $0x4,%esp
80109f2f:	6a 06                	push   $0x6
80109f31:	52                   	push   %edx
80109f32:	50                   	push   %eax
80109f33:	e8 ee b5 ff ff       	call   80105526 <memmove>
80109f38:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f3e:	83 c0 06             	add    $0x6,%eax
80109f41:	83 ec 04             	sub    $0x4,%esp
80109f44:	6a 06                	push   $0x6
80109f46:	68 ac 00 11 80       	push   $0x801100ac
80109f4b:	50                   	push   %eax
80109f4c:	e8 d5 b5 ff ff       	call   80105526 <memmove>
80109f51:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109f54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f57:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f5f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109f65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f68:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109f6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f6f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f76:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80109f7f:	8d 50 08             	lea    0x8(%eax),%edx
80109f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f85:	83 c0 12             	add    $0x12,%eax
80109f88:	83 ec 04             	sub    $0x4,%esp
80109f8b:	6a 06                	push   $0x6
80109f8d:	52                   	push   %edx
80109f8e:	50                   	push   %eax
80109f8f:	e8 92 b5 ff ff       	call   80105526 <memmove>
80109f94:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109f97:	8b 45 08             	mov    0x8(%ebp),%eax
80109f9a:	8d 50 0e             	lea    0xe(%eax),%edx
80109f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fa0:	83 c0 18             	add    $0x18,%eax
80109fa3:	83 ec 04             	sub    $0x4,%esp
80109fa6:	6a 04                	push   $0x4
80109fa8:	52                   	push   %edx
80109fa9:	50                   	push   %eax
80109faa:	e8 77 b5 ff ff       	call   80105526 <memmove>
80109faf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fb5:	83 c0 08             	add    $0x8,%eax
80109fb8:	83 ec 04             	sub    $0x4,%esp
80109fbb:	6a 06                	push   $0x6
80109fbd:	68 ac 00 11 80       	push   $0x801100ac
80109fc2:	50                   	push   %eax
80109fc3:	e8 5e b5 ff ff       	call   80105526 <memmove>
80109fc8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fce:	83 c0 0e             	add    $0xe,%eax
80109fd1:	83 ec 04             	sub    $0x4,%esp
80109fd4:	6a 04                	push   $0x4
80109fd6:	68 e4 f4 10 80       	push   $0x8010f4e4
80109fdb:	50                   	push   %eax
80109fdc:	e8 45 b5 ff ff       	call   80105526 <memmove>
80109fe1:	83 c4 10             	add    $0x10,%esp
}
80109fe4:	90                   	nop
80109fe5:	c9                   	leave  
80109fe6:	c3                   	ret    

80109fe7 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109fe7:	f3 0f 1e fb          	endbr32 
80109feb:	55                   	push   %ebp
80109fec:	89 e5                	mov    %esp,%ebp
80109fee:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109ff1:	83 ec 0c             	sub    $0xc,%esp
80109ff4:	68 22 ce 10 80       	push   $0x8010ce22
80109ff9:	e8 0e 64 ff ff       	call   8010040c <cprintf>
80109ffe:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010a001:	8b 45 08             	mov    0x8(%ebp),%eax
8010a004:	83 c0 0e             	add    $0xe,%eax
8010a007:	83 ec 0c             	sub    $0xc,%esp
8010a00a:	50                   	push   %eax
8010a00b:	e8 e8 00 00 00       	call   8010a0f8 <print_ipv4>
8010a010:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a013:	83 ec 0c             	sub    $0xc,%esp
8010a016:	68 20 ce 10 80       	push   $0x8010ce20
8010a01b:	e8 ec 63 ff ff       	call   8010040c <cprintf>
8010a020:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010a023:	8b 45 08             	mov    0x8(%ebp),%eax
8010a026:	83 c0 08             	add    $0x8,%eax
8010a029:	83 ec 0c             	sub    $0xc,%esp
8010a02c:	50                   	push   %eax
8010a02d:	e8 18 01 00 00       	call   8010a14a <print_mac>
8010a032:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a035:	83 ec 0c             	sub    $0xc,%esp
8010a038:	68 20 ce 10 80       	push   $0x8010ce20
8010a03d:	e8 ca 63 ff ff       	call   8010040c <cprintf>
8010a042:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010a045:	83 ec 0c             	sub    $0xc,%esp
8010a048:	68 39 ce 10 80       	push   $0x8010ce39
8010a04d:	e8 ba 63 ff ff       	call   8010040c <cprintf>
8010a052:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010a055:	8b 45 08             	mov    0x8(%ebp),%eax
8010a058:	83 c0 18             	add    $0x18,%eax
8010a05b:	83 ec 0c             	sub    $0xc,%esp
8010a05e:	50                   	push   %eax
8010a05f:	e8 94 00 00 00       	call   8010a0f8 <print_ipv4>
8010a064:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a067:	83 ec 0c             	sub    $0xc,%esp
8010a06a:	68 20 ce 10 80       	push   $0x8010ce20
8010a06f:	e8 98 63 ff ff       	call   8010040c <cprintf>
8010a074:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010a077:	8b 45 08             	mov    0x8(%ebp),%eax
8010a07a:	83 c0 12             	add    $0x12,%eax
8010a07d:	83 ec 0c             	sub    $0xc,%esp
8010a080:	50                   	push   %eax
8010a081:	e8 c4 00 00 00       	call   8010a14a <print_mac>
8010a086:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010a089:	83 ec 0c             	sub    $0xc,%esp
8010a08c:	68 20 ce 10 80       	push   $0x8010ce20
8010a091:	e8 76 63 ff ff       	call   8010040c <cprintf>
8010a096:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010a099:	83 ec 0c             	sub    $0xc,%esp
8010a09c:	68 50 ce 10 80       	push   $0x8010ce50
8010a0a1:	e8 66 63 ff ff       	call   8010040c <cprintf>
8010a0a6:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010a0a9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0ac:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a0b0:	66 3d 00 01          	cmp    $0x100,%ax
8010a0b4:	75 12                	jne    8010a0c8 <print_arp_info+0xe1>
8010a0b6:	83 ec 0c             	sub    $0xc,%esp
8010a0b9:	68 5c ce 10 80       	push   $0x8010ce5c
8010a0be:	e8 49 63 ff ff       	call   8010040c <cprintf>
8010a0c3:	83 c4 10             	add    $0x10,%esp
8010a0c6:	eb 1d                	jmp    8010a0e5 <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010a0c8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0cb:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a0cf:	66 3d 00 02          	cmp    $0x200,%ax
8010a0d3:	75 10                	jne    8010a0e5 <print_arp_info+0xfe>
    cprintf("Reply\n");
8010a0d5:	83 ec 0c             	sub    $0xc,%esp
8010a0d8:	68 65 ce 10 80       	push   $0x8010ce65
8010a0dd:	e8 2a 63 ff ff       	call   8010040c <cprintf>
8010a0e2:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010a0e5:	83 ec 0c             	sub    $0xc,%esp
8010a0e8:	68 20 ce 10 80       	push   $0x8010ce20
8010a0ed:	e8 1a 63 ff ff       	call   8010040c <cprintf>
8010a0f2:	83 c4 10             	add    $0x10,%esp
}
8010a0f5:	90                   	nop
8010a0f6:	c9                   	leave  
8010a0f7:	c3                   	ret    

8010a0f8 <print_ipv4>:

void print_ipv4(uchar *ip){
8010a0f8:	f3 0f 1e fb          	endbr32 
8010a0fc:	55                   	push   %ebp
8010a0fd:	89 e5                	mov    %esp,%ebp
8010a0ff:	53                   	push   %ebx
8010a100:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010a103:	8b 45 08             	mov    0x8(%ebp),%eax
8010a106:	83 c0 03             	add    $0x3,%eax
8010a109:	0f b6 00             	movzbl (%eax),%eax
8010a10c:	0f b6 d8             	movzbl %al,%ebx
8010a10f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a112:	83 c0 02             	add    $0x2,%eax
8010a115:	0f b6 00             	movzbl (%eax),%eax
8010a118:	0f b6 c8             	movzbl %al,%ecx
8010a11b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a11e:	83 c0 01             	add    $0x1,%eax
8010a121:	0f b6 00             	movzbl (%eax),%eax
8010a124:	0f b6 d0             	movzbl %al,%edx
8010a127:	8b 45 08             	mov    0x8(%ebp),%eax
8010a12a:	0f b6 00             	movzbl (%eax),%eax
8010a12d:	0f b6 c0             	movzbl %al,%eax
8010a130:	83 ec 0c             	sub    $0xc,%esp
8010a133:	53                   	push   %ebx
8010a134:	51                   	push   %ecx
8010a135:	52                   	push   %edx
8010a136:	50                   	push   %eax
8010a137:	68 6c ce 10 80       	push   $0x8010ce6c
8010a13c:	e8 cb 62 ff ff       	call   8010040c <cprintf>
8010a141:	83 c4 20             	add    $0x20,%esp
}
8010a144:	90                   	nop
8010a145:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a148:	c9                   	leave  
8010a149:	c3                   	ret    

8010a14a <print_mac>:

void print_mac(uchar *mac){
8010a14a:	f3 0f 1e fb          	endbr32 
8010a14e:	55                   	push   %ebp
8010a14f:	89 e5                	mov    %esp,%ebp
8010a151:	57                   	push   %edi
8010a152:	56                   	push   %esi
8010a153:	53                   	push   %ebx
8010a154:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010a157:	8b 45 08             	mov    0x8(%ebp),%eax
8010a15a:	83 c0 05             	add    $0x5,%eax
8010a15d:	0f b6 00             	movzbl (%eax),%eax
8010a160:	0f b6 f8             	movzbl %al,%edi
8010a163:	8b 45 08             	mov    0x8(%ebp),%eax
8010a166:	83 c0 04             	add    $0x4,%eax
8010a169:	0f b6 00             	movzbl (%eax),%eax
8010a16c:	0f b6 f0             	movzbl %al,%esi
8010a16f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a172:	83 c0 03             	add    $0x3,%eax
8010a175:	0f b6 00             	movzbl (%eax),%eax
8010a178:	0f b6 d8             	movzbl %al,%ebx
8010a17b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a17e:	83 c0 02             	add    $0x2,%eax
8010a181:	0f b6 00             	movzbl (%eax),%eax
8010a184:	0f b6 c8             	movzbl %al,%ecx
8010a187:	8b 45 08             	mov    0x8(%ebp),%eax
8010a18a:	83 c0 01             	add    $0x1,%eax
8010a18d:	0f b6 00             	movzbl (%eax),%eax
8010a190:	0f b6 d0             	movzbl %al,%edx
8010a193:	8b 45 08             	mov    0x8(%ebp),%eax
8010a196:	0f b6 00             	movzbl (%eax),%eax
8010a199:	0f b6 c0             	movzbl %al,%eax
8010a19c:	83 ec 04             	sub    $0x4,%esp
8010a19f:	57                   	push   %edi
8010a1a0:	56                   	push   %esi
8010a1a1:	53                   	push   %ebx
8010a1a2:	51                   	push   %ecx
8010a1a3:	52                   	push   %edx
8010a1a4:	50                   	push   %eax
8010a1a5:	68 84 ce 10 80       	push   $0x8010ce84
8010a1aa:	e8 5d 62 ff ff       	call   8010040c <cprintf>
8010a1af:	83 c4 20             	add    $0x20,%esp
}
8010a1b2:	90                   	nop
8010a1b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010a1b6:	5b                   	pop    %ebx
8010a1b7:	5e                   	pop    %esi
8010a1b8:	5f                   	pop    %edi
8010a1b9:	5d                   	pop    %ebp
8010a1ba:	c3                   	ret    

8010a1bb <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010a1bb:	f3 0f 1e fb          	endbr32 
8010a1bf:	55                   	push   %ebp
8010a1c0:	89 e5                	mov    %esp,%ebp
8010a1c2:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010a1c5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010a1cb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1ce:	83 c0 0e             	add    $0xe,%eax
8010a1d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010a1d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1d7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a1db:	3c 08                	cmp    $0x8,%al
8010a1dd:	75 1b                	jne    8010a1fa <eth_proc+0x3f>
8010a1df:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1e2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a1e6:	3c 06                	cmp    $0x6,%al
8010a1e8:	75 10                	jne    8010a1fa <eth_proc+0x3f>
    arp_proc(pkt_addr);
8010a1ea:	83 ec 0c             	sub    $0xc,%esp
8010a1ed:	ff 75 f0             	pushl  -0x10(%ebp)
8010a1f0:	e8 d5 f7 ff ff       	call   801099ca <arp_proc>
8010a1f5:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010a1f8:	eb 24                	jmp    8010a21e <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010a1fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a1fd:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a201:	3c 08                	cmp    $0x8,%al
8010a203:	75 19                	jne    8010a21e <eth_proc+0x63>
8010a205:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a208:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a20c:	84 c0                	test   %al,%al
8010a20e:	75 0e                	jne    8010a21e <eth_proc+0x63>
    ipv4_proc(buffer_addr);
8010a210:	83 ec 0c             	sub    $0xc,%esp
8010a213:	ff 75 08             	pushl  0x8(%ebp)
8010a216:	e8 b3 00 00 00       	call   8010a2ce <ipv4_proc>
8010a21b:	83 c4 10             	add    $0x10,%esp
}
8010a21e:	90                   	nop
8010a21f:	c9                   	leave  
8010a220:	c3                   	ret    

8010a221 <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010a221:	f3 0f 1e fb          	endbr32 
8010a225:	55                   	push   %ebp
8010a226:	89 e5                	mov    %esp,%ebp
8010a228:	83 ec 04             	sub    $0x4,%esp
8010a22b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a22e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a232:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a236:	c1 e0 08             	shl    $0x8,%eax
8010a239:	89 c2                	mov    %eax,%edx
8010a23b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a23f:	66 c1 e8 08          	shr    $0x8,%ax
8010a243:	01 d0                	add    %edx,%eax
}
8010a245:	c9                   	leave  
8010a246:	c3                   	ret    

8010a247 <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010a247:	f3 0f 1e fb          	endbr32 
8010a24b:	55                   	push   %ebp
8010a24c:	89 e5                	mov    %esp,%ebp
8010a24e:	83 ec 04             	sub    $0x4,%esp
8010a251:	8b 45 08             	mov    0x8(%ebp),%eax
8010a254:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a258:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a25c:	c1 e0 08             	shl    $0x8,%eax
8010a25f:	89 c2                	mov    %eax,%edx
8010a261:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a265:	66 c1 e8 08          	shr    $0x8,%ax
8010a269:	01 d0                	add    %edx,%eax
}
8010a26b:	c9                   	leave  
8010a26c:	c3                   	ret    

8010a26d <H2N_uint>:

uint H2N_uint(uint value){
8010a26d:	f3 0f 1e fb          	endbr32 
8010a271:	55                   	push   %ebp
8010a272:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010a274:	8b 45 08             	mov    0x8(%ebp),%eax
8010a277:	c1 e0 18             	shl    $0x18,%eax
8010a27a:	25 00 00 00 0f       	and    $0xf000000,%eax
8010a27f:	89 c2                	mov    %eax,%edx
8010a281:	8b 45 08             	mov    0x8(%ebp),%eax
8010a284:	c1 e0 08             	shl    $0x8,%eax
8010a287:	25 00 f0 00 00       	and    $0xf000,%eax
8010a28c:	09 c2                	or     %eax,%edx
8010a28e:	8b 45 08             	mov    0x8(%ebp),%eax
8010a291:	c1 e8 08             	shr    $0x8,%eax
8010a294:	83 e0 0f             	and    $0xf,%eax
8010a297:	01 d0                	add    %edx,%eax
}
8010a299:	5d                   	pop    %ebp
8010a29a:	c3                   	ret    

8010a29b <N2H_uint>:

uint N2H_uint(uint value){
8010a29b:	f3 0f 1e fb          	endbr32 
8010a29f:	55                   	push   %ebp
8010a2a0:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010a2a2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2a5:	c1 e0 18             	shl    $0x18,%eax
8010a2a8:	89 c2                	mov    %eax,%edx
8010a2aa:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2ad:	c1 e0 08             	shl    $0x8,%eax
8010a2b0:	25 00 00 ff 00       	and    $0xff0000,%eax
8010a2b5:	01 c2                	add    %eax,%edx
8010a2b7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2ba:	c1 e8 08             	shr    $0x8,%eax
8010a2bd:	25 00 ff 00 00       	and    $0xff00,%eax
8010a2c2:	01 c2                	add    %eax,%edx
8010a2c4:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2c7:	c1 e8 18             	shr    $0x18,%eax
8010a2ca:	01 d0                	add    %edx,%eax
}
8010a2cc:	5d                   	pop    %ebp
8010a2cd:	c3                   	ret    

8010a2ce <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a2ce:	f3 0f 1e fb          	endbr32 
8010a2d2:	55                   	push   %ebp
8010a2d3:	89 e5                	mov    %esp,%ebp
8010a2d5:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a2d8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2db:	83 c0 0e             	add    $0xe,%eax
8010a2de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a2e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2e4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a2e8:	0f b7 d0             	movzwl %ax,%edx
8010a2eb:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
8010a2f0:	39 c2                	cmp    %eax,%edx
8010a2f2:	74 60                	je     8010a354 <ipv4_proc+0x86>
8010a2f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2f7:	83 c0 0c             	add    $0xc,%eax
8010a2fa:	83 ec 04             	sub    $0x4,%esp
8010a2fd:	6a 04                	push   $0x4
8010a2ff:	50                   	push   %eax
8010a300:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a305:	e8 c0 b1 ff ff       	call   801054ca <memcmp>
8010a30a:	83 c4 10             	add    $0x10,%esp
8010a30d:	85 c0                	test   %eax,%eax
8010a30f:	74 43                	je     8010a354 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
8010a311:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a314:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a318:	0f b7 c0             	movzwl %ax,%eax
8010a31b:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a320:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a323:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a327:	3c 01                	cmp    $0x1,%al
8010a329:	75 10                	jne    8010a33b <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
8010a32b:	83 ec 0c             	sub    $0xc,%esp
8010a32e:	ff 75 08             	pushl  0x8(%ebp)
8010a331:	e8 a7 00 00 00       	call   8010a3dd <icmp_proc>
8010a336:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a339:	eb 19                	jmp    8010a354 <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a33b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a33e:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a342:	3c 06                	cmp    $0x6,%al
8010a344:	75 0e                	jne    8010a354 <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
8010a346:	83 ec 0c             	sub    $0xc,%esp
8010a349:	ff 75 08             	pushl  0x8(%ebp)
8010a34c:	e8 c7 03 00 00       	call   8010a718 <tcp_proc>
8010a351:	83 c4 10             	add    $0x10,%esp
}
8010a354:	90                   	nop
8010a355:	c9                   	leave  
8010a356:	c3                   	ret    

8010a357 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a357:	f3 0f 1e fb          	endbr32 
8010a35b:	55                   	push   %ebp
8010a35c:	89 e5                	mov    %esp,%ebp
8010a35e:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a361:	8b 45 08             	mov    0x8(%ebp),%eax
8010a364:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a36a:	0f b6 00             	movzbl (%eax),%eax
8010a36d:	83 e0 0f             	and    $0xf,%eax
8010a370:	01 c0                	add    %eax,%eax
8010a372:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a375:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a37c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a383:	eb 48                	jmp    8010a3cd <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a385:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a388:	01 c0                	add    %eax,%eax
8010a38a:	89 c2                	mov    %eax,%edx
8010a38c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a38f:	01 d0                	add    %edx,%eax
8010a391:	0f b6 00             	movzbl (%eax),%eax
8010a394:	0f b6 c0             	movzbl %al,%eax
8010a397:	c1 e0 08             	shl    $0x8,%eax
8010a39a:	89 c2                	mov    %eax,%edx
8010a39c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a39f:	01 c0                	add    %eax,%eax
8010a3a1:	8d 48 01             	lea    0x1(%eax),%ecx
8010a3a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3a7:	01 c8                	add    %ecx,%eax
8010a3a9:	0f b6 00             	movzbl (%eax),%eax
8010a3ac:	0f b6 c0             	movzbl %al,%eax
8010a3af:	01 d0                	add    %edx,%eax
8010a3b1:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a3b4:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a3bb:	76 0c                	jbe    8010a3c9 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a3bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a3c0:	0f b7 c0             	movzwl %ax,%eax
8010a3c3:	83 c0 01             	add    $0x1,%eax
8010a3c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a3c9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a3cd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a3d1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a3d4:	7c af                	jl     8010a385 <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
8010a3d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a3d9:	f7 d0                	not    %eax
}
8010a3db:	c9                   	leave  
8010a3dc:	c3                   	ret    

8010a3dd <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a3dd:	f3 0f 1e fb          	endbr32 
8010a3e1:	55                   	push   %ebp
8010a3e2:	89 e5                	mov    %esp,%ebp
8010a3e4:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a3e7:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3ea:	83 c0 0e             	add    $0xe,%eax
8010a3ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a3f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3f3:	0f b6 00             	movzbl (%eax),%eax
8010a3f6:	0f b6 c0             	movzbl %al,%eax
8010a3f9:	83 e0 0f             	and    $0xf,%eax
8010a3fc:	c1 e0 02             	shl    $0x2,%eax
8010a3ff:	89 c2                	mov    %eax,%edx
8010a401:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a404:	01 d0                	add    %edx,%eax
8010a406:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a409:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a40c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a410:	84 c0                	test   %al,%al
8010a412:	75 4f                	jne    8010a463 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a414:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a417:	0f b6 00             	movzbl (%eax),%eax
8010a41a:	3c 08                	cmp    $0x8,%al
8010a41c:	75 45                	jne    8010a463 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
8010a41e:	e8 55 89 ff ff       	call   80102d78 <kalloc>
8010a423:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a426:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a42d:	83 ec 04             	sub    $0x4,%esp
8010a430:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a433:	50                   	push   %eax
8010a434:	ff 75 ec             	pushl  -0x14(%ebp)
8010a437:	ff 75 08             	pushl  0x8(%ebp)
8010a43a:	e8 7c 00 00 00       	call   8010a4bb <icmp_reply_pkt_create>
8010a43f:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a442:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a445:	83 ec 08             	sub    $0x8,%esp
8010a448:	50                   	push   %eax
8010a449:	ff 75 ec             	pushl  -0x14(%ebp)
8010a44c:	e8 43 f4 ff ff       	call   80109894 <i8254_send>
8010a451:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a454:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a457:	83 ec 0c             	sub    $0xc,%esp
8010a45a:	50                   	push   %eax
8010a45b:	e8 7a 88 ff ff       	call   80102cda <kfree>
8010a460:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a463:	90                   	nop
8010a464:	c9                   	leave  
8010a465:	c3                   	ret    

8010a466 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a466:	f3 0f 1e fb          	endbr32 
8010a46a:	55                   	push   %ebp
8010a46b:	89 e5                	mov    %esp,%ebp
8010a46d:	53                   	push   %ebx
8010a46e:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a471:	8b 45 08             	mov    0x8(%ebp),%eax
8010a474:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a478:	0f b7 c0             	movzwl %ax,%eax
8010a47b:	83 ec 0c             	sub    $0xc,%esp
8010a47e:	50                   	push   %eax
8010a47f:	e8 9d fd ff ff       	call   8010a221 <N2H_ushort>
8010a484:	83 c4 10             	add    $0x10,%esp
8010a487:	0f b7 d8             	movzwl %ax,%ebx
8010a48a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a48d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a491:	0f b7 c0             	movzwl %ax,%eax
8010a494:	83 ec 0c             	sub    $0xc,%esp
8010a497:	50                   	push   %eax
8010a498:	e8 84 fd ff ff       	call   8010a221 <N2H_ushort>
8010a49d:	83 c4 10             	add    $0x10,%esp
8010a4a0:	0f b7 c0             	movzwl %ax,%eax
8010a4a3:	83 ec 04             	sub    $0x4,%esp
8010a4a6:	53                   	push   %ebx
8010a4a7:	50                   	push   %eax
8010a4a8:	68 a3 ce 10 80       	push   $0x8010cea3
8010a4ad:	e8 5a 5f ff ff       	call   8010040c <cprintf>
8010a4b2:	83 c4 10             	add    $0x10,%esp
}
8010a4b5:	90                   	nop
8010a4b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a4b9:	c9                   	leave  
8010a4ba:	c3                   	ret    

8010a4bb <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a4bb:	f3 0f 1e fb          	endbr32 
8010a4bf:	55                   	push   %ebp
8010a4c0:	89 e5                	mov    %esp,%ebp
8010a4c2:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a4c5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a4cb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4ce:	83 c0 0e             	add    $0xe,%eax
8010a4d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a4d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4d7:	0f b6 00             	movzbl (%eax),%eax
8010a4da:	0f b6 c0             	movzbl %al,%eax
8010a4dd:	83 e0 0f             	and    $0xf,%eax
8010a4e0:	c1 e0 02             	shl    $0x2,%eax
8010a4e3:	89 c2                	mov    %eax,%edx
8010a4e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4e8:	01 d0                	add    %edx,%eax
8010a4ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a4ed:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a4f3:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a4f6:	83 c0 0e             	add    $0xe,%eax
8010a4f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a4fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4ff:	83 c0 14             	add    $0x14,%eax
8010a502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a505:	8b 45 10             	mov    0x10(%ebp),%eax
8010a508:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a50e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a511:	8d 50 06             	lea    0x6(%eax),%edx
8010a514:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a517:	83 ec 04             	sub    $0x4,%esp
8010a51a:	6a 06                	push   $0x6
8010a51c:	52                   	push   %edx
8010a51d:	50                   	push   %eax
8010a51e:	e8 03 b0 ff ff       	call   80105526 <memmove>
8010a523:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a526:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a529:	83 c0 06             	add    $0x6,%eax
8010a52c:	83 ec 04             	sub    $0x4,%esp
8010a52f:	6a 06                	push   $0x6
8010a531:	68 ac 00 11 80       	push   $0x801100ac
8010a536:	50                   	push   %eax
8010a537:	e8 ea af ff ff       	call   80105526 <memmove>
8010a53c:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a53f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a542:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a546:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a549:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a54d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a550:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a553:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a556:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a55a:	83 ec 0c             	sub    $0xc,%esp
8010a55d:	6a 54                	push   $0x54
8010a55f:	e8 e3 fc ff ff       	call   8010a247 <H2N_ushort>
8010a564:	83 c4 10             	add    $0x10,%esp
8010a567:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a56a:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a56e:	0f b7 15 80 03 11 80 	movzwl 0x80110380,%edx
8010a575:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a578:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a57c:	0f b7 05 80 03 11 80 	movzwl 0x80110380,%eax
8010a583:	83 c0 01             	add    $0x1,%eax
8010a586:	66 a3 80 03 11 80    	mov    %ax,0x80110380
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a58c:	83 ec 0c             	sub    $0xc,%esp
8010a58f:	68 00 40 00 00       	push   $0x4000
8010a594:	e8 ae fc ff ff       	call   8010a247 <H2N_ushort>
8010a599:	83 c4 10             	add    $0x10,%esp
8010a59c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a59f:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a5a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5a6:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a5aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5ad:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a5b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5b4:	83 c0 0c             	add    $0xc,%eax
8010a5b7:	83 ec 04             	sub    $0x4,%esp
8010a5ba:	6a 04                	push   $0x4
8010a5bc:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a5c1:	50                   	push   %eax
8010a5c2:	e8 5f af ff ff       	call   80105526 <memmove>
8010a5c7:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a5ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a5cd:	8d 50 0c             	lea    0xc(%eax),%edx
8010a5d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5d3:	83 c0 10             	add    $0x10,%eax
8010a5d6:	83 ec 04             	sub    $0x4,%esp
8010a5d9:	6a 04                	push   $0x4
8010a5db:	52                   	push   %edx
8010a5dc:	50                   	push   %eax
8010a5dd:	e8 44 af ff ff       	call   80105526 <memmove>
8010a5e2:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a5e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5e8:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a5ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a5f1:	83 ec 0c             	sub    $0xc,%esp
8010a5f4:	50                   	push   %eax
8010a5f5:	e8 5d fd ff ff       	call   8010a357 <ipv4_chksum>
8010a5fa:	83 c4 10             	add    $0x10,%esp
8010a5fd:	0f b7 c0             	movzwl %ax,%eax
8010a600:	83 ec 0c             	sub    $0xc,%esp
8010a603:	50                   	push   %eax
8010a604:	e8 3e fc ff ff       	call   8010a247 <H2N_ushort>
8010a609:	83 c4 10             	add    $0x10,%esp
8010a60c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a60f:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a613:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a616:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a619:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a61c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a620:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a623:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a627:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a62a:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a62e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a631:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a635:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a638:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a63c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a63f:	8d 50 08             	lea    0x8(%eax),%edx
8010a642:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a645:	83 c0 08             	add    $0x8,%eax
8010a648:	83 ec 04             	sub    $0x4,%esp
8010a64b:	6a 08                	push   $0x8
8010a64d:	52                   	push   %edx
8010a64e:	50                   	push   %eax
8010a64f:	e8 d2 ae ff ff       	call   80105526 <memmove>
8010a654:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a657:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a65a:	8d 50 10             	lea    0x10(%eax),%edx
8010a65d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a660:	83 c0 10             	add    $0x10,%eax
8010a663:	83 ec 04             	sub    $0x4,%esp
8010a666:	6a 30                	push   $0x30
8010a668:	52                   	push   %edx
8010a669:	50                   	push   %eax
8010a66a:	e8 b7 ae ff ff       	call   80105526 <memmove>
8010a66f:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a672:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a675:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a67b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a67e:	83 ec 0c             	sub    $0xc,%esp
8010a681:	50                   	push   %eax
8010a682:	e8 1c 00 00 00       	call   8010a6a3 <icmp_chksum>
8010a687:	83 c4 10             	add    $0x10,%esp
8010a68a:	0f b7 c0             	movzwl %ax,%eax
8010a68d:	83 ec 0c             	sub    $0xc,%esp
8010a690:	50                   	push   %eax
8010a691:	e8 b1 fb ff ff       	call   8010a247 <H2N_ushort>
8010a696:	83 c4 10             	add    $0x10,%esp
8010a699:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a69c:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a6a0:	90                   	nop
8010a6a1:	c9                   	leave  
8010a6a2:	c3                   	ret    

8010a6a3 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a6a3:	f3 0f 1e fb          	endbr32 
8010a6a7:	55                   	push   %ebp
8010a6a8:	89 e5                	mov    %esp,%ebp
8010a6aa:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a6ad:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a6b3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a6ba:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a6c1:	eb 48                	jmp    8010a70b <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a6c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a6c6:	01 c0                	add    %eax,%eax
8010a6c8:	89 c2                	mov    %eax,%edx
8010a6ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a6cd:	01 d0                	add    %edx,%eax
8010a6cf:	0f b6 00             	movzbl (%eax),%eax
8010a6d2:	0f b6 c0             	movzbl %al,%eax
8010a6d5:	c1 e0 08             	shl    $0x8,%eax
8010a6d8:	89 c2                	mov    %eax,%edx
8010a6da:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a6dd:	01 c0                	add    %eax,%eax
8010a6df:	8d 48 01             	lea    0x1(%eax),%ecx
8010a6e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a6e5:	01 c8                	add    %ecx,%eax
8010a6e7:	0f b6 00             	movzbl (%eax),%eax
8010a6ea:	0f b6 c0             	movzbl %al,%eax
8010a6ed:	01 d0                	add    %edx,%eax
8010a6ef:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a6f2:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a6f9:	76 0c                	jbe    8010a707 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a6fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a6fe:	0f b7 c0             	movzwl %ax,%eax
8010a701:	83 c0 01             	add    $0x1,%eax
8010a704:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a707:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a70b:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a70f:	7e b2                	jle    8010a6c3 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a711:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a714:	f7 d0                	not    %eax
}
8010a716:	c9                   	leave  
8010a717:	c3                   	ret    

8010a718 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a718:	f3 0f 1e fb          	endbr32 
8010a71c:	55                   	push   %ebp
8010a71d:	89 e5                	mov    %esp,%ebp
8010a71f:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a722:	8b 45 08             	mov    0x8(%ebp),%eax
8010a725:	83 c0 0e             	add    $0xe,%eax
8010a728:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a72b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a72e:	0f b6 00             	movzbl (%eax),%eax
8010a731:	0f b6 c0             	movzbl %al,%eax
8010a734:	83 e0 0f             	and    $0xf,%eax
8010a737:	c1 e0 02             	shl    $0x2,%eax
8010a73a:	89 c2                	mov    %eax,%edx
8010a73c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a73f:	01 d0                	add    %edx,%eax
8010a741:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a744:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a747:	83 c0 14             	add    $0x14,%eax
8010a74a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a74d:	e8 26 86 ff ff       	call   80102d78 <kalloc>
8010a752:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a755:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a75c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a75f:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a763:	0f b6 c0             	movzbl %al,%eax
8010a766:	83 e0 02             	and    $0x2,%eax
8010a769:	85 c0                	test   %eax,%eax
8010a76b:	74 3d                	je     8010a7aa <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a76d:	83 ec 0c             	sub    $0xc,%esp
8010a770:	6a 00                	push   $0x0
8010a772:	6a 12                	push   $0x12
8010a774:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a777:	50                   	push   %eax
8010a778:	ff 75 e8             	pushl  -0x18(%ebp)
8010a77b:	ff 75 08             	pushl  0x8(%ebp)
8010a77e:	e8 a2 01 00 00       	call   8010a925 <tcp_pkt_create>
8010a783:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a786:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a789:	83 ec 08             	sub    $0x8,%esp
8010a78c:	50                   	push   %eax
8010a78d:	ff 75 e8             	pushl  -0x18(%ebp)
8010a790:	e8 ff f0 ff ff       	call   80109894 <i8254_send>
8010a795:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a798:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a79d:	83 c0 01             	add    $0x1,%eax
8010a7a0:	a3 84 03 11 80       	mov    %eax,0x80110384
8010a7a5:	e9 69 01 00 00       	jmp    8010a913 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a7aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7ad:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a7b1:	3c 18                	cmp    $0x18,%al
8010a7b3:	0f 85 10 01 00 00    	jne    8010a8c9 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a7b9:	83 ec 04             	sub    $0x4,%esp
8010a7bc:	6a 03                	push   $0x3
8010a7be:	68 be ce 10 80       	push   $0x8010cebe
8010a7c3:	ff 75 ec             	pushl  -0x14(%ebp)
8010a7c6:	e8 ff ac ff ff       	call   801054ca <memcmp>
8010a7cb:	83 c4 10             	add    $0x10,%esp
8010a7ce:	85 c0                	test   %eax,%eax
8010a7d0:	74 74                	je     8010a846 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a7d2:	83 ec 0c             	sub    $0xc,%esp
8010a7d5:	68 c2 ce 10 80       	push   $0x8010cec2
8010a7da:	e8 2d 5c ff ff       	call   8010040c <cprintf>
8010a7df:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a7e2:	83 ec 0c             	sub    $0xc,%esp
8010a7e5:	6a 00                	push   $0x0
8010a7e7:	6a 10                	push   $0x10
8010a7e9:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a7ec:	50                   	push   %eax
8010a7ed:	ff 75 e8             	pushl  -0x18(%ebp)
8010a7f0:	ff 75 08             	pushl  0x8(%ebp)
8010a7f3:	e8 2d 01 00 00       	call   8010a925 <tcp_pkt_create>
8010a7f8:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a7fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a7fe:	83 ec 08             	sub    $0x8,%esp
8010a801:	50                   	push   %eax
8010a802:	ff 75 e8             	pushl  -0x18(%ebp)
8010a805:	e8 8a f0 ff ff       	call   80109894 <i8254_send>
8010a80a:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a80d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a810:	83 c0 36             	add    $0x36,%eax
8010a813:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a816:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a819:	50                   	push   %eax
8010a81a:	ff 75 e0             	pushl  -0x20(%ebp)
8010a81d:	6a 00                	push   $0x0
8010a81f:	6a 00                	push   $0x0
8010a821:	e8 66 04 00 00       	call   8010ac8c <http_proc>
8010a826:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a829:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a82c:	83 ec 0c             	sub    $0xc,%esp
8010a82f:	50                   	push   %eax
8010a830:	6a 18                	push   $0x18
8010a832:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a835:	50                   	push   %eax
8010a836:	ff 75 e8             	pushl  -0x18(%ebp)
8010a839:	ff 75 08             	pushl  0x8(%ebp)
8010a83c:	e8 e4 00 00 00       	call   8010a925 <tcp_pkt_create>
8010a841:	83 c4 20             	add    $0x20,%esp
8010a844:	eb 62                	jmp    8010a8a8 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a846:	83 ec 0c             	sub    $0xc,%esp
8010a849:	6a 00                	push   $0x0
8010a84b:	6a 10                	push   $0x10
8010a84d:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a850:	50                   	push   %eax
8010a851:	ff 75 e8             	pushl  -0x18(%ebp)
8010a854:	ff 75 08             	pushl  0x8(%ebp)
8010a857:	e8 c9 00 00 00       	call   8010a925 <tcp_pkt_create>
8010a85c:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a85f:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a862:	83 ec 08             	sub    $0x8,%esp
8010a865:	50                   	push   %eax
8010a866:	ff 75 e8             	pushl  -0x18(%ebp)
8010a869:	e8 26 f0 ff ff       	call   80109894 <i8254_send>
8010a86e:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a871:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a874:	83 c0 36             	add    $0x36,%eax
8010a877:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a87a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a87d:	50                   	push   %eax
8010a87e:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a881:	6a 00                	push   $0x0
8010a883:	6a 00                	push   $0x0
8010a885:	e8 02 04 00 00       	call   8010ac8c <http_proc>
8010a88a:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a88d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a890:	83 ec 0c             	sub    $0xc,%esp
8010a893:	50                   	push   %eax
8010a894:	6a 18                	push   $0x18
8010a896:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a899:	50                   	push   %eax
8010a89a:	ff 75 e8             	pushl  -0x18(%ebp)
8010a89d:	ff 75 08             	pushl  0x8(%ebp)
8010a8a0:	e8 80 00 00 00       	call   8010a925 <tcp_pkt_create>
8010a8a5:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a8a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a8ab:	83 ec 08             	sub    $0x8,%esp
8010a8ae:	50                   	push   %eax
8010a8af:	ff 75 e8             	pushl  -0x18(%ebp)
8010a8b2:	e8 dd ef ff ff       	call   80109894 <i8254_send>
8010a8b7:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a8ba:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a8bf:	83 c0 01             	add    $0x1,%eax
8010a8c2:	a3 84 03 11 80       	mov    %eax,0x80110384
8010a8c7:	eb 4a                	jmp    8010a913 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a8c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a8cc:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a8d0:	3c 10                	cmp    $0x10,%al
8010a8d2:	75 3f                	jne    8010a913 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a8d4:	a1 88 03 11 80       	mov    0x80110388,%eax
8010a8d9:	83 f8 01             	cmp    $0x1,%eax
8010a8dc:	75 35                	jne    8010a913 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a8de:	83 ec 0c             	sub    $0xc,%esp
8010a8e1:	6a 00                	push   $0x0
8010a8e3:	6a 01                	push   $0x1
8010a8e5:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a8e8:	50                   	push   %eax
8010a8e9:	ff 75 e8             	pushl  -0x18(%ebp)
8010a8ec:	ff 75 08             	pushl  0x8(%ebp)
8010a8ef:	e8 31 00 00 00       	call   8010a925 <tcp_pkt_create>
8010a8f4:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a8f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a8fa:	83 ec 08             	sub    $0x8,%esp
8010a8fd:	50                   	push   %eax
8010a8fe:	ff 75 e8             	pushl  -0x18(%ebp)
8010a901:	e8 8e ef ff ff       	call   80109894 <i8254_send>
8010a906:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a909:	c7 05 88 03 11 80 00 	movl   $0x0,0x80110388
8010a910:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a913:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a916:	83 ec 0c             	sub    $0xc,%esp
8010a919:	50                   	push   %eax
8010a91a:	e8 bb 83 ff ff       	call   80102cda <kfree>
8010a91f:	83 c4 10             	add    $0x10,%esp
}
8010a922:	90                   	nop
8010a923:	c9                   	leave  
8010a924:	c3                   	ret    

8010a925 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a925:	f3 0f 1e fb          	endbr32 
8010a929:	55                   	push   %ebp
8010a92a:	89 e5                	mov    %esp,%ebp
8010a92c:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a92f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a932:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a935:	8b 45 08             	mov    0x8(%ebp),%eax
8010a938:	83 c0 0e             	add    $0xe,%eax
8010a93b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a93e:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a941:	0f b6 00             	movzbl (%eax),%eax
8010a944:	0f b6 c0             	movzbl %al,%eax
8010a947:	83 e0 0f             	and    $0xf,%eax
8010a94a:	c1 e0 02             	shl    $0x2,%eax
8010a94d:	89 c2                	mov    %eax,%edx
8010a94f:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a952:	01 d0                	add    %edx,%eax
8010a954:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a957:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a95a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a95d:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a960:	83 c0 0e             	add    $0xe,%eax
8010a963:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a966:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a969:	83 c0 14             	add    $0x14,%eax
8010a96c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a96f:	8b 45 18             	mov    0x18(%ebp),%eax
8010a972:	8d 50 36             	lea    0x36(%eax),%edx
8010a975:	8b 45 10             	mov    0x10(%ebp),%eax
8010a978:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a97a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a97d:	8d 50 06             	lea    0x6(%eax),%edx
8010a980:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a983:	83 ec 04             	sub    $0x4,%esp
8010a986:	6a 06                	push   $0x6
8010a988:	52                   	push   %edx
8010a989:	50                   	push   %eax
8010a98a:	e8 97 ab ff ff       	call   80105526 <memmove>
8010a98f:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a992:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a995:	83 c0 06             	add    $0x6,%eax
8010a998:	83 ec 04             	sub    $0x4,%esp
8010a99b:	6a 06                	push   $0x6
8010a99d:	68 ac 00 11 80       	push   $0x801100ac
8010a9a2:	50                   	push   %eax
8010a9a3:	e8 7e ab ff ff       	call   80105526 <memmove>
8010a9a8:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a9ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a9ae:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a9b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a9b5:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a9b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a9bc:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a9bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a9c2:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a9c6:	8b 45 18             	mov    0x18(%ebp),%eax
8010a9c9:	83 c0 28             	add    $0x28,%eax
8010a9cc:	0f b7 c0             	movzwl %ax,%eax
8010a9cf:	83 ec 0c             	sub    $0xc,%esp
8010a9d2:	50                   	push   %eax
8010a9d3:	e8 6f f8 ff ff       	call   8010a247 <H2N_ushort>
8010a9d8:	83 c4 10             	add    $0x10,%esp
8010a9db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a9de:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a9e2:	0f b7 15 80 03 11 80 	movzwl 0x80110380,%edx
8010a9e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a9ec:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a9f0:	0f b7 05 80 03 11 80 	movzwl 0x80110380,%eax
8010a9f7:	83 c0 01             	add    $0x1,%eax
8010a9fa:	66 a3 80 03 11 80    	mov    %ax,0x80110380
  ipv4_send->fragment = H2N_ushort(0x0000);
8010aa00:	83 ec 0c             	sub    $0xc,%esp
8010aa03:	6a 00                	push   $0x0
8010aa05:	e8 3d f8 ff ff       	call   8010a247 <H2N_ushort>
8010aa0a:	83 c4 10             	add    $0x10,%esp
8010aa0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010aa10:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010aa14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa17:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010aa1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa1e:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010aa22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa25:	83 c0 0c             	add    $0xc,%eax
8010aa28:	83 ec 04             	sub    $0x4,%esp
8010aa2b:	6a 04                	push   $0x4
8010aa2d:	68 e4 f4 10 80       	push   $0x8010f4e4
8010aa32:	50                   	push   %eax
8010aa33:	e8 ee aa ff ff       	call   80105526 <memmove>
8010aa38:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010aa3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa3e:	8d 50 0c             	lea    0xc(%eax),%edx
8010aa41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa44:	83 c0 10             	add    $0x10,%eax
8010aa47:	83 ec 04             	sub    $0x4,%esp
8010aa4a:	6a 04                	push   $0x4
8010aa4c:	52                   	push   %edx
8010aa4d:	50                   	push   %eax
8010aa4e:	e8 d3 aa ff ff       	call   80105526 <memmove>
8010aa53:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010aa56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa59:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010aa5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa62:	83 ec 0c             	sub    $0xc,%esp
8010aa65:	50                   	push   %eax
8010aa66:	e8 ec f8 ff ff       	call   8010a357 <ipv4_chksum>
8010aa6b:	83 c4 10             	add    $0x10,%esp
8010aa6e:	0f b7 c0             	movzwl %ax,%eax
8010aa71:	83 ec 0c             	sub    $0xc,%esp
8010aa74:	50                   	push   %eax
8010aa75:	e8 cd f7 ff ff       	call   8010a247 <H2N_ushort>
8010aa7a:	83 c4 10             	add    $0x10,%esp
8010aa7d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010aa80:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010aa84:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010aa87:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010aa8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aa8e:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010aa91:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010aa94:	0f b7 10             	movzwl (%eax),%edx
8010aa97:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aa9a:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010aa9e:	a1 84 03 11 80       	mov    0x80110384,%eax
8010aaa3:	83 ec 0c             	sub    $0xc,%esp
8010aaa6:	50                   	push   %eax
8010aaa7:	e8 c1 f7 ff ff       	call   8010a26d <H2N_uint>
8010aaac:	83 c4 10             	add    $0x10,%esp
8010aaaf:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010aab2:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010aab5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010aab8:	8b 40 04             	mov    0x4(%eax),%eax
8010aabb:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010aac1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aac4:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010aac7:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aaca:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010aace:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aad1:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010aad5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aad8:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010aadc:	8b 45 14             	mov    0x14(%ebp),%eax
8010aadf:	89 c2                	mov    %eax,%edx
8010aae1:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aae4:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010aae7:	83 ec 0c             	sub    $0xc,%esp
8010aaea:	68 90 38 00 00       	push   $0x3890
8010aaef:	e8 53 f7 ff ff       	call   8010a247 <H2N_ushort>
8010aaf4:	83 c4 10             	add    $0x10,%esp
8010aaf7:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010aafa:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010aafe:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab01:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010ab07:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab0a:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010ab10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab13:	83 ec 0c             	sub    $0xc,%esp
8010ab16:	50                   	push   %eax
8010ab17:	e8 1f 00 00 00       	call   8010ab3b <tcp_chksum>
8010ab1c:	83 c4 10             	add    $0x10,%esp
8010ab1f:	83 c0 08             	add    $0x8,%eax
8010ab22:	0f b7 c0             	movzwl %ax,%eax
8010ab25:	83 ec 0c             	sub    $0xc,%esp
8010ab28:	50                   	push   %eax
8010ab29:	e8 19 f7 ff ff       	call   8010a247 <H2N_ushort>
8010ab2e:	83 c4 10             	add    $0x10,%esp
8010ab31:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010ab34:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010ab38:	90                   	nop
8010ab39:	c9                   	leave  
8010ab3a:	c3                   	ret    

8010ab3b <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010ab3b:	f3 0f 1e fb          	endbr32 
8010ab3f:	55                   	push   %ebp
8010ab40:	89 e5                	mov    %esp,%ebp
8010ab42:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010ab45:	8b 45 08             	mov    0x8(%ebp),%eax
8010ab48:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010ab4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010ab4e:	83 c0 14             	add    $0x14,%eax
8010ab51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010ab54:	83 ec 04             	sub    $0x4,%esp
8010ab57:	6a 04                	push   $0x4
8010ab59:	68 e4 f4 10 80       	push   $0x8010f4e4
8010ab5e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ab61:	50                   	push   %eax
8010ab62:	e8 bf a9 ff ff       	call   80105526 <memmove>
8010ab67:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010ab6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010ab6d:	83 c0 0c             	add    $0xc,%eax
8010ab70:	83 ec 04             	sub    $0x4,%esp
8010ab73:	6a 04                	push   $0x4
8010ab75:	50                   	push   %eax
8010ab76:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ab79:	83 c0 04             	add    $0x4,%eax
8010ab7c:	50                   	push   %eax
8010ab7d:	e8 a4 a9 ff ff       	call   80105526 <memmove>
8010ab82:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010ab85:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010ab89:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010ab8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010ab90:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010ab94:	0f b7 c0             	movzwl %ax,%eax
8010ab97:	83 ec 0c             	sub    $0xc,%esp
8010ab9a:	50                   	push   %eax
8010ab9b:	e8 81 f6 ff ff       	call   8010a221 <N2H_ushort>
8010aba0:	83 c4 10             	add    $0x10,%esp
8010aba3:	83 e8 14             	sub    $0x14,%eax
8010aba6:	0f b7 c0             	movzwl %ax,%eax
8010aba9:	83 ec 0c             	sub    $0xc,%esp
8010abac:	50                   	push   %eax
8010abad:	e8 95 f6 ff ff       	call   8010a247 <H2N_ushort>
8010abb2:	83 c4 10             	add    $0x10,%esp
8010abb5:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010abb9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010abc0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010abc3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010abc6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010abcd:	eb 33                	jmp    8010ac02 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010abcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010abd2:	01 c0                	add    %eax,%eax
8010abd4:	89 c2                	mov    %eax,%edx
8010abd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abd9:	01 d0                	add    %edx,%eax
8010abdb:	0f b6 00             	movzbl (%eax),%eax
8010abde:	0f b6 c0             	movzbl %al,%eax
8010abe1:	c1 e0 08             	shl    $0x8,%eax
8010abe4:	89 c2                	mov    %eax,%edx
8010abe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010abe9:	01 c0                	add    %eax,%eax
8010abeb:	8d 48 01             	lea    0x1(%eax),%ecx
8010abee:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010abf1:	01 c8                	add    %ecx,%eax
8010abf3:	0f b6 00             	movzbl (%eax),%eax
8010abf6:	0f b6 c0             	movzbl %al,%eax
8010abf9:	01 d0                	add    %edx,%eax
8010abfb:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010abfe:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010ac02:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010ac06:	7e c7                	jle    8010abcf <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010ac08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ac0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ac0e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010ac15:	eb 33                	jmp    8010ac4a <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010ac17:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ac1a:	01 c0                	add    %eax,%eax
8010ac1c:	89 c2                	mov    %eax,%edx
8010ac1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac21:	01 d0                	add    %edx,%eax
8010ac23:	0f b6 00             	movzbl (%eax),%eax
8010ac26:	0f b6 c0             	movzbl %al,%eax
8010ac29:	c1 e0 08             	shl    $0x8,%eax
8010ac2c:	89 c2                	mov    %eax,%edx
8010ac2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ac31:	01 c0                	add    %eax,%eax
8010ac33:	8d 48 01             	lea    0x1(%eax),%ecx
8010ac36:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ac39:	01 c8                	add    %ecx,%eax
8010ac3b:	0f b6 00             	movzbl (%eax),%eax
8010ac3e:	0f b6 c0             	movzbl %al,%eax
8010ac41:	01 d0                	add    %edx,%eax
8010ac43:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ac46:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010ac4a:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010ac4e:	0f b7 c0             	movzwl %ax,%eax
8010ac51:	83 ec 0c             	sub    $0xc,%esp
8010ac54:	50                   	push   %eax
8010ac55:	e8 c7 f5 ff ff       	call   8010a221 <N2H_ushort>
8010ac5a:	83 c4 10             	add    $0x10,%esp
8010ac5d:	66 d1 e8             	shr    %ax
8010ac60:	0f b7 c0             	movzwl %ax,%eax
8010ac63:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010ac66:	7c af                	jl     8010ac17 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010ac68:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ac6b:	c1 e8 10             	shr    $0x10,%eax
8010ac6e:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010ac71:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ac74:	f7 d0                	not    %eax
}
8010ac76:	c9                   	leave  
8010ac77:	c3                   	ret    

8010ac78 <tcp_fin>:

void tcp_fin(){
8010ac78:	f3 0f 1e fb          	endbr32 
8010ac7c:	55                   	push   %ebp
8010ac7d:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010ac7f:	c7 05 88 03 11 80 01 	movl   $0x1,0x80110388
8010ac86:	00 00 00 
}
8010ac89:	90                   	nop
8010ac8a:	5d                   	pop    %ebp
8010ac8b:	c3                   	ret    

8010ac8c <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010ac8c:	f3 0f 1e fb          	endbr32 
8010ac90:	55                   	push   %ebp
8010ac91:	89 e5                	mov    %esp,%ebp
8010ac93:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010ac96:	8b 45 10             	mov    0x10(%ebp),%eax
8010ac99:	83 ec 04             	sub    $0x4,%esp
8010ac9c:	6a 00                	push   $0x0
8010ac9e:	68 cb ce 10 80       	push   $0x8010cecb
8010aca3:	50                   	push   %eax
8010aca4:	e8 65 00 00 00       	call   8010ad0e <http_strcpy>
8010aca9:	83 c4 10             	add    $0x10,%esp
8010acac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010acaf:	8b 45 10             	mov    0x10(%ebp),%eax
8010acb2:	83 ec 04             	sub    $0x4,%esp
8010acb5:	ff 75 f4             	pushl  -0xc(%ebp)
8010acb8:	68 de ce 10 80       	push   $0x8010cede
8010acbd:	50                   	push   %eax
8010acbe:	e8 4b 00 00 00       	call   8010ad0e <http_strcpy>
8010acc3:	83 c4 10             	add    $0x10,%esp
8010acc6:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010acc9:	8b 45 10             	mov    0x10(%ebp),%eax
8010accc:	83 ec 04             	sub    $0x4,%esp
8010accf:	ff 75 f4             	pushl  -0xc(%ebp)
8010acd2:	68 f9 ce 10 80       	push   $0x8010cef9
8010acd7:	50                   	push   %eax
8010acd8:	e8 31 00 00 00       	call   8010ad0e <http_strcpy>
8010acdd:	83 c4 10             	add    $0x10,%esp
8010ace0:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010ace3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ace6:	83 e0 01             	and    $0x1,%eax
8010ace9:	85 c0                	test   %eax,%eax
8010aceb:	74 11                	je     8010acfe <http_proc+0x72>
    char *payload = (char *)send;
8010aced:	8b 45 10             	mov    0x10(%ebp),%eax
8010acf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010acf3:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010acf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010acf9:	01 d0                	add    %edx,%eax
8010acfb:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010acfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010ad01:	8b 45 14             	mov    0x14(%ebp),%eax
8010ad04:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010ad06:	e8 6d ff ff ff       	call   8010ac78 <tcp_fin>
}
8010ad0b:	90                   	nop
8010ad0c:	c9                   	leave  
8010ad0d:	c3                   	ret    

8010ad0e <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010ad0e:	f3 0f 1e fb          	endbr32 
8010ad12:	55                   	push   %ebp
8010ad13:	89 e5                	mov    %esp,%ebp
8010ad15:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010ad18:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010ad1f:	eb 20                	jmp    8010ad41 <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010ad21:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ad24:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ad27:	01 d0                	add    %edx,%eax
8010ad29:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010ad2c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ad2f:	01 ca                	add    %ecx,%edx
8010ad31:	89 d1                	mov    %edx,%ecx
8010ad33:	8b 55 08             	mov    0x8(%ebp),%edx
8010ad36:	01 ca                	add    %ecx,%edx
8010ad38:	0f b6 00             	movzbl (%eax),%eax
8010ad3b:	88 02                	mov    %al,(%edx)
    i++;
8010ad3d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010ad41:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ad44:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ad47:	01 d0                	add    %edx,%eax
8010ad49:	0f b6 00             	movzbl (%eax),%eax
8010ad4c:	84 c0                	test   %al,%al
8010ad4e:	75 d1                	jne    8010ad21 <http_strcpy+0x13>
  }
  return i;
8010ad50:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010ad53:	c9                   	leave  
8010ad54:	c3                   	ret    
