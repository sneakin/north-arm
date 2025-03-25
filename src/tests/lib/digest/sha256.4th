DEFINED? make-sha256-state UNLESS
  " src/lib/digest/sha256.4th" load
THEN

DEFINED? assert UNLESS
  " src/lib/assert.4th" load
THEN

def assert-sha256 ( sha256-state str len -- )
  128 stack-allot-zero
  dup 128 arg2 sha256->string/3 drop
  arg1 arg0 assert-byte-string-equals/3
  3 return0-n
end

def test-sha256-zero-no-rounds
  0 0
  make-sha256-state set-local0
  16 stack-allot-zero-seq set-local1
  local0 sha256-begin
  local0 sha256-end
  local0 s" E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855" assert-sha256
end

def test-sha256-zero-one-round
  0 0
  make-sha256-state set-local0
  16 stack-allot-zero-seq set-local1
  local0 sha256-begin
  local1 local0 sha256-update-step
  local0 sha256-end
  local0 s" C18F6586CCBCA7EDCFBD28E8EF80BDF994B95C0DB675E24221A473A304E3E747" assert-sha256
end

def test-sha256-test11
  0 0
  make-sha256-state set-local0
  16 stack-allot-zero-seq set-local1
  local1 16 cell-size * 0x0B fill
  local0 sha256-begin
  local1 local0 sha256-update-step
  local0 sha256-end
  local0 s" 30B1BFA3C5D70AEBC2C7AE848D1F0DADF6ACA18FEFD3D5B423897B0FCE1DA20D" assert-sha256
end

def test-sha256-numbers
  0 0
  make-sha256-state set-local0
  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 here set-local1
  local0 sha256-begin
  local1 local0 sha256-update-step
  local1 local0 sha256-update-step
  local0 sha256-end
  local0 s" 0C2CA5EBFF68E861486D67DDDC7886B38E92E83C713CF609AFEA829549E1B016" assert-sha256
end

def test-sha256-string
  0 0
  make-sha256-state set-local0
  " hello
" set-local1
  local0 sha256-begin
  local1 6 local0 sha256-update
  local0 sha256-end
  local0 s" 5891B5B522D5DF086D0FF0B110FBD9D21BB4FC7163AF34D08286A2E846F6BE03" assert-sha256
end

def test-sha256-zero-string
  0 0
  make-sha256-state set-local0
  " " set-local1
  local0 sha256-begin
  local1 0 local0 sha256-update
  local0 sha256-end
  local0 s" E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855" assert-sha256
end

def test-sha256-test1
  0 0
  make-sha256-state set-local0
  " abc" set-local1
  local0 sha256-begin
  local1 3 local0 sha256-update
  local0 sha256-end
  local0 s" BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD" assert-sha256
end

def test-sha256-test1-rev
  0 0
  make-sha256-state set-local0
  " cba" set-local1
  local0 sha256-begin
  local1 3 local0 sha256-update
  local0 sha256-end
  local0 s" 6D970874D0DB767A7058798973F22CF6589601EDAB57996312F2EF7B56E5584D" assert-sha256
end

" 0123456701234567012345670123456701234567012345670123456701234567" string-const> SHA-TEST4

def test-sha256-test4
  0 0
  make-sha256-state set-local0
  local0 sha256-begin
  SHA-TEST4 SHA-TEST4 string-length 10 local0 sha256-update-rounds
  local0 sha256-end
  local0 s" 594847328451BDFA85056225462CC1D867D877FB388DF0CE35F25AB5562BFBB5" assert-sha256
end

def test-sha256-buffer-too-large-by-byte
  0 0
  make-sha256-state set-local0
  local0 sha256-begin
  s" 000000000000000000000000000000000000000000000000000000000000000" local0 sha256-update
  local0 sha256-end
  local0 s" C7DC2D25E306355C97AF916E8D50B27A948506A74C6B2DD1B29E2B63D0A3AA8C" assert-sha256
end

def test-sha256-buffer-too-large-by-uint16
  0 0
  make-sha256-state set-local0
  local0 sha256-begin
  s" 000000000000000000000000000000000000000000000000000000000000" local0 sha256-update
  local0 sha256-end
  local0 s" EB3E68A9F0448BBA8E01933CF1CDDF2CEA114CDBBB41B122B8219482B27211DF" assert-sha256
end

def test-sha256-buffer-too-large-by-uint32
  0 0
  make-sha256-state set-local0
  local0 sha256-begin
  s" 00000000000000000000000000000000000000000000000000000000" local0 sha256-update
  local0 sha256-end
  local0 s" BD03AC1428F0EA86F4B83A731FFC7967BB82866D8545322F888D2F6E857FFC18" assert-sha256
end

def test-sha256-buffer-too-large-by-uint32+byte
  0 0
  make-sha256-state set-local0
  local0 sha256-begin
  s" 000000000000000000000000000000000000000000000000000000" local0 sha256-update
  local0 sha256-end
  local0 s" 5E348A8A500ECF192338852A7252EC59B575F5688D8D18E93BA5BB581A980D32" assert-sha256
end

def test-sha256-code-hashes/4 ( mem-ptr mem-size block-size n -- )
  arg1 arg0 *
  dup arg2 uint< IF
    dup write-hex-uint space
    arg3 + arg1 sha256-hash-string write-line/2
    arg0 1 + set-arg0 drop-locals repeat-frame
  ELSE 4 return0-n
  THEN
end

def test-sha256-code-hashes ( block-size -- )
  ( A manual test that's paired with ~scripts/test/code-hashes.sh~. )
  cs *program-size* arg0 0 test-sha256-code-hashes/4
  1 return0-n
end

def test-sha256
  test-sha256-zero-no-rounds
  test-sha256-zero-one-round
  test-sha256-test11
  test-sha256-numbers
  test-sha256-string
  test-sha256-zero-string
  test-sha256-test1
  test-sha256-test1-rev
  test-sha256-test4
  test-sha256-buffer-too-large-by-byte
  test-sha256-buffer-too-large-by-uint16
  test-sha256-buffer-too-large-by-uint32
  test-sha256-buffer-too-large-by-uint32+byte
end
