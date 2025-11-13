
all: bin/clearenv bin/clearenv.tiny

bin:
	mkdir bin

bin/clearenv: bin
	go build -o $@ -ldflags "-w -s" clearenv.go

bin/clearenv.tiny: bin
	tinygo build -o $@ -no-debug clearenv.go
