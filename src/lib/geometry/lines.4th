( doing textured lines: may need to make callers do the step loop for multiple lerps )
( todo fractional x,y for raycaster: pass line state to callback )
( todo reordering start and end breaks the raycaster, why bresenham was used explicitly and why axis rays fail w/ vline and hline )
 
( Horizontal lines: )

' maxmin [UNLESS]
def maxmin
  arg1 arg0 minmax set-arg1 set-arg0
end
[THEN]

def hline-fn-loop ( fn[accum y x ++ accum more?] accum y x2 x1 ++ accum )
  arg3 arg2 arg0 4 argn exec-abs UNLESS exit-frame THEN set-arg3
  arg0 1 + set-arg0
  arg0 arg1 int<= IF repeat-frame ELSE arg3 exit-frame THEN
end

def hline-fn ( fn[accum y x ++ accum more?] accum y x2 x1 ++ accum )
  4 argn arg3 arg2 arg1 arg0 maxmin hline-fn-loop exit-frame
end

( Vertical lines: )

def vline-fn-loop ( fn[accum y x ++ accum more?] accum y2 y1 x ++ accum )
  arg3 arg1 arg0 4 argn exec-abs UNLESS exit-frame THEN set-arg3
  arg1 1 + set-arg1
  arg1 arg2 int<= IF repeat-frame ELSE arg3 exit-frame THEN
end

def vline-fn ( fn[accum y x ++ accum more?] accum y2 y1 x ++ accum )
  4 argn arg3 arg2 arg1 maxmin arg0 vline-fn-loop exit-frame
end

( Bresenham's line drawing, see http://www.phatcode.net/res/224/files/html/ch35/35-03.html )

struct: LineState
int field: x
int field: y
int field: dx
int field: dy
int field: err
int field: d2
int field: m2
int field: dir

def init-line-state ( state d_pri d_sec -- state )
  arg0 2 * arg2 LineState -> d2 !
  arg2 LineState -> d2 @ arg1 2 * - arg2 LineState -> m2 !
  arg2 LineState -> d2 @ arg1 - arg2 LineState -> err !
  arg2 3 return1-n
end

def make-line-state ( y x dy dx ++ LineState )
  LineState make-instance
  arg0 0 int> IF 1 ELSE -1 THEN over LineState -> dir !
  arg3 over LineState -> y !
  arg2 over LineState -> x !
  arg1 over LineState -> dy !
  arg0 dup 0 int< IF negate THEN
  dup 3 overn LineState -> dx !
  arg1 2dup int< IF swap THEN init-line-state exit-frame
end


( todo inc and dec )

( |dx| > dy )
def ma-line-step-x ( state -- more? )
  arg0 LineState -> err @ 0 int>= IF
    arg0 LineState -> y inc!
    arg0 LineState -> err arg0 LineState -> m2 @ inc!/2
  ELSE arg0 LineState -> err arg0 LineState -> d2 @ inc!/2
  THEN
  arg0 LineState -> x arg0 LineState -> dir @ inc!/2
  arg0 LineState -> dx dec!
  arg0 LineState -> dx @ 0 int>= set-arg0
end

def ma-line-loop-x ( fn[accum y x ++ accum more?] accum state ++ accum )
  arg1 arg0 LineState -> y @ arg0 LineState -> x @ arg2 exec-abs UNLESS exit-frame THEN set-arg1
  arg0 ma-line-step-x IF repeat-frame ELSE arg1 exit-frame THEN
end


( |dy| > dx )
def ma-line-step-y ( state -- done? )
  arg0 LineState -> err @ 0 int>= IF
    arg0 LineState -> x arg0 LineState -> dir @ inc!/2
    arg0 LineState -> err arg0 LineState -> m2 @ inc!/2
  ELSE arg0 LineState -> err arg0 LineState -> d2 @ inc!/2
  THEN
  arg0 LineState -> y inc!
  arg0 LineState -> dy dec!
  arg0 LineState -> dy @ 0 int>= set-arg0
end

def ma-line-loop-y ( fn[accum y x ++ accum more?] accum state ++ accum )
  arg1 arg0 LineState -> y @ arg0 LineState -> x @ arg2 exec-abs UNLESS exit-frame THEN set-arg1
  arg0 ma-line-step-y IF repeat-frame ELSE arg1 exit-frame THEN
end


( todo when integer rise/run is zero, use run/rise )

def ma-line-fn ( fn[accum y x ++ accum more?] accum y2 x2 y1 x1 ++ accum )
  ( swap start and end so y1 > y2 )
  arg1 arg3 int> IF
    arg3 arg1 set-arg3 set-arg1
    arg2 arg0 set-arg2 set-arg0
  THEN
  ( local0 => dx )
  arg2 arg0 -
  ( local1 => dy )
  arg3 arg1 -
	arg1 arg0 local1 local0 make-line-state
  5 argn 4 argn 3 overn
  dup LineState -> dx @ local1 int> IF ma-line-loop-x ELSE ma-line-loop-y THEN exit-frame
end

( Another Bresenham line drawer, see: http://members.chello.at/~easyfilter/bresenham.html
  that always calls the function going from start point to end point. )
struct: LineState2
int field: x1
int field: y1
int field: x2
int field: y2
int field: dx
int field: dy
int field: sx
int field: sy
int field: err

def line-state2-done?
  arg0 LineState2 -> x1 @ arg0 LineState2 -> x2 @ equals?
  arg0 LineState2 -> y1 @ arg0 LineState2 -> y2 @ equals?
  and set-arg0
end

def line-state2-step ( state -- )
  ( Abrash's line breaks this and line-fn's loop into x and y functions )
  arg0 LineState2 -> err @ 1 bsl ( 2 * )
  dup arg0 LineState2 -> dy @ int>= IF
    arg0 LineState2 -> dy @ arg0 LineState2 -> err @ + arg0 LineState2 -> err !
    arg0 LineState2 -> sx @ arg0 LineState2 -> x1 @ + arg0 LineState2 -> x1 !
  THEN
  dup arg0 LineState2 -> dx @ int<= IF
    arg0 LineState2 -> dx @ arg0 LineState2 -> err @ + arg0 LineState2 -> err !
    arg0 LineState2 -> sy @ arg0 LineState2 -> y1 @ + arg0 LineState2 -> y1 !
  THEN
  1 return0-n
end

def bresenham-line-loop ( state fn accum ++ accum )
  ( call fn )
  arg0
  arg2 LineState2 -> y1 @
  arg2 LineState2 -> x1 @
  arg1 exec-abs UNLESS exit-frame THEN set-arg0
  ( done? )
  arg2 line-state2-done?
  IF arg0 exit-frame
  ELSE arg2 line-state2-step repeat-frame
  THEN
end

def bresenham-line-fn ( fn[accum y x ++ accum more?] accum y2 x2 y1 x1 ++ accum )
  ( local0: dx )
  arg2 arg0 - 
  ( local1: dy )
  arg3 arg1 -
  LineState2 make-instance
  arg0 over LineState2 -> x1 !
  arg1 over LineState2 -> y1 !
  arg2 over LineState2 -> x2 !
  arg3 over LineState2 -> y2 !
  local0 abs-int over LineState2 -> dx !
  local1 abs-int negate over LineState2 -> dy !
  local0 0 int> IF 1 ELSE -1 THEN over LineState2 -> sx !
  local1 0 int> IF 1 ELSE -1 THEN over LineState2 -> sy !
  dup LineState2 -> dx @ over LineState2 -> dy @ + over LineState2 -> err !
  5 argn 4 argn bresenham-line-loop exit-frame
end

alias> line-fn-inner ma-line-fn

def line-fn ( fn[accum y x ++ accum more?] accum y2 x2 y1 x1 ++ accum )
  arg2 arg0 equals? IF ( dx == 0: vertical )
    5 argn 4 argn arg1 arg3 arg0 vline-fn
  ELSE
    arg3 arg1 equals? IF ( dy == 0: horizontal )
      5 argn 4 argn arg1 arg2 arg0 hline-fn
    ELSE
      5 argn 4 argn arg3 arg2 arg1 arg0 line-fn-inner
    THEN
  THEN exit-frame
end
