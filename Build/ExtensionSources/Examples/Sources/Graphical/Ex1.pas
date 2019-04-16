{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex1;
	interface
{$ELSE}
	program Example1;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SaGeBase
	,SaGeContextInterface
	,SaGeContextClasses
	{$IF not defined(ENGINE)}
		,SaGeConsolePaintableTools
		,SaGeConsoleToolsBase
		{$ENDIF}
	;
type
	TSGExample1=class(TSGPaintableObject)
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
	SGConsoleRunPaintable(TSGExample1, SGSystemParamsToConcoleCallerParams());
	{$ENDIF}
end.
