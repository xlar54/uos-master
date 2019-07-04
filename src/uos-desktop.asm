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

        #RegisterApp

        #PenWrite
        #DrawLine 0,189,319,189
        
        #CreateButton 0, 0, <MNU_ULTOS, >MNU_ULTOS, 0,189,30,199
        #Text $00, $05, $bf, menu
        
        #Text $01, $17, $bf, time
        
        jsr SAVEBITMAP

        RTS

WIN_OK = *
        jsr FETCHBITMAP
        #RemoveButton 0,1
        jmp MAINLOOP

MNU_FILEMGR = *
        jsr _closemenu
        #DrawRect 100,70,219,140,1       
        #Text $00, $70, $50, mnu1

        #CreateButton 0,1,<WIN_OK, >WIN_OK,180,120,210,130
        #Text $00, $bd, $7a, ok

        jmp MAINLOOP

MNU_SETTINGS = *
        jsr _closemenu
        #DrawRect 100,70,219,140,1       
        #Text $00, $70, $50, mnu2

        #CreateButton 0,1,<WIN_OK, >WIN_OK,180,120,210,130
        #Text $00, $bd, $7a, ok

        jmp MAINLOOP

MNU_CMDLN = *
        jsr _closemenu
        #DrawRect 100,70,219,140,1       
        #Text $00, $70, $50, mnu3

        #CreateButton 0,1,<WIN_OK, >WIN_OK,180,120,210,130
        #Text $00, $bd, $7a, ok

        jmp MAINLOOP

MNU_QUIT = *
        jsr _closemenu
        #DrawRect 100,70,219,140,1       
        #Text $00, $70, $50, mnu4

        #CreateButton 0,1,<WIN_OK, >WIN_OK,180,120,210,130
        #Text $00, $bd, $7a, ok

        jmp MAINLOOP

MNU_ULTOS = *
        lda menuopen
        beq _openmenu

_farclosemenu:
        jsr _closemenu
        jmp MAINLOOP

_openmenu:
        jsr SAVEBITMAP
        lda #$01
        sta menuopen
        
        yoffset := 14
        width := 75
        menuTopY := 119

        #CreateButton 0, 1, <MNU_FILEMGR,  >MNU_FILEMGR, 0, menuTopY + (yoffset * 1), width, (menuTopY + yoffset) + (yoffset*1)
        #Text $00, $05, $7b + (yoffset * 1), fileman
        #CreateButton 0, 2, <MNU_SETTINGS, >MNU_SETTINGS,0, menuTopY + (yoffset * 2), width, (menuTopY + yoffset) + (yoffset*2)
        #Text $00, $05, $7b + (yoffset * 2), settings
        #CreateButton 0, 3, <MNU_CMDLN,    >MNU_CMDLN   ,0, menuTopY + (yoffset * 3), width, (menuTopY + yoffset) + (yoffset*3)
        #Text $00, $05, $7b + (yoffset * 3), cmdline
        #CreateButton 0, 4, <MNU_QUIT,     >MNU_QUIT    ,0, menuTopY + (yoffset * 4), width, (menuTopY + yoffset) + (yoffset*4)
        #Text $00, $05, $7b + (yoffset * 4), quit

        jmp MAINLOOP

_closemenu:
        jsr FETCHBITMAP
nop
        #RemoveButton 0,1
        #RemoveButton 0,2
        #RemoveButton 0,3
        #RemoveButton 0,4

        lda #$00
        sta menuopen
        rts

;WAIT     JSR GETIN
;         BEQ WAIT
;         RTS

mnu1:   .text "File manager", $00
mnu2:   .text "Settings", $00
mnu3:   .text "Cmd Line", $00
mnu4:   .text "Quit", $00
ok:     .text "OK", $00
time:   .text "8:34 PM", $00
quit:   .text "quit", $00
settings .text "settings", $00
fileman .text "file manager", $00
cmdline .text "command line", $00
menu:   .text "ultos", $00

menuopen:
        .byte $00