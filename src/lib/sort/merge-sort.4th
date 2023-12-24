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

def merge-sort-list ( cmp-fn list length depth ++ sorted-list )
  ( subdivide list all the way down to pairs, sorting each half, and merging the halves )
  0 0 0
  debug? IF
    s" Sorting:" write-line/2
    arg1 write-int nl
    arg2 ' write-int-sp map-car nl
  THEN
  arg1 2 uint> IF
    arg1 2 int-div set-local1
    arg3 arg2 local1 arg0 1 + merge-sort-list set-local0
    arg3 local1 arg2 skip-first arg1 local1 int-sub arg0 1 + merge-sort-list set-local2
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
      ELSE 0 4 return1-n
      THEN
    THEN
  THEN
end

( Sequences: )

( todo swap seq and list order? )

def rev-list->seq/3 ( seq list length -- seq )
  arg0 0 int> IF
    arg0 1 - set-arg0
    arg1 car arg2 arg0 seq-poke
    arg1 cdr set-arg1 repeat-frame
  ELSE
    arg2 3 return1-n
  THEN
end

def rev-list->seq ( seq list -- seq )
  arg1 arg0 dup cons-count rev-list->seq/3 2 return1-n
end

def list->seq/3 ( seq list n -- seq )
  arg1 IF
    arg1 car arg2 arg0 seq-poke
    arg0 1 + set-arg0
    arg1 cdr set-arg1 repeat-frame
  ELSE
    arg2 3 return1-n
  THEN
end

def list->seq ( seq list -- seq )  arg1 arg0 0 list->seq/3 2 return1-n end

( todo Sort two element seqs into pairs that use merge-lists for list->seq input? Do away with merge-seqs. )
( todo inplace qsort )

def merge-sort-seq->list ( depth cmp-fn seq length ++ sorted-list )
  arg0 1 int< IF 0 4 return1-n THEN
  ( one item -> list )
  arg0 2 int< IF 0 arg1 peek cons exit-frame THEN
  ( two items -> sorted list )
  arg0 3 int< IF
    debug? IF s" Pair: " write-string/2
	      arg3 write-int-sp
	   THEN
    0
    arg1 1 seq-peek
    arg1 0 seq-peek
    2dup arg2 exec-abs IF swap THEN
    arg3 int32-odd? IF swap THEN
    debug? IF 2dup write-int-sp write-int enl THEN
    cons2 exit-frame
  THEN
  ( more -> subdivide into sorted lists that are merged )
  0 0
  arg3 1 + arg2 arg1 arg0 2 / merge-sort-seq->list set-local0
  arg3 1 +
  arg2
  arg0 2 /
  arg1 over cell-size * + swap
  arg0 swap -
  merge-sort-seq->list set-local1
  local0 local1 arg2 0 arg0 arg3 int32-odd? merge-lists exit-frame
end

def merge-sort-seq ( cmp-fn seq length -- seq )
  1 arg2 arg1 arg0 merge-sort-seq->list arg1 swap
  arg0 1 int< IF
    list->seq
  ELSE arg0 rev-list->seq/3
  THEN 3 return1-n
end
