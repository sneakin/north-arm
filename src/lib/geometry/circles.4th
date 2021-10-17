( Bresenham's circle drawing, see: https://www.geeksforgeeks.org/bresenhams-circle-drawing-algorithm/ )

struct: CircleState
int field: cx
int field: cy
int field: radius
int field: x
int field: y
int field: d

def make-circle-state ( cy cx r ++ circle-state )
  CircleState make-instance
  arg2 over CircleState -> cy !
  arg1 over CircleState -> cx !
  arg0 over CircleState -> radius !
  0 over CircleState -> x !
  arg0 over CircleState -> y !
  3 arg0 2 * - over CircleState -> d !
  exit-frame
end

def eighth-circle-fn-loop ( fn accum circle-state ++ accum )
  ( plot point[s] )
  arg1 arg0 arg2 exec-abs UNLESS exit-frame THEN set-arg1
  ( update state )
  arg0 CircleState -> x dup @ 1 + swap !
  arg0 CircleState -> d @ 0 int> IF
    arg0 CircleState -> y dup @ 1 - swap !
    ( d = d + 4 * [x - y] + 10 )
    arg0 CircleState -> d dup @
    arg0 CircleState -> x @ arg0 CircleState -> y @ - 4 * 10 + +
    swap !
  ELSE
    ( d = d + 4 * x + 6 )
    arg0 CircleState -> d dup @
    arg0 CircleState -> x @ 4 * 6 + +
    swap !
  THEN
  ( loop? )
  arg0 CircleState -> y @ arg0 CircleState -> x @ int>=
  IF repeat-frame ELSE arg1 exit-frame THEN
end

def eighth-circle-fn ( fn accum cy cx r ++ accum )
  arg2 arg1 arg0 make-circle-state
  4 argn arg3 3 overn eighth-circle-fn-loop exit-frame
end

def circle-fn-caller ( fn accum circle-state ++ accum )
  ( Calls ~fn~ with [accum y x] )
  arg0 CircleState -> y @ arg0 CircleState -> x @
  arg0 CircleState -> cy @ arg0 CircleState -> cx @
  ( call fn w/ points on the circle )
  arg1
  local2 local0 + local3 local1 + arg2 exec-abs UNLESS false exit-frame THEN
  local2 local0 + local3 local1 - arg2 exec-abs UNLESS false exit-frame THEN
  local2 local0 - local3 local1 + arg2 exec-abs UNLESS false exit-frame THEN
  local2 local0 - local3 local1 - arg2 exec-abs UNLESS false exit-frame THEN
  ( x/y flipped )
  local2 local1 + local3 local0 + arg2 exec-abs UNLESS false exit-frame THEN
  local2 local1 + local3 local0 - arg2 exec-abs UNLESS false exit-frame THEN
  local2 local1 - local3 local0 + arg2 exec-abs UNLESS false exit-frame THEN
  local2 local1 - local3 local0 - arg2 exec-abs UNLESS false exit-frame THEN
  true exit-frame
end

def circle-fn ( fn accum cy cx r ++ accum )
  arg0 0 equals?
  IF arg3 arg2 arg1 4 argn exec-abs
  ELSE ' circle-fn-caller 4 argn 2 partial-after
       arg3 arg2 arg1 arg0 eighth-circle-fn
  THEN exit-frame
end
