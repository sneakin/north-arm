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
OUT_TARGETS?=$(TARGET)
ifeq ($(QUICK),)
OUT_TARGETS+=thumb-linux-static thumb-linux-gnueabi thumb-linux-android
endif

OUTPUTS=version.4th build/$(TARGET)/bin/interp$(EXECEXT) build.sh \
	build/target build/host

ifeq ($(QUICK),)
	OUTPUTS+=\
		build/bin/fforth \
		build/bin/fforth.dict \
		build/bin/assembler-thumb.sh \
		build/bin/assembler-thumb.dict
endif

$(foreach stage,$(STAGES), \
  $(foreach target,$(OUT_TARGETS), \
    $(eval OUTPUTS+= \
	build/$(target)/bin/builder.$(stage)$(EXECEXT) \
	build/$(target)/bin/interp.$(stage)$(EXECEXT) \
	build/$(target)/bin/runner.$(stage)$(EXECEXT) \
	build/$(target)/bin/builder+core.3$(EXECEXT) \
	build/$(target)/bin/interp+core.3$(EXECEXT) \
	build/$(target)/bin/scantool.3$(EXECEXT) \
	build/$(target)/bin/demo-tty/drawing.3$(EXECEXT) \
	build/$(target)/bin/demo-tty/clock.3$(EXECEXT) \
	build/$(target)/bin/demo-tty/raycaster.3$(EXECEXT) )))

DOCS=build/doc/html/bash.html \
	build/doc/html/interp.html \
	build/doc/html/runner.html \
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
	mkdir -p build

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

ifeq ($(BUILDSH),)
build.sh: Makefile
	@echo "#!/bin/sh" > $@
	make -Bns BUILDSH=1 all >> $@

else
build.sh:
endif

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

build/doc/html/bash.html: $(FORTH_SRC)
	$(HTMLER) $^ > $@

build/bin: build
	mkdir -p $@

build/bin/fforth: bin/fforth build/bin
	ln -sf ../../bin/fforth $@
build/bin/fforth.dict: src/bash/compiler.4th build/bin/fforth
	echo -e "\" $<\" load $@ save-dict\n" | $(FORTH)

build/bin/assembler-thumb.sh: build/bin/fforth build/bin/assembler-thumb.dict
	ln -sf ../../bin/fforth $@
build/bin/assembler-thumb.dict: src/cross/builder.4th
	echo -e "load-core \" $<\" load builder-load \" $@\" save-dict\n" | $(FORTH)

RUNNER_THUMB_SRC=src/include/runner.4th

INTERP_RUNTIME_SRC=\
	src/include/interp.4th \
	src/interp/boot/include.4th

INTERP_CORE_SRC= \
	src/include/interp.4th \
	src/lib/structs.4th \
	src/interp/cross.4th \
	src/interp/boot/include.4th

BUILDER_MIN_SRC=\
	src/include/interp.4th \
	src/interp/cross.4th \
	src/bin/builder.4th

BUILDER_SRC=\
	$(INTERP_CORE_SRC) \
	src/bin/builder.4th \
	src/lib/asm/thumb/disasm.4th

build/doc/html/runner.html: Makefile src/bin/interp.4th $(RUNNER_THUMB_SRC)
	$(HTMLER) $^ > $@
build/doc/html/interp.html: Makefile $(INTERP_CORE_SRC)
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

define define_stage_targets # target, stage
build/$(strip $(1))/bin/builder.$(strip $(2))$$(EXECEXT): $$(STAGE$$(STAGE$(strip $(2))_PRIOR)_BUILDER) $(BUILDER_MIN_SRC)
	@echo -e "\e[36;1mBuilding $$(@)\e[0m"
	mkdir -p $$(dir $$@)
	$$(STAGE$$(STAGE$(strip $(2))_PRIOR)_BUILDER) -t $(1) -e build -o $$@ $$(BUILDER_MIN_SRC)
build/$(strip $(1))/bin/interp.$(strip $(2))$$(EXECEXT): ./src/include/interp.4th
	@echo -e "\e[36;1mBuilding $$(@)\e[0m"
	mkdir -p $$(dir $$@)
	$$(STAGE$$(STAGE$(strip $(2))_PRIOR)_BUILDER) -t $(1) -e interp-boot -o $$@ $$^
build/$(strip $(1))/bin/runner.$(strip $(2))$$(EXECEXT): ./src/interp/strings.4th ./src/runner/main.4th
	@echo -e "\e[36;1mBuilding $$(@)\e[0m"
	mkdir -p $$(dir $$@)
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

define stage0_targets # target
build/$(1)/bin/builder$$(EXECEXT): $$(BUILDER_MIN_SRC)
	$$(STAGE0_BUILDER) -t $(1) -e build -o $$@ $$^
build/$(1)/bin/runner$$(EXECEXT): src/bin/runner.4th $$(RUNNER_THUMB_SRC)

ifeq ($$(QUICK),)
# Actually build with Bash
build/$(1)/bin/interp$$(EXECEXT): src/bin/interp.4th $$(RUNNER_THUMB_SRC)
	@echo -e "\e[35;1mBuilding $$(@)\e[0m"
	cat $$< | LC_ALL=en_US.ISO-8859-1 $$(FORTH) > $$@
	chmod u+x $$@
else
# Or copy the last distributed binary.
build/$(1)/bin/interp$$(EXECEXT): build/$(1)/bin
	cp bootstrap/interp$$(EXECEXT) $$@
endif
endef

$(foreach target,$(TARGETS),$(eval $(call stage0_targets,$(target))))

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
  demo_tty_drawing \
  demo_tty_clock \
  demo_tty_raycaster

PGRM_interp_core_sources=$(INTERP_CORE_SRC)
PGRM_interp_core_output=bin/interp+core
PGRM_interp_core_entry=interp-boot

PGRM_builder_core_sources=$(BUILDER_SRC)
PGRM_builder_core_output=bin/builder+core
PGRM_builder_core_entry=build

# Scantool for stats and syntax highlighting.
PGRM_scantool_sources=\
	src/lib/tty/constants.4th \
	$(INTERP_CORE_SRC) \
	src/lib/tty/deps.4th \
	src/bin/scantool.4th
PGRM_scantool_output=bin/scantool
PGRM_scantool_entry=main

PGRM_demo_tty_drawing_output=bin/demo-tty/drawing
PGRM_demo_tty_drawing_entry=demo-tty-boot
PGRM_demo_tty_drawing_sources=\
	src/lib/tty/constants.4th \
	$(INTERP_CORE_SRC) \
	src/lib/tty.4th \
	src/demos/tty/drawing.4th

PGRM_demo_tty_clock_output=bin/demo-tty/clock
PGRM_demo_tty_clock_entry=tty-clock-boot
PGRM_demo_tty_clock_sources=\
	src/lib/tty/constants.4th \
	src/demos/tty/clock/segment-constants.4th \
	$(INTERP_CORE_SRC) \
	src/lib/tty.4th \
	src/demos/tty/clock.4th

PGRM_demo_tty_raycaster_output=bin/demo-tty/raycaster
PGRM_demo_tty_raycaster_entry=raycaster-boot
PGRM_demo_tty_raycaster_sources=\
	src/lib/tty/constants.4th \
	$(INTERP_CORE_SRC) \
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
