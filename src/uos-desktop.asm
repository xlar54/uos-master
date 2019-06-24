;==========================================================================
; UOS
; Scott Hutter
;==========================================================================

.include "uos.inc"
.include "kernal.inc"
.include "vic-ii.inc"
.include "macros.inc"

* = APP_START

        #PenWrite
        #DrawLine 0,190,319,190
        #DrawRect 100,70,219,140,1


        #LoadB X1, $70
        #LoadB X1+1, $00
        #LoadB Y1, $50
        lda #'h'
        jsr GPUTC

        #LoadB X1, $7A
        #LoadB X1+1, $00
        #LoadB Y1, $50
        lda #'e'
        jsr GPUTC

        #LoadB X1, $84
        #LoadB X1+1, $00
        #LoadB Y1, $50
        lda #'l'
        jsr GPUTC

        #LoadB X1, $8e
        #LoadB X1+1, $00
        #LoadB Y1, $50
        lda #'l'
        jsr GPUTC

        #LoadB X1, $98
        #LoadB X1+1, $00
        #LoadB Y1, $50
        lda #'o'
        jsr GPUTC

        RTS

* = APP_CLICK
        #PenErase
        #DrawRect 100,70,219,140,1
        RTS

;WAIT     JSR GETIN
;         BEQ WAIT
;         RTS
