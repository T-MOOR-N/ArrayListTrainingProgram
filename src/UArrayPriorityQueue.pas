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

    // ��� ��������� ��������� ����� �� ���������� �������. �, ���� �����, ��������� ���.
    procedure DoMyEvent;
    // ��� �������� ��������� ��������� ���������� ��� ��������� ������� MyEvent.
    property OnThreadSyspended: TNotifyEvent read FOnThreadSuspended
      write FOnThreadSuspended;
    // ���������, ������� ��������� ������� - ��������� ������� MyEvent ��� ���.
    // ����� �������� ����� ���� ��������� - ����� ��� ����� ���������� ������� MyEvent.
    // ���� ������� MyEvent ���������, �� ��������� ��������� DoMyEvent().
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
  CritSec: TCriticalSection; // ������ ����������� ������
  // ���������� ��� �������� ������� ���������� � ������� ����������
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

  AddAnswers[0] := '�������� ����������� �������';
  AddAnswers[1] := '����� ���������� ������������� ��������';
  AddAnswers[2] := '���������� �����, ��������� ��������� ������';
  AddAnswers[3] := '����� ����� ������';
  AddAnswers[4] := '�������';
  AddAnswers[5] := '���������� COUNT �� 1';
  AddAnswers[6] := '����� ������� ������ ������';

  DeleteAnswers[0] := '�������� ����������� ��������';
  DeleteAnswers[1] := '����� ���������� ������������� ��������';
  DeleteAnswers[2] := '���������� �����, ��������� ��������� ������';
  DeleteAnswers[3] := '������� ������� ������';
  DeleteAnswers[4] := '����� ����� �����';
  DeleteAnswers[5] := '����� ������� ������ �����';
  DeleteAnswers[6] := '���������� COUNT �� 1';
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

{$ENDREGION}
{$ENDREGION}
{$REGION 'Task functions'}

Procedure TArrayPriorityQueue.AddTask();
var
  i: integer;
  procedure AddFirst();
  begin
    AddMessage('���������� � ������ ������� �������� ' + NewItem.ToString +
      ' (COUNT = ' + Count.ToString + ')');
    step := 1;

    AnswerKey := 4;
    Pause();
    AddMessage(step.ToString + ') �������: ������� �������� ' + NewItem.ToString
      + ' � ������ [1];');
    Items[1] := NewItem;

    AnswerKey := 5;
    Pause();
    AddMessage(step.ToString + ') ���������� COUNT �� 1:' + ' COUNT = ' +
      Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
    Inc(Count);
  end;

begin
  CritSec.Enter;
  if Count <> Max then
  begin
    if Count = 0 then
      // ���������� �������
      AddFirst()
    else
    begin
      // ����� ����� �������
      TempIndex := Search();

      AnswerKey := 3;
      Pause();
      AddMessage(step.ToString +
        ') ����� ����� ������: ���������� ������ ���������� ����� ������� � ������ ['
        + (Count).ToString + '];');

      IsMove := true;
      for i := Count + 1 downto TempIndex + 1 do
      begin
        AnswerKey := 6;
        Pause();
        AddMessage(step.ToString +
          ') ����� ������� ������: ���������� ���������� ������ [' + (i - 1)
          .ToString + '] � ������ [' + i.ToString + '];');

        Items[i] := Items[i - 1];
        Items[i - 1] := nil;

      end;
      IsMove := false;

      AnswerKey := 4;
      Pause();
      AddMessage(step.ToString + ') �������: ������� �������� ' +
        NewItem.ToString + ' � ������ [' + TempIndex.ToString + '];');

      AddIndex := TempIndex;
      Items[TempIndex] := NewItem;

      AnswerKey := 5;
      Pause();
      AddMessage(step.ToString + ') ���������� COUNT �� 1:' + ' COUNT = ' +
        Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
      Inc(Count);
    end;
  end
  else
  begin
    AddMessage(step.ToString +
      ') �������� ����������� �������: ������ ��������;');
  end;
  Finish();
end;

Function TArrayPriorityQueue.Search(): integer;
var
  i: integer;
begin
  result := 0;

  for i := 1 to Count do
  begin
    result := i;
    if Items[i].GetPriority >= NewItem.GetPriority then
      break;

    AnswerKey := 2;
    Pause();
    AddMessage(step.ToString +
      ') ���������� �����, ��������� ��������� ������: [' + i.ToString + '] <>'
      + SearchItem.ToString + ' , ��������� � ��������� ������;');
  end;

  if result <> 0 then
  begin
    AnswerKey := 2;
    Pause();
    AddMessage(step.ToString +
      ') ���������� �����, ��������� ��������� ������: ������� ������, ����� ������;');
  end;
end;

procedure TArrayPriorityQueue.DeleteTask();
var
  i, j: integer;
begin
  CritSec.Enter;

  AddMessage('�������� �������� ' + Items[Count].ToString + ' (COUNT = ' +
    Count.ToString + ')');

  AnswerKey := 0;
  Pause();
  if Count = 0 then
  begin
    AddMessage(step.ToString +
      ') �������� ����������� ��������: �� �� - ��������� �����;');
    Finish();
  end;
  AddMessage(step.ToString + ') �������� ����������� ��������: ��;');

  AnswerKey := 4;
  Pause();
  AddMessage(step.ToString + ') ������� ������� ������: [' + Count.ToString +
    '] => ' + SearchItem.ToString + ';');
  Items[Count] := nil;

  AnswerKey := 6;
  Pause();
  AddMessage(step.ToString + ') ���������� COUNT �� 1:' + ' COUNT = ' +
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
  // ���� ���������� ��������, �� ��������� ���.
  if Assigned(FOnThreadSuspended) then
    FOnThreadSuspended(Self);
end;

procedure TArrayPriorityQueue.GenericMyEvent;
var
  MyEventIsOccurred: boolean;
begin
  MyEventIsOccurred := true;
  // ���� ����� ��������� �������, ������� ������������, ��� ������� MyEvent
  // ���������, �� ������ ������� ��������� ��������� ����������.
  if MyEventIsOccurred then
  begin
    DoMyEvent;
  end;
end;

{$ENDREGION}

end.
