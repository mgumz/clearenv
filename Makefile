
c-lang/bin/clearenv:
	make -C c-lang

.PHONY: git-archive
git-archive:
	git archive -o clearenv.tgz HEAD

update-manpage:
	pandoc README.md -s -t man -o clearenv.1

run-dev-container:
	podman run -it --rm -v `pwd`:/clearenv-build debian:trixie-slim
