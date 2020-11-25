( todo start with software division and detect vfp from the HWCAPS. )

defcol arm-hard-divmod
  ( swap for thumb v2 ops: int-div, int-divmod )
  ' int-div-v2 ' int-div dict-entry-clone-fields
  ' int-divmod-v2 ' int-divmod dict-entry-clone-fields
  ' uint-div-v2 ' uint-div dict-entry-clone-fields
  ' uint-divmod-v2 ' uint-divmod dict-entry-clone-fields
endcol

defcol arm-soft-divmod
  ( swap for software ops )
  ' int-div-sw ' int-div dict-entry-clone-fields
  ' int-divmod-sw ' int-divmod dict-entry-clone-fields
  ' uint-div-sw ' uint-div dict-entry-clone-fields
  ' uint-divmod-sw ' uint-divmod dict-entry-clone-fields
endcol
