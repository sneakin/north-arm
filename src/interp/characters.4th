( Character classification: )

defcol is-space?
  swap int32 0x20 equals? swap
endcol

defcol is-tab?
  swap int32 0x09 equals? swap
endcol

defcol newline?
  swap int32 0x0A equals? swap
endcol

defcol page-feed?
  swap int32 0x0C equals? swap
endcol

defcol line-return?
  swap int32 0x0D equals? swap
endcol

defcol whitespace?
  ( fixme reader breaks at multiples of its buffer? )
  over newline? IF int32 1
  ELSE
    over is-space? IF int32 1
    ELSE
      over is-tab? IF int32 1
      ELSE
        over line-return? IF int32 1
        ELSE
          over page-feed? IF int32 1
          ELSE int32 0
          THEN
        THEN
      THEN
    THEN
  THEN
  rot drop
endcol

defcol not-whitespace?
  swap whitespace? not swap
endcol

def is-digit?
  arg0 int32 57 int32 48 in-range? return1
end

def is-lower-alpha?
  arg0 int32 122 int32 97 in-range? return1
end

def is-upper-alpha?
  arg0 int32 90 int32 65 in-range? return1
end

def minus-sign?
  arg0 int32 45 equals? set-arg0
end

def plus-sign?
  arg0 int32 43 equals? set-arg0
end

def decimal-point?
  arg0 int32 46 equals? set-arg0
end
