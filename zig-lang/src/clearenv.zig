const std = @import("std");

const usage = "usage: clearenv [-ha] [PATTERN...] -- /path/to/cmd [ARGS...]\n";

extern "c" var environ: [*:null]?[*:0]u8;
extern "c" var errno: c_int;

extern "c" fn unsetenv(name: [*:0]const u8) c_int;
extern "c" fn execve(path: [*:0]const u8, argv: [*:null]const ?[*:0]const u8, envp: [*:null]const ?[*:0]const u8) c_int;
extern "c" fn strerror(err: c_int) [*:0]const u8;

pub fn main() u8 {

    // ------------------------------------------------------------------------
    // command line parsing
    var i_other = std.os.argv.len;
    var do_clearall = false;

    for (1..std.os.argv.len) |i| {
        const arg = std.mem.span(std.os.argv[i]);

        if (std.mem.eql(u8, arg, "--")) {
            i_other = i;
            break;
        } else if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            std.debug.print(usage, .{});
            return 0;
        } else if (std.mem.eql(u8, arg, "-a") or std.mem.eql(u8, arg, "--all")) {
            do_clearall = true;
        }
    }

    if (i_other == std.os.argv.len) {
        return 0;
    }

    // ------------------------------------------------------------------------
    // scan for matching environment variables and clear them
    // when the pattern matches

    if (!do_clearall) {

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();

        for (std.os.argv[1..i_other]) |arg| {
            //std.debug.print("arg: {s}\n", .{prefix});
            const prefix = std.mem.span(arg);

            var i: usize = 0;
            while (environ[i] != null) {

                const env_str = std.mem.span(environ[i].?);
                // std.debug.print("env: {s}\n", .{env_str});

                if (!std.mem.startsWith(u8, env_str, prefix)) {
                    i = i + 1;
                    continue;
                }

                if (std.mem.indexOf(u8, env_str, "=")) |key_index| {
                    const key = env_str[0..key_index];
                    _ = do_unsetenv(allocator, key) catch |err| {
                        std.debug.print("Error: {}\n", .{err});
                    };
                    // unsetenv() modifies environ, so, it invalidates
                    // how we iterate over it. lets start from the
                    // start
                    i = 0;
                    continue;
                }
                i = i + 1;
            }
        }
    }

    // ------------------------------------------------------------------------
    // execute /path/to/other with the cleared environment
    //

    var other_env = environ;
    if (do_clearall) {
        other_env[0] = null;
    }
    const other_argv: [*:null]const ?[*:0]const u8 = @ptrCast(std.os.argv.ptr + i_other + 1);
    const other_cmd = std.os.argv[i_other+1];

    const rc = execve(other_cmd, other_argv, other_env);
    if (rc == -1) {
        const err_msg = strerror(errno);
        std.debug.print("execve \"{s}\" failed: {s}\n", .{other_cmd, err_msg});
    }

    return 1;
}

fn do_unsetenv(allocator: std.mem.Allocator, key: []const u8) !c_int {
    const key_cstr = try allocator.dupeZ(u8, key);
    defer allocator.free(key_cstr);

    const result = unsetenv(key_cstr);
    return result;
}
