class Parser
  class Instruction
    attr_accessor :raw_instruction
    def initialize(raw_instruction)
      self.raw_instruction = raw_instruction
    end

    def to_s
      raw_instruction
    end
  end

  class Label < Instruction
    def name
      raw_instruction[/\(([^)]*)\)/, 1]
    end
  end

  class NumericAInstruction < Instruction
    def value
      raw_instruction.delete("@")
    end
  end

  class SymbolicAInstruction < Instruction
    def symbol
      raw_instruction.delete("@")
    end
  end

  class CInstruction < Instruction
    def initialize(raw_instruction)
      raise ArgumentError, "need a jump or dest" unless raw_instruction =~ /=|;/
      super
    end

    def dest
      raw_instruction[/^(\w+)=/, 1]
    end

    def comp
      raw_instruction[/=([^;]+)/, 1] || raw_instruction[/([^;]*);/, 1]
    end

    def jump
      raw_instruction[/;(\w+)/, 1]
    end
  end

  def initialize(assembly_code)
    self.assembly_lines = assembly_code.each_line
  end

  def instructions(&block)
    return to_enum :instructions unless block_given?
    assembly_lines.each do |line|
      fuck_comments_in line
      line.strip!
      next if line.empty?
      block.call interpret_line line
    end
  end

private

  attr_accessor :assembly_lines

  InstructionMatchers = {
    /^@\d+/ => NumericAInstruction,
    /^@\w+/ => SymbolicAInstruction,
    /^\(/   => Label,
    //      => CInstruction
  }

  def finished?
    assembly_lines.empty?
  end

  def fuck_comments_in(line)
    line.sub! /\/\/.*$/, ''
  end

  def interpret_line(line)
    InstructionMatchers.each do |matcher, instruction|
      return instruction.new(line) if line =~ matcher
    end
  end
end
