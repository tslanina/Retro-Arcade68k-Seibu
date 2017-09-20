
	align 4
	
submod_selector:
	dc.l s_s_name
	dc.l s_s_reset
	dc.l s_s_init
	dc.l s_s_update
	
s_s_name:
	dc.b "MOD LIST        ",0
s_s_reset:
	movem.l D0-D7/A0-A6, -(A7)

	moveq.l #0,d0
	move.l d0,(a0)
	movem.l (A7)+, D0-D7/A0-A6
	rts
	
s_s_init:
	movem.l D0-D7/A0-A6, -(A7)
	jsr clear_mod_vram
	movem.l (A7)+, D0-D7/A0-A6
	rts
	
	
s_s_update:

	

	movem.l D0-D7/A0-A6, -(A7)
	
	jsr clear_mod_vram
	
	move.l (a0),d1
	
	moveq.l #0,d2
	
	
	move.l VAR_INPUT_TRG,d0
	move.l VAR_NUM_MODS,d3

	btst #0,d0
	beq .c1
	move.l #-1,d2
.c1:	
	btst #1,d0
	beq .c2
	move.l #1,d2
.c2:	

	add.l d2,d1
	
	cmp.l #-1,d1
	bne .skip1
	moveq.l #0,d1
.skip1:
	cmp.l d3,d1
	bne .skip2
	move.l d3,d1
	subi.l #1,d1
.skip2:
	move.l d1,(a0)
	move.l a0,a2
	
	


	btst #4,d0
	bne .change_mod

;draw list 
	move.l #0,d3
	move.l #MOD_Y,d1
	move.l VAR_NUM_MODS,d6
	sub.l #1,d6
.drawloop:	
	movem.l D0-D7/a2, -(A7)
	move.l d3,d0
	jsr get_module_parameters
	movem.l (A7)+, D0-D7/a2
	
	move.l (a1),a0 ; text
	
	move.l #5,d0
	
	
	
	
	move.l #COLOR_WHITE,d2
	move.l (a2),a1
	cmp.l d3,a1
	bne .skip3
	move.l #COLOR_GREEN,d2

	
.skip3:	
	jsr print_text
	addi.l #1,d1
	addi.l #1,d3


	
	
	dbra d6,.drawloop
	


;move.l VAR_MODULE,d4
	
	bra .end

.change_mod:
	move.l #VAR_MODULE,a1
	move.l (a0),(a1)
	jsr init_module
.end:
	movem.l (A7)+, D0-D7/A0-A6
	rts
