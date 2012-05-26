Feature:
  Assembles programs that contain variables and labels

  Scenario:
    Given the assembly is in "max/Max.asm"
    Then the assembler emits the code in "max/Max.hack"

  Scenario:
    Given the assembly is in "rect/Rect.asm"
    Then the assembler emits the code in "rect/Rect.hack"

  Scenario:
    Given the assembly is in "pong/Pong.asm"
    Then the assembler emits the code in "pong/Pong.hack"
