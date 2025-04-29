#!/bin/sh
HOST?="${2:-thumb-linux-static}"
TARGET?="${1:-thumb-linux-static}"
echo "\" $(cat .git/refs/heads/master)\" string-const> NORTH-GIT-REF" > version.4th
echo "32 defconst> NORTH-BITS" >> version.4th
echo "$(date -u +%s) defconst> NORTH-BUILD-TIME" >> version.4th
echo "\" $(git config --get user.name) <$(git config --get user.email)>\" string-const> NORTH-BUILDER" >> version.4th
echo -e "\e[35;1mBuilding build/"${TARGET}"/bin/interp.elf\e[0m"
cat src/bin/interp.4th | LC_ALL=en_US.ISO-8859-1 bash ./src/bash/forth.sh > build/"${TARGET}"/bin/interp.elf
chmod u+x build/"${TARGET}"/bin/interp.elf
echo "#!/bin/sh" > build.sh
echo "HOST?=\"\${2:-"${TARGET}"}\"" >> build.sh
echo "TARGET?=\"\${1:-"${TARGET}"}\"" >> build.sh
make -Bns all TARGET='"${TARGET}"' HOST='"${TARGET}"' \
  | sed -e 's:"${TARGET}":"${TARGET}":g' -e 's:"${TARGET}":"${HOST}":g' >> build.sh
ln -nsf "${TARGET}" build/target
ln -nsf "${TARGET}" build/host
mkdir build
mkdir build/bin
ln -sf ../../bin/fforth build/bin/fforth
echo -e "\" src/bash/compiler.4th\" load build/bin/fforth.dict save-dict\n" | bash ./src/bash/forth.sh
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/builder.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./build/"${TARGET}"/bin/interp.elf -t "${TARGET}" -e build -o build/"${TARGET}"/bin/builder.1.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/interp.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./build/"${TARGET}"/bin/interp.elf -t "${TARGET}" -e interp-boot -o build/"${TARGET}"/bin/interp.1.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/runner.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./build/"${TARGET}"/bin/interp.elf -t "${TARGET}" -e runner-boot -o build/"${TARGET}"/bin/runner.1.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/builder.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./build/"${TARGET}"/bin/interp.elf -t thumb-linux-gnueabi -e build -o build/thumb-linux-gnueabi/bin/builder.1.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/interp.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./build/"${TARGET}"/bin/interp.elf -t thumb-linux-gnueabi -e interp-boot -o build/thumb-linux-gnueabi/bin/interp.1.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/runner.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./build/"${TARGET}"/bin/interp.elf -t thumb-linux-gnueabi -e runner-boot -o build/thumb-linux-gnueabi/bin/runner.1.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/builder.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./build/"${TARGET}"/bin/interp.elf -t thumb-linux-android -e build -o build/thumb-linux-android/bin/builder.1.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/interp.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./build/"${TARGET}"/bin/interp.elf -t thumb-linux-android -e interp-boot -o build/thumb-linux-android/bin/interp.1.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/runner.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./build/"${TARGET}"/bin/interp.elf -t thumb-linux-android -e runner-boot -o build/thumb-linux-android/bin/runner.1.elf src/interp/strings.4th src/runner/main.4th
echo -e "Building \e[36;1mbuild/"${TARGET}"/bin/builder+core.1.elf\e[0m"
mkdir -p build/"${TARGET}"/bin/
build/"${TARGET}"/bin/builder.1.elf -t  "${TARGET}" -e  build -o build/"${TARGET}"/bin/builder+core.1.elf  src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/bin/builder.4th src/lib/asm/thumb/disasm.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/builder.2.elf\e[0m"
./build/"${TARGET}"/bin/builder.1.elf -t "${TARGET}" -e build -o build/"${TARGET}"/bin/builder.2.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/interp.2.elf\e[0m"
./build/"${TARGET}"/bin/builder.1.elf -t "${TARGET}" -e interp-boot -o build/"${TARGET}"/bin/interp.2.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/runner.2.elf\e[0m"
./build/"${TARGET}"/bin/builder.1.elf -t "${TARGET}" -e runner-boot -o build/"${TARGET}"/bin/runner.2.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/builder.2.elf\e[0m"
./build/"${TARGET}"/bin/builder.1.elf -t thumb-linux-gnueabi -e build -o build/thumb-linux-gnueabi/bin/builder.2.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/interp.2.elf\e[0m"
./build/"${TARGET}"/bin/builder.1.elf -t thumb-linux-gnueabi -e interp-boot -o build/thumb-linux-gnueabi/bin/interp.2.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/runner.2.elf\e[0m"
./build/"${TARGET}"/bin/builder.1.elf -t thumb-linux-gnueabi -e runner-boot -o build/thumb-linux-gnueabi/bin/runner.2.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/builder.2.elf\e[0m"
./build/"${TARGET}"/bin/builder.1.elf -t thumb-linux-android -e build -o build/thumb-linux-android/bin/builder.2.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/interp.2.elf\e[0m"
./build/"${TARGET}"/bin/builder.1.elf -t thumb-linux-android -e interp-boot -o build/thumb-linux-android/bin/interp.2.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/runner.2.elf\e[0m"
./build/"${TARGET}"/bin/builder.1.elf -t thumb-linux-android -e runner-boot -o build/thumb-linux-android/bin/runner.2.elf src/interp/strings.4th src/runner/main.4th
echo -e "Building \e[36;1mbuild/"${TARGET}"/bin/builder+core.2.elf\e[0m"
mkdir -p build/"${TARGET}"/bin/
build/"${TARGET}"/bin/builder.2.elf -t  "${TARGET}" -e  build -o build/"${TARGET}"/bin/builder+core.2.elf  src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/bin/builder.4th src/lib/asm/thumb/disasm.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/builder.3.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.2.elf -t "${TARGET}" -e build -o build/"${TARGET}"/bin/builder.3.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/interp.3.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.2.elf -t "${TARGET}" -e interp-boot -o build/"${TARGET}"/bin/interp.3.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/runner.3.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.2.elf -t "${TARGET}" -e runner-boot -o build/"${TARGET}"/bin/runner.3.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/builder.3.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.2.elf -t thumb-linux-gnueabi -e build -o build/thumb-linux-gnueabi/bin/builder.3.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/interp.3.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.2.elf -t thumb-linux-gnueabi -e interp-boot -o build/thumb-linux-gnueabi/bin/interp.3.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/runner.3.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.2.elf -t thumb-linux-gnueabi -e runner-boot -o build/thumb-linux-gnueabi/bin/runner.3.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/builder.3.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.2.elf -t thumb-linux-android -e build -o build/thumb-linux-android/bin/builder.3.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/interp.3.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.2.elf -t thumb-linux-android -e interp-boot -o build/thumb-linux-android/bin/interp.3.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/runner.3.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.2.elf -t thumb-linux-android -e runner-boot -o build/thumb-linux-android/bin/runner.3.elf src/interp/strings.4th src/runner/main.4th
echo -e "Building \e[36;1mbuild/"${TARGET}"/bin/builder+core.3.elf\e[0m"
mkdir -p build/"${TARGET}"/bin/
build/"${TARGET}"/bin/builder.3.elf -t  "${TARGET}" -e  build -o build/"${TARGET}"/bin/builder+core.3.elf  src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/bin/builder.4th src/lib/asm/thumb/disasm.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/builder.4.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.3.elf -t "${TARGET}" -e build -o build/"${TARGET}"/bin/builder.4.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/interp.4.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.3.elf -t "${TARGET}" -e interp-boot -o build/"${TARGET}"/bin/interp.4.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/"${TARGET}"/bin/runner.4.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.3.elf -t "${TARGET}" -e runner-boot -o build/"${TARGET}"/bin/runner.4.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/builder.4.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.3.elf -t thumb-linux-gnueabi -e build -o build/thumb-linux-gnueabi/bin/builder.4.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/interp.4.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.3.elf -t thumb-linux-gnueabi -e interp-boot -o build/thumb-linux-gnueabi/bin/interp.4.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/thumb-linux-gnueabi/bin/runner.4.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.3.elf -t thumb-linux-gnueabi -e runner-boot -o build/thumb-linux-gnueabi/bin/runner.4.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/builder.4.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.3.elf -t thumb-linux-android -e build -o build/thumb-linux-android/bin/builder.4.elf src/include/interp.4th src/interp/cross.4th src/bin/builder.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/interp.4.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.3.elf -t thumb-linux-android -e interp-boot -o build/thumb-linux-android/bin/interp.4.elf src/include/interp.4th
echo -e "\e[36;1mBuilding build/thumb-linux-android/bin/runner.4.elf\e[0m"
./build/"${TARGET}"/bin/builder+core.3.elf -t thumb-linux-android -e runner-boot -o build/thumb-linux-android/bin/runner.4.elf src/interp/strings.4th src/runner/main.4th
echo -e "Building \e[36;1mbuild/"${TARGET}"/bin/interp+core.3.elf\e[0m"
mkdir -p build/"${TARGET}"/bin/
./build/"${TARGET}"/bin/builder+core.3.elf -t "${TARGET}" -e  interp-boot -o build/"${TARGET}"/bin/interp+core.3.elf  src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th
echo -e "Building \e[36;1mbuild/"${TARGET}"/bin/scantool.3.elf\e[0m"
mkdir -p build/"${TARGET}"/bin/
./build/"${TARGET}"/bin/builder+core.3.elf -t "${TARGET}" -e  main -o build/"${TARGET}"/bin/scantool.3.elf  src/include/interp.4th src/interp/cross.4th src/bin/scantool.4th
echo -e "Building \e[36;1mbuild/"${TARGET}"/bin/demo-tty/drawing.3.elf\e[0m"
mkdir -p build/"${TARGET}"/bin/demo-tty/
./build/"${TARGET}"/bin/builder+core.3.elf -t "${TARGET}" -e  demo-tty-boot -o build/"${TARGET}"/bin/demo-tty/drawing.3.elf  src/lib/tty/constants.4th src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/lib/tty.4th src/demos/tty/drawing.4th
echo -e "Building \e[36;1mbuild/"${TARGET}"/bin/demo-tty/clock.3.elf\e[0m"
mkdir -p build/"${TARGET}"/bin/demo-tty/
./build/"${TARGET}"/bin/builder+core.3.elf -t "${TARGET}" -e  tty-clock-boot -o build/"${TARGET}"/bin/demo-tty/clock.3.elf  src/lib/tty/constants.4th src/demos/tty/clock/segment-constants.4th src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/lib/tty.4th src/demos/tty/clock.4th
echo -e "Building \e[36;1mbuild/"${TARGET}"/bin/demo-tty/raycaster.3.elf\e[0m"
mkdir -p build/"${TARGET}"/bin/demo-tty/
./build/"${TARGET}"/bin/builder+core.3.elf -t "${TARGET}" -e  raycaster-boot -o build/"${TARGET}"/bin/demo-tty/raycaster.3.elf  src/lib/tty/constants.4th src/include/interp.4th src/interp/proper.4th src/lib/pointers.4th src/lib/list-cs.4th src/lib/structs.4th src/interp/cross.4th src/interp/boot/include.4th src/lib/tty.4th src/demos/tty/raycast.4th
echo -e "load-core \" src/cross/builder.4th\" load builder-load \" build/bin/assembler-thumb.dict\" save-dict\n" | bash ./src/bash/forth.sh
ln -sf ../../bin/fforth build/bin/assembler-thumb.sh
