const std = @import("std");
pub const tables = @import("tables.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} [-g|-e <filename> <path-to-key>|-d <filename>]\n", .{args[0]});
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

pub fn permute(bits: u64, nBits: u8, table: []const u8) u64 {
    var res: u64 = 0;
    const n = table.len;

    for (table, 0..) |pos, i| {
        //the permutation tables are 1-indexed for some reason
        const bit_pos: u6 = @intCast(nBits - pos);
        const bit = (bits >> bit_pos) & 1;

        const shift: u6 = @intCast(n - i - 1);
        res |= bit << shift;
    }

    return res;
}

pub fn rotate_left(comptime length: u6, bits: u64, rotations: u8) u64 {
    var res = bits;

    var i: u8 = 0;
    while (i < rotations) {
        //get the left most digit
        const msb = (res >> (length - 1)) & 1;
        //left shift
        res = res << 1;
        //mask off digits to the left of most significant
        res = res & ((1 << length) - 1);
        //add msb to end of number
        res |= msb;
        i += 1;
    }

    return res;
}

pub fn generate_subkeys(full_key: u64) [16]u64 {
    //permute key down to 56 bits from 64
    const key = permute(full_key, 64, &tables.PC1);
    //split key into two 28 bit halves
    var c: u64 = key >> 28;
    var d: u64 = key & 0x0000000FFFFFFF;

    var subkeys: [16]u64 = undefined;

    var i: u8 = 1;
    while (i <= 16) {
        if (i == 1 or i == 2 or i == 9 or i == 16) {
            c = rotate_left(28, c, 1);
            d = rotate_left(28, d, 1);
        } else {
            c = rotate_left(28, c, 2);
            d = rotate_left(28, d, 2);
        }
        var subkey = c << 28;
        subkey |= d;

        subkey = permute(subkey, 56, &tables.PC2);

        subkeys[i - 1] = subkey;
        i += 1;
    }

    return subkeys;
}

pub fn encrypt_block(data: u64, subkeys: [16]u64) u64 {
    //permute data with IP table
    const permuted_data = permute(data, 64, &tables.IP);

    //Split IP into two 32 bit halves
    var L_prev = permuted_data >> 32;
    var R_prev = permuted_data & 0x00000000FFFFFFFF;
    var L: u64 = undefined;
    var R: u64 = undefined;

    var i: u8 = 1;
    while (i <= 16) : (i += 1) {
        L = R_prev;
        R = L_prev ^ feistel(R_prev, subkeys[i - 1]);
        L_prev = L;
        R_prev = R;
    }
    return permute((R << 32) | L, 64, &tables.IP_minus_one);
}

pub fn feistel(R: u64, Kn: u64) u64 {
    const expanded: u64 = permute(R, 32, &tables.E);
    const e_xor_k = expanded ^ Kn;
    var out: u64 = 0;

    var i: u6 = 0;
    while (i < 8) : (i += 1) {
        const B = (e_xor_k >> ((7 - i) * 6)) & 0x3F;
        const row = (((B >> 5) & 1) << 1) | (B & 1);
        const col = (B >> 1) & 0xF;

        const S = tables.S_tables[i][16 * row + col];
        out = (out << 4) | S;
    }
    return permute(out, 32, &tables.P);
}
