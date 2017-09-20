
INITIAL_STACK	equ $11f000
ADDR_DSW		equ $100740
ADDR_INP		equ $100744
ADDR_INP2		equ $10074c



PALETTE_RAM		equ $104000
TILEMAP			equ $102000

NUM_NIBBLE		equ 1
NUM_BYTE		equ 2
NUM_WORD		equ 4
NUM_DWORD		equ 8

COLOR_WHITE		equ $1000
COLOR_BLACK		equ $0000
COLOR_GREEN		equ $2000
COLOR_RED		equ $3000

TMP_STRING		equ $11c880

BSS_MOD_BASE	equ $11d000

BSS_BASE		equ $11f000

MACROS_BASE		equ $11c000

VAR_VBLANK		equ (BSS_BASE)
VAR_FRAMECNT	equ (BSS_BASE+4)
VAR_MODULE		equ	(BSS_BASE+8)
VAR_MEMV		equ	(BSS_BASE+12)
VAR_MEMV_MODE	equ	(BSS_BASE+16)
VAR_MEMV_EA		equ	(BSS_BASE+20)
VAR_INPUT		equ	(BSS_BASE+24)
VAR_INPUT_TRG	equ	(BSS_BASE+28)
VAR_NUM_MODS	equ	(BSS_BASE+32)
VAR_MODE		equ	(BSS_BASE+36)
VAR_MEMV_X		equ	(BSS_BASE+40)
VAR_MEMV_Y		equ	(BSS_BASE+44)
VAR_MEMV_DT		equ	(BSS_BASE+48)
VAR_MEMV_FIRE 	equ (BSS_BASE+52)
VAR_MEMV_EDITP  equ (BSS_BASE+56)
VAR_MEMV_FLASH	equ (BSS_BASE+60)
VAR_MEMV_ADDRP	equ (BSS_BASE+64)
VAR_MEMV_AFLASH	equ (BSS_BASE+68)
VAR_MTYPE		equ (BSS_BASE+72)

STATUS_X 	equ 1
STATUS_Y  	equ 13

COUNT_X		equ	1
COUNT_Y		equ 29

MNAME_X		equ 1
MNAME_Y		equ 14

MOD_Y		equ 16

VIEWER_Y	equ 2

MODE_VIEW	equ 0
MODE_EDIT	equ 1
MODE_MODIFY	equ 2

ID_X		equ 19
ID_Y		equ 26


COP_OFFSET		equ $100400