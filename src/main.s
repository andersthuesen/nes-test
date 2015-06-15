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

reset:
.include "include/reset.s"




main: ; Any initialization code here

  jsr load_palette
  jsr load_sprites


  lda	#%10000000	; enable NMI, sprites from Pattern Table 0
  sta	$2000

  lda	#%00010000	; enable sprites
  sta	$2001




;;;;;;;;;;;;;; Subroutines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



load_palette: ; Loads the palette into PPU
  ldx #$00    ; Set X = $00
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
    bne @loop    ; Branch to LoadPalettesLoop if compare was Not Equal to zero
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






forever: ; Infinite loop, from now on, our program is controlled by the game_loop.
	jmp	forever


;;;;;;;;;;;;;; Game Loop (NMI) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This is run 60 times per second. Should contain game logic, rendering etc.
game_loop:
	lda	#$00		; set the low byte (00) of the RAM address
	sta	$2003
	lda	#$02		; set the high byte (02) of the RAM address
	sta	$4014		; start the transfer

	rti			; return from interrupt

.segment "VECTORS"
  .word 0, 0, 0, game_loop, reset, 0


.segment "CHARS"
.incbin "chr/mario.chr"
