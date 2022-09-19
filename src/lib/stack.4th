struct: Stack
pointer<any> field: base
uint value field: size
pointer<any> field: here

def stack-reset
  arg0 Stack -> base @ arg0 Stack -> size @ +
  cell-size - arg0 Stack -> here !
end

def init-stack ( ptr stack-size stack -- stack )
  arg1 arg0 Stack -> size !
  arg2 arg0 Stack -> base !
  arg0 stack-reset
  arg0 3 return1-n
end

def destroy-stack
  0 arg0 Stack -> base !
  0 arg0 Stack -> size !
  0 arg0 Stack -> here !
  1 return0-n
end

def stack-stack-allot ( num-bytes stack -- ptr )
  arg0 Stack -> here @
  arg1 cell-size pad-addr -
  dup arg0 Stack -> base @ uint<
  IF drop 0
  ELSE dup arg0 Stack -> here !
  THEN 2 return1-n
end

def stack-push
  arg0 Stack -> here cell-size dec!/2
  arg1 swap !
  2 return0-n
end

def stack-pop
  arg0 Stack -> here @ @
  arg0 Stack -> here cell-size inc!/2 drop
  1 return1-n
end

def stack-mem-info ( stack -- free used )
  arg0 Stack -> here @ arg0 Stack -> base @ -
  arg0 Stack -> size @ over -
  1 return2-n
end
