FORTH=bash ./src/bash/forth.sh
HTMLER=./scripts/htmler.sh
EXECEXT=.elf
SOEXT=.so
SO_CFLAGS=-m32 -shared -nostdlib -g

OUTPUTS=bin/interp$(EXECEXT) \
	bin/interp.1$(EXECEXT) \
	bin/interp.2$(EXECEXT) \
	bin/assembler$(EXECEXT) \
	bin/fforth.dict \
	bin/assembler-thumb.sh \
	bin/assembler-thumb.dict \
	lib/ffi-test-lib$(SOEXT)

DOCS=doc/html/bash.html \
	doc/html/interp.html \
	doc/html/interp-runtime.html \
	doc/html/assembler-thumb.html \
	doc/html/all.html \
	doc/html/style.css \
	doc/html/white.css

ELF_OUTPUT_TESTS=bin/tests/elf/bones/with-data$(EXECEXT) \
	bin/tests/elf/bones/barest$(EXECEXT) \
	bin/tests/elf/bones/thumb$(EXECEXT) \

all: $(OUTPUTS)
tests: bin/interp-tests$(EXECEXT)
north: bin/north$(EXECEXT)

.PHONY: clean doc all

release:
	mkdir -p release
release/root: .git/refs/heads/master release
	if [ -d release/root ]; then cd release/root && git pull; else git clone . release/root; fi

bootstrap:
	mkdir -p bootstrap

bootstrap/interp.static.elf: release/root bootstrap
	make -C release/root version.4th bin/interp.elf bin/interp.1.elf
	cp release/root/bin/interp.elf bootstrap/interp.static.elf

bootstrap/interp.android.elf: release/root bootstrap/interp.static.elf
	make -C release/root version.4th bin/interp.2.elf
	cp release/root/bin/interp.2.elf bootstrap/interp.android.elf

boot: bootstrap/interp.static.elf bootstrap/interp.android.elf

version.4th: .git/refs/heads/master
	echo "\" $$(cat $<)\" string-const> *north-git-ref*" > $@

clean:
	rm -f $(OUTPUTS) $(DOCS)

bin:
	mkdir bin

doc: doc/html $(DOCS)

doc/html:
	mkdir -p doc/html

doc/html/all.html: Makefile src/**/*.4th scripts/*.4th
	$(HTMLER) `find src -name \*.4th` `find scripts -name \*.4th` > $@

doc/html/style.css: doc/style.css
	cp $< $@
doc/html/white.css: doc/white.css
	cp $< $@

FORTH_SRC=./src/bash/forth.sh \
	./src/bash/reader.sh \
	./src/bash/core.sh \
	./src/bash/data.sh \
	./src/bash/state.sh \
	./src/bash/dict.sh \
	./src/bash/builtins.sh \
	./src/bash/compiler.4th \
	./src/bash/frames.4th

THUMB_ASSEMBLER_SRC=\
	src/lib/elf/stub32.4th \
	src/lib/bit-fields.4th \
	src/lib/case.4th \
	src/lib/stack-marker.4th \
	src/lib/byte-data.4th \
	src/lib/asm/thumb/v1.4th \
	src/lib/asm/thumb/v2.4th \
	src/lib/asm/thumb/vfp.4th

doc/html/assembler-thumb.html: Makefile src/bin/assembler.4th $(THUMB_ASSEMBLER_SRC)
	$(HTMLER) $^ > $@
doc/html/bash.html: $(FORTH_SRC)
	$(HTMLER) $^ > $@

bin/fforth.dict: $(FORTH_SRC)
	echo -e "src/bash/compiler.4th load $@ save-dict\n" | $(FORTH)

bin/assembler-thumb.sh: bin/fforth bin/assembler-thumb.dict
	ln -sf fforth $@
bin/assembler-thumb.dict: src/cross/builder.4th $(FORTH_SRC) $(THUMB_ASSEMBLER_SRC)
	echo -e "$< load $@ save-dict\n" | $(FORTH)

RUNNER_THUMB_SRC=\
	version.4th \
	src/cross/builder.4th \
	src/cross/builder/bash.4th \
	src/runner/aliases.4th \
	src/cross/defining/colon.4th \
	src/cross/defining/colon-bash.4th \
	src/cross/defining/colon-boot.4th \
	src/cross/defining/alias.4th \
	src/cross/defining/variables.4th \
	src/cross/defining/constants.4th \
	src/runner/thumb/ops.4th \
	src/runner/thumb/cpu.4th \
	src/runner/thumb/vfp.4th \
	src/runner/thumb/ffi.4th \
	src/runner/thumb/state.4th \
	src/runner/thumb/linux.4th \
	src/runner/thumb/init.4th \
	src/runner/thumb/math.4th \
	src/cross/defining/proper.4th \
	src/runner/proper.4th \
	src/runner/thumb/proper.4th \
	src/interp/data-stack.4th \
	src/interp/data-stack-list.4th \
	src/interp/interp.4th \
	src/interp/compiler.4th \
	src/interp/debug.4th \
	src/interp/reader.4th \
	src/interp/output.4th \
	src/runner/thumb/logic.4th \
	src/interp/dictionary.4th \
	src/interp/strings.4th \
	src/interp/messages.4th \
	src/runner/thumb/frames.4th \
	src/runner/frames.4th \
	src/cross/defining/frames.4th \
	src/cross/iwords.4th \
	src/cross/words.4th \
	src/cross/defining/op.4th \
	src/cross/case.4th \
	src/lib/stack.4th \
	src/lib/assert.4th \
	src/lib/strings.4th \
	src/lib/list.4th \
	src/lib/catch.4th \
	$(THUMB_ASSEMBLER_SRC) \
	$(FOURTH_SRC)

INTERP_RUNTIME_SRC=\
	src/interp/boot/core.4th \
	src/interp/boot/cross.4th \
	src/interp/boot/load/interp.4th \
	src/interp/boot/load/runner.4th \
	src/interp/boot/load/thumb-asm.4th \
	src/cross/builder/interp.4th \
	src/interp/boot/debug.4th \
	src/interp/boot/cross/case.4th \
	src/interp/boot/cross/iwords.4th \
	$(THUMB_ASSEMBLER_SRC)

doc/html/interp-runtime.html: Makefile $(INTERP_RUNTIME_SRC)
	$(HTMLER) $^ > $@
doc/html/interp.html: Makefile src/bin/interp.4th $(RUNNER_THUMB_SRC)
	$(HTMLER) $^ > $@

bin/interp$(EXECEXT): src/bin/interp.4th $(RUNNER_THUMB_SRC)
bin/interp-tests$(EXECEXT): src/bin/interp-tests.4th $(RUNNER_THUMB_SRC)
bin/assembler$(EXECEXT): src/bin/assembler.4th $(RUNNER_THUMB_SRC) src/interp/cross.4th src/lib/strings.4th $(THUMB_ASSEMBLER_SRC)
bin/runner$(EXECEXT): src/bin/runner.4th $(RUNNER_THUMB_SRC)
bin/north$(EXECEXT): src/bin/north.4th $(RUNNER_THUMB_SRC) src/interp/cross.4th

lib/ffi-test-lib$(SOEXT): src/runner/tests/ffi/test-lib.c
	mkdir -p lib && $(CC) $(SO_CFLAGS) -o $@ $<

%$(EXECEXT): %.4th
	cat $< | $(FORTH) > $@
	chmod u+x $@

bin/%$(EXECEXT): src/bin/%.4th
	cat $< | $(FORTH) > $@
	chmod u+x $@

bin/tests/elf/bones/%.elf: src/tests/elf/bones/%.4th
	cat $< | $(FORTH) > $@
	chmod u+x $@

STAGE0_FORTH=LD_PRELOAD='' ./bin/interp.elf
STAGE1_FORTH=LD_PRELOAD='' ./bin/interp.1.elf
STAGE2_FORTH=LD_PRELOAD='' ./bin/interp.2.elf

bin/%.1$(EXECEXT): ./src/bin/%.4th
	cat $< | $(STAGE0_FORTH) > $@
	chmod u+x $@

bin/%.2$(EXECEXT): ./src/bin/%.4th
	cat $< | $(STAGE1_FORTH) > $@
	chmod u+x $@

bin/%.3$(EXECEXT): ./src/bin/%.4th
	cat $< | $(STAGE2_FORTH) > $@
	chmod u+x $@

%.png: %.elf
	./scripts/bintopng.sh e $< $@

%.raw: %.png
	./scripts/bintopng.sh d $< $@
