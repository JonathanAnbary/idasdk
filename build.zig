const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const idasdk = b.option([]const u8, "idasdk", "path to installation of the ida sdk") orelse return error.MustProvideIdaSdk;
    const ea_64 = b.option(bool, "EA64", "target IDA64") orelse false;

    switch (target.result.os.tag) {
        .linux, .windows => switch (target.result.cpu.arch) {
            .x86, .x86_64 => {},
            else => return error.TargetNotSupported,
        },
        .macos => switch (target.result.cpu.arch) {
            .x86_64, .aarch64 => {},
            else => return error.TargetNotSupported,
        },
        else => return error.TargetNotSupported,
    }

    const idasdkpath = b.path(idasdk);

    const arch_string = switch (target.result.cpu.arch) {
        .x86 => "x86",
        .x86_64 => "x64",
        .aarch64 => "arm64",
        else => unreachable,
    };
    const os_string = switch (target.result.os.tag) {
        .linux => "linux_gcc",
        .windows => "win_vc",
        .macos => "mac_clang",
        else => unreachable,
    };
    const easize_string = if (ea_64) "64" else "32";

    const libdir = try std.fmt.allocPrint(b.allocator, "{s}_{s}_{s}", .{ arch_string, os_string, easize_string });

    const idamod = b.addModule("ida", .{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    switch (target.result.os.tag) {
        .linux => idamod.addCMacro("__LINUX__", "1"),
        .windows => idamod.addCMacro("__NT__", "1"),
        .macos => idamod.addCMacro("__MAC__", "1"),
        else => unreachable,
    }

    switch (target.result.cpu.arch) {
        .x86 => idamod.addCMacro("__X86__", "1"),
        .x86_64 => idamod.addCMacro("__X64__", "1"),
        .aarch64 => idamod.addCMacro("__ARM__", "1"),
        else => unreachable,
    }
    if (ea_64) idamod.addCMacro("__EA64__", "1");

    if (optimize != .Debug) idamod.addCMacro("NDEBUG", "1");

    idamod.addIncludePath(idasdkpath.path(b, "include"));
    const idalibname = switch (target.result.os.tag) {
        .linux => if (ea_64) "libida64.so" else "libida.so",
        .windows => "ida.lib",
        .macos => if (ea_64) "libida64.dylib" else "libida.dylib",
        else => unreachable,
    };
    idamod.addObjectFile(idasdkpath.path(b, "lib").path(b, libdir).path(b, idalibname));

    const lib = b.addLibrary(.{
        .name = if (ea_64) "ida64" else "ida",
        .linkage = if (target.result.os.tag == .windows) .static else .dynamic,
        .root_module = idamod,
    });

    // g++ -m64 --shared -Wl,--no-undefined -o ../../bin/plugins/ida_capi.so obj/x64_linux_gcc_32/ida_capi.o -L../../lib/x64_linux_gcc_32/ -lida -Wl,--build-id -Wl,--gc-sections -Wl,--warn-shared-textrel -Wl,-Map,obj/x64_linux_gcc_32/ida_capi.so.map -Wl,--version-script=../../plugins/exports.def -Wl,-rpath='$ORIGIN/..' -z origin -lrt -lpthread -lc
    // lib.addLibraryPath(idasdkpath.path(b, "lib").path(b, libdir));
    b.installArtifact(lib);
}
