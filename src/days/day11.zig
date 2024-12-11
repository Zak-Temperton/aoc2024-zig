const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day11.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day11:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
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

fn digits(num: u64) u8 {
    var count: u8 = 0;
    var x = num;
    while (x > 0) {
        x /= 10;
        count += 1;
    }
    return count;
}

fn mapChildren(seen: *std.AutoHashMap(u64, []usize), num: u64, target: usize, loops: usize) !usize {
    if (target == 0) return 1;
    const entry = try seen.getOrPut(num);
    if (entry.found_existing) {
        if (entry.value_ptr.*[target - 1] != 0) {
            return entry.value_ptr.*[target - 1];
        }
    } else {
        entry.value_ptr.* = try seen.allocator.alloc(usize, loops);
        @memset(entry.value_ptr.*, 0);
    }

    if (num == 0) {
        const children = try mapChildren(seen, 1, target - 1, loops);
        seen.get(num).?[target - 1] = children;
    } else {
        const len = digits(num);
        if (len & 1 == 0) {
            var div: u64 = 1;
            for (0..len / 2) |_| {
                div *= 10;
            }
            const children = try mapChildren(seen, num / div, target - 1, loops) + try mapChildren(seen, num % div, target - 1, loops);
            seen.get(num).?[target - 1] = children;
        } else {
            const children = try mapChildren(seen, num * 2024, target - 1, loops);
            seen.get(num).?[target - 1] = children;
        }
    }
    return seen.get(num).?[target - 1];
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    var i: usize = 0;

    var map = std.AutoHashMap(u64, []usize).init(alloc);
    defer {
        var iter = map.valueIterator();
        while (iter.next()) |next| {
            alloc.free(next.*);
        }
        map.deinit();
    }
    var sum: usize = 0;

    while (i < input.len - 1) : (i += 1) {

        sum += try mapChildren(&seen, readInt(u64, input, &i), 25, 25);

    }

    return sum;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !usize {
    var i: usize = 0;

    var seen = std.AutoHashMap(u64, []usize).init(alloc);
    defer {
        var iter = seen.valueIterator();
        while (iter.next()) |next| {
            alloc.free(next.*);
        }
        seen.deinit();
    }
    var sum: usize = 0;

    while (i < input.len - 1) : (i += 1) {
        sum += try mapChildren(&seen, readInt(u64, input, &i), 75, 75);
    }

    return sum;
}
