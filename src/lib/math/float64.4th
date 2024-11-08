defcol 1d 1 int32->float64 swap rot endcol
defcol -1d -1 int32->float64 swap rot endcol
defcol 0d 0 int32->float64 swap rot endcol

( Comparisons: )

def float64> arg3 arg2 arg1 arg0 float64<=> 0 int< 4 return1-n end
def float64>= arg3 arg2 arg1 arg0 float64<=> 0 int<= 4 return1-n end
def float64< arg3 arg2 arg1 arg0 float64<=> 0 int> 4 return1-n end
def float64<= arg3 arg2 arg1 arg0 float64<=> 0 int>= 4 return1-n end
