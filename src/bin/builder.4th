' alias [UNLESS] load-core [THEN]
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
    s" i" WHEN-STR true builder-with-interp ! true 2 return1-n ;;
    s" c" WHEN-STR true builder-with-cross ! true 2 return1-n ;;
    s" b" WHEN-STR arg1 builder-output-format ! true 2 return1-n ;;
    s" o" WHEN-STR arg1 builder-output-file ! true 2 return1-n ;;
    s" d" WHEN-STR start-interpreter inc! true 2 return1-n ;;
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
    verbosity @ IF s" Initialized return stack: " error-string/2
		   return-stack @ error-hex-uint enl
		THEN
  THEN

  dhere UNLESS
    256 1024 * data-init-stack
    verbosity @ IF s" Initialized data stack: " error-string/2
		   data-stack-base @ error-hex-uint espace
		   data-stack-size @ error-uint enl
		THEN
  THEN

  exit-frame
end

" ht:e:vricb:o:d" string-const> OPTS

def build
  reset!

  ' process-opts OPTS getopt UNLESS
    s" Usage: " write-string/2 0 get-argv write-string
    s"  [-" write-string/2 OPTS write-string s" ] files..." write-string/2 nl
    nl
    s"         -h  Help" write-line/2
    s"  -t target  Platform to target" write-line/2
    s"    -e word  Word to use as the entry point." write-line/2
    s"    -b name  Output format" write-line/2
    s"    -o path  Output file name" write-line/2
    s"         -r  Do not include the runner." write-line/2
    s"         -i  Do include the interpreter." write-line/2
    s"         -c  Do include the aliases to ease cross compiling." write-line/2
    s"         -d  Increase counter to start interpreter" write-line/2
    s"         -v  Increase verbosity" write-line/2
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
    s" With interp: " error-string/2 builder-with-interp @ error-int enl
    s" With cross: " error-string/2 builder-with-cross @ error-int enl
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
