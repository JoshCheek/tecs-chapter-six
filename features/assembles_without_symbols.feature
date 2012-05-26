Feature: Assembles code without symbols

  Scenario: Compile the add program
    Given the assembly 
      """
      // This file is part of the materials accompanying the book 
      // "The Elements of Computing Systems" by Nisan and Schocken, 
      // MIT Press. Book site: www.idc.ac.il/tecs
      // File name: projects/06/add/Add.asm
      
      // Computes R0 = 2 + 3
      @2
      D=A
      @3
      D=D+A
      @0
      M=D
      """
    Then the assembler emits
      """
      0000000000000010
      1110110000010000
      0000000000000011
      1110000010010000
      0000000000000000
      1110001100001000

      """

  Scenario: Compile the pong program
    Given the assembly is in "pong/PongL.asm"
    Then the assembler emits the code in "pong/PongL.hack"
