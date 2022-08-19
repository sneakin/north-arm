def assert-int64
  arg3 arg2 arg1 arg0 int64-equals?
  dup assert
  UNLESS
    nl
    arg2 write-hex-uint s" :" write-string/2
    arg3 write-hex-uint s"  != " write-string/2
    arg0 write-hex-uint s" :" write-string/2
    arg1 write-hex-uint nl
  THEN 4 return0-n
end
