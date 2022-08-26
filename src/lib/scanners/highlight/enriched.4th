def write-escaped-enriched-byte
  arg0 CASE
    60 WHEN s" <<" write-string/2 ;;
    10 WHEN nl ;;
    arg0 write-byte
    THEN
  ESAC

  1 return0-n
end

def write-escaped-enriched/2 ( str n )
  arg0 0 int<= IF 2 return0-n THEN
  arg1 peek-byte write-escaped-enriched-byte
  arg1 1 + set-arg1
  arg0 1 - set-arg0
  repeat-frame
end

def enriched-highlight-heading
  s" Content-Type: text/enriched" write-line/2
  s" Text-Width: 70" write-line/2
  nl
end

def enriched-highlight-footing
end

def enriched-any
  arg2 arg1 write-escaped-enriched/2
  space
  3 return0-n
end

def enriched-heading
  nl nl s" <center><bigger>" write-string/2
  arg0 write-string
  s" </bigger></center>" write-string/2 nl nl
  1 return0-n
end

def enriched-hr/3 ( str length size )
  nl s" <center><bigger>" write-string/2
  arg2 arg1 arg0 write-string-times/3
  s" </bigger></center>" write-string/2 nl
  3 return0-n
end

def enriched-hr ( size )
  s" -" arg0 enriched-hr/3 1 return0-n
end

def enriched-double-hr ( size )
  s" =" arg0 enriched-hr/3 1 return0-n
end

def enriched-file-heading ( str -- )
  arg0 string-length dup enriched-double-hr
  arg0 enriched-heading
  enriched-hr nl nl nl
  1 return0-n
end

def enriched-file-footing
  nl nl
end

def enriched-terminated-text ( buffer size done-fn state -- )
  arg3 arg2 arg1 arg0 highlight-state-reader @ reader-read-until
  shift write-escaped-enriched/2
  0 equals? IF repeat-frame THEN
  arg3 arg2 arg0 highlight-state-reader @ reader-next-token drop write-string/2
  4 return0-n
end

def enriched-comment
  0
  s" <bold><x-color><param>red</param>" write-string/2
  arg2 arg1 write-string/2
  highlight-max-token-size @ stack-allot set-local0
  local0
  highlight-max-token-size @
  ' comment-done arg0 enriched-terminated-text
  s" </x-color></bold>" write-string/2
  nl
  3 return0-n
end

def enriched-string
  0
  s" <bold><x-color><param>brightmagenta</param>" write-string/2
  arg2 arg1 write-escaped-enriched/2
  arg0 highlight-state-last-token @ arg0 highlight-state-last-size @
  ' string-done arg0 highlight-state-reader @ reader-read-until drop
  dup arg0 highlight-state-last-length !
  2dup null-terminate
  write-escaped-enriched/2
  16 stack-allot 16
  arg0 highlight-state-reader @
  reader-next-token drop write-string/2
  s" </x-color></bold>" write-string/2
  space
  3 return0-n
end  

def enriched-token-list-loop ( buffer size state cons -- cons )
  arg2 cell-size 3 * int< IF
    s" Warning: token list too large." error-line/2
    arg0 4 return1-n
  THEN
  arg3 arg2 arg1 highlight-state-reader @ reader-next-token
  0 int<= IF arg0 4 return1-n THEN
  2dup null-terminate
  over s" ]" string-equals?/3 IF arg0 4 return1-n ELSE 3 dropn THEN
  over s" (" string-equals?/3 IF 3 dropn arg1 enriched-comment nl repeat-frame ELSE 3 dropn THEN
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

def enriched-token-list
  s" <x-color><param>brightmagenta</param>" write-string/2
  arg2 arg1 write-string/2 space
  s" </x-color>" write-string/2
  arg0 highlight-state-last-token @
  arg0 highlight-state-last-size @
  arg0
  0 enriched-token-list-loop
  arg0 highlight-state-token-list !
  s" <x-color><param>brightmagenta</param>" write-string/2
  s" ] " write-string/2
  s" </x-color>" write-string/2
  3 return0-n
end

def enriched-keyword
  s" <x-color><param>blue</param>" write-string/2
  arg2 arg1 write-escaped-enriched/2
  s" </x-color>" write-string/2
  space
  3 return0-n
end

def enriched-keyword-open
  ( s" <div class='definition'>" write-string/2 )
  nl
  arg2 arg1 arg0 enriched-keyword
  3 return0-n
end

def enriched-keyword-token
  ( s" <div class='definition'>" write-string/2 )
  s" <x-color><param>brightmagenta</param>" write-string/2
  arg2 arg1 write-escaped-enriched/2
  space s" <bold>" write-string/2
  highlight-max-token-size @ stack-allot highlight-max-token-size @
  arg0 highlight-state-reader @ reader-next-token
  drop write-escaped-enriched/2
  s" </bold></x-color>" write-string/2
  space
  3 return0-n
end

def enriched-keyword-token-next
  s" <bold><underline><x-color><param>brightcyan</param>" write-string/2
  highlight-max-token-size @ stack-allot highlight-max-token-size @
  arg0 highlight-state-reader @ reader-next-token
  drop write-escaped-enriched/2
  s" </x-color></underline></bold>" write-string/2
  3 return0-n
end

def enriched-keyword-top-token
  ( s" <div class='definition'>" write-string/2 )
  arg2 arg1 arg0 enriched-keyword
  arg2 arg1 arg0 enriched-keyword-token-next
  nl
  3 return0-n
end

def enriched-keyword-top-token2
  ( s" <div class='definition'>" write-string/2 )
  arg2 arg1 arg0 enriched-keyword
  arg2 arg1 arg0 enriched-keyword-token-next
  space
  arg2 arg1 arg0 enriched-keyword-token-next
  nl
  3 return0-n
end

def enriched-keyword-open-token
  ( s" <div class='definition'>" write-string/2 )
  nl nl
  arg2 arg1 arg0 enriched-keyword-top-token
  3 return0-n
end

def enriched-keyword-end
  nl
  arg2 arg1 arg0 enriched-keyword
  ( s" </div>" write-string/2 )
  3 return0-n
end

def enriched-keyword-frame
  s" <x-color><param>yellow</param>" write-string/2
  arg2 arg1 write-escaped-enriched/2
  s" </x-color>" write-string/2
  space
  3 return0-n
end

def enriched-keyword-peek
  s" <bold><x-color><param>brightgreen</param>" write-string/2
  arg2 arg1 write-escaped-enriched/2
  s" </x-color></bold>" write-string/2
  space
  3 return0-n
end

def enriched-keyword-poke
  s" <bold><x-color><param>brightyellow</param>" write-string/2
  arg2 arg1 write-escaped-enriched/2
  s" </x-color></bold>" write-string/2
  space
  3 return0-n
end

def enriched-word-eol
  arg2 arg1 write-escaped-enriched/2 nl
  3 return0-n
end

def enriched-keyword-eol
  arg2 arg1 arg0 enriched-keyword nl nl
  3 return0-n
end

def enriched-highlight-load
  arg2 arg1 arg0 enriched-keyword-eol
  arg0 highlight-state-last-word @ ' enriched-string dict-entry-equiv? IF
    ( arg2 arg1 arg0 highlight-load exit-frame )
    ' highlight-load tail-0
  ELSE
    3 return0-n
  THEN
end

def enriched-highlight-load-list
  arg2 arg1 arg0 enriched-keyword-eol
  arg0 highlight-state-last-word @ ' enriched-token-list dict-entry-equiv? IF
    ( arg2 arg1 arg0 highlight-load-list exit-frame )
    ' highlight-load-list tail-0
  ELSE
    3 return0-n
  THEN
end


(
tmp" BUILDER-TARGET" defined?/2 [IF]
  ' init-highlight-dict dict-entry-data @ from-out-addr
[ELSE]
  init-highlight-dict
[THEN]
)
0
' enriched-keyword-top-token copies-entry-as> var>
' enriched-keyword-top-token copies-entry-as> const>
' enriched-keyword-top-token copies-entry-as> defvar>
' enriched-keyword-top-token copies-entry-as> defconst>
' enriched-keyword-top-token copies-entry-as> string-const>
' enriched-keyword-top-token copies-entry-as> symbol>
' enriched-keyword-top-token copies-entry-as> copies-entry-as>
' enriched-keyword-top-token copies-entry-as> copies-as>
' enriched-keyword-top-token2 copies-entry-as> alias>
' enriched-keyword-top-token2 copies-entry-as> defalias>
' enriched-keyword-token copies-entry-as> POSTPONE
' enriched-keyword-token copies-entry-as> '
' enriched-keyword-token copies-entry-as> out'
' enriched-keyword-token copies-entry-as> out-off'
' enriched-keyword-token copies-entry-as> literal
' enriched-keyword-token copies-entry-as> pointer
' enriched-keyword-token copies-entry-as> longify
' enriched-keyword-token copies-entry-as> char-code
' enriched-keyword-token copies-entry-as> out-immediate-as
' enriched-keyword-token copies-entry-as> immediate-as
' enriched-keyword-token copies-entry-as> copy-as>
' enriched-keyword-token copies-entry-as> copies-entry-as>
' enriched-keyword-token copies-entry-as> create>
' enriched-keyword-open-token copies-entry-as> def
' enriched-keyword-open-token copies-entry-as> defcol
' enriched-keyword-open-token copies-entry-as> :
' enriched-keyword-open-token copies-entry-as> defop
' enriched-keyword-end copies-entry-as> ;
' enriched-keyword-end copies-entry-as> endcol
' enriched-keyword-end copies-entry-as> end
' enriched-keyword-end copies-entry-as> endop
' enriched-keyword copies-entry-as> immediate
' enriched-keyword-token copies-entry-as> immediate-as
' enriched-keyword copies-entry-as> IF
' enriched-keyword copies-entry-as> ELSE
' enriched-keyword copies-entry-as> THEN
' enriched-keyword copies-entry-as> UNLESS
' enriched-keyword copies-entry-as> [IF]
' enriched-keyword copies-entry-as> [ELSE]
' enriched-keyword-eol copies-entry-as> [THEN]
' enriched-keyword copies-entry-as> [UNLESS]
' enriched-keyword copies-entry-as> CASE
' enriched-keyword copies-entry-as> ENDCASE
' enriched-keyword copies-entry-as> ESAC
' enriched-keyword copies-entry-as> WHEN
' enriched-keyword copies-entry-as> WHEN-STR
' enriched-keyword copies-entry-as> ;;
' enriched-keyword copies-entry-as> OF
' enriched-keyword copies-entry-as> OF-STR
' enriched-keyword copies-entry-as> ENDOF
' enriched-keyword copies-entry-as> exit
' enriched-keyword copies-entry-as> exit-frame
' enriched-keyword copies-entry-as> repeat-frame
' enriched-keyword copies-entry-as> loop
' enriched-keyword copies-entry-as> return
' enriched-keyword copies-entry-as> return0
' enriched-keyword copies-entry-as> return1
' enriched-keyword copies-entry-as> return2
' enriched-keyword copies-entry-as> return0-n
' enriched-keyword copies-entry-as> return1-n
' enriched-keyword copies-entry-as> return2-n
' enriched-keyword-frame copies-entry-as> arg0
' enriched-keyword-frame copies-entry-as> arg1
' enriched-keyword-frame copies-entry-as> arg2
' enriched-keyword-frame copies-entry-as> arg3
' enriched-keyword-frame copies-entry-as> argn
' enriched-keyword-frame copies-entry-as> set-arg0
' enriched-keyword-frame copies-entry-as> set-arg1
' enriched-keyword-frame copies-entry-as> set-arg2
' enriched-keyword-frame copies-entry-as> set-arg3
' enriched-keyword-frame copies-entry-as> set-argn
' enriched-keyword-frame copies-entry-as> local0
' enriched-keyword-frame copies-entry-as> local1
' enriched-keyword-frame copies-entry-as> local2
' enriched-keyword-frame copies-entry-as> local3
' enriched-keyword-frame copies-entry-as> localn
' enriched-keyword-frame copies-entry-as> set-local0
' enriched-keyword-frame copies-entry-as> set-local1
' enriched-keyword-frame copies-entry-as> set-local2
' enriched-keyword-frame copies-entry-as> set-local3
' enriched-keyword-frame copies-entry-as> set-localn
' enriched-word-eol copies-entry-as> ,ins
' enriched-word-eol copies-entry-as> ins!
' enriched-highlight-load copies-entry-as> load
' enriched-highlight-load copies-entry-as> load/2
' enriched-highlight-load-list copies-entry-as> load-list
' enriched-keyword-peek copies-entry-as> peek
' enriched-keyword-peek copies-entry-as> @
' enriched-keyword-poke copies-entry-as> poke
' enriched-keyword-poke copies-entry-as> !
' enriched-token-list copies-entry-as> s[
' enriched-token-list copies-entry-as> w[
' enriched-string copies-entry-as> s"
' enriched-string copies-entry-as> c"
' enriched-string copies-entry-as> e"
' enriched-string copies-entry-as> d"
' enriched-string copies-entry-as> "
' enriched-string copies-entry-as> tmp"
' enriched-comment copies-entry-as> ( ( bad emacs )
to-out-addr const> highlight-enriched-dict

def enriched-highlighter
' enriched-file-footing
' enriched-file-heading
' enriched-highlight-footing
' enriched-highlight-heading
' enriched-any
highlight-enriched-dict cs +
here exit-frame
end
