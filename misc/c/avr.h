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
#include <avr/cpufunc.h>
#include <avr/wdt.h>
#include <util/delay.h>
#include <util/setbaud.h>

#include "ringbuffer.h"

typedef int off_t;

int xputchar(char c, FILE *f)
{
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
  return 0;
}

#ifdef AVR_UART_INTR
#include <avr/interrupt.h>

#define UART_BUFFER_SIZE 32
RING_BUFFER(uart_rx_buffer, UART_BUFFER_SIZE);

void xoff() {
  xputchar(19, stdout);
}

void xon() {
  xputchar(17, stdout);
}

int uart_rx_full() {
  return abs(uart_rx_buffer.rpos - uart_rx_buffer.wpos) > UART_BUFFER_SIZE/2;
}

#ifdef USART_RX_vect
ISR(USART_RX_vect)
#else
ISR(USART1_RX_vect)
#endif
 {
  if(ring_buffer_put(&uart_rx_buffer, UDR0) == 0 ||
     uart_rx_full()) {
    xoff();
  }
}

int uart_rb_getchar(FILE *f) {
  int c;
  if((c = ring_buffer_get(&uart_rx_buffer)) < 0) {
    xon();
    while((c = ring_buffer_get(&uart_rx_buffer)) < 0) {
      _NOP();
    }
  }
  return c;
}

static FILE serial_in = FDEV_SETUP_STREAM(NULL, uart_rb_getchar, _FDEV_SETUP_READ);
#else

int xgetchar(FILE *f)
{
  loop_until_bit_is_set(UCSR0A, RXC0);
  char c = UDR0;
  return c;
}

static FILE serial_in = FDEV_SETUP_STREAM(NULL, xgetchar, _FDEV_SETUP_READ);
#endif

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

void avr_reboot() {
  puts("Rebooting");
#if USE_AVR_WDT
  wdt_enable(WDTO_250MS);
  while(1) {
    putc('.', stdout);
    _delay_ms(500);
  }
#else
  void (*reboot)() = 0x0;
  _delay_ms(100);
  reboot();
#endif
}

#ifdef USE_AVR_WDT
// disable lingering watch dogs before main()
__attribute__((used, unused, naked, section(".init3")))
void wdt_init(void);

void wdt_init(void) {
  MCUSR &= ~(1<<WDRF);
  wdt_disable();
}
#endif // USE_AVR_WDT

void avr_init() {
  // initialize the UART  
  UBRR0H = UBRRH_VALUE;
  UBRR0L = UBRRL_VALUE;
  
#if USE_2X
  UCSR0A |= _BV(U2X0);
#else
  UCSR0A &= ~(_BV(U2X0));
#endif
  UCSR0C = _BV(UCSZ01) | _BV(UCSZ00); /* 8-bit data */
  UCSR0B = _BV(RXEN0) | _BV(TXEN0);   /* Enable RX and TX */
#ifdef AVR_UART_INTR
  UCSR0B |= (1<<RXCIE0);
#endif

  // initialize the IO streams
  stdout = stderr = &serial_out;
#ifdef STATIC_INPUT
  static_input_pos = 0;
  stdin = &static_in;
  puts("Static input");
#else    
  stdin = &serial_in;
#endif

#ifdef AVR_UART_INTR
  sei();
#endif

#ifdef DEBUG
  puts("AVR initialized");
#endif
}
