const std = @import("std");
const util = @import("./util.zig");
const c = @cImport({
    @cInclude("signal.h");
    @cInclude("unistd.h");
    @cInclude("errno.h");
});

pub fn usage() noreturn {
    util.eprintf("usage: {s} cmd [arg ...]\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_|
        usage();

    if (args.countRest() == 0)
        usage();

    if (c.signal(c.SIGHUP, c.SIG_IGN) == c.SIG_ERR)
        util.eprintf("signal HUP: ", .{}, .{ .perror = true, .exit = 127 });

    if (std.os.isatty(std.os.STDOUT_FILENO)) {
        var out = std.fs.cwd().createFile("nohup.out", .{ .read = false, .mode = 0o700 }) catch {
            util.eprintf("open nohup.out:", .{}, .{ .perror = true, .exit = 127 });
        };
        std.os.dup2(out.handle, std.os.STDOUT_FILENO) catch {
            util.eprintf("dup2:", .{}, .{ .perror = true, .exit = 127 });
        };
        out.close();
    }

    if (std.os.isatty(std.os.STDERR_FILENO)) {
        std.os.dup2(std.os.STDOUT_FILENO, std.os.STDERR_FILENO) catch
            util.eprintf("dup2:", .{}, .{ .perror = true, .exit = 127 });
    }

    // NOTE: We're going to use `execvp`, which is NOT provided by `std`.
    //
    // We need to manually convert arguments *back* to C-style arrays, but, to
    // do that, we need a memory allocator. Not very minimal.

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var argv = std.os.argv[1..];

    const argv_buf = try alloc.allocSentinel(?[*:0]u8, argv.len, null);
    for (argv) |arg, i|
        argv_buf[i] = arg;

    _ = c.execvp(argv_buf.ptr[0].?, argv_buf.ptr);

    if (util.errno.get() == c.ENOENT)
        return 127;
    return 126;
}
