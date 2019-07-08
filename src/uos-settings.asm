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

    #CreateWindow 1,72,64,143,96,true,title

    #CreateButton 1,1,<ON_TIME, >ON_TIME,88,95,88+24,88+44,false
    #DrawImage 88, 95, 24, 44, img_time
    #Text 92,120, btn_time

    #DrawImage 120, 95, 24, 44, img_colors
    #Text 119,120, btn_colors

    #DrawImage 152, 95, 24, 44, img_drives
    #Text 152,120, btn_drives

    jmp MAINLOOP

title:  .text "Settings", $00
x:      .text "x", $00

btn_time:
        .text "time",$00
btn_colors:
        .text "colors", $00
btn_drives:
        .text "drives", $00

.include "icons_settings.inc"

ON_CLOSE:
    #UnregisterApp
    #CloseWindow 0,72,64,143,96 
    #RemoveButton 1,0
    jmp MAINLOOP

ON_TIME:  
    #RemoveButton 1,0
    #RemoveButton 1,1

    #CreateWindow 1,96,72,119,72,false, 0    
    #Text 112, 80, dlg_time

    #CreateButton 1,1,<ON_OK, >ON_OK,180,120,210,130,true
    #Text 189, 122, ok

    jmp MAINLOOP

ON_OK = *

    #CloseWindow 0, 96,72,119,72   
    #RemoveButton 0,1
    jmp MAINLOOP

dlg_time:       .text "Time", $00
ok:     .text "Ok", $00
