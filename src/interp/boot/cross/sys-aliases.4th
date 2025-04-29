alias> sys:: :
alias> sys-create create
alias> sys-create> create>
alias> sys-defcol defcol
alias> sys-def def
alias> sys-defproper defproper
alias> sys-var> var>
alias> sys-const> const>
alias> sys-string-const> string-const>
alias> sys-symbol> symbol>

alias> sys:immediate immediate
alias> sys:immediate-as immediate-as
alias> sys-immediate immediate
alias> sys-immediate-as immediate-as
alias> sys-alias> alias>

alias> sys:symbol> symbol>
alias> sys:var> var>
alias> sys:const> const>
DEFINED? const-offset> IF
  alias> sys:const-offset> const-offset>
THEN
DEFINED? const IF
  alias> sys:const const
THEN
DEFINED? const-offset IF
  alias> sys:const-offset const-offset
THEN

alias> sys' '
alias> sys'' '' immediate-as sys'
