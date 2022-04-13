/* c4 but using return values and eip to control next's loop.
 */
#include <stdio.h>
#include <stdlib.h>

#ifdef AVR
#include "avr.h"
#endif

#include "unix_io.h"
#include "c5.h"

#define DBG_ERROR 1
#define DBG_WARN 3
#define DBG_INFO 4
#define DBG_CALLS 5
#define DBG_TRACE 6

extern Word debug_level;
#define DBGOUT(level, fmt, ...) \
  if(debug_level.data.i & (1<<level)) \
  { fprintf(stderr, "\e[3%im" fmt "\e[37m", level, __VA_ARGS__); }

Word *next_op(Word ***eip) {
  Word *cur = **eip;
  (*eip)++;
  return cur;
}

Word *_doconst(Cell **sp, Word ***eip) {
  *(*sp) = (*sp)->word->data;
  return next_op(eip);
}

Word doconst = { "doconst", _doconst, _doconst, NULL };

Word *_doop(Cell **sp, Word ***eip) {
  Word *w = (*sp)->word;
  Fun f = w->data.fn;
  (*sp) += 1;
  return f(sp, eip);
}

Word doop = { "doop", _doconst, _doop, &doconst };

Word *_exec(Cell **sp, Word ***eip) {
  Word *w = (*sp)->word;
  return w->code(sp, eip);;
}

Word exec = { "exec", _doop, _exec, &doop };

Word *_next(Cell **sp, Word ***eip) {
  const Word *w = **eip, *ow = NULL;
  *eip += 1;
  DBGOUT(DBG_TRACE, "next %p\t%p\t%x\n", *eip, *sp, **sp);
  while(w != NULL && *eip) {
    DBGOUT(DBG_TRACE, "-> %s\t%p\t%x\n", w->name, *sp, **sp);
    *sp -= 1;
    (*sp)->word = w;
    ow = w;
    w = w->code(sp, eip);
  }

  DBGOUT(DBG_TRACE, "-! %p\t%p\t%p\t%x\n", w, *eip, *sp, **sp);
  /*if(*eip) return next_op(eip);
  else */ return NULL;
}

Word next = { "next", _doop, _next, &exec };

Word *_cputs(Cell **sp, Word ***eip) {
  puts((*sp)->str);
  (*sp)++;
  return next_op(eip);
}

Word cputs = { "cputs", _doop, _cputs, &next };

Word *_write_string(Cell **sp, Word ***eip) {
  printf((*sp)->str);
  (*sp)++;
  return next_op(eip);
}

Word write_string = { "write-string", _doop, _write_string, &cputs };

FILE ** const std_streams[] = {
  &stdin, &stdout, &stderr
};

Word *_flush(Cell **sp, Word ***eip) {
  int fd = (*sp)->i;
  if(fd < 3) {
    FILE *io = *std_streams[fd];
    fflush(io);
  }
  (*sp)++;
  return next_op(eip);
}

Word flush = { "flush", _doop, _flush, &write_string };

Word *_cexit(Cell **sp, Word ***eip) {
  exit((*sp)->i);
  return next_op(eip);
}

Word cexit = { "cexit", _doop, _cexit, &flush };

Word *_literal(Cell **sp, Word ***eip) {
  *sp -= 1;
  //*eip += 1;
  **sp = *(Cell *)(*eip);
  DBGOUT(DBG_INFO, "literal %p\t%p\n", **eip, **sp);
  *eip += 1;
  return next_op(eip);
}

Word literal = { "literal", _doop, _literal, &cexit };

extern Word return0;

Word *_return0(Cell **sp, Word ***eip) {
  DBGOUT(DBG_CALLS, "returning stack to %p\n", (*sp)->ptr);
  //*eip = (*sp)->word_list;
  *sp += 1;
  //*sp = (*sp)->cell_ptr;
  *eip = NULL;
  return &return0;
}

Word return0 = { "return0", _doop, _return0, &literal };

Word *_rallot(Cell **sp, Word ***eip) {
  Cell *mem = alloca((*sp)->i);
  (*sp)->ptr = mem;
  Word *w = _next(sp, eip);
  if(*eip) return next_op(eip);
  else return NULL;
}

Word rallot = { "rallot", _doop, _rallot, &return0 };

Word *_here(Cell **sp, Word ***eip) {
  ((*sp)-1)->ptr = *sp;
  *sp -= 1;
  return next_op(eip);
}

Word here = { "here", _doop, _here, &rallot };

Word *_rhere(Cell **sp, Word ***eip) {
  int n = 0;
  (--(*sp))->ptr = (void *)&n;
  return next_op(eip);
}

Word rhere = { "rhere", _doop, _rhere, &here };

Word *_int_sub(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b - a);
  return next_op(eip);
}

Word int_sub = { "int-sub", _doop, _int_sub, &rhere };

Word *_write_int(Cell **sp, Word ***eip) {
  printf("%li ", (*sp)->i);
  fflush(stdout);
  *sp += 1;
  return next_op(eip);
}

Word write_int = { "write-int", _doop, _write_int, &int_sub };

Word *_swap(Cell **sp, Word ***eip) {
  Cell t = **sp;
  **sp = *((*sp)+1);
  *((*sp)+1) = t;
  return next_op(eip);
}

Word swap = { "swap", _doop, _swap, &write_int };

Word *_fdup(Cell **sp, Word ***eip) {
  Cell v = **sp;
  *sp -= 1;
  **sp = v;
  return next_op(eip);
}

Word fdup = { "dup", _doop, _fdup, &swap };

Word *_docol(Cell **sp, Word ***eip) {
  const Word *w = (*sp)->word;
  DBGOUT(DBG_CALLS, "docol %p %s from %p\n", w, w->name, *eip);
  //(*sp)->word_list = *eip;
  //*sp += 1;
  // todo need to push nothing to sp, needs every vord updated
  Cell *fp = (*sp)->ptr = (*sp)+1;
  const Word **neip = w->data.word_list;
  const Word *r = _next(sp, &neip);
  if(neip) DBGOUT(DBG_WARN, "eip is not null\t%p\n", neip);
  DBGOUT(DBG_INFO, "word returned: %p\n", r);
  if(r == &return0) { *sp = fp; return next_op(eip); }
  if(r == NULL) return next_op(eip);
  else return r;
}

Word docol = { "docol", _doconst, _docol, &fdup };

Word *_eip(Cell **sp, Word ***eip) {
  *sp -= 1;
  (*sp)->ptr = eip;
  return next_op(eip);
}

Word eip = { "eip", _doop, _eip, &docol };

Word *_abort_next(Cell **sp, Word ***eip) {
  *eip = NULL;
  return NULL;
}

Word abort_next = { "abort-next", _doop, _abort_next, &eip };

Word *_write_hex_int(Cell **sp, Word ***eip) {
  printf("%lx ", (*sp)->i);
  fflush(stdout);
  *sp += 1;
  return next_op(eip);
}

Word write_hex_int = { "write-hex-int", _doop, _write_hex_int, &abort_next };

Word *_int_add(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b + a);
  return next_op(eip);
}

Word int_add = { "int-add", _doop, _int_add, &write_hex_int };

Word *_int_mul(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b * a);
  return next_op(eip);
}

Word int_mul = { "int-mul", _doop, _int_mul, &int_add };

Word *_int_div(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b / a);
  return next_op(eip);
}

Word int_div = { "int-div", _doop, _int_div, &int_mul };

Word *_int_mod(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b % a);
  return next_op(eip);
}

Word int_mod = { "int-mod", _doop, _int_mod, &int_div };

Word *_int_lte(Cell **sp, Word ***eip) {
  int a = (*sp)->i;
  *sp += 1;
  int b = (*sp)->i;
  (*sp)->i = (b <= a);
  return next_op(eip);
}

Word int_lte = { "int<=", _doop, _int_lte, &int_mod };

Word *_int_lt(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b < a);
  return next_op(eip);
}

Word int_lt = { "int<", _doop, _int_lt, &int_lte };

Word *_equals(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b == a);
  return next_op(eip);
}

Word equals = { "equals?", _doop, _equals, &int_lt };

Word *_peek(Cell **sp, Word ***eip) {
  **sp = *(Cell *)((*sp)->ptr);
  return next_op(eip);
}

Word peek = { "peek", _doop, _peek, &equals };

Word *_poke(Cell **sp, Word ***eip) {
  *(*sp)->cell_ptr = *(*sp+1);
  *sp += 2;
  return next_op(eip);
}

Word poke = { "poke", _doop, _poke, &peek };

Word *_peek_byte(Cell **sp, Word ***eip) {
  (*sp)->i = (*sp)->str[0];
  return next_op(eip);
}

Word peek_byte = { "peek-byte", _doop, _peek_byte, &poke };

Word *_poke_byte(Cell **sp, Word ***eip) {
  (*sp)->str[0] = (*sp+1)->i;
  *sp += 2;
  return next_op(eip);
}

Word poke_byte = { "poke-byte", _doop, _poke_byte, &peek_byte };

Word *_ifjump(Cell **sp, Word ***eip) {
  long n = (*sp)->i;
  *sp += 1;
  if((*sp)->i != 0) {
    *eip += n;
  }
  *sp += 1;
  return next_op(eip);
}

Word ifjump = { "ifjump", _doop, _ifjump, &poke_byte };

Word *_unlessjump(Cell **sp, Word ***eip) {
  long n = (*sp)->i;
  *sp += 1;
  if((*sp)->i == 0) {
    *eip += n;
  }
  *sp += 1;
  return next_op(eip);
}

Word unlessjump = { "unlessjump", _doop, _unlessjump, &ifjump };

Word *_drop(Cell **sp, Word ***eip) {
  *sp += 1;
  return next_op(eip);
}

Word drop = { "drop", _doop, _drop, &unlessjump };

Word *_fexit(Cell **sp, Word ***eip) {
  // *eip = (*sp)->word_list;
  // *sp += 1;
  // return _next(sp, eip);
  DBGOUT(DBG_CALLS, "exiting %p\n", (*sp)->ptr);
  *eip = NULL;
  return NULL;
}

Word fexit = { "fexit", _doop, _fexit, &drop };

Word *_over(Cell **sp, Word ***eip) {
  *sp -= 1;
  **sp = *(*sp+2);
  return next_op(eip);
}

Word over = { "over", _doop, _over, &fexit };

Word *_rpush(Cell **sp, Word ***eip) {
  Cell v = **sp;
  *sp += 1;
  DBGOUT(DBG_INFO, "rpush %p\n", v);
  Word *w = _next(sp, eip);
  if(*eip) {
    DBGOUT(DBG_INFO, "rpopping %p\n", v);
    *sp -= 1;
    **sp = v;
    return next_op(eip);
  } else return NULL;
}

Word rpush = { "rpush", _doop, _rpush, &over };

Word *_rpop(Cell **sp, Word ***eip) {
  DBGOUT(DBG_INFO, "rpop %p\n", *sp);
  return NULL;
}

Word rpop = { "rpop", _doop, _rpop, &rpush };

Word *_cread(Cell **sp, Word ***eip) {
  int fd;
  char *data;
  off_t len;
  fd = (*sp)->i;
  *sp += 1;
  data = (*sp)->str;
  *sp += 1;
  len = (*sp)->i;
  DBGOUT(DBG_INFO, "read %i, %p, %i\n", fd, data, len);
  (*sp)->i = read(fd, data, len);
  DBGOUT(DBG_INFO, "read => %i\t%x\n", (*sp)->i, *(unsigned long *)data);
  return next_op(eip);
}

Word cread = { "cread", _doop, _cread, &rpop };

Word *_cwrite(Cell **sp, Word ***eip) {
  int fd;
  char *data;
  off_t len;
  fd = (*sp)->i;
  *sp += 1;
  data = (*sp)->str;
  *sp += 1;
  len = (*sp)->i;
  //DBGOUT(DBG_INFO, "write %i, %p, %i\n", fd, data, len);
  (*sp)->i = write(fd, data, len);
  //DBGOUT(DBG_INFO, "write => %i\n", (*sp)->i);
  return next_op(eip);
}

Word cwrite = { "cwrite", _doop, _cwrite, &cread };

Word *_jumprel(Cell **sp, Word ***eip) {
  *eip += (*sp)->i;
  *sp += 1;
  return next_op(eip);
}

Word jumprel = { "jumprel", _doop, _jumprel, &cwrite };

Word *_roll(Cell **sp, Word ***eip) {
  Cell t = **sp;
  **sp = *(*sp+1);
  *(*sp+1) = *(*sp+2);
  *(*sp+2) = t;
  return next_op(eip);
}

Word roll = { "roll", _doop, _roll, &jumprel };

Word *_dovar(Cell **sp, Word ***eip) {
  (*sp)->ptr = &(*sp)->word->data;
  return next_op(eip);
}

Word dovar = { "dovar", _doconst, _dovar, &roll };

#ifdef AVR
extern int __heap_start, *__brkval;
Word *_free_ram(Cell **sp, Word ***eip) {
  int v;
  (*sp) -= 1;
  (*sp)->i = (int)&v - (__brkval == 0 ? (int)&__heap_start : (int)__brkval);
  return next_op(eip);
}

Word free_ram = { "free-ram", _doop, _free_ram, &dovar };
#endif

Word *_move(Cell **sp, Word ***eip) {
  *sp = (*sp)->cell_ptr;
  return next_op(eip);
}

Word move = { "move", _doop, _move,
#ifdef AVR
  &free_ram
#else
  &dovar
#endif
};

extern Word *last_word;

Word *_set_dict(Cell **sp, Word ***eip) {
  last_word = (*sp)->word;
  *sp += 1;
  return next_op(eip);
}

Word set_dict = { "set-dict", _doop, _set_dict, &move };

Word *_dict(Cell **sp, Word ***eip) {
  *sp -= 1;
  Cell *here = *sp;
  here->word = last_word;
  return next_op(eip);
}

Word debug_level = { "*debug-level*", _dovar, (void *)DBG_ERROR, &set_dict };
Word dict = { "dict", _doop, _dict, &debug_level };
