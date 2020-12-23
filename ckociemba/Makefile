CKOCIEMBA_SRC = coordcube.c cubiecube.c facecube.c search.c prunetable_helpers.c
CKOCIEMBA_INCLUDE = include
CFLAGS = -std=c99 -O3
LIBDIR = lib

lib: $(CKOCIEMBA_SRC)
	mkdir -p $(LIBDIR)
	gcc $(CFLAGS) -c $(CKOCIEMBA_SRC) -I$(CKOCIEMBA_INCLUDE)
	ar -q $(LIBDIR)/libkociemba.a *.o
	rm *.o
