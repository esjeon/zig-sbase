const std = @import("std");
const startsWith = std.mem.startsWith;

fn GenericArgReader(comptime T: type, comptime sentinel: ?u8) type {
    return struct {
        const This = @This();

        argv: T,
        i: usize,
        finished: bool,

        pub fn init(argv: T) This {
            return This{
                .argv = argv,
                .i = 0,
                .finished = false,
            };
        }

        pub fn next(self: *This) ?[]const u8 {
            if (self.finished or self.i >= self.argv.len) {
                return null;
            }

            const word = (if (sentinel) |s|
                std.mem.sliceTo(self.argv[self.i], s)
            else
                self.argv[self.i]);

            if (word[0] != '-') {
                // Got a positional argument. Finish parsing flags.
                self.finished = true;
                return null;
            }

            self.i += 1;
            return word;
        }
    };
}

pub const ArgReader = GenericArgReader([][*:0]const u8, '0');
pub const SliceArgReader = GenericArgReader([][]const u8, null);

test "expect .next() to read independent flags" {
    var args = [_][]const u8{ "-a", "-b" };
    var reader = SliceArgReader.init(args[0..]);

    var flag = reader.next();
    try std.testing.expect(flag != null);
    try std.testing.expect(std.mem.eql(u8, flag.?, "-a"));

    flag = reader.next();
    try std.testing.expect(flag != null);
    try std.testing.expect(std.mem.eql(u8, flag.?, "-b"));

    flag = reader.next();
    try std.testing.expect(flag == null);
}
