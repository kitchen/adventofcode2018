
class Registers
  INSTRUCTIONS = %i{
    addr addi mulr muli banr bani borr bori
    setr seti gtir gtri gtrr eqir eqri eqrr
  }.freeze

  INSTRUCTION_MAP = {
    0 => :bani,
    1 => :banr,
    2 => :muli,
    3 => :setr,
    4 => :bori,
    5 => :eqrr,
    6 => :gtir,
    7 => :mulr,
    8 => :gtrr,
    9 => :seti,
    10 => :gtri,
    11 => :eqri,
    12 => :addi,
    13 => :borr,
    14 => :eqir,
    15 => :addr,
  }

  def self.addr(registers, reg_a, reg_b, output)
    registers[output] = registers[reg_a] + registers[reg_b]
    registers
  end

  def self.addi(registers, reg_a, value_b, output)
    registers[output] = registers[reg_a] + value_b
    registers
  rescue
  end

  def self.mulr(registers, reg_a, reg_b, output)
    registers[output] = registers[reg_a] * registers[reg_b]
    registers
  end

  def self.muli(registers, reg_a, value_b, output)
    registers[output] = registers[reg_a] * value_b
    registers
  end

  def self.banr(registers, reg_a, reg_b, output)
    registers[output] = registers[reg_a] & registers[reg_b]
    registers
  end

  def self.bani(registers, reg_a, value_b, output)
    registers[output] = registers[reg_a] & value_b
    registers
  end

  def self.borr(registers, reg_a, reg_b, output)
    registers[output] = registers[reg_a] | registers[reg_b]
    registers
  end

  def self.bori(registers, reg_a, value_b, output)
    registers[output] = registers[reg_a] | value_b
    registers
  end

  def self.setr(registers, reg_a, _, output)
    registers[output] = registers[reg_a]
    registers
  end

  def self.seti(registers, value_a, _, output)
    registers[output] = value_a
    registers
  end

  def self.gtir(registers, value_a, reg_b, output)
    registers[output] = value_a > registers[reg_b] ? 1 : 0
    registers
  end

  def self.gtri(registers, reg_a, value_b, output)
    registers[output] = registers[reg_a] > value_b ? 1 : 0
    registers
  end

  def self.gtrr(registers, reg_a, reg_b, output)
    registers[output] = registers[reg_a] > registers[reg_b] ? 1 : 0
    registers
  end

  def self.eqir(registers, value_a, reg_b, output)
    registers[output] = value_a == registers[reg_b] ? 1 : 0
    registers
  end

  def self.eqri(registers, reg_a, value_b, output)
    registers[output] = registers[reg_a] == value_b ? 1 : 0
    registers
  end

  def self.eqrr(registers, reg_a, reg_b, output)
    registers[output] = registers[reg_a] == registers[reg_b] ? 1 : 0
    registers
  end

  def self.find_matching_instructions(before, instruction, after)
    instruction = to_instruction(instruction)
    before = to_register(before)
    after = to_register(after)

    matches = INSTRUCTIONS.select do |instruction_name|
      register = before.dup
      self.send(instruction_name, register, instruction[1], instruction[2], instruction[3])
      after == register
    end
    # puts "#{before} % #{instruction} = #{after} (#{matches})"
    matches
  end

  def self.to_instruction(instruction)
    instruction = instruction.split(/\s+/).map(&:to_i) if instruction.is_a?(String)
    instruction
  end

  def self.to_register(input)
    return input if input.is_a?(Hash)
    input = input.split(/\s+/).map(&:to_i) if input.is_a?(String)
    input.map!(&:to_i)
  end

  # this needs an actual array coming in because it modifies it
  def self.execute_instruction(register, instruction)
    instruction = to_instruction(instruction)
    puts "#{register} => #{instruction[0]} #{INSTRUCTION_MAP[instruction[0]]} => #{instruction}"
    self.send(INSTRUCTION_MAP[instruction[0]], register, instruction[1], instruction[2], instruction[3])
  end
end
