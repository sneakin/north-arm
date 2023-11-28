( todo functions need a C ABI wrapper )
( todo names could use mangling of '-' )

def export-word
  arg0 to-out-addr
  arg0 dict-entry-name @ from-out-addr
  dup string-length
  elf32-add-dynamic-export-code-object/3 exit-frame
end

def export-inplace-var
  arg0 dict-entry-data @
  arg0 dict-entry-name @ from-out-addr
  dup string-length
  elf32-add-dynamic-export-code-object/3 exit-frame
end

def export-data-var
  arg0 dict-entry-data @ from-out-addr @ cell-size *
  arg0 dict-entry-name @ from-out-addr
  dup string-length 2dup error-line/2 3 overn .h enl
  elf32-add-dynamic-export-data/3 exit-frame
end

alias> export-var export-data-var

def export-func
  arg0 dict-entry-code @
  arg0 dict-entry-name @ from-out-addr
  dup string-length
  elf32-add-dynamic-export-func/3 exit-frame
end
