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


* = DESK_START

        #RegisterApp

        lda #<APP_TICK
        sta $033c
        lda #>APP_TICK
        sta $033d

        #PenWrite
        #DrawLine 0,189,319,189
        
        #CreateButton 0, 0, <MNU_ULTOS, >MNU_ULTOS, 0,189,30,199,1
        #Text 5, 191, mnu_main
        
        #Text 282, 191, time

        #DrawImage 10, 5, 24, 44, img_computer
        #Text 5, 25, computer

        #DrawImage 280, 150, 24, 44, img_trash
        #Text 283,174, trash
        
        #SaveScreen
        RTS

computer:
        .text "computer", $00
trash:
        .text "trash", $00

img_computer:
.byte %00000000,%00000000,%00000000
.byte %00000000,%11111111,%11100000
.byte %00000000,%10000000,%00100000
.byte %00000000,%10010111,%00100000
.byte %00000000,%10101010,%10100000
.byte %00000000,%10000000,%00100000
.byte %00000000,%10100000,%00100000
.byte %00000000,%10000000,%00100000
.byte %00000000,%10000000,%00100000
.byte %00000000,%11111111,%11100000
.byte %00000000,%11111111,%01100000
.byte %11111111,%00000000,%00001100
.byte %10000001,%01111111,%11100010
.byte %10100001,%10010101,%01110111
.byte %11111110,%10101010,%10011011
.byte %00000001,%00000000,%00001000
.byte %00000000,%11111111,%11110000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000

img_trash:
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%01111110,%00000000
.byte %00000001,%10000001,%10000000
.byte %00011111,%11111111,%11111000
.byte %00010000,%00000000,%00001000
.byte %00011111,%11111111,%11111000
.byte %00000000,%00000000,%00000000
.byte %00001000,%00000000,%00010000
.byte %00001001,%00100100,%10010000
.byte %00001001,%00100100,%10010000
.byte %00001001,%00100100,%10010000
.byte %00001001,%00100100,%10010000
.byte %00001001,%00100100,%10010000
.byte %00001001,%00100100,%10010000
.byte %00001001,%00100100,%10010000
.byte %00001001,%00100100,%10010000
.byte %00001000,%00000000,%00010000
.byte %00001000,%00000000,%00010000
.byte %00000111,%11111111,%11100000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000

APP_TICK = *
        lda minute      ; check if minute has changed
        cmp TODMIN
        bne _updateclock
        jmp _done
_updateclock:           ; if so, update the clock
        lda TODMIN
        sta minute
        #ClearRect 269, 191, 319, 199
        ldy #$00
        lda TODHRS      ; hour (tens)
        and #$7f        ; ignore AM/PM for now
        ror
        clc 
        ror
        clc 
        ror
        clc 
        ror
        clc
        and #$0f
        adc #$30        ; convert to petscii
        sta time,y
        iny
        lda TODHRS      ; hour (ones)
        and #$0f
        adc #$30        ; convert to petscii
        sta time,y
        iny
        lda #':'
        sta time,y
        iny
        lda TODMIN      ;mins (tens)
        ror
        clc 
        ror
        clc 
        ror
        clc 
        ror
        clc
        and #$0f
        adc #$30        ; convert to petscii
        sta time,y
        iny
        lda TODMIN      ; mins (ones)
        and #$0f
        adc #$30        ; convert to petscii
        sta time,y
        iny
        iny
        lda TODHRS      ; check if AM/PM
        and #$80
        cmp #$80
        beq _pm 
        lda #'A'
        sta time,y
        jmp _startclk
_pm:    lda #'P'
        sta time,y 
.comment
        iny
        lda #':'
        sta time,y
        iny
        lda $dc09       ; secs (tens)
        ror
        clc 
        ror
        clc 
        ror
        clc 
        ror
        clc
        and #$0f
        adc #$30        ; convert to petscii
        sta time,y
        iny
        lda $dc09       ; secs (ones)
        and #$0f
        adc #$30        ; convert to petscii
        sta time,y
.endc
_startclk:
        lda $dc08       ; tod has stopped since we read the hour value
        sta $dc08       ; writing to the 10th/sec value restarts tod

        #Text 282, 191, time
_done:
        rts

WIN_OK = *
        #FetchScreen 
        #RemoveButton 0,1
        jmp MAINLOOP

MENU_APPS = *
        jsr closemenu
        #DrawRect 100,70,219,140,1       
        #Text 112, 80, dlg_apps

        #CreateButton 0,1,<WIN_OK, >WIN_OK,180,120,210,130,1
        #Text 189, 122, ok

        jmp MAINLOOP

MENU_FILEMGR = *
        jsr closemenu
        #DrawRect 100,70,219,140,1       
        #Text 112, 80, dlg_fileman

        #CreateButton 0,1,<WIN_OK, >WIN_OK,180,120,210,130,1
        #Text 189, 122, ok

        jmp MAINLOOP

MENU_SETTINGS = *
        jsr closemenu
        
        jsr LOAD_IMM
        .text "uos-settings",$00
        jsr APP_LOADER

        jmp APP_START

MENU_CMDLN = *
        jsr closemenu
        #DrawRect 100,70,219,140,1       
        #Text 112, 80, dlg_cmd

        #CreateButton 0,1,<WIN_OK, >WIN_OK,180,120,210,130,1
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
        #CreateButton 0,1,<QUIT_YES, >QUIT_YES, left, top, left + width, top + height,1
        #Text 189, 122, yes

        top := 120
        left := 140
        width := 30
        height := 10
        #CreateButton 0,2,<QUIT_NO, >QUIT_NO, left, top, left + width, top + height,1
        #Text 148, 122, no 

        jmp MAINLOOP

QUIT_YES:
        jmp $fce2

QUIT_NO:
        #FetchScreen
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
        #SaveScreen
        lda #$01
        sta menuopen
        
        height := 14
        left := 0
        width := 75
        top := 105

        #CreateButton 0, 1, <MENU_APPS,  >MENU_APPS, left, top + (height * 1), width, (top + height) + (height*1),1
        #Text left + 5, top + 4 + (height * 1), mnu_apps
        #CreateButton 0, 2, <MENU_FILEMGR,  >MENU_FILEMGR, left, top + (height * 2), width, (top + height) + (height*2),1
        #Text left + 5, top + 4 + (height * 2), mnu_fileman
        #CreateButton 0, 3, <MENU_SETTINGS, >MENU_SETTINGS,left, top + (height * 3), width, (top + height) + (height*3),1
        #Text left + 5, top + 4 + (height * 3), mnu_settings
        #CreateButton 0, 4, <MENU_CMDLN,    >MENU_CMDLN   ,left, top + (height * 4), width, (top + height) + (height*4),1
        #Text left + 5, top + 4 + (height * 4), mnu_cmdline
        #CreateButton 0, 5, <MENU_QUIT,     >MENU_QUIT    ,left, top + (height * 5), width, (top + height) + (height*5),1
        #Text left + 5, top + 4 + (height * 5), mnu_quit

        jmp MAINLOOP

closemenu:
        #FetchScreen
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

dlg_apps:       .text "Apps submenu", $00
dlg_fileman:    .text "File manager", $00
dlg_settings:   .text "Settings", $00
dlg_cmd:        .text "Cmd Line", $00
dlg_quit:       .text "Quit: Are you sure?", $00

mnu_apps:       .text "applications", $00
mnu_fileman:    .text "file manager", $00
mnu_quit:       .text "quit", $00
mnu_settings:   .text "settings", $00
mnu_cmdline:    .text "command line", $00
mnu_main:       .text "ultos", $00

time:           .text "12:00 PM", $00

yes:    .text "Yes", $00
no:     .text "No", $00
ok:     .text "Ok", $00
cancel: .text "Cancel", $00

menuopen:
        .byte $00

minute:
        .byte $00

