const std = @import("std");

/// Joins a list of strings with designated separator
///
/// Usage:
///     `
///     const items: [3][]const u8 = .{"a", "b", "c"}
///     const newStr = try stringJoin(alloc, items, ",");
///     defer alloc.free(newStr)
///     // Result becomes "a,b,c"
///     `
pub fn join(allocator: std.mem.Allocator, strings: []const []const u8, delimiter: []const u8) ![]const u8 {
    if (strings.len == 0) return allocator.alloc(u8, 0);

    // Calculate total length: sum of string lengths + separators
    var total_len: usize = 0;
    for (strings) |s| {
        total_len += s.len;
    }
    total_len += delimiter.len * (strings.len - 1);

    // Allocate memory for the result
    var result = try allocator.alloc(u8, total_len);
    var offset: usize = 0;

    for (strings, 0..) |s, i| {
        @memcpy(result[offset .. offset + s.len], s);
        offset += s.len;
        if (i < strings.len - 1) {
            @memcpy(result[offset .. offset + delimiter.len], delimiter);
            offset += delimiter.len;
        }
    }

    return result;
}

test "string join" {
    const alloc = std.testing.allocator;

    const strings: [4][]const u8 = .{ "a", "b", "c", "d" };

    const out = try join(alloc, &strings, "-");
    defer alloc.free(out);

    try std.testing.expect(std.mem.eql(u8, "a-b-c-d", out));
}

pub fn concat(allocator: std.mem.Allocator, a: []const u8, b: []const u8) ![]const u8 {
    // if the new is empty, return
    if (isEmpty(b)) return a;

    const total_len: usize = a.len + b.len;

    var result = try allocator.alloc(u8, total_len);

    @memcpy(result[0..a.len], a);
    @memcpy(result[a.len..total_len], b);

    return result;
}

test "string concat" {
    const alloc = std.testing.allocator;

    const a = "Hello";
    const b = "World";

    const out = try concat(alloc, a, b);
    defer alloc.free(out);

    try std.testing.expect(std.mem.eql(u8, "HelloWorld", out));
}

pub inline fn isEmpty(str: []const u8) bool {
    return str.len == 0;
}

test "empty string" {
    try std.testing.expectEqual(true, isEmpty(""));
    try std.testing.expectEqual(false, isEmpty(" "));
    try std.testing.expectEqual(false, isEmpty("asskd_"));
}

pub inline fn isNullOrEmpty(str: ?[]const u8) bool {
    if (str) |s| return isEmpty(s);
    return true;
}

test "null or empty string" {
    try std.testing.expectEqual(true, isNullOrEmpty(null));
    try std.testing.expectEqual(true, isNullOrEmpty(""));
    try std.testing.expectEqual(false, isNullOrEmpty(" "));
    try std.testing.expectEqual(false, isNullOrEmpty("asskd_"));
}

// pub fn contains(haystack: []const u8, elem: []const u8) !bool {
//     // for (haystack, 0..) |h, i| {
//     //     for (elem, 0..) |e, j| {}
//     // }
//     return true;
// }
//
// test "contains string" {
//     try std.testing.expectEqual(true, isNullOrEmpty(null));
// }

pub inline fn eql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

test "eql string" {
    try std.testing.expectEqual(true, eql("a", "a"));
    try std.testing.expectEqual(true, eql("", ""));
    try std.testing.expectEqual(false, eql(" ", "_"));
    try std.testing.expectEqual(false, eql(" ", "  "));
}

// =========================
// Chars
// =========================

pub inline fn isWhitespace(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\r' or c == '\n' or c == '\x0B' or c == '\x0C';
}

test "whitespace string" {
    try std.testing.expectEqual(true, isWhitespace(' '));
    try std.testing.expectEqual(true, isWhitespace('\n'));
    try std.testing.expectEqual(true, isWhitespace('\t'));
    try std.testing.expectEqual(false, isWhitespace('_'));
}

pub inline fn isAlpha(c: u8) bool {
    return (c | 0x20) >= 'a' and (c | 0x20) <= 'z';
}

test "alpha string" {
    try std.testing.expectEqual(true, isAlpha('a'));
    try std.testing.expectEqual(true, isAlpha('z'));
    try std.testing.expectEqual(true, isAlpha('A'));
    try std.testing.expectEqual(true, isAlpha('Z'));
    try std.testing.expectEqual(false, isAlpha('_'));
}

/// 10 is the base
pub inline fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

test "digit char" {
    try std.testing.expectEqual(true, isDigit('0'));
    try std.testing.expectEqual(true, isDigit('1'));
    try std.testing.expectEqual(true, isDigit('2'));
    try std.testing.expectEqual(true, isDigit('3'));
    try std.testing.expectEqual(true, isDigit('4'));
    try std.testing.expectEqual(true, isDigit('5'));
    try std.testing.expectEqual(true, isDigit('6'));
    try std.testing.expectEqual(true, isDigit('7'));
    try std.testing.expectEqual(true, isDigit('8'));
    try std.testing.expectEqual(true, isDigit('9'));
    try std.testing.expectEqual(false, isDigit('z'));
}

// NOTE: Allow _?
pub inline fn isNumeric(s: []const u8) bool {
    for (s) |c| {
        if (!isDigit(c)) return false;
    }
    return true;
}

test "isNumeric string" {
    try std.testing.expectEqual(true, isNumeric("123"));

    try std.testing.expectEqual(false, isNumeric("a123"));
    try std.testing.expectEqual(false, isNumeric("1_23"));
    try std.testing.expectEqual(false, isNumeric("123_"));
    try std.testing.expectEqual(false, isNumeric(" 123"));
    try std.testing.expectEqual(false, isNumeric(" 1 2 3 "));
}

// Note: hex

// FIXME: Should this be a string instead?
pub inline fn isAlphanumeric(c: u8) bool {
    _ = c;
    return false;
}
