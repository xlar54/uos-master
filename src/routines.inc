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

APP_START   = $1000
APP_CLICK   = $1500

install1        = $9f09

REU_SIZE        = $9c00
REU_STASH       = $9c03
REU_FETCH       = $9c06
SAVEBITMAP      = $9c09
FETCHBITMAP     = $9c0c

GFX_INIT        = $c000
GFX_SETPIXEL    = $c00f
GFX_ON          = $c006
GFX_OFF         = $c009
GFX_SETCOLOR    = $c00c
GFX_LINE        = $c015
GFX_CIRCLE      = $c018
GPUTC           = $c01b
GPUTS           = $c01e

