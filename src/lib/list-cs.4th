( Code segment safe list functions: )

' as-code-pointer defined? UNLESS
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
