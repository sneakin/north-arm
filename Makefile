FORTH=bash ./forth/forth.sh

OUTPUTS=elf/bones/with-data.elf \
	elf/bones/barest.elf \
	elf/bones/thumb.elf \
	runner/thumb/build.elf \
	bin/runner-thumb \
	bin/fforth.dict

all: $(OUTPUTS)

clean:
	rm -f $(OUTPUTS)

bin:
	mkdir bin

bin/fforth.dict: ./forth/forth.sh ./forth/compiler.4th ./forth/data.sh ./forth/state.sh
	echo -e "forth/compiler.4th load $@ save-dict\n" | $(FORTH)

bin/runner-thumb: runner/thumb/build.elf
	ln -sf ../$< $@

runner/thumb/build.elf: runner/thumb/build.4th runner/thumb/ops.4th runner/thumb/init.4th runner/thumb/words.4th elf/stub32.4th asm/words.4th asm/byte-data.4th asm/thumb.4th

%.elf: %.4th
	cat $< | $(FORTH) > $@
	chmod u+x $@
