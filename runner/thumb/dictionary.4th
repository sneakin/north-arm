( Dictionary access: )

defcol dict-entry-name
  exit exit ( fixme compiling-read and empties, revmap too? )
endcol

defcol dict-entry-code
  swap cell-size + swap
endcol

defcol dict-entry-data
  swap cell-size + cell-size + swap
endcol

defcol dict-entry-link
  swap cell-size int32 3 * + swap
endcol

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

( Querying: )

def dict-lookup ( ptr length dict-entry ++ found? )
  arg0 null? IF int32 0 return1 THEN
  ( arg0 dict-entry-name peek cs + arg1 write-string/2 )
  arg0 dict-entry-name peek cs + arg2 arg1 string-equals?/3 IF
    int32 1 return1
  THEN
  int32 3 dropn
  arg0 dict-entry-link peek
  dup null? IF int32 0 return1 THEN
  cs + set-arg0
  repeat-frame
end

def lookup ( ptr length -- dict-entry found? )
  arg1 arg0 dict dict-lookup
  set-arg0 set-arg1
endcol

defcol defined?
  swap IF int32 1 ELSE int32 0 THEN
  swap
endcol
