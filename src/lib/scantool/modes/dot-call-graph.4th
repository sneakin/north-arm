( Generates a det graph of what each word calls.
  Nodes are definitions or file top levels.
  Edges are calls. )

( Output data state to store stats: )

def dot-call-graph-state-file-stack arg0 cell-size 0 * + set-arg0 end
def dot-call-graph-state-current-def arg0 cell-size 1 * + set-arg0 end
def dot-call-graph-state-current-def-size arg0 cell-size 2 * + set-arg0 end

def make-dot-call-graph-state
  cell-size 3 * stack-allot-zero
  exit-frame
end

( Stats Report: )

def dot-call-graph-scantool-heading
  s" digraph {" write-line/2
  tab s" graph [overlap=false,splines=true,outputorder=edgesfirst];" write-line/2
  tab s" node [color=black,bgcolor=white];" write-line/2
end

def dot-call-graph-scantool-footing
  s" }" write-line/2
end

( Output handlers: )

def dot-call-graph-file-heading ( str output -- )
  tab s" subgraph {" write-line/2
  arg1 arg0 scantool-output-data @ dot-call-graph-state-file-stack push-onto
  exit-frame
end

def dot-call-graph-file-footing ( output ++ )
  arg0 scantool-output-data @ dot-call-graph-state-file-stack pop-from
  tab s" }" write-line/2
  1 return0-n
end

def dot-call-graph-load-error ( err-code path state -- )
  3 return0-n
end


( Word handlers: )

def write-quoted-string/2
  char-code " write-byte
  arg1 arg0 write-escaped-string/2
  char-code " write-byte
  2 return0-n
end

def dot-call-graph-any
  arg0 scantool-state-output @ scantool-output-data @
  local0 dot-call-graph-state-current-def @ IF
    local0 dot-call-graph-state-current-def @
    local0 dot-call-graph-state-current-def-size @
  ELSE
    local0 dot-call-graph-state-file-stack @
    dup IF car dup string-length
	ELSE drop s" <top-level>"
	THEN
  THEN
  tab tab s" edge [color=blue];" write-line/2
  tab tab write-quoted-string/2
  s"  -> " write-string/2
  arg2 arg1 write-quoted-string/2
  s" ;" write-line/2
  3 return0-n
end

def dot-call-graph-comment
  0 ' comment-done arg0 scantool-terminated-text
  3 return0-n
end

def dot-call-graph-string
  arg0 scantool-string 3 return0-n
end  

def dot-call-graph-token-list
  arg0 scantool-token-list 3 return0-n
end

def dot-call-graph-scantool-load
  ' scantool-load tail-0
end

def dot-call-graph-scantool-load-list
  ' scantool-load-list tail-0
end

def dot-call-graph-keyword-token
  scantool-max-token-size @ stack-allot scantool-max-token-size @
  2dup arg0 scantool-state-reader @ reader-next-token
  3 return0-n
end

def dot-call-graph-keyword-token2
  scantool-max-token-size @ stack-allot scantool-max-token-size @
  2dup arg0 scantool-state-reader @ reader-next-token
  3 dropn
  arg0 scantool-state-reader @ reader-next-token
  3 return0-n
end

( todo read into a dedicated buffer for the current word )
def dot-call-graph-keyword-def
  arg0 scantool-state-output @ scantool-output-data @
  scantool-max-token-size @ stack-allot scantool-max-token-size @
  2dup arg0 scantool-state-reader @ reader-next-token
  negative? IF
    s" Early EOF" error-line/2
    0 local0 dot-call-graph-state-current-def-size !
    0 local0 dot-call-graph-state-current-def !
    3 return0-n
  ELSE
    drop
    tab tab s" edge [color=red];" write-line/2
    tab tab local0 dot-call-graph-state-file-stack @ car dup string-length write-quoted-string/2
    s"  -> " write-string/2
    2dup write-quoted-string/2
    s" ;" write-line/2
    local0 dot-call-graph-state-current-def-size !
    local0 dot-call-graph-state-current-def !
    exit-frame
  THEN
end

def dot-call-graph-keyword-end
  arg0 scantool-state-output @ scantool-output-data @
  0 local0 dot-call-graph-state-current-def !
  0 local0 dot-call-graph-state-current-def-size !
  3 return0-n
end

def dot-call-graph-keyword-var
  arg2 arg1 arg0 dot-call-graph-keyword-token
  3 return0-n
end

def dot-call-graph-keyword-const
  arg2 arg1 arg0 dot-call-graph-keyword-token
  3 return0-n
end

( Stats dictionary: )

0
' dot-call-graph-scantool-load copies-entry-as> load
' dot-call-graph-scantool-load copies-entry-as> load/2
' dot-call-graph-scantool-load-list copies-entry-as> load-list
' dot-call-graph-keyword-def copies-entry-as> def
' dot-call-graph-keyword-def copies-entry-as> defcol
' dot-call-graph-keyword-def copies-entry-as> :
' dot-call-graph-keyword-def copies-entry-as> defop
' dot-call-graph-keyword-end copies-entry-as> end
' dot-call-graph-keyword-end copies-entry-as> endcol
' dot-call-graph-keyword-end copies-entry-as> ;
' dot-call-graph-keyword-end copies-entry-as> endop
' dot-call-graph-keyword-var copies-entry-as> var>
' dot-call-graph-keyword-var copies-entry-as> defvar>
' dot-call-graph-keyword-const copies-entry-as> const>
' dot-call-graph-keyword-const copies-entry-as> const-offset>
' dot-call-graph-keyword-const copies-entry-as> defconst>
' dot-call-graph-keyword-const copies-entry-as> defconst-offset>
' dot-call-graph-keyword-token copies-entry-as> out-immediate-as
' dot-call-graph-keyword-token copies-entry-as> cross-immediate-as
' dot-call-graph-keyword-token copies-entry-as> immediate-as
' dot-call-graph-keyword-token2 copies-entry-as> alias>
' dot-call-graph-keyword-token copies-entry-as> copy-as>
' dot-call-graph-keyword-token copies-entry-as> copies-entry-as>
' dot-call-graph-keyword-token copies-entry-as> create>
' dot-call-graph-keyword-token copies-entry-as> '
' dot-call-graph-token-list copies-entry-as> s[
' dot-call-graph-token-list copies-entry-as> w[
' dot-call-graph-string copies-entry-as> s"
' dot-call-graph-string copies-entry-as> c"
' dot-call-graph-string copies-entry-as> e"
' dot-call-graph-string copies-entry-as> d"
' dot-call-graph-string copies-entry-as> "
' dot-call-graph-string copies-entry-as> tmp"
' dot-call-graph-comment copies-entry-as> ( ( bad emacs )
to-out-addr const> scantool-dot-call-graph-dict

def dot-call-graph-scantool
  make-dot-call-graph-state
  ' dot-call-graph-comment
  ' dot-call-graph-load-error
  ' dot-call-graph-file-footing
  ' dot-call-graph-file-heading
  ' dot-call-graph-scantool-footing
  ' dot-call-graph-scantool-heading
  ' dot-call-graph-any
  scantool-dot-call-graph-dict cs +
  here exit-frame
end
