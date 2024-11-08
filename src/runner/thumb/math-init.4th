( todo start with software division and detect Thumb2 from HWCAPS or /proc/cpuinfo, or trapping illegal instructions, or using NORTH-PLATFORM. going to need a list of init functions. )

defcol patch-math-operators
  ' int-div ' / dict-entry-clone-fields
  ' int-mod ' mod dict-entry-clone-fields
  ' int-divmod ' divmod dict-entry-clone-fields
end

defcol arm-hard-divmod
  ( swap for thumb v2 ops: int-div, int-divmod )
  ' int-div-v2 ' int-div dict-entry-clone-fields
  ' int-divmod-v2 ' int-divmod dict-entry-clone-fields
  ' uint-div-v2 ' uint-div dict-entry-clone-fields
  ' uint-divmod-v2 ' uint-divmod dict-entry-clone-fields
  patch-math-operators
endcol

defcol arm-soft-divmod
  ( swap for software ops )
  ' int-div-sw ' int-div dict-entry-clone-fields
  ' int-divmod-sw ' int-divmod dict-entry-clone-fields
  ' uint-div-sw ' uint-div dict-entry-clone-fields
  ' uint-divmod-sw ' uint-divmod dict-entry-clone-fields
  patch-math-operators
endcol

def math-init/1 ( platform-str -- )
  ( s" thumb2" contains? )
  arg0 0 peek-off-byte 0x74 equals?
  arg0 5 peek-off-byte 0x32 equals? and
  0 IF
    ( s" aarch32" contains? )
    arg0 0 peek-off-byte 0x61 equals?
    arg0 5 peek-off-byte 0x33 equals? and
    arg0 6 peek-off-byte 0x32 equals? and
    or
  THEN
  IF
    arm-hard-divmod
  THEN
  1 return0-n
end

def math-init
  NORTH-PLATFORM math-init/1
end
