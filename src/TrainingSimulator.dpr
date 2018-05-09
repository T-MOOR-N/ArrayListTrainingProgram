program TrainingSimulator;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FormMain},
  UArrayList in 'UArrayList.pas',
  UTest in 'UTest.pas' {FormTest};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormTest, FormTest);
  Application.Run;

end.
