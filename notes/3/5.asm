	section .bss
znak	resb 1
WRITE	equ 1
	section .text
	mov [znak], dil
	mov rcx, rsi
L1:	push rcx
	mov rdi, 1
	lea rsi, [znak] ; mov rsi, znak
	mov rdx, 1
	mov rax, WRITE
	sysenter
	pop rcx
	loop L1

	section .bss
znak	resb 100
WRITE	equ 1
	section .text
	mov rcx, rsi
	jrcxz L2
L1:	mov [znak - 1 + rcx], dil
	loop L1
	mov rdi, 1
	mov rdx, rsi
	mov rsi, buf
	mov eax, WRITE
	sysenter
L2:

	section .bss
znak	resb 100
WRITE	equ 1
	section .text
	mov [rsp], rdi
	dec rsp
	mov rcx, rsi
	jrcxz L2
L1:	mov [znak - 1 + rcx], dil
	loop L1
	mov rdi, 1
	mov rdx, rsi
	mov rsi, buf
	mov eax, WRITE
	sysenter
L2:



