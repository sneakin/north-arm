( 64 bit integer output: )

def digit-count-int64 ( lo hi radix -- digits )
  arg1 0 equals? IF
    arg2 arg0 digit-count
  ELSE
    arg1 arg0 digit-count -1 arg0 digit-count +
  THEN 3 return1-n
end

def uint64->string/6 ( padding out-str out-size lo hi radix n -- out-str length )
  arg0 0 int<= IF 5 argn 4 argn 6 return2-n THEN
  arg0 1 - set-arg0
  arg3 arg2 arg1 uint64-divmod32
  arg0 0 equals? over 0 equals? and IF drop 6 argn ELSE ascii-digit THEN
  5 argn arg0 string-poke
  2dup 0LL int64-equals? IF 5 argn arg0 + 4 argn arg0 - 6 return2-n THEN
  set-arg2 set-arg3
  repeat-frame
end

def uint64->string/3 ( lo hi radix -- out-str length )
  arg2 arg1 arg0 digit-count-int64
  dup 1 + stack-allot
  32 over local0 arg2 arg1 arg0 local0 uint64->string/6
  2dup null-terminate
  exit-frame
end

def int64->string/3 ( lo hi radix -- out-str length )
  arg2 arg1 0LL int64<
  arg2 arg1 arg0 digit-count-int64
  dup 2 + stack-allot
  32 over 1 + local1
  arg2 arg1 local0 IF int64-negate THEN
  arg0 local1 uint64->string/6
  2dup null-terminate
  local0 IF
    1 +
    swap 1 - swap
    0x2D 3 overn 0 string-poke
  THEN
  exit-frame
end

def write-split-uint64 ( lo hi -- )
  arg0 write-uint
  s" :" write-string/2
  arg1 write-uint
  2 return0-n
end

def write-split-hex-uint64 ( lo hi -- )
  output-base @ hex
  arg1 arg0 write-split-uint64
  local0 output-base !
  2 return0-n
end

def write-hex-uint64 ( lo hi -- )
  arg0 IF arg1 arg0 16 uint64->string/3 write-string/2
       ELSE arg1 write-hex-uint
       THEN 2 return0-n
end

def write-uint64 ( lo hi -- )
  arg0 IF arg1 arg0 output-base @ uint64->string/3 write-string/2
       ELSE arg1 write-uint
       THEN
end

def write-int64 ( lo hi -- )
  arg1 arg0 output-base @ int64->string/3 write-string/2
  2 return0-n
end

def write-hex-int64 ( lo hi -- )
  output-base @ hex
  arg1 arg0 write-int64
  local0 output-base !
  2 return0-n
end

defalias> .Q write-uint64
defalias> .q write-int64
defalias> .Qh write-hex-uint64
defalias> .qh write-hex-int64

