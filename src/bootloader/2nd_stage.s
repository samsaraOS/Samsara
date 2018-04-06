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

	mov 	eax, cr0
	or 	eax, 1
	mov 	cr0, eax

	cli
	jmp 	0x8:pmode

.end:
	cli
	hlt
	jmp 	.end

.a20_fail:
	jmp 	.end

%include "gdt32table.s"
%include "a20_line.s"

section .bss
stack_bottom:
	resb 	16368
section .text
stack_top:
bits 32
pmode:
	mov 	ax, 0x10
	mov 	ds, ax
	mov 	es, ax
	mov 	fs, ax
	mov 	gs, ax
	mov 	ss, ax
	mov 	esp, stack_bottom

	cli
	hlt

