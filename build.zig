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

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

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

    const libdir = try std.fmt.allocPrint(alloc, "{s}_{s}_{s}", .{ arch_string, os_string, easize_string });

    const lib_mod = b.addModule("ida", .{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    switch (target.result.os.tag) {
        .linux => lib_mod.addCMacro("__LINUX__", "1"),
        .windows => lib_mod.addCMacro("__NT__", "1"),
        .macos => lib_mod.addCMacro("__MAC__", "1"),
        else => unreachable,
    }

    if (target.result.cpu.arch == .aarch64) lib_mod.addCMacro("__ARM__", "1");

    if (ea_64) lib_mod.addCMacro("__EA64__", "1");

    if (optimize != .Debug) lib_mod.addCMacro("NDEBUG", "1");

    // g++ -m64 --shared -Wl,--no-undefined -o ../../bin/plugins/ida_capi.so obj/x64_linux_gcc_32/ida_capi.o -L../../lib/x64_linux_gcc_32/ -lida -Wl,--build-id -Wl,--gc-sections -Wl,--warn-shared-textrel -Wl,-Map,obj/x64_linux_gcc_32/ida_capi.so.map -Wl,--version-script=../../plugins/exports.def -Wl,-rpath='$ORIGIN/..' -z origin -lrt -lpthread -lc
    lib_mod.addIncludePath(idasdkpath.path(b, "include"));
    lib_mod.addLibraryPath(idasdkpath.path(b, "lib").path(b, libdir));
    lib_mod.linkSystemLibrary(if (ea_64) "ida64" else "ida", .{});
}
