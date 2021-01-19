(
struct> sigaction
field> pointer sa_handler
field> uint32 sa_mask
field> int32  sa_flags
field> pointer sa_restorer
)

defcol make-sigaction
  0 0 rot
  0 0 rot
  here cell-size int-add swap
endcol

defcol sa-handler endcol
defcol sa-mask swap cell-size int-add swap endcol
defcol sa-flags swap cell-size 2 int-mul int-add swap endcol
defcol sa-restorer swap cell-size 3 int-mul int-add swap endcol
