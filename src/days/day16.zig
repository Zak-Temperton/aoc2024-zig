const std = @import("std");

const ONE: u256 = 1;

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day16.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day16:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

const Walker = struct {
    x: u32,
    y: u32,
    dir: u2,
    score: u32,
};

fn flood(alloc: std.mem.Allocator, map: []u256, scores: [][]u32) !u32 {
    var walkers = std.ArrayList(Walker).init(alloc);
    defer walkers.deinit();
    try walkers.append(Walker{ .x = 0, .y = @truncate(map.len - 1), .dir = 0, .score = 0 });
    var nextWalkers = std.ArrayList(Walker).init(alloc);
    defer nextWalkers.deinit();

    while (walkers.items.len > 0) {
        for (walkers.items) |walker| {
            if (map[walker.y] & ONE << @truncate(walker.x) == 0 and scores[walker.y][walker.x] >= walker.score) {
                scores[walker.y][walker.x] = walker.score;
                switch (walker.dir) {
                    0 => {
                        var newWalker = walker;
                        if (walker.x < map.len - 1) {
                            newWalker.x += 1;
                            newWalker.score += 1;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y < map.len - 1) {
                            newWalker = walker;
                            newWalker.dir = 1;
                            newWalker.y += 1;
                            newWalker.score += 1001;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y > 0) {
                            newWalker = walker;
                            newWalker.dir = 3;
                            newWalker.y -= 1;
                            newWalker.score += 1001;
                            try nextWalkers.append(newWalker);
                        }
                    },
                    1 => {
                        var newWalker = walker;
                        if (walker.x < map.len - 1) {
                            newWalker.dir = 0;
                            newWalker.x += 1;
                            newWalker.score += 1001;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y < map.len - 1) {
                            newWalker = walker;
                            newWalker.y += 1;
                            newWalker.score += 1;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.x > 0) {
                            newWalker = walker;
                            newWalker.dir = 2;
                            newWalker.x -= 1;
                            newWalker.score += 1001;
                            try nextWalkers.append(newWalker);
                        }
                    },
                    2 => {
                        var newWalker = walker;
                        if (walker.x > 0) {
                            newWalker.x -= 1;
                            newWalker.score += 1;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y < map.len - 1) {
                            newWalker = walker;
                            newWalker.dir = 1;
                            newWalker.y += 1;
                            newWalker.score += 1001;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y > 0) {
                            newWalker = walker;
                            newWalker.dir = 3;
                            newWalker.y -= 1;
                            newWalker.score += 1001;
                            try nextWalkers.append(newWalker);
                        }
                    },
                    3 => {
                        var newWalker = walker;
                        if (walker.x < map.len - 1) {
                            newWalker.dir = 0;
                            newWalker.x += 1;
                            newWalker.score += 1001;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y > 0) {
                            newWalker = walker;
                            newWalker.y -= 1;
                            newWalker.score += 1;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.x > 0) {
                            newWalker = walker;
                            newWalker.dir = 2;
                            newWalker.x -= 1;
                            newWalker.score += 1001;
                            try nextWalkers.append(newWalker);
                        }
                    },
                }
            }
        }
        const tmp = walkers;
        walkers = nextWalkers;
        nextWalkers = tmp;
        nextWalkers.clearRetainingCapacity();
    }
    return scores[0][map.len - 1];
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    var side: u32 = undefined;
    for (input, 0..) |c, i| {
        if (c == '\r') {
            side = @truncate(i - 2);
            break;
        }
    }
    const map: []u256 = try alloc.alloc(u256, side);
    defer alloc.free(map);
    @memset(map, 0);

    const scores = try alloc.alloc([]u32, map.len);
    for (scores) |*row| {
        row.* = try alloc.alloc(u32, map.len);
        @memset(row.*, std.math.maxInt(u32));
    }
    defer {
        for (scores) |*row| {
            alloc.free(row.*);
        }
        alloc.free(scores);
    }

    for (0..side) |y| {
        const row = &map[y];
        for (0..side) |x| {
            if (input[(x + 1) + (y + 1) * (side + 4)] == '#') {
                row.* |= ONE << @truncate(x);
            }
        }
    }
    return try flood(alloc, map, scores);
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !usize {
    var side: u32 = undefined;
    for (input, 0..) |c, i| {
        if (c == '\r') {
            side = @truncate(i - 2);
            break;
        }
    }
    const map: []u256 = try alloc.alloc(u256, side);
    defer alloc.free(map);
    @memset(map, 0);

    const scores = try alloc.alloc([]u32, map.len);
    for (scores) |*row| {
        row.* = try alloc.alloc(u32, map.len);
        @memset(row.*, std.math.maxInt(u32));
    }
    defer {
        for (scores) |*row| {
            alloc.free(row.*);
        }
        alloc.free(scores);
    }
    for (0..side) |y| {
        const row = &map[y];
        for (0..side) |x| {
            if (input[(x + 1) + (y + 1) * (side + 4)] == '#') {
                row.* |= ONE << @truncate(x);
            }
        }
    }
    const start = try flood(alloc, map, scores);

    const seats: []u256 = try alloc.alloc(u256, side);
    defer alloc.free(seats);
    @memset(seats, 0);

    var walkers = std.ArrayList(Walker).init(alloc);
    defer walkers.deinit();
    try walkers.append(Walker{ .x = @truncate(map.len - 1), .y = 1, .dir = 1, .score = start - 1 });
    try walkers.append(Walker{ .x = @truncate(map.len - 2), .y = 0, .dir = 2, .score = start - 1 });
    var nextWalkers = std.ArrayList(Walker).init(alloc);
    defer nextWalkers.deinit();

    var sum: u32 = 0;
    while (walkers.items.len > 0) {
        for (walkers.items) |walker| {
            if (walker.score > 0 and map[walker.y] >> @truncate(walker.x) & 1 == 0 and seats[walker.y] >> @truncate(walker.x) & 1 == 0 and scores[walker.y][walker.x] == walker.score) {
                sum += 1;
                seats[walker.y] |= ONE << @truncate(walker.x);
                switch (walker.dir) {
                    0 => {
                        var newWalker = walker;
                        if (walker.x < map.len - 1) {
                            newWalker.x += 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                            newWalker.score += 2000;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y < map.len - 1) {
                            newWalker = walker;
                            newWalker.dir = 1;
                            newWalker.y += 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y > 0) {
                            newWalker = walker;
                            newWalker.dir = 3;
                            newWalker.y -= 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                        }
                    },
                    1 => {
                        var newWalker = walker;
                        if (walker.x < map.len - 1) {
                            newWalker.dir = 0;
                            newWalker.x += 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y < map.len - 1) {
                            newWalker = walker;
                            newWalker.y += 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                            newWalker.score += 2000;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.x > 0) {
                            newWalker = walker;
                            newWalker.dir = 2;
                            newWalker.x -= 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                        }
                    },
                    2 => {
                        var newWalker = walker;
                        if (walker.x > 0) {
                            newWalker.x -= 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                            newWalker.score += 2000;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y < map.len - 1) {
                            newWalker = walker;
                            newWalker.dir = 1;
                            newWalker.y += 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y > 0) {
                            newWalker = walker;
                            newWalker.dir = 3;
                            newWalker.y -= 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                        }
                    },
                    3 => {
                        var newWalker = walker;
                        if (walker.x < map.len - 1) {
                            newWalker.dir = 0;
                            newWalker.x += 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.y > 0) {
                            newWalker = walker;
                            newWalker.y -= 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                        }
                        if (walker.x > 0) {
                            newWalker = walker;
                            newWalker.dir = 2;
                            newWalker.x -= 1;
                            newWalker.score -|= 1;
                            try nextWalkers.append(newWalker);
                            newWalker.score -|= 1000;
                            try nextWalkers.append(newWalker);
                            newWalker.score += 2000;
                            try nextWalkers.append(newWalker);
                        }
                    },
                }
            }
        }
        const tmp = walkers;
        walkers = nextWalkers;
        nextWalkers = tmp;
        nextWalkers.clearRetainingCapacity();
    }

    return sum + 2;
}
