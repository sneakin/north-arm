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

def scantool-output-dict end
def scantool-output-any arg0 cell-size + set-arg0 end
def scantool-output-heading-fn arg0 cell-size 2 * + set-arg0 end
def scantool-output-footing-fn arg0 cell-size 3 * + set-arg0 end
def scantool-output-file-heading-fn arg0 cell-size 4 * + set-arg0 end
def scantool-output-file-footing-fn arg0 cell-size 5 * + set-arg0 end
def scantool-output-load-error-fn arg0 cell-size 6 * + set-arg0 end
def scantool-output-comment-fn arg0 cell-size 7 * + set-arg0 end
def scantool-output-data arg0 cell-size 8 * + set-arg0 end

def scantool-output-heading
  arg0 scantool-output-heading-fn @ tail-0
end

def scantool-output-footing
  arg0 scantool-output-footing-fn @ tail-0
end

def scantool-output-file-heading
  arg0 scantool-output-file-heading-fn @ tail-0
end

def scantool-output-file-footing
  arg0 scantool-output-file-footing-fn @ tail-0
end

def scantool-output-load-error
  arg0 scantool-output-load-error-fn @ tail-0
end

def scantool-output-comment
  arg0 scantool-output-comment-fn @ droptail-1
end

( Highligher state: )

1536 var> scantool-max-token-size

def scantool-state-current-token arg0 cell-size 10 * + set-arg0 end
def scantool-state-current-size arg0 cell-size 9 * + set-arg0 end
def scantool-state-current-length arg0 cell-size 8 * + set-arg0 end
def scantool-state-last-token arg0 cell-size 7 * + set-arg0 end
def scantool-state-last-size arg0 cell-size 6 * + set-arg0 end
def scantool-state-last-length arg0 cell-size 5 * + set-arg0 end
def scantool-state-last-word arg0 cell-size 4 * + set-arg0 end
def scantool-state-token-list arg0 cell-size 3 * + set-arg0 end
def scantool-state-seen-files arg0 cell-size 2 * + set-arg0 end
def scantool-state-reader arg0 cell-size 1 * + set-arg0 end
def scantool-state-output arg0 cell-size 0 * + set-arg0 end

def scantool-state-dict arg0 scantool-state-output @ scantool-output-dict set-arg0 end

def allot-scantool-state ( ++ ... state )
  cell-size 11 * stack-allot-zero exit-frame
end

def make-scantool-state ( buffer-size reader output ++ state )
  0 allot-scantool-state set-local0
  arg2 stack-allot-zero local0 scantool-state-current-token !
  arg2 local0 scantool-state-current-size !
  arg2 stack-allot-zero local0 scantool-state-last-token !
  arg2 local0 scantool-state-last-size !
  arg1 local0 scantool-state-reader !
  arg0 local0 scantool-state-output !
  local0 exit-frame
end

def scantool-allot-last
  arg0 scantool-state-last-length @ dup IF
    arg0 scantool-state-last-token @ swap allot-byte-string/2
    exit-frame
  ELSE 0 0 1 return2-n
  THEN
end

( Terminated string readers: )

def comment-done
  arg0 41 equals? set-arg0
end

def string-done
  arg0 34 equals? set-arg0
end

( Reads bytes until ~done-fn~ is true calling ~each-fn~ on each buffer read. )
def scantool-terminated-text ( each-fn done-fn state -- )
  arg0 scantool-state-last-size @ 1 - 0 over stack-allot set-local1
  local1 local0 arg1 arg0 scantool-state-reader @ reader-read-until
  shift 2dup null-terminate
  arg2 dup IF exec-abs ELSE 3 dropn THEN
  0 equals? IF repeat-frame THEN
  local1 local0 arg0 scantool-state-reader @ reader-next-token drop
  arg2 dup IF exec-abs ELSE 3 dropn THEN
  3 return0-n
end

( Reads bytes until ~"~ is read for one buffer or less. )
def scantool-string ( state ++ terminating-token )
  0
  arg0 scantool-state-last-token @ arg0 scantool-state-last-size @
  ' string-done arg0 scantool-state-reader @ reader-read-until drop
  dup arg0 scantool-state-last-length !
  null-terminate
  16 stack-allot 16
  arg0 scantool-state-reader @
  reader-next-token drop exit-frame
end  

( Token list reader: )

( fixme duplicated )
def pad-addr ( addr alignment )
  arg1 arg0 + arg0 / arg0 *
  2 return1-n
end

def scantool-token-list-loop ( buffer size state cons -- cons )
  arg2 cell-size 3 * int< IF
    s" Warning: token list too large." error-line/2
    s" List so far: " error-string/2
    ' error-string ' espace compose arg0 0 roll revmap-cons/3 enl
    arg0 4 return1-n
  THEN
  arg3 arg2 arg1 scantool-state-reader @ reader-next-token
  0 int<= IF arg0 4 return1-n THEN
  2dup null-terminate
  over s" ]" string-equals?/3 IF arg0 4 return1-n ELSE 3 dropn THEN
  over s" (" string-equals?/3 IF
    3 dropn arg1 arg1 scantool-state-output @ scantool-output-comment
    repeat-frame
  ELSE 3 dropn THEN
  over s" )" string-equals?/3 IF 5 dropn repeat-frame ELSE 3 dropn THEN
  ( create a cons pointing to the string and last cons
    after the read string in the buffer )
  arg3 over + 1 + cell-size pad-addr
  arg3 over !
  arg0 over cell-size + !
  dup set-arg0
  dup cell-size 3 * + set-arg3
  arg2 3 overn - cell-size 3 * - set-arg2
  3 dropn repeat-frame
end

def scantool-token-list ( state -- token-list )
  arg0 scantool-state-last-token @ arg0 scantool-state-last-size @
  arg0 0 scantool-token-list-loop
  dup arg0 scantool-state-token-list !
  1 return1-n
end

( Formatter helpers for ~load~ and ~load-list~ )

def scantool-load
  ( copy file name and push onto seen files list)
  ( caller needs to ensure last-token is a string. )
  arg0 scantool-state-last-length @ 1 int> IF
    arg0 scantool-state-last-token @ 1 +
    arg0 scantool-state-last-length @
    arg0 scantool-state-seen-files
    push-copied-string-onto/3
    exit-frame
  THEN 3 return0-n
end

def scantool-load-list
  ( caller needs to ensure last-token and token-list is a cons list of strings. )
  ( todo reset token list more often? )
  arg0 scantool-state-token-list @ dup IF
    arg0 scantool-state-seen-files @
    ' copy-string-onto-list revmap-cons/3
    arg0 scantool-state-seen-files !
    0 arg0 scantool-state-token-list !
    exit-frame
  THEN 3 return0-n
end

( Single stream scantool functions: )

def scantool-lookup ( str len output -- fn )
  arg2 arg1 arg0 scantool-output-dict @ cs dict-lookup/4 UNLESS
    arg0 scantool-output-any @
  THEN 3 return1-n
end

def scantool-inner ( state -- )
  0
  arg0 scantool-state-current-token @
  arg0 scantool-state-current-size @
  arg0 scantool-state-reader @
  reader-next-token negative? IF 3 dropn arg0 exit-frame ELSE drop THEN
  2dup arg0 scantool-state-output @ scantool-lookup dup IF
    dup set-local0
    arg0 swap exec-abs
    local0 arg0 scantool-state-last-word !
    repeat-frame
  THEN
end

def scantool/2 ( reader output ++ )
  scantool-max-token-size @ arg1 arg0 make-scantool-state
  scantool-inner exit-frame
end

def scantool-file/4 ( reader-buffer size path output ++ state ok? || error ok? )
  0 0
  arg1 open-input-file
  negative? IF false 2 return2-n ELSE set-local0 THEN
  arg3 arg2 local0 make-fd-reader set-local1
  local1 arg0 scantool/2
  local1 fd-reader-close
  true exit-frame
end

def scantool-str ( str length output ++ state )
  arg2 arg1 make-string-reader arg0 scantool/2 exit-frame
end

def scantool-stdin ( output ++ state )
  the-reader @ arg0 scantool/2 exit-frame
end


( Output formatters: )

tmp" BUILDER-TARGET" defined?/2 UNLESS
  alias> copies-entry-as> copy-as>
  sys:: to-out-addr cs - ;
THEN
  
s[ src/lib/linux/errno.4th
   src/lib/sort/merge-sort.4th
   src/lib/scantool/modes/common.4th
   src/lib/scantool/modes/enriched.4th
   src/lib/scantool/modes/html.4th
   src/lib/scantool/modes/deps.4th
   src/lib/scantool/modes/flat-deps.4th
   src/lib/scantool/modes/stats.4th
] load-list

" stats" string-const> SCANTOOL-DEFAULT-OUTPUT

def make-scantool-output ( name ++ output )
  arg0 CASE
    s" enriched" OF-STR ' enriched-scantool droptail-1 ENDOF
    s" html" OF-STR ' html-scantool droptail-1 ENDOF
    s" deps" OF-STR ' deps-scantool droptail-1 ENDOF
    s" flat-deps" OF-STR ' flat-deps-scantool droptail-1 ENDOF
    s" stats" OF-STR ' stats-scantool droptail-1 ENDOF
    drop ' enriched-scantool droptail-1
  ENDCASE
end

( Multiple file scanning: )

def scantool-error-opening ( error-code path output -- )
  s" Failed to open: " error-string/2
  arg1 error-string espace
  arg2 error-int
  arg2 errno->string dup IF espace error-string THEN enl
  ' scantool-output-load-error tail-0
end

def scantool-file-list-fn ( reader-buffer size output path ++ output )
  arg0 arg1 scantool-output-file-heading
  arg3 arg2 arg0 arg1 scantool-file/4 UNLESS
    arg0 arg1 scantool-error-opening
  THEN
  arg1 scantool-output-file-footing
  arg1 exit-frame
end

def scantool-file-list ( reader-buffer size output path-list ++ output )
  ' scantool-file-list-fn arg3 3 partial-after arg2 2 partial-after
  arg0 arg1 3 overn revmap-cons/3
  arg1 exit-frame
end

( Recursive scanning: )

def allot-recursive-scantool-state
  cell-size 6 * stack-allot-zero exit-frame
end

def recursive-scantool-state-buffer arg0 cell-size 5 * + set-arg0 end
def recursive-scantool-state-buffer-size
  arg0 cell-size 4 * + set-arg0
end
def recursive-scantool-state-output arg0 cell-size 3 * + set-arg0 end
def recursive-scantool-state-recurser arg0 cell-size 2 * + set-arg0 end
def recursive-scantool-state-seen-paths arg0 cell-size + set-arg0 end
def recursive-scantool-state-verbosity end

def recursive-scantool-seen? ( path state -- yes? )
  arg1 arg0 recursive-scantool-state-seen-paths @
  list-contains-string? 2 return1-n
end

def recursive-scantool-has-seen! ( path state ++ state )
  arg1 arg0 recursive-scantool-state-seen-paths push-onto
  arg0 exit-frame
end

def recursive-scantool-fn ( state path ++ state )
  0
  arg0 arg1 recursive-scantool-seen? IF arg1 2 return1-n THEN
  arg1 recursive-scantool-state-verbosity @ IF
    s" Scanning " error-string/2 arg0 error-string enl
  THEN
  arg0 arg1 recursive-scantool-state-output @ scantool-output-file-heading
  arg0 arg1 recursive-scantool-has-seen!
  arg1 recursive-scantool-state-buffer @
  arg1 recursive-scantool-state-buffer-size @
  arg0
  arg1 recursive-scantool-state-output @
  scantool-file/4 IF
    set-local0
    arg1 recursive-scantool-state-output @ scantool-output-file-footing
    arg1 recursive-scantool-state-recurser @ IF
      local0 scantool-state-seen-files @
      arg1
      arg1 recursive-scantool-state-recurser @
      dup IF exec-abs exit-frame ELSE 3 dropn THEN
    ELSE drop
    THEN
  ELSE
    arg0 arg1 recursive-scantool-state-output @ scantool-error-opening
    arg1 recursive-scantool-state-output @ scantool-output-file-footing
  THEN arg1 exit-frame
end
       
def recursive-scantool/2 ( list state ++ state )
  arg1 arg0 ' recursive-scantool-fn revmap-cons/3 exit-frame
end

def recursive-scantool ( reader-buffer size output list-paths all-paths verbosity ++ recursive-state )
  0 allot-recursive-scantool-state set-local0
  5 argn local0 recursive-scantool-state-buffer !
  4 argn local0 recursive-scantool-state-buffer-size !
  arg3 local0 recursive-scantool-state-output !
  ' recursive-scantool/2 local0 recursive-scantool-state-recurser !
  arg1 local0 recursive-scantool-state-seen-paths !
  arg0 local0 recursive-scantool-state-verbosity !
  arg2 local0 recursive-scantool/2 exit-frame
end
