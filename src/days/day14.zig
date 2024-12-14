const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day14.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = part1(buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day14:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn readInt(input: []const u8, i: *usize) i32 {
    var num: i32 = 0;
    var signed = false;
    if (input[i.*] == '-') {
        signed = true;
        i.* += 1;
    }
    while (i.* < input.len) : (i.* += 1) {
        switch (input[i.*]) {
            '0'...'9' => |c| num = num * 10 + c - '0',
            else => {
                if (signed) {
                    return 0 - num;
                } else {
                    return num;
                }
            },
        }
    }
    if (signed) {
        return 0 - num;
    } else {
        return num;
    }
}

fn part1(input: []const u8) u32 {
    const width: i32 = 101;
    const height: i32 = 103;
    const steps: u32 = 100;
    var i: usize = 0;
    var quads = [4]u32{ 0, 0, 0, 0 };
    while (i < input.len) {
        i += 2;
        const x = readInt(input, &i);
        i += 1;
        const y = readInt(input, &i);
        i += 3;
        const vx = readInt(input, &i);
        i += 1;
        const vy = readInt(input, &i);
        i += 2;
        const final_x = @mod(x + (vx * steps), width);
        const final_y = @mod(y + (vy * steps), height);
        if (final_x < width / 2) {
            if (final_y < height / 2) {
                quads[0] += 1;
            } else if (final_y > height / 2) {
                quads[2] += 1;
            }
        } else if (final_x > width / 2) {
            if (final_y < height / 2) {
                quads[1] += 1;
            } else if (final_y > height / 2) {
                quads[3] += 1;
            }
        }
    }
    return quads[0] * quads[1] * quads[2] * quads[3];
}

const Robot = struct { x: i32, y: i32, vx: i32, vy: i32 };

fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    const width: i32 = 101;
    const height: i32 = 103;
    var robots = std.ArrayList(Robot).init(alloc);
    defer robots.deinit();
    var i: usize = 0;
    while (i < input.len) {
        i += 2;
        const x = readInt(input, &i);
        i += 1;
        const y = readInt(input, &i);
        i += 3;
        const vx = readInt(input, &i);
        i += 1;
        const vy = readInt(input, &i);
        i += 2;
        try robots.append(Robot{ .x = x, .y = y, .vx = vx, .vy = vy });
    }

    var image: [height]u128 = undefined;
    for (0..100000) |s| {
        @memset(&image, 0);

        for (robots.items) |*robot| {
            robot.x = @mod(robot.x + robot.vx, width);
            robot.y = @mod(robot.y + robot.vy, height);

            const final_x: u64 = @intCast(robot.x);
            const final_y: u64 = @intCast(robot.y);
            image[final_y] |= @as(u128, 1) << @truncate(final_x);
        }
        for (image) |line| {
            if (@popCount(line) >= 33) {
                var continuity: u32 = 0;
                for (0..width) |c| {
                    if ((line >> @truncate(c)) & 1 == 1) {
                        continuity += 1;
                        if (continuity == 10) {
                            return @truncate(s);
                        }
                    } else {
                        continuity = 0;
                    }
                }
            }
        }
    }
    unreachable;
}
