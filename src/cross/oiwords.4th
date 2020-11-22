: immediate
  s" Could immediate: " error-string/2
  out-dict dict-entry-name peek from-out-addr error-string enl
;
: immediate-as
  s" Could immediate-as: " error-string/2
  out-dict dict-entry-name peek from-out-addr error-string espace
  next-token error-string/2 enl
;

: out-immediate
  s" Could out-immediate: " error-string/2
  out-dict dict-entry-name peek from-out-addr error-string enl
;
: out-immediate-as
  s" Could out-immediate-as: " error-string/2
  out-dict dict-entry-name peek from-out-addr error-string espace
  next-token error-string/2 enl
;
