def tty-fill-cell-color ( cells color count -- )
  arg1 arg2 TtyCell . color poke-byte
  arg2 TtyCell struct -> byte-size @ + set-arg2
  arg0 1 - set-arg0
  arg0 0 > IF repeat-frame THEN 3 return0-n
end

def tty-fill-cell-attr ( cells attr count -- )
  arg1 arg2 TtyCell . attr poke-byte
  arg2 TtyCell struct -> byte-size @ + set-arg2
  arg0 1 - set-arg0
  arg0 0 > IF repeat-frame THEN 3 return0-n
end

struct: TtyBuffer
int field: width
int field: height
( todo mem width & height & explicit pitch )
pointer<any> field: cells

def make-tty-buffer-mem ( rows cols buffer ++ TtyBuffer )
  arg2 arg1 * TtyCell sizeof * stack-allot-zero arg0 TtyBuffer -> cells !
  arg1 arg0 TtyBuffer -> width !
  arg2 arg0 TtyBuffer -> height !
  arg0 exit-frame
end

def make-tty-buffer ( rows cols ++ TtyBuffer )
  TtyBuffer make-instance
  arg0 arg1 rot make-tty-buffer-mem
  exit-frame
end

def tty-buffer-pitch ( buffer -- pitch )
  arg0 TtyBuffer -> width @
  TtyCell sizeof * set-arg0
end

def tty-buffer-draw-row ( cells width pen-state -- )
  arg2 TtyCell . attr peek-byte arg2 TtyCell . color peek-byte arg0 tty-pen-update-write
  arg2 TtyCell . char peek
  dup -1 equals? UNLESS control-code? IF drop 32 THEN write-utf32-char THEN
  arg2 TtyCell struct -> byte-size @ + set-arg2
  arg1 1 - set-arg1
  arg1 0 > IF repeat-frame THEN 3 return0-n
end

def tty-buffer-draw/4 ( cells line-counter buffer pen-state -- )
  arg3 arg1 TtyBuffer -> width @ arg0 tty-buffer-draw-row
  arg3 arg1 tty-buffer-pitch + set-arg3
  arg2 1 - set-arg2
  arg2 0 > IF nl repeat-frame THEN 4 return0-n
end

def tty-buffer-draw ( TtyBuffer -- )
  0
  TtyPenState make-instance set-local0
  local0 tty-pen-write-reset
  arg0 TtyBuffer -> cells @
  arg0 TtyBuffer -> height @
  arg0 local0 tty-buffer-draw/4
  1 return0-n
end

def tty-buffer-size-for ( row cols -- bytes )
  arg1 arg0 * TtyCell struct -> byte-size @ * set-arg1 1 return0-n
end

def tty-buffer-size ( TtyBuffer -- bytes )
  arg0 TtyBuffer -> height @ arg0 TtyBuffer -> width @ tty-buffer-size-for set-arg0
end

def tty-buffer-erase ( TtyBuffer -- )
  arg0 TtyBuffer -> cells @
  arg0 tty-buffer-size cell/ 1 + ( fixme needs to be byte exact, adding padding on allot and going beyond here )
  0 fill-seq
  1 return0-n
end

def tty-buffer-clips? ( row col buffer -- yes? )
  0 arg2 int<= arg2 arg0 TtyBuffer -> height @ int< and UNLESS true 3 return1-n THEN
  0 arg1 int<= arg1 arg0 TtyBuffer -> width @ int< and UNLESS true 3 return1-n THEN
  false 3 return1-n
end

def tty-buffer-get-cell ( row col buffer ++ cell )
  arg2 arg1 arg0 tty-buffer-clips? UNLESS
    arg0 TtyBuffer -> cells @
    arg2 arg0 tty-buffer-pitch * + arg1 TtyCell struct -> byte-size @ * +
  ELSE
    0
  THEN 3 return1-n
end

def tty-buffer-set-cell/4 ( cell row col buffer -- )
  arg2 arg1 arg0 tty-buffer-clips? UNLESS
    arg0 TtyBuffer -> cells @
    arg2 arg0 tty-buffer-pitch * + arg1 TtyCell struct -> byte-size @ * +
    arg3 TtyCell . char @ over TtyCell . char !
    arg3 TtyCell . color peek-byte over TtyCell . color poke-byte
    arg3 TtyCell . attr peek-byte over TtyCell . attr poke-byte
  THEN 4 return0-n
end

def tty-buffer-set-cell ( char color attr row col buffer -- )
  arg2 arg1 arg0 tty-buffer-clips? UNLESS
    arg0 TtyBuffer -> cells @
    arg2 arg0 tty-buffer-pitch * + arg1 TtyCell struct -> byte-size @ * +
    5 argn over TtyCell . char poke
    4 argn over TtyCell . color poke-byte
    3 argn over TtyCell . attr poke-byte
  THEN 6 return0-n
end

def tty-buffer-draw-string ( str length buffer row col color attr -- )
  ( if col is negative: inc str, shorten length, zero col )
  arg2 0 < IF
    6 argn arg2 - 6 set-argn
    5 argn arg2 + 5 set-argn
    0 set-arg2
  THEN
  ( if col+length >= width, shorten length )
  arg2 5 argn +
  arg4 TtyBuffer -> width @ -
  dup 0 > IF
    5 argn swap - 5 set-argn
  ELSE drop
  THEN
  arg4 TtyBuffer -> cells @
  arg4 tty-buffer-pitch arg3 * + TtyCell struct -> byte-size @ arg2 * +
  dup 6 argn 5 argn tty-cell-copy-string/3    
  dup arg0 5 argn tty-fill-cell-attr
  arg1 5 argn tty-fill-cell-color

  7 return0-n
end

def tty-buffer-resize! ( rows cols buffer ++ buffer allot? )
  arg2 arg1 tty-buffer-size-for
  arg0 tty-buffer-size
  2dup int> IF
    arg2 arg1 arg0 make-tty-buffer-mem true exit-frame
  ELSE
    equals? UNLESS
      arg1 arg0 TtyBuffer -> width !
      arg2 arg0 TtyBuffer -> height !
    THEN
  THEN
  arg0 set-arg2
  false 2 return1-n
end

( todo have set-cell return clipping status to pass along for more? )

def tty-buffer-line-cell/6 ( char color attr buffer y x -- buffer more? )
  5 argn 4 argn arg3 arg1 arg0 arg2 tty-buffer-set-cell
  arg2 true 6 return2-n
end

def tty-buffer-line-cell ( buffer y x -- buffer more? )
  0x43 0x77 0 arg1 arg0 arg2 tty-buffer-set-cell true 2 return1-n
end

def tty-buffer-line ( char color attr y1 x1 y2 x2 buffer -- )
  ( draw the line )
  ' tty-buffer-line-cell/6
  5 argn 3 partial-after
  6 argn 3 partial-after
  7 argn 3 partial-after
  arg0 4 argn arg3 arg2 arg1 line-fn
  8 return0-n
end

def tty-buffer-circle ( char color attr cy cx r buffer -- )
  ' tty-buffer-line-cell/6
  4 argn 3 partial-after
  5 argn 3 partial-after
  6 argn 3 partial-after
  arg0 arg3 arg2 arg1 circle-fn
  7 return0-n
end

def tty-buffer-ellipse ( char color attr y1 x1 y2 x2 buffer -- )
  ' tty-buffer-line-cell/6
  5 argn 3 partial-after
  6 argn 3 partial-after
  7 argn 3 partial-after
  arg0 4 argn arg3 arg2 arg1 ellipse-fn
  8 return0-n
end

def tty-buffer-hline-loop ( char color attr y x w buffer counter -- )
  7 argn 6 argn 5 argn
  4 argn arg3 arg0 + arg1 tty-buffer-set-cell
  arg0 1 + set-arg0
  arg0 arg2 int< IF repeat-frame ELSE 8 return0-n THEN
end

def tty-buffer-fill-rect-loop ( char color attr y x h w buffer counter -- )
  8 argn 7 argn 6 argn
  5 argn arg0 + 4 argn
  arg2 arg1 0 tty-buffer-hline-loop
  arg0 1 + set-arg0
  arg0 arg3 int< IF repeat-frame ELSE 9 return0-n THEN
end

def tty-buffer-fill-rect ( char color attr y x h w buffer -- )
  7 argn 6 argn 5 argn 4 argn arg3 arg2 arg1 arg0 0 tty-buffer-fill-rect-loop
  8 return0-n
end

def tty-buffer-blit/10 ( src sy sx sh sw dest dy dx y x -- )
  arg0 5 argn int>= IF arg1 1 + set-arg1 0 set-arg0 THEN
  arg1 6 argn int>= IF 10 return0-n THEN
  8 argn arg1 +
  7 argn arg0 +
  9 argn tty-buffer-get-cell
  dup TtyCell . attr peek-byte TTY-CELL-ATTR-MASKED logand IF
    drop
  ELSE
    arg3 arg1 +
    arg2 arg0 +
    4 argn tty-buffer-set-cell/4
  THEN
  arg0 1 + set-arg0 repeat-frame
end

( Textured horizontal lines: )

( todo eliminate multiplies, unnecessary args, use widths/heights instead of A to B )
( todo no floats )
( todo minimize type conversions )
( todo rotator or eliminate src lerp )

struct: TexturedHlineArgs
pointer<any> field: dest
float<32> field: dx2
float<32> field: dx1
int field: dy
pointer<any> field: src
float<32> field: sx2
float<32> field: sy2
float<32> field: sx1
float<32> field: sy1

( S = S1 + [S2 - S1] * t )
( D = D1 + [D2-D1] * t )
( t' = t + 1/[D2-D1] )

( S' = S + [S2 - S1] / [D2-D1] )
( D' = D + 1 )

def tty-buffer-textured-hline-loop ( dsy dsx sy sx dx state -- )
  ( arg1 .f space 4 argn .f space arg3 .f nl dump-stack )
  arg1 arg0 TexturedHlineArgs . dx2 @ float32< UNLESS 6 return0-n THEN
  arg3 float32->int32 ( sy )
  arg2 float32->int32 ( sx )
  arg0 TexturedHlineArgs . src @ tty-buffer-get-cell
  dup IF
    dup TtyCell . attr peek-byte TTY-CELL-ATTR-MASKED logand UNLESS
      arg0 TexturedHlineArgs . dy @
      arg1 float32->int32 ( dx )
      arg0 TexturedHlineArgs . dest @ tty-buffer-set-cell/4
    ELSE drop
    THEN
  ELSE drop
  THEN
  ( D' = D + 1 )
  arg1 1f float32-add set-arg1
  ( S' = S + [S2 - S1] / [D2-D1] )
  arg3 5 argn float32-add set-arg3
  arg2 4 argn float32-add set-arg2
  repeat-frame
end

( todo get [s2-s1]/[dx2-dx1] from caller )

def tty-buffer-textured-hline ( sy1 sx1 sy2 sx2 src dy dx1 dx2 dest -- )
  ( convert and order source points by X )
  8 argn int32->float32
  7 argn int32->float32
  6 argn int32->float32
  5 argn int32->float32
  7 argn 5 argn int> IF 2swap THEN
  args TexturedHlineArgs . sx2 !
  args TexturedHlineArgs . sy2 !
  args TexturedHlineArgs . sx1 !
  args TexturedHlineArgs . sy1 !
  ( convert and order dest X )
  arg2 arg1 minmax int32->float32 swap int32->float32 swap
  args TexturedHlineArgs . dx2 !
  args TexturedHlineArgs . dx1 !
  ( calculate deltas )
  1f args TexturedHlineArgs . dx2 @ args TexturedHlineArgs . dx1 @ float32-sub float32-div
  args TexturedHlineArgs . sy2 @ args TexturedHlineArgs . sy1 @ float32-sub over float32-mul
  args TexturedHlineArgs . sx2 @ args TexturedHlineArgs . sx1 @ float32-sub shift float32-mul
  args TexturedHlineArgs . sy1 @
  args TexturedHlineArgs . sx1 @
  args TexturedHlineArgs . dx1 @
  args
  tty-buffer-textured-hline-loop
  9 return0-n
end

( 40 40 make-tty-buffer var> b
0 0 21 32 guy 0 0 40 b @ tty-buffer-textured-hline
)

( Scaling: )

struct: TtyScalerState
pointer<any> field: dest
int field: dw
int field: dh
int field: dx
int field: dy
pointer<any> field: src
int field: sw
int field: sh
int field: sx
int field: sy

def tty-buffer-scaled-blit-loop ( state dy dsy sy -- )
  arg0 float32->int32 arg3 TtyScalerState . sh @ int>= IF 4 return0-n THEN
  arg2 float32->int32 arg3 TtyScalerState . dh @ int>= IF 4 return0-n THEN
  ( sy1 sx1 sy2 sx2 src )
  arg3 TtyScalerState . sy @ int32->float32 arg0 float32-add float32->int32
  arg3 TtyScalerState . sx @
  over
  over arg3 TtyScalerState . sw @ +
  arg3 TtyScalerState . src @
  ( y x0 x1 dest )
  arg3 TtyScalerState . dy @ int32->float32 arg2 float32-add float32->int32
  arg3 TtyScalerState . dx @
  dup arg3 TtyScalerState . dw @ +
  arg3 TtyScalerState . dest @
  tty-buffer-textured-hline
  ( inc counters )
  arg2 1f float32-add set-arg2
  arg0 arg1 float32-add set-arg0
  repeat-frame
end

def tty-buffer-scaled-blit/10 ( sy sx sh sw src dy dx dh dw dest -- )
  args
  0f
  7 argn int32->float32 arg2 int32->float32 float32-div
  0f
  tty-buffer-scaled-blit-loop
  10 return0-n
end

0 IF
  def test-tty-scaled-blit ( sprite h w -- )
    0
    arg2 TtyBuffer -> height @
    arg2 TtyBuffer -> width @
    arg1 arg0 make-tty-buffer set-local0
    0 0 local1 local2 arg2 0 0 arg1 arg0 2 / local0 tty-buffer-scaled-blit/10
    0 0 local1 local2 arg2 0 arg0 2 / arg1 2 / arg0 4 / local0 tty-buffer-scaled-blit/10
    0 0 local1 local2 arg2 0 arg0 2 / arg0 4 / + arg1 4 / arg0 8 / local0 tty-buffer-scaled-blit/10
    0 0 local1 local2 arg2 0 arg0 2 / arg0 4 / + arg0 8 / + arg1 8 / arg0 16 /  local0 tty-buffer-scaled-blit/10
    local0 tty-buffer-draw tty-char-reset nl
    3 return0-n
  end

  nl guy 24 51 test-tty-scaled-blit
THEN

( Masking by cell value: )

def tty-buffer-mask-by-cell-loop ( cell buffer y x -- buffer )
  arg0 arg2 TtyBuffer -> width @ uint< UNLESS 0 set-arg0 arg1 1 + set-arg1 THEN
  arg1 arg2 TtyBuffer -> height @ uint< UNLESS arg2 4 return1-n THEN
  arg1 arg0 arg2 tty-buffer-get-cell
  dup arg3 tty-cell-equals? IF
    TtyCell . attr dup peek-byte TTY-CELL-ATTR-MASKED logior swap poke-byte
  ELSE drop
  THEN
  arg0 1 + set-arg0 repeat-frame
end

def tty-buffer-mask-by-cell ( cell buffer -- buffer )
  ( Change the cell attributes to be a mask for all cell that match ~cell~. )
  TtyCell allot-struct arg1 over TtyCell sizeof copy ( todo struct copier, allot-copy )
  arg0 0 0 tty-buffer-mask-by-cell-loop
  arg0 2 return1-n
end

def tty-buffer-mask-by-xy ( sy sx buffer -- buffer )
  ( Change the cell attributes to be a mask for all cell that match the cell at ~X, Y~. )
  arg2 arg1 arg0 tty-buffer-get-cell
  dup IF arg0 tty-buffer-mask-by-cell ELSE drop arg0 THEN 3 return1-n
end
