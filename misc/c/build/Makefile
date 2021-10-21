all: c1 c2 c3 shared-test

c1: ../c1.c
c2: ../c2.c
c3: ../c3.c

clean:
	rm c1 c2 c3 libc3.so shared-test

%: ../%.c
	$(CC) $(CFLAGS) -o $@ $^

lib%.so: ../%.c
	$(CC) $(CFLAGS) -DSHARED -shared -fPIC -o $@ $^
	
shared-test: ../shared-test.c libc3.so
	$(CC) $(CFLAGS) -o $@ $^
