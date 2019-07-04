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


;==========================================================================
; FILLMEM : Fill RAM  
; (R1 = pages, R2 = LSB address, R3 = MSB address, R4 = value)
;==========================================================================
FILLMEM:
        sta R1              ;set pages to clear (1-255, 0 = 256)
        stx R2              ;set start address LSB
        sty R3              ;set start address MSB
        lda FILLMEMVAL      ;clear value -- could be anything
        ldy #0              ;index
;
_loop   sta (R2),y          ;clear
        iny
        bne _loop           ;next location
;
        dec R1              ;one less page to clear
        beq _done           ;done
;
        inc R3              ;next page
        bne _loop           ;more pages remaining
;
_done:  rts                 ;done
FILLMEMVAL:
        .byte $00

; ======================================================== 
;
; COPY -- Copy mem  ($FB $FC = source, $FD $FE = dest)
;
; ======================================================== 
COPY:
    ;lda #$00 ;set our source memory address to copy from
    ;sta $FB
    ;lda #$e0 
    ;sta $FC

    ;lda #$00 ;set our destination memory to copy to
    ;sta $FD 
    ;lda #$a0
    ;sta $FE

    lda $FE
    sta $20
    ldy #$00 ;reset x and y for our loop
    ldx #$00

_loop
    lda ($FB),Y ;indirect index source memory address
    sta ($FD),Y ;indirect index dest memory address
    iny
    bne _loop ;loop until our dest goes over 255
    
    inc $FC ;increment high order source memory address
    inc $FE ;increment high order dest memory address
    ;dec SIZE+1
    ;dec SIZE
    lda $FE ;load high order mem address into a
    cmp $20 ;compare with the last address we want to write
    bne _loop ;if we're not there yet, loop
    rts

COPYSIZE:
    .byte $00, $00
