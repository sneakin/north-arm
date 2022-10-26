tmp" open-output-file/2" defined?/2 [UNLESS]
  def open-output-file/2 ( mode path -- fid )
    arg1 O_TRUNC O_CREAT logior O_WRONLY logior arg0 open 2 return1-n
  end
[THEN]

tmp" S_IRWXU" defined?/2 [UNLESS]
00700 const> S_IRWXU
00040 const> S_IRGRP
00010 const> S_IXGRP
00004 const> S_IROTH
00001 const> S_IXOTH
[THEN]
   
tmp" fill" defined?/2 [UNLESS]
   s[ src/lib/seq.4th ] load-list
[THEN]
   
s[ src/cross/output/data-vars.4th
   src/lib/digest/sha256.4th
] load-list

def builder-compute-output-hash ( origin size out-ptr out-size -- out-ptr out-size )
  make-sha256-state
  arg3 arg2 3 overn sha256-begin sha256-update sha256-end
  arg1 arg0 3 overn sha256->string/3 4 return2-n
end

def builder-patch-hash ( origin size word -- )
  s" Hashed " error-string/2 arg1 error-int s"  bytes to: " error-string/2
  dhere to-out-addr arg0 dict-entry-data !
  72 stack-allot
  arg2 arg1 3 overn 72 builder-compute-output-hash
  2dup error-string/2 enl ,byte-string/2
  3 return0-n
end

def builder-run ( entry len src-cons )
  0

  target-android?
  IF elf32-target-android! ELSE elf32-target-linux! THEN
  target-static? UNLESS NORTH-STAGE 2 int>= IF elf32-dynamic-stub THEN THEN
  
  builder-output-file peek IF
    S_IRWXU S_IRGRP logior S_IXGRP logior S_IROTH logior S_IXOTH logior
    builder-output-file peek open-output-file/2
    negative? IF
      s" Unable to open output file." error-line/2
      false 3 return1-n
    THEN
    builder-output poke
  THEN

  " Building..." error-line
  4 align-data ( todo align-data that's origin aware so 4k align is relative to any origin' not abs addresses )
  dhere out-origin poke
  write-elf-header
  dhere code-origin poke

  ( Plain text message: )
  BUILD-COPYRIGHT peek dup IF ,byte-string ELSE drop THEN
  ( Words to later patch: )
  s" _start" create

  ( The main stage: )
  builder-with-runner peek IF " src/include/runner.4th" load THEN
  ' builder-with-interp IF builder-with-interp peek IF " src/include/interp.4th" load THEN THEN
  ' builder-with-cross IF builder-with-cross peek IF " src/interp/cross.4th" load THEN THEN
  arg0 load-list

  s" copyright" cross-lookup IF code-origin peek to-out-addr over dict-entry-data uint32! ELSE not-found THEN drop
  s" _start" cross-lookup IF arg2 arg1 does-defalias ELSE not-found drop THEN
  s" *init-dict*" cross-lookup IF out-dict to-out-addr swap dict-entry-data uint32! ELSE not-found drop THEN
  s" immediates" cross-lookup IF output-immediates peek to-out-addr swap dict-entry-data uint32@ from-out-addr data-var-init-value uint32! ELSE not-found drop THEN
  s" *code-size*" cross-lookup IF dhere to-out-addr swap dict-entry-data uint32! ELSE not-found drop THEN
  s" *ds-offset*" cross-lookup IF elf-data-segment-offset swap dict-entry-data uint32! ELSE not-found drop THEN

  4096 align-code
  out-origin peek out-dict write-variable-data
  s" *ds-size*" cross-lookup IF dhere 3 overn - swap dict-entry-data uint32! ELSE not-found drop THEN
  s" *init-data*" cross-lookup IF over to-out-addr swap dict-entry-data uint32! ELSE not-found drop THEN
  code-origin peek
  ( entry point: )
  s" init" cross-lookup UNLESS " no init found" error-line not-found return0 THEN
  dict-entry-code uint32@ cell-size +
  ( finish the ELF file )
  write-elf-ending
  s" *program-size*" cross-lookup IF dhere to-out-addr swap dict-entry-data uint32! ELSE not-found drop THEN

  s" *program-sha256*" cross-lookup IF out-origin @ dhere over - roll builder-patch-hash ELSE not-found drop THEN

  " Writing to " error-string
  current-output peek set-local0
  builder-output peek dup
  IF current-output poke builder-output-file peek
  ELSE drop " stdout"
  THEN error-line
  
  out-origin peek ddump-binary-bytes
  builder-output peek IF current-output peek close THEN
  local0 current-output poke
  out-origin peek dhere to-out-addr exit-frame
end
