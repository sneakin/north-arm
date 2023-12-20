( def stack-pointer?
  arg0 here uint>= 1 return1-n
end

def code-pointer?
  arg0 cs dup *code-size* + swap uint-in-range? 1 return1-n
end
)

' uint-in-range? defined? [UNLESS] ( in runner/math.4th )
  def uint-in-range? ( n max min )
    arg2 arg1 uint<=
    arg2 arg0 uint>= and return1
  end
[THEN]

def potential-pointer? ( ptr -- yes? )
  arg0 0x2 logand 0 equals? set-arg0
end

def thumb-pointer? ( ptr -- yes? )
  arg0 1 logand 1 equals? set-arg0
end

def stack-pointer? ( ptr -- yes? )
  arg0 top-frame here uint-in-range? set-arg0
end

def data-pointer? ( ptr -- yes? )
  arg0 dhere data-stack-base @ uint-in-range? set-arg0
end  

def code-pointer? ( ptr -- yes? )
  arg0 cs *code-size* + cs uint-in-range? set-arg0
end

def code-offset? ( ptr -- yes? )
  arg0 *code-size* 0 uint-in-range? set-arg0
end
  
def pointer? ( ptr -- yes? )
  arg0 stack-pointer?
  IF true
  ELSE arg0 code-pointer?
  THEN set-arg0
end

