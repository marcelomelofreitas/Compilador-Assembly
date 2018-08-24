unit AsmParserInstruction;

interface

uses
  System.TypInfo,
  cstring,
  ctype,
  stdlib,
  AsmInstruction;

function AsmParseString(Instruction: TAsmInstructionPtr): Boolean;

implementation

type
  TAsmParserTokensPtr = ^TAsmParserTokens;
  TAsmParserTokens = array[0..7] of array[0..63] of AnsiChar;

function NextToken(Dest: PAnsichar; Src: PAnsiChar; Operand: Boolean): PAnsiChar;
var
    bufEnd: PAnsiChar;
begin
// Saltar espaços
  while(Src^  = ' ') or (Src^ = #9) do   //Lembre-se #9 = tab na tabela ASCII, assim pula espacos e tabs ;)
    Inc(Src);

  bufEnd := nil;

  if (Operand) then
  begin
     bufEnd := strchr(Src, ',');

     // Skip spaces
//     while (Src^ = ' ') or (Src^ = #9) do
//       Inc(Src);
  end
  else
  begin
    bufEnd := strchr(Src, ' ');
  end;

  if bufEnd <> #0 then
    bufEnd := #0;

  strcpy(Dest, Src);

  if bufEnd <> #0 then
     Result := bufEnd + 1
  else
    Result := nil;
end;

function PrefixFromString(Value: PAnsiChar): TAsmPrefix;
begin
  if stricmp(Value, 'lock') = 0 then
    Result := TAsmPrefix.LOCK
  else if stricmp(Value, 'rep') = 0 then
    Result := TAsmPrefix.REP
  else if (stricmp(Value, 'repe') = 0) or (stricmp(Value, 'repz') = 0) then
    Result := TAsmPrefix.REP
  else if (stricmp(Value, 'repne') = 0) or (stricmp(Value, 'repnz') = 0) then
    Result := TAsmPrefix.REPNEZ
  else
    Result := TAsmPrefix.NONE;
end;

//class function TEnum<T>.ToEnum(const Value: string): T;
//var
//  P: ^T;
//  num: Integer;
//begin
//  try
//    num := GetEnumValue(TypeInfo(T), Value);
//    if num = -1 then
//      abort;
//
//    P := @num;
//    result := P^;
//  except
//    raise EConvertError.Create('O Parâmetro "' + Value + '" passado não ' +
//      sLineBreak + ' corresponde a um Tipo Enumerado ' + GetTypeName(TypeInfo(T)));
//  end;
//end;


function MnemonicFromString(Value: PAnsiChar): TAsmMnemonic;
var
  Index: Integer;
  Buffer: TAsmBuffer;
begin
  strcpy(Buffer, 'X86_' + Value);
  Index := GetEnumValue(TypeInfo(TAsmMnemonic), Buffer);
  Result := TAsmMnemonic(Ord(Index));
end;

function InstructionToTokens(Value: PAnsiChar; Tokens: TAsmParserTokensPtr): Integer;
var
  buf: TAsmBuffer;
  bufPtr: PAnsiChar;
  TokenIndex: Integer;
  i: Integer;
  Token: PAnsiChar;
  dest: TAsmBuffer;
begin
  // [PREFIX] INSTRUÇÃO [SEG]:[MEM/REG/IMM], [SEG]:[MEM/REG/IMM], [REG], [REG]

  dest := Default(TAsmBuffer);

  Result := 0;

  token := strtok(Value, ', ');
  strcpy(Tokens[0], token);

  // Passa por cada operando (use um máximo de 8 tokens)
  for TokenIndex := 1 to 7 do
  begin
    Token := strtok(nil, ', ');

    if (Token = nil) then
      Exit(TokenIndex);

    strcpy(Tokens[tokenIndex], token);
  end;

end;


function RegFromString(const Text: PAnsiChar): TAsmRegister;
var
  Index: Integer;
  Buffer: TAsmBuffer;
  i: Integer;
begin
  strcpy(Buffer, Text);

  i := 0;

  while (Buffer[i] <> #0) do
  begin
    Buffer[i] := toupper(Buffer[i]);
    inc(i);
  end;

  Index := GetEnumValue(TypeInfo(TAsmRegister), Buffer);

  if Index = -1 then
    Result := TAsmRegister.NONE
  else
    Result := TAsmRegister(Ord(Index));
end;

function RegGetSize(const Reg: TAsmRegister): TAsmOpSize;
begin
  Result := AsmRegisterTableDef[Reg].Size;
end;

function ConvertNumber(const Str: PAnsiChar; var Res: UInt64; Radix: Integer): Boolean;
var
  TheEnd: PAnsiChar;
begin
  _errno^ := 0;
  Res := strtoull(str, TheEnd, radix);

  if (Res <> 0) and (TheEnd = str) then
    Result := False
  else if (Res = High(UInt64)) and (_errno^ <> 0) then
    Result := False
  else if (TheEnd^ <> #0) then
    Result := False
  else
    Result := True;
end;


function ImmFromString(Text: PAnsiChar; var Value: UInt64): Boolean;
var
  negative: Boolean;
begin
  // Verifique se a string possui algum caractere real
  if Text[0] = #0 then
    Exit(False);

  // Defina a flag de negativo, se necessário
  negative := false;

  if (text[0] = '-') then
  begin
    negative := true;
    Inc(Text);
  end;

  // Hexadecimal com prefixo '0x'
  if(text[0] = '0') and (tolower(text[1]) = 'x') then
    Inc(Text);

  case tolower(text^) of
    'x': begin // Hexadecimal
         Inc(Text);
         if not convertNumber(text, value, 16) then    //entendi minha vida inteira agora com a base 16 que tive que usar, viver a vida inteira com a base 10 no dia a dia faz a gente achar e só existe ela rss
           Exit(false);
    end;
  end;

  if negative then
    Value := Value * -1;

  Result := True;
end;

function OpsizeFromValue(Value: Int64): TAsmOpSize;
var
  SetBitStart: UInt32;
  temp: UInt64;
  unsetBitStart: UInt32;
  mask: UInt64;
  i: Integer;
begin

    // Primeiro loop para obter o índice de bits mais significativo
    //
    // 00000000111111111111101010001111
    //         ^ Nós queremos esse índice
    setBitStart := 0;

    temp := Value;

    while true do
    begin
      temp := temp shr 1;

      if Temp = 0 then
        Break;


      Inc(setBitStart);
    end;

    unsetBitStart := 0;
    mask := $8000000000000000; //Máscara para valores negativos

    if ((Value and mask) <> 0 ) then
    begin
      // Obtém o índice da última repetição de 1 bit
      //
      // 00000000111111111111101010001111
      //                     ^ Queremos esse índice

      for i := setBitStart downto 0 do
      begin
        // Se não for zero, continue
        if((Value and (UInt64(1) shl i)) <> 0) then
            continue;

        // Break quando um zero é atingido (use o índice do 1 bit anterior)
        unsetBitStart := i + 1;
        break;
      end;
    end
    else
      unsetBitStart := setBitStart;

    // Converter o último bit definido em um valor de tamanho
    if(unsetBitStart < 8) then
        Result := TAsmOpSize.BYTE
    else if(unsetBitStart < 16)  then
        Result := TAsmOpSize.WORD
    else if(unsetBitStart < 32)  then
        Result := TAsmOpSize.DWORD
    else if(unsetBitStart < 64)  then
        Result := TAsmOpSize.QWORD
    else
        Result := TAsmOpSize.UNSET;
end;

function AnalyzeOperand(Instruction: TAsmInstructionPtr; const Value: PAnsiChar; var Operand: TAsmOperand): Boolean;
var
  RegisterValue: TAsmRegister;
  ImmValue: UInt64;
begin

  if (Value = nil) then
  begin
    // Operando Vazio
    Operand.Type_ := TAsmOperandType.INVALID;

//     strcpy(Instruction.error, 'Operando Vazio');
    Exit(false);
  end;

  RegisterValue := RegFromString(Value);
  ImmValue := 0;

  if(RegisterValue <> TAsmRegister.NONE) then
  begin
    // Register
    Operand.Type_       := TAsmOperandType.Reg;
//    Operand.Segment    = REG_INVALID;
    Operand.Size       := RegGetSize(RegisterValue);
//    Operand.XedEOSZ    = OpsizeToEosz(Operand.Size);
    Operand.Reg    := RegisterValue;
//    Operand.Reg.XedReg = RegToXed(registerVal);
  end
  else if (strchr(Value, '[') <> nil) and (strchr(Value, ']') <> nil) then
  begin
    // Memory

  end
  else if (strchr(Value, ':') <> nil) then
  begin
    // Segment selector
  end
  else if ImmFromString(Value, ImmValue) then
  begin
    // Immediate
    Operand.Type_      := TAsmOperandType.Imm;
//    Operand.Segment    :=  REG_INVALID;
    Operand.Size       := OpsizeFromValue(ImmValue);
    Operand.Imm.Signed := (Value[0] = '-');
    Operand.Imm.Value := ImmValue;

  end
  else
  begin
    // Unknown
    Operand.Type_ := TAsmOperandType.INVALID;
    //sprintf(Parse.error, 'Identificador de operando desconhecido '%s'', Value);
    Exit(false);
  end;

  Result := True;

end;

function AsmParseString(Instruction: TAsmInstructionPtr): Boolean;
var
  Tokens: TAsmParserTokens;
  TokenIndex: Integer;
  TokenCount: Integer;
  Buf: TAsmBuffer;
  i: Integer;
begin
  strcpy(buf, Instruction.Str);

  TokenIndex := 0;
  tokens := Default(TAsmParserTokens);
  TokenCount := InstructionToTokens(buf, @tokens);

  if(TokenCount <= 0) then
  begin
    // Instruções mal formadas ou inválidas
    Exit(False);
  end;

  // Prefix
  Instruction.Prefix := PrefixFromString(tokens[tokenIndex]);

  if not (Instruction.Prefix = TAsmPrefix.NONE) then
    Inc(tokenIndex);

  // Mnemonic
  Instruction.Mnemonic := MnemonicFromString(tokens[tokenIndex]);
  Inc(tokenIndex);


  // Operands
  for i := TokenIndex to TokenCount - 1  do
  begin
     if not (AnalyzeOperand(Instruction, tokens[i], Instruction.Operands[Instruction.OperandCount])) then
       Exit(False);

     Inc(Instruction.OperandCount);
  end;

  if(Instruction.OperandCount > 4) then
  begin
//        strcpy(Instruction.error, 'Instrução tem mais de 4 operandos');
        Exit(False);
  end;

 Result := True;

end;


end.
