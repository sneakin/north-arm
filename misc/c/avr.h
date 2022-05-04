#ifndef F_CPU
#define F_CPU 16000000UL
#endif

#ifndef BAUD
#define BAUD 19200
#endif

#include <stdio.h>
#include <avr/io.h>
#include <alloca.h>
#include <avr/pgmspace.h>
#include <util/setbaud.h>

typedef int off_t;

int xputchar(char c, FILE *f)
{
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
  return 0;
}

int xgetchar(FILE *f)
{
  loop_until_bit_is_set(UCSR0A, RXC0);
  char c = UDR0;
  return c;
}

static FILE serial_in = FDEV_SETUP_STREAM(NULL, xgetchar, _FDEV_SETUP_READ);
static FILE serial_out = FDEV_SETUP_STREAM(xputchar, NULL, _FDEV_SETUP_WRITE);

#ifdef STATIC_INPUT
extern const char static_input_buffer[];
extern size_t static_input_length;
size_t static_input_pos = 0;

int static_getchar(FILE *f) {
  fprintf(stderr, "Static read: %i %i\n", static_input_pos, static_input_buffer[static_input_pos]);
  if(static_input_pos < static_input_length) {
    return static_input_buffer[static_input_pos++];
  } else {
    return -1;
  }
}

static FILE static_in = FDEV_SETUP_STREAM(NULL, static_getchar, _FDEV_SETUP_READ);
#endif

void avr_init() {
  UBRR0H = UBRRH_VALUE;
  UBRR0L = UBRRL_VALUE;
  
#if USE_2X
  UCSR0A |= _BV(U2X0);
#else
  UCSR0A &= ~(_BV(U2X0));
#endif
  UCSR0C = _BV(UCSZ01) | _BV(UCSZ00); /* 8-bit data */
  UCSR0B = _BV(RXEN0) | _BV(TXEN0);   /* Enable RX and TX */

  stdout = stderr = &serial_out;
#ifdef STATIC_INPUT
  static_input_pos = 0;
  stdin = &static_in;
  puts("Static input");
#else    
  stdin = &serial_in;
#endif
  puts("AVR initialized");
}
