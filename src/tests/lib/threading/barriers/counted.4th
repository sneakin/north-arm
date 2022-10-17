s[ src/lib/linux/threads.4th
   src/lib/threading/lock.4th
   src/lib/threading/barriers/counted.4th
   src/lib/sleepers.4th
   src/lib/assert.4th
] load-list

def test-counted-barrier-fn
  debug? IF hello arg0 1 seqn-peek .i enl THEN
  10 arg0 1 seqn-peek arg0 0 seqn-peek counted-barrier-wait-for IF
    debug? IF ok arg0 1 seqn-peek .i enl THEN
    true arg0 2 seqn-peek !
  ELSE
    debug? IF boom arg0 1 seqn-peek .i enl THEN
    false arg0 2 seqn-peek !
  THEN 2 return0-n
end

def test-counted-barrier
  0 0 0 0 0 0 ( barrier thread-list t1-data t2-dana t3-data )
  make-counted-barrier set-local0
  ( thread 1: would wake but wake-op only supports 12 bits )
  locals 2 cell-size * - -2 local0 2
  here ' test-counted-barrier-fn thread-start IF local1 swap cons set-local1 THEN
  ( thread 2: times out )
  locals 3 cell-size * - 10 local0 2
  here ' test-counted-barrier-fn thread-start IF local1 swap cons set-local1 THEN
  ( thread 3: gets woken )
  locals 4 cell-size * - 3 local0 2
  here ' test-counted-barrier-fn thread-start IF local1 swap cons set-local1 THEN
  ' thread-wait-to-start/2 3 1 partial-after local1 swap map-car
  1 sleep
  local0 CountedBarrier -> count @ 0 assert-equals
  local0 counted-barrier-dec
  local0 CountedBarrier -> count @ -1 assert-equals
  1 sleep
  local0 counted-barrier-dec
  local0 CountedBarrier -> count @ -2 assert-equals
  1 sleep
  local0 counted-barrier-inc
  local0 CountedBarrier -> count @ -1 assert-equals
  1 sleep
  local0 counted-barrier-inc
  local0 CountedBarrier -> count @ 0 assert-equals
  1 sleep
  local0 counted-barrier-inc
  local0 CountedBarrier -> count @ 1 assert-equals
  1 sleep
  local0 counted-barrier-inc
  local0 CountedBarrier -> count @ 2 assert-equals
  1 sleep
  local0 counted-barrier-inc
  local0 CountedBarrier -> count @ 3 assert-equals
  1 sleep
  local0 counted-barrier-inc
  1 sleep
  local0 counted-barrier-inc
  1 sleep
  local0 counted-barrier-inc
  debug? IF s" Joining" error-line/2 THEN
  local1 ' thread-join map-car
  ( tests )
  local2 true assert-equals
  local3 false assert-equals
  4 localn true assert-equals
  debug? IF s" Destroying" error-line/2 THEN
  local1 ' destroy-thread map-car
end
