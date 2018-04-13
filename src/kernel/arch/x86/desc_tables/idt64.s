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
        lidt    rdi             ;loading the idtr
        xor     rax,rax
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
                cmp     rcx,0x20
                jge     iv_loop_second
                test    rcx,rcx
                je      iv_loop_end
                mov     rdx,rsi         ;* getting _isr_wrapper adrress
                mov     [rdi],dx        ;* isr low offset [bits 0-15]
                add     rdi,0x2
                mov     [rdi],bx        ;* segment selector [bits 16-31]
                add     rdi,0x2
                ;***
                ;* 0x8c00 = 1000110000000000 = P DPL 0 TYPE(Interrupt)=0110  0 0 0 0 0 IST
                ;* set IST to 0. present flag = 1, priv level = 0,
                ;* type = 64-bit mode interrupt
                ;***
                mov     [rdi],0x8C00
                shr     rdx,0x10
                add     rdi,0x2
                mov     [rdi],dx        ;* isr high offset [bits
                add     rdi,0x2
                xor     rdx,rdx         ; the upper 8 bytes are all zero :O
                mov     [rdi],rdx
                add     rdi,0x8
                dec     rcx
                add     rsi,_INT_N_SIZE
                jmp     iv_loop

        iv_loop_second:
                cmp     rcx,0x88
                je      iv_samsara
                xor     rdx,rdx         ;* getting _isr_wrapper adrress
                mov     [rdi],dx        ;* isr low offset [bits 0-15]
                add     rdi,0x2
                mov     [rdi],bx        ;* segment selector [bits 16-31]
                add     rdi,0x2
                ;***
                ;* 0x0c00 = 0000111000000000 = NOT PRESENT DPL 0 TYPE(Interrupt)=0110  0 0 0 0 0 IST
                ;* set IST to 0. present flag = 1, priv level = 0,
                ;* type = 64-bit mode interrupt
                ;***
                mov     [rdi],0x0C00
                add     rdi,0x2
                mov     [rdi],dx        ;* isr high offset [bits
                add     rdi,0x2
                mov     [rdi],rdx
                add     rdi,0x8
                dec     rcx
                jmp     iv_loop

        iv_samsara:
                mov     rdx,int_samsara         ;* getting _isr_wrapper adrress
                mov     [rdi],dx                ;* isr low offset [bits 0-15]
                add     rdi,0x2
                mov     [rdi],bx                ;* segment selector [bits 16-31]
                add     rdi,0x2
                ;***
                ;* 0x8c00 = 1000110000000000 = P DPL 0 TYPE(Interrupt)=0110  0 0 0 0 0 IST
                ;* set IST to 0. present flag = 1, priv level = 0,
                ;* type = 64-bit mode interrupt
                ;***
                mov     [rdi],0x8C00
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


_INT_N_SIZE:
        dd      _INT_N_END - _INT_N_START       ;* calculate the size of

_isr_wrapper:
        ;***
        ;*      interrupt service routine stub supports only intel interrupts
        ;*      plus SamsaraOS interrupt 0x88
        ;***
        _INT_N_START:   ;* these are for size calculation
        push	0x0
        jmp	interrupt_handler
        _INT_N_END:     ;* these are for size calculation

        push	0x1
        jmp	interrupt_handler

        push	0x2
        jmp	interrupt_handler
        _int_0:
        push	0x3
        jmp	interrupt_handler

        push	0x4
        jmp	interrupt_handler

        push	0x5
        jmp	interrupt_handler

        push	0x6
        jmp	interrupt_handler

        push	0x7
        jmp	interrupt_handler

        push	0x8
        jmp	interrupt_handler

        push	0x9
        jmp	interrupt_handler

        push	0xa
        jmp	interrupt_handler

        push	0xb
        jmp	interrupt_handler

        push	0xc
        jmp	interrupt_handler

        push	0xd
        jmp	interrupt_handler

        push	0xe
        jmp	interrupt_handler

        push	0xf
        jmp	interrupt_handler

        push	0x10
        jmp	interrupt_handler

        push	0x11
        jmp	interrupt_handler

        push	0x12
        jmp	interrupt_handler

        push	0x13
        jmp	interrupt_handler

        push	0x14
        jmp	interrupt_handler

        push	0x15
        jmp	interrupt_handler

        push	0x16
        jmp	interrupt_handler

        push	0x17
        jmp	interrupt_handler

        push	0x18
        jmp	interrupt_handler

        push	0x19
        jmp	interrupt_handler

        push	0x1a
        jmp	interrupt_handler

        push	0x1b
        jmp	interrupt_handler

        push	0x1c
        jmp	interrupt_handler

        push	0x1d
        jmp	interrupt_handler

        push	0x1e
        jmp	interrupt_handler

        push	0x1f
        jmp	interrupt_handler

        ;* This is special SamsaraOS Interrupt :D
        int_samsara:
        push    0x88
        jmp     interrupt_handler


interrupt_handler:
        ;***
        ;* To Be Continued :D
        ;***
