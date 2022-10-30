const std = @import("std");

pub fn modMain() !u8 {
    std.os.sync();
    return 0;
}
