unit UStatistics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormStatistics = class(TForm)
    ListBoxResult: TListBox;
    Panel1: TPanel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormStatistics: TFormStatistics;

implementation

{$R *.dfm}

procedure TFormStatistics.Button1Click(Sender: TObject);
begin
  Close;
end;

end.
