( See https://wiki.osdev.org/Raspberry_Pi_Bare_Bones )

0x20000000 const> MMIO-BASE-0
0x3F000000 const> MMIO-BASE-2
0xFE000000 const> MMIO-BASE-4

: GPIO-BASE 0x200000 + ;
 
( Controls actuation of pull up/down to ALL GPIO pins. )
: GPPUD ( gpio-base -- addr ) 0x94 + ;
 
( Controls actuation of pull up/down for specific GPIO pin. )
: GPPUDCLK0 ( gpio-base -- addr ) 0x98 + ;
 
( The base address for UART. )
: UART0-BASE ( gpio-base -- addr ) 0x1000 + ;
( for raspi4 0xFE201000, raspi2 & 3 0x3F201000, and 0x20201000 for raspi1 )

( The offsets for reach register for the UART. )
: UART-DR 0x00 + ;
: UART-RSRECR 0x04 + ;
: UART-FR 0x18 + ;
: UART-ILPR 0x20 + ;
: UART-IBRD 0x24 + ;
: UART-FBRD 0x28 + ;
: UART-LCRH 0x2C + ;
: UART-CR 0x30 + ;
: UART-IFLS 0x34 + ;
: UART-IMSC 0x38 + ;
: UART-RIS 0x3C + ;
: UART-MIS 0x40 + ;
: UART-ICR 0x44 + ;
: UART-DMACR 0x48 + ;
: UART-ITCR 0x80 + ;
: UART-ITIP 0x84 + ;
: UART-ITOP 0x88 + ;
: UART-TDR 0x8C + ;
 
( The offsets for Mailbox registers )
: MBOX-BASE ( MMIO-BASE -- addr ) 0xB880 + ;
: MBOX-READ 0x00 + ;
: MBOX-STATUS 0x18 + ;
: MBOX-WRITE 0x2 + ;

: mmio-read peek ;
: mmio-write poke ;

: mmio-wait ( addr mask -- )
  over mmio-read over logand
  IF 2 dropn
  ELSE loop
  THEN
;

( Wait for UART to become ready to transmit. )
: uart-putc ( c uart-base -- )
  dup UART-FR 0x20 mmio-wait
  UART-DR mmio-write
;

: uart-getc ( uart-base -- c )
  dup UART-FR 0x10 mmio-wait
  UART-DR mmio-read
;

: uart0 MMIO-BASE-2 GPIO-BASE UART0-BASE ;
