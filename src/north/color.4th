load-core
s[ src/lib/math.4th
   src/lib/structs.4th
   src/north/words.4th
   ../north/src/01/tty.4th
] load-list

def color-prompt
  prompt-here peek color-reset green write-hex-uint
  color-reset s" :" write-string/2
  prompt-here peek peek dup cyan write-int
  space color-reset bold s" >" write-string/2
  color-reset space
end

def color-init
  ' color-prompt ' prompt redefine!
end

tty-getsize 0 int> swap 0 int> and [IF] color-init [THEN] about
