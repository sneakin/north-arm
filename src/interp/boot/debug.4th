s[ src/lib/bit-fields.4th
   src/lib/assert.4th
   src/interp/boot/debug/program-args.4th
   src/interp/boot/debug/fancy-stack.4th
] load-list

NORTH-PLATFORM tmp" thumb" drop string-contains? IF
  " src/interp/boot/debug/arm.4th" load
THEN

def fork-loop
  fg-fork IF wexitstatus 0 equals? UNLESS repeat-frame THEN THEN
end
