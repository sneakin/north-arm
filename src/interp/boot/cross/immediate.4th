0 var> cross-immediates

def cross-immediate/1 ( word )
  arg0 copy-dict-entry
  cross-immediates peek over dict-entry-link poke
  dup cs - cross-immediates poke
  exit-frame
end

def cross-immediate/3 ( src-word name name-length )
  0
  arg2 cross-immediate/1 set-local0
  arg1 arg0 allot-byte-string/2 drop cs -
  local0 dict-entry-name poke
  local0 exit-frame
end

: cross-immediate/2 ( src-word name )
  dup string-length cross-immediate/3
;

: cross-immediate dict cross-immediate/1 ;
: cross-immediate-as dict next-token cross-immediate/3 ;

alias> doc( ( cross-immediate ( bad emacs )
alias> args( ( cross-immediate ( bad emacs )
