def find-by-string-2 ( ptr length list -- ptr length result result )
  arg0 UNLESS arg0 return1 THEN
  arg0 car arg2 arg1 string-equals?/3 IF arg0 return1 THEN
  arg0 cdr set-arg0
  repeat-frame
end

def assoc-string-2 ( ptr length list -- ptr length result result )
  arg0 UNLESS arg0 return1 THEN
  arg0 car car arg2 arg1 string-equals?/3 IF arg0 car cdr dup set-arg0 return1 THEN
  arg0 cdr set-arg0
  repeat-frame
end
