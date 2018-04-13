;***
; 2nd stage of the bootloader, we're no longer
; limited to 0x200 bytes, but we still have 1mb limits.
;***

global _start
_start:
	cld
	cli

	xor 	bp, bp
	mov 	sp, 0x7e00

	call 	enable_a20line
	cli
	xor 	eax, eax

	jmp	do_switch
.end:
	cli
	hlt
	jmp 	.end

.a20_fail:
	jmp 	.end

%include "gdt32table.s"
%include "a20_line.s"

do_switch:
	lgdt 	[GDT_32_PTR]
	mov 	eax, cr0
	or 	eax, 1
	mov 	cr0, eax
	jmp 	0x8:pmode
	cli
	hlt
	
bits 32
pmode:
	mov 	ax, 0x10
	mov 	ds, ax
	mov 	es, ax
	mov 	fs, ax
	mov 	gs, ax
	mov 	ss, ax
	mov 	esp, 0x1000
	cli
	hlt

