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

        
        LoadB X1, $00
        LoadB X1+1, $01
        LoadB Y1, $0a
        lda #'X'
        jsr GPRINT

        ;LoadB X1, $fd
        ;LoadB X1+1, $00
        ;LoadB Y1, $0a
        ;lda #'y'
        ;jsr GPRINT

        RTS

* = APP_CLICK
        #PenErase
        #DrawRect 100,70,219,140,1
        RTS

;WAIT     JSR GETIN
;         BEQ WAIT
;         RTS