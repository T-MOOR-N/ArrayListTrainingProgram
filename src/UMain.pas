unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.Menus, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.XPMan, UArrayList, WinProcs,
  UTest;

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

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;
  ListArray: TArrayList;
  RowTemp: Integer;

implementation

{$R *.dfm}

procedure TFormMain.Updater();
var
  I, J: Integer;
begin
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

// Обработчик события ThreadSyspended  - когда отсановили поток
procedure TFormMain.OnThreadSyspended(Sender: TObject);
var
  I: Integer;
begin
  // if not(Sender is TArrayList) then
  // Exit;
  for I := 1 to ListArray.GetMaxCount do
    MyStringGrid.Cells[I - 1, RowTemp] := ListArray.GetItem(I);
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

    if ListArray.temp <> -1 then
      if (ARow = RowTemp) and (ACol = ListArray.temp - 1) then
        Canvas.Brush.Color := clSkyBlue;
    if ListArray.Add <> -1 then
      if (ARow = RowTemp) and (ACol = ListArray.Add - 1) then
        Canvas.Brush.Color := clSilver;

    txt := Cells[ACol, ARow];
    Canvas.FillRect(Rect);
    Canvas.TextRect(Rect, txt, [tfVerticalCenter, tfCenter, tfSingleLine]);
  end;
end;

procedure TFormMain.ButtonNextClick(Sender: TObject);
// var
// i: integer;
// begin
// for i := 1 to List.GetCount do
// StringGrid1.Cells[i - 1, RowTemp] := List.GetItem(i);
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

    ListArray.Delete(iValue);
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

procedure TFormMain.ComboBoxStructureChange(Sender: TObject);
begin
  if ComboBoxStructure.ItemIndex = 0 then
    ComboBoxMode.Enabled := true;

end;

procedure TFormMain.ComboBoxModeChange(Sender: TObject);
begin
  if ComboBoxMode.ItemIndex = 0 then
    ButtonDelete.Enabled := true;
  ButtonAddFirst.Enabled := true;
  ButtonAddBefore.Enabled := true;
  ButtonAddAfter.Enabled := true;
  ButtonNext.Enabled := true;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  myRect: TGridRect;
begin

  ListArray := TArrayList.Create;
  ListArray.Mode:= omDemo;
  // подписываемся на событие ThreadSyspended
  ListArray.OnThreadSyspended := OnThreadSyspended;

  RowTemp := -1;

  ButtonDelete.Enabled := false;

  ComboBoxMode.Enabled := false;

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
