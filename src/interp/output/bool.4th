def bool->string ( boolean -- )
  arg0 IF s" true" ELSE s" false" THEN 1 return2-n
end

def error-bool ( boolean -- )
  arg0 bool->string error-string/2 1 return0-n
end

def write-bool ( boolean -- )
  arg0 bool->string write-string/2 1 return0-n
end
