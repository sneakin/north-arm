def if?
  arg1 s" IF" string-equals?/3 return1
end

def unless?
  arg1 s" UNLESS" string-equals?/3 return1
end

def else?
  arg1 s" ELSE" string-equals?/3 return1
end

def then?
  arg1 s" THEN" string-equals?/3 return1
end

def else-or-then?
  arg1 arg0 else? rot swap then? rot int32 2 dropn or return1
end

def if-or-unless?
  arg1 arg0 if? rot swap unless? rot int32 2 dropn or return1
end

defcol skip-conditional-tokens
  ' if-or-unless?
  ' else-or-then?
  ' then?
  nested-skip-tokens-until
endcol

defcol IF
  swap UNLESS skip-conditional-tokens THEN
endcol

defcol UNLESS
  swap IF skip-conditional-tokens THEN
endcol

defcol ELSE
  ' if-or-unless?
  ' then?
  ' then?
  nested-skip-tokens-until
endcol

defcol THEN
  ( no need to do anything besides not crash )
endcol
