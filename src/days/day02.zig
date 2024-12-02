const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day02.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
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

fn skipLine(input: []const u8, i: *usize) void {
    while (i.* < input.len and input[i.*] != '\n') : (i.* += 1) {}
    i.* += 1;
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    _ = alloc; // autofix

    var count: u32 = 0;
    var i: usize = 0;
    reports: while (i < input.len) {
        var prev = readInt(u8, input, &i);
        i += 1;
        var curr = readInt(u8, input, &i);
        const decrease = curr < prev;
        var diff = @abs(@as(i8, @intCast(curr)) - @as(i8, @intCast(prev)));
        if (diff == 0 or diff > 3) {
            skipLine(input, &i);
            continue :reports;
        }
        while (i < input.len and input[i] == ' ') {
            i += 1;
            prev = curr;
            curr = readInt(u8, input, &i);
            diff = @abs(@as(i8, @intCast(curr)) - @as(i8, @intCast(prev)));

            if (decrease != (curr < prev) or diff == 0 or diff > 3) {
                skipLine(input, &i);
                continue :reports;
            }
        }
        count += 1;
        nextLine(input, &i);
    }
    return count;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var count: u32 = 0;
    var i: usize = 0;
    var report = try std.ArrayList(u8).initCapacity(alloc, 8);
    defer report.deinit();
    while (i < input.len) {
        report.appendAssumeCapacity(readInt(u8, input, &i));
        while (i < input.len and input[i] == ' ') {
            i += 1;
            report.appendAssumeCapacity(readInt(u8, input, &i));
        }
        var prev = report.items[0];
        var decrease = report.items[1] < prev;
        var err = false;
        var valid = true;
        for (report.items[1..]) |curr| {
            if (decrease != (curr < prev)) {
                if (err) {
                    valid = false;
                    break;
                }
                err = true;
                continue;
            }
            const diff = @abs(@as(i8, @intCast(curr)) - @as(i8, @intCast(prev)));
            if (diff == 0 or diff > 3) {
                if (err) {
                    valid = false;
                    break;
                }
                err = true;
                continue;
            }
            prev = curr;
        }
        if (!valid) {
            prev = report.items[0];
            decrease = report.items[2] < prev;
            valid = true;
            for (report.items[2..]) |curr| {
                if (decrease != (curr < prev)) {
                    valid = false;
                    break;
                }
                const diff = @abs(@as(i8, @intCast(curr)) - @as(i8, @intCast(prev)));
                if (diff == 0 or diff > 3) {
                    valid = false;
                    break;
                }
                prev = curr;
            }
        }
        if (!valid) {
            prev = report.items[1];
            decrease = report.items[2] < prev;
            valid = true;
            for (report.items[2..]) |curr| {
                if (decrease != (curr < prev)) {
                    valid = false;
                    break;
                }
                const diff = @abs(@as(i8, @intCast(curr)) - @as(i8, @intCast(prev)));
                if (diff == 0 or diff > 3) {
                    valid = false;
                    break;
                }
                prev = curr;
            }
        }
        if (valid) {
            count += 1;
        }

        report.clearRetainingCapacity();
        nextLine(input, &i);
    }
    return count;
}
