( Syntax highlighting writen in text/enriched. )

def tty-scantool-heading
  bold underline arg0 write-string
  color-reset nl
  1 return0-n
end

( Output handlers: )

def tty-scantool-highlight-heading ( output -- )
  1 return0-n
end

def tty-scantool-highlight-footing ( output )
  color-reset nl
  1 return0-n
end

def tty-scantool-load-error ( err-code path output -- )
  yellow
  s" Failed to open: " write-string/2
  arg2 write-int
  arg2 errno->string dup IF space write-string THEN nl
  color-reset
  3 return0-n
end

def tty-scantool-file-heading ( str output -- )
  nl arg1 tty-scantool-heading nl
  2 return0-n
end

def tty-scantool-file-footing ( output -- )
  nl nl
  1 return0-n
end

( Word handlers: )

def tty-scantool-any
  arg2 arg1 write-string/2
  space
  3 return0-n
end

def tty-scantool-comment
  0
  bold red arg2 arg1 write-string/2
  ' write-string/2 ' comment-done arg0 scantool-terminated-text
  color-reset nl
  3 return0-n
end

def tty-scantool-string
  0
  bold magenta
  arg2 arg1 write-string/2
  arg0 scantool-string
  arg0 scantool-state-last-token @ arg0 scantool-state-last-length @
  write-string/2 write-string/2
  color-reset space
  3 return0-n
end  

def tty-scantool-token-list
  magenta
  arg2 arg1 write-string/2 space
  bold arg0 scantool-token-list 0 ' write-line revmap-cons/3
  color-reset magenta s" ] " write-string/2 color-reset
  3 return0-n
end

def tty-scantool-keyword
  blue arg2 arg1 write-string/2 color-reset
  3 return0-n
end

def tty-scantool-keyword-inline
  arg2 arg1 arg0 tty-scantool-keyword space
  3 return0-n
end

def tty-scantool-keyword-open
  nl
  arg2 arg1 arg0 tty-scantool-keyword
  space
  3 return0-n
end

def tty-scantool-keyword-token
  bold magenta arg2 arg1 write-string/2 space
  scantool-max-token-size @ stack-allot scantool-max-token-size @
  arg0 scantool-state-reader @ reader-next-token
  drop write-string/2
  color-reset space
  3 return0-n
end

def tty-scantool-keyword-token-next
  bold underline cyan
  scantool-max-token-size @ stack-allot scantool-max-token-size @
  arg0 scantool-state-reader @ reader-next-token
  drop write-string/2
  color-reset
  3 return0-n
end

def tty-scantool-keyword-top-token
  arg2 arg1 arg0 tty-scantool-keyword space
  arg2 arg1 arg0 tty-scantool-keyword-token-next nl
  3 return0-n
end

def tty-scantool-keyword-top-token2
  arg2 arg1 arg0 tty-scantool-keyword space
  arg2 arg1 arg0 tty-scantool-keyword-token-next space
  arg2 arg1 arg0 tty-scantool-keyword-token-next nl
  3 return0-n
end

def tty-scantool-keyword-open-token
  nl
  arg2 arg1 arg0 tty-scantool-keyword-top-token
  3 return0-n
end

def tty-scantool-keyword-end
  nl
  arg2 arg1 arg0 tty-scantool-keyword nl
  3 return0-n
end

def tty-scantool-keyword-frame
  yellow
  arg2 arg1 write-string/2
  color-reset space
  3 return0-n
end

def tty-scantool-keyword-peek
  bold green
  arg2 arg1 write-string/2
  color-reset space
  3 return0-n
end

def tty-scantool-keyword-poke
  bold yellow
  arg2 arg1 write-string/2
  color-reset space
  3 return0-n
end

def tty-scantool-word-eol
  arg2 arg1 write-string/2 nl
  3 return0-n
end

def tty-scantool-keyword-eol
  arg2 arg1 arg0 tty-scantool-keyword nl
  3 return0-n
end

def tty-scantool-highlight-load
  arg2 arg1 arg0 tty-scantool-keyword-eol
  arg0 scantool-state-last-word @ ' tty-scantool-string dict-entry-equiv? IF
    ( arg2 arg1 arg0 scantool-load exit-frame )
    ' scantool-load tail-0
  ELSE
    3 return0-n
  THEN
end

def tty-scantool-highlight-load-list
  arg2 arg1 arg0 tty-scantool-keyword-eol
  arg0 scantool-state-last-word @ ' tty-scantool-token-list dict-entry-equiv?
  IF ' scantool-load-list tail-0
  ELSE 3 return0-n
  THEN
end


( Enriched output dictionary: )

0
' tty-scantool-keyword-top-token copies-entry-as> var>
' tty-scantool-keyword-top-token copies-entry-as> const>
' tty-scantool-keyword-top-token copies-entry-as> const-offset>
' tty-scantool-keyword-top-token copies-entry-as> defvar>
' tty-scantool-keyword-top-token copies-entry-as> defconst>
' tty-scantool-keyword-top-token copies-entry-as> defconst-offset>
' tty-scantool-keyword-top-token copies-entry-as> string-const>
' tty-scantool-keyword-top-token copies-entry-as> symbol>
' tty-scantool-keyword-top-token copies-entry-as> copies-entry-as>
' tty-scantool-keyword-top-token copies-entry-as> copies-as>
' tty-scantool-keyword-top-token2 copies-entry-as> alias>
' tty-scantool-keyword-top-token2 copies-entry-as> defalias>
' tty-scantool-keyword-top-token copies-entry-as> seq-field:
' tty-scantool-keyword-top-token copies-entry-as> field:
' tty-scantool-keyword-top-token copies-entry-as> struct:
' tty-scantool-keyword-top-token copies-entry-as> type:
' tty-scantool-keyword-top-token copies-entry-as> OUT:DEFINED?
' tty-scantool-keyword-top-token copies-entry-as> SYS:DEFINED?
' tty-scantool-keyword-top-token copies-entry-as> DEFINED?
' tty-scantool-keyword-token copies-entry-as> POSTPONE
' tty-scantool-keyword-token copies-entry-as> '
' tty-scantool-keyword-token copies-entry-as> out'
' tty-scantool-keyword-token copies-entry-as> out-off'
' tty-scantool-keyword-token copies-entry-as> literal
' tty-scantool-keyword-token copies-entry-as> pointer
' tty-scantool-keyword-token copies-entry-as> longify
' tty-scantool-keyword-token copies-entry-as> char-code
' tty-scantool-keyword-token copies-entry-as> out-immediate-as
' tty-scantool-keyword-token copies-entry-as> cross-immediate-as
' tty-scantool-keyword-token copies-entry-as> immediate-as
' tty-scantool-keyword-token copies-entry-as> copy-as>
' tty-scantool-keyword-token copies-entry-as> copies-entry-as>
' tty-scantool-keyword-token copies-entry-as> create>
' tty-scantool-keyword-open-token copies-entry-as> def
' tty-scantool-keyword-open-token copies-entry-as> defcol
' tty-scantool-keyword-open-token copies-entry-as> :
' tty-scantool-keyword-open-token copies-entry-as> defop
' tty-scantool-keyword-end copies-entry-as> ;
' tty-scantool-keyword-end copies-entry-as> endcol
' tty-scantool-keyword-end copies-entry-as> end
' tty-scantool-keyword-end copies-entry-as> endop
' tty-scantool-keyword-inline copies-entry-as> out-immediate
' tty-scantool-keyword-inline copies-entry-as> cross-immediate
' tty-scantool-keyword-inline copies-entry-as> immediate
' tty-scantool-keyword-inline copies-entry-as> IF
' tty-scantool-keyword-inline copies-entry-as> ELSE
' tty-scantool-keyword-eol copies-entry-as> THEN
' tty-scantool-keyword-inline copies-entry-as> UNLESS
' tty-scantool-keyword-inline copies-entry-as> [IF]
' tty-scantool-keyword-inline copies-entry-as> [ELSE]
' tty-scantool-keyword-eol copies-entry-as> [THEN]
' tty-scantool-keyword-inline copies-entry-as> [UNLESS]
' tty-scantool-keyword-inline copies-entry-as> CASE
' tty-scantool-keyword-eol copies-entry-as> ENDCASE
' tty-scantool-keyword-eol copies-entry-as> ESAC
' tty-scantool-keyword-inline copies-entry-as> WHEN
' tty-scantool-keyword-inline copies-entry-as> WHEN-STR
' tty-scantool-keyword-eol copies-entry-as> ;;
' tty-scantool-keyword-inline copies-entry-as> OF
' tty-scantool-keyword-inline copies-entry-as> OF-STR
' tty-scantool-keyword-eol copies-entry-as> ENDOF
' tty-scantool-keyword-frame copies-entry-as> exit
' tty-scantool-keyword-frame copies-entry-as> exit-frame
' tty-scantool-keyword-frame copies-entry-as> repeat-frame
' tty-scantool-keyword-frame copies-entry-as> loop
' tty-scantool-keyword-frame copies-entry-as> return
' tty-scantool-keyword-frame copies-entry-as> return0
' tty-scantool-keyword-frame copies-entry-as> return1
' tty-scantool-keyword-frame copies-entry-as> return2
' tty-scantool-keyword-frame copies-entry-as> return0-n
' tty-scantool-keyword-frame copies-entry-as> return1-n
' tty-scantool-keyword-frame copies-entry-as> return2-n
' tty-scantool-keyword-frame copies-entry-as> arg0
' tty-scantool-keyword-frame copies-entry-as> arg1
' tty-scantool-keyword-frame copies-entry-as> arg2
' tty-scantool-keyword-frame copies-entry-as> arg3
' tty-scantool-keyword-frame copies-entry-as> argn
' tty-scantool-keyword-frame copies-entry-as> set-arg0
' tty-scantool-keyword-frame copies-entry-as> set-arg1
' tty-scantool-keyword-frame copies-entry-as> set-arg2
' tty-scantool-keyword-frame copies-entry-as> set-arg3
' tty-scantool-keyword-frame copies-entry-as> set-argn
' tty-scantool-keyword-frame copies-entry-as> local0
' tty-scantool-keyword-frame copies-entry-as> local1
' tty-scantool-keyword-frame copies-entry-as> local2
' tty-scantool-keyword-frame copies-entry-as> local3
' tty-scantool-keyword-frame copies-entry-as> localn
' tty-scantool-keyword-frame copies-entry-as> set-local0
' tty-scantool-keyword-frame copies-entry-as> set-local1
' tty-scantool-keyword-frame copies-entry-as> set-local2
' tty-scantool-keyword-frame copies-entry-as> set-local3
' tty-scantool-keyword-frame copies-entry-as> set-localn
' tty-scantool-word-eol copies-entry-as> ,ins
' tty-scantool-word-eol copies-entry-as> ins!
' tty-scantool-highlight-load copies-entry-as> load
' tty-scantool-highlight-load copies-entry-as> load/2
' tty-scantool-highlight-load-list copies-entry-as> load-list
' tty-scantool-keyword-peek copies-entry-as> peek
' tty-scantool-keyword-peek copies-entry-as> @
' tty-scantool-keyword-poke copies-entry-as> poke
' tty-scantool-keyword-poke copies-entry-as> !
' tty-scantool-token-list copies-entry-as> s[
' tty-scantool-token-list copies-entry-as> w[
' tty-scantool-string copies-entry-as> s"
' tty-scantool-string copies-entry-as> c"
' tty-scantool-string copies-entry-as> e"
' tty-scantool-string copies-entry-as> d"
' tty-scantool-string copies-entry-as> "
' tty-scantool-string copies-entry-as> tmp"
' tty-scantool-comment copies-entry-as> ( ( bad emacs )
to-out-addr const> scantool-tty-scantool-dict

def tty-scantool
  ' tty-scantool-comment
  ' tty-scantool-load-error
  ' tty-scantool-file-footing
  ' tty-scantool-file-heading
  ' tty-scantool-highlight-footing
  ' tty-scantool-highlight-heading
  ' tty-scantool-any
  scantool-tty-scantool-dict cs +
  here exit-frame
end
