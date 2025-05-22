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
0 var> start-interpreter
false var> do-dump-dict
false var> show-version

def spaced-error-string
  arg0 as-code-pointer espace error-string
  1 return0-n
end

def spaced-write-string
  arg0 as-code-pointer space write-string
  1 return0-n
end

def builder-has-feature? ( str length -- yes? )
  arg1 arg0 builder-baked-features @ list+cs-has-string? 2 return1-n
end

def parse-log-level
  arg0 dup string-length
  2dup parse-int UNLESS
    drop dict dict-lookup
    IF dict-entry-data @ ELSE false return1-1 THEN
  THEN true 1 return2-n
end

" hVt:e:v:Bb:I:Z:X:f:o:dQ" string-const> OPTS

def reset!
  builder-reset!
  0 sources !
  DEFAULT-ENTRY-POINT entry-point !
  0 start-interpreter !
end

def process-opts
  arg0 CASE
    s" h" OF-STR false 2 return1-n ENDOF
    s" V" OF-STR true show-version ! true 2 return1-n ENDOF
    s" e" OF-STR arg1 entry-point ! true 2 return1-n ENDOF
    s" t" OF-STR arg1 builder-target ! true 2 return1-n ENDOF
    s" v" OF-STR
      arg1 parse-log-level IF
        dup IF *interp-log-level* @ logior THEN
        *interp-log-level* !
      ELSE s" Unknown log level: " error-string/2 arg1 error-line
      THEN true 2 return1-n
    ENDOF
    s" B" OF-STR true builder-bare-bones ! true 2 return1-n ENDOF
    s" b" OF-STR arg1 builder-baked-features push-onto true exit-frame ENDOF
    s" I" OF-STR arg1 builder-load-paths push-onto true exit-frame ENDOF
    s" Z" OF-STR
      arg1 CASE
        s" load-paths" OF-STR 0 builder-load-paths ! ENDOF
        s" file-exts" OF-STR 0 builder-file-exts ! ENDOF
        s" Warning: unknown zeroing: " error-string/2 error-line
      ENDCASE
      true 2 return1-n
    ENDOF
    s" X" OF-STR arg1 builder-file-exts push-onto true exit-frame ENDOF
    s" f" OF-STR arg1 builder-output-format ! true 2 return1-n ENDOF
    s" o" OF-STR arg1 builder-output-file ! true 2 return1-n ENDOF
    s" d" OF-STR start-interpreter inc! true 2 return1-n ENDOF
    s" Q" OF-STR true do-dump-dict ! true 2 return1-n ENDOF
    s" *" OF-STR arg1 sources push-onto true exit-frame ENDOF
    drop false 2 return1-n
  ENDCASE
end

def print-builder-usage
  s" Usage: " write-string/2 0 get-argv write-string
  s"  [-" write-string/2 OPTS write-string s" ] files..." write-string/2 nl
  nl
  s"         -h  Help" write-line/2
  s"         -V  Print version info." write-line/2
  s"  -t target  Platform to target" write-line/2
  s"    -e word  Word to use as the entry point." write-line/2
  s"    -f name  Output format" write-line/2
  s"    -o path  Output file name" write-line/2
  s"         -B  Do not include anything." write-line/2
  s" -b feature  Include feature: runner, interpreter, crossover." write-line/2
  s"               Default: runner" write-line/2
  s"    -I path  Add path the the load-paths list." write-line/2
  ' *load-paths* IF
    s"               Defaults: " write-string/2 *load-paths* @ as-code-pointer ' spaced-write-string map-car+cs nl
  THEN
  s"    -Z flag  Clear the named list: load-paths file-exts" write-line/2
  s"     -X ext  Add EXT to the file extesnions list." write-line/2
  ' *north-file-exts* IF
    s"               Defaults:" write-string/2 *north-file-exts* @ as-code-pointer ' spaced-write-string map-car+cs nl
  THEN
  s"         -Q  Dump the dictionary and exit." write-line/2
  s"         -d  Increase counter to start interpreter" write-line/2
  s"   -v level  Add a log level by nawe or value" write-line/2
end

def dump-builder-config
  s" Target: " error-string/2 builder-target @ error-line
  s" Output file: " error-string/2 builder-output-file @ dup IF error-line ELSE drop s" stdout" error-line/2 THEN
  s" Output format: " error-string/2 builder-output-format @ error-line
  s" Entry point: " error-string/2 entry-point @ error-line
  s" Bare bones? " error-string/2 builder-bare-bones @ error-bool enl
  s" Baked features:" error-string/2 builder-baked-features @ dup IF ' spaced-error-string map-car+cs ELSE drop THEN enl
  s"   With runner? " error-string/2 builder-with-runner @ error-bool enl
  s"   With interp? " error-string/2 builder-with-interp @ error-bool enl
  s"   With cross? " error-string/2 builder-with-cross @ error-bool enl
  s" Interpreter: " error-string/2 start-interpreter @ error-bool enl
  s" Dump dictionary? " error-string/2 do-dump-dict @ error-bool enl
  s" Load paths:" error-string/2 builder-load-paths @ dup IF ' spaced-error-string map-car+cs ELSE drop THEN enl
  s" File exts:" error-string/2 builder-file-exts @ dup IF ' spaced-error-string map-car+cs ELSE drop THEN enl
  s" Sources:" error-line/2 sources @ dup IF ' spaced-error-string map-car enl ELSE drop THEN enl
end

def build
  ( fixme the condition can be removed once interp-init is updated to check for prior init )
  return-stack @ UNLESS interp-init THEN

  reset!

  ( todo init builder-target-bits and endian by target and option )
  
  ' process-opts OPTS getopt UNLESS print-builder-usage -1 return1 THEN

  show-version @ IF about 0 return1 THEN

  builder-baked-features @ UNLESS
    builder-bare-bones @ UNLESS
      s[ runner ] builder-baked-features !
    THEN
  THEN

  s" runner" builder-has-feature? builder-with-runner !
  s" interp" builder-has-feature? builder-with-interp !
  s" crossover" builder-has-feature? builder-with-cross !

  LOG-USER-INFO interp-logs? IF dump-builder-config THEN
  start-interpreter @ 1 equals? IF interp THEN
  do-dump-dict @ IF dump-dict 0 return1 THEN

  " src/copyright.4th" load

  builder-load

  start-interpreter @ 2 equals? IF interp THEN

  entry-point @ dup string-length
  sources @
  s" builder-run" dict dict-lookup
  IF rot 2 dropn exec-abs
  ELSE 6 dropn
  THEN 0 exit-frame
end
