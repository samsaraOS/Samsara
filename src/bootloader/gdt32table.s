;***
; In this file, we'll define GDT
;***
%ifndef GDT_HEADER
%define GDT_HEADER 1

GDT_PTR:
	dw 	GDT_END - GDT_START - 1
	dd 	GDT_START

GDT_START:
.null:
	dd 	0
	dd 	0
.code:
	dw 	0xFFFF
	dw 	0
	db 	0
	db 	10011010b
	db 	11001111b
	db 	0
.data:
	dw 	0xFFFF
	dw 	0
	db 	0
	db 	10010010b
	db 	11001111b
	db 	0
GDT_END:

%endif

