( Output memory offseting: )

dhere var> out-origin

: to-out-addr out-origin peek - ;
: from-out-addr out-origin peek + ;

( fixme duplicated in cross/words.4th )
( todo zero unused memory? )
: align-code ( alignment -- )
  dhere to-out-addr swap pad-addr from-out-addr
  dhere over over - cell-size / 0 fill-seq
  dmove
;

: ,seq-pointer/3 ( seq size n -- )
  2dup int> IF
    3 overn over seq-peek
    dup IF to-out-addr THEN
    over cell-size * dhere + uint32!
    1 + loop
  ELSE drop
       cell-size *
       dhere 2dup + dmove
       shift 2 dropn
  THEN
;

: ,seq-pointer ( seq n -- )
  0 ,seq-pointer/3
;
