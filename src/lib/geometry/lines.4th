( Horizontal lines: )

' maxmin [UNLESS]
def maxmin
  arg1 arg0 minmax set-arg1 set-arg0
end
[THEN]

def hline-fn-loop ( fn accum y x2 x1 ++ accum )
  arg3 arg2 arg0 4 argn exec-abs UNLESS exit-frame THEN set-arg3
  arg0 1 + set-arg0
  arg0 arg1 int<= IF repeat-frame ELSE arg3 exit-frame THEN
end

def hline-fn ( fn accum y x2 x1 ++ accum )
  4 argn arg3 arg2 arg1 arg0 maxmin hline-fn-loop exit-frame
end

( Vertical lines: )

def vline-fn-loop ( fn accum y2 y1 x ++ accum )
  arg3 arg1 arg0 4 argn exec-abs UNLESS exit-frame THEN set-arg3
  arg1 1 + set-arg1
  arg1 arg2 int<= IF repeat-frame ELSE arg3 exit-frame THEN
end

def vline-fn ( fn accum y2 y1 x ++ accum )
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

def make-line-state ( dir y x dy dx ++ LineState )
  LineState make-instance
  arg3 over LineState -> y !
  arg2 over LineState -> x !
  arg1 over LineState -> dy !
  arg0 over LineState -> dx !
  4 argn over LineState -> dir !
  exit-frame
end

def make-line-state-x ( dir y x dy dx ++ LineState )
  4 argn arg3 arg2 arg1 arg0 make-line-state
  arg1 2 * over LineState -> d2 !
  dup LineState -> d2 @ arg0 2 * - over LineState -> m2 !
  dup LineState -> d2 @ arg0 - over LineState -> err !
  exit-frame
end

( |dx| > dy )
def line-fn-loop-x ( fn accum state ++ accum )
  arg1 arg0 LineState -> y @ arg0 LineState -> x @ arg2 exec-abs set-arg1
  arg0 LineState -> err @ 0 int>= IF
    arg0 LineState -> y @ 1 + arg0 LineState -> y !
    arg0 LineState -> m2 @ arg0 LineState -> err @ + arg0 LineState -> err !
  ELSE arg0 LineState -> d2 @ arg0 LineState -> err @ + arg0 LineState -> err !
  THEN
  arg0 LineState -> x @ arg0 LineState -> dir @ + arg0 LineState -> x !
  arg0 LineState -> dx @ 1 - arg0 LineState -> dx !
  arg0 LineState -> dx @ 0 int>= IF repeat-frame ELSE arg1 exit-frame THEN
end

def line-fn-loop-x0 ( fn accum y1 x1 y0 x0 ++ accum )
  arg2 arg0 int> IF 1 ELSE -1 THEN arg1 arg0 arg3 arg1 - arg2 arg0 - make-line-state-x
  5 argn 4 argn 3 overn line-fn-loop-x exit-frame
end

def line-fn-loop-x0 ( fn accum dir y x dy dx ++ accum )
  4 argn arg3 arg2 arg1 arg0  make-line-state-x
  6 argn 5 argn 3 overn line-fn-loop-x exit-frame
end

def make-line-state-y ( dir y x dy dx ++ LineState )
  4 argn arg3 arg2 arg1 arg0 make-line-state
  arg0 2 * over LineState -> d2 !
  dup LineState -> d2 @ arg1 2 * - over LineState -> m2 !
  dup LineState -> d2 @ arg1 - over LineState -> err !
  exit-frame
end

( |dy| > dx )
def line-fn-loop-y ( fn accum state ++ accum )
  arg1 arg0 LineState -> y @ arg0 LineState -> x @ arg2 exec-abs set-arg1
  arg0 LineState -> err @ 0 int>= IF
    arg0 LineState -> x @ arg0 LineState -> dir @ + arg0 LineState -> x !
    arg0 LineState -> m2 @ arg0 LineState -> err @ + arg0 LineState -> err !
  ELSE arg0 LineState -> d2 @ arg0 LineState -> err @ + arg0 LineState -> err !
  THEN
  arg0 LineState -> y @ 1 + arg0 LineState -> y !
  arg0 LineState -> dy @ 1 - arg0 LineState -> dy !
  arg0 LineState -> dy @ 0 int>= IF repeat-frame ELSE arg1 exit-frame THEN
end

def line-fn-loop-y0 ( fn accum y1 x1 y0 x0 ++ accum )
  arg2 arg0 int> IF 1 ELSE -1 THEN arg1 arg0 arg3 arg1 - arg2 arg0 - make-line-state-y
  5 argn 4 argn 3 overn line-fn-loop-y exit-frame
end

def line-fn-loop-y0 ( fn accum dir y x dy dx ++ accum )
  4 argn arg3 arg2 arg1 arg0 make-line-state-y
  6 argn 5 argn 3 overn line-fn-loop-y exit-frame
end


( todo when integer rise/run is zero, use run/rise )

def line-fn ( fn accum y2 x2 y1 x1 ++ accum )
  ( swap start and end so y1 > y2 )
  arg1 arg3 int> IF
    arg3 arg1 set-arg3 set-arg1
    arg2 arg0 set-arg2 set-arg0
  THEN
  ( local0 => dx )
  arg2 arg0 - dup UNLESS ( dx == 0: vertical )
    drop
    5 argn 4 argn arg3 arg1 arg0 vline-fn-loop exit-frame
  THEN
  ( local1 => dy )
  arg3 arg1 - dup UNLESS ( dy == 0: horizontal )
    2 dropn
    5 argn 4 argn arg1 arg2 arg0 hline-fn exit-frame
  THEN
  ( handle the four cases )
  local0 0 int> IF
    local0 local1 int> IF
      5 argn 4 argn 1 arg1 arg0 local1 local0 line-fn-loop-x0
    ELSE
      5 argn 4 argn 1 arg1 arg0 local1 local0 line-fn-loop-y0
    THEN
  ELSE
    local0 negate set-local0
    local0 local1 int> IF
      5 argn 4 argn -1 arg1 arg0 local1 local0 line-fn-loop-x0
    ELSE
      5 argn 4 argn -1 arg1 arg0 local1 local0 line-fn-loop-y0
    THEN
  THEN
  4 argn exit-frame
end

( Another Bresenham line drawer, see: http://members.chello.at/~easyfilter/bresenham.html )
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

def line-state2-step
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
  return0
end

def line-state2-done?
  arg0 LineState2 -> x1 @ arg0 LineState2 -> x2 @ equals?
  arg0 LineState2 -> y1 @ arg0 LineState2 -> y2 @ equals?
  and set-arg0
end

def line-fn-loop ( state fn accum ++ accum )
  ( call fn )
  arg0
  arg2 LineState2 -> y1 @
  arg2 LineState2 -> x1 @
  arg1 exec-abs UNLESS exit-frame THEN set-arg0
  ( done? )
  arg2 line-state2-done?
  IF arg0 exit-frame
  ELSE ( next pixel )
    arg2 line-state2-step drop
    repeat-frame
  THEN
end

def line-fn ( fn accum y2 x2 y1 x1 ++ accum )
  ( local0: dx )
  arg2 arg0 - dup UNLESS ( dx == 0: vertical )
    drop
    5 argn 4 argn arg1 arg3 arg0 vline-fn exit-frame
  THEN
  ( local1: dy )
  arg3 arg1 - dup UNLESS ( dy == 0: horizontal )
    2 dropn
    5 argn 4 argn arg1 arg2 arg0 hline-fn exit-frame
  THEN
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
  5 argn 4 argn line-fn-loop exit-frame
end
