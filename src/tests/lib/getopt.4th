( cat src/bin/interp.argv.4th | ./bin/interp.android.3.elf -o test-getopt src/tests/lib/getopt.4th -e test-getopt )

tmp" alias" defined?/2 [UNLESS] load-core [THEN]

tmp" defconst>" defined?/2 [IF]
  s[ src/lib/seq.4th
     src/lib/list.4th
     src/interp/strings.4th
     src/interp/messages.4th
     src/interp/output/strings.4th
     src/interp/output/hex.4th
     src/interp/output/dec.4th
     src/interp/linux/program-args.4th
     src/interp/cross.4th
  ] load-list
[THEN]

" src/lib/getopt.4th" load

0 var> x
0 var> y
0 var> z
0 var> files
0 var> flags
0 var> subargs

def test-getopt-process ( value name -- ok? )
  arg0 CASE
    s" h" WHEN-STR false ;;
    s" x" WHEN-STR arg1 x ! true ;;
    s" y" WHEN-STR arg1 y ! true ;;
    s" z" WHEN-STR z @ 1 + z ! true ;;
    s" *" WHEN-STR files @ arg1 cons files ! true exit-frame ;;
    s" ." WHEN-STR flags @ arg1 cons flags ! true exit-frame ;;
    s" -" WHEN-STR arg2 1 + subargs ! false ;;
    drop false
  ESAC 2 return1-n
end

def test-getopt-usage
  s" test-getopt [-h] [-x value] [-y value] [-z] files... [-- more args...]" error-line/2
end

def test-getopt-report-subargs ( argc n )
  arg0 arg1 int< IF
    arg0 get-argv write-line
    arg0 1 + set-arg0 repeat-frame
  ELSE 2 return0-n
  THEN
end

def test-getopt-report
  x @ dup IF s" X: " write-string/2 write-line ELSE drop THEN
  y @ dup IF s" Y: " write-string/2 write-line ELSE drop THEN
  z @ dup IF s" Z: " write-string/2 write-int nl ELSE drop THEN
  s" Files: " write-line/2 
  files @ dup IF ' write-line map-car ELSE drop THEN
  s" Flags: " write-line/2
  flags @ dup IF ' write-line map-car ELSE drop THEN
  s" Sub args: " write-string/2 subargs @ write-int nl
  argc subargs @ test-getopt-report-subargs
end
    
def test-getopt
  ' test-getopt-process " hx:y:z-" getopt
  IF test-getopt-report
  ELSE test-getopt-usage
  THEN
  s" Bye" write-line/2
end
