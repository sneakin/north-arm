( Variables: )

: defvar
  create
  out' do-var dict-entry-code uint32@
  over dict-entry-code uint32!
  dict-entry-data uint32!
;

: defvar>
  next-token defvar
;
