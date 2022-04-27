#include "c5.h"
#include "c5-words.h"

extern WordDef boot, words, fexit;
extern WordDef one, int_add, fdup, write_int, literal, here, swap, poke, peek, dict_entry_data, dict_entry_name, mem_info, write_hex_int;
extern WordDef current_input, xvar;

#ifdef AVR
void avr_init();
const int STACK_SIZE=512 / sizeof(Cell); //1024;
#else
const int STACK_SIZE=1024 * sizeof(Cell);
#endif

#ifdef STATIC_INPUT
const char static_input_buffer[] = "1 2 int-add write-int words";
const char static_input_length = sizeof(static_input_buffer);
#endif

int main(int argc, const char *argv[], const char *env[])
{
  WordPtr booter[] = {
#ifdef DEBUG
    &literal, (WordPtr)"Hello", &cputs,
    //&words,
    &xvar, &fdup, &write_int, &peek, &write_int,
    &literal, (WordPtr)789, &xvar, &poke,
    &xvar, &peek, &write_int,
    &xvar, &peek_byte, &write_int,
    &current_input, &peek, &write_int,
    &literal, &dict, &peek, &cputs,
#endif
    &boot, &fexit
  };
  WordListPtr eip = booter;
  Cell stack[STACK_SIZE];
  Cell *sp = stack + STACK_SIZE - 1;
#ifdef AVR
  avr_init();
#endif
#ifdef STATIC_INPUT
  printf("Input: %i %s\n", static_input_length, static_input_buffer);
#endif
  _next(&sp, &eip);
  return 0;
}