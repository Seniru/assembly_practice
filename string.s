.intel_syntax noprefix

.global strlen

# get length of a zero delimited string
strlen:
    push rcx
    push rsi
    xor rax, rax
    xor rcx, rcx

strlen_loop:
    inc rcx
    lodsb
    cmp al, 0
    jne strlen_loop
    # .if al == '\0'
    mov rax, rcx
    pop rsi
    pop rcx
    # substract the null terminator character from the count
    dec rax
    ret
