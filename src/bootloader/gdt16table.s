;***
; in this file we define a flat dummy GDT
;***
%ifndef GDT_HEADER

GDT_PTR:
	dw 	GDT_END - GDT_PTR - 1
	dd 	GDT_HEAD
GDT_HEAD:
;***
; first entry is called a null descriptor  and it's not used. :0
;***
	dd 	0
	dd	0
GDT_DESC:
;***
; setting up  some dummy entry
;***
	dw 	0xFFFF
	dw 	0x0000
	dw 	0x0092
	dw 	0xCF00

GDT_END:

%endif

