.intel_syntax noprefix

.include "system.s"
.include "print.s"

.global _start

.data
    message1:
        .ascii "Hello world\n"
        message1Len = $ - message1
    message2:
        .ascii "Today we are doing assembly!\n"
        message2Len = $ - message2
    message3:
        .ascii "Bye world!\n"
        message3Len = $ - message3


.text

main:
    call _start

_start:
    mov r8, 69420
    call print_int

    jmp exit
    