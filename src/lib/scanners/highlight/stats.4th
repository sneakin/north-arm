( Por definition stats: )

def stats-per-def-caller-count arg0 cell-size 2 * + set-arg0 end
def stats-per-def-word-count arg0 cell-size 1 * + set-arg0 end
def stats-per-def-name arg0 cell-size 0 * + set-arg0 end

def make-stats-per-def ( name ++ stats-per-def )
  0 arg0 allot-byte-string drop set-local0
  cell-size 3 * stack-allot-zero
  local0 over stats-per-def-name !
  exit-frame
end

( Per file stats: )

def stats-per-file-load-count arg0 cell-size 4 * + set-arg0 end
def stats-per-file-def-count arg0 cell-size 3 * + set-arg0 end
def stats-per-file-var-count arg0 cell-size 2 * + set-arg0 end
def stats-per-file-const-count arg0 cell-size 1 * + set-arg0 end
def stats-per-file-name arg0 cell-size 0 * + set-arg0 end

def make-stats-per-file ( name ++ stats-per-file )
  cell-size 5 * stack-allot-zero
  arg1 over stats-per-file-name !
  exit-frame
end

( Output data state to store stats: )

def stats-collector-per-def arg0 cell-size 0 * + set-arg0 end
def stats-collector-file-count arg0 cell-size 1 * + set-arg0 end
def stats-collector-defs-total arg0 cell-size 2 * + set-arg0 end
def stats-collector-per-file arg0 cell-size 3 * + set-arg0 end
def stats-collector-current-file arg0 cell-size 4 * + set-arg0 end
def stats-collector-current-def arg0 cell-size 5 * + set-arg0 end

def make-stats-collector
  cell-size 6 * stack-allot-zero exit-frame
end

def stats-collector-for-def ( word collector ++ stats-per-file )
  arg1 arg0 stats-collector-per-def @ assoc-string
  dup IF cdr 2 return1-n
      ELSE arg1 make-stats-per-def dup stats-per-def-name @ cons
	   arg0 stats-collector-per-def push-onto
	   car cdr exit-frame
      THEN
end

def inc-stats-collector-words-per-def!
  arg1 arg0 stats-collector-for-def
  stats-per-def-word-count inc!
  exit-frame
end

def inc-stats-collector-callers-per-def!
  arg1 arg0 stats-collector-for-def
  stats-per-def-caller-count inc!
  exit-frame
end

def stats-collector-for-file ( path collector ++ stats-per-file )
  arg1 arg0 stats-collector-per-file @ assoc-string
  dup IF cdr 2 return1-n
      ELSE arg1 make-stats-per-file arg1 cons
	   arg0 stats-collector-per-file push-onto
	   car cdr exit-frame
      THEN
end

def inc-stats-collector-defs-per-file!
  arg1 arg0 stats-collector-for-file
  stats-per-file-def-count inc!
  exit-frame
end

def inc-stats-collector-vars-per-file!
  arg1 arg0 stats-collector-for-file
  stats-per-file-var-count inc!
  exit-frame
end

def inc-stats-collector-constants-per-file!
  arg1 arg0 stats-collector-for-file
  stats-per-file-const-count inc!
  exit-frame
end

def inc-stats-collector-current-load-count!/2 ( stats-collector amount ++ valuo )
  arg1 stats-collector-current-file @ arg1 stats-collector-for-file
  stats-per-file-load-count arg0 inc!/2
  exit-frame
end

def inc-stats-collector-current-load-count!
  1 ' inc-stats-collector-current-load-count!/2 tail+1
end

( Stats Report: )

def stats-highlight-heading
  s" Stats" write-line/2
  nl
  s" Files" write-line/2
  nl
  s" File	# defs	# vars	# consts	# loads" write-line/2
end

def write-stats-per-def
  arg0 car write-string tab
  arg0 cdr stats-per-def-word-count @ write-int tab
  arg0 cdr stats-per-def-caller-count @ write-int tab
  nl
end

def write-stats-per-file/2 ( stats-per-file name -- )
  arg0 write-string tab
  arg1 stats-per-file-def-count @ write-int tab
  arg1 stats-per-file-var-count @ write-int tab
  arg1 stats-per-file-const-count @ write-int tab
  arg1 stats-per-file-load-count @ write-int tab
  nl
  2 return0-n
end

def write-stats-per-file
  arg0 car arg0 cdr set-arg0 ' write-stats-per-file/2 tail+1
end

def stats-highlight-footing
  nl
  s" Definitions" write-line/2
  nl
  s" Word	# words	# callers" write-line/2
  arg0 highlight-output-data @ stats-collector-per-def @ ' write-stats-per-def map-car
  nl
  nl
  s" Summary" write-line/2
  nl
  s"   # Files: " write-string/2
  arg0 highlight-output-data @ stats-collector-file-count @ write-int nl
  s"   # Defs: " write-string/2
  arg0 highlight-output-data @ stats-collector-defs-total @ write-int nl
end

( Output handlers: )

def stats-file-heading ( str output -- )
  arg0 highlight-output-data @ stats-collector-file-count inc!
  arg1 arg0 highlight-output-data @ stats-collector-current-file !
  2 return0-n
end

def stats-file-footing
  arg0 highlight-output-data @
  local0 stats-collector-current-file @
  local1 local0 stats-collector-for-file local1 write-stats-per-file/2
  0 local0 stats-collector-current-file !
  exit-frame
end

def stats-load-error ( err-code path state -- )
  3 return0-n
end


( Word handlers: )

def stats-any
  arg0 highlight-state-output @ highlight-output-data @
  dup stats-collector-current-def @ dup IF
    local0 inc-stats-collector-words-per-def!
  ELSE drop
  THEN
  arg2 local0 inc-stats-collector-callers-per-def!
  exit-frame
end

def stats-terminated-text ( buffer size done-fn state -- )
  arg3 arg2 arg1 arg0 highlight-state-reader @ reader-read-until
  shift 2 dropn
  0 equals? IF repeat-frame THEN
  arg3 arg2 arg0 highlight-state-reader @ reader-next-token drop 2 dropn
  4 return0-n
end

def stats-comment
  0 ' comment-done arg0 highlight-terminated-text
  3 return0-n
end

def stats-string
  arg0 highlight-string 3 return0-n
end  

def stats-token-list
  arg0 highlight-token-list 3 return0-n
end

def stats-highlight-load
  ( arg2 arg1 arg0 highlight-load exit-frame )
  arg0 highlight-state-last-word @ ' stats-string dict-entry-equiv? IF
    arg0 highlight-state-output @ highlight-output-data @ inc-stats-collector-current-load-count!
    ' highlight-load tail-0
  ELSE
    3 return0-n
  THEN
end

def stats-highlight-load-list
  arg0 highlight-state-last-word @ ' stats-token-list dict-entry-equiv? IF
    arg0 highlight-state-output @ highlight-output-data @
    arg0 highlight-state-token-list @ cons-count
    inc-stats-collector-current-load-count!/2
    ' highlight-load-list tail-0
  ELSE
    3 return0-n
  THEN
end

def stats-keyword-token
  arg0 highlight-state-last-token @ arg0 highlight-state-last-size @
  arg0 highlight-state-reader @ reader-next-token
  drop arg0 highlight-state-last-length !
  3 return0-n
end

def stats-keyword-token2
  highlight-max-token-size @ stack-allot highlight-max-token-size @
  2dup arg0 highlight-state-reader @ reader-next-token
  3 dropn
  arg0 highlight-state-reader @ reader-next-token
  3 return0-n
end

def stats-keyword-def
  arg2 arg1 arg0 stats-keyword-token
  arg0 highlight-allot-last
  over arg0 highlight-state-output @ highlight-output-data @ stats-collector-current-def !
  arg0 highlight-state-output @ highlight-output-data @ stats-collector-defs-total inc!
  arg0 highlight-state-output @ highlight-output-data @ stats-collector-current-file @
  arg0 highlight-state-output @ highlight-output-data @ inc-stats-collector-defs-per-file!
  exit-frame
end

def stats-keyword-end
  0 arg0 highlight-state-output @ highlight-output-data @ stats-collector-current-def !
  3 return0-n
end

def stats-keyword-var
  arg2 arg1 arg0 stats-keyword-token
  arg0 highlight-allot-last
  arg0 highlight-state-output @ highlight-output-data @ stats-collector-current-file @
  arg0 highlight-state-output @ highlight-output-data @ inc-stats-collector-vars-per-file!
  exit-frame
end

def stats-keyword-const
  arg2 arg1 arg0 stats-keyword-token
  arg0 highlight-allot-last
  arg0 highlight-state-output @ highlight-output-data @ stats-collector-current-file @
  arg0 highlight-state-output @ highlight-output-data @ inc-stats-collector-constants-per-file!
  exit-frame
end

( Highlight Output: )

0
' stats-highlight-load copies-entry-as> load
' stats-highlight-load copies-entry-as> load/2
' stats-highlight-load-list copies-entry-as> load-list
' stats-keyword-def copies-entry-as> def
' stats-keyword-def copies-entry-as> defcol
' stats-keyword-def copies-entry-as> :
' stats-keyword-def copies-entry-as> defop
' stats-keyword-end copies-entry-as> end
' stats-keyword-end copies-entry-as> endcol
' stats-keyword-end copies-entry-as> ;
' stats-keyword-end copies-entry-as> endop
' stats-keyword-var copies-entry-as> var>
' stats-keyword-var copies-entry-as> defvar>
' stats-keyword-const copies-entry-as> const>
' stats-keyword-const copies-entry-as> defconst>
' stats-keyword-token copies-entry-as> out-immediate-as
' stats-keyword-token copies-entry-as> immediate-as
' stats-keyword-token2 copies-entry-as> alias>
' stats-keyword-token copies-entry-as> copy-as>
' stats-keyword-token copies-entry-as> copies-entry-as>
' stats-keyword-token copies-entry-as> create>
' stats-keyword-token copies-entry-as> '
' stats-token-list copies-entry-as> s[
' stats-token-list copies-entry-as> w[
' stats-string copies-entry-as> s"
' stats-string copies-entry-as> c"
' stats-string copies-entry-as> e"
' stats-string copies-entry-as> d"
' stats-string copies-entry-as> "
' stats-string copies-entry-as> tmp"
' stats-comment copies-entry-as> ( ( bad emacs )
to-out-addr const> highlight-stats-dict

def stats-highlighter
  make-stats-collector
  ' stats-comment
  ' stats-load-error
  ' stats-file-footing
  ' stats-file-heading
  ' stats-highlight-footing
  ' stats-highlight-heading
  ' stats-any
  highlight-stats-dict cs +
  here exit-frame
end
