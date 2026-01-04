const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const module = b.addModule("root", .{
        .root_source_file = b.path("src/zbullet.zig"),
        .target = target,
        .optimize = optimize,
    });

    // TODO: Use the old damping method for now otherwise there is a hang in powf().
    const flags = &.{
        "-DBT_USE_OLD_DAMPING_METHOD",
        "-DBT_THREADSAFE=1",
        "-std=c++11",
        "-fno-sanitize=undefined",
    };
    module.addCSourceFiles(.{
        .files = &.{
            "libs/cbullet/cbullet.cpp",
            "libs/bullet/btLinearMathAll.cpp",
            "libs/bullet/btBulletCollisionAll.cpp",
            "libs/bullet/btBulletDynamicsAll.cpp",
        },
        .flags = flags,
    });
    module.addIncludePath(b.path("libs/cbullet"));
    module.addIncludePath(b.path("libs/bullet"));

    module.link_libc = true;
    module.link_libcpp = true;

    const cbullet_lib = b.addLibrary(.{
        .name = "cbullet",
        .root_module = module,
    });
    b.installArtifact(cbullet_lib);

    const test_step = b.step("test", "Run zbullet tests");

    const zmath = b.dependency("zmath", .{});

    var tests = b.addTest(.{
        .name = "zbullet-tests",
        .root_module = module,
    });
    b.installArtifact(tests);

    tests.root_module.addImport("zmath", zmath.module("root"));

    test_step.dependOn(&b.addRunArtifact(tests).step);
}
