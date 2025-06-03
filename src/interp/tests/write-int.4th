require[ src/lib/assert.4th ]

0x12345
0x1
0x0
0x1000
0x1010
0x1FEEDDCC
0xFFEEDDCC
0x12
-0x12
0x5499B42C
-0x5499B42C
0xC499B42C
-0xC499B42C
4294967295
here const> test-numbers
14 const> test-numbers-size

2 3 5 64 36 8 10 16 here const> test-bases
8 const> test-bases-size

def test-write-fn ( radix n fn -- )
  output-base peek
  arg2 output-base poke
  space arg1 arg0 exec-abs
  local0 output-base poke
  3 return0-n
end

def space+write-uint
  space arg0 write-uint
end

def test-write-fn-for ( n fn  -- )
  0
  ' test-write-fn arg1 arg0 2 partial-first-n set-local0
  arg1 write-int
  test-bases test-bases-size 0 local0 map-seq-n/4
  nl
  1 return0-n
end

def test-write-fn
  0 ' test-write-fn-for arg0 partial-first set-local0
  test-numbers test-numbers-size 0 local0 map-seq-n/4
  1 return0-n
end

def test-write-uint
  ' write-uint test-write-fn
end

def test-write-int
  ' write-int test-write-fn
end

def test-writers
  10 write-int
  test-bases test-bases-size 0 ' space+write-uint map-seq-n/4
  
  nl s" Unsigned" write-line/2
  test-write-uint
  nl s" Signed" write-line/2
  test-write-int

  true output-number-prefix !
  nl s" Prefix Unsigned" write-line/2
  test-write-uint
  nl s" Prefixed Signed" write-line/2
  test-write-int
  false output-number-prefix !
end
