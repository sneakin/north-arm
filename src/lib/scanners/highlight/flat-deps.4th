def flat-deps-highlight-heading ( output -- )
  1 return0-n
end

def flat-deps-highlight-footing ( output -- )
  1 return0-n
end

def flat-deps-file-heading ( str output -- )
  arg1 write-string nl
  2 return0-n
end

def flat-deps-file-footing ( output -- )
  1 return0-n
end

def flat-deps-highlight-load
  ( arg2 arg1 arg0 highlight-load exit-frame )
  arg0 highlight-state-last-word @ ' deps-string dict-entry-equiv? IF
    ' highlight-load tail-0
  ELSE
    3 return0-n
  THEN
end

def flat-deps-highlight-load-list
  arg0 highlight-state-last-word @
  ' deps-token-list dict-entry-equiv? IF
    ( arg2 arg1 arg0 highlight-load-list exit-frame )
    ' highlight-load-list tail-0
  ELSE
    3 return0-n
  THEN
end


tmp" BUILDER-TARGET" defined?/2 [IF]
  ' highlight-deps-dict dict-entry-data @ from-out-addr
[ELSE]
  highlight-deps-dict
[THEN]
' flat-deps-highlight-load copies-entry-as> load
' flat-deps-highlight-load copies-entry-as> load/2
' flat-deps-highlight-load-list copies-entry-as> load-list
to-out-addr const> highlight-flat-deps-dict

def flat-deps-highlighter
  ' deps-comment
  ' deps-load-error
  ' flat-deps-file-footing
  ' flat-deps-file-heading
  ' flat-deps-highlight-footing
  ' flat-deps-highlight-heading
  ' deps-any
  highlight-flat-deps-dict cs +
  here exit-frame
end
