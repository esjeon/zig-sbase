const std = @import("std");
const startsWith = std.mem.startsWith;

pub fn GenericArgReader(comptime T: type, comptime sentinel: ?u8) type {
    return struct {
        const This = @This();

        argv: T,
        argc: usize,
        i: usize,

        word: []const u8,
        j: ?usize,

        finished: bool,

        pub fn init(args: T) This {
            return This{
                .argv = args,
                .argc = args.len,
                .i = 0,

                .word = undefined,
                .j = null,

                .finished = false,
            };
        }

        fn readArg(self: *This) []const u8 {
            if (sentinel) |s| {
                return std.mem.sliceTo(self.argv[self.i], s);
            } else {
                return self.argv[self.i];
            }
        }

        pub fn nextFlag(self: *This) ?u8 {
            if (self.finished) return null;

            if (self.j) |j| {
                if (j < self.word.len) {
                    const c = self.word[j];
                    self.j = j + 1;
                    return c;
                } else {
                    self.j = null;
                }
            }

            if (self.i < self.argc) {
                self.word = self.readArg();
                if (self.word.len <= 1 or self.word[0] != '-') {
                    self.finished = true;
                    return null;
                }

                self.i += 1;
                if (self.word.len == 2 and self.word[1] == '-') {
                    self.finished = true;
                    return null;
                }

                self.j = 2;
                return self.word[1];
            }
            return null;
        }

        pub fn nextPositional(self: *This) ?[]const u8 {
            if (!self.finished) return null;

            if (self.i < self.argc) {
                const arg = self.readArg();
                self.i += 1;
                return arg;
            }
            return null;
        }
    };
}

pub const ArgReader = GenericArgReader([][:0]const u8, '\x00');
pub const SliceArgReader = GenericArgReader([][]const u8, null);

test "parse flags" {
    var args = [_][]const u8{ "-a", "-b", "-c" };
    var reader = SliceArgReader.init(args[0..]);

    try std.testing.expect(reader.nextFlag().? == 'a');
    try std.testing.expect(reader.nextFlag().? == 'b');
    try std.testing.expect(reader.nextFlag().? == 'c');
}

test "parse flags and positionals" {
    var args = [_][]const u8{ "-a", "-b", "0", "1" };
    var reader = SliceArgReader.init(args[0..]);

    try std.testing.expect(reader.nextFlag().? == 'a');
    try std.testing.expect(reader.nextFlag().? == 'b');
    try std.testing.expect(reader.nextFlag() == null);
    try std.testing.expect(std.mem.eql(u8, reader.nextPositional().?, "0"));
    try std.testing.expect(std.mem.eql(u8, reader.nextPositional().?, "1"));
    try std.testing.expect(reader.nextPositional() == null);
}

test "parse composite flags" {
    var args = [_][]const u8{ "-abc", "-de" };
    var reader = SliceArgReader.init(args[0..]);

    try std.testing.expect(reader.nextFlag().? == 'a');
    try std.testing.expect(reader.nextFlag().? == 'b');
    try std.testing.expect(reader.nextFlag().? == 'c');
    try std.testing.expect(reader.nextFlag().? == 'd');
    try std.testing.expect(reader.nextFlag().? == 'e');
    try std.testing.expect(reader.nextFlag() == null);
}

test "double-dash separates flags from positionals" {
    var args = [_][]const u8{ "-a", "--", "0" };
    var reader = SliceArgReader.init(args[0..]);

    try std.testing.expect(reader.nextFlag().? == 'a');
    try std.testing.expect(reader.nextFlag() == null);
    try std.testing.expect(std.mem.eql(u8, reader.nextPositional().?, "0"));
    try std.testing.expect(reader.nextPositional() == null);
}

test "single-dash is a positional" {
    var args = [_][]const u8{ "-a", "-", "0" };
    var reader = SliceArgReader.init(args[0..]);

    try std.testing.expect(reader.nextFlag().? == 'a');
    try std.testing.expect(reader.nextFlag() == null);
    try std.testing.expect(std.mem.eql(u8, reader.nextPositional().?, "-"));
    try std.testing.expect(std.mem.eql(u8, reader.nextPositional().?, "0"));
    try std.testing.expect(reader.nextPositional() == null);
}

test "gracefully handle empty string" {
    var args = [_][]const u8{ "-a", "", "0" };
    var reader = SliceArgReader.init(args[0..]);

    try std.testing.expect(reader.nextFlag().? == 'a');
    try std.testing.expect(reader.nextFlag() == null);
    try std.testing.expect(std.mem.eql(u8, reader.nextPositional().?, ""));
    try std.testing.expect(std.mem.eql(u8, reader.nextPositional().?, "0"));
    try std.testing.expect(reader.nextPositional() == null);
}