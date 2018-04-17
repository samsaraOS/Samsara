%ifndef INT_HAND
%define INT_HAND 1

bits 64
align 8

section .text

global  interrupt_handler

;***
;*      interrupt_handler function is a wrapper for real interrupt handling
;*      routine (interrupt_dispatch). It's job is simple: save the state of the
;*      registers, rflags and call the interrupt_dispatch().
;***
interrupt_handler:
        push    rax
        push    rbx
        push    rcx
        push    rdx
        push    rsi
        push    rdi
        push    r8
        push    r9
        push    r10
        push    r11
        push    r12
        push    r13
        push    r14
        push    r15
        push    rflags

        call   interrupt_dispatcher

        pop     rflags
        push    r15
        push    r14
        push    r13
        push    r12
        push    r11
        push    r10
        push    r9
        push    r8
        push    rdi
        push    rsi
        push    rdx
        push    rcx
        push    rbx
        push    rax
        iret


interrupt_dispatcher:

        mov     r15,[rsp+0x90]  ;* get the interrupt vector
        cmp     r15,0x0
        je      div_by_zero
        cmp     r15,0x1
        je      dbg_int
        cmp     r15,0x2
        je      non_maskable
        cmp     r15,0x3
        je      break_point
        cmp     r15,0x4
        je      overflow_detected
        cmp     r15,0x5
        je      out_of_bounds
        cmp     r15,0x6
        je      invalid_opcode
        cmp     r15,0x7
        je      no_coproc
        cmp     r15,0x8
        je      double_fault
        cmp     r15,0x9
        je      coproc_seg_overrun
        cmp     r15,0xA
        je      bad_tss
        cmp     r15,0xB
        je      seg_not_present
        cmp     r15,0xC
        je      stack_fault
        cmp     r15,0xD
        je      general_prot
        cmp     r15,0xE
        je      page_fault
        cmp     r15,0xF
        je      unknown_int
        cmp     r15,0x10
        je      coproc_fault
        cmp     r15,0x11
        je      align_check
        cmp     r15,0x12
        je      machine_check
        cmp     r15,0x88
        je      samsara_int

%include "interrupt_handlers.c"
