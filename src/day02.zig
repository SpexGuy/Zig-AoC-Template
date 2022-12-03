const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

pub fn main() !void {
  // Trim trailing \n's in file
  var trimmed_data = trim(u8, data, "\n");
  var rountes_by_line = split(u8, trimmed_data, "\n");
  var naive_score: u16 = 0;
  var informed_score: u16 = 0;
  var scores = StrMap(u8).init(std.heap.page_allocator);
  try scores.put("A X", 1 + 3);
  try scores.put("A Y", 2 + 6);
  try scores.put("A Z", 3);
  try scores.put("B X", 1);
  try scores.put("B Y", 2 + 3);
  try scores.put("B Z", 3 + 6);
  try scores.put("C X", 1 + 6);
  try scores.put("C Y", 2);
  try scores.put("C Z", 3 + 3);
  var ldw_to_play = StrMap([]const u8).init(std.heap.page_allocator);
  try ldw_to_play.put("A X", "A Z");
  try ldw_to_play.put("A Y", "A X");
  try ldw_to_play.put("A Z", "A Y");
  try ldw_to_play.put("B X", "B X");
  try ldw_to_play.put("B Y", "B Y");
  try ldw_to_play.put("B Z", "B Z");
  try ldw_to_play.put("C X", "C Y");
  try ldw_to_play.put("C Y", "C Z");
  try ldw_to_play.put("C Z", "C X");
  while (rountes_by_line.next()) |round_line| {
    const round_play = ldw_to_play.get(round_line) orelse "";
    naive_score += scores.get(round_line) orelse 0;
    informed_score += scores.get(round_play) orelse 0;
  }
  print("Answer 1: {}\n", .{naive_score});
  print("Answer 2: {}\n", .{informed_score});
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
