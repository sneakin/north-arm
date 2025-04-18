
' alias UNLESS load-core THEN
" src/lib/getopt.4th" load
" src/interp/dictionary/revmap.4th" load
" src/interp/dictionary/dump.4th" load
" src/cross/builder/interp.4th" load

DEFINED? error-bool UNLESS
  " src/interp/output/bool.4th" load
THEN

null var> sources
" main" string-const> DEFAULT-ENTRY-POINT
DEFAULT-ENTRY-POINT var> entry-point
false var> verbosity
0 var> start-interpreter
false var> do-dump-dict
false var> show-version

" hVt:e:vricb:o:dQ" string-const> OPTS

def reset!
  builder-reset!
  0 sources !
  DEFAULT-ENTRY-POINT entry-point !
  0 start-interpreter !
end

def process-opts
  arg0 CASE
    s" h" WHEN-STR false 2 return1-n ;;
    s" V" WHEN-STR true show-version ! true 2 return1-n ;;
    s" e" WHEN-STR arg1 entry-point ! true 2 return1-n ;;
    s" t" WHEN-STR arg1 builder-target ! true 2 return1-n ;;
    s" v" WHEN-STR verbosity inc! true 2 return1-n ;;
    s" r" WHEN-STR false builder-with-runner ! true 2 return1-n ;;
    s" i" WHEN-STR true builder-with-interp ! true 2 return1-n ;;
    s" c" WHEN-STR true builder-with-cross ! true 2 return1-n ;;
    s" b" WHEN-STR arg1 builder-output-format ! true 2 return1-n ;;
    s" o" WHEN-STR arg1 builder-output-file ! true 2 return1-n ;;
    s" d" WHEN-STR start-interpreter inc! true 2 return1-n ;;
    s" Q" WHEN-STR true do-dump-dict ! true 2 return1-n ;;
    s" *" WHEN-STR arg1 sources push-onto true exit-frame ;;
    drop false 2 return1-n
  ESAC  
end

def BUILDER-TARGET
  builder-target @ return1
end

def build
  reset!

  ( todo init builder-target-bits and endian by target and option )
  
  ' process-opts OPTS getopt UNLESS
    s" Usage: " write-string/2 0 get-argv write-string
    s"  [-" write-string/2 OPTS write-string s" ] files..." write-string/2 nl
    nl
    s"         -h  Help" write-line/2
    s"         -V  Print version info." write-line/2
    s"  -t target  Platform to target" write-line/2
    s"    -e word  Word to use as the entry point." write-line/2
    s"    -b name  Output format" write-line/2
    s"    -o path  Output file name" write-line/2
    s"         -r  Do not include the runner." write-line/2
    s"         -i  Do include the interpreter." write-line/2
    s"         -c  Do include the aliases to ease cross compiling." write-line/2
    s"         -Q  Dump the dictionary and exit." write-line/2
    s"         -d  Increase counter to start interpreter" write-line/2
    s"         -v  Increase verbosity" write-line/2
    -1 return1
  THEN

  show-version @ IF about 0 return1 THEN

  ( fixme the condition can be removed once interp-init is updated to check for prior init )
  return-stack @ UNLESS interp-init THEN

  verbosity @ IF
    s" Target: " error-string/2 builder-target @ error-line
    s" Output file: " error-string/2 builder-output-file @ dup IF error-line ELSE drop s" stdout" error-line/2 THEN
    s" Output format: " error-string/2 builder-output-format @ error-line
    s" Entry point: " error-string/2 entry-point @ error-line
    s" With runner: " error-string/2 builder-with-runner @ error-int enl
    s" With interp: " error-string/2 builder-with-interp @ error-int enl
    s" With cross: " error-string/2 builder-with-cross @ error-int enl
    s" Intpreter: " error-string/2 start-interpreter @ error-int enl
    s" Dump dictionary? " error-string/2 do-dump-dict @ error-bool enl
    s" Sources: " error-line/2 sources @ ' error-line map-car
  THEN

  start-interpreter @ 1 equals? IF interp THEN
  
  " src/copyright.4th" load

  builder-load

  do-dump-dict @ IF dump-dict 0 return1 THEN
  start-interpreter @ 2 equals? IF interp THEN

  entry-point @
  dup string-length
  sources @
  s" builder-run" dict dict-lookup IF
    rot 2 dropn exec-abs
  ELSE 6 dropn
  THEN

  0 exit-frame
end
