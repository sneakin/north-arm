#include "c5.h"

extern Word boot, words, fexit;
extern Word one, int_add, fdup, write_int, literal, here, swap, poke;

const int STACK_SIZE=1024*8;

int main()
{
  //Word *booter[] = { &literal, (Word *)3, &fdup, &here, &literal, (Word *)4, &swap, &poke, &write_int, &words, &boot, 0 };
  Word *booter[] = { &boot, &fexit };
  Word **eip = booter;
  Cell stack[STACK_SIZE];
  Cell *sp = stack + STACK_SIZE - 1;
  _next(&sp, &eip);
  return 0;
}