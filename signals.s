.intel_syntax noprefix

.include "string.s"
.include "print.s"
.include "system.s"

.macro printr register=rax
    mov          r8, \register
    call         print_signed_int
.endm

.macro printchar char
    lea           r8, [\char]
    mov           r9, 1
    call          print_string
.endm

.equ SYS_RT_SIGACTION,      13
.equ SYS_RT_SIGRETURN,      15
.equ SYS_IOCTL,             16
.equ SYS_PAUSE,             34

.equ SIG_WINCH,             28
.equ TIOCGWINSZ,            0x5413



.global _start

.data

rowText:        .ascii "Rows: "
rowTextLen      = $ - rowText
colText:        .ascii "Columns: "
colTextLen      = $ - colText
newline:        .ascii "\n"
space:          .ascii " "

/*
struct sigaction {
    void     (*sa_handler)(int);
    void     (*sa_sigaction)(int, siginfo_t *, void *);
    sigset_t   sa_mask;
    int        sa_flags;
    void     (*sa_restorer)(void);
};
*/
sigaction_winch:
    .quad winch_handler
    .quad 0x04000000
    .quad winch_restorer
    .quad 

.bss
    .lcomm winsize 4

.text




main:
    # create new stack frame
    push        rbp
    mov         rbp, rsp

    call        _start

_start:
    /* just to print the initial rows and columns */
    call        winch_handler
    mov         rax, SYS_RT_SIGACTION
    mov         rdi, SIG_WINCH
    lea         rsi, [sigaction_winch]
    xor         rdx, rdx
    mov         r10, 0x08
    syscall

waiter:
    mov         rax, SYS_PAUSE
    syscall
    jmp         waiter


    jmp         exit

winch_handler:
    mov         rax, SYS_IOCTL
    mov         rdi, 0
    mov         rsi, TIOCGWINSZ
    lea         rdx, [winsize]
    syscall
    lea         r8, [rowText]
    mov         r9, rowTextLen
    call        print_string
    xor         rax, rax
    xor         r8, r8
    mov         ax, word ptr [winsize]
    mov         r8, rax
    call        print_usigned_int
    printchar   space
    lea         r8, [colText]
    mov         r9, colTextLen
    call        print_string
    xor         rax, rax
    xor         r8, r8
    mov         ax, word ptr [winsize+2]
    mov         r8, rax
    call        print_usigned_int
    printchar   newline
    ret


winch_restorer:
    mov         rax, SYS_RT_SIGRETURN
    xor         rdi, rdi
    syscall
    ret

