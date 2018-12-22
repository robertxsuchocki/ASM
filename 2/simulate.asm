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
    mov     dword [rbp-4], 0
    mov     dword [rbp-8], 0
    mov     dword [rbp-12], 0
    mov     dword [rbp-16], 0
    mov     r8, qword [M1]
    mov     r9, qword [M2]
.L6:
    mov     edx, dword [x]
    mov     eax, dword [y]
    imul    eax, edx
    sal     eax, 2
    cmp     dword [rbp-4], eax
    jge     .L5
    movaps  xmm0, [r8]
    movaps  [r9], xmm0
    add     r8, 16
    add     r9, 16
    add     dword [rbp-4], 16
    jmp     .L6
.L5:
    mov     dword [rbp-8], 0
.L12:
    mov     eax, dword [y]
    cmp     dword [rbp-8], eax
    jge     .L13
    mov     eax, dword [y]
    sal     eax, 2
    mov     dword [rbp-16], eax
    mov     dword [rbp-4], 0
.L11:
    mov     eax, dword [x]
    cmp     dword [rbp-4], eax
    jge     .L8
    mov     eax, dword [rbp-12]
    sub     eax, dword [rbp-16]
    mov     dword [rbp-20], eax
    mov     edx, dword [rbp-12]
    mov     eax, dword [rbp-16]
    add     eax, edx
    mov     dword [rbp-24], eax
    cmp     dword [rbp-8], 0
    jle     .L9
    ; mov up
.L9:
    mov     eax, dword [y]
    sub     eax, 1
    cmp     dword [rbp-8], eax
    jge     .L10
    ; mov down
.L10:
    add     dword [rbp-12], 4
    add     dword [rbp-4], 4
    jmp     .L11
.L8:
    add     dword [rbp-8], 1
    jmp     .L12
.L13:
    mov     rax, qword [M1]
    mov     rdx, qword [M2]
    mov     qword [M1], rdx
    mov     qword [M2], rax
    mov     rcx, qword [M]
    mov     [rcx], rdx
    mov     [rcx + 8], rax
    leave
    ret
