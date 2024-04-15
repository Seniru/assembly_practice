.intel_syntax noprefix

.global exit

exit:
    mov rax, 60       # sys_exit
    xor rdi, rdi      # return code (0)
    syscall
