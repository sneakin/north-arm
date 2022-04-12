#include "c4.h"

extern Word boot;

#ifdef AVR
const int STACK_SIZE=1024;
#else
const int STACK_SIZE=1024*8;
#endif

int main()
{
  Word **eip = boot.data.word_list;
  Cell stack[STACK_SIZE];
  Cell *sp = stack + STACK_SIZE - 1;
  _next(&sp, &eip);
  return 0;
}