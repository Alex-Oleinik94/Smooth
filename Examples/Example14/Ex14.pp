{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex14;
	interface
{$ELSE}
	program Example14;
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
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeRender
	,SaGeUtils
	,SaGeScreen
	;
type
	TSGExample14=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample14.ClassName():TSGString;
begin
Result := 'Shadow Mapping';
end;

constructor TSGExample14.Create(const VContext : TSGContext);
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
end;

destructor TSGExample14.Destroy();
begin
inherited;
end;

procedure TSGExample14.Draw();
begin
FCamera.CallAction();


end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample14;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
