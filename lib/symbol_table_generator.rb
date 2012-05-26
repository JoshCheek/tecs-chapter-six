require 'parser'

class SymbolTableGenerator

  def initialize(instructions, predefined={})
    self.instructions = instructions
    self.address = 15
    @symbols = predefined.dup
    find_labels
    find_variables
  end

  attr_reader :symbols

  def find_labels
    instruction_address = 0
    instructions.each do |instruction|
      case instruction
      when Parser::Label
        symbols[instruction.name] = instruction_address
      else
        instruction_address += 1
      end
    end
  end

  def find_variables
    instructions.each do |instruction|
      next unless instruction.kind_of? Parser::SymbolicAInstruction
      next if symbols[instruction.symbol]
      symbols[instruction.symbol] = (self.address += 1)
    end
  end

  protected

  attr_accessor :instructions, :address
end
