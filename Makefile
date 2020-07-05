FORTH=bash ./forth/forth.sh

OUTPUTS=elf/bones/with-data.elf \
	elf/bones/barest.elf \
	elf/bones/thumb.elf \
	bin/fforth.dict

all: $(OUTPUTS)

clean:
	rm -f $(OUTPUTS)

bin:
	mkdir bin

bin/fforth.dict: ./forth/forth.sh
	echo -e "forth/compiler.4th load bin/fforth.dict save-dict\n" | $(FORTH)

%.elf: %.4th
	cat $< | $(FORTH) > $@
