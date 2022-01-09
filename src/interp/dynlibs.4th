( will need two variants: using libdl in the interpreter and relocations in the compiler. Both need to add dictionary words that call / reference imports. )

1 const> RTLD-LAZY
2 const> RTLD-NOW

NORTH-STAGE 2 int> [IF]

0
' do-fficall-4-0
' do-fficall-3-0
' do-fficall-2-0
' do-fficall-1-0
' do-fficall-0-0
here const> do-fficalls-0

0
' do-fficall-4-1
' do-fficall-3-1
' do-fficall-2-1
' do-fficall-1-1
' do-fficall-0-1
here const> do-fficalls-1

def fficaller-for ( returns arity ++ code-word )
  arg1 IF do-fficalls-1 ELSE do-fficalls-0 THEN
  arg0 5 uint< IF arg0 ELSE 4 THEN cell-size * + THEN
  peek dict-entry-code peek return1
end

0 var> *libraries*

def library> ( : path ++ handle )
  next-token negative? IF 0 return1 THEN
  2dup *libraries* peek assoc-string-2
  dup IF return1
  ELSE
    drop allot-byte-string/2 drop
    RTLD-NOW over dlopen dup UNLESS not-found 0 return1 THEN
    swap cons *libraries* push-onto
    *libraries* peek car cdr current-frame drop exit-frame
  THEN
end

def does-import ( word returns fn arity ++ )
  ( set code field to ffi caller )
  arg2 arg0 fficaller-for arg3 dict-entry-code poke
  ( data to fn )
  arg1 arg3 dict-entry-data poke
end

def import> ( library : name returns symbol arity ++ )
  0 0
  create> set-local0
  next-integer IF
    set-local1
    next-token negative? UNLESS
      ( resolve symbol now since next-integer clobbers )
      drop arg0 dlsym dup IF
        local1 local0 rot
        next-integer IF
          does-import 4 dropn
          arg0 exit-frame
	THEN
      ELSE
        not-found
      THEN
    THEN
  THEN
  ( todo drop dict on error )
  error
  arg0 exit-frame
end

[ELSE]

def dynamic-linking-warning
  s" Warning: dynamic linking not supported" error-line/2
end
  
def library>
  dynamic-linking-warning next-token
  0 return1
end

def import>
  dynamic-linking-warning
  next-token
  next-token
  next-token
  next-token
  0 return1
end

[THEN]
