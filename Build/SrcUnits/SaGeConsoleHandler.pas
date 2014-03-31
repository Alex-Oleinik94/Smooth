{$I Includes\SaGe.inc}

unit SaGeConsoleHandler;

interface

uses 
	SaGeBased;

Type 
	TSGConsoleHandler = class
			protected
		Parameters: packed array of TSGString;
				
			public
		constructor Create();
		destructor Destroy();
			
			public
		procedure Add(Arg: TSGString);
		procedure Run();
		
			public
		function Search(Arg: TSGString): TSGBoolean;
		end;

implementation

constructor TSGConsoleHandler.Create();
begin
inherited;
end;

destructor TSGConsoleHandler.Destroy();
begin
inherited;
end;		

function TSGConsoleHandler.Search(Arg: TSGString): TSGBoolean;
var i: TSGLongWord;
begin
result := false;
i := 0;
while (not result and (i <= high(Parameters))) do begin
	if (Arg = Parameters[i].Arg) then
   		result := true;
   	inc(i);
end;
end;

procedure TSGConsoleHandler.Run();
var i: TSGLongWord;
begin
for i := 2 to argc - 1 do
	if (not Search(argv[i])) then
   	{$IFDEF SGDebuging}
   		writeln('Console: Parameter "', argv[i],'" is not found')
   	{$ENDIF};
end;

procedure TSGConsoleHandler.Add(Arg: TSGString);
begin
 SetLength(Parameters, Length(Parameters) + 1);
 Parameters[high(Parameters)] := Arg;
end;

end.
