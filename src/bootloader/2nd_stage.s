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

	; Clear registers
	xor 	ax, ax
	xor 	bx, bx
	xor 	cx, cx
	xor 	dx, dx
	xor 	di, di
	xor 	si, si

	; Enable interrupts and load kernel from 0x1000
	sti
	mov 	bx, 0x1000
	mov 	dh, 0x0E
	mov 	dl, [BOOT_DEVICE_DB]
	mov 	byte [SECTORS], dh
	mov 	ch, 0x00
	mov 	dh, 0x00
	mov 	cl, 0x02

	; We'll retry 5 times maximum if we get sector
	; errors from BIOS.
	.read_start:
		mov 	di, 5
	.read:
		mov 	ah, 0x02
		mov 	al, [SECTORS]
		int 	0x13
		jc 	.retry
		sub 	[SECTORS], al
		jz 	.read_done
		mov 	cl, 0x01
		xor 	dh, 1
		jnz 	.read_start
		inc 	ch
		jmp 	.read_start
	.retry:
		mov 	ah, 0x00
		int 	0x13
		dec 	di
		jnz 	.read
		jmp 	.read_fail
	.read_done:
		; After reading the disk, jump to 32-bit protected mode.
		jmp 	do_switch

.read_fail:
	mov 	si, msg_read_fail
	call 	real16_dbg_print
.end:
	cli
	hlt
	jmp 	.end

msg_read_fail db "Failed to read kernel from disk.", 0x0A, 0x0D, 0

real16_dbg_print:
	lodsb
	or 	al, al
	jz 	.ret
	mov 	ah, 0x0E
	int 	0x10
	jmp 	real16_dbg_print
	.ret:
		ret

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
	mov 	eax, 0x10
	mov 	ds, ax
	mov 	es, ax
	mov 	fs, ax
	mov 	gs, ax
	mov 	ss, ax
	mov 	esp, 0x1000
	; We've loaded kernel to 0x1000 here. let's jump!
	jmp 	0x1000

	cli
	hlt

SECTORS db 0

times 	0x1000-($-$$) db 0xFF

