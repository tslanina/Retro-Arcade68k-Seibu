OFFSET_EM_IDX	equ 0
OFFSET_EM_POS	equ 8
OFFSET_EM_FIRE	equ 16
OFFSET_EM_FLASH	equ 20

OFFSET_EM_DATA	equ 32


MAX_EM_WRITE		equ	12
MAX_EM_READ			equ	4

MOD_EM_X		equ 2

; 0= num

	align 8

submod_exec_macro:
	dc.l s_em_name
	dc.l s_em_reset
	dc.l s_em_init
	dc.l s_em_update
	
s_em_name:
	dc.b "DATA WRITE      ",0

s_em_reset:
	movem.l D0-D7/A0-A6, -(A7)
	
	moveq.l #0,d0
	move.l d0,(OFFSET_EM_IDX,a0)


	;prepare default data = num, exec
	
	move.l #OFFSET_EM_DATA,d0
	
	move.l a0,a1
	
	add.l d0,a0

	move.l #(MAX_EM_WRITE+MAX_EM_READ-1),d0
	
	moveq.l #0,d1
	move.l #$100400,d2
.loop:
	move.l d2,(a0)+
	move.l d1,(a0)+
	
	
	dbra d0,.loop
	

	;pointer to vars is destroyed now!
.exi:	
	movem.l (A7)+, D0-D7/A0-A6
	rts

s_em_init:
	movem.l D0-D7/A0-A6, -(A7)
	moveq.l #0,d0
	move.l d0,(OFFSET_EM_IDX,a0)
	movem.l (A7)+, D0-D7/A0-A6
	rts
	
s_em_update:
	movem.l D0-D7/A0-A6, -(A7)
	jsr clear_mod_vram
	
	move.l (OFFSET_EM_FLASH,a0),d0
	add.l #1,d0
	move.l d0,(OFFSET_EM_FLASH,a0)
	
	;check fire
	
	move.l VAR_INPUT,d0
	move.l VAR_INPUT_TRG,d1
	
	
	btst.l #5,d1
	beq .nowrite
	
	;burst write/read
	movem.l D0-D7/A0-A6, -(A7)
	move.l #OFFSET_EM_DATA,a3
	add.l a0,a3
	
	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)
	
	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)

	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)

	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)

	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)

	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)

	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)

	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)

	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)

	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)

	move.l (a3)+,a4
	move.l (a3)+,d2
	move.w d2,(a4)

	move.l (a3)+,a4  ;12th
	move.l (a3)+,d2
	move.w d2,(a4)
	
	moveq.l #0,d2
	
	
	move.l (a3)+,a4
	move.w (a4),d2
	move.l d2,(a3)+
	
	
	
	move.l (a3)+,a4
	move.w (a4),d2
	move.l d2,(a3)+
	
	move.l (a3)+,a4
	move.w (a4),d2
	move.l d2,(a3)+
	
	move.l (a3)+,a4
	move.w (a4),d2
	move.l d2,(a3)+
	movem.l (A7)+, D0-D7/A0-A6
	
	bra .print
.nowrite:	
	btst.l #4,d0
	beq .nofire
	
	;fire pressed
	
	
	move.l (OFFSET_EM_IDX,a0),d6
	move.l d6, (OFFSET_EM_FIRE,a0)
	
	move.l #OFFSET_EM_DATA,d0
	move.l a0,a3
	add.l d0,a3

	move.l d6,d0
	add.l d0,d0
	add.l d0,d0
	;add.l d0,d0  ; *4
	add.l d0,a3
	
	
	
	move.l #8,d2 ; num max mod
	
	
	
	btst #0,d6
	beq  .addr_mod
	
	;data mod
	
	move.l #4,d2 ; num max mod
	;add.l #8,a3
.addr_mod:	
	
	
	move.l (OFFSET_EM_POS,a0),d6
	
	
	;check keys
	btst #2,d1   ;left
	beq .no_moveleft
	
	
	addq.l #1,d6
	cmp.l d6,d2
	
	bne .ok_00
	
	moveq.l #0,d6
.ok_00:
	move.l d6,(OFFSET_EM_POS,a0)
	bra .print

.no_moveleft:
	btst #3,d1   ;right
	beq .no_moveright
	move.l (OFFSET_EM_POS,a0),d6
	
	cmp.l #0,d6
	bne .ok_01
	move.l d2,d6
.ok_01:
	subq.l #1,d6	

	move.l d6,(OFFSET_EM_POS,a0)
	bra .print

.no_moveright:

	moveq.l #1,d2
	add.l d6,d6
	add.l d6,d6
	lsl.l d6,d2		; value

	btst #0,d1   ;right
	beq .no_incvalue
	
	move.l (a3),d6
	add.l d2,d6
	move.l d6,(a3)
	bra .print
	
.no_incvalue:	
	
	btst #1,d1   ;right
	beq .no_decvalue
	
	move.l (a3),d6
	sub.l d2,d6
	move.l d6,(a3)
	bra .print

.no_decvalue:
	
	bra .print
	
	
	
.nofire:

	move.l (OFFSET_EM_FIRE,a0),d0
	move.l #-1,d2

	cmp.l d2, d0
	beq .skip_same_as_before

	;fire pressed prviously - check  pos
	
	move.l (OFFSET_EM_IDX,a0),d2
	
	cmp.l #0,d2
	bne .not_go

	;perform action! (writes + reads)


.not_go:
	moveq.l #0,d2
	move.l d2,(OFFSET_EM_POS,a0) ; clear edited index pos


.skip_same_as_before:

	move.l #(MAX_EM_WRITE+MAX_EM_READ),d2
	add.l d2,d2	  ; *2
		
	move.l (OFFSET_EM_IDX,a0),d0

	btst #1,d1
	beq .nodown

	;down pressed


.incidx:	
	add.l #1, d0
	cmp.l d2,d0
	
	blt .done
	moveq.l #0,d0
	bra .done
	
	
.nodown:
	btst #0,d1
	beq .noup

.decidx:
	cmp.l #0,d0
	bne .noteq
	move.l d2,d0
.noteq:
	sub.l #1,d0
	bra .done

.noup:
	btst #2,d1	; left
	bne .decidx
	
	btst #3,d1	; right
	bne .incidx

.done:
	move.l d0,(OFFSET_EM_IDX,a0)




	
	
	
	
	
.print:
	move.l (OFFSET_EM_IDX,a0),d6
	move.l a0,a6 ;store
	
	;a0 is trashed below!
	move.l #MOD_Y,d1
	
	move.l #MOD_EM_X+3,d0
	
	
	;Write!


	
	;print N x "W" entries
	
	

	move.l #(MAX_EM_WRITE+MAX_EM_READ),d5	; loop counter
	sub.l #1,d5
	
	move.l #OFFSET_EM_DATA,d4
	move.l a6,a5
	add.l d4,a5						; a5 points to the data
	
	moveq.l #0, d7					; counter
	
	
	move.l #MOD_EM_X,d0
	
.myloop:	
	move.l (a5)+,d3
	move.l #NUM_DWORD,d4
	move.w #COLOR_WHITE,d2
	
	cmp.l d6,d7
	bne .nsel3
	
	move.l  (OFFSET_EM_FIRE,a6),d2
	cmp.l #-1,d2
	beq .noedit22
	; highlight / flash
	
	move.l (OFFSET_EM_FLASH,a6),d2
	btst #4,d2
	beq .noedit22


	move.w #COLOR_RED,d2
	move.l d5,a3
	move.l (OFFSET_EM_POS,a6),d5
	jsr print_flashing_num
	move.l a3,d5
	bra .after2
.noedit22:
	
	
	
	
	move.w #COLOR_RED,d2
.nsel3:
	jsr print_num
.after2:	
	add.l #8,d0
	
	;data
	
	lea txt_me_macro,a0
	
		
	move.w #COLOR_GREEN,d2
	jsr print_text
	
	add.l #1,d0				; ":"
	add.l #1,d7	; item counter inc			
	
	
	move.l (a5)+,d3
	moveq.l #4,d4
	move.w #COLOR_WHITE,d2
	
	cmp.l d6,d7
	bne .nsel4
	
			
	move.l  (OFFSET_EM_FIRE,a6),d2
	cmp.l #-1,d2
	beq .justred
	
	
	move.l (OFFSET_EM_FLASH,a6),d2
	btst #4,d2
	beq .justred



	move.w #COLOR_RED,d2
	move.l d5,a3
	move.l (OFFSET_EM_POS,a6),d5
	jsr print_flashing_num
	move.l a3,d5
	bra .afterred
	
.justred:
	move.w #COLOR_RED,d2
.nsel4:	
	jsr print_num
.afterred:	
	
	addq.l #1,d7
	
	btst #1,d7
	bne .same
	
	
	cmp.l #MAX_EM_WRITE*2,d7
	bne .notsplit
	
	add.l #1,d1
	
.notsplit:	
	move.l #MOD_EM_X,d0
	add.l #1,d1
	
	
	bra .loopend
.same:

	add.l, #5, d0
	
.loopend:
	dbra d5,.myloop

	movem.l (A7)+, D0-D7/A0-A6
	rts
	



txt_me_enum:
	dc.b "WR:",0
	
txt_me_enum_r:
	dc.b "RD:",0
	

txt_me_num:
	dc.b "#",0
	
txt_me_macro:
	dc.b ":",0
	
txt_me_macro_r:
	dc.b "=",0

txt_me_address:
	dc.b "A: ",0
	
txt_me_go:
	dc.b "GO!",0
	
txt_me_byte:
	dc.b "BYTE",0
	
txt_me_word:
	dc.b "WORD",0

txt_me_long:
	dc.b "LONG",0
	
txt_me_empty:
	dc.b "    ",0
	
