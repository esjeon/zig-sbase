const std = @import("std");
const util = @import("./util.zig");
const c = @cImport({
    @cInclude("unistd.h");
});

extern "c" fn chroot([*:0]const u8) c_int;

pub fn usage() noreturn {
    util.eprintf("usage: {s} dir [cmd [arg ...]]\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();

    while (args.nextFlag()) |_|
        usage();

    if (args.countRest() == 0)
        usage();

    var chroot_dir = args.nextPositionalRaw().?;

    if (chroot(chroot_dir) < 0)
        util.eprintf("chroot {s}:", .{std.mem.sliceTo(chroot_dir, 0)}, .{});

    std.os.chdir("/") catch
        util.eprintf("chdir:", .{}, .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    if (args.countRest() == 0) {
        const shell = if (std.os.getenv("SHELL")) |val| val else "/bin/shell";
        const cmd = [_][]const u8{ shell, "-i" };
        util.zexecvp(arena.allocator(), cmd[0..]) catch |err| {
            util.weprintf("execvp:", .{}, .{});
            c._exit(@intCast(c_int, 126) + @boolToInt(err == error.FileNotFound));
        };
    } else {
        const cmd: [][*:0]u8 = std.os.argv[2..];
        util.execvp(arena.allocator(), cmd) catch |err| {
            util.weprintf("execvp:", .{}, .{});
            c._exit(@intCast(c_int, 126) + @boolToInt(err == error.FileNotFound));
        };
    }
}
