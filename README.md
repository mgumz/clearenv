# clearenv

`clearenv` is a filter program which removes environment variables set and
launches another program which then does not have the removed environment
variables.

This can be used to remove sensitive environment variables before starting
sub-processes.

## Usage

```sh
clearenv [-ha] [PATTERN...] -- /path/to/other/cmd args
```

**Note:** `clearenv` requires the full path to the program it should launch.
You can apply one of the following approaches:

```sh
clearenv PATTERN -- `which cmd`
```

```sh
clearenv PATTERN -- /bin/sh -c cmd
```

### Flags

* `-h | --help`: show simple usage
* `-a | --all`:  remove all environment variables. Equivalent to `env -i`.

### Matching Modes

* Prefix match: Use "PATTERN". All environment variables starting with
  "PATTERN" are removed.

* Exact match: Use "PATTERN=" to match exactly the environment variable
  "PATTEN", not "PATTERNX" or "PATTERN_".

## License

See LICENSE file, BSD-3 clause.

## Building

    make clearenv

### Different Implementations

For fun, there are different implementations in various programming languages,
mainly for education purposes, partially to compare the relative complexity of
the languages, the resulting binary size etc.

See the `*-lang` folders.

| Flavour                                    | Binary size   |
| ------------------------------------------ | ------------- |
| c-lang/clearenv (MacOS dynamically linked) | 34k           |
| c-lang/clearenv (Linux dynamically linked) | 69k           |
| c-lang/clearenv (Linux statically linked)  | 584k          |
| c-lang/clearenv (Linux static diet)        | 71k           |
| go-lang/clearenv (MacOS, Golang-1.25.1)    | 1340k         |
| go-lang/clearenv (MacOS, Tinygo-0.39.0)    | 202k          |
| rust-lang/clearenv (MacOS, Rust-1.89)      | 292k          |
| rust-lang/clearenv (Linux, Rust-1.91)      | 333k          |
| zig-lang/clearenv (MacOS, Zig-0.15.2)      | 74k           |


## Related

* GNU `env(1)`: https://man7.org/linux/man-pages/man1/env.1.html
* FreeBSD `env(1)`: https://man.freebsd.org/cgi/man.cgi?env

## Author(s)

* Mathias Gumz <mg@2hoch5.com>

