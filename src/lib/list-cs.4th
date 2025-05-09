( Code segment safe list functions: )

DEFINED? as-code-pointer UNLESS
  " src/lib/pointers.4th" load
THEN

def car+cs arg0 car as-code-pointer set-arg0 end
def cdr+cs arg0 cdr as-code-pointer set-arg0 end

def map-car+cs/3 ( cons state fn )
  arg2 UNLESS arg1 exit-frame THEN
  arg1 arg2 car+cs arg0 exec-abs set-arg1
  arg2 cdr+cs set-arg2 repeat-frame
end

def map-car+cs ( cons fn )
  arg1 UNLESS exit-frame THEN
  arg1 car+cs arg0 exec-abs
  arg1 cdr+cs set-arg1 repeat-frame
end

def cons+cs-count-fn ( count item -- count+1 )
  arg1 1 + 2 return1-n
end

def cons+cs-count
  arg0 0 ' cons+cs-count-fn map-car+cs/3 set-arg0
end

def find-first-result+cs ( list fn[item -- result yes?]  -- result yes? )
  arg1 IF
    arg1 car+cs arg0 exec-abs
    IF true
    ELSE arg1 cdr+cs set-arg1 repeat-frame
    THEN
  ELSE false
  THEN 2 return2-n
end

def list+cs-has-string? ( str len list -- yes? )
  ' byte-string-equals?/3 arg2 arg1 2 partial-first-n
  arg0 swap find-first-result+cs 3 return1-n
end
