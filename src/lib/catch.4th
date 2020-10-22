( Exceptions:
  try pushes a function to call, previous handler, and return address.
  throw pops the catcher and calls its handler before returning to the catcher's return address.
  end-try patches in the return address try needs and pops the catcher.
)

( todo try/rescue/end-try where rescue provides the handler. )
( todo move eip, frame, rstack, .data section into continuation )

0 var> the-catcher

( Accessors for the state try needs: )

def catcher-link end
def catcher-frame arg0 cell-size + set-arg0 end
def catcher-rstack arg0 cell-size 2 * + set-arg0 end
def catcher-exit arg0 cell-size 3 * + set-arg0 end
def catcher-fn arg0 cell-size 4 * + set-arg0 end

symbol> try-placeholder

def do-try ( fn exit frame )
  arg0 the-catcher poke
end

: try/1
  ( make a catcher )
  literal int32 try-placeholder
  literal eip literal +
  literal return-stack literal peek
  literal current-frame
  literal the-catcher literal peek
  ( todo store eip and sp for retry )
  literal here
  ( set the-catcher )
  literal do-try
; immediate

def pop-catcher
  the-catcher peek dup null? UNLESS
    dup catcher-link peek the-catcher poke
  THEN return1
end

def try-patcher
  arg0 peek read-terminator equals UNLESS
    arg0 peek try-placeholder equals
    IF arg1 arg0 swap - arg0 poke
    ELSE arg0 up-stack set-arg0 repeat-frame
    THEN
  THEN
end

def end-try
  ( todo drop stack values? )
  ( todo returns need to pop the catcher. Have try start a frame that returns here? Still needs to return from parent frame. Flag frame pointers as being nested? )
  ( todo freeing the catcher )
  args 1 down-stack/2 args try-patcher
  ( called when nothing is thrown )
  literal pop-catcher literal drop
  return2
end immediate

def uncaught-exception
  " Error: uncaught exception" write-string space
  arg0 write-hex-uint nl
  ( todo quit that resets stack, dict, fp; or interp w/ debug prompt )
  current-frame parent-frame frame-args 128 memdump
  interp
end

def throw
  pop-catcher
  dup UNLESS drop arg0 uncaught-exception THEN
  arg0 over catcher-fn speek dup IF exec-abs ELSE drop THEN
  ( jump to end of the try block )
  local0
  dup catcher-frame peek set-current-frame
  dup catcher-rstack peek return-stack poke
  catcher-exit peek jump
end

def retry
  ( set the frame to the try block's and jump to the first call. the popped catcher needs to be somewhere. )
end

def test-try-throw
  " what" write-line
  123 throw
end

def test-try-in-call
  " hello" write-line
  test-try-throw
end

def test-try-rethrow
  " rescue" write-line
  throw
end

def test-try-double
  ' test-try-rethrow try/1
  test-try-throw
  end-try
end
  
def test-try
  ' .s try/1
  test-try-double
  end-try
  ok nl
end

def test-try-nested-inner
  ' write-hex-int try/1
  test-try-in-call
  end-try
end

def test-try-nested
  ' write-hex-int try/1
  test-try-nested-inner
  end-try
end

( Colon definitions put return addresses on the return stack. This can cause throw to jump past an end-try where the function will return to itself. This tests that the return stack is restored: )

: test-try-colon-inner
  " inner" write-line
  10 throw
;

: test-try-colon-outer
  ' test-try-rethrow try/1
  " outer" write-line
  test-try-colon-inner
  end-try
  " not ok" write-line
;

: test-try-colon
  ' .s try/1
  test-try-colon-outer
  end-try
  " done" write-line
;
