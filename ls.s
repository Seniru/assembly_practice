.intel_syntax noprefix

.include "system.s"
.include "string.s"
.include "print.s"

.global _start

.data
    pwd: .asciz "Contents of %s\n"
    newline: .asciz "\n"
        

.bss
    .lcomm cwdir 256
    .lcomm entry 1024

.text


main:
    call _start

_start:

    # create new stack frame
    push rbp
    mov rbp, rsp

    # print current working directory
    mov rax, 79         # sys_getcwd
    lea rdi, [cwdir]    # *buffer
    mov rsi, 256        # size
    syscall

    lea rax, [pwd]
    lea rbx, [cwdir]
    push rax
    push rbx
    call printf

    # get file descriptor for directory
    mov rax, 2          # sys_open
    lea rdi, [cwdir]    # filename
    mov rsi, 0          # mode (0 = O_RDONLY)
    mov rdx, 65536      # flags (65536 = O_DIRECTORY)
    syscall


    # print all the entires
    mov rax, 78        # sys_getdents
    mov rdi, 3         # fd
    lea rsi, [entry]   # *dirent
    mov rdx, 1024      # count
    syscall

    # set rdi to the end of the struct
    mov rdi, rsi
    add rdi, rax

print_entries:
    lodsq       # d_inode
    lodsq       # d_off
    mov r10, rax
    lodsw       # d_reclen
    mov r11, rax

    # calculate the string length
    # string start = 18 (sizeof(long) + sizeof(long) + sizeof(short))
    # string end = d_reclen - 2
    # string length = d_reclen - 20 (string_start + string_end)
    sub rax, 20
    
    # print the entry
    mov r8, rsi
    mov r9, rax
    call print_string
    add rsi, r9

    lodsb       # padding byte
    lodsb       # d_type

    lea r8, [newline]
    mov r9, 1
    call print_string
  
    cmp rsi, rdi
    jne print_entries

    leave
    jmp exit

