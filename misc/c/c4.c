/* Bit of a mix between c1 and c2, with all cases of moving the C return stack
 * covered and more C features.
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "c4.h"

State _next(Cell **sp, Word ***eip) {
  Word *w;
  int r = GO;
  while(r == GO && *eip) {
    //printf("%s\n", (**eip)->name);
    w = **eip;
    *eip += 1;
    r = w->code(sp, eip);
  }

  return r;
}

Word next = { "next", _next, (void *)NULL, NULL };

State _cputs(Cell **sp, Word ***eip) {
  puts((*sp)->str);
  (*sp)++;
  return GO;
}

Word cputs = { "cputs", _cputs, NULL, &next };

State _cexit(Cell **sp, Word ***eip) {
  exit((*sp)->i);
  return STOP;
}

Word cexit = { "cexit", _cexit, (void *)NULL, &cputs };

State _literal(Cell **sp, Word ***eip) {
  *sp -= 1;
  **sp = *(Cell *)(*eip);
  *eip += 1;
  return GO;
}

Word literal = { "literal", _literal, (void *)NULL, &cexit };

State _enter(Cell **sp, Word ***eip) {
  Word *w = (*sp)->word;
  *sp -= 1;
  (*sp)->ptr = (Word *)(*eip);
  *eip = w->data;
  return GO;
}

Word enter = { "enter", _enter, (void *)NULL, &literal };

State _return0(Cell **sp, Word ***eip) {
  printf("returning to %p\n", (*sp)->ptr);
  *eip = (*sp)->word_list;
  *sp += 1;
  return DROP_FRAME;
}

Word return0 = { "return0", _return0, (void *)NULL, &enter };

State _rallot(Cell **sp, Word ***eip) {
  Cell *mem = alloca((*sp)->i);
  (*sp)->ptr = mem;
  switch(_next(sp, eip)) {
    case STOP: return STOP;
    default: return GO;
  }
}

Word rallot = { "rallot", _rallot, (void *)NULL, &return0 };

State _here(Cell **sp, Word ***eip) {
  ((*sp)-1)->ptr = *sp;
  *sp -= 1;
  return GO;
}

Word here = { "here", _here, (void *)NULL, &rallot };

State _rhere(Cell **sp, Word ***eip) {
  int n = 0;
  (--(*sp))->ptr = (void *)&n;
  return GO;
}

Word rhere = { "rhere", _rhere, (void *)NULL, &here };

State _int_sub(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b - a);
  return GO;
}

Word int_sub = { "int-sub", _int_sub, (void *)NULL, &rhere };

State _write_int(Cell **sp, Word ***eip) {
  printf("%li ", (*sp)->i);
  *sp += 1;
  return GO;
}

Word write_int = { "write-int", _write_int, (void *)NULL, &int_sub };

State _swap(Cell **sp, Word ***eip) {
  Cell t = **sp;
  **sp = *((*sp)+1);
  *((*sp)+1) = t;
  return GO;
}

Word swap = { "swap", _swap, (void *)NULL, &write_int };

State _fdup(Cell **sp, Word ***eip) {
  Cell v = **sp;
  *sp -= 1;
  **sp = v;
  return GO;
}

Word fdup = { "dup", _fdup, (void *)NULL, &swap };

State _docol(Cell **sp, Word ***eip) {
  State r;
  Word *w = *(*eip-1);
  //printf("docol %p %s from %p\n", w, w->name, *eip);
  *sp -= 1;
  (*sp)->word_list = *eip;
  *eip = w->data;
  switch(r = _next(sp, eip)) {
    case DROP_FRAME: return GO;
    default: return r;
  }
}

Word docol = { "docol", _docol, NULL, &fdup };

State _eip(Cell **sp, Word ***eip) {
  *sp -= 1;
  (*sp)->ptr = eip;
  return GO;
}

Word eip = { "eip", _eip, NULL, &fdup };

State _abort_next(Cell **sp, Word ***eip) {
  return STOP;
}

Word abort_next = { "abort-next", _abort_next, NULL, &eip };

State _write_hex_int(Cell **sp, Word ***eip) {
  printf("%lx ", (*sp)->i);
  *sp += 1;
  return GO;
}

Word write_hex_int = { "write-hex-int", _write_hex_int, (void *)NULL, &abort_next };

State _int_add(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b + a);
  return GO;
}

Word int_add = { "int-add", _int_add, (void *)NULL, &write_hex_int };

State _peek(Cell **sp, Word ***eip) {
  **sp = *(Cell *)((*sp)->ptr);
  return GO;
}

Word peek = { "peek", _peek, (void *)NULL, &int_add };

State _ifjump(Cell **sp, Word ***eip) {
  long n = (*sp)->i;
  *sp += 1;
  if((*sp)->i != 0) {
    *eip += n;
  }
  *sp += 1;
  return GO;
}

Word ifjump = { "ifjump", _ifjump, (void *)NULL, &peek };

State _drop(Cell **sp, Word ***eip) {
  *sp += 1;
  return GO;
}

Word drop = { "drop", _drop, (void *)NULL, &ifjump };

State _fexit(Cell **sp, Word ***eip) {
  *eip = (*sp)->word_list;
  *sp += 1;
  return _next(sp, eip);
}

Word fexit = { "fexit", _fexit, (void *)NULL, &drop };

State _over(Cell **sp, Word ***eip) {
  *sp -= 1;
  **sp = *(*sp+2);
  return _next(sp, eip);
}

Word over = { "over", _over, (void *)NULL, &fexit };

State _rpush(Cell **sp, Word ***eip) {
  Cell v = **sp;
  *sp += 1;
  switch(_next(sp, eip)) {
    case POP: *sp -= 1; **sp = v;
    default: return GO;
  }
}

Word rpush = { "rpush", _rpush, NULL, &over };

State _rpop(Cell **sp, Word ***eip) {
  return POP;
}

Word rpop = { "rpop", _rpop, NULL, &rpush };

State _cread(Cell **sp, Word ***eip) {
  int fd;
  char *data;
  off_t len;
  fd = (*sp)->i;
  *sp += 1;
  data = (*sp)->str;
  *sp += 1;
  len = (*sp)->i;
  printf("read %i, %p, %i\n", fd, data, len);
  (*sp)->i = read(fd, data, len);
  return GO;
}

Word cread = { "cread", _cread, NULL, &rpop };

State _jumprel(Cell **sp, Word ***eip) {
  *eip += (*sp)->i;
  *sp += 1;
  return GO;
}

Word jumprel = { "jumprel", _jumprel, NULL, &cread };

extern Word *last_word;

State _dict(Cell **sp, Word ***eip) {
  *sp -= 1;
  **sp = (Cell)last_word;
  return GO;
}

Word dict = { "dict", _dict, NULL, &jumprel };

