const std = @import("std");
const c = @cImport({
    @cInclude("sys/stat.h");
});
const mode_t = c.mode_t;
const expect = std.testing.expect;

pub fn getUmask() mode_t {
    var mask: mode_t = c.umask(0);
    _ = c.umask(mask);
    return mask;
}

pub fn parseMode(str: []const u8, base: mode_t, mask: mode_t) !mode_t {
    if (std.fmt.parseInt(mode_t, str, 8) catch null) |octal| {
        if (0 <= octal and octal <= 0o777)
            return octal;
    }

    // Otherwise, the string is a symbolc mode.

    var mode: mode_t = base;
    var who: mode_t = 0;
    var perm: mode_t = 0;
    var clear: mode_t = 0;
    var op: u8 = 0;

    var i: usize = 0;
    next_mode: while (i < str.len) {
        // parse user selector - [ugoa...]
        who = 0;
        while (i < str.len) {
            switch (str[i]) {
                'u' => who |= c.S_IRWXU | c.S_ISUID,
                'g' => who |= c.S_IRWXG | c.S_ISGID,
                'o' => who |= c.S_IRWXO,
                'a' => who |= c.S_IRWXU | c.S_ISUID | c.S_IRWXG | c.S_ISGID | c.S_IRWXO,
                else => break,
            }
            i += 1;
        }
        if (who != 0) {
            clear = who;
        } else {
            clear = c.S_ISUID | c.S_ISGID | c.S_ISVTX | c.S_IRWXU | c.S_IRWXG | c.S_IRWXO;
            who = ~mask;
        }

        while (i < str.len) {
            // parse operation - [-+=]
            switch (str[i]) {
                '=', '+', '-' => op = str[i],
                else => return error.InvalidMode,
            }

            // parse mode bits - [rwxXst]* or [ugo]
            perm = 0;
            i += 1;
            switch (str[i]) {
                'u' => {
                    // Copy user permission.
                    if (mode & c.S_IRUSR != 0) perm |= c.S_IRUSR | c.S_IRGRP | c.S_IROTH;
                    if (mode & c.S_IWUSR != 0) perm |= c.S_IWUSR | c.S_IWGRP | c.S_IWOTH;
                    if (mode & c.S_IXUSR != 0) perm |= c.S_IXUSR | c.S_IXGRP | c.S_IXOTH;
                    if (mode & c.S_ISUID != 0) perm |= c.S_ISUID | c.S_ISGID;
                    i += 1;
                },
                'g' => {
                    // Copy group permission.
                    if (mode & c.S_IRGRP != 0) perm |= c.S_IRUSR | c.S_IRGRP | c.S_IROTH;
                    if (mode & c.S_IWGRP != 0) perm |= c.S_IWUSR | c.S_IWGRP | c.S_IWOTH;
                    if (mode & c.S_IXGRP != 0) perm |= c.S_IXUSR | c.S_IXGRP | c.S_IXOTH;
                    if (mode & c.S_ISGID != 0) perm |= c.S_ISUID | c.S_ISGID;
                    i += 1;
                },
                'o' => {
                    // Copy 'other' permission.
                    if (mode & c.S_IROTH != 0) perm |= c.S_IRUSR | c.S_IRGRP | c.S_IROTH;
                    if (mode & c.S_IWOTH != 0) perm |= c.S_IWUSR | c.S_IWGRP | c.S_IWOTH;
                    if (mode & c.S_IXOTH != 0) perm |= c.S_IXUSR | c.S_IXGRP | c.S_IXOTH;
                    i += 1;
                },
                else => {
                    // Parse permission expression. (i.e. "rwx", "rw")
                    parse_perm_expr: while (i < str.len) {
                        switch (str[i]) {
                            'r' => perm |= c.S_IRUSR | c.S_IRGRP | c.S_IROTH,
                            'w' => perm |= c.S_IWUSR | c.S_IWGRP | c.S_IWOTH,
                            'x' => perm |= c.S_IXUSR | c.S_IXGRP | c.S_IXOTH,
                            'X' => {
                                if (c.S_ISDIR(mode) or mode & (c.S_IXUSR | c.S_IXGRP | c.S_IXOTH) != 0)
                                    perm |= c.S_IXUSR | c.S_IXGRP | c.S_IXOTH;
                            },
                            's' => perm |= c.S_ISUID | c.S_ISGID,
                            't' => perm |= c.S_ISVTX,
                            else => break :parse_perm_expr,
                        }
                        i += 1;
                    } // while
                }, // switch-else
            } // switch

            switch (op) {
                '=' => {
                    mode &= ~clear;
                    mode |= perm & who;
                },
                '+' => {
                    mode |= perm & who;
                },
                '-' => {
                    mode &= ~(perm & who);
                },
                else => return error.InvalidMode,
            }

            if (i < str.len and str[i] == ',') {
                i += 1;
                continue :next_mode;
            }
        } // while
    } // next_mode: while

    return mode & ~@intCast(mode_t, c.S_IFMT);
}

test "parseMode uses octal numbers as-is" {
    try expect(try parseMode("777", 0x111, 0x222) == 0o777);
    try expect(try parseMode("755", 0x111, 0x222) == 0o755);
    try expect(try parseMode("644", 0x111, 0x222) == 0o644);
    try expect(try parseMode("700", 0x111, 0x222) == 0o700);
}

test "parseMode understands user selectors" {
    try expect(try parseMode("u=x", 0, 0) == 0o100);
    try expect(try parseMode("g=x", 0, 0) == 0o010);
    try expect(try parseMode("o=x", 0, 0) == 0o001);

    try expect(try parseMode("ug=r", 0, 0) == 0o440);
    try expect(try parseMode("go=w", 0, 0) == 0o022);
    try expect(try parseMode("ou=x", 0, 0) == 0o101);

    try expect(try parseMode("ugo=w", 0, 0) == 0o222);

    try expect(try parseMode("a=x", 0, 0) == 0o111);
    try expect(try parseMode("=r", 0, 0) == 0o444);
}

test "parseMode supports ADD(+) operation" {
    try expect(try parseMode("u+r", 0o111, 0) == 0o511);
    try expect(try parseMode("g+w", 0o111, 0) == 0o131);
    try expect(try parseMode("o+x", 0o111, 0) == 0o111);
}

test "parseMode supports MINUS(+) operation" {
    try expect(try parseMode("u-w", 0o777, 0) == 0o577);
    try expect(try parseMode("g-x", 0o777, 0) == 0o767);
    try expect(try parseMode("o-r", 0o777, 0) == 0o773);
}

test "parseMode can parse multiple symbolic modes" {
    try expect(try parseMode("u+r,g+w,o+x", 0, 0) == 0o421);
}

test "parseMode can apply mask to the result" {
    try expect(try parseMode("+rwx", 0, 0o011) == 0o766);
}
