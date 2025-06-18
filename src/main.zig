const std = @import("std");

pub fn main() !void {
    const out = std.io.getStdOut();
    var buf_out = std.io.bufferedWriter(out.writer());
    var w = buf_out.writer();

    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));

    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();

    const selection = [4][]const u8{
        "Burgers",
        "Chicken",
        "Chinese Food",
        "Jersey Mike's",
    };
    const selectionIndex = rand.intRangeAtMost(u8, 0, selection.len - 1);
    const food = selection[selectionIndex];

    try w.print("{s}?\n", .{food});
    try buf_out.flush();

    const in = std.io.getStdIn();
    var buf_in = std.io.bufferedReader(in.reader());

    var r = buf_in.reader();

    var msg_buf: [4096]u8 = undefined;
    const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

    if (msg) |m0| {
        var m = m0;
        if (m.len > 0 and (m[m.len - 1] == '\n' or m[m.len - 1] == '\r')) {
            m = m[0 .. m.len - 1];
        }

        if (m.len == 0) {
            try w.print("No input provided", .{});
            try buf_out.flush();
            return;
        }

        const choice = std.ascii.toLower(m[0]);
        switch (choice) {
            'y' => |_| {
                try w.print("We're eating {s} tonight!\n", .{food});
            },
            else => |_| {
                try w.print("Canceling selection\n", .{});
            },
        }

        try buf_out.flush();
    }
}
