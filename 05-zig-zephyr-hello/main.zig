// SPDX-License-Identifier: Apache-2.0
// Zig main program

const std = @import("std");
const zephyr = @import("zephyr.zig");

// Setup Zig's logging to output through Zephyr.
pub const log_level: std.log.Level = .debug;
pub const log = zephyr.log;

export fn main() void {
    std.log.info("Starting zig hello", .{});
    std.log.debug("Debug message", .{});
    std.log.info("Info message", .{});
    std.log.warn("Warn message", .{});
    std.log.err("err log message", .{});
    std.log.err("level: {}", .{@enumToInt(log_level)});
    std.log.info("this u32 info: {any}", .{[_]u32{ 1, 2, 3 }});
    std.log.info("this u16 info: {any}", .{[_]u16{ 1, 2, 3 }});

    // std.log.info("cycles: {}", .{zephyr.c.k_cycle_get_32()});
    // std.log.info("cycles {}", .{zephyr.k_uptime_get()});
}
