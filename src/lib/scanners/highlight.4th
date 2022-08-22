1536 var> highlight-max-token-size

def highlight-state-buffer arg0 cell-size 4 * + set-arg0 end
def highlight-state-size arg0 cell-size 3 * + set-arg0 end
def highlight-state-reader arg0 cell-size 2 * + set-arg0 end
def highlight-state-length arg0 cell-size 1 * + set-arg0 end
def highlight-state-token-list arg0 cell-size 0 * + set-arg0 end

defcol make-highlight-state ( buffer size reader ++ state )
  0 swap
  0 swap
  here cell-size + swap
endcol

def write-escaped-html-byte
  arg0 CASE
    60 WHEN s" &lt;" write-string/2 ;;
    62 WHEN s" &gt;" write-string/2 ;;
    38 WHEN s" &amp;" write-string/2 ;;
    0 WHEN s" &null;" write-string/2 ;;
    27 WHEN s" &escape;" write-string/2 ;;
    10 WHEN nl ;;
    dup 32 int< IF
      s" &x" write-string/2
      arg0 write-hex-int
      s" ;" write-string/2
    ELSE arg0 write-byte
    THEN
  ESAC

  1 return0-n
end

def write-escaped-html/2 ( str n )
  arg0 0 int<= IF 2 return0-n THEN
  arg1 peek-byte write-escaped-html-byte
  arg1 1 + set-arg1
  arg0 1 - set-arg0
  repeat-frame
end

def comment-done
  arg0 41 equals? set-arg0
end

def terminated-text ( buffer size done-fn state -- )
  arg3 arg2 arg1 arg0 highlight-state-reader @ reader-read-until
  shift write-escaped-html/2
  0 equals? IF repeat-frame THEN
  arg3 arg2 arg0 highlight-state-reader @ reader-next-token drop write-string/2
  4 return0-n
end

def comment
  0
  s" <bold><x-color><param>red</param>" write-string/2
  arg2 arg1 write-string/2
  highlight-max-token-size @ stack-allot set-local0
  local0
  highlight-max-token-size @
  ' comment-done arg0 terminated-text
  s" </x-color></bold>" write-string/2
  nl
  3 return0-n
end

def string-done
  arg0 34 equals? set-arg0
end

def string
  0
  s" <bold><x-color><param>brightmagenta</param>" write-string/2
  arg2 arg1 write-escaped-html/2
  arg0 highlight-state-buffer @ arg0 highlight-state-size @
  ' string-done arg0 highlight-state-reader @ reader-read-until drop
  dup arg0 highlight-state-length !
  2dup null-terminate
  write-escaped-html/2
  16 stack-allot 16
  arg0 highlight-state-reader @
  reader-next-token drop write-string/2
  s" </x-color></bold>" write-string/2
  space
  3 return0-n
end  

def token-list-loop ( buffer size state cons -- cons )
  arg2 cell-size 3 * int< IF
    s" Warning: token list too large." error-line/2
    arg0 4 return1-n
  THEN
  arg3 arg2 arg1 highlight-state-reader @ reader-next-token
  0 int<= IF arg0 4 return1-n THEN
  2dup null-terminate
  over s" ]" string-equals?/3 IF arg0 4 return1-n ELSE 3 dropn THEN
  over s" (" string-equals?/3 IF 3 dropn arg1 comment nl repeat-frame ELSE 3 dropn THEN
  over s" )" string-equals?/3 IF 5 dropn repeat-frame ELSE 3 dropn THEN
  2dup write-line/2
  ( create a cons pointing to the string and last cons
    after the read string in the buffer )
  arg3 over + 1 +
  arg3 over !
  arg0 over cell-size + !
  dup set-arg0
  dup cell-size 3 * + set-arg3
  arg2 3 overn - cell-size 3 * - set-arg2
  3 dropn repeat-frame
end

def token-list
  s" <x-color><param>brightmagenta</param>" write-string/2
  arg2 arg1 write-string/2 space
  s" </x-color>" write-string/2
  arg0 highlight-state-buffer @
  arg0 highlight-state-size @
  arg0
  0 token-list-loop
  arg0 highlight-state-token-list !
  s" <x-color><param>brightmagenta</param>" write-string/2
  s" ] " write-string/2
  s" </x-color>" write-string/2
  3 return0-n
end

def keyword
  s" <x-color><param>cyan</param>" write-string/2
  arg2 arg1 write-escaped-html/2
  s" </x-color>" write-string/2
  space
  3 return0-n
end

def keyword-open
  ( s" <div class='definition'>" write-string/2 )
  nl
  arg2 arg1 arg0 keyword
  3 return0-n
end

def keyword-token
  ( s" <div class='definition'>" write-string/2 )
  s" <x-color><param>brightmagenta</param>" write-string/2
  arg2 arg1 write-escaped-html/2
  space s" <bold>" write-string/2
  highlight-max-token-size @ stack-allot highlight-max-token-size @
  arg0 highlight-state-reader @ reader-next-token
  drop write-escaped-html/2
  s" </bold></x-color>" write-string/2
  space
  3 return0-n
end

def keyword-token-next
  s" <bold><underline><x-color><param>brightcyan</param>" write-string/2
  highlight-max-token-size @ stack-allot highlight-max-token-size @
  arg0 highlight-state-reader @ reader-next-token
  drop write-escaped-html/2
  s" </x-color></underline></bold>" write-string/2
  3 return0-n
end

def keyword-top-token
  ( s" <div class='definition'>" write-string/2 )
  arg2 arg1 arg0 keyword
  arg2 arg1 arg0 keyword-token-next
  nl
  3 return0-n
end

def keyword-top-token2
  ( s" <div class='definition'>" write-string/2 )
  arg2 arg1 arg0 keyword
  arg2 arg1 arg0 keyword-token-next
  space
  arg2 arg1 arg0 keyword-token-next
  nl
  3 return0-n
end

def keyword-open-token
  ( s" <div class='definition'>" write-string/2 )
  nl nl
  arg2 arg1 arg0 keyword-top-token
  3 return0-n
end

def keyword-end
  nl
  arg2 arg1 arg0 keyword
  ( s" </div>" write-string/2 )
  3 return0-n
end

def keyword-frame
  s" <x-color><param>yellow</param>" write-string/2
  arg2 arg1 write-escaped-html/2
  s" </x-color>" write-string/2
  space
  3 return0-n
end

def keyword-peek
  s" <bold><x-color><param>brightgreen</param>" write-string/2
  arg2 arg1 write-escaped-html/2
  s" </x-color></bold>" write-string/2
  space
  3 return0-n
end

def keyword-poke
  s" <bold><x-color><param>brightyellow</param>" write-string/2
  arg2 arg1 write-escaped-html/2
  s" </x-color></bold>" write-string/2
  space
  3 return0-n
end

def word-eol
  arg2 arg1 write-escaped-html/2
  nl
  3 return0-n
end

def any
  arg2 arg1 write-escaped-html/2
  space
  3 return0-n
end

0 var> highlight-dict

def highlight-lookup ( str len -- fn )
  arg1 arg0 highlight-dict @ cs dict-lookup/4 UNLESS ' any THEN 2 return1-n
end

def highlight/3 ( buffer len state -- )
  arg2 arg1 arg0 highlight-state-reader @ reader-next-token
  negative? IF 3 return0-n ELSE drop THEN
  2dup highlight-lookup dup IF
    arg0 swap exec-abs
    repeat-frame
  THEN
end

def highlight ( reader -- )
  0
  highlight-max-token-size @ stack-allot
  highlight-max-token-size @
  arg0 make-highlight-state set-local0
  highlight-max-token-size @ stack-allot
  highlight-max-token-size @
  local0 highlight/3 1 return0-n
end

def highlight-str
  arg1 arg0 make-string-reader highlight 2 return0-n
end

def highlight-file
  0
  arg0 open-input-file negative? IF
    s" Failed to open: " error-string/2
    arg0 error-string espace
    error-int enl
    1 return0-n
  ELSE set-local0
  THEN
  s" Highlighting " error-string/2 arg0 error-string enl
  highlight-max-token-size @ stack-allot highlight-max-token-size @ local0 make-fd-reader
  dup highlight
  fd-reader-close
  1 return0-n
end

def highlight-stdin
  the-reader @ highlight
end

def highlight-load
  arg2 arg1 write-string/2 nl nl
  arg0 highlight-state-length @ 1 int> IF 
    arg0 highlight-state-buffer @ 1 + highlight-file
  THEN 3 return0-n
end

def highlight-load-list
  arg2 arg1 write-string/2 nl nl
  arg0 highlight-state-token-list @ dup IF
    0 ' highlight-file revmap-cons/3
  THEN
  3 return0-n
end

tmp" BUILDER-TARGET" defined?/2 [UNLESS]
  alias> copies-entry-as> copy-as>
  : to-out-addr cs - ;
[THEN]
  
0
' comment copies-entry-as> ( ( bad emacs )
' keyword-top-token copies-entry-as> var>
' keyword-top-token copies-entry-as> const>
' keyword-top-token copies-entry-as> defvar>
' keyword-top-token copies-entry-as> defconst>
' keyword-top-token copies-entry-as> string-const>
' keyword-top-token copies-entry-as> symbol>
' keyword-top-token copies-entry-as> copies-entry-as>
' keyword-top-token copies-entry-as> copies-as>
' keyword-top-token2 copies-entry-as> alias>
' keyword-top-token2 copies-entry-as> defalias>
' keyword-token copies-entry-as> POSTPONE
' keyword-token copies-entry-as> '
' keyword-token copies-entry-as> out'
' keyword-token copies-entry-as> out-off'
' keyword-token copies-entry-as> literal
' keyword-token copies-entry-as> pointer
' keyword-open-token copies-entry-as> def
' keyword-open-token copies-entry-as> defcol
' keyword-open-token copies-entry-as> :
' keyword-open-token copies-entry-as> defop
' keyword-end copies-entry-as> ;
' keyword-end copies-entry-as> endcol
' keyword-end copies-entry-as> end
' keyword-end copies-entry-as> endop
' keyword copies-entry-as> immediate
' keyword-token copies-entry-as> immediate-as
' keyword copies-entry-as> IF
' keyword copies-entry-as> ELSE
' keyword copies-entry-as> THEN
' keyword copies-entry-as> UNLESS
' keyword copies-entry-as> CASE
' keyword copies-entry-as> ENDCASE
' keyword copies-entry-as> ESAC
' keyword copies-entry-as> WHEN
' keyword copies-entry-as> WHEN-STR
' keyword copies-entry-as> ;;
' keyword copies-entry-as> OF
' keyword copies-entry-as> OF-STR
' keyword copies-entry-as> ENDOF
' keyword copies-entry-as> exit
' keyword copies-entry-as> exit-frame
' keyword copies-entry-as> repeat-frame
' keyword copies-entry-as> loop
' keyword copies-entry-as> return
' keyword copies-entry-as> return0
' keyword copies-entry-as> return1
' keyword copies-entry-as> return2
' keyword copies-entry-as> return0-n
' keyword copies-entry-as> return1-n
' keyword copies-entry-as> return2-n
' keyword-frame copies-entry-as> arg0
' keyword-frame copies-entry-as> arg1
' keyword-frame copies-entry-as> arg2
' keyword-frame copies-entry-as> arg3
' keyword-frame copies-entry-as> argn
' keyword-frame copies-entry-as> set-arg0
' keyword-frame copies-entry-as> set-arg1
' keyword-frame copies-entry-as> set-arg2
' keyword-frame copies-entry-as> set-arg3
' keyword-frame copies-entry-as> set-argn
' keyword-frame copies-entry-as> local0
' keyword-frame copies-entry-as> local1
' keyword-frame copies-entry-as> local2
' keyword-frame copies-entry-as> local3
' keyword-frame copies-entry-as> localn
' keyword-frame copies-entry-as> set-local0
' keyword-frame copies-entry-as> set-local1
' keyword-frame copies-entry-as> set-local2
' keyword-frame copies-entry-as> set-local3
' keyword-frame copies-entry-as> set-localn
' word-eol copies-entry-as> ,ins
' word-eol copies-entry-as> ins!
' word-eol copies-entry-as> load
' word-eol copies-entry-as> load/2
' word-eol copies-entry-as> load-list
' keyword-peek copies-entry-as> peek
' keyword-peek copies-entry-as> @
' keyword-poke copies-entry-as> poke
' keyword-poke copies-entry-as> !
' token-list copies-entry-as> s[
' token-list copies-entry-as> w[
' string copies-entry-as> s"
' string copies-entry-as> c"
' string copies-entry-as> e"
' string copies-entry-as> d"
' string copies-entry-as> "
' string copies-entry-as> tmp"
to-out-addr const> init-highlight-dict

tmp" BUILDER-TARGET" defined?/2 [IF]
  ' init-highlight-dict dict-entry-data @ from-out-addr
[ELSE]
  init-highlight-dict
[THEN]
' highlight-load copies-entry-as> load
' highlight-load copies-entry-as> load/2
' highlight-load-list copies-entry-as> load-list
to-out-addr const> init-recursive-highlight-dict

def highlight-init ( recurse -- )
  arg0 IF init-recursive-highlight-dict ELSE init-highlight-dict THEN
  cs + highlight-dict !
  1 return0-n
end
