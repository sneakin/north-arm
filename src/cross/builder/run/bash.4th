false var> NORTH-COMPILE-TIME ( Track if the output compiling words are loaded. Defined here instead of globals.4th so it remains undefined until this file is loaded. )

( stub.4th is not loaded to provide a value for *ds-offset* in constants.4th, so we make an alias and patch the value before writing. )
DEFINED? elf-data-segment-offset UNLESS
  alias> elf-data-segment-offset elf32-data-segment-offset
THEN

def update-constant ( value name -- )
  arg0 cross-lookup
  IF arg1 over dict-entry-data uint32!
  ELSE not-found error-line
  THEN 2 return0-n
end

def update-data-var-init ( value name -- )
  arg0 cross-lookup
  IF dict-entry-data uint32@ from-out-addr data-var-init-value
     arg1 swap uint32!
  ELSE not-found error-line
  THEN 2 return0-n
end

def builder-run ( entry-fn fn-length files-cons ++ )
  " Building..." error-line
  dhere set-out-origin
  write-elf32-header
  dhere set-code-origin

  BUILD-COPYRIGHT dup IF ,byte-string ELSE drop THEN
  " _start" create
  
  ( The main stage: )
  true set-NORTH-COMPILE-TIME
  builder-with-runner IF
    load-runner
    ( " src/include/runner.4th" load )
  THEN
  arg0 load-list

  code-origin to-out-addr " copyright" update-constant
  " _start" cross-lookup IF arg2 does-defalias ELSE not-found error-line THEN
  out-dict to-out-addr " *init-dict*" update-constant
  out-immediates to-out-addr " immediates" update-data-var-init
  dhere to-out-addr " *code-size*" update-constant
  elf-data-segment-offset " *ds-offset*" update-constant

  4096 align-code
  out-origin out-dict write-variable-data
  dhere over - " *ds-size*" update-constant
  dup to-out-addr " *init-data*" update-constant
  code-origin
  ( entry point: )
  " init" cross-lookup UNLESS " no init found" error-line not-found return THEN
  dict-entry-code uint32@ cell-size +
  ( finish the ELF file )
  write-elf32-ending
  dhere to-out-addr " *program-size*" update-constant

  " Writing..." error-line
  out-origin .s ddump-binary-bytes
  " Ok" error-line
  dhere to-out-addr return1
end
