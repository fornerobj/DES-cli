const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} [-g|-e <filename>|-d <filename>]\n", .{args[0]});
        return;
    }
    
    const command = args[1];

    if (std.mem.eql(u8, command, "-g")) {
        //generate the key
        std.debug.print("Generating key...", .{});
    } else if (std.mem.eql(u8, command, "-e") and args.len == 3) {
        //encrypt the file
        std.debug.print("Encrypting file...", .{});
    } else if (std.mem.eql(u8, command, "-d") and args.len == 3) {
        //decrypt the file
        std.debug.print("Decrypting file...", .{});
    } else {
        std.debug.print("Invalid arguments {s}\n", .{args[0]});
    }
}

