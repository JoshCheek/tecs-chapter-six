Given 'the assembly' do |assembly_code|
  @assembler = Assembler.new assembly_code
end

Then 'the assembler emits' do |machine_code|
  @assembler.machine_code.should == machine_code
end

Given 'the assembly is in "$filename"' do |filename|
  @assembler = Assembler.new File.read filename
end

Then 'the assembler emits the code in "$filename"' do |filename|
  @assembler.machine_code.should == File.read(filename)
end
