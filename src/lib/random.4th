def rand-int ( max -- n )
  crand arg0 int-mod set-arg0
end

def rand-seq/3 ( range-max seq size -- seq )
  ' rand-int arg2 partial-first arg1 arg0 generate-seq/3 3 return1-n
end

def rand-seq/2
  arg0 cell-size * stack-allot arg1 swap arg0 rand-seq/3 exit-frame
end
