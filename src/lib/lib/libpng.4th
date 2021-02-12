load-core

library> libpng.so
import> png-image-begin-read-from-file 1 png_image_begin_read_from_file 2
import> png-image-begin-read-from-memory 1 png_image_begin_read_from_memory 3
import> png-image-finish-read 1 png_image_finish_read 5
import> png-image-free 0 png_image_free 1
import> png-create-info-struct 1 png_create_info_struct 1
import> png-create-read-struct 1 png_create_read_struct 4
import> png-destroy-read-struct 1 png_destroy_read_struct 1

defcol png-image-opaque endcol
defcol png-image-version swap cell-size + swap endcol
defcol png-image-width swap cell-size 2 * + swap endcol
defcol png-image-height swap cell-size 3 * + swap endcol
defcol png-image-format swap cell-size 4 * + swap endcol
defcol png-image-flags swap cell-size 5 * + swap endcol
defcol png-image-cmap-size swap cell-size 6 * + swap endcol
defcol png-image-is-error swap cell-size 7 * + swap endcol
defcol png-image-message swap cell-size 8 * + swap endcol

def write-png-image-error
  s" Error: " write-string/2
  arg0 png-image-is-error peek write-hex-uint space
  arg0 png-image-message write-line
end

0 var> *debug*
: debug? *debug* peek ;

1 const> PNG-FORMAT-FLAG-ALPHA
2 const> PNG-FORMAT-FLAG-COLOR
0x10 const> PNG-FORMAT-FLAG-BGR
0x20 const> PNG-FORMAT-FLAG-AFIRST
0x3 const> PNG-FORMAT-FLAG-RBGA

def png-finish-load ( png-image ++ pixels ok? | 0 )
  0
  arg0 png-image-width peek
  arg0 png-image-height peek *
  cell-size * stack-allot-zero set-local0
  0 0 local0 0 arg0 png-image-finish-read
  debug? IF .s THEN
  IF
    arg0 png-image-free
    local0 1 exit-frame
  ELSE
    debug? IF arg0 write-png-image-error THEN
    arg1 png-image-free
    0 return1
  THEN
end

def png-load-file ( path ++ header pixels )
  0 0
  24 cell-size * stack-allot-zero set-local0
  1 local0 png-image-version poke
  PNG-FORMAT-FLAG-RBGA local0 png-image-format poke
  arg0 local0
  debug? IF here 256 ememdump THEN
  png-image-begin-read-from-file
  debug? IF here 256 ememdump THEN
  IF
    local0 png-finish-load
    debug? IF .s THEN
    IF local0 swap exit-frame THEN
  THEN
  local0 png-image-free
  local0 move local0 0 exit-frame
end

def png-load-mem ( data num-bytes ++ header pixels )
  0 0
  24 cell-size * stack-allot-zero set-local0
  1 local0 png-image-version poke
  PNG-FORMAT-FLAG-RBGA local0 png-image-format poke
  arg0 arg1 local0
  debug? IF here 256 ememdump THEN
  png-image-begin-read-from-memory
  debug? IF here 256 ememdump THEN
  IF
    local0 png-finish-load
    debug? IF .s THEN
    IF local0 swap exit-frame THEN
  THEN
  local0 png-image-free
  local0 move local0 0 exit-frame
end

def test-libpng-read
  0 0
  *debug* peek
  1 *debug* poke
  " misc/star.png" png-load-file .s dup IF
    set-local1 set-local0
    s" Loaded" write-line/2
    local1 128 memdump
  THEN
  local2 *debug* poke
end

def byte-swap-uint32
  arg0 0xFF logand 24 bsl
  arg0 0xFF00 logand 8 bsl logior
  arg0 0xFF0000 logand 8 bsr logior
  arg0 0xFF000000 logand 24 bsr logior
  set-arg0
end

def UINT32@
  arg0 uint32@ byte-swap-uint32 set-arg0
end
