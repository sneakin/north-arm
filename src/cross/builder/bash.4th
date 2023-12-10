( functions like in boot or based on a flag? based on host. )

s[ src/cross/builder/globals.4th
   src/cross/builder/predicates/bash.4th
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
  " src/cross/arch/thumb.4th" load ( fixme swap load-thumb-asm? )
  " src/cross/builder/run/bash.4th" load
  exit-frame
end
