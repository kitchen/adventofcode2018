require 'minitest/autorun'
require 'minitest/assertions'

require './registers'

class RegisterTest < Minitest::Test
  SAMPLE_PROGRAM = <<~EOF.strip
    #ip 0
    seti 5 0 1
    seti 6 0 2
    addi 0 1 0
    addr 1 2 3
    setr 1 0 0
    seti 8 0 4
    seti 9 0 5
  EOF

  def test_load
    program = Program.new(SAMPLE_PROGRAM)
    assert_equal(0, program.ip)
    assert_equal([0,0,0,0,0,0], program.registers)

    program.tick!
    assert_equal([1, 5, 0, 0, 0, 0], program.registers)

    program.tick!
    assert_equal([2, 5, 6, 0, 0, 0], program.registers)

    program.tick!
    assert_equal([4, 5, 6, 0, 0, 0], program.registers)

    program.tick!
    assert_equal([6, 5, 6, 0, 0, 0], program.registers)

    program.tick!
    assert_equal([7, 5, 6, 0, 0, 9], program.registers)

    refute(program.tick!)
    assert_equal([7, 5, 6, 0, 0, 9], program.registers)
  end

  def test_run
    program = Program.new(SAMPLE_PROGRAM)
    program.run!
    assert_equal([7, 5, 6, 0, 0, 9], program.registers)
  end
end
