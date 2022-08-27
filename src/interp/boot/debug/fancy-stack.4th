( Fancy [linked] stack print out: )

( todo highlight words; seqs with sizes, typed structs, color coding, unreachable/reachable. )

40 var> fancy-stack-cols

def potential-pointer? ( ptr -- yes? )
  arg0 0x2 logand 0 equals? set-arg0
end

def thumb-pointer? ( ptr -- yes? )
  arg0 1 logand 1 equals? set-arg0
end

def stack-pointer? ( ptr -- yes? )
  arg0 top-frame here in-range? set-arg0
end

def data-pointer? ( ptr -- yes? )
  arg0 dhere data-stack-base @ in-range? set-arg0
end  

def code-pointer? ( ptr -- yes? )
  arg0 cs *code-size* + cs in-range? set-arg0
end

def code-offset? ( ptr -- yes? )
  arg0 *code-size* 0 in-range? set-arg0
end
  
def pointer? ( ptr -- yes? )
  arg0 stack-pointer?
  IF true
  ELSE arg0 code-pointer?
  THEN set-arg0
end

def fancy-stack-link ( ptr top-frame -- ptr )
  arg1 arg0 uint<= IF
    s" |" write-string/2
  ELSE
    s"  " write-string/2
  THEN
  arg1 2 return1-n
end

def fancy-stack-add-link ( stack-ptr stack-min counter -- )
  arg0 fancy-stack-cols peek int>= IF 3 return0-n THEN
  arg1 arg0 seq-peek 0 equals? IF
    arg2 arg1 arg0 seq-poke
    3 return0-n
  THEN
  arg0 1 + set-arg0 repeat-frame
end

def fancy-stack-maybe-add-link ( stack-value stack-min -- )
  arg1 arg0 uint>= IF
    arg1 top-frame uint<= IF
      arg1 arg0 0 fancy-stack-add-link
    THEN
  THEN 2 return0-n
end
  
( use a @map-seq-n or a map-seq-n! )

def fancy-stack-zero-past-links ( stack-min link-cols counter -- )
  arg0 fancy-stack-cols peek int>= IF 3 return0-n THEN
  arg1 arg0 seq-peek arg2 uint< IF
    0 arg1 arg0 seq-poke
  THEN
  arg0 1 + set-arg0 repeat-frame
end

def fancy-stack-write-pointer-classes ( ptr -- )
  arg0 peek potential-pointer? IF
    arg0 peek thumb-pointer?
    IF s" t"
    ELSE arg0 peek cs + stack-pointer? IF s" c" ELSE s" p" THEN
    THEN
  ELSE s" -"
  THEN write-string/2
  arg0 peek stack-pointer? IF s" s" ELSE s" -" THEN write-string/2
  arg0 peek data-pointer? IF s" d" ELSE s" -" THEN write-string/2
  arg0 peek code-pointer?
  IF s" c"
  ELSE arg0 peek code-offset?
       IF arg0 peek cs + stack-pointer? IF s" O" ELSE s" o" THEN
       ELSE s" -" THEN
  THEN write-string/2
  1 return0-n
end

( todo use map-seq )

def parent-frame-above ( target frame -- frame )
  arg1 arg0 uint> IF
    arg0 parent-frame dup IF set-arg0 repeat-frame THEN
  THEN arg0 2 return1-n
end

def fancy-stack/4 ( stop-ptr start-ptr link-cols next-fp -- )
  arg2 arg3 uint<= UNLESS 4 return0-n THEN
  arg2 arg0 equals? IF
    s" * "
  ELSE arg2 peek arg0 equals? IF s" x " ELSE s"   " THEN 
  THEN write-string/2
  arg2 arg0 uint>= IF arg2 arg0 parent-frame-above set-arg0 THEN
  arg2 write-hex-uint space
  arg2 peek write-tabbed-hex-uint
  arg2 peek arg1 fancy-stack-maybe-add-link
  arg2 peek cs + arg1 fancy-stack-maybe-add-link
  arg2 arg1 0 fancy-stack-zero-past-links
  arg1 fancy-stack-cols peek arg2 pointer fancy-stack-link map-seq-n/4
  space
  arg2 fancy-stack-write-pointer-classes nl
  arg2 up-stack set-arg2
  drop-locals repeat-frame
end

def fancy-stack/2
  fancy-stack-cols peek stack-allot-zero-seq
  arg0 write-hex-uint s"  -> " write-string/2 arg1 write-hex-uint nl
  arg1 arg0 3 overn current-frame fancy-stack/4
  2 return0-n
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
  1 return0-n
end
