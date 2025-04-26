DEFINED? assert UNLESS
  s" src/lib/assert.4th" load/2
THEN
DEFINED? reverse UNLESS
  s" src/lib/seq.4th" load/2
THEN

def test-reverse
  0
  1 2 3 4 5 here set-local0
  local0 4 reverse
  local0 2 3 4 5 4 assert-data

  local0 0 reverse
  local0 2 3 4 5 4 assert-data

  local0 1 reverse
  local0 2 3 4 5 4 assert-data

  local0 2 reverse
  local0 3 2 4 5 4 assert-data
end

def test-reverse-cells!
  0
  1 2 3 4 5 here set-local0
  6 local0 4 reverse-cells!
  6 assert-equals
  local0 2 3 4 5 4 assert-data

  6 local0 0 reverse-cells!
  6 assert-equals
  local0 2 3 4 5 4 assert-data

  6 local0 1 reverse-cells!
  6 assert-equals
  local0 2 3 4 5 4 assert-data

  6 local0 2 reverse-cells!
  6 assert-equals
  local0 3 2 4 5 4 assert-data
end

def test-reverse-into
  0 0
  1 2 3 4 5 here set-local0
  0 0 0 0 0 here set-local1
  6 local0 local1 4 reverse-into
  6 assert-equals
  local1 2 3 4 5 4 assert-data

  local1 5 0 fill-seq
  6 local0 local1 0 reverse-into
  6 assert-equals
  local1 0 0 0 0 4 assert-data

  local1 5 0 fill-seq
  6 local0 local1 1 reverse-into
  6 assert-equals
  local1 5 0 0 0 4 assert-data

  local1 5 0 fill-seq
  6 local0 local1 2 reverse-into
  6 assert-equals
  local1 4 5 0 0 4 assert-data
end

def test-reverse-bytes!
  0 " hello" set-local0
  local0 5 reverse-bytes!
  local0 s" olleh" assert-byte-string-equals/3
  local0 0 reverse-bytes!
  local0 s" olleh" assert-byte-string-equals/3
  local0 1 reverse-bytes!
  local0 s" olleh" assert-byte-string-equals/3
  local0 2 reverse-bytes!
  local0 s" loleh" assert-byte-string-equals/3
end

def test-seq
  test-reverse
  test-reverse-cells!
  test-reverse-into
  test-reverse-bytes!
end
