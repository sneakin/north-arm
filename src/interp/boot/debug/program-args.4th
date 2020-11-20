( Program argument printing: )

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
    write-hex-uint tab
    cell-size + dup peek write-hex-uint nl
    cell-size + set-arg0 repeat-frame
  THEN
end

def print-auxvec
  auxvec print-auxvec/1
end
