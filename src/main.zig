const std = @import("std");
const lib = @import("root.zig");

pub fn main() !void {
    const t = struct {};
    std.debug.print("{any}", .{t});

    std.debug.print("\n{any}", .{std.meta.fields(t)});
}
