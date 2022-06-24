ERL_INCLUDE_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

ifeq ($(shell uname),Darwin)
	LDFLAGS += -undefined dynamic_lookup
endif

all: priv/yamecab.so

priv/yamecab.so: src/yamecab.c
	cc -fPIC -I$(ERL_INCLUDE_PATH) -dynamiclib -shared $(LDFLAGS) -lmecab -o $@  src/yamecab.c
