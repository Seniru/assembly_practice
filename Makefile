
SRC = system.s print.s main.s clock.s ls.s macros.s
OBJ = $(SRC:.s=.o)
OUT = $(SRC:.s=.out)
# Default target to build the executable 'prog'
all: prog

# Link object files to create the executable 'prog'
prog:
	gcc -c main.s && ld -o prog main.o

ls:
	gcc -c ls.s && ld -o ls.out ls.o

clock:
	gcc -c clock.s && ld -o clock.out clock.o

macros:
	gcc -c macros.s && ld -o macros.out macros.o

# Rule to clean generated files
clean:
	rm -f prog $(OBJ) $(OUT)
