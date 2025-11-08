/*------------------------------------------------------------------*\
    name:  clearenv

    about: removes environment variables matching provided patterns
           from the current environment context and launches a
           provided command.

    author: mathias gumz
\*------------------------------------------------------------------*/

#include "djb/str.h"
#include "djb/byte.h"
#include <unistd.h>
#include <stdlib.h>


/*------------------------------------------------------------------*\
\*------------------------------------------------------------------*/


#define writeStdout(s) write(1, s, sizeof(s));
#define writeStderr(s) write(2, s, sizeof(s));
int do_execve(const char* p, char** argv, char** env);
int do_unsetenv(const char* prefix);
int print_usage();

extern char** environ;
char* clean_env[1] = { NULL };

int main(int argc, char* argv[]) {

    size_t i;
    size_t i_other = argc;
    int do_cleanall = 0;

    // command line parsing
    for (i = 1; i < argc; i++) {
        // scan for "--". if found: exec() at the end
        if (!str_diff(argv[i], "--")) {
            i_other = i;
            break;
        }
        // --all
        if (i_other == argc && (!str_diff(argv[i], "-a") || !str_diff(argv[i], "--all"))) {
            do_cleanall = 1;
        }
    }

    // no "--" found, no other command found. ok, but
    // useless.
    if (i_other == argc) {
        for (i = 1; i < i_other; i++) {
            if (!str_diff(argv[i], "-h") || !str_diff(argv[i], "--help")) {
                print_usage();
                break;
            }
        }
        return 0;
    }

    // "--" given, but no command after. usage error
    if ((i_other + 1) == argc) {
        writeStderr("error: no cmd after \"--\" given.\n");
        return 1;
    }

    // preparing the environment for exec()

    if (do_cleanall) {
        environ = clean_env;
        goto do_exec;
    }

    // iterate over args, try to check all environment
    // variables if the prefix matches, unsetenv() it.
    for (i = 1; i < i_other; i++) {

        // why goto-rescan? unsetenv() modifies the environ
        // array - all entries after the removed one
        // shift one to the left to keep environ an array
        // without any holes. that said: this is implementation
        // specific. there is also no guarantee that after
        // calling unsetenv() the entries in environ have the
        // same order. thus: as soon as we unsetenv() something,
        // we just go over the full environ. it won't be millions
        // of entries.
    rescan:
        for (char** e = environ; e != NULL && *e != NULL; ++e) {

            // how to implement "prefix" match and "exact" match?
            //
            // opt-a: pattern "ABC_%" - prefix, similar to MySQL. '*' might interact
            //        with the shell/shell-globbing, kind of annoying in
            //        usage. '%' itself then is either not allowed in an environment
            //        variable or special quoting needs to be implemented.
            //
            //        this whole adding special pattern thingy adds complexity.
            //
            // opt-b: the environment variables are in form "ABC=123" or "UVW=".
            //        this allows for "exact" match if "ABC=" is given by
            //        the user. or "prefix" match if just "AB" is given.
            //        in addition, an environment variable can also be
            //        cleared if it contains a specific value: "ABC=123".
            //        kind of … no complexity at all.
            //
            //        so, option "b" it is.
            if (str_start(*e, argv[i]) == 1) {
                do_unsetenv(*e);
                goto rescan;
            }
        }
    }

do_exec:
    return do_execve(argv[i_other+1], &argv[i_other+1], environ);
}

int do_execve(const char* p, char** argv, char** env) {

    int rc = execve(p, argv, env);
    if (rc != 0) {
        writeStderr("unable to exec \"");
        write(2, p, str_len(p));
        writeStderr("\"\n");
    }
    return rc;
}

int do_unsetenv(const char* prefix) {

    size_t len_key = str_chr(prefix, '=');
    char key[len_key];
    byte_copy(key, len_key, prefix);
    key[len_key] = '\0';

    return unsetenv(key);
}

int print_usage() {
    writeStdout("usage: clearenv [-ha] [PATTERN...] -- /path/to/other [ARGS]\n");
    return 0;
}

