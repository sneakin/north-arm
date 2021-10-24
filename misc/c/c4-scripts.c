#include <stdio.h>
#include "c4.h"
#include "c4-words.h"

const char hello[] = "Hello";

Word *hey_def[] = {
  &literal, (Word *)"Hey!", &cputs, &return0
};
Word hey = { "hey", _docol, hey_def, &dict };

Word *_bootstrap[] = {
  &here, &rhere,
  &literal, (Word *)&hello, &cputs,
  &hey,
  &literal, (Word *)"rallot", &cputs,
  &literal, (Word *)1024, &rallot, &write_hex_int,
  &literal, (Word *)"\n123", &cputs,
  &literal, (Word *)1, &literal, (Word *)2, &literal, (Word *)3,
  &swap, &fdup, &write_int, &write_int, &write_int, &write_int,
  &literal, (Word *)"\nrhere", &cputs,
  &here, &swap, &fdup, &write_hex_int, &rhere, &fdup, &write_hex_int, &int_sub, &write_int,
  &literal, (Word *)"\nhere", &cputs,
  &int_sub, &write_int,
  &literal, (Word *)"\ndefs", &cputs, &hey,
  /* &literal, (Word *)10,*/ &return0,
  // unreachable
  (Word *)&hello, &cputs
};

Word bootstrap = { "bootstrap", _docol, _bootstrap, &write_hex_int };

Word *_words1[] = {
  &swap,
  &literal, &next, &swap,
  &literal, (Word *)"Words", &cputs, //&hey,
  //&rhere, &write_hex_int,
  &over, &over, &swap, &int_sub, &write_hex_int, 
  &fdup, &write_hex_int, 
  &fdup, &literal, (Word *)(sizeof(void *) * 1), &int_add, &peek, &write_hex_int,
  &fdup, &literal, (Word *)(sizeof(void *) * 2), &int_add, &peek, &write_hex_int,
  &fdup, &literal, (Word *)(sizeof(void *) * 3), &int_add, &peek, &write_hex_int,
  &fdup, &peek, &cputs,
  &literal, (Word *)(sizeof(void *) * 3), &int_add, &peek,
  &fdup, &literal, (Word *)-36, &ifjump,
  &drop, &drop, &return0
};

Word words1 = { "words/1", _docol, _words1, &over };

Word *_test_rallot_exit[] = {
  &rhere, &fdup, &write_hex_int,
  &literal, (Word *)2048, &rallot,
  &swap, &rhere, &fdup, &write_hex_int,
  &int_sub, &write_int, &drop, &fexit //  &return0,
};

Word test_rallot_exit = { "test_rallot_exit", _docol, _test_rallot_exit, &words1 };

Word *_test_rallot_return[] = {
  &rhere, &fdup, &write_hex_int,
  &literal, (Word *)2048, &rallot,
  &swap, &rhere, &fdup, &write_hex_int,
  &int_sub, &write_int, &drop, &return0,
};

Word test_rallot_return = { "test_rallot_return", _docol, _test_rallot_return, &test_rallot_exit };

Word *_test_rallot[] = {
  &literal, (Word *)"\nrallot and returns", &cputs,
  &rhere, &test_rallot_return,
  &literal, (Word *)"\npost ret", &cputs,
  &rhere, &fdup, &write_hex_int,
  &int_sub, &write_int,

  &literal, (Word *)"\nrallot and exit", &cputs,
  &rhere, &test_rallot_exit,
  &literal, (Word *)"\npost ret", &cputs,
  &rhere, &fdup, &write_hex_int,
  &int_sub, &write_int,

  &return0
};

Word test_rallot = { "test_rallot", _docol, _test_rallot, &test_rallot_return };

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

Word *_test_read[] = {
  &literal, (Word *)1024, &rallot,
  &fdup, &write_hex_int,
  &literal, (Word *)1024, &over, &literal, (Word *)0, &cread,
  &fdup, &write_int,
  &fdup, &literal, (Word *)6, &ifjump,
  &literal, (Word *)"EOF", &cputs,
  &literal, (Word *)2, &jumprel,
  &over, &cputs,
  &drop, &drop, &return0
};

Word test_read = { "test-read", _docol, _test_read, &jumprel };

Word *_words[] = {
  &dict, &words1, &return0
};

Word words = { "words", _docol, _words, &cread };

Word *last_word = &words;

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
  eip = test_nesting0.data.word_list;
  _next(&sp, &eip);
  dump_stack(sp, stack+1023);

  (sp--)->i = 0;
  eip = bootstrap.data.word_list;
  _next(&sp, &eip);
  //Cell *here = _next(sp+1023, (Word **)hey_def);
  dump_stack(sp, stack+1023);

  (sp--)->i = 0;
  eip = words.data.word_list;
  _next(&sp, &eip);
  dump_stack(sp, stack+1023);

  (sp--)->i = 0;
  eip = test_rallot.data.word_list;
  _next(&sp, &eip);
  dump_stack(sp, stack+1023);

  (sp--)->i = 0;
  eip = rpushpop.data.word_list;
  _next(&sp, &eip);
  dump_stack(sp, stack+1023);

  (sp--)->i = 0;
  eip = test_read.data.word_list;
  _next(&sp, &eip);
  dump_stack(sp, stack+1023);

  return sp->i;
}
#endif
