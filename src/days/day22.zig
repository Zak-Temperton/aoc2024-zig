const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day22.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = part1(buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day22:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn readInt(comptime T: type, input: []const u8, i: *usize) T {
    var num: T = 0;
    while (i.* < input.len) : (i.* += 1) {
        switch (input[i.*]) {
            '0'...'9' => |c| num = num * 10 + c - '0',
            else => return num,
        }
    }
    return num;
}

fn part1(input: []const u8) u64 {
    var i: usize = 0;
    var sum: u64 = 0;
    while (i < input.len) {
        var num = readInt(u24, input, &i);
        for (0..2000) |_| {
            num ^= num << 6;
            num ^= num >> 5;
            num ^= num << 11;
        }
        sum += num;

        i += 2;
    }
    return sum;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u64 {
    var i: usize = 0;
    var sums = std.AutoHashMap(u20, u64).init(alloc);
    defer sums.deinit();
    var seen = std.ArrayList(u20).init(alloc);
    defer seen.deinit();
    while (i < input.len) {
        seen.clearRetainingCapacity();
        var num = readInt(u24, input, &i);
        var last: u8 = @truncate(num % 10);
        var key: u20 = 0;
        for (0..2000) |j| {
            num ^= num << 6;
            num ^= num >> 5;
            num ^= num << 11;
            const rem = @as(u8, @intCast(num % 10));
            const change = rem + 10 - last;
            key = key << 5 | change;
            if (j > 3 and !std.mem.containsAtLeast(u20, seen.items, 1, &.{key})) {
                try seen.append(key);
                const result = try sums.getOrPut(key);
                if (result.found_existing) {
                    result.value_ptr.* += rem;
                } else {
                    result.value_ptr.* = rem;
                }
            }
            last = rem;
        }
        i += 2;
    }
    var max: u64 = 0;
    var iter = sums.valueIterator();
    while (iter.next()) |next| {
        if (next.* > max) max = next.*;
    }

    return max;
}
