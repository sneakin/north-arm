tmp" open-output-file/2" defined?/2 [UNLESS]
  def open-output-file/2 ( mode path -- fid )
    arg1 O_CREAT O_WRONLY logior arg0 open 2 return1-n
  end
[THEN]

def builder-run ( entry len src-cons )
  0

  target-android?
  IF elf32-target-android! ELSE elf32-target-linux! THEN
  target-static? UNLESS NORTH-STAGE 2 int> IF elf32-dynamic-stub THEN THEN
  
  builder-output-file peek IF
    0755 builder-output-file peek open-output-file/2
    negative? IF
      s" Unable to open output file." error-line/2
      false 3 return1-n
    THEN
    builder-output poke
  THEN

  " Building..." error-line
  4 align-data
  dhere out-origin poke
  write-elf-header
  dhere code-origin poke

  ( Plain text message: )
  BUILD-COPYRIGHT peek dup IF ,byte-string ELSE drop THEN
  ( Words to later patch: )
  s" _start" create

  ( The main stage: )
  builder-with-runner peek IF " src/include/runner.4th" load THEN
  builder-with-interp peek IF " src/include/interp.4th" load THEN
  builder-with-cross peek IF " src/interp/cross.4th" load THEN
  arg0 load-list

  s" copyright" cross-lookup IF code-origin peek to-out-addr over dict-entry-data uint32! ELSE not-found THEN drop
  s" _start" cross-lookup IF arg2 arg1 does-defalias ELSE not-found drop THEN
  s" *init-dict*" cross-lookup IF out-dict to-out-addr swap dict-entry-data uint32! ELSE not-found drop THEN
  s" *code-size*" cross-lookup IF dhere to-out-addr swap dict-entry-data uint32! ELSE not-found drop THEN

  code-origin peek
  ( entry point: )
  s" init" cross-lookup UNLESS " no init found" error-line not-found return THEN
  dict-entry-code uint32@ cell-size +
  ( finish the ELF file )
  write-elf-ending
  s" *program-size*" cross-lookup IF dhere to-out-addr swap dict-entry-data uint32! ELSE not-found drop THEN

  " Writing to " error-string
  current-output peek set-local0
  builder-output peek dup IF
    current-output poke
    builder-output-file peek
  ELSE
    drop
    " stdout"
  THEN error-line
  
  out-origin peek .s ddump-binary-bytes
  builder-output peek IF current-output peek close THEN
  local0 current-output poke
  dhere to-out-addr exit-frame
end
