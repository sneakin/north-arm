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
tmp" src/cross/defining/frames-boot.4th" drop load
tmp" src/runner/thumb/linux.4th" drop load
tmp" src/runner/thumb/logic.4th" drop load
tmp" src/runner/thumb/math.4th" drop load

tmp" src/runner/thumb/proper.4th" drop load
tmp" src/runner/proper.4th" drop load
tmp" src/cross/defining/proper.4th" drop load

tmp" src/interp/messages.4th" drop load
tmp" src/interp/strings.4th" drop load
tmp" src/interp/dictionary.4th" drop load
tmp" src/interp/output.4th" drop load
tmp" src/interp/reader.4th" drop load
tmp" src/interp/interp.4th" drop load
