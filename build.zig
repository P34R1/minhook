const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("minhook", .{
        .root_source_file = b.path("src/minhook.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    mod.addCSourceFiles(.{ .root = b.path("src"), .files = &.{
        "hook.c",
        "buffer.c",
        "trampoline.c",
        "hde/hde32.c",
        "hde/hde64.c",
    } });

    const tests = b.addRunArtifact(b.addTest(.{ .root_module = mod }));
    b.getInstallStep().dependOn(&tests.step);
}
