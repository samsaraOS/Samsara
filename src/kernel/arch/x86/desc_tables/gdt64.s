;***
;* this file contains the initial GDT64 before jumping to 64 protected mode
;***
bits 64
align 8

section .text

global _init_gdt_64

;***
;*      _init_gdt_64 wants an address to crete the GDT
;*      looks for the address in rax register
;*
;*      this gdt will have 32 entries
;*      entry number 0x12 (18 decimal) is the CODE_64 entry
;*      entry number 0x16 (22 decimal) is the DATA_64 entry
;*      they're both overlapping and address the entire address space :D
;*      CS = 0x90 = 10010000
;*      which stands for: entry=0x12, TI=0 (GDT), RPL = 00 (ring 0)
;*      DS,SS,ES = 0x98 = 10011000
;*      which stands for: entry=0x13, TI=0 (GDT), RPL= 00 (ring 0)
;*      later the privilege level must be changed to 11 (ring 3)
;*      and use paging for protection
;***
_init_gdt_64:
        cli     ;clearing interrupts
        mov     rdi,rax ;* copying rax into rdi for iterating the GDT entries
        push    rax     ;* saving the requested loaction of gdtr onto the stack
        xor     rcx,rcx
        xor     r8,r8

        ;***
        ;* we just attempt to set up 32 GDT entries
        ;***
        _gdt_loop:
                cmp     rcx,0x12        ;* check if entry=0x12
                je      _gdt_kernel_code_64 ;* jump to set up code_64 segment
                cmp     rcx,0x20
                je      _gdt_loop_end
                mov     [rdi],r8        ;* any entry other than 0x12 will be 0
                add     rdi,0x8         ;* each gft entry is 8 bytes
                inc     rcx
                jmp _gdt_loop

                _gdt_kernel_code_64:
                ;* be continued :D



                _gdt_loop_end:
