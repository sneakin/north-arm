( todo functions need a C ABI wrapper )
( todo names could use mangling of '-' )
( todo elf64 )

def export-word ( word ++ elf-symbol )
  ( Export a dictionary entry in the ELF dynamic symbol table. )
  arg0 to-out-addr
  arg0 dict-entry-name @ from-out-addr
  dup string-length
  elf32-add-dynamic-export-code-object/3 exit-frame
end

def export-inplace-var ( word ++ elf-symbol )
  ( Export an inplace variable via the ELF dynamic symbol table. )
  arg0 dict-entry-data to-out-addr
  arg0 dict-entry-name @ from-out-addr
  dup string-length
  elf32-add-dynamic-export-code-object/3 exit-frame
end

def export-data-var ( word ++ elf-symbol )
  ( Export a data segment variable's address via the ELF dynamic symbol table. )
  arg0 dict-entry-data @ from-out-addr @ cell-size *
  arg0 dict-entry-name @ from-out-addr
  dup string-length
  elf32-add-dynamic-export-data/3 exit-frame
end

def export-var ( word ++ elf-symbol )
  arg0 dict-entry-code @
  dup out' do-inplace-var dict-entry-code @ equals?
  IF arg0 export-inplace-var exit-frame
  ELSE
    dup out' do-data-var dict-entry-code @ equals?
    IF arg0 export-data-var exit-frame THEN
  THEN
  s" Unknown variable type: " error-string/2 error-hex-uint enl
  0 1 return1-n
end

alias> export-constant export-inplace-var ( value stored in data field )

def export-value ( value str length ++ elf-symbol )
  arg2 arg1 arg0 elf32-add-dynamic-export-value/3 exit-frame
end

( todo export for C callers:
    use ffi-callback-for?
    save cpu state, create north state, exec word, restore cpu state
    north init function necessary?
)

def export-op
  ( Export a word's code field. )
  arg0 dict-entry-code @
  arg0 dict-entry-name @ from-out-addr
  dup string-length
  elf32-add-dynamic-export-func/3 exit-frame
end

def export-func
  ( Export a word's data field as a function. )
  arg0 dict-entry-data @
  arg0 dict-entry-name @ from-out-addr
  dup string-length
  elf32-add-dynamic-export-func/3 exit-frame
end
