const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day13.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day13:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn readInt(comptime T: type, input: []const u8, i: *usize) T {
    var num: T = 0;
    while (i.* < input.len) : (i.* += 1) {
        switch (input[i.*]) {
            '0'...'9' => |c| num = num * 10 + c - '0',
            else => return num,
        }
    }
    return num;
}

const State = struct {
    x: u64,
    y: u64,
    cost: u64,
};

fn cheapestPath(alloc: std.mem.Allocator, ax: u64, ay: u64, bx: u64, by: u64, px: u64, py: u64) !u64 {
    // if even input and out target return 0
    if (ax & 1 == 0 and bx & 1 == 0 and px & 1 == 1 or ay & 1 == 0 and by & 1 == 0 and py & 1 == 1) return 0;
    var been = std.AutoHashMap([2]u64, void).init(alloc);
    defer been.deinit();
    var states = std.ArrayList(State).init(alloc);
    defer states.deinit();
    try states.append(.{ .x = 0, .y = 0, .cost = 0 });
    try been.put(.{ 0, 0 }, {});
    while (states.items.len != 0) {
        var min = states.items[0];
        var min_idx: usize = 0;
        for (states.items[1..], 1..) |s, i| {
            if (s.cost < min.cost) {
                min = s;
                min_idx = i;
            }
        }

        _ = states.swapRemove(min_idx);
        const a = State{ .x = min.x + ax, .y = min.y + ay, .cost = min.cost + 3 };
        const b = State{ .x = min.x + bx, .y = min.y + by, .cost = min.cost + 1 };
        if (b.x == px and b.y == py) {
            return b.cost;
        }
        if (a.x == px and a.y == py) {
            return a.cost;
        }
        if (a.x < px and a.y < py and !been.contains(.{ a.x, a.y })) {
            try been.put(.{ a.x, a.y }, {});
            try states.append(a);
        }
        if (b.x < px and b.y < py and !been.contains(.{ b.x, b.y })) {
            try been.put(.{ b.x, b.y }, {});
            try states.append(b);
        }
    }
    return 0;
}

fn cheapest(ax: u64, ay: u64, bx: u64, by: u64, px: u64, py: u64) u64 {
    if (ax & 1 == 0 and bx & 1 == 0 and px & 1 == 1 or ay & 1 == 0 and by & 1 == 0 and py & 1 == 1) return 0;
    var state = State{ .x = 0, .y = 0, .cost = 0 };
    var min: u64 = 0;
    while (state.x <= px and state.y <= py) {
        if ((px - state.x) % bx == 0 and (py - state.y) % by == 0 and (px - state.x) / bx == (py - state.y) / by) {
            min = state.cost + ((px - state.x) / bx);
            break;
        }
        state.x += ax;
        state.y += ay;
        state.cost += 3;
    }

    return min;
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u64 {
    var i: usize = 0;
    var sum: u64 = 0;
    while (i < input.len) {
        i += 12;
        const ax = readInt(u64, input, &i);
        i += 4;
        const ay = readInt(u64, input, &i);
        i += 14;
        const bx = readInt(u64, input, &i);
        i += 4;
        const by = readInt(u64, input, &i);
        i += 11;
        const px = readInt(u64, input, &i);
        i += 4;
        const py = readInt(u64, input, &i);
        i += 4;
        const cost = try cheapestPath(alloc, ax, ay, bx, by, px, py);
        std.debug.print("{{ {d}, {d} }}{{ {d}, {d} }}{{ {d}, {d} }} => {d}\n", .{ ax, ay, bx, by, px, py, cost });
        sum += cost;
    }
    std.debug.print("\n", .{});
    return sum;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u64 {
    _ = alloc; // autofix
    var i: usize = 0;
    var sum: u64 = 0;
    while (i < input.len) {
        i += 12;
        const ax = readInt(u64, input, &i);
        i += 4;
        const ay = readInt(u64, input, &i);
        i += 14;
        const bx = readInt(u64, input, &i);
        i += 4;
        const by = readInt(u64, input, &i);
        i += 11;
        const px = readInt(u64, input, &i);
        i += 4;
        const py = readInt(u64, input, &i);
        i += 4;
        const cost = cheapest(ax, ay, bx, by, px, py);
        std.debug.print("{{ {d}, {d} }}{{ {d}, {d} }}{{ {d}, {d} }} => {d}\n", .{ ax, ay, bx, by, px, py, cost });
        sum += cost;
    }
    return sum;
}
