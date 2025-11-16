const std = @import("std");

pub fn run(alloc: std.mem.Allocator, stdout: *std.io.Writer) !void {
    const file = try std.fs.cwd().openFile("src/data/day24.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    defer alloc.free(p2);
    const p2_time = timer.read();
    try stdout.print("Day24:\n  part1: {d} {d}ns\n  part2: {s} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn readInt(input: []u8) u6 {
    return @as(u6, @truncate((input[0] - '0') * 10 + input[1] - '0'));
}

const Register = union(enum) {
    const Self = @This();
    x: u6,
    y: u6,
    z: u6,
    r: u16,

    fn parse(input: []u8) Self {
        return switch (input[0]) {
            'x' => .{ .x = readInt(input[1..]) },
            'y' => .{ .y = readInt(input[1..]) },
            'z' => .{ .z = readInt(input[1..]) },
            else => .{ .r = @truncate((@as(u16, input[0] - 'a') << 10) | (@as(u16, input[1] - 'a') << 5) | (input[2] - 'a')) },
        };
    }

    fn print(self: Self) [3]u8 {
        return switch (self) {
            .x => |x| .{
                'x',
                @intCast(x / 10 + '0'),
                @intCast(x % 10 + '0'),
            },
            .y => |y| .{
                'y',
                @intCast(y / 10 + '0'),
                @intCast(y % 10 + '0'),
            },
            .z => |z| .{
                'z',
                @intCast(z / 10 + '0'),
                @intCast(z % 10 + '0'),
            },
            .r => |r| .{
                @truncate((r >> 10) + 'a'),
                @truncate(((r >> 5) & 0b11111) + 'a'),
                @truncate((r & 0b11111) + 'a'),
            },
        };
    }

    fn lth(left: Self, right: Self) bool {
        switch (left) {
            .r => |lr| switch (right) {
                .r => |rr| return lr < rr,
                .x, .y, .z => return true,
            },
            .x => |lx| switch (right) {
                .r => return false,
                .x => |rx| return lx < rx,
                .y, .z => return true,
            },
            .y => |ly| switch (right) {
                .r, .x => return false,
                .y => |ry| return ly < ry,
                .z => return true,
            },
            .z => |lz| switch (right) {
                .r, .x, .y => return false,
                .z => |rz| return lz < rz,
            },
        }
    }
};

const Gate = enum {
    AND,
    XOR,
    OR,
};

const Instruction = struct {
    const Self = @This();

    left: Register,
    right: Register,
    gate: Gate,
    result: ?u1,

    fn parse(input: []u8) Self {
        const left = Register.parse(input);
        var gate: ?Gate = null;
        var right: ?Register = null;
        switch (input[4]) {
            'A' => {
                gate = Gate.AND;
                right = Register.parse(input[8..]);
            },
            'X' => {
                gate = Gate.XOR;
                right = Register.parse(input[8..]);
            },
            'O' => {
                gate = Gate.OR;
                right = Register.parse(input[7..]);
            },
            else => unreachable,
        }
        return .{
            .left = left,
            .right = right.?,
            .gate = gate.?,
            .result = null,
        };
    }
};

const Emulator = struct {
    const Self = @This();

    x: u64,
    y: u64,
    z: u64,
    r: std.AutoHashMap(u16, u1),
    program: std.AutoHashMap(Register, Instruction),

    fn init(alloc: std.mem.Allocator, input: []u8) !Self {
        var emulator = Emulator{
            .x = 0,
            .y = 0,
            .z = 0,
            .r = std.AutoHashMap(u16, u1).init(alloc),
            .program = std.AutoHashMap(Register, Instruction).init(alloc),
        };
        errdefer emulator.deinit();
        var i: usize = 0;
        var n: u6 = 0;
        //init x register
        while (input[i] == 'x') : (i += 8) {
            emulator.x |= @as(u64, input[i + 5] - '0') << n;
            n += 1;
        }
        n = 0;
        //init y register
        while (input[i] == 'y') : (i += 8) {
            emulator.y |= @as(u64, input[i + 5] - '0') << n;
            n += 1;
        }
        i += 2;

        //create program
        while (i < input.len) {
            const instruction = Instruction.parse(input[i..]);
            if (instruction.gate == .OR) {
                i += 14;
            } else {
                i += 15;
            }
            const target_reg = Register.parse(input[i..]);
            i += 5;
            try emulator.program.put(target_reg, instruction);
        }

        return emulator;
    }

    fn deinit(self: *Self) void {
        self.r.deinit();
        self.program.deinit();
    }

    fn run(self: *Self) void {
        var i: u6 = 0;
        while (self.program.getPtr(.{ .z = i })) |instr| : (i += 1) {
            self.z |= @as(u64, self.processIntruction(instr)) << i;
        }
    }

    fn processIntruction(self: *Self, instr: *Instruction) u1 {
        if (instr.result) |res| {
            return res;
        }
        const l: u1 = switch (instr.left) {
            .x => |x| @truncate((self.x >> x) & 1),
            .y => |y| @truncate((self.y >> y) & 1),
            .z => unreachable,
            .r => |r| res: {
                if (self.r.get(r)) |res| {
                    break :res res;
                } else {
                    break :res self.processIntruction(self.program.getPtr(.{ .r = r }).?);
                }
            },
        };
        const r: u1 = switch (instr.right) {
            .x => |x| @truncate((self.x >> x) & 1),
            .y => |y| @truncate((self.y >> y) & 1),
            .z => unreachable,
            .r => |r| res: {
                if (self.r.get(r)) |res| {
                    break :res res;
                } else {
                    break :res self.processIntruction(self.program.getPtr(.{ .r = r }).?);
                }
            },
        };
        const res = switch (instr.gate) {
            .AND => l & r,
            .XOR => l ^ r,
            .OR => l | r,
        };
        instr.result = res;
        return res;
    }
};

fn part1(alloc: std.mem.Allocator, input: []u8) !u64 {
    var emulator = try Emulator.init(alloc, input);
    defer emulator.deinit();

    emulator.run();
    return emulator.z;
}

const Wire = struct {
    const Self = @This();

    left: Register,
    right: Register,
    gate: Gate,

    fn parse(input: []u8) Self {
        const first = Register.parse(input);
        switch (input[4]) {
            'A' => return .{
                .left = first,
                .gate = Gate.AND,
                .right = Register.parse(input[8..]),
            },
            'X' => return .{
                .left = first,
                .gate = Gate.XOR,
                .right = Register.parse(input[8..]),
            },
            'O' => return .{
                .left = first,
                .gate = Gate.OR,
                .right = Register.parse(input[7..]),
            },
            else => unreachable,
        }
    }
};

fn part2(alloc: std.mem.Allocator, input: []u8) ![]u8 {
    var i: usize = 0;
    while (input[i] != '\r') : (i += 8) {}
    i += 2;
    var program = std.AutoHashMap(Wire, Register).init(alloc);
    defer program.deinit();
    while (i < input.len) {
        const wire = Wire.parse(input[i..]);
        if (wire.gate == .OR) {
            i += 14;
        } else {
            i += 15;
        }
        const target_reg = Register.parse(input[i..]);
        i += 5;
        try program.put(wire, target_reg);
        try program.put(.{ .left = wire.right, .right = wire.left, .gate = wire.gate }, target_reg);
    }

    var swaps = try std.ArrayList(Register).initCapacity(alloc, 8);
    defer swaps.deinit(alloc);

    var carry = program.getPtr(.{ .left = .{ .x = 0 }, .right = .{ .y = 0 }, .gate = .AND }).?;
    for (1..45) |j| {
        const z: u6 = @truncate(j);
        const xy_xor = program.getPtr(.{ .left = .{ .x = z }, .right = .{ .y = z }, .gate = .XOR }).?;
        const xy_and = program.getPtr(.{ .left = .{ .x = z }, .right = .{ .y = z }, .gate = .AND }).?;

        if (program.getPtr(.{ .left = carry.*, .right = xy_xor.*, .gate = .XOR }) == null) {
            _ = try searchForRegister(alloc, carry, xy_xor, .XOR, &program, &swaps);
        }

        const carryxy_and = block: {
            if (program.getPtr(.{ .left = carry.*, .right = xy_xor.*, .gate = .AND })) |found| {
                break :block found;
            } else {
                break :block (try searchForRegister(alloc, carry, xy_xor, .AND, &program, &swaps)).?;
            }
        };
        const xycarryxy_or = block: {
            if (program.getPtr(.{ .left = xy_and.*, .right = carryxy_and.*, .gate = .OR })) |found| {
                break :block found;
            } else {
                break :block (try searchForRegister(alloc, xy_and, carryxy_and, .OR, &program, &swaps)).?;
            }
        };
        carry = xycarryxy_or;
    }

    std.mem.sort(Register, swaps.items, {}, asc);

    var output = try std.ArrayList(u8).initCapacity(alloc, 4 * 8 + 1);

    for (swaps.items) |swap| {
        try output.appendSlice(alloc, &swap.print());
        try output.append(alloc, ',');
    }
    _ = output.pop();

    return output.toOwnedSlice(alloc);
}

fn asc(_: void, left: Register, right: Register) bool {
    return left.lth(right);
}

fn searchForRegister(
    alloc: std.mem.Allocator,
    left: *Register,
    right: *Register,
    gate: Gate,
    program: *std.AutoHashMap(Wire, Register),
    swaps: *std.ArrayList(Register),
) !?*Register {
    var val_iter = program.valueIterator();
    while (val_iter.next()) |val| {
        if (program.getPtr(.{ .left = left.*, .right = val.*, .gate = gate })) |ptr| {
            std.mem.swap(Register, val, right);
            try swaps.append(alloc, val.*);
            try swaps.append(alloc, right.*);
            return ptr;
        }
        if (program.getPtr(.{ .left = val.*, .right = right.*, .gate = gate })) |ptr| {
            std.mem.swap(Register, left, val);
            try swaps.append(alloc, val.*);
            try swaps.append(alloc, left.*);
            return ptr;
        }
    }
    return null;
}
