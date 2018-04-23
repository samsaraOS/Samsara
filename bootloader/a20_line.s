;***
; Enabling a20 line
;***
%ifndef A20_FUN
%define A20_FUN 1
global enable_a20line

;***
; Function to check wheter a20 line is enabled
; or not. returns 0 if a20 line is not enabled or
; 1 if a20 line is enabled.
;***
a20line_isenabled:
	push 	bp
	mov 	bp, sp
	pushf
	push 	ds
	push 	es
	push 	di
	push 	si
	cli
	xor 	ax, ax
	mov 	es, ax
	not 	ax
	mov 	ds, ax
	mov 	di, 0x0500
	mov 	si, 0x0510
	mov 	al, byte [es:di]
	push 	ax
	mov 	al, byte [ds:si]
	push 	ax
	mov 	byte [es:di], 0x00
	mov 	byte [ds:si], 0xFF
	cmp 	byte [es:di], 0xFF
	pop 	ax
	mov 	byte [ds:si], al
	pop 	ax
	mov 	byte [es:di], al
	xor 	ax, ax
	je 	.exit
	inc 	ax
.exit:
	pop 	si
	pop 	di
	pop 	es
	pop 	ds
	popf
	mov 	sp, bp
	pop 	bp
	ret

;***
; Enable a20 line with keyboard control.
;***
kbdctl_enable:
	push 	bp
	mov 	bp, sp
	call 	a20wait 	; wait for kbdctl
	mov 	al, 0xAD
	out 	0x64, al 	; write 0xAD to kbdctl
	call 	a20wait
	mov 	al, 0xD0
	out 	0x64, al
	; ************* ;
	call 	a20wait2
	in 	al, 0x60
	push 	eax
	call 	a20wait
	mov 	al, 0xD1
	out 	0x64, al
	call 	a20wait
	pop 	eax
	or 	al, 2
	out 	0x60, al
	call 	a20wait
	mov 	al,  0xAE
	out 	0x64, al
	call 	a20wait
	sti
	mov 	sp, bp
	pop  	bp
	ret
a20wait:
	in 	al,  0x64
	test 	al, 2
	jnz 	a20wait
	ret
a20wait2:
	in 	al, 0x64
	test 	al,  1
	jz 	a20wait2
	ret

;***
; Enable a20 line with fast a20 gate
;***
fast_a20gate:
	push 	bp
	mov 	bp, sp
	in 	al, 0x92 	; read from fast a20 port 0x92
	test 	al, 2
	jnz 	.ret
	or 	al, 2
	and 	al, 0xFE
	out 	0x92, al 	; write or&and value back
.ret:
	mov 	sp, bp
	pop 	bp
	ret

;***
; Enable a20 line via BIOS.
;***
bios_enable:
	push 	bp
	mov 	bp, sp
	xor 	eax, eax
	mov 	ax, 0x2403 	; see if int 15 is supported
	int 	0x15
	jb 	.int15_not_supported
	cmp 	ah, 0
	jnz 	.int15_not_supported
	mov 	ax, 0x2402 	; get a20 status
	int 	0x15
	jb 	.a20_nostatus
	cmp 	ah, 0
	jnz 	.a20_nostatus
	cmp 	al, 1
	jz 	.end
	mov 	ax, 0x2401 	; activate a20 line
	int 	0x15
	jb 	.a20_failed
	cmp 	ah, 0
	jnz 	.a20_failed
	xor 	eax, eax
	jmp 	.end
.int15_not_supported:
	mov 	eax, 3
.a20_nostatus:
	mov 	eax, 2
.a20_failed:
	mov 	eax, 1
.end:
	mov 	sp, bp
	pop 	bp
	ret

;***
; Main function to handle a20 line
; enabling.
;***
enable_a20line:
	push 	bp
	mov 	bp, sp
	call 	a20line_isenabled
	cmp 	ax, 1
	je 	.a20_is_enabled
	call 	kbdctl_enable
	call 	a20line_isenabled
	cmp 	ax, 1
	je 	.a20_is_enabled
	call 	bios_enable
	call 	a20line_isenabled
	cmp 	ax, 1
	je 	.a20_is_enabled
	call 	fast_a20gate
	call 	a20line_isenabled
	cmp 	ax, 1
	je 	.a20_is_enabled
	xor 	eax, eax
	add 	eax, 1
.ret:
	mov 	sp, bp
	pop 	bp
	ret
.a20_is_enabled:
	xor 	eax, eax
	jmp 	.ret


%endif

