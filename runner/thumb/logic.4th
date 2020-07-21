( Logic: )

defcol not
  swap IF int32 0 ELSE int32 1 THEN
  swap
endcol

defcol and
  rot IF IF int32 1 swap exit THEN THEN
  int32 0 swap
endcol

defcol or
  rot IF drop int32 1 swap exit THEN
  IF int32 1 swap exit THEN
  int32 0 swap
endcol
