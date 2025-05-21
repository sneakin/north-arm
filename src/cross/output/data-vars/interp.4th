( todo merge with bash.4th. shares a lot of code with a few interop aliases. )

NORTH-BUILD-TIME 0x6315D6AA int< IF
def inc!
  arg0 peek 1 + dup arg0 poke set-arg0
end
THEN

def out-does-data-var?
  out' do-data-var dup arg0 equals?
  IF false
  ELSE dict-entry-code @ arg0 dict-entry-code @ equals?
  THEN set-arg0
end

def data-var-init-values/2 ( word origin -- value slot )
  arg1 dict-entry-data peek arg0 +
  dup 1 seq-peek swap 0 seq-peek 2 return2-n
end

def variable-writer-state-ds arg0 cell-size 3 * + set-arg0 end
def variable-writer-state-cs arg0 cell-size 2 * + set-arg0 end
def variable-writer-state-dict arg0 cell-size 1 * + set-arg0 end
def variable-writer-state-total arg0 cell-size 0 * + set-arg0 end

def log-data-var-info ( origin word number -- )
  INTERP-LOG-DETAILS interp-logs? IF
    arg0 error-int espace arg1 dict-entry-name @ arg2 + error-string espace
  THEN
  arg1 arg2 data-var-init-values/2
  INTERP-LOG-DETAILS interp-logs? IF
    error-hex-uint espace error-hex-int enl
  THEN
  3 return0-n
end

def write-data-variable ( state word -- )
  arg0 arg1 variable-writer-state-cs @ data-var-init-values/2
  arg1 variable-writer-state-ds @ swap seq-poke
  2 return0-n
end

( fixme crash when do-var aliased as do-data-var )

def maybe-write-data-variable ( state word -- state )
  arg0 out-does-data-var? IF
    arg1 variable-writer-state-cs @
    arg0 arg1 variable-writer-state-total @
    log-data-var-info
    arg1 variable-writer-state-total inc! drop
    arg1 arg0 write-data-variable
  THEN arg1 2 return1-n
end

def write-data-variable-loop ( ds cs word counter -- count )
  arg1 arg2 args ' maybe-write-data-variable dict-map/4
  arg0 cell-size * dhere + dmove 0 ,uint32
  arg0 4 return1-n
end

def write-variable-data
  dhere
  0 ,uint32
  INTERP-LOG-DETAILS interp-logs? IF s" Copying variable data:" error-line/2 THEN
  local0 arg1 arg0 0 write-data-variable-loop
  INTERP-LOG-DETAILS interp-logs? IF
    dup error-int s"  variables" error-line/2
  THEN
  local0 !
  local0 2 return1-n
end
