# This does not handle errors appropriately

.intel_syntax noprefix

.include "system.s"
.include "string.s"
.include "print.s"

.global _start

.data
    pwd:        .asciz "Contents of %s\n"
    newline:    .asciz "\n"

    fifo:       .asciz " (FIFO)"
        fifo_len = $ - fifo

    chardev:    .asciz " (Char device)"
        chardev_len = $ - chardev

    dir:        .asciz " (Directory)"
        dir_len = $ - dir

    blkdev:     .asciz " (Block device)"
        blkdev_len = $ - blkdev

    regular:    .asciz " (Regular)"
        regular_len = $ - regular

    symlink:    .asciz " (Symlink)"
        symlink_len = $ - symlink
    
    socket:     .asciz " (Socket)"
        socket_len = $ - socket
    
    unknown:    .asciz " (Unknown type)"
        unknown_len = $ - unknown
        

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
    mov rdi, rax       # fd
    mov rax, 78        # sys_getdents
    lea rsi, [entry]   # *dirent
    mov rdx, 1024      # count
    syscall

    # set rdi to the end of the struct
    mov rdi, rsi
    add rdi, rax

print_entries:
    lodsq           # d_inode
    lodsq           # d_off
    mov r10, rax
    lodsw           # d_reclen
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
    mov r12, rax
    call print_type
_print_entries_cont:

    lea r8, [newline]
    mov r9, 1
    call print_string
  
    cmp rsi, rdi
    jne print_entries

    leave
    jmp exit

print_type:
    # FIFO
    cmp r12, 1
    je print_type_fifo

    # Char dev
    cmp r12, 2
    je print_type_chardev

    # Directory
    cmp r12, 4
    je print_type_dir

    # Block dev
    cmp r12, 6
    je print_type_blockdev

    # Regular
    cmp r12, 8
    je print_type_regular

    # Symlink
    cmp r12, 10
    je print_type_symlink

    # Socket
    cmp r12, 12
    je print_type_socket

    # unknown
    jmp print_type_unknown
    



print_type_fifo:
    lea r8, [fifo]
    mov r9, fifo_len
    call print_string
    jmp _print_entries_cont

print_type_chardev:
    lea r8, [chardev]
    mov r9, chardev_len
    call print_string
    jmp _print_entries_cont

print_type_dir:
    lea r8, [dir]
    mov r9, dir_len
    call print_string
    jmp _print_entries_cont

print_type_blockdev:
    lea r8, [blkdev]
    mov r9, blkdev_len
    call print_string
    jmp _print_entries_cont

print_type_regular:
    lea r8, [regular]
    mov r9, regular_len
    call print_string
    jmp _print_entries_cont

print_type_symlink:
    lea r8, [symlink]
    mov r9, symlink_len
    call print_string
    jmp _print_entries_cont

print_type_socket:
    lea r8, [socket]
    mov r9, socket_len
    call print_string
    jmp _print_entries_cont

print_type_unknown:
    lea r8, [unknown]
    mov r9, unknown_len
    call print_string
    jmp _print_entries_cont
