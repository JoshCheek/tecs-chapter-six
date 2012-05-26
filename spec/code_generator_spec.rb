require 'parser'
require 'code_generator'

describe CodeGenerator do
  describe Parser::NumericAInstruction do
    { "@0"   => "0000000000000000",
      "@2"   => "0000000000000010",
      "@100" => "0000000001100100",
    }.each do |instruction, machine_code|
      it "generates #{machine_code} from #{instruction}" do
        instruction = Parser::NumericAInstruction.new instruction
        CodeGenerator.new(instruction).generate.should == machine_code
      end
    end

    it 'looks up values in the symbol table' do
      instruction = Parser::SymbolicAInstruction.new "@SCREEN"
      CodeGenerator.new(instruction, "SCREEN" => 2)
        .generate.should == "0000000000000010"
    end
  end

  describe Parser::CInstruction do
    [ # comp
      '1110101010111000', 'AMD=0',   'sets comp for zero',
      '1110111111111000', 'AMD=1',   'sets comp for 1',
      '1110111010111000', 'AMD=-1',  'sets comp for -1',
      '1110001100111000', 'AMD=D',   'sets comp for D',
      '1110110000111000', 'AMD=A',   'sets comp for A',
      '1110001101111000', 'AMD=!D',  'sets comp for -D',
      '1110110001111000', 'AMD=!A',  'sets comp for -A',
      '1110001111111000', 'AMD=-D',  'sets comp for -D',
      '1110110011111000', 'AMD=-A',  'sets comp for -A',
      '1110011111111000', 'AMD=D+1', 'sets comp for D+1',
      '1110110111111000', 'AMD=A+1', 'sets comp for A+1',
      '1110001110111000', 'AMD=D-1', 'sets comp for D-1',
      '1110110010111000', 'AMD=A-1', 'sets comp for A-1',
      '1110000010111000', 'AMD=D+A', 'sets comp for D+A',
      '1110010011111000', 'AMD=D-A', 'sets comp for D-A',
      '1110000111111000', 'AMD=A-D', 'sets comp for A-D',
      '1110000000111000', 'AMD=D&A', 'sets comp for D&A',
      '1110010101111000', 'AMD=D|A', 'sets comp for D|A',
      '1111110000111000', 'AMD=M',   'sets comp for M',
      '1111110001111000', 'AMD=!M',  'sets comp for !M',
      '1111110011111000', 'AMD=-M',  'sets comp for -M',
      '1111110111111000', 'AMD=M+1', 'sets comp for M+1',
      '1111110010111000', 'AMD=M-1', 'sets comp for M-1',
      '1111000010111000', 'AMD=D+M', 'sets comp for D+M',
      '1111010011111000', 'AMD=D-M', 'sets comp for D-M',
      '1111000111111000', 'AMD=M-D', 'sets comp for M-D',
      '1111000000111000', 'AMD=D&M', 'sets comp for D&M',
      '1111010101111000', 'AMD=D|M', 'sets comp for D|M',

      # dests
      '1110000000000111', 'D&A;JMP', 'sets dest to zero when no dest',
      '1110000000001000', 'M=D&A',   'sets dest for M',
      '1110000000010000', 'D=D&A',   'sets dest for D',
      '1110000000011000', 'MD=D&A',  'sets dest for MD',
      '1110000000100000', 'A=D&A',   'sets dest for A',
      '1110000000101000', 'AM=D&A',  'sets dest for AM',
      '1110000000110000', 'AD=D&A',  'sets dest for AD',
      '1110000000111000', 'AMD=D&A', 'sets dest for AMD',

      # jumps
      '1110000000010000', 'D=D&A',   'sets jump to zero when no jump',
      '1110000000000001', 'D&A;JGT', 'sets jump for JGT',
      '1110000000000010', 'D&A;JEQ', 'sets jump for JEQ',
      '1110000000000011', 'D&A;JGE', 'sets jump for JGE',
      '1110000000000100', 'D&A;JLT', 'sets jump for JLT',
      '1110000000000101', 'D&A;JNE', 'sets jump for JNE',
      '1110000000000110', 'D&A;JLE', 'sets jump for JLE',
      '1110000000000111', 'D&A;JMP', 'sets jump for JMP',
    ].each_slice 3 do |machine_code, raw_instruction, comment|
      it comment do
        instruction = Parser::CInstruction.new raw_instruction
        CodeGenerator.new(instruction).generate.should == machine_code
      end
    end
  end

  specify 'everything else is parsed to empty string' do
    CodeGenerator.new(Parser::Label.new('(a)')).generate.should == ''
    CodeGenerator.new('').generate.should == ''
  end
end
