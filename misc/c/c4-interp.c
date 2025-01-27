#include <stdio.h>
#include <stddef.h>
#ifdef C4
#include "c4.h"
#include "c4-words.h"
#endif
#ifdef C5
#include "c5.h"
#include "c5-words.h"
#endif

#define C4_LAST_WORD dict
#include "c4-words-def.c"

#ifdef AVR
#define TOKEN_BUFFER_SIZE 32
#define INPUT_BUFFER_SIZE 64
#else 
#define TOKEN_BUFFER_SIZE 128
#define INPUT_BUFFER_SIZE 1024
#endif

const FLASH char crnl_str[] = "\r\n";

DEFCONST2(cell_size, "cell-size", { .i = sizeof(Cell) }, &words);

DEFCOL(pick, &cell_size) {
  &swap,
  &literal, (WordPtr)2, &int_add,
  &cell_size, &int_mul,
  &here, &int_add, &peek,
  &swap, &return0
};

DEFCONST2(standard_input, "standard-input", { .i = 0 }, &pick);
DEFCONST2(standard_output, "standard-output", { .i = 1 }, &standard_input);
DEFCONST2(standard_error, "standard-error", { .i = 2 }, &standard_output);

DEFVAR2(current_input, "current-input", { .i = 0 }, &standard_error);
DEFVAR2(current_output, "current-output", { .i = 1 }, &current_input);
DEFVAR2(current_error, "current-error", { .i = 2 }, &current_output);

DEFVAR2(input_buffer, "input-buffer", { .ptr = NULL }, &current_error);
DEFVAR2(input_buffer_max_size, "input-buffer-max-size", { .i = 0 }, &input_buffer);
DEFVAR2(input_buffer_size, "input-buffer-size", { .i = 0 }, &input_buffer_max_size);
DEFVAR2(input_buffer_offset, "input-buffer-offset", { .i = 0 }, &input_buffer_size);

DEFVAR2(stack_top, "stack-top", { .ui = 0 }, &input_buffer_offset);
DEFVAR2(stack_prompt, "stack-prompt", { .ui = 0 }, &stack_top);

const FLASH char empty_string[] = "";

DEFCOL(nl, &stack_prompt) {
  &literal, (WordPtr)empty_string, &cputs, &return0
};

DEFCOL2(dot, ".", &nl) {
  &over, &write_int, &nl, &return0
};

DEFCOL(memdump, &dot) {
  // addr bytes --
  //&over, &write_int, &literal, (WordPtr)123, &write_int,
  &over, &literal, (WordPtr)0, &int_lte, &literal, (WordPtr)6, &unlessjump,
  &nl,
  &swap, &drop, &swap, &drop, &return0,
  &literal, (WordPtr)2, &pick, &peek, &write_hex_int,
  &roll, &cell_size, &int_sub,
  &roll, &cell_size, &int_add,
  &roll,
  &literal, (WordPtr)-28, &jumprel
};

const FLASH char dump_stack_s1[] = "Stack";

DEFCOL2(dump_stack, "dump-stack", &memdump) {
  &literal, (WordPtr)dump_stack_s1, &cputs,
  &here, &fdup, &write_hex_int,
  &stack_top, &peek, &fdup, &write_hex_int,
  &over, &ptr_sub, &fdup, &write_uint,
  &literal, (WordPtr)empty_string, &cputs, &fdup, &write_int, 
  &memdump, &return0
};

const FLASH char prompt_str[] = "> ";

DEFCOL(prompt, &dump_stack) {
  &stack_prompt, &peek, &fdup, &write_hex_int,
  &fdup, &literal, (WordPtr)1, &unlessjump, &peek, &write_int,
  &literal, (WordPtr)prompt_str, &write_string,
  &current_output, &peek, &flush,
  &return0
};

DEFCOL2(read_byte, "read-byte", &prompt) {
  // ++ byte || < 0
  &literal, (WordPtr)0, &here,
  &literal, (WordPtr)1, &swap,
  &current_input, &peek, &cread,
  &fdup, &literal, (WordPtr)0, &int_lte, &literal, (WordPtr)3, &ifjump,
  &drop, &swap, &return0,
  &swap, &drop, &literal, (WordPtr)-1, &int_add, &swap, &return0
};

DEFCOL2(is_space, "is-space?", &read_byte) {
  // byte -- yes?
  &swap, &literal, (WordPtr)32, &equals, &swap, &return0
};

DEFCOL2(is_newline, "is-newline?", &is_space) {
  // byte -- yes?
  &swap, &literal, (WordPtr)10, &equals, &swap, &return0
};

DEFCOL2(read_line3, "read-line/3", &is_newline) {
  // buffer max-len counter -- buffer counter
  &literal, (WordPtr)2, &pick,
  &literal, (WordPtr)2, &pick,
  &int_lte, &literal, (WordPtr)3, &unlessjump, &shift, &drop, &return0,
  &read_byte,
  &fdup, &literal, 0, &int_lt, &literal, (WordPtr)4, &unlessjump, &drop, &shift, &drop, &return0,
  &fdup,
  &literal, (WordPtr)5, &pick,
  &literal, (WordPtr)4, &pick,
  &int_add, &poke_byte,
  &rot, &literal, (WordPtr)1, &int_add, &rot,
  &is_newline, &literal, (WordPtr)3, &unlessjump, &shift, &drop, &return0,
  &literal, (WordPtr)-49, &jumprel
};

DEFCOL2(null_terminate, "null-terminate", &read_line3) {
  // string length --
  &shift, &shift, &int_add,
  &literal, (WordPtr)0, &swap, &poke_byte,
  &return0
};

DEFCOL2(refill_input_buffer, "refill-input-buffer", &null_terminate) {
  // ++ ok?
  &prompt,
  &input_buffer, &peek, &input_buffer_max_size, &peek, &literal, 0, &read_line3,
  &fdup, &literal, 0, &int_lte, &literal, (WordPtr)3, &ifjump, &over, &over, &null_terminate,
  &swap, &drop,
  &fdup, &input_buffer_size, &poke,
  &literal, 0, &input_buffer_offset, &poke,
  &literal, 0, &int_lte, &literal, (WordPtr)4, &unlessjump, &literal, 0, &swap, &return0,
  &literal, (WordPtr)1, &swap, &return0
};

DEFCOL2(input_buffer_read_byte, "input-buffer-read-byte", &refill_input_buffer) {
  // ++ byte || < 0
  &input_buffer_size, &peek,
  &fdup, &literal, 0, &int_lt, &literal, (WordPtr)2, &unlessjump, &swap, &return0,
  &input_buffer_offset, &peek, &swap, &int_lt, &literal, (WordPtr)11, &ifjump,
  &refill_input_buffer, &literal, (WordPtr)4, &ifjump, &literal, (WordPtr)-1, &swap, &return0,
  &literal, (WordPtr)-29, &jumprel,
  &input_buffer, &peek, &input_buffer_offset, &peek, &int_add, &peek_byte,
  &input_buffer_offset, &peek, &literal, (WordPtr)1, &int_add, &input_buffer_offset, &poke,
  &swap, &return0
};

DEFCOL2(eat_spaces, "eat-spaces", &input_buffer_read_byte) {
  // ++ next-byte || < 0
  //&read_byte,
  &input_buffer_read_byte,
  &fdup, &is_newline, &literal, (WordPtr)4, &unlessjump, &drop, &literal, (WordPtr)-10, &jumprel,
  &fdup, &is_space, &literal, (WordPtr)4, &unlessjump, &drop, &literal, (WordPtr)-19, &jumprel,
  &swap, &return0
};

DEFCOL2(read_token3, "read-token/3", &eat_spaces) {
  // buffer max-len count -- buffer count
  &eat_spaces, &literal, (WordPtr)1, &jumprel,
  //&read_byte,
  &input_buffer_read_byte,
  &fdup, &literal, (WordPtr)0, &int_lt, &literal, (WordPtr)26, &ifjump,
  // fixme is null / EOF
  &fdup, &is_newline, &literal, (WordPtr)21, &ifjump,
  &fdup, &is_space, &literal, (WordPtr)16, &ifjump,
  &literal, (WordPtr)4, &pick,
  &literal, (WordPtr)3, &pick,
  &int_add, &poke_byte,
  &swap, &literal, (WordPtr)1, &int_add, &swap,
  &literal, (WordPtr)-34, &jumprel,
  &literal, (WordPtr)4, &pick,
  &literal, (WordPtr)3, &pick,
  &int_add, &literal, (WordPtr)0, &swap, &poke_byte,
  &drop, &shift, &drop, &return0
};

DEFCOL2(read_token, "read-token", &read_token3) {
  // buffer max-len -- buffer read-length
  &roll, &literal, (WordPtr)0, &read_token3,
  &shift, &return0
};

DEFCOL2(dict_entry_name, "dict-entry-name", &read_token) {
  &swap, &literal, (WordPtr)offsetof(Word, name), &int_add, &swap, &return0
};

DEFCOL2(dict_entry_code, "dict-entry-code", &dict_entry_name) {
  &swap, &literal, (WordPtr)offsetof(Word, code), &int_add, &swap, &return0
};

DEFCOL2(dict_entry_data, "dict-entry-data", &dict_entry_code) {
  &swap, &literal, (WordPtr)offsetof(Word, data), &int_add, &swap, &return0
};

DEFCOL2(dict_entry_next, "dict-entry-next", &dict_entry_data) {
  &swap, &literal, (WordPtr)offsetof(Word, next), &int_add, &swap, &return0
};

DEFCOL2(byte_string_equals4, "byte-string-equals?/4", &dict_entry_next) {
  // a b length index -- yes?
  // index <= length
  &over, &literal, (WordPtr)3, &pick, &int_lte, &literal, (WordPtr)14, &ifjump,
  // got to the end, drop args and return true
  &roll, &swap, &drop, // a b ra len
  &roll, &swap, &drop, // a len ra
  &roll, &swap, &drop, // ra len
  &drop,
  &literal, (WordPtr)1, &swap, &return0,
  // compare bytes at index
  &over, &literal, (WordPtr)5, &pick, &int_add, &peek_byte,
  &literal, (WordPtr)2, &pick, &literal, (WordPtr)5, &pick, &int_add, &peek_byte,
  &equals, &literal, (WordPtr)14, &ifjump,
  // mismatched, return false
  &roll, &swap, &drop,
  &roll, &swap, &drop,
  &roll, &swap, &drop,
  &drop,
  &literal, (WordPtr)0, &swap, &return0,
  // matched, increment index and repeat
  &swap, &literal, (WordPtr)1, &int_add, &swap,
  &literal, (WordPtr)-62, &jumprel
};

DEFCOL2(byte_string_equals3, "byte-string-equals?/3", &byte_string_equals4) {
  // a b length -- yes?
  &literal, (WordPtr)3, &pick,
  &literal, (WordPtr)3, &pick,
  &literal, (WordPtr)3, &pick,
  &literal, (WordPtr)0, &byte_string_equals4,
  &roll, &swap, &drop, // a b ret ra
  &roll, &swap, &drop, // a ra ret
  &roll, &swap, &drop,
  &return0
};

DEFCOL(lookup, &byte_string_equals3) {
  // buffer length dict -- dict ok?
  // needs to search the dictionary
  // todo handle when the name is null
  //&over, &write_int,
  //&literal, (WordPtr)1245, &write_int,
  &over, &literal, (WordPtr)12, &ifjump,
  &swap, &drop, &swap, &drop, &swap, &drop,
  &literal, (WordPtr)0, &swap, &over, &swap, &return0,
  &over, &dict_entry_name, &peek,
  //&fdup, &cputs,
  &literal, (WordPtr)4, &pick,
  &literal, (WordPtr)4, &pick, &byte_string_equals3,
  &literal, (WordPtr)10, &unlessjump,
  &roll, &swap, &drop, // buf ra dict
  &roll, &swap, &drop, // dict ra 
  &literal, (WordPtr)1, &swap, &return0,
  &swap, &dict_entry_next, &peek, &swap,
  &literal, (WordPtr)-46, &jumprel
};

const FLASH char not_found[] = "Not found.";

DEFCOL2(quote, "'", &lookup) {
  // -- word
  &here, &rpush,
  &literal, (WordPtr)0, &literal, (WordPtr)0, &literal, (WordPtr)0, &literal, (WordPtr)0,
  &here, &literal, (WordPtr)32, &read_token,
  &fdup, &literal, (WordPtr)0, &int_lte, &literal, (WordPtr)14, &ifjump,
  &dict, &lookup,
  &literal, (WordPtr)9, &unlessjump,
  &rpop, &cell_size, &int_sub, &over, &over, &poke, &move, &swap, &return0,
  &literal, (WordPtr)not_found, &cputs,
  &rpop, &move, &literal, (WordPtr)0, &swap, &return0
};

DEFCOL2(swap_places, "swap-places", &quote) {
  // a b --
  &literal, (WordPtr)2, &pick, &peek,
  &literal, (WordPtr)2, &pick, &peek,
  &literal, (WordPtr)4, &pick, &poke,
  &literal, (WordPtr)2, &pick, &poke,
  &swap, &drop, &swap, &drop, &return0  
};

DEFCOL(reverse3, &swap_places) {
  // ptr length n --
  &literal, (WordPtr)3, &pick,
  &literal, (WordPtr)3, &pick,
  &literal, (WordPtr)3, &pick, &int_sub, &literal, (WordPtr)1, &int_sub, &cell_size, &int_mul, &int_add,
  &literal, (WordPtr)4, &pick,
  &literal, (WordPtr)3, &pick, &cell_size, &int_mul, &int_add, &swap_places,
  &swap, &literal, (WordPtr)1, &int_add, &swap,
  &literal, (WordPtr)1, &pick, &literal, (WordPtr)2, &int_mul,
  &literal, (WordPtr)3, &pick, &int_lt, &literal, (WordPtr)-44, &ifjump,
  &return0
};

DEFCOL(reverse, &reverse3) {
  // ptr length --
  &roll, &literal, (WordPtr)0, &reverse3,
  &drop, &drop, &drop, &return0
};

DEFCOL(nseq, &reverse) {
  // n ++ 0 1 2 ... n-1
  &literal, (WordPtr)0, &roll,
  &swap, &literal, (WordPtr)1, &int_sub, &swap,
  &over, &literal, (WordPtr)3, &ifjump, &swap, &drop, &return0,
  &literal, (WordPtr)2, &pick, &literal, (WordPtr)1, &int_add, &roll,
  &literal, (WordPtr)-22, &jumprel
};

DEFVAR2(token_buffer, "token-buffer", { .ptr = NULL }, &nseq);
DEFVAR2(token_buffer_size, "token-buffer-size", { .i = 0 }, &token_buffer);
DEFVAR(istate, { .word = &exec }, &token_buffer_size);

const FLASH char bye_str[] = "Bye";

DEFCOL2(interp_loop, "interp-loop", &istate) {
  &rpush,
  &here, &stack_prompt, &poke,
  &token_buffer, &peek, &token_buffer_size, &peek, &read_token,
  &fdup, &literal, (WordPtr)0, &int_lte, &literal, (WordPtr)18, &ifjump,
  &dict, &lookup,
  &literal, (WordPtr)6, &unlessjump,
  &istate, &peek, &exec, &literal, (WordPtr)4, &jumprel,
  &drop, &literal, (WordPtr)not_found, &cputs,
  &literal, (WordPtr)-33, &jumprel,
  &literal, (WordPtr)bye_str, &cputs,
  &rpop, &return0
};

DEFCOL2(rbracket, "]", &interp_loop) {
  &literal, &exec, &istate, &poke,
  &here, &cell_size, &int_add, &swap, &return0
};

DEFCOL2(compile, "compile", &rbracket) {
  // todo exec immediates
  &over, &literal, &rbracket, &equals, &literal, (WordPtr)1, &ifjump, &return0,
  // todo does SP need pushing?
  &rpush, &exec, &rpop, &return0
};

DEFCOL2(lbracket, "[", &compile) {
  &literal, &compile, &istate, &poke, &return0
};

DEFCOL2(stack_allot, "stack-allot", &lbracket) {
  // num-bytes -- ... pointer
  &rpush,
  &here, &swap, &uint_sub, &move, &here,
  &rpop, &return0
};

DEFCOL(interp, &stack_allot) {
  &rpush,
  &literal, (WordPtr)TOKEN_BUFFER_SIZE, &stack_allot, &token_buffer, &poke,
  &literal, (WordPtr)TOKEN_BUFFER_SIZE, &token_buffer_size, &poke,
  &literal, (WordPtr)INPUT_BUFFER_SIZE, &stack_allot, &input_buffer, &poke,
  &literal, (WordPtr)INPUT_BUFFER_SIZE, &input_buffer_max_size, &poke,
  &interp_loop,
  &literal, (WordPtr)0, &token_buffer, &poke,
  &literal, (WordPtr)0, &token_buffer_size, &poke,
  &rpop, &return0
};

DEFCOL(load, &interp) {
  // path ++
  &rpush,
  &current_input, &peek, &rpush,
  &current_input, &poke, 
  &interp_loop,
  &rpop, &current_input, &poke,
  &rpop, &return0
};

DEFCOL2(mem_used, "mem-used", &load) {
  &stack_top, &peek, &here, &ptr_sub,
  &swap, &return0
};

const FLASH char mem_info_ram_str[] = "Free RAM:\t";
const FLASH char mem_info_rstack_str[] = "Rstack:\t";
const FLASH char mem_info_stack_str[] = "Stack:\t";

DEFCOL2(mem_info, "mem-info", &mem_used) {
#ifdef AVR
  &literal, (WordPtr)mem_info_ram_str, &write_string,
  &free_ram, &write_uint, &literal, (WordPtr)crnl_str, &write_string,
#endif
  &literal, (WordPtr)mem_info_stack_str, &write_string,
  &mem_used, &write_uint, &literal, (WordPtr)crnl_str, &write_string,
  &literal, (WordPtr)mem_info_rstack_str, &write_string,
  &ram_used, &write_uint, &literal, (WordPtr)crnl_str, &write_string,
  &return0  
};

DEFCONST2(zero, "0", { .i = 0 }, &mem_info);
DEFCONST2(one, "1", { .i = 1 }, &zero);
DEFCONST2(mone, "-1", { .i = -1 }, &one);
DEFCONST2(two, "2", { .i = 2 }, &mone);
DEFCONST2(three, "3", { .i = 3 }, &two);
DEFCONST2(four, "4", { .i = 4 }, &three);
DEFCONST2(sixteen, "16", { .i = 16 }, &four);

DEFVAR2(xvar, "x", { .i = 0x12345678 }, &sixteen);

#ifdef DEBUG
const FLASH char win[] = "write-int";
#endif

DEFCOL(boot, &xvar) {
  &here, &stack_top, &poke, // todo AVR is no longer setting this since ring buffer
#ifdef DEBUG
  &cell_size, &write_int,
  &literal, (WordPtr)win, &literal, (WordPtr)9, &dict, &lookup,
  &write_int, &dict_entry_name, &peek, &cputs,
  &literal, (WordPtr)0, &literal, (WordPtr)0, &here, &literal, (WordPtr)sizeof(WordPtr), &fdup, &int_add, &read_token,
  &write_int, &cputs,
#endif
  &mem_info,
  &interp, &return0
};

#ifndef TESTING
WordPtr last_word = &boot;
#else
#include "c4-interp-tests.c"
#endif
