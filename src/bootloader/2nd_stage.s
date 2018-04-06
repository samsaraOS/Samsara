;***
; 2nd stage of the bootloader, we're no longer
; limited to 0x200 bytes, but we still have 1mb limits.
;***

global _start
_start:
	add 	sp, 0x2000
	cld
	cli

	lgdt 	[GDT_PTR]	
	call 	enable_a20line
	cmp 	eax, 0
	jne 	.a20_fail

.end:
	cli
	hlt
	jmp 	.end

.a20_fail:
	jmp 	.end

%include "gdt32table.s"
%include "a20_line.s"

