const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
  // Trim trailing \n's in file
  var trimmed_data = trim(u8, data, "\n");
  // Get each elf's calories as a separate string
  var elf_splits = split(u8, trimmed_data, "\n\n");
  var elf_calories = List(u32).init(std.heap.page_allocator);
  while (elf_splits.next()) |elf_split| {
    // Get each calorie line and count them up
    var foodItems = split(u8, elf_split, "\n");
    var totalCaloriesForElf: u32 = 0;
    while (foodItems.next()) |caloriesStr| {
      totalCaloriesForElf += try parseInt(u32, caloriesStr, 10);
    }
    try elf_calories.append(totalCaloriesForElf);
  }
  var sorted_calories = elf_calories.items;
  std.sort.sort(u32, sorted_calories, {}, comptime std.sort.desc(u32));
  print("Answer 1: {d}\n", .{sorted_calories[0]});
  var top_3_calories = sorted_calories[0] + sorted_calories[1] + sorted_calories[2];
  print("Answer 2: {d}\n", .{top_3_calories});
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;
