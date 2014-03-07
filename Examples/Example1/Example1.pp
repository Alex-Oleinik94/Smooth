{$INCLUDE SaGe.inc}
program Example1;
uses
	{$IFDEF UNIX}
		{$IFNDEF ANDROID}
			cthreads,
			{$ENDIF}
		{$ENDIF}
	SaGeContext
	,SaGeBased
	,SaGeBaseExample
	;
type
	TSGExample1=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
		end;

class function TSGExample1.ClassName():TSGString;
begin
Result := 'Пустой пример';
end;

constructor TSGExample1.Create(const VContext : TSGContext);
begin
inherited Create(VContext);

end;

destructor TSGExample1.Destroy();
begin
inherited;
end;

procedure TSGExample1.Draw();
begin

end;

begin
ExampleClass := TSGExample1;
RunApplication();
end.
