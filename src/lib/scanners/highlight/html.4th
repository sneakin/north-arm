( Highlighter HTML output: )

( CSS stylesheet to bake in: )

( Toggle between baked into binary or loaded during run: )

true [IF] ( Read now to bake in: )

: html-highlight-read-style ( path ++ style-data )
  allot-read-file
  negative? IF
    2 dropn " /* style failed to load */"
  ELSE
    drop
  THEN
;

tmp" doc/style.css" drop html-highlight-read-style string-const> HTML-HIGHLIGHT-SCREEN-STYLE
tmp" doc/white.css" drop html-highlight-read-style string-const> HTML-HIGHLIGHT-PRINT-STYLE

def html-highlight-screen-style
  HTML-HIGHLIGHT-SCREEN-STYLE return1
end

def html-highlight-print-style
  HTML-HIGHLIGHT-PRINT-STYLE return1
end

[ELSE] ( Read when used: )

s[ src/lib/io.4th ] load-list

( When it can't be found: )
" /* style failed to load */" string-const> HTML-HIGHLIGHT-NO-STYLE

def html-highlight-read-style ( path ++ style )
  2048 arg0 allot-read-file/2 negative? IF
    HTML-HIGHLIGHT-NO-STYLE set-arg0
  ELSE
    drop exit-frame
  THEN
end

def html-highlight-screen-style
  " doc/style.css" html-highlight-read-style exit-frame
end

def html-highlight-print-style
  " doc/white.css" html-highlight-read-style exit-frame
end

[THEN]

( Special character escaping: )

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

( File section and token writers: )

def html-style ( css media -- )
  s" <style media='" write-string/2 arg0 write-string s" '>" write-line/2
  arg1 write-line
  s" </style>" write-line/2
  2 return0-n
end

def html-highlight-heading
  s" <html>
  <head>" write-line/2
  html-highlight-screen-style " screen" html-style
  html-highlight-print-style " print" html-style
  s" </head>
  <body>" write-string/2
end

def html-highlight-footing
  s"   </body>
</html>" write-string/2
end

def html-any
  arg2 arg1 write-escaped-html/2
  space
  3 return0-n
end

def anchor-name-start
  s" <a name='" write-string/2 arg1 arg0 write-escaped-html/2 s" '>" write-string/2
  2 return0-n
end

def anchor-end
  s" </a>" write-string/2
end

def html-heading
  s" <h1>" write-string/2
  arg0 dup string-length anchor-name-start
  arg0 write-string
  anchor-end
  s" </h1>" write-line/2
  1 return0-n
end

def html-file-heading ( str -- )
  s" <div class='file'>" write-line/2
  arg0 html-heading
  s" <pre>" write-string/2
  1 return0-n
end

def html-file-footing
  s" </pre></div>" write-line/2
end

def html-terminated-text ( buffer size done-fn state -- )
  arg3 arg2 arg1 arg0 highlight-state-reader @ reader-read-until
  shift write-escaped-html/2
  0 equals? IF repeat-frame THEN
  arg3 arg2 arg0 highlight-state-reader @ reader-next-token drop write-string/2
  4 return0-n
end

def html-comment
  0
  s" <span class='comment'>" write-string/2
  arg2 arg1 write-string/2
  highlight-max-token-size @ stack-allot set-local0
  local0
  highlight-max-token-size @
  ' comment-done arg0 html-terminated-text
  s" </span>" write-string/2
  nl
  3 return0-n
end

def html-string
  0
  s" <bold class='string'>" write-string/2
  arg2 arg1 write-escaped-html/2
  arg0 highlight-state-last-token @ arg0 highlight-state-last-size @
  ' string-done arg0 highlight-state-reader @ reader-read-until drop
  dup arg0 highlight-state-last-length !
  2dup null-terminate
  write-escaped-html/2
  16 stack-allot 16
  arg0 highlight-state-reader @
  reader-next-token drop write-string/2
  s" </bold>" write-string/2
  space
  3 return0-n
end  

def html-token-list-loop ( buffer size state cons -- cons )
  arg2 cell-size 3 * int< IF
    s" Warning: token list too large." error-line/2
    arg0 4 return1-n
  THEN
  arg3 arg2 arg1 highlight-state-reader @ reader-next-token
  0 int<= IF arg0 4 return1-n THEN
  2dup null-terminate
  over s" ]" string-equals?/3 IF arg0 4 return1-n ELSE 3 dropn THEN
  over s" (" string-equals?/3 IF 3 dropn arg1 html-comment nl repeat-frame ELSE 3 dropn THEN
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

def html-token-list
  s" <span class='keyword delimiting list'>" write-string/2
  arg2 arg1 write-string/2 space
  s" </span>" write-string/2
  arg0 highlight-state-last-token @
  arg0 highlight-state-last-size @
  arg0
  0 html-token-list-loop
  arg0 highlight-state-token-list !
  s" <span class='keyword end-delimiting list'>" write-string/2
  s" ] " write-string/2
  s" </span>" write-string/2
  3 return0-n
end

def html-keyword
  s" <i class='keyword'>" write-string/2
  arg2 arg1 write-escaped-html/2
  s" </i>" write-string/2
  space
  3 return0-n
end

def html-defining-keyword
  s" <i class='keyword defining'>" write-string/2
  arg2 arg1 write-escaped-html/2
  s" </i>" write-string/2
  space
  3 return0-n
end

def html-end-keyword
  s" <i class='keyword end-defining'>" write-string/2
  arg2 arg1 write-escaped-html/2
  s" </i>" write-string/2
  space
  3 return0-n
end

def html-keyword-open
  ( s" <div class='definition'>" write-string/2 )
  nl
  arg2 arg1 arg0 html-keyword
  3 return0-n
end

def html-keyword-token
  ( s" <div class='definition'>" write-string/2 )
  arg2 arg1 arg0 html-defining-keyword
  space s" <bold class='name'>" write-string/2
  highlight-max-token-size @ stack-allot highlight-max-token-size @
  arg0 highlight-state-reader @ reader-next-token
  drop write-escaped-html/2
  s" </bold>" write-string/2
  space
  3 return0-n
end


def html-keyword-token-next
  s" <u class='keyword next name'>" write-string/2
  highlight-max-token-size @ stack-allot highlight-max-token-size @
  arg0 highlight-state-reader @ reader-next-token drop
  2dup anchor-name-start write-escaped-html/2 anchor-end
  s" </u>" write-string/2
  3 return0-n
end

def html-keyword-top-token
  ( s" <div class='definition'>" write-string/2 )
  arg2 arg1 arg0 html-defining-keyword
  arg2 arg1 arg0 html-keyword-token-next
  nl
  3 return0-n
end

def html-keyword-top-token2
  ( s" <div class='definition'>" write-string/2 )
  arg2 arg1 arg0 html-defining-keyword
  arg2 arg1 arg0 html-keyword-token-next
  space
  arg2 arg1 arg0 html-keyword-token-next
  nl
  3 return0-n
end

def html-keyword-open-token
  s" <div class='definition'>" write-string/2
  nl nl
  arg2 arg1 arg0 html-keyword-top-token
  3 return0-n
end

def html-keyword-end
  nl
  arg2 arg1 arg0 html-end-keyword
  s" </div>" write-string/2
  3 return0-n
end

def html-keyword-frame
  s" <b class='keyword frame'>" write-string/2
  arg2 arg1 write-escaped-html/2
  s" </b>" write-string/2
  space
  3 return0-n
end

def html-keyword-peek
  s" <i class='keyword peek'>" write-string/2
  arg2 arg1 write-escaped-html/2
  s" </i>" write-string/2
  space
  3 return0-n
end

def html-keyword-poke
  s" <i class='keyword poke'>" write-string/2
  arg2 arg1 write-escaped-html/2
  s" </i>" write-string/2
  space
  3 return0-n
end

def html-word-eol
  arg2 arg1 write-escaped-html/2
  nl
  3 return0-n
end

def html-keyword-eol
  arg2 arg1 arg0 html-keyword nl
  3 return0-n
end

def html-highlight-load
  arg2 arg1 arg0 html-keyword-eol
  ( arg2 arg1 arg0 highlight-load exit-frame )
  ' highlight-load tail-0
end

def html-highlight-load-list
  arg2 arg1 arg0 html-keyword-eol
  ( arg2 arg1 arg0 highlight-load-list exit-frame )
  ' highlight-load-list tail-0
end

( HTML highlighting dictionary: )


0
' html-keyword-top-token copies-entry-as> var>
' html-keyword-top-token copies-entry-as> const>
' html-keyword-top-token copies-entry-as> defvar>
' html-keyword-top-token copies-entry-as> defconst>
' html-keyword-top-token copies-entry-as> string-const>
' html-keyword-top-token copies-entry-as> symbol>
' html-keyword-top-token copies-entry-as> copies-entry-as>
' html-keyword-top-token copies-entry-as> copies-as>
' html-keyword-top-token2 copies-entry-as> alias>
' html-keyword-top-token2 copies-entry-as> defalias>
' html-keyword-token copies-entry-as> POSTPONE
' html-keyword-token copies-entry-as> '
' html-keyword-token copies-entry-as> out'
' html-keyword-token copies-entry-as> out-off'
' html-keyword-token copies-entry-as> literal
' html-keyword-token copies-entry-as> pointer
' html-keyword-token copies-entry-as> longify
' html-keyword-token copies-entry-as> char-code
' html-keyword-open-token copies-entry-as> def
' html-keyword-open-token copies-entry-as> defcol
' html-keyword-open-token copies-entry-as> :
' html-keyword-open-token copies-entry-as> defop
' html-keyword-end copies-entry-as> ;
' html-keyword-end copies-entry-as> endcol
' html-keyword-end copies-entry-as> end
' html-keyword-end copies-entry-as> endop
' html-keyword copies-entry-as> immediate
' html-keyword-token copies-entry-as> immediate-as
' html-keyword copies-entry-as> IF
' html-keyword copies-entry-as> ELSE
' html-keyword copies-entry-as> THEN
' html-keyword copies-entry-as> UNLESS
' html-keyword copies-entry-as> [IF]
' html-keyword copies-entry-as> [ELSE]
' html-keyword-eol copies-entry-as> [THEN]
' html-keyword copies-entry-as> [UNLESS]
' html-keyword copies-entry-as> CASE
' html-keyword copies-entry-as> ENDCASE
' html-keyword copies-entry-as> ESAC
' html-keyword copies-entry-as> WHEN
' html-keyword copies-entry-as> WHEN-STR
' html-keyword copies-entry-as> ;;
' html-keyword copies-entry-as> OF
' html-keyword copies-entry-as> OF-STR
' html-keyword copies-entry-as> ENDOF
' html-keyword copies-entry-as> exit
' html-keyword copies-entry-as> exit-frame
' html-keyword copies-entry-as> repeat-frame
' html-keyword copies-entry-as> loop
' html-keyword copies-entry-as> return
' html-keyword copies-entry-as> return0
' html-keyword copies-entry-as> return1
' html-keyword copies-entry-as> return2
' html-keyword copies-entry-as> return0-n
' html-keyword copies-entry-as> return1-n
' html-keyword copies-entry-as> return2-n
' html-keyword-frame copies-entry-as> arg0
' html-keyword-frame copies-entry-as> arg1
' html-keyword-frame copies-entry-as> arg2
' html-keyword-frame copies-entry-as> arg3
' html-keyword-frame copies-entry-as> argn
' html-keyword-frame copies-entry-as> set-arg0
' html-keyword-frame copies-entry-as> set-arg1
' html-keyword-frame copies-entry-as> set-arg2
' html-keyword-frame copies-entry-as> set-arg3
' html-keyword-frame copies-entry-as> set-argn
' html-keyword-frame copies-entry-as> local0
' html-keyword-frame copies-entry-as> local1
' html-keyword-frame copies-entry-as> local2
' html-keyword-frame copies-entry-as> local3
' html-keyword-frame copies-entry-as> localn
' html-keyword-frame copies-entry-as> set-local0
' html-keyword-frame copies-entry-as> set-local1
' html-keyword-frame copies-entry-as> set-local2
' html-keyword-frame copies-entry-as> set-local3
' html-keyword-frame copies-entry-as> set-localn
' html-word-eol copies-entry-as> ,ins
' html-word-eol copies-entry-as> ins!
' html-highlight-load copies-entry-as> load
' html-highlight-load copies-entry-as> load/2
' html-highlight-load-list copies-entry-as> load-list
' html-keyword-peek copies-entry-as> peek
' html-keyword-peek copies-entry-as> @
' html-keyword-poke copies-entry-as> poke
' html-keyword-poke copies-entry-as> !
' html-token-list copies-entry-as> s[
' html-token-list copies-entry-as> w[
' html-string copies-entry-as> s"
' html-string copies-entry-as> c"
' html-string copies-entry-as> e"
' html-string copies-entry-as> d"
' html-string copies-entry-as> "
' html-string copies-entry-as> tmp"
' html-comment copies-entry-as> ( ( bad emacs )
to-out-addr const> highlight-html-dict

def html-highlighter
' html-file-footing
' html-file-heading
' html-highlight-footing
' html-highlight-heading
' html-any
highlight-html-dict cs +
here exit-frame
end
