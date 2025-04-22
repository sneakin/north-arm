( todo save fp and eval-ip too? )

defop syscall/1
  cs-reg push
  data-reg push
  0x80 int
  data-reg pop
  cs-reg pop
  ret
endop

defop syscall/2
  cs-reg push
  data-reg push
  cell-size 3 * esp modrm-sib x1 sib modrm-sib ebx modrm+ movr
  0x80 int
  data-reg pop
  cs-reg pop
  ebx pop
  cell-size esp esp modrr add#
  ebx push
  ret
endop

defop syscall/3
  cs-reg push
  data-reg push
  cell-size 3 * esp modrm-sib x1 sib modrm-sib ebx modrm+ movr
  cell-size 4 * esp modrm-sib x1 sib modrm-sib ecx modrm+ movr
  0x80 int
  data-reg pop
  cs-reg pop
  ebx pop
  cell-size 2 * esp esp modrr add#
  ebx push
  ret
endop

defop syscall/4
  cs-reg push
  data-reg push
  cell-size 3 * esp modrm-sib x1 sib modrm-sib ebx modrm+ movr
  cell-size 4 * esp modrm-sib x1 sib modrm-sib ecx modrm+ movr
  cell-size 5 * esp modrm-sib x1 sib modrm-sib edx modrm+ movr
  0x80 int
  data-reg pop
  cs-reg pop
  ebx pop
  cell-size 3 * esp esp modrr add#
  ebx push
  ret
endop

def read ( len ptr fd -- bytes-or-error )
  arg2 arg1 arg0 3 syscall/4 3 return1-n
end

def write ( len ptr fd -- bytes-or-error )
  arg2 arg1 arg0 4 syscall/4 3 return1-n
end

defcol sysexit ( status -- )
  rot 1 syscall/2
endcol

defcol bye
  0 sysexit
endcol

push-asm-mark

: emit-sysexit ( status-reg -- )
  ebx modrr movr
  1 eax mov#
  0x80 int
;

pop-mark