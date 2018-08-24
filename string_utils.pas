unit string_utils;

interface

procedure Trim(str: PAnsiChar);
function sub_string(str: PAnsiChar; start_index, end_index: Integer): PAnsiChar;
function splitString(input: PAnsiChar; const delimter: PAnsiChar; count: PInteger): TArray<PAnsiChar>;

implementation

uses
  cstring,
  stdio,
  ctype;

function splitString(input: PAnsiChar; const delimter: PAnsiChar; count: PInteger): TArray<PAnsiChar>;
var
  i: Integer;
  token: PAnsiChar;
begin
  SetLength(Result, 20);
	for i := Low(Result) to High(Result) do
		Result[i] := AllocMem(sizeof(AnsiChar) * 20);

	token := strtok(input, delimter);
	i := 0;
	while not (token = nil) do
	begin
		sprintf(result[i], '%s', token);
    inc(i);
		token := strtok(nil, delimter);
	end;

	count^ := i;
end;


function sub_string(str: PAnsiChar; start_index, end_index: Integer): PAnsiChar;
var
  sub_str: PAnsiChar;
  sub_str_index: Integer;
begin
	if (end_index >= start_index) then
  begin
		sub_str := AllocMem(sizeof(Ansichar) * (end_index - start_index) + 2);
		sub_str_index := 0;
		while (start_index <= end_index) do
		begin
			sub_str[sub_str_index] := str[start_index];
      Inc(sub_str_index);
      Inc(start_index);
		end;
		sub_str[sub_str_index] := #0;
		Exit(sub_str);
	end;
	Result := nil;
end;

procedure Trim(str: PAnsiChar);
var
	output_index, start, end_: Integer;
  len: Integer;
begin
	output_index := 0;
  start := 0;

  while isspace(str[start]) do
    inc(start);

	len := strlen(str);
	for end_ := len - 1 downto 0 do
	begin
		if not isspace(str[end_]) and not (str[end_] = #10) then
			break;
	end;

	while start <= end_ do
  begin
		str[output_index] := str[start];
    inc(output_index);
    inc(start);
	end;

	str[output_index] := #0;
end;

end.
