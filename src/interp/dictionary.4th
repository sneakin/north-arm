( Dictionary access: )

( Entry construction: )

def alloc-dict-entry
  int32 0
  int32 0
  int32 0
  int32 0
  here exit-frame
end

def make-dict-entry ( name-ptr length ++ ...memory entry-ptr )
  alloc-dict-entry
  arg1 cs - over dict-entry-name poke
  exit-frame
end

( Iteration: )

( todo update callers that don't expect returns )
def dict-map/4 ( dict origin state fn ++ state )
  arg3 null? UNLESS
    arg1 arg3 arg0 exec-abs set-arg1
    arg3 dict-entry-link peek
    dup null? UNLESS
      arg2 + set-arg3
      repeat-frame
    ELSE drop
    THEN
  THEN arg1 exit-frame
end

def dict-map ( dict fn )
  arg1 cs int32 0 arg0 dict-map/4
end

( Querying: )

def dict-lookup/4 ( ptr length dict-entry origin -- ptr length entry found? )
  arg1 null? IF int32 0 set-arg0 return0 THEN
  ( arg1 dict-entry-name peek arg0 + arg2 write-string/2 )
  arg1 dict-entry-name peek arg0 + arg3 arg2 string-equals?/3 IF
    int32 1 set-arg0 return0
  THEN
  int32 3 dropn
  arg1 dict-entry-link peek
  dup null? IF int32 0 set-arg0 return0 THEN
  arg0 + set-arg1
  repeat-frame
end

def dict-lookup ( ptr length dict-entry ++ found? )
  arg2 arg1 arg0 cs dict-lookup/4
  over set-arg0
  return1
end

def dict-contains?/2 ( word dict ++ yes )
  arg0 int32 0 equals? IF int32 0 return1 THEN
  arg1 int32 0 equals? IF int32 0 return1 THEN
  arg1 arg0 equals? IF int32 1 return1 THEN
  arg0 dict-entry-link peek
  dup IF
    cs + set-arg0
    repeat-frame
  ELSE int32 0 return1 THEN
end

defcol defined?
  swap IF int32 1 ELSE int32 0 THEN
  swap
endcol

def defined?/2
  arg1 arg0 dict dict-lookup 2 return1-n
end

def dict-entry-equiv? ( word-a word-b -- yes? )
  ( Returns true when both words have to same code and data values. )
  arg1 arg0 equals?
  IF true
  ELSE arg1 dict-entry-code peek
       arg0 dict-entry-code peek equals?
       IF arg1 dict-entry-data peek
	  arg0 dict-entry-data peek equals?
       ELSE false
       THEN
  THEN 2 return1-n		    
end

def bound-dict-lookup-by-value ( value last-word current-word offset -- entry true || false )
  ( Search for ~value~ in the dictionary entries inclusively between ~last-word~ and ~current-word~. )
  arg1 0 equals? IF 0 4 return1-n THEN
  arg2 arg1 equals? IF 0 4 return1-n THEN
  arg1 dict-entry-data @ arg3 equals? IF arg1 true 4 return2-n THEN
  arg1 dict-entry-link @ dup IF arg0 + set-arg1 THEN repeat-frame
end
