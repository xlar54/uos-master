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

*=$8000

sprite0:
; always pointer
.byte $f8,$00,$00,$e0,$00,$00,$f0,$00
.byte $00,$b8,$00,$00,$8c,$00,$00,$04
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$06

sprite1:
; drag mode pointer
.byte %11111111,%00000000,%00000000
.byte %10000000,%00000000,%00000000
.byte %10000000,%00011000,%00000000
.byte %10000000,%00111100,%00000000
.byte %10000000,%01111110,%00000000
.byte %10000000,%11111111,%00000000
.byte %10000000,%00011000,%00000000
.byte %10000010,%00011000,%01000000
.byte %00000110,%00011000,%01100000
.byte %00001111,%00011000,%11110000
.byte %00011111,%11111111,%11111000
.byte %00001111,%00011000,%11110000
.byte %00000110,%00011000,%01100000
.byte %00000010,%00011000,%01000000
.byte %00000000,%00011000,%00000000
.byte %00000000,%11111111,%00000000
.byte %00000000,%01111110,%00000000
.byte %00000000,%00111100,%00000000
.byte %00000000,%00011000,%00000000
.byte %00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000