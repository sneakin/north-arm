#ifndef RINGBUFFER_H
#define RINGBUFFER_H

typedef struct {
  char *buffer;
  int size;
  int rpos, wpos;
} RingBuffer;

#define RING_BUFFER(name, size) \
  char _##name##_buffer[size]; \
  RingBuffer name = { _##name##_buffer, size, 0, 0 }

void ring_buffer_init(RingBuffer *rb, char *buffer, int size);
int ring_buffer_put(RingBuffer *rb, char c);
int ring_buffer_get(RingBuffer *rb);

#endif