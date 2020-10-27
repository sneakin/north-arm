( Debugging aids: )

defcol print-caller-args
  arg3 error-hex-int nl
  arg2 error-hex-int nl
  arg1 error-hex-int nl
  arg0 error-hex-int nl nl
endcol

def print-args
  arg3 error-hex-int nl
  arg2 error-hex-int nl
  arg1 error-hex-int nl
  arg0 error-hex-int nl nl
end

( Decompiling words: )

def dict-contains?
  arg0 dict dict-contains?/2 IF int32 1 return1 THEN
  arg0 immediates peek dict-contains?/2 return1
end

def decompile-loop
  arg0 peek int32 0 equals? IF nl return THEN
  arg0 peek cs +
  dup dict-contains? UNLESS nl return THEN
  dup dict-entry-name peek cs + write-string space
  literalizes? IF
    arg0 op-size +
    dup set-arg0
    peek write-hex-uint space
  THEN
  arg0 op-size + set-arg0
  repeat-frame
end

def decompile ( entry )
  arg0 IF
    " does> " write-string/2
    arg0 dict-entry-code peek write-hex-uint nl
    arg0 dict-entry-data peek
    dup IF cs + decompile-loop THEN
  THEN
end

def memdump/2 ( ptr num-bytes )
  arg1 peek write-hex-uint space
  arg1 cell-size + set-arg1
  arg0 cell-size int>= IF
    arg0 cell-size - set-arg0
    repeat-frame
  ELSE
    nl
  THEN
end

defcol memdump
  rot swap memdump/2
  int32 2 dropn
endcol

def dump-stack
  args write-hex-uint nl
  args 64 memdump nl
end
