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
    #CreateButton 1,0,<ON_CLOSE, >ON_CLOSE,224,70,239,84,1
    #Text 88,74, title
    #Text 229,73, x

    #DrawLine 132,74,224,74
    #DrawLine 132,76,224,76
    #DrawLine 132,78,224,78
    #DrawLine 132,80,224,80

    #CreateButton 1,1,<ON_TIME, >ON_TIME,88,95,88+24,88+44,0
    #DrawImage 88, 95, 24, 44, img_time
    #Text 92,120, btn_time

    #DrawImage 120, 95, 24, 44, img_colors
    #Text 119,120, btn_colors

    jmp MAINLOOP

title:  .text "Settings", $00
x:      .text "x", $00

btn_time:
        .text "time",$00
btn_colors:
        .text "colors", $00

img_time:
    .byte %00000000,%00111100,%00000000
    .byte %00000001,%11000011,%10000000
    .byte %00000111,%00011000,%11100000
    .byte %00001100,%00000000,%00110000
    .byte %00011000,%00000000,%00011000
    .byte %00110000,%00000000,%01001100
    .byte %00100000,%00000000,%10000100
    .byte %00100000,%10000001,%00000100
    .byte %01000000,%01000010,%00000010
    .byte %01000000,%00111100,%00000010
    .byte %01000000,%00011000,%00000010
    .byte %01000000,%00011000,%00000010
    .byte %01000000,%00000000,%00000010
    .byte %00100000,%00000000,%00000100
    .byte %00100000,%00000000,%00000100
    .byte %00110000,%00000000,%00001100
    .byte %00011000,%00000000,%00011000
    .byte %00001100,%00000000,%00110000
    .byte %00000111,%00000000,%11100000
    .byte %00000001,%11000011,%10000000
    .byte %00000000,%00111100,%00000000
    .byte %00000000,%00000000,%00000000

img_colors:
    .byte %00000000,%00000000,%00000000
    .byte %00011111,%11111111,%11110000
    .byte %00011010,%10101010,%10110000
    .byte %00010101,%01010101,%01011000
    .byte %00011010,%10101010,%10111100
    .byte %00010101,%01010101,%01010100
    .byte %00011111,%11111111,%11110100
    .byte %00000000,%00000000,%00000100
    .byte %00000000,%00000000,%00000100
    .byte %00000000,%00001111,%11111000
    .byte %00000000,%00010000,%00000000
    .byte %00000000,%00010000,%00000000
    .byte %00000000,%00010000,%00000000
    .byte %00000000,%00111000,%00000000
    .byte %00000000,%00111000,%00000000
    .byte %00000000,%00111000,%00000000
    .byte %00000000,%00111000,%00000000
    .byte %00000000,%00111000,%00000000
    .byte %00000000,%00111000,%00000000
    .byte %00000000,%00111000,%00000000
    .byte %00000000,%00111000,%00000000
    .byte %00000000,%00000000,%00000000

ON_CLOSE:
    #UnregisterApp
    jsr FETCHBITMAP
    #RemoveButton 1,0
    jmp MAINLOOP

ON_TIME:
    jsr FETCHBITMAP
    #RemoveButton 1,0
    #RemoveButton 1,1

    #DrawRect 100,70,219,140,1       
    #Text 112, 80, dlg_time

    #CreateButton 1,1,<ON_OK, >ON_OK,180,120,210,130,1
    #Text 189, 122, ok

    jmp MAINLOOP

ON_OK = *
    jsr FETCHBITMAP
    #RemoveButton 0,1
    jmp MAINLOOP

dlg_time:       .text "Time", $00
ok:     .text "Ok", $00