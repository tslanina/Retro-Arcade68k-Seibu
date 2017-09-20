
interrupt:

	move    #$2700, SR
	movem.l D0-D7/A0-A6, -(A7)
	
	move.w  #$14, $10047e.l
	move.w  #$ffff, $1006fc.l	; palette
	nop
	nop
	move.w  #$15, $10047e.l
	move.w  #$ffff, $1006fc.l	; tilemap
	nop
	nop
	
	move.w  ADDR_DSW, D0
	btst    #$1, D0
	
	bne     .skip_cop_write
	
	move.w  #$ffff, $100600.l	; unknown ?
	nop
	nop
.skip_cop_write:	
	
	lea BSS_BASE, a6
	move.l #1,VAR_VBLANK
	addq.l #1,VAR_FRAMECNT
	
	


	movem.l (A7)+, D0-D7/A0-A6
	rte