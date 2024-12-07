const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day07.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readAllAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day07:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
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
fn possible(nums: []u64, target: u64) bool {
    if (nums.len == 1) {
        return nums[0] == target;
    }
    if (nums[0] >= target) {
        return false;
    }
    const tmp: u64 = nums[1];
    defer nums[1] = tmp;
    nums[1] = nums[0] * nums[1];
    if (possible(nums[1..], target)) {
        return true;
    }
    nums[1] = tmp + nums[0];
    if (possible(nums[1..], target)) {
        return true;
    }
    return false;
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u64 {
    var i: usize = 0;
    var nums = std.ArrayList(u64).init(alloc);
    defer nums.deinit();
    var sum: u64 = 0;
    while (i < input.len) {
        nums.clearRetainingCapacity();
        const target = readInt(u64, input, &i);
        i += 1;
        while (i < input.len and input[i] == ' ') {
            i += 1;
            try nums.append(readInt(u64, input, &i));
        }
        if (possible(nums.items, target)) {
            sum += target;
        }
        i += 2;
    }
    return sum;
}

fn concat(lhs: u64, rhs: u64) u64 {
    const log: u64 = @intFromFloat(@log10(@as(f32, @floatFromInt(rhs))));
    return lhs * std.math.pow(u64, 10, log + 1) + rhs;
}

fn possible2(nums: []u64, target: u64) bool {
    if (nums.len == 1) {
        return nums[0] == target;
    }
    if (nums[0] >= target) {
        return false;
    }
    const tmp: u64 = nums[1];
    defer nums[1] = tmp;
    nums[1] = nums[0] * nums[1];
    if (possible2(nums[1..], target)) {
        return true;
    }
    nums[1] = tmp + nums[0];
    if (possible2(nums[1..], target)) {
        return true;
    }
    nums[1] = concat(nums[0], tmp);
    if (possible2(nums[1..], target)) {
        return true;
    }
    return false;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u64 {
    var i: usize = 0;
    var nums = std.ArrayList(u64).init(alloc);
    defer nums.deinit();
    var sum: u64 = 0;
    while (i < input.len) {
        nums.clearRetainingCapacity();
        const target = readInt(u64, input, &i);
        i += 1;
        while (i < input.len and input[i] == ' ') {
            i += 1;
            try nums.append(readInt(u64, input, &i));
        }
        if (possible2(nums.items, target)) {
            sum += target;
        }
        i += 2;
    }
    return sum;
}
