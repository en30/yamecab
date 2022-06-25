ERL_INCLUDE_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
MECAB_CFLAGS = $(shell mecab-config --cflags)
MECAB_LIBS = $(shell mecab-config --libs)

ifeq ($(shell uname),Darwin)
	LDFLAGS += -undefined dynamic_lookup
endif

all: priv/yamecab.so

priv/yamecab.so: src/yamecab.c
	cc -fPIC -I$(ERL_INCLUDE_PATH) $(MECAB_CFLAGS) -shared $(LDFLAGS) -o $@ src/yamecab.c $(MECAB_LIBS)

clean:
	@rm priv/yamecab.so
