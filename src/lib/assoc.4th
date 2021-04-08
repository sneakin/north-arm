def find-by-string-2 ( ptr length list -- ptr length result result )
' string-equals?/3 arg1 partial-first arg2 partial-first
  arg0 over find-first 3 return1-n  
end

def assoc-fn/3 ( list test-fn key-fn -- result )
  arg0 arg1 compose 
  arg2 over find-first 3 return1-n
end

def assoc-fn ( list test-fn -- result )
  arg1 arg0 ' car assoc-fn/3 2 return1-n
end

def assoc ( list key fn -- result )
  arg0 arg1 partial-first
  arg2 over assoc-fn 3 return1-n
end

def assoc-string-2 ( ptr length list -- result )
  ' string-equals?/3 arg1 partial-first arg2 partial-first
  arg0 over assoc-fn 3 return1-n
end
