( List of string helpers: )

def push-copied-string-onto/3 ( string length list ++ new-list )
  arg2 arg1 allot-byte-string/2 drop arg0 push-onto exit-frame
end

def push-copied-string-onto ( string list ++ new-list )
  arg1 allot-byte-string drop arg0 push-onto exit-frame
end

def push-copied-strings-onto ( list dest ++ new-list )
  arg1 UNLESS arg0 exit-frame THEN
  arg1 car arg0 push-copied-string-onto
  arg1 cdr set-arg1 repeat-frame
end

def copy-string-onto-list ( list str ++ cons )
  arg0 allot-byte-string drop arg1 swap cons exit-frame
end

def list-contains-string? ( str list -- cons )
  ' string-equals?/3 arg1 string-length partial-first
  arg1 partial-first
  arg0 over find-first 2 return1-n
end

def highlight-output-dict end
def highlight-output-any arg0 cell-size + set-arg0 end
def highlight-output-heading-fn arg0 cell-size 2 * + set-arg0 end
def highlight-output-footing-fn arg0 cell-size 3 * + set-arg0 end
def highlight-output-file-heading-fn arg0 cell-size 4 * + set-arg0 end
def highlight-output-file-footing-fn arg0 cell-size 5 * + set-arg0 end

def highlight-output-heading
  arg0 highlight-output-heading-fn @ droptail-1
end

def highlight-output-footing
  arg0 highlight-output-footing-fn @ droptail-1
end

def highlight-output-file-heading
  arg0 highlight-output-file-heading-fn @ droptail-1
end

def highlight-output-file-footing
  arg0 highlight-output-file-footing-fn @ droptail-1
end

( Highligher state: )

1536 var> highlight-max-token-size

def highlight-state-current-token arg0 cell-size 10 * + set-arg0 end
def highlight-state-current-size arg0 cell-size 9 * + set-arg0 end
def highlight-state-current-length arg0 cell-size 8 * + set-arg0 end
def highlight-state-last-token arg0 cell-size 7 * + set-arg0 end
def highlight-state-last-size arg0 cell-size 6 * + set-arg0 end
def highlight-state-last-length arg0 cell-size 5 * + set-arg0 end
def highlight-state-last-word arg0 cell-size 4 * + set-arg0 end
def highlight-state-token-list arg0 cell-size 3 * + set-arg0 end
def highlight-state-seen-files arg0 cell-size 2 * + set-arg0 end
def highlight-state-reader arg0 cell-size 1 * + set-arg0 end
def highlight-state-output arg0 cell-size 0 * + set-arg0 end

def highlight-state-dict arg0 highlight-state-output @ highlight-output-dict set-arg0 end

def allot-highlight-state ( ++ ... state )
  cell-size 11 * stack-allot-zero exit-frame
end

def make-highlight-state ( buffer-size reader output ++ state )
  0 allot-highlight-state set-local0
  arg2 stack-allot-zero local0 highlight-state-current-token !
  arg2 local0 highlight-state-current-size !
  arg2 stack-allot-zero local0 highlight-state-last-token !
  arg2 local0 highlight-state-last-size !
  arg1 local0 highlight-state-reader !
  arg0 local0 highlight-state-output !
  local0 exit-frame
end

( Formatter helpers for ~load~ and ~load-list~ )

def highlight-load
  ( copy file name and push onto seen files list)
  ( caller needs to ensure last-token is a string. )
  arg0 highlight-state-last-length @ 1 int> IF
    arg0 highlight-state-last-token @ 1 +
    arg0 highlight-state-last-length @
    arg0 highlight-state-seen-files
    push-copied-string-onto/3
    exit-frame
  THEN 3 return0-n
end

def highlight-load-list
  ( caller needs to ensure last-token and token-list is a cons list of strings. )
  ( todo reset token list more often? )
  arg0 highlight-state-token-list @ dup IF
    arg0 highlight-state-seen-files @
    ' copy-string-onto-list revmap-cons/3
    arg0 highlight-state-seen-files !
    0 arg0 highlight-state-token-list !
    exit-frame
  THEN 3 return0-n
end

( Output formatters: )

tmp" BUILDER-TARGET" defined?/2 [UNLESS]
  alias> copies-entry-as> copy-as>
  : to-out-addr cs - ;
[THEN]
  
s[ src/lib/scanners/highlight/common.4th
   src/lib/scanners/highlight/enriched.4th
   src/lib/scanners/highlight/html.4th
   src/lib/scanners/highlight/deps.4th
] load-list

" enriched" string-const> HIGHLIGHT-DEFAULT-OUTPUT

def make-highlight-output ( name ++ output )
  arg0 CASE
    s" enriched" OF-STR ' enriched-highlighter droptail-1 ENDOF
    s" html" OF-STR ' html-highlighter droptail-1 ENDOF
    s" deps" OF-STR ' deps-highlighter droptail-1 ENDOF
    drop ' enriched-highlighter droptail-1
  ENDCASE
end

( Single stream highlight functions: )

def highlight-lookup ( str len output -- fn )
  arg2 arg1 arg0 highlight-output-dict @ cs dict-lookup/4 UNLESS
    arg0 highlight-output-any @
  THEN 3 return1-n
end

def highlight-inner ( state -- )
  0
  arg0 highlight-state-current-token @
  arg0 highlight-state-current-size @
  arg0 highlight-state-reader @
  reader-next-token negative? IF 3 dropn arg0 exit-frame ELSE drop THEN
  2dup arg0 highlight-state-output @ highlight-lookup dup IF
    dup set-local0
    arg0 swap exec-abs
    local0 arg0 highlight-state-last-word !
    repeat-frame
  THEN
end

def highlight/2 ( reader output ++ )
  highlight-max-token-size @ arg1 arg0 make-highlight-state
  highlight-inner exit-frame
end

def highlight-file/4 ( reader-buffer size path output ++ state ok? || error ok? )
  0 0
  arg1 open-input-file
  negative? IF false 2 return2-n ELSE set-local0 THEN
  arg3 arg2 local0 make-fd-reader set-local1
  local1 arg0 highlight/2
  local1 fd-reader-close
  true exit-frame
end

def highlight-str ( str length output ++ state )
  arg2 arg1 make-string-reader arg0 highlight/2 exit-frame
end

def highlight-stdin ( output ++ state )
  the-reader @ arg0 highlight/2 exit-frame
end

( Multiple file highlighting: )

def file-heading ( path output )
  arg1 arg0 highlight-output-file-heading 2 return0-n
end

def file-footing ( output -- )
  arg1 arg0 highlight-output-file-footing 1 return0-n
end

def write-error-opening ( error-code path -- )
  s" Failed to open: " write-string/2
  arg0 write-string space
  arg1 write-int nl
  2 return0-n
end

def highlight-file-list-fn ( reader-buffer size output path ++ output )
  arg0 arg1 file-heading
  arg3 arg2 arg0 arg1 highlight-file/4 UNLESS
    arg0 write-error-opening
  THEN
  arg1 file-footing
  arg1 exit-frame
end

def highlight-file-list ( reader-buffer size output path-list -- )
  ' highlight-file-list-fn arg3 3 partial-after arg2 2 partial-after
  arg0 arg1 3 overn revmap-cons/3
  4 return0-n
end

( Recursive highlighting: )

def allot-recursive-highlight-state
  cell-size 5 * stack-allot-zero exit-frame
end

def recursive-highlight-state-buffer arg0 cell-size 4 * + set-arg0 end
def recursive-highlight-state-buffer-size
  arg0 cell-size 3 * + set-arg0
end
def recursive-highlight-state-output arg0 cell-size 2 * + set-arg0 end
def recursive-highlight-state-recurser arg0 cell-size + set-arg0 end
def recursive-highlight-state-seen-paths end

def recursive-highlight-seen? ( path state -- yes? )
  arg1 arg0 recursive-highlight-state-seen-paths @
  list-contains-string? 2 return1-n
end

def recursive-highlight-has-seen! ( path state ++ state )
  arg1 arg0 recursive-highlight-state-seen-paths push-onto
  arg0 exit-frame
end

def recursive-highlight-fn ( state path ++ state )
  arg0 arg1 recursive-highlight-seen? IF arg1 2 return1-n THEN
  s" Highlighting " error-string/2 arg0 error-string enl
  arg0 arg1 recursive-highlight-state-output @ file-heading
  arg0 arg1 recursive-highlight-has-seen!
  arg1 recursive-highlight-state-buffer @
  arg1 recursive-highlight-state-buffer-size @
  arg0
  arg1 recursive-highlight-state-output @
  highlight-file/4 IF
    arg1 recursive-highlight-state-output @ file-footing
    arg1 recursive-highlight-state-recurser @ IF
      highlight-state-seen-files @
      arg1
      arg1 recursive-highlight-state-recurser @
      dup IF exec-abs exit-frame ELSE 3 dropn THEN
    ELSE drop
    THEN
  ELSE
    arg0 write-error-opening
    arg1 recursive-highlight-state-output @ file-footing
  THEN arg1 exit-frame
end
       
def recursive-highlight/2 ( list state ++ state )
  arg1 arg0 ' recursive-highlight-fn revmap-cons/3 exit-frame
end

def recursive-highlight ( reader-buffer size output list-paths all-paths ++ recursive-state )
  0 allot-recursive-highlight-state set-local0
  4 argn local0 recursive-highlight-state-buffer !
  arg3 local0 recursive-highlight-state-buffer-size !
  arg2 local0 recursive-highlight-state-output !
  ' recursive-highlight/2 local0 recursive-highlight-state-recurser !
  arg0 local0 recursive-highlight-state-seen-paths !
  arg1 local0 recursive-highlight/2 exit-frame
end
