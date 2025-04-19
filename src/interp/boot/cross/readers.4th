: out-dallot-next-token>
  out-off' cstring
  dallot-next-token swap to-out-addr swap
  out-off' uint32 swap
  dhere to-out-addr out-dict dict-entry-data poke
;

: out-''
  ( The immediate ~out'~ that delays the lookup of the next token until the containing definition is called. The output word's address will be on the stack. )
  out-dallot-next-token>
  out-off' cross-lookup-or-break
; cross-immediate-as out'

: out-'
  ( Quote for output definitions. Uses the output dictionary. )
  out-off' pointer
  POSTPONE [out-off']
; cross-immediate-as '

: out-POSTPONE
  etab s" POSTPONE " error-string/2
  next-token 2dup error-line/2
  output-immediates @ out-origin @ dict-lookup/4 IF
    to-out-addr rot 2 dropn
  ELSE drop cross-lookup-offset-or-break
  THEN
; cross-immediate-as POSTPONE


( String readers: )

: out-dq-string
  ( Read until a double quote, writing the contained data to the data stack and leaving a literal and length on the stack for a definition. )
  POSTPONE d"
  out-off' cstring
  swap to-out-addr
  dhere to-out-addr out-dict dict-entry-data poke
; cross-immediate-as " cross-immediate-as top"

: out-dq-stringn
  ( Read until a double quote, writing the contained data to the data stack and leaving a literal and length on the stack for a definition. )
  POSTPONE d"
  out-off' cstring
  swap dup to-out-addr swap string-length
  out-off' uint32 swap
  dhere to-out-addr out-dict dict-entry-data poke
; cross-immediate-as s" cross-immediate-as top-s"

DEFINED? unescape-string/2 IF  

  : out-escaped-dq-string
    ( Read until a double quote, writing the contained data to the data stack and leaving a literal and length on the stack for a definition. )
    POSTPONE etmp" dallot-byte-string/2 drop
    out-off' cstring
    swap to-out-addr
    dhere to-out-addr out-dict dict-entry-data poke
  ; cross-immediate-as "

  : out-escaped-dq-stringn
    ( Read until a double quote, writing the contained data to the data stack and leaving a literal and length on the stack for a definition. )
    POSTPONE etmp" dallot-byte-string/2 swap to-out-addr
    out-off' cstring rot
    out-off' uint32 swap
    dhere to-out-addr out-dict dict-entry-data poke
  ; cross-immediate-as s"

  : out-write-escaped-string
    out-escaped-dq-stringn literal write-string/2
  ; cross-immediate-as ."

  : out-char-code
    out-off' uint32
    char-code
  ; cross-immediate-as char-code
THEN
