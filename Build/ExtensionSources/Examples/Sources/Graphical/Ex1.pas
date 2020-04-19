{$INCLUDE Smooth.inc}
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
	 SmoothBase
	,SmoothContextInterface
	,SmoothContextClasses
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	;
type
	TSExample1 = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSExample1.ClassName():TSString;
begin
Result := 'Пустой пример';
end;

constructor TSExample1.Create(const VContext : ISContext);
begin
inherited Create(VContext);

end;

destructor TSExample1.Destroy();
begin
inherited;
end;

procedure TSExample1.Paint();
begin

end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample1, SSystemParamsToConsoleHandlerParams());
	{$ENDIF}
end.
