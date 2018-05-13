unit UPriorityQueueItem;

interface

uses SysUtils;

Type
  TPriorityQueueItem = class
  Private
    ID: integer;
    Priority: integer;
  Public
    Constructor Create(iID, iPriority: integer);
    Function GetID: integer;
    Function GetPriority: integer;
    function ToString(): string; override;
  End;

implementation

Constructor TPriorityQueueItem.Create(iID, iPriority: integer);
begin
  ID := iID;
  Priority := iPriority;
end;

Function TPriorityQueueItem.GetID: integer;
begin
  result := ID;
end;

Function TPriorityQueueItem.GetPriority: integer;
begin
  result := Priority;
end;

function TPriorityQueueItem.ToString(): string;
begin
  result := ID.ToString + '(' + Priority.ToString + ')';
end;

end.
