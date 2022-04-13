#ifndef F_CPU
#define F_CPU 160000000UL
#endif

#ifndef BAUD
#define BAUD 9600
#endif

#include <avr/io.h>
#include <util/setbaud.h>

typedef int off_t;

void *alloca(int size)
{
  return NULL;
}

int xgetchar(FILE *f)
{
  loop_until_bit_is_set(UCSR0A, RXC0);
  return UDR0;
}

int xputchar(char c, FILE *f)
{
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
  return 0;
}

static FILE serial_in = FDEV_SETUP_STREAM(NULL, xgetchar, _FDEV_SETUP_WRITE);
static FILE serial_out = FDEV_SETUP_STREAM(xputchar, NULL, _FDEV_SETUP_WRITE);

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
    
  stdin = &serial_in;
  stdout = stderr = &serial_out;
  puts("AVR initialized");
}
