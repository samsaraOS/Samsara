;***
;* this file contains the initial GDT64 before jumping to 64 protected mode
;***
bits 64
align 8

section .text

global _init_gdt_64:
