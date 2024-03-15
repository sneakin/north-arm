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

def assert-int-binary-op-by-table ( table num-rows fn -- )
  arg1 0 uint> UNLESS 3 return0-n THEN
  arg1 1 - set-arg1
  arg2 arg1 3 * cell-size * +
  dup @
  swap dup cell-size 2 * + @
  swap cell-size + @
  arg0 exec-abs assert-equals
  repeat-frame
end
