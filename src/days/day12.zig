const std = @import("std");

const ONE: u256 = 1;

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day12.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day12:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn getCost(input: []const u8, checked: []u256, char: u8, x: usize, y: usize, width: usize, area: *u32, perimeter: *u32) void {
    if (checked[y] & (ONE << @truncate(x)) == 0) {
        checked[y] |= ONE << @truncate(x);
        area.* += 1;
        if (x > 0) {
            if (input[(x - 1) + y * (width + 2)] == char) {
                getCost(input, checked, char, x - 1, y, width, area, perimeter);
            } else {
                perimeter.* += 1;
            }
        } else {
            perimeter.* += 1;
        }
        if (x < width - 1) {
            if (input[(x + 1) + y * (width + 2)] == char) {
                getCost(input, checked, char, x + 1, y, width, area, perimeter);
            } else {
                perimeter.* += 1;
            }
        } else {
            perimeter.* += 1;
        }
        if (y > 0) {
            if (input[x + (y - 1) * (width + 2)] == char) {
                getCost(input, checked, char, x, y - 1, width, area, perimeter);
            } else {
                perimeter.* += 1;
            }
        } else {
            perimeter.* += 1;
        }
        if (y < width - 1) {
            if (input[x + (y + 1) * (width + 2)] == char) {
                getCost(input, checked, char, x, y + 1, width, area, perimeter);
            } else {
                perimeter.* += 1;
            }
        } else {
            perimeter.* += 1;
        }
    }
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var width: usize = 0;
    for (input, 0..) |c, i| {
        if (c == '\r') {
            width = i;
            break;
        }
    }
    const checked = try alloc.alloc(u256, width);
    defer alloc.free(checked);
    @memset(checked, 0);
    var sum: u32 = 0;

    for (0..width) |x| {
        for (0..width) |y| {
            if (checked[y] & (ONE << @truncate(x)) == 0) {
                var perimeter: u32 = 0;
                var area: u32 = 0;
                getCost(input, checked, input[x + y * (width + 2)], x, y, width, &area, &perimeter);
                sum += area * perimeter;
            }
        }
    }

    return sum;
}

fn getCost2(input: []const u8, checked: []u256, char: u8, x: usize, y: usize, width: usize, area: *u32, sides: *u32) void {
    if (checked[y] & (ONE << @truncate(x)) == 0) {
        checked[y] |= ONE << @truncate(x);
        area.* += 1;
        if (x > 0) {
            if (input[(x - 1) + y * (width + 2)] == char) {
                getCost2(input, checked, char, x - 1, y, width, area, sides);
            } else if (y == 0 or input[x + (y - 1) * (width + 2)] != char) {
                sides.* += 1;
            } else if (y > 0 and input[(x - 1) + (y - 1) * (width + 2)] == char) {
                sides.* += 1;
            }
        } else if (y == 0 or input[x + (y - 1) * (width + 2)] != char) {
            sides.* += 1;
        }
        if (x < width - 1) {
            if (input[(x + 1) + y * (width + 2)] == char) {
                getCost2(input, checked, char, x + 1, y, width, area, sides);
            } else if (y == width - 1 or input[x + (y + 1) * (width + 2)] != char) {
                sides.* += 1;
            } else if (y < width - 1 and input[(x + 1) + (y + 1) * (width + 2)] == char) {
                sides.* += 1;
            }
        } else if (y == width - 1 or input[x + (y + 1) * (width + 2)] != char) {
            sides.* += 1;
        }
        if (y > 0) {
            if (input[x + (y - 1) * (width + 2)] == char) {
                getCost2(input, checked, char, x, y - 1, width, area, sides);
            } else if (x == width - 1 or input[(x + 1) + y * (width + 2)] != char) {
                sides.* += 1;
            } else if (x < width - 1 and input[(x + 1) + (y - 1) * (width + 2)] == char) {
                sides.* += 1;
            }
        } else if (x == width - 1 or input[(x + 1) + y * (width + 2)] != char) {
            sides.* += 1;
        }
        if (y < width - 1) {
            if (input[x + (y + 1) * (width + 2)] == char) {
                getCost2(input, checked, char, x, y + 1, width, area, sides);
            } else if (x == 0 or input[(x - 1) + y * (width + 2)] != char) {
                sides.* += 1;
            } else if (x > 0 and input[(x - 1) + (y + 1) * (width + 2)] == char) {
                sides.* += 1;
            }
        } else if (x == 0 or input[(x - 1) + y * (width + 2)] != char) {
            sides.* += 1;
        }
    }
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var width: usize = 0;
    for (input, 0..) |c, i| {
        if (c == '\r') {
            width = i;
            break;
        }
    }
    const checked = try alloc.alloc(u256, width);
    defer alloc.free(checked);
    @memset(checked, 0);
    var sum: u32 = 0;

    for (0..width) |x| {
        for (0..width) |y| {
            if (checked[y] & (ONE << @truncate(x)) == 0) {
                var sides: u32 = 0;
                var area: u32 = 0;
                getCost2(input, checked, input[x + y * (width + 2)], x, y, width, &area, &sides);
                sum += area * sides;
            }
        }
    }

    return sum;
}
