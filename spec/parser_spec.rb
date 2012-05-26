require 'parser'

describe Parser do

  describe '#instructions' do
    def instruction_for(code)
      Parser.new(code).instructions.first
    end

    it 'parses numeric a instructions' do
      instruction = instruction_for '@2'
      instruction.should be_a_kind_of Parser::NumericAInstruction
      instruction.to_s.should == '@2'
    end

    it 'parses numeric a instructions with comments' do
      instruction = instruction_for "@3 // comment"
      instruction.should be_a_kind_of Parser::NumericAInstruction
      instruction.to_s.should == '@3'
    end

    it 'parses symbolic a instructions' do
      instruction = instruction_for '@a'
      instruction.should be_a_kind_of Parser::SymbolicAInstruction
      instruction.to_s.should == '@a'
    end

    it 'parses crazy symbolic a instructions' do
      instruction = instruction_for '@aB_c.e$f4:'
      instruction.should be_a_kind_of Parser::SymbolicAInstruction
      instruction.to_s.should == '@aB_c.e$f4:'
    end

    it 'parses c instructions' do
      instruction = instruction_for "D=A"
      instruction.should be_a_kind_of Parser::CInstruction
      instruction.to_s.should == "D=A"
    end

    it 'parses c instructions with comments' do
      instruction = instruction_for "D=A // comment"
      instruction.should be_a_kind_of Parser::CInstruction
      instruction.to_s.should == "D=A"
    end

    it 'parses labels' do
      instruction = instruction_for '(Whatever)'
      instruction.should be_a_kind_of Parser::Label
      instruction.to_s.should == '(Whatever)'
    end

    it 'parses labels with comments' do
      instruction = instruction_for '(Whatever) // comment'
      instruction.should be_a_kind_of Parser::Label
      instruction.to_s.should == '(Whatever)'
    end

    it 'parses labels with crazy characters' do
      instruction = instruction_for '(aB_c.e$f4:)'
      instruction.should be_a_kind_of Parser::Label
      instruction.to_s.should == '(aB_c.e$f4:)'
    end

    it 'ignores blank lines' do
      Parser.new("").instructions.to_a.should be_empty
    end

    it 'parses multiple instructions' do
      Parser.new("//a\n@4 //b\n\nA=D").instructions.map(&:to_s).should == ['@4', 'A=D']
    end
  end
end

describe Parser::Label do
  it 'has a name' do
    described_class.new('(HELLO)').name.should == 'HELLO'
  end

  it 'can deal with crazy characters' do
    described_class.new('(aB_c.e$f4:)').name.should == 'aB_c.e$f4:'
  end
end

describe Parser::NumericAInstruction do
  it 'knows its value' do
    described_class.new('@2').value.should == "2"
    described_class.new('@3').value.should == "3"
  end
end

describe Parser::SymbolicAInstruction do
  it 'knows its symbol' do
    described_class.new('@a').symbol.should == 'a'
    described_class.new('@aB_c.e$f:').symbol.should == 'aB_c.e$f:'
  end
end

describe Parser::CInstruction do
  def dcj(assembly)
    instruction = described_class.new(assembly)
    [instruction.dest, instruction.comp, instruction.jump]
  end

  context 'dest=comp;jump' do
    it 'knows its dest, comp, and jump' do
      dcj('A=D;JGT').should == ['A', 'D', 'JGT']
      dcj('A=-D;JGT').should == ['A', '-D', 'JGT']
      dcj('A=!D;JGT').should == ['A', '!D', 'JGT']
      dcj('A=M|A;JGT').should == ['A', 'M|A', 'JGT']
      dcj('A=M&A;JGT').should == ['A', 'M&A', 'JGT']
    end
  end

  context 'comp;jump' do
    it 'has no dest, knows its comp and jump' do
      dcj('M&A;JGT').should == [nil, 'M&A', 'JGT']
      dcj('M|A;JGT').should == [nil, 'M|A', 'JGT']
      dcj('!A;JGT').should  == [nil, '!A',  'JGT']
      dcj('-D;JGT').should  == [nil, '-D', 'JGT']
    end
  end

  context 'dest=comp' do
    it 'knows its dest and comp, and has no jump' do
      dcj('A=M&A').should == ['A', 'M&A', nil]
      dcj('D=M|A').should == ['D', 'M|A', nil]
      dcj('M=!A;').should == ['M', '!A',  nil]
      dcj('M=-D;').should == ['M', '-D',  nil]
    end
  end

  context 'comp' do
    it 'blows up when initialized' do
      expect { described_class.new("A") }.to raise_error ArgumentError
    end
  end
end
