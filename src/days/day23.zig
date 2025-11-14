const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    const file = try std.fs.cwd().openFile("src/data/day23.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day23:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn nameToNum(name: []u8) u16 {
    std.debug.assert(name.len == 2);
    return (@as(u16, name[0] - 'a') << 5) | @as(u16, name[1] - 'a');
}

fn part1(alloc: std.mem.Allocator, input: []u8) !u32 {
    //32 preserves the first letter
    var connections: [32 * 26]?std.ArrayList(u16) = .{null} ** (32 * 26);
    defer {
        for (&connections) |*con_opt| {
            if (con_opt.*) |*con| {
                con.*.deinit(alloc);
            }
        }
    }
    var i: usize = 0;
    while (i < input.len - 2) {
        const comp1 = nameToNum(input[i .. i + 2]);
        const comp2 = nameToNum(input[i + 3 .. i + 5]);
        i += 7;
        if (connections[comp1]) |*con| {
            try con.append(alloc, comp2);
        } else {
            connections[comp1] = try std.ArrayList(u16).initCapacity(alloc, 1);
            connections[comp1].?.appendAssumeCapacity(comp2);
        }
        if (connections[comp2]) |*con| {
            try con.append(alloc, comp1);
        } else {
            connections[comp2] = try std.ArrayList(u16).initCapacity(alloc, 1);
            connections[comp2].?.appendAssumeCapacity(comp1);
        }
    }
    var count: u32 = 0;
    for (@as(usize, ('t' - 'a') << 5)..@as(usize, ('t' - 'a') << 5) | 26) |a| {
        if (connections[a]) |con_a| {
            for (con_a.items) |b| {
                if (b >> 5 == 't' - 'a' and b < a) continue; //ignore prev connection
                if (connections[b]) |con_b| {
                    for (con_b.items) |c| {
                        if (c >> 5 == 't' - 'a' and c < a) continue; //ignore prev connection
                        if (connections[c]) |con_c| {
                            if (std.mem.containsAtLeast(u16, con_c.items, 1, &.{@intCast(a)})) {
                                count += 1;
                            }
                        }
                    }
                }
            }
        }
    }

    return count / 2; //a,b,c == a,c,b
}
fn part2(alloc: std.mem.Allocator, input: []u8) !u32 {
    _ = alloc;
    _ = input;
    return 0;
}
