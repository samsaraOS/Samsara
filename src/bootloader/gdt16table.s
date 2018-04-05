
%ifndef GDT_HEADER

GDT_PTR:
	dw 	GDT_END - GDT_PTR - 1
	dd 	GDT_HEAD
GDT_HEAD:
	dd 	0
	dd 	0
GDT_DESC:
	dw 	0xFFFF
	dw 	0x0000
	dw 	0x0092
	dw 	0xCF00
GDT_END:

%endif

