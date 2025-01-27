/* c4 but using return values and eip to control next's loop.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#ifdef AVR
#include "avr.h"
#endif

#include "unix_io.h"
#include "c5.h"

#define DBG_ALL -1
#define DBG_ERROR 0x11
#define DBG_WARN 0x22
#define DBG_INFO 0x43
#define DBG_CALLS 0x84
#define DBG_TRACE 0x105
#define DBG_COPYING 0x206
#define DBG_INFO2 0x806
#define DBG_IO 0x406

#ifndef PSTR
#define PSTR(str) str
#define fprintf_P fprintf
#endif

#ifdef NOLOG
#define DBGOUT(level, fmt, ...) {}
#else

#ifdef DEBUG_CALLS
unsigned long _debug_level = DBG_TRACE|DBG_CALLS|DBG_IO|DBG_INFO;
#else // DEBUG_CALLS
#  ifdef DEBUG
unsigned long _debug_level = DBG_ERROR|DBG_WARN|DBG_IO;
#  else // DEBUG
unsigned long _debug_level = DBG_ERROR|DBG_WARN;
#  endif // DEBUG
#endif // DEBUG_CALLS

int is_debug_level(unsigned long level) {
  return _debug_level & (level&~0xF);
}

#define DBGOUT(level, fmt, ...) \
  if(is_debug_level(level)) \
  { fprintf_P(stderr, PSTR("\e[3%im"), level & 0x7); \
    fprintf_P(stderr, PSTR(fmt), __VA_ARGS__); \
    fprintf_P(stderr, PSTR("\e[0m\r\n")); \
  }
#endif // NOLOG

#define OUTPUT_BUFFER_SIZE 32
char output_buffer[OUTPUT_BUFFER_SIZE];

WordPtr next_op(WordListPtr *eip) {
  WordPtr cur = **eip;
  (*eip)++;
  return cur;
}

WordPtr _doconst(Cell **sp, WordListPtr *eip) {
  *(*sp) = (*sp)->word->data;
  return next_op(eip);
}

DEFCONST(doconst, { .fn = _doconst }, 0);

WordPtr _doop(Cell **sp, WordListPtr *eip) {
  WordPtr w = (*sp)->word;
  Fun f = w->data.fn;
  (*sp) += 1;
  return f(sp, eip);
}

DEFCONST(doop, { .fn = _doop }, &doconst);

DEFOP(exec, &doop) {
  WordPtr w = (*sp)->word;
  return w->code.fn(sp, eip);
}

size_t strncpy_M(char *out, const FLASH char *in, size_t count) {
  size_t i;
  DBGOUT(DBG_COPYING, "strncpy: %i bytes from %p to %p", count, (void*)in, (void*)out);
  for(i = 0; i < count && in[i] != 0; i++) {
    DBGOUT(DBG_INFO2, " %i", in[i]);
    out[i] = in[i];
  }
  out[i] = 0;
  DBGOUT(DBG_COPYING, "copied %i bytes: %s", i, out);
  return i;
}

size_t memcpy_M(void *outa, const FLASH void *ina, size_t count) {
  char *out = (char *)outa;
  const FLASH char *in = (const FLASH char *)ina;
  size_t i;
  unsigned long outp = (unsigned long)out, inp = (unsigned long)in;
  DBGOUT(DBG_COPYING, "memcpy: %i bytes from %lx to %lx", count, inp, outp);
  for(i = 0; i < count; i++) {
    DBGOUT(DBG_INFO2, " %x", in[i]);
    out[i] = in[i];
  }
  return i;
}

DEFOP(next, &exec) {
  WordPtr w = **eip;
  char *n = output_buffer;
  size_t i = 0;
  DBGOUT(DBG_TRACE, "next %p\t%p\t%lx", *eip, *sp, **sp);
  *eip += 1;
  while(w != NULL && *eip != NULL) {
#ifndef NOLOG
    if(is_debug_level(DBG_TRACE)) {
      i = strncpy_M(output_buffer, w->name.rostr, OUTPUT_BUFFER_SIZE);
      DBGOUT(DBG_TRACE, "-> %p\t%p\t%i %p \"%s\"", (void*)*eip, (void*)w, i, (void*)output_buffer, output_buffer);
      DBGOUT(DBG_TRACE, "   %p\t%lx\t%li", (void*)*sp, (unsigned long)(*sp)->ui, (long)(*sp)->i);
    }
#endif
    *sp -= 1;
    (*sp)->word = w;
    w = w->code.fn(sp, eip);
  }

  DBGOUT(DBG_TRACE, "-! %p\t%p\t%p\t%lx\t%li", (void *)w, (void *)*eip, (void *)*sp, (unsigned long)(*sp)->ui, (long)(*sp)->i);
  return NULL;
}

DEFOP(cputs, &next) {
#ifdef AVR
  int n = strncpy_M(output_buffer, (*sp)->rostr, OUTPUT_BUFFER_SIZE);
  fwrite(output_buffer, sizeof(char), n, stdout);
#else
  const char *str = (*sp)->rostr;
  fwrite(str, sizeof(char), strlen(str), stdout);
#endif
  fwrite("\r\n", sizeof(char), 2, stdout);
  (*sp)++;
  return next_op(eip);
}

DEFOP2(write_string, "write-string", &cputs) {
#ifdef AVR
  size_t i = strncpy_M(output_buffer, (*sp)->rostr, OUTPUT_BUFFER_SIZE-1);
  fwrite(output_buffer, i, 1, stdout);
#else
  const char *str = (*sp)->rostr;
  fwrite(str, strlen(str), 1, stdout);
#endif
  (*sp)++;
  return next_op(eip);
}

FILE ** const std_streams[] = {
  &stdin, &stdout, &stderr
};

DEFOP(flush, &write_string) {
  int fd = (*sp)->i;
  if(fd < 3) {
    FILE *io = *std_streams[fd];
    fflush(io);
  }
  (*sp)++;
  return next_op(eip);
}

DEFOP(cexit, &flush) {
  exit((*sp)->i);
  return next_op(eip);
}

DEFOP(literal, &cexit) {
  *sp -= 1;
  (*sp)->i = (long)**eip; // does limit values to sizeof(WordPtr)
  DBGOUT(DBG_INFO, "literal %p\t%p\t%lx", (void*)**eip, (*sp)->roptr, (*sp)->ui);
  *eip += 1;
  return next_op(eip);
}

DEFOP(return0, &literal) {
  DBGOUT(DBG_CALLS, "returning stack to %p", (*sp)->ptr);
  //*eip = (*sp)->word_list;
  *sp += 1;
  //*sp = (*sp)->cell_ptr;
  *eip = NULL;
  return &return0;
}

DEFOP(rallot, &return0) {
  Cell *mem = alloca((*sp)->i);
  (*sp)->roptr = mem;
  WordPtr w = _next(sp, eip);
  if(*eip) return next_op(eip);
  else return NULL;
}

DEFOP(here, &rallot) {
  ((*sp)-1)->roptr = *sp;
  *sp -= 1;
  return next_op(eip);
}

DEFOP(rhere, &here) {
  int n = 0;
  (--(*sp))->roptr = (void *)&n;
  return next_op(eip);
}

DEFOP2(int_sub, "int-sub", &rhere) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b - a);
  return next_op(eip);
}

DEFOP2(uint_sub, "uint-sub", &int_sub) {
  unsigned long a = (*sp)->ui;
  *sp += 1;
  unsigned long b = (*sp)->ui;
  (*sp)->ui = (b - a);
  return next_op(eip);
}

DEFOP2(ptr_add, "ptr-add", &uint_sub) {
  long a = (*sp)->i;
  *sp += 1;
  void *b = (*sp)->ptr;
  (*sp)->ptr = (b + a);
  return next_op(eip);
}

DEFOP2(ptr_sub, "ptr-sub", &ptr_add) {
  void *a = (*sp)->ptr;
  *sp += 1;
  void *b = (*sp)->ptr;
  (*sp)->i = (b - a);
  return next_op(eip);
}

DEFOP2(write_int, "write-int", &ptr_sub) {
  printf("%li ", (*sp)->i);
  fflush(stdout);
  *sp += 1;
  return next_op(eip);
}

DEFOP2(write_uint, "write-uint", &write_int) {
  printf("%lu ", (*sp)->ui);
  fflush(stdout);
  *sp += 1;
  return next_op(eip);
}

DEFOP(swap, &write_uint) {
  Cell t = **sp;
  **sp = *((*sp)+1);
  *((*sp)+1) = t;
  return next_op(eip);
}

DEFOP2(fdup, "dup", &swap) {
  Cell v = **sp;
  *sp -= 1;
  **sp = v;
  return next_op(eip);
}

WordPtr _docol(Cell **sp, WordListPtr *eip) {
  WordPtr w = (*sp)->word;
#ifdef AVR
  char *n = output_buffer;
#ifndef NOLOG
  if(is_debug_level(DBG_CALLS)) {
    strncpy_M(n, w->name.rostr, OUTPUT_BUFFER_SIZE);
  }
#endif // NOLOG
#else // AVR
  const FLASH char *n = w->name.rostr;
#endif // AVR
  DBGOUT(DBG_CALLS, "docol %p \"%s\" (%S) from %p", (void*)w, n, w->name.rostr, *eip);
  //(*sp)->word_list = *eip;
  //*sp += 1;
  // todo need to push nothing to sp, needs every word updated
  Cell *fp = (*sp)->cell_ptr = (*sp)+1;
  WordListPtr neip = w->data.word_list;
  WordPtr r = _next(sp, &neip);
#ifndef NOLOG
  if(neip != NULL) DBGOUT(DBG_WARN, "eip is not null\t%p", neip);
  DBGOUT(DBG_INFO, "<= %S returned: %p", w->name.rostr, r);
#endif
  if(r == &return0) { *sp = fp; return next_op(eip); }
  if(r == NULL) return next_op(eip);
  else return r;
}

DEFCONST(docol, { .fn = _docol }, &fdup);

#ifndef NEEDED_ONLY
DEFOP(eip, &docol) {
  *sp -= 1;
  (*sp)->word_list = *eip;
  return next_op(eip);
}

DEFOP2(abort_next, "abort-next", &eip) {
  *eip = NULL;
  return NULL;
}

DEFOP2(write_hex_int, "write-hex-int", &abort_next)
#else // NEEDED_ONLY
DEFOP2(write_hex_int, "write-hex-int", &docol)
#endif // NEEDED_ONLY
{
  printf("%lx ", (*sp)->ui);
  fflush(stdout);
  *sp += 1;
  return next_op(eip);
}

DEFOP2(int_add, "int-add", &write_hex_int) {
  long a = (*sp)->ui;
  *sp += 1;
  long b = (*sp)->ui;
  (*sp)->i = (b + a);
  return next_op(eip);
}

DEFOP2(int_mul, "int-mul", &int_add) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b * a);
  return next_op(eip);
}

DEFOP2(int_div, "int-div", &int_mul) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b / a);
  return next_op(eip);
}

DEFOP2(int_mod, "int-mod", &int_div) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (b % a);
  return next_op(eip);
}

DEFOP(bsl, &int_mod) {
  Cell c = *((*sp)++);
  (*sp)->ui <<= c.ui;
  return next_op(eip);
}

DEFOP(bsr, &bsl) {
  Cell c = *((*sp)++);
  (*sp)->ui >>= c.ui;
  return next_op(eip);
}

DEFOP2(int_lte, "int<=", &bsr) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (long)(b <= a);
  return next_op(eip);
}

DEFOP2(int_lt, "int<", &int_lte) {
  long a = (*sp)->i;
  *sp += 1;
  long b = (*sp)->i;
  (*sp)->i = (long)(b < a);
  return next_op(eip);
}

DEFOP2(equals, "equals?", &int_lt) {
  Cell a = *(*sp);
  *sp += 1;
  Cell b = *(*sp);
  (*sp)->i = (b.ui == a.ui);
  return next_op(eip);
}

DEFOP(peek, &equals) {
#ifdef AVR
  memcpy_M(*sp, (*sp)->roptr, sizeof(Cell));
#else
  (*sp)->ui = (*sp)->cell_ptr->ui;
#endif
  return next_op(eip);
}

DEFOP(poke, &peek) {
  ((*sp)->cell_ptr)->ui = (*sp+1)->ui;
  *sp += 2;
  return next_op(eip);
}

DEFOP2(peek_byte, "peek-byte", &poke) {
  (*sp)->i = (*sp)->rostr[0];
  return next_op(eip);
}

DEFOP2(poke_byte, "poke-byte", &peek_byte) {
  (*sp)->str[0] = (*sp+1)->i;
  *sp += 2;
  return next_op(eip);
}

DEFOP(ifjump, &poke_byte) {
  off_t n = (*sp)->i;
  *sp += 1;
  if((*sp)->i != 0) {
    *eip += n;
  }
  *sp += 1;
  return next_op(eip);
}

DEFOP(unlessjump, &ifjump) {
  off_t n = (*sp)->i;
  *sp += 1;
  if((*sp)->i == 0) { // fixme 0xf0000000 is returned by byte-string-equals
    *eip += n;
  }
  *sp += 1;
  return next_op(eip);
}

DEFOP(drop, &unlessjump) {
  *sp += 1;
  return next_op(eip);
}

DEFOP(fexit, &drop) {
  // *eip = (*sp)->word_list;
  // *sp += 1;
  // return _next(sp, eip);
  DBGOUT(DBG_CALLS, "exiting %p", (*sp)->ptr);
  *eip = NULL;
  return NULL;
}

DEFOP(over, &fexit) {
  *sp -= 1;
  **sp = *(*sp+2);
  return next_op(eip);
}

DEFOP(rpush, &over) {
  Cell v = **sp;
  *sp += 1;
  DBGOUT(DBG_INFO, "rpush %p", v);
  WordPtr w = _next(sp, eip);
  if(*eip) {
    DBGOUT(DBG_INFO, "rpopping %p", v);
    *sp -= 1;
    **sp = v;
    return next_op(eip);
  } else return NULL;
}

DEFOP(rpop, &rpush) {
  DBGOUT(DBG_INFO, "rpop %p", *sp);
  return NULL;
}

DEFOP(cread, &rpop) {
  int fd;
  char *data;
  size_t len;
  fd = (*sp)->i;
  *sp += 1;
  data = (*sp)->str;
  *sp += 1;
  len = (*sp)->ui;
  DBGOUT(DBG_IO, "read %i, %p, %i", fd, data, len);
  (*sp)->i = read(fd, data, len);
  DBGOUT(DBG_IO, "read => %i\t%lx\t%lx", (*sp)->i, data[0], *(unsigned long *)data);
  return next_op(eip);
}

DEFOP(cwrite, &cread) {
  int fd;
  char *data;
  size_t len;
  fd = (*sp)->i;
  *sp += 1;
  data = (*sp)->str;
  *sp += 1;
  len = (*sp)->ui;
  //DBGOUT(DBG_INFO, "write %i, %p, %i", fd, data, len);
  (*sp)->i = write(fd, data, len);
  //DBGOUT(DBG_INFO, "write => %i", (*sp)->i);
  return next_op(eip);
}

DEFOP(jumprel, &cwrite) {
  *eip += (*sp)->i;
  *sp += 1;
  return next_op(eip);
}

DEFOP(roll, &jumprel) {
  Cell t = **sp;
  **sp = *(*sp+1);
  *(*sp+1) = *(*sp+2);
  *(*sp+2) = t;
  return next_op(eip);
}

DEFOP(shift, &roll) {
  // a b c -- b c a
  Cell t = **sp;
  **sp = *(*sp+2);
  *(*sp+2) = *(*sp+1);
  *(*sp+1) = t;
  return next_op(eip);
}

DEFOP(rot, &shift) {
  // a b c -- c b a
  Cell t = **sp;
  **sp = *(*sp+2);
  *(*sp+2) = t;
  return next_op(eip);
}

WordPtr _dovar(Cell **sp, WordListPtr *eip) {
  (*sp)->roptr = &(*sp)->word->data;
  return next_op(eip);
}

DEFCONST(dovar, { .fn = _dovar }, &rot);

WordPtr _doivar(Cell **sp, WordListPtr *eip) {
  //*(*sp) = (*sp)->word->data;
  (*sp)->ptr = (*sp)->word->data.ptr;
#ifdef AVR
  (*sp)->bytes[2] = 0x80; // force the pointer to RAM
#endif
  return next_op(eip);
}

DEFCONST(doivar, { .fn = _doivar }, &dovar);

DEFOP2(free_ram, "free-ram", &doivar) {
#ifdef AVR
  extern int __heap_start, *__brkval;
  int v;
  (*sp) -= 1;
  (*sp)->i = (int)&v - (__brkval == 0 ? (int)&__heap_start : (int)__brkval);
#else
  *sp -= 1;
  (*sp)->i = -1;
#endif
  return next_op(eip);
}

DEFOP2(ram_used, "ram-used", &free_ram) {
  int x;
  static void *init_brk = NULL;
  if(init_brk == NULL) init_brk = &x;
  *sp -= 1;
  (*sp)->ui = init_brk - (void *)&x;
  return next_op(eip);
}

#ifdef AVR
DEFOP(reboot, &ram_used) {
  avr_reboot();
}

DEFOP(move, &reboot)
#else // AVR
DEFOP(move, &ram_used)
#endif // AVR
{
  *sp = (*sp)->cell_ptr;
  return next_op(eip);
}

#ifndef NOLOG
DEFCVAR2(debug_level, "*debug-level*", _debug_level, &move);
#endif

#ifndef NEEDED_ONLY
extern WordPtr last_word;

#ifdef NOLOG
DEFOP2(set_dict, "set-dict", &move)
#else
DEFOP2(set_dict, "set-dict", &debug_level)
#endif
{
  last_word = (*sp)->word;
  *sp += 1;
  return next_op(eip);
}

DEFOP(dict, &set_dict)
#else // NEEDED_ONLY
#ifdef NOLOG
DEFOP(dict, &move)
#else
DEFOP(dict, &debug_level)
#endif
#endif // NEEDED_ONLY
{
  *sp -= 1;
  Cell *here = *sp;
  here->ui = 0;
  here->word = last_word;
  return next_op(eip);
}
