;***
; In this file, we'll define GDT
;***
%ifndef GDT_32_HEADER
%define GDT_32_HEADER 1

GDT_32_PTR:
	dw 	GDT_32_END - GDT_32_START - 1
	dd 	GDT_32_START

GDT_32_START:
GDT_32_NULL:
	dd 	0
	dd 	0
GDT_32_CODE:
	dw 	0xFFFF
	dw 	0
	db 	0
	db 	10011010b
	db 	11001111b
	db 	0
GDT_32_DATA:
	dw 	0xFFFF
	dw 	0
	db 	0
	db 	10010010b
	db 	11001111b
	db 	0
GDT_32_END:

%endif

