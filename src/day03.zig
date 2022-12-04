const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

pub fn main() !void {
  // Trim trailing \n's in file
  var trimmed_data = trim(u8, data, "\n");
  // Get each elf's rucksack
  var elf_rucksacks = split(u8, trimmed_data, "\n");
  var priority_sum: u32 = 0;
  while (elf_rucksacks.next()) |elf_rucksack| {
    var compartment1 = elf_rucksack[0..(elf_rucksack.len / 2)];
    var compartment2 = elf_rucksack[(elf_rucksack.len / 2)..];
    var compartment1_list = List(u8).init(std.heap.page_allocator);
    var compartment2_list = List(u8).init(std.heap.page_allocator);
    try compartment1_list.appendSlice(compartment1);
    try compartment2_list.appendSlice(compartment2);
    std.sort.sort(u8, compartment1_list.items, {}, comptime std.sort.asc(u8));
    std.sort.sort(u8, compartment2_list.items, {}, comptime std.sort.asc(u8));
    const shared_item = find_shared_letter(compartment1_list.items, compartment2_list.items);
    const shared_item_priority = prioritize_item(shared_item);
    priority_sum += shared_item_priority;
  }
  print("Answer 1: {}\n", .{priority_sum});
  elf_rucksacks = split(u8, trimmed_data, "\n");
  priority_sum = 0;
  while (elf_rucksacks.next()) |rucksack_1| {
    var rucksack_2 = elf_rucksacks.next() orelse "";
    var rucksack_3 = elf_rucksacks.next() orelse "";
    var sorted_rucksack_1 = List(u8).init(std.heap.page_allocator);
    var sorted_rucksack_2 = List(u8).init(std.heap.page_allocator);
    var sorted_rucksack_3 = List(u8).init(std.heap.page_allocator);
    try sorted_rucksack_1.appendSlice(rucksack_1[0..rucksack_1.len]);
    try sorted_rucksack_2.appendSlice(rucksack_2[0..rucksack_2.len]);
    try sorted_rucksack_3.appendSlice(rucksack_3[0..rucksack_3.len]);
    std.sort.sort(u8, sorted_rucksack_1.items, {}, comptime std.sort.asc(u8));
    std.sort.sort(u8, sorted_rucksack_2.items, {}, comptime std.sort.asc(u8));
    std.sort.sort(u8, sorted_rucksack_3.items, {}, comptime std.sort.asc(u8));
    const shared_item = find_shared_letter_3(sorted_rucksack_1.items, sorted_rucksack_2.items, sorted_rucksack_3.items);
    const shared_item_priority = prioritize_item(shared_item);
    priority_sum += shared_item_priority;
  }
  print("Answer 2: {}\n", .{priority_sum});
}

fn prioritize_item(item: u8) u8 {
  return if (item > 'Z') item - 'a' + 1 else item - 'A' + 27;
}

fn find_shared_letter(sorted_compartment1: []u8, sorted_compartment2: []u8) u8 {
  var idx1: u8 = 0;
  var idx2: u8 = 0;
  while (idx1 < sorted_compartment1.len and idx2 < sorted_compartment2.len) {
    if (sorted_compartment1[idx1] == sorted_compartment2[idx2]) {
      return sorted_compartment1[idx1];
    } else if (sorted_compartment1[idx1] < sorted_compartment2[idx2]) {
      idx1 += 1;
    } else {
      idx2 += 1;
    }
  }
  return 0;
}

fn find_shared_letter_3(sorted_rucksack_1: []u8, sorted_rucksack_2: []u8, sorted_rucksack_3: []u8) u8 {
  var idx1: u8 = 0;
  var idx2: u8 = 0;
  var idx3: u8 = 0;
  while (idx1 < sorted_rucksack_1.len and idx2 < sorted_rucksack_2.len and idx3 < sorted_rucksack_3.len) {
    if (sorted_rucksack_1[idx1] == sorted_rucksack_2[idx2] and sorted_rucksack_1[idx1] == sorted_rucksack_3[idx3]) {
      return sorted_rucksack_1[idx1];
    } else if (sorted_rucksack_1[idx1] <= sorted_rucksack_2[idx2] and sorted_rucksack_1[idx1] <= sorted_rucksack_3[idx3]) {
      idx1 += 1;
    } else if (sorted_rucksack_2[idx2] <= sorted_rucksack_1[idx1] and sorted_rucksack_2[idx2] <= sorted_rucksack_3[idx3]) {
      idx2 += 1;
    } else {
      idx3 += 1;
    }
  }
  return 0;
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

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
