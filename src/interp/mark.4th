( Dictionary bookmarking: )

DEFINED? dict-entry-equiv? UNLESS s" src/interp/dictionary/equiv.4th" load/2 THEN

( todo dict switch with mark updating )
( todo output marks )

(
struct: mark
pointer field: dict
pointer field: immediates
)

def mark-dict ( mark -- dict ) ( arg0 0 + set-arg0 ) end
def mark-immediates ( mark -- immeds ) arg0 cell-size + set-arg0 end

def make-mark ( ++ mark )
  immediates @ cs + dict here exit-frame
end

def mark> ( : name ++ word )
  make-mark const> exit-frame
end

def copy-mark ( src dest -- )
  arg1 mark-immediates @ arg0 mark-immediates !
  arg1 mark-dict @ arg0 mark-dict !
  2 return0-n
end

def remark! ( mark -- )
  immediates @ cs + arg0 mark-immediates !
  dict arg0 mark-dict !
  1 return0-n
end

def use-mark ( [ dict immediates ] -- )
  ( Change the primary dictionaries to those supplied in the pair. The old values are returned in a new pair. )
  arg0 mark-dict @ dup code-offset? IF cs + THEN set-dict
  arg0 mark-immediates @ dup code-offset? UNLESS cs - THEN immediates !
  1 return0-n
end

def dict-swap ( [ dict immediates ] ++ [ old-dict old-immeds ] )
  ( Change the primary dictionaries to those supplied in the pair. The old values are returned in a new pair. )
  make-mark arg0 use-mark exit-frame
end

def dict-entry-before ( word dict offset -- parent-word found? )
  arg2 arg1 equals? UNLESS
    arg1 0 equals? UNLESS
      arg1 dict-entry-link @
      dup arg0 + arg2 equals? IF arg1 true 3 return2-n THEN
      dup 0 equals? UNLESS arg0 + set-arg1 repeat-frame THEN
    THEN
  THEN 0 false 3 return2-n
end

def dict-terminate! ( word -- )
  ( Set a word's link to null. )
  null arg0 dict-entry-link !
  1 return0-n
end

def dict-cut-before/3 ( word dict offset -- dict )
  ( Terminate a dictionary list at the word that links to ~word~. )
  arg2 arg1 arg0 dict-entry-before IF dict-terminate! THEN
  arg1 3 return1-n
end

def dict-cut-before ( word -- dict )
  ( dict cs ' dict-cut-before/3 tail+2 )
  arg0 dict cs dict-cut-before/3 set-arg0
end

( todo for a clean return, is anything allocated? )
def does-forget ( mark word ++ word )
  ( Makes a word perform a dict swap where it becomes the dictionary and the immediates become the active list. )
  arg0 ' do-col does

  literal return0
  literal dict-swap
  arg1 literal literal
  literal begin-frame
  
  here cs - arg0 dict-entry-data poke
  ( todo no length? )
  arg0 exit-frame
end

def create-forget ( mark name len ++ word )
  ( Create a new word that restores the dictionaries to when the mark was made. )
  arg1 arg0 create
  arg2 swap does-forget exit-frame
end

def mark! ( ++ word )
  ( Create a new ~forget!~ that restores the dictionaries to when the mark was made. )
  make-mark s" forget!" create-forget exit-frame
end

def top-forget!
  s" forget!" dict dict-lookup IF
    dup ' top-forget! dict-entry-equiv? IF
      s" Warning: nothing to forget" error-line/2
    ELSE exec-abs
    THEN
  THEN
end

alias> forget! top-forget!

SYS:DEFINED? NORTH-COMPILE-TIME IF
  sys:: use-out-mark
    dup mark-dict @ from-out-addr out-dictionary !
    mark-immediates @ from-out-addr output-immediates !
  ;

  sys-def out-remark! ( mark -- )
    out-dictionary @ to-out-addr arg0 mark-dict !
    output-immediates @ to-out-addr arg0 mark-immediates !
    1 return0-n
  end

  sys:: make-out-mark
    output-immediates @ to-out-addr
    out-dictionary @ to-out-addr
    here
  ;

  sys:: output-mark ( mark -- data-pointer )
    dhere
    swap dup mark-dict @ ,uint32
    mark-immediates @ ,uint32
  ;

  sys-def out-dict-swap
    make-out-mark ( fixme does not need to be in image )
    arg0 use-out-mark
    exit-frame
  end
  
  sys-def does-out-forget ( mark word ++ word )
  ( Makes a word perform a dict swap where it becomes the dictionary and the immediates become the active list. )
    arg0 pointer do-col does

    literal return0
    literal out-dict-swap
    arg1 literal literal
    literal begin-frame
      
    here cs - arg0 dict-entry-data poke
    ( todo no length? )
    arg0 exit-frame
  end

  sys-def create-out-forget
    arg1 arg0 sys-create arg2 swap does-out-forget exit-frame
  end

  sys:: mark!
    make-out-mark s" forget!" create-out-forget
  ;

  sys:: mark> ( : name ++ word )
    make-out-mark output-mark to-out-addr const-offset>
    out-dictionary @ dict-entry-name @ from-out-addr
    dup string-length
    INTERP-LOG-DEBUG interp-logs? IF
      s" MARK> " error-string/2
      2dup error-line/2
    THEN
    sys-create
    out-dictionary @ dict-entry-data @ from-out-addr over dict-entry-data !
    does-const
  ;
THEN

def does-remark ( new-mark old-mark word ++ word )
  ( Makes a word perform a dict swap after updating the prior used mark. )
  arg0 ' do-col does

  literal return0
  literal copy-mark
  arg1 literal literal
  literal dict-swap
  ( literal enl literal error-hex-uint literal dup )
  arg2 literal literal
  literal begin-frame
  
  ( todo no length? )
  here cs - arg0 dict-entry-data poke
  arg0 exit-frame
end

( todo switch forget! and pop-mark so it looks up a runtime created constant instead of an executable word? )
( todo an export-to-mark that adds a work to a mark's dictionary? )

def create-remark ( new-mark old-mark name len ++ word )
  ( Create a new word that restores the dictionaries to when the mark was made. )
  arg1 arg0 create
  arg2 remark!
  arg3 arg2 roll does-remark exit-frame
end

def push-mark ( mark ++ word )
  arg0 dict-swap arg0 s" pop-mark" create-remark exit-frame
end

def push-mark>
  arg0 dict-swap const> exit-frame
end

def top-pop-mark
  s" pop-mark" dict dict-lookup IF
    dup ' top-pop-mark dict-entry-equiv? IF
      s" Warning: no more marks to pop" error-line/2
    ELSE exec-abs
    THEN
  THEN
end

alias> pop-mark top-pop-mark

( Global marks to the current dictionaries: )
mark> *mark* ( restore by swapping to ~*mark*~ )
mark! ( or restore with a ~forget!~ )

SYS:DEFINED? NORTH-COMPILE-TIME IF
  sys-def does-out-remark ( new-mark old-mark word ++ word )
    ( Makes a word perform a dict swap after updating the prior used mark. )
    arg0 pointer do-col does

    literal return0
    literal copy-mark
    arg1 literal literal
    literal out-dict-swap
    ( literal enl literal error-hex-uint literal dup )
    arg2 literal literal
    literal begin-frame
      
      ( todo no length? )
      here cs - arg0 dict-entry-data poke
      arg0 exit-frame
  end

  sys-def create-out-remark ( new-mark old-mark name len ++ word )
    ( Create a new word that restores the dictionaries to when the mark was made. )
    arg1 arg0 sys-create
    arg2 out-remark!
    arg3 arg2 roll does-out-remark exit-frame
  end

  sys-def push-mark ( mark ++ word )
    arg0 out-dict-swap arg0 s" pop-mark" create-out-remark exit-frame
  end

  sys:: push-mark> ( out-mark : name ++ )
    out-dict-swap output-mark to-out-addr const-offset>
    out-dictionary @ dict-entry-name @ from-out-addr
    dup string-length
    INTERP-LOG-DEBUG interp-logs? IF
      s" PUSH MARK " error-string/2
      2dup error-line/2
    THEN
    sys-create
    out-dictionary @ dict-entry-data @ from-out-addr
    INTERP-LOG-DEBUG interp-logs? IF ,h enl THEN
    over dict-entry-data !
    does-const
  ;
THEN
