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

        #LoadB X1, $05
        #LoadB X1+1, $00
        #LoadB Y1, $bf
        lda #<menu
        sta r1
        lda #>menu
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

menu:
        .text "uos", $00