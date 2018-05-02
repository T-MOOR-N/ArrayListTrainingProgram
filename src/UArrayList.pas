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

    // ���� ����������� �� ���������� ������� MyEvent.
    // ��� TNotifyEvent ������ � ������ Clases ���: TNotifyEvent = procedure(Sender: TObject) of object;
    // �����  "of object" ��������, ��� � �������� ����������� ����� ��������� ������ ����� ������-����
    // ������, � �� ������������ ���������.
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
  End;

implementation

uses
  UMain;

var
  CritSec: TCriticalSection; // ������ ����������� ������
  // ���������� ��� �������� ������� ���������� � ������� ����������
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
    Form1.Memo1.Lines.Add('���������� � ������ ������� �������� ' +
      IntToStr(NewItem) + ' (COUNT = ' + Count.ToString + ')');
    Pause();

    Form1.Memo1.Lines.Add('1) �������: ������� �������� ' + NewItem.ToString +
      ' � ������ [1];');
    Items[1] := NewItem;
    Pause();

    Form1.Memo1.Lines.Add('2) ���������� COUNT �� 1:' + ' COUNT = ' +
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

  Form1.Memo1.Lines.Add('������� � ������ ��������  ' + NewItem.ToString +
    ' ����� ' + SearchItem.ToString + ' (COUNT = ' + Count.ToString + ')');
  Pause();

  if Count = 0 then
    Finish();
  if Count = Max then
  begin
    Form1.Memo1.Lines.Add('1) �������� ����������� �������: ������ ��������;');
    Finish();
  end;

  Form1.Memo1.Lines.Add('1) �������� ����������� �������: ��;');
  Pause();

  j := _Search(SearchItem);
  if j = 0 then
    Finish();
  Inc(Count);

  Form1.Memo1.Lines.Add
    ('�) ����� ����� ������: ���������� ������ ���������� ����� ������� � ������ ['
    + (Count - 1).ToString + '];');
  Pause();

  for i := Count downto j do
  begin
    Items[i + 1] := Items[i];

    Form1.Memo1.Lines.Add
      ('�) ����� ������� ������: ���������� ���������� ������ [' + i.ToString +
      '] � ������ [' + (i + 1).ToString + '];');
    Pause();
  end;

  Items[j + 1] := NewItem;
  Form1.Memo1.Lines.Add('�) �������: ������� �������� ' + NewItem.ToString +
    ' � ������ [' + j.ToString + '];');
  Pause();

  Form1.Memo1.Lines.Add('2) ���������� COUNT �� 1:' + ' COUNT = ' +
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

  Form1.Memo1.Lines.Add('2) ����� ���������� ������������� ��������: ' +
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
      ') ���������� �����, ��������� ��������� ������: [' + i.ToString + '] <>'
      + SearchItem.ToString + ' , ��������� � ��������� ������;');
    Pause();
    Inc(counter);
  end;

  if result <> 0 then
  begin
    Form1.Memo1.Lines.Add(counter.ToString +
      ') ���������� �����, ��������� ��������� ������: ������� ������, [' +
      i.ToString + '] == ' + SearchItem.ToString + ' , ����� ������;');
    Pause();
  end
  else
  begin
    Form1.Memo1.Lines.Add(counter.ToString +
      ') ���������� �����, ��������� ��������� ������: ����� ������! ������� �� ������;');
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
  // ���� ���������� ��������, �� ��������� ���.
  if Assigned(FOnThreadSuspended) then
    FOnThreadSuspended(Self);
end;

procedure TArrayList.GenericMyEvent;
var
  MyEventIsOccurred: boolean;
begin
  MyEventIsOccurred := True;
  // ���� ����� ��������� �������, ������� ������������, ��� ������� MyEvent
  // ���������, �� ������ ������� ��������� ��������� ����������.
  if MyEventIsOccurred then
  begin
    DoMyEvent;
  end;
end;

{$ENDREGION}

end.
