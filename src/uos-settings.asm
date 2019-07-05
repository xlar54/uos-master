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

* = APP_START

    #RegisterApp

    #DrawRect 80,70,239,140,0
    #DrawRect 80,70,239,84,0
    #CreateButton 1,0,<ON_CLOSE, >ON_CLOSE,224,70,239,84
    #Text 88,74, title
    #Text 229,73, x
    ;#DrawLine 132,72,224,72
    #DrawLine 132,74,224,74
    #DrawLine 132,76,224,76
    #DrawLine 132,78,224,78
    #DrawLine 132,80,224,80
    ;#DrawLine 132,82,224,82

    jmp MAINLOOP

title:  .text "Settings", $00
x:      .text "x", $00

ON_CLOSE = *
    #UnregisterApp
    jsr FETCHBITMAP
    #RemoveButton 1,0
    jmp MAINLOOP

