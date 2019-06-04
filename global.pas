unit global;


interface

uses
  AsmInstruction;

type

  // Nível de erro
  TErrorLevel = (LEVEL_WARNING,	LEVEL_ERROR);

  // Estágio de trabalho
  TWorkStage = (STAGE_COMPILE, STAGE_LINK);

  //*Structure of Opcode table*/

//  TOpcodeItemPtr = ^TOpcodeItem;
//  TOpcodeItem = record
//  	Name: array[0..49] of AnsiChar;
//  	Code: Integer;
//  	Next: TOpcodeItemPtr;
//  end;


//   TOpcodeTable = record
//	   Item: array of TOpcodeItemPtr;
//	   HashTableCount: Integer;
//	   HashTableSize: Integer;
//   end;


  TTokenKind = (
	  INVALID,
    VAR_STATEMENT,
    CONST_STATEMENT,
    ASM_REGISTER,
    ASM_MNEMONIC,
    LABEL_IDENTIFIER,

    BYTE,
    WORD_SIZE,
    VAR_DWORD_SIZE,
    VAR_FWORD_SIZE,
    VAR_QWORD_SIZE,
    VAR_TBYTE_SIZE,
    VAR_DQWORD_SIZE,
    VAR_XMMWORD_SIZE,
    VAR_YMMWORD_SIZE,
    VAR_ZMMWORD_SIZE,

    VAR_IDENTIFIER,
    SPECIAL_SYMBOL,
    CONST_IDENTIFIER
  );


//* End of structure of opcode table */
//* Structure of Symbol Table*/
  TTokenPtr = ^TToken;
  TToken = record
    Spelling: PAnsiChar;
    Kind: TTokenKind;
    Address: Integer;
    Size: TAsmOperandSize;
    Reg: TAsmRegister;
    Mnemonic: TAsmMnemonic;
    Next: TTokenPtr;
  end;

  TSymbolTable = record
    Items: array of TTokenPtr;
    HashTableCount: Integer;
    HashTableSize: Integer;
  end;

//* End of structure of symbol table */
//  TInstructionPtr = ^TInstruction;
//  TInstruction = record
//  	Opcode: Integer;
//	  Parameters: Array of Integer;
//  	ParamCount: integer;
//  end;


  TIntermediateTable = record
    Item: array of TAsmInstructionPtr;
    Count: integer;
    Size: integer;
  end;

  TLabelItemPtr = ^TLabelItem;
  TLabelItem = record
    Name: PAnsiChar;
    Instruction_number: Integer;
    Next: TLabelItemPtr;
  end;

  TLabelTable = record
  	Item: array of TLabelItemPtr;
	  Count: Integer;
  	Size: Integer;
  end;

  TConstantSymbolItemPtr = ^TConstantSymbolItem;
  TConstantSymbolItem = record
  	Name: PAnsiChar;
 	  StartAddress: Integer;
	  Size: Integer;
	  Next: TConstantSymbolItemPtr;
  end;

  TConstantSymbolTable = record
  	Item: array of TConstantSymbolItemPtr;
	  Count: Integer;
  	Size: Integer;
  end;

  TStackPtr = ^TStack;
  TStack = record
    Top: integer;
    Capacity: Integer;
    Array_: array of Integer;
  end;

procedure HandleException(Stage: TWorkStage; Level: TErrorLevel; Fmt: PAnsiChar; VarArgList: TVarArgList);
procedure Error(fmt: PAnsiChar); varargs;

const
  MEMORY_SIZE = 1000;
  INT_MIN     = (-2147483647 - 1); // minimum (signed) int value

var
//  main_op_table: TOpcodeTable;
  main_symbol_table: TSymbolTable;
  main_intermediate_table: TIntermediateTable;
  main_label_table: TLabelTable;
  main_constant_symbol_table: TConstantSymbolTable;

  CurrentFileName: PAnsiChar;         // Nome do arquivo fonte
  line_num: integer;           // Número da linha

  registers: array[0..7] of Integer;
  memory_blocks: array[0..MEMORY_SIZE-1] of Integer;
  constant_memory_blocks: array[0..MEMORY_SIZE-1] of AnsiChar;

implementation

uses
  stdio,
  cstring,
  stdlib;

(***********************************************************
 * Função: Manipulação de exceção
 * Stage: fase de compilação ou fase de link
 * Level: nível de erro
 * Fmt: formato da saída do parâmetro
 * VarArgList: lista de parâmetros variáveis
 **********************************************************)
procedure HandleException(Stage: TWorkStage; Level: TErrorLevel; Fmt: PAnsiChar; VarArgList: TVarArgList);
var
  buf: array[0..1023] of AnsiChar;
begin
	vsprintf(buf, fmt, VarArgList);
	if (Stage = TWorkStage.STAGE_COMPILE) then
  begin
		if (level = TErrorLevel.LEVEL_WARNING) then
			printf('%s(Linha %d) : Aviso de compilacao: %s!\n', CurrentFileName, line_num, buf)
		else
    begin
			printf('%s(Linha %d) : Erro de compilacao: %s!'#10, CurrentFileName, line_num, buf);
			_exit(-1);
		end;
	end
	else
  begin
		printf('Erro de link: %s!'#10, buf);
		_exit(-1);
	end;
end;

(***********************************************************
 * Função: Compile o tratamento de erros fatais
 * fmt : formato da saída do parâmetro
 **********************************************************)
procedure Error(fmt: PAnsiChar); varargs;
var
  VarArgList: TVarArgList;
begin
  VarArgStart(VarArgList);
	HandleException(TWorkStage.STAGE_COMPILE, TErrorLevel.LEVEL_ERROR, fmt, VarArgList);
  VarArgEnd(VarArgList);
end;

end.
