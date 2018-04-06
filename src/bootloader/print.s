%ifndef PRINT_H
%define PRINT_H

;***
; Functionality related to printing to screen.
;***

calc_y_coordinate:
        movzx ax, byte [yco]
        ; adding the ax by 160 which is the number of 
	; characters in 1 row time 2
        ; because each characters is 2 bytes in video memory
        ; (first byte is the character and the second is the attribute)
        mov dx,160
        ; the we multiply dx by ax (which was the y counter)
        mul dx
        ret

calc_x_coordinate:
        ; we do the same for x coordinate but a bit differently
        movzx bx, byte [xco]
        shl bx, 1
        ret

calc_coordinates:
  	; di is the calculated postion of the video memory
  	; di = (xco * 2) + (yco * 80 * 2)
        mov di, 0
        add di, ax
        add di, bx
        ret

clear_coordinates:
        mov byte [xco],0
        mov byte [yco],0
        ret

clear:
        call calc_y_coordinate
        call calc_x_coordinate
        call calc_coordinates
        mov ah,0x0F
        mov al,0x20
        stosw
        add byte [xco],1
        cmp cx,0x50
        jne .clear_cont
        add byte [yco],1
        mov byte [xco],0
        .clear_cont:
                dec cx
                cmp cx,0
                jne clear
                ret

; here we declare a fuction for printing characters on the screen
print:
        .load_next_char:
        lodsb
        cmp al,0
        jne .print_char
        mov cx,0x07D0
        call clear
        ret

        .print_char:
                cmp al,0xA
                je .print_newline
                mov ah,0x0F
                push ax
                call calc_y_coordinate
                call calc_x_coordinate
                call calc_coordinates
                pop ax
                stosw
                add byte [xco],1
                cmp byte [xco],0x50
                jne .load_next_char
                add byte [yco],1
                mov byte [xco],0
                jmp .load_next_char

        .print_newline:
                add byte [yco],1
                call calc_y_coordinate
                mov byte [xco],0
                call calc_x_coordinate
                call calc_coordinates
                mov ax,0x0020
                stosw
                jmp .load_next_char

xco   db 0
yco   db 0

%endif
