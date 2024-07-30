const std = @import("std");

pub fn modMain() !u8 {
    std.posix.sync();
    return 0;
}
