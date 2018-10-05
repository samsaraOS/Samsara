global _start
bits 	32

section .multiboot
align	4
dd	0x1BADB002
dd	(1 << 0)  | (1 << 1)
dd	-(0x1BADB002 + ((1 << 0) | (1 << 1)))

section .text
bits 32
_start:
	mov	esp, stack_top

	call check_cpuid
	call check_long_mode

	call set_up_page_tables
	call enable_paging

	extern	_init
	call	_init

	extern	tty_init
	call	tty_init
	lgdt	[GDT64.PTR]




	hlt

check_cpuid:
	pushfd
	pop eax

	mov	ecx, eax
	xor	eax, 1 << 21

	push eax
	popfd

	pushfd
	pop eax
	push ecx
	popfd

	cmp eax, ecx
	je .no_cpuid
	ret
	.no_cpuid:
		mov	al, "1"
		jmp error

check_long_mode:
	mov	eax, 0x80000000
	cpuid
	cmp	eax, 0x80000001
	jb	.no_long_mode

	mov	eax, 0x80000001
	cpuid
	test edx, 1 << 29	  ; test if the LM-bit is set in the D-register
	jz .no_long_mode	   ; If it's not set, there is no long mode
	ret
.no_long_mode:
	mov	al, "2"
	jmp error

set_up_page_tables:
	mov	eax, p3_table
	or	eax, 0x3
	mov	[p4_table], eax

	mov	eax, p2_table
	or	eax, 0b11 ; present + writable
	mov	[p3_table], eax
	xor	ecx, ecx

.map_p2_table:
	mov	eax, 0x200000  
	mul	ecx
	or	eax, 0b10000011 ; present + writable + huge
	mov	[p2_table + ecx * 8], eax 

	inc	ecx
	cmp 	ecx, 0x200 
	jne 	.map_p2_table
	ret

enable_paging:
	mov	eax, p4_table
	mov	cr3, eax

	; enable PAE-flag in cr4 (Physical Address Extension)
	mov	eax, cr4
	or	eax, 1 << 5
	mov	cr4, eax

	; set the long mode bit in the EFER MSR (model specific register)
	mov	ecx, 0xC0000080
	rdmsr
	or	eax, 1 << 8
	wrmsr

	; enable paging in the cr0 register
	mov	eax, cr0
	or	eax, 1 << 31
	mov	cr0, eax
	ret

error:
	mov	[0xb8000], al
	.hang:
		cli
		hlt
		jmp	.hang

section	.rodata
GDT64:
	.NULL:	equ $ - GDT64
		dw	0xFFFF
		dw	0
		db	0
		db	0
		db	1
		db	0
	.CODE:	equ $ - GDT64
		dw	0
		dw	0
		db	0
		db	0x9a
		db	0xaf
		db	0
	.DATA:	equ $ - GDT64
		dw	0
		dw	0
		db	0
		db	0x92
		db	0
		db	0
	.TSS:	equ $ - GDT64
		times 0x64 dw 0
	.PTR: 	equ $ - GDT64 - 1
		dq	GDT64


section .bss
align 4096
p4_table:
	resb 4096
p3_table:
	resb 4096
p2_table:
	resb 4096
stack_bottom:
	resb 64
stack_top:

