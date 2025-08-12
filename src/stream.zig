//! Note: implement for collections

pub fn Stream(comptime T: type) type {
    return struct {
        /// Size of this stream
        size: usize = 0,
        /// Start index of this iterator
        start: usize = 0,

        const Self = @This();

        pub fn init() ?Stream(T) {
            return null;
        }

        pub fn map() Stream(T) {
            return Self{};
        }

        pub fn filter() Stream(T) {
            return Self{};
        }

        /// Returns a sorted version of this stream
        pub fn sorted(self: *Self) Stream(T) {
            _ = self;
            return Self{};
        }

        /// Skips `skip_num` amount of elements in the stream
        pub fn skip(self: *Self, skip_num: usize) Stream(T) {
            _ = self;
            _ = skip_num;
            return Self{};
        }

        /// Gets the amount of elements in this stream
        pub fn count(self: *Self) !usize {
            return self.size;
        }

        // Returns true if stream isEmpty
        pub fn isEmpty(self: *Self) bool {
            return self.size == 0;
        }

        pub fn findFirst(self: *Self) void {
            _ = self;
            return T;
        }

        pub fn findLast(self: *Self) void {
            _ = self;
            return T;
        }
    };
}

test "test stream" {
    const elems: [3][]const u8 = .{ "abc", "def", "ghi" };

    Stream([3][]const u8).of(elems).count();
}
