const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day19.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day19:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var i: usize = 0;
    var towels = std.ArrayList([]const u8).init(alloc);
    defer towels.deinit();
    var basics: [4]u8 = undefined;
    var b: usize = 0;
    while (i < input.len) {
        const start: usize = i;
        while (input[i] != ',' and input[i] != '\r') {
            i += 1;
        }
        if (i - start == 1) {
            basics[b] = input[start];
            b += 1;
        }
        try towels.append(input[start..i]);
        if (input[i] == '\r') {
            i += 3;
            break;
        }
        i += 2;
    }

    const key: u8 = 'r' ^ 'b' ^ 'w' ^ 'g' ^ 'u' ^ basics[0] ^ basics[1] ^ basics[2] ^ basics[3];

    var final_towels = std.ArrayList([]const u8).init(alloc);
    defer final_towels.deinit();

    std.mem.sortUnstable([]const u8, towels.items, {}, sortLen);

    for (towels.items[3..]) |towel| {
        if (!isValid(final_towels, towel, key)) {
            try final_towels.append(towel);
        }
    }
    var sum: u32 = 0;
    while (i < input.len) {
        const start: usize = i;
        while (input[i] != '\r') {
            i += 1;
        }
        if (isValid(final_towels, input[start..i], key)) {
            sum += 1;
        }
        i += 2;
    }
    return sum;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    _ = alloc; // autofix
    _ = input; // autofix
    return 0;
}

fn sortLen(_: void, lhs: []const u8, rhs: []const u8) bool {
    return lhs.len < rhs.len;
}

fn isValid(final_towels: std.ArrayList([]const u8), towel: []const u8, key: u8) bool {
    if (std.mem.containsAtLeast(u8, towel, 1, &.{key})) {
        next: for (final_towels.items) |ft| {
            if (ft.len < towel.len and std.mem.containsAtLeast(u8, towel, 1, ft)) {
                var iter = std.mem.splitSequence(u8, towel, ft);
                while (iter.next()) |next| {
                    if (next.len == 1 and next[0] == key) {
                        continue :next;
                    }
                    if (!isValid(final_towels, next, key)) {
                        continue :next;
                    }
                }
                return true;
            }
        }
        return false;
    }
    return true;
}
