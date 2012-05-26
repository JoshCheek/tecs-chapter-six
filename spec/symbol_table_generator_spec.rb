require 'symbol_table_generator'

describe SymbolTableGenerator do
  def sa(raw_instruction)
    Parser::SymbolicAInstruction.new "@#{raw_instruction}"
  end

  def na(raw_instruction)
    Parser::NumericAInstruction.new "@#{raw_instruction}"
  end

  def l(raw_instruction)
    Parser::Label.new "(#{raw_instruction})"
  end

  it 'finds and allocates memory for variables, starting at address 16' do
    described_class.new([sa('a'), sa('b')]).symbols.should == {'a' => 16, 'b' => 17}
  end

  it 'does not re-allocate memory for a known variable' do
    described_class.new([sa('a'), sa('a'), sa('b')])
      .symbols.should == { 'a' => 16, 'b' => 17}
  end

  it 'does not allocate memory for numeric a-instructions' do
    described_class.new([na('2'), sa('a')])
      .symbols.should == {'a' => 16}
  end

  it 'finds labels' do
    described_class.new([l('a'), na('b'), l('c')])
      .symbols.should == {'a' => 0, 'c' => 1}
  end

  it 'can be given predefined labels' do
    described_class.new([sa('a')], 'a' => 123)
      .symbols.should == {'a' => 123}
  end

  it 'finds labels with variables and predefined symbols' do
    described_class.new(
      [l('a'), na('1'), sa('a'), sa('b'), sa('c'), sa('d'), na('2'), l('d')],
      'c' => 20, 'e' => 30
    ).symbols.should == {'a' => 0, 'b' => 16, 'c' => 20, 'd' => 6, 'e' => 30}
  end
end
