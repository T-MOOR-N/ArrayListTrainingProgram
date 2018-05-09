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
    temp, Add: integer;
    AnswerKey: integer;

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

var
  AddAnswers: array [0 .. 6] of string;
  DeleteAnswers: array [0 .. 4] of string;
  allowmessage: boolean;

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
  temp := -1;
  Add := -1;
  allowmessage := true;
  for i := 1 to Max do
    Items[i] := -1;
  CritSec := TCriticalSection.Create;

  AddAnswers[0] := 'Проверка возможности вставки';
  AddAnswers[1] := 'Поиск введенного пользователем значения';
  AddAnswers[2] := 'Продолжаем поиск, проверяем очередную ячейку';
  AddAnswers[3] := 'Сдвиг ячеек вправо';
  AddAnswers[4] := 'Вставка';
  AddAnswers[5] := 'Увеличение COUNT на 1';
  AddAnswers[6] := 'Сдвиг текущей ячейки вправо';

  DeleteAnswers[0] := 'Проверка возможности удаления';
  DeleteAnswers[1] := 'Поиск введенного пользователем значения';
  DeleteAnswers[2] := 'Извлечь элемент списка';
  DeleteAnswers[3] := 'Сдвиг ячеек влево';
  DeleteAnswers[4] := 'Уменьшение COUNT на 1';
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

procedure AddMessage(const S: String);
begin
  if allowmessage then
    FormMain.ListBox.Items.Add(S);
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
    AddMessage('Добавление в список первого элемента ' + IntToStr(NewItem) +
      ' (COUNT = ' + Count.ToString + ')');
    step := 1;

    AnswerKey := 4;
    Pause();
    AddMessage(step.ToString + ') Вставка: заносим значение ' + NewItem.ToString
      + ' в ячейку [1];');
    Items[1] := NewItem;

    AnswerKey := 5;
    Pause();
    AddMessage(step.ToString + ') Увеличение COUNT на 1:' + ' COUNT = ' +
      Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
    Inc(Count);
  end;
  Finish();
end;

Procedure TArrayList.AddAfterTask();
var
  i: integer;
begin
  CritSec.Enter;

  AddMessage('Вставка в список элемента  ' + NewItem.ToString + ' после ' +
    SearchItem.ToString + ' (COUNT = ' + Count.ToString + ')');

  AnswerKey := 0;
  Pause();
  if Count = 0 then
    Finish();
  if Count = Max then
  begin
    AddMessage(step.ToString +
      ') Проверка возможности вставки: Список заполнен;');
    Finish();
  end;

  AddMessage(step.ToString + ') Проверка возможности вставки: ОК;');

  AnswerKey := 1;
  Pause();

  temp := _Search(SearchItem);
  if temp = 0 then
    Finish();

  AnswerKey := 3;
  Pause();

  if temp = Count then
  begin
    AddMessage(step.ToString + ') Сдвиг ячеек вправо: не нужен;');
    Pause();
  end
  else
  begin

    AddMessage(step.ToString +
      ') Сдвиг ячеек вправо: перемещаем вправо содержимое ячеек начиная с ячейки ['
      + (Count).ToString + '];');

    IsMove := true;
    for i := Count downto temp + 1 do
    begin
      AnswerKey := 6;
      Pause();
      AddMessage(step.ToString +
        ') Сдвиг текущей вправо: перемещаем содержимое ячейки [' + i.ToString +
        '] в ячейку [' + (i + 1).ToString + '];');

      Items[i + 1] := Items[i];
      Items[i] := -1;
    end;
    IsMove := false;
  end;
  AnswerKey := 4;
  Pause();
  AddMessage(step.ToString + ') Вставка: заносим значение ' + NewItem.ToString +
    ' в ячейку [' + (temp + 1).ToString + '];');

  Add := temp + 1;
  Items[temp + 1] := NewItem;

  AnswerKey := 5;
  Pause();
  AddMessage(step.ToString + ') Увеличение COUNT на 1:' + ' COUNT = ' +
    Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
  Inc(Count);

  Finish();
end;

procedure TArrayList.AddBeforeTask();
var
  i: integer;
begin
  CritSec.Enter;

  AddMessage('Вставка в список элемента  ' + NewItem.ToString + ' до ' +
    SearchItem.ToString + ' (COUNT = ' + Count.ToString + ')');

  AnswerKey := 0;
  Pause();

  if Count = 0 then
    Finish();

  if Count = Max then
  begin
    AddMessage(step.ToString +
      ') Проверка возможности вставки: Список заполнен;');
    Finish();
  end;

  AddMessage(step.ToString + ') Проверка возможности вставки: ОК;');

  AnswerKey := 1;
  Pause();

  temp := _Search(SearchItem);
  if temp = 0 then
    Finish();

  AnswerKey := 3;
  Pause();
  AddMessage(step.ToString +
    ') Сдвиг ячеек вправо: перемещаем вправо содержимое ячеек начиная с ячейки ['
    + (Count).ToString + '];');

  IsMove := true;
  for i := Count + 1 downto temp + 1 do
  begin
    AnswerKey := 6;
    Pause();
    AddMessage(step.ToString +
      ') Сдвиг текущей вправо: перемещаем содержимое ячейки [' + (i - 1)
      .ToString + '] в ячейку [' + i.ToString + '];');

    Items[i] := Items[i - 1];
    Items[i - 1] := -1;

  end;
  IsMove := false;

  AnswerKey := 4;
  Pause();
  AddMessage(step.ToString + ') Вставка: заносим значение ' + NewItem.ToString +
    ' в ячейку [' + temp.ToString + '];');

  Add := temp;
  Items[temp] := NewItem;

  AnswerKey := 5;
  Pause();
  AddMessage(step.ToString + ') Увеличение COUNT на 1:' + ' COUNT = ' +
    Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
  Inc(Count);

  Finish();
end;

procedure TArrayList.DeleteTask();
var
  i, j: integer;
begin
  CritSec.Enter;

  AddMessage('Удаление элемента ' + SearchItem.ToString + ' (COUNT = ' +
    Count.ToString + ')');
  Pause();

  AnswerKey := 0;
  if Count = 0 then
  begin
    AddMessage(step.ToString +
      ') Проверка возможности удаления: не ОК - переделай текст;');
    Finish();
  end;

  AddMessage(step.ToString + ') Проверка возможности удаления: ОК;');
  Pause();

  AnswerKey := 1;
  j := _Search(SearchItem);
  if j = 0 then
    Finish();

  AnswerKey := 2;
  AddMessage('Извлечь элемент списка: [' + j.ToString + '] => ' +
    SearchItem.ToString + ';');
  Items[j] := -1;
  Pause();

  AnswerKey := 3;
  AddMessage(step.ToString +
    ') Сдвиг ячеек влево: перемещаем влево содержимое ячеек начиная с ячейки ['
    + j.ToString + '];');
  Pause();

  IsMove := true;
  for i := j to Count - 1 do
  begin
    Items[i] := Items[i + 1];
    Items[i + 1] := -1;

    AddMessage(step.ToString +
      ') Сдвиг текущей влево: перемещаем содержимое ячейки [' + (i + 1).ToString
      + '] в ячейку [' + i.ToString + '];');
    Pause();
  end;
  IsMove := false;

  AnswerKey := 4;
  AddMessage(step.ToString + ') Уменьшение COUNT на 1:' + ' COUNT = ' +
    Count.ToString + ' - 1 = ' + (Count - 1).ToString + ';');
  Dec(Count);
  Pause();
  Finish();
end;

Function TArrayList._Search(aName: integer): integer;
var
  i: integer;
begin
  result := 0;

  AddMessage(step.ToString + ') Поиск введенного пользователем значения: ' +
    SearchItem.ToString + ';');

  // Pause();

  for i := 1 to Count do
  begin
    temp := i;
    if (aName = Items[i]) then
    begin
      result := i;
      break;
    end;

    AnswerKey := 2;
    Pause();
    AddMessage(step.ToString +
      ') Продолжаем поиск, проверяем очередную ячейку: [' + i.ToString + '] <>'
      + SearchItem.ToString + ' , переходим к следующей ячейке;');
    // Pause();
  end;

  if result <> 0 then
  begin
    AnswerKey := 2;
    Pause();
    AddMessage(step.ToString +
      ') Продолжаем поиск, проверяем очередную ячейку: элемент найден, [' +
      i.ToString + '] == ' + SearchItem.ToString + ' , конец поиска;');
  end
  else
  begin
    AnswerKey := 2;
    Pause();

    AddMessage(step.ToString +
      ') Продолжаем поиск, проверяем очередную ячейку: Конец списка! Элемент не найден;');
    // Pause();
  end;
end;

procedure TArrayList.Finish();
begin
  // Pause();
  AddMessage('');
  State := lsNormal;
  temp := -1;
  Add := -1;
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
