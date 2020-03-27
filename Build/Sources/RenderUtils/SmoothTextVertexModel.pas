{$INCLUDE Smooth.inc}

unit SmoothTextVertexModel;

interface

uses
	 SmoothBase
	,SmoothFont
	,SmoothVertexObject
	,SmoothCommonClasses
	,SmoothCommonStructs
	;

type
	TSTextVertexModelSymbol = object
			public
		Vectors : packed array [0..3] of TSVector3f;
		TextVectors : packed array [0..3] of TSVector2f;
		Color : TSVector4f;
		end;
	
	TSTextVertexModel = class(TSDrawable)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
		procedure Paint();override;
			private
		FMesh : TS3DObject;
		FText : TSString;
		FFont : TSFont;
		FUseColors : TSBoolean;
			protected
		procedure SetSymbol(const SymbolNumber : TSMaxEnum; const Symbol : TSTextVertexModelSymbol);
		procedure SetText(const NewText : TSString);
			public
		property Text : TSString read FText write SetText;
		property Font : TSFont   read FFont write FFont;
		end;

procedure SKill(var StaticString : TSTextVertexModel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothRenderBase
	,SmoothCommon
	;

procedure SKill(var StaticString : TSTextVertexModel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (StaticString <> nil) then
	begin
	StaticString.Destroy();
	StaticString := nil;
	end;
end;

procedure TSTextVertexModel.Paint();
begin
if (FMesh<>nil) and (FFont<>nil) then
	begin
	if (not FUseColors) then
		Render.Color4f(1, 1, 1, 1);
	FFont.BindTexture();
	FMesh.Paint();
	FFont.DisableTexture();
	end;
end;

constructor TSTextVertexModel.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FMesh := nil;
FText := '';
FFont := nil;
FUseColors := False;
end;

procedure TSTextVertexModel.SetText(const NewText : TSString);
var
	WidthShift : TSMaxEnum;
	DXShift : TSSingle = 0;

procedure SetSymbolPoligone(const SymbolNumber : TSMaxEnum; const SymbolParam : TSSymbolParam); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Symbol : TSTextVertexModelSymbol;
begin
Symbol.Vectors[0].Import(WidthShift, 0);
Symbol.Vectors[1].Import(WidthShift + SymbolParam.Width, 0);
Symbol.Vectors[2].Import(WidthShift + SymbolParam.Width, FFont.FontHeight);
Symbol.Vectors[3].Import(WidthShift, FFont.FontHeight);
WidthShift += SymbolParam.Width;

Symbol.TextVectors[0].Import(
	(SymbolParam.x + DXShift)/FFont.Width,
	1 - (SymbolParam.y/FFont.Height));
Symbol.TextVectors[1].Import(
	(SymbolParam.x + SymbolParam.Width + DXShift)/FFont.Width,
	1 - (SymbolParam.y/FFont.Height));
Symbol.TextVectors[2].Import(
	(SymbolParam.x + SymbolParam.Width + DXShift)/FFont.Width,
	1 - ((SymbolParam.y + FFont.FontHeight)/FFont.Height));
Symbol.TextVectors[3].Import(
	(SymbolParam.x + DXShift)/FFont.Width,
	1 - ((SymbolParam.y + FFont.FontHeight)/FFont.Height));

SetSymbol(SymbolNumber, Symbol);
end;

var
	i : TSMaxEnum;
begin
if (FFont = nil) then
	Exit;
SKill(FMesh);
FText := NewText;
if (FText = '') then
	Exit;
if Render.RenderType in [SRenderDirectX9, SRenderDirectX8] then
	DXShift := 0.5;
FMesh := TS3DObject.Create();
FMesh.SetContext(Context);
FMesh.HasColors := FUseColors;
FMesh.ObjectPoligonesType := SR_TRIANGLES;
FMesh.ObjectColor := SColor4fFromUInt32($FFFFFFFF);
FMesh.EnableCullFace := False;
FMesh.HasNormals := False;
FMesh.QuantityFaceArrays := 0;
FMesh.HasTexture := True;
FMesh.Vertexes := 2 * 3 * Length(FText);
WidthShift := 0;
for i := 1 to Length(FText) do
	SetSymbolPoligone(i, FFont.SymbolParams[FText[i]]);
FMesh.LoadToVBO();
end;

procedure TSTextVertexModel.SetSymbol(const SymbolNumber : TSMaxEnum; const Symbol : TSTextVertexModelSymbol);
var
	SymbolIndex : TSMaxEnum;
begin
SymbolIndex := (SymbolNumber - 1) * 6;
FMesh.ArVertex3f[SymbolIndex + 0]^  := Symbol.Vectors[0];
FMesh.ArVertex3f[SymbolIndex + 1]^  := Symbol.Vectors[1];
FMesh.ArVertex3f[SymbolIndex + 2]^  := Symbol.Vectors[2];
FMesh.ArVertex3f[SymbolIndex + 3]^  := Symbol.Vectors[0];
FMesh.ArVertex3f[SymbolIndex + 4]^  := Symbol.Vectors[2];
FMesh.ArVertex3f[SymbolIndex + 5]^  := Symbol.Vectors[3];
FMesh.ArTexVertex[SymbolIndex + 0]^ := Symbol.TextVectors[0];
FMesh.ArTexVertex[SymbolIndex + 1]^ := Symbol.TextVectors[1];
FMesh.ArTexVertex[SymbolIndex + 2]^ := Symbol.TextVectors[2];
FMesh.ArTexVertex[SymbolIndex + 3]^ := Symbol.TextVectors[0];
FMesh.ArTexVertex[SymbolIndex + 4]^ := Symbol.TextVectors[2];
FMesh.ArTexVertex[SymbolIndex + 5]^ := Symbol.TextVectors[3];
if FUseColors then
	begin
	FMesh.SetColor(SymbolIndex + 0, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	FMesh.SetColor(SymbolIndex + 1, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	FMesh.SetColor(SymbolIndex + 2, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	FMesh.SetColor(SymbolIndex + 3, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	FMesh.SetColor(SymbolIndex + 4, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	FMesh.SetColor(SymbolIndex + 5, Symbol.Color.x, Symbol.Color.y, Symbol.Color.z,  Symbol.Color.w);
	end;
end;

destructor TSTextVertexModel.Destroy();
begin
SKill(FMesh);
inherited;
end;

class function TSTextVertexModel.ClassName():TSString;
begin
Result := 'TSTextVertexModel';
end;

end.
