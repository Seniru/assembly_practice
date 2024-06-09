.intel_syntax noprefix

.include "system.s"
.include "string.s"
.include "print.s"

.global _start

.data

newline:         .ascii "\n"
clr:             .asciz "\033c"
req:             .quad 1, 0

.text

main:
    call        _start

_start:
    # create new stack frame
    push        rbp
    mov         rbp, rsp

time_loop:
    
    lea         r8, [clr]
    mov         r9, 2
    call        print_string
    
    mov         rax, 201      # sys_time
    syscall
    
    # reset the value
    # resetting has to happen at this very specific place which I'm not sure why
    mov        qword ptr [req], 1

    # formatting unix timestamp into a human readable format
    mov         r8, rax
    call        print_signed_int
    

    # we need to ensure that the entire buffer is flushed before printing again
    # introducing a 1 second delay is the best option here
    # sleep
    mov         rax, 35     # sys_nanosleep
    lea         rdi, [req]  # *rqtp
    syscall

    jmp         time_loop

    # end of program execution
    leave
    jmp         exit
