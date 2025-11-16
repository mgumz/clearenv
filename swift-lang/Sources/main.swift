import Foundation

// Declare the extern C variable
@_silgen_name("environ")
var environ: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>

/*------------------------------------------------------------------*\
   parse command line
\*------------------------------------------------------------------*/
var i_other = CommandLine.arguments.count

for (i, arg) in CommandLine.arguments.enumerated() {
    if (arg == "--") {
        i_other = i
        break
    } else if (arg == "-h" || arg == "--help") {
        print("usage: clearenv [-ha] [PATTERN...] -- /path/to/cmd [ARGS...]\n");
        exit(0);
    } else if (arg == "-a" || arg == "--all") {
    }
}

if (i_other == CommandLine.arguments.count) {
    exit(0);
}

/*------------------------------------------------------------------*\
   analyse environment variables
\*------------------------------------------------------------------*/
let env_copy = ProcessInfo.processInfo.environment
print("Environment Variables:")
for (key, value) in env_copy.sorted(by: { $0.key < $1.key }) {
    print("\(key)=\(value)")
}

/*------------------------------------------------------------------*\
   execve
\*------------------------------------------------------------------*/

