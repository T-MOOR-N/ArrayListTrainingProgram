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
  Inc(UMain.AllquestionsCount);

  if ListBoxAnswer.ItemIndex = rIndex then
  begin
    if Assigned(ListArray) then
    begin
      case ListArray.State of
        lsAddbefore:
          begin
            Inc(AddBeforeСorrectAnswer);
            Inc(AddBeforeQuestionsCount);
          end;
        lsAddAfter, lsAddFirst:
          begin
            Inc(AddAfterСorrectAnswer);
            Inc(AddAfterquestionsCount);
          end;
        lsDelete:
          begin
            Inc(DeleteCorrectAnswer);
            Inc(DeleteQuestionsCount);
          end;
      end;
    end;
    if Assigned(QueueArray) then
    begin
      case QueueArray.State of
        pqsAdd:
          begin
            Inc(AddСorrectAnswer);
            Inc(AddQuestionsCount);
          end;
        pqsDelete:
          begin
            Inc(DeleteCorrectAnswer);
            Inc(DeleteQuestionsCount);
          end;
      end;
    end;
    Inc(UMain.AllcorrectAnswer);
    IsCorrect := true;
  end
  // ShowMessage('верно')
  else
  begin
    IsCorrect := false;
    if Assigned(ListArray) then
    begin
      case ListArray.State of
        lsAddbefore:
          Inc(AddBeforeQuestionsCount);
        lsAddAfter:
          Inc(AddAfterquestionsCount);
        lsDelete:
          Inc(DeleteQuestionsCount);
      end;
    end;
    if Assigned(QueueArray) then
    begin
      case QueueArray.State of
        pqsAdd:
          Inc(AddQuestionsCount);
        pqsDelete:
          Inc(DeleteQuestionsCount);
      end;
    end;
  end;
  FormMain.StatusBar1.Panels[1].Text := UMain.AllcorrectAnswer.ToString + ' из '
    + UMain.AllquestionsCount.ToString;
  close;
end;

// загружает на форму вопросы в зависимости от типа операции: добавление/удаление
procedure TFormTest.Load();
var
  i, index: integer;
  UniqueAnswer: TList<integer>;
  // вспомогательный список для хранения уникальных индекссов ответов
begin
  ListBoxAnswer.Clear;
  Randomize;

  if Assigned(ListArray) then
  begin
    UniqueAnswer := TList<integer>.Create;
    // 0 - верный ключ
    case ListArray.State of
      lsAddAfter, lsAddbefore, lsAddFirst:
        begin
          for i := 0 to 3 do
            // генерируем случайные ключ ответа, пока не найдем уникальный
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
            // генерируем случайные ключ ответа, пока не найдем уникальный
            while UniqueAnswer.Count <> 4 do
            begin
              index := Random(7);
              if index <> ListArray.AnswerKey then
                if not UniqueAnswer.Contains(index) then
                  UniqueAnswer.Add(index)
            end;

          for i := 0 to 3 do
          begin
            ListBoxAnswer.Items.Add(UArrayList.DeleteAnswers
              [UniqueAnswer.Items[i]]);
          end;
          rIndex := Random(4);
          ListBoxAnswer.Items[rIndex] := UArrayList.DeleteAnswers
            [ListArray.AnswerKey];
        end;
    end;
  end;
  if Assigned(QueueArray) then
  begin
    UniqueAnswer := TList<integer>.Create;
    // 0 - верный ключ
    case QueueArray.State of
      pqsAdd:
        begin
          for i := 0 to 3 do
            // генерируем случайные ключ ответа, пока не найдем уникальный
            while UniqueAnswer.Count <> 4 do
            begin
              index := Random(7);
              if index <> QueueArray.AnswerKey then
                if not UniqueAnswer.Contains(index) then
                  UniqueAnswer.Add(index)
            end;

          for i := 0 to 3 do
          begin
            ListBoxAnswer.Items.Add(UArrayPriorityQueue.AddAnswers
              [UniqueAnswer.Items[i]]);
          end;
          rIndex := Random(4);
          ListBoxAnswer.Items[rIndex] := UArrayPriorityQueue.AddAnswers
            [QueueArray.AnswerKey];
        end;
      pqsDelete:
        begin
          for i := 0 to 3 do
            // генерируем случайные ключ ответа, пока не найдем уникальный
            while UniqueAnswer.Count <> 4 do
            begin
              index := Random(5);
              if index <> QueueArray.AnswerKey then
                if not UniqueAnswer.Contains(index) then
                  UniqueAnswer.Add(index)
            end;

          for i := 0 to 3 do
          begin
            ListBoxAnswer.Items.Add(UArrayPriorityQueue.DeleteAnswers
              [UniqueAnswer.Items[i]]);
          end;
          rIndex := Random(4);
          ListBoxAnswer.Items[rIndex] := UArrayPriorityQueue.DeleteAnswers
            [QueueArray.AnswerKey];
        end;
    end;
  end;
end;

end.
