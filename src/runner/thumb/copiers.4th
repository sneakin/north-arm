( Memory copying assembler routines: )

target-aarch32? IF
  s" src/runner/thumb/copiers/aarch32.4th" load/2
THEN
target-thumb? IF
  s" src/runner/thumb/copiers/thumb.4th" load/2 
THEN

( copy-up:  Copies from low to high memory. )

push-asm-mark

: emit-copy-up-loop ( bytes register ++ )
  over r0 cmp# ,ins
  6 bcc-ins ,ins
  r2 over ldmia ,ins
  r1 over stmia ,ins
  over r0 sub# ,ins ( fixme compare w/ precomputed ending )
  -14 branch-ins ,ins
;

pop-mark

( Copies up by 4 bytes and then by 1 byte. )
defop copy-cells-up ( src dest num-bytes -- src+#b dest+#b num-bytes-left )
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set pushr ,ins
  ( copy by 16 bytes )
  cell-size 4 mult
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set
  emit-copy-up-loop
  ( 12 bytes )
  cell-size 3 mult
  0 r4 bit-set r5 bit-set r6 bit-set
  emit-copy-up-loop
  ( 8 bytes )
  cell-size 2 mult
  0 r4 bit-set r5 bit-set
  emit-copy-up-loop
  ( 4 bytes )
  cell-size
  0 r4 bit-set
  emit-copy-up-loop
  ( and then 1 byte )
  emit-copy-up-1
  ( finish up )
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set popr ,ins
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

( Copies bytes from low to high memory. )
def copy-up ( src dest num-bytes -- bytes-left )
  ( misaligned src & dest copy by one cell and then byte at a time )
  arg2 arg1 arg0 
  arg2 3 logand arg1 3 logand logior IF
    copy-up-4
  ELSE
    ( aligned get copied in multiples )
    copy-cells-up
  THEN 3 return1-n
end

( Copy down: )

defop copy-cells-down ( src dest num-bytes -- src+#b dest+#b num-bytes-left )
  0 r1 bit-set r2 bit-set popr ,ins ( r1 dest, r2 src, r0 counter )
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set pushr ,ins
  ( by 16 bytes )
  cell-size 4 mult
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set
  emit-copy-down-loop
  ( by 12 bytes )
  cell-size 3 mult
  0 r4 bit-set r5 bit-set r6 bit-set
  emit-copy-down-loop
  ( by 8 bytes )
  cell-size 2 mult
  0 r4 bit-set r5 bit-set
  emit-copy-down-loop
  ( by 4 bytes and then 1 byte )
  emit-copy-down-4
  emit-copy-down-1
  ( finish up )
  0 r4 bit-set r5 bit-set r6 bit-set r7 bit-set popr ,ins
  0 r1 bit-set r2 bit-set pushr ,ins
  emit-next
endop

( Copies bytes from high to low memory. )
def copy-down ( src dest num-bytes -- bytes-left )
  arg2 arg0 int-add
  arg1 arg0 int-add
  arg0
  ( misaligned src & dest copy by one cell and then byte at a time )
  3 overn 3 logand 3 overn 3 logand logior IF
    copy-down-4
  ELSE
    ( aligned get copied in multiples )
    copy-cells-down
  THEN 3 return1-n
end
