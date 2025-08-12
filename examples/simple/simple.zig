const std = @import("std");
const zstb = @import("zstb");
const strings = zstb.strings;

pub fn main() !void {
    const a = "a";
    const b = "b";

    const isSame = strings.eql(a, b);
    std.debug.print("{any}\n", .{isSame});
}
