locate:	mov rax, rsi

L1:	cmp byte[rax], 0
	je nie
	cmp [rax], dil
	je tak
	inc rax
	jmp L1

nie:	mov rax, -1
	ret

tak:	sub rax, rsi
	ret
