STAGE?=3

BASH?=bash
SHELL=$(BASH)
FORTH?=$(BASH) ./src/bash/forth.sh
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
	RUN_OS=gnueabi
endif

TRIPLE_static=$(TARGET_ARCH)-$(TARGET_OS)-static
TRIPLE_android=$(TARGET_ARCH)-$(TARGET_OS)-android
TRIPLE_gnueabi=$(TARGET_ARCH)-$(TARGET_OS)-gnueabi

STAGES=1 2 3 4
OUT_TARGETS?=$(TARGET) thumb-linux-static thumb-linux-gnueabi thumb-linux-android

OUTPUTS=version.4th build/$(TARGET)/bin/interp$(EXECEXT) build.sh \
	build/target build/host

ifeq ($(QUICK),)
	OUTPUTS+=\
		build/bin/fforth \
		build/bin/fforth.dict
endif

$(foreach stage,$(STAGES), \
  $(foreach target,$(OUT_TARGETS), \
    $(eval OUTPUTS+= \
       build/$(target)/bin/builder.$(stage)$(EXECEXT) \
       build/$(target)/bin/interp.$(stage)$(EXECEXT) \
       build/$(target)/bin/runner.$(stage)$(EXECEXT) )))

OUTPUTS+=build/$(TARGET)/bin/builder+core.3$(EXECEXT) \
	build/$(TARGET)/bin/interp+core.3$(EXECEXT) \
	build/$(TARGET)/bin/scantool.3$(EXECEXT) \
	build/$(TARGET)/bin/demo-tty/drawing.3$(EXECEXT) \
	build/$(TARGET)/bin/demo-tty/clock.3$(EXECEXT) \
	build/$(TARGET)/bin/demo-tty/raycaster.3$(EXECEXT)

ifeq ($(QUICK),)
	OUTPUTS+=\
		build/bin/assembler-thumb.sh \
		build/bin/assembler-thumb.dict
endif

DOCS=build/doc/html/bash.html \
	build/doc/html/interp.html \
	build/doc/html/interp-runtime.html \
	build/doc/html/assembler-thumb.html \
	build/doc/html/all.html \
	build/doc/html/style.css \
	build/doc/html/white.css

ELF_OUTPUT_TESTS=build/$(TARGET)/bin/tests/elf/bones/with-data$(EXECEXT) \
	build/$(TARGET)/bin/tests/elf/bones/barest$(EXECEXT) \
	build/$(TARGET)/bin/tests/elf/bones/thumb$(EXECEXT)

all: $(OUTPUTS)
tests: build/$(TARGET)/lib/ffi-test-lib$(SOEXT) build/$(TATGET)/bin/interp-tests$(EXECEXT)

.PHONY: clean doc all quick misc \
	git-info env print-targets print-programs \
	run-bare-metal debug-bare-metal

git-info:
	@echo $(GIT) at "$(shell cat .git/HEAD | sed -e 's/.*: \(.*\)/\1/')"

release:
	mkdir -p release
release/root: .git/refs/heads/$(RELEASE_BRANCH) release
	if [ -d release/root ]; then cd release/root && $(GIT) fetch; else $(GIT) clone . release/root && cd release/root; fi && $(GIT) checkout $(RELEASE_BRANCH) && $(GIT) pull origin $(RELEASE_BRANCH)

quick:
	mkdir -p build/$(HOST)/bin
	cp bootstrap/$(HOST)/interp$(EXECEXT) build/$(HOST)/bin/interp$(EXECEXT)
	touch build/$(HOST)/bin/interp$(EXECEXT)

clean:
	rm -f build


build:
	mkdir build

build/target:
	ln -nsf $(TARGET) $@

build/host:
	ln -nsf $(HOST) $@

build/$(HOST)/bin:
	mkdir -p $@

build/$(TARGET)/bin:
	mkdir -p $@

#
# Prebuilt binary building from a clean tree.
#

bootstrap:
	mkdir -p $@

BOOTSTRAPS=

define define_bootstrap # targen
bootstrap/$(1):
	mkdir -p $$@

bootstrap/$(1)/interp$$(EXECEXT): release/root bootstrap/$(1)
	$(MAKE) TARGET=$(1) -C release/root version.4th build/$(1)/bin/interp$$(EXECEXT)
	cp release/root/build/$(1)/bin/interp$$(EXECEXT) $$@

BOOTSTRAPS+=bootstrap/$(1)/interp$(EXECEXT)
endef

$(foreach target,$(OUT_TARGETS),$(eval $(call define_bootstrap,$(target))))

boot: $(BOOTSTRAPS)


#
# Generated source files:
#

version.4th: .git/refs/heads/$(RELEASE_BRANCH) Makefile Makefile.arch
	@echo "\" $$(cat $<)\" string-const> NORTH-GIT-REF" > $@
	@echo "$(TARGET_BITS) defconst> NORTH-BITS" >> $@
	@echo "$$(date -u +%s) defconst> NORTH-BUILD-TIME" >> $@
	@echo "\" $$($(GIT) config --get user.name) <$$($(GIT) config --get user.email)>\" string-const> NORTH-BUILDER" >> $@

src/copyright.4th: src/copyright.4th.tmpl src/copyright.txt
	./scripts/copyright-gen.sh $< > $@

build.sh: Makefile
	@echo "#!/bin/sh" > $@
	@echo "HOST?=\"\$${2:-$(HOST)}\"" >> $@
	@echo "TARGET?=\"\$${1:-$(TARGET)}\"" >> $@
	@make -Bns all TARGET='$(TARGET)' HOST='$(HOST)' \
	  | sed -e 's:$(TARGET):"$${TARGET}":g' -e 's:$(HOST):"$${HOST}":g' >> $@


#
# Formatted code docs
#

build/doc: build/doc/html $(DOCS)

build/doc/html:
	mkdir -p $@

build/doc/html/all.html:
	$(HTMLER) `find src -name \*.4th` `find scripts -name \*.4th` > $@

build/doc/html/style.css: doc/style.css build/doc/html
	cp $< $@
build/doc/html/white.css: doc/white.css build/doc/html
	cp $< $@

FORTH_SRC=./src/bash/forth.sh \
	./src/bash/reader.sh \
	./src/bash/core.sh \
	./src/bash/data.sh \
	./src/bash/state.sh \
	./src/bash/dict.sh \
	./src/bash/builtins.sh \
	./src/bash/compiler.4th \
	./src/bash/frames.4th \
	./src/bash/platform.4th

THUMB_ASSEMBLER_SRC=\
	src/lib/bit-fields.4th \
	src/lib/stack.4th \
	src/interp/boot/cross.4th \
	src/lib/elf/stub32.4th \
	src/lib/elf/stub32-dynamic.4th \
	src/lib/elf/stub64.4th \
	src/lib/elf/stub.4th \
	src/lib/asm/thumb/v1.4th \
	src/lib/asm/thumb/v2.4th \
	src/lib/asm/thumb/vfp.4th \
	src/cross/defining/op.4th \
	src/cross/defining/alias.4th

build/doc/html/assembler-thumb.html: Makefile src/bin/assembler.4th $(THUMB_ASSEMBLER_SRC)
	$(HTMLER) $^ > $@
build/doc/html/bash.html: $(FORTH_SRC)
	$(HTMLER) $^ > $@

build/bin: build
	mkdir $@

build/bin/fforth: bin/fforth build/bin
	ln -sf ../../bin/fforth $@
build/bin/fforth.dict: src/bash/compiler.4th build/bin/fforth
	echo -e "\" $<\" load $@ save-dict\n" | $(FORTH)

build/bin/assembler-thumb.sh: build/bin/fforth build/bin/assembler-thumb.dict
	ln -sf ../../bin/fforth $@
build/bin/assembler-thumb.dict: src/cross/builder.4th
	echo -e "load-core \" $<\" load builder-load \" $@\" save-dict\n" | $(FORTH)

RUNNER_THUMB_SRC=\
	./src/include/runner.4th \
	src/runner/thumb/ops.4th \
	src/runner/thumb/cpu.4th \
	src/runner/thumb/vfp.4th \
	src/cross/dynlibs.4th \
	src/cross/list.4th \
	src/interp/boot/cross/iwords.4th \
	src/cross/defining/constants.4th \
	src/cross/constants.4th \
	src/cross/defining/variables.4th \
	src/cross/defining/colon.4th \
	src/interp/boot/cross/case.4th \
	src/runner/thumb/frames.4th \
	src/runner/frames.4th \
	src/cross/defining/frames.4th \
	src/runner/constants.4th \
	src/runner/thumb/copiers.4th \
	src/runner/cells.4th \
	src/runner/stack.4th \
	src/runner/copy.4th \
	src/runner/thumb/linux.4th \
	src/runner/thumb/linux/signals/syscalls.4th \
	src/runner/thumb/ffi.4th \
	src/runner/logic.4th \
	src/runner/thumb/math/cmp.4th \
	src/runner/math/signed.4th \
	src/runner/math/division.4th \
	src/runner/thumb/math/division.4th \
	src/runner/thumb/math/carry.4th \
	src/runner/thumb/math/int64.4th \
	src/runner/thumb/state.4th \
	src/runner/math.4th \
	src/runner/aliases.4th \
	src/runner/thumb/vfp-constants.4th \
	src/runner/thumb/proper.4th \
	src/runner/proper.4th \
	src/runner/dictionary.4th \
	src/runner/frame-tailing.4th \
	src/runner/thumb/math-init.4th \
	version.4th \
	src/runner/thumb/init.4th \
	src/runner/x86/ops.4th \
	src/runner/x86/frames.4th \
	src/runner/x86/copiers.4th \
	src/runner/x86/linux.4th \
	src/runner/x86/init.4th \
	$(THUMB_ASSEMBLER_SRC) \
	$(FOURTH_SRC)

INTERP_RUNTIME_SRC=\
	src/include/interp.4th \
	src/lib/seq.4th \
	src/lib/list.4th \
	src/interp/strings.4th \
	src/interp/messages.4th \
	src/interp/dictionary.4th \
	src/lib/fun.4th \
	src/lib/assoc.4th \
	src/interp/output/strings.4th \
	src/interp/output/hex.4th \
	src/interp/output/dec.4th \
	src/interp/output/bool.4th \
	src/interp/characters.4th \
	src/interp/reader.4th \
	src/interp/numbers.4th \
	src/interp/linux/program-args.4th \
	src/interp/linux/auxvec.4th \
	src/interp/linux/hwcaps.4th \
	src/interp/interp.4th \
	src/interp/list.4th \
	src/interp/compiler.4th \
	src/interp/data-stack.4th \
	src/interp/proper.4th \
	src/lib/math/int32.4th \
	src/lib/math/32/int32.4th \
	src/lib/math/int64.4th \
	src/lib/math/32/int64.4th \
	src/interp/output/int64.4th \
	src/interp/output/32/int64.4th \
	src/interp/debug.4th \
	src/interp/decompiler.4th \
	src/interp/loaders.4th \
	./src/interp/boot/init.4th \
	src/interp/boot/core.4th \
	src/interp/literalizers/int64.4th \
	src/lib/byte-data.4th \
	src/lib/byte-data/32.4th \
	src/lib/byte-data/64.4th \
	src/lib/byte-data/stage0.4th \
	src/lib/case.4th \
	src/interp/data-stack-list.4th \
	src/runner/ffi.4th \
	src/interp/dynlibs.4th \
	src/interp/signals.4th \
	src/lib/linux/signals/constants.4th \
	src/lib/linux/signals/types.4th \
	src/interp/tty.4th \
	src/interp/dictionary/revmap.4th \
	src/interp/dictionary/dump.4th \
	src/lib/structs.4th \
	src/lib/structs/typing.4th \
	src/lib/structs/types.4th \
	src/lib/structs/struct.4th \
	src/lib/structs/struct-field.4th \
	src/lib/structs/defining.4th \
	src/lib/structs/pair.4th \
	src/lib/structs/array-type.4th \
	src/lib/structs/seq-field.4th \
	src/lib/structs/writer.4th \
	src/lib/structs/seq.4th \
	src/lib/math.4th \
	src/lib/bit-fields.4th \
	src/lib/math/float32.4th \
	src/interp/output/float32.4th \
	src/lib/linux.4th \
	src/lib/linux/clock.4th \
	src/lib/linux/stat.4th \
	src/lib/linux/mmap.4th \
	src/lib/linux/epoll.4th \
	src/lib/linux/arm32/epoll.4th \
	src/lib/linux/termios.4th \
	src/lib/linux/termios/constants.4th \
	src/lib/linux/termios/ioctl.4th \
	src/lib/linux/process.4th \
	src/lib/linux/threads.4th \
	src/lib/io.4th \
	./src/interp/boot/debug.4th \
	src/lib/stack.4th \
	src/interp/boot/cross.4th \
	src/lib/elf/stub32.4th \
	src/lib/elf/stub32-dynamic.4th \
	src/lib/elf/stub64.4th \
	src/lib/elf/stub.4th \
	src/lib/asm/thumb/v1.4th \
	src/lib/asm/thumb/v2.4th \
	src/lib/asm/thumb/vfp.4th \
	src/cross/defining/op.4th \
	src/cross/defining/alias.4th \
	./src/include/interp.4th \
	src/runner/imports/android.4th \
	src/runner/imports/linux.4th \
	$(THUMB_ASSEMBLER_SRC)

build/doc/html/interp-runtime.html: Makefile $(INTERP_RUNTIME_SRC)
	$(HTMLER) $^ > $@
build/doc/html/interp.html: Makefile src/bin/interp.4th $(RUNNER_THUMB_SRC)
	$(HTMLER) $^ > $@

# Stage 0

./src/include/interp.4th: version.4th
./src/runner/main.4th: version.4th

# Per stage variabless:

# todo filenames need full triples and this would really cross compile
define define_stage # stage
STAGE$(1)_PRIOR=$(shell echo $$(($(1) - 1)))
STAGE$(1)_FORTH=$(RUNNER) ./build/$(HOST)/bin/interp.$(1)$(EXECEXT)
STAGE$(1)_BUILDER=$(RUNNER) ./build/$(HOST)/bin/builder+core.$(1)$(EXECEXT)
endef

# Per target and stage outputs:

BUILDER_MIN_SRC=\
	src/include/interp.4th \
	src/interp/cross.4th \
	src/bin/builder.4th

BUILDER_SRC=\
	src/include/interp.4th \
	src/interp/proper.4th \
	src/lib/pointers.4th \
	src/lib/list-cs.4th \
	src/lib/structs.4th \
	src/interp/cross.4th \
	src/interp/boot/include.4th \
	src/bin/builder.4th \
	src/lib/asm/thumb/disasm.4th

define define_stage_targets # target, stage
build/$(strip $(1))/bin/builder.$(strip $(2))$$(EXECEXT): $$(STAGE$$(STAGE$(strip $(2))_PRIOR)_BUILDER) $(BUILDER_MIN_SRC)
	@echo -e "\e[36;1mBuilding $$(@)\e[0m"
	$$(STAGE$$(STAGE$(strip $(2))_PRIOR)_BUILDER) -t $(1) -e build -o $$@ $$(BUILDER_MIN_SRC)
build/$(strip $(1))/bin/interp.$(strip $(2))$$(EXECEXT): ./src/include/interp.4th
	@echo -e "\e[36;1mBuilding $$(@)\e[0m"
	$$(STAGE$$(STAGE$(strip $(2))_PRIOR)_BUILDER) -t $(1) -e interp-boot -o $$@ $$^
build/$(strip $(1))/bin/runner.$(strip $(2))$$(EXECEXT): ./src/interp/strings.4th ./src/runner/main.4th
	@echo -e "\e[36;1mBuilding $$(@)\e[0m"
	$$(STAGE$$(STAGE$(strip $(2))_PRIOR)_BUILDER) -t $(1) -e runner-boot -o $$@ $$^
endef

# Define instances of the above:
$(foreach stage,$(STAGES),$(eval $(call define_stage,$(stage))))

$(foreach stage,$(STAGES), \
  $(foreach target,$(TARGETS), \
    $(eval $(call define_stage_targets,$(target),$(stage)))))

# Bootstrap stage 0:

STAGE0_FORTH=$(RUNNER) ./build/$(HOST)/bin/interp$(EXECEXT)
STAGE0_BUILDER=echo '" ./src/bin/builder.4th" load build' | $(STAGE0_FORTH)
#STAGE1_BUILDER=$(RUNNER) ./bin/builder$(EXECEXT)
STAGE1_BUILDER=$(RUNNER) ./build/$(HOST)/bin/builder.1$(EXECEXT)

# todo was using HOST vars which attempted a build for x86. Right but not ready.
build/$(TARGET_ARCH)-$(TARGET_OS)-static/bin/builder$(EXECEXT): $(BUILDER_MIN_SRC)
	$(STAGE0_BUILDER) -t $(TARGET_ARCH)-$(TARGET_OS)-static -e build -o $@ $^

ifeq ($(QUICK),)
# Actually build with Bash
build/$(HOST)/bin/interp$(EXECEXT): src/bin/interp.4th $(RUNNER_THUMB_SRC)
	@echo -e "\e[35;1mBuilding $(@)\e[0m"
	cat $< | LC_ALL=en_US.ISO-8859-1 $(FORTH) > $@
	chmod u+x $@

build/$(TARGET)/bin/interp$(EXECEXT): src/bin/interp.4th $(RUNNER_THUMB_SRC)
	@echo -e "\e[35;1mBuilding $(@)\e[0m"
	cat $< | LC_ALL=en_US.ISO-8859-1 $(FORTH) > $@
	chmod u+x $@

else
# Or copy the last distributed binary.
build/$(HOST)/bin/interp$(EXECEXT): build/$(HOST)/bin
	cp bootstrap/interp$(EXECEXT) $@
build/$(TARGET)/bin/interp$(EXECEXT): build/$(TARGET)/bin
	cp bootstrap/interp$(EXECEXT) $@

endif

# misc Stage 0 binaries

build/$(TARGET)/bin/runner$(EXECEXT): src/bin/runner.4th $(RUNNER_THUMB_SRC)

#
# Test cases:
#

build/$(TARGET)/bin/interp-tests$(EXECEXT): src/bin/interp-tests.4th $(RUNNER_THUMB_SRC)

# Bare metal executables
build/misc/pi-bare-metal.bin: build/misc/pi-bare-metal$(EXECEXT)
	objcopy -O binary $< $@
build/misc/pi-bare-metal$(EXECEXT): misc/pi-bare-metal.4th
	mkdir -p build/misc && $(STAGE$(STAGE)_BUILDER) -b -o $@ $<
run-bare-metal: build/misc/pi-bare-metal.bin
	qemu-system-arm -M raspi2b -serial stdio -kernel $<
debug-bare-metal: build/misc/pi-bare-metal.bin
	qemu-system-arm -S -s -M raspi2b -serial stdio -kernel $<

# Barebones ELF files:
build/$(TARGET)/bin/tests/elf/bones/%$(EXECEXT): src/tests/elf/bones/%.4th
	cat $< | $(FORTH) > $@
	chmod u+x $@

# FFI Test library
build/$(TARGET)/lib/ffi-test-lib$(SOEXT): src/runner/tests/ffi/test-lib.c
	mkdir -p build/$(TARGET)/lib && $(TARGET_CC) $(SO_CFLAGS) -o $@ $<

# CPIO test inputs
build/misc/cpio:
	mkdir -p $@

build/misc/cpio/odc.cpio: $(RUNNER_THUMB_SRC)
	ls $^ | cpio -o -H odc > $@
build/misc/cpio/newc.cpio: $(RUNNER_THUMB_SRC)
	ls $^ | cpio -o -H newc > $@
build/misc/cpio/binary.cpio: $(RUNNER_THUMB_SRC)
	ls $^ | cpio -o -H bin > $@

CPIO_TEST_ARCHIVES=build/misc/cpio/odc.cpio build/misc/cpio/binary.cpio build/misc/cpio/newc.cpio

test-cpio: build/misc/cpio $(CPIO_TEST_ARCHIVES)
	echo 'load-core tmp" src/tests/lib/cpio.4th" load/2 test-cpio' | $(STAGE3_FORTH)

misc: build/misc/pi-bare-metal.bin \
	build/$(TARGET)/lib/ffi-test-lib$(SOEXT) \
	build/misc/cpio $(CPIO_TEST_ARCHIVES)	

#m
# Rules
#

%.sig: %
	@export MSG="$$(sha256sum $< | cut -d ' ' -f 1)"; \
	  echo "Signing \"$${MSG}\""; \
	  (echo "file: $<"; echo "sha256: $${MSG}" ; (echo "$${MSG}" | gpg -s -a)) | tee $@
build/$(TARGET)/bin/%.sig: bin/%
	@export MSG="$$(head -c -64 $< | sha256sum | cut -d ' ' -f 1)"; \
	  echo "Signing \"$${MSG}\""; \
	  (echo "file: $<"; echo "binary: true" ; echo "sha256: $${MSG}" ; (echo "$${MSG}" | gpg -s -a)) | tee $@

# Org-mode
%.html: %.org
	emacs $< --batch -f org-html-export-to-html --kill

# Image fun
%.png: %$(EXECEXT)
	./scripts/bintopng.sh e $< $@

%.raw: %.png
	./scripts/bintopng.sh d $< $@

#
# Demo programs
#

PROGRAMS=\
  interp_core \
  builder_core \
  scantool \
  interp_armasm \
  demo_tty_drawing \
  demo_tty_clock \
  demo_tty_raycaster

PGRM_interp_core_sources= \
	src/include/interp.4th \
	src/interp/proper.4th \
	src/lib/pointers.4th \
	src/lib/list-cs.4th \
	src/lib/structs.4th \
	src/interp/cross.4th \
	src/interp/boot/include.4th
PGRM_interp_core_output=bin/interp+core
PGRM_interp_core_entry=interp-boot

PGRM_builder_core_sources=$(BUILDER_SRC)
PGRM_builder_core_output=bin/builder+core
PGRM_builder_core_entry=build

# Scantool for stats and syntax highlighting.
PGRM_scantool_sources=\
	src/lib/tty/constants.4th \
	src/include/interp.4th \
	src/interp/proper.4th \
	src/lib/pointers.4th \
	src/lib/list-cs.4th \
	src/lib/structs.4th \
	src/interp/cross.4th \
	src/interp/boot/include.4th \
	src/lib/tty/deps.4th \
	src/bin/scantool.4th
PGRM_scantool_output=bin/scantool
PGRM_scantool_entry=main

PGRM_interp_armasm_output=bin/interp-armasm
PGRM_interp_armasm_entry=interp-boot
PGRM_interp_armasm_sources=\
	src/include/interp.4th \
	src/interp/proper.4th \
	src/lib/pointers.4th \
	src/lib/list-cs.4th \
	src/lib/structs.4th \
	src/interp/cross.4th \
	src/interp/boot/include.4th \
	src/lib/math/int32.4th \
	src/lib/asm/thumb/v1.4th \
	src/lib/asm/thumb/v2.4th \
	src/lib/asm/thumb/disasm.4th \
	src/lib/elf/stub32.4th \
	src/lib/elf/stub32-dynamic.4th

PGRM_demo_tty_drawing_output=bin/demo-tty/drawing
PGRM_demo_tty_drawing_entry=demo-tty-boot
PGRM_demo_tty_drawing_sources=\
	src/lib/tty/constants.4th \
	src/include/interp.4th \
	src/interp/proper.4th \
	src/lib/pointers.4th \
	src/lib/list-cs.4th \
	src/lib/structs.4th \
	src/interp/cross.4th \
	src/interp/boot/include.4th \
	src/lib/tty.4th \
	src/demos/tty/drawing.4th

PGRM_demo_tty_clock_output=bin/demo-tty/clock
PGRM_demo_tty_clock_entry=tty-clock-boot
PGRM_demo_tty_clock_sources=\
	src/lib/tty/constants.4th \
	src/demos/tty/clock/segment-constants.4th \
	src/include/interp.4th \
	src/interp/proper.4th \
	src/lib/pointers.4th \
	src/lib/list-cs.4th \
	src/lib/structs.4th \
	src/interp/cross.4th \
	src/interp/boot/include.4th \
	src/lib/tty.4th \
	src/demos/tty/clock.4th

PGRM_demo_tty_raycaster_output=bin/demo-tty/raycaster
PGRM_demo_tty_raycaster_entry=raycaster-boot
PGRM_demo_tty_raycaster_sources=\
	src/lib/tty/constants.4th \
	src/include/interp.4th \
	src/interp/proper.4th \
	src/lib/pointers.4th \
	src/lib/list-cs.4th \
	src/lib/structs.4th \
	src/interp/cross.4th \
	src/interp/boot/include.4th \
	src/lib/tty.4th \
	src/demos/tty/raycast.4th

#
# Now to use the PGRM variables:
#

define define_north_program # name, target, stage, entry point, sources
PGRMS_$(strip $(2))_$(strip $(3))+=$(1)
ifneq (,$(findstring builder+core,$(1)))
$(1): build/$$(HOST)/bin/builder.$(strip $(3))$(EXECEXT) $(5)
	@echo -e "Building \e[36;1m$$(@)\e[0m"
	@mkdir -p $$(dir $$@)
	build/$$(HOST)/bin/builder.$(strip $(3))$(EXECEXT) -t $(2) -e $(4) -o $$@ $(5)
else
$(1): $$(STAGE$(3)_BUILDER) $(5)
	@echo -e "Building \e[36;1m$$(@)\e[0m"
	@mkdir -p $$(dir $$@)
	$$(STAGE$(3)_BUILDER) -t $(strip $(2)) -e $(4) -o $$@ $(5)
endif
endef

$(foreach stage,$(STAGES), \
  $(foreach target,$(TARGETS), \
    $(foreach program,$(PROGRAMS), \
      $(eval $(call define_north_program,\
	      build/$(target)/$(PGRM_$(program)_output).$(stage)$(EXECEXT),\
        $(target),$(stage),\
        $(PGRM_$(program)_entry),\
        $(PGRM_$(program)_sources))))))

programs: $(PGRMS_$(TARGET)_$(STAGE))

print-programs:
	@echo $(PGRMS_$(TARGET)_$(STAGE))
