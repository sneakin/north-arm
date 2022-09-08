: out-string-list-fn
  dhere swap ,byte-string
  out-dcons
;

: ,out-string-list ( src-cons )
  0 ' out-string-list-fn revmap-cons/3 drop swap drop
;

def out-read-list
  POSTPONE s[ ,out-string-list return1
end

: out-s[
  out-off' pointer
  out-read-list to-out-addr
; out-immediate-as s[
