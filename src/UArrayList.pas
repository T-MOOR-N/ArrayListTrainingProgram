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
    FMode: TOperatingMode;
    FCounter: integer;
    // Поле ссылающееся на обработчик события MyEvent.
    // Тип TNotifyEvent описан в модуле Clases так: TNotifyEvent = procedure(Sender: TObject) of object;
    // Фраза  "of object" означает, что в качестве обработчика можно назначить только метод какого-либо
    // класса, а не произвольную процедуру.
    FOnThreadSuspended: TNotifyEvent;
    FIsMove: boolean;

    Procedure AddFirstTask();
    Procedure AddAfterTask();
    Procedure AddBeforeTask();
    Function _Search(aName: integer): integer;
    Procedure DeleteTask();
    procedure Pause();
    procedure Finish();
    function GetStep: integer;
    procedure SetStep(const Value: integer);

    property step: integer read GetStep write SetStep;
  Public
    ThreadId: integer;

    Constructor Create();
    Procedure AddFirst(iNewValue: integer);
    Procedure AddAfter(iNewValue: integer; iSearchValue: integer);
    Procedure AddBefore(iNewValue: integer; iSearchValue: integer);
    Procedure Delete(Value: integer);
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
    property IsMove: boolean read FIsMove write FIsMove;
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
  i: integer;
begin
  Count := 0;
  step := 1;
  for i := 1 to Max do
    Items[i] := -1;
  CritSec := TCriticalSection.Create;
end;

Function TArrayList.GetCount;
begin
  result := Count;
end;

function TArrayList.GetStep: integer;
begin
  result := FCounter;
  Inc(FCounter);
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

procedure TArrayList.AddAfter(iNewValue: integer; iSearchValue: integer);

var
  id: longword;
begin
  NewItem := iNewValue;
  SearchItem := iSearchValue;
  State := lsAddAfter;
  ThreadId := BeginThread(nil, 0, @TArrayList.AddAfterTask, Self, 0, id);
end;

procedure TArrayList.AddBefore(iNewValue: integer; iSearchValue: integer);
var
  id: longword;
begin
  NewItem := iNewValue;
  SearchItem := iSearchValue;
  State := lsAddbefore;
  ThreadId := BeginThread(nil, 0, @TArrayList.AddBeforeTask, Self, 0, id);
end;

procedure TArrayList.Delete(Value: integer);
var
  id: longword;
begin
  State := lsDelete;
  SearchItem := Value;
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
    FormMain.ListBox.Items.Add('Добавление в список первого элемента ' +
      IntToStr(NewItem) + ' (COUNT = ' + Count.ToString + ')');
    Pause();
    step := 1;

    FormMain.ListBox.Items.Add(step.ToString + ') Вставка: заносим значение ' +
      NewItem.ToString + ' в ячейку [1];');
    Items[1] := NewItem;
    Pause();

    FormMain.ListBox.Items.Add(step.ToString + ') Увеличение COUNT на 1:' +
      ' COUNT = ' + Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
    Inc(Count);
  end;
  Finish();
end;

Procedure TArrayList.AddAfterTask();
var
  i, j: integer;
begin
  CritSec.Enter;

  FormMain.ListBox.Items.Add('Вставка в список элемента  ' + NewItem.ToString +
    ' после ' + SearchItem.ToString + ' (COUNT = ' + Count.ToString + ')');
  Pause();

  if Count = 0 then
    Finish();
  if Count = Max then
  begin
    FormMain.ListBox.Items.Add(step.ToString +
      ') Проверка возможности вставки: Список заполнен;');
    Finish();
  end;

  FormMain.ListBox.Items.Add(step.ToString +
    ') Проверка возможности вставки: ОК;');
  Pause();

  j := _Search(SearchItem);
  if j = 0 then
    Finish();

  if j = Count then
  begin
    FormMain.ListBox.Items.Add(step.ToString +
      ') Сдвиг текущей ячейки вправо: не нужен;');
    Pause();
  end
  else
  begin

    FormMain.ListBox.Items.Add(step.ToString +
      ') Сдвиг ячеек вправо: перемещаем вправо содержимое ячеек начиная с ячейки ['
      + (Count).ToString + '];');
    Pause();

    IsMove := true;
    for i := Count downto j + 1 do
    begin
      Items[i + 1] := Items[i];
      Items[i] := -1;

      FormMain.ListBox.Items.Add(step.ToString +
        ') Сдвиг текущей вправо: перемещаем содержимое ячейки [' + i.ToString +
        '] в ячейку [' + (i + 1).ToString + '];');
      Pause();
    end;
    IsMove := false;
  end;
  Items[j + 1] := NewItem;
  FormMain.ListBox.Items.Add(step.ToString + ') Вставка: заносим значение ' +
    NewItem.ToString + ' в ячейку [' + (j + 1).ToString + '];');
  Pause();

  FormMain.ListBox.Items.Add(step.ToString + ') Увеличение COUNT на 1:' +
    ' COUNT = ' + Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
  Inc(Count);

  Finish();
end;

procedure TArrayList.AddBeforeTask();
var
  i, j: integer;
begin
  CritSec.Enter;

  FormMain.ListBox.Items.Add('Вставка в список элемента  ' + NewItem.ToString +
    ' до ' + SearchItem.ToString + ' (COUNT = ' + Count.ToString + ')');
  Pause();

  if Count = 0 then
    Finish();
  if Count = Max then
  begin
    FormMain.ListBox.Items.Add(step.ToString +
      ') Проверка возможности вставки: Список заполнен;');
    Finish();
  end;

  FormMain.ListBox.Items.Add(step.ToString +
    ') Проверка возможности вставки: ОК;');
  Pause();

  j := _Search(SearchItem);
  if j = 0 then
    Finish();

  if j = Count then
  begin
    FormMain.ListBox.Items.Add(step.ToString +
      ') Сдвиг текущей ячейки вправо: не нужен;');
    Pause();
  end
  else
  begin

    FormMain.ListBox.Items.Add(step.ToString +
      ') Сдвиг ячеек вправо: перемещаем вправо содержимое ячеек начиная с ячейки ['
      + (Count).ToString + '];');
    Pause();

    IsMove := true;
    for i := Count + 1 downto j + 1 do
    begin
      Items[i] := Items[i - 1];
      Items[i - 1] := -1;

      FormMain.ListBox.Items.Add(step.ToString +
        ') Сдвиг текущей вправо: перемещаем содержимое ячейки [' + i.ToString +
        '] в ячейку [' + (i + 1).ToString + '];');
      Pause();
    end;
    IsMove := false;

  end;

  Items[j] := NewItem;

  FormMain.ListBox.Items.Add(step.ToString + ') Вставка: заносим значение ' +
    NewItem.ToString + ' в ячейку [' + j.ToString + '];');
  Pause();

  FormMain.ListBox.Items.Add(step.ToString + ') Увеличение COUNT на 1:' +
    ' COUNT = ' + Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
  Inc(Count);

  Finish();
end;

procedure TArrayList.DeleteTask();
var
  i, j: integer;
begin
  CritSec.Enter;

  FormMain.ListBox.Items.Add('Удаление элемента ' + SearchItem.ToString +
    ' (COUNT = ' + Count.ToString + ')');
  Pause();

  if Count = 0 then
  begin
    FormMain.ListBox.Items.Add(step.ToString +
      ') Проверка возможности удаления: не ОК - переделай текст;');
    Finish();
  end;

  FormMain.ListBox.Items.Add(step.ToString +
    ') Проверка возможности удаления: ОК;');
  Pause();

  j := _Search(SearchItem);
  if j = 0 then
    Finish();

  FormMain.ListBox.Items.Add('Извлечь элемент списка: [' + j.ToString + '] => '
    + SearchItem.ToString + ';');
  Items[j] := -1;
  Pause();

  FormMain.ListBox.Items.Add(step.ToString +
    ') Сдвиг ячеек влево: перемещаем влево содержимое ячеек начиная с ячейки ['
    + j.ToString + '];');
  Pause();

  IsMove := true;
  for i := j to Count - 1 do
  begin
    Items[i] := Items[i + 1];
    Items[i + 1]:=-1;

    FormMain.ListBox.Items.Add(step.ToString +
      ') Сдвиг текущей влево: перемещаем содержимое ячейки [' + (i + 1).ToString
      + '] в ячейку [' + i.ToString + '];');
    Pause();
  end;
  IsMove := false;

  FormMain.ListBox.Items.Add(step.ToString + ') Уменьшение COUNT на 1:' +
    ' COUNT = ' + Count.ToString + ' - 1 = ' + (Count - 1).ToString + ';');
  Dec(Count);
  Pause();
  Finish();
end;

Function TArrayList._Search(aName: integer): integer;
var
  i: integer;
begin
  result := 0;

  FormMain.ListBox.Items.Add(step.ToString +
    ') Поиск введенного пользователем значения: ' + SearchItem.ToString + ';');
  Pause();

  for i := 1 to Count do
  begin
    if (aName = Items[i]) then
    begin
      result := i;
      break;
    end;
    FormMain.ListBox.Items.Add(step.ToString +
      ') Продолжаем поиск, проверяем очередную ячейку: [' + i.ToString + '] <>'
      + SearchItem.ToString + ' , переходим к следующей ячейке;');
    Pause();
  end;

  if result <> 0 then
  begin
    FormMain.ListBox.Items.Add(step.ToString +
      ') Продолжаем поиск, проверяем очередную ячейку: элемент найден, [' +
      i.ToString + '] == ' + SearchItem.ToString + ' , конец поиска;');
    Pause();
  end
  else
  begin
    FormMain.ListBox.Items.Add(step.ToString +
      ') Продолжаем поиск, проверяем очередную ячейку: Конец списка! Элемент не найден;');
    Pause();
  end;
end;

procedure TArrayList.Finish();
begin
  Pause();
  FormMain.ListBox.Items.Add('');
  State := lsNormal;
  step := 1;
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

procedure TArrayList.SetStep(const Value: integer);
begin
  if FCounter <> Value then
    FCounter := Value;
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
