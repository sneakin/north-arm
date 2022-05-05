#include "ringbuffer.h"

void ring_buffer_init(RingBuffer *rb, char *buffer, int size) {
  rb->buffer = buffer;
  rb->size = size;
  rb->rpos = rb->wpos = 0;
}

int ring_buffer_put(RingBuffer *rb, char c) {
  rb->buffer[rb->wpos] = c;
  rb->wpos = (1 + rb->wpos) % rb->size;
  return rb->wpos != rb->rpos;
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

