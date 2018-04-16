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
;*      which stands for: entry=0x13, TI=0 (GDT), RPL= 00 (ring 3)
;*      we'll implement ring protection in paging
;***
_init_gdt_64:
        push    rbp
        mov     rbp,rsp
        cli     ;clearing interrupts
        mov     rdi,rax ;* copying rax into rdi for iterating the GDT entries
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
                        ;* base and limit are ignore in 64-bit mode
                        mov     [rdi],r8d
                        add     rdi,0x4
                        ;***
                        ;* 0xBE00 = 1011111000000000 which stands for:
                        ;* Present, DPL=3,S=0 (Not system! It's Code/Data)
                        ;* Type=Execute/Read/Accessed/Non-Conforming (CODE)
                        ;* middle base = 0 (8-bits, ignored)
                        ;***
                        mov     [rdi],0xBE00
                        add     rdi,0x2
                        ;***
                        ;* 0x00B0 = 0000000010110000 which stands for:
                        ;* high base = 0 (ignored), G=1 (4-KB aligned), D=0,
                        ;* L=1 (64-Code), AVL=1, high limit = 0 (8-bits,ignored)
                        ;***
                        mov     [rdi],0x00B0
                        add     rdi,0x2
                        inc rcx

                        ;* now we set up our data segment
                        mov     [rdi],r8d
                        add     rdi,0x4
                        ;***
                        ;* 0x3E00 = 0011111000000000 which stands for:
                        ;* Present, DPL=3,S=0 (Not system! It's Code/Data)
                        ;* Type=Read/Write/Accessed (DATA)
                        ;* middle base = 0 (8-bits, ignored)
                        ;***
                        mov     [rdi],0xEE00
                        add     rdi,0x2
                        ;***
                        ;* 0x00D0 = 00000000011010000 which stands for:
                        ;* high base = 0 (ignored), G=1 (4-KB aligned), D=1,
                        ;* L=0 (Not 64-Code), AVL=1,
                        ;* high limit = 0 (8-bits,ignored)
                        ;***
                        mov     [rdi],0x00D0
                        add     rdi,0x2
                        inc rcx

                        jmp     _gdt_loop

                _gdt_loop_end:
                        ;***
                        ;*      rax holds the base address
                        ;*      rdi     points to the limit
                        ;***
                        sub     rdi,rax
                        ;* we only need the lower 16-bits of the limit
                        and     rdi, 0x000000000000FFFF
                        push    rdi
                        sub     rsp,0x2
                        push    rax
                        lgdt    [rsp]   ;* loading the 80-bits value into gdtr 
                        add     rsp,0xA
                        pop     rbp
                        sti
                        xor     rax,rax
                        ret
