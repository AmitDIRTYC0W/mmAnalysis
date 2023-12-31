// Lazy evaluation

test "" {
    const prices = History.init();
    const bbands = async bollinger_bands(prices)
}

// const bbands = async bollinger_bands(1, 2, 3, )


// Solution 1:
// const prices = async feed(...)
// const integral = async intergal(prices)
// const ma = async ma(integral, 3)
// const rstd = async rstd(integral, )

// Solution 2:
// const prices = async feed(...)
// const rstd = async rstd(prices)
// const ma = async rstd.ma

// Solution 3:
// const process = Process.init()
// process.add(RSTD{})

// Solution 4:
const process = Process.init(
    .{
        Input {
            
        },
        RSTD {
            .prices
        },
        MA {
            .prices,
            3,
        }
    }
);

process.input.feed([1, 2, 3])