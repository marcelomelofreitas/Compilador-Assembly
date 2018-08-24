unit parser;

interface

uses
  cstring,
  stdio,
  global,
  string_utils,
  stack_utils,
  hash;

procedure generate_intermediate_code(FileName: PAnsiChar);

implementation

uses
  AsmParserInstruction,
  AsmInstruction;

function get_size_of_var(var_name: PAnsiChar): Integer;
var
  len: integer;
  count: Integer;
  split_var: TArray<PAnsiChar>;
begin
	len := strlen(var_name);
	if (len = 1) then
		Exit(1)
	else if (len > 3) then
	begin
		count := 0;
		split_var := splitString(var_name, '[', @count);
		if (count > 1) then
		begin
			Exit(Ord(split_var[1][0]));
		end;
	end;
	Result := -1;
end;

function const_statement(sub_instruction: PAnsiChar; constant_start_address: Integer): Integer;
var
  count: integer;
  split_exprsn: TArray<PAnsiChar>;
  left_bracket_index: Integer;
  right_bracket_index: Integer;
  size_of_var: PAnsiChar;
  var_name: PAnsiChar;
  var_size: Integer;
  TokenPtr: TTokenPtr;
begin
	TokenPtr := AllocMem(sizeof(TToken));
	TokenPtr^.Address := constant_start_address;
 	TokenPtr^.size := 0;
 	TokenPtr^.next := nil;

	if not (strstr(sub_instruction, '=') = nil) then
	begin
		count := 0;
		split_exprsn := splitString(sub_instruction, '=', @count);
    var_name := split_exprsn[0];
		memory_blocks[constant_start_address] := Ord(split_exprsn[1][0]) - 0;
	end
	else if not (strstr(sub_instruction, '[') = nil) then
	begin
		left_bracket_index := strcspn(sub_instruction, '[');
		right_bracket_index := strcspn(sub_instruction, ']');
		size_of_var := sub_string(sub_instruction, left_bracket_index, right_bracket_index - 1);
		var_name := sub_string(sub_instruction, 0, left_bracket_index - 1);
		var_size := atoi(size_of_var);
		constant_start_address := constant_start_address + var_size;
	end
	else
  begin
    var_name := sub_instruction;
    constant_start_address := constant_start_address + 1;
  end;

	TokenPtr^.Spelling := AllocMem(sizeof(AnsiChar) * (strlen(var_name) + 1));
	strcpy(TokenPtr^.Spelling, var_name);
	InsertIntoSymbolTable(TokenPtr);

 	Result := constant_start_address + 1;
end;

function var_statement(sub_instruction: PAnsiChar; start_address: Integer): Integer;
var
  var_name: PAnsiChar;
  var_size: Integer;
  TokenPtr: TTokenPtr;
begin
  var_name := sub_instruction;
	var_size := get_size_of_var(var_name);

	if (var_size = -1) then
		Error('Falha na declaracao do tamanho da variavel: [%s].'#10, var_name);

	TokenPtr := AllocMem(sizeof(TToken));
	TokenPtr^.Spelling := AllocMem(sizeof(AnsiChar) * (strlen(var_name) + 1));
	TokenPtr^.Address := start_address;
 	TokenPtr^.size := var_size;
 	TokenPtr^.next := nil;

	strcpy(TokenPtr^.Spelling, var_name);
  insertIntoSymbolTable(TokenPtr);

	Result := TokenPtr^.Address + TokenPtr^.size;
end;


procedure jump_mnemonic_statement(TokenPtr: TTokenPtr; var split_instruction: TArray<PAnsiChar>; var split_instr_count: Integer);
var
  new_instruction: TAsmInstructionPtr;
  LabelPtr: TLabelItemPtr;
begin
	new_instruction := AllocMem(sizeof(TAsmInstruction));
	new_instruction^.Mnemonic := TokenPtr.Mnemonic;
	new_instruction^.OperandCount := 1;
  new_instruction^.Operands[0].Type_ := TAsmOperandType.Imm;

	LabelPtr := SearchInLabelTable(split_instruction[1]);

  if not (LabelPtr = nil) then
	  new_instruction^.Operands[0].Imm.Value := LabelPtr^.instruction_number;

	main_intermediate_table.item[main_intermediate_table.count] := new_instruction;
	Inc(main_intermediate_table.count);
end;

procedure mov_mnemonic_statement(TokenPtr: TTokenPtr; var split_instruction: TArray<PAnsiChar>; var split_instr_count: Integer);
var
  params: TArray<PAnsiChar>;
begin
	SetLength(params, 1);
	params[0] := split_instruction[1];
//  error('implementar a funcao "mov_mnemonic_statement"')
end;

procedure mul_mnemonic_statement(TokenPtr: TTokenPtr; var split_instruction: TArray<PAnsiChar>; var split_instr_count: Integer);
var
  params: TArray<PAnsiChar>;
begin
	SetLength(params, 1);
	params[0] := split_instruction[1];
//  error('implementar a funcao "mov_mnemonic_statement"')
end;

procedure sub_mnemonic_statement(TokenPtr: TTokenPtr; var split_instruction: TArray<PAnsiChar>; var split_instr_count: Integer);
var
  params: TArray<PAnsiChar>;
begin
	SetLength(params, 1);
	params[0] := split_instruction[1];
//  error('implementar a funcao "mov_mnemonic_statement"')
end;

procedure add_mnemonic_statement(TokenPtr: TTokenPtr; var split_instruction: TArray<PAnsiChar>; var split_instr_count: Integer);
var
  params: TArray<PAnsiChar>;
begin
	SetLength(params, 1);
	params[0] := split_instruction[1];
//  error('implementar a funcao "mov_mnemonic_statement"')
end;

procedure asm_mnemonic(TokenPtr: TTokenPtr; var split_instruction: TArray<PAnsiChar>; var split_instr_count: Integer);
var
  new_instruction: TAsmInstructionPtr;
  LabelPtr: TLabelItemPtr;
  i: Integer;
begin
	new_instruction := AllocMem(sizeof(TAsmInstruction));

  for i := 0 to split_instr_count - 1 do
  begin
    Trim(split_instruction[i]);
    strcat(new_instruction.Str, split_instruction[i]);
    strcat(new_instruction.Str, ' ');
  end;

  if not AsmParseString(new_instruction) then
    error('Instrução assembly invalida ou mal formatada: %s', split_instruction);


	main_intermediate_table.item[main_intermediate_table.count] := new_instruction;
	Inc(main_intermediate_table.count);

//  case TokenPtr^.Mnemonic of
//    TAsmMnemonic.X86_JP: jump_mnemonic_statement(TokenPtr, split_instruction, split_instr_count);
//    TAsmMnemonic.X86_MOV: mov_mnemonic_statement(TokenPtr, split_instruction, split_instr_count);
//    TAsmMnemonic.X86_MUL: mul_mnemonic_statement(TokenPtr, split_instruction, split_instr_count);
//    TAsmMnemonic.X86_SUB: sub_mnemonic_statement(TokenPtr, split_instruction, split_instr_count);
//    TAsmMnemonic.X86_ADD: add_mnemonic_statement(TokenPtr, split_instruction, split_instr_count);
//  else
//    Error('Mnemonic invalido ou nao suportado %s', split_instruction[0]);
//  end;
end;

procedure generate_intermediate_code(FileName: PAnsiChar);
var
  SourceFilePtr: THandle;
	start_address: NativeUInt;
  line: TAsmBuffer;
  colon_index: Integer;
  line_length: Integer;
  split_instr_count: integer;
  split_instruction: TArray<PAnsiChar>;
  TokenPtr: TTokenPtr;
begin
	if (FileName = nil) then
		Exit();

  CurrentFileName := FileName;
	SourceFilePtr := fopen(FileName, 'r');
	if (SourceFilePtr = 0) then
		Error('Nao e possivel ler o arquivo fonte: %s', FileName);

  line_num := 0;
  start_address := 0;

  while not feof(SourceFilePtr) do
  begin
    inc(line_num);
    fgets(line, 500, SourceFilePtr);
    Trim(line);

    line_length := strlen(line);

    if line_length = 0 then
      Continue;

    colon_index := strcspn(line, ':');

    if (colon_index = (line_length - 1)) then
    begin
			//JUMP Label encontrado
			InsertIntoLabelTable(sub_string(line, 0, colon_index - 1), main_intermediate_table.count + 1);
			Continue;
    end;

		split_instr_count := 0;
		split_instruction := splitString(line, ' ', @split_instr_count);

    if (split_instruction[0][0] = #9) then
      split_instruction[0] := sub_string(split_instruction[0], 1,strlen(split_instruction[0]));

    TokenPtr := SearchInSymbolTable(split_instruction[0]);

    if (TokenPtr <> nil) and (split_instruction <> nil) then
    begin
      Trim(split_instruction[1]);

      case (TokenPtr^.Kind) of
         TTokenKind.VAR_STATEMENT:
            start_address := var_statement(split_instruction[1], start_address);
         TTokenKind.CONST_STATEMENT:
            start_address := const_statement(split_instruction[1], start_address);
         TTokenKind.ASM_MNEMONIC:
            asm_mnemonic(TokenPtr, split_instruction, split_instr_count);
      else
          Error('Chamada de comando invalido: %s', split_instruction[0]);
      end;
    end
    else
    begin
      Error('Comando invalido: %s', split_instruction[0]);
    end;
  end;

  fclose(SourceFilePtr);
end;

end.
