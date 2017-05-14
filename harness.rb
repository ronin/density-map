require "benchmark"

(0..13).each do |index|
  # This test is not included in zip package
  next if index == 10

  time = Benchmark.realtime do
    `ruby solution.rb map_tests/map#{index}.in map.out`
  end

  expected = File.read("map_tests/map#{index}.out")
  actual = File.read("map.out")

  result = actual == expected ? "Passed" : "Failed"
  formatted_time = "%0.3f" % time
  puts "Test %02d: %s, time: %0.4fs" % [index, result, time]

  File.unlink("map.out") if File.exists?("map.out")
end
