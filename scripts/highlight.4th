def print-token-buffer
  token-buffer peek token-buffer-length peek write-string/2
end

def highlight-token-buffer ( style-class len )
  s" <span class='" write-string/2
  arg1 arg0 write-string/2
  s" '>" write-string/2
  print-token-buffer
  s" </span>" write-string/2
end

def highlight-number
  s" number" highlight-token-buffer
end

def highlight-immed
  s" immed" highlight-token-buffer
end

def highlight-defining
  s" defining" highlight-token-buffer
end

def highlight-name
  s" name" highlight-token-buffer
end

def highlight-def
  highlight-defining space
  next-token highlight-name
end

def highlight-end
  s" end-defining" highlight-token-buffer
end

def highlight-def-block
  s" <div class='block'>" write-string/2
  highlight-def
end

def highlight-end-block
  s" end-defining" highlight-token-buffer
end

def highlight-literal
  s" type" highlight-token-buffer
  next-token highlight-name
end

def highlight-comment
  token-buffer peek token-buffer-max 41 read-until-char drop
  dup IF
    s" <span class='comment'>(" write-string/2
    write-string/2
    s" )</span>" write-string/2
  THEN
end

def highlight-string
  POSTPONE tmp"
  s" <span class='string'>" write-string/2
  34 write-byte space
  write-string/2
  34 write-byte
  s" </span>" write-string/2
end

def print-header
  s" <html><body><pre>" write-string/2
end

def print-footer
  s" </pre></body></html>" write-string/2
end

0
' highlight-string copy-as> "
' highlight-comment copy-as> (
' nop copy-as> )
' highlight-immed copy-as> IF
' highlight-immed copy-as> UNLESS
' highlight-immed copy-as> ELSE
' highlight-immed copy-as> THEN
' highlight-immed copy-as> begin-frame
' highlight-immed copy-as> exit-frame
' highlight-immed copy-as> repeat-frame
' highlight-def-block copy-as> def
' highlight-end-block copy-as> end
' highlight-def-block copy-as> defcol
' highlight-end-block copy-as> endcol
' highlight-def-block copy-as> :
' highlight-end-block copy-as> ;
' highlight-def copy-as> var>
' highlight-def copy-as> const>
' highlight-def copy-as> string-const>
' highlight-def copy-as> alias>
' highlight-literal copy-as> literal
' highlight-literal copy-as> int32
' highlight-literal copy-as> offset32
' highlight-literal copy-as> pointer
' highlight-literal copy-as> '
var> highlight-dict

def hwords
  highlight-dict peek ' words-printer dict-map
end
  
def highlight-lookup
  arg1 arg0 parse-int
  IF set-arg1 0 set-arg0
  ELSE
    arg1 arg0 highlight-dict peek dict-lookup
    IF set-arg1 1 set-arg0
    ELSE -1 set-arg0
    THEN
  THEN
end

def highlight-loop
  next-token negative? IF return0 THEN
  highlight-lookup
  negative? IF print-token-buffer
  ELSE IF exec ELSE highlight-number THEN
  THEN space
  drop-locals repeat-frame
end

def highlight
  print-header highlight-loop print-footer
end

( todo how to run? as an elf, a loaded script, and/or binary image? )
( todo auto-formatting or whitespace )
( todo more words. defining words that need a token. literals. )
( todo interp with another dictionary. )
( todo color entry field, or dictionary builder )