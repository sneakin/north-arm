( Fancy [linked] stack print out: )

( todo highlight words; seqs with sizes. )

40 var> fancy-stack-cols

def fancy-stack-link
  arg1 arg0 uint<= IF
    s" |" write-string/2
  ELSE
    s"  " write-string/2
  THEN
  arg1 return1
end

def fancy-stack-add-link
  arg0 fancy-stack-cols peek int>= IF return0 THEN
  arg1 arg0 seq-peek 0 equals? IF
    arg2 arg1 arg0 seq-poke
    return0
  THEN
  arg0 1 + set-arg0 repeat-frame
end

( use a @map-seq-n or a map-seq-n! )

def fancy-stack-zero-past-links
  arg0 fancy-stack-cols peek int>= IF return0 THEN
  arg1 arg0 seq-peek arg2 uint< IF
    0 arg1 arg0 seq-poke
  THEN
  arg0 1 + set-arg0 repeat-frame
end

( todo use map-seq )

def parent-frame-above ( target frame -- target frame )
  arg1 arg0 uint<= IF return0 THEN
  arg0 0 equals? IF return0 THEN
  arg0 parent-frame set-arg0 repeat-frame
end

def fancy-stack/4 ( stop-ptr start-ptr links next-fp )
  arg2 arg3 uint<= UNLESS return0 THEN
  arg2 arg0 equals? IF s" * " ELSE s"   " THEN write-string/2
  arg2 arg0 uint>= IF arg2 arg0 parent-frame-above set-arg0 drop THEN
  arg2 write-hex-uint space
  arg2 peek write-tabbed-hex-uint
  arg2 peek arg1 uint>= IF
    arg2 peek top-frame uint<= IF
      arg2 peek arg1 0 fancy-stack-add-link 3 dropn
    THEN
  THEN
  arg2 arg1 0 fancy-stack-zero-past-links 3 dropn
  arg1 fancy-stack-cols peek arg2 pointer fancy-stack-link map-seq-n/4 nl
  arg2 up-stack set-arg2 repeat-frame
end

def fancy-stack/2
  fancy-stack-cols peek stack-allot-zero-seq
  arg0 write-hex-uint s"  -> " write-string/2 arg1 write-hex-uint nl
  arg1 arg0 3 overn current-frame fancy-stack/4
end

def fancy-stack-full
  top-frame args fancy-stack/2
end

def fancy-stack-short
  args 40 up-stack/2 args fancy-stack/2
end

def fancy-stack-here
  here 40 up-stack/2 here fancy-stack/2
end

def fancy-stack-frame
  arg0 parent-frame arg0 fancy-stack/2
end
