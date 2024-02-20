( Inplace variables: )

' do-inplace-var defined? IF
  def does-inplace-var
    arg0 pointer do-inplace-var does
  end
ELSE
  def does-inplace-var
    arg0 pointer do-var does
  end
THEN

def inplace-var>
  create> does-inplace-var
  args peek over dict-entry-data poke
  exit-frame
end

( Data segment variables: )

def data-var-init-slot end
def data-var-init-value arg0 cell-size + set-arg0 end

def data-var-init-values/2 ( word origin -- value slot )
  arg1 dict-entry-data peek arg0 +
  dup 1 seq-peek swap 0 seq-peek 2 return2-n
end

' tail+1 defined? IF
  def data-var-init-values ( word -- value slot )
    cs ' data-var-init-values/2 tail+1
  end
ELSE
  def data-var-init-values ( word -- value slot )
    arg0 cs data-var-init-values/2 1 return2-n
  end
THEN

' do-data-var defined? IF

def does-data-var?
  ' do-data-var dup arg0 equals?
  IF false
  ELSE dict-entry-code @ arg0 dict-entry-code @ equals?
  THEN set-arg0
end

def init-data-var ( word )
  ( sets the data segment slot to the initial value )
  arg0 data-var-init-values ds swap seq-poke
  1 return0-n
end

def maybe-init-data-var
  arg0 does-data-var? IF arg0 init-data-var THEN 1 return0-n
end

( todo needs a destination and dictionary args to be useful when building )
def reinit-data-vars!
  dict ' maybe-init-data-var dict-map
end

( A data-var with slot 0: the current size. )
create> *next-data-var-slot*
sys' NORTH-COMPILE-TIME defined? IF
  dup out' do-data-var does
  dhere to-out-addr swap dict-entry-data uint32!
  0 ,uint32 0 ,uint32
ELSE
  does> do-data-var
  0 0 here cs - dict dict-entry-data !
THEN

def next-data-var-slot
  *next-data-var-slot* inc! return1
end

def does-data-var ( init-value word ++ )
  arg0 pointer do-data-var does
  arg0
  next-data-var-slot set-arg0
  args cs - over dict-entry-data poke
  init-data-var return0
end

def data-var>
  create> arg0 over does-data-var
  exit-frame
end

alias> var> data-var>
ELSE
  alias> var> inplace-var>
THEN
