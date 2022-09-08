( todo move the following definitions some place better )
def sinc! arg0 speek 1 + dup arg0 spoke set-arg0 end

4 const> INT32-SIZE

def seq<uint32>-peek
  arg1 arg0 INT32-SIZE * + uint32@ 2 return1-n
end

def seq<uint32>-poke
  arg2 arg1 arg0 INT32-SIZE * + uint32!
  3 return0-n
end

def dallot-seq<int32>
  dhere
  arg0 INT32-SIZE *
  2dup 0 fill-seq
  over + dmove
  arg0 1 return2-n
end

def out-does-data-var?
  out' do-data-var dup arg0 equals?
  IF false
  ELSE dict-entry-code uint32@ arg0 dict-entry-code uint32@ equals?
  THEN set-arg0
end

def data-var-init-values/2 ( word origin -- value slot )
  arg1 dict-entry-data uint32@ arg0 +
  dup 1 seq<uint32>-peek swap 0 seq<uint32>-peek 2 return2-n
end

( Variable writer state is stored on the stack. Bash doesn't need cell-size as all cells fit in a single slot and the stack grows up. )
def variable-writer-state-ds arg0 3 up-stack/2 set-arg0 end
def variable-writer-state-cs arg0 2 up-stack/2 set-arg0 end
def variable-writer-state-dict arg0 1 up-stack/2 set-arg0 end
def variable-writer-state-total ( nop ) end

def log-data-var-info ( origin word number -- )
  arg0 error-int espace
  arg1 dict-entry-name uint32@ arg2 + byte-string@ error-string/2 espace
  arg1 arg2 data-var-init-values/2 error-hex-uint espace error-hex-int enl
  3 return0-n
end

def write-data-variable ( state word -- )
  arg0 arg1 variable-writer-state-cs speek data-var-init-values/2
  arg1 variable-writer-state-ds speek swap seq<uint32>-poke
  2 return0-n
end

def maybe-write-data-variable ( state word -- state )
  arg0 out-does-data-var? IF
    arg1 variable-writer-state-cs speek
    arg0
    arg1 variable-writer-state-total speek
    log-data-var-info
    arg1 variable-writer-state-total sinc! drop
    arg1 arg0 write-data-variable
  THEN arg1 2 return1-n
end

def write-data-variable-loop ( ds cs word counter -- count )
  arg1 arg2 args ' maybe-write-data-variable dict-map/4
  0 ,uint32
  arg0 4 return1-n
end

def write-variable-data ( dict-offset dict -- data-pointer )
  next-def-data-var-slot 1 + dallot-seq<int32>
  s" Copying variable data: " error-string/2 local0 error-hex-uint enl
  local0 arg1 arg0 0 write-data-variable-loop
  dup error-int s"  variables" error-line/2
  local0 uint32!
  local0 2 return1-n
end
