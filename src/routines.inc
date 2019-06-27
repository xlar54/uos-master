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

REU_SIZE        = $1800
REU_STASH       = $1803
REU_FETCH       = $1806
SAVEBITMAP      = $18d0
FETCHBITMAP     = $18f7

install1        = $9f09

GFX_INIT        = $c01b
GFX_SETPIXEL    = $c036
GFX_ON          = $c0c9
GFX_OFF         = $c172
GFX_SETCOLOR    = $c18d
GFX_LINE        = $c1ac
GFX_CIRCLE      = $c379
GPUTC           = $c583
GPUTS           = $c71b

