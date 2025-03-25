DEFINED? uint64 IF
  def next-uint64
    next-token dup 0 int<= IF 0 0 ELSE string->uint64/2 THEN return2
  end

  def next-int64
    next-token dup 0 int<= IF 0 0 ELSE string->int64/2 THEN return2
  end

  : [uint64]
    literal uint64 next-uint64
  ; immediate-as uint64

  : [int64]
    literal int64 next-int64
  ; immediate-as int64
THEN
