extern int init(int argc, char *argv[], char *env[]);
extern void *return_stack;

//int main(int argc, char *argv[], char *env[])
void _start(int argc, char *argv[], char *env[])
{
  int x = (int)return_stack;
  init(argc, argv, env);
}
