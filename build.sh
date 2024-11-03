#!/bin/sh
HOST?="${2:-x86_64-linux-static}"
TARGET?="${1:-thumb-linux-static}"
echo "\" $(cat .git/refs/heads/master)\" string-const> NORTH-GIT-REF" > version.4th
echo "32 defconst> NORTH-BITS" >> version.4th
echo "$(date -u +%s) defconst> NORTH-BUILD-TIME" >> version.4th
echo "\" $(git config --get user.name) <$(git config --get user.email)>\" string-const> NORTH-BUILDER" >> version.4th
echo -e "Building \e[36;1mbin/interp.elf\e[0m"
cat src/bin/interp.4th | LC_ALL=en_US.ISO-8859-1 bash ./src/bash/forth.sh > bin/interp.elf
chmod u+x bin/interp.elf
echo -e "src/bash/compiler.4th load bin/fforth.dict save-dict\n" | bash ./src/bash/forth.sh
echo -e "\e[36;1mBuilding bin/builder.static.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./bin/interp.elf -t "${TARGET}" -e build -o bin/builder.static.1.elf ./src/include/interp.4th ./src/interp/cross.4th ./src/bin/builder.4th
echo -e "\e[36;1mBuilding bin/interp.static.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./bin/interp.elf -t "${TARGET}" -e interp-boot -o bin/interp.static.1.elf src/include/interp.4th
echo -e "\e[36;1mBuilding bin/runner.static.1.elf\e[0m"
echo '" ./src/bin/builder.4th" load build' |  ./bin/interp.elf -t "${TARGET}" -e runner-boot -o bin/runner.static.1.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding bin/builder.static.2.elf\e[0m"
./bin/builder.static.1.elf -t "${TARGET}" -e build -o bin/builder.static.2.elf ./src/include/interp.4th ./src/interp/cross.4th ./src/bin/builder.4th
echo -e "\e[36;1mBuilding bin/interp.static.2.elf\e[0m"
./bin/builder.static.1.elf -t "${TARGET}" -e interp-boot -o bin/interp.static.2.elf src/include/interp.4th
echo -e "\e[36;1mBuilding bin/runner.static.2.elf\e[0m"
./bin/builder.static.1.elf -t "${TARGET}" -e runner-boot -o bin/runner.static.2.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding bin/builder.static.3.elf\e[0m"
./bin/builder.static.2.elf -t "${TARGET}" -e build -o bin/builder.static.3.elf ./src/include/interp.4th ./src/interp/cross.4th ./src/bin/builder.4th
echo -e "\e[36;1mBuilding bin/interp.static.3.elf\e[0m"
./bin/builder.static.2.elf -t "${TARGET}" -e interp-boot -o bin/interp.static.3.elf src/include/interp.4th
echo -e "\e[36;1mBuilding bin/runner.static.3.elf\e[0m"
./bin/builder.static.2.elf -t "${TARGET}" -e runner-boot -o bin/runner.static.3.elf src/interp/strings.4th src/runner/main.4th
echo -e "\e[36;1mBuilding bin/builder.static.4.elf\e[0m"
./bin/builder.static.3.elf -t "${TARGET}" -e build -o bin/builder.static.4.elf ./src/include/interp.4th ./src/interp/cross.4th ./src/bin/builder.4th
echo -e "\e[36;1mBuilding bin/interp.static.4.elf\e[0m"
./bin/builder.static.3.elf -t "${TARGET}" -e interp-boot -o bin/interp.static.4.elf src/include/interp.4th
echo -e "\e[36;1mBuilding bin/runner.static.4.elf\e[0m"
./bin/builder.static.3.elf -t "${TARGET}" -e runner-boot -o bin/runner.static.4.elf src/interp/strings.4th src/runner/main.4th
echo -e "load-core \" src/cross/arch/thumb.4th\" load \" src/cross/builder.4th\" load \" bin/assembler-thumb.dict\" save-dict\n" | bash ./src/bash/forth.sh
ln -sf fforth bin/assembler-thumb.sh
