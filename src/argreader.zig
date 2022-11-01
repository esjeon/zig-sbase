const std = @import("std");
const startsWith = std.mem.startsWith;

fn GenericArgReader(comptime T: type, comptime sentinel: ?u8) type {
    return struct {
        const This = @This();

        argv: T,
        i: usize,
        positional: bool,

        pub fn init(argv: T) This {
            return This{
                .argv = argv,
                .i = 0,
                .positional = false,
            };
        }

        fn get_current_word(self: *This) []const u8 {
            if (sentinel) |s| {
                return std.mem.sliceTo(self.argv[self.i], s);
            } else {
                return self.argv[self.i];
            }
        }

        pub fn nextFlag(self: *This) ?[]const u8 {
            if (self.positional or self.i >= self.argv.len) {
                return null;
            }

            const word = self.get_current_word();
            if (word[0] != '-') {
                // Got a positional argument. Finish parsing flags.
                self.positional = true;
                return null;
            }

            self.i += 1;
            return word;
        }

        pub fn nextPositional(self: *This) ?[]const u8 {
            if (!self.positional or self.i >= self.argv.len) {
                return null;
            }

            const word = self.get_current_word();
            self.i += 1;
            return word;
        }
    };
}

pub const ArgReader = GenericArgReader([][*:0]const u8, '0');
pub const SliceArgReader = GenericArgReader([][]const u8, null);

test "basic usecase" {
    var args = [_][]const u8{ "-a", "-b", "Hello", "world" };
    var reader = SliceArgReader.init(args[0..]);

    var ret = reader.nextFlag();
    try std.testing.expect(ret != null);
    try std.testing.expect(std.mem.eql(u8, ret.?, "-a"));

    ret = reader.nextFlag();
    try std.testing.expect(ret != null);
    try std.testing.expect(std.mem.eql(u8, ret.?, "-b"));

    ret = reader.nextFlag();
    try std.testing.expect(ret == null);

    ret = reader.nextPositional();
    try std.testing.expect(ret != null);
    try std.testing.expect(std.mem.eql(u8, ret.?, "Hello"));

    ret = reader.nextPositional();
    try std.testing.expect(ret != null);
    try std.testing.expect(std.mem.eql(u8, ret.?, "world"));

    ret = reader.nextPositional();
    try std.testing.expect(ret == null);
}
