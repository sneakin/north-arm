( Thumb2 divmod, divide and then multiply and subtract for the remainder: )

defcol int-divmod-v2
  rot swap
  2dup int-div-v2 ( num den quot )
  rot swap 3 overn int-mul int-sub ( abs-int )
  swap rot
endcol

defcol uint-divmod-v2
  rot swap
  2dup uint-div-v2 ( num den quot )
  rot swap 3 overn int-mul int-sub
  swap rot
endcol
