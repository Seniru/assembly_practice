.intel_syntax noprefix

.global random
.global getrandom

.equ SYS_GETRANDOM,         318

.macro getrandomint from to
    push        r12
    push        r13
    mov         r12, \from
    mov         r13, \to
    call        getrandom
    pop         r13
    pop         r12
.endm

/*
    r12: from
    r13: to
*/
getrandom:
    push        r12
    push        r13
    call        random
    # round(from + random() * (to - from))

    # to - from
    sub         r13, r12

    mov         rbx, 0xff
    cvtsi2ss    xmm0, rax
    cvtsi2ss    xmm1, rbx
    cvtsi2ss    xmm2, r12
    cvtsi2ss    xmm3, r13

    # random byte / 255 (to simulate random()'s behaviour)
    divss       xmm0, xmm1
    # random() * (to - from)
    mulss       xmm0, xmm3
    # from + random() * (to - from)
    addss       xmm0, xmm2
    # round the whole thing and return it to rax
    cvtss2si    rax, xmm0

    pop         r13
    pop         r12
    ret


random:
    # allocate memory for one byte
    malloc      1
    # store the allocated memory in r8
    mov         r8, rax

    mov         rax, SYS_GETRANDOM
    mov			rdi, r8         # *buffer
    mov         rsi, 1          # count
    xor         rdx, rdx        # flags
    syscall

    mov         rsi, rdi
    lodsb
    mov         r9, rax
    # free the allocated memory
    free        r8, 1
    # return the random byte
    mov         rax, r9
    ret
