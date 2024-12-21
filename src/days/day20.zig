const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day20.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day20:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

const ONE: u256 = 1;

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var side: u32 = undefined;
    var start_x: u8 = 0;
    var start_y: u8 = 0;
    var end_x: u8 = 0;
    var end_y: u8 = 0;
    for (input, 0..) |c, i| {
        if (c == '\r') {
            side = @truncate(i - 2);
            break;
        }
    }
    const map = try alloc.alloc(u256, side);
    defer alloc.free(map);
    @memset(map, 0);
    for (0..side) |y| {
        const wall = &map[y];
        for (0..side) |x| {
            switch (input[(x + 1) + (y + 1) * (side + 4)]) {
                '#' => wall.* |= ONE << @truncate(x),
                'S' => {
                    start_x = @truncate(x);
                    start_y = @truncate(y);
                },
                'E' => {
                    end_x = @truncate(x);
                    end_y = @truncate(y);
                },
                else => {},
            }
        }
    }

    const path = try alloc.alloc([]u32, side);
    for (path) |*row| {
        row.* = try alloc.alloc(u32, side);
        @memset(row.*, 0);
    }
    defer {
        for (path) |row| {
            alloc.free(row);
        }
        alloc.free(path);
    }
    mapPath(map, path, start_x, start_y, end_x, end_y);

    return getShortcuts(path);
}

inline fn notWall(map: []u256, x: u8, y: u8) bool {
    return map[y] >> x & 1 == 0;
}

inline fn setWall(map: []u256, x: u8, y: u8) void {
    map[y] |= ONE << x;
}

fn mapPath(map: []u256, path: [][]u32, start_x: u8, start_y: u8, end_x: u8, end_y: u8) void {
    var x = start_x;
    var y = start_y;
    var i: u32 = 1;
    while (x != end_x or y != end_y) : (i += 1) {
        path[y][x] = i;
        setWall(map, x, y);
        if (x > 0 and notWall(map, x - 1, y)) {
            x -= 1;
        } else if (x < path.len - 1 and notWall(map, x + 1, y)) {
            x += 1;
        } else if (y > 0 and notWall(map, x, y - 1)) {
            y -= 1;
        } else if (y < path.len - 1 and notWall(map, x, y + 1)) {
            y += 1;
        }
    }
    path[y][x] = i;
}

fn getShortcuts(path: [][]u32) u32 {
    const min = 100 + 2;
    var cuts: u32 = 0;
    for (path, 0..) |row, y| {
        for (row, 0..) |num, x| {
            if (num == 0) {
                if (x > 0 and x < path.len - 1) {
                    const a = path[y][x - 1];
                    const b = path[y][x + 1];
                    if (a != 0 and b != 0) {
                        if (diff(a, b) >= min) {
                            cuts += 1;
                        }
                    }
                }
                if (y > 0 and y < path.len - 1) {
                    const a = path[y - 1][x];
                    const b = path[y + 1][x];
                    if (a != 0 and b != 0) {
                        if (diff(a, b) >= min) {
                            cuts += 1;
                        }
                    }
                }
            }
        }
    }
    return cuts;
}

inline fn diff(lhs: u32, rhs: u32) u32 {
    if (lhs < rhs) {
        return rhs - lhs;
    } else {
        return lhs - rhs;
    }
}

fn getShortcuts2(path: [][]u32) u32 {
    const min = 100;
    var cuts: u32 = 0;
    for (path, 0..) |row, y| {
        for (row, 0..) |num, x| {
            if (num > 0) {
                for (0..21) |xx| {
                    for (0..21 - xx) |yy| {
                        if (x >= xx and xx != 0) {
                            if (y >= yy and yy != 0) {
                                const a = path[y - yy][x - xx];
                                if (a > num and a - num >= min + xx + yy) {
                                    cuts += 1;
                                }
                            }
                            if (y + yy < path.len) {
                                const a = path[y + yy][x - xx];
                                if (a > num and a - num >= min + xx + yy) {
                                    cuts += 1;
                                }
                            }
                        }
                        if (x + xx < path.len) {
                            if (y >= yy and yy != 0) {
                                const a = path[y - yy][x + xx];
                                if (a > num and a - num >= min + xx + yy) {
                                    cuts += 1;
                                }
                            }
                            if (y + yy < path.len) {
                                const a = path[y + yy][x + xx];
                                if (a > num and a - num >= min + xx + yy) {
                                    cuts += 1;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return cuts;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var side: u32 = undefined;
    var start_x: u8 = 0;
    var start_y: u8 = 0;
    var end_x: u8 = 0;
    var end_y: u8 = 0;
    for (input, 0..) |c, i| {
        if (c == '\r') {
            side = @truncate(i - 2);
            break;
        }
    }
    const map = try alloc.alloc(u256, side);
    defer alloc.free(map);
    @memset(map, 0);
    for (0..side) |y| {
        const wall = &map[y];
        for (0..side) |x| {
            switch (input[(x + 1) + (y + 1) * (side + 4)]) {
                '#' => wall.* |= ONE << @truncate(x),
                'S' => {
                    start_x = @truncate(x);
                    start_y = @truncate(y);
                },
                'E' => {
                    end_x = @truncate(x);
                    end_y = @truncate(y);
                },
                else => {},
            }
        }
    }

    const path = try alloc.alloc([]u32, side);
    for (path) |*row| {
        row.* = try alloc.alloc(u32, side);
        @memset(row.*, 0);
    }
    defer {
        for (path) |row| {
            alloc.free(row);
        }
        alloc.free(path);
    }
    mapPath(map, path, start_x, start_y, end_x, end_y);

    return getShortcuts2(path);
}
