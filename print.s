.intel_syntax noprefix

.global print_string
.global print_int

.data
    digits: .ascii "0123456789"


.text

print_string:
    # .push the registers
    push rax
    push rdi
    push rsi
    push rdx

    mov rax, 1         # sys_write
    mov rdi, 1         # stdout
    mov rsi, r8        # buffer
    mov rdx, r9        # size_t
    syscall

    # .pop the registers
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

print_int:
    push rbp
    mov rbp, rsp
    mov rax, r8
    mov rbx, 10

print_int_loop:
    xor rdx, rdx
    # rax % 10
    div rbx
    # .push remainder to the stack
    push rdx
    # check if quotient is 0
    test rax, rax
    jnz print_int_loop

print_digits:
    # print if zero
    pop rdx
    mov rax, 1                  # sys_write
    mov rdi, 1                  # stdout
    lea rsi, [digits+rdx]       # buffer
    mov rdx, 1                  # len
    syscall

    cmp rsp, rbp
    jne print_digits
    pop rbp
    ret

   