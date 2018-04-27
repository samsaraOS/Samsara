
section .bss
align 4
stack_bottom:
	resb 	16358 	; stack
section .text
stack_top:
align 16
bits 	32
global _start
; Signature for bootloader
dw 	0x4141
dw 	0xb00b
dw 	0x4141
_start:
	mov 	esp, stack_top
	cli
	hlt

	extern 	kmain
	call 	kmain

	cli
	hlt


