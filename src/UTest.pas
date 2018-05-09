unit UTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Generics.Collections, UArrayList;

type
  TFormTest = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    ListBox: TListBox;
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

implementation

{$R *.dfm}

uses UMain;

procedure TFormTest.Button1Click(Sender: TObject);
begin
  if ListBox.ItemIndex < 0 then
    exit;

  if ListBox.ItemIndex = rIndex then
    ShowMessage('�����')
  else
    ShowMessage('�������');
  close;
end;

// ��������� �� ����� ������� � ����������� �� ���� ��������: ����������/��������
procedure TFormTest.Load();
var
  i, index: integer;
  UniqueAnswer: TList<integer>;
  // ��������������� ������ ��� �������� ���������� ��������� �������
begin
  ListBox.Clear;
  Randomize;
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
          ListBox.Items.Add(AddAnswers[UniqueAnswer.Items[i]]);
        end;
        rIndex := Random(4);
        ListBox.Items[rIndex] := AddAnswers[ListArray.AnswerKey];
      end;
    lsDelete:
      begin

      end;
  end;
end;

end.
