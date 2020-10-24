( todo write the elf data and dump to stdout )
( todo non-origin data fields? )
( todo move defining/*-boot files to interp/boot/defining )

dhere out-origin poke

tmp" src/runner/thumb/ops.4th" drop load

tmp" src/cross/defining/constants.4th" drop load
tmp" src/cross/defining/variables.4th" drop load
tmp" src/lib/stack.4th" drop load
tmp" src/cross/defining/colon-boot.4th" drop load
tmp" src/cross/defining/colon.4th" drop load

tmp" src/runner/thumb/aliases.4th" drop load
tmp" src/runner/thumb/frames.4th" drop load
tmp" src/runner/frames.4th" drop load
( tmp" src/cross/defining/frames.4th" drop load {
( tmp" src/runner/thumb/linux.4th" drop load )
