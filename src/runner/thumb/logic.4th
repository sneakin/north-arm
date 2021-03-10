( Logic: )

0 defconst> false
-1 defconst> true

defcol not
  swap IF false ELSE true THEN
  swap
endcol

defcol and
  rot IF
    IF true swap exit THEN
  ELSE drop THEN
  false swap
endcol

defcol or
  rot IF drop true swap exit THEN
  IF true swap exit THEN
  false swap
endcol
