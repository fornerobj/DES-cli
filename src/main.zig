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

const IP_minus_one = [_]u8{
    40, 8, 48, 16, 56, 24, 64, 32,
    39, 7, 47, 15, 55, 23, 63, 31,
    38, 6, 46, 14, 54, 22, 62, 30,
    37, 5, 45, 13, 53, 21, 61, 29,
    36, 4, 44, 12, 52, 20, 60, 28,
    35, 3, 43, 11, 51, 19, 59, 27,
    34, 2, 42, 10, 50, 18, 58, 26,
    33, 1, 41, 9,  49, 17, 57, 25,
};

const E = [_]u8{
    32, 1,  2,  3,  4,  5,
    4,  5,  6,  7,  8,  9,
    8,  9,  10, 11, 12, 13,
    12, 13, 14, 15, 16, 17,
    16, 17, 18, 19, 20, 21,
    20, 21, 22, 23, 24, 25,
    24, 25, 26, 27, 28, 29,
    28, 29, 30, 31, 32, 1,
};

const P = [_]u8{
    16, 7,  20, 21,
    29, 12, 28, 17,
    1,  15, 23, 26,
    5,  18, 31, 10,
    2,  8,  24, 14,
    32, 27, 3,  9,
    19, 13, 30, 6,
    22, 11, 4,  25,
};

const S1 = [_]u8{
    14, 4,  13, 1, 2,  15, 11, 8,  3,  10, 6,  12, 5,  9,  0, 7,
    0,  15, 7,  4, 14, 2,  13, 1,  10, 6,  12, 11, 9,  5,  3, 8,
    4,  1,  14, 8, 13, 6,  2,  11, 15, 12, 9,  7,  3,  10, 5, 0,
    15, 12, 8,  2, 4,  9,  1,  7,  5,  11, 3,  14, 10, 0,  6, 13,
};

const S2 = [_]u8{
    15, 1,  8,  14, 6,  11, 3,  4,  9,  7, 2,  13, 12, 0, 5,  10,
    3,  13, 4,  7,  15, 2,  8,  14, 12, 0, 1,  10, 6,  9, 11, 5,
    0,  14, 7,  11, 10, 4,  13, 1,  5,  8, 12, 6,  9,  3, 2,  15,
    13, 8,  10, 1,  3,  15, 4,  2,  11, 6, 7,  12, 0,  5, 14, 9,
};

const S3 = [_]u8{
    10, 0,  9,  14, 6, 3,  15, 5,  1,  13, 12, 7,  11, 4,  2,  8,
    13, 7,  0,  9,  3, 4,  6,  10, 2,  8,  5,  14, 12, 11, 15, 1,
    13, 6,  4,  9,  8, 15, 3,  0,  11, 1,  2,  12, 5,  10, 14, 7,
    1,  10, 13, 0,  6, 9,  8,  7,  4,  15, 14, 3,  11, 5,  2,  12,
};

const S4 = [_]u8{
    7,  13, 14, 3, 0,  6,  9,  10, 1,  2, 8, 5,  11, 12, 4,  15,
    13, 8,  11, 5, 6,  15, 0,  3,  4,  7, 2, 12, 1,  10, 14, 9,
    10, 6,  9,  0, 12, 11, 7,  13, 15, 1, 3, 14, 5,  2,  8,  4,
    3,  15, 0,  6, 10, 1,  13, 8,  9,  4, 5, 11, 12, 7,  2,  14,
};

const S5 = [_]u8{
    2,  12, 4,  1,  7,  10, 11, 6,  8,  5,  3,  15, 13, 0, 14, 9,
    14, 11, 2,  12, 4,  7,  13, 1,  5,  0,  15, 10, 3,  9, 8,  6,
    4,  2,  1,  11, 10, 13, 7,  8,  15, 9,  12, 5,  6,  3, 0,  14,
    11, 8,  12, 7,  1,  14, 2,  13, 6,  15, 0,  9,  10, 4, 5,  3,
};

const S6 = [_]u8{
    12, 1,  10, 15, 9, 2,  6,  8,  0,  13, 3,  4,  14, 7,  5,  11,
    10, 15, 4,  2,  7, 12, 9,  5,  6,  1,  13, 14, 0,  11, 3,  8,
    9,  14, 15, 5,  2, 8,  12, 3,  7,  0,  4,  10, 1,  13, 11, 6,
    4,  3,  2,  12, 9, 5,  15, 10, 11, 14, 1,  7,  6,  0,  8,  13,
};

const S7 = [_]u8{
    4,  11, 2,  14, 15, 0, 8,  13, 3,  12, 9, 7,  5,  10, 6, 1,
    13, 0,  11, 7,  4,  9, 1,  10, 14, 3,  5, 12, 2,  15, 8, 6,
    1,  4,  11, 13, 12, 3, 7,  14, 10, 15, 6, 8,  0,  5,  9, 2,
    6,  11, 13, 8,  1,  4, 10, 7,  9,  5,  0, 15, 14, 2,  3, 12,
};

const S8 = [_]u8{
    13, 2,  8,  4, 6,  15, 11, 1,  10, 9,  3,  14, 5,  0,  12, 7,
    1,  15, 13, 8, 10, 3,  7,  4,  12, 5,  6,  11, 0,  14, 9,  2,
    7,  11, 4,  1, 9,  12, 14, 2,  0,  6,  10, 13, 15, 3,  5,  8,
    2,  1,  14, 7, 4,  10, 8,  13, 15, 12, 9,  0,  3,  5,  6,  11,
};

const S_tables = [8][64]u8{ S1, S2, S3, S4, S5, S6, S7, S8 };

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

fn encrypt_block(data: u64, subkeys: [16]u64) u64 {
    //permute data with IP table
    const permuted_data = permute(data, 64, &IP);

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
    std.debug.print("L16: {b}\n", .{L_prev});
    std.debug.print("R16: {b}\n", .{R_prev});
    return permute((R << 32) | L, 64, &IP_minus_one);
}

fn feistel(R: u64, Kn: u64) u64 {
    const expanded: u64 = permute(R, 32, &E);
    const e_xor_k = expanded ^ Kn;
    var out: u64 = 0;

    var i: u6 = 0;
    while (i < 8) : (i += 1) {
        const B = (e_xor_k >> ((7 - i) * 6)) & 0x3F;
        const row = (((B >> 5) & 1) << 1) | (B & 1);
        const col = (B >> 1) & 0xF;

        const S = S_tables[i][16 * row + col];
        out = (out << 4) | S;
    }
    return permute(out, 32, &P);
}

test "Encrypting a block" {
    const M = 0b0000000100100011010001010110011110001001101010111100110111101111;
    const key = 0b0001001100110100010101110111100110011011101111001101111111110001;
    const Subkeys = generate_subkeys(key);
    const C = encrypt_block(M, Subkeys);
    const expected = 0x85E813540F0AB405;
    try testing.expect(C == expected);
}

test "Testing feistel function" {
    const R0: u64 = 0b11110000101010101111000010101010;
    const Kn: u64 = 0b000110110000001011101111111111000111000001110010;
    const f: u64 = 0b00100011010010101010100110111011;

    try testing.expect(feistel(R0, Kn) == f);
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

const testKeys = [16]u64{
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
