defop test-op endop

defcol test-out'
  out' test-op
  out-off' test-op
  ' test-op
endcol

: test-out'
  out' test-op ,h nl
  out-off' test-op ,h nl
  out' test-out' 64 ddump/2
;

out' test-op ,h nl
out-off' test-op ,h nl
' test-out' get-word .
test-out'
