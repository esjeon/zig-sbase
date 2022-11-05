const std = @import("std");
const ArgReader = @import("util/args.zig").ArgReader;

const c = @cImport({
    @cInclude("unistd.h");
    @cInclude("pwd.h");
});

extern fn __errno_location() [*c]c_int;
extern "c" fn perror([*c]const u8) void;

fn get_errno() c_int {
    return __errno_location().*;
}

fn set_errno(arg_no: c_int) void {
    __errno_location().* = arg_no;
}

pub fn usage() void {
    const name = std.mem.sliceTo(std.os.argv[0], 0);
    std.debug.print("usage: {s}\n", .{name});
    std.os.exit(1);
}

pub fn modMain() !u8 {
    var args = ArgReader.init(std.os.argv[1..]);

    while (args.nextFlag()) |_| {
        usage();
    }

	if (args.countRest() != 0) {
		usage();
	}

    var stdout = std.io.getStdOut().writer();
    var stderr = std.io.getStdErr().writer();

    const uid = c.geteuid();
    set_errno(0);
    var pw = c.getpwuid(uid);
    if (pw == null) {
        if (get_errno() == 0) {
            try stderr.print("getpwuid {d}: no such user\n", .{uid});
        } else {
            try stderr.print("getpwuid {d}:", .{uid});
            perror(null);
        }
        return 1;
    }
    const name = std.mem.sliceTo(pw.*.pw_name, 0);
    try stdout.print("{s}\n", .{name});

    return 0;
}
