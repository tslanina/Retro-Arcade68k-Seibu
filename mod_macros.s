OFFSET_MA_Y		equ 0
OFFSET_MA_X		equ 4
OFFSET_MA_POS	equ 8
OFFSET_MA_NUM	equ 12
OFFSET_MA_FIRE	equ 16
OFFSET_MA_FLASH	equ 20

OFFSET_MA_DATA	equ 32

MOD_MA_X		equ 4

	align 4
	
submod_all_macros:
	dc.l s_am_name
	dc.l s_am_reset
	dc.l s_am_init
	dc.l s_am_update
	
s_am_name:
	dc.b "UPLOAD MACROS   ",0
s_am_reset:
	movem.l D0-D7/A0-A6, -(A7)
	
	
	lea MACROS_BASE,a1
	lea default_macros,a2
	lea sdefault_macros_end,a3
.copyloop:
	move.w (a2)+,(a1)+
	cmp.l a3,a2
	bcs .copyloop
	
	
	
	
	movem.l (A7)+, D0-D7/A0-A6
	rts
	
s_am_init:
	movem.l D0-D7/A0-A6, -(A7)
	jsr clear_mod_vram
	
	movem.l (A7)+, D0-D7/A0-A6
	rts

s_am_update:
	movem.l D0-D7/A0-A6, -(A7)
	jsr clear_mod_vram
	
	move.l (OFFSET_MA_FLASH,a0),d0
	add.l #1,d0
	move.l d0,(OFFSET_MA_FLASH,a0)
	
	;controls
	
	move.l VAR_INPUT,d0
	move.l VAR_INPUT_TRG,d1
	btst.l #4,d0
	beq .nofire
	
	move.l (OFFSET_MA_Y,a0),d6
	move.l d6,d7
	add.l d7,d7
	add.l d7,d7
	add.l (OFFSET_MA_X,a0),d7 ;y*4+x
	move.l d7, (OFFSET_MA_FIRE,a0)
	
	;check position
	
	or.b d6,d6
	bne .notfirstrow
	btst.l #4,d1  ;fire trg
	beq .notrg
	
	or.b d7,d7
	bne .notupl
	;single upload
	move.l (OFFSET_MA_NUM,a0),d0
	jsr upload_macro
	bra .print
.notupl:	
	cmp.b #2,d7
	bne .notall
	;all upload
	moveq.l #0,d0
.allloop:	
	jsr upload_macro
	add.b #1,d0
	cmp.b #NUM_COP_MACROS,d0
	bne .allloop
	
	bra .print
.notall:	
	cmp.b #3,d7
	bne .notrg
	;reset
	move.l (OFFSET_MA_NUM,a0),d0
	jsr reset_macro
	bra .print
.notrg:
	;only num
	cmp.b #1,d7
	bne .notnum
	;num change, edit it
	
	move.l (OFFSET_MA_NUM,a0),d0
	move.l (OFFSET_MA_POS,a0),d2
	and.l #1,d2
	move.l #NUM_WORD,d3
	jsr edit_num
	
	cmp.b #NUM_COP_MACROS,d0
	bcs .skl
	move.l #NUM_COP_MACROS-1,d0
.skl:	
	move.l d0,(OFFSET_MA_NUM,a0)
	move.l d2,(OFFSET_MA_POS,a0)
	
	;	edit_num:
	;d0 = data
	;d1 = controls
	;d2 = pos
	;d3 = pos (1<<num_bits)
	
.notnum:
	bra .print
	
.notfirstrow:

	move.l (OFFSET_MA_NUM,a0),d0
	lea MACROS_BASE,a1
	jsr get_macro_ptr

	sub.l #4,d7
	
	add.l d7,d7
	move.w (a1,d7),d0
	move.l (OFFSET_MA_POS,a0),d2
	move.l #NUM_WORD,d3
	jsr edit_num
	move.w d0,(a1,d7)
	move.l d2,(OFFSET_MA_POS,a0)
	
	bra .print

.nofire:	
	move.l #-1,d3
	move.l d3,(OFFSET_MA_FIRE,a0)
	move.l (OFFSET_MA_Y,a0),d3
	
	btst #0,d1
	beq .noup
	sub.b #1,d3
.noup:
	btst #1,d1
	beq .nodown
	add.b #1,d3
.nodown:
	and.l #3,d3
	move.l d3,(OFFSET_MA_Y,a0)
	
	move.l (OFFSET_MA_X,a0),d3
	
	btst #2,d1
	beq .noleft
	sub.b #1,d3
.noleft:
	btst #3,d1
	beq .noright
	add.b #1,d3
.noright:
	and.l #3,d3
	move.l d3,(OFFSET_MA_X,a0)

.print:
	move.l (OFFSET_MA_NUM,a0),d0
	lea MACROS_BASE,a1
	jsr get_macro_ptr
	jsr print_macro
	
	movem.l (A7)+, D0-D7/A0-A6
	rts
	
get_macro_ptr:
	;d0 macro num
	;a1 macros table
	movem.l D0, -(A7)
	lsl.l #2,d0 ;*4
	move.l (a1,d0),d0
	add.l d0,a1
	movem.l (A7)+, D0
	rts
	
	
reset_macro:
	movem.l D0-D1/A0-A2, -(A7)
	lea default_macros,a1
	jsr get_macro_ptr
	move.l a1,a2
	lea MACROS_BASE,a1
	jsr get_macro_ptr
	
	moveq.l #12-1,d0
.loop:
	move.w (a2)+,(a1)+
	dbra d0,.loop
	movem.l (A7)+, D0-D1/A0-A2
	rts
		

upload_macro:
	movem.l D0-D1/A0-A2, -(A7)
	lea MACROS_BASE,a1
	jsr get_macro_ptr
	lea     COP_OFFSET, a2
	move.w  (a1)+, ($3c,A2)
	move.w  (A1)+, ($38,A2)
	move.w  (A1)+, ($3a,A2)
	move.w  (A1)+, D0
	move.w  #$7, D1
.copy_loop:	
	move.w  D0, ($34,A2)
	addq.w  #1, D0
	move.w  (A1)+, ($32,A2)
	dbra d1,.copy_loop
	movem.l (A7)+, D0-D1/A0-A2
	rts	
	
print_macro:
	move.l (OFFSET_MA_Y,a0),d7
	add.l d7,d7
	add.l d7,d7
	add.l (OFFSET_MA_X,a0),d7 ;y*4+x
	move.l a0,a6

	move.l #0,d6

	move.l #MOD_MA_X-2,d0
	;sub.w #2,d0
	move.l #MOD_Y+1,d1
	
	move.w #COLOR_WHITE,d2
	cmp.b d6,d7
	bne .not_r0
	move.w #COLOR_RED,d2
.not_r0:	

	lea txt_ma_single,a0
	jsr print_text
	add.w #8,d0
	
	add.b #1,d6
	
	
	;macro num
	
	lea txt_ma_num,a0
	move.w #COLOR_GREEN,d2
	jsr print_text
	
	add.w #5,d0
	
	move.l (OFFSET_MA_NUM,a6),d3
	move.l #NUM_BYTE,d4
	
	
	move.w #COLOR_WHITE,d2
	cmp.b d6,d7
	bne .not_r1
	
	move.l  (OFFSET_MA_FIRE,a6),d2
	cmp.l #1,d2
	bne .noedit1
	move.l (OFFSET_MA_FLASH,a6),d2
	btst #4,d2
	beq .noedit1

	move.w #COLOR_RED,d2
	move.l d5,a5
	move.l (OFFSET_MA_POS,a6),d5
	jsr print_flashing_num
	move.l a5,d5
	bra .after1

	
	
	
.noedit1:
	move.w #COLOR_RED,d2
.not_r1:
	jsr print_num
.after1:	
	add.b #1,d6
	
	add.w #4,d0
	
	lea txt_ma_all,a0
	move.w #COLOR_WHITE,d2
	cmp.b d6,d7
	bne .not_r2
	move.w #COLOR_RED,d2
.not_r2:
	jsr print_text
	add.b #1,d6
	
	add.w #5,d0
	
	lea txt_ma_res,a0
	move.w #COLOR_WHITE,d2
	cmp.b d6,d7
	bne .not_r3
	move.w #COLOR_RED,d2
.not_r3:
	jsr print_text
	add.b #1,d6
	
	




;	move.l a0,a6
	move.l #MOD_Y,d1
	add.b #4,d1
	move.l #2,d5
.loop:	
	move.l #MOD_MA_X,d0
	;a1 = macro address
	
	move.l d5,a5
	move.l #3,d5
.loop2:
	move.w (a1)+,d3
	move.l #NUM_WORD,d4
	move.w #COLOR_WHITE,d2


	cmp.b d6,d7
	bne .not_r11
	
	move.l  (OFFSET_MA_FIRE,a6),d2
	cmp.l #-1,d2
	beq .noedit11
	move.l (OFFSET_MA_FLASH,a6),d2
	btst #4,d2
	beq .noedit11

	move.w #COLOR_RED,d2
	move.l d5,a2
	move.l (OFFSET_MA_POS,a6),d5
	
	;move #0,d3
	
	
	jsr print_flashing_num
	move.l a2,d5
	bra .after11
.noedit11:
	move.w #COLOR_RED,d2
.not_r11:
	jsr print_num
.after11:	

	add.w #6,d0
	add.b #1,d6
	
	
	dbra d5, .loop2
	
	move.l a5,d5
	add.b #2,d1
	cmp.b #2,d5
	bne .sski
	add.b #2,d1
.sski:

	dbra d5,.loop
	rts


txt_ma_single:
	dc.b "UPLOAD",0

txt_ma_num:
	dc.b "NUM: ",0

txt_ma_all:
	dc.b "ALL",0

txt_ma_res:
	dc.b "RESET",0

;print_text:
	;a0 points to text string
	;d0=x
	;d1=y
	;d2=attribs

;print_num:
	;d0=x
	;d1=y
	;d2=attribs
	;d3 = num
	;d4 = type (num of digits )
	
	
;	print_flashing_num:
	;d0=x
	;d1=y
	;d2=attribs
	;d3 = num
	;d4 = type (num of digits )
	;d5 = position (from end)		 
	
;	edit_num:
	;d0 = data
	;d1 = controls
	;d2 = pos
	;d3 = pos (1<<num_bits)	 
		 