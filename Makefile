
SRC = system.s print.s main.s
OBJ = $(SRC:.s=.o)
# Default target to build the executable 'prog'
all: prog

# Link object files to create the executable 'prog'
prog:
	gcc -c main.s && ld -o prog main.o

ls:
	gcc -c ls.s && ld -o ls.out ls.o

# Rule to clean generated files
clean:
	rm -f prog $(OBJ)
