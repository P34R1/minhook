const std = @import("std");

pub fn build(b: *std.Build) void {
    const mod = b.addModule("minhook", .{
        .root_source_file = b.path("src/minhook.zig"),
    });

    mod.addCSourceFiles(.{ .root = b.path("src"), .files = &.{
        "hook.c",
        "buffer.c",
        "trampoline.c",
        "hde/hde32.c",
        "hde/hde64.c",
    } });
}
