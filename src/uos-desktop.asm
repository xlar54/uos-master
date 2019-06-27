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
        #DrawLine 25, 189, 25, 199
        #DrawRect 100,70,219,140,1
        #DrawRect 180,120,210,130,0

        #Print $00, $70, $50, msg1
        #Print $00, $70, $5b, msg2
        #Print $00, $70, $65, msg3

        #Print $00, $bd, $7a, ok

        #Print $00, $05, $bf, menu
        #Print $01, $17, $bf, time

        RTS

* = APP_CLICK
        #PenErase
        #DrawRect 100,70,219,140,1
        RTS

;WAIT     JSR GETIN
;         BEQ WAIT
;         RTS

msg1:   .text "UOS - Ultimate OS", $00
msg2:   .text "Version Alpha", $00
msg3:   .text "Scott Hutter", $00
ok:     .text "OK", $00
time:   .text "8:34 PM", $00

menu:
        .text "uos", $00