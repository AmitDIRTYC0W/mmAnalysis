const std = @import("std");

const Buffer = @import("buffer.zig").Buffer;
const Integral = @import("integral.zig").Integral;

pub const SMA = struct {
    const Self = @This();

    integral: *Integral,
    period: u16,

    multiplier: f16,

    pub fn init(integral: *Integral, period: u16) Self {
        return Self{
            .integral = integral,
            .period = period,
            .multiplier = 1.0 / @intToFloat(f16, period),
        };
    }

    pub fn avg(self: Self, last: u16) !f16 {
        return self.multiplier * try self.integral.sum(last - self.period, self.period);
    }
};

test "SMA" {
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

    var sma = SMA.init(&int, 3);

    try std.testing.expectEqual(@as(f16, 5), try sma.avg(6));
}
