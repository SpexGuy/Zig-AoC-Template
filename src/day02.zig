const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = &gpa_impl.allocator;

const data = @embedFile("../data/day02.txt");

pub fn main() !void {
    
}
