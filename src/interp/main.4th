require[ getopt ]

0 var> show-version
0 var> strings-to-load-before
0 var> strings-to-load-after
0 var> files-to-load
0 var> files-to-require

" hVv:r:I:e:E:S:R:" string-const> OPTS

def parse-log-level
  arg0 dup string-length
  2dup parse-int UNLESS
    drop dict dict-lookup
    IF dict-entry-data @ ELSE false return1-1 THEN
  THEN true 1 return2-n
end

def process-opts
  arg0 CASE
    s" h" OF-STR false 2 return1-n ENDOF
    s" V" OF-STR true show-version ! true 2 return1-n ENDOF
    s" v" OF-STR
      arg1 parse-log-level IF
        dup IF *interp-log-level* @ logior THEN
        *interp-log-level* !
      ELSE s" Unknown log level: " error-string/2 arg1 error-line
      THEN true 2 return1-n
    ENDOF
    s" e" OF-STR arg1 strings-to-load-before push-onto true exit-frame ENDOF
    s" E" OF-STR arg1 strings-to-load-after push-onto true exit-frame ENDOF
    s" I" OF-STR arg1 *load-paths* push-onto true exit-frame ENDOF
    s" r" OF-STR arg1 files-to-require push-onto true exit-frame ENDOF
    s" S" OF-STR arg1 dup string-length parse-int IF *interp-data-stack-size* ! THEN true 2 return1-n ENDOF
    s" R" OF-STR arg1 dup string-length parse-int IF *interp-return-stack-size* ! THEN true 2 return1-n ENDOF
    s" *" OF-STR arg1 files-to-load push-onto true exit-frame ENDOF
    drop false 2 return1-n
  ENDCASE
end

def print-usage
  banner nl
  s" Usage: " write-string/2 0 get-argv write-string s" [-" write-string/2 OPTS write-string s" ] [files...]" write-string/2 nl
  nl
  s"       -h  Display this message." write-line/2
  s"       -V  Display the version information." write-line/2
  s" -v level  Log level" write-line/2
  s"  -I path  Add path to *load-paths*." write-line/2
  s"  -r path  Require path before any evaluations." write-line/2
  s"  -e expr  Evaluate an expression before the files or stdin." write-line/2
  s"  -E expr  Evaluate an expression after the files or stdin." write-line/2
  s" -S bytes  Data stack size" write-line/2
  s" -R bytes  Return stack size" write-line/2
end

def main
  ' process-opts OPTS getopt UNLESS print-usage -1 return1 THEN
  show-version @ IF about 0 return1 THEN
  interp-init
  files-to-require @ require-list
  strings-to-load-before @ ' load-string map-car
  files-to-load @ dup IF load-list ELSE drop banner interp THEN
  strings-to-load-after @ ' load-string map-car
  0 return1
end
