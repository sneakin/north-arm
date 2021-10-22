#include <stdio.h>
#include "c4.h"
#include "c4-words.h"

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

Word words1 = { "words/1", _docol, _words1, &dict };

Word *_words[] = {
  &dict, &words1, &return0
};

Word words = { "words", _docol, _words, &words1 };

Word *_boot[] = {
  &literal, (Word *)"Hello", &cputs, &words, &return0
};

Word boot = { "boot", _docol, _boot, &words };

Word *last_word = &boot;
