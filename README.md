# [zbullet](https://github.com/zig-gamedev/zbullet)

Zig bindings for Bullet Physics SDK

## Overview

Bullet Physics SDK 3.25 (**C++**) ---> cbullet v0.2 (**C**) ---> zbullet (**Zig**)

`cbullet` is C API for Bullet Physics SDK which is being developed as a part of zig-gamedev project ([source code](https://github.com/zig-gamedev/zbullet/tree/main/libs/cbullet)).

`zbullet` is built on top of `cbullet` and provides Zig friendly bindings.

## Features

Some `cbullet` features:
* Most collision shapes
* Rigid bodies
* Most constraint types
* Tries to minimize number of memory allocations
  * Multiple rigid bodies and motion states can be created with one memory allocation
  * New physics objects can re-use existing memory
* Lots of error checks in debug builds

For an example code please see:

* [bullet physics test (wgpu)](https://github.com/zig-gamedev/zig-gamedev/tree/main/samples/bullet_physics_test_wgpu)
* [virtual physics lab](https://github.com/zig-gamedev/zig-gamedev/tree/main/samples/bullet_physics_test) (Windows-only, uses `cbullet` directly)
* [zbullet tests](https://github.com/zig-gamedev/zbullet/blob/main/src/zbullet.zig)

## Getting started

Example `build.zig`:

```zig
pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{ ... });

    const zbullet = b.dependency("zbullet", .{});
    exe.root_module.addImport("zbullet", zbullet.module("root"));
    exe.linkLibrary(zbullet.artifact("cbullet"));
}
```

Now in your code you may import and use zbullet:

```zig
const zbt = @import("zbullet");

pub fn main() !void {
    ...
    zbt.init(allocator);
    defer zbt.deinit();

    const world = zbt.initWorld();
    defer world.deinit();

    // Create unit cube shape.
    const box_shape = zbt.initBoxShape(&.{ 0.5, 0.5, 0.5 });
    defer box_shape.deinit();

    // Create rigid body that will use above shape.
    const initial_transform = [_]f32{
        1.0, 0.0, 0.0, // orientation
        0.0, 1.0, 0.0,
        0.0, 0.0, 1.0,
        2.0, 2.0, 2.0, // translation
    };
    const box_body = zbt.initBody(
        1.0, // mass (0.0 for static objects)
        &initial_transform,
        box_shape.asShape(),
    );
    defer box_body.deinit();

    // Add body to the physics world.
    world.addBody(box_body);
    defer world.removeBody(box_body);

    while (...) {
        ...
        // Perform a simulation step.
        _ = world.stepSimulation(time_step, .{});
        ...
    }
}
```
