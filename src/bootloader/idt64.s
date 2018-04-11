bits 64
align 8

section .text

global _init_idt

;***
;*      _init_idt wants an address to crete the IDT.
;*      looks for the address in rax register
;***
_init_idt:
        cli     ;clearing the interrupts to start setting up the IDT
        mov     rdi,rax
        mov     idtr,rdi        ;loading the idtr
        mov     rcx,0xFF        ;loop counter to setup all interrupt vectors
        mov     rsi,_isr_wrapper
        mov     rbx,0x12        ;Code Segment
        ;***
        ;* 0x12 in GDT is a Code Segment.
        ;* (I just chose number 18 because it's 2018 :D)
        ;* we have to set index 0x12 (18 decimal in gdt as a code segment!)
        ;* (don't forget)
        ;***
        iv_loop:
                test    rcx,rcx
                je      iv_loop_end
                mov     rdx,rsi         ;* getting _isr_wrapper adrress
                mov     [rdi],dx        ;* isr low offset [bits 0-15]
                add     rdi,0x2
                mov     [rdi],bx        ;* segment selector [bits 16-31]
                add     rdi,0x2
                ;***
                ;* 0x8e00 = 1000111000000000 = P DPL 0 TYPE=0111 0 0 0 0 0 IST
                ;* set IST to 0. present flag = 1, priv level = 0,
                ;* type = 64-bit mode interrupt
                ;***
                mov     [rdi],0x8e00
                shr     rdx,0x10
                add     rdi,0x2
                mov     [rdi],dx        ;* isr high offset [bits
                add     rdi,0x2
                xor     rdx,rdx         ; the upper 8 bytes are all zero :O
                mov     [rdi],rdx
                add     rdi,0x8
                dec     rcx
                jmp     iv_loop

        iv_loop_end:
                xor rax,rax
                ret

_isr_wrapper:
        
