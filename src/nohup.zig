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

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    util.execvp(arena.allocator(), std.os.argv[1..]) catch |err| {
        util.weprintf("execvp:", .{}, .{});
        c._exit(@intCast(c_int, 126) + @boolToInt(err == error.FileNotFound));
    };
}
