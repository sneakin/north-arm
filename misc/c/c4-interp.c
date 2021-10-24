#include <stdio.h>
#include "c4.h"
#include "c4-words.h"

#define C4_LAST_WORD dict
#include "c4-words-def.c"

Word *_pick[] = {
  &swap,
  &literal, (Word *)2, &int_add,
  &literal, (Word *)sizeof(Cell), &int_mul,
  &here, &int_add, &peek,
  &swap, &return0
};

Word pick = { "pick", _docol, _pick, &words };

Word standard_input = { "standard-input", _doconst, 0, &pick };
Word standard_output = { "standard-output", _doconst, 1, &standard_input };
Word standard_error = { "standard-error", _doconst, 2, &standard_output };

Word current_input = { "current-input", _dovar, 0, &standard_error };
Word current_output = { "current-output", _dovar, 1, &current_input };
Word current_error = { "current-error", _dovar, 2, &current_output };

Word *_read_byte[] = {
  &literal, (Word *)0, &here,
  &literal, (Word *)1, &swap,
  &current_input, &peek, &cread,
  &fdup, &literal, (Word *)0, &int_lte, &literal, (Word *)3, &ifjump,
  &drop, &swap, &return0,
  &swap, &drop, &literal, (Word *)-1, &int_add, &swap, &return0
};

Word read_byte = { "read-byte", _docol, _read_byte, &current_error };

Word *_is_space[] = {
  &swap, &literal, (Word *)32, &int_lte, &swap, &return0
};

Word is_space = { "is-space?", _docol, _is_space, &read_byte };

Word *_read_token3[] = { // buffer max-len count -- buffer count
// todo empty reads look the same as errors
// leading spaces need to be skipped
  &read_byte, // &fdup, &write_int,
  &fdup, &literal, (Word *)0, &int_lte, &literal, (Word *)21, &ifjump,
  &fdup, &is_space, &literal, (Word *)18, &ifjump,
  &literal, (Word *)4, &pick, // &fdup, &write_hex_int,
  &literal, (Word *)3, &pick, // &fdup, &write_int,
  &int_add, &poke_byte,
  &swap, &literal, (Word *)1, &int_add, /* &fdup, &write_int, */ &swap,
  &literal, (Word *)-29, &jumprel,
  &roll, &swap,
  &drop,
  &literal, (Word *)3, &pick,
  &literal, (Word *)2, &pick,
  &int_add, &literal, (Word *)0, &swap, &poke_byte,
  &return0
};

Word read_token3 = { "read-token/3", _docol, _read_token3, &is_space };

Word *_read_token[] = { // buffer max-len -- buffer read-length
  &roll, &literal, (Word *)0, &read_token3,
  &swap, &drop, &roll, &roll, &return0
};

Word read_token = { "read-token", _docol, _read_token, &read_token3 };

Word stack_top = { "stack-top", _dovar, 0, &read_token };
Word cell_size = { "cell-size", _doconst, (void *)sizeof(Cell), &stack_top };

Word *_memdump[] = { // addr bytes
  &over, &literal, (Word *)0, &int_lte, &literal, (Word *)8, &unlessjump,
  &literal, (Word *)"", &cputs,
  &swap, &drop, &swap, &drop, &return0,
  &literal, (Word *)2, &pick, &peek, &write_hex_int,
  &roll, &cell_size, &int_sub,
  &roll, &cell_size, &int_add,
  &roll,
  &literal, (Word *)-30, &jumprel
};

Word memdump = { "memdump", _docol, _memdump, &cell_size };

Word *_dump_stack[] = {
  &literal, (Word *)"Stack", &cputs,
  &here, &fdup, &write_hex_int,
  &stack_top, &peek,
  &over, &int_sub, &fdup, &write_int,
  &literal, (Word *)"", &cputs,
  &memdump, &return0
};

Word dump_stack = { "dump-stack", _docol, _dump_stack, &memdump };

Word *_dict_entry_name[] = {
  &return0
};

Word dict_entry_name = { "dict-entry-name", _docol, _dict_entry_name, &dump_stack };

Word *_dict_entry_code[] = {
  &swap, &literal, (Word *)sizeof(Cell), &int_add, &swap, &return0
};

Word dict_entry_code = { "dict-entry-code", _docol, _dict_entry_code, &dict_entry_name };

Word *_dict_entry_data[] = {
  &swap, &literal, (Word *)(sizeof(Cell)*2), &int_add, &swap, &return0
};

Word dict_entry_data = { "dict-entry-data", _docol, _dict_entry_data, &dict_entry_code };

Word *_dict_entry_next[] = {
  &swap, &literal, (Word *)(sizeof(Cell)*3), &int_add, &swap, &return0
};

Word dict_entry_next = { "dict-entry-next", _docol, _dict_entry_next, &dict_entry_data };

Word *_byte_string_equals4[] = { // a b length index
  &over, &literal, (Word *)3, &pick, &int_lte, &literal, (Word *)14, &ifjump,
  &roll, &swap, &drop, // a b ra len
  &roll, &swap, &drop, // a len ra
  &roll, &swap, &drop, // ra len
  &drop,
  &literal, (Word *)1, &swap, &return0,
  &over, &literal, (Word *)5, &pick, &int_add, &peek_byte,
  &literal, (Word *)2, &pick, &literal, (Word *)5, &pick, &int_add, &peek_byte,
  &equals, &literal, (Word *)14, &ifjump,
  &roll, &swap, &drop,
  &roll, &swap, &drop,
  &roll, &swap, &drop,
  &drop,
  &literal, (Word *)0, &swap, &return0,
  &swap, &literal, (Word *)1, &int_add, &swap,
  &literal, (Word *)-62, &jumprel
};

Word byte_string_equals4 = { "byte-string-equals?/4", _docol, _byte_string_equals4, &dict_entry_next };

Word *_byte_string_equals3[] = { // a b length
  &literal, (Word *)3, &pick,
  &literal, (Word *)3, &pick,
  &literal, (Word *)3, &pick,
  &literal, (Word *)0, &byte_string_equals4,
  &roll, &swap, &drop, // a b ret ra
  &roll, &swap, &drop, // a ra ret
  &roll, &swap, &drop,
  &return0
};

Word byte_string_equals3 = { "byte-string-equals?/3", _docol, _byte_string_equals3, &byte_string_equals4 };

Word *_lookup[] = { // buffer length dict -- dict ok?
// needs to search the dictionary
  &over, &literal, (Word *)12, &ifjump,
  &swap, &drop, &swap, &drop, &swap, &drop,
  &literal, (Word *)0, &swap, &over, &swap, &return0,
  &over, &dict_entry_name, &peek,
  &literal, (Word *)4, &pick,
  &literal, (Word *)4, &pick, &byte_string_equals3,
  &literal, (Word *)10, &unlessjump,
  &roll, &swap, &drop, // buf ra dict
  &roll, &swap, &drop, // dict ra 
  &literal, (Word *)1, &swap, &return0,
  &swap, &dict_entry_next, &peek, &swap,
  &literal, (Word *)-46, &jumprel
};

Word lookup = { "lookup", _docol, _lookup, &byte_string_equals3 };

Word *_quote[] = {
  &here, &rpush,
  &literal, (Word *)0, &literal, (Word *)0, &literal, (Word *)0, &literal, (Word *)0,
  &here, &literal, (Word *)32, &read_token,
  &fdup, &literal, (Word *)0, &int_lte, &literal, (Word *)14, &ifjump,
  &dict, &lookup,
  &literal, (Word *)9, &unlessjump,
  &rpop, &cell_size, &int_sub, &over, &over, &poke, &move, &swap, &return0,
  &literal, "Not found.", &cputs,
  &rpop, &move, &literal, (Word *)0, &swap, &return0
};

Word quote = { "'", _docol, _quote, &lookup };

Word input_buffer = { "input-buffer", _dovar, 0, &quote };
Word input_buffer_size = { "input-buffer-size", _dovar, 0, &input_buffer };
Word istate = { "istate", _dovar, &exec, &input_buffer_size };

Word *_interp_loop[] = {
  &rpush,
  //&fdup, &write_int, &literal, (Word *)"Loop: ", &cputs,
  &input_buffer, &peek, &input_buffer_size, &peek, &read_token,
  &fdup, &literal, (Word *)0, &int_lt, &literal, (Word *)15, &ifjump,
  &dict, &lookup,
  /* &fdup, &write_int, &fdup, &literal, (Word *)4, &unlessjump,
  &over, &dict_entry_name, &peek, &cputs,  */
  &literal, (Word *)6, &unlessjump,
  &istate, &peek, &exec, &literal, (Word *)1, &jumprel,
  &drop,
  &literal, (Word *)-27, &jumprel,
  &literal, (Word *)"Bye", &cputs,
  &rpop, &return0
};

Word interp_loop = { "interp-loop", _docol, _interp_loop, &istate };

Word *_interp[] = {
  &literal, (Word *)128, &rallot, &input_buffer, &poke,
  &rpush,
  &literal, (Word *)128, &input_buffer_size, &poke,
  &interp_loop,
  &literal, (Word *)0, &input_buffer, &poke,
  &literal, (Word *)0, &input_buffer_size, &poke,
  &rpop, &return0
};

Word interp = { "interp", _docol, _interp, &interp_loop };

Word *_load[] = {
  &rpush,
  &current_input, &peek, &rpush,
  &current_input, &poke, 
  &interp_loop,
  &rpop, &current_input, &poke,
  &rpop, &return0
};

Word load = { "load", _docol, _load, &interp };

Word zero = { "0", _doconst, (void *)0, &load };
Word one = { "1", _doconst, (void *)1, &zero };
Word sixteen = { "16", _doconst, (void *)16, &one };

Word xvar = { "x", _dovar, 0, &sixteen };

Word *_boot[] = {
  &here, &stack_top, &poke,
  &interp, &literal, (Word *)0, &cexit, &return0
};

Word boot = { "boot", _docol, _boot, &xvar };

Word *last_word = &boot;