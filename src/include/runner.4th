( Core ops )
s[ src/runner/thumb/ops.4th
   src/runner/thumb/cpu.4th
   src/runner/thumb/vfp.4th
 ] load-list

NORTH-STAGE 0 int> [IF]
  s[ src/cross/dynlibs.4th ] load-list
[THEN]

( Cross compiler )
s[
   src/cross/list.4th
   src/interp/boot/cross/iwords.4th
   src/cross/defining/constants.4th
   src/cross/constants.4th
   src/cross/defining/variables.4th
   src/lib/stack.4th
   src/cross/defining/colon-boot.4th
   src/cross/defining/colon.4th

   src/interp/boot/cross/case.4th
 ] load-list

( Platform ops and words )
s[ src/runner/thumb/frames.4th
   src/runner/frames.4th
   src/cross/defining/frames-boot.4th
   src/runner/constants.4th
   src/runner/thumb/copiers.4th
   src/runner/cells.4th
   src/runner/stack.4th
   src/runner/copy.4th
   src/runner/thumb/linux.4th
   src/runner/thumb/linux/signals/syscalls.4th
   src/runner/thumb/ffi.4th
   src/runner/thumb/logic.4th
   src/runner/thumb/math/cmp.4th
   src/runner/thumb/math/signed.4th
   src/runner/math/division.4th
   src/runner/thumb/math/division.4th
   src/runner/thumb/math/carry.4th
   src/runner/thumb/math/int64.4th
   src/runner/thumb/state.4th
   src/runner/math.4th
   src/runner/aliases.4th
   src/runner/thumb/vfp-constants.4th
   src/runner/thumb/proper.4th
   src/runner/proper.4th
   src/interp/data-stack.4th
   src/runner/thumb/state.4th
   src/runner/dictionary.4th
   src/runner/thumb/math-init.4th
   version.4th
   src/runner/thumb/init.4th
] load-list
