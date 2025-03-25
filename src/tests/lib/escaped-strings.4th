DEFINED? es" UNLESS
  s" src/lib/escaped-strings.4th" load/2
THEN
DEFINED? assert-equals UNLESS
  s" src/lib/assert.4th" load/2
THEN

top-s" Hey\nyou " 9 assert-equals
const> test-escape-string-raw-short-value
top" Hey\n\tyou \e[31mthere\e[0mxy\\\n" const> test-escape-string-raw-big-value

s" Hey\nyou\x20" 8 assert-equals
const> test-escape-string-short-value
" Hey\n\tyou\x20\e[31mthere\e[0m\u0078\x79\\\n" const> test-escape-string-big-value

def test-escape-string-immeds
  ( s" aliased as top-s" )
  test-escape-string-raw-short-value top-s" Hey\nyou " assert-byte-string-equals/3
  ( " aliased as top" )
  test-escape-string-raw-short-value top" Hey\nyou " 9 assert-byte-string-equals/3
  ( [es"] immediates as s" )
  test-escape-string-short-value s" Hey\nyou\x20" assert-byte-string-equals/3  
  ( [e"] immediates as " )
  test-escape-string-short-value " Hey\nyou\x20" 8 assert-byte-string-equals/3  
end

def test-unescape-string/4
  0 256 stack-allot-zero set-local0
  ( short value )
  test-escape-string-raw-short-value 9 local0 256 unescape-string/4
  top-s" Hey
you " assert-byte-string-equals/4
  ( big value )
  test-escape-string-raw-big-value 33 local0 256 unescape-string/4
  s" Hey\n\tyou\x20\e[31mthere\e[0m\u0078\x79\\\n" assert-byte-string-equals/4
  ( no overwrites when output is short )
  local0 256 120 fill
  test-escape-string-raw-short-value 9 local0 5 unescape-string/4
  2dup 1 + peek-off-byte 120 assert-equals
  2dup null-terminate
  s" Hey\ny" assert-byte-string-equals/4
  ( no overwrites when output is short on escape )
  local0 256 120 fill
  test-escape-string-raw-short-value 9 local0 4 unescape-string/4
  2dup 1 + peek-off-byte 120 assert-equals
  2dup null-terminate
  s" Hey\n" assert-byte-string-equals/4
  ( stops if input ends )
  test-escape-string-raw-short-value 4 local0 256 unescape-string/4
  s" Hey" assert-byte-string-equals/4
  ( hex code )
  top-s" \xAB\x01" local0 256 unescape-string/4
  s" \xAB\x01" assert-byte-string-equals/4
  ( long hex code )
  top-s" \u01020304" local0 256 unescape-string/4
  s" \u01020304" assert-byte-string-equals/4
  ( double quote )
  ( todo
  top-s" hey \"you\"\n" local0 256 unescape-string/4
  s" hey \"you\"\n" assert-byte-string-equals/4
)
end

def test-unescape-string/2
  ( over writes the string )
  0 0
  256 stack-allot-zero set-local0
  top-s" hello\nworld\n" set-local1
  local0 local1 copy
  local0 local1 unescape-string/2
  12 assert-equals
  local0 assert-equals
  local0 s" hello\nworld\n" assert-byte-string-equals/3
end

def test-escape-string/4
  0 256 stack-allot-zero set-local0
  ( short value )
  test-escape-string-short-value 8 local0 256 escape-string/4
  test-escape-string-raw-short-value 9 assert-byte-string-equals/4
  ( big value )
  test-escape-string-big-value 27 local0 256 escape-string/4
  test-escape-string-raw-big-value 33 assert-byte-string-equals/4
  ( no overwrites when output is short )
  local0 256 120 fill
  test-escape-string-short-value 8 local0 5 escape-string/4
  2dup 1 + peek-off-byte 120 assert-equals
  2dup null-terminate
  top-s" Hey\n" assert-byte-string-equals/4
  ( no overwrites when output is short on escape )
  local0 256 120 fill
  test-escape-string-short-value 8 local0 4 escape-string/4
  2dup 1 + peek-off-byte 120 assert-equals
  2dup null-terminate
  top-s" Hey\" assert-byte-string-equals/4
  ( stops if input ends )
  test-escape-string-short-value 4 local0 256 escape-string/4
  top-s" Hey\n" assert-byte-string-equals/4
  ( hex code )
  s" \xAB\x01" local0 256 escape-string/4
  top-s" \xAB\x01" assert-byte-string-equals/4
  ( double quote )
  s" hey \x22you\x22\n" local0 256 escape-string/4
  s" hey \\\x22you\\\x22\\n" assert-byte-string-equals/4
end

def test-escape-string/2
  ( allots a new string and writes into that )
  0
  s" hello\nworld\n" over set-local0 escape-string/2
  14 assert-equals
  dup local0 assert-not-equals
  s" hello\\nworld\\n" assert-byte-string-equals/3
end

def test-escaped-strings
  test-escape-string-immeds
  test-escape-string/4
  test-escape-string/2
  test-unescape-string/4
  test-unescape-string/2
end
