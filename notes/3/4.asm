tab db 1,2,3,4,5,6,7,8,9,10
    mov rax, 0 ;suma
    mov rcx, 0
L2: cmp rcx, 10
    jge L1
    add ax, [tab + rcx]
    inc rcx
    jmp L2
L1: ret


tab dd 1,2,3,4,5,6,7,8,9,10
    mov rax, 0 ;suma
    mov rcx, 9
L2: add eax, [tab + rcx * 4]
    dec rcx
    cmp rcx, 0
    jge L2
    ret

tab dd 1,2,3,4,5,6,7,8,9,10
    mov rax, 0 ;suma
    mov rcx, 9
L2: add eax, [tab + rcx * 4]
    loop L2
    ret

tab dd 1,2,3,4,5,6,7,8,9,10
    mov rax, 0 ;suma
    mov rcx, 10
L2: add eax, [tab - 4 + rcx * 4]
    loop L2
    ret

    sub rdi, 4
    mov rax, 0 ;suma
    mov rcx, rsi
L2: add eax, [rdi + rcx * 4]
    loop L2
    ret

    mul rsi, 4
    mov rax, 0 ;suma
    mov rcx, rdi
L2: add eax, [rdi]
    add rdi, 4
    cmp rdi, rcx + rsi
    jl L2
    ret
    
    mov rax, 0 ;suma
    lea rcx, [rdi + rsi * 4]
L2: add eax, [rdi]
    add rdi, 4
    cmp rdi, rcx
    jl L2
    ret

