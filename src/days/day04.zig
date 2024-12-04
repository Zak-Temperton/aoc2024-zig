const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day04.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = part1(140, buffer);
    const p1_time = timer.lap();
    const p2 = part2(140, buffer);
    const p2_time = timer.read();
    try stdout.print("Day02:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
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

fn nextLine(input: []const u8, i: *usize) void {
    while (i.* < input.len and (input[i.*] == '\r' or input[i.*] == '\n')) : (i.* += 1) {}
}

fn readLine(comptime width: usize, input: []const u8, i: *usize) [width]u8 {
    var line: [width]u8 = .{};
    var idx: usize = 0;
    while (i.* < input.len and input[i.*] != '\r' and input[i.*] != '\n') : (i.* += 1) {
        line[idx] = input[i.*];
        idx += 1;
    }
    nextLine(input, i);
    return line;
}

fn part1(comptime width: usize, input: []const u8) u32 {
    const true_width = width + 2; //include line endings
    const word = "XMAS";
    var count: u32 = 0;
    for (0..width) |y| {
        for (0..width) |x| {
            if (input[x + y * true_width] == 'X') {
                var dirs: u32 = 8;
                if (x < width - 3) {
                    if (y > 2) {
                        for (1..4) |i| {
                            if (input[x + i + (y - i) * true_width] != word[i]) {
                                dirs -= 1;
                                break;
                            }
                        }
                    } else {
                        dirs -= 1;
                    }
                    if (y < width - 3) {
                        for (1..4) |i| {
                            if (input[x + i + (y + i) * true_width] != word[i]) {
                                dirs -= 1;
                                break;
                            }
                        }
                    } else {
                        dirs -= 1;
                    }
                    for (1..4) |i| {
                        if (input[x + i + y * true_width] != word[i]) {
                            dirs -= 1;
                            break;
                        }
                    }
                } else {
                    dirs -= 3;
                }

                if (x > 2) {
                    if (y > 2) {
                        for (1..4) |i| {
                            if (input[x - i + (y - i) * true_width] != word[i]) {
                                dirs -= 1;
                                break;
                            }
                        }
                    } else {
                        dirs -= 1;
                    }

                    if (y < width - 3) {
                        for (1..4) |i| {
                            if (x > 2 and input[x - i + (y + i) * true_width] != word[i]) {
                                dirs -= 1;
                                break;
                            }
                        }
                    } else {
                        dirs -= 1;
                    }
                    for (1..4) |i| {
                        if (x > 2 and input[x - i + y * true_width] != word[i]) {
                            dirs -= 1;
                            break;
                        }
                    }
                } else {
                    dirs -= 3;
                }
                if (y < width - 3) {
                    for (1..4) |i| {
                        if (input[x + (y + i) * true_width] != word[i]) {
                            dirs -= 1;
                            break;
                        }
                    }
                } else {
                    dirs -= 1;
                }
                if (y > 2) {
                    for (1..4) |i| {
                        if (input[x + (y - i) * true_width] != word[i]) {
                            dirs -= 1;
                            break;
                        }
                    }
                } else {
                    dirs -= 1;
                }
                count += dirs;
            }
        }
    }

    return count;
}

fn part2(comptime width: usize, input: []const u8) u32 {
    const true_width = width + 2; //include line endings
    var count: u32 = 0;
    for (1..width - 1) |y| {
        for (1..width - 1) |x| {
            if (input[x + y * true_width] == 'A') {
                const l = x - 1;
                const r = x + 1;
                const u = y - 1;
                const d = y + 1;
                const nw = input[l + u * true_width];
                const ne = input[r + u * true_width];
                const sw = input[l + d * true_width];
                const se = input[r + d * true_width];
                if (nw == 'M' and se == 'S' or nw == 'S' and se == 'M') {
                    if (ne == 'M' and sw == 'S' or ne == 'S' and sw == 'M') {
                        count += 1;
                    }
                }
            }
        }
    }
    return count;
}
