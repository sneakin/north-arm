def 0LL 0 0 return2 end
def -1LL -1 -1 return2 end
def 1LL 1 0 return2 end

def uint32->64
  0 return1
end

def int32->64
  arg0 negative? IF -1 ELSE 0 THEN return1
end

def int64-equals?
 arg3 arg1 equals? IF arg2 arg0 equals? ELSE false THEN 4 return1-n
end

def int64<
  arg2 arg0 int<
  IF true ELSE
    arg2 arg0 equals? IF arg3 arg1 uint< ELSE false THEN
  THEN 4 return1-n
end

def int64<=
  arg2 arg0 int<
  IF true ELSE
    arg2 arg0 equals? IF arg3 arg1 uint<= ELSE false THEN
  THEN 4 return1-n
end

def uint64<
  arg2 arg0 uint<
  IF true ELSE
    arg2 arg0 equals? IF arg3 arg1 uint< ELSE false THEN
  THEN 4 return1-n
end

def uint64<=
  arg2 arg0 uint<
  IF true ELSE
    arg2 arg0 equals? IF arg3 arg1 uint<= ELSE false THEN
  THEN 4 return1-n
end

0 [IF]
def uint64-addc ( alo ahi blo bhi -- lo hi carry )
  arg3 arg1 uint-addc
  arg2 arg0 uint-add3
  set-arg1 set-arg2 set-arg3 1 return0-n
end

def int64-addc ( alo ahi blo bhi -- lo hi carry )
  arg3 arg1 int-addc
  arg2 arg0 int-add3
  set-arg1 set-arg2 set-arg3 1 return0-n
end
[THEN]  

def uint64-add
  arg3 arg2 arg1 arg0 uint64-addc drop 4 return2-n
end

def int64-add
  arg3 arg2 arg1 arg0 int64-addc drop 4 return2-n
end

def int64-negate
  arg1 dup IF negate THEN
  arg0 CASE
    0 OF arg1 IF -1 ELSE 0 THEN ENDOF
    -1 OF arg1 IF 0 ELSE 1 THEN ENDOF
    negate 1 -
  ENDCASE
  2 return2-n
end

def abs-int64
  arg1 arg0 2dup 0LL int64< IF int64-negate THEN 2 return2-n
end

( Bit shifting: )

def int64-bsl ( lo hi shift -- lo hi )
  arg2 arg0 bsl
  arg0 32 int>= IF
    arg2 arg0 32 - bsl
  ELSE
    arg1 arg0 bsl
    arg2 32 arg0 - bsr logior
  THEN
  3 return2-n
end

def int64-bsr ( lo hi shift -- lo hi )
  arg0 32 int>= IF
    arg1 arg0 32 - bsr
  ELSE
    arg2 arg0 bsr
    arg1 32 arg0 - bsl logior
  THEN
  arg1 arg0 bsr
  3 return2-n
end

def int64-absr ( lo hi shift -- lo hi )
  arg0 32 int>= IF
    arg1 arg0 32 - absr
  ELSE
    arg2 arg0 bsr
    arg1 32 arg0 - bsl logior
  THEN
  arg1 arg0 absr
  3 return2-n
end


( Multiplication: )

def int-mulc ( a b -- lo hi )
  arg1 abs-int arg0 abs-int uint-mulc
  arg1 0 int< arg0 0 int< logxor IF int64-negate THEN
  2 return2-n
end

def uint64-mul ( alo ahi blo bhi -- lo hi )
  ( Like uint-mulc, but instead of half words this operates on whole words:
  ahi alo
  bhi blo

alo*blo
[ahi*blo + bhi*alo] << 32
ahi*bhi << 64

    0 2        0  2
    1 1        1 10
    ---        ----
    0 2        0 20
  0 2        0 2
0 0        0 0
0 0 2 2    0 0 2 20
)
  ( alo*blo ) arg3 arg1 uint-mulc
  ( ahi*blo + bhi*alo ) arg2 arg1 uint-mulc arg0 arg3 uint-mulc uint64-add
  ( ahi*bhi ) arg2 arg0 uint-mulc
  local0 local1 local2 + 4 return2-n 
end

def uint64-mulc ( alo ahi blo bhi -- lowest low high highest )
  ( alo*blo => xl xh ) arg3 arg1 uint-mulc
  ( ahi*blo + bhi*alo => yl yh yc ) arg2 arg1 uint-mulc arg0 arg3 uint-mulc uint64-addc
  ( ahi*bhi => zl zh ) arg2 arg0 uint-mulc
  local0
  ( xh+yl ) local1 local2 uint-addc
  ( c+yh+zl ) local3 5 localn uint-add3
  ( c+zh+yc ) 6 localn 4 localn uint-add3 drop
  set-arg0 set-arg1 set-arg2 set-arg3
end

def int64-mul ( alo ahi blo bhi -- lo hi )
  arg3 arg2 abs-int64 arg1 arg0 abs-int64 uint64-mul
  arg3 arg2 0LL int64<
  arg1 arg0 0LL int64<
  logxor IF int64-negate THEN
  4 return2-n
end

( Division: A...B... / C...

       __A/C.B/C mod B-b
  C... | A...B...
        -a...
         A-a.B...
         ????b...
             B-b.

✁---
           __A/CDB/CD mod B-b
  C...D... | A...B...
            -a...b...
             A-a.B...
                 b...
                 B-b.
A*X+B / C*X+D
A*X/[C*X+D] + B/[C*X+D]
A+B/X / C+D/X
A/[C+D/X] + B/[X*C+D]

✁---
      _____2_0023 r 3
 1000 | 2002 3003
        2000
           2 300
           2 000
             3003
             3000
                3

✁---
      _____2_3451 r 2
 1000 | 2345 1002
        2000
         345 1
         300 0
          45 10
          40 00
           5 100
           5 000
             1002
             1000
                2

✁---
      _____2_   1 r 2
 1000 | 2345 1002
        2000
         345
             1002
          45 10
          40 00
           5 100
           5 000
             1002
             1000
                2
)
def uint64-divmod32-quotient-bit ( nlo nhi denom shift -- qlo qhi modlo modhi )
  ( s" quotient bit" write-line/2 .s )
  arg0 0 int<= IF
    arg3 arg2 set-arg1 set-arg0
    0LL set-arg3 set-arg2
    return0
  THEN
  arg0 1 - set-arg0
  arg3 arg2 arg0 int64-bsr
  2dup arg1 uint32->64 uint64< IF
    2 dropn repeat-frame      
  ELSE
    arg3 shift
    arg1 uint32->64 int64-sub
    ( quotient bit )
    1 arg0 bsl set-arg3 0 set-arg2
    ( [N - denom] << [32 - shift] | N & mask )
    arg0 int64-bsl
    arg0 bit-mask 4 overn logand
    roll logior set-arg1 set-arg0
  THEN
end

def uint64-divmod32/4 ( bit alo ahi b -- bit nlo nhi mod )
  ( s" div: " write-string/2
  arg3 write-int space
  arg1 .h s" :" write-string/2 arg2 .h space arg0 .h nl )
  arg0 0 equals? IF ( todo error ) 0 set-arg0 0LL set-arg1 set-arg2 return0 THEN
  arg3 0 int< IF 0LL arg1 set-arg0 set-arg1 set-arg2 return0 THEN
  arg1 IF
    arg1 arg0 uint< IF
      ( s" less" write-line/2 )
      arg2 arg1 arg0 32 uint64-divmod32-quotient-bit
      ( s" <less" write-line/2 )
      arg3 1 - 3 overn 3 overn arg0 uint64-divmod32/4
      ( s" <<less" write-line/2 .s )
      set-arg0 6 overn logior set-arg1 6 overn logior set-arg2
    ELSE
      ( s" divide" write-line/2 )
      arg1 arg0 uint-divmod
      arg3 32 - arg2 3 overn arg0 uint64-divmod32/4
      ( s" <divide" write-line/2 .s )
      set-arg0 over set-arg2 5 overn set-arg1
    THEN
  ELSE
    arg2 arg0 uint-divmod set-arg0 set-arg2
  THEN return0
end

def uint64-divmod32 ( alo ahi b -- nlo nhi mod )
  64 arg2 arg1 arg0 uint64-divmod32/4 set-arg0 set-arg1 set-arg2
end

def uint64-div32 ( alo ahi b -- lo hi )
  arg2 arg1 arg0 uint64-divmod32 drop 3 return2-n
end

def int64-div32 ( alo ahi b -- lo hi )
  arg2 arg1 abs-int64 arg0 abs-int uint64-div32
  arg2 arg1 0LL int64<
  arg0 0 int<
  logxor IF int64-negate THEN 3 return2-n
end

def uint64-div ( alo ahi blo bhi -- qlo qhi )
  arg0 IF
    arg3 arg2 arg0 uint64-div32 32 int64-bsr
  ELSE
    arg3 arg2 arg1 uint64-div32
  THEN 4 return2-n
end

def uint64-divmod ( alo ahi blo bhi -- qlo qhi mlo mhi )
  arg0 IF
    arg3 arg2 arg1 arg0 uint64-div
    arg3 arg2 4 overn 4 overn arg1 arg0 int64-mul int64-sub
  ELSE
    arg3 arg2 arg1 uint64-divmod32 0
  THEN set-arg0 set-arg1 set-arg2 set-arg3
end

( Exponentiation: )

def int64-pow32-loop ( lo hi n rlo rhi -- lo hi )
  arg2 0 equals? IF arg1 arg0 5 return2-n THEN
  arg1 arg0 4 argn arg3 int64-mul set-arg0 set-arg1
  arg2 1 - set-arg2
  repeat-frame
end

def int64-pow32 ( lo hi n -- lo hi )
  arg2 arg1 arg0 1LL int64-pow32-loop 3 return2-n
end

( String conversion: )

def string->uint64/6 ( str len radix lo hi n -- lo hi )
  arg0 4 argn uint< IF
    5 argn arg0 string-peek
    dup IF
      char-to-digit
      dup arg3 int< IF
	0 arg2 arg1 arg3 0 int64-mul int64-add set-arg1 set-arg2
	arg0 1 + set-arg0 repeat-frame
      THEN
    THEN
  THEN arg2 arg1 6 return2-n
end

def string->uint64/2 ( str len -- lo hi )
  arg1 0 parse-int-base
  arg1 arg0 4 overn 0 0 6 overn string->uint64/6 2 return2-n
end

def string->int64/2 ( str len -- lo hi )
  arg1 0 string-peek minus-sign?
  dup IF arg1 1 + arg0 1 - ELSE arg1 arg0 THEN string->uint64/2
  local0 IF int64-negate THEN
  2 return2-n
end
