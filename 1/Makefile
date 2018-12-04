all: make_library
	nasm -f elf64 decolour.asm
	gcc -no-pie main.c decolour.o libpnmio/src/pnmio.o -o main

make_library:
	make -C libpnmio/src/

clean: clean_library
	rm *.o main

clean_library:
	make -C libpnmio/src/ clean
