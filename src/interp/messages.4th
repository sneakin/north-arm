( Global streams: )

0 defvar> current-input
1 defvar> current-output
2 defvar> current-error

( Messages: )

" BOOM" string-const> boom-s

defcol boom
  int32 4 boom-s current-output peek write drop
endcol

" Hello!" string-const> hello-s

defcol hello
  int32 6 hello-s current-output peek write drop
endcol

" Ok" string-const> ok-s

defcol ok
  int32 2 ok-s current-output peek write drop
endcol

" Error" string-const> error-s

defcol error-str
  int32 5 error-s current-output peek write drop
endcol

" Failed" string-const> failed-s

defcol failed
  int32 6 failed-s current-output peek write drop
endcol

" Crap!" string-const> crap-s

defcol crap
  int32 5 crap-s current-output peek write drop
endcol

" What?" string-const> what-s

defcol what
  int32 5 what-s current-output peek write drop
endcol

" Boo!" string-const> boo-s

defcol boo
  int32 4 boo-s current-output peek write drop
endcol

" Not Found." string-const> not-found-s

defcol not-found
  int32 10 not-found-s current-error peek write drop
endcol

" 
" string-const> nl-s

defcol nl
  int32 1 nl-s current-output peek write drop
endcol

defcol enl
  int32 1 nl-s current-error peek write drop
endcol

"  " string-const> space-s

defcol space
  int32 1 space-s current-output peek write drop
endcol

defcol espace
  int32 1 space-s current-error peek write drop
endcol

" 	" string-const> tab-s

defcol tab
  int32 1 tab-s current-output peek write drop
endcol

defcol etab
  int32 1 tab-s current-error peek write drop
endcol
