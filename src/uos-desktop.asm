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
        lda #<msg
        sta r1
        lda #>msg
        sta r2
        jsr GPUTS
        

        RTS

* = APP_CLICK
        #PenErase
        #DrawRect 100,70,219,140,1
        RTS

;WAIT     JSR GETIN
;         BEQ WAIT
;         RTS

msg:
        .text "Hello world", $00