const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    const file = try std.fs.cwd().openFile("src/data/day25.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.read();
    try stdout.print("Day25:\n  part1: {d} {d}ns\n", .{ p1, p1_time });
}

fn part1(alloc: std.mem.Allocator, input: []u8) !u32 {
    var keys = try std.ArrayList(u64).initCapacity(alloc, 500);
    defer keys.deinit(alloc);

    var i: usize = 0;
    while (i < input.len) {
        var key: u64 = 0;
        for (0..7) |j| {
            for (0..5) |k| {
                if (input[i + k] == '#') {
                    key |= @as(u64, 1) << @truncate((j * 5) + k);
                }
            }
            i += 7;
        }
        try keys.append(alloc, key);
        i += 2;
    }

    var count: u32 = 0;
    for (keys.items, 0..) |key1, k| {
        for (keys.items[k + 1 ..]) |key2| {
            if (key1 & key2 == 0) count += 1;
        }
    }
    return count;
}
