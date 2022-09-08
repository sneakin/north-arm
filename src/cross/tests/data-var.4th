s[ src/lib/platform-target.4th ] load-list

def target-thumb? false return1 end

NORTH-PLATFORM platform-target-bash? [IF]
4 const> -op-size

: error-int error-string ;

s[
   src/lib/byte-data.4th
   src/cross/words.4th
   src/cross/iwords.4th
   src/cross/owords.4th
] load-list

dhere set-out-origin
[ELSE]
s[ src/interp/boot/cross.4th
] load-list

alias> seq<uint32>-peek seq-peek

dhere out-origin !
[THEN]

s[ src/cross/defining/op.4th ] load-list

defop do-data-var
endop

defop do-inplace-var
endop

s[
   src/cross/defining/variables.4th
   src/cross/output/data-vars.4th
   src/lib/assert.4th
] load-list

0x123 def-data-var> x
0x456 def-data-var> y
0x789 def-data-var> z


def test-out-does-data-var?
  0 " test-word"  make-dict-entry set-local0
  ( 123 local0 does-data-var
  local0 out-does-data-var? assert-not )
  123 local0 does-inplace-var
  local0 out-does-data-var? assert-not
  1234 local0 does-def-data-var
  local0 out-does-data-var? assert
end

def test-data-var-init-values
  0 " test-word" make-dict-entry set-local0
  123 local0 does-def-data-var
  local0 0 from-out-addr data-var-init-values/2
  peek-next-def-data-var-slot ( has to work in bash too )
  assert-equals 123 assert-equals
end

def test-write-variable-data
  dhere
  0 from-out-addr out-dict write-variable-data
  dup local0 assert-equals
  local0 0 seq<uint32>-peek 3 assert-equals
  local0 1 seq<uint32>-peek 0x123 0 + assert-equals ( 0 + to force numeric conversion in Bash )
  local0 2 seq<uint32>-peek 0x456 0 + assert-equals
  local0 3 seq<uint32>-peek 0x789 0 + assert-equals
end

def test-data-vars
  test-out-does-data-var?
  test-data-var-init-values
  test-write-variable-data
end
