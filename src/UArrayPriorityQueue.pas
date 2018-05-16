unit UArrayPriorityQueue;

interface

uses SysUtils, UPriorityQueueItem, SyncObjs, System.Classes, Windows,
  UEnumerations;

const
  Max = 6;

type
  TPriorityQueueState = (pqsNormal, pqsAdd, pqsDelete);

  TArrayPriorityQueue = class
  Private
    Items: array [1 .. Max] of TPriorityQueueItem;
    Count: integer;
    FState: TPriorityQueueState;
    FMode: TOperatingMode;
    FCounter: integer;
    FOnThreadSuspended: TNotifyEvent;
    FIsMove: boolean;

    Procedure AddTask();
    Procedure DeleteTask();
    Function Search(): integer;
    procedure Pause();
    procedure Finish();
    function GetStep: integer;
    procedure SetStep(const value: integer);

    property step: integer read GetStep write SetStep;
  Public
    ThreadId: integer;
    TempIndex, AddIndex: integer;
    AnswerKey: integer;

    Constructor Create();
    Procedure Add(value: TPriorityQueueItem);
    Procedure Delete();
    Function GetCount: integer;
    Function GetMaxCount: integer;
    Function GetItem(index: integer): string;
    procedure NextStep();
    function Contains(const value: integer): boolean;

    // Эта процедура проверяет задан ли обработчик события. И, если задан, запускает его.
    procedure DoMyEvent;
    // Это свойство позволяет назначить обработчик для обработки события MyEvent.
    property OnThreadSyspended: TNotifyEvent read FOnThreadSuspended
      write FOnThreadSuspended;
    // Процедура, которая принимает решение - произошло событие MyEvent или нет.
    // Таких процедур может быть несколько - везде где может возникнуть событие MyEvent.
    // Если событие MyEvent произошло, то вызвается процедура DoMyEvent().
    procedure GenericMyEvent;

    property State: TPriorityQueueState read FState write FState;
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
  NewItem: TPriorityQueueItem;
  SearchItem: integer;
{$REGION 'Public functions'}

Constructor TArrayPriorityQueue.Create();
var
  i: integer;
begin
  Count := 0;
  step := 1;
  TempIndex := -1;
  AddIndex := -1;
  allowmessage := true;
  for i := 1 to Max do
    Items[i] := nil;
  CritSec := TCriticalSection.Create;

  AddAnswers[0] := 'Проверка возможности вставки';
  AddAnswers[1] := 'Поиск места вставки';
  AddAnswers[2] := 'Продолжаем поиск, проверяем очередную ячейку';
  AddAnswers[3] := 'Сдвиг ячеек вправо';
  AddAnswers[4] := 'Вставка';
  AddAnswers[5] := 'Увеличение COUNT на 1';
  AddAnswers[6] := 'Сдвиг текущей ячейки вправо';

  DeleteAnswers[0] := 'Проверка возможности удаления';
  DeleteAnswers[1] := 'Извлечь элемент приоритетной очережи';
  DeleteAnswers[2] := 'Сдвиг ячеек влево';
  DeleteAnswers[3] := 'Сдвиг текущей ячейки влево';
  DeleteAnswers[4] := 'Уменьшение COUNT на 1';
end;

Function TArrayPriorityQueue.GetCount;
begin
  result := Count;
end;

function TArrayPriorityQueue.GetStep: integer;
begin
  result := FCounter;
  Inc(FCounter);
end;

Function TArrayPriorityQueue.GetItem(index: integer): string;
begin
  if Items[index] = nil then
    result := ''
  else
    result := Items[index].ToString;
end;

Function TArrayPriorityQueue.GetMaxCount;
begin
  result := Max;
end;

procedure AddMessage(const S: String);
begin
  if allowmessage then
    FormMain.ListBox.Items.Add(S);
end;
{$REGION 'ThreadWrapper'}

procedure TArrayPriorityQueue.Add(value: TPriorityQueueItem);
var
  id: longword;
begin
  State := pqsAdd;
  NewItem := value;
  ThreadId := BeginThread(nil, 0, @TArrayPriorityQueue.AddTask, Self, 0, id);
end;

procedure TArrayPriorityQueue.Delete();
var
  id: longword;
begin
  State := pqsDelete;
  ThreadId := BeginThread(nil, 0, @TArrayPriorityQueue.DeleteTask, Self, 0, id);
end;

function TArrayPriorityQueue.Contains(const value: integer): boolean;
var
  i: integer;
begin
  result := true;
  for i := 1 to Count do
    if Items[i].GetID = value then
      exit;
  result := false;
end;

{$ENDREGION}
{$ENDREGION}
{$REGION 'Task functions'}

Procedure TArrayPriorityQueue.AddTask();
var
  i: integer;
  procedure AddFirst();
  begin
    AddMessage('Добавление первого элемента ' + NewItem.GetID.ToString +
      ' с приоритетом ' + NewItem.GetPriority.ToString);
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

begin
  CritSec.Enter;
  if Count <> Max then
  begin
    if Count = 0 then
      // добавление первого
      AddFirst()
    else
    begin
      AddMessage('Добавление элемента ' + NewItem.GetID.ToString +
        ' с приоритетом ' + NewItem.GetPriority.ToString);

      AnswerKey := 0;
      Pause();
      AddMessage(step.ToString + ') Проверка возможности вставки: ОК;');

      AnswerKey := 1;
      Pause();

      // поиск места вставки
      TempIndex := Search();

      AnswerKey := 3;
      Pause();

      if TempIndex = Count + 1 then
      begin
        AddMessage(step.ToString + ') Сдвиг ячеек вправо: не нужен;');
      end
      else
      begin
        AddMessage(step.ToString +
          ') Сдвиг ячеек вправо: перемещаем вправо содержимое ячеек начиная с ячейки ['
          + (Count).ToString + '];');

        IsMove := true;
        for i := Count + 1 downto TempIndex + 1 do
        begin
          AnswerKey := 6;
          Pause();
          AddMessage(step.ToString +
            ') Сдвиг текущей вправо: перемещаем содержимое ячейки [' + (i - 1)
            .ToString + '] в ячейку [' + i.ToString + '];');

          Items[i] := Items[i - 1];
          Items[i - 1] := nil;

        end;
        IsMove := false;
      end;

      AnswerKey := 4;
      Pause();
      AddMessage(step.ToString + ') Вставка: заносим значение ' +
        NewItem.ToString + ' в ячейку [' + TempIndex.ToString + '];');

      AddIndex := TempIndex;
      Items[TempIndex] := NewItem;

      AnswerKey := 5;
      Pause();
      AddMessage(step.ToString + ') Увеличение COUNT на 1:' + ' COUNT = ' +
        Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
      Inc(Count);
    end;
  end
  else
  begin
    AddMessage(step.ToString +
      ') Проверка возможности вставки: Приоритетная очередь заполнена;');
  end;
  Finish();
end;

Function TArrayPriorityQueue.Search(): integer;
var
  i: integer;
begin
  result := 0;

  AddMessage(step.ToString +
    ') Поиск места вставки: первый по порядку элемент c приоритетом >= нового ;');

  for i := 1 to Count do
  begin
    TempIndex := i;
    if Items[i].GetPriority >= NewItem.GetPriority then
      break;

    AnswerKey := 2;
    Pause();
    AddMessage(step.ToString + ') проверяем ячейку [' + i.ToString +
      '] : приоритет меньше - идем дальше;');
  end;
  result := i;

  AnswerKey := 2;
  Pause();
  AddMessage(step.ToString + ') проверяем ячейку [' + i.ToString +
    '] : приоритет НЕ меньше - поиск закончен;');
end;

procedure TArrayPriorityQueue.DeleteTask();
var
  i, j: integer;
begin
  CritSec.Enter;

  AddMessage('Удаление из очереди, (COUNT = ' + Count.ToString + ')');

  AnswerKey := 0;
  Pause();
  if Count = 0 then
  begin
    AddMessage(step.ToString +
      ') Проверка возможности удаления: не ОК - переделай текст;');
    Finish();
  end;
  AddMessage(step.ToString + ') Проверка возможности удаления: ОК;');

  AnswerKey := 4;
  Pause();
  AddMessage(step.ToString + ') Извлечь элемент из приориттной очереди: [' +
    Count.ToString + '] => ' + SearchItem.ToString + ';');
  Items[Count] := nil;

  AnswerKey := 6;
  Pause();
  AddMessage(step.ToString + ') Уменьшение COUNT на 1:' + ' COUNT = ' +
    Count.ToString + ' - 1 = ' + (Count - 1).ToString + ';');
  Dec(Count);
  Finish();
end;

procedure TArrayPriorityQueue.Finish();
begin
  // Pause();
  AddMessage('');
  State := pqsNormal;
  TempIndex := -1;
  AddIndex := -1;
  step := 1;
  GenericMyEvent;
  CritSec.Leave;
  EndThread(0);
  exit;
end;

procedure TArrayPriorityQueue.Pause();
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

procedure TArrayPriorityQueue.SetStep(const value: integer);
begin
  if FCounter <> value then
    FCounter := value;
end;

procedure TArrayPriorityQueue.NextStep();
begin
  ResumeThread(ThreadId);
end;

{$ENDREGION}
{$REGION 'Event'}

procedure TArrayPriorityQueue.DoMyEvent;
begin
  // Если обработчик назначен, то запускаем его.
  if Assigned(FOnThreadSuspended) then
    FOnThreadSuspended(Self);
end;

procedure TArrayPriorityQueue.GenericMyEvent;
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
