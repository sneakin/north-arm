( todo start with software division and detect Thumb2 from HWCAPS or /proc/cpuinfo, or trapping illegal instructions. going to need aklist ofkinit functions. )

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
