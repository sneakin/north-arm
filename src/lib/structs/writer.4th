( Structure writers: )

def print-struct-field
  arg0 value-of
  s"   Field: " write-string/2
  local0 struct-field-name peek write-string space
  local0 struct-field-type peek dup dup IF value-of struct-name peek write-string space THEN write-hex-uint space
  local0 struct-field-offset peek write-hex-uint space
  local0 struct-field-byte-size peek write-hex-uint nl
end

def print-struct
  s" Name: " write-string/2
  arg0 struct-name peek write-line
  s" Byte size: " write-string/2
  arg0 struct-byte-size peek write-hex-uint nl
  s" Fields: " write-string/2 nl
  arg0 struct-fields peek ' print-struct-field map-car
end

( Pointer dereferencing printers: )

def print-pointer-type
  arg0 type-of write-hex-uint space
  arg0 type-of value-of type-name peek as-code-pointer write-string space
  arg0 type-of value-of type-super peek dup IF value-of type-name peek as-code-pointer write-string ELSE drop THEN space
  arg0 write-hex-uint s" :" write-string/2
  arg0 type-of value-of type-byte-size peek write-uint nl
end
  
def print-pointer<any>
  arg0 write-hex-uint space
  s" Type: " write-string/2
  arg0 print-pointer-type
  s" Value: " write-string/2
  arg0 value-of write-uint nl
end

def print-pointer<struct>
  arg0 print-pointer-type
  arg0 type equals? ( an exception )
  arg0 struct kind-of? or IF
    s" Struct: " write-line/2
    arg0 value-of print-struct
  THEN
end

( Structure instance, generalized printer: )

def print-instance-field ( field instance )
( todo pick printer based on field type )
  s"   " write-string/2
  arg1 struct-field-offset peek
  dup write-uint s" :" write-string/2
  arg1 struct-field-byte-size peek write-uint space
  arg1 struct-field-type peek value-of type-name dup IF peek as-code-pointer write-string space ELSE drop s" - " write-string/2 THEN
  arg1 struct-field-name peek as-code-pointer write-string space
  arg0 + peek dup write-uint space write-hex-uint enl
end

def print-instance-fields-loop ( struct-fields instance-value )
  arg1 IF
    arg1 car value-of arg0 print-instance-field
    arg1 cdr as-code-pointer set-arg1 repeat-frame
  THEN 2 return0-n
end

def print-instance-fields ( instance type )
  arg0 IF
    arg0 value-of
    dup struct-fields peek as-code-pointer arg1 value-of print-instance-fields-loop
    type-super peek set-arg0 repeat-frame
  THEN 2 return0-n
end

( todo atomic types )
( todo inherited fields )

def print-instance/2
  arg1 print-pointer-type
  arg0 value-of arg0 sizeof cmemdump
  arg0 print-instance-fields
end

def print-instance
  arg0 dup type-of print-instance/2
end
