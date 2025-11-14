const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    const file = try std.fs.cwd().openFile("src/data/day21.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day21:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u128 {
    var last: u8 = 10;
    var i: usize = 0;
    var sum: u128 = 0;
    var len: u128 = 0;
    var num: usize = 0;
    var map = std.AutoHashMap(u128, u128).init(alloc);
    defer map.deinit();
    while (i < input.len) {
        var button: u8 = undefined;
        switch (input[i]) {
            '0'...'9' => {
                button = input[i] - '0';
                num = num * 10 + button;
            },
            'A' => {
                button = 10;
            },
            else => {
                i += 2;
                sum += num * len;
                num = 0;
                len = 0;
                continue;
            },
        }

        len += try getLen(&map, keypad_paths[last][button], 2);
        last = button;

        i += 1;
    }

    return sum;
}

fn getLen(map: *std.AutoHashMap(u128, u128), paths: [2]?[]const u8, depth: u8) std.mem.Allocator.Error!u128 {
    var left: u128 = std.math.maxInt(u128);
    var right: u128 = std.math.maxInt(u128);
    if (paths[0]) |p| {
        left = try createMap(map, p, depth);
    }
    if (paths[1]) |p| {
        right = try createMap(map, p, depth);
    }
    return @min(left, right);
}

fn createMap(map: *std.AutoHashMap(u128, u128), path: []const u8, depth: u8) std.mem.Allocator.Error!u128 {
    if (depth == 0) return path.len;
    var key: u128 = 0;
    for (path) |p| {
        key = key << 4 | p;
    }
    key = key << 4 | depth;
    if (map.get(key)) |found| return found;

    var last: u8 = 0;
    var len: u128 = 0;
    for (path) |next| {
        const r_paths = remote_paths[last][next];
        len += try getLen(map, r_paths, depth - 1);
        last = next;
    }

    try map.put(key, len);

    return len;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u256 {
    var last: u8 = 10;
    var i: usize = 0;
    var sum: u128 = 0;
    var len: u128 = 0;
    var num: usize = 0;
    var map = std.AutoHashMap(u128, u128).init(alloc);
    defer map.deinit();
    while (i < input.len) {
        var button: u8 = undefined;
        switch (input[i]) {
            '0'...'9' => {
                button = input[i] - '0';
                num = num * 10 + button;
            },
            'A' => {
                button = 10;
            },
            else => {
                i += 2;
                sum += num * len;
                num = 0;
                len = 0;
                continue;
            },
        }

        len += try getLen(&map, keypad_paths[last][button], 25);
        last = button;

        i += 1;
    }

    return sum;
}
const keypad_paths: [11][11][2]?[]const u8 = .{
    .{ //0
        .{ &.{0}, null },
        .{ &.{ 1, 3, 0 }, null },
        .{ &.{ 1, 0 }, null },
        .{ &.{ 1, 4, 0 }, &.{ 4, 1, 0 } },
        .{ &.{ 1, 1, 3, 0 }, null },
        .{ &.{ 1, 1, 0 }, null },
        .{ &.{ 1, 1, 4, 0 }, &.{ 4, 1, 1, 0 } },
        .{ &.{ 1, 1, 1, 3, 0 }, null },
        .{ &.{ 1, 1, 1, 0 }, null },
        .{ &.{ 1, 1, 1, 4, 0 }, &.{ 4, 1, 1, 1, 0 } },
        .{ &.{ 4, 0 }, null },
    },
    .{ //1
        .{ &.{ 4, 2, 0 }, null },
        .{ &.{0}, null },
        .{ &.{ 4, 0 }, null },
        .{ &.{ 4, 4, 0 }, null },
        .{ &.{ 1, 0 }, null },
        .{ &.{ 1, 4, 0 }, &.{ 4, 1, 0 } },
        .{ &.{ 1, 4, 4, 0 }, &.{ 4, 4, 1, 0 } },
        .{ &.{ 1, 1, 0 }, null },
        .{ &.{ 1, 1, 4, 0 }, &.{ 4, 1, 1, 0 } },
        .{ &.{ 1, 1, 4, 4, 0 }, &.{ 4, 4, 1, 1, 0 } },
        .{ &.{ 4, 4, 2, 0 }, null },
    },
    .{ //2
        .{ &.{ 2, 0 }, null },
        .{ &.{ 3, 0 }, null },
        .{ &.{0}, null },
        .{ &.{ 4, 0 }, null },
        .{ &.{ 1, 3, 0 }, null },
        .{ &.{ 1, 0 }, null },
        .{ &.{ 1, 4, 0 }, &.{ 4, 1, 0 } },
        .{ &.{ 1, 1, 3, 0 }, &.{ 3, 1, 1, 0 } },
        .{ &.{ 1, 1, 0 }, null },
        .{ &.{ 1, 1, 4, 0 }, &.{ 4, 1, 1, 0 } },
        .{ &.{ 4, 2, 0 }, null },
    },
    .{ //3
        .{ &.{ 3, 2, 0 }, &.{ 2, 3, 0 } },
        .{ &.{ 3, 3, 0 }, null },
        .{ &.{ 3, 0 }, null },
        .{ &.{0}, null },
        .{ &.{ 1, 3, 3, 0 }, &.{ 3, 3, 1, 0 } },
        .{ &.{ 1, 3, 0 }, &.{ 3, 1, 0 } },
        .{ &.{ 1, 0 }, null },
        .{ &.{ 1, 1, 3, 3, 0 }, &.{ 3, 3, 1, 1, 0 } },
        .{ &.{ 1, 1, 3, 0 }, &.{ 3, 1, 1, 0 } },
        .{ &.{ 1, 1, 0 }, null },
        .{ &.{ 2, 0 }, null },
    },
    .{ //4
        .{ &.{ 4, 2, 2, 0 }, null },
        .{ &.{ 2, 0 }, null },
        .{ &.{ 4, 2, 0 }, &.{ 2, 4, 0 } },
        .{ &.{ 4, 4, 2, 0 }, &.{ 2, 4, 4, 0 } },
        .{ &.{0}, null },
        .{ &.{ 4, 0 }, null },
        .{ &.{ 4, 4, 0 }, null },
        .{ &.{ 1, 0 }, null },
        .{ &.{ 1, 4, 0 }, &.{ 4, 1, 0 } },
        .{ &.{ 1, 4, 4, 0 }, &.{ 4, 4, 1, 0 } },
        .{ &.{ 4, 4, 2, 2, 0 }, null },
    },
    .{ //5
        .{ &.{ 2, 2, 0 }, null },
        .{ &.{ 3, 2, 0 }, &.{ 2, 3, 0 } },
        .{ &.{ 2, 0 }, null },
        .{ &.{ 4, 2, 0 }, &.{ 4, 2, 0 } },
        .{ &.{ 3, 0 }, null },
        .{ &.{0}, null },
        .{ &.{ 4, 0 }, null },
        .{ &.{ 1, 3, 0 }, &.{ 3, 1, 0 } },
        .{ &.{ 1, 0 }, null },
        .{ &.{ 1, 4, 0 }, &.{ 4, 1, 0 } },
        .{ &.{ 4, 2, 2, 0 }, null },
    },
    .{ //6
        .{ &.{ 3, 2, 2, 0 }, &.{ 2, 2, 3, 0 } },
        .{ &.{ 3, 3, 2, 0 }, &.{ 2, 3, 3, 0 } },
        .{ &.{ 3, 2, 0 }, &.{ 2, 3, 0 } },
        .{ &.{ 2, 0 }, null },
        .{ &.{ 3, 3, 0 }, null },
        .{ &.{ 3, 0 }, null },
        .{ &.{0}, null },
        .{ &.{ 1, 3, 3, 0 }, &.{ 3, 3, 1, 0 } },
        .{ &.{ 1, 3, 0 }, &.{ 3, 1, 0 } },
        .{ &.{ 1, 0 }, null },
        .{ &.{ 2, 2, 0 }, null },
    },
    .{ //7
        .{ &.{ 4, 2, 2, 2, 0 }, null },
        .{ &.{ 2, 2, 0 }, null },
        .{ &.{ 2, 2, 4, 0 }, &.{ 4, 2, 2, 0 } },
        .{ &.{ 2, 2, 4, 4, 0 }, &.{ 4, 4, 2, 2, 0 } },
        .{ &.{ 2, 0 }, null },
        .{ &.{ 4, 2, 0 }, &.{ 2, 4, 0 } },
        .{ &.{ 4, 4, 2, 0 }, &.{ 2, 4, 4, 0 } },
        .{ &.{0}, null },
        .{ &.{ 4, 0 }, null },
        .{ &.{ 4, 4, 0 }, null },
        .{ &.{ 4, 4, 2, 2, 2, 0 }, null },
    },
    .{ //8
        .{ &.{ 2, 2, 2, 0 }, null },
        .{ &.{ 2, 2, 3, 0 }, &.{ 3, 2, 2, 0 } },
        .{ &.{ 2, 2, 0 }, null },
        .{ &.{ 2, 2, 4, 0 }, &.{ 4, 2, 2, 0 } },
        .{ &.{ 3, 2, 0 }, &.{ 2, 3, 0 } },
        .{ &.{ 2, 0 }, null },
        .{ &.{ 4, 2, 0 }, &.{ 4, 2, 0 } },
        .{ &.{ 3, 0 }, null },
        .{ &.{0}, null },
        .{ &.{ 4, 0 }, null },
        .{ &.{ 4, 2, 2, 2, 0 }, null },
    },
    .{ //9
        .{ &.{ 3, 2, 2, 2, 0 }, &.{ 2, 2, 2, 3, 0 } },
        .{ &.{ 3, 3, 2, 2, 0 }, &.{ 2, 2, 3, 3, 0 } },
        .{ &.{ 3, 2, 2, 0 }, &.{ 2, 2, 3, 0 } },
        .{ &.{ 2, 0 }, null },
        .{ &.{ 2, 3, 3, 0 }, &.{ 3, 3, 2, 0 } },
        .{ &.{ 2, 3, 0 }, &.{ 3, 2, 0 } },
        .{ &.{ 2, 0 }, null },
        .{ &.{ 3, 3, 0 }, null },
        .{ &.{ 3, 0 }, null },
        .{ &.{0}, null },
        .{ &.{ 2, 2, 2, 0 }, null },
    },
    .{ //A
        .{ &.{ 3, 0 }, null },
        .{ &.{ 1, 3, 3, 0 }, null },
        .{ &.{ 1, 3, 0 }, &.{ 3, 1, 0 } },
        .{ &.{ 1, 0 }, null },
        .{ &.{ 1, 1, 3, 3, 0 }, null },
        .{ &.{ 1, 1, 3, 0 }, &.{ 3, 1, 1, 0 } },
        .{ &.{ 1, 1, 0 }, null },
        .{ &.{ 1, 1, 1, 3, 3, 0 }, null },
        .{ &.{ 1, 1, 1, 3, 0 }, &.{ 3, 1, 1, 1, 0 } },
        .{ &.{ 1, 1, 1, 0 }, null },
        .{ &.{0}, null },
    },
};

const remote_paths: [5][5][2]?[]const u8 = .{
    .{
        .{ &.{0}, null },
        .{ &.{ 3, 0 }, null },
        .{ &.{ 3, 2, 0 }, &.{ 2, 3, 0 } },
        .{ &.{ 2, 3, 3, 0 }, null },
        .{ &.{ 2, 0 }, null },
    },
    .{
        .{ &.{ 4, 0 }, null },
        .{ &.{0}, null },
        .{ &.{ 2, 0 }, null },
        .{ &.{ 2, 3, 0 }, null },
        .{ &.{ 2, 4, 0 }, &.{ 4, 2, 0 } },
    },
    .{
        .{ &.{ 4, 1, 0 }, &.{ 1, 4, 0 } },
        .{ &.{ 1, 0 }, null },
        .{ &.{0}, null },
        .{ &.{ 3, 0 }, null },
        .{ &.{ 4, 0 }, null },
    },
    .{
        .{ &.{ 4, 4, 1, 0 }, null },
        .{ &.{ 4, 1, 0 }, null },
        .{ &.{ 4, 0 }, null },
        .{ &.{0}, null },
        .{ &.{ 4, 4, 0 }, null },
    },
    .{
        .{ &.{ 1, 0 }, null },
        .{ &.{ 3, 1, 0 }, &.{ 1, 3, 0 } },
        .{ &.{ 3, 0 }, null },
        .{ &.{ 3, 3, 0 }, null },
        .{ &.{0}, null },
    },
};
