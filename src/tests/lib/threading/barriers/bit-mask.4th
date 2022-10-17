s[ src/lib/linux/threads.4th
   src/lib/threading/lock.4th
   src/lib/threading/barriers/bit-mask.4th
   src/lib/sleepers.4th
   src/lib/assert.4th
] load-list

def test-bit-mask-barrier-fn
  10 arg0 1 seqn-peek arg0 0 seqn-peek bit-mask-barrier-wait-for IF
    true arg0 2 seqn-peek !
  ELSE
    false arg0 2 seqn-peek !
  THEN 2 return0-n
end

def test-bit-mask-barrier-usage
  0 0 0 0
  make-bit-mask-barrier set-local0
  locals 2 cell-size * - 1 local0 3
  here ' test-bit-mask-barrier-fn thread-start IF local1 swap cons set-local1 THEN
  locals 3 cell-size * - 4 local0 3
  here ' test-bit-mask-barrier-fn thread-start IF local1 swap cons set-local1 THEN
  ' thread-wait-to-start/2 3 1 partial-after local1 swap map-car
  5 local0 bit-mask-barrier-set
  1 sleep
  4 local0 bit-mask-barrier-set
  1 sleep
  3 local0 bit-mask-barrier-set
  1 sleep
  2 local0 bit-mask-barrier-set
  1 sleep
  1 local0 bit-mask-barrier-set
  1 sleep
  0 local0 bit-mask-barrier-set
  debug? IF s" Joining" error-line/2 THEN
  local1 ' thread-join map-car
  local2 true assert-equals
  local3 true assert-equals ( todo let timeout expire? )
  local0 BitMaskBarrier -> bits @ 0x3F assert-equals
  debug? IF s" Destroying" error-line/2 THEN
  local1 ' destroy-thread map-car
end

def test-bit-mask-barrier-all-bits-fn
  debug? IF s" Waiting for bit " error-string/2 arg0 1 seq-peek error-int enl THEN
  arg0 1 seq-peek 7 equals? IF 2 ELSE 4 THEN
  1 arg0 1 seq-peek bsl
  arg0 0 seq-peek bit-mask-barrier-wait-for IF
    debug? IF s" Change noticed " error-string/2 arg0 1 seq-peek .i enl THEN
    arg0 2 seq-peek
    1 arg0 1 seq-peek bsl
    logior arg0 2 seq-poke
  ELSE
    debug? IF s" Timed out " error-string/2 THEN
    arg0 3 seq-peek
    1 arg0 1 seq-peek bsl
    logior arg0 3 seq-poke
  THEN
  arg0 1 seq-peek 1 + arg0 1 seq-poke
  arg0 1 seq-peek 32 uint< IF repeat-frame THEN
  ( todo wait for set, clear, change )
  debug? IF s" Waiting for clears " error-string/2 arg0 1 seq-peek .i enl THEN
  5 0x00F00000 arg0 0 seq-peek bit-mask-barrier-wait-for
  IF 1 arg0 4 seq-poke THEN
  40 0x1F7F arg0 0 seq-peek bit-mask-barrier-wait-for-equals
  IF arg0 4 seq-peek 2 logior arg0 4 seq-poke
  ELSE errno->string error-line
  THEN
  40 0 arg0 0 seq-peek bit-mask-barrier-wait-for
  IF arg0 4 seq-peek 4 logior arg0 4 seq-poke
  ELSE errno->string error-line
  THEN 2 return0-n
end

def test-bit-mask-barrier-all-bits-up-loop
  arg0 32 int< UNLESS 2 return0-n THEN
  arg0 7 equals? IF
    3 sleep
  ELSE
    arg0 arg1 bit-mask-barrier-set
    debug? IF s" Set bit " error-string/2 arg0 error-int enl THEN
    arg0 31 equals IF 5 ELSE 1 THEN sleep
  THEN
  arg0 1 + set-arg0 repeat-frame
end

def test-bit-mask-barrier-all-bits-down-loop
  arg0 1 - set-arg0
  arg0 arg1 bit-mask-barrier-clear
  debug? IF
    s" Cleared bit " error-string/2 arg0 error-int espace
    arg1 BitMaskBarrier -> bits @ error-hex-uint enl
  THEN
  arg0 0 int> UNLESS 2 return0-n THEN
  1 sleep
  repeat-frame
end

def test-bit-mask-barrier-all-bits
  0 0 0
  make-bit-mask-barrier set-local0
  0 0 0 0 local0 here set-local2
  local2 ' test-bit-mask-barrier-all-bits-fn thread-start
  IF set-local1 ELSE return0 THEN
  3 local1 thread-wait-to-start/2
  local0 0 test-bit-mask-barrier-all-bits-up-loop
  1 sleep
  local0 bit-mask-barrier-bits 0xFFFFFF7F assert-equals
  local2 1 seq-peek 32 assert-equals
  local2 2 seq-peek 0xFFFFFF7F assert-equals
  local2 3 seq-peek 0x00000080 assert-equals
  local2 4 seq-peek 1 assert-equals ( catches a wait on an already set bit )
  local0 32 test-bit-mask-barrier-all-bits-down-loop
  1 sleep
  local0 bit-mask-barrier-bits 0 assert-equals
  local2 4 seq-peek 7 assert-equals
  local1 thread-join
  local1 destroy-thread
end

def test-bit-mask-barrier
  test-bit-mask-barrier-usage
  test-bit-mask-barrier-all-bits
end
