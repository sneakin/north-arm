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

FORTH_SRC=./forth/forth.sh \
	./forth/compiler.4th \
	./forth/data.sh \
	./forth/state.sh \
	./forth/dict.sh \
	./forth/builtins.sh

bin/fforth.dict: $(FORTH_SRC)
	echo -e "forth/compiler.4th load $@ save-dict\n" | $(FORTH)

bin/runner-thumb: runner/thumb/build.elf
	ln -sf ../$< $@

runner/thumb/build.elf: runner/thumb/build.4th \
	runner/thumb/ops.4th \
	runner/thumb/init.4th \
	runner/thumb/interp.4th \
	runner/thumb/frames.4th \
	runner/thumb/iwords.4th \
	runner/thumb/words.4th \
	elf/stub32.4th \
	asm/words.4th \
	asm/byte-data.4th \
	asm/thumb.4th \
	$(FOURTH_SRC)

%.elf: %.4th
	cat $< | $(FORTH) > $@
	chmod u+x $@
