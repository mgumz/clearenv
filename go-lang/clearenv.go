package main

import (
	"io"
	"os"
	"strings"
	"syscall"
)

func main() {

	env := os.Environ()
	doCleanEnv := false

	iOther := len(os.Args)

	for i, arg := range os.Args {
	args:
		switch arg {
		case "--":
			iOther = i
			break args
		case "--help", "-h":
			usage()
			return
		case "--all", "-a":
			doCleanEnv = true
		}
	}

	// no "--" given, so also not /path/to/cmd provided
	// useless operation
	if iOther == len(os.Args) {
		return
	}

	if doCleanEnv {
		env = []string{}
		goto doExec
	}

	// scan all patterns
	for _, pattern := range os.Args {
		for _, e := range env {
			if strings.HasPrefix(e, pattern) {
				lk := strings.Index(e, "=")
				key := e[:lk]
				os.Unsetenv(key)
			}
		}
	}

	// os.Unsetenv() has modifed the environment, get it
	env = os.Environ()

doExec:
	cmd := os.Args[iOther+1]
	if err := syscall.Exec(cmd, os.Args[iOther+1:], env); err != nil {
		io.WriteString(os.Stderr, "error launching \""+cmd+"\": "+err.Error())
		os.Exit(1)
	}
}

func usage() {
	io.WriteString(os.Stdout, "usage: clearenv [-ha] [PATTERN...] -- /path/to/cmd [ARGS]\n")
}
