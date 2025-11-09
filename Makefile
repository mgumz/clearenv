
SRC = clearenv.c		\
	  djb/byte_copy.c	\
	  djb/str_chr.c		\
	  djb/str_diff.c	\
	  djb/str_len.c		\
	  djb/str_start.c

.PHONY: bin/clearenv
bin/clearenv: $(SRC) bin
	cc -o "$@" -Os -Idjb $(SRC)

.PHONY: bin/clearenv.diet
bin/clearenv.diet: $(SRC) bin
	diet cc -o "$@" -Os -Idjb $(SRC) -static

.PHONY: bin/clearenv.debug
bin/clearenv.debug: $(SRC) bin
	cc -o "$@" -g -Idjb $(SRC)

bin:
	mkdir -p "$@"

.PHONY: git-archive
git-archive:
	git archive -o clearenv.tgz HEAD


update-manpage:
	pandoc README.md -s -t man -o clearenv.1

run-dev-container:
	podman run -it --rm -v `pwd`:/build debian:trixie-slim
