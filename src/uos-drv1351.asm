;==========================================================================
;	1351 proportional mouse driver for the c64
;
;	commodore business machines, inc.   27oct86
;		by hedley davis and fred bowen
;==========================================================================

iirq	= $0314
vic	= $d000
sid     = $d400
cia     = $dc00
cia_ddr	= $dc02
potx	= sid+$19
poty	= sid+$1a

xpos	= vic+$00	;x position (lsb)
ypos	= vic+$01	;y position
xposmsb	= vic+$10	;x position (msb)

* = $9f00

        jmp install1    ;install mouse in port 1
	jmp install2    ;install mouse in port 2
	jmp remove      ;remove mouse wedge

install1:
    	ldx #0          ;port 1 mouse
	.byte $2c

install2:
    	ldx #2          ;port 2 mouse

        lda iirq+1      ;install irq wedge
        cmp #>mirq1
        beq _90         ;...branch if already installed!
        php
        sei

        lda iirq        ;save current irq indirect for our exit
        sta iirq2
        lda iirq+1
        sta iirq2+1

        lda _port,x     ;point irq indirect to mouse driver
        sta iirq
        lda _port+1,x
        sta iirq+1
        plp
_90:	rts

_port:	.word mirq1
	.word mirq2


remove:
        lda iirq+1      ;remove irq wedge
	cmp #>mirq1
	bne _190        ;...branch if already removed!
	php
        sei
        lda iirq2       ;restore saved indirect
        sta iirq
        lda iirq2+1
        sta iirq+1
        plp
_190: 	rts

iirq2:		.byte $00, $00
opotx:		.byte $00
opoty:		.byte $00
newvalue:	.byte $00
oldvalue:	.byte $00
ciasave:	.byte $00

mirq2:
        lda #$80        ;port2 mouse scan
        .byte $2c

mirq1:
        lda #$40        ;port1 mouse scan

        jsr setpot      ;configure cia per .a

        lda potx        ;get delta values for x
        ldy opotx
        jsr movchk
        sty opotx

        clc             ;modify low order x position
        adc xpos
        sta xpos
        txa
        adc #$00
        and #%00000001
        eor xposmsb
        sta xposmsb

        lda poty        ;get delta value for y
        ldy opoty
        jsr movchk
        sty opoty

        sec             ;modify y position (decrease y for increase in pot)
        eor #$ff
        adc ypos
        sta ypos

        ldx ciasave     ;restore keyboard
        stx cia

_90 	jmp (iirq2)     ;continue w/ irq operation



; movchk
;	entry	y = old value of pot register
;		a = currrent value of pot register
;	exit	y = value to use for old value
;		x,a = delta value for position
;

movchk:
        sty oldvalue    ;save old & new values
	sta newvalue
        ldx #0          ;preload x w/ 0

        sec             ;a = mod64(new-old)
        sbc oldvalue
        and #%01111111	
        cmp #%01000000	;if a > 0
        bcs _50
        lsr a           ;   then a = a/2
        beq _80         ;      if a <> 0
        ldy newvalue	;         then y = newvalue
        rts             ;              return

_50 	ora #%11000000	;   else or-in high order bits
        cmp #$ff        ;      if a <> -1
        beq _80
        sec             ;         then a = a/2
        ror a
        ldx #$ff        ;              x = -1
        ldy newvalue	;              y = newvalue
        rts             ;              return

_80 	lda #0          ;a = 0
	rts             ;return w/ y = old value



setpot:
        ldx cia         ;save keyboard GFX_LINEs
	stx ciasave

	sta cia         ;connect appropriate port to sid

        ldx #4
        ldy #$c7	;delay 4ms to let GFX_LINEs settle & get sync-ed
_10	dey 
        bne _10
        dex
        bne _10
        rts

