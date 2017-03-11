{$INCLUDE SaGe.inc}

unit SaGeStaticString;

interface

uses
	 SaGeBase
	,SaGeFont
	,SaGeVertexObject
	,SaGeCommonClasses
	;

type
	TSGStaticString = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
		procedure Paint();override;
			private
		FMesh : TSG3DObject;
		FText : TSGString;
		FFont : TSGFont;
			public
		procedure SetText(const NewText : TSGString);
			public
		property Text : TSGString read FText write SetText;
		property Font : TSGFont   read FFont write FFont;
		end;

implementation

uses
	 SaGeRenderBase
	,SaGeCommon
	;

procedure TSGStaticString.Paint();
begin
if (FMesh<>nil) and (FFont<>nil) then
	begin
	Render.Color4f(1,1,1,1);
	FFont.BindTexture();
	FMesh.Paint();
	FFont.DisableTexture();
	end;
end;

constructor TSGStaticString.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FMesh := nil;
FText := '';
FFont := nil;
end;

procedure TSGStaticString.SetText(const NewText : TSGString);
var
	i, ii : TSGLongWord;
	DXShift : TSGSingle = 0;
begin
if (FFont = nil) then
	Exit;
if FMesh <> nil then
	begin
	FMesh.Destroy();
	FMesh:=nil;
	end;
FText := NewText;
if FText = '' then
	Exit;
if Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8] then
	DXShift := 0.5;
FMesh := TSG3DObject.Create();
FMesh.SetContext(Context);
FMesh.HasColors := False;
FMesh.ObjectPoligonesType:=SGR_TRIANGLES;
FMesh.ObjectColor:=SGColor4fFromUInt32($FFFFFFFF);
FMesh.EnableCullFace:=False;
FMesh.HasNormals:=False;
FMesh.QuantityFaceArrays := 0;
FMesh.HasTexture := True;
FMesh.Vertexes := 2*3*Length(FText);
ii := 0;
for i:=1 to Length(FText) do
	begin
	FMesh.ArVertex3f[(i-1)*6+0]^.Import(ii,0);
	FMesh.ArVertex3f[(i-1)*6+1]^.Import(ii+FFont.SimbolParams[FText[i]].Width,0);
	FMesh.ArVertex3f[(i-1)*6+2]^.Import(ii+FFont.SimbolParams[FText[i]].Width,FFont.FontHeight);
	FMesh.ArVertex3f[(i-1)*6+3]^:=FMesh.ArVertex3f[(i-1)*6+0]^;
	FMesh.ArVertex3f[(i-1)*6+4]^:=FMesh.ArVertex3f[(i-1)*6+2]^;
	FMesh.ArVertex3f[(i-1)*6+5]^.Import(ii,FFont.FontHeight);

	FMesh.ArTexVertex[(i-1)*6+0]^.Import(
		(FFont.SimbolParams[FText[i]].x+DXShift)/FFont.Width,
		1-(FFont.SimbolParams[FText[i]].y/FFont.Height));
	FMesh.ArTexVertex[(i-1)*6+1]^.Import(
		(FFont.SimbolParams[FText[i]].x+FFont.SimbolParams[FText[i]].Width+DXShift)/FFont.Width,
		1-(FFont.SimbolParams[FText[i]].y/FFont.Height));
	FMesh.ArTexVertex[(i-1)*6+2]^.Import(
		(FFont.SimbolParams[FText[i]].x+FFont.SimbolParams[FText[i]].Width+DXShift)/FFont.Width,
		1-((FFont.SimbolParams[FText[i]].y+FFont.FontHeight)/FFont.Height));
	FMesh.ArTexVertex[(i-1)*6+3]^:=FMesh.ArTexVertex[(i-1)*6+0]^;
	FMesh.ArTexVertex[(i-1)*6+4]^:=FMesh.ArTexVertex[(i-1)*6+2]^;
	FMesh.ArTexVertex[(i-1)*6+5]^.Import(
		(FFont.SimbolParams[FText[i]].x+DXShift)/FFont.Width,
		1-((FFont.SimbolParams[FText[i]].y+FFont.FontHeight)/FFont.Height));

	ii+=FFont.SimbolParams[FText[i]].Width;
	end;
FMesh.LoadToVBO();
end;

destructor TSGStaticString.Destroy();
begin
inherited;
end;

class function TSGStaticString.ClassName():TSGString;
begin
Result := 'TSGStaticString';
end;

end.
