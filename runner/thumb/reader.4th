( Character classification: )

defcol is-space?
  swap int32 0x20 equals? swap
endcol

defcol newline?
  swap int32 0x0A equals? swap
endcol

defcol whitespace?
  over newline? IF int32 1
  ELSE
    over is-space? IF int32 1 ELSE int32 0 THEN
  THEN
  rot drop
endcol

defcol not-whitespace?
  swap whitespace? not swap
endcol

( Token Reader: )

defcol reader-null-fn
  int32 -1 swap
endcol

defcol make-reader
  int32 0 swap
  int32 0 swap
  literal reader-null-fn swap
  here cell-size + swap
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

defcol reader-buffer
  swap cell-size int32 4 * + swap
endcol

defcol reader-buffer-length
  swap cell-size int32 3 * + swap
endcol

defcol reader-length
  swap cell-size int32 2 * + swap
endcol

defcol reader-offset
  swap cell-size int32 1 * + swap
endcol

defcol reader-reader-fn
  swap cell-size int32 0 * + swap
endcol

( todo read return 0 on EOF, not -1; could use 0 for length on eof but need a flag for the first read. )
( todo reader stack: pop off when EOF reached )

def reader-read-more
  arg0 reader-reader-fn peek null? IF int32 -1 return1 THEN
  arg0 reader-buffer peek
  arg0 reader-buffer-length peek
  arg0 reader-reader-fn peek exec
  dup int32 0 equals? IF drop int32 -1 THEN
  dup arg0 reader-length poke
  int32 0 arg0 reader-offset poke
  return1
end

def reader-top-up
  arg0 reader-length peek negative? IF return1 THEN
  arg0 reader-offset peek
  int<= IF arg0 reader-read-more return1 THEN
  int32 0 return1
end

def reader-peek-byte ( reader -- byte )
  arg0 reader-top-up negative? IF set-arg0 return THEN
  arg0 reader-buffer peek
  arg0 reader-offset peek
  string-peek set-arg0
end

defcol reader-inc-offset!
  swap reader-offset dup peek int32 1 + swap poke
endcol

def reader-read-byte ( reader -- byte )
  arg0 reader-peek-byte
  negative? IF set-arg0 return THEN
  arg0 reader-inc-offset!
  set-arg0
end

def reader-skip-until/3 ( fn reader bytes-read ++ last-byte )
  arg1 reader-peek-byte negative? IF return1 THEN
  dup arg2 exec IF return1 ELSE drop THEN
  arg1 reader-inc-offset!
  arg0 int32 1 + set-arg0
  repeat-frame
end

def reader-skip-until ( fn reader -- bytes-read last-byte )
  arg1 arg0 int32 0 reader-skip-until/3
  set-arg0
  set-arg1
end

def reader-read-until/5 ( ptr max-length fn reader bytes-read ++ last-byte )
  ( don't overfill )
  arg3 arg0 int<= IF int32 0 return1 THEN
  ( read a byte, return on EOF )
  arg1 reader-peek-byte negative? IF return1 THEN
  ( call the predicate )
  dup arg2 exec IF return1 THEN
  ( store the byte )
  int32 4 argn arg0 string-poke
  ( inc counter )
  arg1 reader-inc-offset!
  arg0 int32 1 + set-arg0
  repeat-frame
end

def reader-read-until ( ptr max-length fn reader -- ptr bytes-read last-byte )
  arg3 arg2 arg1 arg0 int32 0 reader-read-until/5
  set-arg1 set-arg2
  drop-locals end-frame ( fixme what and why drop 2? )
  int32 2 dropn swap drop exit
end

def reader-next-token ( ptr max-length reader -- ptr length last-byte )
  literal not-whitespace? arg0 reader-skip-until negative? IF
    set-arg0
    int32 0 set-arg1
    return
  THEN
  int32 2 dropn
  arg2 arg1 literal whitespace? arg0 reader-read-until
  set-arg0
  set-arg1
end
