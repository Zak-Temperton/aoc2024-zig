const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day09.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day09:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u64 {
    var files = std.ArrayList(u8).init(alloc);
    defer files.deinit();
    var freespace = std.ArrayList(u8).init(alloc);
    defer freespace.deinit();

    for (input, 0..) |c, i| {
        if (c == '\r') break;
        if (i & 1 == 0) {
            try files.append(c - '0');
        } else {
            try freespace.append(c - '0');
        }
    }
    var checksum: u64 = 0;

    var i: u32 = 0;
    var j: u32 = 0;
    var k: u32 = 0;
    var last: usize = 0;
    while (i < files.items.len) : (i += 1) {
        for (0..files.items[i]) |_| {
            checksum += i * j;
            j += 1;
        }
        for (0..freespace.items[i]) |_| {
            if (k == 0) {
                if (i < files.items.len - 1) {
                    last = files.items.len - 1;
                    k = files.pop();
                } else {
                    break;
                }
            }
            checksum += last * j;
            j += 1;
            k -= 1;
        }
    }
    while (k > 0) {
        checksum += last * j;
        j += 1;
        k -= 1;
    }
    return checksum;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u64 {
    const File = struct { avalable: bool, len: u8 };

    var files = std.ArrayList(File).init(alloc);
    defer files.deinit();
    var freespace = std.ArrayList(u8).init(alloc);
    defer freespace.deinit();

    for (input, 0..) |c, i| {
        if (c == '\r') break;
        if (i & 1 == 0) {
            try files.append(.{ .avalable = true, .len = c - '0' });
        } else {
            try freespace.append(c - '0');
        }
    }
    var checksum: u64 = 0;

    var i: u32 = 0;
    var j: u32 = 0;

    while (i < files.items.len) : (i += 1) {
        if (files.items[i].avalable) {
            for (0..files.items[i].len) |_| {
                checksum += i * j;
                j += 1;
            }
        } else {
            j += files.items[i].len;
        }
        const free = &freespace.items[i];
        fill: while (free.* > 0) {
            for (0..files.items.len - i) |idx| {
                const file = &files.items[files.items.len - idx];
                if (file.avalable and free.* >= file.len) {
                    for (0..file.len) |_| {
                        checksum += (files.items.len - idx) * j;
                        j += 1;
                    }
                    free.* -= file.len;
                    file.avalable = false;
                    continue :fill;
                }
            }
            break;
        }
        j += free.*;
    }
    return checksum;
}
