runner/thumb/messages.4th load
runner/thumb/strings.4th load
runner/thumb/dictionary.4th load
runner/thumb/logic.4th load
runner/thumb/output.4th load
runner/thumb/reader.4th load

( Debugging aid: )

defcol print-args
  arg3 write-hex-int nl
  arg2 write-hex-int nl
  arg1 write-hex-int nl
  arg0 write-hex-int nl nl
endcol

( Input: )

defcol prompt
  " Forth> " write-string/2
endcol

defcol stdin-read ( ptr len -- ptr read-length )
  over int32 4 overn int32 0 read
  rot drop
endcol

defcol prompt-read
  nl prompt
  ( fixme perfect spot for a tailcall )
  over int32 4 overn int32 0 read
  rot drop
endcol

defcol make-stdin-reader
  int32 0 swap
  int32 0 swap  
  literal stdin-read swap
  here cell-size + swap
endcol

defcol make-prompt-reader
  int32 0 swap
  int32 0 swap  
  literal prompt-read swap
  here cell-size + swap
endcol

defcol read-line ( ptr len -- ptr read-length )
  over int32 4 overn int32 0 read
  negative? UNLESS
    int32 1 swap -
    int32 4 overn over null-terminate
  THEN
  rot drop
endcol

defcol read-token ( ptr len reader -- ptr read-length )
  int32 4 overn int32 4 overn int32 4 overn reader-next-token
  negative? IF
    drop dup int32 0 equals? IF drop int32 -1 THEN
  ELSE
    drop over over null-terminate
  THEN
  ( ptr len reader -- ptr len )
  int32 4 set-overn
  drop swap drop
endcol

( Interpretation loop: )

def interp
  arg2 arg1 arg0 read-token negative? IF what return THEN
  2dup write-string/2 nl
  lookup IF exec-abs ELSE not-found drop THEN
  dup write-hex-uint
  repeat-frame
end
