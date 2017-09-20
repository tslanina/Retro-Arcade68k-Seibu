; DSW:
;  2 - flip
;  1 - skip cop write during interrupt
;  0 - skip default macros
;
; P1 start - module switch


	cpu 68000

	include "defines.s"
;vectors	
	ORG 0
	
	dc.l INITIAL_STACK
	dc.l START
	dc.l 0
	dc.l 0
	
	dc.l 0,0,0,0
	dc.l 0,0,0,0
	dc.l 0,0,0,0
	dc.l 0,0,0,0
	dc.l 0,0,0,0
	dc.l 0,0,0,0
	
	dc.l interrupt

	ORG $600
txt_id:
	dc.b "13.01.11. (C) TS",0    ; :D
	ORG $666
START:
	
	move    #$2700, SR
	jsr		cop_init
	jsr		macros_start_init
;	move.l 	#$321,d7
;	jsr		ram_clear
	jsr 	dma_set
	jsr		default_palette

	
	jsr		ram_clear
	jsr		maps_clear
	jsr 	tilemap_clear

	jsr 	reset_modules

	move.l  d7,VAR_MTYPE
	
	move.l  #BSS_MOD_BASE,VAR_MEMV
	
	
	jsr 	default_module
	
	jsr 	draw_logo
	
	move    #$2000, SR
	
mainloop:
	move.l VAR_VBLANK,d0
	cmpi.l #$1,d0
	bne mainloop
	
	;process inputs
	
	move.w ADDR_INP,d0
	move.w ADDR_INP2,d1
	andi.l #$3f,d0
	lsl.l  #$6,d1
	or.w	d1,d0
	eor.w 	#$ffff,d0
	move.l	VAR_INPUT,d1
	move.l	d0,VAR_INPUT
	eor.l	d0,d1
	and.l	d0,d1
	move.l	d1,VAR_INPUT_TRG
	
	clr.l VAR_VBLANK	;reser vblank flag


;check  default module (fire 1+2)
	move.l VAR_INPUT,d0
	btst #5,d0
	beq .nodef
	;move.l VAR_INPUT,d0
	btst #4,d0
	beq .nodef
	
	move.l #0,d0
	move.l d0,VAR_MODULE
	jsr init_module
;	bra .end
.nodef:


	
	;check mode switch (p1 start button)
	
	move.l VAR_MODE,d1
	
	move.l VAR_INPUT_TRG,d0
	btst #6,d0
	beq .noswitch
	
	eor.l #1,d1
	move.l d1,VAR_MODE
	
	
.noswitch:	
	
	
	btst #0,d1  ;view or module?
	
	bne .module
	
	;process viewer inputs
	
	move.l d0,d1
	jsr view_inputs

	bra .end
	
	
.module:	
	
	move.l VAR_MODULE,d0
	jsr get_module_parameters
	addi.l #12,a1
	move.l (a1),a1
	jsr (a1)
	
.end:	
	jsr view_mem
	jsr print_status
	jsr print_count
	
	
	;highlight active
	
	move.l VAR_MODE,d0
	btst #0,d0
	bne .h2
	
	move.l #(VIEWER_Y-1),d0
	move.l #(STATUS_Y+2),d1
	move.w #COLOR_GREEN,d2
	move.l #$e,d3
	jsr draw_frame
	
	move.l #(STATUS_Y+3),d0
	move.l #(COUNT_Y-1),d1
	move.w #COLOR_RED,d2
	move.l #$20,d3
	jsr draw_frame
	
	bra .end2
.h2:	
	move.l #(STATUS_Y+3),d0
	move.l #(COUNT_Y-1),d1
	move.w #COLOR_GREEN,d2
	move.l #$e,d3
	jsr draw_frame
	
	
	move.l #(VIEWER_Y-1),d0
	move.l #(STATUS_Y+2),d1
	move.w #COLOR_RED,d2
	move.l #$20,d3
	jsr draw_frame

.end2:	
	bra mainloop

FRAME_X			equ 0
FRAME_WIDTH		equ 29


draw_frame:
	;d0 y0
	;d1 y1
	;d2 attrib
	;d3 char
	
	move.l d0,d6
	move.l d1,d7
	
	;move.l #$0b,d3
	
	; draw horizontal lines
	
	move.l #FRAME_WIDTH,d5
	
	move.l #FRAME_X,d0
.loop:
	move.l d6,d1
;	jsr print_char
	move.l d7,d1
;	jsr print_char
	addq.l #1,d0
	dbra d5,.loop
	
	

	sub.l d6,d7 ; height
	
	move.l d6,d1

	
.loopy:	
	
	move.l #FRAME_X,d0
	jsr print_char
	add.l #FRAME_WIDTH,d0
	add.l #1,d0
	jsr print_char

	
	addq.l #1,d1
	dbra d7,.loopy
	
	rts



	include "viewmem.s"



macros_start_init:
	;set dma(?) offsets, to use with palette/bg update triggers
	moveq.l #0,d7
	move.w  ADDR_DSW, D0
	btst    #$0, D0
	bne     .skip_default_macros	
	
	;move.w d0,d1
	;lsr.w #6,d1
	;and.l #3,d1

	;cmp.l #0,d1
	;bne .not0
	lea		default_macros,a0
	jsr macros_copy
	moveq.l #1,d7
;	bra .skip_default_macros
;.not0:
;	lea		revival_macros,a0
;	jsr macros_copy
;	moveq.l #2,d7
;	bra .skip_default_macros
	
.skip_default_macros:	
	rts
	



ram_clear:
	;clear ram
	
	movea.l A7, A0
	move.l   #$0, D0
.loop:	
	movem.l D0, -(A0)
	cmpa.l  #$108000, A0
	bne     .loop	
	rts
	
maps_clear:
	move.l #$102000-4, A0
	moveq   #$0, D0
.loop:	
	movem.l D0, -(A0)
	cmpa.l  #$100800, A0
	bne     .loop	
	rts


dma_set:
;set dma addresses 	
	lea COP_OFFSET,a0
	
	move.w #$00,	($3e,a0)   	; ???
	move.w #$600,	($74,a0)	; ???
	
	move.w #$14,	($7e,a0)	; slot
	move.w #$4020,	($78,a0)	; offset
	move.w #$27f,	($7a,a0)	; length
	move.w #$0,		($7c,a0)	; ?
	
	move.w #$15,	($7e,a0)	; slot
	move.w #$4100,	($78,a0)	; offset
	move.w #$ff,	($7a,a0)	; length
	move.w #$0,		($7c,a0)	; ?
	rts

default_palette:
; create palette
	lea palette,a0
	lea PALETTE_RAM, a1
	move.l #$400-1, d0
.loop:
	move.l (a0)+,(a1)+
	dbra d0,.loop
	rts


cop_init:
	move.w  #$f, $100640.l
	move.w  #$f, $100642.l
	move.w  #$b0, $100644.l
	move.w  #$d7, $100646.l
	move.w  #$e0, $100648.l
	move.w  #$f, $10064a.l
	move.w  #$e7, $10064c.l
	move.w  #$f3, $10064e.l
	move.w  #$7d, $100650.l
	move.w  #$1fe, $100652.l
	move.w  #$0, $100654.l
	move.w  #$2, $100656.l
	move.w  #$0, $100658.l
	move.w  #$10, $10065c.l ;was: 0
	move.w  #$34, $10067c.l
	move.w  #$3f, $10067e.l
	move.w  #$a8a8, $100682.l
	move.w  #$1830, $100686.l
	
	; scroll regs:
	move.w  #$0, $100660.l
	move.w  #$0, $100662.l
	move.w  #$0, $100664.l
	move.w  #$0, $100666.l
	move.w  #$0, $100668.l
	move.w  #$0, $10066a.l
	
	; screen orientation related
	move.w  #$0, $100470.l
	move.w  #$0, $10068c.l
	move.w  #$1, $100680.l
	move.w  #$ffff, $10068e.l
	move.w  #$0, $100680.l
	move.w  #$9, $100688.l
	move.w  #$1e, $100684.l
	move.w  #$0, $10065a.l
	move.w  #$1d8, $10066c.l
	move.w  #$1ff, $10066e.l
	move.w  #$1da, $100670.l
	move.w  #$1ff, $100672.l
	move.w  #$1d9, $100674.l
	move.w  #$1ff, $100676.l
	move.w  #$1d8, $100678.l
	move.w  #$1ff, $10067a.l
	
	move.w  ADDR_DSW, D0
	btst    #$2, D0
	bne     .end
	
	move.w  #$1000, $100470.l
	move.w  #$ff, $10068c.l
	move.w  #$1, $100680.l
	move.w  #$ffff, $10068e.l
	move.w  #$0, $100680.l
	move.w  #$19, $100688.l
	move.w  #$e1, $100684.l
	move.w  #$1, $10065a.l
	move.w  #$127, $10066c.l
	move.w  #$100, $10066e.l
	move.w  #$125, $100670.l
	move.w  #$100, $100672.l
	move.w  #$126, $100674.l
	move.w  #$100, $100676.l
	move.w  #$127, $100678.l
	move.w  #$100, $10067a.l
.end:
	rts


	include "interrupt.s"

print_text:
	;a0 points to text string
	;d0=x
	;d1=y
	;d2=attribs
	movem.l D0-D1/A0-A1, -(A7)
	lea TILEMAP,a1
	
	andi.l #$ff,d0
	andi.l #$ff,d1
	
	
	lsl.l #1,d0   ;x*2
	lsl.l #7,d1
	add.l d1,d0
	add.l d0,a1
.loop:	
	moveq.l #0,d0
	move.b (a0)+,d0
	cmpi.b #0,d0
	beq .end
	
	or.w d2,d0
	move.w d0,(a1)+
	bra .loop
	
.end:
	movem.l (A7)+, D0-D1/A0-A1
	rts



print_flashing_num:
	;d0=x
	;d1=y
	;d2=attribs
	;d3 = num
	;d4 = type (num of digits )
	;d5 = position (from end)

	
	
	
	movem.l D0-D5/A0, -(A7)
	
	move.l d3,d0
	move.l d4,d1
	
	lea TMP_STRING,a0
	
	move.b #0,(a0,d1)

	subi.l #1,d1

.loop:    
	move.b d0,d2
	andi.w #$f,d2
	
	cmpi.b #$a,d2
	bge .char
	addi.b #$30,d2
	bra .skip
.char:
	addi.b #$37,d2
.skip:
	move.b d2,(a0,d1)
	
	lsr.l #4,d0
	
	dbra d1,.loop

	movem.l (A7)+, D0-D5/A0
	
	movem.l D4-D5/A0, -(A7)
	lea TMP_STRING,a0
	
	sub.l d5,d4
	subq. #1,d4
	moveq #$20,d5
	move.b d5,(a0,d4)
	
	
	
	jsr print_text
	movem.l (A7)+, D4-D5/A0
	rts


	
	
print_num:
	;d0=x
	;d1=y
	;d2=attribs
	;d3 = num
	;d4 = type (num of digits )
	
	
	
	movem.l D0-D4/A0, -(A7)
	
	move.l d3,d0
	move.l d4,d1
	
	lea TMP_STRING,a0
	
	move.b #0,(a0,d1)

	subi.l #1,d1

.loop:    
	move.b d0,d2
	andi.w #$f,d2
	
	cmpi.b #$a,d2
	bge .char
	addi.b #$30,d2
	bra .skip
.char:
	addi.b #$37,d2
.skip:
	move.b d2,(a0,d1)
	
	lsr.l #4,d0
	
	dbra d1,.loop

	movem.l (A7)+, D0-D4/A0
	
	movem.l A0, -(A7)
	lea TMP_STRING,a0
	jsr print_text
	movem.l (A7)+, A0
	rts
	
extract_bits:
	;d0 data
	movem.l D0-D2/A0, -(A7)
	lea TMP_STRING,a0
	move.l #8-1,d2
.loop:
	move.b #'0',d1
	btst d2,d0
	beq .write
	move.b #'1',d1
.write:
	move.b d1,(a0)+
	dbra d2,.loop
	
	moveq #0,d1
	move.b d1,(a0)
	
	movem.l (A7)+, D0-D2/A0

	rts	
	
print_char:
	;d0=x
	;d1=y
	;d2=attribs
	;d3=code
	movem.l D0-D3/A1, -(A7)
	lea TILEMAP,a1
	
	andi.l #$ff,d0
	andi.l #$ff,d1
	
	
	lsl.l #1,d0   ;x*2
	lsl.l #7,d1
	add.l d1,d0
	
	andi.w #$fff,d3
	or.w d2,d3
	move.w d3,(a1,d0)

	movem.l (A7)+, D0-D3/A1
	rts
	
tilemap_clear:
	lea TILEMAP,a0
	move.l #$20,d0
	move.l #$4000,d1
	move.l #(32*32),d1
.loop:
	move.w d0,(a0)+
	dbra d1,.loop
	rts
		
clear_mod_vram:
	;returns in a1 top of the area
	lea TILEMAP,a1
	addi. #(MOD_Y*64*2),a1
	move.l a1,a2
	move.l #$00200020,d0
	move.l #(6*64),d1
.loop:
	move.l d0,(a1)+
	dbra d1,.loop
	move.l a2,a1
	rts


default_module:
	move.l #0,VAR_MODULE

init_module:
	move.l VAR_MODULE,d0
	jsr get_module_parameters
	addi.l #8,a1
	move.l (a1),a1
	jsr (a1)
	
	rts


get_module_parameters:
	; d0 = num
	
	; ret a0 = mem
	; ret a1 = start of table


	;proc address
	move.l d0,d2	
	lsl.l #2,d2
	lea module_list,a0
	move.l (a0,d2),a1

	;mem address
	lea BSS_MOD_BASE,a0
	lsl.l #8,d0
		
	add.l d0,a0
	
	
	rts


reset_modules:
; reset all modules

	moveq.l #0,d1


	lea module_list, a3
	move.l #BSS_MOD_BASE,a0
.loop:	
	move.l (a3)+, a2
	cmpi.w #-$1,a2
	beq .end
	addq.l #4,a2	;skip name offset
	move.l (a2),a2
	addi.l #1,d1
	jsr (a2)		;reset proc
	add.l #$100,a0	;inc ram base for module
	bra .loop
.end:	
	move.l d1,VAR_NUM_MODS
	rts

logo:
	dc.b "                 bb          ",0
	dc.b "                 bb     b b  ",0
	dc.b " bbbb   bbbb  rr bb          ",0
	dc.b "bbb    bb bb     bbbb  bb bb ",0
	dc.b " bbbb  bbbb   rr bb bb bb bb ",0
	dc.b "   bbb bb  bb rr bb bb bb bb ",0
	dc.b "bbbbb   bbbb  rr bbbb   bbbb ",0
	dc.b 1
	
LOGO_X	equ 1
LOGO_Y	equ 18	
	
draw_logo:
	lea logo,a0
	move.l #$e,d3
	move.l #LOGO_Y,d1
.loopx1:	
	move.l #LOGO_X,d0
.loopx:
	move.b (a0)+,d6
	cmp.b #0,d6
	beq .endlx
	cmp.b #1,d6
	beq .endly
	cmp.b #' ',d6
	bne .notblack
	move.w #COLOR_BLACK,d2
	bra .print
.notblack:
	cmp.b #'b',d6
	bne .notblue
	move.w #COLOR_WHITE,d2
	bra .print
.notblue:
	move.w #COLOR_GREEN,d2
.print:
	jsr print_char
	add.l #1,d0
	bra .loopx
	
.endlx:
	add.l #1,d1
	bra .loopx1

.endly:	

	move.l #ID_Y,d1
	move.l #ID_X-11,d0
	
	move.w #COLOR_WHITE,d2
	lea txt_id,a0
	jsr print_text

	rts

	
	align 4

module_list:
	dc.l submod_selector
	dc.l submod_all_macros
	dc.l submod_exec_macro
	dc.l -1
	
	include "mod_selector.s"
	include "mod_macros.s"
	include "mod_exec.s"
	

	

	
	
	include "copmacros.s"


palette:
	include "paldata.s"
	

edit_num:
	;d0 = data
	;d1 = controls
	;d2 = pos
	;d3 = pos (1<<num_bits)
	
	movem.l D3-D6, -(A7)
	
	sub.l #1,d3  ; make mask form num of bits
	
	move.l d1,d6
	and.l #$f,d6
	beq .nochange
	
	btst #2,d1
	beq .noincpos
	add.l #1,d2
	and.l d3,d2
.noincpos:
	btst #3,d1
	beq .nodecpos
	sub.l #1,d2
	and.l d3,d2
.nodecpos:

	move.l d2,d6	; pos

	move.l #$f,d3 ;mask
	lsl.l #2,d2 ;*4
	lsl.l d2,d3 ; shifted mask
 	
	move.l #1,d4	; step
	lsl.l d2,d4  ;inc/dec
	
	move.l d3,d2
	not.l d2		;inv mask

	move.l d0,d5
	and.l d3,d0   ;data
	and.l d2,d5  ;rest
	
	btst #0,d1
	beq .noup
	add.l d4,d0
.noup:
	btst #1,d1
	beq .nodown
	sub.l d4,d0
.nodown:
	and.l d3,d0
	or.l d5,d0	
	move.l d6,d2

.nochange:	
	movem.l (A7)+, D3-D6
	rts
	
	
	end START
	end START
	end START
	end START