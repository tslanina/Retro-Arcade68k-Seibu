view_inputs:
	;d1 = controls trg
	move.l VAR_MEMV_MODE,d0
	
	;check if mode switched
	btst.l #5,d1
	beq .skip
	
	cmp.l #2,d0
	bne .skip2
	move.l #-1,d0
.skip2:
	addq.l #1,d0
	
	move.l d0,VAR_MEMV_MODE
	
.skip:	
	
	
	cmp.l #MODE_VIEW,d0
	bne .not_simple
	
	;simple viewer
	
	lea VAR_MEMV,a0

	btst #0,d1
	beq .c1
	subi.l #8,(a0)
.c1:	
	btst #1,d1
	beq .c2
	addi.l #8,(a0)
.c2:	
	btst #2,d1
	beq .c3
	subi.l #2,(a0)
.c3:	
	btst #3,d1
	beq .c4
	addi.l #2,(a0)
.c4:
	rts
	
.not_simple:
	cmp.l #MODE_EDIT,d0
	bne .modmem
	
	; user u/d/l/r to mvoe highlight    and  u/d/l/r +fire to modify mem value
	
	move.l VAR_INPUT,d2
	btst.l #4,d2
	bne .fire
	
	;jesli bylo fire, to zapisz dana!
	
	jsr memv_calc_edit_address
	
	move.l VAR_MEMV_FIRE,d2
	or.l d2,d2
	beq .nowrite

	;write do pamieci
	
	
	move.w VAR_MEMV_DT,d0
	move.w d0,(a0)
	
.nowrite:
	moveq.l #0,d2
	move.l d2,VAR_MEMV_FIRE
	
	;modify cursor
	
	move.l VAR_MEMV_Y, d2  ; cursor y
	btst #0,d1
	beq .noydec
	
	cmp.l #0,d2
	bne .n0_1
	move.l #10,d2
.n0_1:	
	sub.l #1,d2
.noydec:	

	btst #1,d1
	beq .noyinc
	cmp.l #9,d2
	bne .no9
	move.l #-1,d2
.no9:
	add.l #1,d2
.noyinc:	
	move.l d2,VAR_MEMV_Y		
	
	;now x
	
	
	move.l VAR_MEMV_X, d2  ; cursor y
	btst #2,d1
	beq .noxdec
	
	cmp.l #0,d2
	bne .n0_2
	move.l #4,d2
.n0_2:	
	sub.l #1,d2
.noxdec:	

	btst #3,d1
	beq .noxinc
	cmp.l #3,d2
	bne .no4
	move.l #-1,d2
.no4:
	add.l #1,d2
.noxinc:	
	move.l d2,VAR_MEMV_X	

	moveq.l #0, d0
	move.l d0,VAR_MEMV_FLASH
	
	jsr memv_calc_edit_address
	
	move.w (a0),d0
	move.w d0,VAR_MEMV_DT
	
	rts


.fire:
	; if fire==0, read from mem, otherwise use old value 
	
	move.l VAR_MEMV_FIRE,d2
	or.l d2,d2
	bne .nocopy
	;move.l VAR_MEMV_EA,a0
	
	
.nocopy:
	;set fire to 1
	
	moveq.l #1,d2
	move.l d2,VAR_MEMV_FIRE
	
	;check controls
	
	move.w VAR_MEMV_DT,d0
	move.l VAR_MEMV_EDITP,d2
	move.l #NUM_WORD,d3 
	
	jsr edit_num
	
	move.w VAR_MEMV_DT,d3
	move.l VAR_MEMV_EDITP,d4
	
	move.w d0,VAR_MEMV_DT
	move.l d2,VAR_MEMV_EDITP
	
	cmp.w d3,d0
	bne .clear
	cmp.l d4,d2
	beq .skip_clear
.clear:
	moveq.l #0, d0
	move.l d0,VAR_MEMV_FLASH
.skip_clear:

	move.l #VAR_MEMV_FLASH,a0
	add.l #1,(a0)
	rts


.modmem:
	; modify address
	move.l VAR_MEMV,d0
	move.l VAR_MEMV_ADDRP,d2
	move.l #NUM_DWORD,d3 
	
	jsr edit_num
	
	;move.l #$fffffffe,d3
	;and.l d3,d0			;to prevent address error!
	
	
	move.l VAR_MEMV,d3
	move.l VAR_MEMV_ADDRP,d4
	
	move.l d0,VAR_MEMV
	move.l d2,VAR_MEMV_ADDRP
	
	cmp.w d3,d0
	bne .clear2
	cmp.l d4,d2
	beq .skip_clear2
.clear2:
	moveq.l #0, d0
	move.l d0,VAR_MEMV_AFLASH
.skip_clear2:

	move.l #VAR_MEMV_AFLASH,a0
	add.l #1,(a0)


	rts



memv_calc_edit_address:
	; calc address  = start +2*x 8*y
	move.l VAR_MEMV,d0
	and.l #$fffffffe,d0
	move.l d0,a0
	
	move.l VAR_MEMV_X,d0
	add.l d0,d0
	add.l d0,a0
	move.l VAR_MEMV_Y,d0
	lsl.l #3,d0
	add.l d0,a0
	move.l a0,VAR_MEMV_EA ;store for viewer
	rts





print_count:

	;inputs
	move.l #COUNT_Y,d1
	move.l #COUNT_X,d0
	
	move.w #COLOR_GREEN,d2
	lea txt_mode_inputs,a0
	jsr print_text
	
	add.w #3,d0

	move.l d0,d5
	move.l  VAR_INPUT, d0
	jsr extract_bits
	move.l d5,d0
	
	move.w #COLOR_WHITE,d2
	
	lea TMP_STRING,a0
	jsr print_text
	
	add.l #9,d0
	
	;dsw
	
	move.w #COLOR_GREEN,d2
	lea txt_mode_switch,a0
	jsr print_text
	
	add.w #3,d0



	move.l d0,d5
	move.w  ADDR_DSW, d0
	jsr extract_bits
	move.l d5,d0

	move.w #COLOR_WHITE,d2
	
	lea TMP_STRING,a0
	jsr print_text
	
	add.l #9,d0



	;frame counter
	
	
	
	move.w #COLOR_RED,d2
	move.l	VAR_FRAMECNT,d3
	move.l #5, d4
	jsr print_num
	
	
	


	move.l #MNAME_X,d0
	move.l #MNAME_Y,d1
	move.w #COLOR_GREEN,d2
	lea	txt_mname,a0
	jsr print_text
	
	addi.l #12,d0
	move.w #COLOR_WHITE,d2
	
	
	lea module_list, a0

	move.l VAR_MODULE,d4
	
	
	lsl.l #2,d4
	
	move.l (a0,d4),a0
	move.l (a0),a0
	
	jsr print_text
	
	
	

	
	
	rts
	
	
	
txt_mname:
	dc.b "ACTIVE MOD: ",0

print_status:
	move.l #STATUS_X,d0
	move.l #STATUS_Y,d1
	move.w #COLOR_GREEN,d2
	lea	txt_mode,a0
	jsr print_text
	
	addq.l #2,d0
	
	;mode type
	
	moveq.l #0,d7
	
	move.l VAR_MEMV_MODE,d5
	cmp.l #MODE_VIEW,d5
	bne .not_view

	lea txt_mode_view,a0
	bra .end_mode

.not_view:	
	
	cmp.l #MODE_EDIT,d5
	bne .not_edit

	lea txt_mode_edit,a0
	bra .end_mode

.not_edit:

	lea txt_mode_modify,a0
	moveq.l #1,d7

.end_mode

	move.w #COLOR_WHITE,d2
	jsr print_text

	addq.l #2,d0
	
	move.w #COLOR_GREEN,d2
	lea txt_mode_address,a0
	jsr print_text
	
	addq.l #2,d0

	;print address here
	move.l VAR_MEMV,d3
	move.w #8,d4
	move.w #COLOR_WHITE,d2
	
	or.l d7,d7	; set to 1 on edit mode
	beq .printnoedit

	move.w #COLOR_WHITE,d2
	
	;check for edited
	
	move.w #COLOR_RED,d2

	move.l VAR_MEMV_AFLASH,d7
	btst.l #4,d7
	beq .printnoedit
	movem.l D5, -(A7)

	movem.l VAR_MEMV_ADDRP,d5
	jsr print_flashing_num
	movem.l (A7)+, D5
	bra .skipadp

.printnoedit:

	
	jsr print_num
	
.skipadp:
	
	add.l #9,d0
	
	move.w #COLOR_GREEN,d2
	lea txt_mode_data,a0
	jsr print_text
	
	addq.l #2,d0
	
	move.l VAR_MEMV,d3
	and.l #$fffffffe,d3
	move.l d3,a1
	
	
	move.w (a1),d3
	move.w #4,d4

	move.w #COLOR_WHITE,d2
	jsr print_num
	
	addq.l #5,d0
	
	move.w #COLOR_GREEN,d2
	lea txt_mode_commands,a0
	jsr print_text
	
	addq.l #2,d0
	
	
	
	move.w #COLOR_WHITE,d2
	move.l VAR_MTYPE,d3
	move.w #4,d4
	jsr print_num


	rts
	
txt_mode:
	dc.b "M: ",0

txt_mode_view:
	dc.b "V",0

txt_mode_edit:
	dc.b "E",0

txt_mode_modify:
	dc.b "A",0
	
txt_mode_data:
	dc.b "D:",0	
	
txt_mode_address:
	dc.b "A:",0
	
txt_mode_switch:
	dc.b "SW:",0
	
txt_mode_inputs:
	dc.b "IN:",0	

txt_mode_commands:
	dc.b "C:",0
	
view_mem:
	movem.l D0-D7/A0-A6, -(A7)
	
	move.l VAR_MEMV,d1
	and.l #$fffffffe,d1
	move.l d1,a1
	
	move.w #VIEWER_Y,d1
	
	move.l #9,d6
	
	
.loopy:
	move.w #1,d0

	
	move.l a1,d3
	move.l #8,d4

	
	move.w #COLOR_GREEN,d2
	

	jsr print_num
	
	add.w #8,d0
	
	
	
	move.w #COLOR_WHITE,d2
	moveq.l #$3a,d3
	jsr print_char
	
	add.w #2,d0
	
	move.l #3,d5
	
.loopx:

	move.w (a1)+,d3
	move.w #4,d4
	
	move.w #COLOR_WHITE,d2
	
	;check for edited
	
	move.l VAR_MEMV_MODE,d7
	cmp.l #MODE_EDIT,d7
	bne .skipred
	
	move.l VAR_MEMV_EA,d7
	add.l #2,d7
	cmp.l d7,a1
	bne .skipred
	
	move.w #COLOR_RED,d2
	move.l VAR_MEMV_FIRE,d7
	or.l d7,d7
	beq .skipred
	
	move.w VAR_MEMV_DT,d3  ;print buffered value
	
	
	move.l VAR_MEMV_FLASH,d7
	btst.l #4,d7
	beq .skipred
	
	movem.l D5, -(A7)
	
	
	
	movem.l VAR_MEMV_EDITP,d5
	
	jsr print_flashing_num
	
	movem.l (A7)+, D5
	bra .omin
.skipred:	
	jsr print_num
.omin:	
	add.w #4,d0
	;3a 2d
	
	move.w #COLOR_WHITE,d2
	moveq.l #$2d,d3
	
	cmp.w #0,d5
	beq .skip
	jsr print_char
.skip:
	
	add.w #1,d0
	
	dbra d5,.loopx
	
	add.w #1,d1
	dbra d6,.loopy
	
	movem.l (A7)+, D0-D7/A0-A6
	rts
