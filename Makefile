merkex_src := $(wildcard lib/*ex) \
	$(wildcard lib/**/*.ex) \
	mix.exs
merkex_deps := $(wildcard deps/*)

.PHONY: all test testex iex clean wipe

all: ebin

ebin: $(merkex_src)
	MIX_ENV=dev mix do deps.get, compile

#sys.config: ebin config.exs lib/config.ex
#	@ERL_LIBS=.:deps elixir -e "config = Saloon.Config.file!(%b{config.exs}); config.sys_config!(%b{sys.config})"

testex: all
	@ERL_LIBS=.:deps MIX_ENV=test iex --sname merkex_test --erl "-boot start_sasl"

iex: all
	@ERL_LIBS=.:deps MIX_ENV=dev iex --sname merkex_console --erl "-boot start_sasl"

clean:
	@mix clean

wipe: clean
	@rm -rf ./deps/*
