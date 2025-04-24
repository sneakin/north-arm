def decompile-immediate
  arg0 dict dict-contains-values? IF 1 return0-n THEN
  nl arg0 decompile
  1 return0-n
end

def dump-dict/1
  ' decompile ' nl compose arg0 dict-revmap 1 return0-n
end

def dump-dict
  output-base @
  16 output-base !
  s" 16 input-base poke" write-line/2 nl
  dict dump-dict/1
  ' decompile-immediate immediates peek cs + dict-revmap
  s" 10 input-base poke" write-line/2
  local0 output-base !
end
