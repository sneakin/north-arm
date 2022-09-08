( Program argument printing: )

def print-argv/1
  arg0 argc int< IF
    arg0 write-int space
    arg0 get-argv write-line
    arg0 1 + set-arg0 repeat-frame
  THEN
end

def print-argv
  0 print-argv/1
end

def print-env/1
  arg0 peek dup IF
    write-string nl
    arg0 cell-size + set-arg0 repeat-frame
  THEN
end

def print-env
  env-addr print-env/1
end

def print-auxvec/1
  arg0 dup peek dup IF
    ( todo print field name; assoc list? )
    dup write-hex-uint tab auxvec->string write-string tab
    cell-size + dup peek dup write-int tab write-hex-uint nl
    cell-size + set-arg0 repeat-frame
  THEN
end

def print-auxvec
  auxvec print-auxvec/1
end
