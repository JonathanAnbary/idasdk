const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const idasdk = b.option([]const u8, "idasdk", "path to installation of the ida sdk") orelse return error.MustProvideIdaSdk;
    const idasdkpath = b.path(idasdk);

    // This creates a "module", which represents a collection of source files alongside
    // some compilation options, such as optimization mode and linked system libraries.
    // Every executable or library we compile will be based on one or more modules.
    const lib_mod = b.addModule("ida", .{
        // `root_source_file` is the Zig "entry point" of the module. If a module
        // only contains e.g. external object files, you can make this `null`.
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    const libdir = switch (target.result.os.tag) {
        .linux => switch (target.result.cpu.arch) {
            .x86 => "x64_linux_gcc_32",
            .x86_64 => "x64_linux_gcc_64",
            else => return error.ArchNotSupported,
        },
        else => return error.OsNotSupported,
    };

    // const translate_c = b.addTranslateC(.{
    //     .target = target,
    //     .root_source_file = b.path("pro.hpp"),
    //     .link_libc = true,
    //     .optimize = optimize,
    //     .use_clang = true,
    // });
    // translate_c.addIncludePath(idasdkpath.path(b, "include"));
    // translate_c.getOutput();

    // lib_mod.addLibraryPath(idasdkpath.path(b, "lib").path(b, libdir));
    // lib_mod.linkSystemLibrary("ida64", .{});
    // lib_mod.addIncludePath(idasdkpath.path(b, "include"));
    // lib_mod.installHeadersDirectory(idasdkpath.path("include"), "ida", .{});

    // const test_mod = b.createModule(.{
    //     .root_source_file = b.path("src/tests.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    //
    // test_mod.addImport("ida", lib_mod);

    // const unit_tests = b.addTest(.{
    //     .target = target,
    //     .optimize = optimize,
    //     // .root_module = test_mod,
    //     .root_source_file = b.path("src/tests.zig"),
    //     .link_libc = true,
    //     .link_libcpp = true,
    // });

    // g++ -m64 --shared -Wl,--no-undefined -o ../../bin/plugins/ida_capi.so obj/x64_linux_gcc_32/ida_capi.o -L../../lib/x64_linux_gcc_32/ -lida -Wl,--build-id -Wl,--gc-sections -Wl,--warn-shared-textrel -Wl,-Map,obj/x64_linux_gcc_32/ida_capi.so.map -Wl,--version-script=../../plugins/exports.def -Wl,-rpath='$ORIGIN/..' -z origin -lrt -lpthread -lc
    lib_mod.addIncludePath(b.path("src"));
    lib_mod.addLibraryPath(idasdkpath.path(b, "lib").path(b, libdir));
    lib_mod.linkSystemLibrary("ida64", .{});

    // Now, we will create a static library based on the module we created above.
    // This creates a `std.Build.Step.Compile`, which is the build step responsible
    // for actually invoking the compiler.
    const lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "idasdk",
        .root_module = lib_mod,
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    // const run_unit_tests = b.addRunArtifact(unit_tests);

    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_unit_tests.step);
}
