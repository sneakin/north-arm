( getopt - Single character command line flag processing. )

0 const> GETOPT-NONE
1 const> GETOPT-KEY
2 const> GETOPT-FLAG
3 const> GETOPT-UNKNOWN

DEFINED? defconst> IF
0 defconst> GETOPT-NONE
1 defconst> GETOPT-KEY
2 defconst> GETOPT-FLAG
3 defconst> GETOPT-UNKNOWN
THEN

def getopt-flag?
  arg0 peek-byte 0x2D ( - ) equals? set-arg0
end

def getopt-opt-has-value?
  arg0 1 + peek-byte 0x3A ( - ) equals? set-arg0
end

def getopt-match-loop ( arg option-string -- kind )
  arg0 peek-byte 0 equals? UNLESS
    arg1 peek-byte arg0 peek-byte equals? IF
      arg0 getopt-opt-has-value?
      IF GETOPT-KEY ELSE GETOPT-FLAG THEN 2 return1-n
    ELSE
      arg0 getopt-opt-has-value? IF 2 ELSE 1 THEN
      arg0 + set-arg0 repeat-frame
    THEN
  THEN
  GETOPT-NONE 2 return1-n
end

def getopt-match ( arg option-string -- kind )
  arg1 getopt-flag? IF
    arg1 1 + arg0 getopt-match-loop
    dup GETOPT-NONE equals? IF drop GETOPT-UNKNOWN THEN
  ELSE GETOPT-NONE
  THEN 2 return1-n
end

( Processes a sequence of strings obtained from ~argv-fn~ into hyphenated flags by calling ~processor-fn~ when the flag is contained in ~option-string~. Returns true if the processor never returned false and all arguments were seen.

~processor-fn~ Function that takes a value, name, and index as arguments. Returns false if option parsing should stop. Value may be null for flags. Name may be "*" for standalone values or "." for unknown flags. A "--" flag is treated specially when processing it returns false causing option processing to stop in an OK state.
~option-string~ A string of character flags possibly followed by a colon to indicate a value is required.
~argv-fn~ A fenction that takes an integer algument to retrieve arguments.
~argc~ Size of the argument sequence.
~n~ Loop counter < ~argc~. )
def getopt/5 ( processor-fn option-string argv-fn argc n ++ ok? )
  arg0 arg1 int< UNLESS true exit-frame THEN
  arg0 arg2 exec-abs arg3 getopt-match CASE
    GETOPT-KEY WHEN
      arg0 dup 1 + arg2 exec-abs arg0 arg2 exec-abs 1 + 4 argn exec-abs
      IF arg0 2 + set-arg0 repeat-frame THEN
    ;;
    GETOPT-FLAG WHEN
      arg0 0 arg0 arg2 exec-abs 1 + 4 argn exec-abs
      IF arg0 1 + set-arg0 repeat-frame THEN
    ;;
    GETOPT-UNKNOWN WHEN
      arg0 dup arg2 exec-abs " ." 4 argn exec-abs
      IF arg0 1 + set-arg0 repeat-frame THEN
    ;;
    drop
    arg0 dup arg2 exec-abs " *" 4 argn exec-abs
    arg0 1 + set-arg0 repeat-frame
  ESAC
  arg0 arg2 exec-abs s" --" string-equals?/3
  IF true ELSE false THEN exit-frame
end

( Entry to getopt/5 that uses ~get-argv~ and ~argc~. )
def getopt ( processor-fn option-string ++ ok? )
  arg1 arg0 ' get-argv argc 1 getopt/5 exit-frame
end
