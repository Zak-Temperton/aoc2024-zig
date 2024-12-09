const std = @import("std");

pub const day01 = @import("days/day01.zig");
pub const day02 = @import("days/day02.zig");
pub const day03 = @import("days/day03.zig");
pub const day04 = @import("days/day04.zig");
pub const day05 = @import("days/day05.zig");
pub const day06 = @import("days/day06.zig");
pub const day07 = @import("days/day07.zig");
pub const day08 = @import("days/day08.zig");
pub const day09 = @import("days/day09.zig");
//pub const day10 = @import("days/day10.zig");
//pub const day11 = @import("days/day11.zig");
//pub const day12 = @import("days/day12.zig");
//pub const day13 = @import("days/day13.zig");
//pub const day14 = @import("days/day14.zig");
//pub const day15 = @import("days/day15.zig");
//pub const day16 = @import("days/day16.zig");
//pub const day17 = @import("days/day17.zig");
//pub const day18 = @import("days/day18.zig");
//pub const day19 = @import("days/day19.zig");
//pub const day20 = @import("days/day20.zig");
//pub const day21 = @import("days/day21.zig");
//pub const day22 = @import("days/day22.zig");
//pub const day23 = @import("days/day23.zig");
//pub const day24 = @import("days/day24.zig");
//pub const day25 = @import("days/day25.zig");

pub const Day = enum {
    day01,
    day02,
    day03,
    day04,
    day05,
    day06,
    day07,
    day08,
    day09,
    day10,
    day11,
    day12,
    day13,
    day14,
    day15,
    day16,
    day17,
    day18,
    day19,
    day20,
    day21,
    day22,
    day23,
    day24,
    day25,
    all,
};

pub const days = std.StaticStringMap(Day).initComptime(.{
    .{ "day01", .day01 },
    .{ "day02", .day02 },
    .{ "day03", .day03 },
    .{ "day04", .day04 },
    .{ "day05", .day05 },
    .{ "day06", .day06 },
    .{ "day07", .day07 },
    .{ "day08", .day08 },
    .{ "day09", .day09 },
    .{ "day10", .day10 },
    .{ "day11", .day11 },
    .{ "day12", .day12 },
    .{ "day13", .day13 },
    .{ "day14", .day14 },
    .{ "day15", .day15 },
    .{ "day16", .day16 },
    .{ "day17", .day17 },
    .{ "day18", .day18 },
    .{ "day19", .day19 },
    .{ "day20", .day20 },
    .{ "day21", .day21 },
    .{ "day22", .day22 },
    .{ "day23", .day23 },
    .{ "day24", .day24 },
    .{ "day25", .day25 },
    .{ "all", .all },
});

pub fn selectDay(alloc: std.mem.Allocator, stdout: anytype, input_day: []const u8) !void {
    if (days.get(input_day)) |day_enum| {
        switch (day_enum) {
            .day01 => try day01.run(alloc, stdout),
            .day02 => try day02.run(alloc, stdout),
            .day03 => try day03.run(alloc, stdout),
            .day04 => try day04.run(alloc, stdout),
            .day05 => try day05.run(alloc, stdout),
            .day06 => try day06.run(alloc, stdout),
            .day07 => try day07.run(alloc, stdout),
            .day08 => try day08.run(alloc, stdout),
            .day09 => try day09.run(alloc, stdout),
            //.day10 => try day10.run(alloc, stdout),
            //.day11 => try day11.run(alloc, stdout),
            //.day12 => try day12.run(alloc, stdout),
            //.day13 => try day13.run(alloc, stdout),
            //.day14 => try day14.run(alloc, stdout),
            //.day15 => try day15.run(alloc, stdout),
            //.day16 => try day16.run(alloc, stdout),
            //.day17 => try day17.run(alloc, stdout),
            //.day18 => try day18.run(alloc, stdout),
            //.day19 => try day19.run(alloc, stdout),
            //.day20 => try day20.run(alloc, stdout),
            //.day21 => try day21.run(alloc, stdout),
            //.day22 => try day22.run(alloc, stdout),
            //.day23 => try day23.run(alloc, stdout),
            //.day24 => try day24.run(alloc, stdout),
            //.day25 => try day25.run(alloc, stdout),
            .all => {
                try day01.run(alloc, stdout);
                try day02.run(alloc, stdout);
                try day03.run(alloc, stdout);
                try day04.run(alloc, stdout);
                try day05.run(alloc, stdout);
                try day06.run(alloc, stdout);
                try day07.run(alloc, stdout);
                try day08.run(alloc, stdout);
                try day09.run(alloc, stdout);
                //try day10.run(alloc, stdout);
                //try day11.run(alloc, stdout);
                //try day12.run(alloc, stdout);
                //try day13.run(alloc, stdout);
                //try day14.run(alloc, stdout);
                //try day15.run(alloc, stdout);
                //try day16.run(alloc, stdout);
                //try day17.run(alloc, stdout);
                //try day18.run(alloc, stdout);
                //try day19.run(alloc, stdout);
                //try day20.run(alloc, stdout);
                //try day21.run(alloc, stdout);
                //try day22.run(alloc, stdout);
                //try day23.run(alloc, stdout);
                //try day24.run(alloc, stdout);
                //try day25.run(alloc, stdout);
            },
            else => {
                try stdout.print("invalid day\n", .{});
                try stdout.print("Give the day as an argument e.g. zig build run -- day01", .{});
            },
        }
    } else {
        try stdout.print("invalid day\n", .{});
        try stdout.print("Give the day as an argument e.g. zig build run -- day01", .{});
    }
}
