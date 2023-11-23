/* Bit of a mix between c1 and c2, with all cases of moving the C return stack
 * covered and more C features.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>

#ifdef AVR
typedef int off_t;


void *alloca(int size)
{
  return NULL;
}
#endif

#ifndef NOUNIX
#include <unistd.h>
#endif

#ifdef NOUNIX
int read(int fd, void *data, size_t length)
{
  unsigned char *bytes = (unsigned char *)data;
  int i = 0;
  while(i < length) {
    bytes[i] = getchar();
    i++;
  }
  return i;
}

/*
void xputchar(unsigned char c)
{
  loop_until_bit_is_set(UCSRA, UDRE);
  UDR = c;
}
*/
int write(int fd, void *data, size_t length)
{
  unsigned char *bytes = (unsigned char *)data;
  int i = 0;
  while(i < length) {
    putchar(bytes[i]);
    i++;
  }
  return i;
}
#endif

#include "c4.h"

State _doconst(Cell **sp, Word ***eip) {
  *(*sp) = (*sp)->word->data;
  return GO;
}

Word doconst = { "doconst", _doconst, _doconst, NULL };

State _doop(Cell **sp, Word ***eip) {
  Word *w = (*sp)->word;
  Fun f = w->data.fn;
  (*sp) += 1;
  return f(sp, eip);
}

Word doop = { "doop", _doconst, _doop, &doconst };

State _exec(Cell **sp, Word ***eip) {
  Word *w = (*sp)->word;
  return w->code(sp, eip);;
}

Word exec = { "exec", _doop, _exec, &doop };

Cell _trace_next = { i: 0 };;
Word trace_next = { "*trace-next*", _doivar, &_trace_next, &exec };

State _next(Cell **sp, Word ***eip) {
  Word *w;
  int r = GO;
  while(r == GO && *eip) {
    if(_trace_next.ui) printf("%s\n", (**eip)->name);
    *sp -= 1;
    w = (*sp)->word = **eip;
    *eip += 1;
    r = w->code(sp, eip);
  }

  return r;
}

Word next = { "next", _doop, _next, &trace_next };

State _cputs(Cell **sp, Word ***eip) {
  puts((*sp)->str);
  (*sp)++;
  return GO;
}

Word cputs = { "cputs", _doop, _cputs, &next };

State _write_string(Cell **sp, Word ***eip) {
  printf((*sp)->str);
  (*sp)++;
  return GO;
}

Word write_string = { "write-string", _doop, _write_string, &cputs };

FILE ** const std_streams[] = {
  &stdin, &stdout, &stderr
};

State _flush(Cell **sp, Word ***eip) {
  int fd = (*sp)->i;
  if(fd < 3) {
    FILE *io = *std_streams[fd];
    fflush(io);
  }
  (*sp)++;
  return GO;
}

Word flush = { "flush", _doop, _flush, &write_string };

State _cexit(Cell **sp, Word ***eip) {
  exit((*sp)->i);
  return STOP;
}

Word cexit = { "cexit", _doop, _cexit, &flush };

State _literal(Cell **sp, Word ***eip) {
  *sp -= 1;
  **sp = *(Cell *)(*eip);
  *eip += 1;
  return GO;
}

Word literal = { "literal", _doop, _literal, &cexit };

State _return0(Cell **sp, Word ***eip) {
  //printf("returning to %p\n", (*sp)->ptr);
  *eip = (*sp)->word_list;
  *sp += 1;
  return DROP_FRAME;
}

Word return0 = { "return0", _doop, _return0, &literal };

State _rallot(Cell **sp, Word ***eip) {
  Cell *mem = alloca((*sp)->i);
  (*sp)->ptr = mem;
  switch(_next(sp, eip)) {
    case STOP: return STOP;
    default: return GO;
  }
}

Word rallot = { "rallot", _doop, _rallot, &return0 };

State _here(Cell **sp, Word ***eip) {
  ((*sp)-1)->ptr = *sp;
  *sp -= 1;
  return GO;
}

Word here = { "here", _doop, _here, &rallot };

State _rhere(Cell **sp, Word ***eip) {
  int n = 0;
  (--(*sp))->ptr = (void *)&n;
  return GO;
}

Word rhere = { "rhere", _doop, _rhere, &here };

State _int_sub(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b - a);
  return GO;
}

Word int_sub = { "int-sub", _doop, _int_sub, &rhere };

State _uint_sub(Cell **sp, Word ***eip) {
  unsigned long a = (*sp)->ui;
  *sp += 1;
  unsigned long b = (*sp)->ui;
  (*sp)->i = (b - a);
  return GO;
}

Word uint_sub = { "uint-sub", _doop, _uint_sub, &int_sub };

State _write_int(Cell **sp, Word ***eip) {
  printf("%li ", (*sp)->i);
  fflush(stdout);
  *sp += 1;
  return GO;
}

Word write_int = { "write-int", _doop, _write_int, &uint_sub };

State _write_uint(Cell **sp, Word ***eip) {
  printf("%lu ", (*sp)->ui);
  fflush(stdout);
  *sp += 1;
  return GO;
}

Word write_uint = { "write-uint", _doop, _write_uint, &write_int };

State _swap(Cell **sp, Word ***eip) {
  Cell t = **sp;
  **sp = *((*sp)+1);
  *((*sp)+1) = t;
  return GO;
}

Word swap = { "swap", _doop, _swap, &write_uint };

State _fdup(Cell **sp, Word ***eip) {
  Cell v = **sp;
  *sp -= 1;
  **sp = v;
  return GO;
}

Word fdup = { "dup", _doop, _fdup, &swap };

State _docol(Cell **sp, Word ***eip) {
  State r;
  Word *w = (*sp)->word;
  //printf("docol %p %s from %p\n", w, w->name, *eip);
  (*sp)->word_list = *eip;
  *eip = w->data.word_list;
  switch(r = _next(sp, eip)) {
    case DROP_FRAME: return GO;
    default: return r;
  }
}

Word docol = { "docol", _doconst, _docol, &fdup };

State _eip(Cell **sp, Word ***eip) {
  *sp -= 1;
  (*sp)->ptr = eip;
  return GO;
}

Word eip = { "eip", _doop, _eip, &docol };

State _abort_next(Cell **sp, Word ***eip) {
  return STOP;
}

Word abort_next = { "abort-next", _doop, _abort_next, &eip };

State _write_hex_int(Cell **sp, Word ***eip) {
  printf("%lx ", (*sp)->i);
  fflush(stdout);
  *sp += 1;
  return GO;
}

Word write_hex_int = { "write-hex-int", _doop, _write_hex_int, &abort_next };

State _int_add(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b + a);
  return GO;
}

Word int_add = { "int-add", _doop, _int_add, &write_hex_int };

State _int_mul(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b * a);
  return GO;
}

Word int_mul = { "int-mul", _doop, _int_mul, &int_add };

State _int_div(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b / a);
  return GO;
}

Word int_div = { "int-div", _doop, _int_div, &int_mul };

State _int_mod(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b % a);
  return GO;
}

Word int_mod = { "int-mod", _doop, _int_mod, &int_div };

State _int_lte(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b <= a);
  return GO;
}

Word int_lte = { "int<=", _doop, _int_lte, &int_mod };

State _int_lt(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b < a);
  return GO;
}

Word int_lt = { "int<", _doop, _int_lt, &int_lte };

State _equals(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b == a);
  return GO;
}

Word equals = { "equals?", _doop, _equals, &int_lt };

State _peek(Cell **sp, Word ***eip) {
  **sp = *(Cell *)((*sp)->ptr);
  return GO;
}

Word peek = { "peek", _doop, _peek, &equals };

State _poke(Cell **sp, Word ***eip) {
  *(*sp)->cell_ptr = *(*sp+1);
  *sp += 2;
  return GO;
}

Word poke = { "poke", _doop, _poke, &peek };

State _peek_byte(Cell **sp, Word ***eip) {
  (*sp)->i = (*sp)->str[0];
  return GO;
}

Word peek_byte = { "peek-byte", _doop, _peek_byte, &poke };

State _poke_byte(Cell **sp, Word ***eip) {
  (*sp)->str[0] = (*sp+1)->i;
  *sp += 2;
  return GO;
}

Word poke_byte = { "poke-byte", _doop, _poke_byte, &peek_byte };

State _ifjump(Cell **sp, Word ***eip) {
  long n = (*sp)->i;
  *sp += 1;
  if((*sp)->i != 0) {
    *eip += n;
  }
  *sp += 1;
  return GO;
}

Word ifjump = { "ifjump", _doop, _ifjump, &poke_byte };

State _unlessjump(Cell **sp, Word ***eip) {
  long n = (*sp)->i;
  *sp += 1;
  if((*sp)->i == 0) {
    *eip += n;
  }
  *sp += 1;
  return GO;
}

Word unlessjump = { "unlessjump", _doop, _unlessjump, &ifjump };

State _drop(Cell **sp, Word ***eip) {
  *sp += 1;
  return GO;
}

Word drop = { "drop", _doop, _drop, &unlessjump };

State _fexit(Cell **sp, Word ***eip) {
  *eip = (*sp)->word_list;
  *sp += 1;
  return _next(sp, eip);
}

Word fexit = { "fexit", _doop, _fexit, &drop };

State _over(Cell **sp, Word ***eip) {
  *sp -= 1;
  **sp = *(*sp+2);
  return _next(sp, eip);
}

Word over = { "over", _doop, _over, &fexit };

State _rpush(Cell **sp, Word ***eip) {
  Cell v = **sp;
  *sp += 1;
  switch(_next(sp, eip)) {
    case POP: *sp -= 1; **sp = v;
    default: return GO;
  }
}

Word rpush = { "rpush", _doop, _rpush, &over };

State _rpop(Cell **sp, Word ***eip) {
  return POP;
}

Word rpop = { "rpop", _doop, _rpop, &rpush };

State _cread(Cell **sp, Word ***eip) {
  int fd;
  char *data;
  off_t len;
  fd = (*sp)->i;
  *sp += 1;
  data = (*sp)->str;
  *sp += 1;
  len = (*sp)->i;
  //printf("read %i, %p, %i\n", fd, data, len);
  (*sp)->i = read(fd, data, len);
  //printf("read => %i\n", (*sp)->i);
  return GO;
}

Word cread = { "cread", _doop, _cread, &rpop };

State _cwrite(Cell **sp, Word ***eip) {
  int fd;
  char *data;
  off_t len;
  fd = (*sp)->i;
  *sp += 1;
  data = (*sp)->str;
  *sp += 1;
  len = (*sp)->i;
  //printf("write %i, %p, %i\n", fd, data, len);
  (*sp)->i = write(fd, data, len);
  //printf("write => %i\n", (*sp)->i);
  return GO;
}

Word cwrite = { "cwrite", _doop, _cwrite, &cread };

State _jumprel(Cell **sp, Word ***eip) {
  *eip += (*sp)->i;
  *sp += 1;
  return GO;
}

Word jumprel = { "jumprel", _doop, _jumprel, &cwrite };

State _roll(Cell **sp, Word ***eip) {
  Cell t = **sp;
  **sp = *(*sp+1);
  *(*sp+1) = *(*sp+2);
  *(*sp+2) = t;
  return GO;
}

Word roll = { "roll", _doop, _roll, &jumprel };

State _dovar(Cell **sp, Word ***eip) {
  (*sp)->ptr = &(*sp)->word->data;
  return GO;
}

Word dovar = { "dovar", _doconst, _dovar, &roll };

State _doivar(Cell **sp, Word ***eip) {
  (*sp)->ptr = (*sp)->word->data.ptr;
  return GO;
}

Word doivar = { "doivar", _doconst, _doivar, &dovar };

State _free_ram(Cell **sp, Word ***eip) {
#ifdef AVR
  extern int __heap_start, *__brkval;
  int v;
  (*sp) -= 1;
  (*sp)->i = (int)&v - (__brkval == 0 ? (int)&__heap_start : (int)__brkval);
#else
  (*sp) -= 1;
  (*sp)->i = -1;
#endif
  return GO;
}

Word free_ram = { "free-ram", _doop, _free_ram, &doivar };

State _ram_used(Cell **sp, Word ***eip) {
  int x;
  static void *init_brk = NULL;
  if(init_brk == NULL) init_brk = &x;
  *sp -= 1;
  (*sp)->ui = init_brk - (void *)&x;
  return GO;
}

Word ram_used = { "ram-used", _doop, _ram_used, &free_ram };

State _move(Cell **sp, Word ***eip) {
  *sp = (*sp)->cell_ptr;
  return GO;
}

Word move = { "move", _doop, _move, &ram_used };

extern Word *last_word;

State _set_dict(Cell **sp, Word ***eip) {
  last_word = (*sp)->word;
  *sp += 1;
  return GO;
}

Word set_dict = { "set-dict", _doop, _set_dict, &move };

State _dict(Cell **sp, Word ***eip) {
  *sp -= 1;
  Cell *here = *sp;
  here->word = last_word;
  //**sp = (Cell)last_word;
  return GO;
}

Word dict = { "dict", _doop, _dict, &set_dict };
