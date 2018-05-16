unit UTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Generics.Collections, UArrayList, UArrayPriorityQueue;

type
  TFormTest = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    ListBoxAnswer: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure Load();

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTest: TFormTest;
  rIndex: integer;
  IsCorrect: boolean;

implementation

{$R *.dfm}

uses UMain;

procedure TFormTest.Button1Click(Sender: TObject);
begin
  if ListBoxAnswer.ItemIndex < 0 then
    exit;
  Inc(UMain.questionsCount);
  if ListBoxAnswer.ItemIndex = rIndex then
  begin
    Inc(UMain.correctAnswer);
    IsCorrect := true;
  end
  // ShowMessage('�����')
  else
    IsCorrect := false;
  // FormMain.ListBox.Items[FormMain.ListBox.ItemIndex]
  // .Insert(2, '������! ���������: ');
  // ShowMessage('�������');

  FormMain.StatusBar1.Panels[1].Text := UMain.correctAnswer.ToString + ' �� ' +
    UMain.questionsCount.ToString;
  close;
end;

// ��������� �� ����� ������� � ����������� �� ���� ��������: ����������/��������
procedure TFormTest.Load();
var
  i, index: integer;
  UniqueAnswer: TList<integer>;
  // ��������������� ������ ��� �������� ���������� ��������� �������
begin
  ListBoxAnswer.Clear;
  Randomize;

  if Assigned(ListArray) then
  begin
    UniqueAnswer := TList<integer>.Create;
    // 0 - ������ ����
    case ListArray.State of
      lsAddAfter, lsAddbefore, lsAddFirst:
        begin
          for i := 0 to 3 do
            // ���������� ��������� ���� ������, ���� �� ������ ����������
            while UniqueAnswer.Count <> 4 do
            begin
              index := Random(7);
              if index <> ListArray.AnswerKey then
                if not UniqueAnswer.Contains(index) then
                  UniqueAnswer.Add(index)
            end;

          for i := 0 to 3 do
          begin
            ListBoxAnswer.Items.Add
              (UArrayList.AddAnswers[UniqueAnswer.Items[i]]);
          end;
          rIndex := Random(4);
          ListBoxAnswer.Items[rIndex] := UArrayList.AddAnswers
            [ListArray.AnswerKey];
        end;
      lsDelete:
        begin
          for i := 0 to 3 do
            // ���������� ��������� ���� ������, ���� �� ������ ����������
            while UniqueAnswer.Count <> 4 do
            begin
              index := Random(7);
              if index <> ListArray.AnswerKey then
                if not UniqueAnswer.Contains(index) then
                  UniqueAnswer.Add(index)
            end;

          for i := 0 to 3 do
          begin
            ListBoxAnswer.Items.Add(DeleteAnswers[UniqueAnswer.Items[i]]);
          end;
          rIndex := Random(4);
          ListBoxAnswer.Items[rIndex] := DeleteAnswers[ListArray.AnswerKey];
        end;
    end;
  end;
  if Assigned(QueueArray) then
  begin
    UniqueAnswer := TList<integer>.Create;
    // 0 - ������ ����
    case QueueArray.State of
      pqsAdd:
        begin
          for i := 0 to 3 do
            // ���������� ��������� ���� ������, ���� �� ������ ����������
            while UniqueAnswer.Count <> 4 do
            begin
              index := Random(7);
              if index <> QueueArray.AnswerKey then
                if not UniqueAnswer.Contains(index) then
                  UniqueAnswer.Add(index)
            end;

          for i := 0 to 3 do
          begin
            ListBoxAnswer.Items.Add(AddAnswers[UniqueAnswer.Items[i]]);
          end;
          rIndex := Random(4);
          ListBoxAnswer.Items[rIndex] := AddAnswers[QueueArray.AnswerKey];
        end;
      pqsDelete:
        begin
          for i := 0 to 3 do
            // ���������� ��������� ���� ������, ���� �� ������ ����������
            while UniqueAnswer.Count <> 4 do
            begin
              index := Random(5);
              if index <> QueueArray.AnswerKey then
                if not UniqueAnswer.Contains(index) then
                  UniqueAnswer.Add(index)
            end;

          for i := 0 to 3 do
          begin
            ListBoxAnswer.Items.Add(DeleteAnswers[UniqueAnswer.Items[i]]);
          end;
          rIndex := Random(4);
          ListBoxAnswer.Items[rIndex] := DeleteAnswers[QueueArray.AnswerKey];
        end;
    end;
  end;
end;

end.
