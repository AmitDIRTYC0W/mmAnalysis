const std = @import("std");

const Buffer = @import("buffer.zig").Buffer;

pub const Decision = enum { hold, buy, sell };

pub const Backtest = struct {
    const Self = @This();

    history: *Buffer,
    cash: f16,
    shares: u16,

    present: usize,

    pub fn init(history: *Buffer, cash: f16) Self {
        return Self{
            .history = history,
            .cash = cash,
            .present = 0,
        };
    }

    pub fn update(self: *Self, decisions: []Decision) void {
        for (decisions) |decision| {
            switch (decision) {
                .hold => {},
                .buy => {
                    const price = self.history.*.get(self.present);
                    const quantity = @floatToInt(u16, @divFloor(cash, price));
                    shares += quantity;
                    cash %= price;
                },
                .sell => {
                    const price = self.history.*.get(self.present);
                    self.cash += shares * price;
                    self.price = 0;
                },
            }
            self.present += 1;
        }
    }
};

test "Backtest" {
    var source = Buffer.init(std.testing.allocator);
    defer source.deinit();

    try source.append(3);
    try source.append(1);
    try source.append(4);
    try source.append(1);
    try source.append(5);
    try source.append(9);

    var backtest = Backtest.init(&source, 100);
    backtest.update([_]Decision{ .buy, .hold, .sell });

    try std.testing.expectEqual(@as(f16, 132), backtest.cash);
}
