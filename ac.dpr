program ac;

uses
  stdio,
  grammar in 'grammar.pas',
  memory_utils in 'memory_utils.pas',
  global in 'global.pas',
  hash in 'hash.pas',
  parser in 'parser.pas',
  stack_utils in 'stack_utils.pas',
  string_utils in 'string_utils.pas',
  AsmParserInstruction in 'AsmParserInstruction.pas';

begin

	initializeSymboltable();
	initializeKeywords();
	initialize_instruction_table();
	initialize_label_table();
	initialize_constant_symboltable();
	generate_intermediate_code('exemplo1.asm');
  printf('fim, instrucoes.. %d', main_intermediate_table.Count);
  getch();

end.
