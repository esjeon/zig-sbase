const std = @import("std");
const errno = @import("./errno.zig");
const eprintf = @import("./eprintf.zig").eprintf;
const c = @cImport({
    @cInclude("unistd.h");
});

pub fn zexecvp(allocator: std.mem.Allocator, argv: []const []const u8) !noreturn {
    const argv_buf = try allocator.allocSentinel(?[*:0]u8, argv.len, null);
    for (0.., argv) |i, arg|
        argv_buf[i] = (try allocator.dupeZ(u8, arg)).ptr;

    try call_exec(argv_buf.ptr[0].?, argv_buf.ptr);
}

pub fn execvp(allocator: std.mem.Allocator, argv: [][*:0]u8) !noreturn {
    const argv_buf = try allocator.allocSentinel(?[*:0]u8, argv.len, null);
    for (0.., argv) |i, arg|
        argv_buf[i] = arg;

    try call_exec(argv_buf.ptr[0].?, argv_buf.ptr);
}

fn call_exec(file: [*c]const u8, argv: [*c]const [*c]u8) !noreturn {
    // Shamelessly copied over from `std.os.execveZ`.
    switch (std.posix.errno(c.execvp(file, argv))) {
        .SUCCESS => unreachable,
        .FAULT => unreachable,
        .@"2BIG" => return error.SystemResources,
        .MFILE => return error.ProcessFdQuotaExceeded,
        .NAMETOOLONG => return error.NameTooLong,
        .NFILE => return error.SystemFdQuotaExceeded,
        .NOMEM => return error.SystemResources,
        .ACCES => return error.AccessDenied,
        .PERM => return error.AccessDenied,
        .INVAL => return error.InvalidExe,
        .NOEXEC => return error.InvalidExe,
        .IO => return error.FileSystem,
        .LOOP => return error.FileSystem,
        .ISDIR => return error.IsDir,
        .NOENT => return error.FileNotFound,
        .NOTDIR => return error.NotDir,
        .TXTBSY => return error.FileBusy,
        .LIBBAD => return error.InvalidExe,
        else => |err| return std.posix.unexpectedErrno(err),
    }
}
