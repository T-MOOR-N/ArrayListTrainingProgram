unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.Menus, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.XPMan, UArrayList, WinProcs,
  UTest, UArrayPriorityQueue, UPriorityQueueItem, UEnumerations;

type
  TFormMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ComboBoxMode: TComboBox;
    ComboBoxStructure: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label3: TLabel;
    ButtonAddAfter: TButton;
    ButtonAddFirst: TButton;
    ButtonAddBefore: TButton;
    ButtonDelete: TButton;
    ButtonNext: TBitBtn;
    MyStringGrid: TStringGrid;
    StringGrid2: TStringGrid;
    ListBox: TListBox;
    ButtonClean: TButton;
    ButtonAdd: TButton;
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

implementation

{$R *.dfm}

procedure TFormMain.Updater();
var
  I, J: Integer;
begin
  if Assigned(ListArray) then
  begin
    ButtonAdd.Enabled := false;
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
        ButtonAddFirst.Enabled := true;
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
    ButtonAddAfter.Enabled := false;
    ButtonAddFirst.Enabled := false;
    ButtonAddBefore.Enabled := false;

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
      ButtonDelete.Enabled := false;
      ButtonNext.Enabled := true;
    end
    else
    begin
      if QueueArray.GetCount = 0 then
      begin
        ButtonDelete.Enabled := false;
        ButtonNext.Enabled := false;
      end;
      if QueueArray.GetCount > 0 then
      begin
        ButtonAdd.Enabled := true;
        ButtonDelete.Enabled := true;

        ButtonNext.Enabled := false;
      end;
      if ButtonNext.CanFocus then
        ButtonNext.SetFocus;

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
  end;
end;

procedure TFormMain.ButtonAddClick(Sender: TObject);
var
  sID, sPriority: string;
  iID, iPriority: Integer;
  Item: TPriorityQueueItem;
begin
  // перехватим конверсионные ошибки
  try
    sID := InputBox('Добавление нового элемента',
      'Введите идентификатор нового элемента', '5');

    Trim(sID);
    iID := StrToInt(sID);

    sPriority := InputBox('Добавление нового элемента',
      'Введите приоритет', '3');

    Trim(sPriority);
    iPriority := StrToInt(sPriority);

    Item := TPriorityQueueItem.Create(iID, iPriority);
    QueueArray.Add(Item);

    Inc(RowTemp);
  except
    on Exception: EConvertError do
      ShowMessage(Exception.Message);
  end;
end;

procedure TFormMain.ButtonAddAfterClick(Sender: TObject);
var
  sNewValue, sAfterValue: string;
  iNewValue, iAfterValue: Integer;
begin
  // перехватим конверсионные ошибки
  try
    sNewValue := InputBox('Добавление нового элемента',
      'Введите номер нового эламента', '5');

    Trim(sNewValue);
    iNewValue := StrToInt(sNewValue);

    sAfterValue := InputBox('Добавление нового элемента',
      'После какого добавить', '10');

    Trim(sAfterValue);
    iAfterValue := StrToInt(sAfterValue);

    ListArray.AddAfter(iNewValue, iAfterValue);

    Inc(RowTemp);
  except
    on Exception: EConvertError do
      ShowMessage(Exception.Message);
  end;
end;

procedure TFormMain.ButtonAddFirstClick(Sender: TObject);
var
  sValue: string;
  iValue: Integer;
begin
  sValue := InputBox('Добавление нового элемента', 'Введите номер', '5');

  // перехватим конверсионные ошибки
  try
    Trim(sValue);
    iValue := StrToInt(sValue);

    ListArray.AddFirst(iValue);
    Inc(RowTemp);
  except
    on Exception: EConvertError do
      ShowMessage(Exception.Message);
  end;
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
var
  sValue: string;
  iValue: Integer;
begin
  sValue := InputBox('Удаление элемента', 'Введите номер', '5');
  // перехватим конверсионные ошибки
  try
    Trim(sValue);
    iValue := StrToInt(sValue);

    if Assigned(ListArray) then
      ListArray.Delete(iValue);
    if Assigned(QueueArray) then
      QueueArray.Delete();
    Inc(RowTemp);
  except
    on Exception: EConvertError do
      ShowMessage(Exception.Message);
  end;
end;

procedure TFormMain.ButtonAddBeforeClick(Sender: TObject);
var
  sNewValue, sBeforeValue: string;
  iNewValue, iBeforeValue: Integer;
begin
  // перехватим конверсионные ошибки
  try
    sNewValue := InputBox('Добавление нового элемента',
      'Введите номер нового эламента', '5');

    Trim(sNewValue);
    iNewValue := StrToInt(sNewValue);

    sBeforeValue := InputBox('Добавление нового элемента',
      'Перед каким добавить', '10');

    Trim(sBeforeValue);
    iBeforeValue := StrToInt(sBeforeValue);

    ListArray.AddBefore(iNewValue, iBeforeValue);

    Inc(RowTemp);
  except
    on Exception: EConvertError do
      ShowMessage(Exception.Message);
  end;
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

  case ComboBoxStructure.ItemIndex of
    0:
      begin
        // неупорядоченный
        ListArray := TArrayList.Create;
        ListArray.Mode := Mode;
        // подписываемся на событие ThreadSyspended
        ListArray.OnThreadSyspended := OnThreadSyspended;

        QueueArray := nil;
      end;
    1:
      begin
        // упорядоченный
        QueueArray := TArrayPriorityQueue.Create;
        QueueArray.Mode := Mode;
        // подписываемся на событие ThreadSyspended
        QueueArray.OnThreadSyspended := OnThreadSyspended;

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

  Updater();
end;

end.
