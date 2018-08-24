unit memory_utils;

interface

uses
  global;

//procedure AllocateOpcodeTable();
procedure initializeSymboltable();
procedure initialize_instruction_table();
procedure initialize_label_table();
procedure initialize_constant_symboltable();

implementation

procedure initialize_constant_symboltable();
var
  i: Integer;
begin
	SetLength(main_constant_symbol_table.Item, 100);
	main_constant_symbol_table.count := 0;
	main_constant_symbol_table.size := 100;

	for i := Low(main_constant_symbol_table.item) to High(main_constant_symbol_table.item) do
		main_constant_symbol_table.item[i] := nil;
end;


procedure initialize_instruction_table();
begin
	SetLength(main_intermediate_table.Item, 10000);
	main_intermediate_table.Count := 0;
	main_intermediate_table.Size := 10000;
end;

procedure initialize_label_table();
var
  i: Integer;
begin;
	SetLength(main_label_table.Item, 100);
	main_label_table.Count := 0;
	main_label_table.Size := 100;

	for i := Low(main_label_table.item) to High(main_label_table.item) do
		main_label_table.item[i] := nil;
end;

{
procedure AllocateOpcodeTable();
var
  i: Integer;
begin
	SetLength(main_op_table.item, 100);
	main_op_table.hashTableCount := 0;
	main_op_table.hashTableSize := Length(main_op_table.item);

	for i := Low(main_op_table.item) to High(main_op_table.item) do
		main_op_table.item[i] := nil;
end;
}
procedure initializeSymboltable();
var
  i: Integer;
begin


	SetLength(main_symbol_table.Items, 10000);
	main_symbol_table.HashTableCount := 0;
	main_symbol_table.HashTableSize := 10000;

	for i := Low(main_symbol_table.Items) to High(main_symbol_table.Items) do
		main_symbol_table.Items[i] := nil;

end;


end.
