unit UArrayList;

interface

uses SysUtils, SyncObjs, System.Classes, Windows;

const
  Max = 6;

type
  TArrayList = class
  Private
    Items: array [1 .. Max] of integer;
    Count: integer;
    Procedure _AddFirst(NewValue: integer);
    Function _AddAfter(NewValue: integer; SearchValue: integer): boolean;
    Function _AddBefore(NewValue: integer; SearchValue: integer): boolean;
    Function _Search(aName: integer): integer;
    Function _Delete(value: integer): boolean;
  Public
    Constructor Create();
    Function Search(aName: integer): integer;
    Procedure AddFirst(NewValue: integer);
    Function AddAfter(NewValue: integer; SearchValue: integer): boolean;
    Function AddBefore(NewValue: integer; SearchValue: integer): boolean;
    Function Delete(value: integer): boolean;
    Function GetCount: integer;
    Function GetItem(i: integer): integer;
  End;

implementation

var
  CritSec: TCriticalSection; // объект критической секции
  // переменные для хранения входных парамтеров в функцию добавления
  _NewItem: integer;
  _SearchItem: integer;

Constructor TArrayList.Create();
var
  i: integer;
begin
  Count := 0;
  for i := 1 to Max do
    Items[i] := -1;
end;

Function TArrayList.GetCount;
begin
  result := Count;
end;

Function TArrayList.GetItem(i: integer): integer;
begin
  result := Items[i];
end;

Function TArrayList._Search(aName: integer): integer;
var
  i: integer;
begin
  result := 0;
  for i := 1 to Count do
    if (aName = Items[i]) then
    begin
      result := i;
      break;
    end;
end;

Procedure TArrayList._AddFirst(NewValue: integer);
begin
  Items[1] := NewValue;
  Count := Count + 1;
end;

Function TArrayList._AddAfter(NewValue: integer; SearchValue: integer): boolean;
var
  i, j: integer;
begin
  result := False;
  if Count = 0 then
    Exit;
  if Count = Max then
    Exit;
  j := _Search(SearchValue);
  if j = 0 then
    Exit;
  Count := Count + 1;
  for i := Count downto j do
    Items[i + 1] := Items[i];
  Items[j + 1] := NewValue;
  result := True;
end;

Function TArrayList._AddBefore(NewValue: integer; SearchValue: integer)
  : boolean;
var
  i, j: integer;
begin
  result := False;
  if Count = 0 then
    Exit;
  if Count = Max then
    Exit;
  j := _Search(SearchValue);
  if j = 0 then
    Exit;
  Inc(Count);
  for i := Count downto j + 1 do
    Items[i] := Items[i - 1];
  Items[j] := NewValue;
  result := True;
end;

Function TArrayList._Delete(value: integer): boolean;
var
  i, j: integer;
begin
  result := False;
  if Count = 0 then
    Exit;
  j := _Search(value);
  if j = 0 then
    Exit;
  FreeAndNil(Items[j]);
  Count := Count - 1;
  for i := j to Count do
    Items[i] := Items[i + 1];
  result := True;
end;

end.
