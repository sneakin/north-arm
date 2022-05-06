#include "ringbuffer.h"

void ring_buffer_init(RingBuffer *rb, char *buffer, int size) {
  rb->buffer = buffer;
  rb->size = size;
  rb->rpos = rb->wpos = 0;
}

int ring_buffer_put(RingBuffer *rb, char c) {
  int n = (1 + rb->wpos) % rb->size;
  if(n == rb->rpos) return 0;
  rb->buffer[rb->wpos] = c;
  rb->wpos = n;
  return n != rb->rpos;
}

int ring_buffer_get(RingBuffer *rb) {
  if(rb->rpos == rb->wpos) {
    return -1;
  } else {
    int c = rb->buffer[rb->rpos];
    rb->rpos = (1 + rb->rpos) % rb->size;
    return c;
  }
}

#ifdef TESTING
#include <stdio.h>

int main() {
  RING_BUFFER(rb, 16);
  int i, c;
  for(i = 0; i < 4; i++) {
    ring_buffer_put(&rb, i);
  }
  for(i = 0; i < 6; i++) {
    c = ring_buffer_get(&rb);
    printf("%i: %i\n", i, c);
  }
  for(i = 0; i < 20; i++) {
    if(ring_buffer_put(&rb, i) == 0) {
      printf("Filled: %i\n", rb.wpos);
      break;
    }
    printf("%i %i\n", rb.wpos, rb.rpos);
  }
  for(i = 0; i < 20; i++) {
    c = ring_buffer_get(&rb);
    printf("%i: %i\n", i, c);
  }
  if(ring_buffer_put(&rb, 17) == 0) {
    puts("Full");
  }
  return 0;
}
#endif