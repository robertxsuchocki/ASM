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
    mov     qword [M1], rax     ; M1 - pointer to the first matrix
    mov     rax, [rdx + 8]
    mov     qword [M2], rax     ; M2 - pointer to the second matrix
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
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx
    movups  xmm1, [rdx]
    subps   xmm1, xmm0
    movups  [rdx], xmm1
    cmp     dword [rbp - 8], 0
    jle     .lower_row_update

    movsxd  rcx, dword [rbp - 16]
    sub     rdx, rcx
    movups  xmm1, [rdx]
    addps   xmm1, xmm0
    movups  [rdx], xmm1

.lower_row_update:
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx
    movups  xmm1, [rdx]
    subps   xmm1, xmm0
    movups  [rdx], xmm1
    mov     eax, dword [y]
    sub     eax, 1
    cmp     dword [rbp - 8], eax
    jge     .left_column_update

    movsxd  rcx, dword [rbp - 16]
    add     rdx, rcx
    movups  xmm1, [rdx]
    addps   xmm1, xmm0
    movups  [rdx], xmm1

.left_column_update:
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx
    mov     rcx, rdx
    sub     rdx, 4
    movups  xmm2, xmm0
    movups  xmm1, [rcx]
    subps   xmm1, xmm2
    movups  [rcx], xmm1
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
    mov     rcx, rdx
    add     rdx, 4
    movups  xmm2, xmm0
    movups  xmm1, [rcx]
    subps   xmm1, xmm2
    movups  [rcx], xmm1
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
    mov     rax, qword [G]
    movsxd  rdx, dword [rbp - 4]
    sal     rdx, 2
    add     rax, rdx
    movups  xmm4, [rax]
    movss   xmm3, dword [w]
    shufps  xmm3, xmm3, 0x00
    mulps   xmm4, xmm3

.upper_heater:
    cmp     dword [rbp - 8], 0
    jne      .lower_heater

    mov     rax, qword [M2]
    movsxd  rdx, dword [rbp - 12]
    add     rax, rdx
    movups  xmm3, [rax]
    addps   xmm3, xmm4
    movups  [rax], xmm3

.lower_heater:
    mov     eax, dword [y]
    sub     eax, 1
    cmp     dword [rbp - 8], eax
    jne     .post_updates

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
    mov     dword [rbp - 8], 0
    mov     dword [rbp - 12], 0

.cooling_loop:
    mov     eax, dword [y]
    cmp     dword [rbp - 8], eax
    jge     .swap

    mov     rax, qword [C]
    movsx   rdx, dword [rbp - 8]
    sal     rdx, 2
    add     rax, rdx
    movss   xmm0, dword [rax]
    movss   xmm1, dword [w]
    mulss   xmm0, xmm1

    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx
    movss   xmm1, dword [rdx]
    addss   xmm1, xmm0
    movss   dword [rdx], xmm1

    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx
    movsxd  rcx, dword [x]
    sub     rcx, 1
    imul    rcx, 4
    add     rdx, rcx
    movss   xmm1, dword [rdx]
    addss   xmm1, xmm0
    movss   dword [rdx], xmm1

    mov     eax, dword [rbp - 16]
    add     dword [rbp - 12], eax
    add     dword [rbp - 8], 1
    jmp     .cooling_loop

.swap:
    mov     rax, qword [M1]
    mov     rdx, qword [M2]
    mov     qword [M1], rdx
    mov     qword [M2], rax
    mov     rcx, qword [M]
    mov     [rcx], rdx
    mov     [rcx + 8], rax
    leave
    ret
