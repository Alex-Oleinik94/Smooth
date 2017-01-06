{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex1;
	interface
{$ELSE}
	program Example1;
	{$ENDIF}
uses
	{$IFNDEF ENGINE}
		{$IFDEF UNIX}
			{$IFNDEF ANDROID}
				cthreads,
				{$ENDIF}
			{$ENDIF}
		SaGeBaseExample,
		{$ENDIF}
	SaGeCommonClasses
	,SaGeBased
	;
type
	TSGExample1=class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample1.ClassName():TSGString;
begin
Result := 'Пустой пример';
end;

constructor TSGExample1.Create(const VContext : ISGContext);
begin
inherited Create(VContext);

end;

destructor TSGExample1.Destroy();
begin
inherited;
end;

procedure TSGExample1.Paint();
begin

end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample1;
	RunApplication();
	{$ENDIF}
end.
