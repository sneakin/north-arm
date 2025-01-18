( Standard Forth return stack words. )

defcol r@ ( R:value -- R:value value )
  return-stack @ @ swap
endcol

defcol r! ( R:value new-value -- R:new-value )
  swap return-stack @ !
endcol

defcol >r ( value -- R:value )
  ( return-stack cell-size inc!/2 )
  return-stack @ cell-size + return-stack !
  swap r!
endcol

defcol rdrop ( R:value -- )
  ( return-stack cell-size dec!/2 )
  return-stack @ cell-size - return-stack !
endcol

defcol rdropn ( R_n...:value n -- )
  return-stack @ roll cell-size * - return-stack !
endcol

defcol r> ( R:a -- a )
  r@ swap rdrop
endcol

defcol rdup ( R:value -- R:value R:value )
  r@ >r
endcol

defcol rswap ( R:a R:b -- R:b R:a )
  r> r> swap >r >r
endcol

defcol rover ( R_n:value n -- value )
  return-stack @ roll cell-size * - @ swap
endcol

alias> rpick rover

defcol rover! ( R_n:value new-value n -- R_n:new-value )
  return-stack @ roll cell-size * - swap shift !
endcol

def .r-print-fn ( state return-address -- state )
  arg0 dup pointer? and IF
    arg0 op-size - @
    cs + dict dict-contains?/2 IF
      drop dict-entry-name @ cs + write-string
    ELSE drop write-hex-uint
    THEN
  ELSE arg0 write-hex-uint
  THEN space
  arg1 2 return1-n
end

def .r
  ( Print outs the return stack. )
  s" Return-stack:" write-line/2
  *return-stack-base* @ return-stack @ over - cell-size +
  2dup cmemdump
  cell/ 0 ' .r-print-fn map-seq-n/4 nl
end immediate-as [.r]