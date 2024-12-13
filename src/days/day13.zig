const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day13.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    timer.reset();
    const p1 = try part1(buffer);
    const p1_time = timer.lap();
    const p2 = try part2(buffer);
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

fn part1(input: []const u8) !u64 {
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
        sum += cost;
    }
    std.debug.print("\n", .{});
    return sum;
}

fn part2(input: []const u8) !u64 {
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
        const px = readInt(u64, input, &i) + 10000000000000;
        i += 4;
        const py = readInt(u64, input, &i) + 10000000000000;
        i += 4;
        const cost = cheapest(ax, ay, bx, by, px, py);
        sum += cost;
    }
    return sum;
}

fn cheapest(ax: u64, ay: u64, bx: u64, by: u64, px: u64, py: u64) u64 {
    const fax: f64 = @floatFromInt(ax);
    const fay: f64 = @floatFromInt(ay);
    const fbx: f64 = @floatFromInt(bx);
    const fby: f64 = @floatFromInt(by);
    const fpx: f64 = @floatFromInt(px);
    const fpy: f64 = @floatFromInt(py);

    const fb = @round((fpx / fax - fpy / fay) / (fbx / fax - fby / fay));
    if (fb < 0) return 0;
    const b: u64 = @intFromFloat(fb);
    if (bx * b > px) return 0;
    const a = (px - bx * b) / ax;

    if (a * ax + b * bx == px and a * ay + b * by == py) {
        return a * 3 + b;
    }

    return 0;
}
