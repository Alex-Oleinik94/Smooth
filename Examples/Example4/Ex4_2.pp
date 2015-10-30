{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex4_2;
	interface
{$ELSE}
	program Example4_2;
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
	,SaGeCommon
	;
type
	TSGExample4_2=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FArray  : packed array[0..35] of 
			packed record
				FVertex:TSGVertex3f;
				FColor:TSGColor4b;
				end;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample4_2.ClassName():TSGString;
begin
Result := 'Вывод неиндексированым массивом из оперативки';
end;

constructor TSGExample4_2.Create(const VContext : TSGContext);
var
	i:TSGByte;
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);

i:=0;
FArray[i+0].FVertex.Import(1,1,1);
FArray[i+0].FColor .Import(255,255,255);
FArray[i+1].FVertex.Import(1,1,-1);
FArray[i+1].FColor .Import(255,255,0);
FArray[i+2].FVertex.Import(1,-1,-1);
FArray[i+2].FColor .Import(255,0,255);
FArray[i+3].FVertex.Import(1,-1,1);
FArray[i+3].FColor .Import(0,255,255);
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

i+=6;
FArray[i+0]:=FArray[0];
FArray[i+1]:=FArray[3];
FArray[i+2].FVertex.Import(-1,-1,1);
FArray[i+2].FColor .Import(255,0,0);
FArray[i+3].FVertex.Import(-1,1,1);
FArray[i+3].FColor .Import(0,0,255);
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

i+=6;
FArray[i+0]:=FArray[3];
FArray[i+1]:=FArray[2];
FArray[i+2].FVertex.Import(-1,-1,-1);
FArray[i+2].FColor .Import(0,0,0);
FArray[i+3]:=FArray[8];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

i+=6;
FArray[i+0]:=FArray[0];
FArray[i+1]:=FArray[9];
FArray[i+2].FVertex.Import(-1,1,-1);
FArray[i+2].FColor .Import(0,255,0);
FArray[i+3]:=FArray[1];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

i+=6;
FArray[i+0]:=FArray[9];
FArray[i+1]:=FArray[3*6+2];
FArray[i+2]:=FArray[2*6+2];
FArray[i+3]:=FArray[8];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

i+=6;
FArray[i+0]:=FArray[1];
FArray[i+1]:=FArray[2];
FArray[i+2]:=FArray[2*6+2];
FArray[i+3]:=FArray[3*6+2];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// А вод тут у нас проблемка. 
// Дело в том, что в DirectX можно использовать цвета в формате UNSIGNED_BYTE как (b;g;r;a).
// А в OpenGL можно использовать как FLOAT (r;g;b) и (r;g;b;a), так и UNSIGNED_BYTE (r;g;b) и (r;g;b;a).
// И получается, что синий и красный цвета меняются местами. Поэтому мы их меняем обратно.
// Для решения этой проблемы реализован класс TSGMesh, которы сам делает все эти операции, 
//   и поддерживает работу с разными форматами цветов одной процедурой.
if Render.RenderType=SGRenderOpenGL then
	for i:=Low(FArray) to High(FArray) do
		FArray[i].FColor.ConvertType();
end;

destructor TSGExample4_2.Destroy();
begin
inherited;
end;

procedure TSGExample4_2.Draw();
begin
FCamera.CallAction();

Render.EnableClientState(SGR_VERTEX_ARRAY);
Render.EnableClientState(SGR_COLOR_ARRAY);

Render.VertexPointer(3, SGR_FLOAT,         SizeOf(FArray[0]), @FArray[0].FVertex);
Render.ColorPointer (4, SGR_UNSIGNED_BYTE, SizeOf(FArray[0]), @FArray[0].FColor);

Render.DrawArrays(SGR_TRIANGLES, 0, Length(FArray));

Render.DisableClientState(SGR_COLOR_ARRAY);
Render.DisableClientState(SGR_VERTEX_ARRAY);
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample4_2;
	RunApplication();
	{$ENDIF}
end.
