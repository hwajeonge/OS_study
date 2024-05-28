
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
8010005f:	ba a6 39 10 80       	mov    $0x801039a6,%edx
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
80100073:	68 c0 ac 10 80       	push   $0x8010acc0
80100078:	68 a0 13 11 80       	push   $0x801113a0
8010007d:	e8 70 51 00 00       	call   801051f2 <initlock>
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
801000c1:	68 c7 ac 10 80       	push   $0x8010acc7
801000c6:	50                   	push   %eax
801000c7:	e8 b9 4f 00 00       	call   80105085 <initsleeplock>
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
80100109:	e8 0a 51 00 00       	call   80105218 <acquire>
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
80100148:	e8 3d 51 00 00       	call   8010528a <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 66 4f 00 00       	call   801050c5 <acquiresleep>
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
801001c9:	e8 bc 50 00 00       	call   8010528a <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 e5 4e 00 00       	call   801050c5 <acquiresleep>
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
801001fd:	68 ce ac 10 80       	push   $0x8010acce
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
80100239:	e8 cf 27 00 00       	call   80102a0d <iderw>
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
8010025a:	e8 20 4f 00 00       	call   8010517f <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 df ac 10 80       	push   $0x8010acdf
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
80100288:	e8 80 27 00 00       	call   80102a0d <iderw>
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
801002a7:	e8 d3 4e 00 00       	call   8010517f <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 e6 ac 10 80       	push   $0x8010ace6
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 5e 4e 00 00       	call   8010512d <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 a0 13 11 80       	push   $0x801113a0
801002da:	e8 39 4f 00 00       	call   80105218 <acquire>
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
8010034a:	e8 3b 4f 00 00       	call   8010528a <release>
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
8010042c:	e8 e7 4d 00 00       	call   80105218 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 ed ac 10 80       	push   $0x8010aced
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
8010052c:	c7 45 ec f6 ac 10 80 	movl   $0x8010acf6,-0x14(%ebp)
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
801005ba:	e8 cb 4c 00 00       	call   8010528a <release>
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
801005de:	e8 14 2b 00 00       	call   801030f7 <lapicid>
801005e3:	83 ec 08             	sub    $0x8,%esp
801005e6:	50                   	push   %eax
801005e7:	68 fd ac 10 80       	push   $0x8010acfd
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
80100606:	68 11 ad 10 80       	push   $0x8010ad11
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 bd 4c 00 00       	call   801052e0 <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 13 ad 10 80       	push   $0x8010ad13
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
801006c4:	e8 99 84 00 00       	call   80108b62 <graphic_scroll_up>
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
80100717:	e8 46 84 00 00       	call   80108b62 <graphic_scroll_up>
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
8010077d:	e8 54 84 00 00       	call   80108bd6 <font_render>
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
801007bd:	e8 b4 67 00 00       	call   80106f76 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 a7 67 00 00       	call   80106f76 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 9a 67 00 00       	call   80106f76 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 8a 67 00 00       	call   80106f76 <uartputc>
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
80100819:	e8 fa 49 00 00       	call   80105218 <acquire>
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
8010096f:	e8 b6 43 00 00       	call   80104d2a <wakeup>
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
80100992:	e8 f3 48 00 00       	call   8010528a <release>
80100997:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010099a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010099e:	74 05                	je     801009a5 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009a0:	e8 4b 44 00 00       	call   80104df0 <procdump>
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
801009c9:	68 20 00 11 80       	push   $0x80110020
801009ce:	e8 45 48 00 00       	call   80105218 <acquire>
801009d3:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009d6:	e9 ab 00 00 00       	jmp    80100a86 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
801009db:	e8 c1 36 00 00       	call   801040a1 <myproc>
801009e0:	8b 40 24             	mov    0x24(%eax),%eax
801009e3:	85 c0                	test   %eax,%eax
801009e5:	74 28                	je     80100a0f <consoleread+0x67>
        release(&cons.lock);
801009e7:	83 ec 0c             	sub    $0xc,%esp
801009ea:	68 20 00 11 80       	push   $0x80110020
801009ef:	e8 96 48 00 00       	call   8010528a <release>
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
80100a12:	68 20 00 11 80       	push   $0x80110020
80100a17:	68 80 5d 11 80       	push   $0x80115d80
80100a1c:	e8 17 42 00 00       	call   80104c38 <sleep>
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
80100a9a:	e8 eb 47 00 00       	call   8010528a <release>
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
80100ad7:	68 20 00 11 80       	push   $0x80110020
80100adc:	e8 37 47 00 00       	call   80105218 <acquire>
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
80100b1e:	e8 67 47 00 00       	call   8010528a <release>
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
80100b43:	c7 05 00 00 11 80 00 	movl   $0x0,0x80110000
80100b4a:	00 00 00 
  initlock(&cons.lock, "console");
80100b4d:	83 ec 08             	sub    $0x8,%esp
80100b50:	68 17 ad 10 80       	push   $0x8010ad17
80100b55:	68 20 00 11 80       	push   $0x80110020
80100b5a:	e8 93 46 00 00       	call   801051f2 <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 4c 67 11 80 bc 	movl   $0x80100abc,0x8011674c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 48 67 11 80 a8 	movl   $0x801009a8,0x80116748
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 1f ad 10 80 	movl   $0x8010ad1f,-0xc(%ebp)
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
80100bb3:	e8 4c 20 00 00       	call   80102c04 <ioapicenable>
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
80100bcb:	e8 d1 34 00 00       	call   801040a1 <myproc>
80100bd0:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bd3:	e8 91 2a 00 00       	call   80103669 <begin_op>

  if((ip = namei(path)) == 0){
80100bd8:	83 ec 0c             	sub    $0xc,%esp
80100bdb:	ff 75 08             	pushl  0x8(%ebp)
80100bde:	e8 04 1a 00 00       	call   801025e7 <namei>
80100be3:	83 c4 10             	add    $0x10,%esp
80100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100be9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bed:	75 1f                	jne    80100c0e <exec+0x50>
    end_op();
80100bef:	e8 05 2b 00 00       	call   801036f9 <end_op>
    cprintf("exec: fail\n");
80100bf4:	83 ec 0c             	sub    $0xc,%esp
80100bf7:	68 35 ad 10 80       	push   $0x8010ad35
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
80100c53:	e8 32 73 00 00       	call   80107f8a <setupkvm>
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
80100cf9:	e8 9e 76 00 00       	call   8010839c <allocuvm>
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
80100d3f:	e8 87 75 00 00       	call   801082cb <loaduvm>
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
80100d80:	e8 74 29 00 00       	call   801036f9 <end_op>
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
80100dae:	e8 e9 75 00 00       	call   8010839c <allocuvm>
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
80100dd2:	e8 33 78 00 00       	call   8010860a <clearpteu>
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
80100e0b:	e8 00 49 00 00       	call   80105710 <strlen>
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
80100e38:	e8 d3 48 00 00       	call   80105710 <strlen>
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
80100e5e:	e8 52 79 00 00       	call   801087b5 <copyout>
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
80100efa:	e8 b6 78 00 00       	call   801087b5 <copyout>
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
80100f48:	e8 75 47 00 00       	call   801056c2 <safestrcpy>
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
80100f8b:	e8 24 71 00 00       	call   801080b4 <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	pushl  -0x34(%ebp)
80100f99:	e8 cf 75 00 00       	call   8010856d <freevm>
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
80100fd9:	e8 8f 75 00 00       	call   8010856d <freevm>
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
80100ff5:	e8 ff 26 00 00       	call   801036f9 <end_op>
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
8010100e:	68 41 ad 10 80       	push   $0x8010ad41
80101013:	68 a0 5d 11 80       	push   $0x80115da0
80101018:	e8 d5 41 00 00       	call   801051f2 <initlock>
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
80101030:	68 a0 5d 11 80       	push   $0x80115da0
80101035:	e8 de 41 00 00       	call   80105218 <acquire>
8010103a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103d:	c7 45 f4 d4 5d 11 80 	movl   $0x80115dd4,-0xc(%ebp)
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
8010105d:	68 a0 5d 11 80       	push   $0x80115da0
80101062:	e8 23 42 00 00       	call   8010528a <release>
80101067:	83 c4 10             	add    $0x10,%esp
      return f;
8010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106d:	eb 23                	jmp    80101092 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101073:	b8 34 67 11 80       	mov    $0x80116734,%eax
80101078:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107b:	72 c9                	jb     80101046 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 a0 5d 11 80       	push   $0x80115da0
80101085:	e8 00 42 00 00       	call   8010528a <release>
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
801010a1:	68 a0 5d 11 80       	push   $0x80115da0
801010a6:	e8 6d 41 00 00       	call   80105218 <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 48 ad 10 80       	push   $0x8010ad48
801010c0:	e8 00 f5 ff ff       	call   801005c5 <panic>
  f->ref++;
801010c5:	8b 45 08             	mov    0x8(%ebp),%eax
801010c8:	8b 40 04             	mov    0x4(%eax),%eax
801010cb:	8d 50 01             	lea    0x1(%eax),%edx
801010ce:	8b 45 08             	mov    0x8(%ebp),%eax
801010d1:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d4:	83 ec 0c             	sub    $0xc,%esp
801010d7:	68 a0 5d 11 80       	push   $0x80115da0
801010dc:	e8 a9 41 00 00       	call   8010528a <release>
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
801010f6:	68 a0 5d 11 80       	push   $0x80115da0
801010fb:	e8 18 41 00 00       	call   80105218 <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 50 ad 10 80       	push   $0x8010ad50
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
80101136:	68 a0 5d 11 80       	push   $0x80115da0
8010113b:	e8 4a 41 00 00       	call   8010528a <release>
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
80101184:	68 a0 5d 11 80       	push   $0x80115da0
80101189:	e8 fc 40 00 00       	call   8010528a <release>
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
801011a8:	e8 6b 2b 00 00       	call   80103d18 <pipeclose>
801011ad:	83 c4 10             	add    $0x10,%esp
801011b0:	eb 21                	jmp    801011d3 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011b5:	83 f8 02             	cmp    $0x2,%eax
801011b8:	75 19                	jne    801011d3 <fileclose+0xea>
    begin_op();
801011ba:	e8 aa 24 00 00       	call   80103669 <begin_op>
    iput(ff.ip);
801011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011c2:	83 ec 0c             	sub    $0xc,%esp
801011c5:	50                   	push   %eax
801011c6:	e8 1a 0a 00 00       	call   80101be5 <iput>
801011cb:	83 c4 10             	add    $0x10,%esp
    end_op();
801011ce:	e8 26 25 00 00       	call   801036f9 <end_op>
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
80101269:	e8 5f 2c 00 00       	call   80103ecd <piperead>
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
801012e0:	68 5a ad 10 80       	push   $0x8010ad5a
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
80101326:	e8 9c 2a 00 00       	call   80103dc7 <pipewrite>
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
8010136b:	e8 f9 22 00 00       	call   80103669 <begin_op>
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
801013d1:	e8 23 23 00 00       	call   801036f9 <end_op>

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
801013e7:	68 63 ad 10 80       	push   $0x8010ad63
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
8010141d:	68 73 ad 10 80       	push   $0x8010ad73
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
80101459:	e8 10 41 00 00       	call   8010556e <memmove>
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
801014a3:	e8 ff 3f 00 00       	call   801054a7 <memset>
801014a8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014ab:	83 ec 0c             	sub    $0xc,%esp
801014ae:	ff 75 f4             	pushl  -0xc(%ebp)
801014b1:	e8 fc 23 00 00       	call   801038b2 <log_write>
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
801014fa:	a1 b8 67 11 80       	mov    0x801167b8,%eax
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
80101589:	e8 24 23 00 00       	call   801038b2 <log_write>
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
801015d8:	a1 a0 67 11 80       	mov    0x801167a0,%eax
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
801015fa:	8b 15 a0 67 11 80    	mov    0x801167a0,%edx
80101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101603:	39 c2                	cmp    %eax,%edx
80101605:	0f 87 dc fe ff ff    	ja     801014e7 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010160b:	83 ec 0c             	sub    $0xc,%esp
8010160e:	68 80 ad 10 80       	push   $0x8010ad80
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
80101627:	68 a0 67 11 80       	push   $0x801167a0
8010162c:	ff 75 08             	pushl  0x8(%ebp)
8010162f:	e8 f8 fd ff ff       	call   8010142c <readsb>
80101634:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010163a:	c1 e8 0c             	shr    $0xc,%eax
8010163d:	89 c2                	mov    %eax,%edx
8010163f:	a1 b8 67 11 80       	mov    0x801167b8,%eax
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
801016a5:	68 96 ad 10 80       	push   $0x8010ad96
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
801016dd:	e8 d0 21 00 00       	call   801038b2 <log_write>
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
8010170d:	68 a9 ad 10 80       	push   $0x8010ada9
80101712:	68 c0 67 11 80       	push   $0x801167c0
80101717:	e8 d6 3a 00 00       	call   801051f2 <initlock>
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
80101738:	05 c0 67 11 80       	add    $0x801167c0,%eax
8010173d:	83 c0 10             	add    $0x10,%eax
80101740:	83 ec 08             	sub    $0x8,%esp
80101743:	68 b0 ad 10 80       	push   $0x8010adb0
80101748:	50                   	push   %eax
80101749:	e8 37 39 00 00       	call   80105085 <initsleeplock>
8010174e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101751:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101755:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101759:	7e cd                	jle    80101728 <iinit+0x32>
  }

  readsb(dev, &sb);
8010175b:	83 ec 08             	sub    $0x8,%esp
8010175e:	68 a0 67 11 80       	push   $0x801167a0
80101763:	ff 75 08             	pushl  0x8(%ebp)
80101766:	e8 c1 fc ff ff       	call   8010142c <readsb>
8010176b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010176e:	a1 b8 67 11 80       	mov    0x801167b8,%eax
80101773:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101776:	8b 3d b4 67 11 80    	mov    0x801167b4,%edi
8010177c:	8b 35 b0 67 11 80    	mov    0x801167b0,%esi
80101782:	8b 1d ac 67 11 80    	mov    0x801167ac,%ebx
80101788:	8b 0d a8 67 11 80    	mov    0x801167a8,%ecx
8010178e:	8b 15 a4 67 11 80    	mov    0x801167a4,%edx
80101794:	a1 a0 67 11 80       	mov    0x801167a0,%eax
80101799:	ff 75 d4             	pushl  -0x2c(%ebp)
8010179c:	57                   	push   %edi
8010179d:	56                   	push   %esi
8010179e:	53                   	push   %ebx
8010179f:	51                   	push   %ecx
801017a0:	52                   	push   %edx
801017a1:	50                   	push   %eax
801017a2:	68 b8 ad 10 80       	push   $0x8010adb8
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
801017dd:	a1 b4 67 11 80       	mov    0x801167b4,%eax
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
8010181f:	e8 83 3c 00 00       	call   801054a7 <memset>
80101824:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101827:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010182a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010182e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101831:	83 ec 0c             	sub    $0xc,%esp
80101834:	ff 75 f0             	pushl  -0x10(%ebp)
80101837:	e8 76 20 00 00       	call   801038b2 <log_write>
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
80101873:	8b 15 a8 67 11 80    	mov    0x801167a8,%edx
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	39 c2                	cmp    %eax,%edx
8010187e:	0f 87 51 ff ff ff    	ja     801017d5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 0b ae 10 80       	push   $0x8010ae0b
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
801018a8:	a1 b4 67 11 80       	mov    0x801167b4,%eax
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
80101931:	e8 38 3c 00 00       	call   8010556e <memmove>
80101936:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	ff 75 f4             	pushl  -0xc(%ebp)
8010193f:	e8 6e 1f 00 00       	call   801038b2 <log_write>
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
80101965:	68 c0 67 11 80       	push   $0x801167c0
8010196a:	e8 a9 38 00 00       	call   80105218 <acquire>
8010196f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101972:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101979:	c7 45 f4 f4 67 11 80 	movl   $0x801167f4,-0xc(%ebp)
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
801019b3:	68 c0 67 11 80       	push   $0x801167c0
801019b8:	e8 cd 38 00 00       	call   8010528a <release>
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
801019e2:	81 7d f4 14 84 11 80 	cmpl   $0x80118414,-0xc(%ebp)
801019e9:	72 97                	jb     80101982 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019ef:	75 0d                	jne    801019fe <iget+0xa6>
    panic("iget: no inodes");
801019f1:	83 ec 0c             	sub    $0xc,%esp
801019f4:	68 1d ae 10 80       	push   $0x8010ae1d
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
80101a2c:	68 c0 67 11 80       	push   $0x801167c0
80101a31:	e8 54 38 00 00       	call   8010528a <release>
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
80101a4b:	68 c0 67 11 80       	push   $0x801167c0
80101a50:	e8 c3 37 00 00       	call   80105218 <acquire>
80101a55:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	8b 40 08             	mov    0x8(%eax),%eax
80101a5e:	8d 50 01             	lea    0x1(%eax),%edx
80101a61:	8b 45 08             	mov    0x8(%ebp),%eax
80101a64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a67:	83 ec 0c             	sub    $0xc,%esp
80101a6a:	68 c0 67 11 80       	push   $0x801167c0
80101a6f:	e8 16 38 00 00       	call   8010528a <release>
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
80101a99:	68 2d ae 10 80       	push   $0x8010ae2d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 13 36 00 00       	call   801050c5 <acquiresleep>
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
80101ace:	a1 b4 67 11 80       	mov    0x801167b4,%eax
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
80101b57:	e8 12 3a 00 00       	call   8010556e <memmove>
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
80101b86:	68 33 ae 10 80       	push   $0x8010ae33
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
80101bad:	e8 cd 35 00 00       	call   8010517f <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 42 ae 10 80       	push   $0x8010ae42
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 4e 35 00 00       	call   8010512d <releasesleep>
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
80101bf9:	e8 c7 34 00 00       	call   801050c5 <acquiresleep>
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
80101c1a:	68 c0 67 11 80       	push   $0x801167c0
80101c1f:	e8 f4 35 00 00       	call   80105218 <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 c0 67 11 80       	push   $0x801167c0
80101c38:	e8 4d 36 00 00       	call   8010528a <release>
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
80101c7f:	e8 a9 34 00 00       	call   8010512d <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 c0 67 11 80       	push   $0x801167c0
80101c8f:	e8 84 35 00 00       	call   80105218 <acquire>
80101c94:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 40 08             	mov    0x8(%eax),%eax
80101c9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ca6:	83 ec 0c             	sub    $0xc,%esp
80101ca9:	68 c0 67 11 80       	push   $0x801167c0
80101cae:	e8 d7 35 00 00       	call   8010528a <release>
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
80101ddc:	e8 d1 1a 00 00       	call   801038b2 <log_write>
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
80101dfa:	68 4a ae 10 80       	push   $0x8010ae4a
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
80101fbc:	8b 04 c5 40 67 11 80 	mov    -0x7fee98c0(,%eax,8),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	75 0a                	jne    80101fd1 <readi+0x4d>
      return -1;
80101fc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fcc:	e9 0a 01 00 00       	jmp    801020db <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fd8:	98                   	cwtl   
80101fd9:	8b 04 c5 40 67 11 80 	mov    -0x7fee98c0(,%eax,8),%eax
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
801020a4:	e8 c5 34 00 00       	call   8010556e <memmove>
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
80102115:	8b 04 c5 44 67 11 80 	mov    -0x7fee98bc(,%eax,8),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	75 0a                	jne    8010212a <writei+0x4d>
      return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 3b 01 00 00       	jmp    80102265 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102131:	98                   	cwtl   
80102132:	8b 04 c5 44 67 11 80 	mov    -0x7fee98bc(,%eax,8),%eax
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
801021f8:	e8 71 33 00 00       	call   8010556e <memmove>
801021fd:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102200:	83 ec 0c             	sub    $0xc,%esp
80102203:	ff 75 f0             	pushl  -0x10(%ebp)
80102206:	e8 a7 16 00 00       	call   801038b2 <log_write>
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
8010227c:	e8 8b 33 00 00       	call   8010560c <strncmp>
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
801022a0:	68 5d ae 10 80       	push   $0x8010ae5d
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
801022cf:	68 6f ae 10 80       	push   $0x8010ae6f
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
801023a8:	68 7e ae 10 80       	push   $0x8010ae7e
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
801023e3:	e8 7e 32 00 00       	call   80105666 <strncpy>
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
8010240f:	68 8b ae 10 80       	push   $0x8010ae8b
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
80102485:	e8 e4 30 00 00       	call   8010556e <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	ff 75 0c             	pushl  0xc(%ebp)
8010249c:	e8 cd 30 00 00       	call   8010556e <memmove>
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
801024ef:	e8 ad 1b 00 00       	call   801040a1 <myproc>
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

80102626 <inb>:
{
80102626:	55                   	push   %ebp
80102627:	89 e5                	mov    %esp,%ebp
80102629:	83 ec 14             	sub    $0x14,%esp
8010262c:	8b 45 08             	mov    0x8(%ebp),%eax
8010262f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102633:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102637:	89 c2                	mov    %eax,%edx
80102639:	ec                   	in     (%dx),%al
8010263a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010263d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102641:	c9                   	leave  
80102642:	c3                   	ret    

80102643 <insl>:
{
80102643:	55                   	push   %ebp
80102644:	89 e5                	mov    %esp,%ebp
80102646:	57                   	push   %edi
80102647:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102648:	8b 55 08             	mov    0x8(%ebp),%edx
8010264b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010264e:	8b 45 10             	mov    0x10(%ebp),%eax
80102651:	89 cb                	mov    %ecx,%ebx
80102653:	89 df                	mov    %ebx,%edi
80102655:	89 c1                	mov    %eax,%ecx
80102657:	fc                   	cld    
80102658:	f3 6d                	rep insl (%dx),%es:(%edi)
8010265a:	89 c8                	mov    %ecx,%eax
8010265c:	89 fb                	mov    %edi,%ebx
8010265e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102661:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102664:	90                   	nop
80102665:	5b                   	pop    %ebx
80102666:	5f                   	pop    %edi
80102667:	5d                   	pop    %ebp
80102668:	c3                   	ret    

80102669 <outb>:
{
80102669:	55                   	push   %ebp
8010266a:	89 e5                	mov    %esp,%ebp
8010266c:	83 ec 08             	sub    $0x8,%esp
8010266f:	8b 45 08             	mov    0x8(%ebp),%eax
80102672:	8b 55 0c             	mov    0xc(%ebp),%edx
80102675:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102679:	89 d0                	mov    %edx,%eax
8010267b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010267e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102682:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102686:	ee                   	out    %al,(%dx)
}
80102687:	90                   	nop
80102688:	c9                   	leave  
80102689:	c3                   	ret    

8010268a <outsl>:
{
8010268a:	55                   	push   %ebp
8010268b:	89 e5                	mov    %esp,%ebp
8010268d:	56                   	push   %esi
8010268e:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010268f:	8b 55 08             	mov    0x8(%ebp),%edx
80102692:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102695:	8b 45 10             	mov    0x10(%ebp),%eax
80102698:	89 cb                	mov    %ecx,%ebx
8010269a:	89 de                	mov    %ebx,%esi
8010269c:	89 c1                	mov    %eax,%ecx
8010269e:	fc                   	cld    
8010269f:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801026a1:	89 c8                	mov    %ecx,%eax
801026a3:	89 f3                	mov    %esi,%ebx
801026a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026a8:	89 45 10             	mov    %eax,0x10(%ebp)
}
801026ab:	90                   	nop
801026ac:	5b                   	pop    %ebx
801026ad:	5e                   	pop    %esi
801026ae:	5d                   	pop    %ebp
801026af:	c3                   	ret    

801026b0 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801026b0:	f3 0f 1e fb          	endbr32 
801026b4:	55                   	push   %ebp
801026b5:	89 e5                	mov    %esp,%ebp
801026b7:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801026ba:	90                   	nop
801026bb:	68 f7 01 00 00       	push   $0x1f7
801026c0:	e8 61 ff ff ff       	call   80102626 <inb>
801026c5:	83 c4 04             	add    $0x4,%esp
801026c8:	0f b6 c0             	movzbl %al,%eax
801026cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026d1:	25 c0 00 00 00       	and    $0xc0,%eax
801026d6:	83 f8 40             	cmp    $0x40,%eax
801026d9:	75 e0                	jne    801026bb <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026df:	74 11                	je     801026f2 <idewait+0x42>
801026e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026e4:	83 e0 21             	and    $0x21,%eax
801026e7:	85 c0                	test   %eax,%eax
801026e9:	74 07                	je     801026f2 <idewait+0x42>
    return -1;
801026eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026f0:	eb 05                	jmp    801026f7 <idewait+0x47>
  return 0;
801026f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026f7:	c9                   	leave  
801026f8:	c3                   	ret    

801026f9 <ideinit>:

void
ideinit(void)
{
801026f9:	f3 0f 1e fb          	endbr32 
801026fd:	55                   	push   %ebp
801026fe:	89 e5                	mov    %esp,%ebp
80102700:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102703:	83 ec 08             	sub    $0x8,%esp
80102706:	68 93 ae 10 80       	push   $0x8010ae93
8010270b:	68 60 00 11 80       	push   $0x80110060
80102710:	e8 dd 2a 00 00       	call   801051f2 <initlock>
80102715:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102718:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
8010271d:	83 e8 01             	sub    $0x1,%eax
80102720:	83 ec 08             	sub    $0x8,%esp
80102723:	50                   	push   %eax
80102724:	6a 0e                	push   $0xe
80102726:	e8 d9 04 00 00       	call   80102c04 <ioapicenable>
8010272b:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010272e:	83 ec 0c             	sub    $0xc,%esp
80102731:	6a 00                	push   $0x0
80102733:	e8 78 ff ff ff       	call   801026b0 <idewait>
80102738:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010273b:	83 ec 08             	sub    $0x8,%esp
8010273e:	68 f0 00 00 00       	push   $0xf0
80102743:	68 f6 01 00 00       	push   $0x1f6
80102748:	e8 1c ff ff ff       	call   80102669 <outb>
8010274d:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102750:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102757:	eb 24                	jmp    8010277d <ideinit+0x84>
    if(inb(0x1f7) != 0){
80102759:	83 ec 0c             	sub    $0xc,%esp
8010275c:	68 f7 01 00 00       	push   $0x1f7
80102761:	e8 c0 fe ff ff       	call   80102626 <inb>
80102766:	83 c4 10             	add    $0x10,%esp
80102769:	84 c0                	test   %al,%al
8010276b:	74 0c                	je     80102779 <ideinit+0x80>
      havedisk1 = 1;
8010276d:	c7 05 98 00 11 80 01 	movl   $0x1,0x80110098
80102774:	00 00 00 
      break;
80102777:	eb 0d                	jmp    80102786 <ideinit+0x8d>
  for(i=0; i<1000; i++){
80102779:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010277d:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102784:	7e d3                	jle    80102759 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102786:	83 ec 08             	sub    $0x8,%esp
80102789:	68 e0 00 00 00       	push   $0xe0
8010278e:	68 f6 01 00 00       	push   $0x1f6
80102793:	e8 d1 fe ff ff       	call   80102669 <outb>
80102798:	83 c4 10             	add    $0x10,%esp
}
8010279b:	90                   	nop
8010279c:	c9                   	leave  
8010279d:	c3                   	ret    

8010279e <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010279e:	f3 0f 1e fb          	endbr32 
801027a2:	55                   	push   %ebp
801027a3:	89 e5                	mov    %esp,%ebp
801027a5:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801027a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027ac:	75 0d                	jne    801027bb <idestart+0x1d>
    panic("idestart");
801027ae:	83 ec 0c             	sub    $0xc,%esp
801027b1:	68 97 ae 10 80       	push   $0x8010ae97
801027b6:	e8 0a de ff ff       	call   801005c5 <panic>
  if(b->blockno >= FSSIZE)
801027bb:	8b 45 08             	mov    0x8(%ebp),%eax
801027be:	8b 40 08             	mov    0x8(%eax),%eax
801027c1:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801027c6:	76 0d                	jbe    801027d5 <idestart+0x37>
    panic("incorrect blockno");
801027c8:	83 ec 0c             	sub    $0xc,%esp
801027cb:	68 a0 ae 10 80       	push   $0x8010aea0
801027d0:	e8 f0 dd ff ff       	call   801005c5 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027d5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027dc:	8b 45 08             	mov    0x8(%ebp),%eax
801027df:	8b 50 08             	mov    0x8(%eax),%edx
801027e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e5:	0f af c2             	imul   %edx,%eax
801027e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801027eb:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801027ef:	75 07                	jne    801027f8 <idestart+0x5a>
801027f1:	b8 20 00 00 00       	mov    $0x20,%eax
801027f6:	eb 05                	jmp    801027fd <idestart+0x5f>
801027f8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801027fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102800:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102804:	75 07                	jne    8010280d <idestart+0x6f>
80102806:	b8 30 00 00 00       	mov    $0x30,%eax
8010280b:	eb 05                	jmp    80102812 <idestart+0x74>
8010280d:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102812:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102815:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102819:	7e 0d                	jle    80102828 <idestart+0x8a>
8010281b:	83 ec 0c             	sub    $0xc,%esp
8010281e:	68 97 ae 10 80       	push   $0x8010ae97
80102823:	e8 9d dd ff ff       	call   801005c5 <panic>

  idewait(0);
80102828:	83 ec 0c             	sub    $0xc,%esp
8010282b:	6a 00                	push   $0x0
8010282d:	e8 7e fe ff ff       	call   801026b0 <idewait>
80102832:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102835:	83 ec 08             	sub    $0x8,%esp
80102838:	6a 00                	push   $0x0
8010283a:	68 f6 03 00 00       	push   $0x3f6
8010283f:	e8 25 fe ff ff       	call   80102669 <outb>
80102844:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010284a:	0f b6 c0             	movzbl %al,%eax
8010284d:	83 ec 08             	sub    $0x8,%esp
80102850:	50                   	push   %eax
80102851:	68 f2 01 00 00       	push   $0x1f2
80102856:	e8 0e fe ff ff       	call   80102669 <outb>
8010285b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010285e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102861:	0f b6 c0             	movzbl %al,%eax
80102864:	83 ec 08             	sub    $0x8,%esp
80102867:	50                   	push   %eax
80102868:	68 f3 01 00 00       	push   $0x1f3
8010286d:	e8 f7 fd ff ff       	call   80102669 <outb>
80102872:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102875:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102878:	c1 f8 08             	sar    $0x8,%eax
8010287b:	0f b6 c0             	movzbl %al,%eax
8010287e:	83 ec 08             	sub    $0x8,%esp
80102881:	50                   	push   %eax
80102882:	68 f4 01 00 00       	push   $0x1f4
80102887:	e8 dd fd ff ff       	call   80102669 <outb>
8010288c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010288f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102892:	c1 f8 10             	sar    $0x10,%eax
80102895:	0f b6 c0             	movzbl %al,%eax
80102898:	83 ec 08             	sub    $0x8,%esp
8010289b:	50                   	push   %eax
8010289c:	68 f5 01 00 00       	push   $0x1f5
801028a1:	e8 c3 fd ff ff       	call   80102669 <outb>
801028a6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801028a9:	8b 45 08             	mov    0x8(%ebp),%eax
801028ac:	8b 40 04             	mov    0x4(%eax),%eax
801028af:	c1 e0 04             	shl    $0x4,%eax
801028b2:	83 e0 10             	and    $0x10,%eax
801028b5:	89 c2                	mov    %eax,%edx
801028b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ba:	c1 f8 18             	sar    $0x18,%eax
801028bd:	83 e0 0f             	and    $0xf,%eax
801028c0:	09 d0                	or     %edx,%eax
801028c2:	83 c8 e0             	or     $0xffffffe0,%eax
801028c5:	0f b6 c0             	movzbl %al,%eax
801028c8:	83 ec 08             	sub    $0x8,%esp
801028cb:	50                   	push   %eax
801028cc:	68 f6 01 00 00       	push   $0x1f6
801028d1:	e8 93 fd ff ff       	call   80102669 <outb>
801028d6:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801028d9:	8b 45 08             	mov    0x8(%ebp),%eax
801028dc:	8b 00                	mov    (%eax),%eax
801028de:	83 e0 04             	and    $0x4,%eax
801028e1:	85 c0                	test   %eax,%eax
801028e3:	74 35                	je     8010291a <idestart+0x17c>
    outb(0x1f7, write_cmd);
801028e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028e8:	0f b6 c0             	movzbl %al,%eax
801028eb:	83 ec 08             	sub    $0x8,%esp
801028ee:	50                   	push   %eax
801028ef:	68 f7 01 00 00       	push   $0x1f7
801028f4:	e8 70 fd ff ff       	call   80102669 <outb>
801028f9:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028fc:	8b 45 08             	mov    0x8(%ebp),%eax
801028ff:	83 c0 5c             	add    $0x5c,%eax
80102902:	83 ec 04             	sub    $0x4,%esp
80102905:	68 80 00 00 00       	push   $0x80
8010290a:	50                   	push   %eax
8010290b:	68 f0 01 00 00       	push   $0x1f0
80102910:	e8 75 fd ff ff       	call   8010268a <outsl>
80102915:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102918:	eb 17                	jmp    80102931 <idestart+0x193>
    outb(0x1f7, read_cmd);
8010291a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010291d:	0f b6 c0             	movzbl %al,%eax
80102920:	83 ec 08             	sub    $0x8,%esp
80102923:	50                   	push   %eax
80102924:	68 f7 01 00 00       	push   $0x1f7
80102929:	e8 3b fd ff ff       	call   80102669 <outb>
8010292e:	83 c4 10             	add    $0x10,%esp
}
80102931:	90                   	nop
80102932:	c9                   	leave  
80102933:	c3                   	ret    

80102934 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102934:	f3 0f 1e fb          	endbr32 
80102938:	55                   	push   %ebp
80102939:	89 e5                	mov    %esp,%ebp
8010293b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010293e:	83 ec 0c             	sub    $0xc,%esp
80102941:	68 60 00 11 80       	push   $0x80110060
80102946:	e8 cd 28 00 00       	call   80105218 <acquire>
8010294b:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010294e:	a1 94 00 11 80       	mov    0x80110094,%eax
80102953:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102956:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010295a:	75 15                	jne    80102971 <ideintr+0x3d>
    release(&idelock);
8010295c:	83 ec 0c             	sub    $0xc,%esp
8010295f:	68 60 00 11 80       	push   $0x80110060
80102964:	e8 21 29 00 00       	call   8010528a <release>
80102969:	83 c4 10             	add    $0x10,%esp
    return;
8010296c:	e9 9a 00 00 00       	jmp    80102a0b <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102974:	8b 40 58             	mov    0x58(%eax),%eax
80102977:	a3 94 00 11 80       	mov    %eax,0x80110094

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010297c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010297f:	8b 00                	mov    (%eax),%eax
80102981:	83 e0 04             	and    $0x4,%eax
80102984:	85 c0                	test   %eax,%eax
80102986:	75 2d                	jne    801029b5 <ideintr+0x81>
80102988:	83 ec 0c             	sub    $0xc,%esp
8010298b:	6a 01                	push   $0x1
8010298d:	e8 1e fd ff ff       	call   801026b0 <idewait>
80102992:	83 c4 10             	add    $0x10,%esp
80102995:	85 c0                	test   %eax,%eax
80102997:	78 1c                	js     801029b5 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299c:	83 c0 5c             	add    $0x5c,%eax
8010299f:	83 ec 04             	sub    $0x4,%esp
801029a2:	68 80 00 00 00       	push   $0x80
801029a7:	50                   	push   %eax
801029a8:	68 f0 01 00 00       	push   $0x1f0
801029ad:	e8 91 fc ff ff       	call   80102643 <insl>
801029b2:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801029b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b8:	8b 00                	mov    (%eax),%eax
801029ba:	83 c8 02             	or     $0x2,%eax
801029bd:	89 c2                	mov    %eax,%edx
801029bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c2:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c7:	8b 00                	mov    (%eax),%eax
801029c9:	83 e0 fb             	and    $0xfffffffb,%eax
801029cc:	89 c2                	mov    %eax,%edx
801029ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029d3:	83 ec 0c             	sub    $0xc,%esp
801029d6:	ff 75 f4             	pushl  -0xc(%ebp)
801029d9:	e8 4c 23 00 00       	call   80104d2a <wakeup>
801029de:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
801029e1:	a1 94 00 11 80       	mov    0x80110094,%eax
801029e6:	85 c0                	test   %eax,%eax
801029e8:	74 11                	je     801029fb <ideintr+0xc7>
    idestart(idequeue);
801029ea:	a1 94 00 11 80       	mov    0x80110094,%eax
801029ef:	83 ec 0c             	sub    $0xc,%esp
801029f2:	50                   	push   %eax
801029f3:	e8 a6 fd ff ff       	call   8010279e <idestart>
801029f8:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801029fb:	83 ec 0c             	sub    $0xc,%esp
801029fe:	68 60 00 11 80       	push   $0x80110060
80102a03:	e8 82 28 00 00       	call   8010528a <release>
80102a08:	83 c4 10             	add    $0x10,%esp
}
80102a0b:	c9                   	leave  
80102a0c:	c3                   	ret    

80102a0d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a0d:	f3 0f 1e fb          	endbr32 
80102a11:	55                   	push   %ebp
80102a12:	89 e5                	mov    %esp,%ebp
80102a14:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102a17:	8b 15 98 00 11 80    	mov    0x80110098,%edx
80102a1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a20:	8b 40 04             	mov    0x4(%eax),%eax
80102a23:	83 ec 04             	sub    $0x4,%esp
80102a26:	52                   	push   %edx
80102a27:	50                   	push   %eax
80102a28:	68 b2 ae 10 80       	push   $0x8010aeb2
80102a2d:	e8 da d9 ff ff       	call   8010040c <cprintf>
80102a32:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
80102a35:	8b 45 08             	mov    0x8(%ebp),%eax
80102a38:	83 c0 0c             	add    $0xc,%eax
80102a3b:	83 ec 0c             	sub    $0xc,%esp
80102a3e:	50                   	push   %eax
80102a3f:	e8 3b 27 00 00       	call   8010517f <holdingsleep>
80102a44:	83 c4 10             	add    $0x10,%esp
80102a47:	85 c0                	test   %eax,%eax
80102a49:	75 0d                	jne    80102a58 <iderw+0x4b>
    panic("iderw: buf not locked");
80102a4b:	83 ec 0c             	sub    $0xc,%esp
80102a4e:	68 cc ae 10 80       	push   $0x8010aecc
80102a53:	e8 6d db ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a58:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5b:	8b 00                	mov    (%eax),%eax
80102a5d:	83 e0 06             	and    $0x6,%eax
80102a60:	83 f8 02             	cmp    $0x2,%eax
80102a63:	75 0d                	jne    80102a72 <iderw+0x65>
    panic("iderw: nothing to do");
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	68 e2 ae 10 80       	push   $0x8010aee2
80102a6d:	e8 53 db ff ff       	call   801005c5 <panic>
  if(b->dev != 0 && !havedisk1)
80102a72:	8b 45 08             	mov    0x8(%ebp),%eax
80102a75:	8b 40 04             	mov    0x4(%eax),%eax
80102a78:	85 c0                	test   %eax,%eax
80102a7a:	74 16                	je     80102a92 <iderw+0x85>
80102a7c:	a1 98 00 11 80       	mov    0x80110098,%eax
80102a81:	85 c0                	test   %eax,%eax
80102a83:	75 0d                	jne    80102a92 <iderw+0x85>
    panic("iderw: ide disk 1 not present");
80102a85:	83 ec 0c             	sub    $0xc,%esp
80102a88:	68 f7 ae 10 80       	push   $0x8010aef7
80102a8d:	e8 33 db ff ff       	call   801005c5 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a92:	83 ec 0c             	sub    $0xc,%esp
80102a95:	68 60 00 11 80       	push   $0x80110060
80102a9a:	e8 79 27 00 00       	call   80105218 <acquire>
80102a9f:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa5:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102aac:	c7 45 f4 94 00 11 80 	movl   $0x80110094,-0xc(%ebp)
80102ab3:	eb 0b                	jmp    80102ac0 <iderw+0xb3>
80102ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab8:	8b 00                	mov    (%eax),%eax
80102aba:	83 c0 58             	add    $0x58,%eax
80102abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac3:	8b 00                	mov    (%eax),%eax
80102ac5:	85 c0                	test   %eax,%eax
80102ac7:	75 ec                	jne    80102ab5 <iderw+0xa8>
    ;
  *pp = b;
80102ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acc:	8b 55 08             	mov    0x8(%ebp),%edx
80102acf:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102ad1:	a1 94 00 11 80       	mov    0x80110094,%eax
80102ad6:	39 45 08             	cmp    %eax,0x8(%ebp)
80102ad9:	75 23                	jne    80102afe <iderw+0xf1>
    idestart(b);
80102adb:	83 ec 0c             	sub    $0xc,%esp
80102ade:	ff 75 08             	pushl  0x8(%ebp)
80102ae1:	e8 b8 fc ff ff       	call   8010279e <idestart>
80102ae6:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102ae9:	eb 13                	jmp    80102afe <iderw+0xf1>
    sleep(b, &idelock);
80102aeb:	83 ec 08             	sub    $0x8,%esp
80102aee:	68 60 00 11 80       	push   $0x80110060
80102af3:	ff 75 08             	pushl  0x8(%ebp)
80102af6:	e8 3d 21 00 00       	call   80104c38 <sleep>
80102afb:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102afe:	8b 45 08             	mov    0x8(%ebp),%eax
80102b01:	8b 00                	mov    (%eax),%eax
80102b03:	83 e0 06             	and    $0x6,%eax
80102b06:	83 f8 02             	cmp    $0x2,%eax
80102b09:	75 e0                	jne    80102aeb <iderw+0xde>
  }


  release(&idelock);
80102b0b:	83 ec 0c             	sub    $0xc,%esp
80102b0e:	68 60 00 11 80       	push   $0x80110060
80102b13:	e8 72 27 00 00       	call   8010528a <release>
80102b18:	83 c4 10             	add    $0x10,%esp
}
80102b1b:	90                   	nop
80102b1c:	c9                   	leave  
80102b1d:	c3                   	ret    

80102b1e <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b1e:	f3 0f 1e fb          	endbr32 
80102b22:	55                   	push   %ebp
80102b23:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b25:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b2a:	8b 55 08             	mov    0x8(%ebp),%edx
80102b2d:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b2f:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b34:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b37:	5d                   	pop    %ebp
80102b38:	c3                   	ret    

80102b39 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b39:	f3 0f 1e fb          	endbr32 
80102b3d:	55                   	push   %ebp
80102b3e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b40:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b45:	8b 55 08             	mov    0x8(%ebp),%edx
80102b48:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b4a:	a1 14 84 11 80       	mov    0x80118414,%eax
80102b4f:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b52:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b55:	90                   	nop
80102b56:	5d                   	pop    %ebp
80102b57:	c3                   	ret    

80102b58 <ioapicinit>:

void
ioapicinit(void)
{
80102b58:	f3 0f 1e fb          	endbr32 
80102b5c:	55                   	push   %ebp
80102b5d:	89 e5                	mov    %esp,%ebp
80102b5f:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b62:	c7 05 14 84 11 80 00 	movl   $0xfec00000,0x80118414
80102b69:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b6c:	6a 01                	push   $0x1
80102b6e:	e8 ab ff ff ff       	call   80102b1e <ioapicread>
80102b73:	83 c4 04             	add    $0x4,%esp
80102b76:	c1 e8 10             	shr    $0x10,%eax
80102b79:	25 ff 00 00 00       	and    $0xff,%eax
80102b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b81:	6a 00                	push   $0x0
80102b83:	e8 96 ff ff ff       	call   80102b1e <ioapicread>
80102b88:	83 c4 04             	add    $0x4,%esp
80102b8b:	c1 e8 18             	shr    $0x18,%eax
80102b8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b91:	0f b6 05 e0 ae 11 80 	movzbl 0x8011aee0,%eax
80102b98:	0f b6 c0             	movzbl %al,%eax
80102b9b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102b9e:	74 10                	je     80102bb0 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102ba0:	83 ec 0c             	sub    $0xc,%esp
80102ba3:	68 18 af 10 80       	push   $0x8010af18
80102ba8:	e8 5f d8 ff ff       	call   8010040c <cprintf>
80102bad:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102bb0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102bb7:	eb 3f                	jmp    80102bf8 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bbc:	83 c0 20             	add    $0x20,%eax
80102bbf:	0d 00 00 01 00       	or     $0x10000,%eax
80102bc4:	89 c2                	mov    %eax,%edx
80102bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc9:	83 c0 08             	add    $0x8,%eax
80102bcc:	01 c0                	add    %eax,%eax
80102bce:	83 ec 08             	sub    $0x8,%esp
80102bd1:	52                   	push   %edx
80102bd2:	50                   	push   %eax
80102bd3:	e8 61 ff ff ff       	call   80102b39 <ioapicwrite>
80102bd8:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bde:	83 c0 08             	add    $0x8,%eax
80102be1:	01 c0                	add    %eax,%eax
80102be3:	83 c0 01             	add    $0x1,%eax
80102be6:	83 ec 08             	sub    $0x8,%esp
80102be9:	6a 00                	push   $0x0
80102beb:	50                   	push   %eax
80102bec:	e8 48 ff ff ff       	call   80102b39 <ioapicwrite>
80102bf1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102bf4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bfb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102bfe:	7e b9                	jle    80102bb9 <ioapicinit+0x61>
  }
}
80102c00:	90                   	nop
80102c01:	90                   	nop
80102c02:	c9                   	leave  
80102c03:	c3                   	ret    

80102c04 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c04:	f3 0f 1e fb          	endbr32 
80102c08:	55                   	push   %ebp
80102c09:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0e:	83 c0 20             	add    $0x20,%eax
80102c11:	89 c2                	mov    %eax,%edx
80102c13:	8b 45 08             	mov    0x8(%ebp),%eax
80102c16:	83 c0 08             	add    $0x8,%eax
80102c19:	01 c0                	add    %eax,%eax
80102c1b:	52                   	push   %edx
80102c1c:	50                   	push   %eax
80102c1d:	e8 17 ff ff ff       	call   80102b39 <ioapicwrite>
80102c22:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c28:	c1 e0 18             	shl    $0x18,%eax
80102c2b:	89 c2                	mov    %eax,%edx
80102c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c30:	83 c0 08             	add    $0x8,%eax
80102c33:	01 c0                	add    %eax,%eax
80102c35:	83 c0 01             	add    $0x1,%eax
80102c38:	52                   	push   %edx
80102c39:	50                   	push   %eax
80102c3a:	e8 fa fe ff ff       	call   80102b39 <ioapicwrite>
80102c3f:	83 c4 08             	add    $0x8,%esp
}
80102c42:	90                   	nop
80102c43:	c9                   	leave  
80102c44:	c3                   	ret    

80102c45 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c45:	f3 0f 1e fb          	endbr32 
80102c49:	55                   	push   %ebp
80102c4a:	89 e5                	mov    %esp,%ebp
80102c4c:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102c4f:	83 ec 08             	sub    $0x8,%esp
80102c52:	68 4a af 10 80       	push   $0x8010af4a
80102c57:	68 20 84 11 80       	push   $0x80118420
80102c5c:	e8 91 25 00 00       	call   801051f2 <initlock>
80102c61:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102c64:	c7 05 54 84 11 80 00 	movl   $0x0,0x80118454
80102c6b:	00 00 00 
  freerange(vstart, vend);
80102c6e:	83 ec 08             	sub    $0x8,%esp
80102c71:	ff 75 0c             	pushl  0xc(%ebp)
80102c74:	ff 75 08             	pushl  0x8(%ebp)
80102c77:	e8 2e 00 00 00       	call   80102caa <freerange>
80102c7c:	83 c4 10             	add    $0x10,%esp
}
80102c7f:	90                   	nop
80102c80:	c9                   	leave  
80102c81:	c3                   	ret    

80102c82 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c82:	f3 0f 1e fb          	endbr32 
80102c86:	55                   	push   %ebp
80102c87:	89 e5                	mov    %esp,%ebp
80102c89:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c8c:	83 ec 08             	sub    $0x8,%esp
80102c8f:	ff 75 0c             	pushl  0xc(%ebp)
80102c92:	ff 75 08             	pushl  0x8(%ebp)
80102c95:	e8 10 00 00 00       	call   80102caa <freerange>
80102c9a:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c9d:	c7 05 54 84 11 80 01 	movl   $0x1,0x80118454
80102ca4:	00 00 00 
}
80102ca7:	90                   	nop
80102ca8:	c9                   	leave  
80102ca9:	c3                   	ret    

80102caa <freerange>:

void
freerange(void *vstart, void *vend)
{
80102caa:	f3 0f 1e fb          	endbr32 
80102cae:	55                   	push   %ebp
80102caf:	89 e5                	mov    %esp,%ebp
80102cb1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb7:	05 ff 0f 00 00       	add    $0xfff,%eax
80102cbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cc4:	eb 15                	jmp    80102cdb <freerange+0x31>
    kfree(p);
80102cc6:	83 ec 0c             	sub    $0xc,%esp
80102cc9:	ff 75 f4             	pushl  -0xc(%ebp)
80102ccc:	e8 1b 00 00 00       	call   80102cec <kfree>
80102cd1:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cd4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cde:	05 00 10 00 00       	add    $0x1000,%eax
80102ce3:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102ce6:	73 de                	jae    80102cc6 <freerange+0x1c>
}
80102ce8:	90                   	nop
80102ce9:	90                   	nop
80102cea:	c9                   	leave  
80102ceb:	c3                   	ret    

80102cec <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102cec:	f3 0f 1e fb          	endbr32 
80102cf0:	55                   	push   %ebp
80102cf1:	89 e5                	mov    %esp,%ebp
80102cf3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf9:	25 ff 0f 00 00       	and    $0xfff,%eax
80102cfe:	85 c0                	test   %eax,%eax
80102d00:	75 18                	jne    80102d1a <kfree+0x2e>
80102d02:	81 7d 08 00 c0 11 80 	cmpl   $0x8011c000,0x8(%ebp)
80102d09:	72 0f                	jb     80102d1a <kfree+0x2e>
80102d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d0e:	05 00 00 00 80       	add    $0x80000000,%eax
80102d13:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102d18:	76 0d                	jbe    80102d27 <kfree+0x3b>
    panic("kfree");
80102d1a:	83 ec 0c             	sub    $0xc,%esp
80102d1d:	68 4f af 10 80       	push   $0x8010af4f
80102d22:	e8 9e d8 ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d27:	83 ec 04             	sub    $0x4,%esp
80102d2a:	68 00 10 00 00       	push   $0x1000
80102d2f:	6a 01                	push   $0x1
80102d31:	ff 75 08             	pushl  0x8(%ebp)
80102d34:	e8 6e 27 00 00       	call   801054a7 <memset>
80102d39:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102d3c:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d41:	85 c0                	test   %eax,%eax
80102d43:	74 10                	je     80102d55 <kfree+0x69>
    acquire(&kmem.lock);
80102d45:	83 ec 0c             	sub    $0xc,%esp
80102d48:	68 20 84 11 80       	push   $0x80118420
80102d4d:	e8 c6 24 00 00       	call   80105218 <acquire>
80102d52:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102d55:	8b 45 08             	mov    0x8(%ebp),%eax
80102d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102d5b:	8b 15 58 84 11 80    	mov    0x80118458,%edx
80102d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d64:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d69:	a3 58 84 11 80       	mov    %eax,0x80118458
  if(kmem.use_lock)
80102d6e:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d73:	85 c0                	test   %eax,%eax
80102d75:	74 10                	je     80102d87 <kfree+0x9b>
    release(&kmem.lock);
80102d77:	83 ec 0c             	sub    $0xc,%esp
80102d7a:	68 20 84 11 80       	push   $0x80118420
80102d7f:	e8 06 25 00 00       	call   8010528a <release>
80102d84:	83 c4 10             	add    $0x10,%esp
}
80102d87:	90                   	nop
80102d88:	c9                   	leave  
80102d89:	c3                   	ret    

80102d8a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d8a:	f3 0f 1e fb          	endbr32 
80102d8e:	55                   	push   %ebp
80102d8f:	89 e5                	mov    %esp,%ebp
80102d91:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d94:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d99:	85 c0                	test   %eax,%eax
80102d9b:	74 10                	je     80102dad <kalloc+0x23>
    acquire(&kmem.lock);
80102d9d:	83 ec 0c             	sub    $0xc,%esp
80102da0:	68 20 84 11 80       	push   $0x80118420
80102da5:	e8 6e 24 00 00       	call   80105218 <acquire>
80102daa:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102dad:	a1 58 84 11 80       	mov    0x80118458,%eax
80102db2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102db5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102db9:	74 0a                	je     80102dc5 <kalloc+0x3b>
    kmem.freelist = r->next;
80102dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dbe:	8b 00                	mov    (%eax),%eax
80102dc0:	a3 58 84 11 80       	mov    %eax,0x80118458
  if(kmem.use_lock)
80102dc5:	a1 54 84 11 80       	mov    0x80118454,%eax
80102dca:	85 c0                	test   %eax,%eax
80102dcc:	74 10                	je     80102dde <kalloc+0x54>
    release(&kmem.lock);
80102dce:	83 ec 0c             	sub    $0xc,%esp
80102dd1:	68 20 84 11 80       	push   $0x80118420
80102dd6:	e8 af 24 00 00       	call   8010528a <release>
80102ddb:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102de1:	c9                   	leave  
80102de2:	c3                   	ret    

80102de3 <inb>:
{
80102de3:	55                   	push   %ebp
80102de4:	89 e5                	mov    %esp,%ebp
80102de6:	83 ec 14             	sub    $0x14,%esp
80102de9:	8b 45 08             	mov    0x8(%ebp),%eax
80102dec:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102df0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102df4:	89 c2                	mov    %eax,%edx
80102df6:	ec                   	in     (%dx),%al
80102df7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dfa:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102dfe:	c9                   	leave  
80102dff:	c3                   	ret    

80102e00 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e00:	f3 0f 1e fb          	endbr32 
80102e04:	55                   	push   %ebp
80102e05:	89 e5                	mov    %esp,%ebp
80102e07:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e0a:	6a 64                	push   $0x64
80102e0c:	e8 d2 ff ff ff       	call   80102de3 <inb>
80102e11:	83 c4 04             	add    $0x4,%esp
80102e14:	0f b6 c0             	movzbl %al,%eax
80102e17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e1d:	83 e0 01             	and    $0x1,%eax
80102e20:	85 c0                	test   %eax,%eax
80102e22:	75 0a                	jne    80102e2e <kbdgetc+0x2e>
    return -1;
80102e24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e29:	e9 23 01 00 00       	jmp    80102f51 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102e2e:	6a 60                	push   $0x60
80102e30:	e8 ae ff ff ff       	call   80102de3 <inb>
80102e35:	83 c4 04             	add    $0x4,%esp
80102e38:	0f b6 c0             	movzbl %al,%eax
80102e3b:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e3e:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e45:	75 17                	jne    80102e5e <kbdgetc+0x5e>
    shift |= E0ESC;
80102e47:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e4c:	83 c8 40             	or     $0x40,%eax
80102e4f:	a3 9c 00 11 80       	mov    %eax,0x8011009c
    return 0;
80102e54:	b8 00 00 00 00       	mov    $0x0,%eax
80102e59:	e9 f3 00 00 00       	jmp    80102f51 <kbdgetc+0x151>
  } else if(data & 0x80){
80102e5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e61:	25 80 00 00 00       	and    $0x80,%eax
80102e66:	85 c0                	test   %eax,%eax
80102e68:	74 45                	je     80102eaf <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e6a:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e6f:	83 e0 40             	and    $0x40,%eax
80102e72:	85 c0                	test   %eax,%eax
80102e74:	75 08                	jne    80102e7e <kbdgetc+0x7e>
80102e76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e79:	83 e0 7f             	and    $0x7f,%eax
80102e7c:	eb 03                	jmp    80102e81 <kbdgetc+0x81>
80102e7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e81:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e87:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102e8c:	0f b6 00             	movzbl (%eax),%eax
80102e8f:	83 c8 40             	or     $0x40,%eax
80102e92:	0f b6 c0             	movzbl %al,%eax
80102e95:	f7 d0                	not    %eax
80102e97:	89 c2                	mov    %eax,%edx
80102e99:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102e9e:	21 d0                	and    %edx,%eax
80102ea0:	a3 9c 00 11 80       	mov    %eax,0x8011009c
    return 0;
80102ea5:	b8 00 00 00 00       	mov    $0x0,%eax
80102eaa:	e9 a2 00 00 00       	jmp    80102f51 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102eaf:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102eb4:	83 e0 40             	and    $0x40,%eax
80102eb7:	85 c0                	test   %eax,%eax
80102eb9:	74 14                	je     80102ecf <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102ebb:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102ec2:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102ec7:	83 e0 bf             	and    $0xffffffbf,%eax
80102eca:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  }

  shift |= shiftcode[data];
80102ecf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ed2:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102ed7:	0f b6 00             	movzbl (%eax),%eax
80102eda:	0f b6 d0             	movzbl %al,%edx
80102edd:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102ee2:	09 d0                	or     %edx,%eax
80102ee4:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  shift ^= togglecode[data];
80102ee9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eec:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102ef1:	0f b6 00             	movzbl (%eax),%eax
80102ef4:	0f b6 d0             	movzbl %al,%edx
80102ef7:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102efc:	31 d0                	xor    %edx,%eax
80102efe:	a3 9c 00 11 80       	mov    %eax,0x8011009c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f03:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102f08:	83 e0 03             	and    $0x3,%eax
80102f0b:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102f12:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f15:	01 d0                	add    %edx,%eax
80102f17:	0f b6 00             	movzbl (%eax),%eax
80102f1a:	0f b6 c0             	movzbl %al,%eax
80102f1d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f20:	a1 9c 00 11 80       	mov    0x8011009c,%eax
80102f25:	83 e0 08             	and    $0x8,%eax
80102f28:	85 c0                	test   %eax,%eax
80102f2a:	74 22                	je     80102f4e <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102f2c:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f30:	76 0c                	jbe    80102f3e <kbdgetc+0x13e>
80102f32:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f36:	77 06                	ja     80102f3e <kbdgetc+0x13e>
      c += 'A' - 'a';
80102f38:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f3c:	eb 10                	jmp    80102f4e <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102f3e:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f42:	76 0a                	jbe    80102f4e <kbdgetc+0x14e>
80102f44:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f48:	77 04                	ja     80102f4e <kbdgetc+0x14e>
      c += 'a' - 'A';
80102f4a:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f51:	c9                   	leave  
80102f52:	c3                   	ret    

80102f53 <kbdintr>:

void
kbdintr(void)
{
80102f53:	f3 0f 1e fb          	endbr32 
80102f57:	55                   	push   %ebp
80102f58:	89 e5                	mov    %esp,%ebp
80102f5a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102f5d:	83 ec 0c             	sub    $0xc,%esp
80102f60:	68 00 2e 10 80       	push   $0x80102e00
80102f65:	e8 96 d8 ff ff       	call   80100800 <consoleintr>
80102f6a:	83 c4 10             	add    $0x10,%esp
}
80102f6d:	90                   	nop
80102f6e:	c9                   	leave  
80102f6f:	c3                   	ret    

80102f70 <inb>:
{
80102f70:	55                   	push   %ebp
80102f71:	89 e5                	mov    %esp,%ebp
80102f73:	83 ec 14             	sub    $0x14,%esp
80102f76:	8b 45 08             	mov    0x8(%ebp),%eax
80102f79:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f7d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f81:	89 c2                	mov    %eax,%edx
80102f83:	ec                   	in     (%dx),%al
80102f84:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f87:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f8b:	c9                   	leave  
80102f8c:	c3                   	ret    

80102f8d <outb>:
{
80102f8d:	55                   	push   %ebp
80102f8e:	89 e5                	mov    %esp,%ebp
80102f90:	83 ec 08             	sub    $0x8,%esp
80102f93:	8b 45 08             	mov    0x8(%ebp),%eax
80102f96:	8b 55 0c             	mov    0xc(%ebp),%edx
80102f99:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102f9d:	89 d0                	mov    %edx,%eax
80102f9f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fa2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102fa6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102faa:	ee                   	out    %al,(%dx)
}
80102fab:	90                   	nop
80102fac:	c9                   	leave  
80102fad:	c3                   	ret    

80102fae <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102fae:	f3 0f 1e fb          	endbr32 
80102fb2:	55                   	push   %ebp
80102fb3:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fb5:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fba:	8b 55 08             	mov    0x8(%ebp),%edx
80102fbd:	c1 e2 02             	shl    $0x2,%edx
80102fc0:	01 c2                	add    %eax,%edx
80102fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fc5:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102fc7:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fcc:	83 c0 20             	add    $0x20,%eax
80102fcf:	8b 00                	mov    (%eax),%eax
}
80102fd1:	90                   	nop
80102fd2:	5d                   	pop    %ebp
80102fd3:	c3                   	ret    

80102fd4 <lapicinit>:

void
lapicinit(void)
{
80102fd4:	f3 0f 1e fb          	endbr32 
80102fd8:	55                   	push   %ebp
80102fd9:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102fdb:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80102fe0:	85 c0                	test   %eax,%eax
80102fe2:	0f 84 0c 01 00 00    	je     801030f4 <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102fe8:	68 3f 01 00 00       	push   $0x13f
80102fed:	6a 3c                	push   $0x3c
80102fef:	e8 ba ff ff ff       	call   80102fae <lapicw>
80102ff4:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ff7:	6a 0b                	push   $0xb
80102ff9:	68 f8 00 00 00       	push   $0xf8
80102ffe:	e8 ab ff ff ff       	call   80102fae <lapicw>
80103003:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103006:	68 20 00 02 00       	push   $0x20020
8010300b:	68 c8 00 00 00       	push   $0xc8
80103010:	e8 99 ff ff ff       	call   80102fae <lapicw>
80103015:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80103018:	68 80 96 98 00       	push   $0x989680
8010301d:	68 e0 00 00 00       	push   $0xe0
80103022:	e8 87 ff ff ff       	call   80102fae <lapicw>
80103027:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010302a:	68 00 00 01 00       	push   $0x10000
8010302f:	68 d4 00 00 00       	push   $0xd4
80103034:	e8 75 ff ff ff       	call   80102fae <lapicw>
80103039:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
8010303c:	68 00 00 01 00       	push   $0x10000
80103041:	68 d8 00 00 00       	push   $0xd8
80103046:	e8 63 ff ff ff       	call   80102fae <lapicw>
8010304b:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010304e:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103053:	83 c0 30             	add    $0x30,%eax
80103056:	8b 00                	mov    (%eax),%eax
80103058:	c1 e8 10             	shr    $0x10,%eax
8010305b:	25 fc 00 00 00       	and    $0xfc,%eax
80103060:	85 c0                	test   %eax,%eax
80103062:	74 12                	je     80103076 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
80103064:	68 00 00 01 00       	push   $0x10000
80103069:	68 d0 00 00 00       	push   $0xd0
8010306e:	e8 3b ff ff ff       	call   80102fae <lapicw>
80103073:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103076:	6a 33                	push   $0x33
80103078:	68 dc 00 00 00       	push   $0xdc
8010307d:	e8 2c ff ff ff       	call   80102fae <lapicw>
80103082:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103085:	6a 00                	push   $0x0
80103087:	68 a0 00 00 00       	push   $0xa0
8010308c:	e8 1d ff ff ff       	call   80102fae <lapicw>
80103091:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103094:	6a 00                	push   $0x0
80103096:	68 a0 00 00 00       	push   $0xa0
8010309b:	e8 0e ff ff ff       	call   80102fae <lapicw>
801030a0:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801030a3:	6a 00                	push   $0x0
801030a5:	6a 2c                	push   $0x2c
801030a7:	e8 02 ff ff ff       	call   80102fae <lapicw>
801030ac:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801030af:	6a 00                	push   $0x0
801030b1:	68 c4 00 00 00       	push   $0xc4
801030b6:	e8 f3 fe ff ff       	call   80102fae <lapicw>
801030bb:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801030be:	68 00 85 08 00       	push   $0x88500
801030c3:	68 c0 00 00 00       	push   $0xc0
801030c8:	e8 e1 fe ff ff       	call   80102fae <lapicw>
801030cd:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801030d0:	90                   	nop
801030d1:	a1 5c 84 11 80       	mov    0x8011845c,%eax
801030d6:	05 00 03 00 00       	add    $0x300,%eax
801030db:	8b 00                	mov    (%eax),%eax
801030dd:	25 00 10 00 00       	and    $0x1000,%eax
801030e2:	85 c0                	test   %eax,%eax
801030e4:	75 eb                	jne    801030d1 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801030e6:	6a 00                	push   $0x0
801030e8:	6a 20                	push   $0x20
801030ea:	e8 bf fe ff ff       	call   80102fae <lapicw>
801030ef:	83 c4 08             	add    $0x8,%esp
801030f2:	eb 01                	jmp    801030f5 <lapicinit+0x121>
    return;
801030f4:	90                   	nop
}
801030f5:	c9                   	leave  
801030f6:	c3                   	ret    

801030f7 <lapicid>:

int
lapicid(void)
{
801030f7:	f3 0f 1e fb          	endbr32 
801030fb:	55                   	push   %ebp
801030fc:	89 e5                	mov    %esp,%ebp

  if (!lapic){
801030fe:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103103:	85 c0                	test   %eax,%eax
80103105:	75 07                	jne    8010310e <lapicid+0x17>
    return 0;
80103107:	b8 00 00 00 00       	mov    $0x0,%eax
8010310c:	eb 0d                	jmp    8010311b <lapicid+0x24>
  }
  return lapic[ID] >> 24;
8010310e:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103113:	83 c0 20             	add    $0x20,%eax
80103116:	8b 00                	mov    (%eax),%eax
80103118:	c1 e8 18             	shr    $0x18,%eax
}
8010311b:	5d                   	pop    %ebp
8010311c:	c3                   	ret    

8010311d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010311d:	f3 0f 1e fb          	endbr32 
80103121:	55                   	push   %ebp
80103122:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103124:	a1 5c 84 11 80       	mov    0x8011845c,%eax
80103129:	85 c0                	test   %eax,%eax
8010312b:	74 0c                	je     80103139 <lapiceoi+0x1c>
    lapicw(EOI, 0);
8010312d:	6a 00                	push   $0x0
8010312f:	6a 2c                	push   $0x2c
80103131:	e8 78 fe ff ff       	call   80102fae <lapicw>
80103136:	83 c4 08             	add    $0x8,%esp
}
80103139:	90                   	nop
8010313a:	c9                   	leave  
8010313b:	c3                   	ret    

8010313c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010313c:	f3 0f 1e fb          	endbr32 
80103140:	55                   	push   %ebp
80103141:	89 e5                	mov    %esp,%ebp
}
80103143:	90                   	nop
80103144:	5d                   	pop    %ebp
80103145:	c3                   	ret    

80103146 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103146:	f3 0f 1e fb          	endbr32 
8010314a:	55                   	push   %ebp
8010314b:	89 e5                	mov    %esp,%ebp
8010314d:	83 ec 14             	sub    $0x14,%esp
80103150:	8b 45 08             	mov    0x8(%ebp),%eax
80103153:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103156:	6a 0f                	push   $0xf
80103158:	6a 70                	push   $0x70
8010315a:	e8 2e fe ff ff       	call   80102f8d <outb>
8010315f:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103162:	6a 0a                	push   $0xa
80103164:	6a 71                	push   $0x71
80103166:	e8 22 fe ff ff       	call   80102f8d <outb>
8010316b:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010316e:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103175:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103178:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010317d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103180:	c1 e8 04             	shr    $0x4,%eax
80103183:	89 c2                	mov    %eax,%edx
80103185:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103188:	83 c0 02             	add    $0x2,%eax
8010318b:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010318e:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103192:	c1 e0 18             	shl    $0x18,%eax
80103195:	50                   	push   %eax
80103196:	68 c4 00 00 00       	push   $0xc4
8010319b:	e8 0e fe ff ff       	call   80102fae <lapicw>
801031a0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801031a3:	68 00 c5 00 00       	push   $0xc500
801031a8:	68 c0 00 00 00       	push   $0xc0
801031ad:	e8 fc fd ff ff       	call   80102fae <lapicw>
801031b2:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031b5:	68 c8 00 00 00       	push   $0xc8
801031ba:	e8 7d ff ff ff       	call   8010313c <microdelay>
801031bf:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801031c2:	68 00 85 00 00       	push   $0x8500
801031c7:	68 c0 00 00 00       	push   $0xc0
801031cc:	e8 dd fd ff ff       	call   80102fae <lapicw>
801031d1:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031d4:	6a 64                	push   $0x64
801031d6:	e8 61 ff ff ff       	call   8010313c <microdelay>
801031db:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801031e5:	eb 3d                	jmp    80103224 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801031e7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031eb:	c1 e0 18             	shl    $0x18,%eax
801031ee:	50                   	push   %eax
801031ef:	68 c4 00 00 00       	push   $0xc4
801031f4:	e8 b5 fd ff ff       	call   80102fae <lapicw>
801031f9:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801031fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801031ff:	c1 e8 0c             	shr    $0xc,%eax
80103202:	80 cc 06             	or     $0x6,%ah
80103205:	50                   	push   %eax
80103206:	68 c0 00 00 00       	push   $0xc0
8010320b:	e8 9e fd ff ff       	call   80102fae <lapicw>
80103210:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103213:	68 c8 00 00 00       	push   $0xc8
80103218:	e8 1f ff ff ff       	call   8010313c <microdelay>
8010321d:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103220:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103224:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103228:	7e bd                	jle    801031e7 <lapicstartap+0xa1>
  }
}
8010322a:	90                   	nop
8010322b:	90                   	nop
8010322c:	c9                   	leave  
8010322d:	c3                   	ret    

8010322e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010322e:	f3 0f 1e fb          	endbr32 
80103232:	55                   	push   %ebp
80103233:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103235:	8b 45 08             	mov    0x8(%ebp),%eax
80103238:	0f b6 c0             	movzbl %al,%eax
8010323b:	50                   	push   %eax
8010323c:	6a 70                	push   $0x70
8010323e:	e8 4a fd ff ff       	call   80102f8d <outb>
80103243:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103246:	68 c8 00 00 00       	push   $0xc8
8010324b:	e8 ec fe ff ff       	call   8010313c <microdelay>
80103250:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103253:	6a 71                	push   $0x71
80103255:	e8 16 fd ff ff       	call   80102f70 <inb>
8010325a:	83 c4 04             	add    $0x4,%esp
8010325d:	0f b6 c0             	movzbl %al,%eax
}
80103260:	c9                   	leave  
80103261:	c3                   	ret    

80103262 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103262:	f3 0f 1e fb          	endbr32 
80103266:	55                   	push   %ebp
80103267:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103269:	6a 00                	push   $0x0
8010326b:	e8 be ff ff ff       	call   8010322e <cmos_read>
80103270:	83 c4 04             	add    $0x4,%esp
80103273:	8b 55 08             	mov    0x8(%ebp),%edx
80103276:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103278:	6a 02                	push   $0x2
8010327a:	e8 af ff ff ff       	call   8010322e <cmos_read>
8010327f:	83 c4 04             	add    $0x4,%esp
80103282:	8b 55 08             	mov    0x8(%ebp),%edx
80103285:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103288:	6a 04                	push   $0x4
8010328a:	e8 9f ff ff ff       	call   8010322e <cmos_read>
8010328f:	83 c4 04             	add    $0x4,%esp
80103292:	8b 55 08             	mov    0x8(%ebp),%edx
80103295:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103298:	6a 07                	push   $0x7
8010329a:	e8 8f ff ff ff       	call   8010322e <cmos_read>
8010329f:	83 c4 04             	add    $0x4,%esp
801032a2:	8b 55 08             	mov    0x8(%ebp),%edx
801032a5:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801032a8:	6a 08                	push   $0x8
801032aa:	e8 7f ff ff ff       	call   8010322e <cmos_read>
801032af:	83 c4 04             	add    $0x4,%esp
801032b2:	8b 55 08             	mov    0x8(%ebp),%edx
801032b5:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801032b8:	6a 09                	push   $0x9
801032ba:	e8 6f ff ff ff       	call   8010322e <cmos_read>
801032bf:	83 c4 04             	add    $0x4,%esp
801032c2:	8b 55 08             	mov    0x8(%ebp),%edx
801032c5:	89 42 14             	mov    %eax,0x14(%edx)
}
801032c8:	90                   	nop
801032c9:	c9                   	leave  
801032ca:	c3                   	ret    

801032cb <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801032cb:	f3 0f 1e fb          	endbr32 
801032cf:	55                   	push   %ebp
801032d0:	89 e5                	mov    %esp,%ebp
801032d2:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801032d5:	6a 0b                	push   $0xb
801032d7:	e8 52 ff ff ff       	call   8010322e <cmos_read>
801032dc:	83 c4 04             	add    $0x4,%esp
801032df:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801032e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e5:	83 e0 04             	and    $0x4,%eax
801032e8:	85 c0                	test   %eax,%eax
801032ea:	0f 94 c0             	sete   %al
801032ed:	0f b6 c0             	movzbl %al,%eax
801032f0:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801032f3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032f6:	50                   	push   %eax
801032f7:	e8 66 ff ff ff       	call   80103262 <fill_rtcdate>
801032fc:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801032ff:	6a 0a                	push   $0xa
80103301:	e8 28 ff ff ff       	call   8010322e <cmos_read>
80103306:	83 c4 04             	add    $0x4,%esp
80103309:	25 80 00 00 00       	and    $0x80,%eax
8010330e:	85 c0                	test   %eax,%eax
80103310:	75 27                	jne    80103339 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80103312:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103315:	50                   	push   %eax
80103316:	e8 47 ff ff ff       	call   80103262 <fill_rtcdate>
8010331b:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010331e:	83 ec 04             	sub    $0x4,%esp
80103321:	6a 18                	push   $0x18
80103323:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103326:	50                   	push   %eax
80103327:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010332a:	50                   	push   %eax
8010332b:	e8 e2 21 00 00       	call   80105512 <memcmp>
80103330:	83 c4 10             	add    $0x10,%esp
80103333:	85 c0                	test   %eax,%eax
80103335:	74 05                	je     8010333c <cmostime+0x71>
80103337:	eb ba                	jmp    801032f3 <cmostime+0x28>
        continue;
80103339:	90                   	nop
    fill_rtcdate(&t1);
8010333a:	eb b7                	jmp    801032f3 <cmostime+0x28>
      break;
8010333c:	90                   	nop
  }

  // convert
  if(bcd) {
8010333d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103341:	0f 84 b4 00 00 00    	je     801033fb <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103347:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010334a:	c1 e8 04             	shr    $0x4,%eax
8010334d:	89 c2                	mov    %eax,%edx
8010334f:	89 d0                	mov    %edx,%eax
80103351:	c1 e0 02             	shl    $0x2,%eax
80103354:	01 d0                	add    %edx,%eax
80103356:	01 c0                	add    %eax,%eax
80103358:	89 c2                	mov    %eax,%edx
8010335a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010335d:	83 e0 0f             	and    $0xf,%eax
80103360:	01 d0                	add    %edx,%eax
80103362:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103365:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103368:	c1 e8 04             	shr    $0x4,%eax
8010336b:	89 c2                	mov    %eax,%edx
8010336d:	89 d0                	mov    %edx,%eax
8010336f:	c1 e0 02             	shl    $0x2,%eax
80103372:	01 d0                	add    %edx,%eax
80103374:	01 c0                	add    %eax,%eax
80103376:	89 c2                	mov    %eax,%edx
80103378:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010337b:	83 e0 0f             	and    $0xf,%eax
8010337e:	01 d0                	add    %edx,%eax
80103380:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103383:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103386:	c1 e8 04             	shr    $0x4,%eax
80103389:	89 c2                	mov    %eax,%edx
8010338b:	89 d0                	mov    %edx,%eax
8010338d:	c1 e0 02             	shl    $0x2,%eax
80103390:	01 d0                	add    %edx,%eax
80103392:	01 c0                	add    %eax,%eax
80103394:	89 c2                	mov    %eax,%edx
80103396:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103399:	83 e0 0f             	and    $0xf,%eax
8010339c:	01 d0                	add    %edx,%eax
8010339e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801033a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033a4:	c1 e8 04             	shr    $0x4,%eax
801033a7:	89 c2                	mov    %eax,%edx
801033a9:	89 d0                	mov    %edx,%eax
801033ab:	c1 e0 02             	shl    $0x2,%eax
801033ae:	01 d0                	add    %edx,%eax
801033b0:	01 c0                	add    %eax,%eax
801033b2:	89 c2                	mov    %eax,%edx
801033b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033b7:	83 e0 0f             	and    $0xf,%eax
801033ba:	01 d0                	add    %edx,%eax
801033bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801033bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033c2:	c1 e8 04             	shr    $0x4,%eax
801033c5:	89 c2                	mov    %eax,%edx
801033c7:	89 d0                	mov    %edx,%eax
801033c9:	c1 e0 02             	shl    $0x2,%eax
801033cc:	01 d0                	add    %edx,%eax
801033ce:	01 c0                	add    %eax,%eax
801033d0:	89 c2                	mov    %eax,%edx
801033d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033d5:	83 e0 0f             	and    $0xf,%eax
801033d8:	01 d0                	add    %edx,%eax
801033da:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801033dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e0:	c1 e8 04             	shr    $0x4,%eax
801033e3:	89 c2                	mov    %eax,%edx
801033e5:	89 d0                	mov    %edx,%eax
801033e7:	c1 e0 02             	shl    $0x2,%eax
801033ea:	01 d0                	add    %edx,%eax
801033ec:	01 c0                	add    %eax,%eax
801033ee:	89 c2                	mov    %eax,%edx
801033f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f3:	83 e0 0f             	and    $0xf,%eax
801033f6:	01 d0                	add    %edx,%eax
801033f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801033fb:	8b 45 08             	mov    0x8(%ebp),%eax
801033fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103401:	89 10                	mov    %edx,(%eax)
80103403:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103406:	89 50 04             	mov    %edx,0x4(%eax)
80103409:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010340c:	89 50 08             	mov    %edx,0x8(%eax)
8010340f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103412:	89 50 0c             	mov    %edx,0xc(%eax)
80103415:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103418:	89 50 10             	mov    %edx,0x10(%eax)
8010341b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010341e:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103421:	8b 45 08             	mov    0x8(%ebp),%eax
80103424:	8b 40 14             	mov    0x14(%eax),%eax
80103427:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010342d:	8b 45 08             	mov    0x8(%ebp),%eax
80103430:	89 50 14             	mov    %edx,0x14(%eax)
}
80103433:	90                   	nop
80103434:	c9                   	leave  
80103435:	c3                   	ret    

80103436 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103436:	f3 0f 1e fb          	endbr32 
8010343a:	55                   	push   %ebp
8010343b:	89 e5                	mov    %esp,%ebp
8010343d:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103440:	83 ec 08             	sub    $0x8,%esp
80103443:	68 55 af 10 80       	push   $0x8010af55
80103448:	68 60 84 11 80       	push   $0x80118460
8010344d:	e8 a0 1d 00 00       	call   801051f2 <initlock>
80103452:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103455:	83 ec 08             	sub    $0x8,%esp
80103458:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010345b:	50                   	push   %eax
8010345c:	ff 75 08             	pushl  0x8(%ebp)
8010345f:	e8 c8 df ff ff       	call   8010142c <readsb>
80103464:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103467:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346a:	a3 94 84 11 80       	mov    %eax,0x80118494
  log.size = sb.nlog;
8010346f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103472:	a3 98 84 11 80       	mov    %eax,0x80118498
  log.dev = dev;
80103477:	8b 45 08             	mov    0x8(%ebp),%eax
8010347a:	a3 a4 84 11 80       	mov    %eax,0x801184a4
  recover_from_log();
8010347f:	e8 bf 01 00 00       	call   80103643 <recover_from_log>
}
80103484:	90                   	nop
80103485:	c9                   	leave  
80103486:	c3                   	ret    

80103487 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103487:	f3 0f 1e fb          	endbr32 
8010348b:	55                   	push   %ebp
8010348c:	89 e5                	mov    %esp,%ebp
8010348e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103491:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103498:	e9 95 00 00 00       	jmp    80103532 <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010349d:	8b 15 94 84 11 80    	mov    0x80118494,%edx
801034a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034a6:	01 d0                	add    %edx,%eax
801034a8:	83 c0 01             	add    $0x1,%eax
801034ab:	89 c2                	mov    %eax,%edx
801034ad:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801034b2:	83 ec 08             	sub    $0x8,%esp
801034b5:	52                   	push   %edx
801034b6:	50                   	push   %eax
801034b7:	e8 4d cd ff ff       	call   80100209 <bread>
801034bc:	83 c4 10             	add    $0x10,%esp
801034bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034c5:	83 c0 10             	add    $0x10,%eax
801034c8:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
801034cf:	89 c2                	mov    %eax,%edx
801034d1:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801034d6:	83 ec 08             	sub    $0x8,%esp
801034d9:	52                   	push   %edx
801034da:	50                   	push   %eax
801034db:	e8 29 cd ff ff       	call   80100209 <bread>
801034e0:	83 c4 10             	add    $0x10,%esp
801034e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801034e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034e9:	8d 50 5c             	lea    0x5c(%eax),%edx
801034ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ef:	83 c0 5c             	add    $0x5c,%eax
801034f2:	83 ec 04             	sub    $0x4,%esp
801034f5:	68 00 02 00 00       	push   $0x200
801034fa:	52                   	push   %edx
801034fb:	50                   	push   %eax
801034fc:	e8 6d 20 00 00       	call   8010556e <memmove>
80103501:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103504:	83 ec 0c             	sub    $0xc,%esp
80103507:	ff 75 ec             	pushl  -0x14(%ebp)
8010350a:	e8 37 cd ff ff       	call   80100246 <bwrite>
8010350f:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80103512:	83 ec 0c             	sub    $0xc,%esp
80103515:	ff 75 f0             	pushl  -0x10(%ebp)
80103518:	e8 76 cd ff ff       	call   80100293 <brelse>
8010351d:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103520:	83 ec 0c             	sub    $0xc,%esp
80103523:	ff 75 ec             	pushl  -0x14(%ebp)
80103526:	e8 68 cd ff ff       	call   80100293 <brelse>
8010352b:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010352e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103532:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103537:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010353a:	0f 8c 5d ff ff ff    	jl     8010349d <install_trans+0x16>
  }
}
80103540:	90                   	nop
80103541:	90                   	nop
80103542:	c9                   	leave  
80103543:	c3                   	ret    

80103544 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103544:	f3 0f 1e fb          	endbr32 
80103548:	55                   	push   %ebp
80103549:	89 e5                	mov    %esp,%ebp
8010354b:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010354e:	a1 94 84 11 80       	mov    0x80118494,%eax
80103553:	89 c2                	mov    %eax,%edx
80103555:	a1 a4 84 11 80       	mov    0x801184a4,%eax
8010355a:	83 ec 08             	sub    $0x8,%esp
8010355d:	52                   	push   %edx
8010355e:	50                   	push   %eax
8010355f:	e8 a5 cc ff ff       	call   80100209 <bread>
80103564:	83 c4 10             	add    $0x10,%esp
80103567:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010356a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010356d:	83 c0 5c             	add    $0x5c,%eax
80103570:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103573:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103576:	8b 00                	mov    (%eax),%eax
80103578:	a3 a8 84 11 80       	mov    %eax,0x801184a8
  for (i = 0; i < log.lh.n; i++) {
8010357d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103584:	eb 1b                	jmp    801035a1 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
80103586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103589:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010358c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103590:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103593:	83 c2 10             	add    $0x10,%edx
80103596:	89 04 95 6c 84 11 80 	mov    %eax,-0x7fee7b94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010359d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035a1:	a1 a8 84 11 80       	mov    0x801184a8,%eax
801035a6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035a9:	7c db                	jl     80103586 <read_head+0x42>
  }
  brelse(buf);
801035ab:	83 ec 0c             	sub    $0xc,%esp
801035ae:	ff 75 f0             	pushl  -0x10(%ebp)
801035b1:	e8 dd cc ff ff       	call   80100293 <brelse>
801035b6:	83 c4 10             	add    $0x10,%esp
}
801035b9:	90                   	nop
801035ba:	c9                   	leave  
801035bb:	c3                   	ret    

801035bc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801035bc:	f3 0f 1e fb          	endbr32 
801035c0:	55                   	push   %ebp
801035c1:	89 e5                	mov    %esp,%ebp
801035c3:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035c6:	a1 94 84 11 80       	mov    0x80118494,%eax
801035cb:	89 c2                	mov    %eax,%edx
801035cd:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801035d2:	83 ec 08             	sub    $0x8,%esp
801035d5:	52                   	push   %edx
801035d6:	50                   	push   %eax
801035d7:	e8 2d cc ff ff       	call   80100209 <bread>
801035dc:	83 c4 10             	add    $0x10,%esp
801035df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801035e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035e5:	83 c0 5c             	add    $0x5c,%eax
801035e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801035eb:	8b 15 a8 84 11 80    	mov    0x801184a8,%edx
801035f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035f4:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801035f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035fd:	eb 1b                	jmp    8010361a <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
801035ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103602:	83 c0 10             	add    $0x10,%eax
80103605:	8b 0c 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%ecx
8010360c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010360f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103612:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103616:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010361a:	a1 a8 84 11 80       	mov    0x801184a8,%eax
8010361f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103622:	7c db                	jl     801035ff <write_head+0x43>
  }
  bwrite(buf);
80103624:	83 ec 0c             	sub    $0xc,%esp
80103627:	ff 75 f0             	pushl  -0x10(%ebp)
8010362a:	e8 17 cc ff ff       	call   80100246 <bwrite>
8010362f:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103632:	83 ec 0c             	sub    $0xc,%esp
80103635:	ff 75 f0             	pushl  -0x10(%ebp)
80103638:	e8 56 cc ff ff       	call   80100293 <brelse>
8010363d:	83 c4 10             	add    $0x10,%esp
}
80103640:	90                   	nop
80103641:	c9                   	leave  
80103642:	c3                   	ret    

80103643 <recover_from_log>:

static void
recover_from_log(void)
{
80103643:	f3 0f 1e fb          	endbr32 
80103647:	55                   	push   %ebp
80103648:	89 e5                	mov    %esp,%ebp
8010364a:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010364d:	e8 f2 fe ff ff       	call   80103544 <read_head>
  install_trans(); // if committed, copy from log to disk
80103652:	e8 30 fe ff ff       	call   80103487 <install_trans>
  log.lh.n = 0;
80103657:	c7 05 a8 84 11 80 00 	movl   $0x0,0x801184a8
8010365e:	00 00 00 
  write_head(); // clear the log
80103661:	e8 56 ff ff ff       	call   801035bc <write_head>
}
80103666:	90                   	nop
80103667:	c9                   	leave  
80103668:	c3                   	ret    

80103669 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103669:	f3 0f 1e fb          	endbr32 
8010366d:	55                   	push   %ebp
8010366e:	89 e5                	mov    %esp,%ebp
80103670:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103673:	83 ec 0c             	sub    $0xc,%esp
80103676:	68 60 84 11 80       	push   $0x80118460
8010367b:	e8 98 1b 00 00       	call   80105218 <acquire>
80103680:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103683:	a1 a0 84 11 80       	mov    0x801184a0,%eax
80103688:	85 c0                	test   %eax,%eax
8010368a:	74 17                	je     801036a3 <begin_op+0x3a>
      sleep(&log, &log.lock);
8010368c:	83 ec 08             	sub    $0x8,%esp
8010368f:	68 60 84 11 80       	push   $0x80118460
80103694:	68 60 84 11 80       	push   $0x80118460
80103699:	e8 9a 15 00 00       	call   80104c38 <sleep>
8010369e:	83 c4 10             	add    $0x10,%esp
801036a1:	eb e0                	jmp    80103683 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801036a3:	8b 0d a8 84 11 80    	mov    0x801184a8,%ecx
801036a9:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801036ae:	8d 50 01             	lea    0x1(%eax),%edx
801036b1:	89 d0                	mov    %edx,%eax
801036b3:	c1 e0 02             	shl    $0x2,%eax
801036b6:	01 d0                	add    %edx,%eax
801036b8:	01 c0                	add    %eax,%eax
801036ba:	01 c8                	add    %ecx,%eax
801036bc:	83 f8 1e             	cmp    $0x1e,%eax
801036bf:	7e 17                	jle    801036d8 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801036c1:	83 ec 08             	sub    $0x8,%esp
801036c4:	68 60 84 11 80       	push   $0x80118460
801036c9:	68 60 84 11 80       	push   $0x80118460
801036ce:	e8 65 15 00 00       	call   80104c38 <sleep>
801036d3:	83 c4 10             	add    $0x10,%esp
801036d6:	eb ab                	jmp    80103683 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801036d8:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801036dd:	83 c0 01             	add    $0x1,%eax
801036e0:	a3 9c 84 11 80       	mov    %eax,0x8011849c
      release(&log.lock);
801036e5:	83 ec 0c             	sub    $0xc,%esp
801036e8:	68 60 84 11 80       	push   $0x80118460
801036ed:	e8 98 1b 00 00       	call   8010528a <release>
801036f2:	83 c4 10             	add    $0x10,%esp
      break;
801036f5:	90                   	nop
    }
  }
}
801036f6:	90                   	nop
801036f7:	c9                   	leave  
801036f8:	c3                   	ret    

801036f9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801036f9:	f3 0f 1e fb          	endbr32 
801036fd:	55                   	push   %ebp
801036fe:	89 e5                	mov    %esp,%ebp
80103700:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010370a:	83 ec 0c             	sub    $0xc,%esp
8010370d:	68 60 84 11 80       	push   $0x80118460
80103712:	e8 01 1b 00 00       	call   80105218 <acquire>
80103717:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010371a:	a1 9c 84 11 80       	mov    0x8011849c,%eax
8010371f:	83 e8 01             	sub    $0x1,%eax
80103722:	a3 9c 84 11 80       	mov    %eax,0x8011849c
  if(log.committing)
80103727:	a1 a0 84 11 80       	mov    0x801184a0,%eax
8010372c:	85 c0                	test   %eax,%eax
8010372e:	74 0d                	je     8010373d <end_op+0x44>
    panic("log.committing");
80103730:	83 ec 0c             	sub    $0xc,%esp
80103733:	68 59 af 10 80       	push   $0x8010af59
80103738:	e8 88 ce ff ff       	call   801005c5 <panic>
  if(log.outstanding == 0){
8010373d:	a1 9c 84 11 80       	mov    0x8011849c,%eax
80103742:	85 c0                	test   %eax,%eax
80103744:	75 13                	jne    80103759 <end_op+0x60>
    do_commit = 1;
80103746:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010374d:	c7 05 a0 84 11 80 01 	movl   $0x1,0x801184a0
80103754:	00 00 00 
80103757:	eb 10                	jmp    80103769 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103759:	83 ec 0c             	sub    $0xc,%esp
8010375c:	68 60 84 11 80       	push   $0x80118460
80103761:	e8 c4 15 00 00       	call   80104d2a <wakeup>
80103766:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103769:	83 ec 0c             	sub    $0xc,%esp
8010376c:	68 60 84 11 80       	push   $0x80118460
80103771:	e8 14 1b 00 00       	call   8010528a <release>
80103776:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103779:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010377d:	74 3f                	je     801037be <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010377f:	e8 fa 00 00 00       	call   8010387e <commit>
    acquire(&log.lock);
80103784:	83 ec 0c             	sub    $0xc,%esp
80103787:	68 60 84 11 80       	push   $0x80118460
8010378c:	e8 87 1a 00 00       	call   80105218 <acquire>
80103791:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103794:	c7 05 a0 84 11 80 00 	movl   $0x0,0x801184a0
8010379b:	00 00 00 
    wakeup(&log);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 84 11 80       	push   $0x80118460
801037a6:	e8 7f 15 00 00       	call   80104d2a <wakeup>
801037ab:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801037ae:	83 ec 0c             	sub    $0xc,%esp
801037b1:	68 60 84 11 80       	push   $0x80118460
801037b6:	e8 cf 1a 00 00       	call   8010528a <release>
801037bb:	83 c4 10             	add    $0x10,%esp
  }
}
801037be:	90                   	nop
801037bf:	c9                   	leave  
801037c0:	c3                   	ret    

801037c1 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801037c1:	f3 0f 1e fb          	endbr32 
801037c5:	55                   	push   %ebp
801037c6:	89 e5                	mov    %esp,%ebp
801037c8:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037d2:	e9 95 00 00 00       	jmp    8010386c <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801037d7:	8b 15 94 84 11 80    	mov    0x80118494,%edx
801037dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e0:	01 d0                	add    %edx,%eax
801037e2:	83 c0 01             	add    $0x1,%eax
801037e5:	89 c2                	mov    %eax,%edx
801037e7:	a1 a4 84 11 80       	mov    0x801184a4,%eax
801037ec:	83 ec 08             	sub    $0x8,%esp
801037ef:	52                   	push   %edx
801037f0:	50                   	push   %eax
801037f1:	e8 13 ca ff ff       	call   80100209 <bread>
801037f6:	83 c4 10             	add    $0x10,%esp
801037f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801037fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ff:	83 c0 10             	add    $0x10,%eax
80103802:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
80103809:	89 c2                	mov    %eax,%edx
8010380b:	a1 a4 84 11 80       	mov    0x801184a4,%eax
80103810:	83 ec 08             	sub    $0x8,%esp
80103813:	52                   	push   %edx
80103814:	50                   	push   %eax
80103815:	e8 ef c9 ff ff       	call   80100209 <bread>
8010381a:	83 c4 10             	add    $0x10,%esp
8010381d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103820:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103823:	8d 50 5c             	lea    0x5c(%eax),%edx
80103826:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103829:	83 c0 5c             	add    $0x5c,%eax
8010382c:	83 ec 04             	sub    $0x4,%esp
8010382f:	68 00 02 00 00       	push   $0x200
80103834:	52                   	push   %edx
80103835:	50                   	push   %eax
80103836:	e8 33 1d 00 00       	call   8010556e <memmove>
8010383b:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010383e:	83 ec 0c             	sub    $0xc,%esp
80103841:	ff 75 f0             	pushl  -0x10(%ebp)
80103844:	e8 fd c9 ff ff       	call   80100246 <bwrite>
80103849:	83 c4 10             	add    $0x10,%esp
    brelse(from);
8010384c:	83 ec 0c             	sub    $0xc,%esp
8010384f:	ff 75 ec             	pushl  -0x14(%ebp)
80103852:	e8 3c ca ff ff       	call   80100293 <brelse>
80103857:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010385a:	83 ec 0c             	sub    $0xc,%esp
8010385d:	ff 75 f0             	pushl  -0x10(%ebp)
80103860:	e8 2e ca ff ff       	call   80100293 <brelse>
80103865:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103868:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010386c:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103871:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103874:	0f 8c 5d ff ff ff    	jl     801037d7 <write_log+0x16>
  }
}
8010387a:	90                   	nop
8010387b:	90                   	nop
8010387c:	c9                   	leave  
8010387d:	c3                   	ret    

8010387e <commit>:

static void
commit()
{
8010387e:	f3 0f 1e fb          	endbr32 
80103882:	55                   	push   %ebp
80103883:	89 e5                	mov    %esp,%ebp
80103885:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103888:	a1 a8 84 11 80       	mov    0x801184a8,%eax
8010388d:	85 c0                	test   %eax,%eax
8010388f:	7e 1e                	jle    801038af <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103891:	e8 2b ff ff ff       	call   801037c1 <write_log>
    write_head();    // Write header to disk -- the real commit
80103896:	e8 21 fd ff ff       	call   801035bc <write_head>
    install_trans(); // Now install writes to home locations
8010389b:	e8 e7 fb ff ff       	call   80103487 <install_trans>
    log.lh.n = 0;
801038a0:	c7 05 a8 84 11 80 00 	movl   $0x0,0x801184a8
801038a7:	00 00 00 
    write_head();    // Erase the transaction from the log
801038aa:	e8 0d fd ff ff       	call   801035bc <write_head>
  }
}
801038af:	90                   	nop
801038b0:	c9                   	leave  
801038b1:	c3                   	ret    

801038b2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801038b2:	f3 0f 1e fb          	endbr32 
801038b6:	55                   	push   %ebp
801038b7:	89 e5                	mov    %esp,%ebp
801038b9:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801038bc:	a1 a8 84 11 80       	mov    0x801184a8,%eax
801038c1:	83 f8 1d             	cmp    $0x1d,%eax
801038c4:	7f 12                	jg     801038d8 <log_write+0x26>
801038c6:	a1 a8 84 11 80       	mov    0x801184a8,%eax
801038cb:	8b 15 98 84 11 80    	mov    0x80118498,%edx
801038d1:	83 ea 01             	sub    $0x1,%edx
801038d4:	39 d0                	cmp    %edx,%eax
801038d6:	7c 0d                	jl     801038e5 <log_write+0x33>
    panic("too big a transaction");
801038d8:	83 ec 0c             	sub    $0xc,%esp
801038db:	68 68 af 10 80       	push   $0x8010af68
801038e0:	e8 e0 cc ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801038e5:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801038ea:	85 c0                	test   %eax,%eax
801038ec:	7f 0d                	jg     801038fb <log_write+0x49>
    panic("log_write outside of trans");
801038ee:	83 ec 0c             	sub    $0xc,%esp
801038f1:	68 7e af 10 80       	push   $0x8010af7e
801038f6:	e8 ca cc ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
801038fb:	83 ec 0c             	sub    $0xc,%esp
801038fe:	68 60 84 11 80       	push   $0x80118460
80103903:	e8 10 19 00 00       	call   80105218 <acquire>
80103908:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
8010390b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103912:	eb 1d                	jmp    80103931 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103917:	83 c0 10             	add    $0x10,%eax
8010391a:	8b 04 85 6c 84 11 80 	mov    -0x7fee7b94(,%eax,4),%eax
80103921:	89 c2                	mov    %eax,%edx
80103923:	8b 45 08             	mov    0x8(%ebp),%eax
80103926:	8b 40 08             	mov    0x8(%eax),%eax
80103929:	39 c2                	cmp    %eax,%edx
8010392b:	74 10                	je     8010393d <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
8010392d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103931:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103936:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103939:	7c d9                	jl     80103914 <log_write+0x62>
8010393b:	eb 01                	jmp    8010393e <log_write+0x8c>
      break;
8010393d:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010393e:	8b 45 08             	mov    0x8(%ebp),%eax
80103941:	8b 40 08             	mov    0x8(%eax),%eax
80103944:	89 c2                	mov    %eax,%edx
80103946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103949:	83 c0 10             	add    $0x10,%eax
8010394c:	89 14 85 6c 84 11 80 	mov    %edx,-0x7fee7b94(,%eax,4)
  if (i == log.lh.n)
80103953:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103958:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010395b:	75 0d                	jne    8010396a <log_write+0xb8>
    log.lh.n++;
8010395d:	a1 a8 84 11 80       	mov    0x801184a8,%eax
80103962:	83 c0 01             	add    $0x1,%eax
80103965:	a3 a8 84 11 80       	mov    %eax,0x801184a8
  b->flags |= B_DIRTY; // prevent eviction
8010396a:	8b 45 08             	mov    0x8(%ebp),%eax
8010396d:	8b 00                	mov    (%eax),%eax
8010396f:	83 c8 04             	or     $0x4,%eax
80103972:	89 c2                	mov    %eax,%edx
80103974:	8b 45 08             	mov    0x8(%ebp),%eax
80103977:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103979:	83 ec 0c             	sub    $0xc,%esp
8010397c:	68 60 84 11 80       	push   $0x80118460
80103981:	e8 04 19 00 00       	call   8010528a <release>
80103986:	83 c4 10             	add    $0x10,%esp
}
80103989:	90                   	nop
8010398a:	c9                   	leave  
8010398b:	c3                   	ret    

8010398c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010398c:	55                   	push   %ebp
8010398d:	89 e5                	mov    %esp,%ebp
8010398f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103992:	8b 55 08             	mov    0x8(%ebp),%edx
80103995:	8b 45 0c             	mov    0xc(%ebp),%eax
80103998:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010399b:	f0 87 02             	lock xchg %eax,(%edx)
8010399e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801039a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801039a4:	c9                   	leave  
801039a5:	c3                   	ret    

801039a6 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801039a6:	f3 0f 1e fb          	endbr32 
801039aa:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801039ae:	83 e4 f0             	and    $0xfffffff0,%esp
801039b1:	ff 71 fc             	pushl  -0x4(%ecx)
801039b4:	55                   	push   %ebp
801039b5:	89 e5                	mov    %esp,%ebp
801039b7:	51                   	push   %ecx
801039b8:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
801039bb:	e8 de 50 00 00       	call   80108a9e <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801039c0:	83 ec 08             	sub    $0x8,%esp
801039c3:	68 00 00 40 80       	push   $0x80400000
801039c8:	68 00 c0 11 80       	push   $0x8011c000
801039cd:	e8 73 f2 ff ff       	call   80102c45 <kinit1>
801039d2:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801039d5:	e8 a1 46 00 00       	call   8010807b <kvmalloc>
  mpinit_uefi();
801039da:	e8 78 4e 00 00       	call   80108857 <mpinit_uefi>
  lapicinit();     // interrupt controller
801039df:	e8 f0 f5 ff ff       	call   80102fd4 <lapicinit>
  seginit();       // segment descriptors
801039e4:	e8 19 41 00 00       	call   80107b02 <seginit>
  picinit();    // disable pic
801039e9:	e8 a9 01 00 00       	call   80103b97 <picinit>
  ioapicinit();    // another interrupt controller
801039ee:	e8 65 f1 ff ff       	call   80102b58 <ioapicinit>
  consoleinit();   // console hardware
801039f3:	e8 41 d1 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
801039f8:	e8 8e 34 00 00       	call   80106e8b <uartinit>
  pinit();         // process table
801039fd:	e8 e2 05 00 00       	call   80103fe4 <pinit>
  tvinit();        // trap vectors
80103a02:	e8 01 30 00 00       	call   80106a08 <tvinit>
  binit();         // buffer cache
80103a07:	e8 5a c6 ff ff       	call   80100066 <binit>
  fileinit();      // file table
80103a0c:	e8 f0 d5 ff ff       	call   80101001 <fileinit>
  ideinit();       // disk 
80103a11:	e8 e3 ec ff ff       	call   801026f9 <ideinit>
  startothers();   // start other processors
80103a16:	e8 92 00 00 00       	call   80103aad <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a1b:	83 ec 08             	sub    $0x8,%esp
80103a1e:	68 00 00 00 a0       	push   $0xa0000000
80103a23:	68 00 00 40 80       	push   $0x80400000
80103a28:	e8 55 f2 ff ff       	call   80102c82 <kinit2>
80103a2d:	83 c4 10             	add    $0x10,%esp
  pci_init();
80103a30:	e8 dc 52 00 00       	call   80108d11 <pci_init>
  arp_scan();
80103a35:	e8 55 60 00 00       	call   80109a8f <arp_scan>
  //i8254_recv();
  userinit();      // first user process
80103a3a:	e8 ab 07 00 00       	call   801041ea <userinit>

  mpmain();        // finish this processor's setup
80103a3f:	e8 1e 00 00 00       	call   80103a62 <mpmain>

80103a44 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103a44:	f3 0f 1e fb          	endbr32 
80103a48:	55                   	push   %ebp
80103a49:	89 e5                	mov    %esp,%ebp
80103a4b:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103a4e:	e8 44 46 00 00       	call   80108097 <switchkvm>
  seginit();
80103a53:	e8 aa 40 00 00       	call   80107b02 <seginit>
  lapicinit();
80103a58:	e8 77 f5 ff ff       	call   80102fd4 <lapicinit>
  mpmain();
80103a5d:	e8 00 00 00 00       	call   80103a62 <mpmain>

80103a62 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a62:	f3 0f 1e fb          	endbr32 
80103a66:	55                   	push   %ebp
80103a67:	89 e5                	mov    %esp,%ebp
80103a69:	53                   	push   %ebx
80103a6a:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103a6d:	e8 94 05 00 00       	call   80104006 <cpuid>
80103a72:	89 c3                	mov    %eax,%ebx
80103a74:	e8 8d 05 00 00       	call   80104006 <cpuid>
80103a79:	83 ec 04             	sub    $0x4,%esp
80103a7c:	53                   	push   %ebx
80103a7d:	50                   	push   %eax
80103a7e:	68 99 af 10 80       	push   $0x8010af99
80103a83:	e8 84 c9 ff ff       	call   8010040c <cprintf>
80103a88:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a8b:	e8 f2 30 00 00       	call   80106b82 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103a90:	e8 90 05 00 00       	call   80104025 <mycpu>
80103a95:	05 a0 00 00 00       	add    $0xa0,%eax
80103a9a:	83 ec 08             	sub    $0x8,%esp
80103a9d:	6a 01                	push   $0x1
80103a9f:	50                   	push   %eax
80103aa0:	e8 e7 fe ff ff       	call   8010398c <xchg>
80103aa5:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103aa8:	e8 87 0f 00 00       	call   80104a34 <scheduler>

80103aad <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103aad:	f3 0f 1e fb          	endbr32 
80103ab1:	55                   	push   %ebp
80103ab2:	89 e5                	mov    %esp,%ebp
80103ab4:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103ab7:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103abe:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103ac3:	83 ec 04             	sub    $0x4,%esp
80103ac6:	50                   	push   %eax
80103ac7:	68 38 f5 10 80       	push   $0x8010f538
80103acc:	ff 75 f0             	pushl  -0x10(%ebp)
80103acf:	e8 9a 1a 00 00       	call   8010556e <memmove>
80103ad4:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103ad7:	c7 45 f4 00 af 11 80 	movl   $0x8011af00,-0xc(%ebp)
80103ade:	eb 79                	jmp    80103b59 <startothers+0xac>
    if(c == mycpu()){  // We've started already.
80103ae0:	e8 40 05 00 00       	call   80104025 <mycpu>
80103ae5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103ae8:	74 67                	je     80103b51 <startothers+0xa4>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103aea:	e8 9b f2 ff ff       	call   80102d8a <kalloc>
80103aef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af5:	83 e8 04             	sub    $0x4,%eax
80103af8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103afb:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b01:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b06:	83 e8 08             	sub    $0x8,%eax
80103b09:	c7 00 44 3a 10 80    	movl   $0x80103a44,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b0f:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
80103b14:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b1d:	83 e8 0c             	sub    $0xc,%eax
80103b20:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b25:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2e:	0f b6 00             	movzbl (%eax),%eax
80103b31:	0f b6 c0             	movzbl %al,%eax
80103b34:	83 ec 08             	sub    $0x8,%esp
80103b37:	52                   	push   %edx
80103b38:	50                   	push   %eax
80103b39:	e8 08 f6 ff ff       	call   80103146 <lapicstartap>
80103b3e:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103b41:	90                   	nop
80103b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b45:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103b4b:	85 c0                	test   %eax,%eax
80103b4d:	74 f3                	je     80103b42 <startothers+0x95>
80103b4f:	eb 01                	jmp    80103b52 <startothers+0xa5>
      continue;
80103b51:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103b52:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103b59:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
80103b5e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b64:	05 00 af 11 80       	add    $0x8011af00,%eax
80103b69:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b6c:	0f 82 6e ff ff ff    	jb     80103ae0 <startothers+0x33>
      ;
  }
}
80103b72:	90                   	nop
80103b73:	90                   	nop
80103b74:	c9                   	leave  
80103b75:	c3                   	ret    

80103b76 <outb>:
{
80103b76:	55                   	push   %ebp
80103b77:	89 e5                	mov    %esp,%ebp
80103b79:	83 ec 08             	sub    $0x8,%esp
80103b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b82:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103b86:	89 d0                	mov    %edx,%eax
80103b88:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b8b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b8f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b93:	ee                   	out    %al,(%dx)
}
80103b94:	90                   	nop
80103b95:	c9                   	leave  
80103b96:	c3                   	ret    

80103b97 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103b97:	f3 0f 1e fb          	endbr32 
80103b9b:	55                   	push   %ebp
80103b9c:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103b9e:	68 ff 00 00 00       	push   $0xff
80103ba3:	6a 21                	push   $0x21
80103ba5:	e8 cc ff ff ff       	call   80103b76 <outb>
80103baa:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103bad:	68 ff 00 00 00       	push   $0xff
80103bb2:	68 a1 00 00 00       	push   $0xa1
80103bb7:	e8 ba ff ff ff       	call   80103b76 <outb>
80103bbc:	83 c4 08             	add    $0x8,%esp
}
80103bbf:	90                   	nop
80103bc0:	c9                   	leave  
80103bc1:	c3                   	ret    

80103bc2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103bc2:	f3 0f 1e fb          	endbr32 
80103bc6:	55                   	push   %ebp
80103bc7:	89 e5                	mov    %esp,%ebp
80103bc9:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103bcc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bd6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bdf:	8b 10                	mov    (%eax),%edx
80103be1:	8b 45 08             	mov    0x8(%ebp),%eax
80103be4:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103be6:	e8 38 d4 ff ff       	call   80101023 <filealloc>
80103beb:	8b 55 08             	mov    0x8(%ebp),%edx
80103bee:	89 02                	mov    %eax,(%edx)
80103bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf3:	8b 00                	mov    (%eax),%eax
80103bf5:	85 c0                	test   %eax,%eax
80103bf7:	0f 84 c8 00 00 00    	je     80103cc5 <pipealloc+0x103>
80103bfd:	e8 21 d4 ff ff       	call   80101023 <filealloc>
80103c02:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c05:	89 02                	mov    %eax,(%edx)
80103c07:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c0a:	8b 00                	mov    (%eax),%eax
80103c0c:	85 c0                	test   %eax,%eax
80103c0e:	0f 84 b1 00 00 00    	je     80103cc5 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c14:	e8 71 f1 ff ff       	call   80102d8a <kalloc>
80103c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c20:	0f 84 a2 00 00 00    	je     80103cc8 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80103c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c29:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103c30:	00 00 00 
  p->writeopen = 1;
80103c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c36:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103c3d:	00 00 00 
  p->nwrite = 0;
80103c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c43:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103c4a:	00 00 00 
  p->nread = 0;
80103c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c50:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103c57:	00 00 00 
  initlock(&p->lock, "pipe");
80103c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5d:	83 ec 08             	sub    $0x8,%esp
80103c60:	68 ad af 10 80       	push   $0x8010afad
80103c65:	50                   	push   %eax
80103c66:	e8 87 15 00 00       	call   801051f2 <initlock>
80103c6b:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c71:	8b 00                	mov    (%eax),%eax
80103c73:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103c79:	8b 45 08             	mov    0x8(%ebp),%eax
80103c7c:	8b 00                	mov    (%eax),%eax
80103c7e:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103c82:	8b 45 08             	mov    0x8(%ebp),%eax
80103c85:	8b 00                	mov    (%eax),%eax
80103c87:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8e:	8b 00                	mov    (%eax),%eax
80103c90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c93:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103c96:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c99:	8b 00                	mov    (%eax),%eax
80103c9b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ca4:	8b 00                	mov    (%eax),%eax
80103ca6:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103caa:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cad:	8b 00                	mov    (%eax),%eax
80103caf:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cb6:	8b 00                	mov    (%eax),%eax
80103cb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cbb:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103cbe:	b8 00 00 00 00       	mov    $0x0,%eax
80103cc3:	eb 51                	jmp    80103d16 <pipealloc+0x154>
    goto bad;
80103cc5:	90                   	nop
80103cc6:	eb 01                	jmp    80103cc9 <pipealloc+0x107>
    goto bad;
80103cc8:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103cc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ccd:	74 0e                	je     80103cdd <pipealloc+0x11b>
    kfree((char*)p);
80103ccf:	83 ec 0c             	sub    $0xc,%esp
80103cd2:	ff 75 f4             	pushl  -0xc(%ebp)
80103cd5:	e8 12 f0 ff ff       	call   80102cec <kfree>
80103cda:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce0:	8b 00                	mov    (%eax),%eax
80103ce2:	85 c0                	test   %eax,%eax
80103ce4:	74 11                	je     80103cf7 <pipealloc+0x135>
    fileclose(*f0);
80103ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ce9:	8b 00                	mov    (%eax),%eax
80103ceb:	83 ec 0c             	sub    $0xc,%esp
80103cee:	50                   	push   %eax
80103cef:	e8 f5 d3 ff ff       	call   801010e9 <fileclose>
80103cf4:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cfa:	8b 00                	mov    (%eax),%eax
80103cfc:	85 c0                	test   %eax,%eax
80103cfe:	74 11                	je     80103d11 <pipealloc+0x14f>
    fileclose(*f1);
80103d00:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d03:	8b 00                	mov    (%eax),%eax
80103d05:	83 ec 0c             	sub    $0xc,%esp
80103d08:	50                   	push   %eax
80103d09:	e8 db d3 ff ff       	call   801010e9 <fileclose>
80103d0e:	83 c4 10             	add    $0x10,%esp
  return -1;
80103d11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d16:	c9                   	leave  
80103d17:	c3                   	ret    

80103d18 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d18:	f3 0f 1e fb          	endbr32 
80103d1c:	55                   	push   %ebp
80103d1d:	89 e5                	mov    %esp,%ebp
80103d1f:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103d22:	8b 45 08             	mov    0x8(%ebp),%eax
80103d25:	83 ec 0c             	sub    $0xc,%esp
80103d28:	50                   	push   %eax
80103d29:	e8 ea 14 00 00       	call   80105218 <acquire>
80103d2e:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103d31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d35:	74 23                	je     80103d5a <pipeclose+0x42>
    p->writeopen = 0;
80103d37:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3a:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d41:	00 00 00 
    wakeup(&p->nread);
80103d44:	8b 45 08             	mov    0x8(%ebp),%eax
80103d47:	05 34 02 00 00       	add    $0x234,%eax
80103d4c:	83 ec 0c             	sub    $0xc,%esp
80103d4f:	50                   	push   %eax
80103d50:	e8 d5 0f 00 00       	call   80104d2a <wakeup>
80103d55:	83 c4 10             	add    $0x10,%esp
80103d58:	eb 21                	jmp    80103d7b <pipeclose+0x63>
  } else {
    p->readopen = 0;
80103d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5d:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103d64:	00 00 00 
    wakeup(&p->nwrite);
80103d67:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6a:	05 38 02 00 00       	add    $0x238,%eax
80103d6f:	83 ec 0c             	sub    $0xc,%esp
80103d72:	50                   	push   %eax
80103d73:	e8 b2 0f 00 00       	call   80104d2a <wakeup>
80103d78:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d7e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103d84:	85 c0                	test   %eax,%eax
80103d86:	75 2c                	jne    80103db4 <pipeclose+0x9c>
80103d88:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103d91:	85 c0                	test   %eax,%eax
80103d93:	75 1f                	jne    80103db4 <pipeclose+0x9c>
    release(&p->lock);
80103d95:	8b 45 08             	mov    0x8(%ebp),%eax
80103d98:	83 ec 0c             	sub    $0xc,%esp
80103d9b:	50                   	push   %eax
80103d9c:	e8 e9 14 00 00       	call   8010528a <release>
80103da1:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103da4:	83 ec 0c             	sub    $0xc,%esp
80103da7:	ff 75 08             	pushl  0x8(%ebp)
80103daa:	e8 3d ef ff ff       	call   80102cec <kfree>
80103daf:	83 c4 10             	add    $0x10,%esp
80103db2:	eb 10                	jmp    80103dc4 <pipeclose+0xac>
  } else
    release(&p->lock);
80103db4:	8b 45 08             	mov    0x8(%ebp),%eax
80103db7:	83 ec 0c             	sub    $0xc,%esp
80103dba:	50                   	push   %eax
80103dbb:	e8 ca 14 00 00       	call   8010528a <release>
80103dc0:	83 c4 10             	add    $0x10,%esp
}
80103dc3:	90                   	nop
80103dc4:	90                   	nop
80103dc5:	c9                   	leave  
80103dc6:	c3                   	ret    

80103dc7 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103dc7:	f3 0f 1e fb          	endbr32 
80103dcb:	55                   	push   %ebp
80103dcc:	89 e5                	mov    %esp,%ebp
80103dce:	53                   	push   %ebx
80103dcf:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd5:	83 ec 0c             	sub    $0xc,%esp
80103dd8:	50                   	push   %eax
80103dd9:	e8 3a 14 00 00       	call   80105218 <acquire>
80103dde:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103de1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103de8:	e9 ad 00 00 00       	jmp    80103e9a <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103ded:	8b 45 08             	mov    0x8(%ebp),%eax
80103df0:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103df6:	85 c0                	test   %eax,%eax
80103df8:	74 0c                	je     80103e06 <pipewrite+0x3f>
80103dfa:	e8 a2 02 00 00       	call   801040a1 <myproc>
80103dff:	8b 40 24             	mov    0x24(%eax),%eax
80103e02:	85 c0                	test   %eax,%eax
80103e04:	74 19                	je     80103e1f <pipewrite+0x58>
        release(&p->lock);
80103e06:	8b 45 08             	mov    0x8(%ebp),%eax
80103e09:	83 ec 0c             	sub    $0xc,%esp
80103e0c:	50                   	push   %eax
80103e0d:	e8 78 14 00 00       	call   8010528a <release>
80103e12:	83 c4 10             	add    $0x10,%esp
        return -1;
80103e15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e1a:	e9 a9 00 00 00       	jmp    80103ec8 <pipewrite+0x101>
      }
      wakeup(&p->nread);
80103e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e22:	05 34 02 00 00       	add    $0x234,%eax
80103e27:	83 ec 0c             	sub    $0xc,%esp
80103e2a:	50                   	push   %eax
80103e2b:	e8 fa 0e 00 00       	call   80104d2a <wakeup>
80103e30:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e33:	8b 45 08             	mov    0x8(%ebp),%eax
80103e36:	8b 55 08             	mov    0x8(%ebp),%edx
80103e39:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e3f:	83 ec 08             	sub    $0x8,%esp
80103e42:	50                   	push   %eax
80103e43:	52                   	push   %edx
80103e44:	e8 ef 0d 00 00       	call   80104c38 <sleep>
80103e49:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4f:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e55:	8b 45 08             	mov    0x8(%ebp),%eax
80103e58:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e5e:	05 00 02 00 00       	add    $0x200,%eax
80103e63:	39 c2                	cmp    %eax,%edx
80103e65:	74 86                	je     80103ded <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103e67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e6d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103e70:	8b 45 08             	mov    0x8(%ebp),%eax
80103e73:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103e79:	8d 48 01             	lea    0x1(%eax),%ecx
80103e7c:	8b 55 08             	mov    0x8(%ebp),%edx
80103e7f:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103e85:	25 ff 01 00 00       	and    $0x1ff,%eax
80103e8a:	89 c1                	mov    %eax,%ecx
80103e8c:	0f b6 13             	movzbl (%ebx),%edx
80103e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e92:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103e96:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e9d:	3b 45 10             	cmp    0x10(%ebp),%eax
80103ea0:	7c aa                	jl     80103e4c <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea5:	05 34 02 00 00       	add    $0x234,%eax
80103eaa:	83 ec 0c             	sub    $0xc,%esp
80103ead:	50                   	push   %eax
80103eae:	e8 77 0e 00 00       	call   80104d2a <wakeup>
80103eb3:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103eb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb9:	83 ec 0c             	sub    $0xc,%esp
80103ebc:	50                   	push   %eax
80103ebd:	e8 c8 13 00 00       	call   8010528a <release>
80103ec2:	83 c4 10             	add    $0x10,%esp
  return n;
80103ec5:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103ec8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103ecb:	c9                   	leave  
80103ecc:	c3                   	ret    

80103ecd <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103ecd:	f3 0f 1e fb          	endbr32 
80103ed1:	55                   	push   %ebp
80103ed2:	89 e5                	mov    %esp,%ebp
80103ed4:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80103eda:	83 ec 0c             	sub    $0xc,%esp
80103edd:	50                   	push   %eax
80103ede:	e8 35 13 00 00       	call   80105218 <acquire>
80103ee3:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103ee6:	eb 3e                	jmp    80103f26 <piperead+0x59>
    if(myproc()->killed){
80103ee8:	e8 b4 01 00 00       	call   801040a1 <myproc>
80103eed:	8b 40 24             	mov    0x24(%eax),%eax
80103ef0:	85 c0                	test   %eax,%eax
80103ef2:	74 19                	je     80103f0d <piperead+0x40>
      release(&p->lock);
80103ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef7:	83 ec 0c             	sub    $0xc,%esp
80103efa:	50                   	push   %eax
80103efb:	e8 8a 13 00 00       	call   8010528a <release>
80103f00:	83 c4 10             	add    $0x10,%esp
      return -1;
80103f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f08:	e9 be 00 00 00       	jmp    80103fcb <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f10:	8b 55 08             	mov    0x8(%ebp),%edx
80103f13:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f19:	83 ec 08             	sub    $0x8,%esp
80103f1c:	50                   	push   %eax
80103f1d:	52                   	push   %edx
80103f1e:	e8 15 0d 00 00       	call   80104c38 <sleep>
80103f23:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f26:	8b 45 08             	mov    0x8(%ebp),%eax
80103f29:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f32:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f38:	39 c2                	cmp    %eax,%edx
80103f3a:	75 0d                	jne    80103f49 <piperead+0x7c>
80103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f45:	85 c0                	test   %eax,%eax
80103f47:	75 9f                	jne    80103ee8 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f50:	eb 48                	jmp    80103f9a <piperead+0xcd>
    if(p->nread == p->nwrite)
80103f52:	8b 45 08             	mov    0x8(%ebp),%eax
80103f55:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f64:	39 c2                	cmp    %eax,%edx
80103f66:	74 3c                	je     80103fa4 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f68:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6b:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f71:	8d 48 01             	lea    0x1(%eax),%ecx
80103f74:	8b 55 08             	mov    0x8(%ebp),%edx
80103f77:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103f7d:	25 ff 01 00 00       	and    $0x1ff,%eax
80103f82:	89 c1                	mov    %eax,%ecx
80103f84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f87:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f8a:	01 c2                	add    %eax,%edx
80103f8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8f:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103f94:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f96:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9d:	3b 45 10             	cmp    0x10(%ebp),%eax
80103fa0:	7c b0                	jl     80103f52 <piperead+0x85>
80103fa2:	eb 01                	jmp    80103fa5 <piperead+0xd8>
      break;
80103fa4:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa8:	05 38 02 00 00       	add    $0x238,%eax
80103fad:	83 ec 0c             	sub    $0xc,%esp
80103fb0:	50                   	push   %eax
80103fb1:	e8 74 0d 00 00       	call   80104d2a <wakeup>
80103fb6:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbc:	83 ec 0c             	sub    $0xc,%esp
80103fbf:	50                   	push   %eax
80103fc0:	e8 c5 12 00 00       	call   8010528a <release>
80103fc5:	83 c4 10             	add    $0x10,%esp
  return i;
80103fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103fcb:	c9                   	leave  
80103fcc:	c3                   	ret    

80103fcd <readeflags>:
{
80103fcd:	55                   	push   %ebp
80103fce:	89 e5                	mov    %esp,%ebp
80103fd0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103fd3:	9c                   	pushf  
80103fd4:	58                   	pop    %eax
80103fd5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103fd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103fdb:	c9                   	leave  
80103fdc:	c3                   	ret    

80103fdd <sti>:
{
80103fdd:	55                   	push   %ebp
80103fde:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103fe0:	fb                   	sti    
}
80103fe1:	90                   	nop
80103fe2:	5d                   	pop    %ebp
80103fe3:	c3                   	ret    

80103fe4 <pinit>:
extern void trapret(void);
static void wakeup1(void *chan);

void
pinit(void)
{
80103fe4:	f3 0f 1e fb          	endbr32 
80103fe8:	55                   	push   %ebp
80103fe9:	89 e5                	mov    %esp,%ebp
80103feb:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103fee:	83 ec 08             	sub    $0x8,%esp
80103ff1:	68 b4 af 10 80       	push   $0x8010afb4
80103ff6:	68 40 85 11 80       	push   $0x80118540
80103ffb:	e8 f2 11 00 00       	call   801051f2 <initlock>
80104000:	83 c4 10             	add    $0x10,%esp
}
80104003:	90                   	nop
80104004:	c9                   	leave  
80104005:	c3                   	ret    

80104006 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104006:	f3 0f 1e fb          	endbr32 
8010400a:	55                   	push   %ebp
8010400b:	89 e5                	mov    %esp,%ebp
8010400d:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104010:	e8 10 00 00 00       	call   80104025 <mycpu>
80104015:	2d 00 af 11 80       	sub    $0x8011af00,%eax
8010401a:	c1 f8 04             	sar    $0x4,%eax
8010401d:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80104023:	c9                   	leave  
80104024:	c3                   	ret    

80104025 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104025:	f3 0f 1e fb          	endbr32 
80104029:	55                   	push   %ebp
8010402a:	89 e5                	mov    %esp,%ebp
8010402c:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
8010402f:	e8 99 ff ff ff       	call   80103fcd <readeflags>
80104034:	25 00 02 00 00       	and    $0x200,%eax
80104039:	85 c0                	test   %eax,%eax
8010403b:	74 0d                	je     8010404a <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
8010403d:	83 ec 0c             	sub    $0xc,%esp
80104040:	68 bc af 10 80       	push   $0x8010afbc
80104045:	e8 7b c5 ff ff       	call   801005c5 <panic>
  }

  apicid = lapicid();
8010404a:	e8 a8 f0 ff ff       	call   801030f7 <lapicid>
8010404f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104052:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104059:	eb 2d                	jmp    80104088 <mycpu+0x63>
    if (cpus[i].apicid == apicid){
8010405b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80104064:	05 00 af 11 80       	add    $0x8011af00,%eax
80104069:	0f b6 00             	movzbl (%eax),%eax
8010406c:	0f b6 c0             	movzbl %al,%eax
8010406f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104072:	75 10                	jne    80104084 <mycpu+0x5f>
      return &cpus[i];
80104074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104077:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010407d:	05 00 af 11 80       	add    $0x8011af00,%eax
80104082:	eb 1b                	jmp    8010409f <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80104084:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104088:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
8010408d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104090:	7c c9                	jl     8010405b <mycpu+0x36>
    }
  }
  panic("unknown apicid\n");
80104092:	83 ec 0c             	sub    $0xc,%esp
80104095:	68 e2 af 10 80       	push   $0x8010afe2
8010409a:	e8 26 c5 ff ff       	call   801005c5 <panic>
}
8010409f:	c9                   	leave  
801040a0:	c3                   	ret    

801040a1 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801040a1:	f3 0f 1e fb          	endbr32 
801040a5:	55                   	push   %ebp
801040a6:	89 e5                	mov    %esp,%ebp
801040a8:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801040ab:	e8 e4 12 00 00       	call   80105394 <pushcli>
  c = mycpu();
801040b0:	e8 70 ff ff ff       	call   80104025 <mycpu>
801040b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801040b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bb:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801040c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801040c4:	e8 1c 13 00 00       	call   801053e5 <popcli>
  return p;
801040c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801040cc:	c9                   	leave  
801040cd:	c3                   	ret    

801040ce <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801040ce:	f3 0f 1e fb          	endbr32 
801040d2:	55                   	push   %ebp
801040d3:	89 e5                	mov    %esp,%ebp
801040d5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801040d8:	83 ec 0c             	sub    $0xc,%esp
801040db:	68 40 85 11 80       	push   $0x80118540
801040e0:	e8 33 11 00 00       	call   80105218 <acquire>
801040e5:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040e8:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801040ef:	eb 11                	jmp    80104102 <allocproc+0x34>
    if(p->state == UNUSED){
801040f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f4:	8b 40 0c             	mov    0xc(%eax),%eax
801040f7:	85 c0                	test   %eax,%eax
801040f9:	74 2a                	je     80104125 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040fb:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104102:	81 7d f4 74 a6 11 80 	cmpl   $0x8011a674,-0xc(%ebp)
80104109:	72 e6                	jb     801040f1 <allocproc+0x23>
      goto found;
    }

  release(&ptable.lock);
8010410b:	83 ec 0c             	sub    $0xc,%esp
8010410e:	68 40 85 11 80       	push   $0x80118540
80104113:	e8 72 11 00 00       	call   8010528a <release>
80104118:	83 c4 10             	add    $0x10,%esp
  return 0;
8010411b:	b8 00 00 00 00       	mov    $0x0,%eax
80104120:	e9 c3 00 00 00       	jmp    801041e8 <allocproc+0x11a>
      goto found;
80104125:	90                   	nop
80104126:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
8010412a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412d:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104134:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80104139:	8d 50 01             	lea    0x1(%eax),%edx
8010413c:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80104142:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104145:	89 42 10             	mov    %eax,0x10(%edx)

  p->scheduler = 0; //사용자 수준 스케줄러 필드를 0으로 설정, 초기화
80104148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104152:	00 00 00 

  release(&ptable.lock);
80104155:	83 ec 0c             	sub    $0xc,%esp
80104158:	68 40 85 11 80       	push   $0x80118540
8010415d:	e8 28 11 00 00       	call   8010528a <release>
80104162:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104165:	e8 20 ec ff ff       	call   80102d8a <kalloc>
8010416a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010416d:	89 42 08             	mov    %eax,0x8(%edx)
80104170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104173:	8b 40 08             	mov    0x8(%eax),%eax
80104176:	85 c0                	test   %eax,%eax
80104178:	75 11                	jne    8010418b <allocproc+0xbd>
    p->state = UNUSED;
8010417a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104184:	b8 00 00 00 00       	mov    $0x0,%eax
80104189:	eb 5d                	jmp    801041e8 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
8010418b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418e:	8b 40 08             	mov    0x8(%eax),%eax
80104191:	05 00 10 00 00       	add    $0x1000,%eax
80104196:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104199:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010419d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041a3:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801041a6:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801041aa:	ba c2 69 10 80       	mov    $0x801069c2,%edx
801041af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041b2:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801041b4:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801041b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801041be:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801041c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c4:	8b 40 1c             	mov    0x1c(%eax),%eax
801041c7:	83 ec 04             	sub    $0x4,%esp
801041ca:	6a 14                	push   $0x14
801041cc:	6a 00                	push   $0x0
801041ce:	50                   	push   %eax
801041cf:	e8 d3 12 00 00       	call   801054a7 <memset>
801041d4:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801041d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041da:	8b 40 1c             	mov    0x1c(%eax),%eax
801041dd:	ba ee 4b 10 80       	mov    $0x80104bee,%edx
801041e2:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801041e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801041e8:	c9                   	leave  
801041e9:	c3                   	ret    

801041ea <userinit>:
void printpt(int pid);
//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801041ea:	f3 0f 1e fb          	endbr32 
801041ee:	55                   	push   %ebp
801041ef:	89 e5                	mov    %esp,%ebp
801041f1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801041f4:	e8 d5 fe ff ff       	call   801040ce <allocproc>
801041f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801041fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ff:	a3 a0 00 11 80       	mov    %eax,0x801100a0
  if((p->pgdir = setupkvm()) == 0){
80104204:	e8 81 3d 00 00       	call   80107f8a <setupkvm>
80104209:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010420c:	89 42 04             	mov    %eax,0x4(%edx)
8010420f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104212:	8b 40 04             	mov    0x4(%eax),%eax
80104215:	85 c0                	test   %eax,%eax
80104217:	75 0d                	jne    80104226 <userinit+0x3c>
    panic("userinit: out of memory?");
80104219:	83 ec 0c             	sub    $0xc,%esp
8010421c:	68 f2 af 10 80       	push   $0x8010aff2
80104221:	e8 9f c3 ff ff       	call   801005c5 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104226:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010422b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422e:	8b 40 04             	mov    0x4(%eax),%eax
80104231:	83 ec 04             	sub    $0x4,%esp
80104234:	52                   	push   %edx
80104235:	68 0c f5 10 80       	push   $0x8010f50c
8010423a:	50                   	push   %eax
8010423b:	e8 17 40 00 00       	call   80108257 <inituvm>
80104240:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104246:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010424c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424f:	8b 40 18             	mov    0x18(%eax),%eax
80104252:	83 ec 04             	sub    $0x4,%esp
80104255:	6a 4c                	push   $0x4c
80104257:	6a 00                	push   $0x0
80104259:	50                   	push   %eax
8010425a:	e8 48 12 00 00       	call   801054a7 <memset>
8010425f:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104265:	8b 40 18             	mov    0x18(%eax),%eax
80104268:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010426e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104271:	8b 40 18             	mov    0x18(%eax),%eax
80104274:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010427a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427d:	8b 50 18             	mov    0x18(%eax),%edx
80104280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104283:	8b 40 18             	mov    0x18(%eax),%eax
80104286:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010428a:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010428e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104291:	8b 50 18             	mov    0x18(%eax),%edx
80104294:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104297:	8b 40 18             	mov    0x18(%eax),%eax
8010429a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010429e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801042a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a5:	8b 40 18             	mov    0x18(%eax),%eax
801042a8:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801042af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b2:	8b 40 18             	mov    0x18(%eax),%eax
801042b5:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801042bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042bf:	8b 40 18             	mov    0x18(%eax),%eax
801042c2:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801042c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cc:	83 c0 6c             	add    $0x6c,%eax
801042cf:	83 ec 04             	sub    $0x4,%esp
801042d2:	6a 10                	push   $0x10
801042d4:	68 0b b0 10 80       	push   $0x8010b00b
801042d9:	50                   	push   %eax
801042da:	e8 e3 13 00 00       	call   801056c2 <safestrcpy>
801042df:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801042e2:	83 ec 0c             	sub    $0xc,%esp
801042e5:	68 14 b0 10 80       	push   $0x8010b014
801042ea:	e8 f8 e2 ff ff       	call   801025e7 <namei>
801042ef:	83 c4 10             	add    $0x10,%esp
801042f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042f5:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801042f8:	83 ec 0c             	sub    $0xc,%esp
801042fb:	68 40 85 11 80       	push   $0x80118540
80104300:	e8 13 0f 00 00       	call   80105218 <acquire>
80104305:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104312:	83 ec 0c             	sub    $0xc,%esp
80104315:	68 40 85 11 80       	push   $0x80118540
8010431a:	e8 6b 0f 00 00       	call   8010528a <release>
8010431f:	83 c4 10             	add    $0x10,%esp
}
80104322:	90                   	nop
80104323:	c9                   	leave  
80104324:	c3                   	ret    

80104325 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104325:	f3 0f 1e fb          	endbr32 
80104329:	55                   	push   %ebp
8010432a:	89 e5                	mov    %esp,%ebp
8010432c:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010432f:	e8 6d fd ff ff       	call   801040a1 <myproc>
80104334:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010433a:	8b 00                	mov    (%eax),%eax
8010433c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010433f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104343:	7e 2e                	jle    80104373 <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104345:	8b 55 08             	mov    0x8(%ebp),%edx
80104348:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434b:	01 c2                	add    %eax,%edx
8010434d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104350:	8b 40 04             	mov    0x4(%eax),%eax
80104353:	83 ec 04             	sub    $0x4,%esp
80104356:	52                   	push   %edx
80104357:	ff 75 f4             	pushl  -0xc(%ebp)
8010435a:	50                   	push   %eax
8010435b:	e8 3c 40 00 00       	call   8010839c <allocuvm>
80104360:	83 c4 10             	add    $0x10,%esp
80104363:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104366:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010436a:	75 3b                	jne    801043a7 <growproc+0x82>
      return -1;
8010436c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104371:	eb 4f                	jmp    801043c2 <growproc+0x9d>
  } else if(n < 0){
80104373:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104377:	79 2e                	jns    801043a7 <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104379:	8b 55 08             	mov    0x8(%ebp),%edx
8010437c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437f:	01 c2                	add    %eax,%edx
80104381:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104384:	8b 40 04             	mov    0x4(%eax),%eax
80104387:	83 ec 04             	sub    $0x4,%esp
8010438a:	52                   	push   %edx
8010438b:	ff 75 f4             	pushl  -0xc(%ebp)
8010438e:	50                   	push   %eax
8010438f:	e8 11 41 00 00       	call   801084a5 <deallocuvm>
80104394:	83 c4 10             	add    $0x10,%esp
80104397:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010439a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010439e:	75 07                	jne    801043a7 <growproc+0x82>
      return -1;
801043a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043a5:	eb 1b                	jmp    801043c2 <growproc+0x9d>
  }
  curproc->sz = sz;
801043a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ad:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801043af:	83 ec 0c             	sub    $0xc,%esp
801043b2:	ff 75 f0             	pushl  -0x10(%ebp)
801043b5:	e8 fa 3c 00 00       	call   801080b4 <switchuvm>
801043ba:	83 c4 10             	add    $0x10,%esp
  return 0;
801043bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043c2:	c9                   	leave  
801043c3:	c3                   	ret    

801043c4 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801043c4:	f3 0f 1e fb          	endbr32 
801043c8:	55                   	push   %ebp
801043c9:	89 e5                	mov    %esp,%ebp
801043cb:	57                   	push   %edi
801043cc:	56                   	push   %esi
801043cd:	53                   	push   %ebx
801043ce:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801043d1:	e8 cb fc ff ff       	call   801040a1 <myproc>
801043d6:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801043d9:	e8 f0 fc ff ff       	call   801040ce <allocproc>
801043de:	89 45 dc             	mov    %eax,-0x24(%ebp)
801043e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801043e5:	75 0a                	jne    801043f1 <fork+0x2d>
    return -1;
801043e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043ec:	e9 48 01 00 00       	jmp    80104539 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801043f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043f4:	8b 10                	mov    (%eax),%edx
801043f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043f9:	8b 40 04             	mov    0x4(%eax),%eax
801043fc:	83 ec 08             	sub    $0x8,%esp
801043ff:	52                   	push   %edx
80104400:	50                   	push   %eax
80104401:	e8 49 42 00 00       	call   8010864f <copyuvm>
80104406:	83 c4 10             	add    $0x10,%esp
80104409:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010440c:	89 42 04             	mov    %eax,0x4(%edx)
8010440f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104412:	8b 40 04             	mov    0x4(%eax),%eax
80104415:	85 c0                	test   %eax,%eax
80104417:	75 30                	jne    80104449 <fork+0x85>
    kfree(np->kstack);
80104419:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010441c:	8b 40 08             	mov    0x8(%eax),%eax
8010441f:	83 ec 0c             	sub    $0xc,%esp
80104422:	50                   	push   %eax
80104423:	e8 c4 e8 ff ff       	call   80102cec <kfree>
80104428:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010442b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010442e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104435:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104438:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010443f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104444:	e9 f0 00 00 00       	jmp    80104539 <fork+0x175>
  }
  np->sz = curproc->sz;
80104449:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010444c:	8b 10                	mov    (%eax),%edx
8010444e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104451:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104453:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104456:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104459:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010445c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010445f:	8b 48 18             	mov    0x18(%eax),%ecx
80104462:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104465:	8b 40 18             	mov    0x18(%eax),%eax
80104468:	89 c2                	mov    %eax,%edx
8010446a:	89 cb                	mov    %ecx,%ebx
8010446c:	b8 13 00 00 00       	mov    $0x13,%eax
80104471:	89 d7                	mov    %edx,%edi
80104473:	89 de                	mov    %ebx,%esi
80104475:	89 c1                	mov    %eax,%ecx
80104477:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104479:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010447c:	8b 40 18             	mov    0x18(%eax),%eax
8010447f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104486:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010448d:	eb 3b                	jmp    801044ca <fork+0x106>
    if(curproc->ofile[i])
8010448f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104492:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104495:	83 c2 08             	add    $0x8,%edx
80104498:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010449c:	85 c0                	test   %eax,%eax
8010449e:	74 26                	je     801044c6 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
801044a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801044a6:	83 c2 08             	add    $0x8,%edx
801044a9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044ad:	83 ec 0c             	sub    $0xc,%esp
801044b0:	50                   	push   %eax
801044b1:	e8 de cb ff ff       	call   80101094 <filedup>
801044b6:	83 c4 10             	add    $0x10,%esp
801044b9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044bc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801044bf:	83 c1 08             	add    $0x8,%ecx
801044c2:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801044c6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801044ca:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801044ce:	7e bf                	jle    8010448f <fork+0xcb>
  np->cwd = idup(curproc->cwd);
801044d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044d3:	8b 40 68             	mov    0x68(%eax),%eax
801044d6:	83 ec 0c             	sub    $0xc,%esp
801044d9:	50                   	push   %eax
801044da:	e8 5f d5 ff ff       	call   80101a3e <idup>
801044df:	83 c4 10             	add    $0x10,%esp
801044e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044e5:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801044e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044eb:	8d 50 6c             	lea    0x6c(%eax),%edx
801044ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044f1:	83 c0 6c             	add    $0x6c,%eax
801044f4:	83 ec 04             	sub    $0x4,%esp
801044f7:	6a 10                	push   $0x10
801044f9:	52                   	push   %edx
801044fa:	50                   	push   %eax
801044fb:	e8 c2 11 00 00       	call   801056c2 <safestrcpy>
80104500:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104503:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104506:	8b 40 10             	mov    0x10(%eax),%eax
80104509:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010450c:	83 ec 0c             	sub    $0xc,%esp
8010450f:	68 40 85 11 80       	push   $0x80118540
80104514:	e8 ff 0c 00 00       	call   80105218 <acquire>
80104519:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010451c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010451f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104526:	83 ec 0c             	sub    $0xc,%esp
80104529:	68 40 85 11 80       	push   $0x80118540
8010452e:	e8 57 0d 00 00       	call   8010528a <release>
80104533:	83 c4 10             	add    $0x10,%esp

  return pid;
80104536:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104539:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010453c:	5b                   	pop    %ebx
8010453d:	5e                   	pop    %esi
8010453e:	5f                   	pop    %edi
8010453f:	5d                   	pop    %ebp
80104540:	c3                   	ret    

80104541 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104541:	f3 0f 1e fb          	endbr32 
80104545:	55                   	push   %ebp
80104546:	89 e5                	mov    %esp,%ebp
80104548:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010454b:	e8 51 fb ff ff       	call   801040a1 <myproc>
80104550:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104553:	a1 a0 00 11 80       	mov    0x801100a0,%eax
80104558:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010455b:	75 0d                	jne    8010456a <exit+0x29>
    panic("init exiting");
8010455d:	83 ec 0c             	sub    $0xc,%esp
80104560:	68 16 b0 10 80       	push   $0x8010b016
80104565:	e8 5b c0 ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010456a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104571:	eb 3f                	jmp    801045b2 <exit+0x71>
    if(curproc->ofile[fd]){
80104573:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104576:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104579:	83 c2 08             	add    $0x8,%edx
8010457c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104580:	85 c0                	test   %eax,%eax
80104582:	74 2a                	je     801045ae <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104584:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104587:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010458a:	83 c2 08             	add    $0x8,%edx
8010458d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104591:	83 ec 0c             	sub    $0xc,%esp
80104594:	50                   	push   %eax
80104595:	e8 4f cb ff ff       	call   801010e9 <fileclose>
8010459a:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
8010459d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045a3:	83 c2 08             	add    $0x8,%edx
801045a6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801045ad:	00 
  for(fd = 0; fd < NOFILE; fd++){
801045ae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801045b2:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801045b6:	7e bb                	jle    80104573 <exit+0x32>
    }
  }

  begin_op();
801045b8:	e8 ac f0 ff ff       	call   80103669 <begin_op>
  iput(curproc->cwd);
801045bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045c0:	8b 40 68             	mov    0x68(%eax),%eax
801045c3:	83 ec 0c             	sub    $0xc,%esp
801045c6:	50                   	push   %eax
801045c7:	e8 19 d6 ff ff       	call   80101be5 <iput>
801045cc:	83 c4 10             	add    $0x10,%esp
  end_op();
801045cf:	e8 25 f1 ff ff       	call   801036f9 <end_op>
  curproc->cwd = 0;
801045d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045d7:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801045de:	83 ec 0c             	sub    $0xc,%esp
801045e1:	68 40 85 11 80       	push   $0x80118540
801045e6:	e8 2d 0c 00 00       	call   80105218 <acquire>
801045eb:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801045ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045f1:	8b 40 14             	mov    0x14(%eax),%eax
801045f4:	83 ec 0c             	sub    $0xc,%esp
801045f7:	50                   	push   %eax
801045f8:	e8 e6 06 00 00       	call   80104ce3 <wakeup1>
801045fd:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104600:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104607:	eb 3a                	jmp    80104643 <exit+0x102>
    if(p->parent == curproc){
80104609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460c:	8b 40 14             	mov    0x14(%eax),%eax
8010460f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104612:	75 28                	jne    8010463c <exit+0xfb>
      p->parent = initproc;
80104614:	8b 15 a0 00 11 80    	mov    0x801100a0,%edx
8010461a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461d:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104623:	8b 40 0c             	mov    0xc(%eax),%eax
80104626:	83 f8 05             	cmp    $0x5,%eax
80104629:	75 11                	jne    8010463c <exit+0xfb>
        wakeup1(initproc);
8010462b:	a1 a0 00 11 80       	mov    0x801100a0,%eax
80104630:	83 ec 0c             	sub    $0xc,%esp
80104633:	50                   	push   %eax
80104634:	e8 aa 06 00 00       	call   80104ce3 <wakeup1>
80104639:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010463c:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104643:	81 7d f4 74 a6 11 80 	cmpl   $0x8011a674,-0xc(%ebp)
8010464a:	72 bd                	jb     80104609 <exit+0xc8>
    }
  }

  curproc->scheduler = 0; //명시적으로 scheduler 필드를 초기화
8010464c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010464f:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104656:	00 00 00 

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104659:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010465c:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104663:	e8 8b 04 00 00       	call   80104af3 <sched>
  panic("zombie exit");
80104668:	83 ec 0c             	sub    $0xc,%esp
8010466b:	68 23 b0 10 80       	push   $0x8010b023
80104670:	e8 50 bf ff ff       	call   801005c5 <panic>

80104675 <exit2>:
}

void
exit2(int status)
{
80104675:	f3 0f 1e fb          	endbr32 
80104679:	55                   	push   %ebp
8010467a:	89 e5                	mov    %esp,%ebp
8010467c:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010467f:	e8 1d fa ff ff       	call   801040a1 <myproc>
80104684:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104687:	a1 a0 00 11 80       	mov    0x801100a0,%eax
8010468c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010468f:	75 0d                	jne    8010469e <exit2+0x29>
    panic("init exiting");
80104691:	83 ec 0c             	sub    $0xc,%esp
80104694:	68 16 b0 10 80       	push   $0x8010b016
80104699:	e8 27 bf ff ff       	call   801005c5 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010469e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801046a5:	eb 3f                	jmp    801046e6 <exit2+0x71>
    if(curproc->ofile[fd]){
801046a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046ad:	83 c2 08             	add    $0x8,%edx
801046b0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046b4:	85 c0                	test   %eax,%eax
801046b6:	74 2a                	je     801046e2 <exit2+0x6d>
      fileclose(curproc->ofile[fd]);
801046b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046be:	83 c2 08             	add    $0x8,%edx
801046c1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046c5:	83 ec 0c             	sub    $0xc,%esp
801046c8:	50                   	push   %eax
801046c9:	e8 1b ca ff ff       	call   801010e9 <fileclose>
801046ce:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801046d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046d7:	83 c2 08             	add    $0x8,%edx
801046da:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801046e1:	00 
  for(fd = 0; fd < NOFILE; fd++){
801046e2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801046e6:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801046ea:	7e bb                	jle    801046a7 <exit2+0x32>
    }
  }

  begin_op();
801046ec:	e8 78 ef ff ff       	call   80103669 <begin_op>
  iput(curproc->cwd);
801046f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046f4:	8b 40 68             	mov    0x68(%eax),%eax
801046f7:	83 ec 0c             	sub    $0xc,%esp
801046fa:	50                   	push   %eax
801046fb:	e8 e5 d4 ff ff       	call   80101be5 <iput>
80104700:	83 c4 10             	add    $0x10,%esp
  end_op();
80104703:	e8 f1 ef ff ff       	call   801036f9 <end_op>
  curproc->cwd = 0;
80104708:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010470b:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104712:	83 ec 0c             	sub    $0xc,%esp
80104715:	68 40 85 11 80       	push   $0x80118540
8010471a:	e8 f9 0a 00 00       	call   80105218 <acquire>
8010471f:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104722:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104725:	8b 40 14             	mov    0x14(%eax),%eax
80104728:	83 ec 0c             	sub    $0xc,%esp
8010472b:	50                   	push   %eax
8010472c:	e8 b2 05 00 00       	call   80104ce3 <wakeup1>
80104731:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104734:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
8010473b:	eb 3a                	jmp    80104777 <exit2+0x102>
    if(p->parent == curproc){
8010473d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104740:	8b 40 14             	mov    0x14(%eax),%eax
80104743:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104746:	75 28                	jne    80104770 <exit2+0xfb>
      p->parent = initproc;
80104748:	8b 15 a0 00 11 80    	mov    0x801100a0,%edx
8010474e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104751:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104757:	8b 40 0c             	mov    0xc(%eax),%eax
8010475a:	83 f8 05             	cmp    $0x5,%eax
8010475d:	75 11                	jne    80104770 <exit2+0xfb>
        wakeup1(initproc);
8010475f:	a1 a0 00 11 80       	mov    0x801100a0,%eax
80104764:	83 ec 0c             	sub    $0xc,%esp
80104767:	50                   	push   %eax
80104768:	e8 76 05 00 00       	call   80104ce3 <wakeup1>
8010476d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104770:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104777:	81 7d f4 74 a6 11 80 	cmpl   $0x8011a674,-0xc(%ebp)
8010477e:	72 bd                	jb     8010473d <exit2+0xc8>
    }
  }

  // Set exit status and become a zombie.
  curproc->xstate = status; // Save the exit status
80104780:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104783:	8b 55 08             	mov    0x8(%ebp),%edx
80104786:	89 50 7c             	mov    %edx,0x7c(%eax)

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104789:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010478c:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104793:	e8 5b 03 00 00       	call   80104af3 <sched>
  panic("zombie exit");
80104798:	83 ec 0c             	sub    $0xc,%esp
8010479b:	68 23 b0 10 80       	push   $0x8010b023
801047a0:	e8 20 be ff ff       	call   801005c5 <panic>

801047a5 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801047a5:	f3 0f 1e fb          	endbr32 
801047a9:	55                   	push   %ebp
801047aa:	89 e5                	mov    %esp,%ebp
801047ac:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801047af:	e8 ed f8 ff ff       	call   801040a1 <myproc>
801047b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801047b7:	83 ec 0c             	sub    $0xc,%esp
801047ba:	68 40 85 11 80       	push   $0x80118540
801047bf:	e8 54 0a 00 00       	call   80105218 <acquire>
801047c4:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801047c7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047ce:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801047d5:	e9 a4 00 00 00       	jmp    8010487e <wait+0xd9>
      if(p->parent != curproc)
801047da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047dd:	8b 40 14             	mov    0x14(%eax),%eax
801047e0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801047e3:	0f 85 8d 00 00 00    	jne    80104876 <wait+0xd1>
        continue;
      havekids = 1;
801047e9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801047f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f3:	8b 40 0c             	mov    0xc(%eax),%eax
801047f6:	83 f8 05             	cmp    $0x5,%eax
801047f9:	75 7c                	jne    80104877 <wait+0xd2>
        // Found one.
        pid = p->pid;
801047fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fe:	8b 40 10             	mov    0x10(%eax),%eax
80104801:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104807:	8b 40 08             	mov    0x8(%eax),%eax
8010480a:	83 ec 0c             	sub    $0xc,%esp
8010480d:	50                   	push   %eax
8010480e:	e8 d9 e4 ff ff       	call   80102cec <kfree>
80104813:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104819:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104823:	8b 40 04             	mov    0x4(%eax),%eax
80104826:	83 ec 0c             	sub    $0xc,%esp
80104829:	50                   	push   %eax
8010482a:	e8 3e 3d 00 00       	call   8010856d <freevm>
8010482f:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104835:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010483c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104849:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010484d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104850:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104861:	83 ec 0c             	sub    $0xc,%esp
80104864:	68 40 85 11 80       	push   $0x80118540
80104869:	e8 1c 0a 00 00       	call   8010528a <release>
8010486e:	83 c4 10             	add    $0x10,%esp
        return pid;
80104871:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104874:	eb 54                	jmp    801048ca <wait+0x125>
        continue;
80104876:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104877:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010487e:	81 7d f4 74 a6 11 80 	cmpl   $0x8011a674,-0xc(%ebp)
80104885:	0f 82 4f ff ff ff    	jb     801047da <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010488b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010488f:	74 0a                	je     8010489b <wait+0xf6>
80104891:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104894:	8b 40 24             	mov    0x24(%eax),%eax
80104897:	85 c0                	test   %eax,%eax
80104899:	74 17                	je     801048b2 <wait+0x10d>
      release(&ptable.lock);
8010489b:	83 ec 0c             	sub    $0xc,%esp
8010489e:	68 40 85 11 80       	push   $0x80118540
801048a3:	e8 e2 09 00 00       	call   8010528a <release>
801048a8:	83 c4 10             	add    $0x10,%esp
      return -1;
801048ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048b0:	eb 18                	jmp    801048ca <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801048b2:	83 ec 08             	sub    $0x8,%esp
801048b5:	68 40 85 11 80       	push   $0x80118540
801048ba:	ff 75 ec             	pushl  -0x14(%ebp)
801048bd:	e8 76 03 00 00       	call   80104c38 <sleep>
801048c2:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801048c5:	e9 fd fe ff ff       	jmp    801047c7 <wait+0x22>
  }
}
801048ca:	c9                   	leave  
801048cb:	c3                   	ret    

801048cc <wait2>:

int
wait2(int *status) {
801048cc:	f3 0f 1e fb          	endbr32 
801048d0:	55                   	push   %ebp
801048d1:	89 e5                	mov    %esp,%ebp
801048d3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801048d6:	e8 c6 f7 ff ff       	call   801040a1 <myproc>
801048db:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
801048de:	83 ec 0c             	sub    $0xc,%esp
801048e1:	68 40 85 11 80       	push   $0x80118540
801048e6:	e8 2d 09 00 00       	call   80105218 <acquire>
801048eb:	83 c4 10             	add    $0x10,%esp
  for(;;) {
    // Scan through table looking for zombie children.
    havekids = 0;
801048ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801048f5:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
801048fc:	e9 e5 00 00 00       	jmp    801049e6 <wait2+0x11a>
      if(p->parent != curproc)
80104901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104904:	8b 40 14             	mov    0x14(%eax),%eax
80104907:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010490a:	0f 85 ce 00 00 00    	jne    801049de <wait2+0x112>
        continue;
      havekids = 1;
80104910:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE) {
80104917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491a:	8b 40 0c             	mov    0xc(%eax),%eax
8010491d:	83 f8 05             	cmp    $0x5,%eax
80104920:	0f 85 b9 00 00 00    	jne    801049df <wait2+0x113>
        // Found one.
        pid = p->pid;
80104926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104929:	8b 40 10             	mov    0x10(%eax),%eax
8010492c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010492f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104932:	8b 40 08             	mov    0x8(%eax),%eax
80104935:	83 ec 0c             	sub    $0xc,%esp
80104938:	50                   	push   %eax
80104939:	e8 ae e3 ff ff       	call   80102cec <kfree>
8010493e:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104944:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010494b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494e:	8b 40 04             	mov    0x4(%eax),%eax
80104951:	83 ec 0c             	sub    $0xc,%esp
80104954:	50                   	push   %eax
80104955:	e8 13 3c 00 00       	call   8010856d <freevm>
8010495a:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010495d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104960:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104974:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497b:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        if(status != 0 && copyout(curproc->pgdir, (uint)status, &p->xstate, sizeof(p->xstate)) < 0) {
80104982:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104986:	74 37                	je     801049bf <wait2+0xf3>
80104988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498b:	8d 48 7c             	lea    0x7c(%eax),%ecx
8010498e:	8b 55 08             	mov    0x8(%ebp),%edx
80104991:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104994:	8b 40 04             	mov    0x4(%eax),%eax
80104997:	6a 04                	push   $0x4
80104999:	51                   	push   %ecx
8010499a:	52                   	push   %edx
8010499b:	50                   	push   %eax
8010499c:	e8 14 3e 00 00       	call   801087b5 <copyout>
801049a1:	83 c4 10             	add    $0x10,%esp
801049a4:	85 c0                	test   %eax,%eax
801049a6:	79 17                	jns    801049bf <wait2+0xf3>
          release(&ptable.lock);
801049a8:	83 ec 0c             	sub    $0xc,%esp
801049ab:	68 40 85 11 80       	push   $0x80118540
801049b0:	e8 d5 08 00 00       	call   8010528a <release>
801049b5:	83 c4 10             	add    $0x10,%esp
          return -1;
801049b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049bd:	eb 73                	jmp    80104a32 <wait2+0x166>
        }
        p->state = UNUSED;
801049bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
801049c9:	83 ec 0c             	sub    $0xc,%esp
801049cc:	68 40 85 11 80       	push   $0x80118540
801049d1:	e8 b4 08 00 00       	call   8010528a <release>
801049d6:	83 c4 10             	add    $0x10,%esp
        return pid;
801049d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801049dc:	eb 54                	jmp    80104a32 <wait2+0x166>
        continue;
801049de:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801049df:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801049e6:	81 7d f4 74 a6 11 80 	cmpl   $0x8011a674,-0xc(%ebp)
801049ed:	0f 82 0e ff ff ff    	jb     80104901 <wait2+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed) {
801049f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049f7:	74 0a                	je     80104a03 <wait2+0x137>
801049f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049fc:	8b 40 24             	mov    0x24(%eax),%eax
801049ff:	85 c0                	test   %eax,%eax
80104a01:	74 17                	je     80104a1a <wait2+0x14e>
      release(&ptable.lock);
80104a03:	83 ec 0c             	sub    $0xc,%esp
80104a06:	68 40 85 11 80       	push   $0x80118540
80104a0b:	e8 7a 08 00 00       	call   8010528a <release>
80104a10:	83 c4 10             	add    $0x10,%esp
      return -1;
80104a13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a18:	eb 18                	jmp    80104a32 <wait2+0x166>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  // DOC: wait-sleep
80104a1a:	83 ec 08             	sub    $0x8,%esp
80104a1d:	68 40 85 11 80       	push   $0x80118540
80104a22:	ff 75 ec             	pushl  -0x14(%ebp)
80104a25:	e8 0e 02 00 00       	call   80104c38 <sleep>
80104a2a:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104a2d:	e9 bc fe ff ff       	jmp    801048ee <wait2+0x22>
  }
}
80104a32:	c9                   	leave  
80104a33:	c3                   	ret    

80104a34 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a34:	f3 0f 1e fb          	endbr32 
80104a38:	55                   	push   %ebp
80104a39:	89 e5                	mov    %esp,%ebp
80104a3b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104a3e:	e8 e2 f5 ff ff       	call   80104025 <mycpu>
80104a43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a49:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104a50:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a53:	e8 85 f5 ff ff       	call   80103fdd <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a58:	83 ec 0c             	sub    $0xc,%esp
80104a5b:	68 40 85 11 80       	push   $0x80118540
80104a60:	e8 b3 07 00 00       	call   80105218 <acquire>
80104a65:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a68:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104a6f:	eb 64                	jmp    80104ad5 <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a74:	8b 40 0c             	mov    0xc(%eax),%eax
80104a77:	83 f8 03             	cmp    $0x3,%eax
80104a7a:	75 51                	jne    80104acd <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a82:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104a88:	83 ec 0c             	sub    $0xc,%esp
80104a8b:	ff 75 f4             	pushl  -0xc(%ebp)
80104a8e:	e8 21 36 00 00       	call   801080b4 <switchuvm>
80104a93:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a99:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa3:	8b 40 1c             	mov    0x1c(%eax),%eax
80104aa6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104aa9:	83 c2 04             	add    $0x4,%edx
80104aac:	83 ec 08             	sub    $0x8,%esp
80104aaf:	50                   	push   %eax
80104ab0:	52                   	push   %edx
80104ab1:	e8 85 0c 00 00       	call   8010573b <swtch>
80104ab6:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104ab9:	e8 d9 35 00 00       	call   80108097 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ac1:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104ac8:	00 00 00 
80104acb:	eb 01                	jmp    80104ace <scheduler+0x9a>
        continue;
80104acd:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ace:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ad5:	81 7d f4 74 a6 11 80 	cmpl   $0x8011a674,-0xc(%ebp)
80104adc:	72 93                	jb     80104a71 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104ade:	83 ec 0c             	sub    $0xc,%esp
80104ae1:	68 40 85 11 80       	push   $0x80118540
80104ae6:	e8 9f 07 00 00       	call   8010528a <release>
80104aeb:	83 c4 10             	add    $0x10,%esp
    sti();
80104aee:	e9 60 ff ff ff       	jmp    80104a53 <scheduler+0x1f>

80104af3 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104af3:	f3 0f 1e fb          	endbr32 
80104af7:	55                   	push   %ebp
80104af8:	89 e5                	mov    %esp,%ebp
80104afa:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104afd:	e8 9f f5 ff ff       	call   801040a1 <myproc>
80104b02:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104b05:	83 ec 0c             	sub    $0xc,%esp
80104b08:	68 40 85 11 80       	push   $0x80118540
80104b0d:	e8 4d 08 00 00       	call   8010535f <holding>
80104b12:	83 c4 10             	add    $0x10,%esp
80104b15:	85 c0                	test   %eax,%eax
80104b17:	75 0d                	jne    80104b26 <sched+0x33>
    panic("sched ptable.lock");
80104b19:	83 ec 0c             	sub    $0xc,%esp
80104b1c:	68 2f b0 10 80       	push   $0x8010b02f
80104b21:	e8 9f ba ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104b26:	e8 fa f4 ff ff       	call   80104025 <mycpu>
80104b2b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b31:	83 f8 01             	cmp    $0x1,%eax
80104b34:	74 0d                	je     80104b43 <sched+0x50>
    panic("sched locks");
80104b36:	83 ec 0c             	sub    $0xc,%esp
80104b39:	68 41 b0 10 80       	push   $0x8010b041
80104b3e:	e8 82 ba ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b46:	8b 40 0c             	mov    0xc(%eax),%eax
80104b49:	83 f8 04             	cmp    $0x4,%eax
80104b4c:	75 0d                	jne    80104b5b <sched+0x68>
    panic("sched running");
80104b4e:	83 ec 0c             	sub    $0xc,%esp
80104b51:	68 4d b0 10 80       	push   $0x8010b04d
80104b56:	e8 6a ba ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
80104b5b:	e8 6d f4 ff ff       	call   80103fcd <readeflags>
80104b60:	25 00 02 00 00       	and    $0x200,%eax
80104b65:	85 c0                	test   %eax,%eax
80104b67:	74 0d                	je     80104b76 <sched+0x83>
    panic("sched interruptible");
80104b69:	83 ec 0c             	sub    $0xc,%esp
80104b6c:	68 5b b0 10 80       	push   $0x8010b05b
80104b71:	e8 4f ba ff ff       	call   801005c5 <panic>
  intena = mycpu()->intena;
80104b76:	e8 aa f4 ff ff       	call   80104025 <mycpu>
80104b7b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104b81:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104b84:	e8 9c f4 ff ff       	call   80104025 <mycpu>
80104b89:	8b 40 04             	mov    0x4(%eax),%eax
80104b8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b8f:	83 c2 1c             	add    $0x1c,%edx
80104b92:	83 ec 08             	sub    $0x8,%esp
80104b95:	50                   	push   %eax
80104b96:	52                   	push   %edx
80104b97:	e8 9f 0b 00 00       	call   8010573b <swtch>
80104b9c:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104b9f:	e8 81 f4 ff ff       	call   80104025 <mycpu>
80104ba4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ba7:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104bad:	90                   	nop
80104bae:	c9                   	leave  
80104baf:	c3                   	ret    

80104bb0 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104bb0:	f3 0f 1e fb          	endbr32 
80104bb4:	55                   	push   %ebp
80104bb5:	89 e5                	mov    %esp,%ebp
80104bb7:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104bba:	83 ec 0c             	sub    $0xc,%esp
80104bbd:	68 40 85 11 80       	push   $0x80118540
80104bc2:	e8 51 06 00 00       	call   80105218 <acquire>
80104bc7:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104bca:	e8 d2 f4 ff ff       	call   801040a1 <myproc>
80104bcf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104bd6:	e8 18 ff ff ff       	call   80104af3 <sched>
  release(&ptable.lock);
80104bdb:	83 ec 0c             	sub    $0xc,%esp
80104bde:	68 40 85 11 80       	push   $0x80118540
80104be3:	e8 a2 06 00 00       	call   8010528a <release>
80104be8:	83 c4 10             	add    $0x10,%esp
}
80104beb:	90                   	nop
80104bec:	c9                   	leave  
80104bed:	c3                   	ret    

80104bee <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bee:	f3 0f 1e fb          	endbr32 
80104bf2:	55                   	push   %ebp
80104bf3:	89 e5                	mov    %esp,%ebp
80104bf5:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bf8:	83 ec 0c             	sub    $0xc,%esp
80104bfb:	68 40 85 11 80       	push   $0x80118540
80104c00:	e8 85 06 00 00       	call   8010528a <release>
80104c05:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104c08:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104c0d:	85 c0                	test   %eax,%eax
80104c0f:	74 24                	je     80104c35 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104c11:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
80104c18:	00 00 00 
    iinit(ROOTDEV);
80104c1b:	83 ec 0c             	sub    $0xc,%esp
80104c1e:	6a 01                	push   $0x1
80104c20:	e8 d1 ca ff ff       	call   801016f6 <iinit>
80104c25:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104c28:	83 ec 0c             	sub    $0xc,%esp
80104c2b:	6a 01                	push   $0x1
80104c2d:	e8 04 e8 ff ff       	call   80103436 <initlog>
80104c32:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104c35:	90                   	nop
80104c36:	c9                   	leave  
80104c37:	c3                   	ret    

80104c38 <sleep>:

// Atomically release lock and sleep on chan.ld: trap.o: in function `trap':
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104c38:	f3 0f 1e fb          	endbr32 
80104c3c:	55                   	push   %ebp
80104c3d:	89 e5                	mov    %esp,%ebp
80104c3f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104c42:	e8 5a f4 ff ff       	call   801040a1 <myproc>
80104c47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104c4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c4e:	75 0d                	jne    80104c5d <sleep+0x25>
    panic("sleep");
80104c50:	83 ec 0c             	sub    $0xc,%esp
80104c53:	68 6f b0 10 80       	push   $0x8010b06f
80104c58:	e8 68 b9 ff ff       	call   801005c5 <panic>

  if(lk == 0)
80104c5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c61:	75 0d                	jne    80104c70 <sleep+0x38>
    panic("sleep without lk");
80104c63:	83 ec 0c             	sub    $0xc,%esp
80104c66:	68 75 b0 10 80       	push   $0x8010b075
80104c6b:	e8 55 b9 ff ff       	call   801005c5 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c70:	81 7d 0c 40 85 11 80 	cmpl   $0x80118540,0xc(%ebp)
80104c77:	74 1e                	je     80104c97 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c79:	83 ec 0c             	sub    $0xc,%esp
80104c7c:	68 40 85 11 80       	push   $0x80118540
80104c81:	e8 92 05 00 00       	call   80105218 <acquire>
80104c86:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104c89:	83 ec 0c             	sub    $0xc,%esp
80104c8c:	ff 75 0c             	pushl  0xc(%ebp)
80104c8f:	e8 f6 05 00 00       	call   8010528a <release>
80104c94:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9a:	8b 55 08             	mov    0x8(%ebp),%edx
80104c9d:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca3:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104caa:	e8 44 fe ff ff       	call   80104af3 <sched>

  // Tidy up.
  p->chan = 0;
80104caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb2:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104cb9:	81 7d 0c 40 85 11 80 	cmpl   $0x80118540,0xc(%ebp)
80104cc0:	74 1e                	je     80104ce0 <sleep+0xa8>
    release(&ptable.lock);
80104cc2:	83 ec 0c             	sub    $0xc,%esp
80104cc5:	68 40 85 11 80       	push   $0x80118540
80104cca:	e8 bb 05 00 00       	call   8010528a <release>
80104ccf:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104cd2:	83 ec 0c             	sub    $0xc,%esp
80104cd5:	ff 75 0c             	pushl  0xc(%ebp)
80104cd8:	e8 3b 05 00 00       	call   80105218 <acquire>
80104cdd:	83 c4 10             	add    $0x10,%esp
  }
}
80104ce0:	90                   	nop
80104ce1:	c9                   	leave  
80104ce2:	c3                   	ret    

80104ce3 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ce3:	f3 0f 1e fb          	endbr32 
80104ce7:	55                   	push   %ebp
80104ce8:	89 e5                	mov    %esp,%ebp
80104cea:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ced:	c7 45 fc 74 85 11 80 	movl   $0x80118574,-0x4(%ebp)
80104cf4:	eb 27                	jmp    80104d1d <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
80104cf6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cf9:	8b 40 0c             	mov    0xc(%eax),%eax
80104cfc:	83 f8 02             	cmp    $0x2,%eax
80104cff:	75 15                	jne    80104d16 <wakeup1+0x33>
80104d01:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d04:	8b 40 20             	mov    0x20(%eax),%eax
80104d07:	39 45 08             	cmp    %eax,0x8(%ebp)
80104d0a:	75 0a                	jne    80104d16 <wakeup1+0x33>
      p->state = RUNNABLE;
80104d0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d0f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104d16:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104d1d:	81 7d fc 74 a6 11 80 	cmpl   $0x8011a674,-0x4(%ebp)
80104d24:	72 d0                	jb     80104cf6 <wakeup1+0x13>
}
80104d26:	90                   	nop
80104d27:	90                   	nop
80104d28:	c9                   	leave  
80104d29:	c3                   	ret    

80104d2a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104d2a:	f3 0f 1e fb          	endbr32 
80104d2e:	55                   	push   %ebp
80104d2f:	89 e5                	mov    %esp,%ebp
80104d31:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104d34:	83 ec 0c             	sub    $0xc,%esp
80104d37:	68 40 85 11 80       	push   $0x80118540
80104d3c:	e8 d7 04 00 00       	call   80105218 <acquire>
80104d41:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104d44:	83 ec 0c             	sub    $0xc,%esp
80104d47:	ff 75 08             	pushl  0x8(%ebp)
80104d4a:	e8 94 ff ff ff       	call   80104ce3 <wakeup1>
80104d4f:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104d52:	83 ec 0c             	sub    $0xc,%esp
80104d55:	68 40 85 11 80       	push   $0x80118540
80104d5a:	e8 2b 05 00 00       	call   8010528a <release>
80104d5f:	83 c4 10             	add    $0x10,%esp
}
80104d62:	90                   	nop
80104d63:	c9                   	leave  
80104d64:	c3                   	ret    

80104d65 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104d65:	f3 0f 1e fb          	endbr32 
80104d69:	55                   	push   %ebp
80104d6a:	89 e5                	mov    %esp,%ebp
80104d6c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104d6f:	83 ec 0c             	sub    $0xc,%esp
80104d72:	68 40 85 11 80       	push   $0x80118540
80104d77:	e8 9c 04 00 00       	call   80105218 <acquire>
80104d7c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d7f:	c7 45 f4 74 85 11 80 	movl   $0x80118574,-0xc(%ebp)
80104d86:	eb 48                	jmp    80104dd0 <kill+0x6b>
    if(p->pid == pid){
80104d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8b:	8b 40 10             	mov    0x10(%eax),%eax
80104d8e:	39 45 08             	cmp    %eax,0x8(%ebp)
80104d91:	75 36                	jne    80104dc9 <kill+0x64>
      p->killed = 1;
80104d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d96:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da0:	8b 40 0c             	mov    0xc(%eax),%eax
80104da3:	83 f8 02             	cmp    $0x2,%eax
80104da6:	75 0a                	jne    80104db2 <kill+0x4d>
        p->state = RUNNABLE;
80104da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dab:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104db2:	83 ec 0c             	sub    $0xc,%esp
80104db5:	68 40 85 11 80       	push   $0x80118540
80104dba:	e8 cb 04 00 00       	call   8010528a <release>
80104dbf:	83 c4 10             	add    $0x10,%esp
      return 0;
80104dc2:	b8 00 00 00 00       	mov    $0x0,%eax
80104dc7:	eb 25                	jmp    80104dee <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dc9:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104dd0:	81 7d f4 74 a6 11 80 	cmpl   $0x8011a674,-0xc(%ebp)
80104dd7:	72 af                	jb     80104d88 <kill+0x23>
    }
  }
  release(&ptable.lock);
80104dd9:	83 ec 0c             	sub    $0xc,%esp
80104ddc:	68 40 85 11 80       	push   $0x80118540
80104de1:	e8 a4 04 00 00       	call   8010528a <release>
80104de6:	83 c4 10             	add    $0x10,%esp
  return -1;
80104de9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104dee:	c9                   	leave  
80104def:	c3                   	ret    

80104df0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104df0:	f3 0f 1e fb          	endbr32 
80104df4:	55                   	push   %ebp
80104df5:	89 e5                	mov    %esp,%ebp
80104df7:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dfa:	c7 45 f0 74 85 11 80 	movl   $0x80118574,-0x10(%ebp)
80104e01:	e9 da 00 00 00       	jmp    80104ee0 <procdump+0xf0>
    if(p->state == UNUSED)
80104e06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e09:	8b 40 0c             	mov    0xc(%eax),%eax
80104e0c:	85 c0                	test   %eax,%eax
80104e0e:	0f 84 c4 00 00 00    	je     80104ed8 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e17:	8b 40 0c             	mov    0xc(%eax),%eax
80104e1a:	83 f8 05             	cmp    $0x5,%eax
80104e1d:	77 23                	ja     80104e42 <procdump+0x52>
80104e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e22:	8b 40 0c             	mov    0xc(%eax),%eax
80104e25:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104e2c:	85 c0                	test   %eax,%eax
80104e2e:	74 12                	je     80104e42 <procdump+0x52>
      state = states[p->state];
80104e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e33:	8b 40 0c             	mov    0xc(%eax),%eax
80104e36:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104e3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104e40:	eb 07                	jmp    80104e49 <procdump+0x59>
    else
      state = "???";
80104e42:	c7 45 ec 86 b0 10 80 	movl   $0x8010b086,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e4c:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e52:	8b 40 10             	mov    0x10(%eax),%eax
80104e55:	52                   	push   %edx
80104e56:	ff 75 ec             	pushl  -0x14(%ebp)
80104e59:	50                   	push   %eax
80104e5a:	68 8a b0 10 80       	push   $0x8010b08a
80104e5f:	e8 a8 b5 ff ff       	call   8010040c <cprintf>
80104e64:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e6a:	8b 40 0c             	mov    0xc(%eax),%eax
80104e6d:	83 f8 02             	cmp    $0x2,%eax
80104e70:	75 54                	jne    80104ec6 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e75:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e78:	8b 40 0c             	mov    0xc(%eax),%eax
80104e7b:	83 c0 08             	add    $0x8,%eax
80104e7e:	89 c2                	mov    %eax,%edx
80104e80:	83 ec 08             	sub    $0x8,%esp
80104e83:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104e86:	50                   	push   %eax
80104e87:	52                   	push   %edx
80104e88:	e8 53 04 00 00       	call   801052e0 <getcallerpcs>
80104e8d:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e97:	eb 1c                	jmp    80104eb5 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ea0:	83 ec 08             	sub    $0x8,%esp
80104ea3:	50                   	push   %eax
80104ea4:	68 93 b0 10 80       	push   $0x8010b093
80104ea9:	e8 5e b5 ff ff       	call   8010040c <cprintf>
80104eae:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104eb1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104eb5:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104eb9:	7f 0b                	jg     80104ec6 <procdump+0xd6>
80104ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebe:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ec2:	85 c0                	test   %eax,%eax
80104ec4:	75 d3                	jne    80104e99 <procdump+0xa9>
    }
    cprintf("\n");
80104ec6:	83 ec 0c             	sub    $0xc,%esp
80104ec9:	68 97 b0 10 80       	push   $0x8010b097
80104ece:	e8 39 b5 ff ff       	call   8010040c <cprintf>
80104ed3:	83 c4 10             	add    $0x10,%esp
80104ed6:	eb 01                	jmp    80104ed9 <procdump+0xe9>
      continue;
80104ed8:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ed9:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104ee0:	81 7d f0 74 a6 11 80 	cmpl   $0x8011a674,-0x10(%ebp)
80104ee7:	0f 82 19 ff ff ff    	jb     80104e06 <procdump+0x16>
  }
}
80104eed:	90                   	nop
80104eee:	90                   	nop
80104eef:	c9                   	leave  
80104ef0:	c3                   	ret    

80104ef1 <printpt>:

// printpt 함수 구현
void printpt(int pid) {
80104ef1:	f3 0f 1e fb          	endbr32 
80104ef5:	55                   	push   %ebp
80104ef6:	89 e5                	mov    %esp,%ebp
80104ef8:	56                   	push   %esi
80104ef9:	53                   	push   %ebx
80104efa:	83 ec 20             	sub    $0x20,%esp
    struct proc *p = myproc();  // 현재 실행 중인 프로세스를 가져옴
80104efd:	e8 9f f1 ff ff       	call   801040a1 <myproc>
80104f02:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(p->pid != pid) {
80104f05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f08:	8b 40 10             	mov    0x10(%eax),%eax
80104f0b:	39 45 08             	cmp    %eax,0x8(%ebp)
80104f0e:	74 15                	je     80104f25 <printpt+0x34>
        cprintf("Error: PID does not match current process.\n");
80104f10:	83 ec 0c             	sub    $0xc,%esp
80104f13:	68 9c b0 10 80       	push   $0x8010b09c
80104f18:	e8 ef b4 ff ff       	call   8010040c <cprintf>
80104f1d:	83 c4 10             	add    $0x10,%esp
        return;
80104f20:	e9 59 01 00 00       	jmp    8010507e <printpt+0x18d>
    }

    pde_t *pgdir = p->pgdir;
80104f25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f28:	8b 40 04             	mov    0x4(%eax),%eax
80104f2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    cprintf("START PAGE TABLE (pid %d)\n", pid);
80104f2e:	83 ec 08             	sub    $0x8,%esp
80104f31:	ff 75 08             	pushl  0x8(%ebp)
80104f34:	68 c8 b0 10 80       	push   $0x8010b0c8
80104f39:	e8 ce b4 ff ff       	call   8010040c <cprintf>
80104f3e:	83 c4 10             	add    $0x10,%esp
    for(int i = 0; i < NPDENTRIES; i++) {
80104f41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f48:	e9 14 01 00 00       	jmp    80105061 <printpt+0x170>
        if((pgdir[i] & PTE_P) && (pgdir[i] & PTE_U)) { // 사용자 메모리 부분만 탐색
80104f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f57:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f5a:	01 d0                	add    %edx,%eax
80104f5c:	8b 00                	mov    (%eax),%eax
80104f5e:	83 e0 01             	and    $0x1,%eax
80104f61:	85 c0                	test   %eax,%eax
80104f63:	0f 84 f4 00 00 00    	je     8010505d <printpt+0x16c>
80104f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f73:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f76:	01 d0                	add    %edx,%eax
80104f78:	8b 00                	mov    (%eax),%eax
80104f7a:	83 e0 04             	and    $0x4,%eax
80104f7d:	85 c0                	test   %eax,%eax
80104f7f:	0f 84 d8 00 00 00    	je     8010505d <printpt+0x16c>
            pte_t *pt = (pte_t*)P2V(PTE_ADDR(pgdir[i]));
80104f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f88:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104f92:	01 d0                	add    %edx,%eax
80104f94:	8b 00                	mov    (%eax),%eax
80104f96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104f9b:	05 00 00 00 80       	add    $0x80000000,%eax
80104fa0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            for(int j = 0; j < NPTENTRIES; j++) {
80104fa3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104faa:	e9 a1 00 00 00       	jmp    80105050 <printpt+0x15f>
                if(pt[j] & PTE_P) { // 유효한 페이지 테이블 엔트리만 출력
80104faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104fbc:	01 d0                	add    %edx,%eax
80104fbe:	8b 00                	mov    (%eax),%eax
80104fc0:	83 e0 01             	and    $0x1,%eax
80104fc3:	85 c0                	test   %eax,%eax
80104fc5:	0f 84 81 00 00 00    	je     8010504c <printpt+0x15b>
                    cprintf("%x P %c %c %x\n", 
                            (i << 10) + j, // 가상 페이지 번호
                            (pt[j] & PTE_U) ? 'U' : 'K', // 사용자 모드 접근 가능 여부
                            (pt[j] & PTE_W) ? 'W' : '-', // 쓰기 가능 여부
                            PTE_ADDR(pt[j])); // 물리 페이지 번호
80104fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104fd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104fd8:	01 d0                	add    %edx,%eax
80104fda:	8b 00                	mov    (%eax),%eax
                    cprintf("%x P %c %c %x\n", 
80104fdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104fe1:	89 c2                	mov    %eax,%edx
                            (pt[j] & PTE_W) ? 'W' : '-', // 쓰기 가능 여부
80104fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80104fed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ff0:	01 c8                	add    %ecx,%eax
80104ff2:	8b 00                	mov    (%eax),%eax
80104ff4:	83 e0 02             	and    $0x2,%eax
                    cprintf("%x P %c %c %x\n", 
80104ff7:	85 c0                	test   %eax,%eax
80104ff9:	74 07                	je     80105002 <printpt+0x111>
80104ffb:	be 57 00 00 00       	mov    $0x57,%esi
80105000:	eb 05                	jmp    80105007 <printpt+0x116>
80105002:	be 2d 00 00 00       	mov    $0x2d,%esi
                            (pt[j] & PTE_U) ? 'U' : 'K', // 사용자 모드 접근 가능 여부
80105007:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80105011:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105014:	01 c8                	add    %ecx,%eax
80105016:	8b 00                	mov    (%eax),%eax
80105018:	83 e0 04             	and    $0x4,%eax
                    cprintf("%x P %c %c %x\n", 
8010501b:	85 c0                	test   %eax,%eax
8010501d:	74 07                	je     80105026 <printpt+0x135>
8010501f:	bb 55 00 00 00       	mov    $0x55,%ebx
80105024:	eb 05                	jmp    8010502b <printpt+0x13a>
80105026:	bb 4b 00 00 00       	mov    $0x4b,%ebx
                            (i << 10) + j, // 가상 페이지 번호
8010502b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502e:	c1 e0 0a             	shl    $0xa,%eax
80105031:	89 c1                	mov    %eax,%ecx
                    cprintf("%x P %c %c %x\n", 
80105033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105036:	01 c8                	add    %ecx,%eax
80105038:	83 ec 0c             	sub    $0xc,%esp
8010503b:	52                   	push   %edx
8010503c:	56                   	push   %esi
8010503d:	53                   	push   %ebx
8010503e:	50                   	push   %eax
8010503f:	68 e3 b0 10 80       	push   $0x8010b0e3
80105044:	e8 c3 b3 ff ff       	call   8010040c <cprintf>
80105049:	83 c4 20             	add    $0x20,%esp
            for(int j = 0; j < NPTENTRIES; j++) {
8010504c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105050:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
80105057:	0f 8e 52 ff ff ff    	jle    80104faf <printpt+0xbe>
    for(int i = 0; i < NPDENTRIES; i++) {
8010505d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105061:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80105068:	0f 8e df fe ff ff    	jle    80104f4d <printpt+0x5c>
                }
            }
        }
    }
    cprintf("END PAGE TABLE\n");
8010506e:	83 ec 0c             	sub    $0xc,%esp
80105071:	68 f2 b0 10 80       	push   $0x8010b0f2
80105076:	e8 91 b3 ff ff       	call   8010040c <cprintf>
8010507b:	83 c4 10             	add    $0x10,%esp
}
8010507e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105081:	5b                   	pop    %ebx
80105082:	5e                   	pop    %esi
80105083:	5d                   	pop    %ebp
80105084:	c3                   	ret    

80105085 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105085:	f3 0f 1e fb          	endbr32 
80105089:	55                   	push   %ebp
8010508a:	89 e5                	mov    %esp,%ebp
8010508c:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010508f:	8b 45 08             	mov    0x8(%ebp),%eax
80105092:	83 c0 04             	add    $0x4,%eax
80105095:	83 ec 08             	sub    $0x8,%esp
80105098:	68 2c b1 10 80       	push   $0x8010b12c
8010509d:	50                   	push   %eax
8010509e:	e8 4f 01 00 00       	call   801051f2 <initlock>
801050a3:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801050a6:	8b 45 08             	mov    0x8(%ebp),%eax
801050a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801050ac:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801050af:	8b 45 08             	mov    0x8(%ebp),%eax
801050b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801050b8:	8b 45 08             	mov    0x8(%ebp),%eax
801050bb:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801050c2:	90                   	nop
801050c3:	c9                   	leave  
801050c4:	c3                   	ret    

801050c5 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801050c5:	f3 0f 1e fb          	endbr32 
801050c9:	55                   	push   %ebp
801050ca:	89 e5                	mov    %esp,%ebp
801050cc:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801050cf:	8b 45 08             	mov    0x8(%ebp),%eax
801050d2:	83 c0 04             	add    $0x4,%eax
801050d5:	83 ec 0c             	sub    $0xc,%esp
801050d8:	50                   	push   %eax
801050d9:	e8 3a 01 00 00       	call   80105218 <acquire>
801050de:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801050e1:	eb 15                	jmp    801050f8 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
801050e3:	8b 45 08             	mov    0x8(%ebp),%eax
801050e6:	83 c0 04             	add    $0x4,%eax
801050e9:	83 ec 08             	sub    $0x8,%esp
801050ec:	50                   	push   %eax
801050ed:	ff 75 08             	pushl  0x8(%ebp)
801050f0:	e8 43 fb ff ff       	call   80104c38 <sleep>
801050f5:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801050f8:	8b 45 08             	mov    0x8(%ebp),%eax
801050fb:	8b 00                	mov    (%eax),%eax
801050fd:	85 c0                	test   %eax,%eax
801050ff:	75 e2                	jne    801050e3 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80105101:	8b 45 08             	mov    0x8(%ebp),%eax
80105104:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010510a:	e8 92 ef ff ff       	call   801040a1 <myproc>
8010510f:	8b 50 10             	mov    0x10(%eax),%edx
80105112:	8b 45 08             	mov    0x8(%ebp),%eax
80105115:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105118:	8b 45 08             	mov    0x8(%ebp),%eax
8010511b:	83 c0 04             	add    $0x4,%eax
8010511e:	83 ec 0c             	sub    $0xc,%esp
80105121:	50                   	push   %eax
80105122:	e8 63 01 00 00       	call   8010528a <release>
80105127:	83 c4 10             	add    $0x10,%esp
}
8010512a:	90                   	nop
8010512b:	c9                   	leave  
8010512c:	c3                   	ret    

8010512d <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010512d:	f3 0f 1e fb          	endbr32 
80105131:	55                   	push   %ebp
80105132:	89 e5                	mov    %esp,%ebp
80105134:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105137:	8b 45 08             	mov    0x8(%ebp),%eax
8010513a:	83 c0 04             	add    $0x4,%eax
8010513d:	83 ec 0c             	sub    $0xc,%esp
80105140:	50                   	push   %eax
80105141:	e8 d2 00 00 00       	call   80105218 <acquire>
80105146:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80105149:	8b 45 08             	mov    0x8(%ebp),%eax
8010514c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105152:	8b 45 08             	mov    0x8(%ebp),%eax
80105155:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010515c:	83 ec 0c             	sub    $0xc,%esp
8010515f:	ff 75 08             	pushl  0x8(%ebp)
80105162:	e8 c3 fb ff ff       	call   80104d2a <wakeup>
80105167:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010516a:	8b 45 08             	mov    0x8(%ebp),%eax
8010516d:	83 c0 04             	add    $0x4,%eax
80105170:	83 ec 0c             	sub    $0xc,%esp
80105173:	50                   	push   %eax
80105174:	e8 11 01 00 00       	call   8010528a <release>
80105179:	83 c4 10             	add    $0x10,%esp
}
8010517c:	90                   	nop
8010517d:	c9                   	leave  
8010517e:	c3                   	ret    

8010517f <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010517f:	f3 0f 1e fb          	endbr32 
80105183:	55                   	push   %ebp
80105184:	89 e5                	mov    %esp,%ebp
80105186:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80105189:	8b 45 08             	mov    0x8(%ebp),%eax
8010518c:	83 c0 04             	add    $0x4,%eax
8010518f:	83 ec 0c             	sub    $0xc,%esp
80105192:	50                   	push   %eax
80105193:	e8 80 00 00 00       	call   80105218 <acquire>
80105198:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
8010519b:	8b 45 08             	mov    0x8(%ebp),%eax
8010519e:	8b 00                	mov    (%eax),%eax
801051a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801051a3:	8b 45 08             	mov    0x8(%ebp),%eax
801051a6:	83 c0 04             	add    $0x4,%eax
801051a9:	83 ec 0c             	sub    $0xc,%esp
801051ac:	50                   	push   %eax
801051ad:	e8 d8 00 00 00       	call   8010528a <release>
801051b2:	83 c4 10             	add    $0x10,%esp
  return r;
801051b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801051b8:	c9                   	leave  
801051b9:	c3                   	ret    

801051ba <readeflags>:
{
801051ba:	55                   	push   %ebp
801051bb:	89 e5                	mov    %esp,%ebp
801051bd:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801051c0:	9c                   	pushf  
801051c1:	58                   	pop    %eax
801051c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801051c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051c8:	c9                   	leave  
801051c9:	c3                   	ret    

801051ca <cli>:
{
801051ca:	55                   	push   %ebp
801051cb:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801051cd:	fa                   	cli    
}
801051ce:	90                   	nop
801051cf:	5d                   	pop    %ebp
801051d0:	c3                   	ret    

801051d1 <sti>:
{
801051d1:	55                   	push   %ebp
801051d2:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801051d4:	fb                   	sti    
}
801051d5:	90                   	nop
801051d6:	5d                   	pop    %ebp
801051d7:	c3                   	ret    

801051d8 <xchg>:
{
801051d8:	55                   	push   %ebp
801051d9:	89 e5                	mov    %esp,%ebp
801051db:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801051de:	8b 55 08             	mov    0x8(%ebp),%edx
801051e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801051e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
801051e7:	f0 87 02             	lock xchg %eax,(%edx)
801051ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801051ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801051f0:	c9                   	leave  
801051f1:	c3                   	ret    

801051f2 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801051f2:	f3 0f 1e fb          	endbr32 
801051f6:	55                   	push   %ebp
801051f7:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801051f9:	8b 45 08             	mov    0x8(%ebp),%eax
801051fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801051ff:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105202:	8b 45 08             	mov    0x8(%ebp),%eax
80105205:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010520b:	8b 45 08             	mov    0x8(%ebp),%eax
8010520e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105215:	90                   	nop
80105216:	5d                   	pop    %ebp
80105217:	c3                   	ret    

80105218 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105218:	f3 0f 1e fb          	endbr32 
8010521c:	55                   	push   %ebp
8010521d:	89 e5                	mov    %esp,%ebp
8010521f:	53                   	push   %ebx
80105220:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105223:	e8 6c 01 00 00       	call   80105394 <pushcli>
  if(holding(lk)){
80105228:	8b 45 08             	mov    0x8(%ebp),%eax
8010522b:	83 ec 0c             	sub    $0xc,%esp
8010522e:	50                   	push   %eax
8010522f:	e8 2b 01 00 00       	call   8010535f <holding>
80105234:	83 c4 10             	add    $0x10,%esp
80105237:	85 c0                	test   %eax,%eax
80105239:	74 0d                	je     80105248 <acquire+0x30>
    panic("acquire");
8010523b:	83 ec 0c             	sub    $0xc,%esp
8010523e:	68 37 b1 10 80       	push   $0x8010b137
80105243:	e8 7d b3 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105248:	90                   	nop
80105249:	8b 45 08             	mov    0x8(%ebp),%eax
8010524c:	83 ec 08             	sub    $0x8,%esp
8010524f:	6a 01                	push   $0x1
80105251:	50                   	push   %eax
80105252:	e8 81 ff ff ff       	call   801051d8 <xchg>
80105257:	83 c4 10             	add    $0x10,%esp
8010525a:	85 c0                	test   %eax,%eax
8010525c:	75 eb                	jne    80105249 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010525e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105263:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105266:	e8 ba ed ff ff       	call   80104025 <mycpu>
8010526b:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010526e:	8b 45 08             	mov    0x8(%ebp),%eax
80105271:	83 c0 0c             	add    $0xc,%eax
80105274:	83 ec 08             	sub    $0x8,%esp
80105277:	50                   	push   %eax
80105278:	8d 45 08             	lea    0x8(%ebp),%eax
8010527b:	50                   	push   %eax
8010527c:	e8 5f 00 00 00       	call   801052e0 <getcallerpcs>
80105281:	83 c4 10             	add    $0x10,%esp
}
80105284:	90                   	nop
80105285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105288:	c9                   	leave  
80105289:	c3                   	ret    

8010528a <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010528a:	f3 0f 1e fb          	endbr32 
8010528e:	55                   	push   %ebp
8010528f:	89 e5                	mov    %esp,%ebp
80105291:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105294:	83 ec 0c             	sub    $0xc,%esp
80105297:	ff 75 08             	pushl  0x8(%ebp)
8010529a:	e8 c0 00 00 00       	call   8010535f <holding>
8010529f:	83 c4 10             	add    $0x10,%esp
801052a2:	85 c0                	test   %eax,%eax
801052a4:	75 0d                	jne    801052b3 <release+0x29>
    panic("release");
801052a6:	83 ec 0c             	sub    $0xc,%esp
801052a9:	68 3f b1 10 80       	push   $0x8010b13f
801052ae:	e8 12 b3 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
801052b3:	8b 45 08             	mov    0x8(%ebp),%eax
801052b6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801052bd:	8b 45 08             	mov    0x8(%ebp),%eax
801052c0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801052c7:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801052cc:	8b 45 08             	mov    0x8(%ebp),%eax
801052cf:	8b 55 08             	mov    0x8(%ebp),%edx
801052d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801052d8:	e8 08 01 00 00       	call   801053e5 <popcli>
}
801052dd:	90                   	nop
801052de:	c9                   	leave  
801052df:	c3                   	ret    

801052e0 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801052e0:	f3 0f 1e fb          	endbr32 
801052e4:	55                   	push   %ebp
801052e5:	89 e5                	mov    %esp,%ebp
801052e7:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801052ea:	8b 45 08             	mov    0x8(%ebp),%eax
801052ed:	83 e8 08             	sub    $0x8,%eax
801052f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801052f3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801052fa:	eb 38                	jmp    80105334 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801052fc:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105300:	74 53                	je     80105355 <getcallerpcs+0x75>
80105302:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105309:	76 4a                	jbe    80105355 <getcallerpcs+0x75>
8010530b:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010530f:	74 44                	je     80105355 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105311:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105314:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010531b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010531e:	01 c2                	add    %eax,%edx
80105320:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105323:	8b 40 04             	mov    0x4(%eax),%eax
80105326:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105328:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010532b:	8b 00                	mov    (%eax),%eax
8010532d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105330:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105334:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105338:	7e c2                	jle    801052fc <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
8010533a:	eb 19                	jmp    80105355 <getcallerpcs+0x75>
    pcs[i] = 0;
8010533c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010533f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105346:	8b 45 0c             	mov    0xc(%ebp),%eax
80105349:	01 d0                	add    %edx,%eax
8010534b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105351:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105355:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105359:	7e e1                	jle    8010533c <getcallerpcs+0x5c>
}
8010535b:	90                   	nop
8010535c:	90                   	nop
8010535d:	c9                   	leave  
8010535e:	c3                   	ret    

8010535f <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010535f:	f3 0f 1e fb          	endbr32 
80105363:	55                   	push   %ebp
80105364:	89 e5                	mov    %esp,%ebp
80105366:	53                   	push   %ebx
80105367:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010536a:	8b 45 08             	mov    0x8(%ebp),%eax
8010536d:	8b 00                	mov    (%eax),%eax
8010536f:	85 c0                	test   %eax,%eax
80105371:	74 16                	je     80105389 <holding+0x2a>
80105373:	8b 45 08             	mov    0x8(%ebp),%eax
80105376:	8b 58 08             	mov    0x8(%eax),%ebx
80105379:	e8 a7 ec ff ff       	call   80104025 <mycpu>
8010537e:	39 c3                	cmp    %eax,%ebx
80105380:	75 07                	jne    80105389 <holding+0x2a>
80105382:	b8 01 00 00 00       	mov    $0x1,%eax
80105387:	eb 05                	jmp    8010538e <holding+0x2f>
80105389:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010538e:	83 c4 04             	add    $0x4,%esp
80105391:	5b                   	pop    %ebx
80105392:	5d                   	pop    %ebp
80105393:	c3                   	ret    

80105394 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105394:	f3 0f 1e fb          	endbr32 
80105398:	55                   	push   %ebp
80105399:	89 e5                	mov    %esp,%ebp
8010539b:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010539e:	e8 17 fe ff ff       	call   801051ba <readeflags>
801053a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801053a6:	e8 1f fe ff ff       	call   801051ca <cli>
  if(mycpu()->ncli == 0)
801053ab:	e8 75 ec ff ff       	call   80104025 <mycpu>
801053b0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801053b6:	85 c0                	test   %eax,%eax
801053b8:	75 14                	jne    801053ce <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
801053ba:	e8 66 ec ff ff       	call   80104025 <mycpu>
801053bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053c2:	81 e2 00 02 00 00    	and    $0x200,%edx
801053c8:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801053ce:	e8 52 ec ff ff       	call   80104025 <mycpu>
801053d3:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801053d9:	83 c2 01             	add    $0x1,%edx
801053dc:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801053e2:	90                   	nop
801053e3:	c9                   	leave  
801053e4:	c3                   	ret    

801053e5 <popcli>:

void
popcli(void)
{
801053e5:	f3 0f 1e fb          	endbr32 
801053e9:	55                   	push   %ebp
801053ea:	89 e5                	mov    %esp,%ebp
801053ec:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801053ef:	e8 c6 fd ff ff       	call   801051ba <readeflags>
801053f4:	25 00 02 00 00       	and    $0x200,%eax
801053f9:	85 c0                	test   %eax,%eax
801053fb:	74 0d                	je     8010540a <popcli+0x25>
    panic("popcli - interruptible");
801053fd:	83 ec 0c             	sub    $0xc,%esp
80105400:	68 47 b1 10 80       	push   $0x8010b147
80105405:	e8 bb b1 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
8010540a:	e8 16 ec ff ff       	call   80104025 <mycpu>
8010540f:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105415:	83 ea 01             	sub    $0x1,%edx
80105418:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010541e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105424:	85 c0                	test   %eax,%eax
80105426:	79 0d                	jns    80105435 <popcli+0x50>
    panic("popcli");
80105428:	83 ec 0c             	sub    $0xc,%esp
8010542b:	68 5e b1 10 80       	push   $0x8010b15e
80105430:	e8 90 b1 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105435:	e8 eb eb ff ff       	call   80104025 <mycpu>
8010543a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105440:	85 c0                	test   %eax,%eax
80105442:	75 14                	jne    80105458 <popcli+0x73>
80105444:	e8 dc eb ff ff       	call   80104025 <mycpu>
80105449:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010544f:	85 c0                	test   %eax,%eax
80105451:	74 05                	je     80105458 <popcli+0x73>
    sti();
80105453:	e8 79 fd ff ff       	call   801051d1 <sti>
}
80105458:	90                   	nop
80105459:	c9                   	leave  
8010545a:	c3                   	ret    

8010545b <stosb>:
{
8010545b:	55                   	push   %ebp
8010545c:	89 e5                	mov    %esp,%ebp
8010545e:	57                   	push   %edi
8010545f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105460:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105463:	8b 55 10             	mov    0x10(%ebp),%edx
80105466:	8b 45 0c             	mov    0xc(%ebp),%eax
80105469:	89 cb                	mov    %ecx,%ebx
8010546b:	89 df                	mov    %ebx,%edi
8010546d:	89 d1                	mov    %edx,%ecx
8010546f:	fc                   	cld    
80105470:	f3 aa                	rep stos %al,%es:(%edi)
80105472:	89 ca                	mov    %ecx,%edx
80105474:	89 fb                	mov    %edi,%ebx
80105476:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105479:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010547c:	90                   	nop
8010547d:	5b                   	pop    %ebx
8010547e:	5f                   	pop    %edi
8010547f:	5d                   	pop    %ebp
80105480:	c3                   	ret    

80105481 <stosl>:
{
80105481:	55                   	push   %ebp
80105482:	89 e5                	mov    %esp,%ebp
80105484:	57                   	push   %edi
80105485:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105486:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105489:	8b 55 10             	mov    0x10(%ebp),%edx
8010548c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010548f:	89 cb                	mov    %ecx,%ebx
80105491:	89 df                	mov    %ebx,%edi
80105493:	89 d1                	mov    %edx,%ecx
80105495:	fc                   	cld    
80105496:	f3 ab                	rep stos %eax,%es:(%edi)
80105498:	89 ca                	mov    %ecx,%edx
8010549a:	89 fb                	mov    %edi,%ebx
8010549c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010549f:	89 55 10             	mov    %edx,0x10(%ebp)
}
801054a2:	90                   	nop
801054a3:	5b                   	pop    %ebx
801054a4:	5f                   	pop    %edi
801054a5:	5d                   	pop    %ebp
801054a6:	c3                   	ret    

801054a7 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801054a7:	f3 0f 1e fb          	endbr32 
801054ab:	55                   	push   %ebp
801054ac:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801054ae:	8b 45 08             	mov    0x8(%ebp),%eax
801054b1:	83 e0 03             	and    $0x3,%eax
801054b4:	85 c0                	test   %eax,%eax
801054b6:	75 43                	jne    801054fb <memset+0x54>
801054b8:	8b 45 10             	mov    0x10(%ebp),%eax
801054bb:	83 e0 03             	and    $0x3,%eax
801054be:	85 c0                	test   %eax,%eax
801054c0:	75 39                	jne    801054fb <memset+0x54>
    c &= 0xFF;
801054c2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801054c9:	8b 45 10             	mov    0x10(%ebp),%eax
801054cc:	c1 e8 02             	shr    $0x2,%eax
801054cf:	89 c1                	mov    %eax,%ecx
801054d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d4:	c1 e0 18             	shl    $0x18,%eax
801054d7:	89 c2                	mov    %eax,%edx
801054d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801054dc:	c1 e0 10             	shl    $0x10,%eax
801054df:	09 c2                	or     %eax,%edx
801054e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801054e4:	c1 e0 08             	shl    $0x8,%eax
801054e7:	09 d0                	or     %edx,%eax
801054e9:	0b 45 0c             	or     0xc(%ebp),%eax
801054ec:	51                   	push   %ecx
801054ed:	50                   	push   %eax
801054ee:	ff 75 08             	pushl  0x8(%ebp)
801054f1:	e8 8b ff ff ff       	call   80105481 <stosl>
801054f6:	83 c4 0c             	add    $0xc,%esp
801054f9:	eb 12                	jmp    8010550d <memset+0x66>
  } else
    stosb(dst, c, n);
801054fb:	8b 45 10             	mov    0x10(%ebp),%eax
801054fe:	50                   	push   %eax
801054ff:	ff 75 0c             	pushl  0xc(%ebp)
80105502:	ff 75 08             	pushl  0x8(%ebp)
80105505:	e8 51 ff ff ff       	call   8010545b <stosb>
8010550a:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010550d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105510:	c9                   	leave  
80105511:	c3                   	ret    

80105512 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105512:	f3 0f 1e fb          	endbr32 
80105516:	55                   	push   %ebp
80105517:	89 e5                	mov    %esp,%ebp
80105519:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010551c:	8b 45 08             	mov    0x8(%ebp),%eax
8010551f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105522:	8b 45 0c             	mov    0xc(%ebp),%eax
80105525:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105528:	eb 30                	jmp    8010555a <memcmp+0x48>
    if(*s1 != *s2)
8010552a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010552d:	0f b6 10             	movzbl (%eax),%edx
80105530:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105533:	0f b6 00             	movzbl (%eax),%eax
80105536:	38 c2                	cmp    %al,%dl
80105538:	74 18                	je     80105552 <memcmp+0x40>
      return *s1 - *s2;
8010553a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010553d:	0f b6 00             	movzbl (%eax),%eax
80105540:	0f b6 d0             	movzbl %al,%edx
80105543:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105546:	0f b6 00             	movzbl (%eax),%eax
80105549:	0f b6 c0             	movzbl %al,%eax
8010554c:	29 c2                	sub    %eax,%edx
8010554e:	89 d0                	mov    %edx,%eax
80105550:	eb 1a                	jmp    8010556c <memcmp+0x5a>
    s1++, s2++;
80105552:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105556:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
8010555a:	8b 45 10             	mov    0x10(%ebp),%eax
8010555d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105560:	89 55 10             	mov    %edx,0x10(%ebp)
80105563:	85 c0                	test   %eax,%eax
80105565:	75 c3                	jne    8010552a <memcmp+0x18>
  }

  return 0;
80105567:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010556c:	c9                   	leave  
8010556d:	c3                   	ret    

8010556e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010556e:	f3 0f 1e fb          	endbr32 
80105572:	55                   	push   %ebp
80105573:	89 e5                	mov    %esp,%ebp
80105575:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105578:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010557e:	8b 45 08             	mov    0x8(%ebp),%eax
80105581:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105584:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105587:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010558a:	73 54                	jae    801055e0 <memmove+0x72>
8010558c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010558f:	8b 45 10             	mov    0x10(%ebp),%eax
80105592:	01 d0                	add    %edx,%eax
80105594:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105597:	73 47                	jae    801055e0 <memmove+0x72>
    s += n;
80105599:	8b 45 10             	mov    0x10(%ebp),%eax
8010559c:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010559f:	8b 45 10             	mov    0x10(%ebp),%eax
801055a2:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801055a5:	eb 13                	jmp    801055ba <memmove+0x4c>
      *--d = *--s;
801055a7:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801055ab:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801055af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b2:	0f b6 10             	movzbl (%eax),%edx
801055b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055b8:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801055ba:	8b 45 10             	mov    0x10(%ebp),%eax
801055bd:	8d 50 ff             	lea    -0x1(%eax),%edx
801055c0:	89 55 10             	mov    %edx,0x10(%ebp)
801055c3:	85 c0                	test   %eax,%eax
801055c5:	75 e0                	jne    801055a7 <memmove+0x39>
  if(s < d && s + n > d){
801055c7:	eb 24                	jmp    801055ed <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
801055c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055cc:	8d 42 01             	lea    0x1(%edx),%eax
801055cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055d5:	8d 48 01             	lea    0x1(%eax),%ecx
801055d8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801055db:	0f b6 12             	movzbl (%edx),%edx
801055de:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801055e0:	8b 45 10             	mov    0x10(%ebp),%eax
801055e3:	8d 50 ff             	lea    -0x1(%eax),%edx
801055e6:	89 55 10             	mov    %edx,0x10(%ebp)
801055e9:	85 c0                	test   %eax,%eax
801055eb:	75 dc                	jne    801055c9 <memmove+0x5b>

  return dst;
801055ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
801055f0:	c9                   	leave  
801055f1:	c3                   	ret    

801055f2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801055f2:	f3 0f 1e fb          	endbr32 
801055f6:	55                   	push   %ebp
801055f7:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801055f9:	ff 75 10             	pushl  0x10(%ebp)
801055fc:	ff 75 0c             	pushl  0xc(%ebp)
801055ff:	ff 75 08             	pushl  0x8(%ebp)
80105602:	e8 67 ff ff ff       	call   8010556e <memmove>
80105607:	83 c4 0c             	add    $0xc,%esp
}
8010560a:	c9                   	leave  
8010560b:	c3                   	ret    

8010560c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010560c:	f3 0f 1e fb          	endbr32 
80105610:	55                   	push   %ebp
80105611:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105613:	eb 0c                	jmp    80105621 <strncmp+0x15>
    n--, p++, q++;
80105615:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105619:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010561d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105621:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105625:	74 1a                	je     80105641 <strncmp+0x35>
80105627:	8b 45 08             	mov    0x8(%ebp),%eax
8010562a:	0f b6 00             	movzbl (%eax),%eax
8010562d:	84 c0                	test   %al,%al
8010562f:	74 10                	je     80105641 <strncmp+0x35>
80105631:	8b 45 08             	mov    0x8(%ebp),%eax
80105634:	0f b6 10             	movzbl (%eax),%edx
80105637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010563a:	0f b6 00             	movzbl (%eax),%eax
8010563d:	38 c2                	cmp    %al,%dl
8010563f:	74 d4                	je     80105615 <strncmp+0x9>
  if(n == 0)
80105641:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105645:	75 07                	jne    8010564e <strncmp+0x42>
    return 0;
80105647:	b8 00 00 00 00       	mov    $0x0,%eax
8010564c:	eb 16                	jmp    80105664 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
8010564e:	8b 45 08             	mov    0x8(%ebp),%eax
80105651:	0f b6 00             	movzbl (%eax),%eax
80105654:	0f b6 d0             	movzbl %al,%edx
80105657:	8b 45 0c             	mov    0xc(%ebp),%eax
8010565a:	0f b6 00             	movzbl (%eax),%eax
8010565d:	0f b6 c0             	movzbl %al,%eax
80105660:	29 c2                	sub    %eax,%edx
80105662:	89 d0                	mov    %edx,%eax
}
80105664:	5d                   	pop    %ebp
80105665:	c3                   	ret    

80105666 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105666:	f3 0f 1e fb          	endbr32 
8010566a:	55                   	push   %ebp
8010566b:	89 e5                	mov    %esp,%ebp
8010566d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105670:	8b 45 08             	mov    0x8(%ebp),%eax
80105673:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105676:	90                   	nop
80105677:	8b 45 10             	mov    0x10(%ebp),%eax
8010567a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010567d:	89 55 10             	mov    %edx,0x10(%ebp)
80105680:	85 c0                	test   %eax,%eax
80105682:	7e 2c                	jle    801056b0 <strncpy+0x4a>
80105684:	8b 55 0c             	mov    0xc(%ebp),%edx
80105687:	8d 42 01             	lea    0x1(%edx),%eax
8010568a:	89 45 0c             	mov    %eax,0xc(%ebp)
8010568d:	8b 45 08             	mov    0x8(%ebp),%eax
80105690:	8d 48 01             	lea    0x1(%eax),%ecx
80105693:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105696:	0f b6 12             	movzbl (%edx),%edx
80105699:	88 10                	mov    %dl,(%eax)
8010569b:	0f b6 00             	movzbl (%eax),%eax
8010569e:	84 c0                	test   %al,%al
801056a0:	75 d5                	jne    80105677 <strncpy+0x11>
    ;
  while(n-- > 0)
801056a2:	eb 0c                	jmp    801056b0 <strncpy+0x4a>
    *s++ = 0;
801056a4:	8b 45 08             	mov    0x8(%ebp),%eax
801056a7:	8d 50 01             	lea    0x1(%eax),%edx
801056aa:	89 55 08             	mov    %edx,0x8(%ebp)
801056ad:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801056b0:	8b 45 10             	mov    0x10(%ebp),%eax
801056b3:	8d 50 ff             	lea    -0x1(%eax),%edx
801056b6:	89 55 10             	mov    %edx,0x10(%ebp)
801056b9:	85 c0                	test   %eax,%eax
801056bb:	7f e7                	jg     801056a4 <strncpy+0x3e>
  return os;
801056bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056c0:	c9                   	leave  
801056c1:	c3                   	ret    

801056c2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801056c2:	f3 0f 1e fb          	endbr32 
801056c6:	55                   	push   %ebp
801056c7:	89 e5                	mov    %esp,%ebp
801056c9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801056cc:	8b 45 08             	mov    0x8(%ebp),%eax
801056cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801056d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056d6:	7f 05                	jg     801056dd <safestrcpy+0x1b>
    return os;
801056d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056db:	eb 31                	jmp    8010570e <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801056dd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056e5:	7e 1e                	jle    80105705 <safestrcpy+0x43>
801056e7:	8b 55 0c             	mov    0xc(%ebp),%edx
801056ea:	8d 42 01             	lea    0x1(%edx),%eax
801056ed:	89 45 0c             	mov    %eax,0xc(%ebp)
801056f0:	8b 45 08             	mov    0x8(%ebp),%eax
801056f3:	8d 48 01             	lea    0x1(%eax),%ecx
801056f6:	89 4d 08             	mov    %ecx,0x8(%ebp)
801056f9:	0f b6 12             	movzbl (%edx),%edx
801056fc:	88 10                	mov    %dl,(%eax)
801056fe:	0f b6 00             	movzbl (%eax),%eax
80105701:	84 c0                	test   %al,%al
80105703:	75 d8                	jne    801056dd <safestrcpy+0x1b>
    ;
  *s = 0;
80105705:	8b 45 08             	mov    0x8(%ebp),%eax
80105708:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010570b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010570e:	c9                   	leave  
8010570f:	c3                   	ret    

80105710 <strlen>:

int
strlen(const char *s)
{
80105710:	f3 0f 1e fb          	endbr32 
80105714:	55                   	push   %ebp
80105715:	89 e5                	mov    %esp,%ebp
80105717:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010571a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105721:	eb 04                	jmp    80105727 <strlen+0x17>
80105723:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105727:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010572a:	8b 45 08             	mov    0x8(%ebp),%eax
8010572d:	01 d0                	add    %edx,%eax
8010572f:	0f b6 00             	movzbl (%eax),%eax
80105732:	84 c0                	test   %al,%al
80105734:	75 ed                	jne    80105723 <strlen+0x13>
    ;
  return n;
80105736:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105739:	c9                   	leave  
8010573a:	c3                   	ret    

8010573b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010573b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010573f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105743:	55                   	push   %ebp
  pushl %ebx
80105744:	53                   	push   %ebx
  pushl %esi
80105745:	56                   	push   %esi
  pushl %edi
80105746:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105747:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105749:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010574b:	5f                   	pop    %edi
  popl %esi
8010574c:	5e                   	pop    %esi
  popl %ebx
8010574d:	5b                   	pop    %ebx
  popl %ebp
8010574e:	5d                   	pop    %ebp
  ret
8010574f:	c3                   	ret    

80105750 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105750:	f3 0f 1e fb          	endbr32 
80105754:	55                   	push   %ebp
80105755:	89 e5                	mov    %esp,%ebp
80105757:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010575a:	e8 42 e9 ff ff       	call   801040a1 <myproc>
8010575f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105765:	8b 00                	mov    (%eax),%eax
80105767:	39 45 08             	cmp    %eax,0x8(%ebp)
8010576a:	73 0f                	jae    8010577b <fetchint+0x2b>
8010576c:	8b 45 08             	mov    0x8(%ebp),%eax
8010576f:	8d 50 04             	lea    0x4(%eax),%edx
80105772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105775:	8b 00                	mov    (%eax),%eax
80105777:	39 c2                	cmp    %eax,%edx
80105779:	76 07                	jbe    80105782 <fetchint+0x32>
    return -1;
8010577b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105780:	eb 0f                	jmp    80105791 <fetchint+0x41>
  *ip = *(int*)(addr);
80105782:	8b 45 08             	mov    0x8(%ebp),%eax
80105785:	8b 10                	mov    (%eax),%edx
80105787:	8b 45 0c             	mov    0xc(%ebp),%eax
8010578a:	89 10                	mov    %edx,(%eax)
  return 0;
8010578c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105791:	c9                   	leave  
80105792:	c3                   	ret    

80105793 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105793:	f3 0f 1e fb          	endbr32 
80105797:	55                   	push   %ebp
80105798:	89 e5                	mov    %esp,%ebp
8010579a:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010579d:	e8 ff e8 ff ff       	call   801040a1 <myproc>
801057a2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801057a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a8:	8b 00                	mov    (%eax),%eax
801057aa:	39 45 08             	cmp    %eax,0x8(%ebp)
801057ad:	72 07                	jb     801057b6 <fetchstr+0x23>
    return -1;
801057af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b4:	eb 43                	jmp    801057f9 <fetchstr+0x66>
  *pp = (char*)addr;
801057b6:	8b 55 08             	mov    0x8(%ebp),%edx
801057b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801057bc:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801057be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057c1:	8b 00                	mov    (%eax),%eax
801057c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801057c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801057c9:	8b 00                	mov    (%eax),%eax
801057cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057ce:	eb 1c                	jmp    801057ec <fetchstr+0x59>
    if(*s == 0)
801057d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d3:	0f b6 00             	movzbl (%eax),%eax
801057d6:	84 c0                	test   %al,%al
801057d8:	75 0e                	jne    801057e8 <fetchstr+0x55>
      return s - *pp;
801057da:	8b 45 0c             	mov    0xc(%ebp),%eax
801057dd:	8b 00                	mov    (%eax),%eax
801057df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057e2:	29 c2                	sub    %eax,%edx
801057e4:	89 d0                	mov    %edx,%eax
801057e6:	eb 11                	jmp    801057f9 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
801057e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801057ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801057f2:	72 dc                	jb     801057d0 <fetchstr+0x3d>
  }
  return -1;
801057f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057f9:	c9                   	leave  
801057fa:	c3                   	ret    

801057fb <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801057fb:	f3 0f 1e fb          	endbr32 
801057ff:	55                   	push   %ebp
80105800:	89 e5                	mov    %esp,%ebp
80105802:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105805:	e8 97 e8 ff ff       	call   801040a1 <myproc>
8010580a:	8b 40 18             	mov    0x18(%eax),%eax
8010580d:	8b 40 44             	mov    0x44(%eax),%eax
80105810:	8b 55 08             	mov    0x8(%ebp),%edx
80105813:	c1 e2 02             	shl    $0x2,%edx
80105816:	01 d0                	add    %edx,%eax
80105818:	83 c0 04             	add    $0x4,%eax
8010581b:	83 ec 08             	sub    $0x8,%esp
8010581e:	ff 75 0c             	pushl  0xc(%ebp)
80105821:	50                   	push   %eax
80105822:	e8 29 ff ff ff       	call   80105750 <fetchint>
80105827:	83 c4 10             	add    $0x10,%esp
}
8010582a:	c9                   	leave  
8010582b:	c3                   	ret    

8010582c <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010582c:	f3 0f 1e fb          	endbr32 
80105830:	55                   	push   %ebp
80105831:	89 e5                	mov    %esp,%ebp
80105833:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105836:	e8 66 e8 ff ff       	call   801040a1 <myproc>
8010583b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010583e:	83 ec 08             	sub    $0x8,%esp
80105841:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105844:	50                   	push   %eax
80105845:	ff 75 08             	pushl  0x8(%ebp)
80105848:	e8 ae ff ff ff       	call   801057fb <argint>
8010584d:	83 c4 10             	add    $0x10,%esp
80105850:	85 c0                	test   %eax,%eax
80105852:	79 07                	jns    8010585b <argptr+0x2f>
    return -1;
80105854:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105859:	eb 3b                	jmp    80105896 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010585b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010585f:	78 1f                	js     80105880 <argptr+0x54>
80105861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105864:	8b 00                	mov    (%eax),%eax
80105866:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105869:	39 d0                	cmp    %edx,%eax
8010586b:	76 13                	jbe    80105880 <argptr+0x54>
8010586d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105870:	89 c2                	mov    %eax,%edx
80105872:	8b 45 10             	mov    0x10(%ebp),%eax
80105875:	01 c2                	add    %eax,%edx
80105877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587a:	8b 00                	mov    (%eax),%eax
8010587c:	39 c2                	cmp    %eax,%edx
8010587e:	76 07                	jbe    80105887 <argptr+0x5b>
    return -1;
80105880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105885:	eb 0f                	jmp    80105896 <argptr+0x6a>
  *pp = (char*)i;
80105887:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010588a:	89 c2                	mov    %eax,%edx
8010588c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010588f:	89 10                	mov    %edx,(%eax)
  return 0;
80105891:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105896:	c9                   	leave  
80105897:	c3                   	ret    

80105898 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105898:	f3 0f 1e fb          	endbr32 
8010589c:	55                   	push   %ebp
8010589d:	89 e5                	mov    %esp,%ebp
8010589f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801058a2:	83 ec 08             	sub    $0x8,%esp
801058a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058a8:	50                   	push   %eax
801058a9:	ff 75 08             	pushl  0x8(%ebp)
801058ac:	e8 4a ff ff ff       	call   801057fb <argint>
801058b1:	83 c4 10             	add    $0x10,%esp
801058b4:	85 c0                	test   %eax,%eax
801058b6:	79 07                	jns    801058bf <argstr+0x27>
    return -1;
801058b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bd:	eb 12                	jmp    801058d1 <argstr+0x39>
  return fetchstr(addr, pp);
801058bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c2:	83 ec 08             	sub    $0x8,%esp
801058c5:	ff 75 0c             	pushl  0xc(%ebp)
801058c8:	50                   	push   %eax
801058c9:	e8 c5 fe ff ff       	call   80105793 <fetchstr>
801058ce:	83 c4 10             	add    $0x10,%esp
}
801058d1:	c9                   	leave  
801058d2:	c3                   	ret    

801058d3 <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
801058d3:	f3 0f 1e fb          	endbr32 
801058d7:	55                   	push   %ebp
801058d8:	89 e5                	mov    %esp,%ebp
801058da:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
801058dd:	e8 bf e7 ff ff       	call   801040a1 <myproc>
801058e2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801058e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e8:	8b 40 18             	mov    0x18(%eax),%eax
801058eb:	8b 40 1c             	mov    0x1c(%eax),%eax
801058ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801058f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801058f5:	7e 2f                	jle    80105926 <syscall+0x53>
801058f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058fa:	83 f8 19             	cmp    $0x19,%eax
801058fd:	77 27                	ja     80105926 <syscall+0x53>
801058ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105902:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105909:	85 c0                	test   %eax,%eax
8010590b:	74 19                	je     80105926 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
8010590d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105910:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105917:	ff d0                	call   *%eax
80105919:	89 c2                	mov    %eax,%edx
8010591b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010591e:	8b 40 18             	mov    0x18(%eax),%eax
80105921:	89 50 1c             	mov    %edx,0x1c(%eax)
80105924:	eb 2c                	jmp    80105952 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105929:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
8010592c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010592f:	8b 40 10             	mov    0x10(%eax),%eax
80105932:	ff 75 f0             	pushl  -0x10(%ebp)
80105935:	52                   	push   %edx
80105936:	50                   	push   %eax
80105937:	68 65 b1 10 80       	push   $0x8010b165
8010593c:	e8 cb aa ff ff       	call   8010040c <cprintf>
80105941:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105947:	8b 40 18             	mov    0x18(%eax),%eax
8010594a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105951:	90                   	nop
80105952:	90                   	nop
80105953:	c9                   	leave  
80105954:	c3                   	ret    

80105955 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105955:	f3 0f 1e fb          	endbr32 
80105959:	55                   	push   %ebp
8010595a:	89 e5                	mov    %esp,%ebp
8010595c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010595f:	83 ec 08             	sub    $0x8,%esp
80105962:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105965:	50                   	push   %eax
80105966:	ff 75 08             	pushl  0x8(%ebp)
80105969:	e8 8d fe ff ff       	call   801057fb <argint>
8010596e:	83 c4 10             	add    $0x10,%esp
80105971:	85 c0                	test   %eax,%eax
80105973:	79 07                	jns    8010597c <argfd+0x27>
    return -1;
80105975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010597a:	eb 4f                	jmp    801059cb <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010597c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597f:	85 c0                	test   %eax,%eax
80105981:	78 20                	js     801059a3 <argfd+0x4e>
80105983:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105986:	83 f8 0f             	cmp    $0xf,%eax
80105989:	7f 18                	jg     801059a3 <argfd+0x4e>
8010598b:	e8 11 e7 ff ff       	call   801040a1 <myproc>
80105990:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105993:	83 c2 08             	add    $0x8,%edx
80105996:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010599a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010599d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059a1:	75 07                	jne    801059aa <argfd+0x55>
    return -1;
801059a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a8:	eb 21                	jmp    801059cb <argfd+0x76>
  if(pfd)
801059aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801059ae:	74 08                	je     801059b8 <argfd+0x63>
    *pfd = fd;
801059b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801059b6:	89 10                	mov    %edx,(%eax)
  if(pf)
801059b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801059bc:	74 08                	je     801059c6 <argfd+0x71>
    *pf = f;
801059be:	8b 45 10             	mov    0x10(%ebp),%eax
801059c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059c4:	89 10                	mov    %edx,(%eax)
  return 0;
801059c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059cb:	c9                   	leave  
801059cc:	c3                   	ret    

801059cd <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801059cd:	f3 0f 1e fb          	endbr32 
801059d1:	55                   	push   %ebp
801059d2:	89 e5                	mov    %esp,%ebp
801059d4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801059d7:	e8 c5 e6 ff ff       	call   801040a1 <myproc>
801059dc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801059df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801059e6:	eb 2a                	jmp    80105a12 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
801059e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059ee:	83 c2 08             	add    $0x8,%edx
801059f1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801059f5:	85 c0                	test   %eax,%eax
801059f7:	75 15                	jne    80105a0e <fdalloc+0x41>
      curproc->ofile[fd] = f;
801059f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059ff:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a02:	8b 55 08             	mov    0x8(%ebp),%edx
80105a05:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0c:	eb 0f                	jmp    80105a1d <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105a0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105a12:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105a16:	7e d0                	jle    801059e8 <fdalloc+0x1b>
    }
  }
  return -1;
80105a18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a1d:	c9                   	leave  
80105a1e:	c3                   	ret    

80105a1f <sys_dup>:

int
sys_dup(void)
{
80105a1f:	f3 0f 1e fb          	endbr32 
80105a23:	55                   	push   %ebp
80105a24:	89 e5                	mov    %esp,%ebp
80105a26:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105a29:	83 ec 04             	sub    $0x4,%esp
80105a2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a2f:	50                   	push   %eax
80105a30:	6a 00                	push   $0x0
80105a32:	6a 00                	push   $0x0
80105a34:	e8 1c ff ff ff       	call   80105955 <argfd>
80105a39:	83 c4 10             	add    $0x10,%esp
80105a3c:	85 c0                	test   %eax,%eax
80105a3e:	79 07                	jns    80105a47 <sys_dup+0x28>
    return -1;
80105a40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a45:	eb 31                	jmp    80105a78 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4a:	83 ec 0c             	sub    $0xc,%esp
80105a4d:	50                   	push   %eax
80105a4e:	e8 7a ff ff ff       	call   801059cd <fdalloc>
80105a53:	83 c4 10             	add    $0x10,%esp
80105a56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a5d:	79 07                	jns    80105a66 <sys_dup+0x47>
    return -1;
80105a5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a64:	eb 12                	jmp    80105a78 <sys_dup+0x59>
  filedup(f);
80105a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a69:	83 ec 0c             	sub    $0xc,%esp
80105a6c:	50                   	push   %eax
80105a6d:	e8 22 b6 ff ff       	call   80101094 <filedup>
80105a72:	83 c4 10             	add    $0x10,%esp
  return fd;
80105a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105a78:	c9                   	leave  
80105a79:	c3                   	ret    

80105a7a <sys_read>:

int
sys_read(void)
{
80105a7a:	f3 0f 1e fb          	endbr32 
80105a7e:	55                   	push   %ebp
80105a7f:	89 e5                	mov    %esp,%ebp
80105a81:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a84:	83 ec 04             	sub    $0x4,%esp
80105a87:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a8a:	50                   	push   %eax
80105a8b:	6a 00                	push   $0x0
80105a8d:	6a 00                	push   $0x0
80105a8f:	e8 c1 fe ff ff       	call   80105955 <argfd>
80105a94:	83 c4 10             	add    $0x10,%esp
80105a97:	85 c0                	test   %eax,%eax
80105a99:	78 2e                	js     80105ac9 <sys_read+0x4f>
80105a9b:	83 ec 08             	sub    $0x8,%esp
80105a9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aa1:	50                   	push   %eax
80105aa2:	6a 02                	push   $0x2
80105aa4:	e8 52 fd ff ff       	call   801057fb <argint>
80105aa9:	83 c4 10             	add    $0x10,%esp
80105aac:	85 c0                	test   %eax,%eax
80105aae:	78 19                	js     80105ac9 <sys_read+0x4f>
80105ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab3:	83 ec 04             	sub    $0x4,%esp
80105ab6:	50                   	push   %eax
80105ab7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aba:	50                   	push   %eax
80105abb:	6a 01                	push   $0x1
80105abd:	e8 6a fd ff ff       	call   8010582c <argptr>
80105ac2:	83 c4 10             	add    $0x10,%esp
80105ac5:	85 c0                	test   %eax,%eax
80105ac7:	79 07                	jns    80105ad0 <sys_read+0x56>
    return -1;
80105ac9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ace:	eb 17                	jmp    80105ae7 <sys_read+0x6d>
  return fileread(f, p, n);
80105ad0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ad3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad9:	83 ec 04             	sub    $0x4,%esp
80105adc:	51                   	push   %ecx
80105add:	52                   	push   %edx
80105ade:	50                   	push   %eax
80105adf:	e8 4c b7 ff ff       	call   80101230 <fileread>
80105ae4:	83 c4 10             	add    $0x10,%esp
}
80105ae7:	c9                   	leave  
80105ae8:	c3                   	ret    

80105ae9 <sys_write>:

int
sys_write(void)
{
80105ae9:	f3 0f 1e fb          	endbr32 
80105aed:	55                   	push   %ebp
80105aee:	89 e5                	mov    %esp,%ebp
80105af0:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105af3:	83 ec 04             	sub    $0x4,%esp
80105af6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105af9:	50                   	push   %eax
80105afa:	6a 00                	push   $0x0
80105afc:	6a 00                	push   $0x0
80105afe:	e8 52 fe ff ff       	call   80105955 <argfd>
80105b03:	83 c4 10             	add    $0x10,%esp
80105b06:	85 c0                	test   %eax,%eax
80105b08:	78 2e                	js     80105b38 <sys_write+0x4f>
80105b0a:	83 ec 08             	sub    $0x8,%esp
80105b0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b10:	50                   	push   %eax
80105b11:	6a 02                	push   $0x2
80105b13:	e8 e3 fc ff ff       	call   801057fb <argint>
80105b18:	83 c4 10             	add    $0x10,%esp
80105b1b:	85 c0                	test   %eax,%eax
80105b1d:	78 19                	js     80105b38 <sys_write+0x4f>
80105b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b22:	83 ec 04             	sub    $0x4,%esp
80105b25:	50                   	push   %eax
80105b26:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b29:	50                   	push   %eax
80105b2a:	6a 01                	push   $0x1
80105b2c:	e8 fb fc ff ff       	call   8010582c <argptr>
80105b31:	83 c4 10             	add    $0x10,%esp
80105b34:	85 c0                	test   %eax,%eax
80105b36:	79 07                	jns    80105b3f <sys_write+0x56>
    return -1;
80105b38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b3d:	eb 17                	jmp    80105b56 <sys_write+0x6d>
  return filewrite(f, p, n);
80105b3f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b42:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b48:	83 ec 04             	sub    $0x4,%esp
80105b4b:	51                   	push   %ecx
80105b4c:	52                   	push   %edx
80105b4d:	50                   	push   %eax
80105b4e:	e8 99 b7 ff ff       	call   801012ec <filewrite>
80105b53:	83 c4 10             	add    $0x10,%esp
}
80105b56:	c9                   	leave  
80105b57:	c3                   	ret    

80105b58 <sys_close>:

int
sys_close(void)
{
80105b58:	f3 0f 1e fb          	endbr32 
80105b5c:	55                   	push   %ebp
80105b5d:	89 e5                	mov    %esp,%ebp
80105b5f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105b62:	83 ec 04             	sub    $0x4,%esp
80105b65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b68:	50                   	push   %eax
80105b69:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b6c:	50                   	push   %eax
80105b6d:	6a 00                	push   $0x0
80105b6f:	e8 e1 fd ff ff       	call   80105955 <argfd>
80105b74:	83 c4 10             	add    $0x10,%esp
80105b77:	85 c0                	test   %eax,%eax
80105b79:	79 07                	jns    80105b82 <sys_close+0x2a>
    return -1;
80105b7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b80:	eb 27                	jmp    80105ba9 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105b82:	e8 1a e5 ff ff       	call   801040a1 <myproc>
80105b87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b8a:	83 c2 08             	add    $0x8,%edx
80105b8d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b94:	00 
  fileclose(f);
80105b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b98:	83 ec 0c             	sub    $0xc,%esp
80105b9b:	50                   	push   %eax
80105b9c:	e8 48 b5 ff ff       	call   801010e9 <fileclose>
80105ba1:	83 c4 10             	add    $0x10,%esp
  return 0;
80105ba4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ba9:	c9                   	leave  
80105baa:	c3                   	ret    

80105bab <sys_fstat>:

int
sys_fstat(void)
{
80105bab:	f3 0f 1e fb          	endbr32 
80105baf:	55                   	push   %ebp
80105bb0:	89 e5                	mov    %esp,%ebp
80105bb2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105bb5:	83 ec 04             	sub    $0x4,%esp
80105bb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bbb:	50                   	push   %eax
80105bbc:	6a 00                	push   $0x0
80105bbe:	6a 00                	push   $0x0
80105bc0:	e8 90 fd ff ff       	call   80105955 <argfd>
80105bc5:	83 c4 10             	add    $0x10,%esp
80105bc8:	85 c0                	test   %eax,%eax
80105bca:	78 17                	js     80105be3 <sys_fstat+0x38>
80105bcc:	83 ec 04             	sub    $0x4,%esp
80105bcf:	6a 14                	push   $0x14
80105bd1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bd4:	50                   	push   %eax
80105bd5:	6a 01                	push   $0x1
80105bd7:	e8 50 fc ff ff       	call   8010582c <argptr>
80105bdc:	83 c4 10             	add    $0x10,%esp
80105bdf:	85 c0                	test   %eax,%eax
80105be1:	79 07                	jns    80105bea <sys_fstat+0x3f>
    return -1;
80105be3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be8:	eb 13                	jmp    80105bfd <sys_fstat+0x52>
  return filestat(f, st);
80105bea:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf0:	83 ec 08             	sub    $0x8,%esp
80105bf3:	52                   	push   %edx
80105bf4:	50                   	push   %eax
80105bf5:	e8 db b5 ff ff       	call   801011d5 <filestat>
80105bfa:	83 c4 10             	add    $0x10,%esp
}
80105bfd:	c9                   	leave  
80105bfe:	c3                   	ret    

80105bff <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105bff:	f3 0f 1e fb          	endbr32 
80105c03:	55                   	push   %ebp
80105c04:	89 e5                	mov    %esp,%ebp
80105c06:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105c09:	83 ec 08             	sub    $0x8,%esp
80105c0c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105c0f:	50                   	push   %eax
80105c10:	6a 00                	push   $0x0
80105c12:	e8 81 fc ff ff       	call   80105898 <argstr>
80105c17:	83 c4 10             	add    $0x10,%esp
80105c1a:	85 c0                	test   %eax,%eax
80105c1c:	78 15                	js     80105c33 <sys_link+0x34>
80105c1e:	83 ec 08             	sub    $0x8,%esp
80105c21:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105c24:	50                   	push   %eax
80105c25:	6a 01                	push   $0x1
80105c27:	e8 6c fc ff ff       	call   80105898 <argstr>
80105c2c:	83 c4 10             	add    $0x10,%esp
80105c2f:	85 c0                	test   %eax,%eax
80105c31:	79 0a                	jns    80105c3d <sys_link+0x3e>
    return -1;
80105c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c38:	e9 68 01 00 00       	jmp    80105da5 <sys_link+0x1a6>

  begin_op();
80105c3d:	e8 27 da ff ff       	call   80103669 <begin_op>
  if((ip = namei(old)) == 0){
80105c42:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105c45:	83 ec 0c             	sub    $0xc,%esp
80105c48:	50                   	push   %eax
80105c49:	e8 99 c9 ff ff       	call   801025e7 <namei>
80105c4e:	83 c4 10             	add    $0x10,%esp
80105c51:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c58:	75 0f                	jne    80105c69 <sys_link+0x6a>
    end_op();
80105c5a:	e8 9a da ff ff       	call   801036f9 <end_op>
    return -1;
80105c5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c64:	e9 3c 01 00 00       	jmp    80105da5 <sys_link+0x1a6>
  }

  ilock(ip);
80105c69:	83 ec 0c             	sub    $0xc,%esp
80105c6c:	ff 75 f4             	pushl  -0xc(%ebp)
80105c6f:	e8 08 be ff ff       	call   80101a7c <ilock>
80105c74:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105c7e:	66 83 f8 01          	cmp    $0x1,%ax
80105c82:	75 1d                	jne    80105ca1 <sys_link+0xa2>
    iunlockput(ip);
80105c84:	83 ec 0c             	sub    $0xc,%esp
80105c87:	ff 75 f4             	pushl  -0xc(%ebp)
80105c8a:	e8 2a c0 ff ff       	call   80101cb9 <iunlockput>
80105c8f:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c92:	e8 62 da ff ff       	call   801036f9 <end_op>
    return -1;
80105c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9c:	e9 04 01 00 00       	jmp    80105da5 <sys_link+0x1a6>
  }

  ip->nlink++;
80105ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca4:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ca8:	83 c0 01             	add    $0x1,%eax
80105cab:	89 c2                	mov    %eax,%edx
80105cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb0:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105cb4:	83 ec 0c             	sub    $0xc,%esp
80105cb7:	ff 75 f4             	pushl  -0xc(%ebp)
80105cba:	e8 d4 bb ff ff       	call   80101893 <iupdate>
80105cbf:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105cc2:	83 ec 0c             	sub    $0xc,%esp
80105cc5:	ff 75 f4             	pushl  -0xc(%ebp)
80105cc8:	e8 c6 be ff ff       	call   80101b93 <iunlock>
80105ccd:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105cd0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105cd3:	83 ec 08             	sub    $0x8,%esp
80105cd6:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105cd9:	52                   	push   %edx
80105cda:	50                   	push   %eax
80105cdb:	e8 27 c9 ff ff       	call   80102607 <nameiparent>
80105ce0:	83 c4 10             	add    $0x10,%esp
80105ce3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ce6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cea:	74 71                	je     80105d5d <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105cec:	83 ec 0c             	sub    $0xc,%esp
80105cef:	ff 75 f0             	pushl  -0x10(%ebp)
80105cf2:	e8 85 bd ff ff       	call   80101a7c <ilock>
80105cf7:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cfd:	8b 10                	mov    (%eax),%edx
80105cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d02:	8b 00                	mov    (%eax),%eax
80105d04:	39 c2                	cmp    %eax,%edx
80105d06:	75 1d                	jne    80105d25 <sys_link+0x126>
80105d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0b:	8b 40 04             	mov    0x4(%eax),%eax
80105d0e:	83 ec 04             	sub    $0x4,%esp
80105d11:	50                   	push   %eax
80105d12:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105d15:	50                   	push   %eax
80105d16:	ff 75 f0             	pushl  -0x10(%ebp)
80105d19:	e8 26 c6 ff ff       	call   80102344 <dirlink>
80105d1e:	83 c4 10             	add    $0x10,%esp
80105d21:	85 c0                	test   %eax,%eax
80105d23:	79 10                	jns    80105d35 <sys_link+0x136>
    iunlockput(dp);
80105d25:	83 ec 0c             	sub    $0xc,%esp
80105d28:	ff 75 f0             	pushl  -0x10(%ebp)
80105d2b:	e8 89 bf ff ff       	call   80101cb9 <iunlockput>
80105d30:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d33:	eb 29                	jmp    80105d5e <sys_link+0x15f>
  }
  iunlockput(dp);
80105d35:	83 ec 0c             	sub    $0xc,%esp
80105d38:	ff 75 f0             	pushl  -0x10(%ebp)
80105d3b:	e8 79 bf ff ff       	call   80101cb9 <iunlockput>
80105d40:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105d43:	83 ec 0c             	sub    $0xc,%esp
80105d46:	ff 75 f4             	pushl  -0xc(%ebp)
80105d49:	e8 97 be ff ff       	call   80101be5 <iput>
80105d4e:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d51:	e8 a3 d9 ff ff       	call   801036f9 <end_op>

  return 0;
80105d56:	b8 00 00 00 00       	mov    $0x0,%eax
80105d5b:	eb 48                	jmp    80105da5 <sys_link+0x1a6>
    goto bad;
80105d5d:	90                   	nop

bad:
  ilock(ip);
80105d5e:	83 ec 0c             	sub    $0xc,%esp
80105d61:	ff 75 f4             	pushl  -0xc(%ebp)
80105d64:	e8 13 bd ff ff       	call   80101a7c <ilock>
80105d69:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d6f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d73:	83 e8 01             	sub    $0x1,%eax
80105d76:	89 c2                	mov    %eax,%edx
80105d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105d7f:	83 ec 0c             	sub    $0xc,%esp
80105d82:	ff 75 f4             	pushl  -0xc(%ebp)
80105d85:	e8 09 bb ff ff       	call   80101893 <iupdate>
80105d8a:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d8d:	83 ec 0c             	sub    $0xc,%esp
80105d90:	ff 75 f4             	pushl  -0xc(%ebp)
80105d93:	e8 21 bf ff ff       	call   80101cb9 <iunlockput>
80105d98:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d9b:	e8 59 d9 ff ff       	call   801036f9 <end_op>
  return -1;
80105da0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105da5:	c9                   	leave  
80105da6:	c3                   	ret    

80105da7 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105da7:	f3 0f 1e fb          	endbr32 
80105dab:	55                   	push   %ebp
80105dac:	89 e5                	mov    %esp,%ebp
80105dae:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105db1:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105db8:	eb 40                	jmp    80105dfa <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbd:	6a 10                	push   $0x10
80105dbf:	50                   	push   %eax
80105dc0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105dc3:	50                   	push   %eax
80105dc4:	ff 75 08             	pushl  0x8(%ebp)
80105dc7:	e8 b8 c1 ff ff       	call   80101f84 <readi>
80105dcc:	83 c4 10             	add    $0x10,%esp
80105dcf:	83 f8 10             	cmp    $0x10,%eax
80105dd2:	74 0d                	je     80105de1 <isdirempty+0x3a>
      panic("isdirempty: readi");
80105dd4:	83 ec 0c             	sub    $0xc,%esp
80105dd7:	68 81 b1 10 80       	push   $0x8010b181
80105ddc:	e8 e4 a7 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105de1:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105de5:	66 85 c0             	test   %ax,%ax
80105de8:	74 07                	je     80105df1 <isdirempty+0x4a>
      return 0;
80105dea:	b8 00 00 00 00       	mov    $0x0,%eax
80105def:	eb 1b                	jmp    80105e0c <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df4:	83 c0 10             	add    $0x10,%eax
80105df7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80105dfd:	8b 50 58             	mov    0x58(%eax),%edx
80105e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e03:	39 c2                	cmp    %eax,%edx
80105e05:	77 b3                	ja     80105dba <isdirempty+0x13>
  }
  return 1;
80105e07:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105e0c:	c9                   	leave  
80105e0d:	c3                   	ret    

80105e0e <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105e0e:	f3 0f 1e fb          	endbr32 
80105e12:	55                   	push   %ebp
80105e13:	89 e5                	mov    %esp,%ebp
80105e15:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105e18:	83 ec 08             	sub    $0x8,%esp
80105e1b:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105e1e:	50                   	push   %eax
80105e1f:	6a 00                	push   $0x0
80105e21:	e8 72 fa ff ff       	call   80105898 <argstr>
80105e26:	83 c4 10             	add    $0x10,%esp
80105e29:	85 c0                	test   %eax,%eax
80105e2b:	79 0a                	jns    80105e37 <sys_unlink+0x29>
    return -1;
80105e2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e32:	e9 bf 01 00 00       	jmp    80105ff6 <sys_unlink+0x1e8>

  begin_op();
80105e37:	e8 2d d8 ff ff       	call   80103669 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105e3c:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105e3f:	83 ec 08             	sub    $0x8,%esp
80105e42:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105e45:	52                   	push   %edx
80105e46:	50                   	push   %eax
80105e47:	e8 bb c7 ff ff       	call   80102607 <nameiparent>
80105e4c:	83 c4 10             	add    $0x10,%esp
80105e4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e56:	75 0f                	jne    80105e67 <sys_unlink+0x59>
    end_op();
80105e58:	e8 9c d8 ff ff       	call   801036f9 <end_op>
    return -1;
80105e5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e62:	e9 8f 01 00 00       	jmp    80105ff6 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105e67:	83 ec 0c             	sub    $0xc,%esp
80105e6a:	ff 75 f4             	pushl  -0xc(%ebp)
80105e6d:	e8 0a bc ff ff       	call   80101a7c <ilock>
80105e72:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105e75:	83 ec 08             	sub    $0x8,%esp
80105e78:	68 93 b1 10 80       	push   $0x8010b193
80105e7d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e80:	50                   	push   %eax
80105e81:	e8 e1 c3 ff ff       	call   80102267 <namecmp>
80105e86:	83 c4 10             	add    $0x10,%esp
80105e89:	85 c0                	test   %eax,%eax
80105e8b:	0f 84 49 01 00 00    	je     80105fda <sys_unlink+0x1cc>
80105e91:	83 ec 08             	sub    $0x8,%esp
80105e94:	68 95 b1 10 80       	push   $0x8010b195
80105e99:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e9c:	50                   	push   %eax
80105e9d:	e8 c5 c3 ff ff       	call   80102267 <namecmp>
80105ea2:	83 c4 10             	add    $0x10,%esp
80105ea5:	85 c0                	test   %eax,%eax
80105ea7:	0f 84 2d 01 00 00    	je     80105fda <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ead:	83 ec 04             	sub    $0x4,%esp
80105eb0:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105eb3:	50                   	push   %eax
80105eb4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105eb7:	50                   	push   %eax
80105eb8:	ff 75 f4             	pushl  -0xc(%ebp)
80105ebb:	e8 c6 c3 ff ff       	call   80102286 <dirlookup>
80105ec0:	83 c4 10             	add    $0x10,%esp
80105ec3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ec6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105eca:	0f 84 0d 01 00 00    	je     80105fdd <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105ed0:	83 ec 0c             	sub    $0xc,%esp
80105ed3:	ff 75 f0             	pushl  -0x10(%ebp)
80105ed6:	e8 a1 bb ff ff       	call   80101a7c <ilock>
80105edb:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee1:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105ee5:	66 85 c0             	test   %ax,%ax
80105ee8:	7f 0d                	jg     80105ef7 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105eea:	83 ec 0c             	sub    $0xc,%esp
80105eed:	68 98 b1 10 80       	push   $0x8010b198
80105ef2:	e8 ce a6 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efa:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105efe:	66 83 f8 01          	cmp    $0x1,%ax
80105f02:	75 25                	jne    80105f29 <sys_unlink+0x11b>
80105f04:	83 ec 0c             	sub    $0xc,%esp
80105f07:	ff 75 f0             	pushl  -0x10(%ebp)
80105f0a:	e8 98 fe ff ff       	call   80105da7 <isdirempty>
80105f0f:	83 c4 10             	add    $0x10,%esp
80105f12:	85 c0                	test   %eax,%eax
80105f14:	75 13                	jne    80105f29 <sys_unlink+0x11b>
    iunlockput(ip);
80105f16:	83 ec 0c             	sub    $0xc,%esp
80105f19:	ff 75 f0             	pushl  -0x10(%ebp)
80105f1c:	e8 98 bd ff ff       	call   80101cb9 <iunlockput>
80105f21:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105f24:	e9 b5 00 00 00       	jmp    80105fde <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105f29:	83 ec 04             	sub    $0x4,%esp
80105f2c:	6a 10                	push   $0x10
80105f2e:	6a 00                	push   $0x0
80105f30:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f33:	50                   	push   %eax
80105f34:	e8 6e f5 ff ff       	call   801054a7 <memset>
80105f39:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f3c:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105f3f:	6a 10                	push   $0x10
80105f41:	50                   	push   %eax
80105f42:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105f45:	50                   	push   %eax
80105f46:	ff 75 f4             	pushl  -0xc(%ebp)
80105f49:	e8 8f c1 ff ff       	call   801020dd <writei>
80105f4e:	83 c4 10             	add    $0x10,%esp
80105f51:	83 f8 10             	cmp    $0x10,%eax
80105f54:	74 0d                	je     80105f63 <sys_unlink+0x155>
    panic("unlink: writei");
80105f56:	83 ec 0c             	sub    $0xc,%esp
80105f59:	68 aa b1 10 80       	push   $0x8010b1aa
80105f5e:	e8 62 a6 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f66:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f6a:	66 83 f8 01          	cmp    $0x1,%ax
80105f6e:	75 21                	jne    80105f91 <sys_unlink+0x183>
    dp->nlink--;
80105f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f73:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f77:	83 e8 01             	sub    $0x1,%eax
80105f7a:	89 c2                	mov    %eax,%edx
80105f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f7f:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105f83:	83 ec 0c             	sub    $0xc,%esp
80105f86:	ff 75 f4             	pushl  -0xc(%ebp)
80105f89:	e8 05 b9 ff ff       	call   80101893 <iupdate>
80105f8e:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105f91:	83 ec 0c             	sub    $0xc,%esp
80105f94:	ff 75 f4             	pushl  -0xc(%ebp)
80105f97:	e8 1d bd ff ff       	call   80101cb9 <iunlockput>
80105f9c:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa2:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105fa6:	83 e8 01             	sub    $0x1,%eax
80105fa9:	89 c2                	mov    %eax,%edx
80105fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fae:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105fb2:	83 ec 0c             	sub    $0xc,%esp
80105fb5:	ff 75 f0             	pushl  -0x10(%ebp)
80105fb8:	e8 d6 b8 ff ff       	call   80101893 <iupdate>
80105fbd:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105fc0:	83 ec 0c             	sub    $0xc,%esp
80105fc3:	ff 75 f0             	pushl  -0x10(%ebp)
80105fc6:	e8 ee bc ff ff       	call   80101cb9 <iunlockput>
80105fcb:	83 c4 10             	add    $0x10,%esp

  end_op();
80105fce:	e8 26 d7 ff ff       	call   801036f9 <end_op>

  return 0;
80105fd3:	b8 00 00 00 00       	mov    $0x0,%eax
80105fd8:	eb 1c                	jmp    80105ff6 <sys_unlink+0x1e8>
    goto bad;
80105fda:	90                   	nop
80105fdb:	eb 01                	jmp    80105fde <sys_unlink+0x1d0>
    goto bad;
80105fdd:	90                   	nop

bad:
  iunlockput(dp);
80105fde:	83 ec 0c             	sub    $0xc,%esp
80105fe1:	ff 75 f4             	pushl  -0xc(%ebp)
80105fe4:	e8 d0 bc ff ff       	call   80101cb9 <iunlockput>
80105fe9:	83 c4 10             	add    $0x10,%esp
  end_op();
80105fec:	e8 08 d7 ff ff       	call   801036f9 <end_op>
  return -1;
80105ff1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ff6:	c9                   	leave  
80105ff7:	c3                   	ret    

80105ff8 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105ff8:	f3 0f 1e fb          	endbr32 
80105ffc:	55                   	push   %ebp
80105ffd:	89 e5                	mov    %esp,%ebp
80105fff:	83 ec 38             	sub    $0x38,%esp
80106002:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106005:	8b 55 10             	mov    0x10(%ebp),%edx
80106008:	8b 45 14             	mov    0x14(%ebp),%eax
8010600b:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010600f:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106013:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106017:	83 ec 08             	sub    $0x8,%esp
8010601a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010601d:	50                   	push   %eax
8010601e:	ff 75 08             	pushl  0x8(%ebp)
80106021:	e8 e1 c5 ff ff       	call   80102607 <nameiparent>
80106026:	83 c4 10             	add    $0x10,%esp
80106029:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010602c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106030:	75 0a                	jne    8010603c <create+0x44>
    return 0;
80106032:	b8 00 00 00 00       	mov    $0x0,%eax
80106037:	e9 90 01 00 00       	jmp    801061cc <create+0x1d4>
  ilock(dp);
8010603c:	83 ec 0c             	sub    $0xc,%esp
8010603f:	ff 75 f4             	pushl  -0xc(%ebp)
80106042:	e8 35 ba ff ff       	call   80101a7c <ilock>
80106047:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
8010604a:	83 ec 04             	sub    $0x4,%esp
8010604d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106050:	50                   	push   %eax
80106051:	8d 45 de             	lea    -0x22(%ebp),%eax
80106054:	50                   	push   %eax
80106055:	ff 75 f4             	pushl  -0xc(%ebp)
80106058:	e8 29 c2 ff ff       	call   80102286 <dirlookup>
8010605d:	83 c4 10             	add    $0x10,%esp
80106060:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106063:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106067:	74 50                	je     801060b9 <create+0xc1>
    iunlockput(dp);
80106069:	83 ec 0c             	sub    $0xc,%esp
8010606c:	ff 75 f4             	pushl  -0xc(%ebp)
8010606f:	e8 45 bc ff ff       	call   80101cb9 <iunlockput>
80106074:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106077:	83 ec 0c             	sub    $0xc,%esp
8010607a:	ff 75 f0             	pushl  -0x10(%ebp)
8010607d:	e8 fa b9 ff ff       	call   80101a7c <ilock>
80106082:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106085:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010608a:	75 15                	jne    801060a1 <create+0xa9>
8010608c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010608f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106093:	66 83 f8 02          	cmp    $0x2,%ax
80106097:	75 08                	jne    801060a1 <create+0xa9>
      return ip;
80106099:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609c:	e9 2b 01 00 00       	jmp    801061cc <create+0x1d4>
    iunlockput(ip);
801060a1:	83 ec 0c             	sub    $0xc,%esp
801060a4:	ff 75 f0             	pushl  -0x10(%ebp)
801060a7:	e8 0d bc ff ff       	call   80101cb9 <iunlockput>
801060ac:	83 c4 10             	add    $0x10,%esp
    return 0;
801060af:	b8 00 00 00 00       	mov    $0x0,%eax
801060b4:	e9 13 01 00 00       	jmp    801061cc <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801060b9:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801060bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c0:	8b 00                	mov    (%eax),%eax
801060c2:	83 ec 08             	sub    $0x8,%esp
801060c5:	52                   	push   %edx
801060c6:	50                   	push   %eax
801060c7:	e8 ec b6 ff ff       	call   801017b8 <ialloc>
801060cc:	83 c4 10             	add    $0x10,%esp
801060cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060d6:	75 0d                	jne    801060e5 <create+0xed>
    panic("create: ialloc");
801060d8:	83 ec 0c             	sub    $0xc,%esp
801060db:	68 b9 b1 10 80       	push   $0x8010b1b9
801060e0:	e8 e0 a4 ff ff       	call   801005c5 <panic>

  ilock(ip);
801060e5:	83 ec 0c             	sub    $0xc,%esp
801060e8:	ff 75 f0             	pushl  -0x10(%ebp)
801060eb:	e8 8c b9 ff ff       	call   80101a7c <ilock>
801060f0:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801060f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f6:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801060fa:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801060fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106101:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106105:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80106109:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010610c:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106112:	83 ec 0c             	sub    $0xc,%esp
80106115:	ff 75 f0             	pushl  -0x10(%ebp)
80106118:	e8 76 b7 ff ff       	call   80101893 <iupdate>
8010611d:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106120:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106125:	75 6a                	jne    80106191 <create+0x199>
    dp->nlink++;  // for ".."
80106127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010612e:	83 c0 01             	add    $0x1,%eax
80106131:	89 c2                	mov    %eax,%edx
80106133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106136:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010613a:	83 ec 0c             	sub    $0xc,%esp
8010613d:	ff 75 f4             	pushl  -0xc(%ebp)
80106140:	e8 4e b7 ff ff       	call   80101893 <iupdate>
80106145:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106148:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010614b:	8b 40 04             	mov    0x4(%eax),%eax
8010614e:	83 ec 04             	sub    $0x4,%esp
80106151:	50                   	push   %eax
80106152:	68 93 b1 10 80       	push   $0x8010b193
80106157:	ff 75 f0             	pushl  -0x10(%ebp)
8010615a:	e8 e5 c1 ff ff       	call   80102344 <dirlink>
8010615f:	83 c4 10             	add    $0x10,%esp
80106162:	85 c0                	test   %eax,%eax
80106164:	78 1e                	js     80106184 <create+0x18c>
80106166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106169:	8b 40 04             	mov    0x4(%eax),%eax
8010616c:	83 ec 04             	sub    $0x4,%esp
8010616f:	50                   	push   %eax
80106170:	68 95 b1 10 80       	push   $0x8010b195
80106175:	ff 75 f0             	pushl  -0x10(%ebp)
80106178:	e8 c7 c1 ff ff       	call   80102344 <dirlink>
8010617d:	83 c4 10             	add    $0x10,%esp
80106180:	85 c0                	test   %eax,%eax
80106182:	79 0d                	jns    80106191 <create+0x199>
      panic("create dots");
80106184:	83 ec 0c             	sub    $0xc,%esp
80106187:	68 c8 b1 10 80       	push   $0x8010b1c8
8010618c:	e8 34 a4 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106191:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106194:	8b 40 04             	mov    0x4(%eax),%eax
80106197:	83 ec 04             	sub    $0x4,%esp
8010619a:	50                   	push   %eax
8010619b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010619e:	50                   	push   %eax
8010619f:	ff 75 f4             	pushl  -0xc(%ebp)
801061a2:	e8 9d c1 ff ff       	call   80102344 <dirlink>
801061a7:	83 c4 10             	add    $0x10,%esp
801061aa:	85 c0                	test   %eax,%eax
801061ac:	79 0d                	jns    801061bb <create+0x1c3>
    panic("create: dirlink");
801061ae:	83 ec 0c             	sub    $0xc,%esp
801061b1:	68 d4 b1 10 80       	push   $0x8010b1d4
801061b6:	e8 0a a4 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
801061bb:	83 ec 0c             	sub    $0xc,%esp
801061be:	ff 75 f4             	pushl  -0xc(%ebp)
801061c1:	e8 f3 ba ff ff       	call   80101cb9 <iunlockput>
801061c6:	83 c4 10             	add    $0x10,%esp

  return ip;
801061c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801061cc:	c9                   	leave  
801061cd:	c3                   	ret    

801061ce <sys_open>:

int
sys_open(void)
{
801061ce:	f3 0f 1e fb          	endbr32 
801061d2:	55                   	push   %ebp
801061d3:	89 e5                	mov    %esp,%ebp
801061d5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801061d8:	83 ec 08             	sub    $0x8,%esp
801061db:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061de:	50                   	push   %eax
801061df:	6a 00                	push   $0x0
801061e1:	e8 b2 f6 ff ff       	call   80105898 <argstr>
801061e6:	83 c4 10             	add    $0x10,%esp
801061e9:	85 c0                	test   %eax,%eax
801061eb:	78 15                	js     80106202 <sys_open+0x34>
801061ed:	83 ec 08             	sub    $0x8,%esp
801061f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061f3:	50                   	push   %eax
801061f4:	6a 01                	push   $0x1
801061f6:	e8 00 f6 ff ff       	call   801057fb <argint>
801061fb:	83 c4 10             	add    $0x10,%esp
801061fe:	85 c0                	test   %eax,%eax
80106200:	79 0a                	jns    8010620c <sys_open+0x3e>
    return -1;
80106202:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106207:	e9 61 01 00 00       	jmp    8010636d <sys_open+0x19f>

  begin_op();
8010620c:	e8 58 d4 ff ff       	call   80103669 <begin_op>

  if(omode & O_CREATE){
80106211:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106214:	25 00 02 00 00       	and    $0x200,%eax
80106219:	85 c0                	test   %eax,%eax
8010621b:	74 2a                	je     80106247 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
8010621d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106220:	6a 00                	push   $0x0
80106222:	6a 00                	push   $0x0
80106224:	6a 02                	push   $0x2
80106226:	50                   	push   %eax
80106227:	e8 cc fd ff ff       	call   80105ff8 <create>
8010622c:	83 c4 10             	add    $0x10,%esp
8010622f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106232:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106236:	75 75                	jne    801062ad <sys_open+0xdf>
      end_op();
80106238:	e8 bc d4 ff ff       	call   801036f9 <end_op>
      return -1;
8010623d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106242:	e9 26 01 00 00       	jmp    8010636d <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106247:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010624a:	83 ec 0c             	sub    $0xc,%esp
8010624d:	50                   	push   %eax
8010624e:	e8 94 c3 ff ff       	call   801025e7 <namei>
80106253:	83 c4 10             	add    $0x10,%esp
80106256:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106259:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010625d:	75 0f                	jne    8010626e <sys_open+0xa0>
      end_op();
8010625f:	e8 95 d4 ff ff       	call   801036f9 <end_op>
      return -1;
80106264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106269:	e9 ff 00 00 00       	jmp    8010636d <sys_open+0x19f>
    }
    ilock(ip);
8010626e:	83 ec 0c             	sub    $0xc,%esp
80106271:	ff 75 f4             	pushl  -0xc(%ebp)
80106274:	e8 03 b8 ff ff       	call   80101a7c <ilock>
80106279:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010627c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106283:	66 83 f8 01          	cmp    $0x1,%ax
80106287:	75 24                	jne    801062ad <sys_open+0xdf>
80106289:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010628c:	85 c0                	test   %eax,%eax
8010628e:	74 1d                	je     801062ad <sys_open+0xdf>
      iunlockput(ip);
80106290:	83 ec 0c             	sub    $0xc,%esp
80106293:	ff 75 f4             	pushl  -0xc(%ebp)
80106296:	e8 1e ba ff ff       	call   80101cb9 <iunlockput>
8010629b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010629e:	e8 56 d4 ff ff       	call   801036f9 <end_op>
      return -1;
801062a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a8:	e9 c0 00 00 00       	jmp    8010636d <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801062ad:	e8 71 ad ff ff       	call   80101023 <filealloc>
801062b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062b9:	74 17                	je     801062d2 <sys_open+0x104>
801062bb:	83 ec 0c             	sub    $0xc,%esp
801062be:	ff 75 f0             	pushl  -0x10(%ebp)
801062c1:	e8 07 f7 ff ff       	call   801059cd <fdalloc>
801062c6:	83 c4 10             	add    $0x10,%esp
801062c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801062cc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801062d0:	79 2e                	jns    80106300 <sys_open+0x132>
    if(f)
801062d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062d6:	74 0e                	je     801062e6 <sys_open+0x118>
      fileclose(f);
801062d8:	83 ec 0c             	sub    $0xc,%esp
801062db:	ff 75 f0             	pushl  -0x10(%ebp)
801062de:	e8 06 ae ff ff       	call   801010e9 <fileclose>
801062e3:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801062e6:	83 ec 0c             	sub    $0xc,%esp
801062e9:	ff 75 f4             	pushl  -0xc(%ebp)
801062ec:	e8 c8 b9 ff ff       	call   80101cb9 <iunlockput>
801062f1:	83 c4 10             	add    $0x10,%esp
    end_op();
801062f4:	e8 00 d4 ff ff       	call   801036f9 <end_op>
    return -1;
801062f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062fe:	eb 6d                	jmp    8010636d <sys_open+0x19f>
  }
  iunlock(ip);
80106300:	83 ec 0c             	sub    $0xc,%esp
80106303:	ff 75 f4             	pushl  -0xc(%ebp)
80106306:	e8 88 b8 ff ff       	call   80101b93 <iunlock>
8010630b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010630e:	e8 e6 d3 ff ff       	call   801036f9 <end_op>

  f->type = FD_INODE;
80106313:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106316:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010631c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010631f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106322:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106325:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106328:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010632f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106332:	83 e0 01             	and    $0x1,%eax
80106335:	85 c0                	test   %eax,%eax
80106337:	0f 94 c0             	sete   %al
8010633a:	89 c2                	mov    %eax,%edx
8010633c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010633f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106342:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106345:	83 e0 01             	and    $0x1,%eax
80106348:	85 c0                	test   %eax,%eax
8010634a:	75 0a                	jne    80106356 <sys_open+0x188>
8010634c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010634f:	83 e0 02             	and    $0x2,%eax
80106352:	85 c0                	test   %eax,%eax
80106354:	74 07                	je     8010635d <sys_open+0x18f>
80106356:	b8 01 00 00 00       	mov    $0x1,%eax
8010635b:	eb 05                	jmp    80106362 <sys_open+0x194>
8010635d:	b8 00 00 00 00       	mov    $0x0,%eax
80106362:	89 c2                	mov    %eax,%edx
80106364:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106367:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010636a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010636d:	c9                   	leave  
8010636e:	c3                   	ret    

8010636f <sys_mkdir>:

int
sys_mkdir(void)
{
8010636f:	f3 0f 1e fb          	endbr32 
80106373:	55                   	push   %ebp
80106374:	89 e5                	mov    %esp,%ebp
80106376:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106379:	e8 eb d2 ff ff       	call   80103669 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010637e:	83 ec 08             	sub    $0x8,%esp
80106381:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106384:	50                   	push   %eax
80106385:	6a 00                	push   $0x0
80106387:	e8 0c f5 ff ff       	call   80105898 <argstr>
8010638c:	83 c4 10             	add    $0x10,%esp
8010638f:	85 c0                	test   %eax,%eax
80106391:	78 1b                	js     801063ae <sys_mkdir+0x3f>
80106393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106396:	6a 00                	push   $0x0
80106398:	6a 00                	push   $0x0
8010639a:	6a 01                	push   $0x1
8010639c:	50                   	push   %eax
8010639d:	e8 56 fc ff ff       	call   80105ff8 <create>
801063a2:	83 c4 10             	add    $0x10,%esp
801063a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063ac:	75 0c                	jne    801063ba <sys_mkdir+0x4b>
    end_op();
801063ae:	e8 46 d3 ff ff       	call   801036f9 <end_op>
    return -1;
801063b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b8:	eb 18                	jmp    801063d2 <sys_mkdir+0x63>
  }
  iunlockput(ip);
801063ba:	83 ec 0c             	sub    $0xc,%esp
801063bd:	ff 75 f4             	pushl  -0xc(%ebp)
801063c0:	e8 f4 b8 ff ff       	call   80101cb9 <iunlockput>
801063c5:	83 c4 10             	add    $0x10,%esp
  end_op();
801063c8:	e8 2c d3 ff ff       	call   801036f9 <end_op>
  return 0;
801063cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063d2:	c9                   	leave  
801063d3:	c3                   	ret    

801063d4 <sys_mknod>:

int
sys_mknod(void)
{
801063d4:	f3 0f 1e fb          	endbr32 
801063d8:	55                   	push   %ebp
801063d9:	89 e5                	mov    %esp,%ebp
801063db:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801063de:	e8 86 d2 ff ff       	call   80103669 <begin_op>
  if((argstr(0, &path)) < 0 ||
801063e3:	83 ec 08             	sub    $0x8,%esp
801063e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063e9:	50                   	push   %eax
801063ea:	6a 00                	push   $0x0
801063ec:	e8 a7 f4 ff ff       	call   80105898 <argstr>
801063f1:	83 c4 10             	add    $0x10,%esp
801063f4:	85 c0                	test   %eax,%eax
801063f6:	78 4f                	js     80106447 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
801063f8:	83 ec 08             	sub    $0x8,%esp
801063fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063fe:	50                   	push   %eax
801063ff:	6a 01                	push   $0x1
80106401:	e8 f5 f3 ff ff       	call   801057fb <argint>
80106406:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106409:	85 c0                	test   %eax,%eax
8010640b:	78 3a                	js     80106447 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
8010640d:	83 ec 08             	sub    $0x8,%esp
80106410:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106413:	50                   	push   %eax
80106414:	6a 02                	push   $0x2
80106416:	e8 e0 f3 ff ff       	call   801057fb <argint>
8010641b:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010641e:	85 c0                	test   %eax,%eax
80106420:	78 25                	js     80106447 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
80106422:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106425:	0f bf c8             	movswl %ax,%ecx
80106428:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010642b:	0f bf d0             	movswl %ax,%edx
8010642e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106431:	51                   	push   %ecx
80106432:	52                   	push   %edx
80106433:	6a 03                	push   $0x3
80106435:	50                   	push   %eax
80106436:	e8 bd fb ff ff       	call   80105ff8 <create>
8010643b:	83 c4 10             	add    $0x10,%esp
8010643e:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80106441:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106445:	75 0c                	jne    80106453 <sys_mknod+0x7f>
    end_op();
80106447:	e8 ad d2 ff ff       	call   801036f9 <end_op>
    return -1;
8010644c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106451:	eb 18                	jmp    8010646b <sys_mknod+0x97>
  }
  iunlockput(ip);
80106453:	83 ec 0c             	sub    $0xc,%esp
80106456:	ff 75 f4             	pushl  -0xc(%ebp)
80106459:	e8 5b b8 ff ff       	call   80101cb9 <iunlockput>
8010645e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106461:	e8 93 d2 ff ff       	call   801036f9 <end_op>
  return 0;
80106466:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010646b:	c9                   	leave  
8010646c:	c3                   	ret    

8010646d <sys_chdir>:

int
sys_chdir(void)
{
8010646d:	f3 0f 1e fb          	endbr32 
80106471:	55                   	push   %ebp
80106472:	89 e5                	mov    %esp,%ebp
80106474:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106477:	e8 25 dc ff ff       	call   801040a1 <myproc>
8010647c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010647f:	e8 e5 d1 ff ff       	call   80103669 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106484:	83 ec 08             	sub    $0x8,%esp
80106487:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010648a:	50                   	push   %eax
8010648b:	6a 00                	push   $0x0
8010648d:	e8 06 f4 ff ff       	call   80105898 <argstr>
80106492:	83 c4 10             	add    $0x10,%esp
80106495:	85 c0                	test   %eax,%eax
80106497:	78 18                	js     801064b1 <sys_chdir+0x44>
80106499:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010649c:	83 ec 0c             	sub    $0xc,%esp
8010649f:	50                   	push   %eax
801064a0:	e8 42 c1 ff ff       	call   801025e7 <namei>
801064a5:	83 c4 10             	add    $0x10,%esp
801064a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064af:	75 0c                	jne    801064bd <sys_chdir+0x50>
    end_op();
801064b1:	e8 43 d2 ff ff       	call   801036f9 <end_op>
    return -1;
801064b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064bb:	eb 68                	jmp    80106525 <sys_chdir+0xb8>
  }
  ilock(ip);
801064bd:	83 ec 0c             	sub    $0xc,%esp
801064c0:	ff 75 f0             	pushl  -0x10(%ebp)
801064c3:	e8 b4 b5 ff ff       	call   80101a7c <ilock>
801064c8:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801064cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ce:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801064d2:	66 83 f8 01          	cmp    $0x1,%ax
801064d6:	74 1a                	je     801064f2 <sys_chdir+0x85>
    iunlockput(ip);
801064d8:	83 ec 0c             	sub    $0xc,%esp
801064db:	ff 75 f0             	pushl  -0x10(%ebp)
801064de:	e8 d6 b7 ff ff       	call   80101cb9 <iunlockput>
801064e3:	83 c4 10             	add    $0x10,%esp
    end_op();
801064e6:	e8 0e d2 ff ff       	call   801036f9 <end_op>
    return -1;
801064eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f0:	eb 33                	jmp    80106525 <sys_chdir+0xb8>
  }
  iunlock(ip);
801064f2:	83 ec 0c             	sub    $0xc,%esp
801064f5:	ff 75 f0             	pushl  -0x10(%ebp)
801064f8:	e8 96 b6 ff ff       	call   80101b93 <iunlock>
801064fd:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80106500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106503:	8b 40 68             	mov    0x68(%eax),%eax
80106506:	83 ec 0c             	sub    $0xc,%esp
80106509:	50                   	push   %eax
8010650a:	e8 d6 b6 ff ff       	call   80101be5 <iput>
8010650f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106512:	e8 e2 d1 ff ff       	call   801036f9 <end_op>
  curproc->cwd = ip;
80106517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010651d:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106520:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106525:	c9                   	leave  
80106526:	c3                   	ret    

80106527 <sys_exec>:

int
sys_exec(void)
{
80106527:	f3 0f 1e fb          	endbr32 
8010652b:	55                   	push   %ebp
8010652c:	89 e5                	mov    %esp,%ebp
8010652e:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106534:	83 ec 08             	sub    $0x8,%esp
80106537:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010653a:	50                   	push   %eax
8010653b:	6a 00                	push   $0x0
8010653d:	e8 56 f3 ff ff       	call   80105898 <argstr>
80106542:	83 c4 10             	add    $0x10,%esp
80106545:	85 c0                	test   %eax,%eax
80106547:	78 18                	js     80106561 <sys_exec+0x3a>
80106549:	83 ec 08             	sub    $0x8,%esp
8010654c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106552:	50                   	push   %eax
80106553:	6a 01                	push   $0x1
80106555:	e8 a1 f2 ff ff       	call   801057fb <argint>
8010655a:	83 c4 10             	add    $0x10,%esp
8010655d:	85 c0                	test   %eax,%eax
8010655f:	79 0a                	jns    8010656b <sys_exec+0x44>
    return -1;
80106561:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106566:	e9 c6 00 00 00       	jmp    80106631 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
8010656b:	83 ec 04             	sub    $0x4,%esp
8010656e:	68 80 00 00 00       	push   $0x80
80106573:	6a 00                	push   $0x0
80106575:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010657b:	50                   	push   %eax
8010657c:	e8 26 ef ff ff       	call   801054a7 <memset>
80106581:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106584:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010658b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658e:	83 f8 1f             	cmp    $0x1f,%eax
80106591:	76 0a                	jbe    8010659d <sys_exec+0x76>
      return -1;
80106593:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106598:	e9 94 00 00 00       	jmp    80106631 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010659d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a0:	c1 e0 02             	shl    $0x2,%eax
801065a3:	89 c2                	mov    %eax,%edx
801065a5:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801065ab:	01 c2                	add    %eax,%edx
801065ad:	83 ec 08             	sub    $0x8,%esp
801065b0:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801065b6:	50                   	push   %eax
801065b7:	52                   	push   %edx
801065b8:	e8 93 f1 ff ff       	call   80105750 <fetchint>
801065bd:	83 c4 10             	add    $0x10,%esp
801065c0:	85 c0                	test   %eax,%eax
801065c2:	79 07                	jns    801065cb <sys_exec+0xa4>
      return -1;
801065c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c9:	eb 66                	jmp    80106631 <sys_exec+0x10a>
    if(uarg == 0){
801065cb:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801065d1:	85 c0                	test   %eax,%eax
801065d3:	75 27                	jne    801065fc <sys_exec+0xd5>
      argv[i] = 0;
801065d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d8:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801065df:	00 00 00 00 
      break;
801065e3:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801065e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e7:	83 ec 08             	sub    $0x8,%esp
801065ea:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801065f0:	52                   	push   %edx
801065f1:	50                   	push   %eax
801065f2:	e8 c7 a5 ff ff       	call   80100bbe <exec>
801065f7:	83 c4 10             	add    $0x10,%esp
801065fa:	eb 35                	jmp    80106631 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801065fc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106602:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106605:	c1 e2 02             	shl    $0x2,%edx
80106608:	01 c2                	add    %eax,%edx
8010660a:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106610:	83 ec 08             	sub    $0x8,%esp
80106613:	52                   	push   %edx
80106614:	50                   	push   %eax
80106615:	e8 79 f1 ff ff       	call   80105793 <fetchstr>
8010661a:	83 c4 10             	add    $0x10,%esp
8010661d:	85 c0                	test   %eax,%eax
8010661f:	79 07                	jns    80106628 <sys_exec+0x101>
      return -1;
80106621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106626:	eb 09                	jmp    80106631 <sys_exec+0x10a>
  for(i=0;; i++){
80106628:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
8010662c:	e9 5a ff ff ff       	jmp    8010658b <sys_exec+0x64>
}
80106631:	c9                   	leave  
80106632:	c3                   	ret    

80106633 <sys_pipe>:

int
sys_pipe(void)
{
80106633:	f3 0f 1e fb          	endbr32 
80106637:	55                   	push   %ebp
80106638:	89 e5                	mov    %esp,%ebp
8010663a:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010663d:	83 ec 04             	sub    $0x4,%esp
80106640:	6a 08                	push   $0x8
80106642:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106645:	50                   	push   %eax
80106646:	6a 00                	push   $0x0
80106648:	e8 df f1 ff ff       	call   8010582c <argptr>
8010664d:	83 c4 10             	add    $0x10,%esp
80106650:	85 c0                	test   %eax,%eax
80106652:	79 0a                	jns    8010665e <sys_pipe+0x2b>
    return -1;
80106654:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106659:	e9 ae 00 00 00       	jmp    8010670c <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
8010665e:	83 ec 08             	sub    $0x8,%esp
80106661:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106664:	50                   	push   %eax
80106665:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106668:	50                   	push   %eax
80106669:	e8 54 d5 ff ff       	call   80103bc2 <pipealloc>
8010666e:	83 c4 10             	add    $0x10,%esp
80106671:	85 c0                	test   %eax,%eax
80106673:	79 0a                	jns    8010667f <sys_pipe+0x4c>
    return -1;
80106675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010667a:	e9 8d 00 00 00       	jmp    8010670c <sys_pipe+0xd9>
  fd0 = -1;
8010667f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106686:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106689:	83 ec 0c             	sub    $0xc,%esp
8010668c:	50                   	push   %eax
8010668d:	e8 3b f3 ff ff       	call   801059cd <fdalloc>
80106692:	83 c4 10             	add    $0x10,%esp
80106695:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106698:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010669c:	78 18                	js     801066b6 <sys_pipe+0x83>
8010669e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066a1:	83 ec 0c             	sub    $0xc,%esp
801066a4:	50                   	push   %eax
801066a5:	e8 23 f3 ff ff       	call   801059cd <fdalloc>
801066aa:	83 c4 10             	add    $0x10,%esp
801066ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066b4:	79 3e                	jns    801066f4 <sys_pipe+0xc1>
    if(fd0 >= 0)
801066b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066ba:	78 13                	js     801066cf <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
801066bc:	e8 e0 d9 ff ff       	call   801040a1 <myproc>
801066c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066c4:	83 c2 08             	add    $0x8,%edx
801066c7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801066ce:	00 
    fileclose(rf);
801066cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066d2:	83 ec 0c             	sub    $0xc,%esp
801066d5:	50                   	push   %eax
801066d6:	e8 0e aa ff ff       	call   801010e9 <fileclose>
801066db:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801066de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066e1:	83 ec 0c             	sub    $0xc,%esp
801066e4:	50                   	push   %eax
801066e5:	e8 ff a9 ff ff       	call   801010e9 <fileclose>
801066ea:	83 c4 10             	add    $0x10,%esp
    return -1;
801066ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f2:	eb 18                	jmp    8010670c <sys_pipe+0xd9>
  }
  fd[0] = fd0;
801066f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066fa:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801066fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066ff:	8d 50 04             	lea    0x4(%eax),%edx
80106702:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106705:	89 02                	mov    %eax,(%edx)
  return 0;
80106707:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010670c:	c9                   	leave  
8010670d:	c3                   	ret    

8010670e <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010670e:	f3 0f 1e fb          	endbr32 
80106712:	55                   	push   %ebp
80106713:	89 e5                	mov    %esp,%ebp
80106715:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106718:	e8 a7 dc ff ff       	call   801043c4 <fork>
}
8010671d:	c9                   	leave  
8010671e:	c3                   	ret    

8010671f <sys_exit>:

int
sys_exit(void)
{
8010671f:	f3 0f 1e fb          	endbr32 
80106723:	55                   	push   %ebp
80106724:	89 e5                	mov    %esp,%ebp
80106726:	83 ec 08             	sub    $0x8,%esp
  exit();
80106729:	e8 13 de ff ff       	call   80104541 <exit>
  return 0;  // not reached
8010672e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106733:	c9                   	leave  
80106734:	c3                   	ret    

80106735 <sys_wait>:

int
sys_wait(void)
{
80106735:	f3 0f 1e fb          	endbr32 
80106739:	55                   	push   %ebp
8010673a:	89 e5                	mov    %esp,%ebp
8010673c:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010673f:	e8 61 e0 ff ff       	call   801047a5 <wait>
}
80106744:	c9                   	leave  
80106745:	c3                   	ret    

80106746 <sys_kill>:

int
sys_kill(void)
{
80106746:	f3 0f 1e fb          	endbr32 
8010674a:	55                   	push   %ebp
8010674b:	89 e5                	mov    %esp,%ebp
8010674d:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106750:	83 ec 08             	sub    $0x8,%esp
80106753:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106756:	50                   	push   %eax
80106757:	6a 00                	push   $0x0
80106759:	e8 9d f0 ff ff       	call   801057fb <argint>
8010675e:	83 c4 10             	add    $0x10,%esp
80106761:	85 c0                	test   %eax,%eax
80106763:	79 07                	jns    8010676c <sys_kill+0x26>
    return -1;
80106765:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676a:	eb 0f                	jmp    8010677b <sys_kill+0x35>
  return kill(pid);
8010676c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010676f:	83 ec 0c             	sub    $0xc,%esp
80106772:	50                   	push   %eax
80106773:	e8 ed e5 ff ff       	call   80104d65 <kill>
80106778:	83 c4 10             	add    $0x10,%esp
}
8010677b:	c9                   	leave  
8010677c:	c3                   	ret    

8010677d <sys_getpid>:

int
sys_getpid(void)
{
8010677d:	f3 0f 1e fb          	endbr32 
80106781:	55                   	push   %ebp
80106782:	89 e5                	mov    %esp,%ebp
80106784:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106787:	e8 15 d9 ff ff       	call   801040a1 <myproc>
8010678c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010678f:	c9                   	leave  
80106790:	c3                   	ret    

80106791 <sys_sbrk>:

int
sys_sbrk(void)
{
80106791:	f3 0f 1e fb          	endbr32 
80106795:	55                   	push   %ebp
80106796:	89 e5                	mov    %esp,%ebp
80106798:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010679b:	83 ec 08             	sub    $0x8,%esp
8010679e:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067a1:	50                   	push   %eax
801067a2:	6a 00                	push   $0x0
801067a4:	e8 52 f0 ff ff       	call   801057fb <argint>
801067a9:	83 c4 10             	add    $0x10,%esp
801067ac:	85 c0                	test   %eax,%eax
801067ae:	79 07                	jns    801067b7 <sys_sbrk+0x26>
    return -1;
801067b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b5:	eb 27                	jmp    801067de <sys_sbrk+0x4d>
  addr = myproc()->sz;
801067b7:	e8 e5 d8 ff ff       	call   801040a1 <myproc>
801067bc:	8b 00                	mov    (%eax),%eax
801067be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801067c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067c4:	83 ec 0c             	sub    $0xc,%esp
801067c7:	50                   	push   %eax
801067c8:	e8 58 db ff ff       	call   80104325 <growproc>
801067cd:	83 c4 10             	add    $0x10,%esp
801067d0:	85 c0                	test   %eax,%eax
801067d2:	79 07                	jns    801067db <sys_sbrk+0x4a>
    return -1;
801067d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d9:	eb 03                	jmp    801067de <sys_sbrk+0x4d>
  return addr;
801067db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067de:	c9                   	leave  
801067df:	c3                   	ret    

801067e0 <sys_sleep>:

int
sys_sleep(void)
{
801067e0:	f3 0f 1e fb          	endbr32 
801067e4:	55                   	push   %ebp
801067e5:	89 e5                	mov    %esp,%ebp
801067e7:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801067ea:	83 ec 08             	sub    $0x8,%esp
801067ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067f0:	50                   	push   %eax
801067f1:	6a 00                	push   $0x0
801067f3:	e8 03 f0 ff ff       	call   801057fb <argint>
801067f8:	83 c4 10             	add    $0x10,%esp
801067fb:	85 c0                	test   %eax,%eax
801067fd:	79 07                	jns    80106806 <sys_sleep+0x26>
    return -1;
801067ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106804:	eb 76                	jmp    8010687c <sys_sleep+0x9c>
  acquire(&tickslock);
80106806:	83 ec 0c             	sub    $0xc,%esp
80106809:	68 80 a6 11 80       	push   $0x8011a680
8010680e:	e8 05 ea ff ff       	call   80105218 <acquire>
80106813:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106816:	a1 c0 ae 11 80       	mov    0x8011aec0,%eax
8010681b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010681e:	eb 38                	jmp    80106858 <sys_sleep+0x78>
    if(myproc()->killed){
80106820:	e8 7c d8 ff ff       	call   801040a1 <myproc>
80106825:	8b 40 24             	mov    0x24(%eax),%eax
80106828:	85 c0                	test   %eax,%eax
8010682a:	74 17                	je     80106843 <sys_sleep+0x63>
      release(&tickslock);
8010682c:	83 ec 0c             	sub    $0xc,%esp
8010682f:	68 80 a6 11 80       	push   $0x8011a680
80106834:	e8 51 ea ff ff       	call   8010528a <release>
80106839:	83 c4 10             	add    $0x10,%esp
      return -1;
8010683c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106841:	eb 39                	jmp    8010687c <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106843:	83 ec 08             	sub    $0x8,%esp
80106846:	68 80 a6 11 80       	push   $0x8011a680
8010684b:	68 c0 ae 11 80       	push   $0x8011aec0
80106850:	e8 e3 e3 ff ff       	call   80104c38 <sleep>
80106855:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106858:	a1 c0 ae 11 80       	mov    0x8011aec0,%eax
8010685d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106860:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106863:	39 d0                	cmp    %edx,%eax
80106865:	72 b9                	jb     80106820 <sys_sleep+0x40>
  }
  release(&tickslock);
80106867:	83 ec 0c             	sub    $0xc,%esp
8010686a:	68 80 a6 11 80       	push   $0x8011a680
8010686f:	e8 16 ea ff ff       	call   8010528a <release>
80106874:	83 c4 10             	add    $0x10,%esp
  return 0;
80106877:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010687c:	c9                   	leave  
8010687d:	c3                   	ret    

8010687e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010687e:	f3 0f 1e fb          	endbr32 
80106882:	55                   	push   %ebp
80106883:	89 e5                	mov    %esp,%ebp
80106885:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106888:	83 ec 0c             	sub    $0xc,%esp
8010688b:	68 80 a6 11 80       	push   $0x8011a680
80106890:	e8 83 e9 ff ff       	call   80105218 <acquire>
80106895:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106898:	a1 c0 ae 11 80       	mov    0x8011aec0,%eax
8010689d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801068a0:	83 ec 0c             	sub    $0xc,%esp
801068a3:	68 80 a6 11 80       	push   $0x8011a680
801068a8:	e8 dd e9 ff ff       	call   8010528a <release>
801068ad:	83 c4 10             	add    $0x10,%esp
  return xticks;
801068b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068b3:	c9                   	leave  
801068b4:	c3                   	ret    

801068b5 <sys_exit2>:

int
sys_exit2(void)
{
801068b5:	f3 0f 1e fb          	endbr32 
801068b9:	55                   	push   %ebp
801068ba:	89 e5                	mov    %esp,%ebp
801068bc:	83 ec 18             	sub    $0x18,%esp
  int status;
  if(argint(0, &status) < 0)
801068bf:	83 ec 08             	sub    $0x8,%esp
801068c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068c5:	50                   	push   %eax
801068c6:	6a 00                	push   $0x0
801068c8:	e8 2e ef ff ff       	call   801057fb <argint>
801068cd:	83 c4 10             	add    $0x10,%esp
801068d0:	85 c0                	test   %eax,%eax
801068d2:	79 07                	jns    801068db <sys_exit2+0x26>
    return -1; 
801068d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d9:	eb 15                	jmp    801068f0 <sys_exit2+0x3b>

  myproc()->xstate = status;
801068db:	e8 c1 d7 ff ff       	call   801040a1 <myproc>
801068e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801068e3:	89 50 7c             	mov    %edx,0x7c(%eax)
  exit();
801068e6:	e8 56 dc ff ff       	call   80104541 <exit>
  return 0;
801068eb:	b8 00 00 00 00       	mov    $0x0,%eax
}	
801068f0:	c9                   	leave  
801068f1:	c3                   	ret    

801068f2 <sys_wait2>:

extern int wait2(int *status);

int sys_wait2(void) 
{
801068f2:	f3 0f 1e fb          	endbr32 
801068f6:	55                   	push   %ebp
801068f7:	89 e5                	mov    %esp,%ebp
801068f9:	83 ec 18             	sub    $0x18,%esp
  int *status;
  if(argptr(0, (void *)&status, sizeof(*status)) < 0)
801068fc:	83 ec 04             	sub    $0x4,%esp
801068ff:	6a 04                	push   $0x4
80106901:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106904:	50                   	push   %eax
80106905:	6a 00                	push   $0x0
80106907:	e8 20 ef ff ff       	call   8010582c <argptr>
8010690c:	83 c4 10             	add    $0x10,%esp
8010690f:	85 c0                	test   %eax,%eax
80106911:	79 07                	jns    8010691a <sys_wait2+0x28>
    return -1;
80106913:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106918:	eb 0f                	jmp    80106929 <sys_wait2+0x37>
  return wait2(status);
8010691a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010691d:	83 ec 0c             	sub    $0xc,%esp
80106920:	50                   	push   %eax
80106921:	e8 a6 df ff ff       	call   801048cc <wait2>
80106926:	83 c4 10             	add    $0x10,%esp
}
80106929:	c9                   	leave  
8010692a:	c3                   	ret    

8010692b <sys_uthread_init>:

int
sys_uthread_init(void)
{
8010692b:	f3 0f 1e fb          	endbr32 
8010692f:	55                   	push   %ebp
80106930:	89 e5                	mov    %esp,%ebp
80106932:	83 ec 18             	sub    $0x18,%esp
    struct proc* p;
    int func;

    if (argint(0, &func) < 0)
80106935:	83 ec 08             	sub    $0x8,%esp
80106938:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010693b:	50                   	push   %eax
8010693c:	6a 00                	push   $0x0
8010693e:	e8 b8 ee ff ff       	call   801057fb <argint>
80106943:	83 c4 10             	add    $0x10,%esp
80106946:	85 c0                	test   %eax,%eax
80106948:	79 07                	jns    80106951 <sys_uthread_init+0x26>
        return -1;
8010694a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010694f:	eb 1b                	jmp    8010696c <sys_uthread_init+0x41>

    p = myproc();
80106951:	e8 4b d7 ff ff       	call   801040a1 <myproc>
80106956:	89 45 f4             	mov    %eax,-0xc(%ebp)

    p->scheduler = (uint)func;
80106959:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010695c:	89 c2                	mov    %eax,%edx
8010695e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106961:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

    return 0;
80106967:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010696c:	c9                   	leave  
8010696d:	c3                   	ret    

8010696e <sys_printpt>:

int sys_printpt(void) {
8010696e:	f3 0f 1e fb          	endbr32 
80106972:	55                   	push   %ebp
80106973:	89 e5                	mov    %esp,%ebp
80106975:	83 ec 18             	sub    $0x18,%esp
    int pid;
    if(argint(0, &pid) < 0)
80106978:	83 ec 08             	sub    $0x8,%esp
8010697b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010697e:	50                   	push   %eax
8010697f:	6a 00                	push   $0x0
80106981:	e8 75 ee ff ff       	call   801057fb <argint>
80106986:	83 c4 10             	add    $0x10,%esp
80106989:	85 c0                	test   %eax,%eax
8010698b:	79 07                	jns    80106994 <sys_printpt+0x26>
        return -1;
8010698d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106992:	eb 14                	jmp    801069a8 <sys_printpt+0x3a>
    printpt(pid);
80106994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106997:	83 ec 0c             	sub    $0xc,%esp
8010699a:	50                   	push   %eax
8010699b:	e8 51 e5 ff ff       	call   80104ef1 <printpt>
801069a0:	83 c4 10             	add    $0x10,%esp
    return 0;
801069a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069a8:	c9                   	leave  
801069a9:	c3                   	ret    

801069aa <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801069aa:	1e                   	push   %ds
  pushl %es
801069ab:	06                   	push   %es
  pushl %fs
801069ac:	0f a0                	push   %fs
  pushl %gs
801069ae:	0f a8                	push   %gs
  pushal
801069b0:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801069b1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801069b5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801069b7:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801069b9:	54                   	push   %esp
  call trap
801069ba:	e8 df 01 00 00       	call   80106b9e <trap>
  addl $4, %esp
801069bf:	83 c4 04             	add    $0x4,%esp

801069c2 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801069c2:	61                   	popa   
  popl %gs
801069c3:	0f a9                	pop    %gs
  popl %fs
801069c5:	0f a1                	pop    %fs
  popl %es
801069c7:	07                   	pop    %es
  popl %ds
801069c8:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801069c9:	83 c4 08             	add    $0x8,%esp
  iret
801069cc:	cf                   	iret   

801069cd <lidt>:
{
801069cd:	55                   	push   %ebp
801069ce:	89 e5                	mov    %esp,%ebp
801069d0:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801069d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801069d6:	83 e8 01             	sub    $0x1,%eax
801069d9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801069dd:	8b 45 08             	mov    0x8(%ebp),%eax
801069e0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801069e4:	8b 45 08             	mov    0x8(%ebp),%eax
801069e7:	c1 e8 10             	shr    $0x10,%eax
801069ea:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801069ee:	8d 45 fa             	lea    -0x6(%ebp),%eax
801069f1:	0f 01 18             	lidtl  (%eax)
}
801069f4:	90                   	nop
801069f5:	c9                   	leave  
801069f6:	c3                   	ret    

801069f7 <rcr2>:

static inline uint
rcr2(void)
{
801069f7:	55                   	push   %ebp
801069f8:	89 e5                	mov    %esp,%ebp
801069fa:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801069fd:	0f 20 d0             	mov    %cr2,%eax
80106a00:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106a03:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106a06:	c9                   	leave  
80106a07:	c3                   	ret    

80106a08 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106a08:	f3 0f 1e fb          	endbr32 
80106a0c:	55                   	push   %ebp
80106a0d:	89 e5                	mov    %esp,%ebp
80106a0f:	83 ec 18             	sub    $0x18,%esp
    int i;

    for (i = 0; i < 256; i++)
80106a12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a19:	e9 c3 00 00 00       	jmp    80106ae1 <tvinit+0xd9>
        SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
80106a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a21:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106a28:	89 c2                	mov    %eax,%edx
80106a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a2d:	66 89 14 c5 c0 a6 11 	mov    %dx,-0x7fee5940(,%eax,8)
80106a34:	80 
80106a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a38:	66 c7 04 c5 c2 a6 11 	movw   $0x8,-0x7fee593e(,%eax,8)
80106a3f:	80 08 00 
80106a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a45:	0f b6 14 c5 c4 a6 11 	movzbl -0x7fee593c(,%eax,8),%edx
80106a4c:	80 
80106a4d:	83 e2 e0             	and    $0xffffffe0,%edx
80106a50:	88 14 c5 c4 a6 11 80 	mov    %dl,-0x7fee593c(,%eax,8)
80106a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a5a:	0f b6 14 c5 c4 a6 11 	movzbl -0x7fee593c(,%eax,8),%edx
80106a61:	80 
80106a62:	83 e2 1f             	and    $0x1f,%edx
80106a65:	88 14 c5 c4 a6 11 80 	mov    %dl,-0x7fee593c(,%eax,8)
80106a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a6f:	0f b6 14 c5 c5 a6 11 	movzbl -0x7fee593b(,%eax,8),%edx
80106a76:	80 
80106a77:	83 e2 f0             	and    $0xfffffff0,%edx
80106a7a:	83 ca 0e             	or     $0xe,%edx
80106a7d:	88 14 c5 c5 a6 11 80 	mov    %dl,-0x7fee593b(,%eax,8)
80106a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a87:	0f b6 14 c5 c5 a6 11 	movzbl -0x7fee593b(,%eax,8),%edx
80106a8e:	80 
80106a8f:	83 e2 ef             	and    $0xffffffef,%edx
80106a92:	88 14 c5 c5 a6 11 80 	mov    %dl,-0x7fee593b(,%eax,8)
80106a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a9c:	0f b6 14 c5 c5 a6 11 	movzbl -0x7fee593b(,%eax,8),%edx
80106aa3:	80 
80106aa4:	83 e2 9f             	and    $0xffffff9f,%edx
80106aa7:	88 14 c5 c5 a6 11 80 	mov    %dl,-0x7fee593b(,%eax,8)
80106aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab1:	0f b6 14 c5 c5 a6 11 	movzbl -0x7fee593b(,%eax,8),%edx
80106ab8:	80 
80106ab9:	83 ca 80             	or     $0xffffff80,%edx
80106abc:	88 14 c5 c5 a6 11 80 	mov    %dl,-0x7fee593b(,%eax,8)
80106ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac6:	8b 04 85 88 f0 10 80 	mov    -0x7fef0f78(,%eax,4),%eax
80106acd:	c1 e8 10             	shr    $0x10,%eax
80106ad0:	89 c2                	mov    %eax,%edx
80106ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad5:	66 89 14 c5 c6 a6 11 	mov    %dx,-0x7fee593a(,%eax,8)
80106adc:	80 
    for (i = 0; i < 256; i++)
80106add:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ae1:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106ae8:	0f 8e 30 ff ff ff    	jle    80106a1e <tvinit+0x16>
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
80106aee:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106af3:	66 a3 c0 a8 11 80    	mov    %ax,0x8011a8c0
80106af9:	66 c7 05 c2 a8 11 80 	movw   $0x8,0x8011a8c2
80106b00:	08 00 
80106b02:	0f b6 05 c4 a8 11 80 	movzbl 0x8011a8c4,%eax
80106b09:	83 e0 e0             	and    $0xffffffe0,%eax
80106b0c:	a2 c4 a8 11 80       	mov    %al,0x8011a8c4
80106b11:	0f b6 05 c4 a8 11 80 	movzbl 0x8011a8c4,%eax
80106b18:	83 e0 1f             	and    $0x1f,%eax
80106b1b:	a2 c4 a8 11 80       	mov    %al,0x8011a8c4
80106b20:	0f b6 05 c5 a8 11 80 	movzbl 0x8011a8c5,%eax
80106b27:	83 c8 0f             	or     $0xf,%eax
80106b2a:	a2 c5 a8 11 80       	mov    %al,0x8011a8c5
80106b2f:	0f b6 05 c5 a8 11 80 	movzbl 0x8011a8c5,%eax
80106b36:	83 e0 ef             	and    $0xffffffef,%eax
80106b39:	a2 c5 a8 11 80       	mov    %al,0x8011a8c5
80106b3e:	0f b6 05 c5 a8 11 80 	movzbl 0x8011a8c5,%eax
80106b45:	83 c8 60             	or     $0x60,%eax
80106b48:	a2 c5 a8 11 80       	mov    %al,0x8011a8c5
80106b4d:	0f b6 05 c5 a8 11 80 	movzbl 0x8011a8c5,%eax
80106b54:	83 c8 80             	or     $0xffffff80,%eax
80106b57:	a2 c5 a8 11 80       	mov    %al,0x8011a8c5
80106b5c:	a1 88 f1 10 80       	mov    0x8010f188,%eax
80106b61:	c1 e8 10             	shr    $0x10,%eax
80106b64:	66 a3 c6 a8 11 80    	mov    %ax,0x8011a8c6

    initlock(&tickslock, "time");
80106b6a:	83 ec 08             	sub    $0x8,%esp
80106b6d:	68 e4 b1 10 80       	push   $0x8010b1e4
80106b72:	68 80 a6 11 80       	push   $0x8011a680
80106b77:	e8 76 e6 ff ff       	call   801051f2 <initlock>
80106b7c:	83 c4 10             	add    $0x10,%esp
}
80106b7f:	90                   	nop
80106b80:	c9                   	leave  
80106b81:	c3                   	ret    

80106b82 <idtinit>:

void
idtinit(void)
{
80106b82:	f3 0f 1e fb          	endbr32 
80106b86:	55                   	push   %ebp
80106b87:	89 e5                	mov    %esp,%ebp
    lidt(idt, sizeof(idt));
80106b89:	68 00 08 00 00       	push   $0x800
80106b8e:	68 c0 a6 11 80       	push   $0x8011a6c0
80106b93:	e8 35 fe ff ff       	call   801069cd <lidt>
80106b98:	83 c4 08             	add    $0x8,%esp
}
80106b9b:	90                   	nop
80106b9c:	c9                   	leave  
80106b9d:	c3                   	ret    

80106b9e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe* tf)
{
80106b9e:	f3 0f 1e fb          	endbr32 
80106ba2:	55                   	push   %ebp
80106ba3:	89 e5                	mov    %esp,%ebp
80106ba5:	57                   	push   %edi
80106ba6:	56                   	push   %esi
80106ba7:	53                   	push   %ebx
80106ba8:	83 ec 2c             	sub    $0x2c,%esp
    if (tf->trapno == T_SYSCALL) {
80106bab:	8b 45 08             	mov    0x8(%ebp),%eax
80106bae:	8b 40 30             	mov    0x30(%eax),%eax
80106bb1:	83 f8 40             	cmp    $0x40,%eax
80106bb4:	75 3b                	jne    80106bf1 <trap+0x53>
        if (myproc()->killed)
80106bb6:	e8 e6 d4 ff ff       	call   801040a1 <myproc>
80106bbb:	8b 40 24             	mov    0x24(%eax),%eax
80106bbe:	85 c0                	test   %eax,%eax
80106bc0:	74 05                	je     80106bc7 <trap+0x29>
            exit();
80106bc2:	e8 7a d9 ff ff       	call   80104541 <exit>
        myproc()->tf = tf;
80106bc7:	e8 d5 d4 ff ff       	call   801040a1 <myproc>
80106bcc:	8b 55 08             	mov    0x8(%ebp),%edx
80106bcf:	89 50 18             	mov    %edx,0x18(%eax)
        syscall();
80106bd2:	e8 fc ec ff ff       	call   801058d3 <syscall>
        if (myproc()->killed)
80106bd7:	e8 c5 d4 ff ff       	call   801040a1 <myproc>
80106bdc:	8b 40 24             	mov    0x24(%eax),%eax
80106bdf:	85 c0                	test   %eax,%eax
80106be1:	0f 84 5d 02 00 00    	je     80106e44 <trap+0x2a6>
            exit();
80106be7:	e8 55 d9 ff ff       	call   80104541 <exit>
        return;
80106bec:	e9 53 02 00 00       	jmp    80106e44 <trap+0x2a6>
    }

    switch (tf->trapno) {
80106bf1:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf4:	8b 40 30             	mov    0x30(%eax),%eax
80106bf7:	83 e8 20             	sub    $0x20,%eax
80106bfa:	83 f8 1f             	cmp    $0x1f,%eax
80106bfd:	0f 87 09 01 00 00    	ja     80106d0c <trap+0x16e>
80106c03:	8b 04 85 8c b2 10 80 	mov    -0x7fef4d74(,%eax,4),%eax
80106c0a:	3e ff e0             	notrack jmp *%eax
    case T_IRQ0 + IRQ_TIMER:
        if (cpuid() == 0) {
80106c0d:	e8 f4 d3 ff ff       	call   80104006 <cpuid>
80106c12:	85 c0                	test   %eax,%eax
80106c14:	75 3d                	jne    80106c53 <trap+0xb5>
            acquire(&tickslock);
80106c16:	83 ec 0c             	sub    $0xc,%esp
80106c19:	68 80 a6 11 80       	push   $0x8011a680
80106c1e:	e8 f5 e5 ff ff       	call   80105218 <acquire>
80106c23:	83 c4 10             	add    $0x10,%esp
            ticks++;
80106c26:	a1 c0 ae 11 80       	mov    0x8011aec0,%eax
80106c2b:	83 c0 01             	add    $0x1,%eax
80106c2e:	a3 c0 ae 11 80       	mov    %eax,0x8011aec0
            wakeup(&ticks);
80106c33:	83 ec 0c             	sub    $0xc,%esp
80106c36:	68 c0 ae 11 80       	push   $0x8011aec0
80106c3b:	e8 ea e0 ff ff       	call   80104d2a <wakeup>
80106c40:	83 c4 10             	add    $0x10,%esp
            release(&tickslock);
80106c43:	83 ec 0c             	sub    $0xc,%esp
80106c46:	68 80 a6 11 80       	push   $0x8011a680
80106c4b:	e8 3a e6 ff ff       	call   8010528a <release>
80106c50:	83 c4 10             	add    $0x10,%esp
        }
        lapiceoi();  // Acknowledge the interrupt
80106c53:	e8 c5 c4 ff ff       	call   8010311d <lapiceoi>

        // After acknowledging the timer interrupt, check if we need to switch threads.
        struct proc* curproc = myproc();
80106c58:	e8 44 d4 ff ff       	call   801040a1 <myproc>
80106c5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (curproc && curproc->scheduler && (tf->cs & 3) == DPL_USER) {
80106c60:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106c64:	0f 84 59 01 00 00    	je     80106dc3 <trap+0x225>
80106c6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c6d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106c73:	85 c0                	test   %eax,%eax
80106c75:	0f 84 48 01 00 00    	je     80106dc3 <trap+0x225>
80106c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c7e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c82:	0f b7 c0             	movzwl %ax,%eax
80106c85:	83 e0 03             	and    $0x3,%eax
80106c88:	83 f8 03             	cmp    $0x3,%eax
80106c8b:	0f 85 32 01 00 00    	jne    80106dc3 <trap+0x225>
            // Only switch threads if the current process has a user-level scheduler
            // and the trap occurred in user mode.
            ((void(*)(void))curproc->scheduler)();  // Call the user-level scheduler
80106c91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c94:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106c9a:	ff d0                	call   *%eax
	    return;
80106c9c:	e9 a4 01 00 00       	jmp    80106e45 <trap+0x2a7>
        }
        break;
    case T_IRQ0 + IRQ_IDE:
        ideintr();
80106ca1:	e8 8e bc ff ff       	call   80102934 <ideintr>
        lapiceoi();
80106ca6:	e8 72 c4 ff ff       	call   8010311d <lapiceoi>
        break;
80106cab:	e9 14 01 00 00       	jmp    80106dc4 <trap+0x226>
    case T_IRQ0 + IRQ_IDE + 1:
        // Bochs generates spurious IDE1 interrupts.
        break;
    case T_IRQ0 + IRQ_KBD:
        kbdintr();
80106cb0:	e8 9e c2 ff ff       	call   80102f53 <kbdintr>
        lapiceoi();
80106cb5:	e8 63 c4 ff ff       	call   8010311d <lapiceoi>
        break;
80106cba:	e9 05 01 00 00       	jmp    80106dc4 <trap+0x226>
    case T_IRQ0 + IRQ_COM1:
        uartintr();
80106cbf:	e8 62 03 00 00       	call   80107026 <uartintr>
        lapiceoi();
80106cc4:	e8 54 c4 ff ff       	call   8010311d <lapiceoi>
        break;
80106cc9:	e9 f6 00 00 00       	jmp    80106dc4 <trap+0x226>
    case T_IRQ0 + 0xB:
        i8254_intr();
80106cce:	e8 30 2c 00 00       	call   80109903 <i8254_intr>
        lapiceoi();
80106cd3:	e8 45 c4 ff ff       	call   8010311d <lapiceoi>
        break;
80106cd8:	e9 e7 00 00 00       	jmp    80106dc4 <trap+0x226>
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce0:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106cea:	0f b7 d8             	movzwl %ax,%ebx
80106ced:	e8 14 d3 ff ff       	call   80104006 <cpuid>
80106cf2:	56                   	push   %esi
80106cf3:	53                   	push   %ebx
80106cf4:	50                   	push   %eax
80106cf5:	68 ec b1 10 80       	push   $0x8010b1ec
80106cfa:	e8 0d 97 ff ff       	call   8010040c <cprintf>
80106cff:	83 c4 10             	add    $0x10,%esp
        lapiceoi();
80106d02:	e8 16 c4 ff ff       	call   8010311d <lapiceoi>
        break;
80106d07:	e9 b8 00 00 00       	jmp    80106dc4 <trap+0x226>

        //PAGEBREAK: 13
    default:
        if (myproc() == 0 || (tf->cs & 3) == 0) {
80106d0c:	e8 90 d3 ff ff       	call   801040a1 <myproc>
80106d11:	85 c0                	test   %eax,%eax
80106d13:	74 11                	je     80106d26 <trap+0x188>
80106d15:	8b 45 08             	mov    0x8(%ebp),%eax
80106d18:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d1c:	0f b7 c0             	movzwl %ax,%eax
80106d1f:	83 e0 03             	and    $0x3,%eax
80106d22:	85 c0                	test   %eax,%eax
80106d24:	75 39                	jne    80106d5f <trap+0x1c1>
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106d26:	e8 cc fc ff ff       	call   801069f7 <rcr2>
80106d2b:	89 c3                	mov    %eax,%ebx
80106d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d30:	8b 70 38             	mov    0x38(%eax),%esi
80106d33:	e8 ce d2 ff ff       	call   80104006 <cpuid>
80106d38:	8b 55 08             	mov    0x8(%ebp),%edx
80106d3b:	8b 52 30             	mov    0x30(%edx),%edx
80106d3e:	83 ec 0c             	sub    $0xc,%esp
80106d41:	53                   	push   %ebx
80106d42:	56                   	push   %esi
80106d43:	50                   	push   %eax
80106d44:	52                   	push   %edx
80106d45:	68 10 b2 10 80       	push   $0x8010b210
80106d4a:	e8 bd 96 ff ff       	call   8010040c <cprintf>
80106d4f:	83 c4 20             	add    $0x20,%esp
                tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
80106d52:	83 ec 0c             	sub    $0xc,%esp
80106d55:	68 42 b2 10 80       	push   $0x8010b242
80106d5a:	e8 66 98 ff ff       	call   801005c5 <panic>
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d5f:	e8 93 fc ff ff       	call   801069f7 <rcr2>
80106d64:	89 c6                	mov    %eax,%esi
80106d66:	8b 45 08             	mov    0x8(%ebp),%eax
80106d69:	8b 40 38             	mov    0x38(%eax),%eax
80106d6c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106d6f:	e8 92 d2 ff ff       	call   80104006 <cpuid>
80106d74:	89 c3                	mov    %eax,%ebx
80106d76:	8b 45 08             	mov    0x8(%ebp),%eax
80106d79:	8b 48 34             	mov    0x34(%eax),%ecx
80106d7c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d82:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106d85:	e8 17 d3 ff ff       	call   801040a1 <myproc>
80106d8a:	8d 50 6c             	lea    0x6c(%eax),%edx
80106d8d:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106d90:	e8 0c d3 ff ff       	call   801040a1 <myproc>
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d95:	8b 40 10             	mov    0x10(%eax),%eax
80106d98:	56                   	push   %esi
80106d99:	ff 75 d4             	pushl  -0x2c(%ebp)
80106d9c:	53                   	push   %ebx
80106d9d:	ff 75 d0             	pushl  -0x30(%ebp)
80106da0:	57                   	push   %edi
80106da1:	ff 75 cc             	pushl  -0x34(%ebp)
80106da4:	50                   	push   %eax
80106da5:	68 48 b2 10 80       	push   $0x8010b248
80106daa:	e8 5d 96 ff ff       	call   8010040c <cprintf>
80106daf:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
80106db2:	e8 ea d2 ff ff       	call   801040a1 <myproc>
80106db7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106dbe:	eb 04                	jmp    80106dc4 <trap+0x226>
        break;
80106dc0:	90                   	nop
80106dc1:	eb 01                	jmp    80106dc4 <trap+0x226>
        break;
80106dc3:	90                   	nop
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106dc4:	e8 d8 d2 ff ff       	call   801040a1 <myproc>
80106dc9:	85 c0                	test   %eax,%eax
80106dcb:	74 23                	je     80106df0 <trap+0x252>
80106dcd:	e8 cf d2 ff ff       	call   801040a1 <myproc>
80106dd2:	8b 40 24             	mov    0x24(%eax),%eax
80106dd5:	85 c0                	test   %eax,%eax
80106dd7:	74 17                	je     80106df0 <trap+0x252>
80106dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80106ddc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106de0:	0f b7 c0             	movzwl %ax,%eax
80106de3:	83 e0 03             	and    $0x3,%eax
80106de6:	83 f8 03             	cmp    $0x3,%eax
80106de9:	75 05                	jne    80106df0 <trap+0x252>
        exit();
80106deb:	e8 51 d7 ff ff       	call   80104541 <exit>

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
80106df0:	e8 ac d2 ff ff       	call   801040a1 <myproc>
80106df5:	85 c0                	test   %eax,%eax
80106df7:	74 1d                	je     80106e16 <trap+0x278>
80106df9:	e8 a3 d2 ff ff       	call   801040a1 <myproc>
80106dfe:	8b 40 0c             	mov    0xc(%eax),%eax
80106e01:	83 f8 04             	cmp    $0x4,%eax
80106e04:	75 10                	jne    80106e16 <trap+0x278>
        tf->trapno == T_IRQ0 + IRQ_TIMER)
80106e06:	8b 45 08             	mov    0x8(%ebp),%eax
80106e09:	8b 40 30             	mov    0x30(%eax),%eax
    if (myproc() && myproc()->state == RUNNING &&
80106e0c:	83 f8 20             	cmp    $0x20,%eax
80106e0f:	75 05                	jne    80106e16 <trap+0x278>
        yield();
80106e11:	e8 9a dd ff ff       	call   80104bb0 <yield>

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106e16:	e8 86 d2 ff ff       	call   801040a1 <myproc>
80106e1b:	85 c0                	test   %eax,%eax
80106e1d:	74 26                	je     80106e45 <trap+0x2a7>
80106e1f:	e8 7d d2 ff ff       	call   801040a1 <myproc>
80106e24:	8b 40 24             	mov    0x24(%eax),%eax
80106e27:	85 c0                	test   %eax,%eax
80106e29:	74 1a                	je     80106e45 <trap+0x2a7>
80106e2b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e2e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e32:	0f b7 c0             	movzwl %ax,%eax
80106e35:	83 e0 03             	and    $0x3,%eax
80106e38:	83 f8 03             	cmp    $0x3,%eax
80106e3b:	75 08                	jne    80106e45 <trap+0x2a7>
        exit();
80106e3d:	e8 ff d6 ff ff       	call   80104541 <exit>
80106e42:	eb 01                	jmp    80106e45 <trap+0x2a7>
        return;
80106e44:	90                   	nop
}
80106e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e48:	5b                   	pop    %ebx
80106e49:	5e                   	pop    %esi
80106e4a:	5f                   	pop    %edi
80106e4b:	5d                   	pop    %ebp
80106e4c:	c3                   	ret    

80106e4d <inb>:
{
80106e4d:	55                   	push   %ebp
80106e4e:	89 e5                	mov    %esp,%ebp
80106e50:	83 ec 14             	sub    $0x14,%esp
80106e53:	8b 45 08             	mov    0x8(%ebp),%eax
80106e56:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106e5a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106e5e:	89 c2                	mov    %eax,%edx
80106e60:	ec                   	in     (%dx),%al
80106e61:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106e64:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106e68:	c9                   	leave  
80106e69:	c3                   	ret    

80106e6a <outb>:
{
80106e6a:	55                   	push   %ebp
80106e6b:	89 e5                	mov    %esp,%ebp
80106e6d:	83 ec 08             	sub    $0x8,%esp
80106e70:	8b 45 08             	mov    0x8(%ebp),%eax
80106e73:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e76:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106e7a:	89 d0                	mov    %edx,%eax
80106e7c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106e7f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106e83:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106e87:	ee                   	out    %al,(%dx)
}
80106e88:	90                   	nop
80106e89:	c9                   	leave  
80106e8a:	c3                   	ret    

80106e8b <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106e8b:	f3 0f 1e fb          	endbr32 
80106e8f:	55                   	push   %ebp
80106e90:	89 e5                	mov    %esp,%ebp
80106e92:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106e95:	6a 00                	push   $0x0
80106e97:	68 fa 03 00 00       	push   $0x3fa
80106e9c:	e8 c9 ff ff ff       	call   80106e6a <outb>
80106ea1:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106ea4:	68 80 00 00 00       	push   $0x80
80106ea9:	68 fb 03 00 00       	push   $0x3fb
80106eae:	e8 b7 ff ff ff       	call   80106e6a <outb>
80106eb3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106eb6:	6a 0c                	push   $0xc
80106eb8:	68 f8 03 00 00       	push   $0x3f8
80106ebd:	e8 a8 ff ff ff       	call   80106e6a <outb>
80106ec2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106ec5:	6a 00                	push   $0x0
80106ec7:	68 f9 03 00 00       	push   $0x3f9
80106ecc:	e8 99 ff ff ff       	call   80106e6a <outb>
80106ed1:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ed4:	6a 03                	push   $0x3
80106ed6:	68 fb 03 00 00       	push   $0x3fb
80106edb:	e8 8a ff ff ff       	call   80106e6a <outb>
80106ee0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106ee3:	6a 00                	push   $0x0
80106ee5:	68 fc 03 00 00       	push   $0x3fc
80106eea:	e8 7b ff ff ff       	call   80106e6a <outb>
80106eef:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106ef2:	6a 01                	push   $0x1
80106ef4:	68 f9 03 00 00       	push   $0x3f9
80106ef9:	e8 6c ff ff ff       	call   80106e6a <outb>
80106efe:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106f01:	68 fd 03 00 00       	push   $0x3fd
80106f06:	e8 42 ff ff ff       	call   80106e4d <inb>
80106f0b:	83 c4 04             	add    $0x4,%esp
80106f0e:	3c ff                	cmp    $0xff,%al
80106f10:	74 61                	je     80106f73 <uartinit+0xe8>
    return;
  uart = 1;
80106f12:	c7 05 a4 00 11 80 01 	movl   $0x1,0x801100a4
80106f19:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106f1c:	68 fa 03 00 00       	push   $0x3fa
80106f21:	e8 27 ff ff ff       	call   80106e4d <inb>
80106f26:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106f29:	68 f8 03 00 00       	push   $0x3f8
80106f2e:	e8 1a ff ff ff       	call   80106e4d <inb>
80106f33:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106f36:	83 ec 08             	sub    $0x8,%esp
80106f39:	6a 00                	push   $0x0
80106f3b:	6a 04                	push   $0x4
80106f3d:	e8 c2 bc ff ff       	call   80102c04 <ioapicenable>
80106f42:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f45:	c7 45 f4 0c b3 10 80 	movl   $0x8010b30c,-0xc(%ebp)
80106f4c:	eb 19                	jmp    80106f67 <uartinit+0xdc>
    uartputc(*p);
80106f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f51:	0f b6 00             	movzbl (%eax),%eax
80106f54:	0f be c0             	movsbl %al,%eax
80106f57:	83 ec 0c             	sub    $0xc,%esp
80106f5a:	50                   	push   %eax
80106f5b:	e8 16 00 00 00       	call   80106f76 <uartputc>
80106f60:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106f63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f6a:	0f b6 00             	movzbl (%eax),%eax
80106f6d:	84 c0                	test   %al,%al
80106f6f:	75 dd                	jne    80106f4e <uartinit+0xc3>
80106f71:	eb 01                	jmp    80106f74 <uartinit+0xe9>
    return;
80106f73:	90                   	nop
}
80106f74:	c9                   	leave  
80106f75:	c3                   	ret    

80106f76 <uartputc>:

void
uartputc(int c)
{
80106f76:	f3 0f 1e fb          	endbr32 
80106f7a:	55                   	push   %ebp
80106f7b:	89 e5                	mov    %esp,%ebp
80106f7d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106f80:	a1 a4 00 11 80       	mov    0x801100a4,%eax
80106f85:	85 c0                	test   %eax,%eax
80106f87:	74 53                	je     80106fdc <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f90:	eb 11                	jmp    80106fa3 <uartputc+0x2d>
    microdelay(10);
80106f92:	83 ec 0c             	sub    $0xc,%esp
80106f95:	6a 0a                	push   $0xa
80106f97:	e8 a0 c1 ff ff       	call   8010313c <microdelay>
80106f9c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f9f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106fa3:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106fa7:	7f 1a                	jg     80106fc3 <uartputc+0x4d>
80106fa9:	83 ec 0c             	sub    $0xc,%esp
80106fac:	68 fd 03 00 00       	push   $0x3fd
80106fb1:	e8 97 fe ff ff       	call   80106e4d <inb>
80106fb6:	83 c4 10             	add    $0x10,%esp
80106fb9:	0f b6 c0             	movzbl %al,%eax
80106fbc:	83 e0 20             	and    $0x20,%eax
80106fbf:	85 c0                	test   %eax,%eax
80106fc1:	74 cf                	je     80106f92 <uartputc+0x1c>
  outb(COM1+0, c);
80106fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80106fc6:	0f b6 c0             	movzbl %al,%eax
80106fc9:	83 ec 08             	sub    $0x8,%esp
80106fcc:	50                   	push   %eax
80106fcd:	68 f8 03 00 00       	push   $0x3f8
80106fd2:	e8 93 fe ff ff       	call   80106e6a <outb>
80106fd7:	83 c4 10             	add    $0x10,%esp
80106fda:	eb 01                	jmp    80106fdd <uartputc+0x67>
    return;
80106fdc:	90                   	nop
}
80106fdd:	c9                   	leave  
80106fde:	c3                   	ret    

80106fdf <uartgetc>:

static int
uartgetc(void)
{
80106fdf:	f3 0f 1e fb          	endbr32 
80106fe3:	55                   	push   %ebp
80106fe4:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106fe6:	a1 a4 00 11 80       	mov    0x801100a4,%eax
80106feb:	85 c0                	test   %eax,%eax
80106fed:	75 07                	jne    80106ff6 <uartgetc+0x17>
    return -1;
80106fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ff4:	eb 2e                	jmp    80107024 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106ff6:	68 fd 03 00 00       	push   $0x3fd
80106ffb:	e8 4d fe ff ff       	call   80106e4d <inb>
80107000:	83 c4 04             	add    $0x4,%esp
80107003:	0f b6 c0             	movzbl %al,%eax
80107006:	83 e0 01             	and    $0x1,%eax
80107009:	85 c0                	test   %eax,%eax
8010700b:	75 07                	jne    80107014 <uartgetc+0x35>
    return -1;
8010700d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107012:	eb 10                	jmp    80107024 <uartgetc+0x45>
  return inb(COM1+0);
80107014:	68 f8 03 00 00       	push   $0x3f8
80107019:	e8 2f fe ff ff       	call   80106e4d <inb>
8010701e:	83 c4 04             	add    $0x4,%esp
80107021:	0f b6 c0             	movzbl %al,%eax
}
80107024:	c9                   	leave  
80107025:	c3                   	ret    

80107026 <uartintr>:

void
uartintr(void)
{
80107026:	f3 0f 1e fb          	endbr32 
8010702a:	55                   	push   %ebp
8010702b:	89 e5                	mov    %esp,%ebp
8010702d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107030:	83 ec 0c             	sub    $0xc,%esp
80107033:	68 df 6f 10 80       	push   $0x80106fdf
80107038:	e8 c3 97 ff ff       	call   80100800 <consoleintr>
8010703d:	83 c4 10             	add    $0x10,%esp
}
80107040:	90                   	nop
80107041:	c9                   	leave  
80107042:	c3                   	ret    

80107043 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $0
80107045:	6a 00                	push   $0x0
  jmp alltraps
80107047:	e9 5e f9 ff ff       	jmp    801069aa <alltraps>

8010704c <vector1>:
.globl vector1
vector1:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $1
8010704e:	6a 01                	push   $0x1
  jmp alltraps
80107050:	e9 55 f9 ff ff       	jmp    801069aa <alltraps>

80107055 <vector2>:
.globl vector2
vector2:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $2
80107057:	6a 02                	push   $0x2
  jmp alltraps
80107059:	e9 4c f9 ff ff       	jmp    801069aa <alltraps>

8010705e <vector3>:
.globl vector3
vector3:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $3
80107060:	6a 03                	push   $0x3
  jmp alltraps
80107062:	e9 43 f9 ff ff       	jmp    801069aa <alltraps>

80107067 <vector4>:
.globl vector4
vector4:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $4
80107069:	6a 04                	push   $0x4
  jmp alltraps
8010706b:	e9 3a f9 ff ff       	jmp    801069aa <alltraps>

80107070 <vector5>:
.globl vector5
vector5:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $5
80107072:	6a 05                	push   $0x5
  jmp alltraps
80107074:	e9 31 f9 ff ff       	jmp    801069aa <alltraps>

80107079 <vector6>:
.globl vector6
vector6:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $6
8010707b:	6a 06                	push   $0x6
  jmp alltraps
8010707d:	e9 28 f9 ff ff       	jmp    801069aa <alltraps>

80107082 <vector7>:
.globl vector7
vector7:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $7
80107084:	6a 07                	push   $0x7
  jmp alltraps
80107086:	e9 1f f9 ff ff       	jmp    801069aa <alltraps>

8010708b <vector8>:
.globl vector8
vector8:
  pushl $8
8010708b:	6a 08                	push   $0x8
  jmp alltraps
8010708d:	e9 18 f9 ff ff       	jmp    801069aa <alltraps>

80107092 <vector9>:
.globl vector9
vector9:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $9
80107094:	6a 09                	push   $0x9
  jmp alltraps
80107096:	e9 0f f9 ff ff       	jmp    801069aa <alltraps>

8010709b <vector10>:
.globl vector10
vector10:
  pushl $10
8010709b:	6a 0a                	push   $0xa
  jmp alltraps
8010709d:	e9 08 f9 ff ff       	jmp    801069aa <alltraps>

801070a2 <vector11>:
.globl vector11
vector11:
  pushl $11
801070a2:	6a 0b                	push   $0xb
  jmp alltraps
801070a4:	e9 01 f9 ff ff       	jmp    801069aa <alltraps>

801070a9 <vector12>:
.globl vector12
vector12:
  pushl $12
801070a9:	6a 0c                	push   $0xc
  jmp alltraps
801070ab:	e9 fa f8 ff ff       	jmp    801069aa <alltraps>

801070b0 <vector13>:
.globl vector13
vector13:
  pushl $13
801070b0:	6a 0d                	push   $0xd
  jmp alltraps
801070b2:	e9 f3 f8 ff ff       	jmp    801069aa <alltraps>

801070b7 <vector14>:
.globl vector14
vector14:
  pushl $14
801070b7:	6a 0e                	push   $0xe
  jmp alltraps
801070b9:	e9 ec f8 ff ff       	jmp    801069aa <alltraps>

801070be <vector15>:
.globl vector15
vector15:
  pushl $0
801070be:	6a 00                	push   $0x0
  pushl $15
801070c0:	6a 0f                	push   $0xf
  jmp alltraps
801070c2:	e9 e3 f8 ff ff       	jmp    801069aa <alltraps>

801070c7 <vector16>:
.globl vector16
vector16:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $16
801070c9:	6a 10                	push   $0x10
  jmp alltraps
801070cb:	e9 da f8 ff ff       	jmp    801069aa <alltraps>

801070d0 <vector17>:
.globl vector17
vector17:
  pushl $17
801070d0:	6a 11                	push   $0x11
  jmp alltraps
801070d2:	e9 d3 f8 ff ff       	jmp    801069aa <alltraps>

801070d7 <vector18>:
.globl vector18
vector18:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $18
801070d9:	6a 12                	push   $0x12
  jmp alltraps
801070db:	e9 ca f8 ff ff       	jmp    801069aa <alltraps>

801070e0 <vector19>:
.globl vector19
vector19:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $19
801070e2:	6a 13                	push   $0x13
  jmp alltraps
801070e4:	e9 c1 f8 ff ff       	jmp    801069aa <alltraps>

801070e9 <vector20>:
.globl vector20
vector20:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $20
801070eb:	6a 14                	push   $0x14
  jmp alltraps
801070ed:	e9 b8 f8 ff ff       	jmp    801069aa <alltraps>

801070f2 <vector21>:
.globl vector21
vector21:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $21
801070f4:	6a 15                	push   $0x15
  jmp alltraps
801070f6:	e9 af f8 ff ff       	jmp    801069aa <alltraps>

801070fb <vector22>:
.globl vector22
vector22:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $22
801070fd:	6a 16                	push   $0x16
  jmp alltraps
801070ff:	e9 a6 f8 ff ff       	jmp    801069aa <alltraps>

80107104 <vector23>:
.globl vector23
vector23:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $23
80107106:	6a 17                	push   $0x17
  jmp alltraps
80107108:	e9 9d f8 ff ff       	jmp    801069aa <alltraps>

8010710d <vector24>:
.globl vector24
vector24:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $24
8010710f:	6a 18                	push   $0x18
  jmp alltraps
80107111:	e9 94 f8 ff ff       	jmp    801069aa <alltraps>

80107116 <vector25>:
.globl vector25
vector25:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $25
80107118:	6a 19                	push   $0x19
  jmp alltraps
8010711a:	e9 8b f8 ff ff       	jmp    801069aa <alltraps>

8010711f <vector26>:
.globl vector26
vector26:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $26
80107121:	6a 1a                	push   $0x1a
  jmp alltraps
80107123:	e9 82 f8 ff ff       	jmp    801069aa <alltraps>

80107128 <vector27>:
.globl vector27
vector27:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $27
8010712a:	6a 1b                	push   $0x1b
  jmp alltraps
8010712c:	e9 79 f8 ff ff       	jmp    801069aa <alltraps>

80107131 <vector28>:
.globl vector28
vector28:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $28
80107133:	6a 1c                	push   $0x1c
  jmp alltraps
80107135:	e9 70 f8 ff ff       	jmp    801069aa <alltraps>

8010713a <vector29>:
.globl vector29
vector29:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $29
8010713c:	6a 1d                	push   $0x1d
  jmp alltraps
8010713e:	e9 67 f8 ff ff       	jmp    801069aa <alltraps>

80107143 <vector30>:
.globl vector30
vector30:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $30
80107145:	6a 1e                	push   $0x1e
  jmp alltraps
80107147:	e9 5e f8 ff ff       	jmp    801069aa <alltraps>

8010714c <vector31>:
.globl vector31
vector31:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $31
8010714e:	6a 1f                	push   $0x1f
  jmp alltraps
80107150:	e9 55 f8 ff ff       	jmp    801069aa <alltraps>

80107155 <vector32>:
.globl vector32
vector32:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $32
80107157:	6a 20                	push   $0x20
  jmp alltraps
80107159:	e9 4c f8 ff ff       	jmp    801069aa <alltraps>

8010715e <vector33>:
.globl vector33
vector33:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $33
80107160:	6a 21                	push   $0x21
  jmp alltraps
80107162:	e9 43 f8 ff ff       	jmp    801069aa <alltraps>

80107167 <vector34>:
.globl vector34
vector34:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $34
80107169:	6a 22                	push   $0x22
  jmp alltraps
8010716b:	e9 3a f8 ff ff       	jmp    801069aa <alltraps>

80107170 <vector35>:
.globl vector35
vector35:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $35
80107172:	6a 23                	push   $0x23
  jmp alltraps
80107174:	e9 31 f8 ff ff       	jmp    801069aa <alltraps>

80107179 <vector36>:
.globl vector36
vector36:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $36
8010717b:	6a 24                	push   $0x24
  jmp alltraps
8010717d:	e9 28 f8 ff ff       	jmp    801069aa <alltraps>

80107182 <vector37>:
.globl vector37
vector37:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $37
80107184:	6a 25                	push   $0x25
  jmp alltraps
80107186:	e9 1f f8 ff ff       	jmp    801069aa <alltraps>

8010718b <vector38>:
.globl vector38
vector38:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $38
8010718d:	6a 26                	push   $0x26
  jmp alltraps
8010718f:	e9 16 f8 ff ff       	jmp    801069aa <alltraps>

80107194 <vector39>:
.globl vector39
vector39:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $39
80107196:	6a 27                	push   $0x27
  jmp alltraps
80107198:	e9 0d f8 ff ff       	jmp    801069aa <alltraps>

8010719d <vector40>:
.globl vector40
vector40:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $40
8010719f:	6a 28                	push   $0x28
  jmp alltraps
801071a1:	e9 04 f8 ff ff       	jmp    801069aa <alltraps>

801071a6 <vector41>:
.globl vector41
vector41:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $41
801071a8:	6a 29                	push   $0x29
  jmp alltraps
801071aa:	e9 fb f7 ff ff       	jmp    801069aa <alltraps>

801071af <vector42>:
.globl vector42
vector42:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $42
801071b1:	6a 2a                	push   $0x2a
  jmp alltraps
801071b3:	e9 f2 f7 ff ff       	jmp    801069aa <alltraps>

801071b8 <vector43>:
.globl vector43
vector43:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $43
801071ba:	6a 2b                	push   $0x2b
  jmp alltraps
801071bc:	e9 e9 f7 ff ff       	jmp    801069aa <alltraps>

801071c1 <vector44>:
.globl vector44
vector44:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $44
801071c3:	6a 2c                	push   $0x2c
  jmp alltraps
801071c5:	e9 e0 f7 ff ff       	jmp    801069aa <alltraps>

801071ca <vector45>:
.globl vector45
vector45:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $45
801071cc:	6a 2d                	push   $0x2d
  jmp alltraps
801071ce:	e9 d7 f7 ff ff       	jmp    801069aa <alltraps>

801071d3 <vector46>:
.globl vector46
vector46:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $46
801071d5:	6a 2e                	push   $0x2e
  jmp alltraps
801071d7:	e9 ce f7 ff ff       	jmp    801069aa <alltraps>

801071dc <vector47>:
.globl vector47
vector47:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $47
801071de:	6a 2f                	push   $0x2f
  jmp alltraps
801071e0:	e9 c5 f7 ff ff       	jmp    801069aa <alltraps>

801071e5 <vector48>:
.globl vector48
vector48:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $48
801071e7:	6a 30                	push   $0x30
  jmp alltraps
801071e9:	e9 bc f7 ff ff       	jmp    801069aa <alltraps>

801071ee <vector49>:
.globl vector49
vector49:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $49
801071f0:	6a 31                	push   $0x31
  jmp alltraps
801071f2:	e9 b3 f7 ff ff       	jmp    801069aa <alltraps>

801071f7 <vector50>:
.globl vector50
vector50:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $50
801071f9:	6a 32                	push   $0x32
  jmp alltraps
801071fb:	e9 aa f7 ff ff       	jmp    801069aa <alltraps>

80107200 <vector51>:
.globl vector51
vector51:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $51
80107202:	6a 33                	push   $0x33
  jmp alltraps
80107204:	e9 a1 f7 ff ff       	jmp    801069aa <alltraps>

80107209 <vector52>:
.globl vector52
vector52:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $52
8010720b:	6a 34                	push   $0x34
  jmp alltraps
8010720d:	e9 98 f7 ff ff       	jmp    801069aa <alltraps>

80107212 <vector53>:
.globl vector53
vector53:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $53
80107214:	6a 35                	push   $0x35
  jmp alltraps
80107216:	e9 8f f7 ff ff       	jmp    801069aa <alltraps>

8010721b <vector54>:
.globl vector54
vector54:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $54
8010721d:	6a 36                	push   $0x36
  jmp alltraps
8010721f:	e9 86 f7 ff ff       	jmp    801069aa <alltraps>

80107224 <vector55>:
.globl vector55
vector55:
  pushl $0
80107224:	6a 00                	push   $0x0
  pushl $55
80107226:	6a 37                	push   $0x37
  jmp alltraps
80107228:	e9 7d f7 ff ff       	jmp    801069aa <alltraps>

8010722d <vector56>:
.globl vector56
vector56:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $56
8010722f:	6a 38                	push   $0x38
  jmp alltraps
80107231:	e9 74 f7 ff ff       	jmp    801069aa <alltraps>

80107236 <vector57>:
.globl vector57
vector57:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $57
80107238:	6a 39                	push   $0x39
  jmp alltraps
8010723a:	e9 6b f7 ff ff       	jmp    801069aa <alltraps>

8010723f <vector58>:
.globl vector58
vector58:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $58
80107241:	6a 3a                	push   $0x3a
  jmp alltraps
80107243:	e9 62 f7 ff ff       	jmp    801069aa <alltraps>

80107248 <vector59>:
.globl vector59
vector59:
  pushl $0
80107248:	6a 00                	push   $0x0
  pushl $59
8010724a:	6a 3b                	push   $0x3b
  jmp alltraps
8010724c:	e9 59 f7 ff ff       	jmp    801069aa <alltraps>

80107251 <vector60>:
.globl vector60
vector60:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $60
80107253:	6a 3c                	push   $0x3c
  jmp alltraps
80107255:	e9 50 f7 ff ff       	jmp    801069aa <alltraps>

8010725a <vector61>:
.globl vector61
vector61:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $61
8010725c:	6a 3d                	push   $0x3d
  jmp alltraps
8010725e:	e9 47 f7 ff ff       	jmp    801069aa <alltraps>

80107263 <vector62>:
.globl vector62
vector62:
  pushl $0
80107263:	6a 00                	push   $0x0
  pushl $62
80107265:	6a 3e                	push   $0x3e
  jmp alltraps
80107267:	e9 3e f7 ff ff       	jmp    801069aa <alltraps>

8010726c <vector63>:
.globl vector63
vector63:
  pushl $0
8010726c:	6a 00                	push   $0x0
  pushl $63
8010726e:	6a 3f                	push   $0x3f
  jmp alltraps
80107270:	e9 35 f7 ff ff       	jmp    801069aa <alltraps>

80107275 <vector64>:
.globl vector64
vector64:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $64
80107277:	6a 40                	push   $0x40
  jmp alltraps
80107279:	e9 2c f7 ff ff       	jmp    801069aa <alltraps>

8010727e <vector65>:
.globl vector65
vector65:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $65
80107280:	6a 41                	push   $0x41
  jmp alltraps
80107282:	e9 23 f7 ff ff       	jmp    801069aa <alltraps>

80107287 <vector66>:
.globl vector66
vector66:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $66
80107289:	6a 42                	push   $0x42
  jmp alltraps
8010728b:	e9 1a f7 ff ff       	jmp    801069aa <alltraps>

80107290 <vector67>:
.globl vector67
vector67:
  pushl $0
80107290:	6a 00                	push   $0x0
  pushl $67
80107292:	6a 43                	push   $0x43
  jmp alltraps
80107294:	e9 11 f7 ff ff       	jmp    801069aa <alltraps>

80107299 <vector68>:
.globl vector68
vector68:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $68
8010729b:	6a 44                	push   $0x44
  jmp alltraps
8010729d:	e9 08 f7 ff ff       	jmp    801069aa <alltraps>

801072a2 <vector69>:
.globl vector69
vector69:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $69
801072a4:	6a 45                	push   $0x45
  jmp alltraps
801072a6:	e9 ff f6 ff ff       	jmp    801069aa <alltraps>

801072ab <vector70>:
.globl vector70
vector70:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $70
801072ad:	6a 46                	push   $0x46
  jmp alltraps
801072af:	e9 f6 f6 ff ff       	jmp    801069aa <alltraps>

801072b4 <vector71>:
.globl vector71
vector71:
  pushl $0
801072b4:	6a 00                	push   $0x0
  pushl $71
801072b6:	6a 47                	push   $0x47
  jmp alltraps
801072b8:	e9 ed f6 ff ff       	jmp    801069aa <alltraps>

801072bd <vector72>:
.globl vector72
vector72:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $72
801072bf:	6a 48                	push   $0x48
  jmp alltraps
801072c1:	e9 e4 f6 ff ff       	jmp    801069aa <alltraps>

801072c6 <vector73>:
.globl vector73
vector73:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $73
801072c8:	6a 49                	push   $0x49
  jmp alltraps
801072ca:	e9 db f6 ff ff       	jmp    801069aa <alltraps>

801072cf <vector74>:
.globl vector74
vector74:
  pushl $0
801072cf:	6a 00                	push   $0x0
  pushl $74
801072d1:	6a 4a                	push   $0x4a
  jmp alltraps
801072d3:	e9 d2 f6 ff ff       	jmp    801069aa <alltraps>

801072d8 <vector75>:
.globl vector75
vector75:
  pushl $0
801072d8:	6a 00                	push   $0x0
  pushl $75
801072da:	6a 4b                	push   $0x4b
  jmp alltraps
801072dc:	e9 c9 f6 ff ff       	jmp    801069aa <alltraps>

801072e1 <vector76>:
.globl vector76
vector76:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $76
801072e3:	6a 4c                	push   $0x4c
  jmp alltraps
801072e5:	e9 c0 f6 ff ff       	jmp    801069aa <alltraps>

801072ea <vector77>:
.globl vector77
vector77:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $77
801072ec:	6a 4d                	push   $0x4d
  jmp alltraps
801072ee:	e9 b7 f6 ff ff       	jmp    801069aa <alltraps>

801072f3 <vector78>:
.globl vector78
vector78:
  pushl $0
801072f3:	6a 00                	push   $0x0
  pushl $78
801072f5:	6a 4e                	push   $0x4e
  jmp alltraps
801072f7:	e9 ae f6 ff ff       	jmp    801069aa <alltraps>

801072fc <vector79>:
.globl vector79
vector79:
  pushl $0
801072fc:	6a 00                	push   $0x0
  pushl $79
801072fe:	6a 4f                	push   $0x4f
  jmp alltraps
80107300:	e9 a5 f6 ff ff       	jmp    801069aa <alltraps>

80107305 <vector80>:
.globl vector80
vector80:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $80
80107307:	6a 50                	push   $0x50
  jmp alltraps
80107309:	e9 9c f6 ff ff       	jmp    801069aa <alltraps>

8010730e <vector81>:
.globl vector81
vector81:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $81
80107310:	6a 51                	push   $0x51
  jmp alltraps
80107312:	e9 93 f6 ff ff       	jmp    801069aa <alltraps>

80107317 <vector82>:
.globl vector82
vector82:
  pushl $0
80107317:	6a 00                	push   $0x0
  pushl $82
80107319:	6a 52                	push   $0x52
  jmp alltraps
8010731b:	e9 8a f6 ff ff       	jmp    801069aa <alltraps>

80107320 <vector83>:
.globl vector83
vector83:
  pushl $0
80107320:	6a 00                	push   $0x0
  pushl $83
80107322:	6a 53                	push   $0x53
  jmp alltraps
80107324:	e9 81 f6 ff ff       	jmp    801069aa <alltraps>

80107329 <vector84>:
.globl vector84
vector84:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $84
8010732b:	6a 54                	push   $0x54
  jmp alltraps
8010732d:	e9 78 f6 ff ff       	jmp    801069aa <alltraps>

80107332 <vector85>:
.globl vector85
vector85:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $85
80107334:	6a 55                	push   $0x55
  jmp alltraps
80107336:	e9 6f f6 ff ff       	jmp    801069aa <alltraps>

8010733b <vector86>:
.globl vector86
vector86:
  pushl $0
8010733b:	6a 00                	push   $0x0
  pushl $86
8010733d:	6a 56                	push   $0x56
  jmp alltraps
8010733f:	e9 66 f6 ff ff       	jmp    801069aa <alltraps>

80107344 <vector87>:
.globl vector87
vector87:
  pushl $0
80107344:	6a 00                	push   $0x0
  pushl $87
80107346:	6a 57                	push   $0x57
  jmp alltraps
80107348:	e9 5d f6 ff ff       	jmp    801069aa <alltraps>

8010734d <vector88>:
.globl vector88
vector88:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $88
8010734f:	6a 58                	push   $0x58
  jmp alltraps
80107351:	e9 54 f6 ff ff       	jmp    801069aa <alltraps>

80107356 <vector89>:
.globl vector89
vector89:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $89
80107358:	6a 59                	push   $0x59
  jmp alltraps
8010735a:	e9 4b f6 ff ff       	jmp    801069aa <alltraps>

8010735f <vector90>:
.globl vector90
vector90:
  pushl $0
8010735f:	6a 00                	push   $0x0
  pushl $90
80107361:	6a 5a                	push   $0x5a
  jmp alltraps
80107363:	e9 42 f6 ff ff       	jmp    801069aa <alltraps>

80107368 <vector91>:
.globl vector91
vector91:
  pushl $0
80107368:	6a 00                	push   $0x0
  pushl $91
8010736a:	6a 5b                	push   $0x5b
  jmp alltraps
8010736c:	e9 39 f6 ff ff       	jmp    801069aa <alltraps>

80107371 <vector92>:
.globl vector92
vector92:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $92
80107373:	6a 5c                	push   $0x5c
  jmp alltraps
80107375:	e9 30 f6 ff ff       	jmp    801069aa <alltraps>

8010737a <vector93>:
.globl vector93
vector93:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $93
8010737c:	6a 5d                	push   $0x5d
  jmp alltraps
8010737e:	e9 27 f6 ff ff       	jmp    801069aa <alltraps>

80107383 <vector94>:
.globl vector94
vector94:
  pushl $0
80107383:	6a 00                	push   $0x0
  pushl $94
80107385:	6a 5e                	push   $0x5e
  jmp alltraps
80107387:	e9 1e f6 ff ff       	jmp    801069aa <alltraps>

8010738c <vector95>:
.globl vector95
vector95:
  pushl $0
8010738c:	6a 00                	push   $0x0
  pushl $95
8010738e:	6a 5f                	push   $0x5f
  jmp alltraps
80107390:	e9 15 f6 ff ff       	jmp    801069aa <alltraps>

80107395 <vector96>:
.globl vector96
vector96:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $96
80107397:	6a 60                	push   $0x60
  jmp alltraps
80107399:	e9 0c f6 ff ff       	jmp    801069aa <alltraps>

8010739e <vector97>:
.globl vector97
vector97:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $97
801073a0:	6a 61                	push   $0x61
  jmp alltraps
801073a2:	e9 03 f6 ff ff       	jmp    801069aa <alltraps>

801073a7 <vector98>:
.globl vector98
vector98:
  pushl $0
801073a7:	6a 00                	push   $0x0
  pushl $98
801073a9:	6a 62                	push   $0x62
  jmp alltraps
801073ab:	e9 fa f5 ff ff       	jmp    801069aa <alltraps>

801073b0 <vector99>:
.globl vector99
vector99:
  pushl $0
801073b0:	6a 00                	push   $0x0
  pushl $99
801073b2:	6a 63                	push   $0x63
  jmp alltraps
801073b4:	e9 f1 f5 ff ff       	jmp    801069aa <alltraps>

801073b9 <vector100>:
.globl vector100
vector100:
  pushl $0
801073b9:	6a 00                	push   $0x0
  pushl $100
801073bb:	6a 64                	push   $0x64
  jmp alltraps
801073bd:	e9 e8 f5 ff ff       	jmp    801069aa <alltraps>

801073c2 <vector101>:
.globl vector101
vector101:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $101
801073c4:	6a 65                	push   $0x65
  jmp alltraps
801073c6:	e9 df f5 ff ff       	jmp    801069aa <alltraps>

801073cb <vector102>:
.globl vector102
vector102:
  pushl $0
801073cb:	6a 00                	push   $0x0
  pushl $102
801073cd:	6a 66                	push   $0x66
  jmp alltraps
801073cf:	e9 d6 f5 ff ff       	jmp    801069aa <alltraps>

801073d4 <vector103>:
.globl vector103
vector103:
  pushl $0
801073d4:	6a 00                	push   $0x0
  pushl $103
801073d6:	6a 67                	push   $0x67
  jmp alltraps
801073d8:	e9 cd f5 ff ff       	jmp    801069aa <alltraps>

801073dd <vector104>:
.globl vector104
vector104:
  pushl $0
801073dd:	6a 00                	push   $0x0
  pushl $104
801073df:	6a 68                	push   $0x68
  jmp alltraps
801073e1:	e9 c4 f5 ff ff       	jmp    801069aa <alltraps>

801073e6 <vector105>:
.globl vector105
vector105:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $105
801073e8:	6a 69                	push   $0x69
  jmp alltraps
801073ea:	e9 bb f5 ff ff       	jmp    801069aa <alltraps>

801073ef <vector106>:
.globl vector106
vector106:
  pushl $0
801073ef:	6a 00                	push   $0x0
  pushl $106
801073f1:	6a 6a                	push   $0x6a
  jmp alltraps
801073f3:	e9 b2 f5 ff ff       	jmp    801069aa <alltraps>

801073f8 <vector107>:
.globl vector107
vector107:
  pushl $0
801073f8:	6a 00                	push   $0x0
  pushl $107
801073fa:	6a 6b                	push   $0x6b
  jmp alltraps
801073fc:	e9 a9 f5 ff ff       	jmp    801069aa <alltraps>

80107401 <vector108>:
.globl vector108
vector108:
  pushl $0
80107401:	6a 00                	push   $0x0
  pushl $108
80107403:	6a 6c                	push   $0x6c
  jmp alltraps
80107405:	e9 a0 f5 ff ff       	jmp    801069aa <alltraps>

8010740a <vector109>:
.globl vector109
vector109:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $109
8010740c:	6a 6d                	push   $0x6d
  jmp alltraps
8010740e:	e9 97 f5 ff ff       	jmp    801069aa <alltraps>

80107413 <vector110>:
.globl vector110
vector110:
  pushl $0
80107413:	6a 00                	push   $0x0
  pushl $110
80107415:	6a 6e                	push   $0x6e
  jmp alltraps
80107417:	e9 8e f5 ff ff       	jmp    801069aa <alltraps>

8010741c <vector111>:
.globl vector111
vector111:
  pushl $0
8010741c:	6a 00                	push   $0x0
  pushl $111
8010741e:	6a 6f                	push   $0x6f
  jmp alltraps
80107420:	e9 85 f5 ff ff       	jmp    801069aa <alltraps>

80107425 <vector112>:
.globl vector112
vector112:
  pushl $0
80107425:	6a 00                	push   $0x0
  pushl $112
80107427:	6a 70                	push   $0x70
  jmp alltraps
80107429:	e9 7c f5 ff ff       	jmp    801069aa <alltraps>

8010742e <vector113>:
.globl vector113
vector113:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $113
80107430:	6a 71                	push   $0x71
  jmp alltraps
80107432:	e9 73 f5 ff ff       	jmp    801069aa <alltraps>

80107437 <vector114>:
.globl vector114
vector114:
  pushl $0
80107437:	6a 00                	push   $0x0
  pushl $114
80107439:	6a 72                	push   $0x72
  jmp alltraps
8010743b:	e9 6a f5 ff ff       	jmp    801069aa <alltraps>

80107440 <vector115>:
.globl vector115
vector115:
  pushl $0
80107440:	6a 00                	push   $0x0
  pushl $115
80107442:	6a 73                	push   $0x73
  jmp alltraps
80107444:	e9 61 f5 ff ff       	jmp    801069aa <alltraps>

80107449 <vector116>:
.globl vector116
vector116:
  pushl $0
80107449:	6a 00                	push   $0x0
  pushl $116
8010744b:	6a 74                	push   $0x74
  jmp alltraps
8010744d:	e9 58 f5 ff ff       	jmp    801069aa <alltraps>

80107452 <vector117>:
.globl vector117
vector117:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $117
80107454:	6a 75                	push   $0x75
  jmp alltraps
80107456:	e9 4f f5 ff ff       	jmp    801069aa <alltraps>

8010745b <vector118>:
.globl vector118
vector118:
  pushl $0
8010745b:	6a 00                	push   $0x0
  pushl $118
8010745d:	6a 76                	push   $0x76
  jmp alltraps
8010745f:	e9 46 f5 ff ff       	jmp    801069aa <alltraps>

80107464 <vector119>:
.globl vector119
vector119:
  pushl $0
80107464:	6a 00                	push   $0x0
  pushl $119
80107466:	6a 77                	push   $0x77
  jmp alltraps
80107468:	e9 3d f5 ff ff       	jmp    801069aa <alltraps>

8010746d <vector120>:
.globl vector120
vector120:
  pushl $0
8010746d:	6a 00                	push   $0x0
  pushl $120
8010746f:	6a 78                	push   $0x78
  jmp alltraps
80107471:	e9 34 f5 ff ff       	jmp    801069aa <alltraps>

80107476 <vector121>:
.globl vector121
vector121:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $121
80107478:	6a 79                	push   $0x79
  jmp alltraps
8010747a:	e9 2b f5 ff ff       	jmp    801069aa <alltraps>

8010747f <vector122>:
.globl vector122
vector122:
  pushl $0
8010747f:	6a 00                	push   $0x0
  pushl $122
80107481:	6a 7a                	push   $0x7a
  jmp alltraps
80107483:	e9 22 f5 ff ff       	jmp    801069aa <alltraps>

80107488 <vector123>:
.globl vector123
vector123:
  pushl $0
80107488:	6a 00                	push   $0x0
  pushl $123
8010748a:	6a 7b                	push   $0x7b
  jmp alltraps
8010748c:	e9 19 f5 ff ff       	jmp    801069aa <alltraps>

80107491 <vector124>:
.globl vector124
vector124:
  pushl $0
80107491:	6a 00                	push   $0x0
  pushl $124
80107493:	6a 7c                	push   $0x7c
  jmp alltraps
80107495:	e9 10 f5 ff ff       	jmp    801069aa <alltraps>

8010749a <vector125>:
.globl vector125
vector125:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $125
8010749c:	6a 7d                	push   $0x7d
  jmp alltraps
8010749e:	e9 07 f5 ff ff       	jmp    801069aa <alltraps>

801074a3 <vector126>:
.globl vector126
vector126:
  pushl $0
801074a3:	6a 00                	push   $0x0
  pushl $126
801074a5:	6a 7e                	push   $0x7e
  jmp alltraps
801074a7:	e9 fe f4 ff ff       	jmp    801069aa <alltraps>

801074ac <vector127>:
.globl vector127
vector127:
  pushl $0
801074ac:	6a 00                	push   $0x0
  pushl $127
801074ae:	6a 7f                	push   $0x7f
  jmp alltraps
801074b0:	e9 f5 f4 ff ff       	jmp    801069aa <alltraps>

801074b5 <vector128>:
.globl vector128
vector128:
  pushl $0
801074b5:	6a 00                	push   $0x0
  pushl $128
801074b7:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801074bc:	e9 e9 f4 ff ff       	jmp    801069aa <alltraps>

801074c1 <vector129>:
.globl vector129
vector129:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $129
801074c3:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801074c8:	e9 dd f4 ff ff       	jmp    801069aa <alltraps>

801074cd <vector130>:
.globl vector130
vector130:
  pushl $0
801074cd:	6a 00                	push   $0x0
  pushl $130
801074cf:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801074d4:	e9 d1 f4 ff ff       	jmp    801069aa <alltraps>

801074d9 <vector131>:
.globl vector131
vector131:
  pushl $0
801074d9:	6a 00                	push   $0x0
  pushl $131
801074db:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801074e0:	e9 c5 f4 ff ff       	jmp    801069aa <alltraps>

801074e5 <vector132>:
.globl vector132
vector132:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $132
801074e7:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801074ec:	e9 b9 f4 ff ff       	jmp    801069aa <alltraps>

801074f1 <vector133>:
.globl vector133
vector133:
  pushl $0
801074f1:	6a 00                	push   $0x0
  pushl $133
801074f3:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801074f8:	e9 ad f4 ff ff       	jmp    801069aa <alltraps>

801074fd <vector134>:
.globl vector134
vector134:
  pushl $0
801074fd:	6a 00                	push   $0x0
  pushl $134
801074ff:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107504:	e9 a1 f4 ff ff       	jmp    801069aa <alltraps>

80107509 <vector135>:
.globl vector135
vector135:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $135
8010750b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107510:	e9 95 f4 ff ff       	jmp    801069aa <alltraps>

80107515 <vector136>:
.globl vector136
vector136:
  pushl $0
80107515:	6a 00                	push   $0x0
  pushl $136
80107517:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010751c:	e9 89 f4 ff ff       	jmp    801069aa <alltraps>

80107521 <vector137>:
.globl vector137
vector137:
  pushl $0
80107521:	6a 00                	push   $0x0
  pushl $137
80107523:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107528:	e9 7d f4 ff ff       	jmp    801069aa <alltraps>

8010752d <vector138>:
.globl vector138
vector138:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $138
8010752f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107534:	e9 71 f4 ff ff       	jmp    801069aa <alltraps>

80107539 <vector139>:
.globl vector139
vector139:
  pushl $0
80107539:	6a 00                	push   $0x0
  pushl $139
8010753b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107540:	e9 65 f4 ff ff       	jmp    801069aa <alltraps>

80107545 <vector140>:
.globl vector140
vector140:
  pushl $0
80107545:	6a 00                	push   $0x0
  pushl $140
80107547:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010754c:	e9 59 f4 ff ff       	jmp    801069aa <alltraps>

80107551 <vector141>:
.globl vector141
vector141:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $141
80107553:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107558:	e9 4d f4 ff ff       	jmp    801069aa <alltraps>

8010755d <vector142>:
.globl vector142
vector142:
  pushl $0
8010755d:	6a 00                	push   $0x0
  pushl $142
8010755f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107564:	e9 41 f4 ff ff       	jmp    801069aa <alltraps>

80107569 <vector143>:
.globl vector143
vector143:
  pushl $0
80107569:	6a 00                	push   $0x0
  pushl $143
8010756b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107570:	e9 35 f4 ff ff       	jmp    801069aa <alltraps>

80107575 <vector144>:
.globl vector144
vector144:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $144
80107577:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010757c:	e9 29 f4 ff ff       	jmp    801069aa <alltraps>

80107581 <vector145>:
.globl vector145
vector145:
  pushl $0
80107581:	6a 00                	push   $0x0
  pushl $145
80107583:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107588:	e9 1d f4 ff ff       	jmp    801069aa <alltraps>

8010758d <vector146>:
.globl vector146
vector146:
  pushl $0
8010758d:	6a 00                	push   $0x0
  pushl $146
8010758f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107594:	e9 11 f4 ff ff       	jmp    801069aa <alltraps>

80107599 <vector147>:
.globl vector147
vector147:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $147
8010759b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801075a0:	e9 05 f4 ff ff       	jmp    801069aa <alltraps>

801075a5 <vector148>:
.globl vector148
vector148:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $148
801075a7:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801075ac:	e9 f9 f3 ff ff       	jmp    801069aa <alltraps>

801075b1 <vector149>:
.globl vector149
vector149:
  pushl $0
801075b1:	6a 00                	push   $0x0
  pushl $149
801075b3:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801075b8:	e9 ed f3 ff ff       	jmp    801069aa <alltraps>

801075bd <vector150>:
.globl vector150
vector150:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $150
801075bf:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801075c4:	e9 e1 f3 ff ff       	jmp    801069aa <alltraps>

801075c9 <vector151>:
.globl vector151
vector151:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $151
801075cb:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801075d0:	e9 d5 f3 ff ff       	jmp    801069aa <alltraps>

801075d5 <vector152>:
.globl vector152
vector152:
  pushl $0
801075d5:	6a 00                	push   $0x0
  pushl $152
801075d7:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801075dc:	e9 c9 f3 ff ff       	jmp    801069aa <alltraps>

801075e1 <vector153>:
.globl vector153
vector153:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $153
801075e3:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801075e8:	e9 bd f3 ff ff       	jmp    801069aa <alltraps>

801075ed <vector154>:
.globl vector154
vector154:
  pushl $0
801075ed:	6a 00                	push   $0x0
  pushl $154
801075ef:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801075f4:	e9 b1 f3 ff ff       	jmp    801069aa <alltraps>

801075f9 <vector155>:
.globl vector155
vector155:
  pushl $0
801075f9:	6a 00                	push   $0x0
  pushl $155
801075fb:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107600:	e9 a5 f3 ff ff       	jmp    801069aa <alltraps>

80107605 <vector156>:
.globl vector156
vector156:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $156
80107607:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010760c:	e9 99 f3 ff ff       	jmp    801069aa <alltraps>

80107611 <vector157>:
.globl vector157
vector157:
  pushl $0
80107611:	6a 00                	push   $0x0
  pushl $157
80107613:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107618:	e9 8d f3 ff ff       	jmp    801069aa <alltraps>

8010761d <vector158>:
.globl vector158
vector158:
  pushl $0
8010761d:	6a 00                	push   $0x0
  pushl $158
8010761f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107624:	e9 81 f3 ff ff       	jmp    801069aa <alltraps>

80107629 <vector159>:
.globl vector159
vector159:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $159
8010762b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107630:	e9 75 f3 ff ff       	jmp    801069aa <alltraps>

80107635 <vector160>:
.globl vector160
vector160:
  pushl $0
80107635:	6a 00                	push   $0x0
  pushl $160
80107637:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010763c:	e9 69 f3 ff ff       	jmp    801069aa <alltraps>

80107641 <vector161>:
.globl vector161
vector161:
  pushl $0
80107641:	6a 00                	push   $0x0
  pushl $161
80107643:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107648:	e9 5d f3 ff ff       	jmp    801069aa <alltraps>

8010764d <vector162>:
.globl vector162
vector162:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $162
8010764f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107654:	e9 51 f3 ff ff       	jmp    801069aa <alltraps>

80107659 <vector163>:
.globl vector163
vector163:
  pushl $0
80107659:	6a 00                	push   $0x0
  pushl $163
8010765b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107660:	e9 45 f3 ff ff       	jmp    801069aa <alltraps>

80107665 <vector164>:
.globl vector164
vector164:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $164
80107667:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010766c:	e9 39 f3 ff ff       	jmp    801069aa <alltraps>

80107671 <vector165>:
.globl vector165
vector165:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $165
80107673:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107678:	e9 2d f3 ff ff       	jmp    801069aa <alltraps>

8010767d <vector166>:
.globl vector166
vector166:
  pushl $0
8010767d:	6a 00                	push   $0x0
  pushl $166
8010767f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107684:	e9 21 f3 ff ff       	jmp    801069aa <alltraps>

80107689 <vector167>:
.globl vector167
vector167:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $167
8010768b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107690:	e9 15 f3 ff ff       	jmp    801069aa <alltraps>

80107695 <vector168>:
.globl vector168
vector168:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $168
80107697:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010769c:	e9 09 f3 ff ff       	jmp    801069aa <alltraps>

801076a1 <vector169>:
.globl vector169
vector169:
  pushl $0
801076a1:	6a 00                	push   $0x0
  pushl $169
801076a3:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801076a8:	e9 fd f2 ff ff       	jmp    801069aa <alltraps>

801076ad <vector170>:
.globl vector170
vector170:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $170
801076af:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801076b4:	e9 f1 f2 ff ff       	jmp    801069aa <alltraps>

801076b9 <vector171>:
.globl vector171
vector171:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $171
801076bb:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801076c0:	e9 e5 f2 ff ff       	jmp    801069aa <alltraps>

801076c5 <vector172>:
.globl vector172
vector172:
  pushl $0
801076c5:	6a 00                	push   $0x0
  pushl $172
801076c7:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801076cc:	e9 d9 f2 ff ff       	jmp    801069aa <alltraps>

801076d1 <vector173>:
.globl vector173
vector173:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $173
801076d3:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801076d8:	e9 cd f2 ff ff       	jmp    801069aa <alltraps>

801076dd <vector174>:
.globl vector174
vector174:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $174
801076df:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801076e4:	e9 c1 f2 ff ff       	jmp    801069aa <alltraps>

801076e9 <vector175>:
.globl vector175
vector175:
  pushl $0
801076e9:	6a 00                	push   $0x0
  pushl $175
801076eb:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801076f0:	e9 b5 f2 ff ff       	jmp    801069aa <alltraps>

801076f5 <vector176>:
.globl vector176
vector176:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $176
801076f7:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801076fc:	e9 a9 f2 ff ff       	jmp    801069aa <alltraps>

80107701 <vector177>:
.globl vector177
vector177:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $177
80107703:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107708:	e9 9d f2 ff ff       	jmp    801069aa <alltraps>

8010770d <vector178>:
.globl vector178
vector178:
  pushl $0
8010770d:	6a 00                	push   $0x0
  pushl $178
8010770f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107714:	e9 91 f2 ff ff       	jmp    801069aa <alltraps>

80107719 <vector179>:
.globl vector179
vector179:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $179
8010771b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107720:	e9 85 f2 ff ff       	jmp    801069aa <alltraps>

80107725 <vector180>:
.globl vector180
vector180:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $180
80107727:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010772c:	e9 79 f2 ff ff       	jmp    801069aa <alltraps>

80107731 <vector181>:
.globl vector181
vector181:
  pushl $0
80107731:	6a 00                	push   $0x0
  pushl $181
80107733:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107738:	e9 6d f2 ff ff       	jmp    801069aa <alltraps>

8010773d <vector182>:
.globl vector182
vector182:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $182
8010773f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107744:	e9 61 f2 ff ff       	jmp    801069aa <alltraps>

80107749 <vector183>:
.globl vector183
vector183:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $183
8010774b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107750:	e9 55 f2 ff ff       	jmp    801069aa <alltraps>

80107755 <vector184>:
.globl vector184
vector184:
  pushl $0
80107755:	6a 00                	push   $0x0
  pushl $184
80107757:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010775c:	e9 49 f2 ff ff       	jmp    801069aa <alltraps>

80107761 <vector185>:
.globl vector185
vector185:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $185
80107763:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107768:	e9 3d f2 ff ff       	jmp    801069aa <alltraps>

8010776d <vector186>:
.globl vector186
vector186:
  pushl $0
8010776d:	6a 00                	push   $0x0
  pushl $186
8010776f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107774:	e9 31 f2 ff ff       	jmp    801069aa <alltraps>

80107779 <vector187>:
.globl vector187
vector187:
  pushl $0
80107779:	6a 00                	push   $0x0
  pushl $187
8010777b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107780:	e9 25 f2 ff ff       	jmp    801069aa <alltraps>

80107785 <vector188>:
.globl vector188
vector188:
  pushl $0
80107785:	6a 00                	push   $0x0
  pushl $188
80107787:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010778c:	e9 19 f2 ff ff       	jmp    801069aa <alltraps>

80107791 <vector189>:
.globl vector189
vector189:
  pushl $0
80107791:	6a 00                	push   $0x0
  pushl $189
80107793:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107798:	e9 0d f2 ff ff       	jmp    801069aa <alltraps>

8010779d <vector190>:
.globl vector190
vector190:
  pushl $0
8010779d:	6a 00                	push   $0x0
  pushl $190
8010779f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801077a4:	e9 01 f2 ff ff       	jmp    801069aa <alltraps>

801077a9 <vector191>:
.globl vector191
vector191:
  pushl $0
801077a9:	6a 00                	push   $0x0
  pushl $191
801077ab:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801077b0:	e9 f5 f1 ff ff       	jmp    801069aa <alltraps>

801077b5 <vector192>:
.globl vector192
vector192:
  pushl $0
801077b5:	6a 00                	push   $0x0
  pushl $192
801077b7:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801077bc:	e9 e9 f1 ff ff       	jmp    801069aa <alltraps>

801077c1 <vector193>:
.globl vector193
vector193:
  pushl $0
801077c1:	6a 00                	push   $0x0
  pushl $193
801077c3:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801077c8:	e9 dd f1 ff ff       	jmp    801069aa <alltraps>

801077cd <vector194>:
.globl vector194
vector194:
  pushl $0
801077cd:	6a 00                	push   $0x0
  pushl $194
801077cf:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801077d4:	e9 d1 f1 ff ff       	jmp    801069aa <alltraps>

801077d9 <vector195>:
.globl vector195
vector195:
  pushl $0
801077d9:	6a 00                	push   $0x0
  pushl $195
801077db:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801077e0:	e9 c5 f1 ff ff       	jmp    801069aa <alltraps>

801077e5 <vector196>:
.globl vector196
vector196:
  pushl $0
801077e5:	6a 00                	push   $0x0
  pushl $196
801077e7:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801077ec:	e9 b9 f1 ff ff       	jmp    801069aa <alltraps>

801077f1 <vector197>:
.globl vector197
vector197:
  pushl $0
801077f1:	6a 00                	push   $0x0
  pushl $197
801077f3:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801077f8:	e9 ad f1 ff ff       	jmp    801069aa <alltraps>

801077fd <vector198>:
.globl vector198
vector198:
  pushl $0
801077fd:	6a 00                	push   $0x0
  pushl $198
801077ff:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107804:	e9 a1 f1 ff ff       	jmp    801069aa <alltraps>

80107809 <vector199>:
.globl vector199
vector199:
  pushl $0
80107809:	6a 00                	push   $0x0
  pushl $199
8010780b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107810:	e9 95 f1 ff ff       	jmp    801069aa <alltraps>

80107815 <vector200>:
.globl vector200
vector200:
  pushl $0
80107815:	6a 00                	push   $0x0
  pushl $200
80107817:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010781c:	e9 89 f1 ff ff       	jmp    801069aa <alltraps>

80107821 <vector201>:
.globl vector201
vector201:
  pushl $0
80107821:	6a 00                	push   $0x0
  pushl $201
80107823:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107828:	e9 7d f1 ff ff       	jmp    801069aa <alltraps>

8010782d <vector202>:
.globl vector202
vector202:
  pushl $0
8010782d:	6a 00                	push   $0x0
  pushl $202
8010782f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107834:	e9 71 f1 ff ff       	jmp    801069aa <alltraps>

80107839 <vector203>:
.globl vector203
vector203:
  pushl $0
80107839:	6a 00                	push   $0x0
  pushl $203
8010783b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107840:	e9 65 f1 ff ff       	jmp    801069aa <alltraps>

80107845 <vector204>:
.globl vector204
vector204:
  pushl $0
80107845:	6a 00                	push   $0x0
  pushl $204
80107847:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010784c:	e9 59 f1 ff ff       	jmp    801069aa <alltraps>

80107851 <vector205>:
.globl vector205
vector205:
  pushl $0
80107851:	6a 00                	push   $0x0
  pushl $205
80107853:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107858:	e9 4d f1 ff ff       	jmp    801069aa <alltraps>

8010785d <vector206>:
.globl vector206
vector206:
  pushl $0
8010785d:	6a 00                	push   $0x0
  pushl $206
8010785f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107864:	e9 41 f1 ff ff       	jmp    801069aa <alltraps>

80107869 <vector207>:
.globl vector207
vector207:
  pushl $0
80107869:	6a 00                	push   $0x0
  pushl $207
8010786b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107870:	e9 35 f1 ff ff       	jmp    801069aa <alltraps>

80107875 <vector208>:
.globl vector208
vector208:
  pushl $0
80107875:	6a 00                	push   $0x0
  pushl $208
80107877:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010787c:	e9 29 f1 ff ff       	jmp    801069aa <alltraps>

80107881 <vector209>:
.globl vector209
vector209:
  pushl $0
80107881:	6a 00                	push   $0x0
  pushl $209
80107883:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107888:	e9 1d f1 ff ff       	jmp    801069aa <alltraps>

8010788d <vector210>:
.globl vector210
vector210:
  pushl $0
8010788d:	6a 00                	push   $0x0
  pushl $210
8010788f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107894:	e9 11 f1 ff ff       	jmp    801069aa <alltraps>

80107899 <vector211>:
.globl vector211
vector211:
  pushl $0
80107899:	6a 00                	push   $0x0
  pushl $211
8010789b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801078a0:	e9 05 f1 ff ff       	jmp    801069aa <alltraps>

801078a5 <vector212>:
.globl vector212
vector212:
  pushl $0
801078a5:	6a 00                	push   $0x0
  pushl $212
801078a7:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801078ac:	e9 f9 f0 ff ff       	jmp    801069aa <alltraps>

801078b1 <vector213>:
.globl vector213
vector213:
  pushl $0
801078b1:	6a 00                	push   $0x0
  pushl $213
801078b3:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801078b8:	e9 ed f0 ff ff       	jmp    801069aa <alltraps>

801078bd <vector214>:
.globl vector214
vector214:
  pushl $0
801078bd:	6a 00                	push   $0x0
  pushl $214
801078bf:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801078c4:	e9 e1 f0 ff ff       	jmp    801069aa <alltraps>

801078c9 <vector215>:
.globl vector215
vector215:
  pushl $0
801078c9:	6a 00                	push   $0x0
  pushl $215
801078cb:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801078d0:	e9 d5 f0 ff ff       	jmp    801069aa <alltraps>

801078d5 <vector216>:
.globl vector216
vector216:
  pushl $0
801078d5:	6a 00                	push   $0x0
  pushl $216
801078d7:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801078dc:	e9 c9 f0 ff ff       	jmp    801069aa <alltraps>

801078e1 <vector217>:
.globl vector217
vector217:
  pushl $0
801078e1:	6a 00                	push   $0x0
  pushl $217
801078e3:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801078e8:	e9 bd f0 ff ff       	jmp    801069aa <alltraps>

801078ed <vector218>:
.globl vector218
vector218:
  pushl $0
801078ed:	6a 00                	push   $0x0
  pushl $218
801078ef:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801078f4:	e9 b1 f0 ff ff       	jmp    801069aa <alltraps>

801078f9 <vector219>:
.globl vector219
vector219:
  pushl $0
801078f9:	6a 00                	push   $0x0
  pushl $219
801078fb:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107900:	e9 a5 f0 ff ff       	jmp    801069aa <alltraps>

80107905 <vector220>:
.globl vector220
vector220:
  pushl $0
80107905:	6a 00                	push   $0x0
  pushl $220
80107907:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010790c:	e9 99 f0 ff ff       	jmp    801069aa <alltraps>

80107911 <vector221>:
.globl vector221
vector221:
  pushl $0
80107911:	6a 00                	push   $0x0
  pushl $221
80107913:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107918:	e9 8d f0 ff ff       	jmp    801069aa <alltraps>

8010791d <vector222>:
.globl vector222
vector222:
  pushl $0
8010791d:	6a 00                	push   $0x0
  pushl $222
8010791f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107924:	e9 81 f0 ff ff       	jmp    801069aa <alltraps>

80107929 <vector223>:
.globl vector223
vector223:
  pushl $0
80107929:	6a 00                	push   $0x0
  pushl $223
8010792b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107930:	e9 75 f0 ff ff       	jmp    801069aa <alltraps>

80107935 <vector224>:
.globl vector224
vector224:
  pushl $0
80107935:	6a 00                	push   $0x0
  pushl $224
80107937:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010793c:	e9 69 f0 ff ff       	jmp    801069aa <alltraps>

80107941 <vector225>:
.globl vector225
vector225:
  pushl $0
80107941:	6a 00                	push   $0x0
  pushl $225
80107943:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107948:	e9 5d f0 ff ff       	jmp    801069aa <alltraps>

8010794d <vector226>:
.globl vector226
vector226:
  pushl $0
8010794d:	6a 00                	push   $0x0
  pushl $226
8010794f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107954:	e9 51 f0 ff ff       	jmp    801069aa <alltraps>

80107959 <vector227>:
.globl vector227
vector227:
  pushl $0
80107959:	6a 00                	push   $0x0
  pushl $227
8010795b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107960:	e9 45 f0 ff ff       	jmp    801069aa <alltraps>

80107965 <vector228>:
.globl vector228
vector228:
  pushl $0
80107965:	6a 00                	push   $0x0
  pushl $228
80107967:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010796c:	e9 39 f0 ff ff       	jmp    801069aa <alltraps>

80107971 <vector229>:
.globl vector229
vector229:
  pushl $0
80107971:	6a 00                	push   $0x0
  pushl $229
80107973:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107978:	e9 2d f0 ff ff       	jmp    801069aa <alltraps>

8010797d <vector230>:
.globl vector230
vector230:
  pushl $0
8010797d:	6a 00                	push   $0x0
  pushl $230
8010797f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107984:	e9 21 f0 ff ff       	jmp    801069aa <alltraps>

80107989 <vector231>:
.globl vector231
vector231:
  pushl $0
80107989:	6a 00                	push   $0x0
  pushl $231
8010798b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107990:	e9 15 f0 ff ff       	jmp    801069aa <alltraps>

80107995 <vector232>:
.globl vector232
vector232:
  pushl $0
80107995:	6a 00                	push   $0x0
  pushl $232
80107997:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010799c:	e9 09 f0 ff ff       	jmp    801069aa <alltraps>

801079a1 <vector233>:
.globl vector233
vector233:
  pushl $0
801079a1:	6a 00                	push   $0x0
  pushl $233
801079a3:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801079a8:	e9 fd ef ff ff       	jmp    801069aa <alltraps>

801079ad <vector234>:
.globl vector234
vector234:
  pushl $0
801079ad:	6a 00                	push   $0x0
  pushl $234
801079af:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801079b4:	e9 f1 ef ff ff       	jmp    801069aa <alltraps>

801079b9 <vector235>:
.globl vector235
vector235:
  pushl $0
801079b9:	6a 00                	push   $0x0
  pushl $235
801079bb:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801079c0:	e9 e5 ef ff ff       	jmp    801069aa <alltraps>

801079c5 <vector236>:
.globl vector236
vector236:
  pushl $0
801079c5:	6a 00                	push   $0x0
  pushl $236
801079c7:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801079cc:	e9 d9 ef ff ff       	jmp    801069aa <alltraps>

801079d1 <vector237>:
.globl vector237
vector237:
  pushl $0
801079d1:	6a 00                	push   $0x0
  pushl $237
801079d3:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801079d8:	e9 cd ef ff ff       	jmp    801069aa <alltraps>

801079dd <vector238>:
.globl vector238
vector238:
  pushl $0
801079dd:	6a 00                	push   $0x0
  pushl $238
801079df:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801079e4:	e9 c1 ef ff ff       	jmp    801069aa <alltraps>

801079e9 <vector239>:
.globl vector239
vector239:
  pushl $0
801079e9:	6a 00                	push   $0x0
  pushl $239
801079eb:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801079f0:	e9 b5 ef ff ff       	jmp    801069aa <alltraps>

801079f5 <vector240>:
.globl vector240
vector240:
  pushl $0
801079f5:	6a 00                	push   $0x0
  pushl $240
801079f7:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801079fc:	e9 a9 ef ff ff       	jmp    801069aa <alltraps>

80107a01 <vector241>:
.globl vector241
vector241:
  pushl $0
80107a01:	6a 00                	push   $0x0
  pushl $241
80107a03:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107a08:	e9 9d ef ff ff       	jmp    801069aa <alltraps>

80107a0d <vector242>:
.globl vector242
vector242:
  pushl $0
80107a0d:	6a 00                	push   $0x0
  pushl $242
80107a0f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107a14:	e9 91 ef ff ff       	jmp    801069aa <alltraps>

80107a19 <vector243>:
.globl vector243
vector243:
  pushl $0
80107a19:	6a 00                	push   $0x0
  pushl $243
80107a1b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107a20:	e9 85 ef ff ff       	jmp    801069aa <alltraps>

80107a25 <vector244>:
.globl vector244
vector244:
  pushl $0
80107a25:	6a 00                	push   $0x0
  pushl $244
80107a27:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107a2c:	e9 79 ef ff ff       	jmp    801069aa <alltraps>

80107a31 <vector245>:
.globl vector245
vector245:
  pushl $0
80107a31:	6a 00                	push   $0x0
  pushl $245
80107a33:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107a38:	e9 6d ef ff ff       	jmp    801069aa <alltraps>

80107a3d <vector246>:
.globl vector246
vector246:
  pushl $0
80107a3d:	6a 00                	push   $0x0
  pushl $246
80107a3f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107a44:	e9 61 ef ff ff       	jmp    801069aa <alltraps>

80107a49 <vector247>:
.globl vector247
vector247:
  pushl $0
80107a49:	6a 00                	push   $0x0
  pushl $247
80107a4b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107a50:	e9 55 ef ff ff       	jmp    801069aa <alltraps>

80107a55 <vector248>:
.globl vector248
vector248:
  pushl $0
80107a55:	6a 00                	push   $0x0
  pushl $248
80107a57:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107a5c:	e9 49 ef ff ff       	jmp    801069aa <alltraps>

80107a61 <vector249>:
.globl vector249
vector249:
  pushl $0
80107a61:	6a 00                	push   $0x0
  pushl $249
80107a63:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107a68:	e9 3d ef ff ff       	jmp    801069aa <alltraps>

80107a6d <vector250>:
.globl vector250
vector250:
  pushl $0
80107a6d:	6a 00                	push   $0x0
  pushl $250
80107a6f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107a74:	e9 31 ef ff ff       	jmp    801069aa <alltraps>

80107a79 <vector251>:
.globl vector251
vector251:
  pushl $0
80107a79:	6a 00                	push   $0x0
  pushl $251
80107a7b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107a80:	e9 25 ef ff ff       	jmp    801069aa <alltraps>

80107a85 <vector252>:
.globl vector252
vector252:
  pushl $0
80107a85:	6a 00                	push   $0x0
  pushl $252
80107a87:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107a8c:	e9 19 ef ff ff       	jmp    801069aa <alltraps>

80107a91 <vector253>:
.globl vector253
vector253:
  pushl $0
80107a91:	6a 00                	push   $0x0
  pushl $253
80107a93:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107a98:	e9 0d ef ff ff       	jmp    801069aa <alltraps>

80107a9d <vector254>:
.globl vector254
vector254:
  pushl $0
80107a9d:	6a 00                	push   $0x0
  pushl $254
80107a9f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107aa4:	e9 01 ef ff ff       	jmp    801069aa <alltraps>

80107aa9 <vector255>:
.globl vector255
vector255:
  pushl $0
80107aa9:	6a 00                	push   $0x0
  pushl $255
80107aab:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107ab0:	e9 f5 ee ff ff       	jmp    801069aa <alltraps>

80107ab5 <lgdt>:
{
80107ab5:	55                   	push   %ebp
80107ab6:	89 e5                	mov    %esp,%ebp
80107ab8:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107abb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107abe:	83 e8 01             	sub    $0x1,%eax
80107ac1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ac8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107acc:	8b 45 08             	mov    0x8(%ebp),%eax
80107acf:	c1 e8 10             	shr    $0x10,%eax
80107ad2:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107ad6:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107ad9:	0f 01 10             	lgdtl  (%eax)
}
80107adc:	90                   	nop
80107add:	c9                   	leave  
80107ade:	c3                   	ret    

80107adf <ltr>:
{
80107adf:	55                   	push   %ebp
80107ae0:	89 e5                	mov    %esp,%ebp
80107ae2:	83 ec 04             	sub    $0x4,%esp
80107ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80107ae8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107aec:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107af0:	0f 00 d8             	ltr    %ax
}
80107af3:	90                   	nop
80107af4:	c9                   	leave  
80107af5:	c3                   	ret    

80107af6 <lcr3>:

static inline void
lcr3(uint val)
{
80107af6:	55                   	push   %ebp
80107af7:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107af9:	8b 45 08             	mov    0x8(%ebp),%eax
80107afc:	0f 22 d8             	mov    %eax,%cr3
}
80107aff:	90                   	nop
80107b00:	5d                   	pop    %ebp
80107b01:	c3                   	ret    

80107b02 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107b02:	f3 0f 1e fb          	endbr32 
80107b06:	55                   	push   %ebp
80107b07:	89 e5                	mov    %esp,%ebp
80107b09:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107b0c:	e8 f5 c4 ff ff       	call   80104006 <cpuid>
80107b11:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107b17:	05 00 af 11 80       	add    $0x8011af00,%eax
80107b1c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b22:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b34:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b3f:	83 e2 f0             	and    $0xfffffff0,%edx
80107b42:	83 ca 0a             	or     $0xa,%edx
80107b45:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b4f:	83 ca 10             	or     $0x10,%edx
80107b52:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b58:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b5c:	83 e2 9f             	and    $0xffffff9f,%edx
80107b5f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b65:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107b69:	83 ca 80             	or     $0xffffff80,%edx
80107b6c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b72:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b76:	83 ca 0f             	or     $0xf,%edx
80107b79:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b83:	83 e2 ef             	and    $0xffffffef,%edx
80107b86:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b90:	83 e2 df             	and    $0xffffffdf,%edx
80107b93:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b99:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b9d:	83 ca 40             	or     $0x40,%edx
80107ba0:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107baa:	83 ca 80             	or     $0xffffff80,%edx
80107bad:	88 50 7e             	mov    %dl,0x7e(%eax)
80107bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb3:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bba:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107bc1:	ff ff 
80107bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc6:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107bcd:	00 00 
80107bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107be3:	83 e2 f0             	and    $0xfffffff0,%edx
80107be6:	83 ca 02             	or     $0x2,%edx
80107be9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107bf9:	83 ca 10             	or     $0x10,%edx
80107bfc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c05:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c0c:	83 e2 9f             	and    $0xffffff9f,%edx
80107c0f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c18:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c1f:	83 ca 80             	or     $0xffffff80,%edx
80107c22:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c32:	83 ca 0f             	or     $0xf,%edx
80107c35:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c45:	83 e2 ef             	and    $0xffffffef,%edx
80107c48:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c51:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c58:	83 e2 df             	and    $0xffffffdf,%edx
80107c5b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c64:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c6b:	83 ca 40             	or     $0x40,%edx
80107c6e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c77:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107c7e:	83 ca 80             	or     $0xffffff80,%edx
80107c81:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c94:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107c9b:	ff ff 
80107c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca0:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107ca7:	00 00 
80107ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cac:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107cbd:	83 e2 f0             	and    $0xfffffff0,%edx
80107cc0:	83 ca 0a             	or     $0xa,%edx
80107cc3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107cd3:	83 ca 10             	or     $0x10,%edx
80107cd6:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdf:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ce6:	83 ca 60             	or     $0x60,%edx
80107ce9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf2:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107cf9:	83 ca 80             	or     $0xffffff80,%edx
80107cfc:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d05:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d0c:	83 ca 0f             	or     $0xf,%edx
80107d0f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d18:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d1f:	83 e2 ef             	and    $0xffffffef,%edx
80107d22:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d32:	83 e2 df             	and    $0xffffffdf,%edx
80107d35:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d45:	83 ca 40             	or     $0x40,%edx
80107d48:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d51:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d58:	83 ca 80             	or     $0xffffff80,%edx
80107d5b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d64:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107d75:	ff ff 
80107d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107d81:	00 00 
80107d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d86:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d90:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d97:	83 e2 f0             	and    $0xfffffff0,%edx
80107d9a:	83 ca 02             	or     $0x2,%edx
80107d9d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107dad:	83 ca 10             	or     $0x10,%edx
80107db0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107dc0:	83 ca 60             	or     $0x60,%edx
80107dc3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107dd3:	83 ca 80             	or     $0xffffff80,%edx
80107dd6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107de6:	83 ca 0f             	or     $0xf,%edx
80107de9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107df9:	83 e2 ef             	and    $0xffffffef,%edx
80107dfc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e05:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e0c:	83 e2 df             	and    $0xffffffdf,%edx
80107e0f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e18:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e1f:	83 ca 40             	or     $0x40,%edx
80107e22:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e32:	83 ca 80             	or     $0xffffff80,%edx
80107e35:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3e:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e48:	83 c0 70             	add    $0x70,%eax
80107e4b:	83 ec 08             	sub    $0x8,%esp
80107e4e:	6a 30                	push   $0x30
80107e50:	50                   	push   %eax
80107e51:	e8 5f fc ff ff       	call   80107ab5 <lgdt>
80107e56:	83 c4 10             	add    $0x10,%esp
}
80107e59:	90                   	nop
80107e5a:	c9                   	leave  
80107e5b:	c3                   	ret    

80107e5c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107e5c:	f3 0f 1e fb          	endbr32 
80107e60:	55                   	push   %ebp
80107e61:	89 e5                	mov    %esp,%ebp
80107e63:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e69:	c1 e8 16             	shr    $0x16,%eax
80107e6c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e73:	8b 45 08             	mov    0x8(%ebp),%eax
80107e76:	01 d0                	add    %edx,%eax
80107e78:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e7e:	8b 00                	mov    (%eax),%eax
80107e80:	83 e0 01             	and    $0x1,%eax
80107e83:	85 c0                	test   %eax,%eax
80107e85:	74 14                	je     80107e9b <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e8a:	8b 00                	mov    (%eax),%eax
80107e8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e91:	05 00 00 00 80       	add    $0x80000000,%eax
80107e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e99:	eb 42                	jmp    80107edd <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107e9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107e9f:	74 0e                	je     80107eaf <walkpgdir+0x53>
80107ea1:	e8 e4 ae ff ff       	call   80102d8a <kalloc>
80107ea6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ea9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107ead:	75 07                	jne    80107eb6 <walkpgdir+0x5a>
      return 0;
80107eaf:	b8 00 00 00 00       	mov    $0x0,%eax
80107eb4:	eb 3e                	jmp    80107ef4 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107eb6:	83 ec 04             	sub    $0x4,%esp
80107eb9:	68 00 10 00 00       	push   $0x1000
80107ebe:	6a 00                	push   $0x0
80107ec0:	ff 75 f4             	pushl  -0xc(%ebp)
80107ec3:	e8 df d5 ff ff       	call   801054a7 <memset>
80107ec8:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ece:	05 00 00 00 80       	add    $0x80000000,%eax
80107ed3:	83 c8 07             	or     $0x7,%eax
80107ed6:	89 c2                	mov    %eax,%edx
80107ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107edb:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107edd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ee0:	c1 e8 0c             	shr    $0xc,%eax
80107ee3:	25 ff 03 00 00       	and    $0x3ff,%eax
80107ee8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef2:	01 d0                	add    %edx,%eax
}
80107ef4:	c9                   	leave  
80107ef5:	c3                   	ret    

80107ef6 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107ef6:	f3 0f 1e fb          	endbr32 
80107efa:	55                   	push   %ebp
80107efb:	89 e5                	mov    %esp,%ebp
80107efd:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107f00:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f0b:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f0e:	8b 45 10             	mov    0x10(%ebp),%eax
80107f11:	01 d0                	add    %edx,%eax
80107f13:	83 e8 01             	sub    $0x1,%eax
80107f16:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f1e:	83 ec 04             	sub    $0x4,%esp
80107f21:	6a 01                	push   $0x1
80107f23:	ff 75 f4             	pushl  -0xc(%ebp)
80107f26:	ff 75 08             	pushl  0x8(%ebp)
80107f29:	e8 2e ff ff ff       	call   80107e5c <walkpgdir>
80107f2e:	83 c4 10             	add    $0x10,%esp
80107f31:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f34:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f38:	75 07                	jne    80107f41 <mappages+0x4b>
      return -1;
80107f3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f3f:	eb 47                	jmp    80107f88 <mappages+0x92>
    if(*pte & PTE_P)
80107f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f44:	8b 00                	mov    (%eax),%eax
80107f46:	83 e0 01             	and    $0x1,%eax
80107f49:	85 c0                	test   %eax,%eax
80107f4b:	74 0d                	je     80107f5a <mappages+0x64>
      panic("remap");
80107f4d:	83 ec 0c             	sub    $0xc,%esp
80107f50:	68 14 b3 10 80       	push   $0x8010b314
80107f55:	e8 6b 86 ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
80107f5a:	8b 45 18             	mov    0x18(%ebp),%eax
80107f5d:	0b 45 14             	or     0x14(%ebp),%eax
80107f60:	83 c8 01             	or     $0x1,%eax
80107f63:	89 c2                	mov    %eax,%edx
80107f65:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f68:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f70:	74 10                	je     80107f82 <mappages+0x8c>
      break;
    a += PGSIZE;
80107f72:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107f79:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f80:	eb 9c                	jmp    80107f1e <mappages+0x28>
      break;
80107f82:	90                   	nop
  }
  return 0;
80107f83:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f88:	c9                   	leave  
80107f89:	c3                   	ret    

80107f8a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107f8a:	f3 0f 1e fb          	endbr32 
80107f8e:	55                   	push   %ebp
80107f8f:	89 e5                	mov    %esp,%ebp
80107f91:	53                   	push   %ebx
80107f92:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107f95:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107f9c:	a1 cc b1 11 80       	mov    0x8011b1cc,%eax
80107fa1:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107fa6:	29 c2                	sub    %eax,%edx
80107fa8:	89 d0                	mov    %edx,%eax
80107faa:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107fad:	a1 c4 b1 11 80       	mov    0x8011b1c4,%eax
80107fb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107fb5:	8b 15 c4 b1 11 80    	mov    0x8011b1c4,%edx
80107fbb:	a1 cc b1 11 80       	mov    0x8011b1cc,%eax
80107fc0:	01 d0                	add    %edx,%eax
80107fc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107fc5:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcf:	83 c0 30             	add    $0x30,%eax
80107fd2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107fd5:	89 10                	mov    %edx,(%eax)
80107fd7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107fda:	89 50 04             	mov    %edx,0x4(%eax)
80107fdd:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107fe0:	89 50 08             	mov    %edx,0x8(%eax)
80107fe3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107fe6:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107fe9:	e8 9c ad ff ff       	call   80102d8a <kalloc>
80107fee:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ff1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ff5:	75 07                	jne    80107ffe <setupkvm+0x74>
    return 0;
80107ff7:	b8 00 00 00 00       	mov    $0x0,%eax
80107ffc:	eb 78                	jmp    80108076 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
80107ffe:	83 ec 04             	sub    $0x4,%esp
80108001:	68 00 10 00 00       	push   $0x1000
80108006:	6a 00                	push   $0x0
80108008:	ff 75 f0             	pushl  -0x10(%ebp)
8010800b:	e8 97 d4 ff ff       	call   801054a7 <memset>
80108010:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108013:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
8010801a:	eb 4e                	jmp    8010806a <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010801c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801f:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80108022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108025:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802b:	8b 58 08             	mov    0x8(%eax),%ebx
8010802e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108031:	8b 40 04             	mov    0x4(%eax),%eax
80108034:	29 c3                	sub    %eax,%ebx
80108036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108039:	8b 00                	mov    (%eax),%eax
8010803b:	83 ec 0c             	sub    $0xc,%esp
8010803e:	51                   	push   %ecx
8010803f:	52                   	push   %edx
80108040:	53                   	push   %ebx
80108041:	50                   	push   %eax
80108042:	ff 75 f0             	pushl  -0x10(%ebp)
80108045:	e8 ac fe ff ff       	call   80107ef6 <mappages>
8010804a:	83 c4 20             	add    $0x20,%esp
8010804d:	85 c0                	test   %eax,%eax
8010804f:	79 15                	jns    80108066 <setupkvm+0xdc>
      freevm(pgdir);
80108051:	83 ec 0c             	sub    $0xc,%esp
80108054:	ff 75 f0             	pushl  -0x10(%ebp)
80108057:	e8 11 05 00 00       	call   8010856d <freevm>
8010805c:	83 c4 10             	add    $0x10,%esp
      return 0;
8010805f:	b8 00 00 00 00       	mov    $0x0,%eax
80108064:	eb 10                	jmp    80108076 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108066:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010806a:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80108071:	72 a9                	jb     8010801c <setupkvm+0x92>
    }
  return pgdir;
80108073:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108079:	c9                   	leave  
8010807a:	c3                   	ret    

8010807b <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010807b:	f3 0f 1e fb          	endbr32 
8010807f:	55                   	push   %ebp
80108080:	89 e5                	mov    %esp,%ebp
80108082:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108085:	e8 00 ff ff ff       	call   80107f8a <setupkvm>
8010808a:	a3 c4 ae 11 80       	mov    %eax,0x8011aec4
  switchkvm();
8010808f:	e8 03 00 00 00       	call   80108097 <switchkvm>
}
80108094:	90                   	nop
80108095:	c9                   	leave  
80108096:	c3                   	ret    

80108097 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108097:	f3 0f 1e fb          	endbr32 
8010809b:	55                   	push   %ebp
8010809c:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010809e:	a1 c4 ae 11 80       	mov    0x8011aec4,%eax
801080a3:	05 00 00 00 80       	add    $0x80000000,%eax
801080a8:	50                   	push   %eax
801080a9:	e8 48 fa ff ff       	call   80107af6 <lcr3>
801080ae:	83 c4 04             	add    $0x4,%esp
}
801080b1:	90                   	nop
801080b2:	c9                   	leave  
801080b3:	c3                   	ret    

801080b4 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080b4:	f3 0f 1e fb          	endbr32 
801080b8:	55                   	push   %ebp
801080b9:	89 e5                	mov    %esp,%ebp
801080bb:	56                   	push   %esi
801080bc:	53                   	push   %ebx
801080bd:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
801080c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801080c4:	75 0d                	jne    801080d3 <switchuvm+0x1f>
    panic("switchuvm: no process");
801080c6:	83 ec 0c             	sub    $0xc,%esp
801080c9:	68 1a b3 10 80       	push   $0x8010b31a
801080ce:	e8 f2 84 ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
801080d3:	8b 45 08             	mov    0x8(%ebp),%eax
801080d6:	8b 40 08             	mov    0x8(%eax),%eax
801080d9:	85 c0                	test   %eax,%eax
801080db:	75 0d                	jne    801080ea <switchuvm+0x36>
    panic("switchuvm: no kstack");
801080dd:	83 ec 0c             	sub    $0xc,%esp
801080e0:	68 30 b3 10 80       	push   $0x8010b330
801080e5:	e8 db 84 ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
801080ea:	8b 45 08             	mov    0x8(%ebp),%eax
801080ed:	8b 40 04             	mov    0x4(%eax),%eax
801080f0:	85 c0                	test   %eax,%eax
801080f2:	75 0d                	jne    80108101 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801080f4:	83 ec 0c             	sub    $0xc,%esp
801080f7:	68 45 b3 10 80       	push   $0x8010b345
801080fc:	e8 c4 84 ff ff       	call   801005c5 <panic>

  pushcli();
80108101:	e8 8e d2 ff ff       	call   80105394 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108106:	e8 1a bf ff ff       	call   80104025 <mycpu>
8010810b:	89 c3                	mov    %eax,%ebx
8010810d:	e8 13 bf ff ff       	call   80104025 <mycpu>
80108112:	83 c0 08             	add    $0x8,%eax
80108115:	89 c6                	mov    %eax,%esi
80108117:	e8 09 bf ff ff       	call   80104025 <mycpu>
8010811c:	83 c0 08             	add    $0x8,%eax
8010811f:	c1 e8 10             	shr    $0x10,%eax
80108122:	88 45 f7             	mov    %al,-0x9(%ebp)
80108125:	e8 fb be ff ff       	call   80104025 <mycpu>
8010812a:	83 c0 08             	add    $0x8,%eax
8010812d:	c1 e8 18             	shr    $0x18,%eax
80108130:	89 c2                	mov    %eax,%edx
80108132:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108139:	67 00 
8010813b:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108142:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80108146:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
8010814c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108153:	83 e0 f0             	and    $0xfffffff0,%eax
80108156:	83 c8 09             	or     $0x9,%eax
80108159:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010815f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108166:	83 c8 10             	or     $0x10,%eax
80108169:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010816f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108176:	83 e0 9f             	and    $0xffffff9f,%eax
80108179:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010817f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108186:	83 c8 80             	or     $0xffffff80,%eax
80108189:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
8010818f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108196:	83 e0 f0             	and    $0xfffffff0,%eax
80108199:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010819f:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081a6:	83 e0 ef             	and    $0xffffffef,%eax
801081a9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081af:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081b6:	83 e0 df             	and    $0xffffffdf,%eax
801081b9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081bf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081c6:	83 c8 40             	or     $0x40,%eax
801081c9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081cf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801081d6:	83 e0 7f             	and    $0x7f,%eax
801081d9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801081df:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801081e5:	e8 3b be ff ff       	call   80104025 <mycpu>
801081ea:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801081f1:	83 e2 ef             	and    $0xffffffef,%edx
801081f4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801081fa:	e8 26 be ff ff       	call   80104025 <mycpu>
801081ff:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108205:	8b 45 08             	mov    0x8(%ebp),%eax
80108208:	8b 40 08             	mov    0x8(%eax),%eax
8010820b:	89 c3                	mov    %eax,%ebx
8010820d:	e8 13 be ff ff       	call   80104025 <mycpu>
80108212:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108218:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010821b:	e8 05 be ff ff       	call   80104025 <mycpu>
80108220:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108226:	83 ec 0c             	sub    $0xc,%esp
80108229:	6a 28                	push   $0x28
8010822b:	e8 af f8 ff ff       	call   80107adf <ltr>
80108230:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108233:	8b 45 08             	mov    0x8(%ebp),%eax
80108236:	8b 40 04             	mov    0x4(%eax),%eax
80108239:	05 00 00 00 80       	add    $0x80000000,%eax
8010823e:	83 ec 0c             	sub    $0xc,%esp
80108241:	50                   	push   %eax
80108242:	e8 af f8 ff ff       	call   80107af6 <lcr3>
80108247:	83 c4 10             	add    $0x10,%esp
  popcli();
8010824a:	e8 96 d1 ff ff       	call   801053e5 <popcli>
}
8010824f:	90                   	nop
80108250:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108253:	5b                   	pop    %ebx
80108254:	5e                   	pop    %esi
80108255:	5d                   	pop    %ebp
80108256:	c3                   	ret    

80108257 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108257:	f3 0f 1e fb          	endbr32 
8010825b:	55                   	push   %ebp
8010825c:	89 e5                	mov    %esp,%ebp
8010825e:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108261:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108268:	76 0d                	jbe    80108277 <inituvm+0x20>
    panic("inituvm: more than a page");
8010826a:	83 ec 0c             	sub    $0xc,%esp
8010826d:	68 59 b3 10 80       	push   $0x8010b359
80108272:	e8 4e 83 ff ff       	call   801005c5 <panic>
  mem = kalloc();
80108277:	e8 0e ab ff ff       	call   80102d8a <kalloc>
8010827c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010827f:	83 ec 04             	sub    $0x4,%esp
80108282:	68 00 10 00 00       	push   $0x1000
80108287:	6a 00                	push   $0x0
80108289:	ff 75 f4             	pushl  -0xc(%ebp)
8010828c:	e8 16 d2 ff ff       	call   801054a7 <memset>
80108291:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108294:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108297:	05 00 00 00 80       	add    $0x80000000,%eax
8010829c:	83 ec 0c             	sub    $0xc,%esp
8010829f:	6a 06                	push   $0x6
801082a1:	50                   	push   %eax
801082a2:	68 00 10 00 00       	push   $0x1000
801082a7:	6a 00                	push   $0x0
801082a9:	ff 75 08             	pushl  0x8(%ebp)
801082ac:	e8 45 fc ff ff       	call   80107ef6 <mappages>
801082b1:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801082b4:	83 ec 04             	sub    $0x4,%esp
801082b7:	ff 75 10             	pushl  0x10(%ebp)
801082ba:	ff 75 0c             	pushl  0xc(%ebp)
801082bd:	ff 75 f4             	pushl  -0xc(%ebp)
801082c0:	e8 a9 d2 ff ff       	call   8010556e <memmove>
801082c5:	83 c4 10             	add    $0x10,%esp
}
801082c8:	90                   	nop
801082c9:	c9                   	leave  
801082ca:	c3                   	ret    

801082cb <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082cb:	f3 0f 1e fb          	endbr32 
801082cf:	55                   	push   %ebp
801082d0:	89 e5                	mov    %esp,%ebp
801082d2:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801082d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801082d8:	25 ff 0f 00 00       	and    $0xfff,%eax
801082dd:	85 c0                	test   %eax,%eax
801082df:	74 0d                	je     801082ee <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801082e1:	83 ec 0c             	sub    $0xc,%esp
801082e4:	68 74 b3 10 80       	push   $0x8010b374
801082e9:	e8 d7 82 ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801082ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082f5:	e9 8f 00 00 00       	jmp    80108389 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801082fa:	8b 55 0c             	mov    0xc(%ebp),%edx
801082fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108300:	01 d0                	add    %edx,%eax
80108302:	83 ec 04             	sub    $0x4,%esp
80108305:	6a 00                	push   $0x0
80108307:	50                   	push   %eax
80108308:	ff 75 08             	pushl  0x8(%ebp)
8010830b:	e8 4c fb ff ff       	call   80107e5c <walkpgdir>
80108310:	83 c4 10             	add    $0x10,%esp
80108313:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108316:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010831a:	75 0d                	jne    80108329 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
8010831c:	83 ec 0c             	sub    $0xc,%esp
8010831f:	68 97 b3 10 80       	push   $0x8010b397
80108324:	e8 9c 82 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80108329:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010832c:	8b 00                	mov    (%eax),%eax
8010832e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108333:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108336:	8b 45 18             	mov    0x18(%ebp),%eax
80108339:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010833c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108341:	77 0b                	ja     8010834e <loaduvm+0x83>
      n = sz - i;
80108343:	8b 45 18             	mov    0x18(%ebp),%eax
80108346:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108349:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010834c:	eb 07                	jmp    80108355 <loaduvm+0x8a>
    else
      n = PGSIZE;
8010834e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108355:	8b 55 14             	mov    0x14(%ebp),%edx
80108358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010835b:	01 d0                	add    %edx,%eax
8010835d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108360:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108366:	ff 75 f0             	pushl  -0x10(%ebp)
80108369:	50                   	push   %eax
8010836a:	52                   	push   %edx
8010836b:	ff 75 10             	pushl  0x10(%ebp)
8010836e:	e8 11 9c ff ff       	call   80101f84 <readi>
80108373:	83 c4 10             	add    $0x10,%esp
80108376:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108379:	74 07                	je     80108382 <loaduvm+0xb7>
      return -1;
8010837b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108380:	eb 18                	jmp    8010839a <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80108382:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838c:	3b 45 18             	cmp    0x18(%ebp),%eax
8010838f:	0f 82 65 ff ff ff    	jb     801082fa <loaduvm+0x2f>
  }
  return 0;
80108395:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010839a:	c9                   	leave  
8010839b:	c3                   	ret    

8010839c <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010839c:	f3 0f 1e fb          	endbr32 
801083a0:	55                   	push   %ebp
801083a1:	89 e5                	mov    %esp,%ebp
801083a3:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801083a6:	8b 45 10             	mov    0x10(%ebp),%eax
801083a9:	85 c0                	test   %eax,%eax
801083ab:	79 0a                	jns    801083b7 <allocuvm+0x1b>
    return 0;
801083ad:	b8 00 00 00 00       	mov    $0x0,%eax
801083b2:	e9 ec 00 00 00       	jmp    801084a3 <allocuvm+0x107>
  if(newsz < oldsz)
801083b7:	8b 45 10             	mov    0x10(%ebp),%eax
801083ba:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083bd:	73 08                	jae    801083c7 <allocuvm+0x2b>
    return oldsz;
801083bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c2:	e9 dc 00 00 00       	jmp    801084a3 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
801083c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801083ca:	05 ff 0f 00 00       	add    $0xfff,%eax
801083cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801083d7:	e9 b8 00 00 00       	jmp    80108494 <allocuvm+0xf8>
    mem = kalloc();
801083dc:	e8 a9 a9 ff ff       	call   80102d8a <kalloc>
801083e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801083e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083e8:	75 2e                	jne    80108418 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
801083ea:	83 ec 0c             	sub    $0xc,%esp
801083ed:	68 b5 b3 10 80       	push   $0x8010b3b5
801083f2:	e8 15 80 ff ff       	call   8010040c <cprintf>
801083f7:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801083fa:	83 ec 04             	sub    $0x4,%esp
801083fd:	ff 75 0c             	pushl  0xc(%ebp)
80108400:	ff 75 10             	pushl  0x10(%ebp)
80108403:	ff 75 08             	pushl  0x8(%ebp)
80108406:	e8 9a 00 00 00       	call   801084a5 <deallocuvm>
8010840b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010840e:	b8 00 00 00 00       	mov    $0x0,%eax
80108413:	e9 8b 00 00 00       	jmp    801084a3 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80108418:	83 ec 04             	sub    $0x4,%esp
8010841b:	68 00 10 00 00       	push   $0x1000
80108420:	6a 00                	push   $0x0
80108422:	ff 75 f0             	pushl  -0x10(%ebp)
80108425:	e8 7d d0 ff ff       	call   801054a7 <memset>
8010842a:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010842d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108430:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108439:	83 ec 0c             	sub    $0xc,%esp
8010843c:	6a 06                	push   $0x6
8010843e:	52                   	push   %edx
8010843f:	68 00 10 00 00       	push   $0x1000
80108444:	50                   	push   %eax
80108445:	ff 75 08             	pushl  0x8(%ebp)
80108448:	e8 a9 fa ff ff       	call   80107ef6 <mappages>
8010844d:	83 c4 20             	add    $0x20,%esp
80108450:	85 c0                	test   %eax,%eax
80108452:	79 39                	jns    8010848d <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80108454:	83 ec 0c             	sub    $0xc,%esp
80108457:	68 cd b3 10 80       	push   $0x8010b3cd
8010845c:	e8 ab 7f ff ff       	call   8010040c <cprintf>
80108461:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108464:	83 ec 04             	sub    $0x4,%esp
80108467:	ff 75 0c             	pushl  0xc(%ebp)
8010846a:	ff 75 10             	pushl  0x10(%ebp)
8010846d:	ff 75 08             	pushl  0x8(%ebp)
80108470:	e8 30 00 00 00       	call   801084a5 <deallocuvm>
80108475:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108478:	83 ec 0c             	sub    $0xc,%esp
8010847b:	ff 75 f0             	pushl  -0x10(%ebp)
8010847e:	e8 69 a8 ff ff       	call   80102cec <kfree>
80108483:	83 c4 10             	add    $0x10,%esp
      return 0;
80108486:	b8 00 00 00 00       	mov    $0x0,%eax
8010848b:	eb 16                	jmp    801084a3 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
8010848d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108497:	3b 45 10             	cmp    0x10(%ebp),%eax
8010849a:	0f 82 3c ff ff ff    	jb     801083dc <allocuvm+0x40>
    }
  }
  return newsz;
801084a0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084a3:	c9                   	leave  
801084a4:	c3                   	ret    

801084a5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084a5:	f3 0f 1e fb          	endbr32 
801084a9:	55                   	push   %ebp
801084aa:	89 e5                	mov    %esp,%ebp
801084ac:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801084af:	8b 45 10             	mov    0x10(%ebp),%eax
801084b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084b5:	72 08                	jb     801084bf <deallocuvm+0x1a>
    return oldsz;
801084b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ba:	e9 ac 00 00 00       	jmp    8010856b <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
801084bf:	8b 45 10             	mov    0x10(%ebp),%eax
801084c2:	05 ff 0f 00 00       	add    $0xfff,%eax
801084c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801084cf:	e9 88 00 00 00       	jmp    8010855c <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
801084d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d7:	83 ec 04             	sub    $0x4,%esp
801084da:	6a 00                	push   $0x0
801084dc:	50                   	push   %eax
801084dd:	ff 75 08             	pushl  0x8(%ebp)
801084e0:	e8 77 f9 ff ff       	call   80107e5c <walkpgdir>
801084e5:	83 c4 10             	add    $0x10,%esp
801084e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801084eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084ef:	75 16                	jne    80108507 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801084f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f4:	c1 e8 16             	shr    $0x16,%eax
801084f7:	83 c0 01             	add    $0x1,%eax
801084fa:	c1 e0 16             	shl    $0x16,%eax
801084fd:	2d 00 10 00 00       	sub    $0x1000,%eax
80108502:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108505:	eb 4e                	jmp    80108555 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80108507:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010850a:	8b 00                	mov    (%eax),%eax
8010850c:	83 e0 01             	and    $0x1,%eax
8010850f:	85 c0                	test   %eax,%eax
80108511:	74 42                	je     80108555 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80108513:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108516:	8b 00                	mov    (%eax),%eax
80108518:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010851d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108520:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108524:	75 0d                	jne    80108533 <deallocuvm+0x8e>
        panic("kfree");
80108526:	83 ec 0c             	sub    $0xc,%esp
80108529:	68 e9 b3 10 80       	push   $0x8010b3e9
8010852e:	e8 92 80 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80108533:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108536:	05 00 00 00 80       	add    $0x80000000,%eax
8010853b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010853e:	83 ec 0c             	sub    $0xc,%esp
80108541:	ff 75 e8             	pushl  -0x18(%ebp)
80108544:	e8 a3 a7 ff ff       	call   80102cec <kfree>
80108549:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010854c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010854f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108555:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010855c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108562:	0f 82 6c ff ff ff    	jb     801084d4 <deallocuvm+0x2f>
    }
  }
  return newsz;
80108568:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010856b:	c9                   	leave  
8010856c:	c3                   	ret    

8010856d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010856d:	f3 0f 1e fb          	endbr32 
80108571:	55                   	push   %ebp
80108572:	89 e5                	mov    %esp,%ebp
80108574:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108577:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010857b:	75 0d                	jne    8010858a <freevm+0x1d>
    panic("freevm: no pgdir");
8010857d:	83 ec 0c             	sub    $0xc,%esp
80108580:	68 ef b3 10 80       	push   $0x8010b3ef
80108585:	e8 3b 80 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010858a:	83 ec 04             	sub    $0x4,%esp
8010858d:	6a 00                	push   $0x0
8010858f:	68 00 00 00 80       	push   $0x80000000
80108594:	ff 75 08             	pushl  0x8(%ebp)
80108597:	e8 09 ff ff ff       	call   801084a5 <deallocuvm>
8010859c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010859f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085a6:	eb 48                	jmp    801085f0 <freevm+0x83>
    if(pgdir[i] & PTE_P){
801085a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085b2:	8b 45 08             	mov    0x8(%ebp),%eax
801085b5:	01 d0                	add    %edx,%eax
801085b7:	8b 00                	mov    (%eax),%eax
801085b9:	83 e0 01             	and    $0x1,%eax
801085bc:	85 c0                	test   %eax,%eax
801085be:	74 2c                	je     801085ec <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801085c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085ca:	8b 45 08             	mov    0x8(%ebp),%eax
801085cd:	01 d0                	add    %edx,%eax
801085cf:	8b 00                	mov    (%eax),%eax
801085d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085d6:	05 00 00 00 80       	add    $0x80000000,%eax
801085db:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801085de:	83 ec 0c             	sub    $0xc,%esp
801085e1:	ff 75 f0             	pushl  -0x10(%ebp)
801085e4:	e8 03 a7 ff ff       	call   80102cec <kfree>
801085e9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801085ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085f0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801085f7:	76 af                	jbe    801085a8 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801085f9:	83 ec 0c             	sub    $0xc,%esp
801085fc:	ff 75 08             	pushl  0x8(%ebp)
801085ff:	e8 e8 a6 ff ff       	call   80102cec <kfree>
80108604:	83 c4 10             	add    $0x10,%esp
}
80108607:	90                   	nop
80108608:	c9                   	leave  
80108609:	c3                   	ret    

8010860a <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010860a:	f3 0f 1e fb          	endbr32 
8010860e:	55                   	push   %ebp
8010860f:	89 e5                	mov    %esp,%ebp
80108611:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108614:	83 ec 04             	sub    $0x4,%esp
80108617:	6a 00                	push   $0x0
80108619:	ff 75 0c             	pushl  0xc(%ebp)
8010861c:	ff 75 08             	pushl  0x8(%ebp)
8010861f:	e8 38 f8 ff ff       	call   80107e5c <walkpgdir>
80108624:	83 c4 10             	add    $0x10,%esp
80108627:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010862a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010862e:	75 0d                	jne    8010863d <clearpteu+0x33>
    panic("clearpteu");
80108630:	83 ec 0c             	sub    $0xc,%esp
80108633:	68 00 b4 10 80       	push   $0x8010b400
80108638:	e8 88 7f ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
8010863d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108640:	8b 00                	mov    (%eax),%eax
80108642:	83 e0 fb             	and    $0xfffffffb,%eax
80108645:	89 c2                	mov    %eax,%edx
80108647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864a:	89 10                	mov    %edx,(%eax)
}
8010864c:	90                   	nop
8010864d:	c9                   	leave  
8010864e:	c3                   	ret    

8010864f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010864f:	f3 0f 1e fb          	endbr32 
80108653:	55                   	push   %ebp
80108654:	89 e5                	mov    %esp,%ebp
80108656:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108659:	e8 2c f9 ff ff       	call   80107f8a <setupkvm>
8010865e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108661:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108665:	75 0a                	jne    80108671 <copyuvm+0x22>
    return 0;
80108667:	b8 00 00 00 00       	mov    $0x0,%eax
8010866c:	e9 eb 00 00 00       	jmp    8010875c <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
80108671:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108678:	e9 b7 00 00 00       	jmp    80108734 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010867d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108680:	83 ec 04             	sub    $0x4,%esp
80108683:	6a 00                	push   $0x0
80108685:	50                   	push   %eax
80108686:	ff 75 08             	pushl  0x8(%ebp)
80108689:	e8 ce f7 ff ff       	call   80107e5c <walkpgdir>
8010868e:	83 c4 10             	add    $0x10,%esp
80108691:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108694:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108698:	75 0d                	jne    801086a7 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
8010869a:	83 ec 0c             	sub    $0xc,%esp
8010869d:	68 0a b4 10 80       	push   $0x8010b40a
801086a2:	e8 1e 7f ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
801086a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086aa:	8b 00                	mov    (%eax),%eax
801086ac:	83 e0 01             	and    $0x1,%eax
801086af:	85 c0                	test   %eax,%eax
801086b1:	75 0d                	jne    801086c0 <copyuvm+0x71>
      panic("copyuvm: page not present");
801086b3:	83 ec 0c             	sub    $0xc,%esp
801086b6:	68 24 b4 10 80       	push   $0x8010b424
801086bb:	e8 05 7f ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
801086c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086c3:	8b 00                	mov    (%eax),%eax
801086c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801086cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086d0:	8b 00                	mov    (%eax),%eax
801086d2:	25 ff 0f 00 00       	and    $0xfff,%eax
801086d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801086da:	e8 ab a6 ff ff       	call   80102d8a <kalloc>
801086df:	89 45 e0             	mov    %eax,-0x20(%ebp)
801086e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801086e6:	74 5d                	je     80108745 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801086e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086eb:	05 00 00 00 80       	add    $0x80000000,%eax
801086f0:	83 ec 04             	sub    $0x4,%esp
801086f3:	68 00 10 00 00       	push   $0x1000
801086f8:	50                   	push   %eax
801086f9:	ff 75 e0             	pushl  -0x20(%ebp)
801086fc:	e8 6d ce ff ff       	call   8010556e <memmove>
80108701:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108704:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108707:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010870a:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108713:	83 ec 0c             	sub    $0xc,%esp
80108716:	52                   	push   %edx
80108717:	51                   	push   %ecx
80108718:	68 00 10 00 00       	push   $0x1000
8010871d:	50                   	push   %eax
8010871e:	ff 75 f0             	pushl  -0x10(%ebp)
80108721:	e8 d0 f7 ff ff       	call   80107ef6 <mappages>
80108726:	83 c4 20             	add    $0x20,%esp
80108729:	85 c0                	test   %eax,%eax
8010872b:	78 1b                	js     80108748 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
8010872d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108737:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010873a:	0f 82 3d ff ff ff    	jb     8010867d <copyuvm+0x2e>
      goto bad;
  }
  return d;
80108740:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108743:	eb 17                	jmp    8010875c <copyuvm+0x10d>
      goto bad;
80108745:	90                   	nop
80108746:	eb 01                	jmp    80108749 <copyuvm+0xfa>
      goto bad;
80108748:	90                   	nop

bad:
  freevm(d);
80108749:	83 ec 0c             	sub    $0xc,%esp
8010874c:	ff 75 f0             	pushl  -0x10(%ebp)
8010874f:	e8 19 fe ff ff       	call   8010856d <freevm>
80108754:	83 c4 10             	add    $0x10,%esp
  return 0;
80108757:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010875c:	c9                   	leave  
8010875d:	c3                   	ret    

8010875e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010875e:	f3 0f 1e fb          	endbr32 
80108762:	55                   	push   %ebp
80108763:	89 e5                	mov    %esp,%ebp
80108765:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108768:	83 ec 04             	sub    $0x4,%esp
8010876b:	6a 00                	push   $0x0
8010876d:	ff 75 0c             	pushl  0xc(%ebp)
80108770:	ff 75 08             	pushl  0x8(%ebp)
80108773:	e8 e4 f6 ff ff       	call   80107e5c <walkpgdir>
80108778:	83 c4 10             	add    $0x10,%esp
8010877b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010877e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108781:	8b 00                	mov    (%eax),%eax
80108783:	83 e0 01             	and    $0x1,%eax
80108786:	85 c0                	test   %eax,%eax
80108788:	75 07                	jne    80108791 <uva2ka+0x33>
    return 0;
8010878a:	b8 00 00 00 00       	mov    $0x0,%eax
8010878f:	eb 22                	jmp    801087b3 <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80108791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108794:	8b 00                	mov    (%eax),%eax
80108796:	83 e0 04             	and    $0x4,%eax
80108799:	85 c0                	test   %eax,%eax
8010879b:	75 07                	jne    801087a4 <uva2ka+0x46>
    return 0;
8010879d:	b8 00 00 00 00       	mov    $0x0,%eax
801087a2:	eb 0f                	jmp    801087b3 <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
801087a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a7:	8b 00                	mov    (%eax),%eax
801087a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087ae:	05 00 00 00 80       	add    $0x80000000,%eax
}
801087b3:	c9                   	leave  
801087b4:	c3                   	ret    

801087b5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801087b5:	f3 0f 1e fb          	endbr32 
801087b9:	55                   	push   %ebp
801087ba:	89 e5                	mov    %esp,%ebp
801087bc:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801087bf:	8b 45 10             	mov    0x10(%ebp),%eax
801087c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801087c5:	eb 7f                	jmp    80108846 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801087c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801087ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801087d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087d5:	83 ec 08             	sub    $0x8,%esp
801087d8:	50                   	push   %eax
801087d9:	ff 75 08             	pushl  0x8(%ebp)
801087dc:	e8 7d ff ff ff       	call   8010875e <uva2ka>
801087e1:	83 c4 10             	add    $0x10,%esp
801087e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801087e7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801087eb:	75 07                	jne    801087f4 <copyout+0x3f>
      return -1;
801087ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087f2:	eb 61                	jmp    80108855 <copyout+0xa0>
    n = PGSIZE - (va - va0);
801087f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087f7:	2b 45 0c             	sub    0xc(%ebp),%eax
801087fa:	05 00 10 00 00       	add    $0x1000,%eax
801087ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108802:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108805:	3b 45 14             	cmp    0x14(%ebp),%eax
80108808:	76 06                	jbe    80108810 <copyout+0x5b>
      n = len;
8010880a:	8b 45 14             	mov    0x14(%ebp),%eax
8010880d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108810:	8b 45 0c             	mov    0xc(%ebp),%eax
80108813:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108816:	89 c2                	mov    %eax,%edx
80108818:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010881b:	01 d0                	add    %edx,%eax
8010881d:	83 ec 04             	sub    $0x4,%esp
80108820:	ff 75 f0             	pushl  -0x10(%ebp)
80108823:	ff 75 f4             	pushl  -0xc(%ebp)
80108826:	50                   	push   %eax
80108827:	e8 42 cd ff ff       	call   8010556e <memmove>
8010882c:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010882f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108832:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108835:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108838:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010883b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010883e:	05 00 10 00 00       	add    $0x1000,%eax
80108843:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108846:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010884a:	0f 85 77 ff ff ff    	jne    801087c7 <copyout+0x12>
  }
  return 0;
80108850:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108855:	c9                   	leave  
80108856:	c3                   	ret    

80108857 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108857:	f3 0f 1e fb          	endbr32 
8010885b:	55                   	push   %ebp
8010885c:	89 e5                	mov    %esp,%ebp
8010885e:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108861:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108868:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010886b:	8b 40 08             	mov    0x8(%eax),%eax
8010886e:	05 00 00 00 80       	add    $0x80000000,%eax
80108873:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80108876:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
8010887d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108880:	8b 40 24             	mov    0x24(%eax),%eax
80108883:	a3 5c 84 11 80       	mov    %eax,0x8011845c
  ncpu = 0;
80108888:	c7 05 c0 b1 11 80 00 	movl   $0x0,0x8011b1c0
8010888f:	00 00 00 

  while(i<madt->len){
80108892:	90                   	nop
80108893:	e9 be 00 00 00       	jmp    80108956 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
80108898:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010889b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010889e:	01 d0                	add    %edx,%eax
801088a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801088a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088a6:	0f b6 00             	movzbl (%eax),%eax
801088a9:	0f b6 c0             	movzbl %al,%eax
801088ac:	83 f8 05             	cmp    $0x5,%eax
801088af:	0f 87 a1 00 00 00    	ja     80108956 <mpinit_uefi+0xff>
801088b5:	8b 04 85 40 b4 10 80 	mov    -0x7fef4bc0(,%eax,4),%eax
801088bc:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801088bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801088c5:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
801088ca:	83 f8 03             	cmp    $0x3,%eax
801088cd:	7f 28                	jg     801088f7 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801088cf:	8b 15 c0 b1 11 80    	mov    0x8011b1c0,%edx
801088d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088d8:	0f b6 40 03          	movzbl 0x3(%eax),%eax
801088dc:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
801088e2:	81 c2 00 af 11 80    	add    $0x8011af00,%edx
801088e8:	88 02                	mov    %al,(%edx)
          ncpu++;
801088ea:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
801088ef:	83 c0 01             	add    $0x1,%eax
801088f2:	a3 c0 b1 11 80       	mov    %eax,0x8011b1c0
        }
        i += lapic_entry->record_len;
801088f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801088fa:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801088fe:	0f b6 c0             	movzbl %al,%eax
80108901:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108904:	eb 50                	jmp    80108956 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108906:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108909:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010890c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010890f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108913:	a2 e0 ae 11 80       	mov    %al,0x8011aee0
        i += ioapic->record_len;
80108918:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010891b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010891f:	0f b6 c0             	movzbl %al,%eax
80108922:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108925:	eb 2f                	jmp    80108956 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108927:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010892a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010892d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108930:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108934:	0f b6 c0             	movzbl %al,%eax
80108937:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010893a:	eb 1a                	jmp    80108956 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010893c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010893f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108942:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108945:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108949:	0f b6 c0             	movzbl %al,%eax
8010894c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010894f:	eb 05                	jmp    80108956 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
80108951:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108955:	90                   	nop
  while(i<madt->len){
80108956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108959:	8b 40 04             	mov    0x4(%eax),%eax
8010895c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010895f:	0f 82 33 ff ff ff    	jb     80108898 <mpinit_uefi+0x41>
    }
  }

}
80108965:	90                   	nop
80108966:	90                   	nop
80108967:	c9                   	leave  
80108968:	c3                   	ret    

80108969 <inb>:
{
80108969:	55                   	push   %ebp
8010896a:	89 e5                	mov    %esp,%ebp
8010896c:	83 ec 14             	sub    $0x14,%esp
8010896f:	8b 45 08             	mov    0x8(%ebp),%eax
80108972:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80108976:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010897a:	89 c2                	mov    %eax,%edx
8010897c:	ec                   	in     (%dx),%al
8010897d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80108980:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80108984:	c9                   	leave  
80108985:	c3                   	ret    

80108986 <outb>:
{
80108986:	55                   	push   %ebp
80108987:	89 e5                	mov    %esp,%ebp
80108989:	83 ec 08             	sub    $0x8,%esp
8010898c:	8b 45 08             	mov    0x8(%ebp),%eax
8010898f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108992:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80108996:	89 d0                	mov    %edx,%eax
80108998:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010899b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010899f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801089a3:	ee                   	out    %al,(%dx)
}
801089a4:	90                   	nop
801089a5:	c9                   	leave  
801089a6:	c3                   	ret    

801089a7 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801089a7:	f3 0f 1e fb          	endbr32 
801089ab:	55                   	push   %ebp
801089ac:	89 e5                	mov    %esp,%ebp
801089ae:	83 ec 28             	sub    $0x28,%esp
801089b1:	8b 45 08             	mov    0x8(%ebp),%eax
801089b4:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801089b7:	6a 00                	push   $0x0
801089b9:	68 fa 03 00 00       	push   $0x3fa
801089be:	e8 c3 ff ff ff       	call   80108986 <outb>
801089c3:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801089c6:	68 80 00 00 00       	push   $0x80
801089cb:	68 fb 03 00 00       	push   $0x3fb
801089d0:	e8 b1 ff ff ff       	call   80108986 <outb>
801089d5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801089d8:	6a 0c                	push   $0xc
801089da:	68 f8 03 00 00       	push   $0x3f8
801089df:	e8 a2 ff ff ff       	call   80108986 <outb>
801089e4:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801089e7:	6a 00                	push   $0x0
801089e9:	68 f9 03 00 00       	push   $0x3f9
801089ee:	e8 93 ff ff ff       	call   80108986 <outb>
801089f3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801089f6:	6a 03                	push   $0x3
801089f8:	68 fb 03 00 00       	push   $0x3fb
801089fd:	e8 84 ff ff ff       	call   80108986 <outb>
80108a02:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108a05:	6a 00                	push   $0x0
80108a07:	68 fc 03 00 00       	push   $0x3fc
80108a0c:	e8 75 ff ff ff       	call   80108986 <outb>
80108a11:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108a14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a1b:	eb 11                	jmp    80108a2e <uart_debug+0x87>
80108a1d:	83 ec 0c             	sub    $0xc,%esp
80108a20:	6a 0a                	push   $0xa
80108a22:	e8 15 a7 ff ff       	call   8010313c <microdelay>
80108a27:	83 c4 10             	add    $0x10,%esp
80108a2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a2e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108a32:	7f 1a                	jg     80108a4e <uart_debug+0xa7>
80108a34:	83 ec 0c             	sub    $0xc,%esp
80108a37:	68 fd 03 00 00       	push   $0x3fd
80108a3c:	e8 28 ff ff ff       	call   80108969 <inb>
80108a41:	83 c4 10             	add    $0x10,%esp
80108a44:	0f b6 c0             	movzbl %al,%eax
80108a47:	83 e0 20             	and    $0x20,%eax
80108a4a:	85 c0                	test   %eax,%eax
80108a4c:	74 cf                	je     80108a1d <uart_debug+0x76>
  outb(COM1+0, p);
80108a4e:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108a52:	0f b6 c0             	movzbl %al,%eax
80108a55:	83 ec 08             	sub    $0x8,%esp
80108a58:	50                   	push   %eax
80108a59:	68 f8 03 00 00       	push   $0x3f8
80108a5e:	e8 23 ff ff ff       	call   80108986 <outb>
80108a63:	83 c4 10             	add    $0x10,%esp
}
80108a66:	90                   	nop
80108a67:	c9                   	leave  
80108a68:	c3                   	ret    

80108a69 <uart_debugs>:

void uart_debugs(char *p){
80108a69:	f3 0f 1e fb          	endbr32 
80108a6d:	55                   	push   %ebp
80108a6e:	89 e5                	mov    %esp,%ebp
80108a70:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80108a73:	eb 1b                	jmp    80108a90 <uart_debugs+0x27>
    uart_debug(*p++);
80108a75:	8b 45 08             	mov    0x8(%ebp),%eax
80108a78:	8d 50 01             	lea    0x1(%eax),%edx
80108a7b:	89 55 08             	mov    %edx,0x8(%ebp)
80108a7e:	0f b6 00             	movzbl (%eax),%eax
80108a81:	0f be c0             	movsbl %al,%eax
80108a84:	83 ec 0c             	sub    $0xc,%esp
80108a87:	50                   	push   %eax
80108a88:	e8 1a ff ff ff       	call   801089a7 <uart_debug>
80108a8d:	83 c4 10             	add    $0x10,%esp
  while(*p){
80108a90:	8b 45 08             	mov    0x8(%ebp),%eax
80108a93:	0f b6 00             	movzbl (%eax),%eax
80108a96:	84 c0                	test   %al,%al
80108a98:	75 db                	jne    80108a75 <uart_debugs+0xc>
  }
}
80108a9a:	90                   	nop
80108a9b:	90                   	nop
80108a9c:	c9                   	leave  
80108a9d:	c3                   	ret    

80108a9e <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80108a9e:	f3 0f 1e fb          	endbr32 
80108aa2:	55                   	push   %ebp
80108aa3:	89 e5                	mov    %esp,%ebp
80108aa5:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108aa8:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80108aaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108ab2:	8b 50 14             	mov    0x14(%eax),%edx
80108ab5:	8b 40 10             	mov    0x10(%eax),%eax
80108ab8:	a3 c4 b1 11 80       	mov    %eax,0x8011b1c4
  gpu.vram_size = boot_param->graphic_config.frame_size;
80108abd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108ac0:	8b 50 1c             	mov    0x1c(%eax),%edx
80108ac3:	8b 40 18             	mov    0x18(%eax),%eax
80108ac6:	a3 cc b1 11 80       	mov    %eax,0x8011b1cc
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80108acb:	a1 cc b1 11 80       	mov    0x8011b1cc,%eax
80108ad0:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108ad5:	29 c2                	sub    %eax,%edx
80108ad7:	89 d0                	mov    %edx,%eax
80108ad9:	a3 c8 b1 11 80       	mov    %eax,0x8011b1c8
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80108ade:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108ae1:	8b 50 24             	mov    0x24(%eax),%edx
80108ae4:	8b 40 20             	mov    0x20(%eax),%eax
80108ae7:	a3 d0 b1 11 80       	mov    %eax,0x8011b1d0
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80108aec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108aef:	8b 50 2c             	mov    0x2c(%eax),%edx
80108af2:	8b 40 28             	mov    0x28(%eax),%eax
80108af5:	a3 d4 b1 11 80       	mov    %eax,0x8011b1d4
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108afa:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108afd:	8b 50 34             	mov    0x34(%eax),%edx
80108b00:	8b 40 30             	mov    0x30(%eax),%eax
80108b03:	a3 d8 b1 11 80       	mov    %eax,0x8011b1d8
}
80108b08:	90                   	nop
80108b09:	c9                   	leave  
80108b0a:	c3                   	ret    

80108b0b <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80108b0b:	f3 0f 1e fb          	endbr32 
80108b0f:	55                   	push   %ebp
80108b10:	89 e5                	mov    %esp,%ebp
80108b12:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108b15:	8b 15 d8 b1 11 80    	mov    0x8011b1d8,%edx
80108b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b1e:	0f af d0             	imul   %eax,%edx
80108b21:	8b 45 08             	mov    0x8(%ebp),%eax
80108b24:	01 d0                	add    %edx,%eax
80108b26:	c1 e0 02             	shl    $0x2,%eax
80108b29:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108b2c:	8b 15 c8 b1 11 80    	mov    0x8011b1c8,%edx
80108b32:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108b35:	01 d0                	add    %edx,%eax
80108b37:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108b3a:	8b 45 10             	mov    0x10(%ebp),%eax
80108b3d:	0f b6 10             	movzbl (%eax),%edx
80108b40:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108b43:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108b45:	8b 45 10             	mov    0x10(%ebp),%eax
80108b48:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108b4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108b4f:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108b52:	8b 45 10             	mov    0x10(%ebp),%eax
80108b55:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108b59:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108b5c:	88 50 02             	mov    %dl,0x2(%eax)
}
80108b5f:	90                   	nop
80108b60:	c9                   	leave  
80108b61:	c3                   	ret    

80108b62 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108b62:	f3 0f 1e fb          	endbr32 
80108b66:	55                   	push   %ebp
80108b67:	89 e5                	mov    %esp,%ebp
80108b69:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80108b6c:	8b 15 d8 b1 11 80    	mov    0x8011b1d8,%edx
80108b72:	8b 45 08             	mov    0x8(%ebp),%eax
80108b75:	0f af c2             	imul   %edx,%eax
80108b78:	c1 e0 02             	shl    $0x2,%eax
80108b7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80108b7e:	8b 15 cc b1 11 80    	mov    0x8011b1cc,%edx
80108b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b87:	29 c2                	sub    %eax,%edx
80108b89:	89 d0                	mov    %edx,%eax
80108b8b:	8b 0d c8 b1 11 80    	mov    0x8011b1c8,%ecx
80108b91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b94:	01 ca                	add    %ecx,%edx
80108b96:	89 d1                	mov    %edx,%ecx
80108b98:	8b 15 c8 b1 11 80    	mov    0x8011b1c8,%edx
80108b9e:	83 ec 04             	sub    $0x4,%esp
80108ba1:	50                   	push   %eax
80108ba2:	51                   	push   %ecx
80108ba3:	52                   	push   %edx
80108ba4:	e8 c5 c9 ff ff       	call   8010556e <memmove>
80108ba9:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80108bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108baf:	8b 0d c8 b1 11 80    	mov    0x8011b1c8,%ecx
80108bb5:	8b 15 cc b1 11 80    	mov    0x8011b1cc,%edx
80108bbb:	01 d1                	add    %edx,%ecx
80108bbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108bc0:	29 d1                	sub    %edx,%ecx
80108bc2:	89 ca                	mov    %ecx,%edx
80108bc4:	83 ec 04             	sub    $0x4,%esp
80108bc7:	50                   	push   %eax
80108bc8:	6a 00                	push   $0x0
80108bca:	52                   	push   %edx
80108bcb:	e8 d7 c8 ff ff       	call   801054a7 <memset>
80108bd0:	83 c4 10             	add    $0x10,%esp
}
80108bd3:	90                   	nop
80108bd4:	c9                   	leave  
80108bd5:	c3                   	ret    

80108bd6 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108bd6:	f3 0f 1e fb          	endbr32 
80108bda:	55                   	push   %ebp
80108bdb:	89 e5                	mov    %esp,%ebp
80108bdd:	53                   	push   %ebx
80108bde:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108be1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108be8:	e9 b1 00 00 00       	jmp    80108c9e <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108bed:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108bf4:	e9 97 00 00 00       	jmp    80108c90 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108bf9:	8b 45 10             	mov    0x10(%ebp),%eax
80108bfc:	83 e8 20             	sub    $0x20,%eax
80108bff:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c05:	01 d0                	add    %edx,%eax
80108c07:	0f b7 84 00 60 b4 10 	movzwl -0x7fef4ba0(%eax,%eax,1),%eax
80108c0e:	80 
80108c0f:	0f b7 d0             	movzwl %ax,%edx
80108c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c15:	bb 01 00 00 00       	mov    $0x1,%ebx
80108c1a:	89 c1                	mov    %eax,%ecx
80108c1c:	d3 e3                	shl    %cl,%ebx
80108c1e:	89 d8                	mov    %ebx,%eax
80108c20:	21 d0                	and    %edx,%eax
80108c22:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c28:	ba 01 00 00 00       	mov    $0x1,%edx
80108c2d:	89 c1                	mov    %eax,%ecx
80108c2f:	d3 e2                	shl    %cl,%edx
80108c31:	89 d0                	mov    %edx,%eax
80108c33:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108c36:	75 2b                	jne    80108c63 <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108c38:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3e:	01 c2                	add    %eax,%edx
80108c40:	b8 0e 00 00 00       	mov    $0xe,%eax
80108c45:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108c48:	89 c1                	mov    %eax,%ecx
80108c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80108c4d:	01 c8                	add    %ecx,%eax
80108c4f:	83 ec 04             	sub    $0x4,%esp
80108c52:	68 00 f5 10 80       	push   $0x8010f500
80108c57:	52                   	push   %edx
80108c58:	50                   	push   %eax
80108c59:	e8 ad fe ff ff       	call   80108b0b <graphic_draw_pixel>
80108c5e:	83 c4 10             	add    $0x10,%esp
80108c61:	eb 29                	jmp    80108c8c <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108c63:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c69:	01 c2                	add    %eax,%edx
80108c6b:	b8 0e 00 00 00       	mov    $0xe,%eax
80108c70:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108c73:	89 c1                	mov    %eax,%ecx
80108c75:	8b 45 08             	mov    0x8(%ebp),%eax
80108c78:	01 c8                	add    %ecx,%eax
80108c7a:	83 ec 04             	sub    $0x4,%esp
80108c7d:	68 a8 00 11 80       	push   $0x801100a8
80108c82:	52                   	push   %edx
80108c83:	50                   	push   %eax
80108c84:	e8 82 fe ff ff       	call   80108b0b <graphic_draw_pixel>
80108c89:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108c8c:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108c90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c94:	0f 89 5f ff ff ff    	jns    80108bf9 <font_render+0x23>
  for(int i=0;i<30;i++){
80108c9a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108c9e:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108ca2:	0f 8e 45 ff ff ff    	jle    80108bed <font_render+0x17>
      }
    }
  }
}
80108ca8:	90                   	nop
80108ca9:	90                   	nop
80108caa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108cad:	c9                   	leave  
80108cae:	c3                   	ret    

80108caf <font_render_string>:

void font_render_string(char *string,int row){
80108caf:	f3 0f 1e fb          	endbr32 
80108cb3:	55                   	push   %ebp
80108cb4:	89 e5                	mov    %esp,%ebp
80108cb6:	53                   	push   %ebx
80108cb7:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108cba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108cc1:	eb 33                	jmp    80108cf6 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108cc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80108cc9:	01 d0                	add    %edx,%eax
80108ccb:	0f b6 00             	movzbl (%eax),%eax
80108cce:	0f be d8             	movsbl %al,%ebx
80108cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cd4:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108cd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108cda:	89 d0                	mov    %edx,%eax
80108cdc:	c1 e0 04             	shl    $0x4,%eax
80108cdf:	29 d0                	sub    %edx,%eax
80108ce1:	83 c0 02             	add    $0x2,%eax
80108ce4:	83 ec 04             	sub    $0x4,%esp
80108ce7:	53                   	push   %ebx
80108ce8:	51                   	push   %ecx
80108ce9:	50                   	push   %eax
80108cea:	e8 e7 fe ff ff       	call   80108bd6 <font_render>
80108cef:	83 c4 10             	add    $0x10,%esp
    i++;
80108cf2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108cf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108cf9:	8b 45 08             	mov    0x8(%ebp),%eax
80108cfc:	01 d0                	add    %edx,%eax
80108cfe:	0f b6 00             	movzbl (%eax),%eax
80108d01:	84 c0                	test   %al,%al
80108d03:	74 06                	je     80108d0b <font_render_string+0x5c>
80108d05:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108d09:	7e b8                	jle    80108cc3 <font_render_string+0x14>
  }
}
80108d0b:	90                   	nop
80108d0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d0f:	c9                   	leave  
80108d10:	c3                   	ret    

80108d11 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108d11:	f3 0f 1e fb          	endbr32 
80108d15:	55                   	push   %ebp
80108d16:	89 e5                	mov    %esp,%ebp
80108d18:	53                   	push   %ebx
80108d19:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108d1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d23:	eb 6b                	jmp    80108d90 <pci_init+0x7f>
    for(int j=0;j<32;j++){
80108d25:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108d2c:	eb 58                	jmp    80108d86 <pci_init+0x75>
      for(int k=0;k<8;k++){
80108d2e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108d35:	eb 45                	jmp    80108d7c <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108d37:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108d3a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d40:	83 ec 0c             	sub    $0xc,%esp
80108d43:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108d46:	53                   	push   %ebx
80108d47:	6a 00                	push   $0x0
80108d49:	51                   	push   %ecx
80108d4a:	52                   	push   %edx
80108d4b:	50                   	push   %eax
80108d4c:	e8 c0 00 00 00       	call   80108e11 <pci_access_config>
80108d51:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108d54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d57:	0f b7 c0             	movzwl %ax,%eax
80108d5a:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108d5f:	74 17                	je     80108d78 <pci_init+0x67>
        pci_init_device(i,j,k);
80108d61:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108d64:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d6a:	83 ec 04             	sub    $0x4,%esp
80108d6d:	51                   	push   %ecx
80108d6e:	52                   	push   %edx
80108d6f:	50                   	push   %eax
80108d70:	e8 4f 01 00 00       	call   80108ec4 <pci_init_device>
80108d75:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108d78:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108d7c:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108d80:	7e b5                	jle    80108d37 <pci_init+0x26>
    for(int j=0;j<32;j++){
80108d82:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108d86:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108d8a:	7e a2                	jle    80108d2e <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108d8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108d90:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108d97:	7e 8c                	jle    80108d25 <pci_init+0x14>
      }
      }
    }
  }
}
80108d99:	90                   	nop
80108d9a:	90                   	nop
80108d9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d9e:	c9                   	leave  
80108d9f:	c3                   	ret    

80108da0 <pci_write_config>:

void pci_write_config(uint config){
80108da0:	f3 0f 1e fb          	endbr32 
80108da4:	55                   	push   %ebp
80108da5:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108da7:	8b 45 08             	mov    0x8(%ebp),%eax
80108daa:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108daf:	89 c0                	mov    %eax,%eax
80108db1:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108db2:	90                   	nop
80108db3:	5d                   	pop    %ebp
80108db4:	c3                   	ret    

80108db5 <pci_write_data>:

void pci_write_data(uint config){
80108db5:	f3 0f 1e fb          	endbr32 
80108db9:	55                   	push   %ebp
80108dba:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80108dbf:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108dc4:	89 c0                	mov    %eax,%eax
80108dc6:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108dc7:	90                   	nop
80108dc8:	5d                   	pop    %ebp
80108dc9:	c3                   	ret    

80108dca <pci_read_config>:
uint pci_read_config(){
80108dca:	f3 0f 1e fb          	endbr32 
80108dce:	55                   	push   %ebp
80108dcf:	89 e5                	mov    %esp,%ebp
80108dd1:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108dd4:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108dd9:	ed                   	in     (%dx),%eax
80108dda:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108ddd:	83 ec 0c             	sub    $0xc,%esp
80108de0:	68 c8 00 00 00       	push   $0xc8
80108de5:	e8 52 a3 ff ff       	call   8010313c <microdelay>
80108dea:	83 c4 10             	add    $0x10,%esp
  return data;
80108ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108df0:	c9                   	leave  
80108df1:	c3                   	ret    

80108df2 <pci_test>:


void pci_test(){
80108df2:	f3 0f 1e fb          	endbr32 
80108df6:	55                   	push   %ebp
80108df7:	89 e5                	mov    %esp,%ebp
80108df9:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108dfc:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108e03:	ff 75 fc             	pushl  -0x4(%ebp)
80108e06:	e8 95 ff ff ff       	call   80108da0 <pci_write_config>
80108e0b:	83 c4 04             	add    $0x4,%esp
}
80108e0e:	90                   	nop
80108e0f:	c9                   	leave  
80108e10:	c3                   	ret    

80108e11 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108e11:	f3 0f 1e fb          	endbr32 
80108e15:	55                   	push   %ebp
80108e16:	89 e5                	mov    %esp,%ebp
80108e18:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108e1b:	8b 45 08             	mov    0x8(%ebp),%eax
80108e1e:	c1 e0 10             	shl    $0x10,%eax
80108e21:	25 00 00 ff 00       	and    $0xff0000,%eax
80108e26:	89 c2                	mov    %eax,%edx
80108e28:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e2b:	c1 e0 0b             	shl    $0xb,%eax
80108e2e:	0f b7 c0             	movzwl %ax,%eax
80108e31:	09 c2                	or     %eax,%edx
80108e33:	8b 45 10             	mov    0x10(%ebp),%eax
80108e36:	c1 e0 08             	shl    $0x8,%eax
80108e39:	25 00 07 00 00       	and    $0x700,%eax
80108e3e:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108e40:	8b 45 14             	mov    0x14(%ebp),%eax
80108e43:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108e48:	09 d0                	or     %edx,%eax
80108e4a:	0d 00 00 00 80       	or     $0x80000000,%eax
80108e4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108e52:	ff 75 f4             	pushl  -0xc(%ebp)
80108e55:	e8 46 ff ff ff       	call   80108da0 <pci_write_config>
80108e5a:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108e5d:	e8 68 ff ff ff       	call   80108dca <pci_read_config>
80108e62:	8b 55 18             	mov    0x18(%ebp),%edx
80108e65:	89 02                	mov    %eax,(%edx)
}
80108e67:	90                   	nop
80108e68:	c9                   	leave  
80108e69:	c3                   	ret    

80108e6a <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108e6a:	f3 0f 1e fb          	endbr32 
80108e6e:	55                   	push   %ebp
80108e6f:	89 e5                	mov    %esp,%ebp
80108e71:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108e74:	8b 45 08             	mov    0x8(%ebp),%eax
80108e77:	c1 e0 10             	shl    $0x10,%eax
80108e7a:	25 00 00 ff 00       	and    $0xff0000,%eax
80108e7f:	89 c2                	mov    %eax,%edx
80108e81:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e84:	c1 e0 0b             	shl    $0xb,%eax
80108e87:	0f b7 c0             	movzwl %ax,%eax
80108e8a:	09 c2                	or     %eax,%edx
80108e8c:	8b 45 10             	mov    0x10(%ebp),%eax
80108e8f:	c1 e0 08             	shl    $0x8,%eax
80108e92:	25 00 07 00 00       	and    $0x700,%eax
80108e97:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108e99:	8b 45 14             	mov    0x14(%ebp),%eax
80108e9c:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108ea1:	09 d0                	or     %edx,%eax
80108ea3:	0d 00 00 00 80       	or     $0x80000000,%eax
80108ea8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108eab:	ff 75 fc             	pushl  -0x4(%ebp)
80108eae:	e8 ed fe ff ff       	call   80108da0 <pci_write_config>
80108eb3:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108eb6:	ff 75 18             	pushl  0x18(%ebp)
80108eb9:	e8 f7 fe ff ff       	call   80108db5 <pci_write_data>
80108ebe:	83 c4 04             	add    $0x4,%esp
}
80108ec1:	90                   	nop
80108ec2:	c9                   	leave  
80108ec3:	c3                   	ret    

80108ec4 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108ec4:	f3 0f 1e fb          	endbr32 
80108ec8:	55                   	push   %ebp
80108ec9:	89 e5                	mov    %esp,%ebp
80108ecb:	53                   	push   %ebx
80108ecc:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80108ed2:	a2 dc b1 11 80       	mov    %al,0x8011b1dc
  dev.device_num = device_num;
80108ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eda:	a2 dd b1 11 80       	mov    %al,0x8011b1dd
  dev.function_num = function_num;
80108edf:	8b 45 10             	mov    0x10(%ebp),%eax
80108ee2:	a2 de b1 11 80       	mov    %al,0x8011b1de
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108ee7:	ff 75 10             	pushl  0x10(%ebp)
80108eea:	ff 75 0c             	pushl  0xc(%ebp)
80108eed:	ff 75 08             	pushl  0x8(%ebp)
80108ef0:	68 a4 ca 10 80       	push   $0x8010caa4
80108ef5:	e8 12 75 ff ff       	call   8010040c <cprintf>
80108efa:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108efd:	83 ec 0c             	sub    $0xc,%esp
80108f00:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108f03:	50                   	push   %eax
80108f04:	6a 00                	push   $0x0
80108f06:	ff 75 10             	pushl  0x10(%ebp)
80108f09:	ff 75 0c             	pushl  0xc(%ebp)
80108f0c:	ff 75 08             	pushl  0x8(%ebp)
80108f0f:	e8 fd fe ff ff       	call   80108e11 <pci_access_config>
80108f14:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108f17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f1a:	c1 e8 10             	shr    $0x10,%eax
80108f1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f23:	25 ff ff 00 00       	and    $0xffff,%eax
80108f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f2e:	a3 e0 b1 11 80       	mov    %eax,0x8011b1e0
  dev.vendor_id = vendor_id;
80108f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f36:	a3 e4 b1 11 80       	mov    %eax,0x8011b1e4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108f3b:	83 ec 04             	sub    $0x4,%esp
80108f3e:	ff 75 f0             	pushl  -0x10(%ebp)
80108f41:	ff 75 f4             	pushl  -0xc(%ebp)
80108f44:	68 d8 ca 10 80       	push   $0x8010cad8
80108f49:	e8 be 74 ff ff       	call   8010040c <cprintf>
80108f4e:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108f51:	83 ec 0c             	sub    $0xc,%esp
80108f54:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108f57:	50                   	push   %eax
80108f58:	6a 08                	push   $0x8
80108f5a:	ff 75 10             	pushl  0x10(%ebp)
80108f5d:	ff 75 0c             	pushl  0xc(%ebp)
80108f60:	ff 75 08             	pushl  0x8(%ebp)
80108f63:	e8 a9 fe ff ff       	call   80108e11 <pci_access_config>
80108f68:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108f6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f6e:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108f71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f74:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108f77:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108f7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f7d:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108f80:	0f b6 c0             	movzbl %al,%eax
80108f83:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108f86:	c1 eb 18             	shr    $0x18,%ebx
80108f89:	83 ec 0c             	sub    $0xc,%esp
80108f8c:	51                   	push   %ecx
80108f8d:	52                   	push   %edx
80108f8e:	50                   	push   %eax
80108f8f:	53                   	push   %ebx
80108f90:	68 fc ca 10 80       	push   $0x8010cafc
80108f95:	e8 72 74 ff ff       	call   8010040c <cprintf>
80108f9a:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fa0:	c1 e8 18             	shr    $0x18,%eax
80108fa3:	a2 e8 b1 11 80       	mov    %al,0x8011b1e8
  dev.sub_class = (data>>16)&0xFF;
80108fa8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fab:	c1 e8 10             	shr    $0x10,%eax
80108fae:	a2 e9 b1 11 80       	mov    %al,0x8011b1e9
  dev.interface = (data>>8)&0xFF;
80108fb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fb6:	c1 e8 08             	shr    $0x8,%eax
80108fb9:	a2 ea b1 11 80       	mov    %al,0x8011b1ea
  dev.revision_id = data&0xFF;
80108fbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fc1:	a2 eb b1 11 80       	mov    %al,0x8011b1eb
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108fc6:	83 ec 0c             	sub    $0xc,%esp
80108fc9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108fcc:	50                   	push   %eax
80108fcd:	6a 10                	push   $0x10
80108fcf:	ff 75 10             	pushl  0x10(%ebp)
80108fd2:	ff 75 0c             	pushl  0xc(%ebp)
80108fd5:	ff 75 08             	pushl  0x8(%ebp)
80108fd8:	e8 34 fe ff ff       	call   80108e11 <pci_access_config>
80108fdd:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108fe0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fe3:	a3 ec b1 11 80       	mov    %eax,0x8011b1ec
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108fe8:	83 ec 0c             	sub    $0xc,%esp
80108feb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108fee:	50                   	push   %eax
80108fef:	6a 14                	push   $0x14
80108ff1:	ff 75 10             	pushl  0x10(%ebp)
80108ff4:	ff 75 0c             	pushl  0xc(%ebp)
80108ff7:	ff 75 08             	pushl  0x8(%ebp)
80108ffa:	e8 12 fe ff ff       	call   80108e11 <pci_access_config>
80108fff:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80109002:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109005:	a3 f0 b1 11 80       	mov    %eax,0x8011b1f0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
8010900a:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80109011:	75 5a                	jne    8010906d <pci_init_device+0x1a9>
80109013:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
8010901a:	75 51                	jne    8010906d <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
8010901c:	83 ec 0c             	sub    $0xc,%esp
8010901f:	68 41 cb 10 80       	push   $0x8010cb41
80109024:	e8 e3 73 ff ff       	call   8010040c <cprintf>
80109029:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
8010902c:	83 ec 0c             	sub    $0xc,%esp
8010902f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109032:	50                   	push   %eax
80109033:	68 f0 00 00 00       	push   $0xf0
80109038:	ff 75 10             	pushl  0x10(%ebp)
8010903b:	ff 75 0c             	pushl  0xc(%ebp)
8010903e:	ff 75 08             	pushl  0x8(%ebp)
80109041:	e8 cb fd ff ff       	call   80108e11 <pci_access_config>
80109046:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80109049:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010904c:	83 ec 08             	sub    $0x8,%esp
8010904f:	50                   	push   %eax
80109050:	68 5b cb 10 80       	push   $0x8010cb5b
80109055:	e8 b2 73 ff ff       	call   8010040c <cprintf>
8010905a:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010905d:	83 ec 0c             	sub    $0xc,%esp
80109060:	68 dc b1 11 80       	push   $0x8011b1dc
80109065:	e8 09 00 00 00       	call   80109073 <i8254_init>
8010906a:	83 c4 10             	add    $0x10,%esp
  }
}
8010906d:	90                   	nop
8010906e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109071:	c9                   	leave  
80109072:	c3                   	ret    

80109073 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80109073:	f3 0f 1e fb          	endbr32 
80109077:	55                   	push   %ebp
80109078:	89 e5                	mov    %esp,%ebp
8010907a:	53                   	push   %ebx
8010907b:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
8010907e:	8b 45 08             	mov    0x8(%ebp),%eax
80109081:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80109085:	0f b6 c8             	movzbl %al,%ecx
80109088:	8b 45 08             	mov    0x8(%ebp),%eax
8010908b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010908f:	0f b6 d0             	movzbl %al,%edx
80109092:	8b 45 08             	mov    0x8(%ebp),%eax
80109095:	0f b6 00             	movzbl (%eax),%eax
80109098:	0f b6 c0             	movzbl %al,%eax
8010909b:	83 ec 0c             	sub    $0xc,%esp
8010909e:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801090a1:	53                   	push   %ebx
801090a2:	6a 04                	push   $0x4
801090a4:	51                   	push   %ecx
801090a5:	52                   	push   %edx
801090a6:	50                   	push   %eax
801090a7:	e8 65 fd ff ff       	call   80108e11 <pci_access_config>
801090ac:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801090af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090b2:	83 c8 04             	or     $0x4,%eax
801090b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801090b8:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801090bb:	8b 45 08             	mov    0x8(%ebp),%eax
801090be:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801090c2:	0f b6 c8             	movzbl %al,%ecx
801090c5:	8b 45 08             	mov    0x8(%ebp),%eax
801090c8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801090cc:	0f b6 d0             	movzbl %al,%edx
801090cf:	8b 45 08             	mov    0x8(%ebp),%eax
801090d2:	0f b6 00             	movzbl (%eax),%eax
801090d5:	0f b6 c0             	movzbl %al,%eax
801090d8:	83 ec 0c             	sub    $0xc,%esp
801090db:	53                   	push   %ebx
801090dc:	6a 04                	push   $0x4
801090de:	51                   	push   %ecx
801090df:	52                   	push   %edx
801090e0:	50                   	push   %eax
801090e1:	e8 84 fd ff ff       	call   80108e6a <pci_write_config_register>
801090e6:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801090e9:	8b 45 08             	mov    0x8(%ebp),%eax
801090ec:	8b 40 10             	mov    0x10(%eax),%eax
801090ef:	05 00 00 00 40       	add    $0x40000000,%eax
801090f4:	a3 f4 b1 11 80       	mov    %eax,0x8011b1f4
  uint *ctrl = (uint *)base_addr;
801090f9:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801090fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80109101:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109106:	05 d8 00 00 00       	add    $0xd8,%eax
8010910b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
8010910e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109111:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80109117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010911a:	8b 00                	mov    (%eax),%eax
8010911c:	0d 00 00 00 04       	or     $0x4000000,%eax
80109121:	89 c2                	mov    %eax,%edx
80109123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109126:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80109128:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010912b:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80109131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109134:	8b 00                	mov    (%eax),%eax
80109136:	83 c8 40             	or     $0x40,%eax
80109139:	89 c2                	mov    %eax,%edx
8010913b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010913e:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80109140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109143:	8b 10                	mov    (%eax),%edx
80109145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109148:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
8010914a:	83 ec 0c             	sub    $0xc,%esp
8010914d:	68 70 cb 10 80       	push   $0x8010cb70
80109152:	e8 b5 72 ff ff       	call   8010040c <cprintf>
80109157:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
8010915a:	e8 2b 9c ff ff       	call   80102d8a <kalloc>
8010915f:	a3 f8 b1 11 80       	mov    %eax,0x8011b1f8
  *intr_addr = 0;
80109164:	a1 f8 b1 11 80       	mov    0x8011b1f8,%eax
80109169:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
8010916f:	a1 f8 b1 11 80       	mov    0x8011b1f8,%eax
80109174:	83 ec 08             	sub    $0x8,%esp
80109177:	50                   	push   %eax
80109178:	68 92 cb 10 80       	push   $0x8010cb92
8010917d:	e8 8a 72 ff ff       	call   8010040c <cprintf>
80109182:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80109185:	e8 50 00 00 00       	call   801091da <i8254_init_recv>
  i8254_init_send();
8010918a:	e8 6d 03 00 00       	call   801094fc <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
8010918f:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80109196:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80109199:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801091a0:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801091a3:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801091aa:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801091ad:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801091b4:	0f b6 c0             	movzbl %al,%eax
801091b7:	83 ec 0c             	sub    $0xc,%esp
801091ba:	53                   	push   %ebx
801091bb:	51                   	push   %ecx
801091bc:	52                   	push   %edx
801091bd:	50                   	push   %eax
801091be:	68 a0 cb 10 80       	push   $0x8010cba0
801091c3:	e8 44 72 ff ff       	call   8010040c <cprintf>
801091c8:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801091cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801091d4:	90                   	nop
801091d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801091d8:	c9                   	leave  
801091d9:	c3                   	ret    

801091da <i8254_init_recv>:

void i8254_init_recv(){
801091da:	f3 0f 1e fb          	endbr32 
801091de:	55                   	push   %ebp
801091df:	89 e5                	mov    %esp,%ebp
801091e1:	57                   	push   %edi
801091e2:	56                   	push   %esi
801091e3:	53                   	push   %ebx
801091e4:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801091e7:	83 ec 0c             	sub    $0xc,%esp
801091ea:	6a 00                	push   $0x0
801091ec:	e8 ec 04 00 00       	call   801096dd <i8254_read_eeprom>
801091f1:	83 c4 10             	add    $0x10,%esp
801091f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801091f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801091fa:	a2 ac 00 11 80       	mov    %al,0x801100ac
  mac_addr[1] = data_l>>8;
801091ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109202:	c1 e8 08             	shr    $0x8,%eax
80109205:	a2 ad 00 11 80       	mov    %al,0x801100ad
  uint data_m = i8254_read_eeprom(0x1);
8010920a:	83 ec 0c             	sub    $0xc,%esp
8010920d:	6a 01                	push   $0x1
8010920f:	e8 c9 04 00 00       	call   801096dd <i8254_read_eeprom>
80109214:	83 c4 10             	add    $0x10,%esp
80109217:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
8010921a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010921d:	a2 ae 00 11 80       	mov    %al,0x801100ae
  mac_addr[3] = data_m>>8;
80109222:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109225:	c1 e8 08             	shr    $0x8,%eax
80109228:	a2 af 00 11 80       	mov    %al,0x801100af
  uint data_h = i8254_read_eeprom(0x2);
8010922d:	83 ec 0c             	sub    $0xc,%esp
80109230:	6a 02                	push   $0x2
80109232:	e8 a6 04 00 00       	call   801096dd <i8254_read_eeprom>
80109237:	83 c4 10             	add    $0x10,%esp
8010923a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010923d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109240:	a2 b0 00 11 80       	mov    %al,0x801100b0
  mac_addr[5] = data_h>>8;
80109245:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109248:	c1 e8 08             	shr    $0x8,%eax
8010924b:	a2 b1 00 11 80       	mov    %al,0x801100b1
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80109250:	0f b6 05 b1 00 11 80 	movzbl 0x801100b1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109257:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
8010925a:	0f b6 05 b0 00 11 80 	movzbl 0x801100b0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109261:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80109264:	0f b6 05 af 00 11 80 	movzbl 0x801100af,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010926b:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010926e:	0f b6 05 ae 00 11 80 	movzbl 0x801100ae,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109275:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80109278:	0f b6 05 ad 00 11 80 	movzbl 0x801100ad,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010927f:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80109282:	0f b6 05 ac 00 11 80 	movzbl 0x801100ac,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109289:	0f b6 c0             	movzbl %al,%eax
8010928c:	83 ec 04             	sub    $0x4,%esp
8010928f:	57                   	push   %edi
80109290:	56                   	push   %esi
80109291:	53                   	push   %ebx
80109292:	51                   	push   %ecx
80109293:	52                   	push   %edx
80109294:	50                   	push   %eax
80109295:	68 b8 cb 10 80       	push   $0x8010cbb8
8010929a:	e8 6d 71 ff ff       	call   8010040c <cprintf>
8010929f:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801092a2:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801092a7:	05 00 54 00 00       	add    $0x5400,%eax
801092ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
801092af:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801092b4:	05 04 54 00 00       	add    $0x5404,%eax
801092b9:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
801092bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801092bf:	c1 e0 10             	shl    $0x10,%eax
801092c2:	0b 45 d8             	or     -0x28(%ebp),%eax
801092c5:	89 c2                	mov    %eax,%edx
801092c7:	8b 45 cc             	mov    -0x34(%ebp),%eax
801092ca:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801092cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
801092cf:	0d 00 00 00 80       	or     $0x80000000,%eax
801092d4:	89 c2                	mov    %eax,%edx
801092d6:	8b 45 c8             	mov    -0x38(%ebp),%eax
801092d9:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801092db:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801092e0:	05 00 52 00 00       	add    $0x5200,%eax
801092e5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801092e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801092ef:	eb 19                	jmp    8010930a <i8254_init_recv+0x130>
    mta[i] = 0;
801092f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801092f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092fb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801092fe:	01 d0                	add    %edx,%eax
80109300:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80109306:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010930a:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
8010930e:	7e e1                	jle    801092f1 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80109310:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109315:	05 d0 00 00 00       	add    $0xd0,%eax
8010931a:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010931d:	8b 45 c0             	mov    -0x40(%ebp),%eax
80109320:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80109326:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010932b:	05 c8 00 00 00       	add    $0xc8,%eax
80109330:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80109333:	8b 45 bc             	mov    -0x44(%ebp),%eax
80109336:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
8010933c:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109341:	05 28 28 00 00       	add    $0x2828,%eax
80109346:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80109349:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010934c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80109352:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109357:	05 00 01 00 00       	add    $0x100,%eax
8010935c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010935f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109362:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80109368:	e8 1d 9a ff ff       	call   80102d8a <kalloc>
8010936d:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109370:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109375:	05 00 28 00 00       	add    $0x2800,%eax
8010937a:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010937d:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109382:	05 04 28 00 00       	add    $0x2804,%eax
80109387:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010938a:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010938f:	05 08 28 00 00       	add    $0x2808,%eax
80109394:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80109397:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010939c:	05 10 28 00 00       	add    $0x2810,%eax
801093a1:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801093a4:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801093a9:	05 18 28 00 00       	add    $0x2818,%eax
801093ae:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801093b1:	8b 45 b0             	mov    -0x50(%ebp),%eax
801093b4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801093ba:	8b 45 ac             	mov    -0x54(%ebp),%eax
801093bd:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801093bf:	8b 45 a8             	mov    -0x58(%ebp),%eax
801093c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801093c8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801093cb:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801093d1:	8b 45 a0             	mov    -0x60(%ebp),%eax
801093d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801093da:	8b 45 9c             	mov    -0x64(%ebp),%eax
801093dd:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801093e3:	8b 45 b0             	mov    -0x50(%ebp),%eax
801093e6:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801093e9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801093f0:	eb 73                	jmp    80109465 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
801093f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801093f5:	c1 e0 04             	shl    $0x4,%eax
801093f8:	89 c2                	mov    %eax,%edx
801093fa:	8b 45 98             	mov    -0x68(%ebp),%eax
801093fd:	01 d0                	add    %edx,%eax
801093ff:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80109406:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109409:	c1 e0 04             	shl    $0x4,%eax
8010940c:	89 c2                	mov    %eax,%edx
8010940e:	8b 45 98             	mov    -0x68(%ebp),%eax
80109411:	01 d0                	add    %edx,%eax
80109413:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80109419:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010941c:	c1 e0 04             	shl    $0x4,%eax
8010941f:	89 c2                	mov    %eax,%edx
80109421:	8b 45 98             	mov    -0x68(%ebp),%eax
80109424:	01 d0                	add    %edx,%eax
80109426:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
8010942c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010942f:	c1 e0 04             	shl    $0x4,%eax
80109432:	89 c2                	mov    %eax,%edx
80109434:	8b 45 98             	mov    -0x68(%ebp),%eax
80109437:	01 d0                	add    %edx,%eax
80109439:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
8010943d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109440:	c1 e0 04             	shl    $0x4,%eax
80109443:	89 c2                	mov    %eax,%edx
80109445:	8b 45 98             	mov    -0x68(%ebp),%eax
80109448:	01 d0                	add    %edx,%eax
8010944a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
8010944e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109451:	c1 e0 04             	shl    $0x4,%eax
80109454:	89 c2                	mov    %eax,%edx
80109456:	8b 45 98             	mov    -0x68(%ebp),%eax
80109459:	01 d0                	add    %edx,%eax
8010945b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109461:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109465:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010946c:	7e 84                	jle    801093f2 <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010946e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80109475:	eb 57                	jmp    801094ce <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
80109477:	e8 0e 99 ff ff       	call   80102d8a <kalloc>
8010947c:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
8010947f:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80109483:	75 12                	jne    80109497 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
80109485:	83 ec 0c             	sub    $0xc,%esp
80109488:	68 d8 cb 10 80       	push   $0x8010cbd8
8010948d:	e8 7a 6f ff ff       	call   8010040c <cprintf>
80109492:	83 c4 10             	add    $0x10,%esp
      break;
80109495:	eb 3d                	jmp    801094d4 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80109497:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010949a:	c1 e0 04             	shl    $0x4,%eax
8010949d:	89 c2                	mov    %eax,%edx
8010949f:	8b 45 98             	mov    -0x68(%ebp),%eax
801094a2:	01 d0                	add    %edx,%eax
801094a4:	8b 55 94             	mov    -0x6c(%ebp),%edx
801094a7:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801094ad:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801094af:	8b 45 dc             	mov    -0x24(%ebp),%eax
801094b2:	83 c0 01             	add    $0x1,%eax
801094b5:	c1 e0 04             	shl    $0x4,%eax
801094b8:	89 c2                	mov    %eax,%edx
801094ba:	8b 45 98             	mov    -0x68(%ebp),%eax
801094bd:	01 d0                	add    %edx,%eax
801094bf:	8b 55 94             	mov    -0x6c(%ebp),%edx
801094c2:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801094c8:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801094ca:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801094ce:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801094d2:	7e a3                	jle    80109477 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
801094d4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801094d7:	8b 00                	mov    (%eax),%eax
801094d9:	83 c8 02             	or     $0x2,%eax
801094dc:	89 c2                	mov    %eax,%edx
801094de:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801094e1:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801094e3:	83 ec 0c             	sub    $0xc,%esp
801094e6:	68 f8 cb 10 80       	push   $0x8010cbf8
801094eb:	e8 1c 6f ff ff       	call   8010040c <cprintf>
801094f0:	83 c4 10             	add    $0x10,%esp
}
801094f3:	90                   	nop
801094f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801094f7:	5b                   	pop    %ebx
801094f8:	5e                   	pop    %esi
801094f9:	5f                   	pop    %edi
801094fa:	5d                   	pop    %ebp
801094fb:	c3                   	ret    

801094fc <i8254_init_send>:

void i8254_init_send(){
801094fc:	f3 0f 1e fb          	endbr32 
80109500:	55                   	push   %ebp
80109501:	89 e5                	mov    %esp,%ebp
80109503:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80109506:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010950b:	05 28 38 00 00       	add    $0x3828,%eax
80109510:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80109513:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109516:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
8010951c:	e8 69 98 ff ff       	call   80102d8a <kalloc>
80109521:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109524:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109529:	05 00 38 00 00       	add    $0x3800,%eax
8010952e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80109531:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109536:	05 04 38 00 00       	add    $0x3804,%eax
8010953b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
8010953e:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109543:	05 08 38 00 00       	add    $0x3808,%eax
80109548:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
8010954b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010954e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109554:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109557:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109559:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010955c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109562:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109565:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010956b:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109570:	05 10 38 00 00       	add    $0x3810,%eax
80109575:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109578:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010957d:	05 18 38 00 00       	add    $0x3818,%eax
80109582:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80109585:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109588:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
8010958e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109591:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80109597:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010959a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010959d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801095a4:	e9 82 00 00 00       	jmp    8010962b <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
801095a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ac:	c1 e0 04             	shl    $0x4,%eax
801095af:	89 c2                	mov    %eax,%edx
801095b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801095b4:	01 d0                	add    %edx,%eax
801095b6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801095bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c0:	c1 e0 04             	shl    $0x4,%eax
801095c3:	89 c2                	mov    %eax,%edx
801095c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801095c8:	01 d0                	add    %edx,%eax
801095ca:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801095d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d3:	c1 e0 04             	shl    $0x4,%eax
801095d6:	89 c2                	mov    %eax,%edx
801095d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801095db:	01 d0                	add    %edx,%eax
801095dd:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801095e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095e4:	c1 e0 04             	shl    $0x4,%eax
801095e7:	89 c2                	mov    %eax,%edx
801095e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801095ec:	01 d0                	add    %edx,%eax
801095ee:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801095f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095f5:	c1 e0 04             	shl    $0x4,%eax
801095f8:	89 c2                	mov    %eax,%edx
801095fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
801095fd:	01 d0                	add    %edx,%eax
801095ff:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80109603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109606:	c1 e0 04             	shl    $0x4,%eax
80109609:	89 c2                	mov    %eax,%edx
8010960b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010960e:	01 d0                	add    %edx,%eax
80109610:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80109614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109617:	c1 e0 04             	shl    $0x4,%eax
8010961a:	89 c2                	mov    %eax,%edx
8010961c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010961f:	01 d0                	add    %edx,%eax
80109621:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010962b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109632:	0f 8e 71 ff ff ff    	jle    801095a9 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109638:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010963f:	eb 57                	jmp    80109698 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80109641:	e8 44 97 ff ff       	call   80102d8a <kalloc>
80109646:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109649:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
8010964d:	75 12                	jne    80109661 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
8010964f:	83 ec 0c             	sub    $0xc,%esp
80109652:	68 d8 cb 10 80       	push   $0x8010cbd8
80109657:	e8 b0 6d ff ff       	call   8010040c <cprintf>
8010965c:	83 c4 10             	add    $0x10,%esp
      break;
8010965f:	eb 3d                	jmp    8010969e <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109661:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109664:	c1 e0 04             	shl    $0x4,%eax
80109667:	89 c2                	mov    %eax,%edx
80109669:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010966c:	01 d0                	add    %edx,%eax
8010966e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80109671:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80109677:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80109679:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010967c:	83 c0 01             	add    $0x1,%eax
8010967f:	c1 e0 04             	shl    $0x4,%eax
80109682:	89 c2                	mov    %eax,%edx
80109684:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109687:	01 d0                	add    %edx,%eax
80109689:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010968c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80109692:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109694:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109698:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010969c:	7e a3                	jle    80109641 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
8010969e:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801096a3:	05 00 04 00 00       	add    $0x400,%eax
801096a8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801096ab:	8b 45 c8             	mov    -0x38(%ebp),%eax
801096ae:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801096b4:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801096b9:	05 10 04 00 00       	add    $0x410,%eax
801096be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801096c1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801096c4:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801096ca:	83 ec 0c             	sub    $0xc,%esp
801096cd:	68 18 cc 10 80       	push   $0x8010cc18
801096d2:	e8 35 6d ff ff       	call   8010040c <cprintf>
801096d7:	83 c4 10             	add    $0x10,%esp

}
801096da:	90                   	nop
801096db:	c9                   	leave  
801096dc:	c3                   	ret    

801096dd <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801096dd:	f3 0f 1e fb          	endbr32 
801096e1:	55                   	push   %ebp
801096e2:	89 e5                	mov    %esp,%ebp
801096e4:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801096e7:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801096ec:	83 c0 14             	add    $0x14,%eax
801096ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801096f2:	8b 45 08             	mov    0x8(%ebp),%eax
801096f5:	c1 e0 08             	shl    $0x8,%eax
801096f8:	0f b7 c0             	movzwl %ax,%eax
801096fb:	83 c8 01             	or     $0x1,%eax
801096fe:	89 c2                	mov    %eax,%edx
80109700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109703:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80109705:	83 ec 0c             	sub    $0xc,%esp
80109708:	68 38 cc 10 80       	push   $0x8010cc38
8010970d:	e8 fa 6c ff ff       	call   8010040c <cprintf>
80109712:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80109715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109718:	8b 00                	mov    (%eax),%eax
8010971a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
8010971d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109720:	83 e0 10             	and    $0x10,%eax
80109723:	85 c0                	test   %eax,%eax
80109725:	75 02                	jne    80109729 <i8254_read_eeprom+0x4c>
  while(1){
80109727:	eb dc                	jmp    80109705 <i8254_read_eeprom+0x28>
      break;
80109729:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
8010972a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010972d:	8b 00                	mov    (%eax),%eax
8010972f:	c1 e8 10             	shr    $0x10,%eax
}
80109732:	c9                   	leave  
80109733:	c3                   	ret    

80109734 <i8254_recv>:
void i8254_recv(){
80109734:	f3 0f 1e fb          	endbr32 
80109738:	55                   	push   %ebp
80109739:	89 e5                	mov    %esp,%ebp
8010973b:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
8010973e:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109743:	05 10 28 00 00       	add    $0x2810,%eax
80109748:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010974b:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109750:	05 18 28 00 00       	add    $0x2818,%eax
80109755:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109758:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010975d:	05 00 28 00 00       	add    $0x2800,%eax
80109762:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109765:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109768:	8b 00                	mov    (%eax),%eax
8010976a:	05 00 00 00 80       	add    $0x80000000,%eax
8010976f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80109772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109775:	8b 10                	mov    (%eax),%edx
80109777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010977a:	8b 00                	mov    (%eax),%eax
8010977c:	29 c2                	sub    %eax,%edx
8010977e:	89 d0                	mov    %edx,%eax
80109780:	25 ff 00 00 00       	and    $0xff,%eax
80109785:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80109788:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010978c:	7e 37                	jle    801097c5 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
8010978e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109791:	8b 00                	mov    (%eax),%eax
80109793:	c1 e0 04             	shl    $0x4,%eax
80109796:	89 c2                	mov    %eax,%edx
80109798:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010979b:	01 d0                	add    %edx,%eax
8010979d:	8b 00                	mov    (%eax),%eax
8010979f:	05 00 00 00 80       	add    $0x80000000,%eax
801097a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801097a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097aa:	8b 00                	mov    (%eax),%eax
801097ac:	83 c0 01             	add    $0x1,%eax
801097af:	0f b6 d0             	movzbl %al,%edx
801097b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097b5:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801097b7:	83 ec 0c             	sub    $0xc,%esp
801097ba:	ff 75 e0             	pushl  -0x20(%ebp)
801097bd:	e8 47 09 00 00       	call   8010a109 <eth_proc>
801097c2:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801097c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097c8:	8b 10                	mov    (%eax),%edx
801097ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097cd:	8b 00                	mov    (%eax),%eax
801097cf:	39 c2                	cmp    %eax,%edx
801097d1:	75 9f                	jne    80109772 <i8254_recv+0x3e>
      (*rdt)--;
801097d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097d6:	8b 00                	mov    (%eax),%eax
801097d8:	8d 50 ff             	lea    -0x1(%eax),%edx
801097db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097de:	89 10                	mov    %edx,(%eax)
  while(1){
801097e0:	eb 90                	jmp    80109772 <i8254_recv+0x3e>

801097e2 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
801097e2:	f3 0f 1e fb          	endbr32 
801097e6:	55                   	push   %ebp
801097e7:	89 e5                	mov    %esp,%ebp
801097e9:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
801097ec:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801097f1:	05 10 38 00 00       	add    $0x3810,%eax
801097f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801097f9:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801097fe:	05 18 38 00 00       	add    $0x3818,%eax
80109803:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109806:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010980b:	05 00 38 00 00       	add    $0x3800,%eax
80109810:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109813:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109816:	8b 00                	mov    (%eax),%eax
80109818:	05 00 00 00 80       	add    $0x80000000,%eax
8010981d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109820:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109823:	8b 10                	mov    (%eax),%edx
80109825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109828:	8b 00                	mov    (%eax),%eax
8010982a:	29 c2                	sub    %eax,%edx
8010982c:	89 d0                	mov    %edx,%eax
8010982e:	0f b6 c0             	movzbl %al,%eax
80109831:	ba 00 01 00 00       	mov    $0x100,%edx
80109836:	29 c2                	sub    %eax,%edx
80109838:	89 d0                	mov    %edx,%eax
8010983a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010983d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109840:	8b 00                	mov    (%eax),%eax
80109842:	25 ff 00 00 00       	and    $0xff,%eax
80109847:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010984a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010984e:	0f 8e a8 00 00 00    	jle    801098fc <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109854:	8b 45 08             	mov    0x8(%ebp),%eax
80109857:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010985a:	89 d1                	mov    %edx,%ecx
8010985c:	c1 e1 04             	shl    $0x4,%ecx
8010985f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109862:	01 ca                	add    %ecx,%edx
80109864:	8b 12                	mov    (%edx),%edx
80109866:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010986c:	83 ec 04             	sub    $0x4,%esp
8010986f:	ff 75 0c             	pushl  0xc(%ebp)
80109872:	50                   	push   %eax
80109873:	52                   	push   %edx
80109874:	e8 f5 bc ff ff       	call   8010556e <memmove>
80109879:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010987c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010987f:	c1 e0 04             	shl    $0x4,%eax
80109882:	89 c2                	mov    %eax,%edx
80109884:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109887:	01 d0                	add    %edx,%eax
80109889:	8b 55 0c             	mov    0xc(%ebp),%edx
8010988c:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109890:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109893:	c1 e0 04             	shl    $0x4,%eax
80109896:	89 c2                	mov    %eax,%edx
80109898:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010989b:	01 d0                	add    %edx,%eax
8010989d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801098a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098a4:	c1 e0 04             	shl    $0x4,%eax
801098a7:	89 c2                	mov    %eax,%edx
801098a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801098ac:	01 d0                	add    %edx,%eax
801098ae:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801098b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098b5:	c1 e0 04             	shl    $0x4,%eax
801098b8:	89 c2                	mov    %eax,%edx
801098ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
801098bd:	01 d0                	add    %edx,%eax
801098bf:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801098c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098c6:	c1 e0 04             	shl    $0x4,%eax
801098c9:	89 c2                	mov    %eax,%edx
801098cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801098ce:	01 d0                	add    %edx,%eax
801098d0:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801098d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098d9:	c1 e0 04             	shl    $0x4,%eax
801098dc:	89 c2                	mov    %eax,%edx
801098de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801098e1:	01 d0                	add    %edx,%eax
801098e3:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801098e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098ea:	8b 00                	mov    (%eax),%eax
801098ec:	83 c0 01             	add    $0x1,%eax
801098ef:	0f b6 d0             	movzbl %al,%edx
801098f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098f5:	89 10                	mov    %edx,(%eax)
    return len;
801098f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801098fa:	eb 05                	jmp    80109901 <i8254_send+0x11f>
  }else{
    return -1;
801098fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109901:	c9                   	leave  
80109902:	c3                   	ret    

80109903 <i8254_intr>:

void i8254_intr(){
80109903:	f3 0f 1e fb          	endbr32 
80109907:	55                   	push   %ebp
80109908:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
8010990a:	a1 f8 b1 11 80       	mov    0x8011b1f8,%eax
8010990f:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109915:	90                   	nop
80109916:	5d                   	pop    %ebp
80109917:	c3                   	ret    

80109918 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109918:	f3 0f 1e fb          	endbr32 
8010991c:	55                   	push   %ebp
8010991d:	89 e5                	mov    %esp,%ebp
8010991f:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109922:	8b 45 08             	mov    0x8(%ebp),%eax
80109925:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010992b:	0f b7 00             	movzwl (%eax),%eax
8010992e:	66 3d 00 01          	cmp    $0x100,%ax
80109932:	74 0a                	je     8010993e <arp_proc+0x26>
80109934:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109939:	e9 4f 01 00 00       	jmp    80109a8d <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
8010993e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109941:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109945:	66 83 f8 08          	cmp    $0x8,%ax
80109949:	74 0a                	je     80109955 <arp_proc+0x3d>
8010994b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109950:	e9 38 01 00 00       	jmp    80109a8d <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80109955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109958:	0f b6 40 04          	movzbl 0x4(%eax),%eax
8010995c:	3c 06                	cmp    $0x6,%al
8010995e:	74 0a                	je     8010996a <arp_proc+0x52>
80109960:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109965:	e9 23 01 00 00       	jmp    80109a8d <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
8010996a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010996d:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109971:	3c 04                	cmp    $0x4,%al
80109973:	74 0a                	je     8010997f <arp_proc+0x67>
80109975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010997a:	e9 0e 01 00 00       	jmp    80109a8d <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
8010997f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109982:	83 c0 18             	add    $0x18,%eax
80109985:	83 ec 04             	sub    $0x4,%esp
80109988:	6a 04                	push   $0x4
8010998a:	50                   	push   %eax
8010998b:	68 04 f5 10 80       	push   $0x8010f504
80109990:	e8 7d bb ff ff       	call   80105512 <memcmp>
80109995:	83 c4 10             	add    $0x10,%esp
80109998:	85 c0                	test   %eax,%eax
8010999a:	74 27                	je     801099c3 <arp_proc+0xab>
8010999c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010999f:	83 c0 0e             	add    $0xe,%eax
801099a2:	83 ec 04             	sub    $0x4,%esp
801099a5:	6a 04                	push   $0x4
801099a7:	50                   	push   %eax
801099a8:	68 04 f5 10 80       	push   $0x8010f504
801099ad:	e8 60 bb ff ff       	call   80105512 <memcmp>
801099b2:	83 c4 10             	add    $0x10,%esp
801099b5:	85 c0                	test   %eax,%eax
801099b7:	74 0a                	je     801099c3 <arp_proc+0xab>
801099b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801099be:	e9 ca 00 00 00       	jmp    80109a8d <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801099c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801099ca:	66 3d 00 01          	cmp    $0x100,%ax
801099ce:	75 69                	jne    80109a39 <arp_proc+0x121>
801099d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d3:	83 c0 18             	add    $0x18,%eax
801099d6:	83 ec 04             	sub    $0x4,%esp
801099d9:	6a 04                	push   $0x4
801099db:	50                   	push   %eax
801099dc:	68 04 f5 10 80       	push   $0x8010f504
801099e1:	e8 2c bb ff ff       	call   80105512 <memcmp>
801099e6:	83 c4 10             	add    $0x10,%esp
801099e9:	85 c0                	test   %eax,%eax
801099eb:	75 4c                	jne    80109a39 <arp_proc+0x121>
    uint send = (uint)kalloc();
801099ed:	e8 98 93 ff ff       	call   80102d8a <kalloc>
801099f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801099f5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801099fc:	83 ec 04             	sub    $0x4,%esp
801099ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109a02:	50                   	push   %eax
80109a03:	ff 75 f0             	pushl  -0x10(%ebp)
80109a06:	ff 75 f4             	pushl  -0xc(%ebp)
80109a09:	e8 33 04 00 00       	call   80109e41 <arp_reply_pkt_create>
80109a0e:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109a11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109a14:	83 ec 08             	sub    $0x8,%esp
80109a17:	50                   	push   %eax
80109a18:	ff 75 f0             	pushl  -0x10(%ebp)
80109a1b:	e8 c2 fd ff ff       	call   801097e2 <i8254_send>
80109a20:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a26:	83 ec 0c             	sub    $0xc,%esp
80109a29:	50                   	push   %eax
80109a2a:	e8 bd 92 ff ff       	call   80102cec <kfree>
80109a2f:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109a32:	b8 02 00 00 00       	mov    $0x2,%eax
80109a37:	eb 54                	jmp    80109a8d <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a3c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109a40:	66 3d 00 02          	cmp    $0x200,%ax
80109a44:	75 42                	jne    80109a88 <arp_proc+0x170>
80109a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a49:	83 c0 18             	add    $0x18,%eax
80109a4c:	83 ec 04             	sub    $0x4,%esp
80109a4f:	6a 04                	push   $0x4
80109a51:	50                   	push   %eax
80109a52:	68 04 f5 10 80       	push   $0x8010f504
80109a57:	e8 b6 ba ff ff       	call   80105512 <memcmp>
80109a5c:	83 c4 10             	add    $0x10,%esp
80109a5f:	85 c0                	test   %eax,%eax
80109a61:	75 25                	jne    80109a88 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
80109a63:	83 ec 0c             	sub    $0xc,%esp
80109a66:	68 3c cc 10 80       	push   $0x8010cc3c
80109a6b:	e8 9c 69 ff ff       	call   8010040c <cprintf>
80109a70:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80109a73:	83 ec 0c             	sub    $0xc,%esp
80109a76:	ff 75 f4             	pushl  -0xc(%ebp)
80109a79:	e8 b7 01 00 00       	call   80109c35 <arp_table_update>
80109a7e:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109a81:	b8 01 00 00 00       	mov    $0x1,%eax
80109a86:	eb 05                	jmp    80109a8d <arp_proc+0x175>
  }else{
    return -1;
80109a88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109a8d:	c9                   	leave  
80109a8e:	c3                   	ret    

80109a8f <arp_scan>:

void arp_scan(){
80109a8f:	f3 0f 1e fb          	endbr32 
80109a93:	55                   	push   %ebp
80109a94:	89 e5                	mov    %esp,%ebp
80109a96:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80109a99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109aa0:	eb 6f                	jmp    80109b11 <arp_scan+0x82>
    uint send = (uint)kalloc();
80109aa2:	e8 e3 92 ff ff       	call   80102d8a <kalloc>
80109aa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80109aaa:	83 ec 04             	sub    $0x4,%esp
80109aad:	ff 75 f4             	pushl  -0xc(%ebp)
80109ab0:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109ab3:	50                   	push   %eax
80109ab4:	ff 75 ec             	pushl  -0x14(%ebp)
80109ab7:	e8 62 00 00 00       	call   80109b1e <arp_broadcast>
80109abc:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80109abf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ac2:	83 ec 08             	sub    $0x8,%esp
80109ac5:	50                   	push   %eax
80109ac6:	ff 75 ec             	pushl  -0x14(%ebp)
80109ac9:	e8 14 fd ff ff       	call   801097e2 <i8254_send>
80109ace:	83 c4 10             	add    $0x10,%esp
80109ad1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109ad4:	eb 22                	jmp    80109af8 <arp_scan+0x69>
      microdelay(1);
80109ad6:	83 ec 0c             	sub    $0xc,%esp
80109ad9:	6a 01                	push   $0x1
80109adb:	e8 5c 96 ff ff       	call   8010313c <microdelay>
80109ae0:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109ae3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ae6:	83 ec 08             	sub    $0x8,%esp
80109ae9:	50                   	push   %eax
80109aea:	ff 75 ec             	pushl  -0x14(%ebp)
80109aed:	e8 f0 fc ff ff       	call   801097e2 <i8254_send>
80109af2:	83 c4 10             	add    $0x10,%esp
80109af5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109af8:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80109afc:	74 d8                	je     80109ad6 <arp_scan+0x47>
    }
    kfree((char *)send);
80109afe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b01:	83 ec 0c             	sub    $0xc,%esp
80109b04:	50                   	push   %eax
80109b05:	e8 e2 91 ff ff       	call   80102cec <kfree>
80109b0a:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80109b0d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109b11:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109b18:	7e 88                	jle    80109aa2 <arp_scan+0x13>
  }
}
80109b1a:	90                   	nop
80109b1b:	90                   	nop
80109b1c:	c9                   	leave  
80109b1d:	c3                   	ret    

80109b1e <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109b1e:	f3 0f 1e fb          	endbr32 
80109b22:	55                   	push   %ebp
80109b23:	89 e5                	mov    %esp,%ebp
80109b25:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109b28:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80109b2c:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109b30:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109b34:	8b 45 10             	mov    0x10(%ebp),%eax
80109b37:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80109b3a:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109b41:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109b47:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109b4e:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109b54:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b57:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80109b60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109b63:	8b 45 08             	mov    0x8(%ebp),%eax
80109b66:	83 c0 0e             	add    $0xe,%eax
80109b69:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80109b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b6f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b76:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80109b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b7d:	83 ec 04             	sub    $0x4,%esp
80109b80:	6a 06                	push   $0x6
80109b82:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109b85:	52                   	push   %edx
80109b86:	50                   	push   %eax
80109b87:	e8 e2 b9 ff ff       	call   8010556e <memmove>
80109b8c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b92:	83 c0 06             	add    $0x6,%eax
80109b95:	83 ec 04             	sub    $0x4,%esp
80109b98:	6a 06                	push   $0x6
80109b9a:	68 ac 00 11 80       	push   $0x801100ac
80109b9f:	50                   	push   %eax
80109ba0:	e8 c9 b9 ff ff       	call   8010556e <memmove>
80109ba5:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bab:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109bb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bb3:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bbc:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bc3:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80109bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bca:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bd3:	8d 50 12             	lea    0x12(%eax),%edx
80109bd6:	83 ec 04             	sub    $0x4,%esp
80109bd9:	6a 06                	push   $0x6
80109bdb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109bde:	50                   	push   %eax
80109bdf:	52                   	push   %edx
80109be0:	e8 89 b9 ff ff       	call   8010556e <memmove>
80109be5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109beb:	8d 50 18             	lea    0x18(%eax),%edx
80109bee:	83 ec 04             	sub    $0x4,%esp
80109bf1:	6a 04                	push   $0x4
80109bf3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109bf6:	50                   	push   %eax
80109bf7:	52                   	push   %edx
80109bf8:	e8 71 b9 ff ff       	call   8010556e <memmove>
80109bfd:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c03:	83 c0 08             	add    $0x8,%eax
80109c06:	83 ec 04             	sub    $0x4,%esp
80109c09:	6a 06                	push   $0x6
80109c0b:	68 ac 00 11 80       	push   $0x801100ac
80109c10:	50                   	push   %eax
80109c11:	e8 58 b9 ff ff       	call   8010556e <memmove>
80109c16:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c1c:	83 c0 0e             	add    $0xe,%eax
80109c1f:	83 ec 04             	sub    $0x4,%esp
80109c22:	6a 04                	push   $0x4
80109c24:	68 04 f5 10 80       	push   $0x8010f504
80109c29:	50                   	push   %eax
80109c2a:	e8 3f b9 ff ff       	call   8010556e <memmove>
80109c2f:	83 c4 10             	add    $0x10,%esp
}
80109c32:	90                   	nop
80109c33:	c9                   	leave  
80109c34:	c3                   	ret    

80109c35 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109c35:	f3 0f 1e fb          	endbr32 
80109c39:	55                   	push   %ebp
80109c3a:	89 e5                	mov    %esp,%ebp
80109c3c:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80109c42:	83 c0 0e             	add    $0xe,%eax
80109c45:	83 ec 0c             	sub    $0xc,%esp
80109c48:	50                   	push   %eax
80109c49:	e8 bc 00 00 00       	call   80109d0a <arp_table_search>
80109c4e:	83 c4 10             	add    $0x10,%esp
80109c51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109c54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109c58:	78 2d                	js     80109c87 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80109c5d:	8d 48 08             	lea    0x8(%eax),%ecx
80109c60:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c63:	89 d0                	mov    %edx,%eax
80109c65:	c1 e0 02             	shl    $0x2,%eax
80109c68:	01 d0                	add    %edx,%eax
80109c6a:	01 c0                	add    %eax,%eax
80109c6c:	01 d0                	add    %edx,%eax
80109c6e:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109c73:	83 c0 04             	add    $0x4,%eax
80109c76:	83 ec 04             	sub    $0x4,%esp
80109c79:	6a 06                	push   $0x6
80109c7b:	51                   	push   %ecx
80109c7c:	50                   	push   %eax
80109c7d:	e8 ec b8 ff ff       	call   8010556e <memmove>
80109c82:	83 c4 10             	add    $0x10,%esp
80109c85:	eb 70                	jmp    80109cf7 <arp_table_update+0xc2>
  }else{
    index += 1;
80109c87:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109c8b:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80109c91:	8d 48 08             	lea    0x8(%eax),%ecx
80109c94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c97:	89 d0                	mov    %edx,%eax
80109c99:	c1 e0 02             	shl    $0x2,%eax
80109c9c:	01 d0                	add    %edx,%eax
80109c9e:	01 c0                	add    %eax,%eax
80109ca0:	01 d0                	add    %edx,%eax
80109ca2:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109ca7:	83 c0 04             	add    $0x4,%eax
80109caa:	83 ec 04             	sub    $0x4,%esp
80109cad:	6a 06                	push   $0x6
80109caf:	51                   	push   %ecx
80109cb0:	50                   	push   %eax
80109cb1:	e8 b8 b8 ff ff       	call   8010556e <memmove>
80109cb6:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80109cbc:	8d 48 0e             	lea    0xe(%eax),%ecx
80109cbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109cc2:	89 d0                	mov    %edx,%eax
80109cc4:	c1 e0 02             	shl    $0x2,%eax
80109cc7:	01 d0                	add    %edx,%eax
80109cc9:	01 c0                	add    %eax,%eax
80109ccb:	01 d0                	add    %edx,%eax
80109ccd:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109cd2:	83 ec 04             	sub    $0x4,%esp
80109cd5:	6a 04                	push   $0x4
80109cd7:	51                   	push   %ecx
80109cd8:	50                   	push   %eax
80109cd9:	e8 90 b8 ff ff       	call   8010556e <memmove>
80109cde:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109ce1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ce4:	89 d0                	mov    %edx,%eax
80109ce6:	c1 e0 02             	shl    $0x2,%eax
80109ce9:	01 d0                	add    %edx,%eax
80109ceb:	01 c0                	add    %eax,%eax
80109ced:	01 d0                	add    %edx,%eax
80109cef:	05 ca 00 11 80       	add    $0x801100ca,%eax
80109cf4:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109cf7:	83 ec 0c             	sub    $0xc,%esp
80109cfa:	68 c0 00 11 80       	push   $0x801100c0
80109cff:	e8 87 00 00 00       	call   80109d8b <print_arp_table>
80109d04:	83 c4 10             	add    $0x10,%esp
}
80109d07:	90                   	nop
80109d08:	c9                   	leave  
80109d09:	c3                   	ret    

80109d0a <arp_table_search>:

int arp_table_search(uchar *ip){
80109d0a:	f3 0f 1e fb          	endbr32 
80109d0e:	55                   	push   %ebp
80109d0f:	89 e5                	mov    %esp,%ebp
80109d11:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109d14:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109d1b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109d22:	eb 59                	jmp    80109d7d <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109d24:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d27:	89 d0                	mov    %edx,%eax
80109d29:	c1 e0 02             	shl    $0x2,%eax
80109d2c:	01 d0                	add    %edx,%eax
80109d2e:	01 c0                	add    %eax,%eax
80109d30:	01 d0                	add    %edx,%eax
80109d32:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109d37:	83 ec 04             	sub    $0x4,%esp
80109d3a:	6a 04                	push   $0x4
80109d3c:	ff 75 08             	pushl  0x8(%ebp)
80109d3f:	50                   	push   %eax
80109d40:	e8 cd b7 ff ff       	call   80105512 <memcmp>
80109d45:	83 c4 10             	add    $0x10,%esp
80109d48:	85 c0                	test   %eax,%eax
80109d4a:	75 05                	jne    80109d51 <arp_table_search+0x47>
      return i;
80109d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d4f:	eb 38                	jmp    80109d89 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109d51:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109d54:	89 d0                	mov    %edx,%eax
80109d56:	c1 e0 02             	shl    $0x2,%eax
80109d59:	01 d0                	add    %edx,%eax
80109d5b:	01 c0                	add    %eax,%eax
80109d5d:	01 d0                	add    %edx,%eax
80109d5f:	05 ca 00 11 80       	add    $0x801100ca,%eax
80109d64:	0f b6 00             	movzbl (%eax),%eax
80109d67:	84 c0                	test   %al,%al
80109d69:	75 0e                	jne    80109d79 <arp_table_search+0x6f>
80109d6b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109d6f:	75 08                	jne    80109d79 <arp_table_search+0x6f>
      empty = -i;
80109d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d74:	f7 d8                	neg    %eax
80109d76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109d79:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109d7d:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109d81:	7e a1                	jle    80109d24 <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d86:	83 e8 01             	sub    $0x1,%eax
}
80109d89:	c9                   	leave  
80109d8a:	c3                   	ret    

80109d8b <print_arp_table>:

void print_arp_table(){
80109d8b:	f3 0f 1e fb          	endbr32 
80109d8f:	55                   	push   %ebp
80109d90:	89 e5                	mov    %esp,%ebp
80109d92:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109d95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109d9c:	e9 92 00 00 00       	jmp    80109e33 <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109da1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109da4:	89 d0                	mov    %edx,%eax
80109da6:	c1 e0 02             	shl    $0x2,%eax
80109da9:	01 d0                	add    %edx,%eax
80109dab:	01 c0                	add    %eax,%eax
80109dad:	01 d0                	add    %edx,%eax
80109daf:	05 ca 00 11 80       	add    $0x801100ca,%eax
80109db4:	0f b6 00             	movzbl (%eax),%eax
80109db7:	84 c0                	test   %al,%al
80109db9:	74 74                	je     80109e2f <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109dbb:	83 ec 08             	sub    $0x8,%esp
80109dbe:	ff 75 f4             	pushl  -0xc(%ebp)
80109dc1:	68 4f cc 10 80       	push   $0x8010cc4f
80109dc6:	e8 41 66 ff ff       	call   8010040c <cprintf>
80109dcb:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109dce:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109dd1:	89 d0                	mov    %edx,%eax
80109dd3:	c1 e0 02             	shl    $0x2,%eax
80109dd6:	01 d0                	add    %edx,%eax
80109dd8:	01 c0                	add    %eax,%eax
80109dda:	01 d0                	add    %edx,%eax
80109ddc:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109de1:	83 ec 0c             	sub    $0xc,%esp
80109de4:	50                   	push   %eax
80109de5:	e8 5c 02 00 00       	call   8010a046 <print_ipv4>
80109dea:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109ded:	83 ec 0c             	sub    $0xc,%esp
80109df0:	68 5e cc 10 80       	push   $0x8010cc5e
80109df5:	e8 12 66 ff ff       	call   8010040c <cprintf>
80109dfa:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109dfd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e00:	89 d0                	mov    %edx,%eax
80109e02:	c1 e0 02             	shl    $0x2,%eax
80109e05:	01 d0                	add    %edx,%eax
80109e07:	01 c0                	add    %eax,%eax
80109e09:	01 d0                	add    %edx,%eax
80109e0b:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109e10:	83 c0 04             	add    $0x4,%eax
80109e13:	83 ec 0c             	sub    $0xc,%esp
80109e16:	50                   	push   %eax
80109e17:	e8 7c 02 00 00       	call   8010a098 <print_mac>
80109e1c:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109e1f:	83 ec 0c             	sub    $0xc,%esp
80109e22:	68 60 cc 10 80       	push   $0x8010cc60
80109e27:	e8 e0 65 ff ff       	call   8010040c <cprintf>
80109e2c:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109e2f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109e33:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109e37:	0f 8e 64 ff ff ff    	jle    80109da1 <print_arp_table+0x16>
    }
  }
}
80109e3d:	90                   	nop
80109e3e:	90                   	nop
80109e3f:	c9                   	leave  
80109e40:	c3                   	ret    

80109e41 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109e41:	f3 0f 1e fb          	endbr32 
80109e45:	55                   	push   %ebp
80109e46:	89 e5                	mov    %esp,%ebp
80109e48:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109e4b:	8b 45 10             	mov    0x10(%ebp),%eax
80109e4e:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109e54:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e5d:	83 c0 0e             	add    $0xe,%eax
80109e60:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e66:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e6d:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109e71:	8b 45 08             	mov    0x8(%ebp),%eax
80109e74:	8d 50 08             	lea    0x8(%eax),%edx
80109e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e7a:	83 ec 04             	sub    $0x4,%esp
80109e7d:	6a 06                	push   $0x6
80109e7f:	52                   	push   %edx
80109e80:	50                   	push   %eax
80109e81:	e8 e8 b6 ff ff       	call   8010556e <memmove>
80109e86:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e8c:	83 c0 06             	add    $0x6,%eax
80109e8f:	83 ec 04             	sub    $0x4,%esp
80109e92:	6a 06                	push   $0x6
80109e94:	68 ac 00 11 80       	push   $0x801100ac
80109e99:	50                   	push   %eax
80109e9a:	e8 cf b6 ff ff       	call   8010556e <memmove>
80109e9f:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ea5:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ead:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eb6:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ebd:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ec4:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109eca:	8b 45 08             	mov    0x8(%ebp),%eax
80109ecd:	8d 50 08             	lea    0x8(%eax),%edx
80109ed0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ed3:	83 c0 12             	add    $0x12,%eax
80109ed6:	83 ec 04             	sub    $0x4,%esp
80109ed9:	6a 06                	push   $0x6
80109edb:	52                   	push   %edx
80109edc:	50                   	push   %eax
80109edd:	e8 8c b6 ff ff       	call   8010556e <memmove>
80109ee2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ee8:	8d 50 0e             	lea    0xe(%eax),%edx
80109eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eee:	83 c0 18             	add    $0x18,%eax
80109ef1:	83 ec 04             	sub    $0x4,%esp
80109ef4:	6a 04                	push   $0x4
80109ef6:	52                   	push   %edx
80109ef7:	50                   	push   %eax
80109ef8:	e8 71 b6 ff ff       	call   8010556e <memmove>
80109efd:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f03:	83 c0 08             	add    $0x8,%eax
80109f06:	83 ec 04             	sub    $0x4,%esp
80109f09:	6a 06                	push   $0x6
80109f0b:	68 ac 00 11 80       	push   $0x801100ac
80109f10:	50                   	push   %eax
80109f11:	e8 58 b6 ff ff       	call   8010556e <memmove>
80109f16:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f1c:	83 c0 0e             	add    $0xe,%eax
80109f1f:	83 ec 04             	sub    $0x4,%esp
80109f22:	6a 04                	push   $0x4
80109f24:	68 04 f5 10 80       	push   $0x8010f504
80109f29:	50                   	push   %eax
80109f2a:	e8 3f b6 ff ff       	call   8010556e <memmove>
80109f2f:	83 c4 10             	add    $0x10,%esp
}
80109f32:	90                   	nop
80109f33:	c9                   	leave  
80109f34:	c3                   	ret    

80109f35 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109f35:	f3 0f 1e fb          	endbr32 
80109f39:	55                   	push   %ebp
80109f3a:	89 e5                	mov    %esp,%ebp
80109f3c:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109f3f:	83 ec 0c             	sub    $0xc,%esp
80109f42:	68 62 cc 10 80       	push   $0x8010cc62
80109f47:	e8 c0 64 ff ff       	call   8010040c <cprintf>
80109f4c:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80109f52:	83 c0 0e             	add    $0xe,%eax
80109f55:	83 ec 0c             	sub    $0xc,%esp
80109f58:	50                   	push   %eax
80109f59:	e8 e8 00 00 00       	call   8010a046 <print_ipv4>
80109f5e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109f61:	83 ec 0c             	sub    $0xc,%esp
80109f64:	68 60 cc 10 80       	push   $0x8010cc60
80109f69:	e8 9e 64 ff ff       	call   8010040c <cprintf>
80109f6e:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109f71:	8b 45 08             	mov    0x8(%ebp),%eax
80109f74:	83 c0 08             	add    $0x8,%eax
80109f77:	83 ec 0c             	sub    $0xc,%esp
80109f7a:	50                   	push   %eax
80109f7b:	e8 18 01 00 00       	call   8010a098 <print_mac>
80109f80:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109f83:	83 ec 0c             	sub    $0xc,%esp
80109f86:	68 60 cc 10 80       	push   $0x8010cc60
80109f8b:	e8 7c 64 ff ff       	call   8010040c <cprintf>
80109f90:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109f93:	83 ec 0c             	sub    $0xc,%esp
80109f96:	68 79 cc 10 80       	push   $0x8010cc79
80109f9b:	e8 6c 64 ff ff       	call   8010040c <cprintf>
80109fa0:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80109fa6:	83 c0 18             	add    $0x18,%eax
80109fa9:	83 ec 0c             	sub    $0xc,%esp
80109fac:	50                   	push   %eax
80109fad:	e8 94 00 00 00       	call   8010a046 <print_ipv4>
80109fb2:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109fb5:	83 ec 0c             	sub    $0xc,%esp
80109fb8:	68 60 cc 10 80       	push   $0x8010cc60
80109fbd:	e8 4a 64 ff ff       	call   8010040c <cprintf>
80109fc2:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80109fc8:	83 c0 12             	add    $0x12,%eax
80109fcb:	83 ec 0c             	sub    $0xc,%esp
80109fce:	50                   	push   %eax
80109fcf:	e8 c4 00 00 00       	call   8010a098 <print_mac>
80109fd4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109fd7:	83 ec 0c             	sub    $0xc,%esp
80109fda:	68 60 cc 10 80       	push   $0x8010cc60
80109fdf:	e8 28 64 ff ff       	call   8010040c <cprintf>
80109fe4:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109fe7:	83 ec 0c             	sub    $0xc,%esp
80109fea:	68 90 cc 10 80       	push   $0x8010cc90
80109fef:	e8 18 64 ff ff       	call   8010040c <cprintf>
80109ff4:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80109ffa:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109ffe:	66 3d 00 01          	cmp    $0x100,%ax
8010a002:	75 12                	jne    8010a016 <print_arp_info+0xe1>
8010a004:	83 ec 0c             	sub    $0xc,%esp
8010a007:	68 9c cc 10 80       	push   $0x8010cc9c
8010a00c:	e8 fb 63 ff ff       	call   8010040c <cprintf>
8010a011:	83 c4 10             	add    $0x10,%esp
8010a014:	eb 1d                	jmp    8010a033 <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
8010a016:	8b 45 08             	mov    0x8(%ebp),%eax
8010a019:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a01d:	66 3d 00 02          	cmp    $0x200,%ax
8010a021:	75 10                	jne    8010a033 <print_arp_info+0xfe>
    cprintf("Reply\n");
8010a023:	83 ec 0c             	sub    $0xc,%esp
8010a026:	68 a5 cc 10 80       	push   $0x8010cca5
8010a02b:	e8 dc 63 ff ff       	call   8010040c <cprintf>
8010a030:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010a033:	83 ec 0c             	sub    $0xc,%esp
8010a036:	68 60 cc 10 80       	push   $0x8010cc60
8010a03b:	e8 cc 63 ff ff       	call   8010040c <cprintf>
8010a040:	83 c4 10             	add    $0x10,%esp
}
8010a043:	90                   	nop
8010a044:	c9                   	leave  
8010a045:	c3                   	ret    

8010a046 <print_ipv4>:

void print_ipv4(uchar *ip){
8010a046:	f3 0f 1e fb          	endbr32 
8010a04a:	55                   	push   %ebp
8010a04b:	89 e5                	mov    %esp,%ebp
8010a04d:	53                   	push   %ebx
8010a04e:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
8010a051:	8b 45 08             	mov    0x8(%ebp),%eax
8010a054:	83 c0 03             	add    $0x3,%eax
8010a057:	0f b6 00             	movzbl (%eax),%eax
8010a05a:	0f b6 d8             	movzbl %al,%ebx
8010a05d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a060:	83 c0 02             	add    $0x2,%eax
8010a063:	0f b6 00             	movzbl (%eax),%eax
8010a066:	0f b6 c8             	movzbl %al,%ecx
8010a069:	8b 45 08             	mov    0x8(%ebp),%eax
8010a06c:	83 c0 01             	add    $0x1,%eax
8010a06f:	0f b6 00             	movzbl (%eax),%eax
8010a072:	0f b6 d0             	movzbl %al,%edx
8010a075:	8b 45 08             	mov    0x8(%ebp),%eax
8010a078:	0f b6 00             	movzbl (%eax),%eax
8010a07b:	0f b6 c0             	movzbl %al,%eax
8010a07e:	83 ec 0c             	sub    $0xc,%esp
8010a081:	53                   	push   %ebx
8010a082:	51                   	push   %ecx
8010a083:	52                   	push   %edx
8010a084:	50                   	push   %eax
8010a085:	68 ac cc 10 80       	push   $0x8010ccac
8010a08a:	e8 7d 63 ff ff       	call   8010040c <cprintf>
8010a08f:	83 c4 20             	add    $0x20,%esp
}
8010a092:	90                   	nop
8010a093:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a096:	c9                   	leave  
8010a097:	c3                   	ret    

8010a098 <print_mac>:

void print_mac(uchar *mac){
8010a098:	f3 0f 1e fb          	endbr32 
8010a09c:	55                   	push   %ebp
8010a09d:	89 e5                	mov    %esp,%ebp
8010a09f:	57                   	push   %edi
8010a0a0:	56                   	push   %esi
8010a0a1:	53                   	push   %ebx
8010a0a2:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010a0a5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0a8:	83 c0 05             	add    $0x5,%eax
8010a0ab:	0f b6 00             	movzbl (%eax),%eax
8010a0ae:	0f b6 f8             	movzbl %al,%edi
8010a0b1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0b4:	83 c0 04             	add    $0x4,%eax
8010a0b7:	0f b6 00             	movzbl (%eax),%eax
8010a0ba:	0f b6 f0             	movzbl %al,%esi
8010a0bd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0c0:	83 c0 03             	add    $0x3,%eax
8010a0c3:	0f b6 00             	movzbl (%eax),%eax
8010a0c6:	0f b6 d8             	movzbl %al,%ebx
8010a0c9:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0cc:	83 c0 02             	add    $0x2,%eax
8010a0cf:	0f b6 00             	movzbl (%eax),%eax
8010a0d2:	0f b6 c8             	movzbl %al,%ecx
8010a0d5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d8:	83 c0 01             	add    $0x1,%eax
8010a0db:	0f b6 00             	movzbl (%eax),%eax
8010a0de:	0f b6 d0             	movzbl %al,%edx
8010a0e1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0e4:	0f b6 00             	movzbl (%eax),%eax
8010a0e7:	0f b6 c0             	movzbl %al,%eax
8010a0ea:	83 ec 04             	sub    $0x4,%esp
8010a0ed:	57                   	push   %edi
8010a0ee:	56                   	push   %esi
8010a0ef:	53                   	push   %ebx
8010a0f0:	51                   	push   %ecx
8010a0f1:	52                   	push   %edx
8010a0f2:	50                   	push   %eax
8010a0f3:	68 c4 cc 10 80       	push   $0x8010ccc4
8010a0f8:	e8 0f 63 ff ff       	call   8010040c <cprintf>
8010a0fd:	83 c4 20             	add    $0x20,%esp
}
8010a100:	90                   	nop
8010a101:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010a104:	5b                   	pop    %ebx
8010a105:	5e                   	pop    %esi
8010a106:	5f                   	pop    %edi
8010a107:	5d                   	pop    %ebp
8010a108:	c3                   	ret    

8010a109 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
8010a109:	f3 0f 1e fb          	endbr32 
8010a10d:	55                   	push   %ebp
8010a10e:	89 e5                	mov    %esp,%ebp
8010a110:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
8010a113:	8b 45 08             	mov    0x8(%ebp),%eax
8010a116:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
8010a119:	8b 45 08             	mov    0x8(%ebp),%eax
8010a11c:	83 c0 0e             	add    $0xe,%eax
8010a11f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
8010a122:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a125:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a129:	3c 08                	cmp    $0x8,%al
8010a12b:	75 1b                	jne    8010a148 <eth_proc+0x3f>
8010a12d:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a130:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a134:	3c 06                	cmp    $0x6,%al
8010a136:	75 10                	jne    8010a148 <eth_proc+0x3f>
    arp_proc(pkt_addr);
8010a138:	83 ec 0c             	sub    $0xc,%esp
8010a13b:	ff 75 f0             	pushl  -0x10(%ebp)
8010a13e:	e8 d5 f7 ff ff       	call   80109918 <arp_proc>
8010a143:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
8010a146:	eb 24                	jmp    8010a16c <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
8010a148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a14b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010a14f:	3c 08                	cmp    $0x8,%al
8010a151:	75 19                	jne    8010a16c <eth_proc+0x63>
8010a153:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a156:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a15a:	84 c0                	test   %al,%al
8010a15c:	75 0e                	jne    8010a16c <eth_proc+0x63>
    ipv4_proc(buffer_addr);
8010a15e:	83 ec 0c             	sub    $0xc,%esp
8010a161:	ff 75 08             	pushl  0x8(%ebp)
8010a164:	e8 b3 00 00 00       	call   8010a21c <ipv4_proc>
8010a169:	83 c4 10             	add    $0x10,%esp
}
8010a16c:	90                   	nop
8010a16d:	c9                   	leave  
8010a16e:	c3                   	ret    

8010a16f <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010a16f:	f3 0f 1e fb          	endbr32 
8010a173:	55                   	push   %ebp
8010a174:	89 e5                	mov    %esp,%ebp
8010a176:	83 ec 04             	sub    $0x4,%esp
8010a179:	8b 45 08             	mov    0x8(%ebp),%eax
8010a17c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a180:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a184:	c1 e0 08             	shl    $0x8,%eax
8010a187:	89 c2                	mov    %eax,%edx
8010a189:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a18d:	66 c1 e8 08          	shr    $0x8,%ax
8010a191:	01 d0                	add    %edx,%eax
}
8010a193:	c9                   	leave  
8010a194:	c3                   	ret    

8010a195 <H2N_ushort>:

ushort H2N_ushort(ushort value){
8010a195:	f3 0f 1e fb          	endbr32 
8010a199:	55                   	push   %ebp
8010a19a:	89 e5                	mov    %esp,%ebp
8010a19c:	83 ec 04             	sub    $0x4,%esp
8010a19f:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1a2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010a1a6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a1aa:	c1 e0 08             	shl    $0x8,%eax
8010a1ad:	89 c2                	mov    %eax,%edx
8010a1af:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010a1b3:	66 c1 e8 08          	shr    $0x8,%ax
8010a1b7:	01 d0                	add    %edx,%eax
}
8010a1b9:	c9                   	leave  
8010a1ba:	c3                   	ret    

8010a1bb <H2N_uint>:

uint H2N_uint(uint value){
8010a1bb:	f3 0f 1e fb          	endbr32 
8010a1bf:	55                   	push   %ebp
8010a1c0:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010a1c2:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1c5:	c1 e0 18             	shl    $0x18,%eax
8010a1c8:	25 00 00 00 0f       	and    $0xf000000,%eax
8010a1cd:	89 c2                	mov    %eax,%edx
8010a1cf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1d2:	c1 e0 08             	shl    $0x8,%eax
8010a1d5:	25 00 f0 00 00       	and    $0xf000,%eax
8010a1da:	09 c2                	or     %eax,%edx
8010a1dc:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1df:	c1 e8 08             	shr    $0x8,%eax
8010a1e2:	83 e0 0f             	and    $0xf,%eax
8010a1e5:	01 d0                	add    %edx,%eax
}
8010a1e7:	5d                   	pop    %ebp
8010a1e8:	c3                   	ret    

8010a1e9 <N2H_uint>:

uint N2H_uint(uint value){
8010a1e9:	f3 0f 1e fb          	endbr32 
8010a1ed:	55                   	push   %ebp
8010a1ee:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010a1f0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1f3:	c1 e0 18             	shl    $0x18,%eax
8010a1f6:	89 c2                	mov    %eax,%edx
8010a1f8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1fb:	c1 e0 08             	shl    $0x8,%eax
8010a1fe:	25 00 00 ff 00       	and    $0xff0000,%eax
8010a203:	01 c2                	add    %eax,%edx
8010a205:	8b 45 08             	mov    0x8(%ebp),%eax
8010a208:	c1 e8 08             	shr    $0x8,%eax
8010a20b:	25 00 ff 00 00       	and    $0xff00,%eax
8010a210:	01 c2                	add    %eax,%edx
8010a212:	8b 45 08             	mov    0x8(%ebp),%eax
8010a215:	c1 e8 18             	shr    $0x18,%eax
8010a218:	01 d0                	add    %edx,%eax
}
8010a21a:	5d                   	pop    %ebp
8010a21b:	c3                   	ret    

8010a21c <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a21c:	f3 0f 1e fb          	endbr32 
8010a220:	55                   	push   %ebp
8010a221:	89 e5                	mov    %esp,%ebp
8010a223:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a226:	8b 45 08             	mov    0x8(%ebp),%eax
8010a229:	83 c0 0e             	add    $0xe,%eax
8010a22c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a22f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a232:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a236:	0f b7 d0             	movzwl %ax,%edx
8010a239:	a1 08 f5 10 80       	mov    0x8010f508,%eax
8010a23e:	39 c2                	cmp    %eax,%edx
8010a240:	74 60                	je     8010a2a2 <ipv4_proc+0x86>
8010a242:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a245:	83 c0 0c             	add    $0xc,%eax
8010a248:	83 ec 04             	sub    $0x4,%esp
8010a24b:	6a 04                	push   $0x4
8010a24d:	50                   	push   %eax
8010a24e:	68 04 f5 10 80       	push   $0x8010f504
8010a253:	e8 ba b2 ff ff       	call   80105512 <memcmp>
8010a258:	83 c4 10             	add    $0x10,%esp
8010a25b:	85 c0                	test   %eax,%eax
8010a25d:	74 43                	je     8010a2a2 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
8010a25f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a262:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a266:	0f b7 c0             	movzwl %ax,%eax
8010a269:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a26e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a271:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a275:	3c 01                	cmp    $0x1,%al
8010a277:	75 10                	jne    8010a289 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
8010a279:	83 ec 0c             	sub    $0xc,%esp
8010a27c:	ff 75 08             	pushl  0x8(%ebp)
8010a27f:	e8 a7 00 00 00       	call   8010a32b <icmp_proc>
8010a284:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a287:	eb 19                	jmp    8010a2a2 <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a289:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a28c:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a290:	3c 06                	cmp    $0x6,%al
8010a292:	75 0e                	jne    8010a2a2 <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
8010a294:	83 ec 0c             	sub    $0xc,%esp
8010a297:	ff 75 08             	pushl  0x8(%ebp)
8010a29a:	e8 c7 03 00 00       	call   8010a666 <tcp_proc>
8010a29f:	83 c4 10             	add    $0x10,%esp
}
8010a2a2:	90                   	nop
8010a2a3:	c9                   	leave  
8010a2a4:	c3                   	ret    

8010a2a5 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a2a5:	f3 0f 1e fb          	endbr32 
8010a2a9:	55                   	push   %ebp
8010a2aa:	89 e5                	mov    %esp,%ebp
8010a2ac:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a2af:	8b 45 08             	mov    0x8(%ebp),%eax
8010a2b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a2b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2b8:	0f b6 00             	movzbl (%eax),%eax
8010a2bb:	83 e0 0f             	and    $0xf,%eax
8010a2be:	01 c0                	add    %eax,%eax
8010a2c0:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a2c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a2ca:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a2d1:	eb 48                	jmp    8010a31b <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a2d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a2d6:	01 c0                	add    %eax,%eax
8010a2d8:	89 c2                	mov    %eax,%edx
8010a2da:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2dd:	01 d0                	add    %edx,%eax
8010a2df:	0f b6 00             	movzbl (%eax),%eax
8010a2e2:	0f b6 c0             	movzbl %al,%eax
8010a2e5:	c1 e0 08             	shl    $0x8,%eax
8010a2e8:	89 c2                	mov    %eax,%edx
8010a2ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a2ed:	01 c0                	add    %eax,%eax
8010a2ef:	8d 48 01             	lea    0x1(%eax),%ecx
8010a2f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a2f5:	01 c8                	add    %ecx,%eax
8010a2f7:	0f b6 00             	movzbl (%eax),%eax
8010a2fa:	0f b6 c0             	movzbl %al,%eax
8010a2fd:	01 d0                	add    %edx,%eax
8010a2ff:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a302:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a309:	76 0c                	jbe    8010a317 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a30b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a30e:	0f b7 c0             	movzwl %ax,%eax
8010a311:	83 c0 01             	add    $0x1,%eax
8010a314:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a317:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a31b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a31f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a322:	7c af                	jl     8010a2d3 <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
8010a324:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a327:	f7 d0                	not    %eax
}
8010a329:	c9                   	leave  
8010a32a:	c3                   	ret    

8010a32b <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a32b:	f3 0f 1e fb          	endbr32 
8010a32f:	55                   	push   %ebp
8010a330:	89 e5                	mov    %esp,%ebp
8010a332:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a335:	8b 45 08             	mov    0x8(%ebp),%eax
8010a338:	83 c0 0e             	add    $0xe,%eax
8010a33b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a33e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a341:	0f b6 00             	movzbl (%eax),%eax
8010a344:	0f b6 c0             	movzbl %al,%eax
8010a347:	83 e0 0f             	and    $0xf,%eax
8010a34a:	c1 e0 02             	shl    $0x2,%eax
8010a34d:	89 c2                	mov    %eax,%edx
8010a34f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a352:	01 d0                	add    %edx,%eax
8010a354:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a357:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a35a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a35e:	84 c0                	test   %al,%al
8010a360:	75 4f                	jne    8010a3b1 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a362:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a365:	0f b6 00             	movzbl (%eax),%eax
8010a368:	3c 08                	cmp    $0x8,%al
8010a36a:	75 45                	jne    8010a3b1 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
8010a36c:	e8 19 8a ff ff       	call   80102d8a <kalloc>
8010a371:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a374:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a37b:	83 ec 04             	sub    $0x4,%esp
8010a37e:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a381:	50                   	push   %eax
8010a382:	ff 75 ec             	pushl  -0x14(%ebp)
8010a385:	ff 75 08             	pushl  0x8(%ebp)
8010a388:	e8 7c 00 00 00       	call   8010a409 <icmp_reply_pkt_create>
8010a38d:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a390:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a393:	83 ec 08             	sub    $0x8,%esp
8010a396:	50                   	push   %eax
8010a397:	ff 75 ec             	pushl  -0x14(%ebp)
8010a39a:	e8 43 f4 ff ff       	call   801097e2 <i8254_send>
8010a39f:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a3a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3a5:	83 ec 0c             	sub    $0xc,%esp
8010a3a8:	50                   	push   %eax
8010a3a9:	e8 3e 89 ff ff       	call   80102cec <kfree>
8010a3ae:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a3b1:	90                   	nop
8010a3b2:	c9                   	leave  
8010a3b3:	c3                   	ret    

8010a3b4 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a3b4:	f3 0f 1e fb          	endbr32 
8010a3b8:	55                   	push   %ebp
8010a3b9:	89 e5                	mov    %esp,%ebp
8010a3bb:	53                   	push   %ebx
8010a3bc:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a3bf:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3c2:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a3c6:	0f b7 c0             	movzwl %ax,%eax
8010a3c9:	83 ec 0c             	sub    $0xc,%esp
8010a3cc:	50                   	push   %eax
8010a3cd:	e8 9d fd ff ff       	call   8010a16f <N2H_ushort>
8010a3d2:	83 c4 10             	add    $0x10,%esp
8010a3d5:	0f b7 d8             	movzwl %ax,%ebx
8010a3d8:	8b 45 08             	mov    0x8(%ebp),%eax
8010a3db:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a3df:	0f b7 c0             	movzwl %ax,%eax
8010a3e2:	83 ec 0c             	sub    $0xc,%esp
8010a3e5:	50                   	push   %eax
8010a3e6:	e8 84 fd ff ff       	call   8010a16f <N2H_ushort>
8010a3eb:	83 c4 10             	add    $0x10,%esp
8010a3ee:	0f b7 c0             	movzwl %ax,%eax
8010a3f1:	83 ec 04             	sub    $0x4,%esp
8010a3f4:	53                   	push   %ebx
8010a3f5:	50                   	push   %eax
8010a3f6:	68 e3 cc 10 80       	push   $0x8010cce3
8010a3fb:	e8 0c 60 ff ff       	call   8010040c <cprintf>
8010a400:	83 c4 10             	add    $0x10,%esp
}
8010a403:	90                   	nop
8010a404:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a407:	c9                   	leave  
8010a408:	c3                   	ret    

8010a409 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a409:	f3 0f 1e fb          	endbr32 
8010a40d:	55                   	push   %ebp
8010a40e:	89 e5                	mov    %esp,%ebp
8010a410:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a413:	8b 45 08             	mov    0x8(%ebp),%eax
8010a416:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a419:	8b 45 08             	mov    0x8(%ebp),%eax
8010a41c:	83 c0 0e             	add    $0xe,%eax
8010a41f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a422:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a425:	0f b6 00             	movzbl (%eax),%eax
8010a428:	0f b6 c0             	movzbl %al,%eax
8010a42b:	83 e0 0f             	and    $0xf,%eax
8010a42e:	c1 e0 02             	shl    $0x2,%eax
8010a431:	89 c2                	mov    %eax,%edx
8010a433:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a436:	01 d0                	add    %edx,%eax
8010a438:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a43b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a43e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a441:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a444:	83 c0 0e             	add    $0xe,%eax
8010a447:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a44a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a44d:	83 c0 14             	add    $0x14,%eax
8010a450:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a453:	8b 45 10             	mov    0x10(%ebp),%eax
8010a456:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a45c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a45f:	8d 50 06             	lea    0x6(%eax),%edx
8010a462:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a465:	83 ec 04             	sub    $0x4,%esp
8010a468:	6a 06                	push   $0x6
8010a46a:	52                   	push   %edx
8010a46b:	50                   	push   %eax
8010a46c:	e8 fd b0 ff ff       	call   8010556e <memmove>
8010a471:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a474:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a477:	83 c0 06             	add    $0x6,%eax
8010a47a:	83 ec 04             	sub    $0x4,%esp
8010a47d:	6a 06                	push   $0x6
8010a47f:	68 ac 00 11 80       	push   $0x801100ac
8010a484:	50                   	push   %eax
8010a485:	e8 e4 b0 ff ff       	call   8010556e <memmove>
8010a48a:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a48d:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a490:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a494:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a497:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a49b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a49e:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a4a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4a4:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a4a8:	83 ec 0c             	sub    $0xc,%esp
8010a4ab:	6a 54                	push   $0x54
8010a4ad:	e8 e3 fc ff ff       	call   8010a195 <H2N_ushort>
8010a4b2:	83 c4 10             	add    $0x10,%esp
8010a4b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4b8:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a4bc:	0f b7 15 80 03 11 80 	movzwl 0x80110380,%edx
8010a4c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4c6:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a4ca:	0f b7 05 80 03 11 80 	movzwl 0x80110380,%eax
8010a4d1:	83 c0 01             	add    $0x1,%eax
8010a4d4:	66 a3 80 03 11 80    	mov    %ax,0x80110380
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a4da:	83 ec 0c             	sub    $0xc,%esp
8010a4dd:	68 00 40 00 00       	push   $0x4000
8010a4e2:	e8 ae fc ff ff       	call   8010a195 <H2N_ushort>
8010a4e7:	83 c4 10             	add    $0x10,%esp
8010a4ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a4ed:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a4f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4f4:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a4f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a4fb:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a4ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a502:	83 c0 0c             	add    $0xc,%eax
8010a505:	83 ec 04             	sub    $0x4,%esp
8010a508:	6a 04                	push   $0x4
8010a50a:	68 04 f5 10 80       	push   $0x8010f504
8010a50f:	50                   	push   %eax
8010a510:	e8 59 b0 ff ff       	call   8010556e <memmove>
8010a515:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a51b:	8d 50 0c             	lea    0xc(%eax),%edx
8010a51e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a521:	83 c0 10             	add    $0x10,%eax
8010a524:	83 ec 04             	sub    $0x4,%esp
8010a527:	6a 04                	push   $0x4
8010a529:	52                   	push   %edx
8010a52a:	50                   	push   %eax
8010a52b:	e8 3e b0 ff ff       	call   8010556e <memmove>
8010a530:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a533:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a536:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a53c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a53f:	83 ec 0c             	sub    $0xc,%esp
8010a542:	50                   	push   %eax
8010a543:	e8 5d fd ff ff       	call   8010a2a5 <ipv4_chksum>
8010a548:	83 c4 10             	add    $0x10,%esp
8010a54b:	0f b7 c0             	movzwl %ax,%eax
8010a54e:	83 ec 0c             	sub    $0xc,%esp
8010a551:	50                   	push   %eax
8010a552:	e8 3e fc ff ff       	call   8010a195 <H2N_ushort>
8010a557:	83 c4 10             	add    $0x10,%esp
8010a55a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a55d:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a561:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a564:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a567:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a56a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a56e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a571:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a575:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a578:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a57c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a57f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a583:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a586:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a58a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a58d:	8d 50 08             	lea    0x8(%eax),%edx
8010a590:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a593:	83 c0 08             	add    $0x8,%eax
8010a596:	83 ec 04             	sub    $0x4,%esp
8010a599:	6a 08                	push   $0x8
8010a59b:	52                   	push   %edx
8010a59c:	50                   	push   %eax
8010a59d:	e8 cc af ff ff       	call   8010556e <memmove>
8010a5a2:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a5a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a5a8:	8d 50 10             	lea    0x10(%eax),%edx
8010a5ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5ae:	83 c0 10             	add    $0x10,%eax
8010a5b1:	83 ec 04             	sub    $0x4,%esp
8010a5b4:	6a 30                	push   $0x30
8010a5b6:	52                   	push   %edx
8010a5b7:	50                   	push   %eax
8010a5b8:	e8 b1 af ff ff       	call   8010556e <memmove>
8010a5bd:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a5c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5c3:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a5c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a5cc:	83 ec 0c             	sub    $0xc,%esp
8010a5cf:	50                   	push   %eax
8010a5d0:	e8 1c 00 00 00       	call   8010a5f1 <icmp_chksum>
8010a5d5:	83 c4 10             	add    $0x10,%esp
8010a5d8:	0f b7 c0             	movzwl %ax,%eax
8010a5db:	83 ec 0c             	sub    $0xc,%esp
8010a5de:	50                   	push   %eax
8010a5df:	e8 b1 fb ff ff       	call   8010a195 <H2N_ushort>
8010a5e4:	83 c4 10             	add    $0x10,%esp
8010a5e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a5ea:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a5ee:	90                   	nop
8010a5ef:	c9                   	leave  
8010a5f0:	c3                   	ret    

8010a5f1 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a5f1:	f3 0f 1e fb          	endbr32 
8010a5f5:	55                   	push   %ebp
8010a5f6:	89 e5                	mov    %esp,%ebp
8010a5f8:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a5fb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a5fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a601:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a608:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a60f:	eb 48                	jmp    8010a659 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a611:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a614:	01 c0                	add    %eax,%eax
8010a616:	89 c2                	mov    %eax,%edx
8010a618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a61b:	01 d0                	add    %edx,%eax
8010a61d:	0f b6 00             	movzbl (%eax),%eax
8010a620:	0f b6 c0             	movzbl %al,%eax
8010a623:	c1 e0 08             	shl    $0x8,%eax
8010a626:	89 c2                	mov    %eax,%edx
8010a628:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a62b:	01 c0                	add    %eax,%eax
8010a62d:	8d 48 01             	lea    0x1(%eax),%ecx
8010a630:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a633:	01 c8                	add    %ecx,%eax
8010a635:	0f b6 00             	movzbl (%eax),%eax
8010a638:	0f b6 c0             	movzbl %al,%eax
8010a63b:	01 d0                	add    %edx,%eax
8010a63d:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a640:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a647:	76 0c                	jbe    8010a655 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a649:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a64c:	0f b7 c0             	movzwl %ax,%eax
8010a64f:	83 c0 01             	add    $0x1,%eax
8010a652:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a655:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a659:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a65d:	7e b2                	jle    8010a611 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a662:	f7 d0                	not    %eax
}
8010a664:	c9                   	leave  
8010a665:	c3                   	ret    

8010a666 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a666:	f3 0f 1e fb          	endbr32 
8010a66a:	55                   	push   %ebp
8010a66b:	89 e5                	mov    %esp,%ebp
8010a66d:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a670:	8b 45 08             	mov    0x8(%ebp),%eax
8010a673:	83 c0 0e             	add    $0xe,%eax
8010a676:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a67c:	0f b6 00             	movzbl (%eax),%eax
8010a67f:	0f b6 c0             	movzbl %al,%eax
8010a682:	83 e0 0f             	and    $0xf,%eax
8010a685:	c1 e0 02             	shl    $0x2,%eax
8010a688:	89 c2                	mov    %eax,%edx
8010a68a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a68d:	01 d0                	add    %edx,%eax
8010a68f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a692:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a695:	83 c0 14             	add    $0x14,%eax
8010a698:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a69b:	e8 ea 86 ff ff       	call   80102d8a <kalloc>
8010a6a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a6a3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a6aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6ad:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a6b1:	0f b6 c0             	movzbl %al,%eax
8010a6b4:	83 e0 02             	and    $0x2,%eax
8010a6b7:	85 c0                	test   %eax,%eax
8010a6b9:	74 3d                	je     8010a6f8 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a6bb:	83 ec 0c             	sub    $0xc,%esp
8010a6be:	6a 00                	push   $0x0
8010a6c0:	6a 12                	push   $0x12
8010a6c2:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a6c5:	50                   	push   %eax
8010a6c6:	ff 75 e8             	pushl  -0x18(%ebp)
8010a6c9:	ff 75 08             	pushl  0x8(%ebp)
8010a6cc:	e8 a2 01 00 00       	call   8010a873 <tcp_pkt_create>
8010a6d1:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a6d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a6d7:	83 ec 08             	sub    $0x8,%esp
8010a6da:	50                   	push   %eax
8010a6db:	ff 75 e8             	pushl  -0x18(%ebp)
8010a6de:	e8 ff f0 ff ff       	call   801097e2 <i8254_send>
8010a6e3:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a6e6:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a6eb:	83 c0 01             	add    $0x1,%eax
8010a6ee:	a3 84 03 11 80       	mov    %eax,0x80110384
8010a6f3:	e9 69 01 00 00       	jmp    8010a861 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a6f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6fb:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a6ff:	3c 18                	cmp    $0x18,%al
8010a701:	0f 85 10 01 00 00    	jne    8010a817 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a707:	83 ec 04             	sub    $0x4,%esp
8010a70a:	6a 03                	push   $0x3
8010a70c:	68 fe cc 10 80       	push   $0x8010ccfe
8010a711:	ff 75 ec             	pushl  -0x14(%ebp)
8010a714:	e8 f9 ad ff ff       	call   80105512 <memcmp>
8010a719:	83 c4 10             	add    $0x10,%esp
8010a71c:	85 c0                	test   %eax,%eax
8010a71e:	74 74                	je     8010a794 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a720:	83 ec 0c             	sub    $0xc,%esp
8010a723:	68 02 cd 10 80       	push   $0x8010cd02
8010a728:	e8 df 5c ff ff       	call   8010040c <cprintf>
8010a72d:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a730:	83 ec 0c             	sub    $0xc,%esp
8010a733:	6a 00                	push   $0x0
8010a735:	6a 10                	push   $0x10
8010a737:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a73a:	50                   	push   %eax
8010a73b:	ff 75 e8             	pushl  -0x18(%ebp)
8010a73e:	ff 75 08             	pushl  0x8(%ebp)
8010a741:	e8 2d 01 00 00       	call   8010a873 <tcp_pkt_create>
8010a746:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a749:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a74c:	83 ec 08             	sub    $0x8,%esp
8010a74f:	50                   	push   %eax
8010a750:	ff 75 e8             	pushl  -0x18(%ebp)
8010a753:	e8 8a f0 ff ff       	call   801097e2 <i8254_send>
8010a758:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a75b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a75e:	83 c0 36             	add    $0x36,%eax
8010a761:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a764:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a767:	50                   	push   %eax
8010a768:	ff 75 e0             	pushl  -0x20(%ebp)
8010a76b:	6a 00                	push   $0x0
8010a76d:	6a 00                	push   $0x0
8010a76f:	e8 66 04 00 00       	call   8010abda <http_proc>
8010a774:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a777:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a77a:	83 ec 0c             	sub    $0xc,%esp
8010a77d:	50                   	push   %eax
8010a77e:	6a 18                	push   $0x18
8010a780:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a783:	50                   	push   %eax
8010a784:	ff 75 e8             	pushl  -0x18(%ebp)
8010a787:	ff 75 08             	pushl  0x8(%ebp)
8010a78a:	e8 e4 00 00 00       	call   8010a873 <tcp_pkt_create>
8010a78f:	83 c4 20             	add    $0x20,%esp
8010a792:	eb 62                	jmp    8010a7f6 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a794:	83 ec 0c             	sub    $0xc,%esp
8010a797:	6a 00                	push   $0x0
8010a799:	6a 10                	push   $0x10
8010a79b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a79e:	50                   	push   %eax
8010a79f:	ff 75 e8             	pushl  -0x18(%ebp)
8010a7a2:	ff 75 08             	pushl  0x8(%ebp)
8010a7a5:	e8 c9 00 00 00       	call   8010a873 <tcp_pkt_create>
8010a7aa:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a7ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a7b0:	83 ec 08             	sub    $0x8,%esp
8010a7b3:	50                   	push   %eax
8010a7b4:	ff 75 e8             	pushl  -0x18(%ebp)
8010a7b7:	e8 26 f0 ff ff       	call   801097e2 <i8254_send>
8010a7bc:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a7bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a7c2:	83 c0 36             	add    $0x36,%eax
8010a7c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a7c8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a7cb:	50                   	push   %eax
8010a7cc:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a7cf:	6a 00                	push   $0x0
8010a7d1:	6a 00                	push   $0x0
8010a7d3:	e8 02 04 00 00       	call   8010abda <http_proc>
8010a7d8:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a7db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a7de:	83 ec 0c             	sub    $0xc,%esp
8010a7e1:	50                   	push   %eax
8010a7e2:	6a 18                	push   $0x18
8010a7e4:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a7e7:	50                   	push   %eax
8010a7e8:	ff 75 e8             	pushl  -0x18(%ebp)
8010a7eb:	ff 75 08             	pushl  0x8(%ebp)
8010a7ee:	e8 80 00 00 00       	call   8010a873 <tcp_pkt_create>
8010a7f3:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a7f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a7f9:	83 ec 08             	sub    $0x8,%esp
8010a7fc:	50                   	push   %eax
8010a7fd:	ff 75 e8             	pushl  -0x18(%ebp)
8010a800:	e8 dd ef ff ff       	call   801097e2 <i8254_send>
8010a805:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a808:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a80d:	83 c0 01             	add    $0x1,%eax
8010a810:	a3 84 03 11 80       	mov    %eax,0x80110384
8010a815:	eb 4a                	jmp    8010a861 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a817:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a81a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a81e:	3c 10                	cmp    $0x10,%al
8010a820:	75 3f                	jne    8010a861 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a822:	a1 88 03 11 80       	mov    0x80110388,%eax
8010a827:	83 f8 01             	cmp    $0x1,%eax
8010a82a:	75 35                	jne    8010a861 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a82c:	83 ec 0c             	sub    $0xc,%esp
8010a82f:	6a 00                	push   $0x0
8010a831:	6a 01                	push   $0x1
8010a833:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a836:	50                   	push   %eax
8010a837:	ff 75 e8             	pushl  -0x18(%ebp)
8010a83a:	ff 75 08             	pushl  0x8(%ebp)
8010a83d:	e8 31 00 00 00       	call   8010a873 <tcp_pkt_create>
8010a842:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a845:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a848:	83 ec 08             	sub    $0x8,%esp
8010a84b:	50                   	push   %eax
8010a84c:	ff 75 e8             	pushl  -0x18(%ebp)
8010a84f:	e8 8e ef ff ff       	call   801097e2 <i8254_send>
8010a854:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a857:	c7 05 88 03 11 80 00 	movl   $0x0,0x80110388
8010a85e:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a861:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a864:	83 ec 0c             	sub    $0xc,%esp
8010a867:	50                   	push   %eax
8010a868:	e8 7f 84 ff ff       	call   80102cec <kfree>
8010a86d:	83 c4 10             	add    $0x10,%esp
}
8010a870:	90                   	nop
8010a871:	c9                   	leave  
8010a872:	c3                   	ret    

8010a873 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a873:	f3 0f 1e fb          	endbr32 
8010a877:	55                   	push   %ebp
8010a878:	89 e5                	mov    %esp,%ebp
8010a87a:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a87d:	8b 45 08             	mov    0x8(%ebp),%eax
8010a880:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a883:	8b 45 08             	mov    0x8(%ebp),%eax
8010a886:	83 c0 0e             	add    $0xe,%eax
8010a889:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a88c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a88f:	0f b6 00             	movzbl (%eax),%eax
8010a892:	0f b6 c0             	movzbl %al,%eax
8010a895:	83 e0 0f             	and    $0xf,%eax
8010a898:	c1 e0 02             	shl    $0x2,%eax
8010a89b:	89 c2                	mov    %eax,%edx
8010a89d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a8a0:	01 d0                	add    %edx,%eax
8010a8a2:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a8a5:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a8a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a8ab:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a8ae:	83 c0 0e             	add    $0xe,%eax
8010a8b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a8b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a8b7:	83 c0 14             	add    $0x14,%eax
8010a8ba:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a8bd:	8b 45 18             	mov    0x18(%ebp),%eax
8010a8c0:	8d 50 36             	lea    0x36(%eax),%edx
8010a8c3:	8b 45 10             	mov    0x10(%ebp),%eax
8010a8c6:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a8c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a8cb:	8d 50 06             	lea    0x6(%eax),%edx
8010a8ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8d1:	83 ec 04             	sub    $0x4,%esp
8010a8d4:	6a 06                	push   $0x6
8010a8d6:	52                   	push   %edx
8010a8d7:	50                   	push   %eax
8010a8d8:	e8 91 ac ff ff       	call   8010556e <memmove>
8010a8dd:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a8e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8e3:	83 c0 06             	add    $0x6,%eax
8010a8e6:	83 ec 04             	sub    $0x4,%esp
8010a8e9:	6a 06                	push   $0x6
8010a8eb:	68 ac 00 11 80       	push   $0x801100ac
8010a8f0:	50                   	push   %eax
8010a8f1:	e8 78 ac ff ff       	call   8010556e <memmove>
8010a8f6:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a8f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8fc:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a900:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a903:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a907:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a90a:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a90d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a910:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a914:	8b 45 18             	mov    0x18(%ebp),%eax
8010a917:	83 c0 28             	add    $0x28,%eax
8010a91a:	0f b7 c0             	movzwl %ax,%eax
8010a91d:	83 ec 0c             	sub    $0xc,%esp
8010a920:	50                   	push   %eax
8010a921:	e8 6f f8 ff ff       	call   8010a195 <H2N_ushort>
8010a926:	83 c4 10             	add    $0x10,%esp
8010a929:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a92c:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a930:	0f b7 15 80 03 11 80 	movzwl 0x80110380,%edx
8010a937:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a93a:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a93e:	0f b7 05 80 03 11 80 	movzwl 0x80110380,%eax
8010a945:	83 c0 01             	add    $0x1,%eax
8010a948:	66 a3 80 03 11 80    	mov    %ax,0x80110380
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a94e:	83 ec 0c             	sub    $0xc,%esp
8010a951:	6a 00                	push   $0x0
8010a953:	e8 3d f8 ff ff       	call   8010a195 <H2N_ushort>
8010a958:	83 c4 10             	add    $0x10,%esp
8010a95b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a95e:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a962:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a965:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a969:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a96c:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a970:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a973:	83 c0 0c             	add    $0xc,%eax
8010a976:	83 ec 04             	sub    $0x4,%esp
8010a979:	6a 04                	push   $0x4
8010a97b:	68 04 f5 10 80       	push   $0x8010f504
8010a980:	50                   	push   %eax
8010a981:	e8 e8 ab ff ff       	call   8010556e <memmove>
8010a986:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a98c:	8d 50 0c             	lea    0xc(%eax),%edx
8010a98f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a992:	83 c0 10             	add    $0x10,%eax
8010a995:	83 ec 04             	sub    $0x4,%esp
8010a998:	6a 04                	push   $0x4
8010a99a:	52                   	push   %edx
8010a99b:	50                   	push   %eax
8010a99c:	e8 cd ab ff ff       	call   8010556e <memmove>
8010a9a1:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a9a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a9a7:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a9ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a9b0:	83 ec 0c             	sub    $0xc,%esp
8010a9b3:	50                   	push   %eax
8010a9b4:	e8 ec f8 ff ff       	call   8010a2a5 <ipv4_chksum>
8010a9b9:	83 c4 10             	add    $0x10,%esp
8010a9bc:	0f b7 c0             	movzwl %ax,%eax
8010a9bf:	83 ec 0c             	sub    $0xc,%esp
8010a9c2:	50                   	push   %eax
8010a9c3:	e8 cd f7 ff ff       	call   8010a195 <H2N_ushort>
8010a9c8:	83 c4 10             	add    $0x10,%esp
8010a9cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a9ce:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a9d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a9d5:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a9d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a9dc:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a9df:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a9e2:	0f b7 10             	movzwl (%eax),%edx
8010a9e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a9e8:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a9ec:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a9f1:	83 ec 0c             	sub    $0xc,%esp
8010a9f4:	50                   	push   %eax
8010a9f5:	e8 c1 f7 ff ff       	call   8010a1bb <H2N_uint>
8010a9fa:	83 c4 10             	add    $0x10,%esp
8010a9fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010aa00:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010aa03:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010aa06:	8b 40 04             	mov    0x4(%eax),%eax
8010aa09:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010aa0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aa12:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010aa15:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aa18:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010aa1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aa1f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010aa23:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aa26:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010aa2a:	8b 45 14             	mov    0x14(%ebp),%eax
8010aa2d:	89 c2                	mov    %eax,%edx
8010aa2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aa32:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010aa35:	83 ec 0c             	sub    $0xc,%esp
8010aa38:	68 90 38 00 00       	push   $0x3890
8010aa3d:	e8 53 f7 ff ff       	call   8010a195 <H2N_ushort>
8010aa42:	83 c4 10             	add    $0x10,%esp
8010aa45:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010aa48:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010aa4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aa4f:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010aa55:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010aa58:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010aa5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010aa61:	83 ec 0c             	sub    $0xc,%esp
8010aa64:	50                   	push   %eax
8010aa65:	e8 1f 00 00 00       	call   8010aa89 <tcp_chksum>
8010aa6a:	83 c4 10             	add    $0x10,%esp
8010aa6d:	83 c0 08             	add    $0x8,%eax
8010aa70:	0f b7 c0             	movzwl %ax,%eax
8010aa73:	83 ec 0c             	sub    $0xc,%esp
8010aa76:	50                   	push   %eax
8010aa77:	e8 19 f7 ff ff       	call   8010a195 <H2N_ushort>
8010aa7c:	83 c4 10             	add    $0x10,%esp
8010aa7f:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010aa82:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010aa86:	90                   	nop
8010aa87:	c9                   	leave  
8010aa88:	c3                   	ret    

8010aa89 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010aa89:	f3 0f 1e fb          	endbr32 
8010aa8d:	55                   	push   %ebp
8010aa8e:	89 e5                	mov    %esp,%ebp
8010aa90:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010aa93:	8b 45 08             	mov    0x8(%ebp),%eax
8010aa96:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010aa99:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aa9c:	83 c0 14             	add    $0x14,%eax
8010aa9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010aaa2:	83 ec 04             	sub    $0x4,%esp
8010aaa5:	6a 04                	push   $0x4
8010aaa7:	68 04 f5 10 80       	push   $0x8010f504
8010aaac:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010aaaf:	50                   	push   %eax
8010aab0:	e8 b9 aa ff ff       	call   8010556e <memmove>
8010aab5:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010aab8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aabb:	83 c0 0c             	add    $0xc,%eax
8010aabe:	83 ec 04             	sub    $0x4,%esp
8010aac1:	6a 04                	push   $0x4
8010aac3:	50                   	push   %eax
8010aac4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010aac7:	83 c0 04             	add    $0x4,%eax
8010aaca:	50                   	push   %eax
8010aacb:	e8 9e aa ff ff       	call   8010556e <memmove>
8010aad0:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010aad3:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010aad7:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010aadb:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010aade:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010aae2:	0f b7 c0             	movzwl %ax,%eax
8010aae5:	83 ec 0c             	sub    $0xc,%esp
8010aae8:	50                   	push   %eax
8010aae9:	e8 81 f6 ff ff       	call   8010a16f <N2H_ushort>
8010aaee:	83 c4 10             	add    $0x10,%esp
8010aaf1:	83 e8 14             	sub    $0x14,%eax
8010aaf4:	0f b7 c0             	movzwl %ax,%eax
8010aaf7:	83 ec 0c             	sub    $0xc,%esp
8010aafa:	50                   	push   %eax
8010aafb:	e8 95 f6 ff ff       	call   8010a195 <H2N_ushort>
8010ab00:	83 c4 10             	add    $0x10,%esp
8010ab03:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010ab07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010ab0e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010ab11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010ab14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010ab1b:	eb 33                	jmp    8010ab50 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010ab1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ab20:	01 c0                	add    %eax,%eax
8010ab22:	89 c2                	mov    %eax,%edx
8010ab24:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab27:	01 d0                	add    %edx,%eax
8010ab29:	0f b6 00             	movzbl (%eax),%eax
8010ab2c:	0f b6 c0             	movzbl %al,%eax
8010ab2f:	c1 e0 08             	shl    $0x8,%eax
8010ab32:	89 c2                	mov    %eax,%edx
8010ab34:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ab37:	01 c0                	add    %eax,%eax
8010ab39:	8d 48 01             	lea    0x1(%eax),%ecx
8010ab3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab3f:	01 c8                	add    %ecx,%eax
8010ab41:	0f b6 00             	movzbl (%eax),%eax
8010ab44:	0f b6 c0             	movzbl %al,%eax
8010ab47:	01 d0                	add    %edx,%eax
8010ab49:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010ab4c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010ab50:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010ab54:	7e c7                	jle    8010ab1d <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010ab56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010ab59:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ab5c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010ab63:	eb 33                	jmp    8010ab98 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010ab65:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ab68:	01 c0                	add    %eax,%eax
8010ab6a:	89 c2                	mov    %eax,%edx
8010ab6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab6f:	01 d0                	add    %edx,%eax
8010ab71:	0f b6 00             	movzbl (%eax),%eax
8010ab74:	0f b6 c0             	movzbl %al,%eax
8010ab77:	c1 e0 08             	shl    $0x8,%eax
8010ab7a:	89 c2                	mov    %eax,%edx
8010ab7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010ab7f:	01 c0                	add    %eax,%eax
8010ab81:	8d 48 01             	lea    0x1(%eax),%ecx
8010ab84:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010ab87:	01 c8                	add    %ecx,%eax
8010ab89:	0f b6 00             	movzbl (%eax),%eax
8010ab8c:	0f b6 c0             	movzbl %al,%eax
8010ab8f:	01 d0                	add    %edx,%eax
8010ab91:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010ab94:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010ab98:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010ab9c:	0f b7 c0             	movzwl %ax,%eax
8010ab9f:	83 ec 0c             	sub    $0xc,%esp
8010aba2:	50                   	push   %eax
8010aba3:	e8 c7 f5 ff ff       	call   8010a16f <N2H_ushort>
8010aba8:	83 c4 10             	add    $0x10,%esp
8010abab:	66 d1 e8             	shr    %ax
8010abae:	0f b7 c0             	movzwl %ax,%eax
8010abb1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010abb4:	7c af                	jl     8010ab65 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010abb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010abb9:	c1 e8 10             	shr    $0x10,%eax
8010abbc:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010abbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010abc2:	f7 d0                	not    %eax
}
8010abc4:	c9                   	leave  
8010abc5:	c3                   	ret    

8010abc6 <tcp_fin>:

void tcp_fin(){
8010abc6:	f3 0f 1e fb          	endbr32 
8010abca:	55                   	push   %ebp
8010abcb:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010abcd:	c7 05 88 03 11 80 01 	movl   $0x1,0x80110388
8010abd4:	00 00 00 
}
8010abd7:	90                   	nop
8010abd8:	5d                   	pop    %ebp
8010abd9:	c3                   	ret    

8010abda <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010abda:	f3 0f 1e fb          	endbr32 
8010abde:	55                   	push   %ebp
8010abdf:	89 e5                	mov    %esp,%ebp
8010abe1:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010abe4:	8b 45 10             	mov    0x10(%ebp),%eax
8010abe7:	83 ec 04             	sub    $0x4,%esp
8010abea:	6a 00                	push   $0x0
8010abec:	68 0b cd 10 80       	push   $0x8010cd0b
8010abf1:	50                   	push   %eax
8010abf2:	e8 65 00 00 00       	call   8010ac5c <http_strcpy>
8010abf7:	83 c4 10             	add    $0x10,%esp
8010abfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010abfd:	8b 45 10             	mov    0x10(%ebp),%eax
8010ac00:	83 ec 04             	sub    $0x4,%esp
8010ac03:	ff 75 f4             	pushl  -0xc(%ebp)
8010ac06:	68 1e cd 10 80       	push   $0x8010cd1e
8010ac0b:	50                   	push   %eax
8010ac0c:	e8 4b 00 00 00       	call   8010ac5c <http_strcpy>
8010ac11:	83 c4 10             	add    $0x10,%esp
8010ac14:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010ac17:	8b 45 10             	mov    0x10(%ebp),%eax
8010ac1a:	83 ec 04             	sub    $0x4,%esp
8010ac1d:	ff 75 f4             	pushl  -0xc(%ebp)
8010ac20:	68 39 cd 10 80       	push   $0x8010cd39
8010ac25:	50                   	push   %eax
8010ac26:	e8 31 00 00 00       	call   8010ac5c <http_strcpy>
8010ac2b:	83 c4 10             	add    $0x10,%esp
8010ac2e:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010ac31:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010ac34:	83 e0 01             	and    $0x1,%eax
8010ac37:	85 c0                	test   %eax,%eax
8010ac39:	74 11                	je     8010ac4c <http_proc+0x72>
    char *payload = (char *)send;
8010ac3b:	8b 45 10             	mov    0x10(%ebp),%eax
8010ac3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010ac41:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010ac44:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010ac47:	01 d0                	add    %edx,%eax
8010ac49:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010ac4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010ac4f:	8b 45 14             	mov    0x14(%ebp),%eax
8010ac52:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010ac54:	e8 6d ff ff ff       	call   8010abc6 <tcp_fin>
}
8010ac59:	90                   	nop
8010ac5a:	c9                   	leave  
8010ac5b:	c3                   	ret    

8010ac5c <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010ac5c:	f3 0f 1e fb          	endbr32 
8010ac60:	55                   	push   %ebp
8010ac61:	89 e5                	mov    %esp,%ebp
8010ac63:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010ac66:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010ac6d:	eb 20                	jmp    8010ac8f <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010ac6f:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ac72:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ac75:	01 d0                	add    %edx,%eax
8010ac77:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010ac7a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ac7d:	01 ca                	add    %ecx,%edx
8010ac7f:	89 d1                	mov    %edx,%ecx
8010ac81:	8b 55 08             	mov    0x8(%ebp),%edx
8010ac84:	01 ca                	add    %ecx,%edx
8010ac86:	0f b6 00             	movzbl (%eax),%eax
8010ac89:	88 02                	mov    %al,(%edx)
    i++;
8010ac8b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010ac8f:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010ac92:	8b 45 0c             	mov    0xc(%ebp),%eax
8010ac95:	01 d0                	add    %edx,%eax
8010ac97:	0f b6 00             	movzbl (%eax),%eax
8010ac9a:	84 c0                	test   %al,%al
8010ac9c:	75 d1                	jne    8010ac6f <http_strcpy+0x13>
  }
  return i;
8010ac9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010aca1:	c9                   	leave  
8010aca2:	c3                   	ret    
