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

    Procedure AddFirstTask();
    Procedure AddAfterTask();
    Procedure AddBeforeTask();
    Function _Search(aName: integer): integer;
    Procedure DeleteTask();
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

uses
  UMain;

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
  ThreadId := BeginThread(nil, 0, @TArrayList.AddFirstTask, Self, 0, id);
end;

function TArrayList.AddAfter(iNewValue: integer; iSearchValue: integer)
  : boolean;

var
  id: longword;
begin
  NewItem := iNewValue;
  SearchItem := iSearchValue;
  State := lsAddAfter;
  ThreadId := BeginThread(nil, 0, @TArrayList.AddAfterTask, Self, 0, id);
end;

function TArrayList.AddBefore(iNewValue: integer;
  iSearchValue: integer): boolean;
var
  id: longword;
begin
  NewItem := iNewValue;
  SearchItem := iSearchValue;
  State := lsAddbefore;
  ThreadId := BeginThread(nil, 0, @TArrayList.AddBeforeTask, Self, 0, id);
end;

Function TArrayList.Delete(value: integer): boolean;
var
  id: longword;
begin
  State := lsDelete;
  SearchItem := value;
  ThreadId := BeginThread(nil, 0, @TArrayList.DeleteTask, Self, 0, id);
end;

{$ENDREGION}
{$ENDREGION}
{$REGION 'Task functions'}

Procedure TArrayList.AddFirstTask();
begin
  CritSec.Enter;
  if Count = 0 then
  begin
    Form1.Memo1.Lines.Add('Добавление в список первого элемента ' +
      IntToStr(NewItem) + ' (COUNT = ' + Count.ToString + ')');
    Pause();

    Form1.Memo1.Lines.Add('1) Вставка: заносим значение ' + NewItem.ToString +
      ' в ячейку [1];');
    Items[1] := NewItem;
    Pause();

    Form1.Memo1.Lines.Add('2) Увеличение COUNT на 1:' + ' COUNT = ' +
      Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
    Inc(Count);
  end;
  Finish();
end;

Procedure TArrayList.AddAfterTask();
var
  i, j: integer;
begin
  CritSec.Enter;

  Form1.Memo1.Lines.Add('Вставка в список элемента  ' + NewItem.ToString +
    ' после ' + SearchItem.ToString + ' (COUNT = ' + Count.ToString + ')');
  Pause();

  if Count = 0 then
    Finish();
  if Count = Max then
  begin
    Form1.Memo1.Lines.Add('1) Проверка возможности вставки: Список заполнен;');
    Finish();
  end;

  Form1.Memo1.Lines.Add('1) Проверка возможности вставки: ОК;');
  Pause();

  j := _Search(SearchItem);
  if j = 0 then
    Finish();
  Inc(Count);

  Form1.Memo1.Lines.Add
    ('Х) Сдвиг ячеек вправо: перемещаем вправо содержимое ячеек начиная с ячейки ['
    + (Count - 1).ToString + '];');
  Pause();

  for i := Count downto j do
  begin
    Items[i + 1] := Items[i];

    Form1.Memo1.Lines.Add
      ('Х) Сдвиг текущей вправо: перемещаем содержимое ячейки [' + i.ToString +
      '] в ячейку [' + (i + 1).ToString + '];');
    Pause();
  end;

  Items[j + 1] := NewItem;
  Form1.Memo1.Lines.Add('Х) Вставка: заносим значение ' + NewItem.ToString +
    ' в ячейку [' + j.ToString + '];');
  Pause();

  Form1.Memo1.Lines.Add('2) Увеличение COUNT на 1:' + ' COUNT = ' +
    Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
  // Inc(Count);

  Finish();
end;

procedure TArrayList.AddBeforeTask();
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

procedure TArrayList.DeleteTask();
var
  i, j: integer;
begin
  CritSec.Enter;

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
  i, counter: integer;
begin
  counter := 3;
  result := 0;

  Form1.Memo1.Lines.Add('2) Поиск введенного пользователем значения: ' +
    SearchItem.ToString + ';');
  Pause();

  for i := 1 to Count do
  begin
    if (aName = Items[i]) then
    begin
      result := i;
      break;
    end;
    Form1.Memo1.Lines.Add(counter.ToString +
      ') Продолжаем поиск, проверяем очередную ячейку: [' + i.ToString + '] <>'
      + SearchItem.ToString + ' , переходим к следующей ячейке;');
    Pause();
    Inc(counter);
  end;

  if result <> 0 then
  begin
    Form1.Memo1.Lines.Add(counter.ToString +
      ') Продолжаем поиск, проверяем очередную ячейку: элемент найден, [' +
      i.ToString + '] == ' + SearchItem.ToString + ' , конец поиска;');
    Pause();
  end
  else
  begin
    Form1.Memo1.Lines.Add(counter.ToString +
      ') Продолжаем поиск, проверяем очередную ячейку: Конец списка! Элемент не найден;');
    Pause();
  end;
end;

procedure TArrayList.Finish();
begin
  Form1.Memo1.Lines.Add('');
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
