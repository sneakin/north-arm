/* Like c1, but uses an union to represent values on stack.
*/
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include "tailcall.h"

union Cell;
struct Word;
typedef union Cell *(*Fun)(union Cell *, struct Word **);

typedef union Cell
{
  long i;
  void *ptr;
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

PRESERVE_NONE Cell *_next(Cell *sp, Word **eip) {
  //printf("%s\n", (*eip)->name);
  TAILCALL((*eip)->code(sp, eip+1));
}

Word next = { "next", _next, (void *)NULL, NULL };

#define NEXT(sp, eip) TAILCALL(_next(sp, eip))

PRESERVE_NONE Cell *_cputs(Cell *sp, Word **eip) {
  puts((const char *)sp->ptr);
  NEXT(++sp, eip);
}

Word cputs = { "cputs", _cputs, (void *)NULL, &next };

PRESERVE_NONE Cell *_cexit(Cell *sp, Word **eip) {
  exit((int)sp->i);
  NEXT(++sp, eip);
}

Word cexit = { "cexit", _cexit, (void *)NULL, &cputs };

PRESERVE_NONE Cell *_literal(Cell *sp, Word **eip) {
  --sp;
  *sp = *(Cell *)(eip);
  NEXT(sp, ++eip);
}

Word literal = { "literal", _literal, (void *)NULL, &cexit };

PRESERVE_NONE Cell *_enter(Cell *sp, Word **eip) {
#ifdef STACK_RETADDR
  Word *w = (Word *)sp->word;
  sp--;
  sp->ptr = (Word *)eip;
  NEXT(sp, w->data);
#else
  NEXT(_next(sp+1, sp->word_list), ++eip);
#endif
}

Word enter = { "enter", _enter, (void *)NULL, &literal };

PRESERVE_NONE Cell *_return0(Cell *sp, Word **eip) {
#ifdef STACK_RETADDR
  printf("returning to %p\n", (Word **)sp->ptr);
  //NEXT(sp+1, (Word **)sp->word);
  return ++sp;
#else
  return sp;
#endif
}

Word return0 = { "return0", _return0, (void *)NULL, &enter };

PRESERVE_NONE Cell *_rallot(Cell *sp, Word **eip) {
  Cell *mem = alloca(*(unsigned long *)sp);
  sp->ptr = mem;
  NEXT(sp, eip);
}

Word rallot = { "rallot", _rallot, (void *)NULL, &return0 };

PRESERVE_NONE Cell *_here(Cell *sp, Word **eip) {
  (sp-1)->ptr = sp;
  --sp;
  NEXT(sp, eip);
}

Word here = { "here", _here, (void *)NULL, &rallot };

PRESERVE_NONE Cell *_rhere(Cell *sp, Word **eip) {
  int n = 0;
  (--sp)->ptr = (void *)&n;
  NEXT(sp, eip);
}

Word rhere = { "rhere", _rhere, (void *)NULL, &here };

PRESERVE_NONE Cell *_int_sub(Cell *sp, Word **eip) {
  long a = (sp++)->i;
  long b = (sp)->i;
  sp->i = (b - a);
  NEXT(sp, eip);
}

Word int_sub = { "int-sub", _int_sub, (void *)NULL, &rhere };

PRESERVE_NONE Cell *_write_int(Cell *sp, Word **eip) {
  long a = (sp++)->i;
  printf("%i ", (int)a);
  NEXT(sp, eip);
}

Word write_int = { "write-int", _write_int, (void *)NULL, &int_sub };

PRESERVE_NONE Cell *_swap(Cell *sp, Word **eip) {
  Cell t = *sp;
  *sp = *(sp+1);
  *(sp+1) = t;
  NEXT(sp, eip);
}

Word swap = { "swap", _swap, (void *)NULL, &write_int };

PRESERVE_NONE Cell *_dup(Cell *sp, Word **eip) {
  Cell v = *(sp--);
  *sp = v;
  NEXT(sp, eip);
}

Word dup = { "dup", _dup, (void *)NULL, &swap };

PRESERVE_NONE Cell *_docol(Cell *sp, Word **eip) {
  Word *w = *(eip-1);
  printf("docol %p %s from %p\n", w, w->name, eip);
#ifdef STACK_RETADDR
  sp--;
  sp->word_list = eip;
  NEXT(sp, w->data);
#else
  NEXT(_next(sp, w->data), eip);
#endif
}

Word docol = { "docol", _docol, NULL, &dup };

Word *hey_def[] = {
  &literal, (Word *)"Hey!", &cputs, &return0
};
Word hey = { "hey", _docol, hey_def, &docol };

PRESERVE_NONE Cell *_eip(Cell *sp, Word **eip) {
  (--sp)->ptr = eip;
  NEXT(sp, eip);
}

Word eip = { "eip", _eip, NULL, &hey };

Word *_bootstrap[] = {
  &here, &rhere,
  &literal, (Word *)&hello, &cputs,
  &literal, (Word *)1024, &rallot, &write_int,
  &literal, (Word *)"\n123", &cputs,
  &literal, (Word *)1, &literal, (Word *)2, &literal, (Word *)3,
  &swap, &dup, &write_int, &write_int, &write_int, &write_int,
  &literal, (Word *)"\nrhere", &cputs,
  &here, &swap, &dup, &write_int, &rhere, &dup, &write_int, &int_sub, &write_int,
  &literal, (Word *)"\nhere", &cputs,
  &int_sub, &write_int,
  &literal, (Word *)"\ndefs", &cputs, &hey,
  &literal, (Word *)10, &return0,
  // unreachable
  (Word *)&hello, &cputs
};

Word bootstrap = { "bootstrap", _docol, _bootstrap, &eip };

PRESERVE_NONE Cell *_int_add(Cell *sp, Word **eip) {
  long a = (sp++)->i;
  long b = (sp)->i;
  sp->i = (b + a);
  NEXT(sp, eip);
}

Word int_add = { "int-add", _int_add, (void *)NULL, &bootstrap };

PRESERVE_NONE Cell *_peek(Cell *sp, Word **eip) {
  *sp = *(Cell *)sp->ptr;
  NEXT(sp, eip);
}

Word peek = { "peek", _peek, (void *)NULL, &int_add };

PRESERVE_NONE Cell *_ifjump(Cell *sp, Word **eip) {
  long n = (sp++)->i;
  if(sp->i != 0) {
    NEXT(sp+1, eip + n);
  } else {
    NEXT(sp+1, eip);
  }
}

Word ifjump = { "ifjump", _ifjump, (void *)NULL, &peek };

PRESERVE_NONE Cell *_write_hex_int(Cell *sp, Word **eip) {
  long a = (sp++)->i;
  printf("%lx ", a);
  NEXT(sp, eip);
}

Word write_hex_int = { "write-hex-int", _write_hex_int, (void *)NULL, &ifjump };

PRESERVE_NONE Cell *_drop(Cell *sp, Word **eip) {
  NEXT(sp+1, eip);
}

Word drop = { "drop", _drop, (void *)NULL, &write_hex_int };

PRESERVE_NONE Cell *_fexit(Cell *sp, Word **eip) {
#ifdef STACK_RETADDR
  NEXT(sp+1, sp->word_list);
#else
  return sp; //_next(sp, eip);
#endif
}

Word fexit = { "fexit", _fexit, (void *)NULL, &drop };

Word *_words1[] = {
  &literal, (Word *)"Words", &cputs, // &hey,
#ifdef STACK_RETADDR
  &swap,
#endif
  &rhere, &write_hex_int,
  &dup, &write_hex_int,
  &dup, &peek, &cputs,
  &literal, (Word *)(sizeof(void *) * 3), &int_add, &peek,
  &dup, &literal, (Word *)-15, &ifjump,
  &drop, &return0
};

Word words1 = { "words/1", _docol, _words1, &fexit };

PRESERVE_NONE Cell *_dict(Cell *sp, Word **eip) {
  (--sp)->word = &words1;
  NEXT(sp, eip);
}

Word dict = { "dict", _dict, NULL, &words1 };

Word *_words[] = {
  &dict, &words1, &return0
};

Word words = { "words", _docol, _words, &dict };

Word *_rallot_exit[] = {
  &rhere, &dup, &write_hex_int,
  &literal, (Word *)2048, &rallot,
  &swap, &rhere, &dup, &write_hex_int,
  &int_sub, &write_int, &drop, &fexit //  &return0,
};

Word rallot_exit = { "rallot_exit", _docol, _rallot_exit, &words };

Word *_rallot_return[] = {
  &rhere, &dup, &write_hex_int,
  &literal, (Word *)2048, &rallot,
  &swap, &rhere, &dup, &write_hex_int,
  &int_sub, &write_int, &drop, &return0,
};

Word rallot_return = { "rallot_return", _docol, _rallot_return, &rallot_exit };

Word *_rallot2[] = {
  &literal, (Word *)"\nrallot and returns", &cputs,
  &rhere, &rallot_return,
  &literal, (Word *)"\npost ret", &cputs,
  &rhere, &dup, &write_hex_int,
  &int_sub, &write_int,

  &literal, (Word *)"\nrallot and exit", &cputs,
  &rhere, &rallot_exit,
  &literal, (Word *)"\npost ret", &cputs,
  &rhere, &dup, &write_hex_int,
  &int_sub, &write_int,

  &return0
};

Word rallot2 = { "rallot2", _docol, _rallot2, &rallot_return };

void dump_stack(Cell *here, Cell *top) {
  printf("Stack: %p\t%p\t%li\n", here, top, top - here);
  while(here < top) {
    printf("%i\t%x\n", *(int*)(here), *(int*)(here));
    here++;
  }
}

#ifndef SHARED
int main() {
  Cell sp[1024];
  Cell *here = _next(sp+1023, (Word **)bootstrap.data);
  //Cell *here = _next(sp+1023, (Word **)hey_def);
  dump_stack(here, sp+1023);
  here = _next(here, (Word **)words.data);
  dump_stack(here, sp+1023);
  here = _next(here, (Word **)rallot2.data);

  return *(int*)here;
}
#endif