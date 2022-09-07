( Can build with:
    ~bin/builder.android.3.elf -o bin/scantool src/include/interp.4th src/interp/cross.4th src/bin/scantool.4th~. )

( todo rename to scantool )
( todo sorting of stats, getopt options for outputs  )
( todo todo and fixme stats )
( todo stats formatting: column sizes, html? )
( todo html css cmd line arguments )
( todo output assoc list for construction )
( todo stats assoc on structs )
( todo interp powered )

tmp" alias" defined?/2 [UNLESS] load-core [THEN]
s[ src/lib/getopt.4th
   src/lib/scantool/scantool.4th
] load-list

0 var> verbosity
0 var> start-interp
0 var> files-to-scan
0 var> cfg-file
0 var> recurse-files
true var> with-file-heading
0 var> scantool-mode

" him:c:vrf" string-const> OPTS

def process-opts
  arg0 CASE
    s" h" WHEN-STR false 2 return1-n ;;
    s" i" WHEN-STR true start-interp ! ;;
    s" v" WHEN-STR verbosity @ 1 + verbosity ! ;;
    s" r" WHEN-STR true recurse-files ! ;;
    s" c" WHEN-STR arg1 cfg-file ! ;;
    s" f" WHEN-STR false with-file-heading ! ;;
    s" m" WHEN-STR arg1 scantool-mode ! ;;
    s" *" WHEN-STR arg1 files-to-scan push-onto true exit-frame ;;
    drop false 2 return1-n
  ESAC  
end

def usage
  s" Usage: " write-string/2 0 get-argv write-string
  s"  [-" write-string/2 OPTS write-string s" ] -m mode [files...]" write-string/2 nl nl
  s"        -h  Print this." write-line/2
  s"        -r  Scan files loaded by scanned files." write-line/2
  s"        -f  Skip writing the text/enriched header.." write-line/2
  s"        -i  Start an interpreter before scanning." write-line/2
  s"        -v  Be verbose and print out debug messages." write-line/2
  s"   -c path  Load a North script to configure scanning." write-line/2
  s"   -m name  Use the named mode: enriched, html, deps, flat-deps, stats" write-line/2
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

def main
  0 0
  SCANTOOL-DEFAULT-OUTPUT scantool-mode !
  ' process-opts OPTS getopt UNLESS usage 1 return1 THEN

  verbosity @ IF
    s" Inputs: " error-string/2
    files-to-scan @ dup IF enl ' error-line map-car ELSE drop s" stdin" error-line/2 THEN
    s" Recursive: " error-string/2 recurse-files @ error-bool enl
    s" Output format: " error-string/2 scantool-mode @ dup UNLESS " enriched" THEN error-string enl
    s" With header: " error-string/2 with-file-heading @ error-bool enl
    s" Verbosity: " error-string/2 verbosity @ error-int enl
    s" Config file: " error-string/2 cfg-file @ error-string enl
    s" Start Interpreter: " error-string/2 start-interp @ error-bool enl
  THEN

  ( Initialize everything: )
  north-stacks-init!
  scantool-mode @ make-scantool-output set-local0

  cfg-file @ IF cfg-file @ load THEN
  start-interp @ IF interp-init interp THEN

  ( Start of writing: )
  with-file-heading @ IF local0 scantool-output-heading THEN

  ( Allocate space for the readers: )
  token-buffer-max stack-allot set-local1

  ( Start scanning... )
  files-to-scan @ IF
    ( ...files listed on the command line )
    local1 token-buffer-max local0 files-to-scan @
    recurse-files @
    IF 0 verbosity @ recursive-scantool ELSE scantool-file-list THEN
  ELSE
    ( ...standard input )
    local1 token-buffer-max make-stdin-reader local0 scantool/2
    ( ...and any files loaded )
    recurse-files @ IF
      scantool-state-seen-files @
      local1 token-buffer-max local0 4 overn 0 verbosity @ recursive-scantool
    THEN
  THEN

  ( finish writing )
  with-file-heading @ IF local0 scantool-output-footing THEN

  0 return1
end
