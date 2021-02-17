load-core
tmp" src/lib/lib/libpng.4th" drop load
tmp" src/lib/assert.4th" drop load

def test-libpng-read
  0 0
  *debug* peek
  1 *debug* poke
  " misc/star.png" png-load-file .s
  dup IF
    set-local1 set-local0
    s" Loaded" write-line/2
    local1 128 memdump
  THEN
  local2 *debug* poke
end
