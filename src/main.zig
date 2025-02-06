const std = @import("std");
const testing = @import("std").testing;

//define permutation tables
const PC1 = [_]u8{ 57, 49, 41, 33, 25, 17, 9, 1, 58, 50, 42, 34, 26, 18, 10, 2, 59, 51, 43, 35, 27, 19, 11, 3, 60, 52, 44, 36, 63, 55, 47, 39, 31, 23, 15, 7, 62, 54, 46, 38, 30, 22, 14, 6, 61, 53, 45, 37, 29, 21, 13, 5, 28, 20, 12, 4 };

const PC2 = [_]u8{
    14, 17, 11, 24, 1,  5,
    3,  28, 15, 6,  21, 10,
    23, 19, 12, 4,  26, 8,
    16, 7,  27, 20, 13, 2,
    41, 52, 31, 37, 47, 55,
    30, 40, 51, 45, 33, 48,
    44, 49, 39, 56, 34, 53,
    46, 42, 50, 36, 29, 32,
};

const IP = [_]u8{
    58, 50, 42, 34, 26, 18, 10, 2,
    60, 52, 44, 36, 28, 20, 12, 4,
    62, 54, 46, 38, 30, 22, 14, 6,
    64, 56, 48, 40, 32, 24, 16, 8,
    57, 49, 41, 33, 25, 17, 9,  1,
    59, 51, 43, 35, 27, 19, 11, 3,
    61, 53, 45, 37, 29, 21, 13, 5,
    63, 55, 47, 39, 31, 23, 15, 7,
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

fn permute(bits: u64, nBits: u8, table: []const u8) u64 {
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

fn rotate_left(comptime length: u6, bits: u64, rotations: u8) u64 {
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

fn generate_subkeys(key: u64) [16]u64 {
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

        subkey = permute(subkey, 56, &PC2);

        subkeys[i - 1] = subkey;
        i += 1;
    }

    return subkeys;
}

test "test applyPermutation function" {
    const originalKey: u64 = 0x133457799BBCDFF1; // 00010011 00110100 01010111 01111001 10011011 10111100 11011111 11110001
    const expectedPermutedKey: u64 = 0xF0CCAAF556678F; // 1111000 0110011 0010101 0101111 0101010 1011001 1001111 0001111

    const permutedKey = permute(originalKey, 64, &PC1);

    // Compare the values
    try testing.expect(permutedKey == expectedPermutedKey);

    const originalKey2: u64 = 0b11100001100110010101010111111010101011001100111100011110;
    const expectedPermutedKey2: u64 = 0b000110110000001011101111111111000111000001110010;

    const permutedKey2 = permute(originalKey2, 56, &PC2);

    // Compare the values
    try testing.expect(permutedKey2 == expectedPermutedKey2);
}

test "test rotate left function" {
    const original: u64 = 0b1000;
    const rotated = rotate_left(4, original, 1);
    const expected: u64 = 0b0001;
    try testing.expect(rotated == expected);

    const original2: u64 = 0b1111000011001100101010101111;
    const rotated2 = rotate_left(28, original2, 1);
    const expected2: u64 = 0b1110000110011001010101011111;
    try testing.expect(rotated2 == expected2);

    const original3: u64 = 0b1100001100110010101010111111;
    const rotated3 = rotate_left(28, original3, 2);
    const expected3: u64 = 0b0000110011001010101011111111;
    try testing.expect(rotated3 == expected3);
}

const testKeys = []u64{
    0b000110110000001011101111111111000111000001110010,
    0b011110011010111011011001110110111100100111100101,
    0b010101011111110010001010010000101100111110011001,
    0b011100101010110111010110110110110011010100011101,
    0b011111001110110000000111111010110101001110101000,
    0b011000111010010100111110010100000111101100101111,
    0b111011001000010010110111111101100001100010111100,
    0b111101111000101000111010110000010011101111111011,
    0b111000001101101111101011111011011110011110000001,
    0b101100011111001101000111101110100100011001001111,
    0b001000010101111111010011110111101101001110000110,
    0b011101010111000111110101100101000110011111101001,
    0b100101111100010111010001111110101011101001000001,
    0b010111110100001110110111111100101110011100111010,
    0b101111111001000110001101001111010011111100001010,
    0b110010110011110110001011000011100001011111110101,
};

test "test subkey generation" {
    const key: u64 = 0b11110000110011001010101011110101010101100110011110001111;
    const subkeys = generate_subkeys(key);
    for (subkeys, 1..) |item, i| {
        try testing.expect(item == testKeys[i - 1]);
    }
}
