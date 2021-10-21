/* Very minimal Forth interpreter where every op tail calls ~next~.
* Define STACK_RETADDR to push return addresses on the stack and to pop that into eip on returns.
* Without it, ~next~ calls nest and actually return.
*/
#include <stdio.h>
#include <stdlib.h>

typedef long Cell;
struct Word;
typedef Cell *(*Fun)(Cell *stack, struct Word **eip);

typedef struct Word {
  char *name;
  Fun code;
  void *data;
  struct Word *next;
} Word;

const char hello[] = "Hello";

Cell *_next(Cell *sp, Word **eip) {
  //printf("%s\n", (*eip)->name);
  return (*eip)->code(sp, eip+1);
}

Word next = { "next", _next, (void *)NULL, NULL };

Cell *_cputs(Cell *sp, Word **eip) {
  puts((const char *)*sp);
  return _next(++sp, eip);
}

Word cputs = { "cputs", _cputs, (void *)NULL, &next };

Cell *_cexit(Cell *sp, Word **eip) {
  exit((int)*sp);
  return _next(++sp, eip);
}

Word cexit = { "cexit", _cexit, (void *)NULL, &cputs };

Cell *_literal(Cell *sp, Word **eip) {
  --sp;
  *sp = *(Cell *)(eip);
  return _next(sp, ++eip);
}

Word literal = { "literal", _literal, (void *)NULL, &cexit };

Cell *_enter(Cell *sp, Word **eip) {
#ifdef STACK_RETADDR
  Word *w = (Word *)(*sp);
  sp--;
  *sp = (Cell)eip;
  return _next(sp, w->data);
#else
  return _next(_next(sp+1, (Word **)*sp), ++eip);
#endif
}

Word enter = { "enter", _enter, (void *)NULL, &literal };

Cell *_return0(Cell *sp, Word **eip) {
  printf("returning to %p\n", (Word **)*sp);
#ifdef STACK_RETADDR
#if STACK_RETADDR == 1
#warning bootstrap definition has no address to return
  return _next(sp+1, (Word **)(*sp));
#else
  return ++sp;
#endif
#else
  return sp;
#endif
}

Word return0 = { "return0", _return0, (void *)NULL, &enter };

Cell *_rallot(Cell *sp, Word **eip) {
  Cell *mem = alloca(*(unsigned long *)sp);
  *sp = (Cell)mem;
  return _next(sp, eip);
}

Word rallot = { "rallot", _rallot, (void *)NULL, &return0 };

Cell *_here(Cell *sp, Word **eip) {
  *(sp-1) = (Cell)sp;
  --sp;
  return _next(sp, eip);
}

Word here = { "here", _here, (void *)NULL, &rallot };

Cell *_rhere(Cell *sp, Word **eip) {
  int n = 0;
  *(--sp) = (Cell)&n;
  return _next(sp, eip);
}

Word rhere = { "rhere", _rhere, (void *)NULL, &here };

Cell *_int_sub(Cell *sp, Word **eip) {
  Cell a = *(sp++);
  Cell b = *(sp);
  *sp = (Cell)(b - a);
  return _next(sp, eip);
}

Word int_sub = { "int-sub", _int_sub, (void *)NULL, &rhere };

Cell *_write_int(Cell *sp, Word **eip) {
  Cell a = *(sp++);
  printf("%i ", (int)a);
  return _next(sp, eip);
}

Word write_int = { "write-int", _write_int, (void *)NULL, &int_sub };

Cell *_swap(Cell *sp, Word **eip) {
  Cell t = *sp;
  *sp = *(sp+1);
  *(sp+1) = t;
  return _next(sp, eip);
}

Word swap = { "swap", _swap, (void *)NULL, &write_int };

Cell *_dup(Cell *sp, Word **eip) {
  Cell v = *(sp--);
  *sp = v;
  return _next(sp, eip);
}

Word dup = { "dup", _dup, (void *)NULL, &swap };

Cell *_docol(Cell *sp, Word **eip) {
  Word *w = *(eip-1);
#ifdef STACK_RETADDR
  printf("%p %s %p\n", w, w->name, eip);
  sp--;
  *sp = (Cell)eip;
  return _next(sp, w->data);
#else
  return _next(_next(sp, w->data), eip);
#endif
}

Word docol = { "docol", _docol, NULL, &dup };

Word *hey_def[] = {
  &literal, (Word *)"Hey!", &cputs, &return0
};
Word hey = { "hey", _docol, hey_def, &docol };

Cell *_eip(Cell *sp, Word **eip) {
  *(--sp) = (Cell)eip;
  return _next(sp, eip);
}

Word eip = { "eip", _eip, NULL, &hey };

extern Word drop;

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
  &literal, (Word *)10,
#ifdef STACK_RETADDR
  &drop,
#endif
  &return0,
  // unreachable
  (Word *)&hello, &cputs
};

Word bootstrap = { "bootstrap", _docol, _bootstrap, &eip };

Cell *_int_add(Cell *sp, Word **eip) {
  Cell a = *(sp++);
  Cell b = *(sp);
  *sp = (Cell)(b + a);
  return _next(sp, eip);
}

Word int_add = { "int-add", _int_add, (void *)NULL, &bootstrap };

Cell *_peek(Cell *sp, Word **eip) {
  *sp = *(Cell *)(*sp);
  return _next(sp, eip);
}

Word peek = { "peek", _peek, (void *)NULL, &int_add };

Cell *_ifjump(Cell *sp, Word **eip) {
  Cell c = *(sp++);
  if(*sp != 0) {
    return _next(sp+1, eip + (int)c);
  } else {
    return _next(sp+1, eip);
  }
}

Word ifjump = { "ifjump", _ifjump, (void *)NULL, &peek };

Cell *_write_hex_int(Cell *sp, Word **eip) {
  Cell a = *(sp++);
  printf("%lx ", (long)a);
  return _next(sp, eip);
}

Word write_hex_int = { "write-hex-int", _write_hex_int, (void *)NULL, &ifjump };

Cell *_drop(Cell *sp, Word **eip) {
  return _next(sp+1, eip);
}

Word drop = { "drop", _drop, (void *)NULL, &write_hex_int };

Cell *_fexit(Cell *sp, Word **eip) {
#ifdef STACK_RETADDR
  return _next(sp+1, (Word **)(*sp));
#else
#warning fexit not possible
  return _next(sp, (Word **)(*sp));
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

Cell *_dict(Cell *sp, Word **eip) {
  *(--sp) = (Cell)&words1;
  return _next(sp, eip);
}

Word dict = { "dict", _dict, NULL, &words1 };

Word *_words[] = {
  &dict, &words1, &return0
};

Word words = { "words", _docol, _words, &dict };

void dump_stack(Cell *here, Cell *top) {
  printf("Stack: %p\t%p\t%li\n", here, top, top - here);
  while(here < top) {
    printf("%i\t%x\n", *(int*)(here), *(int*)(here));
    here++;
  }
}

int main() {
  Cell sp[1024];
  Cell *here = _next(sp+1023, (Word **)bootstrap.data);
  //Cell *here = _next(sp+1023, (Word **)hey_def);
  dump_stack(here, sp+1023);
  here = _next(here, (Word **)words.data);
  dump_stack(here, sp+1023);

  return *(int*)here;
}