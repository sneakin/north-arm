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

( Memory dumping: )

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
