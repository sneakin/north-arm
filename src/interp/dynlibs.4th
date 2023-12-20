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

def library/2 ( path len ++ handle )
  arg0 negative? IF 0 2 return1-n THEN
  arg1 arg0 *libraries* peek assoc-string-2
  dup IF cdr 2 return1-n
  ELSE
    drop arg1 arg0 allot-byte-string/2 drop
    RTLD-NOW over dlopen dup UNLESS not-found 0 2 return1-n THEN
    swap cons *libraries* push-onto
    *libraries* peek car cdr exit-frame
  THEN
end

def library> ( : path ++ handle )
  next-token library/2 dup IF exit-frame ELSE return1 THEN
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
	next-token 2 dropn ( eat the tailing integer )
        not-found
      THEN
    THEN
  THEN
  dict-drop return0
end

def does-indirect-var ( ptr word -- )
  arg1 arg0 dict-entry-data !
  arg0 ' do-indirect-var does
  2 return0-n
end

def import-var> ( library : new-word symbol ++ library )
  0 create> set-local0
  next-token negative? UNLESS
    drop arg0 dlsym dup IF
      local0 does-indirect-var
      arg0 exit-frame
    THEN
  THEN
  ( drop the new word )
  dict-drop
end

def import-value> ( library : new-word symbol ++ library )
  0 create> set-local0
  local0 does-const
  next-token negative? UNLESS
    drop arg0 dlsym dup IF
      local0 dict-entry-data !
      arg0 exit-frame
    THEN
  THEN
  ( drop the new word )
  dict-drop
end

def import-const> ( library : new-word symbol ++ library )
  0 create> set-local0
  local0 ' do-indirect-const does
  next-token negative? UNLESS
    drop arg0 dlsym dup IF
      local0 dict-entry-data !
      arg0 exit-frame
    THEN
  THEN
  ( drop the new word )
  dict-drop
end

def import-word> ( library : new-word symbol ++ library )
  0 create> set-local0
  next-token negative? UNLESS
    drop arg0 dlsym dup IF
      dup dict-entry-code @ local0 dict-entry-code !
      dup dict-entry-data @ local0 dict-entry-data !
      arg0 exit-frame
    THEN
  THEN
  ( drop the new word )
  dict-drop
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
end

def import-var>
  dynamic-linking-warning
  next-token
end

def import-constant>
  dynamic-linking-warning
  next-token
end

def import-word>
  dynamic-linking-warning
  next-token
end

def import-op>
  dynamic-linking-warning
  next-token
end

def import-func>
  dynamic-linking-warning
  next-token
end

[THEN]
