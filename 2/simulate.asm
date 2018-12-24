section .bss
    i   resb 4
    x   resb 4
    y   resb 4
    M   resb 8
    M1  resb 8
    M2  resb 8
    G   resb 8
    C   resb 8
    w   resb 4

section .text
    global start
    global step

start:
    push    rbp
    mov     rbp, rsp
    mov     dword [x], edi
    mov     dword [y], esi
    mov     qword [M], rdx
    mov     rax, [rdx]
    mov     qword [M1], rax
    mov     rax, [rdx + 8]
    mov     qword [M2], rax
    mov     qword [G], rcx
    mov     qword [C], r8
    movss   dword [w], xmm0
    leave
    ret

step:
    push    rbp
    mov     rbp, rsp
    mov     dword [rbp - 4], 0    ; i - number of column
    mov     dword [rbp - 8], 0    ; j - number of row
    mov     dword [rbp - 12], 0   ; offs - current cell offset
    mov     eax, dword [x]
    sal     eax, 2
    mov     dword [rbp - 16], eax ; gap - offset difference between rows

    mov     r8, qword [M1]
    mov     r9, qword [M2]

.copy_loop:
    mov     edx, dword [x]
    mov     eax, dword [y]
    imul    eax, edx
    sal     eax, 2
    cmp     dword [rbp - 4], eax
    jge     .post_copy_loop

    mov     rax, qword [M1]
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 4]
    add     rax, rcx
    add     rdx, rcx
    movups  xmm0, [rax]
    movups  [rdx], xmm0
    add     dword [rbp - 4], 16
    jmp     .copy_loop

.post_copy_loop:
    mov     r8, qword [M1]
    mov     r9, qword [M2]
    mov     dword [rbp - 8], 0

.outer_row_loop:
    mov     eax, dword [y]
    cmp     dword [rbp - 8], eax
    jge     .post_outer_row_loop

    mov     dword [rbp - 4], 0

.inner_cell_loop:
    mov     eax, dword [x]
    cmp     dword [rbp - 4], eax
    jge     .post_inner_cell_loop

; update buffer creation
    mov     rax, qword [M1]
    movsxd  rcx, dword [rbp - 12]
    add     rax, rcx
    movups  xmm0, [rax]
    movss   xmm1, dword [w]
    shufps  xmm1, xmm1, 0x00
    mulps   xmm0, xmm1

; upper row update
    cmp     dword [rbp - 8], 0
    jle     .lower_row_update

    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx
    movsxd  rcx, dword [rbp - 16]
    sub     rdx, rcx
    movups  xmm1, [rdx]
    addps   xmm1, xmm0
    movups  [rdx], xmm1

.lower_row_update:
    mov     eax, dword [y]
    sub     eax, 1
    cmp     dword [rbp - 8], eax
    jge     .left_column_update

    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx
    movsxd  rcx, dword [rbp - 16]
    add     rdx, rcx
    movups  xmm1, [rdx]
    addps   xmm1, xmm0
    movups  [rdx], xmm1

.left_column_update:
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx
    sub     rdx, 4
    movups  xmm2, xmm0
    cmp     dword [rbp - 4], 0
    jne     .left_column_addition

.left_border:
    xorps   xmm3, xmm3
    cmpeqps xmm2, xmm2
    movss   xmm2, xmm3
    andps   xmm2, xmm0
    jmp     .left_column_addition

.left_column_addition:
    movups  xmm1, [rdx]
    addps   xmm1, xmm2
    movups  [rdx], xmm1

.right_column_update:
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx
    add     rdx, 4
    movups  xmm2, xmm0
    mov     eax, dword [x]
    sub     eax, 4
    cmp     dword [rbp - 4], eax
    jl     .right_column_addition

.right_border:
    xorps   xmm3, xmm3
    cmpeqps xmm2, xmm2
    movss   xmm2, xmm3
    shufps  xmm2, xmm2, 0x1b
    andps   xmm2, xmm0
    jmp     .right_column_addition

.right_column_addition:
    movups  xmm1, [rdx]
    addps   xmm1, xmm2
    movups  [rdx], xmm1

.heaters_update:
    cmp     dword [rbp - 8], 0
    je      .heaters_addition
    mov     eax, dword [y]
    sub     eax, 1
    cmp     dword [rbp - 8], eax
    jl      .post_updates

.heaters_addition:
    mov     rax, qword [C]
    movsxd  rdx, dword [rbp - 4]
    sal     rdx, 2
    add     rax, rdx
    movups  xmm4, [rax]
    movss   xmm3, dword [w]
    shufps  xmm3, xmm3, 0x00
    mulps   xmm4, xmm3

    mov     rax, qword [M2]
    movsxd  rdx, dword [rbp - 12]
    add     rax, rdx
    movups  xmm3, [rax]
    addps   xmm3, xmm4
    movups  [rax], xmm3

.post_updates:
    add     dword [rbp - 12], 16
    add     dword [rbp - 4], 4
    jmp     .inner_cell_loop

.post_inner_cell_loop:
    add     dword [rbp - 8], 1
    jmp     .outer_row_loop

.post_outer_row_loop:
    mov     rax, qword [M1]
    mov     rdx, qword [M2]
    mov     qword [M1], rdx
    mov     qword [M2], rax
    mov     rcx, qword [M]
    mov     [rcx], rdx
    mov     [rcx + 8], rax
    leave
    ret
