.intel_syntax noprefix

.include "system.s"
.include "string.s"
.include "print.s"

.global _start

# constants

.equ PI, 3

# macros

.macro sum n1, n2
	mov			rax, \n1
	add			rax, \n2
.endm

.macro print register=rax
	mov			r8, \register
	call		print_usigned_int
.endm

.macro print_newline
	lea			r8, [newline]
	mov			r9, 1
	call		print_string
.endm

.macro area r
	mov			rax, PI
	mov			rbx, \r
	imul		rax, rbx
	imul		rax, rbx
.endm

newline:	.asciz "\n"

.text

_start:
	# create new stack frame
	push		rbp
	mov			rbp, rsp

	sum			1, 5
	print
	print_newline

	area		7
	print
	print_newline

	# end of program execution
	leave
	jmp			exit
