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

DrawImage .macro x, y, width, height, img 

    lda #<\img
    sta r4L
    lda #>\img
    sta r4H

    width := \width / 8
    height := \height / 2
    tempx := \x
    
    .for ty := 0, ty < height, ty := ty + 1

        .for tx := 0, tx < width, tx := tx + 1

            .if tempx > 255
                    lda #$01
                    sta X1+1
                    lda #tempx-256
            .else
                    lda #$00
                    sta X1+1
                    lda #tempx
            .fi

            sta X1

            lda #\y+ty
            sta Y1

            jsr GFX_DRAWBYTEPATTERN
            
            lda r4L                 ; increment next data byte pointer
            clc
            adc #$01
            sta r4L
            bcc +
            inc r4H
+                      
            tempx := tempx + 8

        .next

        tempx := \x
    .next
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


DrawRect .macro x, y, width, height, shadow

    ; top/bottom 
    #DrawLine \x, \y, \x + \width, \y
    #DrawLine \x, \y + \height, \x + \width, \y + \height

    ; left / right
    #DrawLine \x, \y, \x, \y + \height
    #DrawLine \x + \width, \y, \x + \width, \y + \height

.if \shadow = 1
    ; bottom shadow
    #DrawLine \x+5, \y+\height+1, \x+\width+5, \y+\height+1
    #DrawLine \x+5, \y+\height+2, \x+\width+5, \y+\height+2
    #DrawLine \x+5, \y+\height+3, \x+\width+5, \y+\height+3
    #DrawLine \x+5, \y+\height+4, \x+\width+5, \y+\height+4
    #DrawLine \x+5, \y+\height+5, \x+\width+5, \y+\height+5
    
    ; right shadow
    #DrawLine \x+\width+1, \y+5, \x+\width+1, \y+\height+5
    #DrawLine \x+\width+2, \y+5, \x+\width+2, \y+\height+5
    #DrawLine \x+\width+3, \y+5, \x+\width+3, \y+\height+5
    #DrawLine \x+\width+4, \y+5, \x+\width+4, \y+\height+5
    #DrawLine \x+\width+5, \y+5, \x+\width+5, \y+\height+5
.fi

.endm


CreateButton .macro appid, btnid, lo, hi, x1, y1, x2, y2, border

    .if \border == true
        ; top/bottom 
        #DrawLine \x1, \y1, \x2, \y1
        #DrawLine \x1, \y2, \x2, \y2

        ; left / right
        #DrawLine \x1, \y1, \x1, \y2
        #DrawLine \x2, \y1, \x2, \y2
    .endif

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

UnregisterApp .macro
    dec APP_ID_TBL
    lda APP_ID_TBL
.endm

SaveScreen .macro
    lda #$00
    jsr FS_SCREEN
.endm

FetchScreen .macro
    lda #$01
    jsr FS_SCREEN
.endm

SaveRect .macro x, y, width, height

    exploc      := 0
    firstrow    := \y / 8
    lastrow     := firstrow + ((\y + \height) / 8)
    row         := 0
    col         := (\x / 8)
    memsz       := (((\x + \width) / 8) * 8) + 8

    .for row := firstrow, row <= lastrow, row := row + 1 

        memloc := BITMAP_START + (row * 320) + (col * 8)

        lda #<memloc
        sta r0L
        lda #>memloc
        sta r0H
        lda #<exploc
        sta r1L
        lda #>exploc
        sta r1H
        lda #<memsz
        sta r2L
        lda #>memsz
        sta r2H

        lda #$00
        jsr FS_RECT

        exploc := exploc + memsz + 1
    .next

.endm

FetchRect .macro x, y, width, height

    exploc      := 0
    firstrow    := \y / 8
    lastrow     := firstrow + ((\y + \height) / 8)
    row         := 0
    col         := (\x / 8)
    memsz       := (((\x + \width) / 8) * 8) + 8

    .for row := firstrow, row <= lastrow, row := row + 1 

        memloc := BITMAP_START + (row * 320) + (col * 8)

        lda #<memloc
        sta r0L
        lda #>memloc
        sta r0H
        lda #<exploc
        sta r1L
        lda #>exploc
        sta r1H
        lda #<memsz
        sta r2L
        lda #>memsz
        sta r2H

        lda #$01
        jsr FS_RECT

        exploc := exploc + memsz + 1
    .next

.endm

ClrRect .macro x, y, width, height

    exploc      := 0
    firstrow    := \y / 8
    lastrow     := (\y + \height) / 8
    row         := 0
    col         := (\x / 8)
    lastcol     := col + (\width / 8) + 1
    memsz       := (lastcol - col) * 8

    .for row := firstrow, row <= lastrow, row := row + 1 

        memloc := BITMAP_START + (row * 320) + (col * 8)

        lda #<memloc
        sta r0L
        lda #>memloc
        sta r0H
        lda #<exploc
        sta r1L
        lda #>exploc
        sta r1H
        lda #<memsz
        sta r2L
        lda #>memsz
        sta r2H

        jsr CLR_RECT

        exploc := exploc + memsz + 1
    .next

.endm

CreateWindow .macro appId, x, y, width, height, titlebar, title

    #SaveRect \x, \y, \width, \height
    #ClrRect \x, \y,\width, \height

    #DrawRect \x,\y,\width,\height,0

    .if \titlebar == true
        #DrawLine \x,\y+14,\x+\width,\y+14
        #CreateButton \appId,0,<ON_CLOSE, >ON_CLOSE,\x+\width-15,\y,\x+\width,\y+14,1
        #Text \x+8,\y+4, \title
        #Text \x+\width-10,\y+3, x

        #DrawLine \x+52,\y+4,\x+\width-15,\y+4
        #DrawLine \x+52,\y+6,\x+\width-15,\y+6
        #DrawLine \x+52,\y+8,\x+\width-15,\y+8
        #DrawLine \x+52,\y+10,\x+\width-15,\y+10
    .endif

    ; window ID
    lda #$00

.endm

CloseWindow .macro windowId, x, y, width, height

    ; find window
    #FetchRect \x, \y, \width, \height

    ; ...destroy child controls

.endm