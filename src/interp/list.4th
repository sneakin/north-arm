( List reading: )

def read-list ( last-token result ++ result )
  next-token negative? IF 2 dropn arg0 exit-frame THEN
  over s" (" string-equals?/3 IF 5 dropn POSTPONE ( repeat-frame ELSE 3 dropn THEN
  arg1 3 overn 3 overn string-equals?/3 IF 5 dropn arg0 exit-frame THEN
  3 dropn allot-byte-string/2 drop
  arg0 swap cons set-arg0
  repeat-frame
end

( Reads tokens to the stack and returns a list stored on the stack. )
def s[
  s" ]" drop 0 read-list exit-frame
end

( todo switch to defs gets these included when cross compiling. )

( Reads a list of tokens to the stack, placing ' literal before each so the list is stack allocated at runtime. )
: read-literal-stack-list
  next-token negative? IF 2 dropn proper-exit THEN
  over s" (" byte-string-equals?/3 IF 5 dropn POSTPONE ( loop THEN
  over s" ]" byte-string-equals?/3
  IF 5 dropn proper-exit ELSE 3 dropn THEN
  dhere rot swap 0 ,byte-string/3 3 dropn ( fixme drop the drop )
  literal literal rot ( to-out-addr )
  literal cons swap
  1 + loop
;

( fixme "literal int32 0" caused problems. )

: old-'s[
  literal int32 int32 0
  0 read-literal-stack-list drop
; immediate-as old-s[

( Operations: )

def print-cons
  s" (" write-string/2
  arg0 car write-hex-uint
  s"  . " write-string/2
  arg0 cdr write-hex-uint
  s" )" write-string/2
end

def load-1
  arg0 load
  1 exit-frame
end
  
def load-list ( pair ++ )
  arg0 0 ' load-1 revmap-cons/3 exit-frame
end
