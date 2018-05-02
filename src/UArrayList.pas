unit UArrayList;

interface

uses SysUtils, SyncObjs, System.Classes, Windows;

const
  Max = 6;

type
  TListState = (lsNormal, lsAddFirst, lsAddbefore, lsAddAfter, lsDelete);
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

    Procedure _AddFirst();
    Procedure _AddAfter();
    Procedure _AddBefore();
    Function _Search(aName: integer): integer;
    Procedure _Delete();
    procedure Pause();
    procedure Finish();
  Public
    ThreadId: integer;

    Constructor Create();
    Procedure AddFirst(iNewValue: integer);
    Function AddAfter(iNewValue: integer; iSearchValue: integer): boolean;
    Function AddBefore(iNewValue: integer; iSearchValue: integer): boolean;
    Function Delete(value: integer): boolean;
    Function GetCount: integer;
    Function GetMaxCount: integer;
    Function GetItem(index: integer): string;
    procedure NextStep();

    // Эта процедура проверяет задан ли обработчик события. И, если задан, запускает его.
    procedure DoMyEvent; // dynamic;
    // Это свойство позволяет назначить обработчик для обработки события MyEvent.
    property OnThreadSyspended: TNotifyEvent read FOnThreadSuspended
      write FOnThreadSuspended;
    // Процедура, которая принимает решение - произошло событие MyEvent или нет.
    // Таких процедур может быть несколько - везде где может возникнуть событие MyEvent.
    // Если событие MyEvent произошло, то вызвается процедура DoMyEvent().
    procedure GenericMyEvent;

    property State: TListState read FState write FState;
    // property ThreadID: integer read FThreadID write FThreadID;
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
  i, j: integer;
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

Function TArrayList.GetItem(index: integer): string;
begin
  if Items[index] = -1 then
    result := ''
  else
    result := IntToStr(Items[index]);
end;

Function TArrayList.GetMaxCount;
begin
  result := Max;
end;

{$REGION 'ThreadWrapper'}

procedure TArrayList.AddFirst(iNewValue: integer);
var
  id: longword;
begin
  State := lsAddFirst;
  NewItem := iNewValue;
  ThreadId := BeginThread(nil, 0, @TArrayList._AddFirst, Self, 0, id);
end;

function TArrayList.AddAfter(iNewValue: integer; iSearchValue: integer)
  : boolean;

var
  id: longword;
begin
  NewItem := iNewValue;
  SearchItem := iSearchValue;
  State := lsAddAfter;
  ThreadId := BeginThread(nil, 0, @TArrayList._AddAfter, Self, 0, id);
end;

function TArrayList.AddBefore(iNewValue: integer;
  iSearchValue: integer): boolean;
var
  id: longword;
begin
  NewItem := iNewValue;
  SearchItem := iSearchValue;
  State := lsAddbefore;
  ThreadId := BeginThread(nil, 0, @TArrayList._AddBefore, Self, 0, id);
end;

Function TArrayList.Delete(value: integer): boolean;
var
  id: longword;
begin
  State := lsDelete;
  SearchItem := value;
  ThreadId := BeginThread(nil, 0, @TArrayList._Delete, Self, 0, id);
end;

{$ENDREGION}
{$ENDREGION}
{$REGION 'Thread functions'}

Procedure TArrayList._AddFirst();
begin
  CritSec.Enter;
  if Count = 0 then
  begin
    Items[1] := NewItem;
    Inc(Count);
  end;
  Finish();
end;

Procedure TArrayList._AddAfter();
var
  i, j: integer;
begin
  CritSec.Enter;

  if Count = 0 then
    Finish();
  if Count = Max then
    Finish();
  j := _Search(SearchItem);
  if j = 0 then
    Finish();
  Inc(Count);
  for i := Count downto j do
    Items[i + 1] := Items[i];
  Items[j + 1] := NewItem;

  Finish();
end;

procedure TArrayList._AddBefore();
var
  i, j: integer;
begin
  CritSec.Enter;

  if Count = 0 then
    Finish();
  if Count = Max then
    Finish();
  j := _Search(SearchItem);
  if j = 0 then
    Finish();
  Inc(Count);
  for i := Count downto j + 1 do
    Items[i] := Items[i - 1];

  Items[j] := NewItem;
  Finish();
end;

procedure TArrayList._Delete();
var
  i, j: integer;
begin
  if Count = 0 then
    Finish();
  j := _Search(SearchItem);
  if j = 0 then
    Finish();
  FreeAndNil(Items[j]);
  Count := Count - 1;
  for i := j to Count do
    Items[i] := Items[i + 1];
  Finish();
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

procedure TArrayList.Finish();
begin
  State := lsNormal;
  GenericMyEvent;
  CritSec.Leave;
  EndThread(0);
  exit;
end;

procedure TArrayList.Pause();
begin
  case Mode of
    omControl:
      begin
        GenericMyEvent;
        SuspendThread(ThreadId);
      end;
    omNormal:
      ;
    omDemo:
      begin
        GenericMyEvent;
        SuspendThread(ThreadId);
      end;
  end;
end;

procedure TArrayList.NextStep();
begin
  ResumeThread(ThreadId);
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
  MyEventIsOccurred := True;
  // Если верно некоторое условие, которое подтверждает, что событие MyEvent
  // произошло, то делаем попытку запустить связанный обработчик.
  if MyEventIsOccurred then
  begin
    DoMyEvent;
  end;
end;

{$ENDREGION}

end.
