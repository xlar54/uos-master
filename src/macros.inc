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

add .macro source
	clc
	adc \source
.endm

sub .macro source
	sec
	sbc \source
.endm

addv .macro value
	clc
	adc #\value
.endm

subv .macro value
	sec
	sbc #\value
.endm

PopB .macro dest
	pla
	sta \dest
.endm

PopW .macro dest
	PopB \dest+0
	PopB \dest+1
.endm

PushB .macro source
	lda \source
	pha
.endm

PushW .macro source
	PushB \source+1
	PushB \source+0
.endm

SubB .macro source, dest
	lda \dest
	sub \source
	sta \dest
.endm

SubW .macro source, dest
	SubB \source+0, \dest+0
	lda \dest+1
	sbc \source+1
	sta \dest+1
.endm

SubVW .macro value, dest
	sec
	lda \dest+0
	sbc #<(\value)
	sta \dest+0
	lda \dest+1
	sbc #>(\value)
	sta \dest+1
.endm

LoadB .macro addr, val
    lda #\val
    sta \addr
.endm

CopyW .macro src, dest
    lda \src
    sta \dest
    lda \src+1
    sta \dest+1
.endm

AddW .macro addr1, addr2
    lda \addr1
    clc
    adc \addr2
    sta \addr2
    bcs _inchi
    jmp _skip
_inchi:
    inc \addr2+1
_skip:
    nop
.endm

AddX .macro val

    lda tempx
    clc
    adc #\val
    bcs _incx
    sta tempx
    jmp _endm
_incx:
    sta tempx
    lda #$01
    sta tempx+1
_endm:
    nop
.endm

HiresInit .macro

    JSR GFX_INIT

.endm

HiresOn .macro fgcol, bcol

    LDA #(\fgcol * 16 + \bcol)
    JSR GFX_ON

.endm

HiresOff .macro

    lda #$93
    jsr CHROUT
    jsr GFX_OFF

.endm

PenWrite .macro

    LDA #$01
    JSR GFX_SETCOLOR

.endm

PenErase .macro

    LDA #$00
    JSR GFX_SETCOLOR

.endm

SetPixel .macro x, y
.if \x > 255
        lda #$01
        sta X1+1
        lda #\x-256
.else
        lda #$00
        sta X1+1
        lda #\x
.fi
        sta X1

        lda #\y
        sta Y1
        
        lda #$00
        sta Y1+1

        jsr GFX_SETPIXEL
.endm

DrawLine .macro x1, y1, x2, y2
.if \x1 > 255
        lda #$01
        sta X1+1
        lda #\x1-256
.else
        lda #$00
        sta X1+1
        lda #\x1
.fi
        sta X1

.if \x2 > 255
        lda #$01
        sta X2+1
        lda #\x2-256
.else
        lda #$00
        sta X2+1
        lda #\x2
.fi
        sta X2

        lda #\y1
        sta Y1
        lda #\y2
        sta Y2
        
        lda #$00
        sta Y1+1
        sta Y2+1

        jsr GFX_LINE
.endm


DrawRect .macro x1, y1, x2, y2, shadow

    ; top/bottom 
    #DrawLine \x1, \y1, \x2, \y1
    #DrawLine \x1, \y2, \x2, \y2

    ; left / right
    #DrawLine \x1, \y1, \x1, \y2
    #DrawLine \x2, \y1, \x2, \y2

.if \shadow = 1
    ; bottom shadow
    #DrawLine \x1+5, \y2+1, \x2+5, \y2+1
    #DrawLine \x1+5, \y2+2, \x2+5, \y2+2
    #DrawLine \x1+5, \y2+3, \x2+5, \y2+3
    #DrawLine \x1+5, \y2+4, \x2+5, \y2+4
    #DrawLine \x1+5, \y2+5, \x2+5, \y2+5
    
    ; right shadow
    #DrawLine \x2+1, \y1+5, \x2+1, \y2+5
    #DrawLine \x2+2, \y1+5, \x2+2, \y2+5
    #DrawLine \x2+3, \y1+5, \x2+3, \y2+5
    #DrawLine \x2+4, \y1+5, \x2+4, \y2+5
    #DrawLine \x2+5, \y1+5, \x2+5, \y2+5
.fi

.endm

ClearRect .macro x1, y1, x2, y2
    #PenErase

.for y := \y1, y <= \y2, y := y + 1
    #DrawLine \x1, y, \x2, y
.next

    #PenWrite

.endm

CreateButton .macro appid, btnid, lo, hi, x1, y1, x2, y2

    ; top/bottom 
    #DrawLine \x1, \y1, \x2, \y1
    #DrawLine \x1, \y2, \x2, \y2

    ; left / right
    #DrawLine \x1, \y1, \x1, \y2
    #DrawLine \x2, \y1, \x2, \y2

    ; find spot for control
    lda #$ff
    sta r1
    sta r2
    jsr FIND_CTL

    ; store the app id
    ldy #$00
    lda #\appid
    sta (r3),y
    iny

    ; store the button id
    lda #\btnid
    sta (r3),y
    iny

    ; store the callback address
    lda #\lo
    sta (r3),y
    iny

    lda #\hi
    sta (r3),y
    iny

    ; store x/y

.if \x1 > 255
    lda #\x1-256
    sta (r3),y
    iny
    lda #$01
    sta (r3),y
    iny
.else
    lda #\x1
    sta (r3),y
    iny
    lda #$00
    sta (r3),y
    iny
.fi

    lda #\y1
    sta (r3),y
    iny

.if \x2 > 255
    lda #\x2-256
    sta (r3),y
    iny
    lda #$01
    sta (r3),y
    iny
.else
    lda #\x2
    sta (r3),y
    iny
    lda #$00
    sta (r3),y
    iny
.fi

    lda #\y2
    sta (r3),y
    iny

    inc APP_CTL_CTR

.endm

RemoveButton .macro appId, btnId

    lda #\appId
    sta r1
    lda #\btnId
    sta r2
    jsr FIND_CTL
    lda r3H
    beq _didntfindit
    ldy #$00
    lda #$ff
    sta (r3),y
    iny
    sta (r3),y
    dec APP_CTL_CTR
_didntfindit:

.endm

Text .macro x, y, msg

    ; store x/y
.if \x > 255
    lda #\x-256
    sta X1
    lda #$01
    sta X1+1
    iny
.else
    lda #\x
    sta X1
    lda #$00
    sta X1+1
    iny
.fi

    lda #\y
    sta Y1

    lda #<\msg
    sta r9L
    lda #>\msg
    sta r9H
    jsr GPUTS

.endm

RegisterApp .macro
    inc APP_ID_TBL
    lda APP_ID_TBL
.endm

