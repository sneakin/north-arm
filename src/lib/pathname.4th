DEFINED? getcwd UNLESS
  def getcwd ( out-str out-length -- result )
    args 2 0xB7 syscall 2 return1-n
  end
THEN

" /" string-const> path-separator
1 const> path-separator-length
1024 const> max-pathname

SYS:DEFINED? NORTH-COMPILE-TIME IF
  1 defconst> path-separator-length
  1024 defconst> max-pathname
THEN

def string-rindex-compare/4 ( str length needle needle-length -- yes? )
  arg3 arg1 arg0 byte-string-equals?/3 4 return1-n
end

def string-rindex/4 ( ptr len needle needle-length -- index true || false )
  ' string-rindex-compare/4 arg1 arg0 2 partial-first-n
  arg3 arg2 roll string-rindex-of IF true 4 return2-n ELSE false 4 return1-n THEN
end

def xpathname-dirname ( pathname length -- pathname dirname-length )
  arg1 arg0 path-separator path-separator-length string-rindex/4
  IF return1-1 ELSE s" ." 2 return2-n THEN
end

def xpathname-basename ( pathname length -- basename length )
  arg1 arg0 path-separator path-separator-length string-rindex/4
  UNLESS return0 THEN
  arg1 over + 1 +
  swap arg0 swap - 1 - 2 return2-n
end

def is-path-separator? ( str length -- yes? )
  arg0 path-separator-length uint<
  IF false
  ELSE arg1 path-separator path-separator-length byte-string-equals?/3
  THEN 2 return1-n
end

SYS:DEFINED? NORTH-COMPILE-TIME IF
  defalias> pathname-absolute? is-path-separator?
ELSE
  alias> pathname-absolute? is-path-separator?
THEN

( Returns the parent directory of a path, or truncates the right most component. )
def pathname-dirname ( pathname length -- pathname dirname-length )
  arg1 arg0 ' is-path-separator? string-rindex-of
  IF return1-1 ELSE s" ." 2 return2-n THEN
end

( Returns the file name or right most component of a path. )
def pathname-basename ( pathname length -- basename length )
  arg1 arg0 ' is-path-separator? string-rindex-of
  UNLESS return0 THEN
  arg1 over + 1 +
  swap arg0 swap - 1 - 2 return2-n
end

( Join two path name fragments ensuring only a single separator is between thew. )
def pathname-join/6 ( out out-max left left-length right right-length -- out left+right+separator true || false )
  ( left/ + right )
  arg3 arg2 path-separator-length - + path-separator-length is-path-separator?
  IF
    ( left/ + /right )
    arg3 5 argn arg2
    arg1 path-separator-length is-path-separator? IF 1 - THEN
    copy-byte-string/3  ( todo bounds checking? )
  ELSE
    arg1 path-separator-length is-path-separator?
    IF ( left + /right )
      arg3 5 argn arg2 copy-byte-string/3 ( todo bounds checking? )
    ELSE ( left + / )
      4 argn arg2 arg0 + path-separator-length + uint<= IF false 6 return1-n THEN
      5 argn 4 argn arg3 arg2 path-separator path-separator-length string-append/6
    THEN
  THEN
  ( left/ + right, unless it was left/ + /right )
  5 argn 4 argn 4 overn 4 overn arg1 arg0 string-append/6
  ( s" join " error-string/2 2dup error-line/2 )
  true 5 return2-n
end

( To expand a path:
    It is scanned separator to separator.
    To start: paths with a leading non-separator need the CWD prepended.
              Could handle ~ and $HOME.
    Then from the highest component:
       Ignore '' and '.'
       Back track on '..'
       Append any others
)

( Scans a path name removing '.', empty components, and the component
  preceding '..'. )
def pathname-expand-dots ( out out-max-length path path-length last-separator out-n in-n -- out length true || false)
  ( end of input )
  arg0 arg3 uint> IF arg1 true 6 return2-n THEN
  ( end of output: error for overflow )
  arg1 5 argn uint> IF false 7 return1-n THEN
  ( find next separator )
  4 argn arg3 ' is-path-separator? arg0 string-index-of-str/4
  UNLESS ( the last part ) arg3 THEN
  ( empty parts and initial separators are skipped over )
  dup 0 equals? arg0 0 equals? and IF 0 ELSE dup arg0 - THEN
  CASE
    0 OF ( // )
      arg0 path-separator-length + set-arg0
      drop repeat-frame
    ENDOF
    1 OF ( handle . )
      4 argn arg0 + s" ." clean-byte-string-equals?/3 IF
	arg0 path-separator-length + 1 + set-arg0
	drop repeat-frame
      THEN
    ENDOF
    2 OF ( handle .. )
      4 argn arg0 + s" .." clean-byte-string-equals?/3 IF
	( use the variable tracking the last part )
	arg2 arg1 uint<
	IF arg2 true
	ELSE ( already back tracked the last part )
	  arg1 path-separator-length uint>
	  IF 6 argn arg1 path-separator-length - ' is-path-separator? string-rindex-of
	  ELSE false
	  THEN
	THEN
	IF ( back track )
	  dup path-separator-length uint< IF drop path-separator-length THEN set-arg1
	  arg0 path-separator-length + 2 + set-arg0
	  drop repeat-frame
	ELSE
	  ( at the beginning so copy the part )
	THEN
      THEN
    ENDOF
    ( else cleanup )
    drop
  ENDCASE
  ( all other parts )
  arg1 set-arg2 ( track the previous part )
  6 argn 5 argn over arg1 4 argn arg0 + 6 overn arg0 - pathname-join/6
  UNLESS false 7 return1-n THEN
  set-arg1 2 overn path-separator-length + set-arg0
  2 dropn repeat-frame
end

( Expand a path name so it has no relative components. )
def pathname-expand ( out out-max pathname pathname-length -- out final-length true || false )
  ( absolute paths that start with / )
  arg1 arg0 pathname-absolute?
  IF arg1 arg0
  ELSE
    ( relative paths: . .. abc )
    ( prepend the working dir )
    max-pathname stack-allot
    max-pathname over getcwd 1 -
    over max-pathname 4 overn 4 overn arg1 arg0 pathname-join/6
    UNLESS false 4 return1-n THEN
  THEN
  ( expand the full path )
  arg3 arg2 4 overn 4 overn 0 0 0 pathname-expand-dots
  IF 2dup null-terminate true 3 return2-n ELSE false 4 return1-n THEN
end
