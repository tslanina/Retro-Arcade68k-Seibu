
	dc.b "[MACROS_COPY]",0
	
macros_copy:
	lea     COP_OFFSET, A1
	move.l	a0,d4 
.copy_next:
	move.l  (a0)+,a2
	cmpi.l #-$1,a2
	beq .copy_exit	

	add.l d4,a2

	move.w  (a2)+,d0

	move.w  D0, ($3c,A1)
	move.w  (A2)+, ($38,A1)
	move.w  (A2)+, ($3a,A1)
	move.w  (A2)+, D0
	move.w  #$7, D1
.copy_loop:	
	move.w  D0, ($34,A1)
	addq.w  #1, D0
	move.w  (A2)+, ($32,A1)
	dbra d1,.copy_loop
	bra .copy_next
.copy_exit:
	rts

NUM_COP_MACROS equ 21


revival_macros:
	dc.l revival_00-revival_macros
	dc.l revival_01-revival_macros
	dc.l -1
	
revival_00:
	dc.w $0105, $0006
	dc.w $fffb, $0000
	dc.w $0180, $02e0, $00a0, $0000, $0000, $0000, $0000, $0000

revival_01:
	dc.w $0b05, $0006
	dc.w $ffdb, $0008
	dc.w $0180, $02e0, $00a0, $0182, $02e0, $00c0, $0000, $0000

default_macros:	
	dc.l cop_macro_00-default_macros
	dc.l cop_macro_08-default_macros
	dc.l cop_macro_10-default_macros
	dc.l cop_macro_18-default_macros
	dc.l cop_macro_28-default_macros
	dc.l cop_macro_60-default_macros
	dc.l cop_macro_80-default_macros
	dc.l cop_macro_88-default_macros
	dc.l cop_macro_90-default_macros
	dc.l cop_macro_98-default_macros
	dc.l cop_macro_20-default_macros
	dc.l cop_macro_30-default_macros
	dc.l cop_macro_38-default_macros
	dc.l cop_macro_40-default_macros
	dc.l cop_macro_48-default_macros
	dc.l cop_macro_68-default_macros
	dc.l cop_macro_c0-default_macros
	dc.l cop_macro_a0-default_macros
	dc.l cop_macro_a8-default_macros
	dc.l cop_macro_b0-default_macros
	dc.l cop_macro_b8-default_macros
	dc.l -1

cop_macro_00:
	dc.w $0205,$0006
	dc.w $FFEB  
	dc.w $0000
	dc.w $0188, $0282, $0082, $0B8E, $098E, $0000, $0000, $0000
	
cop_macro_08:
	dc.w $0905, $0006
	dc.w $FBFB
	dc.w $0008                       
	dc.w $0194, $0288, $0088, $0000, $0000, $0000, $0000, $0000  
	
cop_macro_10:
	dc.w $138E, $0005
	dc.w $BF7F
	dc.w $0010 
	dc.w $0984, $0AA4, $0D82, $0AA2, $039B, $0B9A, $0B9A, $0B9A

cop_macro_18:
	dc.w $1905, $0006
	dc.w $FBFB
	dc.w $0018
	dc.w $0994, $0A88, $0088, $0000, $0000, $0000, $0000, $0000
	
cop_macro_28:
	dc.w $2A05, $0006
	dc.w $EBEB
	dc.w $0028
	dc.w $09AF, $0A82, $0082, $0A8F, $018E, $0000, $0000, $0000

cop_macro_60:
	dc.w $6200, $0008
	dc.w $F3E7
	dc.w $0060
	dc.w $0380, $039A, $0380, $0A80, $029A, $0000, $0000, $0000

cop_macro_80:
	dc.w $08100, $00007
	dc.w $FDFB
	dc.w $0080 
	dc.w $0B9A, $0B88, $0888, $0000, $0000, $0000, $0000, $0000

cop_macro_88:
	dc.w $8900, $0007
	dc.w $FDFB
	dc.w $0088
	dc.w $0B9A, $0B8A, $088A, $0000, $0000, $0000, $0000, $0000

cop_macro_90:
	dc.w $9180, $0007
	dc.w $F8F7
	dc.w $0090
	dc.w $0B80, $0B94, $0B94, $0894, $0000, $0000, $0000, $0000

cop_macro_98:
	dc.w $9980, $0007
	dc.w $F8F7
	dc.w $0098
	dc.w $0B80, $0B96, $0B96, $0896, $0000, $0000, $0000, $0000

cop_macro_20:
	dc.w $2288, $0005
	dc.w $F5DF
	dc.w $0020
	dc.w $0F8A, $0B8A, $0388, $0B9C, $0B9A, $0A9A, $0000, $0000

cop_macro_30:
	dc.w $338E, $0005
	dc.w $BF7F
	dc.w $0030
	dc.w $0984, $0AA4, $0D82, $0AA2, $039C, $0B9C, $0B9C, $0A9A

cop_macro_38:
	dc.w $3BB0, $0004
	dc.w $007F
	dc.w $0038 
	dc.w $0F9C, $0B9C, $0B9C, $0B9C, $0B9C, $0B9C, $0B9C, $099C
	
cop_macro_40:
	dc.w $42C2, $0005
	dc.w $FCDD
	dc.w $0040
	dc.w $0F9A, $0B9A, $0B9C, $0B9C, $0B9C, $029C, $0000, $0000

cop_macro_48:
	dc.w $4AA0, $0005
	dc.w $FCDD
	dc.w $0048
	dc.w $0F9A, $0B9A, $0B9C, $0B9C, $0B9C, $099B, $0000, $0000

cop_macro_68:
	dc.w $6880, $000A
	dc.w $FFF3
	dc.w $0068
	dc.w $0B80, $0BA0, $0000, $0000, $0000, $0000, $0000, $0000

cop_macro_c0:
	dc.w $C480, $000A
	dc.w $FF00
	dc.w $00C0
	dc.w $0080, $0882, $0000, $0000, $0000, $0000, $0000, $0000

cop_macro_a0:
	dc.w $A100, $0000
	dc.w $FFFF
	dc.w $00A0
	dc.w $0B80, $0B82, $0B84, $0B86, $0000, $0000, $0000, $0000

cop_macro_a8:
	dc.w $A900, $000F
	dc.w $FFFF
	dc.w $00A8
	dc.w $0BA0, $0BA2, $0BA4, $0BA6, $0000, $0000, $0000, $0000

cop_macro_b0:
	dc.w $B080, $0009
	dc.w $FFFF
	dc.w $00B0
	dc.w $0B40, $0BC0, $0BC2, $0000, $0000, $0000, $0000, $00000

cop_macro_b8:
	dc.w $B880, $0006
	dc.w $FFFF
	dc.w $00B8
	dc.w $0B60, $0BE0, $0BE2, $0000, $0000, $0000, $0000, $0000

sdefault_macros_end:
