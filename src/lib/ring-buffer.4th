struct: RingBuffer
uint field: size
pointer<any> field: buffer
uint field: in-index
uint field: out-index

def init-ring-buffer
  arg1 cell-size * stack-allot arg0 RingBuffer -> buffer !
  arg1 arg0 RingBuffer -> size !
  0 arg0 RingBuffer -> in-index !
  0 arg0 RingBuffer -> out-index !
  arg0 exit-frame
end

def make-ring-buffer
  RingBuffer make-instance arg0 swap init-ring-buffer exit-frame
end

def ring-buffer-empty?
  arg0 RingBuffer -> in-index @
  arg0 RingBuffer -> out-index @
  equals? 1 return1-n
end

def ring-buffer-full?
  arg0 RingBuffer -> in-index @ here arg0 RingBuffer -> size @ 1 wrapped-inc!/3 drop
  arg0 RingBuffer -> out-index @
  equals? 1 return1-n
end

def ring-buffer-wait-for-msg/2 ( seconds ring-buffer -- true | error false )
  arg0 ring-buffer-empty? UNLESS true 2 return1-n THEN
  arg1 secs->timespec value-of
  arg0 RingBuffer -> out-index @
  arg0 RingBuffer -> in-index futex-wait/3 dup UNLESS
    arg0 ring-buffer-empty? IF drop-locals repeat-frame THEN
    true 2 return1-n
  ELSE
    ( really make sure )
    arg0 ring-buffer-empty?
    IF false 2 return2-n ELSE true 2 return1-n THEN
  THEN
end

def ring-buffer-wait-for-msg ( ring-buffer -- true | error false )
  arg0 -1 set-arg0 ' ring-buffer-wait-for-msg/2 tail+1
end

def ring-buffer-wait-for-space/2 ( seconds ring-buffer -- true | error false )
  arg0 ring-buffer-full? UNLESS true 2 return1-n THEN
  arg1 secs->timespec value-of
  arg0 RingBuffer -> in-index @ here arg0 RingBuffer -> size @ 1 wrapped-inc!/3 drop
  arg0 RingBuffer -> out-index futex-wait/3 dup UNLESS
    arg0 ring-buffer-full? IF drop-locals repeat-frame THEN
    true 2 return1-n
  ELSE
    ( really make sure )
    arg0 ring-buffer-full?
    IF false 2 return2-n ELSE true 2 return1-n THEN
  THEN
end

def ring-buffer-wait-for-space ( ring-buffer -- true | error false )
  arg0 -1 set-arg0 ' ring-buffer-wait-for-space/2 tail+1
end

def ring-buffer-push
  arg0 ring-buffer-full?
  IF false
  ELSE
    arg1 arg0 RingBuffer -> buffer @ arg0 RingBuffer -> in-index @ seq-poke
    arg0 RingBuffer -> in-index arg0 RingBuffer -> size @ 1 wrapped-inc!/3 drop
    1 arg0 RingBuffer -> in-index futex-wake
    true
  THEN 2 return1-n
end

def ring-buffer-pop
  arg0 ring-buffer-empty?
  IF false 1 return1-n
  ELSE
    arg0 RingBuffer -> buffer @ arg0 RingBuffer -> out-index @ seq-peek
    arg0 RingBuffer -> out-index arg0 RingBuffer -> size @ 1 wrapped-inc!/3 drop
    1 arg0 RingBuffer -> out-index futex-wake drop
    true 1 return2-n
  THEN
end
