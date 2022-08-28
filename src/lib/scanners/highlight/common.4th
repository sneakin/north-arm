def write-string-times/3 ( str length times -- )
  arg0 1 int< IF 3 return0-n THEN
  arg2 arg1 write-string/2
  arg0 1 - set-arg0 repeat-frame
end

def write-error-opening ( error-code path -- )
  s" Failed to open: " write-string/2
  arg0 write-string space
  arg1 write-int nl
  2 return0-n
end
