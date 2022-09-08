( stub.4th is not loaded to provide a value for *ds-offset* in constants.4th, so we make anmalias andbpatch the value before writing. )
' elf-data-segment-offset defined? [UNLESS]
  alias> elf-data-segment-offset elf32-data-segment-offset
[THEN]

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
  " *ds-offset*" cross-lookup IF elf-data-segment-offset swap dict-entry-data uint32! ELSE not-found error-line THEN

  4096 align-code
  out-origin out-dict write-variable-data
  " *ds-size*" cross-lookup IF dhere 3 overn - swap dict-entry-data uint32! ELSE not-found error-line THEN
  " *init-data*" cross-lookup IF over to-out-addr swap dict-entry-data uint32! ELSE not-found error-line THEN
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
