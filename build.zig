const raylib = @import("raylib");
const std = @import("std");

pub const OpenglVersion = raylib.OpenglVersion;

pub fn build(builder: *std.Build) !void {
    const target = builder.standardTargetOptions(.{});
    const optimize = builder.standardOptimizeOption(.{});

    const options = raylib.Options.getOptions(builder);

    const raylib_dependency = builder.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
        .raudio = options.raudio,
        .rmodels = options.rmodels,
        .rshapes = options.rshapes,
        .rtext = options.rtext,
        .rtextures = options.rtextures,
        .platform = options.platform,
        .linkage = options.linkage,
        .linux_display_backend = options.linux_display_backend,
        .opengl_version = options.opengl_version,
        .android_api_version = options.android_api_version,
        .android_ndk = options.android_ndk,
        .config = options.config,
    });

    const raylib_artifact = raylib_dependency.artifact("raylib");
    var raylib_headers = std.StringHashMap(std.Build.LazyPath).init(builder.allocator);

    defer raylib_headers.deinit();

    for (raylib_artifact.installed_headers.items) |installed_header| {
        try raylib_headers.put(
            installed_header.file.dest_rel_path,
            installed_header.file.source,
        );
    }

    builder.installArtifact(raylib_artifact);

    const raylib_module = builder.addModule("raylib", .{
        .root_source_file = builder.path("lib/raylib.zig"),

        .target = target,
        .optimize = optimize,

        .link_libc = true,
    });

    raylib_module.linkLibrary(raylib_artifact);

    const update_source_files_step = builder.addUpdateSourceFiles();

    update_source_files_step.addCopyFileToSource(raylib_headers.get("raylib.h").?, "lib/headers/raylib.h");
    update_source_files_step.addCopyFileToSource(raylib_headers.get("raymath.h").?, "lib/headers/raymath.h");
    update_source_files_step.addCopyFileToSource(raylib_headers.get("rlgl.h").?, "lib/headers/rlgl.h");
}
