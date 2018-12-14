require 'minitest/autorun'
require 'minitest/assertions'
class SleepyGuards
  attr_accessor :guards
  def initialize
    @guards = Hash.new { |h,k| h[k] = Hash.new(0) }
  end

  def load_from_lines(lines)
    current_guard = nil
    asleep_time = nil
    lines.each do |line|
      line.chomp
      puts line
      if line.match(/Guard #(\d+) begins shift/)
        (_, guard) = line.match(/Guard #(\d+) begins shift/).to_a
        current_guard = guard
        puts "guard changed"
      elsif current_guard && line.match(/(\d\d)\].*falls asleep/)
        (_, time) = line.match(/(\d\d)\].*falls asleep/).to_a
        puts "fell asleep"
        asleep_time = time.to_i
      elsif current_guard && asleep_time && line.match(/(\d\d)\].*wakes up/)
        (_, wake_time) = line.match(/(\d\d)\].*wakes up/).to_a
        puts "woke up"
        wake_time = wake_time.to_i

        puts "guard #{current_guard} sleep time: #{asleep_time} wake time: #{wake_time}"
        (asleep_time...wake_time).each do |minute|
          guards[current_guard][minute] += 1
        end
        asleep_time = nil
      else
        puts "uhhh... weird line / state? #{line} (#{current_guard}, #{asleep_time})"
      end
    end
  end

  def load_from_file(file)
    load_from_lines(File.readlines(file))
  end

  def sort_by_sleepiest
    guards.sort {|a, b| a[1].values.sum <=> b[1].values.sum}.reverse
  end

  def sort_by_frequentest
    guards.sort {|a, b| a[1].values.max <=> b[1].values.max}.reverse
  end

end


class SleepyGuardsTest < Minitest::Test

  def test_load_data
    guards = SleepyGuards.new
  end
end

