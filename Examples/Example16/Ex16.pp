{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex16;
	interface
{$ELSE}
	program Example16;
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
	,SaGeBase
	,SaGeUtils
	,SaGeRenderConstants
	,SaGeCommon
	,crt
	,SaGeScreen
	,SaGeMesh
	,SaGeShaders
	,SaGePhysics
	,SaGeImages
	,Math
	;

type
	TSGExample16 = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FFont : TSGFont;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample16.ClassName():TSGString;
begin
Result := 'Фрактальный ландшафт';
end;

constructor TSGExample16.Create(const VContext : ISGContext);
begin
FFont := nil;
FCamera := nil;

inherited Create(VContext);

FFont:=TSGFont.Create(SGFontDirectory+Slash+{$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF});
FFont.SetContext(Context);
FFont.Loading();
FFont.ToTexture();

FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FCamera.ViewMode := SG_VIEW_LOOK_AT_OBJECT;
FCamera.ChangingLookAtObject := False;
FCamera.Up       := SGVertex3fImport(0,0,1);
FCamera.Location := SGVertex3fImport(0,-350,100);
FCamera.View     := (SGVertex3fImport(0,0,0)-FCamera.Location).Normalized();
FCamera.Location := FCamera.Location;
end;

destructor TSGExample16.Destroy();
begin
if FFont <> nil then
	begin
	FFont.Destroy();
	FFont := nil;
	end;
if FCamera <> nil then
	begin
	FCamera .Destroy();
	FCamera := nil;
	end;
inherited;
end;

procedure TSGExample16.Paint();
begin

end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample16;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
