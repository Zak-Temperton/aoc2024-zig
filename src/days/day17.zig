const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    const file = try std.fs.cwd().openFile("src/data/day17.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    defer alloc.free(p1);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day17:\n  part1: {s} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
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

fn part1(alloc: std.mem.Allocator, input: []const u8) ![]u8 {
    var i: usize = 12;
    var reg_a = readInt(u32, input, &i);
    i += 14;
    var reg_b = readInt(u32, input, &i);
    i += 14;
    var reg_c = readInt(u32, input, &i);
    i += 13;
    var program = try std.ArrayList(u32).initCapacity(alloc, (input.len - i) / 3 + 1);
    defer program.deinit(alloc);
    var output = try std.ArrayList(u8).initCapacity(alloc, 0);
    while (i < input.len - 1) : (i += 2) {
        try program.append(alloc, input[i] - '0');
    }
    i = 0;
    while (i < program.items.len) {
        const combo: u32 = switch (program.items[i + 1]) {
            0 => 0,
            1 => 1,
            2 => 2,
            3 => 3,
            4 => reg_a,
            5 => reg_b,
            6 => reg_c,
            else => 0,
        };
        switch (program.items[i]) {
            0 => { //adv
                reg_a = reg_a >> @truncate(combo);
                i += 2;
            },
            1 => { //bxl
                reg_b = reg_b ^ program.items[i + 1];
                i += 2;
            },
            2 => { //bst
                reg_b = combo & 0b111;
                i += 2;
            },
            3 => { //jnz
                if (reg_a == 0) {
                    i += 2;
                } else {
                    i = program.items[i + 1];
                }
            },
            4 => { //bxc
                reg_b = reg_b ^ combo;
                i += 2;
            },
            5 => { //out
                try output.append(alloc, @truncate('0' + (combo & 0b111)));
                try output.append(alloc, ',');
                i += 2;
            },
            6 => { //bdv
                reg_b = reg_a >> @truncate(combo);
                i += 2;
            },
            7 => { //cdv
                reg_c = reg_a >> @truncate(combo);
                i += 2;
            },
            else => {},
        }
    }
    _ = output.pop();

    return output.toOwnedSlice(alloc);
}

//24 bst b = a & 0b111
//17 bxl b ^= 0b111
//75 cdv c = a >> b
//17 bxl b ^ 0b111
//46 bxc b ^= c
//03 adv a >> 3
//55 out
//30 jnz
//
//hard coded testing
fn part2b() u128 {
    const program: [16]u32 = .{ 2, 4, 1, 7, 7, 5, 1, 7, 4, 6, 0, 3, 5, 5, 3, 0 };

    var start: u128 = 1;
    var inc: u128 = 1;
    var max: u128 = 2;

    restart: while (true) : (start += inc) {
        var reg_a: u128 = start;
        var reg_b: u128 = 0;
        var i: usize = 0;

        while (reg_a != 0) {
            reg_b = (reg_a & 0b111) ^ (reg_a >> @truncate((reg_a & 0b111) ^ 0b111));
            reg_a >>= 3;
            if (i == program.len or program[i] != reg_b & 0b111) {
                if (i > max) {
                    max = i;
                    inc = @as(u64, 1) << @truncate(3 * (max - 3));
                }
                continue :restart;
            }
            i += 1;
        }
        if (i == program.len) return start;
    }
    return 0;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u64 {
    var i: usize = 12;
    var reg_a = readInt(u64, input, &i);
    i += 14;
    var reg_b = readInt(u64, input, &i);
    i += 14;
    var reg_c = readInt(u64, input, &i);
    i += 13;
    reg_a = 0;
    var program = try std.ArrayList(u32).initCapacity(alloc, (input.len - i) / 3 + 1);
    defer program.deinit(alloc);
    while (i < input.len - 1) : (i += 2) {
        try program.append(alloc, input[i] - '0');
    }
    var start: u64 = 0;
    var j: usize = 0;

    var inc: u64 = 1;
    var max: u64 = 2;

    restart: while (true) : (start += inc) {
        reg_a = start;
        reg_b = 0;
        reg_c = 0;
        i = 0;
        j = 0;
        while (i < program.items.len) {
            const combo: u64 = switch (program.items[i + 1]) {
                0 => 0,
                1 => 1,
                2 => 2,
                3 => 3,
                4 => reg_a,
                5 => reg_b,
                6 => reg_c,
                else => 0,
            };
            switch (program.items[i]) {
                0 => { //adv
                    reg_a = reg_a >> @truncate(combo);
                    i += 2;
                },
                1 => { //bxl
                    reg_b = reg_b ^ program.items[i + 1];
                    i += 2;
                },
                2 => { //bst
                    reg_b = combo & 0b111;
                    i += 2;
                },
                3 => { //jnz
                    if (reg_a == 0) {
                        i += 2;
                    } else {
                        i = program.items[i + 1];
                    }
                },
                4 => { //bxc
                    reg_b = reg_b ^ combo;
                    i += 2;
                },
                5 => { //out
                    if (j == program.items.len or (combo & 0b111) != program.items[j]) {
                        if (j > max) {
                            max = j;
                            inc = @as(u64, 1) << @truncate(3 * (max - 3));
                        }
                        continue :restart;
                    } else {
                        j += 1;
                        i += 2;
                    }
                },
                6 => { //bdv
                    reg_b = reg_a >> @truncate(combo);
                    i += 2;
                },
                7 => { //cdv
                    reg_c = reg_a >> @truncate(combo);
                    i += 2;
                },
                else => {},
            }
        }
        if (j == program.items.len)
            return start;
    }
}
