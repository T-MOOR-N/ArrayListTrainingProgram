program ConsoleTestApp;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, UPriorityQueueItem, UArrayPriorityQueue;

var
  item1, item2, item3, item4: TPriorityQueueItem;
  list: TArrayPriorityQueue;

begin
  try
    list := TArrayPriorityQueue.Create();
    item1 := TPriorityQueueItem.Create(10, 5);
    item2 := TPriorityQueueItem.Create(2, 4);
    item3 := TPriorityQueueItem.Create(1, 5);
    item4 := TPriorityQueueItem.Create(3, 4);
    list.Add(item1);
    list.Add(item2);
    list.Add(item3);
    list.Add(item4);

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
