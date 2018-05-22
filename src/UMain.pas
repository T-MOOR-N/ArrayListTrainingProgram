unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.Menus, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.XPMan, UArrayList, WinProcs,
  UTest, UArrayPriorityQueue, UPriorityQueueItem, UEnumerations,
  Vcl.Samples.Spin, Vcl.ComCtrls, System.UITypes;

type
  TFormMain = class(TForm)
    Panel1: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MyStringGrid: TStringGrid;
    ComboBoxStructure: TComboBox;
    PanelListArray: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    ButtonAddAfter: TButton;
    ButtonAddFirst: TButton;
    ButtonAddBefore: TButton;
    ButtonDelete: TButton;
    ButtonNext: TBitBtn;
    ButtonClean: TButton;
    SpinEditListID1: TSpinEdit;
    SpinEditListID2: TSpinEdit;
    ComboBoxMode: TComboBox;
    StringGrid2: TStringGrid;
    ListBox: TListBox;
    PanelPriorityQueue: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    ButtonDelete2: TButton;
    ButtonNext2: TBitBtn;
    ButtonClean2: TButton;
    ButtonAdd: TButton;
    SpinEditPriority: TSpinEdit;
    SpinEditID: TSpinEdit;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure ComboBoxStructureChange(Sender: TObject);
    procedure ComboBoxModeChange(Sender: TObject);
    procedure ButtonAddFirstClick(Sender: TObject);
    // Обработчик события MyEvent для объектов, принадлежащих типу TMyClass.
    procedure OnThreadSyspended(Sender: TObject);
    procedure ButtonNextClick(Sender: TObject);
    procedure ButtonAddAfterClick(Sender: TObject);
    procedure ButtonAddBeforeClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure MyStringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Updater();
    procedure ButtonCleanClick(Sender: TObject);
    procedure ComboBoxModeSelect(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;
  ListArray: TArrayList;
  QueueArray: TArrayPriorityQueue;
  RowTemp: Integer;
  Mode: TOperatingMode = TOperatingMode.omDemo;

  // блок переменных для хранения статистики
  // по всем вопросам
  AddQuestionsCount: Integer = 0;
  AddAfterquestionsCount: Integer = 0;
  AddBeforeQuestionsCount: Integer = 0;
  DeleteQuestionsCount: Integer = 0;
  AllQuestionsCount: Integer = 0;

  // по верным ответам
  AddСorrectAnswer: Integer = 0;
  AddAfterСorrectAnswer: Integer = 0;
  AddBeforeСorrectAnswer: Integer = 0;
  DeleteCorrectAnswer: Integer = 0;
  AllcorrectAnswer: Integer = 0;

implementation

{$R *.dfm}

uses UStatistics;

procedure ResetCounters;
begin
  AddСorrectAnswer := 0;
  AddAfterСorrectAnswer := 0;
  AddBeforeСorrectAnswer := 0;
  DeleteCorrectAnswer := 0;
  AllcorrectAnswer := 0;

  AddQuestionsCount := 0;
  AddAfterquestionsCount := 0;
  AddBeforeQuestionsCount := 0;
  DeleteQuestionsCount := 0;
  AllQuestionsCount := 0;

end;

procedure TFormMain.Updater();
var
  I, J: Integer;
begin
  if Assigned(ListArray) then
  begin
    ButtonAddFirst.Enabled := true;

    ListBox.ItemIndex := ListBox.Items.Count - 1;
    if ListBox.ItemIndex > 0 then
      if ListBox.Items[ListBox.ItemIndex] = '' then
        ListBox.ItemIndex := -1;

    if MyStringGrid.RowCount < RowTemp + 1 then
      MyStringGrid.RowCount := RowTemp + 1;

    if not(ListArray.State = lsNormal) then
    begin
      ButtonAddAfter.Enabled := false;
      ButtonAddFirst.Enabled := false;
      ButtonAddBefore.Enabled := false;
      ButtonDelete.Enabled := false;
      ButtonNext.Enabled := true;
    end
    else
    begin
      if ListArray.GetCount = 0 then
        ButtonAddFirst.Enabled := true
      else
        ButtonAddFirst.Enabled := false;
      if ListArray.GetCount > 0 then
      begin
        ButtonAddAfter.Enabled := true;
        ButtonAddBefore.Enabled := true;
        ButtonDelete.Enabled := true;
      end;
      ButtonNext.Enabled := false;
    end;
    if ButtonNext.CanFocus then
      ButtonNext.SetFocus;

    // костыль для восстановления цвета ячеек
    if ListArray.State = lsNormal then
    begin
      for I := 0 to MyStringGrid.ColCount do
        for J := 0 to MyStringGrid.RowCount do
          MyStringGrid.Cells[I, J] := MyStringGrid.Cells[I, J];
    end;
  end;

  if Assigned(QueueArray) then
  begin

    ButtonAdd.Enabled := true;
    ListBox.ItemIndex := ListBox.Items.Count - 1;
    if ListBox.ItemIndex > 0 then
      if ListBox.Items[ListBox.ItemIndex] = '' then
        ListBox.ItemIndex := -1;

    if MyStringGrid.RowCount < RowTemp + 1 then
      MyStringGrid.RowCount := RowTemp + 1;

    if not(QueueArray.State = pqsNormal) then
    begin
      ButtonAdd.Enabled := false;
      ButtonDelete2.Enabled := false;
      ButtonNext2.Enabled := true;
    end
    else
    begin
      if QueueArray.GetCount = 0 then
      begin
        ButtonDelete2.Enabled := false;
        ButtonNext2.Enabled := false;
      end;
      if QueueArray.GetCount > 0 then
      begin
        ButtonAdd.Enabled := true;
        ButtonDelete2.Enabled := true;

        ButtonNext2.Enabled := false;
      end;
      if ButtonNext2.CanFocus then
        ButtonNext2.SetFocus;

      // костыль для восстановления цвета ячеек
      if QueueArray.State = pqsNormal then
      begin
        for I := 0 to MyStringGrid.ColCount do
          for J := 0 to MyStringGrid.RowCount do
            MyStringGrid.Cells[I, J] := MyStringGrid.Cells[I, J];
      end;
    end;

  end;
end;

// Обработчик события ThreadSyspended  - когда отсановили поток
procedure TFormMain.OnThreadSyspended(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(ListArray) then
    for I := 1 to ListArray.GetMaxCount do
      MyStringGrid.Cells[I - 1, RowTemp] := ListArray.GetItem(I);

  if Assigned(QueueArray) then
    for I := 1 to QueueArray.GetMaxCount do
      MyStringGrid.Cells[I - 1, RowTemp] := QueueArray.GetItem(I);

  Updater();
end;

procedure TFormMain.MyStringGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  txt: string;
begin
  // центруем текст в ячейках
  with MyStringGrid do
  begin
    Canvas.Brush.Color := clWindow;
    if Assigned(ListArray) then
    begin
      if ListArray.temp <> -1 then
        if (ARow = RowTemp) and (ACol = ListArray.temp - 1) then
          Canvas.Brush.Color := clSkyBlue;
      if ListArray.Add <> -1 then
        if (ARow = RowTemp) and (ACol = ListArray.Add - 1) then
          Canvas.Brush.Color := clSilver;
    end;
    if Assigned(QueueArray) then
    begin
      if QueueArray.TempIndex <> -1 then
        if (ARow = RowTemp) and (ACol = QueueArray.TempIndex - 1) then
          Canvas.Brush.Color := clSkyBlue;
      if QueueArray.AddIndex <> -1 then
        if (ARow = RowTemp) and (ACol = QueueArray.AddIndex - 1) then
          Canvas.Brush.Color := clSilver;
    end;

    txt := Cells[ACol, ARow];
    Canvas.FillRect(Rect);
    Canvas.TextRect(Rect, txt, [tfVerticalCenter, tfCenter, tfSingleLine]);
  end;
end;

procedure TFormMain.ButtonNextClick(Sender: TObject);
begin
  if Assigned(ListArray) then
  begin
    case ListArray.Mode of
      omControl:
        begin
          // заполнение формы с вопросами
          FormTest.Load;
          FormTest.ShowModal;
        end;
    end;
    ListArray.NextStep;
    if ListArray.IsMove then
      Inc(RowTemp);
    if ListArray.Mode = omControl then
      if not UTest.IsCorrect then
        ListBox.Items[ListBox.ItemIndex + 1] := 'Ошибка! Правильно: ';
  end;
  if Assigned(QueueArray) then
  begin
    case QueueArray.Mode of
      omControl:
        begin
          // заполнение формы с вопросами
          FormTest.Load;
          FormTest.ShowModal;
        end;
    end;
    QueueArray.NextStep;
    if QueueArray.IsMove then
      Inc(RowTemp);
    if QueueArray.Mode = omControl then
      if not UTest.IsCorrect then
        ListBox.Items[ListBox.ItemIndex + 1] := 'Ошибка! Правильно: ';
  end;

end;

procedure TFormMain.ButtonAddClick(Sender: TObject);
var
  Item: TPriorityQueueItem;
begin
  Item := TPriorityQueueItem.Create(SpinEditID.Value, SpinEditPriority.Value);
  QueueArray.Add(Item);

  Inc(RowTemp);
end;

procedure TFormMain.ButtonAddAfterClick(Sender: TObject);
begin
  if ListArray.Contains(SpinEditListID1.Value) then
  begin
    MessageDlg('Ошибка! Список уже содержит ключ: ' +
      SpinEditListID1.Value.ToString, mtError, mbOKCancel, 0);
    exit;
  end;

  ListArray.AddAfter(SpinEditListID1.Value, SpinEditListID2.Value);
  Inc(RowTemp);
end;

procedure TFormMain.ButtonAddFirstClick(Sender: TObject);
begin
  ListArray.AddFirst(SpinEditListID1.Value);
  Inc(RowTemp);
end;

procedure TFormMain.ButtonCleanClick(Sender: TObject);
var
  I: Integer;
  J: Integer;
begin
  for I := 0 to MyStringGrid.ColCount do
    for J := 0 to MyStringGrid.RowCount do
      MyStringGrid.Cells[I, J] := '';
  RowTemp := 0;
  OnThreadSyspended(Sender);
end;

procedure TFormMain.ButtonDeleteClick(Sender: TObject);
begin
  if Assigned(ListArray) then
    ListArray.Delete(SpinEditListID1.Value);
  if Assigned(QueueArray) then
    QueueArray.Delete();
  Inc(RowTemp);
end;

procedure TFormMain.ButtonAddBeforeClick(Sender: TObject);
begin
  if ListArray.Contains(SpinEditListID1.Value) then
  begin
    MessageDlg('Ошибка! Список уже содержит ключ: ' +
      SpinEditListID1.Value.ToString, mtError, mbOKCancel, 0);
    exit;
  end;

  ListArray.AddBefore(SpinEditListID1.Value, SpinEditListID2.Value);
  Inc(RowTemp);
end;

// смена структуры
procedure TFormMain.ComboBoxStructureChange(Sender: TObject);
begin
  case ComboBoxStructure.ItemIndex of
    0:
      begin
        ComboBoxMode.Enabled := true;
        FormCreate(Self);
      end;
    1:
      begin
        FormCreate(Self);
      end;
  end;

end;

// смена режима
procedure TFormMain.ComboBoxModeChange(Sender: TObject);
begin
  if ComboBoxMode.ItemIndex = 0 then
    ButtonDelete.Enabled := true;
  ButtonAddFirst.Enabled := true;
  ButtonAddBefore.Enabled := true;
  ButtonAddAfter.Enabled := true;
  ButtonNext.Enabled := true;

  if ComboBoxMode.ItemIndex = 0 then
    Mode := omDemo;
  if ComboBoxMode.ItemIndex = 1 then
    Mode := omControl;
  FormCreate(Self);
end;

procedure TFormMain.ComboBoxModeSelect(Sender: TObject);
begin
  if ComboBoxMode.ItemIndex = 0 then
    Mode := omDemo;
  if ComboBoxMode.ItemIndex = 1 then
    Mode := omControl;
  FormCreate(Self);
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  if Mode <> omControl then
    exit;

  if Assigned(ListArray) then
  begin
    if AddBeforeQuestionsCount > 0 then
      FormStatistics.ListBoxResult.Items.Add('Вставка ДО в список: верно ' +
        AddBeforeСorrectAnswer.ToString + ' из ' +
        AddBeforeQuestionsCount.ToString);
    if AddAfterquestionsCount > 0 then
      FormStatistics.ListBoxResult.Items.Add('Вставка После в список: верно ' +
        AddAfterСorrectAnswer.ToString + ' из ' +
        AddAfterquestionsCount.ToString);
    if DeleteQuestionsCount > 0 then
      FormStatistics.ListBoxResult.Items.Add('Удаление из списка: верно ' +
        DeleteCorrectAnswer.ToString + ' из ' + DeleteQuestionsCount.ToString);
  end;

  if Assigned(QueueArray) then
  begin
    if AddQuestionsCount > 0 then
      FormStatistics.ListBoxResult.Items.Add('Вставка в очередь: верно ' +
        AddСorrectAnswer.ToString + ' из ' + AddQuestionsCount.ToString);
    if DeleteQuestionsCount > 0 then
      FormStatistics.ListBoxResult.Items.Add('Удаление из очереди: верно ' +
        DeleteCorrectAnswer.ToString + ' из ' + DeleteQuestionsCount.ToString);
  end;

  FormStatistics.ListBoxResult.Items.Add('ИТОГО:');
  FormStatistics.ListBoxResult.Items.Add('Всего выполнено:' +
    AllQuestionsCount.ToString);
  FormStatistics.ListBoxResult.Items.Add('Из них верно:' +
    AllcorrectAnswer.ToString);

  FormStatistics.ShowModal;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  myRect: TGridRect;
  I: Integer;
  J: Integer;
begin
  // очистка стриггрида
  for I := 0 to MyStringGrid.ColCount do
    for J := 0 to MyStringGrid.RowCount do
      MyStringGrid.Cells[I, J] := '';

  // сброс счётчиков статистики
  ResetCounters;

  case ComboBoxStructure.ItemIndex of
    0:
      begin
        // неупорядоченный
        ListArray := TArrayList.Create;
        ListArray.Mode := Mode;
        // подписываемся на событие ThreadSyspended
        ListArray.OnThreadSyspended := OnThreadSyspended;

        PanelListArray.Visible := true;
        PanelPriorityQueue.Visible := false;
        QueueArray := nil;

      end;
    1:
      begin
        // упорядоченный
        QueueArray := TArrayPriorityQueue.Create;
        QueueArray.Mode := Mode;
        // подписываемся на событие ThreadSyspended
        QueueArray.OnThreadSyspended := OnThreadSyspended;

        PanelListArray.Visible := false;
        PanelPriorityQueue.Visible := true;
        ListArray := nil;
      end;
  end;

  RowTemp := -1;

  ButtonDelete.Enabled := false;

  // ComboBoxMode.Enabled := false;

  StringGrid2.Cells[0, 0] := '1';
  StringGrid2.Cells[1, 0] := '2';
  StringGrid2.Cells[2, 0] := '3';
  StringGrid2.Cells[3, 0] := '4';
  StringGrid2.Cells[4, 0] := '5';
  StringGrid2.Cells[5, 0] := '6';
  MyStringGrid.Options := MyStringGrid.Options - [goEditing];
  StringGrid2.Options := MyStringGrid.Options - [goEditing];
  StringGrid2.Options := MyStringGrid.Options - [goDrawFocusSelected,
    goRowMoving, goColMoving, goRowSelect];
  with myRect do
  begin
    Left := -1;
    Top := -1;
    Right := -1;
    Bottom := -1;
  end;
  StringGrid2.Selection := myRect;
  MyStringGrid.Selection := myRect;

  if Mode = omControl then
    StatusBar1.Visible := true
  else
    StatusBar1.Visible := false;
  Updater();
end;

end.
