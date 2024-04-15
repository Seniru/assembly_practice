; 8086 assembly

org 100h

.data
    n dw 10          ; Initialize n with a sample value
    evenMessage db "Number is even$"
    oddMessage db "Number is odd$"

.code
    mov ax, @data
    mov ds, ax

    mov ax, n        ; Load the value of n into ax
    test ax, 1       ; Test if the least significant bit is set (checks for odd)
    jnz odd          ; If the result is not zero, jump to the odd label

    ; If we reach here, the number is even
    lea dx, evenMessage
    mov ah, 9
    int 21h
    jmp exitProgram

odd:
    ; If we reach here, the number is odd
    lea dx, oddMessage
    mov ah, 9
    int 21h

exitProgram:
    ; Exit the program
    mov ah, 4Ch
    int 21h