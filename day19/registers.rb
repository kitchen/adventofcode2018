
class Registers
  INSTRUCTIONS = %i{
    addr addi mulr muli banr bani borr bori
    setr seti gtir gtri gtrr eqir eqri eqrr
  }.freeze

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
    # puts "#{register} => #{instruction[0]} #{INSTRUCTION_MAP[instruction[0]]} => #{instruction}"
    self.send(INSTRUCTION_MAP[instruction[0]], register, instruction[1], instruction[2], instruction[3])
  end
end

class Program
  attr_accessor :ip
  attr_accessor :instructions
  attr_accessor :registers
  def initialize(program_lines, initial_register = [0,0,0,0,0,0])
    program_lines = program_lines.split(/\n/) if program_lines.is_a?(String)

    @ip = program_lines.shift.gsub(/[^\d]/, '').to_i
    @instructions = program_lines.map do |instruction|
      instruction = instruction.split(/\s+/)
      instruction[1] = instruction[1].to_i
      instruction[2] = instruction[2].to_i
      instruction[3] = instruction[3].to_i
      instruction
    end

    @registers = initial_register
  end

  def tick!
    if instruction = instructions[registers[ip]]
      Registers.send(instruction[0], registers, instruction[1], instruction[2], instruction[3])
      registers[ip] += 1
      true
    else
      false
    end
  end

  def run!
    loop do
      break unless tick!
    end
  end

end
