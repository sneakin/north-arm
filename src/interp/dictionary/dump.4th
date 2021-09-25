def decompile-immediate
  nl arg0 decompile
  s" immediate" write-line/2
end

def dump-dict/1
  ' decompile ' nl compose arg0 swap dict-revmap 1 return0-n
end

def dump-dict
  s" 16 input-base poke" write-line/2
  dict dump-dict/1
  immediates peek cs + ' decompile-immediate dict-revmap
  s" 10 input-base poke" write-line/2
end
