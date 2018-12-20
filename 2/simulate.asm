section .text
    global start
    global step

start:
    push    rbp
    mov     rbp, rsp
    leave
    ret

step:
    push    rbp
    mov     rbp, rsp
    leave
    ret
