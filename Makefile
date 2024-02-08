OUTPUT := asm.bot
SOURCE := $(wildcard *.asm)
CSOURCE := $(wildcard *.c)
ASMOBJS := $(patsubst %.asm,%.o,$(SOURCE))
COBJS := $(patsubst %.c,%.o,$(CSOURCE))

$(OUTPUT): $(ASMOBJS) $(COBJS)
	ld -o $@ $^ -ldiscord -lcurl -lc
	patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 $(OUTPUT)

%.o: %.c
	gcc -c -O3 -o $@ $<

%.o: %.asm
	nasm -felf64 $<

.PHONY: clean
clean:
	@rm -f $(ASMOBJS) $(COBJS) $(OUTPUT)

.PHONY: run
run:
	./$(OUTPUT)
