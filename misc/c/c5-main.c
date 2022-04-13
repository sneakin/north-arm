#include "c5.h"

extern Word boot, words, fexit;
extern Word one, int_add, fdup, write_int, literal, here, swap, poke, peek, dict_entry_data, mem_info, write_hex_int;

#ifdef AVR
void avr_init();
const int STACK_SIZE=1024*2;
#else
const int STACK_SIZE=1024*8;
#endif

int main(int argc, const char *argv[], const char *env[])
{
  Word *booter[] = {
#ifdef DEBUG
    &words,
#endif
    &boot, &fexit
  };
  Word **eip = booter;
  Cell stack[STACK_SIZE];
  Cell *sp = stack + STACK_SIZE - 1;
#ifdef AVR
  avr_init();
#endif
  _next(&sp, &eip);
  return 0;
}