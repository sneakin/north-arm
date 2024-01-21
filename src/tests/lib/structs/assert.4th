' cons+cs-count defined? UNLESS
  " src/lib/list-cs.4th" load
THEN

def assert-meta-struct ( type name len base byte-size num-fields -- )
  5 argn
  value-of type-name peek as-code-pointer 4 argn arg3 assert-byte-string-equals/3
  5 argn value-of type-byte-size peek arg1 assert-equals
  5 argn value-of type-super peek as-code-pointer arg2 assert-equals
  arg0 0 int> IF
    5 argn value-of type-data peek as-code-pointer cons+cs-count arg0 assert-equals
  ELSE
    5 argn value-of type-data peek arg0 assert-equals
  THEN
  6 return0-n
end

def assert-type
  5 argn type-of type assert-equals
  5 argn 4 argn arg3 arg2 arg1 arg0 assert-meta-struct
  6 return0-n
end

def assert-struct
  5 argn type-of struct assert-equals
  5 argn 4 argn arg3 arg2 arg1 arg0 assert-meta-struct
  6 return0-n
end

def assert-struct-field ( struct field-name len type offset size -- )
  0
  4 argn arg3 5 argn value-of struct-get-field set-local0
  local0 assert
  local0 IF
    local0 value-of struct-field-name peek as-code-pointer 4 argn arg3 assert-byte-string-equals/3
    local0 value-of struct-field-type peek as-code-pointer arg2 type-super-of? assert
    local0 value-of struct-field-offset peek arg1 assert-equals
    local0 value-of struct-field-byte-size peek arg0 assert-equals
  THEN
end
