const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    const file = try std.fs.cwd().openFile("src/data/day19.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day19:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn sortLen(_: void, lhs: []const u8, rhs: []const u8) bool {
    return lhs.len < rhs.len;
}

fn isValid(seen: *std.StringHashMap(bool), w_towels: [][]const u8, u_towels: [][]const u8, b_towels: [][]const u8, r_towels: [][]const u8, g_towels: [][]const u8, towel: []const u8) !bool {
    if (seen.get(towel)) |res| {
        return res;
    }
    const key = switch (towel[0]) {
        'w' => w_towels,
        'u' => u_towels,
        'b' => b_towels,
        'r' => r_towels,
        'g' => g_towels,
        else => return false,
    };
    for (key) |k| {
        if (k.len <= towel.len) {
            if (std.mem.eql(u8, k, towel[0..k.len])) {
                if (k.len == towel.len or try isValid(seen, w_towels, u_towels, b_towels, r_towels, g_towels, towel[k.len..])) {
                    try seen.put(towel, true);
                    return true;
                }
            }
        } else {
            break;
        }
    }
    try seen.put(towel, false);
    return false;
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var i: usize = 0;
    var w_towels = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    var u_towels = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    var b_towels = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    var r_towels = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    var g_towels = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    defer w_towels.deinit(alloc);
    defer u_towels.deinit(alloc);
    defer b_towels.deinit(alloc);
    defer r_towels.deinit(alloc);
    defer g_towels.deinit(alloc);
    var seen = std.StringHashMap(bool).init(alloc);
    defer seen.deinit();
    while (i < input.len) {
        const start: usize = i;
        while (input[i] != ',' and input[i] != '\r') {
            i += 1;
        }

        switch (input[start]) {
            'w' => try w_towels.append(alloc, input[start..i]),
            'u' => try u_towels.append(alloc, input[start..i]),
            'b' => try b_towels.append(alloc, input[start..i]),
            'r' => try r_towels.append(alloc, input[start..i]),
            'g' => try g_towels.append(alloc, input[start..i]),
            else => std.debug.print("{c}", .{input[start]}),
        }
        try seen.put(input[start..i], true);
        if (input[i] == '\r') {
            i += 4;
            break;
        }
        i += 2;
    }

    std.mem.sortUnstable([]const u8, w_towels.items, {}, sortLen);
    std.mem.sortUnstable([]const u8, u_towels.items, {}, sortLen);
    std.mem.sortUnstable([]const u8, b_towels.items, {}, sortLen);
    std.mem.sortUnstable([]const u8, r_towels.items, {}, sortLen);
    std.mem.sortUnstable([]const u8, g_towels.items, {}, sortLen);

    var sum: u32 = 0;
    while (i < input.len) {
        const start: usize = i;
        while (input[i] != '\r') {
            i += 1;
        }
        if (try isValid(&seen, w_towels.items, u_towels.items, b_towels.items, r_towels.items, g_towels.items, input[start..i])) {
            sum += 1;
        }
        i += 2;
    }
    return sum;
}

fn isValid2(seen: *std.StringHashMap(u64), w_towels: [][]const u8, u_towels: [][]const u8, b_towels: [][]const u8, r_towels: [][]const u8, g_towels: [][]const u8, towel: []const u8) !u64 {
    if (seen.get(towel)) |res| {
        return res;
    }
    const key = switch (towel[0]) {
        'w' => w_towels,
        'u' => u_towels,
        'b' => b_towels,
        'r' => r_towels,
        'g' => g_towels,
        else => unreachable,
    };
    var res: u64 = 0;
    for (key) |k| {
        if (k.len <= towel.len) {
            if (std.mem.eql(u8, k, towel[0..k.len])) {
                if (k.len == towel.len) {
                    res += 1;
                } else {
                    res += try isValid2(seen, w_towels, u_towels, b_towels, r_towels, g_towels, towel[k.len..]);
                }
            }
        }
    }
    try seen.put(towel, res);
    return res;
}
fn part2(alloc: std.mem.Allocator, input: []const u8) !u64 {
    var i: usize = 0;
    var w_towels = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    var u_towels = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    var b_towels = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    var r_towels = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    var g_towels = try std.ArrayList([]const u8).initCapacity(alloc, 0);
    defer w_towels.deinit(alloc);
    defer u_towels.deinit(alloc);
    defer b_towels.deinit(alloc);
    defer r_towels.deinit(alloc);
    defer g_towels.deinit(alloc);
    var seen = std.StringHashMap(u64).init(alloc);
    defer seen.deinit();
    while (i < input.len) {
        const start: usize = i;
        while (input[i] != ',' and input[i] != '\r') {
            i += 1;
        }

        switch (input[start]) {
            'w' => try w_towels.append(alloc, input[start..i]),
            'u' => try u_towels.append(alloc, input[start..i]),
            'b' => try b_towels.append(alloc, input[start..i]),
            'r' => try r_towels.append(alloc, input[start..i]),
            'g' => try g_towels.append(alloc, input[start..i]),
            else => std.debug.print("{c}", .{input[start]}),
        }
        if (input[i] == '\r') {
            i += 4;
            break;
        }
        i += 2;
    }

    std.mem.sortUnstable([]const u8, w_towels.items, {}, sortLen);
    std.mem.sortUnstable([]const u8, u_towels.items, {}, sortLen);
    std.mem.sortUnstable([]const u8, b_towels.items, {}, sortLen);
    std.mem.sortUnstable([]const u8, r_towels.items, {}, sortLen);
    std.mem.sortUnstable([]const u8, g_towels.items, {}, sortLen);

    var sum: u64 = 0;
    while (i < input.len) {
        const start: usize = i;
        while (input[i] != '\r') {
            i += 1;
        }
        sum += try isValid2(&seen, w_towels.items, u_towels.items, b_towels.items, r_towels.items, g_towels.items, input[start..i]);
        i += 2;
    }
    return sum;
}
