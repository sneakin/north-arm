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

def print-regs-loop ( highs lows n -- )
  arg0 8 int< IF
    s" r" error-string/2
    arg0 error-uint
    tab arg1 peek dup error-hex-uint
    0x10000000 uint< IF tab THEN tab
    s" r" error-string/2
    arg0 8 + error-uint
    tab arg2 peek error-hex-uint enl
    arg1 cell-size + set-arg1
    arg2 cell-size + set-arg2
    arg0 1 + set-arg0 repeat-frame
  ELSE
    3 return0-n
  THEN
end

def print-regs/2 ( low high -- )
  0 ' print-regs-loop tail+1
end

def print-regs/1 ( ptr -- )
  arg0 cell-size 8 * + arg0 print-regs/2 1 return0-n
end

def print-regs
  0 dup save-low-regs set-local0
  save-high-regs local0 print-regs/2
end

def print-inplace-var
  arg0 ' do-inplace-var dict-entry-equiv? IF 1 return0-n THEN
  s" I" write-string/2 tab
  arg0 dict-entry-name @ cs + write-string tab
  arg0 exec-abs @ write-int nl
  1 return0-n
end

def print-data-var
  arg0 ' do-data-var dict-entry-equiv? IF 1 return0-n THEN
  s" D" write-string/2 space
  arg0 dict-entry-data @ cs + ( data-var-init-slot @ ) car write-int tab
  arg0 dict-entry-name @ cs + write-string tab
  arg0 exec-abs @ write-int tab
  arg0 dict-entry-data @ cs + ( data-var-init-value @ ) cdr write-int nl
  1 return0-n
end

def print-var
  arg0 dict-entry-code @ CASE
    ' do-inplace-var dict-entry-code @ OF arg0 print-inplace-var ENDOF
    ' do-data-var dict-entry-code @ OF arg0 print-data-var ENDOF
  ENDCASE
  1 return0-n
end

def print-vars
  dict ' print-var dict-map
end

( Memory dumping: )

def memdump/3 ( ptr num-bytes printer )
  arg1 0 int> IF
    arg2 peek arg0 exec-abs space
    arg2 cell-size + set-arg2
    arg1 cell-size - set-arg1
    repeat-frame
  ELSE
    nl
  THEN
end

def cmemdump/2 ( ptr num-bytes )
  arg1 arg0 ' write-hex-uint memdump/3
end

defcol cmemdump
  shift cmemdump/2
  int32 2 dropn
endcol

def memdump/2 ( ptr num-bytes )
  arg1 arg0 ' write-cell-lsb memdump/3
end

defcol memdump
  shift memdump/2
  int32 2 dropn
endcol


def dump-stack
  args write-hex-uint nl
  args 64 memdump nl
end
