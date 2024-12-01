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

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    _ = args.next();
    if (args.next()) |day| {
        try days.selectDay(alloc, stdout, day);
    } else {
        try stdout.print("Give the day as an argument e.g. zig build run -- day01", .{});
    }
    try bw.flush();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
