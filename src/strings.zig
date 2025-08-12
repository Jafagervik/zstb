const std = @import("std");
const cast = @import("cast.zig");
const StringSplitIterator = std.mem.SplitIterator(u8, .any);

// NOTE: Not tested
pub inline fn split(s: []const u8, delim: []const u8) StringSplitIterator {
    return std.mem.splitAny(u8, s, delim);
}

/// Compares two string slices lexicographically.
///
/// It returns:
/// - A negative value if `str1` is lexicographically less than `str2`.
/// - A positive value if `str1` is lexicographically greater than `str2`.
/// - 0 if the strings are equal.
///
/// The comparison is based on the ASCII values of the characters (bytes).
pub fn compare(str1: []const u8, str2: []const u8) i32 {
    if (eql(str1, str2)) return 0;
    const min_len = @min(str1.len, str2.len);

    for (0..min_len) |i| {
        const char1 = str1[i];
        const char2 = str2[i];

        if (char1 != char2) {
            return cast.byteToInt(char1) - cast.byteToInt(char2);
        }
    }

    return cast.usizeToInt(str1.len) - cast.usizeToInt(str2.len);
}

// NOTE: These two should be moved

test "compare string" {
    const apple = "apple";
    const banana = "banana";
    const hello = "hello";

    try std.testing.expectEqual(0, compare(apple, apple));
    try std.testing.expectEqual(-1, compare(apple, banana));
    try std.testing.expectEqual(1, compare(banana, apple));
    try std.testing.expectEqual(-7, compare(apple, hello));
    try std.testing.expectEqual(6, compare(hello, banana));
}

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
    const total_len = blk: {
        var sum: usize = 0;
        for (strings) |s| sum += s.len;
        sum += delimiter.len * (strings.len - 1);
        break :blk sum;
    };

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

/// Converts an ASCII character to its uppercase equivalent.
/// Returns the character unchanged if it's not a lowercase ASCII letter.
pub inline fn asciiToUpper(c: u8) u8 {
    if (c >= 'a' and c <= 'z') {
        return c - 'a' + 'A';
    }
    return c;
}

/// Converts an ASCII string to uppercase.
/// Allocates a new string for the result.
/// Returns an error if memory allocation fails.
pub fn toUpper(allocator: std.mem.Allocator, s: []const u8) ![]const u8 {
    var upper_str = try allocator.alloc(u8, s.len);
    for (s, 0..) |char_byte, i| upper_str[i] = asciiToUpper(char_byte);
    return upper_str;
}

test "toUpper string" {
    const a = "aaaa";

    const out = try toUpper(std.testing.allocator, a);
    defer std.testing.allocator.free(out);

    try std.testing.expect(eql("AAAA", out));
}

/// Converts an ASCII character to its lowercase equivalent.
/// Returns the character unchanged if it's not an uppercase ASCII letter.
pub inline fn asciiToLower(c: u8) u8 {
    if (c >= 'A' and c <= 'Z') {
        return c - 'A' + 'a';
    }
    return c;
}

/// Converts an ASCII string to lowercase.
/// Allocates a new string for the result.
/// Returns an error if memory allocation fails.
pub fn toLower(allocator: std.mem.Allocator, s: []const u8) ![]const u8 {
    var lower_str = try allocator.alloc(u8, s.len);
    for (s, 0..) |char_byte, i| lower_str[i] = asciiToLower(char_byte);
    return lower_str;
}

test "toLower string" {
    const b = "bBbB";

    const out = try toLower(std.testing.allocator, b);
    defer std.testing.allocator.free(out);

    try std.testing.expect(eql("bbbb", out));
}

// pub fn replace(alloc: std.mem.Allocator, s: []const u8, old: []const u8, new: []const u8) ![]const u8 {}

pub fn trim(s: []const u8) []const u8 {
    var start: usize = 0;
    var end: usize = s.len;

    while (start < end and isWhitespace(s[start])) : (start += 1) {}

    while (end > start and isWhitespace(s[end - 1])) : (end -= 1) {}

    return s[start..end];
}

test "trim string" {
    const inputs: [6][]const u8 = .{
        "   hello world   ",
        "no trim",
        "   ",
        "",
        "\t\nleading and trailing\r\n",
        " a ",
    };

    const expected: [6][]const u8 = .{
        "hello world",
        "no trim",
        "",
        "",
        "leading and trailing",
        "a",
    };

    inline for (expected, inputs) |exp, act| {
        try std.testing.expect(eql(exp, trim(act)));
    }
}

// =========================
// Chars
// =========================

/// Checks char at a certain index in a safe manner
/// If idx is out of bounds, it returns none
pub inline fn charAt(s: []const u8, idx: usize) ?u8 {
    if (idx >= s.len) return null;
    return s[idx];
}

test "char string" {
    const a = "";
    const b = "a";
    const c = "bccccccccc";

    try std.testing.expectEqual(null, charAt(a, 0));
    try std.testing.expectEqual('a', charAt(b, 0));
    try std.testing.expectEqual(null, charAt(b, 1));
    try std.testing.expectEqual('b', charAt(c, 0));
    try std.testing.expectEqual('c', charAt(c, 5));
    try std.testing.expectEqual(null, charAt(c, 12341));
}

pub inline fn first(s: []const u8) ?u8 {
    if (isEmpty(s)) return null;
    return s[0];
}

test "first string" {
    const a = "";
    const b = "a";
    const c = "bccccccccc";

    try std.testing.expectEqual(null, first(a));
    try std.testing.expectEqual('a', first(b));
    try std.testing.expectEqual('b', first(c));
}

pub inline fn last(s: []const u8) ?u8 {
    if (isEmpty(s)) return null;
    return s[s.len - 1];
}

test "last string" {
    const a = "";
    const b = "b";
    const c = "bccccccccc";

    try std.testing.expectEqual(null, last(a));
    try std.testing.expectEqual('b', last(b));
    try std.testing.expectEqual('c', last(c));
}

pub inline fn toChar(s: []const u8) ?u8 {
    return if (s.len == 1) s[0] else null;
}

test "toChar string" {
    const a = "aa";
    const b = "b";

    try std.testing.expectEqual(null, toChar(a));
    try std.testing.expectEqual('b', toChar(b));
}

pub inline fn charToString(allocator: std.mem.Allocator, c: u8) ![]const u8 {
    const str_slice = try allocator.alloc(u8, 1);
    str_slice[0] = c;
    return str_slice;
}

test "charToString string" {
    const a = 'a';

    const out = try charToString(std.testing.allocator, a);
    defer std.testing.allocator.free(out);

    try std.testing.expect(eql("a", out));
}

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
