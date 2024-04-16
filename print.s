.intel_syntax noprefix

.global print_string
.global print_usigned_int
.global print_signed_int

.data
    digits: .ascii "0123456789"
    negative: .ascii "-"


.text

print_string:
    # .push the registers
    push rax
    push rdi
    push rsi
    push rdx
    push rcx

    mov rax, 1         # sys_write
    mov rdi, 1         # stdout
    mov rsi, r8        # buffer
    mov rdx, r9        # size_t
    syscall

    # .pop the registers
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

print_usigned_int:
    push rbp
    mov rbp, rsp
    mov rax, r8

print_int_loop:
    xor rdx, rdx
    push rbx
    mov rbx, 10
    # rax % 10
    div rbx
    pop rbx
    # .push remainder to the stack
    push rdx
    # check if quotient is 0
    test rax, rax
    jnz print_int_loop

print_digits:
    # print if zero
    pop rdx
    lea r8, [digits+rdx]
    mov r9, 1
    call print_string

    cmp rsp, rbp
    jne print_digits
    pop rbp
    ret

print_signed_int:
    push rbx
    mov rbx, 0x8000000000000000
    test r8, rbx
    pop rbx
    jnz print_negative_sign
_print_signed_int_cont:
    call print_usigned_int
    ret

print_negative_sign:
    push r8
    lea r8, negative
    mov r9, 1
    call print_string
    pop r8
    neg r8
    jmp _print_signed_int_cont

printf:
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    mov rdx, 1
    mov rsi, [rbp - 8]      # &buffer
    mov rdi, rsi

print_char_loop:
    lodsb
    cmp al, 0
    je end_string
    cmp al, '%'
    je handle_format
    inc rbx
    jmp print_char_loop


handle_format:
    call print_string_partial
    add rcx, rbx
    # count the % and format specifier
    add rcx, 2
    # increment the parameter index
    inc rdx
    xor rbx, rbx
    # load the format specifier character
    lodsb
    cmp al, 's'
    je handle_format_string
    cmp al, 'd'
    je handle_format_signed_ints
    cmp al, 'u'
    je handle_format_usigned_ints

handle_format_string:
    push rsi

    mov rax, -8
    imul rax, rdx
    mov rsi, [rbp + rax]

    call strlen
    mov r8, rsi
    mov r9, rax
    call print_string
    pop rsi
    jmp print_char_loop

handle_format_usigned_ints:
    mov rax, -8
    imul rax, rdx
    mov r8, [rbp + rax]
    call print_usigned_int
    jmp print_char_loop

handle_format_signed_ints:
    mov rax, -8
    imul rax, rdx
    mov r8, [rbp + rax]
    call print_signed_int
    jmp print_char_loop

end_string:
    call print_string_partial
    ret

print_string_partial:
    lea r8, [rdi+rcx]
    mov r9, rbx
    call print_string
    ret
    


