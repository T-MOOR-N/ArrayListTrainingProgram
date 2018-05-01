unit UArrayList;

interface

uses SysUtils, SyncObjs, System.Classes, Windows;

const
  Max = 6;

type
  TListState = (lsNormal, lsAddbefore, lsAddAfter, lsDelete);
  TOperatingMode = (omControl, omNormal, omDemo);

  TArrayList = class
  Private
    Items: array [1 .. Max] of integer;
    Count: integer;
    FState: TListState;
    FThreadID: integer;
    FMode: TOperatingMode;

    // Поле ссылающееся на обработчик события MyEvent.
    // Тип TNotifyEvent описан в модуле Clases так: TNotifyEvent = procedure(Sender: TObject) of object;
    // Фраза  "of object" означает, что в качестве обработчика можно назначить только метод какого-либо
    // класса, а не произвольную процедуру.
    FOnThreadSuspended: TNotifyEvent;

    Procedure _AddFirst(NewValue: integer);
    Function _AddAfter(): boolean;
    Function _AddBefore(): boolean;
    Function _Search(aName: integer): integer;
    Function _Delete(): boolean;
    procedure Pause();
  Public
    Constructor Create();
    Procedure AddFirst(NewValue: integer);
    Function AddAfter(iNewValue: integer; iSearchValue: integer): boolean;
    Function AddBefore(iNewValue: integer; iSearchValue: integer): boolean;
    Function Delete(value: integer): boolean;
    Function GetCount: integer;
    Function GetItem(i: integer): integer;
    procedure NextStep();

    // Эта процедура проверяет задан ли обработчик события. И, если задан, запускает его.
    procedure DoMyEvent; dynamic;
    // Это свойство позволяет назначить обработчик для обработки события MyEvent.
    property OnThreadSyspended: TNotifyEvent read FOnThreadSuspended
      write FOnThreadSuspended;
    // Процедура, которая принимает решение - произошло событие MyEvent или нет.
    // Таких процедур может быть несколько - везде где может возникнуть событие MyEvent.
    // Если событие MyEvent произошло, то вызвается процедура DoMyEvent().
    procedure GenericMyEvent;

    property State: TListState read FState write FState;
    property ThreadID: integer read FThreadID write FThreadID;
    property Mode: TOperatingMode read FMode write FMode;

  End;

implementation

var
  CritSec: TCriticalSection; // объект критической секции
  // переменные для хранения входных парамтеров в функцию добавления
  NewItem: integer;
  SearchItem: integer;

{$REGION 'Public functions'}

Constructor TArrayList.Create();
var
  i: integer;
begin
  Count := 0;
  for i := 1 to Max do
    Items[i] := -1;
  CritSec := TCriticalSection.Create;
end;

Function TArrayList.GetCount;
begin
  result := Count;
end;

Function TArrayList.GetItem(i: integer): integer;
begin
  result := Items[i];
end;

{$ENDREGION}
{$REGION 'ThreadWrapper'}

function TArrayList.AddAfter(iNewValue: integer; iSearchValue: integer)
  : boolean;
var
  id: longword;
begin
  NewItem := iNewValue;
  SearchItem := iSearchValue;
  State := lsAddAfter;
  ThreadID := BeginThread(nil, 0, @TArrayList._AddAfter, Self, 0, id);
end;

function TArrayList.AddBefore(iNewValue: integer;
  iSearchValue: integer): boolean;
var
  id: longword;
begin
  NewItem := iNewValue;
  SearchItem := iSearchValue;
  State := lsAddbefore;
  ThreadID := BeginThread(nil, 0, @TArrayList._AddBefore, Self, 0, id);
end;

procedure TArrayList.AddFirst(NewValue: integer);
begin

end;

Function TArrayList.Delete(value: integer): boolean;
var
  id: longword;
begin
  State := lsDelete;
  SearchItem := value;
  ThreadID := BeginThread(nil, 0, @TArrayList._Delete, Self, 0, id);
end;

{$ENDREGION}
{$REGION 'Thread functions'}

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

Function TArrayList._AddAfter(): boolean;
var
  i, j: integer;
{$REGION 'вложенные функции для добавления'}
  procedure FuncEnd();
  begin
    State := lsNormal;
    // TLogger.DisableCouner;
    // TLogger.Log('');
    if Mode <> omNormal then
      GenericMyEvent;
    CritSec.Leave;
    EndThread(0);
    exit;
  end;
{$ENDREGION}

begin
  CritSec.Enter;

  result := false;
  if Count = 0 then
    exit;
  if Count = Max then
    exit;
  j := _Search(SearchItem);
  if j = 0 then
    exit;
  Count := Count + 1;
  for i := Count downto j do
    Items[i + 1] := Items[i];
  Items[j + 1] := NewItem;
  result := true;
end;

Function TArrayList._AddBefore(): boolean;
var
  i, j: integer;
begin
  result := false;
  if Count = 0 then
    exit;
  if Count = Max then
    exit;
  j := _Search(SearchItem);
  if j = 0 then
    exit;
  Inc(Count);
  for i := Count downto j + 1 do
    Items[i] := Items[i - 1];
  Items[j] := NewItem;
  result := true;
end;

Function TArrayList._Delete(): boolean;
var
  i, j: integer;
begin
  result := false;
  if Count = 0 then
    exit;
  j := _Search(SearchItem);
  if j = 0 then
    exit;
  FreeAndNil(Items[j]);
  Count := Count - 1;
  for i := j to Count do
    Items[i] := Items[i + 1];
  result := true;
end;

procedure TArrayList.Pause();
begin
  case Mode of
    omControl:
      begin
        GenericMyEvent;
        SuspendThread(ThreadID);
      end;
    omNormal:
      ;
    omDemo:
      begin
        GenericMyEvent;
        SuspendThread(ThreadID);
      end;
  end;
end;

procedure TArrayList.NextStep();
begin
  ResumeThread(ThreadID);
end;

{$ENDREGION}
{$REGION 'Event'}

procedure TArrayList.DoMyEvent;
begin
  // Если обработчик назначен, то запускаем его.
  if Assigned(FOnThreadSuspended) then
    FOnThreadSuspended(Self);
end;

procedure TArrayList.GenericMyEvent;
var
  MyEventIsOccurred: boolean;
begin
  MyEventIsOccurred := true;
  // Если верно некоторое условие, которое подтверждает, что событие MyEvent
  // произошло, то делаем попытку запустить связанный обработчик.
  if MyEventIsOccurred then
  begin
    DoMyEvent;
  end;
end;

{$ENDREGION}

end.
