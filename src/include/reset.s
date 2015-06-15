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

@wait:
  bit $2002	 ; Wait for V-Blank
	bpl @wait

@clear:
  lda #$00 	; Clear RAM
	sta $0000, x
	sta $0100, x
	sta $0200, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	inx
	bne @clear

@wait2:
  bit $2002  ; Wait for V-Blank
	bpl @wait2

;@clear_palette:
	;; Need clear both palettes to $00. Needed for Nestopia. Not
	;; needed for FCEU* as they're already $00 on powerup.
;	lda	$2002		; Read PPU status to reset PPU address
;	lda	#$3f		; Set PPU address to BG palette RAM ($3F00)
;	sta	$2006
;	lda	#$00
;	sta $2006
;	ldx	#$20		; Loop $20 times (up to $3F20)
;	lda	#$00		; Set each entry to $00

;@loop:
;	sta	$2007
;	dex
;	bne	@loop
