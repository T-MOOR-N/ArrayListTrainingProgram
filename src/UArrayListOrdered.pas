unit UArrayListOrdered;

interface

uses SysUtils, SyncObjs, System.Classes, Windows;

const
  Max = 6;

type
  TListState = (lsNormal, lsAdd, lsAddbefore, lsAddAfter, lsDelete);
  TOperatingMode = (omControl, omNormal, omDemo);

  TArrayListOrdered = class
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

    Procedure AddTask();
    Function _Search(aName: integer): integer;
    Procedure DeleteTask();
    procedure Pause();
    procedure Finish();
    function GetStep: integer;
    procedure SetStep(const Value: integer);

    property step: integer read GetStep write SetStep;
  Public
    ThreadId: integer;
    temp, AddIndex: integer;
    AnswerKey: integer;

    Constructor Create();
    Procedure Add(iNewValue: integer);
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
  DeleteAnswers: array [0 .. 6] of string;
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

Constructor TArrayListOrdered.Create();
var
  i: integer;
begin
  Count := 0;
  step := 1;
  temp := -1;
  AddIndex := -1;
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
  DeleteAnswers[2] := 'Продолжаем поиск, проверяем очередную ячейку';
  DeleteAnswers[3] := 'Извлечь элемент списка';
  DeleteAnswers[4] := 'Сдвиг ячеек влево';
  DeleteAnswers[5] := 'Сдвиг текущей ячейки влево';
  DeleteAnswers[6] := 'Уменьшение COUNT на 1';
end;

Function TArrayListOrdered.GetCount;
begin
  result := Count;
end;

function TArrayListOrdered.GetStep: integer;
begin
  result := FCounter;
  Inc(FCounter);
end;

Function TArrayListOrdered.GetItem(index: integer): string;
begin
  if Items[index] = -1 then
    result := ''
  else
    result := IntToStr(Items[index]);
end;

Function TArrayListOrdered.GetMaxCount;
begin
  result := Max;
end;

procedure AddMessage(const S: String);
begin
  if allowmessage then
    FormMain.ListBox.Items.Add(S);
end;
{$REGION 'ThreadWrapper'}

procedure TArrayListOrdered.Add(iNewValue: integer);
var
  id: longword;
begin
  State := lsAdd;
  NewItem := iNewValue;
  ThreadId := BeginThread(nil, 0, @TArrayListOrdered.AddTask, Self, 0, id);
end;

procedure TArrayListOrdered.Delete(Value: integer);
var
  id: longword;
begin
  State := lsDelete;
  SearchItem := Value;
  ThreadId := BeginThread(nil, 0, @TArrayListOrdered.DeleteTask, Self, 0, id);
end;

{$ENDREGION}
{$ENDREGION}
{$REGION 'Task functions'}

Procedure TArrayListOrdered.AddTask();
var
  i, j: integer;
begin
  CritSec.Enter;
  if Count <> Max then
  begin
    if Count = 0 then
      // добавление первого
      Items[1] := NewItem
    else
    begin
      // поиск места вставки
      for i := 1 to Count do
        if NewItem < Items[i] then
          break;
      // свдиг ячеек массива
      for j := Count + 1 downto i + 1 do
      begin
        Items[j] := Items[j - 1];
        Items[j - 1] := -1;
      end;
      Items[i] := NewItem;
    end;
    Inc(Count);
  end;
  Finish();
end;

procedure TArrayListOrdered.DeleteTask();
var
  i, j: integer;
begin
  CritSec.Enter;

  AddMessage('Удаление элемента ' + SearchItem.ToString + ' (COUNT = ' +
    Count.ToString + ')');

  AnswerKey := 0;
  Pause();

  if Count = 0 then
  begin
    AddMessage(step.ToString +
      ') Проверка возможности удаления: не ОК - переделай текст;');
    Finish();
  end;

  AddMessage(step.ToString + ') Проверка возможности удаления: ОК;');

  AnswerKey := 1;
  Pause();

  j := _Search(SearchItem);
  if j = 0 then
    Finish();

  AnswerKey := 4;
  Pause();
  AddMessage(step.ToString + ') Извлечь элемент списка: [' + j.ToString +
    '] => ' + SearchItem.ToString + ';');
  Items[j] := -1;

  Pause();
  AnswerKey := 4;
  AddMessage(step.ToString +
    ') Сдвиг ячеек влево: перемещаем влево содержимое ячеек начиная с ячейки ['
    + j.ToString + '];');

  IsMove := true;
  for i := j to Count - 1 do
  begin
    AnswerKey := 5;
    Pause();
    AddMessage(step.ToString +
      ') Сдвиг текущей влево: перемещаем содержимое ячейки [' + (i + 1).ToString
      + '] в ячейку [' + i.ToString + '];');

    Items[i] := Items[i + 1];
    Items[i + 1] := -1;
  end;
  IsMove := false;

  AnswerKey := 6;
  Pause();
  AddMessage(step.ToString + ') Уменьшение COUNT на 1:' + ' COUNT = ' +
    Count.ToString + ' - 1 = ' + (Count - 1).ToString + ';');
  Dec(Count);
  Finish();
end;

Function TArrayListOrdered._Search(aName: integer): integer;
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

procedure TArrayListOrdered.Finish();
begin
  // Pause();
  AddMessage('');
  State := lsNormal;
  temp := -1;
  AddIndex := -1;
  step := 1;
  GenericMyEvent;
  CritSec.Leave;
  EndThread(0);
  exit;
end;

procedure TArrayListOrdered.Pause();
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

procedure TArrayListOrdered.SetStep(const Value: integer);
begin
  if FCounter <> Value then
    FCounter := Value;
end;

procedure TArrayListOrdered.NextStep();
begin
  ResumeThread(ThreadId);
end;

{$ENDREGION}
{$REGION 'Event'}

procedure TArrayListOrdered.DoMyEvent;
begin
  // Если обработчик назначен, то запускаем его.
  if Assigned(FOnThreadSuspended) then
    FOnThreadSuspended(Self);
end;

procedure TArrayListOrdered.GenericMyEvent;
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
