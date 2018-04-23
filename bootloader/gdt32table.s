
%ifndef GDT_32_H
%define GDT_32_H 1

; GDT start
__null:
	dq 	0
; GDT code segment (0x9a)
__code:
	dw 	0xffff
	dw 	0
	db 	0
	db 	10011010b
	db 	11001111b
	db 	0
; GDT data segment (0x92)
__data:
	dw 	0xffff
	dw 	0
	db 	0
	db 	10010010b
	db  	11001111b
	db 	0
__end:

GDT_32_PTR:
	dw 	__end - __null - 1 ; See amd system programmers manual
	dd 	__null
GDT_32_CODE equ __code - __null ; Calculate GDT32 code & data
GDT_32_DATA equ __data - __null

%endif

