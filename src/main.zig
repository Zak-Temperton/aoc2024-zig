const std = @import("std");
const GPA = std.heap.GeneralPurposeAllocator(.{});

const days = @import("days.zig");

pub fn main() !void {
    //create General Purpose Allocator
    var gpa = GPA{};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var stdout_buffer: [1024]u8 = undefined;
    const stdout_file = std.fs.File.stdout();
    var stdout_writer = stdout_file.writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    _ = args.next();
    if (args.next()) |day| {
        try days.selectDay(alloc, stdout, day);
    } else {
        try stdout.print("Give the day as an argument e.g. zig build run -- day01", .{});
    }
    try stdout.flush();
}
