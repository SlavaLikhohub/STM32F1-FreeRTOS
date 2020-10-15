DEBUG ?= 0
TARGET_FIFO := freeRTOS_stm32f1
TARGET_SHARED := lib$(TARGET_FIFO).sh
TARGET_STATIC := lib$(TARGET_FIFO).a
SRCDIR = ./src
INCDIRS = ./include

SRCS =  croutine.c heap_3.c list.c queue.c tasks.c
SRCS += event_groups.c port.c  stream_buffer.c  timers.c


BUILDDIR = .build/

PREFIX ?= arm-none-eabi-
AR ?= $(PREFIX)ar
CC := $(PREFIX)gcc

CFLAGS ?= -O2 -std=gnu17 -Wall -Wextra -Wpedantic
ARFLAGS ?= rcs
INCL := $(addprefix -I,$(INCDIRS)) 
DEF  := -DDEBUG=$(DEBUG)
LDFLAGS = $(shell pkg-config --libs $(LIBS)) -Wl,--as-needed

FPU ?= soft
ARCHFLAGS := -mcpu=cortex-m3 -mthumb $(FPU_FLAGS)

CFLAGS += $(ARCHFLAGS)
CFLAGS += -fdata-sections -ffunction-sections

.PHONY: all clean shared static

all: shared

shared : $(BUILDDIR)/$(TARGET_SHARED)

static : $(BUILDDIR)/$(TARGET_STATIC)

$(BUILDDIR)/$(TARGET_STATIC): $(addprefix $(BUILDDIR)/,$(SRCS:.c=.o))
	$(AR) -rcs $@ $^

$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	$(CC) $(CFLAGS) $(INCL) -c $< -o $@

$(BUILDDIR)/$(TARGET_SHARED): $(addprefix $(BUILDDIR)/,$(SRCS:.c=.o))
	$(CC) -shared $(CFLAGS) $(INCL) $(DEF) $(LDFLAGS) $^ -o $@

$(BUILDDIR):
	mkdir -p $@

clean:
	-rm -rf $(BUILDDIR)

