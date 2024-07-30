pub const ReadIntError = error{
    Empty,
};

pub fn readInt(comptime T: type, str: []const u8, ret_len: ?*usize) ReadIntError!T {
    if (str.len == 0) return error.Empty;

    var neg = false;
    var i: usize = 0;
    var x: T = 0;

    if (str[0] == '-') {
        neg = true;
        i += 1;
    } else if (str[0] == '+') {
        neg = false;
        i += 1;
    }

    while (i < str.len) {
        const c = str[i];

        if (c < '0' or c > '9') {
            break;
        }
        const d = c - '0';

        x = x * 10 + d;

        i += 1;
    }

    if (ret_len) |ptr_len| {
        ptr_len.* = i;
    }
    return if (neg) -1 * x else x;
}

test "returns the number of bytes consumed" {
    const expect = @import("std").testing.expect;
    var len: usize = 0;

    try expect(try readInt(i32, "1", &len) == 1);
    try expect(len == 1);
    try expect(try readInt(i32, "12", &len) == 12);
    try expect(len == 2);
    try expect(try readInt(i32, "123", &len) == 123);
    try expect(len == 3);
    try expect(try readInt(i32, "123v", &len) == 123);
    try expect(len == 3);
}

test "parse a number w/o sign" {
    const expect = @import("std").testing.expect;
    try expect(try readInt(i32, "0", null) == 0);
    try expect(try readInt(i32, "1", null) == 1);
    try expect(try readInt(i32, "12", null) == 12);
    try expect(try readInt(i32, "123", null) == 123);
}

test "parse a number w/ minus sign" {
    const expect = @import("std").testing.expect;
    try expect(try readInt(i32, "-872", null) == -872);
}

test "parse a number w/ plus sign" {
    const expect = @import("std").testing.expect;
    try expect(try readInt(i32, "+9432", null) == 9432);
}

test "parse numbers mixed in string" {
    const expect = @import("std").testing.expect;
    try expect(try readInt(i32, "1*", null) == 1);
    try expect(try readInt(i32, "646a", null) == 646);
}
