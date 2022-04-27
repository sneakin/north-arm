typedef enum State {
  STOP,
  DROP_FRAME,
  GO,
  POP
} State;

union Cell;
struct Word;
typedef State (*Fun)(union Cell **, struct Word ***);

typedef union Cell
{
  void *ptr;
  long i;
  unsigned long ui;
  char *str;
  union Cell *cell_ptr;
  struct Word *word;
  struct Word **word_list;
  Fun fn;
} Cell;

typedef struct Word {
  const char *name;
  Fun code;
  Cell data;
  struct Word *next;
} Word;

State _exec(Cell **sp, Word ***eip);
State _next(Cell **sp, Word ***eip);
State _doop(Cell **, Word ***);;
State _docol(Cell **, Word ***);;
State _doconst(Cell **, Word ***);;
State _dovar(Cell **, Word ***);;
State _doivar(Cell **, Word ***);;

extern Word *last_word;

#define FLASH
typedef Word *WordPtr;
typedef WordPtr WordList[];
typedef WordPtr *WordListPtr;

#define DEFWORD2(cname, name, code, data, next) \
  const char _##cname##_name[] = name; \
  Word cname = { _##cname##_name, code, data, next };

#define DEFWORD(name, code, data, next) \
  DEFWORD2(name, #name, code, data, next)

#define DEFOP2(cname, name, next) \
  WordPtr _##cname(Cell **sp, WordListPtr *eip); \
  DEFWORD2(cname, name, _doop, { fn: _##cname }, next); \
  WordPtr _##cname(Cell **sp, WordListPtr *eip)

#define DEFOP(name, next) \
  DEFOP2(name, #name, next)

#define DEFCOL2(cname, name, next) \
  extern WordList _##cname; \
  DEFWORD2(cname, name, _docol, _##cname, next); \
  WordList _##cname = 

#define DEFCOL(name, next) \
  DEFCOL2(name, #name, next)

#define DEFCONST2(cname, name, value, next) \
  DEFWORD2(cname, name, _doconst, value, next)

#define DEFCONST(name, value, next) \
  DEFCONST2(name, #name, value, next)

#define DEFVAR2(cname, name, value, next) \
  Cell _##cname = value; \
  DEFWORD2(cname, name, _doivar, { ptr: &_##cname }, next)

#define DEFVAR(name, value, next) \
  DEFVAR2(name, #name, value, next)
