;==========================================================================
; UOS
; Scott Hutter
;==========================================================================

.include "uos.inc"
.include "kernal.inc"
.include "vic-ii.inc"
.include "macros.inc"

* = $0801    ;start of BASIC area

; BASIC Loader

.byte $0C, $08      ; pointer to next line
.byte $0A, $00      ; line number (10)
.byte $9E           ; SYS token
.text " 2062"       ; SYS address in ASCII
.byte $00, $00, $00 ; end-of-program

START:
        lda #$00
        sta VIC_BASE + VIC_BORDER_COL

        lda #$00
        sta VIC_BASE + VIC_BG_COL0

        lda #$93
        jsr CHROUT

_prmsg1
        LDY #$00
_prloop:
        LDA msg1,Y
        BEQ _prdone
        JSR CHROUT
        INY
        JMP _prloop
_prdone:
        LDA #$0D
        JSR CHROUT

        jmp loadfiles

msg1:   .text "booting system...", $0d, $00

loadfiles:
        JSR LOADIMM
	    .text "uos-gfx",$00
        jsr LOADER

        JSR LOADIMM
	    .text "uos-drv1351",$00
        jsr LOADER

        JSR LOADIMM
	    .text "uos-sprites",$00
        jsr LOADER

        JSR LOADIMM
	    .text "uos-desktop",$00
        jsr LOADER

_setup:
        ; set up the graphics and mouse and then jump to the desktop
        jsr install1

        #HiresInit
        #HiresOn VIC_COLOR_DGREY, VIC_COLOR_LGREY

        ; enable sprite 0
        lda #$01    
        sta VIC_BASE + VIC_SPR_ENBL
        
        ;color
        lda #VIC_COLOR_RED  
        sta VIC_BASE + VIC_SPR_COL0   
        
        ; sprite 0 data pointer  
        lda #$00        ; $8000 = sprite table
        sta $87f8   
        
        ; sprite 0 x/y location
        lda #$80    
        sta VIC_BASE + VIC_SPR0_X
        sta VIC_BASE + VIC_SPR0_Y

        jsr APP_START

_mainloop:

        ;read input driver
        lda $dc01
        and #%00010000
        beq _btnclick
        jmp _next

_btnclick:
        jsr APP_CLICK

_next
        jmp _mainloop

TOBASIC:

        #HiresOff

        lda #$01    
        sta VIC_BASE + VIC_SPR_ENBL
        RTS



LOADER:
; Equivalent to LOAD"file",8,1

        LDY #$00
_prloop:
        LDA file,Y
        BEQ _prdone
        JSR CHROUT
        INY
        JMP _prloop
_prdone:
        LDA #$0D
        JSR CHROUT

        LDA ftmp
        LDX #<file
        LDY #>file
        JSR $FFBD     ; call SETNAM
        LDA #$01
        LDX $BA       ; last used device number
        BNE _skip
        LDX #$08      ; default to device 8
_skip   LDY #$01      ; not $01 means: load to address stored in file
        JSR $FFBA     ; call SETLFS

        LDA #$00      ; $00 means: load to memory (not verify)
        JSR $FFD5     ; call LOAD
        BCS _error    ; if carry set, a load error has happened
        RTS
_error
        ; Accumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)

        ;... error handling ...
        RTS

ftmp:   .byte $00
file:   .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
files:  .TEXT "uos-gfx", $00
        .TEXT "uos-drv1351", $00
        .byte $00


LOADIMM:
	PHA     		; save A
	TYA			    ; copy Y
	PHA  			; save Y
	TXA			    ; copy X
	PHA  			; save X
	TSX			    ; get stack pointer
	LDA $0104,X		; get return address low byte (+4 to correct pointer)
	STA $BC			; save in page zero
	LDA $0105,X		; get return address high byte (+5 to correct pointer)
	STA $BD			; save in page zero
	LDY #$01		; set index (+1 to allow for return address offset)
LOADIMM2:
	LDA ($BC),Y		; get byte from string
	BEQ LOADIMM3	; exit if null (end of text)

	;JSR CHAROUT	; else display character
    DEY
	STA file,Y
    INY
    TYA
    STA ftmp
    ;
    INY			    ; increment index
	BNE LOADIMM2	; loop (exit if 256th character)

LOADIMM3:
	TYA			    ; copy index
	CLC			    ; clear carry
	ADC $BC			; add string pointer low byte to index
	STA $0104,X		; put on stack as return address low byte
				    ; (+4 to correct pointer, X is unchanged)
	LDA #$00		; clear A
	ADC $BD		    ; add string pointer high byte
	STA $0105,X		; put on stack as return address high byte
				    ; (+5 to correct pointer, X is unchanged)
	PLA			    ; pull value
	TAX  			; restore X
	PLA			    ; pull value
	TAY  			; restore Y
	PLA  			; restore A
	RTS





