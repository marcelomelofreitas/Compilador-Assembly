unit grammar;

interface

uses
  stdlib,
  stdio,
  Global,
  AsmInstruction,
  cstring,
  memory_utils,
  hash;

const
  Keywords: array[0..10] of TToken = (
		(Spelling: 'var'; Kind: TTokenKind.VAR_STATEMENT; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.NONE; Mnemonic: TAsmMnemonic.X86_INVALID; Next: nil),
		(Spelling: 'const'; Kind: TTokenKind.CONST_STATEMENT; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.NONE; Mnemonic: TAsmMnemonic.X86_INVALID; Next: nil),
		(Spelling: 'mov'; Kind: TTokenKind.ASM_MNEMONIC; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.NONE; Mnemonic: TAsmMnemonic.X86_MOV; Next: nil),
		(Spelling: 'add'; Kind: TTokenKind.ASM_MNEMONIC; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.NONE; Mnemonic: TAsmMnemonic.X86_ADD; Next: nil),
		(Spelling: 'sub'; Kind: TTokenKind.ASM_MNEMONIC; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.NONE; Mnemonic: TAsmMnemonic.X86_SUB; Next: nil),
		(Spelling: 'mul'; Kind: TTokenKind.ASM_MNEMONIC; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.NONE; Mnemonic: TAsmMnemonic.X86_MUL; Next: nil),
		(Spelling: 'jp'; Kind: TTokenKind.ASM_MNEMONIC; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.NONE; Mnemonic: TAsmMnemonic.X86_JP; Next: nil),
		(Spelling: 'eax'; Kind: TTokenKind.ASM_REGISTER; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.EAX; Mnemonic: TAsmMnemonic.X86_INVALID; Next: nil),
		(Spelling: 'ebx'; Kind: TTokenKind.ASM_REGISTER; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.EBX; Mnemonic: TAsmMnemonic.X86_INVALID; Next: nil),
		(Spelling: 'ecx'; Kind: TTokenKind.ASM_REGISTER; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.ECX; Mnemonic: TAsmMnemonic.X86_INVALID; Next: nil),
		(Spelling: 'edx'; Kind: TTokenKind.ASM_REGISTER; Address: 0; Size: TAsmOperandSize.UNSET; Reg: TAsmRegister.EDX; Mnemonic: TAsmMnemonic.X86_INVALID; Next: nil)
  );

procedure initializeKeywords();
procedure Expect(msg: PAnsiChar);


implementation


procedure initializeKeywords();
var
  iter: Integer;
  TokenPtr: TTokenPtr;
begin

	for iter := Low(Keywords) to  High(Keywords) do
  begin
    TokenPtr := @Keywords[iter];
		InsertIntoSymbolTable(TokenPtr);
  end;

end;

(*****************************************************************
 * Função: Erro rápido, falta um certo componente de sintaxe aqui
 * msg : Quais componentes gramaticais são necessários
 ************************************************** **************)
procedure Expect(msg: PAnsiChar);
begin
  Error('Faltando %s', msg);
end;


end.
