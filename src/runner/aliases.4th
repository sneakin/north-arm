( Shorthands: )

defalias> @ peek
defalias> ! poke

( Math aliases: )

defalias> + int-add
defalias> - int-sub
defalias> * int-mul
( todo needs to update w/ hard & soft; trampoline )
defalias> / int-div
defalias> mod int-mod
defalias> divmod int-divmod

( Debug helpers: )

defcol break
  int32 0x47 peek
endcol
