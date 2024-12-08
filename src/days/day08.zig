const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day08.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day08:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
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

const Antenna = struct { x: u32, y: u32 };

fn findAntennas(input: []const u8, antennas: *std.AutoHashMap(u8, std.ArrayList(Antenna))) !u32 {
    var x: u32 = 0;
    var y: u32 = 0;
    for (input) |c| {
        switch (c) {
            '.', '\r' => x += 1,
            '\n' => {
                y += 1;
                x = 0;
            },
            else => {
                const entry = try antennas.getOrPut(c);
                if (!entry.found_existing) {
                    entry.value_ptr.* = std.ArrayList(Antenna).init(antennas.allocator);
                }
                try entry.value_ptr.append(.{ .x = x, .y = y });
                x += 1;
            },
        }
    }
    return y;
}

fn findAntinodes(antennas: std.AutoHashMap(u8, std.ArrayList(Antenna)), antinodes: []u64, size: u32) void {
    const ONE: u64 = 1;
    var iter = antennas.valueIterator();
    while (iter.next()) |frequency| {
        for (frequency.items, 0..) |a1, i| {
            for (frequency.items[i + 1 ..]) |a2| {
                const yy = a2.y - a1.y;
                if (a1.x > a2.x) {
                    const xx = a1.x - a2.x;
                    if (xx + a1.x < size and a1.y >= yy) {
                        antinodes[a1.y - yy] |= ONE << @truncate(a1.x + xx);
                    }
                    if (xx <= a2.x and a2.y + yy < size) {
                        antinodes[a2.y + yy] |= ONE << @truncate(a2.x - xx);
                    }
                } else {
                    const xx = a2.x - a1.x;
                    if (xx <= a1.x and a1.y >= yy) {
                        antinodes[a1.y - yy] |= ONE << @truncate(a1.x - xx);
                    }
                    if (xx + a2.x < size and a2.y + yy < size) {
                        antinodes[a2.y + yy] |= ONE << @truncate(a2.x + xx);
                    }
                }
            }
        }
    }
}

fn findAntinodes2(antennas: std.AutoHashMap(u8, std.ArrayList(Antenna)), antinodes: []u64, size: u32) void {
    const ONE: u64 = 1;
    var iter = antennas.valueIterator();
    while (iter.next()) |frequency| {
        for (frequency.items, 0..) |a1, i| {
            for (frequency.items[i + 1 ..]) |a2| {
                const yy = a2.y - a1.y;
                if (a1.x > a2.x) {
                    const xx = a1.x - a2.x;
                    var dx: u32 = 0;
                    var dy: u32 = 0;
                    while (dx + a1.x < size and a1.y >= dy) {
                        antinodes[a1.y - dy] |= ONE << @truncate(a1.x + dx);
                        dx += xx;
                        dy += yy;
                    }
                    dx = 0;
                    dy = 0;
                    while (dx <= a2.x and a2.y + dy < size) {
                        antinodes[a2.y + dy] |= ONE << @truncate(a2.x - dx);
                        dx += xx;
                        dy += yy;
                    }
                } else {
                    const xx = a2.x - a1.x;
                    var dx: u32 = 0;
                    var dy: u32 = 0;
                    while (dx <= a1.x and a1.y >= dy) {
                        antinodes[a1.y - dy] |= ONE << @truncate(a1.x - dx);
                        dx += xx;
                        dy += yy;
                    }
                    dx = 0;
                    dy = 0;
                    while (dx + a2.x < size and a2.y + dy < size) {
                        antinodes[a2.y + dy] |= ONE << @truncate(a2.x + dx);
                        dx += xx;
                        dy += yy;
                    }
                }
            }
        }
    }
}
fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var antennas = std.AutoHashMap(u8, std.ArrayList(Antenna)).init(alloc);
    defer {
        var iter = antennas.valueIterator();
        while (iter.next()) |frequency| {
            frequency.deinit();
        }
        antennas.deinit();
    }
    const size = try findAntennas(input, &antennas);
    const antinodes = try alloc.alloc(u64, size);
    @memset(antinodes, 0);
    defer alloc.free(antinodes);

    findAntinodes(antennas, antinodes, size);

    var sum: u32 = 0;
    for (antinodes) |row| {
        sum += @popCount(row);
    }
    return sum;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var antennas = std.AutoHashMap(u8, std.ArrayList(Antenna)).init(alloc);
    defer {
        var iter = antennas.valueIterator();
        while (iter.next()) |frequency| {
            frequency.deinit();
        }
        antennas.deinit();
    }
    const size = try findAntennas(input, &antennas);
    const antinodes = try alloc.alloc(u64, size);
    @memset(antinodes, 0);
    defer alloc.free(antinodes);

    findAntinodes2(antennas, antinodes, size);

    var sum: u32 = 0;
    for (antinodes) |row| {
        sum += @popCount(row);
    }
    return sum;
}
