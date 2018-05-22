program TrainingSimulator;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FormMain},
  UArrayList in 'UArrayList.pas',
  UTest in 'UTest.pas' {FormTest},
  UArrayPriorityQueue in 'UArrayPriorityQueue.pas',
  UPriorityQueueItem in 'UPriorityQueueItem.pas',
  UEnumerations in 'UEnumerations.pas',
  UStatistics in 'UStatistics.pas' {FormStatistics};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormTest, FormTest);
  Application.CreateForm(TFormStatistics, FormStatistics);
  Application.Run;

end.
