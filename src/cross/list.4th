: out-dcons
  dhere swap to-out-addr ,uint32 swap to-out-addr ,uint32
;

: out-string-list-fn
  dhere swap .s ,byte-string
  out-dcons
;

: ,out-string-list ( src-cons )
  0 ' out-string-list-fn revmap-car/3 drop swap drop
;

def out-read-list
  POSTPONE s[ ,out-string-list return1
end

: out-s[
  out-off' pointer
  out-read-list to-out-addr
; out-immediate-as s[
