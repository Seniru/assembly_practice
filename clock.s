.intel_syntax noprefix

.include "system.s"
.include "string.s"
.include "print.s"

.global _start

.equ SYS_TIME,              201
.equ SYS_NANOSLEEP,         35

.equ EPOCH_YEAR,            1970
.equ SECONDS_PER_MINUTE,    60
.equ SECONDS_PER_HOUR,      SECONDS_PER_MINUTE * 60
.equ SECONDS_PER_DAY,       SECONDS_PER_HOUR * 24
.equ SECONDS_PER_MONTH,     SECONDS_PER_DAY * 30
.equ SECONDS_PER_YEAR,      SECONDS_PER_DAY * 365
.equ MONTHS_IN_YEAR,        12

.equ LEAP_YEAR,             1

.macro printr register=rax
    mov          r8, \register
    call         print_signed_int
.endm

.macro print_space
    lea         r8, [space]
    mov         r9, 1
    call        print_string
.endm

.macro print_colon
    lea         r8, [colon]
    mov         r9, 1
    call        print_string
.endm

.data

newline:         .ascii "\n"
space:           .ascii " "
colon:           .ascii ":"
clr:             .asciz "\033c"
req:             .quad 1, 0
days_in_months:  .byte 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
leap_year:       .asciz "Leap year\n"
january:         .asciz "January "
february:        .asciz "February "
march:           .asciz "March "
april:           .asciz "April "
may:             .asciz "May "
june:            .asciz "June "
july:            .asciz "July "
august:          .asciz "August "
september:       .asciz "September "
october:         .asciz "October "
november:        .asciz "November "
december:        .asciz "December "
months:          .quad january, february, march, april, may, june, july, august, september, october, november, december


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
    
    mov         rax, SYS_TIME
    syscall
    
    # reset the value
    # resetting has to happen at this very specific place which I'm not sure why
    mov         qword ptr [req], 1

    # formatting unix timestamp into a human readable format
    mov         r15, rax

    mov         rcx, EPOCH_YEAR

calculate_year:
    inc         rcx
    mov         r14, !LEAP_YEAR
    sub         r15, SECONDS_PER_YEAR
    # check if the year is a leap year
    # rdx needs to be cleared out before division
    # https://stackoverflow.com/questions/47520720/floating-point-exception-division-between-integers
    xor         rdx, rdx
    mov         rbx, 4
    mov         rax, rcx
    idiv        rbx
    cmp         rdx, 0
    call        handle_leap_year
    cmp         r15, SECONDS_PER_YEAR
    jge         calculate_year
    # did not handle leap years yet

    # print the year
    printr      rcx
    print_space
    
    # reset counter to calculate months
    xor         rcx, rcx

calculate_month:
    inc         rcx
    lea         rsi, [days_in_months + rcx - 1]
    lodsb
    mov         r13, rax
    imul        r13, SECONDS_PER_DAY
    sub         r15, r13
    cmp         r15, r13
    jge         calculate_month

    dec         rcx
    lea         rsi, [months + 8 * rcx]
    lodsq
    push        rax
    call        printf

    # reset counter to calculate dates
    xor         rcx, rcx

calculate_date:
    inc         rcx
    sub         r15, SECONDS_PER_DAY
    cmp         r15, SECONDS_PER_DAY
    jge         calculate_date

    # print the date
    printr      rcx
    print_space

    xor         rcx, rcx

calculate_hour:
    inc         rcx
    sub         r15, SECONDS_PER_HOUR
    cmp         r15, SECONDS_PER_HOUR
    jge         calculate_hour

    # print the hour
    printr      rcx
    print_colon

    xor         rcx, rcx

calculate_minute:
    inc         rcx
    sub         r15, SECONDS_PER_MINUTE
    cmp         r15, SECONDS_PER_MINUTE
    jge         calculate_minute

    # print the mintue
    printr      rcx
    print_colon

    xor         rcx, rcx

calculate_seconds:
    printr      r15


    # we need to ensure that the entire buffer is flushed before printing again
    # introducing a 1 second delay is the best option here
    # sleep
    mov         rax, SYS_NANOSLEEP
    lea         rdi, [req]  # *rqtp
    syscall

    jmp         time_loop

    # end of program execution
    leave
    jmp         exit

handle_leap_year:
    # substract one extra day
    mov         r14, LEAP_YEAR
    sub         r15, SECONDS_PER_DAY
    ret
