( todo Infinite ray is caused by hline and vline. They need to traverse from x0 -> x1 and not min to max )

' TtyBuffer [UNLESS]
load-core
s[ src/lib/linux/clock.4th
   src/lib/linux/stat.4th
   src/lib/io.4th
   src/lib/threading/lock.4th
   src/lib/tty.4th
   src/lib/geometry/angles.4th
] load-list
[THEN]

( Functions that belong else where: )

def write-char-rep ( c n )
  arg1 write-byte
  arg0 1 - set-arg0
  arg0 0 int> IF repeat-frame THEN 2 return0-n
end

( Float32 helpers: )

def min-float32
  arg1 arg0 float32< IF 1 return0-n ELSE arg0 2 return1-n THEN
end

def max-float32
  arg1 arg0 float32> IF 1 return0-n ELSE arg0 2 return1-n THEN
end

def in-range-float32? ( n min max -- yes? )
  arg2 arg0 float32<= arg2 arg1 float32>= and 3 return1-n
end

def float32-lerp ( weight min max -- value )
  arg2 arg1 float32-mul
  1f arg2 float32-sub arg0 float32-mul
  float32-add 3 return1-n
end

( Trig lookup tables: )
( fixme causes an artifact in the rays. may need more precision and/or ditching degrees )

pi 2f float32-div const> pi/2
pi/2 2f float32-div const> pi/4

0 var> sin-lut
pi 128 int32->float32 float32-div const> pi/128
128 int32->float32 pi float32-div const> 128/pi
180 int32->float32 128 int32->float32 float32-div const> 180/128
128 int32->float32 180 int32->float32 float32-div const> 128/180

def byte->radians
  arg0 int32->float32 pi/128 float32-mul set-arg0
end

def radians->byte
  arg0 128/pi float32-mul float32->int32 0xFF logand set-arg0
end

def byte->degrees
  arg0 int32->float32 180/128 float32-mul set-arg0
end

def degrees->byte
  arg0 128/180 float32-mul float32->int32 0xFF logand set-arg0
end

def lut-sin-byte
  sin-lut @ arg0 0xFF logand seq-peek set-arg0
end

def lut-sin
  arg0 radians->byte lut-sin-byte set-arg0
end

def lut-cos-byte
  arg0 64 int-add lut-sin-byte set-arg0
end

def lut-cos
  arg0 pi/2 float32-add lut-sin set-arg0
end

def trig-lut-init-loop
  arg0 256 int< UNLESS 1 return0-n THEN
  arg0 byte->radians float32-sin sin-lut @ arg0 seq-poke
  arg0 1 + set-arg0 repeat-frame
end

def trig-lut-init
  float-precision @
  31 float-precision !
  256 cell* stack-allot sin-lut !
  0 trig-lut-init-loop
  local0 float-precision !
  exit-frame
end

def byte->vec2d
  arg0 lut-sin-byte
  arg0 lut-cos-byte 1 return2-n
end

def lut-radians->vec2d
  arg0 radians->byte byte->vec2d 1 return2-n
end

def lut-degrees->vec2d
  arg0 degrees->byte byte->vec2d 1 return2-n
end

( 2D vectors: )

def vec2d-sub ( y2 x2 y1 x1 -- y x )
  arg3 arg1 float32-sub
  arg2 arg0 float32-sub
  4 return2-n
end

def magnitude-squared ( y x -- mag2 )
  arg1 dup *
  arg0 dup * + 2 return1-n
end

def magnitude-squared-float32 ( y x -- mag2 )
  arg1 dup float32-mul
  arg0 dup float32-mul float32-add 2 return1-n
end

def distance-squared ( y1 x1 y0 x0 -- dd )
  arg3 arg1 - arg2 arg0 - magnitude-squared 4 return1-n
end

def distance-squared-float32 ( y1 x1 y0 x0 -- dd )
  arg3 arg2 arg1 arg0 vec2d-sub magnitude-squared-float32 4 return1-n
end

def magnitude ( y x -- mag )
  arg1 arg0 magnitude-squared
  int32->float32 float32-sqrt
  2 return1-n
end

def magnitude-float32 ( y x -- mag )
  arg1 arg0 magnitude-squared-float32 float32-sqrt 2 return1-n
end

def distance ( y1 x1 y0 x0 -- dd )
  arg3 arg2 arg1 arg0 distance-squared
  int32->float32 float32-sqrt
  4 return1-n
end

def distance-float32 ( y1 x1 y0 x0 -- dd )
  arg3 arg2 arg1 arg0 distance-squared-float32 float32-sqrt 4 return1-n
end

def vec2d-normalize ( y x -- ny nx )
  arg1 arg0 magnitude-float32
  arg1 over float32-div
  swap arg0 swap float32-div
  2 return2-n
end

def vec2d-dot ( by bx ay ax -- acos )
  arg3 arg1 * arg2 arg0 * + int32->float32
  arg3 arg2 magnitude float32-div
  arg1 arg0 magnitude float32-div
  4 return1-n
end

def vec2d-scale ( y x scale -- y' x' )
  arg2 arg0 float32-mul
  arg1 arg0 float32-mul
  3 return2-n
end

( A ray caster: )

( Constants: )

8 const> raycaster-angle-bits
4 const> raycaster-ray-bits
90 var> raycaster-init-fov
0.5f dup float32-mul dup float32-mul ( dup float32-mul ) float32-negate const> hit-fudge-factor
0 var> use-x

0 var> *raycaster-threads*
-1 var> *raycaster-poll-timeout*

( The world: )

0 var> raycaster-textures

def raycaster-digit-textures
  arg0 dup 4 bsl logior arg1 char-code 0 arg0 + seq-poke
  arg0 1 + set-arg0
  arg0 10 int< IF repeat-frame ELSE 1 return0-n THEN
end

def raycaster-texture-init
  128 cell-size * stack-allot
  dup raycaster-textures !
  0x80000044 over 0 seq-poke
  0x80000000 over 32 seq-poke
  0x10 over char-code B seq-poke
  0x80000010 over char-code b seq-poke
  0x21 over char-code D seq-poke
  0x23 over char-code W seq-poke
  0x80000023 over char-code w seq-poke
  0x66 over char-code A seq-poke
  0x55 over char-code X seq-poke
  0x11 over char-code Y seq-poke
  0x70 over char-code M seq-poke
  0x13 over char-code T seq-poke
  0x77 over char-code * seq-poke
  0x40 over char-code ~ seq-poke
  ( todo ░▒▓█▄▌▐▀ needs more than a byte and unicode encoder, or a remapping. could use for real shading in 16, 256, millions of colors. )
  0 raycaster-digit-textures
  exit-frame
end

def world-cell-floor? ( cell ++ yes? )
  arg0 32 equals?
  arg0 0 equals? or
  arg0 char-code w equals? or
  arg0 char-code b equals? or
  return1
end

def world-cell-solid? ( cell ++ yes? )
  arg0 world-cell-floor? not return1
end

def world-cell-sky? ( cell ++ yes? )
  arg0 0 equals? IF true return1 THEN
  arg0 10 equals? return1
end

( Fun Worlds )

struct: World
pointer<any> field: fun
pointer<any> field: data
int field: width
int field: height

def make-world
  World make-instance
  arg0 over World -> width !
  arg1 over World -> height !
  arg2 over World -> data !
  arg3 over World -> fun !
  exit-frame
end

def world-contains? ( y x world -- yes? )
  arg2 0 int>=
  arg2 arg0 World -> height @ int< and UNLESS false 3 return1-n THEN
  arg1 0 int>=
  arg1 arg0 World -> width @ int< and UNLESS false 3 return1-n THEN
  true 3 return1-n
end

def world-get-cell-value ( y x world -- value )
  arg2 arg1 arg0 world-contains? IF
    arg2 arg1 arg0 arg0 World -> fun @ exec-abs
  ELSE 0 THEN 3 return1-n
end

struct: StaticWorld
pointer<any> field: cells
int field: width
int field: height

def static-world-contains? ( y x world -- yes? )
  arg2 0 int>=
  arg2 arg0 StaticWorld -> height @ int< and UNLESS false 3 return1-n THEN
  arg1 0 int>=
  arg1 arg0 StaticWorld -> width @ int< and UNLESS false 3 return1-n THEN
  true 3 return1-n
end

def static-world-get-cell-value ( y x world static-world -- value )
  arg3 arg2 arg0 static-world-contains? IF
    arg0 StaticWorld -> cells @
    arg0 StaticWorld -> width @ arg3 * arg2 +
    string-peek
  ELSE 0 THEN 4 return1-n
end

def make-static-world-fun ( world ++ fun )
  ' static-world-get-cell-value arg0 partial-first exit-frame
end

def make-static-world
  0 0
  StaticWorld make-instance set-local0
  arg0 local0 StaticWorld -> width !
  arg1 local0 StaticWorld -> height !
  arg2 local0 StaticWorld -> cells !
  local0 make-static-world-fun
  local0 arg1 arg0 make-world
  exit-frame
end


( Casting rays through the world: )

struct: RayCasterHit
int field: angle
int field: screen-x
int field: x
int field: y
int field: sky
int field: terminal
int field: cell

def make-ray-caster-hit
  args RayCasterHit cons exit-frame
end

def cast-ray-fn ( world y x angle ++ world | hit )
  arg2 raycaster-ray-bits absr arg1 raycaster-ray-bits absr arg3 world-get-cell-value
  world-cell-sky? IF
    true true
    arg2 raycaster-ray-bits absr ( todo don't shift, convert to float? )
    arg1 raycaster-ray-bits absr
    -1 arg0 make-ray-caster-hit false exit-frame
    ( drop 0 arg0 cons false exit-frame )
  THEN
  world-cell-solid? IF ( make a list of angle, y, x )
    true false
    arg2 raycaster-ray-bits absr
    arg1 raycaster-ray-bits absr
    -1 arg0 make-ray-caster-hit false exit-frame
    ( drop 0 arg2 raycaster-ray-bits absr cons arg1 raycaster-ray-bits absr cons arg0 cons false exit-frame )
  THEN
  arg3 true 4 return2-n
end

1024 var> RAYCAST-CAST-LENGTH ( fixme crashes when set too small: nothing to render? crashes w/ too big of a world. down to havinh misaligned floor and ceilings. )

def cast-ray ( world y x angle ++ hit )
  arg0 int32->float32 lut-degrees->vec2d
  RAYCAST-CAST-LENGTH @ int32->float32 float32-mul float32->int32 arg1 + raycaster-ray-bits bsl swap
  RAYCAST-CAST-LENGTH @ int32->float32 float32-mul float32->int32 arg2 + raycaster-ray-bits bsl swap
  ( s" casting to " write-string/2 arg2 .i space arg1 .i space arg0 .i space
  local1 .i space local0 .i nl )
  ' cast-ray-fn arg0 partial-first
  arg3 local0 local1
  arg2 raycaster-ray-bits bsl
  arg1 raycaster-ray-bits bsl
  bresenham-line-fn
  dup arg3 equals? IF
    false false
    local0 raycaster-ray-bits absr ( todo don't shift, convert to float? )
    local1 raycaster-ray-bits absr
    -1 arg2 make-ray-caster-hit
  THEN
  exit-frame
end

( todo map-range )

def sweep-rays/9 ( sx dsx dO*256 world y x from*256 to*256 accum ++ hits )
  5 argn 4 argn arg3 arg2 raycaster-angle-bits absr cast-ray
  8 argn over RayCasterHit -> screen-x !
  arg0 swap cons set-arg0
  arg2 6 argn + set-arg2
  8 argn 7 argn + 8 set-argn
  arg2 arg1 int< IF repeat-frame ELSE arg0 exit-frame THEN
end

def sweep-rays ( dO*256 world y x from*256 to*256 accum ++ hits )
  5 argn 4 argn arg3 arg2 raycaster-angle-bits absr cast-ray
  arg0 swap cons set-arg0
  arg2 6 argn + set-arg2
  arg2 arg1 int< IF repeat-frame ELSE arg0 exit-frame THEN
end

  
def print-hit
  arg0 RayCasterHit -> angle @ .i space
  arg0 RayCasterHit -> x @ .i space
  arg0 RayCasterHit -> y @ .i space
  arg0 RayCasterHit -> sky @ .i space
  arg0 RayCasterHit -> cell @ .i space
  nl
end

def raycaster-print ( world buffer )
  1 raycaster-angle-bits bsl arg1 8 8 0 360 raycaster-angle-bits bsl 0 sweep-rays ' print-hit map-car
end

def raycaster-print-vertical ( hit world context )
  arg2 cdr cdr car arg2 cdr car
  2dup 8 8 distance-squared ,i space
  480 swap / ,i tab
  50 min
  32 25 3 overn 2 / - write-char-rep
  local0 local1 arg1 world-get-cell-value
  swap write-char-rep nl
end

struct: WorldCamera
int field: fov
int field: angle
int field: x
int field: y

def make-world-camera ( y x angle fov ++ camera )
  args WorldCamera make-typed-pointer
  exit-frame
end

def copy-world-camera-to ( camera new-camera -- )
  arg1 WorldCamera -> y @ arg0 WorldCamera -> y !
  arg1 WorldCamera -> x @ arg0 WorldCamera -> x !
  arg1 WorldCamera -> angle @ arg0 WorldCamera -> angle !
  arg1 WorldCamera -> fov @ arg0 WorldCamera -> fov !
  2 return0-n
end

def copy-world-camera ( camera ++ new-camera )
  WorldCamera make-instance arg0 over copy-world-camera-to exit-frame
end

def world-camera-pos
  arg0 WorldCamera -> y @ arg0 WorldCamera -> x @ 1 return2-n
end

( Ray caster hit rendering: )

def raycaster-fish-eye-correct ( distance vertical-angle fov/2 -- fixed-distance )
  ( Verticals get bowed so the middle verticals look too tall. This makes the outer verticals taller. )
  arg1 int32->float32 ( ,f space ) degrees->radians ( ,f space )
  lut-cos ( ,f space )
  arg2 ( ,f space )
  float32-mul  ( ,f nl ) 3 return1-n
end

def raycaster-hit-dist-y ( wx px angle -- dist )
  arg2 arg1 - int32->float32
  arg0 int32->float32 degrees->radians lut-cos float32-div 3 return1-n
end

def raycaster-hit-dist-x ( wy py angle -- dist )
  arg2 arg1 - int32->float32
  arg0 int32->float32 degrees->radians lut-sin float32-div 3 return1-n
end

def raycaster-angle-north-south? ( angle -- yes? )
  arg0 180 floored-mod
  local0 45 int>= local0 135 int<= and set-arg0
end

def raycaster-side-vec2d ( wy wx cy cx -- y x )
  arg2 arg0 - 0 int<=>
  arg3 arg1 - 0 int<=>
  4 return2-n
end

def raycaster-side-of ( wy wx cy cx -- dir )
  arg1 arg3 - 0 int<=> 1 + 3 *
  arg0 arg2 - 0 int<=> 1 + +
  4 return1-n
end

(    x ->
  y  \ | /
  |  -   -  0 degrees
  v  / | \ 45
)
225 270 315
180 0 0
135 90 45
9 here const> side-angles

def raycaster-side-angle
  side-angles arg0 seq-peek set-arg0
end

def raycaster-hit-y ( wy wx cy cx angle -- y x )
  3 argn arg1 int< IF
    arg3 1 + set-arg3
  THEN
  arg0 float32-tan
  arg3 arg1 - int32->float32 float32-mul
  arg2 int32->float32 float32-add
  arg3 int32->float32 5 return2-n
end

def raycaster-hit-x ( wy wx cy cx angle -- y x )
  4 argn arg2 int< IF
    4 argn 1 + 4 set-argn
  THEN
  4 argn arg2 - int32->float32
  arg0 float32-tan float32-div
  arg1 int32->float32 float32-add
  4 argn int32->float32 swap 5 return2-n
end

def raycaster-debug-hit-dist ( cell sky? wy wx cy cx angle -- dist )
  yellow arg0 .i space
  white 5 argn .i space
  white 6 argn .i space
  arg2 green .i space arg1 .i space 4 argn cyan .i space 3 argn .i space
  4 argn arg2 - white ,i space int32->float32
  arg3 arg1 - ,i space int32->float32
  2dup magnitude-float32 .f space
  yellow
  arg0 int32->float32 degrees->radians
  dup float32-tan .f space

  ( Valid hits are on the cell. )
  magenta
  4 argn arg3 arg2 arg1 5 overn raycaster-hit-y
  3 argn arg1 int< IF s" + " write-string/2 THEN
  2dup swap .f space .f space
  over 4 argn int32->float32 float32-sub hit-fudge-factor 1f in-range-float32?
  dup IF green s" V " write-string/2 THEN
  
  magenta
  4 argn arg3 arg2 arg1 8 overn raycaster-hit-x
  4 argn arg2 int< IF s" + " write-string/2 THEN
  2dup swap .f space .f space
  dup 3 argn int32->float32 float32-sub hit-fudge-factor 1f in-range-float32?
  dup IF green s" V " write-string/2 THEN

  red
  use-x @ 1 equals?
  IF drop
  ELSE
    use-x @ 2 equals?
    IF 4 dropn
    ELSE
      IF
	s"  X " write-string/2
      ELSE
	3 overn IF
	  s"  Y " write-string/2
	  3 dropn
	ELSE
	  s"  M " write-string/2
	  ( float32-infinity 5 return1-n )
	  3 dropn
	THEN
      THEN
    THEN
  THEN
  arg2 int32->float32
  arg1 int32->float32
  distance-float32
  yellow ,f space
  white nl
  7 return1-n
end

def raycaster-hit-coord ( wy wx cy cx angle -- hy hx y? )
  4 argn arg2 - int32->float32
  arg3 arg1 - int32->float32
  arg0 int32->float32 degrees->radians

  ( Valid hits are on the cell. )
  4 argn arg3 arg2 arg1 5 overn raycaster-hit-y
  over 4 argn int32->float32 float32-sub hit-fudge-factor 1f in-range-float32?

  4 argn arg3 arg2 arg1 8 overn raycaster-hit-x
  dup 3 argn int32->float32 float32-sub hit-fudge-factor 1f in-range-float32?

  use-x @ 1 equals?
  IF drop false
  ELSE
    use-x @ 2 equals?
    IF 4 dropn true
    ELSE
      IF ( use x ) false
      ELSE
	3 overn IF
	  ( use y )
	  3 dropn true
	ELSE
	  dup float32->int32 arg1 equals?
	  IF ( use y )
	    3 dropn true
	  ELSE ( use x )
	    false
	  THEN
	  ( float32-infinity 5 return1-n )
	  ( 3 dropn true )
	  ( false )
	THEN
      THEN
    THEN
  THEN
  set-arg2 set-arg3 4 set-argn 2 return0-n
end

def raycaster-hit-dist ( wy wx cy cx angle -- y? dist )
  4 argn arg3 arg2 arg1 arg0 raycaster-hit-coord roll
  arg2 int32->float32
  arg1 int32->float32
  distance-float32
  5 return2-n
end

def raycaster-draw-floor-vertical ( hit-dist wy wx camera world context n )
  ( Each horizontal defines a weight to interpolate along the ray.
From http://www.academictutorials.com/graphics/graphics-raycasting-ii.asp
  currentDist = h / [2.0 * y - h]
  weight = [currentDist - distPlayer] / [distWall - distPlayer]
  currentFloorPos = weight * floorPosWall + [1.0 - weight] * playerPos
  )
  ( needs the hit's precise xy and world xy move down along the ray; vertically it's height per unit. )
  arg1 TtyContext -> y @ arg1 tty-context-height int< UNLESS 7 return0-n THEN
  arg1 tty-context-height int32->float32
  arg1 TtyContext -> y @ 2 int-mul int32->float32
  over float32-sub float32-div ( 0: current distance )
  dup 6 argn float32-div ( 1: percent along ray )
  local1 5 argn arg3 WorldCamera -> y @ int32->float32 float32-lerp
  local1 4 argn arg3 WorldCamera -> x @ int32->float32 float32-lerp
  float32->int32 swap float32->int32 swap
  2dup arg2 world-get-cell-value
  dup 32 equals? IF
    ( checkered floor )
    rot + 1 logand IF 0x77 ELSE 0x00 THEN arg1 TtyContext -> color poke-byte
  ELSE
    raycaster-textures @ over seq-peek arg1 TtyContext -> color poke-byte
    rot 2 dropn
  THEN
  0 arg1 TtyContext -> attr !
  arg1 tty-context-set-char
  1 0 arg1 tty-context-move-by
  arg0 1 + set-arg0
  drop-locals repeat-frame
end

def raycaster-draw-ceiling-vertical ( wall-top hit-dist wy wx camera world context n )
  arg1 TtyContext -> y @ 7 argn int< UNLESS 8 return0-n THEN
  arg1 tty-context-height int32->float32
  arg1 TtyContext -> y @ 2 int-mul int32->float32
  over swap float32-sub float32-div ( 0: current distance: [H - y*2] / H )
  dup 6 argn float32-div ( 1: percent along ray )
  local1 5 argn arg3 WorldCamera -> y @ int32->float32 float32-lerp
  local1 4 argn arg3 WorldCamera -> x @ int32->float32 float32-lerp
  float32->int32 swap float32->int32 swap
  2dup arg2 world-get-cell-value
  dup 32 equals? IF
    ( checkered floor )
    ( rot + 1 logand IF 0x77 ELSE 0x00 THEN arg1 TtyContext -> color poke-byte )
    ( empty sky )
    *raycaster-threads* @ 0 equals? UNLESS
      0x65 arg1 TtyContext -> color !
      TTY-CELL-ATTR-MASKED arg1 TtyContext -> attr !
      32 arg1 tty-context-set-char
    THEN
  ELSE
    raycaster-textures @ over seq-peek arg1 TtyContext -> color poke-byte
    rot 2 dropn
    TTY-CELL-NORMAL arg1 TtyContext -> attr !
    arg1 tty-context-set-char
  THEN
  1 0 arg1 tty-context-move-by
  arg0 1 + set-arg0
  drop-locals repeat-frame
end

def raycaster-draw-wall ( y? height hit world context -- )
  ( todo turn black or sky color when way too far )
  arg2 RayCasterHit -> sky @ IF
    0x65 arg0 TtyContext -> color poke-byte
    33 arg0 TtyContext -> char !
    TTY-CELL-ATTR-MASKED arg0 TtyContext -> attr poke-byte
  ELSE
    ( set the context up for the wall )
    arg2 RayCasterHit -> y @ arg2 RayCasterHit -> x @ arg1 world-get-cell-value
    raycaster-textures @ over seq-peek arg0 TtyContext -> color poke-byte
    arg0 TtyContext -> char !
    arg3 arg0 tty-context-height 4 bsr int<
    4 argn or
    IF TTY-CELL-NORMAL ELSE TTY-CELL-DIM THEN arg0 TtyContext -> attr poke-byte
  THEN
  ( center the vertical: con_height/2 - wall/2 )
  ( dup 2 / arg0 tty-context-height 2 / swap - 0 arg0 tty-context-move-by )
  *raycaster-threads* @ 0 equals?
  arg2 RayCasterHit -> sky @ and IF
    arg3 1 + 0 arg0 tty-context-move-by
  ELSE
    arg3 arg0 TtyContext -> y @ + arg0 TtyContext -> x @ arg0 tty-context-line
  THEN
  5 return0-n
end
    
def raycaster-draw-vertical ( hit camera world context )
( setup the context for the vertical )
  0 arg0 TtyContext -> y !
  arg3 IF
    arg3 RayCasterHit -> screen-x @
    dup arg0 tty-context-width int< UNLESS 4 return0-n THEN
    arg0 TtyContext -> x !
    ( y, x of hit )
    ( arg3 cdr cdr car arg3 cdr car )
    arg3 RayCasterHit -> y @
    arg3 RayCasterHit -> x @
    0
    0
    ( compute the precise hit and distance )
    ( todo don't this here )
    local0 local1 arg2 world-camera-pos arg3 RayCasterHit -> angle @ raycaster-hit-coord
    set-local2 2dup set-local1 set-local0
    arg2 world-camera-pos int32->float32 swap int32->float32 swap distance-float32
    arg3 RayCasterHit -> angle @ arg2 WorldCamera -> angle @ -
    arg2 WorldCamera -> fov @ 2 /
    raycaster-fish-eye-correct
    dup set-local3
    ( clamp the wall's pixel height )
    arg0 tty-context-height int32->float32 swap float32-div float32->int32-rounded arg0 tty-context-height min 0 max
    ( draw the ceiling from the top )
    dup 2 / arg0 tty-context-height 2 / swap - 1 +
    local3 local0 local1 arg2 arg1 arg0 0 raycaster-draw-ceiling-vertical
    ( the wall )
    local2 over arg3 arg1 arg0 raycaster-draw-wall
    ( draw floor )
    local3 local0 local1 arg2 arg1 arg0 0 raycaster-draw-floor-vertical
  ELSE
    ( draw floor and ceiling. at least the angle needed )
  THEN
  arg0 TtyContext -> x inc!
  4 return0-n
end

def raycaster-cast-rays ( camera world width ++ hit-list )
  ( Cast rays centered on the camera for the full FOV and width. )
  arg2 WorldCamera -> fov @ raycaster-angle-bits bsl arg0 /
  arg1
  arg2 WorldCamera -> y @
  arg2 WorldCamera -> x @
  arg2 WorldCamera -> angle @
  arg2 WorldCamera -> fov @ 2 /
  2dup - raycaster-angle-bits bsl rot + raycaster-angle-bits bsl
  0 sweep-rays exit-frame
end

def raycaster-cast-rays/6 ( starting-sx max-sx step-sx camera world width ++ hit-list )
  ( Do a sweep of rays such that rays, centered on the camera's angle and bounded by the fov, are only cast for the verticals every step-sx in the region defined by starting-sx to max-sx. )
  ( d0/dSx = fov / width -> angle / pixel )
  ( d0 = d0/dSx * step-sx )
  5 argn
  arg3
  arg2 WorldCamera -> fov @ raycaster-angle-bits bsl arg0 / arg3 *
  arg1
  arg2 WorldCamera -> y @
  arg2 WorldCamera -> x @
  ( the min and max angles:
      starting-sx = 0, max-sx = width -> angle-fov/2 to angle+fov/2 every dO
      starting-sx != 0, max-sx != width -> angle-[fov/2]+fov*[starting/width] to angle-fov/2+fov*[max/width] every dO
 )
  arg2 WorldCamera -> angle @
  arg2 WorldCamera -> fov @ 2 / -
  dup 4 argn arg2 WorldCamera -> fov @ * arg0 / +
  swap 5 argn arg2 WorldCamera -> fov @ * arg0 / + swap
  raycaster-angle-bits bsl
  swap raycaster-angle-bits bsl swap
  0 sweep-rays/9 exit-frame
end

def raycaster-draw-rays/6 ( starting-vertical max-vertical vert-step camera world context )
  0
  ' raycaster-draw-vertical
  arg0 partial-first
  arg1 partial-first
  arg2 partial-first set-local0
  5 argn 4 argn arg3 arg2 arg1 arg0 tty-context-width raycaster-cast-rays/6 0 local0 revmap-cons/3
  6 return0-n
end

def raycaster-draw-rays ( camera world context )
  0 arg0 tty-context-width 1 arg2 arg1 arg0 raycaster-draw-rays/6
  3 return0-n
end

def raycaster-debug-vertical ( hit camera world context )
  arg3 IF
    white arg3 RayCasterHit -> screen-x @ write-int space
    ( y, x of hit )
    arg3 RayCasterHit -> cell @
    arg3 RayCasterHit -> sky @
    arg3 RayCasterHit -> y @
    arg3 RayCasterHit -> x @
    ( compute the distance )
    arg2 world-camera-pos arg3 RayCasterHit -> angle @ raycaster-debug-hit-dist
  ELSE
    arg3 car .i space
    arg0 TtyScreen -> height @ 2 / int32->float32
    arg3 car int32->float32 lut-degrees->vec2d 3 overn vec2d-scale .f space .f space nl
  THEN
  4 return0-n
end

def raycaster-debug-rays ( camera world screen )
  0
  ' raycaster-debug-vertical
  arg0 partial-first
  arg1 partial-first
  arg2 partial-first set-local0
  1 arg0 TtyScreen -> width @ 1 arg2 arg1 arg0 TtyScreen -> width @ raycaster-cast-rays/6 0 local0 revmap-cons/3
  10 arg0 TtyScreen -> height @ write-char-rep
  3 return0-n
end

def raycaster-minimap-row ( world context wy wx sy sx n counter -- )
  5 argn 4 argn arg0 2 / + 7 argn world-get-cell-value
  raycaster-textures @ over seq-peek
  0 arg3 arg2 arg0 + 6 argn tty-context-set-cell
  arg0 1 + set-arg0
  arg0 arg1 int< IF repeat-frame ELSE 7 return0-n THEN
end

def raycaster-minimap ( camera world context wy wx sy sx height width row -- )
  8 argn 7 argn
  6 argn arg0 + 5 argn
  4 argn arg0 + arg3
  arg1 0 raycaster-minimap-row
  arg0 1 + set-arg0
  arg0 arg2 int<
  IF repeat-frame
  ELSE
    6 argn arg2 2 / + 5 argn arg1 4 / + 8 argn world-get-cell-value
    raycaster-textures @ swap seq-peek
    TTY-CELL-BG logand 0x70 logior 7 argn TtyContext -> color poke-byte
    TTY-CELL-NORMAL 7 argn TtyContext -> attr poke-byte
    4 argn arg2 2 / +
    arg3 arg1 2 / dup 1 logand - + ( shift by 1 when width/2 is odd, ie: 88 columns )
    7 argn tty-context-move-to
    0x1f607 7 argn tty-context-write-byte
    -1 7 argn tty-context-write-byte
    10 return0-n
  THEN
end

def raycaster-draw-sun-disc
  arg1 arg0 tty-context-circle
  arg1 1 - set-arg1
  arg1 0 int> IF repeat-frame ELSE 2 return0-n THEN
end

def raycaster-draw-sun ( size vangle hangle camera world context )
  ( radius from percent of width to pixels )
  arg0 tty-context-width 5 argn * 100 / 1 max
  ( Vfov = FoV/w * h )
  ( h/2 - h*sin[time%360] )
  arg0 tty-context-height 2 /
  4 argn int32->float32 degrees->radians lut-sin
  over local0 + int32->float32 float32-mul float32->int32 -
  ( w/2 - W/FoV * A )
  arg0 tty-context-width dup 2 /
  swap raycaster-angle-bits bsl arg2 WorldCamera -> fov @ /
  arg2 WorldCamera -> angle @
  arg3 -
  ( fixme in-range? from north-words )
  360 int-mod 270 90 4 argn in-range? IF 3 dropn 180 + ELSE 3 dropn THEN
  dup 180 int>= IF 360 - THEN * raycaster-angle-bits absr -
  arg0 tty-context-move-to
  32 arg0 TtyContext -> char poke-byte
  TTY-CELL-NORMAL arg0 TtyContext -> attr poke-byte
  local0 arg0 raycaster-draw-sun-disc
  6 return0-n
end

def raycaster-draw-sky ( camera world context )
  ( sky )
  0x44 arg0 TtyContext -> color poke-byte
  32 arg0 TtyContext -> char poke-byte
  TTY-CELL-NORMAL arg0 TtyContext -> attr poke-byte
  0 0 arg0 tty-context-move-to
  arg0 tty-context-height 2 / arg0 tty-context-width arg0 tty-context-fill-rect
  ( north lower in the sky the further south )
  0x77 arg0 TtyContext -> color poke-byte
  1
  arg2 WorldCamera -> y @ raycaster-angle-bits bsl
  arg1 World -> height @ / 90 * raycaster-angle-bits absr
  90 swap -
  -90 arg2 arg1 arg0 raycaster-draw-sun
  ( sun rises in the east and sets in the west w/ time )
  0x33 arg0 TtyContext -> color poke-byte
  6
  get-time-secs 6 * 360 int-mod
  0 arg2 arg1 arg0 raycaster-draw-sun
  ( moon like the sun but moves ahead a bit each rotation )
  ( fixme the moon only makes half way around. )
  0x77 arg0 TtyContext -> color poke-byte
  4
  get-time-secs dup 6 * 360 int-mod swap 6 * 60 / 360 int-mod +
  0 arg2 arg1 arg0 raycaster-draw-sun
  3 return0-n
end

def raycaster-draw ( caster-buffer camera world buffer )
  0
  arg0 make-tty-context set-local0
  ( main display )
  ( 10 arg0 tty-context-height write-char-rep )
  ( ground & sky )
  arg2 arg1 local0  raycaster-draw-sky
  0x02 local0 TtyContext -> color poke-byte
  32 local0 TtyContext -> char poke-byte
  TTY-CELL-NORMAL arg0 TtyContext -> attr poke-byte
  local0 tty-context-height 2 / 0 local0 tty-context-move-to
  local0 tty-context-height dup 2 / swap 1 logand +
  local0 tty-context-width local0 tty-context-fill-rect
  ( rays )
  *raycaster-threads* @ IF
    0 0 local0 tty-context-move-to
    3 arg3 tty-double-buffer-lock/2 IF
      arg3 TtyDoubleBuffer -> front @ local0 tty-context-blit/2
      arg3 tty-double-buffer-unlock
    THEN
  ELSE
    arg2 arg1 local0 raycaster-draw-rays
    ( 0 local0 tty-context-width 1 arg2 arg1 local0 raycaster-draw-rays/6 )
  THEN
  ( minimap in top left quarter )
  arg2 arg1 local0
  arg2 WorldCamera -> y @ local0 tty-context-height 8 / -
  arg2 WorldCamera -> x @ local0 tty-context-width 16 / -
  0
  local0 tty-context-width
  local0 tty-context-height 4 /
  over 4 /
  3 overn over - 3 set-overn
  0 raycaster-minimap
  4 return0-n
end

( Multiple threads: budget of 4 to 8.
    Screen gets split for a render pool. Each thread handles casting and rendering a set of verticals: -regions or- interleaved. Would block on the page flip, -or locks it's region which composite thread acquires-. Lock free: casts and renders in a tight loop. Page flip may hurt. Will need to update when the inner loop restarts.
    An input thread opens up real-time-ish interaction. Local echo needs to be turned off, and redrawn as part of:
    Composite and dump to screen thread: combine buffers holding the sky, raycast, minimap, prompt.
    todo Logic, io, etc?
    toho Dead thread monitoring. One dies, everything goes.

todo Split prompt reading and drawing.
todo Sky needs to be drawn with the verticals. Computed as it's drawn or sampled from an updated buffer.

)
struct: CasterHerd
value field: casters

struct: Caster
value field: herd
value field: thread
value field: lock
value field: stopped
value field: cmd-code
value field: cmd-data
int field: offset
int field: step
pointer<any> field: camera
pointer<any> field: world
pointer<any> field: screen
int field: stage
value field: frame-ready

0 const> CASTER-CMD-NONE
1 const> CASTER-CMD-EXIT
2 const> CASTER-CMD-SET-SCREEN
3 const> CASTER-CMD-STOP
4 const> CASTER-CMD-CONTINUE
5 const> CASTER-CMD-SET-CAMERA

def caster-stopped?
  arg0 Caster -> stopped @ set-arg0
end

def caster-leader?
  arg0 Caster -> offset @ 0 equals? set-arg0
end

def caster-awaken
  1 arg0 Caster -> stopped futex-wake
  1 return0-n
end

def caster-resume
  false arg0 Caster -> stopped !
  arg0 caster-awaken
  1 return0-n
end

def caster-set-frame-ready/2
  arg0 Caster -> lock @ lock-acquire
  arg1 arg0 Caster -> frame-ready !
  arg0 Caster -> lock @ lock-release
  0x7FFFFFFF arg0 Caster -> frame-ready futex-wake
  2 return0-n
end

def caster-wait-for-ready-to-equal
  arg2 arg1 arg0 Caster -> frame-ready futex-wait-for-equals/3
  IF true 3 return1-n ELSE false 3 return2-n THEN
end

def caster-wait-for-ready-cleared
  arg1 0 arg0 caster-wait-for-ready-to-equal
  IF true 2 return1-n ELSE false 2 return2-n THEN
end

def caster-wait-for-frame-ready
  arg1 true arg0 caster-wait-for-ready-to-equal
  IF true 2 return1-n ELSE false 2 return2-n THEN
end

def all? ( fn list -- yes? )
  arg0 IF
    arg0 car arg1 exec-abs UNLESS false 2 return1-n THEN
    arg0 cdr set-arg0 repeat-frame
  ELSE true 2 return1-n
  THEN
end

def caster-frame-ready?
  arg0 Caster -> frame-ready @ 1 return1-n
end

def caster-herd-ready?
  ' caster-frame-ready? arg0 CasterHerd -> casters @ all? 1 return1-n
end

def caster-herd-clear-ready
  ' caster-set-frame-ready/2 false 1 partial-after
  arg0 CasterHerd -> casters @ over map-car 1 return0-n
end

def caster-herd-wait-for-frame-ready
  ' caster-wait-for-frame-ready arg1 1 partial-after
  arg0 CasterHerd -> casters @ all?
  2 return1-n
end

def caster-herd-wait-for-ready-cleared
  ' caster-wait-for-ready-cleared arg1 1 partial-after
  arg0 CasterHerd -> casters @ all?
  2 return1-n
end

def caster-process-cmd ( caster -- done? )
  arg0 Caster -> lock @ lock-acquire
  arg0 Caster -> cmd-code @ CASE
    CASTER-CMD-EXIT OF
      s" Thread exit " error-string/2
	 arg0 Caster -> thread @ Thread -> tid @ .i enl
	 arg0 Caster -> lock @ lock-release
	 true 1 return1-n
      ENDOF
    CASTER-CMD-STOP OF true arg0 Caster -> stopped ! ENDOF
    CASTER-CMD-CONTINUE OF false arg0 Caster -> stopped ! ENDOF
    CASTER-CMD-SET-SCREEN OF arg0 Caster -> cmd-data @ arg0 Caster -> screen ! ENDOF
    CASTER-CMD-SET-CAMERA OF arg0 Caster -> cmd-data @ arg0 Caster -> camera @ copy-world-camera-to ENDOF
    drop
  ENDCASE
  0 arg0 Caster -> cmd-code !
  0 arg0 Caster -> cmd-data !
  arg0 Caster -> lock @ lock-release
  0x7FFFFFFF arg0 Caster -> cmd-code futex-wake
  false 1 return1-n
end

def caster-thread-fn
  0 arg0 Caster -> stage !
  arg0 caster-process-cmd IF bye return0 THEN
  arg0 Caster -> stopped @ IF
    -1 arg0 Caster -> stage !
    5 secs->timespec value-of arg0 Caster -> stopped futex-wait/2
    drop-locals repeat-frame
  THEN
  ( cast and draw rays )
  0 0
  1 arg0 Caster -> stage !
  arg0 caster-leader? IF
    arg0 Caster -> herd @ caster-herd-clear-ready
  ELSE
    1 arg0 caster-wait-for-ready-cleared UNLESS
      -2 arg0 Caster -> stage !
      arg0 Caster -> screen @ tty-double-buffer-get make-tty-context set-local0
      0x01 local0 TtyContext -> color poke-byte
      0 arg0 Caster -> offset @ local0 tty-context-move-to
      88 local0 tty-context-set-char
      drop-locals repeat-frame
    THEN
  THEN
  2 arg0 Caster -> stage !
  arg0 Caster -> screen @ tty-double-buffer-get make-tty-context set-local0
  arg0 Caster -> offset @
  local0 tty-context-width
  arg0 Caster -> step @
  arg0 Caster -> camera @
  arg0 Caster -> world @
  local0 raycaster-draw-rays/6
  3 arg0 Caster -> stage !
  true arg0 caster-set-frame-ready/2
  arg0 caster-leader? IF
    3 arg0 Caster -> herd @ caster-herd-wait-for-frame-ready UNLESS
      2 1 local0 tty-context-move-to
      0x70 local0 TtyContext -> color poke-byte
      TTY-CELL-NORMAL local0 TtyContext -> attr poke-byte
      s" Timed out" local0 tty-context-write-string/3
    THEN
    4 arg0 Caster -> stage !
    2 arg0 Caster -> screen @ tty-double-buffer-swap/2 drop
    5 arg0 Caster -> stage !
  ELSE
    5 arg0 Caster -> stage !
  THEN
  drop-locals repeat-frame
end

def caster-start
  arg0 ' caster-thread-fn thread-start IF
    s" Caster thread started " error-string/2
    dup Thread -> tid @ .i enl
    arg0 Caster -> thread !
    arg0 true exit-frame
  ELSE
    s" Caster thread failed to start: " error-string/2
    dup error-int espace
    dup errno->string error-string enl
    false 1 return2-n
  THEN
end

def caster-wait-for-command
  arg1 0 arg0 Caster -> cmd-code futex-wait-for-equals/3
  IF true 2 return1-n
  ELSE false 2 return2-n
  THEN
end

def caster-command/3
  arg0 Caster -> lock @ lock-acquire
  arg2 arg0 Caster -> cmd-data !
  arg1 arg0 Caster -> cmd-code !
  arg0 Caster -> lock @ lock-release
  arg0 caster-stopped? IF arg0 caster-awaken THEN
  0x7FFFFFFF arg0 Caster -> cmd-code futex-wake
  3 return0-n
end

def caster-command/2
  0 arg1 arg0 caster-command/3 2 return0-n
end

def caster-join
  20 arg0 Caster -> thread @ thread-join/2 1 return1-n
end

def destroy-caster
  arg0 Caster -> thread @ thread-alive? IF
    CASTER-CMD-EXIT arg0 caster-command/2
    arg0 caster-join
  THEN
  arg0 Caster -> thread @ destroy-thread
  1 return0-n
end

def caster-set-camera
  arg1 CASTER-CMD-SET-CAMERA arg0 caster-command/3
  2 return0-n
end

( A herd of caster threads spread across the screen. )

0 var> caster-herd

def caster-herd-stop
  arg0 CasterHerd -> casters @ ' destroy-caster map-car
  1 return0-n
end

def caster-herd-wait-for-command
  ' caster-wait-for-command arg1 1 partial-after
  arg0 CasterHerd -> casters @ over map-car
  2 return0-n
end

def caster-herd-set-camera
  ' caster-set-camera arg1 1 partial-after
  arg0 CasterHerd -> casters @ over map-car
  2 arg0 caster-herd-wait-for-command
  2 return0-n
end

def raycaster-make-caster ( [ camera world tty-buffer number-threads ] n herd ++ caster )
  0
  Caster make-instance set-local0
  Lock make-instance local0 Caster -> lock !
  arg0 local0 Caster -> herd !
  ( north/words has seq-peek patched to seqn-peek )
  arg1 local0 Caster -> offset !
  arg2 @ local0 Caster -> step !
  arg2 2 seq-peek copy-world-camera local0 Caster -> camera !
  arg2 1 seq-peek local0 Caster -> world !
  arg2 0 seq-peek local0 Caster -> screen !
  local0 exit-frame
end

def caster-herd-start ( start-args counter herd ++ herd ok? )
  arg1 arg2 @ int>= IF arg0 true exit-frame THEN
  0
  arg2 arg1 arg0 raycaster-make-caster set-local0
  local0 caster-start IF
    local0 arg0 CasterHerd -> casters push-onto
    arg1 1 + set-arg1
    repeat-frame
  ELSE
    arg0 caster-herd-stop
    arg0 false exit-frame
  THEN
end

def raycaster-start-herd ( camera world tty-buffer number-threads ++ herd ok? )
  CasterHerd make-instance print-instance
  args 0 3 overn caster-herd-start
  exit-frame
end

def raycaster-draw-caster-info ( caster context -- )
  arg1 Caster -> stage @ arg0 tty-context-write-int
  s" :" arg0 tty-context-write-string/3
  arg1 Caster -> frame-ready @ 1 logand arg0 tty-context-write-uint
  s"  " arg0 tty-context-write-string/3
  2 return0-n
end

def raycaster-draw-prompt ( herd camera world screen -- )
  0
  arg0 make-tty-context set-local0
  ( thread state )
  local0 tty-context-height 6 - 1 local0 tty-context-move-to
  0x70 local0 TtyContext -> color poke-byte
  TTY-CELL-NORMAL local0 TtyContext -> attr poke-byte
  arg3 IF
    ' raycaster-draw-caster-info local0 partial-first
    arg3 CasterHerd -> casters @ over map-car
  THEN
  0x70 local0 TtyContext -> color poke-byte
  local0 tty-context-height 5 - 1 local0 tty-context-move-to
  arg2 WorldCamera -> angle @ local0 tty-context-write-int 0xB0 local0 tty-context-write-byte
  ( now for prompt )
  local0 tty-context-height 4 - 1 local0 tty-context-move-to
  the-reader @ reader-buffer @ the-reader @ reader-offset @ local0 tty-context-write-string/3
  local0 tty-context-height 3 - 1 local0 tty-context-move-to
  s"  > " local0 tty-context-write-string/3
  token-buffer @ token-buffer-length @ local0 tty-context-write-string/3
  ( fake a cursor )
  0x07 local0 TtyContext -> color poke-byte
  32 local0 tty-context-write-byte
  4 return0-n
end

def raycaster-prompt ( herd camera world screen -- repeat? )
  here prompt-here !
  *raycaster-poll-timeout* @ 0 int>= IF
    ( todo an async next-token that can accumulate each call. presently will block until a token is read if it reads a byte, even in raw mode )
    current-input @ *raycaster-poll-timeout* @ poll-fd-in
    UNLESS true 4 return1-n THEN
  THEN
  ( Emacs' ansi-term will already be at the bottom but will ignore thin move )
  arg0 TtyBuffer -> height @ 1 tty-cursor-to 2 dropn
  ( align with what was drawn for the prompt. will be removed fram here soon. )
  tty-cursor-home 1 tty-cursor-up
  tty-show-cursor
  next-token dup 0 int<= IF true 4 return1-n THEN
  2 overn CASE
    s" bye" OF-STR false 4 return1-n ENDOF
    s" dump" OF-STR arg2 arg1 arg0 raycaster-debug-rays ENDOF
    drop
  ENDCASE
  2 overn CASE
    s" r" OF-STR arg2 WorldCamera -> angle 360 15 wrapped-inc!/3 drop ENDOF  
    s" R" OF-STR arg2 WorldCamera -> angle 360 45 wrapped-inc!/3 drop ENDOF  
    s" l" OF-STR arg2 WorldCamera -> angle 360 15 wrapped-dec!/3 drop ENDOF  
    s" L" OF-STR arg2 WorldCamera -> angle 360 45 wrapped-dec!/3 drop ENDOF  
    s" c" OF-STR arg2 WorldCamera -> angle 360 180 wrapped-inc!/3 drop ENDOF  
    s" n" OF-STR arg2 WorldCamera -> y dec! drop ENDOF  
    s" s" OF-STR arg2 WorldCamera -> y inc! drop ENDOF  
    s" w" OF-STR arg2 WorldCamera -> x dec! drop ENDOF  
    s" e" OF-STR arg2 WorldCamera -> x inc! drop ENDOF
    s" v" OF-STR arg2 WorldCamera -> fov 10 dec!/2 drop ENDOF  
    s" V" OF-STR arg2 WorldCamera -> fov 10 inc!/2 drop ENDOF
    s" x" OF-STR use-x 3 wrapped-inc! drop ENDOF
    drop
  ENDCASE
  arg3 IF arg2 arg3 caster-herd-set-camera THEN
  true 4 return1-n
end

def raycaster-inner-loop ( cast-buffer start-time frame camera world screen ++ repeat? )
  arg0 tty-screen-resized? IF s" resized" error-line/2 true 6 return1-n THEN
  5 argn arg2 arg1 arg0 tty-screen-buffer raycaster-draw
  caster-herd @ arg2 arg1 arg0 tty-screen-buffer raycaster-draw-prompt
  arg0 tty-screen-draw
  caster-herd @ arg2 arg1 arg0 tty-screen-buffer raycaster-prompt
  UNLESS false 6 return1-n THEN
  arg3 1 + set-arg3
  drop-locals repeat-frame
end

def raycaster-outer-loop ( start-time camera world -- )
  0 0 0 0 0
  tty-getsize make-tty-screen
  dup tty-screen-erase
  dup tty-screen-draw-copy
  set-local0
  tty-getsize make-tty-double-buffer set-local1
  *raycaster-threads* @ IF
    s" Starting herd" error-line/2
    arg1 arg0 local1 *raycaster-threads* @ raycaster-start-herd IF
      caster-herd !
    ELSE
      0 *raycaster-threads* !
      0 caster-herd !
    THEN
  THEN
  local1 arg2 0 arg1 arg0 local0 raycaster-inner-loop
  *raycaster-threads* @ IF
    s" Stopping herd" error-line/2
    caster-herd @ caster-herd-stop
    0 caster-herd !
  THEN
  IF drop-locals repeat-frame ELSE 3 return0-n THEN
end

def raycaster-init
  raycaster-texture-init
  trig-lut-init
  exit-frame
end

" src/demos/tty/raycaster-worlds.4th" load

def raycaster-start ( world )
  0
  raycaster-textures @ UNLESS s" exec raycaster-init" error-line/2 return0 THEN
  8 8 0 raycaster-init-fov @ make-world-camera set-local0
  get-time-secs local0 arg0 raycaster-outer-loop
end

def raycaster-turn
  0 *raycaster-threads* !
  -1 *raycaster-poll-timeout* !
  arg0 raycaster-start
end

4 var> *raycaster-default-threads*

def raycaster-real
  *raycaster-default-threads* @ *raycaster-threads* !
  0 *raycaster-poll-timeout* !
  tty-enter-raw-mode
  arg0 raycaster-start
  tty-exit-raw-mode
end

def reload!
  " src/demos/tty/raycast.4th" load
  s" raycaster-init" load-string/2 exit-frame
end
