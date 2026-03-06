const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    // TODO: Use the old damping method for now otherwise there is a hang in powf().
    const flags = &.{
        "-DBT_USE_OLD_DAMPING_METHOD",
        "-DBT_THREADSAFE=1",
        "-std=c++11",
        "-fno-sanitize=undefined",
    };

    const cbullet_lib = b.addLibrary(.{
        .name = "cbullet",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    cbullet_lib.addCSourceFiles(.{
        .files = &.{
            "libs/cbullet/cbullet.cpp",
            "libs/bullet/btLinearMathAll.cpp",
            "libs/bullet/btBulletCollisionAll.cpp",
            "libs/bullet/btBulletDynamicsAll.cpp",
        },
        .flags = flags,
    });
    cbullet_lib.addIncludePath(b.path("libs/cbullet"));
    cbullet_lib.addIncludePath(b.path("libs/bullet"));
    cbullet_lib.linkLibC();
    cbullet_lib.linkLibCpp();
    b.installArtifact(cbullet_lib);

    const module = b.addModule("root", .{
        .root_source_file = b.path("src/zbullet.zig"),
        .target = target,
        .optimize = optimize,
    });
    module.linkLibrary(cbullet_lib);

    const test_step = b.step("test", "Run zbullet tests");

    const zmath = b.dependency("zmath", .{});

    const test_module = b.createModule(.{
        .root_source_file = b.path("src/zbullet.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_module.addImport("zmath", zmath.module("root"));
    test_module.linkLibrary(cbullet_lib);

    const tests = b.addTest(.{
        .name = "zbullet-tests",
        .root_module = test_module,
    });
    b.installArtifact(tests);

    test_step.dependOn(&b.addRunArtifact(tests).step);
}
