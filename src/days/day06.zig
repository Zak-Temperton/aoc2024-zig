const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    const file = try std.fs.cwd().openFile("src/data/day06.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day06:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn nextLine(input: []const u8, i: *usize) void {
    while (i.* < input.len and (input[i.*] == '\r' or input[i.*] == '\n')) : (i.* += 1) {}
}

const Dir = enum {
    up,
    down,
    left,
    right,
};

const ONE: u256 = 1;

const Guard = struct {
    x: u8,
    y: u8,
    dir: Dir,

    fn step(self: *Guard, map: []const u256, been: []u256) bool {
        been[self.y] |= ONE << self.x;
        switch (self.dir) {
            .up => {
                if (self.y == 0) return false;
                if (map[self.y - 1] & ONE << self.x == 0) {
                    self.y -= 1;
                } else {
                    self.dir = .right;
                    return self.step(map, been);
                }
            },
            .down => {
                if (self.y == map.len - 1) return false;
                if (map[self.y + 1] & ONE << self.x == 0) {
                    self.y += 1;
                } else {
                    self.dir = .left;
                    return self.step(map, been);
                }
            },
            .left => {
                if (self.x == 0) return false;
                if (map[self.y] & ONE << (self.x - 1) == 0) {
                    self.x -= 1;
                } else {
                    self.dir = .up;
                    return self.step(map, been);
                }
            },
            .right => {
                if (self.x == map.len - 1) return false;
                if (map[self.y] & ONE << (self.x + 1) == 0) {
                    self.x += 1;
                } else {
                    self.dir = .down;
                    return self.step(map, been);
                }
            },
        }
        return true;
    }

    fn equals(self: Guard, other: Guard) bool {
        return self.x == other.x and self.y == other.y and self.dir == other.dir;
    }

    fn testLoop(self: Guard, alloc: std.mem.Allocator, map: []const u256, been: []u256) !bool {
        var tmp_guard = self;
        var checks = try std.ArrayList(Guard).initCapacity(alloc, 2);
        defer checks.deinit(alloc);
        checks.appendAssumeCapacity(tmp_guard);
        const tmp_been: []u256 = try alloc.alloc(u256, been.len);
        defer alloc.free(tmp_been);
        @memcpy(tmp_been, been);
        var dir = tmp_guard.dir;
        while (tmp_guard.step(map, tmp_been)) {
            if (dir != tmp_guard.dir) {
                for (checks.items) |check| {
                    if (tmp_guard.equals(check)) {
                        return true;
                    }
                }
            } else {
                dir = tmp_guard.dir;
            }
            try checks.append(alloc, tmp_guard);
        }
        return false;
    }

    fn obstruct(self: *Guard, alloc: std.mem.Allocator, map: []u256, been: []u256) !bool {
        switch (self.dir) {
            .up => {
                if (self.y == 0) return false;
                if (map[self.y - 1] & ONE << self.x == 0) {
                    if (been[self.y - 1] & ONE << self.x == 0) {
                        map[self.y - 1] |= ONE << self.x;
                        const loop = try self.testLoop(alloc, map, been);
                        map[self.y - 1] ^= ONE << self.x;
                        return loop;
                    } else {
                        return false;
                    }
                } else {
                    self.dir = .right;
                    return try self.obstruct(alloc, map, been);
                }
            },
            .down => {
                if (self.y == map.len - 1) return false;
                if (map[self.y + 1] & ONE << self.x == 0) {
                    if (been[self.y + 1] & ONE << self.x == 0) {
                        map[self.y + 1] |= ONE << self.x;
                        const loop = try self.testLoop(alloc, map, been);
                        map[self.y + 1] ^= ONE << self.x;
                        return loop;
                    } else {
                        return false;
                    }
                } else {
                    self.dir = .left;
                    return try self.obstruct(alloc, map, been);
                }
            },
            .left => {
                if (self.x == 0) return false;
                if (map[self.y] & ONE << (self.x - 1) == 0) {
                    if (been[self.y] & ONE << (self.x - 1) == 0) {
                        map[self.y] |= ONE << (self.x - 1);
                        const loop = try self.testLoop(alloc, map, been);
                        map[self.y] ^= ONE << (self.x - 1);
                        return loop;
                    } else {
                        return false;
                    }
                } else {
                    self.dir = .up;
                    return try self.obstruct(alloc, map, been);
                }
            },
            .right => {
                if (self.x == map.len - 1) return false;
                if (map[self.y] & ONE << (self.x + 1) == 0) {
                    if (been[self.y] & ONE << (self.x + 1) == 0) {
                        map[self.y] |= ONE << (self.x + 1);
                        const loop = try self.testLoop(alloc, map, been);
                        map[self.y] ^= ONE << (self.x + 1);
                        return loop;
                    } else {
                        return false;
                    }
                } else {
                    self.dir = .down;
                    return try self.obstruct(alloc, map, been);
                }
            },
        }
    }
};

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var guard: Guard = undefined;
    var x: u8 = 0;
    var y: u8 = 0;
    var map = try std.ArrayList(u256).initCapacity(alloc, 1);
    defer map.deinit(alloc);
    map.appendAssumeCapacity(0);
    for (input) |value| {
        switch (value) {
            '.' => x += 1,
            '#' => {
                map.items[y] |= ONE << x;
                x += 1;
            },
            '\n' => {
                x = 0;
                y += 1;
                try map.append(alloc, 0);
            },
            '^' => {
                guard = Guard{ .x = x, .y = y, .dir = .up };
                x += 1;
            },
            else => {},
        }
    }
    _ = map.pop();
    const been = try alloc.alloc(u256, map.items.len);
    defer alloc.free(been);
    @memset(been, 0);

    while (guard.step(map.items, been)) {}
    var sum: u32 = 0;
    for (been) |val| {
        sum += @popCount(val);
    }
    return sum;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var guard: Guard = undefined;
    var x: u8 = 0;
    var y: u8 = 0;
    var map = try std.ArrayList(u256).initCapacity(alloc, 1);
    defer map.deinit(alloc);
    map.appendAssumeCapacity(0);
    for (input) |value| {
        switch (value) {
            '.' => x += 1,
            '#' => {
                map.items[y] |= ONE << x;
                x += 1;
            },
            '\n' => {
                x = 0;
                y += 1;
                try map.append(alloc, 0);
            },
            '^' => {
                guard = Guard{ .x = x, .y = y, .dir = .up };
                x += 1;
            },
            else => {},
        }
    }
    _ = map.pop();

    const been = try alloc.alloc(u256, map.items.len);
    defer alloc.free(been);
    @memset(been, 0);

    var sum: u32 = 0;
    while (guard.step(map.items, been)) {
        if (try guard.obstruct(alloc, map.items, been)) {
            sum += 1;
        }
    }
    return sum;
}
