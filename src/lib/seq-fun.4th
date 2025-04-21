( Searching: )

def seq-index-of/4 ( fn seq n i -- index )
  arg0 arg1 int< UNLESS -1 4 return1-n THEN
  arg2 arg0 seq-peek arg3 exec-abs IF arg0 4 return1-n THEN
  arg0 1 + set-arg0
  repeat-frame
end

def seq-index-of ( item seq n -- index )
  ' equals? arg2 partial-first
  arg1 arg0 0 seq-index-of/4 3 return1-n
end
