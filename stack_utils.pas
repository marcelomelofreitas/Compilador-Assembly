unit stack_utils;

interface

uses
  stdio,
  global;

function CreateStack(Capacity: UInt32): TStackPtr;
procedure push(stack: TStackPtr; item: Integer);
function pop(stack: TStackPtr): Integer;

implementation

// Stack is full when top is equal to the last index
function isFull(stack: TStackPtr): Boolean;
begin
	Result := stack^.top = stack^.capacity - 1;
end;


// Function to add an item to stack.  It increases top by 1
procedure push(stack: TStackPtr; item: Integer);
begin
	if (isFull(stack)) then
		Exit;

  Inc(stack^.Top);

	stack^.Array_[stack^.Top] := item;
	printf('%d pushed to stack'#10, item);
end;

// Stack is empty when top is equal to -1
function isEmpty(stack: TStackPtr): Boolean;
begin
	Result := stack^.Top = -1;
end;

// Function to remove an item from stack.  It decreases top by 1
function pop(stack: TStackPtr): Integer;
begin
	if (isEmpty(stack)) then
		Exit(INT_MIN);

	Result := stack^.array_[stack^.top];
  Dec(stack^.top);
end;

// cria uma pilha com a capacidade solicitada e inicializa o tamanho da pilha como 0
function CreateStack(Capacity: UInt32): TStackPtr;
begin
	Result := AllocMem(SizeOf(TStack));
	Result^.Capacity := capacity;
	Result^.Top := -1;
	SetLength(Result^.Array_, Result^.Capacity);
end;

end.
