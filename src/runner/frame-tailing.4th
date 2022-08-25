( Words to use to reuse a frame in a tail call: )

( First some helpers: )

defcol current-frame-add-arg ( arg0 ... tos new-arg -- arg0 new-arg ... tos )
  swap dup
  here dup cell-size + swap args over - copy
  args cell-size - !
  current-frame cell-size - set-current-frame
endcol

def tail-start-offset ( colon-seq -- colon-seq-start framed? )
  arg0 @ literal begin-frame equals?
  IF arg0 op-size + true
  ELSE arg0 false
  THEN 1 return2-n
end

def tail-word-start-offset ( word -- start-ptr framed? )
  arg0 dict-entry-data @ cs + tail-start-offset 1 return2-n
end

( Now the tail calls: )

( Executes word without changing the calling frame. )
defcol tail-0 ( ...args frame-ra fp word -- ...args frame-ra -> word )
  drop
  tail-word-start-offset UNLESS
    current-frame return-address @ ( todo be much smarter w/ non-frames )
    swap end-frame
  THEN jump
endcol

( Executes word after adding an argument to the calling frame. )
defcol tail+1 ( ...args frame-ra fp new-arg0 word ra -- ...args new-arg0 frame-ra fp -> word )
  drop
  swap current-frame-add-arg
  tail-0
endcol

( todo do not drop the locals from the stack )

( Executes word after dropping the locals and an argument from the calling frame. )
defcol droptail-1 ( ...args1 arg0 frame-ra fp ... word -- ...args1 frame-ra -> word )
  drop
  current-frame return-address @ set-arg0
  dict-entry-data @ cs + ( tail-word-start-offset drop ) current-frame return-address !
  return
endcol

( Executes word after dropping the locals and two arguments from the calling frame. )
defcol droptail-2 ( ...arg2 arg1 arg0 frame-ra fp ... word -- ...arg2 frame-ra fp -> word )
  drop
  current-frame return-address @ set-arg1
  dict-entry-data @ cs + current-frame return-address !
  1 return0-n
endcol

( Executes word after dropping the locals and N argument- from the calling frame. )
defcol droptail-n ( ...argn ... arg0 frame-ra fp ... word n -- ...argn frame-ra fp -> word )
  drop
  1 -
  current-frame return-address @ over set-argn
  swap dict-entry-data @ cs + current-frame return-address !
  return0-n
endcol
