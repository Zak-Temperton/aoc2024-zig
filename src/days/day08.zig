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

fn getIndex(char: u8) u8 {
    switch (char) {
        '0'...'9' => return char - '0',
        'a'...'z' => return char - 'a' + 10,
        'A'...'Z' => return char - 'A' + 36,
        else => unreachable,
    }
}

fn findAntennas(alloc: std.mem.Allocator, input: []const u8, antennas: []?std.ArrayList(Antenna)) !u32 {
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
                const index = getIndex(c);
                if (antennas[index]) |*frequency| {
                    try frequency.append(.{ .x = x, .y = y });
                } else {
                    antennas[index] = std.ArrayList(Antenna).init(alloc);
                    try antennas[index].?.append(.{ .x = x, .y = y });
                }
                x += 1;
            },
        }
    }
    return y;
}

fn findAntinodes(antennas: []?std.ArrayList(Antenna), antinodes: []u64, size: u32) void {
    const ONE: u64 = 1;
    for (antennas) |antenna| {
        if (antenna) |frequency| {
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
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    const antennas = try alloc.alloc(?std.ArrayList(Antenna), 10 + 26 * 2);
    @memset(antennas, null);
    defer {
        for (antennas) |antenna| {
            if (antenna) |frequency| {
                frequency.deinit();
            }
        }
        alloc.free(antennas);
    }
    const size = try findAntennas(alloc, input, antennas);
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

fn findAntinodes2(antennas: []?std.ArrayList(Antenna), antinodes: []u64, size: u32) void {
    const ONE: u64 = 1;
    for (antennas) |antenna| {
        if (antenna) |frequency| {
            for (frequency.items, 0..) |a1, i| {
                for (frequency.items[i + 1 ..]) |a2| {
                    const yy = a2.y - a1.y;
                    var dx: u32 = 0;
                    var dy: u32 = 0;
                    if (a1.x > a2.x) {
                        const xx = a1.x - a2.x;
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
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    const antennas = try alloc.alloc(?std.ArrayList(Antenna), 10 + 26 * 2);
    @memset(antennas, null);
    defer {
        for (antennas) |antenna| {
            if (antenna) |frequency| {
                frequency.deinit();
            }
        }
        alloc.free(antennas);
    }
    const size = try findAntennas(alloc, input, antennas);
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
