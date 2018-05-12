unit UArrayListOrdered;

interface

uses SysUtils;

const
  Max = 6;

type
  TArrayListOrdered = class
  Private
    Count: integer;
  Public
    Items: array [1 .. Max] of integer;

    Constructor Create(aName: string);
    Function GetCount: integer;
    Function Search(value: integer): integer;
    Function Add(value: integer): boolean;
    Function Delete(value: integer): boolean;
  End;

implementation

Constructor TArrayListOrdered.Create(aName: string);
var
  i: integer;
begin
  Count := 0;
  for i := 1 to Max do
    Items[i] := -1;
end;

Function TArrayListOrdered.GetCount;
begin
  result := Count;
end;

Function TArrayListOrdered.Search(value: integer): integer;
var
  i: integer;
begin
  result := 0;
  for i := 1 to Count do
    if (value = Items[i]) then
    begin
      result := i;
      break;
    end;
end;

Function TArrayListOrdered.Add(value: integer): boolean;
var
  i, j: integer;
begin
  result := False;
  if Count <> Max then
  begin
    if Count = 0 then
      // добавление первого
      Items[1] := value
    else
    begin
      // поиск места вставки
      for i := 1 to Count do
        if value < Items[i] then
          break;
      // свдиг ячеек массива
      for j := Count + 1 downto i + 1 do
      begin
        Items[j] := Items[j - 1];
        Items[j - 1] := -1;
      end;
      Items[i] := value;
    end;
    inc(Count);
    result := true;
  end;
end;

Function TArrayListOrdered.Delete(value: integer): boolean;
var
  i, j: integer;
begin
  result := False;
  if Count = 0 then
    Exit;
  j := Search(value);
  if j = 0 then
    Exit;
  FreeAndNil(Items[j]);
  Count := Count - 1;
  for i := j to Count do
    Items[i] := Items[i + 1];
  result := true;
end;

end.
