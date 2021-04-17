def read-bytes ( ptr len fd -- ptr len )
  arg1 arg2 arg0 read 2 return1-n
end

def allot-read-bytes
  arg0 open-input-file negative? IF 0 set-arg1 0 set-arg0 return0 THEN
  arg1 cell-size + stack-allot arg1 local0 read-bytes
  negative? UNLESS 2dup null-terminate THEN ( todo byte-string-equals? needs? )
  local0 close drop
  exit-frame
end
