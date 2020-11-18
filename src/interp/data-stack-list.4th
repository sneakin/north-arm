defcol dcons dhere rot dpush rot dpush swap endcol

( Or reading and copying tokens to the data stack: )

: string-list-fn
  dhere swap ,byte-string
  dcons
;

: ,string-list ( src-cons )
  0 ' string-list-fn revmap-cons/3
;

def read-literal-list
  POSTPONE s[ ,string-list return1
end

: 's[
  literal pointer
  read-literal-list
; immediate-as s[
