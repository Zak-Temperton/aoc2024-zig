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

fn trailScore(map: []const std.ArrayList(u8), x: usize, y: usize, cur: u8, nines: *std.ArrayList([2]usize)) !void {
    if (x > 0) {
        if (map[y].items[x - 1] == 9 and cur == 8) {
            var found = false;
            for (nines.items) |nine| {
                if (nine[0] == x - 1 and nine[1] == y) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                try nines.append(.{ x - 1, y });
            }
        } else if (map[y].items[x - 1] == cur + 1) {
            try trailScore(map, x - 1, y, cur + 1, nines);
        }
    }
    if (x < map.len - 1) {
        if (map[y].items[x + 1] == 9 and cur == 8) {
            var found = false;
            for (nines.items) |nine| {
                if (nine[0] == x + 1 and nine[1] == y) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                try nines.append(.{ x + 1, y });
            }
        } else if (map[y].items[x + 1] == cur + 1) {
            try trailScore(map, x + 1, y, cur + 1, nines);
        }
    }
    if (y > 0) {
        if (map[y - 1].items[x] == 9 and cur == 8) {
            var found = false;
            for (nines.items) |nine| {
                if (nine[0] == x and nine[1] == y - 1) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                try nines.append(.{ x, y - 1 });
            }
        } else if (map[y - 1].items[x] == cur + 1) {
            try trailScore(map, x, y - 1, cur + 1, nines);
        }
    }
    if (y < map.len - 1) {
        if (map[y + 1].items[x] == 9 and cur == 8) {
            var found = false;
            for (nines.items) |nine| {
                if (nine[0] == x and nine[1] == y + 1) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                try nines.append(.{ x, y + 1 });
            }
        } else if (map[y + 1].items[x] == cur + 1) {
            try trailScore(map, x, y + 1, cur + 1, nines);
        }
    }
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

    var nines = std.ArrayList([2]usize).init(alloc);
    defer nines.deinit();

    var sum: usize = 0;
    for (map.items, 0..) |row, y| {
        for (row.items, 0..) |item, x| {
            if (item == 0) {
                nines.clearAndFree();
                try trailScore(map.items, x, y, 0, &nines);
                sum += nines.items.len;
            }
        }
    }
    return sum;
}

fn trailScore2(map: []const std.ArrayList(u8), x: usize, y: usize, cur: u8) u32 {
    var nines: u32 = 0;
    if (x > 0) {
        if (map[y].items[x - 1] == 9 and cur == 8) {
            nines += 1;
        } else if (map[y].items[x - 1] == cur + 1) {
            nines += trailScore2(map, x - 1, y, cur + 1);
        }
    }
    if (x < map.len - 1) {
        if (map[y].items[x + 1] == 9 and cur == 8) {
            nines += 1;
        } else if (map[y].items[x + 1] == cur + 1) {
            nines += trailScore2(map, x + 1, y, cur + 1);
        }
    }
    if (y > 0) {
        if (map[y - 1].items[x] == 9 and cur == 8) {
            nines += 1;
        } else if (map[y - 1].items[x] == cur + 1) {
            nines += trailScore2(map, x, y - 1, cur + 1);
        }
    }
    if (y < map.len - 1) {
        if (map[y + 1].items[x] == 9 and cur == 8) {
            nines += 1;
        } else if (map[y + 1].items[x] == cur + 1) {
            nines += trailScore2(map, x, y + 1, cur + 1);
        }
    }
    return nines;
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
                sum += trailScore2(map.items, x, y, 0);
            }
        }
    }
    return sum;
}
