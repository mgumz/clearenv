use libc::{c_char, execve};
use std::env;
use std::ffi::CString;
use std::process;

fn main() {
    let mut do_clearenv = false;
    let n_args = env::args().count();
    let mut i_other = n_args;

    // scan over command line arguments
    for (i, arg) in std::env::args().enumerate() {
        if arg == "--" {
            i_other = i;
            break;
        } else if arg == "-h" || arg == "--help" {
            println!("usage: clearenv [-ha] [PATTERN...] -- /path/to/other [ARGS]");
            return;
        } else if arg == "-a" || arg == "--all" {
            do_clearenv = true;
        }
    }

    if i_other == n_args {
        process::exit(0)
    }

    // we will build a new environment for launching
    // the /path/to/other command.
    let mut vars: Vec<CString> = Vec::new();

    if !do_clearenv {
        // we need a stable copy of env::vars() as it is right now.
        // when PATTERN matches, we will call env::remove_var()
        // and thus mutate the environment.
        let env_copy: Vec<String> = env::vars()
            .map(|(key, value)| format!("{key}={value}"))
            .collect();

        for prefix in env::args().skip(1).take(i_other - 1) {
            for entry in &env_copy {
                if entry.starts_with(&prefix) {
                    let index = entry.find('=').unwrap();
                    let key = &entry[..index];
                    unsafe {
                        env::remove_var(key);
                    }
                }
            }
        }

        // construct the cleaned environment
        vars = env::vars()
            .map(|(key, value)| 
                CString::new(format!("{key}={value}")).unwrap())
            .collect();
    }

    let mut vars_ptr: Vec<*const c_char> = vars
        .iter()
        .map(|var| var.as_ptr())
        .collect();
    vars_ptr.push(std::ptr::null());

    // build the arguments for /path/to/other
    // we need to keep CStrings around to not invalidate
    // the .as_ptr() references down the line
    let argv: Vec<CString> = env::args()
        .skip(i_other+1)
        .map(|arg| CString::new(arg).unwrap())
        .collect();

    let mut argv_ptr: Vec<*const c_char> = argv
        .iter()
        .map(|arg| arg.as_ptr())
        .collect();
    argv_ptr.push(std::ptr::null());

    // and finally, replace ourself with a cleared environment
    let rc = unsafe {
        execve(argv_ptr[0], argv_ptr.as_ptr(), vars_ptr.as_ptr())
    };
    if rc == -1 {
        let errno = std::io::Error::last_os_error();
        eprintln!("execve failed: {}", errno);
    }
}
