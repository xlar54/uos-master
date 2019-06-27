;****************************************************************************
; vic-ii                                                                    *
;****************************************************************************
; The VIC chip registers are mapped onto $D000 in RAM. 

VIC_BASE        = $d000
VIC_COLOR_RAM   = $d800
VIC_HIRES_COLOR = $0400


VIC_SPR0_X      = $00     ; Sprite x / y screen position registers
VIC_SPR0_Y      = $01
VIC_SPR1_X      = $02
VIC_SPR1_Y      = $03
VIC_SPR2_X      = $04
VIC_SPR2_Y      = $05
VIC_SPR3_X      = $06
VIC_SPR3_Y      = $07
VIC_SPR4_X      = $08
VIC_SPR4_Y      = $09
VIC_SPR5_X      = $0A
VIC_SPR5_Y      = $0B
VIC_SPR6_X      = $0C
VIC_SPR6_Y      = $0D
VIC_SPR7_X      = $0E
VIC_SPR7_Y      = $0F
VIC_SPR_XMSb    = $10     ; MSB of the X coordinate (since 320 > 255). Bit 7 = sprite 7, 6 = sprite 6, etc

VIC_CTRL_1      = $11
SCROLY			= $11     ; Control register 1
                          ; Bit 0-2: Offset of the screen border in raster GFX_LINEs
                          ; Bit 3  : 0=24 GFX_LINEs 1=25 GFX_LINEs
                          ; Bit 4  : 0=screen off
                          ; Bit 5  : 1=standard bitmap mode (graphics)
                          ; Bit 6  : 1=extended color mode (text)
                          ; Bit 7  : Carry from register 18 ($13)

VIC_RASTER      = $12     ; Number of raster GFX_LINE at which a raster IRQ should be generated. 
                          ; 9th bit of raster GFX_LINE found in reg 17 ($12)
VIC_LTPEN_X     = $13     ; X-portion of the screen position at which the beam was found when a strobe was generated (light pen)
VIC_LTPEN_Y     = $14     ; Y-portion of the screen position at which the beam was found when a strobe was generated (light pen)

VIC_SPR_ENBL    = $15     ; Sprite enable (bit 7= sprite 7, bit 6 = sprite 6 etc)

VIC_CTRL_2      = $16     ; Control register 2
                          ; Bit 0-2 : Offset of the left screen border in raster dots
                          ; Bit 3   : 0=38 characters, 1=40 characters (horizontal)
                          ; Bit 4   : Multi-color mode (graphics)

VIC_SPR_XPND_X  = $17     ; Sprite expand (bit 7= sprite 7, bit 6 = sprite 6 etc)
VIC_RAM_BASE    = $18     ; Base address of the character generator and video RAM
                          ; Bits 1-3  : Address bits 11-13 for the character RAM base
                          ; Bits 4-7  : Address bits 10-13 for the video RAM

VIC_IRR         = $19     ; IRR:Interrupt Request Register
                          ; This register indicates which register generated an interrupt. 
                          ; Bit0 : generator is REG18 
                          ; Bit1 : generator is REG31
                          ; Bit2 : generator is REG30
                          ; Bit3 : generator is pin LP
                          ; Bit7 : =1 when at least one other bit is one

VIC_IMR         = $1a     ; IMR:Interrupt Mask Register 
                          ; Layout like REG25. If at least one bit in the IRR and IMR agree
                          ; (IRR AND IMR <> 0), an interrupt is generated (pin IRQ=0).

VIC_SPR_PRI     = $1b     ; Priority register(sprites)
                          ; If the corresponding bit is set, the background character has precedence over the sprite.

VIC_SPR_MULTI   = $1c     ; Multi-color register (sprites)
                          ; If the bit representing a given sprite is set, that sprite is represented in multi-color mode.

VIC_SPR_XPND_Y  = $1d     ; Sprite expand Y The sprites can be doubled in the Y-direction by setting 
                          ; the appropriate bit in this register.

VIC_SPSP_COL    = $1e     ; Sprite/sprite collision
                          ; Each sprite is assigned a bit. If two sprites touch each other,the two corresponding
                          ; bits are set. These bits remain set until they are explicitly cleared. At the same time,
                          ; bit 2 in the IRR is set. If bit 2 in the IMR is also set, an interrupt will be generated.

VIC_SPBK_COL    = $1f     ; Sprite/background collision
                          ; Each sprite is assigned a bit. If a sprite touches the background, the corresponding bit is 
                          ; set. The bits remains set until they are explicitly reset. Bit 3 in the IRR is set. if
                          ; bit 3 in the IMR is also set,an interrupt is generated.

VIC_BORDER_COL  = $20     ; Exterior color(border color) The border color is set in this register (0-15).

VIC_BG_COL0     = $21     ; Background color registers 0-3 
VIC_BG_COL1     = $22     ; Background color register 0 determines the background color in
VIC_BG_COL2     = $23     ; the "normal" text mode. If the multi-color mode is enabled, it 
VIC_BG_COL3     = $24     ; accesses registers 1-3

VIC_SPR_MCOL0   = $25     ; Spritemulti-colorcolor0/1 
VIC_SPR_MCOL1   = $26     ; Sprites which are represented in multi-color can assume the back
                          ; ground color,the sprite color,or the multi-color 0 and 1.

VIC_SPR_COL0    = $27     ; Color sprite 0-8 
VIC_SPR_COL1    = $28     ; The colors for the individual sprites are placed in these registers. 
VIC_SPR_COL2    = $29
VIC_SPR_COL3    = $2a
VIC_SPR_COL4    = $2b
VIC_SPR_COL5    = $2c
VIC_SPR_COL6    = $2d
VIC_SPR_COL7    = $2e

VIC_KYBRD_CTRL  = $2f     ; Keyboard control register
                          ; This register contains the status of the four keyboard interface pins K0 to K3.
                          ; Bits 0 to 3 are responsible for this.
                          ; Bits 4-7 are unused and are always 1.

VIC_CLOCK       = $30     ; 2MHz bit
                          ; Bit 0 of this register determines whether the computer operates at 2MHz or 1MHz.
                          ; If the bit is set, all accesses from the VIC-II chip to the memory
                          ; are halted, except for refreshing the dynamic RAM. Bits 1-7 are unused. 


; *******************************************************************************************************************
; Color values
; *******************************************************************************************************************

VIC_COLOR_BLACK   = $00
VIC_COLOR_WHITE   = $01
VIC_COLOR_RED     = $02
VIC_COLOR_CYAN    = $03
VIC_COLOR_PURPLE  = $04
VIC_COLOR_GREEN   = $05
VIC_COLOR_BLUE    = $06
VIC_COLOR_YELLOW  = $07
VIC_COLOR_ORANGE  = $08
VIC_COLOR_BROWN   = $09
VIC_COLOR_LRED    = $0A
VIC_COLOR_DGREY   = $0B
VIC_COLOR_MGREY   = $0C
VIC_COLOR_LGREEN  = $0D
VIC_COLOR_LBLUE   = $0E
VIC_COLOR_LGREY   = $0F

; By default, the VIC chip 
; uses the same 16K area as the C64 ($0000 to $3FFF) and the screen and
; character memory offsets are also identical.
;
; Also, as on the C64, the VIC chip does not see ROM, only RAM. No matter what
; your memory configuration is, you can use the RAM you selected even if a ROM
; image is mapped in the same location.
;
; As you can see in the memory map above, the VIC can be pointed to 4 blocks
; of RAM, also called banks... The following macro accepts a number from 0 - 3:

SetVICBank .macro bank
 lda $dd00
 and #%11111100
 ora #3-\bank
 sta $dd00
.endm

; Within this 16K block of RAM, we can change the offsets to the character set
; data and the screen display matrix (screen memory) inside that block.
;
; #SetCharacterOffset 4
;This mean that the offset for the character data is 4K. If the VIC bank
;is located at $0000 (the default) then the character data is read from $1000.
;As you can see from the map above, this is the default.

SetCharacterOffset .macro offset
 lda VIC_BASE + VIC_RAM_BASE
 and #%11110001  ; clear the 3 offset control bits
 ora #\offset
 sta VIC_BASE + VIC_RAM_BASE
.endm


; The offset voor screen memory (screen matrix) can be changed in 1K steps.
; The macro I created for this below:
;
; Using #SetMatrixOffset 1
; will place the screen RAM at $0000 + $400 = $0400, which is, again,
; the default.

SetMatrixOffset .macro  offset
 lda VIC_BASE + VIC_RAM_BASE
 and #%00001111  ; clear the 4 offset control bits
 .if(\offset > 0) 
   ora #\offset*16
 .fi
 sta VIC_BASE + VIC_RAM_BASE
.endm


.comment
;==========================================================================
; VIC_SETBANK : Set vic ram base
;==========================================================================
VIC_SETBANK:
;        sta R1

        ; set data direction register to output
        lda $dd02
        ora #%00000011
        sta $dd02

        ; select vic bank 3
        ; vic-ii can only access 16k within the c64's full 64k
        ;   $0000 - $3FFF = 3 (default)
        ;   $4000 - $7FFF = 2 (good for bitmaps and BASIC)
        ;   $8000 - $BFFF = 1
        ;   $C000 - $FFFF = 0
        lda $dd00
        and #%11111100
 ;       ora R1
        sta $dd00

        ; set the block offset for the hires screen - bit 3
        ; Bitmap memory takes up 8192 bytes (half the entire 16k block), so you can only choose:
        ;     0 = 0 byte offset
        ;     1 = 8192 byte offset
        lda VIC_BASE + VIC_RAM_BASE
        and #%11110111
        ora #%00001000
        sta VIC_BASE + VIC_RAM_BASE
        rts

.endc