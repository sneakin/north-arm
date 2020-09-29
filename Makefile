FORTH=bash ./forth/forth.sh
HTMLER=./scripts/htmler.sh

OUTPUTS=elf/bones/with-data.elf \
	elf/bones/barest.elf \
	elf/bones/thumb.elf \
	runner/thumb/bin/interp.elf \
	runner/thumb/bin/assembler.elf \
	bin/interp-thumb \
	bin/assembler-thumb \
	bin/fforth.dict \
	bin/assembler-thumb.sh \
	bin/assembler-thumb.dict
DOCS=doc/html/bash.html \
	doc/html/assembler.html \
	doc/html/runner-thumb.html

all: $(OUTPUTS)
tests: runner/thumb/bin/interp-tests.elf
north: runner/thumb/bin/north.elf

clean:
	rm -f $(OUTPUTS) $(DOCS)

bin:
	mkdir bin

alldoc: doc/html $(DOCS)

doc:
	mkdir doc

doc/html: doc
	mkdir doc/html

FORTH_SRC=./forth/forth.sh \
	./forth/data.sh \
	./forth/state.sh \
	./forth/dict.sh \
	./forth/builtins.sh \
	./forth/compiler.4th \
	./forth/frames.4th

THUMB_ASSEMBLER_SRC=\
	elf/stub32.4th \
	lib/bit-fields.4th \
	lib/case.4th \
	asm/words.4th \
	asm/byte-data.4th \
	asm/thumb.4th \
	asm/thumb2.4th

doc/html/assembler.html: Makefile $(THUMB_ASSEMBLER_SRC) runner/thumb/boot.4th
	$(HTMLER) $^ > $@
doc/html/bash.html: $(FORTH_SRC)
	$(HTMLER) $^ > $@

bin/fforth.dict: $(FORTH_SRC)
	echo -e "forth/compiler.4th load $@ save-dict\n" | $(FORTH)

bin/assembler-thumb.sh: bin/fforth bin/assembler-thumb.dict
	ln -sf fforth $@
bin/assembler-thumb.dict: runner/thumb/builder.4th $(FORTH_SRC) $(THUMB_ASSEMBLER_SRC)
	echo -e "$< load $@ save-dict\n" | $(FORTH)

bin/interp-thumb: runner/thumb/bin/interp.elf
	ln -sf ../$< $@
bin/assembler-thumb: runner/thumb/bin/assembler.elf
	ln -sf ../$< $@

RUNNER_THUMB_SRC=\
	runner/thumb/builder.4th \
	runner/thumb/defining.4th \
	runner/thumb/ops.4th \
	runner/thumb/linux.4th \
	runner/thumb/init.4th \
	runner/thumb/math.4th \
	runner/thumb/proper.4th \
	runner/thumb/data-stack.4th \
	runner/thumb/interp.4th \
	runner/thumb/reader.4th \
	runner/thumb/output.4th \
	runner/thumb/logic.4th \
	runner/thumb/dictionary.4th \
	runner/thumb/strings.4th \
	runner/thumb/messages.4th \
	runner/thumb/frames.4th \
	runner/thumb/iwords.4th \
	runner/thumb/words.4th \
	runner/thumb/case.4th \
	lib/stack.4th \
	lib/assert.4th \
	lib/strings.4th \
	$(THUMB_ASSEMBLER_SRC) \
	$(FOURTH_SRC)

doc/html/runner-thumb.html: Makefile $(RUNNER_THUMB_SRC) runner/thumb/boot.4th
	$(HTMLER) $^ > $@

runner/thumb/bin/interp.elf: runner/thumb/bin/interp.4th $(RUNNER_THUMB_SRC)
runner/thumb/bin/interp-tests.elf: runner/thumb/bin/interp.4th $(RUNNER_THUMB_SRC)
runner/thumb/bin/assembler.elf: runner/thumb/bin/assembler.4th $(RUNNER_THUMB_SRC) runner/thumb/cross.4th lib/strings.4th $(THUMB_ASSEMBLER_SRC)
runner/thumb/bin/runner.elf: runner/thumb/bin/runner.4th $(RUNNER_THUMB_SRC)
runner/thumb/bin/north.elf: runner/thumb/bin/north.4th $(RUNNER_THUMB_SRC) runner/thumb/cross.4th

%.elf: %.4th
	cat $< | $(FORTH) > $@
	chmod u+x $@
