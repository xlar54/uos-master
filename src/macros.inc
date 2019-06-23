HiresInit .macro

    JSR InitGr

.endm

HiresOn .macro fgcol, bcol

    LDA #(\fgcol * 16 + \bcol)
    JSR GRON

.endm

HiresOff .macro

    lda #$93
    jsr CHROUT
    jsr GROFF

.endm

PenWrite .macro

    LDA #$01
    JSR SETCOLOR

.endm

PenErase .macro

    LDA #$00
    JSR SETCOLOR

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

        jsr GPLOT
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

        jsr LINE
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

LoadB .macro addr, val

    lda #\val
    sta \addr
.endm

AddB .macro addr, val

    lda \addr
    clc
    adc #\val
    sta \addr
.endm