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


* = APP_START

        #RegisterApp

        #PenWrite
        #DrawLine 0,189,319,189
        
        #CreateButton 0, 0, <MNU_ULTOS, >MNU_ULTOS, 0,189,30,199
        #Text 5, 191, mnu_main
        
        #Text 279, 191, time
        
        jsr SAVEBITMAP

        RTS

WIN_OK = *
        jsr FETCHBITMAP
        #RemoveButton 0,1
        jmp MAINLOOP

MENU_FILEMGR = *
        jsr closemenu
        #DrawRect 100,70,219,140,1       
        #Text 112, 80, dlg_fileman

        #CreateButton 0,1,<WIN_OK, >WIN_OK,180,120,210,130
        #Text 189, 122, ok

        jmp MAINLOOP

MENU_SETTINGS = *
        jsr closemenu
        #DrawRect 100,70,219,140,1       
        #Text 112, 80, dlg_settings

        #CreateButton 0,1,<WIN_OK, >WIN_OK,180,120,210,130
        #Text 189, 122, ok

        jmp MAINLOOP

MENU_CMDLN = *
        jsr closemenu
        #DrawRect 100,70,219,140,1       
        #Text 112, 80, dlg_cmd

        #CreateButton 0,1,<WIN_OK, >WIN_OK,180,120,210,130
        #Text 189, 122, ok

        jmp MAINLOOP

MENU_QUIT = *
        jsr closemenu
        #DrawRect 100,70,219,140,1       
        #Text 112, 80, dlg_quit

        top := 120
        left := 180
        width := 30
        height := 10
        #CreateButton 0,1,<QUIT_YES, >QUIT_YES, left, top, left + width, top + height
        #Text 189, 122, yes

        top := 120
        left := 140
        width := 30
        height := 10
        #CreateButton 0,2,<QUIT_NO, >QUIT_NO, left, top, left + width, top + height
        #Text 148, 122, no 

        jmp MAINLOOP

QUIT_YES:
        jmp $fce2

QUIT_NO:
        jsr FETCHBITMAP
        #RemoveButton 0,1
        #RemoveButton 0,2
        jmp MAINLOOP


MNU_ULTOS = *
        lda menuopen
        beq _openmenu

_farclosemenu:
        jsr closemenu
        jmp MAINLOOP

_openmenu:
        jsr SAVEBITMAP
        lda #$01
        sta menuopen
        
        height := 14
        left := 0
        width := 75
        top := 119

        #CreateButton 0, 1, <MENU_FILEMGR,  >MENU_FILEMGR, left, top + (height * 1), width, (top + height) + (height*1)
        #Text left + 5, top + 4 + (height * 1), mnu_fileman
        #CreateButton 0, 2, <MENU_SETTINGS, >MENU_SETTINGS,left, top + (height * 2), width, (top + height) + (height*2)
        #Text left + 5, top + 4 + (height * 2), mnu_settings
        #CreateButton 0, 3, <MENU_CMDLN,    >MENU_CMDLN   ,left, top + (height * 3), width, (top + height) + (height*3)
        #Text left + 5, top + 4 + (height * 3), mnu_cmdline
        #CreateButton 0, 4, <MENU_QUIT,     >MENU_QUIT    ,left, top + (height * 4), width, (top + height) + (height*4)
        #Text left + 5, top + 4 + (height * 4), mnu_quit

        jmp MAINLOOP

closemenu:
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

dlg_fileman:    .text "File manager", $00
dlg_settings:   .text "Settings", $00
dlg_cmd:        .text "Cmd Line", $00
dlg_quit:       .text "Quit: Are you sure?", $00

mnu_fileman:    .text "file manager", $00
mnu_quit:       .text "quit", $00
mnu_settings:   .text "settings", $00
mnu_cmdline:    .text "command line", $00
mnu_main:       .text "ultos", $00

time:           .text "8:34 PM", $00

yes:    .text "Yes", $00
no:     .text "No", $00
ok:     .text "Ok", $00
cancel: .text "Cancel", $00

menuopen:
        .byte $00