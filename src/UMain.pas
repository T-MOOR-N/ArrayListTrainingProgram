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
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    ComboBox1: TComboBox;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    tht1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    Panel3: TPanel;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button1: TButton;
    ComboBox2: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    BitBtn1: TBitBtn;
    StringGrid2: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    function Add: integer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  List: TArrayList;

implementation

{$R *.dfm}

function TForm1.Add: integer;
var
  i, j, row: integer;
  flag: boolean;
begin
  // with StringGrid1 do
  // for i := 0 to RowCount - 1 do
  // begin
  // flag := true;
  // for j := 0 to ColCount - 1 do
  // if Cells[j, i] <> '' then
  // begin
  // flag := false;
  // break;
  // end;
  // if flag = true then
  // begin
  // break;
  // end;
  // end;
  // if flag = true then
  // begin
  // row := i;
  // result := row;
  // end
  // else
  // result := -1;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  t: integer;
var
  rowIndex, j: integer;
  k: string;
  El: TArrayList;
  a, m, n: integer;
begin
  // rowIndex := Add;
  // if rowIndex = -1 then
  // begin
  // showMessage('Отсутствуют свободные строки!');
  // exit;
  // end;
  //
  // a := 0;
  // with StringGrid1 do
  // for j := 0 to ColCount - 1 do
  //
  // begin
  // a := a + 1;
  // k := InputBox('Новый элемент', 'Введите значение элемента:', '1');
  // El := TArrayList.Create(k);
  // LElement[a] := El;
  // Cells[j, rowIndex] := LElement[a].GetInfo;
  //
  // end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if ComboBox1.ItemIndex = 0 then
    ComboBox2.Enabled := true;

end;

procedure TForm1.ComboBox2Change(Sender: TObject);
begin
  if ComboBox2.ItemIndex = 0 then
    Button1.Enabled := true;
  Button7.Enabled := true;
  Button8.Enabled := true;
  Button6.Enabled := true;
  BitBtn1.Enabled := true;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  myRect: TGridRect;
begin

  List := TArrayList.Create;

  Button1.Enabled := false;
  Button7.Enabled := false;
  Button8.Enabled := false;
  Button6.Enabled := false;
  BitBtn1.Enabled := false;
  ComboBox2.Enabled := false;

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
