const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day10.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = part2(buffer);
    const p2_time = timer.read();
    try stdout.print("Day10:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    var width: usize = 0;
    for (input, 0..) |c, i| {
        if (c == '\r') {
            width = i;
            break;
        }
    }

    var sum: usize = 0;
    const nines = try alloc.alloc(u32, width);
    defer alloc.free(nines);
    for (0..width) |x| {
        for (0..width) |y| {
            if (input[x + y * (width + 2)] == '0') {
                @memset(nines, 0);
                sum += trailScore(input, width, x, y, '0', nines);
            }
        }
    }

    return sum;
}

fn trailScore(input: []const u8, width: usize, x: usize, y: usize, cur: u8, nines: []u32) u32 {
    var sum: u32 = 0;
    if (x > 0) {
        sum += score(input, width, x - 1, y, cur, nines);
    }
    if (x < width - 1) {
        sum += score(input, width, x + 1, y, cur, nines);
    }
    if (y > 0) {
        sum += score(input, width, x, y - 1, cur, nines);
    }
    if (y < width - 1) {
        sum += score(input, width, x, y + 1, cur, nines);
    }
    return sum;
}

fn score(input: []const u8, width: usize, x: usize, y: usize, cur: u8, nines: []u32) u32 {
    if (input[x + y * (width + 2)] == '9' and cur == '8') {
        if ((nines[y] >> @truncate(x)) & 1 == 0) {
            nines[y] |= @as(u32, 1) << @truncate(x);
            return 1;
        }
    } else if (input[x + y * (width + 2)] == cur + 1) {
        return trailScore(input, width, x, y, cur + 1, nines);
    }
    return 0;
}

fn score2(input: []const u8, width: usize, x: usize, y: usize, cur: u8, nines: *u32) void {
    if (input[x + y * (width + 2)] == cur + 1) {
        if (input[x + y * (width + 2)] == '9') {
            nines.* += 1;
        }
        trailScore2(input, width, x, y, cur + 1, nines);
        return;
    }
    return;
}

fn trailScore2(input: []const u8, width: usize, x: usize, y: usize, cur: u8, nines: *u32) void {
    if (x > 0) {
        score2(input, width, x - 1, y, cur, nines);
    }
    if (x < width - 1) {
        score2(input, width, x + 1, y, cur, nines);
    }
    if (y > 0) {
        score2(input, width, x, y - 1, cur, nines);
    }
    if (y < width - 1) {
        score2(input, width, x, y + 1, cur, nines);
    }
}

fn part2(input: []const u8) u32 {
    var width: usize = 0;
    for (input, 0..) |c, i| {
        if (c == '\r') {
            width = i;
            break;
        }
    }

    var sum: u32 = 0;
    for (0..width) |x| {
        for (0..width) |y| {
            if (input[x + y * (width + 2)] == '0') {
                trailScore2(input, width, x, y, '0', &sum);
            }
        }
    }
    return sum;
}
