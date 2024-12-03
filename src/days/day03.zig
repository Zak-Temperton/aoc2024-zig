const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day03.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(buffer);
    const p1_time = timer.lap();
    const p2 = try part2(buffer);
    const p2_time = timer.read();
    try stdout.print("Day03:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
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

fn nextMul(input: []const u8, i: *usize) ?u32 {
    while (i.* < input.len - 8) : (i.* += 1) {
        if (input[i.*] == 'm' and input[i.* + 1] == 'u' and input[i.* + 2] == 'l' and input[i.* + 3] == '(') {
            i.* += 4;
            if (input[i.*] >= '0' and input[i.*] <= '9') {
                const a = readInt(u32, input, i);
                if (input[i.*] == ',' and input[i.* + 1] >= '0' and input[i.* + 1] <= '9') {
                    i.* += 1;
                    const b = readInt(u32, input, i);
                    if (input[i.*] == ')') {
                        i.* += 1;
                        return a * b;
                    }
                }
            }
        }
    }
    return null;
}

fn nextIntruction(input: []const u8, i: *usize) ?u32 {
    var do = true;
    while (i.* < input.len - 8) : (i.* += 1) {
        if (do and input[i.*] == 'm' and input[i.* + 1] == 'u' and input[i.* + 2] == 'l' and input[i.* + 3] == '(') {
            i.* += 4;
            if (input[i.*] >= '0' and input[i.*] <= '9') {
                const a = readInt(u32, input, i);
                if (input[i.*] == ',' and input[i.* + 1] >= '0' and input[i.* + 1] <= '9') {
                    i.* += 1;
                    const b = readInt(u32, input, i);
                    if (input[i.*] == ')') {
                        i.* += 1;
                        return a * b;
                    }
                }
            }
        }
        if (input[i.*] == 'd' and input[i.* + 1] == 'o') {
            if (input[i.* + 2] == '(' and input[i.* + 3] == ')') {
                do = true;
                i.* += 3;
            } else if (input[i.* + 2] == 'n' and input[i.* + 3] == '\'' and input[i.* + 4] == 't' and input[i.* + 5] == '(' and input[i.* + 6] == ')') {
                do = false;
                i.* += 6;
            }
        }
    }
    return null;
}

fn part1(input: []const u8) !u32 {
    var sum: u32 = 0;
    var i: usize = 0;
    while (nextMul(input, &i)) |mul| {
        sum += mul;
    }
    return sum;
}

fn part2(input: []const u8) !u32 {
    var sum: u32 = 0;
    var i: usize = 0;
    while (nextIntruction(input, &i)) |mul| {
        sum += mul;
    }
    return sum;
}
