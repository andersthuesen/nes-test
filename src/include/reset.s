; reset:

  sei		     ; disable IRQs
	cld		     ; disable decimal mode
	ldx #$40
	stx $4017	 ; disable APU frame IRQ
	ldx #$ff 	 ; Set up stack
	txs		     ;  .
	inx		     ; now X = 0
	stx $2000  ; disable NMI
	stx $2001  ; disable rendering
	stx $4010  ; disable DMC IRQs

wait:
  bit $2002	 ; Wait for V-Blank
	bpl wait

clear_memory:
	lda	#$00
	sta	$0000, x
	sta	$0100, x
	sta	$0300, x
	sta	$0400, x
	sta	$0500, x
	sta	$0600, x
	sta	$0700, x
	lda	#$fe
	sta	$0200, x	; move all sprites off screen
	inx
	bne	clear_memory

wait2:
  bit $2002  ; Wait for V-Blank
	bpl wait2

clear_nametables:
	lda	$2002		; read PPU status to reset the high/low latch
	lda	#$20		; write the high byte of $2000
	sta	$2006		;  .
	lda	#$00		; write the low byte of $2000
	sta	$2006		;  .
	ldx	#$08		; prepare to fill 8 pages ($800 bytes)
	ldy	#$00		;  x/y is 16-bit counter, high byte in x
	lda	#$27		; fill with tile $27 (a solid box)

  @loop:
  	sta	$2007
  	dey
  	bne	@loop
  	dex
  	bne	@loop
