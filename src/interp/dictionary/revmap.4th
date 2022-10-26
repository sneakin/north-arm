def dict-revmap-iter ( state entry -- entry state+1 )
  arg1 1 + arg0 set-arg1 set-arg0
end

def dict-revmap ( fn dict -- )
  arg0 cs -1 ' dict-revmap-iter dict-map/4
  here cell-size 2 * + swap
  0 arg1 map-seq-n/4 exit-frame
end
