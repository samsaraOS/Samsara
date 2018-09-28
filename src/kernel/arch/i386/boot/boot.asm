; BSD 3-Clause License
; 
; Copyright (c) 2018, Samsara OS
; All rights reserved.
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
; 
; * Redistributions of source code must retain the above copyright notice, this
;   list of conditions and the following disclaimer.
; 
; * Redistributions in binary form must reproduce the above copyright notice,
;   this list of conditions and the following disclaimer in the documentation
;   and/or other materials provided with the distribution.
; 
; * Neither the name of the copyright holder nor the names of its
;   contributors may be used to endorse or promote products derived from
;   this software without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[BITS 	32]

; Constants for multiboot header
MULTIBOOT_ALIGN 	equ 	1 << 0
MULTIBOOT_MEM_MAP 	equ 	1 << 1
; Add more flags if needed
MULTIBOOT_FLAGS 	equ 	MULTIBOOT_ALIGN | MULTIBOOT_MEM_MAP
MULTIBOOT_MAGIC 	equ 	0x1BADB002
MULTIBOOT_CHECKSUM 	equ 	-(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

section	.multiboot
align 	4
dd 	MULTIBOOT_MAGIC
dd 	MULTIBOOT_FLAGS
dd 	MULTIBOOT_CHECKSUM

section	.bss
align	16
stack_btm:
	resb 	16384
stack_top:
section .text

global _start
_start:
	; Just in case, disable interrupts
	cli

	; initializing c runtime environment 
	mov 	esp, stack_btm
	extern 	_init
	call 	_init

	extern 	tty_init
	call 	tty_init

	; Clearing paging if it has been set up.
	mov 	eax, cr0
	and 	eax, 0x7fffffff
	mov 	cr0, eax

	; Loading the global descriptor table.
	lgdt	[GDT64.Ptr]


	; Calling kinit, a initializion function for setting
	; up 64-bit long mode. The sole purpose of this is
	; to prepare environment for our main kernel function (kmain)
	; to run in. We don't support 32-bit platform, period.
 	;
	; kinit() takes one argument, void pointer to multiboot header,
	; grub stores this pointer for us to EBX, so we just push it and
	; be happy :)

	push 	ebx
	extern 	kinit
	call 	kinit

.hang:
	cli
	hlt
	jmp 	.hang

GDT64:
	.Null: equ $ - GDT64
		dw 0xFFFF
		dw 	0	
		db 	0
		db 	0
		db 	1
		db 	0
	.Code: equ $ - GDT64
		dw 	0
		dw	0
		db	0
		db	0x9a
		db	0xaf
		db	0
	.Datai: equ $ - GDT64
		dw 	0
		dw	0
		db	0
		db	0x92
		db	0
		db	0
	.TSS: equ $ - GDT64
		times 0x64 dw 0
	.Ptr: equ $ - GDT64 - 1
		dq	GDT64


