( doing textured lines: may need to make callers do the step loop for multiple lerps )
( todo fractional x,y for raycaster: pass line state to callback )
( todo reordering start and end breaks the raycaster, why bresenham was used explicitly and why axis rays fail w/ vline and hline )
 
( Horizontal lines: )

' maxmin UNLESS
def maxmin
  arg1 arg0 minmax set-arg1 set-arg0
end
THEN

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

( Bresenham's line drawing:
   For Abrash's implementation in C see http://www.phatcode.net/res/224/files/html/ch35/35-03.html
   Or for the one that always calls the function going from start point to end point
   see http://members.chello.at/~easyfilter/bresenham.html )

struct: LineState
int field: x1 ( starting )
int field: y1
int field: x2 ( ending )
int field: y2
int field: dx ( |x2 - x1| )
int field: dy ( |y2 - y1| )
int field: sx ( step in x dir: -1 or +1 )
int field: sy ( step in y dir )
int field: err ( error accumulator )

def make-line-state ( y2 x2 y1 x1 ++ state )
  LineState make-instance
  arg0 over LineState -> x1 !
  arg1 over LineState -> y1 !
  arg2 over LineState -> x2 !
  arg3 over LineState -> y2 !
  arg2 arg0 - dup abs-int 3 overn LineState -> dx !
  0 int> IF 1 ELSE -1 THEN over LineState -> sx !
  arg3 arg1 - dup abs-int negate 3 overn LineState -> dy !
  0 int> IF 1 ELSE -1 THEN over LineState -> sy !
  dup LineState -> dx @ over LineState -> dy @ + over LineState -> err !
  exit-frame
end

def line-state-done?
  arg0 LineState -> x1 @ arg0 LineState -> x2 @ equals?
  arg0 LineState -> y1 @ arg0 LineState -> y2 @ equals?
  and set-arg0
end

def line-state-step ( state -- )
  arg0 LineState -> err @ 1 bsl ( 2 * )
  dup arg0 LineState -> dy @ int>= IF
    arg0 LineState -> dy @ arg0 LineState -> err @ + arg0 LineState -> err !
    arg0 LineState -> sx @ arg0 LineState -> x1 @ + arg0 LineState -> x1 !
  THEN
  dup arg0 LineState -> dx @ int<= IF
    arg0 LineState -> dx @ arg0 LineState -> err @ + arg0 LineState -> err !
    arg0 LineState -> sy @ arg0 LineState -> y1 @ + arg0 LineState -> y1 !
  THEN
  1 return0-n
end

def bresenham-line-loop ( state fn accum ++ accum )
  ( call fn )
  arg0
  arg2 LineState -> y1 @
  arg2 LineState -> x1 @
  arg1 exec-abs UNLESS exit-frame THEN set-arg0
  ( done? )
  arg2 line-state-done?
  IF arg0 exit-frame
  ELSE arg2 line-state-step repeat-frame
  THEN
end

def bresenham-line-fn ( fn[accum y x ++ accum more?] accum y2 x2 y1 x1 ++ accum )
  arg3 arg2 arg1 arg0 make-line-state
  5 argn 4 argn bresenham-line-loop exit-frame
end

def line-fn ( fn[accum y x ++ accum more?] accum y2 x2 y1 x1 ++ accum )
  arg2 arg0 equals? IF ( dx == 0: vertical )
    5 argn 4 argn arg1 arg3 arg0 vline-fn
  ELSE
    arg3 arg1 equals? IF ( dy == 0: horizontal )
      5 argn 4 argn arg1 arg2 arg0 hline-fn
    ELSE
      5 argn 4 argn arg3 arg2 arg1 arg0 bresenham-line-fn
    THEN
  THEN exit-frame
end
