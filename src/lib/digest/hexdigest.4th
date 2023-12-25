( Hex digest output: )

0 IF
def ohexdigest/5 ( max-length ptr size hash-value n -- ptr length )
  ( convert each 32 bit cell in ~hash-value~ into an 8 byte string and concatenate it in ~ptr~ to make one big 64 or ~max-length*8~, byte string )
  arg0 4 argn uint>=
  arg0 8 * arg2 uint>= or IF
    arg3 arg0 8 *
    arg2 4 argn 8 * uint> IF 2dup null-terminate THEN
    4 return2-n
  THEN
  arg1 arg0 seq-peek
  arg3 arg0 8 * + 0 true uint->hex-string/4 4 dropn
  arg0 1 + set-arg0 repeat-frame
end
THEN

( Or in a map friendly style? )

def hexdigest-fn
  arg1 0 seq-peek arg1 4 seq-peek uint<
  arg1 0 seq-peek 8 * arg1 2 seq-peek uint< and IF
    arg0
    arg1 3 seq-peek
    arg1 0 seq-peek 8 * +
    0 true uint->hex-string/4
    arg1 inc!
  THEN arg1 2 return1-n
end

def hexdigest/5 ( max-length ptr size hash-value n -- ptr length )
  ( convert each 32 bit cell in ~hash-value~ into an 8 byte string and concatenate it in ~ptr~ to make one big 64 or ~max-length*8~, byte string )
  arg1 4 argn args ' hexdigest-fn map-seq-n/4
  arg3 arg0 8 *
  arg2 4 argn 8 * uint> IF 2dup null-terminate THEN
  5 return2-n
end
