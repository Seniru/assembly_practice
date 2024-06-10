.intel_syntax noprefix

.include "system.s"
.include "string.s"
.include "print.s"
.include "mman.s"
.include "random.s"


.global _start

.macro printr register=rax
    mov     r8, \register
    call    print_usigned_int
.endm

.macro print_newline
    lea     r8, [newline]
    mov     r9, 1
    call    print_string
.endm

.data
    message:
        .ascii "Hello world\n"
        messageLen = $ - message
    name: .asciz "Seniru Pasan"
    formatted_message: .asciz "\n\nHello %s\n==========\nAge - %d\nHeight - %d cm\n"
    newline: .asciz "\n"
    n1: .float 255.1
        


.text

main:
    call _start

_start:
    # create new stack frame
    push rbp
    mov rbp, rsp

    # call random
    # printr rax

    getrandomint        69, 420
    printr rax

    leave
    jmp exit
    