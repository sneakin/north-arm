def write-string-times/3 ( str length times -- )
  arg0 1 int< IF 3 return0-n THEN
  arg2 arg1 write-string/2
  arg0 1 - set-arg0 repeat-frame
end

def comment-done
  arg0 41 equals? set-arg0
end

def string-done
  arg0 34 equals? set-arg0
end

