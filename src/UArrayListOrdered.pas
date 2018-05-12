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
    // ���� ����������� �� ���������� ������� MyEvent.
    // ��� TNotifyEvent ������ � ������ Clases ���: TNotifyEvent = procedure(Sender: TObject) of object;
    // �����  "of object" ��������, ��� � �������� ����������� ����� ��������� ������ ����� ������-����
    // ������, � �� ������������ ���������.
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

    // ��� ��������� ��������� ����� �� ���������� �������. �, ���� �����, ��������� ���.
    procedure DoMyEvent; // dynamic;
    // ��� �������� ��������� ��������� ���������� ��� ��������� ������� MyEvent.
    property OnThreadSyspended: TNotifyEvent read FOnThreadSuspended
      write FOnThreadSuspended;
    // ���������, ������� ��������� ������� - ��������� ������� MyEvent ��� ���.
    // ����� �������� ����� ���� ��������� - ����� ��� ����� ���������� ������� MyEvent.
    // ���� ������� MyEvent ���������, �� ��������� ��������� DoMyEvent().
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
  CritSec: TCriticalSection; // ������ ����������� ������
  // ���������� ��� �������� ������� ���������� � ������� ����������
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
      // ���������� �������
      Items[1] := NewItem
    else
    begin
      // ����� ����� �������
      for i := 1 to Count do
        if NewItem < Items[i] then
          break;
      // ����� ����� �������
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

  AddMessage('�������� �������� ' + SearchItem.ToString + ' (COUNT = ' +
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

  AnswerKey := 1;
  Pause();

  j := _Search(SearchItem);
  if j = 0 then
    Finish();

  AnswerKey := 4;
  Pause();
  AddMessage(step.ToString + ') ������� ������� ������: [' + j.ToString +
    '] => ' + SearchItem.ToString + ';');
  Items[j] := -1;

  Pause();
  AnswerKey := 4;
  AddMessage(step.ToString +
    ') ����� ����� �����: ���������� ����� ���������� ����� ������� � ������ ['
    + j.ToString + '];');

  IsMove := true;
  for i := j to Count - 1 do
  begin
    AnswerKey := 5;
    Pause();
    AddMessage(step.ToString +
      ') ����� ������� �����: ���������� ���������� ������ [' + (i + 1).ToString
      + '] � ������ [' + i.ToString + '];');

    Items[i] := Items[i + 1];
    Items[i + 1] := -1;
  end;
  IsMove := false;

  AnswerKey := 6;
  Pause();
  AddMessage(step.ToString + ') ���������� COUNT �� 1:' + ' COUNT = ' +
    Count.ToString + ' - 1 = ' + (Count - 1).ToString + ';');
  Dec(Count);
  Finish();
end;

Function TArrayListOrdered._Search(aName: integer): integer;
var
  i: integer;
begin
  result := 0;

  AddMessage(step.ToString + ') ����� ���������� ������������� ��������: ' +
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
      ') ���������� �����, ��������� ��������� ������: [' + i.ToString + '] <>'
      + SearchItem.ToString + ' , ��������� � ��������� ������;');
    // Pause();
  end;

  if result <> 0 then
  begin
    AnswerKey := 2;
    Pause();
    AddMessage(step.ToString +
      ') ���������� �����, ��������� ��������� ������: ������� ������, [' +
      i.ToString + '] == ' + SearchItem.ToString + ' , ����� ������;');
  end
  else
  begin
    AnswerKey := 2;
    Pause();

    AddMessage(step.ToString +
      ') ���������� �����, ��������� ��������� ������: ����� ������! ������� �� ������;');
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
  // ���� ���������� ��������, �� ��������� ���.
  if Assigned(FOnThreadSuspended) then
    FOnThreadSuspended(Self);
end;

procedure TArrayListOrdered.GenericMyEvent;
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
