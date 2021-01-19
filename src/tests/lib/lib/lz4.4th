tmp" src/lib/assert.4th" drop load
tmp" src/lib/lib/lz4.4th" drop load

def test-lz4
  0 0 0
  s" hello hello! hey world! hey hey hey world!" set-local1 set-local0
  local1 stack-allot set-local2
  ( compress string )
  local0 local1 2dup 3 + cell/ memdump lz4-compress
  nl .s 2dup 3 + cell/ memdump
  ( decompress )
  2dup local2 local1 lz4-decompress
  nl .s 2dup 3 + cell/ memdump 2dup write-line/2
  ( compare )
  local0 local1 assert-byte-string-equals/4
end
