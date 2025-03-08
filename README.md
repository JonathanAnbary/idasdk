# IdaSdk packaged with the zig build system

To use in another project add the following to your build.zig:
```zig
const idasdk_path_opt = b.option([]const u8, "idasdk", "path to installation of the ida sdk") orelse return error.MustProvideIdaSdk;
const idasdk_ea_64_opt = b.option(bool, "EA64", "target IDA64") orelse false;
...
const idasdk = b.dependency("idasdk", .{
    .target = target,
    .optimize = optimize,
    .idasdk = idasdk_path_opt,
    .EA64 = idasdk_ea_64_opt,
});
...
const plugin = b.createModule(.{
    .target = target,
    .optimize = optimize,
    .link_libc = true,
    .link_libcpp = true,
});


for (idamod.include_dirs.items) |include_dir| {
    plugin.addIncludePath(include_dir.path);
}
for (idamod.c_macros.items) |macro| {
    plugin.c_macros.append(b.allocator, macro) catch @panic("OOM");
}
for (idamod.lib_paths.items) |lib_path| {
    plugin.lib_paths.append(b.allocator, lib_path) catch @panic("OOM");
}
plugin.linkSystemLibrary(if (idasdk_ea_64_opt) "ida64" else "ida", .{});
```

If you want to mix zig code with cpp I would suggest taking a look at [binmodify_plug](https://github.com/JonathanAnbary/binmodify_plug).

The short and long of it is that you have to create your own forward declerations for the ida functions you want to use 
(by just copying them from the idasdk header files) since the ida headers are .hpp files and not .h.
