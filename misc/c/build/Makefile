all: \
	c1 c1-tail \
	c2 c2-tail \
	c3 \
	c4-words c4-scripts shared-test c4-interp c4-interp.standalone c4-interp-tests \
	c5-interp c5-interp.standalone
static: c4-interp.static c5-interp.static

../c4-words.h: ../c4.c
	sed -E -e 's:^Word (\S+).*:extern Word \1;:g' -e t -e d < $< > $@
../c5-words.h: ../c5.c
	sed -E -e 's:^DEF(OP|CONST|VAR).?\((\S+),.*:extern WordDef \2;:g' -e t -e d < $< > $@
	#sed -E -e 's:^Word ([^*]\S*).*:extern const FLASH Word \1;:g' -e t -e d < $< > $@

c1: ../c1.c
c1-tail: ../c1.c
c2: ../c2.c
c2-tail: ../c2.c
c3: ../c3.c
c4: ../c4.c
c5: ../c5.c ../c5-main.c

clean:
	rm c1 c2 c3 libc3.so shared-test
	rm c4-interp.static c4-interp.standalone c4-words c4-scripts libc4*.so
	rm c5 c5-interp c5-interp.static c5-interp.standalone libc5*.so 

%: ../%.c
	$(CC) $(CFLAGS) -o $@ $^

lib%.so: ../%.c
	$(CC) $(CFLAGS) -DSHARED -shared -fPIC -o $@ $^

%-tail: ../%.c
	$(CC) -DDO_TAILCALL -DTAILCALL_FAST $(CFLAGS) -o $@ $^

lib%-tail.so: ../%.c
	$(CC) -DDO_TAILCALL -DTAILCALL_FAST $(CFLAGS) -DSHARED -shared -fPIC -o $@ $^
	
shared-test: ../shared-test.c libc3.so
	$(CC) $(CFLAGS) -o $@ $^

c4-words: ../c4-words.h ../c4-words.c ../c4-words-def.c libc4.so libc4-main.so
	$(CC) $(CFLAGS) -DC4 -o $@ ../c4-words.c libc4.so libc4-main.so

c4-scripts: ../c4-words.h ../c4-scripts.c libc4.so
	$(CC) $(CFLAGS) -DC4 -o $@ ../c4-scripts.c libc4.so

c4-interp: ../c4-words.h ../c4-interp.c ../c4-words-def.c libc4.so libc4-main.so
	$(CC) $(CFLAGS) -DC4 -o $@ ../c4-interp.c libc4.so libc4-main.so

c4-interp-tests: ../c4-words.h ../c4-interp.c ../c4-words-def.c ../c4-interp-tests.c libc4.so libc4-main.so
	$(CC) $(CFLAGS) -DC4 -o $@ -DTESTING ../c4-interp.c libc4.so libc4-main.so

c4-interp.static: ../c4-words.h ../c4-interp.c ../c4-words-def.c ../c4.c ../c4-main.c
	$(CC) $(CFLAGS) -DC4 -DSTATIC -static -o $@ ../c4-interp.c ../c4.c ../c4-main.c

c4-interp.standalone: ../c4-words.h ../c4-interp.c ../c4-words-def.c ../c4.c ../c4-main.c
	$(CC) $(CFLAGS) -DC4 -o $@ ../c4-interp.c ../c4.c ../c4-main.c

c5-interp: ../c5-words.h ../c4-interp.c ../c4-words-def.c libc5.so libc5-main.so
	$(CC) $(CFLAGS) -DC5 -o $@ ../c4-interp.c libc5.so libc5-main.so

c5-interp.static: ../c5-words.h ../c4-interp.c ../c4-words-def.c ../c5.c ../c5-main.c
	$(CC) $(CFLAGS) -DC5 -static -o $@ ../c4-interp.c ../c5.c ../c5-main.c

c5-interp.standalone: ../c5-words.h ../c4-interp.c ../c4-words-def.c ../c5.c ../c5-main.c
	$(CC) $(CFLAGS) -DC5 -o $@ ../c4-interp.c ../c5.c ../c5-main.c

c1.avr: ../avr.h ../unix_io.h ../c1.c ../ringbuffer.c ../ringbuffer.h
	$(AVR_CC) $(CFLAGS) -DC5 -DAVR -DNOUNIX -mmcu=$(AVR_MCU) -static -o $@ ../c1.c -DAVR_UART_INTR ../ringbuffer.c

AVR_CC?=avr-gcc
AVR_MCU?=atmega328p
AVRDUDE_MCU?=m328p
AVR_PORT?=/dev/ttyUSB1
AVR_BAUD?=19200
AVR_FLAGS?=-Os -DNOLOG

c5-interp.avr: ../c5-words.h ../c4-interp.c ../c4-words-def.c ../avr.h ../unix_io.h ../c5.c ../c5-main.c ../ringbuffer.c ../ringbuffer.h
	$(AVR_CC) $(CFLAGS) $(AVR_FLAGS) -DC5 -DAVR -DNOUNIX -mmcu=$(AVR_MCU) -static -o $@ ../c4-interp.c ../c5.c ../c5-main.c -DAVR_UART_INTR ../ringbuffer.c
c5-interp.hex: c5-interp.avr
	avr-objcopy -Oihex $< $@

flash-c5: c5-interp.hex
	avrdude -c arduino -p $(AVRDUDE_MCU) -b $(AVR_BAUD) -U flash:w:$<:i -P $(AVR_PORT)