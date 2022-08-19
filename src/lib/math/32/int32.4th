( Multiplication:

  AAAA aaaa
  BBBB bbbb
                       aaaa*bbbb
     [AAAA*bbbb + BBBB*aaaa]
 AAAA*BBBB 

✁---
        0x1000 0000
          3000 2000

     2000 0000 0000
3000 0000 0000
3000 2000 0000 0000

✁---
          FFFF FFFF
          FFFF FFFF

          FFFE 0001  <- a*b
   1 FFFC 0002       <- A*b+a*B: FFFE 0001 + FFFE 0001
FFFE 0001            <- A*B
        1 0000 0001  <- a*b + [A*b+a*B]<<16      
FFFF FFFE            <- A*B + [A*b+a*B]>>16 + carry_2 + carry_1<<16

ffff fffe 0000 0001

✁---
          7fff ffff
                  3

             2 fffd
        1 7ffd
0000 0000
        1 7fff fffd
)
def uint-mulc ( a b -- lo hi )
  ( todo less work doing nothing or calculating this log? )
  arg1 badlog2-uint arg0 badlog2-uint int-add 31 int>= IF
    ( a*b ) arg1 0xFFFF logand arg0 0xFFFF logand int-mul
    ( A*B ) arg1 16 bsr arg0 16 bsr int-mul
    ( A*b ) arg1 16 bsr arg0 0xFFFF logand int-mul
    ( a*B ) arg1 0xFFFF logand arg0 16 bsr int-mul
    ( A*b+a*B, carry_1 ) uint-addc
    ( lo, carry_2 ) local0 local2 0xFFFF logand 16 bsl uint-addc
    ( hi ) local1 local2 16 bsr uint-add3 drop local3 16 bsl uint-addc drop
  ELSE
    arg1 arg0 int-mul 0
  THEN 2 return2-n
end
