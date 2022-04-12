typedef enum State {
  STOP,
  DROP_FRAME,
  GO,
  POP
} State;

union Cell;
struct Word;
typedef struct Word *(*Fun)(union Cell **, struct Word ***);

typedef union Cell
{
  void *ptr;
  long i;
  char *str;
  union Cell *cell_ptr;
  struct Word *word;
  struct Word **word_list;
  Fun fn;
} Cell;

typedef struct Word {
  char *name;
  Fun code;
  Cell data;
  struct Word *next;
} Word;

Word *_exec(Cell **sp, Word ***eip);
Word *_next(Cell **sp, Word ***eip);
Word *_doop(Cell **, Word ***);;
Word *_docol(Cell **, Word ***);;
Word *_doconst(Cell **, Word ***);;
Word *_dovar(Cell **, Word ***);;

extern Word *last_word;
