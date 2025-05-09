DEFINED? fill UNLESS
   s[ src/lib/seq.4th ] load-list
THEN

DEFINED? map-car/3 UNLESS
  " src/lib/list.4th" load
THEN
   
s[ src/lib/digest/sha256.4th ] load-list

false var> NORTH-COMPILE-TIME ( Track if the output compiling words are loaded. Defined here instead of globals.4th so it remains undefined until this file is loaded. )
0 var> boot-punter
0 var> copyright-address

DEFINED? builder-bare-bones IF
  def builder-bare-bones? builder-bare-bones @ return1 end
ELSE
  def builder-bare-bones? false return1 end
THEN

DEFINED? open-output-file/2 UNLESS
  def open-output-file/2 ( mode path -- fid )
    arg1 O_TRUNC O_CREAT logior O_WRONLY logior arg0 open 2 return1-n
  end
THEN

DEFINED? S_IRWXU UNLESS
  00700 const> S_IRWXU
  00040 const> S_IRGRP
  00010 const> S_IXGRP
  00004 const> S_IROTH
  00001 const> S_IXOTH
THEN
   
s[ src/cross/output/data-vars.4th
   src/cross/output/structs.4th
] load-list

def builder-compute-output-hash ( origin size out-ptr out-size -- out-ptr out-size )
  make-sha256-state
  arg3 arg2 3 overn sha256-begin sha256-update sha256-end
  arg1 arg0 3 overn sha256->string/3 4 return2-n
end

def builder-hash-program ( origin size -- hash-ptr )
  s" Hashed " error-string/2 arg0 error-int s"  bytes to: " error-string/2
  dhere
  72 stack-allot
  arg1 arg0 3 overn 72 builder-compute-output-hash
  2dup error-string/2 enl ,byte-string/2
  local0 2 return1-n
end

def update-constant ( value str n -- )
  arg1 arg0 cross-lookup LOOKUP-WORD equals?
  IF arg2 over dict-entry-data uint32!
  ELSE not-found
  THEN 3 return0-n
end

def update-data-var-init ( value str n -- )
  arg1 arg0 cross-lookup LOOKUP-WORD equals?
  IF dict-entry-data uint32@ from-out-addr data-var-init-value
     arg2 swap uint32!
  ELSE not-found
  THEN 3 return0-n
end

DEFINED? *load-paths* IF
  def builder-store-load-paths
    *loaded-files* @ *load-paths* @ *north-file-exts* @
    here exit-frame
  end

  def builder-set-load-paths
    arg0 2 seq-peek *loaded-files* !
    arg0 1 seq-peek *load-paths* !
    arg0 0 seq-peek *north-file-exts* !
    1 return0-n
  end
ELSE
  def builder-store-load-paths
    0 return1
  end

  def builder-set-load-paths
    1 return0-n
  end
THEN

def builder-run ( entry len src-cons )
  0 0 builder-store-load-paths set-local1

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

  0 builder-load-paths @ builder-file-exts @ here builder-set-load-paths 3 dropn
  builder-load-paths @ as-code-pointer ' error-line map-car+cs

  " Building..." error-line
  4 align-data ( todo align-data that's origin aware so 4k align is relative to any origin' not abs addresses )
  dhere out-origin poke
  write-elf-header
  dhere code-origin poke

  builder-bare-bones? UNLESS
    ( Plain text message: )
    target-raspi? IF " src/runner/thumb/boot.4th" load THEN
    dhere copyright-address poke
    BUILD-COPYRIGHT peek dup IF ,byte-string ELSE drop THEN
    ( Words to later patch: )
    s" _start" create
  THEN

  ( todo options to load a file before and after the runner )
  ( The main stage: )
  true NORTH-COMPILE-TIME poke
  builder-bare-bones? UNLESS
    builder-with-runner peek IF " src/include/runner.4th" load THEN
    ' builder-with-interp IF builder-with-interp peek IF " src/include/interp.4th" load THEN THEN
    ' builder-with-cross IF builder-with-cross peek IF " src/interp/cross.4th" load THEN THEN
  THEN
  arg0 load-list

  builder-bare-bones? UNLESS
    out-dict update-structs
    s" _start" cross-lookup IF arg2 arg1 does-defalias ELSE not-found drop THEN
    copyright-address peek to-out-addr s" copyright" update-constant
    out-dict to-out-addr s" *init-dict*" update-constant
    output-immediates peek to-out-addr s" immediates" update-data-var-init
    dhere to-out-addr s" *code-size*" update-constant
    elf-data-segment-offset s" *ds-offset*" update-constant

    4096 align-code
    out-origin peek out-dict write-variable-data
    dhere over - s" *ds-size*" update-constant
    dup to-out-addr s" *init-data*" update-constant
  ELSE
    dhere
  THEN
  
  code-origin peek
  ( entry point: )
  s" init" cross-lookup
  IF dict-entry-code uint32@ cell-size +
  ELSE
    drop
    arg2 arg1 parse-uint UNLESS
      " Warning: no init found or numeric entry point given" error-line
      drop dup to-out-addr
    THEN
  THEN
  boot-punter peek dup IF 2dup to-out-addr - swap poke ELSE drop THEN
  ( finish the ELF file )
  write-elf-ending

  builder-bare-bones? UNLESS
    dhere to-out-addr s" *program-size*" update-constant
    out-origin peek dhere over - builder-hash-program
    to-out-addr s" *program-sha256*" update-constant
  THEN

  " Writing to " error-string
  current-output peek set-local0
  builder-output peek dup
  IF current-output poke builder-output-file peek
  ELSE drop " stdout"
  THEN error-line
  
  out-origin peek ddump-binary-bytes
  builder-output peek IF current-output peek close THEN
  local0 current-output poke
  out-origin peek dhere to-out-addr

  local1 builder-set-load-paths
  
  ok-s error-line
  exit-frame ( todo how much can be cleaned up? )
end
