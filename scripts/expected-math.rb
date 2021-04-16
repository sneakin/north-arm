#!/bin/env ruby

mode = ARGV.shift
MIN=(ARGV.shift || 0.0).to_f
MAX=(ARGV.shift || (Math::PI * 2.0)).to_f
STEP=(ARGV.shift || 0.1).to_f

case mode
when /^trig/ then
  Range.new(MIN, MAX).step(STEP).each do |n|
    puts("%.6f %.6f %.6f %.6f" % [ n, Math.sin(n), Math.cos(n), Math.tan(n) ])
  end
when /^hyp/ then
  Range.new(MIN, MAX).step(STEP).each do |n|
    puts("%.6f %.6f %.6f %.6f" % [ n, Math.sinh(n), Math.cosh(n), Math.tanh(n) ])
  end
when /^log/ then
  Range.new(MIN, MAX).step(STEP).each do |n|
    puts("%.6f %.6f %.6f %.6f %.6f" % [ n, Math.exp(n), Math.log(n), Math.log2(n), Math.log10(n) ])
  end
when /^sq/ then
  Range.new(MIN, MAX).step(STEP).each do |n|
    puts("%.6f %.6f" % [ n, Math.sqrt(n) ])
  end
else puts("Unknown mode. Try 'log', 'sq', 'trig', or 'hyp'.")
end

