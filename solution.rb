class DensityMapSolver
  attr_reader :size, :radius, :input

  def initialize(input_filename, output_filename)
    @input_filename = input_filename
    @output_filename = output_filename
    @input = []
  end

  # Read input data from input file.
  def read_input_data
    File.open(@input_filename) do |file|
      file.each.with_index do |line, index|
        # If this is a first line, read array size n and radius r
        if index == 0
          @size, @radius = line.split(" ").map(&:to_i)
        else
          @input.push(line.split.map(&:to_i))
        end
      end
    end
  end

  # Write computed density map to output file
  def write_output_data
    File.open(@output_filename, "w") do |file|
      @output.each do |row|
        file.puts(row.join(" "))
      end
    end
  end

  # Get the value at position (x, y) or 0 if (x, y) is outside array range
  def get(array, x, y)
    if x >= 0 && x < size && y >= 0 && y < size
      array[y][x]
    else
      0
    end
  end

  # Set the value at position (x, y) or no-op if (x, y) is outside array range
  def set(array, x, y, value)
    if x >= 0 && x < size && y >= 0 && y < size
      array[y][x] = value
    end
  end

  # Initialize two-dimensional array
  def init_empty_array
    (0...size).map { [] }
  end

  # Computes sum of all elements that are in specified range,
  # from (x1, y1) to (x2, y2). At the beginning it limits the range
  # to only elements that are inside array range.
  def compute_sum(array, x1, x2, y1, y2)
    sum = 0
    x1 = [0, x1].max
    x2 = [x2, size - 1].min
    y1 = [0, y1].max
    y2 = [y2, size - 1].min

    (x1..x2).each do |x|
      (y1..y2).each do |y|
        sum += get(array, x, y)
      end
    end

    sum
  end

  def run_naive_solution
    @output = init_empty_array

    size.times do |x|
      size.times do |y|
        sum = compute_sum(input, x - radius, x + radius, y - radius, y + radius)
        set(@output, x, y, sum)
      end
    end
  end

  def run_better_solution
    @output = init_empty_array

    (0...size).each do |y|
      if y == 0
        set(@output, 0, 0, compute_sum(input, 0 - radius, 0 + radius, 0 - radius, 0 + radius))
      else
        top_row = compute_sum(input, 0, radius, y - radius - 1, y - radius - 1)
        bottom_row = compute_sum(input, 0, radius, y + radius, y + radius)
        set(@output, 0, y, get(@output, 0, y - 1) - top_row + bottom_row)
      end

      (1...size).each do |x|
        left_column = compute_sum(input, x - radius - 1, x - radius - 1, y - radius, y + radius)
        right_column = compute_sum(input, x + radius, x + radius, y - radius, y + radius)
        set(@output, x, y, get(@output, x - 1, y) - left_column + right_column)
      end
    end
  end

  def run_optimal_solution
    @temp = init_empty_array

    size.times do |y|
      sum = compute_sum(input, 0, radius, y, y)
      set(@temp, 0, y, sum)

      1.upto(size - 1) do |i|
        sum = sum - get(input, i - radius - 1, y) + get(input, i + radius, y)
        set(@temp, i, y, sum)
      end
    end

    @output = init_empty_array

    size.times do |x|
      sum = compute_sum(@temp, x, x, 0, radius)
      set(@output, x, 0, sum)

      1.upto(size - 1) do |i|
        sum = sum - get(@temp, x, i - radius - 1) + get(@temp, x, i + radius)
        set(@output, x, i, sum)
      end
    end
  end

  def run_official_solution
    sums = init_empty_array

    size.times do |y|
      row_sum = 0

      size.times do |x|
        row_sum += get(@input, x, y)
        top = y == 0 ? 0 : get(sums, x, y - 1)
        set(sums, x, y, row_sum + top)
      end
    end

    @output = init_empty_array

    size.times do |y|
      size.times do |x|
        x1 = [0, x - radius].max
        x2 = [x + radius, size - 1].min
        y1 = [0, y - radius].max
        y2 = [y + radius, size - 1].min

        value = get(sums, x2, y2) - get(sums, x2, y1 - 1) - get(sums, x1 - 1, y2) + get(sums, x1 - 1, y1 - 1)
        set(@output, x, y, value)
      end
    end
  end
end

solver = DensityMapSolver.new(ARGV[0], ARGV[1])

solver.read_input_data
# solver.run_naive_solution
# solver.run_better_solution
solver.run_optimal_solution
#solver.run_official_solution
solver.write_output_data
