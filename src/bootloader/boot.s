;***
; The entrypoint for bootloader.
;***
bits 16
align 4
org 0x7c00
section .text
global _entry
jmp 	0x0000:_entry

_entry:
	cld
	cli

	mov 	[BOOT_DEVICE_DB], dl
	xor 	ax, ax
	xor 	bx, bx
	xor 	cx, cx

	xor 	si, si
	xor 	di, di

	xor 	bp, bp
	mov 	ss, ax
	mov 	es, ax
	mov 	fs, ax
	mov 	sp, 0x7c00

	sti
	add 	ah, 0x02
	add 	al, 2
	add 	cl, 0x02
	mov 	bx, _start
	int 	0x13
	jmp 	_start

	BOOT_DEVICE_DB db 0

	times 	510-($-$$) db 0x00
	db 	0x55
	db 	0xAA


%include "src/bootloader/2nd_stage.s"

