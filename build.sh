#!/bin/sh
HOST?="${2:-thumb-linux-static}"
TARGET?="${1:-thumb-linux-static}"
echo "\" $(cat .git/refs/heads/master)\" string-const> NORTH-GIT-REF" > version.4th
echo "32 defconst> NORTH-BITS" >> version.4th
echo "$(date -u +%s) defconst> NORTH-BUILD-TIME" >> version.4th
echo "\" $(git config --get user.name) <$(git config --get user.email)>\" string-const> NORTH-BUILDER" >> version.4th
echo -e "\e[36;1mBuilding bin/interp.elf\e[0m"
cat src/bin/interp.4th | LC_ALL=en_US.ISO-8859-1 bash ./src/bash/forth.sh > bin/interp.elf
chmod u+x bin/interp.elf
echo "#!/bin/sh" > build.sh
echo "HOST?=\"\${2:-"${TARGET}"}\"" >> build.sh
echo "TARGET?=\"\${1:-"${TARGET}"}\"" >> build.sh
make -Bns all TARGET='"${TARGET}"' HOST='"${TARGET}"' \
  | sed -e 's:"${TARGET}":"${TARGET}":g' -e 's:"${TARGET}":"${HOST}":g' >> build.sh
echo -e "\" src/bash/compiler.4th\" load bin/fforth.dict save-dict\n" | bash ./src/bash/forth.sh
echo -e "\e[36;1mBuilding bin/builder.static.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./bin/interp.elf -t "${TARGET}" -e build -o bin/builder.static.1.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding bin/interp.static.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./bin/interp.elf -t "${TARGET}" -e interp-boot -o bin/interp.static.1.elf src/include/interp.4th
echo -e "\e[36;1mBuilding bin/runner.static.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./bin/interp.elf -t "${TARGET}" -e runner-boot -o bin/runner.static.1.elf src/interp/strings.4th src/runner/main.4th
echo -e "Building \e[36;1mbin/builder+core.static.1.elf\e[0m"
mkdir -p bin/
bin/builder.static.1.elf -t "${TARGET}" -e  build -o bin/builder+core.static.1.elf  src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/bin/builder.4th src/lib/asm/thumb/disasm.4th
echo -e "\e[36;1mBuilding bin/builder.static.2.elf\e[0m"
./bin/builder.static.1.elf -t "${TARGET}" -e build -o bin/builder.static.2.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding bin/interp.static.2.elf\e[0m"
./bin/builder.static.1.elf -t "${TARGET}" -e interp-boot -o bin/interp.static.2.elf src/include/interp.4th
echo -e "\e[36;1mBuilding bin/runner.static.2.elf\e[0m"
./bin/builder.static.1.elf -t "${TARGET}" -e runner-boot -o bin/runner.static.2.elf src/interp/strings.4th src/runner/main.4th
echo -e "Building \e[36;1mbin/builder+core.static.2.elf\e[0m"
mkdir -p bin/
bin/builder.static.2.elf -t "${TARGET}" -e  build -o bin/builder+core.static.2.elf  src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/bin/builder.4th src/lib/asm/thumb/disasm.4th
echo -e "\e[36;1mBuilding bin/builder.static.3.elf\e[0m"
./bin/builder+core.static.2.elf -t "${TARGET}" -e build -o bin/builder.static.3.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding bin/interp.static.3.elf\e[0m"
./bin/builder+core.static.2.elf -t "${TARGET}" -e interp-boot -o bin/interp.static.3.elf src/include/interp.4th
echo -e "\e[36;1mBuilding bin/runner.static.3.elf\e[0m"
./bin/builder+core.static.2.elf -t "${TARGET}" -e runner-boot -o bin/runner.static.3.elf src/interp/strings.4th src/runner/main.4th
echo -e "Building \e[36;1mbin/builder+core.static.3.elf\e[0m"
mkdir -p bin/
bin/builder.static.3.elf -t "${TARGET}" -e  build -o bin/builder+core.static.3.elf  src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/bin/builder.4th src/lib/asm/thumb/disasm.4th
echo -e "\e[36;1mBuilding bin/builder.static.4.elf\e[0m"
./bin/builder+core.static.3.elf -t "${TARGET}" -e build -o bin/builder.static.4.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding bin/interp.static.4.elf\e[0m"
./bin/builder+core.static.3.elf -t "${TARGET}" -e interp-boot -o bin/interp.static.4.elf src/include/interp.4th
echo -e "\e[36;1mBuilding bin/runner.static.4.elf\e[0m"
./bin/builder+core.static.3.elf -t "${TARGET}" -e runner-boot -o bin/runner.static.4.elf src/interp/strings.4th src/runner/main.4th
echo -e "Building \e[36;1mbin/interp+core.static.3.elf\e[0m"
mkdir -p bin/
./bin/builder+core.static.3.elf -t "${TARGET}" -e  interp-boot -o bin/interp+core.static.3.elf  src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th
echo -e "Building \e[36;1mbin/scantool.static.3.elf\e[0m"
mkdir -p bin/
./bin/builder+core.static.3.elf -t "${TARGET}" -e  main -o bin/scantool.static.3.elf  src/include/interp.4th src/interp/cross.4th src/bin/scantool.4th
echo -e "Building \e[36;1mbin/demo-tty/drawing.static.3.elf\e[0m"
mkdir -p bin/demo-tty/
./bin/builder+core.static.3.elf -t "${TARGET}" -e  demo-tty-boot -o bin/demo-tty/drawing.static.3.elf  src/lib/tty/constants.4th src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/lib/tty.4th src/demos/tty/drawing.4th
echo -e "Building \e[36;1mbin/demo-tty/clock.static.3.elf\e[0m"
mkdir -p bin/demo-tty/
./bin/builder+core.static.3.elf -t "${TARGET}" -e  tty-clock-boot -o bin/demo-tty/clock.static.3.elf  src/lib/tty/constants.4th src/demos/tty/clock/segment-constants.4th src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/lib/tty.4th src/demos/tty/clock.4th
echo -e "Building \e[36;1mbin/demo-tty/raycaster.static.3.elf\e[0m"
mkdir -p bin/demo-tty/
./bin/builder+core.static.3.elf -t "${TARGET}" -e  raycaster-boot -o bin/demo-tty/raycaster.static.3.elf  src/lib/tty/constants.4th src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/lib/tty.4th src/demos/tty/raycast.4th
echo -e "load-core \" src/cross/builder.4th\" load builder-load \" bin/assembler-thumb.dict\" save-dict\n" | bash ./src/bash/forth.sh
ln -sf fforth bin/assembler-thumb.sh
