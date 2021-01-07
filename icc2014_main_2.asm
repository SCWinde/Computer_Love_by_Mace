// POST-RELEASE VERSION:	with 6-line font optimization and jitter bug fix.
/* Memory map:

	0801 - 080e	BASIC list
	0810 - 0f8f	Charset where DYCP is plotted
	0f90 - 0fef Code, routine:bufferScrol
	0ff0 - 0ff8	Empty char to fill unused parts of the screen
	1000 - 1ffe	Music routine (external file)
	2000 - 2eff	Bitmap of logo (external file)
	2f00 - 2f7f	Sine data (32 bytes per 1 wave between $00 and $28)
				To save data, only half a page is used.
	2f80 - 2fbf	Sprite 1, 3 vertical multicol bars
	2fc0 - 2fff	Sprite 2, 1 vertical bar
	3000 - 33e7	Screen (external file)
				Contains colours for the logo and pattern for dycp plot
	3400 - 357f	Font (external file)
				First 64 bytes are all top lines of chars, next 64 bytes
				are 2nd line of all chars and so on.
	3580 - 364c	Code, initialisation
	364d - 366b	IRQ 1, display the logo and prepare DYCP
	366c - 36d1	IRQ 2, display white line and blue part, play music
	36d2 - 3712	IRQ 3, end of blue part, 2nd white line, bitmap for vertical bars
	3713 - 3745	IRQ 4, open upper and lower border
	3746 - 41c2	Subroutine createDycp
	41c3 - 41ea	Sine buffer
	41eb - 44a7	Scroll text (exernal file)
*/

// Import library, contains aliases for video chip registers
.import source "shared_VIC.kas"

// Load external files
.var musicFile = LoadSid("Computer_Love_v2.sid")
.var logoFile = LoadPicture("erwin_logo_320x96.gif")

.var ctmTemplate = "CtmHeader=0,CtmSize=10,CtmPadding=12,CtmData=24"
.var fontFile = LoadBinary("hr 1x1 (7x6) - Mace 2014 Intro Compo font.ctm", ctmTemplate)

// BASIC upstart, generates runable list with SYS {start address}
:BasicUpstart2(start)

// first area for plotting the dycp
.align $8
.pc = * "GFX: plot area 1"
plotArea:
	.fill 240*8,00

// This subroutine fetches 40 characters from scrollText and
// puts it in a buffer, so the DYCP routine doesn't need to 'think'
// where to get the text from.
.pc = * "CODE: bufferScroll"
bufferScroll:
	ldy #$00				// Counter for filling textBuffer
	ldx #$00				// Counter for reading scrollText
	bfrLoop:
		lda scrollText,x	// Read from scrollText
		cmp #$ff			// End sign $ff reached?
		bne noEnd
		lda #$20			// Replace end sign $ff with space $20
							// (not necessary, since char $ff is a space too)
		bne skipInx			// Don't continue reading from scrollText when
							// and sign $ff has been reached, untill the end
							// sign is the first char in the buffer
							// (handled at label 'checkEnd')
	noEnd:
		inx
	skipInx:
		sta textBuffer,y	// Buffer text
		iny
		cpy #$28			// Buffer filled?
		bne bfrLoop			// If not, loop
	checkEnd:
		cpx #$00			// End sign is first char?
		bne noReset			// If not, don't reset scrollText vector
		lda #<scrollText	// If so, reset scrollText vector
		sta bfrLoop+1
		lda #>scrollText
		sta bfrLoop+2
		jmp noPage			// And don't increase vector
	noReset:	
		inc bfrLoop+1		// Increase scrollText vector
		bne noPage
		inc bfrLoop+2
	noPage:
		rts					// End of subroutine

.pc = * "BUFFER: text buffer"
textBuffer:
	.fill 40,20				// This will be filled with text

.align $8
.pc = * "GFX: fill char"
	.fill 8,0				// empty char $ff

// Load the music
.pc = musicFile.location "MUSIC: music (external file, SID)"
	.fill musicFile.size, musicFile.getData(i)

// drop the logo into memory
.pc = $2000 "GFX: logo bitmap (external file, GIF)"
	.for (var y=0; y<12; y++)
		.for (var x=0; x<40; x++)
			.for (var charPosY=0; charPosY<8; charPosY++)
				.byte logoFile.getSinglecolorByte(x,charPosY+y*8)

// raw sine data
.align $100
.pc = * "DATA: sine data"
sinData:
	.fill 128,20 + 20*sin(toRadians(i*2880/256))

// room for sprites
.align $40
.pc = * "GFX: sprite 1"
spriteMultiCol:
	.for (var x=0; x<21; x++)
		.byte %01010000, %11110000, %10100000

.align $40
.pc = * "GFX: sprite 2"
spriteSingleCol:
	.for (var x=0; x<21; x++)
		.byte %11110000, %00000000, %00000000

// the character screen goes here
.align $0400
.pc = * "GFX: screen"
screen:
	.import source "icc2014_screen.kas"

.pc = screen + $3f8 "DATA: spritepointers"
spritePointers:
	.byte spriteMultiCol/64, spriteSingleCol/64, spriteSingleCol/64

// Load the font
.align $100
.pc = * "GFX: font (external file, CTM)"
font:
	.fill 384, fontFile.getCtmData([[i*8] & $1ff] + floor(i/64))

.pc = * "CODE: init"
start:
		sei						// START
		lda #$00
		ldx #$00
		ldy #$00
		jsr musicFile.init		// init music
		jsr bufferScroll		// init text buffer
		jsr createDycp			// init dycp buffer
		ldx #<irq1				// set IRQ 1
		ldy #>irq1
		stx $0314
		sty $0315
		asl $d019				// ack pending IRQs
		lda #$7f				// stop all timers
		sta $dc0d
		sta $dd0d
		lda $dc0d				// ack pending timers
		lda $dd0d
		lda #$81				// set to raster IRQ
		sta $d01a
		ldx #$00				// colour DYCP area
colourFill:
		sta $d800 + 15*40,x		// A=#$81 == white
		inx
		cpx #$f0
		bne colourFill
		lda #$0f				// Colour last few chars of screen
		sta $dbe4				// to hide some nasty jitter bug
		sta $dbe5
		sta $dbe6
		sta $dbe7
		lda #$32				// trigger for IRQ1 = rasterline $32
		sta $d012
		lda #$3b				// clear raster MSB, set screen to bitmap
		sta $d011
		lda #$07				// enable and expand (X & Y) first 3 sprites
		sta VIC.spriteEnable
		sta VIC.spriteExpandX
		sta VIC.spriteExpandY
		lda #$01				// make sprite one multicolour
		sta VIC.spriteColorMode
		lda #148				// set X-coords of sprites
		sta VIC.sprite1.X
		clc
		adc #$30
		sta VIC.sprite2.X
		adc #$10
		sta VIC.sprite3.X
		lda #$02				// set colours of sprites
		sta VIC.color.spriteMC1
		lda #$08
		sta VIC.color.spriteMC2
		lda #$07
		sta VIC.sprite1.color
		lda #$05
		sta VIC.sprite2.color
		lda #$06
		sta VIC.sprite3.color
		cli
loop:
		ldx #$00				//detect if space is pressed
		lda #$7f
		sta $dc00
		lda $dc01
		and #%00010000
		bne loop
		sei						// if so, stop IRQ
		lda #$81				// clear timers
		sta $dc0d
		sta $dd0d
		lda $dc0d				// ack pending timers
		lda $dd0d
		asl $d019				// ack pending IRQ
		lda #$00				// set to normal IRQ
		sta $d01a
		ldx #$31				// reset IRQ vectors
		ldy #$ea
		stx $0314
		sty $0315
		lda #$00				// volume to $00
		sta $d418
		lda #$1b				// screen to chars
		sta $d011
		lda #$c7				// screen to normal width
		lda VIC.ctrlReg2
		lda #$15				// screen to normal chars
		sta VIC.screenPointer
		lda #$0e				// screen colours to default
		sta $d020
		lda #$06
		sta $d021
		cli						// enable IRQ
		rts						// exit

.pc = * "CODE: irq 1"
irq1:							// LOGO AREA
		asl $d019				// ack IRQ
		lda #[[screen/$400]<<4]|[[$2000/$800]<<1]	// set screen
		sta VIC.screenPointer
		nop						// timer NOP
		lda #$3b				// screen to bitmap
		sta $d011
		lda #$c8				// default screen X-position & width
		sta VIC.ctrlReg2

		jsr createDycp			// clear and generate DYCP
	
		lda #$92				// IRQ2 triggers to rasterline $92
		ldx #<irq2
		ldy #>irq2
		jmp irqend				// end IRQ

.pc = * "CODE: irq 2"
irq2:							// START OF BLUE AREA WITH DYCP
		asl $d019				// ack IRQ
		nop						// timer NOPs
		nop
		nop
		lda #$1b				// screen to chars
		sta $d011
		lda #$01				// white line
		sta $d020
		sta $d021
		lda #[[screen/$400]<<4]|[[$0800/$800]<<1]	// screen to DYCP charset
		sta VIC.screenPointer
		nop						// timer NOPs
		nop

		lda #$06				// screen colour to blue
		sta $d020
		sta $d021

.label screenScroll = *+1
		lda #$c7				// scroll sideways
		sta VIC.ctrlReg2
		tax
		dex						// move to right by 2 pixels
		dex
		cpx #$bf				// to exreme right?
		bne skipText
		jsr bufferScroll		// on reset of scroll byte, fetch new char
		ldx #$c7				// reset screen scroll position
skipText:
		stx screenScroll
		jsr musicFile.play		// play music

fillSinBuffer:
		lda sinCounter			// cycle sine data
		sta thisCounter +1
		ldx #$00
thisCounter:
		lda sinData				// fetch from data
		sta sinBuffer,x			// store in buffer for DYCP to fetch from
		inc thisCounter +1
		inx
		cpx #$28				// buffer filled?
		bne thisCounter
		ldx sinCounter
		inx
		cpx #$40				// end of sine cycle?
		bne noResetSin
		ldx #$00				// reset cycle
noResetSin:
		stx sinCounter

		lda #$e9				// IRQ3 triggers to rasterline $e9
		ldx #<irq3
		ldy #>irq3

		jmp irqend				// end of IRQ2
sinCounter:
		.byte $00

.pc = * "CODE: irq 3"
irq3:						// END OF BLUE AREA
		asl $d019			// ack IRQ
		nop					// timer NOPs
		nop
		nop
		nop
		nop
		nop
	
		lda #$01			// bottom white line
		sta $d020
		sta $d021
		lda #$c4			// 4px shift to align vertical bars
		sta VIC.ctrlReg2

		ldx #$07			// timer
tinyTimeLoop:
		dex
		bne tinyTimeLoop
		nop					// timer NOPs
		nop

		lda #[[screen/$400]<<4]|[[$2000/$800]<<1]	// set screen to logo
		sta VIC.screenPointer
		lda #$0f			// screen colours to light grey
		sta $d020
		sta $d021
		lda #$3b			// screen to bitmap
		sta $d011

		lda #$fa			// sprite Y-positions to $fa
		sta VIC.sprite1.Y
		sta VIC.sprite2.Y
		sta VIC.sprite3.Y
	
		ldx #<irq4			// IRQ4 triggers to rasterline $fa
		ldy #>irq4

		jmp irqend			// end of IRQ3

.pc = * "CODE: irq 4"
irq4:						// TO OPEN BORDERS
		asl $d019			// ack IRQ
		nop
		lda #$13			// fix screen height to open border
		sta $d011
		ldx #$40			// timer loop
timeloop:
		dex
		bne timeloop
		lda #$1b			// fix screen height to open border
		sta $d011

		lda #$08			// sprite Y-positions to $08
		sta VIC.sprite1.Y
		sta VIC.sprite2.Y
		sta VIC.sprite3.Y

		lda #$32			// IRQ1 triggers to rasterline $32
		ldx #<irq1
		ldy #>irq1

irqend:						// WHERE EVERYTHING ENDS
		sta $d012			// set rasterline trigger
		stx $0314			// set IRQ vectors
		sty $0315
		pla					// reset registers
		tay
		pla
		tax
		pla
		rti					// end IRQ

.pc = * "CODE: createDycp"
createDycp:					// Unroll DYCP routine (40 characters)
.for (var dycpPosition=0; dycpPosition<40; dycpPosition++) {
		
		// Debug tool to localise $3fff (ghostbyte) in code.
		// Ghostbyte always needs to be $00 in order to have clear
		// borders. Code has to bypass $00 (=BRK), fixing can only be
		// done by hand.
		.print "Unrolled code for char " + dycpPosition + " starts at $" + toHexString(*)
		
		lda #$00							// clear old DYCP
.label oldData = *+1
		ldx #$00							// old sine is stored here
		sta plotArea + dycpPosition*48,x	// clear line 1

		.if (dycpPosition == 33) {			// fix for ghostbyte $3fff in code
			bit $00
			}

		sta plotArea + dycpPosition*48 +1,x	// clear line 2
		sta plotArea + dycpPosition*48 +2,x	// clear line 3
		sta plotArea + dycpPosition*48 +3,x	// clear line 4
		sta plotArea + dycpPosition*48 +4,x	// clear line 5
		sta plotArea + dycpPosition*48 +5,x	// clear line 6

		ldx sinBuffer + dycpPosition		// fetch new sine data
		stx oldData							// store sine backwards for clearing later
		ldy textBuffer + dycpPosition		// fetch character from text buffer
		lda font,y							// fetch char line 1
		sta plotArea + dycpPosition*48,x	// plot char line 1
		lda font +1*64,y					// fetch char line 2
		sta plotArea + dycpPosition*48 +1,x	// plot char line 2
		lda font +2*64,y					// fetch char line 3
		sta plotArea + dycpPosition*48 +2,x	// plot char line 3
		lda font +3*64,y					// fetch char line 4
		sta plotArea + dycpPosition*48 +3,x	// plot char line 4
		lda font +4*64,y					// fetch char line 5
		sta plotArea + dycpPosition*48 +4,x	// plot char line 5
		lda font +5*64,y					// fetch char line 6
		sta plotArea + dycpPosition*48 +5,x	// plot char line 6
	}										// (unroll 40 times)
		rts									// end of subroutine

// sinBuffers
.pc = * "BUFFER: sine buffer"
sinBuffer:									// Buffer for sine data
	.fill 40,0

.pc = * "DATA: scrolltext (external file, KAS)"
scrollText:									// Scroll text (external file)
	.import source "icc2014_scrolltext2.kas"
