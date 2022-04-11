gcc -m32 -mcpu=armv6k -fpic -ffreestanding -c stub.S -o stub.o
gcc -T linker.ld -o myos.elf -ffreestanding -O2 -nostdlib stub.o -lgcc
objcopy myos.elf -O binary kernel7.img
