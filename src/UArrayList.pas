unit UArrayList;

interface

uses SysUtils, SyncObjs, System.Classes, Windows;

const
  Max = 6;

type
  TListState = (lsNormal, lsAdd, lsAddFirst, lsAddbefore, lsAddAfter, lsDelete);
  TOperatingMode = (omControl, omNormal, omDemo);

  TArrayList = class
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
    IsOrdered: boolean;

    Procedure AddTask();
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
    TempIndex: integer;
    AddIndex: integer;
    AnswerKey: integer;

    Constructor Create(Ordered: boolean = false);
    Procedure Add(iNewValue: integer);
    Procedure AddFirst(iNewValue: integer);
    Procedure AddAfter(iNewValue: integer; iSearchValue: integer);
    Procedure AddBefore(iNewValue: integer; iSearchValue: integer);
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
  AddAnswers: array [0 .. 7] of string;
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

Constructor TArrayList.Create(Ordered: boolean = false);
var
  i: integer;
begin
  IsOrdered := Ordered;
  Count := 0;
  step := 1;
  TempIndex := -1;
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
  AddAnswers[7] := '����� ����� ��� �������';

  DeleteAnswers[0] := '�������� ����������� ��������';
  DeleteAnswers[1] := '����� ���������� ������������� ��������';
  DeleteAnswers[2] := '���������� �����, ��������� ��������� ������';
  DeleteAnswers[3] := '������� ������� ������';
  DeleteAnswers[4] := '����� ����� �����';
  DeleteAnswers[5] := '����� ������� ������ �����';
  DeleteAnswers[6] := '���������� COUNT �� 1';
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

procedure TArrayList.Add(iNewValue: integer);
var
  id: longword;
begin
  if not IsOrdered then
    exit;
  State := lsAdd;
  NewItem := iNewValue;
  ThreadId := BeginThread(nil, 0, @TArrayList.AddTask, Self, 0, id);
end;

procedure TArrayList.AddFirst(iNewValue: integer);
var
  id: longword;
begin
  if IsOrdered then
    exit;
  State := lsAddFirst;
  NewItem := iNewValue;
  ThreadId := BeginThread(nil, 0, @TArrayList.AddFirstTask, Self, 0, id);
end;

procedure TArrayList.AddAfter(iNewValue: integer; iSearchValue: integer);

var
  id: longword;
begin
  if IsOrdered then
    exit;
  NewItem := iNewValue;
  SearchItem := iSearchValue;
  State := lsAddAfter;
  ThreadId := BeginThread(nil, 0, @TArrayList.AddAfterTask, Self, 0, id);
end;

procedure TArrayList.AddBefore(iNewValue: integer; iSearchValue: integer);
var
  id: longword;
begin
  if IsOrdered then
    exit;
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

Procedure TArrayList.AddTask();
var
  i, j: integer;
begin
  if Count <> Max then
  begin
    if Count = 0 then
      // ���������� �������
      AddFirstTask()
    else
    begin
      CritSec.Enter;
      AddMessage('���������� � ������������� ������');
      step := 1;

      AnswerKey := 0;
      Pause();
      AddMessage(step.ToString + ') �������� ����������� �������: ��;');

      AnswerKey := 7;
      Pause();
      AddMessage(step.ToString + '����� ����� ��� �������');
      // ����� ����� �������
      for j := 1 to Count do
      begin
        TempIndex := j;
        if NewItem < Items[j] then
          break;

        AnswerKey := 2;
        Pause();
        AddMessage(step.ToString +
          ') ���������� �����, ��������� ��������� ������: [' + j.ToString +
          '] <' + SearchItem.ToString + ' , ��������� � ��������� ������;');
      end;

      if j > Count then
      begin
        AnswerKey := 2;
        Pause();
        AddMessage(step.ToString +
          ') ���������� �����, ��������� ��������� ������: ����� ��� ������� �������, ['
          + j.ToString + '] > ' + SearchItem.ToString + ' , ����� ������;');
      end
      else
      begin
        AnswerKey := 2;
        Pause();
        AddMessage(step.ToString +
          ') ���������� �����, ��������� ��������� ������: ����� ��� ������� �������, ['
          + j.ToString + '] < ' + SearchItem.ToString + ' , ����� ������;');
      end;

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
        Items[i - 1] := -1;

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
    AddMessage(step.ToString +
      ') �������� ����������� �������: ������ ��������;');
  Finish();
end;

Procedure TArrayList.AddFirstTask();
begin
  CritSec.Enter;
  if Count = 0 then
  begin
    AddMessage('���������� � ������ ������� �������� ' + IntToStr(NewItem) +
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
  Finish();
end;

Procedure TArrayList.AddAfterTask();
var
  i: integer;
begin
  CritSec.Enter;

  AddMessage('������� � ������ ��������  ' + NewItem.ToString + ' ����� ' +
    SearchItem.ToString + ' (COUNT = ' + Count.ToString + ')');

  AnswerKey := 0;
  Pause();
  if Count = 0 then
    Finish();
  if Count = Max then
  begin
    AddMessage(step.ToString +
      ') �������� ����������� �������: ������ ��������;');
    Finish();
  end;

  AddMessage(step.ToString + ') �������� ����������� �������: ��;');

  AnswerKey := 1;
  Pause();

  TempIndex := _Search(SearchItem);
  if TempIndex = 0 then
    Finish();

  AnswerKey := 3;
  Pause();

  if TempIndex = Count then
  begin
    AddMessage(step.ToString + ') ����� ����� ������: �� �����;');
  end
  else
  begin

    AddMessage(step.ToString +
      ') ����� ����� ������: ���������� ������ ���������� ����� ������� � ������ ['
      + (Count).ToString + '];');

    IsMove := true;
    for i := Count downto TempIndex + 1 do
    begin
      AnswerKey := 6;
      Pause();
      AddMessage(step.ToString +
        ') ����� ������� ������: ���������� ���������� ������ [' + i.ToString +
        '] � ������ [' + (i + 1).ToString + '];');

      Items[i + 1] := Items[i];
      Items[i] := -1;
    end;
    IsMove := false;
  end;
  AnswerKey := 4;
  Pause();
  AddMessage(step.ToString + ') �������: ������� �������� ' + NewItem.ToString +
    ' � ������ [' + (TempIndex + 1).ToString + '];');

  AddIndex := TempIndex + 1;
  Items[TempIndex + 1] := NewItem;

  AnswerKey := 5;
  Pause();
  AddMessage(step.ToString + ') ���������� COUNT �� 1:' + ' COUNT = ' +
    Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
  Inc(Count);

  Finish();
end;

procedure TArrayList.AddBeforeTask();
var
  i: integer;
begin
  CritSec.Enter;

  AddMessage('������� � ������ ��������  ' + NewItem.ToString + ' �� ' +
    SearchItem.ToString + ' (COUNT = ' + Count.ToString + ')');

  AnswerKey := 0;
  Pause();

  if Count = 0 then
    Finish();

  if Count = Max then
  begin
    AddMessage(step.ToString +
      ') �������� ����������� �������: ������ ��������;');
    Finish();
  end;

  AddMessage(step.ToString + ') �������� ����������� �������: ��;');

  AnswerKey := 1;
  Pause();

  TempIndex := _Search(SearchItem);
  if TempIndex = 0 then
    Finish();

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
    Items[i - 1] := -1;

  end;
  IsMove := false;

  AnswerKey := 4;
  Pause();
  AddMessage(step.ToString + ') �������: ������� �������� ' + NewItem.ToString +
    ' � ������ [' + TempIndex.ToString + '];');

  AddIndex := TempIndex;
  Items[TempIndex] := NewItem;

  AnswerKey := 5;
  Pause();
  AddMessage(step.ToString + ') ���������� COUNT �� 1:' + ' COUNT = ' +
    Count.ToString + ' + 1 = ' + IntToStr(Count + 1) + ';');
  Inc(Count);

  Finish();
end;

procedure TArrayList.DeleteTask();
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

Function TArrayList._Search(aName: integer): integer;
var
  i: integer;
begin
  result := 0;

  AddMessage(step.ToString + ') ����� ���������� ������������� ��������: ' +
    SearchItem.ToString + ';');

  // Pause();

  for i := 1 to Count do
  begin
    TempIndex := i;
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

procedure TArrayList.Finish();
begin
  // Pause();
  AddMessage('');
  State := lsNormal;
  TempIndex := -1;
  AddIndex := -1;
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
  // ���� ���������� ��������, �� ��������� ���.
  if Assigned(FOnThreadSuspended) then
    FOnThreadSuspended(Self);
end;

procedure TArrayList.GenericMyEvent;
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
