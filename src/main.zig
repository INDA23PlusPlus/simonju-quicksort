const std = @import("std");

const N = 500_000;
var BYTE_BUFFER: [N * 12]u8 align(@alignOf(i32)) = undefined;
var INT_BUFFER: [N]i32 = undefined;

pub fn main() !void {
    _ = try std.io.getStdIn().readAll(&BYTE_BUFFER);

    var length: usize = 0;

    var i: usize = 0;
    while ('0' <= BYTE_BUFFER[i] and BYTE_BUFFER[i] <= '9') : (i += 1) {
        length = length * 10 + BYTE_BUFFER[i] - '0';
    }

    for (0..length) |j| {
        i += 1;
        const sign: i32 = if (BYTE_BUFFER[i] == '-') a: {
            i += 1;
            break :a -1;
        } else 1;

        var parsed: i32 = 0;
        while ('0' <= BYTE_BUFFER[i] and BYTE_BUFFER[i] <= '9') : (i += 1) {
            parsed = parsed * 10 + BYTE_BUFFER[i] - '0';
        }

        INT_BUFFER[j] = parsed * sign;
    }

    const array = INT_BUFFER[0..length];

    iterative_quicksort_3wp(array);

    var writer = buffered_writer(std.io.getStdOut().writer());
    var w = writer.writer();

    for (array) |element| {
        try w.print("{} ", .{element});
    }

    try writer.flush();
}

inline fn buffered_writer(underlying_stream: anytype) std.io.BufferedWriter(N, @TypeOf(underlying_stream)) {
    return .{ .unbuffered_writer = underlying_stream };
}

var rng = std.rand.DefaultPrng.init(0);

var TOP: usize = undefined;
var STACK: [N]usize = undefined;

inline fn iterative_quicksort_3wp(array: []i32) void {
    if (array.len <= 1) return;

    push(0);
    push(array.len);

    while (TOP >= 2) {
        const hi = pop();
        const lo = pop();

        if (hi <= lo + 1) continue;

        if (hi <= lo + 10) {
            insertionsort(array[lo..hi]);
            continue;
        }

        const pivot_index = rng.next() % (hi - lo) + lo;
        swap(array, pivot_index, hi - 1);
        const pivot: i32 = array[hi - 1];

        var low: usize = lo;
        var mid: usize = lo;
        var high: usize = hi - 1;

        while (mid <= high) {
            if (array[mid] < pivot) {
                swap(array, mid, low);
                low += 1;
                mid += 1;
            } else if (array[mid] > pivot) {
                swap(array, mid, high);
                high -= 1;
            } else {
                mid += 1;
            }
        }

        push(mid);
        push(hi);
        push(lo);
        push(low);
    }
}

inline fn insertionsort(array: []i32) void {
    for (1..array.len) |i| {
        const key = array[i];

        var j = i;
        while (j > 0 and array[j - 1] > key) : (j -= 1) {
            array[j] = array[j - 1];
        }

        array[j] = key;
    }
}

inline fn swap(array: []i32, i: usize, j: usize) void {
    const tmp = array[i];
    array[i] = array[j];
    array[j] = tmp;
}

inline fn push(x: usize) void {
    STACK[TOP] = x;
    TOP += 1;
}

inline fn pop() usize {
    TOP -= 1;
    return STACK[TOP];
}
