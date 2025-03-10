const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const idasdk = b.option([]const u8, "idasdk", "absolute path to installation of the ida sdk") orelse return error.MustProvideIdaSdk;
    const ea_64 = b.option(bool, "EA64", "target IDA64 (default)") orelse true;

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

    const idasdkpath: std.Build.LazyPath = .{ .cwd_relative = idasdk };

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

    const libdir = idasdkpath.path(b, "lib").path(b, try std.fmt.allocPrint(b.allocator, "{s}_{s}_{s}", .{ arch_string, os_string, easize_string }));

    const idamod = b.addModule("ida", .{
        .root_source_file = b.path("src/root.zig"),
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

    const libfilename = switch (target.result.os.tag) {
        .linux => if (ea_64) "libida64.so" else "libida.so",
        .windows => "ida.lib",
        .macos => if (ea_64) "libida64.dylib" else "libida.dylib",
        else => unreachable,
    };

    const lib = b.addLibrary(.{
        .name = "ida",
        .linkage = if (target.result.os.tag == .windows) .static else .dynamic,
        .root_module = idamod,
    });

    lib.installHeadersDirectory(idasdkpath.path(b, "include"), "", .{ .include_extensions = &.{ ".h", ".hpp" } });
    b.installArtifact(lib);
    b.addNamedLazyPath("ida", libdir.path(b, libfilename));
    b.addNamedLazyPath("exports.def", idasdkpath.path(b, "plugins").path(b, "exports.def"));
}
