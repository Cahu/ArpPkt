CC=gcc
CFLAGS=-g -W
LDFLAGS=-lnet

PGRM=arpsend
SRCS=arpsend.c
OBJS=${SRCS:.c=.o}

.PHONY: all clean

all: $(OBJS)
	$(CC) -o $(PGRM) $(CFLAGS) $(LDFLAGS) $^

# Generate dependancies
%.d:%.c
	@ $(CC) -MM $< | sed 's,^\($*\)\.o,\1\.o \1\.d,g' > $@

# Include dependancy files
-include ${SRCS:.c=.d}

clean:
	rm -f ${SRCS:.c=.d} $(OBJS)
