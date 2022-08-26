def deps-highlight-heading
end

def deps-highlight-footing
end

def deps-any
(
  0 arg0 highlight-state-last-token @ !
  0 arg0 highlight-state-last-length !
)
  3 return0-n
end

def deps-file-heading ( str -- )
  arg0 write-string
  s" :" write-string/2
  1 return0-n
end

def deps-file-footing
  nl
end

def deps-terminated-text ( buffer size done-fn state -- )
  arg3 arg2 arg1 arg0 highlight-state-reader @ reader-read-until
  shift 2 dropn
  0 equals? IF repeat-frame THEN
  arg3 arg2 arg0 highlight-state-reader @ reader-next-token drop 2 dropn
  4 return0-n
end

def deps-comment
  0
  highlight-max-token-size @ stack-allot set-local0
  local0
  highlight-max-token-size @
  ' comment-done arg0 deps-terminated-text
  3 return0-n
end

def deps-string
  0
  arg0 highlight-state-last-token @ arg0 highlight-state-last-size @
  ' string-done arg0 highlight-state-reader @ reader-read-until drop
  dup arg0 highlight-state-last-length !
  2dup null-terminate
  2 dropn
  16 stack-allot 16
  arg0 highlight-state-reader @
  reader-next-token drop 2 dropn
  3 return0-n
end  

def deps-token-list-loop ( buffer size state cons -- cons )
  arg2 cell-size 3 * int< IF
    s" Warning: token list too large." error-line/2
    arg0 4 return1-n
  THEN
  arg3 arg2 arg1 highlight-state-reader @ reader-next-token
  0 int<= IF arg0 4 return1-n THEN
  2dup null-terminate
  over s" ]" string-equals?/3 IF arg0 4 return1-n ELSE 3 dropn THEN
  over s" (" string-equals?/3 IF 3 dropn arg1 deps-comment repeat-frame ELSE 3 dropn THEN
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

def deps-token-list
  arg0 highlight-state-last-token @
  arg0 highlight-state-last-size @
  arg0
  0 deps-token-list-loop
  arg0 highlight-state-token-list !
  3 return0-n
end

def deps-highlight-load
  ( arg2 arg1 arg0 highlight-load exit-frame )
  arg0 highlight-state-last-word @ ' deps-string dict-entry-equiv? IF
    arg0 highlight-state-last-token @
    arg0 highlight-state-last-length @
    dup IF write-string/2 space ELSE 2 dropn THEN
    ' highlight-load tail-0
  ELSE
    3 return0-n
  THEN
end

def deps-highlight-load-list
  arg0 highlight-state-last-word @
  ' deps-token-list dict-entry-equiv? IF
    0 ' space ' write-string compose set-local0
    arg0 highlight-state-token-list @ dup IF 0 local0 revmap-cons/3 THEN
    ( arg2 arg1 arg0 highlight-load-list exit-frame )
    ' highlight-load-list tail-0
  ELSE
    3 return0-n
  THEN
end

def deps-keyword-token
  highlight-max-token-size @ stack-allot highlight-max-token-size @
  arg0 highlight-state-reader @ reader-next-token
  3 return0-n
end

def deps-keyword-token2
  highlight-max-token-size @ stack-allot highlight-max-token-size @
  2dup arg0 highlight-state-reader @ reader-next-token
  3 dropn
  arg0 highlight-state-reader @ reader-next-token
  3 return0-n
end


0
' deps-highlight-load copies-entry-as> load
' deps-highlight-load copies-entry-as> load/2
' deps-highlight-load-list copies-entry-as> load-list
' deps-keyword-token copies-entry-as> def
' deps-keyword-token copies-entry-as> defcol
' deps-keyword-token copies-entry-as> :
' deps-keyword-token copies-entry-as> defop
' deps-keyword-token copies-entry-as> out-immediate-as
' deps-keyword-token copies-entry-as> immediate-as
' deps-keyword-token2 copies-entry-as> alias>
' deps-keyword-token copies-entry-as> copy-as>
' deps-keyword-token copies-entry-as> copies-entry-as>
' deps-keyword-token copies-entry-as> create>
' deps-keyword-token copies-entry-as> '
' deps-token-list copies-entry-as> s[
' deps-token-list copies-entry-as> w[
' deps-string copies-entry-as> s"
' deps-string copies-entry-as> c"
' deps-string copies-entry-as> e"
' deps-string copies-entry-as> d"
' deps-string copies-entry-as> "
' deps-string copies-entry-as> tmp"
' deps-comment copies-entry-as> ( ( bad emacs )
to-out-addr const> highlight-deps-dict

def deps-highlighter
' deps-file-footing
' deps-file-heading
' deps-highlight-footing
' deps-highlight-heading
' deps-any
highlight-deps-dict cs +
here exit-frame
end
