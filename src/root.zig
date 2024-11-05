const std = @import("std");
const testing = std.testing;

pub fn column(comptime T: type) type {
    return struct {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const allocator = arena.allocator();
        data: std.AutoHashMap(u128, ?T) = std.AutoHashMap(u128, ?T).init(allocator),
        columnNum: u8,

        pub fn init(_columnNum: u8) @This() {
            return .{
                .columnNum = _columnNum,
            };
        }

        pub fn deinit() void {
            arena.deinit();
        }
    };
}

pub fn frame(comptime _scema: [*:0]type) type {
    return struct {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const allocator = arena.allocator();
        scema: [*:0]type = _scema,
        columns: std.ArrayList(column(anyopaque)) = std.ArrayList(column(anyopaque)).init(allocator),

        pub fn init() @This() {
            const ret: @This() = .{};
            var cn: u8 = 0;
            for (ret.scema) |t| {
                ret.columns.append(column(t).init(cn));
                cn += 1;
            }
            return ret;
        }
    };
}
