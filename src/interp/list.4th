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

( Operations: )

def print-cons
  s" (" write-string/2
  arg0 car write-hex-uint
  s"  . " write-string/2
  arg0 cdr write-hex-uint
  s" )" write-string/2
end

def load-list ( pair ++ )
  arg0 0 ' load revmap-cons/3 exit-frame
end
