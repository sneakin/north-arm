defcol parent-frame
  swap peek swap
endcol

defcol frame-args
  swap frame-byte-size +
  swap
endcol

defcol farg0 swap frame-args swap endcol
defcol farg1 swap frame-args cell-size + swap endcol
defcol farg2 swap frame-args cell-size 2 * + swap endcol
defcol farg3 swap frame-args cell-size 3 * + swap endcol

defcol fargn ( n frame -- ptr )
  rot cell-size * swap frame-args + swap
endcol

defcol args current-frame frame-args swap endcol

defcol arg0 current-frame farg0 peek swap endcol
defcol arg1 current-frame farg1 peek swap endcol
defcol arg2 current-frame farg2 peek swap endcol
defcol arg3 current-frame farg3 peek swap endcol

defcol set-arg0 swap current-frame farg0 poke endcol
defcol set-arg1 swap current-frame farg1 poke endcol
defcol set-arg2 swap current-frame farg2 poke endcol
defcol set-arg3 swap current-frame farg3 poke endcol

defcol argn swap current-frame fargn peek swap endcol

defcol set-argn ( v n )
  swap current-frame fargn
  swap rot swap poke
endcol

defcol locals
  current-frame cell-size -
  swap
endcol

defcol local0
  locals peek swap
endcol

defcol set-local0
  swap locals poke
endcol

defcol local1
  locals cell-size - peek swap
endcol

defcol set-local1
  swap locals cell-size - poke
endcol

defcol return-address
  swap cell-size + swap
endcol

defcol exit-frame
  drop
  current-frame return-address peek
  end-frame jump
endcol
