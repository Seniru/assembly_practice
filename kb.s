.intel_syntax noprefix

.include "system.s"
.include "string.s"
.include "print.s"

.global _start

.equ SYS_READ,			0
.equ SYS_IOCTL,			16
.equ SYS_NANOSLEEP, 	35
.equ SYS_FORK,			57
.equ STDIO_FD,			0

# termio constants
.equ SIZEOF_TERMIOS,	18
.equ TCGETS,			0x5401
.equ TCSETS, 			0x5402
.equ ICANON,			0x02
.EQU ECHO,				0X08
.EQU VMIN,				6
.EQU VTIME,				5
.equ CLEAR_FLAG,		0xff ^ (ICANON | ECHO)

.equ DIR.UP,			0
.equ DIR.DOWN,			1
.equ DIR.LEFT,			2
.equ DIR.RIGHT,			3

.equ KEY.UP,			65
.equ KEY.DOWN,			66
.equ KEY.RIGHT,			67
.equ KEY.LEFT,			68
.equ KEY.ESCAPE,		27
.equ KEY.ESCAPE_SEQ,	91

.macro sleep seconds=1 nano=0
    mov         qword ptr [req], \seconds
	mov			qword ptr [req + 32], \nano
    mov         rax, SYS_NANOSLEEP
    lea         rdi, [req]  # *rqtp
    syscall
.endm

.macro tcgets struct
	mov			rax, SYS_IOCTL
	mov			rdi, STDIO_FD
	mov			rsi, TCGETS
	lea			rdx, [\struct]
	syscall
.endm

.macro printr register=rax
	mov		r8, \register
	call 	print_usigned_int
.endm

.macro print_newline
	lea		r8, [newline]
	mov		r9, 1
	call	print_string
.endm


.data

up:				.int 0
down:			.int 0
left:			.int 0
right:			.int 0
dir:			.byte 0
clr:			.ascii "\033c"
dirtext:		.asciz "Direction: "
newline:		.asciz "\n"
req:            .quad 1, 0

.bss

.lcomm input_buffer 3
.lcomm old_termios 34
.lcomm new_termios 34


.text

main:
	call		_start

_start:
	# create new stack frame
    push        rbp
    mov         rbp, rsp

	# save original terminal settings
	tcgets		[old_termios]
	# copy old settings into new settings
	tcgets		[new_termios]
	# modify new settings
	and			word ptr [new_termios + 12], CLEAR_FLAG
	mov			byte ptr [new_termios + 18 + VMIN], 3
	mov			byte ptr [new_termios + 18 + VTIME], 0

	mov			rax, SYS_IOCTL
	mov			rdi, STDIO_FD
	mov			rsi, TCSETS
	lea			rdx, [new_termios]
	syscall

mainloop:
    lea         r8, [clr]
    mov         r9, 2
    call        print_string

	lea			rax, [dirtext]
    push		rax
	call		printf

	lea			rsi, [dir]
	lodsb
	mov			r8, rax
	call		print_usigned_int

ifdir:
	cmp			byte ptr dir, DIR.UP
	je			inc_up
	cmp			byte ptr dir, DIR.DOWN
	je			inc_down
	cmp			byte ptr dir, DIR.LEFT
	je			inc_left
	cmp			byte ptr dir, DIR.RIGHT
	je			inc_right
endifdir:
	mov			rax, SYS_READ
	mov			rdi, STDIO_FD
	lea			rsi, [input_buffer]
	mov			rdx, 3
	syscall

	lea			rsi, [input_buffer]
	lodsb
	lodsb
	lodsb
	cmp			rax, KEY.UP
	je			goup
	cmp			rax, KEY.DOWN
	je			godown
	cmp			rax, KEY.LEFT
	je			goleft
	cmp			rax, KEY.RIGHT
	je			goright
	
	jmp			mainloop

	# end of program execution
    leave
    jmp         exit

goup:
	mov			byte ptr dir, DIR.UP
	jmp			mainloop

godown:
	mov			byte ptr dir, DIR.DOWN
	jmp			mainloop

goleft:
	mov			byte ptr dir, DIR.LEFT
	jmp			mainloop

goright:
	mov			byte ptr dir, DIR.RIGHT
	jmp			mainloop

inc_up:
	inc			qword ptr up
	mov			r8, up
	call		print_signed_int
	sleep		1, 500
	jmp			endifdir

inc_down:
	inc			qword ptr down
	mov			r8, down
	call		print_signed_int
	sleep		1, 500
	jmp			endifdir

inc_left:
	inc			qword ptr left
	mov			r8, left
	call		print_signed_int
	sleep		1, 500
	jmp			endifdir

inc_right:
	inc			qword ptr right
	mov			r8, right
	call		print_signed_int
	sleep		1, 500
	jmp			endifdir

