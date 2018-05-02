program TrainingSimulator;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {Form1} ,
  UArrayList in 'UArrayList.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
