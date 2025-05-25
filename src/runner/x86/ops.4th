push-asm-mark

32 x86-bits !

4 const> ptr-size
ebp const> fp-reg
ecx const> cs-reg
edx const> ds-reg
edi const> eval-ip
esi const> this-word-reg

: label>
  dhere const>
;

: emit-op-call dict-entry-code @ dhere to-out-addr - 1 - call ;
: jmp-disp-size signed-byte? IF 1 ELSE 16bit? IF 2 ELSE 4 THEN THEN ;
: emit-jump dhere - dup jmp-disp-size - 1 - jmp# ;
: emit-op-jump dict-entry-code @ from-out-addr cell-size + emit-jump ;

pop-mark

( Execution: )


defop next
  -op-size eval-ip 0 modrr add#
  0 eval-ip this-word-reg modrm+ movr
  cs-reg this-word-reg modrr addr
  0 dict-entry-code this-word-reg ebx modrm+ movr
  cell-size cs-reg ebx x1 sib modrm-sib ebx modrm+ lea
  ebx 0 modrr callm
  out' next emit-op-jump
endop

defop exec-abs
  eax this-word-reg modrr movr
  ebx pop
  eax pop
  ebx push
  ( 0 esp modrm-sib x1 sib modrm-sib ebx modrm+ movr )
  ( cell-size esp modrm-sib x1 sib modrm-sib eax modrm+ movr )
  ( cell-size esp modrm-sib x1 sib modrm-sib ebx modrm+ movm )
  ( cell-size esp 0 modrr add# )
  0 dict-entry-code this-word-reg ebx modrm+ movr
  cell-size cs-reg ebx x1 sib modrm-sib ebx modrm+ lea
  ebx 0 modrr jmpr
endop

defop exec
  cs-reg eax modrr addr
  out' exec-abs emit-op-jump
endop

defop nop
  ret
endop


( Calls: )

defop enter
  0 dict-entry-data eax ebx modrm+ movr
  eval-ip eax modrr movr
  cell-size negate cs-reg ebx x1 sib modrm-sib eval-ip modrm+ lea
  out' next emit-op-jump
endop
  
defop exit
  eax eval-ip modrr movr
  eax pop ( eat the exit op's ret addr )
  eax pop ( so we can use do-col's )
  ret
endop

defop do-col
  eax push
  this-word-reg eax modrr movr
  out' enter emit-op-jump
endop


( Control flow: )

defop if-jump
  0 cell-size esp modrm-sib x1 sib modrm-sib 0 modrm+ cmp#
  2 jz
  2 eax eax modrr rol#
  eax eval-ip modrr addr
  ebx pop
  cell-size esp 0 modrr add#
  eax pop
  ebx push
  ret
endop

defop unless-jump
  0 cell-size esp modrm-sib x1 sib modrm-sib 0 modrm+ cmp#
  2 jnz
  2 eax eax modrr rol#
  eax eval-ip modrr addr
  ebx pop
  cell-size esp 0 modrr add#
  eax pop
  ebx push
  ret
endop

defop jump
  2 eax eax modrr rol#
  eax eval-ip modrr addr
  ebx pop
  eax pop
  ebx push
  ret
endop

defop jump-cs
  eax eval-ip modrr movr
  cs-reg eval-ip modrr addr
  ebx pop
  eax pop
  ebx push
  ret
endop

defop jump-rel
  2 eax eax modrr rol#
  eax eval-ip modrr addr
  ebx pop
  eax pop
  ebx push
  ret
endop



( Stack manipulations: )

defop drop ( a -- )
  ebx pop
  eax pop
  ebx push
  ret
endop

defop dropn ( argn ... n -- argn )
  ebx pop
  2 eax eax modrr rol#
  eax esp modrr addr
  ebx push
  ret
endop

defop dup ( a -- a a )
  ebx pop
  eax push
  ebx push
  ret
endop

defop 2dup ( a b -- a b a b )
  ebx pop
  eax push
  eax push
  ebx push
  cell-size 3 * esp modrm-sib x1 sib ebx modrm+x movr
  cell-size esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop over ( a b ++ a )
  ebx pop
  eax push
  cell-size esp modrm-sib x1 sib eax modrm+x movm
  ebx push
  ret
endop

defop overn ( n -- value )
  ebx pop
  2 eax eax modrr rol#
  0 esp eax x1 sib modrm-sib eax modrm+ movr
  ebx push
  ret
endop

defop set-overn ( value n -- )
  cell-size esp modrm-sib x1 sib ebx modrm+x movr
  2 eax eax modrr rol#
  cell-size 3 * esp eax x1 sib modrm-sib ebx modrm+ movm
  ebx pop
  cell-size esp 0 modrr add#
  eax pop
  ebx push
  ret
endop

defop swap ( a b -- b a )
  cell-size esp modrm-sib x1 sib ebx modrm+x movr
  cell-size esp modrm-sib x1 sib eax modrm+x movm
  ebx eax modrr movr
  ret
endop

defop 2swap ( a b c d -- c d a b )
  ( d <-> b )
  cell-size esp modrm-sib x1 sib ebx modrm+x movr
  cell-size 3 * esp modrm-sib x1 sib eax modrm+x movm
  ebx eax modrr movr
  ( c <-> a )
  cell-size 2 * esp modrm-sib x1 sib ebx modrm+x movr
  cell-size 4 * esp modrm-sib x1 sib ecx modrm+x movr
  cell-size 4 * esp modrm-sib x1 sib ebx modrm+x movm
  cell-size 2 * esp modrm-sib x1 sib ecx modrm+x movm
  ret
endop

defop swapn ( Xn ... v n -- v ... Xn )
endop

defop rot ( a b c -- c b a )
  cell-size 2 * esp modrm-sib x1 sib ebx modrm+x movr
  cell-size 2 * esp modrm-sib x1 sib eax modrm+x movm
  ebx eax modrr movr
  ret
endop

defop here ( ++ sp )
  ebx pop
  eax push
  esp eax modrr movr
  ebx push
  ret
endop

defop move ( sp -- )
  ebx pop
  eax esp modrr movr
  ebx push
  ret
endop

defop stack-allot ( bytes -- ... pointer )
  ebx pop
  eax esp modrr addr
  ( esp push )
  esp eax modrr movr
  ebx push
  ret
endop


( Memory manipulation: )

defop peek ( pointer -- value )
  eax eax modrm movr
  ret
endop

defop peek-byte ( pointer -- byte )
  eax al modrm movzx
  ret
endop

defop peek-short ( pointer -- byte )
  eax ax modrm movzx
  ret
endop

defop peek-off ( offset base -- value )
  cell-size esp modrm-sib x1 sib ebx modrm+x movr
  0 eax ebx x1 sib eax modrmx movr
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop peek-off-byte ( offset base -- byte )
  cell-size esp modrm-sib x1 sib ebx modrm+x movr
  0 eax ebx x1 sib eax modrmx movzx
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop poke ( value pointer -- )
  cell-size esp modrm-sib x1 sib ebx modrm+x movr
  eax ebx modrm movm
  ebx pop
  eax pop
  ebx push
  ret
endop

defop poke-byte ( byte pointer -- )
  cell-size esp modrm-sib x1 sib ebx modrm+x movr
  eax bl modrm movm
  ebx pop
  eax pop
  ebx push
  ret
endop

defop poke-short ( byte pointer -- )
  cell-size esp modrm-sib x1 sib ebx modrm+x movr
  eax bx modrm movm
  ebx pop
  eax pop
  ebx push
  ret
endop

defop poke-off ( value offset base -- )
  cell-size esp modrm-sib x1 sib eax modrm+x addr
  cell-size 2 * esp modrm-sib x1 sib ebx modrm+x movr
  eax ebx modrm movm
  ebx pop
  cell-size 2 * esp 0 modrr add#
  eax pop
  ebx push
  ret
endop

defop poke-off-byte ( byte offset base -- )
  cell-size esp modrm-sib x1 sib eax modrm+x addr
  cell-size 2 * esp modrm-sib x1 sib ebx modrm+x movr
  eax bl modrm movm
  ebx pop
  cell-size 2 * esp 0 modrr add#
  eax pop
  ebx push
  ret
endop


( Data literals: )

defop int32
  ebx pop
  eax push
  ebx push
  -op-size eval-ip 0 modrr add#
  eval-ip eax modrm movr
  ret
endop

defop offset32
  ebx pop
  eax push
  ebx push
  -op-size eval-ip 0 modrr add#
  eval-ip eax modrm movr
  cs-reg eax modrr addr
  ret
endop

defalias> uint32 int32
defalias> literal offset32
defalias> pointer offset32
defalias> string pointer
defalias> cstring string


( Code words: )

defop do-inplace-var
  ret
endop

defop do-data-var
  ret
endop

defalias> do-var do-inplace-var

defop do-const
  ret
endop

defop do-const-offset
  ret
endop


( Interpreter state: )

defop cs
  ebx pop
  eax push
  ebx push
  cs-reg eax modrr movr
  ret
endop

defop set-cs!
  eax cs-reg modrr movr
  ebx pop
  eax pop
  ebx push
  ret
endop

defop ds
  ebx pop
  eax push
  ebx push
  ds-reg eax modrr movr
  ret
endop

defop set-ds!
  eax ds-reg modrr movr
  ebx pop
  eax pop
  ebx push
  ret
endop


( Integers: )

defop bsl
  cl eax modrr movr
  ebx pop
  eax pop
  eax eax modrr shlcl
  ebx push
  ret
endop

defop bsr
  cl eax modrr movr
  ebx pop
  eax pop
  eax eax modrr shrcl
  ebx push
  ret
endop

defop absr
  cl eax modrr movr
  ebx pop
  eax pop
  eax eax modrr sarcl
  ebx push
  ret
endop

defop negate
  eax eax modrr neg
  ret
endop

defop int-add
  cell-size esp modrm-sib x1 sib eax modrm+x addr
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop uint-addc
endop

defop uint-add3
endop

defop int-mul
  cell-size esp modrm-sib x1 sib eax modrm+x imulr
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop int-sub
  cell-size esp modrm-sib x1 sib eax modrm+x subr
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop uint-divmod
endop

defop uint-div
  cell-size esp modrm-sib x1 sib eax modrm+x div
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop uint-mod
endop

defop int-divmod
endop

defop int-div
  cell-size esp modrm-sib x1 sib eax modrm+x idiv
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop int-mod
endop

( Logic: )

defop logand
  cell-size esp modrm-sib x1 sib eax modrm+x andr
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop logior
  cell-size esp modrm-sib x1 sib eax modrm+x orr
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop logxor
  cell-size esp modrm-sib x1 sib eax modrm+x xorr
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop lognot
  eax eax modrr x86:not
  ret
endop


( Comparisons: )

push-asm-mark

( fixme maybe inverted )
: emit-truther ( jump-word -- )
  0 eax mov#
  5 swap exec-abs
  -1 eax mov#
;

pop-mark

defop null?
  eax push
  0 eax eax modrm cmp#
  ' jne emit-truther
  ret
endop

defop equals?
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  ' jne emit-truther
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop int<
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  ' jge emit-truther
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop int<=
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  ' jg emit-truther
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop int>
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  ' jle emit-truther
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop int>=
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  ' jl emit-truther
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop int<=>
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  0 eax mov#
  5 jge
  -1 eax mov#
  5 jle
  1 eax mov#
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop uint<
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  ' jbe emit-truther
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop uint>
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  ' jae emit-truther
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop uint<=
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  ' jb emit-truther
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop uint>=
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  ' ja emit-truther
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop

defop uint<=>
  cell-size esp modrm-sib x1 sib eax modrm+x cmpr
  0 eax mov#
  5 jae
  -1 eax mov#
  5 jbe
  1 eax mov#
  ebx pop
  0 esp modrm-sib x1 sib ebx modrm+x movm
  ret
endop


defop break
endop
