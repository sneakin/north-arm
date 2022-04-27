#ifndef NOUNIX
#include <unistd.h>
#else

int read(int fd, void *data, size_t length)
{
  unsigned char *bytes = (unsigned char *)data;
  size_t i = 0;
  int c = 0;
  while(i < length && c != '\n') {
    c = getchar();
    if(c < 0) {
      if(i == 0) return c;
      break;
    }
    bytes[i] = c;
    i++;
  }
  return i;
}

int write(int fd, void *data, size_t length)
{
  unsigned char *bytes = (unsigned char *)data;
  size_t i = 0;
  while(i < length) {
    if(putchar(bytes[i]) < 0) break;
    i++;
  }
  return i;
}
#endif
