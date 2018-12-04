	mov rax, rdi	;Wynik
	mov rsi, rdi
L1:	cmp [rsi], 0
	je koniec1
	cmp [rsi], ' '
	jne dalej
	inc rsi
	jmp L1
dalej:	mov [rdi], [rsi]
	inc rdi
	inc rsi
	jmp L1
koniec1:cmp [rdi], ' '
	jne L2
	dec rdi
L2:	mov [rdi], 0
koniec:	ret

	cld
	mov rax, rdi	;Wynik
	mov rsi, rdi
	mov dl, 1
L1:	cmp byte [rsi], 0
	je koniec1
	cmp byte [rsi], ' '
	cmovne dl, 1
	jne dalej
	test dl, dl
	cmornz dl, 0
	jz dalej
	inc rsi
	jmp L1
dalej:	mov sb
	jmp L1
koniec1:cmp [rdi], ' '
	jne L2
	dec rdi
L2:	mov byte [rdi], 0
koniec:	ret

