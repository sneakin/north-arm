#include "c4.h"
#include "c4-words.h"
#define C4_LAST_WORD dict
#include "c4-words-def.c"

Word *_boot[] = {
  &literal, (Word *)"Hello", &cputs, &words, &return0
};

Word boot = { "boot", _docol, _boot, &words };

Word *last_word = &boot;
