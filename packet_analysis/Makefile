GCC=g++
CFLAGS+=-Wall -g
CFLAGS+=-std=c++11 -pedantic -Wextra
CFLAGS+=-DUSE_SLEEP
LIBS=-lpcap
SRC=$(wildcard *.cpp)
PROGS=$(patsubst %.cpp,%,$(SRC))
#OBJS = $(SRC:.c=.o)

%: %.cpp
	$(GCC) $(CFLAGS+) $< $(LIBS) -o $@ 

all: $(PROGS)

clean:
	rm -f $(PROGS) *~
