#include <stddef.h>
#include "c5.h"
#include "c5-words.h"

extern WordDef boot, words, fexit;
extern WordDef one, int_add, fdup, write_int, dot, dump_stack, literal, here, swap, poke, peek, dict_entry_data, dict_entry_name, dict_entry_next, mem_info, write_hex_int, read_token, lookup;
extern WordDef current_input, xvar;

#if defined(AVR)
void avr_init();
const int STACK_SIZE=256 / sizeof(Cell); //1024;
#elif defined(INIT_STACK_SIZE)
const int STACK_SIZE=INIT_STACK_SIZE * sizeof(Cell);
#else
const int STACK_SIZE=1024 * sizeof(Cell);
#endif

#ifdef STATIC_INPUT
// fixme needs whitespace to terminate, and terminates w/ a Not Found lookup
const char static_input_buffer[] = "1 2 int-add dup write-int dup int-mul \nwrite-int "; //words dump-stack ";
size_t static_input_length = sizeof(static_input_buffer);
#endif

int main(int argc, const char *argv[], const char *env[])
{
  WordPtr booter[] = {
#ifdef DEBUG
    &literal, (WordPtr)"Hello", &cputs,
    //&words,
    &xvar, &fdup, &write_int, &peek, &write_int,
    &literal, (WordPtr)789, &xvar, &poke,
    &literal, 0, &dict_entry_next, &dot, &drop,
    &xvar, &peek, &write_int,
    &xvar, &peek_byte, &write_int,
    &current_input, &peek, &write_int,
    &literal, 0, &literal, (WordPtr)offsetof(Word, next), &int_add, &dot, &drop,
    &literal, 0, &dict_entry_name, &dot, &drop,
    &literal, &dict, &peek, &cputs,
    &literal, &dict, &dict_entry_name, &peek, &cputs,
    &dict, &dict_entry_name, &peek, &cputs,
    &dict, &dict_entry_next, &peek, &peek, &cputs,
    &literal, last_word, &peek, &cputs,
#endif
    &boot, &fexit
  };
  WordListPtr eip = booter;
  Cell stack[STACK_SIZE];
  Cell *sp = stack + STACK_SIZE - 1;
  sp->ptr = sp;
  sp--;
#ifdef AVR
  avr_init();
#endif
#if defined(STATIC_INPUT) && defined(DEBUG) && !defined(AVR)
  printf("Input: %i %s\r\n", static_input_length, static_input_buffer);
#endif
  _next(&sp, &eip);
  return 0;
}