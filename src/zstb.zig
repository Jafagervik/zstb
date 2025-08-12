const std = @import("std");

pub const strings = @import("strings.zig");
pub const types = @import("types.zig");
pub const color = @import("color.zig");

test {
    std.testing.refAllDeclsRecursive(@This());
}
