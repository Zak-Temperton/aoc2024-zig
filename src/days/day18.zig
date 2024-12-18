const std = @import("std");

const ONE: u71 = 1;

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day18.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day18:\n  part1: {d} {d}ns\n  part2: {d},{d} {d}ns\n", .{ p1, p1_time, p2[0], p2[1], p2_time });
}

fn readInt(comptime T: type, input: []const u8, i: *usize) T {
    var num: T = 0;
    while (i.* < input.len) : (i.* += 1) {
        switch (input[i.*]) {
            '0'...'9' => |c| num = num * 10 + @as(T, @truncate(c)) - '0',
            else => return num,
        }
    }
    return num;
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var map: [71]u71 = .{0} ** 71;
    var i: usize = 0;
    for (0..1024) |_| {
        const x = readInt(u7, input, &i);
        i += 1;
        const y = readInt(u7, input, &i);
        i += 2;
        map[y] |= @as(u71, 1) << x;
    }
    return traverse(alloc, &map);
}

fn traverse(alloc: std.mem.Allocator, map: []u71) !u32 {
    const Point = struct {
        x: u7,
        y: u7,
    };
    var states = std.ArrayList(Point).init(alloc);
    defer states.deinit();
    var new_states = std.ArrayList(Point).init(alloc);
    defer new_states.deinit();
    try states.append(Point{ .x = 0, .y = 0 });
    map[0] |= 1;
    var steps: u32 = 0;
    while (states.items.len > 0) : (steps += 1) {
        for (states.items) |state| {
            if (state.x == 70 and state.y == 70) {
                return steps;
            }
            if (state.x > 0 and map[state.y] >> (state.x - 1) & 1 == 0) {
                map[state.y] |= ONE << (state.x - 1);
                try new_states.append(Point{ .x = state.x - 1, .y = state.y });
            }
            if (state.x < 70 and map[state.y] >> (state.x + 1) & 1 == 0) {
                map[state.y] |= ONE << (state.x + 1);
                try new_states.append(Point{ .x = state.x + 1, .y = state.y });
            }
            if (state.y > 0 and map[state.y - 1] >> state.x & 1 == 0) {
                map[state.y - 1] |= ONE << state.x;
                try new_states.append(Point{ .x = state.x, .y = state.y - 1 });
            }
            if (state.y < 70 and map[state.y + 1] >> state.x & 1 == 0) {
                map[state.y + 1] |= ONE << state.x;
                try new_states.append(Point{ .x = state.x, .y = state.y + 1 });
            }
        }
        const tmp = states;
        states = new_states;
        new_states = tmp;
        new_states.clearRetainingCapacity();
    }
    return 0;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) ![2]u7 {
    var map: [71]u71 = .{0} ** 71;
    var i: usize = 0;
    for (0..1024) |_| {
        const x = readInt(u7, input, &i);
        i += 1;
        const y = readInt(u7, input, &i);
        i += 2;
        map[y] |= @as(u71, 1) << x;
    }
    var copy: [71]u71 = undefined;
    @memcpy(&copy, &map);
    _ = try traverse(alloc, &copy);

    var c: usize = 1024;
    while (i < input.len) : (c += 1) {
        const x = readInt(u7, input, &i);
        i += 1;
        const y = readInt(u7, input, &i);
        i += 2;

        if (copy[y] >> x & 1 == 1) {
            map[y] |= @as(u71, 1) << x;
            @memcpy(&copy, &map);
            if (try traverse(alloc, &copy) == 0) {
                return .{ x, y };
            }

            continue;
        }

        copy[y] |= @as(u71, 1) << x;
        map[y] |= @as(u71, 1) << x;
    }
    return .{ 0, 0 };
}
