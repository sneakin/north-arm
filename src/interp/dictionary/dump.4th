def decompile-immediate
  arg0 dict dict-contains-values? IF 1 return0-n THEN
  nl arg0 decompile
  1 return0-n
end

def dump-dict/1
  ' decompile ' nl compose arg0 dict-revmap 1 return0-n
end

def dump-dict
  ( save state )
  output-base @
  get-hex-output-prefix
  output-number-prefix @
  ( configure output for hexadecimal )
  16 output-base !
  1 output-number-prefix !
  s" 0x" set-hex-output-prefix
  ( preface )
  s" 16 input-base poke" write-line/2 nl
  ( dump it )
  dict dump-dict/1
  ' decompile-immediate immediates peek cs + dict-revmap
  ( post script )
  s" 10 input-base poke" write-line/2
  ( restore state )
  local3 output-number-prefix !
  local1 local2 set-hex-output-prefix
  local0 output-base !
end
