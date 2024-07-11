AS=nasm
LD=ld

all: b64

b64.o: b64.asm linux.inc
	$(AS) -f elf64 -o $@ $<

b64: b64.o
	$(LD) -o $@ $<

clean:
	rm -f *.o b64
