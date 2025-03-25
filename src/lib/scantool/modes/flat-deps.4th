def flat-deps-scantool-heading ( output -- )
  1 return0-n
end

def flat-deps-scantool-footing ( output -- )
  1 return0-n
end

def flat-deps-file-heading ( str output -- )
  arg1 write-string nl
  2 return0-n
end

def flat-deps-file-footing ( output -- )
  1 return0-n
end

def flat-deps-scantool-load
  ( arg2 arg1 arg0 scantool-load exit-frame )
  arg0 scantool-state-last-word @ ' deps-string dict-entry-equiv? IF
    ' scantool-load tail-0
  ELSE
    3 return0-n
  THEN
end

def flat-deps-scantool-load-list
  arg0 scantool-state-last-word @
  ' deps-token-list dict-entry-equiv? IF
    ( arg2 arg1 arg0 scantool-load-list exit-frame )
    ' scantool-load-list tail-0
  ELSE
    3 return0-n
  THEN
end


DEFINED? BUILDER-TARGET IF
  ' scantool-deps-dict dict-entry-data @ from-out-addr
ELSE
  scantool-deps-dict
THEN
' flat-deps-scantool-load copies-entry-as> load
' flat-deps-scantool-load copies-entry-as> load/2
' flat-deps-scantool-load-list copies-entry-as> load-list
to-out-addr const> scantool-flat-deps-dict

def flat-deps-scantool
  ' deps-comment
  ' deps-load-error
  ' flat-deps-file-footing
  ' flat-deps-file-heading
  ' flat-deps-scantool-footing
  ' flat-deps-scantool-heading
  ' deps-any
  scantool-flat-deps-dict cs +
  here exit-frame
end
