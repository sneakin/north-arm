defcol parent-frame
  swap peek swap
endcol

defcol frame-args
  swap frame-byte-size +
  swap
endcol

defcol args
  current-frame frame-args
  swap
endcol

defcol arg0
  args peek swap
endcol

defcol set-arg0
  swap args poke
endcol

defcol arg1
  args cell-size + peek swap
endcol

defcol set-arg1
  swap args cell-size + poke
endcol

defcol arg2
  args cell-size int32 2 * + peek swap
endcol

defcol set-arg2
  swap args cell-size int32 2 * + poke
endcol

defcol arg3
  args cell-size int32 3 * + peek swap
endcol

defcol set-arg3
  swap args cell-size int32 3 * + poke
endcol

defcol argn
  swap cell-size * args + peek swap
endcol

defcol set-argn ( v n )
  swap cell-size * args +
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

