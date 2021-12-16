def make-struct-seq ( struct count ++ ptr )
  arg1 byte-size arg0 * stack-allot-zero exit-frame
end

def struct-seq-nth ( seq n struct -- ptr )
  arg0 byte-size arg1 * arg2 + 3 return1-n
end
