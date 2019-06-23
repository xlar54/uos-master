.include "macros.inc"
.include "vic-ii.inc"
.include "kernal.inc"

; ========================================================    
; GRLIB -- hires bitmap graphics library
;
; Basically just a modified BLARG
;
; SLJ 5/20/00
; http:;www.ffd2.com/fridge/grlib/
; ========================================================
* = $C000

; Constants

; CHROUT   = $FFD2

X1       = $02
Y1       = $04
X2       = $06
Y2       = $08
DX       = $0A
DY       = $0C
ROW      = $0D            ;Bitmap row
COL      = $0E            ;and column
INRANGE  = $0F            ;Range check flag

RADIUS   = $10

CHUNK1   = $11            ;Circle routine stuff
OLDCH1   = $12
CHUNK2   = $13
OLDCH2   = $14
DISPLAY  = $15

CX       = DX
CY       = DY
X        = $15
Y        = $16
LCOL     = $17            ;Left column
RCOL     = $18
TROW     = $19            ;Top row
BROW     = $1A            ;Bottom row
RANGE1   = $1B
RANGE2   = INRANGE

POINT    = $1C
TEMP2    = $1E
TEMP     = $20            ;1 byte

; ======================================================== 
;
; Jump table
;
; ======================================================== 
         JMP InitGr
         JMP SetOrg
         JMP GRON
         JMP GROFF
         JMP SETCOLOR
         JMP GPLOT
         JMP PLOTABS
         JMP LINE
         JMP CIRCLE

; ======================================================== 
;
; Initialize stuff
;
; ======================================================== 
InitGr:   
         LDA #00
         STA ORGX
         STA ORGY

         LDA #$FF
         STA DONTPLOT
         STA BITMASK

         RTS
; ======================================================== 
;
; Set center of screen
; .X = x-coord, .Y = y-coord
;
; ======================================================== 
ORGX:     .byte $00
ORGY:     .byte $00

SetOrg:   
         STX ORGX
         STY ORGY
         RTS
; ======================================================== 
;
; GPLOT -- plot the point in x1,y1
;
; Note that x1 and y1 are 16-bit!
;
; Out of range values are allowed and
; computed, so that pointer updates
; will work correctly.  ROW and COL are
; computed for reference by other
; routines.
;
; INRANGE is set to 0 if point is on screen
;
; ======================================================== 
DONTPLOT: .byte $01           ;0=Don't plot point, just compute
                          ;coordinates (used by e.g. circles)
GPLOT:     
         LDA Y1
         SEC
         SBC ORGY
         STA Y1
         BCS _C1
         DEC Y1+1
         SEC
_C1      LDA X1
         SBC ORGX
         STA X1
         BCS PLOTABS
         DEC X1+1

PLOTABS:  
         LDA Y1
         STA ROW
         AND #7
         TAY
         LDA Y1+1
         LSR              ;Neg is possible
         ROR ROW
         LSR
         ROR ROW
         LSR
         ROR ROW

         LDA #00
         STA POINT
         LDA ROW
         CMP #$80
         ROR
         ROR POINT
         CMP #$80
         ROR
         ROR POINT        ;row*64
         ADC ROW          ;+row*256
         CLC
         ADC BASE         ;+bitmap base
         STA POINT+1

         LDA X1
         TAX
         STA COL
         LDA X1+1
         LSR
         ROR COL
         LSR
         ROR COL
         LSR
         ROR COL

         TXA
         AND #$F8
         CLC
         ADC POINT        ;+(X AND #$F8)
         STA POINT
         LDA X1+1
         ADC POINT+1
         STA POINT+1
         TXA
         AND #7
         TAX

         LDA ROW
         CMP #25
         BCS _rts
         LDA COL
         CMP #40
         BCS _rts

         LDA DONTPLOT
         BEQ _rts
         SEI              ;Get underneath ROM
         LDA $01
         PHA
         LDA #$34
         STA $01

         LDA (POINT),Y
         EOR BITMASK
         AND BITTAB,X
         EOR (POINT),Y
         STA (POINT),Y

         PLA
         STA $01
         CLI
         LDA #00
_rts     STA INRANGE
         RTS

; ======================================================== 
;
; GRON -- turn graphics on.
;
; .A = 0 -> Turn bitmap on
;
; Otherwise, initialize colomap to .A
; and clear bitmap.
;
; ======================================================== 

BASE:   .byte $A0          ;Address of bitmap, hi byte

GRON:     
        TAX
        LDA $D011        ;Skip if bitmap is already on.
        AND #%00100000
        BNE CLEAR

        LDA $DD02        ;Set the data direction regs
        ORA #$03
        STA $DD02

        #SetVICBank 2
        ;LDA $DD00       ; Set VIC Bank 2 - ($8000 - $bfff)
        ;ORA #%00000001
        ;STA $DD00

        ;#SetMatrixOffset 1
        LDA $D018       ; Set bitmap offset
        and #%11110111
        ORA #%00001000  ; bit 3 : 0 = 0 offset (1st 8k)  1 = 8192K offset (2nd 8k)  ($A000)
        STA $D018

        LDA $D011        ;And turn on bitmap
        ORA #%00100000
        STA $D011
CLEAR:  
        TXA
        BEQ GRONDONE
CLEARCOLOR: 
         LDY #$00
         TXA
_l1:     STA $8400,Y
         STA $8500,Y
         STA $8600,Y
         STA $8700,Y
         INY
         BNE _l1
CLEARBITMAP:
         lda #$00
         ldy #$00
_l2:     STA $A000,Y
         STA $A100,Y
         STA $A200,Y
         STA $A300,Y
         STA $A400,Y
         STA $A500,Y
         STA $A600,Y
         STA $A700,Y
         STA $A800,Y
         STA $A900,Y
         STA $AA00,Y
         STA $AB00,Y
         STA $AC00,Y
         STA $AD00,Y
         STA $AE00,Y
         STA $AF00,Y
         STA $B000,Y
         STA $B100,Y
         STA $B200,Y
         STA $B300,Y
         STA $B400,Y
         STA $B500,Y
         STA $B600,Y
         STA $B700,Y
         STA $B800,Y
         STA $B900,Y
         STA $BA00,Y
         STA $BB00,Y
         STA $BC00,Y
         STA $BD00,Y
         STA $BE00,Y
         STA $BF00,Y
         INY
         BNE _l2
GRONDONE: RTS

; ======================================================== 
; GROFF -- Restore old values if graphics are on.
; ======================================================== 
GROFF:    

        LDA $DD02        ;Set the data direction regs
        ORA #$03
        STA $DD02

        LDA $DD00       ; Set VIC Bank 0 - ($0000 - $3fff)
        ORA #%00000011
        STA $DD00

        LDA #$15        ; Set memory control register to default
        STA $D018

        LDA #$1b        ; set control register to default
        STA $D011

GDONE:    RTS

; ======================================================== 
;
; SETCOLOR -- Set drawing color
;   .A = 0 -> background color
;   .A = 1 -> foreground color
;
; ======================================================== 
SETCOLOR: 
COLENT:   CMP #00          ;MODE enters here
         BEQ _C2
_C1      CMP #01
         BNE _RTS
         LDA #$FF
_C2      STA BITMASK
_RTS     RTS


BITMASK:  .byte $FF         ;Set point
BITTAB:   .byte $80,$40,$20,$10,$08,$04,$02,$01


; ======================================================== 
; Drawin' a line.  A fahn lahn.
;
; To deal with off-screen coordinates, the current row
; and column (40x25) is kept track of.  These are set
; negative when the point is off the screen, and made
; positive when the point is within the visible screen.

; Little bit position table
BITCHUNK: .byte $FF, $7F, $3F, $1F, $0F, $07, $03, $01
CHUNK    = X2
OLDCHUNK = X2+1

; DOTTED -- Set to $01 if doing dotted draws (diligently)
; X1,X2 etc. are set up above (x2=LINNUM in particular)
; Format is LINE x2,y2,x1,y1

LINE:     

_CHECK   LDA X2           ;Make sure x1<x2
         SEC
         SBC X1
         TAX
         LDA X2+1
         SBC X1+1
         BPL _CONT
         LDA Y2           ;If not, swap P1 and P2
         LDY Y1
         STA Y1
         STY Y2
         LDA Y2+1
         LDY Y1+1
         STA Y1+1
         STY Y2+1
         LDA X1
         LDY X2
         STY X1
         STA X2
         LDA X2+1
         LDY X1+1
         STA X1+1
         STY X2+1
         BCC _CHECK

_CONT    STA DX+1
         STX DX

         LDX #$C8         ;INY
         LDA Y2           ;Calculate dy
         SEC
         SBC Y1
         TAY
         LDA Y2+1
         SBC Y1+1
         BPL _DYPOS       ;Is y2>=y1?
         LDA Y1           ;Otherwise dy=y1-y2
         SEC
         SBC Y2
         TAY
         LDX #$88         ;DEY

_DYPOS   STY DY           ;8-bit DY -- FIX ME?
         STX YINCDEC
         STX XINCDEC

         LDA #00
         STA DONTPLOT
         JSR GPLOT         ;Set up .X,.Y,POINT, and INRANGE
         INC DONTPLOT
         LDA BITCHUNK,X
         STA OLDCHUNK
         STA CHUNK

         SEI              ;Get underneath ROM
         LDA #$34
         STA $01

         LDX DY
         CPX DX           ;Who's bigger: dy or dx?
         BCC STEPINX      ;If dx, then...
         LDA DX+1
         BNE STEPINX
; ======================================================== 
;
; Big steps in Y
;
;   To simplify my life, just use PLOT to plot points.
;
;   No more!
;   Added special plotting routine -- cool!
;
;   X is now counter, Y is y-coordinate
;
; On entry, X=DY=number of loop iterations, and Y=
;   Y1 AND #$07
STEPINY:  
         LDA #00
         STA OLDCHUNK     ;So plotting routine will work right
         LDA CHUNK
         LSR              ;Strip the bit
         EOR CHUNK
         STA CHUNK
         TXA
         BNE _CONT        ;If dy=0 it's just a point
         INX
_CONT    LSR              ;Init counter to dy/2
;
; Main loop
;
YLOOP:    STA TEMP

         LDA INRANGE      ;Range check
         BNE _SKIP

         LDA (POINT),Y    ;Otherwise plot
         EOR BITMASK
         AND CHUNK
         EOR (POINT),Y
         STA (POINT),Y
_SKIP    
YINCDEC:  INY              ;Advance Y coordinate
         CPY #8
         BCC _CONT        ;No prob if Y=0..7
         JSR FIXY
_CONT    LDA TEMP         ;Restore A
         SEC
         SBC DX
         BCC YFIXX
YCONT:    DEX              ;X is counter
         BNE YLOOP
YCONT2:   LDA (POINT),Y    ;Plot endpoint
         EOR BITMASK
         AND CHUNK
         EOR (POINT),Y
         STA (POINT),Y
YDONE:    
         LDA #$37
         STA $01
         CLI
         RTS

YFIXX:                     ;x=x+1
         ADC DY
         LSR CHUNK
         BNE YCONT        ;If we pass a column boundary...
         ROR CHUNK        ;then reset CHUNK to $80
         STA TEMP2
         LDA COL
         BMI _C1          ;Skip if column is negative
         CMP #39          ;End if move past end of screen
         BCS YDONE
_C1      
         LDA POINT        ;And add 8 to POINT
         ADC #8
         STA POINT
         BCC _CONT
         INC POINT+1
_CONT    INC COL          ;Increment column
         BNE _C2
         LDA ROW          ;Range check
         CMP #25
         BCS _C2
         LDA #00          ;Passed into col 0
         STA INRANGE
_C2      LDA TEMP2
         DEX
         BNE YLOOP
         BEQ YCONT2
; ======================================================== 
;
; Big steps in X direction
;
; On entry, X=DY=number of loop iterations, and Y=
;   Y1 AND #$07
; ======================================================== 
COUNTHI:  .byte  $00           ;Temporary counter
                          ;only used once
STEPINX:  
         LDX DX
         LDA DX+1
         STA COUNTHI
         CMP #$80
         ROR              ;Need bit for initialization
         STA Y1           ;High byte of counter
         TXA
         BNE _CONT        ;Could be $100
         DEC COUNTHI
_CONT    ROR
;
; Main loop
;
XLOOP:    
         LSR CHUNK
         BEQ XFIXC        ;If we pass a column boundary...
XCONT1:   SBC DY
         BCC XFIXY        ;Time to step in Y?
XCONT2:   DEX
         BNE XLOOP
         DEC COUNTHI      ;High bits set?
         BPL XLOOP
XDONE:    
         LSR CHUNK        ;Advance to last point
         JSR LINEPLOT     ;Plot the last chunk
EXIT:     LDA #$37
         STA $01
         CLI
         RTS
;
; CHUNK has passed a column, so plot and increment pointer
; and fix up CHUNK, OLDCHUNK.
;
XFIXC:    
         STA TEMP
         JSR LINEPLOT
         LDA #$FF
         STA CHUNK
         STA OLDCHUNK
         LDA COL
         BMI _C1          ;Skip if column is negative
         CMP #39          ;End if move past end of screen
         BCS EXIT
_C1      
         LDA POINT
         ADC #8
         STA POINT
         BCC _CONT
         INC POINT+1
_CONT    INC COL
         BNE _C2
         LDA ROW
         CMP #25
         BCS _C2
         LDA #00
         STA INRANGE
_C2      LDA TEMP
         SEC
         BCS XCONT1
;
; Check to make sure there isn't a high bit, plot chunk,
; and update Y-coordinate.
;
XFIXY:    
         DEC Y1           ;Maybe high bit set
         BPL XCONT2
         ADC DX
         STA TEMP
         LDA DX+1
         ADC #$FF         ;Hi byte
         STA Y1

         JSR LINEPLOT     ;Plot chunk
         LDA CHUNK
         STA OLDCHUNK

         LDA TEMP
XINCDEC:  INY              ;Y-coord
         CPY #8           ;0..7 is ok
         BCC XCONT2
         STA TEMP
         JSR FIXY
         LDA TEMP
         JMP XCONT2

;
; Subroutine to plot chunks/points (to save a little
; room, gray hair, etc.)
;
LINEPLOT:                  ;Plot the line chunk

         LDA INRANGE
         BNE _SKIP

         LDA (POINT),Y    ;Otherwise plot
         EOR BITMASK
         ORA CHUNK
         AND OLDCHUNK
         EOR CHUNK
         EOR (POINT),Y
         STA (POINT),Y
_SKIP    
         RTS

;
; Subroutine to fix up pointer when Y decreases through
; zero or increases through 7.
;
FIXY:     CPY #255         ;Y=255 or Y=8
         BEQ _DECPTR
_INCPTR                   ;Add 320 to pointer
         LDY #0           ;Y increased through 7
         LDA ROW
         BMI _C1          ;If negative, then don't update
         CMP #24
         BCS _TOAST       ;If at bottom of screen then quit
_C1      
         LDA POINT
         ADC #<320
         STA POINT
         LDA POINT+1
         ADC #>320
         STA POINT+1
_CONT1   INC ROW
         BNE _RTS
         LDA COL
         BMI _RTS
         LDA #00
         STA INRANGE
_RTS     RTS
_DECPTR                   ;Okay, subtract 320 then
         LDY #7           ;Y decreased through 0
         LDA POINT
         SEC
         SBC #<320
         STA POINT
         LDA POINT+1
         SBC #>320
         STA POINT+1
_CONT2   DEC ROW
         BMI _TOAST
         LDA ROW
         CMP #24
         BNE _RTS
         LDA COL
         BMI _RTS
         LDA #00
         STA INRANGE
         RTS
_TOAST   PLA              ;Remove old return address
         PLA
         JMP EXIT         ;Restore interrupts, etc.
; ======================================================== 
;
; CIRCLE draws a circle of course, using my
; super-sneaky algorithm.
;
; Center of circle is at x1,y1
; Radius of circle in RADIUS
;
; ======================================================== 
CIRCLE:   
         LDA RADIUS
         STA Y
         BNE _c1
         JMP GPLOT         ;Plot as a point
_c1      
         CLC
         ADC Y1
         STA Y1
         BCC _c2
         INC Y1+1
_c2      LDA #00
         STA DONTPLOT
         JSR GPLOT         ;Compute XC, YC+R

         LDA INRANGE      ;Track row/col separately
         STA RANGE1
         LDA ROW
         STA BROW
         LDA COL
         STA LCOL
         STA RCOL

         STY Y2           ;Y AND 07
         LDA BITCHUNK,X
         STA CHUNK1       ;Forwards chunk
         STA OLDCH1
         LSR
         EOR #$FF
         STA CHUNK2       ;Backwards chunk
         STA OLDCH2
         LDA POINT
         STA TEMP2        ;TEMP2 = forwards high pointer
         STA X2           ;X2 = backwards high pointer
         LDA POINT+1
         STA TEMP2+1
         STA X2+1

; Next compute CY-R

         LDA Y1
         SEC
         SBC RADIUS
         BCS _C3
         DEC Y1+1
         SEC
_C3      SBC RADIUS
         BCS _C4
         DEC Y1+1
_C4      STA Y1

         JSR PLOTABS      ;Compute new coords
         STY Y1
         LDA POINT
         STA X1           ;X1 will be the backwards
         LDA POINT+1      ;low-pointer
         STA X1+1         ;POINT will be forwards
         LDA ROW
         STA TROW
; LDA INRANGE
; STA RANGE2 ;RANGE2=INRANGE

         INC DONTPLOT

         SEI              ;Get underneath ROM
         LDA #$34
         STA $01

         LDA RADIUS
         LSR              ;A=r/2
         LDX #00
         STX X            ;y=0

; Main loop

_LOOP    
         INC X            ;x=x+1

         LSR CHUNK1       ;Right chunk
         BNE _CONT1
         JSR UPCHUNK1     ;Update if we move past a column
_CONT1   ASL CHUNK2
         BNE _CONT2
         JSR UPCHUNK2
_CONT2                    ;LDA TEMP
         SEC
         SBC X            ;a=a-x
         BCS _LOOP

         ADC Y            ;if a<0 then a=a+y; y=y-1
         TAX
         JSR PCHUNK1
         JSR PCHUNK2
         LDA CHUNK1
         STA OLDCH1
         LDA CHUNK2
         STA OLDCH2
         TXA

         DEC Y            ;(y=y-1)

         DEC Y2           ;Decrement y-offest for upper
         BPL _CONT3       ;points
         JSR DECYOFF
_CONT3   LDY Y1
         INY
         STY Y1
         CPY #8
         BCC _CONT4
         JSR INCYOFF
_CONT4   
         LDY X
         CPY Y            ;if y<=x then punt
         BCC _LOOP        ;Now draw the other half
;
; Draw the other half of the circle by exactly reversing
; the above!
;
NEXTHALF: 
         LSR OLDCH1       ;Only plot a bit at a time
         ASL OLDCH2
         LDA RADIUS       ;A=-R/2-1
         LSR
         EOR #$FF
_LOOP    
         TAX
         JSR PCHUNK1      ;Plot points
         JSR PCHUNK2
         TXA
         DEC Y2           ;Y2=bottom
         BPL _CONT1
         JSR DECYOFF
_CONT1   INC Y1
         LDY Y1
         CPY #8
         BCC _CONT2
         JSR INCYOFF
_CONT2   
         LDX Y
         BEQ _DONE
         CLC
         ADC Y            ;a=a+y
         DEC Y            ;y=y-1
         BCC _LOOP

         INC X
         SBC X            ;if a<0 then x=x+1; a=a+x
         LSR CHUNK1
         BNE _CONT3
         TAX
         JSR UPCH1        ;Upchunk, but no plot
_CONT3   LSR OLDCH1       ;Only the bits...
         ASL CHUNK2       ;Fix chunks
         BNE _CONT4
         TAX
         JSR UPCH2
_CONT4   ASL OLDCH2
         BCS _LOOP
_DONE    
CIRCEXIT:                  ;Restore interrupts
         LDA #$37
         STA $01
         CLI
         LDA #1           ;Re-enable plotting
         STA DONTPLOT
         RTS
;
; Decrement lower pointers
;
DECYOFF:  
         TAY
         LDA #7
         STA Y2

         LDA X2           ;If we pass through zero, then
         SEC
         SBC #<320        ;subtract 320
         STA X2
         LDA X2+1
         SBC #>320
         STA X2+1
         LDA TEMP2
         SEC
         SBC #<320
         STA TEMP2
         LDA TEMP2+1
         SBC #>320
         STA TEMP2+1

         TYA
         DEC BROW
         BMI EXIT2
         RTS
EXIT2:    PLA              ;Grab return address
         PLA
         JMP CIRCEXIT     ;Restore interrupts, etc.

; Increment upper pointers
INCYOFF:  
         TAY
         LDA #00
         STA Y1
         LDA X1
         CLC
         ADC #<320
         STA X1
         LDA X1+1
         ADC #>320
         STA X1+1
         LDA POINT
         CLC
         ADC #<320
         STA POINT
         LDA POINT+1
         ADC #>320
         STA POINT+1
_ISKIP   
         INC TROW
         BMI _RTS
         LDA TROW
         CMP #25
         BCS EXIT2
_RTS     TYA
         RTS

;
; UPCHUNK1 -- Update right-moving chunk pointers
;             Due to passing through a column
;
UPCHUNK1: 
         TAX
         JSR PCHUNK1
UPCH1:    LDA #$FF         ;Alternative entry point
         STA CHUNK1
         STA OLDCH1
         LDA TEMP2
         CLC
         ADC #8
         STA TEMP2
         BCC _CONT
         INC TEMP2+1
         CLC
_CONT    LDA POINT
         ADC #8
         STA POINT
         BCC _DONE
         INC POINT+1
_DONE    TXA
         INC RCOL
         RTS

;
; UPCHUNK2 -- Update left-moving chunk pointers
;
UPCHUNK2: 
         TAX
         JSR PCHUNK2
UPCH2:    LDA #$FF
         STA CHUNK2
         STA OLDCH2
         LDA X2
         SEC
         SBC #8
         STA X2
         BCS _CONT
         DEC X2+1
         SEC
_CONT    LDA X1
         SBC #8
         STA X1
         BCS _DONE
         DEC X1+1
_DONE    TXA
         DEC LCOL
         RTS
;
; Plot right-moving chunk pairs for circle routine
;
PCHUNK1:  

         LDA RCOL         ;Make sure we're in range
         CMP #40
         BCS _SKIP2
         LDA CHUNK1       ;Otherwise plot
         EOR OLDCH1
         STA TEMP
         LDA TROW         ;Check for underflow
         BMI _SKIP
         LDY Y1
         LDA (POINT),Y
         EOR BITMASK
         AND TEMP
         EOR (POINT),Y
         STA (POINT),Y

_SKIP    LDA BROW         ;If CY+Y >= 200...
         CMP #25
         BCS _SKIP2
         LDY Y2
         LDA (TEMP2),Y
         EOR BITMASK
         AND TEMP
         EOR (TEMP2),Y
         STA (TEMP2),Y
_SKIP2   
         RTS

;
; Plot left-moving chunk pairs for circle routine
;
PCHUNK2:  

         LDA LCOL         ;Range check in X
         CMP #40
         BCS _SKIP2
         LDA CHUNK2       ;Otherwise plot
         EOR OLDCH2
         STA TEMP
         LDA TROW         ;Check for underflow
         BMI _SKIP
         LDY Y1
         LDA (X1),Y
         EOR BITMASK
         AND TEMP
         EOR (X1),Y
         STA (X1),Y

_SKIP    LDA BROW         ;If CY+Y >= 200...
         CMP #25
         BCS _SKIP2
         LDY Y2
         LDA (X2),Y
         EOR BITMASK
         AND TEMP
         EOR (X2),Y
         STA (X2),Y
_SKIP2   
         RTS


; ======================================================== 
;
; GPrint
;   .X
;   .Y
;   .A = character
;
; ======================================================== 
GPRINT:

    ; if lowecase, fix value
    cmp #$c1
    bcs _fixlower
    ; store char
    sec
    sbc #$20
    pha
    jmp _getoffset

_fixlower:
    sec
    sbc #$80
    pha

_getoffset:
    ; get character offset
    lda #<font
    sta $fb
    lda #>font
    sta $fc

    pla
    
    ; TODO: needs optimized

_loop1:
    beq _skip0
    jmp _offset1
_skip0:
    jmp _haveoffset

_offset1:
    clc
    inc $fb
    beq _addhibyte1
    jmp _offset2
_addhibyte1:
    inc $fc

_offset2:
    clc
    inc $fb
    beq _addhibyte2
    jmp _offset3
_addhibyte2:
    inc $fc

_offset3:
    clc
    inc $fb
    beq _addhibyte3
    jmp _offset4
_addhibyte3:
    inc $fc

_offset4:
    clc
    inc $fb
    beq _addhibyte4
    jmp _offset5
_addhibyte4:
    inc $fc

_offset5:
    clc
    inc $fb
    beq _addhibyte5
    jmp _offset6
_addhibyte5:
    inc $fc

_offset6:
    clc
    inc $fb
    beq _addhibyte6
    jmp _offset7
_addhibyte6:
    inc $fc

_offset7:
    clc
    inc $fb
    beq _addhibyte7
    jmp _offset8
_addhibyte7:
    inc $fc

_offset8:
    clc
    inc $fb
    beq _addhibyte8
    jmp _offset9
_addhibyte8:
    inc $fc

_offset9:
    clc
    inc $fb
    beq _addhibyte9
    jmp _offset10
_addhibyte9:
    inc $fc

_offset10:
    clc
    inc $fb
    beq _addhibyte10
    jmp _offset11
_addhibyte10:
    inc $fc

_offset11:
    clc
    inc $fb
    beq _addhibyte11
    jmp _iterate
_addhibyte11:
    inc $fc

_iterate:
    sec
    sbc #$01
    jmp _loop1

_haveoffset:
    ; skip 3 meta bytes
    inc $fb
    inc $fb
    inc $fb

; start plotting the character rows

    ldy #$00
    sty tempy

_nextrow:
    lda tempy
    tay
    lda ($fb),y
    and #%10000000
    cmp #%10000000
    bne _nextbit1
    ; plot it
    #LoadB X1, 0
    #LoadB X1+1, 0
    sty Y1
    jsr GPLOT
_nextbit1:
    lda tempy
    tay
    lda ($fb),y
    and #%01000000
    cmp #%01000000
    bne _nextbit2
    ; plot it
    #LoadB X1, 1
    #LoadB X1+1, 0
    sty Y1
    jsr GPLOT
_nextbit2:
    lda tempy
    tay
    lda ($fb),y
    and #%00100000
    cmp #%00100000
    bne _nextbit3
    ; plot it
    #LoadB X1, 2
    #LoadB X1+1, 0
    sty Y1
    jsr GPLOT
_nextbit3:
    lda tempy
    tay
    lda ($fb),y
    and #%00010000
    cmp #%00010000
    bne _nextbit4
    ; plot it
    #LoadB X1, 3
    #LoadB X1+1, 0
    sty Y1
    jsr GPLOT
_nextbit4:
    lda tempy
    tay
    lda ($fb),y
    and #%00001000
    cmp #%00001000
    bne _nextbit5
    ; plot it
    #LoadB X1, 4
    #LoadB X1+1, 0
    sty Y1
    jsr GPLOT
_nextbit5:
    lda tempy
    tay
    lda ($fb),y
    and #%00000100
    cmp #%00000100
    bne _nextbit6
    ; plot it
    #LoadB X1, 5
    #LoadB X1+1, 0
    sty Y1
    jsr GPLOT
_nextbit6:
    lda tempy
    tay
    lda ($fb),y
    and #%00000010
    cmp #%00000010
    bne _nextbit7
    ; plot it
    #LoadB X1, 6
    #LoadB X1+1, 0
    sty Y1
    jsr GPLOT
_nextbit7:
    lda tempy
    tay
    lda ($fb),y
    and #%00000001
    cmp #%00000001
    bne _endrow
    ; plot it
    #LoadB X1, 7
    #LoadB X1+1, 0
    sty Y1
    jsr GPLOT

_endrow:

    inc tempy
    lda tempy
    cmp #$08
    beq _end
    tay
    jmp _nextrow

_end:
    rts

tempy:
    .byte $00

.comment
.if \x > 255
        lda #$01
        sta X1+1
        lda #\x-256
.else
        lda #$00
        sta X1+1
        lda #\x
.fi
        sta X1

        lda #\y
        sta Y1
        
        lda #$00
        sta Y1+1

        jsr GPLOT
.endc



font:
.byte $04, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00 ;space
.byte $01, $07, $00, $80, $80, $80, $80, $00, $80, $80, $00 ; !
.byte $03, $02, $00, $A0, $A0, $00, $00, $00, $00, $00, $00 ; "
.byte $05, $07, $00, $50, $50, $F8, $50, $F8, $50, $50, $00 ; #
.byte $05, $08, $00, $78, $A0, $60, $20, $30, $28, $F0, $20 ; $
.byte $05, $07, $00, $C0, $C8, $10, $20, $40, $98, $18, $00 ; %
.byte $05, $07, $00, $60, $80, $90, $78, $90, $90, $70, $00 ; &
.byte $02, $07, $00, $40, $40, $80, $00, $00, $00, $00, $00 ; '
.byte $03, $08, $01, $20, $40, $80, $80, $80, $80, $40, $20 ; (
.byte $03, $08, $01, $80, $40, $20, $20, $20, $20, $40, $80 ; )
.byte $05, $07, $00, $20, $A8, $70, $F8, $70, $A8, $20, $00 ; *
.byte $05, $07, $00, $00, $20, $20, $F8, $20, $20, $00, $00 ; +
.byte $02, $02, $01, $40, $80, $00, $00, $00, $00, $00, $00 ; ,
.byte $04, $07, $00, $00, $00, $00, $F0, $00, $00, $00, $00 ; -
.byte $01, $01, $00, $80, $00, $00, $00, $00, $00, $00, $00 ; .
.byte $06, $07, $00, $00, $04, $08, $10, $20, $40, $80, $00 ; /
.byte $04, $07, $00, $60, $90, $B0, $D0, $90, $90, $60, $00 ; 0
.byte $02, $07, $00, $40, $C0, $40, $40, $40, $40, $40, $00 ; 1
.byte $03, $07, $00, $C0, $20, $20, $40, $80, $80, $E0, $00 ; 2
.byte $03, $07, $00, $C0, $20, $20, $40, $20, $20, $C0, $00 ; 3
.byte $04, $07, $00, $10, $30, $50, $90, $F0, $10, $10, $00 ; 4
.byte $03, $07, $00, $E0, $80, $C0, $20, $20, $20, $C0, $00 ; 5
.byte $04, $07, $00, $20, $40, $80, $E0, $90, $90, $60, $00 ; 6
.byte $04, $07, $00, $F0, $10, $20, $40, $40, $40, $40, $00 ; 7
.byte $04, $07, $00, $60, $90, $90, $60, $90, $90, $60, $00 ; 8
.byte $04, $07, $00, $60, $90, $90, $70, $10, $20, $40, $00 ; 9
.byte $01, $04, $00, $80, $00, $00, $80, $00, $00, $00, $00 ; :
.byte $02, $05, $01, $40, $00, $00, $40, $80, $00, $00, $00 ; ;
.byte $03, $06, $00, $00, $20, $40, $80, $40, $20, $00, $00 ; <
.byte $04, $06, $00, $00, $F0, $00, $F0, $00, $00, $00, $00 ; =
.byte $03, $06, $00, $00, $80, $40, $20, $40, $80, $00, $00 ; >
.byte $05, $07, $00, $70, $88, $10, $20, $20, $00, $20, $00 ; ?
.byte $05, $07, $00, $70, $88, $B8, $A8, $B8, $80, $70, $00 ; @

.byte $05, $07, $00, $20, $50, $88, $88, $F8, $88, $88, $00 ;A
.byte $04, $07, $00, $E0, $90, $90, $E0, $90, $90, $E0, $00 ;B
.byte $04, $07, $00, $60, $90, $80, $80, $80, $80, $70, $00 ;C
.byte $04, $07, $00, $E0, $90, $90, $90, $90, $90, $E0, $00 ;D 
.byte $03, $07, $00, $E0, $80, $80, $E0, $80, $80, $E0, $00 ;E
.byte $03, $07, $00, $E0, $80, $80, $E0, $80, $80, $80, $00 ;F
.byte $04, $07, $00, $60, $90, $80, $80, $B0, $90, $70, $00 ;G
.byte $05, $07, $00, $88, $88, $88, $F8, $88, $88, $88, $00 ;H
.byte $01, $07, $00, $80, $80, $80, $80, $80, $80, $80, $00 ;I
.byte $03, $07, $00, $20, $20, $20, $20, $20, $20, $C0, $00 ;J
.byte $05, $07, $00, $88, $90, $A0, $C0, $A0, $90, $88, $00 ;K
.byte $03, $07, $00, $80, $80, $80, $80, $80, $80, $E0, $00 ;L
.byte $07, $07, $00, $82, $C6, $AA, $92, $82, $82, $82, $00 ;M
.byte $05, $07, $00, $88, $C8, $A8, $98, $88, $88, $88, $00 ;N
.byte $05, $07, $00, $70, $88, $88, $88, $88, $88, $70, $00 ;O
.byte $04, $07, $00, $E0, $90, $90, $90, $E0, $80, $80, $00 ;P
.byte $05, $08, $01, $70, $88, $88, $88, $88, $98, $78, $04 ;Q
.byte $04, $07, $00, $E0, $90, $90, $90, $E0, $A0, $90, $00 ;R
.byte $04, $07, $00, $70, $80, $C0, $20, $10, $10, $E0, $00 ;S
.byte $03, $07, $00, $E0, $40, $40, $40, $40, $40, $40, $00 ;T
.byte $04, $07, $00, $90, $90, $90, $90, $90, $90, $70, $00 ;U
.byte $05, $07, $00, $88, $88, $88, $88, $88, $50, $20, $00 ;V
.byte $07, $07, $00, $82, $82, $82, $92, $AA, $C6, $82, $00 ;W
.byte $05, $07, $00, $88, $88, $50, $20, $50, $88, $88, $00 ;X
.byte $05, $07, $00, $88, $88, $88, $50, $20, $20, $20, $00 ;Y
.byte $07, $07, $00, $F8, $08, $10, $20, $40, $80, $F8, $00 ;Z

.byte $02, $07, $00, $C0, $80, $80, $80, $80, $80, $C0, $00 ; [
.byte $07, $07, $00, $80, $40, $20, $10, $08, $04, $02, $00 ; slash
.byte $02, $07, $00, $C0, $40, $40, $40, $40, $40, $C0, $00 ; ]
.byte $05, $07, $00, $20, $50, $88, $00, $00, $00, $00, $00 ; ^
.byte $05, $01, $00, $F8, $00, $00, $00, $00, $00, $00, $00 ; _
.byte $02, $07, $00, $80, $80, $40, $00, $00, $00, $00, $00 ; `

.byte $04, $05, $00, $70, $90, $90, $90, $50, $00, $00, $00 ;a
.byte $04, $07, $00, $80, $80, $E0, $90, $90, $90, $E0, $00 ;b
.byte $04, $05, $00, $60, $90, $80, $80, $70, $00, $00, $00 ;c
.byte $04, $07, $00, $10, $10, $70, $90, $90, $90, $70, $00 ;d 
.byte $04, $05, $00, $60, $90, $F0, $80, $70, $00, $00, $00 ;e
.byte $02, $07, $00, $40, $80, $C0, $80, $80, $80, $80, $00 ;f
.byte $04, $07, $02, $70, $90, $90, $90, $70, $10, $20, $00 ;g
.byte $04, $07, $00, $80, $80, $E0, $90, $90, $90, $90, $00 ;h
.byte $01, $07, $00, $80, $00, $80, $80, $80, $80, $80, $00 ;i
.byte $02, $07, $02, $40, $00, $40, $40, $40, $40, $80, $00 ;j
.byte $04, $07, $00, $80, $80, $90, $A0, $C0, $A0, $90, $00 ;k
.byte $01, $07, $00, $80, $80, $80, $80, $80, $80, $80, $00 ;l
.byte $07, $05, $00, $EC, $92, $92, $92, $92, $00, $00, $00 ;m
.byte $04, $05, $00, $E0, $90, $90, $90, $90, $00, $00, $00 ;n
.byte $05, $05, $00, $70, $88, $88, $88, $70, $00, $00, $00 ;o
.byte $04, $07, $02, $E0, $90, $90, $90, $E0, $80, $80, $00 ;p
.byte $04, $07, $02, $70, $90, $90, $90, $70, $10, $10, $00 ;q
.byte $02, $05, $00, $40, $80, $80, $80, $80, $00, $00, $00 ;r
.byte $03, $05, $00, $60, $80, $40, $20, $C0, $00, $00, $00 ;s
.byte $02, $07, $00, $80, $C0, $80, $80, $80, $80, $40, $00 ;t
.byte $04, $05, $00, $90, $90, $90, $90, $70, $00, $00, $00 ;u
.byte $05, $05, $00, $88, $88, $88, $50, $20, $00, $00, $00 ;v
.byte $07, $05, $00, $92, $92, $92, $92, $6C, $00, $00, $00 ;w
.byte $05, $05, $00, $88, $50, $20, $50, $88, $00, $00, $00 ;x
.byte $04, $07, $02, $90, $90, $90, $90, $70, $10, $20, $00 ;y
.byte $04, $05, $00, $F0, $20, $40, $80, $F0, $00, $00, $00 ;z