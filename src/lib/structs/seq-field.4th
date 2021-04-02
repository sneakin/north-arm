( Structure fields that have multiple elements: )

def generate-struct-seq-field-name
  arg0 struct-name peek dup write-line
  arg1 struct-field-name peek dup write-line
  0
  local0 string-length local1 string-length + 5 + 3 + ( fixme one too many )
  dup stack-allot-zero set-local2
  local2 local3 local0 " -" string-append/4 write-line/2
  local2 local3 local2 local1 string-append/4 write-line/2
  local2 local3 local2 " -aref" string-append/4 2dup write-line/2
  exit-frame
end

def does-seq-field-accessor
  arg1 pointer seq-field-accessor does
  arg0 arg1 dict-entry-data poke
end

def generate-struct-seq-accessor ( field struct )
  arg1 value-of
  arg0
  generate-struct-seq-field-name
  create local0 does-seq-field-accessor drop
  exit-frame
end

def struct-create-seq-field ( name length type size struct )
  0 arg2 arg1 make-array-type set-local0
  4 argn arg3 local0 arg0 struct-create-field set-local0
  local0 arg0 generate-struct-seq-accessor
  local0 exit-frame
end

( A structure field with many elements stored sequentially. )
def seq-field: ( : name type size )
  next-token allot-byte-string/2
  next-type
  next-integer drop
  *this-struct* peek value-of
  struct-create-seq-field
  exit-frame
end
