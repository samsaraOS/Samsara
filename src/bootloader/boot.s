;***
; The entrypoint for bootloader.
;***
bits 16
align 4
org 0x7c00
section .text
global _entry
_entry:
	xor 	ax, ax
	xor 	bx, bx
	xor 	cx, cx
	xor 	dx, dx

	xor 	si, si
	xor 	di, di

	xor 	bp, bp
	mov 	ss, ax
	mov 	es, ax
	mov 	fs, ax
	mov 	sp, 0x7c00

	add 	ah, 0x02
	inc 	al
	add 	dl, 0x80
	add 	cl, 0x02
	mov 	bx, _start
	int 	0x13
	jmp 	_start

	times 	510-($-$$) db 0x00
	db 	0x55
	db 	0xAA

%include "2nd_stage.s"

