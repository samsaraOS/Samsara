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

load_2nd_stage:
	sti
	mov 	bx, _start
	mov 	dh, 2
	mov 	dl, [BOOT_DEVICE_DB]
	mov 	byte [BL_SECTORS], dh
	xor 	ch, ch
	xor 	dh, dh
	mov 	cl, 0x02
.read_start:
	mov 	di, 5
.read:
	mov 	ah, 0x02
	mov 	al, [BL_SECTORS]
	int 	0x13
	jc 	.retry
	sub 	[BL_SECTORS], al
	jz 	.read_done
	mov 	cl, 0x01
	xor 	dh, 1
	jnz 	.read_start
	inc 	ch
	jmp 	.read_start
.retry:
	xor 	ah, ah
	int 	0x13
	dec 	di
	jnz 	.read
	mov 	si, msg_loader_failed
	call 	real16_dbg_print
.error_hang:
	cli
	hlt
.read_done:
	jmp 	0x0000:_start

	msg_loader_failed db "Failed to load bootloader.", 0x0A, 0x0D, 0
	BOOT_DEVICE_DB db 0
	BL_SECTORS db 0

	times 	510-($-$$) db 0x00
	db 	0x55
	db 	0xAA


%include "bootloader/2nd_stage.s"

