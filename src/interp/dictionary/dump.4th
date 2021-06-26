def decompile-immediate
  nl arg0 decompile
  s" immediate" write-line/2
end

def dump-dict
  s" 16 input-base poke" write-line/2
  ' decompile ' nl compose dict swap dict-revmap
  immediates peek cs + ' decompile-immediate dict-revmap
  s" 10 input-base poke" write-line/2
end
