/* Bit of a mix between c1 and c2, with all cases of moving the C return stack
 * covered and more C features.
 */
#include <stdio.h>
#include <stdlib.h>

typedef enum State {
  STOP,
  DROP_FRAME,
  GO,
  POP
} State;

union Cell;
struct Word;
typedef State (*Fun)(union Cell **, struct Word ***);

typedef union Cell
{
  long i;
  void *ptr;
  const char *str;
  struct Word *word;
  struct Word **word_list;
  Fun fn;
} Cell;

typedef struct Word {
  char *name;
  Fun code;
  void *data;
  struct Word *next;
} Word;

const char hello[] = "Hello";

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

State _dup(Cell **sp, Word ***eip) {
  Cell v = **sp;
  *sp -= 1;
  **sp = v;
  return GO;
}

Word dup = { "dup", _dup, (void *)NULL, &swap };

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

Word docol = { "docol", _docol, NULL, &dup };

Word *hey_def[] = {
  &literal, (Word *)"Hey!", &cputs, &return0
};
Word hey = { "hey", _docol, hey_def, &docol };

State _eip(Cell **sp, Word ***eip) {
  *sp -= 1;
  (*sp)->ptr = eip;
  return GO;
}

Word eip = { "eip", _eip, NULL, &hey };

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

Word *_bootstrap[] = {
  &here, &rhere,
  &literal, (Word *)&hello, &cputs,
  &hey,
  &literal, (Word *)"rallot", &cputs,
  &literal, (Word *)1024, &rallot, &write_hex_int,
  &literal, (Word *)"\n123", &cputs,
  &literal, (Word *)1, &literal, (Word *)2, &literal, (Word *)3,
  &swap, &dup, &write_int, &write_int, &write_int, &write_int,
  &literal, (Word *)"\nrhere", &cputs,
  &here, &swap, &dup, &write_hex_int, &rhere, &dup, &write_hex_int, &int_sub, &write_int,
  &literal, (Word *)"\nhere", &cputs,
  &int_sub, &write_int,
  &literal, (Word *)"\ndefs", &cputs, &hey,
  /* &literal, (Word *)10,*/ &return0,
  // unreachable
  (Word *)&hello, &cputs
};

Word bootstrap = { "bootstrap", _docol, _bootstrap, &write_hex_int };

State _int_add(Cell **sp, Word ***eip) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b + a);
  return GO;
}

Word int_add = { "int-add", _int_add, (void *)NULL, &bootstrap };

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

Word *_words1[] = {
  &swap,
  &literal, &next, &swap,
  &literal, (Word *)"Words", &cputs, //&hey,
  //&rhere, &write_hex_int,
  &over, &over, &swap, &int_sub, &write_hex_int, 
  &dup, &write_hex_int, 
  &dup, &literal, (Word *)(sizeof(void *) * 1), &int_add, &peek, &write_hex_int,
  &dup, &literal, (Word *)(sizeof(void *) * 2), &int_add, &peek, &write_hex_int,
  &dup, &literal, (Word *)(sizeof(void *) * 3), &int_add, &peek, &write_hex_int,
  &dup, &peek, &cputs,
  &literal, (Word *)(sizeof(void *) * 3), &int_add, &peek,
  &dup, &literal, (Word *)-36, &ifjump,
  &drop, &drop, &return0
};

Word words1 = { "words/1", _docol, _words1, &over };

Word *_test_rallot_exit[] = {
  &rhere, &dup, &write_hex_int,
  &literal, (Word *)2048, &rallot,
  &swap, &rhere, &dup, &write_hex_int,
  &int_sub, &write_int, &drop, &fexit //  &return0,
};

Word test_rallot_exit = { "test_rallot_exit", _docol, _test_rallot_exit, &words1 };

Word *_test_rallot_return[] = {
  &rhere, &dup, &write_hex_int,
  &literal, (Word *)2048, &rallot,
  &swap, &rhere, &dup, &write_hex_int,
  &int_sub, &write_int, &drop, &return0,
};

Word test_rallot_return = { "test_rallot_return", _docol, _test_rallot_return, &test_rallot_exit };

Word *_test_rallot[] = {
  &literal, (Word *)"\nrallot and returns", &cputs,
  &rhere, &test_rallot_return,
  &literal, (Word *)"\npost ret", &cputs,
  &rhere, &dup, &write_hex_int,
  &int_sub, &write_int,

  &literal, (Word *)"\nrallot and exit", &cputs,
  &rhere, &test_rallot_exit,
  &literal, (Word *)"\npost ret", &cputs,
  &rhere, &dup, &write_hex_int,
  &int_sub, &write_int,

  &return0
};

Word test_rallot = { "test_rallot", _docol, _test_rallot, &test_rallot_return };

State _rpush(Cell **sp, Word ***eip) {
  Cell v = **sp;
  *sp += 1;
  switch(_next(sp, eip)) {
    case POP: *sp -= 1; **sp = v;
    default: return GO;
  }
}

Word rpush = { "rpush", _rpush, NULL, &test_rallot };

State _rpop(Cell **sp, Word ***eip) {
  return POP;
}

Word rpop = { "rpop", _rpop, NULL, &rpush };

Word *_rpushpop[] = {
  &literal, (Word *)"Push pop", &cputs,
  &literal, (Word *)-305,
  &literal, (Word *)123, &rpush,
  &literal, (Word *)456, &rpush,
  &literal, (Word *)789, &rpush,
  &rpop, &write_int,
  &rpop, &write_int,
  &rpop, &write_int,
  &write_int,
  &return0,
};

Word rpushpop = { "rpushpop", _docol, _rpushpop, &rpop };

Word *_test_nesting1[] = {
  &literal, (Word *)"Nesting 1", &cputs,
  &hey, &hey, &return0
};

Word test_nesting1 = { "test_nesting1", _docol, _test_nesting1, &rpushpop };

Word *_test_nesting0[] = {
  &literal, (Word *)"Nesting 0", &cputs,
  &test_nesting1, &test_nesting1, &return0
};

Word test_nesting0 = { "test_nesting0", _docol, _test_nesting0, &test_nesting1 };

extern Word dict;

Word *_words[] = {
  &dict, &words1, &return0
};

Word words = { "words", _docol, _words, &test_nesting0 };

State _dict(Cell **sp, Word ***eip) {
  *sp -= 1;
  **sp = (Cell)&dict;
  return GO;
}

Word dict = { "dict", _dict, NULL, &words };

void dump_stack(Cell *here, Cell *top) {
  printf("Stack: %p\t%p\t%li\n", here, top, top - here);
  while(here < top) {
    printf("%li\t%p\n", here->i, here->ptr);
    here++;
  }
}

#ifndef SHARED
int main() {
  Cell stack[1024];
  Cell *sp = stack+1023;
  Word **eip;
  
  (sp--)->i = 0;
  eip = test_nesting0.data;
  _next(&sp, &eip);
  dump_stack(sp, stack+1023);

  (sp--)->i = 0;
  eip = bootstrap.data;
  _next(&sp, &eip);
  //Cell *here = _next(sp+1023, (Word **)hey_def);
  dump_stack(sp, stack+1023);

  (sp--)->i = 0;
  eip = words.data;
  _next(&sp, &eip);
  dump_stack(sp, stack+1023);

  (sp--)->i = 0;
  eip = test_rallot.data;
  _next(&sp, &eip);
  dump_stack(sp, stack+1023);

  (sp--)->i = 0;
  eip = rpushpop.data;
  _next(&sp, &eip);
  dump_stack(sp, stack+1023);

  return sp->i;
}
#endif