//! This file is not yet tested
const std = @import("std");

pub const Color = enum {
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,

    fn toAnsi(self: Color) []const u8 {
        return switch (self) {
            .Red => "\x1b[31m",
            .Green => "\x1b[32m",
            .Yellow => "\x1b[33m",
            .Blue => "\x1b[34m",
            .Magenta => "\x1b[35m",
            .Cyan => "\x1b[36m",
        };
    }
};

const RESET = "\x1b[0m";

// NOTE: BROKEN
pub fn print(color: Color, comptime fmt: []const u8, args: anytype) void {
    std.debug.print("{s}" ++ fmt ++ "{s}", .{ color.toAnsi(), args, RESET });
}

pub fn printStdout(color: Color, comptime fmt: []const u8, args: anytype) !void {
    try std.io.getStdOut().writer().print("{s}" ++ fmt ++ "{s}", .{ color.toAnsi(), args, RESET });
}

// pub fn main() !void {
// const zstb = @import("zstb");
//
// const color = zstb.color;
//
// color.print("NOW")
//     const stdout = std.io.getStdOut().writer();
//     try printColored(stdout, .Red, "Hello, this is red!\n", .{});
//     try printColored(stdout, .Green, "This is green!\n", .{});
//     try printColored(stdout, .Yellow, "Error: Something went wrong!\n", .{});
// }
