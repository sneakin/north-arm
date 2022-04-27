#include <stddef.h>

#ifndef C4_LAST_WORD
#error Define C4_LAST_WORD to link words into the dictionary.
#endif

const FLASH char _words1_s1[] = "Words";
DEFCOL(words1, &C4_LAST_WORD) {
  &swap,
  &literal, &doconst, &swap,
  &literal, (WordPtr)_words1_s1, &cputs,
  &over, &over, &swap, &int_sub, &write_hex_int, 
  &fdup, &write_hex_int, 
  &fdup, &literal, (WordPtr)offsetof(Word, name), &int_add, &peek, &write_hex_int,
  &fdup, &literal, (WordPtr)offsetof(Word, code), &int_add, &peek, &write_hex_int,
  &fdup, &literal, (WordPtr)offsetof(Word, data), &int_add, &peek, &write_hex_int,
  &fdup, &peek, &cputs,
  &literal, (WordPtr)offsetof(Word, next), &int_add, &peek,
  &fdup, &literal, (WordPtr)-36, &ifjump,
  &drop, &drop, &return0
};

DEFCOL(words, &words1) {
  &dict, &words1, &return0
};
