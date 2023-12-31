const std = @import("std");

const Buffer = @import("buffer.zig").Buffer;

// test "" {
//     const price = source.init();
//     const integral = Integral.init(price);
//     const ma = SMA.init(integral, 3);

//     while (true) {
//         price.source({1, 2, 3});
//         const res:[3]f16 = ma.pull();
//     }
// }

pub const Integral = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    source: *Buffer,
    values: Buffer,

    pub fn init(allocator: std.mem.Allocator, source: *Buffer) !Self {
        return Self{
            .allocator = allocator,
            .source = source,
            .values = creation: {
                var v = Buffer.init(allocator);
                try v.append(0);
                break :creation v;
            },
        };
    }

    pub fn deinit(self: Self) void {
        self.values.deinit();
    }

    pub fn update(self: *Self) !void {
        // Obtain the new values from the source
        const raw = self.source.items[self.values.items.len - 1 ..];

        // Remember what is the current sum thus far
        var current_sum = self.values.getLast();

        const new = try self.values.addManyAsSlice(raw.len);

        for (raw[0..], 0..) |value, i| {
            current_sum += value;
            new[i] = current_sum;
        }
    }

    pub fn sum(self: *Self, first: u16, amount: u16) !f16 {
        if (first + amount > self.values.items.len) {
            try self.update();
        }

        return self.values.items[first + amount] - self.values.items[first];
    }
};

test "Integral" {
    var source = Buffer.init(std.testing.allocator);
    defer source.deinit();

    try source.append(3);
    try source.append(1);
    try source.append(4);
    try source.append(1);
    try source.append(5);
    try source.append(9);

    var int = try Integral.init(std.testing.allocator, &source);
    defer int.deinit();

    try std.testing.expectEqual(@as(f16, 8), try int.sum(0, 3));
    try std.testing.expectEqual(@as(f16, 19), try int.sum(2, 4));

    try source.append(2);
    try source.append(6);

    try std.testing.expectEqual(@as(f16, 17), try int.sum(5, 3));
}

pub const Integral2 = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    source: *Buffer,
    values: Buffer,

    pub fn init(allocator: std.mem.Allocator, source: *Buffer) !Self {
        return Self{
            .allocator = allocator,
            .source = source,
            .values = creation: {
                var v = Buffer.init(allocator);
                try v.append(0);
                break :creation v;
            },
        };
    }

    pub fn deinit(self: Self) void {
        self.values.deinit();
    }

    fn update(self: *Self) !void {
        // Obtain the new values from the source
        const raw = self.source.items[self.values.items.len - 1 ..];

        // Remember what is the current sum thus far
        var current_sum = self.values.getLast();

        const new = try self.values.addManyAsSlice(raw.len);

        for (raw[0..], 0..) |value, i| {
            current_sum += value * value;
            new[i] = current_sum;
        }
    }

    pub fn sum(self: *Self, first: u16, amount: u16) !f16 {
        if (first + amount > self.values.items.len) {
            try self.update();
        }

        return self.values.items[first + amount] - self.values.items[first];
    }
};

test "Integral2" {
    var source = Buffer.init(std.testing.allocator);
    defer source.deinit();

    try source.append(3);
    try source.append(1);
    try source.append(4);
    try source.append(1);
    try source.append(5);
    try source.append(9);

    var int = try Integral2.init(std.testing.allocator, &source);
    defer int.deinit();

    try std.testing.expectEqual(@as(f16, 26), try int.sum(0, 3));
    try std.testing.expectEqual(@as(f16, 123), try int.sum(2, 4));

    try source.append(2);
    try source.append(6);

    try std.testing.expectEqual(@as(f16, 121), try int.sum(5, 3));
}
