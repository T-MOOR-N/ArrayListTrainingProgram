unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.Menus, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.XPMan, UArrayList;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Memo1: TMemo;
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
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  List: TArrayList;
  RowTemp: integer;

implementation

{$R *.dfm}

// Обработчик события ThreadSyspended  - когда отсановили поток
procedure TForm1.OnThreadSyspended(Sender: TObject);
var
  i: integer;
begin
  // if not(Sender is TArrayList) then
  // Exit;
  for i := 1 to List.GetMaxCount do
    StringGrid1.Cells[i - 1, RowTemp] := List.GetItem(i);
end;

procedure TForm1.ButtonNextClick(Sender: TObject);
var
  i: integer;
begin
  for i := 1 to List.GetCount do
    StringGrid1.Cells[i - 1, RowTemp] := List.GetItem(i);
end;

procedure TForm1.ButtonAddAfterClick(Sender: TObject);
var
  sNewValue, sAfterValue: string;
  iNewValue, iAfterValue: integer;
begin
  // перехватим конверсионные ошибки
  try
    sNewValue := InputBox('Добавление нового элемента',
      'Введите номер нового эламента', '5');

    Trim(sNewValue);
    iNewValue := StrToInt(sNewValue);

    sAfterValue := InputBox('Добавление нового элемента',
      'Перед каким добавить', '10');

    Trim(sAfterValue);
    iAfterValue := StrToInt(sAfterValue);

    List.AddAfter(iNewValue, iAfterValue);

    Inc(RowTemp);
  except
    on Exception: EConvertError do
      ShowMessage(Exception.Message);
  end;
end;

procedure TForm1.ButtonAddFirstClick(Sender: TObject);
var
  sValue: string;
  iValue: integer;
begin
  sValue := InputBox('Добавление нового элемента', 'Введите номер', '5');

  // перехватим конверсионные ошибки
  try
    Trim(sValue);
    iValue := StrToInt(sValue);

    List.AddFirst(iValue);
    Inc(RowTemp);
  except
    on Exception: EConvertError do
      ShowMessage(Exception.Message);
  end;
end;

procedure TForm1.ButtonDeleteClick(Sender: TObject);
var
  sValue: string;
  iValue: integer;
begin
  sValue := InputBox('Удаление элемента', 'Введите номер', '5');
  // перехватим конверсионные ошибки
  try
    Trim(sValue);
    iValue := StrToInt(sValue);

    List.Delete(iValue);
    Inc(RowTemp);
  except
    on Exception: EConvertError do
      ShowMessage(Exception.Message);
  end;
end;

procedure TForm1.ButtonAddBeforeClick(Sender: TObject);
var
  sNewValue, sBeforeValue: string;
  iNewValue, iBeforeValue: integer;
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

    List.AddBefore(iNewValue, iBeforeValue);

    Inc(RowTemp);
  except
    on Exception: EConvertError do
      ShowMessage(Exception.Message);
  end;
end;

procedure TForm1.ComboBoxStructureChange(Sender: TObject);
begin
  if ComboBoxStructure.ItemIndex = 0 then
    ComboBoxMode.Enabled := true;

end;

procedure TForm1.ComboBoxModeChange(Sender: TObject);
begin
  if ComboBoxMode.ItemIndex = 0 then
    ButtonDelete.Enabled := true;
  ButtonAddFirst.Enabled := true;
  ButtonAddBefore.Enabled := true;
  ButtonAddAfter.Enabled := true;
  ButtonNext.Enabled := true;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  myRect: TGridRect;
begin

  List := TArrayList.Create;
  // подписываемся на событие ThreadSyspended
  List.OnThreadSyspended := OnThreadSyspended;

  RowTemp := -1;

  ButtonDelete.Enabled := false;

  ComboBoxMode.Enabled := false;

  StringGrid2.Cells[0, 0] := '1';
  StringGrid2.Cells[1, 0] := '2';
  StringGrid2.Cells[2, 0] := '3';
  StringGrid2.Cells[3, 0] := '4';
  StringGrid2.Cells[4, 0] := '5';
  StringGrid2.Cells[5, 0] := '6';
  StringGrid1.Options := StringGrid1.Options - [goEditing];
  StringGrid2.Options := StringGrid1.Options - [goEditing];
  StringGrid2.Options := StringGrid1.Options - [goDrawFocusSelected,
    goRowMoving, goColMoving, goRowSelect];
  with myRect do
  begin
    Left := -1;
    Top := -1;
    Right := -1;
    Bottom := -1;
  end;
  StringGrid2.Selection := myRect;
  StringGrid1.Selection := myRect;
end;

end.
