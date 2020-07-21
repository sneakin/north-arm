FORTH=bash ./forth/forth.sh

OUTPUTS=elf/bones/with-data.elf \
	elf/bones/barest.elf \
	elf/bones/thumb.elf \
	runner/thumb/bin/interp.elf \
	runner/thumb/bin/assembler.elf \
	bin/interp-thumb \
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

bin/interp-thumb: runner/thumb/bin/interp.elf
	ln -sf ../$< $@

THUMB_ASSEMBLER_SRC=\
	elf/stub32.4th \
	lib/bit-fields.4th \
	asm/words.4th \
	asm/byte-data.4th \
	asm/thumb.4th \
	asm/thumb2.4th

RUNNER_THUMB_SRC=\
	runner/thumb/builder.4th \
	runner/thumb/ops.4th \
	runner/thumb/linux.4th \
	runner/thumb/init.4th \
	runner/thumb/math.4th \
	runner/thumb/reader.4th \
	runner/thumb/interp.4th \
	runner/thumb/output.4th \
	runner/thumb/logic.4th \
	runner/thumb/dictionary.4th \
	runner/thumb/strings.4th \
	runner/thumb/messages.4th \
	runner/thumb/frames.4th \
	runner/thumb/iwords.4th \
	runner/thumb/words.4th \
	$(THUMB_ASSEMBLER_SRC) \
	$(FOURTH_SRC)

runner/thumb/bin/interp.elf: runner/thumb/bin/interp.4th $(RUNNER_THUMB_SRC)
runner/thumb/bin/assembler.elf: runner/thumb/bin/assembler.4th $(RUNNER_THUMB_SRC) runner/thumb/cross.4th $(THUMB_ASSEMBLER_SRC)
runner/thumb/bin/runner.elf: runner/thumb/bin/runner.4th $(RUNNER_THUMB_SRC)
runner/thumb/bin/north.elf: runner/thumb/build.4th $(RUNNER_THUMB_SRC) runner/thumb/cross.4th

%.elf: %.4th
	cat $< | $(FORTH) > $@
	chmod u+x $@
