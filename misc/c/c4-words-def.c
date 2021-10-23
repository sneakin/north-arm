#ifndef C4_LAST_WORD
#error Define C4_LAST_WORD to link words into the dictionary.
#endif

Word *_words1[] = {
  &swap,
  &literal, &doconst, &swap,
  &literal, (Word *)"Words", &cputs,
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

Word words1 = { "words/1", _docol, _words1, &C4_LAST_WORD };

Word *_words[] = {
  &dict, &words1, &return0
};

Word words = { "words", _docol, _words, &words1 };
