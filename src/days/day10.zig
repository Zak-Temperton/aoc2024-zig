const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day10.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day10:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    var map = std.ArrayList(std.ArrayList(u8)).init(alloc);
    try map.append(std.ArrayList(u8).init(alloc));
    defer {
        for (map.items) |row| {
            row.deinit();
        }
        map.deinit();
    }
    var nine_count: u32 = 0;
    for (input) |c| {
        switch (c) {
            '0'...'8' => {
                try map.items[map.items.len - 1].append(c - '0');
            },
            '9' => {
                nine_count += 1;
                try map.items[map.items.len - 1].append(c - '0');
            },
            '\n' => {
                try map.append(std.ArrayList(u8).init(alloc));
            },
            else => {},
        }
    }
    _ = map.pop();
    const nines = try alloc.alloc(?u32, nine_count);

    var sum: usize = 0;
    for (map.items, 0..) |row, y| {
        for (row.items, 0..) |item, x| {
            if (item == 0) {
                @memset(nines, null);
                trailScore(map.items, x, y, 0, nines);
                for (nines) |nine| {
                    if (nine) |_| {
                        sum += 1;
                    }
                }
            }
        }
    }
    return sum;
}

fn trailScore(map: []const std.ArrayList(u8), x: usize, y: usize, cur: u8, nines: []?u32) void {
    if (x > 0) {
        score(map, x - 1, y, cur, nines);
    }
    if (x < map.len - 1) {
        score(map, x + 1, y, cur, nines);
    }
    if (y > 0) {
        score(map, x, y - 1, cur, nines);
    }
    if (y < map.len - 1) {
        score(map, x, y + 1, cur, nines);
    }
}

fn score(map: []const std.ArrayList(u8), x: usize, y: usize, cur: u8, nines: []?u32) void {
    if (map[y].items[x] == 9 and cur == 8) {
        const xy: u32 = @truncate(x * 100 | y);
        for (nines) |*nine| {
            if (nine.*) |n| {
                if (n == xy) {
                    return;
                }
            } else {
                nine.* = xy;
                return;
            }
        }
    } else if (map[y].items[x] == cur + 1) {
        trailScore(map, x, y, cur + 1, nines);
    }
}

fn score2(map: []const std.ArrayList(u8), x: usize, y: usize, cur: u8, nines: *u32) void {
    if (map[y].items[x] == cur + 1) {
        if (map[y].items[x] == 9) {
            nines.* += 1;
        }
        trailScore2(map, x, y, cur + 1, nines);
        return;
    }
    return;
}

fn trailScore2(map: []const std.ArrayList(u8), x: usize, y: usize, cur: u8, nines: *u32) void {
    if (x > 0) {
        score2(map, x - 1, y, cur, nines);
    }
    if (x < map.len - 1) {
        score2(map, x + 1, y, cur, nines);
    }
    if (y > 0) {
        score2(map, x, y - 1, cur, nines);
    }
    if (y < map.len - 1) {
        score2(map, x, y + 1, cur, nines);
    }
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var map = std.ArrayList(std.ArrayList(u8)).init(alloc);
    try map.append(std.ArrayList(u8).init(alloc));
    defer {
        for (map.items) |row| {
            row.deinit();
        }
        map.deinit();
    }

    for (input) |c| {
        switch (c) {
            '0'...'9' => {
                try map.items[map.items.len - 1].append(c - '0');
            },
            '\n' => {
                try map.append(std.ArrayList(u8).init(alloc));
            },
            else => {},
        }
    }
    _ = map.pop();

    var sum: u32 = 0;
    for (map.items, 0..) |row, y| {
        for (row.items, 0..) |item, x| {
            if (item == 0) {
                trailScore2(map.items, x, y, 0, &sum);
            }
        }
    }
    return sum;
}
