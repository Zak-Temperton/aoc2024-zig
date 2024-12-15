const std = @import("std");

const ONE: u64 = 1;
const THREE: u128 = 0b11;

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day15.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = part1(buffer);
    const p1_time = timer.lap();
    const p2 = part2(buffer);
    const p2_time = timer.read();
    try stdout.print("Day15:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn pushBox(dir: u8, px: *u32, py: *u32, walls: []u64, boxes: []u64) void {
    switch (dir) {
        '^' => {
            if (py.* == 0) return;
            if (walls[py.* - 1] & ONE << @truncate(px.*) == 0) {
                if (boxes[py.* - 1] & ONE << @truncate(px.*) == 0) {
                    py.* -= 1;
                } else {
                    for (2..py.* + 1) |y| {
                        if (walls[py.* - y] & ONE << @truncate(px.*) == 0) {
                            if (boxes[py.* - y] & ONE << @truncate(px.*) == 0) {
                                boxes[py.* - 1] ^= ONE << @truncate(px.*);
                                boxes[py.* - y] |= ONE << @truncate(px.*);
                                py.* -= 1;
                                return;
                            }
                        } else {
                            return;
                        }
                    }
                }
            }
        },
        'v' => {
            if (py.* == walls.len - 1) return;
            if (walls[py.* + 1] & ONE << @truncate(px.*) == 0) {
                if (boxes[py.* + 1] & ONE << @truncate(px.*) == 0) {
                    py.* += 1;
                } else {
                    for (py.* + 2..walls.len) |y| {
                        if (walls[y] & ONE << @truncate(px.*) == 0) {
                            if (boxes[y] & ONE << @truncate(px.*) == 0) {
                                boxes[py.* + 1] ^= ONE << @truncate(px.*);
                                boxes[y] |= ONE << @truncate(px.*);
                                py.* += 1;
                                return;
                            }
                        } else {
                            return;
                        }
                    }
                }
            }
        },
        '<' => {
            if (px.* == 0) return;
            if (walls[py.*] & (ONE << @truncate(px.* - 1)) == 0) {
                if (boxes[py.*] & ONE << @truncate(px.* - 1) == 0) {
                    px.* -= 1;
                } else {
                    for (2..px.* + 1) |x| {
                        if (walls[py.*] & ONE << @truncate(px.* - x) == 0) {
                            if (boxes[py.*] & ONE << @truncate(px.* - x) == 0) {
                                boxes[py.*] ^= ONE << @truncate(px.* - 1);
                                boxes[py.*] |= ONE << @truncate(px.* - x);
                                px.* -= 1;
                                return;
                            }
                        } else {
                            return;
                        }
                    }
                }
            }
        },
        '>' => {
            if (px.* == walls.len - 1) return;
            if (walls[py.*] & ONE << @truncate(px.* + 1) == 0) {
                if (boxes[py.*] & ONE << @truncate(px.* + 1) == 0) {
                    px.* += 1;
                } else {
                    for (px.* + 2..walls.len) |x| {
                        if (walls[py.*] & ONE << @truncate(x) == 0) {
                            if (boxes[py.*] & ONE << @truncate(x) == 0) {
                                boxes[py.*] ^= ONE << @truncate(px.* + 1);
                                boxes[py.*] |= ONE << @truncate(x);
                                px.* += 1;
                                return;
                            }
                        } else {
                            return;
                        }
                    }
                }
            }
        },
        else => {},
    }
}

fn part1(input: []const u8) usize {
    const width: u32 = 48;
    const height: u32 = 48;
    var walls: [height]u64 = undefined;
    @memset(&walls, 0);
    var boxes: [height]u64 = undefined;
    @memset(&boxes, 0);
    var player_x: u32 = 0;
    var player_y: u32 = 0;
    for (0..height) |y| {
        const wall = &walls[y];
        const box = &boxes[y];
        for (0..width) |x| {
            switch (input[(x + 1) + (y + 1) * (width + 4)]) {
                '#' => wall.* |= ONE << @truncate(x),
                'O' => box.* |= ONE << @truncate(x),
                '@' => {
                    player_x = @truncate(x);
                    player_y = @truncate(y);
                },
                else => {},
            }
        }
    }

    var i = (width + 4) * (height + 2) + 2;

    while (i < input.len) : (i += 1) {
        pushBox(input[i], &player_x, &player_y, &walls, &boxes);
    }

    var sum: usize = 0;
    for (0..height) |y| {
        const box = boxes[y];
        for (0..width) |x| {
            if (box >> @truncate(x) & 1 == 1) {
                sum += (y + 1) * 100 + x + 1;
            }
        }
    }
    return sum;
}

fn part2(input: []const u8) usize {
    _ = input; // autofix
    return 0;
}
