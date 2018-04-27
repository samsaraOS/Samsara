
; Entry of 2nd stage of bootloader
global _start
_start:
	cli
	cli
	xor 	bp, bp
	mov 	sp, 0x7e00

	call 	enable_a20line
	call 	load_kernel
	call 	switch_to_pm
.hang:
	cli
	hlt
	jmp 	.hang

SECTORS db 0
%include "bootloader/gdt32table.s"
%include "bootloader/a20_line.s"
msg_read_failed db "Failed to read disk.", 0x0A, 0x0D, 0

; Function to load kernel from disk
load_kernel:
	sti
	mov 	ebx, 0x10000
	mov 	dh, 0x42
	mov 	dl, [BOOT_DEVICE_DB]
	mov 	byte [SECTORS], dh
	xor 	ch, ch
	xor 	dh, dh
	mov 	cl, 0x02
read_start:
	push 	ebp
	mov 	ebp, esp
	mov 	di, 5
read:
	mov 	ah, 0x02
	mov 	al, [SECTORS]
	int 	0x13
	jc 	retry
	sub 	[SECTORS], al
	jz 	read_done
	mov 	cl, 0x01
	xor 	dh, 1
	jnz 	read_start
	inc 	ch
	jmp 	read_start
retry:
	xor 	ah, ah
	int 	0x13
	dec 	di
	jnz 	read
	mov 	si, msg_read_failed
	call 	real16_dbg_print
error_hang:
	cli
	hlt
	jmp 	error_hang
read_done:
	mov 	esp, ebp
	pop 	ebp
	ret

; Function to print debug messages in 16-bit real mode
real16_dbg_print:
	lodsb
	or 	al, al
	jnz 	.continue
	ret
.continue:
	mov 	ah, 0x0E
	int 	0x10
	jmp 	real16_dbg_print

; Function to switch to protected mode
switch_to_pm:
	cli
	lgdt 	[GDT_32_PTR]
	mov 	eax, cr0
	or 	eax, 1
	mov 	cr0, eax 	
	; 1 more instruction to execute in
	; 16 bit real mode, then we'll be
	; in 32-bit mode !
	jmp 	GDT_32_CODE:pmode_init

[bits 32]
; Function to initialize pmode
pmode_init:
	mov 	ax, GDT_32_DATA
	mov 	ds, ax
	mov 	ss, ax
	mov  	es, ax
	mov 	fs, ax
	mov 	gs, ax

	; Setting up new stack
	mov 	ebp, 0x90000
	mov 	esp, ebp

	call 	pmode

; Function that's in protected 32-bit mode.
; entering to kernel!
pmode:
	push 	ebp
	mov 	ebp, esp
	
	xor 	eax, eax
	xor 	ebx, ebx
	xor 	ecx, ecx
	mov 	eax, 0x1000


; Look for kernel signature
search_loop:
	inc 	ecx
	cmp 	eax, 0xfffa
	jge 	notfound
	cmp 	word [eax + ecx], 0x4141
	jne 	search_loop
	; Apparently kernel was found !
	add 	ecx, 2
	cmp 	word [eax + ecx], 0xb00b
	jne 	search_loop
	add 	ecx, 2
	cmp 	word [eax + ecx], 0x4141
	jne 	search_loop
	add 	ecx, 2
	mov 	ebx, eax
	add 	ebx, ecx

	jmp 	ebx

notfound:
	mov 	eax, 1
done:
	cli
	hlt



