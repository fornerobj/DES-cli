const std = @import("std");
const testing = @import("std").testing;

//define permutation tables
const PC1 = [_]u8{
    57,49,41,33,25,17,9,
    1,58,50,42,34,26,18,
    10,2,59,51,43,35,27,
    19,11,3,60,52,44,36,
    63,55,47,39,31,23,15,
    7,62,54,46,38,30,22,
    14,6,61,53,45,37,29,
    21,13,5,28,20,12,4
};

const PC2 = [_]u8{
    14,17,11,24,1,5,
    3,28,15,6,21,10,
    23,19,12,4,26,8,
    16,7,27,20,13,2,
    41,52,31,37,47,55,
    30,40,51,45,33,48,
    44,49,39,56,34,53,
    46,42,50,36,29,32,
};

const IP = [_]u8{
    58,50,42,34,26,18,10,2,
    60,52,44,36,28,20,12,4,
    62,54,46,38,30,22,14,6,
    64,56,48,40,32,24,16,8,
    57,49,41,33,25,17,9,1,
    59,51,43,35,27,19,11,3,
    61,53,45,37,29,21,13,5,
    63,55,47,39,31,23,15,7,
};

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

// fn encrypt_file(allocator: *std.mem.Allocator, filename: []const u8, key: []const u8) void {
    //steps
    //
    // GENERATE SUBKEYS
    // permute key using table P1
    // split key into halves C and D
    // create rotation set of keys C1-16 and D1-16
    // Kn will be permution of Cn+Dn according to P2
    // 
    // ENCODE BLOCK
    // apply initial permutation (IP) to message (M)
    // split IP into halves L0 and R0
    // 16 iterations
    //      Ln = Rn-1
    //      Rn = Ln-1 + f(Rn-1, Kn) (+ = XOR)
    //      but what is f?
// }

// fn create_subkeys(key: u64) [16]u8{
//     const newKey = permute(key, PC1);
//
// }

fn permute(bits: u64, table: []const u8) u64 {
    var res: u64 = 0;
    const n = table.len;
    
    for (table, 0..) |pos, i| {
        //the permutation tables are 1-indexed for some reason
        const bit_pos: u6 = @intCast(64-pos);
        const bit = (bits >> bit_pos) & 1;

        const shift: u6 = @intCast(n-i-1);
        res |= bit << shift;
    }

    return res;
}

fn generate_subkeys(key: u64) [16]u64 {

}

test "test applyPermutation function" {
    const originalKey: u64 = 0x133457799BBCDFF1; // 00010011 00110100 01010111 01111001 10011011 10111100 11011111 11110001
    const expectedPermutedKey: u64 = 0xF0CCAAF556678F; // 1111000 0110011 0010101 0101111 0101010 1011001 1001111 0001111

    const permutedKey = permute(originalKey, &PC1);
    std.debug.print("original: {b}\npermuted: {b}\nexpected: {b}\n", .{originalKey,permutedKey, expectedPermutedKey});
    std.debug.print("permuted xor expected: {b}\n", .{permutedKey^expectedPermutedKey});

    // Compare the values
    try testing.expect(permutedKey == expectedPermutedKey);
}

