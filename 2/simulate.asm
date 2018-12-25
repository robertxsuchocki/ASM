section .bss
    i       resb 4
    x       resb 4
    x_real  resb 4
    y       resb 4
    M       resb 8
    M1      resb 8
    M2      resb 8
    G       resb 8
    C       resb 8
    w       resb 4

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

    mov     eax, edi
    mov     ecx, eax

.calculate_real_x_value:
    mov     eax, ecx
    and     eax, 3
    test    eax, eax
    je      .return
    add     ecx, 1
    jmp     .calculate_real_x_value

.return:
    ; x_real - real value of x, which is original x rounded up
    ; to be divisible by 4, as operations require row length divisible by 4
    mov     dword [x_real], ecx
    leave
    ret

step:
    push    rbp
    mov     rbp, rsp

    ; i - number of column
    mov     dword [rbp - 4], 0

    ; j - number of row
    mov     dword [rbp - 8], 0

    ; offset - current cell offset
    mov     dword [rbp - 12], 0

    ; gap - offset difference between rows
    mov     eax, dword [x_real]
    sal     eax, 2
    mov     dword [rbp - 16], eax

.copy_loop:
    ; while (i < 4 * x_real * y)
    mov     edx, dword [x_real]
    mov     eax, dword [y]
    imul    eax, edx
    sal     eax, 2
    cmp     dword [rbp - 4], eax
    jge     .post_copy_loop

    ; copy 4 values from M1 to M2 at index i
    mov     rax, qword [M1]
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 4]
    add     rax, rcx
    add     rdx, rcx
    movups  xmm0, [rax]
    movups  [rdx], xmm0

    ; i += 16
    add     dword [rbp - 4], 16
    jmp     .copy_loop

.post_copy_loop:
    ; j = 0
    mov     dword [rbp - 8], 0

.outer_row_loop:
    ; while (j < y)
    mov     eax, dword [y]
    cmp     dword [rbp - 8], eax
    jge     .post_outer_row_loop

    ; i = 0
    mov     dword [rbp - 4], 0

.inner_cell_loop:
    ; while (i < x_real)
    mov     eax, dword [x_real]
    cmp     dword [rbp - 4], eax
    jge     .post_inner_cell_loop

.update_buffer_creation:
    ; get update buffer from address [M1 + offset] and multiply by w
    mov     rax, qword [M1]
    movsxd  rcx, dword [rbp - 12]
    add     rax, rcx
    movups  xmm0, [rax]
    movss   xmm1, dword [w]
    shufps  xmm1, xmm1, 0x00
    mulps   xmm0, xmm1

.upper_row_update:
    ; get address of update buffer in new state
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx

    ; subtract update buffer - give away heat to higher cells
    movups  xmm1, [rdx]
    subps   xmm1, xmm0
    movups  [rdx], xmm1

    ; if (j > 0) - not in the first row, so heat goes up
    ; otherwise there are heaters higher, no update
    cmp     dword [rbp - 8], 0
    jle     .lower_row_update

    ; get address of buffer directly above update buffer
    movsxd  rcx, dword [rbp - 16]
    sub     rdx, rcx

    ; add heat to the higher buffer
    ; (cells i to (i + 3) give heat to cells i to (i + 3) of higher row)
    movups  xmm1, [rdx]
    addps   xmm1, xmm0
    movups  [rdx], xmm1

.lower_row_update:
    ; get address of update buffer in new state
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx

    ; subtract update buffer - give away heat to lower cells
    movups  xmm1, [rdx]
    subps   xmm1, xmm0
    movups  [rdx], xmm1

    ; if (j < (y - 1)) - not in the last row, so heat goes down
    ; otherwise there are heaters lower, no update
    mov     eax, dword [y]
    sub     eax, 1
    cmp     dword [rbp - 8], eax
    jge     .left_column_update

    ; get address of buffer directly below update buffer
    movsxd  rcx, dword [rbp - 16]
    add     rdx, rcx

    ; add heat to the lower buffer
    ; (cells i to (i + 3) give heat to cells i to (i + 3) of lower row)
    movups  xmm1, [rdx]
    addps   xmm1, xmm0
    movups  [rdx], xmm1

.left_column_update:
    ; get address of update buffer in new state
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx

    ; subtract update buffer - give away heat to cells to the left
    movups  xmm1, [rdx]
    subps   xmm1, xmm0
    movups  [rdx], xmm1

    ; copy update buffer
    movups  xmm2, xmm0

    ; get address of buffer one cell to the left of update buffer
    sub     rdx, 4

    ; if (i > 0) - not in the beginning of the row, so all 4 cells go left
    ; otherwise leftmost cell has cooler on the left, we need to 0 its value
    cmp     dword [rbp - 4], 0
    jg     .left_column_addition

.left_border:
    ; remove first value in buffer so we don't pollute previous row
    xorps   xmm3, xmm3
    cmpeqps xmm2, xmm2
    movss   xmm2, xmm3
    ; and value of buffer with a value of [0 1 1 1] prepared above
    andps   xmm2, xmm0
    jmp     .left_column_addition

.left_column_addition:
    ; add heat to the cells on the left
    ; (cells i to (i + 3) give heat to cells (i - 1) to (i + 2) of the same row)
    movups  xmm1, [rdx]
    addps   xmm1, xmm2
    movups  [rdx], xmm1

.right_column_update:
    ; get address of update buffer in new state
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx

    ; subtract update buffer - give away heat to cells to the right
    movups  xmm1, [rdx]
    subps   xmm1, xmm0
    movups  [rdx], xmm1

    ; copy update buffer
    movups  xmm2, xmm0

    ; get address of buffer one cell to the right of update buffer
    add     rdx, 4

    ; if (i < (x_real - 4)) - not in the end of the row, so all 4 cells go right
    ; otherwise rightmost cell has cooler on the right, we need to 0 its value
    mov     eax, dword [x_real]
    sub     eax, 4
    cmp     dword [rbp - 4], eax
    jl     .right_column_addition

.right_border:
    ; remove last value in buffer so we don't pollute next row
    xorps   xmm3, xmm3
    cmpeqps xmm2, xmm2
    movss   xmm2, xmm3
    shufps  xmm2, xmm2, 0x1b
    ; and value of buffer with a value of [1 1 1 0] prepared above
    andps   xmm2, xmm0
    jmp     .right_column_addition

.right_column_addition:
    ; add heat to the cells on the right
    ; (cells i to (i + 3) give heat to cells (i + 1) to (i + 4) of the same row)
    movups  xmm1, [rdx]
    addps   xmm1, xmm2
    movups  [rdx], xmm1

.heating:
    ; get 4 heaters buffer starting at index i
    mov     rax, qword [G]
    movsxd  rdx, dword [rbp - 4]
    sal     rdx, 2
    add     rax, rdx

    ; multiply by w
    movups  xmm4, [rax]
    movss   xmm3, dword [w]
    shufps  xmm3, xmm3, 0x00
    mulps   xmm4, xmm3

.upper_heater:
    ; if (j == 0) - we're at the first row, that's heated by heaters from above
    cmp     dword [rbp - 8], 0
    jne      .lower_heater

    ; get address of update buffer in new state
    mov     rax, qword [M2]
    movsxd  rdx, dword [rbp - 12]
    add     rax, rdx

    ; add heat to that buffer
    movups  xmm3, [rax]
    addps   xmm3, xmm4
    movups  [rax], xmm3

.lower_heater:
    ; if (j == (y - 1)) - we're at the last row heated by heaters from below
    mov     eax, dword [y]
    sub     eax, 1
    cmp     dword [rbp - 8], eax
    jne     .post_updates

    ; get address of update buffer in new state
    mov     rax, qword [M2]
    movsxd  rdx, dword [rbp - 12]
    add     rax, rdx

    ; add heat to that buffer
    movups  xmm3, [rax]
    addps   xmm3, xmm4
    movups  [rax], xmm3

.post_updates:
    ; current += 16
    add     dword [rbp - 12], 16

    ; i += 4
    add     dword [rbp - 4], 4
    jmp     .inner_cell_loop

.post_inner_cell_loop:
    ; j += 1
    add     dword [rbp - 8], 1
    jmp     .outer_row_loop

.post_outer_row_loop:
    ; j = 0
    mov     dword [rbp - 8], 0

    ; current = 0
    mov     dword [rbp - 12], 0

.cooling_loop:
    ; while (j < y)
    mov     eax, dword [y]
    cmp     dword [rbp - 8], eax
    jge     .swap

    ; get cooler at index j
    mov     rax, qword [C]
    movsx   rdx, dword [rbp - 8]
    sal     rdx, 2
    add     rax, rdx

    ; multiply its value by w
    movss   xmm0, dword [rax]
    movss   xmm1, dword [w]
    mulss   xmm0, xmm1

    ; get new state cell at index 0 at row j
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx

    ; cool that cell down
    movss   xmm1, dword [rdx]
    addss   xmm1, xmm0
    movss   dword [rdx], xmm1

    ; get new state cell at index (x - 1) (note: original x) at row j
    mov     rdx, qword [M2]
    movsxd  rcx, dword [rbp - 12]
    add     rdx, rcx
    movsxd  rcx, dword [x]
    sub     rcx, 1
    imul    rcx, 4
    add     rdx, rcx

    ; cool that cell down
    movss   xmm1, dword [rdx]
    addss   xmm1, xmm0
    movss   dword [rdx], xmm1

    ; current += gap
    mov     eax, dword [rbp - 16]
    add     dword [rbp - 12], eax

    ; j += 1
    add     dword [rbp - 8], 1
    jmp     .cooling_loop

.swap:
    ; swap pointers of M1 and M2 in struct M, M2 becomes a current state matrix
    mov     rax, qword [M1]
    mov     rdx, qword [M2]
    mov     qword [M1], rdx
    mov     qword [M2], rax
    mov     rcx, qword [M]
    mov     [rcx], rdx
    mov     [rcx + 8], rax
    leave
    ret
