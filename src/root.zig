const std = @import("std");
const testing = std.testing;

pub fn column(T: type) type {
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
const default_val = false;
pub fn frame(comptime _scema: type) !type {
    switch (@typeInfo(_scema)) {
        .Struct => |st| {
            var Struc_fields: [st.fields.len]std.builtin.Type.StructField = undefined;
            for (st.fields, 0..) |F, i| {
                Struc_fields[i] = .{
                    .name = F.name,
                    .type = column(F.type),
                    .default_value = null,
                    .is_comptime = false,
                    .alignment = 4,
                };
            }
            const ret: type = @Type(.{ .Struct = .{
                .fields = &Struc_fields,
                .layout = .auto,
                .is_tuple = false,
                .decls = &.{},
            } });
            return ret;
        },
        else => {
            @compileError("Not a struct");
        },
    }
}

test "frame alloc test" {
    const ExampleStruct = struct {
        // Zig primitive types
        aBool: bool,
        aU8: u8,
        aU16: u16,
        aU32: u32,
        aU64: u64,
        aI8: i8,
        aI16: i16,
        aI32: i32,
        aI64: i64,
        aF32: f32,
        aF64: f64,
        aVoid: void, // this is more of a placeholder than an actual field

        // Zig special types
        aMaybeInt: ?i32, // Optional integer
        anArray: [4]u8, // Array of 4 unsigned 8-bit integers
        aSlice: []u8, // Slice of unsigned 8-bit integers
        aPointer: *const u8, // Constant pointer to unsigned 8-bit integer
        aFnPointer: fn (i32) void, // Function pointer
        aComptimeInt: comptime_int, // Compile-time integer
        aComptimeFloat: comptime_float, // Compile-time floating point
        anEnum: enum { red, green, blue }, // Enum type
        aUnion: union(enum) { // Enum-tagged union
            intVal: i32,
            floatVal: f32,
        },

        aCCharPointer: ?[*:0]const u8, // Nullable C-style null-terminated string
    };
    const table = frame(ExampleStruct) catch |err| {
        std.debug.print("error {any}", .{err});
        try std.testing.expect(false);
    };

    const expectedFields = &[_]struct {
        name: []const u8,
        comptime_type: type,
    }{
        .{ .name = "aBool", .comptime_type = column(bool) },
        .{ .name = "aU8", .comptime_type = column(u8) },
        .{ .name = "aU16", .comptime_type = column(u16) },
        .{ .name = "aU32", .comptime_type = column(u32) },
        .{ .name = "aU64", .comptime_type = column(u64) },
        .{ .name = "aI8", .comptime_type = column(i8) },
        .{ .name = "aI16", .comptime_type = column(i16) },
        .{ .name = "aI32", .comptime_type = column(i32) },
        .{ .name = "aI64", .comptime_type = column(i64) },
        .{ .name = "aF32", .comptime_type = column(f32) },
        .{ .name = "aF64", .comptime_type = column(f64) },
        .{ .name = "aVoid", .comptime_type = column(void) },
        .{ .name = "aMaybeInt", .comptime_type = column(?i32) },
        .{ .name = "anArray", .comptime_type = column([4]u8) },
        .{ .name = "aSlice", .comptime_type = column([]u8) },
        .{ .name = "aPointer", .comptime_type = column(*const u8) },
        .{ .name = "aFnPointer", .comptime_type = column(fn (i32) void) },
        .{ .name = "aComptimeInt", .comptime_type = column(comptime_int) },
        .{ .name = "aComptimeFloat", .comptime_type = column(comptime_float) },
        .{ .name = "anEnum", .comptime_type = column(enum { red, green, blue }) },
        .{ .name = "aUnion", .comptime_type = column(union(enum) { intVal: i32, floatVal: f32 }) },
        .{ .name = "aCCharPointer", .comptime_type = column(?[*:0]const u8) },
    };
    _ = table;
    _ = expectedFields;
}
