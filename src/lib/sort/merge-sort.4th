( Merge sort: sorts by subdividing the set all the way to pairs and then merging the sorted subdivisions. )

( todo merge-sort sequences )

def sort-pair ( a b cmp-fn -- b a )
  arg2 arg1 arg0 exec-abs 0 int> IF arg2 arg1 set-arg2 set-arg1 THEN 1 return0-n
end

def merge-lists ( b a cmp-fn acc length reversed? ++ merger )
  ( Works through two sorted lists building up a new list built by taking the lesser head from A or B. )
  debug? IF
    s" Merging:" write-line/2
    arg1 write-int-sp arg0 write-int-sp nl
    5 argn ' write-int-sp map-car nl
    4 argn ' write-int-sp map-car nl
    arg2 ' write-int-sp map-car nl
  THEN
  arg1 0 uint> IF
    arg1 1 - set-arg1
    5 argn IF
      4 argn IF
	5 argn car 4 argn car arg3 exec-abs
	arg0 UNLESS not THEN IF
	  arg2 5 argn car cons set-arg2
	  5 argn cdr 5 set-argn
	ELSE
	  arg2 4 argn car cons set-arg2
	  4 argn cdr 4 set-argn
	THEN
      ELSE
	arg2 5 argn car cons set-arg2
	5 argn cdr 5 set-argn
      THEN repeat-frame
    ELSE
      4 argn IF
	arg2 4 argn car cons set-arg2
	4 argn cdr 4 set-argn
	repeat-frame
      THEN
    THEN
  THEN arg2 exit-frame
end

def merge-sort ( cmp-fn list length depth ++ sorted-list )
  ( subdivide list all the way down to pairs, sorting each half, and merging the halves )
  0 0 0
  debug? IF
    s" Sorting:" write-line/2
    arg1 write-int nl
    arg2 ' write-int-sp map-car nl
  THEN
  arg1 2 uint> IF
    arg1 2 int-div set-local1
    arg3 arg2 local1 arg0 1 + merge-sort set-local0
    arg3 local1 arg2 skip-first arg1 local1 int-sub arg0 1 + merge-sort set-local2
    debug? IF
      s" Sort merger:" write-line/2
      local0 ' write-int-sp map-car nl
      local2 ' write-int-sp map-car nl
    THEN
    local0 local2 arg3 0 arg1 arg0 int32-odd? merge-lists exit-frame
  ELSE
    arg1 1 uint> IF
      0
      arg2 car
      arg2 cdr car
      arg3 sort-pair
      arg0 int32-odd? IF swap THEN
      cons2 exit-frame
    ELSE
      arg1 0 uint> IF
	0 arg2 car cons exit-frame
      ELSE 0 3 return1-n
      THEN
    THEN
  THEN
end
