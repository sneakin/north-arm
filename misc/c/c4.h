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
  long i;
  void *ptr;
  char *str;
  union Cell *cell_ptr;
  struct Word *word;
  struct Word **word_list;
  Fun fn;
} Cell;

typedef struct Word {
  char *name;
  Fun code;
  void *data; // todo Cell
  struct Word *next;
} Word;

State _next(Cell **sp, Word ***eip);
State _docol(Cell **, Word ***);;
State _doconst(Cell **, Word ***);;
State _dovar(Cell **, Word ***);;

extern Word *last_word;
