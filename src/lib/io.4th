def read-bytes ( ptr len fd -- ptr len )
  arg1 arg2 arg0 read 2 return1-n
end

def allot-read-bytes ( num-bytes path ++ ptr num-bytes )
  arg0 open-input-file negative? IF 0 set-arg1 0 set-arg0 return0 THEN
  arg1 cell-size + stack-allot arg1 local0 read-bytes
  local0 close drop
  ( read failed )
  negative? IF 0 set-arg1 0 set-arg0 return0 THEN
  ( null terminate the string and return it and the size )
  2dup null-terminate ( todo byte-string-equals? needs? )
  exit-frame
end

def allot-read-file ( path ++ ptr num-bytes )
  arg0 file-size arg0 allot-read-bytes exit-frame
end
