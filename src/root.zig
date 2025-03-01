// const ida = @cImport(@cInclude("ida_c.h"));
const ida = @import("temp.zig");
const std = @import("std");

var input_file_buf: [50]u8 = undefined;

export fn get_input_file_path() [*c]u8 {
    _ = ida.getinf_buf(ida.INF_INPUT_FILE_PATH, &input_file_buf, input_file_buf.len);
    return &input_file_buf;
}
