def deps-scantool-heading ( output -- )
  1 return0-n
end

def deps-scantool-footing ( output -- )
  1 return0-n
end

def deps-any
  3 return0-n
end

def deps-file-heading ( str output -- )
  arg1 write-string
  s" :" write-string/2
  2 return0-n
end

def deps-file-footing ( output -- )
  nl
  1 return0-n
end

def deps-load-error ( err-code path state -- )
  3 return0-n
end

def deps-comment
  0 ' comment-done arg0 scantool-terminated-text 3 return0-n
end

def deps-string
  arg0 scantool-string 3 return0-n
end  

def deps-token-list
  arg0 scantool-token-list 3 return0-n
end

def deps-scantool-load
  ( arg2 arg1 arg0 scantool-load exit-frame )
  arg0 scantool-state-last-word @ ' deps-string dict-entry-equiv? IF
    arg0 scantool-state-last-token @
    arg0 scantool-state-last-length @
    dup IF write-string/2 space ELSE 2 dropn THEN
    ' scantool-load tail-0
  ELSE
    3 return0-n
  THEN
end

def deps-scantool-load-list
  arg0 scantool-state-last-word @
  ' deps-token-list dict-entry-equiv? IF
    0 ' space ' write-string compose set-local0
    arg0 scantool-state-token-list @ dup IF 0 local0 revmap-cons/3 THEN
    ( arg2 arg1 arg0 scantool-load-list exit-frame )
    ' scantool-load-list tail-0
  ELSE
    3 return0-n
  THEN
end

def deps-keyword-token
  scantool-max-token-size @ stack-allot scantool-max-token-size @
  arg0 scantool-state-reader @ reader-next-token
  3 return0-n
end

def deps-keyword-token2
  scantool-max-token-size @ stack-allot scantool-max-token-size @
  2dup arg0 scantool-state-reader @ reader-next-token
  3 dropn
  arg0 scantool-state-reader @ reader-next-token
  3 return0-n
end


0
' deps-scantool-load copies-entry-as> load
' deps-scantool-load copies-entry-as> load/2
' deps-scantool-load-list copies-entry-as> load-list
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
to-out-addr const> scantool-deps-dict

def deps-scantool
  ' deps-comment
  ' deps-load-error
  ' deps-file-footing
  ' deps-file-heading
  ' deps-scantool-footing
  ' deps-scantool-heading
  ' deps-any
  scantool-deps-dict cs +
  here exit-frame
end
