;;;;;;;;;;;;;; Header / Startup Code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "HEADER"

  .byte   "NES", $1A      ; iNES header identifier
  .byte   2               ; 2x 16KB PRG code
  .byte   1               ; 1x  8KB CHR data
  .byte   $01, $00        ; mapper 0, vertical mirroring

.segment "STARTUP"

.segment "CODE"

PaletteData:
  .include "include/palette.s"

SpritesData:
  .include "include/sprites.s"


BackgroundData:
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 1
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;row 2
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;;all sky
  .byte $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24  ;;row 3
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;;some brick tops
  .byte $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24  ;;row 4
  .byte $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;;brick bottoms


AttributeData:
	.byte	%00000000, %00010000, %01010000, %00010000
	.byte	%00000000, %00000000, %00000000, %00110000

reset:
  .include "include/reset.s"


main: ; Any initialization code here

  jsr load_palette
  jsr load_sprites
  jsr load_background
  jsr load_attribute

	lda	#%10010000	; enable NMI, sprites from pattern table 0,
	sta	$2000		;  background from pattern table 1
	lda	#%00011110	; enable sprites, enable background,
	sta	$2001		;  no clipping on left

forever: ; Infinite loop, from now on, our program is controlled by the game_loop.
	jmp	forever


;;;;;;;;;;;;;; Subroutines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


load_palette: ; Loads the palette into PPU
  lda	$2002   ; read PPU status to reset the high/low latch
  lda	#$3f
  sta	$2006
  lda	#$00
  sta	$2006
  ldx	#$00

  @loop:
    lda PaletteData, x      ; load data from address (PaletteData + the value in x)
    sta $2007               ; write to PPU
    inx                     ; X = X + 1
    cpx #$20                ; Compare X to hex $20, decimal 32
    bne @loop    ; Branch to @loop if compare was Not Equal to zero
                          ; if compare was equal to 32, return
  rts

load_sprites:
  ldx #$00

  @loop:
    lda SpritesData, x
    sta $0200, x    ; Load tile number in a
    inx
    cpx #$10        ; Length of sprites
    bne @loop

  rts

load_background:

  lda $2002             ; read ppu status to reset the high/low latch
  lda #$20
  sta $2006             ; write the high byte of $2000 address
  lda #$00
  sta $2006             ; write the low byte of $2000 address
  ldx #$00              ; start out at 0

  @loop:
    lda BackgroundData, x     ; load data from address (background + the value in x)
    sta $2007             ; write to ppu
    inx                   ; x = x + 1
    cpx #$80              ; compare x to hex $80, decimal 128 - copying 128 bytes
    bne @loop             ; branch to @loop if compare was not equal to zero
                        ; if compare was equal to 128, return
  rts



load_attribute:
  lda $2002             ; read ppu status to reset the high/low latch
  lda #$23
  sta $2006             ; write the high byte of $23c0 address
  lda #$c0
  sta $2006             ; write the low byte of $23c0 address
  ldx #$00              ; start out at 0

  @loop:
    lda AttributeData, x      ; load data from address (attribute + the value in x)
    sta $2007             ; write to PPU
    inx                   ; x = x + 1
    cpx #$08              ; compare x to hex $08, decimal 8 - copying 8 bytes
    bne @loop

  rts


;;;;;;;;;;;;;; Game Loop (NMI) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This is run 60 times per second. Should contain game logic, rendering etc.
game_loop:

	lda	#$00		; set the low byte (00) of the RAM address
	sta	$2003
	lda	#$02		; set the high byte (02) of the RAM address
	sta	$4014		; start the transfer

  lda #$00    ; Disable background scrolling
  sta $2005
  sta $2005

	rti			; return from interrupt

.segment "VECTORS"
  .word 0, 0, 0, game_loop, reset, 0


.segment "CHARS"
  .incbin "chr/mario.chr"
