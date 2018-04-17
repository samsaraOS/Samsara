bits 64
align 8

section .text

global _init_idt_64

;***
;*      _init_idt wants an address to crete the IDT.
;*      looks for the address in rax register
;***
_init_idt_64:
        cli     ;clearing the interrupts to start setting up the IDT
        mov     rdi,rax ;* copying rax into rdi for iterating the IDT vectors
        push    rax     ;* saving the requested loaction of idtr onto the stack
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
                ;***
                ;* if vector is greater than or equal to 32, we jump
                ;* to second loop and start setting them to NOT PRESENT
                ;* we only do it in reversed.  0xE0 = 0xFF - 0x1F
                ;***
                cmp     rcx,0xE0
                jle     iv_loop_second
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
                mov     [rdi],dx        ;* isr high offset
                add     rdi,0x2
                xor     rdx,rdx         ; the upper 8 bytes are all zero :O
                mov     [rdi],rdx
                add     rdi,0x8
                dec     rcx
                add     rsi,_INT_N_SIZE
                jmp     iv_loop

        iv_loop_second:
                ;***
                ;* we check if vector number is 0x88 (0xFF-0x77).
                ;* if it is, then it's samsara special interrupt and we'll jump
                ;* to iv_samsara to set it up
                ;***

                cmp     rcx,0x77
                je      iv_samsara
                ;***
                ;* since these vectors are empty, we just set NULL as the
                ;* ISR pointer and set the PRESENT flag to 0.
                xor     rdx,rdx
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
                mov     [rdi],dx        ;* isr high offset
                add     rdi,0x2
                mov     [rdi],rdx
                add     rdi,0x8
                dec     rcx
                jmp     iv_loop

        iv_samsara:
                ;***
                ;* this is int 0x88, the special samsara interrupt (syscall)
                ;***
                mov     rdx,int_samsara
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
                mov     [rdi],dx        ;* isr high offset
                add     rdi,0x2
                xor     rdx,rdx         ; the upper 8 bytes are all zero :O
                mov     [rdi],rdx
                add     rdi,0x8
                dec     rcx
                jmp     iv_loop

        iv_loop_end:
                sti     ;* enabling iterrupts again
                pop rax ;* restoring requested IDT location
                lidt rax        ;* loading the idtr
                xor rax,rax
                ret

;***
;* calculate the size of an ISR
;* hope this method works with nasm
;* otherwise should calculate manually and hardcode the offset :(
;***
_INT_N_SIZE:
        dd      _INT_N_END - _INT_N_START

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


        ;* This is special SamsaraOS Interrupt :D
        int_samsara:
        push    0x88
        jmp     interrupt_handler

;***
;* interrupt_handler function will be implemented later (most likely in C)
;***
