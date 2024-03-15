#!/usc/bin/env ruby

$mode = 'exp'

Modes = {
  pow: lambda { |b, e| b ** e },
  pow2: lambda { |e| 2 ** e },
  sqrt: Math.method(:sqrt),
  exp: Math.method(:exp),
  log: Math.method(:log),
  log2: Math.method(:log2),
  sin: Math.method(:sin),
  cos: Math.method(:cos),
  tan: Math.method(:tan),
  sinh: Math.method(:sinh),
  cosh: Math.method(:cosh),
  tanh: Math.method(:tanh),
  asin: Math.method(:asin),
  acos: Math.method(:acos),
  atan: Math.method(:atan),
  asinh: Math.method(:asinh),
  acosh: Math.method(:acosh),
  atanh: Math.method(:atanh),
}

def call_fn *args
  r = Modes.fetch($mode.to_sym).call(*args)
  $stdout.puts((args + [ r ]).collect { |a| "%.8f" % [ a ]}.join(" "))
  $stdout.flush
rescue RangeError
  $stderr.puts($!)
  $stdout.puts((args + [ 0 ]).collect { |a| "%.8f" % [ a ]}.join(" "))
end

ARGF.each_line do |line|
  case line
  when /^mode\s+(\w+)/ then $mode = $1; $stderr.puts("Mode set to #{$mode}")
  when /^([-+]?\d+(\.\d+)?)\s+([-+]?\d+(\.\d+)?)/ then call_fn($1.to_f, $3.to_f)
  when /^([-+]?\d+(\.\d+)?)/ then call_fn($1.to_f)
  end
end
