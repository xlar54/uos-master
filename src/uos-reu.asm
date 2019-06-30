;
;
	*=$9c00
;
;
;========================================
;                 equates
;========================================
;
;
buffer	        = $9e00
numbank         = $fb
ramexp          = $df00
rcr             = $d506
BITMAP          = $A000
BITMAPSZ        = $2000
REUSTART        = $0000
;
;
;========================================
;                jump table
;========================================
;
;
start   jmp GETSIZE
        jmp STASH
        jmp FETCH
        jmp SAVEBITMAP
        jmp FETCHBITMAP
;
;
;===========================================
;              DMA parameters
;===========================================
;
;
params	.word $0000	; Host address, lo, hi
	.word $0000	; Exp  address, lo, hi
expbank .byte $00	; Expansion  bank no.
	.word $0100	; # bytes to move, lo, hi
	.byte $00	; Interrupt mask reg.
	.byte $00	; Adress control reg.
;
bnk128  .byte $00       ; Bank of 128 to work with 
pend
;
;
;===========================================
;    Test ram expander to determine size
;===========================================
;
;  Number of banks is returned in .A
;  and in numbank.
;
;   .A =  8 for the 1750 512K expander
;   .A =  2 for the 1700 128K expander
;   .A =  4 for the 1764 256K expander
;   .A =  1 for no RAM expander
;
;===========================================
;
;
;
                                
GETSIZE:
                                ; Here are the 8 parameters we
        ldx #>buffer            ; must set for stash and fetch: 
        stx params+1            ; First, set up the hi bytes of
        stx params+3            ; the cpu and expansion address.
        ldx #$01
        stx params+6            ; Set up the byte count hi
        dex                     ; and the byte count lo.
        stx params+5  
	stx expbank             ;  Set up the expansion bank to
        stx params+0            ; use and the lo bytes of the
        stx params+2            ; cpu and expansion address.
        stx bnk128              ; Set the 128 bank to work with.
;
_20	txa		        ; Generate a 1 block
	eor #$5a                ; test pattern in
	sta buffer,x            ; buffer.
	dex
	bne _20
;
_30	jsr stash	        ; Now write the test
	inc expbank             ; pattern in buffer
        lda expbank             ; to each of the 8
	cmp #8                  ; possible exp. banks.
        bne _30
;
	ldx #0
	stx expbank
;
_40     ldx #0		        ; OK, now change
_50 	txa		        ; the 1 block test
	eor #$3c                ; pattern in the buffer
	sta buffer,x            ; to a new pattern.
	dex
	bne _50
;
	jsr stash	        ; Now write the new 
	inc expbank             ; pattern to bank (x)...

	lda expbank             ; (check to see
        cmp #8                  ;  if we are done)
	beq _90

	jsr fetch	        ; ...and read the pattern
	ldx #0                  ;    from bank (x+1).
_60	txa		        ;  
	eor #$5a                ; We should see the old pattern
	cmp buffer,x            ; here.  If we don't then the data
	bne _90		        ; changed and we have found the end.
	dex
	bne _60                 ; Bytes match so all is well.
	beq _40 		; Loop back for next bank.
;
_90	lda expbank	        ; Number of banks is returned in
	sta numbank             ; the accumulator and in numbank.
	rts
;
;
;===============================================
;          stash  &  fetch  subroutines
;===============================================
;
;  These routines will transfer RAM between the
; cpu and expansion unit on the c64 and c128.
; Before calling, you must set up 8 parameters 
; for the DMA as follows:
;
;       source address      (lo, hi)
;       destination address (lo, hi)
;       exapnsion bank     
;       number of bytes     (lo, hi)
;       128 bank to use
;
;  (parameters are located at "params")
;
;  You may stash or fetch at any address.     
; These routines will bank out ROMs and I/O
; before starting the DMA.
;
;  If you want to fetch or stash RAM bank 1
; on the C128 be sure to make a copy of this
; code in bank 1 too.
;
;===============================================
;
;
FETCH:
        ldy #$ed                ; Command to read from expander
        .byte $2c               ; with FF00 option enabled.
                                ; (skip 2 bytes)

STASH:
        ldy #$ec                ; Command to write to expander
                                ; with FF00 option enabled.
	ldx #pend-params-2
_10 	lda params,x	        ; Initialize the DMA 
	sta $df02,x             ; contoller with our
	dex                     ; parameters,
	bpl _10                 ;
	sty $df01	        ; and issue command.

        ldy bnk128              ;  Set the .y register to the
                                ; 128 bank we want (0 or 1).
;
;
;===============================
;  check if running on c64 or c128
;===============================
;
;
dmarom
        lda $fffd   ; The high byte of the 
        cmp #$fc    ; reset vector on all C64s
        beq xfer64  ; is equal to $fc.
;
;
;============================
;  c128: turn off all ROMs
;============================
;
xfer128:
       sei
       lda rcr       ;   Save the old value of
       pha           ; the 128 rcr.  Now convert
       tya           ; the 128 bank number to a 
       beq bk0128    ; mask for the VIC/DMA
       lda #$40      ; pointer in the rcr.
       ora rcr       ;   This allows a stash or
       bne bangit    ; fetch to bank 0 or bank 1
bk0128 lda #$3f      ; of the 128.  When using
       and rcr       ; bank 1, be sure to make a copy
bangit sta rcr       ; of this code in both banks.
;
       lda $ff00     ;  Save the 128 configuration
       pha           ; now kill ROMs and I/O.
       ora #$3f      ; When we write to FF00
       sta $ff00     ; DMA execution begins.
       pla
       sta $ff00     ;  Restore the old  
       pla           ; configuration and
       sta rcr       ; restore the old VIC 
       cli           ; pointer in the rcr.
       rts
;
;============================
;  c64: turn off all ROMs
;============================
;
xfer64:  
        sei             ;  Save the value of the
        lda $01         ; the c64 control port 
        pha             ; and turn on lower 3 bits
        ;ora #$03       ; to bank out ROMs, I/O.
        lda #$35        ; turn off basic so reu can access bitmap
        sta $01

        sta $ff00       ; start delayed transfer by writing anything to $ff00

        pla             ;  Restore the old
        ;lda #$35       ; restore basic (dont really care since drawing routines are underneath basic)
        sta $01         ; configuration
        cli             ; and return.
        rts

SAVEBITMAP:
        lda #<BITMAP    ; source addr
        sta params
        lda #>BITMAP
        sta params+1
        lda #<REUSTART  ; expanson ram addr
        sta params+2
        lda #>REUSTART
        sta params+3
        lda #$01
        sta params+4    ; expansion bank #
        lda #<BITMAPSZ  ; bytes to move         
        sta params+5
        lda #>BITMAPSZ
        sta params+6
        jmp STASH


FETCHBITMAP:
        lda #<BITMAP    ; source addr
        sta params
        lda #>BITMAP
        sta params+1
        lda #<REUSTART  ; expanson ram addr
        sta params+2
        lda #>REUSTART
        sta params+3
        lda #$01
        sta params+4    ; expansion bank #
        lda #<BITMAPSZ  ; bytes to move         
        sta params+5
        lda #>BITMAPSZ
        sta params+6
        jmp FETCH
