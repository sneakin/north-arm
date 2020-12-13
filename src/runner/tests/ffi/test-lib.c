#define try(fn, args...) if(fn != 0) fn(args)

typedef void (*nputs_fn)(const char *);
static nputs_fn _nputs = 0;
void nputs(const char *s)
{
  try(_nputs, s);
}

static int n_args = 0;
static int arg_0 = 0;

int get_n_args() { return n_args; }
int get_arg_0() { return arg_0; }

void reset_vars() {
  n_args = -1;
  arg_0 = -1;
}

void init_lib(nputs_fn p)
{
  _nputs = p;
  reset_vars();
}

void ffi_test_0_0()
{
  nputs("FFI test 0 0");
  n_args = 0;
  arg_0 = 0;
}

int ffi_test_0_1()
{
  nputs("FFI test 0 1");
  n_args = 0;
  arg_0 = 0;
  return 123;
}

void ffi_test_1_0(int x)
{
  n_args = 1;
  arg_0 = x;
}

int ffi_test_1_1(int x)
{
  n_args = 1;
  arg_0 = x;
  return x * x;
}

void ffi_cb_0_0(void (*cb)())
{
  int x = -3;
  cb();
  n_args = x*x;
}

static void (*nullf)() = 0;

void ffi_cb_0_1(int (*cb)())
{
  arg_0 = cb();
  n_args = 0;
  //nullf();
}

void ffi_cb_1_0(void (*cb)(int))
{
  cb(0x234);
  arg_0 = -1;
  n_args = 1;
}

void ffi_cb_2_0(void (*cb)(int,int))
{
  cb(0x234, 0x789);
  arg_0 = -2;
  n_args = 2;
}

void ffi_cb_1_1(int (*cb)(int))
{
  arg_0 = cb(0x234);
  n_args = 1;
  nputs("cb-1-1 done");
}

void ffi_cb_2_1_1(int x, int (*cb)(int))
{
  arg_0 = cb(x);
  n_args = 2;
}
