#!/usr/bin/env ruby

numbers = [
  0x12345,
  0x1,
  0x0,
  0x1000,
  0x1010,
  0x1FEEDDCC,
  0xFFEEDDCC,
  0x12,
  -0x12,
  0x5499B42C,
  -0x5499B42C,
  0xC499B42C,
  -0xC499B42C,
  4294967295
]

bases = ARGV[0] ? ARGV.collect(&:to_i) : [ 10, 36, 16, 8, 5, 4, 3, 2 ]

puts(bases.join("\t"))
numbers.reverse.each do |n|
  puts(bases.collect { n.to_s(_1) }.join("\t"))
end
