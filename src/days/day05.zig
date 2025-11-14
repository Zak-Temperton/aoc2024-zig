const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    const file = try std.fs.cwd().openFile("src/data/day05.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day05:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn readInt(comptime T: type, input: []const u8, i: *usize) T {
    const num: T = (input[i.*] - '0') * 10 + input[i.* + 1] - '0';
    i.* += 2;
    return num;
}

fn skipLine(input: []const u8, i: *usize) void {
    while (i.* < input.len and input[i.*] != '\n') : (i.* += 1) {}
    i.* += 1;
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var rules = std.AutoHashMap(u8, std.ArrayList(u8)).init(alloc);
    defer {
        var iter = rules.valueIterator();
        while (iter.next()) |next| {
            next.deinit(alloc);
        }
        rules.deinit();
    }

    var i: usize = 0;
    while (input[i] != '\r') {
        const left = readInt(u8, input, &i);
        i += 1;
        const right = readInt(u8, input, &i);
        i += 2;
        const res = try rules.getOrPut(right);
        if (res.found_existing) {
            try res.value_ptr.append(alloc, left);
        } else {
            res.value_ptr.* = try std.ArrayList(u8).initCapacity(alloc, 1);
            res.value_ptr.appendAssumeCapacity(left);
        }
    }
    i += 2;
    var sum: u32 = 0;
    var line = try std.ArrayList(u8).initCapacity(alloc, 0);
    defer line.deinit(alloc);
    var disallowed = try std.ArrayList(u8).initCapacity(alloc, 0);
    defer disallowed.deinit(alloc);
    line: while (i < input.len) {
        defer line.clearRetainingCapacity();
        defer disallowed.clearRetainingCapacity();
        while (i < input.len) : (i += 1) {
            const num = readInt(u8, input, &i);
            if (std.mem.containsAtLeast(u8, disallowed.items, 1, &.{num})) {
                skipLine(input, &i);
                continue :line;
            } else {
                try line.append(alloc, num);
                if (rules.get(num)) |rule| {
                    try disallowed.appendSlice(alloc, rule.items);
                }
            }
            if (input[i] != ',') {
                skipLine(input, &i);
                break;
            }
        }
        sum += line.items[line.items.len / 2];
    }
    return sum;
}
fn part2(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var rules = std.AutoHashMap(u8, std.ArrayList(u8)).init(alloc);
    defer {
        var iter = rules.valueIterator();
        while (iter.next()) |next| {
            next.deinit(alloc);
        }
        rules.deinit();
    }

    var i: usize = 0;
    while (input[i] != '\r') {
        const left = readInt(u8, input, &i);
        i += 1;
        const right = readInt(u8, input, &i);
        i += 2;
        const res = try rules.getOrPut(right);
        if (res.found_existing) {
            try res.value_ptr.append(alloc, left);
        } else {
            res.value_ptr.* = try std.ArrayList(u8).initCapacity(alloc, 1);
            res.value_ptr.appendAssumeCapacity(left);
        }
    }
    i += 2;
    var line = try std.ArrayList(u8).initCapacity(alloc, 0);
    defer line.deinit(alloc);
    var disallowed = try std.ArrayList(u8).initCapacity(alloc, 0);
    defer disallowed.deinit(alloc);

    var sum: u32 = 0;
    while (i < input.len) {
        defer line.clearRetainingCapacity();
        defer disallowed.clearRetainingCapacity();
        var valid = true;
        while (i < input.len) : (i += 1) {
            const num = readInt(u8, input, &i);
            if (std.mem.containsAtLeast(u8, disallowed.items, 1, &.{num})) {
                valid = false;
            }
            try line.append(alloc, num);
            if (rules.get(num)) |rule| {
                try disallowed.appendSlice(alloc, rule.items);
            }
            if (input[i] != ',') {
                i += 2;
                break;
            }
        }
        if (!valid) {
            std.mem.sortUnstable(u8, line.items, rules, lessThan);
            sum += line.items[line.items.len / 2];
        }
    }
    return sum;
}

fn lessThan(rules: std.AutoHashMap(u8, std.ArrayList(u8)), lhs: u8, rhs: u8) bool {
    if (rules.get(lhs)) |rule| {
        return std.mem.containsAtLeast(u8, rule.items, 1, &.{rhs});
    }
    return false;
}
