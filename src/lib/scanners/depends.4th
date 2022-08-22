1536 var> depends-max-token-size

def depends-state-buffer arg0 cell-size 4 * + set-arg0 end
def depends-state-size arg0 cell-size 3 * + set-arg0 end
def depends-state-reader arg0 cell-size 2 * + set-arg0 end
def depends-state-length arg0 cell-size 1 * + set-arg0 end
def depends-state-token-list arg0 cell-size 0 * + set-arg0 end

defcol make-depends-state ( buffer size reader ++ state )
  0 swap
  0 swap
  here cell-size + swap
endcol

def comment-done
  arg0 41 equals? set-arg0
end

def comment
  0
  depends-max-token-size @ stack-allot set-local0
  local0
  depends-max-token-size @
  ' comment-done arg0 depends-state-reader @ reader-read-until
  3 dropn
  local0 depends-max-token-size @
  arg0 depends-state-reader @
  reader-next-token 3 dropn
  3 return0-n
end

def string-done
  arg0 34 equals? set-arg0
end

def string
  0
  arg0 depends-state-buffer @ arg0 depends-state-size @
  ' string-done arg0 depends-state-reader @ reader-read-until drop
  dup arg0 depends-state-length !
  2dup null-terminate
  16 stack-allot 16
  arg0 depends-state-reader @
  reader-next-token 3 dropn
  3 return0-n
end  

def token-list-loop ( buffer size state cons -- cons )
  arg2 cell-size 3 * int< IF
    s" Warning: token list too large." error-line/2
    arg0 4 return1-n
  THEN
  arg3 arg2 arg1 depends-state-reader @ reader-next-token
  0 int<= IF arg0 4 return1-n THEN
  2dup null-terminate
  over s" ]" string-equals?/3 IF arg0 4 return1-n ELSE 3 dropn THEN
  over s" (" string-equals?/3 IF 3 dropn arg1 comment repeat-frame ELSE 3 dropn THEN
  over s" )" string-equals?/3 IF 5 dropn repeat-frame ELSE 3 dropn THEN
  ( create a cons pointing to the string and last cons
    after the read string in the buffer )
  arg3 over + 1 +
  arg3 over !
  arg0 over cell-size + !
  dup set-arg0
  dup cell-size 3 * + set-arg3
  arg2 3 overn - cell-size 3 * - set-arg2
  3 dropn repeat-frame
end

def token-list
  arg0 depends-state-buffer @
  arg0 depends-state-size @
  arg0
  0 token-list-loop
  dup arg0 depends-state-token-list !
  3 return0-n
end

def keyword-token-next
  depends-max-token-size @ stack-allot depends-max-token-size @
  arg0 depends-state-reader @ reader-next-token
  3 return0-n
end

def keyword-token
  arg2 arg1 arg0 keyword-token-next
  3 return0-n
end

def keyword-token2
  arg2 arg1 arg0 keyword-token-next
  arg2 arg1 arg0 keyword-token-next
  3 return0-n
end

def any
  3 return0-n
end

0
' comment copy-as> ( ( bad emacs )
' keyword-token copy-as> var>
' keyword-token copy-as> const>
' keyword-token copy-as> defvar>
' keyword-token copy-as> defconst>
' keyword-token copy-as> string-const>
' keyword-token copy-as> symbol>
' keyword-token copy-as> copy-as>
' keyword-token2 copy-as> alias>
' keyword-token copy-as> POSTPONE
' keyword-token copy-as> '
' keyword-token copy-as> out'
' keyword-token copy-as> out-off'
' keyword-token copy-as> literal
' keyword-token copy-as> pointer
' keyword-token copy-as> def
' keyword-token copy-as> defcol
' keyword-token copy-as> :
' keyword-token copy-as> defop
' keyword-token copy-as> immediate-as
' token-list copy-as> s[
' token-list copy-as> w[
' string copy-as> s"
' string copy-as> c"
' string copy-as> e"
' string copy-as> d"
' string copy-as> "
' string copy-as> tmp"
var> depends-dict

def depends-lookup ( str len -- fn )
  arg1 arg0 depends-dict @ cs dict-lookup/4 UNLESS ' any THEN 2 return1-n
end

def depends/3 ( buffer len state -- )
  arg2 arg1 arg0 depends-state-reader @ reader-next-token
  negative? IF 3 return0-n ELSE drop THEN
  2dup depends-lookup dup IF
    arg0 swap exec-abs
    repeat-frame
  THEN
end

def depends ( reader -- )
  0
  depends-max-token-size @ stack-allot
  depends-max-token-size @
  arg0 make-depends-state set-local0
  depends-max-token-size @ stack-allot
  depends-max-token-size @
  local0 depends/3 1 return0-n
end

def depends-str
  arg1 arg0 make-string-reader depends 2 return0-n
end

def depends-file
  0
  arg0 open-input-file negative? IF
    s" Failed to open: " error-string/2
    arg0 error-string espace
    error-int enl
    1 return0-n
  ELSE set-local0
  THEN
  arg0 write-line
  depends-max-token-size @ stack-allot depends-max-token-size @ local0 make-fd-reader
  dup depends
  fd-reader-close
  1 return0-n
end

def depends-stdin
  the-reader @ depends
end

def depends-load
  arg0 depends-state-length @ 1 int> IF 
    arg0 depends-state-buffer @ 1 + depends-file
  THEN 3 return0-n
end

def depends-load-list
  arg0 depends-state-token-list @ dup IF
    0 ' depends-file revmap-cons/3
  THEN
  3 return0-n
end

depends-dict @
' depends-load copy-as> load
' depends-load copy-as> load/2
' depends-load-list copy-as> load-list
depends-dict !
