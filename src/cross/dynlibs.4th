( will need two variants: using libdl in the interpreter and relocations in the compiler. Both need to add dictionary words that call / reference imports. )

( ELF output needs a list of libraries and symbols. Symbols each get a relocation that alters an address. )

( 0 var> *out-libs*
0 var> *out-imports*
)

def library> ( : path ++ library-item )
  next-token negative? IF error 0 return1 THEN
  2dup *out-libs* peek find-by-string-2
  dup IF return1
  ELSE
    drop allot-byte-string/2 drop
    *out-libs* push-onto
    exit-frame
  THEN
end

def out-fficaller-for-0 ( returns arity ++ out-word )
  out' do-fficall-0-0
  arg0 1 equals? IF out' do-fficall-1-0 THEN
  arg0 2 equals? IF out' do-fficall-2-0 THEN
  arg0 3 equals? IF out' do-fficall-3-0 THEN
  arg0 4 int>= IF out' do-fficall-4-0 THEN
  set-arg0 return0
end

def out-fficaller-for-1 ( returns arity ++ out-word )
  out' do-fficall-0-1
  arg0 1 equals? IF out' do-fficall-1-1 THEN
  arg0 2 equals? IF out' do-fficall-2-1 THEN
  arg0 3 equals? IF out' do-fficall-3-1 THEN
  arg0 4 int>= IF out' do-fficall-4-1 THEN
  set-arg0 return0
end

def out-fficaller-for ( returns arity ++ out-word )
  arg0 arg1 IF out-fficaller-for-1 ELSE out-fficaller-for-0 THEN
  dict-entry-code peek return1
end

  ( todo find any prior import entry. single symbol w/ multiple relocs )
  ( todo add relocation to list, symbol to another )
  ( store name, data, library, and space for a string table address to import list )

def out-import ( word returns symbol-index arity ++ )
  ( make relocation for data )
  arg3 dict-entry-data arg1 elf32-add-dynamic-jump-slot
  ( set code to ffi caller )
  arg2 arg0 out-fficaller-for rot 2 dropn
  arg3 dict-entry-code poke
  exit-frame
end

def import> ( library : name returns symbol arity ++ library )
  0 0
  create> set-local0
  next-integer IF
    set-local1
    next-token negative? UNLESS
      ( register symbol for importing before next-integer over writes )
      elf32-add-dynamic-symbol/2 local1 local0 rot
      next-integer IF
        out-import
        arg0 exit-frame
      THEN
    THEN
  THEN
  error
  ( todo drop out-dict )
  arg0 exit-frame
end
