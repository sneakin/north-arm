def stack-pointer?
  arg0 here uint>= 1 return1-n
end

def code-pointer?
  arg0 cs dup *code-size* + swap in-range? 1 return1-n
end
