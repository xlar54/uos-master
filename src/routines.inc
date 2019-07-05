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

brkVectorlo     = $0316
brkVectorhi     = $0317

MAINLOOP        = $0811
FIND_CTL        = $0814
STASH_APP       = $0817
FETCH_APP       = $081a
LOAD_IMM        = $081d
APP_LOADER      = $0820

DESK_START      = $1000
DESK_END        = $2fff

APP_START       = $3000
APP_END         = $8fff

APP_CTL_TBL     = $9000
APP_CTL_CTR     = $9000
APP_CTL_BUF     = $9001
APP_ID_TBL      = $9b00

REU_SIZE        = $9c00
REU_STASH       = $9c03
REU_FETCH       = $9c06
SAVEBITMAP      = $9c09
FETCHBITMAP     = $9c0c
REU_PARAMS      = $9c0f

INIT_MOUSE      = $9f00

GFX_INIT        = $c000
GFX_SETPIXEL    = $c00f
GFX_DRAWBYTEPATTERN = $c021
GFX_ON          = $c006
GFX_OFF         = $c009
GFX_SETCOLOR    = $c00c
GFX_LINE        = $c015
GFX_CIRCLE      = $c018
GPUTC           = $c01b
GPUTS           = $c01e

