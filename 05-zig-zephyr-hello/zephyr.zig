// SPDX-License-Identifier: Apache-2.0
// Bindings to things in Zephyr.

const std = @import("std");

pub const c = @cImport({
    @cInclude("zephyr/zephyr.h");
});

// Raw are bindings to direct calls in C.
const raw = struct {
    extern fn zig_log_message(level: c_int, msg: [*:0]const u8) void;
    extern fn k_uptime_get() u64;
};

pub const k_uptime_get = raw.k_uptime_get;

// A single shared buffer for log messages.  This will need to be
// locked if we become multi-threaded.
var buffer: [256]u8 = undefined;

// Use: `pub const log = zephyr.log;` in the root of the project to
// enable Zig logging to output to the console in Zephyr.
// `pub const log_level: std.log.Level = .info;` to set the logging
// level at compile time.
pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    _ = scope;
    const msg = std.fmt.bufPrintZ(&buffer, format, args) catch return;
    raw.zig_log_message(@enumToInt(level), msg);
}
