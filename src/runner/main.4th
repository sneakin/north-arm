" Hello!" string-const> hello-s

0 defvar> current-input
1 defvar> current-output
2 defvar> current-error

defcol hello
  int32 6 hello-s current-output peek write drop
endcol

def read-uint32
  op-size stack-allot
  op-size over current-input peek read
  op-size equals? IF peek op-mask logand ELSE 0 THEN return1
end

def runner-boot
  read-uint32 dup IF exec repeat-frame ELSE return THEN
end
