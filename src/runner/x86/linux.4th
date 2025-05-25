( todo save fp and eval-ip too? )

( Arguments are passed in ebx   ecx   edx   esi   edi   ebp  )

push-asm-mark

: emit-push-state
  cs-reg push
  ds-reg push
  fp-reg push
  eval-ip push
;

: emit-pop-state
  eval-ip pop
  fp-reg pop
  ds-reg pop
  cs-reg pop
;

cell-size 4 * const> state-byte-size

pop-mark

defop syscall/1
  emit-push-state
  0x80 int
  emit-pop-state
  ret
endop

defop syscall/2
  emit-push-state
  cell-size 1 * state-byte-size + esp modrm-sib x1 sib modrm-sib ebx modrm+ movr
  0x80 int
  emit-pop-state
  ebx pop
  cell-size esp esp modrr add#
  ebx push
  ret
endop

defop syscall/3
  emit-push-state
  cell-size 1 * state-byte-size + esp modrm-sib x1 sib modrm-sib ebx modrm+ movr
  cell-size 2 * state-byte-size + esp modrm-sib x1 sib modrm-sib ecx modrm+ movr
  0x80 int
  emit-pop-state
  ebx pop
  cell-size 2 * esp esp modrr add#
  ebx push
  ret
endop

defop syscall/4
  emit-push-state
  cell-size 1 * state-byte-size + esp modrm-sib x1 sib modrm-sib ebx modrm+ movr
  cell-size 2 * state-byte-size + esp modrm-sib x1 sib modrm-sib ecx modrm+ movr
  cell-size 3 * state-byte-size + esp modrm-sib x1 sib modrm-sib edx modrm+ movr
  0x80 int
  emit-pop-state
  ebx pop
  cell-size 3 * esp esp modrr add#
  ebx push
  ret
endop

def open
end

def close
end

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

def getcwd
end

def stat
end


push-asm-mark

: emit-sysexit ( status-reg -- )
  ebx modrr movr
  1 eax mov#
  0x80 int
;

pop-mark
