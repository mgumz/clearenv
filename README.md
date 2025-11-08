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

## Related

* GNU `env(1)`: https://man7.org/linux/man-pages/man1/env.1.html
* FreeBSD `env(1)`: https://man.freebsd.org/cgi/man.cgi?env

## Author(s)

* Mathias Gumz <mg@2hoch5.com>

