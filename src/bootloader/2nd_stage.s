;***
; 2nd stage of the bootloader, we're no longer
; limited to 0x200 bytes, but we still have 1mb limits.
;***

global _start
_start:
	add 	sp, 0x2000
	cld

	lgdt 	[GDT_PTR]	

	call 	enable_a20line

	mov 	ax, 0xb800
	mov 	es, ax

	mov 	ah, 0x00
	xor 	bx, bx
	add 	bl, 0x11
	int 	0x10

	mov 	si, msg_a20_enabled
	call 	print

.end:
	cli
	hlt
	jmp 	.end

.a20_fail:
	jmp 	.end

msg_a20_enabled db "a20 line enabled and gdt loaded.", 0x0A, 0x0D, 0
msg_booted db "Booted the board.", 0x0A, 0x0D, 0

%include "gdt32table.s"
%include "a20_line.s"
%include "print.s"

