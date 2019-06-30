;==========================================================================
; UOS
; Scott Hutter
;
;   This file is part of UOS.
;
;    UOS is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    UOS is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with UOS.  If not, see <https://www.gnu.org/licenses/>.
;==========================================================================

.include "equates.inc"
.include "routines.inc"
.include "macros.inc"
.include "kernal.inc"
.include "vic-ii.inc"


* = APP_START

        #PenWrite
        #DrawLine 0,189,319,189
        
        #Button 0,189,30,199
        #Print $00, $05, $bf, menu
        
        #Print $01, $17, $bf, time
        
        jsr SAVEBITMAP

        ;#DrawRect 100,70,219,140,1
        
        ;#Print $00, $70, $50, msg1
        ;#Print $00, $70, $5b, msg2
        ;#Print $00, $70, $65, msg3

        ;#Button 180,120,210,130
        ;#Print $00, $bd, $7a, ok

        RTS

* = APP_CLICK
        ;#PenErase
        ;#DrawRect 100,70,219,140,1

        lda menuopen
        beq _openmenu

_farclosemenu:
        jmp _closemenu

_openmenu:
        jsr SAVEBITMAP
        lda #$01
        sta menuopen

        #Button 0,175,75,189
        #Print $00, $05, $b2, quit
        #Button 0,161,75,175
        #Print $00, $05, $a5, settings
        #Button 0,147,75,161
        #Print $00, $05, $97, fileman

        jmp _done

_closemenu:
        jsr FETCHBITMAP
        lda #$00
        sta menuopen
        

_done:
        RTS

;WAIT     JSR GETIN
;         BEQ WAIT
;         RTS

msg1:   .text "ultOS", $00
msg2:   .text "Version Alpha", $00
msg3:   .text "Scott Hutter", $00
ok:     .text "OK", $00
time:   .text "8:34 PM", $00
quit:   .text "quit", $00
settings .text "settings", $00
fileman .text "file manager", $00
menu:   .text "ultos", $00

menuopen:
        .byte $00