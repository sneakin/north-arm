( Dictionary entry structure: )

0 defvar> *dict*

defcol dict *dict* peek swap endcol
defcol set-dict ( dict ) swap *dict* poke endcol

cell-size 4 mult defconst> dict-entry-size

defcol dict-entry-name
  exit
endcol

defcol dict-entry-code
  swap cell-size + swap
endcol

defcol dict-entry-data
  swap cell-size + cell-size + swap
endcol

defcol dict-entry-data-pointer
  swap dict-entry-data peek cs + swap
endcol

defcol dict-entry-link
  swap cell-size int32 3 * + swap
endcol

( Copying: )

defcol dict-entry-clone-fields
  rot swap
  over dict-entry-code peek over dict-entry-code poke
  over dict-entry-data peek over dict-entry-data poke
  2 dropn
endcol

( Execution: )

defcol jump-data
  drop
  dict-entry-data peek jump-cs
end
