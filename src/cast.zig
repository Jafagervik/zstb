pub inline fn byteToInt(b: u8) i32 {
    return @as(i32, @intCast(b));
}

pub inline fn usizeToInt(u: usize) i32 {
    return @as(i32, @intCast(u));
}
