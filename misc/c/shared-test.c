#include <stdio.h>

typedef union Cell {
  void *ptr;
} Cell;

typedef struct Word {
  char *name;
  Cell *(*code)(Cell *stack, struct Word **eip);
  void *data;
  struct Word *next;
} Word;

extern Word words, return0, hey;

int _next(Cell **, Word ***);

Word *code[] = {
  &hey, &words, &hey, &return0
};

int main()
{
  Cell stack[1024];
  Cell *sp = stack + 1023;
  Word **eip = code;
  _next(&sp, &eip);
  return 0;
}