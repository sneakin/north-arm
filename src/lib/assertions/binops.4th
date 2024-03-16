def assert-binary-op-by-table ( table num-rows fn assert-fn -- )
  arg2 0 uint> UNLESS 4 return0-n THEN
  arg2 1 - set-arg2
  arg3 arg2 3 * cell-size * +
  dup @
  swap dup cell-size 2 * + @
  swap cell-size + @
  arg1 exec-abs arg0 exec-abs
  repeat-frame
end

def assert-int-binary-op-by-table ( table num-rows fn -- )
  ' assert-equals ' assert-binary-op-by-table tail+1
end

def assert-bool-binary-op-by-table ( table num-rows fn -- )
  ' assert-bool ' assert-binary-op-by-table tail+1
end
