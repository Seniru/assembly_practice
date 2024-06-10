.intel_syntax noprefix

.equ SYS_MMAP,          9
.equ SYS_MUNMAP,        11
.equ PROT_READ,         1
.equ PROT_WRITE,        2
.equ MAP_PRIVATE,       2
.equ MAP_ANONYMOUS,     32
.equ NULL,              0

.global malloc
.global free
.global mmap
.global munmap

.macro malloc len
    push         r12
    mov          r12, \len
    call         mmap
    pop          r12
.endm

.macro free addr, len
    push        r12
    push        r13
    mov         r12, \addr
    mov         r13, \len
    call        munmap
    pop         r13
    pop         r12
.endm

.text

mmap:
    mov         rax, SYS_MMAP
    mov         rdi, NULL
    mov         rsi, r12
    mov         rdx, PROT_READ | PROT_WRITE
    mov         r10, MAP_PRIVATE | MAP_ANONYMOUS
    mov         r8, -1
    mov         r9, 0
    syscall
    ret

munmap:
    mov         rax, SYS_MUNMAP
    mov         rdi, r12
    mov         rsi, r13
    syscall
    ret


    
