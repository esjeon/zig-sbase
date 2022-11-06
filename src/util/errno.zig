extern fn __errno_location() [*c]c_int;

pub fn get() c_int {
    return __errno_location().*;
}

pub fn set(no: c_int) void {
    __errno_location().* = no;
}

test "get errno" {
    const std = @import("std");

    // Perform a random failing operation.
    var buf: [4]u8 = undefined;
    _ = std.c.read(99, &buf, 0);

    try std.testing.expect(get() != 0);
}

test "set->get round trip" {
    const std = @import("std");
    set(10);
    try std.testing.expect(get() == 10);
}
