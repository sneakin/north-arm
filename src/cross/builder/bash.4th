( functions like in boot or based on a flag? based on host. )

s[ src/cross/builder/globals.4th
   src/cross/builder/predicates/bash.4th
   src/cross/builder/marks.4th
] load-list

( todo duplicated by include/runner.4th )
def load-runner
  s[
  src/runner/thumb/ops.4th
  src/runner/thumb/cpu.4th
  src/runner/thumb/vfp.4th

  src/cross/string-list.4th
  src/cross/defining/colon.4th
  src/cross/defining/constants.4th
  src/cross/constants.4th
  src/cross/defining/variables.4th
  src/cross/output/data-vars.4th
  
  src/runner/thumb/frames.4th
  src/runner/frames.4th
  src/cross/defining/frames.4th
  src/runner/thumb/constants.4th
  src/runner/constants.4th
  src/runner/thumb/state.4th
  src/runner/thumb/linux.4th
  src/runner/thumb/linux/signals/syscalls.4th
  src/runner/thumb/ffi.4th
  src/runner/logic.4th
  src/runner/thumb/math/cmp.4th
  src/runner/math/signed.4th
  src/runner/math/division.4th
  src/runner/thumb/math/division.4th
  src/runner/thumb/math/carry.4th
  src/runner/thumb/math/int64.4th
  src/runner/math.4th
  src/runner/cells.4th
  src/runner/stack.4th
  src/runner/thumb/copiers.4th
  src/runner/copy.4th
  src/runner/thumb/vfp-constants.4th
  src/runner/thumb/proper.4th
  src/runner/proper.4th
  src/runner/aliases.4th
  ( src/interp/data-stack.4th )
  src/runner/thumb/state.4th
  src/runner/dictionary.4th
  src/runner/frame-tailing.4th
  src/runner/thumb/math-init.4th
  version.4th
  src/runner/thumb/init.4th
  ] load-list exit-frame
end

def builder-load
  s[ src/lib/case.4th
     src/lib/stack-marker.4th
     src/lib/map/stack.4th
     src/lib/bit-fields.4th
     src/lib/byte-data.4th
   ] load-list

  target-thumb? IF " src/lib/asm/thumb.4th" load THEN
  target-aarch32? IF " src/lib/asm/aarch32.4th" load THEN
  target-x86? IF " src/lib/asm/x86.4th" load THEN

  s[ src/cross/words.4th
     src/cross/iwords.4th
     src/cross/owords.4th
     src/cross/oiwords.4th
     src/cross/list.4th
     src/cross/defining/op.4th
     src/cross/defining/alias.4th
     src/cross/case.4th
     src/lib/elf/stub32.4th

     src/cross/builder/run/bash.4th
   ] load-list
  exit-frame
end
