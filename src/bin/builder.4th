tmp" alias" defined?/2 [UNLESS] load-core [THEN]
" src/lib/getopt.4th" load

" src/cross/builder/interp.4th" load

null var> sources
" main" string-const> DEFAULT-ENTRY-POINT
DEFAULT-ENTRY-POINT var> entry-point
false var> verbosity
0 var> start-interpreter

def reset!
  builder-reset!
  0 sources !
  DEFAULT-ENTRY-POINT entry-point !
  0 start-interpreter !
end

def inc!
  arg0 @ 1 + arg0 !
  1 return0-n
end
  
def process-opts
  arg0 CASE
    s" h" WHEN-STR false 2 return1-n ;;
    s" e" WHEN-STR arg1 entry-point ! true 2 return1-n ;;
    s" t" WHEN-STR arg1 builder-target ! true 2 return1-n ;;
    s" v" WHEN-STR verbosity inc! true 2 return1-n ;;
    s" r" WHEN-STR false builder-with-runner ! true 2 return1-n ;;
    s" b" WHEN-STR arg1 builder-output-format ! true 2 return1-n ;;
    s" o" WHEN-STR arg1 builder-output-file ! true 2 return1-n ;;
    s" i" WHEN-STR start-interpreter inc! true 2 return1-n ;;
    s" *" WHEN-STR arg1 sources push-onto true exit-frame ;;
    drop false 2 return1-n
  ESAC  
end

def BUILDER-TARGET
  builder-target @ return1
end

def north-stacks-init!
  return-stack peek UNLESS
    512 proper-init
    verbosity @ IF s" Initialized return stack: " error-string/2 THEN
    return-stack @ error-hex-uint enl
  THEN

  dhere UNLESS
    256 1024 * data-init-stack
    verbosity @ IF s" Initialized data stack: " error-string/2 THEN
    data-stack-base @ error-hex-uint espace
    data-stack-size @ error-uint enl
  THEN

  exit-frame
end

" ht:e:vrb:o:i" string-const> OPTS

def build
  reset!

  ' process-opts OPTS getopt UNLESS
    s" Usage: " error-string/2 0 get-argv error-string
    s"  [-" error-string/2 OPTS error-string s" ] files..." error-string/2 enl
    enl
    s"         -h  Help" error-line/2
    s"  -t target  Platform to target" error-line/2
    s"    -e word  Word to use as the entry point." error-line/2
    s"    -b name  Output format" error-line/2
    s"    -o path  Output file name" error-line/2
    s"         -r  Do not include the runner." error-line/2
    s"         -i  Increase counter to start interpreter" error-line/2
    s"         -v  Increase verbosity" error-line/2
    -1 sysexit
  THEN

  north-stacks-init!
  interp-init

  verbosity @ IF
    s" Target: " error-string/2 builder-target @ error-line
    s" Output file: " error-string/2 builder-output-file @ dup IF error-line ELSE drop s" stdout" error-line/2 THEN
    s" Output format: " error-string/2 builder-output-format @ error-line
    s" Entry point: " error-string/2 entry-point @ error-line
    s" With runner: " error-string/2 builder-with-runner @ error-int enl
    s" Intpreter: " error-string/2 start-interpreter @ error-int enl
    s" Sources:" error-line/2 sources @ ' error-line map-car
  THEN

  start-interpreter @ 1 equals? IF interp THEN
  
  " src/copyright.4th" load

  builder-load

  start-interpreter @ 2 equals? IF interp THEN
  ( builder-target @ string-const> BUILDER-TARGET )

  entry-point @
  dup string-length
  sources @
  s" builder-run" dict dict-lookup IF
    rot 2 dropn exec-abs
  ELSE 6 dropn
  THEN

  exit-frame
end
