
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
80100073:	68 e0 aa 10 80       	push   $0x8010aae0
80100078:	68 a0 13 11 80       	push   $0x801113a0
8010007d:	e8 dc 4f 00 00       	call   8010505e <initlock>
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
801000c1:	68 e7 aa 10 80       	push   $0x8010aae7
801000c6:	50                   	push   %eax
801000c7:	e8 25 4e 00 00       	call   80104ef1 <initsleeplock>
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
80100109:	e8 76 4f 00 00       	call   80105084 <acquire>
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
80100148:	e8 a9 4f 00 00       	call   801050f6 <release>
8010014d:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100153:	83 c0 0c             	add    $0xc,%eax
80100156:	83 ec 0c             	sub    $0xc,%esp
80100159:	50                   	push   %eax
8010015a:	e8 d2 4d 00 00       	call   80104f31 <acquiresleep>
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
801001c9:	e8 28 4f 00 00       	call   801050f6 <release>
801001ce:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	83 c0 0c             	add    $0xc,%eax
801001d7:	83 ec 0c             	sub    $0xc,%esp
801001da:	50                   	push   %eax
801001db:	e8 51 4d 00 00       	call   80104f31 <acquiresleep>
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
801001fd:	68 ee aa 10 80       	push   $0x8010aaee
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
8010025a:	e8 8c 4d 00 00       	call   80104feb <holdingsleep>
8010025f:	83 c4 10             	add    $0x10,%esp
80100262:	85 c0                	test   %eax,%eax
80100264:	75 0d                	jne    80100273 <bwrite+0x2d>
    panic("bwrite");
80100266:	83 ec 0c             	sub    $0xc,%esp
80100269:	68 ff aa 10 80       	push   $0x8010aaff
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
801002a7:	e8 3f 4d 00 00       	call   80104feb <holdingsleep>
801002ac:	83 c4 10             	add    $0x10,%esp
801002af:	85 c0                	test   %eax,%eax
801002b1:	75 0d                	jne    801002c0 <brelse+0x2d>
    panic("brelse");
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	68 06 ab 10 80       	push   $0x8010ab06
801002bb:	e8 05 03 00 00       	call   801005c5 <panic>

  releasesleep(&b->lock);
801002c0:	8b 45 08             	mov    0x8(%ebp),%eax
801002c3:	83 c0 0c             	add    $0xc,%eax
801002c6:	83 ec 0c             	sub    $0xc,%esp
801002c9:	50                   	push   %eax
801002ca:	e8 ca 4c 00 00       	call   80104f99 <releasesleep>
801002cf:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002d2:	83 ec 0c             	sub    $0xc,%esp
801002d5:	68 a0 13 11 80       	push   $0x801113a0
801002da:	e8 a5 4d 00 00       	call   80105084 <acquire>
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
8010034a:	e8 a7 4d 00 00       	call   801050f6 <release>
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
8010042c:	e8 53 4c 00 00       	call   80105084 <acquire>
80100431:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100434:	8b 45 08             	mov    0x8(%ebp),%eax
80100437:	85 c0                	test   %eax,%eax
80100439:	75 0d                	jne    80100448 <cprintf+0x3c>
    panic("null fmt");
8010043b:	83 ec 0c             	sub    $0xc,%esp
8010043e:	68 0d ab 10 80       	push   $0x8010ab0d
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
8010052c:	c7 45 ec 16 ab 10 80 	movl   $0x8010ab16,-0x14(%ebp)
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
801005ba:	e8 37 4b 00 00       	call   801050f6 <release>
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
801005e7:	68 1d ab 10 80       	push   $0x8010ab1d
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
80100606:	68 31 ab 10 80       	push   $0x8010ab31
8010060b:	e8 fc fd ff ff       	call   8010040c <cprintf>
80100610:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100613:	83 ec 08             	sub    $0x8,%esp
80100616:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100619:	50                   	push   %eax
8010061a:	8d 45 08             	lea    0x8(%ebp),%eax
8010061d:	50                   	push   %eax
8010061e:	e8 29 4b 00 00       	call   8010514c <getcallerpcs>
80100623:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100626:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010062d:	eb 1c                	jmp    8010064b <panic+0x86>
    cprintf(" %p", pcs[i]);
8010062f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100632:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100636:	83 ec 08             	sub    $0x8,%esp
80100639:	50                   	push   %eax
8010063a:	68 33 ab 10 80       	push   $0x8010ab33
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
801006c4:	e8 c9 82 00 00       	call   80108992 <graphic_scroll_up>
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
80100717:	e8 76 82 00 00       	call   80108992 <graphic_scroll_up>
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
8010077d:	e8 84 82 00 00       	call   80108a06 <font_render>
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
801007bd:	e8 e4 65 00 00       	call   80106da6 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	6a 20                	push   $0x20
801007ca:	e8 d7 65 00 00       	call   80106da6 <uartputc>
801007cf:	83 c4 10             	add    $0x10,%esp
801007d2:	83 ec 0c             	sub    $0xc,%esp
801007d5:	6a 08                	push   $0x8
801007d7:	e8 ca 65 00 00       	call   80106da6 <uartputc>
801007dc:	83 c4 10             	add    $0x10,%esp
801007df:	eb 0e                	jmp    801007ef <consputc+0x5a>
  } else {
    uartputc(c);
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	ff 75 08             	pushl  0x8(%ebp)
801007e7:	e8 ba 65 00 00       	call   80106da6 <uartputc>
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
80100819:	e8 66 48 00 00       	call   80105084 <acquire>
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
80100992:	e8 5f 47 00 00       	call   801050f6 <release>
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
801009ce:	e8 b1 46 00 00       	call   80105084 <acquire>
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
801009ef:	e8 02 47 00 00       	call   801050f6 <release>
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
80100a9a:	e8 57 46 00 00       	call   801050f6 <release>
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
80100adc:	e8 a3 45 00 00       	call   80105084 <acquire>
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
80100b1e:	e8 d3 45 00 00       	call   801050f6 <release>
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
80100b50:	68 37 ab 10 80       	push   $0x8010ab37
80100b55:	68 20 00 11 80       	push   $0x80110020
80100b5a:	e8 ff 44 00 00       	call   8010505e <initlock>
80100b5f:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b62:	c7 05 4c 67 11 80 bc 	movl   $0x80100abc,0x8011674c
80100b69:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6c:	c7 05 48 67 11 80 a8 	movl   $0x801009a8,0x80116748
80100b73:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b76:	c7 45 f4 3f ab 10 80 	movl   $0x8010ab3f,-0xc(%ebp)
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
80100bf7:	68 55 ab 10 80       	push   $0x8010ab55
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
80100c53:	e8 62 71 00 00       	call   80107dba <setupkvm>
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
80100cf9:	e8 ce 74 00 00       	call   801081cc <allocuvm>
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
80100d3f:	e8 b7 73 00 00       	call   801080fb <loaduvm>
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
80100dae:	e8 19 74 00 00       	call   801081cc <allocuvm>
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
80100dd2:	e8 63 76 00 00       	call   8010843a <clearpteu>
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
80100e0b:	e8 6c 47 00 00       	call   8010557c <strlen>
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
80100e38:	e8 3f 47 00 00       	call   8010557c <strlen>
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
80100e5e:	e8 82 77 00 00       	call   801085e5 <copyout>
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
80100efa:	e8 e6 76 00 00       	call   801085e5 <copyout>
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
80100f48:	e8 e1 45 00 00       	call   8010552e <safestrcpy>
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
80100f8b:	e8 54 6f 00 00       	call   80107ee4 <switchuvm>
80100f90:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f93:	83 ec 0c             	sub    $0xc,%esp
80100f96:	ff 75 cc             	pushl  -0x34(%ebp)
80100f99:	e8 ff 73 00 00       	call   8010839d <freevm>
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
80100fd9:	e8 bf 73 00 00       	call   8010839d <freevm>
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
8010100e:	68 61 ab 10 80       	push   $0x8010ab61
80101013:	68 a0 5d 11 80       	push   $0x80115da0
80101018:	e8 41 40 00 00       	call   8010505e <initlock>
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
80101035:	e8 4a 40 00 00       	call   80105084 <acquire>
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
80101062:	e8 8f 40 00 00       	call   801050f6 <release>
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
80101085:	e8 6c 40 00 00       	call   801050f6 <release>
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
801010a6:	e8 d9 3f 00 00       	call   80105084 <acquire>
801010ab:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 04             	mov    0x4(%eax),%eax
801010b4:	85 c0                	test   %eax,%eax
801010b6:	7f 0d                	jg     801010c5 <filedup+0x31>
    panic("filedup");
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 68 ab 10 80       	push   $0x8010ab68
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
801010dc:	e8 15 40 00 00       	call   801050f6 <release>
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
801010fb:	e8 84 3f 00 00       	call   80105084 <acquire>
80101100:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	8b 40 04             	mov    0x4(%eax),%eax
80101109:	85 c0                	test   %eax,%eax
8010110b:	7f 0d                	jg     8010111a <fileclose+0x31>
    panic("fileclose");
8010110d:	83 ec 0c             	sub    $0xc,%esp
80101110:	68 70 ab 10 80       	push   $0x8010ab70
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
8010113b:	e8 b6 3f 00 00       	call   801050f6 <release>
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
80101189:	e8 68 3f 00 00       	call   801050f6 <release>
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
801012e0:	68 7a ab 10 80       	push   $0x8010ab7a
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
801013e7:	68 83 ab 10 80       	push   $0x8010ab83
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
8010141d:	68 93 ab 10 80       	push   $0x8010ab93
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
80101459:	e8 7c 3f 00 00       	call   801053da <memmove>
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
801014a3:	e8 6b 3e 00 00       	call   80105313 <memset>
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
8010160e:	68 a0 ab 10 80       	push   $0x8010aba0
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
801016a5:	68 b6 ab 10 80       	push   $0x8010abb6
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
8010170d:	68 c9 ab 10 80       	push   $0x8010abc9
80101712:	68 c0 67 11 80       	push   $0x801167c0
80101717:	e8 42 39 00 00       	call   8010505e <initlock>
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
80101743:	68 d0 ab 10 80       	push   $0x8010abd0
80101748:	50                   	push   %eax
80101749:	e8 a3 37 00 00       	call   80104ef1 <initsleeplock>
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
801017a2:	68 d8 ab 10 80       	push   $0x8010abd8
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
8010181f:	e8 ef 3a 00 00       	call   80105313 <memset>
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
80101887:	68 2b ac 10 80       	push   $0x8010ac2b
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
80101931:	e8 a4 3a 00 00       	call   801053da <memmove>
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
8010196a:	e8 15 37 00 00       	call   80105084 <acquire>
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
801019b8:	e8 39 37 00 00       	call   801050f6 <release>
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
801019f4:	68 3d ac 10 80       	push   $0x8010ac3d
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
80101a31:	e8 c0 36 00 00       	call   801050f6 <release>
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
80101a50:	e8 2f 36 00 00       	call   80105084 <acquire>
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
80101a6f:	e8 82 36 00 00       	call   801050f6 <release>
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
80101a99:	68 4d ac 10 80       	push   $0x8010ac4d
80101a9e:	e8 22 eb ff ff       	call   801005c5 <panic>

  acquiresleep(&ip->lock);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	83 c0 0c             	add    $0xc,%eax
80101aa9:	83 ec 0c             	sub    $0xc,%esp
80101aac:	50                   	push   %eax
80101aad:	e8 7f 34 00 00       	call   80104f31 <acquiresleep>
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
80101b57:	e8 7e 38 00 00       	call   801053da <memmove>
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
80101b86:	68 53 ac 10 80       	push   $0x8010ac53
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
80101bad:	e8 39 34 00 00       	call   80104feb <holdingsleep>
80101bb2:	83 c4 10             	add    $0x10,%esp
80101bb5:	85 c0                	test   %eax,%eax
80101bb7:	74 0a                	je     80101bc3 <iunlock+0x30>
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 08             	mov    0x8(%eax),%eax
80101bbf:	85 c0                	test   %eax,%eax
80101bc1:	7f 0d                	jg     80101bd0 <iunlock+0x3d>
    panic("iunlock");
80101bc3:	83 ec 0c             	sub    $0xc,%esp
80101bc6:	68 62 ac 10 80       	push   $0x8010ac62
80101bcb:	e8 f5 e9 ff ff       	call   801005c5 <panic>

  releasesleep(&ip->lock);
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	83 c0 0c             	add    $0xc,%eax
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	50                   	push   %eax
80101bda:	e8 ba 33 00 00       	call   80104f99 <releasesleep>
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
80101bf9:	e8 33 33 00 00       	call   80104f31 <acquiresleep>
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
80101c1f:	e8 60 34 00 00       	call   80105084 <acquire>
80101c24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	68 c0 67 11 80       	push   $0x801167c0
80101c38:	e8 b9 34 00 00       	call   801050f6 <release>
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
80101c7f:	e8 15 33 00 00       	call   80104f99 <releasesleep>
80101c84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101c87:	83 ec 0c             	sub    $0xc,%esp
80101c8a:	68 c0 67 11 80       	push   $0x801167c0
80101c8f:	e8 f0 33 00 00       	call   80105084 <acquire>
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
80101cae:	e8 43 34 00 00       	call   801050f6 <release>
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
80101dfa:	68 6a ac 10 80       	push   $0x8010ac6a
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
801020a4:	e8 31 33 00 00       	call   801053da <memmove>
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
801021f8:	e8 dd 31 00 00       	call   801053da <memmove>
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
8010227c:	e8 f7 31 00 00       	call   80105478 <strncmp>
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
801022a0:	68 7d ac 10 80       	push   $0x8010ac7d
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
801022cf:	68 8f ac 10 80       	push   $0x8010ac8f
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
801023a8:	68 9e ac 10 80       	push   $0x8010ac9e
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
801023e3:	e8 ea 30 00 00       	call   801054d2 <strncpy>
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
8010240f:	68 ab ac 10 80       	push   $0x8010acab
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
80102485:	e8 50 2f 00 00       	call   801053da <memmove>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	eb 26                	jmp    801024b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010248f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102492:	83 ec 04             	sub    $0x4,%esp
80102495:	50                   	push   %eax
80102496:	ff 75 f4             	pushl  -0xc(%ebp)
80102499:	ff 75 0c             	pushl  0xc(%ebp)
8010249c:	e8 39 2f 00 00       	call   801053da <memmove>
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
80102706:	68 b3 ac 10 80       	push   $0x8010acb3
8010270b:	68 60 00 11 80       	push   $0x80110060
80102710:	e8 49 29 00 00       	call   8010505e <initlock>
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
801027b1:	68 b7 ac 10 80       	push   $0x8010acb7
801027b6:	e8 0a de ff ff       	call   801005c5 <panic>
  if(b->blockno >= FSSIZE)
801027bb:	8b 45 08             	mov    0x8(%ebp),%eax
801027be:	8b 40 08             	mov    0x8(%eax),%eax
801027c1:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801027c6:	76 0d                	jbe    801027d5 <idestart+0x37>
    panic("incorrect blockno");
801027c8:	83 ec 0c             	sub    $0xc,%esp
801027cb:	68 c0 ac 10 80       	push   $0x8010acc0
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
8010281e:	68 b7 ac 10 80       	push   $0x8010acb7
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
80102946:	e8 39 27 00 00       	call   80105084 <acquire>
8010294b:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
8010294e:	a1 94 00 11 80       	mov    0x80110094,%eax
80102953:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102956:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010295a:	75 15                	jne    80102971 <ideintr+0x3d>
    release(&idelock);
8010295c:	83 ec 0c             	sub    $0xc,%esp
8010295f:	68 60 00 11 80       	push   $0x80110060
80102964:	e8 8d 27 00 00       	call   801050f6 <release>
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
80102a03:	e8 ee 26 00 00       	call   801050f6 <release>
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
80102a28:	68 d2 ac 10 80       	push   $0x8010acd2
80102a2d:	e8 da d9 ff ff       	call   8010040c <cprintf>
80102a32:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
80102a35:	8b 45 08             	mov    0x8(%ebp),%eax
80102a38:	83 c0 0c             	add    $0xc,%eax
80102a3b:	83 ec 0c             	sub    $0xc,%esp
80102a3e:	50                   	push   %eax
80102a3f:	e8 a7 25 00 00       	call   80104feb <holdingsleep>
80102a44:	83 c4 10             	add    $0x10,%esp
80102a47:	85 c0                	test   %eax,%eax
80102a49:	75 0d                	jne    80102a58 <iderw+0x4b>
    panic("iderw: buf not locked");
80102a4b:	83 ec 0c             	sub    $0xc,%esp
80102a4e:	68 ec ac 10 80       	push   $0x8010acec
80102a53:	e8 6d db ff ff       	call   801005c5 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a58:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5b:	8b 00                	mov    (%eax),%eax
80102a5d:	83 e0 06             	and    $0x6,%eax
80102a60:	83 f8 02             	cmp    $0x2,%eax
80102a63:	75 0d                	jne    80102a72 <iderw+0x65>
    panic("iderw: nothing to do");
80102a65:	83 ec 0c             	sub    $0xc,%esp
80102a68:	68 02 ad 10 80       	push   $0x8010ad02
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
80102a88:	68 17 ad 10 80       	push   $0x8010ad17
80102a8d:	e8 33 db ff ff       	call   801005c5 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a92:	83 ec 0c             	sub    $0xc,%esp
80102a95:	68 60 00 11 80       	push   $0x80110060
80102a9a:	e8 e5 25 00 00       	call   80105084 <acquire>
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
80102b13:	e8 de 25 00 00       	call   801050f6 <release>
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
80102ba3:	68 38 ad 10 80       	push   $0x8010ad38
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
80102c52:	68 6a ad 10 80       	push   $0x8010ad6a
80102c57:	68 20 84 11 80       	push   $0x80118420
80102c5c:	e8 fd 23 00 00       	call   8010505e <initlock>
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
80102d1d:	68 6f ad 10 80       	push   $0x8010ad6f
80102d22:	e8 9e d8 ff ff       	call   801005c5 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d27:	83 ec 04             	sub    $0x4,%esp
80102d2a:	68 00 10 00 00       	push   $0x1000
80102d2f:	6a 01                	push   $0x1
80102d31:	ff 75 08             	pushl  0x8(%ebp)
80102d34:	e8 da 25 00 00       	call   80105313 <memset>
80102d39:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102d3c:	a1 54 84 11 80       	mov    0x80118454,%eax
80102d41:	85 c0                	test   %eax,%eax
80102d43:	74 10                	je     80102d55 <kfree+0x69>
    acquire(&kmem.lock);
80102d45:	83 ec 0c             	sub    $0xc,%esp
80102d48:	68 20 84 11 80       	push   $0x80118420
80102d4d:	e8 32 23 00 00       	call   80105084 <acquire>
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
80102d7f:	e8 72 23 00 00       	call   801050f6 <release>
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
80102da5:	e8 da 22 00 00       	call   80105084 <acquire>
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
80102dd6:	e8 1b 23 00 00       	call   801050f6 <release>
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
8010332b:	e8 4e 20 00 00       	call   8010537e <memcmp>
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
80103443:	68 75 ad 10 80       	push   $0x8010ad75
80103448:	68 60 84 11 80       	push   $0x80118460
8010344d:	e8 0c 1c 00 00       	call   8010505e <initlock>
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
801034fc:	e8 d9 1e 00 00       	call   801053da <memmove>
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
8010367b:	e8 04 1a 00 00       	call   80105084 <acquire>
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
801036ed:	e8 04 1a 00 00       	call   801050f6 <release>
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
80103712:	e8 6d 19 00 00       	call   80105084 <acquire>
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
80103733:	68 79 ad 10 80       	push   $0x8010ad79
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
80103771:	e8 80 19 00 00       	call   801050f6 <release>
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
8010378c:	e8 f3 18 00 00       	call   80105084 <acquire>
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
801037b6:	e8 3b 19 00 00       	call   801050f6 <release>
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
80103836:	e8 9f 1b 00 00       	call   801053da <memmove>
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
801038db:	68 88 ad 10 80       	push   $0x8010ad88
801038e0:	e8 e0 cc ff ff       	call   801005c5 <panic>
  if (log.outstanding < 1)
801038e5:	a1 9c 84 11 80       	mov    0x8011849c,%eax
801038ea:	85 c0                	test   %eax,%eax
801038ec:	7f 0d                	jg     801038fb <log_write+0x49>
    panic("log_write outside of trans");
801038ee:	83 ec 0c             	sub    $0xc,%esp
801038f1:	68 9e ad 10 80       	push   $0x8010ad9e
801038f6:	e8 ca cc ff ff       	call   801005c5 <panic>

  acquire(&log.lock);
801038fb:	83 ec 0c             	sub    $0xc,%esp
801038fe:	68 60 84 11 80       	push   $0x80118460
80103903:	e8 7c 17 00 00       	call   80105084 <acquire>
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
80103981:	e8 70 17 00 00       	call   801050f6 <release>
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
801039bb:	e8 0e 4f 00 00       	call   801088ce <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801039c0:	83 ec 08             	sub    $0x8,%esp
801039c3:	68 00 00 40 80       	push   $0x80400000
801039c8:	68 00 c0 11 80       	push   $0x8011c000
801039cd:	e8 73 f2 ff ff       	call   80102c45 <kinit1>
801039d2:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801039d5:	e8 d1 44 00 00       	call   80107eab <kvmalloc>
  mpinit_uefi();
801039da:	e8 a8 4c 00 00       	call   80108687 <mpinit_uefi>
  lapicinit();     // interrupt controller
801039df:	e8 f0 f5 ff ff       	call   80102fd4 <lapicinit>
  seginit();       // segment descriptors
801039e4:	e8 49 3f 00 00       	call   80107932 <seginit>
  picinit();    // disable pic
801039e9:	e8 a9 01 00 00       	call   80103b97 <picinit>
  ioapicinit();    // another interrupt controller
801039ee:	e8 65 f1 ff ff       	call   80102b58 <ioapicinit>
  consoleinit();   // console hardware
801039f3:	e8 41 d1 ff ff       	call   80100b39 <consoleinit>
  uartinit();      // serial port
801039f8:	e8 be 32 00 00       	call   80106cbb <uartinit>
  pinit();         // process table
801039fd:	e8 e2 05 00 00       	call   80103fe4 <pinit>
  tvinit();        // trap vectors
80103a02:	e8 31 2e 00 00       	call   80106838 <tvinit>
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
80103a30:	e8 0c 51 00 00       	call   80108b41 <pci_init>
  arp_scan();
80103a35:	e8 85 5e 00 00       	call   801098bf <arp_scan>
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
80103a4e:	e8 74 44 00 00       	call   80107ec7 <switchkvm>
  seginit();
80103a53:	e8 da 3e 00 00       	call   80107932 <seginit>
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
80103a7e:	68 b9 ad 10 80       	push   $0x8010adb9
80103a83:	e8 84 c9 ff ff       	call   8010040c <cprintf>
80103a88:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a8b:	e8 22 2f 00 00       	call   801069b2 <idtinit>
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
80103acf:	e8 06 19 00 00       	call   801053da <memmove>
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
80103c60:	68 cd ad 10 80       	push   $0x8010adcd
80103c65:	50                   	push   %eax
80103c66:	e8 f3 13 00 00       	call   8010505e <initlock>
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
80103d29:	e8 56 13 00 00       	call   80105084 <acquire>
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
80103d9c:	e8 55 13 00 00       	call   801050f6 <release>
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
80103dbb:	e8 36 13 00 00       	call   801050f6 <release>
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
80103dd9:	e8 a6 12 00 00       	call   80105084 <acquire>
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
80103e0d:	e8 e4 12 00 00       	call   801050f6 <release>
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
80103ebd:	e8 34 12 00 00       	call   801050f6 <release>
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
80103ede:	e8 a1 11 00 00       	call   80105084 <acquire>
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
80103efb:	e8 f6 11 00 00       	call   801050f6 <release>
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
80103fc0:	e8 31 11 00 00       	call   801050f6 <release>
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
80103ff1:	68 d4 ad 10 80       	push   $0x8010add4
80103ff6:	68 40 85 11 80       	push   $0x80118540
80103ffb:	e8 5e 10 00 00       	call   8010505e <initlock>
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
80104040:	68 dc ad 10 80       	push   $0x8010addc
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
80104095:	68 02 ae 10 80       	push   $0x8010ae02
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
801040ab:	e8 50 11 00 00       	call   80105200 <pushcli>
  c = mycpu();
801040b0:	e8 70 ff ff ff       	call   80104025 <mycpu>
801040b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801040b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bb:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801040c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801040c4:	e8 88 11 00 00       	call   80105251 <popcli>
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
801040e0:	e8 9f 0f 00 00       	call   80105084 <acquire>
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
80104113:	e8 de 0f 00 00       	call   801050f6 <release>
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
8010415d:	e8 94 0f 00 00       	call   801050f6 <release>
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
801041aa:	ba f2 67 10 80       	mov    $0x801067f2,%edx
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
801041cf:	e8 3f 11 00 00       	call   80105313 <memset>
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
80104204:	e8 b1 3b 00 00       	call   80107dba <setupkvm>
80104209:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010420c:	89 42 04             	mov    %eax,0x4(%edx)
8010420f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104212:	8b 40 04             	mov    0x4(%eax),%eax
80104215:	85 c0                	test   %eax,%eax
80104217:	75 0d                	jne    80104226 <userinit+0x3c>
    panic("userinit: out of memory?");
80104219:	83 ec 0c             	sub    $0xc,%esp
8010421c:	68 12 ae 10 80       	push   $0x8010ae12
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
8010423b:	e8 47 3e 00 00       	call   80108087 <inituvm>
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
8010425a:	e8 b4 10 00 00       	call   80105313 <memset>
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
801042d4:	68 2b ae 10 80       	push   $0x8010ae2b
801042d9:	50                   	push   %eax
801042da:	e8 4f 12 00 00       	call   8010552e <safestrcpy>
801042df:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801042e2:	83 ec 0c             	sub    $0xc,%esp
801042e5:	68 34 ae 10 80       	push   $0x8010ae34
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
80104300:	e8 7f 0d 00 00       	call   80105084 <acquire>
80104305:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104312:	83 ec 0c             	sub    $0xc,%esp
80104315:	68 40 85 11 80       	push   $0x80118540
8010431a:	e8 d7 0d 00 00       	call   801050f6 <release>
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
8010435b:	e8 6c 3e 00 00       	call   801081cc <allocuvm>
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
8010438f:	e8 41 3f 00 00       	call   801082d5 <deallocuvm>
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
801043b5:	e8 2a 3b 00 00       	call   80107ee4 <switchuvm>
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
80104401:	e8 79 40 00 00       	call   8010847f <copyuvm>
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
801044fb:	e8 2e 10 00 00       	call   8010552e <safestrcpy>
80104500:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104503:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104506:	8b 40 10             	mov    0x10(%eax),%eax
80104509:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
8010450c:	83 ec 0c             	sub    $0xc,%esp
8010450f:	68 40 85 11 80       	push   $0x80118540
80104514:	e8 6b 0b 00 00       	call   80105084 <acquire>
80104519:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
8010451c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010451f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104526:	83 ec 0c             	sub    $0xc,%esp
80104529:	68 40 85 11 80       	push   $0x80118540
8010452e:	e8 c3 0b 00 00       	call   801050f6 <release>
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
80104560:	68 36 ae 10 80       	push   $0x8010ae36
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
801045e6:	e8 99 0a 00 00       	call   80105084 <acquire>
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
8010466b:	68 43 ae 10 80       	push   $0x8010ae43
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
80104694:	68 36 ae 10 80       	push   $0x8010ae36
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
8010471a:	e8 65 09 00 00       	call   80105084 <acquire>
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
8010479b:	68 43 ae 10 80       	push   $0x8010ae43
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
801047bf:	e8 c0 08 00 00       	call   80105084 <acquire>
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
8010482a:	e8 6e 3b 00 00       	call   8010839d <freevm>
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
80104869:	e8 88 08 00 00       	call   801050f6 <release>
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
801048a3:	e8 4e 08 00 00       	call   801050f6 <release>
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
801048e6:	e8 99 07 00 00       	call   80105084 <acquire>
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
80104955:	e8 43 3a 00 00       	call   8010839d <freevm>
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
8010499c:	e8 44 3c 00 00       	call   801085e5 <copyout>
801049a1:	83 c4 10             	add    $0x10,%esp
801049a4:	85 c0                	test   %eax,%eax
801049a6:	79 17                	jns    801049bf <wait2+0xf3>
          release(&ptable.lock);
801049a8:	83 ec 0c             	sub    $0xc,%esp
801049ab:	68 40 85 11 80       	push   $0x80118540
801049b0:	e8 41 07 00 00       	call   801050f6 <release>
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
801049d1:	e8 20 07 00 00       	call   801050f6 <release>
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
80104a0b:	e8 e6 06 00 00       	call   801050f6 <release>
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
80104a60:	e8 1f 06 00 00       	call   80105084 <acquire>
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
80104a8e:	e8 51 34 00 00       	call   80107ee4 <switchuvm>
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
80104ab1:	e8 f1 0a 00 00       	call   801055a7 <swtch>
80104ab6:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104ab9:	e8 09 34 00 00       	call   80107ec7 <switchkvm>

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
80104ae6:	e8 0b 06 00 00       	call   801050f6 <release>
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
80104b0d:	e8 b9 06 00 00       	call   801051cb <holding>
80104b12:	83 c4 10             	add    $0x10,%esp
80104b15:	85 c0                	test   %eax,%eax
80104b17:	75 0d                	jne    80104b26 <sched+0x33>
    panic("sched ptable.lock");
80104b19:	83 ec 0c             	sub    $0xc,%esp
80104b1c:	68 4f ae 10 80       	push   $0x8010ae4f
80104b21:	e8 9f ba ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli != 1)
80104b26:	e8 fa f4 ff ff       	call   80104025 <mycpu>
80104b2b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104b31:	83 f8 01             	cmp    $0x1,%eax
80104b34:	74 0d                	je     80104b43 <sched+0x50>
    panic("sched locks");
80104b36:	83 ec 0c             	sub    $0xc,%esp
80104b39:	68 61 ae 10 80       	push   $0x8010ae61
80104b3e:	e8 82 ba ff ff       	call   801005c5 <panic>
  if(p->state == RUNNING)
80104b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b46:	8b 40 0c             	mov    0xc(%eax),%eax
80104b49:	83 f8 04             	cmp    $0x4,%eax
80104b4c:	75 0d                	jne    80104b5b <sched+0x68>
    panic("sched running");
80104b4e:	83 ec 0c             	sub    $0xc,%esp
80104b51:	68 6d ae 10 80       	push   $0x8010ae6d
80104b56:	e8 6a ba ff ff       	call   801005c5 <panic>
  if(readeflags()&FL_IF)
80104b5b:	e8 6d f4 ff ff       	call   80103fcd <readeflags>
80104b60:	25 00 02 00 00       	and    $0x200,%eax
80104b65:	85 c0                	test   %eax,%eax
80104b67:	74 0d                	je     80104b76 <sched+0x83>
    panic("sched interruptible");
80104b69:	83 ec 0c             	sub    $0xc,%esp
80104b6c:	68 7b ae 10 80       	push   $0x8010ae7b
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
80104b97:	e8 0b 0a 00 00       	call   801055a7 <swtch>
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
80104bc2:	e8 bd 04 00 00       	call   80105084 <acquire>
80104bc7:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104bca:	e8 d2 f4 ff ff       	call   801040a1 <myproc>
80104bcf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104bd6:	e8 18 ff ff ff       	call   80104af3 <sched>
  release(&ptable.lock);
80104bdb:	83 ec 0c             	sub    $0xc,%esp
80104bde:	68 40 85 11 80       	push   $0x80118540
80104be3:	e8 0e 05 00 00       	call   801050f6 <release>
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
80104c00:	e8 f1 04 00 00       	call   801050f6 <release>
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
80104c53:	68 8f ae 10 80       	push   $0x8010ae8f
80104c58:	e8 68 b9 ff ff       	call   801005c5 <panic>

  if(lk == 0)
80104c5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c61:	75 0d                	jne    80104c70 <sleep+0x38>
    panic("sleep without lk");
80104c63:	83 ec 0c             	sub    $0xc,%esp
80104c66:	68 95 ae 10 80       	push   $0x8010ae95
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
80104c81:	e8 fe 03 00 00       	call   80105084 <acquire>
80104c86:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104c89:	83 ec 0c             	sub    $0xc,%esp
80104c8c:	ff 75 0c             	pushl  0xc(%ebp)
80104c8f:	e8 62 04 00 00       	call   801050f6 <release>
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
80104cca:	e8 27 04 00 00       	call   801050f6 <release>
80104ccf:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104cd2:	83 ec 0c             	sub    $0xc,%esp
80104cd5:	ff 75 0c             	pushl  0xc(%ebp)
80104cd8:	e8 a7 03 00 00       	call   80105084 <acquire>
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
80104d3c:	e8 43 03 00 00       	call   80105084 <acquire>
80104d41:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104d44:	83 ec 0c             	sub    $0xc,%esp
80104d47:	ff 75 08             	pushl  0x8(%ebp)
80104d4a:	e8 94 ff ff ff       	call   80104ce3 <wakeup1>
80104d4f:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104d52:	83 ec 0c             	sub    $0xc,%esp
80104d55:	68 40 85 11 80       	push   $0x80118540
80104d5a:	e8 97 03 00 00       	call   801050f6 <release>
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
80104d77:	e8 08 03 00 00       	call   80105084 <acquire>
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
80104dba:	e8 37 03 00 00       	call   801050f6 <release>
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
80104de1:	e8 10 03 00 00       	call   801050f6 <release>
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
80104e42:	c7 45 ec a6 ae 10 80 	movl   $0x8010aea6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104e49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e4c:	8d 50 6c             	lea    0x6c(%eax),%edx
80104e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e52:	8b 40 10             	mov    0x10(%eax),%eax
80104e55:	52                   	push   %edx
80104e56:	ff 75 ec             	pushl  -0x14(%ebp)
80104e59:	50                   	push   %eax
80104e5a:	68 aa ae 10 80       	push   $0x8010aeaa
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
80104e88:	e8 bf 02 00 00       	call   8010514c <getcallerpcs>
80104e8d:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104e90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e97:	eb 1c                	jmp    80104eb5 <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104e99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104ea0:	83 ec 08             	sub    $0x8,%esp
80104ea3:	50                   	push   %eax
80104ea4:	68 b3 ae 10 80       	push   $0x8010aeb3
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
80104ec9:	68 b7 ae 10 80       	push   $0x8010aeb7
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

80104ef1 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104ef1:	f3 0f 1e fb          	endbr32 
80104ef5:	55                   	push   %ebp
80104ef6:	89 e5                	mov    %esp,%ebp
80104ef8:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104efb:	8b 45 08             	mov    0x8(%ebp),%eax
80104efe:	83 c0 04             	add    $0x4,%eax
80104f01:	83 ec 08             	sub    $0x8,%esp
80104f04:	68 e3 ae 10 80       	push   $0x8010aee3
80104f09:	50                   	push   %eax
80104f0a:	e8 4f 01 00 00       	call   8010505e <initlock>
80104f0f:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104f12:	8b 45 08             	mov    0x8(%ebp),%eax
80104f15:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f18:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104f24:	8b 45 08             	mov    0x8(%ebp),%eax
80104f27:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104f2e:	90                   	nop
80104f2f:	c9                   	leave  
80104f30:	c3                   	ret    

80104f31 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104f31:	f3 0f 1e fb          	endbr32 
80104f35:	55                   	push   %ebp
80104f36:	89 e5                	mov    %esp,%ebp
80104f38:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3e:	83 c0 04             	add    $0x4,%eax
80104f41:	83 ec 0c             	sub    $0xc,%esp
80104f44:	50                   	push   %eax
80104f45:	e8 3a 01 00 00       	call   80105084 <acquire>
80104f4a:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104f4d:	eb 15                	jmp    80104f64 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104f52:	83 c0 04             	add    $0x4,%eax
80104f55:	83 ec 08             	sub    $0x8,%esp
80104f58:	50                   	push   %eax
80104f59:	ff 75 08             	pushl  0x8(%ebp)
80104f5c:	e8 d7 fc ff ff       	call   80104c38 <sleep>
80104f61:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104f64:	8b 45 08             	mov    0x8(%ebp),%eax
80104f67:	8b 00                	mov    (%eax),%eax
80104f69:	85 c0                	test   %eax,%eax
80104f6b:	75 e2                	jne    80104f4f <acquiresleep+0x1e>
  }
  lk->locked = 1;
80104f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80104f70:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104f76:	e8 26 f1 ff ff       	call   801040a1 <myproc>
80104f7b:	8b 50 10             	mov    0x10(%eax),%edx
80104f7e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f81:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104f84:	8b 45 08             	mov    0x8(%ebp),%eax
80104f87:	83 c0 04             	add    $0x4,%eax
80104f8a:	83 ec 0c             	sub    $0xc,%esp
80104f8d:	50                   	push   %eax
80104f8e:	e8 63 01 00 00       	call   801050f6 <release>
80104f93:	83 c4 10             	add    $0x10,%esp
}
80104f96:	90                   	nop
80104f97:	c9                   	leave  
80104f98:	c3                   	ret    

80104f99 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104f99:	f3 0f 1e fb          	endbr32 
80104f9d:	55                   	push   %ebp
80104f9e:	89 e5                	mov    %esp,%ebp
80104fa0:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa6:	83 c0 04             	add    $0x4,%eax
80104fa9:	83 ec 0c             	sub    $0xc,%esp
80104fac:	50                   	push   %eax
80104fad:	e8 d2 00 00 00       	call   80105084 <acquire>
80104fb2:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc1:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104fc8:	83 ec 0c             	sub    $0xc,%esp
80104fcb:	ff 75 08             	pushl  0x8(%ebp)
80104fce:	e8 57 fd ff ff       	call   80104d2a <wakeup>
80104fd3:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd9:	83 c0 04             	add    $0x4,%eax
80104fdc:	83 ec 0c             	sub    $0xc,%esp
80104fdf:	50                   	push   %eax
80104fe0:	e8 11 01 00 00       	call   801050f6 <release>
80104fe5:	83 c4 10             	add    $0x10,%esp
}
80104fe8:	90                   	nop
80104fe9:	c9                   	leave  
80104fea:	c3                   	ret    

80104feb <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104feb:	f3 0f 1e fb          	endbr32 
80104fef:	55                   	push   %ebp
80104ff0:	89 e5                	mov    %esp,%ebp
80104ff2:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff8:	83 c0 04             	add    $0x4,%eax
80104ffb:	83 ec 0c             	sub    $0xc,%esp
80104ffe:	50                   	push   %eax
80104fff:	e8 80 00 00 00       	call   80105084 <acquire>
80105004:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80105007:	8b 45 08             	mov    0x8(%ebp),%eax
8010500a:	8b 00                	mov    (%eax),%eax
8010500c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010500f:	8b 45 08             	mov    0x8(%ebp),%eax
80105012:	83 c0 04             	add    $0x4,%eax
80105015:	83 ec 0c             	sub    $0xc,%esp
80105018:	50                   	push   %eax
80105019:	e8 d8 00 00 00       	call   801050f6 <release>
8010501e:	83 c4 10             	add    $0x10,%esp
  return r;
80105021:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105024:	c9                   	leave  
80105025:	c3                   	ret    

80105026 <readeflags>:
{
80105026:	55                   	push   %ebp
80105027:	89 e5                	mov    %esp,%ebp
80105029:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010502c:	9c                   	pushf  
8010502d:	58                   	pop    %eax
8010502e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105031:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105034:	c9                   	leave  
80105035:	c3                   	ret    

80105036 <cli>:
{
80105036:	55                   	push   %ebp
80105037:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105039:	fa                   	cli    
}
8010503a:	90                   	nop
8010503b:	5d                   	pop    %ebp
8010503c:	c3                   	ret    

8010503d <sti>:
{
8010503d:	55                   	push   %ebp
8010503e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105040:	fb                   	sti    
}
80105041:	90                   	nop
80105042:	5d                   	pop    %ebp
80105043:	c3                   	ret    

80105044 <xchg>:
{
80105044:	55                   	push   %ebp
80105045:	89 e5                	mov    %esp,%ebp
80105047:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010504a:	8b 55 08             	mov    0x8(%ebp),%edx
8010504d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105050:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105053:	f0 87 02             	lock xchg %eax,(%edx)
80105056:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105059:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010505c:	c9                   	leave  
8010505d:	c3                   	ret    

8010505e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010505e:	f3 0f 1e fb          	endbr32 
80105062:	55                   	push   %ebp
80105063:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105065:	8b 45 08             	mov    0x8(%ebp),%eax
80105068:	8b 55 0c             	mov    0xc(%ebp),%edx
8010506b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010506e:	8b 45 08             	mov    0x8(%ebp),%eax
80105071:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105077:	8b 45 08             	mov    0x8(%ebp),%eax
8010507a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105081:	90                   	nop
80105082:	5d                   	pop    %ebp
80105083:	c3                   	ret    

80105084 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105084:	f3 0f 1e fb          	endbr32 
80105088:	55                   	push   %ebp
80105089:	89 e5                	mov    %esp,%ebp
8010508b:	53                   	push   %ebx
8010508c:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010508f:	e8 6c 01 00 00       	call   80105200 <pushcli>
  if(holding(lk)){
80105094:	8b 45 08             	mov    0x8(%ebp),%eax
80105097:	83 ec 0c             	sub    $0xc,%esp
8010509a:	50                   	push   %eax
8010509b:	e8 2b 01 00 00       	call   801051cb <holding>
801050a0:	83 c4 10             	add    $0x10,%esp
801050a3:	85 c0                	test   %eax,%eax
801050a5:	74 0d                	je     801050b4 <acquire+0x30>
    panic("acquire");
801050a7:	83 ec 0c             	sub    $0xc,%esp
801050aa:	68 ee ae 10 80       	push   $0x8010aeee
801050af:	e8 11 b5 ff ff       	call   801005c5 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801050b4:	90                   	nop
801050b5:	8b 45 08             	mov    0x8(%ebp),%eax
801050b8:	83 ec 08             	sub    $0x8,%esp
801050bb:	6a 01                	push   $0x1
801050bd:	50                   	push   %eax
801050be:	e8 81 ff ff ff       	call   80105044 <xchg>
801050c3:	83 c4 10             	add    $0x10,%esp
801050c6:	85 c0                	test   %eax,%eax
801050c8:	75 eb                	jne    801050b5 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801050ca:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801050cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
801050d2:	e8 4e ef ff ff       	call   80104025 <mycpu>
801050d7:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801050da:	8b 45 08             	mov    0x8(%ebp),%eax
801050dd:	83 c0 0c             	add    $0xc,%eax
801050e0:	83 ec 08             	sub    $0x8,%esp
801050e3:	50                   	push   %eax
801050e4:	8d 45 08             	lea    0x8(%ebp),%eax
801050e7:	50                   	push   %eax
801050e8:	e8 5f 00 00 00       	call   8010514c <getcallerpcs>
801050ed:	83 c4 10             	add    $0x10,%esp
}
801050f0:	90                   	nop
801050f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050f4:	c9                   	leave  
801050f5:	c3                   	ret    

801050f6 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050f6:	f3 0f 1e fb          	endbr32 
801050fa:	55                   	push   %ebp
801050fb:	89 e5                	mov    %esp,%ebp
801050fd:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105100:	83 ec 0c             	sub    $0xc,%esp
80105103:	ff 75 08             	pushl  0x8(%ebp)
80105106:	e8 c0 00 00 00       	call   801051cb <holding>
8010510b:	83 c4 10             	add    $0x10,%esp
8010510e:	85 c0                	test   %eax,%eax
80105110:	75 0d                	jne    8010511f <release+0x29>
    panic("release");
80105112:	83 ec 0c             	sub    $0xc,%esp
80105115:	68 f6 ae 10 80       	push   $0x8010aef6
8010511a:	e8 a6 b4 ff ff       	call   801005c5 <panic>

  lk->pcs[0] = 0;
8010511f:	8b 45 08             	mov    0x8(%ebp),%eax
80105122:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105129:	8b 45 08             	mov    0x8(%ebp),%eax
8010512c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105133:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105138:	8b 45 08             	mov    0x8(%ebp),%eax
8010513b:	8b 55 08             	mov    0x8(%ebp),%edx
8010513e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105144:	e8 08 01 00 00       	call   80105251 <popcli>
}
80105149:	90                   	nop
8010514a:	c9                   	leave  
8010514b:	c3                   	ret    

8010514c <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010514c:	f3 0f 1e fb          	endbr32 
80105150:	55                   	push   %ebp
80105151:	89 e5                	mov    %esp,%ebp
80105153:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105156:	8b 45 08             	mov    0x8(%ebp),%eax
80105159:	83 e8 08             	sub    $0x8,%eax
8010515c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010515f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105166:	eb 38                	jmp    801051a0 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105168:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010516c:	74 53                	je     801051c1 <getcallerpcs+0x75>
8010516e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105175:	76 4a                	jbe    801051c1 <getcallerpcs+0x75>
80105177:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010517b:	74 44                	je     801051c1 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010517d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105180:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105187:	8b 45 0c             	mov    0xc(%ebp),%eax
8010518a:	01 c2                	add    %eax,%edx
8010518c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010518f:	8b 40 04             	mov    0x4(%eax),%eax
80105192:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105194:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105197:	8b 00                	mov    (%eax),%eax
80105199:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010519c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051a0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051a4:	7e c2                	jle    80105168 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801051a6:	eb 19                	jmp    801051c1 <getcallerpcs+0x75>
    pcs[i] = 0;
801051a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801051b5:	01 d0                	add    %edx,%eax
801051b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801051bd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051c1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051c5:	7e e1                	jle    801051a8 <getcallerpcs+0x5c>
}
801051c7:	90                   	nop
801051c8:	90                   	nop
801051c9:	c9                   	leave  
801051ca:	c3                   	ret    

801051cb <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051cb:	f3 0f 1e fb          	endbr32 
801051cf:	55                   	push   %ebp
801051d0:	89 e5                	mov    %esp,%ebp
801051d2:	53                   	push   %ebx
801051d3:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801051d6:	8b 45 08             	mov    0x8(%ebp),%eax
801051d9:	8b 00                	mov    (%eax),%eax
801051db:	85 c0                	test   %eax,%eax
801051dd:	74 16                	je     801051f5 <holding+0x2a>
801051df:	8b 45 08             	mov    0x8(%ebp),%eax
801051e2:	8b 58 08             	mov    0x8(%eax),%ebx
801051e5:	e8 3b ee ff ff       	call   80104025 <mycpu>
801051ea:	39 c3                	cmp    %eax,%ebx
801051ec:	75 07                	jne    801051f5 <holding+0x2a>
801051ee:	b8 01 00 00 00       	mov    $0x1,%eax
801051f3:	eb 05                	jmp    801051fa <holding+0x2f>
801051f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051fa:	83 c4 04             	add    $0x4,%esp
801051fd:	5b                   	pop    %ebx
801051fe:	5d                   	pop    %ebp
801051ff:	c3                   	ret    

80105200 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105200:	f3 0f 1e fb          	endbr32 
80105204:	55                   	push   %ebp
80105205:	89 e5                	mov    %esp,%ebp
80105207:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010520a:	e8 17 fe ff ff       	call   80105026 <readeflags>
8010520f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105212:	e8 1f fe ff ff       	call   80105036 <cli>
  if(mycpu()->ncli == 0)
80105217:	e8 09 ee ff ff       	call   80104025 <mycpu>
8010521c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105222:	85 c0                	test   %eax,%eax
80105224:	75 14                	jne    8010523a <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105226:	e8 fa ed ff ff       	call   80104025 <mycpu>
8010522b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010522e:	81 e2 00 02 00 00    	and    $0x200,%edx
80105234:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010523a:	e8 e6 ed ff ff       	call   80104025 <mycpu>
8010523f:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105245:	83 c2 01             	add    $0x1,%edx
80105248:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010524e:	90                   	nop
8010524f:	c9                   	leave  
80105250:	c3                   	ret    

80105251 <popcli>:

void
popcli(void)
{
80105251:	f3 0f 1e fb          	endbr32 
80105255:	55                   	push   %ebp
80105256:	89 e5                	mov    %esp,%ebp
80105258:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010525b:	e8 c6 fd ff ff       	call   80105026 <readeflags>
80105260:	25 00 02 00 00       	and    $0x200,%eax
80105265:	85 c0                	test   %eax,%eax
80105267:	74 0d                	je     80105276 <popcli+0x25>
    panic("popcli - interruptible");
80105269:	83 ec 0c             	sub    $0xc,%esp
8010526c:	68 fe ae 10 80       	push   $0x8010aefe
80105271:	e8 4f b3 ff ff       	call   801005c5 <panic>
  if(--mycpu()->ncli < 0)
80105276:	e8 aa ed ff ff       	call   80104025 <mycpu>
8010527b:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105281:	83 ea 01             	sub    $0x1,%edx
80105284:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010528a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105290:	85 c0                	test   %eax,%eax
80105292:	79 0d                	jns    801052a1 <popcli+0x50>
    panic("popcli");
80105294:	83 ec 0c             	sub    $0xc,%esp
80105297:	68 15 af 10 80       	push   $0x8010af15
8010529c:	e8 24 b3 ff ff       	call   801005c5 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801052a1:	e8 7f ed ff ff       	call   80104025 <mycpu>
801052a6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052ac:	85 c0                	test   %eax,%eax
801052ae:	75 14                	jne    801052c4 <popcli+0x73>
801052b0:	e8 70 ed ff ff       	call   80104025 <mycpu>
801052b5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801052bb:	85 c0                	test   %eax,%eax
801052bd:	74 05                	je     801052c4 <popcli+0x73>
    sti();
801052bf:	e8 79 fd ff ff       	call   8010503d <sti>
}
801052c4:	90                   	nop
801052c5:	c9                   	leave  
801052c6:	c3                   	ret    

801052c7 <stosb>:
{
801052c7:	55                   	push   %ebp
801052c8:	89 e5                	mov    %esp,%ebp
801052ca:	57                   	push   %edi
801052cb:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052cf:	8b 55 10             	mov    0x10(%ebp),%edx
801052d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d5:	89 cb                	mov    %ecx,%ebx
801052d7:	89 df                	mov    %ebx,%edi
801052d9:	89 d1                	mov    %edx,%ecx
801052db:	fc                   	cld    
801052dc:	f3 aa                	rep stos %al,%es:(%edi)
801052de:	89 ca                	mov    %ecx,%edx
801052e0:	89 fb                	mov    %edi,%ebx
801052e2:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052e5:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052e8:	90                   	nop
801052e9:	5b                   	pop    %ebx
801052ea:	5f                   	pop    %edi
801052eb:	5d                   	pop    %ebp
801052ec:	c3                   	ret    

801052ed <stosl>:
{
801052ed:	55                   	push   %ebp
801052ee:	89 e5                	mov    %esp,%ebp
801052f0:	57                   	push   %edi
801052f1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052f5:	8b 55 10             	mov    0x10(%ebp),%edx
801052f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801052fb:	89 cb                	mov    %ecx,%ebx
801052fd:	89 df                	mov    %ebx,%edi
801052ff:	89 d1                	mov    %edx,%ecx
80105301:	fc                   	cld    
80105302:	f3 ab                	rep stos %eax,%es:(%edi)
80105304:	89 ca                	mov    %ecx,%edx
80105306:	89 fb                	mov    %edi,%ebx
80105308:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010530b:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010530e:	90                   	nop
8010530f:	5b                   	pop    %ebx
80105310:	5f                   	pop    %edi
80105311:	5d                   	pop    %ebp
80105312:	c3                   	ret    

80105313 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105313:	f3 0f 1e fb          	endbr32 
80105317:	55                   	push   %ebp
80105318:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010531a:	8b 45 08             	mov    0x8(%ebp),%eax
8010531d:	83 e0 03             	and    $0x3,%eax
80105320:	85 c0                	test   %eax,%eax
80105322:	75 43                	jne    80105367 <memset+0x54>
80105324:	8b 45 10             	mov    0x10(%ebp),%eax
80105327:	83 e0 03             	and    $0x3,%eax
8010532a:	85 c0                	test   %eax,%eax
8010532c:	75 39                	jne    80105367 <memset+0x54>
    c &= 0xFF;
8010532e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105335:	8b 45 10             	mov    0x10(%ebp),%eax
80105338:	c1 e8 02             	shr    $0x2,%eax
8010533b:	89 c1                	mov    %eax,%ecx
8010533d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105340:	c1 e0 18             	shl    $0x18,%eax
80105343:	89 c2                	mov    %eax,%edx
80105345:	8b 45 0c             	mov    0xc(%ebp),%eax
80105348:	c1 e0 10             	shl    $0x10,%eax
8010534b:	09 c2                	or     %eax,%edx
8010534d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105350:	c1 e0 08             	shl    $0x8,%eax
80105353:	09 d0                	or     %edx,%eax
80105355:	0b 45 0c             	or     0xc(%ebp),%eax
80105358:	51                   	push   %ecx
80105359:	50                   	push   %eax
8010535a:	ff 75 08             	pushl  0x8(%ebp)
8010535d:	e8 8b ff ff ff       	call   801052ed <stosl>
80105362:	83 c4 0c             	add    $0xc,%esp
80105365:	eb 12                	jmp    80105379 <memset+0x66>
  } else
    stosb(dst, c, n);
80105367:	8b 45 10             	mov    0x10(%ebp),%eax
8010536a:	50                   	push   %eax
8010536b:	ff 75 0c             	pushl  0xc(%ebp)
8010536e:	ff 75 08             	pushl  0x8(%ebp)
80105371:	e8 51 ff ff ff       	call   801052c7 <stosb>
80105376:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105379:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010537c:	c9                   	leave  
8010537d:	c3                   	ret    

8010537e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010537e:	f3 0f 1e fb          	endbr32 
80105382:	55                   	push   %ebp
80105383:	89 e5                	mov    %esp,%ebp
80105385:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105388:	8b 45 08             	mov    0x8(%ebp),%eax
8010538b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010538e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105391:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105394:	eb 30                	jmp    801053c6 <memcmp+0x48>
    if(*s1 != *s2)
80105396:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105399:	0f b6 10             	movzbl (%eax),%edx
8010539c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010539f:	0f b6 00             	movzbl (%eax),%eax
801053a2:	38 c2                	cmp    %al,%dl
801053a4:	74 18                	je     801053be <memcmp+0x40>
      return *s1 - *s2;
801053a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053a9:	0f b6 00             	movzbl (%eax),%eax
801053ac:	0f b6 d0             	movzbl %al,%edx
801053af:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b2:	0f b6 00             	movzbl (%eax),%eax
801053b5:	0f b6 c0             	movzbl %al,%eax
801053b8:	29 c2                	sub    %eax,%edx
801053ba:	89 d0                	mov    %edx,%eax
801053bc:	eb 1a                	jmp    801053d8 <memcmp+0x5a>
    s1++, s2++;
801053be:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053c2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801053c6:	8b 45 10             	mov    0x10(%ebp),%eax
801053c9:	8d 50 ff             	lea    -0x1(%eax),%edx
801053cc:	89 55 10             	mov    %edx,0x10(%ebp)
801053cf:	85 c0                	test   %eax,%eax
801053d1:	75 c3                	jne    80105396 <memcmp+0x18>
  }

  return 0;
801053d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053d8:	c9                   	leave  
801053d9:	c3                   	ret    

801053da <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053da:	f3 0f 1e fb          	endbr32 
801053de:	55                   	push   %ebp
801053df:	89 e5                	mov    %esp,%ebp
801053e1:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053ea:	8b 45 08             	mov    0x8(%ebp),%eax
801053ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053f6:	73 54                	jae    8010544c <memmove+0x72>
801053f8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053fb:	8b 45 10             	mov    0x10(%ebp),%eax
801053fe:	01 d0                	add    %edx,%eax
80105400:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105403:	73 47                	jae    8010544c <memmove+0x72>
    s += n;
80105405:	8b 45 10             	mov    0x10(%ebp),%eax
80105408:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010540b:	8b 45 10             	mov    0x10(%ebp),%eax
8010540e:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105411:	eb 13                	jmp    80105426 <memmove+0x4c>
      *--d = *--s;
80105413:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105417:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010541b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010541e:	0f b6 10             	movzbl (%eax),%edx
80105421:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105424:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105426:	8b 45 10             	mov    0x10(%ebp),%eax
80105429:	8d 50 ff             	lea    -0x1(%eax),%edx
8010542c:	89 55 10             	mov    %edx,0x10(%ebp)
8010542f:	85 c0                	test   %eax,%eax
80105431:	75 e0                	jne    80105413 <memmove+0x39>
  if(s < d && s + n > d){
80105433:	eb 24                	jmp    80105459 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105435:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105438:	8d 42 01             	lea    0x1(%edx),%eax
8010543b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010543e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105441:	8d 48 01             	lea    0x1(%eax),%ecx
80105444:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105447:	0f b6 12             	movzbl (%edx),%edx
8010544a:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010544c:	8b 45 10             	mov    0x10(%ebp),%eax
8010544f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105452:	89 55 10             	mov    %edx,0x10(%ebp)
80105455:	85 c0                	test   %eax,%eax
80105457:	75 dc                	jne    80105435 <memmove+0x5b>

  return dst;
80105459:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010545c:	c9                   	leave  
8010545d:	c3                   	ret    

8010545e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010545e:	f3 0f 1e fb          	endbr32 
80105462:	55                   	push   %ebp
80105463:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105465:	ff 75 10             	pushl  0x10(%ebp)
80105468:	ff 75 0c             	pushl  0xc(%ebp)
8010546b:	ff 75 08             	pushl  0x8(%ebp)
8010546e:	e8 67 ff ff ff       	call   801053da <memmove>
80105473:	83 c4 0c             	add    $0xc,%esp
}
80105476:	c9                   	leave  
80105477:	c3                   	ret    

80105478 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105478:	f3 0f 1e fb          	endbr32 
8010547c:	55                   	push   %ebp
8010547d:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010547f:	eb 0c                	jmp    8010548d <strncmp+0x15>
    n--, p++, q++;
80105481:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105485:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105489:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010548d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105491:	74 1a                	je     801054ad <strncmp+0x35>
80105493:	8b 45 08             	mov    0x8(%ebp),%eax
80105496:	0f b6 00             	movzbl (%eax),%eax
80105499:	84 c0                	test   %al,%al
8010549b:	74 10                	je     801054ad <strncmp+0x35>
8010549d:	8b 45 08             	mov    0x8(%ebp),%eax
801054a0:	0f b6 10             	movzbl (%eax),%edx
801054a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a6:	0f b6 00             	movzbl (%eax),%eax
801054a9:	38 c2                	cmp    %al,%dl
801054ab:	74 d4                	je     80105481 <strncmp+0x9>
  if(n == 0)
801054ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054b1:	75 07                	jne    801054ba <strncmp+0x42>
    return 0;
801054b3:	b8 00 00 00 00       	mov    $0x0,%eax
801054b8:	eb 16                	jmp    801054d0 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
801054ba:	8b 45 08             	mov    0x8(%ebp),%eax
801054bd:	0f b6 00             	movzbl (%eax),%eax
801054c0:	0f b6 d0             	movzbl %al,%edx
801054c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801054c6:	0f b6 00             	movzbl (%eax),%eax
801054c9:	0f b6 c0             	movzbl %al,%eax
801054cc:	29 c2                	sub    %eax,%edx
801054ce:	89 d0                	mov    %edx,%eax
}
801054d0:	5d                   	pop    %ebp
801054d1:	c3                   	ret    

801054d2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054d2:	f3 0f 1e fb          	endbr32 
801054d6:	55                   	push   %ebp
801054d7:	89 e5                	mov    %esp,%ebp
801054d9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801054dc:	8b 45 08             	mov    0x8(%ebp),%eax
801054df:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054e2:	90                   	nop
801054e3:	8b 45 10             	mov    0x10(%ebp),%eax
801054e6:	8d 50 ff             	lea    -0x1(%eax),%edx
801054e9:	89 55 10             	mov    %edx,0x10(%ebp)
801054ec:	85 c0                	test   %eax,%eax
801054ee:	7e 2c                	jle    8010551c <strncpy+0x4a>
801054f0:	8b 55 0c             	mov    0xc(%ebp),%edx
801054f3:	8d 42 01             	lea    0x1(%edx),%eax
801054f6:	89 45 0c             	mov    %eax,0xc(%ebp)
801054f9:	8b 45 08             	mov    0x8(%ebp),%eax
801054fc:	8d 48 01             	lea    0x1(%eax),%ecx
801054ff:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105502:	0f b6 12             	movzbl (%edx),%edx
80105505:	88 10                	mov    %dl,(%eax)
80105507:	0f b6 00             	movzbl (%eax),%eax
8010550a:	84 c0                	test   %al,%al
8010550c:	75 d5                	jne    801054e3 <strncpy+0x11>
    ;
  while(n-- > 0)
8010550e:	eb 0c                	jmp    8010551c <strncpy+0x4a>
    *s++ = 0;
80105510:	8b 45 08             	mov    0x8(%ebp),%eax
80105513:	8d 50 01             	lea    0x1(%eax),%edx
80105516:	89 55 08             	mov    %edx,0x8(%ebp)
80105519:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010551c:	8b 45 10             	mov    0x10(%ebp),%eax
8010551f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105522:	89 55 10             	mov    %edx,0x10(%ebp)
80105525:	85 c0                	test   %eax,%eax
80105527:	7f e7                	jg     80105510 <strncpy+0x3e>
  return os;
80105529:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010552c:	c9                   	leave  
8010552d:	c3                   	ret    

8010552e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010552e:	f3 0f 1e fb          	endbr32 
80105532:	55                   	push   %ebp
80105533:	89 e5                	mov    %esp,%ebp
80105535:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105538:	8b 45 08             	mov    0x8(%ebp),%eax
8010553b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010553e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105542:	7f 05                	jg     80105549 <safestrcpy+0x1b>
    return os;
80105544:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105547:	eb 31                	jmp    8010557a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105549:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010554d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105551:	7e 1e                	jle    80105571 <safestrcpy+0x43>
80105553:	8b 55 0c             	mov    0xc(%ebp),%edx
80105556:	8d 42 01             	lea    0x1(%edx),%eax
80105559:	89 45 0c             	mov    %eax,0xc(%ebp)
8010555c:	8b 45 08             	mov    0x8(%ebp),%eax
8010555f:	8d 48 01             	lea    0x1(%eax),%ecx
80105562:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105565:	0f b6 12             	movzbl (%edx),%edx
80105568:	88 10                	mov    %dl,(%eax)
8010556a:	0f b6 00             	movzbl (%eax),%eax
8010556d:	84 c0                	test   %al,%al
8010556f:	75 d8                	jne    80105549 <safestrcpy+0x1b>
    ;
  *s = 0;
80105571:	8b 45 08             	mov    0x8(%ebp),%eax
80105574:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105577:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010557a:	c9                   	leave  
8010557b:	c3                   	ret    

8010557c <strlen>:

int
strlen(const char *s)
{
8010557c:	f3 0f 1e fb          	endbr32 
80105580:	55                   	push   %ebp
80105581:	89 e5                	mov    %esp,%ebp
80105583:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105586:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010558d:	eb 04                	jmp    80105593 <strlen+0x17>
8010558f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105593:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105596:	8b 45 08             	mov    0x8(%ebp),%eax
80105599:	01 d0                	add    %edx,%eax
8010559b:	0f b6 00             	movzbl (%eax),%eax
8010559e:	84 c0                	test   %al,%al
801055a0:	75 ed                	jne    8010558f <strlen+0x13>
    ;
  return n;
801055a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055a5:	c9                   	leave  
801055a6:	c3                   	ret    

801055a7 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801055a7:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055ab:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055af:	55                   	push   %ebp
  pushl %ebx
801055b0:	53                   	push   %ebx
  pushl %esi
801055b1:	56                   	push   %esi
  pushl %edi
801055b2:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055b3:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055b5:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055b7:	5f                   	pop    %edi
  popl %esi
801055b8:	5e                   	pop    %esi
  popl %ebx
801055b9:	5b                   	pop    %ebx
  popl %ebp
801055ba:	5d                   	pop    %ebp
  ret
801055bb:	c3                   	ret    

801055bc <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801055bc:	f3 0f 1e fb          	endbr32 
801055c0:	55                   	push   %ebp
801055c1:	89 e5                	mov    %esp,%ebp
801055c3:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801055c6:	e8 d6 ea ff ff       	call   801040a1 <myproc>
801055cb:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801055ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d1:	8b 00                	mov    (%eax),%eax
801055d3:	39 45 08             	cmp    %eax,0x8(%ebp)
801055d6:	73 0f                	jae    801055e7 <fetchint+0x2b>
801055d8:	8b 45 08             	mov    0x8(%ebp),%eax
801055db:	8d 50 04             	lea    0x4(%eax),%edx
801055de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e1:	8b 00                	mov    (%eax),%eax
801055e3:	39 c2                	cmp    %eax,%edx
801055e5:	76 07                	jbe    801055ee <fetchint+0x32>
    return -1;
801055e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ec:	eb 0f                	jmp    801055fd <fetchint+0x41>
  *ip = *(int*)(addr);
801055ee:	8b 45 08             	mov    0x8(%ebp),%eax
801055f1:	8b 10                	mov    (%eax),%edx
801055f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f6:	89 10                	mov    %edx,(%eax)
  return 0;
801055f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055fd:	c9                   	leave  
801055fe:	c3                   	ret    

801055ff <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801055ff:	f3 0f 1e fb          	endbr32 
80105603:	55                   	push   %ebp
80105604:	89 e5                	mov    %esp,%ebp
80105606:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105609:	e8 93 ea ff ff       	call   801040a1 <myproc>
8010560e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105614:	8b 00                	mov    (%eax),%eax
80105616:	39 45 08             	cmp    %eax,0x8(%ebp)
80105619:	72 07                	jb     80105622 <fetchstr+0x23>
    return -1;
8010561b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105620:	eb 43                	jmp    80105665 <fetchstr+0x66>
  *pp = (char*)addr;
80105622:	8b 55 08             	mov    0x8(%ebp),%edx
80105625:	8b 45 0c             	mov    0xc(%ebp),%eax
80105628:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010562a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010562d:	8b 00                	mov    (%eax),%eax
8010562f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105632:	8b 45 0c             	mov    0xc(%ebp),%eax
80105635:	8b 00                	mov    (%eax),%eax
80105637:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010563a:	eb 1c                	jmp    80105658 <fetchstr+0x59>
    if(*s == 0)
8010563c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010563f:	0f b6 00             	movzbl (%eax),%eax
80105642:	84 c0                	test   %al,%al
80105644:	75 0e                	jne    80105654 <fetchstr+0x55>
      return s - *pp;
80105646:	8b 45 0c             	mov    0xc(%ebp),%eax
80105649:	8b 00                	mov    (%eax),%eax
8010564b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010564e:	29 c2                	sub    %eax,%edx
80105650:	89 d0                	mov    %edx,%eax
80105652:	eb 11                	jmp    80105665 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80105654:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010565b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010565e:	72 dc                	jb     8010563c <fetchstr+0x3d>
  }
  return -1;
80105660:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105665:	c9                   	leave  
80105666:	c3                   	ret    

80105667 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105667:	f3 0f 1e fb          	endbr32 
8010566b:	55                   	push   %ebp
8010566c:	89 e5                	mov    %esp,%ebp
8010566e:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105671:	e8 2b ea ff ff       	call   801040a1 <myproc>
80105676:	8b 40 18             	mov    0x18(%eax),%eax
80105679:	8b 40 44             	mov    0x44(%eax),%eax
8010567c:	8b 55 08             	mov    0x8(%ebp),%edx
8010567f:	c1 e2 02             	shl    $0x2,%edx
80105682:	01 d0                	add    %edx,%eax
80105684:	83 c0 04             	add    $0x4,%eax
80105687:	83 ec 08             	sub    $0x8,%esp
8010568a:	ff 75 0c             	pushl  0xc(%ebp)
8010568d:	50                   	push   %eax
8010568e:	e8 29 ff ff ff       	call   801055bc <fetchint>
80105693:	83 c4 10             	add    $0x10,%esp
}
80105696:	c9                   	leave  
80105697:	c3                   	ret    

80105698 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105698:	f3 0f 1e fb          	endbr32 
8010569c:	55                   	push   %ebp
8010569d:	89 e5                	mov    %esp,%ebp
8010569f:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801056a2:	e8 fa e9 ff ff       	call   801040a1 <myproc>
801056a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801056aa:	83 ec 08             	sub    $0x8,%esp
801056ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056b0:	50                   	push   %eax
801056b1:	ff 75 08             	pushl  0x8(%ebp)
801056b4:	e8 ae ff ff ff       	call   80105667 <argint>
801056b9:	83 c4 10             	add    $0x10,%esp
801056bc:	85 c0                	test   %eax,%eax
801056be:	79 07                	jns    801056c7 <argptr+0x2f>
    return -1;
801056c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c5:	eb 3b                	jmp    80105702 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801056c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056cb:	78 1f                	js     801056ec <argptr+0x54>
801056cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056d0:	8b 00                	mov    (%eax),%eax
801056d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801056d5:	39 d0                	cmp    %edx,%eax
801056d7:	76 13                	jbe    801056ec <argptr+0x54>
801056d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056dc:	89 c2                	mov    %eax,%edx
801056de:	8b 45 10             	mov    0x10(%ebp),%eax
801056e1:	01 c2                	add    %eax,%edx
801056e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e6:	8b 00                	mov    (%eax),%eax
801056e8:	39 c2                	cmp    %eax,%edx
801056ea:	76 07                	jbe    801056f3 <argptr+0x5b>
    return -1;
801056ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f1:	eb 0f                	jmp    80105702 <argptr+0x6a>
  *pp = (char*)i;
801056f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f6:	89 c2                	mov    %eax,%edx
801056f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801056fb:	89 10                	mov    %edx,(%eax)
  return 0;
801056fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105702:	c9                   	leave  
80105703:	c3                   	ret    

80105704 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105704:	f3 0f 1e fb          	endbr32 
80105708:	55                   	push   %ebp
80105709:	89 e5                	mov    %esp,%ebp
8010570b:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010570e:	83 ec 08             	sub    $0x8,%esp
80105711:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105714:	50                   	push   %eax
80105715:	ff 75 08             	pushl  0x8(%ebp)
80105718:	e8 4a ff ff ff       	call   80105667 <argint>
8010571d:	83 c4 10             	add    $0x10,%esp
80105720:	85 c0                	test   %eax,%eax
80105722:	79 07                	jns    8010572b <argstr+0x27>
    return -1;
80105724:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105729:	eb 12                	jmp    8010573d <argstr+0x39>
  return fetchstr(addr, pp);
8010572b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010572e:	83 ec 08             	sub    $0x8,%esp
80105731:	ff 75 0c             	pushl  0xc(%ebp)
80105734:	50                   	push   %eax
80105735:	e8 c5 fe ff ff       	call   801055ff <fetchstr>
8010573a:	83 c4 10             	add    $0x10,%esp
}
8010573d:	c9                   	leave  
8010573e:	c3                   	ret    

8010573f <syscall>:
[SYS_uthread_init]   sys_uthread_init,
};

void
syscall(void)
{
8010573f:	f3 0f 1e fb          	endbr32 
80105743:	55                   	push   %ebp
80105744:	89 e5                	mov    %esp,%ebp
80105746:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105749:	e8 53 e9 ff ff       	call   801040a1 <myproc>
8010574e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105754:	8b 40 18             	mov    0x18(%eax),%eax
80105757:	8b 40 1c             	mov    0x1c(%eax),%eax
8010575a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010575d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105761:	7e 2f                	jle    80105792 <syscall+0x53>
80105763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105766:	83 f8 18             	cmp    $0x18,%eax
80105769:	77 27                	ja     80105792 <syscall+0x53>
8010576b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010576e:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105775:	85 c0                	test   %eax,%eax
80105777:	74 19                	je     80105792 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010577c:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80105783:	ff d0                	call   *%eax
80105785:	89 c2                	mov    %eax,%edx
80105787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578a:	8b 40 18             	mov    0x18(%eax),%eax
8010578d:	89 50 1c             	mov    %edx,0x1c(%eax)
80105790:	eb 2c                	jmp    801057be <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105795:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579b:	8b 40 10             	mov    0x10(%eax),%eax
8010579e:	ff 75 f0             	pushl  -0x10(%ebp)
801057a1:	52                   	push   %edx
801057a2:	50                   	push   %eax
801057a3:	68 1c af 10 80       	push   $0x8010af1c
801057a8:	e8 5f ac ff ff       	call   8010040c <cprintf>
801057ad:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801057b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b3:	8b 40 18             	mov    0x18(%eax),%eax
801057b6:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801057bd:	90                   	nop
801057be:	90                   	nop
801057bf:	c9                   	leave  
801057c0:	c3                   	ret    

801057c1 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801057c1:	f3 0f 1e fb          	endbr32 
801057c5:	55                   	push   %ebp
801057c6:	89 e5                	mov    %esp,%ebp
801057c8:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801057cb:	83 ec 08             	sub    $0x8,%esp
801057ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057d1:	50                   	push   %eax
801057d2:	ff 75 08             	pushl  0x8(%ebp)
801057d5:	e8 8d fe ff ff       	call   80105667 <argint>
801057da:	83 c4 10             	add    $0x10,%esp
801057dd:	85 c0                	test   %eax,%eax
801057df:	79 07                	jns    801057e8 <argfd+0x27>
    return -1;
801057e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057e6:	eb 4f                	jmp    80105837 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801057e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057eb:	85 c0                	test   %eax,%eax
801057ed:	78 20                	js     8010580f <argfd+0x4e>
801057ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f2:	83 f8 0f             	cmp    $0xf,%eax
801057f5:	7f 18                	jg     8010580f <argfd+0x4e>
801057f7:	e8 a5 e8 ff ff       	call   801040a1 <myproc>
801057fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057ff:	83 c2 08             	add    $0x8,%edx
80105802:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105806:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105809:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010580d:	75 07                	jne    80105816 <argfd+0x55>
    return -1;
8010580f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105814:	eb 21                	jmp    80105837 <argfd+0x76>
  if(pfd)
80105816:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010581a:	74 08                	je     80105824 <argfd+0x63>
    *pfd = fd;
8010581c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010581f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105822:	89 10                	mov    %edx,(%eax)
  if(pf)
80105824:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105828:	74 08                	je     80105832 <argfd+0x71>
    *pf = f;
8010582a:	8b 45 10             	mov    0x10(%ebp),%eax
8010582d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105830:	89 10                	mov    %edx,(%eax)
  return 0;
80105832:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105837:	c9                   	leave  
80105838:	c3                   	ret    

80105839 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105839:	f3 0f 1e fb          	endbr32 
8010583d:	55                   	push   %ebp
8010583e:	89 e5                	mov    %esp,%ebp
80105840:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105843:	e8 59 e8 ff ff       	call   801040a1 <myproc>
80105848:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
8010584b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105852:	eb 2a                	jmp    8010587e <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105854:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105857:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010585a:	83 c2 08             	add    $0x8,%edx
8010585d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105861:	85 c0                	test   %eax,%eax
80105863:	75 15                	jne    8010587a <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105865:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105868:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010586b:	8d 4a 08             	lea    0x8(%edx),%ecx
8010586e:	8b 55 08             	mov    0x8(%ebp),%edx
80105871:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105878:	eb 0f                	jmp    80105889 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
8010587a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010587e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105882:	7e d0                	jle    80105854 <fdalloc+0x1b>
    }
  }
  return -1;
80105884:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105889:	c9                   	leave  
8010588a:	c3                   	ret    

8010588b <sys_dup>:

int
sys_dup(void)
{
8010588b:	f3 0f 1e fb          	endbr32 
8010588f:	55                   	push   %ebp
80105890:	89 e5                	mov    %esp,%ebp
80105892:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105895:	83 ec 04             	sub    $0x4,%esp
80105898:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010589b:	50                   	push   %eax
8010589c:	6a 00                	push   $0x0
8010589e:	6a 00                	push   $0x0
801058a0:	e8 1c ff ff ff       	call   801057c1 <argfd>
801058a5:	83 c4 10             	add    $0x10,%esp
801058a8:	85 c0                	test   %eax,%eax
801058aa:	79 07                	jns    801058b3 <sys_dup+0x28>
    return -1;
801058ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b1:	eb 31                	jmp    801058e4 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
801058b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b6:	83 ec 0c             	sub    $0xc,%esp
801058b9:	50                   	push   %eax
801058ba:	e8 7a ff ff ff       	call   80105839 <fdalloc>
801058bf:	83 c4 10             	add    $0x10,%esp
801058c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058c9:	79 07                	jns    801058d2 <sys_dup+0x47>
    return -1;
801058cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d0:	eb 12                	jmp    801058e4 <sys_dup+0x59>
  filedup(f);
801058d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d5:	83 ec 0c             	sub    $0xc,%esp
801058d8:	50                   	push   %eax
801058d9:	e8 b6 b7 ff ff       	call   80101094 <filedup>
801058de:	83 c4 10             	add    $0x10,%esp
  return fd;
801058e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058e4:	c9                   	leave  
801058e5:	c3                   	ret    

801058e6 <sys_read>:

int
sys_read(void)
{
801058e6:	f3 0f 1e fb          	endbr32 
801058ea:	55                   	push   %ebp
801058eb:	89 e5                	mov    %esp,%ebp
801058ed:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058f0:	83 ec 04             	sub    $0x4,%esp
801058f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058f6:	50                   	push   %eax
801058f7:	6a 00                	push   $0x0
801058f9:	6a 00                	push   $0x0
801058fb:	e8 c1 fe ff ff       	call   801057c1 <argfd>
80105900:	83 c4 10             	add    $0x10,%esp
80105903:	85 c0                	test   %eax,%eax
80105905:	78 2e                	js     80105935 <sys_read+0x4f>
80105907:	83 ec 08             	sub    $0x8,%esp
8010590a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010590d:	50                   	push   %eax
8010590e:	6a 02                	push   $0x2
80105910:	e8 52 fd ff ff       	call   80105667 <argint>
80105915:	83 c4 10             	add    $0x10,%esp
80105918:	85 c0                	test   %eax,%eax
8010591a:	78 19                	js     80105935 <sys_read+0x4f>
8010591c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010591f:	83 ec 04             	sub    $0x4,%esp
80105922:	50                   	push   %eax
80105923:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105926:	50                   	push   %eax
80105927:	6a 01                	push   $0x1
80105929:	e8 6a fd ff ff       	call   80105698 <argptr>
8010592e:	83 c4 10             	add    $0x10,%esp
80105931:	85 c0                	test   %eax,%eax
80105933:	79 07                	jns    8010593c <sys_read+0x56>
    return -1;
80105935:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010593a:	eb 17                	jmp    80105953 <sys_read+0x6d>
  return fileread(f, p, n);
8010593c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010593f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105945:	83 ec 04             	sub    $0x4,%esp
80105948:	51                   	push   %ecx
80105949:	52                   	push   %edx
8010594a:	50                   	push   %eax
8010594b:	e8 e0 b8 ff ff       	call   80101230 <fileread>
80105950:	83 c4 10             	add    $0x10,%esp
}
80105953:	c9                   	leave  
80105954:	c3                   	ret    

80105955 <sys_write>:

int
sys_write(void)
{
80105955:	f3 0f 1e fb          	endbr32 
80105959:	55                   	push   %ebp
8010595a:	89 e5                	mov    %esp,%ebp
8010595c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010595f:	83 ec 04             	sub    $0x4,%esp
80105962:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105965:	50                   	push   %eax
80105966:	6a 00                	push   $0x0
80105968:	6a 00                	push   $0x0
8010596a:	e8 52 fe ff ff       	call   801057c1 <argfd>
8010596f:	83 c4 10             	add    $0x10,%esp
80105972:	85 c0                	test   %eax,%eax
80105974:	78 2e                	js     801059a4 <sys_write+0x4f>
80105976:	83 ec 08             	sub    $0x8,%esp
80105979:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010597c:	50                   	push   %eax
8010597d:	6a 02                	push   $0x2
8010597f:	e8 e3 fc ff ff       	call   80105667 <argint>
80105984:	83 c4 10             	add    $0x10,%esp
80105987:	85 c0                	test   %eax,%eax
80105989:	78 19                	js     801059a4 <sys_write+0x4f>
8010598b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010598e:	83 ec 04             	sub    $0x4,%esp
80105991:	50                   	push   %eax
80105992:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105995:	50                   	push   %eax
80105996:	6a 01                	push   $0x1
80105998:	e8 fb fc ff ff       	call   80105698 <argptr>
8010599d:	83 c4 10             	add    $0x10,%esp
801059a0:	85 c0                	test   %eax,%eax
801059a2:	79 07                	jns    801059ab <sys_write+0x56>
    return -1;
801059a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a9:	eb 17                	jmp    801059c2 <sys_write+0x6d>
  return filewrite(f, p, n);
801059ab:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059ae:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b4:	83 ec 04             	sub    $0x4,%esp
801059b7:	51                   	push   %ecx
801059b8:	52                   	push   %edx
801059b9:	50                   	push   %eax
801059ba:	e8 2d b9 ff ff       	call   801012ec <filewrite>
801059bf:	83 c4 10             	add    $0x10,%esp
}
801059c2:	c9                   	leave  
801059c3:	c3                   	ret    

801059c4 <sys_close>:

int
sys_close(void)
{
801059c4:	f3 0f 1e fb          	endbr32 
801059c8:	55                   	push   %ebp
801059c9:	89 e5                	mov    %esp,%ebp
801059cb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801059ce:	83 ec 04             	sub    $0x4,%esp
801059d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059d4:	50                   	push   %eax
801059d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059d8:	50                   	push   %eax
801059d9:	6a 00                	push   $0x0
801059db:	e8 e1 fd ff ff       	call   801057c1 <argfd>
801059e0:	83 c4 10             	add    $0x10,%esp
801059e3:	85 c0                	test   %eax,%eax
801059e5:	79 07                	jns    801059ee <sys_close+0x2a>
    return -1;
801059e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ec:	eb 27                	jmp    80105a15 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
801059ee:	e8 ae e6 ff ff       	call   801040a1 <myproc>
801059f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059f6:	83 c2 08             	add    $0x8,%edx
801059f9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105a00:	00 
  fileclose(f);
80105a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a04:	83 ec 0c             	sub    $0xc,%esp
80105a07:	50                   	push   %eax
80105a08:	e8 dc b6 ff ff       	call   801010e9 <fileclose>
80105a0d:	83 c4 10             	add    $0x10,%esp
  return 0;
80105a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a15:	c9                   	leave  
80105a16:	c3                   	ret    

80105a17 <sys_fstat>:

int
sys_fstat(void)
{
80105a17:	f3 0f 1e fb          	endbr32 
80105a1b:	55                   	push   %ebp
80105a1c:	89 e5                	mov    %esp,%ebp
80105a1e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a21:	83 ec 04             	sub    $0x4,%esp
80105a24:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a27:	50                   	push   %eax
80105a28:	6a 00                	push   $0x0
80105a2a:	6a 00                	push   $0x0
80105a2c:	e8 90 fd ff ff       	call   801057c1 <argfd>
80105a31:	83 c4 10             	add    $0x10,%esp
80105a34:	85 c0                	test   %eax,%eax
80105a36:	78 17                	js     80105a4f <sys_fstat+0x38>
80105a38:	83 ec 04             	sub    $0x4,%esp
80105a3b:	6a 14                	push   $0x14
80105a3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a40:	50                   	push   %eax
80105a41:	6a 01                	push   $0x1
80105a43:	e8 50 fc ff ff       	call   80105698 <argptr>
80105a48:	83 c4 10             	add    $0x10,%esp
80105a4b:	85 c0                	test   %eax,%eax
80105a4d:	79 07                	jns    80105a56 <sys_fstat+0x3f>
    return -1;
80105a4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a54:	eb 13                	jmp    80105a69 <sys_fstat+0x52>
  return filestat(f, st);
80105a56:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5c:	83 ec 08             	sub    $0x8,%esp
80105a5f:	52                   	push   %edx
80105a60:	50                   	push   %eax
80105a61:	e8 6f b7 ff ff       	call   801011d5 <filestat>
80105a66:	83 c4 10             	add    $0x10,%esp
}
80105a69:	c9                   	leave  
80105a6a:	c3                   	ret    

80105a6b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105a6b:	f3 0f 1e fb          	endbr32 
80105a6f:	55                   	push   %ebp
80105a70:	89 e5                	mov    %esp,%ebp
80105a72:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105a75:	83 ec 08             	sub    $0x8,%esp
80105a78:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105a7b:	50                   	push   %eax
80105a7c:	6a 00                	push   $0x0
80105a7e:	e8 81 fc ff ff       	call   80105704 <argstr>
80105a83:	83 c4 10             	add    $0x10,%esp
80105a86:	85 c0                	test   %eax,%eax
80105a88:	78 15                	js     80105a9f <sys_link+0x34>
80105a8a:	83 ec 08             	sub    $0x8,%esp
80105a8d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a90:	50                   	push   %eax
80105a91:	6a 01                	push   $0x1
80105a93:	e8 6c fc ff ff       	call   80105704 <argstr>
80105a98:	83 c4 10             	add    $0x10,%esp
80105a9b:	85 c0                	test   %eax,%eax
80105a9d:	79 0a                	jns    80105aa9 <sys_link+0x3e>
    return -1;
80105a9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa4:	e9 68 01 00 00       	jmp    80105c11 <sys_link+0x1a6>

  begin_op();
80105aa9:	e8 bb db ff ff       	call   80103669 <begin_op>
  if((ip = namei(old)) == 0){
80105aae:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105ab1:	83 ec 0c             	sub    $0xc,%esp
80105ab4:	50                   	push   %eax
80105ab5:	e8 2d cb ff ff       	call   801025e7 <namei>
80105aba:	83 c4 10             	add    $0x10,%esp
80105abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ac0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ac4:	75 0f                	jne    80105ad5 <sys_link+0x6a>
    end_op();
80105ac6:	e8 2e dc ff ff       	call   801036f9 <end_op>
    return -1;
80105acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad0:	e9 3c 01 00 00       	jmp    80105c11 <sys_link+0x1a6>
  }

  ilock(ip);
80105ad5:	83 ec 0c             	sub    $0xc,%esp
80105ad8:	ff 75 f4             	pushl  -0xc(%ebp)
80105adb:	e8 9c bf ff ff       	call   80101a7c <ilock>
80105ae0:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae6:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105aea:	66 83 f8 01          	cmp    $0x1,%ax
80105aee:	75 1d                	jne    80105b0d <sys_link+0xa2>
    iunlockput(ip);
80105af0:	83 ec 0c             	sub    $0xc,%esp
80105af3:	ff 75 f4             	pushl  -0xc(%ebp)
80105af6:	e8 be c1 ff ff       	call   80101cb9 <iunlockput>
80105afb:	83 c4 10             	add    $0x10,%esp
    end_op();
80105afe:	e8 f6 db ff ff       	call   801036f9 <end_op>
    return -1;
80105b03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b08:	e9 04 01 00 00       	jmp    80105c11 <sys_link+0x1a6>
  }

  ip->nlink++;
80105b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b10:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105b14:	83 c0 01             	add    $0x1,%eax
80105b17:	89 c2                	mov    %eax,%edx
80105b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105b20:	83 ec 0c             	sub    $0xc,%esp
80105b23:	ff 75 f4             	pushl  -0xc(%ebp)
80105b26:	e8 68 bd ff ff       	call   80101893 <iupdate>
80105b2b:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105b2e:	83 ec 0c             	sub    $0xc,%esp
80105b31:	ff 75 f4             	pushl  -0xc(%ebp)
80105b34:	e8 5a c0 ff ff       	call   80101b93 <iunlock>
80105b39:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105b3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b3f:	83 ec 08             	sub    $0x8,%esp
80105b42:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b45:	52                   	push   %edx
80105b46:	50                   	push   %eax
80105b47:	e8 bb ca ff ff       	call   80102607 <nameiparent>
80105b4c:	83 c4 10             	add    $0x10,%esp
80105b4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b52:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b56:	74 71                	je     80105bc9 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105b58:	83 ec 0c             	sub    $0xc,%esp
80105b5b:	ff 75 f0             	pushl  -0x10(%ebp)
80105b5e:	e8 19 bf ff ff       	call   80101a7c <ilock>
80105b63:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b69:	8b 10                	mov    (%eax),%edx
80105b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b6e:	8b 00                	mov    (%eax),%eax
80105b70:	39 c2                	cmp    %eax,%edx
80105b72:	75 1d                	jne    80105b91 <sys_link+0x126>
80105b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b77:	8b 40 04             	mov    0x4(%eax),%eax
80105b7a:	83 ec 04             	sub    $0x4,%esp
80105b7d:	50                   	push   %eax
80105b7e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105b81:	50                   	push   %eax
80105b82:	ff 75 f0             	pushl  -0x10(%ebp)
80105b85:	e8 ba c7 ff ff       	call   80102344 <dirlink>
80105b8a:	83 c4 10             	add    $0x10,%esp
80105b8d:	85 c0                	test   %eax,%eax
80105b8f:	79 10                	jns    80105ba1 <sys_link+0x136>
    iunlockput(dp);
80105b91:	83 ec 0c             	sub    $0xc,%esp
80105b94:	ff 75 f0             	pushl  -0x10(%ebp)
80105b97:	e8 1d c1 ff ff       	call   80101cb9 <iunlockput>
80105b9c:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b9f:	eb 29                	jmp    80105bca <sys_link+0x15f>
  }
  iunlockput(dp);
80105ba1:	83 ec 0c             	sub    $0xc,%esp
80105ba4:	ff 75 f0             	pushl  -0x10(%ebp)
80105ba7:	e8 0d c1 ff ff       	call   80101cb9 <iunlockput>
80105bac:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105baf:	83 ec 0c             	sub    $0xc,%esp
80105bb2:	ff 75 f4             	pushl  -0xc(%ebp)
80105bb5:	e8 2b c0 ff ff       	call   80101be5 <iput>
80105bba:	83 c4 10             	add    $0x10,%esp

  end_op();
80105bbd:	e8 37 db ff ff       	call   801036f9 <end_op>

  return 0;
80105bc2:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc7:	eb 48                	jmp    80105c11 <sys_link+0x1a6>
    goto bad;
80105bc9:	90                   	nop

bad:
  ilock(ip);
80105bca:	83 ec 0c             	sub    $0xc,%esp
80105bcd:	ff 75 f4             	pushl  -0xc(%ebp)
80105bd0:	e8 a7 be ff ff       	call   80101a7c <ilock>
80105bd5:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bdb:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105bdf:	83 e8 01             	sub    $0x1,%eax
80105be2:	89 c2                	mov    %eax,%edx
80105be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be7:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105beb:	83 ec 0c             	sub    $0xc,%esp
80105bee:	ff 75 f4             	pushl  -0xc(%ebp)
80105bf1:	e8 9d bc ff ff       	call   80101893 <iupdate>
80105bf6:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105bf9:	83 ec 0c             	sub    $0xc,%esp
80105bfc:	ff 75 f4             	pushl  -0xc(%ebp)
80105bff:	e8 b5 c0 ff ff       	call   80101cb9 <iunlockput>
80105c04:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c07:	e8 ed da ff ff       	call   801036f9 <end_op>
  return -1;
80105c0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c11:	c9                   	leave  
80105c12:	c3                   	ret    

80105c13 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c13:	f3 0f 1e fb          	endbr32 
80105c17:	55                   	push   %ebp
80105c18:	89 e5                	mov    %esp,%ebp
80105c1a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c1d:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c24:	eb 40                	jmp    80105c66 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c29:	6a 10                	push   $0x10
80105c2b:	50                   	push   %eax
80105c2c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c2f:	50                   	push   %eax
80105c30:	ff 75 08             	pushl  0x8(%ebp)
80105c33:	e8 4c c3 ff ff       	call   80101f84 <readi>
80105c38:	83 c4 10             	add    $0x10,%esp
80105c3b:	83 f8 10             	cmp    $0x10,%eax
80105c3e:	74 0d                	je     80105c4d <isdirempty+0x3a>
      panic("isdirempty: readi");
80105c40:	83 ec 0c             	sub    $0xc,%esp
80105c43:	68 38 af 10 80       	push   $0x8010af38
80105c48:	e8 78 a9 ff ff       	call   801005c5 <panic>
    if(de.inum != 0)
80105c4d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c51:	66 85 c0             	test   %ax,%ax
80105c54:	74 07                	je     80105c5d <isdirempty+0x4a>
      return 0;
80105c56:	b8 00 00 00 00       	mov    $0x0,%eax
80105c5b:	eb 1b                	jmp    80105c78 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c60:	83 c0 10             	add    $0x10,%eax
80105c63:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c66:	8b 45 08             	mov    0x8(%ebp),%eax
80105c69:	8b 50 58             	mov    0x58(%eax),%edx
80105c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6f:	39 c2                	cmp    %eax,%edx
80105c71:	77 b3                	ja     80105c26 <isdirempty+0x13>
  }
  return 1;
80105c73:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105c78:	c9                   	leave  
80105c79:	c3                   	ret    

80105c7a <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105c7a:	f3 0f 1e fb          	endbr32 
80105c7e:	55                   	push   %ebp
80105c7f:	89 e5                	mov    %esp,%ebp
80105c81:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105c84:	83 ec 08             	sub    $0x8,%esp
80105c87:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105c8a:	50                   	push   %eax
80105c8b:	6a 00                	push   $0x0
80105c8d:	e8 72 fa ff ff       	call   80105704 <argstr>
80105c92:	83 c4 10             	add    $0x10,%esp
80105c95:	85 c0                	test   %eax,%eax
80105c97:	79 0a                	jns    80105ca3 <sys_unlink+0x29>
    return -1;
80105c99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9e:	e9 bf 01 00 00       	jmp    80105e62 <sys_unlink+0x1e8>

  begin_op();
80105ca3:	e8 c1 d9 ff ff       	call   80103669 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105ca8:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105cab:	83 ec 08             	sub    $0x8,%esp
80105cae:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105cb1:	52                   	push   %edx
80105cb2:	50                   	push   %eax
80105cb3:	e8 4f c9 ff ff       	call   80102607 <nameiparent>
80105cb8:	83 c4 10             	add    $0x10,%esp
80105cbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cbe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cc2:	75 0f                	jne    80105cd3 <sys_unlink+0x59>
    end_op();
80105cc4:	e8 30 da ff ff       	call   801036f9 <end_op>
    return -1;
80105cc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cce:	e9 8f 01 00 00       	jmp    80105e62 <sys_unlink+0x1e8>
  }

  ilock(dp);
80105cd3:	83 ec 0c             	sub    $0xc,%esp
80105cd6:	ff 75 f4             	pushl  -0xc(%ebp)
80105cd9:	e8 9e bd ff ff       	call   80101a7c <ilock>
80105cde:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105ce1:	83 ec 08             	sub    $0x8,%esp
80105ce4:	68 4a af 10 80       	push   $0x8010af4a
80105ce9:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105cec:	50                   	push   %eax
80105ced:	e8 75 c5 ff ff       	call   80102267 <namecmp>
80105cf2:	83 c4 10             	add    $0x10,%esp
80105cf5:	85 c0                	test   %eax,%eax
80105cf7:	0f 84 49 01 00 00    	je     80105e46 <sys_unlink+0x1cc>
80105cfd:	83 ec 08             	sub    $0x8,%esp
80105d00:	68 4c af 10 80       	push   $0x8010af4c
80105d05:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d08:	50                   	push   %eax
80105d09:	e8 59 c5 ff ff       	call   80102267 <namecmp>
80105d0e:	83 c4 10             	add    $0x10,%esp
80105d11:	85 c0                	test   %eax,%eax
80105d13:	0f 84 2d 01 00 00    	je     80105e46 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d19:	83 ec 04             	sub    $0x4,%esp
80105d1c:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d1f:	50                   	push   %eax
80105d20:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d23:	50                   	push   %eax
80105d24:	ff 75 f4             	pushl  -0xc(%ebp)
80105d27:	e8 5a c5 ff ff       	call   80102286 <dirlookup>
80105d2c:	83 c4 10             	add    $0x10,%esp
80105d2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d36:	0f 84 0d 01 00 00    	je     80105e49 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80105d3c:	83 ec 0c             	sub    $0xc,%esp
80105d3f:	ff 75 f0             	pushl  -0x10(%ebp)
80105d42:	e8 35 bd ff ff       	call   80101a7c <ilock>
80105d47:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105d51:	66 85 c0             	test   %ax,%ax
80105d54:	7f 0d                	jg     80105d63 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80105d56:	83 ec 0c             	sub    $0xc,%esp
80105d59:	68 4f af 10 80       	push   $0x8010af4f
80105d5e:	e8 62 a8 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d66:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105d6a:	66 83 f8 01          	cmp    $0x1,%ax
80105d6e:	75 25                	jne    80105d95 <sys_unlink+0x11b>
80105d70:	83 ec 0c             	sub    $0xc,%esp
80105d73:	ff 75 f0             	pushl  -0x10(%ebp)
80105d76:	e8 98 fe ff ff       	call   80105c13 <isdirempty>
80105d7b:	83 c4 10             	add    $0x10,%esp
80105d7e:	85 c0                	test   %eax,%eax
80105d80:	75 13                	jne    80105d95 <sys_unlink+0x11b>
    iunlockput(ip);
80105d82:	83 ec 0c             	sub    $0xc,%esp
80105d85:	ff 75 f0             	pushl  -0x10(%ebp)
80105d88:	e8 2c bf ff ff       	call   80101cb9 <iunlockput>
80105d8d:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105d90:	e9 b5 00 00 00       	jmp    80105e4a <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80105d95:	83 ec 04             	sub    $0x4,%esp
80105d98:	6a 10                	push   $0x10
80105d9a:	6a 00                	push   $0x0
80105d9c:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d9f:	50                   	push   %eax
80105da0:	e8 6e f5 ff ff       	call   80105313 <memset>
80105da5:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105da8:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105dab:	6a 10                	push   $0x10
80105dad:	50                   	push   %eax
80105dae:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105db1:	50                   	push   %eax
80105db2:	ff 75 f4             	pushl  -0xc(%ebp)
80105db5:	e8 23 c3 ff ff       	call   801020dd <writei>
80105dba:	83 c4 10             	add    $0x10,%esp
80105dbd:	83 f8 10             	cmp    $0x10,%eax
80105dc0:	74 0d                	je     80105dcf <sys_unlink+0x155>
    panic("unlink: writei");
80105dc2:	83 ec 0c             	sub    $0xc,%esp
80105dc5:	68 61 af 10 80       	push   $0x8010af61
80105dca:	e8 f6 a7 ff ff       	call   801005c5 <panic>
  if(ip->type == T_DIR){
80105dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105dd6:	66 83 f8 01          	cmp    $0x1,%ax
80105dda:	75 21                	jne    80105dfd <sys_unlink+0x183>
    dp->nlink--;
80105ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddf:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105de3:	83 e8 01             	sub    $0x1,%eax
80105de6:	89 c2                	mov    %eax,%edx
80105de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105deb:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105def:	83 ec 0c             	sub    $0xc,%esp
80105df2:	ff 75 f4             	pushl  -0xc(%ebp)
80105df5:	e8 99 ba ff ff       	call   80101893 <iupdate>
80105dfa:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105dfd:	83 ec 0c             	sub    $0xc,%esp
80105e00:	ff 75 f4             	pushl  -0xc(%ebp)
80105e03:	e8 b1 be ff ff       	call   80101cb9 <iunlockput>
80105e08:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105e12:	83 e8 01             	sub    $0x1,%eax
80105e15:	89 c2                	mov    %eax,%edx
80105e17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1a:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105e1e:	83 ec 0c             	sub    $0xc,%esp
80105e21:	ff 75 f0             	pushl  -0x10(%ebp)
80105e24:	e8 6a ba ff ff       	call   80101893 <iupdate>
80105e29:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e2c:	83 ec 0c             	sub    $0xc,%esp
80105e2f:	ff 75 f0             	pushl  -0x10(%ebp)
80105e32:	e8 82 be ff ff       	call   80101cb9 <iunlockput>
80105e37:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e3a:	e8 ba d8 ff ff       	call   801036f9 <end_op>

  return 0;
80105e3f:	b8 00 00 00 00       	mov    $0x0,%eax
80105e44:	eb 1c                	jmp    80105e62 <sys_unlink+0x1e8>
    goto bad;
80105e46:	90                   	nop
80105e47:	eb 01                	jmp    80105e4a <sys_unlink+0x1d0>
    goto bad;
80105e49:	90                   	nop

bad:
  iunlockput(dp);
80105e4a:	83 ec 0c             	sub    $0xc,%esp
80105e4d:	ff 75 f4             	pushl  -0xc(%ebp)
80105e50:	e8 64 be ff ff       	call   80101cb9 <iunlockput>
80105e55:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e58:	e8 9c d8 ff ff       	call   801036f9 <end_op>
  return -1;
80105e5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e62:	c9                   	leave  
80105e63:	c3                   	ret    

80105e64 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e64:	f3 0f 1e fb          	endbr32 
80105e68:	55                   	push   %ebp
80105e69:	89 e5                	mov    %esp,%ebp
80105e6b:	83 ec 38             	sub    $0x38,%esp
80105e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e71:	8b 55 10             	mov    0x10(%ebp),%edx
80105e74:	8b 45 14             	mov    0x14(%ebp),%eax
80105e77:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e7b:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e7f:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e83:	83 ec 08             	sub    $0x8,%esp
80105e86:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e89:	50                   	push   %eax
80105e8a:	ff 75 08             	pushl  0x8(%ebp)
80105e8d:	e8 75 c7 ff ff       	call   80102607 <nameiparent>
80105e92:	83 c4 10             	add    $0x10,%esp
80105e95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e9c:	75 0a                	jne    80105ea8 <create+0x44>
    return 0;
80105e9e:	b8 00 00 00 00       	mov    $0x0,%eax
80105ea3:	e9 90 01 00 00       	jmp    80106038 <create+0x1d4>
  ilock(dp);
80105ea8:	83 ec 0c             	sub    $0xc,%esp
80105eab:	ff 75 f4             	pushl  -0xc(%ebp)
80105eae:	e8 c9 bb ff ff       	call   80101a7c <ilock>
80105eb3:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105eb6:	83 ec 04             	sub    $0x4,%esp
80105eb9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ebc:	50                   	push   %eax
80105ebd:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ec0:	50                   	push   %eax
80105ec1:	ff 75 f4             	pushl  -0xc(%ebp)
80105ec4:	e8 bd c3 ff ff       	call   80102286 <dirlookup>
80105ec9:	83 c4 10             	add    $0x10,%esp
80105ecc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ecf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ed3:	74 50                	je     80105f25 <create+0xc1>
    iunlockput(dp);
80105ed5:	83 ec 0c             	sub    $0xc,%esp
80105ed8:	ff 75 f4             	pushl  -0xc(%ebp)
80105edb:	e8 d9 bd ff ff       	call   80101cb9 <iunlockput>
80105ee0:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105ee3:	83 ec 0c             	sub    $0xc,%esp
80105ee6:	ff 75 f0             	pushl  -0x10(%ebp)
80105ee9:	e8 8e bb ff ff       	call   80101a7c <ilock>
80105eee:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105ef1:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105ef6:	75 15                	jne    80105f0d <create+0xa9>
80105ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105eff:	66 83 f8 02          	cmp    $0x2,%ax
80105f03:	75 08                	jne    80105f0d <create+0xa9>
      return ip;
80105f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f08:	e9 2b 01 00 00       	jmp    80106038 <create+0x1d4>
    iunlockput(ip);
80105f0d:	83 ec 0c             	sub    $0xc,%esp
80105f10:	ff 75 f0             	pushl  -0x10(%ebp)
80105f13:	e8 a1 bd ff ff       	call   80101cb9 <iunlockput>
80105f18:	83 c4 10             	add    $0x10,%esp
    return 0;
80105f1b:	b8 00 00 00 00       	mov    $0x0,%eax
80105f20:	e9 13 01 00 00       	jmp    80106038 <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f25:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2c:	8b 00                	mov    (%eax),%eax
80105f2e:	83 ec 08             	sub    $0x8,%esp
80105f31:	52                   	push   %edx
80105f32:	50                   	push   %eax
80105f33:	e8 80 b8 ff ff       	call   801017b8 <ialloc>
80105f38:	83 c4 10             	add    $0x10,%esp
80105f3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f42:	75 0d                	jne    80105f51 <create+0xed>
    panic("create: ialloc");
80105f44:	83 ec 0c             	sub    $0xc,%esp
80105f47:	68 70 af 10 80       	push   $0x8010af70
80105f4c:	e8 74 a6 ff ff       	call   801005c5 <panic>

  ilock(ip);
80105f51:	83 ec 0c             	sub    $0xc,%esp
80105f54:	ff 75 f0             	pushl  -0x10(%ebp)
80105f57:	e8 20 bb ff ff       	call   80101a7c <ilock>
80105f5c:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f62:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f66:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6d:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f71:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f78:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105f7e:	83 ec 0c             	sub    $0xc,%esp
80105f81:	ff 75 f0             	pushl  -0x10(%ebp)
80105f84:	e8 0a b9 ff ff       	call   80101893 <iupdate>
80105f89:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105f8c:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f91:	75 6a                	jne    80105ffd <create+0x199>
    dp->nlink++;  // for ".."
80105f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f96:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f9a:	83 c0 01             	add    $0x1,%eax
80105f9d:	89 c2                	mov    %eax,%edx
80105f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa2:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105fa6:	83 ec 0c             	sub    $0xc,%esp
80105fa9:	ff 75 f4             	pushl  -0xc(%ebp)
80105fac:	e8 e2 b8 ff ff       	call   80101893 <iupdate>
80105fb1:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb7:	8b 40 04             	mov    0x4(%eax),%eax
80105fba:	83 ec 04             	sub    $0x4,%esp
80105fbd:	50                   	push   %eax
80105fbe:	68 4a af 10 80       	push   $0x8010af4a
80105fc3:	ff 75 f0             	pushl  -0x10(%ebp)
80105fc6:	e8 79 c3 ff ff       	call   80102344 <dirlink>
80105fcb:	83 c4 10             	add    $0x10,%esp
80105fce:	85 c0                	test   %eax,%eax
80105fd0:	78 1e                	js     80105ff0 <create+0x18c>
80105fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd5:	8b 40 04             	mov    0x4(%eax),%eax
80105fd8:	83 ec 04             	sub    $0x4,%esp
80105fdb:	50                   	push   %eax
80105fdc:	68 4c af 10 80       	push   $0x8010af4c
80105fe1:	ff 75 f0             	pushl  -0x10(%ebp)
80105fe4:	e8 5b c3 ff ff       	call   80102344 <dirlink>
80105fe9:	83 c4 10             	add    $0x10,%esp
80105fec:	85 c0                	test   %eax,%eax
80105fee:	79 0d                	jns    80105ffd <create+0x199>
      panic("create dots");
80105ff0:	83 ec 0c             	sub    $0xc,%esp
80105ff3:	68 7f af 10 80       	push   $0x8010af7f
80105ff8:	e8 c8 a5 ff ff       	call   801005c5 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106000:	8b 40 04             	mov    0x4(%eax),%eax
80106003:	83 ec 04             	sub    $0x4,%esp
80106006:	50                   	push   %eax
80106007:	8d 45 de             	lea    -0x22(%ebp),%eax
8010600a:	50                   	push   %eax
8010600b:	ff 75 f4             	pushl  -0xc(%ebp)
8010600e:	e8 31 c3 ff ff       	call   80102344 <dirlink>
80106013:	83 c4 10             	add    $0x10,%esp
80106016:	85 c0                	test   %eax,%eax
80106018:	79 0d                	jns    80106027 <create+0x1c3>
    panic("create: dirlink");
8010601a:	83 ec 0c             	sub    $0xc,%esp
8010601d:	68 8b af 10 80       	push   $0x8010af8b
80106022:	e8 9e a5 ff ff       	call   801005c5 <panic>

  iunlockput(dp);
80106027:	83 ec 0c             	sub    $0xc,%esp
8010602a:	ff 75 f4             	pushl  -0xc(%ebp)
8010602d:	e8 87 bc ff ff       	call   80101cb9 <iunlockput>
80106032:	83 c4 10             	add    $0x10,%esp

  return ip;
80106035:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106038:	c9                   	leave  
80106039:	c3                   	ret    

8010603a <sys_open>:

int
sys_open(void)
{
8010603a:	f3 0f 1e fb          	endbr32 
8010603e:	55                   	push   %ebp
8010603f:	89 e5                	mov    %esp,%ebp
80106041:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106044:	83 ec 08             	sub    $0x8,%esp
80106047:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010604a:	50                   	push   %eax
8010604b:	6a 00                	push   $0x0
8010604d:	e8 b2 f6 ff ff       	call   80105704 <argstr>
80106052:	83 c4 10             	add    $0x10,%esp
80106055:	85 c0                	test   %eax,%eax
80106057:	78 15                	js     8010606e <sys_open+0x34>
80106059:	83 ec 08             	sub    $0x8,%esp
8010605c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010605f:	50                   	push   %eax
80106060:	6a 01                	push   $0x1
80106062:	e8 00 f6 ff ff       	call   80105667 <argint>
80106067:	83 c4 10             	add    $0x10,%esp
8010606a:	85 c0                	test   %eax,%eax
8010606c:	79 0a                	jns    80106078 <sys_open+0x3e>
    return -1;
8010606e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106073:	e9 61 01 00 00       	jmp    801061d9 <sys_open+0x19f>

  begin_op();
80106078:	e8 ec d5 ff ff       	call   80103669 <begin_op>

  if(omode & O_CREATE){
8010607d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106080:	25 00 02 00 00       	and    $0x200,%eax
80106085:	85 c0                	test   %eax,%eax
80106087:	74 2a                	je     801060b3 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80106089:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010608c:	6a 00                	push   $0x0
8010608e:	6a 00                	push   $0x0
80106090:	6a 02                	push   $0x2
80106092:	50                   	push   %eax
80106093:	e8 cc fd ff ff       	call   80105e64 <create>
80106098:	83 c4 10             	add    $0x10,%esp
8010609b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010609e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060a2:	75 75                	jne    80106119 <sys_open+0xdf>
      end_op();
801060a4:	e8 50 d6 ff ff       	call   801036f9 <end_op>
      return -1;
801060a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ae:	e9 26 01 00 00       	jmp    801061d9 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801060b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060b6:	83 ec 0c             	sub    $0xc,%esp
801060b9:	50                   	push   %eax
801060ba:	e8 28 c5 ff ff       	call   801025e7 <namei>
801060bf:	83 c4 10             	add    $0x10,%esp
801060c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060c9:	75 0f                	jne    801060da <sys_open+0xa0>
      end_op();
801060cb:	e8 29 d6 ff ff       	call   801036f9 <end_op>
      return -1;
801060d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d5:	e9 ff 00 00 00       	jmp    801061d9 <sys_open+0x19f>
    }
    ilock(ip);
801060da:	83 ec 0c             	sub    $0xc,%esp
801060dd:	ff 75 f4             	pushl  -0xc(%ebp)
801060e0:	e8 97 b9 ff ff       	call   80101a7c <ilock>
801060e5:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801060e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060eb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801060ef:	66 83 f8 01          	cmp    $0x1,%ax
801060f3:	75 24                	jne    80106119 <sys_open+0xdf>
801060f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f8:	85 c0                	test   %eax,%eax
801060fa:	74 1d                	je     80106119 <sys_open+0xdf>
      iunlockput(ip);
801060fc:	83 ec 0c             	sub    $0xc,%esp
801060ff:	ff 75 f4             	pushl  -0xc(%ebp)
80106102:	e8 b2 bb ff ff       	call   80101cb9 <iunlockput>
80106107:	83 c4 10             	add    $0x10,%esp
      end_op();
8010610a:	e8 ea d5 ff ff       	call   801036f9 <end_op>
      return -1;
8010610f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106114:	e9 c0 00 00 00       	jmp    801061d9 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106119:	e8 05 af ff ff       	call   80101023 <filealloc>
8010611e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106121:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106125:	74 17                	je     8010613e <sys_open+0x104>
80106127:	83 ec 0c             	sub    $0xc,%esp
8010612a:	ff 75 f0             	pushl  -0x10(%ebp)
8010612d:	e8 07 f7 ff ff       	call   80105839 <fdalloc>
80106132:	83 c4 10             	add    $0x10,%esp
80106135:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106138:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010613c:	79 2e                	jns    8010616c <sys_open+0x132>
    if(f)
8010613e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106142:	74 0e                	je     80106152 <sys_open+0x118>
      fileclose(f);
80106144:	83 ec 0c             	sub    $0xc,%esp
80106147:	ff 75 f0             	pushl  -0x10(%ebp)
8010614a:	e8 9a af ff ff       	call   801010e9 <fileclose>
8010614f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106152:	83 ec 0c             	sub    $0xc,%esp
80106155:	ff 75 f4             	pushl  -0xc(%ebp)
80106158:	e8 5c bb ff ff       	call   80101cb9 <iunlockput>
8010615d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106160:	e8 94 d5 ff ff       	call   801036f9 <end_op>
    return -1;
80106165:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010616a:	eb 6d                	jmp    801061d9 <sys_open+0x19f>
  }
  iunlock(ip);
8010616c:	83 ec 0c             	sub    $0xc,%esp
8010616f:	ff 75 f4             	pushl  -0xc(%ebp)
80106172:	e8 1c ba ff ff       	call   80101b93 <iunlock>
80106177:	83 c4 10             	add    $0x10,%esp
  end_op();
8010617a:	e8 7a d5 ff ff       	call   801036f9 <end_op>

  f->type = FD_INODE;
8010617f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106182:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106188:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010618b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010618e:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106191:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106194:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010619b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010619e:	83 e0 01             	and    $0x1,%eax
801061a1:	85 c0                	test   %eax,%eax
801061a3:	0f 94 c0             	sete   %al
801061a6:	89 c2                	mov    %eax,%edx
801061a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ab:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801061ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061b1:	83 e0 01             	and    $0x1,%eax
801061b4:	85 c0                	test   %eax,%eax
801061b6:	75 0a                	jne    801061c2 <sys_open+0x188>
801061b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061bb:	83 e0 02             	and    $0x2,%eax
801061be:	85 c0                	test   %eax,%eax
801061c0:	74 07                	je     801061c9 <sys_open+0x18f>
801061c2:	b8 01 00 00 00       	mov    $0x1,%eax
801061c7:	eb 05                	jmp    801061ce <sys_open+0x194>
801061c9:	b8 00 00 00 00       	mov    $0x0,%eax
801061ce:	89 c2                	mov    %eax,%edx
801061d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d3:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801061d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801061d9:	c9                   	leave  
801061da:	c3                   	ret    

801061db <sys_mkdir>:

int
sys_mkdir(void)
{
801061db:	f3 0f 1e fb          	endbr32 
801061df:	55                   	push   %ebp
801061e0:	89 e5                	mov    %esp,%ebp
801061e2:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801061e5:	e8 7f d4 ff ff       	call   80103669 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801061ea:	83 ec 08             	sub    $0x8,%esp
801061ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061f0:	50                   	push   %eax
801061f1:	6a 00                	push   $0x0
801061f3:	e8 0c f5 ff ff       	call   80105704 <argstr>
801061f8:	83 c4 10             	add    $0x10,%esp
801061fb:	85 c0                	test   %eax,%eax
801061fd:	78 1b                	js     8010621a <sys_mkdir+0x3f>
801061ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106202:	6a 00                	push   $0x0
80106204:	6a 00                	push   $0x0
80106206:	6a 01                	push   $0x1
80106208:	50                   	push   %eax
80106209:	e8 56 fc ff ff       	call   80105e64 <create>
8010620e:	83 c4 10             	add    $0x10,%esp
80106211:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106214:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106218:	75 0c                	jne    80106226 <sys_mkdir+0x4b>
    end_op();
8010621a:	e8 da d4 ff ff       	call   801036f9 <end_op>
    return -1;
8010621f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106224:	eb 18                	jmp    8010623e <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106226:	83 ec 0c             	sub    $0xc,%esp
80106229:	ff 75 f4             	pushl  -0xc(%ebp)
8010622c:	e8 88 ba ff ff       	call   80101cb9 <iunlockput>
80106231:	83 c4 10             	add    $0x10,%esp
  end_op();
80106234:	e8 c0 d4 ff ff       	call   801036f9 <end_op>
  return 0;
80106239:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010623e:	c9                   	leave  
8010623f:	c3                   	ret    

80106240 <sys_mknod>:

int
sys_mknod(void)
{
80106240:	f3 0f 1e fb          	endbr32 
80106244:	55                   	push   %ebp
80106245:	89 e5                	mov    %esp,%ebp
80106247:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010624a:	e8 1a d4 ff ff       	call   80103669 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010624f:	83 ec 08             	sub    $0x8,%esp
80106252:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106255:	50                   	push   %eax
80106256:	6a 00                	push   $0x0
80106258:	e8 a7 f4 ff ff       	call   80105704 <argstr>
8010625d:	83 c4 10             	add    $0x10,%esp
80106260:	85 c0                	test   %eax,%eax
80106262:	78 4f                	js     801062b3 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80106264:	83 ec 08             	sub    $0x8,%esp
80106267:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010626a:	50                   	push   %eax
8010626b:	6a 01                	push   $0x1
8010626d:	e8 f5 f3 ff ff       	call   80105667 <argint>
80106272:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80106275:	85 c0                	test   %eax,%eax
80106277:	78 3a                	js     801062b3 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
80106279:	83 ec 08             	sub    $0x8,%esp
8010627c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010627f:	50                   	push   %eax
80106280:	6a 02                	push   $0x2
80106282:	e8 e0 f3 ff ff       	call   80105667 <argint>
80106287:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010628a:	85 c0                	test   %eax,%eax
8010628c:	78 25                	js     801062b3 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010628e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106291:	0f bf c8             	movswl %ax,%ecx
80106294:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106297:	0f bf d0             	movswl %ax,%edx
8010629a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629d:	51                   	push   %ecx
8010629e:	52                   	push   %edx
8010629f:	6a 03                	push   $0x3
801062a1:	50                   	push   %eax
801062a2:	e8 bd fb ff ff       	call   80105e64 <create>
801062a7:	83 c4 10             	add    $0x10,%esp
801062aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801062ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062b1:	75 0c                	jne    801062bf <sys_mknod+0x7f>
    end_op();
801062b3:	e8 41 d4 ff ff       	call   801036f9 <end_op>
    return -1;
801062b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062bd:	eb 18                	jmp    801062d7 <sys_mknod+0x97>
  }
  iunlockput(ip);
801062bf:	83 ec 0c             	sub    $0xc,%esp
801062c2:	ff 75 f4             	pushl  -0xc(%ebp)
801062c5:	e8 ef b9 ff ff       	call   80101cb9 <iunlockput>
801062ca:	83 c4 10             	add    $0x10,%esp
  end_op();
801062cd:	e8 27 d4 ff ff       	call   801036f9 <end_op>
  return 0;
801062d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062d7:	c9                   	leave  
801062d8:	c3                   	ret    

801062d9 <sys_chdir>:

int
sys_chdir(void)
{
801062d9:	f3 0f 1e fb          	endbr32 
801062dd:	55                   	push   %ebp
801062de:	89 e5                	mov    %esp,%ebp
801062e0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801062e3:	e8 b9 dd ff ff       	call   801040a1 <myproc>
801062e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801062eb:	e8 79 d3 ff ff       	call   80103669 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801062f0:	83 ec 08             	sub    $0x8,%esp
801062f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062f6:	50                   	push   %eax
801062f7:	6a 00                	push   $0x0
801062f9:	e8 06 f4 ff ff       	call   80105704 <argstr>
801062fe:	83 c4 10             	add    $0x10,%esp
80106301:	85 c0                	test   %eax,%eax
80106303:	78 18                	js     8010631d <sys_chdir+0x44>
80106305:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106308:	83 ec 0c             	sub    $0xc,%esp
8010630b:	50                   	push   %eax
8010630c:	e8 d6 c2 ff ff       	call   801025e7 <namei>
80106311:	83 c4 10             	add    $0x10,%esp
80106314:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106317:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010631b:	75 0c                	jne    80106329 <sys_chdir+0x50>
    end_op();
8010631d:	e8 d7 d3 ff ff       	call   801036f9 <end_op>
    return -1;
80106322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106327:	eb 68                	jmp    80106391 <sys_chdir+0xb8>
  }
  ilock(ip);
80106329:	83 ec 0c             	sub    $0xc,%esp
8010632c:	ff 75 f0             	pushl  -0x10(%ebp)
8010632f:	e8 48 b7 ff ff       	call   80101a7c <ilock>
80106334:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010633a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010633e:	66 83 f8 01          	cmp    $0x1,%ax
80106342:	74 1a                	je     8010635e <sys_chdir+0x85>
    iunlockput(ip);
80106344:	83 ec 0c             	sub    $0xc,%esp
80106347:	ff 75 f0             	pushl  -0x10(%ebp)
8010634a:	e8 6a b9 ff ff       	call   80101cb9 <iunlockput>
8010634f:	83 c4 10             	add    $0x10,%esp
    end_op();
80106352:	e8 a2 d3 ff ff       	call   801036f9 <end_op>
    return -1;
80106357:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010635c:	eb 33                	jmp    80106391 <sys_chdir+0xb8>
  }
  iunlock(ip);
8010635e:	83 ec 0c             	sub    $0xc,%esp
80106361:	ff 75 f0             	pushl  -0x10(%ebp)
80106364:	e8 2a b8 ff ff       	call   80101b93 <iunlock>
80106369:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010636c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636f:	8b 40 68             	mov    0x68(%eax),%eax
80106372:	83 ec 0c             	sub    $0xc,%esp
80106375:	50                   	push   %eax
80106376:	e8 6a b8 ff ff       	call   80101be5 <iput>
8010637b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010637e:	e8 76 d3 ff ff       	call   801036f9 <end_op>
  curproc->cwd = ip;
80106383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106386:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106389:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010638c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106391:	c9                   	leave  
80106392:	c3                   	ret    

80106393 <sys_exec>:

int
sys_exec(void)
{
80106393:	f3 0f 1e fb          	endbr32 
80106397:	55                   	push   %ebp
80106398:	89 e5                	mov    %esp,%ebp
8010639a:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801063a0:	83 ec 08             	sub    $0x8,%esp
801063a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063a6:	50                   	push   %eax
801063a7:	6a 00                	push   $0x0
801063a9:	e8 56 f3 ff ff       	call   80105704 <argstr>
801063ae:	83 c4 10             	add    $0x10,%esp
801063b1:	85 c0                	test   %eax,%eax
801063b3:	78 18                	js     801063cd <sys_exec+0x3a>
801063b5:	83 ec 08             	sub    $0x8,%esp
801063b8:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801063be:	50                   	push   %eax
801063bf:	6a 01                	push   $0x1
801063c1:	e8 a1 f2 ff ff       	call   80105667 <argint>
801063c6:	83 c4 10             	add    $0x10,%esp
801063c9:	85 c0                	test   %eax,%eax
801063cb:	79 0a                	jns    801063d7 <sys_exec+0x44>
    return -1;
801063cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d2:	e9 c6 00 00 00       	jmp    8010649d <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
801063d7:	83 ec 04             	sub    $0x4,%esp
801063da:	68 80 00 00 00       	push   $0x80
801063df:	6a 00                	push   $0x0
801063e1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063e7:	50                   	push   %eax
801063e8:	e8 26 ef ff ff       	call   80105313 <memset>
801063ed:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801063f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fa:	83 f8 1f             	cmp    $0x1f,%eax
801063fd:	76 0a                	jbe    80106409 <sys_exec+0x76>
      return -1;
801063ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106404:	e9 94 00 00 00       	jmp    8010649d <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106409:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640c:	c1 e0 02             	shl    $0x2,%eax
8010640f:	89 c2                	mov    %eax,%edx
80106411:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106417:	01 c2                	add    %eax,%edx
80106419:	83 ec 08             	sub    $0x8,%esp
8010641c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106422:	50                   	push   %eax
80106423:	52                   	push   %edx
80106424:	e8 93 f1 ff ff       	call   801055bc <fetchint>
80106429:	83 c4 10             	add    $0x10,%esp
8010642c:	85 c0                	test   %eax,%eax
8010642e:	79 07                	jns    80106437 <sys_exec+0xa4>
      return -1;
80106430:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106435:	eb 66                	jmp    8010649d <sys_exec+0x10a>
    if(uarg == 0){
80106437:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010643d:	85 c0                	test   %eax,%eax
8010643f:	75 27                	jne    80106468 <sys_exec+0xd5>
      argv[i] = 0;
80106441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106444:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010644b:	00 00 00 00 
      break;
8010644f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106453:	83 ec 08             	sub    $0x8,%esp
80106456:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010645c:	52                   	push   %edx
8010645d:	50                   	push   %eax
8010645e:	e8 5b a7 ff ff       	call   80100bbe <exec>
80106463:	83 c4 10             	add    $0x10,%esp
80106466:	eb 35                	jmp    8010649d <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106468:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010646e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106471:	c1 e2 02             	shl    $0x2,%edx
80106474:	01 c2                	add    %eax,%edx
80106476:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010647c:	83 ec 08             	sub    $0x8,%esp
8010647f:	52                   	push   %edx
80106480:	50                   	push   %eax
80106481:	e8 79 f1 ff ff       	call   801055ff <fetchstr>
80106486:	83 c4 10             	add    $0x10,%esp
80106489:	85 c0                	test   %eax,%eax
8010648b:	79 07                	jns    80106494 <sys_exec+0x101>
      return -1;
8010648d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106492:	eb 09                	jmp    8010649d <sys_exec+0x10a>
  for(i=0;; i++){
80106494:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80106498:	e9 5a ff ff ff       	jmp    801063f7 <sys_exec+0x64>
}
8010649d:	c9                   	leave  
8010649e:	c3                   	ret    

8010649f <sys_pipe>:

int
sys_pipe(void)
{
8010649f:	f3 0f 1e fb          	endbr32 
801064a3:	55                   	push   %ebp
801064a4:	89 e5                	mov    %esp,%ebp
801064a6:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801064a9:	83 ec 04             	sub    $0x4,%esp
801064ac:	6a 08                	push   $0x8
801064ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064b1:	50                   	push   %eax
801064b2:	6a 00                	push   $0x0
801064b4:	e8 df f1 ff ff       	call   80105698 <argptr>
801064b9:	83 c4 10             	add    $0x10,%esp
801064bc:	85 c0                	test   %eax,%eax
801064be:	79 0a                	jns    801064ca <sys_pipe+0x2b>
    return -1;
801064c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c5:	e9 ae 00 00 00       	jmp    80106578 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
801064ca:	83 ec 08             	sub    $0x8,%esp
801064cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064d0:	50                   	push   %eax
801064d1:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064d4:	50                   	push   %eax
801064d5:	e8 e8 d6 ff ff       	call   80103bc2 <pipealloc>
801064da:	83 c4 10             	add    $0x10,%esp
801064dd:	85 c0                	test   %eax,%eax
801064df:	79 0a                	jns    801064eb <sys_pipe+0x4c>
    return -1;
801064e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e6:	e9 8d 00 00 00       	jmp    80106578 <sys_pipe+0xd9>
  fd0 = -1;
801064eb:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064f5:	83 ec 0c             	sub    $0xc,%esp
801064f8:	50                   	push   %eax
801064f9:	e8 3b f3 ff ff       	call   80105839 <fdalloc>
801064fe:	83 c4 10             	add    $0x10,%esp
80106501:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106504:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106508:	78 18                	js     80106522 <sys_pipe+0x83>
8010650a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010650d:	83 ec 0c             	sub    $0xc,%esp
80106510:	50                   	push   %eax
80106511:	e8 23 f3 ff ff       	call   80105839 <fdalloc>
80106516:	83 c4 10             	add    $0x10,%esp
80106519:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010651c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106520:	79 3e                	jns    80106560 <sys_pipe+0xc1>
    if(fd0 >= 0)
80106522:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106526:	78 13                	js     8010653b <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106528:	e8 74 db ff ff       	call   801040a1 <myproc>
8010652d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106530:	83 c2 08             	add    $0x8,%edx
80106533:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010653a:	00 
    fileclose(rf);
8010653b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010653e:	83 ec 0c             	sub    $0xc,%esp
80106541:	50                   	push   %eax
80106542:	e8 a2 ab ff ff       	call   801010e9 <fileclose>
80106547:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010654a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010654d:	83 ec 0c             	sub    $0xc,%esp
80106550:	50                   	push   %eax
80106551:	e8 93 ab ff ff       	call   801010e9 <fileclose>
80106556:	83 c4 10             	add    $0x10,%esp
    return -1;
80106559:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655e:	eb 18                	jmp    80106578 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106560:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106563:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106566:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106568:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010656b:	8d 50 04             	lea    0x4(%eax),%edx
8010656e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106571:	89 02                	mov    %eax,(%edx)
  return 0;
80106573:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106578:	c9                   	leave  
80106579:	c3                   	ret    

8010657a <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010657a:	f3 0f 1e fb          	endbr32 
8010657e:	55                   	push   %ebp
8010657f:	89 e5                	mov    %esp,%ebp
80106581:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106584:	e8 3b de ff ff       	call   801043c4 <fork>
}
80106589:	c9                   	leave  
8010658a:	c3                   	ret    

8010658b <sys_exit>:

int
sys_exit(void)
{
8010658b:	f3 0f 1e fb          	endbr32 
8010658f:	55                   	push   %ebp
80106590:	89 e5                	mov    %esp,%ebp
80106592:	83 ec 08             	sub    $0x8,%esp
  exit();
80106595:	e8 a7 df ff ff       	call   80104541 <exit>
  return 0;  // not reached
8010659a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010659f:	c9                   	leave  
801065a0:	c3                   	ret    

801065a1 <sys_wait>:

int
sys_wait(void)
{
801065a1:	f3 0f 1e fb          	endbr32 
801065a5:	55                   	push   %ebp
801065a6:	89 e5                	mov    %esp,%ebp
801065a8:	83 ec 08             	sub    $0x8,%esp
  return wait();
801065ab:	e8 f5 e1 ff ff       	call   801047a5 <wait>
}
801065b0:	c9                   	leave  
801065b1:	c3                   	ret    

801065b2 <sys_kill>:

int
sys_kill(void)
{
801065b2:	f3 0f 1e fb          	endbr32 
801065b6:	55                   	push   %ebp
801065b7:	89 e5                	mov    %esp,%ebp
801065b9:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801065bc:	83 ec 08             	sub    $0x8,%esp
801065bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065c2:	50                   	push   %eax
801065c3:	6a 00                	push   $0x0
801065c5:	e8 9d f0 ff ff       	call   80105667 <argint>
801065ca:	83 c4 10             	add    $0x10,%esp
801065cd:	85 c0                	test   %eax,%eax
801065cf:	79 07                	jns    801065d8 <sys_kill+0x26>
    return -1;
801065d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065d6:	eb 0f                	jmp    801065e7 <sys_kill+0x35>
  return kill(pid);
801065d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065db:	83 ec 0c             	sub    $0xc,%esp
801065de:	50                   	push   %eax
801065df:	e8 81 e7 ff ff       	call   80104d65 <kill>
801065e4:	83 c4 10             	add    $0x10,%esp
}
801065e7:	c9                   	leave  
801065e8:	c3                   	ret    

801065e9 <sys_getpid>:

int
sys_getpid(void)
{
801065e9:	f3 0f 1e fb          	endbr32 
801065ed:	55                   	push   %ebp
801065ee:	89 e5                	mov    %esp,%ebp
801065f0:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801065f3:	e8 a9 da ff ff       	call   801040a1 <myproc>
801065f8:	8b 40 10             	mov    0x10(%eax),%eax
}
801065fb:	c9                   	leave  
801065fc:	c3                   	ret    

801065fd <sys_sbrk>:

int
sys_sbrk(void)
{
801065fd:	f3 0f 1e fb          	endbr32 
80106601:	55                   	push   %ebp
80106602:	89 e5                	mov    %esp,%ebp
80106604:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106607:	83 ec 08             	sub    $0x8,%esp
8010660a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010660d:	50                   	push   %eax
8010660e:	6a 00                	push   $0x0
80106610:	e8 52 f0 ff ff       	call   80105667 <argint>
80106615:	83 c4 10             	add    $0x10,%esp
80106618:	85 c0                	test   %eax,%eax
8010661a:	79 07                	jns    80106623 <sys_sbrk+0x26>
    return -1;
8010661c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106621:	eb 27                	jmp    8010664a <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106623:	e8 79 da ff ff       	call   801040a1 <myproc>
80106628:	8b 00                	mov    (%eax),%eax
8010662a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010662d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106630:	83 ec 0c             	sub    $0xc,%esp
80106633:	50                   	push   %eax
80106634:	e8 ec dc ff ff       	call   80104325 <growproc>
80106639:	83 c4 10             	add    $0x10,%esp
8010663c:	85 c0                	test   %eax,%eax
8010663e:	79 07                	jns    80106647 <sys_sbrk+0x4a>
    return -1;
80106640:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106645:	eb 03                	jmp    8010664a <sys_sbrk+0x4d>
  return addr;
80106647:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010664a:	c9                   	leave  
8010664b:	c3                   	ret    

8010664c <sys_sleep>:

int
sys_sleep(void)
{
8010664c:	f3 0f 1e fb          	endbr32 
80106650:	55                   	push   %ebp
80106651:	89 e5                	mov    %esp,%ebp
80106653:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106656:	83 ec 08             	sub    $0x8,%esp
80106659:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010665c:	50                   	push   %eax
8010665d:	6a 00                	push   $0x0
8010665f:	e8 03 f0 ff ff       	call   80105667 <argint>
80106664:	83 c4 10             	add    $0x10,%esp
80106667:	85 c0                	test   %eax,%eax
80106669:	79 07                	jns    80106672 <sys_sleep+0x26>
    return -1;
8010666b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106670:	eb 76                	jmp    801066e8 <sys_sleep+0x9c>
  acquire(&tickslock);
80106672:	83 ec 0c             	sub    $0xc,%esp
80106675:	68 80 a6 11 80       	push   $0x8011a680
8010667a:	e8 05 ea ff ff       	call   80105084 <acquire>
8010667f:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106682:	a1 c0 ae 11 80       	mov    0x8011aec0,%eax
80106687:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010668a:	eb 38                	jmp    801066c4 <sys_sleep+0x78>
    if(myproc()->killed){
8010668c:	e8 10 da ff ff       	call   801040a1 <myproc>
80106691:	8b 40 24             	mov    0x24(%eax),%eax
80106694:	85 c0                	test   %eax,%eax
80106696:	74 17                	je     801066af <sys_sleep+0x63>
      release(&tickslock);
80106698:	83 ec 0c             	sub    $0xc,%esp
8010669b:	68 80 a6 11 80       	push   $0x8011a680
801066a0:	e8 51 ea ff ff       	call   801050f6 <release>
801066a5:	83 c4 10             	add    $0x10,%esp
      return -1;
801066a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ad:	eb 39                	jmp    801066e8 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
801066af:	83 ec 08             	sub    $0x8,%esp
801066b2:	68 80 a6 11 80       	push   $0x8011a680
801066b7:	68 c0 ae 11 80       	push   $0x8011aec0
801066bc:	e8 77 e5 ff ff       	call   80104c38 <sleep>
801066c1:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801066c4:	a1 c0 ae 11 80       	mov    0x8011aec0,%eax
801066c9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801066cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801066cf:	39 d0                	cmp    %edx,%eax
801066d1:	72 b9                	jb     8010668c <sys_sleep+0x40>
  }
  release(&tickslock);
801066d3:	83 ec 0c             	sub    $0xc,%esp
801066d6:	68 80 a6 11 80       	push   $0x8011a680
801066db:	e8 16 ea ff ff       	call   801050f6 <release>
801066e0:	83 c4 10             	add    $0x10,%esp
  return 0;
801066e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066e8:	c9                   	leave  
801066e9:	c3                   	ret    

801066ea <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801066ea:	f3 0f 1e fb          	endbr32 
801066ee:	55                   	push   %ebp
801066ef:	89 e5                	mov    %esp,%ebp
801066f1:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801066f4:	83 ec 0c             	sub    $0xc,%esp
801066f7:	68 80 a6 11 80       	push   $0x8011a680
801066fc:	e8 83 e9 ff ff       	call   80105084 <acquire>
80106701:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106704:	a1 c0 ae 11 80       	mov    0x8011aec0,%eax
80106709:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010670c:	83 ec 0c             	sub    $0xc,%esp
8010670f:	68 80 a6 11 80       	push   $0x8011a680
80106714:	e8 dd e9 ff ff       	call   801050f6 <release>
80106719:	83 c4 10             	add    $0x10,%esp
  return xticks;
8010671c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010671f:	c9                   	leave  
80106720:	c3                   	ret    

80106721 <sys_exit2>:

int
sys_exit2(void)
{
80106721:	f3 0f 1e fb          	endbr32 
80106725:	55                   	push   %ebp
80106726:	89 e5                	mov    %esp,%ebp
80106728:	83 ec 18             	sub    $0x18,%esp
  int status;
  if(argint(0, &status) < 0)
8010672b:	83 ec 08             	sub    $0x8,%esp
8010672e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106731:	50                   	push   %eax
80106732:	6a 00                	push   $0x0
80106734:	e8 2e ef ff ff       	call   80105667 <argint>
80106739:	83 c4 10             	add    $0x10,%esp
8010673c:	85 c0                	test   %eax,%eax
8010673e:	79 07                	jns    80106747 <sys_exit2+0x26>
    return -1; 
80106740:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106745:	eb 15                	jmp    8010675c <sys_exit2+0x3b>

  myproc()->xstate = status;
80106747:	e8 55 d9 ff ff       	call   801040a1 <myproc>
8010674c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010674f:	89 50 7c             	mov    %edx,0x7c(%eax)
  exit();
80106752:	e8 ea dd ff ff       	call   80104541 <exit>
  return 0;
80106757:	b8 00 00 00 00       	mov    $0x0,%eax
}	
8010675c:	c9                   	leave  
8010675d:	c3                   	ret    

8010675e <sys_wait2>:

extern int wait2(int *status);

int sys_wait2(void) 
{
8010675e:	f3 0f 1e fb          	endbr32 
80106762:	55                   	push   %ebp
80106763:	89 e5                	mov    %esp,%ebp
80106765:	83 ec 18             	sub    $0x18,%esp
  int *status;
  if(argptr(0, (void *)&status, sizeof(*status)) < 0)
80106768:	83 ec 04             	sub    $0x4,%esp
8010676b:	6a 04                	push   $0x4
8010676d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106770:	50                   	push   %eax
80106771:	6a 00                	push   $0x0
80106773:	e8 20 ef ff ff       	call   80105698 <argptr>
80106778:	83 c4 10             	add    $0x10,%esp
8010677b:	85 c0                	test   %eax,%eax
8010677d:	79 07                	jns    80106786 <sys_wait2+0x28>
    return -1;
8010677f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106784:	eb 0f                	jmp    80106795 <sys_wait2+0x37>
  return wait2(status);
80106786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106789:	83 ec 0c             	sub    $0xc,%esp
8010678c:	50                   	push   %eax
8010678d:	e8 3a e1 ff ff       	call   801048cc <wait2>
80106792:	83 c4 10             	add    $0x10,%esp
}
80106795:	c9                   	leave  
80106796:	c3                   	ret    

80106797 <sys_uthread_init>:

int
sys_uthread_init(void)
{
80106797:	f3 0f 1e fb          	endbr32 
8010679b:	55                   	push   %ebp
8010679c:	89 e5                	mov    %esp,%ebp
8010679e:	83 ec 18             	sub    $0x18,%esp
    struct proc* p;
    int func;

    if (argint(0, &func) < 0)
801067a1:	83 ec 08             	sub    $0x8,%esp
801067a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067a7:	50                   	push   %eax
801067a8:	6a 00                	push   $0x0
801067aa:	e8 b8 ee ff ff       	call   80105667 <argint>
801067af:	83 c4 10             	add    $0x10,%esp
801067b2:	85 c0                	test   %eax,%eax
801067b4:	79 07                	jns    801067bd <sys_uthread_init+0x26>
        return -1;
801067b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bb:	eb 1b                	jmp    801067d8 <sys_uthread_init+0x41>

    p = myproc();
801067bd:	e8 df d8 ff ff       	call   801040a1 <myproc>
801067c2:	89 45 f4             	mov    %eax,-0xc(%ebp)

    p->scheduler = (uint)func;
801067c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067c8:	89 c2                	mov    %eax,%edx
801067ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067cd:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

    return 0;
801067d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067d8:	c9                   	leave  
801067d9:	c3                   	ret    

801067da <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801067da:	1e                   	push   %ds
  pushl %es
801067db:	06                   	push   %es
  pushl %fs
801067dc:	0f a0                	push   %fs
  pushl %gs
801067de:	0f a8                	push   %gs
  pushal
801067e0:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801067e1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801067e5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801067e7:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801067e9:	54                   	push   %esp
  call trap
801067ea:	e8 df 01 00 00       	call   801069ce <trap>
  addl $4, %esp
801067ef:	83 c4 04             	add    $0x4,%esp

801067f2 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801067f2:	61                   	popa   
  popl %gs
801067f3:	0f a9                	pop    %gs
  popl %fs
801067f5:	0f a1                	pop    %fs
  popl %es
801067f7:	07                   	pop    %es
  popl %ds
801067f8:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801067f9:	83 c4 08             	add    $0x8,%esp
  iret
801067fc:	cf                   	iret   

801067fd <lidt>:
{
801067fd:	55                   	push   %ebp
801067fe:	89 e5                	mov    %esp,%ebp
80106800:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106803:	8b 45 0c             	mov    0xc(%ebp),%eax
80106806:	83 e8 01             	sub    $0x1,%eax
80106809:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010680d:	8b 45 08             	mov    0x8(%ebp),%eax
80106810:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106814:	8b 45 08             	mov    0x8(%ebp),%eax
80106817:	c1 e8 10             	shr    $0x10,%eax
8010681a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010681e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106821:	0f 01 18             	lidtl  (%eax)
}
80106824:	90                   	nop
80106825:	c9                   	leave  
80106826:	c3                   	ret    

80106827 <rcr2>:

static inline uint
rcr2(void)
{
80106827:	55                   	push   %ebp
80106828:	89 e5                	mov    %esp,%ebp
8010682a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010682d:	0f 20 d0             	mov    %cr2,%eax
80106830:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106833:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106836:	c9                   	leave  
80106837:	c3                   	ret    

80106838 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106838:	f3 0f 1e fb          	endbr32 
8010683c:	55                   	push   %ebp
8010683d:	89 e5                	mov    %esp,%ebp
8010683f:	83 ec 18             	sub    $0x18,%esp
    int i;

    for (i = 0; i < 256; i++)
80106842:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106849:	e9 c3 00 00 00       	jmp    80106911 <tvinit+0xd9>
        SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
8010684e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106851:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
80106858:	89 c2                	mov    %eax,%edx
8010685a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685d:	66 89 14 c5 c0 a6 11 	mov    %dx,-0x7fee5940(,%eax,8)
80106864:	80 
80106865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106868:	66 c7 04 c5 c2 a6 11 	movw   $0x8,-0x7fee593e(,%eax,8)
8010686f:	80 08 00 
80106872:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106875:	0f b6 14 c5 c4 a6 11 	movzbl -0x7fee593c(,%eax,8),%edx
8010687c:	80 
8010687d:	83 e2 e0             	and    $0xffffffe0,%edx
80106880:	88 14 c5 c4 a6 11 80 	mov    %dl,-0x7fee593c(,%eax,8)
80106887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010688a:	0f b6 14 c5 c4 a6 11 	movzbl -0x7fee593c(,%eax,8),%edx
80106891:	80 
80106892:	83 e2 1f             	and    $0x1f,%edx
80106895:	88 14 c5 c4 a6 11 80 	mov    %dl,-0x7fee593c(,%eax,8)
8010689c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689f:	0f b6 14 c5 c5 a6 11 	movzbl -0x7fee593b(,%eax,8),%edx
801068a6:	80 
801068a7:	83 e2 f0             	and    $0xfffffff0,%edx
801068aa:	83 ca 0e             	or     $0xe,%edx
801068ad:	88 14 c5 c5 a6 11 80 	mov    %dl,-0x7fee593b(,%eax,8)
801068b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b7:	0f b6 14 c5 c5 a6 11 	movzbl -0x7fee593b(,%eax,8),%edx
801068be:	80 
801068bf:	83 e2 ef             	and    $0xffffffef,%edx
801068c2:	88 14 c5 c5 a6 11 80 	mov    %dl,-0x7fee593b(,%eax,8)
801068c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068cc:	0f b6 14 c5 c5 a6 11 	movzbl -0x7fee593b(,%eax,8),%edx
801068d3:	80 
801068d4:	83 e2 9f             	and    $0xffffff9f,%edx
801068d7:	88 14 c5 c5 a6 11 80 	mov    %dl,-0x7fee593b(,%eax,8)
801068de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e1:	0f b6 14 c5 c5 a6 11 	movzbl -0x7fee593b(,%eax,8),%edx
801068e8:	80 
801068e9:	83 ca 80             	or     $0xffffff80,%edx
801068ec:	88 14 c5 c5 a6 11 80 	mov    %dl,-0x7fee593b(,%eax,8)
801068f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f6:	8b 04 85 84 f0 10 80 	mov    -0x7fef0f7c(,%eax,4),%eax
801068fd:	c1 e8 10             	shr    $0x10,%eax
80106900:	89 c2                	mov    %eax,%edx
80106902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106905:	66 89 14 c5 c6 a6 11 	mov    %dx,-0x7fee593a(,%eax,8)
8010690c:	80 
    for (i = 0; i < 256; i++)
8010690d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106911:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106918:	0f 8e 30 ff ff ff    	jle    8010684e <tvinit+0x16>
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
8010691e:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80106923:	66 a3 c0 a8 11 80    	mov    %ax,0x8011a8c0
80106929:	66 c7 05 c2 a8 11 80 	movw   $0x8,0x8011a8c2
80106930:	08 00 
80106932:	0f b6 05 c4 a8 11 80 	movzbl 0x8011a8c4,%eax
80106939:	83 e0 e0             	and    $0xffffffe0,%eax
8010693c:	a2 c4 a8 11 80       	mov    %al,0x8011a8c4
80106941:	0f b6 05 c4 a8 11 80 	movzbl 0x8011a8c4,%eax
80106948:	83 e0 1f             	and    $0x1f,%eax
8010694b:	a2 c4 a8 11 80       	mov    %al,0x8011a8c4
80106950:	0f b6 05 c5 a8 11 80 	movzbl 0x8011a8c5,%eax
80106957:	83 c8 0f             	or     $0xf,%eax
8010695a:	a2 c5 a8 11 80       	mov    %al,0x8011a8c5
8010695f:	0f b6 05 c5 a8 11 80 	movzbl 0x8011a8c5,%eax
80106966:	83 e0 ef             	and    $0xffffffef,%eax
80106969:	a2 c5 a8 11 80       	mov    %al,0x8011a8c5
8010696e:	0f b6 05 c5 a8 11 80 	movzbl 0x8011a8c5,%eax
80106975:	83 c8 60             	or     $0x60,%eax
80106978:	a2 c5 a8 11 80       	mov    %al,0x8011a8c5
8010697d:	0f b6 05 c5 a8 11 80 	movzbl 0x8011a8c5,%eax
80106984:	83 c8 80             	or     $0xffffff80,%eax
80106987:	a2 c5 a8 11 80       	mov    %al,0x8011a8c5
8010698c:	a1 84 f1 10 80       	mov    0x8010f184,%eax
80106991:	c1 e8 10             	shr    $0x10,%eax
80106994:	66 a3 c6 a8 11 80    	mov    %ax,0x8011a8c6

    initlock(&tickslock, "time");
8010699a:	83 ec 08             	sub    $0x8,%esp
8010699d:	68 9c af 10 80       	push   $0x8010af9c
801069a2:	68 80 a6 11 80       	push   $0x8011a680
801069a7:	e8 b2 e6 ff ff       	call   8010505e <initlock>
801069ac:	83 c4 10             	add    $0x10,%esp
}
801069af:	90                   	nop
801069b0:	c9                   	leave  
801069b1:	c3                   	ret    

801069b2 <idtinit>:

void
idtinit(void)
{
801069b2:	f3 0f 1e fb          	endbr32 
801069b6:	55                   	push   %ebp
801069b7:	89 e5                	mov    %esp,%ebp
    lidt(idt, sizeof(idt));
801069b9:	68 00 08 00 00       	push   $0x800
801069be:	68 c0 a6 11 80       	push   $0x8011a6c0
801069c3:	e8 35 fe ff ff       	call   801067fd <lidt>
801069c8:	83 c4 08             	add    $0x8,%esp
}
801069cb:	90                   	nop
801069cc:	c9                   	leave  
801069cd:	c3                   	ret    

801069ce <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe* tf)
{
801069ce:	f3 0f 1e fb          	endbr32 
801069d2:	55                   	push   %ebp
801069d3:	89 e5                	mov    %esp,%ebp
801069d5:	57                   	push   %edi
801069d6:	56                   	push   %esi
801069d7:	53                   	push   %ebx
801069d8:	83 ec 2c             	sub    $0x2c,%esp
    if (tf->trapno == T_SYSCALL) {
801069db:	8b 45 08             	mov    0x8(%ebp),%eax
801069de:	8b 40 30             	mov    0x30(%eax),%eax
801069e1:	83 f8 40             	cmp    $0x40,%eax
801069e4:	75 3b                	jne    80106a21 <trap+0x53>
        if (myproc()->killed)
801069e6:	e8 b6 d6 ff ff       	call   801040a1 <myproc>
801069eb:	8b 40 24             	mov    0x24(%eax),%eax
801069ee:	85 c0                	test   %eax,%eax
801069f0:	74 05                	je     801069f7 <trap+0x29>
            exit();
801069f2:	e8 4a db ff ff       	call   80104541 <exit>
        myproc()->tf = tf;
801069f7:	e8 a5 d6 ff ff       	call   801040a1 <myproc>
801069fc:	8b 55 08             	mov    0x8(%ebp),%edx
801069ff:	89 50 18             	mov    %edx,0x18(%eax)
        syscall();
80106a02:	e8 38 ed ff ff       	call   8010573f <syscall>
        if (myproc()->killed)
80106a07:	e8 95 d6 ff ff       	call   801040a1 <myproc>
80106a0c:	8b 40 24             	mov    0x24(%eax),%eax
80106a0f:	85 c0                	test   %eax,%eax
80106a11:	0f 84 5d 02 00 00    	je     80106c74 <trap+0x2a6>
            exit();
80106a17:	e8 25 db ff ff       	call   80104541 <exit>
        return;
80106a1c:	e9 53 02 00 00       	jmp    80106c74 <trap+0x2a6>
    }

    switch (tf->trapno) {
80106a21:	8b 45 08             	mov    0x8(%ebp),%eax
80106a24:	8b 40 30             	mov    0x30(%eax),%eax
80106a27:	83 e8 20             	sub    $0x20,%eax
80106a2a:	83 f8 1f             	cmp    $0x1f,%eax
80106a2d:	0f 87 09 01 00 00    	ja     80106b3c <trap+0x16e>
80106a33:	8b 04 85 44 b0 10 80 	mov    -0x7fef4fbc(,%eax,4),%eax
80106a3a:	3e ff e0             	notrack jmp *%eax
    case T_IRQ0 + IRQ_TIMER:
        if (cpuid() == 0) {
80106a3d:	e8 c4 d5 ff ff       	call   80104006 <cpuid>
80106a42:	85 c0                	test   %eax,%eax
80106a44:	75 3d                	jne    80106a83 <trap+0xb5>
            acquire(&tickslock);
80106a46:	83 ec 0c             	sub    $0xc,%esp
80106a49:	68 80 a6 11 80       	push   $0x8011a680
80106a4e:	e8 31 e6 ff ff       	call   80105084 <acquire>
80106a53:	83 c4 10             	add    $0x10,%esp
            ticks++;
80106a56:	a1 c0 ae 11 80       	mov    0x8011aec0,%eax
80106a5b:	83 c0 01             	add    $0x1,%eax
80106a5e:	a3 c0 ae 11 80       	mov    %eax,0x8011aec0
            wakeup(&ticks);
80106a63:	83 ec 0c             	sub    $0xc,%esp
80106a66:	68 c0 ae 11 80       	push   $0x8011aec0
80106a6b:	e8 ba e2 ff ff       	call   80104d2a <wakeup>
80106a70:	83 c4 10             	add    $0x10,%esp
            release(&tickslock);
80106a73:	83 ec 0c             	sub    $0xc,%esp
80106a76:	68 80 a6 11 80       	push   $0x8011a680
80106a7b:	e8 76 e6 ff ff       	call   801050f6 <release>
80106a80:	83 c4 10             	add    $0x10,%esp
        }
        lapiceoi();  // Acknowledge the interrupt
80106a83:	e8 95 c6 ff ff       	call   8010311d <lapiceoi>

        // After acknowledging the timer interrupt, check if we need to switch threads.
        struct proc* curproc = myproc();
80106a88:	e8 14 d6 ff ff       	call   801040a1 <myproc>
80106a8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (curproc && curproc->scheduler && (tf->cs & 3) == DPL_USER) {
80106a90:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106a94:	0f 84 59 01 00 00    	je     80106bf3 <trap+0x225>
80106a9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a9d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106aa3:	85 c0                	test   %eax,%eax
80106aa5:	0f 84 48 01 00 00    	je     80106bf3 <trap+0x225>
80106aab:	8b 45 08             	mov    0x8(%ebp),%eax
80106aae:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ab2:	0f b7 c0             	movzwl %ax,%eax
80106ab5:	83 e0 03             	and    $0x3,%eax
80106ab8:	83 f8 03             	cmp    $0x3,%eax
80106abb:	0f 85 32 01 00 00    	jne    80106bf3 <trap+0x225>
            // Only switch threads if the current process has a user-level scheduler
            // and the trap occurred in user mode.
            ((void(*)(void))curproc->scheduler)();  // Call the user-level scheduler
80106ac1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ac4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106aca:	ff d0                	call   *%eax
	    return;
80106acc:	e9 a4 01 00 00       	jmp    80106c75 <trap+0x2a7>
        }
        break;
    case T_IRQ0 + IRQ_IDE:
        ideintr();
80106ad1:	e8 5e be ff ff       	call   80102934 <ideintr>
        lapiceoi();
80106ad6:	e8 42 c6 ff ff       	call   8010311d <lapiceoi>
        break;
80106adb:	e9 14 01 00 00       	jmp    80106bf4 <trap+0x226>
    case T_IRQ0 + IRQ_IDE + 1:
        // Bochs generates spurious IDE1 interrupts.
        break;
    case T_IRQ0 + IRQ_KBD:
        kbdintr();
80106ae0:	e8 6e c4 ff ff       	call   80102f53 <kbdintr>
        lapiceoi();
80106ae5:	e8 33 c6 ff ff       	call   8010311d <lapiceoi>
        break;
80106aea:	e9 05 01 00 00       	jmp    80106bf4 <trap+0x226>
    case T_IRQ0 + IRQ_COM1:
        uartintr();
80106aef:	e8 62 03 00 00       	call   80106e56 <uartintr>
        lapiceoi();
80106af4:	e8 24 c6 ff ff       	call   8010311d <lapiceoi>
        break;
80106af9:	e9 f6 00 00 00       	jmp    80106bf4 <trap+0x226>
    case T_IRQ0 + 0xB:
        i8254_intr();
80106afe:	e8 30 2c 00 00       	call   80109733 <i8254_intr>
        lapiceoi();
80106b03:	e8 15 c6 ff ff       	call   8010311d <lapiceoi>
        break;
80106b08:	e9 e7 00 00 00       	jmp    80106bf4 <trap+0x226>
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b10:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106b13:	8b 45 08             	mov    0x8(%ebp),%eax
80106b16:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b1a:	0f b7 d8             	movzwl %ax,%ebx
80106b1d:	e8 e4 d4 ff ff       	call   80104006 <cpuid>
80106b22:	56                   	push   %esi
80106b23:	53                   	push   %ebx
80106b24:	50                   	push   %eax
80106b25:	68 a4 af 10 80       	push   $0x8010afa4
80106b2a:	e8 dd 98 ff ff       	call   8010040c <cprintf>
80106b2f:	83 c4 10             	add    $0x10,%esp
        lapiceoi();
80106b32:	e8 e6 c5 ff ff       	call   8010311d <lapiceoi>
        break;
80106b37:	e9 b8 00 00 00       	jmp    80106bf4 <trap+0x226>

        //PAGEBREAK: 13
    default:
        if (myproc() == 0 || (tf->cs & 3) == 0) {
80106b3c:	e8 60 d5 ff ff       	call   801040a1 <myproc>
80106b41:	85 c0                	test   %eax,%eax
80106b43:	74 11                	je     80106b56 <trap+0x188>
80106b45:	8b 45 08             	mov    0x8(%ebp),%eax
80106b48:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b4c:	0f b7 c0             	movzwl %ax,%eax
80106b4f:	83 e0 03             	and    $0x3,%eax
80106b52:	85 c0                	test   %eax,%eax
80106b54:	75 39                	jne    80106b8f <trap+0x1c1>
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b56:	e8 cc fc ff ff       	call   80106827 <rcr2>
80106b5b:	89 c3                	mov    %eax,%ebx
80106b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b60:	8b 70 38             	mov    0x38(%eax),%esi
80106b63:	e8 9e d4 ff ff       	call   80104006 <cpuid>
80106b68:	8b 55 08             	mov    0x8(%ebp),%edx
80106b6b:	8b 52 30             	mov    0x30(%edx),%edx
80106b6e:	83 ec 0c             	sub    $0xc,%esp
80106b71:	53                   	push   %ebx
80106b72:	56                   	push   %esi
80106b73:	50                   	push   %eax
80106b74:	52                   	push   %edx
80106b75:	68 c8 af 10 80       	push   $0x8010afc8
80106b7a:	e8 8d 98 ff ff       	call   8010040c <cprintf>
80106b7f:	83 c4 20             	add    $0x20,%esp
                tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
80106b82:	83 ec 0c             	sub    $0xc,%esp
80106b85:	68 fa af 10 80       	push   $0x8010affa
80106b8a:	e8 36 9a ff ff       	call   801005c5 <panic>
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b8f:	e8 93 fc ff ff       	call   80106827 <rcr2>
80106b94:	89 c6                	mov    %eax,%esi
80106b96:	8b 45 08             	mov    0x8(%ebp),%eax
80106b99:	8b 40 38             	mov    0x38(%eax),%eax
80106b9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106b9f:	e8 62 d4 ff ff       	call   80104006 <cpuid>
80106ba4:	89 c3                	mov    %eax,%ebx
80106ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ba9:	8b 48 34             	mov    0x34(%eax),%ecx
80106bac:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106baf:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb2:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106bb5:	e8 e7 d4 ff ff       	call   801040a1 <myproc>
80106bba:	8d 50 6c             	lea    0x6c(%eax),%edx
80106bbd:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106bc0:	e8 dc d4 ff ff       	call   801040a1 <myproc>
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106bc5:	8b 40 10             	mov    0x10(%eax),%eax
80106bc8:	56                   	push   %esi
80106bc9:	ff 75 d4             	pushl  -0x2c(%ebp)
80106bcc:	53                   	push   %ebx
80106bcd:	ff 75 d0             	pushl  -0x30(%ebp)
80106bd0:	57                   	push   %edi
80106bd1:	ff 75 cc             	pushl  -0x34(%ebp)
80106bd4:	50                   	push   %eax
80106bd5:	68 00 b0 10 80       	push   $0x8010b000
80106bda:	e8 2d 98 ff ff       	call   8010040c <cprintf>
80106bdf:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
        myproc()->killed = 1;
80106be2:	e8 ba d4 ff ff       	call   801040a1 <myproc>
80106be7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106bee:	eb 04                	jmp    80106bf4 <trap+0x226>
        break;
80106bf0:	90                   	nop
80106bf1:	eb 01                	jmp    80106bf4 <trap+0x226>
        break;
80106bf3:	90                   	nop
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106bf4:	e8 a8 d4 ff ff       	call   801040a1 <myproc>
80106bf9:	85 c0                	test   %eax,%eax
80106bfb:	74 23                	je     80106c20 <trap+0x252>
80106bfd:	e8 9f d4 ff ff       	call   801040a1 <myproc>
80106c02:	8b 40 24             	mov    0x24(%eax),%eax
80106c05:	85 c0                	test   %eax,%eax
80106c07:	74 17                	je     80106c20 <trap+0x252>
80106c09:	8b 45 08             	mov    0x8(%ebp),%eax
80106c0c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c10:	0f b7 c0             	movzwl %ax,%eax
80106c13:	83 e0 03             	and    $0x3,%eax
80106c16:	83 f8 03             	cmp    $0x3,%eax
80106c19:	75 05                	jne    80106c20 <trap+0x252>
        exit();
80106c1b:	e8 21 d9 ff ff       	call   80104541 <exit>

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
80106c20:	e8 7c d4 ff ff       	call   801040a1 <myproc>
80106c25:	85 c0                	test   %eax,%eax
80106c27:	74 1d                	je     80106c46 <trap+0x278>
80106c29:	e8 73 d4 ff ff       	call   801040a1 <myproc>
80106c2e:	8b 40 0c             	mov    0xc(%eax),%eax
80106c31:	83 f8 04             	cmp    $0x4,%eax
80106c34:	75 10                	jne    80106c46 <trap+0x278>
        tf->trapno == T_IRQ0 + IRQ_TIMER)
80106c36:	8b 45 08             	mov    0x8(%ebp),%eax
80106c39:	8b 40 30             	mov    0x30(%eax),%eax
    if (myproc() && myproc()->state == RUNNING &&
80106c3c:	83 f8 20             	cmp    $0x20,%eax
80106c3f:	75 05                	jne    80106c46 <trap+0x278>
        yield();
80106c41:	e8 6a df ff ff       	call   80104bb0 <yield>

    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80106c46:	e8 56 d4 ff ff       	call   801040a1 <myproc>
80106c4b:	85 c0                	test   %eax,%eax
80106c4d:	74 26                	je     80106c75 <trap+0x2a7>
80106c4f:	e8 4d d4 ff ff       	call   801040a1 <myproc>
80106c54:	8b 40 24             	mov    0x24(%eax),%eax
80106c57:	85 c0                	test   %eax,%eax
80106c59:	74 1a                	je     80106c75 <trap+0x2a7>
80106c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c5e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c62:	0f b7 c0             	movzwl %ax,%eax
80106c65:	83 e0 03             	and    $0x3,%eax
80106c68:	83 f8 03             	cmp    $0x3,%eax
80106c6b:	75 08                	jne    80106c75 <trap+0x2a7>
        exit();
80106c6d:	e8 cf d8 ff ff       	call   80104541 <exit>
80106c72:	eb 01                	jmp    80106c75 <trap+0x2a7>
        return;
80106c74:	90                   	nop
}
80106c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106c78:	5b                   	pop    %ebx
80106c79:	5e                   	pop    %esi
80106c7a:	5f                   	pop    %edi
80106c7b:	5d                   	pop    %ebp
80106c7c:	c3                   	ret    

80106c7d <inb>:
{
80106c7d:	55                   	push   %ebp
80106c7e:	89 e5                	mov    %esp,%ebp
80106c80:	83 ec 14             	sub    $0x14,%esp
80106c83:	8b 45 08             	mov    0x8(%ebp),%eax
80106c86:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c8a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106c8e:	89 c2                	mov    %eax,%edx
80106c90:	ec                   	in     (%dx),%al
80106c91:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106c94:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106c98:	c9                   	leave  
80106c99:	c3                   	ret    

80106c9a <outb>:
{
80106c9a:	55                   	push   %ebp
80106c9b:	89 e5                	mov    %esp,%ebp
80106c9d:	83 ec 08             	sub    $0x8,%esp
80106ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca3:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ca6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106caa:	89 d0                	mov    %edx,%eax
80106cac:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106caf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106cb3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106cb7:	ee                   	out    %al,(%dx)
}
80106cb8:	90                   	nop
80106cb9:	c9                   	leave  
80106cba:	c3                   	ret    

80106cbb <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106cbb:	f3 0f 1e fb          	endbr32 
80106cbf:	55                   	push   %ebp
80106cc0:	89 e5                	mov    %esp,%ebp
80106cc2:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106cc5:	6a 00                	push   $0x0
80106cc7:	68 fa 03 00 00       	push   $0x3fa
80106ccc:	e8 c9 ff ff ff       	call   80106c9a <outb>
80106cd1:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106cd4:	68 80 00 00 00       	push   $0x80
80106cd9:	68 fb 03 00 00       	push   $0x3fb
80106cde:	e8 b7 ff ff ff       	call   80106c9a <outb>
80106ce3:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106ce6:	6a 0c                	push   $0xc
80106ce8:	68 f8 03 00 00       	push   $0x3f8
80106ced:	e8 a8 ff ff ff       	call   80106c9a <outb>
80106cf2:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106cf5:	6a 00                	push   $0x0
80106cf7:	68 f9 03 00 00       	push   $0x3f9
80106cfc:	e8 99 ff ff ff       	call   80106c9a <outb>
80106d01:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106d04:	6a 03                	push   $0x3
80106d06:	68 fb 03 00 00       	push   $0x3fb
80106d0b:	e8 8a ff ff ff       	call   80106c9a <outb>
80106d10:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106d13:	6a 00                	push   $0x0
80106d15:	68 fc 03 00 00       	push   $0x3fc
80106d1a:	e8 7b ff ff ff       	call   80106c9a <outb>
80106d1f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106d22:	6a 01                	push   $0x1
80106d24:	68 f9 03 00 00       	push   $0x3f9
80106d29:	e8 6c ff ff ff       	call   80106c9a <outb>
80106d2e:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106d31:	68 fd 03 00 00       	push   $0x3fd
80106d36:	e8 42 ff ff ff       	call   80106c7d <inb>
80106d3b:	83 c4 04             	add    $0x4,%esp
80106d3e:	3c ff                	cmp    $0xff,%al
80106d40:	74 61                	je     80106da3 <uartinit+0xe8>
    return;
  uart = 1;
80106d42:	c7 05 a4 00 11 80 01 	movl   $0x1,0x801100a4
80106d49:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106d4c:	68 fa 03 00 00       	push   $0x3fa
80106d51:	e8 27 ff ff ff       	call   80106c7d <inb>
80106d56:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106d59:	68 f8 03 00 00       	push   $0x3f8
80106d5e:	e8 1a ff ff ff       	call   80106c7d <inb>
80106d63:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80106d66:	83 ec 08             	sub    $0x8,%esp
80106d69:	6a 00                	push   $0x0
80106d6b:	6a 04                	push   $0x4
80106d6d:	e8 92 be ff ff       	call   80102c04 <ioapicenable>
80106d72:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d75:	c7 45 f4 c4 b0 10 80 	movl   $0x8010b0c4,-0xc(%ebp)
80106d7c:	eb 19                	jmp    80106d97 <uartinit+0xdc>
    uartputc(*p);
80106d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d81:	0f b6 00             	movzbl (%eax),%eax
80106d84:	0f be c0             	movsbl %al,%eax
80106d87:	83 ec 0c             	sub    $0xc,%esp
80106d8a:	50                   	push   %eax
80106d8b:	e8 16 00 00 00       	call   80106da6 <uartputc>
80106d90:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106d93:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d9a:	0f b6 00             	movzbl (%eax),%eax
80106d9d:	84 c0                	test   %al,%al
80106d9f:	75 dd                	jne    80106d7e <uartinit+0xc3>
80106da1:	eb 01                	jmp    80106da4 <uartinit+0xe9>
    return;
80106da3:	90                   	nop
}
80106da4:	c9                   	leave  
80106da5:	c3                   	ret    

80106da6 <uartputc>:

void
uartputc(int c)
{
80106da6:	f3 0f 1e fb          	endbr32 
80106daa:	55                   	push   %ebp
80106dab:	89 e5                	mov    %esp,%ebp
80106dad:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106db0:	a1 a4 00 11 80       	mov    0x801100a4,%eax
80106db5:	85 c0                	test   %eax,%eax
80106db7:	74 53                	je     80106e0c <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106db9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106dc0:	eb 11                	jmp    80106dd3 <uartputc+0x2d>
    microdelay(10);
80106dc2:	83 ec 0c             	sub    $0xc,%esp
80106dc5:	6a 0a                	push   $0xa
80106dc7:	e8 70 c3 ff ff       	call   8010313c <microdelay>
80106dcc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106dcf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106dd3:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106dd7:	7f 1a                	jg     80106df3 <uartputc+0x4d>
80106dd9:	83 ec 0c             	sub    $0xc,%esp
80106ddc:	68 fd 03 00 00       	push   $0x3fd
80106de1:	e8 97 fe ff ff       	call   80106c7d <inb>
80106de6:	83 c4 10             	add    $0x10,%esp
80106de9:	0f b6 c0             	movzbl %al,%eax
80106dec:	83 e0 20             	and    $0x20,%eax
80106def:	85 c0                	test   %eax,%eax
80106df1:	74 cf                	je     80106dc2 <uartputc+0x1c>
  outb(COM1+0, c);
80106df3:	8b 45 08             	mov    0x8(%ebp),%eax
80106df6:	0f b6 c0             	movzbl %al,%eax
80106df9:	83 ec 08             	sub    $0x8,%esp
80106dfc:	50                   	push   %eax
80106dfd:	68 f8 03 00 00       	push   $0x3f8
80106e02:	e8 93 fe ff ff       	call   80106c9a <outb>
80106e07:	83 c4 10             	add    $0x10,%esp
80106e0a:	eb 01                	jmp    80106e0d <uartputc+0x67>
    return;
80106e0c:	90                   	nop
}
80106e0d:	c9                   	leave  
80106e0e:	c3                   	ret    

80106e0f <uartgetc>:

static int
uartgetc(void)
{
80106e0f:	f3 0f 1e fb          	endbr32 
80106e13:	55                   	push   %ebp
80106e14:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106e16:	a1 a4 00 11 80       	mov    0x801100a4,%eax
80106e1b:	85 c0                	test   %eax,%eax
80106e1d:	75 07                	jne    80106e26 <uartgetc+0x17>
    return -1;
80106e1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e24:	eb 2e                	jmp    80106e54 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80106e26:	68 fd 03 00 00       	push   $0x3fd
80106e2b:	e8 4d fe ff ff       	call   80106c7d <inb>
80106e30:	83 c4 04             	add    $0x4,%esp
80106e33:	0f b6 c0             	movzbl %al,%eax
80106e36:	83 e0 01             	and    $0x1,%eax
80106e39:	85 c0                	test   %eax,%eax
80106e3b:	75 07                	jne    80106e44 <uartgetc+0x35>
    return -1;
80106e3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e42:	eb 10                	jmp    80106e54 <uartgetc+0x45>
  return inb(COM1+0);
80106e44:	68 f8 03 00 00       	push   $0x3f8
80106e49:	e8 2f fe ff ff       	call   80106c7d <inb>
80106e4e:	83 c4 04             	add    $0x4,%esp
80106e51:	0f b6 c0             	movzbl %al,%eax
}
80106e54:	c9                   	leave  
80106e55:	c3                   	ret    

80106e56 <uartintr>:

void
uartintr(void)
{
80106e56:	f3 0f 1e fb          	endbr32 
80106e5a:	55                   	push   %ebp
80106e5b:	89 e5                	mov    %esp,%ebp
80106e5d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106e60:	83 ec 0c             	sub    $0xc,%esp
80106e63:	68 0f 6e 10 80       	push   $0x80106e0f
80106e68:	e8 93 99 ff ff       	call   80100800 <consoleintr>
80106e6d:	83 c4 10             	add    $0x10,%esp
}
80106e70:	90                   	nop
80106e71:	c9                   	leave  
80106e72:	c3                   	ret    

80106e73 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $0
80106e75:	6a 00                	push   $0x0
  jmp alltraps
80106e77:	e9 5e f9 ff ff       	jmp    801067da <alltraps>

80106e7c <vector1>:
.globl vector1
vector1:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $1
80106e7e:	6a 01                	push   $0x1
  jmp alltraps
80106e80:	e9 55 f9 ff ff       	jmp    801067da <alltraps>

80106e85 <vector2>:
.globl vector2
vector2:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $2
80106e87:	6a 02                	push   $0x2
  jmp alltraps
80106e89:	e9 4c f9 ff ff       	jmp    801067da <alltraps>

80106e8e <vector3>:
.globl vector3
vector3:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $3
80106e90:	6a 03                	push   $0x3
  jmp alltraps
80106e92:	e9 43 f9 ff ff       	jmp    801067da <alltraps>

80106e97 <vector4>:
.globl vector4
vector4:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $4
80106e99:	6a 04                	push   $0x4
  jmp alltraps
80106e9b:	e9 3a f9 ff ff       	jmp    801067da <alltraps>

80106ea0 <vector5>:
.globl vector5
vector5:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $5
80106ea2:	6a 05                	push   $0x5
  jmp alltraps
80106ea4:	e9 31 f9 ff ff       	jmp    801067da <alltraps>

80106ea9 <vector6>:
.globl vector6
vector6:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $6
80106eab:	6a 06                	push   $0x6
  jmp alltraps
80106ead:	e9 28 f9 ff ff       	jmp    801067da <alltraps>

80106eb2 <vector7>:
.globl vector7
vector7:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $7
80106eb4:	6a 07                	push   $0x7
  jmp alltraps
80106eb6:	e9 1f f9 ff ff       	jmp    801067da <alltraps>

80106ebb <vector8>:
.globl vector8
vector8:
  pushl $8
80106ebb:	6a 08                	push   $0x8
  jmp alltraps
80106ebd:	e9 18 f9 ff ff       	jmp    801067da <alltraps>

80106ec2 <vector9>:
.globl vector9
vector9:
  pushl $0
80106ec2:	6a 00                	push   $0x0
  pushl $9
80106ec4:	6a 09                	push   $0x9
  jmp alltraps
80106ec6:	e9 0f f9 ff ff       	jmp    801067da <alltraps>

80106ecb <vector10>:
.globl vector10
vector10:
  pushl $10
80106ecb:	6a 0a                	push   $0xa
  jmp alltraps
80106ecd:	e9 08 f9 ff ff       	jmp    801067da <alltraps>

80106ed2 <vector11>:
.globl vector11
vector11:
  pushl $11
80106ed2:	6a 0b                	push   $0xb
  jmp alltraps
80106ed4:	e9 01 f9 ff ff       	jmp    801067da <alltraps>

80106ed9 <vector12>:
.globl vector12
vector12:
  pushl $12
80106ed9:	6a 0c                	push   $0xc
  jmp alltraps
80106edb:	e9 fa f8 ff ff       	jmp    801067da <alltraps>

80106ee0 <vector13>:
.globl vector13
vector13:
  pushl $13
80106ee0:	6a 0d                	push   $0xd
  jmp alltraps
80106ee2:	e9 f3 f8 ff ff       	jmp    801067da <alltraps>

80106ee7 <vector14>:
.globl vector14
vector14:
  pushl $14
80106ee7:	6a 0e                	push   $0xe
  jmp alltraps
80106ee9:	e9 ec f8 ff ff       	jmp    801067da <alltraps>

80106eee <vector15>:
.globl vector15
vector15:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $15
80106ef0:	6a 0f                	push   $0xf
  jmp alltraps
80106ef2:	e9 e3 f8 ff ff       	jmp    801067da <alltraps>

80106ef7 <vector16>:
.globl vector16
vector16:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $16
80106ef9:	6a 10                	push   $0x10
  jmp alltraps
80106efb:	e9 da f8 ff ff       	jmp    801067da <alltraps>

80106f00 <vector17>:
.globl vector17
vector17:
  pushl $17
80106f00:	6a 11                	push   $0x11
  jmp alltraps
80106f02:	e9 d3 f8 ff ff       	jmp    801067da <alltraps>

80106f07 <vector18>:
.globl vector18
vector18:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $18
80106f09:	6a 12                	push   $0x12
  jmp alltraps
80106f0b:	e9 ca f8 ff ff       	jmp    801067da <alltraps>

80106f10 <vector19>:
.globl vector19
vector19:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $19
80106f12:	6a 13                	push   $0x13
  jmp alltraps
80106f14:	e9 c1 f8 ff ff       	jmp    801067da <alltraps>

80106f19 <vector20>:
.globl vector20
vector20:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $20
80106f1b:	6a 14                	push   $0x14
  jmp alltraps
80106f1d:	e9 b8 f8 ff ff       	jmp    801067da <alltraps>

80106f22 <vector21>:
.globl vector21
vector21:
  pushl $0
80106f22:	6a 00                	push   $0x0
  pushl $21
80106f24:	6a 15                	push   $0x15
  jmp alltraps
80106f26:	e9 af f8 ff ff       	jmp    801067da <alltraps>

80106f2b <vector22>:
.globl vector22
vector22:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $22
80106f2d:	6a 16                	push   $0x16
  jmp alltraps
80106f2f:	e9 a6 f8 ff ff       	jmp    801067da <alltraps>

80106f34 <vector23>:
.globl vector23
vector23:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $23
80106f36:	6a 17                	push   $0x17
  jmp alltraps
80106f38:	e9 9d f8 ff ff       	jmp    801067da <alltraps>

80106f3d <vector24>:
.globl vector24
vector24:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $24
80106f3f:	6a 18                	push   $0x18
  jmp alltraps
80106f41:	e9 94 f8 ff ff       	jmp    801067da <alltraps>

80106f46 <vector25>:
.globl vector25
vector25:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $25
80106f48:	6a 19                	push   $0x19
  jmp alltraps
80106f4a:	e9 8b f8 ff ff       	jmp    801067da <alltraps>

80106f4f <vector26>:
.globl vector26
vector26:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $26
80106f51:	6a 1a                	push   $0x1a
  jmp alltraps
80106f53:	e9 82 f8 ff ff       	jmp    801067da <alltraps>

80106f58 <vector27>:
.globl vector27
vector27:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $27
80106f5a:	6a 1b                	push   $0x1b
  jmp alltraps
80106f5c:	e9 79 f8 ff ff       	jmp    801067da <alltraps>

80106f61 <vector28>:
.globl vector28
vector28:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $28
80106f63:	6a 1c                	push   $0x1c
  jmp alltraps
80106f65:	e9 70 f8 ff ff       	jmp    801067da <alltraps>

80106f6a <vector29>:
.globl vector29
vector29:
  pushl $0
80106f6a:	6a 00                	push   $0x0
  pushl $29
80106f6c:	6a 1d                	push   $0x1d
  jmp alltraps
80106f6e:	e9 67 f8 ff ff       	jmp    801067da <alltraps>

80106f73 <vector30>:
.globl vector30
vector30:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $30
80106f75:	6a 1e                	push   $0x1e
  jmp alltraps
80106f77:	e9 5e f8 ff ff       	jmp    801067da <alltraps>

80106f7c <vector31>:
.globl vector31
vector31:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $31
80106f7e:	6a 1f                	push   $0x1f
  jmp alltraps
80106f80:	e9 55 f8 ff ff       	jmp    801067da <alltraps>

80106f85 <vector32>:
.globl vector32
vector32:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $32
80106f87:	6a 20                	push   $0x20
  jmp alltraps
80106f89:	e9 4c f8 ff ff       	jmp    801067da <alltraps>

80106f8e <vector33>:
.globl vector33
vector33:
  pushl $0
80106f8e:	6a 00                	push   $0x0
  pushl $33
80106f90:	6a 21                	push   $0x21
  jmp alltraps
80106f92:	e9 43 f8 ff ff       	jmp    801067da <alltraps>

80106f97 <vector34>:
.globl vector34
vector34:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $34
80106f99:	6a 22                	push   $0x22
  jmp alltraps
80106f9b:	e9 3a f8 ff ff       	jmp    801067da <alltraps>

80106fa0 <vector35>:
.globl vector35
vector35:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $35
80106fa2:	6a 23                	push   $0x23
  jmp alltraps
80106fa4:	e9 31 f8 ff ff       	jmp    801067da <alltraps>

80106fa9 <vector36>:
.globl vector36
vector36:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $36
80106fab:	6a 24                	push   $0x24
  jmp alltraps
80106fad:	e9 28 f8 ff ff       	jmp    801067da <alltraps>

80106fb2 <vector37>:
.globl vector37
vector37:
  pushl $0
80106fb2:	6a 00                	push   $0x0
  pushl $37
80106fb4:	6a 25                	push   $0x25
  jmp alltraps
80106fb6:	e9 1f f8 ff ff       	jmp    801067da <alltraps>

80106fbb <vector38>:
.globl vector38
vector38:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $38
80106fbd:	6a 26                	push   $0x26
  jmp alltraps
80106fbf:	e9 16 f8 ff ff       	jmp    801067da <alltraps>

80106fc4 <vector39>:
.globl vector39
vector39:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $39
80106fc6:	6a 27                	push   $0x27
  jmp alltraps
80106fc8:	e9 0d f8 ff ff       	jmp    801067da <alltraps>

80106fcd <vector40>:
.globl vector40
vector40:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $40
80106fcf:	6a 28                	push   $0x28
  jmp alltraps
80106fd1:	e9 04 f8 ff ff       	jmp    801067da <alltraps>

80106fd6 <vector41>:
.globl vector41
vector41:
  pushl $0
80106fd6:	6a 00                	push   $0x0
  pushl $41
80106fd8:	6a 29                	push   $0x29
  jmp alltraps
80106fda:	e9 fb f7 ff ff       	jmp    801067da <alltraps>

80106fdf <vector42>:
.globl vector42
vector42:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $42
80106fe1:	6a 2a                	push   $0x2a
  jmp alltraps
80106fe3:	e9 f2 f7 ff ff       	jmp    801067da <alltraps>

80106fe8 <vector43>:
.globl vector43
vector43:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $43
80106fea:	6a 2b                	push   $0x2b
  jmp alltraps
80106fec:	e9 e9 f7 ff ff       	jmp    801067da <alltraps>

80106ff1 <vector44>:
.globl vector44
vector44:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $44
80106ff3:	6a 2c                	push   $0x2c
  jmp alltraps
80106ff5:	e9 e0 f7 ff ff       	jmp    801067da <alltraps>

80106ffa <vector45>:
.globl vector45
vector45:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $45
80106ffc:	6a 2d                	push   $0x2d
  jmp alltraps
80106ffe:	e9 d7 f7 ff ff       	jmp    801067da <alltraps>

80107003 <vector46>:
.globl vector46
vector46:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $46
80107005:	6a 2e                	push   $0x2e
  jmp alltraps
80107007:	e9 ce f7 ff ff       	jmp    801067da <alltraps>

8010700c <vector47>:
.globl vector47
vector47:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $47
8010700e:	6a 2f                	push   $0x2f
  jmp alltraps
80107010:	e9 c5 f7 ff ff       	jmp    801067da <alltraps>

80107015 <vector48>:
.globl vector48
vector48:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $48
80107017:	6a 30                	push   $0x30
  jmp alltraps
80107019:	e9 bc f7 ff ff       	jmp    801067da <alltraps>

8010701e <vector49>:
.globl vector49
vector49:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $49
80107020:	6a 31                	push   $0x31
  jmp alltraps
80107022:	e9 b3 f7 ff ff       	jmp    801067da <alltraps>

80107027 <vector50>:
.globl vector50
vector50:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $50
80107029:	6a 32                	push   $0x32
  jmp alltraps
8010702b:	e9 aa f7 ff ff       	jmp    801067da <alltraps>

80107030 <vector51>:
.globl vector51
vector51:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $51
80107032:	6a 33                	push   $0x33
  jmp alltraps
80107034:	e9 a1 f7 ff ff       	jmp    801067da <alltraps>

80107039 <vector52>:
.globl vector52
vector52:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $52
8010703b:	6a 34                	push   $0x34
  jmp alltraps
8010703d:	e9 98 f7 ff ff       	jmp    801067da <alltraps>

80107042 <vector53>:
.globl vector53
vector53:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $53
80107044:	6a 35                	push   $0x35
  jmp alltraps
80107046:	e9 8f f7 ff ff       	jmp    801067da <alltraps>

8010704b <vector54>:
.globl vector54
vector54:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $54
8010704d:	6a 36                	push   $0x36
  jmp alltraps
8010704f:	e9 86 f7 ff ff       	jmp    801067da <alltraps>

80107054 <vector55>:
.globl vector55
vector55:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $55
80107056:	6a 37                	push   $0x37
  jmp alltraps
80107058:	e9 7d f7 ff ff       	jmp    801067da <alltraps>

8010705d <vector56>:
.globl vector56
vector56:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $56
8010705f:	6a 38                	push   $0x38
  jmp alltraps
80107061:	e9 74 f7 ff ff       	jmp    801067da <alltraps>

80107066 <vector57>:
.globl vector57
vector57:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $57
80107068:	6a 39                	push   $0x39
  jmp alltraps
8010706a:	e9 6b f7 ff ff       	jmp    801067da <alltraps>

8010706f <vector58>:
.globl vector58
vector58:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $58
80107071:	6a 3a                	push   $0x3a
  jmp alltraps
80107073:	e9 62 f7 ff ff       	jmp    801067da <alltraps>

80107078 <vector59>:
.globl vector59
vector59:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $59
8010707a:	6a 3b                	push   $0x3b
  jmp alltraps
8010707c:	e9 59 f7 ff ff       	jmp    801067da <alltraps>

80107081 <vector60>:
.globl vector60
vector60:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $60
80107083:	6a 3c                	push   $0x3c
  jmp alltraps
80107085:	e9 50 f7 ff ff       	jmp    801067da <alltraps>

8010708a <vector61>:
.globl vector61
vector61:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $61
8010708c:	6a 3d                	push   $0x3d
  jmp alltraps
8010708e:	e9 47 f7 ff ff       	jmp    801067da <alltraps>

80107093 <vector62>:
.globl vector62
vector62:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $62
80107095:	6a 3e                	push   $0x3e
  jmp alltraps
80107097:	e9 3e f7 ff ff       	jmp    801067da <alltraps>

8010709c <vector63>:
.globl vector63
vector63:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $63
8010709e:	6a 3f                	push   $0x3f
  jmp alltraps
801070a0:	e9 35 f7 ff ff       	jmp    801067da <alltraps>

801070a5 <vector64>:
.globl vector64
vector64:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $64
801070a7:	6a 40                	push   $0x40
  jmp alltraps
801070a9:	e9 2c f7 ff ff       	jmp    801067da <alltraps>

801070ae <vector65>:
.globl vector65
vector65:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $65
801070b0:	6a 41                	push   $0x41
  jmp alltraps
801070b2:	e9 23 f7 ff ff       	jmp    801067da <alltraps>

801070b7 <vector66>:
.globl vector66
vector66:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $66
801070b9:	6a 42                	push   $0x42
  jmp alltraps
801070bb:	e9 1a f7 ff ff       	jmp    801067da <alltraps>

801070c0 <vector67>:
.globl vector67
vector67:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $67
801070c2:	6a 43                	push   $0x43
  jmp alltraps
801070c4:	e9 11 f7 ff ff       	jmp    801067da <alltraps>

801070c9 <vector68>:
.globl vector68
vector68:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $68
801070cb:	6a 44                	push   $0x44
  jmp alltraps
801070cd:	e9 08 f7 ff ff       	jmp    801067da <alltraps>

801070d2 <vector69>:
.globl vector69
vector69:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $69
801070d4:	6a 45                	push   $0x45
  jmp alltraps
801070d6:	e9 ff f6 ff ff       	jmp    801067da <alltraps>

801070db <vector70>:
.globl vector70
vector70:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $70
801070dd:	6a 46                	push   $0x46
  jmp alltraps
801070df:	e9 f6 f6 ff ff       	jmp    801067da <alltraps>

801070e4 <vector71>:
.globl vector71
vector71:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $71
801070e6:	6a 47                	push   $0x47
  jmp alltraps
801070e8:	e9 ed f6 ff ff       	jmp    801067da <alltraps>

801070ed <vector72>:
.globl vector72
vector72:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $72
801070ef:	6a 48                	push   $0x48
  jmp alltraps
801070f1:	e9 e4 f6 ff ff       	jmp    801067da <alltraps>

801070f6 <vector73>:
.globl vector73
vector73:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $73
801070f8:	6a 49                	push   $0x49
  jmp alltraps
801070fa:	e9 db f6 ff ff       	jmp    801067da <alltraps>

801070ff <vector74>:
.globl vector74
vector74:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $74
80107101:	6a 4a                	push   $0x4a
  jmp alltraps
80107103:	e9 d2 f6 ff ff       	jmp    801067da <alltraps>

80107108 <vector75>:
.globl vector75
vector75:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $75
8010710a:	6a 4b                	push   $0x4b
  jmp alltraps
8010710c:	e9 c9 f6 ff ff       	jmp    801067da <alltraps>

80107111 <vector76>:
.globl vector76
vector76:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $76
80107113:	6a 4c                	push   $0x4c
  jmp alltraps
80107115:	e9 c0 f6 ff ff       	jmp    801067da <alltraps>

8010711a <vector77>:
.globl vector77
vector77:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $77
8010711c:	6a 4d                	push   $0x4d
  jmp alltraps
8010711e:	e9 b7 f6 ff ff       	jmp    801067da <alltraps>

80107123 <vector78>:
.globl vector78
vector78:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $78
80107125:	6a 4e                	push   $0x4e
  jmp alltraps
80107127:	e9 ae f6 ff ff       	jmp    801067da <alltraps>

8010712c <vector79>:
.globl vector79
vector79:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $79
8010712e:	6a 4f                	push   $0x4f
  jmp alltraps
80107130:	e9 a5 f6 ff ff       	jmp    801067da <alltraps>

80107135 <vector80>:
.globl vector80
vector80:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $80
80107137:	6a 50                	push   $0x50
  jmp alltraps
80107139:	e9 9c f6 ff ff       	jmp    801067da <alltraps>

8010713e <vector81>:
.globl vector81
vector81:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $81
80107140:	6a 51                	push   $0x51
  jmp alltraps
80107142:	e9 93 f6 ff ff       	jmp    801067da <alltraps>

80107147 <vector82>:
.globl vector82
vector82:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $82
80107149:	6a 52                	push   $0x52
  jmp alltraps
8010714b:	e9 8a f6 ff ff       	jmp    801067da <alltraps>

80107150 <vector83>:
.globl vector83
vector83:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $83
80107152:	6a 53                	push   $0x53
  jmp alltraps
80107154:	e9 81 f6 ff ff       	jmp    801067da <alltraps>

80107159 <vector84>:
.globl vector84
vector84:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $84
8010715b:	6a 54                	push   $0x54
  jmp alltraps
8010715d:	e9 78 f6 ff ff       	jmp    801067da <alltraps>

80107162 <vector85>:
.globl vector85
vector85:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $85
80107164:	6a 55                	push   $0x55
  jmp alltraps
80107166:	e9 6f f6 ff ff       	jmp    801067da <alltraps>

8010716b <vector86>:
.globl vector86
vector86:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $86
8010716d:	6a 56                	push   $0x56
  jmp alltraps
8010716f:	e9 66 f6 ff ff       	jmp    801067da <alltraps>

80107174 <vector87>:
.globl vector87
vector87:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $87
80107176:	6a 57                	push   $0x57
  jmp alltraps
80107178:	e9 5d f6 ff ff       	jmp    801067da <alltraps>

8010717d <vector88>:
.globl vector88
vector88:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $88
8010717f:	6a 58                	push   $0x58
  jmp alltraps
80107181:	e9 54 f6 ff ff       	jmp    801067da <alltraps>

80107186 <vector89>:
.globl vector89
vector89:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $89
80107188:	6a 59                	push   $0x59
  jmp alltraps
8010718a:	e9 4b f6 ff ff       	jmp    801067da <alltraps>

8010718f <vector90>:
.globl vector90
vector90:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $90
80107191:	6a 5a                	push   $0x5a
  jmp alltraps
80107193:	e9 42 f6 ff ff       	jmp    801067da <alltraps>

80107198 <vector91>:
.globl vector91
vector91:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $91
8010719a:	6a 5b                	push   $0x5b
  jmp alltraps
8010719c:	e9 39 f6 ff ff       	jmp    801067da <alltraps>

801071a1 <vector92>:
.globl vector92
vector92:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $92
801071a3:	6a 5c                	push   $0x5c
  jmp alltraps
801071a5:	e9 30 f6 ff ff       	jmp    801067da <alltraps>

801071aa <vector93>:
.globl vector93
vector93:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $93
801071ac:	6a 5d                	push   $0x5d
  jmp alltraps
801071ae:	e9 27 f6 ff ff       	jmp    801067da <alltraps>

801071b3 <vector94>:
.globl vector94
vector94:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $94
801071b5:	6a 5e                	push   $0x5e
  jmp alltraps
801071b7:	e9 1e f6 ff ff       	jmp    801067da <alltraps>

801071bc <vector95>:
.globl vector95
vector95:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $95
801071be:	6a 5f                	push   $0x5f
  jmp alltraps
801071c0:	e9 15 f6 ff ff       	jmp    801067da <alltraps>

801071c5 <vector96>:
.globl vector96
vector96:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $96
801071c7:	6a 60                	push   $0x60
  jmp alltraps
801071c9:	e9 0c f6 ff ff       	jmp    801067da <alltraps>

801071ce <vector97>:
.globl vector97
vector97:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $97
801071d0:	6a 61                	push   $0x61
  jmp alltraps
801071d2:	e9 03 f6 ff ff       	jmp    801067da <alltraps>

801071d7 <vector98>:
.globl vector98
vector98:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $98
801071d9:	6a 62                	push   $0x62
  jmp alltraps
801071db:	e9 fa f5 ff ff       	jmp    801067da <alltraps>

801071e0 <vector99>:
.globl vector99
vector99:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $99
801071e2:	6a 63                	push   $0x63
  jmp alltraps
801071e4:	e9 f1 f5 ff ff       	jmp    801067da <alltraps>

801071e9 <vector100>:
.globl vector100
vector100:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $100
801071eb:	6a 64                	push   $0x64
  jmp alltraps
801071ed:	e9 e8 f5 ff ff       	jmp    801067da <alltraps>

801071f2 <vector101>:
.globl vector101
vector101:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $101
801071f4:	6a 65                	push   $0x65
  jmp alltraps
801071f6:	e9 df f5 ff ff       	jmp    801067da <alltraps>

801071fb <vector102>:
.globl vector102
vector102:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $102
801071fd:	6a 66                	push   $0x66
  jmp alltraps
801071ff:	e9 d6 f5 ff ff       	jmp    801067da <alltraps>

80107204 <vector103>:
.globl vector103
vector103:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $103
80107206:	6a 67                	push   $0x67
  jmp alltraps
80107208:	e9 cd f5 ff ff       	jmp    801067da <alltraps>

8010720d <vector104>:
.globl vector104
vector104:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $104
8010720f:	6a 68                	push   $0x68
  jmp alltraps
80107211:	e9 c4 f5 ff ff       	jmp    801067da <alltraps>

80107216 <vector105>:
.globl vector105
vector105:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $105
80107218:	6a 69                	push   $0x69
  jmp alltraps
8010721a:	e9 bb f5 ff ff       	jmp    801067da <alltraps>

8010721f <vector106>:
.globl vector106
vector106:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $106
80107221:	6a 6a                	push   $0x6a
  jmp alltraps
80107223:	e9 b2 f5 ff ff       	jmp    801067da <alltraps>

80107228 <vector107>:
.globl vector107
vector107:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $107
8010722a:	6a 6b                	push   $0x6b
  jmp alltraps
8010722c:	e9 a9 f5 ff ff       	jmp    801067da <alltraps>

80107231 <vector108>:
.globl vector108
vector108:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $108
80107233:	6a 6c                	push   $0x6c
  jmp alltraps
80107235:	e9 a0 f5 ff ff       	jmp    801067da <alltraps>

8010723a <vector109>:
.globl vector109
vector109:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $109
8010723c:	6a 6d                	push   $0x6d
  jmp alltraps
8010723e:	e9 97 f5 ff ff       	jmp    801067da <alltraps>

80107243 <vector110>:
.globl vector110
vector110:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $110
80107245:	6a 6e                	push   $0x6e
  jmp alltraps
80107247:	e9 8e f5 ff ff       	jmp    801067da <alltraps>

8010724c <vector111>:
.globl vector111
vector111:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $111
8010724e:	6a 6f                	push   $0x6f
  jmp alltraps
80107250:	e9 85 f5 ff ff       	jmp    801067da <alltraps>

80107255 <vector112>:
.globl vector112
vector112:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $112
80107257:	6a 70                	push   $0x70
  jmp alltraps
80107259:	e9 7c f5 ff ff       	jmp    801067da <alltraps>

8010725e <vector113>:
.globl vector113
vector113:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $113
80107260:	6a 71                	push   $0x71
  jmp alltraps
80107262:	e9 73 f5 ff ff       	jmp    801067da <alltraps>

80107267 <vector114>:
.globl vector114
vector114:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $114
80107269:	6a 72                	push   $0x72
  jmp alltraps
8010726b:	e9 6a f5 ff ff       	jmp    801067da <alltraps>

80107270 <vector115>:
.globl vector115
vector115:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $115
80107272:	6a 73                	push   $0x73
  jmp alltraps
80107274:	e9 61 f5 ff ff       	jmp    801067da <alltraps>

80107279 <vector116>:
.globl vector116
vector116:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $116
8010727b:	6a 74                	push   $0x74
  jmp alltraps
8010727d:	e9 58 f5 ff ff       	jmp    801067da <alltraps>

80107282 <vector117>:
.globl vector117
vector117:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $117
80107284:	6a 75                	push   $0x75
  jmp alltraps
80107286:	e9 4f f5 ff ff       	jmp    801067da <alltraps>

8010728b <vector118>:
.globl vector118
vector118:
  pushl $0
8010728b:	6a 00                	push   $0x0
  pushl $118
8010728d:	6a 76                	push   $0x76
  jmp alltraps
8010728f:	e9 46 f5 ff ff       	jmp    801067da <alltraps>

80107294 <vector119>:
.globl vector119
vector119:
  pushl $0
80107294:	6a 00                	push   $0x0
  pushl $119
80107296:	6a 77                	push   $0x77
  jmp alltraps
80107298:	e9 3d f5 ff ff       	jmp    801067da <alltraps>

8010729d <vector120>:
.globl vector120
vector120:
  pushl $0
8010729d:	6a 00                	push   $0x0
  pushl $120
8010729f:	6a 78                	push   $0x78
  jmp alltraps
801072a1:	e9 34 f5 ff ff       	jmp    801067da <alltraps>

801072a6 <vector121>:
.globl vector121
vector121:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $121
801072a8:	6a 79                	push   $0x79
  jmp alltraps
801072aa:	e9 2b f5 ff ff       	jmp    801067da <alltraps>

801072af <vector122>:
.globl vector122
vector122:
  pushl $0
801072af:	6a 00                	push   $0x0
  pushl $122
801072b1:	6a 7a                	push   $0x7a
  jmp alltraps
801072b3:	e9 22 f5 ff ff       	jmp    801067da <alltraps>

801072b8 <vector123>:
.globl vector123
vector123:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $123
801072ba:	6a 7b                	push   $0x7b
  jmp alltraps
801072bc:	e9 19 f5 ff ff       	jmp    801067da <alltraps>

801072c1 <vector124>:
.globl vector124
vector124:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $124
801072c3:	6a 7c                	push   $0x7c
  jmp alltraps
801072c5:	e9 10 f5 ff ff       	jmp    801067da <alltraps>

801072ca <vector125>:
.globl vector125
vector125:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $125
801072cc:	6a 7d                	push   $0x7d
  jmp alltraps
801072ce:	e9 07 f5 ff ff       	jmp    801067da <alltraps>

801072d3 <vector126>:
.globl vector126
vector126:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $126
801072d5:	6a 7e                	push   $0x7e
  jmp alltraps
801072d7:	e9 fe f4 ff ff       	jmp    801067da <alltraps>

801072dc <vector127>:
.globl vector127
vector127:
  pushl $0
801072dc:	6a 00                	push   $0x0
  pushl $127
801072de:	6a 7f                	push   $0x7f
  jmp alltraps
801072e0:	e9 f5 f4 ff ff       	jmp    801067da <alltraps>

801072e5 <vector128>:
.globl vector128
vector128:
  pushl $0
801072e5:	6a 00                	push   $0x0
  pushl $128
801072e7:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801072ec:	e9 e9 f4 ff ff       	jmp    801067da <alltraps>

801072f1 <vector129>:
.globl vector129
vector129:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $129
801072f3:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801072f8:	e9 dd f4 ff ff       	jmp    801067da <alltraps>

801072fd <vector130>:
.globl vector130
vector130:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $130
801072ff:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107304:	e9 d1 f4 ff ff       	jmp    801067da <alltraps>

80107309 <vector131>:
.globl vector131
vector131:
  pushl $0
80107309:	6a 00                	push   $0x0
  pushl $131
8010730b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107310:	e9 c5 f4 ff ff       	jmp    801067da <alltraps>

80107315 <vector132>:
.globl vector132
vector132:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $132
80107317:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010731c:	e9 b9 f4 ff ff       	jmp    801067da <alltraps>

80107321 <vector133>:
.globl vector133
vector133:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $133
80107323:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107328:	e9 ad f4 ff ff       	jmp    801067da <alltraps>

8010732d <vector134>:
.globl vector134
vector134:
  pushl $0
8010732d:	6a 00                	push   $0x0
  pushl $134
8010732f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107334:	e9 a1 f4 ff ff       	jmp    801067da <alltraps>

80107339 <vector135>:
.globl vector135
vector135:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $135
8010733b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107340:	e9 95 f4 ff ff       	jmp    801067da <alltraps>

80107345 <vector136>:
.globl vector136
vector136:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $136
80107347:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010734c:	e9 89 f4 ff ff       	jmp    801067da <alltraps>

80107351 <vector137>:
.globl vector137
vector137:
  pushl $0
80107351:	6a 00                	push   $0x0
  pushl $137
80107353:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107358:	e9 7d f4 ff ff       	jmp    801067da <alltraps>

8010735d <vector138>:
.globl vector138
vector138:
  pushl $0
8010735d:	6a 00                	push   $0x0
  pushl $138
8010735f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107364:	e9 71 f4 ff ff       	jmp    801067da <alltraps>

80107369 <vector139>:
.globl vector139
vector139:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $139
8010736b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107370:	e9 65 f4 ff ff       	jmp    801067da <alltraps>

80107375 <vector140>:
.globl vector140
vector140:
  pushl $0
80107375:	6a 00                	push   $0x0
  pushl $140
80107377:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010737c:	e9 59 f4 ff ff       	jmp    801067da <alltraps>

80107381 <vector141>:
.globl vector141
vector141:
  pushl $0
80107381:	6a 00                	push   $0x0
  pushl $141
80107383:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107388:	e9 4d f4 ff ff       	jmp    801067da <alltraps>

8010738d <vector142>:
.globl vector142
vector142:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $142
8010738f:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107394:	e9 41 f4 ff ff       	jmp    801067da <alltraps>

80107399 <vector143>:
.globl vector143
vector143:
  pushl $0
80107399:	6a 00                	push   $0x0
  pushl $143
8010739b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801073a0:	e9 35 f4 ff ff       	jmp    801067da <alltraps>

801073a5 <vector144>:
.globl vector144
vector144:
  pushl $0
801073a5:	6a 00                	push   $0x0
  pushl $144
801073a7:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801073ac:	e9 29 f4 ff ff       	jmp    801067da <alltraps>

801073b1 <vector145>:
.globl vector145
vector145:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $145
801073b3:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801073b8:	e9 1d f4 ff ff       	jmp    801067da <alltraps>

801073bd <vector146>:
.globl vector146
vector146:
  pushl $0
801073bd:	6a 00                	push   $0x0
  pushl $146
801073bf:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801073c4:	e9 11 f4 ff ff       	jmp    801067da <alltraps>

801073c9 <vector147>:
.globl vector147
vector147:
  pushl $0
801073c9:	6a 00                	push   $0x0
  pushl $147
801073cb:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801073d0:	e9 05 f4 ff ff       	jmp    801067da <alltraps>

801073d5 <vector148>:
.globl vector148
vector148:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $148
801073d7:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801073dc:	e9 f9 f3 ff ff       	jmp    801067da <alltraps>

801073e1 <vector149>:
.globl vector149
vector149:
  pushl $0
801073e1:	6a 00                	push   $0x0
  pushl $149
801073e3:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801073e8:	e9 ed f3 ff ff       	jmp    801067da <alltraps>

801073ed <vector150>:
.globl vector150
vector150:
  pushl $0
801073ed:	6a 00                	push   $0x0
  pushl $150
801073ef:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801073f4:	e9 e1 f3 ff ff       	jmp    801067da <alltraps>

801073f9 <vector151>:
.globl vector151
vector151:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $151
801073fb:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107400:	e9 d5 f3 ff ff       	jmp    801067da <alltraps>

80107405 <vector152>:
.globl vector152
vector152:
  pushl $0
80107405:	6a 00                	push   $0x0
  pushl $152
80107407:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010740c:	e9 c9 f3 ff ff       	jmp    801067da <alltraps>

80107411 <vector153>:
.globl vector153
vector153:
  pushl $0
80107411:	6a 00                	push   $0x0
  pushl $153
80107413:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107418:	e9 bd f3 ff ff       	jmp    801067da <alltraps>

8010741d <vector154>:
.globl vector154
vector154:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $154
8010741f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107424:	e9 b1 f3 ff ff       	jmp    801067da <alltraps>

80107429 <vector155>:
.globl vector155
vector155:
  pushl $0
80107429:	6a 00                	push   $0x0
  pushl $155
8010742b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107430:	e9 a5 f3 ff ff       	jmp    801067da <alltraps>

80107435 <vector156>:
.globl vector156
vector156:
  pushl $0
80107435:	6a 00                	push   $0x0
  pushl $156
80107437:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010743c:	e9 99 f3 ff ff       	jmp    801067da <alltraps>

80107441 <vector157>:
.globl vector157
vector157:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $157
80107443:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107448:	e9 8d f3 ff ff       	jmp    801067da <alltraps>

8010744d <vector158>:
.globl vector158
vector158:
  pushl $0
8010744d:	6a 00                	push   $0x0
  pushl $158
8010744f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107454:	e9 81 f3 ff ff       	jmp    801067da <alltraps>

80107459 <vector159>:
.globl vector159
vector159:
  pushl $0
80107459:	6a 00                	push   $0x0
  pushl $159
8010745b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107460:	e9 75 f3 ff ff       	jmp    801067da <alltraps>

80107465 <vector160>:
.globl vector160
vector160:
  pushl $0
80107465:	6a 00                	push   $0x0
  pushl $160
80107467:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010746c:	e9 69 f3 ff ff       	jmp    801067da <alltraps>

80107471 <vector161>:
.globl vector161
vector161:
  pushl $0
80107471:	6a 00                	push   $0x0
  pushl $161
80107473:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107478:	e9 5d f3 ff ff       	jmp    801067da <alltraps>

8010747d <vector162>:
.globl vector162
vector162:
  pushl $0
8010747d:	6a 00                	push   $0x0
  pushl $162
8010747f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107484:	e9 51 f3 ff ff       	jmp    801067da <alltraps>

80107489 <vector163>:
.globl vector163
vector163:
  pushl $0
80107489:	6a 00                	push   $0x0
  pushl $163
8010748b:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107490:	e9 45 f3 ff ff       	jmp    801067da <alltraps>

80107495 <vector164>:
.globl vector164
vector164:
  pushl $0
80107495:	6a 00                	push   $0x0
  pushl $164
80107497:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010749c:	e9 39 f3 ff ff       	jmp    801067da <alltraps>

801074a1 <vector165>:
.globl vector165
vector165:
  pushl $0
801074a1:	6a 00                	push   $0x0
  pushl $165
801074a3:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801074a8:	e9 2d f3 ff ff       	jmp    801067da <alltraps>

801074ad <vector166>:
.globl vector166
vector166:
  pushl $0
801074ad:	6a 00                	push   $0x0
  pushl $166
801074af:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801074b4:	e9 21 f3 ff ff       	jmp    801067da <alltraps>

801074b9 <vector167>:
.globl vector167
vector167:
  pushl $0
801074b9:	6a 00                	push   $0x0
  pushl $167
801074bb:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801074c0:	e9 15 f3 ff ff       	jmp    801067da <alltraps>

801074c5 <vector168>:
.globl vector168
vector168:
  pushl $0
801074c5:	6a 00                	push   $0x0
  pushl $168
801074c7:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801074cc:	e9 09 f3 ff ff       	jmp    801067da <alltraps>

801074d1 <vector169>:
.globl vector169
vector169:
  pushl $0
801074d1:	6a 00                	push   $0x0
  pushl $169
801074d3:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801074d8:	e9 fd f2 ff ff       	jmp    801067da <alltraps>

801074dd <vector170>:
.globl vector170
vector170:
  pushl $0
801074dd:	6a 00                	push   $0x0
  pushl $170
801074df:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801074e4:	e9 f1 f2 ff ff       	jmp    801067da <alltraps>

801074e9 <vector171>:
.globl vector171
vector171:
  pushl $0
801074e9:	6a 00                	push   $0x0
  pushl $171
801074eb:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801074f0:	e9 e5 f2 ff ff       	jmp    801067da <alltraps>

801074f5 <vector172>:
.globl vector172
vector172:
  pushl $0
801074f5:	6a 00                	push   $0x0
  pushl $172
801074f7:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801074fc:	e9 d9 f2 ff ff       	jmp    801067da <alltraps>

80107501 <vector173>:
.globl vector173
vector173:
  pushl $0
80107501:	6a 00                	push   $0x0
  pushl $173
80107503:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107508:	e9 cd f2 ff ff       	jmp    801067da <alltraps>

8010750d <vector174>:
.globl vector174
vector174:
  pushl $0
8010750d:	6a 00                	push   $0x0
  pushl $174
8010750f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107514:	e9 c1 f2 ff ff       	jmp    801067da <alltraps>

80107519 <vector175>:
.globl vector175
vector175:
  pushl $0
80107519:	6a 00                	push   $0x0
  pushl $175
8010751b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107520:	e9 b5 f2 ff ff       	jmp    801067da <alltraps>

80107525 <vector176>:
.globl vector176
vector176:
  pushl $0
80107525:	6a 00                	push   $0x0
  pushl $176
80107527:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010752c:	e9 a9 f2 ff ff       	jmp    801067da <alltraps>

80107531 <vector177>:
.globl vector177
vector177:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $177
80107533:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107538:	e9 9d f2 ff ff       	jmp    801067da <alltraps>

8010753d <vector178>:
.globl vector178
vector178:
  pushl $0
8010753d:	6a 00                	push   $0x0
  pushl $178
8010753f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107544:	e9 91 f2 ff ff       	jmp    801067da <alltraps>

80107549 <vector179>:
.globl vector179
vector179:
  pushl $0
80107549:	6a 00                	push   $0x0
  pushl $179
8010754b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107550:	e9 85 f2 ff ff       	jmp    801067da <alltraps>

80107555 <vector180>:
.globl vector180
vector180:
  pushl $0
80107555:	6a 00                	push   $0x0
  pushl $180
80107557:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010755c:	e9 79 f2 ff ff       	jmp    801067da <alltraps>

80107561 <vector181>:
.globl vector181
vector181:
  pushl $0
80107561:	6a 00                	push   $0x0
  pushl $181
80107563:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107568:	e9 6d f2 ff ff       	jmp    801067da <alltraps>

8010756d <vector182>:
.globl vector182
vector182:
  pushl $0
8010756d:	6a 00                	push   $0x0
  pushl $182
8010756f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107574:	e9 61 f2 ff ff       	jmp    801067da <alltraps>

80107579 <vector183>:
.globl vector183
vector183:
  pushl $0
80107579:	6a 00                	push   $0x0
  pushl $183
8010757b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107580:	e9 55 f2 ff ff       	jmp    801067da <alltraps>

80107585 <vector184>:
.globl vector184
vector184:
  pushl $0
80107585:	6a 00                	push   $0x0
  pushl $184
80107587:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010758c:	e9 49 f2 ff ff       	jmp    801067da <alltraps>

80107591 <vector185>:
.globl vector185
vector185:
  pushl $0
80107591:	6a 00                	push   $0x0
  pushl $185
80107593:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107598:	e9 3d f2 ff ff       	jmp    801067da <alltraps>

8010759d <vector186>:
.globl vector186
vector186:
  pushl $0
8010759d:	6a 00                	push   $0x0
  pushl $186
8010759f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801075a4:	e9 31 f2 ff ff       	jmp    801067da <alltraps>

801075a9 <vector187>:
.globl vector187
vector187:
  pushl $0
801075a9:	6a 00                	push   $0x0
  pushl $187
801075ab:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801075b0:	e9 25 f2 ff ff       	jmp    801067da <alltraps>

801075b5 <vector188>:
.globl vector188
vector188:
  pushl $0
801075b5:	6a 00                	push   $0x0
  pushl $188
801075b7:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801075bc:	e9 19 f2 ff ff       	jmp    801067da <alltraps>

801075c1 <vector189>:
.globl vector189
vector189:
  pushl $0
801075c1:	6a 00                	push   $0x0
  pushl $189
801075c3:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801075c8:	e9 0d f2 ff ff       	jmp    801067da <alltraps>

801075cd <vector190>:
.globl vector190
vector190:
  pushl $0
801075cd:	6a 00                	push   $0x0
  pushl $190
801075cf:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801075d4:	e9 01 f2 ff ff       	jmp    801067da <alltraps>

801075d9 <vector191>:
.globl vector191
vector191:
  pushl $0
801075d9:	6a 00                	push   $0x0
  pushl $191
801075db:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801075e0:	e9 f5 f1 ff ff       	jmp    801067da <alltraps>

801075e5 <vector192>:
.globl vector192
vector192:
  pushl $0
801075e5:	6a 00                	push   $0x0
  pushl $192
801075e7:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801075ec:	e9 e9 f1 ff ff       	jmp    801067da <alltraps>

801075f1 <vector193>:
.globl vector193
vector193:
  pushl $0
801075f1:	6a 00                	push   $0x0
  pushl $193
801075f3:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801075f8:	e9 dd f1 ff ff       	jmp    801067da <alltraps>

801075fd <vector194>:
.globl vector194
vector194:
  pushl $0
801075fd:	6a 00                	push   $0x0
  pushl $194
801075ff:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107604:	e9 d1 f1 ff ff       	jmp    801067da <alltraps>

80107609 <vector195>:
.globl vector195
vector195:
  pushl $0
80107609:	6a 00                	push   $0x0
  pushl $195
8010760b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107610:	e9 c5 f1 ff ff       	jmp    801067da <alltraps>

80107615 <vector196>:
.globl vector196
vector196:
  pushl $0
80107615:	6a 00                	push   $0x0
  pushl $196
80107617:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010761c:	e9 b9 f1 ff ff       	jmp    801067da <alltraps>

80107621 <vector197>:
.globl vector197
vector197:
  pushl $0
80107621:	6a 00                	push   $0x0
  pushl $197
80107623:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107628:	e9 ad f1 ff ff       	jmp    801067da <alltraps>

8010762d <vector198>:
.globl vector198
vector198:
  pushl $0
8010762d:	6a 00                	push   $0x0
  pushl $198
8010762f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107634:	e9 a1 f1 ff ff       	jmp    801067da <alltraps>

80107639 <vector199>:
.globl vector199
vector199:
  pushl $0
80107639:	6a 00                	push   $0x0
  pushl $199
8010763b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107640:	e9 95 f1 ff ff       	jmp    801067da <alltraps>

80107645 <vector200>:
.globl vector200
vector200:
  pushl $0
80107645:	6a 00                	push   $0x0
  pushl $200
80107647:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010764c:	e9 89 f1 ff ff       	jmp    801067da <alltraps>

80107651 <vector201>:
.globl vector201
vector201:
  pushl $0
80107651:	6a 00                	push   $0x0
  pushl $201
80107653:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107658:	e9 7d f1 ff ff       	jmp    801067da <alltraps>

8010765d <vector202>:
.globl vector202
vector202:
  pushl $0
8010765d:	6a 00                	push   $0x0
  pushl $202
8010765f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107664:	e9 71 f1 ff ff       	jmp    801067da <alltraps>

80107669 <vector203>:
.globl vector203
vector203:
  pushl $0
80107669:	6a 00                	push   $0x0
  pushl $203
8010766b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107670:	e9 65 f1 ff ff       	jmp    801067da <alltraps>

80107675 <vector204>:
.globl vector204
vector204:
  pushl $0
80107675:	6a 00                	push   $0x0
  pushl $204
80107677:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010767c:	e9 59 f1 ff ff       	jmp    801067da <alltraps>

80107681 <vector205>:
.globl vector205
vector205:
  pushl $0
80107681:	6a 00                	push   $0x0
  pushl $205
80107683:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107688:	e9 4d f1 ff ff       	jmp    801067da <alltraps>

8010768d <vector206>:
.globl vector206
vector206:
  pushl $0
8010768d:	6a 00                	push   $0x0
  pushl $206
8010768f:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107694:	e9 41 f1 ff ff       	jmp    801067da <alltraps>

80107699 <vector207>:
.globl vector207
vector207:
  pushl $0
80107699:	6a 00                	push   $0x0
  pushl $207
8010769b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801076a0:	e9 35 f1 ff ff       	jmp    801067da <alltraps>

801076a5 <vector208>:
.globl vector208
vector208:
  pushl $0
801076a5:	6a 00                	push   $0x0
  pushl $208
801076a7:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801076ac:	e9 29 f1 ff ff       	jmp    801067da <alltraps>

801076b1 <vector209>:
.globl vector209
vector209:
  pushl $0
801076b1:	6a 00                	push   $0x0
  pushl $209
801076b3:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801076b8:	e9 1d f1 ff ff       	jmp    801067da <alltraps>

801076bd <vector210>:
.globl vector210
vector210:
  pushl $0
801076bd:	6a 00                	push   $0x0
  pushl $210
801076bf:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801076c4:	e9 11 f1 ff ff       	jmp    801067da <alltraps>

801076c9 <vector211>:
.globl vector211
vector211:
  pushl $0
801076c9:	6a 00                	push   $0x0
  pushl $211
801076cb:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801076d0:	e9 05 f1 ff ff       	jmp    801067da <alltraps>

801076d5 <vector212>:
.globl vector212
vector212:
  pushl $0
801076d5:	6a 00                	push   $0x0
  pushl $212
801076d7:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801076dc:	e9 f9 f0 ff ff       	jmp    801067da <alltraps>

801076e1 <vector213>:
.globl vector213
vector213:
  pushl $0
801076e1:	6a 00                	push   $0x0
  pushl $213
801076e3:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801076e8:	e9 ed f0 ff ff       	jmp    801067da <alltraps>

801076ed <vector214>:
.globl vector214
vector214:
  pushl $0
801076ed:	6a 00                	push   $0x0
  pushl $214
801076ef:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801076f4:	e9 e1 f0 ff ff       	jmp    801067da <alltraps>

801076f9 <vector215>:
.globl vector215
vector215:
  pushl $0
801076f9:	6a 00                	push   $0x0
  pushl $215
801076fb:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107700:	e9 d5 f0 ff ff       	jmp    801067da <alltraps>

80107705 <vector216>:
.globl vector216
vector216:
  pushl $0
80107705:	6a 00                	push   $0x0
  pushl $216
80107707:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010770c:	e9 c9 f0 ff ff       	jmp    801067da <alltraps>

80107711 <vector217>:
.globl vector217
vector217:
  pushl $0
80107711:	6a 00                	push   $0x0
  pushl $217
80107713:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107718:	e9 bd f0 ff ff       	jmp    801067da <alltraps>

8010771d <vector218>:
.globl vector218
vector218:
  pushl $0
8010771d:	6a 00                	push   $0x0
  pushl $218
8010771f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107724:	e9 b1 f0 ff ff       	jmp    801067da <alltraps>

80107729 <vector219>:
.globl vector219
vector219:
  pushl $0
80107729:	6a 00                	push   $0x0
  pushl $219
8010772b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107730:	e9 a5 f0 ff ff       	jmp    801067da <alltraps>

80107735 <vector220>:
.globl vector220
vector220:
  pushl $0
80107735:	6a 00                	push   $0x0
  pushl $220
80107737:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010773c:	e9 99 f0 ff ff       	jmp    801067da <alltraps>

80107741 <vector221>:
.globl vector221
vector221:
  pushl $0
80107741:	6a 00                	push   $0x0
  pushl $221
80107743:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107748:	e9 8d f0 ff ff       	jmp    801067da <alltraps>

8010774d <vector222>:
.globl vector222
vector222:
  pushl $0
8010774d:	6a 00                	push   $0x0
  pushl $222
8010774f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107754:	e9 81 f0 ff ff       	jmp    801067da <alltraps>

80107759 <vector223>:
.globl vector223
vector223:
  pushl $0
80107759:	6a 00                	push   $0x0
  pushl $223
8010775b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107760:	e9 75 f0 ff ff       	jmp    801067da <alltraps>

80107765 <vector224>:
.globl vector224
vector224:
  pushl $0
80107765:	6a 00                	push   $0x0
  pushl $224
80107767:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010776c:	e9 69 f0 ff ff       	jmp    801067da <alltraps>

80107771 <vector225>:
.globl vector225
vector225:
  pushl $0
80107771:	6a 00                	push   $0x0
  pushl $225
80107773:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107778:	e9 5d f0 ff ff       	jmp    801067da <alltraps>

8010777d <vector226>:
.globl vector226
vector226:
  pushl $0
8010777d:	6a 00                	push   $0x0
  pushl $226
8010777f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107784:	e9 51 f0 ff ff       	jmp    801067da <alltraps>

80107789 <vector227>:
.globl vector227
vector227:
  pushl $0
80107789:	6a 00                	push   $0x0
  pushl $227
8010778b:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107790:	e9 45 f0 ff ff       	jmp    801067da <alltraps>

80107795 <vector228>:
.globl vector228
vector228:
  pushl $0
80107795:	6a 00                	push   $0x0
  pushl $228
80107797:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010779c:	e9 39 f0 ff ff       	jmp    801067da <alltraps>

801077a1 <vector229>:
.globl vector229
vector229:
  pushl $0
801077a1:	6a 00                	push   $0x0
  pushl $229
801077a3:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801077a8:	e9 2d f0 ff ff       	jmp    801067da <alltraps>

801077ad <vector230>:
.globl vector230
vector230:
  pushl $0
801077ad:	6a 00                	push   $0x0
  pushl $230
801077af:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801077b4:	e9 21 f0 ff ff       	jmp    801067da <alltraps>

801077b9 <vector231>:
.globl vector231
vector231:
  pushl $0
801077b9:	6a 00                	push   $0x0
  pushl $231
801077bb:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801077c0:	e9 15 f0 ff ff       	jmp    801067da <alltraps>

801077c5 <vector232>:
.globl vector232
vector232:
  pushl $0
801077c5:	6a 00                	push   $0x0
  pushl $232
801077c7:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801077cc:	e9 09 f0 ff ff       	jmp    801067da <alltraps>

801077d1 <vector233>:
.globl vector233
vector233:
  pushl $0
801077d1:	6a 00                	push   $0x0
  pushl $233
801077d3:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801077d8:	e9 fd ef ff ff       	jmp    801067da <alltraps>

801077dd <vector234>:
.globl vector234
vector234:
  pushl $0
801077dd:	6a 00                	push   $0x0
  pushl $234
801077df:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801077e4:	e9 f1 ef ff ff       	jmp    801067da <alltraps>

801077e9 <vector235>:
.globl vector235
vector235:
  pushl $0
801077e9:	6a 00                	push   $0x0
  pushl $235
801077eb:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801077f0:	e9 e5 ef ff ff       	jmp    801067da <alltraps>

801077f5 <vector236>:
.globl vector236
vector236:
  pushl $0
801077f5:	6a 00                	push   $0x0
  pushl $236
801077f7:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801077fc:	e9 d9 ef ff ff       	jmp    801067da <alltraps>

80107801 <vector237>:
.globl vector237
vector237:
  pushl $0
80107801:	6a 00                	push   $0x0
  pushl $237
80107803:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107808:	e9 cd ef ff ff       	jmp    801067da <alltraps>

8010780d <vector238>:
.globl vector238
vector238:
  pushl $0
8010780d:	6a 00                	push   $0x0
  pushl $238
8010780f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107814:	e9 c1 ef ff ff       	jmp    801067da <alltraps>

80107819 <vector239>:
.globl vector239
vector239:
  pushl $0
80107819:	6a 00                	push   $0x0
  pushl $239
8010781b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107820:	e9 b5 ef ff ff       	jmp    801067da <alltraps>

80107825 <vector240>:
.globl vector240
vector240:
  pushl $0
80107825:	6a 00                	push   $0x0
  pushl $240
80107827:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010782c:	e9 a9 ef ff ff       	jmp    801067da <alltraps>

80107831 <vector241>:
.globl vector241
vector241:
  pushl $0
80107831:	6a 00                	push   $0x0
  pushl $241
80107833:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107838:	e9 9d ef ff ff       	jmp    801067da <alltraps>

8010783d <vector242>:
.globl vector242
vector242:
  pushl $0
8010783d:	6a 00                	push   $0x0
  pushl $242
8010783f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107844:	e9 91 ef ff ff       	jmp    801067da <alltraps>

80107849 <vector243>:
.globl vector243
vector243:
  pushl $0
80107849:	6a 00                	push   $0x0
  pushl $243
8010784b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107850:	e9 85 ef ff ff       	jmp    801067da <alltraps>

80107855 <vector244>:
.globl vector244
vector244:
  pushl $0
80107855:	6a 00                	push   $0x0
  pushl $244
80107857:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010785c:	e9 79 ef ff ff       	jmp    801067da <alltraps>

80107861 <vector245>:
.globl vector245
vector245:
  pushl $0
80107861:	6a 00                	push   $0x0
  pushl $245
80107863:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107868:	e9 6d ef ff ff       	jmp    801067da <alltraps>

8010786d <vector246>:
.globl vector246
vector246:
  pushl $0
8010786d:	6a 00                	push   $0x0
  pushl $246
8010786f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107874:	e9 61 ef ff ff       	jmp    801067da <alltraps>

80107879 <vector247>:
.globl vector247
vector247:
  pushl $0
80107879:	6a 00                	push   $0x0
  pushl $247
8010787b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107880:	e9 55 ef ff ff       	jmp    801067da <alltraps>

80107885 <vector248>:
.globl vector248
vector248:
  pushl $0
80107885:	6a 00                	push   $0x0
  pushl $248
80107887:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010788c:	e9 49 ef ff ff       	jmp    801067da <alltraps>

80107891 <vector249>:
.globl vector249
vector249:
  pushl $0
80107891:	6a 00                	push   $0x0
  pushl $249
80107893:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107898:	e9 3d ef ff ff       	jmp    801067da <alltraps>

8010789d <vector250>:
.globl vector250
vector250:
  pushl $0
8010789d:	6a 00                	push   $0x0
  pushl $250
8010789f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801078a4:	e9 31 ef ff ff       	jmp    801067da <alltraps>

801078a9 <vector251>:
.globl vector251
vector251:
  pushl $0
801078a9:	6a 00                	push   $0x0
  pushl $251
801078ab:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801078b0:	e9 25 ef ff ff       	jmp    801067da <alltraps>

801078b5 <vector252>:
.globl vector252
vector252:
  pushl $0
801078b5:	6a 00                	push   $0x0
  pushl $252
801078b7:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801078bc:	e9 19 ef ff ff       	jmp    801067da <alltraps>

801078c1 <vector253>:
.globl vector253
vector253:
  pushl $0
801078c1:	6a 00                	push   $0x0
  pushl $253
801078c3:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801078c8:	e9 0d ef ff ff       	jmp    801067da <alltraps>

801078cd <vector254>:
.globl vector254
vector254:
  pushl $0
801078cd:	6a 00                	push   $0x0
  pushl $254
801078cf:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801078d4:	e9 01 ef ff ff       	jmp    801067da <alltraps>

801078d9 <vector255>:
.globl vector255
vector255:
  pushl $0
801078d9:	6a 00                	push   $0x0
  pushl $255
801078db:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801078e0:	e9 f5 ee ff ff       	jmp    801067da <alltraps>

801078e5 <lgdt>:
{
801078e5:	55                   	push   %ebp
801078e6:	89 e5                	mov    %esp,%ebp
801078e8:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801078eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801078ee:	83 e8 01             	sub    $0x1,%eax
801078f1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801078f5:	8b 45 08             	mov    0x8(%ebp),%eax
801078f8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801078fc:	8b 45 08             	mov    0x8(%ebp),%eax
801078ff:	c1 e8 10             	shr    $0x10,%eax
80107902:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107906:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107909:	0f 01 10             	lgdtl  (%eax)
}
8010790c:	90                   	nop
8010790d:	c9                   	leave  
8010790e:	c3                   	ret    

8010790f <ltr>:
{
8010790f:	55                   	push   %ebp
80107910:	89 e5                	mov    %esp,%ebp
80107912:	83 ec 04             	sub    $0x4,%esp
80107915:	8b 45 08             	mov    0x8(%ebp),%eax
80107918:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010791c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107920:	0f 00 d8             	ltr    %ax
}
80107923:	90                   	nop
80107924:	c9                   	leave  
80107925:	c3                   	ret    

80107926 <lcr3>:

static inline void
lcr3(uint val)
{
80107926:	55                   	push   %ebp
80107927:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107929:	8b 45 08             	mov    0x8(%ebp),%eax
8010792c:	0f 22 d8             	mov    %eax,%cr3
}
8010792f:	90                   	nop
80107930:	5d                   	pop    %ebp
80107931:	c3                   	ret    

80107932 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107932:	f3 0f 1e fb          	endbr32 
80107936:	55                   	push   %ebp
80107937:	89 e5                	mov    %esp,%ebp
80107939:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010793c:	e8 c5 c6 ff ff       	call   80104006 <cpuid>
80107941:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107947:	05 00 af 11 80       	add    $0x8011af00,%eax
8010794c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010794f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107952:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107964:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010796f:	83 e2 f0             	and    $0xfffffff0,%edx
80107972:	83 ca 0a             	or     $0xa,%edx
80107975:	88 50 7d             	mov    %dl,0x7d(%eax)
80107978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010797f:	83 ca 10             	or     $0x10,%edx
80107982:	88 50 7d             	mov    %dl,0x7d(%eax)
80107985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107988:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010798c:	83 e2 9f             	and    $0xffffff9f,%edx
8010798f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107995:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107999:	83 ca 80             	or     $0xffffff80,%edx
8010799c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010799f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079a6:	83 ca 0f             	or     $0xf,%edx
801079a9:	88 50 7e             	mov    %dl,0x7e(%eax)
801079ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079af:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079b3:	83 e2 ef             	and    $0xffffffef,%edx
801079b6:	88 50 7e             	mov    %dl,0x7e(%eax)
801079b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079c0:	83 e2 df             	and    $0xffffffdf,%edx
801079c3:	88 50 7e             	mov    %dl,0x7e(%eax)
801079c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079cd:	83 ca 40             	or     $0x40,%edx
801079d0:	88 50 7e             	mov    %dl,0x7e(%eax)
801079d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079da:	83 ca 80             	or     $0xffffff80,%edx
801079dd:	88 50 7e             	mov    %dl,0x7e(%eax)
801079e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e3:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801079e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ea:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801079f1:	ff ff 
801079f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f6:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801079fd:	00 00 
801079ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a02:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a13:	83 e2 f0             	and    $0xfffffff0,%edx
80107a16:	83 ca 02             	or     $0x2,%edx
80107a19:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a22:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a29:	83 ca 10             	or     $0x10,%edx
80107a2c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a35:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a3c:	83 e2 9f             	and    $0xffffff9f,%edx
80107a3f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a48:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a4f:	83 ca 80             	or     $0xffffff80,%edx
80107a52:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a62:	83 ca 0f             	or     $0xf,%edx
80107a65:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a75:	83 e2 ef             	and    $0xffffffef,%edx
80107a78:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a81:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a88:	83 e2 df             	and    $0xffffffdf,%edx
80107a8b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a9b:	83 ca 40             	or     $0x40,%edx
80107a9e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107aae:	83 ca 80             	or     $0xffffff80,%edx
80107ab1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aba:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac4:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107acb:	ff ff 
80107acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad0:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107ad7:	00 00 
80107ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adc:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107aed:	83 e2 f0             	and    $0xfffffff0,%edx
80107af0:	83 ca 0a             	or     $0xa,%edx
80107af3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afc:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b03:	83 ca 10             	or     $0x10,%edx
80107b06:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b16:	83 ca 60             	or     $0x60,%edx
80107b19:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b22:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b29:	83 ca 80             	or     $0xffffff80,%edx
80107b2c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b35:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b3c:	83 ca 0f             	or     $0xf,%edx
80107b3f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b4f:	83 e2 ef             	and    $0xffffffef,%edx
80107b52:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b62:	83 e2 df             	and    $0xffffffdf,%edx
80107b65:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b75:	83 ca 40             	or     $0x40,%edx
80107b78:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b81:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b88:	83 ca 80             	or     $0xffffff80,%edx
80107b8b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b94:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107ba5:	ff ff 
80107ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baa:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107bb1:	00 00 
80107bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb6:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107bc7:	83 e2 f0             	and    $0xfffffff0,%edx
80107bca:	83 ca 02             	or     $0x2,%edx
80107bcd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107bdd:	83 ca 10             	or     $0x10,%edx
80107be0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be9:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107bf0:	83 ca 60             	or     $0x60,%edx
80107bf3:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfc:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c03:	83 ca 80             	or     $0xffffff80,%edx
80107c06:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c16:	83 ca 0f             	or     $0xf,%edx
80107c19:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c22:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c29:	83 e2 ef             	and    $0xffffffef,%edx
80107c2c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c35:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c3c:	83 e2 df             	and    $0xffffffdf,%edx
80107c3f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c4f:	83 ca 40             	or     $0x40,%edx
80107c52:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c62:	83 ca 80             	or     $0xffffff80,%edx
80107c65:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6e:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c78:	83 c0 70             	add    $0x70,%eax
80107c7b:	83 ec 08             	sub    $0x8,%esp
80107c7e:	6a 30                	push   $0x30
80107c80:	50                   	push   %eax
80107c81:	e8 5f fc ff ff       	call   801078e5 <lgdt>
80107c86:	83 c4 10             	add    $0x10,%esp
}
80107c89:	90                   	nop
80107c8a:	c9                   	leave  
80107c8b:	c3                   	ret    

80107c8c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c8c:	f3 0f 1e fb          	endbr32 
80107c90:	55                   	push   %ebp
80107c91:	89 e5                	mov    %esp,%ebp
80107c93:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c96:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c99:	c1 e8 16             	shr    $0x16,%eax
80107c9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80107ca6:	01 d0                	add    %edx,%eax
80107ca8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cae:	8b 00                	mov    (%eax),%eax
80107cb0:	83 e0 01             	and    $0x1,%eax
80107cb3:	85 c0                	test   %eax,%eax
80107cb5:	74 14                	je     80107ccb <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cba:	8b 00                	mov    (%eax),%eax
80107cbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cc1:	05 00 00 00 80       	add    $0x80000000,%eax
80107cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cc9:	eb 42                	jmp    80107d0d <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ccb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ccf:	74 0e                	je     80107cdf <walkpgdir+0x53>
80107cd1:	e8 b4 b0 ff ff       	call   80102d8a <kalloc>
80107cd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107cd9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107cdd:	75 07                	jne    80107ce6 <walkpgdir+0x5a>
      return 0;
80107cdf:	b8 00 00 00 00       	mov    $0x0,%eax
80107ce4:	eb 3e                	jmp    80107d24 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107ce6:	83 ec 04             	sub    $0x4,%esp
80107ce9:	68 00 10 00 00       	push   $0x1000
80107cee:	6a 00                	push   $0x0
80107cf0:	ff 75 f4             	pushl  -0xc(%ebp)
80107cf3:	e8 1b d6 ff ff       	call   80105313 <memset>
80107cf8:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfe:	05 00 00 00 80       	add    $0x80000000,%eax
80107d03:	83 c8 07             	or     $0x7,%eax
80107d06:	89 c2                	mov    %eax,%edx
80107d08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d0b:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d10:	c1 e8 0c             	shr    $0xc,%eax
80107d13:	25 ff 03 00 00       	and    $0x3ff,%eax
80107d18:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d22:	01 d0                	add    %edx,%eax
}
80107d24:	c9                   	leave  
80107d25:	c3                   	ret    

80107d26 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107d26:	f3 0f 1e fb          	endbr32 
80107d2a:	55                   	push   %ebp
80107d2b:	89 e5                	mov    %esp,%ebp
80107d2d:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107d30:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107d3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80107d3e:	8b 45 10             	mov    0x10(%ebp),%eax
80107d41:	01 d0                	add    %edx,%eax
80107d43:	83 e8 01             	sub    $0x1,%eax
80107d46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d4e:	83 ec 04             	sub    $0x4,%esp
80107d51:	6a 01                	push   $0x1
80107d53:	ff 75 f4             	pushl  -0xc(%ebp)
80107d56:	ff 75 08             	pushl  0x8(%ebp)
80107d59:	e8 2e ff ff ff       	call   80107c8c <walkpgdir>
80107d5e:	83 c4 10             	add    $0x10,%esp
80107d61:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107d64:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d68:	75 07                	jne    80107d71 <mappages+0x4b>
      return -1;
80107d6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d6f:	eb 47                	jmp    80107db8 <mappages+0x92>
    if(*pte & PTE_P)
80107d71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d74:	8b 00                	mov    (%eax),%eax
80107d76:	83 e0 01             	and    $0x1,%eax
80107d79:	85 c0                	test   %eax,%eax
80107d7b:	74 0d                	je     80107d8a <mappages+0x64>
      panic("remap");
80107d7d:	83 ec 0c             	sub    $0xc,%esp
80107d80:	68 cc b0 10 80       	push   $0x8010b0cc
80107d85:	e8 3b 88 ff ff       	call   801005c5 <panic>
    *pte = pa | perm | PTE_P;
80107d8a:	8b 45 18             	mov    0x18(%ebp),%eax
80107d8d:	0b 45 14             	or     0x14(%ebp),%eax
80107d90:	83 c8 01             	or     $0x1,%eax
80107d93:	89 c2                	mov    %eax,%edx
80107d95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d98:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107da0:	74 10                	je     80107db2 <mappages+0x8c>
      break;
    a += PGSIZE;
80107da2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107da9:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107db0:	eb 9c                	jmp    80107d4e <mappages+0x28>
      break;
80107db2:	90                   	nop
  }
  return 0;
80107db3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107db8:	c9                   	leave  
80107db9:	c3                   	ret    

80107dba <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107dba:	f3 0f 1e fb          	endbr32 
80107dbe:	55                   	push   %ebp
80107dbf:	89 e5                	mov    %esp,%ebp
80107dc1:	53                   	push   %ebx
80107dc2:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107dc5:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107dcc:	a1 cc b1 11 80       	mov    0x8011b1cc,%eax
80107dd1:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107dd6:	29 c2                	sub    %eax,%edx
80107dd8:	89 d0                	mov    %edx,%eax
80107dda:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107ddd:	a1 c4 b1 11 80       	mov    0x8011b1c4,%eax
80107de2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107de5:	8b 15 c4 b1 11 80    	mov    0x8011b1c4,%edx
80107deb:	a1 cc b1 11 80       	mov    0x8011b1cc,%eax
80107df0:	01 d0                	add    %edx,%eax
80107df2:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107df5:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dff:	83 c0 30             	add    $0x30,%eax
80107e02:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107e05:	89 10                	mov    %edx,(%eax)
80107e07:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107e0a:	89 50 04             	mov    %edx,0x4(%eax)
80107e0d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107e10:	89 50 08             	mov    %edx,0x8(%eax)
80107e13:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107e16:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107e19:	e8 6c af ff ff       	call   80102d8a <kalloc>
80107e1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e21:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e25:	75 07                	jne    80107e2e <setupkvm+0x74>
    return 0;
80107e27:	b8 00 00 00 00       	mov    $0x0,%eax
80107e2c:	eb 78                	jmp    80107ea6 <setupkvm+0xec>
  }
  memset(pgdir, 0, PGSIZE);
80107e2e:	83 ec 04             	sub    $0x4,%esp
80107e31:	68 00 10 00 00       	push   $0x1000
80107e36:	6a 00                	push   $0x0
80107e38:	ff 75 f0             	pushl  -0x10(%ebp)
80107e3b:	e8 d3 d4 ff ff       	call   80105313 <memset>
80107e40:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e43:	c7 45 f4 a0 f4 10 80 	movl   $0x8010f4a0,-0xc(%ebp)
80107e4a:	eb 4e                	jmp    80107e9a <setupkvm+0xe0>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4f:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e55:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5b:	8b 58 08             	mov    0x8(%eax),%ebx
80107e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e61:	8b 40 04             	mov    0x4(%eax),%eax
80107e64:	29 c3                	sub    %eax,%ebx
80107e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e69:	8b 00                	mov    (%eax),%eax
80107e6b:	83 ec 0c             	sub    $0xc,%esp
80107e6e:	51                   	push   %ecx
80107e6f:	52                   	push   %edx
80107e70:	53                   	push   %ebx
80107e71:	50                   	push   %eax
80107e72:	ff 75 f0             	pushl  -0x10(%ebp)
80107e75:	e8 ac fe ff ff       	call   80107d26 <mappages>
80107e7a:	83 c4 20             	add    $0x20,%esp
80107e7d:	85 c0                	test   %eax,%eax
80107e7f:	79 15                	jns    80107e96 <setupkvm+0xdc>
      freevm(pgdir);
80107e81:	83 ec 0c             	sub    $0xc,%esp
80107e84:	ff 75 f0             	pushl  -0x10(%ebp)
80107e87:	e8 11 05 00 00       	call   8010839d <freevm>
80107e8c:	83 c4 10             	add    $0x10,%esp
      return 0;
80107e8f:	b8 00 00 00 00       	mov    $0x0,%eax
80107e94:	eb 10                	jmp    80107ea6 <setupkvm+0xec>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107e96:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107e9a:	81 7d f4 00 f5 10 80 	cmpl   $0x8010f500,-0xc(%ebp)
80107ea1:	72 a9                	jb     80107e4c <setupkvm+0x92>
    }
  return pgdir;
80107ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107ea6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107ea9:	c9                   	leave  
80107eaa:	c3                   	ret    

80107eab <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107eab:	f3 0f 1e fb          	endbr32 
80107eaf:	55                   	push   %ebp
80107eb0:	89 e5                	mov    %esp,%ebp
80107eb2:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107eb5:	e8 00 ff ff ff       	call   80107dba <setupkvm>
80107eba:	a3 c4 ae 11 80       	mov    %eax,0x8011aec4
  switchkvm();
80107ebf:	e8 03 00 00 00       	call   80107ec7 <switchkvm>
}
80107ec4:	90                   	nop
80107ec5:	c9                   	leave  
80107ec6:	c3                   	ret    

80107ec7 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107ec7:	f3 0f 1e fb          	endbr32 
80107ecb:	55                   	push   %ebp
80107ecc:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107ece:	a1 c4 ae 11 80       	mov    0x8011aec4,%eax
80107ed3:	05 00 00 00 80       	add    $0x80000000,%eax
80107ed8:	50                   	push   %eax
80107ed9:	e8 48 fa ff ff       	call   80107926 <lcr3>
80107ede:	83 c4 04             	add    $0x4,%esp
}
80107ee1:	90                   	nop
80107ee2:	c9                   	leave  
80107ee3:	c3                   	ret    

80107ee4 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107ee4:	f3 0f 1e fb          	endbr32 
80107ee8:	55                   	push   %ebp
80107ee9:	89 e5                	mov    %esp,%ebp
80107eeb:	56                   	push   %esi
80107eec:	53                   	push   %ebx
80107eed:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107ef0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107ef4:	75 0d                	jne    80107f03 <switchuvm+0x1f>
    panic("switchuvm: no process");
80107ef6:	83 ec 0c             	sub    $0xc,%esp
80107ef9:	68 d2 b0 10 80       	push   $0x8010b0d2
80107efe:	e8 c2 86 ff ff       	call   801005c5 <panic>
  if(p->kstack == 0)
80107f03:	8b 45 08             	mov    0x8(%ebp),%eax
80107f06:	8b 40 08             	mov    0x8(%eax),%eax
80107f09:	85 c0                	test   %eax,%eax
80107f0b:	75 0d                	jne    80107f1a <switchuvm+0x36>
    panic("switchuvm: no kstack");
80107f0d:	83 ec 0c             	sub    $0xc,%esp
80107f10:	68 e8 b0 10 80       	push   $0x8010b0e8
80107f15:	e8 ab 86 ff ff       	call   801005c5 <panic>
  if(p->pgdir == 0)
80107f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f1d:	8b 40 04             	mov    0x4(%eax),%eax
80107f20:	85 c0                	test   %eax,%eax
80107f22:	75 0d                	jne    80107f31 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
80107f24:	83 ec 0c             	sub    $0xc,%esp
80107f27:	68 fd b0 10 80       	push   $0x8010b0fd
80107f2c:	e8 94 86 ff ff       	call   801005c5 <panic>

  pushcli();
80107f31:	e8 ca d2 ff ff       	call   80105200 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107f36:	e8 ea c0 ff ff       	call   80104025 <mycpu>
80107f3b:	89 c3                	mov    %eax,%ebx
80107f3d:	e8 e3 c0 ff ff       	call   80104025 <mycpu>
80107f42:	83 c0 08             	add    $0x8,%eax
80107f45:	89 c6                	mov    %eax,%esi
80107f47:	e8 d9 c0 ff ff       	call   80104025 <mycpu>
80107f4c:	83 c0 08             	add    $0x8,%eax
80107f4f:	c1 e8 10             	shr    $0x10,%eax
80107f52:	88 45 f7             	mov    %al,-0x9(%ebp)
80107f55:	e8 cb c0 ff ff       	call   80104025 <mycpu>
80107f5a:	83 c0 08             	add    $0x8,%eax
80107f5d:	c1 e8 18             	shr    $0x18,%eax
80107f60:	89 c2                	mov    %eax,%edx
80107f62:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107f69:	67 00 
80107f6b:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80107f72:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
80107f76:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80107f7c:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107f83:	83 e0 f0             	and    $0xfffffff0,%eax
80107f86:	83 c8 09             	or     $0x9,%eax
80107f89:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107f8f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107f96:	83 c8 10             	or     $0x10,%eax
80107f99:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107f9f:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107fa6:	83 e0 9f             	and    $0xffffff9f,%eax
80107fa9:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107faf:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80107fb6:	83 c8 80             	or     $0xffffff80,%eax
80107fb9:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107fbf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107fc6:	83 e0 f0             	and    $0xfffffff0,%eax
80107fc9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107fcf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107fd6:	83 e0 ef             	and    $0xffffffef,%eax
80107fd9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107fdf:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107fe6:	83 e0 df             	and    $0xffffffdf,%eax
80107fe9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107fef:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107ff6:	83 c8 40             	or     $0x40,%eax
80107ff9:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107fff:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80108006:	83 e0 7f             	and    $0x7f,%eax
80108009:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010800f:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108015:	e8 0b c0 ff ff       	call   80104025 <mycpu>
8010801a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108021:	83 e2 ef             	and    $0xffffffef,%edx
80108024:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010802a:	e8 f6 bf ff ff       	call   80104025 <mycpu>
8010802f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108035:	8b 45 08             	mov    0x8(%ebp),%eax
80108038:	8b 40 08             	mov    0x8(%eax),%eax
8010803b:	89 c3                	mov    %eax,%ebx
8010803d:	e8 e3 bf ff ff       	call   80104025 <mycpu>
80108042:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80108048:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010804b:	e8 d5 bf ff ff       	call   80104025 <mycpu>
80108050:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108056:	83 ec 0c             	sub    $0xc,%esp
80108059:	6a 28                	push   $0x28
8010805b:	e8 af f8 ff ff       	call   8010790f <ltr>
80108060:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108063:	8b 45 08             	mov    0x8(%ebp),%eax
80108066:	8b 40 04             	mov    0x4(%eax),%eax
80108069:	05 00 00 00 80       	add    $0x80000000,%eax
8010806e:	83 ec 0c             	sub    $0xc,%esp
80108071:	50                   	push   %eax
80108072:	e8 af f8 ff ff       	call   80107926 <lcr3>
80108077:	83 c4 10             	add    $0x10,%esp
  popcli();
8010807a:	e8 d2 d1 ff ff       	call   80105251 <popcli>
}
8010807f:	90                   	nop
80108080:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108083:	5b                   	pop    %ebx
80108084:	5e                   	pop    %esi
80108085:	5d                   	pop    %ebp
80108086:	c3                   	ret    

80108087 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108087:	f3 0f 1e fb          	endbr32 
8010808b:	55                   	push   %ebp
8010808c:	89 e5                	mov    %esp,%ebp
8010808e:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108091:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108098:	76 0d                	jbe    801080a7 <inituvm+0x20>
    panic("inituvm: more than a page");
8010809a:	83 ec 0c             	sub    $0xc,%esp
8010809d:	68 11 b1 10 80       	push   $0x8010b111
801080a2:	e8 1e 85 ff ff       	call   801005c5 <panic>
  mem = kalloc();
801080a7:	e8 de ac ff ff       	call   80102d8a <kalloc>
801080ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801080af:	83 ec 04             	sub    $0x4,%esp
801080b2:	68 00 10 00 00       	push   $0x1000
801080b7:	6a 00                	push   $0x0
801080b9:	ff 75 f4             	pushl  -0xc(%ebp)
801080bc:	e8 52 d2 ff ff       	call   80105313 <memset>
801080c1:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801080c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c7:	05 00 00 00 80       	add    $0x80000000,%eax
801080cc:	83 ec 0c             	sub    $0xc,%esp
801080cf:	6a 06                	push   $0x6
801080d1:	50                   	push   %eax
801080d2:	68 00 10 00 00       	push   $0x1000
801080d7:	6a 00                	push   $0x0
801080d9:	ff 75 08             	pushl  0x8(%ebp)
801080dc:	e8 45 fc ff ff       	call   80107d26 <mappages>
801080e1:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801080e4:	83 ec 04             	sub    $0x4,%esp
801080e7:	ff 75 10             	pushl  0x10(%ebp)
801080ea:	ff 75 0c             	pushl  0xc(%ebp)
801080ed:	ff 75 f4             	pushl  -0xc(%ebp)
801080f0:	e8 e5 d2 ff ff       	call   801053da <memmove>
801080f5:	83 c4 10             	add    $0x10,%esp
}
801080f8:	90                   	nop
801080f9:	c9                   	leave  
801080fa:	c3                   	ret    

801080fb <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801080fb:	f3 0f 1e fb          	endbr32 
801080ff:	55                   	push   %ebp
80108100:	89 e5                	mov    %esp,%ebp
80108102:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108105:	8b 45 0c             	mov    0xc(%ebp),%eax
80108108:	25 ff 0f 00 00       	and    $0xfff,%eax
8010810d:	85 c0                	test   %eax,%eax
8010810f:	74 0d                	je     8010811e <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80108111:	83 ec 0c             	sub    $0xc,%esp
80108114:	68 2c b1 10 80       	push   $0x8010b12c
80108119:	e8 a7 84 ff ff       	call   801005c5 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010811e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108125:	e9 8f 00 00 00       	jmp    801081b9 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010812a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010812d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108130:	01 d0                	add    %edx,%eax
80108132:	83 ec 04             	sub    $0x4,%esp
80108135:	6a 00                	push   $0x0
80108137:	50                   	push   %eax
80108138:	ff 75 08             	pushl  0x8(%ebp)
8010813b:	e8 4c fb ff ff       	call   80107c8c <walkpgdir>
80108140:	83 c4 10             	add    $0x10,%esp
80108143:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108146:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010814a:	75 0d                	jne    80108159 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
8010814c:	83 ec 0c             	sub    $0xc,%esp
8010814f:	68 4f b1 10 80       	push   $0x8010b14f
80108154:	e8 6c 84 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
80108159:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010815c:	8b 00                	mov    (%eax),%eax
8010815e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108163:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108166:	8b 45 18             	mov    0x18(%ebp),%eax
80108169:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010816c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108171:	77 0b                	ja     8010817e <loaduvm+0x83>
      n = sz - i;
80108173:	8b 45 18             	mov    0x18(%ebp),%eax
80108176:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108179:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010817c:	eb 07                	jmp    80108185 <loaduvm+0x8a>
    else
      n = PGSIZE;
8010817e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108185:	8b 55 14             	mov    0x14(%ebp),%edx
80108188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818b:	01 d0                	add    %edx,%eax
8010818d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108190:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108196:	ff 75 f0             	pushl  -0x10(%ebp)
80108199:	50                   	push   %eax
8010819a:	52                   	push   %edx
8010819b:	ff 75 10             	pushl  0x10(%ebp)
8010819e:	e8 e1 9d ff ff       	call   80101f84 <readi>
801081a3:	83 c4 10             	add    $0x10,%esp
801081a6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801081a9:	74 07                	je     801081b2 <loaduvm+0xb7>
      return -1;
801081ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081b0:	eb 18                	jmp    801081ca <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
801081b2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081bc:	3b 45 18             	cmp    0x18(%ebp),%eax
801081bf:	0f 82 65 ff ff ff    	jb     8010812a <loaduvm+0x2f>
  }
  return 0;
801081c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081ca:	c9                   	leave  
801081cb:	c3                   	ret    

801081cc <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801081cc:	f3 0f 1e fb          	endbr32 
801081d0:	55                   	push   %ebp
801081d1:	89 e5                	mov    %esp,%ebp
801081d3:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801081d6:	8b 45 10             	mov    0x10(%ebp),%eax
801081d9:	85 c0                	test   %eax,%eax
801081db:	79 0a                	jns    801081e7 <allocuvm+0x1b>
    return 0;
801081dd:	b8 00 00 00 00       	mov    $0x0,%eax
801081e2:	e9 ec 00 00 00       	jmp    801082d3 <allocuvm+0x107>
  if(newsz < oldsz)
801081e7:	8b 45 10             	mov    0x10(%ebp),%eax
801081ea:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081ed:	73 08                	jae    801081f7 <allocuvm+0x2b>
    return oldsz;
801081ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801081f2:	e9 dc 00 00 00       	jmp    801082d3 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
801081f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801081fa:	05 ff 0f 00 00       	add    $0xfff,%eax
801081ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108204:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108207:	e9 b8 00 00 00       	jmp    801082c4 <allocuvm+0xf8>
    mem = kalloc();
8010820c:	e8 79 ab ff ff       	call   80102d8a <kalloc>
80108211:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108214:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108218:	75 2e                	jne    80108248 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
8010821a:	83 ec 0c             	sub    $0xc,%esp
8010821d:	68 6d b1 10 80       	push   $0x8010b16d
80108222:	e8 e5 81 ff ff       	call   8010040c <cprintf>
80108227:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010822a:	83 ec 04             	sub    $0x4,%esp
8010822d:	ff 75 0c             	pushl  0xc(%ebp)
80108230:	ff 75 10             	pushl  0x10(%ebp)
80108233:	ff 75 08             	pushl  0x8(%ebp)
80108236:	e8 9a 00 00 00       	call   801082d5 <deallocuvm>
8010823b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010823e:	b8 00 00 00 00       	mov    $0x0,%eax
80108243:	e9 8b 00 00 00       	jmp    801082d3 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
80108248:	83 ec 04             	sub    $0x4,%esp
8010824b:	68 00 10 00 00       	push   $0x1000
80108250:	6a 00                	push   $0x0
80108252:	ff 75 f0             	pushl  -0x10(%ebp)
80108255:	e8 b9 d0 ff ff       	call   80105313 <memset>
8010825a:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010825d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108260:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108269:	83 ec 0c             	sub    $0xc,%esp
8010826c:	6a 06                	push   $0x6
8010826e:	52                   	push   %edx
8010826f:	68 00 10 00 00       	push   $0x1000
80108274:	50                   	push   %eax
80108275:	ff 75 08             	pushl  0x8(%ebp)
80108278:	e8 a9 fa ff ff       	call   80107d26 <mappages>
8010827d:	83 c4 20             	add    $0x20,%esp
80108280:	85 c0                	test   %eax,%eax
80108282:	79 39                	jns    801082bd <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
80108284:	83 ec 0c             	sub    $0xc,%esp
80108287:	68 85 b1 10 80       	push   $0x8010b185
8010828c:	e8 7b 81 ff ff       	call   8010040c <cprintf>
80108291:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108294:	83 ec 04             	sub    $0x4,%esp
80108297:	ff 75 0c             	pushl  0xc(%ebp)
8010829a:	ff 75 10             	pushl  0x10(%ebp)
8010829d:	ff 75 08             	pushl  0x8(%ebp)
801082a0:	e8 30 00 00 00       	call   801082d5 <deallocuvm>
801082a5:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801082a8:	83 ec 0c             	sub    $0xc,%esp
801082ab:	ff 75 f0             	pushl  -0x10(%ebp)
801082ae:	e8 39 aa ff ff       	call   80102cec <kfree>
801082b3:	83 c4 10             	add    $0x10,%esp
      return 0;
801082b6:	b8 00 00 00 00       	mov    $0x0,%eax
801082bb:	eb 16                	jmp    801082d3 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
801082bd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c7:	3b 45 10             	cmp    0x10(%ebp),%eax
801082ca:	0f 82 3c ff ff ff    	jb     8010820c <allocuvm+0x40>
    }
  }
  return newsz;
801082d0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801082d3:	c9                   	leave  
801082d4:	c3                   	ret    

801082d5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082d5:	f3 0f 1e fb          	endbr32 
801082d9:	55                   	push   %ebp
801082da:	89 e5                	mov    %esp,%ebp
801082dc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801082df:	8b 45 10             	mov    0x10(%ebp),%eax
801082e2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082e5:	72 08                	jb     801082ef <deallocuvm+0x1a>
    return oldsz;
801082e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801082ea:	e9 ac 00 00 00       	jmp    8010839b <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
801082ef:	8b 45 10             	mov    0x10(%ebp),%eax
801082f2:	05 ff 0f 00 00       	add    $0xfff,%eax
801082f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801082ff:	e9 88 00 00 00       	jmp    8010838c <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108307:	83 ec 04             	sub    $0x4,%esp
8010830a:	6a 00                	push   $0x0
8010830c:	50                   	push   %eax
8010830d:	ff 75 08             	pushl  0x8(%ebp)
80108310:	e8 77 f9 ff ff       	call   80107c8c <walkpgdir>
80108315:	83 c4 10             	add    $0x10,%esp
80108318:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010831b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010831f:	75 16                	jne    80108337 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108324:	c1 e8 16             	shr    $0x16,%eax
80108327:	83 c0 01             	add    $0x1,%eax
8010832a:	c1 e0 16             	shl    $0x16,%eax
8010832d:	2d 00 10 00 00       	sub    $0x1000,%eax
80108332:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108335:	eb 4e                	jmp    80108385 <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
80108337:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010833a:	8b 00                	mov    (%eax),%eax
8010833c:	83 e0 01             	and    $0x1,%eax
8010833f:	85 c0                	test   %eax,%eax
80108341:	74 42                	je     80108385 <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
80108343:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108346:	8b 00                	mov    (%eax),%eax
80108348:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010834d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108350:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108354:	75 0d                	jne    80108363 <deallocuvm+0x8e>
        panic("kfree");
80108356:	83 ec 0c             	sub    $0xc,%esp
80108359:	68 a1 b1 10 80       	push   $0x8010b1a1
8010835e:	e8 62 82 ff ff       	call   801005c5 <panic>
      char *v = P2V(pa);
80108363:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108366:	05 00 00 00 80       	add    $0x80000000,%eax
8010836b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010836e:	83 ec 0c             	sub    $0xc,%esp
80108371:	ff 75 e8             	pushl  -0x18(%ebp)
80108374:	e8 73 a9 ff ff       	call   80102cec <kfree>
80108379:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010837c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010837f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108385:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010838c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108392:	0f 82 6c ff ff ff    	jb     80108304 <deallocuvm+0x2f>
    }
  }
  return newsz;
80108398:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010839b:	c9                   	leave  
8010839c:	c3                   	ret    

8010839d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010839d:	f3 0f 1e fb          	endbr32 
801083a1:	55                   	push   %ebp
801083a2:	89 e5                	mov    %esp,%ebp
801083a4:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801083a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801083ab:	75 0d                	jne    801083ba <freevm+0x1d>
    panic("freevm: no pgdir");
801083ad:	83 ec 0c             	sub    $0xc,%esp
801083b0:	68 a7 b1 10 80       	push   $0x8010b1a7
801083b5:	e8 0b 82 ff ff       	call   801005c5 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801083ba:	83 ec 04             	sub    $0x4,%esp
801083bd:	6a 00                	push   $0x0
801083bf:	68 00 00 00 80       	push   $0x80000000
801083c4:	ff 75 08             	pushl  0x8(%ebp)
801083c7:	e8 09 ff ff ff       	call   801082d5 <deallocuvm>
801083cc:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801083cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083d6:	eb 48                	jmp    80108420 <freevm+0x83>
    if(pgdir[i] & PTE_P){
801083d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801083e2:	8b 45 08             	mov    0x8(%ebp),%eax
801083e5:	01 d0                	add    %edx,%eax
801083e7:	8b 00                	mov    (%eax),%eax
801083e9:	83 e0 01             	and    $0x1,%eax
801083ec:	85 c0                	test   %eax,%eax
801083ee:	74 2c                	je     8010841c <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801083f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801083fa:	8b 45 08             	mov    0x8(%ebp),%eax
801083fd:	01 d0                	add    %edx,%eax
801083ff:	8b 00                	mov    (%eax),%eax
80108401:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108406:	05 00 00 00 80       	add    $0x80000000,%eax
8010840b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010840e:	83 ec 0c             	sub    $0xc,%esp
80108411:	ff 75 f0             	pushl  -0x10(%ebp)
80108414:	e8 d3 a8 ff ff       	call   80102cec <kfree>
80108419:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010841c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108420:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108427:	76 af                	jbe    801083d8 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80108429:	83 ec 0c             	sub    $0xc,%esp
8010842c:	ff 75 08             	pushl  0x8(%ebp)
8010842f:	e8 b8 a8 ff ff       	call   80102cec <kfree>
80108434:	83 c4 10             	add    $0x10,%esp
}
80108437:	90                   	nop
80108438:	c9                   	leave  
80108439:	c3                   	ret    

8010843a <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010843a:	f3 0f 1e fb          	endbr32 
8010843e:	55                   	push   %ebp
8010843f:	89 e5                	mov    %esp,%ebp
80108441:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108444:	83 ec 04             	sub    $0x4,%esp
80108447:	6a 00                	push   $0x0
80108449:	ff 75 0c             	pushl  0xc(%ebp)
8010844c:	ff 75 08             	pushl  0x8(%ebp)
8010844f:	e8 38 f8 ff ff       	call   80107c8c <walkpgdir>
80108454:	83 c4 10             	add    $0x10,%esp
80108457:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010845a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010845e:	75 0d                	jne    8010846d <clearpteu+0x33>
    panic("clearpteu");
80108460:	83 ec 0c             	sub    $0xc,%esp
80108463:	68 b8 b1 10 80       	push   $0x8010b1b8
80108468:	e8 58 81 ff ff       	call   801005c5 <panic>
  *pte &= ~PTE_U;
8010846d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108470:	8b 00                	mov    (%eax),%eax
80108472:	83 e0 fb             	and    $0xfffffffb,%eax
80108475:	89 c2                	mov    %eax,%edx
80108477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847a:	89 10                	mov    %edx,(%eax)
}
8010847c:	90                   	nop
8010847d:	c9                   	leave  
8010847e:	c3                   	ret    

8010847f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010847f:	f3 0f 1e fb          	endbr32 
80108483:	55                   	push   %ebp
80108484:	89 e5                	mov    %esp,%ebp
80108486:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108489:	e8 2c f9 ff ff       	call   80107dba <setupkvm>
8010848e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108491:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108495:	75 0a                	jne    801084a1 <copyuvm+0x22>
    return 0;
80108497:	b8 00 00 00 00       	mov    $0x0,%eax
8010849c:	e9 eb 00 00 00       	jmp    8010858c <copyuvm+0x10d>
  for(i = 0; i < sz; i += PGSIZE){
801084a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084a8:	e9 b7 00 00 00       	jmp    80108564 <copyuvm+0xe5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801084ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b0:	83 ec 04             	sub    $0x4,%esp
801084b3:	6a 00                	push   $0x0
801084b5:	50                   	push   %eax
801084b6:	ff 75 08             	pushl  0x8(%ebp)
801084b9:	e8 ce f7 ff ff       	call   80107c8c <walkpgdir>
801084be:	83 c4 10             	add    $0x10,%esp
801084c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801084c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084c8:	75 0d                	jne    801084d7 <copyuvm+0x58>
      panic("copyuvm: pte should exist");
801084ca:	83 ec 0c             	sub    $0xc,%esp
801084cd:	68 c2 b1 10 80       	push   $0x8010b1c2
801084d2:	e8 ee 80 ff ff       	call   801005c5 <panic>
    if(!(*pte & PTE_P))
801084d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084da:	8b 00                	mov    (%eax),%eax
801084dc:	83 e0 01             	and    $0x1,%eax
801084df:	85 c0                	test   %eax,%eax
801084e1:	75 0d                	jne    801084f0 <copyuvm+0x71>
      panic("copyuvm: page not present");
801084e3:	83 ec 0c             	sub    $0xc,%esp
801084e6:	68 dc b1 10 80       	push   $0x8010b1dc
801084eb:	e8 d5 80 ff ff       	call   801005c5 <panic>
    pa = PTE_ADDR(*pte);
801084f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084f3:	8b 00                	mov    (%eax),%eax
801084f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801084fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108500:	8b 00                	mov    (%eax),%eax
80108502:	25 ff 0f 00 00       	and    $0xfff,%eax
80108507:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010850a:	e8 7b a8 ff ff       	call   80102d8a <kalloc>
8010850f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108512:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108516:	74 5d                	je     80108575 <copyuvm+0xf6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108518:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010851b:	05 00 00 00 80       	add    $0x80000000,%eax
80108520:	83 ec 04             	sub    $0x4,%esp
80108523:	68 00 10 00 00       	push   $0x1000
80108528:	50                   	push   %eax
80108529:	ff 75 e0             	pushl  -0x20(%ebp)
8010852c:	e8 a9 ce ff ff       	call   801053da <memmove>
80108531:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108534:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108537:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010853a:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108543:	83 ec 0c             	sub    $0xc,%esp
80108546:	52                   	push   %edx
80108547:	51                   	push   %ecx
80108548:	68 00 10 00 00       	push   $0x1000
8010854d:	50                   	push   %eax
8010854e:	ff 75 f0             	pushl  -0x10(%ebp)
80108551:	e8 d0 f7 ff ff       	call   80107d26 <mappages>
80108556:	83 c4 20             	add    $0x20,%esp
80108559:	85 c0                	test   %eax,%eax
8010855b:	78 1b                	js     80108578 <copyuvm+0xf9>
  for(i = 0; i < sz; i += PGSIZE){
8010855d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108564:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108567:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010856a:	0f 82 3d ff ff ff    	jb     801084ad <copyuvm+0x2e>
      goto bad;
  }
  return d;
80108570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108573:	eb 17                	jmp    8010858c <copyuvm+0x10d>
      goto bad;
80108575:	90                   	nop
80108576:	eb 01                	jmp    80108579 <copyuvm+0xfa>
      goto bad;
80108578:	90                   	nop

bad:
  freevm(d);
80108579:	83 ec 0c             	sub    $0xc,%esp
8010857c:	ff 75 f0             	pushl  -0x10(%ebp)
8010857f:	e8 19 fe ff ff       	call   8010839d <freevm>
80108584:	83 c4 10             	add    $0x10,%esp
  return 0;
80108587:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010858c:	c9                   	leave  
8010858d:	c3                   	ret    

8010858e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010858e:	f3 0f 1e fb          	endbr32 
80108592:	55                   	push   %ebp
80108593:	89 e5                	mov    %esp,%ebp
80108595:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108598:	83 ec 04             	sub    $0x4,%esp
8010859b:	6a 00                	push   $0x0
8010859d:	ff 75 0c             	pushl  0xc(%ebp)
801085a0:	ff 75 08             	pushl  0x8(%ebp)
801085a3:	e8 e4 f6 ff ff       	call   80107c8c <walkpgdir>
801085a8:	83 c4 10             	add    $0x10,%esp
801085ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801085ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b1:	8b 00                	mov    (%eax),%eax
801085b3:	83 e0 01             	and    $0x1,%eax
801085b6:	85 c0                	test   %eax,%eax
801085b8:	75 07                	jne    801085c1 <uva2ka+0x33>
    return 0;
801085ba:	b8 00 00 00 00       	mov    $0x0,%eax
801085bf:	eb 22                	jmp    801085e3 <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
801085c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c4:	8b 00                	mov    (%eax),%eax
801085c6:	83 e0 04             	and    $0x4,%eax
801085c9:	85 c0                	test   %eax,%eax
801085cb:	75 07                	jne    801085d4 <uva2ka+0x46>
    return 0;
801085cd:	b8 00 00 00 00       	mov    $0x0,%eax
801085d2:	eb 0f                	jmp    801085e3 <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
801085d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d7:	8b 00                	mov    (%eax),%eax
801085d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085de:	05 00 00 00 80       	add    $0x80000000,%eax
}
801085e3:	c9                   	leave  
801085e4:	c3                   	ret    

801085e5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801085e5:	f3 0f 1e fb          	endbr32 
801085e9:	55                   	push   %ebp
801085ea:	89 e5                	mov    %esp,%ebp
801085ec:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801085ef:	8b 45 10             	mov    0x10(%ebp),%eax
801085f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801085f5:	eb 7f                	jmp    80108676 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
801085f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801085fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108602:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108605:	83 ec 08             	sub    $0x8,%esp
80108608:	50                   	push   %eax
80108609:	ff 75 08             	pushl  0x8(%ebp)
8010860c:	e8 7d ff ff ff       	call   8010858e <uva2ka>
80108611:	83 c4 10             	add    $0x10,%esp
80108614:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108617:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010861b:	75 07                	jne    80108624 <copyout+0x3f>
      return -1;
8010861d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108622:	eb 61                	jmp    80108685 <copyout+0xa0>
    n = PGSIZE - (va - va0);
80108624:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108627:	2b 45 0c             	sub    0xc(%ebp),%eax
8010862a:	05 00 10 00 00       	add    $0x1000,%eax
8010862f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108635:	3b 45 14             	cmp    0x14(%ebp),%eax
80108638:	76 06                	jbe    80108640 <copyout+0x5b>
      n = len;
8010863a:	8b 45 14             	mov    0x14(%ebp),%eax
8010863d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108640:	8b 45 0c             	mov    0xc(%ebp),%eax
80108643:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108646:	89 c2                	mov    %eax,%edx
80108648:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010864b:	01 d0                	add    %edx,%eax
8010864d:	83 ec 04             	sub    $0x4,%esp
80108650:	ff 75 f0             	pushl  -0x10(%ebp)
80108653:	ff 75 f4             	pushl  -0xc(%ebp)
80108656:	50                   	push   %eax
80108657:	e8 7e cd ff ff       	call   801053da <memmove>
8010865c:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010865f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108662:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108668:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010866b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010866e:	05 00 10 00 00       	add    $0x1000,%eax
80108673:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108676:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010867a:	0f 85 77 ff ff ff    	jne    801085f7 <copyout+0x12>
  }
  return 0;
80108680:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108685:	c9                   	leave  
80108686:	c3                   	ret    

80108687 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80108687:	f3 0f 1e fb          	endbr32 
8010868b:	55                   	push   %ebp
8010868c:	89 e5                	mov    %esp,%ebp
8010868e:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80108691:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80108698:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010869b:	8b 40 08             	mov    0x8(%eax),%eax
8010869e:	05 00 00 00 80       	add    $0x80000000,%eax
801086a3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801086a6:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801086ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b0:	8b 40 24             	mov    0x24(%eax),%eax
801086b3:	a3 5c 84 11 80       	mov    %eax,0x8011845c
  ncpu = 0;
801086b8:	c7 05 c0 b1 11 80 00 	movl   $0x0,0x8011b1c0
801086bf:	00 00 00 

  while(i<madt->len){
801086c2:	90                   	nop
801086c3:	e9 be 00 00 00       	jmp    80108786 <mpinit_uefi+0xff>
    uchar *entry_type = ((uchar *)madt)+i;
801086c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801086ce:	01 d0                	add    %edx,%eax
801086d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801086d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d6:	0f b6 00             	movzbl (%eax),%eax
801086d9:	0f b6 c0             	movzbl %al,%eax
801086dc:	83 f8 05             	cmp    $0x5,%eax
801086df:	0f 87 a1 00 00 00    	ja     80108786 <mpinit_uefi+0xff>
801086e5:	8b 04 85 f8 b1 10 80 	mov    -0x7fef4e08(,%eax,4),%eax
801086ec:	3e ff e0             	notrack jmp *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
801086ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
801086f5:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
801086fa:	83 f8 03             	cmp    $0x3,%eax
801086fd:	7f 28                	jg     80108727 <mpinit_uefi+0xa0>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
801086ff:	8b 15 c0 b1 11 80    	mov    0x8011b1c0,%edx
80108705:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108708:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010870c:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80108712:	81 c2 00 af 11 80    	add    $0x8011af00,%edx
80108718:	88 02                	mov    %al,(%edx)
          ncpu++;
8010871a:	a1 c0 b1 11 80       	mov    0x8011b1c0,%eax
8010871f:	83 c0 01             	add    $0x1,%eax
80108722:	a3 c0 b1 11 80       	mov    %eax,0x8011b1c0
        }
        i += lapic_entry->record_len;
80108727:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010872a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010872e:	0f b6 c0             	movzbl %al,%eax
80108731:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108734:	eb 50                	jmp    80108786 <mpinit_uefi+0xff>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108736:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108739:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010873c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010873f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108743:	a2 e0 ae 11 80       	mov    %al,0x8011aee0
        i += ioapic->record_len;
80108748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010874b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010874f:	0f b6 c0             	movzbl %al,%eax
80108752:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108755:	eb 2f                	jmp    80108786 <mpinit_uefi+0xff>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108757:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010875a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010875d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108760:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108764:	0f b6 c0             	movzbl %al,%eax
80108767:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010876a:	eb 1a                	jmp    80108786 <mpinit_uefi+0xff>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010876c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010876f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108772:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108775:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108779:	0f b6 c0             	movzbl %al,%eax
8010877c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010877f:	eb 05                	jmp    80108786 <mpinit_uefi+0xff>

      case 5:
        i = i + 0xC;
80108781:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80108785:	90                   	nop
  while(i<madt->len){
80108786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108789:	8b 40 04             	mov    0x4(%eax),%eax
8010878c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
8010878f:	0f 82 33 ff ff ff    	jb     801086c8 <mpinit_uefi+0x41>
    }
  }

}
80108795:	90                   	nop
80108796:	90                   	nop
80108797:	c9                   	leave  
80108798:	c3                   	ret    

80108799 <inb>:
{
80108799:	55                   	push   %ebp
8010879a:	89 e5                	mov    %esp,%ebp
8010879c:	83 ec 14             	sub    $0x14,%esp
8010879f:	8b 45 08             	mov    0x8(%ebp),%eax
801087a2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801087a6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801087aa:	89 c2                	mov    %eax,%edx
801087ac:	ec                   	in     (%dx),%al
801087ad:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801087b0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801087b4:	c9                   	leave  
801087b5:	c3                   	ret    

801087b6 <outb>:
{
801087b6:	55                   	push   %ebp
801087b7:	89 e5                	mov    %esp,%ebp
801087b9:	83 ec 08             	sub    $0x8,%esp
801087bc:	8b 45 08             	mov    0x8(%ebp),%eax
801087bf:	8b 55 0c             	mov    0xc(%ebp),%edx
801087c2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801087c6:	89 d0                	mov    %edx,%eax
801087c8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801087cb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801087cf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801087d3:	ee                   	out    %al,(%dx)
}
801087d4:	90                   	nop
801087d5:	c9                   	leave  
801087d6:	c3                   	ret    

801087d7 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801087d7:	f3 0f 1e fb          	endbr32 
801087db:	55                   	push   %ebp
801087dc:	89 e5                	mov    %esp,%ebp
801087de:	83 ec 28             	sub    $0x28,%esp
801087e1:	8b 45 08             	mov    0x8(%ebp),%eax
801087e4:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801087e7:	6a 00                	push   $0x0
801087e9:	68 fa 03 00 00       	push   $0x3fa
801087ee:	e8 c3 ff ff ff       	call   801087b6 <outb>
801087f3:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801087f6:	68 80 00 00 00       	push   $0x80
801087fb:	68 fb 03 00 00       	push   $0x3fb
80108800:	e8 b1 ff ff ff       	call   801087b6 <outb>
80108805:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108808:	6a 0c                	push   $0xc
8010880a:	68 f8 03 00 00       	push   $0x3f8
8010880f:	e8 a2 ff ff ff       	call   801087b6 <outb>
80108814:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108817:	6a 00                	push   $0x0
80108819:	68 f9 03 00 00       	push   $0x3f9
8010881e:	e8 93 ff ff ff       	call   801087b6 <outb>
80108823:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108826:	6a 03                	push   $0x3
80108828:	68 fb 03 00 00       	push   $0x3fb
8010882d:	e8 84 ff ff ff       	call   801087b6 <outb>
80108832:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108835:	6a 00                	push   $0x0
80108837:	68 fc 03 00 00       	push   $0x3fc
8010883c:	e8 75 ff ff ff       	call   801087b6 <outb>
80108841:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80108844:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010884b:	eb 11                	jmp    8010885e <uart_debug+0x87>
8010884d:	83 ec 0c             	sub    $0xc,%esp
80108850:	6a 0a                	push   $0xa
80108852:	e8 e5 a8 ff ff       	call   8010313c <microdelay>
80108857:	83 c4 10             	add    $0x10,%esp
8010885a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010885e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80108862:	7f 1a                	jg     8010887e <uart_debug+0xa7>
80108864:	83 ec 0c             	sub    $0xc,%esp
80108867:	68 fd 03 00 00       	push   $0x3fd
8010886c:	e8 28 ff ff ff       	call   80108799 <inb>
80108871:	83 c4 10             	add    $0x10,%esp
80108874:	0f b6 c0             	movzbl %al,%eax
80108877:	83 e0 20             	and    $0x20,%eax
8010887a:	85 c0                	test   %eax,%eax
8010887c:	74 cf                	je     8010884d <uart_debug+0x76>
  outb(COM1+0, p);
8010887e:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80108882:	0f b6 c0             	movzbl %al,%eax
80108885:	83 ec 08             	sub    $0x8,%esp
80108888:	50                   	push   %eax
80108889:	68 f8 03 00 00       	push   $0x3f8
8010888e:	e8 23 ff ff ff       	call   801087b6 <outb>
80108893:	83 c4 10             	add    $0x10,%esp
}
80108896:	90                   	nop
80108897:	c9                   	leave  
80108898:	c3                   	ret    

80108899 <uart_debugs>:

void uart_debugs(char *p){
80108899:	f3 0f 1e fb          	endbr32 
8010889d:	55                   	push   %ebp
8010889e:	89 e5                	mov    %esp,%ebp
801088a0:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801088a3:	eb 1b                	jmp    801088c0 <uart_debugs+0x27>
    uart_debug(*p++);
801088a5:	8b 45 08             	mov    0x8(%ebp),%eax
801088a8:	8d 50 01             	lea    0x1(%eax),%edx
801088ab:	89 55 08             	mov    %edx,0x8(%ebp)
801088ae:	0f b6 00             	movzbl (%eax),%eax
801088b1:	0f be c0             	movsbl %al,%eax
801088b4:	83 ec 0c             	sub    $0xc,%esp
801088b7:	50                   	push   %eax
801088b8:	e8 1a ff ff ff       	call   801087d7 <uart_debug>
801088bd:	83 c4 10             	add    $0x10,%esp
  while(*p){
801088c0:	8b 45 08             	mov    0x8(%ebp),%eax
801088c3:	0f b6 00             	movzbl (%eax),%eax
801088c6:	84 c0                	test   %al,%al
801088c8:	75 db                	jne    801088a5 <uart_debugs+0xc>
  }
}
801088ca:	90                   	nop
801088cb:	90                   	nop
801088cc:	c9                   	leave  
801088cd:	c3                   	ret    

801088ce <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801088ce:	f3 0f 1e fb          	endbr32 
801088d2:	55                   	push   %ebp
801088d3:	89 e5                	mov    %esp,%ebp
801088d5:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801088d8:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801088df:	8b 45 fc             	mov    -0x4(%ebp),%eax
801088e2:	8b 50 14             	mov    0x14(%eax),%edx
801088e5:	8b 40 10             	mov    0x10(%eax),%eax
801088e8:	a3 c4 b1 11 80       	mov    %eax,0x8011b1c4
  gpu.vram_size = boot_param->graphic_config.frame_size;
801088ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801088f0:	8b 50 1c             	mov    0x1c(%eax),%edx
801088f3:	8b 40 18             	mov    0x18(%eax),%eax
801088f6:	a3 cc b1 11 80       	mov    %eax,0x8011b1cc
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
801088fb:	a1 cc b1 11 80       	mov    0x8011b1cc,%eax
80108900:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108905:	29 c2                	sub    %eax,%edx
80108907:	89 d0                	mov    %edx,%eax
80108909:	a3 c8 b1 11 80       	mov    %eax,0x8011b1c8
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010890e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108911:	8b 50 24             	mov    0x24(%eax),%edx
80108914:	8b 40 20             	mov    0x20(%eax),%eax
80108917:	a3 d0 b1 11 80       	mov    %eax,0x8011b1d0
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010891c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010891f:	8b 50 2c             	mov    0x2c(%eax),%edx
80108922:	8b 40 28             	mov    0x28(%eax),%eax
80108925:	a3 d4 b1 11 80       	mov    %eax,0x8011b1d4
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
8010892a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010892d:	8b 50 34             	mov    0x34(%eax),%edx
80108930:	8b 40 30             	mov    0x30(%eax),%eax
80108933:	a3 d8 b1 11 80       	mov    %eax,0x8011b1d8
}
80108938:	90                   	nop
80108939:	c9                   	leave  
8010893a:	c3                   	ret    

8010893b <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010893b:	f3 0f 1e fb          	endbr32 
8010893f:	55                   	push   %ebp
80108940:	89 e5                	mov    %esp,%ebp
80108942:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108945:	8b 15 d8 b1 11 80    	mov    0x8011b1d8,%edx
8010894b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010894e:	0f af d0             	imul   %eax,%edx
80108951:	8b 45 08             	mov    0x8(%ebp),%eax
80108954:	01 d0                	add    %edx,%eax
80108956:	c1 e0 02             	shl    $0x2,%eax
80108959:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
8010895c:	8b 15 c8 b1 11 80    	mov    0x8011b1c8,%edx
80108962:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108965:	01 d0                	add    %edx,%eax
80108967:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
8010896a:	8b 45 10             	mov    0x10(%ebp),%eax
8010896d:	0f b6 10             	movzbl (%eax),%edx
80108970:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108973:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108975:	8b 45 10             	mov    0x10(%ebp),%eax
80108978:	0f b6 50 01          	movzbl 0x1(%eax),%edx
8010897c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010897f:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80108982:	8b 45 10             	mov    0x10(%ebp),%eax
80108985:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108989:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010898c:	88 50 02             	mov    %dl,0x2(%eax)
}
8010898f:	90                   	nop
80108990:	c9                   	leave  
80108991:	c3                   	ret    

80108992 <graphic_scroll_up>:

void graphic_scroll_up(int height){
80108992:	f3 0f 1e fb          	endbr32 
80108996:	55                   	push   %ebp
80108997:	89 e5                	mov    %esp,%ebp
80108999:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
8010899c:	8b 15 d8 b1 11 80    	mov    0x8011b1d8,%edx
801089a2:	8b 45 08             	mov    0x8(%ebp),%eax
801089a5:	0f af c2             	imul   %edx,%eax
801089a8:	c1 e0 02             	shl    $0x2,%eax
801089ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801089ae:	8b 15 cc b1 11 80    	mov    0x8011b1cc,%edx
801089b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b7:	29 c2                	sub    %eax,%edx
801089b9:	89 d0                	mov    %edx,%eax
801089bb:	8b 0d c8 b1 11 80    	mov    0x8011b1c8,%ecx
801089c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089c4:	01 ca                	add    %ecx,%edx
801089c6:	89 d1                	mov    %edx,%ecx
801089c8:	8b 15 c8 b1 11 80    	mov    0x8011b1c8,%edx
801089ce:	83 ec 04             	sub    $0x4,%esp
801089d1:	50                   	push   %eax
801089d2:	51                   	push   %ecx
801089d3:	52                   	push   %edx
801089d4:	e8 01 ca ff ff       	call   801053da <memmove>
801089d9:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801089dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089df:	8b 0d c8 b1 11 80    	mov    0x8011b1c8,%ecx
801089e5:	8b 15 cc b1 11 80    	mov    0x8011b1cc,%edx
801089eb:	01 d1                	add    %edx,%ecx
801089ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801089f0:	29 d1                	sub    %edx,%ecx
801089f2:	89 ca                	mov    %ecx,%edx
801089f4:	83 ec 04             	sub    $0x4,%esp
801089f7:	50                   	push   %eax
801089f8:	6a 00                	push   $0x0
801089fa:	52                   	push   %edx
801089fb:	e8 13 c9 ff ff       	call   80105313 <memset>
80108a00:	83 c4 10             	add    $0x10,%esp
}
80108a03:	90                   	nop
80108a04:	c9                   	leave  
80108a05:	c3                   	ret    

80108a06 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80108a06:	f3 0f 1e fb          	endbr32 
80108a0a:	55                   	push   %ebp
80108a0b:	89 e5                	mov    %esp,%ebp
80108a0d:	53                   	push   %ebx
80108a0e:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108a11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a18:	e9 b1 00 00 00       	jmp    80108ace <font_render+0xc8>
    for(int j=14;j>-1;j--){
80108a1d:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108a24:	e9 97 00 00 00       	jmp    80108ac0 <font_render+0xba>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108a29:	8b 45 10             	mov    0x10(%ebp),%eax
80108a2c:	83 e8 20             	sub    $0x20,%eax
80108a2f:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a35:	01 d0                	add    %edx,%eax
80108a37:	0f b7 84 00 20 b2 10 	movzwl -0x7fef4de0(%eax,%eax,1),%eax
80108a3e:	80 
80108a3f:	0f b7 d0             	movzwl %ax,%edx
80108a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a45:	bb 01 00 00 00       	mov    $0x1,%ebx
80108a4a:	89 c1                	mov    %eax,%ecx
80108a4c:	d3 e3                	shl    %cl,%ebx
80108a4e:	89 d8                	mov    %ebx,%eax
80108a50:	21 d0                	and    %edx,%eax
80108a52:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a58:	ba 01 00 00 00       	mov    $0x1,%edx
80108a5d:	89 c1                	mov    %eax,%ecx
80108a5f:	d3 e2                	shl    %cl,%edx
80108a61:	89 d0                	mov    %edx,%eax
80108a63:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108a66:	75 2b                	jne    80108a93 <font_render+0x8d>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108a68:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6e:	01 c2                	add    %eax,%edx
80108a70:	b8 0e 00 00 00       	mov    $0xe,%eax
80108a75:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108a78:	89 c1                	mov    %eax,%ecx
80108a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80108a7d:	01 c8                	add    %ecx,%eax
80108a7f:	83 ec 04             	sub    $0x4,%esp
80108a82:	68 00 f5 10 80       	push   $0x8010f500
80108a87:	52                   	push   %edx
80108a88:	50                   	push   %eax
80108a89:	e8 ad fe ff ff       	call   8010893b <graphic_draw_pixel>
80108a8e:	83 c4 10             	add    $0x10,%esp
80108a91:	eb 29                	jmp    80108abc <font_render+0xb6>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108a93:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a99:	01 c2                	add    %eax,%edx
80108a9b:	b8 0e 00 00 00       	mov    $0xe,%eax
80108aa0:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108aa3:	89 c1                	mov    %eax,%ecx
80108aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80108aa8:	01 c8                	add    %ecx,%eax
80108aaa:	83 ec 04             	sub    $0x4,%esp
80108aad:	68 a8 00 11 80       	push   $0x801100a8
80108ab2:	52                   	push   %edx
80108ab3:	50                   	push   %eax
80108ab4:	e8 82 fe ff ff       	call   8010893b <graphic_draw_pixel>
80108ab9:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80108abc:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80108ac0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108ac4:	0f 89 5f ff ff ff    	jns    80108a29 <font_render+0x23>
  for(int i=0;i<30;i++){
80108aca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ace:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80108ad2:	0f 8e 45 ff ff ff    	jle    80108a1d <font_render+0x17>
      }
    }
  }
}
80108ad8:	90                   	nop
80108ad9:	90                   	nop
80108ada:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108add:	c9                   	leave  
80108ade:	c3                   	ret    

80108adf <font_render_string>:

void font_render_string(char *string,int row){
80108adf:	f3 0f 1e fb          	endbr32 
80108ae3:	55                   	push   %ebp
80108ae4:	89 e5                	mov    %esp,%ebp
80108ae6:	53                   	push   %ebx
80108ae7:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108aea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80108af1:	eb 33                	jmp    80108b26 <font_render_string+0x47>
    font_render(i*15+2,row*30,string[i]);
80108af3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108af6:	8b 45 08             	mov    0x8(%ebp),%eax
80108af9:	01 d0                	add    %edx,%eax
80108afb:	0f b6 00             	movzbl (%eax),%eax
80108afe:	0f be d8             	movsbl %al,%ebx
80108b01:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b04:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108b07:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b0a:	89 d0                	mov    %edx,%eax
80108b0c:	c1 e0 04             	shl    $0x4,%eax
80108b0f:	29 d0                	sub    %edx,%eax
80108b11:	83 c0 02             	add    $0x2,%eax
80108b14:	83 ec 04             	sub    $0x4,%esp
80108b17:	53                   	push   %ebx
80108b18:	51                   	push   %ecx
80108b19:	50                   	push   %eax
80108b1a:	e8 e7 fe ff ff       	call   80108a06 <font_render>
80108b1f:	83 c4 10             	add    $0x10,%esp
    i++;
80108b22:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108b26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108b29:	8b 45 08             	mov    0x8(%ebp),%eax
80108b2c:	01 d0                	add    %edx,%eax
80108b2e:	0f b6 00             	movzbl (%eax),%eax
80108b31:	84 c0                	test   %al,%al
80108b33:	74 06                	je     80108b3b <font_render_string+0x5c>
80108b35:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108b39:	7e b8                	jle    80108af3 <font_render_string+0x14>
  }
}
80108b3b:	90                   	nop
80108b3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b3f:	c9                   	leave  
80108b40:	c3                   	ret    

80108b41 <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
80108b41:	f3 0f 1e fb          	endbr32 
80108b45:	55                   	push   %ebp
80108b46:	89 e5                	mov    %esp,%ebp
80108b48:	53                   	push   %ebx
80108b49:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108b4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b53:	eb 6b                	jmp    80108bc0 <pci_init+0x7f>
    for(int j=0;j<32;j++){
80108b55:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108b5c:	eb 58                	jmp    80108bb6 <pci_init+0x75>
      for(int k=0;k<8;k++){
80108b5e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80108b65:	eb 45                	jmp    80108bac <pci_init+0x6b>
      pci_access_config(i,j,k,0,&data);
80108b67:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108b6a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b70:	83 ec 0c             	sub    $0xc,%esp
80108b73:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108b76:	53                   	push   %ebx
80108b77:	6a 00                	push   $0x0
80108b79:	51                   	push   %ecx
80108b7a:	52                   	push   %edx
80108b7b:	50                   	push   %eax
80108b7c:	e8 c0 00 00 00       	call   80108c41 <pci_access_config>
80108b81:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
80108b84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b87:	0f b7 c0             	movzwl %ax,%eax
80108b8a:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108b8f:	74 17                	je     80108ba8 <pci_init+0x67>
        pci_init_device(i,j,k);
80108b91:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108b94:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9a:	83 ec 04             	sub    $0x4,%esp
80108b9d:	51                   	push   %ecx
80108b9e:	52                   	push   %edx
80108b9f:	50                   	push   %eax
80108ba0:	e8 4f 01 00 00       	call   80108cf4 <pci_init_device>
80108ba5:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108ba8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108bac:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108bb0:	7e b5                	jle    80108b67 <pci_init+0x26>
    for(int j=0;j<32;j++){
80108bb2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108bb6:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108bba:	7e a2                	jle    80108b5e <pci_init+0x1d>
  for(int i=0;i<256;i++){
80108bbc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108bc0:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108bc7:	7e 8c                	jle    80108b55 <pci_init+0x14>
      }
      }
    }
  }
}
80108bc9:	90                   	nop
80108bca:	90                   	nop
80108bcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108bce:	c9                   	leave  
80108bcf:	c3                   	ret    

80108bd0 <pci_write_config>:

void pci_write_config(uint config){
80108bd0:	f3 0f 1e fb          	endbr32 
80108bd4:	55                   	push   %ebp
80108bd5:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
80108bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80108bda:	ba f8 0c 00 00       	mov    $0xcf8,%edx
80108bdf:	89 c0                	mov    %eax,%eax
80108be1:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108be2:	90                   	nop
80108be3:	5d                   	pop    %ebp
80108be4:	c3                   	ret    

80108be5 <pci_write_data>:

void pci_write_data(uint config){
80108be5:	f3 0f 1e fb          	endbr32 
80108be9:	55                   	push   %ebp
80108bea:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
80108bec:	8b 45 08             	mov    0x8(%ebp),%eax
80108bef:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108bf4:	89 c0                	mov    %eax,%eax
80108bf6:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108bf7:	90                   	nop
80108bf8:	5d                   	pop    %ebp
80108bf9:	c3                   	ret    

80108bfa <pci_read_config>:
uint pci_read_config(){
80108bfa:	f3 0f 1e fb          	endbr32 
80108bfe:	55                   	push   %ebp
80108bff:	89 e5                	mov    %esp,%ebp
80108c01:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
80108c04:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108c09:	ed                   	in     (%dx),%eax
80108c0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108c0d:	83 ec 0c             	sub    $0xc,%esp
80108c10:	68 c8 00 00 00       	push   $0xc8
80108c15:	e8 22 a5 ff ff       	call   8010313c <microdelay>
80108c1a:	83 c4 10             	add    $0x10,%esp
  return data;
80108c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80108c20:	c9                   	leave  
80108c21:	c3                   	ret    

80108c22 <pci_test>:


void pci_test(){
80108c22:	f3 0f 1e fb          	endbr32 
80108c26:	55                   	push   %ebp
80108c27:	89 e5                	mov    %esp,%ebp
80108c29:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108c2c:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108c33:	ff 75 fc             	pushl  -0x4(%ebp)
80108c36:	e8 95 ff ff ff       	call   80108bd0 <pci_write_config>
80108c3b:	83 c4 04             	add    $0x4,%esp
}
80108c3e:	90                   	nop
80108c3f:	c9                   	leave  
80108c40:	c3                   	ret    

80108c41 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108c41:	f3 0f 1e fb          	endbr32 
80108c45:	55                   	push   %ebp
80108c46:	89 e5                	mov    %esp,%ebp
80108c48:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80108c4e:	c1 e0 10             	shl    $0x10,%eax
80108c51:	25 00 00 ff 00       	and    $0xff0000,%eax
80108c56:	89 c2                	mov    %eax,%edx
80108c58:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c5b:	c1 e0 0b             	shl    $0xb,%eax
80108c5e:	0f b7 c0             	movzwl %ax,%eax
80108c61:	09 c2                	or     %eax,%edx
80108c63:	8b 45 10             	mov    0x10(%ebp),%eax
80108c66:	c1 e0 08             	shl    $0x8,%eax
80108c69:	25 00 07 00 00       	and    $0x700,%eax
80108c6e:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108c70:	8b 45 14             	mov    0x14(%ebp),%eax
80108c73:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108c78:	09 d0                	or     %edx,%eax
80108c7a:	0d 00 00 00 80       	or     $0x80000000,%eax
80108c7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108c82:	ff 75 f4             	pushl  -0xc(%ebp)
80108c85:	e8 46 ff ff ff       	call   80108bd0 <pci_write_config>
80108c8a:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108c8d:	e8 68 ff ff ff       	call   80108bfa <pci_read_config>
80108c92:	8b 55 18             	mov    0x18(%ebp),%edx
80108c95:	89 02                	mov    %eax,(%edx)
}
80108c97:	90                   	nop
80108c98:	c9                   	leave  
80108c99:	c3                   	ret    

80108c9a <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108c9a:	f3 0f 1e fb          	endbr32 
80108c9e:	55                   	push   %ebp
80108c9f:	89 e5                	mov    %esp,%ebp
80108ca1:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca7:	c1 e0 10             	shl    $0x10,%eax
80108caa:	25 00 00 ff 00       	and    $0xff0000,%eax
80108caf:	89 c2                	mov    %eax,%edx
80108cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cb4:	c1 e0 0b             	shl    $0xb,%eax
80108cb7:	0f b7 c0             	movzwl %ax,%eax
80108cba:	09 c2                	or     %eax,%edx
80108cbc:	8b 45 10             	mov    0x10(%ebp),%eax
80108cbf:	c1 e0 08             	shl    $0x8,%eax
80108cc2:	25 00 07 00 00       	and    $0x700,%eax
80108cc7:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108cc9:	8b 45 14             	mov    0x14(%ebp),%eax
80108ccc:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108cd1:	09 d0                	or     %edx,%eax
80108cd3:	0d 00 00 00 80       	or     $0x80000000,%eax
80108cd8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108cdb:	ff 75 fc             	pushl  -0x4(%ebp)
80108cde:	e8 ed fe ff ff       	call   80108bd0 <pci_write_config>
80108ce3:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
80108ce6:	ff 75 18             	pushl  0x18(%ebp)
80108ce9:	e8 f7 fe ff ff       	call   80108be5 <pci_write_data>
80108cee:	83 c4 04             	add    $0x4,%esp
}
80108cf1:	90                   	nop
80108cf2:	c9                   	leave  
80108cf3:	c3                   	ret    

80108cf4 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
80108cf4:	f3 0f 1e fb          	endbr32 
80108cf8:	55                   	push   %ebp
80108cf9:	89 e5                	mov    %esp,%ebp
80108cfb:	53                   	push   %ebx
80108cfc:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
80108cff:	8b 45 08             	mov    0x8(%ebp),%eax
80108d02:	a2 dc b1 11 80       	mov    %al,0x8011b1dc
  dev.device_num = device_num;
80108d07:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d0a:	a2 dd b1 11 80       	mov    %al,0x8011b1dd
  dev.function_num = function_num;
80108d0f:	8b 45 10             	mov    0x10(%ebp),%eax
80108d12:	a2 de b1 11 80       	mov    %al,0x8011b1de
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108d17:	ff 75 10             	pushl  0x10(%ebp)
80108d1a:	ff 75 0c             	pushl  0xc(%ebp)
80108d1d:	ff 75 08             	pushl  0x8(%ebp)
80108d20:	68 64 c8 10 80       	push   $0x8010c864
80108d25:	e8 e2 76 ff ff       	call   8010040c <cprintf>
80108d2a:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108d2d:	83 ec 0c             	sub    $0xc,%esp
80108d30:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d33:	50                   	push   %eax
80108d34:	6a 00                	push   $0x0
80108d36:	ff 75 10             	pushl  0x10(%ebp)
80108d39:	ff 75 0c             	pushl  0xc(%ebp)
80108d3c:	ff 75 08             	pushl  0x8(%ebp)
80108d3f:	e8 fd fe ff ff       	call   80108c41 <pci_access_config>
80108d44:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108d47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d4a:	c1 e8 10             	shr    $0x10,%eax
80108d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
80108d50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d53:	25 ff ff 00 00       	and    $0xffff,%eax
80108d58:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d5e:	a3 e0 b1 11 80       	mov    %eax,0x8011b1e0
  dev.vendor_id = vendor_id;
80108d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d66:	a3 e4 b1 11 80       	mov    %eax,0x8011b1e4
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108d6b:	83 ec 04             	sub    $0x4,%esp
80108d6e:	ff 75 f0             	pushl  -0x10(%ebp)
80108d71:	ff 75 f4             	pushl  -0xc(%ebp)
80108d74:	68 98 c8 10 80       	push   $0x8010c898
80108d79:	e8 8e 76 ff ff       	call   8010040c <cprintf>
80108d7e:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
80108d81:	83 ec 0c             	sub    $0xc,%esp
80108d84:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d87:	50                   	push   %eax
80108d88:	6a 08                	push   $0x8
80108d8a:	ff 75 10             	pushl  0x10(%ebp)
80108d8d:	ff 75 0c             	pushl  0xc(%ebp)
80108d90:	ff 75 08             	pushl  0x8(%ebp)
80108d93:	e8 a9 fe ff ff       	call   80108c41 <pci_access_config>
80108d98:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108d9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d9e:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108da1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108da4:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108da7:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108daa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dad:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108db0:	0f b6 c0             	movzbl %al,%eax
80108db3:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108db6:	c1 eb 18             	shr    $0x18,%ebx
80108db9:	83 ec 0c             	sub    $0xc,%esp
80108dbc:	51                   	push   %ecx
80108dbd:	52                   	push   %edx
80108dbe:	50                   	push   %eax
80108dbf:	53                   	push   %ebx
80108dc0:	68 bc c8 10 80       	push   $0x8010c8bc
80108dc5:	e8 42 76 ff ff       	call   8010040c <cprintf>
80108dca:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108dcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dd0:	c1 e8 18             	shr    $0x18,%eax
80108dd3:	a2 e8 b1 11 80       	mov    %al,0x8011b1e8
  dev.sub_class = (data>>16)&0xFF;
80108dd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ddb:	c1 e8 10             	shr    $0x10,%eax
80108dde:	a2 e9 b1 11 80       	mov    %al,0x8011b1e9
  dev.interface = (data>>8)&0xFF;
80108de3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108de6:	c1 e8 08             	shr    $0x8,%eax
80108de9:	a2 ea b1 11 80       	mov    %al,0x8011b1ea
  dev.revision_id = data&0xFF;
80108dee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108df1:	a2 eb b1 11 80       	mov    %al,0x8011b1eb
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
80108df6:	83 ec 0c             	sub    $0xc,%esp
80108df9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108dfc:	50                   	push   %eax
80108dfd:	6a 10                	push   $0x10
80108dff:	ff 75 10             	pushl  0x10(%ebp)
80108e02:	ff 75 0c             	pushl  0xc(%ebp)
80108e05:	ff 75 08             	pushl  0x8(%ebp)
80108e08:	e8 34 fe ff ff       	call   80108c41 <pci_access_config>
80108e0d:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
80108e10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e13:	a3 ec b1 11 80       	mov    %eax,0x8011b1ec
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108e18:	83 ec 0c             	sub    $0xc,%esp
80108e1b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e1e:	50                   	push   %eax
80108e1f:	6a 14                	push   $0x14
80108e21:	ff 75 10             	pushl  0x10(%ebp)
80108e24:	ff 75 0c             	pushl  0xc(%ebp)
80108e27:	ff 75 08             	pushl  0x8(%ebp)
80108e2a:	e8 12 fe ff ff       	call   80108c41 <pci_access_config>
80108e2f:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
80108e32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e35:	a3 f0 b1 11 80       	mov    %eax,0x8011b1f0
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108e3a:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
80108e41:	75 5a                	jne    80108e9d <pci_init_device+0x1a9>
80108e43:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108e4a:	75 51                	jne    80108e9d <pci_init_device+0x1a9>
    cprintf("E1000 Ethernet NIC Found\n");
80108e4c:	83 ec 0c             	sub    $0xc,%esp
80108e4f:	68 01 c9 10 80       	push   $0x8010c901
80108e54:	e8 b3 75 ff ff       	call   8010040c <cprintf>
80108e59:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108e5c:	83 ec 0c             	sub    $0xc,%esp
80108e5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108e62:	50                   	push   %eax
80108e63:	68 f0 00 00 00       	push   $0xf0
80108e68:	ff 75 10             	pushl  0x10(%ebp)
80108e6b:	ff 75 0c             	pushl  0xc(%ebp)
80108e6e:	ff 75 08             	pushl  0x8(%ebp)
80108e71:	e8 cb fd ff ff       	call   80108c41 <pci_access_config>
80108e76:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108e79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e7c:	83 ec 08             	sub    $0x8,%esp
80108e7f:	50                   	push   %eax
80108e80:	68 1b c9 10 80       	push   $0x8010c91b
80108e85:	e8 82 75 ff ff       	call   8010040c <cprintf>
80108e8a:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108e8d:	83 ec 0c             	sub    $0xc,%esp
80108e90:	68 dc b1 11 80       	push   $0x8011b1dc
80108e95:	e8 09 00 00 00       	call   80108ea3 <i8254_init>
80108e9a:	83 c4 10             	add    $0x10,%esp
  }
}
80108e9d:	90                   	nop
80108e9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108ea1:	c9                   	leave  
80108ea2:	c3                   	ret    

80108ea3 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108ea3:	f3 0f 1e fb          	endbr32 
80108ea7:	55                   	push   %ebp
80108ea8:	89 e5                	mov    %esp,%ebp
80108eaa:	53                   	push   %ebx
80108eab:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108eae:	8b 45 08             	mov    0x8(%ebp),%eax
80108eb1:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108eb5:	0f b6 c8             	movzbl %al,%ecx
80108eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80108ebb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108ebf:	0f b6 d0             	movzbl %al,%edx
80108ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ec5:	0f b6 00             	movzbl (%eax),%eax
80108ec8:	0f b6 c0             	movzbl %al,%eax
80108ecb:	83 ec 0c             	sub    $0xc,%esp
80108ece:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108ed1:	53                   	push   %ebx
80108ed2:	6a 04                	push   $0x4
80108ed4:	51                   	push   %ecx
80108ed5:	52                   	push   %edx
80108ed6:	50                   	push   %eax
80108ed7:	e8 65 fd ff ff       	call   80108c41 <pci_access_config>
80108edc:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108edf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ee2:	83 c8 04             	or     $0x4,%eax
80108ee5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
80108ee8:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80108eee:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108ef2:	0f b6 c8             	movzbl %al,%ecx
80108ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108efc:	0f b6 d0             	movzbl %al,%edx
80108eff:	8b 45 08             	mov    0x8(%ebp),%eax
80108f02:	0f b6 00             	movzbl (%eax),%eax
80108f05:	0f b6 c0             	movzbl %al,%eax
80108f08:	83 ec 0c             	sub    $0xc,%esp
80108f0b:	53                   	push   %ebx
80108f0c:	6a 04                	push   $0x4
80108f0e:	51                   	push   %ecx
80108f0f:	52                   	push   %edx
80108f10:	50                   	push   %eax
80108f11:	e8 84 fd ff ff       	call   80108c9a <pci_write_config_register>
80108f16:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
80108f19:	8b 45 08             	mov    0x8(%ebp),%eax
80108f1c:	8b 40 10             	mov    0x10(%eax),%eax
80108f1f:	05 00 00 00 40       	add    $0x40000000,%eax
80108f24:	a3 f4 b1 11 80       	mov    %eax,0x8011b1f4
  uint *ctrl = (uint *)base_addr;
80108f29:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80108f2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108f31:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80108f36:	05 d8 00 00 00       	add    $0xd8,%eax
80108f3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f41:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f4a:	8b 00                	mov    (%eax),%eax
80108f4c:	0d 00 00 00 04       	or     $0x4000000,%eax
80108f51:	89 c2                	mov    %eax,%edx
80108f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f56:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108f58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f5b:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f64:	8b 00                	mov    (%eax),%eax
80108f66:	83 c8 40             	or     $0x40,%eax
80108f69:	89 c2                	mov    %eax,%edx
80108f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6e:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f73:	8b 10                	mov    (%eax),%edx
80108f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f78:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108f7a:	83 ec 0c             	sub    $0xc,%esp
80108f7d:	68 30 c9 10 80       	push   $0x8010c930
80108f82:	e8 85 74 ff ff       	call   8010040c <cprintf>
80108f87:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108f8a:	e8 fb 9d ff ff       	call   80102d8a <kalloc>
80108f8f:	a3 f8 b1 11 80       	mov    %eax,0x8011b1f8
  *intr_addr = 0;
80108f94:	a1 f8 b1 11 80       	mov    0x8011b1f8,%eax
80108f99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108f9f:	a1 f8 b1 11 80       	mov    0x8011b1f8,%eax
80108fa4:	83 ec 08             	sub    $0x8,%esp
80108fa7:	50                   	push   %eax
80108fa8:	68 52 c9 10 80       	push   $0x8010c952
80108fad:	e8 5a 74 ff ff       	call   8010040c <cprintf>
80108fb2:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
80108fb5:	e8 50 00 00 00       	call   8010900a <i8254_init_recv>
  i8254_init_send();
80108fba:	e8 6d 03 00 00       	call   8010932c <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108fbf:	0f b6 05 07 f5 10 80 	movzbl 0x8010f507,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108fc6:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108fc9:	0f b6 05 06 f5 10 80 	movzbl 0x8010f506,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108fd0:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108fd3:	0f b6 05 05 f5 10 80 	movzbl 0x8010f505,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108fda:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108fdd:	0f b6 05 04 f5 10 80 	movzbl 0x8010f504,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108fe4:	0f b6 c0             	movzbl %al,%eax
80108fe7:	83 ec 0c             	sub    $0xc,%esp
80108fea:	53                   	push   %ebx
80108feb:	51                   	push   %ecx
80108fec:	52                   	push   %edx
80108fed:	50                   	push   %eax
80108fee:	68 60 c9 10 80       	push   $0x8010c960
80108ff3:	e8 14 74 ff ff       	call   8010040c <cprintf>
80108ff8:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
80108ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ffe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
80109004:	90                   	nop
80109005:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109008:	c9                   	leave  
80109009:	c3                   	ret    

8010900a <i8254_init_recv>:

void i8254_init_recv(){
8010900a:	f3 0f 1e fb          	endbr32 
8010900e:	55                   	push   %ebp
8010900f:	89 e5                	mov    %esp,%ebp
80109011:	57                   	push   %edi
80109012:	56                   	push   %esi
80109013:	53                   	push   %ebx
80109014:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80109017:	83 ec 0c             	sub    $0xc,%esp
8010901a:	6a 00                	push   $0x0
8010901c:	e8 ec 04 00 00       	call   8010950d <i8254_read_eeprom>
80109021:	83 c4 10             	add    $0x10,%esp
80109024:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80109027:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010902a:	a2 ac 00 11 80       	mov    %al,0x801100ac
  mac_addr[1] = data_l>>8;
8010902f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109032:	c1 e8 08             	shr    $0x8,%eax
80109035:	a2 ad 00 11 80       	mov    %al,0x801100ad
  uint data_m = i8254_read_eeprom(0x1);
8010903a:	83 ec 0c             	sub    $0xc,%esp
8010903d:	6a 01                	push   $0x1
8010903f:	e8 c9 04 00 00       	call   8010950d <i8254_read_eeprom>
80109044:	83 c4 10             	add    $0x10,%esp
80109047:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
8010904a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010904d:	a2 ae 00 11 80       	mov    %al,0x801100ae
  mac_addr[3] = data_m>>8;
80109052:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109055:	c1 e8 08             	shr    $0x8,%eax
80109058:	a2 af 00 11 80       	mov    %al,0x801100af
  uint data_h = i8254_read_eeprom(0x2);
8010905d:	83 ec 0c             	sub    $0xc,%esp
80109060:	6a 02                	push   $0x2
80109062:	e8 a6 04 00 00       	call   8010950d <i8254_read_eeprom>
80109067:	83 c4 10             	add    $0x10,%esp
8010906a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010906d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109070:	a2 b0 00 11 80       	mov    %al,0x801100b0
  mac_addr[5] = data_h>>8;
80109075:	8b 45 d0             	mov    -0x30(%ebp),%eax
80109078:	c1 e8 08             	shr    $0x8,%eax
8010907b:	a2 b1 00 11 80       	mov    %al,0x801100b1
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80109080:	0f b6 05 b1 00 11 80 	movzbl 0x801100b1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109087:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
8010908a:	0f b6 05 b0 00 11 80 	movzbl 0x801100b0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80109091:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80109094:	0f b6 05 af 00 11 80 	movzbl 0x801100af,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010909b:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
8010909e:	0f b6 05 ae 00 11 80 	movzbl 0x801100ae,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090a5:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
801090a8:	0f b6 05 ad 00 11 80 	movzbl 0x801100ad,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090af:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801090b2:	0f b6 05 ac 00 11 80 	movzbl 0x801100ac,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801090b9:	0f b6 c0             	movzbl %al,%eax
801090bc:	83 ec 04             	sub    $0x4,%esp
801090bf:	57                   	push   %edi
801090c0:	56                   	push   %esi
801090c1:	53                   	push   %ebx
801090c2:	51                   	push   %ecx
801090c3:	52                   	push   %edx
801090c4:	50                   	push   %eax
801090c5:	68 78 c9 10 80       	push   $0x8010c978
801090ca:	e8 3d 73 ff ff       	call   8010040c <cprintf>
801090cf:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801090d2:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801090d7:	05 00 54 00 00       	add    $0x5400,%eax
801090dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
801090df:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801090e4:	05 04 54 00 00       	add    $0x5404,%eax
801090e9:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
801090ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801090ef:	c1 e0 10             	shl    $0x10,%eax
801090f2:	0b 45 d8             	or     -0x28(%ebp),%eax
801090f5:	89 c2                	mov    %eax,%edx
801090f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
801090fa:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801090fc:	8b 45 d0             	mov    -0x30(%ebp),%eax
801090ff:	0d 00 00 00 80       	or     $0x80000000,%eax
80109104:	89 c2                	mov    %eax,%edx
80109106:	8b 45 c8             	mov    -0x38(%ebp),%eax
80109109:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
8010910b:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109110:	05 00 52 00 00       	add    $0x5200,%eax
80109115:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80109118:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010911f:	eb 19                	jmp    8010913a <i8254_init_recv+0x130>
    mta[i] = 0;
80109121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109124:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010912b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
8010912e:	01 d0                	add    %edx,%eax
80109130:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80109136:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010913a:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
8010913e:	7e e1                	jle    80109121 <i8254_init_recv+0x117>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80109140:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109145:	05 d0 00 00 00       	add    $0xd0,%eax
8010914a:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010914d:	8b 45 c0             	mov    -0x40(%ebp),%eax
80109150:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80109156:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010915b:	05 c8 00 00 00       	add    $0xc8,%eax
80109160:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80109163:	8b 45 bc             	mov    -0x44(%ebp),%eax
80109166:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
8010916c:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109171:	05 28 28 00 00       	add    $0x2828,%eax
80109176:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80109179:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010917c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80109182:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109187:	05 00 01 00 00       	add    $0x100,%eax
8010918c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
8010918f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109192:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80109198:	e8 ed 9b ff ff       	call   80102d8a <kalloc>
8010919d:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
801091a0:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801091a5:	05 00 28 00 00       	add    $0x2800,%eax
801091aa:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
801091ad:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801091b2:	05 04 28 00 00       	add    $0x2804,%eax
801091b7:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
801091ba:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801091bf:	05 08 28 00 00       	add    $0x2808,%eax
801091c4:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
801091c7:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801091cc:	05 10 28 00 00       	add    $0x2810,%eax
801091d1:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801091d4:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801091d9:	05 18 28 00 00       	add    $0x2818,%eax
801091de:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801091e1:	8b 45 b0             	mov    -0x50(%ebp),%eax
801091e4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801091ea:	8b 45 ac             	mov    -0x54(%ebp),%eax
801091ed:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801091ef:	8b 45 a8             	mov    -0x58(%ebp),%eax
801091f2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801091f8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801091fb:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80109201:	8b 45 a0             	mov    -0x60(%ebp),%eax
80109204:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
8010920a:	8b 45 9c             	mov    -0x64(%ebp),%eax
8010920d:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80109213:	8b 45 b0             	mov    -0x50(%ebp),%eax
80109216:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109219:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80109220:	eb 73                	jmp    80109295 <i8254_init_recv+0x28b>
    recv_desc[i].padding = 0;
80109222:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109225:	c1 e0 04             	shl    $0x4,%eax
80109228:	89 c2                	mov    %eax,%edx
8010922a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010922d:	01 d0                	add    %edx,%eax
8010922f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80109236:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109239:	c1 e0 04             	shl    $0x4,%eax
8010923c:	89 c2                	mov    %eax,%edx
8010923e:	8b 45 98             	mov    -0x68(%ebp),%eax
80109241:	01 d0                	add    %edx,%eax
80109243:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80109249:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010924c:	c1 e0 04             	shl    $0x4,%eax
8010924f:	89 c2                	mov    %eax,%edx
80109251:	8b 45 98             	mov    -0x68(%ebp),%eax
80109254:	01 d0                	add    %edx,%eax
80109256:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
8010925c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010925f:	c1 e0 04             	shl    $0x4,%eax
80109262:	89 c2                	mov    %eax,%edx
80109264:	8b 45 98             	mov    -0x68(%ebp),%eax
80109267:	01 d0                	add    %edx,%eax
80109269:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
8010926d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109270:	c1 e0 04             	shl    $0x4,%eax
80109273:	89 c2                	mov    %eax,%edx
80109275:	8b 45 98             	mov    -0x68(%ebp),%eax
80109278:	01 d0                	add    %edx,%eax
8010927a:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
8010927e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109281:	c1 e0 04             	shl    $0x4,%eax
80109284:	89 c2                	mov    %eax,%edx
80109286:	8b 45 98             	mov    -0x68(%ebp),%eax
80109289:	01 d0                	add    %edx,%eax
8010928b:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80109291:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80109295:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010929c:	7e 84                	jle    80109222 <i8254_init_recv+0x218>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
8010929e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801092a5:	eb 57                	jmp    801092fe <i8254_init_recv+0x2f4>
    uint buf_addr = (uint)kalloc();
801092a7:	e8 de 9a ff ff       	call   80102d8a <kalloc>
801092ac:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
801092af:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
801092b3:	75 12                	jne    801092c7 <i8254_init_recv+0x2bd>
      cprintf("failed to allocate buffer area\n");
801092b5:	83 ec 0c             	sub    $0xc,%esp
801092b8:	68 98 c9 10 80       	push   $0x8010c998
801092bd:	e8 4a 71 ff ff       	call   8010040c <cprintf>
801092c2:	83 c4 10             	add    $0x10,%esp
      break;
801092c5:	eb 3d                	jmp    80109304 <i8254_init_recv+0x2fa>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
801092c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801092ca:	c1 e0 04             	shl    $0x4,%eax
801092cd:	89 c2                	mov    %eax,%edx
801092cf:	8b 45 98             	mov    -0x68(%ebp),%eax
801092d2:	01 d0                	add    %edx,%eax
801092d4:	8b 55 94             	mov    -0x6c(%ebp),%edx
801092d7:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801092dd:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801092df:	8b 45 dc             	mov    -0x24(%ebp),%eax
801092e2:	83 c0 01             	add    $0x1,%eax
801092e5:	c1 e0 04             	shl    $0x4,%eax
801092e8:	89 c2                	mov    %eax,%edx
801092ea:	8b 45 98             	mov    -0x68(%ebp),%eax
801092ed:	01 d0                	add    %edx,%eax
801092ef:	8b 55 94             	mov    -0x6c(%ebp),%edx
801092f2:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801092f8:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801092fa:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801092fe:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80109302:	7e a3                	jle    801092a7 <i8254_init_recv+0x29d>
  }

  *rctl |= I8254_RCTL_EN;
80109304:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109307:	8b 00                	mov    (%eax),%eax
80109309:	83 c8 02             	or     $0x2,%eax
8010930c:	89 c2                	mov    %eax,%edx
8010930e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80109311:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80109313:	83 ec 0c             	sub    $0xc,%esp
80109316:	68 b8 c9 10 80       	push   $0x8010c9b8
8010931b:	e8 ec 70 ff ff       	call   8010040c <cprintf>
80109320:	83 c4 10             	add    $0x10,%esp
}
80109323:	90                   	nop
80109324:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109327:	5b                   	pop    %ebx
80109328:	5e                   	pop    %esi
80109329:	5f                   	pop    %edi
8010932a:	5d                   	pop    %ebp
8010932b:	c3                   	ret    

8010932c <i8254_init_send>:

void i8254_init_send(){
8010932c:	f3 0f 1e fb          	endbr32 
80109330:	55                   	push   %ebp
80109331:	89 e5                	mov    %esp,%ebp
80109333:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80109336:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010933b:	05 28 38 00 00       	add    $0x3828,%eax
80109340:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80109343:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109346:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
8010934c:	e8 39 9a ff ff       	call   80102d8a <kalloc>
80109351:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109354:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109359:	05 00 38 00 00       	add    $0x3800,%eax
8010935e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80109361:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109366:	05 04 38 00 00       	add    $0x3804,%eax
8010936b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
8010936e:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109373:	05 08 38 00 00       	add    $0x3808,%eax
80109378:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
8010937b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010937e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80109384:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109387:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80109389:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010938c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80109392:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109395:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010939b:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801093a0:	05 10 38 00 00       	add    $0x3810,%eax
801093a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
801093a8:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801093ad:	05 18 38 00 00       	add    $0x3818,%eax
801093b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
801093b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801093b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
801093be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801093c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
801093c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801093ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801093cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801093d4:	e9 82 00 00 00       	jmp    8010945b <i8254_init_send+0x12f>
    send_desc[i].padding = 0;
801093d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093dc:	c1 e0 04             	shl    $0x4,%eax
801093df:	89 c2                	mov    %eax,%edx
801093e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801093e4:	01 d0                	add    %edx,%eax
801093e6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801093ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f0:	c1 e0 04             	shl    $0x4,%eax
801093f3:	89 c2                	mov    %eax,%edx
801093f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801093f8:	01 d0                	add    %edx,%eax
801093fa:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80109400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109403:	c1 e0 04             	shl    $0x4,%eax
80109406:	89 c2                	mov    %eax,%edx
80109408:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010940b:	01 d0                	add    %edx,%eax
8010940d:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80109411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109414:	c1 e0 04             	shl    $0x4,%eax
80109417:	89 c2                	mov    %eax,%edx
80109419:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010941c:	01 d0                	add    %edx,%eax
8010941e:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80109422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109425:	c1 e0 04             	shl    $0x4,%eax
80109428:	89 c2                	mov    %eax,%edx
8010942a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010942d:	01 d0                	add    %edx,%eax
8010942f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80109433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109436:	c1 e0 04             	shl    $0x4,%eax
80109439:	89 c2                	mov    %eax,%edx
8010943b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010943e:	01 d0                	add    %edx,%eax
80109440:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80109444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109447:	c1 e0 04             	shl    $0x4,%eax
8010944a:	89 c2                	mov    %eax,%edx
8010944c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010944f:	01 d0                	add    %edx,%eax
80109451:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80109457:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010945b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109462:	0f 8e 71 ff ff ff    	jle    801093d9 <i8254_init_send+0xad>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80109468:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010946f:	eb 57                	jmp    801094c8 <i8254_init_send+0x19c>
    uint buf_addr = (uint)kalloc();
80109471:	e8 14 99 ff ff       	call   80102d8a <kalloc>
80109476:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80109479:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
8010947d:	75 12                	jne    80109491 <i8254_init_send+0x165>
      cprintf("failed to allocate buffer area\n");
8010947f:	83 ec 0c             	sub    $0xc,%esp
80109482:	68 98 c9 10 80       	push   $0x8010c998
80109487:	e8 80 6f ff ff       	call   8010040c <cprintf>
8010948c:	83 c4 10             	add    $0x10,%esp
      break;
8010948f:	eb 3d                	jmp    801094ce <i8254_init_send+0x1a2>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80109491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109494:	c1 e0 04             	shl    $0x4,%eax
80109497:	89 c2                	mov    %eax,%edx
80109499:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010949c:	01 d0                	add    %edx,%eax
8010949e:	8b 55 cc             	mov    -0x34(%ebp),%edx
801094a1:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801094a7:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801094a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094ac:	83 c0 01             	add    $0x1,%eax
801094af:	c1 e0 04             	shl    $0x4,%eax
801094b2:	89 c2                	mov    %eax,%edx
801094b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
801094b7:	01 d0                	add    %edx,%eax
801094b9:	8b 55 cc             	mov    -0x34(%ebp),%edx
801094bc:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801094c2:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801094c4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801094c8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801094cc:	7e a3                	jle    80109471 <i8254_init_send+0x145>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
801094ce:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801094d3:	05 00 04 00 00       	add    $0x400,%eax
801094d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801094db:	8b 45 c8             	mov    -0x38(%ebp),%eax
801094de:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801094e4:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
801094e9:	05 10 04 00 00       	add    $0x410,%eax
801094ee:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801094f1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801094f4:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801094fa:	83 ec 0c             	sub    $0xc,%esp
801094fd:	68 d8 c9 10 80       	push   $0x8010c9d8
80109502:	e8 05 6f ff ff       	call   8010040c <cprintf>
80109507:	83 c4 10             	add    $0x10,%esp

}
8010950a:	90                   	nop
8010950b:	c9                   	leave  
8010950c:	c3                   	ret    

8010950d <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
8010950d:	f3 0f 1e fb          	endbr32 
80109511:	55                   	push   %ebp
80109512:	89 e5                	mov    %esp,%ebp
80109514:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80109517:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010951c:	83 c0 14             	add    $0x14,%eax
8010951f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80109522:	8b 45 08             	mov    0x8(%ebp),%eax
80109525:	c1 e0 08             	shl    $0x8,%eax
80109528:	0f b7 c0             	movzwl %ax,%eax
8010952b:	83 c8 01             	or     $0x1,%eax
8010952e:	89 c2                	mov    %eax,%edx
80109530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109533:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80109535:	83 ec 0c             	sub    $0xc,%esp
80109538:	68 f8 c9 10 80       	push   $0x8010c9f8
8010953d:	e8 ca 6e ff ff       	call   8010040c <cprintf>
80109542:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80109545:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109548:	8b 00                	mov    (%eax),%eax
8010954a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
8010954d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109550:	83 e0 10             	and    $0x10,%eax
80109553:	85 c0                	test   %eax,%eax
80109555:	75 02                	jne    80109559 <i8254_read_eeprom+0x4c>
  while(1){
80109557:	eb dc                	jmp    80109535 <i8254_read_eeprom+0x28>
      break;
80109559:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
8010955a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010955d:	8b 00                	mov    (%eax),%eax
8010955f:	c1 e8 10             	shr    $0x10,%eax
}
80109562:	c9                   	leave  
80109563:	c3                   	ret    

80109564 <i8254_recv>:
void i8254_recv(){
80109564:	f3 0f 1e fb          	endbr32 
80109568:	55                   	push   %ebp
80109569:	89 e5                	mov    %esp,%ebp
8010956b:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
8010956e:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109573:	05 10 28 00 00       	add    $0x2810,%eax
80109578:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010957b:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109580:	05 18 28 00 00       	add    $0x2818,%eax
80109585:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80109588:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010958d:	05 00 28 00 00       	add    $0x2800,%eax
80109592:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80109595:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109598:	8b 00                	mov    (%eax),%eax
8010959a:	05 00 00 00 80       	add    $0x80000000,%eax
8010959f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
801095a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a5:	8b 10                	mov    (%eax),%edx
801095a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095aa:	8b 00                	mov    (%eax),%eax
801095ac:	29 c2                	sub    %eax,%edx
801095ae:	89 d0                	mov    %edx,%eax
801095b0:	25 ff 00 00 00       	and    $0xff,%eax
801095b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
801095b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801095bc:	7e 37                	jle    801095f5 <i8254_recv+0x91>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
801095be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095c1:	8b 00                	mov    (%eax),%eax
801095c3:	c1 e0 04             	shl    $0x4,%eax
801095c6:	89 c2                	mov    %eax,%edx
801095c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801095cb:	01 d0                	add    %edx,%eax
801095cd:	8b 00                	mov    (%eax),%eax
801095cf:	05 00 00 00 80       	add    $0x80000000,%eax
801095d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
801095d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095da:	8b 00                	mov    (%eax),%eax
801095dc:	83 c0 01             	add    $0x1,%eax
801095df:	0f b6 d0             	movzbl %al,%edx
801095e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095e5:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
801095e7:	83 ec 0c             	sub    $0xc,%esp
801095ea:	ff 75 e0             	pushl  -0x20(%ebp)
801095ed:	e8 47 09 00 00       	call   80109f39 <eth_proc>
801095f2:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
801095f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095f8:	8b 10                	mov    (%eax),%edx
801095fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095fd:	8b 00                	mov    (%eax),%eax
801095ff:	39 c2                	cmp    %eax,%edx
80109601:	75 9f                	jne    801095a2 <i8254_recv+0x3e>
      (*rdt)--;
80109603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109606:	8b 00                	mov    (%eax),%eax
80109608:	8d 50 ff             	lea    -0x1(%eax),%edx
8010960b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010960e:	89 10                	mov    %edx,(%eax)
  while(1){
80109610:	eb 90                	jmp    801095a2 <i8254_recv+0x3e>

80109612 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80109612:	f3 0f 1e fb          	endbr32 
80109616:	55                   	push   %ebp
80109617:	89 e5                	mov    %esp,%ebp
80109619:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
8010961c:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
80109621:	05 10 38 00 00       	add    $0x3810,%eax
80109626:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80109629:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010962e:	05 18 38 00 00       	add    $0x3818,%eax
80109633:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80109636:	a1 f4 b1 11 80       	mov    0x8011b1f4,%eax
8010963b:	05 00 38 00 00       	add    $0x3800,%eax
80109640:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109643:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109646:	8b 00                	mov    (%eax),%eax
80109648:	05 00 00 00 80       	add    $0x80000000,%eax
8010964d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109653:	8b 10                	mov    (%eax),%edx
80109655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109658:	8b 00                	mov    (%eax),%eax
8010965a:	29 c2                	sub    %eax,%edx
8010965c:	89 d0                	mov    %edx,%eax
8010965e:	0f b6 c0             	movzbl %al,%eax
80109661:	ba 00 01 00 00       	mov    $0x100,%edx
80109666:	29 c2                	sub    %eax,%edx
80109668:	89 d0                	mov    %edx,%eax
8010966a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010966d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109670:	8b 00                	mov    (%eax),%eax
80109672:	25 ff 00 00 00       	and    $0xff,%eax
80109677:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010967a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010967e:	0f 8e a8 00 00 00    	jle    8010972c <i8254_send+0x11a>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109684:	8b 45 08             	mov    0x8(%ebp),%eax
80109687:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010968a:	89 d1                	mov    %edx,%ecx
8010968c:	c1 e1 04             	shl    $0x4,%ecx
8010968f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109692:	01 ca                	add    %ecx,%edx
80109694:	8b 12                	mov    (%edx),%edx
80109696:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010969c:	83 ec 04             	sub    $0x4,%esp
8010969f:	ff 75 0c             	pushl  0xc(%ebp)
801096a2:	50                   	push   %eax
801096a3:	52                   	push   %edx
801096a4:	e8 31 bd ff ff       	call   801053da <memmove>
801096a9:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
801096ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096af:	c1 e0 04             	shl    $0x4,%eax
801096b2:	89 c2                	mov    %eax,%edx
801096b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096b7:	01 d0                	add    %edx,%eax
801096b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801096bc:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
801096c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096c3:	c1 e0 04             	shl    $0x4,%eax
801096c6:	89 c2                	mov    %eax,%edx
801096c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096cb:	01 d0                	add    %edx,%eax
801096cd:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
801096d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096d4:	c1 e0 04             	shl    $0x4,%eax
801096d7:	89 c2                	mov    %eax,%edx
801096d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096dc:	01 d0                	add    %edx,%eax
801096de:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801096e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096e5:	c1 e0 04             	shl    $0x4,%eax
801096e8:	89 c2                	mov    %eax,%edx
801096ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096ed:	01 d0                	add    %edx,%eax
801096ef:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801096f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801096f6:	c1 e0 04             	shl    $0x4,%eax
801096f9:	89 c2                	mov    %eax,%edx
801096fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096fe:	01 d0                	add    %edx,%eax
80109700:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80109706:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109709:	c1 e0 04             	shl    $0x4,%eax
8010970c:	89 c2                	mov    %eax,%edx
8010970e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109711:	01 d0                	add    %edx,%eax
80109713:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80109717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010971a:	8b 00                	mov    (%eax),%eax
8010971c:	83 c0 01             	add    $0x1,%eax
8010971f:	0f b6 d0             	movzbl %al,%edx
80109722:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109725:	89 10                	mov    %edx,(%eax)
    return len;
80109727:	8b 45 0c             	mov    0xc(%ebp),%eax
8010972a:	eb 05                	jmp    80109731 <i8254_send+0x11f>
  }else{
    return -1;
8010972c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80109731:	c9                   	leave  
80109732:	c3                   	ret    

80109733 <i8254_intr>:

void i8254_intr(){
80109733:	f3 0f 1e fb          	endbr32 
80109737:	55                   	push   %ebp
80109738:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
8010973a:	a1 f8 b1 11 80       	mov    0x8011b1f8,%eax
8010973f:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109745:	90                   	nop
80109746:	5d                   	pop    %ebp
80109747:	c3                   	ret    

80109748 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109748:	f3 0f 1e fb          	endbr32 
8010974c:	55                   	push   %ebp
8010974d:	89 e5                	mov    %esp,%ebp
8010974f:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80109752:	8b 45 08             	mov    0x8(%ebp),%eax
80109755:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010975b:	0f b7 00             	movzwl (%eax),%eax
8010975e:	66 3d 00 01          	cmp    $0x100,%ax
80109762:	74 0a                	je     8010976e <arp_proc+0x26>
80109764:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109769:	e9 4f 01 00 00       	jmp    801098bd <arp_proc+0x175>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
8010976e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109771:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109775:	66 83 f8 08          	cmp    $0x8,%ax
80109779:	74 0a                	je     80109785 <arp_proc+0x3d>
8010977b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109780:	e9 38 01 00 00       	jmp    801098bd <arp_proc+0x175>
  if(arp_p->hrd_len != 6) return -1;
80109785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109788:	0f b6 40 04          	movzbl 0x4(%eax),%eax
8010978c:	3c 06                	cmp    $0x6,%al
8010978e:	74 0a                	je     8010979a <arp_proc+0x52>
80109790:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109795:	e9 23 01 00 00       	jmp    801098bd <arp_proc+0x175>
  if(arp_p->pro_len != 4) return -1;
8010979a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010979d:	0f b6 40 05          	movzbl 0x5(%eax),%eax
801097a1:	3c 04                	cmp    $0x4,%al
801097a3:	74 0a                	je     801097af <arp_proc+0x67>
801097a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097aa:	e9 0e 01 00 00       	jmp    801098bd <arp_proc+0x175>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
801097af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b2:	83 c0 18             	add    $0x18,%eax
801097b5:	83 ec 04             	sub    $0x4,%esp
801097b8:	6a 04                	push   $0x4
801097ba:	50                   	push   %eax
801097bb:	68 04 f5 10 80       	push   $0x8010f504
801097c0:	e8 b9 bb ff ff       	call   8010537e <memcmp>
801097c5:	83 c4 10             	add    $0x10,%esp
801097c8:	85 c0                	test   %eax,%eax
801097ca:	74 27                	je     801097f3 <arp_proc+0xab>
801097cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097cf:	83 c0 0e             	add    $0xe,%eax
801097d2:	83 ec 04             	sub    $0x4,%esp
801097d5:	6a 04                	push   $0x4
801097d7:	50                   	push   %eax
801097d8:	68 04 f5 10 80       	push   $0x8010f504
801097dd:	e8 9c bb ff ff       	call   8010537e <memcmp>
801097e2:	83 c4 10             	add    $0x10,%esp
801097e5:	85 c0                	test   %eax,%eax
801097e7:	74 0a                	je     801097f3 <arp_proc+0xab>
801097e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801097ee:	e9 ca 00 00 00       	jmp    801098bd <arp_proc+0x175>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801097f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801097fa:	66 3d 00 01          	cmp    $0x100,%ax
801097fe:	75 69                	jne    80109869 <arp_proc+0x121>
80109800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109803:	83 c0 18             	add    $0x18,%eax
80109806:	83 ec 04             	sub    $0x4,%esp
80109809:	6a 04                	push   $0x4
8010980b:	50                   	push   %eax
8010980c:	68 04 f5 10 80       	push   $0x8010f504
80109811:	e8 68 bb ff ff       	call   8010537e <memcmp>
80109816:	83 c4 10             	add    $0x10,%esp
80109819:	85 c0                	test   %eax,%eax
8010981b:	75 4c                	jne    80109869 <arp_proc+0x121>
    uint send = (uint)kalloc();
8010981d:	e8 68 95 ff ff       	call   80102d8a <kalloc>
80109822:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80109825:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
8010982c:	83 ec 04             	sub    $0x4,%esp
8010982f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109832:	50                   	push   %eax
80109833:	ff 75 f0             	pushl  -0x10(%ebp)
80109836:	ff 75 f4             	pushl  -0xc(%ebp)
80109839:	e8 33 04 00 00       	call   80109c71 <arp_reply_pkt_create>
8010983e:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80109841:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109844:	83 ec 08             	sub    $0x8,%esp
80109847:	50                   	push   %eax
80109848:	ff 75 f0             	pushl  -0x10(%ebp)
8010984b:	e8 c2 fd ff ff       	call   80109612 <i8254_send>
80109850:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80109853:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109856:	83 ec 0c             	sub    $0xc,%esp
80109859:	50                   	push   %eax
8010985a:	e8 8d 94 ff ff       	call   80102cec <kfree>
8010985f:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80109862:	b8 02 00 00 00       	mov    $0x2,%eax
80109867:	eb 54                	jmp    801098bd <arp_proc+0x175>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010986c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109870:	66 3d 00 02          	cmp    $0x200,%ax
80109874:	75 42                	jne    801098b8 <arp_proc+0x170>
80109876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109879:	83 c0 18             	add    $0x18,%eax
8010987c:	83 ec 04             	sub    $0x4,%esp
8010987f:	6a 04                	push   $0x4
80109881:	50                   	push   %eax
80109882:	68 04 f5 10 80       	push   $0x8010f504
80109887:	e8 f2 ba ff ff       	call   8010537e <memcmp>
8010988c:	83 c4 10             	add    $0x10,%esp
8010988f:	85 c0                	test   %eax,%eax
80109891:	75 25                	jne    801098b8 <arp_proc+0x170>
    cprintf("ARP TABLE UPDATED\n");
80109893:	83 ec 0c             	sub    $0xc,%esp
80109896:	68 fc c9 10 80       	push   $0x8010c9fc
8010989b:	e8 6c 6b ff ff       	call   8010040c <cprintf>
801098a0:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
801098a3:	83 ec 0c             	sub    $0xc,%esp
801098a6:	ff 75 f4             	pushl  -0xc(%ebp)
801098a9:	e8 b7 01 00 00       	call   80109a65 <arp_table_update>
801098ae:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
801098b1:	b8 01 00 00 00       	mov    $0x1,%eax
801098b6:	eb 05                	jmp    801098bd <arp_proc+0x175>
  }else{
    return -1;
801098b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801098bd:	c9                   	leave  
801098be:	c3                   	ret    

801098bf <arp_scan>:

void arp_scan(){
801098bf:	f3 0f 1e fb          	endbr32 
801098c3:	55                   	push   %ebp
801098c4:	89 e5                	mov    %esp,%ebp
801098c6:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
801098c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801098d0:	eb 6f                	jmp    80109941 <arp_scan+0x82>
    uint send = (uint)kalloc();
801098d2:	e8 b3 94 ff ff       	call   80102d8a <kalloc>
801098d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
801098da:	83 ec 04             	sub    $0x4,%esp
801098dd:	ff 75 f4             	pushl  -0xc(%ebp)
801098e0:	8d 45 e8             	lea    -0x18(%ebp),%eax
801098e3:	50                   	push   %eax
801098e4:	ff 75 ec             	pushl  -0x14(%ebp)
801098e7:	e8 62 00 00 00       	call   8010994e <arp_broadcast>
801098ec:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801098ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801098f2:	83 ec 08             	sub    $0x8,%esp
801098f5:	50                   	push   %eax
801098f6:	ff 75 ec             	pushl  -0x14(%ebp)
801098f9:	e8 14 fd ff ff       	call   80109612 <i8254_send>
801098fe:	83 c4 10             	add    $0x10,%esp
80109901:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109904:	eb 22                	jmp    80109928 <arp_scan+0x69>
      microdelay(1);
80109906:	83 ec 0c             	sub    $0xc,%esp
80109909:	6a 01                	push   $0x1
8010990b:	e8 2c 98 ff ff       	call   8010313c <microdelay>
80109910:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80109913:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109916:	83 ec 08             	sub    $0x8,%esp
80109919:	50                   	push   %eax
8010991a:	ff 75 ec             	pushl  -0x14(%ebp)
8010991d:	e8 f0 fc ff ff       	call   80109612 <i8254_send>
80109922:	83 c4 10             	add    $0x10,%esp
80109925:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80109928:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010992c:	74 d8                	je     80109906 <arp_scan+0x47>
    }
    kfree((char *)send);
8010992e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109931:	83 ec 0c             	sub    $0xc,%esp
80109934:	50                   	push   %eax
80109935:	e8 b2 93 ff ff       	call   80102cec <kfree>
8010993a:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
8010993d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109941:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80109948:	7e 88                	jle    801098d2 <arp_scan+0x13>
  }
}
8010994a:	90                   	nop
8010994b:	90                   	nop
8010994c:	c9                   	leave  
8010994d:	c3                   	ret    

8010994e <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
8010994e:	f3 0f 1e fb          	endbr32 
80109952:	55                   	push   %ebp
80109953:	89 e5                	mov    %esp,%ebp
80109955:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109958:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010995c:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109960:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109964:	8b 45 10             	mov    0x10(%ebp),%eax
80109967:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010996a:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109971:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109977:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010997e:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109984:	8b 45 0c             	mov    0xc(%ebp),%eax
80109987:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010998d:	8b 45 08             	mov    0x8(%ebp),%eax
80109990:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109993:	8b 45 08             	mov    0x8(%ebp),%eax
80109996:	83 c0 0e             	add    $0xe,%eax
80109999:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010999c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010999f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
801099a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099a6:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
801099aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099ad:	83 ec 04             	sub    $0x4,%esp
801099b0:	6a 06                	push   $0x6
801099b2:	8d 55 e6             	lea    -0x1a(%ebp),%edx
801099b5:	52                   	push   %edx
801099b6:	50                   	push   %eax
801099b7:	e8 1e ba ff ff       	call   801053da <memmove>
801099bc:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
801099bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c2:	83 c0 06             	add    $0x6,%eax
801099c5:	83 ec 04             	sub    $0x4,%esp
801099c8:	6a 06                	push   $0x6
801099ca:	68 ac 00 11 80       	push   $0x801100ac
801099cf:	50                   	push   %eax
801099d0:	e8 05 ba ff ff       	call   801053da <memmove>
801099d5:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
801099d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099db:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
801099e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099e3:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801099e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099ec:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801099f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099f3:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801099f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099fa:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80109a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a03:	8d 50 12             	lea    0x12(%eax),%edx
80109a06:	83 ec 04             	sub    $0x4,%esp
80109a09:	6a 06                	push   $0x6
80109a0b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80109a0e:	50                   	push   %eax
80109a0f:	52                   	push   %edx
80109a10:	e8 c5 b9 ff ff       	call   801053da <memmove>
80109a15:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80109a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a1b:	8d 50 18             	lea    0x18(%eax),%edx
80109a1e:	83 ec 04             	sub    $0x4,%esp
80109a21:	6a 04                	push   $0x4
80109a23:	8d 45 ec             	lea    -0x14(%ebp),%eax
80109a26:	50                   	push   %eax
80109a27:	52                   	push   %edx
80109a28:	e8 ad b9 ff ff       	call   801053da <memmove>
80109a2d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a33:	83 c0 08             	add    $0x8,%eax
80109a36:	83 ec 04             	sub    $0x4,%esp
80109a39:	6a 06                	push   $0x6
80109a3b:	68 ac 00 11 80       	push   $0x801100ac
80109a40:	50                   	push   %eax
80109a41:	e8 94 b9 ff ff       	call   801053da <memmove>
80109a46:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109a49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a4c:	83 c0 0e             	add    $0xe,%eax
80109a4f:	83 ec 04             	sub    $0x4,%esp
80109a52:	6a 04                	push   $0x4
80109a54:	68 04 f5 10 80       	push   $0x8010f504
80109a59:	50                   	push   %eax
80109a5a:	e8 7b b9 ff ff       	call   801053da <memmove>
80109a5f:	83 c4 10             	add    $0x10,%esp
}
80109a62:	90                   	nop
80109a63:	c9                   	leave  
80109a64:	c3                   	ret    

80109a65 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109a65:	f3 0f 1e fb          	endbr32 
80109a69:	55                   	push   %ebp
80109a6a:	89 e5                	mov    %esp,%ebp
80109a6c:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80109a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80109a72:	83 c0 0e             	add    $0xe,%eax
80109a75:	83 ec 0c             	sub    $0xc,%esp
80109a78:	50                   	push   %eax
80109a79:	e8 bc 00 00 00       	call   80109b3a <arp_table_search>
80109a7e:	83 c4 10             	add    $0x10,%esp
80109a81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109a84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109a88:	78 2d                	js     80109ab7 <arp_table_update+0x52>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109a8a:	8b 45 08             	mov    0x8(%ebp),%eax
80109a8d:	8d 48 08             	lea    0x8(%eax),%ecx
80109a90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109a93:	89 d0                	mov    %edx,%eax
80109a95:	c1 e0 02             	shl    $0x2,%eax
80109a98:	01 d0                	add    %edx,%eax
80109a9a:	01 c0                	add    %eax,%eax
80109a9c:	01 d0                	add    %edx,%eax
80109a9e:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109aa3:	83 c0 04             	add    $0x4,%eax
80109aa6:	83 ec 04             	sub    $0x4,%esp
80109aa9:	6a 06                	push   $0x6
80109aab:	51                   	push   %ecx
80109aac:	50                   	push   %eax
80109aad:	e8 28 b9 ff ff       	call   801053da <memmove>
80109ab2:	83 c4 10             	add    $0x10,%esp
80109ab5:	eb 70                	jmp    80109b27 <arp_table_update+0xc2>
  }else{
    index += 1;
80109ab7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109abb:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109abe:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac1:	8d 48 08             	lea    0x8(%eax),%ecx
80109ac4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ac7:	89 d0                	mov    %edx,%eax
80109ac9:	c1 e0 02             	shl    $0x2,%eax
80109acc:	01 d0                	add    %edx,%eax
80109ace:	01 c0                	add    %eax,%eax
80109ad0:	01 d0                	add    %edx,%eax
80109ad2:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109ad7:	83 c0 04             	add    $0x4,%eax
80109ada:	83 ec 04             	sub    $0x4,%esp
80109add:	6a 06                	push   $0x6
80109adf:	51                   	push   %ecx
80109ae0:	50                   	push   %eax
80109ae1:	e8 f4 b8 ff ff       	call   801053da <memmove>
80109ae6:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80109aec:	8d 48 0e             	lea    0xe(%eax),%ecx
80109aef:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109af2:	89 d0                	mov    %edx,%eax
80109af4:	c1 e0 02             	shl    $0x2,%eax
80109af7:	01 d0                	add    %edx,%eax
80109af9:	01 c0                	add    %eax,%eax
80109afb:	01 d0                	add    %edx,%eax
80109afd:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109b02:	83 ec 04             	sub    $0x4,%esp
80109b05:	6a 04                	push   $0x4
80109b07:	51                   	push   %ecx
80109b08:	50                   	push   %eax
80109b09:	e8 cc b8 ff ff       	call   801053da <memmove>
80109b0e:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80109b11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109b14:	89 d0                	mov    %edx,%eax
80109b16:	c1 e0 02             	shl    $0x2,%eax
80109b19:	01 d0                	add    %edx,%eax
80109b1b:	01 c0                	add    %eax,%eax
80109b1d:	01 d0                	add    %edx,%eax
80109b1f:	05 ca 00 11 80       	add    $0x801100ca,%eax
80109b24:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80109b27:	83 ec 0c             	sub    $0xc,%esp
80109b2a:	68 c0 00 11 80       	push   $0x801100c0
80109b2f:	e8 87 00 00 00       	call   80109bbb <print_arp_table>
80109b34:	83 c4 10             	add    $0x10,%esp
}
80109b37:	90                   	nop
80109b38:	c9                   	leave  
80109b39:	c3                   	ret    

80109b3a <arp_table_search>:

int arp_table_search(uchar *ip){
80109b3a:	f3 0f 1e fb          	endbr32 
80109b3e:	55                   	push   %ebp
80109b3f:	89 e5                	mov    %esp,%ebp
80109b41:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80109b44:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109b4b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109b52:	eb 59                	jmp    80109bad <arp_table_search+0x73>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80109b54:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109b57:	89 d0                	mov    %edx,%eax
80109b59:	c1 e0 02             	shl    $0x2,%eax
80109b5c:	01 d0                	add    %edx,%eax
80109b5e:	01 c0                	add    %eax,%eax
80109b60:	01 d0                	add    %edx,%eax
80109b62:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109b67:	83 ec 04             	sub    $0x4,%esp
80109b6a:	6a 04                	push   $0x4
80109b6c:	ff 75 08             	pushl  0x8(%ebp)
80109b6f:	50                   	push   %eax
80109b70:	e8 09 b8 ff ff       	call   8010537e <memcmp>
80109b75:	83 c4 10             	add    $0x10,%esp
80109b78:	85 c0                	test   %eax,%eax
80109b7a:	75 05                	jne    80109b81 <arp_table_search+0x47>
      return i;
80109b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b7f:	eb 38                	jmp    80109bb9 <arp_table_search+0x7f>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109b81:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109b84:	89 d0                	mov    %edx,%eax
80109b86:	c1 e0 02             	shl    $0x2,%eax
80109b89:	01 d0                	add    %edx,%eax
80109b8b:	01 c0                	add    %eax,%eax
80109b8d:	01 d0                	add    %edx,%eax
80109b8f:	05 ca 00 11 80       	add    $0x801100ca,%eax
80109b94:	0f b6 00             	movzbl (%eax),%eax
80109b97:	84 c0                	test   %al,%al
80109b99:	75 0e                	jne    80109ba9 <arp_table_search+0x6f>
80109b9b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109b9f:	75 08                	jne    80109ba9 <arp_table_search+0x6f>
      empty = -i;
80109ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ba4:	f7 d8                	neg    %eax
80109ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109ba9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109bad:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109bb1:	7e a1                	jle    80109b54 <arp_table_search+0x1a>
    }
  }
  return empty-1;
80109bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bb6:	83 e8 01             	sub    $0x1,%eax
}
80109bb9:	c9                   	leave  
80109bba:	c3                   	ret    

80109bbb <print_arp_table>:

void print_arp_table(){
80109bbb:	f3 0f 1e fb          	endbr32 
80109bbf:	55                   	push   %ebp
80109bc0:	89 e5                	mov    %esp,%ebp
80109bc2:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109bc5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109bcc:	e9 92 00 00 00       	jmp    80109c63 <print_arp_table+0xa8>
    if(arp_table[i].use != 0){
80109bd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109bd4:	89 d0                	mov    %edx,%eax
80109bd6:	c1 e0 02             	shl    $0x2,%eax
80109bd9:	01 d0                	add    %edx,%eax
80109bdb:	01 c0                	add    %eax,%eax
80109bdd:	01 d0                	add    %edx,%eax
80109bdf:	05 ca 00 11 80       	add    $0x801100ca,%eax
80109be4:	0f b6 00             	movzbl (%eax),%eax
80109be7:	84 c0                	test   %al,%al
80109be9:	74 74                	je     80109c5f <print_arp_table+0xa4>
      cprintf("Entry Num: %d ",i);
80109beb:	83 ec 08             	sub    $0x8,%esp
80109bee:	ff 75 f4             	pushl  -0xc(%ebp)
80109bf1:	68 0f ca 10 80       	push   $0x8010ca0f
80109bf6:	e8 11 68 ff ff       	call   8010040c <cprintf>
80109bfb:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109bfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c01:	89 d0                	mov    %edx,%eax
80109c03:	c1 e0 02             	shl    $0x2,%eax
80109c06:	01 d0                	add    %edx,%eax
80109c08:	01 c0                	add    %eax,%eax
80109c0a:	01 d0                	add    %edx,%eax
80109c0c:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109c11:	83 ec 0c             	sub    $0xc,%esp
80109c14:	50                   	push   %eax
80109c15:	e8 5c 02 00 00       	call   80109e76 <print_ipv4>
80109c1a:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
80109c1d:	83 ec 0c             	sub    $0xc,%esp
80109c20:	68 1e ca 10 80       	push   $0x8010ca1e
80109c25:	e8 e2 67 ff ff       	call   8010040c <cprintf>
80109c2a:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
80109c2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109c30:	89 d0                	mov    %edx,%eax
80109c32:	c1 e0 02             	shl    $0x2,%eax
80109c35:	01 d0                	add    %edx,%eax
80109c37:	01 c0                	add    %eax,%eax
80109c39:	01 d0                	add    %edx,%eax
80109c3b:	05 c0 00 11 80       	add    $0x801100c0,%eax
80109c40:	83 c0 04             	add    $0x4,%eax
80109c43:	83 ec 0c             	sub    $0xc,%esp
80109c46:	50                   	push   %eax
80109c47:	e8 7c 02 00 00       	call   80109ec8 <print_mac>
80109c4c:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109c4f:	83 ec 0c             	sub    $0xc,%esp
80109c52:	68 20 ca 10 80       	push   $0x8010ca20
80109c57:	e8 b0 67 ff ff       	call   8010040c <cprintf>
80109c5c:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109c5f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109c63:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109c67:	0f 8e 64 ff ff ff    	jle    80109bd1 <print_arp_table+0x16>
    }
  }
}
80109c6d:	90                   	nop
80109c6e:	90                   	nop
80109c6f:	c9                   	leave  
80109c70:	c3                   	ret    

80109c71 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109c71:	f3 0f 1e fb          	endbr32 
80109c75:	55                   	push   %ebp
80109c76:	89 e5                	mov    %esp,%ebp
80109c78:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109c7b:	8b 45 10             	mov    0x10(%ebp),%eax
80109c7e:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109c84:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c8d:	83 c0 0e             	add    $0xe,%eax
80109c90:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c96:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c9d:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ca4:	8d 50 08             	lea    0x8(%eax),%edx
80109ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109caa:	83 ec 04             	sub    $0x4,%esp
80109cad:	6a 06                	push   $0x6
80109caf:	52                   	push   %edx
80109cb0:	50                   	push   %eax
80109cb1:	e8 24 b7 ff ff       	call   801053da <memmove>
80109cb6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cbc:	83 c0 06             	add    $0x6,%eax
80109cbf:	83 ec 04             	sub    $0x4,%esp
80109cc2:	6a 06                	push   $0x6
80109cc4:	68 ac 00 11 80       	push   $0x801100ac
80109cc9:	50                   	push   %eax
80109cca:	e8 0b b7 ff ff       	call   801053da <memmove>
80109ccf:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cd5:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cdd:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ce6:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ced:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109cf4:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80109cfd:	8d 50 08             	lea    0x8(%eax),%edx
80109d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d03:	83 c0 12             	add    $0x12,%eax
80109d06:	83 ec 04             	sub    $0x4,%esp
80109d09:	6a 06                	push   $0x6
80109d0b:	52                   	push   %edx
80109d0c:	50                   	push   %eax
80109d0d:	e8 c8 b6 ff ff       	call   801053da <memmove>
80109d12:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109d15:	8b 45 08             	mov    0x8(%ebp),%eax
80109d18:	8d 50 0e             	lea    0xe(%eax),%edx
80109d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d1e:	83 c0 18             	add    $0x18,%eax
80109d21:	83 ec 04             	sub    $0x4,%esp
80109d24:	6a 04                	push   $0x4
80109d26:	52                   	push   %edx
80109d27:	50                   	push   %eax
80109d28:	e8 ad b6 ff ff       	call   801053da <memmove>
80109d2d:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80109d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d33:	83 c0 08             	add    $0x8,%eax
80109d36:	83 ec 04             	sub    $0x4,%esp
80109d39:	6a 06                	push   $0x6
80109d3b:	68 ac 00 11 80       	push   $0x801100ac
80109d40:	50                   	push   %eax
80109d41:	e8 94 b6 ff ff       	call   801053da <memmove>
80109d46:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d4c:	83 c0 0e             	add    $0xe,%eax
80109d4f:	83 ec 04             	sub    $0x4,%esp
80109d52:	6a 04                	push   $0x4
80109d54:	68 04 f5 10 80       	push   $0x8010f504
80109d59:	50                   	push   %eax
80109d5a:	e8 7b b6 ff ff       	call   801053da <memmove>
80109d5f:	83 c4 10             	add    $0x10,%esp
}
80109d62:	90                   	nop
80109d63:	c9                   	leave  
80109d64:	c3                   	ret    

80109d65 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109d65:	f3 0f 1e fb          	endbr32 
80109d69:	55                   	push   %ebp
80109d6a:	89 e5                	mov    %esp,%ebp
80109d6c:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109d6f:	83 ec 0c             	sub    $0xc,%esp
80109d72:	68 22 ca 10 80       	push   $0x8010ca22
80109d77:	e8 90 66 ff ff       	call   8010040c <cprintf>
80109d7c:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80109d82:	83 c0 0e             	add    $0xe,%eax
80109d85:	83 ec 0c             	sub    $0xc,%esp
80109d88:	50                   	push   %eax
80109d89:	e8 e8 00 00 00       	call   80109e76 <print_ipv4>
80109d8e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109d91:	83 ec 0c             	sub    $0xc,%esp
80109d94:	68 20 ca 10 80       	push   $0x8010ca20
80109d99:	e8 6e 66 ff ff       	call   8010040c <cprintf>
80109d9e:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
80109da1:	8b 45 08             	mov    0x8(%ebp),%eax
80109da4:	83 c0 08             	add    $0x8,%eax
80109da7:	83 ec 0c             	sub    $0xc,%esp
80109daa:	50                   	push   %eax
80109dab:	e8 18 01 00 00       	call   80109ec8 <print_mac>
80109db0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109db3:	83 ec 0c             	sub    $0xc,%esp
80109db6:	68 20 ca 10 80       	push   $0x8010ca20
80109dbb:	e8 4c 66 ff ff       	call   8010040c <cprintf>
80109dc0:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109dc3:	83 ec 0c             	sub    $0xc,%esp
80109dc6:	68 39 ca 10 80       	push   $0x8010ca39
80109dcb:	e8 3c 66 ff ff       	call   8010040c <cprintf>
80109dd0:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80109dd6:	83 c0 18             	add    $0x18,%eax
80109dd9:	83 ec 0c             	sub    $0xc,%esp
80109ddc:	50                   	push   %eax
80109ddd:	e8 94 00 00 00       	call   80109e76 <print_ipv4>
80109de2:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109de5:	83 ec 0c             	sub    $0xc,%esp
80109de8:	68 20 ca 10 80       	push   $0x8010ca20
80109ded:	e8 1a 66 ff ff       	call   8010040c <cprintf>
80109df2:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109df5:	8b 45 08             	mov    0x8(%ebp),%eax
80109df8:	83 c0 12             	add    $0x12,%eax
80109dfb:	83 ec 0c             	sub    $0xc,%esp
80109dfe:	50                   	push   %eax
80109dff:	e8 c4 00 00 00       	call   80109ec8 <print_mac>
80109e04:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109e07:	83 ec 0c             	sub    $0xc,%esp
80109e0a:	68 20 ca 10 80       	push   $0x8010ca20
80109e0f:	e8 f8 65 ff ff       	call   8010040c <cprintf>
80109e14:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109e17:	83 ec 0c             	sub    $0xc,%esp
80109e1a:	68 50 ca 10 80       	push   $0x8010ca50
80109e1f:	e8 e8 65 ff ff       	call   8010040c <cprintf>
80109e24:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
80109e27:	8b 45 08             	mov    0x8(%ebp),%eax
80109e2a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109e2e:	66 3d 00 01          	cmp    $0x100,%ax
80109e32:	75 12                	jne    80109e46 <print_arp_info+0xe1>
80109e34:	83 ec 0c             	sub    $0xc,%esp
80109e37:	68 5c ca 10 80       	push   $0x8010ca5c
80109e3c:	e8 cb 65 ff ff       	call   8010040c <cprintf>
80109e41:	83 c4 10             	add    $0x10,%esp
80109e44:	eb 1d                	jmp    80109e63 <print_arp_info+0xfe>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109e46:	8b 45 08             	mov    0x8(%ebp),%eax
80109e49:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109e4d:	66 3d 00 02          	cmp    $0x200,%ax
80109e51:	75 10                	jne    80109e63 <print_arp_info+0xfe>
    cprintf("Reply\n");
80109e53:	83 ec 0c             	sub    $0xc,%esp
80109e56:	68 65 ca 10 80       	push   $0x8010ca65
80109e5b:	e8 ac 65 ff ff       	call   8010040c <cprintf>
80109e60:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
80109e63:	83 ec 0c             	sub    $0xc,%esp
80109e66:	68 20 ca 10 80       	push   $0x8010ca20
80109e6b:	e8 9c 65 ff ff       	call   8010040c <cprintf>
80109e70:	83 c4 10             	add    $0x10,%esp
}
80109e73:	90                   	nop
80109e74:	c9                   	leave  
80109e75:	c3                   	ret    

80109e76 <print_ipv4>:

void print_ipv4(uchar *ip){
80109e76:	f3 0f 1e fb          	endbr32 
80109e7a:	55                   	push   %ebp
80109e7b:	89 e5                	mov    %esp,%ebp
80109e7d:	53                   	push   %ebx
80109e7e:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109e81:	8b 45 08             	mov    0x8(%ebp),%eax
80109e84:	83 c0 03             	add    $0x3,%eax
80109e87:	0f b6 00             	movzbl (%eax),%eax
80109e8a:	0f b6 d8             	movzbl %al,%ebx
80109e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80109e90:	83 c0 02             	add    $0x2,%eax
80109e93:	0f b6 00             	movzbl (%eax),%eax
80109e96:	0f b6 c8             	movzbl %al,%ecx
80109e99:	8b 45 08             	mov    0x8(%ebp),%eax
80109e9c:	83 c0 01             	add    $0x1,%eax
80109e9f:	0f b6 00             	movzbl (%eax),%eax
80109ea2:	0f b6 d0             	movzbl %al,%edx
80109ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ea8:	0f b6 00             	movzbl (%eax),%eax
80109eab:	0f b6 c0             	movzbl %al,%eax
80109eae:	83 ec 0c             	sub    $0xc,%esp
80109eb1:	53                   	push   %ebx
80109eb2:	51                   	push   %ecx
80109eb3:	52                   	push   %edx
80109eb4:	50                   	push   %eax
80109eb5:	68 6c ca 10 80       	push   $0x8010ca6c
80109eba:	e8 4d 65 ff ff       	call   8010040c <cprintf>
80109ebf:	83 c4 20             	add    $0x20,%esp
}
80109ec2:	90                   	nop
80109ec3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109ec6:	c9                   	leave  
80109ec7:	c3                   	ret    

80109ec8 <print_mac>:

void print_mac(uchar *mac){
80109ec8:	f3 0f 1e fb          	endbr32 
80109ecc:	55                   	push   %ebp
80109ecd:	89 e5                	mov    %esp,%ebp
80109ecf:	57                   	push   %edi
80109ed0:	56                   	push   %esi
80109ed1:	53                   	push   %ebx
80109ed2:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ed8:	83 c0 05             	add    $0x5,%eax
80109edb:	0f b6 00             	movzbl (%eax),%eax
80109ede:	0f b6 f8             	movzbl %al,%edi
80109ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80109ee4:	83 c0 04             	add    $0x4,%eax
80109ee7:	0f b6 00             	movzbl (%eax),%eax
80109eea:	0f b6 f0             	movzbl %al,%esi
80109eed:	8b 45 08             	mov    0x8(%ebp),%eax
80109ef0:	83 c0 03             	add    $0x3,%eax
80109ef3:	0f b6 00             	movzbl (%eax),%eax
80109ef6:	0f b6 d8             	movzbl %al,%ebx
80109ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80109efc:	83 c0 02             	add    $0x2,%eax
80109eff:	0f b6 00             	movzbl (%eax),%eax
80109f02:	0f b6 c8             	movzbl %al,%ecx
80109f05:	8b 45 08             	mov    0x8(%ebp),%eax
80109f08:	83 c0 01             	add    $0x1,%eax
80109f0b:	0f b6 00             	movzbl (%eax),%eax
80109f0e:	0f b6 d0             	movzbl %al,%edx
80109f11:	8b 45 08             	mov    0x8(%ebp),%eax
80109f14:	0f b6 00             	movzbl (%eax),%eax
80109f17:	0f b6 c0             	movzbl %al,%eax
80109f1a:	83 ec 04             	sub    $0x4,%esp
80109f1d:	57                   	push   %edi
80109f1e:	56                   	push   %esi
80109f1f:	53                   	push   %ebx
80109f20:	51                   	push   %ecx
80109f21:	52                   	push   %edx
80109f22:	50                   	push   %eax
80109f23:	68 84 ca 10 80       	push   $0x8010ca84
80109f28:	e8 df 64 ff ff       	call   8010040c <cprintf>
80109f2d:	83 c4 20             	add    $0x20,%esp
}
80109f30:	90                   	nop
80109f31:	8d 65 f4             	lea    -0xc(%ebp),%esp
80109f34:	5b                   	pop    %ebx
80109f35:	5e                   	pop    %esi
80109f36:	5f                   	pop    %edi
80109f37:	5d                   	pop    %ebp
80109f38:	c3                   	ret    

80109f39 <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
80109f39:	f3 0f 1e fb          	endbr32 
80109f3d:	55                   	push   %ebp
80109f3e:	89 e5                	mov    %esp,%ebp
80109f40:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
80109f43:	8b 45 08             	mov    0x8(%ebp),%eax
80109f46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
80109f49:	8b 45 08             	mov    0x8(%ebp),%eax
80109f4c:	83 c0 0e             	add    $0xe,%eax
80109f4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f55:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109f59:	3c 08                	cmp    $0x8,%al
80109f5b:	75 1b                	jne    80109f78 <eth_proc+0x3f>
80109f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f60:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f64:	3c 06                	cmp    $0x6,%al
80109f66:	75 10                	jne    80109f78 <eth_proc+0x3f>
    arp_proc(pkt_addr);
80109f68:	83 ec 0c             	sub    $0xc,%esp
80109f6b:	ff 75 f0             	pushl  -0x10(%ebp)
80109f6e:	e8 d5 f7 ff ff       	call   80109748 <arp_proc>
80109f73:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109f76:	eb 24                	jmp    80109f9c <eth_proc+0x63>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f7b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109f7f:	3c 08                	cmp    $0x8,%al
80109f81:	75 19                	jne    80109f9c <eth_proc+0x63>
80109f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f86:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f8a:	84 c0                	test   %al,%al
80109f8c:	75 0e                	jne    80109f9c <eth_proc+0x63>
    ipv4_proc(buffer_addr);
80109f8e:	83 ec 0c             	sub    $0xc,%esp
80109f91:	ff 75 08             	pushl  0x8(%ebp)
80109f94:	e8 b3 00 00 00       	call   8010a04c <ipv4_proc>
80109f99:	83 c4 10             	add    $0x10,%esp
}
80109f9c:	90                   	nop
80109f9d:	c9                   	leave  
80109f9e:	c3                   	ret    

80109f9f <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109f9f:	f3 0f 1e fb          	endbr32 
80109fa3:	55                   	push   %ebp
80109fa4:	89 e5                	mov    %esp,%ebp
80109fa6:	83 ec 04             	sub    $0x4,%esp
80109fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80109fac:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109fb0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109fb4:	c1 e0 08             	shl    $0x8,%eax
80109fb7:	89 c2                	mov    %eax,%edx
80109fb9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109fbd:	66 c1 e8 08          	shr    $0x8,%ax
80109fc1:	01 d0                	add    %edx,%eax
}
80109fc3:	c9                   	leave  
80109fc4:	c3                   	ret    

80109fc5 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109fc5:	f3 0f 1e fb          	endbr32 
80109fc9:	55                   	push   %ebp
80109fca:	89 e5                	mov    %esp,%ebp
80109fcc:	83 ec 04             	sub    $0x4,%esp
80109fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109fd6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109fda:	c1 e0 08             	shl    $0x8,%eax
80109fdd:	89 c2                	mov    %eax,%edx
80109fdf:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109fe3:	66 c1 e8 08          	shr    $0x8,%ax
80109fe7:	01 d0                	add    %edx,%eax
}
80109fe9:	c9                   	leave  
80109fea:	c3                   	ret    

80109feb <H2N_uint>:

uint H2N_uint(uint value){
80109feb:	f3 0f 1e fb          	endbr32 
80109fef:	55                   	push   %ebp
80109ff0:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109ff2:	8b 45 08             	mov    0x8(%ebp),%eax
80109ff5:	c1 e0 18             	shl    $0x18,%eax
80109ff8:	25 00 00 00 0f       	and    $0xf000000,%eax
80109ffd:	89 c2                	mov    %eax,%edx
80109fff:	8b 45 08             	mov    0x8(%ebp),%eax
8010a002:	c1 e0 08             	shl    $0x8,%eax
8010a005:	25 00 f0 00 00       	and    $0xf000,%eax
8010a00a:	09 c2                	or     %eax,%edx
8010a00c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a00f:	c1 e8 08             	shr    $0x8,%eax
8010a012:	83 e0 0f             	and    $0xf,%eax
8010a015:	01 d0                	add    %edx,%eax
}
8010a017:	5d                   	pop    %ebp
8010a018:	c3                   	ret    

8010a019 <N2H_uint>:

uint N2H_uint(uint value){
8010a019:	f3 0f 1e fb          	endbr32 
8010a01d:	55                   	push   %ebp
8010a01e:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010a020:	8b 45 08             	mov    0x8(%ebp),%eax
8010a023:	c1 e0 18             	shl    $0x18,%eax
8010a026:	89 c2                	mov    %eax,%edx
8010a028:	8b 45 08             	mov    0x8(%ebp),%eax
8010a02b:	c1 e0 08             	shl    $0x8,%eax
8010a02e:	25 00 00 ff 00       	and    $0xff0000,%eax
8010a033:	01 c2                	add    %eax,%edx
8010a035:	8b 45 08             	mov    0x8(%ebp),%eax
8010a038:	c1 e8 08             	shr    $0x8,%eax
8010a03b:	25 00 ff 00 00       	and    $0xff00,%eax
8010a040:	01 c2                	add    %eax,%edx
8010a042:	8b 45 08             	mov    0x8(%ebp),%eax
8010a045:	c1 e8 18             	shr    $0x18,%eax
8010a048:	01 d0                	add    %edx,%eax
}
8010a04a:	5d                   	pop    %ebp
8010a04b:	c3                   	ret    

8010a04c <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
8010a04c:	f3 0f 1e fb          	endbr32 
8010a050:	55                   	push   %ebp
8010a051:	89 e5                	mov    %esp,%ebp
8010a053:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010a056:	8b 45 08             	mov    0x8(%ebp),%eax
8010a059:	83 c0 0e             	add    $0xe,%eax
8010a05c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
8010a05f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a062:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a066:	0f b7 d0             	movzwl %ax,%edx
8010a069:	a1 08 f5 10 80       	mov    0x8010f508,%eax
8010a06e:	39 c2                	cmp    %eax,%edx
8010a070:	74 60                	je     8010a0d2 <ipv4_proc+0x86>
8010a072:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a075:	83 c0 0c             	add    $0xc,%eax
8010a078:	83 ec 04             	sub    $0x4,%esp
8010a07b:	6a 04                	push   $0x4
8010a07d:	50                   	push   %eax
8010a07e:	68 04 f5 10 80       	push   $0x8010f504
8010a083:	e8 f6 b2 ff ff       	call   8010537e <memcmp>
8010a088:	83 c4 10             	add    $0x10,%esp
8010a08b:	85 c0                	test   %eax,%eax
8010a08d:	74 43                	je     8010a0d2 <ipv4_proc+0x86>
    ip_id = ipv4_p->id;
8010a08f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a092:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a096:	0f b7 c0             	movzwl %ax,%eax
8010a099:	a3 08 f5 10 80       	mov    %eax,0x8010f508
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
8010a09e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0a1:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a0a5:	3c 01                	cmp    $0x1,%al
8010a0a7:	75 10                	jne    8010a0b9 <ipv4_proc+0x6d>
        icmp_proc(buffer_addr);
8010a0a9:	83 ec 0c             	sub    $0xc,%esp
8010a0ac:	ff 75 08             	pushl  0x8(%ebp)
8010a0af:	e8 a7 00 00 00       	call   8010a15b <icmp_proc>
8010a0b4:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010a0b7:	eb 19                	jmp    8010a0d2 <ipv4_proc+0x86>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010a0b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0bc:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010a0c0:	3c 06                	cmp    $0x6,%al
8010a0c2:	75 0e                	jne    8010a0d2 <ipv4_proc+0x86>
        tcp_proc(buffer_addr);
8010a0c4:	83 ec 0c             	sub    $0xc,%esp
8010a0c7:	ff 75 08             	pushl  0x8(%ebp)
8010a0ca:	e8 c7 03 00 00       	call   8010a496 <tcp_proc>
8010a0cf:	83 c4 10             	add    $0x10,%esp
}
8010a0d2:	90                   	nop
8010a0d3:	c9                   	leave  
8010a0d4:	c3                   	ret    

8010a0d5 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010a0d5:	f3 0f 1e fb          	endbr32 
8010a0d9:	55                   	push   %ebp
8010a0da:	89 e5                	mov    %esp,%ebp
8010a0dc:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010a0df:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
8010a0e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0e8:	0f b6 00             	movzbl (%eax),%eax
8010a0eb:	83 e0 0f             	and    $0xf,%eax
8010a0ee:	01 c0                	add    %eax,%eax
8010a0f0:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
8010a0f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a0fa:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a101:	eb 48                	jmp    8010a14b <ipv4_chksum+0x76>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a103:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a106:	01 c0                	add    %eax,%eax
8010a108:	89 c2                	mov    %eax,%edx
8010a10a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a10d:	01 d0                	add    %edx,%eax
8010a10f:	0f b6 00             	movzbl (%eax),%eax
8010a112:	0f b6 c0             	movzbl %al,%eax
8010a115:	c1 e0 08             	shl    $0x8,%eax
8010a118:	89 c2                	mov    %eax,%edx
8010a11a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a11d:	01 c0                	add    %eax,%eax
8010a11f:	8d 48 01             	lea    0x1(%eax),%ecx
8010a122:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a125:	01 c8                	add    %ecx,%eax
8010a127:	0f b6 00             	movzbl (%eax),%eax
8010a12a:	0f b6 c0             	movzbl %al,%eax
8010a12d:	01 d0                	add    %edx,%eax
8010a12f:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a132:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a139:	76 0c                	jbe    8010a147 <ipv4_chksum+0x72>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a13b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a13e:	0f b7 c0             	movzwl %ax,%eax
8010a141:	83 c0 01             	add    $0x1,%eax
8010a144:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010a147:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a14b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010a14f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010a152:	7c af                	jl     8010a103 <ipv4_chksum+0x2e>
    }
  }
  return ~(chk_sum);
8010a154:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a157:	f7 d0                	not    %eax
}
8010a159:	c9                   	leave  
8010a15a:	c3                   	ret    

8010a15b <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010a15b:	f3 0f 1e fb          	endbr32 
8010a15f:	55                   	push   %ebp
8010a160:	89 e5                	mov    %esp,%ebp
8010a162:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
8010a165:	8b 45 08             	mov    0x8(%ebp),%eax
8010a168:	83 c0 0e             	add    $0xe,%eax
8010a16b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a16e:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a171:	0f b6 00             	movzbl (%eax),%eax
8010a174:	0f b6 c0             	movzbl %al,%eax
8010a177:	83 e0 0f             	and    $0xf,%eax
8010a17a:	c1 e0 02             	shl    $0x2,%eax
8010a17d:	89 c2                	mov    %eax,%edx
8010a17f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a182:	01 d0                	add    %edx,%eax
8010a184:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
8010a187:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a18a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010a18e:	84 c0                	test   %al,%al
8010a190:	75 4f                	jne    8010a1e1 <icmp_proc+0x86>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010a192:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a195:	0f b6 00             	movzbl (%eax),%eax
8010a198:	3c 08                	cmp    $0x8,%al
8010a19a:	75 45                	jne    8010a1e1 <icmp_proc+0x86>
      uint send_addr = (uint)kalloc();
8010a19c:	e8 e9 8b ff ff       	call   80102d8a <kalloc>
8010a1a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
8010a1a4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
8010a1ab:	83 ec 04             	sub    $0x4,%esp
8010a1ae:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010a1b1:	50                   	push   %eax
8010a1b2:	ff 75 ec             	pushl  -0x14(%ebp)
8010a1b5:	ff 75 08             	pushl  0x8(%ebp)
8010a1b8:	e8 7c 00 00 00       	call   8010a239 <icmp_reply_pkt_create>
8010a1bd:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010a1c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a1c3:	83 ec 08             	sub    $0x8,%esp
8010a1c6:	50                   	push   %eax
8010a1c7:	ff 75 ec             	pushl  -0x14(%ebp)
8010a1ca:	e8 43 f4 ff ff       	call   80109612 <i8254_send>
8010a1cf:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010a1d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1d5:	83 ec 0c             	sub    $0xc,%esp
8010a1d8:	50                   	push   %eax
8010a1d9:	e8 0e 8b ff ff       	call   80102cec <kfree>
8010a1de:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010a1e1:	90                   	nop
8010a1e2:	c9                   	leave  
8010a1e3:	c3                   	ret    

8010a1e4 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
8010a1e4:	f3 0f 1e fb          	endbr32 
8010a1e8:	55                   	push   %ebp
8010a1e9:	89 e5                	mov    %esp,%ebp
8010a1eb:	53                   	push   %ebx
8010a1ec:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010a1ef:	8b 45 08             	mov    0x8(%ebp),%eax
8010a1f2:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010a1f6:	0f b7 c0             	movzwl %ax,%eax
8010a1f9:	83 ec 0c             	sub    $0xc,%esp
8010a1fc:	50                   	push   %eax
8010a1fd:	e8 9d fd ff ff       	call   80109f9f <N2H_ushort>
8010a202:	83 c4 10             	add    $0x10,%esp
8010a205:	0f b7 d8             	movzwl %ax,%ebx
8010a208:	8b 45 08             	mov    0x8(%ebp),%eax
8010a20b:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010a20f:	0f b7 c0             	movzwl %ax,%eax
8010a212:	83 ec 0c             	sub    $0xc,%esp
8010a215:	50                   	push   %eax
8010a216:	e8 84 fd ff ff       	call   80109f9f <N2H_ushort>
8010a21b:	83 c4 10             	add    $0x10,%esp
8010a21e:	0f b7 c0             	movzwl %ax,%eax
8010a221:	83 ec 04             	sub    $0x4,%esp
8010a224:	53                   	push   %ebx
8010a225:	50                   	push   %eax
8010a226:	68 a3 ca 10 80       	push   $0x8010caa3
8010a22b:	e8 dc 61 ff ff       	call   8010040c <cprintf>
8010a230:	83 c4 10             	add    $0x10,%esp
}
8010a233:	90                   	nop
8010a234:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a237:	c9                   	leave  
8010a238:	c3                   	ret    

8010a239 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
8010a239:	f3 0f 1e fb          	endbr32 
8010a23d:	55                   	push   %ebp
8010a23e:	89 e5                	mov    %esp,%ebp
8010a240:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a243:	8b 45 08             	mov    0x8(%ebp),%eax
8010a246:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a249:	8b 45 08             	mov    0x8(%ebp),%eax
8010a24c:	83 c0 0e             	add    $0xe,%eax
8010a24f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010a252:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a255:	0f b6 00             	movzbl (%eax),%eax
8010a258:	0f b6 c0             	movzbl %al,%eax
8010a25b:	83 e0 0f             	and    $0xf,%eax
8010a25e:	c1 e0 02             	shl    $0x2,%eax
8010a261:	89 c2                	mov    %eax,%edx
8010a263:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a266:	01 d0                	add    %edx,%eax
8010a268:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a26b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a26e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
8010a271:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a274:	83 c0 0e             	add    $0xe,%eax
8010a277:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
8010a27a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a27d:	83 c0 14             	add    $0x14,%eax
8010a280:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
8010a283:	8b 45 10             	mov    0x10(%ebp),%eax
8010a286:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a28c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a28f:	8d 50 06             	lea    0x6(%eax),%edx
8010a292:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a295:	83 ec 04             	sub    $0x4,%esp
8010a298:	6a 06                	push   $0x6
8010a29a:	52                   	push   %edx
8010a29b:	50                   	push   %eax
8010a29c:	e8 39 b1 ff ff       	call   801053da <memmove>
8010a2a1:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a2a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2a7:	83 c0 06             	add    $0x6,%eax
8010a2aa:	83 ec 04             	sub    $0x4,%esp
8010a2ad:	6a 06                	push   $0x6
8010a2af:	68 ac 00 11 80       	push   $0x801100ac
8010a2b4:	50                   	push   %eax
8010a2b5:	e8 20 b1 ff ff       	call   801053da <memmove>
8010a2ba:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a2bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2c0:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a2c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a2c7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a2cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2ce:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a2d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2d4:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010a2d8:	83 ec 0c             	sub    $0xc,%esp
8010a2db:	6a 54                	push   $0x54
8010a2dd:	e8 e3 fc ff ff       	call   80109fc5 <H2N_ushort>
8010a2e2:	83 c4 10             	add    $0x10,%esp
8010a2e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a2e8:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a2ec:	0f b7 15 80 03 11 80 	movzwl 0x80110380,%edx
8010a2f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2f6:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a2fa:	0f b7 05 80 03 11 80 	movzwl 0x80110380,%eax
8010a301:	83 c0 01             	add    $0x1,%eax
8010a304:	66 a3 80 03 11 80    	mov    %ax,0x80110380
  ipv4_send->fragment = H2N_ushort(0x4000);
8010a30a:	83 ec 0c             	sub    $0xc,%esp
8010a30d:	68 00 40 00 00       	push   $0x4000
8010a312:	e8 ae fc ff ff       	call   80109fc5 <H2N_ushort>
8010a317:	83 c4 10             	add    $0x10,%esp
8010a31a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a31d:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a321:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a324:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010a328:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a32b:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a32f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a332:	83 c0 0c             	add    $0xc,%eax
8010a335:	83 ec 04             	sub    $0x4,%esp
8010a338:	6a 04                	push   $0x4
8010a33a:	68 04 f5 10 80       	push   $0x8010f504
8010a33f:	50                   	push   %eax
8010a340:	e8 95 b0 ff ff       	call   801053da <memmove>
8010a345:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a348:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a34b:	8d 50 0c             	lea    0xc(%eax),%edx
8010a34e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a351:	83 c0 10             	add    $0x10,%eax
8010a354:	83 ec 04             	sub    $0x4,%esp
8010a357:	6a 04                	push   $0x4
8010a359:	52                   	push   %edx
8010a35a:	50                   	push   %eax
8010a35b:	e8 7a b0 ff ff       	call   801053da <memmove>
8010a360:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a363:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a366:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a36c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a36f:	83 ec 0c             	sub    $0xc,%esp
8010a372:	50                   	push   %eax
8010a373:	e8 5d fd ff ff       	call   8010a0d5 <ipv4_chksum>
8010a378:	83 c4 10             	add    $0x10,%esp
8010a37b:	0f b7 c0             	movzwl %ax,%eax
8010a37e:	83 ec 0c             	sub    $0xc,%esp
8010a381:	50                   	push   %eax
8010a382:	e8 3e fc ff ff       	call   80109fc5 <H2N_ushort>
8010a387:	83 c4 10             	add    $0x10,%esp
8010a38a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a38d:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
8010a391:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a394:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010a397:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a39a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
8010a39e:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3a1:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010a3a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3a8:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
8010a3ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3af:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010a3b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3b6:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010a3ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3bd:	8d 50 08             	lea    0x8(%eax),%edx
8010a3c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3c3:	83 c0 08             	add    $0x8,%eax
8010a3c6:	83 ec 04             	sub    $0x4,%esp
8010a3c9:	6a 08                	push   $0x8
8010a3cb:	52                   	push   %edx
8010a3cc:	50                   	push   %eax
8010a3cd:	e8 08 b0 ff ff       	call   801053da <memmove>
8010a3d2:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010a3d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a3d8:	8d 50 10             	lea    0x10(%eax),%edx
8010a3db:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3de:	83 c0 10             	add    $0x10,%eax
8010a3e1:	83 ec 04             	sub    $0x4,%esp
8010a3e4:	6a 30                	push   $0x30
8010a3e6:	52                   	push   %edx
8010a3e7:	50                   	push   %eax
8010a3e8:	e8 ed af ff ff       	call   801053da <memmove>
8010a3ed:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
8010a3f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3f3:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010a3f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a3fc:	83 ec 0c             	sub    $0xc,%esp
8010a3ff:	50                   	push   %eax
8010a400:	e8 1c 00 00 00       	call   8010a421 <icmp_chksum>
8010a405:	83 c4 10             	add    $0x10,%esp
8010a408:	0f b7 c0             	movzwl %ax,%eax
8010a40b:	83 ec 0c             	sub    $0xc,%esp
8010a40e:	50                   	push   %eax
8010a40f:	e8 b1 fb ff ff       	call   80109fc5 <H2N_ushort>
8010a414:	83 c4 10             	add    $0x10,%esp
8010a417:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a41a:	66 89 42 02          	mov    %ax,0x2(%edx)
}
8010a41e:	90                   	nop
8010a41f:	c9                   	leave  
8010a420:	c3                   	ret    

8010a421 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
8010a421:	f3 0f 1e fb          	endbr32 
8010a425:	55                   	push   %ebp
8010a426:	89 e5                	mov    %esp,%ebp
8010a428:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010a42b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a42e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
8010a431:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a438:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010a43f:	eb 48                	jmp    8010a489 <icmp_chksum+0x68>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a441:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a444:	01 c0                	add    %eax,%eax
8010a446:	89 c2                	mov    %eax,%edx
8010a448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a44b:	01 d0                	add    %edx,%eax
8010a44d:	0f b6 00             	movzbl (%eax),%eax
8010a450:	0f b6 c0             	movzbl %al,%eax
8010a453:	c1 e0 08             	shl    $0x8,%eax
8010a456:	89 c2                	mov    %eax,%edx
8010a458:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010a45b:	01 c0                	add    %eax,%eax
8010a45d:	8d 48 01             	lea    0x1(%eax),%ecx
8010a460:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a463:	01 c8                	add    %ecx,%eax
8010a465:	0f b6 00             	movzbl (%eax),%eax
8010a468:	0f b6 c0             	movzbl %al,%eax
8010a46b:	01 d0                	add    %edx,%eax
8010a46d:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
8010a470:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010a477:	76 0c                	jbe    8010a485 <icmp_chksum+0x64>
      chk_sum = (chk_sum&0xFFFF)+1;
8010a479:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a47c:	0f b7 c0             	movzwl %ax,%eax
8010a47f:	83 c0 01             	add    $0x1,%eax
8010a482:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010a485:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010a489:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
8010a48d:	7e b2                	jle    8010a441 <icmp_chksum+0x20>
    }
  }
  return ~(chk_sum);
8010a48f:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010a492:	f7 d0                	not    %eax
}
8010a494:	c9                   	leave  
8010a495:	c3                   	ret    

8010a496 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
8010a496:	f3 0f 1e fb          	endbr32 
8010a49a:	55                   	push   %ebp
8010a49b:	89 e5                	mov    %esp,%ebp
8010a49d:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010a4a0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a4a3:	83 c0 0e             	add    $0xe,%eax
8010a4a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
8010a4a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4ac:	0f b6 00             	movzbl (%eax),%eax
8010a4af:	0f b6 c0             	movzbl %al,%eax
8010a4b2:	83 e0 0f             	and    $0xf,%eax
8010a4b5:	c1 e0 02             	shl    $0x2,%eax
8010a4b8:	89 c2                	mov    %eax,%edx
8010a4ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a4bd:	01 d0                	add    %edx,%eax
8010a4bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010a4c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4c5:	83 c0 14             	add    $0x14,%eax
8010a4c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
8010a4cb:	e8 ba 88 ff ff       	call   80102d8a <kalloc>
8010a4d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010a4d3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010a4da:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a4dd:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a4e1:	0f b6 c0             	movzbl %al,%eax
8010a4e4:	83 e0 02             	and    $0x2,%eax
8010a4e7:	85 c0                	test   %eax,%eax
8010a4e9:	74 3d                	je     8010a528 <tcp_proc+0x92>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010a4eb:	83 ec 0c             	sub    $0xc,%esp
8010a4ee:	6a 00                	push   $0x0
8010a4f0:	6a 12                	push   $0x12
8010a4f2:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a4f5:	50                   	push   %eax
8010a4f6:	ff 75 e8             	pushl  -0x18(%ebp)
8010a4f9:	ff 75 08             	pushl  0x8(%ebp)
8010a4fc:	e8 a2 01 00 00       	call   8010a6a3 <tcp_pkt_create>
8010a501:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
8010a504:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a507:	83 ec 08             	sub    $0x8,%esp
8010a50a:	50                   	push   %eax
8010a50b:	ff 75 e8             	pushl  -0x18(%ebp)
8010a50e:	e8 ff f0 ff ff       	call   80109612 <i8254_send>
8010a513:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a516:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a51b:	83 c0 01             	add    $0x1,%eax
8010a51e:	a3 84 03 11 80       	mov    %eax,0x80110384
8010a523:	e9 69 01 00 00       	jmp    8010a691 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
8010a528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a52b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a52f:	3c 18                	cmp    $0x18,%al
8010a531:	0f 85 10 01 00 00    	jne    8010a647 <tcp_proc+0x1b1>
    if(memcmp(payload,"GET",3)){
8010a537:	83 ec 04             	sub    $0x4,%esp
8010a53a:	6a 03                	push   $0x3
8010a53c:	68 be ca 10 80       	push   $0x8010cabe
8010a541:	ff 75 ec             	pushl  -0x14(%ebp)
8010a544:	e8 35 ae ff ff       	call   8010537e <memcmp>
8010a549:	83 c4 10             	add    $0x10,%esp
8010a54c:	85 c0                	test   %eax,%eax
8010a54e:	74 74                	je     8010a5c4 <tcp_proc+0x12e>
      cprintf("ACK PSH\n");
8010a550:	83 ec 0c             	sub    $0xc,%esp
8010a553:	68 c2 ca 10 80       	push   $0x8010cac2
8010a558:	e8 af 5e ff ff       	call   8010040c <cprintf>
8010a55d:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a560:	83 ec 0c             	sub    $0xc,%esp
8010a563:	6a 00                	push   $0x0
8010a565:	6a 10                	push   $0x10
8010a567:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a56a:	50                   	push   %eax
8010a56b:	ff 75 e8             	pushl  -0x18(%ebp)
8010a56e:	ff 75 08             	pushl  0x8(%ebp)
8010a571:	e8 2d 01 00 00       	call   8010a6a3 <tcp_pkt_create>
8010a576:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a579:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a57c:	83 ec 08             	sub    $0x8,%esp
8010a57f:	50                   	push   %eax
8010a580:	ff 75 e8             	pushl  -0x18(%ebp)
8010a583:	e8 8a f0 ff ff       	call   80109612 <i8254_send>
8010a588:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a58b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a58e:	83 c0 36             	add    $0x36,%eax
8010a591:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a594:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010a597:	50                   	push   %eax
8010a598:	ff 75 e0             	pushl  -0x20(%ebp)
8010a59b:	6a 00                	push   $0x0
8010a59d:	6a 00                	push   $0x0
8010a59f:	e8 66 04 00 00       	call   8010aa0a <http_proc>
8010a5a4:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a5a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010a5aa:	83 ec 0c             	sub    $0xc,%esp
8010a5ad:	50                   	push   %eax
8010a5ae:	6a 18                	push   $0x18
8010a5b0:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a5b3:	50                   	push   %eax
8010a5b4:	ff 75 e8             	pushl  -0x18(%ebp)
8010a5b7:	ff 75 08             	pushl  0x8(%ebp)
8010a5ba:	e8 e4 00 00 00       	call   8010a6a3 <tcp_pkt_create>
8010a5bf:	83 c4 20             	add    $0x20,%esp
8010a5c2:	eb 62                	jmp    8010a626 <tcp_proc+0x190>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
8010a5c4:	83 ec 0c             	sub    $0xc,%esp
8010a5c7:	6a 00                	push   $0x0
8010a5c9:	6a 10                	push   $0x10
8010a5cb:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a5ce:	50                   	push   %eax
8010a5cf:	ff 75 e8             	pushl  -0x18(%ebp)
8010a5d2:	ff 75 08             	pushl  0x8(%ebp)
8010a5d5:	e8 c9 00 00 00       	call   8010a6a3 <tcp_pkt_create>
8010a5da:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
8010a5dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a5e0:	83 ec 08             	sub    $0x8,%esp
8010a5e3:	50                   	push   %eax
8010a5e4:	ff 75 e8             	pushl  -0x18(%ebp)
8010a5e7:	e8 26 f0 ff ff       	call   80109612 <i8254_send>
8010a5ec:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
8010a5ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a5f2:	83 c0 36             	add    $0x36,%eax
8010a5f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
8010a5f8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a5fb:	50                   	push   %eax
8010a5fc:	ff 75 e4             	pushl  -0x1c(%ebp)
8010a5ff:	6a 00                	push   $0x0
8010a601:	6a 00                	push   $0x0
8010a603:	e8 02 04 00 00       	call   8010aa0a <http_proc>
8010a608:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
8010a60b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010a60e:	83 ec 0c             	sub    $0xc,%esp
8010a611:	50                   	push   %eax
8010a612:	6a 18                	push   $0x18
8010a614:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a617:	50                   	push   %eax
8010a618:	ff 75 e8             	pushl  -0x18(%ebp)
8010a61b:	ff 75 08             	pushl  0x8(%ebp)
8010a61e:	e8 80 00 00 00       	call   8010a6a3 <tcp_pkt_create>
8010a623:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
8010a626:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a629:	83 ec 08             	sub    $0x8,%esp
8010a62c:	50                   	push   %eax
8010a62d:	ff 75 e8             	pushl  -0x18(%ebp)
8010a630:	e8 dd ef ff ff       	call   80109612 <i8254_send>
8010a635:	83 c4 10             	add    $0x10,%esp
    seq_num++;
8010a638:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a63d:	83 c0 01             	add    $0x1,%eax
8010a640:	a3 84 03 11 80       	mov    %eax,0x80110384
8010a645:	eb 4a                	jmp    8010a691 <tcp_proc+0x1fb>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
8010a647:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a64a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010a64e:	3c 10                	cmp    $0x10,%al
8010a650:	75 3f                	jne    8010a691 <tcp_proc+0x1fb>
    if(fin_flag == 1){
8010a652:	a1 88 03 11 80       	mov    0x80110388,%eax
8010a657:	83 f8 01             	cmp    $0x1,%eax
8010a65a:	75 35                	jne    8010a691 <tcp_proc+0x1fb>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
8010a65c:	83 ec 0c             	sub    $0xc,%esp
8010a65f:	6a 00                	push   $0x0
8010a661:	6a 01                	push   $0x1
8010a663:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010a666:	50                   	push   %eax
8010a667:	ff 75 e8             	pushl  -0x18(%ebp)
8010a66a:	ff 75 08             	pushl  0x8(%ebp)
8010a66d:	e8 31 00 00 00       	call   8010a6a3 <tcp_pkt_create>
8010a672:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
8010a675:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010a678:	83 ec 08             	sub    $0x8,%esp
8010a67b:	50                   	push   %eax
8010a67c:	ff 75 e8             	pushl  -0x18(%ebp)
8010a67f:	e8 8e ef ff ff       	call   80109612 <i8254_send>
8010a684:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
8010a687:	c7 05 88 03 11 80 00 	movl   $0x0,0x80110388
8010a68e:	00 00 00 
    }
  }
  kfree((char *)send_addr);
8010a691:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a694:	83 ec 0c             	sub    $0xc,%esp
8010a697:	50                   	push   %eax
8010a698:	e8 4f 86 ff ff       	call   80102cec <kfree>
8010a69d:	83 c4 10             	add    $0x10,%esp
}
8010a6a0:	90                   	nop
8010a6a1:	c9                   	leave  
8010a6a2:	c3                   	ret    

8010a6a3 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
8010a6a3:	f3 0f 1e fb          	endbr32 
8010a6a7:	55                   	push   %ebp
8010a6a8:	89 e5                	mov    %esp,%ebp
8010a6aa:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010a6ad:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010a6b3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a6b6:	83 c0 0e             	add    $0xe,%eax
8010a6b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a6bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6bf:	0f b6 00             	movzbl (%eax),%eax
8010a6c2:	0f b6 c0             	movzbl %al,%eax
8010a6c5:	83 e0 0f             	and    $0xf,%eax
8010a6c8:	c1 e0 02             	shl    $0x2,%eax
8010a6cb:	89 c2                	mov    %eax,%edx
8010a6cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a6d0:	01 d0                	add    %edx,%eax
8010a6d2:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a6d5:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a6d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a6db:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a6de:	83 c0 0e             	add    $0xe,%eax
8010a6e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a6e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a6e7:	83 c0 14             	add    $0x14,%eax
8010a6ea:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a6ed:	8b 45 18             	mov    0x18(%ebp),%eax
8010a6f0:	8d 50 36             	lea    0x36(%eax),%edx
8010a6f3:	8b 45 10             	mov    0x10(%ebp),%eax
8010a6f6:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a6f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a6fb:	8d 50 06             	lea    0x6(%eax),%edx
8010a6fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a701:	83 ec 04             	sub    $0x4,%esp
8010a704:	6a 06                	push   $0x6
8010a706:	52                   	push   %edx
8010a707:	50                   	push   %eax
8010a708:	e8 cd ac ff ff       	call   801053da <memmove>
8010a70d:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a710:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a713:	83 c0 06             	add    $0x6,%eax
8010a716:	83 ec 04             	sub    $0x4,%esp
8010a719:	6a 06                	push   $0x6
8010a71b:	68 ac 00 11 80       	push   $0x801100ac
8010a720:	50                   	push   %eax
8010a721:	e8 b4 ac ff ff       	call   801053da <memmove>
8010a726:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a729:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a72c:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a730:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a733:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a737:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a73a:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a73d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a740:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a744:	8b 45 18             	mov    0x18(%ebp),%eax
8010a747:	83 c0 28             	add    $0x28,%eax
8010a74a:	0f b7 c0             	movzwl %ax,%eax
8010a74d:	83 ec 0c             	sub    $0xc,%esp
8010a750:	50                   	push   %eax
8010a751:	e8 6f f8 ff ff       	call   80109fc5 <H2N_ushort>
8010a756:	83 c4 10             	add    $0x10,%esp
8010a759:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a75c:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a760:	0f b7 15 80 03 11 80 	movzwl 0x80110380,%edx
8010a767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a76a:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a76e:	0f b7 05 80 03 11 80 	movzwl 0x80110380,%eax
8010a775:	83 c0 01             	add    $0x1,%eax
8010a778:	66 a3 80 03 11 80    	mov    %ax,0x80110380
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a77e:	83 ec 0c             	sub    $0xc,%esp
8010a781:	6a 00                	push   $0x0
8010a783:	e8 3d f8 ff ff       	call   80109fc5 <H2N_ushort>
8010a788:	83 c4 10             	add    $0x10,%esp
8010a78b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a78e:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a792:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a795:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a79c:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a7a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7a3:	83 c0 0c             	add    $0xc,%eax
8010a7a6:	83 ec 04             	sub    $0x4,%esp
8010a7a9:	6a 04                	push   $0x4
8010a7ab:	68 04 f5 10 80       	push   $0x8010f504
8010a7b0:	50                   	push   %eax
8010a7b1:	e8 24 ac ff ff       	call   801053da <memmove>
8010a7b6:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a7b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a7bc:	8d 50 0c             	lea    0xc(%eax),%edx
8010a7bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7c2:	83 c0 10             	add    $0x10,%eax
8010a7c5:	83 ec 04             	sub    $0x4,%esp
8010a7c8:	6a 04                	push   $0x4
8010a7ca:	52                   	push   %edx
8010a7cb:	50                   	push   %eax
8010a7cc:	e8 09 ac ff ff       	call   801053da <memmove>
8010a7d1:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a7d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7d7:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a7dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a7e0:	83 ec 0c             	sub    $0xc,%esp
8010a7e3:	50                   	push   %eax
8010a7e4:	e8 ec f8 ff ff       	call   8010a0d5 <ipv4_chksum>
8010a7e9:	83 c4 10             	add    $0x10,%esp
8010a7ec:	0f b7 c0             	movzwl %ax,%eax
8010a7ef:	83 ec 0c             	sub    $0xc,%esp
8010a7f2:	50                   	push   %eax
8010a7f3:	e8 cd f7 ff ff       	call   80109fc5 <H2N_ushort>
8010a7f8:	83 c4 10             	add    $0x10,%esp
8010a7fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a7fe:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a802:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a805:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a809:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a80c:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a80f:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a812:	0f b7 10             	movzwl (%eax),%edx
8010a815:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a818:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a81c:	a1 84 03 11 80       	mov    0x80110384,%eax
8010a821:	83 ec 0c             	sub    $0xc,%esp
8010a824:	50                   	push   %eax
8010a825:	e8 c1 f7 ff ff       	call   80109feb <H2N_uint>
8010a82a:	83 c4 10             	add    $0x10,%esp
8010a82d:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a830:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a833:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a836:	8b 40 04             	mov    0x4(%eax),%eax
8010a839:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a83f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a842:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a845:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a848:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a84c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a84f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a853:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a856:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a85a:	8b 45 14             	mov    0x14(%ebp),%eax
8010a85d:	89 c2                	mov    %eax,%edx
8010a85f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a862:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a865:	83 ec 0c             	sub    $0xc,%esp
8010a868:	68 90 38 00 00       	push   $0x3890
8010a86d:	e8 53 f7 ff ff       	call   80109fc5 <H2N_ushort>
8010a872:	83 c4 10             	add    $0x10,%esp
8010a875:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a878:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a87c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a87f:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a885:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a888:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a88e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a891:	83 ec 0c             	sub    $0xc,%esp
8010a894:	50                   	push   %eax
8010a895:	e8 1f 00 00 00       	call   8010a8b9 <tcp_chksum>
8010a89a:	83 c4 10             	add    $0x10,%esp
8010a89d:	83 c0 08             	add    $0x8,%eax
8010a8a0:	0f b7 c0             	movzwl %ax,%eax
8010a8a3:	83 ec 0c             	sub    $0xc,%esp
8010a8a6:	50                   	push   %eax
8010a8a7:	e8 19 f7 ff ff       	call   80109fc5 <H2N_ushort>
8010a8ac:	83 c4 10             	add    $0x10,%esp
8010a8af:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a8b2:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a8b6:	90                   	nop
8010a8b7:	c9                   	leave  
8010a8b8:	c3                   	ret    

8010a8b9 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a8b9:	f3 0f 1e fb          	endbr32 
8010a8bd:	55                   	push   %ebp
8010a8be:	89 e5                	mov    %esp,%ebp
8010a8c0:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a8c3:	8b 45 08             	mov    0x8(%ebp),%eax
8010a8c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a8c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8cc:	83 c0 14             	add    $0x14,%eax
8010a8cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a8d2:	83 ec 04             	sub    $0x4,%esp
8010a8d5:	6a 04                	push   $0x4
8010a8d7:	68 04 f5 10 80       	push   $0x8010f504
8010a8dc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a8df:	50                   	push   %eax
8010a8e0:	e8 f5 aa ff ff       	call   801053da <memmove>
8010a8e5:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a8e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a8eb:	83 c0 0c             	add    $0xc,%eax
8010a8ee:	83 ec 04             	sub    $0x4,%esp
8010a8f1:	6a 04                	push   $0x4
8010a8f3:	50                   	push   %eax
8010a8f4:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a8f7:	83 c0 04             	add    $0x4,%eax
8010a8fa:	50                   	push   %eax
8010a8fb:	e8 da aa ff ff       	call   801053da <memmove>
8010a900:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a903:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a907:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a90b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a90e:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a912:	0f b7 c0             	movzwl %ax,%eax
8010a915:	83 ec 0c             	sub    $0xc,%esp
8010a918:	50                   	push   %eax
8010a919:	e8 81 f6 ff ff       	call   80109f9f <N2H_ushort>
8010a91e:	83 c4 10             	add    $0x10,%esp
8010a921:	83 e8 14             	sub    $0x14,%eax
8010a924:	0f b7 c0             	movzwl %ax,%eax
8010a927:	83 ec 0c             	sub    $0xc,%esp
8010a92a:	50                   	push   %eax
8010a92b:	e8 95 f6 ff ff       	call   80109fc5 <H2N_ushort>
8010a930:	83 c4 10             	add    $0x10,%esp
8010a933:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a937:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a93e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a941:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a944:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a94b:	eb 33                	jmp    8010a980 <tcp_chksum+0xc7>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a94d:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a950:	01 c0                	add    %eax,%eax
8010a952:	89 c2                	mov    %eax,%edx
8010a954:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a957:	01 d0                	add    %edx,%eax
8010a959:	0f b6 00             	movzbl (%eax),%eax
8010a95c:	0f b6 c0             	movzbl %al,%eax
8010a95f:	c1 e0 08             	shl    $0x8,%eax
8010a962:	89 c2                	mov    %eax,%edx
8010a964:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a967:	01 c0                	add    %eax,%eax
8010a969:	8d 48 01             	lea    0x1(%eax),%ecx
8010a96c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a96f:	01 c8                	add    %ecx,%eax
8010a971:	0f b6 00             	movzbl (%eax),%eax
8010a974:	0f b6 c0             	movzbl %al,%eax
8010a977:	01 d0                	add    %edx,%eax
8010a979:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a97c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a980:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a984:	7e c7                	jle    8010a94d <tcp_chksum+0x94>
  }

  bin = (uchar *)(tcp_p);
8010a986:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a989:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a98c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a993:	eb 33                	jmp    8010a9c8 <tcp_chksum+0x10f>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a995:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a998:	01 c0                	add    %eax,%eax
8010a99a:	89 c2                	mov    %eax,%edx
8010a99c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a99f:	01 d0                	add    %edx,%eax
8010a9a1:	0f b6 00             	movzbl (%eax),%eax
8010a9a4:	0f b6 c0             	movzbl %al,%eax
8010a9a7:	c1 e0 08             	shl    $0x8,%eax
8010a9aa:	89 c2                	mov    %eax,%edx
8010a9ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a9af:	01 c0                	add    %eax,%eax
8010a9b1:	8d 48 01             	lea    0x1(%eax),%ecx
8010a9b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a9b7:	01 c8                	add    %ecx,%eax
8010a9b9:	0f b6 00             	movzbl (%eax),%eax
8010a9bc:	0f b6 c0             	movzbl %al,%eax
8010a9bf:	01 d0                	add    %edx,%eax
8010a9c1:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a9c4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a9c8:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a9cc:	0f b7 c0             	movzwl %ax,%eax
8010a9cf:	83 ec 0c             	sub    $0xc,%esp
8010a9d2:	50                   	push   %eax
8010a9d3:	e8 c7 f5 ff ff       	call   80109f9f <N2H_ushort>
8010a9d8:	83 c4 10             	add    $0x10,%esp
8010a9db:	66 d1 e8             	shr    %ax
8010a9de:	0f b7 c0             	movzwl %ax,%eax
8010a9e1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a9e4:	7c af                	jl     8010a995 <tcp_chksum+0xdc>
  }
  chk_sum += (chk_sum>>8*2);
8010a9e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a9e9:	c1 e8 10             	shr    $0x10,%eax
8010a9ec:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a9ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a9f2:	f7 d0                	not    %eax
}
8010a9f4:	c9                   	leave  
8010a9f5:	c3                   	ret    

8010a9f6 <tcp_fin>:

void tcp_fin(){
8010a9f6:	f3 0f 1e fb          	endbr32 
8010a9fa:	55                   	push   %ebp
8010a9fb:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a9fd:	c7 05 88 03 11 80 01 	movl   $0x1,0x80110388
8010aa04:	00 00 00 
}
8010aa07:	90                   	nop
8010aa08:	5d                   	pop    %ebp
8010aa09:	c3                   	ret    

8010aa0a <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010aa0a:	f3 0f 1e fb          	endbr32 
8010aa0e:	55                   	push   %ebp
8010aa0f:	89 e5                	mov    %esp,%ebp
8010aa11:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010aa14:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa17:	83 ec 04             	sub    $0x4,%esp
8010aa1a:	6a 00                	push   $0x0
8010aa1c:	68 cb ca 10 80       	push   $0x8010cacb
8010aa21:	50                   	push   %eax
8010aa22:	e8 65 00 00 00       	call   8010aa8c <http_strcpy>
8010aa27:	83 c4 10             	add    $0x10,%esp
8010aa2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010aa2d:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa30:	83 ec 04             	sub    $0x4,%esp
8010aa33:	ff 75 f4             	pushl  -0xc(%ebp)
8010aa36:	68 de ca 10 80       	push   $0x8010cade
8010aa3b:	50                   	push   %eax
8010aa3c:	e8 4b 00 00 00       	call   8010aa8c <http_strcpy>
8010aa41:	83 c4 10             	add    $0x10,%esp
8010aa44:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010aa47:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa4a:	83 ec 04             	sub    $0x4,%esp
8010aa4d:	ff 75 f4             	pushl  -0xc(%ebp)
8010aa50:	68 f9 ca 10 80       	push   $0x8010caf9
8010aa55:	50                   	push   %eax
8010aa56:	e8 31 00 00 00       	call   8010aa8c <http_strcpy>
8010aa5b:	83 c4 10             	add    $0x10,%esp
8010aa5e:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010aa61:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010aa64:	83 e0 01             	and    $0x1,%eax
8010aa67:	85 c0                	test   %eax,%eax
8010aa69:	74 11                	je     8010aa7c <http_proc+0x72>
    char *payload = (char *)send;
8010aa6b:	8b 45 10             	mov    0x10(%ebp),%eax
8010aa6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010aa71:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010aa74:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010aa77:	01 d0                	add    %edx,%eax
8010aa79:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010aa7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010aa7f:	8b 45 14             	mov    0x14(%ebp),%eax
8010aa82:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010aa84:	e8 6d ff ff ff       	call   8010a9f6 <tcp_fin>
}
8010aa89:	90                   	nop
8010aa8a:	c9                   	leave  
8010aa8b:	c3                   	ret    

8010aa8c <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010aa8c:	f3 0f 1e fb          	endbr32 
8010aa90:	55                   	push   %ebp
8010aa91:	89 e5                	mov    %esp,%ebp
8010aa93:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010aa96:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010aa9d:	eb 20                	jmp    8010aabf <http_strcpy+0x33>
    dst[start_index+i] = src[i];
8010aa9f:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aaa2:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aaa5:	01 d0                	add    %edx,%eax
8010aaa7:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010aaaa:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aaad:	01 ca                	add    %ecx,%edx
8010aaaf:	89 d1                	mov    %edx,%ecx
8010aab1:	8b 55 08             	mov    0x8(%ebp),%edx
8010aab4:	01 ca                	add    %ecx,%edx
8010aab6:	0f b6 00             	movzbl (%eax),%eax
8010aab9:	88 02                	mov    %al,(%edx)
    i++;
8010aabb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010aabf:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010aac2:	8b 45 0c             	mov    0xc(%ebp),%eax
8010aac5:	01 d0                	add    %edx,%eax
8010aac7:	0f b6 00             	movzbl (%eax),%eax
8010aaca:	84 c0                	test   %al,%al
8010aacc:	75 d1                	jne    8010aa9f <http_strcpy+0x13>
  }
  return i;
8010aace:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010aad1:	c9                   	leave  
8010aad2:	c3                   	ret    
