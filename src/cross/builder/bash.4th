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
  src/runner/cells.4th
  src/runner/stack.4th
  src/runner/thumb/copiers.4th
  src/runner/copy.4th
  src/runner/thumb/vfp-constants.4th
  src/runner/thumb/proper.4th
  src/runner/proper.4th
  src/runner/aliases.4th
  src/runner/thumb/state.4th
   src/runner/dictionary.4th
   src/runner/thumb/math-init.4th
   version.4th
   src/runner/thumb/init.4th
  ] load-list exit-frame
end

(   src/runner/thumb/ffi.4th
  src/runner/ffi.4th
)
(   src/cross/dynlibs.4th
)

def builder-load
  " src/cross/arch/thumb.4th" load ( fixme swap load-thumb-asm? )
  exit-frame
end

def builder-run ( entry-fn fn-length files-cons ++ )
  " Building..." error-line
  dhere set-out-origin
  write-elf32-header
  dhere set-code-origin

  BUILD-COPYRIGHT dup IF ,byte-string ELSE drop THEN
  " _start" create
  
  ( The main stage: )
  builder-with-runner IF
    load-runner
    ( " src/include/runner.4th" load )
  THEN
  arg0 load-list

  " copyright" cross-lookup IF code-origin to-out-addr over dict-entry-data uint32! ELSE not-found error-line THEN drop
  " _start" cross-lookup IF arg2 does-defalias ELSE not-found error-line THEN
  " *init-dict*" cross-lookup IF out-dict to-out-addr swap dict-entry-data uint32! ELSE not-found error-line THEN
  " *code-size*" cross-lookup IF dhere to-out-addr swap dict-entry-data uint32! ELSE not-found error-line THEN

  code-origin
  ( entry point: )
  " init" cross-lookup UNLESS " no init found" error-line not-found return THEN
  dict-entry-code uint32@ cell-size +
  ( finish the ELF file )
  write-elf32-ending
  " *program-size*" cross-lookup IF dhere to-out-addr swap dict-entry-data uint32! ELSE not-found error-line THEN

  " Writing..." error-line
  out-origin .s ddump-binary-bytes
  dhere to-out-addr return1
end
