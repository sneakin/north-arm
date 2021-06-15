( functions like in boot or based on a flag? based on host. )

" src/cross/arch/thumb.4th" load

4 const> cell-size
4 const> -op-size
0xFFFFFFFF const> -op-mask

( Needs literals handled. )
( 2 const> -op-size )
( Needs defconst sooner. )

0 var> code-origin

def load-runner
  s[
  src/runner/thumb/ops.4th
  src/runner/thumb/cpu.4th
  src/runner/thumb/vfp.4th
  src/cross/string-list.4th
  src/cross/defining/colon-bash.4th
  src/cross/defining/colon.4th
  src/cross/defining/alias.4th
  src/cross/defining/constants.4th
  src/cross/constants.4th
  src/cross/defining/variables.4th
  src/runner/thumb/frames.4th
  src/runner/frames.4th
  src/cross/defining/frames.4th
  src/runner/constants.4th
  src/runner/thumb/linux.4th
  src/runner/thumb/linux/signals/syscalls.4th
  src/runner/thumb/ffi.4th
  src/runner/thumb/logic.4th
  src/runner/thumb/math.4th
  src/runner/math.4th
  src/runner/stack.4th
  src/runner/thumb/copiers.4th
  src/runner/copy.4th
  src/runner/thumb/vfp-constants.4th
  src/runner/thumb/proper.4th
  src/runner/proper.4th
  src/runner/aliases.4th
  src/runner/thumb/state.4th
  ] load-list exit-frame
end

(   src/runner/thumb/ffi.4th
  src/runner/ffi.4th
)
(   src/cross/dynlibs.4th
)

def builder-run ( entry-fn fn-length files-cons ++ )
  " Building..." error-line
  dhere set-out-origin
  write-elf32-header
  dhere set-code-origin

  ( The main stage: )
  load-runner
  arg0 load-list

  ' main create arg2 does-defalias
  " version.4th" load
  " src/runner/thumb/init.4th" load
  " *code-size*" cross-lookup IF dhere to-out-addr swap dict-entry-data uint32! ELSE not-found error-line THEN

  code-origin
  ( entry point: )
  " init" cross-lookup UNLESS " no init found" error-line not-found return THEN
  dict-entry-code uint32@
  ( finish the ELF file )
  write-elf32-ending
  " *program-size*" cross-lookup IF dhere to-out-addr swap dict-entry-data uint32! ELSE not-found error-line THEN

  " Writing..." error-line
  out-origin .s ddump-binary-bytes
  dhere to-out-addr return1
end
