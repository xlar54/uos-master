;==========================================================================
; UltOS
; Scott Hutter
;
;   This file is part of UltOS.
;
;    UltOS is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    UltOS is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with UltOS.  If not, see <https://www.gnu.org/licenses/>.
;==========================================================================

.include "equates.inc"
.include "routines.inc"
.include "macros.inc"
.include "kernal.inc"
.include "vic-ii.inc"
.include "io.inc"


* = $0801    ;start of BASIC area
; ==========================================================
; BASIC Loader
; ==========================================================
.byte $0C, $08      ; pointer to next GFX_LINE
.byte $0A, $00      ; GFX_LINE number (10)
.byte $9E           ; SYS token
.text " 2062"       ; SYS address in ASCII
.byte $00, $00, $00 ; end-of-program

        jmp START
        jmp main_loop   ; main loop entry
        jmp find_control
        jmp FETCH_STASH_APP
        jmp FETCH_STASH_SCREEN
        jmp FETCH_STASH_RECT
        jmp CLEAR_RECT
        jmp LOADIMM
        jmp LOADER

; ==========================================================
; START
; Initialize the system
; ==========================================================
START:
        LDA #$12	; Load clock registers with inital time
	STA TODHRS	; Store 12 in hour  (Bit 7=PM)
	LDA #$00
	STA TODMIN	; Store 0 in minutes
	LDA #$00
	STA TODSEC	; Store 0 in seconds
	LDA #$00
	STA TODTEN	; Store 0 in tenth of a second
			; Clock starts after writing to this register

        lda #$01
        sta r16         ; second register test

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

; ==========================================================
; Load Files
; Load the ML subsystems, base drivers, and data
; ==========================================================
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
	    .text "uos-reu",$00
        jsr LOADER

        JSR LOADIMM
	    .text "uos-desktop",$00
        jsr LOADER

; ==========================================================
; Setup
; Various post loading initialization code
; ==========================================================
setup:
        #HiresInit
        #HiresOn VIC_COLOR_BLACK, VIC_COLOR_CYAN

        ; point brk vector to our routine
        sei
        lda #<SYSERR
        sta brkVectorlo
        lda #>SYSERR
        sta brkVectorhi
        cli

        ; clear app id table
        lda #$ff 
        sta APP_ID_TBL

        jsr SETUP_CTL_BUF

        ; enable sprite 0
        lda #$01    
        sta VIC_BASE + VIC_SPR_ENBL
        
        ;color
        lda #VIC_COLOR_WHITE  
        sta VIC_BASE + VIC_SPR_COL0   
        
        ; sprite 0 data pointer  
        lda #$00        ; $8000 = sprite table
        sta $87f8   
        
        ; sprite 0 x/y location
        lda #$80    
        sta VIC_BASE + VIC_SPR0_X
        sta VIC_BASE + VIC_SPR0_Y

        ; disable basic rom
        lda #$35
        sta $01

        ; stash the empty screen
        lda #<BITMAP_START              ; source addr
        sta REU_PARAMS
        lda #>BITMAP_START
        sta REU_PARAMS+1
        lda #<$0000                     ; expanson ram addr
        sta REU_PARAMS+2                
        lda #>$0000
        sta REU_PARAMS+3
        lda #$00                        ; bank 0
        sta REU_PARAMS+4                ; expansion bank #
        lda #<$2000                     ; bytes to move  (8192)       
        sta REU_PARAMS+5
        lda #>$2000
        sta REU_PARAMS+6
        jsr REU_STASH

        ; set up the mouse irq
        jsr INIT_MOUSE

        ; start the application
        jsr DESK_START

; ==========================================================
; Main input waiting loop
; ==========================================================
main_loop:
        jsr TICK

        ;read input driver
        lda $dc01
        and #$10
        beq btnclick
        jmp main_loop
btnclick:
        ; check for drag operation
        inc mousedowntime
        bne _keepwaiting
        inc mousedowntime+1
        lda mousedowntime+1
        cmp #$20                ; just check if mouse down for a certain length of time
        bne _keepwaiting
        jsr dragmode
_keepwaiting:
        ; wait for mouse up
        lda $dc01
        and #$10
        beq btnclick
        jsr normalmode
        jsr TESTCLICK
        bne goodclick
        jmp next
goodclick:
        jmp (r4L)
next:
        jmp main_loop
 
dragmode:
        ; sprite 0 data pointer  
        lda #$01        ; $8000 = sprite table
        sta $87f8
        rts

normalmode:
        lda #$00
        sta mousedowntime
        sta mousedowntime + 1
        ; sprite 0 data pointer  
        lda #$00        ; $8000 = sprite table
        sta $87f8
        rts

mousedowntime:
        .byte $00, $00

; ==========================================================
; Find Control
; r1 = app id to find 
; r2 = control id to find
;
; returns
; r3H = high address of control
; r3L = lo address of control
; ==========================================================
find_control:
        lda #<APP_CTL_BUF
        sta r3L
        lda #>APP_CTL_BUF
        sta r3H

        ldy #$00
        ldx #$00
 _loop:
        lda r3H
        cmp #>APP_ID_TBL
        beq _notfound  
_skip:
        lda (r3),y      
        cmp r1         ; check app id
        beq _foundappid
        bne _skip9

_foundappid:
        iny
        lda (r3),y      ; get 1st byte
        cmp r2         ; compare to the id we want
        beq _foundctlid
        dey             ; not same app id
        lda r3L
        clc
        adc #$0a        ; skip 10 bytes
        bcc _cont
        inc r3H         ; if so, increase hi byte
_cont:
        sta r3L         ; increase lo byte
        jmp _loop       ; do it again

_skip9:
        lda r3L
        clc
        adc #$0a
        bcc _cont2
        inc r3H         ; if so, increase hi byte
_cont2:
        sta r3L         ; increase lo byte
        jmp _loop       ; do checks again

_foundctlid:
        rts
        
_notfound:
        lda #$00
        sta r3H
        sta r3L
        rts

; ==========================================================
; Quit to BASIC
; ==========================================================
TOBASIC:
        #HiresOff

        lda #$01    
        sta VIC_BASE + VIC_SPR_ENBL
        RTS

; ==========================================================
; File Loader
; Equivalent to LOAD"file",8,1
; ==========================================================
LOADER:
        LDY #$00        ; print file name being loaded
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

; ==========================================================
; Load Immediate
; Like a PRIMM subroutine, this will load the file
; following the jsr call
; ==========================================================
LOADIMM:
	PHA     		; save A
	TYA			; copy Y
	PHA  			; save Y
	TXA			; copy X
	PHA  			; save X
	TSX			; get stack pointer
	LDA $0104,X		; get return address low byte (+4 to correct pointer)
	STA $BC			; save in page zero
	LDA $0105,X		; get return address high byte (+5 to correct pointer)
	STA $BD			; save in page zero
	LDY #$01		; set index (+1 to allow for return address offset)
LOADIMM2:
	LDA ($BC),Y		; get byte from string
	BEQ LOADIMM3	        ; exit if null (end of text)

	;JSR CHAROUT	        ; else display character
        DEY
	STA file,Y
        INY
        TYA
        STA ftmp

        INY			; increment index
	BNE LOADIMM2	        ; loop (exit if 256th character)

LOADIMM3:
	TYA                     ; copy index
	CLC			; clear carry
	ADC $BC			; add string pointer low byte to index
	STA $0104,X		; put on stack as return address low byte
				; (+4 to correct pointer, X is unchanged)
	LDA #$00		; clear A
	ADC $BD		        ; add string pointer high byte
	STA $0105,X		; put on stack as return address high byte
				; (+5 to correct pointer, X is unchanged)
	PLA			; pull value
	TAX  			; restore X
	PLA			; pull value
	TAY  			; restore Y
	PLA  			; restore A
	RTS

; ==========================================================
; Test click
; Checked whenever a mouse click occurs
; ==========================================================
TESTCLICK:
        ldx #$00
        lda APP_CTL_CTR
        sta r1

_loopbtns:
        bne _storemeta
        jmp _badclick

_storemeta:

        ; get app id
        lda APP_CTL_BUF,x
        sta r2

        ; get button id
        lda APP_CTL_BUF+1,x
        sta r3

        ; get callback address
        lda APP_CTL_BUF+2, x
        sta r4L

        lda APP_CTL_BUF+3, x
        sta r4H

        ; check if click is on button
_x1a:
        lda VIC_BASE + VIC_SPR0_X
        sec
        sbc #$18
        clc
        cmp APP_CTL_BUF+4,x
        bcc _fardone1

_x1b:
        lda VIC_BASE + VIC_SPR_XMSb
        and #%00000001
        cmp APP_CTL_BUF+5,x
        beq _y1
_fardone1:
        jmp _checknextbtn 
_y1:
        lda VIC_BASE + VIC_SPR0_Y
        sec
        sbc #$32
        clc
        cmp APP_CTL_BUF+6,x
        bcs _x2a
        jmp _checknextbtn 

_x2a:
        lda VIC_BASE + VIC_SPR0_X
        sec
        sbc #$18
        sec
        cmp APP_CTL_BUF+7,x
        bcs _fardone2
_x2b:
        lda VIC_BASE + VIC_SPR_XMSb
        and #%00000001
        cmp APP_CTL_BUF+8,x
        beq _y2
_fardone2:
        jmp _checknextbtn 
_y2:
        lda VIC_BASE + VIC_SPR0_Y
        sec
        sbc #$32
        sec
        cmp APP_CTL_BUF+9,x
        bcc _goodclick
        ;jmp _checknextbtn       

_checknextbtn
        txa 
        clc
        adc #$0a
        tax 
        dec r1
        jmp _loopbtns

_goodclick:
        lda #$01
        rts
_badclick:
        lda #$00
        rts 

; ==========================================================
; Clock Tick
; Occurs when 1 second has passed
; Uses cassette buffer for app registered callbacks 
; ==========================================================
TICK:
        lda r16
        ; check if a second has passed
        cmp $DC09
        bne _tick
        jmp _skip
_tick:
        lda $DC09
        sta r16
        lda $033d
        beq _skip
        jmp ($033c)
_skip:
        rts

; ==========================================================
; System Error
; Intercepts the BRK vector and displays a debug msg
; ==========================================================
SYSERR:
        pla 
        pla 
        pla
        pla
        PopW r0
        SubVW 2, r0
        lda r0H
        ldx #0
	jsr er1
        lda r0L
	jsr er1
        #DrawRect 100,70,119,70,1
        ;#DrawImage 112, 85, 24, 44, img_stop
        ;#Text 146, 85, oops
        #Text 112, 85, oops
        #Text 112, 105, panicstr
_forever:
        jmp _forever

er1:	pha
	lsr
	lsr
	lsr
	lsr
	jsr er2
	inx
	pla
	and #%00001111
	jsr er2
	inx
	rts
er2:	cmp #10
	bcs er3
	addv '0'
	bne er4
er3:	addv '0'+7
er4:	sta panicaddr,x
	rts
oops:
        .text "SYSTEM SUSPENDED", $00
panicstr:
        .text "Error near "
        .byte "$"
panicaddr:
	.text "xxxx"
	.byte $00

img_stop:
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%01111110,%00000000
.byte %00000000,%11111111,%00000000
.byte %00000001,%11111111,%10000000
.byte %00000011,%11111111,%11000000
.byte %00000111,%00001010,%01100000
.byte %00000110,%11010100,%10100000
.byte %00000111,%01010100,%01100000
.byte %00000110,%11011010,%11100000
.byte %00000011,%11111111,%11000000
.byte %00000001,%11111111,%10000000
.byte %00000000,%11111111,%00000000
.byte %00000000,%01111110,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000

; ==========================================================
; Set up Control Buffer
; A buffer exists to manage the creation of controls
; (hit spots) on the screen.  This subroutine initializes
; it to it's basic state
; ==========================================================
SETUP_CTL_BUF:
        lda #<APP_CTL_BUF
        sta r1L
        lda #>APP_CTL_BUF
        sta r1H

        lda #>APP_ID_TBL
        sta r2

        ldy #$00
        ldx #$00
 _loop:
        
_skip:
        lda #$ff        ; set app id to $ff
        sta (r1L),y
        
        inc r1L
        jsr _addhi
        lda #$ff        ; set ctl id to $ff
        sta (r1L),y

        inc r1L
        jsr _addhi
        lda #$00 
        sta (r1L),y
        inc r1L
        jsr _addhi
        sta (r1L),y
        inc r1L
        jsr _addhi
        sta (r1L),y
        inc r1L
        jsr _addhi
        sta (r1L),y
        inc r1L
        jsr _addhi
        sta (r1L),y
        inc r1L
        jsr _addhi
        sta (r1L),y
        inc r1L
        jsr _addhi
        sta (r1L),y
        inc r1L
        jsr _addhi
        sta (r1L),y
        inc r1L
        jsr _addhi
        sta (r1L),y

        jmp _loop

 _addhi:
        bne _cont
        inc r1H
        lda r1H        ; if we have reached the end
        cmp r2         ; of control table, exit
        beq _return
        lda #$00
        sta r1L
_cont:
        rts
_return:
        pla             ; break out of inner loop
        pla
        rts

; ==========================================================
; Clear Screen Rectangle
; Fetches from $0000 (bank 0)
;       r0 = 64 address
;       r1 = size in bytes
; ==========================================================
CLEAR_RECT:
        lda r0L                 ; source addr
        sta REU_PARAMS
        lda r0H
        sta REU_PARAMS+1
        lda r1L                        ; expanson ram addr
        sta REU_PARAMS+2
        lda r1H
        sta REU_PARAMS+3
        lda #$00                        ; bank 0
        sta REU_PARAMS+4                ; expansion bank #
        lda r2L                        ; bytes to move         
        sta REU_PARAMS+5
        lda r2H
        sta REU_PARAMS+6
        jsr REU_FETCH
        rts

; ==========================================================
; Fetch or Stash Screen Bitmap
; .a = 0        - Stash
; .a <> 0       - Fetch
; ==========================================================
FETCH_STASH_SCREEN:
        pha
        lda #<BITMAP_START              ; source addr
        sta REU_PARAMS
        lda #>BITMAP_START
        sta REU_PARAMS+1
        lda #<$2000                     ; expanson ram addr
        sta REU_PARAMS+2                ; $2000 - $3fff
        lda #>$2000
        sta REU_PARAMS+3
        lda #$00                        ; bank 0
        sta REU_PARAMS+4                ; expansion bank #
        lda #<$2000                     ; bytes to move  (8192)       
        sta REU_PARAMS+5
        lda #>$2000
        sta REU_PARAMS+6
        pla
        beq _stash
        jsr REU_FETCH
        rts
_stash:
        jsr REU_STASH
        rts

; ==========================================================
; Fetch or Stash App
; .a = 0        - Stash
; .a <> 0       - Fetch
; Saves current app to REU
; ==========================================================
FETCH_STASH_APP:
        pha
        lda #<APP_START                 ; source addr
        sta REU_PARAMS
        lda #>APP_START
        sta REU_PARAMS+1
        lda #$00                        ; expanson ram addr
        sta REU_PARAMS+2                
        lda #$00
        sta REU_PARAMS+3
        lda #$01                        ; bank 1
        sta REU_PARAMS+4                ; expansion bank #
        lda #<(APP_END-APP_START)    ; bytes to move         
        sta REU_PARAMS+5
        lda #>(APP_END-APP_START)
        sta REU_PARAMS+6
        pla
        beq _stash
        jsr REU_FETCH
        jmp MAINLOOP
_stash:
        jsr REU_STASH
        jmp MAINLOOP

; ==========================================================
; Fetch or Stash Screen Rectangle
; .a = 0        - Stash
; .a <> 0       - Fetch
; 
; Saves current app to REU
; ==========================================================
FETCH_STASH_RECT:
        pha
        lda r0L                 ; source addr
        sta REU_PARAMS
        lda r0H
        sta REU_PARAMS+1
        lda r1L                        ; expanson ram addr
        sta REU_PARAMS+2
        lda r1H
        sta REU_PARAMS+3
        lda #$02                        ; bank 2
        sta REU_PARAMS+4                ; expansion bank #
        lda r2L                        ; bytes to move         
        sta REU_PARAMS+5
        lda r2H
        sta REU_PARAMS+6
        pla
        beq _stash
        jsr REU_FETCH
        rts
_stash:
        jsr REU_STASH
        rts

        
