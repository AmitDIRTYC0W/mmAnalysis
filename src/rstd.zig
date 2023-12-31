const std = @import("std");

const Buffer = @import("buffer.zig").Buffer;
const Integral = @import("integral.zig").Integral;
const Integral2 = @import("integral.zig").Integral2;

pub const RSTD = struct {
    const Self = @This();

    integral: *Integral,
    integral2: *Integral2,
    period: u16,

    multiplier: f16,

    pub fn init(integral: *Integral, integral2: *Integral2, period: u16) Self {
        return Self{
            .integral = integral,
            .integral2 = integral2,
            .period = period,
            .multiplier = 1 / @sqrt(@intToFloat(f16, period * (period - 1))),
        };
    }

    pub fn dev(self: Self, last: u16) !f16 {
        const sum2 = try self.integral2.sum(last - self.period, self.period);
        const sum = try self.integral.sum(last - self.period, self.period);
        return @sqrt(sum2 * @intToFloat(f16, self.period) - sum * sum) * self.multiplier;
    }
};

test "RSTD" {
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

    var int2 = try Integral2.init(std.testing.allocator, &source);
    defer int2.deinit();

    var rstd = RSTD.init(&int, &int2, 3);

    try std.testing.expectEqual(@as(f16, 4), try rstd.dev(6));
}
