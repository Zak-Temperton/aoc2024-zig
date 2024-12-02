const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day01.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day01:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
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

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var left = try std.ArrayList(i32).initCapacity(alloc, 1000);
    defer left.deinit();
    var right = try std.ArrayList(i32).initCapacity(alloc, 1000);
    defer right.deinit();

    var i: usize = 0;
    while (i < input.len) {
        const l = readInt(i32, input, &i);
        left.appendAssumeCapacity(l);
        i += 3;
        const r = readInt(i32, input, &i);
        right.appendAssumeCapacity(r);
        nextLine(input, &i);
    }
    std.mem.sortUnstable(i32, left.items, {}, std.sort.asc(i32));
    std.mem.sortUnstable(i32, right.items, {}, std.sort.asc(i32));

    var sum: u32 = 0;
    for (left.items, right.items) |l, r| {
        sum += @abs(l - r);
    }
    return sum;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var hash = std.AutoHashMap(u32, u32).init(alloc);
    defer hash.deinit();
    var left = try std.ArrayList(u32).initCapacity(alloc, 1000);
    defer left.deinit();

    var i: usize = 0;
    while (i < input.len) {
        const l = readInt(u32, input, &i);
        left.appendAssumeCapacity(l);
        i += 3;
        const r = readInt(u32, input, &i);
        const res = try hash.getOrPut(r);
        if (res.found_existing) {
            res.value_ptr.* += 1;
        } else {
            res.value_ptr.* = 1;
        }
        nextLine(input, &i);
    }

    var sum: u32 = 0;
    for (left.items) |l| {
        if (hash.get(l)) |r| {
            sum += l * r;
        }
    }

    return sum;
}
