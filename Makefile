FORTH?=bash ./src/bash/forth.sh
HTMLER?=./scripts/htmler.sh
GIT?=git

EXECEXT=.elf
SOEXT=.so
SO_CFLAGS=-shared -nostdlib -g

RELEASE_BRANCH?=master

all:

include ./Makefile.arch

RUN_OS=static
ifeq ($(HOST_ABI),android)
	RUN_OS=android
else ifeq ($(HOST_ABI),gnueabi)
	RUN_OS=linux
endif

TRIPLE_static=$(TARGET_ARCH)-$(TARGET_OS)-static
TRIPLE_android=$(TARGET_ARCH)-$(TARGET_OS)-android
TRIPLE_gnueabi=$(TARGET_ARCH)-$(TARGET_OS)-gnueabi

#OUT_TARGETS?=static android gnueabi
OUT_TARGETS?=$(TARGET_ABI)

OUTPUTS=lib/ffi-test-lib$(SOEXT)

$(foreach stage,1 2 3, \
  $(foreach target,$(OUT_TARGETS), \
    $(eval OUTPUTS+= \
       bin/builder.$(target).$(stage)$(EXECEXT) \
       bin/interp.$(target).$(stage)$(EXECEXT) \
       bin/runner.$(target).$(stage)$(EXECEXT) )))

ifeq ($(QUICK),)
	OUTPUTS+=\
		bin/interp$(EXECEXT) \
		bin/fforth.dict \
		bin/assembler-thumb.sh \
		bin/assembler-thumb.dict
endif

DOCS=doc/html/bash.html \
	doc/html/interp.html \
	doc/html/interp-runtime.html \
	doc/html/assembler-thumb.html \
	doc/html/all.html \
	doc/html/style.css \
	doc/html/white.css

ELF_OUTPUT_TESTS=bin/tests/elf/bones/with-data$(EXECEXT) \
	bin/tests/elf/bones/barest$(EXECEXT) \
	bin/tests/elf/bones/thumb$(EXECEXT)

all: $(OUTPUTS)
tests: bin/interp-tests$(EXECEXT)
north: bin/north$(EXECEXT)

.PHONY: clean doc all quick git-info

git-info:
	@echo $(GIT) at "$(shell cat .git/HEAD | sed -e 's/.*: \(.*\)/\1/')"

release:
	mkdir -p release
release/root: .git/refs/heads/$(RELEASE_BRANCH) release
	if [ -d release/root ]; then cd release/root && $(GIT) fetch; else $(GIT) clone . release/root && cd release/root; fi && $(GIT) checkout $(RELEASE_BRANCH) && $(GIT) pull origin $(RELEASE_BRANCH)

quick:
	cp bootstrap/interp.elf bin/interp.elf

clean:
	rm -f $(OUTPUTS) $(DOCS)

bin:
	mkdir bin

#
# Prebuilt binary building from a clean tree.
#

bootstrap:
	mkdir -p bootstrap

bootstrap/interp.elf: release/root bootstrap
	$(MAKE) TARGET=thumb-linux-static -C release/root version.4th bin/interp.elf
	cp release/root/bin/interp.elf bootstrap/interp.elf

bootstrap/interp.static.elf: release/root bootstrap
	$(MAKE) TARGET=thumb-linux-static -C release/root version.4th bin/interp.elf bin/interp.static.1.elf bin/interp.static.2.elf
	cp release/root/bin/interp.static.2.elf bootstrap/interp.static.elf

bootstrap/interp.gnueabi.elf: release/root bootstrap
	$(MAKE) TARGET=thumb-linux-gnueabi -C release/root version.4th bin/interp.elf bin/interp.gnueabi.1.elf bin/interp.gnueabi.2.elf bin/interp.gnueabi.3.elf
	cp release/root/bin/interp.gnueabi.3.elf bootstrap/interp.gnueabi.elf

bootstrap/interp.android.elf: release/root bootstrap
	$(MAKE) TARGET=thumb-linux-android -C release/root version.4th bin/interp.android.1.elf bin/interp.android.2.elf bin/interp.android.3.elf
	cp release/root/bin/interp.android.3.elf bootstrap/interp.android.elf

boot: bootstrap/interp.elf bootstrap/interp.static.elf bootstrap/interp.gnueabi.elf bootstrap/interp.android.elf

#
# Generated source files:
#

version.4th: .git/refs/heads/$(RELEASE_BRANCH) Makefile Makefile.arch
	@echo "\" $$(cat $<)\" string-const> NORTH-GIT-REF" > $@
	@echo "$(TARGET_BITS) defconst> NORTH-BITS" >> $@
	@echo "$$(date -u +%s) defconst> NORTH-BUILD-TIME" >> $@
	@echo "\" $$($(GIT) config --get user.name) <$$($(GIT) config --get user.email)>\" string-const> NORTH-BUILDER" >> $@

src/copyright.4th: src/copyright.4th.erb src/copyright.txt
	./scripts/copyright-gen.sh $< > $@

#
# Formatted code docs
#

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
	src/interp/output/strings.4th \
	src/interp/output/hex.4th \
	src/interp/output/dec.4th \
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
	src/lib/structs.4th \
	src/lib/cpio.4th \
	$(THUMB_ASSEMBLER_SRC) \
	$(FOURTH_SRC)

INTERP_RUNTIME_SRC=\
	src/interp/boot/core.4th \
	src/interp/boot/cross.4th \
	src/include/interp.4th \
	src/include/runner.4th \
	src/include/thumb-asm.4th \
	src/cross/builder/interp.4th \
	src/interp/boot/debug.4th \
	src/interp/boot/cross/case.4th \
	src/interp/boot/cross/iwords.4th \
	$(THUMB_ASSEMBLER_SRC)

doc/html/interp-runtime.html: Makefile $(INTERP_RUNTIME_SRC)
	$(HTMLER) $^ > $@
doc/html/interp.html: Makefile src/bin/interp.4th $(RUNNER_THUMB_SRC)
	$(HTMLER) $^ > $@

# Per stage variabless:

define define_stage # stage
STAGE$(1)_PRIOR=$(shell echo $$(($(1) - 1)))
STAGE$(1)_FORTH=$(RUNNER) ./bin/interp.$(RUN_OS).$(1)$(EXECEXT)
STAGE$(1)_BUILDER=$(RUNNER) ./bin/builder.$(RUN_OS).$(1)$(EXECEXT)
endef

# Per target and stage outputs:

define define_stage_targets # target, stage
bin/%.$(1).$(2)$$(EXECEXT):
	$$(STAGE$(2)_BUILDER) -t $$(TRIPLE_$(1)) -o $$@ $$^
bin/builder.$(1).$(2)$$(EXECEXT): ./src/include/interp.4th ./src/interp/cross.4th ./src/bin/builder.4th
	$$(STAGE$$(STAGE$(2)_PRIOR)_BUILDER) -t $$(TRIPLE_$(1)) -e build -o $$@ $$^
bin/interp.$(1).$(2)$$(EXECEXT): ./src/include/interp.4th
	$$(STAGE$$(STAGE$(2)_PRIOR)_BUILDER) -t $$(TRIPLE_$(1)) -e interp-boot -o $$@ $$^
bin/runner.$(1).$(2)$$(EXECEXT): ./src/interp/strings.4th ./src/runner/main.4th
	$$(STAGE$$(STAGE$(2)_PRIOR)_BUILDER) -t $$(TRIPLE_$(1)) -e runner-boot -o $$@ $$^
endef

# Define instances of the above:
$(foreach stage,1 2 3,$(eval $(call define_stage,$(stage))))

$(foreach stage,1 2 3, \
  $(foreach target,static android gnueabi, \
    $(eval $(call define_stage_targets,$(target),$(stage)))))

# Bootstrap stage 0:

STAGE0_FORTH=$(RUNNER) ./bin/interp$(EXECEXT)
STAGE0_BUILDER=echo '" ./src/bin/builder.4th" load build' | $(STAGE0_FORTH)
STAGE1_BUILDER=$(RUNNER) ./bin/builder$(EXECEXT)

bin/builder$(EXECEXT): ./src/include/interp.4th ./src/interp/cross.4th ./src/bin/builder.4th
	$(STAGE0_BUILDER) -t $(HOST_ARCH)-$(HOST_OS)-static -e build -o $@ $^

bin/interp$(EXECEXT): src/bin/interp.4th $(RUNNER_THUMB_SRC)
bin/interp-tests$(EXECEXT): src/bin/interp-tests.4th $(RUNNER_THUMB_SRC)
bin/assembler$(EXECEXT): src/bin/assembler.4th $(RUNNER_THUMB_SRC) src/interp/cross.4th src/lib/strings.4th $(THUMB_ASSEMBLER_SRC)
bin/runner$(EXECEXT): src/bin/runner.4th $(RUNNER_THUMB_SRC)
bin/north$(EXECEXT): src/bin/north.4th $(RUNNER_THUMB_SRC) src/interp/cross.4th

%$(EXECEXT): %.4th
	cat $< | $(FORTH) > $@
	chmod u+x $@

bin/%$(EXECEXT): src/bin/%.4th
	cat $< | LC_ALL=en_US.ISO-8859-1 $(FORTH) > $@
	chmod u+x $@

# Barebones ELF files:
bin/tests/elf/bones/%.elf: src/tests/elf/bones/%.4th
	cat $< | $(FORTH) > $@
	chmod u+x $@

# Test cases:

# FFI Test library
lib/ffi-test-lib$(SOEXT): src/runner/tests/ffi/test-lib.c
	mkdir -p lib && $(TARGET_CC) $(SO_CFLAGS) -o $@ $<

# CPIO test inputs
misc/cpio:
	mkdir -p $@

misc/cpio/odc.cpio: $(RUNNER_THUMB_SRC)
	ls $^ | cpio -o -H odc > $@
misc/cpio/newc.cpio: $(RUNNER_THUMB_SRC)
	ls $^ | cpio -o -H newc > $@
misc/cpio/binary.cpio: $(RUNNER_THUMB_SRC)
	ls $^ | cpio -o -H bin > $@

test-cpio: misc/cpio misc/cpio/odc.cpio misc/cpio/binary.cpio misc/cpio/newc.cpio
	echo 'load-core tmp" src/tests/lib/cpio.4th" load/2 test-cpio' | $(STAGE3_FORTH)

# Image fun
%.png: %$(EXECEXT)
	./scripts/bintopng.sh e $< $@

%.raw: %.png
	./scripts/bintopng.sh d $< $@
