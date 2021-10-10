struct: EllipseState
int field: x0 ( left edge )
int field: y0 ( top of screen, lowest edge )
int field: x1 ( right edge )
int field: y1 ( bottom of screen, larger edge )
int field: a ( horizontal diameter )
int field: b1 ( vertical diameter LSB )
int field: b ( vertical diameter )
int field: dx ( change in X )
int field: dy ( change in Y )
int field: err ( accumulator of error )

def ellipse-state-x-done?
  arg0 EllipseState -> x0 @
  arg0 EllipseState -> x1 @ int> set-arg0
end

def ellipse-state-y-done?
  arg0 EllipseState -> y0 @
  arg0 EllipseState -> y1 @ -
  arg0 EllipseState -> b @ int>= set-arg0
end

def ellipse-state-step
  arg0 EllipseState -> err @ 2 *
  dup arg0 EllipseState -> dy @ int<= IF
    arg0 EllipseState -> y0 inc!
    arg0 EllipseState -> y1 dec!
    arg0 EllipseState -> dy arg0 EllipseState -> a @ inc!/2
    arg0 EllipseState -> err arg0 EllipseState -> dy @ inc!/2
  THEN
  dup arg0 EllipseState -> dx @ int>=
  over 2 * arg0 EllipseState -> dy @ int> or IF
    arg0 EllipseState -> x0 inc!
    arg0 EllipseState -> x1 dec!
    arg0 EllipseState -> dx arg0 EllipseState -> b1 @ inc!/2
    arg0 EllipseState -> err arg0 EllipseState -> dx @ inc!/2
  THEN
  1 return0-n
end

def ellipse-fn-loop-y  ( state fn accum ++ accum )
  ( call fn )
  arg0 arg2 EllipseState -> y0 @ arg2 EllipseState -> x0 @ 1 - arg1 exec-abs UNLESS exit-frame THEN set-arg0
  arg0 arg2 EllipseState -> y0 @ arg2 EllipseState -> x1 @ 1 + arg1 exec-abs UNLESS exit-frame THEN set-arg0
  arg0 arg2 EllipseState -> y1 @ arg2 EllipseState -> x0 @ 1 - arg1 exec-abs UNLESS exit-frame THEN set-arg0
  arg0 arg2 EllipseState -> y1 @ arg2 EllipseState -> x1 @ 1 + arg1 exec-abs UNLESS exit-frame THEN set-arg0
  ( loop )
  arg2 EllipseState -> y0 inc! drop
  arg2 EllipseState -> y1 dec! drop
  arg2 ellipse-state-y-done? IF arg0 exit-frame ELSE repeat-frame THEN
end

def ellipse-fn-quadrant-call ( state fn accum ++ accum )
  ( Call fn, with accum, y, x, for pixels in each quadrant. )
  arg0 arg2 EllipseState -> y0 @ arg2 EllipseState -> x1 @ arg1 exec-abs UNLESS false exit-frame THEN set-arg0
  arg0 arg2 EllipseState -> y0 @ arg2 EllipseState -> x0 @ arg1 exec-abs UNLESS false exit-frame THEN set-arg0
  arg0 arg2 EllipseState -> y1 @ arg2 EllipseState -> x0 @ arg1 exec-abs UNLESS false exit-frame THEN set-arg0
  arg0 arg2 EllipseState -> y1 @ arg2 EllipseState -> x1 @ arg1 exec-abs UNLESS false exit-frame THEN set-arg0
  ( returns accum )
  arg0 true exit-frame
end

def ellipse-fn-loop  ( state fn accum ++ accum )
  ( call fn )
  arg2 arg1 arg0 ellipse-fn-quadrant-call UNLESS exit-frame THEN set-arg0
  ( next pixel )
  arg2 ellipse-state-step
  ( done? )
  arg2 ellipse-state-x-done?
  IF
    ( draw the pixels in thin ellipses )
    arg2 ellipse-state-y-done?
    IF arg0 exit-frame
    ELSE arg2 arg1 arg0 ellipse-fn-loop-y exit-frame
    THEN
  ELSE repeat-frame
  THEN
end

def make-ellipse-state ( y1 x1 y0 x0 )
  EllipseState make-instance
  ( sort edges )
  arg3 arg1 minmax dup set-arg3 3 overn EllipseState -> y1 ! dup set-arg1 over EllipseState -> y0 !
  arg2 arg0 minmax dup set-arg2 3 overn EllipseState -> x1 ! dup set-arg0 over EllipseState -> x0 !
  ( diameters )
  arg2 arg0 - abs-int over EllipseState -> a !
  arg3 arg1 - abs-int dup 3 overn EllipseState -> b !
  1 logand over EllipseState -> b1 !
  ( slopes )
  1 over EllipseState -> a @ - 4 * over EllipseState -> b @ dup * *
  over EllipseState -> dx !
  1 over EllipseState -> b1 @ + 4 * over EllipseState -> a @ dup * *
  over EllipseState -> dy !
  ( initial error )
  dup EllipseState -> dx @ over EllipseState -> dy @ +
  over EllipseState -> b1 @ 3 overn EllipseState -> a @ dup * * +
  over EllipseState -> err !
  ( start with Y coordinates at the top and bottom )
  dup EllipseState -> b @ 1 + 2 / arg1 + over EllipseState -> y0 !
  dup EllipseState -> y0 @ over EllipseState -> b1 @ - over EllipseState -> y1 !
  ( a = a ** 2 * 8 )
  dup EllipseState -> a @ dup * 8 * over EllipseState -> a !
  ( b = b ** 2 * 8 )
  dup EllipseState -> b @ dup * 8 * over EllipseState -> b1 !
  exit-frame
end
  
def ellipse-fn ( fn accum y1 x1 y0 x0 ++ accum )
  arg3 arg2 arg1 arg0 make-ellipse-state 5 argn 4 argn ellipse-fn-loop exit-frame
end
