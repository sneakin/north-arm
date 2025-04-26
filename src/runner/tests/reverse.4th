DEFINED? assert UNLESS
  s" src/lib/assert.4th" load/2
THEN

def test-reverse-bytes
  0 0
  " hello!" set-local0
  16 stack-allot-zero set-local1

  local0 5 + local1 5 reverse-bytes
  local1 s" !olle" assert-byte-string-equals/3

  local0 5 + local1 6 reverse-bytes
  local1 s" !olleh" assert-byte-string-equals/3
end

def test-reverse-cells
  0 0
  0 1 2 3 4 here set-local0
  0 0 0 0 0 here set-local1

  local0 3 cell-size * + local1 3 reverse-cells
  local1 1 2 3 0 4 assert-data

  local0 3 cell-size * + local1 4 reverse-cells
  local1 1 2 3 4 4 assert-data

  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 here set-local0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 here set-local1

  local0 17 cell-size * + local1 8 reverse-cells
  local1 1 2 3 4 5 6 7 8 8 assert-data

  local0 17 cell-size * + local1 18 reverse-cells
  local1 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 18 assert-data
end

def test-reverse-cells!
  0
  0 0 0 0 1 2 3 4 5 6 7 8 here set-local0

  local0 3 reverse-cells!
  local0 6 7 8 3 assert-data

  local0 4 reverse-cells!
  local0 5 8 7 6 4 assert-data

  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 here set-local0
  local0 18 reverse-cells!
  local0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 18 assert-data
end

def test-reverse-bytes!
  0 " hello" set-local0
  local0 5 reverse-bytes!
  local0 s" olleh" assert-byte-string-equals/3
end

def test-reverse
  test-reverse-bytes
  test-reverse-bytes!
  test-reverse-cells
  test-reverse-cells!
end
