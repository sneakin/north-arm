typedef enum State {
  STOP,
  DROP_FRAME,
  GO,
  POP
} State;

union Cell;
struct Word;

#ifdef AVR
#define FLASH __memx
typedef const FLASH struct Word WordDef;
typedef const FLASH struct Word *WordPtr;
typedef const FLASH WordPtr WordList[];
typedef const FLASH WordPtr *WordListPtr;
#else
#define FLASH
typedef const struct Word WordDef;
typedef const struct Word *WordPtr;
typedef const WordPtr WordList[];
typedef const WordPtr *WordListPtr;
#endif

typedef WordPtr (*Fun)(union Cell **, WordListPtr *);

typedef union Cell
{
#if defined(__x86_64__) || defined(__aarch64__)
  long long i;
  unsigned long long ui;
  unsigned char bytes[sizeof(long long)];
#else
  long i;
  unsigned long ui;
  unsigned char bytes[sizeof(long)];
#endif
  const FLASH void *roptr;
  void *ptr;
  char *str;
  const FLASH char *rostr;
  union Cell *cell_ptr;
  WordPtr word;
  WordListPtr word_list;
  Fun fn;
} Cell;

typedef struct Word {
  const FLASH char *name;
  Fun code;
  Cell data;
  WordPtr next;
#ifdef AVR
  char _p1; // padding so next=NULL == NULL
#endif
} Word;

WordPtr _exec(Cell **, WordListPtr *);
WordPtr _next(Cell **, WordListPtr *);
WordPtr _doop(Cell **, WordListPtr *);
WordPtr _docol(Cell **, WordListPtr *);
WordPtr _doconst(Cell **, WordListPtr *);
WordPtr _dovar(Cell **, WordListPtr *);
WordPtr _doivar(Cell **, WordListPtr *);

extern WordPtr last_word;

#define DEFWORD2(cname, name, code, data, next) \
  const FLASH char _##cname##_name[] = name; \
  WordDef cname = { _##cname##_name, code, data, next };

#define DEFWORD(name, code, data, next) \
  DEFWORD2(name, #name, code, data, next)

#define DEFOP2(cname, name, next) \
  WordPtr _##cname(Cell **sp, WordListPtr *eip); \
  DEFWORD2(cname, name, _doop, { fn: _##cname }, next); \
  WordPtr _##cname(Cell **sp, WordListPtr *eip)

#define DEFOP(name, next) \
  DEFOP2(name, #name, next)

#define DEFCOL2(cname, name, next) \
  extern const FLASH WordList _##cname; \
  DEFWORD2(cname, name, _docol, { word_list: _##cname }, next); \
  const FLASH WordList _##cname = 

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

#define DEFCVAR2(cname, name, var, next) \
  DEFWORD2(cname, name, _doivar, { ptr: &var }, next)

#define DEFCVAR(name, var, next) \
  DEFCVAR2(name, #name, var, next)
