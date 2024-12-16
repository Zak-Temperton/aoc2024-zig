const std = @import("std");

const ONE: u128 = 1;
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

fn pushBox(dir: u8, px: *u32, py: *u32, walls: []u128, boxes: []u128) void {
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
    const side: u32 = 48;
    var walls: [side]u128 = undefined;
    @memset(&walls, 0);
    var boxes: [side]u128 = undefined;
    @memset(&boxes, 0);
    var player_x: u32 = 0;
    var player_y: u32 = 0;
    for (0..side) |y| {
        const wall = &walls[y];
        const box = &boxes[y];
        for (0..side) |x| {
            switch (input[(x + 1) + (y + 1) * (side + 4)]) {
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

    var i = (side + 4) * (side + 2) + 2;

    while (i < input.len) : (i += 1) {
        pushBox(input[i], &player_x, &player_y, &walls, &boxes);
    }

    var sum: usize = 0;
    for (0..side) |y| {
        const box = boxes[y];
        for (0..side) |x| {
            if (box >> @truncate(x) & 1 == 1) {
                sum += (y + 1) * 100 + x + 1;
            }
        }
    }
    return sum;
}

fn canPushCrate(dir: u8, x: u32, y: u32, walls: []u128, boxes_left: []u128, boxes_right: []u128) bool {
    var xx: u7 = @truncate(x);
    var yy: u7 = @truncate(y);
    switch (dir) {
        '^' => {
            if (y == 0) return false;
            yy -= 1;
        },
        'v' => {
            if (y == walls.len - 1) return false;
            yy += 1;
        },
        '<' => {
            if (x == 0 or boxes_right[y] >> xx & 1 == 1 and x == 1) return false;
            xx -= 1;
        },
        '>' => {
            if (x == walls.len * 2 - 1 or boxes_left[y] >> xx & 1 == 1 and x == walls.len * 2 - 2) return false;
            xx += 1;
        },
        else => return false,
    }

    if (walls[yy] >> xx & 1 == 1) return false;
    if (dir == '^' or dir == 'v') {
        if (boxes_left[yy] >> xx & 1 == 1) {
            return canPushCrate(dir, xx, yy, walls, boxes_left, boxes_right) and canPushCrate(dir, xx + 1, yy, walls, boxes_left, boxes_right);
        }
        if (boxes_right[yy] >> xx & 1 == 1) {
            return canPushCrate(dir, xx, yy, walls, boxes_left, boxes_right) and canPushCrate(dir, xx - 1, yy, walls, boxes_left, boxes_right);
        }
    } else {
        if (boxes_left[yy] >> xx & 1 == 1) {
            return canPushCrate(dir, xx, yy, walls, boxes_left, boxes_right);
        }
        if (boxes_right[yy] >> xx & 1 == 1) {
            return canPushCrate(dir, xx, yy, walls, boxes_left, boxes_right);
        }
    }
    return true;
}

fn pushCrate(dir: u8, x: u32, y: u32, walls: []u128, boxes_left: []u128, boxes_right: []u128) void {
    var xx: u7 = @truncate(x);
    var yy: u7 = @truncate(y);
    switch (dir) {
        '^' => {
            if (y == 0) return;
            yy -= 1;
        },
        'v' => {
            if (y == walls.len - 1) return;
            yy += 1;
        },
        '<' => {
            if (x == 0) return;
            xx -= 1;
        },
        '>' => {
            if (x == walls.len * 2 - 1) return;
            xx += 1;
        },
        else => return,
    }

    if (dir == '^' or dir == 'v') {
        if (boxes_left[y] >> @truncate(x) & 1 == 1) {
            pushCrate(dir, xx + 1, yy, walls, boxes_left, boxes_right);
            pushCrate(dir, xx, yy, walls, boxes_left, boxes_right);
            if (boxes_left[y] >> @truncate(x) & 1 == 1) {
                boxes_left[yy] |= ONE << @truncate(x);
                boxes_left[y] ^= ONE << @truncate(x);
            }
            if (boxes_right[y] >> @truncate(x + 1) & 1 == 1) {
                boxes_right[yy] |= ONE << @truncate(x + 1);
                boxes_right[y] ^= ONE << @truncate(x + 1);
            }
        }
        if (boxes_right[y] >> @truncate(x) & 1 == 1) {
            pushCrate(dir, xx, yy, walls, boxes_left, boxes_right);
            pushCrate(dir, xx - 1, yy, walls, boxes_left, boxes_right);
            if (boxes_left[y] >> @truncate(x - 1) & 1 == 1) {
                boxes_left[yy] |= ONE << @truncate(x - 1);
                boxes_left[y] ^= ONE << @truncate(x - 1);
            }
            if (boxes_right[y] >> @truncate(x) & 1 == 1) {
                boxes_right[yy] |= ONE << @truncate(x);
                boxes_right[y] ^= ONE << @truncate(x);
            }
        }
    } else {
        if (boxes_left[y] >> @truncate(x) & 1 == 1) {
            pushCrate(dir, xx, yy, walls, boxes_left, boxes_right);
            if (boxes_left[y] >> @truncate(x) & 1 == 1) {
                boxes_left[y] |= ONE << @truncate(xx);
                boxes_left[y] ^= ONE << @truncate(x);
            }
        } else if (boxes_right[y] >> @truncate(x) & 1 == 1) {
            pushCrate(dir, xx, yy, walls, boxes_left, boxes_right);
            if (boxes_right[y] >> @truncate(x) & 1 == 1) {
                boxes_right[y] |= ONE << @truncate(xx);
                boxes_right[y] ^= ONE << @truncate(x);
            }
        }
    }
}

fn tryPushCrate(dir: u8, px: *u32, py: *u32, walls: []u128, boxes_left: []u128, boxes_right: []u128) void {
    if (canPushCrate(dir, px.*, py.*, walls, boxes_left, boxes_right)) {
        switch (dir) {
            '^' => {
                py.* -= 1;
            },
            'v' => {
                py.* += 1;
            },
            '<' => {
                px.* -= 1;
            },
            '>' => {
                px.* += 1;
            },
            else => return,
        }
        pushCrate(dir, px.*, py.*, walls, boxes_left, boxes_right);
        return;
    }
}

fn part2(input: []const u8) usize {
    const side: u32 = 48;
    var walls: [side]u128 = undefined;
    @memset(&walls, 0);
    var boxes_left: [side]u128 = undefined;
    @memset(&boxes_left, 0);
    var boxes_right: [side]u128 = undefined;
    @memset(&boxes_right, 0);
    var player_x: u32 = 0;
    var player_y: u32 = 0;
    for (0..side) |y| {
        const wall = &walls[y];
        const box_left = &boxes_left[y];
        const box_right = &boxes_right[y];
        for (0..side) |x| {
            switch (input[(x + 1) + (y + 1) * (side + 4)]) {
                '#' => wall.* |= THREE << @truncate(x * 2),
                'O' => {
                    box_left.* |= @as(u128, 1) << @truncate(x * 2);
                    box_right.* |= @as(u128, 1) << @truncate(x * 2 + 1);
                },
                '@' => {
                    player_x = @truncate(x * 2);
                    player_y = @truncate(y);
                },
                else => {},
            }
        }
    }

    var i = (side + 4) * (side + 2) + 2;

    while (i < input.len) : (i += 1) {
        tryPushCrate(input[i], &player_x, &player_y, &walls, &boxes_left, &boxes_right);
    }

    var sum: usize = 0;
    for (0..side) |y| {
        const box = boxes_left[y];
        for (0..side * 2) |x| {
            if (box >> @truncate(x) & 1 == 1) {
                sum += (y + 1) * 100 + x + 2;
            }
        }
    }
    return sum;
}
