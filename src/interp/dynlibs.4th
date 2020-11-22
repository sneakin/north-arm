( will need two variants: using libdl in the interpreter and relocations in the compiler. Both need to add dictionary words that call / reference imports. )

0 var> *libraries*

def library> ( : path ++ handle )
  next-token negative? IF 0 return1 THEN
  *libraries* peek assoc-string-2
  IF return1
  ELSE
    drop allot-byte-string/2 drop
    0 over dlopen dup UNLESS not-found 0 return1 THEN
    swap cons *libraries* push-onto
    *libraries* peek car cdr current-frame drop exit-frame
  THEN
end

def fficaller-for
  pointer do-fficall-0-1
  arg0 1 equals? IF pointer do-fficall-1-1 THEN
  arg0 2 equals? IF pointer do-fficall-2-1 THEN
  arg0 3 equals? IF pointer do-fficall-3-1 THEN
  arg0 4 int>= IF pointer do-fficall-4-1 THEN
  dict-entry-code peek set-arg0
end

def import> ( library : name symbol arity ++ )
  0
  create> set-local0
  ( read & resolve symbol )
  next-token negative? IF arg0 exit-frame THEN
  drop arg0 dlsym dup UNLESS not-found arg0 exit-frame THEN
  local0 dict-entry-data poke
  ( set code field to ffi caller )
  next-integer IF
    fficaller-for local0 dict-entry-code poke
  THEN
  arg0 exit-frame
end
