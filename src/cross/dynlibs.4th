( will need two variants: using libdl in the interpreter and relocations in the compiler. Both need to add dictionary words that call / reference imports. )

( ELF output needs a list of libraries and symbols. Symbols each get a relocation that alters an address. )

( 0 var> *out-libs*
0 var> *out-imports*
)

def library> ( : path ++ )
  next-token negative? IF error 0 return1 THEN
  *out-libs* peek find-by-string-2
  IF return1
  ELSE
    drop allot-byte-string/2 drop
    *out-libs* push-onto
    exit-frame
  THEN
end

def fficaller-for
  out' do-fficall-0-1
  arg0 1 equals? IF out' do-fficall-1-1 THEN
  arg0 2 equals? IF out' do-fficall-2-1 THEN
  arg0 3 equals? IF out' do-fficall-3-1 THEN
  arg0 4 int>= IF out' do-fficall-4-1 THEN
  dict-entry-code peek set-arg0 return0
end

  ( todo find any prior import entry. single symbol w/ multiple relocs )
  ( todo add relocation to list, symbol to another )
  ( store name, data, library, and space for a string table address to import list )

def import> ( library : name symbol arity ++ library )
  0
  create> set-local0
  ( read name )
  next-token negative? IF error arg0 exit-frame THEN
  elf32-add-dynamic-symbol/2
  local0 dict-entry-data
  swap .s elf32-add-dynamic-jump-slot
  ( read arity & set word's code field )
  next-integer IF
    fficaller-for local0 dict-entry-code poke
  THEN
  arg0 exit-frame
end
