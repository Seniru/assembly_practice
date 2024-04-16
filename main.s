.intel_syntax noprefix

.include "system.s"
.include "string.s"
.include "print.s"


.global _start

.data
    message:
        .ascii "Hello world\n"
        messageLen = $ - message
    name: .asciz "Seniru Pasan"
    formatted_message: .asciz "\n\nHello %s\n==========\nAge - %d\nHeight - %d cm\n"
        


.text

main:
    call _start

_start:
    # create new stack frame
    push rbp
    mov rbp, rsp

    # printing a string
    lea r8, [message]
    mov r9, messageLen
    call print_string

    # print an unsigned integer
    mov r8, 420
    call print_usigned_int

    # print a signed integer
    mov r8, -500
    call print_signed_int

    # print formatted string
    lea rax, [formatted_message]
    lea rbx, [name]

    push rax
    push rbx
    push 21
    push 100
    call printf

    leave
    jmp exit
    