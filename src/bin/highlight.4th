( Can built with:
    ~bin/builder.android.3.elf -o bin/highlight src/include/interp.4th src/interp/cross.4th src/bin/highlight.4th~. )

tmp" alias" defined?/2 [UNLESS] load-core [THEN]
" src/lib/getopt.4th" load
" src/lib/scanners/highlight.4th" load

0 var> verbosity
0 var> start-interp
0 var> files-to-highlight
0 var> cfg-file
0 var> recurse-files
true var> with-file-heading

" hic:vrm" string-const> OPTS

def process-opts
  arg0 CASE
    s" h" WHEN-STR false 2 return1-n ;;
    s" i" WHEN-STR true start-interp ! ;;
    s" v" WHEN-STR verbosity @ 1 + verbosity ! ;;
    s" r" WHEN-STR true recurse-files ! ;;
    s" c" WHEN-STR arg1 cfg-file ! ;;
    s" m" WHEN-STR false with-file-heading ! ;;
    s" *" WHEN-STR arg1 files-to-highlight push-onto true exit-frame ;;
    drop false 2 return1-n
  ESAC  
end

def usage
  s" Usage: " write-string/2 0 get-argv write-string
  s"  [-" write-string/2 OPTS write-string s" ] [files...]" write-string/2 nl nl
  s"        -h  Print this." write-line/2
  s"        -r  Highlight files loaded by processed files." write-line/2
  s"        -m  Skip writing the text/enriched header.." write-line/2
  s"        -i  Start an interpreter before highlighting." write-line/2
  s"        -v  Be verbose and print out debug messages." write-line/2
  s"   -c path  Load a North script to configure highlighting." write-line/2
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
  ' process-opts OPTS getopt UNLESS usage 1 return1 THEN

  north-stacks-init!
  recurse-files @ highlight-init

  start-interp @ IF interp-init interp THEN
  cfg-file @ IF cfg-file @ load THEN

  with-file-heading @ IF
    s" Content-Type: text/enriched" write-line/2
    s" Text-Width: 70" write-line/2
    nl
  THEN
  
  files-to-highlight @ dup IF
    0 ' highlight-file revmap-cons/3
  ELSE
    token-buffer-max stack-allot
    token-buffer-max make-stdin-reader highlight
  THEN

  0 return1
end
