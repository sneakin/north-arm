( Words needed to load files made for the first North. )

def error ( msg heading -- )
  arg0 error-line
  arg1 error-line
  error
  end

( defcol return1-1 drop 1 return1-n end )
defcol return1-1 drop set-arg0 return0 endcol  

def pointer? arg0 here uint>= return1 end

def escape?
  arg0 0x1B equals? return1
end

def control-code?
  arg0 32 int< return1
end  

def decode-char-escape ( string length index -- new-index char )
  arg2 arg0 int-add peek-byte
  CASE
    0x5C ( \ ) WHEN 0x5C ;;
    101 ( e ) WHEN 0x1B ;;
    110 ( n ) WHEN 0xA ;;
    114 ( r ) WHEN 0xD ;;
    116 ( t ) WHEN 9 ;;
    48 ( 0 ) WHEN 0 ;;
  ESAC
  ( todo \x, \u, proper \0 )
  ( todo raise error )
  arg0 1 + set-arg2 2 return1-n
end

def unescape-string/4 ( string length out-idx in-idx -- string new-length )
  arg0 arg2 int>= IF
    arg1 arg0 int< IF arg3 arg1 null-terminate THEN
    arg1 3 return1-n
  THEN
  arg3 arg0 int-add peek-byte
  dup 0x5C equals? IF
    ( unescape char )
    arg3 arg2 arg0 1 int-add decode-char-escape
    arg3 arg1 int-add poke-byte set-arg0
    arg1 1 int-add set-arg1
  ELSE
    ( copy the byte down )
    arg1 arg0 int< IF arg3 arg1 int-add poke-byte ELSE drop THEN
    arg1 1 int-add set-arg1
    arg0 1 int-add set-arg0
  THEN repeat-frame
end

def unescape-string/2 ( string length -- string new-length )
  arg1 arg0 0 0 unescape-string/4 return1-1
end

( todo POSTPONE needs a like word that useskdict for the source. )
alias> top-s" s"

def es"
  top-s" unescape-string/2 return2
end

defcol [es"]
  literal cstring swap
  POSTPONE es" swap cs - rot
  literal int32 rot swap
endcol immediate-as s"

def e"
  top-s" unescape-string/2 drop return1
end

def [e"]
  literal cstring
  POSTPONE e" cs - return2
end immediate-as "

def char-code
  ( reads a single character or an escape sequence, and returns the ASCII value. )
  next-token dup IF unescape-string/2 over peek-byte ELSE 0 THEN return1
end

def [char-code]
  literal uint32 char-code return2
end immediate-as char-code

def longify/4 ( ptr len n sum -- sum )
  arg2 arg1 int<= IF arg0 4 return1-n THEN
  arg3 arg1 int-add peek-byte
  arg1 8 int-mul bsl arg0 int-add set-arg0
  arg1 1 int-add set-arg1
  repeat-frame
end

def longify
  ( Reads up to four bytes and returns an integer with those bytes. )
  next-token unescape-string/2 0 0 longify/4 return1
end

longify STOP const> terminator
def terminator? arg0 terminator equals? return1 end

def [longify]
  literal uint32 longify return2
end immediate-as longify

def write-word
  args 4 write-string/2 1 return0-n
end

def doc(
  POSTPONE (
end immediate

def args(
  POSTPONE (
end immediate

def .d
  arg0 write-int space 1 return0-n
end

def cell*
  arg0 cell-size int-mul return1
end

def cell+
  arg0 cell-size int-add return1
end

def cell+2
  arg0 cell-size 2 int-mul int-add return1
end

def cell+3
  arg0 cell-size 3 int-mul int-add return1
end

def cell+n
  arg0 cell* arg1 int-add return1
end

alias> digit? is-digit?
( alias> digit-char char-to-digit )
def digit-char arg0 char-to-digit return1 end

def global-var 0 var> exit-frame end

alias> base input-base

def aliases ( dict new-name dict-entry ++ new-entry )
  0
  arg1 dup string-length make-dict-entry set-local0
  arg2 cs - local0 dict-entry-link poke
  arg0 dict-entry-code peek local0 dict-entry-code poke
  arg0 dict-entry-data peek local0 dict-entry-data poke
  local0 exit-frame
end

( fixme )
defcol aliases>
  next-token dict dict-lookup
  IF rot 2 dropn
     literal literal rot
     literal aliases swap
  ELSE drop error-line/2 not-found swap drop
  THEN
endcol immediate

def constant
  0 const> next-integer UNLESS 0 THEN dict dict-entry-data poke exit-frame
end

defcol cont-frame
  current-frame return-address peek end-frame swap
endcol

defcol colon-cont
  ( fixme ops return using LR; originally may have reused frame )
  drop cont-frame swap exec-abs
endcol

( cont )
defcol cont
  drop
  dup dict-entry-code peek ' do-col dict-entry-code peek equals? IF
    dict-entry-data peek cs +
    dup peek cs + ' begin-frame equals?
    IF op-size +
    ELSE cont-frame swap
    THEN jump
  ELSE exec-abs
  THEN
endcol

def bslc ( a shift -- high low )
  arg1 32 arg0 - bsr
  arg1 arg0 bsl set-arg0 set-arg1
end

def bsrc ( a shift -- high low )
  arg1 32 arg0 - bsl
  arg1 arg0 bsr set-arg1 set-arg0
end

alias> u->f uint32->float32
alias> float-div float32-div

( ordered-seq needs: )
alias> .\n nl
alias> ,sp space
alias> write-space space
alias> write-tab tab
alias> write-crnl nl
alias> write-unsigned-int write-uint
alias> ,d ,i
alias> .s write-string
alias> write-string-n write-string/2
def .S space arg0 write-string 1 return0-n end
def write-line-n arg1 arg0 write-line/2 end
alias> hexdump cmemdump

alias> exec-core-word exec-abs

alias> RECURSE repeat-frame immediate
alias> store-local0 set-local0
defcol arg4 4 argn swap endcol

def frame-argn
  arg0 current-frame parent-frame @ fargn @ set-arg0
end

defcol returnN
  ( copy N values over the frame's return and FP. Return from the frame. )
  ( stack: frame ... values num-values return-addr )
  drop ( the definition's call frame)
  current-frame return-address peek ( save the frame's return )
  swap 1 + cell-size * ( number bytes to copy including return address )
  current-frame frame-byte-size + over - ( destination address )
  ( end the caller's frame )
  end-frame
  ( copy the values up the stack to overwrite the frame's call state )
  here cell-size 2 * + over 4 overn copy
  ( and move stack before returning from caller )
  move exit
endcol

defcol return-locals
  drop here current-frame swap int-sub cell-size int-div returnN
endcol

0 [IF]
defcol return2-n
  drop
  1 - current-frame fargn ( pointer to top most arg )
  current-frame return-address peek swap ( frame's return address )
  end-frame
  4 overn over poke ( first return value )
  down-stack
  3 overn over poke ( next return value )
  down-stack over over poke ( return address )
  move
end
[THEN]

alias> logi badlog2-int
alias> < int<
alias> > int>
alias> >= int>=
alias> <= int<=
alias> <=> int<=>
def not-<=> arg1 arg0 <=> negate 2 return1-n end

def identity end
def drop2 2 return0-n end
def drop3 3 return0-n end
def swapdrop arg0 2 return1-n end
def rotdrop2 arg0 3 return1-n end

def cell-align
  arg0 cell-size pad-addr return1
end

def string-equal
  arg0 string-length
  arg1 string-length
  2dup equals? IF
    arg1 arg0 local0 string-equals?/3
  ELSE
    false
  THEN 2 return1-n
end

def seq-data
  arg0 cell-size int-add ( return1-1 ) return1
end

def seq-length
  arg0 peek return1
end

alias> seq-peek seqn-peek
alias> seq-poke seqn-poke
alias> dallot-cells dallot

def dallot ( num-bytes -- ptr )
  arg0 cell-size int-add cell-size int-div dallot-cells return1-1
end

def dallot-seq ( num-cells -- seq )
  arg0 1 + cell-size * dallot
  arg0 over poke
  return1-1
end

def dallot-zeroed-seq ( num-cells -- seq )
  arg0 dallot-seq
  dup seq-data arg0 cell-size * 0 fill-seq 3 dropn
  return1-1
end

def read-byte
  ( fixme needs to read fd directly? )
  ( the-reader peek reader-read-byte return1 )
  0
  1 locals current-input peek read IF local0 ELSE -1 THEN return1
end

defcol input-reset
  exit
endcol

( DOTIMES[ ]DOTIMES )
def DOTIMES[
  literal uint32 int32 0
  literal eip
  literal uint32 terminator
  literal int-add
  literal begin-frame
  literal arg0 literal arg1 literal int< ( todo switch to uint< which needs tty-filled-box to check size )
  POSTPONE UNLESS literal return-locals POSTPONE THEN
  return-locals
end immediate

def find-terminator
  arg0 top-frame uint< UNLESS false return1-1 THEN
  arg0 peek terminator equals? IF true return1 THEN
  arg0 up-stack set-arg0 repeat-frame
end

def bytes-to-terminator
  arg0 find-terminator IF here int-sub ELSE 0 THEN return1-1
end

def patch-terminator/2
  arg1 find-terminator IF
    arg0 swap poke
  THEN
  2 return0-n
end

def ]DOTIMES
    ( inc the counter )
    literal arg0 literal uint32 int32 1 literal int-add literal set-arg0
    ( calculate jump offset )
    literal int32
    frame-byte-size 5 cell+n rotdrop2
    here bytes-to-terminator int-sub
    ( loop )
    literal jump-rel
    ( patch the terminator to here less call frame )
    here
    dup bytes-to-terminator frame-byte-size 3 cell+n rotdrop2 -
    patch-terminator/2
    return-locals
end immediate

alias> variable-peeker do-var
alias> value-peeker do-const

def set-dict-entry-data
  arg1 arg0 dict-entry-data poke
  2 return0-n
end

def make-dict/4 ( link name code data ++ entry )
  arg3 arg2 arg1 arg0
  args dict-entry-data poke
  args dict-entry-code poke
  cs - args dict-entry-name poke
  cs - args dict-entry-link poke
  args return1
end

( copy-seq to terminator )

def copy-seq
  doc( Copies NUMBER of CELLS from the SRC to DEST sequence and updates DEST size to NUMBER. )
  args( src dest number )
  arg2 cell+ swapdrop arg1 cell+ swapdrop arg0 cell* swapdrop copy
  arg0 arg1 poke
end

def string-cmp
  arg1 string-length
  arg0 string-length
  2dup equals?
  IF arg1 arg0 local0 string-equals?/3
  ELSE false
  THEN 2 return1-n
end

def seq->cstring/4 ( src dest num-chars counter -- dest length )
  arg0 arg1 uint< IF
    arg3 arg0 seqn-peek
    arg2 arg0 poke-off
    arg0 1 int-add set-arg0
    repeat-frame
  ELSE
    arg2 arg0
    2dup null-terminate
    4 return2-n
  THEN
end

def seq->cstring ( src dest num-chars -- dest length )
  ( Compacts a sequence of cell sized characters into a byte string of single byte characters. )
  arg2 arg1 arg0 0 seq->cstring/4 3 return2-n
end

def copy-string
  arg2 arg1 arg0 copy 3 return0-n
end

def write-char-seq/3
  arg0 arg1 < IF
    arg2 arg0 seq-peek write-byte
    arg0 1 int-add set-arg0 RECURSE
  THEN 3 return0-n
end

def write-char-seq/2
  arg1 arg0 0 write-char-seq/3 2 return0-n
end


( tty-enter-raw-mode tty-exit-raw-mode: needs termios or ioctl wrappers )
( def tty-enter-raw-mode end
def tty-exit-raw-mode end )

( alias> lit literal ) ( ['] immediate-as lit )

def lit
  next-token
  over dhere 3 overn copy-byte-string/3 3 dropn
  dhere dup 3 overn + cell-size pad-addr dmove
  literal cstring swap cs - return2
end immediate

0 var> tty-readeval-done

def reduce-seq-n ( ptr count fn initial )
  arg3 arg2 arg0 arg1 map-seq-n/4 4 return1-n
end

def map-seq-n ( ptr count fn )
  arg2 arg1 0 arg0 map-seq-n/4 3 return1-n
end

def help
  s" No help." write-line/2
end

( return1 is used by readeval as words are assumed to be on data stack. exit-frame needed here. )
( DO LEAVE LOOP )
( .s for strings in north, for stack here )
( decompiler needs to escape strings )
( stack arguments w/ cont reused w/ caller? )
( cell+, etc. have different signatures )

( .S
btree-branch-add-inner
btree-split
tty-readline-at-end?
tty-readline-insert-string
)

alias> copydown copy-down
alias> min-int min
alias> max-int max
alias> minmax-int minmax

def redefine!
  arg1 dict-entry-code peek arg0 dict-entry-code poke
  arg1 dict-entry-data peek arg0 dict-entry-data poke
end

def lookup-or-create
  arg1 arg0 dict dict-lookup IF return1 ELSE drop THEN
  create exit-frame
end

def next-word-or-create>
  next-token lookup-or-create exit-frame
end

def redef
  next-word-or-create> does-frame> exit-frame
end

def dict-entry-data@
  arg0 dict-entry-data @ return1-1
end

def dict-entry-code@
  arg0 dict-entry-code @ return1-1
end

alias> sys:dict-lookup dict-lookup

def dict-lookup ( name dict ++ entry )
  arg1 dup string-length arg0 sys:dict-lookup UNLESS false THEN return1
end

( in-range? arg order differs )
def in-range? ( max min value ++ yes? )
  arg0 arg2 int<= arg1 arg0 int<= and return1
end

( tty.4th expects dict-entry slots to add to stack )
( overn is off by one, bc is +1 )
def pick ( an ... a0 n -- an ... a0 an )
  args arg0 1 + up-stack/2 peek return1-1
end

( shift is in the wrong direction, is a roll )
alias> old-roll roll
alias> roll shift
alias> shift old-roll

def write-dict-name arg0 dict-entry-name peek cs + write-line 1 return0-n end
def dump-dict-entry arg0 64 cmemdump 1 return0-n end

def null? arg0 0 equals? return1 end

alias> dict-terminator zero

