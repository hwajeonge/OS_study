
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
8010005f:	ba 98 39 10 80       	mov    $0x80103998,%edx
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
8010007d:	e8 3e 51 00 00       	call   801051c0 <initlock>
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
801000c7:	e8 87 4f 00 00       	call   80105053 <initsleeplock>
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
80100109:	e8 d8 50 00 00       	call   801051e6 <acquire>
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
80100148:	e8 0b 51 00 00       	call   80105258 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 34 4f 00 00       	call   80105093 <acquiresleep>
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
801001c9:	e8 8a 50 00 00       	call   80105258 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 b3 4e 00 00       	call   80105093 <acquiresleep>
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
80100239:	e8 c1 27 00 00       	call   801029ff <iderw>
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
8010025a:	e8 ee 4e 00 00       	call   8010514d <holdingsleep>
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
80100288:	e8 72 27 00 00       	call   801029ff <iderw>
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
801002a7:	e8 a1 4e 00 00       	call   8010514d <holdingsleep>
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
801002ca:	e8 2c 4e 00 00       	call   801050fb <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 a0 13 11 80       	push   $0x801113a0
801002da:	e8 07 4f 00 00       	call   801051e6 <acquire>
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
8010034a:	e8 09 4f 00 00       	call   80105258 <release>
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
8010042c:	e8 b5 4d 00 00       	call   801051e6 <acquire>
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
801005ba:	e8 99 4c 00 00       	call   80105258 <release>
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
801005de:	e8 06 2b 00 00       	call   801030e9 <lapicid>
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
8010061e:	e8 8b 4c 00 00       	call   801052ae <getcallerpcs>
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
801007bd:	e8 6a 67 00 00       	call   80106f2c <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 5d 67 00 00       	call   80106f2c <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 50 67 00 00       	call   80106f2c <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 40 67 00 00       	call   80106f2c <uartputc>
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
80100819:	e8 c8 49 00 00       	call   801051e6 <acquire>
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
8010096f:	e8 ba 43 00 00       	call   80104d2e <wakeup>
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
80100992:	e8 c1 48 00 00       	call   80105258 <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 4f 44 00 00       	call   80104df4 <procdump>
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
801009c9:	68 20 00 11 80       	push   $0x80110020
801009ce:	e8 13 48 00 00       	call   801051e6 <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 b3 36 00 00       	call   80104093 <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 00 11 80       	push   $0x80110020
801009ef:	e8 64 48 00 00       	call   80105258 <release>
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
80100a12:	68 20 00 11 80       	push   $0x80110020
80100a17:	68 80 5d 11 80       	push   $0x80115d80
80100a1c:	e8 1b 42 00 00       	call   80104c3c <sleep>
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
80100a9a:	e8 b9 47 00 00       	call   80105258 <release>
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
80100ad7:	68 20 00 11 80       	push   $0x80110020
80100adc:	e8 05 47 00 00       	call   801051e6 <acquire>
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
80100b1e:	e8 35 47 00 00       	call   80105258 <release>
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
80100b43:	c7 05 00 00 11 80 00 	movl   $0x0,0x80110000
80100b4a:	00 00 00 
  initlock(&cons.lock, "console");
80100b4d:	83 ec 08             	sub    $0x8,%esp
80100b50:	68 b7 ad 10 80       	push   $0x8010adb7
80100b55:	68 20 00 11 80       	push   $0x80110020
80100b5a:	e8 61 46 00 00       	call   801051c0 <initlock>
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
80100bb3:	e8 3e 20 00 00       	call   80102bf6 <ioapicenable>
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
80100bcb:	e8 c3 34 00 00       	call   80104093 <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

    begin_op();
80100bd3:	e8 83 2a 00 00       	call   8010365b <begin_op>

    if ((ip = namei(path)) == 0) {
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	pushl  0x8(%ebp)
80100bde:	e8 f6 19 00 00       	call   801025d9 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
        end_op();
80100bef:	e8 f7 2a 00 00       	call   801036eb <end_op>
        cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 d5 ad 10 80       	push   $0x8010add5
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
80100c53:	e8 e8 72 00 00       	call   80107f40 <setupkvm>
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
80100cf9:	e8 54 76 00 00       	call   80108352 <allocuvm>
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
80100d3f:	e8 3d 75 00 00       	call   80108281 <loaduvm>
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
80100d80:	e8 66 29 00 00       	call   801036eb <end_op>
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
80100db5:	e8 98 75 00 00       	call   80108352 <allocuvm>
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
80100dfd:	e8 dc 48 00 00       	call   801056de <strlen>
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
80100e2a:	e8 af 48 00 00       	call   801056de <strlen>
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
80100e50:	e8 12 7a 00 00       	call   80108867 <copyout>
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
80100eec:	e8 76 79 00 00       	call   80108867 <copyout>
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
80100f3a:	e8 51 47 00 00       	call   80105690 <safestrcpy>
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
80100f7d:	e8 e8 70 00 00       	call   8010806a <switchuvm>
80100f82:	83 c4 10             	add    $0x10,%esp
    freevm(oldpgdir);
80100f85:	83 ec 0c             	sub    $0xc,%esp
80100f88:	ff 75 cc             	pushl  -0x34(%ebp)
80100f8b:	e8 93 75 00 00       	call   80108523 <freevm>
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
80100fcb:	e8 53 75 00 00       	call   80108523 <freevm>
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
80100fe7:	e8 ff 26 00 00       	call   801036eb <end_op>
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
80101000:	68 e1 ad 10 80       	push   $0x8010ade1
80101005:	68 a0 5d 11 80       	push   $0x80115da0
8010100a:	e8 b1 41 00 00       	call   801051c0 <initlock>
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
80101022:	68 a0 5d 11 80       	push   $0x80115da0
80101027:	e8 ba 41 00 00       	call   801051e6 <acquire>
8010102c:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102f:	c7 45 f4 d4 5d 11 80 	movl   $0x80115dd4,-0xc(%ebp)
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
8010104f:	68 a0 5d 11 80       	push   $0x80115da0
80101054:	e8 ff 41 00 00       	call   80105258 <release>
80101059:	83 c4 10             	add    $0x10,%esp
      return f;
8010105c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010105f:	eb 23                	jmp    80101084 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101061:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101065:	b8 34 67 11 80       	mov    $0x80116734,%eax
8010106a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010106d:	72 c9                	jb     80101038 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010106f:	83 ec 0c             	sub    $0xc,%esp
80101072:	68 a0 5d 11 80       	push   $0x80115da0
80101077:	e8 dc 41 00 00       	call   80105258 <release>
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
80101093:	68 a0 5d 11 80       	push   $0x80115da0
80101098:	e8 49 41 00 00       	call   801051e6 <acquire>
8010109d:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
801010a3:	8b 40 04             	mov    0x4(%eax),%eax
801010a6:	85 c0                	test   %eax,%eax
801010a8:	7f 0d                	jg     801010b7 <filedup+0x31>
    panic("filedup");
801010aa:	83 ec 0c             	sub    $0xc,%esp
801010ad:	68 e8 ad 10 80       	push   $0x8010ade8
801010b2:	e8 0e f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010b7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ba:	8b 40 04             	mov    0x4(%eax),%eax
801010bd:	8d 50 01             	lea    0x1(%eax),%edx
801010c0:	8b 45 08             	mov    0x8(%ebp),%eax
801010c3:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010c6:	83 ec 0c             	sub    $0xc,%esp
801010c9:	68 a0 5d 11 80       	push   $0x80115da0
801010ce:	e8 85 41 00 00       	call   80105258 <release>
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
801010e8:	68 a0 5d 11 80       	push   $0x80115da0
801010ed:	e8 f4 40 00 00       	call   801051e6 <acquire>
801010f2:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	8b 40 04             	mov    0x4(%eax),%eax
801010fb:	85 c0                	test   %eax,%eax
801010fd:	7f 0d                	jg     8010110c <fileclose+0x31>
    panic("fileclose");
801010ff:	83 ec 0c             	sub    $0xc,%esp
80101102:	68 f0 ad 10 80       	push   $0x8010adf0
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
80101128:	68 a0 5d 11 80       	push   $0x80115da0
8010112d:	e8 26 41 00 00       	call   80105258 <release>
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
80101176:	68 a0 5d 11 80       	push   $0x80115da0
8010117b:	e8 d8 40 00 00       	call   80105258 <release>
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
8010119a:	e8 6b 2b 00 00       	call   80103d0a <pipeclose>
8010119f:	83 c4 10             	add    $0x10,%esp
801011a2:	eb 21                	jmp    801011c5 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011a7:	83 f8 02             	cmp    $0x2,%eax
801011aa:	75 19                	jne    801011c5 <fileclose+0xea>
    begin_op();
801011ac:	e8 aa 24 00 00       	call   8010365b <begin_op>
    iput(ff.ip);
801011b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011b4:	83 ec 0c             	sub    $0xc,%esp
801011b7:	50                   	push   %eax
801011b8:	e8 1a 0a 00 00       	call   80101bd7 <iput>
801011bd:	83 c4 10             	add    $0x10,%esp
    end_op();
801011c0:	e8 26 25 00 00       	call   801036eb <end_op>
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
8010125b:	e8 5f 2c 00 00       	call   80103ebf <piperead>
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
801012d2:	68 fa ad 10 80       	push   $0x8010adfa
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
80101318:	e8 9c 2a 00 00       	call   80103db9 <pipewrite>
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
8010135d:	e8 f9 22 00 00       	call   8010365b <begin_op>
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
801013c3:	e8 23 23 00 00       	call   801036eb <end_op>

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
801013d9:	68 03 ae 10 80       	push   $0x8010ae03
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
8010140f:	68 13 ae 10 80       	push   $0x8010ae13
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
8010144b:	e8 ec 40 00 00       	call   8010553c <memmove>
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
80101495:	e8 db 3f 00 00       	call   80105475 <memset>
8010149a:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010149d:	83 ec 0c             	sub    $0xc,%esp
801014a0:	ff 75 f4             	pushl  -0xc(%ebp)
801014a3:	e8 fc 23 00 00       	call   801038a4 <log_write>
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
801014ec:	a1 b8 67 11 80       	mov    0x801167b8,%eax
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
8010157b:	e8 24 23 00 00       	call   801038a4 <log_write>
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
801015ca:	a1 a0 67 11 80       	mov    0x801167a0,%eax
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
801015ec:	8b 15 a0 67 11 80    	mov    0x801167a0,%edx
801015f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015f5:	39 c2                	cmp    %eax,%edx
801015f7:	0f 87 dc fe ff ff    	ja     801014d9 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801015fd:	83 ec 0c             	sub    $0xc,%esp
80101600:	68 20 ae 10 80       	push   $0x8010ae20
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
80101619:	68 a0 67 11 80       	push   $0x801167a0
8010161e:	ff 75 08             	pushl  0x8(%ebp)
80101621:	e8 f8 fd ff ff       	call   8010141e <readsb>
80101626:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101629:	8b 45 0c             	mov    0xc(%ebp),%eax
8010162c:	c1 e8 0c             	shr    $0xc,%eax
8010162f:	89 c2                	mov    %eax,%edx
80101631:	a1 b8 67 11 80       	mov    0x801167b8,%eax
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
80101697:	68 36 ae 10 80       	push   $0x8010ae36
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
801016cf:	e8 d0 21 00 00       	call   801038a4 <log_write>
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
801016ff:	68 49 ae 10 80       	push   $0x8010ae49
80101704:	68 c0 67 11 80       	push   $0x801167c0
80101709:	e8 b2 3a 00 00       	call   801051c0 <initlock>
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
8010172a:	05 c0 67 11 80       	add    $0x801167c0,%eax
8010172f:	83 c0 10             	add    $0x10,%eax
80101732:	83 ec 08             	sub    $0x8,%esp
80101735:	68 50 ae 10 80       	push   $0x8010ae50
8010173a:	50                   	push   %eax
8010173b:	e8 13 39 00 00       	call   80105053 <initsleeplock>
80101740:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101743:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101747:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
8010174b:	7e cd                	jle    8010171a <iinit+0x32>
  }

  readsb(dev, &sb);
8010174d:	83 ec 08             	sub    $0x8,%esp
80101750:	68 a0 67 11 80       	push   $0x801167a0
80101755:	ff 75 08             	pushl  0x8(%ebp)
80101758:	e8 c1 fc ff ff       	call   8010141e <readsb>
8010175d:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101760:	a1 b8 67 11 80       	mov    0x801167b8,%eax
80101765:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101768:	8b 3d b4 67 11 80    	mov    0x801167b4,%edi
8010176e:	8b 35 b0 67 11 80    	mov    0x801167b0,%esi
80101774:	8b 1d ac 67 11 80    	mov    0x801167ac,%ebx
8010177a:	8b 0d a8 67 11 80    	mov    0x801167a8,%ecx
80101780:	8b 15 a4 67 11 80    	mov    0x801167a4,%edx
80101786:	a1 a0 67 11 80       	mov    0x801167a0,%eax
8010178b:	ff 75 d4             	pushl  -0x2c(%ebp)
8010178e:	57                   	push   %edi
8010178f:	56                   	push   %esi
80101790:	53                   	push   %ebx
80101791:	51                   	push   %ecx
80101792:	52                   	push   %edx
80101793:	50                   	push   %eax
80101794:	68 58 ae 10 80       	push   $0x8010ae58
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
801017cf:	a1 b4 67 11 80       	mov    0x801167b4,%eax
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
80101811:	e8 5f 3c 00 00       	call   80105475 <memset>
80101816:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101819:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010181c:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101820:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101823:	83 ec 0c             	sub    $0xc,%esp
80101826:	ff 75 f0             	pushl  -0x10(%ebp)
80101829:	e8 76 20 00 00       	call   801038a4 <log_write>
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
80101865:	8b 15 a8 67 11 80    	mov    0x801167a8,%edx
8010186b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186e:	39 c2                	cmp    %eax,%edx
80101870:	0f 87 51 ff ff ff    	ja     801017c7 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101876:	83 ec 0c             	sub    $0xc,%esp
80101879:	68 ab ae 10 80       	push   $0x8010aeab
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
8010189a:	a1 b4 67 11 80       	mov    0x801167b4,%eax
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
80101923:	e8 14 3c 00 00       	call   8010553c <memmove>
80101928:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010192b:	83 ec 0c             	sub    $0xc,%esp
8010192e:	ff 75 f4             	pushl  -0xc(%ebp)
80101931:	e8 6e 1f 00 00       	call   801038a4 <log_write>
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
80101957:	68 c0 67 11 80       	push   $0x801167c0
8010195c:	e8 85 38 00 00       	call   801051e6 <acquire>
80101961:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101964:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010196b:	c7 45 f4 f4 67 11 80 	movl   $0x801167f4,-0xc(%ebp)
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
801019a5:	68 c0 67 11 80       	push   $0x801167c0
801019aa:	e8 a9 38 00 00       	call   80105258 <release>
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
801019d4:	81 7d f4 14 84 11 80 	cmpl   $0x80118414,-0xc(%ebp)
801019db:	72 97                	jb     80101974 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019e1:	75 0d                	jne    801019f0 <iget+0xa6>
    panic("iget: no inodes");
801019e3:	83 ec 0c             	sub    $0xc,%esp
801019e6:	68 bd ae 10 80       	push   $0x8010aebd
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
80101a1e:	68 c0 67 11 80       	push   $0x801167c0
80101a23:	e8 30 38 00 00       	call   80105258 <release>
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
80101a3d:	68 c0 67 11 80       	push   $0x801167c0
80101a42:	e8 9f 37 00 00       	call   801051e6 <acquire>
80101a47:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4d:	8b 40 08             	mov    0x8(%eax),%eax
80101a50:	8d 50 01             	lea    0x1(%eax),%edx
80101a53:	8b 45 08             	mov    0x8(%ebp),%eax
80101a56:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a59:	83 ec 0c             	sub    $0xc,%esp
80101a5c:	68 c0 67 11 80       	push   $0x801167c0
80101a61:	e8 f2 37 00 00       	call   80105258 <release>
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
80101a8b:	68 cd ae 10 80       	push   $0x8010aecd
80101a90:	e8 30 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	83 c0 0c             	add    $0xc,%eax
80101a9b:	83 ec 0c             	sub    $0xc,%esp
80101a9e:	50                   	push   %eax
80101a9f:	e8 ef 35 00 00       	call   80105093 <acquiresleep>
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
80101ac0:	a1 b4 67 11 80       	mov    0x801167b4,%eax
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
80101b49:	e8 ee 39 00 00       	call   8010553c <memmove>
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
80101b78:	68 d3 ae 10 80       	push   $0x8010aed3
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
80101b9f:	e8 a9 35 00 00       	call   8010514d <holdingsleep>
80101ba4:	83 c4 10             	add    $0x10,%esp
80101ba7:	85 c0                	test   %eax,%eax
80101ba9:	74 0a                	je     80101bb5 <iunlock+0x30>
80101bab:	8b 45 08             	mov    0x8(%ebp),%eax
80101bae:	8b 40 08             	mov    0x8(%eax),%eax
80101bb1:	85 c0                	test   %eax,%eax
80101bb3:	7f 0d                	jg     80101bc2 <iunlock+0x3d>
    panic("iunlock");
80101bb5:	83 ec 0c             	sub    $0xc,%esp
80101bb8:	68 e2 ae 10 80       	push   $0x8010aee2
80101bbd:	e8 03 ea ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	83 c0 0c             	add    $0xc,%eax
80101bc8:	83 ec 0c             	sub    $0xc,%esp
80101bcb:	50                   	push   %eax
80101bcc:	e8 2a 35 00 00       	call   801050fb <releasesleep>
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
80101beb:	e8 a3 34 00 00       	call   80105093 <acquiresleep>
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
80101c0c:	68 c0 67 11 80       	push   $0x801167c0
80101c11:	e8 d0 35 00 00       	call   801051e6 <acquire>
80101c16:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c19:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1c:	8b 40 08             	mov    0x8(%eax),%eax
80101c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c22:	83 ec 0c             	sub    $0xc,%esp
80101c25:	68 c0 67 11 80       	push   $0x801167c0
80101c2a:	e8 29 36 00 00       	call   80105258 <release>
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
80101c71:	e8 85 34 00 00       	call   801050fb <releasesleep>
80101c76:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c79:	83 ec 0c             	sub    $0xc,%esp
80101c7c:	68 c0 67 11 80       	push   $0x801167c0
80101c81:	e8 60 35 00 00       	call   801051e6 <acquire>
80101c86:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c89:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8c:	8b 40 08             	mov    0x8(%eax),%eax
80101c8f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c92:	8b 45 08             	mov    0x8(%ebp),%eax
80101c95:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c98:	83 ec 0c             	sub    $0xc,%esp
80101c9b:	68 c0 67 11 80       	push   $0x801167c0
80101ca0:	e8 b3 35 00 00       	call   80105258 <release>
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
80101dce:	e8 d1 1a 00 00       	call   801038a4 <log_write>
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
80101dec:	68 ea ae 10 80       	push   $0x8010aeea
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
80101fae:	8b 04 c5 40 67 11 80 	mov    -0x7fee98c0(,%eax,8),%eax
80101fb5:	85 c0                	test   %eax,%eax
80101fb7:	75 0a                	jne    80101fc3 <readi+0x4d>
      return -1;
80101fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fbe:	e9 0a 01 00 00       	jmp    801020cd <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fca:	98                   	cwtl   
80101fcb:	8b 04 c5 40 67 11 80 	mov    -0x7fee98c0(,%eax,8),%eax
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
80102096:	e8 a1 34 00 00       	call   8010553c <memmove>
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
80102107:	8b 04 c5 44 67 11 80 	mov    -0x7fee98bc(,%eax,8),%eax
8010210e:	85 c0                	test   %eax,%eax
80102110:	75 0a                	jne    8010211c <writei+0x4d>
      return -1;
80102112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102117:	e9 3b 01 00 00       	jmp    80102257 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010211c:	8b 45 08             	mov    0x8(%ebp),%eax
8010211f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102123:	98                   	cwtl   
80102124:	8b 04 c5 44 67 11 80 	mov    -0x7fee98bc(,%eax,8),%eax
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
801021ea:	e8 4d 33 00 00       	call   8010553c <memmove>
801021ef:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021f2:	83 ec 0c             	sub    $0xc,%esp
801021f5:	ff 75 f0             	pushl  -0x10(%ebp)
801021f8:	e8 a7 16 00 00       	call   801038a4 <log_write>
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
8010226e:	e8 67 33 00 00       	call   801055da <strncmp>
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
80102292:	68 fd ae 10 80       	push   $0x8010aefd
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
801022c1:	68 0f af 10 80       	push   $0x8010af0f
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
8010239a:	68 1e af 10 80       	push   $0x8010af1e
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
801023d5:	e8 5a 32 00 00       	call   80105634 <strncpy>
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
80102401:	68 2b af 10 80       	push   $0x8010af2b
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
80102477:	e8 c0 30 00 00       	call   8010553c <memmove>
8010247c:	83 c4 10             	add    $0x10,%esp
8010247f:	eb 26                	jmp    801024a7 <skipelem+0x95>
  else {
    memmove(name, s, len);
80102481:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102484:	83 ec 04             	sub    $0x4,%esp
80102487:	50                   	push   %eax
80102488:	ff 75 f4             	pushl  -0xc(%ebp)
8010248b:	ff 75 0c             	pushl  0xc(%ebp)
8010248e:	e8 a9 30 00 00       	call   8010553c <memmove>
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
801024e1:	e8 ad 1b 00 00       	call   80104093 <myproc>
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

80102618 <inb>:
{
80102618:	55                   	push   %ebp
80102619:	89 e5                	mov    %esp,%ebp
8010261b:	83 ec 14             	sub    $0x14,%esp
8010261e:	8b 45 08             	mov    0x8(%ebp),%eax
80102621:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102625:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102629:	89 c2                	mov    %eax,%edx
8010262b:	ec                   	in     (%dx),%al
8010262c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010262f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102633:	c9                   	leave  
80102634:	c3                   	ret    

80102635 <insl>:
{
80102635:	55                   	push   %ebp
80102636:	89 e5                	mov    %esp,%ebp
80102638:	57                   	push   %edi
80102639:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010263a:	8b 55 08             	mov    0x8(%ebp),%edx
8010263d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102640:	8b 45 10             	mov    0x10(%ebp),%eax
80102643:	89 cb                	mov    %ecx,%ebx
80102645:	89 df                	mov    %ebx,%edi
80102647:	89 c1                	mov    %eax,%ecx
80102649:	fc                   	cld    
8010264a:	f3 6d                	rep insl (%dx),%es:(%edi)
8010264c:	89 c8                	mov    %ecx,%eax
8010264e:	89 fb                	mov    %edi,%ebx
80102650:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102653:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102656:	90                   	nop
80102657:	5b                   	pop    %ebx
80102658:	5f                   	pop    %edi
80102659:	5d                   	pop    %ebp
8010265a:	c3                   	ret    

8010265b <outb>:
{
8010265b:	55                   	push   %ebp
8010265c:	89 e5                	mov    %esp,%ebp
8010265e:	83 ec 08             	sub    $0x8,%esp
80102661:	8b 45 08             	mov    0x8(%ebp),%eax
80102664:	8b 55 0c             	mov    0xc(%ebp),%edx
80102667:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010266b:	89 d0                	mov    %edx,%eax
8010266d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102670:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102674:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102678:	ee                   	out    %al,(%dx)
}
80102679:	90                   	nop
8010267a:	c9                   	leave  
8010267b:	c3                   	ret    

8010267c <outsl>:
{
8010267c:	55                   	push   %ebp
8010267d:	89 e5                	mov    %esp,%ebp
8010267f:	56                   	push   %esi
80102680:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102681:	8b 55 08             	mov    0x8(%ebp),%edx
80102684:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102687:	8b 45 10             	mov    0x10(%ebp),%eax
8010268a:	89 cb                	mov    %ecx,%ebx
8010268c:	89 de                	mov    %ebx,%esi
8010268e:	89 c1                	mov    %eax,%ecx
80102690:	fc                   	cld    
80102691:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102693:	89 c8                	mov    %ecx,%eax
80102695:	89 f3                	mov    %esi,%ebx
80102697:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010269a:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010269d:	90                   	nop
8010269e:	5b                   	pop    %ebx
8010269f:	5e                   	pop    %esi
801026a0:	5d                   	pop    %ebp
801026a1:	c3                   	ret    

801026a2 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801026a2:	f3 0f 1e fb          	endbr32 
801026a6:	55                   	push   %ebp
801026a7:	89 e5                	mov    %esp,%ebp
801026a9:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801026ac:	90                   	nop
801026ad:	68 f7 01 00 00       	push   $0x1f7
801026b2:	e8 61 ff ff ff       	call   80102618 <inb>
801026b7:	83 c4 04             	add    $0x4,%esp
801026ba:	0f b6 c0             	movzbl %al,%eax
801026bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026c3:	25 c0 00 00 00       	and    $0xc0,%eax
801026c8:	83 f8 40             	cmp    $0x40,%eax
801026cb:	75 e0                	jne    801026ad <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026cd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026d1:	74 11                	je     801026e4 <idewait+0x42>
801026d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026d6:	83 e0 21             	and    $0x21,%eax
801026d9:	85 c0                	test   %eax,%eax
801026db:	74 07                	je     801026e4 <idewait+0x42>
    return -1;
801026dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026e2:	eb 05                	jmp    801026e9 <idewait+0x47>
  return 0;
801026e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026e9:	c9                   	leave  
801026ea:	c3                   	ret    

801026eb <ideinit>:

void
ideinit(void)
{
801026eb:	f3 0f 1e fb          	endbr32 
801026ef:	55                   	push   %ebp
801026f0:	89 e5                	mov    %esp,%ebp
801026f2:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801026f5:	83 ec 08             	sub    $0x8,%esp
801026f8:	68 33 af 10 80       	push   $0x8010af33
801026fd:	68 60 00 11 80       	push   $0x80110060
80102702:	e8 b9 2a 00 00       	call   801051c0 <initlock>
80102707:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
8010270a:	a1 c0 b4 11 80       	mov    0x8011b4c0,%eax
8010270f:	83 e8 01             	sub    $0x1,%eax
80102712:	83 ec 08             	sub    $0x8,%esp
80102715:	50                   	push   %eax
80102716:	6a 0e                	push   $0xe
80102718:	e8 d9 04 00 00       	call   80102bf6 <ioapicenable>
8010271d:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102720:	83 ec 0c             	sub    $0xc,%esp
80102723:	6a 00                	push   $0x0
80102725:	e8 78 ff ff ff       	call   801026a2 <idewait>
8010272a:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010272d:	83 ec 08             	sub    $0x8,%esp
80102730:	68 f0 00 00 00       	push   $0xf0
80102735:	68 f6 01 00 00       	push   $0x1f6
8010273a:	e8 1c ff ff ff       	call   8010265b <outb>
8010273f:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102742:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102749:	eb 24                	jmp    8010276f <ideinit+0x84>
    if(inb(0x1f7) != 0){
8010274b:	83 ec 0c             	sub    $0xc,%esp
8010274e:	68 f7 01 00 00       	push   $0x1f7
80102753:	e8 c0 fe ff ff       	call   80102618 <inb>
80102758:	83 c4 10             	add    $0x10,%esp
8010275b:	84 c0                	test   %al,%al
8010275d:	74 0c                	je     8010276b <ideinit+0x80>
      havedisk1 = 1;
8010275f:	c7 05 98 00 11 80 01 	movl   $0x1,0x80110098
80102766:	00 00 00 
      break;
80102769:	eb 0d                	jmp    80102778 <ideinit+0x8d>
  for(i=0; i<1000; i++){
8010276b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010276f:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102776:	7e d3                	jle    8010274b <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102778:	83 ec 08             	sub    $0x8,%esp
8010277b:	68 e0 00 00 00       	push   $0xe0
80102780:	68 f6 01 00 00       	push   $0x1f6
80102785:	e8 d1 fe ff ff       	call   8010265b <outb>
8010278a:	83 c4 10             	add    $0x10,%esp
}
8010278d:	90                   	nop
8010278e:	c9                   	leave  
8010278f:	c3                   	ret    

80102790 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102790:	f3 0f 1e fb          	endbr32 
80102794:	55                   	push   %ebp
80102795:	89 e5                	mov    %esp,%ebp
80102797:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010279a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010279e:	75 0d                	jne    801027ad <idestart+0x1d>
    panic("idestart");
801027a0:	83 ec 0c             	sub    $0xc,%esp
801027a3:	68 37 af 10 80       	push   $0x8010af37
801027a8:	e8 18 de ff ff       	call   801005c5 <panic>
  if(b->blockno >= FSSIZE)
801027ad:	8b 45 08             	mov    0x8(%ebp),%eax
801027b0:	8b 40 08             	mov    0x8(%eax),%eax
801027b3:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801027b8:	76 0d                	jbe    801027c7 <idestart+0x37>
    panic("incorrect blockno");
801027ba:	83 ec 0c             	sub    $0xc,%esp
801027bd:	68 40 af 10 80       	push   $0x8010af40
801027c2:	e8 fe dd ff ff       	call   801005c5 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027c7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027ce:	8b 45 08             	mov    0x8(%ebp),%eax
801027d1:	8b 50 08             	mov    0x8(%eax),%edx
801027d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d7:	0f af c2             	imul   %edx,%eax
801027da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027dd:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027e1:	75 07                	jne    801027ea <idestart+0x5a>
801027e3:	b8 20 00 00 00       	mov    $0x20,%eax
801027e8:	eb 05                	jmp    801027ef <idestart+0x5f>
801027ea:	b8 c4 00 00 00       	mov    $0xc4,%eax
801027ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801027f2:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027f6:	75 07                	jne    801027ff <idestart+0x6f>
801027f8:	b8 30 00 00 00       	mov    $0x30,%eax
801027fd:	eb 05                	jmp    80102804 <idestart+0x74>
801027ff:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102804:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102807:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010280b:	7e 0d                	jle    8010281a <idestart+0x8a>
8010280d:	83 ec 0c             	sub    $0xc,%esp
80102810:	68 37 af 10 80       	push   $0x8010af37
80102815:	e8 ab dd ff ff       	call   801005c5 <panic>

  idewait(0);
8010281a:	83 ec 0c             	sub    $0xc,%esp
8010281d:	6a 00                	push   $0x0
8010281f:	e8 7e fe ff ff       	call   801026a2 <idewait>
80102824:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102827:	83 ec 08             	sub    $0x8,%esp
8010282a:	6a 00                	push   $0x0
8010282c:	68 f6 03 00 00       	push   $0x3f6
80102831:	e8 25 fe ff ff       	call   8010265b <outb>
80102836:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010283c:	0f b6 c0             	movzbl %al,%eax
8010283f:	83 ec 08             	sub    $0x8,%esp
80102842:	50                   	push   %eax
80102843:	68 f2 01 00 00       	push   $0x1f2
80102848:	e8 0e fe ff ff       	call   8010265b <outb>
8010284d:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102850:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102853:	0f b6 c0             	movzbl %al,%eax
80102856:	83 ec 08             	sub    $0x8,%esp
80102859:	50                   	push   %eax
8010285a:	68 f3 01 00 00       	push   $0x1f3
8010285f:	e8 f7 fd ff ff       	call   8010265b <outb>
80102864:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010286a:	c1 f8 08             	sar    $0x8,%eax
8010286d:	0f b6 c0             	movzbl %al,%eax
80102870:	83 ec 08             	sub    $0x8,%esp
80102873:	50                   	push   %eax
80102874:	68 f4 01 00 00       	push   $0x1f4
80102879:	e8 dd fd ff ff       	call   8010265b <outb>
8010287e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102884:	c1 f8 10             	sar    $0x10,%eax
80102887:	0f b6 c0             	movzbl %al,%eax
8010288a:	83 ec 08             	sub    $0x8,%esp
8010288d:	50                   	push   %eax
8010288e:	68 f5 01 00 00       	push   $0x1f5
80102893:	e8 c3 fd ff ff       	call   8010265b <outb>
80102898:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010289b:	8b 45 08             	mov    0x8(%ebp),%eax
8010289e:	8b 40 04             	mov    0x4(%eax),%eax
801028a1:	c1 e0 04             	shl    $0x4,%eax
801028a4:	83 e0 10             	and    $0x10,%eax
801028a7:	89 c2                	mov    %eax,%edx
801028a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ac:	c1 f8 18             	sar    $0x18,%eax
801028af:	83 e0 0f             	and    $0xf,%eax
801028b2:	09 d0                	or     %edx,%eax
801028b4:	83 c8 e0             	or     $0xffffffe0,%eax
801028b7:	0f b6 c0             	movzbl %al,%eax
801028ba:	83 ec 08             	sub    $0x8,%esp
801028bd:	50                   	push   %eax
801028be:	68 f6 01 00 00       	push   $0x1f6
801028c3:	e8 93 fd ff ff       	call   8010265b <outb>
801028c8:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801028cb:	8b 45 08             	mov    0x8(%ebp),%eax
801028ce:	8b 00                	mov    (%eax),%eax
801028d0:	83 e0 04             	and    $0x4,%eax
801028d3:	85 c0                	test   %eax,%eax
801028d5:	74 35                	je     8010290c <idestart+0x17c>
    outb(0x1f7, write_cmd);
801028d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028da:	0f b6 c0             	movzbl %al,%eax
801028dd:	83 ec 08             	sub    $0x8,%esp
801028e0:	50                   	push   %eax
801028e1:	68 f7 01 00 00       	push   $0x1f7
801028e6:	e8 70 fd ff ff       	call   8010265b <outb>
801028eb:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028ee:	8b 45 08             	mov    0x8(%ebp),%eax
801028f1:	83 c0 5c             	add    $0x5c,%eax
801028f4:	83 ec 04             	sub    $0x4,%esp
801028f7:	68 80 00 00 00       	push   $0x80
801028fc:	50                   	push   %eax
801028fd:	68 f0 01 00 00       	push   $0x1f0
80102902:	e8 75 fd ff ff       	call   8010267c <outsl>
80102907:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010290a:	eb 17                	jmp    80102923 <idestart+0x193>
    outb(0x1f7, read_cmd);
8010290c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010290f:	0f b6 c0             	movzbl %al,%eax
80102912:	83 ec 08             	sub    $0x8,%esp
80102915:	50                   	push   %eax
80102916:	68 f7 01 00 00       	push   $0x1f7
8010291b:	e8 3b fd ff ff       	call   8010265b <outb>
80102920:	83 c4 10             	add    $0x10,%esp
}
80102923:	90                   	nop
80102924:	c9                   	leave  
80102925:	c3                   	ret    

80102926 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102926:	f3 0f 1e fb          	endbr32 
8010292a:	55                   	push   %ebp
8010292b:	89 e5                	mov    %esp,%ebp
8010292d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102930:	83 ec 0c             	sub    $0xc,%esp
80102933:	68 60 00 11 80       	push   $0x80110060
80102938:	e8 a9 28 00 00       	call   801051e6 <acquire>
8010293d:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102940:	a1 94 00 11 80       	mov    0x80110094,%eax
80102945:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102948:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010294c:	75 15                	jne    80102963 <ideintr+0x3d>
    release(&idelock);
8010294e:	83 ec 0c             	sub    $0xc,%esp
80102951:	68 60 00 11 80       	push   $0x80110060
80102956:	e8 fd 28 00 00       	call   80105258 <release>
8010295b:	83 c4 10             	add    $0x10,%esp
    return;
8010295e:	e9 9a 00 00 00       	jmp    801029fd <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102966:	8b 40 58             	mov    0x58(%eax),%eax
80102969:	a3 94 00 11 80       	mov    %eax,0x80110094

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010296e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102971:	8b 00                	mov    (%eax),%eax
80102973:	83 e0 04             	and    $0x4,%eax
80102976:	85 c0                	test   %eax,%eax
80102978:	75 2d                	jne    801029a7 <ideintr+0x81>
8010297a:	83 ec 0c             	sub    $0xc,%esp
8010297d:	6a 01                	push   $0x1
8010297f:	e8 1e fd ff ff       	call   801026a2 <idewait>
80102984:	83 c4 10             	add    $0x10,%esp
80102987:	85 c0                	test   %eax,%eax
80102989:	78 1c                	js     801029a7 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
8010298b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298e:	83 c0 5c             	add    $0x5c,%eax
80102991:	83 ec 04             	sub    $0x4,%esp
80102994:	68 80 00 00 00       	push   $0x80
80102999:	50                   	push   %eax
8010299a:	68 f0 01 00 00       	push   $0x1f0
8010299f:	e8 91 fc ff ff       	call   80102635 <insl>
801029a4:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801029a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029aa:	8b 00                	mov    (%eax),%eax
801029ac:	83 c8 02             	or     $0x2,%eax
801029af:	89 c2                	mov    %eax,%edx
801029b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b4:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b9:	8b 00                	mov    (%eax),%eax
801029bb:	83 e0 fb             	and    $0xfffffffb,%eax
801029be:	89 c2                	mov    %eax,%edx
801029c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029c5:	83 ec 0c             	sub    $0xc,%esp
801029c8:	ff 75 f4             	pushl  -0xc(%ebp)
801029cb:	e8 5e 23 00 00       	call   80104d2e <wakeup>
801029d0:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801029d3:	a1 94 00 11 80       	mov    0x80110094,%eax
801029d8:	85 c0                	test   %eax,%eax
801029da:	74 11                	je     801029ed <ideintr+0xc7>
    idestart(idequeue);
801029dc:	a1 94 00 11 80       	mov    0x80110094,%eax
801029e1:	83 ec 0c             	sub    $0xc,%esp
801029e4:	50                   	push   %eax
801029e5:	e8 a6 fd ff ff       	call   80102790 <idestart>
801029ea:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801029ed:	83 ec 0c             	sub    $0xc,%esp
801029f0:	68 60 00 11 80       	push   $0x80110060
801029f5:	e8 5e 28 00 00       	call   80105258 <release>
801029fa:	83 c4 10             	add    $0x10,%esp
}
801029fd:	c9                   	leave  
801029fe:	c3                   	ret    

801029ff <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029ff:	f3 0f 1e fb          	endbr32 
80102a03:	55                   	push   %ebp
80102a04:	89 e5                	mov    %esp,%ebp
80102a06:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102a09:	8b 15 98 00 11 80    	mov    0x80110098,%edx
80102a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a12:	8b 40 04             	mov    0x4(%eax),%eax
80102a15:	83 ec 04             	sub    $0x4,%esp
80102a18:	52                   	push   %edx
80102a19:	50                   	push   %eax
80102a1a:	68 52 af 10 80       	push   $0x8010af52
80102a1f:	e8 e8 d9 ff ff       	call   8010040c <cprintf>
80102a24:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
80102a27:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2a:	83 c0 0c             	add    $0xc,%eax
80102a2d:	83 ec 0c             	sub    $0xc,%esp
80102a30:	50                   	push   %eax
80102a31:	e8 17 27 00 00       	call   8010514d <holdingsleep>
80102a36:	83 c4 10             	add    $0x10,%esp
80102a39:	85 c0                	test   %eax,%eax
80102a3b:	75 0d                	jne    80102a4a <iderw+0x4b>
    panic("iderw: buf not locked");
80102a3d:	83 ec 0c             	sub    $0xc,%esp
80102a40:	68 6c af 10 80       	push   $0x8010af6c
80102a45:	e8 7b db ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a4d:	8b 00                	mov    (%eax),%eax
80102a4f:	83 e0 06             	and    $0x6,%eax
80102a52:	83 f8 02             	cmp    $0x2,%eax
80102a55:	75 0d                	jne    80102a64 <iderw+0x65>
    panic("iderw: nothing to do");
80102a57:	83 ec 0c             	sub    $0xc,%esp
80102a5a:	68 82 af 10 80       	push   $0x8010af82
80102a5f:	e8 61 db ff ff       	call   801005c5 <panic>
  if(b->dev != 0 && !havedisk1)
80102a64:	8b 45 08             	mov    0x8(%ebp),%eax
80102a67:	8b 40 04             	mov    0x4(%eax),%eax
80102a6a:	85 c0                	test   %eax,%eax
80102a6c:	74 16                	je     80102a84 <iderw+0x85>
80102a6e:	a1 98 00 11 80       	mov    0x80110098,%eax
80102a73:	85 c0                	test   %eax,%eax
80102a75:	75 0d                	jne    80102a84 <iderw+0x85>
    panic("iderw: ide disk 1 not present");
80102a77:	83 ec 0c             	sub    $0xc,%esp
80102a7a:	68 97 af 10 80       	push   $0x8010af97
80102a7f:	e8 41 db ff ff       	call   801005c5 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a84:	83 ec 0c             	sub    $0xc,%esp
80102a87:	68 60 00 11 80       	push   $0x80110060
80102a8c:	e8 55 27 00 00       	call   801051e6 <acquire>
80102a91:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a94:	8b 45 08             	mov    0x8(%ebp),%eax
80102a97:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a9e:	c7 45 f4 94 00 11 80 	movl   $0x80110094,-0xc(%ebp)
80102aa5:	eb 0b                	jmp    80102ab2 <iderw+0xb3>
80102aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aaa:	8b 00                	mov    (%eax),%eax
80102aac:	83 c0 58             	add    $0x58,%eax
80102aaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab5:	8b 00                	mov    (%eax),%eax
80102ab7:	85 c0                	test   %eax,%eax
80102ab9:	75 ec                	jne    80102aa7 <iderw+0xa8>
    ;
  *pp = b;
80102abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102abe:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac1:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102ac3:	a1 94 00 11 80       	mov    0x80110094,%eax
80102ac8:	39 45 08             	cmp    %eax,0x8(%ebp)
80102acb:	75 23                	jne    80102af0 <iderw+0xf1>
    idestart(b);
80102acd:	83 ec 0c             	sub    $0xc,%esp
80102ad0:	ff 75 08             	pushl  0x8(%ebp)
80102ad3:	e8 b8 fc ff ff       	call   80102790 <idestart>
80102ad8:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102adb:	eb 13                	jmp    80102af0 <iderw+0xf1>
    sleep(b, &idelock);
80102add:	83 ec 08             	sub    $0x8,%esp
80102ae0:	68 60 00 11 80       	push   $0x80110060
80102ae5:	ff 75 08             	pushl  0x8(%ebp)
80102ae8:	e8 4f 21 00 00       	call   80104c3c <sleep>
80102aed:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102af0:	8b 45 08             	mov    0x8(%ebp),%eax
80102af3:	8b 00                	mov    (%eax),%eax
80102af5:	83 e0 06             	and    $0x6,%eax
80102af8:	83 f8 02             	cmp    $0x2,%eax
80102afb:	75 e0                	jne    80102add <iderw+0xde>
  }


  release(&idelock);
80102afd:	83 ec 0c             	sub    $0xc,%esp
80102b00:	68 60 00 11 80       	push   $0x80110060
80102b05:	e8 4e 27 00 00       	call   80105258 <release>
80102b0a:	83 c4 10             	add    $0x10,%esp
}
80102b0d:	90                   	nop
80102b0e:	c9                   	leave  
80102b0f:	c3                   	ret    

80102b10 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b10:	f3 0f 1e fb          	endbr32 
80102b14:	55                   	push   %ebp
80102b15:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b17:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b1c:	8b 55 08             	mov    0x8(%ebp),%edx
80102b1f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b21:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b26:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b29:	5d                   	pop    %ebp
80102b2a:	c3                   	ret    

80102b2b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b2b:	f3 0f 1e fb          	endbr32 
80102b2f:	55                   	push   %ebp
80102b30:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b32:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b37:	8b 55 08             	mov    0x8(%ebp),%edx
80102b3a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b3c:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b41:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b44:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b47:	90                   	nop
80102b48:	5d                   	pop    %ebp
80102b49:	c3                   	ret    

80102b4a <ioapicinit>:

void
ioapicinit(void)
{
80102b4a:	f3 0f 1e fb          	endbr32 
80102b4e:	55                   	push   %ebp
80102b4f:	89 e5                	mov    %esp,%ebp
80102b51:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b54:	c7 05 14 84 11 80 00 	movl   $0xfec00000,0x80118414
80102b5b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b5e:	6a 01                	push   $0x1
80102b60:	e8 ab ff ff ff       	call   80102b10 <ioapicread>
80102b65:	83 c4 04             	add    $0x4,%esp
80102b68:	c1 e8 10             	shr    $0x10,%eax
80102b6b:	25 ff 00 00 00       	and    $0xff,%eax
80102b70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b73:	6a 00                	push   $0x0
80102b75:	e8 96 ff ff ff       	call   80102b10 <ioapicread>
80102b7a:	83 c4 04             	add    $0x4,%esp
80102b7d:	c1 e8 18             	shr    $0x18,%eax
80102b80:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b83:	0f b6 05 e0 b1 11 80 	movzbl 0x8011b1e0,%eax
80102b8a:	0f b6 c0             	movzbl %al,%eax
80102b8d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102b90:	74 10                	je     80102ba2 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b92:	83 ec 0c             	sub    $0xc,%esp
80102b95:	68 b8 af 10 80       	push   $0x8010afb8
80102b9a:	e8 6d d8 ff ff       	call   8010040c <cprintf>
80102b9f:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ba2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ba9:	eb 3f                	jmp    80102bea <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bae:	83 c0 20             	add    $0x20,%eax
80102bb1:	0d 00 00 01 00       	or     $0x10000,%eax
80102bb6:	89 c2                	mov    %eax,%edx
80102bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bbb:	83 c0 08             	add    $0x8,%eax
80102bbe:	01 c0                	add    %eax,%eax
80102bc0:	83 ec 08             	sub    $0x8,%esp
80102bc3:	52                   	push   %edx
80102bc4:	50                   	push   %eax
80102bc5:	e8 61 ff ff ff       	call   80102b2b <ioapicwrite>
80102bca:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd0:	83 c0 08             	add    $0x8,%eax
80102bd3:	01 c0                	add    %eax,%eax
80102bd5:	83 c0 01             	add    $0x1,%eax
80102bd8:	83 ec 08             	sub    $0x8,%esp
80102bdb:	6a 00                	push   $0x0
80102bdd:	50                   	push   %eax
80102bde:	e8 48 ff ff ff       	call   80102b2b <ioapicwrite>
80102be3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102be6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bed:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102bf0:	7e b9                	jle    80102bab <ioapicinit+0x61>
  }
}
80102bf2:	90                   	nop
80102bf3:	90                   	nop
80102bf4:	c9                   	leave  
80102bf5:	c3                   	ret    

80102bf6 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102bf6:	f3 0f 1e fb          	endbr32 
80102bfa:	55                   	push   %ebp
80102bfb:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80102c00:	83 c0 20             	add    $0x20,%eax
80102c03:	89 c2                	mov    %eax,%edx
80102c05:	8b 45 08             	mov    0x8(%ebp),%eax
80102c08:	83 c0 08             	add    $0x8,%eax
80102c0b:	01 c0                	add    %eax,%eax
80102c0d:	52                   	push   %edx
80102c0e:	50                   	push   %eax
80102c0f:	e8 17 ff ff ff       	call   80102b2b <ioapicwrite>
80102c14:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c17:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c1a:	c1 e0 18             	shl    $0x18,%eax
80102c1d:	89 c2                	mov    %eax,%edx
80102c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80102c22:	83 c0 08             	add    $0x8,%eax
80102c25:	01 c0                	add    %eax,%eax
80102c27:	83 c0 01             	add    $0x1,%eax
80102c2a:	52                   	push   %edx
80102c2b:	50                   	push   %eax
80102c2c:	e8 fa fe ff ff       	call   80102b2b <ioapicwrite>
80102c31:	83 c4 08             	add    $0x8,%esp
}
80102c34:	90                   	nop
80102c35:	c9                   	leave  
80102c36:	c3                   	ret    

80102c37 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c37:	f3 0f 1e fb          	endbr32 
80102c3b:	55                   	push   %ebp
80102c3c:	89 e5                	mov    %esp,%ebp
80102c3e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102c41:	83 ec 08             	sub    $0x8,%esp
80102c44:	68 ea af 10 80       	push   $0x8010afea
80102c49:	68 20 84 11 80       	push   $0x80118420
80102c4e:	e8 6d 25 00 00       	call   801051c0 <initlock>
80102c53:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102c56:	c7 05 54 84 11 80 00 	movl   $0x0,0x80118454
80102c5d:	00 00 00 
  freerange(vstart, vend);
80102c60:	83 ec 08             	sub    $0x8,%esp
80102c63:	ff 75 0c             	pushl  0xc(%ebp)
80102c66:	ff 75 08             	pushl  0x8(%ebp)
80102c69:	e8 2e 00 00 00       	call   80102c9c <freerange>
80102c6e:	83 c4 10             	add    $0x10,%esp
}
80102c71:	90                   	nop
80102c72:	c9                   	leave  
80102c73:	c3                   	ret    

80102c74 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c74:	f3 0f 1e fb          	endbr32 
80102c78:	55                   	push   %ebp
80102c79:	89 e5                	mov    %esp,%ebp
80102c7b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c7e:	83 ec 08             	sub    $0x8,%esp
80102c81:	ff 75 0c             	pushl  0xc(%ebp)
80102c84:	ff 75 08             	pushl  0x8(%ebp)
80102c87:	e8 10 00 00 00       	call   80102c9c <freerange>
80102c8c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c8f:	c7 05 54 84 11 80 01 	movl   $0x1,0x80118454
80102c96:	00 00 00 
}
80102c99:	90                   	nop
80102c9a:	c9                   	leave  
80102c9b:	c3                   	ret    

80102c9c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c9c:	f3 0f 1e fb          	endbr32 
80102ca0:	55                   	push   %ebp
80102ca1:	89 e5                	mov    %esp,%ebp
80102ca3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca9:	05 ff 0f 00 00       	add    $0xfff,%eax
80102cae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102cb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cb6:	eb 15                	jmp    80102ccd <freerange+0x31>
    kfree(p);
80102cb8:	83 ec 0c             	sub    $0xc,%esp
80102cbb:	ff 75 f4             	pushl  -0xc(%ebp)
80102cbe:	e8 1b 00 00 00       	call   80102cde <kfree>
80102cc3:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cc6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd0:	05 00 10 00 00       	add    $0x1000,%eax
80102cd5:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102cd8:	73 de                	jae    80102cb8 <freerange+0x1c>
}
80102cda:	90                   	nop
80102cdb:	90                   	nop
80102cdc:	c9                   	leave  
80102cdd:	c3                   	ret    

80102cde <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102cde:	f3 0f 1e fb          	endbr32 
80102ce2:	55                   	push   %ebp
80102ce3:	89 e5                	mov    %esp,%ebp
80102ce5:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102ce8:	8b 45 08             	mov    0x8(%ebp),%eax
80102ceb:	25 ff 0f 00 00       	and    $0xfff,%eax
80102cf0:	85 c0                	test   %eax,%eax
80102cf2:	75 18                	jne    80102d0c <kfree+0x2e>
80102cf4:	81 7d 08 00 c0 11 80 	cmpl   $0x8011c000,0x8(%ebp)
80102cfb:	72 0f                	jb     80102d0c <kfree+0x2e>
80102cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80102d00:	05 00 00 00 80       	add    $0x80000000,%eax
80102d05:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102d0a:	76 0d                	jbe    80102d19 <kfree+0x3b>
    panic("kfree");
80102d0c:	83 ec 0c             	sub    $0xc,%esp
80102d0f:	68 ef af 10 80       	push   $0x8010afef
80102d14:	e8 ac d8 ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d19:	83 ec 04             	sub    $0x4,%esp
80102d1c:	68 00 10 00 00       	push   $0x1000
80102d21:	6a 01                	push   $0x1
80102d23:	ff 75 08             	pushl  0x8(%ebp)
80102d26:	e8 4a 27 00 00       	call   80105475 <memset>
80102d2b:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102d2e:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d33:	85 c0                	test   %eax,%eax
80102d35:	74 10                	je     80102d47 <kfree+0x69>
    acquire(&kmem.lock);
80102d37:	83 ec 0c             	sub    $0xc,%esp
80102d3a:	68 20 84 11 80       	push   $0x80118420
80102d3f:	e8 a2 24 00 00       	call   801051e6 <acquire>
80102d44:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102d47:	8b 45 08             	mov    0x8(%ebp),%eax
80102d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102d4d:	8b 15 58 84 11 80    	mov    0x80118458,%edx
80102d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d56:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d5b:	a3 58 84 11 80       	mov    %eax,0x80118458
  if(kmem.use_lock)
80102d60:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d65:	85 c0                	test   %eax,%eax
80102d67:	74 10                	je     80102d79 <kfree+0x9b>
    release(&kmem.lock);
80102d69:	83 ec 0c             	sub    $0xc,%esp
80102d6c:	68 20 84 11 80       	push   $0x80118420
80102d71:	e8 e2 24 00 00       	call   80105258 <release>
80102d76:	83 c4 10             	add    $0x10,%esp
}
80102d79:	90                   	nop
80102d7a:	c9                   	leave  
80102d7b:	c3                   	ret    

80102d7c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d7c:	f3 0f 1e fb          	endbr32 
80102d80:	55                   	push   %ebp
80102d81:	89 e5                	mov    %esp,%ebp
80102d83:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d86:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d8b:	85 c0                	test   %eax,%eax
80102d8d:	74 10                	je     80102d9f <kalloc+0x23>
    acquire(&kmem.lock);
80102d8f:	83 ec 0c             	sub    $0xc,%esp
80102d92:	68 20 84 11 80       	push   $0x80118420
80102d97:	e8 4a 24 00 00       	call   801051e6 <acquire>
80102d9c:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d9f:	a1 58 84 11 80       	mov    0x80118458,%eax
80102da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102da7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102dab:	74 0a                	je     80102db7 <kalloc+0x3b>
    kmem.freelist = r->next;
80102dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db0:	8b 00                	mov    (%eax),%eax
80102db2:	a3 58 84 11 80       	mov    %eax,0x80118458
  if(kmem.use_lock)
80102db7:	a1 54 84 11 80       	mov    0x80118454,%eax
80102dbc:	85 c0                	test   %eax,%eax
80102dbe:	74 10                	je     80102dd0 <kalloc+0x54>
    release(&kmem.lock);
80102dc0:	83 ec 0c             	sub    $0xc,%esp
80102dc3:	68 20 84 11 80       	push   $0x80118420
80102dc8:	e8 8b 24 00 00       	call   80105258 <release>
80102dcd:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102dd3:	c9                   	leave  
80102dd4:	c3                   	ret    

80102dd5 <inb>:
{
80102dd5:	55                   	push   %ebp
80102dd6:	89 e5                	mov    %esp,%ebp
80102dd8:	83 ec 14             	sub    $0x14,%esp
80102ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80102dde:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102de2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102de6:	89 c2                	mov    %eax,%edx
80102de8:	ec                   	in     (%dx),%al
80102de9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102df0:	c9                   	leave  
80102df1:	c3                   	ret    

80102df2 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102df2:	f3 0f 1e fb          	endbr32 
80102df6:	55                   	push   %ebp
80102df7:	89 e5                	mov    %esp,%ebp
80102df9:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102dfc:	6a 64                	push   $0x64
80102dfe:	e8 d2 ff ff ff       	call   80102dd5 <inb>
80102e03:	83 c4 04             	add    $0x4,%esp
80102e06:	0f b6 c0             	movzbl %al,%eax
80102e09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e0f:	83 e0 01             	and    $0x1,%eax
80102e12:	85 c0                	test   %eax,%eax
80102e14:	75 0a                	jne    80102e20 <kbdgetc+0x2e>
    return -1;
80102e16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e1b:	e9 23 01 00 00       	jmp    80102f43 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102e20:	6a 60                	push   $0x60
80102e22:	e8 ae ff ff ff       	call   80102dd5 <inb>
80102e27:	83 c4 04             	add    $0x4,%esp
80102e2a:	0f b6 c0             	movzbl %al,%eax
80102e2d:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e30:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e37:	75 17                	jne    80102e50 <kbdgetc+0x5e>
    shift |= E0ESC;
80102e39:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e3e:	83 c8 40             	or     $0x40,%eax
80102e41:	a3 9c 00 11 80       	mov    %eax,0x8011009c
    return 0;
80102e46:	b8 00 00 00 00       	mov    $0x0,%eax
80102e4b:	e9 f3 00 00 00       	jmp    80102f43 <kbdgetc+0x151>
  } else if(data & 0x80){
80102e50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e53:	25 80 00 00 00       	and    $0x80,%eax
80102e58:	85 c0                	test   %eax,%eax
80102e5a:	74 45                	je     80102ea1 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e5c:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e61:	83 e0 40             	and    $0x40,%eax
80102e64:	85 c0                	test   %eax,%eax
80102e66:	75 08                	jne    80102e70 <kbdgetc+0x7e>
80102e68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e6b:	83 e0 7f             	and    $0x7f,%eax
80102e6e:	eb 03                	jmp    80102e73 <kbdgetc+0x81>
80102e70:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e73:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e79:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102e7e:	0f b6 00             	movzbl (%eax),%eax
80102e81:	83 c8 40             	or     $0x40,%eax
80102e84:	0f b6 c0             	movzbl %al,%eax
80102e87:	f7 d0                	not    %eax
80102e89:	89 c2                	mov    %eax,%edx
80102e8b:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e90:	21 d0                	and    %edx,%eax
80102e92:	a3 9c 00 11 80       	mov    %eax,0x8011009c
    return 0;
80102e97:	b8 00 00 00 00       	mov    $0x0,%eax
80102e9c:	e9 a2 00 00 00       	jmp    80102f43 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102ea1:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102ea6:	83 e0 40             	and    $0x40,%eax
80102ea9:	85 c0                	test   %eax,%eax
80102eab:	74 14                	je     80102ec1 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102ead:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102eb4:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102eb9:	83 e0 bf             	and    $0xffffffbf,%eax
80102ebc:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  }

  shift |= shiftcode[data];
80102ec1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ec4:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102ec9:	0f b6 00             	movzbl (%eax),%eax
80102ecc:	0f b6 d0             	movzbl %al,%edx
80102ecf:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102ed4:	09 d0                	or     %edx,%eax
80102ed6:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  shift ^= togglecode[data];
80102edb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ede:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102ee3:	0f b6 00             	movzbl (%eax),%eax
80102ee6:	0f b6 d0             	movzbl %al,%edx
80102ee9:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102eee:	31 d0                	xor    %edx,%eax
80102ef0:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  c = charcode[shift & (CTL | SHIFT)][data];
80102ef5:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102efa:	83 e0 03             	and    $0x3,%eax
80102efd:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102f04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f07:	01 d0                	add    %edx,%eax
80102f09:	0f b6 00             	movzbl (%eax),%eax
80102f0c:	0f b6 c0             	movzbl %al,%eax
80102f0f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f12:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102f17:	83 e0 08             	and    $0x8,%eax
80102f1a:	85 c0                	test   %eax,%eax
80102f1c:	74 22                	je     80102f40 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102f1e:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f22:	76 0c                	jbe    80102f30 <kbdgetc+0x13e>
80102f24:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f28:	77 06                	ja     80102f30 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102f2a:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f2e:	eb 10                	jmp    80102f40 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102f30:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f34:	76 0a                	jbe    80102f40 <kbdgetc+0x14e>
80102f36:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f3a:	77 04                	ja     80102f40 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102f3c:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f40:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f43:	c9                   	leave  
80102f44:	c3                   	ret    

80102f45 <kbdintr>:

void
kbdintr(void)
{
80102f45:	f3 0f 1e fb          	endbr32 
80102f49:	55                   	push   %ebp
80102f4a:	89 e5                	mov    %esp,%ebp
80102f4c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102f4f:	83 ec 0c             	sub    $0xc,%esp
80102f52:	68 f2 2d 10 80       	push   $0x80102df2
80102f57:	e8 a4 d8 ff ff       	call   80100800 <consoleintr>
80102f5c:	83 c4 10             	add    $0x10,%esp
}
80102f5f:	90                   	nop
80102f60:	c9                   	leave  
80102f61:	c3                   	ret    

80102f62 <inb>:
{
80102f62:	55                   	push   %ebp
80102f63:	89 e5                	mov    %esp,%ebp
80102f65:	83 ec 14             	sub    $0x14,%esp
80102f68:	8b 45 08             	mov    0x8(%ebp),%eax
80102f6b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f6f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f73:	89 c2                	mov    %eax,%edx
80102f75:	ec                   	in     (%dx),%al
80102f76:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f79:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f7d:	c9                   	leave  
80102f7e:	c3                   	ret    

80102f7f <outb>:
{
80102f7f:	55                   	push   %ebp
80102f80:	89 e5                	mov    %esp,%ebp
80102f82:	83 ec 08             	sub    $0x8,%esp
80102f85:	8b 45 08             	mov    0x8(%ebp),%eax
80102f88:	8b 55 0c             	mov    0xc(%ebp),%edx
80102f8b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102f8f:	89 d0                	mov    %edx,%eax
80102f91:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f94:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f98:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f9c:	ee                   	out    %al,(%dx)
}
80102f9d:	90                   	nop
80102f9e:	c9                   	leave  
80102f9f:	c3                   	ret    

80102fa0 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102fa0:	f3 0f 1e fb          	endbr32 
80102fa4:	55                   	push   %ebp
80102fa5:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fa7:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fac:	8b 55 08             	mov    0x8(%ebp),%edx
80102faf:	c1 e2 02             	shl    $0x2,%edx
80102fb2:	01 c2                	add    %eax,%edx
80102fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fb7:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102fb9:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fbe:	83 c0 20             	add    $0x20,%eax
80102fc1:	8b 00                	mov    (%eax),%eax
}
80102fc3:	90                   	nop
80102fc4:	5d                   	pop    %ebp
80102fc5:	c3                   	ret    

80102fc6 <lapicinit>:

void
lapicinit(void)
{
80102fc6:	f3 0f 1e fb          	endbr32 
80102fca:	55                   	push   %ebp
80102fcb:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102fcd:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fd2:	85 c0                	test   %eax,%eax
80102fd4:	0f 84 0c 01 00 00    	je     801030e6 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102fda:	68 3f 01 00 00       	push   $0x13f
80102fdf:	6a 3c                	push   $0x3c
80102fe1:	e8 ba ff ff ff       	call   80102fa0 <lapicw>
80102fe6:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102fe9:	6a 0b                	push   $0xb
80102feb:	68 f8 00 00 00       	push   $0xf8
80102ff0:	e8 ab ff ff ff       	call   80102fa0 <lapicw>
80102ff5:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ff8:	68 20 00 02 00       	push   $0x20020
80102ffd:	68 c8 00 00 00       	push   $0xc8
80103002:	e8 99 ff ff ff       	call   80102fa0 <lapicw>
80103007:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
8010300a:	68 80 96 98 00       	push   $0x989680
8010300f:	68 e0 00 00 00       	push   $0xe0
80103014:	e8 87 ff ff ff       	call   80102fa0 <lapicw>
80103019:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010301c:	68 00 00 01 00       	push   $0x10000
80103021:	68 d4 00 00 00       	push   $0xd4
80103026:	e8 75 ff ff ff       	call   80102fa0 <lapicw>
8010302b:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
8010302e:	68 00 00 01 00       	push   $0x10000
80103033:	68 d8 00 00 00       	push   $0xd8
80103038:	e8 63 ff ff ff       	call   80102fa0 <lapicw>
8010303d:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103040:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103045:	83 c0 30             	add    $0x30,%eax
80103048:	8b 00                	mov    (%eax),%eax
8010304a:	c1 e8 10             	shr    $0x10,%eax
8010304d:	25 fc 00 00 00       	and    $0xfc,%eax
80103052:	85 c0                	test   %eax,%eax
80103054:	74 12                	je     80103068 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80103056:	68 00 00 01 00       	push   $0x10000
8010305b:	68 d0 00 00 00       	push   $0xd0
80103060:	e8 3b ff ff ff       	call   80102fa0 <lapicw>
80103065:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103068:	6a 33                	push   $0x33
8010306a:	68 dc 00 00 00       	push   $0xdc
8010306f:	e8 2c ff ff ff       	call   80102fa0 <lapicw>
80103074:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103077:	6a 00                	push   $0x0
80103079:	68 a0 00 00 00       	push   $0xa0
8010307e:	e8 1d ff ff ff       	call   80102fa0 <lapicw>
80103083:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103086:	6a 00                	push   $0x0
80103088:	68 a0 00 00 00       	push   $0xa0
8010308d:	e8 0e ff ff ff       	call   80102fa0 <lapicw>
80103092:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103095:	6a 00                	push   $0x0
80103097:	6a 2c                	push   $0x2c
80103099:	e8 02 ff ff ff       	call   80102fa0 <lapicw>
8010309e:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801030a1:	6a 00                	push   $0x0
801030a3:	68 c4 00 00 00       	push   $0xc4
801030a8:	e8 f3 fe ff ff       	call   80102fa0 <lapicw>
801030ad:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801030b0:	68 00 85 08 00       	push   $0x88500
801030b5:	68 c0 00 00 00       	push   $0xc0
801030ba:	e8 e1 fe ff ff       	call   80102fa0 <lapicw>
801030bf:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801030c2:	90                   	nop
801030c3:	a1 5c 84 11 80       	mov    0x8011845c,%eax
801030c8:	05 00 03 00 00       	add    $0x300,%eax
801030cd:	8b 00                	mov    (%eax),%eax
801030cf:	25 00 10 00 00       	and    $0x1000,%eax
801030d4:	85 c0                	test   %eax,%eax
801030d6:	75 eb                	jne    801030c3 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801030d8:	6a 00                	push   $0x0
801030da:	6a 20                	push   $0x20
801030dc:	e8 bf fe ff ff       	call   80102fa0 <lapicw>
801030e1:	83 c4 08             	add    $0x8,%esp
801030e4:	eb 01                	jmp    801030e7 <lapicinit+0x121>
    return;
801030e6:	90                   	nop
}
801030e7:	c9                   	leave  
801030e8:	c3                   	ret    

801030e9 <lapicid>:

int
lapicid(void)
{
801030e9:	f3 0f 1e fb          	endbr32 
801030ed:	55                   	push   %ebp
801030ee:	89 e5                	mov    %esp,%ebp

  if (!lapic){
801030f0:	a1 5c 84 11 80       	mov    0x8011845c,%eax
801030f5:	85 c0                	test   %eax,%eax
801030f7:	75 07                	jne    80103100 <lapicid+0x17>
    return 0;
801030f9:	b8 00 00 00 00       	mov    $0x0,%eax
801030fe:	eb 0d                	jmp    8010310d <lapicid+0x24>
  }
  return lapic[ID] >> 24;
80103100:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103105:	83 c0 20             	add    $0x20,%eax
80103108:	8b 00                	mov    (%eax),%eax
8010310a:	c1 e8 18             	shr    $0x18,%eax
}
8010310d:	5d                   	pop    %ebp
8010310e:	c3                   	ret    

8010310f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010310f:	f3 0f 1e fb          	endbr32 
80103113:	55                   	push   %ebp
80103114:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103116:	a1 5c 84 11 80       	mov    0x8011845c,%eax
8010311b:	85 c0                	test   %eax,%eax
8010311d:	74 0c                	je     8010312b <lapiceoi+0x1c>
    lapicw(EOI, 0);
8010311f:	6a 00                	push   $0x0
80103121:	6a 2c                	push   $0x2c
80103123:	e8 78 fe ff ff       	call   80102fa0 <lapicw>
80103128:	83 c4 08             	add    $0x8,%esp
}
8010312b:	90                   	nop
8010312c:	c9                   	leave  
8010312d:	c3                   	ret    

8010312e <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010312e:	f3 0f 1e fb          	endbr32 
80103132:	55                   	push   %ebp
80103133:	89 e5                	mov    %esp,%ebp
}
80103135:	90                   	nop
80103136:	5d                   	pop    %ebp
80103137:	c3                   	ret    

80103138 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103138:	f3 0f 1e fb          	endbr32 
8010313c:	55                   	push   %ebp
8010313d:	89 e5                	mov    %esp,%ebp
8010313f:	83 ec 14             	sub    $0x14,%esp
80103142:	8b 45 08             	mov    0x8(%ebp),%eax
80103145:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103148:	6a 0f                	push   $0xf
8010314a:	6a 70                	push   $0x70
8010314c:	e8 2e fe ff ff       	call   80102f7f <outb>
80103151:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103154:	6a 0a                	push   $0xa
80103156:	6a 71                	push   $0x71
80103158:	e8 22 fe ff ff       	call   80102f7f <outb>
8010315d:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103160:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103167:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010316a:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010316f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103172:	c1 e8 04             	shr    $0x4,%eax
80103175:	89 c2                	mov    %eax,%edx
80103177:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010317a:	83 c0 02             	add    $0x2,%eax
8010317d:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103180:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103184:	c1 e0 18             	shl    $0x18,%eax
80103187:	50                   	push   %eax
80103188:	68 c4 00 00 00       	push   $0xc4
8010318d:	e8 0e fe ff ff       	call   80102fa0 <lapicw>
80103192:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103195:	68 00 c5 00 00       	push   $0xc500
8010319a:	68 c0 00 00 00       	push   $0xc0
8010319f:	e8 fc fd ff ff       	call   80102fa0 <lapicw>
801031a4:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031a7:	68 c8 00 00 00       	push   $0xc8
801031ac:	e8 7d ff ff ff       	call   8010312e <microdelay>
801031b1:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801031b4:	68 00 85 00 00       	push   $0x8500
801031b9:	68 c0 00 00 00       	push   $0xc0
801031be:	e8 dd fd ff ff       	call   80102fa0 <lapicw>
801031c3:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031c6:	6a 64                	push   $0x64
801031c8:	e8 61 ff ff ff       	call   8010312e <microdelay>
801031cd:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031d0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801031d7:	eb 3d                	jmp    80103216 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801031d9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031dd:	c1 e0 18             	shl    $0x18,%eax
801031e0:	50                   	push   %eax
801031e1:	68 c4 00 00 00       	push   $0xc4
801031e6:	e8 b5 fd ff ff       	call   80102fa0 <lapicw>
801031eb:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801031ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801031f1:	c1 e8 0c             	shr    $0xc,%eax
801031f4:	80 cc 06             	or     $0x6,%ah
801031f7:	50                   	push   %eax
801031f8:	68 c0 00 00 00       	push   $0xc0
801031fd:	e8 9e fd ff ff       	call   80102fa0 <lapicw>
80103202:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103205:	68 c8 00 00 00       	push   $0xc8
8010320a:	e8 1f ff ff ff       	call   8010312e <microdelay>
8010320f:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103212:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103216:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010321a:	7e bd                	jle    801031d9 <lapicstartap+0xa1>
  }
}
8010321c:	90                   	nop
8010321d:	90                   	nop
8010321e:	c9                   	leave  
8010321f:	c3                   	ret    

80103220 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103220:	f3 0f 1e fb          	endbr32 
80103224:	55                   	push   %ebp
80103225:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103227:	8b 45 08             	mov    0x8(%ebp),%eax
8010322a:	0f b6 c0             	movzbl %al,%eax
8010322d:	50                   	push   %eax
8010322e:	6a 70                	push   $0x70
80103230:	e8 4a fd ff ff       	call   80102f7f <outb>
80103235:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103238:	68 c8 00 00 00       	push   $0xc8
8010323d:	e8 ec fe ff ff       	call   8010312e <microdelay>
80103242:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103245:	6a 71                	push   $0x71
80103247:	e8 16 fd ff ff       	call   80102f62 <inb>
8010324c:	83 c4 04             	add    $0x4,%esp
8010324f:	0f b6 c0             	movzbl %al,%eax
}
80103252:	c9                   	leave  
80103253:	c3                   	ret    

80103254 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103254:	f3 0f 1e fb          	endbr32 
80103258:	55                   	push   %ebp
80103259:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010325b:	6a 00                	push   $0x0
8010325d:	e8 be ff ff ff       	call   80103220 <cmos_read>
80103262:	83 c4 04             	add    $0x4,%esp
80103265:	8b 55 08             	mov    0x8(%ebp),%edx
80103268:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010326a:	6a 02                	push   $0x2
8010326c:	e8 af ff ff ff       	call   80103220 <cmos_read>
80103271:	83 c4 04             	add    $0x4,%esp
80103274:	8b 55 08             	mov    0x8(%ebp),%edx
80103277:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010327a:	6a 04                	push   $0x4
8010327c:	e8 9f ff ff ff       	call   80103220 <cmos_read>
80103281:	83 c4 04             	add    $0x4,%esp
80103284:	8b 55 08             	mov    0x8(%ebp),%edx
80103287:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010328a:	6a 07                	push   $0x7
8010328c:	e8 8f ff ff ff       	call   80103220 <cmos_read>
80103291:	83 c4 04             	add    $0x4,%esp
80103294:	8b 55 08             	mov    0x8(%ebp),%edx
80103297:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010329a:	6a 08                	push   $0x8
8010329c:	e8 7f ff ff ff       	call   80103220 <cmos_read>
801032a1:	83 c4 04             	add    $0x4,%esp
801032a4:	8b 55 08             	mov    0x8(%ebp),%edx
801032a7:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801032aa:	6a 09                	push   $0x9
801032ac:	e8 6f ff ff ff       	call   80103220 <cmos_read>
801032b1:	83 c4 04             	add    $0x4,%esp
801032b4:	8b 55 08             	mov    0x8(%ebp),%edx
801032b7:	89 42 14             	mov    %eax,0x14(%edx)
}
801032ba:	90                   	nop
801032bb:	c9                   	leave  
801032bc:	c3                   	ret    

801032bd <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801032bd:	f3 0f 1e fb          	endbr32 
801032c1:	55                   	push   %ebp
801032c2:	89 e5                	mov    %esp,%ebp
801032c4:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801032c7:	6a 0b                	push   $0xb
801032c9:	e8 52 ff ff ff       	call   80103220 <cmos_read>
801032ce:	83 c4 04             	add    $0x4,%esp
801032d1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801032d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d7:	83 e0 04             	and    $0x4,%eax
801032da:	85 c0                	test   %eax,%eax
801032dc:	0f 94 c0             	sete   %al
801032df:	0f b6 c0             	movzbl %al,%eax
801032e2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801032e5:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032e8:	50                   	push   %eax
801032e9:	e8 66 ff ff ff       	call   80103254 <fill_rtcdate>
801032ee:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801032f1:	6a 0a                	push   $0xa
801032f3:	e8 28 ff ff ff       	call   80103220 <cmos_read>
801032f8:	83 c4 04             	add    $0x4,%esp
801032fb:	25 80 00 00 00       	and    $0x80,%eax
80103300:	85 c0                	test   %eax,%eax
80103302:	75 27                	jne    8010332b <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80103304:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103307:	50                   	push   %eax
80103308:	e8 47 ff ff ff       	call   80103254 <fill_rtcdate>
8010330d:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103310:	83 ec 04             	sub    $0x4,%esp
80103313:	6a 18                	push   $0x18
80103315:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103318:	50                   	push   %eax
80103319:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010331c:	50                   	push   %eax
8010331d:	e8 be 21 00 00       	call   801054e0 <memcmp>
80103322:	83 c4 10             	add    $0x10,%esp
80103325:	85 c0                	test   %eax,%eax
80103327:	74 05                	je     8010332e <cmostime+0x71>
80103329:	eb ba                	jmp    801032e5 <cmostime+0x28>
        continue;
8010332b:	90                   	nop
    fill_rtcdate(&t1);
8010332c:	eb b7                	jmp    801032e5 <cmostime+0x28>
      break;
8010332e:	90                   	nop
  }

  // convert
  if(bcd) {
8010332f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103333:	0f 84 b4 00 00 00    	je     801033ed <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103339:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010333c:	c1 e8 04             	shr    $0x4,%eax
8010333f:	89 c2                	mov    %eax,%edx
80103341:	89 d0                	mov    %edx,%eax
80103343:	c1 e0 02             	shl    $0x2,%eax
80103346:	01 d0                	add    %edx,%eax
80103348:	01 c0                	add    %eax,%eax
8010334a:	89 c2                	mov    %eax,%edx
8010334c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010334f:	83 e0 0f             	and    $0xf,%eax
80103352:	01 d0                	add    %edx,%eax
80103354:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103357:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010335a:	c1 e8 04             	shr    $0x4,%eax
8010335d:	89 c2                	mov    %eax,%edx
8010335f:	89 d0                	mov    %edx,%eax
80103361:	c1 e0 02             	shl    $0x2,%eax
80103364:	01 d0                	add    %edx,%eax
80103366:	01 c0                	add    %eax,%eax
80103368:	89 c2                	mov    %eax,%edx
8010336a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010336d:	83 e0 0f             	and    $0xf,%eax
80103370:	01 d0                	add    %edx,%eax
80103372:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103375:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103378:	c1 e8 04             	shr    $0x4,%eax
8010337b:	89 c2                	mov    %eax,%edx
8010337d:	89 d0                	mov    %edx,%eax
8010337f:	c1 e0 02             	shl    $0x2,%eax
80103382:	01 d0                	add    %edx,%eax
80103384:	01 c0                	add    %eax,%eax
80103386:	89 c2                	mov    %eax,%edx
80103388:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010338b:	83 e0 0f             	and    $0xf,%eax
8010338e:	01 d0                	add    %edx,%eax
80103390:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103393:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103396:	c1 e8 04             	shr    $0x4,%eax
80103399:	89 c2                	mov    %eax,%edx
8010339b:	89 d0                	mov    %edx,%eax
8010339d:	c1 e0 02             	shl    $0x2,%eax
801033a0:	01 d0                	add    %edx,%eax
801033a2:	01 c0                	add    %eax,%eax
801033a4:	89 c2                	mov    %eax,%edx
801033a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033a9:	83 e0 0f             	and    $0xf,%eax
801033ac:	01 d0                	add    %edx,%eax
801033ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801033b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033b4:	c1 e8 04             	shr    $0x4,%eax
801033b7:	89 c2                	mov    %eax,%edx
801033b9:	89 d0                	mov    %edx,%eax
801033bb:	c1 e0 02             	shl    $0x2,%eax
801033be:	01 d0                	add    %edx,%eax
801033c0:	01 c0                	add    %eax,%eax
801033c2:	89 c2                	mov    %eax,%edx
801033c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033c7:	83 e0 0f             	and    $0xf,%eax
801033ca:	01 d0                	add    %edx,%eax
801033cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801033cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d2:	c1 e8 04             	shr    $0x4,%eax
801033d5:	89 c2                	mov    %eax,%edx
801033d7:	89 d0                	mov    %edx,%eax
801033d9:	c1 e0 02             	shl    $0x2,%eax
801033dc:	01 d0                	add    %edx,%eax
801033de:	01 c0                	add    %eax,%eax
801033e0:	89 c2                	mov    %eax,%edx
801033e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e5:	83 e0 0f             	and    $0xf,%eax
801033e8:	01 d0                	add    %edx,%eax
801033ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801033ed:	8b 45 08             	mov    0x8(%ebp),%eax
801033f0:	8b 55 d8             	mov    -0x28(%ebp),%edx
801033f3:	89 10                	mov    %edx,(%eax)
801033f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
801033f8:	89 50 04             	mov    %edx,0x4(%eax)
801033fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
801033fe:	89 50 08             	mov    %edx,0x8(%eax)
80103401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103404:	89 50 0c             	mov    %edx,0xc(%eax)
80103407:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010340a:	89 50 10             	mov    %edx,0x10(%eax)
8010340d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103410:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103413:	8b 45 08             	mov    0x8(%ebp),%eax
80103416:	8b 40 14             	mov    0x14(%eax),%eax
80103419:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010341f:	8b 45 08             	mov    0x8(%ebp),%eax
80103422:	89 50 14             	mov    %edx,0x14(%eax)
}
80103425:	90                   	nop
80103426:	c9                   	leave  
80103427:	c3                   	ret    

80103428 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103428:	f3 0f 1e fb          	endbr32 
8010342c:	55                   	push   %ebp
8010342d:	89 e5                	mov    %esp,%ebp
8010342f:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103432:	83 ec 08             	sub    $0x8,%esp
80103435:	68 f5 af 10 80       	push   $0x8010aff5
8010343a:	68 60 84 11 80       	push   $0x80118460
8010343f:	e8 7c 1d 00 00       	call   801051c0 <initlock>
80103444:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103447:	83 ec 08             	sub    $0x8,%esp
8010344a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010344d:	50                   	push   %eax
8010344e:	ff 75 08             	pushl  0x8(%ebp)
80103451:	e8 c8 df ff ff       	call   8010141e <readsb>
80103456:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103459:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345c:	a3 94 84 11 80       	mov    %eax,0x80118494
  log.size = sb.nlog;
80103461:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103464:	a3 98 84 11 80       	mov    %eax,0x80118498
  log.dev = dev;
80103469:	8b 45 08             	mov    0x8(%ebp),%eax
8010346c:	a3 a4 84 11 80       	mov    %eax,0x801184a4
  recover_from_log();
80103471:	e8 bf 01 00 00       	call   80103635 <recover_from_log>
}
80103476:	90                   	nop
80103477:	c9                   	leave  
80103478:	c3                   	ret    

80103479 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103479:	f3 0f 1e fb          	endbr32 
8010347d:	55                   	push   %ebp
8010347e:	89 e5                	mov    %esp,%ebp
80103480:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103483:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010348a:	e9 95 00 00 00       	jmp    80103524 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010348f:	8b 15 94 84 11 80    	mov    0x80118494,%edx
80103495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103498:	01 d0                	add    %edx,%eax
8010349a:	83 c0 01             	add    $0x1,%eax
8010349d:	89 c2                	mov    %eax,%edx
8010349f:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801034a4:	83 ec 08             	sub    $0x8,%esp
801034a7:	52                   	push   %edx
801034a8:	50                   	push   %eax
801034a9:	e8 5b cd ff ff       	call   80100209 <bread>
801034ae:	83 c4 10             	add    $0x10,%esp
801034b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801034b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034b7:	83 c0 10             	add    $0x10,%eax
801034ba:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
801034c1:	89 c2                	mov    %eax,%edx
801034c3:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801034c8:	83 ec 08             	sub    $0x8,%esp
801034cb:	52                   	push   %edx
801034cc:	50                   	push   %eax
801034cd:	e8 37 cd ff ff       	call   80100209 <bread>
801034d2:	83 c4 10             	add    $0x10,%esp
801034d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801034d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034db:	8d 50 5c             	lea    0x5c(%eax),%edx
801034de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e1:	83 c0 5c             	add    $0x5c,%eax
801034e4:	83 ec 04             	sub    $0x4,%esp
801034e7:	68 00 02 00 00       	push   $0x200
801034ec:	52                   	push   %edx
801034ed:	50                   	push   %eax
801034ee:	e8 49 20 00 00       	call   8010553c <memmove>
801034f3:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801034f6:	83 ec 0c             	sub    $0xc,%esp
801034f9:	ff 75 ec             	pushl  -0x14(%ebp)
801034fc:	e8 45 cd ff ff       	call   80100246 <bwrite>
80103501:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103504:	83 ec 0c             	sub    $0xc,%esp
80103507:	ff 75 f0             	pushl  -0x10(%ebp)
8010350a:	e8 84 cd ff ff       	call   80100293 <brelse>
8010350f:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103512:	83 ec 0c             	sub    $0xc,%esp
80103515:	ff 75 ec             	pushl  -0x14(%ebp)
80103518:	e8 76 cd ff ff       	call   80100293 <brelse>
8010351d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103520:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103524:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103529:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010352c:	0f 8c 5d ff ff ff    	jl     8010348f <install_trans+0x16>
  }
}
80103532:	90                   	nop
80103533:	90                   	nop
80103534:	c9                   	leave  
80103535:	c3                   	ret    

80103536 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103536:	f3 0f 1e fb          	endbr32 
8010353a:	55                   	push   %ebp
8010353b:	89 e5                	mov    %esp,%ebp
8010353d:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103540:	a1 94 84 11 80       	mov    0x80118494,%eax
80103545:	89 c2                	mov    %eax,%edx
80103547:	a1 a4 84 11 80       	mov    0x801184a4,%eax
8010354c:	83 ec 08             	sub    $0x8,%esp
8010354f:	52                   	push   %edx
80103550:	50                   	push   %eax
80103551:	e8 b3 cc ff ff       	call   80100209 <bread>
80103556:	83 c4 10             	add    $0x10,%esp
80103559:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010355c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010355f:	83 c0 5c             	add    $0x5c,%eax
80103562:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103565:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103568:	8b 00                	mov    (%eax),%eax
8010356a:	a3 a8 84 11 80       	mov    %eax,0x801184a8
  for (i = 0; i < log.lh.n; i++) {
8010356f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103576:	eb 1b                	jmp    80103593 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
80103578:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010357b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010357e:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103582:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103585:	83 c2 10             	add    $0x10,%edx
80103588:	89 04 95 6c 84 11 80 	mov    %eax,-0x7fee7b94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010358f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103593:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103598:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010359b:	7c db                	jl     80103578 <read_head+0x42>
  }
  brelse(buf);
8010359d:	83 ec 0c             	sub    $0xc,%esp
801035a0:	ff 75 f0             	pushl  -0x10(%ebp)
801035a3:	e8 eb cc ff ff       	call   80100293 <brelse>
801035a8:	83 c4 10             	add    $0x10,%esp
}
801035ab:	90                   	nop
801035ac:	c9                   	leave  
801035ad:	c3                   	ret    

801035ae <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801035ae:	f3 0f 1e fb          	endbr32 
801035b2:	55                   	push   %ebp
801035b3:	89 e5                	mov    %esp,%ebp
801035b5:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035b8:	a1 94 84 11 80       	mov    0x80118494,%eax
801035bd:	89 c2                	mov    %eax,%edx
801035bf:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801035c4:	83 ec 08             	sub    $0x8,%esp
801035c7:	52                   	push   %edx
801035c8:	50                   	push   %eax
801035c9:	e8 3b cc ff ff       	call   80100209 <bread>
801035ce:	83 c4 10             	add    $0x10,%esp
801035d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801035d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d7:	83 c0 5c             	add    $0x5c,%eax
801035da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801035dd:	8b 15 a8 84 11 80    	mov    0x801184a8,%edx
801035e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035e6:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801035e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035ef:	eb 1b                	jmp    8010360c <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801035f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f4:	83 c0 10             	add    $0x10,%eax
801035f7:	8b 0c 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%ecx
801035fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103601:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103604:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103608:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010360c:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103611:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103614:	7c db                	jl     801035f1 <write_head+0x43>
  }
  bwrite(buf);
80103616:	83 ec 0c             	sub    $0xc,%esp
80103619:	ff 75 f0             	pushl  -0x10(%ebp)
8010361c:	e8 25 cc ff ff       	call   80100246 <bwrite>
80103621:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103624:	83 ec 0c             	sub    $0xc,%esp
80103627:	ff 75 f0             	pushl  -0x10(%ebp)
8010362a:	e8 64 cc ff ff       	call   80100293 <brelse>
8010362f:	83 c4 10             	add    $0x10,%esp
}
80103632:	90                   	nop
80103633:	c9                   	leave  
80103634:	c3                   	ret    

80103635 <recover_from_log>:

static void
recover_from_log(void)
{
80103635:	f3 0f 1e fb          	endbr32 
80103639:	55                   	push   %ebp
8010363a:	89 e5                	mov    %esp,%ebp
8010363c:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010363f:	e8 f2 fe ff ff       	call   80103536 <read_head>
  install_trans(); // if committed, copy from log to disk
80103644:	e8 30 fe ff ff       	call   80103479 <install_trans>
  log.lh.n = 0;
80103649:	c7 05 a8 84 11 80 00 	movl   $0x0,0x801184a8
80103650:	00 00 00 
  write_head(); // clear the log
80103653:	e8 56 ff ff ff       	call   801035ae <write_head>
}
80103658:	90                   	nop
80103659:	c9                   	leave  
8010365a:	c3                   	ret    

8010365b <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010365b:	f3 0f 1e fb          	endbr32 
8010365f:	55                   	push   %ebp
80103660:	89 e5                	mov    %esp,%ebp
80103662:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103665:	83 ec 0c             	sub    $0xc,%esp
80103668:	68 60 84 11 80       	push   $0x80118460
8010366d:	e8 74 1b 00 00       	call   801051e6 <acquire>
80103672:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103675:	a1 a0 84 11 80       	mov    0x801184a0,%eax
8010367a:	85 c0                	test   %eax,%eax
8010367c:	74 17                	je     80103695 <begin_op+0x3a>
      sleep(&log, &log.lock);
8010367e:	83 ec 08             	sub    $0x8,%esp
80103681:	68 60 84 11 80       	push   $0x80118460
80103686:	68 60 84 11 80       	push   $0x80118460
8010368b:	e8 ac 15 00 00       	call   80104c3c <sleep>
80103690:	83 c4 10             	add    $0x10,%esp
80103693:	eb e0                	jmp    80103675 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103695:	8b 0d a8 84 11 80    	mov    0x801184a8,%ecx
8010369b:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801036a0:	8d 50 01             	lea    0x1(%eax),%edx
801036a3:	89 d0                	mov    %edx,%eax
801036a5:	c1 e0 02             	shl    $0x2,%eax
801036a8:	01 d0                	add    %edx,%eax
801036aa:	01 c0                	add    %eax,%eax
801036ac:	01 c8                	add    %ecx,%eax
801036ae:	83 f8 1e             	cmp    $0x1e,%eax
801036b1:	7e 17                	jle    801036ca <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801036b3:	83 ec 08             	sub    $0x8,%esp
801036b6:	68 60 84 11 80       	push   $0x80118460
801036bb:	68 60 84 11 80       	push   $0x80118460
801036c0:	e8 77 15 00 00       	call   80104c3c <sleep>
801036c5:	83 c4 10             	add    $0x10,%esp
801036c8:	eb ab                	jmp    80103675 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801036ca:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801036cf:	83 c0 01             	add    $0x1,%eax
801036d2:	a3 9c 84 11 80       	mov    %eax,0x8011849c
      release(&log.lock);
801036d7:	83 ec 0c             	sub    $0xc,%esp
801036da:	68 60 84 11 80       	push   $0x80118460
801036df:	e8 74 1b 00 00       	call   80105258 <release>
801036e4:	83 c4 10             	add    $0x10,%esp
      break;
801036e7:	90                   	nop
    }
  }
}
801036e8:	90                   	nop
801036e9:	c9                   	leave  
801036ea:	c3                   	ret    

801036eb <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801036eb:	f3 0f 1e fb          	endbr32 
801036ef:	55                   	push   %ebp
801036f0:	89 e5                	mov    %esp,%ebp
801036f2:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801036f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801036fc:	83 ec 0c             	sub    $0xc,%esp
801036ff:	68 60 84 11 80       	push   $0x80118460
80103704:	e8 dd 1a 00 00       	call   801051e6 <acquire>
80103709:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010370c:	a1 9c 84 11 80       	mov    0x8011849c,%eax
80103711:	83 e8 01             	sub    $0x1,%eax
80103714:	a3 9c 84 11 80       	mov    %eax,0x8011849c
  if(log.committing)
80103719:	a1 a0 84 11 80       	mov    0x801184a0,%eax
8010371e:	85 c0                	test   %eax,%eax
80103720:	74 0d                	je     8010372f <end_op+0x44>
    panic("log.committing");
80103722:	83 ec 0c             	sub    $0xc,%esp
80103725:	68 f9 af 10 80       	push   $0x8010aff9
8010372a:	e8 96 ce ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
8010372f:	a1 9c 84 11 80       	mov    0x8011849c,%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 13                	jne    8010374b <end_op+0x60>
    do_commit = 1;
80103738:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010373f:	c7 05 a0 84 11 80 01 	movl   $0x1,0x801184a0
80103746:	00 00 00 
80103749:	eb 10                	jmp    8010375b <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010374b:	83 ec 0c             	sub    $0xc,%esp
8010374e:	68 60 84 11 80       	push   $0x80118460
80103753:	e8 d6 15 00 00       	call   80104d2e <wakeup>
80103758:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010375b:	83 ec 0c             	sub    $0xc,%esp
8010375e:	68 60 84 11 80       	push   $0x80118460
80103763:	e8 f0 1a 00 00       	call   80105258 <release>
80103768:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010376b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010376f:	74 3f                	je     801037b0 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103771:	e8 fa 00 00 00       	call   80103870 <commit>
    acquire(&log.lock);
80103776:	83 ec 0c             	sub    $0xc,%esp
80103779:	68 60 84 11 80       	push   $0x80118460
8010377e:	e8 63 1a 00 00       	call   801051e6 <acquire>
80103783:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103786:	c7 05 a0 84 11 80 00 	movl   $0x0,0x801184a0
8010378d:	00 00 00 
    wakeup(&log);
80103790:	83 ec 0c             	sub    $0xc,%esp
80103793:	68 60 84 11 80       	push   $0x80118460
80103798:	e8 91 15 00 00       	call   80104d2e <wakeup>
8010379d:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801037a0:	83 ec 0c             	sub    $0xc,%esp
801037a3:	68 60 84 11 80       	push   $0x80118460
801037a8:	e8 ab 1a 00 00       	call   80105258 <release>
801037ad:	83 c4 10             	add    $0x10,%esp
  }
}
801037b0:	90                   	nop
801037b1:	c9                   	leave  
801037b2:	c3                   	ret    

801037b3 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801037b3:	f3 0f 1e fb          	endbr32 
801037b7:	55                   	push   %ebp
801037b8:	89 e5                	mov    %esp,%ebp
801037ba:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037c4:	e9 95 00 00 00       	jmp    8010385e <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801037c9:	8b 15 94 84 11 80    	mov    0x80118494,%edx
801037cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037d2:	01 d0                	add    %edx,%eax
801037d4:	83 c0 01             	add    $0x1,%eax
801037d7:	89 c2                	mov    %eax,%edx
801037d9:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	52                   	push   %edx
801037e2:	50                   	push   %eax
801037e3:	e8 21 ca ff ff       	call   80100209 <bread>
801037e8:	83 c4 10             	add    $0x10,%esp
801037eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801037ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037f1:	83 c0 10             	add    $0x10,%eax
801037f4:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
801037fb:	89 c2                	mov    %eax,%edx
801037fd:	a1 a4 84 11 80       	mov    0x801184a4,%eax
80103802:	83 ec 08             	sub    $0x8,%esp
80103805:	52                   	push   %edx
80103806:	50                   	push   %eax
80103807:	e8 fd c9 ff ff       	call   80100209 <bread>
8010380c:	83 c4 10             	add    $0x10,%esp
8010380f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103812:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103815:	8d 50 5c             	lea    0x5c(%eax),%edx
80103818:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010381b:	83 c0 5c             	add    $0x5c,%eax
8010381e:	83 ec 04             	sub    $0x4,%esp
80103821:	68 00 02 00 00       	push   $0x200
80103826:	52                   	push   %edx
80103827:	50                   	push   %eax
80103828:	e8 0f 1d 00 00       	call   8010553c <memmove>
8010382d:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103830:	83 ec 0c             	sub    $0xc,%esp
80103833:	ff 75 f0             	pushl  -0x10(%ebp)
80103836:	e8 0b ca ff ff       	call   80100246 <bwrite>
8010383b:	83 c4 10             	add    $0x10,%esp
    brelse(from);
8010383e:	83 ec 0c             	sub    $0xc,%esp
80103841:	ff 75 ec             	pushl  -0x14(%ebp)
80103844:	e8 4a ca ff ff       	call   80100293 <brelse>
80103849:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010384c:	83 ec 0c             	sub    $0xc,%esp
8010384f:	ff 75 f0             	pushl  -0x10(%ebp)
80103852:	e8 3c ca ff ff       	call   80100293 <brelse>
80103857:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010385a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010385e:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103863:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103866:	0f 8c 5d ff ff ff    	jl     801037c9 <write_log+0x16>
  }
}
8010386c:	90                   	nop
8010386d:	90                   	nop
8010386e:	c9                   	leave  
8010386f:	c3                   	ret    

80103870 <commit>:

static void
commit()
{
80103870:	f3 0f 1e fb          	endbr32 
80103874:	55                   	push   %ebp
80103875:	89 e5                	mov    %esp,%ebp
80103877:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010387a:	a1 a8 84 11 80       	mov    0x801184a8,%eax
8010387f:	85 c0                	test   %eax,%eax
80103881:	7e 1e                	jle    801038a1 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103883:	e8 2b ff ff ff       	call   801037b3 <write_log>
    write_head();    // Write header to disk -- the real commit
80103888:	e8 21 fd ff ff       	call   801035ae <write_head>
    install_trans(); // Now install writes to home locations
8010388d:	e8 e7 fb ff ff       	call   80103479 <install_trans>
    log.lh.n = 0;
80103892:	c7 05 a8 84 11 80 00 	movl   $0x0,0x801184a8
80103899:	00 00 00 
    write_head();    // Erase the transaction from the log
8010389c:	e8 0d fd ff ff       	call   801035ae <write_head>
  }
}
801038a1:	90                   	nop
801038a2:	c9                   	leave  
801038a3:	c3                   	ret    

801038a4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801038a4:	f3 0f 1e fb          	endbr32 
801038a8:	55                   	push   %ebp
801038a9:	89 e5                	mov    %esp,%ebp
801038ab:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801038ae:	a1 a8 84 11 80       	mov    0x801184a8,%eax
801038b3:	83 f8 1d             	cmp    $0x1d,%eax
801038b6:	7f 12                	jg     801038ca <log_write+0x26>
801038b8:	a1 a8 84 11 80       	mov    0x801184a8,%eax
801038bd:	8b 15 98 84 11 80    	mov    0x80118498,%edx
801038c3:	83 ea 01             	sub    $0x1,%edx
801038c6:	39 d0                	cmp    %edx,%eax
801038c8:	7c 0d                	jl     801038d7 <log_write+0x33>
    panic("too big a transaction");
801038ca:	83 ec 0c             	sub    $0xc,%esp
801038cd:	68 08 b0 10 80       	push   $0x8010b008
801038d2:	e8 ee cc ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801038d7:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801038dc:	85 c0                	test   %eax,%eax
801038de:	7f 0d                	jg     801038ed <log_write+0x49>
    panic("log_write outside of trans");
801038e0:	83 ec 0c             	sub    $0xc,%esp
801038e3:	68 1e b0 10 80       	push   $0x8010b01e
801038e8:	e8 d8 cc ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
801038ed:	83 ec 0c             	sub    $0xc,%esp
801038f0:	68 60 84 11 80       	push   $0x80118460
801038f5:	e8 ec 18 00 00       	call   801051e6 <acquire>
801038fa:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801038fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103904:	eb 1d                	jmp    80103923 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103909:	83 c0 10             	add    $0x10,%eax
8010390c:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
80103913:	89 c2                	mov    %eax,%edx
80103915:	8b 45 08             	mov    0x8(%ebp),%eax
80103918:	8b 40 08             	mov    0x8(%eax),%eax
8010391b:	39 c2                	cmp    %eax,%edx
8010391d:	74 10                	je     8010392f <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
8010391f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103923:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103928:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010392b:	7c d9                	jl     80103906 <log_write+0x62>
8010392d:	eb 01                	jmp    80103930 <log_write+0x8c>
      break;
8010392f:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103930:	8b 45 08             	mov    0x8(%ebp),%eax
80103933:	8b 40 08             	mov    0x8(%eax),%eax
80103936:	89 c2                	mov    %eax,%edx
80103938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010393b:	83 c0 10             	add    $0x10,%eax
8010393e:	89 14 85 6c 84 11 80 	mov    %edx,-0x7fee7b94(,%eax,4)
  if (i == log.lh.n)
80103945:	a1 a8 84 11 80       	mov    0x801184a8,%eax
8010394a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010394d:	75 0d                	jne    8010395c <log_write+0xb8>
    log.lh.n++;
8010394f:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103954:	83 c0 01             	add    $0x1,%eax
80103957:	a3 a8 84 11 80       	mov    %eax,0x801184a8
  b->flags |= B_DIRTY; // prevent eviction
8010395c:	8b 45 08             	mov    0x8(%ebp),%eax
8010395f:	8b 00                	mov    (%eax),%eax
80103961:	83 c8 04             	or     $0x4,%eax
80103964:	89 c2                	mov    %eax,%edx
80103966:	8b 45 08             	mov    0x8(%ebp),%eax
80103969:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010396b:	83 ec 0c             	sub    $0xc,%esp
8010396e:	68 60 84 11 80       	push   $0x80118460
80103973:	e8 e0 18 00 00       	call   80105258 <release>
80103978:	83 c4 10             	add    $0x10,%esp
}
8010397b:	90                   	nop
8010397c:	c9                   	leave  
8010397d:	c3                   	ret    

8010397e <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010397e:	55                   	push   %ebp
8010397f:	89 e5                	mov    %esp,%ebp
80103981:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103984:	8b 55 08             	mov    0x8(%ebp),%edx
80103987:	8b 45 0c             	mov    0xc(%ebp),%eax
8010398a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010398d:	f0 87 02             	lock xchg %eax,(%edx)
80103990:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103993:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103996:	c9                   	leave  
80103997:	c3                   	ret    

80103998 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103998:	f3 0f 1e fb          	endbr32 
8010399c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801039a0:	83 e4 f0             	and    $0xfffffff0,%esp
801039a3:	ff 71 fc             	pushl  -0x4(%ecx)
801039a6:	55                   	push   %ebp
801039a7:	89 e5                	mov    %esp,%ebp
801039a9:	51                   	push   %ecx
801039aa:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
801039ad:	e8 9e 51 00 00       	call   80108b50 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801039b2:	83 ec 08             	sub    $0x8,%esp
801039b5:	68 00 00 40 80       	push   $0x80400000
801039ba:	68 00 c0 11 80       	push   $0x8011c000
801039bf:	e8 73 f2 ff ff       	call   80102c37 <kinit1>
801039c4:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801039c7:	e8 65 46 00 00       	call   80108031 <kvmalloc>
  mpinit_uefi();
801039cc:	e8 38 4f 00 00       	call   80108909 <mpinit_uefi>
  lapicinit();     // interrupt controller
801039d1:	e8 f0 f5 ff ff       	call   80102fc6 <lapicinit>
  seginit();       // segment descriptors
801039d6:	e8 dd 40 00 00       	call   80107ab8 <seginit>
  picinit();    // disable pic
801039db:	e8 a9 01 00 00       	call   80103b89 <picinit>
  ioapicinit();    // another interrupt controller
801039e0:	e8 65 f1 ff ff       	call   80102b4a <ioapicinit>
  consoleinit();   // console hardware
801039e5:	e8 4f d1 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
801039ea:	e8 52 34 00 00       	call   80106e41 <uartinit>
  pinit();         // process table
801039ef:	e8 e2 05 00 00       	call   80103fd6 <pinit>
  tvinit();        // trap vectors
801039f4:	e8 ae 2f 00 00       	call   801069a7 <tvinit>
  binit();         // buffer cache
801039f9:	e8 68 c6 ff ff       	call   80100066 <binit>
  fileinit();      // file table
801039fe:	e8 f0 d5 ff ff       	call   80100ff3 <fileinit>
  ideinit();       // disk 
80103a03:	e8 e3 ec ff ff       	call   801026eb <ideinit>
  startothers();   // start other processors
80103a08:	e8 92 00 00 00       	call   80103a9f <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a0d:	83 ec 08             	sub    $0x8,%esp
80103a10:	68 00 00 00 a0       	push   $0xa0000000
80103a15:	68 00 00 40 80       	push   $0x80400000
80103a1a:	e8 55 f2 ff ff       	call   80102c74 <kinit2>
80103a1f:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103a22:	e8 9c 53 00 00       	call   80108dc3 <pci_init>
  arp_scan();
80103a27:	e8 15 61 00 00       	call   80109b41 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103a2c:	e8 ab 07 00 00       	call   801041dc <userinit>

  mpmain();        // finish this processor's setup
80103a31:	e8 1e 00 00 00       	call   80103a54 <mpmain>

80103a36 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103a36:	f3 0f 1e fb          	endbr32 
80103a3a:	55                   	push   %ebp
80103a3b:	89 e5                	mov    %esp,%ebp
80103a3d:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103a40:	e8 08 46 00 00       	call   8010804d <switchkvm>
  seginit();
80103a45:	e8 6e 40 00 00       	call   80107ab8 <seginit>
  lapicinit();
80103a4a:	e8 77 f5 ff ff       	call   80102fc6 <lapicinit>
  mpmain();
80103a4f:	e8 00 00 00 00       	call   80103a54 <mpmain>

80103a54 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a54:	f3 0f 1e fb          	endbr32 
80103a58:	55                   	push   %ebp
80103a59:	89 e5                	mov    %esp,%ebp
80103a5b:	53                   	push   %ebx
80103a5c:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103a5f:	e8 94 05 00 00       	call   80103ff8 <cpuid>
80103a64:	89 c3                	mov    %eax,%ebx
80103a66:	e8 8d 05 00 00       	call   80103ff8 <cpuid>
80103a6b:	83 ec 04             	sub    $0x4,%esp
80103a6e:	53                   	push   %ebx
80103a6f:	50                   	push   %eax
80103a70:	68 39 b0 10 80       	push   $0x8010b039
80103a75:	e8 92 c9 ff ff       	call   8010040c <cprintf>
80103a7a:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a7d:	e8 9f 30 00 00       	call   80106b21 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103a82:	e8 90 05 00 00       	call   80104017 <mycpu>
80103a87:	05 a0 00 00 00       	add    $0xa0,%eax
80103a8c:	83 ec 08             	sub    $0x8,%esp
80103a8f:	6a 01                	push   $0x1
80103a91:	50                   	push   %eax
80103a92:	e8 e7 fe ff ff       	call   8010397e <xchg>
80103a97:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a9a:	e8 99 0f 00 00       	call   80104a38 <scheduler>

80103a9f <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a9f:	f3 0f 1e fb          	endbr32 
80103aa3:	55                   	push   %ebp
80103aa4:	89 e5                	mov    %esp,%ebp
80103aa6:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103aa9:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103ab0:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103ab5:	83 ec 04             	sub    $0x4,%esp
80103ab8:	50                   	push   %eax
80103ab9:	68 38 f5 10 80       	push   $0x8010f538
80103abe:	ff 75 f0             	pushl  -0x10(%ebp)
80103ac1:	e8 76 1a 00 00       	call   8010553c <memmove>
80103ac6:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103ac9:	c7 45 f4 00 b2 11 80 	movl   $0x8011b200,-0xc(%ebp)
80103ad0:	eb 79                	jmp    80103b4b <startothers+0xac>
    if(c == mycpu()){  // We've started already.
80103ad2:	e8 40 05 00 00       	call   80104017 <mycpu>
80103ad7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103ada:	74 67                	je     80103b43 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103adc:	e8 9b f2 ff ff       	call   80102d7c <kalloc>
80103ae1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ae7:	83 e8 04             	sub    $0x4,%eax
80103aea:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103aed:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103af3:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af8:	83 e8 08             	sub    $0x8,%eax
80103afb:	c7 00 36 3a 10 80    	movl   $0x80103a36,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b01:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
80103b06:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b0f:	83 e8 0c             	sub    $0xc,%eax
80103b12:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b17:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b20:	0f b6 00             	movzbl (%eax),%eax
80103b23:	0f b6 c0             	movzbl %al,%eax
80103b26:	83 ec 08             	sub    $0x8,%esp
80103b29:	52                   	push   %edx
80103b2a:	50                   	push   %eax
80103b2b:	e8 08 f6 ff ff       	call   80103138 <lapicstartap>
80103b30:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103b33:	90                   	nop
80103b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b37:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103b3d:	85 c0                	test   %eax,%eax
80103b3f:	74 f3                	je     80103b34 <startothers+0x95>
80103b41:	eb 01                	jmp    80103b44 <startothers+0xa5>
      continue;
80103b43:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103b44:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103b4b:	a1 c0 b4 11 80       	mov    0x8011b4c0,%eax
80103b50:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b56:	05 00 b2 11 80       	add    $0x8011b200,%eax
80103b5b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b5e:	0f 82 6e ff ff ff    	jb     80103ad2 <startothers+0x33>
      ;
  }
}
80103b64:	90                   	nop
80103b65:	90                   	nop
80103b66:	c9                   	leave  
80103b67:	c3                   	ret    

80103b68 <outb>:
{
80103b68:	55                   	push   %ebp
80103b69:	89 e5                	mov    %esp,%ebp
80103b6b:	83 ec 08             	sub    $0x8,%esp
80103b6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103b71:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b74:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103b78:	89 d0                	mov    %edx,%eax
80103b7a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b7d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b81:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b85:	ee                   	out    %al,(%dx)
}
80103b86:	90                   	nop
80103b87:	c9                   	leave  
80103b88:	c3                   	ret    

80103b89 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103b89:	f3 0f 1e fb          	endbr32 
80103b8d:	55                   	push   %ebp
80103b8e:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103b90:	68 ff 00 00 00       	push   $0xff
80103b95:	6a 21                	push   $0x21
80103b97:	e8 cc ff ff ff       	call   80103b68 <outb>
80103b9c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103b9f:	68 ff 00 00 00       	push   $0xff
80103ba4:	68 a1 00 00 00       	push   $0xa1
80103ba9:	e8 ba ff ff ff       	call   80103b68 <outb>
80103bae:	83 c4 08             	add    $0x8,%esp
}
80103bb1:	90                   	nop
80103bb2:	c9                   	leave  
80103bb3:	c3                   	ret    

80103bb4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103bb4:	f3 0f 1e fb          	endbr32 
80103bb8:	55                   	push   %ebp
80103bb9:	89 e5                	mov    %esp,%ebp
80103bbb:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103bbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bc8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103bce:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bd1:	8b 10                	mov    (%eax),%edx
80103bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80103bd6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103bd8:	e8 38 d4 ff ff       	call   80101015 <filealloc>
80103bdd:	8b 55 08             	mov    0x8(%ebp),%edx
80103be0:	89 02                	mov    %eax,(%edx)
80103be2:	8b 45 08             	mov    0x8(%ebp),%eax
80103be5:	8b 00                	mov    (%eax),%eax
80103be7:	85 c0                	test   %eax,%eax
80103be9:	0f 84 c8 00 00 00    	je     80103cb7 <pipealloc+0x103>
80103bef:	e8 21 d4 ff ff       	call   80101015 <filealloc>
80103bf4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bf7:	89 02                	mov    %eax,(%edx)
80103bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bfc:	8b 00                	mov    (%eax),%eax
80103bfe:	85 c0                	test   %eax,%eax
80103c00:	0f 84 b1 00 00 00    	je     80103cb7 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c06:	e8 71 f1 ff ff       	call   80102d7c <kalloc>
80103c0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c12:	0f 84 a2 00 00 00    	je     80103cba <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80103c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1b:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103c22:	00 00 00 
  p->writeopen = 1;
80103c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c28:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103c2f:	00 00 00 
  p->nwrite = 0;
80103c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c35:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103c3c:	00 00 00 
  p->nread = 0;
80103c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c42:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103c49:	00 00 00 
  initlock(&p->lock, "pipe");
80103c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4f:	83 ec 08             	sub    $0x8,%esp
80103c52:	68 4d b0 10 80       	push   $0x8010b04d
80103c57:	50                   	push   %eax
80103c58:	e8 63 15 00 00       	call   801051c0 <initlock>
80103c5d:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103c60:	8b 45 08             	mov    0x8(%ebp),%eax
80103c63:	8b 00                	mov    (%eax),%eax
80103c65:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c6e:	8b 00                	mov    (%eax),%eax
80103c70:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103c74:	8b 45 08             	mov    0x8(%ebp),%eax
80103c77:	8b 00                	mov    (%eax),%eax
80103c79:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103c7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c80:	8b 00                	mov    (%eax),%eax
80103c82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c85:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103c88:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c8b:	8b 00                	mov    (%eax),%eax
80103c8d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103c93:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c96:	8b 00                	mov    (%eax),%eax
80103c98:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c9f:	8b 00                	mov    (%eax),%eax
80103ca1:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ca8:	8b 00                	mov    (%eax),%eax
80103caa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cad:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103cb0:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb5:	eb 51                	jmp    80103d08 <pipealloc+0x154>
    goto bad;
80103cb7:	90                   	nop
80103cb8:	eb 01                	jmp    80103cbb <pipealloc+0x107>
    goto bad;
80103cba:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103cbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cbf:	74 0e                	je     80103ccf <pipealloc+0x11b>
    kfree((char*)p);
80103cc1:	83 ec 0c             	sub    $0xc,%esp
80103cc4:	ff 75 f4             	pushl  -0xc(%ebp)
80103cc7:	e8 12 f0 ff ff       	call   80102cde <kfree>
80103ccc:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd2:	8b 00                	mov    (%eax),%eax
80103cd4:	85 c0                	test   %eax,%eax
80103cd6:	74 11                	je     80103ce9 <pipealloc+0x135>
    fileclose(*f0);
80103cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103cdb:	8b 00                	mov    (%eax),%eax
80103cdd:	83 ec 0c             	sub    $0xc,%esp
80103ce0:	50                   	push   %eax
80103ce1:	e8 f5 d3 ff ff       	call   801010db <fileclose>
80103ce6:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cec:	8b 00                	mov    (%eax),%eax
80103cee:	85 c0                	test   %eax,%eax
80103cf0:	74 11                	je     80103d03 <pipealloc+0x14f>
    fileclose(*f1);
80103cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf5:	8b 00                	mov    (%eax),%eax
80103cf7:	83 ec 0c             	sub    $0xc,%esp
80103cfa:	50                   	push   %eax
80103cfb:	e8 db d3 ff ff       	call   801010db <fileclose>
80103d00:	83 c4 10             	add    $0x10,%esp
  return -1;
80103d03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d08:	c9                   	leave  
80103d09:	c3                   	ret    

80103d0a <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d0a:	f3 0f 1e fb          	endbr32 
80103d0e:	55                   	push   %ebp
80103d0f:	89 e5                	mov    %esp,%ebp
80103d11:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103d14:	8b 45 08             	mov    0x8(%ebp),%eax
80103d17:	83 ec 0c             	sub    $0xc,%esp
80103d1a:	50                   	push   %eax
80103d1b:	e8 c6 14 00 00       	call   801051e6 <acquire>
80103d20:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103d23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d27:	74 23                	je     80103d4c <pipeclose+0x42>
    p->writeopen = 0;
80103d29:	8b 45 08             	mov    0x8(%ebp),%eax
80103d2c:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d33:	00 00 00 
    wakeup(&p->nread);
80103d36:	8b 45 08             	mov    0x8(%ebp),%eax
80103d39:	05 34 02 00 00       	add    $0x234,%eax
80103d3e:	83 ec 0c             	sub    $0xc,%esp
80103d41:	50                   	push   %eax
80103d42:	e8 e7 0f 00 00       	call   80104d2e <wakeup>
80103d47:	83 c4 10             	add    $0x10,%esp
80103d4a:	eb 21                	jmp    80103d6d <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4f:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103d56:	00 00 00 
    wakeup(&p->nwrite);
80103d59:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5c:	05 38 02 00 00       	add    $0x238,%eax
80103d61:	83 ec 0c             	sub    $0xc,%esp
80103d64:	50                   	push   %eax
80103d65:	e8 c4 0f 00 00       	call   80104d2e <wakeup>
80103d6a:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80103d70:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103d76:	85 c0                	test   %eax,%eax
80103d78:	75 2c                	jne    80103da6 <pipeclose+0x9c>
80103d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d7d:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103d83:	85 c0                	test   %eax,%eax
80103d85:	75 1f                	jne    80103da6 <pipeclose+0x9c>
    release(&p->lock);
80103d87:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8a:	83 ec 0c             	sub    $0xc,%esp
80103d8d:	50                   	push   %eax
80103d8e:	e8 c5 14 00 00       	call   80105258 <release>
80103d93:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103d96:	83 ec 0c             	sub    $0xc,%esp
80103d99:	ff 75 08             	pushl  0x8(%ebp)
80103d9c:	e8 3d ef ff ff       	call   80102cde <kfree>
80103da1:	83 c4 10             	add    $0x10,%esp
80103da4:	eb 10                	jmp    80103db6 <pipeclose+0xac>
  } else
    release(&p->lock);
80103da6:	8b 45 08             	mov    0x8(%ebp),%eax
80103da9:	83 ec 0c             	sub    $0xc,%esp
80103dac:	50                   	push   %eax
80103dad:	e8 a6 14 00 00       	call   80105258 <release>
80103db2:	83 c4 10             	add    $0x10,%esp
}
80103db5:	90                   	nop
80103db6:	90                   	nop
80103db7:	c9                   	leave  
80103db8:	c3                   	ret    

80103db9 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103db9:	f3 0f 1e fb          	endbr32 
80103dbd:	55                   	push   %ebp
80103dbe:	89 e5                	mov    %esp,%ebp
80103dc0:	53                   	push   %ebx
80103dc1:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc7:	83 ec 0c             	sub    $0xc,%esp
80103dca:	50                   	push   %eax
80103dcb:	e8 16 14 00 00       	call   801051e6 <acquire>
80103dd0:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103dd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dda:	e9 ad 00 00 00       	jmp    80103e8c <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80103de2:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103de8:	85 c0                	test   %eax,%eax
80103dea:	74 0c                	je     80103df8 <pipewrite+0x3f>
80103dec:	e8 a2 02 00 00       	call   80104093 <myproc>
80103df1:	8b 40 24             	mov    0x24(%eax),%eax
80103df4:	85 c0                	test   %eax,%eax
80103df6:	74 19                	je     80103e11 <pipewrite+0x58>
        release(&p->lock);
80103df8:	8b 45 08             	mov    0x8(%ebp),%eax
80103dfb:	83 ec 0c             	sub    $0xc,%esp
80103dfe:	50                   	push   %eax
80103dff:	e8 54 14 00 00       	call   80105258 <release>
80103e04:	83 c4 10             	add    $0x10,%esp
        return -1;
80103e07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e0c:	e9 a9 00 00 00       	jmp    80103eba <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103e11:	8b 45 08             	mov    0x8(%ebp),%eax
80103e14:	05 34 02 00 00       	add    $0x234,%eax
80103e19:	83 ec 0c             	sub    $0xc,%esp
80103e1c:	50                   	push   %eax
80103e1d:	e8 0c 0f 00 00       	call   80104d2e <wakeup>
80103e22:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e25:	8b 45 08             	mov    0x8(%ebp),%eax
80103e28:	8b 55 08             	mov    0x8(%ebp),%edx
80103e2b:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e31:	83 ec 08             	sub    $0x8,%esp
80103e34:	50                   	push   %eax
80103e35:	52                   	push   %edx
80103e36:	e8 01 0e 00 00       	call   80104c3c <sleep>
80103e3b:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e41:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e47:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e50:	05 00 02 00 00       	add    $0x200,%eax
80103e55:	39 c2                	cmp    %eax,%edx
80103e57:	74 86                	je     80103ddf <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103e59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e5f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103e62:	8b 45 08             	mov    0x8(%ebp),%eax
80103e65:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103e6b:	8d 48 01             	lea    0x1(%eax),%ecx
80103e6e:	8b 55 08             	mov    0x8(%ebp),%edx
80103e71:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103e77:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e7c:	89 c1                	mov    %eax,%ecx
80103e7e:	0f b6 13             	movzbl (%ebx),%edx
80103e81:	8b 45 08             	mov    0x8(%ebp),%eax
80103e84:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103e88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e8f:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e92:	7c aa                	jl     80103e3e <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103e94:	8b 45 08             	mov    0x8(%ebp),%eax
80103e97:	05 34 02 00 00       	add    $0x234,%eax
80103e9c:	83 ec 0c             	sub    $0xc,%esp
80103e9f:	50                   	push   %eax
80103ea0:	e8 89 0e 00 00       	call   80104d2e <wakeup>
80103ea5:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80103eab:	83 ec 0c             	sub    $0xc,%esp
80103eae:	50                   	push   %eax
80103eaf:	e8 a4 13 00 00       	call   80105258 <release>
80103eb4:	83 c4 10             	add    $0x10,%esp
  return n;
80103eb7:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103eba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ebd:	c9                   	leave  
80103ebe:	c3                   	ret    

80103ebf <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103ebf:	f3 0f 1e fb          	endbr32 
80103ec3:	55                   	push   %ebp
80103ec4:	89 e5                	mov    %esp,%ebp
80103ec6:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecc:	83 ec 0c             	sub    $0xc,%esp
80103ecf:	50                   	push   %eax
80103ed0:	e8 11 13 00 00       	call   801051e6 <acquire>
80103ed5:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103ed8:	eb 3e                	jmp    80103f18 <piperead+0x59>
    if(myproc()->killed){
80103eda:	e8 b4 01 00 00       	call   80104093 <myproc>
80103edf:	8b 40 24             	mov    0x24(%eax),%eax
80103ee2:	85 c0                	test   %eax,%eax
80103ee4:	74 19                	je     80103eff <piperead+0x40>
      release(&p->lock);
80103ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee9:	83 ec 0c             	sub    $0xc,%esp
80103eec:	50                   	push   %eax
80103eed:	e8 66 13 00 00       	call   80105258 <release>
80103ef2:	83 c4 10             	add    $0x10,%esp
      return -1;
80103ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103efa:	e9 be 00 00 00       	jmp    80103fbd <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103eff:	8b 45 08             	mov    0x8(%ebp),%eax
80103f02:	8b 55 08             	mov    0x8(%ebp),%edx
80103f05:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f0b:	83 ec 08             	sub    $0x8,%esp
80103f0e:	50                   	push   %eax
80103f0f:	52                   	push   %edx
80103f10:	e8 27 0d 00 00       	call   80104c3c <sleep>
80103f15:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f18:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1b:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f21:	8b 45 08             	mov    0x8(%ebp),%eax
80103f24:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f2a:	39 c2                	cmp    %eax,%edx
80103f2c:	75 0d                	jne    80103f3b <piperead+0x7c>
80103f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f31:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f37:	85 c0                	test   %eax,%eax
80103f39:	75 9f                	jne    80103eda <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f42:	eb 48                	jmp    80103f8c <piperead+0xcd>
    if(p->nread == p->nwrite)
80103f44:	8b 45 08             	mov    0x8(%ebp),%eax
80103f47:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f50:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f56:	39 c2                	cmp    %eax,%edx
80103f58:	74 3c                	je     80103f96 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f63:	8d 48 01             	lea    0x1(%eax),%ecx
80103f66:	8b 55 08             	mov    0x8(%ebp),%edx
80103f69:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103f6f:	25 ff 01 00 00       	and    $0x1ff,%eax
80103f74:	89 c1                	mov    %eax,%ecx
80103f76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f79:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f7c:	01 c2                	add    %eax,%edx
80103f7e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f81:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103f86:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f8f:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f92:	7c b0                	jl     80103f44 <piperead+0x85>
80103f94:	eb 01                	jmp    80103f97 <piperead+0xd8>
      break;
80103f96:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103f97:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9a:	05 38 02 00 00       	add    $0x238,%eax
80103f9f:	83 ec 0c             	sub    $0xc,%esp
80103fa2:	50                   	push   %eax
80103fa3:	e8 86 0d 00 00       	call   80104d2e <wakeup>
80103fa8:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103fab:	8b 45 08             	mov    0x8(%ebp),%eax
80103fae:	83 ec 0c             	sub    $0xc,%esp
80103fb1:	50                   	push   %eax
80103fb2:	e8 a1 12 00 00       	call   80105258 <release>
80103fb7:	83 c4 10             	add    $0x10,%esp
  return i;
80103fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103fbd:	c9                   	leave  
80103fbe:	c3                   	ret    

80103fbf <readeflags>:
{
80103fbf:	55                   	push   %ebp
80103fc0:	89 e5                	mov    %esp,%ebp
80103fc2:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103fc5:	9c                   	pushf  
80103fc6:	58                   	pop    %eax
80103fc7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103fca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103fcd:	c9                   	leave  
80103fce:	c3                   	ret    

80103fcf <sti>:
{
80103fcf:	55                   	push   %ebp
80103fd0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103fd2:	fb                   	sti    
}
80103fd3:	90                   	nop
80103fd4:	5d                   	pop    %ebp
80103fd5:	c3                   	ret    

80103fd6 <pinit>:
extern void trapret(void);
static void wakeup1(void *chan);

void
pinit(void)
{
80103fd6:	f3 0f 1e fb          	endbr32 
80103fda:	55                   	push   %ebp
80103fdb:	89 e5                	mov    %esp,%ebp
80103fdd:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103fe0:	83 ec 08             	sub    $0x8,%esp
80103fe3:	68 54 b0 10 80       	push   $0x8010b054
80103fe8:	68 40 85 11 80       	push   $0x80118540
80103fed:	e8 ce 11 00 00       	call   801051c0 <initlock>
80103ff2:	83 c4 10             	add    $0x10,%esp
}
80103ff5:	90                   	nop
80103ff6:	c9                   	leave  
80103ff7:	c3                   	ret    

80103ff8 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103ff8:	f3 0f 1e fb          	endbr32 
80103ffc:	55                   	push   %ebp
80103ffd:	89 e5                	mov    %esp,%ebp
80103fff:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104002:	e8 10 00 00 00       	call   80104017 <mycpu>
80104007:	2d 00 b2 11 80       	sub    $0x8011b200,%eax
8010400c:	c1 f8 04             	sar    $0x4,%eax
8010400f:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104015:	c9                   	leave  
80104016:	c3                   	ret    

80104017 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104017:	f3 0f 1e fb          	endbr32 
8010401b:	55                   	push   %ebp
8010401c:	89 e5                	mov    %esp,%ebp
8010401e:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80104021:	e8 99 ff ff ff       	call   80103fbf <readeflags>
80104026:	25 00 02 00 00       	and    $0x200,%eax
8010402b:	85 c0                	test   %eax,%eax
8010402d:	74 0d                	je     8010403c <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
8010402f:	83 ec 0c             	sub    $0xc,%esp
80104032:	68 5c b0 10 80       	push   $0x8010b05c
80104037:	e8 89 c5 ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
8010403c:	e8 a8 f0 ff ff       	call   801030e9 <lapicid>
80104041:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104044:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010404b:	eb 2d                	jmp    8010407a <mycpu+0x63>
    if (cpus[i].apicid == apicid){
8010404d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104050:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104056:	05 00 b2 11 80       	add    $0x8011b200,%eax
8010405b:	0f b6 00             	movzbl (%eax),%eax
8010405e:	0f b6 c0             	movzbl %al,%eax
80104061:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104064:	75 10                	jne    80104076 <mycpu+0x5f>
      return &cpus[i];
80104066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104069:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010406f:	05 00 b2 11 80       	add    $0x8011b200,%eax
80104074:	eb 1b                	jmp    80104091 <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80104076:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010407a:	a1 c0 b4 11 80       	mov    0x8011b4c0,%eax
8010407f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104082:	7c c9                	jl     8010404d <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80104084:	83 ec 0c             	sub    $0xc,%esp
80104087:	68 82 b0 10 80       	push   $0x8010b082
8010408c:	e8 34 c5 ff ff       	call   801005c5 <panic>
}
80104091:	c9                   	leave  
80104092:	c3                   	ret    

80104093 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104093:	f3 0f 1e fb          	endbr32 
80104097:	55                   	push   %ebp
80104098:	89 e5                	mov    %esp,%ebp
8010409a:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010409d:	e8 c0 12 00 00       	call   80105362 <pushcli>
  c = mycpu();
801040a2:	e8 70 ff ff ff       	call   80104017 <mycpu>
801040a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801040aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ad:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801040b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801040b6:	e8 f8 12 00 00       	call   801053b3 <popcli>
  return p;
801040bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801040be:	c9                   	leave  
801040bf:	c3                   	ret    

801040c0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801040c0:	f3 0f 1e fb          	endbr32 
801040c4:	55                   	push   %ebp
801040c5:	89 e5                	mov    %esp,%ebp
801040c7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801040ca:	83 ec 0c             	sub    $0xc,%esp
801040cd:	68 40 85 11 80       	push   $0x80118540
801040d2:	e8 0f 11 00 00       	call   801051e6 <acquire>
801040d7:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040da:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801040e1:	eb 11                	jmp    801040f4 <allocproc+0x34>
    if(p->state == UNUSED){
801040e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e6:	8b 40 0c             	mov    0xc(%eax),%eax
801040e9:	85 c0                	test   %eax,%eax
801040eb:	74 2a                	je     80104117 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040ed:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801040f4:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
801040fb:	72 e6                	jb     801040e3 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
801040fd:	83 ec 0c             	sub    $0xc,%esp
80104100:	68 40 85 11 80       	push   $0x80118540
80104105:	e8 4e 11 00 00       	call   80105258 <release>
8010410a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010410d:	b8 00 00 00 00       	mov    $0x0,%eax
80104112:	e9 c3 00 00 00       	jmp    801041da <allocproc+0x11a>
      goto found;
80104117:	90                   	nop
80104118:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
8010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411f:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104126:	a1 00 f0 10 80       	mov    0x8010f000,%eax
8010412b:	8d 50 01             	lea    0x1(%eax),%edx
8010412e:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80104134:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104137:	89 42 10             	mov    %eax,0x10(%edx)

  p->scheduler = 0; //사용자 수준 스케줄러 필드를 0으로 설정, 초기화
8010413a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413d:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104144:	00 00 00 

  release(&ptable.lock);
80104147:	83 ec 0c             	sub    $0xc,%esp
8010414a:	68 40 85 11 80       	push   $0x80118540
8010414f:	e8 04 11 00 00       	call   80105258 <release>
80104154:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104157:	e8 20 ec ff ff       	call   80102d7c <kalloc>
8010415c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010415f:	89 42 08             	mov    %eax,0x8(%edx)
80104162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104165:	8b 40 08             	mov    0x8(%eax),%eax
80104168:	85 c0                	test   %eax,%eax
8010416a:	75 11                	jne    8010417d <allocproc+0xbd>
    p->state = UNUSED;
8010416c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104176:	b8 00 00 00 00       	mov    $0x0,%eax
8010417b:	eb 5d                	jmp    801041da <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
8010417d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104180:	8b 40 08             	mov    0x8(%eax),%eax
80104183:	05 00 10 00 00       	add    $0x1000,%eax
80104188:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010418b:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010418f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104192:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104195:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104198:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010419c:	ba 61 69 10 80       	mov    $0x80106961,%edx
801041a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041a4:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801041a6:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801041aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041b0:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801041b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b6:	8b 40 1c             	mov    0x1c(%eax),%eax
801041b9:	83 ec 04             	sub    $0x4,%esp
801041bc:	6a 14                	push   $0x14
801041be:	6a 00                	push   $0x0
801041c0:	50                   	push   %eax
801041c1:	e8 af 12 00 00       	call   80105475 <memset>
801041c6:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801041c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041cc:	8b 40 1c             	mov    0x1c(%eax),%eax
801041cf:	ba f2 4b 10 80       	mov    $0x80104bf2,%edx
801041d4:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801041d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801041da:	c9                   	leave  
801041db:	c3                   	ret    

801041dc <userinit>:
int printpt(int pid);
//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801041dc:	f3 0f 1e fb          	endbr32 
801041e0:	55                   	push   %ebp
801041e1:	89 e5                	mov    %esp,%ebp
801041e3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801041e6:	e8 d5 fe ff ff       	call   801040c0 <allocproc>
801041eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801041ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f1:	a3 a0 00 11 80       	mov    %eax,0x801100a0
  if((p->pgdir = setupkvm()) == 0){
801041f6:	e8 45 3d 00 00       	call   80107f40 <setupkvm>
801041fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fe:	89 42 04             	mov    %eax,0x4(%edx)
80104201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104204:	8b 40 04             	mov    0x4(%eax),%eax
80104207:	85 c0                	test   %eax,%eax
80104209:	75 0d                	jne    80104218 <userinit+0x3c>
    panic("userinit: out of memory?");
8010420b:	83 ec 0c             	sub    $0xc,%esp
8010420e:	68 92 b0 10 80       	push   $0x8010b092
80104213:	e8 ad c3 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104218:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010421d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104220:	8b 40 04             	mov    0x4(%eax),%eax
80104223:	83 ec 04             	sub    $0x4,%esp
80104226:	52                   	push   %edx
80104227:	68 0c f5 10 80       	push   $0x8010f50c
8010422c:	50                   	push   %eax
8010422d:	e8 db 3f 00 00       	call   8010820d <inituvm>
80104232:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104238:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010423e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104241:	8b 40 18             	mov    0x18(%eax),%eax
80104244:	83 ec 04             	sub    $0x4,%esp
80104247:	6a 4c                	push   $0x4c
80104249:	6a 00                	push   $0x0
8010424b:	50                   	push   %eax
8010424c:	e8 24 12 00 00       	call   80105475 <memset>
80104251:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104257:	8b 40 18             	mov    0x18(%eax),%eax
8010425a:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104263:	8b 40 18             	mov    0x18(%eax),%eax
80104266:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010426c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426f:	8b 50 18             	mov    0x18(%eax),%edx
80104272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104275:	8b 40 18             	mov    0x18(%eax),%eax
80104278:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010427c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104283:	8b 50 18             	mov    0x18(%eax),%edx
80104286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104289:	8b 40 18             	mov    0x18(%eax),%eax
8010428c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104290:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104294:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104297:	8b 40 18             	mov    0x18(%eax),%eax
8010429a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801042a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a4:	8b 40 18             	mov    0x18(%eax),%eax
801042a7:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801042ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b1:	8b 40 18             	mov    0x18(%eax),%eax
801042b4:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801042bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042be:	83 c0 6c             	add    $0x6c,%eax
801042c1:	83 ec 04             	sub    $0x4,%esp
801042c4:	6a 10                	push   $0x10
801042c6:	68 ab b0 10 80       	push   $0x8010b0ab
801042cb:	50                   	push   %eax
801042cc:	e8 bf 13 00 00       	call   80105690 <safestrcpy>
801042d1:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801042d4:	83 ec 0c             	sub    $0xc,%esp
801042d7:	68 b4 b0 10 80       	push   $0x8010b0b4
801042dc:	e8 f8 e2 ff ff       	call   801025d9 <namei>
801042e1:	83 c4 10             	add    $0x10,%esp
801042e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042e7:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801042ea:	83 ec 0c             	sub    $0xc,%esp
801042ed:	68 40 85 11 80       	push   $0x80118540
801042f2:	e8 ef 0e 00 00       	call   801051e6 <acquire>
801042f7:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801042fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104304:	83 ec 0c             	sub    $0xc,%esp
80104307:	68 40 85 11 80       	push   $0x80118540
8010430c:	e8 47 0f 00 00       	call   80105258 <release>
80104311:	83 c4 10             	add    $0x10,%esp
}
80104314:	90                   	nop
80104315:	c9                   	leave  
80104316:	c3                   	ret    

80104317 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104317:	f3 0f 1e fb          	endbr32 
8010431b:	55                   	push   %ebp
8010431c:	89 e5                	mov    %esp,%ebp
8010431e:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80104321:	e8 6d fd ff ff       	call   80104093 <myproc>
80104326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104329:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010432c:	8b 00                	mov    (%eax),%eax
8010432e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104331:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104335:	7e 2e                	jle    80104365 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104337:	8b 55 08             	mov    0x8(%ebp),%edx
8010433a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433d:	01 c2                	add    %eax,%edx
8010433f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104342:	8b 40 04             	mov    0x4(%eax),%eax
80104345:	83 ec 04             	sub    $0x4,%esp
80104348:	52                   	push   %edx
80104349:	ff 75 f4             	pushl  -0xc(%ebp)
8010434c:	50                   	push   %eax
8010434d:	e8 00 40 00 00       	call   80108352 <allocuvm>
80104352:	83 c4 10             	add    $0x10,%esp
80104355:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104358:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010435c:	75 3b                	jne    80104399 <growproc+0x82>
      return -1;
8010435e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104363:	eb 4f                	jmp    801043b4 <growproc+0x9d>
  } else if(n < 0){
80104365:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104369:	79 2e                	jns    80104399 <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010436b:	8b 55 08             	mov    0x8(%ebp),%edx
8010436e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104371:	01 c2                	add    %eax,%edx
80104373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104376:	8b 40 04             	mov    0x4(%eax),%eax
80104379:	83 ec 04             	sub    $0x4,%esp
8010437c:	52                   	push   %edx
8010437d:	ff 75 f4             	pushl  -0xc(%ebp)
80104380:	50                   	push   %eax
80104381:	e8 d5 40 00 00       	call   8010845b <deallocuvm>
80104386:	83 c4 10             	add    $0x10,%esp
80104389:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010438c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104390:	75 07                	jne    80104399 <growproc+0x82>
      return -1;
80104392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104397:	eb 1b                	jmp    801043b4 <growproc+0x9d>
  }
  curproc->sz = sz;
80104399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010439c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010439f:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801043a1:	83 ec 0c             	sub    $0xc,%esp
801043a4:	ff 75 f0             	pushl  -0x10(%ebp)
801043a7:	e8 be 3c 00 00       	call   8010806a <switchuvm>
801043ac:	83 c4 10             	add    $0x10,%esp
  return 0;
801043af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043b4:	c9                   	leave  
801043b5:	c3                   	ret    

801043b6 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801043b6:	f3 0f 1e fb          	endbr32 
801043ba:	55                   	push   %ebp
801043bb:	89 e5                	mov    %esp,%ebp
801043bd:	57                   	push   %edi
801043be:	56                   	push   %esi
801043bf:	53                   	push   %ebx
801043c0:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801043c3:	e8 cb fc ff ff       	call   80104093 <myproc>
801043c8:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801043cb:	e8 f0 fc ff ff       	call   801040c0 <allocproc>
801043d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
801043d3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801043d7:	75 0a                	jne    801043e3 <fork+0x2d>
    return -1;
801043d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043de:	e9 5a 01 00 00       	jmp    8010453d <fork+0x187>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801043e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043e6:	8b 10                	mov    (%eax),%edx
801043e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043eb:	8b 40 04             	mov    0x4(%eax),%eax
801043ee:	83 ec 08             	sub    $0x8,%esp
801043f1:	52                   	push   %edx
801043f2:	50                   	push   %eax
801043f3:	e8 0d 42 00 00       	call   80108605 <copyuvm>
801043f8:	83 c4 10             	add    $0x10,%esp
801043fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
801043fe:	89 42 04             	mov    %eax,0x4(%edx)
80104401:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104404:	8b 40 04             	mov    0x4(%eax),%eax
80104407:	85 c0                	test   %eax,%eax
80104409:	75 30                	jne    8010443b <fork+0x85>
    kfree(np->kstack);
8010440b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010440e:	8b 40 08             	mov    0x8(%eax),%eax
80104411:	83 ec 0c             	sub    $0xc,%esp
80104414:	50                   	push   %eax
80104415:	e8 c4 e8 ff ff       	call   80102cde <kfree>
8010441a:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010441d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104420:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104427:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010442a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104431:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104436:	e9 02 01 00 00       	jmp    8010453d <fork+0x187>
  }
  np->sz = curproc->sz;
8010443b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010443e:	8b 10                	mov    (%eax),%edx
80104440:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104443:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104445:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104448:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010444b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010444e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104451:	8b 48 18             	mov    0x18(%eax),%ecx
80104454:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104457:	8b 40 18             	mov    0x18(%eax),%eax
8010445a:	89 c2                	mov    %eax,%edx
8010445c:	89 cb                	mov    %ecx,%ebx
8010445e:	b8 13 00 00 00       	mov    $0x13,%eax
80104463:	89 d7                	mov    %edx,%edi
80104465:	89 de                	mov    %ebx,%esi
80104467:	89 c1                	mov    %eax,%ecx
80104469:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->stack_alloc = curproc->stack_alloc;
8010446b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010446e:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104474:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104477:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010447d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104480:	8b 40 18             	mov    0x18(%eax),%eax
80104483:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010448a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104491:	eb 3b                	jmp    801044ce <fork+0x118>
    if(curproc->ofile[i])
80104493:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104496:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104499:	83 c2 08             	add    $0x8,%edx
8010449c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044a0:	85 c0                	test   %eax,%eax
801044a2:	74 26                	je     801044ca <fork+0x114>
      np->ofile[i] = filedup(curproc->ofile[i]);
801044a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801044aa:	83 c2 08             	add    $0x8,%edx
801044ad:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044b1:	83 ec 0c             	sub    $0xc,%esp
801044b4:	50                   	push   %eax
801044b5:	e8 cc cb ff ff       	call   80101086 <filedup>
801044ba:	83 c4 10             	add    $0x10,%esp
801044bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044c0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801044c3:	83 c1 08             	add    $0x8,%ecx
801044c6:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801044ca:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801044ce:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801044d2:	7e bf                	jle    80104493 <fork+0xdd>
  np->cwd = idup(curproc->cwd);
801044d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044d7:	8b 40 68             	mov    0x68(%eax),%eax
801044da:	83 ec 0c             	sub    $0xc,%esp
801044dd:	50                   	push   %eax
801044de:	e8 4d d5 ff ff       	call   80101a30 <idup>
801044e3:	83 c4 10             	add    $0x10,%esp
801044e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044e9:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801044ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044ef:	8d 50 6c             	lea    0x6c(%eax),%edx
801044f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044f5:	83 c0 6c             	add    $0x6c,%eax
801044f8:	83 ec 04             	sub    $0x4,%esp
801044fb:	6a 10                	push   $0x10
801044fd:	52                   	push   %edx
801044fe:	50                   	push   %eax
801044ff:	e8 8c 11 00 00       	call   80105690 <safestrcpy>
80104504:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104507:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010450a:	8b 40 10             	mov    0x10(%eax),%eax
8010450d:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104510:	83 ec 0c             	sub    $0xc,%esp
80104513:	68 40 85 11 80       	push   $0x80118540
80104518:	e8 c9 0c 00 00       	call   801051e6 <acquire>
8010451d:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104520:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104523:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010452a:	83 ec 0c             	sub    $0xc,%esp
8010452d:	68 40 85 11 80       	push   $0x80118540
80104532:	e8 21 0d 00 00       	call   80105258 <release>
80104537:	83 c4 10             	add    $0x10,%esp

  return pid;
8010453a:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
8010453d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104540:	5b                   	pop    %ebx
80104541:	5e                   	pop    %esi
80104542:	5f                   	pop    %edi
80104543:	5d                   	pop    %ebp
80104544:	c3                   	ret    

80104545 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104545:	f3 0f 1e fb          	endbr32 
80104549:	55                   	push   %ebp
8010454a:	89 e5                	mov    %esp,%ebp
8010454c:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010454f:	e8 3f fb ff ff       	call   80104093 <myproc>
80104554:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104557:	a1 a0 00 11 80       	mov    0x801100a0,%eax
8010455c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010455f:	75 0d                	jne    8010456e <exit+0x29>
    panic("init exiting");
80104561:	83 ec 0c             	sub    $0xc,%esp
80104564:	68 b6 b0 10 80       	push   $0x8010b0b6
80104569:	e8 57 c0 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010456e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104575:	eb 3f                	jmp    801045b6 <exit+0x71>
    if(curproc->ofile[fd]){
80104577:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010457a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010457d:	83 c2 08             	add    $0x8,%edx
80104580:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104584:	85 c0                	test   %eax,%eax
80104586:	74 2a                	je     801045b2 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104588:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010458b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010458e:	83 c2 08             	add    $0x8,%edx
80104591:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104595:	83 ec 0c             	sub    $0xc,%esp
80104598:	50                   	push   %eax
80104599:	e8 3d cb ff ff       	call   801010db <fileclose>
8010459e:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801045a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045a7:	83 c2 08             	add    $0x8,%edx
801045aa:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801045b1:	00 
  for(fd = 0; fd < NOFILE; fd++){
801045b2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801045b6:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801045ba:	7e bb                	jle    80104577 <exit+0x32>
    }
  }

  begin_op();
801045bc:	e8 9a f0 ff ff       	call   8010365b <begin_op>
  iput(curproc->cwd);
801045c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045c4:	8b 40 68             	mov    0x68(%eax),%eax
801045c7:	83 ec 0c             	sub    $0xc,%esp
801045ca:	50                   	push   %eax
801045cb:	e8 07 d6 ff ff       	call   80101bd7 <iput>
801045d0:	83 c4 10             	add    $0x10,%esp
  end_op();
801045d3:	e8 13 f1 ff ff       	call   801036eb <end_op>
  curproc->cwd = 0;
801045d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045db:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801045e2:	83 ec 0c             	sub    $0xc,%esp
801045e5:	68 40 85 11 80       	push   $0x80118540
801045ea:	e8 f7 0b 00 00       	call   801051e6 <acquire>
801045ef:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801045f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045f5:	8b 40 14             	mov    0x14(%eax),%eax
801045f8:	83 ec 0c             	sub    $0xc,%esp
801045fb:	50                   	push   %eax
801045fc:	e8 e6 06 00 00       	call   80104ce7 <wakeup1>
80104601:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104604:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
8010460b:	eb 3a                	jmp    80104647 <exit+0x102>
    if(p->parent == curproc){
8010460d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104610:	8b 40 14             	mov    0x14(%eax),%eax
80104613:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104616:	75 28                	jne    80104640 <exit+0xfb>
      p->parent = initproc;
80104618:	8b 15 a0 00 11 80    	mov    0x801100a0,%edx
8010461e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104621:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104627:	8b 40 0c             	mov    0xc(%eax),%eax
8010462a:	83 f8 05             	cmp    $0x5,%eax
8010462d:	75 11                	jne    80104640 <exit+0xfb>
        wakeup1(initproc);
8010462f:	a1 a0 00 11 80       	mov    0x801100a0,%eax
80104634:	83 ec 0c             	sub    $0xc,%esp
80104637:	50                   	push   %eax
80104638:	e8 aa 06 00 00       	call   80104ce7 <wakeup1>
8010463d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104640:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104647:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
8010464e:	72 bd                	jb     8010460d <exit+0xc8>
    }
  }

  curproc->scheduler = 0; //명시적으로 scheduler 필드를 초기화
80104650:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104653:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
8010465a:	00 00 00 

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010465d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104660:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104667:	e8 8b 04 00 00       	call   80104af7 <sched>
  panic("zombie exit");
8010466c:	83 ec 0c             	sub    $0xc,%esp
8010466f:	68 c3 b0 10 80       	push   $0x8010b0c3
80104674:	e8 4c bf ff ff       	call   801005c5 <panic>

80104679 <exit2>:
}

void
exit2(int status)
{
80104679:	f3 0f 1e fb          	endbr32 
8010467d:	55                   	push   %ebp
8010467e:	89 e5                	mov    %esp,%ebp
80104680:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104683:	e8 0b fa ff ff       	call   80104093 <myproc>
80104688:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
8010468b:	a1 a0 00 11 80       	mov    0x801100a0,%eax
80104690:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104693:	75 0d                	jne    801046a2 <exit2+0x29>
    panic("init exiting");
80104695:	83 ec 0c             	sub    $0xc,%esp
80104698:	68 b6 b0 10 80       	push   $0x8010b0b6
8010469d:	e8 23 bf ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801046a2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801046a9:	eb 3f                	jmp    801046ea <exit2+0x71>
    if(curproc->ofile[fd]){
801046ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046b1:	83 c2 08             	add    $0x8,%edx
801046b4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046b8:	85 c0                	test   %eax,%eax
801046ba:	74 2a                	je     801046e6 <exit2+0x6d>
      fileclose(curproc->ofile[fd]);
801046bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046c2:	83 c2 08             	add    $0x8,%edx
801046c5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046c9:	83 ec 0c             	sub    $0xc,%esp
801046cc:	50                   	push   %eax
801046cd:	e8 09 ca ff ff       	call   801010db <fileclose>
801046d2:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801046d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046db:	83 c2 08             	add    $0x8,%edx
801046de:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801046e5:	00 
  for(fd = 0; fd < NOFILE; fd++){
801046e6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801046ea:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801046ee:	7e bb                	jle    801046ab <exit2+0x32>
    }
  }

  begin_op();
801046f0:	e8 66 ef ff ff       	call   8010365b <begin_op>
  iput(curproc->cwd);
801046f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046f8:	8b 40 68             	mov    0x68(%eax),%eax
801046fb:	83 ec 0c             	sub    $0xc,%esp
801046fe:	50                   	push   %eax
801046ff:	e8 d3 d4 ff ff       	call   80101bd7 <iput>
80104704:	83 c4 10             	add    $0x10,%esp
  end_op();
80104707:	e8 df ef ff ff       	call   801036eb <end_op>
  curproc->cwd = 0;
8010470c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010470f:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104716:	83 ec 0c             	sub    $0xc,%esp
80104719:	68 40 85 11 80       	push   $0x80118540
8010471e:	e8 c3 0a 00 00       	call   801051e6 <acquire>
80104723:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104726:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104729:	8b 40 14             	mov    0x14(%eax),%eax
8010472c:	83 ec 0c             	sub    $0xc,%esp
8010472f:	50                   	push   %eax
80104730:	e8 b2 05 00 00       	call   80104ce7 <wakeup1>
80104735:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104738:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
8010473f:	eb 3a                	jmp    8010477b <exit2+0x102>
    if(p->parent == curproc){
80104741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104744:	8b 40 14             	mov    0x14(%eax),%eax
80104747:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010474a:	75 28                	jne    80104774 <exit2+0xfb>
      p->parent = initproc;
8010474c:	8b 15 a0 00 11 80    	mov    0x801100a0,%edx
80104752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104755:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475b:	8b 40 0c             	mov    0xc(%eax),%eax
8010475e:	83 f8 05             	cmp    $0x5,%eax
80104761:	75 11                	jne    80104774 <exit2+0xfb>
        wakeup1(initproc);
80104763:	a1 a0 00 11 80       	mov    0x801100a0,%eax
80104768:	83 ec 0c             	sub    $0xc,%esp
8010476b:	50                   	push   %eax
8010476c:	e8 76 05 00 00       	call   80104ce7 <wakeup1>
80104771:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104774:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010477b:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
80104782:	72 bd                	jb     80104741 <exit2+0xc8>
    }
  }

  // Set exit status and become a zombie.
  curproc->xstate = status; // Save the exit status
80104784:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104787:	8b 55 08             	mov    0x8(%ebp),%edx
8010478a:	89 50 7c             	mov    %edx,0x7c(%eax)

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010478d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104790:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104797:	e8 5b 03 00 00       	call   80104af7 <sched>
  panic("zombie exit");
8010479c:	83 ec 0c             	sub    $0xc,%esp
8010479f:	68 c3 b0 10 80       	push   $0x8010b0c3
801047a4:	e8 1c be ff ff       	call   801005c5 <panic>

801047a9 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801047a9:	f3 0f 1e fb          	endbr32 
801047ad:	55                   	push   %ebp
801047ae:	89 e5                	mov    %esp,%ebp
801047b0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801047b3:	e8 db f8 ff ff       	call   80104093 <myproc>
801047b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801047bb:	83 ec 0c             	sub    $0xc,%esp
801047be:	68 40 85 11 80       	push   $0x80118540
801047c3:	e8 1e 0a 00 00       	call   801051e6 <acquire>
801047c8:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801047cb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047d2:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801047d9:	e9 a4 00 00 00       	jmp    80104882 <wait+0xd9>
      if(p->parent != curproc)
801047de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e1:	8b 40 14             	mov    0x14(%eax),%eax
801047e4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801047e7:	0f 85 8d 00 00 00    	jne    8010487a <wait+0xd1>
        continue;
      havekids = 1;
801047ed:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801047f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f7:	8b 40 0c             	mov    0xc(%eax),%eax
801047fa:	83 f8 05             	cmp    $0x5,%eax
801047fd:	75 7c                	jne    8010487b <wait+0xd2>
        // Found one.
        pid = p->pid;
801047ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104802:	8b 40 10             	mov    0x10(%eax),%eax
80104805:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480b:	8b 40 08             	mov    0x8(%eax),%eax
8010480e:	83 ec 0c             	sub    $0xc,%esp
80104811:	50                   	push   %eax
80104812:	e8 c7 e4 ff ff       	call   80102cde <kfree>
80104817:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010481a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010481d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104827:	8b 40 04             	mov    0x4(%eax),%eax
8010482a:	83 ec 0c             	sub    $0xc,%esp
8010482d:	50                   	push   %eax
8010482e:	e8 f0 3c 00 00       	call   80108523 <freevm>
80104833:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104839:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104843:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010484a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010484d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104854:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
8010485b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104865:	83 ec 0c             	sub    $0xc,%esp
80104868:	68 40 85 11 80       	push   $0x80118540
8010486d:	e8 e6 09 00 00       	call   80105258 <release>
80104872:	83 c4 10             	add    $0x10,%esp
        return pid;
80104875:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104878:	eb 54                	jmp    801048ce <wait+0x125>
        continue;
8010487a:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010487b:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104882:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
80104889:	0f 82 4f ff ff ff    	jb     801047de <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010488f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104893:	74 0a                	je     8010489f <wait+0xf6>
80104895:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104898:	8b 40 24             	mov    0x24(%eax),%eax
8010489b:	85 c0                	test   %eax,%eax
8010489d:	74 17                	je     801048b6 <wait+0x10d>
      release(&ptable.lock);
8010489f:	83 ec 0c             	sub    $0xc,%esp
801048a2:	68 40 85 11 80       	push   $0x80118540
801048a7:	e8 ac 09 00 00       	call   80105258 <release>
801048ac:	83 c4 10             	add    $0x10,%esp
      return -1;
801048af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048b4:	eb 18                	jmp    801048ce <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801048b6:	83 ec 08             	sub    $0x8,%esp
801048b9:	68 40 85 11 80       	push   $0x80118540
801048be:	ff 75 ec             	pushl  -0x14(%ebp)
801048c1:	e8 76 03 00 00       	call   80104c3c <sleep>
801048c6:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801048c9:	e9 fd fe ff ff       	jmp    801047cb <wait+0x22>
  }
}
801048ce:	c9                   	leave  
801048cf:	c3                   	ret    

801048d0 <wait2>:

int
wait2(int *status) {
801048d0:	f3 0f 1e fb          	endbr32 
801048d4:	55                   	push   %ebp
801048d5:	89 e5                	mov    %esp,%ebp
801048d7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801048da:	e8 b4 f7 ff ff       	call   80104093 <myproc>
801048df:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
801048e2:	83 ec 0c             	sub    $0xc,%esp
801048e5:	68 40 85 11 80       	push   $0x80118540
801048ea:	e8 f7 08 00 00       	call   801051e6 <acquire>
801048ef:	83 c4 10             	add    $0x10,%esp
  for(;;) {
    // Scan through table looking for zombie children.
    havekids = 0;
801048f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801048f9:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104900:	e9 e5 00 00 00       	jmp    801049ea <wait2+0x11a>
      if(p->parent != curproc)
80104905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104908:	8b 40 14             	mov    0x14(%eax),%eax
8010490b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010490e:	0f 85 ce 00 00 00    	jne    801049e2 <wait2+0x112>
        continue;
      havekids = 1;
80104914:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE) {
8010491b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491e:	8b 40 0c             	mov    0xc(%eax),%eax
80104921:	83 f8 05             	cmp    $0x5,%eax
80104924:	0f 85 b9 00 00 00    	jne    801049e3 <wait2+0x113>
        // Found one.
        pid = p->pid;
8010492a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492d:	8b 40 10             	mov    0x10(%eax),%eax
80104930:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104936:	8b 40 08             	mov    0x8(%eax),%eax
80104939:	83 ec 0c             	sub    $0xc,%esp
8010493c:	50                   	push   %eax
8010493d:	e8 9c e3 ff ff       	call   80102cde <kfree>
80104942:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104948:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010494f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104952:	8b 40 04             	mov    0x4(%eax),%eax
80104955:	83 ec 0c             	sub    $0xc,%esp
80104958:	50                   	push   %eax
80104959:	e8 c5 3b 00 00       	call   80108523 <freevm>
8010495e:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104964:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010496b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104978:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010497c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497f:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        if(status != 0 && copyout(curproc->pgdir, (uint)status, &p->xstate, sizeof(p->xstate)) < 0) {
80104986:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010498a:	74 37                	je     801049c3 <wait2+0xf3>
8010498c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498f:	8d 48 7c             	lea    0x7c(%eax),%ecx
80104992:	8b 55 08             	mov    0x8(%ebp),%edx
80104995:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104998:	8b 40 04             	mov    0x4(%eax),%eax
8010499b:	6a 04                	push   $0x4
8010499d:	51                   	push   %ecx
8010499e:	52                   	push   %edx
8010499f:	50                   	push   %eax
801049a0:	e8 c2 3e 00 00       	call   80108867 <copyout>
801049a5:	83 c4 10             	add    $0x10,%esp
801049a8:	85 c0                	test   %eax,%eax
801049aa:	79 17                	jns    801049c3 <wait2+0xf3>
          release(&ptable.lock);
801049ac:	83 ec 0c             	sub    $0xc,%esp
801049af:	68 40 85 11 80       	push   $0x80118540
801049b4:	e8 9f 08 00 00       	call   80105258 <release>
801049b9:	83 c4 10             	add    $0x10,%esp
          return -1;
801049bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049c1:	eb 73                	jmp    80104a36 <wait2+0x166>
        }
        p->state = UNUSED;
801049c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801049cd:	83 ec 0c             	sub    $0xc,%esp
801049d0:	68 40 85 11 80       	push   $0x80118540
801049d5:	e8 7e 08 00 00       	call   80105258 <release>
801049da:	83 c4 10             	add    $0x10,%esp
        return pid;
801049dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801049e0:	eb 54                	jmp    80104a36 <wait2+0x166>
        continue;
801049e2:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801049e3:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801049ea:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
801049f1:	0f 82 0e ff ff ff    	jb     80104905 <wait2+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed) {
801049f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049fb:	74 0a                	je     80104a07 <wait2+0x137>
801049fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a00:	8b 40 24             	mov    0x24(%eax),%eax
80104a03:	85 c0                	test   %eax,%eax
80104a05:	74 17                	je     80104a1e <wait2+0x14e>
      release(&ptable.lock);
80104a07:	83 ec 0c             	sub    $0xc,%esp
80104a0a:	68 40 85 11 80       	push   $0x80118540
80104a0f:	e8 44 08 00 00       	call   80105258 <release>
80104a14:	83 c4 10             	add    $0x10,%esp
      return -1;
80104a17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a1c:	eb 18                	jmp    80104a36 <wait2+0x166>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  // DOC: wait-sleep
80104a1e:	83 ec 08             	sub    $0x8,%esp
80104a21:	68 40 85 11 80       	push   $0x80118540
80104a26:	ff 75 ec             	pushl  -0x14(%ebp)
80104a29:	e8 0e 02 00 00       	call   80104c3c <sleep>
80104a2e:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104a31:	e9 bc fe ff ff       	jmp    801048f2 <wait2+0x22>
  }
}
80104a36:	c9                   	leave  
80104a37:	c3                   	ret    

80104a38 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a38:	f3 0f 1e fb          	endbr32 
80104a3c:	55                   	push   %ebp
80104a3d:	89 e5                	mov    %esp,%ebp
80104a3f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104a42:	e8 d0 f5 ff ff       	call   80104017 <mycpu>
80104a47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a4d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a54:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a57:	e8 73 f5 ff ff       	call   80103fcf <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a5c:	83 ec 0c             	sub    $0xc,%esp
80104a5f:	68 40 85 11 80       	push   $0x80118540
80104a64:	e8 7d 07 00 00       	call   801051e6 <acquire>
80104a69:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a6c:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104a73:	eb 64                	jmp    80104ad9 <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a78:	8b 40 0c             	mov    0xc(%eax),%eax
80104a7b:	83 f8 03             	cmp    $0x3,%eax
80104a7e:	75 51                	jne    80104ad1 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a86:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a8c:	83 ec 0c             	sub    $0xc,%esp
80104a8f:	ff 75 f4             	pushl  -0xc(%ebp)
80104a92:	e8 d3 35 00 00       	call   8010806a <switchuvm>
80104a97:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa7:	8b 40 1c             	mov    0x1c(%eax),%eax
80104aaa:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104aad:	83 c2 04             	add    $0x4,%edx
80104ab0:	83 ec 08             	sub    $0x8,%esp
80104ab3:	50                   	push   %eax
80104ab4:	52                   	push   %edx
80104ab5:	e8 4f 0c 00 00       	call   80105709 <swtch>
80104aba:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104abd:	e8 8b 35 00 00       	call   8010804d <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ac5:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104acc:	00 00 00 
80104acf:	eb 01                	jmp    80104ad2 <scheduler+0x9a>
        continue;
80104ad1:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ad2:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104ad9:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
80104ae0:	72 93                	jb     80104a75 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104ae2:	83 ec 0c             	sub    $0xc,%esp
80104ae5:	68 40 85 11 80       	push   $0x80118540
80104aea:	e8 69 07 00 00       	call   80105258 <release>
80104aef:	83 c4 10             	add    $0x10,%esp
    sti();
80104af2:	e9 60 ff ff ff       	jmp    80104a57 <scheduler+0x1f>

80104af7 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104af7:	f3 0f 1e fb          	endbr32 
80104afb:	55                   	push   %ebp
80104afc:	89 e5                	mov    %esp,%ebp
80104afe:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104b01:	e8 8d f5 ff ff       	call   80104093 <myproc>
80104b06:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104b09:	83 ec 0c             	sub    $0xc,%esp
80104b0c:	68 40 85 11 80       	push   $0x80118540
80104b11:	e8 17 08 00 00       	call   8010532d <holding>
80104b16:	83 c4 10             	add    $0x10,%esp
80104b19:	85 c0                	test   %eax,%eax
80104b1b:	75 0d                	jne    80104b2a <sched+0x33>
    panic("sched ptable.lock");
80104b1d:	83 ec 0c             	sub    $0xc,%esp
80104b20:	68 cf b0 10 80       	push   $0x8010b0cf
80104b25:	e8 9b ba ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104b2a:	e8 e8 f4 ff ff       	call   80104017 <mycpu>
80104b2f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b35:	83 f8 01             	cmp    $0x1,%eax
80104b38:	74 0d                	je     80104b47 <sched+0x50>
    panic("sched locks");
80104b3a:	83 ec 0c             	sub    $0xc,%esp
80104b3d:	68 e1 b0 10 80       	push   $0x8010b0e1
80104b42:	e8 7e ba ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4a:	8b 40 0c             	mov    0xc(%eax),%eax
80104b4d:	83 f8 04             	cmp    $0x4,%eax
80104b50:	75 0d                	jne    80104b5f <sched+0x68>
    panic("sched running");
80104b52:	83 ec 0c             	sub    $0xc,%esp
80104b55:	68 ed b0 10 80       	push   $0x8010b0ed
80104b5a:	e8 66 ba ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
80104b5f:	e8 5b f4 ff ff       	call   80103fbf <readeflags>
80104b64:	25 00 02 00 00       	and    $0x200,%eax
80104b69:	85 c0                	test   %eax,%eax
80104b6b:	74 0d                	je     80104b7a <sched+0x83>
    panic("sched interruptible");
80104b6d:	83 ec 0c             	sub    $0xc,%esp
80104b70:	68 fb b0 10 80       	push   $0x8010b0fb
80104b75:	e8 4b ba ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
80104b7a:	e8 98 f4 ff ff       	call   80104017 <mycpu>
80104b7f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b85:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b88:	e8 8a f4 ff ff       	call   80104017 <mycpu>
80104b8d:	8b 40 04             	mov    0x4(%eax),%eax
80104b90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b93:	83 c2 1c             	add    $0x1c,%edx
80104b96:	83 ec 08             	sub    $0x8,%esp
80104b99:	50                   	push   %eax
80104b9a:	52                   	push   %edx
80104b9b:	e8 69 0b 00 00       	call   80105709 <swtch>
80104ba0:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104ba3:	e8 6f f4 ff ff       	call   80104017 <mycpu>
80104ba8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104bab:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104bb1:	90                   	nop
80104bb2:	c9                   	leave  
80104bb3:	c3                   	ret    

80104bb4 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104bb4:	f3 0f 1e fb          	endbr32 
80104bb8:	55                   	push   %ebp
80104bb9:	89 e5                	mov    %esp,%ebp
80104bbb:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104bbe:	83 ec 0c             	sub    $0xc,%esp
80104bc1:	68 40 85 11 80       	push   $0x80118540
80104bc6:	e8 1b 06 00 00       	call   801051e6 <acquire>
80104bcb:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104bce:	e8 c0 f4 ff ff       	call   80104093 <myproc>
80104bd3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104bda:	e8 18 ff ff ff       	call   80104af7 <sched>
  release(&ptable.lock);
80104bdf:	83 ec 0c             	sub    $0xc,%esp
80104be2:	68 40 85 11 80       	push   $0x80118540
80104be7:	e8 6c 06 00 00       	call   80105258 <release>
80104bec:	83 c4 10             	add    $0x10,%esp
}
80104bef:	90                   	nop
80104bf0:	c9                   	leave  
80104bf1:	c3                   	ret    

80104bf2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bf2:	f3 0f 1e fb          	endbr32 
80104bf6:	55                   	push   %ebp
80104bf7:	89 e5                	mov    %esp,%ebp
80104bf9:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bfc:	83 ec 0c             	sub    $0xc,%esp
80104bff:	68 40 85 11 80       	push   $0x80118540
80104c04:	e8 4f 06 00 00       	call   80105258 <release>
80104c09:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104c0c:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104c11:	85 c0                	test   %eax,%eax
80104c13:	74 24                	je     80104c39 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104c15:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104c1c:	00 00 00 
    iinit(ROOTDEV);
80104c1f:	83 ec 0c             	sub    $0xc,%esp
80104c22:	6a 01                	push   $0x1
80104c24:	e8 bf ca ff ff       	call   801016e8 <iinit>
80104c29:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104c2c:	83 ec 0c             	sub    $0xc,%esp
80104c2f:	6a 01                	push   $0x1
80104c31:	e8 f2 e7 ff ff       	call   80103428 <initlog>
80104c36:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104c39:	90                   	nop
80104c3a:	c9                   	leave  
80104c3b:	c3                   	ret    

80104c3c <sleep>:

// Atomically release lock and sleep on chan.ld: trap.o: in function `trap':
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c3c:	f3 0f 1e fb          	endbr32 
80104c40:	55                   	push   %ebp
80104c41:	89 e5                	mov    %esp,%ebp
80104c43:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104c46:	e8 48 f4 ff ff       	call   80104093 <myproc>
80104c4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104c4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c52:	75 0d                	jne    80104c61 <sleep+0x25>
    panic("sleep");
80104c54:	83 ec 0c             	sub    $0xc,%esp
80104c57:	68 0f b1 10 80       	push   $0x8010b10f
80104c5c:	e8 64 b9 ff ff       	call   801005c5 <panic>

  if(lk == 0)
80104c61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c65:	75 0d                	jne    80104c74 <sleep+0x38>
    panic("sleep without lk");
80104c67:	83 ec 0c             	sub    $0xc,%esp
80104c6a:	68 15 b1 10 80       	push   $0x8010b115
80104c6f:	e8 51 b9 ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c74:	81 7d 0c 40 85 11 80 	cmpl   $0x80118540,0xc(%ebp)
80104c7b:	74 1e                	je     80104c9b <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c7d:	83 ec 0c             	sub    $0xc,%esp
80104c80:	68 40 85 11 80       	push   $0x80118540
80104c85:	e8 5c 05 00 00       	call   801051e6 <acquire>
80104c8a:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104c8d:	83 ec 0c             	sub    $0xc,%esp
80104c90:	ff 75 0c             	pushl  0xc(%ebp)
80104c93:	e8 c0 05 00 00       	call   80105258 <release>
80104c98:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9e:	8b 55 08             	mov    0x8(%ebp),%edx
80104ca1:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104cae:	e8 44 fe ff ff       	call   80104af7 <sched>

  // Tidy up.
  p->chan = 0;
80104cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb6:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104cbd:	81 7d 0c 40 85 11 80 	cmpl   $0x80118540,0xc(%ebp)
80104cc4:	74 1e                	je     80104ce4 <sleep+0xa8>
    release(&ptable.lock);
80104cc6:	83 ec 0c             	sub    $0xc,%esp
80104cc9:	68 40 85 11 80       	push   $0x80118540
80104cce:	e8 85 05 00 00       	call   80105258 <release>
80104cd3:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104cd6:	83 ec 0c             	sub    $0xc,%esp
80104cd9:	ff 75 0c             	pushl  0xc(%ebp)
80104cdc:	e8 05 05 00 00       	call   801051e6 <acquire>
80104ce1:	83 c4 10             	add    $0x10,%esp
  }
}
80104ce4:	90                   	nop
80104ce5:	c9                   	leave  
80104ce6:	c3                   	ret    

80104ce7 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ce7:	f3 0f 1e fb          	endbr32 
80104ceb:	55                   	push   %ebp
80104cec:	89 e5                	mov    %esp,%ebp
80104cee:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cf1:	c7 45 fc 74 85 11 80 	movl   $0x80118574,-0x4(%ebp)
80104cf8:	eb 27                	jmp    80104d21 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104cfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cfd:	8b 40 0c             	mov    0xc(%eax),%eax
80104d00:	83 f8 02             	cmp    $0x2,%eax
80104d03:	75 15                	jne    80104d1a <wakeup1+0x33>
80104d05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d08:	8b 40 20             	mov    0x20(%eax),%eax
80104d0b:	39 45 08             	cmp    %eax,0x8(%ebp)
80104d0e:	75 0a                	jne    80104d1a <wakeup1+0x33>
      p->state = RUNNABLE;
80104d10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d13:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d1a:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80104d21:	81 7d fc 74 a9 11 80 	cmpl   $0x8011a974,-0x4(%ebp)
80104d28:	72 d0                	jb     80104cfa <wakeup1+0x13>
}
80104d2a:	90                   	nop
80104d2b:	90                   	nop
80104d2c:	c9                   	leave  
80104d2d:	c3                   	ret    

80104d2e <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104d2e:	f3 0f 1e fb          	endbr32 
80104d32:	55                   	push   %ebp
80104d33:	89 e5                	mov    %esp,%ebp
80104d35:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104d38:	83 ec 0c             	sub    $0xc,%esp
80104d3b:	68 40 85 11 80       	push   $0x80118540
80104d40:	e8 a1 04 00 00       	call   801051e6 <acquire>
80104d45:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104d48:	83 ec 0c             	sub    $0xc,%esp
80104d4b:	ff 75 08             	pushl  0x8(%ebp)
80104d4e:	e8 94 ff ff ff       	call   80104ce7 <wakeup1>
80104d53:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104d56:	83 ec 0c             	sub    $0xc,%esp
80104d59:	68 40 85 11 80       	push   $0x80118540
80104d5e:	e8 f5 04 00 00       	call   80105258 <release>
80104d63:	83 c4 10             	add    $0x10,%esp
}
80104d66:	90                   	nop
80104d67:	c9                   	leave  
80104d68:	c3                   	ret    

80104d69 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d69:	f3 0f 1e fb          	endbr32 
80104d6d:	55                   	push   %ebp
80104d6e:	89 e5                	mov    %esp,%ebp
80104d70:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d73:	83 ec 0c             	sub    $0xc,%esp
80104d76:	68 40 85 11 80       	push   $0x80118540
80104d7b:	e8 66 04 00 00       	call   801051e6 <acquire>
80104d80:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d83:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104d8a:	eb 48                	jmp    80104dd4 <kill+0x6b>
    if(p->pid == pid){
80104d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8f:	8b 40 10             	mov    0x10(%eax),%eax
80104d92:	39 45 08             	cmp    %eax,0x8(%ebp)
80104d95:	75 36                	jne    80104dcd <kill+0x64>
      p->killed = 1;
80104d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da4:	8b 40 0c             	mov    0xc(%eax),%eax
80104da7:	83 f8 02             	cmp    $0x2,%eax
80104daa:	75 0a                	jne    80104db6 <kill+0x4d>
        p->state = RUNNABLE;
80104dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104daf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104db6:	83 ec 0c             	sub    $0xc,%esp
80104db9:	68 40 85 11 80       	push   $0x80118540
80104dbe:	e8 95 04 00 00       	call   80105258 <release>
80104dc3:	83 c4 10             	add    $0x10,%esp
      return 0;
80104dc6:	b8 00 00 00 00       	mov    $0x0,%eax
80104dcb:	eb 25                	jmp    80104df2 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dcd:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104dd4:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
80104ddb:	72 af                	jb     80104d8c <kill+0x23>
    }
  }
  release(&ptable.lock);
80104ddd:	83 ec 0c             	sub    $0xc,%esp
80104de0:	68 40 85 11 80       	push   $0x80118540
80104de5:	e8 6e 04 00 00       	call   80105258 <release>
80104dea:	83 c4 10             	add    $0x10,%esp
  return -1;
80104ded:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104df2:	c9                   	leave  
80104df3:	c3                   	ret    

80104df4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104df4:	f3 0f 1e fb          	endbr32 
80104df8:	55                   	push   %ebp
80104df9:	89 e5                	mov    %esp,%ebp
80104dfb:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dfe:	c7 45 f0 74 85 11 80 	movl   $0x80118574,-0x10(%ebp)
80104e05:	e9 da 00 00 00       	jmp    80104ee4 <procdump+0xf0>
    if(p->state == UNUSED)
80104e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e0d:	8b 40 0c             	mov    0xc(%eax),%eax
80104e10:	85 c0                	test   %eax,%eax
80104e12:	0f 84 c4 00 00 00    	je     80104edc <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e1b:	8b 40 0c             	mov    0xc(%eax),%eax
80104e1e:	83 f8 05             	cmp    $0x5,%eax
80104e21:	77 23                	ja     80104e46 <procdump+0x52>
80104e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e26:	8b 40 0c             	mov    0xc(%eax),%eax
80104e29:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104e30:	85 c0                	test   %eax,%eax
80104e32:	74 12                	je     80104e46 <procdump+0x52>
      state = states[p->state];
80104e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e37:	8b 40 0c             	mov    0xc(%eax),%eax
80104e3a:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104e41:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e44:	eb 07                	jmp    80104e4d <procdump+0x59>
    else
      state = "???";
80104e46:	c7 45 ec 26 b1 10 80 	movl   $0x8010b126,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e50:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e56:	8b 40 10             	mov    0x10(%eax),%eax
80104e59:	52                   	push   %edx
80104e5a:	ff 75 ec             	pushl  -0x14(%ebp)
80104e5d:	50                   	push   %eax
80104e5e:	68 2a b1 10 80       	push   $0x8010b12a
80104e63:	e8 a4 b5 ff ff       	call   8010040c <cprintf>
80104e68:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e6e:	8b 40 0c             	mov    0xc(%eax),%eax
80104e71:	83 f8 02             	cmp    $0x2,%eax
80104e74:	75 54                	jne    80104eca <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e79:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e7c:	8b 40 0c             	mov    0xc(%eax),%eax
80104e7f:	83 c0 08             	add    $0x8,%eax
80104e82:	89 c2                	mov    %eax,%edx
80104e84:	83 ec 08             	sub    $0x8,%esp
80104e87:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104e8a:	50                   	push   %eax
80104e8b:	52                   	push   %edx
80104e8c:	e8 1d 04 00 00       	call   801052ae <getcallerpcs>
80104e91:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e9b:	eb 1c                	jmp    80104eb9 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea0:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ea4:	83 ec 08             	sub    $0x8,%esp
80104ea7:	50                   	push   %eax
80104ea8:	68 33 b1 10 80       	push   $0x8010b133
80104ead:	e8 5a b5 ff ff       	call   8010040c <cprintf>
80104eb2:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104eb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104eb9:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104ebd:	7f 0b                	jg     80104eca <procdump+0xd6>
80104ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ec6:	85 c0                	test   %eax,%eax
80104ec8:	75 d3                	jne    80104e9d <procdump+0xa9>
    }
    cprintf("\n");
80104eca:	83 ec 0c             	sub    $0xc,%esp
80104ecd:	68 37 b1 10 80       	push   $0x8010b137
80104ed2:	e8 35 b5 ff ff       	call   8010040c <cprintf>
80104ed7:	83 c4 10             	add    $0x10,%esp
80104eda:	eb 01                	jmp    80104edd <procdump+0xe9>
      continue;
80104edc:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104edd:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
80104ee4:	81 7d f0 74 a9 11 80 	cmpl   $0x8011a974,-0x10(%ebp)
80104eeb:	0f 82 19 ff ff ff    	jb     80104e0a <procdump+0x16>
  }
}
80104ef1:	90                   	nop
80104ef2:	90                   	nop
80104ef3:	c9                   	leave  
80104ef4:	c3                   	ret    

80104ef5 <printpt>:


pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc);
int
printpt(int pid)
{
80104ef5:	f3 0f 1e fb          	endbr32 
80104ef9:	55                   	push   %ebp
80104efa:	89 e5                	mov    %esp,%ebp
80104efc:	83 ec 28             	sub    $0x28,%esp
    struct proc* p = 0;
80104eff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    pde_t* pgdir;
    pte_t* pte;
    uint va;
    int found = 0;
80104f06:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    // 프로세스 테이블에서 해당 pid의 프로세스를 찾기
    acquire(&ptable.lock);
80104f0d:	83 ec 0c             	sub    $0xc,%esp
80104f10:	68 40 85 11 80       	push   $0x80118540
80104f15:	e8 cc 02 00 00       	call   801051e6 <acquire>
80104f1a:	83 c4 10             	add    $0x10,%esp
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104f1d:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104f24:	eb 1b                	jmp    80104f41 <printpt+0x4c>
        if (p->pid == pid) {
80104f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f29:	8b 40 10             	mov    0x10(%eax),%eax
80104f2c:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f2f:	75 09                	jne    80104f3a <printpt+0x45>
            found = 1;
80104f31:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
            break;
80104f38:	eb 10                	jmp    80104f4a <printpt+0x55>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104f3a:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104f41:	81 7d f4 74 a9 11 80 	cmpl   $0x8011a974,-0xc(%ebp)
80104f48:	72 dc                	jb     80104f26 <printpt+0x31>
        }
    }
    release(&ptable.lock);
80104f4a:	83 ec 0c             	sub    $0xc,%esp
80104f4d:	68 40 85 11 80       	push   $0x80118540
80104f52:	e8 01 03 00 00       	call   80105258 <release>
80104f57:	83 c4 10             	add    $0x10,%esp

    // 해당 프로세스가 존재하지 않거나, UNUSED 상태일 경우 -1 반환
    if (!found || p->state == UNUSED) {
80104f5a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104f5e:	74 0a                	je     80104f6a <printpt+0x75>
80104f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f63:	8b 40 0c             	mov    0xc(%eax),%eax
80104f66:	85 c0                	test   %eax,%eax
80104f68:	75 1d                	jne    80104f87 <printpt+0x92>
        cprintf("Process with pid %d not found or is in UNUSED state\n", pid);
80104f6a:	83 ec 08             	sub    $0x8,%esp
80104f6d:	ff 75 08             	pushl  0x8(%ebp)
80104f70:	68 3c b1 10 80       	push   $0x8010b13c
80104f75:	e8 92 b4 ff ff       	call   8010040c <cprintf>
80104f7a:	83 c4 10             	add    $0x10,%esp
        return -1;
80104f7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f82:	e9 ca 00 00 00       	jmp    80105051 <printpt+0x15c>
    }

    pgdir = p->pgdir;
80104f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f8a:	8b 40 04             	mov    0x4(%eax),%eax
80104f8d:	89 45 e8             	mov    %eax,-0x18(%ebp)

    cprintf("START PAGE TABLE (pid %d)\n", pid);
80104f90:	83 ec 08             	sub    $0x8,%esp
80104f93:	ff 75 08             	pushl  0x8(%ebp)
80104f96:	68 71 b1 10 80       	push   $0x8010b171
80104f9b:	e8 6c b4 ff ff       	call   8010040c <cprintf>
80104fa0:	83 c4 10             	add    $0x10,%esp
    for (va = 0; va < KERNBASE; va += PGSIZE) {
80104fa3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104faa:	e9 82 00 00 00       	jmp    80105031 <printpt+0x13c>
        pte = walkpgdir(pgdir, (void*)va, 0);
80104faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb2:	83 ec 04             	sub    $0x4,%esp
80104fb5:	6a 00                	push   $0x0
80104fb7:	50                   	push   %eax
80104fb8:	ff 75 e8             	pushl  -0x18(%ebp)
80104fbb:	e8 52 2e 00 00       	call   80107e12 <walkpgdir>
80104fc0:	83 c4 10             	add    $0x10,%esp
80104fc3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (pte && (*pte & PTE_P)) {
80104fc6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104fca:	74 5e                	je     8010502a <printpt+0x135>
80104fcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104fcf:	8b 00                	mov    (%eax),%eax
80104fd1:	83 e0 01             	and    $0x1,%eax
80104fd4:	85 c0                	test   %eax,%eax
80104fd6:	74 52                	je     8010502a <printpt+0x135>
            cprintf("VA: 0x%x P %s %s PA: 0x%x\n",
                va,
                (*pte & PTE_U) ? "U" : "K",
                (*pte & PTE_W) ? "W" : " - ",
                PTE_ADDR(*pte));
80104fd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104fdb:	8b 00                	mov    (%eax),%eax
            cprintf("VA: 0x%x P %s %s PA: 0x%x\n",
80104fdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104fe2:	89 c2                	mov    %eax,%edx
                (*pte & PTE_W) ? "W" : " - ",
80104fe4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104fe7:	8b 00                	mov    (%eax),%eax
80104fe9:	83 e0 02             	and    $0x2,%eax
            cprintf("VA: 0x%x P %s %s PA: 0x%x\n",
80104fec:	85 c0                	test   %eax,%eax
80104fee:	74 07                	je     80104ff7 <printpt+0x102>
80104ff0:	b9 8c b1 10 80       	mov    $0x8010b18c,%ecx
80104ff5:	eb 05                	jmp    80104ffc <printpt+0x107>
80104ff7:	b9 8e b1 10 80       	mov    $0x8010b18e,%ecx
                (*pte & PTE_U) ? "U" : "K",
80104ffc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104fff:	8b 00                	mov    (%eax),%eax
80105001:	83 e0 04             	and    $0x4,%eax
            cprintf("VA: 0x%x P %s %s PA: 0x%x\n",
80105004:	85 c0                	test   %eax,%eax
80105006:	74 07                	je     8010500f <printpt+0x11a>
80105008:	b8 92 b1 10 80       	mov    $0x8010b192,%eax
8010500d:	eb 05                	jmp    80105014 <printpt+0x11f>
8010500f:	b8 94 b1 10 80       	mov    $0x8010b194,%eax
80105014:	83 ec 0c             	sub    $0xc,%esp
80105017:	52                   	push   %edx
80105018:	51                   	push   %ecx
80105019:	50                   	push   %eax
8010501a:	ff 75 f0             	pushl  -0x10(%ebp)
8010501d:	68 96 b1 10 80       	push   $0x8010b196
80105022:	e8 e5 b3 ff ff       	call   8010040c <cprintf>
80105027:	83 c4 20             	add    $0x20,%esp
    for (va = 0; va < KERNBASE; va += PGSIZE) {
8010502a:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80105031:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105034:	85 c0                	test   %eax,%eax
80105036:	0f 89 73 ff ff ff    	jns    80104faf <printpt+0xba>
        }
    }
    cprintf("END PAGE TABLE\n");
8010503c:	83 ec 0c             	sub    $0xc,%esp
8010503f:	68 b1 b1 10 80       	push   $0x8010b1b1
80105044:	e8 c3 b3 ff ff       	call   8010040c <cprintf>
80105049:	83 c4 10             	add    $0x10,%esp
    return 0;
8010504c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105051:	c9                   	leave  
80105052:	c3                   	ret    

80105053 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105053:	f3 0f 1e fb          	endbr32 
80105057:	55                   	push   %ebp
80105058:	89 e5                	mov    %esp,%ebp
8010505a:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010505d:	8b 45 08             	mov    0x8(%ebp),%eax
80105060:	83 c0 04             	add    $0x4,%eax
80105063:	83 ec 08             	sub    $0x8,%esp
80105066:	68 eb b1 10 80       	push   $0x8010b1eb
8010506b:	50                   	push   %eax
8010506c:	e8 4f 01 00 00       	call   801051c0 <initlock>
80105071:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80105074:	8b 45 08             	mov    0x8(%ebp),%eax
80105077:	8b 55 0c             	mov    0xc(%ebp),%edx
8010507a:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
8010507d:	8b 45 08             	mov    0x8(%ebp),%eax
80105080:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105086:	8b 45 08             	mov    0x8(%ebp),%eax
80105089:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105090:	90                   	nop
80105091:	c9                   	leave  
80105092:	c3                   	ret    

80105093 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105093:	f3 0f 1e fb          	endbr32 
80105097:	55                   	push   %ebp
80105098:	89 e5                	mov    %esp,%ebp
8010509a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010509d:	8b 45 08             	mov    0x8(%ebp),%eax
801050a0:	83 c0 04             	add    $0x4,%eax
801050a3:	83 ec 0c             	sub    $0xc,%esp
801050a6:	50                   	push   %eax
801050a7:	e8 3a 01 00 00       	call   801051e6 <acquire>
801050ac:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801050af:	eb 15                	jmp    801050c6 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801050b1:	8b 45 08             	mov    0x8(%ebp),%eax
801050b4:	83 c0 04             	add    $0x4,%eax
801050b7:	83 ec 08             	sub    $0x8,%esp
801050ba:	50                   	push   %eax
801050bb:	ff 75 08             	pushl  0x8(%ebp)
801050be:	e8 79 fb ff ff       	call   80104c3c <sleep>
801050c3:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801050c6:	8b 45 08             	mov    0x8(%ebp),%eax
801050c9:	8b 00                	mov    (%eax),%eax
801050cb:	85 c0                	test   %eax,%eax
801050cd:	75 e2                	jne    801050b1 <acquiresleep+0x1e>
  }
  lk->locked = 1;
801050cf:	8b 45 08             	mov    0x8(%ebp),%eax
801050d2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801050d8:	e8 b6 ef ff ff       	call   80104093 <myproc>
801050dd:	8b 50 10             	mov    0x10(%eax),%edx
801050e0:	8b 45 08             	mov    0x8(%ebp),%eax
801050e3:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801050e6:	8b 45 08             	mov    0x8(%ebp),%eax
801050e9:	83 c0 04             	add    $0x4,%eax
801050ec:	83 ec 0c             	sub    $0xc,%esp
801050ef:	50                   	push   %eax
801050f0:	e8 63 01 00 00       	call   80105258 <release>
801050f5:	83 c4 10             	add    $0x10,%esp
}
801050f8:	90                   	nop
801050f9:	c9                   	leave  
801050fa:	c3                   	ret    

801050fb <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801050fb:	f3 0f 1e fb          	endbr32 
801050ff:	55                   	push   %ebp
80105100:	89 e5                	mov    %esp,%ebp
80105102:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105105:	8b 45 08             	mov    0x8(%ebp),%eax
80105108:	83 c0 04             	add    $0x4,%eax
8010510b:	83 ec 0c             	sub    $0xc,%esp
8010510e:	50                   	push   %eax
8010510f:	e8 d2 00 00 00       	call   801051e6 <acquire>
80105114:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105117:	8b 45 08             	mov    0x8(%ebp),%eax
8010511a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105120:	8b 45 08             	mov    0x8(%ebp),%eax
80105123:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010512a:	83 ec 0c             	sub    $0xc,%esp
8010512d:	ff 75 08             	pushl  0x8(%ebp)
80105130:	e8 f9 fb ff ff       	call   80104d2e <wakeup>
80105135:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80105138:	8b 45 08             	mov    0x8(%ebp),%eax
8010513b:	83 c0 04             	add    $0x4,%eax
8010513e:	83 ec 0c             	sub    $0xc,%esp
80105141:	50                   	push   %eax
80105142:	e8 11 01 00 00       	call   80105258 <release>
80105147:	83 c4 10             	add    $0x10,%esp
}
8010514a:	90                   	nop
8010514b:	c9                   	leave  
8010514c:	c3                   	ret    

8010514d <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010514d:	f3 0f 1e fb          	endbr32 
80105151:	55                   	push   %ebp
80105152:	89 e5                	mov    %esp,%ebp
80105154:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80105157:	8b 45 08             	mov    0x8(%ebp),%eax
8010515a:	83 c0 04             	add    $0x4,%eax
8010515d:	83 ec 0c             	sub    $0xc,%esp
80105160:	50                   	push   %eax
80105161:	e8 80 00 00 00       	call   801051e6 <acquire>
80105166:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80105169:	8b 45 08             	mov    0x8(%ebp),%eax
8010516c:	8b 00                	mov    (%eax),%eax
8010516e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105171:	8b 45 08             	mov    0x8(%ebp),%eax
80105174:	83 c0 04             	add    $0x4,%eax
80105177:	83 ec 0c             	sub    $0xc,%esp
8010517a:	50                   	push   %eax
8010517b:	e8 d8 00 00 00       	call   80105258 <release>
80105180:	83 c4 10             	add    $0x10,%esp
  return r;
80105183:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105186:	c9                   	leave  
80105187:	c3                   	ret    

80105188 <readeflags>:
{
80105188:	55                   	push   %ebp
80105189:	89 e5                	mov    %esp,%ebp
8010518b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010518e:	9c                   	pushf  
8010518f:	58                   	pop    %eax
80105190:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105193:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105196:	c9                   	leave  
80105197:	c3                   	ret    

80105198 <cli>:
{
80105198:	55                   	push   %ebp
80105199:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010519b:	fa                   	cli    
}
8010519c:	90                   	nop
8010519d:	5d                   	pop    %ebp
8010519e:	c3                   	ret    

8010519f <sti>:
{
8010519f:	55                   	push   %ebp
801051a0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801051a2:	fb                   	sti    
}
801051a3:	90                   	nop
801051a4:	5d                   	pop    %ebp
801051a5:	c3                   	ret    

801051a6 <xchg>:
{
801051a6:	55                   	push   %ebp
801051a7:	89 e5                	mov    %esp,%ebp
801051a9:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801051ac:	8b 55 08             	mov    0x8(%ebp),%edx
801051af:	8b 45 0c             	mov    0xc(%ebp),%eax
801051b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801051b5:	f0 87 02             	lock xchg %eax,(%edx)
801051b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801051bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051be:	c9                   	leave  
801051bf:	c3                   	ret    

801051c0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801051c0:	f3 0f 1e fb          	endbr32 
801051c4:	55                   	push   %ebp
801051c5:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801051c7:	8b 45 08             	mov    0x8(%ebp),%eax
801051ca:	8b 55 0c             	mov    0xc(%ebp),%edx
801051cd:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801051d0:	8b 45 08             	mov    0x8(%ebp),%eax
801051d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801051d9:	8b 45 08             	mov    0x8(%ebp),%eax
801051dc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051e3:	90                   	nop
801051e4:	5d                   	pop    %ebp
801051e5:	c3                   	ret    

801051e6 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051e6:	f3 0f 1e fb          	endbr32 
801051ea:	55                   	push   %ebp
801051eb:	89 e5                	mov    %esp,%ebp
801051ed:	53                   	push   %ebx
801051ee:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051f1:	e8 6c 01 00 00       	call   80105362 <pushcli>
  if(holding(lk)){
801051f6:	8b 45 08             	mov    0x8(%ebp),%eax
801051f9:	83 ec 0c             	sub    $0xc,%esp
801051fc:	50                   	push   %eax
801051fd:	e8 2b 01 00 00       	call   8010532d <holding>
80105202:	83 c4 10             	add    $0x10,%esp
80105205:	85 c0                	test   %eax,%eax
80105207:	74 0d                	je     80105216 <acquire+0x30>
    panic("acquire");
80105209:	83 ec 0c             	sub    $0xc,%esp
8010520c:	68 f6 b1 10 80       	push   $0x8010b1f6
80105211:	e8 af b3 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105216:	90                   	nop
80105217:	8b 45 08             	mov    0x8(%ebp),%eax
8010521a:	83 ec 08             	sub    $0x8,%esp
8010521d:	6a 01                	push   $0x1
8010521f:	50                   	push   %eax
80105220:	e8 81 ff ff ff       	call   801051a6 <xchg>
80105225:	83 c4 10             	add    $0x10,%esp
80105228:	85 c0                	test   %eax,%eax
8010522a:	75 eb                	jne    80105217 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010522c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105231:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105234:	e8 de ed ff ff       	call   80104017 <mycpu>
80105239:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010523c:	8b 45 08             	mov    0x8(%ebp),%eax
8010523f:	83 c0 0c             	add    $0xc,%eax
80105242:	83 ec 08             	sub    $0x8,%esp
80105245:	50                   	push   %eax
80105246:	8d 45 08             	lea    0x8(%ebp),%eax
80105249:	50                   	push   %eax
8010524a:	e8 5f 00 00 00       	call   801052ae <getcallerpcs>
8010524f:	83 c4 10             	add    $0x10,%esp
}
80105252:	90                   	nop
80105253:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105256:	c9                   	leave  
80105257:	c3                   	ret    

80105258 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105258:	f3 0f 1e fb          	endbr32 
8010525c:	55                   	push   %ebp
8010525d:	89 e5                	mov    %esp,%ebp
8010525f:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105262:	83 ec 0c             	sub    $0xc,%esp
80105265:	ff 75 08             	pushl  0x8(%ebp)
80105268:	e8 c0 00 00 00       	call   8010532d <holding>
8010526d:	83 c4 10             	add    $0x10,%esp
80105270:	85 c0                	test   %eax,%eax
80105272:	75 0d                	jne    80105281 <release+0x29>
    panic("release");
80105274:	83 ec 0c             	sub    $0xc,%esp
80105277:	68 fe b1 10 80       	push   $0x8010b1fe
8010527c:	e8 44 b3 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
80105281:	8b 45 08             	mov    0x8(%ebp),%eax
80105284:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010528b:	8b 45 08             	mov    0x8(%ebp),%eax
8010528e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105295:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010529a:	8b 45 08             	mov    0x8(%ebp),%eax
8010529d:	8b 55 08             	mov    0x8(%ebp),%edx
801052a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801052a6:	e8 08 01 00 00       	call   801053b3 <popcli>
}
801052ab:	90                   	nop
801052ac:	c9                   	leave  
801052ad:	c3                   	ret    

801052ae <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801052ae:	f3 0f 1e fb          	endbr32 
801052b2:	55                   	push   %ebp
801052b3:	89 e5                	mov    %esp,%ebp
801052b5:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801052b8:	8b 45 08             	mov    0x8(%ebp),%eax
801052bb:	83 e8 08             	sub    $0x8,%eax
801052be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801052c1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801052c8:	eb 38                	jmp    80105302 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801052ca:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801052ce:	74 53                	je     80105323 <getcallerpcs+0x75>
801052d0:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801052d7:	76 4a                	jbe    80105323 <getcallerpcs+0x75>
801052d9:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801052dd:	74 44                	je     80105323 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801052df:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ec:	01 c2                	add    %eax,%edx
801052ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f1:	8b 40 04             	mov    0x4(%eax),%eax
801052f4:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801052f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f9:	8b 00                	mov    (%eax),%eax
801052fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801052fe:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105302:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105306:	7e c2                	jle    801052ca <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80105308:	eb 19                	jmp    80105323 <getcallerpcs+0x75>
    pcs[i] = 0;
8010530a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010530d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105314:	8b 45 0c             	mov    0xc(%ebp),%eax
80105317:	01 d0                	add    %edx,%eax
80105319:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010531f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105323:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105327:	7e e1                	jle    8010530a <getcallerpcs+0x5c>
}
80105329:	90                   	nop
8010532a:	90                   	nop
8010532b:	c9                   	leave  
8010532c:	c3                   	ret    

8010532d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010532d:	f3 0f 1e fb          	endbr32 
80105331:	55                   	push   %ebp
80105332:	89 e5                	mov    %esp,%ebp
80105334:	53                   	push   %ebx
80105335:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105338:	8b 45 08             	mov    0x8(%ebp),%eax
8010533b:	8b 00                	mov    (%eax),%eax
8010533d:	85 c0                	test   %eax,%eax
8010533f:	74 16                	je     80105357 <holding+0x2a>
80105341:	8b 45 08             	mov    0x8(%ebp),%eax
80105344:	8b 58 08             	mov    0x8(%eax),%ebx
80105347:	e8 cb ec ff ff       	call   80104017 <mycpu>
8010534c:	39 c3                	cmp    %eax,%ebx
8010534e:	75 07                	jne    80105357 <holding+0x2a>
80105350:	b8 01 00 00 00       	mov    $0x1,%eax
80105355:	eb 05                	jmp    8010535c <holding+0x2f>
80105357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010535c:	83 c4 04             	add    $0x4,%esp
8010535f:	5b                   	pop    %ebx
80105360:	5d                   	pop    %ebp
80105361:	c3                   	ret    

80105362 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105362:	f3 0f 1e fb          	endbr32 
80105366:	55                   	push   %ebp
80105367:	89 e5                	mov    %esp,%ebp
80105369:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010536c:	e8 17 fe ff ff       	call   80105188 <readeflags>
80105371:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105374:	e8 1f fe ff ff       	call   80105198 <cli>
  if(mycpu()->ncli == 0)
80105379:	e8 99 ec ff ff       	call   80104017 <mycpu>
8010537e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105384:	85 c0                	test   %eax,%eax
80105386:	75 14                	jne    8010539c <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105388:	e8 8a ec ff ff       	call   80104017 <mycpu>
8010538d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105390:	81 e2 00 02 00 00    	and    $0x200,%edx
80105396:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010539c:	e8 76 ec ff ff       	call   80104017 <mycpu>
801053a1:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801053a7:	83 c2 01             	add    $0x1,%edx
801053aa:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801053b0:	90                   	nop
801053b1:	c9                   	leave  
801053b2:	c3                   	ret    

801053b3 <popcli>:

void
popcli(void)
{
801053b3:	f3 0f 1e fb          	endbr32 
801053b7:	55                   	push   %ebp
801053b8:	89 e5                	mov    %esp,%ebp
801053ba:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801053bd:	e8 c6 fd ff ff       	call   80105188 <readeflags>
801053c2:	25 00 02 00 00       	and    $0x200,%eax
801053c7:	85 c0                	test   %eax,%eax
801053c9:	74 0d                	je     801053d8 <popcli+0x25>
    panic("popcli - interruptible");
801053cb:	83 ec 0c             	sub    $0xc,%esp
801053ce:	68 06 b2 10 80       	push   $0x8010b206
801053d3:	e8 ed b1 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
801053d8:	e8 3a ec ff ff       	call   80104017 <mycpu>
801053dd:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801053e3:	83 ea 01             	sub    $0x1,%edx
801053e6:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801053ec:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801053f2:	85 c0                	test   %eax,%eax
801053f4:	79 0d                	jns    80105403 <popcli+0x50>
    panic("popcli");
801053f6:	83 ec 0c             	sub    $0xc,%esp
801053f9:	68 1d b2 10 80       	push   $0x8010b21d
801053fe:	e8 c2 b1 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105403:	e8 0f ec ff ff       	call   80104017 <mycpu>
80105408:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010540e:	85 c0                	test   %eax,%eax
80105410:	75 14                	jne    80105426 <popcli+0x73>
80105412:	e8 00 ec ff ff       	call   80104017 <mycpu>
80105417:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010541d:	85 c0                	test   %eax,%eax
8010541f:	74 05                	je     80105426 <popcli+0x73>
    sti();
80105421:	e8 79 fd ff ff       	call   8010519f <sti>
}
80105426:	90                   	nop
80105427:	c9                   	leave  
80105428:	c3                   	ret    

80105429 <stosb>:
{
80105429:	55                   	push   %ebp
8010542a:	89 e5                	mov    %esp,%ebp
8010542c:	57                   	push   %edi
8010542d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010542e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105431:	8b 55 10             	mov    0x10(%ebp),%edx
80105434:	8b 45 0c             	mov    0xc(%ebp),%eax
80105437:	89 cb                	mov    %ecx,%ebx
80105439:	89 df                	mov    %ebx,%edi
8010543b:	89 d1                	mov    %edx,%ecx
8010543d:	fc                   	cld    
8010543e:	f3 aa                	rep stos %al,%es:(%edi)
80105440:	89 ca                	mov    %ecx,%edx
80105442:	89 fb                	mov    %edi,%ebx
80105444:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105447:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010544a:	90                   	nop
8010544b:	5b                   	pop    %ebx
8010544c:	5f                   	pop    %edi
8010544d:	5d                   	pop    %ebp
8010544e:	c3                   	ret    

8010544f <stosl>:
{
8010544f:	55                   	push   %ebp
80105450:	89 e5                	mov    %esp,%ebp
80105452:	57                   	push   %edi
80105453:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105454:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105457:	8b 55 10             	mov    0x10(%ebp),%edx
8010545a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010545d:	89 cb                	mov    %ecx,%ebx
8010545f:	89 df                	mov    %ebx,%edi
80105461:	89 d1                	mov    %edx,%ecx
80105463:	fc                   	cld    
80105464:	f3 ab                	rep stos %eax,%es:(%edi)
80105466:	89 ca                	mov    %ecx,%edx
80105468:	89 fb                	mov    %edi,%ebx
8010546a:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010546d:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105470:	90                   	nop
80105471:	5b                   	pop    %ebx
80105472:	5f                   	pop    %edi
80105473:	5d                   	pop    %ebp
80105474:	c3                   	ret    

80105475 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105475:	f3 0f 1e fb          	endbr32 
80105479:	55                   	push   %ebp
8010547a:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010547c:	8b 45 08             	mov    0x8(%ebp),%eax
8010547f:	83 e0 03             	and    $0x3,%eax
80105482:	85 c0                	test   %eax,%eax
80105484:	75 43                	jne    801054c9 <memset+0x54>
80105486:	8b 45 10             	mov    0x10(%ebp),%eax
80105489:	83 e0 03             	and    $0x3,%eax
8010548c:	85 c0                	test   %eax,%eax
8010548e:	75 39                	jne    801054c9 <memset+0x54>
    c &= 0xFF;
80105490:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105497:	8b 45 10             	mov    0x10(%ebp),%eax
8010549a:	c1 e8 02             	shr    $0x2,%eax
8010549d:	89 c1                	mov    %eax,%ecx
8010549f:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a2:	c1 e0 18             	shl    $0x18,%eax
801054a5:	89 c2                	mov    %eax,%edx
801054a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054aa:	c1 e0 10             	shl    $0x10,%eax
801054ad:	09 c2                	or     %eax,%edx
801054af:	8b 45 0c             	mov    0xc(%ebp),%eax
801054b2:	c1 e0 08             	shl    $0x8,%eax
801054b5:	09 d0                	or     %edx,%eax
801054b7:	0b 45 0c             	or     0xc(%ebp),%eax
801054ba:	51                   	push   %ecx
801054bb:	50                   	push   %eax
801054bc:	ff 75 08             	pushl  0x8(%ebp)
801054bf:	e8 8b ff ff ff       	call   8010544f <stosl>
801054c4:	83 c4 0c             	add    $0xc,%esp
801054c7:	eb 12                	jmp    801054db <memset+0x66>
  } else
    stosb(dst, c, n);
801054c9:	8b 45 10             	mov    0x10(%ebp),%eax
801054cc:	50                   	push   %eax
801054cd:	ff 75 0c             	pushl  0xc(%ebp)
801054d0:	ff 75 08             	pushl  0x8(%ebp)
801054d3:	e8 51 ff ff ff       	call   80105429 <stosb>
801054d8:	83 c4 0c             	add    $0xc,%esp
  return dst;
801054db:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054de:	c9                   	leave  
801054df:	c3                   	ret    

801054e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801054e0:	f3 0f 1e fb          	endbr32 
801054e4:	55                   	push   %ebp
801054e5:	89 e5                	mov    %esp,%ebp
801054e7:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801054ea:	8b 45 08             	mov    0x8(%ebp),%eax
801054ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801054f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801054f6:	eb 30                	jmp    80105528 <memcmp+0x48>
    if(*s1 != *s2)
801054f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054fb:	0f b6 10             	movzbl (%eax),%edx
801054fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105501:	0f b6 00             	movzbl (%eax),%eax
80105504:	38 c2                	cmp    %al,%dl
80105506:	74 18                	je     80105520 <memcmp+0x40>
      return *s1 - *s2;
80105508:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010550b:	0f b6 00             	movzbl (%eax),%eax
8010550e:	0f b6 d0             	movzbl %al,%edx
80105511:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105514:	0f b6 00             	movzbl (%eax),%eax
80105517:	0f b6 c0             	movzbl %al,%eax
8010551a:	29 c2                	sub    %eax,%edx
8010551c:	89 d0                	mov    %edx,%eax
8010551e:	eb 1a                	jmp    8010553a <memcmp+0x5a>
    s1++, s2++;
80105520:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105524:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105528:	8b 45 10             	mov    0x10(%ebp),%eax
8010552b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010552e:	89 55 10             	mov    %edx,0x10(%ebp)
80105531:	85 c0                	test   %eax,%eax
80105533:	75 c3                	jne    801054f8 <memcmp+0x18>
  }

  return 0;
80105535:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010553a:	c9                   	leave  
8010553b:	c3                   	ret    

8010553c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010553c:	f3 0f 1e fb          	endbr32 
80105540:	55                   	push   %ebp
80105541:	89 e5                	mov    %esp,%ebp
80105543:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105546:	8b 45 0c             	mov    0xc(%ebp),%eax
80105549:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010554c:	8b 45 08             	mov    0x8(%ebp),%eax
8010554f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105552:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105555:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105558:	73 54                	jae    801055ae <memmove+0x72>
8010555a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010555d:	8b 45 10             	mov    0x10(%ebp),%eax
80105560:	01 d0                	add    %edx,%eax
80105562:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105565:	73 47                	jae    801055ae <memmove+0x72>
    s += n;
80105567:	8b 45 10             	mov    0x10(%ebp),%eax
8010556a:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010556d:	8b 45 10             	mov    0x10(%ebp),%eax
80105570:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105573:	eb 13                	jmp    80105588 <memmove+0x4c>
      *--d = *--s;
80105575:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105579:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010557d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105580:	0f b6 10             	movzbl (%eax),%edx
80105583:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105586:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105588:	8b 45 10             	mov    0x10(%ebp),%eax
8010558b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010558e:	89 55 10             	mov    %edx,0x10(%ebp)
80105591:	85 c0                	test   %eax,%eax
80105593:	75 e0                	jne    80105575 <memmove+0x39>
  if(s < d && s + n > d){
80105595:	eb 24                	jmp    801055bb <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105597:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010559a:	8d 42 01             	lea    0x1(%edx),%eax
8010559d:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055a3:	8d 48 01             	lea    0x1(%eax),%ecx
801055a6:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801055a9:	0f b6 12             	movzbl (%edx),%edx
801055ac:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801055ae:	8b 45 10             	mov    0x10(%ebp),%eax
801055b1:	8d 50 ff             	lea    -0x1(%eax),%edx
801055b4:	89 55 10             	mov    %edx,0x10(%ebp)
801055b7:	85 c0                	test   %eax,%eax
801055b9:	75 dc                	jne    80105597 <memmove+0x5b>

  return dst;
801055bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055be:	c9                   	leave  
801055bf:	c3                   	ret    

801055c0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801055c0:	f3 0f 1e fb          	endbr32 
801055c4:	55                   	push   %ebp
801055c5:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801055c7:	ff 75 10             	pushl  0x10(%ebp)
801055ca:	ff 75 0c             	pushl  0xc(%ebp)
801055cd:	ff 75 08             	pushl  0x8(%ebp)
801055d0:	e8 67 ff ff ff       	call   8010553c <memmove>
801055d5:	83 c4 0c             	add    $0xc,%esp
}
801055d8:	c9                   	leave  
801055d9:	c3                   	ret    

801055da <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801055da:	f3 0f 1e fb          	endbr32 
801055de:	55                   	push   %ebp
801055df:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801055e1:	eb 0c                	jmp    801055ef <strncmp+0x15>
    n--, p++, q++;
801055e3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055e7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801055eb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801055ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055f3:	74 1a                	je     8010560f <strncmp+0x35>
801055f5:	8b 45 08             	mov    0x8(%ebp),%eax
801055f8:	0f b6 00             	movzbl (%eax),%eax
801055fb:	84 c0                	test   %al,%al
801055fd:	74 10                	je     8010560f <strncmp+0x35>
801055ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105602:	0f b6 10             	movzbl (%eax),%edx
80105605:	8b 45 0c             	mov    0xc(%ebp),%eax
80105608:	0f b6 00             	movzbl (%eax),%eax
8010560b:	38 c2                	cmp    %al,%dl
8010560d:	74 d4                	je     801055e3 <strncmp+0x9>
  if(n == 0)
8010560f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105613:	75 07                	jne    8010561c <strncmp+0x42>
    return 0;
80105615:	b8 00 00 00 00       	mov    $0x0,%eax
8010561a:	eb 16                	jmp    80105632 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
8010561c:	8b 45 08             	mov    0x8(%ebp),%eax
8010561f:	0f b6 00             	movzbl (%eax),%eax
80105622:	0f b6 d0             	movzbl %al,%edx
80105625:	8b 45 0c             	mov    0xc(%ebp),%eax
80105628:	0f b6 00             	movzbl (%eax),%eax
8010562b:	0f b6 c0             	movzbl %al,%eax
8010562e:	29 c2                	sub    %eax,%edx
80105630:	89 d0                	mov    %edx,%eax
}
80105632:	5d                   	pop    %ebp
80105633:	c3                   	ret    

80105634 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105634:	f3 0f 1e fb          	endbr32 
80105638:	55                   	push   %ebp
80105639:	89 e5                	mov    %esp,%ebp
8010563b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010563e:	8b 45 08             	mov    0x8(%ebp),%eax
80105641:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105644:	90                   	nop
80105645:	8b 45 10             	mov    0x10(%ebp),%eax
80105648:	8d 50 ff             	lea    -0x1(%eax),%edx
8010564b:	89 55 10             	mov    %edx,0x10(%ebp)
8010564e:	85 c0                	test   %eax,%eax
80105650:	7e 2c                	jle    8010567e <strncpy+0x4a>
80105652:	8b 55 0c             	mov    0xc(%ebp),%edx
80105655:	8d 42 01             	lea    0x1(%edx),%eax
80105658:	89 45 0c             	mov    %eax,0xc(%ebp)
8010565b:	8b 45 08             	mov    0x8(%ebp),%eax
8010565e:	8d 48 01             	lea    0x1(%eax),%ecx
80105661:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105664:	0f b6 12             	movzbl (%edx),%edx
80105667:	88 10                	mov    %dl,(%eax)
80105669:	0f b6 00             	movzbl (%eax),%eax
8010566c:	84 c0                	test   %al,%al
8010566e:	75 d5                	jne    80105645 <strncpy+0x11>
    ;
  while(n-- > 0)
80105670:	eb 0c                	jmp    8010567e <strncpy+0x4a>
    *s++ = 0;
80105672:	8b 45 08             	mov    0x8(%ebp),%eax
80105675:	8d 50 01             	lea    0x1(%eax),%edx
80105678:	89 55 08             	mov    %edx,0x8(%ebp)
8010567b:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010567e:	8b 45 10             	mov    0x10(%ebp),%eax
80105681:	8d 50 ff             	lea    -0x1(%eax),%edx
80105684:	89 55 10             	mov    %edx,0x10(%ebp)
80105687:	85 c0                	test   %eax,%eax
80105689:	7f e7                	jg     80105672 <strncpy+0x3e>
  return os;
8010568b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010568e:	c9                   	leave  
8010568f:	c3                   	ret    

80105690 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105690:	f3 0f 1e fb          	endbr32 
80105694:	55                   	push   %ebp
80105695:	89 e5                	mov    %esp,%ebp
80105697:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010569a:	8b 45 08             	mov    0x8(%ebp),%eax
8010569d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801056a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056a4:	7f 05                	jg     801056ab <safestrcpy+0x1b>
    return os;
801056a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056a9:	eb 31                	jmp    801056dc <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801056ab:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056b3:	7e 1e                	jle    801056d3 <safestrcpy+0x43>
801056b5:	8b 55 0c             	mov    0xc(%ebp),%edx
801056b8:	8d 42 01             	lea    0x1(%edx),%eax
801056bb:	89 45 0c             	mov    %eax,0xc(%ebp)
801056be:	8b 45 08             	mov    0x8(%ebp),%eax
801056c1:	8d 48 01             	lea    0x1(%eax),%ecx
801056c4:	89 4d 08             	mov    %ecx,0x8(%ebp)
801056c7:	0f b6 12             	movzbl (%edx),%edx
801056ca:	88 10                	mov    %dl,(%eax)
801056cc:	0f b6 00             	movzbl (%eax),%eax
801056cf:	84 c0                	test   %al,%al
801056d1:	75 d8                	jne    801056ab <safestrcpy+0x1b>
    ;
  *s = 0;
801056d3:	8b 45 08             	mov    0x8(%ebp),%eax
801056d6:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801056d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056dc:	c9                   	leave  
801056dd:	c3                   	ret    

801056de <strlen>:

int
strlen(const char *s)
{
801056de:	f3 0f 1e fb          	endbr32 
801056e2:	55                   	push   %ebp
801056e3:	89 e5                	mov    %esp,%ebp
801056e5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801056e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801056ef:	eb 04                	jmp    801056f5 <strlen+0x17>
801056f1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056f5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056f8:	8b 45 08             	mov    0x8(%ebp),%eax
801056fb:	01 d0                	add    %edx,%eax
801056fd:	0f b6 00             	movzbl (%eax),%eax
80105700:	84 c0                	test   %al,%al
80105702:	75 ed                	jne    801056f1 <strlen+0x13>
    ;
  return n;
80105704:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105707:	c9                   	leave  
80105708:	c3                   	ret    

80105709 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105709:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010570d:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105711:	55                   	push   %ebp
  pushl %ebx
80105712:	53                   	push   %ebx
  pushl %esi
80105713:	56                   	push   %esi
  pushl %edi
80105714:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105715:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105717:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105719:	5f                   	pop    %edi
  popl %esi
8010571a:	5e                   	pop    %esi
  popl %ebx
8010571b:	5b                   	pop    %ebx
  popl %ebp
8010571c:	5d                   	pop    %ebp
  ret
8010571d:	c3                   	ret    

8010571e <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int* ip)
{
8010571e:	f3 0f 1e fb          	endbr32 
80105722:	55                   	push   %ebp
80105723:	89 e5                	mov    %esp,%ebp
    if(addr>=TOP || addr+4>TOP)
80105725:	81 7d 08 fe ff ff 7f 	cmpl   $0x7ffffffe,0x8(%ebp)
8010572c:	77 0a                	ja     80105738 <fetchint+0x1a>
8010572e:	8b 45 08             	mov    0x8(%ebp),%eax
80105731:	83 c0 04             	add    $0x4,%eax
80105734:	85 c0                	test   %eax,%eax
80105736:	79 07                	jns    8010573f <fetchint+0x21>
        return -1;
80105738:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010573d:	eb 0f                	jmp    8010574e <fetchint+0x30>
    *ip = *(int*)(addr);
8010573f:	8b 45 08             	mov    0x8(%ebp),%eax
80105742:	8b 10                	mov    (%eax),%edx
80105744:	8b 45 0c             	mov    0xc(%ebp),%eax
80105747:	89 10                	mov    %edx,(%eax)
    return 0;
80105749:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010574e:	5d                   	pop    %ebp
8010574f:	c3                   	ret    

80105750 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char** pp)
{
80105750:	f3 0f 1e fb          	endbr32 
80105754:	55                   	push   %ebp
80105755:	89 e5                	mov    %esp,%ebp
80105757:	83 ec 10             	sub    $0x10,%esp
    char* s, * ep;

    if (addr >= TOP)
8010575a:	81 7d 08 fe ff ff 7f 	cmpl   $0x7ffffffe,0x8(%ebp)
80105761:	76 07                	jbe    8010576a <fetchstr+0x1a>
        return -1;
80105763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105768:	eb 42                	jmp    801057ac <fetchstr+0x5c>
    *pp = (char*)addr;
8010576a:	8b 55 08             	mov    0x8(%ebp),%edx
8010576d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105770:	89 10                	mov    %edx,(%eax)
    ep = (char*)(TOP);
80105772:	c7 45 f8 ff ff ff 7f 	movl   $0x7fffffff,-0x8(%ebp)
    for (s = *pp; s < ep; s++) {
80105779:	8b 45 0c             	mov    0xc(%ebp),%eax
8010577c:	8b 00                	mov    (%eax),%eax
8010577e:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105781:	eb 1c                	jmp    8010579f <fetchstr+0x4f>
        if (*s == 0)
80105783:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105786:	0f b6 00             	movzbl (%eax),%eax
80105789:	84 c0                	test   %al,%al
8010578b:	75 0e                	jne    8010579b <fetchstr+0x4b>
            return s - *pp;
8010578d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105790:	8b 00                	mov    (%eax),%eax
80105792:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105795:	29 c2                	sub    %eax,%edx
80105797:	89 d0                	mov    %edx,%eax
80105799:	eb 11                	jmp    801057ac <fetchstr+0x5c>
    for (s = *pp; s < ep; s++) {
8010579b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010579f:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057a2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801057a5:	72 dc                	jb     80105783 <fetchstr+0x33>
    }
    return -1;
801057a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057ac:	c9                   	leave  
801057ad:	c3                   	ret    

801057ae <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int* ip)
{
801057ae:	f3 0f 1e fb          	endbr32 
801057b2:	55                   	push   %ebp
801057b3:	89 e5                	mov    %esp,%ebp
801057b5:	83 ec 08             	sub    $0x8,%esp
    return fetchint((myproc()->tf->esp) + 4 + 4 * n, ip);
801057b8:	e8 d6 e8 ff ff       	call   80104093 <myproc>
801057bd:	8b 40 18             	mov    0x18(%eax),%eax
801057c0:	8b 40 44             	mov    0x44(%eax),%eax
801057c3:	8b 55 08             	mov    0x8(%ebp),%edx
801057c6:	c1 e2 02             	shl    $0x2,%edx
801057c9:	01 d0                	add    %edx,%eax
801057cb:	83 c0 04             	add    $0x4,%eax
801057ce:	83 ec 08             	sub    $0x8,%esp
801057d1:	ff 75 0c             	pushl  0xc(%ebp)
801057d4:	50                   	push   %eax
801057d5:	e8 44 ff ff ff       	call   8010571e <fetchint>
801057da:	83 c4 10             	add    $0x10,%esp
}
801057dd:	c9                   	leave  
801057de:	c3                   	ret    

801057df <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char** pp, int size)
{
801057df:	f3 0f 1e fb          	endbr32 
801057e3:	55                   	push   %ebp
801057e4:	89 e5                	mov    %esp,%ebp
801057e6:	83 ec 18             	sub    $0x18,%esp
    int i;

    if (argint(n, &i) < 0)
801057e9:	83 ec 08             	sub    $0x8,%esp
801057ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057ef:	50                   	push   %eax
801057f0:	ff 75 08             	pushl  0x8(%ebp)
801057f3:	e8 b6 ff ff ff       	call   801057ae <argint>
801057f8:	83 c4 10             	add    $0x10,%esp
801057fb:	85 c0                	test   %eax,%eax
801057fd:	79 07                	jns    80105806 <argptr+0x27>
        return -1;
801057ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105804:	eb 34                	jmp    8010583a <argptr+0x5b>
    if (size < 0 || (uint)i >= (TOP) || (uint)i + size > (TOP))
80105806:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010580a:	78 18                	js     80105824 <argptr+0x45>
8010580c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010580f:	3d fe ff ff 7f       	cmp    $0x7ffffffe,%eax
80105814:	77 0e                	ja     80105824 <argptr+0x45>
80105816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105819:	89 c2                	mov    %eax,%edx
8010581b:	8b 45 10             	mov    0x10(%ebp),%eax
8010581e:	01 d0                	add    %edx,%eax
80105820:	85 c0                	test   %eax,%eax
80105822:	79 07                	jns    8010582b <argptr+0x4c>
        return -1;
80105824:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105829:	eb 0f                	jmp    8010583a <argptr+0x5b>
    *pp = (char*)i;
8010582b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582e:	89 c2                	mov    %eax,%edx
80105830:	8b 45 0c             	mov    0xc(%ebp),%eax
80105833:	89 10                	mov    %edx,(%eax)
    return 0;
80105835:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010583a:	c9                   	leave  
8010583b:	c3                   	ret    

8010583c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char** pp)
{
8010583c:	f3 0f 1e fb          	endbr32 
80105840:	55                   	push   %ebp
80105841:	89 e5                	mov    %esp,%ebp
80105843:	83 ec 18             	sub    $0x18,%esp
    int addr;
    if (argint(n, &addr) < 0)
80105846:	83 ec 08             	sub    $0x8,%esp
80105849:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010584c:	50                   	push   %eax
8010584d:	ff 75 08             	pushl  0x8(%ebp)
80105850:	e8 59 ff ff ff       	call   801057ae <argint>
80105855:	83 c4 10             	add    $0x10,%esp
80105858:	85 c0                	test   %eax,%eax
8010585a:	79 07                	jns    80105863 <argstr+0x27>
        return -1;
8010585c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105861:	eb 12                	jmp    80105875 <argstr+0x39>
    return fetchstr(addr, pp);
80105863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105866:	83 ec 08             	sub    $0x8,%esp
80105869:	ff 75 0c             	pushl  0xc(%ebp)
8010586c:	50                   	push   %eax
8010586d:	e8 de fe ff ff       	call   80105750 <fetchstr>
80105872:	83 c4 10             	add    $0x10,%esp
}
80105875:	c9                   	leave  
80105876:	c3                   	ret    

80105877 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80105877:	f3 0f 1e fb          	endbr32 
8010587b:	55                   	push   %ebp
8010587c:	89 e5                	mov    %esp,%ebp
8010587e:	83 ec 18             	sub    $0x18,%esp
    int num;
    struct proc* curproc = myproc();
80105881:	e8 0d e8 ff ff       	call   80104093 <myproc>
80105886:	89 45 f4             	mov    %eax,-0xc(%ebp)

    num = curproc->tf->eax;
80105889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588c:	8b 40 18             	mov    0x18(%eax),%eax
8010588f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105892:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105895:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105899:	7e 2f                	jle    801058ca <syscall+0x53>
8010589b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010589e:	83 f8 19             	cmp    $0x19,%eax
801058a1:	77 27                	ja     801058ca <syscall+0x53>
801058a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a6:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801058ad:	85 c0                	test   %eax,%eax
801058af:	74 19                	je     801058ca <syscall+0x53>
        curproc->tf->eax = syscalls[num]();
801058b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b4:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801058bb:	ff d0                	call   *%eax
801058bd:	89 c2                	mov    %eax,%edx
801058bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c2:	8b 40 18             	mov    0x18(%eax),%eax
801058c5:	89 50 1c             	mov    %edx,0x1c(%eax)
801058c8:	eb 2c                	jmp    801058f6 <syscall+0x7f>
    }
    else {
        cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801058ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058cd:	8d 50 6c             	lea    0x6c(%eax),%edx
        cprintf("%d %s: unknown sys call %d\n",
801058d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d3:	8b 40 10             	mov    0x10(%eax),%eax
801058d6:	ff 75 f0             	pushl  -0x10(%ebp)
801058d9:	52                   	push   %edx
801058da:	50                   	push   %eax
801058db:	68 24 b2 10 80       	push   $0x8010b224
801058e0:	e8 27 ab ff ff       	call   8010040c <cprintf>
801058e5:	83 c4 10             	add    $0x10,%esp
        curproc->tf->eax = -1;
801058e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058eb:	8b 40 18             	mov    0x18(%eax),%eax
801058ee:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
    }
801058f5:	90                   	nop
801058f6:	90                   	nop
801058f7:	c9                   	leave  
801058f8:	c3                   	ret    

801058f9 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801058f9:	f3 0f 1e fb          	endbr32 
801058fd:	55                   	push   %ebp
801058fe:	89 e5                	mov    %esp,%ebp
80105900:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105903:	83 ec 08             	sub    $0x8,%esp
80105906:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105909:	50                   	push   %eax
8010590a:	ff 75 08             	pushl  0x8(%ebp)
8010590d:	e8 9c fe ff ff       	call   801057ae <argint>
80105912:	83 c4 10             	add    $0x10,%esp
80105915:	85 c0                	test   %eax,%eax
80105917:	79 07                	jns    80105920 <argfd+0x27>
    return -1;
80105919:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591e:	eb 4f                	jmp    8010596f <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105920:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105923:	85 c0                	test   %eax,%eax
80105925:	78 20                	js     80105947 <argfd+0x4e>
80105927:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592a:	83 f8 0f             	cmp    $0xf,%eax
8010592d:	7f 18                	jg     80105947 <argfd+0x4e>
8010592f:	e8 5f e7 ff ff       	call   80104093 <myproc>
80105934:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105937:	83 c2 08             	add    $0x8,%edx
8010593a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010593e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105941:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105945:	75 07                	jne    8010594e <argfd+0x55>
    return -1;
80105947:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594c:	eb 21                	jmp    8010596f <argfd+0x76>
  if(pfd)
8010594e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105952:	74 08                	je     8010595c <argfd+0x63>
    *pfd = fd;
80105954:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105957:	8b 45 0c             	mov    0xc(%ebp),%eax
8010595a:	89 10                	mov    %edx,(%eax)
  if(pf)
8010595c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105960:	74 08                	je     8010596a <argfd+0x71>
    *pf = f;
80105962:	8b 45 10             	mov    0x10(%ebp),%eax
80105965:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105968:	89 10                	mov    %edx,(%eax)
  return 0;
8010596a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010596f:	c9                   	leave  
80105970:	c3                   	ret    

80105971 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105971:	f3 0f 1e fb          	endbr32 
80105975:	55                   	push   %ebp
80105976:	89 e5                	mov    %esp,%ebp
80105978:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010597b:	e8 13 e7 ff ff       	call   80104093 <myproc>
80105980:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105983:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010598a:	eb 2a                	jmp    801059b6 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
8010598c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105992:	83 c2 08             	add    $0x8,%edx
80105995:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105999:	85 c0                	test   %eax,%eax
8010599b:	75 15                	jne    801059b2 <fdalloc+0x41>
      curproc->ofile[fd] = f;
8010599d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059a3:	8d 4a 08             	lea    0x8(%edx),%ecx
801059a6:	8b 55 08             	mov    0x8(%ebp),%edx
801059a9:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801059ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b0:	eb 0f                	jmp    801059c1 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
801059b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801059b6:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801059ba:	7e d0                	jle    8010598c <fdalloc+0x1b>
    }
  }
  return -1;
801059bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059c1:	c9                   	leave  
801059c2:	c3                   	ret    

801059c3 <sys_dup>:

int
sys_dup(void)
{
801059c3:	f3 0f 1e fb          	endbr32 
801059c7:	55                   	push   %ebp
801059c8:	89 e5                	mov    %esp,%ebp
801059ca:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801059cd:	83 ec 04             	sub    $0x4,%esp
801059d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059d3:	50                   	push   %eax
801059d4:	6a 00                	push   $0x0
801059d6:	6a 00                	push   $0x0
801059d8:	e8 1c ff ff ff       	call   801058f9 <argfd>
801059dd:	83 c4 10             	add    $0x10,%esp
801059e0:	85 c0                	test   %eax,%eax
801059e2:	79 07                	jns    801059eb <sys_dup+0x28>
    return -1;
801059e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e9:	eb 31                	jmp    80105a1c <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801059eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ee:	83 ec 0c             	sub    $0xc,%esp
801059f1:	50                   	push   %eax
801059f2:	e8 7a ff ff ff       	call   80105971 <fdalloc>
801059f7:	83 c4 10             	add    $0x10,%esp
801059fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a01:	79 07                	jns    80105a0a <sys_dup+0x47>
    return -1;
80105a03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a08:	eb 12                	jmp    80105a1c <sys_dup+0x59>
  filedup(f);
80105a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0d:	83 ec 0c             	sub    $0xc,%esp
80105a10:	50                   	push   %eax
80105a11:	e8 70 b6 ff ff       	call   80101086 <filedup>
80105a16:	83 c4 10             	add    $0x10,%esp
  return fd;
80105a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105a1c:	c9                   	leave  
80105a1d:	c3                   	ret    

80105a1e <sys_read>:

int
sys_read(void)
{
80105a1e:	f3 0f 1e fb          	endbr32 
80105a22:	55                   	push   %ebp
80105a23:	89 e5                	mov    %esp,%ebp
80105a25:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a28:	83 ec 04             	sub    $0x4,%esp
80105a2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a2e:	50                   	push   %eax
80105a2f:	6a 00                	push   $0x0
80105a31:	6a 00                	push   $0x0
80105a33:	e8 c1 fe ff ff       	call   801058f9 <argfd>
80105a38:	83 c4 10             	add    $0x10,%esp
80105a3b:	85 c0                	test   %eax,%eax
80105a3d:	78 2e                	js     80105a6d <sys_read+0x4f>
80105a3f:	83 ec 08             	sub    $0x8,%esp
80105a42:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a45:	50                   	push   %eax
80105a46:	6a 02                	push   $0x2
80105a48:	e8 61 fd ff ff       	call   801057ae <argint>
80105a4d:	83 c4 10             	add    $0x10,%esp
80105a50:	85 c0                	test   %eax,%eax
80105a52:	78 19                	js     80105a6d <sys_read+0x4f>
80105a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a57:	83 ec 04             	sub    $0x4,%esp
80105a5a:	50                   	push   %eax
80105a5b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a5e:	50                   	push   %eax
80105a5f:	6a 01                	push   $0x1
80105a61:	e8 79 fd ff ff       	call   801057df <argptr>
80105a66:	83 c4 10             	add    $0x10,%esp
80105a69:	85 c0                	test   %eax,%eax
80105a6b:	79 07                	jns    80105a74 <sys_read+0x56>
    return -1;
80105a6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a72:	eb 17                	jmp    80105a8b <sys_read+0x6d>
  return fileread(f, p, n);
80105a74:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a77:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7d:	83 ec 04             	sub    $0x4,%esp
80105a80:	51                   	push   %ecx
80105a81:	52                   	push   %edx
80105a82:	50                   	push   %eax
80105a83:	e8 9a b7 ff ff       	call   80101222 <fileread>
80105a88:	83 c4 10             	add    $0x10,%esp
}
80105a8b:	c9                   	leave  
80105a8c:	c3                   	ret    

80105a8d <sys_write>:

int
sys_write(void)
{
80105a8d:	f3 0f 1e fb          	endbr32 
80105a91:	55                   	push   %ebp
80105a92:	89 e5                	mov    %esp,%ebp
80105a94:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a97:	83 ec 04             	sub    $0x4,%esp
80105a9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a9d:	50                   	push   %eax
80105a9e:	6a 00                	push   $0x0
80105aa0:	6a 00                	push   $0x0
80105aa2:	e8 52 fe ff ff       	call   801058f9 <argfd>
80105aa7:	83 c4 10             	add    $0x10,%esp
80105aaa:	85 c0                	test   %eax,%eax
80105aac:	78 2e                	js     80105adc <sys_write+0x4f>
80105aae:	83 ec 08             	sub    $0x8,%esp
80105ab1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ab4:	50                   	push   %eax
80105ab5:	6a 02                	push   $0x2
80105ab7:	e8 f2 fc ff ff       	call   801057ae <argint>
80105abc:	83 c4 10             	add    $0x10,%esp
80105abf:	85 c0                	test   %eax,%eax
80105ac1:	78 19                	js     80105adc <sys_write+0x4f>
80105ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac6:	83 ec 04             	sub    $0x4,%esp
80105ac9:	50                   	push   %eax
80105aca:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105acd:	50                   	push   %eax
80105ace:	6a 01                	push   $0x1
80105ad0:	e8 0a fd ff ff       	call   801057df <argptr>
80105ad5:	83 c4 10             	add    $0x10,%esp
80105ad8:	85 c0                	test   %eax,%eax
80105ada:	79 07                	jns    80105ae3 <sys_write+0x56>
    return -1;
80105adc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ae1:	eb 17                	jmp    80105afa <sys_write+0x6d>
  return filewrite(f, p, n);
80105ae3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ae6:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aec:	83 ec 04             	sub    $0x4,%esp
80105aef:	51                   	push   %ecx
80105af0:	52                   	push   %edx
80105af1:	50                   	push   %eax
80105af2:	e8 e7 b7 ff ff       	call   801012de <filewrite>
80105af7:	83 c4 10             	add    $0x10,%esp
}
80105afa:	c9                   	leave  
80105afb:	c3                   	ret    

80105afc <sys_close>:

int
sys_close(void)
{
80105afc:	f3 0f 1e fb          	endbr32 
80105b00:	55                   	push   %ebp
80105b01:	89 e5                	mov    %esp,%ebp
80105b03:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105b06:	83 ec 04             	sub    $0x4,%esp
80105b09:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b0c:	50                   	push   %eax
80105b0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b10:	50                   	push   %eax
80105b11:	6a 00                	push   $0x0
80105b13:	e8 e1 fd ff ff       	call   801058f9 <argfd>
80105b18:	83 c4 10             	add    $0x10,%esp
80105b1b:	85 c0                	test   %eax,%eax
80105b1d:	79 07                	jns    80105b26 <sys_close+0x2a>
    return -1;
80105b1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b24:	eb 27                	jmp    80105b4d <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105b26:	e8 68 e5 ff ff       	call   80104093 <myproc>
80105b2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b2e:	83 c2 08             	add    $0x8,%edx
80105b31:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b38:	00 
  fileclose(f);
80105b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b3c:	83 ec 0c             	sub    $0xc,%esp
80105b3f:	50                   	push   %eax
80105b40:	e8 96 b5 ff ff       	call   801010db <fileclose>
80105b45:	83 c4 10             	add    $0x10,%esp
  return 0;
80105b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b4d:	c9                   	leave  
80105b4e:	c3                   	ret    

80105b4f <sys_fstat>:

int
sys_fstat(void)
{
80105b4f:	f3 0f 1e fb          	endbr32 
80105b53:	55                   	push   %ebp
80105b54:	89 e5                	mov    %esp,%ebp
80105b56:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b59:	83 ec 04             	sub    $0x4,%esp
80105b5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b5f:	50                   	push   %eax
80105b60:	6a 00                	push   $0x0
80105b62:	6a 00                	push   $0x0
80105b64:	e8 90 fd ff ff       	call   801058f9 <argfd>
80105b69:	83 c4 10             	add    $0x10,%esp
80105b6c:	85 c0                	test   %eax,%eax
80105b6e:	78 17                	js     80105b87 <sys_fstat+0x38>
80105b70:	83 ec 04             	sub    $0x4,%esp
80105b73:	6a 14                	push   $0x14
80105b75:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b78:	50                   	push   %eax
80105b79:	6a 01                	push   $0x1
80105b7b:	e8 5f fc ff ff       	call   801057df <argptr>
80105b80:	83 c4 10             	add    $0x10,%esp
80105b83:	85 c0                	test   %eax,%eax
80105b85:	79 07                	jns    80105b8e <sys_fstat+0x3f>
    return -1;
80105b87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8c:	eb 13                	jmp    80105ba1 <sys_fstat+0x52>
  return filestat(f, st);
80105b8e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b94:	83 ec 08             	sub    $0x8,%esp
80105b97:	52                   	push   %edx
80105b98:	50                   	push   %eax
80105b99:	e8 29 b6 ff ff       	call   801011c7 <filestat>
80105b9e:	83 c4 10             	add    $0x10,%esp
}
80105ba1:	c9                   	leave  
80105ba2:	c3                   	ret    

80105ba3 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ba3:	f3 0f 1e fb          	endbr32 
80105ba7:	55                   	push   %ebp
80105ba8:	89 e5                	mov    %esp,%ebp
80105baa:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105bad:	83 ec 08             	sub    $0x8,%esp
80105bb0:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105bb3:	50                   	push   %eax
80105bb4:	6a 00                	push   $0x0
80105bb6:	e8 81 fc ff ff       	call   8010583c <argstr>
80105bbb:	83 c4 10             	add    $0x10,%esp
80105bbe:	85 c0                	test   %eax,%eax
80105bc0:	78 15                	js     80105bd7 <sys_link+0x34>
80105bc2:	83 ec 08             	sub    $0x8,%esp
80105bc5:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105bc8:	50                   	push   %eax
80105bc9:	6a 01                	push   $0x1
80105bcb:	e8 6c fc ff ff       	call   8010583c <argstr>
80105bd0:	83 c4 10             	add    $0x10,%esp
80105bd3:	85 c0                	test   %eax,%eax
80105bd5:	79 0a                	jns    80105be1 <sys_link+0x3e>
    return -1;
80105bd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bdc:	e9 68 01 00 00       	jmp    80105d49 <sys_link+0x1a6>

  begin_op();
80105be1:	e8 75 da ff ff       	call   8010365b <begin_op>
  if((ip = namei(old)) == 0){
80105be6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105be9:	83 ec 0c             	sub    $0xc,%esp
80105bec:	50                   	push   %eax
80105bed:	e8 e7 c9 ff ff       	call   801025d9 <namei>
80105bf2:	83 c4 10             	add    $0x10,%esp
80105bf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bf8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bfc:	75 0f                	jne    80105c0d <sys_link+0x6a>
    end_op();
80105bfe:	e8 e8 da ff ff       	call   801036eb <end_op>
    return -1;
80105c03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c08:	e9 3c 01 00 00       	jmp    80105d49 <sys_link+0x1a6>
  }

  ilock(ip);
80105c0d:	83 ec 0c             	sub    $0xc,%esp
80105c10:	ff 75 f4             	pushl  -0xc(%ebp)
80105c13:	e8 56 be ff ff       	call   80101a6e <ilock>
80105c18:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c22:	66 83 f8 01          	cmp    $0x1,%ax
80105c26:	75 1d                	jne    80105c45 <sys_link+0xa2>
    iunlockput(ip);
80105c28:	83 ec 0c             	sub    $0xc,%esp
80105c2b:	ff 75 f4             	pushl  -0xc(%ebp)
80105c2e:	e8 78 c0 ff ff       	call   80101cab <iunlockput>
80105c33:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c36:	e8 b0 da ff ff       	call   801036eb <end_op>
    return -1;
80105c3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c40:	e9 04 01 00 00       	jmp    80105d49 <sys_link+0x1a6>
  }

  ip->nlink++;
80105c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c48:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105c4c:	83 c0 01             	add    $0x1,%eax
80105c4f:	89 c2                	mov    %eax,%edx
80105c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c54:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105c58:	83 ec 0c             	sub    $0xc,%esp
80105c5b:	ff 75 f4             	pushl  -0xc(%ebp)
80105c5e:	e8 22 bc ff ff       	call   80101885 <iupdate>
80105c63:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105c66:	83 ec 0c             	sub    $0xc,%esp
80105c69:	ff 75 f4             	pushl  -0xc(%ebp)
80105c6c:	e8 14 bf ff ff       	call   80101b85 <iunlock>
80105c71:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105c74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c77:	83 ec 08             	sub    $0x8,%esp
80105c7a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c7d:	52                   	push   %edx
80105c7e:	50                   	push   %eax
80105c7f:	e8 75 c9 ff ff       	call   801025f9 <nameiparent>
80105c84:	83 c4 10             	add    $0x10,%esp
80105c87:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c8a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c8e:	74 71                	je     80105d01 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105c90:	83 ec 0c             	sub    $0xc,%esp
80105c93:	ff 75 f0             	pushl  -0x10(%ebp)
80105c96:	e8 d3 bd ff ff       	call   80101a6e <ilock>
80105c9b:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca1:	8b 10                	mov    (%eax),%edx
80105ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca6:	8b 00                	mov    (%eax),%eax
80105ca8:	39 c2                	cmp    %eax,%edx
80105caa:	75 1d                	jne    80105cc9 <sys_link+0x126>
80105cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caf:	8b 40 04             	mov    0x4(%eax),%eax
80105cb2:	83 ec 04             	sub    $0x4,%esp
80105cb5:	50                   	push   %eax
80105cb6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105cb9:	50                   	push   %eax
80105cba:	ff 75 f0             	pushl  -0x10(%ebp)
80105cbd:	e8 74 c6 ff ff       	call   80102336 <dirlink>
80105cc2:	83 c4 10             	add    $0x10,%esp
80105cc5:	85 c0                	test   %eax,%eax
80105cc7:	79 10                	jns    80105cd9 <sys_link+0x136>
    iunlockput(dp);
80105cc9:	83 ec 0c             	sub    $0xc,%esp
80105ccc:	ff 75 f0             	pushl  -0x10(%ebp)
80105ccf:	e8 d7 bf ff ff       	call   80101cab <iunlockput>
80105cd4:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105cd7:	eb 29                	jmp    80105d02 <sys_link+0x15f>
  }
  iunlockput(dp);
80105cd9:	83 ec 0c             	sub    $0xc,%esp
80105cdc:	ff 75 f0             	pushl  -0x10(%ebp)
80105cdf:	e8 c7 bf ff ff       	call   80101cab <iunlockput>
80105ce4:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105ce7:	83 ec 0c             	sub    $0xc,%esp
80105cea:	ff 75 f4             	pushl  -0xc(%ebp)
80105ced:	e8 e5 be ff ff       	call   80101bd7 <iput>
80105cf2:	83 c4 10             	add    $0x10,%esp

  end_op();
80105cf5:	e8 f1 d9 ff ff       	call   801036eb <end_op>

  return 0;
80105cfa:	b8 00 00 00 00       	mov    $0x0,%eax
80105cff:	eb 48                	jmp    80105d49 <sys_link+0x1a6>
    goto bad;
80105d01:	90                   	nop

bad:
  ilock(ip);
80105d02:	83 ec 0c             	sub    $0xc,%esp
80105d05:	ff 75 f4             	pushl  -0xc(%ebp)
80105d08:	e8 61 bd ff ff       	call   80101a6e <ilock>
80105d0d:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d13:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d17:	83 e8 01             	sub    $0x1,%eax
80105d1a:	89 c2                	mov    %eax,%edx
80105d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1f:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d23:	83 ec 0c             	sub    $0xc,%esp
80105d26:	ff 75 f4             	pushl  -0xc(%ebp)
80105d29:	e8 57 bb ff ff       	call   80101885 <iupdate>
80105d2e:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d31:	83 ec 0c             	sub    $0xc,%esp
80105d34:	ff 75 f4             	pushl  -0xc(%ebp)
80105d37:	e8 6f bf ff ff       	call   80101cab <iunlockput>
80105d3c:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d3f:	e8 a7 d9 ff ff       	call   801036eb <end_op>
  return -1;
80105d44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d49:	c9                   	leave  
80105d4a:	c3                   	ret    

80105d4b <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105d4b:	f3 0f 1e fb          	endbr32 
80105d4f:	55                   	push   %ebp
80105d50:	89 e5                	mov    %esp,%ebp
80105d52:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d55:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d5c:	eb 40                	jmp    80105d9e <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d61:	6a 10                	push   $0x10
80105d63:	50                   	push   %eax
80105d64:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d67:	50                   	push   %eax
80105d68:	ff 75 08             	pushl  0x8(%ebp)
80105d6b:	e8 06 c2 ff ff       	call   80101f76 <readi>
80105d70:	83 c4 10             	add    $0x10,%esp
80105d73:	83 f8 10             	cmp    $0x10,%eax
80105d76:	74 0d                	je     80105d85 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105d78:	83 ec 0c             	sub    $0xc,%esp
80105d7b:	68 40 b2 10 80       	push   $0x8010b240
80105d80:	e8 40 a8 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105d85:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105d89:	66 85 c0             	test   %ax,%ax
80105d8c:	74 07                	je     80105d95 <isdirempty+0x4a>
      return 0;
80105d8e:	b8 00 00 00 00       	mov    $0x0,%eax
80105d93:	eb 1b                	jmp    80105db0 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d98:	83 c0 10             	add    $0x10,%eax
80105d9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80105da1:	8b 50 58             	mov    0x58(%eax),%edx
80105da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da7:	39 c2                	cmp    %eax,%edx
80105da9:	77 b3                	ja     80105d5e <isdirempty+0x13>
  }
  return 1;
80105dab:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105db0:	c9                   	leave  
80105db1:	c3                   	ret    

80105db2 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105db2:	f3 0f 1e fb          	endbr32 
80105db6:	55                   	push   %ebp
80105db7:	89 e5                	mov    %esp,%ebp
80105db9:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105dbc:	83 ec 08             	sub    $0x8,%esp
80105dbf:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105dc2:	50                   	push   %eax
80105dc3:	6a 00                	push   $0x0
80105dc5:	e8 72 fa ff ff       	call   8010583c <argstr>
80105dca:	83 c4 10             	add    $0x10,%esp
80105dcd:	85 c0                	test   %eax,%eax
80105dcf:	79 0a                	jns    80105ddb <sys_unlink+0x29>
    return -1;
80105dd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd6:	e9 bf 01 00 00       	jmp    80105f9a <sys_unlink+0x1e8>

  begin_op();
80105ddb:	e8 7b d8 ff ff       	call   8010365b <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105de0:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105de3:	83 ec 08             	sub    $0x8,%esp
80105de6:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105de9:	52                   	push   %edx
80105dea:	50                   	push   %eax
80105deb:	e8 09 c8 ff ff       	call   801025f9 <nameiparent>
80105df0:	83 c4 10             	add    $0x10,%esp
80105df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105df6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dfa:	75 0f                	jne    80105e0b <sys_unlink+0x59>
    end_op();
80105dfc:	e8 ea d8 ff ff       	call   801036eb <end_op>
    return -1;
80105e01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e06:	e9 8f 01 00 00       	jmp    80105f9a <sys_unlink+0x1e8>
  }

  ilock(dp);
80105e0b:	83 ec 0c             	sub    $0xc,%esp
80105e0e:	ff 75 f4             	pushl  -0xc(%ebp)
80105e11:	e8 58 bc ff ff       	call   80101a6e <ilock>
80105e16:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e19:	83 ec 08             	sub    $0x8,%esp
80105e1c:	68 52 b2 10 80       	push   $0x8010b252
80105e21:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e24:	50                   	push   %eax
80105e25:	e8 2f c4 ff ff       	call   80102259 <namecmp>
80105e2a:	83 c4 10             	add    $0x10,%esp
80105e2d:	85 c0                	test   %eax,%eax
80105e2f:	0f 84 49 01 00 00    	je     80105f7e <sys_unlink+0x1cc>
80105e35:	83 ec 08             	sub    $0x8,%esp
80105e38:	68 54 b2 10 80       	push   $0x8010b254
80105e3d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e40:	50                   	push   %eax
80105e41:	e8 13 c4 ff ff       	call   80102259 <namecmp>
80105e46:	83 c4 10             	add    $0x10,%esp
80105e49:	85 c0                	test   %eax,%eax
80105e4b:	0f 84 2d 01 00 00    	je     80105f7e <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105e51:	83 ec 04             	sub    $0x4,%esp
80105e54:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105e57:	50                   	push   %eax
80105e58:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e5b:	50                   	push   %eax
80105e5c:	ff 75 f4             	pushl  -0xc(%ebp)
80105e5f:	e8 14 c4 ff ff       	call   80102278 <dirlookup>
80105e64:	83 c4 10             	add    $0x10,%esp
80105e67:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e6a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e6e:	0f 84 0d 01 00 00    	je     80105f81 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105e74:	83 ec 0c             	sub    $0xc,%esp
80105e77:	ff 75 f0             	pushl  -0x10(%ebp)
80105e7a:	e8 ef bb ff ff       	call   80101a6e <ilock>
80105e7f:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e85:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e89:	66 85 c0             	test   %ax,%ax
80105e8c:	7f 0d                	jg     80105e9b <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105e8e:	83 ec 0c             	sub    $0xc,%esp
80105e91:	68 57 b2 10 80       	push   $0x8010b257
80105e96:	e8 2a a7 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105ea2:	66 83 f8 01          	cmp    $0x1,%ax
80105ea6:	75 25                	jne    80105ecd <sys_unlink+0x11b>
80105ea8:	83 ec 0c             	sub    $0xc,%esp
80105eab:	ff 75 f0             	pushl  -0x10(%ebp)
80105eae:	e8 98 fe ff ff       	call   80105d4b <isdirempty>
80105eb3:	83 c4 10             	add    $0x10,%esp
80105eb6:	85 c0                	test   %eax,%eax
80105eb8:	75 13                	jne    80105ecd <sys_unlink+0x11b>
    iunlockput(ip);
80105eba:	83 ec 0c             	sub    $0xc,%esp
80105ebd:	ff 75 f0             	pushl  -0x10(%ebp)
80105ec0:	e8 e6 bd ff ff       	call   80101cab <iunlockput>
80105ec5:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ec8:	e9 b5 00 00 00       	jmp    80105f82 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105ecd:	83 ec 04             	sub    $0x4,%esp
80105ed0:	6a 10                	push   $0x10
80105ed2:	6a 00                	push   $0x0
80105ed4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ed7:	50                   	push   %eax
80105ed8:	e8 98 f5 ff ff       	call   80105475 <memset>
80105edd:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ee0:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ee3:	6a 10                	push   $0x10
80105ee5:	50                   	push   %eax
80105ee6:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ee9:	50                   	push   %eax
80105eea:	ff 75 f4             	pushl  -0xc(%ebp)
80105eed:	e8 dd c1 ff ff       	call   801020cf <writei>
80105ef2:	83 c4 10             	add    $0x10,%esp
80105ef5:	83 f8 10             	cmp    $0x10,%eax
80105ef8:	74 0d                	je     80105f07 <sys_unlink+0x155>
    panic("unlink: writei");
80105efa:	83 ec 0c             	sub    $0xc,%esp
80105efd:	68 69 b2 10 80       	push   $0x8010b269
80105f02:	e8 be a6 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f0e:	66 83 f8 01          	cmp    $0x1,%ax
80105f12:	75 21                	jne    80105f35 <sys_unlink+0x183>
    dp->nlink--;
80105f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f17:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f1b:	83 e8 01             	sub    $0x1,%eax
80105f1e:	89 c2                	mov    %eax,%edx
80105f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f23:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105f27:	83 ec 0c             	sub    $0xc,%esp
80105f2a:	ff 75 f4             	pushl  -0xc(%ebp)
80105f2d:	e8 53 b9 ff ff       	call   80101885 <iupdate>
80105f32:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105f35:	83 ec 0c             	sub    $0xc,%esp
80105f38:	ff 75 f4             	pushl  -0xc(%ebp)
80105f3b:	e8 6b bd ff ff       	call   80101cab <iunlockput>
80105f40:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f46:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f4a:	83 e8 01             	sub    $0x1,%eax
80105f4d:	89 c2                	mov    %eax,%edx
80105f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f52:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105f56:	83 ec 0c             	sub    $0xc,%esp
80105f59:	ff 75 f0             	pushl  -0x10(%ebp)
80105f5c:	e8 24 b9 ff ff       	call   80101885 <iupdate>
80105f61:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105f64:	83 ec 0c             	sub    $0xc,%esp
80105f67:	ff 75 f0             	pushl  -0x10(%ebp)
80105f6a:	e8 3c bd ff ff       	call   80101cab <iunlockput>
80105f6f:	83 c4 10             	add    $0x10,%esp

  end_op();
80105f72:	e8 74 d7 ff ff       	call   801036eb <end_op>

  return 0;
80105f77:	b8 00 00 00 00       	mov    $0x0,%eax
80105f7c:	eb 1c                	jmp    80105f9a <sys_unlink+0x1e8>
    goto bad;
80105f7e:	90                   	nop
80105f7f:	eb 01                	jmp    80105f82 <sys_unlink+0x1d0>
    goto bad;
80105f81:	90                   	nop

bad:
  iunlockput(dp);
80105f82:	83 ec 0c             	sub    $0xc,%esp
80105f85:	ff 75 f4             	pushl  -0xc(%ebp)
80105f88:	e8 1e bd ff ff       	call   80101cab <iunlockput>
80105f8d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105f90:	e8 56 d7 ff ff       	call   801036eb <end_op>
  return -1;
80105f95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f9a:	c9                   	leave  
80105f9b:	c3                   	ret    

80105f9c <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105f9c:	f3 0f 1e fb          	endbr32 
80105fa0:	55                   	push   %ebp
80105fa1:	89 e5                	mov    %esp,%ebp
80105fa3:	83 ec 38             	sub    $0x38,%esp
80105fa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105fa9:	8b 55 10             	mov    0x10(%ebp),%edx
80105fac:	8b 45 14             	mov    0x14(%ebp),%eax
80105faf:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105fb3:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105fb7:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105fbb:	83 ec 08             	sub    $0x8,%esp
80105fbe:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fc1:	50                   	push   %eax
80105fc2:	ff 75 08             	pushl  0x8(%ebp)
80105fc5:	e8 2f c6 ff ff       	call   801025f9 <nameiparent>
80105fca:	83 c4 10             	add    $0x10,%esp
80105fcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fd4:	75 0a                	jne    80105fe0 <create+0x44>
    return 0;
80105fd6:	b8 00 00 00 00       	mov    $0x0,%eax
80105fdb:	e9 90 01 00 00       	jmp    80106170 <create+0x1d4>
  ilock(dp);
80105fe0:	83 ec 0c             	sub    $0xc,%esp
80105fe3:	ff 75 f4             	pushl  -0xc(%ebp)
80105fe6:	e8 83 ba ff ff       	call   80101a6e <ilock>
80105feb:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105fee:	83 ec 04             	sub    $0x4,%esp
80105ff1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ff4:	50                   	push   %eax
80105ff5:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ff8:	50                   	push   %eax
80105ff9:	ff 75 f4             	pushl  -0xc(%ebp)
80105ffc:	e8 77 c2 ff ff       	call   80102278 <dirlookup>
80106001:	83 c4 10             	add    $0x10,%esp
80106004:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106007:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010600b:	74 50                	je     8010605d <create+0xc1>
    iunlockput(dp);
8010600d:	83 ec 0c             	sub    $0xc,%esp
80106010:	ff 75 f4             	pushl  -0xc(%ebp)
80106013:	e8 93 bc ff ff       	call   80101cab <iunlockput>
80106018:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010601b:	83 ec 0c             	sub    $0xc,%esp
8010601e:	ff 75 f0             	pushl  -0x10(%ebp)
80106021:	e8 48 ba ff ff       	call   80101a6e <ilock>
80106026:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106029:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010602e:	75 15                	jne    80106045 <create+0xa9>
80106030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106033:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106037:	66 83 f8 02          	cmp    $0x2,%ax
8010603b:	75 08                	jne    80106045 <create+0xa9>
      return ip;
8010603d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106040:	e9 2b 01 00 00       	jmp    80106170 <create+0x1d4>
    iunlockput(ip);
80106045:	83 ec 0c             	sub    $0xc,%esp
80106048:	ff 75 f0             	pushl  -0x10(%ebp)
8010604b:	e8 5b bc ff ff       	call   80101cab <iunlockput>
80106050:	83 c4 10             	add    $0x10,%esp
    return 0;
80106053:	b8 00 00 00 00       	mov    $0x0,%eax
80106058:	e9 13 01 00 00       	jmp    80106170 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010605d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106064:	8b 00                	mov    (%eax),%eax
80106066:	83 ec 08             	sub    $0x8,%esp
80106069:	52                   	push   %edx
8010606a:	50                   	push   %eax
8010606b:	e8 3a b7 ff ff       	call   801017aa <ialloc>
80106070:	83 c4 10             	add    $0x10,%esp
80106073:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106076:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010607a:	75 0d                	jne    80106089 <create+0xed>
    panic("create: ialloc");
8010607c:	83 ec 0c             	sub    $0xc,%esp
8010607f:	68 78 b2 10 80       	push   $0x8010b278
80106084:	e8 3c a5 ff ff       	call   801005c5 <panic>

  ilock(ip);
80106089:	83 ec 0c             	sub    $0xc,%esp
8010608c:	ff 75 f0             	pushl  -0x10(%ebp)
8010608f:	e8 da b9 ff ff       	call   80101a6e <ilock>
80106094:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106097:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010609e:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801060a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a5:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801060a9:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801060ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b0:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801060b6:	83 ec 0c             	sub    $0xc,%esp
801060b9:	ff 75 f0             	pushl  -0x10(%ebp)
801060bc:	e8 c4 b7 ff ff       	call   80101885 <iupdate>
801060c1:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801060c4:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801060c9:	75 6a                	jne    80106135 <create+0x199>
    dp->nlink++;  // for ".."
801060cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ce:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801060d2:	83 c0 01             	add    $0x1,%eax
801060d5:	89 c2                	mov    %eax,%edx
801060d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060da:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801060de:	83 ec 0c             	sub    $0xc,%esp
801060e1:	ff 75 f4             	pushl  -0xc(%ebp)
801060e4:	e8 9c b7 ff ff       	call   80101885 <iupdate>
801060e9:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801060ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ef:	8b 40 04             	mov    0x4(%eax),%eax
801060f2:	83 ec 04             	sub    $0x4,%esp
801060f5:	50                   	push   %eax
801060f6:	68 52 b2 10 80       	push   $0x8010b252
801060fb:	ff 75 f0             	pushl  -0x10(%ebp)
801060fe:	e8 33 c2 ff ff       	call   80102336 <dirlink>
80106103:	83 c4 10             	add    $0x10,%esp
80106106:	85 c0                	test   %eax,%eax
80106108:	78 1e                	js     80106128 <create+0x18c>
8010610a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610d:	8b 40 04             	mov    0x4(%eax),%eax
80106110:	83 ec 04             	sub    $0x4,%esp
80106113:	50                   	push   %eax
80106114:	68 54 b2 10 80       	push   $0x8010b254
80106119:	ff 75 f0             	pushl  -0x10(%ebp)
8010611c:	e8 15 c2 ff ff       	call   80102336 <dirlink>
80106121:	83 c4 10             	add    $0x10,%esp
80106124:	85 c0                	test   %eax,%eax
80106126:	79 0d                	jns    80106135 <create+0x199>
      panic("create dots");
80106128:	83 ec 0c             	sub    $0xc,%esp
8010612b:	68 87 b2 10 80       	push   $0x8010b287
80106130:	e8 90 a4 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106138:	8b 40 04             	mov    0x4(%eax),%eax
8010613b:	83 ec 04             	sub    $0x4,%esp
8010613e:	50                   	push   %eax
8010613f:	8d 45 de             	lea    -0x22(%ebp),%eax
80106142:	50                   	push   %eax
80106143:	ff 75 f4             	pushl  -0xc(%ebp)
80106146:	e8 eb c1 ff ff       	call   80102336 <dirlink>
8010614b:	83 c4 10             	add    $0x10,%esp
8010614e:	85 c0                	test   %eax,%eax
80106150:	79 0d                	jns    8010615f <create+0x1c3>
    panic("create: dirlink");
80106152:	83 ec 0c             	sub    $0xc,%esp
80106155:	68 93 b2 10 80       	push   $0x8010b293
8010615a:	e8 66 a4 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
8010615f:	83 ec 0c             	sub    $0xc,%esp
80106162:	ff 75 f4             	pushl  -0xc(%ebp)
80106165:	e8 41 bb ff ff       	call   80101cab <iunlockput>
8010616a:	83 c4 10             	add    $0x10,%esp

  return ip;
8010616d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106170:	c9                   	leave  
80106171:	c3                   	ret    

80106172 <sys_open>:

int
sys_open(void)
{
80106172:	f3 0f 1e fb          	endbr32 
80106176:	55                   	push   %ebp
80106177:	89 e5                	mov    %esp,%ebp
80106179:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010617c:	83 ec 08             	sub    $0x8,%esp
8010617f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106182:	50                   	push   %eax
80106183:	6a 00                	push   $0x0
80106185:	e8 b2 f6 ff ff       	call   8010583c <argstr>
8010618a:	83 c4 10             	add    $0x10,%esp
8010618d:	85 c0                	test   %eax,%eax
8010618f:	78 15                	js     801061a6 <sys_open+0x34>
80106191:	83 ec 08             	sub    $0x8,%esp
80106194:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106197:	50                   	push   %eax
80106198:	6a 01                	push   $0x1
8010619a:	e8 0f f6 ff ff       	call   801057ae <argint>
8010619f:	83 c4 10             	add    $0x10,%esp
801061a2:	85 c0                	test   %eax,%eax
801061a4:	79 0a                	jns    801061b0 <sys_open+0x3e>
    return -1;
801061a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061ab:	e9 61 01 00 00       	jmp    80106311 <sys_open+0x19f>

  begin_op();
801061b0:	e8 a6 d4 ff ff       	call   8010365b <begin_op>

  if(omode & O_CREATE){
801061b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061b8:	25 00 02 00 00       	and    $0x200,%eax
801061bd:	85 c0                	test   %eax,%eax
801061bf:	74 2a                	je     801061eb <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801061c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061c4:	6a 00                	push   $0x0
801061c6:	6a 00                	push   $0x0
801061c8:	6a 02                	push   $0x2
801061ca:	50                   	push   %eax
801061cb:	e8 cc fd ff ff       	call   80105f9c <create>
801061d0:	83 c4 10             	add    $0x10,%esp
801061d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801061d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061da:	75 75                	jne    80106251 <sys_open+0xdf>
      end_op();
801061dc:	e8 0a d5 ff ff       	call   801036eb <end_op>
      return -1;
801061e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e6:	e9 26 01 00 00       	jmp    80106311 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801061eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061ee:	83 ec 0c             	sub    $0xc,%esp
801061f1:	50                   	push   %eax
801061f2:	e8 e2 c3 ff ff       	call   801025d9 <namei>
801061f7:	83 c4 10             	add    $0x10,%esp
801061fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106201:	75 0f                	jne    80106212 <sys_open+0xa0>
      end_op();
80106203:	e8 e3 d4 ff ff       	call   801036eb <end_op>
      return -1;
80106208:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620d:	e9 ff 00 00 00       	jmp    80106311 <sys_open+0x19f>
    }
    ilock(ip);
80106212:	83 ec 0c             	sub    $0xc,%esp
80106215:	ff 75 f4             	pushl  -0xc(%ebp)
80106218:	e8 51 b8 ff ff       	call   80101a6e <ilock>
8010621d:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106223:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106227:	66 83 f8 01          	cmp    $0x1,%ax
8010622b:	75 24                	jne    80106251 <sys_open+0xdf>
8010622d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106230:	85 c0                	test   %eax,%eax
80106232:	74 1d                	je     80106251 <sys_open+0xdf>
      iunlockput(ip);
80106234:	83 ec 0c             	sub    $0xc,%esp
80106237:	ff 75 f4             	pushl  -0xc(%ebp)
8010623a:	e8 6c ba ff ff       	call   80101cab <iunlockput>
8010623f:	83 c4 10             	add    $0x10,%esp
      end_op();
80106242:	e8 a4 d4 ff ff       	call   801036eb <end_op>
      return -1;
80106247:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624c:	e9 c0 00 00 00       	jmp    80106311 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106251:	e8 bf ad ff ff       	call   80101015 <filealloc>
80106256:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106259:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010625d:	74 17                	je     80106276 <sys_open+0x104>
8010625f:	83 ec 0c             	sub    $0xc,%esp
80106262:	ff 75 f0             	pushl  -0x10(%ebp)
80106265:	e8 07 f7 ff ff       	call   80105971 <fdalloc>
8010626a:	83 c4 10             	add    $0x10,%esp
8010626d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106270:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106274:	79 2e                	jns    801062a4 <sys_open+0x132>
    if(f)
80106276:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010627a:	74 0e                	je     8010628a <sys_open+0x118>
      fileclose(f);
8010627c:	83 ec 0c             	sub    $0xc,%esp
8010627f:	ff 75 f0             	pushl  -0x10(%ebp)
80106282:	e8 54 ae ff ff       	call   801010db <fileclose>
80106287:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010628a:	83 ec 0c             	sub    $0xc,%esp
8010628d:	ff 75 f4             	pushl  -0xc(%ebp)
80106290:	e8 16 ba ff ff       	call   80101cab <iunlockput>
80106295:	83 c4 10             	add    $0x10,%esp
    end_op();
80106298:	e8 4e d4 ff ff       	call   801036eb <end_op>
    return -1;
8010629d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a2:	eb 6d                	jmp    80106311 <sys_open+0x19f>
  }
  iunlock(ip);
801062a4:	83 ec 0c             	sub    $0xc,%esp
801062a7:	ff 75 f4             	pushl  -0xc(%ebp)
801062aa:	e8 d6 b8 ff ff       	call   80101b85 <iunlock>
801062af:	83 c4 10             	add    $0x10,%esp
  end_op();
801062b2:	e8 34 d4 ff ff       	call   801036eb <end_op>

  f->type = FD_INODE;
801062b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ba:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801062c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062c6:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801062c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062cc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801062d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062d6:	83 e0 01             	and    $0x1,%eax
801062d9:	85 c0                	test   %eax,%eax
801062db:	0f 94 c0             	sete   %al
801062de:	89 c2                	mov    %eax,%edx
801062e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e3:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801062e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062e9:	83 e0 01             	and    $0x1,%eax
801062ec:	85 c0                	test   %eax,%eax
801062ee:	75 0a                	jne    801062fa <sys_open+0x188>
801062f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062f3:	83 e0 02             	and    $0x2,%eax
801062f6:	85 c0                	test   %eax,%eax
801062f8:	74 07                	je     80106301 <sys_open+0x18f>
801062fa:	b8 01 00 00 00       	mov    $0x1,%eax
801062ff:	eb 05                	jmp    80106306 <sys_open+0x194>
80106301:	b8 00 00 00 00       	mov    $0x0,%eax
80106306:	89 c2                	mov    %eax,%edx
80106308:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010630b:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010630e:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106311:	c9                   	leave  
80106312:	c3                   	ret    

80106313 <sys_mkdir>:

int
sys_mkdir(void)
{
80106313:	f3 0f 1e fb          	endbr32 
80106317:	55                   	push   %ebp
80106318:	89 e5                	mov    %esp,%ebp
8010631a:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010631d:	e8 39 d3 ff ff       	call   8010365b <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106322:	83 ec 08             	sub    $0x8,%esp
80106325:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106328:	50                   	push   %eax
80106329:	6a 00                	push   $0x0
8010632b:	e8 0c f5 ff ff       	call   8010583c <argstr>
80106330:	83 c4 10             	add    $0x10,%esp
80106333:	85 c0                	test   %eax,%eax
80106335:	78 1b                	js     80106352 <sys_mkdir+0x3f>
80106337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010633a:	6a 00                	push   $0x0
8010633c:	6a 00                	push   $0x0
8010633e:	6a 01                	push   $0x1
80106340:	50                   	push   %eax
80106341:	e8 56 fc ff ff       	call   80105f9c <create>
80106346:	83 c4 10             	add    $0x10,%esp
80106349:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010634c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106350:	75 0c                	jne    8010635e <sys_mkdir+0x4b>
    end_op();
80106352:	e8 94 d3 ff ff       	call   801036eb <end_op>
    return -1;
80106357:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635c:	eb 18                	jmp    80106376 <sys_mkdir+0x63>
  }
  iunlockput(ip);
8010635e:	83 ec 0c             	sub    $0xc,%esp
80106361:	ff 75 f4             	pushl  -0xc(%ebp)
80106364:	e8 42 b9 ff ff       	call   80101cab <iunlockput>
80106369:	83 c4 10             	add    $0x10,%esp
  end_op();
8010636c:	e8 7a d3 ff ff       	call   801036eb <end_op>
  return 0;
80106371:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106376:	c9                   	leave  
80106377:	c3                   	ret    

80106378 <sys_mknod>:

int
sys_mknod(void)
{
80106378:	f3 0f 1e fb          	endbr32 
8010637c:	55                   	push   %ebp
8010637d:	89 e5                	mov    %esp,%ebp
8010637f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106382:	e8 d4 d2 ff ff       	call   8010365b <begin_op>
  if((argstr(0, &path)) < 0 ||
80106387:	83 ec 08             	sub    $0x8,%esp
8010638a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010638d:	50                   	push   %eax
8010638e:	6a 00                	push   $0x0
80106390:	e8 a7 f4 ff ff       	call   8010583c <argstr>
80106395:	83 c4 10             	add    $0x10,%esp
80106398:	85 c0                	test   %eax,%eax
8010639a:	78 4f                	js     801063eb <sys_mknod+0x73>
     argint(1, &major) < 0 ||
8010639c:	83 ec 08             	sub    $0x8,%esp
8010639f:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063a2:	50                   	push   %eax
801063a3:	6a 01                	push   $0x1
801063a5:	e8 04 f4 ff ff       	call   801057ae <argint>
801063aa:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801063ad:	85 c0                	test   %eax,%eax
801063af:	78 3a                	js     801063eb <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801063b1:	83 ec 08             	sub    $0x8,%esp
801063b4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063b7:	50                   	push   %eax
801063b8:	6a 02                	push   $0x2
801063ba:	e8 ef f3 ff ff       	call   801057ae <argint>
801063bf:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801063c2:	85 c0                	test   %eax,%eax
801063c4:	78 25                	js     801063eb <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801063c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063c9:	0f bf c8             	movswl %ax,%ecx
801063cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801063cf:	0f bf d0             	movswl %ax,%edx
801063d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d5:	51                   	push   %ecx
801063d6:	52                   	push   %edx
801063d7:	6a 03                	push   $0x3
801063d9:	50                   	push   %eax
801063da:	e8 bd fb ff ff       	call   80105f9c <create>
801063df:	83 c4 10             	add    $0x10,%esp
801063e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801063e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063e9:	75 0c                	jne    801063f7 <sys_mknod+0x7f>
    end_op();
801063eb:	e8 fb d2 ff ff       	call   801036eb <end_op>
    return -1;
801063f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f5:	eb 18                	jmp    8010640f <sys_mknod+0x97>
  }
  iunlockput(ip);
801063f7:	83 ec 0c             	sub    $0xc,%esp
801063fa:	ff 75 f4             	pushl  -0xc(%ebp)
801063fd:	e8 a9 b8 ff ff       	call   80101cab <iunlockput>
80106402:	83 c4 10             	add    $0x10,%esp
  end_op();
80106405:	e8 e1 d2 ff ff       	call   801036eb <end_op>
  return 0;
8010640a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010640f:	c9                   	leave  
80106410:	c3                   	ret    

80106411 <sys_chdir>:

int
sys_chdir(void)
{
80106411:	f3 0f 1e fb          	endbr32 
80106415:	55                   	push   %ebp
80106416:	89 e5                	mov    %esp,%ebp
80106418:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010641b:	e8 73 dc ff ff       	call   80104093 <myproc>
80106420:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106423:	e8 33 d2 ff ff       	call   8010365b <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106428:	83 ec 08             	sub    $0x8,%esp
8010642b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010642e:	50                   	push   %eax
8010642f:	6a 00                	push   $0x0
80106431:	e8 06 f4 ff ff       	call   8010583c <argstr>
80106436:	83 c4 10             	add    $0x10,%esp
80106439:	85 c0                	test   %eax,%eax
8010643b:	78 18                	js     80106455 <sys_chdir+0x44>
8010643d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106440:	83 ec 0c             	sub    $0xc,%esp
80106443:	50                   	push   %eax
80106444:	e8 90 c1 ff ff       	call   801025d9 <namei>
80106449:	83 c4 10             	add    $0x10,%esp
8010644c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010644f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106453:	75 0c                	jne    80106461 <sys_chdir+0x50>
    end_op();
80106455:	e8 91 d2 ff ff       	call   801036eb <end_op>
    return -1;
8010645a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645f:	eb 68                	jmp    801064c9 <sys_chdir+0xb8>
  }
  ilock(ip);
80106461:	83 ec 0c             	sub    $0xc,%esp
80106464:	ff 75 f0             	pushl  -0x10(%ebp)
80106467:	e8 02 b6 ff ff       	call   80101a6e <ilock>
8010646c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010646f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106472:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106476:	66 83 f8 01          	cmp    $0x1,%ax
8010647a:	74 1a                	je     80106496 <sys_chdir+0x85>
    iunlockput(ip);
8010647c:	83 ec 0c             	sub    $0xc,%esp
8010647f:	ff 75 f0             	pushl  -0x10(%ebp)
80106482:	e8 24 b8 ff ff       	call   80101cab <iunlockput>
80106487:	83 c4 10             	add    $0x10,%esp
    end_op();
8010648a:	e8 5c d2 ff ff       	call   801036eb <end_op>
    return -1;
8010648f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106494:	eb 33                	jmp    801064c9 <sys_chdir+0xb8>
  }
  iunlock(ip);
80106496:	83 ec 0c             	sub    $0xc,%esp
80106499:	ff 75 f0             	pushl  -0x10(%ebp)
8010649c:	e8 e4 b6 ff ff       	call   80101b85 <iunlock>
801064a1:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801064a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a7:	8b 40 68             	mov    0x68(%eax),%eax
801064aa:	83 ec 0c             	sub    $0xc,%esp
801064ad:	50                   	push   %eax
801064ae:	e8 24 b7 ff ff       	call   80101bd7 <iput>
801064b3:	83 c4 10             	add    $0x10,%esp
  end_op();
801064b6:	e8 30 d2 ff ff       	call   801036eb <end_op>
  curproc->cwd = ip;
801064bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801064c1:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801064c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064c9:	c9                   	leave  
801064ca:	c3                   	ret    

801064cb <sys_exec>:

int
sys_exec(void)
{
801064cb:	f3 0f 1e fb          	endbr32 
801064cf:	55                   	push   %ebp
801064d0:	89 e5                	mov    %esp,%ebp
801064d2:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801064d8:	83 ec 08             	sub    $0x8,%esp
801064db:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064de:	50                   	push   %eax
801064df:	6a 00                	push   $0x0
801064e1:	e8 56 f3 ff ff       	call   8010583c <argstr>
801064e6:	83 c4 10             	add    $0x10,%esp
801064e9:	85 c0                	test   %eax,%eax
801064eb:	78 18                	js     80106505 <sys_exec+0x3a>
801064ed:	83 ec 08             	sub    $0x8,%esp
801064f0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801064f6:	50                   	push   %eax
801064f7:	6a 01                	push   $0x1
801064f9:	e8 b0 f2 ff ff       	call   801057ae <argint>
801064fe:	83 c4 10             	add    $0x10,%esp
80106501:	85 c0                	test   %eax,%eax
80106503:	79 0a                	jns    8010650f <sys_exec+0x44>
    return -1;
80106505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650a:	e9 c6 00 00 00       	jmp    801065d5 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
8010650f:	83 ec 04             	sub    $0x4,%esp
80106512:	68 80 00 00 00       	push   $0x80
80106517:	6a 00                	push   $0x0
80106519:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010651f:	50                   	push   %eax
80106520:	e8 50 ef ff ff       	call   80105475 <memset>
80106525:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106528:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010652f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106532:	83 f8 1f             	cmp    $0x1f,%eax
80106535:	76 0a                	jbe    80106541 <sys_exec+0x76>
      return -1;
80106537:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653c:	e9 94 00 00 00       	jmp    801065d5 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106544:	c1 e0 02             	shl    $0x2,%eax
80106547:	89 c2                	mov    %eax,%edx
80106549:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010654f:	01 c2                	add    %eax,%edx
80106551:	83 ec 08             	sub    $0x8,%esp
80106554:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010655a:	50                   	push   %eax
8010655b:	52                   	push   %edx
8010655c:	e8 bd f1 ff ff       	call   8010571e <fetchint>
80106561:	83 c4 10             	add    $0x10,%esp
80106564:	85 c0                	test   %eax,%eax
80106566:	79 07                	jns    8010656f <sys_exec+0xa4>
      return -1;
80106568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010656d:	eb 66                	jmp    801065d5 <sys_exec+0x10a>
    if(uarg == 0){
8010656f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106575:	85 c0                	test   %eax,%eax
80106577:	75 27                	jne    801065a0 <sys_exec+0xd5>
      argv[i] = 0;
80106579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106583:	00 00 00 00 
      break;
80106587:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106588:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010658b:	83 ec 08             	sub    $0x8,%esp
8010658e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106594:	52                   	push   %edx
80106595:	50                   	push   %eax
80106596:	e8 23 a6 ff ff       	call   80100bbe <exec>
8010659b:	83 c4 10             	add    $0x10,%esp
8010659e:	eb 35                	jmp    801065d5 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801065a0:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801065a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065a9:	c1 e2 02             	shl    $0x2,%edx
801065ac:	01 c2                	add    %eax,%edx
801065ae:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801065b4:	83 ec 08             	sub    $0x8,%esp
801065b7:	52                   	push   %edx
801065b8:	50                   	push   %eax
801065b9:	e8 92 f1 ff ff       	call   80105750 <fetchstr>
801065be:	83 c4 10             	add    $0x10,%esp
801065c1:	85 c0                	test   %eax,%eax
801065c3:	79 07                	jns    801065cc <sys_exec+0x101>
      return -1;
801065c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ca:	eb 09                	jmp    801065d5 <sys_exec+0x10a>
  for(i=0;; i++){
801065cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801065d0:	e9 5a ff ff ff       	jmp    8010652f <sys_exec+0x64>
}
801065d5:	c9                   	leave  
801065d6:	c3                   	ret    

801065d7 <sys_pipe>:

int
sys_pipe(void)
{
801065d7:	f3 0f 1e fb          	endbr32 
801065db:	55                   	push   %ebp
801065dc:	89 e5                	mov    %esp,%ebp
801065de:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801065e1:	83 ec 04             	sub    $0x4,%esp
801065e4:	6a 08                	push   $0x8
801065e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065e9:	50                   	push   %eax
801065ea:	6a 00                	push   $0x0
801065ec:	e8 ee f1 ff ff       	call   801057df <argptr>
801065f1:	83 c4 10             	add    $0x10,%esp
801065f4:	85 c0                	test   %eax,%eax
801065f6:	79 0a                	jns    80106602 <sys_pipe+0x2b>
    return -1;
801065f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065fd:	e9 ae 00 00 00       	jmp    801066b0 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106602:	83 ec 08             	sub    $0x8,%esp
80106605:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106608:	50                   	push   %eax
80106609:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010660c:	50                   	push   %eax
8010660d:	e8 a2 d5 ff ff       	call   80103bb4 <pipealloc>
80106612:	83 c4 10             	add    $0x10,%esp
80106615:	85 c0                	test   %eax,%eax
80106617:	79 0a                	jns    80106623 <sys_pipe+0x4c>
    return -1;
80106619:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010661e:	e9 8d 00 00 00       	jmp    801066b0 <sys_pipe+0xd9>
  fd0 = -1;
80106623:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010662a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010662d:	83 ec 0c             	sub    $0xc,%esp
80106630:	50                   	push   %eax
80106631:	e8 3b f3 ff ff       	call   80105971 <fdalloc>
80106636:	83 c4 10             	add    $0x10,%esp
80106639:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010663c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106640:	78 18                	js     8010665a <sys_pipe+0x83>
80106642:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106645:	83 ec 0c             	sub    $0xc,%esp
80106648:	50                   	push   %eax
80106649:	e8 23 f3 ff ff       	call   80105971 <fdalloc>
8010664e:	83 c4 10             	add    $0x10,%esp
80106651:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106654:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106658:	79 3e                	jns    80106698 <sys_pipe+0xc1>
    if(fd0 >= 0)
8010665a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010665e:	78 13                	js     80106673 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106660:	e8 2e da ff ff       	call   80104093 <myproc>
80106665:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106668:	83 c2 08             	add    $0x8,%edx
8010666b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106672:	00 
    fileclose(rf);
80106673:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106676:	83 ec 0c             	sub    $0xc,%esp
80106679:	50                   	push   %eax
8010667a:	e8 5c aa ff ff       	call   801010db <fileclose>
8010667f:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106682:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106685:	83 ec 0c             	sub    $0xc,%esp
80106688:	50                   	push   %eax
80106689:	e8 4d aa ff ff       	call   801010db <fileclose>
8010668e:	83 c4 10             	add    $0x10,%esp
    return -1;
80106691:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106696:	eb 18                	jmp    801066b0 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106698:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010669b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010669e:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801066a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066a3:	8d 50 04             	lea    0x4(%eax),%edx
801066a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066a9:	89 02                	mov    %eax,(%edx)
  return 0;
801066ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066b0:	c9                   	leave  
801066b1:	c3                   	ret    

801066b2 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801066b2:	f3 0f 1e fb          	endbr32 
801066b6:	55                   	push   %ebp
801066b7:	89 e5                	mov    %esp,%ebp
801066b9:	83 ec 08             	sub    $0x8,%esp
  return fork();
801066bc:	e8 f5 dc ff ff       	call   801043b6 <fork>
}
801066c1:	c9                   	leave  
801066c2:	c3                   	ret    

801066c3 <sys_exit>:

int
sys_exit(void)
{
801066c3:	f3 0f 1e fb          	endbr32 
801066c7:	55                   	push   %ebp
801066c8:	89 e5                	mov    %esp,%ebp
801066ca:	83 ec 08             	sub    $0x8,%esp
  exit();
801066cd:	e8 73 de ff ff       	call   80104545 <exit>
  return 0;  // not reached
801066d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066d7:	c9                   	leave  
801066d8:	c3                   	ret    

801066d9 <sys_wait>:

int
sys_wait(void)
{
801066d9:	f3 0f 1e fb          	endbr32 
801066dd:	55                   	push   %ebp
801066de:	89 e5                	mov    %esp,%ebp
801066e0:	83 ec 08             	sub    $0x8,%esp
  return wait();
801066e3:	e8 c1 e0 ff ff       	call   801047a9 <wait>
}
801066e8:	c9                   	leave  
801066e9:	c3                   	ret    

801066ea <sys_kill>:

int
sys_kill(void)
{
801066ea:	f3 0f 1e fb          	endbr32 
801066ee:	55                   	push   %ebp
801066ef:	89 e5                	mov    %esp,%ebp
801066f1:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801066f4:	83 ec 08             	sub    $0x8,%esp
801066f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066fa:	50                   	push   %eax
801066fb:	6a 00                	push   $0x0
801066fd:	e8 ac f0 ff ff       	call   801057ae <argint>
80106702:	83 c4 10             	add    $0x10,%esp
80106705:	85 c0                	test   %eax,%eax
80106707:	79 07                	jns    80106710 <sys_kill+0x26>
    return -1;
80106709:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010670e:	eb 0f                	jmp    8010671f <sys_kill+0x35>
  return kill(pid);
80106710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106713:	83 ec 0c             	sub    $0xc,%esp
80106716:	50                   	push   %eax
80106717:	e8 4d e6 ff ff       	call   80104d69 <kill>
8010671c:	83 c4 10             	add    $0x10,%esp
}
8010671f:	c9                   	leave  
80106720:	c3                   	ret    

80106721 <sys_getpid>:

int
sys_getpid(void)
{
80106721:	f3 0f 1e fb          	endbr32 
80106725:	55                   	push   %ebp
80106726:	89 e5                	mov    %esp,%ebp
80106728:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010672b:	e8 63 d9 ff ff       	call   80104093 <myproc>
80106730:	8b 40 10             	mov    0x10(%eax),%eax
}
80106733:	c9                   	leave  
80106734:	c3                   	ret    

80106735 <sys_sbrk>:

int
sys_sbrk(void)
{
80106735:	f3 0f 1e fb          	endbr32 
80106739:	55                   	push   %ebp
8010673a:	89 e5                	mov    %esp,%ebp
8010673c:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010673f:	83 ec 08             	sub    $0x8,%esp
80106742:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106745:	50                   	push   %eax
80106746:	6a 00                	push   $0x0
80106748:	e8 61 f0 ff ff       	call   801057ae <argint>
8010674d:	83 c4 10             	add    $0x10,%esp
80106750:	85 c0                	test   %eax,%eax
80106752:	79 07                	jns    8010675b <sys_sbrk+0x26>
    return -1;
80106754:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106759:	eb 27                	jmp    80106782 <sys_sbrk+0x4d>
  addr = myproc()->sz;
8010675b:	e8 33 d9 ff ff       	call   80104093 <myproc>
80106760:	8b 00                	mov    (%eax),%eax
80106762:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106768:	83 ec 0c             	sub    $0xc,%esp
8010676b:	50                   	push   %eax
8010676c:	e8 a6 db ff ff       	call   80104317 <growproc>
80106771:	83 c4 10             	add    $0x10,%esp
80106774:	85 c0                	test   %eax,%eax
80106776:	79 07                	jns    8010677f <sys_sbrk+0x4a>
    return -1;
80106778:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010677d:	eb 03                	jmp    80106782 <sys_sbrk+0x4d>
  return addr;
8010677f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106782:	c9                   	leave  
80106783:	c3                   	ret    

80106784 <sys_sleep>:

int
sys_sleep(void)
{
80106784:	f3 0f 1e fb          	endbr32 
80106788:	55                   	push   %ebp
80106789:	89 e5                	mov    %esp,%ebp
8010678b:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
8010678e:	83 ec 08             	sub    $0x8,%esp
80106791:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106794:	50                   	push   %eax
80106795:	6a 00                	push   $0x0
80106797:	e8 12 f0 ff ff       	call   801057ae <argint>
8010679c:	83 c4 10             	add    $0x10,%esp
8010679f:	85 c0                	test   %eax,%eax
801067a1:	79 07                	jns    801067aa <sys_sleep+0x26>
    return -1;
801067a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a8:	eb 76                	jmp    80106820 <sys_sleep+0x9c>
  acquire(&tickslock);
801067aa:	83 ec 0c             	sub    $0xc,%esp
801067ad:	68 80 a9 11 80       	push   $0x8011a980
801067b2:	e8 2f ea ff ff       	call   801051e6 <acquire>
801067b7:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801067ba:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
801067bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801067c2:	eb 38                	jmp    801067fc <sys_sleep+0x78>
    if(myproc()->killed){
801067c4:	e8 ca d8 ff ff       	call   80104093 <myproc>
801067c9:	8b 40 24             	mov    0x24(%eax),%eax
801067cc:	85 c0                	test   %eax,%eax
801067ce:	74 17                	je     801067e7 <sys_sleep+0x63>
      release(&tickslock);
801067d0:	83 ec 0c             	sub    $0xc,%esp
801067d3:	68 80 a9 11 80       	push   $0x8011a980
801067d8:	e8 7b ea ff ff       	call   80105258 <release>
801067dd:	83 c4 10             	add    $0x10,%esp
      return -1;
801067e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e5:	eb 39                	jmp    80106820 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801067e7:	83 ec 08             	sub    $0x8,%esp
801067ea:	68 80 a9 11 80       	push   $0x8011a980
801067ef:	68 c0 b1 11 80       	push   $0x8011b1c0
801067f4:	e8 43 e4 ff ff       	call   80104c3c <sleep>
801067f9:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801067fc:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
80106801:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106804:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106807:	39 d0                	cmp    %edx,%eax
80106809:	72 b9                	jb     801067c4 <sys_sleep+0x40>
  }
  release(&tickslock);
8010680b:	83 ec 0c             	sub    $0xc,%esp
8010680e:	68 80 a9 11 80       	push   $0x8011a980
80106813:	e8 40 ea ff ff       	call   80105258 <release>
80106818:	83 c4 10             	add    $0x10,%esp
  return 0;
8010681b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106820:	c9                   	leave  
80106821:	c3                   	ret    

80106822 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106822:	f3 0f 1e fb          	endbr32 
80106826:	55                   	push   %ebp
80106827:	89 e5                	mov    %esp,%ebp
80106829:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
8010682c:	83 ec 0c             	sub    $0xc,%esp
8010682f:	68 80 a9 11 80       	push   $0x8011a980
80106834:	e8 ad e9 ff ff       	call   801051e6 <acquire>
80106839:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010683c:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
80106841:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106844:	83 ec 0c             	sub    $0xc,%esp
80106847:	68 80 a9 11 80       	push   $0x8011a980
8010684c:	e8 07 ea ff ff       	call   80105258 <release>
80106851:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106854:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106857:	c9                   	leave  
80106858:	c3                   	ret    

80106859 <sys_exit2>:

int
sys_exit2(void)
{
80106859:	f3 0f 1e fb          	endbr32 
8010685d:	55                   	push   %ebp
8010685e:	89 e5                	mov    %esp,%ebp
80106860:	83 ec 18             	sub    $0x18,%esp
  int status;
  if(argint(0, &status) < 0)
80106863:	83 ec 08             	sub    $0x8,%esp
80106866:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106869:	50                   	push   %eax
8010686a:	6a 00                	push   $0x0
8010686c:	e8 3d ef ff ff       	call   801057ae <argint>
80106871:	83 c4 10             	add    $0x10,%esp
80106874:	85 c0                	test   %eax,%eax
80106876:	79 07                	jns    8010687f <sys_exit2+0x26>
    return -1; 
80106878:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687d:	eb 15                	jmp    80106894 <sys_exit2+0x3b>

  myproc()->xstate = status;
8010687f:	e8 0f d8 ff ff       	call   80104093 <myproc>
80106884:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106887:	89 50 7c             	mov    %edx,0x7c(%eax)
  exit();
8010688a:	e8 b6 dc ff ff       	call   80104545 <exit>
  return 0;
8010688f:	b8 00 00 00 00       	mov    $0x0,%eax
}	
80106894:	c9                   	leave  
80106895:	c3                   	ret    

80106896 <sys_wait2>:

extern int wait2(int *status);

int sys_wait2(void) 
{
80106896:	f3 0f 1e fb          	endbr32 
8010689a:	55                   	push   %ebp
8010689b:	89 e5                	mov    %esp,%ebp
8010689d:	83 ec 18             	sub    $0x18,%esp
  int *status;
  if(argptr(0, (void *)&status, sizeof(*status)) < 0)
801068a0:	83 ec 04             	sub    $0x4,%esp
801068a3:	6a 04                	push   $0x4
801068a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068a8:	50                   	push   %eax
801068a9:	6a 00                	push   $0x0
801068ab:	e8 2f ef ff ff       	call   801057df <argptr>
801068b0:	83 c4 10             	add    $0x10,%esp
801068b3:	85 c0                	test   %eax,%eax
801068b5:	79 07                	jns    801068be <sys_wait2+0x28>
    return -1;
801068b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068bc:	eb 0f                	jmp    801068cd <sys_wait2+0x37>
  return wait2(status);
801068be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c1:	83 ec 0c             	sub    $0xc,%esp
801068c4:	50                   	push   %eax
801068c5:	e8 06 e0 ff ff       	call   801048d0 <wait2>
801068ca:	83 c4 10             	add    $0x10,%esp
}
801068cd:	c9                   	leave  
801068ce:	c3                   	ret    

801068cf <sys_uthread_init>:

int
sys_uthread_init(void)
{
801068cf:	f3 0f 1e fb          	endbr32 
801068d3:	55                   	push   %ebp
801068d4:	89 e5                	mov    %esp,%ebp
801068d6:	83 ec 18             	sub    $0x18,%esp
    struct proc* p;
    int func;

    if (argint(0, &func) < 0)
801068d9:	83 ec 08             	sub    $0x8,%esp
801068dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068df:	50                   	push   %eax
801068e0:	6a 00                	push   $0x0
801068e2:	e8 c7 ee ff ff       	call   801057ae <argint>
801068e7:	83 c4 10             	add    $0x10,%esp
801068ea:	85 c0                	test   %eax,%eax
801068ec:	79 07                	jns    801068f5 <sys_uthread_init+0x26>
        return -1;
801068ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068f3:	eb 1b                	jmp    80106910 <sys_uthread_init+0x41>

    p = myproc();
801068f5:	e8 99 d7 ff ff       	call   80104093 <myproc>
801068fa:	89 45 f4             	mov    %eax,-0xc(%ebp)

    p->scheduler = (uint)func;
801068fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106900:	89 c2                	mov    %eax,%edx
80106902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106905:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

    return 0;
8010690b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106910:	c9                   	leave  
80106911:	c3                   	ret    

80106912 <sys_printpt>:

int sys_printpt(void) {
80106912:	f3 0f 1e fb          	endbr32 
80106916:	55                   	push   %ebp
80106917:	89 e5                	mov    %esp,%ebp
80106919:	83 ec 18             	sub    $0x18,%esp
    int pid;
    if(argint(0, &pid) < 0)
8010691c:	83 ec 08             	sub    $0x8,%esp
8010691f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106922:	50                   	push   %eax
80106923:	6a 00                	push   $0x0
80106925:	e8 84 ee ff ff       	call   801057ae <argint>
8010692a:	83 c4 10             	add    $0x10,%esp
8010692d:	85 c0                	test   %eax,%eax
8010692f:	79 07                	jns    80106938 <sys_printpt+0x26>
        return -1;
80106931:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106936:	eb 0f                	jmp    80106947 <sys_printpt+0x35>
    return printpt(pid);
80106938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010693b:	83 ec 0c             	sub    $0xc,%esp
8010693e:	50                   	push   %eax
8010693f:	e8 b1 e5 ff ff       	call   80104ef5 <printpt>
80106944:	83 c4 10             	add    $0x10,%esp
}
80106947:	c9                   	leave  
80106948:	c3                   	ret    

80106949 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106949:	1e                   	push   %ds
  pushl %es
8010694a:	06                   	push   %es
  pushl %fs
8010694b:	0f a0                	push   %fs
  pushl %gs
8010694d:	0f a8                	push   %gs
  pushal
8010694f:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106950:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106954:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106956:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106958:	54                   	push   %esp
  call trap
80106959:	e8 df 01 00 00       	call   80106b3d <trap>
  addl $4, %esp
8010695e:	83 c4 04             	add    $0x4,%esp

80106961 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106961:	61                   	popa   
  popl %gs
80106962:	0f a9                	pop    %gs
  popl %fs
80106964:	0f a1                	pop    %fs
  popl %es
80106966:	07                   	pop    %es
  popl %ds
80106967:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106968:	83 c4 08             	add    $0x8,%esp
  iret
8010696b:	cf                   	iret   

8010696c <lidt>:
{
8010696c:	55                   	push   %ebp
8010696d:	89 e5                	mov    %esp,%ebp
8010696f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106972:	8b 45 0c             	mov    0xc(%ebp),%eax
80106975:	83 e8 01             	sub    $0x1,%eax
80106978:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010697c:	8b 45 08             	mov    0x8(%ebp),%eax
8010697f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106983:	8b 45 08             	mov    0x8(%ebp),%eax
80106986:	c1 e8 10             	shr    $0x10,%eax
80106989:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010698d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106990:	0f 01 18             	lidtl  (%eax)
}
80106993:	90                   	nop
80106994:	c9                   	leave  
80106995:	c3                   	ret    

80106996 <rcr2>:

static inline uint
rcr2(void)
{
80106996:	55                   	push   %ebp
80106997:	89 e5                	mov    %esp,%ebp
80106999:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010699c:	0f 20 d0             	mov    %cr2,%eax
8010699f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801069a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801069a5:	c9                   	leave  
801069a6:	c3                   	ret    

801069a7 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801069a7:	f3 0f 1e fb          	endbr32 
801069ab:	55                   	push   %ebp
801069ac:	89 e5                	mov    %esp,%ebp
801069ae:	83 ec 18             	sub    $0x18,%esp
    int i;

    for (i = 0; i < 256; i++)
801069b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801069b8:	e9 c3 00 00 00       	jmp    80106a80 <tvinit+0xd9>
        SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
801069bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c0:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
801069c7:	89 c2                	mov    %eax,%edx
801069c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069cc:	66 89 14 c5 c0 a9 11 	mov    %dx,-0x7fee5640(,%eax,8)
801069d3:	80 
801069d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d7:	66 c7 04 c5 c2 a9 11 	movw   $0x8,-0x7fee563e(,%eax,8)
801069de:	80 08 00 
801069e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e4:	0f b6 14 c5 c4 a9 11 	movzbl -0x7fee563c(,%eax,8),%edx
801069eb:	80 
801069ec:	83 e2 e0             	and    $0xffffffe0,%edx
801069ef:	88 14 c5 c4 a9 11 80 	mov    %dl,-0x7fee563c(,%eax,8)
801069f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f9:	0f b6 14 c5 c4 a9 11 	movzbl -0x7fee563c(,%eax,8),%edx
80106a00:	80 
80106a01:	83 e2 1f             	and    $0x1f,%edx
80106a04:	88 14 c5 c4 a9 11 80 	mov    %dl,-0x7fee563c(,%eax,8)
80106a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0e:	0f b6 14 c5 c5 a9 11 	movzbl -0x7fee563b(,%eax,8),%edx
80106a15:	80 
80106a16:	83 e2 f0             	and    $0xfffffff0,%edx
80106a19:	83 ca 0e             	or     $0xe,%edx
80106a1c:	88 14 c5 c5 a9 11 80 	mov    %dl,-0x7fee563b(,%eax,8)
80106a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a26:	0f b6 14 c5 c5 a9 11 	movzbl -0x7fee563b(,%eax,8),%edx
80106a2d:	80 
80106a2e:	83 e2 ef             	and    $0xffffffef,%edx
80106a31:	88 14 c5 c5 a9 11 80 	mov    %dl,-0x7fee563b(,%eax,8)
80106a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a3b:	0f b6 14 c5 c5 a9 11 	movzbl -0x7fee563b(,%eax,8),%edx
80106a42:	80 
80106a43:	83 e2 9f             	and    $0xffffff9f,%edx
80106a46:	88 14 c5 c5 a9 11 80 	mov    %dl,-0x7fee563b(,%eax,8)
80106a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a50:	0f b6 14 c5 c5 a9 11 	movzbl -0x7fee563b(,%eax,8),%edx
80106a57:	80 
80106a58:	83 ca 80             	or     $0xffffff80,%edx
80106a5b:	88 14 c5 c5 a9 11 80 	mov    %dl,-0x7fee563b(,%eax,8)
80106a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a65:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106a6c:	c1 e8 10             	shr    $0x10,%eax
80106a6f:	89 c2                	mov    %eax,%edx
80106a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a74:	66 89 14 c5 c6 a9 11 	mov    %dx,-0x7fee563a(,%eax,8)
80106a7b:	80 
    for (i = 0; i < 256; i++)
80106a7c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a80:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106a87:	0f 8e 30 ff ff ff    	jle    801069bd <tvinit+0x16>
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
80106a8d:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106a92:	66 a3 c0 ab 11 80    	mov    %ax,0x8011abc0
80106a98:	66 c7 05 c2 ab 11 80 	movw   $0x8,0x8011abc2
80106a9f:	08 00 
80106aa1:	0f b6 05 c4 ab 11 80 	movzbl 0x8011abc4,%eax
80106aa8:	83 e0 e0             	and    $0xffffffe0,%eax
80106aab:	a2 c4 ab 11 80       	mov    %al,0x8011abc4
80106ab0:	0f b6 05 c4 ab 11 80 	movzbl 0x8011abc4,%eax
80106ab7:	83 e0 1f             	and    $0x1f,%eax
80106aba:	a2 c4 ab 11 80       	mov    %al,0x8011abc4
80106abf:	0f b6 05 c5 ab 11 80 	movzbl 0x8011abc5,%eax
80106ac6:	83 c8 0f             	or     $0xf,%eax
80106ac9:	a2 c5 ab 11 80       	mov    %al,0x8011abc5
80106ace:	0f b6 05 c5 ab 11 80 	movzbl 0x8011abc5,%eax
80106ad5:	83 e0 ef             	and    $0xffffffef,%eax
80106ad8:	a2 c5 ab 11 80       	mov    %al,0x8011abc5
80106add:	0f b6 05 c5 ab 11 80 	movzbl 0x8011abc5,%eax
80106ae4:	83 c8 60             	or     $0x60,%eax
80106ae7:	a2 c5 ab 11 80       	mov    %al,0x8011abc5
80106aec:	0f b6 05 c5 ab 11 80 	movzbl 0x8011abc5,%eax
80106af3:	83 c8 80             	or     $0xffffff80,%eax
80106af6:	a2 c5 ab 11 80       	mov    %al,0x8011abc5
80106afb:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106b00:	c1 e8 10             	shr    $0x10,%eax
80106b03:	66 a3 c6 ab 11 80    	mov    %ax,0x8011abc6

    initlock(&tickslock, "time");
80106b09:	83 ec 08             	sub    $0x8,%esp
80106b0c:	68 a4 b2 10 80       	push   $0x8010b2a4
80106b11:	68 80 a9 11 80       	push   $0x8011a980
80106b16:	e8 a5 e6 ff ff       	call   801051c0 <initlock>
80106b1b:	83 c4 10             	add    $0x10,%esp
}
80106b1e:	90                   	nop
80106b1f:	c9                   	leave  
80106b20:	c3                   	ret    

80106b21 <idtinit>:

void
idtinit(void)
{
80106b21:	f3 0f 1e fb          	endbr32 
80106b25:	55                   	push   %ebp
80106b26:	89 e5                	mov    %esp,%ebp
    lidt(idt, sizeof(idt));
80106b28:	68 00 08 00 00       	push   $0x800
80106b2d:	68 c0 a9 11 80       	push   $0x8011a9c0
80106b32:	e8 35 fe ff ff       	call   8010696c <lidt>
80106b37:	83 c4 08             	add    $0x8,%esp
}
80106b3a:	90                   	nop
80106b3b:	c9                   	leave  
80106b3c:	c3                   	ret    

80106b3d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe* tf)
{
80106b3d:	f3 0f 1e fb          	endbr32 
80106b41:	55                   	push   %ebp
80106b42:	89 e5                	mov    %esp,%ebp
80106b44:	57                   	push   %edi
80106b45:	56                   	push   %esi
80106b46:	53                   	push   %ebx
80106b47:	83 ec 2c             	sub    $0x2c,%esp
    if (tf->trapno == T_SYSCALL) {
80106b4a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b4d:	8b 40 30             	mov    0x30(%eax),%eax
80106b50:	83 f8 40             	cmp    $0x40,%eax
80106b53:	75 3b                	jne    80106b90 <trap+0x53>
        if (myproc()->killed)
80106b55:	e8 39 d5 ff ff       	call   80104093 <myproc>
80106b5a:	8b 40 24             	mov    0x24(%eax),%eax
80106b5d:	85 c0                	test   %eax,%eax
80106b5f:	74 05                	je     80106b66 <trap+0x29>
            exit();
80106b61:	e8 df d9 ff ff       	call   80104545 <exit>
        myproc()->tf = tf;
80106b66:	e8 28 d5 ff ff       	call   80104093 <myproc>
80106b6b:	8b 55 08             	mov    0x8(%ebp),%edx
80106b6e:	89 50 18             	mov    %edx,0x18(%eax)
        syscall();
80106b71:	e8 01 ed ff ff       	call   80105877 <syscall>
        if (myproc()->killed)
80106b76:	e8 18 d5 ff ff       	call   80104093 <myproc>
80106b7b:	8b 40 24             	mov    0x24(%eax),%eax
80106b7e:	85 c0                	test   %eax,%eax
80106b80:	0f 84 74 02 00 00    	je     80106dfa <trap+0x2bd>
            exit();
80106b86:	e8 ba d9 ff ff       	call   80104545 <exit>
        return;
80106b8b:	e9 6a 02 00 00       	jmp    80106dfa <trap+0x2bd>
    }

    switch (tf->trapno) {
80106b90:	8b 45 08             	mov    0x8(%ebp),%eax
80106b93:	8b 40 30             	mov    0x30(%eax),%eax
80106b96:	83 e8 0e             	sub    $0xe,%eax
80106b99:	83 f8 31             	cmp    $0x31,%eax
80106b9c:	0f 87 23 01 00 00    	ja     80106cc5 <trap+0x188>
80106ba2:	8b 04 85 4c b3 10 80 	mov    -0x7fef4cb4(,%eax,4),%eax
80106ba9:	3e ff e0             	notrack jmp *%eax
    case T_IRQ0 + IRQ_TIMER:
        if (cpuid() == 0) {
80106bac:	e8 47 d4 ff ff       	call   80103ff8 <cpuid>
80106bb1:	85 c0                	test   %eax,%eax
80106bb3:	75 3d                	jne    80106bf2 <trap+0xb5>
            acquire(&tickslock);
80106bb5:	83 ec 0c             	sub    $0xc,%esp
80106bb8:	68 80 a9 11 80       	push   $0x8011a980
80106bbd:	e8 24 e6 ff ff       	call   801051e6 <acquire>
80106bc2:	83 c4 10             	add    $0x10,%esp
            ticks++;
80106bc5:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
80106bca:	83 c0 01             	add    $0x1,%eax
80106bcd:	a3 c0 b1 11 80       	mov    %eax,0x8011b1c0
            wakeup(&ticks);
80106bd2:	83 ec 0c             	sub    $0xc,%esp
80106bd5:	68 c0 b1 11 80       	push   $0x8011b1c0
80106bda:	e8 4f e1 ff ff       	call   80104d2e <wakeup>
80106bdf:	83 c4 10             	add    $0x10,%esp
            release(&tickslock);
80106be2:	83 ec 0c             	sub    $0xc,%esp
80106be5:	68 80 a9 11 80       	push   $0x8011a980
80106bea:	e8 69 e6 ff ff       	call   80105258 <release>
80106bef:	83 c4 10             	add    $0x10,%esp
        }
        lapiceoi();
80106bf2:	e8 18 c5 ff ff       	call   8010310f <lapiceoi>
        break;
80106bf7:	e9 7e 01 00 00       	jmp    80106d7a <trap+0x23d>
    case T_IRQ0 + IRQ_IDE:
        ideintr();
80106bfc:	e8 25 bd ff ff       	call   80102926 <ideintr>
        lapiceoi();
80106c01:	e8 09 c5 ff ff       	call   8010310f <lapiceoi>
        break;
80106c06:	e9 6f 01 00 00       	jmp    80106d7a <trap+0x23d>
    case T_IRQ0 + IRQ_IDE + 1:
        // Bochs generates spurious IDE1 interrupts.
        break;
    case T_IRQ0 + IRQ_KBD:
        kbdintr();
80106c0b:	e8 35 c3 ff ff       	call   80102f45 <kbdintr>
        lapiceoi();
80106c10:	e8 fa c4 ff ff       	call   8010310f <lapiceoi>
        break;
80106c15:	e9 60 01 00 00       	jmp    80106d7a <trap+0x23d>
    case T_IRQ0 + IRQ_COM1:
        uartintr();
80106c1a:	e8 bd 03 00 00       	call   80106fdc <uartintr>
        lapiceoi();
80106c1f:	e8 eb c4 ff ff       	call   8010310f <lapiceoi>
        break;
80106c24:	e9 51 01 00 00       	jmp    80106d7a <trap+0x23d>
    case T_IRQ0 + 0xB:
        i8254_intr();
80106c29:	e8 87 2d 00 00       	call   801099b5 <i8254_intr>
        lapiceoi();
80106c2e:	e8 dc c4 ff ff       	call   8010310f <lapiceoi>
        break;
80106c33:	e9 42 01 00 00       	jmp    80106d7a <trap+0x23d>
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c38:	8b 45 08             	mov    0x8(%ebp),%eax
80106c3b:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80106c41:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c45:	0f b7 d8             	movzwl %ax,%ebx
80106c48:	e8 ab d3 ff ff       	call   80103ff8 <cpuid>
80106c4d:	56                   	push   %esi
80106c4e:	53                   	push   %ebx
80106c4f:	50                   	push   %eax
80106c50:	68 ac b2 10 80       	push   $0x8010b2ac
80106c55:	e8 b2 97 ff ff       	call   8010040c <cprintf>
80106c5a:	83 c4 10             	add    $0x10,%esp
        lapiceoi();
80106c5d:	e8 ad c4 ff ff       	call   8010310f <lapiceoi>
        break;
80106c62:	e9 13 01 00 00       	jmp    80106d7a <trap+0x23d>
        
    case T_PGFLT: {
        uint d = rcr2();
80106c67:	e8 2a fd ff ff       	call   80106996 <rcr2>
80106c6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (d > TOP) {
80106c6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c72:	85 c0                	test   %eax,%eax
80106c74:	79 05                	jns    80106c7b <trap+0x13e>
            exit();
80106c76:	e8 ca d8 ff ff       	call   80104545 <exit>
        }
        d = PGROUNDDOWN(d);
80106c7b:	81 65 e4 00 f0 ff ff 	andl   $0xfffff000,-0x1c(%ebp)
        if (allocuvm(myproc()->pgdir, d, d + PGSIZE) == 0) {
80106c82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c85:	8d 98 00 10 00 00    	lea    0x1000(%eax),%ebx
80106c8b:	e8 03 d4 ff ff       	call   80104093 <myproc>
80106c90:	8b 40 04             	mov    0x4(%eax),%eax
80106c93:	83 ec 04             	sub    $0x4,%esp
80106c96:	53                   	push   %ebx
80106c97:	ff 75 e4             	pushl  -0x1c(%ebp)
80106c9a:	50                   	push   %eax
80106c9b:	e8 b2 16 00 00       	call   80108352 <allocuvm>
80106ca0:	83 c4 10             	add    $0x10,%esp
80106ca3:	85 c0                	test   %eax,%eax
80106ca5:	75 05                	jne    80106cac <trap+0x16f>
            exit();
80106ca7:	e8 99 d8 ff ff       	call   80104545 <exit>
        }
        myproc()->stack_alloc++;
80106cac:	e8 e2 d3 ff ff       	call   80104093 <myproc>
80106cb1:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80106cb7:	83 c2 01             	add    $0x1,%edx
80106cba:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
        break;
80106cc0:	e9 b5 00 00 00       	jmp    80106d7a <trap+0x23d>
    }


        //PAGEBREAK: 13
    default:
        if (myproc() == 0 || (tf->cs & 3) == 0) {
80106cc5:	e8 c9 d3 ff ff       	call   80104093 <myproc>
80106cca:	85 c0                	test   %eax,%eax
80106ccc:	74 11                	je     80106cdf <trap+0x1a2>
80106cce:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cd5:	0f b7 c0             	movzwl %ax,%eax
80106cd8:	83 e0 03             	and    $0x3,%eax
80106cdb:	85 c0                	test   %eax,%eax
80106cdd:	75 39                	jne    80106d18 <trap+0x1db>
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106cdf:	e8 b2 fc ff ff       	call   80106996 <rcr2>
80106ce4:	89 c3                	mov    %eax,%ebx
80106ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce9:	8b 70 38             	mov    0x38(%eax),%esi
80106cec:	e8 07 d3 ff ff       	call   80103ff8 <cpuid>
80106cf1:	8b 55 08             	mov    0x8(%ebp),%edx
80106cf4:	8b 52 30             	mov    0x30(%edx),%edx
80106cf7:	83 ec 0c             	sub    $0xc,%esp
80106cfa:	53                   	push   %ebx
80106cfb:	56                   	push   %esi
80106cfc:	50                   	push   %eax
80106cfd:	52                   	push   %edx
80106cfe:	68 d0 b2 10 80       	push   $0x8010b2d0
80106d03:	e8 04 97 ff ff       	call   8010040c <cprintf>
80106d08:	83 c4 20             	add    $0x20,%esp
                tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
80106d0b:	83 ec 0c             	sub    $0xc,%esp
80106d0e:	68 02 b3 10 80       	push   $0x8010b302
80106d13:	e8 ad 98 ff ff       	call   801005c5 <panic>
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d18:	e8 79 fc ff ff       	call   80106996 <rcr2>
80106d1d:	89 c6                	mov    %eax,%esi
80106d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d22:	8b 40 38             	mov    0x38(%eax),%eax
80106d25:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106d28:	e8 cb d2 ff ff       	call   80103ff8 <cpuid>
80106d2d:	89 c3                	mov    %eax,%ebx
80106d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d32:	8b 48 34             	mov    0x34(%eax),%ecx
80106d35:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106d38:	8b 45 08             	mov    0x8(%ebp),%eax
80106d3b:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106d3e:	e8 50 d3 ff ff       	call   80104093 <myproc>
80106d43:	8d 50 6c             	lea    0x6c(%eax),%edx
80106d46:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106d49:	e8 45 d3 ff ff       	call   80104093 <myproc>
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d4e:	8b 40 10             	mov    0x10(%eax),%eax
80106d51:	56                   	push   %esi
80106d52:	ff 75 d4             	pushl  -0x2c(%ebp)
80106d55:	53                   	push   %ebx
80106d56:	ff 75 d0             	pushl  -0x30(%ebp)
80106d59:	57                   	push   %edi
80106d5a:	ff 75 cc             	pushl  -0x34(%ebp)
80106d5d:	50                   	push   %eax
80106d5e:	68 08 b3 10 80       	push   $0x8010b308
80106d63:	e8 a4 96 ff ff       	call   8010040c <cprintf>
80106d68:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
80106d6b:	e8 23 d3 ff ff       	call   80104093 <myproc>
80106d70:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106d77:	eb 01                	jmp    80106d7a <trap+0x23d>
        break;
80106d79:	90                   	nop
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106d7a:	e8 14 d3 ff ff       	call   80104093 <myproc>
80106d7f:	85 c0                	test   %eax,%eax
80106d81:	74 23                	je     80106da6 <trap+0x269>
80106d83:	e8 0b d3 ff ff       	call   80104093 <myproc>
80106d88:	8b 40 24             	mov    0x24(%eax),%eax
80106d8b:	85 c0                	test   %eax,%eax
80106d8d:	74 17                	je     80106da6 <trap+0x269>
80106d8f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d92:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d96:	0f b7 c0             	movzwl %ax,%eax
80106d99:	83 e0 03             	and    $0x3,%eax
80106d9c:	83 f8 03             	cmp    $0x3,%eax
80106d9f:	75 05                	jne    80106da6 <trap+0x269>
        exit();
80106da1:	e8 9f d7 ff ff       	call   80104545 <exit>

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
80106da6:	e8 e8 d2 ff ff       	call   80104093 <myproc>
80106dab:	85 c0                	test   %eax,%eax
80106dad:	74 1d                	je     80106dcc <trap+0x28f>
80106daf:	e8 df d2 ff ff       	call   80104093 <myproc>
80106db4:	8b 40 0c             	mov    0xc(%eax),%eax
80106db7:	83 f8 04             	cmp    $0x4,%eax
80106dba:	75 10                	jne    80106dcc <trap+0x28f>
        tf->trapno == T_IRQ0 + IRQ_TIMER)
80106dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80106dbf:	8b 40 30             	mov    0x30(%eax),%eax
    if (myproc() && myproc()->state == RUNNING &&
80106dc2:	83 f8 20             	cmp    $0x20,%eax
80106dc5:	75 05                	jne    80106dcc <trap+0x28f>
        yield();
80106dc7:	e8 e8 dd ff ff       	call   80104bb4 <yield>

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106dcc:	e8 c2 d2 ff ff       	call   80104093 <myproc>
80106dd1:	85 c0                	test   %eax,%eax
80106dd3:	74 26                	je     80106dfb <trap+0x2be>
80106dd5:	e8 b9 d2 ff ff       	call   80104093 <myproc>
80106dda:	8b 40 24             	mov    0x24(%eax),%eax
80106ddd:	85 c0                	test   %eax,%eax
80106ddf:	74 1a                	je     80106dfb <trap+0x2be>
80106de1:	8b 45 08             	mov    0x8(%ebp),%eax
80106de4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106de8:	0f b7 c0             	movzwl %ax,%eax
80106deb:	83 e0 03             	and    $0x3,%eax
80106dee:	83 f8 03             	cmp    $0x3,%eax
80106df1:	75 08                	jne    80106dfb <trap+0x2be>
        exit();
80106df3:	e8 4d d7 ff ff       	call   80104545 <exit>
80106df8:	eb 01                	jmp    80106dfb <trap+0x2be>
        return;
80106dfa:	90                   	nop
80106dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106dfe:	5b                   	pop    %ebx
80106dff:	5e                   	pop    %esi
80106e00:	5f                   	pop    %edi
80106e01:	5d                   	pop    %ebp
80106e02:	c3                   	ret    

80106e03 <inb>:
{
80106e03:	55                   	push   %ebp
80106e04:	89 e5                	mov    %esp,%ebp
80106e06:	83 ec 14             	sub    $0x14,%esp
80106e09:	8b 45 08             	mov    0x8(%ebp),%eax
80106e0c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106e10:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106e14:	89 c2                	mov    %eax,%edx
80106e16:	ec                   	in     (%dx),%al
80106e17:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106e1a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106e1e:	c9                   	leave  
80106e1f:	c3                   	ret    

80106e20 <outb>:
{
80106e20:	55                   	push   %ebp
80106e21:	89 e5                	mov    %esp,%ebp
80106e23:	83 ec 08             	sub    $0x8,%esp
80106e26:	8b 45 08             	mov    0x8(%ebp),%eax
80106e29:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106e30:	89 d0                	mov    %edx,%eax
80106e32:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106e35:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106e39:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106e3d:	ee                   	out    %al,(%dx)
}
80106e3e:	90                   	nop
80106e3f:	c9                   	leave  
80106e40:	c3                   	ret    

80106e41 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106e41:	f3 0f 1e fb          	endbr32 
80106e45:	55                   	push   %ebp
80106e46:	89 e5                	mov    %esp,%ebp
80106e48:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106e4b:	6a 00                	push   $0x0
80106e4d:	68 fa 03 00 00       	push   $0x3fa
80106e52:	e8 c9 ff ff ff       	call   80106e20 <outb>
80106e57:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106e5a:	68 80 00 00 00       	push   $0x80
80106e5f:	68 fb 03 00 00       	push   $0x3fb
80106e64:	e8 b7 ff ff ff       	call   80106e20 <outb>
80106e69:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106e6c:	6a 0c                	push   $0xc
80106e6e:	68 f8 03 00 00       	push   $0x3f8
80106e73:	e8 a8 ff ff ff       	call   80106e20 <outb>
80106e78:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106e7b:	6a 00                	push   $0x0
80106e7d:	68 f9 03 00 00       	push   $0x3f9
80106e82:	e8 99 ff ff ff       	call   80106e20 <outb>
80106e87:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106e8a:	6a 03                	push   $0x3
80106e8c:	68 fb 03 00 00       	push   $0x3fb
80106e91:	e8 8a ff ff ff       	call   80106e20 <outb>
80106e96:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106e99:	6a 00                	push   $0x0
80106e9b:	68 fc 03 00 00       	push   $0x3fc
80106ea0:	e8 7b ff ff ff       	call   80106e20 <outb>
80106ea5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ea8:	6a 01                	push   $0x1
80106eaa:	68 f9 03 00 00       	push   $0x3f9
80106eaf:	e8 6c ff ff ff       	call   80106e20 <outb>
80106eb4:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106eb7:	68 fd 03 00 00       	push   $0x3fd
80106ebc:	e8 42 ff ff ff       	call   80106e03 <inb>
80106ec1:	83 c4 04             	add    $0x4,%esp
80106ec4:	3c ff                	cmp    $0xff,%al
80106ec6:	74 61                	je     80106f29 <uartinit+0xe8>
    return;
  uart = 1;
80106ec8:	c7 05 a4 00 11 80 01 	movl   $0x1,0x801100a4
80106ecf:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106ed2:	68 fa 03 00 00       	push   $0x3fa
80106ed7:	e8 27 ff ff ff       	call   80106e03 <inb>
80106edc:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106edf:	68 f8 03 00 00       	push   $0x3f8
80106ee4:	e8 1a ff ff ff       	call   80106e03 <inb>
80106ee9:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106eec:	83 ec 08             	sub    $0x8,%esp
80106eef:	6a 00                	push   $0x0
80106ef1:	6a 04                	push   $0x4
80106ef3:	e8 fe bc ff ff       	call   80102bf6 <ioapicenable>
80106ef8:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106efb:	c7 45 f4 14 b4 10 80 	movl   $0x8010b414,-0xc(%ebp)
80106f02:	eb 19                	jmp    80106f1d <uartinit+0xdc>
    uartputc(*p);
80106f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f07:	0f b6 00             	movzbl (%eax),%eax
80106f0a:	0f be c0             	movsbl %al,%eax
80106f0d:	83 ec 0c             	sub    $0xc,%esp
80106f10:	50                   	push   %eax
80106f11:	e8 16 00 00 00       	call   80106f2c <uartputc>
80106f16:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106f19:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f20:	0f b6 00             	movzbl (%eax),%eax
80106f23:	84 c0                	test   %al,%al
80106f25:	75 dd                	jne    80106f04 <uartinit+0xc3>
80106f27:	eb 01                	jmp    80106f2a <uartinit+0xe9>
    return;
80106f29:	90                   	nop
}
80106f2a:	c9                   	leave  
80106f2b:	c3                   	ret    

80106f2c <uartputc>:

void
uartputc(int c)
{
80106f2c:	f3 0f 1e fb          	endbr32 
80106f30:	55                   	push   %ebp
80106f31:	89 e5                	mov    %esp,%ebp
80106f33:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106f36:	a1 a4 00 11 80       	mov    0x801100a4,%eax
80106f3b:	85 c0                	test   %eax,%eax
80106f3d:	74 53                	je     80106f92 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f3f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f46:	eb 11                	jmp    80106f59 <uartputc+0x2d>
    microdelay(10);
80106f48:	83 ec 0c             	sub    $0xc,%esp
80106f4b:	6a 0a                	push   $0xa
80106f4d:	e8 dc c1 ff ff       	call   8010312e <microdelay>
80106f52:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f55:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f59:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106f5d:	7f 1a                	jg     80106f79 <uartputc+0x4d>
80106f5f:	83 ec 0c             	sub    $0xc,%esp
80106f62:	68 fd 03 00 00       	push   $0x3fd
80106f67:	e8 97 fe ff ff       	call   80106e03 <inb>
80106f6c:	83 c4 10             	add    $0x10,%esp
80106f6f:	0f b6 c0             	movzbl %al,%eax
80106f72:	83 e0 20             	and    $0x20,%eax
80106f75:	85 c0                	test   %eax,%eax
80106f77:	74 cf                	je     80106f48 <uartputc+0x1c>
  outb(COM1+0, c);
80106f79:	8b 45 08             	mov    0x8(%ebp),%eax
80106f7c:	0f b6 c0             	movzbl %al,%eax
80106f7f:	83 ec 08             	sub    $0x8,%esp
80106f82:	50                   	push   %eax
80106f83:	68 f8 03 00 00       	push   $0x3f8
80106f88:	e8 93 fe ff ff       	call   80106e20 <outb>
80106f8d:	83 c4 10             	add    $0x10,%esp
80106f90:	eb 01                	jmp    80106f93 <uartputc+0x67>
    return;
80106f92:	90                   	nop
}
80106f93:	c9                   	leave  
80106f94:	c3                   	ret    

80106f95 <uartgetc>:

static int
uartgetc(void)
{
80106f95:	f3 0f 1e fb          	endbr32 
80106f99:	55                   	push   %ebp
80106f9a:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106f9c:	a1 a4 00 11 80       	mov    0x801100a4,%eax
80106fa1:	85 c0                	test   %eax,%eax
80106fa3:	75 07                	jne    80106fac <uartgetc+0x17>
    return -1;
80106fa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106faa:	eb 2e                	jmp    80106fda <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106fac:	68 fd 03 00 00       	push   $0x3fd
80106fb1:	e8 4d fe ff ff       	call   80106e03 <inb>
80106fb6:	83 c4 04             	add    $0x4,%esp
80106fb9:	0f b6 c0             	movzbl %al,%eax
80106fbc:	83 e0 01             	and    $0x1,%eax
80106fbf:	85 c0                	test   %eax,%eax
80106fc1:	75 07                	jne    80106fca <uartgetc+0x35>
    return -1;
80106fc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fc8:	eb 10                	jmp    80106fda <uartgetc+0x45>
  return inb(COM1+0);
80106fca:	68 f8 03 00 00       	push   $0x3f8
80106fcf:	e8 2f fe ff ff       	call   80106e03 <inb>
80106fd4:	83 c4 04             	add    $0x4,%esp
80106fd7:	0f b6 c0             	movzbl %al,%eax
}
80106fda:	c9                   	leave  
80106fdb:	c3                   	ret    

80106fdc <uartintr>:

void
uartintr(void)
{
80106fdc:	f3 0f 1e fb          	endbr32 
80106fe0:	55                   	push   %ebp
80106fe1:	89 e5                	mov    %esp,%ebp
80106fe3:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106fe6:	83 ec 0c             	sub    $0xc,%esp
80106fe9:	68 95 6f 10 80       	push   $0x80106f95
80106fee:	e8 0d 98 ff ff       	call   80100800 <consoleintr>
80106ff3:	83 c4 10             	add    $0x10,%esp
}
80106ff6:	90                   	nop
80106ff7:	c9                   	leave  
80106ff8:	c3                   	ret    

80106ff9 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106ff9:	6a 00                	push   $0x0
  pushl $0
80106ffb:	6a 00                	push   $0x0
  jmp alltraps
80106ffd:	e9 47 f9 ff ff       	jmp    80106949 <alltraps>

80107002 <vector1>:
.globl vector1
vector1:
  pushl $0
80107002:	6a 00                	push   $0x0
  pushl $1
80107004:	6a 01                	push   $0x1
  jmp alltraps
80107006:	e9 3e f9 ff ff       	jmp    80106949 <alltraps>

8010700b <vector2>:
.globl vector2
vector2:
  pushl $0
8010700b:	6a 00                	push   $0x0
  pushl $2
8010700d:	6a 02                	push   $0x2
  jmp alltraps
8010700f:	e9 35 f9 ff ff       	jmp    80106949 <alltraps>

80107014 <vector3>:
.globl vector3
vector3:
  pushl $0
80107014:	6a 00                	push   $0x0
  pushl $3
80107016:	6a 03                	push   $0x3
  jmp alltraps
80107018:	e9 2c f9 ff ff       	jmp    80106949 <alltraps>

8010701d <vector4>:
.globl vector4
vector4:
  pushl $0
8010701d:	6a 00                	push   $0x0
  pushl $4
8010701f:	6a 04                	push   $0x4
  jmp alltraps
80107021:	e9 23 f9 ff ff       	jmp    80106949 <alltraps>

80107026 <vector5>:
.globl vector5
vector5:
  pushl $0
80107026:	6a 00                	push   $0x0
  pushl $5
80107028:	6a 05                	push   $0x5
  jmp alltraps
8010702a:	e9 1a f9 ff ff       	jmp    80106949 <alltraps>

8010702f <vector6>:
.globl vector6
vector6:
  pushl $0
8010702f:	6a 00                	push   $0x0
  pushl $6
80107031:	6a 06                	push   $0x6
  jmp alltraps
80107033:	e9 11 f9 ff ff       	jmp    80106949 <alltraps>

80107038 <vector7>:
.globl vector7
vector7:
  pushl $0
80107038:	6a 00                	push   $0x0
  pushl $7
8010703a:	6a 07                	push   $0x7
  jmp alltraps
8010703c:	e9 08 f9 ff ff       	jmp    80106949 <alltraps>

80107041 <vector8>:
.globl vector8
vector8:
  pushl $8
80107041:	6a 08                	push   $0x8
  jmp alltraps
80107043:	e9 01 f9 ff ff       	jmp    80106949 <alltraps>

80107048 <vector9>:
.globl vector9
vector9:
  pushl $0
80107048:	6a 00                	push   $0x0
  pushl $9
8010704a:	6a 09                	push   $0x9
  jmp alltraps
8010704c:	e9 f8 f8 ff ff       	jmp    80106949 <alltraps>

80107051 <vector10>:
.globl vector10
vector10:
  pushl $10
80107051:	6a 0a                	push   $0xa
  jmp alltraps
80107053:	e9 f1 f8 ff ff       	jmp    80106949 <alltraps>

80107058 <vector11>:
.globl vector11
vector11:
  pushl $11
80107058:	6a 0b                	push   $0xb
  jmp alltraps
8010705a:	e9 ea f8 ff ff       	jmp    80106949 <alltraps>

8010705f <vector12>:
.globl vector12
vector12:
  pushl $12
8010705f:	6a 0c                	push   $0xc
  jmp alltraps
80107061:	e9 e3 f8 ff ff       	jmp    80106949 <alltraps>

80107066 <vector13>:
.globl vector13
vector13:
  pushl $13
80107066:	6a 0d                	push   $0xd
  jmp alltraps
80107068:	e9 dc f8 ff ff       	jmp    80106949 <alltraps>

8010706d <vector14>:
.globl vector14
vector14:
  pushl $14
8010706d:	6a 0e                	push   $0xe
  jmp alltraps
8010706f:	e9 d5 f8 ff ff       	jmp    80106949 <alltraps>

80107074 <vector15>:
.globl vector15
vector15:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $15
80107076:	6a 0f                	push   $0xf
  jmp alltraps
80107078:	e9 cc f8 ff ff       	jmp    80106949 <alltraps>

8010707d <vector16>:
.globl vector16
vector16:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $16
8010707f:	6a 10                	push   $0x10
  jmp alltraps
80107081:	e9 c3 f8 ff ff       	jmp    80106949 <alltraps>

80107086 <vector17>:
.globl vector17
vector17:
  pushl $17
80107086:	6a 11                	push   $0x11
  jmp alltraps
80107088:	e9 bc f8 ff ff       	jmp    80106949 <alltraps>

8010708d <vector18>:
.globl vector18
vector18:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $18
8010708f:	6a 12                	push   $0x12
  jmp alltraps
80107091:	e9 b3 f8 ff ff       	jmp    80106949 <alltraps>

80107096 <vector19>:
.globl vector19
vector19:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $19
80107098:	6a 13                	push   $0x13
  jmp alltraps
8010709a:	e9 aa f8 ff ff       	jmp    80106949 <alltraps>

8010709f <vector20>:
.globl vector20
vector20:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $20
801070a1:	6a 14                	push   $0x14
  jmp alltraps
801070a3:	e9 a1 f8 ff ff       	jmp    80106949 <alltraps>

801070a8 <vector21>:
.globl vector21
vector21:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $21
801070aa:	6a 15                	push   $0x15
  jmp alltraps
801070ac:	e9 98 f8 ff ff       	jmp    80106949 <alltraps>

801070b1 <vector22>:
.globl vector22
vector22:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $22
801070b3:	6a 16                	push   $0x16
  jmp alltraps
801070b5:	e9 8f f8 ff ff       	jmp    80106949 <alltraps>

801070ba <vector23>:
.globl vector23
vector23:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $23
801070bc:	6a 17                	push   $0x17
  jmp alltraps
801070be:	e9 86 f8 ff ff       	jmp    80106949 <alltraps>

801070c3 <vector24>:
.globl vector24
vector24:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $24
801070c5:	6a 18                	push   $0x18
  jmp alltraps
801070c7:	e9 7d f8 ff ff       	jmp    80106949 <alltraps>

801070cc <vector25>:
.globl vector25
vector25:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $25
801070ce:	6a 19                	push   $0x19
  jmp alltraps
801070d0:	e9 74 f8 ff ff       	jmp    80106949 <alltraps>

801070d5 <vector26>:
.globl vector26
vector26:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $26
801070d7:	6a 1a                	push   $0x1a
  jmp alltraps
801070d9:	e9 6b f8 ff ff       	jmp    80106949 <alltraps>

801070de <vector27>:
.globl vector27
vector27:
  pushl $0
801070de:	6a 00                	push   $0x0
  pushl $27
801070e0:	6a 1b                	push   $0x1b
  jmp alltraps
801070e2:	e9 62 f8 ff ff       	jmp    80106949 <alltraps>

801070e7 <vector28>:
.globl vector28
vector28:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $28
801070e9:	6a 1c                	push   $0x1c
  jmp alltraps
801070eb:	e9 59 f8 ff ff       	jmp    80106949 <alltraps>

801070f0 <vector29>:
.globl vector29
vector29:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $29
801070f2:	6a 1d                	push   $0x1d
  jmp alltraps
801070f4:	e9 50 f8 ff ff       	jmp    80106949 <alltraps>

801070f9 <vector30>:
.globl vector30
vector30:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $30
801070fb:	6a 1e                	push   $0x1e
  jmp alltraps
801070fd:	e9 47 f8 ff ff       	jmp    80106949 <alltraps>

80107102 <vector31>:
.globl vector31
vector31:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $31
80107104:	6a 1f                	push   $0x1f
  jmp alltraps
80107106:	e9 3e f8 ff ff       	jmp    80106949 <alltraps>

8010710b <vector32>:
.globl vector32
vector32:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $32
8010710d:	6a 20                	push   $0x20
  jmp alltraps
8010710f:	e9 35 f8 ff ff       	jmp    80106949 <alltraps>

80107114 <vector33>:
.globl vector33
vector33:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $33
80107116:	6a 21                	push   $0x21
  jmp alltraps
80107118:	e9 2c f8 ff ff       	jmp    80106949 <alltraps>

8010711d <vector34>:
.globl vector34
vector34:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $34
8010711f:	6a 22                	push   $0x22
  jmp alltraps
80107121:	e9 23 f8 ff ff       	jmp    80106949 <alltraps>

80107126 <vector35>:
.globl vector35
vector35:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $35
80107128:	6a 23                	push   $0x23
  jmp alltraps
8010712a:	e9 1a f8 ff ff       	jmp    80106949 <alltraps>

8010712f <vector36>:
.globl vector36
vector36:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $36
80107131:	6a 24                	push   $0x24
  jmp alltraps
80107133:	e9 11 f8 ff ff       	jmp    80106949 <alltraps>

80107138 <vector37>:
.globl vector37
vector37:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $37
8010713a:	6a 25                	push   $0x25
  jmp alltraps
8010713c:	e9 08 f8 ff ff       	jmp    80106949 <alltraps>

80107141 <vector38>:
.globl vector38
vector38:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $38
80107143:	6a 26                	push   $0x26
  jmp alltraps
80107145:	e9 ff f7 ff ff       	jmp    80106949 <alltraps>

8010714a <vector39>:
.globl vector39
vector39:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $39
8010714c:	6a 27                	push   $0x27
  jmp alltraps
8010714e:	e9 f6 f7 ff ff       	jmp    80106949 <alltraps>

80107153 <vector40>:
.globl vector40
vector40:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $40
80107155:	6a 28                	push   $0x28
  jmp alltraps
80107157:	e9 ed f7 ff ff       	jmp    80106949 <alltraps>

8010715c <vector41>:
.globl vector41
vector41:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $41
8010715e:	6a 29                	push   $0x29
  jmp alltraps
80107160:	e9 e4 f7 ff ff       	jmp    80106949 <alltraps>

80107165 <vector42>:
.globl vector42
vector42:
  pushl $0
80107165:	6a 00                	push   $0x0
  pushl $42
80107167:	6a 2a                	push   $0x2a
  jmp alltraps
80107169:	e9 db f7 ff ff       	jmp    80106949 <alltraps>

8010716e <vector43>:
.globl vector43
vector43:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $43
80107170:	6a 2b                	push   $0x2b
  jmp alltraps
80107172:	e9 d2 f7 ff ff       	jmp    80106949 <alltraps>

80107177 <vector44>:
.globl vector44
vector44:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $44
80107179:	6a 2c                	push   $0x2c
  jmp alltraps
8010717b:	e9 c9 f7 ff ff       	jmp    80106949 <alltraps>

80107180 <vector45>:
.globl vector45
vector45:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $45
80107182:	6a 2d                	push   $0x2d
  jmp alltraps
80107184:	e9 c0 f7 ff ff       	jmp    80106949 <alltraps>

80107189 <vector46>:
.globl vector46
vector46:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $46
8010718b:	6a 2e                	push   $0x2e
  jmp alltraps
8010718d:	e9 b7 f7 ff ff       	jmp    80106949 <alltraps>

80107192 <vector47>:
.globl vector47
vector47:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $47
80107194:	6a 2f                	push   $0x2f
  jmp alltraps
80107196:	e9 ae f7 ff ff       	jmp    80106949 <alltraps>

8010719b <vector48>:
.globl vector48
vector48:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $48
8010719d:	6a 30                	push   $0x30
  jmp alltraps
8010719f:	e9 a5 f7 ff ff       	jmp    80106949 <alltraps>

801071a4 <vector49>:
.globl vector49
vector49:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $49
801071a6:	6a 31                	push   $0x31
  jmp alltraps
801071a8:	e9 9c f7 ff ff       	jmp    80106949 <alltraps>

801071ad <vector50>:
.globl vector50
vector50:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $50
801071af:	6a 32                	push   $0x32
  jmp alltraps
801071b1:	e9 93 f7 ff ff       	jmp    80106949 <alltraps>

801071b6 <vector51>:
.globl vector51
vector51:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $51
801071b8:	6a 33                	push   $0x33
  jmp alltraps
801071ba:	e9 8a f7 ff ff       	jmp    80106949 <alltraps>

801071bf <vector52>:
.globl vector52
vector52:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $52
801071c1:	6a 34                	push   $0x34
  jmp alltraps
801071c3:	e9 81 f7 ff ff       	jmp    80106949 <alltraps>

801071c8 <vector53>:
.globl vector53
vector53:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $53
801071ca:	6a 35                	push   $0x35
  jmp alltraps
801071cc:	e9 78 f7 ff ff       	jmp    80106949 <alltraps>

801071d1 <vector54>:
.globl vector54
vector54:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $54
801071d3:	6a 36                	push   $0x36
  jmp alltraps
801071d5:	e9 6f f7 ff ff       	jmp    80106949 <alltraps>

801071da <vector55>:
.globl vector55
vector55:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $55
801071dc:	6a 37                	push   $0x37
  jmp alltraps
801071de:	e9 66 f7 ff ff       	jmp    80106949 <alltraps>

801071e3 <vector56>:
.globl vector56
vector56:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $56
801071e5:	6a 38                	push   $0x38
  jmp alltraps
801071e7:	e9 5d f7 ff ff       	jmp    80106949 <alltraps>

801071ec <vector57>:
.globl vector57
vector57:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $57
801071ee:	6a 39                	push   $0x39
  jmp alltraps
801071f0:	e9 54 f7 ff ff       	jmp    80106949 <alltraps>

801071f5 <vector58>:
.globl vector58
vector58:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $58
801071f7:	6a 3a                	push   $0x3a
  jmp alltraps
801071f9:	e9 4b f7 ff ff       	jmp    80106949 <alltraps>

801071fe <vector59>:
.globl vector59
vector59:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $59
80107200:	6a 3b                	push   $0x3b
  jmp alltraps
80107202:	e9 42 f7 ff ff       	jmp    80106949 <alltraps>

80107207 <vector60>:
.globl vector60
vector60:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $60
80107209:	6a 3c                	push   $0x3c
  jmp alltraps
8010720b:	e9 39 f7 ff ff       	jmp    80106949 <alltraps>

80107210 <vector61>:
.globl vector61
vector61:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $61
80107212:	6a 3d                	push   $0x3d
  jmp alltraps
80107214:	e9 30 f7 ff ff       	jmp    80106949 <alltraps>

80107219 <vector62>:
.globl vector62
vector62:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $62
8010721b:	6a 3e                	push   $0x3e
  jmp alltraps
8010721d:	e9 27 f7 ff ff       	jmp    80106949 <alltraps>

80107222 <vector63>:
.globl vector63
vector63:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $63
80107224:	6a 3f                	push   $0x3f
  jmp alltraps
80107226:	e9 1e f7 ff ff       	jmp    80106949 <alltraps>

8010722b <vector64>:
.globl vector64
vector64:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $64
8010722d:	6a 40                	push   $0x40
  jmp alltraps
8010722f:	e9 15 f7 ff ff       	jmp    80106949 <alltraps>

80107234 <vector65>:
.globl vector65
vector65:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $65
80107236:	6a 41                	push   $0x41
  jmp alltraps
80107238:	e9 0c f7 ff ff       	jmp    80106949 <alltraps>

8010723d <vector66>:
.globl vector66
vector66:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $66
8010723f:	6a 42                	push   $0x42
  jmp alltraps
80107241:	e9 03 f7 ff ff       	jmp    80106949 <alltraps>

80107246 <vector67>:
.globl vector67
vector67:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $67
80107248:	6a 43                	push   $0x43
  jmp alltraps
8010724a:	e9 fa f6 ff ff       	jmp    80106949 <alltraps>

8010724f <vector68>:
.globl vector68
vector68:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $68
80107251:	6a 44                	push   $0x44
  jmp alltraps
80107253:	e9 f1 f6 ff ff       	jmp    80106949 <alltraps>

80107258 <vector69>:
.globl vector69
vector69:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $69
8010725a:	6a 45                	push   $0x45
  jmp alltraps
8010725c:	e9 e8 f6 ff ff       	jmp    80106949 <alltraps>

80107261 <vector70>:
.globl vector70
vector70:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $70
80107263:	6a 46                	push   $0x46
  jmp alltraps
80107265:	e9 df f6 ff ff       	jmp    80106949 <alltraps>

8010726a <vector71>:
.globl vector71
vector71:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $71
8010726c:	6a 47                	push   $0x47
  jmp alltraps
8010726e:	e9 d6 f6 ff ff       	jmp    80106949 <alltraps>

80107273 <vector72>:
.globl vector72
vector72:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $72
80107275:	6a 48                	push   $0x48
  jmp alltraps
80107277:	e9 cd f6 ff ff       	jmp    80106949 <alltraps>

8010727c <vector73>:
.globl vector73
vector73:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $73
8010727e:	6a 49                	push   $0x49
  jmp alltraps
80107280:	e9 c4 f6 ff ff       	jmp    80106949 <alltraps>

80107285 <vector74>:
.globl vector74
vector74:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $74
80107287:	6a 4a                	push   $0x4a
  jmp alltraps
80107289:	e9 bb f6 ff ff       	jmp    80106949 <alltraps>

8010728e <vector75>:
.globl vector75
vector75:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $75
80107290:	6a 4b                	push   $0x4b
  jmp alltraps
80107292:	e9 b2 f6 ff ff       	jmp    80106949 <alltraps>

80107297 <vector76>:
.globl vector76
vector76:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $76
80107299:	6a 4c                	push   $0x4c
  jmp alltraps
8010729b:	e9 a9 f6 ff ff       	jmp    80106949 <alltraps>

801072a0 <vector77>:
.globl vector77
vector77:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $77
801072a2:	6a 4d                	push   $0x4d
  jmp alltraps
801072a4:	e9 a0 f6 ff ff       	jmp    80106949 <alltraps>

801072a9 <vector78>:
.globl vector78
vector78:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $78
801072ab:	6a 4e                	push   $0x4e
  jmp alltraps
801072ad:	e9 97 f6 ff ff       	jmp    80106949 <alltraps>

801072b2 <vector79>:
.globl vector79
vector79:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $79
801072b4:	6a 4f                	push   $0x4f
  jmp alltraps
801072b6:	e9 8e f6 ff ff       	jmp    80106949 <alltraps>

801072bb <vector80>:
.globl vector80
vector80:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $80
801072bd:	6a 50                	push   $0x50
  jmp alltraps
801072bf:	e9 85 f6 ff ff       	jmp    80106949 <alltraps>

801072c4 <vector81>:
.globl vector81
vector81:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $81
801072c6:	6a 51                	push   $0x51
  jmp alltraps
801072c8:	e9 7c f6 ff ff       	jmp    80106949 <alltraps>

801072cd <vector82>:
.globl vector82
vector82:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $82
801072cf:	6a 52                	push   $0x52
  jmp alltraps
801072d1:	e9 73 f6 ff ff       	jmp    80106949 <alltraps>

801072d6 <vector83>:
.globl vector83
vector83:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $83
801072d8:	6a 53                	push   $0x53
  jmp alltraps
801072da:	e9 6a f6 ff ff       	jmp    80106949 <alltraps>

801072df <vector84>:
.globl vector84
vector84:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $84
801072e1:	6a 54                	push   $0x54
  jmp alltraps
801072e3:	e9 61 f6 ff ff       	jmp    80106949 <alltraps>

801072e8 <vector85>:
.globl vector85
vector85:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $85
801072ea:	6a 55                	push   $0x55
  jmp alltraps
801072ec:	e9 58 f6 ff ff       	jmp    80106949 <alltraps>

801072f1 <vector86>:
.globl vector86
vector86:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $86
801072f3:	6a 56                	push   $0x56
  jmp alltraps
801072f5:	e9 4f f6 ff ff       	jmp    80106949 <alltraps>

801072fa <vector87>:
.globl vector87
vector87:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $87
801072fc:	6a 57                	push   $0x57
  jmp alltraps
801072fe:	e9 46 f6 ff ff       	jmp    80106949 <alltraps>

80107303 <vector88>:
.globl vector88
vector88:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $88
80107305:	6a 58                	push   $0x58
  jmp alltraps
80107307:	e9 3d f6 ff ff       	jmp    80106949 <alltraps>

8010730c <vector89>:
.globl vector89
vector89:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $89
8010730e:	6a 59                	push   $0x59
  jmp alltraps
80107310:	e9 34 f6 ff ff       	jmp    80106949 <alltraps>

80107315 <vector90>:
.globl vector90
vector90:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $90
80107317:	6a 5a                	push   $0x5a
  jmp alltraps
80107319:	e9 2b f6 ff ff       	jmp    80106949 <alltraps>

8010731e <vector91>:
.globl vector91
vector91:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $91
80107320:	6a 5b                	push   $0x5b
  jmp alltraps
80107322:	e9 22 f6 ff ff       	jmp    80106949 <alltraps>

80107327 <vector92>:
.globl vector92
vector92:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $92
80107329:	6a 5c                	push   $0x5c
  jmp alltraps
8010732b:	e9 19 f6 ff ff       	jmp    80106949 <alltraps>

80107330 <vector93>:
.globl vector93
vector93:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $93
80107332:	6a 5d                	push   $0x5d
  jmp alltraps
80107334:	e9 10 f6 ff ff       	jmp    80106949 <alltraps>

80107339 <vector94>:
.globl vector94
vector94:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $94
8010733b:	6a 5e                	push   $0x5e
  jmp alltraps
8010733d:	e9 07 f6 ff ff       	jmp    80106949 <alltraps>

80107342 <vector95>:
.globl vector95
vector95:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $95
80107344:	6a 5f                	push   $0x5f
  jmp alltraps
80107346:	e9 fe f5 ff ff       	jmp    80106949 <alltraps>

8010734b <vector96>:
.globl vector96
vector96:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $96
8010734d:	6a 60                	push   $0x60
  jmp alltraps
8010734f:	e9 f5 f5 ff ff       	jmp    80106949 <alltraps>

80107354 <vector97>:
.globl vector97
vector97:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $97
80107356:	6a 61                	push   $0x61
  jmp alltraps
80107358:	e9 ec f5 ff ff       	jmp    80106949 <alltraps>

8010735d <vector98>:
.globl vector98
vector98:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $98
8010735f:	6a 62                	push   $0x62
  jmp alltraps
80107361:	e9 e3 f5 ff ff       	jmp    80106949 <alltraps>

80107366 <vector99>:
.globl vector99
vector99:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $99
80107368:	6a 63                	push   $0x63
  jmp alltraps
8010736a:	e9 da f5 ff ff       	jmp    80106949 <alltraps>

8010736f <vector100>:
.globl vector100
vector100:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $100
80107371:	6a 64                	push   $0x64
  jmp alltraps
80107373:	e9 d1 f5 ff ff       	jmp    80106949 <alltraps>

80107378 <vector101>:
.globl vector101
vector101:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $101
8010737a:	6a 65                	push   $0x65
  jmp alltraps
8010737c:	e9 c8 f5 ff ff       	jmp    80106949 <alltraps>

80107381 <vector102>:
.globl vector102
vector102:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $102
80107383:	6a 66                	push   $0x66
  jmp alltraps
80107385:	e9 bf f5 ff ff       	jmp    80106949 <alltraps>

8010738a <vector103>:
.globl vector103
vector103:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $103
8010738c:	6a 67                	push   $0x67
  jmp alltraps
8010738e:	e9 b6 f5 ff ff       	jmp    80106949 <alltraps>

80107393 <vector104>:
.globl vector104
vector104:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $104
80107395:	6a 68                	push   $0x68
  jmp alltraps
80107397:	e9 ad f5 ff ff       	jmp    80106949 <alltraps>

8010739c <vector105>:
.globl vector105
vector105:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $105
8010739e:	6a 69                	push   $0x69
  jmp alltraps
801073a0:	e9 a4 f5 ff ff       	jmp    80106949 <alltraps>

801073a5 <vector106>:
.globl vector106
vector106:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $106
801073a7:	6a 6a                	push   $0x6a
  jmp alltraps
801073a9:	e9 9b f5 ff ff       	jmp    80106949 <alltraps>

801073ae <vector107>:
.globl vector107
vector107:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $107
801073b0:	6a 6b                	push   $0x6b
  jmp alltraps
801073b2:	e9 92 f5 ff ff       	jmp    80106949 <alltraps>

801073b7 <vector108>:
.globl vector108
vector108:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $108
801073b9:	6a 6c                	push   $0x6c
  jmp alltraps
801073bb:	e9 89 f5 ff ff       	jmp    80106949 <alltraps>

801073c0 <vector109>:
.globl vector109
vector109:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $109
801073c2:	6a 6d                	push   $0x6d
  jmp alltraps
801073c4:	e9 80 f5 ff ff       	jmp    80106949 <alltraps>

801073c9 <vector110>:
.globl vector110
vector110:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $110
801073cb:	6a 6e                	push   $0x6e
  jmp alltraps
801073cd:	e9 77 f5 ff ff       	jmp    80106949 <alltraps>

801073d2 <vector111>:
.globl vector111
vector111:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $111
801073d4:	6a 6f                	push   $0x6f
  jmp alltraps
801073d6:	e9 6e f5 ff ff       	jmp    80106949 <alltraps>

801073db <vector112>:
.globl vector112
vector112:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $112
801073dd:	6a 70                	push   $0x70
  jmp alltraps
801073df:	e9 65 f5 ff ff       	jmp    80106949 <alltraps>

801073e4 <vector113>:
.globl vector113
vector113:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $113
801073e6:	6a 71                	push   $0x71
  jmp alltraps
801073e8:	e9 5c f5 ff ff       	jmp    80106949 <alltraps>

801073ed <vector114>:
.globl vector114
vector114:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $114
801073ef:	6a 72                	push   $0x72
  jmp alltraps
801073f1:	e9 53 f5 ff ff       	jmp    80106949 <alltraps>

801073f6 <vector115>:
.globl vector115
vector115:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $115
801073f8:	6a 73                	push   $0x73
  jmp alltraps
801073fa:	e9 4a f5 ff ff       	jmp    80106949 <alltraps>

801073ff <vector116>:
.globl vector116
vector116:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $116
80107401:	6a 74                	push   $0x74
  jmp alltraps
80107403:	e9 41 f5 ff ff       	jmp    80106949 <alltraps>

80107408 <vector117>:
.globl vector117
vector117:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $117
8010740a:	6a 75                	push   $0x75
  jmp alltraps
8010740c:	e9 38 f5 ff ff       	jmp    80106949 <alltraps>

80107411 <vector118>:
.globl vector118
vector118:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $118
80107413:	6a 76                	push   $0x76
  jmp alltraps
80107415:	e9 2f f5 ff ff       	jmp    80106949 <alltraps>

8010741a <vector119>:
.globl vector119
vector119:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $119
8010741c:	6a 77                	push   $0x77
  jmp alltraps
8010741e:	e9 26 f5 ff ff       	jmp    80106949 <alltraps>

80107423 <vector120>:
.globl vector120
vector120:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $120
80107425:	6a 78                	push   $0x78
  jmp alltraps
80107427:	e9 1d f5 ff ff       	jmp    80106949 <alltraps>

8010742c <vector121>:
.globl vector121
vector121:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $121
8010742e:	6a 79                	push   $0x79
  jmp alltraps
80107430:	e9 14 f5 ff ff       	jmp    80106949 <alltraps>

80107435 <vector122>:
.globl vector122
vector122:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $122
80107437:	6a 7a                	push   $0x7a
  jmp alltraps
80107439:	e9 0b f5 ff ff       	jmp    80106949 <alltraps>

8010743e <vector123>:
.globl vector123
vector123:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $123
80107440:	6a 7b                	push   $0x7b
  jmp alltraps
80107442:	e9 02 f5 ff ff       	jmp    80106949 <alltraps>

80107447 <vector124>:
.globl vector124
vector124:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $124
80107449:	6a 7c                	push   $0x7c
  jmp alltraps
8010744b:	e9 f9 f4 ff ff       	jmp    80106949 <alltraps>

80107450 <vector125>:
.globl vector125
vector125:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $125
80107452:	6a 7d                	push   $0x7d
  jmp alltraps
80107454:	e9 f0 f4 ff ff       	jmp    80106949 <alltraps>

80107459 <vector126>:
.globl vector126
vector126:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $126
8010745b:	6a 7e                	push   $0x7e
  jmp alltraps
8010745d:	e9 e7 f4 ff ff       	jmp    80106949 <alltraps>

80107462 <vector127>:
.globl vector127
vector127:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $127
80107464:	6a 7f                	push   $0x7f
  jmp alltraps
80107466:	e9 de f4 ff ff       	jmp    80106949 <alltraps>

8010746b <vector128>:
.globl vector128
vector128:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $128
8010746d:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107472:	e9 d2 f4 ff ff       	jmp    80106949 <alltraps>

80107477 <vector129>:
.globl vector129
vector129:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $129
80107479:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010747e:	e9 c6 f4 ff ff       	jmp    80106949 <alltraps>

80107483 <vector130>:
.globl vector130
vector130:
  pushl $0
80107483:	6a 00                	push   $0x0
  pushl $130
80107485:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010748a:	e9 ba f4 ff ff       	jmp    80106949 <alltraps>

8010748f <vector131>:
.globl vector131
vector131:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $131
80107491:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107496:	e9 ae f4 ff ff       	jmp    80106949 <alltraps>

8010749b <vector132>:
.globl vector132
vector132:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $132
8010749d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801074a2:	e9 a2 f4 ff ff       	jmp    80106949 <alltraps>

801074a7 <vector133>:
.globl vector133
vector133:
  pushl $0
801074a7:	6a 00                	push   $0x0
  pushl $133
801074a9:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801074ae:	e9 96 f4 ff ff       	jmp    80106949 <alltraps>

801074b3 <vector134>:
.globl vector134
vector134:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $134
801074b5:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801074ba:	e9 8a f4 ff ff       	jmp    80106949 <alltraps>

801074bf <vector135>:
.globl vector135
vector135:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $135
801074c1:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801074c6:	e9 7e f4 ff ff       	jmp    80106949 <alltraps>

801074cb <vector136>:
.globl vector136
vector136:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $136
801074cd:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801074d2:	e9 72 f4 ff ff       	jmp    80106949 <alltraps>

801074d7 <vector137>:
.globl vector137
vector137:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $137
801074d9:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801074de:	e9 66 f4 ff ff       	jmp    80106949 <alltraps>

801074e3 <vector138>:
.globl vector138
vector138:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $138
801074e5:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801074ea:	e9 5a f4 ff ff       	jmp    80106949 <alltraps>

801074ef <vector139>:
.globl vector139
vector139:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $139
801074f1:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801074f6:	e9 4e f4 ff ff       	jmp    80106949 <alltraps>

801074fb <vector140>:
.globl vector140
vector140:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $140
801074fd:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107502:	e9 42 f4 ff ff       	jmp    80106949 <alltraps>

80107507 <vector141>:
.globl vector141
vector141:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $141
80107509:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010750e:	e9 36 f4 ff ff       	jmp    80106949 <alltraps>

80107513 <vector142>:
.globl vector142
vector142:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $142
80107515:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010751a:	e9 2a f4 ff ff       	jmp    80106949 <alltraps>

8010751f <vector143>:
.globl vector143
vector143:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $143
80107521:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107526:	e9 1e f4 ff ff       	jmp    80106949 <alltraps>

8010752b <vector144>:
.globl vector144
vector144:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $144
8010752d:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107532:	e9 12 f4 ff ff       	jmp    80106949 <alltraps>

80107537 <vector145>:
.globl vector145
vector145:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $145
80107539:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010753e:	e9 06 f4 ff ff       	jmp    80106949 <alltraps>

80107543 <vector146>:
.globl vector146
vector146:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $146
80107545:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010754a:	e9 fa f3 ff ff       	jmp    80106949 <alltraps>

8010754f <vector147>:
.globl vector147
vector147:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $147
80107551:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107556:	e9 ee f3 ff ff       	jmp    80106949 <alltraps>

8010755b <vector148>:
.globl vector148
vector148:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $148
8010755d:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107562:	e9 e2 f3 ff ff       	jmp    80106949 <alltraps>

80107567 <vector149>:
.globl vector149
vector149:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $149
80107569:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010756e:	e9 d6 f3 ff ff       	jmp    80106949 <alltraps>

80107573 <vector150>:
.globl vector150
vector150:
  pushl $0
80107573:	6a 00                	push   $0x0
  pushl $150
80107575:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010757a:	e9 ca f3 ff ff       	jmp    80106949 <alltraps>

8010757f <vector151>:
.globl vector151
vector151:
  pushl $0
8010757f:	6a 00                	push   $0x0
  pushl $151
80107581:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107586:	e9 be f3 ff ff       	jmp    80106949 <alltraps>

8010758b <vector152>:
.globl vector152
vector152:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $152
8010758d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107592:	e9 b2 f3 ff ff       	jmp    80106949 <alltraps>

80107597 <vector153>:
.globl vector153
vector153:
  pushl $0
80107597:	6a 00                	push   $0x0
  pushl $153
80107599:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010759e:	e9 a6 f3 ff ff       	jmp    80106949 <alltraps>

801075a3 <vector154>:
.globl vector154
vector154:
  pushl $0
801075a3:	6a 00                	push   $0x0
  pushl $154
801075a5:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801075aa:	e9 9a f3 ff ff       	jmp    80106949 <alltraps>

801075af <vector155>:
.globl vector155
vector155:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $155
801075b1:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801075b6:	e9 8e f3 ff ff       	jmp    80106949 <alltraps>

801075bb <vector156>:
.globl vector156
vector156:
  pushl $0
801075bb:	6a 00                	push   $0x0
  pushl $156
801075bd:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801075c2:	e9 82 f3 ff ff       	jmp    80106949 <alltraps>

801075c7 <vector157>:
.globl vector157
vector157:
  pushl $0
801075c7:	6a 00                	push   $0x0
  pushl $157
801075c9:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801075ce:	e9 76 f3 ff ff       	jmp    80106949 <alltraps>

801075d3 <vector158>:
.globl vector158
vector158:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $158
801075d5:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801075da:	e9 6a f3 ff ff       	jmp    80106949 <alltraps>

801075df <vector159>:
.globl vector159
vector159:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $159
801075e1:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801075e6:	e9 5e f3 ff ff       	jmp    80106949 <alltraps>

801075eb <vector160>:
.globl vector160
vector160:
  pushl $0
801075eb:	6a 00                	push   $0x0
  pushl $160
801075ed:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801075f2:	e9 52 f3 ff ff       	jmp    80106949 <alltraps>

801075f7 <vector161>:
.globl vector161
vector161:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $161
801075f9:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801075fe:	e9 46 f3 ff ff       	jmp    80106949 <alltraps>

80107603 <vector162>:
.globl vector162
vector162:
  pushl $0
80107603:	6a 00                	push   $0x0
  pushl $162
80107605:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010760a:	e9 3a f3 ff ff       	jmp    80106949 <alltraps>

8010760f <vector163>:
.globl vector163
vector163:
  pushl $0
8010760f:	6a 00                	push   $0x0
  pushl $163
80107611:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107616:	e9 2e f3 ff ff       	jmp    80106949 <alltraps>

8010761b <vector164>:
.globl vector164
vector164:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $164
8010761d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107622:	e9 22 f3 ff ff       	jmp    80106949 <alltraps>

80107627 <vector165>:
.globl vector165
vector165:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $165
80107629:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010762e:	e9 16 f3 ff ff       	jmp    80106949 <alltraps>

80107633 <vector166>:
.globl vector166
vector166:
  pushl $0
80107633:	6a 00                	push   $0x0
  pushl $166
80107635:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010763a:	e9 0a f3 ff ff       	jmp    80106949 <alltraps>

8010763f <vector167>:
.globl vector167
vector167:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $167
80107641:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107646:	e9 fe f2 ff ff       	jmp    80106949 <alltraps>

8010764b <vector168>:
.globl vector168
vector168:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $168
8010764d:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107652:	e9 f2 f2 ff ff       	jmp    80106949 <alltraps>

80107657 <vector169>:
.globl vector169
vector169:
  pushl $0
80107657:	6a 00                	push   $0x0
  pushl $169
80107659:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010765e:	e9 e6 f2 ff ff       	jmp    80106949 <alltraps>

80107663 <vector170>:
.globl vector170
vector170:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $170
80107665:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010766a:	e9 da f2 ff ff       	jmp    80106949 <alltraps>

8010766f <vector171>:
.globl vector171
vector171:
  pushl $0
8010766f:	6a 00                	push   $0x0
  pushl $171
80107671:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107676:	e9 ce f2 ff ff       	jmp    80106949 <alltraps>

8010767b <vector172>:
.globl vector172
vector172:
  pushl $0
8010767b:	6a 00                	push   $0x0
  pushl $172
8010767d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107682:	e9 c2 f2 ff ff       	jmp    80106949 <alltraps>

80107687 <vector173>:
.globl vector173
vector173:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $173
80107689:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010768e:	e9 b6 f2 ff ff       	jmp    80106949 <alltraps>

80107693 <vector174>:
.globl vector174
vector174:
  pushl $0
80107693:	6a 00                	push   $0x0
  pushl $174
80107695:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010769a:	e9 aa f2 ff ff       	jmp    80106949 <alltraps>

8010769f <vector175>:
.globl vector175
vector175:
  pushl $0
8010769f:	6a 00                	push   $0x0
  pushl $175
801076a1:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801076a6:	e9 9e f2 ff ff       	jmp    80106949 <alltraps>

801076ab <vector176>:
.globl vector176
vector176:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $176
801076ad:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801076b2:	e9 92 f2 ff ff       	jmp    80106949 <alltraps>

801076b7 <vector177>:
.globl vector177
vector177:
  pushl $0
801076b7:	6a 00                	push   $0x0
  pushl $177
801076b9:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801076be:	e9 86 f2 ff ff       	jmp    80106949 <alltraps>

801076c3 <vector178>:
.globl vector178
vector178:
  pushl $0
801076c3:	6a 00                	push   $0x0
  pushl $178
801076c5:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801076ca:	e9 7a f2 ff ff       	jmp    80106949 <alltraps>

801076cf <vector179>:
.globl vector179
vector179:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $179
801076d1:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801076d6:	e9 6e f2 ff ff       	jmp    80106949 <alltraps>

801076db <vector180>:
.globl vector180
vector180:
  pushl $0
801076db:	6a 00                	push   $0x0
  pushl $180
801076dd:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801076e2:	e9 62 f2 ff ff       	jmp    80106949 <alltraps>

801076e7 <vector181>:
.globl vector181
vector181:
  pushl $0
801076e7:	6a 00                	push   $0x0
  pushl $181
801076e9:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801076ee:	e9 56 f2 ff ff       	jmp    80106949 <alltraps>

801076f3 <vector182>:
.globl vector182
vector182:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $182
801076f5:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801076fa:	e9 4a f2 ff ff       	jmp    80106949 <alltraps>

801076ff <vector183>:
.globl vector183
vector183:
  pushl $0
801076ff:	6a 00                	push   $0x0
  pushl $183
80107701:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107706:	e9 3e f2 ff ff       	jmp    80106949 <alltraps>

8010770b <vector184>:
.globl vector184
vector184:
  pushl $0
8010770b:	6a 00                	push   $0x0
  pushl $184
8010770d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107712:	e9 32 f2 ff ff       	jmp    80106949 <alltraps>

80107717 <vector185>:
.globl vector185
vector185:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $185
80107719:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010771e:	e9 26 f2 ff ff       	jmp    80106949 <alltraps>

80107723 <vector186>:
.globl vector186
vector186:
  pushl $0
80107723:	6a 00                	push   $0x0
  pushl $186
80107725:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010772a:	e9 1a f2 ff ff       	jmp    80106949 <alltraps>

8010772f <vector187>:
.globl vector187
vector187:
  pushl $0
8010772f:	6a 00                	push   $0x0
  pushl $187
80107731:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107736:	e9 0e f2 ff ff       	jmp    80106949 <alltraps>

8010773b <vector188>:
.globl vector188
vector188:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $188
8010773d:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107742:	e9 02 f2 ff ff       	jmp    80106949 <alltraps>

80107747 <vector189>:
.globl vector189
vector189:
  pushl $0
80107747:	6a 00                	push   $0x0
  pushl $189
80107749:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010774e:	e9 f6 f1 ff ff       	jmp    80106949 <alltraps>

80107753 <vector190>:
.globl vector190
vector190:
  pushl $0
80107753:	6a 00                	push   $0x0
  pushl $190
80107755:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010775a:	e9 ea f1 ff ff       	jmp    80106949 <alltraps>

8010775f <vector191>:
.globl vector191
vector191:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $191
80107761:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107766:	e9 de f1 ff ff       	jmp    80106949 <alltraps>

8010776b <vector192>:
.globl vector192
vector192:
  pushl $0
8010776b:	6a 00                	push   $0x0
  pushl $192
8010776d:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107772:	e9 d2 f1 ff ff       	jmp    80106949 <alltraps>

80107777 <vector193>:
.globl vector193
vector193:
  pushl $0
80107777:	6a 00                	push   $0x0
  pushl $193
80107779:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010777e:	e9 c6 f1 ff ff       	jmp    80106949 <alltraps>

80107783 <vector194>:
.globl vector194
vector194:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $194
80107785:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010778a:	e9 ba f1 ff ff       	jmp    80106949 <alltraps>

8010778f <vector195>:
.globl vector195
vector195:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $195
80107791:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107796:	e9 ae f1 ff ff       	jmp    80106949 <alltraps>

8010779b <vector196>:
.globl vector196
vector196:
  pushl $0
8010779b:	6a 00                	push   $0x0
  pushl $196
8010779d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801077a2:	e9 a2 f1 ff ff       	jmp    80106949 <alltraps>

801077a7 <vector197>:
.globl vector197
vector197:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $197
801077a9:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801077ae:	e9 96 f1 ff ff       	jmp    80106949 <alltraps>

801077b3 <vector198>:
.globl vector198
vector198:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $198
801077b5:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801077ba:	e9 8a f1 ff ff       	jmp    80106949 <alltraps>

801077bf <vector199>:
.globl vector199
vector199:
  pushl $0
801077bf:	6a 00                	push   $0x0
  pushl $199
801077c1:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801077c6:	e9 7e f1 ff ff       	jmp    80106949 <alltraps>

801077cb <vector200>:
.globl vector200
vector200:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $200
801077cd:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801077d2:	e9 72 f1 ff ff       	jmp    80106949 <alltraps>

801077d7 <vector201>:
.globl vector201
vector201:
  pushl $0
801077d7:	6a 00                	push   $0x0
  pushl $201
801077d9:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801077de:	e9 66 f1 ff ff       	jmp    80106949 <alltraps>

801077e3 <vector202>:
.globl vector202
vector202:
  pushl $0
801077e3:	6a 00                	push   $0x0
  pushl $202
801077e5:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801077ea:	e9 5a f1 ff ff       	jmp    80106949 <alltraps>

801077ef <vector203>:
.globl vector203
vector203:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $203
801077f1:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801077f6:	e9 4e f1 ff ff       	jmp    80106949 <alltraps>

801077fb <vector204>:
.globl vector204
vector204:
  pushl $0
801077fb:	6a 00                	push   $0x0
  pushl $204
801077fd:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107802:	e9 42 f1 ff ff       	jmp    80106949 <alltraps>

80107807 <vector205>:
.globl vector205
vector205:
  pushl $0
80107807:	6a 00                	push   $0x0
  pushl $205
80107809:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010780e:	e9 36 f1 ff ff       	jmp    80106949 <alltraps>

80107813 <vector206>:
.globl vector206
vector206:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $206
80107815:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010781a:	e9 2a f1 ff ff       	jmp    80106949 <alltraps>

8010781f <vector207>:
.globl vector207
vector207:
  pushl $0
8010781f:	6a 00                	push   $0x0
  pushl $207
80107821:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107826:	e9 1e f1 ff ff       	jmp    80106949 <alltraps>

8010782b <vector208>:
.globl vector208
vector208:
  pushl $0
8010782b:	6a 00                	push   $0x0
  pushl $208
8010782d:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107832:	e9 12 f1 ff ff       	jmp    80106949 <alltraps>

80107837 <vector209>:
.globl vector209
vector209:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $209
80107839:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010783e:	e9 06 f1 ff ff       	jmp    80106949 <alltraps>

80107843 <vector210>:
.globl vector210
vector210:
  pushl $0
80107843:	6a 00                	push   $0x0
  pushl $210
80107845:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010784a:	e9 fa f0 ff ff       	jmp    80106949 <alltraps>

8010784f <vector211>:
.globl vector211
vector211:
  pushl $0
8010784f:	6a 00                	push   $0x0
  pushl $211
80107851:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107856:	e9 ee f0 ff ff       	jmp    80106949 <alltraps>

8010785b <vector212>:
.globl vector212
vector212:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $212
8010785d:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107862:	e9 e2 f0 ff ff       	jmp    80106949 <alltraps>

80107867 <vector213>:
.globl vector213
vector213:
  pushl $0
80107867:	6a 00                	push   $0x0
  pushl $213
80107869:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010786e:	e9 d6 f0 ff ff       	jmp    80106949 <alltraps>

80107873 <vector214>:
.globl vector214
vector214:
  pushl $0
80107873:	6a 00                	push   $0x0
  pushl $214
80107875:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010787a:	e9 ca f0 ff ff       	jmp    80106949 <alltraps>

8010787f <vector215>:
.globl vector215
vector215:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $215
80107881:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107886:	e9 be f0 ff ff       	jmp    80106949 <alltraps>

8010788b <vector216>:
.globl vector216
vector216:
  pushl $0
8010788b:	6a 00                	push   $0x0
  pushl $216
8010788d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107892:	e9 b2 f0 ff ff       	jmp    80106949 <alltraps>

80107897 <vector217>:
.globl vector217
vector217:
  pushl $0
80107897:	6a 00                	push   $0x0
  pushl $217
80107899:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010789e:	e9 a6 f0 ff ff       	jmp    80106949 <alltraps>

801078a3 <vector218>:
.globl vector218
vector218:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $218
801078a5:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801078aa:	e9 9a f0 ff ff       	jmp    80106949 <alltraps>

801078af <vector219>:
.globl vector219
vector219:
  pushl $0
801078af:	6a 00                	push   $0x0
  pushl $219
801078b1:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801078b6:	e9 8e f0 ff ff       	jmp    80106949 <alltraps>

801078bb <vector220>:
.globl vector220
vector220:
  pushl $0
801078bb:	6a 00                	push   $0x0
  pushl $220
801078bd:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801078c2:	e9 82 f0 ff ff       	jmp    80106949 <alltraps>

801078c7 <vector221>:
.globl vector221
vector221:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $221
801078c9:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801078ce:	e9 76 f0 ff ff       	jmp    80106949 <alltraps>

801078d3 <vector222>:
.globl vector222
vector222:
  pushl $0
801078d3:	6a 00                	push   $0x0
  pushl $222
801078d5:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801078da:	e9 6a f0 ff ff       	jmp    80106949 <alltraps>

801078df <vector223>:
.globl vector223
vector223:
  pushl $0
801078df:	6a 00                	push   $0x0
  pushl $223
801078e1:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801078e6:	e9 5e f0 ff ff       	jmp    80106949 <alltraps>

801078eb <vector224>:
.globl vector224
vector224:
  pushl $0
801078eb:	6a 00                	push   $0x0
  pushl $224
801078ed:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801078f2:	e9 52 f0 ff ff       	jmp    80106949 <alltraps>

801078f7 <vector225>:
.globl vector225
vector225:
  pushl $0
801078f7:	6a 00                	push   $0x0
  pushl $225
801078f9:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801078fe:	e9 46 f0 ff ff       	jmp    80106949 <alltraps>

80107903 <vector226>:
.globl vector226
vector226:
  pushl $0
80107903:	6a 00                	push   $0x0
  pushl $226
80107905:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010790a:	e9 3a f0 ff ff       	jmp    80106949 <alltraps>

8010790f <vector227>:
.globl vector227
vector227:
  pushl $0
8010790f:	6a 00                	push   $0x0
  pushl $227
80107911:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107916:	e9 2e f0 ff ff       	jmp    80106949 <alltraps>

8010791b <vector228>:
.globl vector228
vector228:
  pushl $0
8010791b:	6a 00                	push   $0x0
  pushl $228
8010791d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107922:	e9 22 f0 ff ff       	jmp    80106949 <alltraps>

80107927 <vector229>:
.globl vector229
vector229:
  pushl $0
80107927:	6a 00                	push   $0x0
  pushl $229
80107929:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010792e:	e9 16 f0 ff ff       	jmp    80106949 <alltraps>

80107933 <vector230>:
.globl vector230
vector230:
  pushl $0
80107933:	6a 00                	push   $0x0
  pushl $230
80107935:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010793a:	e9 0a f0 ff ff       	jmp    80106949 <alltraps>

8010793f <vector231>:
.globl vector231
vector231:
  pushl $0
8010793f:	6a 00                	push   $0x0
  pushl $231
80107941:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107946:	e9 fe ef ff ff       	jmp    80106949 <alltraps>

8010794b <vector232>:
.globl vector232
vector232:
  pushl $0
8010794b:	6a 00                	push   $0x0
  pushl $232
8010794d:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107952:	e9 f2 ef ff ff       	jmp    80106949 <alltraps>

80107957 <vector233>:
.globl vector233
vector233:
  pushl $0
80107957:	6a 00                	push   $0x0
  pushl $233
80107959:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010795e:	e9 e6 ef ff ff       	jmp    80106949 <alltraps>

80107963 <vector234>:
.globl vector234
vector234:
  pushl $0
80107963:	6a 00                	push   $0x0
  pushl $234
80107965:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010796a:	e9 da ef ff ff       	jmp    80106949 <alltraps>

8010796f <vector235>:
.globl vector235
vector235:
  pushl $0
8010796f:	6a 00                	push   $0x0
  pushl $235
80107971:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107976:	e9 ce ef ff ff       	jmp    80106949 <alltraps>

8010797b <vector236>:
.globl vector236
vector236:
  pushl $0
8010797b:	6a 00                	push   $0x0
  pushl $236
8010797d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107982:	e9 c2 ef ff ff       	jmp    80106949 <alltraps>

80107987 <vector237>:
.globl vector237
vector237:
  pushl $0
80107987:	6a 00                	push   $0x0
  pushl $237
80107989:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010798e:	e9 b6 ef ff ff       	jmp    80106949 <alltraps>

80107993 <vector238>:
.globl vector238
vector238:
  pushl $0
80107993:	6a 00                	push   $0x0
  pushl $238
80107995:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010799a:	e9 aa ef ff ff       	jmp    80106949 <alltraps>

8010799f <vector239>:
.globl vector239
vector239:
  pushl $0
8010799f:	6a 00                	push   $0x0
  pushl $239
801079a1:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801079a6:	e9 9e ef ff ff       	jmp    80106949 <alltraps>

801079ab <vector240>:
.globl vector240
vector240:
  pushl $0
801079ab:	6a 00                	push   $0x0
  pushl $240
801079ad:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801079b2:	e9 92 ef ff ff       	jmp    80106949 <alltraps>

801079b7 <vector241>:
.globl vector241
vector241:
  pushl $0
801079b7:	6a 00                	push   $0x0
  pushl $241
801079b9:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801079be:	e9 86 ef ff ff       	jmp    80106949 <alltraps>

801079c3 <vector242>:
.globl vector242
vector242:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $242
801079c5:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801079ca:	e9 7a ef ff ff       	jmp    80106949 <alltraps>

801079cf <vector243>:
.globl vector243
vector243:
  pushl $0
801079cf:	6a 00                	push   $0x0
  pushl $243
801079d1:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801079d6:	e9 6e ef ff ff       	jmp    80106949 <alltraps>

801079db <vector244>:
.globl vector244
vector244:
  pushl $0
801079db:	6a 00                	push   $0x0
  pushl $244
801079dd:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801079e2:	e9 62 ef ff ff       	jmp    80106949 <alltraps>

801079e7 <vector245>:
.globl vector245
vector245:
  pushl $0
801079e7:	6a 00                	push   $0x0
  pushl $245
801079e9:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801079ee:	e9 56 ef ff ff       	jmp    80106949 <alltraps>

801079f3 <vector246>:
.globl vector246
vector246:
  pushl $0
801079f3:	6a 00                	push   $0x0
  pushl $246
801079f5:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801079fa:	e9 4a ef ff ff       	jmp    80106949 <alltraps>

801079ff <vector247>:
.globl vector247
vector247:
  pushl $0
801079ff:	6a 00                	push   $0x0
  pushl $247
80107a01:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107a06:	e9 3e ef ff ff       	jmp    80106949 <alltraps>

80107a0b <vector248>:
.globl vector248
vector248:
  pushl $0
80107a0b:	6a 00                	push   $0x0
  pushl $248
80107a0d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107a12:	e9 32 ef ff ff       	jmp    80106949 <alltraps>

80107a17 <vector249>:
.globl vector249
vector249:
  pushl $0
80107a17:	6a 00                	push   $0x0
  pushl $249
80107a19:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107a1e:	e9 26 ef ff ff       	jmp    80106949 <alltraps>

80107a23 <vector250>:
.globl vector250
vector250:
  pushl $0
80107a23:	6a 00                	push   $0x0
  pushl $250
80107a25:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107a2a:	e9 1a ef ff ff       	jmp    80106949 <alltraps>

80107a2f <vector251>:
.globl vector251
vector251:
  pushl $0
80107a2f:	6a 00                	push   $0x0
  pushl $251
80107a31:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107a36:	e9 0e ef ff ff       	jmp    80106949 <alltraps>

80107a3b <vector252>:
.globl vector252
vector252:
  pushl $0
80107a3b:	6a 00                	push   $0x0
  pushl $252
80107a3d:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107a42:	e9 02 ef ff ff       	jmp    80106949 <alltraps>

80107a47 <vector253>:
.globl vector253
vector253:
  pushl $0
80107a47:	6a 00                	push   $0x0
  pushl $253
80107a49:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107a4e:	e9 f6 ee ff ff       	jmp    80106949 <alltraps>

80107a53 <vector254>:
.globl vector254
vector254:
  pushl $0
80107a53:	6a 00                	push   $0x0
  pushl $254
80107a55:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107a5a:	e9 ea ee ff ff       	jmp    80106949 <alltraps>

80107a5f <vector255>:
.globl vector255
vector255:
  pushl $0
80107a5f:	6a 00                	push   $0x0
  pushl $255
80107a61:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107a66:	e9 de ee ff ff       	jmp    80106949 <alltraps>

80107a6b <lgdt>:
{
80107a6b:	55                   	push   %ebp
80107a6c:	89 e5                	mov    %esp,%ebp
80107a6e:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107a71:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a74:	83 e8 01             	sub    $0x1,%eax
80107a77:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a7e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a82:	8b 45 08             	mov    0x8(%ebp),%eax
80107a85:	c1 e8 10             	shr    $0x10,%eax
80107a88:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107a8c:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a8f:	0f 01 10             	lgdtl  (%eax)
}
80107a92:	90                   	nop
80107a93:	c9                   	leave  
80107a94:	c3                   	ret    

80107a95 <ltr>:
{
80107a95:	55                   	push   %ebp
80107a96:	89 e5                	mov    %esp,%ebp
80107a98:	83 ec 04             	sub    $0x4,%esp
80107a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a9e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107aa2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107aa6:	0f 00 d8             	ltr    %ax
}
80107aa9:	90                   	nop
80107aaa:	c9                   	leave  
80107aab:	c3                   	ret    

80107aac <lcr3>:

static inline void
lcr3(uint val)
{
80107aac:	55                   	push   %ebp
80107aad:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80107ab2:	0f 22 d8             	mov    %eax,%cr3
}
80107ab5:	90                   	nop
80107ab6:	5d                   	pop    %ebp
80107ab7:	c3                   	ret    

80107ab8 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107ab8:	f3 0f 1e fb          	endbr32 
80107abc:	55                   	push   %ebp
80107abd:	89 e5                	mov    %esp,%ebp
80107abf:	83 ec 18             	sub    $0x18,%esp

    // Map "logical" addresses to virtual addresses using identity map.
    // Cannot share a CODE descriptor for both kernel and user
    // because it would have to have DPL_USR, but the CPU forbids
    // an interrupt from CPL=0 to DPL=3.
    c = &cpus[cpuid()];
80107ac2:	e8 31 c5 ff ff       	call   80103ff8 <cpuid>
80107ac7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107acd:	05 00 b2 11 80       	add    $0x8011b200,%eax
80107ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)

    c->gdt[SEG_KCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, 0);
80107ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad8:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae1:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aea:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107af5:	83 e2 f0             	and    $0xfffffff0,%edx
80107af8:	83 ca 0a             	or     $0xa,%edx
80107afb:	88 50 7d             	mov    %dl,0x7d(%eax)
80107afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b01:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b05:	83 ca 10             	or     $0x10,%edx
80107b08:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0e:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b12:	83 e2 9f             	and    $0xffffff9f,%edx
80107b15:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b1f:	83 ca 80             	or     $0xffffff80,%edx
80107b22:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b28:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b2c:	83 ca 0f             	or     $0xf,%edx
80107b2f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b35:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b39:	83 e2 ef             	and    $0xffffffef,%edx
80107b3c:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b42:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b46:	83 e2 df             	and    $0xffffffdf,%edx
80107b49:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b53:	83 ca 40             	or     $0x40,%edx
80107b56:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b60:	83 ca 80             	or     $0xffffff80,%edx
80107b63:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b69:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
    c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b70:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b77:	ff ff 
80107b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7c:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b83:	00 00 
80107b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b88:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b92:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b99:	83 e2 f0             	and    $0xfffffff0,%edx
80107b9c:	83 ca 02             	or     $0x2,%edx
80107b9f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107baf:	83 ca 10             	or     $0x10,%edx
80107bb2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbb:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bc2:	83 e2 9f             	and    $0xffffff9f,%edx
80107bc5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bce:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bd5:	83 ca 80             	or     $0xffffff80,%edx
80107bd8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107be8:	83 ca 0f             	or     $0xf,%edx
80107beb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bfb:	83 e2 ef             	and    $0xffffffef,%edx
80107bfe:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c07:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c0e:	83 e2 df             	and    $0xffffffdf,%edx
80107c11:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c21:	83 ca 40             	or     $0x40,%edx
80107c24:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c34:	83 ca 80             	or     $0xffffff80,%edx
80107c37:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c40:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
    c->gdt[SEG_UCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, DPL_USER);
80107c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4a:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107c51:	ff ff 
80107c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c56:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107c5d:	00 00 
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c73:	83 e2 f0             	and    $0xfffffff0,%edx
80107c76:	83 ca 0a             	or     $0xa,%edx
80107c79:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c82:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c89:	83 ca 10             	or     $0x10,%edx
80107c8c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c95:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107c9c:	83 ca 60             	or     $0x60,%edx
80107c9f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107caf:	83 ca 80             	or     $0xffffff80,%edx
80107cb2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107cc2:	83 ca 0f             	or     $0xf,%edx
80107cc5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cce:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107cd5:	83 e2 ef             	and    $0xffffffef,%edx
80107cd8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ce8:	83 e2 df             	and    $0xffffffdf,%edx
80107ceb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107cfb:	83 ca 40             	or     $0x40,%edx
80107cfe:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d07:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d0e:	83 ca 80             	or     $0xffffff80,%edx
80107d11:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1a:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
    c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d24:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107d2b:	ff ff 
80107d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d30:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107d37:	00 00 
80107d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d46:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d4d:	83 e2 f0             	and    $0xfffffff0,%edx
80107d50:	83 ca 02             	or     $0x2,%edx
80107d53:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d63:	83 ca 10             	or     $0x10,%edx
80107d66:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d76:	83 ca 60             	or     $0x60,%edx
80107d79:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d82:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d89:	83 ca 80             	or     $0xffffff80,%edx
80107d8c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d95:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107d9c:	83 ca 0f             	or     $0xf,%edx
80107d9f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107daf:	83 e2 ef             	and    $0xffffffef,%edx
80107db2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107dc2:	83 e2 df             	and    $0xffffffdf,%edx
80107dc5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dce:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107dd5:	83 ca 40             	or     $0x40,%edx
80107dd8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107de8:	83 ca 80             	or     $0xffffff80,%edx
80107deb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df4:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
    lgdt(c->gdt, sizeof(c->gdt));
80107dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfe:	83 c0 70             	add    $0x70,%eax
80107e01:	83 ec 08             	sub    $0x8,%esp
80107e04:	6a 30                	push   $0x30
80107e06:	50                   	push   %eax
80107e07:	e8 5f fc ff ff       	call   80107a6b <lgdt>
80107e0c:	83 c4 10             	add    $0x10,%esp
}
80107e0f:	90                   	nop
80107e10:	c9                   	leave  
80107e11:	c3                   	ret    

80107e12 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
pte_t*
walkpgdir(pde_t* pgdir, const void* va, int alloc)
{
80107e12:	f3 0f 1e fb          	endbr32 
80107e16:	55                   	push   %ebp
80107e17:	89 e5                	mov    %esp,%ebp
80107e19:	83 ec 18             	sub    $0x18,%esp
    pde_t* pde;
    pte_t* pgtab;

    pde = &pgdir[PDX(va)];
80107e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e1f:	c1 e8 16             	shr    $0x16,%eax
80107e22:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e29:	8b 45 08             	mov    0x8(%ebp),%eax
80107e2c:	01 d0                	add    %edx,%eax
80107e2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (*pde & PTE_P) {
80107e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e34:	8b 00                	mov    (%eax),%eax
80107e36:	83 e0 01             	and    $0x1,%eax
80107e39:	85 c0                	test   %eax,%eax
80107e3b:	74 14                	je     80107e51 <walkpgdir+0x3f>
        pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e40:	8b 00                	mov    (%eax),%eax
80107e42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e47:	05 00 00 00 80       	add    $0x80000000,%eax
80107e4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e4f:	eb 42                	jmp    80107e93 <walkpgdir+0x81>
    }
    else {
        if (!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107e51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107e55:	74 0e                	je     80107e65 <walkpgdir+0x53>
80107e57:	e8 20 af ff ff       	call   80102d7c <kalloc>
80107e5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e63:	75 07                	jne    80107e6c <walkpgdir+0x5a>
            return 0;
80107e65:	b8 00 00 00 00       	mov    $0x0,%eax
80107e6a:	eb 3e                	jmp    80107eaa <walkpgdir+0x98>
        // Make sure all those PTE_P bits are zero.
        memset(pgtab, 0, PGSIZE);
80107e6c:	83 ec 04             	sub    $0x4,%esp
80107e6f:	68 00 10 00 00       	push   $0x1000
80107e74:	6a 00                	push   $0x0
80107e76:	ff 75 f4             	pushl  -0xc(%ebp)
80107e79:	e8 f7 d5 ff ff       	call   80105475 <memset>
80107e7e:	83 c4 10             	add    $0x10,%esp
        // The permissions here are overly generous, but they can
        // be further restricted by the permissions in the page table
        // entries, if necessary.
        *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e84:	05 00 00 00 80       	add    $0x80000000,%eax
80107e89:	83 c8 07             	or     $0x7,%eax
80107e8c:	89 c2                	mov    %eax,%edx
80107e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e91:	89 10                	mov    %edx,(%eax)
    }
    return &pgtab[PTX(va)];
80107e93:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e96:	c1 e8 0c             	shr    $0xc,%eax
80107e99:	25 ff 03 00 00       	and    $0x3ff,%eax
80107e9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea8:	01 d0                	add    %edx,%eax
}
80107eaa:	c9                   	leave  
80107eab:	c3                   	ret    

80107eac <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t* pgdir, void* va, uint size, uint pa, int perm)
{
80107eac:	f3 0f 1e fb          	endbr32 
80107eb0:	55                   	push   %ebp
80107eb1:	89 e5                	mov    %esp,%ebp
80107eb3:	83 ec 18             	sub    $0x18,%esp
    char* a, * last;
    pte_t* pte;

    a = (char*)PGROUNDDOWN((uint)va);
80107eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eb9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ebe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107ec1:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ec4:	8b 45 10             	mov    0x10(%ebp),%eax
80107ec7:	01 d0                	add    %edx,%eax
80107ec9:	83 e8 01             	sub    $0x1,%eax
80107ecc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ed1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (;;) {
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ed4:	83 ec 04             	sub    $0x4,%esp
80107ed7:	6a 01                	push   $0x1
80107ed9:	ff 75 f4             	pushl  -0xc(%ebp)
80107edc:	ff 75 08             	pushl  0x8(%ebp)
80107edf:	e8 2e ff ff ff       	call   80107e12 <walkpgdir>
80107ee4:	83 c4 10             	add    $0x10,%esp
80107ee7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107eea:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107eee:	75 07                	jne    80107ef7 <mappages+0x4b>
            return -1;
80107ef0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ef5:	eb 47                	jmp    80107f3e <mappages+0x92>
        if (*pte & PTE_P)
80107ef7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107efa:	8b 00                	mov    (%eax),%eax
80107efc:	83 e0 01             	and    $0x1,%eax
80107eff:	85 c0                	test   %eax,%eax
80107f01:	74 0d                	je     80107f10 <mappages+0x64>
            panic("remap");
80107f03:	83 ec 0c             	sub    $0xc,%esp
80107f06:	68 1c b4 10 80       	push   $0x8010b41c
80107f0b:	e8 b5 86 ff ff       	call   801005c5 <panic>
        *pte = pa | perm | PTE_P;
80107f10:	8b 45 18             	mov    0x18(%ebp),%eax
80107f13:	0b 45 14             	or     0x14(%ebp),%eax
80107f16:	83 c8 01             	or     $0x1,%eax
80107f19:	89 c2                	mov    %eax,%edx
80107f1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f1e:	89 10                	mov    %edx,(%eax)
        if (a == last)
80107f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f23:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f26:	74 10                	je     80107f38 <mappages+0x8c>
            break;
        a += PGSIZE;
80107f28:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
        pa += PGSIZE;
80107f2f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f36:	eb 9c                	jmp    80107ed4 <mappages+0x28>
            break;
80107f38:	90                   	nop
    }
    return 0;
80107f39:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f3e:	c9                   	leave  
80107f3f:	c3                   	ret    

80107f40 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107f40:	f3 0f 1e fb          	endbr32 
80107f44:	55                   	push   %ebp
80107f45:	89 e5                	mov    %esp,%ebp
80107f47:	53                   	push   %ebx
80107f48:	83 ec 24             	sub    $0x24,%esp
    pde_t* pgdir;
    struct kmap* k;
    k = kmap;
80107f4b:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
    struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr + gpu.vram_size, PTE_W };
80107f52:	a1 cc b4 11 80       	mov    0x8011b4cc,%eax
80107f57:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107f5c:	29 c2                	sub    %eax,%edx
80107f5e:	89 d0                	mov    %edx,%eax
80107f60:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f63:	a1 c4 b4 11 80       	mov    0x8011b4c4,%eax
80107f68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107f6b:	8b 15 c4 b4 11 80    	mov    0x8011b4c4,%edx
80107f71:	a1 cc b4 11 80       	mov    0x8011b4cc,%eax
80107f76:	01 d0                	add    %edx,%eax
80107f78:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107f7b:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
    k[3] = vram;
80107f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f85:	83 c0 30             	add    $0x30,%eax
80107f88:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107f8b:	89 10                	mov    %edx,(%eax)
80107f8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f90:	89 50 04             	mov    %edx,0x4(%eax)
80107f93:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107f96:	89 50 08             	mov    %edx,0x8(%eax)
80107f99:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107f9c:	89 50 0c             	mov    %edx,0xc(%eax)
    if ((pgdir = (pde_t*)kalloc()) == 0) {
80107f9f:	e8 d8 ad ff ff       	call   80102d7c <kalloc>
80107fa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fa7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fab:	75 07                	jne    80107fb4 <setupkvm+0x74>
        return 0;
80107fad:	b8 00 00 00 00       	mov    $0x0,%eax
80107fb2:	eb 78                	jmp    8010802c <setupkvm+0xec>
    }
    memset(pgdir, 0, PGSIZE);
80107fb4:	83 ec 04             	sub    $0x4,%esp
80107fb7:	68 00 10 00 00       	push   $0x1000
80107fbc:	6a 00                	push   $0x0
80107fbe:	ff 75 f0             	pushl  -0x10(%ebp)
80107fc1:	e8 af d4 ff ff       	call   80105475 <memset>
80107fc6:	83 c4 10             	add    $0x10,%esp
    if (P2V(PHYSTOP) > (void*)DEVSPACE)
        panic("PHYSTOP too high");
    for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107fc9:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107fd0:	eb 4e                	jmp    80108020 <setupkvm+0xe0>
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
80107ffb:	e8 ac fe ff ff       	call   80107eac <mappages>
80108000:	83 c4 20             	add    $0x20,%esp
80108003:	85 c0                	test   %eax,%eax
80108005:	79 15                	jns    8010801c <setupkvm+0xdc>
            freevm(pgdir);
80108007:	83 ec 0c             	sub    $0xc,%esp
8010800a:	ff 75 f0             	pushl  -0x10(%ebp)
8010800d:	e8 11 05 00 00       	call   80108523 <freevm>
80108012:	83 c4 10             	add    $0x10,%esp
            return 0;
80108015:	b8 00 00 00 00       	mov    $0x0,%eax
8010801a:	eb 10                	jmp    8010802c <setupkvm+0xec>
    for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010801c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108020:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80108027:	72 a9                	jb     80107fd2 <setupkvm+0x92>
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
8010803b:	e8 00 ff ff ff       	call   80107f40 <setupkvm>
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
8010805f:	e8 48 fa ff ff       	call   80107aac <lcr3>
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
8010807f:	68 22 b4 10 80       	push   $0x8010b422
80108084:	e8 3c 85 ff ff       	call   801005c5 <panic>
    if (p->kstack == 0)
80108089:	8b 45 08             	mov    0x8(%ebp),%eax
8010808c:	8b 40 08             	mov    0x8(%eax),%eax
8010808f:	85 c0                	test   %eax,%eax
80108091:	75 0d                	jne    801080a0 <switchuvm+0x36>
        panic("switchuvm: no kstack");
80108093:	83 ec 0c             	sub    $0xc,%esp
80108096:	68 38 b4 10 80       	push   $0x8010b438
8010809b:	e8 25 85 ff ff       	call   801005c5 <panic>
    if (p->pgdir == 0)
801080a0:	8b 45 08             	mov    0x8(%ebp),%eax
801080a3:	8b 40 04             	mov    0x4(%eax),%eax
801080a6:	85 c0                	test   %eax,%eax
801080a8:	75 0d                	jne    801080b7 <switchuvm+0x4d>
        panic("switchuvm: no pgdir");
801080aa:	83 ec 0c             	sub    $0xc,%esp
801080ad:	68 4d b4 10 80       	push   $0x8010b44d
801080b2:	e8 0e 85 ff ff       	call   801005c5 <panic>

    pushcli();
801080b7:	e8 a6 d2 ff ff       	call   80105362 <pushcli>
    mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801080bc:	e8 56 bf ff ff       	call   80104017 <mycpu>
801080c1:	89 c3                	mov    %eax,%ebx
801080c3:	e8 4f bf ff ff       	call   80104017 <mycpu>
801080c8:	83 c0 08             	add    $0x8,%eax
801080cb:	89 c6                	mov    %eax,%esi
801080cd:	e8 45 bf ff ff       	call   80104017 <mycpu>
801080d2:	83 c0 08             	add    $0x8,%eax
801080d5:	c1 e8 10             	shr    $0x10,%eax
801080d8:	88 45 f7             	mov    %al,-0x9(%ebp)
801080db:	e8 37 bf ff ff       	call   80104017 <mycpu>
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
8010819b:	e8 77 be ff ff       	call   80104017 <mycpu>
801081a0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801081a7:	83 e2 ef             	and    $0xffffffef,%edx
801081aa:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
    mycpu()->ts.ss0 = SEG_KDATA << 3;
801081b0:	e8 62 be ff ff       	call   80104017 <mycpu>
801081b5:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
    mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801081bb:	8b 45 08             	mov    0x8(%ebp),%eax
801081be:	8b 40 08             	mov    0x8(%eax),%eax
801081c1:	89 c3                	mov    %eax,%ebx
801081c3:	e8 4f be ff ff       	call   80104017 <mycpu>
801081c8:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801081ce:	89 50 0c             	mov    %edx,0xc(%eax)
    // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
    // forbids I/O instructions (e.g., inb and outb) from user space
    mycpu()->ts.iomb = (ushort)0xFFFF;
801081d1:	e8 41 be ff ff       	call   80104017 <mycpu>
801081d6:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
    ltr(SEG_TSS << 3);
801081dc:	83 ec 0c             	sub    $0xc,%esp
801081df:	6a 28                	push   $0x28
801081e1:	e8 af f8 ff ff       	call   80107a95 <ltr>
801081e6:	83 c4 10             	add    $0x10,%esp
    lcr3(V2P(p->pgdir));  // switch to process's address space
801081e9:	8b 45 08             	mov    0x8(%ebp),%eax
801081ec:	8b 40 04             	mov    0x4(%eax),%eax
801081ef:	05 00 00 00 80       	add    $0x80000000,%eax
801081f4:	83 ec 0c             	sub    $0xc,%esp
801081f7:	50                   	push   %eax
801081f8:	e8 af f8 ff ff       	call   80107aac <lcr3>
801081fd:	83 c4 10             	add    $0x10,%esp
    popcli();
80108200:	e8 ae d1 ff ff       	call   801053b3 <popcli>
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
80108223:	68 61 b4 10 80       	push   $0x8010b461
80108228:	e8 98 83 ff ff       	call   801005c5 <panic>
    mem = kalloc();
8010822d:	e8 4a ab ff ff       	call   80102d7c <kalloc>
80108232:	89 45 f4             	mov    %eax,-0xc(%ebp)
    memset(mem, 0, PGSIZE);
80108235:	83 ec 04             	sub    $0x4,%esp
80108238:	68 00 10 00 00       	push   $0x1000
8010823d:	6a 00                	push   $0x0
8010823f:	ff 75 f4             	pushl  -0xc(%ebp)
80108242:	e8 2e d2 ff ff       	call   80105475 <memset>
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
80108262:	e8 45 fc ff ff       	call   80107eac <mappages>
80108267:	83 c4 20             	add    $0x20,%esp
    memmove(mem, init, sz);
8010826a:	83 ec 04             	sub    $0x4,%esp
8010826d:	ff 75 10             	pushl  0x10(%ebp)
80108270:	ff 75 0c             	pushl  0xc(%ebp)
80108273:	ff 75 f4             	pushl  -0xc(%ebp)
80108276:	e8 c1 d2 ff ff       	call   8010553c <memmove>
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
8010829a:	68 7c b4 10 80       	push   $0x8010b47c
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
801082c1:	e8 4c fb ff ff       	call   80107e12 <walkpgdir>
801082c6:	83 c4 10             	add    $0x10,%esp
801082c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082d0:	75 0d                	jne    801082df <loaduvm+0x5e>
            panic("loaduvm: address should exist");
801082d2:	83 ec 0c             	sub    $0xc,%esp
801082d5:	68 9f b4 10 80       	push   $0x8010b49f
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
80108324:	e8 4d 9c ff ff       	call   80101f76 <readi>
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
80108392:	e8 e5 a9 ff ff       	call   80102d7c <kalloc>
80108397:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (mem == 0) {
8010839a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010839e:	75 2e                	jne    801083ce <allocuvm+0x7c>
            cprintf("allocuvm out of memory\n");
801083a0:	83 ec 0c             	sub    $0xc,%esp
801083a3:	68 bd b4 10 80       	push   $0x8010b4bd
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
801083db:	e8 95 d0 ff ff       	call   80105475 <memset>
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
801083fe:	e8 a9 fa ff ff       	call   80107eac <mappages>
80108403:	83 c4 20             	add    $0x20,%esp
80108406:	85 c0                	test   %eax,%eax
80108408:	79 39                	jns    80108443 <allocuvm+0xf1>
            cprintf("allocuvm out of memory (2)\n");
8010840a:	83 ec 0c             	sub    $0xc,%esp
8010840d:	68 d5 b4 10 80       	push   $0x8010b4d5
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
80108434:	e8 a5 a8 ff ff       	call   80102cde <kfree>
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
80108496:	e8 77 f9 ff ff       	call   80107e12 <walkpgdir>
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
801084df:	68 f1 b4 10 80       	push   $0x8010b4f1
801084e4:	e8 dc 80 ff ff       	call   801005c5 <panic>
            char* v = P2V(pa);
801084e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ec:	05 00 00 00 80       	add    $0x80000000,%eax
801084f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
            kfree(v);
801084f4:	83 ec 0c             	sub    $0xc,%esp
801084f7:	ff 75 e8             	pushl  -0x18(%ebp)
801084fa:	e8 df a7 ff ff       	call   80102cde <kfree>
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
80108536:	68 f7 b4 10 80       	push   $0x8010b4f7
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
8010859a:	e8 3f a7 ff ff       	call   80102cde <kfree>
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
801085b5:	e8 24 a7 ff ff       	call   80102cde <kfree>
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
801085d5:	e8 38 f8 ff ff       	call   80107e12 <walkpgdir>
801085da:	83 c4 10             	add    $0x10,%esp
801085dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (pte == 0)
801085e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801085e4:	75 0d                	jne    801085f3 <clearpteu+0x33>
        panic("clearpteu");
801085e6:	83 ec 0c             	sub    $0xc,%esp
801085e9:	68 08 b5 10 80       	push   $0x8010b508
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
8010860f:	e8 2c f9 ff ff       	call   80107f40 <setupkvm>
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
8010863f:	e8 ce f7 ff ff       	call   80107e12 <walkpgdir>
80108644:	83 c4 10             	add    $0x10,%esp
80108647:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010864a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010864e:	75 0d                	jne    8010865d <copyuvm+0x58>
            panic("copyuvm: pte should exist");
80108650:	83 ec 0c             	sub    $0xc,%esp
80108653:	68 12 b5 10 80       	push   $0x8010b512
80108658:	e8 68 7f ff ff       	call   801005c5 <panic>
        if (!(*pte & PTE_P))
8010865d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108660:	8b 00                	mov    (%eax),%eax
80108662:	83 e0 01             	and    $0x1,%eax
80108665:	85 c0                	test   %eax,%eax
80108667:	75 0d                	jne    80108676 <copyuvm+0x71>
            panic("copyuvm: page not present");
80108669:	83 ec 0c             	sub    $0xc,%esp
8010866c:	68 2c b5 10 80       	push   $0x8010b52c
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
80108690:	e8 e7 a6 ff ff       	call   80102d7c <kalloc>
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
801086b6:	e8 81 ce ff ff       	call   8010553c <memmove>
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
801086db:	e8 cc f7 ff ff       	call   80107eac <mappages>
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
    uint t = TOP;
801086fe:	c7 45 ec ff ff ff 7f 	movl   $0x7fffffff,-0x14(%ebp)
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
80108723:	e8 ea f6 ff ff       	call   80107e12 <walkpgdir>
80108728:	83 c4 10             	add    $0x10,%esp
8010872b:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010872e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108732:	75 0d                	jne    80108741 <copyuvm+0x13c>
            panic("copyuvm: pte should exist");
80108734:	83 ec 0c             	sub    $0xc,%esp
80108737:	68 12 b5 10 80       	push   $0x8010b512
8010873c:	e8 84 7e ff ff       	call   801005c5 <panic>
        if (!(*pte & PTE_P))
80108741:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108744:	8b 00                	mov    (%eax),%eax
80108746:	83 e0 01             	and    $0x1,%eax
80108749:	85 c0                	test   %eax,%eax
8010874b:	75 0d                	jne    8010875a <copyuvm+0x155>
            panic("copyuvm: page not present");
8010874d:	83 ec 0c             	sub    $0xc,%esp
80108750:	68 2c b5 10 80       	push   $0x8010b52c
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
80108774:	e8 03 a6 ff ff       	call   80102d7c <kalloc>
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
80108796:	e8 a1 cd ff ff       	call   8010553c <memmove>
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
801087bb:	e8 ec f6 ff ff       	call   80107eac <mappages>
801087c0:	83 c4 20             	add    $0x20,%esp
801087c3:	85 c0                	test   %eax,%eax
801087c5:	79 10                	jns    801087d7 <copyuvm+0x1d2>
            kfree(mem);
801087c7:	83 ec 0c             	sub    $0xc,%esp
801087ca:	ff 75 dc             	pushl  -0x24(%ebp)
801087cd:	e8 0c a5 ff ff       	call   80102cde <kfree>
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
80108825:	e8 e8 f5 ff ff       	call   80107e12 <walkpgdir>
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
801088d9:	e8 5e cc ff ff       	call   8010553c <memmove>
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
80108967:	8b 04 85 48 b5 10 80 	mov    -0x7fef4ab8(,%eax,4),%eax
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
80108ad4:	e8 55 a6 ff ff       	call   8010312e <microdelay>
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
80108c56:	e8 e1 c8 ff ff       	call   8010553c <memmove>
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
80108c7d:	e8 f3 c7 ff ff       	call   80105475 <memset>
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
80108cb9:	0f b7 84 00 60 b5 10 	movzwl -0x7fef4aa0(%eax,%eax,1),%eax
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
80108d04:	68 00 f5 10 80       	push   $0x8010f500
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
80108e97:	e8 92 a2 ff ff       	call   8010312e <microdelay>
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
80108fa2:	68 a4 cb 10 80       	push   $0x8010cba4
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
80108ff6:	68 d8 cb 10 80       	push   $0x8010cbd8
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
80109042:	68 fc cb 10 80       	push   $0x8010cbfc
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
801090d1:	68 41 cc 10 80       	push   $0x8010cc41
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
80109102:	68 5b cc 10 80       	push   $0x8010cc5b
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
801091ff:	68 70 cc 10 80       	push   $0x8010cc70
80109204:	e8 03 72 ff ff       	call   8010040c <cprintf>
80109209:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
8010920c:	e8 6b 9b ff ff       	call   80102d7c <kalloc>
80109211:	a3 f8 b4 11 80       	mov    %eax,0x8011b4f8
  *intr_addr = 0;
80109216:	a1 f8 b4 11 80       	mov    0x8011b4f8,%eax
8010921b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80109221:	a1 f8 b4 11 80       	mov    0x8011b4f8,%eax
80109226:	83 ec 08             	sub    $0x8,%esp
80109229:	50                   	push   %eax
8010922a:	68 92 cc 10 80       	push   $0x8010cc92
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
80109241:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109248:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010924b:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109252:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80109255:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010925c:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
8010925f:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109266:	0f b6 c0             	movzbl %al,%eax
80109269:	83 ec 0c             	sub    $0xc,%esp
8010926c:	53                   	push   %ebx
8010926d:	51                   	push   %ecx
8010926e:	52                   	push   %edx
8010926f:	50                   	push   %eax
80109270:	68 a0 cc 10 80       	push   $0x8010cca0
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
80109347:	68 b8 cc 10 80       	push   $0x8010ccb8
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
8010941a:	e8 5d 99 ff ff       	call   80102d7c <kalloc>
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
80109529:	e8 4e 98 ff ff       	call   80102d7c <kalloc>
8010952e:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80109531:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109535:	75 12                	jne    80109549 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80109537:	83 ec 0c             	sub    $0xc,%esp
8010953a:	68 d8 cc 10 80       	push   $0x8010ccd8
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
80109598:	68 f8 cc 10 80       	push   $0x8010ccf8
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
801095ce:	e8 a9 97 ff ff       	call   80102d7c <kalloc>
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
801096f3:	e8 84 96 ff ff       	call   80102d7c <kalloc>
801096f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
801096fb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
801096ff:	75 12                	jne    80109713 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
80109701:	83 ec 0c             	sub    $0xc,%esp
80109704:	68 d8 cc 10 80       	push   $0x8010ccd8
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
8010977f:	68 18 cd 10 80       	push   $0x8010cd18
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
801097ba:	68 38 cd 10 80       	push   $0x8010cd38
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
80109926:	e8 11 bc ff ff       	call   8010553c <memmove>
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
80109a3d:	68 04 f5 10 80       	push   $0x8010f504
80109a42:	e8 99 ba ff ff       	call   801054e0 <memcmp>
80109a47:	83 c4 10             	add    $0x10,%esp
80109a4a:	85 c0                	test   %eax,%eax
80109a4c:	74 27                	je     80109a75 <arp_proc+0xab>
80109a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a51:	83 c0 0e             	add    $0xe,%eax
80109a54:	83 ec 04             	sub    $0x4,%esp
80109a57:	6a 04                	push   $0x4
80109a59:	50                   	push   %eax
80109a5a:	68 04 f5 10 80       	push   $0x8010f504
80109a5f:	e8 7c ba ff ff       	call   801054e0 <memcmp>
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
80109a8e:	68 04 f5 10 80       	push   $0x8010f504
80109a93:	e8 48 ba ff ff       	call   801054e0 <memcmp>
80109a98:	83 c4 10             	add    $0x10,%esp
80109a9b:	85 c0                	test   %eax,%eax
80109a9d:	75 4c                	jne    80109aeb <arp_proc+0x121>
    uint send = (uint)kalloc();
80109a9f:	e8 d8 92 ff ff       	call   80102d7c <kalloc>
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
80109adc:	e8 fd 91 ff ff       	call   80102cde <kfree>
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
80109b04:	68 04 f5 10 80       	push   $0x8010f504
80109b09:	e8 d2 b9 ff ff       	call   801054e0 <memcmp>
80109b0e:	83 c4 10             	add    $0x10,%esp
80109b11:	85 c0                	test   %eax,%eax
80109b13:	75 25                	jne    80109b3a <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
80109b15:	83 ec 0c             	sub    $0xc,%esp
80109b18:	68 3c cd 10 80       	push   $0x8010cd3c
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
80109b54:	e8 23 92 ff ff       	call   80102d7c <kalloc>
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
80109b8d:	e8 9c 95 ff ff       	call   8010312e <microdelay>
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
80109bb7:	e8 22 91 ff ff       	call   80102cde <kfree>
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
80109c39:	e8 fe b8 ff ff       	call   8010553c <memmove>
80109c3e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c44:	83 c0 06             	add    $0x6,%eax
80109c47:	83 ec 04             	sub    $0x4,%esp
80109c4a:	6a 06                	push   $0x6
80109c4c:	68 ac 00 11 80       	push   $0x801100ac
80109c51:	50                   	push   %eax
80109c52:	e8 e5 b8 ff ff       	call   8010553c <memmove>
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
80109c92:	e8 a5 b8 ff ff       	call   8010553c <memmove>
80109c97:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c9d:	8d 50 18             	lea    0x18(%eax),%edx
80109ca0:	83 ec 04             	sub    $0x4,%esp
80109ca3:	6a 04                	push   $0x4
80109ca5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109ca8:	50                   	push   %eax
80109ca9:	52                   	push   %edx
80109caa:	e8 8d b8 ff ff       	call   8010553c <memmove>
80109caf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cb5:	83 c0 08             	add    $0x8,%eax
80109cb8:	83 ec 04             	sub    $0x4,%esp
80109cbb:	6a 06                	push   $0x6
80109cbd:	68 ac 00 11 80       	push   $0x801100ac
80109cc2:	50                   	push   %eax
80109cc3:	e8 74 b8 ff ff       	call   8010553c <memmove>
80109cc8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cce:	83 c0 0e             	add    $0xe,%eax
80109cd1:	83 ec 04             	sub    $0x4,%esp
80109cd4:	6a 04                	push   $0x4
80109cd6:	68 04 f5 10 80       	push   $0x8010f504
80109cdb:	50                   	push   %eax
80109cdc:	e8 5b b8 ff ff       	call   8010553c <memmove>
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
80109d2f:	e8 08 b8 ff ff       	call   8010553c <memmove>
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
80109d63:	e8 d4 b7 ff ff       	call   8010553c <memmove>
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
80109d8b:	e8 ac b7 ff ff       	call   8010553c <memmove>
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
80109df2:	e8 e9 b6 ff ff       	call   801054e0 <memcmp>
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
80109e73:	68 4f cd 10 80       	push   $0x8010cd4f
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
80109ea2:	68 5e cd 10 80       	push   $0x8010cd5e
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
80109ed4:	68 60 cd 10 80       	push   $0x8010cd60
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
80109f33:	e8 04 b6 ff ff       	call   8010553c <memmove>
80109f38:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f3e:	83 c0 06             	add    $0x6,%eax
80109f41:	83 ec 04             	sub    $0x4,%esp
80109f44:	6a 06                	push   $0x6
80109f46:	68 ac 00 11 80       	push   $0x801100ac
80109f4b:	50                   	push   %eax
80109f4c:	e8 eb b5 ff ff       	call   8010553c <memmove>
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
80109f8f:	e8 a8 b5 ff ff       	call   8010553c <memmove>
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
80109faa:	e8 8d b5 ff ff       	call   8010553c <memmove>
80109faf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109fb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fb5:	83 c0 08             	add    $0x8,%eax
80109fb8:	83 ec 04             	sub    $0x4,%esp
80109fbb:	6a 06                	push   $0x6
80109fbd:	68 ac 00 11 80       	push   $0x801100ac
80109fc2:	50                   	push   %eax
80109fc3:	e8 74 b5 ff ff       	call   8010553c <memmove>
80109fc8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fce:	83 c0 0e             	add    $0xe,%eax
80109fd1:	83 ec 04             	sub    $0x4,%esp
80109fd4:	6a 04                	push   $0x4
80109fd6:	68 04 f5 10 80       	push   $0x8010f504
80109fdb:	50                   	push   %eax
80109fdc:	e8 5b b5 ff ff       	call   8010553c <memmove>
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
80109ff4:	68 62 cd 10 80       	push   $0x8010cd62
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
8010a016:	68 60 cd 10 80       	push   $0x8010cd60
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
8010a038:	68 60 cd 10 80       	push   $0x8010cd60
8010a03d:	e8 ca 63 ff ff       	call   8010040c <cprintf>
8010a042:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010a045:	83 ec 0c             	sub    $0xc,%esp
8010a048:	68 79 cd 10 80       	push   $0x8010cd79
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
8010a06a:	68 60 cd 10 80       	push   $0x8010cd60
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
8010a08c:	68 60 cd 10 80       	push   $0x8010cd60
8010a091:	e8 76 63 ff ff       	call   8010040c <cprintf>
8010a096:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
8010a099:	83 ec 0c             	sub    $0xc,%esp
8010a09c:	68 90 cd 10 80       	push   $0x8010cd90
8010a0a1:	e8 66 63 ff ff       	call   8010040c <cprintf>
8010a0a6:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
8010a0a9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0ac:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a0b0:	66 3d 00 01          	cmp    $0x100,%ax
8010a0b4:	75 12                	jne    8010a0c8 <print_arp_info+0xe1>
8010a0b6:	83 ec 0c             	sub    $0xc,%esp
8010a0b9:	68 9c cd 10 80       	push   $0x8010cd9c
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
8010a0d8:	68 a5 cd 10 80       	push   $0x8010cda5
8010a0dd:	e8 2a 63 ff ff       	call   8010040c <cprintf>
8010a0e2:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010a0e5:	83 ec 0c             	sub    $0xc,%esp
8010a0e8:	68 60 cd 10 80       	push   $0x8010cd60
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
8010a137:	68 ac cd 10 80       	push   $0x8010cdac
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
8010a1a5:	68 c4 cd 10 80       	push   $0x8010cdc4
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
8010a2eb:	a1 08 f5 10 80       	mov    0x8010f508,%eax
8010a2f0:	39 c2                	cmp    %eax,%edx
8010a2f2:	74 60                	je     8010a354 <ipv4_proc+0x86>
8010a2f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2f7:	83 c0 0c             	add    $0xc,%eax
8010a2fa:	83 ec 04             	sub    $0x4,%esp
8010a2fd:	6a 04                	push   $0x4
8010a2ff:	50                   	push   %eax
8010a300:	68 04 f5 10 80       	push   $0x8010f504
8010a305:	e8 d6 b1 ff ff       	call   801054e0 <memcmp>
8010a30a:	83 c4 10             	add    $0x10,%esp
8010a30d:	85 c0                	test   %eax,%eax
8010a30f:	74 43                	je     8010a354 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
8010a311:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a314:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a318:	0f b7 c0             	movzwl %ax,%eax
8010a31b:	a3 08 f5 10 80       	mov    %eax,0x8010f508
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
8010a41e:	e8 59 89 ff ff       	call   80102d7c <kalloc>
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
8010a45b:	e8 7e 88 ff ff       	call   80102cde <kfree>
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
8010a4a8:	68 e3 cd 10 80       	push   $0x8010cde3
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
8010a51e:	e8 19 b0 ff ff       	call   8010553c <memmove>
8010a523:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a526:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a529:	83 c0 06             	add    $0x6,%eax
8010a52c:	83 ec 04             	sub    $0x4,%esp
8010a52f:	6a 06                	push   $0x6
8010a531:	68 ac 00 11 80       	push   $0x801100ac
8010a536:	50                   	push   %eax
8010a537:	e8 00 b0 ff ff       	call   8010553c <memmove>
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
8010a5bc:	68 04 f5 10 80       	push   $0x8010f504
8010a5c1:	50                   	push   %eax
8010a5c2:	e8 75 af ff ff       	call   8010553c <memmove>
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
8010a5dd:	e8 5a af ff ff       	call   8010553c <memmove>
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
8010a64f:	e8 e8 ae ff ff       	call   8010553c <memmove>
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
8010a66a:	e8 cd ae ff ff       	call   8010553c <memmove>
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
8010a74d:	e8 2a 86 ff ff       	call   80102d7c <kalloc>
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
8010a7be:	68 fe cd 10 80       	push   $0x8010cdfe
8010a7c3:	ff 75 ec             	pushl  -0x14(%ebp)
8010a7c6:	e8 15 ad ff ff       	call   801054e0 <memcmp>
8010a7cb:	83 c4 10             	add    $0x10,%esp
8010a7ce:	85 c0                	test   %eax,%eax
8010a7d0:	74 74                	je     8010a846 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a7d2:	83 ec 0c             	sub    $0xc,%esp
8010a7d5:	68 02 ce 10 80       	push   $0x8010ce02
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
8010a91a:	e8 bf 83 ff ff       	call   80102cde <kfree>
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
8010a98a:	e8 ad ab ff ff       	call   8010553c <memmove>
8010a98f:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a992:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a995:	83 c0 06             	add    $0x6,%eax
8010a998:	83 ec 04             	sub    $0x4,%esp
8010a99b:	6a 06                	push   $0x6
8010a99d:	68 ac 00 11 80       	push   $0x801100ac
8010a9a2:	50                   	push   %eax
8010a9a3:	e8 94 ab ff ff       	call   8010553c <memmove>
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
8010aa2d:	68 04 f5 10 80       	push   $0x8010f504
8010aa32:	50                   	push   %eax
8010aa33:	e8 04 ab ff ff       	call   8010553c <memmove>
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
8010aa4e:	e8 e9 aa ff ff       	call   8010553c <memmove>
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
8010ab59:	68 04 f5 10 80       	push   $0x8010f504
8010ab5e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ab61:	50                   	push   %eax
8010ab62:	e8 d5 a9 ff ff       	call   8010553c <memmove>
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
8010ab7d:	e8 ba a9 ff ff       	call   8010553c <memmove>
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
8010ac9e:	68 0b ce 10 80       	push   $0x8010ce0b
8010aca3:	50                   	push   %eax
8010aca4:	e8 65 00 00 00       	call   8010ad0e <http_strcpy>
8010aca9:	83 c4 10             	add    $0x10,%esp
8010acac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010acaf:	8b 45 10             	mov    0x10(%ebp),%eax
8010acb2:	83 ec 04             	sub    $0x4,%esp
8010acb5:	ff 75 f4             	pushl  -0xc(%ebp)
8010acb8:	68 1e ce 10 80       	push   $0x8010ce1e
8010acbd:	50                   	push   %eax
8010acbe:	e8 4b 00 00 00       	call   8010ad0e <http_strcpy>
8010acc3:	83 c4 10             	add    $0x10,%esp
8010acc6:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010acc9:	8b 45 10             	mov    0x10(%ebp),%eax
8010accc:	83 ec 04             	sub    $0x4,%esp
8010accf:	ff 75 f4             	pushl  -0xc(%ebp)
8010acd2:	68 39 ce 10 80       	push   $0x8010ce39
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
