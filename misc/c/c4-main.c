#include "c4.h"

extern Word boot;

const int STACK_SIZE=1024*8;

int main()
{
  Cell stack[STACK_SIZE];
  Cell *sp = stack + STACK_SIZE - 1;
  Word **eip = boot.data;
  _next(&sp, &eip);
  return 0;
}