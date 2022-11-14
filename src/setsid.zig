const std = @import("std");
const util = @import("./util.zig");
const c = @cImport({
    @cInclude("unistd.h");
});

pub fn usage() noreturn {
    util.eprintf("usage: {s} [-f] cmd [arg ...]\n", .{util.getArgv0()}, .{});
}

pub fn modMain() !u8 {
    var args = util.parseArgs();
    var fflag = false;

    while (args.nextFlag()) |flag|
        switch (flag) {
            'f' => fflag = true,
            else => usage(),
        };

    if (args.countRest() == 0)
        usage();

    if (fflag or (c.getpgrp() == c.getpid())) {
        switch (c.fork()) {
            -1 => util.eprintf("fork:", .{}, .{}),
            0 => {},
            else => return 0,
        }
    }

    if (c.setsid() < 0)
        util.eprintf("setsid:", .{}, .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    util.execvp(arena.allocator(), std.os.argv[1..]) catch |err| {
        util.weprintf("execvp:", .{}, .{});
        c._exit(@intCast(c_int, 126) + @boolToInt(err == error.FileNotFound));
    };
}
