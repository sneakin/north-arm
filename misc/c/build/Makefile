all: c1 c2 c3 c4-words c4-scripts shared-test c4-interp c4-interp.static c4-interp-tests

../c4-words.h: ../c4.c
	sed -E -e 's:^Word (\S+).*:extern Word \1;:g' -e t -e d < $< > $@

c1: ../c1.c
c2: ../c2.c
c3: ../c3.c
c4: ../c4.c

clean:
	rm c1 c2 c3 libc3.so shared-test
	rm c4-words c4-scripts libc4*.so

%: ../%.c
	$(CC) $(CFLAGS) -o $@ $^

lib%.so: ../%.c
	$(CC) $(CFLAGS) -DSHARED -shared -fPIC -o $@ $^
	
shared-test: ../shared-test.c libc3.so
	$(CC) $(CFLAGS) -o $@ $^

c4-words: ../c4-words.h ../c4-words.c ../c4-words-def.c libc4.so libc4-main.so
	$(CC) $(CFLAGS) -o $@ ../c4-words.c libc4.so libc4-main.so

c4-scripts: ../c4-words.h ../c4-scripts.c libc4.so
	$(CC) $(CFLAGS) -o $@ ../c4-scripts.c libc4.so

c4-interp: ../c4-words.h ../c4-interp.c ../c4-words-def.c libc4.so libc4-main.so
	$(CC) $(CFLAGS) -o $@ ../c4-interp.c libc4.so libc4-main.so

c4-interp-tests: ../c4-words.h ../c4-interp.c ../c4-words-def.c ../c4-interp-tests.c libc4.so libc4-main.so
	$(CC) $(CFLAGS) -o $@ -DTESTING ../c4-interp.c libc4.so libc4-main.so

c4-interp.static: ../c4-words.h ../c4-interp.c ../c4-words-def.c ../c4.c ../c4-main.c
	$(CC) $(CFLAGS) -o $@ ../c4-interp.c ../c4.c ../c4-main.c
