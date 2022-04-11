( todo Infinite ray is caused by hline and vline. They need to traverse from x0 -> x1 and not min to max )

' TtyBuffer [UNLESS]
s[ src/lib/tty.4th
   src/lib/geometry/angles.4th
   src/lib/linux/clock.4th
   src/lib/linux/stat.4th
   src/lib/io.4th
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


( The world: )

struct: World
pointer<any> field: cells
int field: width
int field: height

def make-world
  World make-instance
  arg1 over World -> height !
  arg0 over World -> width !
  arg2 over World -> cells !
  exit-frame
end

" src/demos/tty/raycaster-worlds.4th" load
0 var> raycaster-textures

def raycaster-digit-textures
  arg0 dup 4 bsl logior arg1 char-code 0 arg0 + seq-poke
  arg0 1 + set-arg0
  arg0 10 int< IF repeat-frame ELSE 1 return0-n THEN
end

def raycaster-init
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
  0 raycaster-digit-textures
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
    arg0 World -> cells @
    arg0 World -> width @ arg2 * arg1 +
    string-peek
  ELSE 0 THEN 3 return1-n
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

( Casting rays through the world: )

struct: RayCasterHit
int field: angle
int field: x
int field: y
int field: sky
int field: cell

def make-ray-caster-hit
  args RayCasterHit cons exit-frame
end

def cast-ray-fn ( world y x angle ++ world | hit )
  arg2 raycaster-ray-bits absr arg1 raycaster-ray-bits absr arg3 world-get-cell-value
  world-cell-sky? IF
    true
    arg2 raycaster-ray-bits absr
    arg1 raycaster-ray-bits absr
    arg0 make-ray-caster-hit false exit-frame
    ( drop 0 arg0 cons false exit-frame )
  THEN
  world-cell-solid? IF ( make a list of angle, y, x )
    false
    arg2 raycaster-ray-bits absr
    arg1 raycaster-ray-bits absr
    arg0 make-ray-caster-hit false exit-frame
    ( drop 0 arg2 raycaster-ray-bits absr cons arg1 raycaster-ray-bits absr cons arg0 cons false exit-frame )
  THEN
  arg3 true 4 return2-n
end

def cast-ray ( world y x angle ++ hit )
  arg0 int32->float32 degrees->vec2d
  1024 int32->float32 float32-mul float32->int32 arg1 + raycaster-ray-bits bsl swap
  1024 int32->float32 float32-mul float32->int32 arg2 + raycaster-ray-bits bsl swap
  ( s" casting to " write-string/2 arg2 .i space arg1 .i space arg0 .i space
  local1 .i space local0 .i nl )
  ' cast-ray-fn arg0 partial-first
  arg3 local0 local1
  arg2 raycaster-ray-bits bsl
  arg1 raycaster-ray-bits bsl
  bresenham-line-fn exit-frame
end

( todo map-range )

def sweep-rays ( dO*256 world y x from*256 to*256 accum ++ hits )
  5 argn 4 argn arg3 arg2 raycaster-angle-bits absr cast-ray
  dup 5 argn equals? IF
    ( s" No hit " write-string/2 arg2 write-int nl )
    0 arg2 cons set-arg0
  ELSE
    ( you saw it. )
    arg0 swap cons set-arg0
  THEN
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
int field: x
int field: y
int field: angle
int field: fov

def make-world-camera ( y x angle ++ camera )
  WorldCamera make-instance
  arg2 over WorldCamera -> y !
  arg1 over WorldCamera -> x !
  arg0 over WorldCamera -> angle !
  raycaster-init-fov @ over WorldCamera -> fov !
  exit-frame
end

def world-camera-pos
  arg0 WorldCamera -> y @ arg0 WorldCamera -> x @ 1 return2-n
end

( Ray caster hit rendering: )

def raycaster-fish-eye-correct ( distance vertical-angle fov/2 -- fixed-distance )
  ( Verticals get bowed so the middle verticals look too tall. This makes the outer verticals taller. )
  arg1 int32->float32 ( ,f space ) degrees->radians ( ,f space )
  float32-cos ( ,f space )
  arg2 ( ,f space )
  float32-mul  ( ,f nl ) 3 return1-n
end

def raycaster-hit-dist-y ( wx px angle -- dist )
  arg2 arg1 - int32->float32
  arg0 int32->float32 degrees->radians float32-cos float32-div 3 return1-n
end

def raycaster-hit-dist-x ( wy py angle -- dist )
  arg2 arg1 - int32->float32
  arg0 int32->float32 degrees->radians float32-sin float32-div 3 return1-n
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
  arg1 TtyContext -> y @ arg1 tty-context-height int<
  IF drop-locals repeat-frame
  ELSE 7 return0-n
  THEN
end

def raycaster-draw-vertical ( hit camera world context )
  arg0 TtyContext -> x @ arg0 tty-context-width int<
  arg3 cdr and IF
    ( y, x of hit )
    ( arg3 cdr cdr car arg3 cdr car )
    arg3 RayCasterHit -> y @
    arg3 RayCasterHit -> x @
    0
    0
    ( setup the context for the cell )
    0 arg0 TtyContext -> y !
    local0 local1 arg1 world-get-cell-value
    dup arg0 TtyContext -> char !
    raycaster-textures @ over seq-peek arg0 TtyContext -> color poke-byte
    ( compute the precise hit and distance )
    local0 local1 arg2 world-camera-pos arg3 RayCasterHit -> angle @ raycaster-hit-coord
    set-local2 2dup set-local1 set-local0
    arg2 world-camera-pos int32->float32 swap int32->float32 swap distance-float32
    arg3 RayCasterHit -> angle @ arg2 WorldCamera -> angle @ -
    arg2 WorldCamera -> fov @ 2 /
    raycaster-fish-eye-correct
    dup set-local3
    ( todo turn black or sky color when way too far )
    local2 over float32->int32 8 int> or IF TTY-CELL-NORMAL ELSE TTY-CELL-DIM THEN arg0 TtyContext -> attr poke-byte
    ( adjust to wall's pixel height one map unit away )
    arg0 tty-context-height int32->float32 swap float32-div float32->int32 arg0 tty-context-height min 0 max
    ( center the vertical: con_height/2 - wall/2 )
    dup 2 / arg0 tty-context-height 2 / swap - 0 arg0 tty-context-move-by    
    arg3 RayCasterHit -> sky @ IF
      1 + 0 arg0 tty-context-move-by
    ELSE
      arg0 TtyContext -> y @ + arg0 TtyContext -> x @ arg0 tty-context-line
    THEN
    ( draw floor )
    ( needs the hit's precise xy and world xy move down along the ray; vertically it's height per unit. )
    local3 local0 local1 arg2 arg1 arg0 0 raycaster-draw-floor-vertical
  THEN
  arg0 TtyContext -> x inc!
  4 return0-n
end

def raycaster-cast-rays ( camera world width ++ hit-list )
  arg2 WorldCamera -> fov @ raycaster-angle-bits bsl arg0 /
  arg1
  arg2 WorldCamera -> y @
  arg2 WorldCamera -> x @
  arg2 WorldCamera -> angle @
  arg2 WorldCamera -> fov @ 2 /
  2dup - raycaster-angle-bits bsl rot + raycaster-angle-bits bsl
  0 sweep-rays exit-frame
end

def raycaster-draw-rays ( camera world context )
  0
  ' raycaster-draw-vertical
  arg0 partial-first
  arg1 partial-first
  arg2 partial-first set-local0
  arg2 arg1 arg0 tty-context-width raycaster-cast-rays 0 local0 revmap-cons/3
  ( 10 arg0 tty-context-height write-char-rep )
  3 return0-n
end

def raycaster-debug-vertical ( hit camera world context )
  arg3 cdr IF
    ( y, x of hit )
    ( arg3 cdr cdr car arg3 cdr car )
    arg3 RayCasterHit -> cell @
    arg3 RayCasterHit -> sky @
    arg3 RayCasterHit -> y @
    arg3 RayCasterHit -> x @
    ( compute the distance )
    arg2 world-camera-pos arg3 RayCasterHit -> angle @ raycaster-debug-hit-dist
  ELSE
    arg3 car .i space
    arg0 TtyScreen -> height @ 2 / int32->float32
    arg3 car int32->float32 degrees->vec2d 3 overn vec2d-scale .f space .f space nl
  THEN
  4 return0-n
end

def raycaster-debug-rays ( camera world screen )
  0
  ' raycaster-debug-vertical
  arg0 partial-first
  arg1 partial-first
  arg2 partial-first set-local0
  arg2 arg1 arg0 TtyScreen -> width @ raycaster-cast-rays 0 local0 revmap-cons/3
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
    0x71 7 argn TtyContext -> color poke-byte
    TTY-CELL-NORMAL 7 argn TtyContext -> attr poke-byte
    4 argn arg2 2 / +
    arg3 arg1 2 / dup 1 logand - + ( shift by 1 when width/2 is odd, ie: 88 columns )
    7 argn tty-context-move-to
    char-code : 7 argn tty-context-write-byte
    char-code ) 7 argn tty-context-write-byte
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
  4 argn int32->float32 degrees->radians float32-sin
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
  0x77 arg0 TtyContext -> color poke-byte
  4
  get-time-secs dup 6 * 360 int-mod swap 6 * 60 / 360 int-mod +
  0 arg2 arg1 arg0 raycaster-draw-sun
  3 return0-n
end

def raycaster-draw ( camera world buffer )
  0
  arg0 make-tty-context set-local0
  ( main display )
  arg2 arg1 local0  raycaster-draw-sky
  ( ground & sky )
  0x02 local0 TtyContext -> color poke-byte
  32 local0 TtyContext -> char poke-byte
  TTY-CELL-NORMAL arg0 TtyContext -> attr poke-byte
  local0 tty-context-height 2 / 0 local0 tty-context-move-to
  local0 tty-context-height dup 2 / swap 1 logand +
  local0 tty-context-width local0 tty-context-fill-rect
  ( rays )
  0 0 local0 tty-context-move-to
  arg2 arg1 local0 raycaster-draw-rays
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
  3 return0-n
end

def raycaster-prompt ( camera world screen -- repeat? )
  arg2 WorldCamera -> angle @
  here prompt-here !
  arg0 TtyScreen -> height @ 2 - 1 tty-cursor-to 2 dropn
  tty-show-cursor
  next-token 2dup error-line/2
  " bye" 3 overn 3 overn string-equals?/3 IF false 3 return1-n ELSE 3 dropn THEN
  " r" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> angle 360 15 wrapped-inc!/3 drop ELSE 3 dropn THEN  
  " R" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> angle 360 45 wrapped-inc!/3 drop ELSE 3 dropn THEN  
  " l" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> angle 360 15 wrapped-dec!/3 drop ELSE 3 dropn THEN  
  " L" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> angle 360 45 wrapped-dec!/3 drop ELSE 3 dropn THEN  
  " c" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> angle 360 180 wrapped-inc!/3 drop ELSE 3 dropn THEN  
  " n" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> y dec! drop ELSE 3 dropn THEN  
  " s" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> y inc! drop ELSE 3 dropn THEN  
  " w" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> x dec! drop ELSE 3 dropn THEN  
  " e" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> x inc! drop ELSE 3 dropn THEN
  " v" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> fov 10 dec!/2 drop ELSE 3 dropn THEN  
  " V" 3 overn 3 overn string-equals?/3 IF arg2 WorldCamera -> fov 10 inc!/2 drop ELSE 3 dropn THEN
  " x" 3 overn 3 overn string-equals?/3 IF use-x 3 wrapped-inc! drop ELSE 3 dropn THEN
  " dump" 3 overn 3 overn string-equals?/3 IF arg2 arg1 arg0 raycaster-debug-rays ELSE 3 dropn THEN
  true 3 return1-n
end

def raycaster-inner-loop ( start-time frame camera world screen ++ repeat? )
  arg0 tty-screen-resized? IF true 5 return1-n THEN
  arg2 arg1 arg0 tty-screen-buffer raycaster-draw
  arg0 tty-screen-draw
  arg2 arg1 arg0 raycaster-prompt UNLESS false 5 return1-n THEN
  arg3 1 + set-arg3
  drop-locals repeat-frame
end

def raycaster-outer-loop ( start-time camera world -- )
  0
  tty-getsize make-tty-screen
  dup tty-screen-erase
  dup tty-screen-draw-copy
  set-local0
  arg2 0 arg1 arg0 local0 raycaster-inner-loop
  IF drop-locals repeat-frame ELSE 3 return0-n THEN
end

def raycaster ( world )
  0
  raycaster-textures @ UNLESS s" exec raycaster-init" error-line/2 return0 THEN
  8 8 0 make-world-camera set-local0
  get-time-secs local0 arg0 raycaster-outer-loop
end

def reload!
  " src/demos/tty/raycast.4th" load
  s" raycaster-init" load-string/2 exit-frame
end
