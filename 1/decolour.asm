R_VALUE     equ 77
G_VALUE     equ 151
B_VALUE     equ 28
SUM_VALUE   equ R_VALUE + G_VALUE + B_VALUE
NUM_COLORS  equ 3

section .text
    global decolour

decolour:
    push    rbp
    mov     rbp, rsp

    mov     qword [rbp - 56], rdi           ; int **matrix
    mov     dword [rbp - 60], esi           ; int x
    mov     dword [rbp - 64], edx           ; int y

    mov     dword [rbp - 4], 0              ; i = 0
    mov     dword [rbp - 8], 0              ; j = 0
    mov     dword [rbp - 12], 0             ; v = 0
    mov     dword [rbp - 16], 0             ; r = 0
    mov     dword [rbp - 20], 0             ; g = 0
    mov     dword [rbp - 24], 0             ; b = 0
    mov     dword [rbp - 28], 0             ; new_j = 0
    mov     dword [rbp - 32], R_VALUE       ; R_VALUE
    mov     dword [rbp - 36], G_VALUE       ; G_VALUE
    mov     dword [rbp - 40], B_VALUE       ; B_VALUE
    mov     dword [rbp - 44], SUM_VALUE     ; SUM_VALUE
    mov     dword [rbp - 48], NUM_COLORS    ; NUM_COLORS

    ; while (i < y)
    jmp     .outer_while_cond

.outer_while_loop:
    ; j = 0
    mov     dword [rbp - 8], 0

    ; while (j < NUM_COLORS * x)
    jmp     .inner_while_cond

.inner_while_loop:
    ; r = matrix[i][j]
    mov     rdi, qword [rbp - 56]
    movsxd  rax, dword [rbp - 4]
    mov     rax, qword [rdi + 8 * rax]
    movsxd  rdi, dword [rbp - 8]
    mov     ecx, dword [rax + 4 * rdi]
    mov     dword [rbp - 16], ecx

    ; j++
    inc     dword [rbp - 8]

    ; g = matrix[i][j]
    mov     rdi, qword [rbp - 56]
    movsxd  rax, dword [rbp - 4]
    mov     rax, qword [rdi + 8 * rax]
    movsxd  rdi, dword [rbp - 8]
    mov     ecx, dword [rax + 4 * rdi]
    mov     dword [rbp - 20], ecx

    ; j++
    inc     dword [rbp - 8]

    ; b = matrix[i][j]
    mov     rdi, qword [rbp - 56]
    movsxd  rax, dword [rbp - 4]
    mov     rax, qword [rdi + 8 * rax]
    movsxd  rdi, dword [rbp - 8]
    mov     ecx, dword [rax + 4 * rdi]
    mov     dword [rbp - 24], ecx

    ; j++
    inc     dword [rbp - 8]

    ; r *= R_VALUE
    mov     eax, dword [rbp - 16]
    imul    eax, dword [rbp - 32]
    mov     dword [rbp - 16], eax

    ; g *= G_VALUE
    mov     eax, dword [rbp - 20]
    imul    eax, dword [rbp - 36]
    mov     dword [rbp - 20], eax

    ; b *= B_VALUE
    mov     eax, dword [rbp - 24]
    imul    eax, dword [rbp - 40]
    mov     dword [rbp - 24], eax

    ; v += r
    mov     eax, dword [rbp - 16]
    add     dword [rbp - 12], eax

    ; v += g
    mov     eax, dword [rbp - 20]
    add     dword [rbp - 12], eax

    ; v += b
    mov     eax, dword [rbp - 24]
    add     dword [rbp - 12], eax

    ; v /= SUM_VALUE
    mov     eax, dword [rbp - 12]
    cdq
    idiv    dword [rbp - 44]
    mov     dword [rbp - 12], eax

    ; new_j = j / NUM_COLORS
    mov     eax, dword [rbp - 8]
    cdq
    idiv    dword [rbp - 48]
    mov     dword [rbp - 28], eax

    ; matrix[i][new_j] = v
    mov     eax, dword [rbp - 12]
    mov     rdi, qword [rbp - 56]
    movsxd  rcx, dword [rbp - 4]
    mov     rcx, qword [rdi + 8 * rcx]
    movsxd  rdi, dword [rbp - 28]
    mov     dword [rcx + 4 * rdi], eax

.inner_while_cond:
    ; j < NUM_COLORS * x ?
    mov     eax, dword [rbp - 48]
    imul    eax, dword [rbp - 60]
    cmp     dword [rbp - 8], eax
    jl      .inner_while_loop

    ; i++
    inc     dword [rbp - 4]

.outer_while_cond:
    ; i < y ?
    mov     eax, dword [rbp - 4]
    cmp     eax, dword [rbp - 64]
    jl      .outer_while_loop

    pop     rbp
    ret
