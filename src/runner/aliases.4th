( Cell & Op Constants: )

cell-size defconst> cell-size
-op-size defconst> op-size
-op-mask defconst> op-mask

( Shorthands: )

defalias> @ peek
defalias> ! poke

( Math aliases: )

defalias> + int-add
defalias> - int-sub
defalias> * int-mul
defalias> / int-div

( Debug helpers: )

defcol break
  int32 0x47 peek
endcol
