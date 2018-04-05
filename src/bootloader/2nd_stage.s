;***
; 2nd stage of the bootloader, we're no longer
; limited to 0x200 bytes, but we still have 1mb limits.
;***

global _start
_start:
	add 	sp, 0x2000
	cld

	lgdt 	[GDT_PTR]



%include "gdt16table.s"

