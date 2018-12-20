all:
	nasm -f elf64 simulate.asm
	gcc -no-pie main.c simulate.o -o main

clean:
	rm *.o main
