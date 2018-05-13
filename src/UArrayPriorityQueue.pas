unit UArrayPriorityQueue;

interface

uses SysUtils, UPriorityQueueItem;

const
  Max = 6;

type
  TArrayPriorityQueue = class
  Private
    Count: integer;
  Public
    Items: array [1 .. Max] of TPriorityQueueItem;

    Constructor Create();
    Function GetCount: integer;
    Function Add(value: TPriorityQueueItem): boolean;
    Function Delete(): boolean;
  End;

implementation

Constructor TArrayPriorityQueue.Create();
var
  i: integer;
begin
  Count := 0;
  for i := 1 to Max do
    Items[i] := nil
end;

Function TArrayPriorityQueue.GetCount;
begin
  result := Count;
end;

Function TArrayPriorityQueue.Add(value: TPriorityQueueItem): boolean;
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
        if Items[i].GetPriority >= value.GetPriority then
          break;
      // свдиг ячеек массива
      for j := Count + 1 downto i + 1 do
      begin
        Items[j] := Items[j - 1];
        Items[j - 1] := nil;
      end;
      Items[i] := value;
    end;
    inc(Count);
    result := true;
  end;
end;

Function TArrayPriorityQueue.Delete(): boolean;
begin
  result := False;
  if Count = 0 then
    Exit;
  FreeAndNil(Items[Count]);
  Dec(Count);
  result := true;
end;

end.
