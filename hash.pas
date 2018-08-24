unit hash;

interface

uses
  global,
  stdio,
  ctype,
  cstring;


function InsertIntoLabelTable(label_name: PAnsiChar; instruction_number: Integer): Boolean;
function Duplicate_variable_check(label_name: PAnsiChar): Boolean;
function HashCode(key: PAnsiChar; size: integer ): Integer;
procedure PrintErrorProcessingHashCode();
//function SearchInOpTable(key: PAnsiChar): TOpcodeItemPtr;
function InsertIntoSymbolTable(TokenPtr: TTokenPtr): Boolean;
procedure PrintErrorWithNullInputs();
function SearchInLabelTable(Key: PAnsiChar): TLabelItemPtr;
function SearchInSymbolTable(key: PAnsiChar): TTokenPtr;
function SearchInConstantSymbolTable(key: PAnsiChar): TConstantSymbolItemPtr;

implementation

uses
  AsmInstruction;

function InsertIntoSymbolTable(TokenPtr: TTokenPtr): Boolean;
var
  hashIndex: Integer;
  tItem: TTokenPtr;
begin
	if (main_symbol_table.HashTableCount < 0) or (TokenPtr = nil) or (TokenPtr^.Spelling = nil) then
	begin
		printErrorWithNullInputs();
		Exit(false);
	end;

  if TokenPtr.Kind = TTokenKind.VARIABLE_IDENTIFIER then
  begin
	  if (duplicate_variable_check(TokenPtr.Spelling)) then
		  Error('Nome de variavel duplicado: %s', TokenPtr.Spelling);
  end;

	hashIndex := HashCode(TokenPtr.Spelling, main_symbol_table.HashTableSize);
	if (hashIndex = -1) then
	begin
		printErrorProcessingHashCode();
		Exit(false);
	end;

	if not (main_symbol_table.Items[hashIndex] = nil) then
  begin
		tItem := main_symbol_table.Items[hashIndex];
		if (stricmp(tItem^.Spelling, TokenPtr.Spelling) = 0) then
		begin
			TokenPtr^.next := main_symbol_table.Items[hashIndex]^.next;
			main_symbol_table.Items[hashIndex] := TokenPtr;
			Inc(main_symbol_table.HashTableCount);
			Exit(true);
		end;

		while not (tItem^.next = nil) do
			tItem := tItem^.next;

		tItem^.next := TokenPtr;
		Inc(main_symbol_table.HashTableCount);
		Exit(true);
	end;

	main_symbol_table.Items[hashIndex] := TokenPtr;
	Inc(main_symbol_table.HashTableCount);
	Exit(true);
end;

procedure PrintErrorWithNullInputs();
begin
	//printf('No Records'#10);
end;

//function searchInOpTable(key: PAnsichar): TOpcodeItemPtr;
//var
//  hashIndex: integer;
//  item: TOpcodeItemPtr;
//begin
//
//	if (main_op_table.hashTableCount < 1) or (key = nil) then
//	begin
//		printErrorWithNullInputs();
//		Exit(nil);
//	end;
//
//	hashIndex := hashCode(key, main_op_table.hashTableSize);
//	if (hashIndex = -1) then
//	begin
//		printErrorProcessingHashCode();
//		Exit(nil);
//	end;
//
//	item := main_op_table.item[hashIndex];
//	while not (item = nil) do
//  begin
//		if (strcmp(item^.name, key) = 0) then
//			Exit(item);
//
//		item := item^.next;
//	end;
//
//	Result := nil;
//end;


function SumOfChars(Str: PAnsiChar): Integer;
var
  i,
  len,
  sum: Integer;
begin
	len := strlen(str);
	sum := 0;

	for i := 0 to len - 1 do
	  sum := sum + Ord(tolower(str[i]));

	Result := sum;
end;

procedure printErrorProcessingHashCode();
begin
  Error(#10'Erro ao gerar código hash'#10);
end;


// // retorna -1 se a entrada nil for dada else retorna o hashCode gerado com chave e tamanho
function HashCode(key: PAnsiChar; size: integer ): Integer;
begin
	if (key = nil) then
		Result := -1
  else
  begin
  	Result := SumOfChars(key) mod size;
  end;
end;
{
function InsertIntoOpTable(Name: PAnsiChar; Code: Integer): Boolean;
var
  item: TOpcodeItemPtr;
  HashIndex: Integer;
  tItem: TOpcodeItemPtr;
begin
	if (main_op_table.hashTableCount < 0) or (Name = nil) then
	begin
		PrintErrorWithNullInputs();
		Exit(False);
	end;

  item := AllocMem(SizeOf(TOpcodeItem));
	strcpy(item^.Name, Name);
	Item^.Code := Code;
	Item^.Next := nil;

  HashIndex := HashCode(Name, main_op_table.hashTableSize);

	if (hashIndex = -1) then
	begin
		printErrorProcessingHashCode();
		Exit(false);
	end;

	if not (main_op_table.item[hashIndex] = nil) then
  begin
		tItem := main_op_table.item[hashIndex];
		if (strcmp(tItem^.Name, Name) = 0) then
		begin
			item^.Next := main_op_table.item[hashIndex]^.Next;
			main_op_table.item[hashIndex] := item;
			Inc(main_op_table.hashTableCount);
			Exit(True);
		end;

		while not (tItem^.next = nil) do
			tItem := tItem^.Next;

		tItem^.Next := item;
		Inc(main_op_table.hashTableCount);
		Exit(True);
	end;

	main_op_table.item[hashIndex] := item;
  Inc(main_op_table.hashTableCount);
	Exit(True);
end;
}
function SearchInLabelTable(Key: PAnsiChar): TLabelItemPtr;
var
  HashIndex: Integer;
  item: TLabelItemPtr;
begin
	if (main_label_table.count < 1) or (key = nil) then
	begin
		PrintErrorWithNullInputs();
		Exit(nil);
	end;

	HashIndex := HashCode(key, main_label_table.size);
	if (hashIndex = -1) then
	begin
		PrintErrorProcessingHashCode();
		Exit(nil);
	end;

	item := main_label_table.item[hashIndex];
	while not (item = nil) do
  begin
		if (stricmp(item^.Name, key) = 0) then
			Exit(item);

		item := item^.next;
	end;

	Result := nil;
end;

function SearchInSymbolTable(key: PAnsiChar): TTokenPtr;
var
  hashIndex: integer;
  item: TTokenPtr;
begin

	if (main_symbol_table.HashTableCount < 1) or (key = nil) then
	begin
		PrintErrorWithNullInputs();
		Exit(nil);
	end;

	hashIndex := HashCode(key, main_symbol_table.HashTableSize);
	if (hashIndex = -1) then
	begin
		PrintErrorProcessingHashCode();
		Exit(nil);
	end;

	item := main_symbol_table.Items[hashIndex];
	while not (item = nil) do
  begin
		if (stricmp(item^.Spelling, key) = 0) then
			Exit(item);

		item := item^.next;
	end;

  Result := nil;
end;


function SearchInConstantSymbolTable(key: PAnsiChar): TConstantSymbolItemPtr;
var
  hashIndex: Integer;
  item: TConstantSymbolItemPtr;
begin

	if (main_constant_symbol_table.count < 1) or (key = nil) then
	begin
		PrintErrorWithNullInputs();
		Exit(nil);
	end;

	hashIndex := HashCode(key, main_constant_symbol_table.size);
	if (hashIndex = -1) then
	begin
		printErrorProcessingHashCode();
		Exit(nil);
	end;

	item := main_constant_symbol_table.item[hashIndex];
	while not (item = nil) do
  begin
		if (stricmp(item^.Name, key) = 0) then
			Exit(item);

		item := item^.next;
	end;
	Result := nil;
end;

{
function searchInOpTable(key: PAnsiChar): TOpcodeItemPtr;
var
  hashIndex: Integer;
  item: TOpcodeItemPtr;
begin

	if (main_op_table.hashTableCount < 1) or (key = nil) then
	begin
		printErrorWithNullInputs();
		Exit(nil);
	end;

	hashIndex := hashCode(key, main_op_table.hashTableSize);
	if (hashIndex = -1) then
	begin
		printErrorProcessingHashCode();
		Exit(nil);
	end;

	item := main_op_table.item[hashIndex];
	while not (item = nil) do
  begin
		if (strcmp(item^.name, key) = 0) then
			Exit(item);

		item := item^.next;
	end;
	Result := nil;
end;
}
function duplicate_variable_check(label_name: PAnsiChar): Boolean;
var
  item: TLabelItemPtr;
  symbl_item: TTokenPtr;
  const_item: TConstantSymbolItemPtr;
//  op_code_item: TOpcodeItemPtr;
begin
	item := searchInLabelTable(label_name);
	symbl_item := searchInSymbolTable(label_name);
	const_item := searchInConstantSymbolTable(label_name);
//	op_code_item := searchInOpTable(label_name);
	if (item <> nil) or (symbl_item <> nil) or (const_item <> nil) {or (op_code_item <> nil)} then
	begin
		printf('palavra duplicada : %s'#10, label_name);
		Result := True;
	end
  else
  	Result := False;
end;

function InsertIntoLabelTable(label_name: PAnsiChar; instruction_number: Integer): Boolean;
var
  item: TLabelItemPtr;
  hashIndex: integer;
  tItem:  TLabelItemPtr;
begin
	if (main_label_table.count < 0) or (label_name = nil) then
	begin
		PrintErrorWithNullInputs();
		Exit(False);
	end;

	if (duplicate_variable_check(label_name)) then
		Exit(false);

	item := AllocMem(SizeOf(TLabelItem));
	item^.Name := AllocMem(SizeOf(AnsiChar) * (strlen(label_name) + 1));
	strcpy(item^.Name, label_name);
	item^.instruction_number := instruction_number;
	item^.next := nil;
	hashIndex := hashCode(label_name, main_label_table.size);
	if (hashIndex = -1) then
	begin
		PrintErrorProcessingHashCode();
		Exit(false);
	end;

	if not (main_label_table.item[hashIndex] = nil) then
  begin
		tItem := main_label_table.item[hashIndex];
		if (stricmp(tItem^.Name, label_name) = 0) then
		begin
			item^.next := main_label_table.item[hashIndex]^.next;
			main_label_table.item[hashIndex] := item;
			Inc(main_label_table.count);
			Exit(true);
		end;

		while not (tItem^.next = nil) do
			tItem := tItem^.next;

		tItem^.next := item;
		Inc(main_label_table.count);
		Exit(true);
	end;

	main_label_table.item[hashIndex] := item;
	Inc(main_label_table.count);
	Result := true;
end;

end.
