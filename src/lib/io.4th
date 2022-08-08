( s[ src/lib/linux/clock.4th src/lib/linux/stat.4th ] load-list )

def read-bytes ( ptr len fd -- ptr len )
  arg1 arg2 arg0 read 2 return1-n
end

def allot-read-bytes ( num-bytes fd ++ ptr num-bytes )
  arg1 cell-size + stack-allot arg1 arg0 read-bytes
  ( read failed )
  negative? IF 0 set-arg1 0 set-arg0 return0 THEN
  ( null terminate the string and return it and the size )
  2dup null-terminate ( todo byte-string-equals? needs? )
  exit-frame
end

def allot-read-file/2 ( num-bytes path ++ ptr num-bytes )
  arg0 open-input-file negative? UNLESS
    arg1 local0 allot-read-bytes
    local0 close drop
    dup IF exit-frame THEN
  THEN
  0 set-arg1 0 set-arg0
end

def allot-read-file ( path ++ ptr num-bytes )
  arg0 file-size dup 0 equals? IF 0 set-arg0 0 return1 THEN
  arg0 allot-read-file/2 exit-frame
end
