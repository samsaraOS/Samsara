;***
; Enabling a20 line
;***
%ifndef A20_FUN
%define A20_FUN 1
global enable_a20line

enable_a20line:
	push 	ebp
	mov 	ebp, esp

	xor 	eax, eax
	mov 	ax, 0x2403
	int 	0x15
	jb 	.a20_not_supported
	cmp 	ah, 0
	jnz 	.a20_not_supported

	mov 	ax, 0x2402
	int 	0x15
	jb 	.a20_nostatus
	cmp 	ah, 0
	jnz 	.a20_nostatus

	cmp 	al, 1
	jz 	.end

	mov 	ax, 0x2401
	int 	0x15
	jb 	.a20_failed
	cmp 	ah, 0
	jnz 	.a20_failed

	jmp 	.end
.a20_not_supported:
	add 	eax, 1
.a20_nostatus:
	add 	eax, 1
.a20_failed:
	add 	eax, 1
.end:
	mov 	esp, ebp
	pop 	ebp
	ret

%endif

