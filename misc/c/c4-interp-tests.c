Word *_test_reverse[] = {
  &here, &rpush,
  &literal, (Word *)4, &nseq,
  &here, &literal, (Word *)4, &reverse,
  &dump_stack,
  &literal, (Word *)1,
  &here, &literal, (Word *)1, &reverse,
  &dump_stack,
  &literal, (Word *)1, &literal, (Word *)2,
  &here, &literal, (Word *)2, &reverse,
  &dump_stack,
  &literal, (Word *)3, &nseq,
  &here, &literal, (Word *)3, &reverse,
  &dump_stack,
  &literal, (Word *)5, &nseq,
  &here, &literal, (Word *)5, &reverse,
  &dump_stack,
  &literal, (Word *)6, &nseq,
  &here, &literal, (Word *)6, &reverse,
  &dump_stack,
  &rpop, &move, &return0
};

Word test_reverse = { "test-reverse", _docol, _test_reverse, &boot };

Word *last_word = &test_reverse;

